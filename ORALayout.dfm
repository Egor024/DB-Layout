inherited frmORALayout: TfrmORALayout
  OnCloseQuery = FormCloseQuery
  OnDeactivate = FormDeactivate
  ExplicitWidth = 753
  ExplicitHeight = 490
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    OptionsItem.AutoControlTabOrders = False
    OnCustomization = dxLayoutControl1Customization
    OnGetItemStoredProperties = dxLayoutControl1GetItemStoredProperties
    OnGetItemStoredPropertyValue = dxLayoutControl1GetItemStoredPropertyValue
    OnSetItemStoredPropertyValue = dxLayoutControl1SetItemStoredPropertyValue
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      Index = -1
    end
  end
  object pnlNotes: TPanel
    Left = 160
    Top = 40
    Width = 433
    Height = 257
    BorderWidth = 2
    Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1103
    DockSite = True
    DragKind = dkDock
    DragMode = dmAutomatic
    TabOrder = 5
    Visible = False
    DesignSize = (
      433
      257)
    object memNotes: TcxMemo
      Left = 3
      Top = 3
      Align = alClient
      Style.Color = clCream
      TabOrder = 0
      Height = 251
      Width = 427
    end
    object btnNotesSave: TcxButton
      Left = 360
      Top = 232
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 1
      OnClick = btnNotesSaveClick
    end
    object btnCaptions: TcxButton
      Left = 285
      Top = 232
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1047#1072#1075#1086#1083#1086#1074#1082#1080
      TabOrder = 2
      OnClick = btnCaptionsClick
    end
  end
  object dxBarManager1: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 16
    Top = 40
    DockControlHeights = (
      0
      0
      0
      0)
    object barXMLMenu: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 771
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem1'
        end
        item
          BeginGroup = True
          ViewLayout = ivlGlyphControlCaption
          Visible = True
          ItemName = 'cbEditMode'
        end
        item
          BeginGroup = True
          UserDefine = [udWidth]
          UserWidth = 161
          Visible = True
          ItemName = 'teName'
        end
        item
          Visible = True
          ItemName = 'teCode'
        end>
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = False
      WholeRow = False
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = #1060#1072#1081#1083
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'btnNew'
        end
        item
          Visible = True
          ItemName = 'btnSave'
        end
        item
          Visible = True
          ItemName = 'btnNotes'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'btnOpen'
        end
        item
          Visible = True
          ItemName = 'btnSaveAs'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'btnClose'
        end>
    end
    object btnOpen: TdxBarButton
      Caption = #1048#1084#1087#1086#1088#1090' '#1080#1079' '#1092#1072#1081#1083#1072' ...'
      Category = 0
      Hint = #1048#1084#1087#1086#1088#1090' '#1080#1079' '#1092#1072#1081#1083#1072' '
      Visible = ivAlways
      OnClick = btnOpenClick
    end
    object btnSave: TdxBarButton
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      Category = 0
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      Visible = ivAlways
      OnClick = btnSaveClick
    end
    object btnNew: TdxBarButton
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      Category = 0
      Hint = #1054#1095#1080#1089#1090#1080#1090#1100
      Visible = ivAlways
      OnClick = btnNewClick
    end
    object btnClose: TdxBarButton
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Category = 0
      Hint = #1047#1072#1082#1088#1099#1090#1100
      Visible = ivAlways
      OnClick = btnCloseClick
    end
    object cbEditMode: TcxBarEditItem
      Caption = #1056#1077#1078#1080#1084' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
      Category = 0
      Hint = #1056#1077#1078#1080#1084' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
      Visible = ivAlways
      ShowCaption = True
      Width = 0
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = cbEditModePropertiesEditValueChanged
      InternalEditValue = False
    end
    object btnSaveAs: TdxBarButton
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' '#1092#1072#1081#1083' ...'
      Category = 0
      Hint = #1069#1082#1089#1087#1086#1088#1090' '#1074' '#1092#1072#1081#1083' '
      Visible = ivAlways
      OnClick = btnSaveAsClick
    end
    object teName: TcxBarEditItem
      Caption = #1048#1084#1103
      Category = 0
      Hint = #1048#1084#1103
      Visible = ivAlways
      ShowCaption = True
      PropertiesClassName = 'TcxTextEditProperties'
      Properties.OnChange = teNamePropertiesChange
    end
    object teCode: TcxBarEditItem
      Caption = #1042#1077#1088#1089#1080#1103
      Category = 0
      Hint = #1042#1077#1088#1089#1080#1103
      Visible = ivAlways
      ShowCaption = True
      PropertiesClassName = 'TcxTextEditProperties'
      Properties.OnChange = teCodePropertiesChange
    end
    object btnNotes: TdxBarButton
      Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1103
      Category = 0
      Hint = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1103
      Visible = ivAlways
      ShortCut = 112
      OnClick = btnNotesClick
    end
    object bgCustomize: TdxBarGroup
      Items = ()
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 'FRM-'#1092#1072#1081#1083#1099'|*.frm|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*'
    Left = 8
    Top = 208
  end
  object OpenDialog1: TOpenDialog
    Ctl3D = False
    Filter = 'FRM-'#1092#1072#1081#1083#1099'|*.frm|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 176
  end
  object JvCaptionButtonHelp: TJvCaptionButton
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Standard = tsbHelp
    OnClick = btnNotesClick
    Left = 320
    Top = 328
  end
  object JvCaptionButtonClone: TJvCaptionButton
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Position = 1
    OnClick = JvCaptionButtonCloneClick
    Left = 280
    Top = 328
  end
end
