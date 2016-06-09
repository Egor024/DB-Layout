unit ORALayoutTreeList;

interface

uses TypInfo, Classes, SysUtils, cxTL, cxDBTL, cxTLData, DB, LayoutData, cxStyles,
  ORALayoutCustomize, cxOI, ORALayoutColumnEdit, cxEdit, cxInplaceContainer, Controls, dxCore,
  ORANavigators, cxNavigator;

type
  TORATreeList = class(TcxDBTreeList)
  private
    FDataSet: TDataSet;
    FOnNewRecord: TDataSet;
    procedure OnAfterPost(pDataSet: TDataSet);
    procedure GetContentStyle(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn;
      ANode: TcxTreeListNode; var AStyle: TcxStyle);
    function getRowStyleColumnIndex: Integer;
    function getColumnStyleColumnIndex(const pColumn: String): Integer;
    function getIDField: String;
    procedure setIDField(const Value: String);
    function getParentField: String;
    procedure setParentField(const Value: String);
    procedure DragOverHandler(Sender, Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    function getLockingMode: TLockMode;
    function getUniqFields: String;
    procedure setLockingMode(const Value: TLockMode);
    procedure setUniqFields(const Value: String);
    procedure OnNavigatorButtonClick(Sender: TObject; AButtonIndex: Integer; var ADone: Boolean);
  protected
    function GetNavigatorClass: TcxControlNavigatorClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    property DataSet: TDataSet read FDataSet;
    property KeyField: String read getIDField write setIDField;
    property ParentField: String read getParentField write setParentField;
    property RowStyleColumnIndex: Integer read getRowStyleColumnIndex;
    property ColumnStyleColumnIndex[const pColumn: String]: Integer read getColumnStyleColumnIndex;
  published
    property UniqFields: String read getUniqFields write setUniqFields;
    property LockingMode: TLockMode read getLockingMode write setLockingMode
      default TLockMode.lmNone;
  end;

  TORATreeListColumnProperties = class(TORAColumnProperties)
  private
    function getColumn: TcxDBTreeListColumn; inline;
    function getColumnOptions: TcxTreeListColumnOptions;
    function getSummary: TcxTreeListColumnSummary;
    function getStyles: TcxTreeListColumnStyles;
    function getSortIndex: Longint;
    procedure setSortIndex(const Value: Longint);
    function getSortOrder: TdxSortOrder;
    procedure setSortOrder(const Value: TdxSortOrder);
  protected
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getProperties: TcxCustomEditProperties; override;
    procedure SetPropertiesClass(Value: TcxCustomEditPropertiesClass); override;
    function getVisible: Boolean; override;
    procedure setVisible(const Value: Boolean); override;
    function getFieldName: String; override;
    procedure setFieldName(const Value: String); override;
    function getWidth: Integer; override;
    procedure setWidth(const Value: Integer); override;
    function getCaption: String; override;
    procedure setCaption(const Value: String); override;
  public
    property Column: TcxDBTreeListColumn read getColumn;
  published
    property SortIndex: Longint read getSortIndex write setSortIndex;
    property SortOrder: TdxSortOrder read getSortOrder write setSortOrder;
    property Options: TcxTreeListColumnOptions read getColumnOptions;
    property Summary: TcxTreeListColumnSummary read getSummary;
    property Styles: TcxTreeListColumnStyles read getStyles;
  end;

  TORATreeListProperties = class(TORAControlProperties)
  private
    FNewValue: Variant;
    function GetNavigator: TcxControlNavigator;
    function GetOptionsBehavior: TcxTreeListOptionsBehavior;
    function GetOptionsCustomize: TcxTreeListOptionsCustomizing;
    function GetOptionsData: TcxTreeListOptionsData;
    function GetOptionsSelection: TcxTreeListOptionsSelection;
    function GetOptionsView: TcxTreeListOptionsView;
    function getTORATreeList: TORATreeList; inline;
    function getKeyField: String; inline;
    procedure setKeyField(const Value: String); inline;
    procedure OnSelectionChanged(Sender: TObject);
    procedure OnFocusedNodeChanged(Sender: TcxCustomTreeList;
      APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    procedure DataSetNewRecordNotify(pDataSet: TDataSet);
    function getOnNewRecord: TDataSet;
    function getColumn(const pSubControlName: String): TcxDBTreeListColumn;
    function calcColumnValue(const pColumn: TcxDBTreeListColumn): String;
    procedure setColumnValue(const pColumn: TcxDBTreeListColumn; const pValue: String);
    function getLayoutColumns: TComponent; inline;
    function GetDataController: TcxDBTreeListDataController;
    function getParentField: String;
    procedure setParentField(const Value: String);
    function getStyles: TcxTreeListStyles;
    function getLockingMode: TLockMode;
    function getUniqFields: String;
    procedure setLockingMode(const Value: TLockMode);
    procedure setUniqFields(const Value: String);
    procedure OnTreeDblClick(Sender: TObject);
  protected
    function getDataSet: TDataSet; override;
    procedure initSourceData; override;
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
    function GetValue: String; override;
    procedure SetValue(const aValue: String); override;
    function GetSubControlCount: Integer; override;
    function GetSubControl(const pIndex: Integer): TComponent; override;
    function GetSubValue(const pSubControlName: String): String; override;
    procedure SetSubValue(const pSubControlName, Value: String); override;
    procedure OnPropertyChanged(const aPropertyRow: TcxPropertyRow); override;
    property NewValue: Variant read FNewValue write FNewValue;
    property Columns[const pSubControlName: String]: TcxDBTreeListColumn read getColumn;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
    procedure StoreToStream(const pWriter: TWriter); override;
    procedure RestoreFromStream(const pReader: TReader); override;
    function indexOfSubControl(const pSubControlName: String): Integer; override;
    property TreeList: TORATreeList read getTORATreeList;
  published
    property srcData: TDataSet read getDataSet;
    property ORALayoutColumns: TComponent read getLayoutColumns;
    property OptionsView: TcxTreeListOptionsView read GetOptionsView;
    property OptionsSelection: TcxTreeListOptionsSelection read GetOptionsSelection;
    property OnNewRecord: TDataSet read getOnNewRecord;
    property KeyField: String read getKeyField write setKeyField;
    property ParentField: String read getParentField write setParentField;
    property UniqFields: String read getUniqFields write setUniqFields;
    property LockingMode: TLockMode read getLockingMode write setLockingMode
      default TLockMode.lmNone;
    property DataController: TcxDBTreeListDataController read GetDataController;
    property Navigator: TcxControlNavigator read GetNavigator;
    property OptionsBehavior: TcxTreeListOptionsBehavior read GetOptionsBehavior;
    property OptionsCustomize: TcxTreeListOptionsCustomizing read GetOptionsCustomize;
    property OptionsData: TcxTreeListOptionsData read GetOptionsData;
    property Styles: TcxTreeListStyles read getStyles;
  end;

implementation

uses cxFilter, RTLConsts, Variants, cxClasses, ORALayoutGridEditor, StrUtils, forms, ORAStyles,
  ORALayout, ORALayoutGrid;

const
  cTreeListPropertyNames: array [0 .. 1] of String = ('srcSQL', 'OnNewRecord');

  { TORAtreeListProperties }

function TORATreeListProperties.getKeyField: String;
begin
  Result := TreeList.KeyField;
end;

function TORATreeListProperties.getLayoutColumns: TComponent;
begin
  Result := TreeList;
end;

function TORATreeListProperties.getLockingMode: TLockMode;
begin
  Result := TreeList.LockingMode;
end;

function TORATreeListProperties.GetNavigator: TcxControlNavigator;
begin
  Result := TreeList.Navigator;
end;

function TORATreeListProperties.getOnNewRecord: TDataSet;
begin
  Result := TreeList.FOnNewRecord;
end;

function TORATreeListProperties.GetOptionsBehavior: TcxTreeListOptionsBehavior;
begin
  Result := TreeList.OptionsBehavior;
end;

function TORATreeListProperties.GetOptionsCustomize: TcxTreeListOptionsCustomizing;
begin
  Result := TreeList.OptionsCustomizing;
end;

function TORATreeListProperties.GetOptionsData: TcxTreeListOptionsData;
begin
  Result := TreeList.OptionsData;
end;

function TORATreeListProperties.GetOptionsSelection: TcxTreeListOptionsSelection;
begin
  Result := TreeList.OptionsSelection;
end;

function TORATreeListProperties.GetOptionsView: TcxTreeListOptionsView;
begin
  Result := TreeList.OptionsView;
end;

function TORATreeListProperties.getTORATreeList: TORATreeList;
begin
  Result := TORATreeList(Component);
end;

function TORATreeListProperties.getUniqFields: String;
begin
  Result := TreeList.UniqFields;
end;

function TORATreeListProperties.getParentField: String;
begin
  Result := TreeList.ParentField;
end;

function TORATreeListProperties.getStoreProperty(const pName: String): Variant;
begin
  Result := Unassigned;
  case StorePropertyIndex[pName] of
    0: if srcData <> nil then Result := getLayoutInterface(srcData).SQL.Text;
    1: if OnNewRecord <> nil then Result := getLayoutInterface(OnNewRecord).SQL.Text;
  else inherited;
  end;
end;

function TORATreeListProperties.getStorePropertyCount: Longint;
begin
  Result := Length(cTreeListPropertyNames) + inherited;
end;

function TORATreeListProperties.getStorePropertyNames: PString;
begin
  Result := @cTreeListPropertyNames[0];
end;

function TORATreeListProperties.getStyles: TcxTreeListStyles;
begin
  Result := TreeList.Styles;
end;

function TORATreeListProperties.GetSubControl(const pIndex: Integer): TComponent;
begin
  Result := TreeList.Columns[pIndex];
end;

function TORATreeListProperties.GetSubControlCount: Integer;
begin
  Result := TreeList.ColumnCount;
end;

function TORATreeListProperties.GetSubValue(const pSubControlName: String): String;
begin
  Result := calcColumnValue(Columns[pSubControlName]);
end;

function TORATreeListProperties.GetValue: String;
begin
  if VarIsStr(NewValue) then Result := VarToStr(NewValue)
  else Result := calcColumnValue(TreeList.GetColumnByFieldName(KeyField));
end;

function TORATreeListProperties.indexOfSubControl(const pSubControlName: String): Integer;
var
  vCol: TcxDBTreeListColumn;
begin
  vCol := Columns[pSubControlName];
  if vCol <> nil then Result := vCol.Position.ColIndex
  else Result := -1;
end;

procedure TORATreeListProperties.initSourceData;
var
  I: Longint;
  vNeedFullExpand: Boolean;
begin
  vNeedFullExpand := not srcData.Active And Navigator.Visible And Navigator.Buttons.CustomButtons
    [0].Visible;

  inherited;
  with TreeList do
    for I := 0 to ColumnCount - 1 do
      with TORATreeListColumnProperties.Create(Columns[I], nil) do
        try
          initSourceData;
        finally
          Free;
        end;
  if vNeedFullExpand And srcData.Active then TreeList.FullExpand;
end;

procedure TORATreeListProperties.OnFocusedNodeChanged(Sender: TcxCustomTreeList;
  APrevFocusedNode, AFocusedNode: TcxTreeListNode);
begin
  if not VarIsStr(NewValue) And not OptionsSelection.MultiSelect And srcData.Active then
      Controller.OnEditValueChanged(self);
end;

procedure TORATreeListProperties.OnPropertyChanged(const aPropertyRow: TcxPropertyRow);
var
  vName: String;
begin
  vName := aPropertyRow.PropertyEditor.getName;
  if vName = 'srcData' then begin
    srcData.Active := False;
    srcData.Fields.Clear;
    initSourceData;
  end
  else if vName = 'IDField' then Controller.OnEditValueChanged(self);
  inherited;
end;

procedure TORATreeListProperties.OnSelectionChanged(Sender: TObject);
begin
  if not VarIsStr(NewValue) And OptionsSelection.MultiSelect then
      Controller.OnEditValueChanged(self);
end;

procedure TORATreeListProperties.OnTreeDblClick(Sender: TObject);
var
  AHandled: Boolean;
begin
  Controller.DblClickHandler(nil, AHandled);
end;

procedure TORATreeListProperties.RestoreFromStream(const pReader: TReader);
var
  I, vColCnt: Longint;

begin
  inherited;
  with pReader do begin
    with TreeList do
      try
        BeginUpdate;
        vColCnt := ReadInteger;
        for I := 0 to vColCnt - 1 do
          with TORATreeListColumnProperties.Create(CreateColumn(), nil) do
            try
              RestoreFromStream(pReader);
            finally
              Free;
            end;
      finally
        EndUpdate;
      end;
  end;
end;

procedure TORATreeListProperties.setColumnValue(const pColumn: TcxDBTreeListColumn;
  const pValue: String);
begin
  with TreeList do begin
    if SelectionCount > 1 then
        raise Exception.Create('Нельзя установить значение по нескольким строкам');
    if FocusedNode <> nil then begin
      if (SelectionCount = 1) And not FocusedNode.Selected then
          raise Exception.Create('Активная строка не совпадает с подсвеченной строкой');
      pColumn.EditValue := pValue;
    end
    else if pValue <> '' then raise Exception.Create('Отсутствует активная строка');
  end;
end;

procedure TORATreeListProperties.setKeyField(const Value: String);
begin
  if TreeList.KeyField = Value then exit;
  TreeList.KeyField := Value;
  Controller.OnEditValueChanged(self);
end;

procedure TORATreeListProperties.setLockingMode(const Value: TLockMode);
begin
  TreeList.LockingMode := Value;
end;

procedure TORATreeListProperties.setParentField(const Value: String);
begin
  TreeList.ParentField := Value;
end;

procedure TORATreeListProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  case StorePropertyIndex[pName] of
    0: if srcData <> nil then getLayoutInterface(srcData).SQL.Text := Value;
    1: if OnNewRecord <> nil then getLayoutInterface(OnNewRecord).SQL.Text := Value;
  else inherited;
  end;
end;

procedure TORATreeListProperties.SetSubValue(const pSubControlName, Value: String);
var
  vColumn: TcxDBTreeListColumn;
begin
  vColumn := Columns[pSubControlName];
  if vColumn <> nil then setColumnValue(vColumn, Value)
  else inherited;
end;

procedure TORATreeListProperties.setUniqFields(const Value: String);
begin
  TreeList.UniqFields := Value;
end;

procedure TORATreeListProperties.SetValue(const aValue: String);
const
  ftNumericTypes = [ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftAutoInc,
    ftLargeint, ftLongWord, ftShortInt, ftByte, ftExtended, ftSingle];

var
  vColumn: TcxDBTreeListColumn;
  vValues: String;
  vValue: String;
  I: Longint;

begin
  if VarIsStr(NewValue) then exit;
  if aValue = Value then exit;
  try
    NewValue := aValue;
    vColumn := TreeList.GetColumnByFieldName(KeyField);
    if OptionsSelection.MultiSelect And
      ((vColumn = nil) or (vColumn.DataBinding.Field.DataType in ftNumericTypes)) then begin
      with TreeList do begin
        ClearSelection;
        vValues := ',' + stringreplace(aValue, ' ', '', [rfReplaceAll]) + ',';
        for I := 0 to AbsoluteCount - 1 do begin
          if vColumn = nil then vValue := IntToStr(I)
          else vValue := VarToStr(AbsoluteItems[I].Values[vColumn.ItemIndex]);
          AbsoluteItems[I].Selected := AnsiPos(',' + vValue + ',', vValues) <> 0;
        end;
      end;
    end else begin
      with srcData do
        if Active then begin
          if KeyField <> '' then begin
            try
              Locate(KeyField, aValue, []);
            except
            end;
          end
          else if Value <> '' then RecNo := StrToInt(aValue);
        end;
    end;
  finally
    NewValue := Unassigned;
  end;
end;

procedure TORATreeListProperties.StoreToStream(const pWriter: TWriter);
var
  I: Longint;
begin
  inherited;
  with pWriter do begin
    IgnoreChildren := True;
    with TreeList do begin
      WriteInteger(ColumnCount);
      for I := 0 to ColumnCount - 1 do
        with TORATreeListColumnProperties.Create(Columns[I], nil) do
          try
            StoreToStream(pWriter);
          finally
            Free;
          end;
    end;
  end;
end;

{ TORATreeList }

constructor TORATreeList.Create(AOwner: TComponent);
begin
  inherited;
  FOnNewRecord := stdLayoutQuery(self);
  FOnNewRecord.name := 'OnNewRecord';
  FDataSet := stdLayoutQuery(self);
  with FDataSet, getLayoutInterface(FDataSet) do begin
    name := 'srcData';
    AfterPost := OnAfterPost;
    AfterDelete := OnAfterPost;
  end;
  Styles.OnGetContentStyle := GetContentStyle;
  with Navigator.Buttons do begin
    Images := HostInterface.LayoutImages;
    with CustomButtons.Add do begin
      ImageIndex := 36;
      Visible := False;
    end;
    with CustomButtons.Add do begin
      ImageIndex := 35;
      Visible := False;
    end;
    OnButtonClick := OnNavigatorButtonClick;
  end;
  with DataController do begin
    DataSource := TDataSource.Create(self);
    DataSource.DataSet := FDataSet;
    Filter.Options := [fcoCaseInsensitive];
  end;
  DragMode := dmAutomatic;
  OnDragOver := DragOverHandler;
end;

procedure TORATreeListProperties.DataSetNewRecordNotify(pDataSet: TDataSet);
var
  I: Longint;
  vParam: TParam;
begin
  with OnNewRecord, getLayoutInterface(self.OnNewRecord) do
    if SQL.Text <> '' then
      with Controller do begin
        doBeforeExecute(self.OnNewRecord);
        LayoutSession := Session;
        Execute;
        for I := 0 to srcData.FieldCount - 1 do
          with srcData.Fields[I] do begin
            vParam := Params.FindParam(FieldName);
            if vParam <> nil then AsString := vParam.AsString;
          end;
      end;
end;

procedure TORATreeList.GetContentStyle(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn;
  ANode: TcxTreeListNode; var AStyle: TcxStyle);
var
  vIndex: Longint;
begin
  if AColumn <> nil then begin
    vIndex := ColumnStyleColumnIndex[TcxDBTreeListColumn(AColumn).DataBinding.FieldName];
    if vIndex <> -1 then begin
      AStyle := LayoutStyles(VarToStr(ANode.Values[vIndex]));
      if AStyle <> nil then exit;
    end;
  end;
  vIndex := RowStyleColumnIndex;
  if vIndex = -1 then exit;
  AStyle := LayoutStyles(VarToStr(ANode.Values[vIndex]));
end;

procedure TORATreeList.DragOverHandler(Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := (Sender = Source) And (Source = self);
end;

function TORATreeList.getColumnStyleColumnIndex(const pColumn: String): Integer;
var
  vColumn: TcxDBTreeListColumn;
begin
  vColumn := GetColumnByFieldName(cColumnStylePrefix + pColumn);
  if vColumn = nil then Result := -1
  else Result := vColumn.ItemIndex;
end;

function TORATreeList.getIDField: String;
begin
  Result := DataController.KeyField;
end;

function TORATreeList.getLockingMode: TLockMode;
begin
  Result := getLayoutInterface(DataSet).LockMode;
end;

function TORATreeList.GetNavigatorClass: TcxControlNavigatorClass;
begin
  Result := TORAControlNavigator;
end;

function TORATreeList.getParentField: String;
begin
  Result := DataController.ParentField;
end;

function TORATreeList.getRowStyleColumnIndex: Integer;
var
  vColumn: TcxDBTreeListColumn;
begin
  vColumn := GetColumnByFieldName(cRowStyleField);
  if vColumn = nil then Result := -1
  else Result := vColumn.ItemIndex;
end;

function TORATreeList.getUniqFields: String;
begin
  Result := getLayoutInterface(DataSet).KeyFields;
end;

procedure TORATreeList.OnAfterPost(pDataSet: TDataSet);
var
  vBookmark: TBookmark;
begin
  with pDataSet do
    if Active then begin
      vBookmark := Bookmark;
      Refresh;
      if BookmarkValid(vBookmark) then Bookmark := vBookmark;
    end;
end;

procedure TORATreeList.OnNavigatorButtonClick(Sender: TObject; AButtonIndex: Integer;
  var ADone: Boolean);
begin
  case AButtonIndex of
    NBDI_REFRESH: begin
        OnAfterPost(DataSet);
        ADone := True;
      end;
    NavigatorButtonCount: begin
        FullExpand;
        ADone := True;
      end;
    NavigatorButtonCount + 1: begin
        FullCollapse;
        ADone := True;
      end;
  end;
end;

procedure TORATreeList.setIDField(const Value: String);
begin
  DataController.KeyField := Value;
end;

procedure TORATreeList.setLockingMode(const Value: TLockMode);
begin
  getLayoutInterface(DataSet).LockMode := Value;
end;

procedure TORATreeList.setParentField(const Value: String);
begin
  DataController.ParentField := Value;
end;

procedure TORATreeList.setUniqFields(const Value: String);
begin
  getLayoutInterface(DataSet).KeyFields := Value;
end;

function TORATreeListProperties.calcColumnValue(const pColumn: TcxDBTreeListColumn): String;
var
  I: Longint;
  procedure add_result(ANode: TcxTreeListNode);
  var
    vVal: String;
  begin
    if ANode <> nil then begin
      if pColumn <> nil then vVal := VarToStr(ANode.Values[pColumn.ItemIndex])
      else vVal := IntToStr(ANode.AbsoluteIndex);
      if Result = '' then Result := vVal
      else Result := Result + ',' + vVal;
    end;
  end;

begin
  Result := '';
  with TreeList do
    if SelectionCount > 0 then
      for I := 0 to SelectionCount - 1 do add_result(Selections[I])
    else add_result(FocusedNode)
end;

constructor TORATreeListProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;
  NewValue := Unassigned;
  if AController <> nil then begin
    TreeList.OnSelectionChanged := OnSelectionChanged;
    TreeList.OnFocusedNodeChanged := OnFocusedNodeChanged;
    TreeList.OnDblClick := OnTreeDblClick;
    srcData.OnNewRecord := DataSetNewRecordNotify;
  end;
end;

function TORATreeListProperties.getColumn(const pSubControlName: String): TcxDBTreeListColumn;
var
  I: Integer;
begin
  with TreeList do
    for I := 0 to ColumnCount - 1 do begin
      Result := TcxDBTreeListColumn(Columns[I]);
      if AnsiSameText(Result.name, pSubControlName) then exit;
    end;
  Result := nil;
end;

function TORATreeListProperties.GetDataController: TcxDBTreeListDataController;
begin
  Result := TreeList.DataController;
end;

function TORATreeListProperties.getDataSet: TDataSet;
begin
  Result := TreeList.FDataSet;
end;

{ TORATableProperty }

{
  procedure TORATableProperty.Edit;
  var
  vPersistent: TPersistent;
  begin
  vPersistent := TPersistent(GetOrdValue);
  if vPersistent is TORATreeList then
  showViewColumns(TcxCustomGridTableView(TORATreeList(vPersistent).Views[0]),
  TfrmORALayoutCustomize(getOwnerByClass(Inspector, TfrmORALayoutCustomize)));
  end;

  function TORATableProperty.GetAttributes: TcxPropertyAttributes;
  begin
  Result := [ipaDialog, ipaReadOnly];
  end;
}

{ TORATreeListColumnProperties }

function TORATreeListColumnProperties.getCaption: String;
begin
  Result := Column.Caption.Text;
end;

function TORATreeListColumnProperties.getColumn: TcxDBTreeListColumn;
begin
  Result := TcxDBTreeListColumn(Component);
end;

function TORATreeListColumnProperties.getColumnOptions: TcxTreeListColumnOptions;
begin
  Result := Column.Options;
end;

function TORATreeListColumnProperties.getSortIndex: Longint;
begin
  Result := Column.SortIndex;
end;

function TORATreeListColumnProperties.getSortOrder: TdxSortOrder;
begin
  Result := Column.SortOrder;
end;

function TORATreeListColumnProperties.getStoreProperty(const pName: String): Variant;
begin
  if pName = 'Styles' then Result := styles2string(Styles)
  else Result := inherited;
end;

function TORATreeListColumnProperties.getStyles: TcxTreeListColumnStyles;
begin
  Result := Column.Styles;
end;

function TORATreeListColumnProperties.getSummary: TcxTreeListColumnSummary;
begin
  Result := Column.Summary;
end;

function TORATreeListColumnProperties.getVisible: Boolean;
begin
  Result := Column.Visible;
end;

function TORATreeListColumnProperties.getWidth: Integer;
begin
  Result := Column.Width;
end;

procedure TORATreeListColumnProperties.setCaption(const Value: String);
begin
  Column.Caption.Text := Value;
end;

procedure TORATreeListColumnProperties.setSortIndex(const Value: Longint);
begin
  Column.SortIndex := Value;
end;

procedure TORATreeListColumnProperties.setSortOrder(const Value: TdxSortOrder);
begin
  Column.SortOrder := Value;
end;

procedure TORATreeListColumnProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  if pName = 'Styles' then string2styles(Styles, Value)
  else inherited;
end;

procedure TORATreeListColumnProperties.setVisible(const Value: Boolean);
begin
  Column.Visible := Value;
end;

procedure TORATreeListColumnProperties.setWidth(const Value: Integer);
begin
  Column.Width := Value;
end;

function TORATreeListColumnProperties.getFieldName: String;
begin
  Result := Column.DataBinding.FieldName;
end;

function TORATreeListColumnProperties.getProperties: TcxCustomEditProperties;
begin
  Result := Column.Properties;
end;

procedure TORATreeListColumnProperties.setFieldName(const Value: String);
begin
  Column.DataBinding.FieldName := Value;
end;

procedure TORATreeListColumnProperties.SetPropertiesClass(Value: TcxCustomEditPropertiesClass);
begin
  inherited;
  Column.PropertiesClass := Value;
end;

initialization

register_ORADataType('Иерархия БД', TORATreeListProperties, TORATreeList);
register_ORADataType('Иерархичная колонка', TORATreeListColumnProperties, TcxDBTreeListColumn);

// cxRegisterPropertyEditor(TypeInfo(TcxTreeListColumn), nil, '', TORAColumnProperty);

end.
