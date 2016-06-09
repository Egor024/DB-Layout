object frmORAStyles: TfrmORAStyles
  Left = 0
  Top = 0
  Caption = #1056#1077#1087#1086#1079#1080#1090#1086#1088#1080#1081' '#1089#1090#1080#1083#1077#1081
  ClientHeight = 393
  ClientWidth = 562
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 562
    Height = 393
    Align = alClient
    TabOrder = 0
    LayoutLookAndFeel = frmMain.layoutLookAndFeel
    object styleEditor: TcxRTTIInspector
      Left = 189
      Top = 18
      Width = 150
      Height = 200
      TabOrder = 3
      OnPropertyChanged = styleEditorPropertyChanged
      Version = 1
    end
    object btnAddNewStyle: TcxButton
      Left = 3
      Top = 334
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = btnAddNewStyleClick
    end
    object lbStyles: TcxListBox
      Left = 3
      Top = 18
      Width = 180
      Height = 97
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbStylesClick
    end
    object btnSave: TcxButton
      Left = 3
      Top = 365
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      ButtonOptions.Buttons = <>
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = -1
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1090#1080#1083#1103
      CaptionOptions.Layout = clTop
      Control = styleEditor
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Visible = False
      Control = btnAddNewStyle
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Group1: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignVert = avClient
      CaptionOptions.Text = #1057#1087#1080#1089#1086#1082' '#1089#1090#1080#1083#1077#1081
      CaptionOptions.Layout = clTop
      Control = lbStyles
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Visible = False
      Control = btnSave
      ControlOptions.ShowBorder = False
      Index = 2
    end
  end
end
