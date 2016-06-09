inherited frmXLSwork: TfrmXLSwork
  Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072' XLS-'#1092#1072#1081#1083#1086#1074
  ClientHeight = 531
  ClientWidth = 848
  ExplicitWidth = 856
  ExplicitHeight = 565
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    Width = 848
    Height = 531
    ExplicitWidth = 848
    ExplicitHeight = 531
    object btnRefresh: TcxButton [0]
      Left = 3
      Top = 503
      Width = 110
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 3
      OnClick = btnRefreshClick
    end
    object cxGrid1: TcxGrid [1]
      Left = 3
      Top = 18
      Width = 250
      Height = 271
      TabOrder = 0
      object tvFiles: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        Navigator.Buttons.First.Visible = False
        Navigator.Buttons.PriorPage.Visible = False
        Navigator.Buttons.Prior.Visible = False
        Navigator.Buttons.Next.Visible = False
        Navigator.Buttons.NextPage.Visible = False
        Navigator.Buttons.Last.Visible = False
        Navigator.Buttons.Insert.Visible = True
        Navigator.Buttons.Append.Visible = False
        Navigator.Buttons.Delete.Visible = True
        Navigator.Buttons.Edit.Visible = False
        Navigator.Buttons.Post.Visible = True
        Navigator.Buttons.Cancel.Visible = True
        Navigator.Buttons.Refresh.Visible = False
        Navigator.Buttons.SaveBookmark.Visible = False
        Navigator.Buttons.GotoBookmark.Visible = False
        Navigator.Buttons.Filter.Visible = True
        OnFocusedRecordChanged = tvFilesFocusedRecordChanged
        DataController.DataSource = dsFiles
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        Styles.OnGetContentStyle = tvFilesStylesGetContentStyle
        object tvFilesName: TcxGridDBColumn
          Caption = #1048#1084#1103
          DataBinding.FieldName = 'Name'
        end
        object tvFilesFullName: TcxGridDBColumn
          DataBinding.FieldName = 'FullName'
          Visible = False
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = tvFiles
      end
    end
    object cxGrid2: TcxGrid [2]
      Left = 261
      Top = 18
      Width = 300
      Height = 200
      TabOrder = 1
      object tvSheets: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        Navigator.Buttons.First.Visible = False
        Navigator.Buttons.PriorPage.Visible = False
        Navigator.Buttons.Prior.Visible = False
        Navigator.Buttons.Next.Visible = False
        Navigator.Buttons.NextPage.Visible = False
        Navigator.Buttons.Last.Visible = False
        Navigator.Buttons.Insert.Visible = True
        Navigator.Buttons.Append.Visible = False
        Navigator.Buttons.Delete.Visible = True
        Navigator.Buttons.Edit.Visible = False
        Navigator.Buttons.Post.Visible = True
        Navigator.Buttons.Cancel.Visible = True
        Navigator.Buttons.Refresh.Visible = False
        Navigator.Buttons.SaveBookmark.Visible = False
        Navigator.Buttons.GotoBookmark.Visible = False
        Navigator.Buttons.Filter.Visible = True
        OnFocusedRecordChanged = tvSheetsFocusedRecordChanged
        DataController.DataSource = dsSheets
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsSelection.CellSelect = False
        OptionsSelection.HideFocusRectOnExit = False
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        Styles.OnGetContentStyle = tvSheetsStylesGetContentStyle
        object tvSheetsName: TcxGridDBColumn
          Caption = #1048#1084#1103
          DataBinding.FieldName = 'Name'
        end
      end
      object cxGrid2Level1: TcxGridLevel
        GridView = tvSheets
      end
    end
    object vgParams: TcxVerticalGrid [3]
      Left = 536
      Top = 18
      Width = 309
      Height = 200
      OptionsView.RowHeaderWidth = 130
      TabOrder = 2
      Version = 1
    end
    object btnSave: TcxButton [4]
      Left = 735
      Top = 503
      Width = 110
      Height = 25
      Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1074' Excel'
      TabOrder = 5
      OnClick = btnSaveClick
    end
    object btnRun: TcxButton [5]
      Left = 622
      Top = 503
      Width = 110
      Height = 25
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
      TabOrder = 4
      OnClick = btnRunClick
    end
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      Index = -1
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignHorz = ahLeft
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnRefresh
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Group1: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      AlignVert = avClient
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignVert = avClient
      CaptionOptions.Text = #1060#1072#1081#1083#1099
      CaptionOptions.Layout = clTop
      Control = cxGrid1
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1SplitterItem1: TdxLayoutSplitterItem
      Parent = dxLayoutControl1Group1
      AlignVert = avClient
      CaptionOptions.Text = 'Splitter'
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      Index = 1
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = #1051#1080#1089#1090#1099
      CaptionOptions.Layout = clTop
      Control = cxGrid2
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignVert = avClient
      CaptionOptions.Text = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      CaptionOptions.Layout = clTop
      Control = vgParams
      ControlOptions.ShowBorder = False
      Index = 4
    end
    object dxLayoutControl1SplitterItem2: TdxLayoutSplitterItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'Splitter'
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      Index = 3
    end
    object dxLayoutControl1Group2: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item5: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignHorz = ahRight
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnSave
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Item6: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignHorz = ahRight
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnRun
      ControlOptions.ShowBorder = False
      Index = 1
    end
  end
  object mdFiles: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 56
    Top = 128
    object mdFilesName: TStringField
      FieldName = 'Name'
      Size = 2000
    end
    object mdFilesFullName: TStringField
      FieldName = 'FullName'
      Size = 2000
    end
  end
  object dsFiles: TDataSource
    AutoEdit = False
    DataSet = mdFiles
    Left = 80
    Top = 128
  end
  object mdSheets: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 360
    Top = 120
    object mdSheetsName: TStringField
      FieldName = 'Name'
      Size = 2000
    end
  end
  object dsSheets: TDataSource
    AutoEdit = False
    DataSet = mdSheets
    Left = 384
    Top = 120
  end
end
