unit ORALayoutVGridEditor;

{$I cxVer.inc}

interface

uses
  Variants, Classes, Graphics, Controls, Forms, ORALayoutCustomize,
  Dialogs, cxVGrid, StdCtrls, ComCtrls, ExtCtrls, cxOI,
  cxLookAndFeelPainters, cxButtons, cxDBVGrid, Menus, cxGraphics, cxLookAndFeels;

type
  TfrmORAVerticalGridEditor = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lbRows: TListBox;
    btCategory: TcxButton;
    btEditor: TcxButton;
    btClose: TcxButton;
    btMultiEditor: TcxButton;
    btDelete: TcxButton;
    btClear: TcxButton;
    btCreateAll: TcxButton;
    PopupMenu: TPopupMenu;
    miEditor: TMenuItem;
    miCategory: TMenuItem;
    miMultieditor: TMenuItem;
    N1: TMenuItem;
    miDelete: TMenuItem;
    miClearAll: TMenuItem;
    N2: TMenuItem;
    miSelectAll: TMenuItem;
    btLayoutEditor: TcxButton;
    procedure btCloseClick(Sender: TObject);
    procedure lbRowsClick(Sender: TObject);
    procedure btCategoryClick(Sender: TObject);
    procedure btEditorClick(Sender: TObject);
    procedure btMultiEditorClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btCreateAllClick(Sender: TObject);
    procedure miEditorClick(Sender: TObject);
    procedure miCategoryClick(Sender: TObject);
    procedure miMultieditorClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure miClearAllClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    procedure btLayoutEditorClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FVGrid: TcxCustomVerticalGrid;
    FLocked: Boolean;
    procedure AddRow(ARowClass: TcxCustomRowClass);
    procedure SelectItem(AItem: Pointer);
    procedure UpdateButtons;
    procedure UpdateItems;
  protected
    procedure InitFormEditor; // override;
  public
    procedure DoItemsModified; // override;
    // procedure SelectionsChanged(const ASelection: TDesignerSelectionList); override;
    property VerticalGrid: TcxCustomVerticalGrid read FVGrid;
  end;

  TORAVGridRowsProperty = class(TcxClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TcxPropertyAttributes; override;
  end;

procedure showVGridEditor(const aVGrid: TcxCustomVerticalGrid;
  const aCustomizeForm: TfrmORALayoutCustomize);

implementation

uses
  Utilities, ORALayoutVGrid, cxClasses, Types, SysUtils, cxDBData, cxVGridLayoutEditor,
  ORALayoutGridEditor;

{$R *.dfm}

const
  SizeStore: TRect = (Left: - 1; Top: - 1; Right: - 1; Bottom: - 1);

procedure showVGridEditor(const aVGrid: TcxCustomVerticalGrid;
  const aCustomizeForm: TfrmORALayoutCustomize);
const
  cEditorClassName: String = 'TfrmORAVerticalGridEditor';
var
  vEditorClass: TPersistentClass;
  vEditor: TfrmORAVerticalGridEditor;
begin
  vEditor := TfrmORAVerticalGridEditor(getChildByClass(aCustomizeForm, TfrmORAVerticalGridEditor));
  if vEditor = nil then begin
    vEditorClass := GetClass(cEditorClassName);
    if (vEditorClass <> nil) And vEditorClass.InheritsFrom(TCustomForm) then begin
      vEditor := TfrmORAVerticalGridEditor(TCustomFormClass(vEditorClass).Create(aCustomizeForm));
    end
    else exit;
  end;
  with vEditor do begin
    FVGrid := aVGrid;
    InitFormEditor;
    Show;
  end;
end;

procedure TfrmORAVerticalGridEditor.btCategoryClick(Sender: TObject);
begin
  AddRow(TORACategoryRow);
end;

procedure TfrmORAVerticalGridEditor.btEditorClick(Sender: TObject);
var
  AIntf: IcxVGridDesignerRows;
begin
  if Supports(TObject(VerticalGrid), IcxVGridDesignerRows, AIntf) then
      AddRow(AIntf.GetEditorRowClass);
end;

procedure TfrmORAVerticalGridEditor.btMultiEditorClick(Sender: TObject);
var
  AIntf: IcxVGridDesignerRows;
begin
  if Supports(TObject(VerticalGrid), IcxVGridDesignerRows, AIntf) then
      AddRow(AIntf.GetMultiEditorRowClass);
end;

procedure TfrmORAVerticalGridEditor.btDeleteClick(Sender: TObject);

  function FindItemToSelect: Pointer;
  var
    I: Integer;
  begin
    Result := nil;
    with lbRows do begin
      if ItemIndex = -1 then exit;
      if not Selected[ItemIndex] then Result := Items.Objects[ItemIndex]
      else begin
        for I := ItemIndex + 1 to Items.Count - 1 do
          if not Selected[I] then begin
            Result := Items.Objects[I];
            exit
          end;
        for I := ItemIndex - 1 downto 0 do
          if not Selected[I] then begin
            Result := Items.Objects[I];
            exit
          end;
      end;
    end;
  end;

var
  AItem: Pointer;
  ARow: TcxCustomRow;
  I, J: Integer;
begin
  if lbRows.SelCount > 0 then begin
    FLocked := True;
    AItem := FindItemToSelect;
    VerticalGrid.BeginUpdate;
    try
      for I := lbRows.Items.Count - 1 downto 0 do
        if lbRows.Selected[I] then begin
          ARow := TcxCustomRow(lbRows.Items.Objects[I]);
          J := ARow.Index;
          while ARow.Count > 0 do
            with ARow.Rows[0] do begin
              Parent := ARow.Parent;
              Index := J;
              Inc(J);
            end;
          ARow.Free;
        end;
    finally
      VerticalGrid.EndUpdate;
      FLocked := False;
    end;
    if lbRows.CanFocus then lbRows.SetFocus;
    UpdateItems;
    SelectItem(AItem);
    lbRowsClick(nil);
  end;
end;

procedure TfrmORAVerticalGridEditor.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmORAVerticalGridEditor.lbRowsClick(Sender: TObject);
begin
  if lbRows.ItemIndex >= 0 then
      TfrmORALayoutCustomize(Owner).Item := TComponent(lbRows.Items.Objects[lbRows.ItemIndex]);
  UpdateButtons;
end;

procedure TfrmORAVerticalGridEditor.AddRow(ARowClass: TcxCustomRowClass);
var
  ARow: TcxCustomRow;
begin
  if ARowClass <> nil then begin
    ARow := VerticalGrid.Add(ARowClass);
    ARow.Name := CreateUniqueName(VerticalGrid.Owner, VerticalGrid, ARow, 'Tcx', '');
    UpdateItems;
    SelectItem(ARow);
    UpdateButtons;
  end;
end;

procedure TfrmORAVerticalGridEditor.SelectItem(AItem: Pointer);
begin
  with lbRows do ItemIndex := Items.IndexOfObject(AItem);
  ListBoxClearSelection(lbRows);
  // if VerticalGrid <> nil then
  // if (AItem <> nil) and (lbRows.ItemIndex >= 0) then Designer.SelectComponent(TPersistent(AItem))
  // else Designer.SelectComponent(Component)
end;

procedure TfrmORAVerticalGridEditor.UpdateButtons;
begin
  btDelete.Enabled := lbRows.SelCount <> 0;
  miDelete.Enabled := btDelete.Enabled;
  miSelectAll.Enabled := lbRows.Items.Count > 0;
  btClear.Enabled := miSelectAll.Enabled;
  miClearAll.Enabled := miSelectAll.Enabled;
  btLayoutEditor.Enabled := miSelectAll.Enabled;
  btCreateAll.Visible := VerticalGrid is TcxDBVerticalGrid;
  if btCreateAll.Visible then
      btCreateAll.Enabled := TcxDBVerticalGrid(VerticalGrid).DataController.Dataset <> nil;
end;

procedure TfrmORAVerticalGridEditor.UpdateItems;
var
  I, AItemIndex, ATopIndex: Integer;
  ASelection: TStringList;
begin
  ListBoxSaveSelection(lbRows, ASelection, AItemIndex, ATopIndex);
  try
    lbRows.Items.Clear;
    for I := 0 to VerticalGrid.Rows.Count - 1 do
        lbRows.Items.AddObject(VerticalGrid.Rows[I].Name, VerticalGrid.Rows.Items[I]);
  finally
    ListBoxRestoreSelection(lbRows, ASelection, AItemIndex, ATopIndex);
  end;
end;

procedure TfrmORAVerticalGridEditor.InitFormEditor;
begin
  // inherited InitFormEditor;
  UpdateItems;
  // UpdateSelection;
  UpdateButtons;
  if not btCreateAll.Visible then begin
    btLayoutEditor.Top := btClear.Top;
    btClear.Top := btCreateAll.Top;
  end;
  ClientHeight := btLayoutEditor.Top + btLayoutEditor.Height * 3 + 16;
  Constraints.MinHeight := Height;
  btClose.Top := ClientHeight - (btClose.Height + 8);
end;

procedure TfrmORAVerticalGridEditor.DoItemsModified;
begin
  UpdateItems;
end;

// procedure TcxVerticalGridEditor.SelectionsChanged(const ASelection: TDesignerSelectionList);
// var
// AList: TList;
// begin
// if FLocked then Exit;
// AList := TList.Create;
// try
// GetSelectionList(AList);
// ListBoxSyncSelection(lbRows, AList);
// finally
// AList.Free;
// end;
// UpdateButtons;
// end;

procedure TfrmORAVerticalGridEditor.btClearClick(Sender: TObject);
begin
  ListBoxSelectAll(lbRows);
  btDeleteClick(nil);
  UpdateItems;
  // UpdateSelection;
  UpdateButtons;
end;

procedure TfrmORAVerticalGridEditor.FormActivate(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TfrmORAVerticalGridEditor.btCreateAllClick(Sender: TObject);
begin
  if VerticalGrid is TcxDBVerticalGrid then begin
    TcxDBVerticalGrid(VerticalGrid).DataController.CreateAllItems;
    UpdateItems;
    UpdateButtons;
  end;
end;

procedure TfrmORAVerticalGridEditor.miEditorClick(Sender: TObject);
begin
  btEditorClick(nil);
end;

procedure TfrmORAVerticalGridEditor.miCategoryClick(Sender: TObject);
begin
  btCategoryClick(nil);
end;

procedure TfrmORAVerticalGridEditor.miMultieditorClick(Sender: TObject);
begin
  btMultiEditorClick(nil);
end;

procedure TfrmORAVerticalGridEditor.miDeleteClick(Sender: TObject);
begin
  btDeleteClick(nil);
end;

procedure TfrmORAVerticalGridEditor.miClearAllClick(Sender: TObject);
begin
  btClearClick(nil);
end;

procedure TfrmORAVerticalGridEditor.miSelectAllClick(Sender: TObject);
begin
  ListBoxSelectAll(lbRows);
  UpdateItems;
  UpdateButtons;
end;

procedure TfrmORAVerticalGridEditor.btLayoutEditorClick(Sender: TObject);
begin
  ShowVerticalGridLayoutEditor(VerticalGrid);
end;

procedure TfrmORAVerticalGridEditor.FormShow(Sender: TObject);
begin
  if SizeStore.Right <> -1 then begin
    Left := SizeStore.Left;
    Top := SizeStore.Top;
    Width := SizeStore.Right;
    Height := SizeStore.Bottom;
  end;
end;

procedure TfrmORAVerticalGridEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SizeStore.Left := Left;
  SizeStore.Top := Top;
  SizeStore.Right := Width;
  SizeStore.Bottom := Height;
end;

{ TORAVGridRowsProperty }

procedure TORAVGridRowsProperty.Edit;
var
  vPersistent: TPersistent;
begin
  vPersistent := TPersistent(GetOrdValue);
  if vPersistent is TcxCustomVerticalGrid then
      showVGridEditor(TcxCustomVerticalGrid(vPersistent),
      TfrmORALayoutCustomize(getOwnerByClass(Inspector, TfrmORALayoutCustomize)));
end;

function TORAVGridRowsProperty.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaDialog, ipaReadOnly];
end;

initialization

RegisterClass(TfrmORAVerticalGridEditor);
cxRegisterPropertyEditor(TypeInfo(TORAVerticalGrid), TORAControlProperties, 'VGrid',
  TORAVGridRowsProperty);

finalization

UnRegisterClass(TfrmORAVerticalGridEditor);

end.
