inherited frmORALayoutGridEditor: TfrmORALayoutGridEditor
  Left = 556
  Top = 316
  Caption = 'frmORALayoutGridEditor'
  ClientHeight = 348
  ClientWidth = 348
  ParentFont = True
  Visible = True
  ExplicitWidth = 356
  ExplicitHeight = 382
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    Width = 348
    Height = 348
    ExplicitWidth = 348
    ExplicitHeight = 348
    object LBColumns: TListBox [0]
      Left = 4
      Top = 4
      Width = 194
      Height = 277
      BorderStyle = bsNone
      ItemHeight = 13
      MultiSelect = True
      PopupMenu = PMColumns
      TabOrder = 0
      OnClick = LBColumnsClick
      OnDrawItem = LBColumnsDrawItem
    end
    object BColumnAdd: TcxButton [1]
      Left = 224
      Top = 3
      Width = 120
      Height = 24
      Caption = '&Add'
      TabOrder = 1
      OnClick = BColumnAddClick
    end
    object BColumnDelete: TcxButton [2]
      Left = 224
      Top = 30
      Width = 120
      Height = 24
      Caption = 'Delete'
      TabOrder = 2
      OnClick = BColumnDeleteClick
    end
    object BColumnMoveUp: TcxButton [3]
      Left = 224
      Top = 57
      Width = 120
      Height = 24
      Caption = 'Move &Up'
      TabOrder = 3
      OnClick = BColumnMoveUpClick
    end
    object BColumnMoveDown: TcxButton [4]
      Left = 224
      Top = 84
      Width = 120
      Height = 24
      Caption = 'Move &Down'
      TabOrder = 4
      OnClick = BColumnMoveDownClick
    end
    object BColumnAddAll: TcxButton [5]
      Left = 224
      Top = 111
      Width = 120
      Height = 24
      Caption = 'Retrieve &Fields'
      TabOrder = 5
      OnClick = BColumnAddAllClick
    end
    object BColumnAddMissing: TcxButton [6]
      Left = 224
      Top = 138
      Width = 120
      Height = 24
      Caption = 'Retrieve &Missing Fields'
      TabOrder = 6
      OnClick = BColumnAddMissingClick
    end
    object btnNumberFmt: TcxButton [7]
      Left = 224
      Top = 320
      Width = 75
      Height = 25
      Caption = 'Number Format'
      TabOrder = 11
      OnClick = btnNumberFmtClick
    end
    object btnAutoWidth: TcxButton [8]
      Left = 224
      Top = 229
      Width = 75
      Height = 25
      Caption = 'All auto width'
      TabOrder = 8
      OnClick = btnAutoWidthClick
    end
    object teFormat: TcxTextEdit [9]
      Left = 224
      Top = 272
      Style.HotTrack = False
      TabOrder = 9
      Text = ',0.00'
      Width = 121
    end
    object chkSummary: TcxCheckBox [10]
      Left = 224
      Top = 296
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1080#1090#1086#1075#1080
      Style.HotTrack = False
      TabOrder = 10
      Width = 121
    end
    object btnLayoutCustomization: TcxButton [11]
      Left = 224
      Top = 165
      Width = 75
      Height = 25
      Caption = 'Layout'
      TabOrder = 7
      OnClick = btnLayoutCustomizationClick
    end
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      LayoutDirection = ldHorizontal
      Index = -1
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = LBColumns
      Index = 0
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = BColumnAdd
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group1: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = BColumnDelete
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = BColumnMoveUp
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Item5: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = BColumnMoveDown
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object dxLayoutControl1Item6: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = BColumnAddAll
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object dxLayoutControl1Item7: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = BColumnAddMissing
      ControlOptions.ShowBorder = False
      Index = 5
    end
    object dxLayoutControl1Group2: TdxLayoutGroup
      Parent = dxLayoutControl1Group1
      AlignVert = avBottom
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      ShowBorder = False
      Index = 7
    end
    object dxLayoutControl1Item9: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnNumberFmt
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object dxLayoutControl1Item8: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      CaptionOptions.Visible = False
      Control = btnAutoWidth
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item10: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      CaptionOptions.Text = #1060#1086#1088#1084#1072#1090
      CaptionOptions.Layout = clTop
      Control = teFormat
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item11: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      CaptionOptions.Visible = False
      Control = chkSummary
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Item12: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnLayoutCustomization
      ControlOptions.ShowBorder = False
      Index = 6
    end
  end
  object PMColumns: TPopupMenu
    Left = 28
    Top = 6
    object MIColumnAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BColumnAddClick
    end
    object MIColumnDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BColumnDeleteClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MIColumnMoveUp: TMenuItem
      Caption = 'Move Up'
      ShortCut = 16422
      OnClick = BColumnMoveUpClick
    end
    object MIColumnMoveDown: TMenuItem
      Caption = 'Move Down'
      ShortCut = 16424
      OnClick = BColumnMoveDownClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MIColumnSelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MIColumnSelectAllClick
    end
  end
end
