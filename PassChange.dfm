inherited frmPassChange: TfrmPassChange
  Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103
  ClientHeight = 145
  ClientWidth = 341
  Position = poDesktopCenter
  ExplicitWidth = 349
  ExplicitHeight = 179
  PixelsPerInch = 96
  TextHeight = 13
  inherited dxLayoutControl1: TdxLayoutControl
    Width = 341
    Height = 145
    ExplicitWidth = 341
    ExplicitHeight = 145
    object teOldPass: TcxTextEdit [0]
      Left = 106
      Top = 21
      Properties.EchoMode = eemPassword
      Properties.OnChange = teNewPassPropertiesChange
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object teNewPass: TcxTextEdit [1]
      Left = 106
      Top = 45
      Properties.EchoMode = eemPassword
      Properties.OnChange = teNewPassPropertiesChange
      Style.HotTrack = False
      TabOrder = 1
      Width = 121
    end
    object teChkPass: TcxTextEdit [2]
      Left = 106
      Top = 69
      Properties.EchoMode = eemPassword
      Properties.OnChange = teNewPassPropertiesChange
      Style.HotTrack = False
      TabOrder = 2
      Width = 121
    end
    object btnOK: TcxButton [3]
      Left = 3
      Top = 105
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      Enabled = False
      ModalResult = 1
      TabOrder = 3
    end
    object btnCancel: TcxButton [4]
      Left = 81
      Top = 105
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 4
    end
    inherited dxLayoutControl1Group_Root: TdxLayoutGroup
      Index = -1
    end
    object dxLayoutControl1Item1: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = #1057#1090#1072#1088#1099#1081' '#1087#1072#1088#1086#1083#1100
      Control = teOldPass
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutControl1Item2: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = #1053#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100
      Control = teNewPass
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutControl1Item3: TdxLayoutItem
      Parent = dxLayoutControl1Group1
      CaptionOptions.Text = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077'  '
      Control = teChkPass
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutControl1Group1: TdxLayoutGroup
      Parent = dxLayoutControl1Group_Root
      CaptionOptions.Text = 'New Group'
      CaptionOptions.Visible = False
      ButtonOptions.Buttons = <>
      Index = 0
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
      CaptionOptions.Visible = False
      Control = btnOK
      ControlOptions.ShowBorder = False
      Enabled = False
      Index = 0
    end
    object dxLayoutControl1Item5: TdxLayoutItem
      Parent = dxLayoutControl1Group2
      CaptionOptions.Visible = False
      Control = btnCancel
      ControlOptions.ShowBorder = False
      Index = 1
    end
  end
end
