unit Dockable;
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
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    ComCtrls, Dialogs, ExtCtrls, TntComCtrls, TntForms;

type
  TDockNotify = procedure of object;
  {
    Dockable forms may be docked/undocked either through drag -n- dock operations
    or programatically through their DockForm/FloatForm methods. Because there
    are two different paths that result in this state change One set of events
    has been defined that will fire in either case.

    OnDockStartChange will be fired when either the OnStartDock event is fired
    immediately before any dock change is requested programactically. Subclasses
    should use the Docked (possibly Visible) property to check their current state
    And assume the property will be toggled after this event has fired.

    OnDockEndChange will fire when the OnEndDock event has been fired or after the
    form has been programatically docked/floated.
  }
  TfrmDockable = class(TTntForm)
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    {
        Drag event.

        Override default event handlers to change when this form should accept
        dragged objects. Fired by dock manager when user drags something over
        tab.
    }
    procedure OnDockedDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);virtual;
    {
        Drop event

        Override to handle objects dropped into form, specifically
        from dock manager (tabs)
    }
    procedure OnDockedDragDrop(Sender, Source: TObject; X, Y: Integer); virtual;
  private
    { Private declarations }
    _docked: boolean;
    _pos: TRect;
    _noMoveCheck: boolean;
    _top: boolean;

    _onDockStartChange: TDockNotify;
    _onDockEndChange: TDockNotify;

    procedure CheckPos();
    procedure SavePos();

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMActivate(var msg: TMessage); message WM_ACTIVATE;
    procedure WMDisplayChange(var msg: TMessage); message WM_DISPLAYCHANGE;
    procedure WMWindowPosChanging(var msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  published
    property OnDockStartChange: TDockNotify read _onDockStartChange write _onDockStartChange;
    property OnDockEndChange: TDockNotify read _onDockEndChange write _onDockEndChange;
  public
    { Public declarations }
    TabSheet: TTntTabSheet;
    ImageIndex: integer;
    procedure DockForm; virtual;
    procedure FloatForm; virtual;
    procedure ShowDefault;
    procedure gotActivate; virtual;
    {
        Event fired when Form receives activation while in docked state.

        Fired by DockManager when tab is activated (brought to front)
    }
    procedure OnDockedActivate(Sender : TObject);virtual;


    property Docked: boolean read _docked write _docked;

    property FloatPos: TRect read _pos;
  end;

var
  frmDockable: TfrmDockable;

implementation

{$R *.dfm}

uses
    XMLUtils, ChatWin, Debug, JabberUtils, ExUtils,  GnuGetText, Session, Jabber1;

{---------------------------------------}
procedure TfrmDockable.FormCreate(Sender: TObject);
begin
    ImageIndex := 43;

    _docked := false;
    _noMoveCheck := true;

    // do translation magic
    AssignUnicodeFont(Self);
    TranslateComponent(Self);

    if (Self is TfrmChat) then
        // do nothing
    else
        MainSession.Prefs.RestorePosition(Self);

    SnapBuffer := MainSession.Prefs.getInt('edge_snap');

    Self.SavePos();

    _noMoveCheck := false;
end;

{
    Drag event.

    Override default event handlers to change when this form should accept
    dragged objects. This is called from dock manager (tabs)
}
procedure TfrmDockable.OnDockedDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
    inherited;
    Accept := false;
    //implement in subclass
end;

{
    Drop event

    Override to handle objects dropped into form, specifically
    from dock manager (tabs)
}
procedure TfrmDockable.OnDockedDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
    inherited;
    //implement in subclass
end;

{---------------------------------------}
procedure TfrmDockable.DockForm;
begin
    // dock the window to the main form
    if Assigned(_onDockStartChange) then
        Self.OnDockStartChange();

    Self.SavePos();
    Self.TabSheet := frmExodus.OpenDocked(self);
    Self.Align := alClient;
    _docked := true;

    if (Self.TabSheet <> nil) then
        Self.TabSheet.ImageIndex := ImageIndex;;

    if Assigned(_onDockEndChange) then
        Self.OnDockEndChange();
end;

{---------------------------------------}
procedure TfrmDockable.CheckPos();
begin
    if (_pos.Right - _pos.Left) <= 100 then
        _pos.Right := _pos.Left + 150;

    if (_pos.Bottom - _pos.Top) <= 100 then
        _pos.Bottom := _pos.Top + 150;
end;

{---------------------------------------}
procedure TfrmDockable.SavePos();
begin
    _pos.Left := Self.Left;
    _pos.Right := Self.Left + Self.Width;
    _pos.Top := Self.Top;
    _pos.Bottom := Self.Top + Self.Height;
end;

{---------------------------------------}
procedure TfrmDockable.FloatForm;
begin
    if Assigned(_onDockStartChange) then
        Self.OnDockStartChange();
    Self.CheckPos();
    frmExodus.FloatDocked(Self);
    _docked := false;
    Self.TabSheet := nil;
    if Assigned(_onDockEndChange) then
        Self.OnDockEndChange();
end;

{---------------------------------------}
procedure TfrmDockable.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    if ((not _docked) and (MainSession <> nil)) then begin
        if (Self is TfrmChat) then
            MainSession.Prefs.SavePosition(Self, MungeName(Self.Caption))
        else
            MainSession.Prefs.SavePosition(Self);
    end
    else
        frmExodus.CloseDocked(Self);

    CanClose := true;
end;

{---------------------------------------}
procedure TfrmDockable.CreateParams(var Params: TCreateParams);
begin
    // Make each window appear on the task bar.
    inherited CreateParams(Params);
    with Params do begin
        ExStyle := ExStyle or WS_EX_APPWINDOW;
    end;
end;

{---------------------------------------}
procedure TfrmDockable.ShowDefault;
begin
    // show this form using the default behavior
    if (Jabber1.getAllowedDockState() <> adsForbidden) then begin
        if (TabSheet = nil) then begin
            // dock the form
            Self.DockForm();
            Self.Show();
            Self.Visible := true;
        end
        else
            frmExodus.BringDockedToTop(Self);
    end
    else begin
        if (frmExodus.isMinimized()) then
            ShowWindow(Handle, SW_SHOWMINNOACTIVE)
        else
            ShowWindow(Handle, SW_SHOWNOACTIVATE);
        Self.Visible := true;
    end;

end;

{---------------------------------------}
procedure TfrmDockable.WMDisplayChange(var msg: TMessage);
begin
    checkAndCenterForm(Self);
end;

{---------------------------------------}
procedure TfrmDockable.WMActivate(var msg: TMessage);
var
    m: Widestring;
begin
    if ((not _top) and
        ((Application.Active) or (Msg.WParamLo = WA_CLICKACTIVE))) then begin
        // we are getting clicked..
        m := 'frmDockable.WMActivate ' + Self.Caption;
        OutputDebugString(PChar(m));

        _top := true;
        SetWindowPos(Self.Handle, 0, Self.Left, Self.Top,
            Self.Width, Self.Height, HWND_TOP);
        _top := false;

        StopTrayAlert();
        gotActivate();
    end;

    inherited;
end;

{---------------------------------------}
procedure TfrmDockable.WMWindowPosChanging(var msg: TWMWindowPosChanging);
begin
    //
    if (not _top) then
        msg.WindowPos^.flags := msg.WindowPos^.flags or SWP_NOZORDER;

    inherited;
end;

{---------------------------------------}
procedure TfrmDockable.gotActivate();
begin
    // implement this in sub-classes.
end;

{---------------------------------------}
procedure TfrmDockable.FormResize(Sender: TObject);
begin
    savePos();
    if ((MainSession <> nil)) then
        MainSession.Prefs.SavePosition(Self);
end;

{---------------------------------------}
{
    Event fired at the end of a drag -n- dock operation

    Will also fire when a tab change takes place
}
procedure TfrmDockable.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
    //impl in subclasses
end;


{

    Event fired when Form receives activation while in docked state.

    Fired by DockManager when tab is activated (brought to front)
}
procedure TfrmDockable.OnDockedActivate(Sender : TObject);
begin
    inherited;
    //subclasses override to change activation behavior
     if (Self.TabSheet <> nil) then
        Self.TabSheet.ImageIndex := ImageIndex;
end;

end.
