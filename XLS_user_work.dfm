inherited frmXLSUserWork: TfrmXLSUserWork
  Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' XLS-'#1088#1077#1077#1089#1090#1088#1086#1074
  ExplicitWidth = 753
  ExplicitHeight = 490
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    object cxGrid1: TcxGrid [0]
      Left = 3
      Top = 18
      Width = 414
      Height = 200
      TabOrder = 0
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
        OnSelectionChanged = tvSheetsSelectionChanged
        DataController.DataSource = dsSheets
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsSelection.CellSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.ColumnAutoWidth = True
        OptionsView.GroupByBox = False
        object tvSheetsName: TcxGridDBColumn
          Caption = 'XLS-'#1092#1072#1081#1083
          DataBinding.FieldName = 'Name'
          Width = 250
        end
        object tvSheetsSheet: TcxGridDBColumn
          Caption = 'XLS-'#1083#1080#1089#1090
          DataBinding.FieldName = 'Sheet'
          Width = 162
        end
        object tvSheetsFullName: TcxGridDBColumn
          DataBinding.FieldName = 'FullName'
          Visible = False
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = tvSheets
      end
    end
    object btnRefresh: TcxButton [1]
      Left = 3
      Top = 428
      Width = 110
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 2
      OnClick = btnRefreshClick
    end
    object vgParams: TcxVerticalGrid [2]
      Left = 420
      Top = 18
      Width = 150
      Height = 200
      OptionsView.RowHeaderWidth = 108
      TabOrder = 1
      Version = 1
    end
    object btnExecute: TcxButton [3]
      Left = 632
      Top = 428
      Width = 110
      Height = 25
      Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
      TabOrder = 3
      OnClick = btnExecuteClick
    end
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      Index = -1
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignHorz = ahLeft
      AlignVert = avClient
      CaptionOptions.Text = 'XLS-'#1088#1077#1077#1089#1090#1088#1099
      CaptionOptions.Layout = clTop
      Control = cxGrid1
      ControlOptions.ShowBorder = False
      Index = 0
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
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = #1055#1072#1088#1072#1084#1077#1088#1090#1099' '#1079#1072#1087#1091#1089#1082#1072
      CaptionOptions.Layout = clTop
      Control = vgParams
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Group2: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      ButtonOptions.Buttons = <>
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      AlignHorz = ahRight
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = btnExecute
      ControlOptions.ShowBorder = False
      Index = 1
    end
  end
  object dsSheets: TDataSource
    AutoEdit = False
    DataSet = mdSheets
    Left = 80
    Top = 128
  end
  object mdSheets: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 56
    Top = 128
    object mdSheetsName: TStringField
      FieldName = 'Name'
      Size = 2000
    end
    object mdSheetsFullName: TStringField
      FieldName = 'FullName'
      Size = 2000
    end
    object mdSheetsSheet: TStringField
      FieldName = 'Sheet'
      Size = 2000
    end
  end
end
