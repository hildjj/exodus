object frameXData: TframeXData
  Left = 0
  Top = 0
  Width = 320
  Height = 132
  TabOrder = 0
  TabStop = True
  OnResize = FrameResize
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 132
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object ScrollBox1: TScrollBox
      Left = 5
      Top = 5
      Width = 310
      Height = 122
      VertScrollBar.Tracking = True
      Align = alClient
      BorderStyle = bsNone
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
end
