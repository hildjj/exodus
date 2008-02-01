object frmActivityWindow: TfrmActivityWindow
  Left = 0
  Top = 0
  Caption = 'frmActivityWindow'
  ClientHeight = 394
  ClientWidth = 187
  Color = 13681583
  DockSite = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlListBase: TExGradientPanel
    Left = 0
    Top = 10
    Width = 187
    Height = 374
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    GradientProperites.startColor = 13681583
    GradientProperites.endColor = 13681583
    GradientProperites.orientation = gdHorizontal
    object pnlListScrollUp: TExGradientPanel
      Left = 0
      Top = 30
      Width = 187
      Height = 22
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      Visible = False
      OnClick = pnlListScrollUpClick
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      object imgScrollUp: TImage
        Left = 73
        Top = 2
        Width = 16
        Height = 16
        Align = alCustom
        Anchors = [akTop]
        Transparent = True
        OnClick = pnlListScrollUpClick
        ExplicitLeft = 75
      end
      object ScrollUpBevel: TColorBevel
        Left = 0
        Top = 17
        Width = 187
        Height = 5
        Align = alBottom
        Shape = bsBottomLine
        HighLight = clBtnHighlight
        Shadow = clBtnShadow
        FrameColor = frUser
        ExplicitTop = -28
      end
    end
    object pnlListScrollDown: TExGradientPanel
      Left = 0
      Top = 352
      Width = 187
      Height = 22
      Align = alBottom
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      Visible = False
      OnClick = pnlListScrollDownClick
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      object imgScrollDown: TImage
        Left = 73
        Top = 4
        Width = 16
        Height = 16
        Align = alCustom
        Anchors = [akBottom]
        Transparent = True
        OnClick = pnlListScrollDownClick
        ExplicitLeft = 75
        ExplicitTop = 2
      end
      object ScrollDownBevel: TColorBevel
        Left = 0
        Top = 0
        Width = 187
        Height = 5
        Align = alTop
        Shape = bsTopLine
        HighLight = clBtnHighlight
        Shadow = clBtnShadow
        FrameColor = frUser
      end
    end
    object pnlList: TExGradientPanel
      Left = 0
      Top = 52
      Width = 187
      Height = 300
      Align = alClient
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 2
      TabStop = True
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      ExplicitTop = 54
      object ListLeftSpacer: TBevel
        Left = 0
        Top = 0
        Width = 10
        Height = 300
        Align = alLeft
        Shape = bsSpacer
        ExplicitHeight = 305
      end
      object ListRightSpacer: TBevel
        Left = 187
        Top = 0
        Width = 0
        Height = 300
        Align = alRight
        Shape = bsSpacer
        ExplicitLeft = 184
        ExplicitHeight = 327
      end
    end
    object pnlListSort: TExGradientPanel
      Left = 0
      Top = 0
      Width = 187
      Height = 30
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      OnClick = pnlListSortClick
      GradientProperites.startColor = 13746091
      GradientProperites.endColor = 12429970
      GradientProperites.orientation = gdHorizontal
      object lblSort: TTntLabel
        Left = 26
        Top = 5
        Width = 140
        Height = 20
        Align = alClient
        Alignment = taRightJustify
        Caption = 'Sort By:  Alpha'
        Transparent = True
        OnClick = pnlListSortClick
        ExplicitLeft = 94
        ExplicitWidth = 72
        ExplicitHeight = 13
      end
      object SortTopSpacer: TBevel
        Left = 0
        Top = 0
        Width = 187
        Height = 5
        Align = alTop
        Shape = bsSpacer
        ExplicitLeft = 1
        ExplicitTop = 30
        ExplicitWidth = 183
      end
      object imgSortArrow: TImage
        Left = 166
        Top = 5
        Width = 16
        Height = 20
        Align = alRight
        Transparent = True
        OnClick = pnlListSortClick
        ExplicitLeft = 75
        ExplicitTop = 2
        ExplicitHeight = 16
      end
      object imgShowRoster: TImage
        Left = 10
        Top = 5
        Width = 16
        Height = 20
        Hint = 'Back to Roster'
        Align = alLeft
        ParentShowHint = False
        ShowHint = True
        Transparent = True
        OnClick = imgShowRosterClick
        ExplicitLeft = 149
        ExplicitTop = 4
      end
      object SortLeftSpacer: TBevel
        Left = 0
        Top = 5
        Width = 10
        Height = 20
        Align = alLeft
        Shape = bsSpacer
      end
      object SortRightSpacer: TBevel
        Left = 182
        Top = 5
        Width = 5
        Height = 20
        Align = alRight
        Shape = bsSpacer
        ExplicitLeft = 177
      end
      object SortBevel: TColorBevel
        Left = 0
        Top = 25
        Width = 187
        Height = 5
        Align = alBottom
        Shape = bsBottomLine
        HighLight = clBtnHighlight
        Shadow = clBtnShadow
        FrameColor = frUser
        ExplicitLeft = 104
        ExplicitTop = 32
        ExplicitWidth = 50
      end
    end
  end
  object pnlBorderTop: TExGradientPanel
    Left = 0
    Top = 0
    Width = 187
    Height = 10
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlBorderTop'
    Color = 13681583
    TabOrder = 1
    GradientProperites.startColor = 13681583
    GradientProperites.endColor = 13681583
    GradientProperites.orientation = gdVertical
  end
  object pnlBorderBottom: TExGradientPanel
    Left = 0
    Top = 384
    Width = 187
    Height = 10
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'ExGradientPanel1'
    Color = 13681583
    TabOrder = 2
    GradientProperites.startColor = 13681583
    GradientProperites.endColor = 13681583
    GradientProperites.orientation = gdVertical
  end
  object popAWSort: TTntPopupMenu
    Left = 104
    Top = 144
    object mnuRecentSort: TTntMenuItem
      Caption = 'Activity'
      OnClick = mnuRecentSortClick
    end
    object mnuAlphaSort: TTntMenuItem
      Caption = 'Alphabetical'
      OnClick = mnuAlphaSortClick
    end
    object mnuTypeSort: TTntMenuItem
      Caption = 'Type'
      OnClick = mnuTypeSortClick
    end
    object mnuUnreadSort: TTntMenuItem
      Caption = 'Unread'
      OnClick = mnuUnreadSortClick
    end
  end
  object timShowActiveDocked: TTimer
    Interval = 100
    OnTimer = timShowActiveDockedTimer
    Left = 72
    Top = 144
  end
end