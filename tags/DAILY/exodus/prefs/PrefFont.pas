unit PrefFont;
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

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PrefPanel, StdCtrls, ComCtrls, RichEdit2, ExRichEdit, ExtCtrls,
  TntStdCtrls, TntExtCtrls, TntComCtrls;

type
  TfrmPrefFont = class(TfrmPrefPanel)
    lblRoster: TTntLabel;
    lblChat: TTntLabel;
    Label24: TTntLabel;
    Label25: TTntLabel;
    Label5: TTntLabel;
    clrBoxBG: TColorBox;
    clrBoxFont: TColorBox;
    btnFont: TTntButton;
    colorChat: TExRichEdit;
    FontDialog1: TFontDialog;
    lblColor: TTntLabel;
    colorRoster: TTntTreeView;
    TntLabel1: TTntLabel;
    cboIEStylesheet: TTntComboBox;
    btnCSSBrowse: TTntButton;
    TntLabel2: TTntLabel;
    cboMsgList: TTntComboBox;
    OpenDialog1: TOpenDialog;
    btnCSSEdit: TTntButton;
    procedure btnFontClick(Sender: TObject);
    procedure colorChatMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure clrBoxBGChange(Sender: TObject);
    procedure clrBoxFontChange(Sender: TObject);
    procedure colorRosterMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure cboMsgListChange(Sender: TObject);
    procedure btnCSSBrowseClick(Sender: TObject);
    procedure btnCSSEditClick(Sender: TObject);
  private
    { Private declarations }
    _clr_control: TControl;
    _clr_font_color: string;
    _clr_font: string;
    _clr_bg: string;

    procedure redrawChat();

  public
    { Public declarations }
    procedure LoadPrefs(); override;
    procedure SavePrefs(); override;
  end;

var
  frmPrefFont: TfrmPrefFont;

const
    sRosterFontLabel = 'Roster Font and Background';
    sChatFontLabel = 'Roster Font and Background';


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
{$R *.dfm}
uses
    ShellAPI, JabberUtils, ExUtils,  GnuGetText, JabberMsg, MsgDisplay, Session;

{---------------------------------------}
procedure TfrmPrefFont.LoadPrefs();
var
    n: TTntTreeNode;
begin
    inherited;

    n := colorRoster.Items.AddChild(nil, _('Sample Group'));
    colorRoster.Items.AddChild(n, _('Peter M.'));
    colorRoster.Items.AddChild(n, _('Cowboy Neal'));

    with MainSession.Prefs do begin
        with colorChat do begin
            Font.Name := getString('font_name');
            Font.Size := getInt('font_size');
            Font.Color := TColor(getInt('font_color'));
            Font.Charset := getInt('font_charset');
            if (Font.Charset = 0) then Font.Charset := 1;

            Font.Style := [];
            if (getBool('font_bold')) then Font.Style := Font.Style + [fsBold];
            if (getBool('font_italic')) then Font.Style := Font.Style + [fsItalic];
            if (getBool('font_underline')) then Font.Style := Font.Style + [fsUnderline];
            Color := TColor(getInt('color_bg'));
            Self.redrawChat();
        end;

        with colorRoster do begin
            Items[0].Expand(true);
            Color := TColor(getInt('roster_bg'));
            Font.Color := TColor(getInt('roster_font_color'));
            Font.Name := getString('roster_font_name');
            Font.Size := getInt('roster_font_size');
            Font.Charset := getInt('roster_font_charset');
            if (Font.Charset = 0) then Font.Charset := 1;
            Font.Style := [];
        end;
        lblColor.Caption := _(sRosterFontLabel);
        _clr_font := 'roster_font';
        _clr_font_color := 'roster_font_color';
        _clr_bg := 'roster_bg';
        _clr_control := colorRoster;

        btnFont.Enabled := true;
        clrBoxBG.Selected := TColor(MainSession.Prefs.getInt(_clr_bg));
        clrBoxFont.Selected := TColor(Mainsession.Prefs.getInt(_clr_font_color));

    end;
end;

{---------------------------------------}
procedure TfrmPrefFont.SavePrefs();
begin
    inherited;
    
    // All other saves happen as folks change settings in this dialog.
end;


{---------------------------------------}
procedure TfrmPrefFont.btnFontClick(Sender: TObject);
begin
  inherited;
    // Change the roster font
    with FontDialog1 do begin
        if (_clr_control = colorRoster) then
            Font.Assign(colorRoster.Font)
        else
            Font.Assign(colorChat.Font);

        if Execute then begin
            if (_clr_control = colorRoster) then
                colorRoster.Font.Assign(Font)
            else begin
                colorChat.Font.Assign(Font);
                redrawChat();
            end;

            with MainSession.prefs do begin
                setString(_clr_font + '_name', Font.Name);
                setInt(_clr_font + '_charset', Font.Charset);
                setInt(_clr_font + '_size', Font.Size);
                setBool(_clr_font + '_bold', (fsBold in Font.Style));
                setBool(_clr_font + '_italic', (fsItalic in Font.Style));
                setBool(_clr_font + '_underline', (fsUnderline in Font.Style));
            end;
        end;
    end;
end;

{---------------------------------------}
procedure TfrmPrefFont.redrawChat();
var
    m1, m2: TJabberMessage;
begin
    with colorChat do begin
        Lines.Clear;
        m1 := TJabberMessage.Create();
        with m1 do begin
            Body := _('Some text from me');
            isMe := true;
            Nick := _('Your nick');
        end;
        m2 := TJabberMessage.Create();
        with m2 do begin
            Body := _('Some reply text');
            isMe := false;
            Nick := _('Other nick');
        end;

        DisplayRTFMsg(colorChat, m1);
        DisplayRTFMsg(colorChat, m2);

        m1.Free();
        m2.Free();
    end;
end;

{---------------------------------------}
procedure TfrmPrefFont.colorChatMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    start: integer;
begin
    // Select the chat window
    lblColor.Caption := _(sChatFontLabel);
    _clr_control := colorChat;
    _clr_bg := 'color_bg';
    clrBoxBG.Selected := TColor(MainSession.Prefs.getInt(_clr_bg));

    start := colorChat.SelStart;

    if ((start >= 7) and (start <=  11)) then begin
        // on <pgm>, color-me
        _clr_font_color := 'color_me';
        _clr_font := '';
    end
    else if ((start >= 41) and (start <= 48)) then begin
        // on <c-neal>, color-other
        _clr_font_color := 'color_other';
        _clr_font := '';
    end
    else begin
        // normal window, font_color
        _clr_font_color := 'font_color';
        _clr_font := 'font';
    end;

    btnFont.Enabled := (_clr_font <> '');
    clrBoxFont.Selected := TColor(Mainsession.Prefs.getInt(_clr_font_color));
end;

{---------------------------------------}
procedure TfrmPrefFont.clrBoxBGChange(Sender: TObject);
begin
  inherited;
    // change in the bg color
    MainSession.Prefs.setInt(_clr_bg, Integer(clrBoxBG.Selected));
    if (_clr_control = colorChat) then
        colorChat.Color := clrBoxBG.Selected
    else
        colorRoster.Color := clrBoxBG.Selected;
end;

{---------------------------------------}
procedure TfrmPrefFont.clrBoxFontChange(Sender: TObject);
begin
  inherited;
    // change the font color
    MainSession.Prefs.setInt(_clr_font_color, integer(clrBoxFont.Selected));
    if (_clr_control = colorChat) then
        redrawChat()
    else
        colorRoster.Font.Color := clrBoxFont.Selected;
end;

{---------------------------------------}
procedure TfrmPrefFont.colorRosterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
    // find the "thing" that we clicked on in the window..
    lblColor.Caption := _(sRosterFontLabel);
    _clr_font := 'roster_font';
    _clr_font_color := 'roster_font_color';
    _clr_bg := 'roster_bg';
    _clr_control := colorRoster;

    btnFont.Enabled := true;
    clrBoxBG.Selected := TColor(MainSession.Prefs.getInt(_clr_bg));
    clrBoxFont.Selected := TColor(Mainsession.Prefs.getInt(_clr_font_color));
end;

{---------------------------------------}
procedure TfrmPrefFont.FormCreate(Sender: TObject);
begin
  inherited;
    AssignUnicodeFont(lblRoster.Font, 9);
    AssignUnicodeFont(lblChat.Font, 9);
    AssignUnicodeFont(lblColor.Font, 9);
    lblRoster.Font.Style := [fsBold];
    lblChat.Font.Style := [fsBold];
    lblColor.Font.Style := [fsBold];

end;

{---------------------------------------}
procedure TfrmPrefFont.cboMsgListChange(Sender: TObject);
var
    idx: integer;
begin
  inherited;
    // When we use IE, disable the color & font stuff
    idx := cboMsgList.ItemIndex;

    // Richedit stuff
    colorChat.Enabled := (idx = 0);
    clrBoxBG.Enabled := (idx = 0);
    clrBoxFont.Enabled := (idx = 0);
    btnFont.Enabled := (idx = 0);

    // IE stuff
    cboIEStylesheet.Enabled := (idx = 1);
    btnCSSBrowse.Enabled := (idx = 1);
    btnCSSEdit.Enabled := (idx = 1);
end;

{---------------------------------------}
procedure TfrmPrefFont.btnCSSBrowseClick(Sender: TObject);
begin
  inherited;
    if (OpenDialog1.Execute) then
        cboIEStylesheet.Text := OpenDialog1.Filename;
end;

{---------------------------------------}
procedure TfrmPrefFont.btnCSSEditClick(Sender: TObject);
begin
  inherited;
    // Edit the CSS
    // XXX: if the stylesheet is empty, dupe the default, and create a new css file
    ShellExecute(Application.Handle, 'edit', PChar(String(cboIEStylesheet.text)), nil, nil,
        SW_SHOWNORMAL);
end;

end.
