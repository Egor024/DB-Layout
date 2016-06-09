inherited frmImageSelector: TfrmImageSelector
  Caption = 'frmImageSelector'
  ClientHeight = 437
  ClientWidth = 589
  ExplicitWidth = 597
  ExplicitHeight = 471
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    Width = 589
    Height = 437
    ExplicitWidth = 589
    ExplicitHeight = 437
    object lvImages: TListView [0]
      Left = 4
      Top = 4
      Width = 250
      Height = 357
      BorderStyle = bsNone
      Columns = <>
      IconOptions.AutoArrange = True
      ReadOnly = True
      TabOrder = 0
      OnDblClick = lvImagesDblClick
    end
    object cxButton1: TcxButton [1]
      Left = 3
      Top = 409
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object cxButton2: TcxButton [2]
      Left = 84
      Top = 409
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object cxButton3: TcxButton [3]
      Left = 165
      Top = 409
      Width = 75
      Height = 25
      Caption = 'Clear'
      ModalResult = 5
      TabOrder = 3
    end
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      Index = -1
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group_Root
      AlignVert = avClient
      CaptionOptions.Text = 'ListView1'
      CaptionOptions.Visible = False
      Control = lvImages
      Index = 0
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      AlignHorz = ahLeft
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = cxButton1
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
      Control = cxButton2
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item4: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = 'cxButton3'
      CaptionOptions.Visible = False
      Control = cxButton3
      ControlOptions.ShowBorder = False
      Index = 2
    end
  end
end
