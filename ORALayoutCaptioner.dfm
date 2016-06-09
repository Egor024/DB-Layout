inherited frmCaptioner: TfrmCaptioner
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1079#1072#1075#1086#1083#1086#1074#1082#1086#1074
  ClientHeight = 591
  ClientWidth = 382
  ExplicitWidth = 390
  ExplicitHeight = 625
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    Width = 382
    Height = 591
    ExplicitWidth = 382
    ExplicitHeight = 591
    object tlControls: TcxDBTreeList [0]
      Left = 3
      Top = 3
      Width = 250
      Height = 150
      Bands = <
        item
        end>
      DataController.DataSource = dsControls
      DataController.ParentField = 'ParentName'
      DataController.KeyField = 'ControlName'
      Navigator.Buttons.CustomButtons = <>
      OptionsView.ColumnAutoWidth = True
      OptionsView.Headers = False
      RootValue = -1
      Styles.OnGetContentStyle = tlControlsStylesGetContentStyle
      TabOrder = 0
      object tlControlsCaption: TcxDBTreeListColumn
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.OnEditValueChanged = tlControlsCaptionPropertiesEditValueChanged
        DataBinding.FieldName = 'Caption'
        Width = 222
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object tlControlsChanged: TcxDBTreeListColumn
        Visible = False
        DataBinding.FieldName = 'Changed'
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
    object btnSave: TcxButton [1]
      Left = 3
      Top = 563
      Width = 120
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object btnLoad: TcxButton [2]
      Left = 126
      Top = 563
      Width = 120
      Height = 25
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1080#1079' '#1092#1072#1081#1083#1072
      TabOrder = 2
      OnClick = btnLoadClick
    end
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      Index = -1
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group_Root
      AlignVert = avClient
      CaptionOptions.Text = 'cxDBTreeList1'
      CaptionOptions.Visible = False
      Control = tlControls
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'cxButton1'
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
      Index = 1
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'cxButton2'
      CaptionOptions.Visible = False
      Control = btnLoad
      ControlOptions.ShowBorder = False
      Index = 1
    end
  end
  object mdControls: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 96
    Top = 184
    object mdControlsPointer: TIntegerField
      FieldName = 'Pointer'
    end
    object mdControlsControlName: TStringField
      FieldName = 'ControlName'
      Size = 100
    end
    object mdControlsParentName: TStringField
      FieldName = 'ParentName'
      Size = 100
    end
    object mdControlsCaption: TStringField
      FieldName = 'Caption'
      Size = 500
    end
    object mdControlsChanged: TBooleanField
      FieldName = 'Changed'
    end
  end
  object dsControls: TDataSource
    DataSet = mdControls
    Left = 120
    Top = 184
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Caption-'#1092#1072#1081#1083#1099'|*.Captions|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*'
    Left = 8
    Top = 208
  end
  object OpenDialog1: TOpenDialog
    Ctl3D = False
    Filter = 'Caption-'#1092#1072#1081#1083#1099'|*.Captions|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 176
  end
  object cxStyleRepository1: TcxStyleRepository
    PixelsPerInch = 96
    object stChanged: TcxStyle
      AssignedValues = [svColor]
      Color = 14086102
    end
  end
end
