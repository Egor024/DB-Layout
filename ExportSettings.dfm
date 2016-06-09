object frmExportSettings: TfrmExportSettings
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1069#1082#1089#1087#1086#1088#1090
  ClientHeight = 304
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 450
    Height = 304
    Align = alClient
    TabOrder = 0
    LayoutLookAndFeel = frmMain.layoutLookAndFeel
    object btnOK: TcxButton
      Left = 294
      Top = 260
      Width = 75
      Height = 25
      Caption = #1069#1082#1089#1087#1086#1088#1090
      Colors.Normal = clSkyBlue
      Default = True
      ModalResult = 1
      TabOrder = 12
      OnClick = btnOKClick
    end
    object btnCancel: TcxButton
      Left = 372
      Top = 260
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 13
      OnClick = btnCancelClick
    end
    object rgSaveAll: TcxRadioGroup
      Left = 15
      Top = 69
      BiDiMode = bdRightToLeft
      Caption = #1069#1082#1089#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100
      Ctl3D = True
      ParentBiDiMode = False
      ParentCtl3D = False
      Properties.Items = <
        item
          Caption = #1042#1089#1077' '#1079#1072#1087#1080#1089#1080
        end
        item
          Caption = #1058#1086#1083#1100#1082#1086' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1079#1072#1087#1080#1089#1080
        end>
      Properties.ReadOnly = False
      ItemIndex = 0
      TabOrder = 5
      Height = 55
      Width = 247
    end
    object rgUseNative: TcxRadioGroup
      Left = 265
      Top = 69
      BiDiMode = bdRightToLeft
      Caption = #1060#1086#1088#1084#1072#1090#1080#1088#1086#1074#1072#1085#1080#1077
      Ctl3D = True
      ParentBiDiMode = False
      ParentCtl3D = False
      Properties.Items = <
        item
          Caption = #1060#1086#1088#1084#1072#1090' Excel'
        end
        item
          Caption = #1060#1086#1088#1084#1072#1090' '#1058#1072#1073#1083#1080#1094#1099
        end>
      Properties.ReadOnly = False
      ItemIndex = 0
      TabOrder = 6
      Height = 55
      Width = 170
    end
    object edFileName: TcxTextEdit
      Left = 98
      Top = 21
      Style.HotTrack = False
      TabOrder = 1
      Width = 315
    end
    object btnFileName: TcxButton
      Left = 416
      Top = 21
      Width = 19
      Height = 21
      Caption = '...'
      TabOrder = 2
      OnClick = btnFileNameClick
    end
    object chbExpand: TcxCheckBox
      Left = 15
      Top = 127
      Caption = #1069#1082#1089#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1082#1088#1099#1090#1099#1077' '#1079#1072#1087#1080#1089#1080
      State = cbsChecked
      Style.HotTrack = False
      TabOrder = 7
      Width = 420
    end
    object rgFileFormat: TcxRadioGroup
      Left = 15
      Top = 151
      Caption = #1060#1086#1088#1084#1072#1090' '#1092#1072#1081#1083#1072
      Properties.Columns = 3
      Properties.Items = <
        item
          Caption = 'XLS'
        end
        item
          Caption = 'XLSX'
        end
        item
          Caption = 'CSV'
        end>
      Properties.OnEditValueChanged = rgFileFormatPropertiesEditValueChanged
      ItemIndex = 1
      TabOrder = 8
      Height = 38
      Width = 420
    end
    object rgViewFormat: TcxRadioGroup
      Left = 15
      Top = 192
      Caption = #1042#1085#1077#1096#1085#1080#1081' '#1074#1080#1076
      Properties.Columns = 3
      Properties.Items = <
        item
          Caption = #1058#1077#1082#1091#1097#1080#1081
        end
        item
          Caption = #1057#1086#1093#1088#1072#1085#1077#1085#1085#1099#1081
        end>
      Properties.OnEditValueChanged = rgViewFormatPropertiesEditValueChanged
      ItemIndex = 0
      TabOrder = 9
      Height = 38
      Width = 420
    end
    object rgNewExist: TcxRadioGroup
      Left = 15
      Top = 21
      Properties.Items = <
        item
          Caption = #1053#1086#1074#1099#1081
        end
        item
          Caption = #1057#1090#1072#1088#1099#1081
        end>
      Properties.OnEditValueChanged = rgNewExistPropertiesEditValueChanged
      ItemIndex = 0
      TabOrder = 0
      Height = 40
      Width = 80
    end
    object btnSaveSettings: TcxButton
      Left = 15
      Top = 263
      Width = 80
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 10
      OnClick = btnSaveSettingsClick
    end
    object edWorksheet: TcxComboBox
      Left = 124
      Top = 45
      Properties.OnInitPopup = cbWorksheetPropertiesInitPopup
      Style.HotTrack = False
      TabOrder = 3
      Width = 121
    end
    object edCell: TcxTextEdit
      Left = 395
      Top = 45
      Style.HotTrack = False
      TabOrder = 4
      Text = 'A1'
      Width = 40
    end
    object btnDelSettings: TcxButton
      Left = 98
      Top = 263
      Width = 80
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Enabled = False
      TabOrder = 11
      OnClick = btnDelSettingsClick
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object grExcel: TdxLayoutGroup
      Parent = grMain
      CaptionOptions.Text = 'Excel'
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Index = 0
    end
    object dxLayoutControl1Group3: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group3
      AlignHorz = ahRight
      AlignVert = avCenter
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnOK
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group3
      AlignHorz = ahRight
      AlignVert = avCenter
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnCancel
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Group4: TdxLayoutGroup
      Parent = grExcel
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group6
      AlignHorz = ahClient
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = rgSaveAll
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group6: TdxLayoutGroup
      Parent = dxLayoutControl1Group4
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item7: TdxLayoutItem
      Parent = dxLayoutControl1Group6
      AlignHorz = ahClient
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = rgUseNative
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item8: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignHorz = ahClient
      AlignVert = avCenter
      Control = edFileName
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group5: TdxLayoutGroup
      Parent = dxLayoutControl1Group4
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item5: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignHorz = ahRight
      AlignVert = avCenter
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = btnFileName
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item6: TdxLayoutItem
      Parent = grExcel
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = chbExpand
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object grMain: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item12: TdxLayoutItem
      Parent = grExcel
      CaptionOptions.Text = 'cxRadioGroup1'
      CaptionOptions.Visible = False
      Control = rgFileFormat
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = grExcel
      AlignHorz = ahClient
      CaptionOptions.Text = 'cxRadioGroup1'
      CaptionOptions.Visible = False
      Control = rgViewFormat
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object dxLayoutControl1Item9: TdxLayoutItem
      Parent = dxLayoutControl1Group5
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'cxRadioGroup1'
      CaptionOptions.Visible = False
      Control = rgNewExist
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item10: TdxLayoutItem
      Parent = dxLayoutControl1Group8
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnSaveSettings
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group1: TdxLayoutGroup
      Parent = dxLayoutControl1Group5
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Group2: TdxLayoutGroup
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item11: TdxLayoutItem
      Parent = dxLayoutControl1Group7
      AlignHorz = ahClient
      CaptionOptions.Text = #1051#1080#1089#1090
      Control = edWorksheet
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item13: TdxLayoutItem
      Parent = dxLayoutControl1Group7
      CaptionOptions.Text = #1071#1095#1077#1081#1082#1072
      Control = edCell
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Group7: TdxLayoutGroup
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item14: TdxLayoutItem
      Parent = dxLayoutControl1Group8
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnDelSettings
      ControlOptions.ShowBorder = False
      Enabled = False
      Index = 1
    end
    object dxLayoutControl1Group8: TdxLayoutGroup
      Parent = dxLayoutControl1Group3
      CaptionOptions.Text = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1085#1072#1089#1090#1088#1086#1077#1082
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      Index = 0
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'xls'
    Left = 144
    Top = 72
  end
end
