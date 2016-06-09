unit ORALayoutGridEditor;

interface

uses Forms, SysUtils, Types, layoutForm, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters,
  cxPCdxBarPopupMenu,
  Menus, ExtCtrls, Controls, StdCtrls, cxButtons, cxPC, dxLayoutContainer, Classes,
  cxGridCustomView, ORALayoutCustomize,
  cxGridCustomTableView, cxCustomData, dxLayoutControl, dxLayoutControlAdapters,
  dxLayoutcxEditAdapters, cxContainer, cxEdit, cxCheckBox, cxTextEdit;

type

  TcxListBoxReindexProc = procedure(AList: TList; ANewIndex: Integer) of object;

  TfrmORALayoutGridEditor = class(TfrmLayout)
    BColumnAdd: TcxButton;
    BColumnDelete: TcxButton;
    BColumnAddAll: TcxButton;
    PMColumns: TPopupMenu;
    MIColumnAdd: TMenuItem;
    MIColumnDelete: TMenuItem;
    MIColumnSelectAll: TMenuItem;
    N1: TMenuItem;
    BColumnMoveUp: TcxButton;
    BColumnMoveDown: TcxButton;
    N2: TMenuItem;
    MIColumnMoveUp: TMenuItem;
    MIColumnMoveDown: TMenuItem;
    LBColumns: TListBox;
    BColumnAddMissing: TcxButton;
    dxLayoutControl1Item1: TdxLayoutItem;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Item6: TdxLayoutItem;
    dxLayoutControl1Item7: TdxLayoutItem;
    btnAutoWidth: TcxButton;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    btnNumberFmt: TcxButton;
    dxLayoutControl1Item9: TdxLayoutItem;
    teFormat: TcxTextEdit;
    dxLayoutControl1Item10: TdxLayoutItem;
    chkSummary: TcxCheckBox;
    dxLayoutControl1Item11: TdxLayoutItem;
    btnLayoutCustomization: TcxButton;
    dxLayoutControl1Item12: TdxLayoutItem;
    procedure LBColumnsClick(Sender: TObject);
    procedure BColumnAddClick(Sender: TObject);
    procedure BColumnDeleteClick(Sender: TObject);
    procedure BColumnRestoreClick(Sender: TObject);
    procedure MIColumnSelectAllClick(Sender: TObject);
    procedure BColumnAddAllClick(Sender: TObject);
    procedure BColumnMoveUpClick(Sender: TObject);
    procedure BColumnMoveDownClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LBColumnsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure BColumnAddMissingClick(Sender: TObject);
    procedure btnAutoWidthClick(Sender: TObject);
    procedure btnNumberFmtClick(Sender: TObject);
    procedure btnLayoutCustomizationClick(Sender: TObject);
  private
    FColumnHolder: TComponent;

    procedure ReindexViewColumnsProc(AList: TList; ANewIndex: Integer);
    procedure ReindexTLColumnsProc(AList: TList; ANewIndex: Integer);

    procedure CalculateListBoxItemHeight(AListBox: TListBox);
    procedure DoCreateViewItems(AMissingItemsOnly: Boolean);
    procedure DrawListBoxItem(AListBox: TWinControl; AIndex: Integer; R: TRect);
    procedure SelectAllColumns;
    procedure UpdateButtons;
    procedure UpdateColumnList;
    procedure SetHolder(const aHolder: TComponent);
    function getColumns(const pIndex: Integer): TComponent;
    function getColumnCount: Longint;
    function getReindexColumnsProc: TcxListBoxReindexProc;
    property ColumnHolder: TComponent read FColumnHolder;
    function CreateColumn: TComponent;
    procedure ClearColumns;
    property ColumnCount: Longint read getColumnCount;
    property Columns[const pIndex: Longint]: TComponent read getColumns;
    property ReindexColumnsProc: TcxListBoxReindexProc read getReindexColumnsProc;

  end;

procedure showViewColumns(const aColumnHolder: TComponent;
  const aCustomizeForm: TfrmORALayoutCustomize);
procedure ListBoxClearSelection(AListBox: TListBox);
procedure ListBoxSyncSelection(AListBox: TListBox; AList: TList);
procedure ListBoxSaveSelection(AListBox: TListBox; var ASelection: TStringList;
  var AItemIndex, ATopIndex: Integer);
procedure ListBoxRestoreSelection(AListBox: TListBox; var ASelection: TStringList;
  AItemIndex, ATopIndex: Integer);
procedure ListBoxSelectAll(AListBox: TListBox);

implementation

uses
  cxCurrencyEdit, cxGridDBTableView, ORALayoutColumnEdit, ORALayoutGrid, ORALayoutTreeList,
  Utilities, Dialogs, cxClasses, cxTLStrs, cxGridTableView,
  Math, dxCore, cxDBTL, cxTL;

{$R *.dfm}

type
  TORAColumnPropertiesClass = class of TORAColumnProperties;
  TcxCustomTreeListAccess = class(TcxCustomTreeList);

procedure showViewColumns(const aColumnHolder: TComponent;
  const aCustomizeForm: TfrmORALayoutCustomize);
const
  cEditorClassName: String = 'TfrmORALayoutGridEditor';
var
  vEditorClass: TPersistentClass;
  vEditor: TfrmORALayoutGridEditor;
begin
  vEditor := TfrmORALayoutGridEditor(getChildByClass(aCustomizeForm, TfrmORALayoutGridEditor));
  if vEditor = nil then begin
    vEditorClass := GetClass(cEditorClassName);
    if (vEditorClass <> nil) And vEditorClass.InheritsFrom(TCustomForm) then begin
      vEditor := TfrmORALayoutGridEditor(TCustomFormClass(vEditorClass).Create(aCustomizeForm));
    end
    else exit;
  end;
  vEditor.SetHolder(aColumnHolder);
  vEditor.Show;
end;

// ListBox Routines
function LockListBox(AListBox: TListBox): TNotifyEvent;
begin
  Result := AListBox.OnClick;
  AListBox.OnClick := nil;
end;

procedure UnlockListBox(AListBox: TListBox; APrevOnClick: TNotifyEvent);
begin
  AListBox.OnClick := APrevOnClick;
end;

procedure ListBoxSetItemIndex(AListBox: TListBox; AItemIndex: Integer);
var
  APrevOnClick: TNotifyEvent;
begin
  APrevOnClick := LockListBox(AListBox);
  try
    AListBox.ItemIndex := AItemIndex;
  finally
    UnlockListBox(AListBox, APrevOnClick);
  end;
end;

procedure ListBoxSetSelected(AListBox: TListBox; AItemIndex: Integer; ASelected: Boolean);
var
  APrevOnClick: TNotifyEvent;
begin
  APrevOnClick := LockListBox(AListBox);
  try
    if AListBox.Selected[AItemIndex] <> ASelected then AListBox.Selected[AItemIndex] := ASelected;
  finally
    UnlockListBox(AListBox, APrevOnClick);
  end;
end;

procedure ListBoxRestoreSelection(AListBox: TListBox; var ASelection: TStringList;
  AItemIndex, ATopIndex: Integer);
var
  I: Integer;
  APrevOnClick: TNotifyEvent;
begin
  try
    APrevOnClick := LockListBox(AListBox);
    try
      with AListBox do
        for I := 0 to Items.Count - 1 do
            Selected[I] := ASelection.IndexOfObject(Items.Objects[I]) <> -1;
      if ATopIndex <> -1 then AListBox.TopIndex := ATopIndex;
      if AItemIndex <> -1 then AListBox.ItemIndex := AItemIndex;
    finally
      UnlockListBox(AListBox, APrevOnClick);
    end;
  finally
    AListBox.Items.EndUpdate;
    FreeAndNil(ASelection);
  end;
end;

procedure ListBoxSaveSelection(AListBox: TListBox; var ASelection: TStringList;
  var AItemIndex, ATopIndex: Integer);
var
  I: Integer;
begin
  ASelection := TStringList.Create;
  try
    AItemIndex := AListBox.ItemIndex;
    ATopIndex := AListBox.TopIndex;
    with AListBox do
      for I := 0 to Items.Count - 1 do
        if Selected[I] then ASelection.AddObject(Items[I], Items.Objects[I]);
    AListBox.Items.BeginUpdate;
  except
    ASelection.Free;
    ASelection := nil;
  end;
end;

procedure ListBoxRestorePos(AListBox: TListBox; AItemIndex, ATopIndex: Integer);
var
  APrevOnClick: TNotifyEvent;
begin
  APrevOnClick := LockListBox(AListBox);
  try
    if ATopIndex <> -1 then AListBox.TopIndex := ATopIndex;
    if AItemIndex <> -1 then AListBox.ItemIndex := AItemIndex;
  finally
    UnlockListBox(AListBox, APrevOnClick);
  end;
  // AListBox.Items.EndUpdate;
end;

procedure ListBoxSavePos(AListBox: TListBox; var AItemIndex, ATopIndex: Integer);
begin
  AItemIndex := AListBox.ItemIndex;
  ATopIndex := AListBox.TopIndex;
  // AListBox.Items.BeginUpdate;
end;

function ListBoxGetFirstSelectedIndex(AListBox: TListBox): Integer;
begin
  for Result := 0 to AListBox.Items.Count - 1 do
    if AListBox.Selected[Result] then exit;
  Result := -1;
end;

function ListBoxGetLastSelectedIndex(AListBox: TListBox): Integer;
begin
  for Result := AListBox.Items.Count - 1 downto 0 do
    if AListBox.Selected[Result] then exit;
  Result := -1;
end;

procedure ListBoxDeleteSelection(AListBox: TListBox; ASetFocus: Boolean;
  AKeepSelection: Boolean = False);
var
  I, AIndex: Integer;
  AObject, AItemToSelect: TObject;

  function CanDeleteObject(AObject: TObject): Boolean;
  begin
    if AObject is TComponent then Result := not(csAncestor in TComponent(AObject).ComponentState)
    else Result := True;
  end;

  function FindItemToSelect: TObject;
  var
    I: Integer;
  begin
    Result := nil;
    with AListBox do begin
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

begin
  AItemToSelect := FindItemToSelect;
  for I := AListBox.Items.Count - 1 downto 0 do
    if AListBox.Selected[I] then begin
      with AListBox.Items do begin
        AObject := Objects[I];
        if not CanDeleteObject(AObject) then begin
          AItemToSelect := AObject;
          Continue;
        end;
        Delete(I);
      end;
      AObject.Free;
    end;
  AIndex := AListBox.Items.IndexOfObject(AItemToSelect);
  if AIndex >= 0 then begin
    ListBoxSetItemIndex(AListBox, AIndex);
    if AKeepSelection then ListBoxSetSelected(AListBox, AIndex, True);
    if ASetFocus and AListBox.CanFocus then AListBox.SetFocus;
  end;
end;

procedure ListBoxSetNumberFormat(const AListBox: TListBox;
  const aPropClass: TORAColumnPropertiesClass; const AFormat: String;
  const aSummaryKind: TcxSummaryKind = skNone);
var
  I: Integer;
begin

  for I := AListBox.Items.Count - 1 downto 0 do
    if AListBox.Selected[I] then begin
      with AListBox.Items do
        if Objects[I] is TComponent then begin
          with aPropClass.Create(TComponent(Objects[I]), nil) do
            try
              ColumnType := get_ORAColumnType('Число');
              if Properties is TcxCurrencyEditProperties then
                with TcxCurrencyEditProperties(Properties) do begin
                  DisplayFormat := AFormat;
                  if (aSummaryKind <> skNone) And (Objects[I] is TcxGridDBColumn) then
                    with TcxGridDBColumn(Objects[I]) do begin
                      Summary.FooterKind := aSummaryKind;
                      Summary.FooterFormat := AFormat;
                      Summary.GroupFooterKind := aSummaryKind;
                      Summary.GroupFooterFormat := AFormat;
                    end;
                end;

            finally
              Free;
            end;
        end;
    end;
end;

procedure ListBoxGetSelection(AListBox: TListBox; AList: TList);
var
  I: Integer;
begin
  for I := 0 to AListBox.Items.Count - 1 do
    if AListBox.Selected[I] then AList.Add(AListBox.Items.Objects[I]);
end;

procedure ListBoxLoadCollection(AListBox: TListBox; ACollection: TCollection);
var
  I, AItemIndex, ATopIndex: Integer;
  ASelection: TStringList;
  S: string;
begin
  ListBoxSaveSelection(AListBox, ASelection, AItemIndex, ATopIndex);
  try
    AListBox.Items.Clear;
    for I := 0 to ACollection.Count - 1 do begin
      S := Format('%d - %s', [I, ACollection.Items[I].DisplayName]);
      AListBox.Items.AddObject(S, ACollection.Items[I]);
    end;
  finally
    ListBoxRestoreSelection(AListBox, ASelection, AItemIndex, ATopIndex);
  end;
end;

procedure ListBoxSelectByObject(AListBox: TListBox; AObject: TObject);
var
  AIndex: Integer;
begin
  AIndex := AListBox.Items.IndexOfObject(AObject);
  if AIndex <> -1 then ListBoxSetSelected(AListBox, AIndex, True);
end;

procedure ListBoxSyncSelection(AListBox: TListBox; AList: TList);
var
  I, AItemIndex, ATopIndex: Integer;
  ASelected: Boolean;
  APrevOnClick: TNotifyEvent;
begin
  ListBoxSavePos(AListBox, AItemIndex, ATopIndex);
  try
    APrevOnClick := LockListBox(AListBox);
    try
      for I := 0 to AListBox.Items.Count - 1 do begin
        ASelected := AList.IndexOf(AListBox.Items.Objects[I]) <> -1;
        if AListBox.Selected[I] <> ASelected then AListBox.Selected[I] := ASelected;
      end;
    finally
      UnlockListBox(AListBox, APrevOnClick);
    end;
    if AListBox.SelCount = 1 then
      for I := 0 to AListBox.Items.Count - 1 do
        if AListBox.Selected[I] then begin
          AItemIndex := I;
          Break;
        end;
  finally
    ListBoxRestorePos(AListBox, AItemIndex, ATopIndex);
  end;
end;

procedure ListBoxClearSelection(AListBox: TListBox);
var
  APrevOnClick: TNotifyEvent;
begin
  APrevOnClick := LockListBox(AListBox);
  try
    AListBox.ClearSelection;
  finally
    UnlockListBox(AListBox, APrevOnClick);
  end;
end;

procedure ListBoxSelectAll(AListBox: TListBox);
var
  I: Integer;
  APrevOnClick: TNotifyEvent;
begin
  APrevOnClick := LockListBox(AListBox);
  try
    with AListBox do
      for I := 0 to Items.Count - 1 do Selected[I] := True;
  finally
    UnlockListBox(AListBox, APrevOnClick);
  end;
end;

procedure ListBoxMoveItems(AListBox: TListBox; AIndex: Integer; var APrevDragIndex: Integer;
  AReindexProc: TcxListBoxReindexProc);
var
  I: Integer;
  APrevOnClick: TNotifyEvent;
  AList: TList;
begin
  APrevOnClick := LockListBox(AListBox);
  try
    with AListBox do begin
      if (0 <= APrevDragIndex) and (APrevDragIndex < Items.Count) then begin
        Selected[APrevDragIndex] := False;
        APrevDragIndex := -1;
      end;
      if AIndex <> -1 then begin
        AList := TList.Create;
        try
          for I := 0 to Items.Count - 1 do
            if Selected[I] then AList.Add(Items.Objects[I]);
          AReindexProc(AList, AIndex);
        finally
          AList.Free;
        end;
      end;
      AIndex := Max(ListBoxGetFirstSelectedIndex(AListBox), AIndex);
      AIndex := Min(ListBoxGetLastSelectedIndex(AListBox), AIndex);
      ItemIndex := AIndex;
    end;
  finally
    UnlockListBox(AListBox, APrevOnClick);
  end;
end;

procedure ListBoxMoveUpItems(AListBox: TListBox; var APrevDragIndex: Integer;
  AReindexProc: TcxListBoxReindexProc);
begin
  ListBoxMoveItems(AListBox, Max(0, ListBoxGetFirstSelectedIndex(AListBox) - 1), APrevDragIndex,
    AReindexProc);
end;

procedure ListBoxMoveDownItems(AListBox: TListBox; var APrevDragIndex: Integer;
  AReindexProc: TcxListBoxReindexProc);
begin
  ListBoxMoveItems(AListBox, Min(AListBox.Items.Count - 1, ListBoxGetLastSelectedIndex(AListBox) +
    1), APrevDragIndex, AReindexProc);
end;

procedure ListBoxDragOver(AListBox: TListBox; Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean; var APrevDragIndex: Integer);
var
  AIndex: Integer;
  APrevOnClick: TNotifyEvent;
begin
  if Source <> AListBox then Accept := False
  else begin
    APrevOnClick := LockListBox(AListBox);
    try
      with AListBox do begin
        Accept := True;
        AIndex := ItemAtPos(Point(X, Y), True);
        if APrevDragIndex <> AIndex then begin
          if (0 <= APrevDragIndex) and (APrevDragIndex < Items.Count) then
              Selected[APrevDragIndex] := False;
          if AIndex <> -1 then
            if not Selected[AIndex] then begin
              Selected[AIndex] := True;
              APrevDragIndex := AIndex;
            end
            else APrevDragIndex := -1;
        end;
        ItemIndex := AIndex;
      end;
    finally
      UnlockListBox(AListBox, APrevOnClick);
    end;
  end;
end;

procedure ListBoxDragDrop(AListBox: TListBox; Sender, Source: TObject; X, Y: Integer;
  var APrevDragIndex: Integer; AReindexProc: TcxListBoxReindexProc);
var
  AIndex: Integer;
begin
  AIndex := AListBox.ItemAtPos(Point(X, Y), True);
  if (AIndex = -1) and PtInRect(AListBox.ClientRect, Point(X, Y)) then
      AIndex := AListBox.Items.Count;
  if AIndex <> -1 then ListBoxMoveItems(AListBox, AIndex, APrevDragIndex, AReindexProc);
end;

procedure ListBoxEndDrag(AListBox: TListBox; Sender, Target: TObject; X, Y: Integer;
  var APrevDragIndex: Integer);
begin
  if (0 <= APrevDragIndex) and (APrevDragIndex < AListBox.Items.Count) then begin
    ListBoxSetSelected(AListBox, APrevDragIndex, False);
    APrevDragIndex := -1;
  end;
end;

{ TcxCustomTableViewEditor }

procedure TfrmORALayoutGridEditor.CalculateListBoxItemHeight(AListBox: TListBox);
begin
  with AListBox do begin
    Canvas.Font := Font;
    ItemHeight := 2 + cxTextHeight(Canvas.Handle);
  end;
end;

procedure TfrmORALayoutGridEditor.ClearColumns;
var
  I: Integer;
begin
  if ColumnHolder is TcxCustomGridTableView then TcxCustomGridTableView(ColumnHolder).BeginUpdate
  else if ColumnHolder is TcxCustomTreeList then TcxCustomTreeList(ColumnHolder).BeginUpdate;
  try
    for I := ColumnCount - 1 downto 0 do Columns[I].Free;
  finally
    if ColumnHolder is TcxCustomGridTableView then TcxCustomGridTableView(ColumnHolder).EndUpdate
    else if ColumnHolder is TcxCustomTreeList then TcxCustomTreeList(ColumnHolder).EndUpdate;
  end;
end;

function TfrmORALayoutGridEditor.CreateColumn: TComponent;
begin
  if ColumnHolder is TcxCustomGridTableView then
      Result := CreateViewItem(TcxCustomGridTableView(ColumnHolder))
  else if ColumnHolder is TcxCustomTreeList then
      Result := TcxCustomTreeList(ColumnHolder).CreateColumn
  else Result := nil;
end;

procedure TfrmORALayoutGridEditor.DrawListBoxItem(AListBox: TWinControl; AIndex: Integer; R: TRect);
begin
  with AListBox as TListBox, Canvas do begin
    FillRect(R);
    TextOut(R.Left + 2, R.Top, Items[AIndex]);
  end;
end;

procedure TfrmORALayoutGridEditor.SelectAllColumns;
begin
  ListBoxSelectAll(LBColumns);
end;

procedure TfrmORALayoutGridEditor.SetHolder(const aHolder: TComponent);
begin
  FColumnHolder := aHolder;
  UpdateColumnList;
  UpdateButtons;
  if FColumnHolder <> nil then Caption := FColumnHolder.Name
  else Caption := '';
end;

procedure TfrmORALayoutGridEditor.UpdateButtons;
var
  vLayoutContainerOwner: IdxLayoutContainerOwner;
begin
  btnLayoutCustomization.Enabled := ColumnHolder.GetInterface(IdxLayoutContainerOwner,
    vLayoutContainerOwner);
  // Columns
  // BColumnAdd.Enabled := CanAddComponent;
  BColumnDelete.Enabled := LBColumns.SelCount > 0;
  BColumnMoveUp.Enabled := LBColumns.SelCount > 0;
  BColumnMoveDown.Enabled := LBColumns.SelCount > 0;
  BColumnAddAll.Enabled := True;
  // (View.DataController as IcxCustomGridDataController).IsDataLinked;
  BColumnAddMissing.Enabled := BColumnAddAll.Enabled;
  // and not(View.DataController as IcxCustomGridDataController).HasAllItems;

  MIColumnAdd.Enabled := BColumnAdd.Enabled;
  MIColumnDelete.Enabled := BColumnDelete.Enabled;
  MIColumnMoveUp.Enabled := BColumnMoveUp.Enabled;
  MIColumnMoveDown.Enabled := BColumnMoveDown.Enabled;
  MIColumnSelectAll.Enabled := LBColumns.SelCount < LBColumns.Items.Count;

end;

procedure TfrmORALayoutGridEditor.UpdateColumnList;
var
  I, AItemIndex, ATopIndex: Integer;
  ASelection: TStringList;
  S: string;
begin
  ListBoxSaveSelection(LBColumns, ASelection, AItemIndex, ATopIndex);
  try
    LBColumns.Items.Clear;
    for I := 0 to ColumnCount - 1 do begin
      S := Columns[I].Name;
      // if View.Items[I].RepositoryItem <> nil then
      // S := S + ' (' + View.Items[I].RepositoryItem.Name + ')'; // TODO: description
      LBColumns.Items.AddObject(S, Columns[I]);
    end;
  finally
    ListBoxRestoreSelection(LBColumns, ASelection, AItemIndex, ATopIndex);
  end;
end;

procedure TfrmORALayoutGridEditor.ReindexViewColumnsProc(AList: TList; ANewIndex: Integer);
var
  I: Integer;
begin
  if AList.Count = 0 then exit;
  if TcxCustomGridTableItem(AList[0]).Index < ANewIndex then begin
    for I := 0 to AList.Count - 1 do TcxCustomGridTableItem(AList[I]).Index := ANewIndex;
  end else begin
    for I := AList.Count - 1 downto 0 do TcxCustomGridTableItem(AList[I]).Index := ANewIndex;
  end;
end;

procedure TfrmORALayoutGridEditor.ReindexTLColumnsProc(AList: TList; ANewIndex: Integer);
var
  I: Integer;
begin
  if AList.Count = 0 then exit;
  if TcxTreeListColumn(AList[0]).ItemIndex < ANewIndex then begin
    for I := 0 to AList.Count - 1 do TcxTreeListColumn(AList[I]).ItemIndex := ANewIndex;
  end else begin
    for I := AList.Count - 1 downto 0 do TcxTreeListColumn(AList[I]).ItemIndex := ANewIndex;
  end;
end;

// Columns

procedure TfrmORALayoutGridEditor.LBColumnsClick(Sender: TObject);
begin
  if LBColumns.ItemIndex >= 0 then begin
    TfrmORALayoutCustomize(Owner).Item := TComponent(LBColumns.Items.Objects[LBColumns.ItemIndex]);
    UpdateButtons;
  end;
end;

procedure TfrmORALayoutGridEditor.BColumnAddClick(Sender: TObject);
var
  AItem: TComponent;
begin
  ListBoxClearSelection(LBColumns);
  AItem := CreateColumn;
  UpdateColumnList;
  ListBoxSelectByObject(LBColumns, AItem);
  LBColumnsClick(nil);
end;

procedure TfrmORALayoutGridEditor.BColumnAddMissingClick(Sender: TObject);
begin
  DoCreateViewItems(True);
end;

procedure TfrmORALayoutGridEditor.BColumnDeleteClick(Sender: TObject);
begin
  if LBColumns.SelCount > 0 then begin
    ListBoxDeleteSelection(LBColumns, True);
    UpdateColumnList;
    LBColumnsClick(nil);
  end;
end;

procedure TfrmORALayoutGridEditor.BColumnRestoreClick(Sender: TObject);
var
  I: Integer;
begin
  if LBColumns.SelCount > 0 then
    try
      for I := 0 to LBColumns.Items.Count - 1 do
        if LBColumns.Selected[I] then
            TcxCustomGridTableItem(LBColumns.Items.Objects[I]).RestoreDefaults;
    finally
      UpdateColumnList;
      LBColumnsClick(nil);
    end;
end;

procedure TfrmORALayoutGridEditor.btnAutoWidthClick(Sender: TObject);
begin
  if ColumnHolder is TcxCustomGridTableView then TcxCustomGridTableView(ColumnHolder).ApplyBestFit()
  else if ColumnHolder is TcxCustomTreeList then TcxCustomTreeList(ColumnHolder).ApplyBestFit()
end;

procedure TfrmORALayoutGridEditor.btnLayoutCustomizationClick(Sender: TObject);
// var   vLayoutContainerOwner: IdxLayoutContainerOwner;
begin
  if ColumnHolder is TcxGridTableView then
      TcxGridTableView(ColumnHolder).Controller.ShowEditFormCustomizationDialog
  else if ColumnHolder is TcxCustomGridView then
    with TcxCustomGridView(ColumnHolder).Controller do Customization := not Customization;
end;

procedure TfrmORALayoutGridEditor.btnNumberFmtClick(Sender: TObject);
var
  vSummaryKind: TcxSummaryKind;
begin
  inherited;
  if chkSummary.Checked then vSummaryKind := skSum
  else vSummaryKind := skNone;

  if ColumnHolder is TcxCustomGridTableView then
      ListBoxSetNumberFormat(LBColumns, TORATableColumnProperties, teFormat.EditValue, vSummaryKind)
  else if ColumnHolder is TcxCustomTreeList then
      ListBoxSetNumberFormat(LBColumns, TORATreeListColumnProperties, ',0.00');
end;

procedure TfrmORALayoutGridEditor.BColumnMoveUpClick(Sender: TObject);
var
  vPrevDragIndex: Longint;
begin
  vPrevDragIndex := -1;
  ListBoxMoveUpItems(LBColumns, vPrevDragIndex, ReindexColumnsProc);
end;

procedure TfrmORALayoutGridEditor.BColumnMoveDownClick(Sender: TObject);
var
  vPrevDragIndex: Longint;
begin
  vPrevDragIndex := -1;
  ListBoxMoveDownItems(LBColumns, vPrevDragIndex, ReindexColumnsProc);
end;

procedure TfrmORALayoutGridEditor.BColumnAddAllClick(Sender: TObject);
begin
  if ColumnCount > 0 then
    case MessageDlg('Удалить все существующие колонки?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes: ClearColumns;
      mrCancel: exit;
    end;
  DoCreateViewItems(False);
end;

procedure TfrmORALayoutGridEditor.MIColumnSelectAllClick(Sender: TObject);
begin
  SelectAllColumns;
  LBColumnsClick(nil);
end;

procedure TfrmORALayoutGridEditor.FormCreate(Sender: TObject);
begin
  inherited;
  CalculateListBoxItemHeight(LBColumns);
end;

function TfrmORALayoutGridEditor.getColumns(const pIndex: Integer): TComponent;
begin
  if ColumnHolder is TcxCustomGridTableView then
      Result := TcxCustomGridTableView(ColumnHolder).Items[pIndex]
  else if ColumnHolder is TcxCustomTreeList then
      Result := TcxCustomTreeList(ColumnHolder).Columns[pIndex]
  else Result := nil;
end;

function TfrmORALayoutGridEditor.getReindexColumnsProc: TcxListBoxReindexProc;
begin
  if ColumnHolder is TcxCustomGridTableView then Result := ReindexViewColumnsProc
  else if ColumnHolder is TcxCustomTreeList then Result := ReindexTLColumnsProc;
end;

function TfrmORALayoutGridEditor.getColumnCount: Longint;
begin
  if ColumnHolder is TcxCustomGridTableView then
      Result := TcxCustomGridTableView(ColumnHolder).ItemCount
  else if ColumnHolder is TcxCustomTreeList then
      Result := TcxCustomTreeList(ColumnHolder).ColumnCount
  else Result := 0;
end;

procedure TfrmORALayoutGridEditor.LBColumnsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  DrawListBoxItem(Control, Index, Rect);
end;

type
  TcxCustomDBTreeListAccess = class(TcxCustomDBTreeList);

procedure TfrmORALayoutGridEditor.DoCreateViewItems(AMissingItemsOnly: Boolean);
var
  AItems: TList;

  procedure CreateTLItems(const pController: TcxDBTreeListDataController);
  var
    I: Integer;
    ABand: TcxTreeListBand;
    AColumn: TcxDBTreeListColumn;
  begin
    with pController do begin
      if (DataSet = nil) or (DataSet.FieldCount = 0) then exit;
      TcxCustomDBTreeListAccess(TreeList).SetGlassCursor;
      try
        TreeList.BeginUpdate;
        try
          ABand := TcxCustomDBTreeListAccess(TreeList).GetDefaultColumnContainer;
          for I := 0 to DataSet.FieldCount - 1 do begin
            if not AMissingItemsOnly or
              (TcxCustomDBTreeListAccess(TreeList).GetColumnByFieldName(DataSet.Fields[I].FieldName)
              = nil) then begin
              AColumn := TcxDBTreeListColumn(TreeList.CreateColumn(ABand));
              AColumn.DataBinding.FieldName := DataSet.Fields[I].FieldName;
              if TreeList.Owner <> nil then
                  AColumn.Name := CreateUniqueName(TreeList.Owner, TreeList, AColumn,
                  scxTLPrefixName, DataSet.Fields[I].FieldName);
              AColumn.Visible := DataSet.Fields[I].Visible;
            end;
          end;
        finally
          TreeList.EndUpdate;
        end;
      finally
        TcxCustomDBTreeListAccess(TreeList).RestoreCursor;
        TcxCustomDBTreeListAccess(TreeList).Modified;
      end;
    end;
  end;

  procedure CreateColumns;
  begin
    if ColumnHolder is TcxCustomGridTableView then begin
      (TcxCustomGridTableView(ColumnHolder).DataController as IcxCustomGridDataController)
        .CreateAllItems(AMissingItemsOnly) end else if (ColumnHolder is TcxCustomTreeList) And
        (TcxCustomTreeListAccess(ColumnHolder).DataController is TcxDBTreeListDataController)
      then CreateTLItems(TcxDBTreeListDataController(TcxCustomTreeListAccess(ColumnHolder)
        .DataController)) end;

      procedure getColumns(AItems: TList);
      var
        I: Integer;
      begin
        for I := 0 to ColumnCount - 1 do AItems.Add(Columns[I]);
      end;

      procedure GetNewColumns(AOldItems, ANewItems: TList);
      var
        I, J: Integer;
      begin
        for I := 0 to ColumnCount - 1 do begin
          J := AOldItems.IndexOf(Columns[I]);
          if J = -1 then ANewItems.Add(Columns[I])
          else AOldItems.Delete(J);
        end;
      end;

      begin
        AItems := TList.Create;
        try
          getColumns(AItems);
          CreateColumns;
          GetNewColumns(AItems, AItems);
          UpdateColumnList;
          ListBoxSyncSelection(LBColumns, AItems);
          LBColumnsClick(nil);
        finally
          AItems.Free;
        end;
      end;

initialization

RegisterClass(TfrmORALayoutGridEditor);

// RegisterViewEditorClass(TcxCustomGridTableView, TcxCustomTableViewEditor);
// RegisterViewMenuProviderClass(TcxCustomGridTableView, TcxCustomGridTableViewMenuProvider);
//
finalization

UnRegisterClass(TfrmORALayoutGridEditor);
// UnregisterViewMenuProviderClass(TcxCustomGridTableView, TcxCustomGridTableViewMenuProvider);
// UnregisterViewEditorClass(TcxCustomGridTableView, TcxCustomTableViewEditor);

end.
