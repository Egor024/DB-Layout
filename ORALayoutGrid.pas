unit ORALayoutGrid;

interface

uses TypInfo, Classes, SysUtils, cxOI, cxGrid, cxGridDBDataDefinitions, cxGridCustomTableView,
  Controls, cxCheckBox, cxDBLookupComboBox, cxButtonEdit, ORALayoutColumnEdit, dxLayoutContainer,
  cxEdit, cxGridTableView, cxGridDBTableView, ORALayoutCustomize, DB, cxGridCustomView,
  LayoutThreads, cxTextEdit, cxCurrencyEdit, cxCalendar, cxStyles, dxCore, cxCustomData,
  cxNavigator, cxControls, ORANavigators, LayoutData;

type
  TORADataSummaryItem = class(TcxGridDBTableSummaryItem)
  public
    function FormatValue(const AValue: Variant; AIsFooter: Boolean): string; override;
  end;

  TORADataSummary = class(TcxDataSummary)
  protected
    procedure EndCalculateSummary(ASummaryItems: TcxDataSummaryItems;
      var ACountValues: TcxDataSummaryCountValues; var ASummaryValues: TcxDataSummaryValues;
      var SummaryValues: Variant); override;
  end;

  TORAColumnSummary = class(TcxGridColumnSummary)
  private
    FWeightColumn: String;
  published
    property WeightColumn: String read FWeightColumn write FWeightColumn;
  end;

  TORATableColumn = class(TcxGridDBColumn)
  private
    function getStringStyles: String;
    procedure setStringStyles(const Value: String);
    function getWeightColumn: TORATableColumn;
  public
    function GetSummaryClass: TcxGridColumnSummaryClass; override;
    property WeightColumn: TORATableColumn read getWeightColumn;
  published
    property StringStyles: String read getStringStyles write setStringStyles;
  end;

  TORADataController = class(TcxGridDBDataController)
  protected
    function GetSummaryClass: TcxDataSummaryClass; override;
    function GetSummaryItemClass: TcxDataSummaryItemClass; override;
  end;

  TORATableView = class(TcxGridDBTableView)
  protected
    function GetNavigatorClass: TcxGridViewNavigatorClass; override;
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
  public
    function GetItemClass: TcxCustomGridTableItemClass; override;
  end;

  TORATable = class(TcxGrid)
  private
    FNewValue: Variant;
    FChanging: Boolean;
    FInAfterPost: Boolean;
    FThread: TLayoutQueryThread;
    FThreadTerminated: Boolean;
    FThreaded: Boolean;
    FDataSet: TDataSet;
    FOnNewRecord: TDataSet;
    FOnColumnChanged: TDataSet;
    FOnDblClick: TDataSet;
    FIDField: String;
    // function getDataController: TcxGridDBDataController;
    procedure OnAfterPost(pDataSet: TDataSet);
    procedure OnNavigatorButtonClick(Sender: TObject; AButtonIndex: Integer; var ADone: Boolean);
    procedure doCalcSummary(ASender: TcxDataSummaryItems; Arguments: TcxSummaryEventArguments;
      var OutArguments: TcxSummaryEventOutArguments);
    function getUniqFields: String;
    procedure setUniqFields(const Value: String);
    function getLockingMode: TLockMode;
    procedure setLockingMode(const Value: TLockMode);
    procedure GetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    function getRowStyleColumnIndex: Integer;
    function getColumnStyleColumnIndex(const pColumn: String): Integer;
    function getItemsList: String;
    procedure setItemsList(const Value: String);
  protected
    property NewValue: Variant read FNewValue write FNewValue;
    function GetDefaultViewClass: TcxCustomGridViewClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // property DataController: TcxGridDBDataController read getDataController;
    property DataSet: TDataSet read FDataSet;
    property IDField: String read FIDField write FIDField;
  published
    property UniqFields: String read getUniqFields write setUniqFields;
    property LockingMode: TLockMode read getLockingMode write setLockingMode
      default TLockMode.lmNone;
    property Threaded: Boolean read FThreaded write FThreaded default False;
    property ItemsList: String read getItemsList write setItemsList;
  end;

  TORATableItemProperties = class(TORAColumnProperties)
  private
    function getColumn: TcxCustomGridTableItem; inline;
    function getColumnOptions: TcxCustomGridTableItemOptions;
    function getStyles: TcxCustomGridTableItemStyles;
    function getGroupIndex: Longint;
    function getSortIndex: Longint;
    procedure setGroupIndex(const Value: Longint);
    procedure setSortIndex(const Value: Longint);
    function getSortOrder: TdxSortOrder;
    procedure setSortOrder(const Value: TdxSortOrder);
  protected
    function getLayoutItem: TdxCustomLayoutItem; override;
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
    property Column: TcxCustomGridTableItem read getColumn;
  published
    property SortIndex: Longint read getSortIndex write setSortIndex;
    property SortOrder: TdxSortOrder read getSortOrder write setSortOrder;
    property GroupIndex: Longint read getGroupIndex write setGroupIndex;
    property Options: TcxCustomGridTableItemOptions read getColumnOptions;
    property Styles: TcxCustomGridTableItemStyles read getStyles;
  end;

  TORATableColumnProperties = class(TORATableItemProperties)
  private
    function getColumn: TORATableColumn; inline;
    function getSummary: TcxGridColumnSummary;
  protected
  public
    procedure RestoreFromStream(const pReader: TReader); override;
    property Column: TORATableColumn read getColumn;
  published
    property SortIndex;
    property SortOrder;
    property GroupIndex;
    property Options;
    property Summary: TcxGridColumnSummary read getSummary;
    property Styles;
  end;

  TORAGridProperties = class(TORAControlProperties)
  private
    function getFilterBox: TcxGridFilterBox;
    function GetNavigator: TcxGridViewNavigator;
    function GetOptionsBehavior: TcxCustomGridTableOptionsBehavior;
    function GetOptionsCustomize: TcxCustomGridTableOptionsCustomize;
    function GetOptionsData: TcxCustomGridTableOptionsData;
    function GetOptionsSelection: TcxCustomGridTableOptionsSelection;
    function GetOptionsView: TcxCustomGridTableOptionsView;
    function getView: TcxCustomGridTableView;
    function getORATable: TORATable; inline;
    function getIDField: String; inline;
    procedure setIDField(const Value: String);
    procedure OnThreadTerminate(AThread: TObject);
    procedure OnSelectionChanged(Sender: TcxCustomGridTableView);
    procedure OnFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure DataSetNewRecordNotify(pDataSet: TDataSet);
    function getOnNewRecord: TDataSet;
    function getColumn(const pSubControlName: String): TcxCustomGridTableItem;
    function calcColumnValue(const pColumn: TcxCustomGridTableItem;
      const pAddQuote: Boolean = False): String;
    procedure setColumnValue(const pColumn: TcxCustomGridTableItem; const pValue: String);
    function getLayoutColumns: TComponent; inline;
    function getStyles: TcxCustomGridTableViewStyles;
    function getUpdatingTable: String;
    procedure setUpdatingTable(const Value: String);
    function getDataController: TcxGridDBDataController;
    procedure OnGridCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState;
      var AHandled: Boolean);
    procedure OnColumnValueChanged(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
    function getOnColumnChanged: TDataSet;
    function getUniqFields: String;
    procedure setUniqFields(const Value: String);
    function getLockingMode: TLockMode;
    procedure setLockingMode(const Value: TLockMode);
    function getOnDblClick: TDataSet;
    function getGridLockedStateImageOptions: TcxGridLockedStateImageOptions;
    function getThreaded: Boolean;
    procedure setThreaded(const Value: Boolean);
    procedure initColumnsSource;
    function getViewName: String;
    procedure setViewName(const Value: String);
  protected
    function getDataSet: TDataSet; override;
    procedure initSourceData; override;
    procedure beforeOpenData; override;
    procedure afterOpenData; override;
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
    function GetValue: String; override;
    procedure SetValue(const AValue: String); override;
    function GetSubControlCount: Integer; override;
    function GetSubControl(const pIndex: Integer): TComponent; override;
    function GetSubValue(const pSubControlName: String): String; override;
    procedure SetSubValue(const pSubControlName, Value: String); override;
    procedure OnPropertyChanged(const aPropertyRow: TcxPropertyRow); override;
    property Columns[const pSubControlName: String]: TcxCustomGridTableItem read getColumn;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
    procedure StoreToStream(const pWriter: TWriter); override;
    procedure RestoreFromStream(const pReader: TReader); override;
    function indexOfSubControl(const pSubControlName: String): Integer; override;
    property View: TcxCustomGridTableView read getView;
    property ORATable: TORATable read getORATable;
  published
    property srcData: TDataSet read getDataSet;
    property ORALayoutColumns: TComponent read getLayoutColumns;
    property OptionsView: TcxCustomGridTableOptionsView read GetOptionsView;
    property OptionsSelection: TcxCustomGridTableOptionsSelection read GetOptionsSelection;
    property Navigator: TcxGridViewNavigator read GetNavigator;
    property IDField: String read getIDField write setIDField;
    property UpdatingTable: String read getUpdatingTable write setUpdatingTable;
    property UniqFields: String read getUniqFields write setUniqFields;
    property OnNewRecord: TDataSet read getOnNewRecord;
    property OnColumnChanged: TDataSet read getOnColumnChanged;
    property OnDblClick: TDataSet read getOnDblClick;
    property LockingMode: TLockMode read getLockingMode write setLockingMode
      default TLockMode.lmNone;
    property TableViewName: String read getViewName write setViewName;
    property DataController: TcxGridDBDataController read getDataController;
    property FilterBox: TcxGridFilterBox read getFilterBox;
    property OptionsBehavior: TcxCustomGridTableOptionsBehavior read GetOptionsBehavior;
    property OptionsCustomize: TcxCustomGridTableOptionsCustomize read GetOptionsCustomize;
    property OptionsData: TcxCustomGridTableOptionsData read GetOptionsData;
    property Styles: TcxCustomGridTableViewStyles read getStyles;
    property LockedStateImageOptions: TcxGridLockedStateImageOptions
      read getGridLockedStateImageOptions;
    property Threaded: Boolean read getThreaded write setThreaded default False;
  end;

  TORAGridTableProperties = class(TORAGridProperties)

  end;

implementation

uses cxFilter, Utilities, Variants, cxClasses, ORALayoutGridEditor, Clipbrd,
  forms, ORAStyles, ORALayout;

const
  cTablePropertyNames: array [0 .. 6] of String = ('srcSQL', 'IDField', 'OnNewRecord',
    'UpdatingTable', 'OnColumnChanged', 'OnDblClick', 'Styles');

  { TORAGridTableProperties }

function TORAGridProperties.getFilterBox: TcxGridFilterBox;
begin
  Result := View.FilterBox;
end;

function TORAGridProperties.getGridLockedStateImageOptions: TcxGridLockedStateImageOptions;
begin
  Result := ORATable.LockedStateImageOptions;
end;

function TORAGridProperties.getIDField: String;
begin
  Result := ORATable.IDField;
end;

function TORATable.getItemsList: String;
var
  I: Integer;
begin
  Result := '';
  if ((ComponentState * [csReading, csWriting]) = []) and (Views[0] is TcxCustomGridTableView) then
    with TcxCustomGridTableView(Views[0]) do begin
      for I := 0 to ItemCount - 1 do
          Result := ifThen(Result = '', '', Result + ';') + ifThen(Items[I].Visible, '1', '0') +
          TcxGridItemDBDataBinding(Items[I].DataBinding).FieldName;
    end;
end;

function TORAGridProperties.getLayoutColumns: TComponent;
begin
  Result := View;
end;

function TORAGridProperties.getLockingMode: TLockMode;
begin
  Result := ORATable.LockingMode;
end;

function TORAGridProperties.GetNavigator: TcxGridViewNavigator;
begin
  Result := View.Navigator;
end;

function TORAGridProperties.getOnColumnChanged: TDataSet;
begin
  Result := ORATable.FOnColumnChanged;
end;

function TORAGridProperties.getOnDblClick: TDataSet;
begin
  Result := ORATable.FOnDblClick;
end;

function TORAGridProperties.getOnNewRecord: TDataSet;
begin
  Result := ORATable.FOnNewRecord;
end;

function TORAGridProperties.GetOptionsBehavior: TcxCustomGridTableOptionsBehavior;
begin
  Result := View.OptionsBehavior;
end;

function TORAGridProperties.GetOptionsCustomize: TcxCustomGridTableOptionsCustomize;
begin
  Result := View.OptionsCustomize;
end;

function TORAGridProperties.GetOptionsData: TcxCustomGridTableOptionsData;
begin
  Result := View.OptionsData;
end;

function TORAGridProperties.GetOptionsSelection: TcxCustomGridTableOptionsSelection;
begin
  Result := View.OptionsSelection;
end;

function TORAGridProperties.GetOptionsView: TcxCustomGridTableOptionsView;
begin
  Result := View.OptionsView;
end;

function TORAGridProperties.getORATable: TORATable;
begin
  Result := TORATable(Component);
end;

function TORAGridProperties.getStoreProperty(const pName: String): Variant;
begin
  Result := Unassigned;
  case StorePropertyIndex[pName] of
    0: if srcData <> nil then Result := getLayoutInterface(srcData).SQL.Text;
    1: Result := IDField;
    2: if OnNewRecord <> nil then Result := getLayoutInterface(OnNewRecord).SQL.Text;
    3: Result := UpdatingTable;
    4: if OnColumnChanged <> nil then Result := getLayoutInterface(OnColumnChanged).SQL.Text;
    5: if OnDblClick <> nil then Result := getLayoutInterface(OnDblClick).SQL.Text;
    6: Result := styles2string(Styles);
  else inherited;
  end;
end;

function TORAGridProperties.getStorePropertyCount: Longint;
begin
  Result := Length(cTablePropertyNames) + inherited;
end;

function TORAGridProperties.getStorePropertyNames: PString;
begin
  Result := @cTablePropertyNames[0];
end;

function TORAGridProperties.getStyles: TcxCustomGridTableViewStyles;
begin
  Result := View.Styles;
end;

function TORAGridProperties.GetSubControl(const pIndex: Integer): TComponent;
begin
  Result := View.Items[pIndex];
end;

function TORAGridProperties.GetSubControlCount: Integer;
begin
  Result := View.ItemCount;
end;

function TORAGridProperties.GetSubValue(const pSubControlName: String): String;
begin
  Result := calcColumnValue(Columns[pSubControlName]);
end;

function TORAGridProperties.getThreaded: Boolean;
begin
  Result := ORATable.FThreaded;
end;

function TORAGridProperties.getUniqFields: String;
begin
  Result := ORATable.UniqFields;
end;

function TORAGridProperties.getUpdatingTable: String;
begin
  Result := getLayoutInterface(srcData).UpdatingTable
end;

function TORAGridProperties.GetValue: String;
var
  vCol: TcxCustomGridTableItem;
begin
  if VarIsStr(ORATable.NewValue) then Result := VarToStr(ORATable.NewValue)
  else begin
    vCol := DataController.GetItemByFieldName(IDField);
    Result := calcColumnValue(vCol);
    // , (vCol <> nil) And (vCol.DataBinding.Field is TStringField));
  end;
end;

function TORAGridProperties.getView: TcxCustomGridTableView;
begin
  if (ORATable.Views[0] is TcxCustomGridTableView) then
      Result := TcxCustomGridTableView(ORATable.Views[0])
  else Result := nil;
end;

function TORAGridProperties.getViewName: String;
begin
  Result := View.Name;
end;

function TORAGridProperties.indexOfSubControl(const pSubControlName: String): Integer;
var
  vCol: TcxCustomGridTableItem;
begin
  vCol := Columns[pSubControlName];
  if vCol <> nil then Result := vCol.Index
  else Result := -1;
end;

procedure TORAGridProperties.OnThreadTerminate(AThread: TObject);
begin
  if AThread = ORATable.FThread then
    with ORATable.FThread do begin
      with srcData, getLayoutInterface(srcData) do begin
        if Active And not Fetched then Close;
        ReadOnly := FindField('ROWID') = nil;
      end;
      DataController.DataSource.DataSet := srcData;
      afterOpenData;
      ORATable.FThreadTerminated := ORATable.FThread.Terminated;
      ORATable.FThread := nil;
      ORATable.NewValue := Unassigned;
      initColumnsSource;
    end;
end;

procedure TORAGridProperties.initColumnsSource;
var
  I: Longint;
begin
  with View do
    for I := 0 to ItemCount - 1 do
      with TORATableColumnProperties.Create(Items[I], nil) do
        try
          initSourceData;
        finally
          Free;
        end;
end;

procedure TORAGridProperties.initSourceData;
begin
  if Threaded then begin
    if startInitSourceData then
      try
        if not VarIsStr(ORATable.NewValue) And
          ((ORATable.FThread = nil) or (ORATable.FThread.Terminated)) And
          (Controller.doBeforeExecute(srcData) or
          (not srcData.Active And not ORATable.FThreadTerminated)) then begin
          ORATable.FThread.Free;
          ORATable.FThreadTerminated := False;
          ORATable.FThread := TLayoutQueryThread.Create(True);
          with ORATable.FThread do
            try
              ORATable.NewValue := Value;
              DataController.DataSource.DataSet := nil;
              beforeOpenData;
              with srcData, getLayoutInterface(srcData) do begin
                if Active then Close;
                if (LayoutSession = Controller.Session) or (LayoutSession = nil) then
                    LayoutSession := mainSession.clone;
              end;
              Query := srcData;
              OnTerminate := OnThreadTerminate;
              FetchAllRecords := True;
              SaveSessionOnExit := True;
              SaveQueryOnExit := True;
              FreeOnTerminate := True;
              Start;
            except
              OnThreadTerminate(ORATable.FThread);
              ORATable.NewValue := Unassigned;
              Free;
            end;
        end;
      finally
        endInitSourceData;
      end;
  end else begin
    inherited initSourceData;
    initColumnsSource;
  end;
end;

procedure TORAGridProperties.OnColumnValueChanged(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem);
begin
  if AItem = Sender.Controller.EditingItem then
      AItem.EditValue := Sender.Controller.EditingController.Edit.EditValue;
  if not ORATable.FChanging then
    try
      ORATable.FChanging := True;
      with getLayoutInterface(OnColumnChanged) do
        if SQL.Text <> '' then
          with Controller do begin
            ControlCollection.Values['CHANGED_COLUMN'] := AItem.Name;
            doBeforeExecute(OnColumnChanged);
            LayoutSession := Session;
            Execute;
            doAfterExecute(OnColumnChanged);
            if ControlCollection.Values['CHANGED_COLUMN'] = '' then begin
              Sender.DataController.Cancel;
              ORATable.OnAfterPost(srcData);
            end
            else Sender.DataController.Post;
          end;
    finally
      ORATable.FChanging := False;
    end;
end;

procedure TORAGridProperties.OnFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  if not VarIsStr(ORATable.NewValue) And not View.OptionsSelection.MultiSelect And
    srcData.Active then Controller.OnEditValueChanged(self);
end;

procedure TORAGridProperties.OnPropertyChanged(const aPropertyRow: TcxPropertyRow);
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

procedure TORAGridProperties.OnSelectionChanged(Sender: TcxCustomGridTableView);
begin
  if not VarIsStr(ORATable.NewValue) And View.OptionsSelection.MultiSelect then
      Controller.OnEditValueChanged(self);
end;

procedure TORAGridProperties.RestoreFromStream(const pReader: TReader);
var
  I, vColCnt: Longint;
  vPosSave1, vPosSave2: Longint;
  CC: ^TCursor;
  vItem: TComponent;

begin
  inherited;
  with pReader do begin
    vPosSave1 := Position;
    ReadRootComponent(View);
    with View do
      try
        BeginSortingUpdate;
        vColCnt := ReadInteger;
        for I := 0 to vColCnt - 1 do begin
          vItem := CreateItem();
          with getORAComponentPropertiesClass(TComponentClass(vItem.ClassType))
            .Create(vItem, nil) do
            try
              RestoreFromStream(pReader);
            finally
              Free;
            end;
        end;
      finally
        // Я так и не понял, почему иногда Screen.Cursor:=0 внутри EndSortingUpdate выдает exception
        // поэтому восстанавливаю курсор руками
        CC := @Screen.Cursor;
        CC^ := 0;
        // GetCursorPos(P);
        // Handle := WindowFromPoint(P);
        // Debug_putline('3'+IntToStr(Screen.Cursor));
        // if (Handle <> 0) and
        // (GetWindowThreadProcessId(Handle, nil) = GetCurrentThreadId) then
        // begin
        // Code := SendMessage(Handle, WM_NCHITTEST, 0, PointToLParam(P));
        // SendMessage(Handle, WM_SETCURSOR, Handle, MakeLong(Code, WM_MOUSEMOVE));
        // end;
        EndSortingUpdate;
      end;
    vPosSave2 := Position;
    Position := vPosSave1;
    ReadRootComponent(View);
    Position := vPosSave2;
  end;
end;

procedure TORAGridProperties.setColumnValue(const pColumn: TcxCustomGridTableItem;
  const pValue: String);
begin
  if View.DataController.RecordCount = 0 then exit;
  with View.Controller do begin
    if SelectedRecordCount > 1 then
        raise Exception.Create('Нельзя установить значение по нескольким строкам');
    if FocusedRecord <> nil then begin
      if (SelectedRecordCount = 1) And (SelectedRecords[0].Index <> FocusedRecord.Index) then
          raise Exception.Create('Активная строка не совпадает с подсвеченной строкой');
      if VarToStr(pColumn.EditValue) <> pValue then begin
        pColumn.EditValue := pValue;
        OnColumnValueChanged(View, pColumn);
      end;
    end
    else if pValue <> '' then raise Exception.Create('Отсутствует активная строка');
  end;
end;

procedure TORAGridProperties.setIDField(const Value: String);
begin
  if ORATable.IDField = Value then exit;
  ORATable.IDField := Value;
  Controller.OnEditValueChanged(self);
end;

procedure TORATable.setItemsList(const Value: String);
var
  ndx, I: Longint;
  vis: Boolean;
  vColumn: TcxCustomGridTableItem;
begin
  if ComponentState * [csReading, csWriting] = [] then
    with TStringList.Create do
      try
        Text := StringReplace(Value, ';', #13#10, [rfReplaceAll]);
        ndx := 0;
        for I := 0 to Count - 1 do begin
          vis := Strings[I][1] = '1';
          vColumn := TcxGridDBDataController(ActiveView.DataController)
            .GetItemByFieldName(Copy(Strings[I], 2, 500));
          if vColumn <> nil then begin
            vColumn.Index := ndx;
            vColumn.Visible := vis;
            ndx := ndx + 1;
          end;
        end;
      finally
        Free;
      end;
end;

procedure TORAGridProperties.setLockingMode(const Value: TLockMode);
begin
  ORATable.LockingMode := Value;
end;

procedure TORAGridProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  case StorePropertyIndex[pName] of
    0: if srcData <> nil then getLayoutInterface(srcData).SQL.Text := Value;
    1: IDField := Value;
    2: if OnNewRecord <> nil then getLayoutInterface(OnNewRecord).SQL.Text := Value;
    3: UpdatingTable := Value;
    4: if OnColumnChanged <> nil then getLayoutInterface(OnColumnChanged).SQL.Text := Value;
    5: if OnDblClick <> nil then getLayoutInterface(OnDblClick).SQL.Text := Value;
    6: string2styles(Styles, Value);
  else inherited;
  end;
end;

procedure TORAGridProperties.SetSubValue(const pSubControlName, Value: String);
var
  vColumn: TcxCustomGridTableItem;
begin
  if getLayoutInterface(srcData).ReadOnly then exit;
  vColumn := Columns[pSubControlName];
  if vColumn <> nil then setColumnValue(vColumn, Value)
  else inherited;
end;

procedure TORAGridProperties.setThreaded(const Value: Boolean);
var
  vSess: TComponent;
begin
  with ORATable, DataSet, getLayoutInterface(DataSet) do
    if FThreaded <> Value then begin
      if FThread.IndexOf <> -1 then
        with FThread do begin
          Terminate;
          while FThread <> nil do Application.ProcessMessages;
        end;
      FThreaded := Value;
      vSess := LayoutSession;
      Close;
      Fields.Clear;
      LayoutSession := nil;
      if vSess <> self.Controller.Session then vSess.Free;
      initSourceData;
    end;
end;

procedure TORAGridProperties.setUniqFields(const Value: String);
begin
  ORATable.UniqFields := Value;
end;

procedure TORAGridProperties.setUpdatingTable(const Value: String);
begin
  getLayoutInterface(srcData).UpdatingTable := Value;
end;

type
  TDataSetAccess = class(TDataSet);

procedure TORAGridProperties.SetValue(const AValue: String);
const
  ftNumericTypes = [ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftAutoInc,
    ftLargeint, ftLongWord, ftShortInt, ftByte, ftExtended, ftSingle];

var
  vColumn: TcxCustomGridTableItem;
  vValues: String;
  vValue: String;
  I, vFocus: Longint;

begin
  if VarIsStr(ORATable.NewValue) then exit;
  if AValue = Value then exit;
  try
    ORATable.NewValue := AValue;
    if AValue = '' then begin
      try
        with TDataSetAccess(ORATable.DataSet) do
          if Active then SetCurrentRecord(-1);
      except
      end;
      exit;
    end;

    vColumn := DataController.GetItemByFieldName(IDField);
    if View.OptionsSelection.MultiSelect And
      ((vColumn = nil) or (TcxGridItemDBDataBinding(vColumn.DataBinding).Field.DataType
      in ftNumericTypes)) then begin
      with View, ViewData do begin
        Controller.ClearSelection;
        vValues := ',' + StringReplace(AValue, ' ', '', [rfReplaceAll]) + ',';
        vFocus := -1;
        for I := 0 to RecordCount - 1 do begin
          if vColumn = nil then vValue := IntToStr(I)
          else vValue := VarToStr(Records[I].Values[vColumn.Index]);
          with Records[I] do begin
            Selected := AnsiPos(',' + vValue + ',', vValues) <> 0;
            if Selected then begin
              if vFocus = -1 then vFocus := I
              else vFocus := -2;
            end;
          end;
        end;
        if vFocus >= 0 then Controller.FocusedRecordIndex := vFocus;
      end;
    end else begin
      with ORATable.DataSet do
        if Active then begin
          if IDField <> '' then begin
            try
              Locate(IDField, AnsiString(AValue), []);
            except
            end;
          end
          else if Value <> '' then RecNo := StrToInt(AValue);
        end;
    end;
  finally
    ORATable.NewValue := Unassigned;
  end;
end;

procedure TORAGridProperties.setViewName(const Value: String);
begin
  View.Name := Value;
end;

procedure TORAGridProperties.StoreToStream(const pWriter: TWriter);
var
  I: Longint;
begin
  inherited;
  with pWriter do begin
    IgnoreChildren := True;
    WriteRootComponent(View);
    with View do begin
      WriteInteger(ItemCount);
      for I := 0 to ItemCount - 1 do
        with TORATableColumnProperties.Create(Items[I], nil) do
          try
            StoreToStream(pWriter);
          finally
            Free;
          end;
    end;
  end;
end;

{ TORATable }

constructor TORATable.Create(AOwner: TComponent);
begin
  inherited;
  FChanging := False;
  FInAfterPost := False;
  FThread := nil;
  FThreadTerminated := False;
  NewValue := Unassigned;
  FOnNewRecord := stdLayoutQuery(self);
  FOnNewRecord.Name := 'OnNewRecord';
  FOnColumnChanged := stdLayoutQuery(self);
  FOnColumnChanged.Name := 'OnColumnChanged';
  FOnDblClick := stdLayoutQuery(self);
  FOnDblClick.Name := 'OnDblClick';
  FDataSet := stdLayoutQuery(self);
  with FDataSet, getLayoutInterface(FDataSet) do begin
    name := 'srcData';
    AutoCommit := True;
    AfterPost := OnAfterPost;
    AfterDelete := OnAfterPost;
  end;
  Levels.Add.GridView := CreateView(GetDefaultViewClass);
  if ActiveView is TcxCustomGridTableView then
    with TcxCustomGridTableView(ActiveView) do begin
      name := CreateUniqueName(nil, nil, ActiveView, '', '');

      Styles.OnGetContentStyle := GetContentStyle;

      with FindPanel do begin
        DisplayMode := fpdmManual;
        UseExtendedSyntax := True;
      end;

      with Navigator.Buttons do begin
        Images := HostInterface.LayoutImages;
        with CustomButtons.Add do begin
          ImageIndex := 90;
          Visible := False;
        end;
        OnButtonClick := OnNavigatorButtonClick;
      end;
    end;
  if ActiveView.DataController is TcxGridDBDataController then
    with TcxGridDBDataController(ActiveView.DataController) do begin
      DataSource := TDataSource.Create(self);
      DataSource.DataSet := FDataSet;
      Filter.Options := [fcoCaseInsensitive];
      with Summary do begin
        FooterSummaryItems.OnSummary := doCalcSummary;
        DefaultGroupSummaryItems.OnSummary := doCalcSummary;
      end;
    end;
end;

procedure TORAGridProperties.DataSetNewRecordNotify(pDataSet: TDataSet);
var
  I: Longint;
  vParam: TParam;
begin
  with getLayoutInterface(OnNewRecord) do
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

procedure TORATable.GetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  vIndex: Longint;
begin
  if AItem <> nil then begin
    vIndex := getColumnStyleColumnIndex(TcxGridItemDBDataBinding(AItem.DataBinding).FieldName);
    if vIndex <> -1 then begin
      AStyle := LayoutStyles(VarToStr(ARecord.Values[vIndex]));
      if AStyle <> nil then exit;
    end;
  end;
  vIndex := getRowStyleColumnIndex;
  if vIndex = -1 then exit;
  AStyle := LayoutStyles(VarToStr(ARecord.Values[vIndex]));
end;

destructor TORATable.Destroy;
begin
  if FThread.IndexOf <> -1 then
    with FThread do begin
      OnTerminate := nil;
      SaveSessionOnExit := False;
      SaveQueryOnExit := False;
      RemoveComponent(FDataSet);
      Terminate;
      FThread := nil;
    end
  else if FThreaded then getLayoutInterface(FDataSet).LayoutSession.Free;
  ActiveView.Free;
  inherited;
end;

procedure TORATable.doCalcSummary(ASender: TcxDataSummaryItems; Arguments: TcxSummaryEventArguments;
  var OutArguments: TcxSummaryEventOutArguments);
var
  vWColumn: TORATableColumn;
  vWeight: Extended;
  function get_extended(const v: Variant): Extended;
  begin
    if not TryStrToFloat(VarToStr(v), Result) then Result := 0;
  end;

begin
  OutArguments.Done := True;
  vWColumn := TORATableColumn(Arguments.SummaryItem.ItemLink).WeightColumn;
  if (vWColumn <> nil) And (Arguments.SummaryItem.Kind = skAverage) then begin
    if not VarIsNull(OutArguments.SummaryValue) then begin
      vWeight := get_extended(TcxGridDBTableView(ActiveView).DataController.Values
        [Arguments.RecordIndex, vWColumn.Index]);
      if vWeight <> 0 then begin
        if vWeight * OutArguments.CountValue < 0 then OutArguments.SummaryValue := Null
        else begin
          if OutArguments.CountValue = 0 then
            if vWeight > 0 then OutArguments.CountValue := 1
            else OutArguments.CountValue := -1;
          OutArguments.SummaryValue := OutArguments.SummaryValue + vWeight *
            get_extended(OutArguments.Value);
        end;
      end;
    end;
  end
  else if (Arguments.SummaryItem.Kind <> skNone) and
    not((soNullIgnore in ASender.Summary.Options) and VarIsNull(OutArguments.Value)) then begin
    if VarIsEmpty(OutArguments.SummaryValue) then begin
      if Arguments.SummaryItem.Kind <> skCount then begin
        if not(VarIsNull(OutArguments.Value) and (Arguments.SummaryItem.Kind in [skMin, skMax]))
        then OutArguments.SummaryValue := get_extended(OutArguments.Value);
      end;
    end
    else if not VarIsNull(OutArguments.Value) and not VarIsNull(OutArguments.SummaryValue) then
    begin
      case Arguments.SummaryItem.Kind of
        skSum, skAverage:
          OutArguments.SummaryValue := OutArguments.SummaryValue + get_extended(OutArguments.Value);
        skMin: if OutArguments.Value < OutArguments.SummaryValue then
              OutArguments.SummaryValue := OutArguments.Value;
        skMax: if OutArguments.Value > OutArguments.SummaryValue then
              OutArguments.SummaryValue := OutArguments.Value;
      end;
    end;
    Inc(OutArguments.CountValue);
  end;
end;

procedure TORAGridProperties.OnGridCellDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState;
  var AHandled: Boolean);
begin
  Controller.DblClickHandler(OnDblClick, AHandled);
end;

function TORATable.getColumnStyleColumnIndex(const pColumn: String): Integer;
var
  vColumn: TcxCustomGridTableItem;
begin
  vColumn := TcxGridDBDataController(ActiveView.DataController)
    .GetItemByFieldName(cColumnStylePrefix + pColumn);
  if vColumn = nil then Result := -1
  else Result := vColumn.Index;
end;

// function TORATable.getDataController: TcxGridDBDataController;
// begin
// Result := TcxGridDBTableView(ActiveView).DataController;
// end;
//
function TORATable.GetDefaultViewClass: TcxCustomGridViewClass;
begin
  Result := TORATableView;
end;

function TORATable.getLockingMode: TLockMode;
begin
  Result := getLayoutInterface(DataSet).LockMode;
end;

function TORATable.getRowStyleColumnIndex: Integer;
var
  vColumn: TcxCustomGridTableItem;
begin
  vColumn := TcxGridDBDataController(ActiveView.DataController).GetItemByFieldName(cRowStyleField);
  if vColumn = nil then Result := -1
  else Result := vColumn.Index;
end;

function TORATable.getUniqFields: String;
begin
  Result := getLayoutInterface(DataSet).KeyFields; // .UniqueFields;
end;

procedure TORATable.OnAfterPost(pDataSet: TDataSet);
var
  vBookmark: TBookmark;
begin
  with pDataSet do
    if not FInAfterPost And Active then
      try
        FInAfterPost := True;
        vBookmark := Bookmark;
        Refresh;
        if BookmarkValid(vBookmark) then Bookmark := vBookmark;
      finally
        FInAfterPost := False;
      end;
end;

procedure TORATable.OnNavigatorButtonClick(Sender: TObject; AButtonIndex: Integer;
  var ADone: Boolean);
begin
  case AButtonIndex of
    NBDI_REFRESH: begin
        OnAfterPost(DataSet);
        ADone := True;
      end;
    NavigatorButtonCount: begin
        pasteToTableView(Clipboard.AsText, TcxCustomGridTableView(ActiveView));
        ADone := True;
      end;
  end;
end;

procedure TORATable.setLockingMode(const Value: TLockMode);
begin
  getLayoutInterface(DataSet).LockMode := Value;
end;

procedure TORATable.setUniqFields(const Value: String);
begin
  getLayoutInterface(DataSet).KeyFields := Value;
end;

procedure TORAGridProperties.afterOpenData;
begin
  inherited;
  if LockedStateImageOptions.Effect <> lsieNone then View.EndUpdate;
end;

procedure TORAGridProperties.beforeOpenData;
begin
  inherited;
  if LockedStateImageOptions.Effect <> lsieNone then View.BeginUpdate(lsimImmediate);
end;

function TORAGridProperties.calcColumnValue(const pColumn: TcxCustomGridTableItem;
  const pAddQuote: Boolean = False): String;
var
  I: Longint;
  procedure add_result(aRec: TcxCustomGridRecord);
  var
    vVal: String;
  begin
    if (aRec <> nil) And (aRec is TcxGridDataRow) then begin
      if pColumn <> nil then
        if pAddQuote then vVal := '''' + VarToStr(aRec.Values[pColumn.Index]) + ''''
        else vVal := VarToStr(aRec.Values[pColumn.Index])
      else vVal := IntToStr(aRec.Index);
      if Result = '' then Result := vVal
      else Result := Result + ',' + vVal;
    end;
  end;

begin
  Result := '';
  with View.Controller do
    if SelectedRecordCount > 0 then
      for I := 0 to SelectedRecordCount - 1 do add_result(SelectedRecords[I])
    else add_result(View.Controller.FocusedRecord)
end;

constructor TORAGridProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;
  if AController <> nil then begin
    View.OnSelectionChanged := OnSelectionChanged;
    View.OnFocusedRecordChanged := OnFocusedRecordChanged;
    View.OnCellDblClick := OnGridCellDblClick;
    View.OnEditValueChanged := OnColumnValueChanged;
    srcData.OnNewRecord := DataSetNewRecordNotify;
  end;
end;

function TORAGridProperties.getColumn(const pSubControlName: String): TcxCustomGridTableItem;
var
  I: Integer;
begin
  with View do
    for I := 0 to ItemCount - 1 do begin
      Result := Items[I];
      if AnsiSameText(Result.Name, pSubControlName) then exit;
    end;
  Result := nil;
end;

function TORAGridProperties.getDataController: TcxGridDBDataController;
begin
  if View.DataController is TcxGridDBDataController then
      Result := TcxGridDBDataController(View.DataController)
  else Result := nil;
end;

function TORAGridProperties.getDataSet: TDataSet;
begin
  Result := ORATable.FDataSet;
end;

{ TORAColumnProperties }
type
  TcxCustomGridTableItemAccess = class(TcxCustomGridTableItem);

function TORATableItemProperties.getCaption: String;
begin
  Result := Column.Caption;
end;

function TORATableItemProperties.getColumn: TcxCustomGridTableItem;
begin
  Result := TcxCustomGridTableItem(Component);
end;

function TORATableItemProperties.getColumnOptions: TcxCustomGridTableItemOptions;
begin
  Result := Column.Options;
end;

function TORATableItemProperties.getSortIndex: Longint;
begin
  Result := Column.SortIndex;
end;

function TORATableItemProperties.getSortOrder: TdxSortOrder;
begin
  Result := Column.SortOrder;
end;

function TORATableItemProperties.getStyles: TcxCustomGridTableItemStyles;
begin
  Result := Column.Styles;
end;

function TORATableColumnProperties.getColumn: TORATableColumn;
begin
  Result := TORATableColumn(Component);
end;

function TORATableColumnProperties.getSummary: TcxGridColumnSummary;
begin
  Result := Column.Summary;
end;

function TORATableItemProperties.getVisible: Boolean;
begin
  Result := Column.Visible;
end;

function TORATableItemProperties.getWidth: Integer;
begin
  Result := TcxCustomGridTableItemAccess(Column).Width;
end;

procedure TORATableColumnProperties.RestoreFromStream(const pReader: TReader);
begin
  inherited;
  if Column.Properties <> nil then begin
    Column.FooterAlignmentHorz := Column.Properties.Alignment.Horz;
    Column.GroupSummaryAlignment := Column.Properties.Alignment.Horz;
  end;
end;

procedure TORATableItemProperties.setCaption(const Value: String);
begin
  Column.Caption := Value;
end;

procedure TORATableItemProperties.setSortIndex(const Value: Longint);
begin
  Column.SortIndex := Value;
end;

procedure TORATableItemProperties.setSortOrder(const Value: TdxSortOrder);
begin
  Column.SortOrder := Value;
end;

procedure TORATableItemProperties.setVisible(const Value: Boolean);
begin
  Column.Visible := Value;
end;

procedure TORATableItemProperties.setWidth(const Value: Integer);
begin
  TcxCustomGridTableItemAccess(Column).Width := Value;
end;

function TORATableItemProperties.getFieldName: String;
begin
  Result := TcxGridItemDBDataBinding(Column.DataBinding).FieldName;
end;

function TORATableItemProperties.getGroupIndex: Longint;
begin
  Result := TcxCustomGridTableItemAccess(Column).GroupIndex;
end;

function TORATableItemProperties.getLayoutItem: TdxCustomLayoutItem;
begin
  Result := Controller.Layout.FindItem(Column.GridView.Control);
end;

function TORATableItemProperties.getProperties: TcxCustomEditProperties;
begin
  Result := Column.Properties;
end;

procedure TORATableItemProperties.setFieldName(const Value: String);
begin
  TcxGridItemDBDataBinding(Column.DataBinding).FieldName := Value;
end;

procedure TORATableItemProperties.setGroupIndex(const Value: Longint);
begin
  TcxCustomGridTableItemAccess(Column).GroupIndex := Value;
end;

procedure TORATableItemProperties.SetPropertiesClass(Value: TcxCustomEditPropertiesClass);
begin
  inherited;
  Column.PropertiesClass := Value;
end;

{ TORATableView }

function TORATableView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TORADataController;
end;

function TORATableView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TORATableColumn;
end;

function TORATableView.GetNavigatorClass: TcxGridViewNavigatorClass;
begin
  Result := TORATableViewNavigator;
end;

{ TORATableColumn }

function TORATableColumn.getStringStyles: String;
begin
  Result := styles2string(Styles);
end;

function TORATableColumn.GetSummaryClass: TcxGridColumnSummaryClass;
begin
  Result := TORAColumnSummary;
end;

function TORATableColumn.getWeightColumn: TORATableColumn;
begin
  Result := self;
  if Result <> nil then
      Result := TORATableColumn(TcxGridDBDataController(DataController)
      .GetItemByFieldName(TORAColumnSummary(Summary).WeightColumn));
end;

procedure TORATableColumn.setStringStyles(const Value: String);
begin
  string2styles(Styles, Value);
end;

{ TORADataController }

function TORADataController.GetSummaryClass: TcxDataSummaryClass;
begin
  Result := TORADataSummary;
end;

function TORADataController.GetSummaryItemClass: TcxDataSummaryItemClass;
begin
  Result := TORADataSummaryItem;
end;

{ TORADataSummary }

procedure TORADataSummary.EndCalculateSummary(ASummaryItems: TcxDataSummaryItems;
  var ACountValues: TcxDataSummaryCountValues; var ASummaryValues: TcxDataSummaryValues;
  var SummaryValues: Variant);
var
  I, J: Integer;
  vWColumn: TORATableColumn;
begin
  for J := 0 to ASummaryItems.Count - 1 do begin
    vWColumn := TORATableColumn(ASummaryItems[J].ItemLink).WeightColumn;
    if (vWColumn <> nil) And (ASummaryItems[J].Kind = skAverage) then begin
      I := ASummaryItems.IndexOfItemLink(vWColumn);
      if I <> -1 then
        try
          ASummaryValues[J] := ASummaryValues[J] / ASummaryValues[I]
        except
          on E: Exception do ASummaryValues[J] := E.Message;
        end;
    end
    else DoFinishSummaryValue(ASummaryItems[J], ASummaryValues[J], ACountValues[J]);
  end;
  if Length(ASummaryValues) = 0 then SummaryValues := Null
  else SummaryValues := Variant(ASummaryValues);
end;

{ TORADataSummaryItem }

function TORADataSummaryItem.FormatValue(const AValue: Variant; AIsFooter: Boolean): string;
begin
  try
    Result := inherited;
  except
    Result := VarToStr(AValue);
  end;
end;

initialization

register_ORADataType('Таблица БД', TORAGridTableProperties, TORATable);
register_ORADataType('Табличная колонка', TORATableColumnProperties, TORATableColumn);

end.
