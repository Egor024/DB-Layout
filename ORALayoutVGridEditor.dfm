object frmORAVerticalGridEditor: TfrmORAVerticalGridEditor
  Left = 591
  Top = 125
  Caption = 'VerticalGrid - rows editor'
  ClientHeight = 370
  ClientWidth = 274
  Color = clBtnFace
  Constraints.MinHeight = 252
  Constraints.MinWidth = 228
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PopupMenu = PopupMenu
  OnActivate = FormActivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 170
    Top = 0
    Width = 104
    Height = 370
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      104
      370)
    object btCategory: TcxButton
      Left = 5
      Top = 41
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Add category'
      TabOrder = 2
      OnClick = btCategoryClick
    end
    object btEditor: TcxButton
      Left = 5
      Top = 9
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Add editor'
      TabOrder = 0
      OnClick = btEditorClick
    end
    object btClose: TcxButton
      Left = 5
      Top = 323
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Close'
      TabOrder = 5
      OnClick = btCloseClick
    end
    object btMultiEditor: TcxButton
      Left = 5
      Top = 73
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Add multieditor'
      TabOrder = 1
      OnClick = btMultiEditorClick
    end
    object btDelete: TcxButton
      Left = 5
      Top = 105
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Delete'
      Enabled = False
      TabOrder = 3
      OnClick = btDeleteClick
    end
    object btClear: TcxButton
      Left = 5
      Top = 169
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Clear all'
      Enabled = False
      TabOrder = 4
      OnClick = btClearClick
    end
    object btCreateAll: TcxButton
      Left = 5
      Top = 137
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Create all items'
      TabOrder = 6
      OnClick = btCreateAllClick
    end
    object btLayoutEditor: TcxButton
      Left = 5
      Top = 201
      Width = 89
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Layout editor...'
      Enabled = False
      TabOrder = 7
      OnClick = btLayoutEditorClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 170
    Height = 370
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object lbRows: TListBox
      Left = 4
      Top = 4
      Width = 162
      Height = 362
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
      OnClick = lbRowsClick
    end
  end
  object PopupMenu: TPopupMenu
    Left = 128
    Top = 16
    object miEditor: TMenuItem
      Caption = 'Add &editor'
      ShortCut = 45
      OnClick = miEditorClick
    end
    object miCategory: TMenuItem
      Caption = 'Add &category'
      OnClick = miCategoryClick
    end
    object miMultieditor: TMenuItem
      Caption = 'Add &multieditor'
      OnClick = miMultieditorClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miDelete: TMenuItem
      Caption = '&Delete row'
      Enabled = False
      ShortCut = 46
      OnClick = miDeleteClick
    end
    object miClearAll: TMenuItem
      Caption = 'C&lear all'
      Enabled = False
      OnClick = miClearAllClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miSelectAll: TMenuItem
      Caption = 'Select &All'
      Enabled = False
      ShortCut = 16449
      OnClick = miSelectAllClick
    end
  end
end
