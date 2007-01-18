unit Roster;
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
    XMLTag,
    JabberID,
    Signals,
    SysUtils, Classes;

type
    TJabberRosterItem = class
    private
        procedure fillTag(tag: TXMLTag);
    public
        jid: TJabberID;
        subscription: string;
        ask: string;
        nickname: string;
        Groups: TStringList;
        Data: TObject;

        constructor Create; overload;
        destructor Destroy; override;

        function xml: string;
        procedure parse(tag: TXMLTag);
        procedure remove;
        procedure update;
    end;

    TJabberBookmark = class
    public
        jid: TJabberID;
        bmType: string;
        name: string;

        constructor Create(tag: TXMLTag);
        destructor Destroy; override;
    end;

    TRosterEvent = procedure(event: string; tag: TXMLTag; ritem: TJabberRosterItem) of object;
    TRosterListener = class(TSignalListener)
    public
    end;

    TRosterSignal = class(TSignal)
    public
        procedure Invoke(event: string; tag: TXMLTag; ritem: TJabberRosterItem = nil); overload;
        function addListener(callback: TRosterEvent): TRosterListener; overload;
    end;

    TJabberRoster = class(TStringList)
    private
        _js: TObject;
        _callbacks: TList;
        _add_subscribe: boolean;
        _add_jid: string;
        procedure Callback(event: string; tag: TXMLTag);
        procedure AddCallback(event: string; tag: TXMLTag);
        procedure checkGroups(ri: TJabberRosterItem);
        procedure checkGroup(grp: string);
    public
        GrpList: TStringList;
        Bookmarks: TStringList;

        constructor Create;
        destructor Destroy; override;

        procedure Clear; override;

        procedure SetSession(js: TObject);
        procedure Fetch;
        procedure ParseFullRoster(tag: TXMLTag);

        procedure AddItem(sjid, nickname, group: string; subscribe: boolean);
        function Find(sjid: string): TJabberRosterItem; reintroduce; overload;
    end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
uses
    IQ,
    Presence,
    S10n,
    XMLUtils,
    Session;

{---------------------------------------}
constructor TJabberBookmark.Create(tag: TXMLTag);
begin
    //
    inherited Create;
    jid := TJabberID.Create(tag.GetAttribute('jid'));
    name := tag.getAttribute('name');
    bmType := tag.name;
end;

{---------------------------------------}
destructor TJabberBookmark.Destroy;
begin
    jid.Free;
    inherited Destroy;
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TJabberRosterItem.Create;
begin
    inherited Create;

    Groups := TStringList.Create;
    jid := TJabberID.Create('');
    subscription := 'none';
    nickname := '';
    ask := '';
end;

{---------------------------------------}
destructor TJabberRosterItem.Destroy;
begin
    Groups.Free;
    jid.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TJabberRosterItem.fillTag(tag: TXMLTag);
var
    i: integer;
begin
    tag.name := 'item';
    tag.PutAttribute('jid', jid.Full);
    tag.PutAttribute('name', nickname);

    for i := 0 to Groups.Count - 1 do
        tag.AddBasicTag('group', Groups[i]);
end;

{---------------------------------------}
procedure TJabberRosterItem.Update;
var
    item, iq: TXMLTag;
begin
    iq := TXMLTag.Create('iq');
    iq.PutAttribute('type', 'set');
    iq.PutAttribute('id', MainSession.generateID());
    with iq.AddTag('query') do begin
        putAttribute('xmlns', 'jabber:iq:roster');
        item := AddTag('item');
        Self.fillTag(item);
        end;

    MainSession.SendTag(iq);
end;

{---------------------------------------}
procedure TJabberRosterItem.remove;
begin
    // remove this roster item from my roster;
    subscription := 'remove';
    update();
end;

{---------------------------------------}
function TJabberRosterItem.xml: string;
var
    x: TXMLTag;
begin
    x := TXMLTag.Create('item');
    Self.FillTag(x);
    Result := x.xml;
    x.Free;
end;

{---------------------------------------}
procedure TJabberRosterItem.parse(tag: TXMLTag);
var
    grps: TXMLTagList;
    i: integer;
begin
    // fill the object based on the tag
    jid.ParseJID(tag.GetAttribute('jid'));
    subscription := tag.GetAttribute('subscription');
    ask := tag.GetAttribute('ask');
    if subscription = 'none' then subscription := '';
    nickname := tag.GetAttribute('name');

    Groups.Clear;
    grps := tag.QueryTags('group');
    for i := 0 to grps.Count - 1 do
        Groups.Add(TXMLTag(grps[i]).Data);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TJabberRoster.Create;
begin
    inherited Create;

    GrpList := TStringList.Create;
    _callbacks := TList.Create;
    Bookmarks := TStringList.Create;
end;

{---------------------------------------}
destructor TJabberRoster.Destroy;
begin
    GrpList.Free;
    _callbacks.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TJabberRoster.Clear;
begin
    // Free all the roster items.
    while Count > 0 do begin
        TJabberRosterItem(Objects[Count - 1]).Free;
        Delete(Count - 1);
        end;
    GrpList.Clear;
end;

{---------------------------------------}
procedure TJabberRoster.SetSession(js: TObject);
begin
    _js := js;
    with TJabberSession(_js) do
        RegisterCallback(Callback, '/packet/iq/query[@xmlns="jabber:iq:roster"]');
end;

{---------------------------------------}
procedure TJabberRoster.Fetch;
var
    js: TJabberSession;
    x: TXMLTag;
begin
    js := TJabberSession(_js);
    x := TXMLTag.Create('iq');
    x.PutAttribute('id', js.generateID);
    x.PutAttribute('type', 'get');
    with x.AddTag('query') do
        PutAttribute('xmlns', XMLNS_ROSTER);
    js.SendTag(x);
end;

{---------------------------------------}
procedure TJabberRoster.Callback(event: string; tag: TXMLTag);
var
    q: TXMLTag;
    bmtags, ritems: TXMLTagList;
    ri: TJabberRosterItem;
    bm: TJabberBookmark;
    idx, i: integer;
    iq_type, j: string;
    s: TJabberSession;
begin
    // callback from the session
    s := TJabberSession(_js);
    if tag.Namespace = 'jabber:iq:roster' then begin
        // deal with it...this is some kind of roster push
        iq_type := tag.GetAttribute('type');
        if iq_type = 'set' then begin
            // a roster push
            q := tag.GetFirstTag('query');
            if q = nil then exit;
            ritems := q.QueryTags('item');
            for i := 0 to ritems.Count - 1 do begin
                j := Lowercase(ritems[i].GetAttribute('jid'));
                ri := Find(j);
                if ri = nil then begin
                    ri := TJabberRosterItem.Create;
                    Self.AddObject(j, ri);
                    end;
                ri.parse(ritems[i]);
                checkGroups(ri);
                s.FireEvent('/roster/item', tag, ri);
                if (ri.subscription = 'remove') then begin
                    idx := Self.indexOfObject(ri);
                    ri.Free;
                    Self.Delete(idx);
                    end;
                end;

            bmtags := q.QueryTags('conference');
            for i := 0 to bmtags.count - 1 do begin
                j := Lowercase(bmtags[i].GetAttribute('jid'));
                idx := Bookmarks.indexOf(j);
                if idx >= 0 then begin
                    TJabberBookmark(Bookmarks.Objects[idx]).Free;
                    Bookmarks.Delete(idx);
                    end;
                bm := TJabberBookmark.Create(bmtags[i]);
                Bookmarks.AddObject(j, bm);
                checkGroup('Bookmarks');
                s.FireEvent('/roster/conference', bmtags[i], TJabberRosterItem(nil));
                end;
            end
        else begin
            // prolly a full roster
            ParseFullRoster(tag);
            end;
        end;
end;

{---------------------------------------}
procedure TJabberRoster.checkGroups(ri: TJabberRosterItem);
var
    g: integer;
    cur_grp: string;
begin
    // make sure the GrpList is populated.
    for g := 0 to ri.Groups.Count - 1 do begin
        cur_grp := ri.Groups[g];
        checkGroup(cur_grp);
        end;
end;

{---------------------------------------}
procedure TJabberRoster.checkGroup(grp: string);
begin
    if GrpList.indexOf(grp) < 0 then
        GrpList.Add(grp);
end;

{---------------------------------------}
function TJabberRoster.Find(sjid: string): TJabberRosterItem;
var
    i: integer;
begin
    i := indexOf(Lowercase(sjid));
    if (i >= 0) and (i < Count) then
        Result := TJabberRosterItem(Objects[i])
    else
        Result := nil;
end;

{---------------------------------------}
procedure TJabberRoster.AddItem(sjid, nickname, group: string; subscribe: boolean);
var
    iq: TJabberIQ;
begin
    // send a iq-set
    iq := TJabberIQ.Create(MainSession, MainSession.generateID, Self.AddCallback);
    with iq do begin
        Namespace := XMLNS_ROSTER;
        iqType := 'set';
        with qTag.AddTag('item') do begin
            PutAttribute('jid', sjid);
            PutAttribute('name', nickname);
            if group <> '' then
                AddBasicTag('group', group);
            end;
        end;
    _add_subscribe := subscribe;
    _add_jid := sjid;
    iq.Send;
end;

{---------------------------------------}
procedure TJabberRoster.AddCallback(event: string; tag: TXMLTag);
var
    iq_type: string;
begin
    // callback for the roster add.
    if tag = nil then exit;
    iq_type := tag.getAttribute('type');
    if (((iq_type = 'set') or (iq_type = 'result')) and (_add_subscribe)) then
        SendSubscribe(_add_jid, MainSession);
end;

{---------------------------------------}
procedure TJabberRoster.ParseFullRoster(tag: TXMLTag);
var
    ct, qtag: TXMLTag;
    bms, ritems: TXMLTagList;
    i: integer;
    ri: TJabberRosterItem;
    s: TJabberSession;
    bm: TJabberBookmark;
begin
    // parse the full roster push
    Self.Clear;
    s := TJabberSession(_js);
    qtag := tag.GetFirstTag('query');
    if qtag = nil then exit;

    s.FireEvent('/roster/start', tag);

    ritems := qtag.QueryTags('item');
    for i := 0 to ritems.Count - 1 do begin
        ct := ritems.Tags[i];
        ri := TJabberRosterItem.Create;
        ri.parse(ct);
        checkGroups(ri);
        AddObject(Lowercase(ri.jid.Full), ri);
        // Fire('item', ri, ct);
        s.FireEvent('/roster/item', ritems.Tags[i], ri);
        end;

    bms := qtag.QueryTags('conference');
    for i := 0 to bms.Count - 1 do begin
        ct := bms.Tags[i];
        bm := TJabberBookmark.Create(ct);
        Bookmarks.AddObject(bm.jid.jid, bm);
        s.FireEvent('/roster/conference', ct, TJabberRosterItem(nil));
        end;

    s.FireEvent('/roster/end', nil);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
function TRosterSignal.addListener(callback: TRosterEvent): TRosterListener;
var
    l: TRosterListener;
begin
    l := TRosterListener.Create();
    l.callback := TMethod(callback);
    Self.AddObject('', l);
    Result := l;
end;

{---------------------------------------}
procedure TRosterSignal.Invoke(event: string; tag: TXMLTag; ritem: TJabberRosterItem = nil);
var
    i: integer;
    l: TRosterListener;
    cmp, e: string;
    sig: TRosterEvent;
begin
    // dispatch this to all interested listeners
    cmp := Lowercase(Trim(event));
    for i := 0 to Self.Count - 1 do begin
        e := Strings[i];
        l := TRosterListener(Objects[i]);
        sig := TRosterEvent(l.callback);
        if (e <> '') then begin
            // check to see if the listener's string is a substring of the event
            if (Pos(e, cmp) >= 1) then
                sig(event, tag, ritem);
            end
        else
            sig(event, tag, ritem);
        end;
end;

end.
