unit RecvStatus;

{
    Copyright 2003, Peter Millard

    This file is part of Exodus.

    Exodus is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Exodus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Exodus; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{$ifdef VER150}
    {$define INDY9}
{$endif}

interface

uses
    Unicode, SyncObjs, XferManager, ShellApi, Contnrs, XMLTag,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ComCtrls, TntStdCtrls, ExtCtrls, IdSocks,
    IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
    IdIOHandler, IdIOHandlerSocket;

const
    WM_RECV_DONE = WM_USER + 6001;
    
    WM_RECV_SICONN = WM_USER + 6010;
    WM_RECV_SIDISCONN = WM_USER + 6011;
    WM_RECV_NEXT = WM_USER + 6012;

type

    TFileRecvThread = class;

    TFileRecvState = (recv_invalid, recv_recv, recv_done,
        recv_si_offer, recv_si_wait, recv_si_stream, recv_si_cancel);

    TfRecvStatus = class(TFrame)
        Panel3: TPanel;
        lblFile: TTntLabel;
        lblFrom: TTntLabel;
        Panel2: TPanel;
        lblStatus: TTntLabel;
        Bar1: TProgressBar;
        Panel1: TPanel;
        btnRecv: TButton;
        httpClient: TIdHTTP;
        tcpClient: TIdTCPClient;
        SaveDialog1: TSaveDialog;
        btnCancel: TButton;
        SocksHandler: TIdIOHandlerSocket;
        IdSocksInfo1: TIdSocksInfo;
    Bevel3: TBevel;
    Bevel2: TBevel;
        procedure btnRecvClick(Sender: TObject);
        procedure btnCancelClick(Sender: TObject);
    private
        { Private declarations }
        _thread: TFileRecvThread;
        _state: TFileRecvState;
        _filename: string;
        _pkg: TFileXferPkg;
        _sid: Widestring;
        _hosts: TQueue;
        _cur: integer;
        _stream: TFileStream;
        _size: longint;

        procedure attemptSIConnection();

    protected
        procedure WMRecvDone(var msg: TMessage); message WM_RECV_DONE;
        procedure WMRecvConn(var msg: TMessage); message WM_RECV_SICONN;
        procedure WMRecvDisconn(var msg: TMessage); message WM_RECV_SIDISCONN;
        procedure WMRecvNext(var msg: TMessage); message WM_RECV_NEXT;

    published
       procedure BytestreamCallback(event: string; tag: TXMLTag);

    public
        { Public declarations }
        procedure setup(pkg: TFileXferPkg);
    end;

    TFileRecvThread = class(TThread)
    private
        _http: TIdHTTP;
        _client: TIdTCPClient;
        _stream: TFileStream;
        _form: TfRecvStatus;
        _pos_max: longint;
        _pos: longint;
        _new_txt: TWidestringlist;
        _lock: TCriticalSection;
        _url: string;
        _method: string;
        _size: longint;

        procedure Update();
        procedure setHttp(value: TIdHttp);
        procedure setClient(value: TIdTCPClient);

        procedure httpClientStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: String);
        procedure httpClientConnected(Sender: TObject);
        procedure httpClientDisconnected(Sender: TObject);
        procedure httpClientWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
        procedure httpClientWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
        procedure httpClientWorkBegin(Sender: TObject; AWorkMode: TWorkMode; const AWorkCountMax: Integer);

        procedure tcpClientConnected(Sender: TObject);
        procedure tcpClientDisconnected(Sender: TObject);
        procedure tcpClientStatus(ASender: TObject; const AStatus: TIdStatus;
            const AStatusText: String);

    protected
        procedure Execute; override;

    public
        constructor Create(); reintroduce;

        property http: TIdHttp read _http write setHttp;
        property stream: TFileStream read _stream write _stream;
        property form: TfRecvStatus read _form write _form;
        property url: String read _url write _url;
        property method: String read _method write _method;
        property client: TIdTCPClient read _client write setClient;
        property size: longint read _size write _size;
    end;

implementation

{$R *.dfm}

uses
    XMLUtils, StrUtils, 
    IQ, GnuGetText, Session, JabberConst, ExUtils;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TFileRecvThread.Create();
begin
    //
    inherited Create(true);
    
    _pos := 0;
    _form := nil;
    _new_txt := TWidestringlist.Create();
    _lock := TCriticalSection.Create();

end;

{---------------------------------------}
procedure TFileRecvThread.setHttp(value: TIdHttp);
begin
    _client := nil;
    _http := Value;
    with _http do begin
        OnConnected := Self.httpClientConnected;
        OnDisconnected := Self.httpClientDisconnected;
        OnWork := Self.httpClientWork;
        OnWorkBegin := Self.httpClientWorkBegin;
        OnWorkEnd := Self.httpClientWorkEnd;
        OnStatus := httpClientStatus;
    end;
end;

{---------------------------------------}
procedure TFileRecvThread.setClient(value: TIdTCPClient);
begin
    _http := nil;
    _client := value;
    with _client do begin
        OnConnected := Self.tcpClientConnected;
        OnDisconnected := Self.tcpClientDisconnected;
        onWork := Self.httpClientWork;
        onWorkBegin := Self.httpClientWorkBegin;
        onWorkEnd := Self.httpClientWorkEnd;
        onStatus := Self.tcpClientStatus;
    end;
end;

{---------------------------------------}
procedure TFileRecvThread.Execute();
var
    tmps: string;
begin
    try
        try
            if (_method = 'si') then begin
                try
                    _client.Connect();
                except
                    SendMessage(_form.Handle, WM_RECV_SIDISCONN, 0, 0);
                    exit;
                end;
                // This is BS, but we're getting a NULL in the first
                // byte of the stream, so just suck it off the socket,
                // and move on. *sigh* I have no idea where it's coming from.
                tmps := _client.ReadString(1);
                _client.ReadStream(_stream, _size, false);
            end
            else if (_method = 'get') then
                _http.Get(_url, _stream)
            else
                _http.Put(Self.url, _stream);
        finally
            FreeAndNil(_stream);
        end;
    except
    end;

    if (_http <> nil) then
        SendMessage(_form.Handle, WM_RECV_DONE, 0, _http.ResponseCode)
    else
        SendMessage(_form.Handle, WM_RECV_DONE, 0, 0);
end;

{---------------------------------------}
procedure TFileRecvThread.Update();
begin
    _lock.Acquire();

    if ((Self.Suspended) or (Self.Terminated)) then begin
        _lock.Release();
        if (_http <> nil) then
            _http.DisconnectSocket()
        else
            _client.DisconnectSocket();
        FreeAndNil(_stream);
        Self.Terminate();
    end;

    with _form do begin
        if (_pos_max > 0) then
            bar1.Max := _pos_max;
        bar1.Position := _pos;
        if (_new_txt.Count > 0) then begin
            lblStatus.Caption := _new_txt[_new_txt.Count - 1];
            _new_txt.Clear();
        end;
    end;

    _lock.Release();
end;

{---------------------------------------}
procedure TFileRecvThread.httpClientStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
    _lock.Acquire();
    _new_txt.Add(AStatusText);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileRecvThread.httpClientConnected(Sender: TObject);
begin
    _lock.Acquire();
    _new_txt.Add(sXferConn);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileRecvThread.httpClientDisconnected(Sender: TObject);
begin
    // NB: For Indy9, it fires disconnected before it actually
    // connects. So if we drop the stream here, our GETs
    // never work since the response stream gets freed.
    {$ifndef INDY9}
    if (_stream <> nil) then
        FreeAndNil(_stream);
    {$endif}
end;


{---------------------------------------}
procedure TFileRecvThread.httpClientWorkEnd(Sender: TObject;
  AWorkMode: TWorkMode);
begin
    _lock.Acquire();
    _new_txt.Add(sXferDone);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileRecvThread.httpClientWork(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCount: Integer);
begin
    // Update the progress meter
    _pos := AWorkCount;
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileRecvThread.httpClientWorkBegin(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCountMax: Integer);
begin
    if (AWorkCountMax > 0) then
        _pos_max := AWorkCountMax;
    _pos := 0;
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileRecvThread.tcpClientConnected(Sender: TObject);
begin
    // we connected, let our form know
    SendMessage(_form.Handle, WM_RECV_SICONN, 0, 0);
end;

{---------------------------------------}
procedure TFileRecvThread.tcpClientDisconnected(Sender: TObject);
begin
    // we NOT connected, let our form know
    //SendMessage(_form.Handle, WM_RECV_SIDISCONN, 0, 0);
end;

{---------------------------------------}
procedure TFileRecvThread.tcpClientStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
    _lock.Acquire();
    _new_txt.Add(AStatusText);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure TfRecvStatus.BytestreamCallback(event: string; tag: TXMLTag);
var
    i: integer;
    hosts: TXMLTagList;
    p: THostPortPair;
    pi: integer;
    e, r: TXMLTag;
    file_path: string;
    fStream: TFileStream;
begin
    //
    MainSession.UnRegisterCallback(_cur);
    _cur := -1;

    if (event = 'timeout') then begin
        // xxx: codeme
        exit;
    end;

    // check to see if they cancel'd before
    if (_state = recv_si_cancel) then begin
        r := jabberIQError(tag);
        e := r.AddTag('error');
        e.setAttribute('code', '406');
        e.AddCData('User Canceled the stream.');
        MainSession.SendTag(r);
        getXferManager().killFrame(Self);
        exit;
    end;

    // compile a list of hosts to try, and start at the beginning.
    while (_hosts.Count > 0) do begin
        p := THostPortPair(_hosts.Pop());
        p.Free();
    end;

    hosts := tag.QUeryXPTags('/iq/query/streamhost');
    for i := 0 to hosts.Count - 1 do begin
        pi := SafeInt(hosts[i].getAttribute('port'));
        // xxx: support zero-conf ID's
        if (pi > 0) then begin
            p := THostPortPair.Create();
            p.host := hosts[i].GetAttribute('host');
            p.port := pi;
            p.jid := hosts[i].GetAttribute('jid');
            _hosts.Push(p);
        end;
    end;

    if (_hosts.Count = 0) then begin
        r := jabberIQError(tag);
        e := r.AddTag('error');
        e.setAttribute('code', '406');
        e.AddCData('No acceptable hosts found');
        MainSession.SendTag(r);
        getXFerManager().killFrame(Self);
        exit;
    end;

    // use the save as dialog
    SaveDialog1.Filename := _filename;
    if (not SaveDialog1.Execute) then begin
        r := jabberIQError(tag);
        e := r.AddTag('error');
        e.setAttribute('code', '406');
        e.AddCData('User Canceled the stream.');
        MainSession.SendTag(r);
        getXferManager().killFrame(Self);
        exit;
    end;
    _filename := SaveDialog1.filename;

    if FileExists(_filename) then begin
        if MessageDlg(sXferOverwrite,
            mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
        DeleteFile(_filename);
    end;

    file_path := ExtractFilePath(_filename);
    if (not DirectoryExists(file_path)) then begin
        if MessageDlg(sXferCreateDir, mtConfirmation,
            [mbYes, mbNo], 0) = mrNo then exit;
        CreateDir(file_path);
    end;

    // Create a stream, and get the file into it.
    try
        fstream := TFileStream.Create(_filename, fmCreate);
    except
        on EStreamError do begin
            MessageDlg(sXferStreamError, mtError, [mbOK], 0);
            exit;
        end;
    end;

    _pkg.packet := TXMLTag.Create(tag);
    _stream := fStream;
    _stream.Seek(0, soFromBeginning);

    attemptSIConnection();
end;

{---------------------------------------}
procedure TfRecvStatus.attemptSIConnection();
var
    tmps, hash_key: Widestring;
    p: THostPortPair;
begin
    // ok, try and connect to the first host/port
    p := THostPortPair(_hosts.Peek());
    SocksHandler.SocksInfo.Authentication := saNoAuthentication;
    SocksHandler.SocksInfo.Version := svSocks5;
    SocksHandler.SocksInfo.Host := p.host;
    SocksHandler.SocksInfo.Port := p.Port;

    hash_key := _sid + _pkg.recip + MainSession.Jid;
    tmps := Sha1Hash(hash_key);
    tcpClient.IOHandler := SocksHandler;
    tcpClient.Host := tmps;
    tcpClient.Port := 0;

    _thread := TFileRecvThread.Create();
    _thread.url := '';
    _thread.form := Self;
    _thread.client := tcpClient;
    _thread.stream := _stream;
    _thread.method := 'si';
    _thread.size := _size;
    _thread.Resume();
end;

{---------------------------------------}
procedure TfRecvStatus.btnRecvClick(Sender: TObject);
var
    fp: Widestring;
    file_path: String;
    fStream: TFileStream;
    p, t, x: TXMLTag;
begin
    if _state = recv_done then begin
        // Open the file.
        ShellExecute(Application.Handle, 'open', PChar(_filename), '', '', SW_NORMAL);
    end;

    if (_pkg.mode = recv_si) then begin
        if (_state = recv_si_offer) then begin
            // send SI accept
            assert(_pkg.packet <> nil);
            p := _pkg.packet;
            _sid := p.QueryXPData('/iq/si@id');
            _filename := ExtractFilename(p.QueryXPData('/iq/si/file@name'));
            _size := SafeInt(p.QueryXPData('/iq/si/file@size')); 
            fp := MainSession.Prefs.getString('xfer_path');
            if (AnsiEndsText('\', fp)) then
                _filename := fp + _filename
            else
                _filename := fp + '\' + _filename;

            t := jabberIQResult(p);
            x := t.AddTagNS('si', XMLNS_SI);
            x.setAttribute('id', _sid);
            x := x.AddTagNS('feature', XMLNS_FEATNEG);
            x := x.AddTagNS('x', XMLNS_XDATA);
            x.setAttribute('type', 'submit');
            x := x.AddTag('field');
            x.setAttribute('var', 'stream-method');
            x.AddBasicTag('value', XMLNS_BYTESTREAMS);
            _state := recv_si_wait;

            _cur := MainSession.RegisterCallback(
                Self.BytestreamCallback,
                '/packet/iq[@type="set"]/query[@xmlns="' + XMLNS_BYTESTREAMS + '"]');

            MainSession.SendTag(t);
            FreeAndNil(_pkg.packet);

            btnRecv.Enabled := false;
        end;
    end

    else if (_pkg.mode = recv_oob) then begin
        if (_state = recv_recv) then begin
            // receive mode
            _filename := URLToFilename(_pkg.url);

            // use the save as dialog
            SaveDialog1.Filename := _filename;
            if (not SaveDialog1.Execute) then exit;
            _filename := SaveDialog1.filename;

            if FileExists(_filename) then begin
                if MessageDlg(sXferOverwrite,
                    mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
                DeleteFile(_filename);
            end;

            file_path := ExtractFilePath(_filename);
            if (not DirectoryExists(file_path)) then begin
                if MessageDlg(sXferCreateDir, mtConfirmation,
                    [mbYes, mbNo], 0) = mrNo then exit;
                CreateDir(file_path);
            end;

            // Create a stream, and get the file into it.
            try
                fstream := TFileStream.Create(_filename, fmCreate);
            except
                on EStreamError do begin
                    MessageDlg(sXferStreamError, mtError, [mbOK], 0);
                    exit;
                end;
            end;

            _thread := TFileRecvThread.Create();
            _thread.url := _pkg.url;
            _thread.form := Self;
            _thread.http := httpClient;
            _thread.stream := fstream;
            _thread.method := 'get';
            _thread.Resume();
        end;
    end;
end;

{---------------------------------------}
procedure TfRecvStatus.setup(pkg: TFileXferPkg);
begin
    _pkg := pkg;
    _state := recv_si_offer;
    _hosts := TQueue.Create();
    bar1.Max := pkg.size;
    lblFrom.Caption := pkg.recip;
    lblFile.Caption := ExtractFilename(pkg.pathname);
    lblStatus.Caption := _('Negotiating with sender...');
end;

{---------------------------------------}
procedure TfRecvStatus.WMRecvDone(var msg: TMessage);
var
    tmps: Widestring;
begin
    // our thread completed.
    if (_pkg.Mode = recv_si) then begin
        if (_state = recv_si_stream) then begin
            btnRecv.Enabled := true;
            btnRecv.Caption := sOpen;
            btnCancel.Caption := sClose;
            _state := recv_done;
            _thread := nil;
            bar1.Position := bar1.Max;
        end;
    end
    else if (_state = recv_recv) then begin
        if ((msg.LParam >= 200) and
            (msg.LParam < 300)) then begin
            btnRecv.Enabled := true;
            btnRecv.Caption := sOpen;
            btnCancel.Caption := sClose;
            _state := recv_done;
        end
        else begin
            tmps := Format(sXferRecvError, [msg.LParam]);
            MessageDlg(tmps, mtError, [mbOK], 0);
            DeleteFile(_filename);
        end;
    end;
end;

{---------------------------------------}
procedure TfRecvStatus.WMRecvConn(var msg: TMessage);
var
    p: THostPortPair;
    x, r: TXMLTag;
begin
    //
    r := jabberIQResult(_pkg.packet);
    p := THostPortPair(_hosts.Pop());

    x := r.AddTagNS('query', XMLNS_BYTESTREAMS);
    x.setAttribute('sid', _sid);
    x := x.AddTag('streamhost-used');
    x.setAttribute('jid', p.jid);
    _state := recv_si_stream;
    MainSession.SendTag(r);

    p.Free();

end;

{---------------------------------------}
procedure TfRecvStatus.WMRecvDisconn(var msg: TMessage);
begin
    // We couldn't connect to this host,
    // pick the next one.
    PostMessage(Self.Handle, WM_RECV_NEXT, 0, 0);
end;

{---------------------------------------}
procedure TfRecvStatus.WMRecvNext(var msg: TMessage);
var
    p: THostPortPair;
begin
    p := THostPortPair(_hosts.Pop());
    p.Free();
    if (_hosts.Count = 0) then exit;

    attemptSIConnection();
end;

{---------------------------------------}
procedure TfRecvStatus.btnCancelClick(Sender: TObject);
var
    xfm: TfrmXferManager;
    i: integer;
begin
    // cancel, or close
    if (_pkg.mode = recv_si) then begin

        if (_cur <> -1) then begin
            MainSession.UnRegisterCallback(_cur);
        end;

        case _state of
        recv_si_offer: begin
            // just refuse the SI, and close panel
            getXferManager().killFrame(Self);
            end;
        recv_si_wait: begin
            // disable btn, and wait for stream hosts, then
            // immediately turn around and refuse.
            end;
        recv_si_stream, recv_done: begin
            // kill the socket and close panel.
            if (_thread <> nil) then
                _thread.Terminate();
            getXferManager().killFrame(Self);
            end;
        end;
    end
    else begin
        xfm := getXferManager();
        i := xfm.getFrameIndex(Self);
        if (i = -1) then exit;
        SendMessage(xfm.Handle, WM_CLOSE_FRAME, i, 0);
    end;
end;



end.
