inherited ORAMainMenuCustomizationForm: TORAMainMenuCustomizationForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1075#1083#1072#1074#1085#1086#1075#1086' '#1084#1077#1085#1102
  ClientHeight = 383
  ClientWidth = 621
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  ExplicitWidth = 629
  ExplicitHeight = 417
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox2: TListBox [0]
    Left = 8
    Top = 111
    Width = 121
    Height = 97
    ItemHeight = 13
    TabOrder = 4
  end
  object dxLayoutControl1: TdxLayoutControl [1]
    Left = 0
    Top = 0
    Width = 621
    Height = 383
    Align = alClient
    TabOrder = 5
    LayoutLookAndFeel = frmMain.layoutLookAndFeel
    object btnSave: TcxButton
      Left = 3
      Top = 355
      Width = 95
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 4
      OnClick = btnSaveClick
    end
    object lbItems: TListBox
      Left = 4
      Top = 35
      Width = 194
      Height = 196
      Style = lbOwnerDrawFixed
      BorderStyle = bsNone
      ItemHeight = 13
      Sorted = True
      TabOrder = 2
      OnDrawItem = lbItemsDrawItem
    end
    object btnLoad: TcxButton
      Left = 104
      Top = 355
      Width = 95
      Height = 25
      Caption = #1042#1086#1089#1089#1090#1072#1085#1086#1074#1080#1090#1100
      TabOrder = 5
      OnClick = btnLoadClick
    end
    object btnAddButton: TcxButton
      Left = 3
      Top = 3
      Width = 75
      Height = 25
      Caption = #1050#1085#1086#1087#1082#1072
      OptionsImage.ImageIndex = 44
      OptionsImage.Images = frmMain.cxImageList
      TabOrder = 0
      OnClick = btnAddButtonClick
    end
    object btnAddSubMenu: TcxButton
      Left = 84
      Top = 3
      Width = 75
      Height = 25
      Caption = #1052#1077#1085#1102
      OptionsImage.ImageIndex = 44
      OptionsImage.Images = frmMain.cxImageList
      TabOrder = 1
      OnClick = btnAddSubMenuClick
    end
    object rtInspector: TcxRTTIInspector
      Left = 213
      Top = 34
      Width = 150
      Height = 200
      TabOrder = 3
      Version = 1
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      ButtonOptions.Buttons = <>
      Hidden = True
      ShowBorder = False
      Index = -1
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Visible = False
      Control = btnSave
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group1: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group3
      AlignVert = avClient
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = lbItems
      Index = 0
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnLoad
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignVert = avClient
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnAddButton
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group2: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item5: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      CaptionOptions.Text = 'cxButton2'
      CaptionOptions.Visible = False
      Control = btnAddSubMenu
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Group3: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item6: TdxLayoutItem
      Parent = dxLayoutControl1Group3
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'cxRTTIInspector1'
      CaptionOptions.Visible = False
      Control = rtInspector
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1SplitterItem1: TdxLayoutSplitterItem
      Parent = dxLayoutControl1Group3
      AlignVert = avClient
      CaptionOptions.Text = 'Splitter'
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      Index = 1
    end
  end
  object ListBox1: TListBox [2]
    Left = 8
    Top = 282
    Width = 73
    Height = 43
    BorderStyle = bsNone
    ItemHeight = 13
    TabOrder = 6
    Visible = False
  end
  inherited BarManager1: TdxBarManager
    DockControlHeights = (
      0
      0
      0
      0)
  end
end
