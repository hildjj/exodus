inherited frmPrefPlugins: TfrmPrefPlugins
  Left = 232
  Top = 142
  BorderStyle = bsDialog
  Caption = 'Plugins'
  ClientHeight = 444
  ClientWidth = 517
  ParentFont = True
  OldCreateOrder = True
  OnCreate = TntFormCreate
  ExplicitWidth = 523
  ExplicitHeight = 482
  PixelsPerInch = 120
  TextHeight = 16
  object Label6: TTntLabel
    Left = 3
    Top = 316
    Width = 239
    Height = 16
    Caption = 'Plug-in Directory (automatically scanned):'
  end
  object lblPluginScan: TTntLabel
    Left = 3
    Top = 379
    Width = 193
    Height = 16
    Cursor = crHandPoint
    Caption = 'Re-scan this directory for plug-ins'
    OnClick = lblPluginScanClick
  end
  object btnConfigPlugin: TTntButton
    Left = 4
    Top = 275
    Width = 104
    Height = 30
    Caption = 'Configure...'
    Enabled = False
    TabOrder = 1
    OnClick = btnConfigPluginClick
  end
  object txtPluginDir: TTntEdit
    Left = 3
    Top = 341
    Width = 395
    Height = 24
    TabOrder = 2
  end
  object btnBrowsePluginPath: TTntButton
    Left = 409
    Top = 342
    Width = 104
    Height = 29
    Caption = 'Browse...'
    TabOrder = 3
    OnClick = btnBrowsePluginPathClick
  end
  object lstPlugins: TTntListView
    AlignWithMargins = True
    Left = 3
    Top = 9
    Width = 511
    Height = 253
    Margins.Top = 9
    Align = alTop
    BevelWidth = 0
    Checkboxes = True
    Columns = <
      item
        Caption = 'Plugin'
        Width = 146
      end
      item
        Caption = 'Description'
        Width = 221
      end
      item
        Caption = 'Filename'
        Width = 117
      end>
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = lstPluginsSelectItem
  end
  object btnCancel: TTntButton
    Left = 409
    Top = 405
    Width = 104
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object btnOK: TTntButton
    Left = 297
    Top = 405
    Width = 103
    Height = 31
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
    OnClick = btnOKClick
  end
end