unit Debug;
{
    Copyright 2001, Peter Millard

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

interface

uses
    Dockable, 
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus;

type
  TfrmDebug = class(TfrmDockable)
    Panel1: TPanel;
    chkDebugWrap: TCheckBox;
    Panel2: TPanel;
    MsgDebug: TRichEdit;
    MemoSend: TMemo;
    Splitter1: TSplitter;
    Panel3: TPanel;
    btnSendRaw: TButton;
    btnClearDebug: TButton;
    PopupMenu1: TPopupMenu;
    popMsg: TMenuItem;
    popIQGet: TMenuItem;
    popIQSet: TMenuItem;
    popPres: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure chkDebugWrapClick(Sender: TObject);
    procedure btnClearDebugClick(Sender: TObject);
    procedure btnSendRawClick(Sender: TObject);
    procedure popMsgClick(Sender: TObject);
  private
    { Private declarations }
    procedure DebugCallback(send: boolean; data: string);
  public
    { Public declarations }
  end;

var
  frmDebug: TfrmDebug;

implementation

{$R *.dfm}
uses
    Session, Jabber1;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure TfrmDebug.FormCreate(Sender: TObject);
begin
    // make sure the output is showing..
    inherited;
    MainSession.Stream.RegisterSocketCallback(DebugCallback);
end;

{---------------------------------------}
procedure TfrmDebug.DebugCallback(send: boolean; data: string);
begin
    if send then with MsgDebug do begin
        SelStart := GetTextLen;
        SelLength := 0;
        SelAttributes.Color := clBlue;
        SelText := 'SENT: ' + data + #13#10;
        SelAttributes.Color := clBlack;
        end
    else with MsgDebug do begin
        SelStart := GetTextLen;
        SelLength := 0;
        SelAttributes.Color := clGreen;
        SelText := 'RECV: ' + data + #13#10;
        SelAttributes.Color := clBlack;
        end;

    with MsgDebug do begin
        SelStart := GetTextLen;
        Perform(EM_SCROLLCARET, 0, 0);
        end;

end;

{---------------------------------------}
procedure TfrmDebug.chkDebugWrapClick(Sender: TObject);
begin
    MsgDebug.WordWrap := chkDebugWrap.Checked;
end;

{---------------------------------------}
procedure TfrmDebug.btnClearDebugClick(Sender: TObject);
begin
    MsgDebug.Lines.Clear;
end;

{---------------------------------------}
procedure TfrmDebug.btnSendRawClick(Sender: TObject);
begin
    // Send the text in the MsgSend memo box
    MainSession.Stream.Send(MemoSend.Lines.Text);
end;

{---------------------------------------}
procedure TfrmDebug.popMsgClick(Sender: TObject);
var
    id: string;
begin
    // setup an XML fragment
    id := MainSession.generateID;
    with MemoSend.Lines do begin
        Clear;
        if Sender = popMsg then
            Add('<message to="" id="' + id + '"><body></body></message>')
        else if Sender = popIQGet then
            Add('<iq type="get" to="" id="' + id + '"><query xmlns=""></query></iq>')
        else if Sender = popIQSet then
            Add('<iq type="set" to="" id="' + id + '"><query xmlns=""></query></iq>')
        else if Sender = popPres then
            Add('<presence to="" id="' + id + '"/>');
        end;
end;

end.