unit ORALayoutColumnEdit;

interface

uses TypInfo, Classes, SysUtils, cxOI, Controls, cxCheckComboBox, ORALayoutCustomize,
  cxDBLookupComboBox, cxButtonEdit, cxEdit, DB, cxCheckBox, cxImage, LayoutData;

type

  TORALookupComboBoxProperties = class(TcxLookupComboBoxProperties)
  private
    function getSrcSQL: TDataSet;
  published
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    property SrcSQL: TDataSet read getSrcSQL;
  end;

  TORACheckComboBoxProperties = class(TcxCheckComboBoxProperties)
  private
    FDataSet: TDataSet;
  protected
    procedure myValueToCheckStates(Sender: TObject; const AEditValue: TcxEditValue;
      var ACheckStates: TcxCheckStates);
    procedure myCheckStatesToValue(Sender: TObject; const ACheckStates: TcxCheckStates;
      out AValue: TcxEditValue);
  published
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    property SrcSQL: TDataSet read FDataSet;
  end;

  TORAButtonEditProperties = class(TcxButtonEditProperties)
  private
    FOnClickStart: TDataSet;
    FOnClickFinish: TDataSet;
    procedure OnButtonClickHandler(Sender: TObject; AButtonIndex: Integer);
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
  published
    property OnClickStart: TDataSet read FOnClickStart;
    property OnClickFinish: TDataSet read FOnClickFinish;
  end;

  TORAColumnTypeProperty = class(TcxOrdinalProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  TORAColumnsProperty = class(TcxClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TcxPropertyAttributes; override;
  end;

  TORAColumnProperties = class(TORAComponentProperties)
  private
    function getColumnType: Longint;
    procedure setColumnType(const Value: Longint);
  protected
    procedure initSourceData; override;
    function getVisible: Boolean; virtual; abstract;
    procedure setVisible(const Value: Boolean); virtual; abstract;
    function getFieldName: String; virtual; abstract;
    procedure setFieldName(const Value: String); virtual; abstract;
    function getProperties: TcxCustomEditProperties; virtual; abstract;
    procedure SetPropertiesClass(Value: TcxCustomEditPropertiesClass); virtual; abstract;
    function getWidth: Integer; virtual; abstract;
    procedure setWidth(const Value: Integer); virtual; abstract;
    function getDataSet: TDataSet; override;
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
  public
  published
    property FieldName: String read getFieldName write setFieldName;
    property Visible: Boolean read getVisible write setVisible;
    property Width: Integer read getWidth write setWidth;
    property ColumnType: Longint read getColumnType write setColumnType;
    property srcData: TDataSet read getDataSet;
    property Properties: TcxCustomEditProperties read getProperties;
  end;

procedure register_ORAColumnType(pDataTypeName: String; pEditClass: TcxCustomEditPropertiesClass);

function get_ORAColumnType(pDataTypeName: String): Longint; overload;
function get_ORAColumnType(pEditClass: TClass): Longint; overload;
function get_ORAColumnType(pIndex: Longint): TcxCustomEditPropertiesClass; overload;

const
  cRowStyleField: String = 'RowStyle';
  cColumnStylePrefix: String = 'ColumnStyle_';

implementation

uses RTLConsts, Utilities, ORALayoutDropdown, Variants, cxGridCustomTableView, ORALayoutGridEditor,
  ORALayout, cxTextEdit, cxCurrencyEdit, cxCalendar, cxLookAndFeelPainters;

type

  TType_mapping_rec = record
    DataTypeName: String;
    EditClass: TcxCustomEditPropertiesClass;
  end;

const
  cSrcPropertyNames: array [0 .. 1] of String = ('srcSQL', 'Styles');
  cButtonPropertyNames: array [0 .. 2] of String = ('OnClickStart', 'OnClickFinish', 'Styles');

var
  type_mapping: array of TType_mapping_rec;

function get_ORAColumnType(pDataTypeName: String): Longint; overload;
begin
  for Result := Low(type_mapping) to High(type_mapping) do
    if type_mapping[Result].DataTypeName = pDataTypeName then exit;
  Result := -1;
end;

function get_ORAColumnType(pIndex: Longint): TcxCustomEditPropertiesClass; overload;
begin
  Result := type_mapping[pIndex].EditClass;
end;

function get_ORAColumnType(pEditClass: TClass): Longint; overload;
begin
  for Result := Low(type_mapping) to High(type_mapping) do
    if type_mapping[Result].EditClass = pEditClass then exit;
  Result := -1;
end;

procedure register_ORAColumnType(pDataTypeName: String; pEditClass: TcxCustomEditPropertiesClass);
var
  vTypeIndex: Longint;
begin
  vTypeIndex := get_ORAColumnType(pDataTypeName);
  if vTypeIndex < 0 then begin
    vTypeIndex := get_ORAColumnType(pEditClass);
    if vTypeIndex < 0 then begin
      SetLength(type_mapping, Length(type_mapping) + 1);
      vTypeIndex := High(type_mapping);
    end;
  end;
  with type_mapping[vTypeIndex] do begin
    DataTypeName := pDataTypeName;
    EditClass := pEditClass;
  end;
end;

{ TORAColumnTypeProperty }

function TORAColumnTypeProperty.GetAttributes: TcxPropertyAttributes;
begin
  if PropList[0].PropInfo.SetProc = nil then Result := [ipaValueList, ipaReadOnly]
  else Result := [ipaValueList, ipaSortList, ipaRevertable];
end;

function TORAColumnTypeProperty.GetValue: string;
var
  v: Longint;
begin
  v := GetOrdValue;
  if v < Low(type_mapping) then Result := ''
  else Result := type_mapping[v].DataTypeName;
end;

procedure TORAColumnTypeProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := Low(type_mapping) to High(type_mapping) do Proc(type_mapping[I].DataTypeName);
end;

procedure TORAColumnTypeProperty.SetValue(const Value: string);
var
  I: Integer;
begin
  I := get_ORAColumnType(Value);
  with GetTypeData(GetPropType)^ do
    if (I < Low(type_mapping)) or (I > High(type_mapping)) then
        raise EcxPropertyError.Create(SInvalidPropertyValue);
  SetOrdValue(I);
  if Inspector.Owner is TfrmORALayoutCustomize then
      TfrmORALayoutCustomize(Inspector.Owner).RefreshSelection;
end;

{ TORALookupComboBoxProperties }

constructor TORALookupComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited;
  UseMouseWheel := False;
  if AOwner is TComponent then begin
    ListSource := TDataSource.Create(TComponent(AOwner));
    ListSource.DataSet := stdLayoutQuery(ListSource);
  end;
end;

destructor TORALookupComboBoxProperties.Destroy;
begin
  ListSource.Free;
  inherited;
end;

function TORALookupComboBoxProperties.getSrcSQL: TDataSet;
begin
  Result := ListSource.DataSet;
end;

{ TORAButtonEditProperties }

constructor TORAButtonEditProperties.Create(AOwner: TPersistent);
begin
  if AOwner is TComponent then begin
    FOnClickStart := stdLayoutQuery(TComponent(AOwner));
    FOnClickFinish := stdLayoutQuery(TComponent(AOwner));
    OnButtonClick := OnButtonClickHandler;
  end else begin
    FOnClickStart := nil;
    FOnClickFinish := nil;
  end;
  inherited;
  ReadOnly := True;
  Images := HostInterface.LayoutImages;
end;

destructor TORAButtonEditProperties.Destroy;
begin
  FOnClickStart.Free;
  FOnClickFinish.Free;
  inherited;
end;

procedure TORAButtonEditProperties.OnButtonClickHandler(Sender: TObject; AButtonIndex: Integer);
var
  vController: TORALayoutController;
  vOwner: TComponent;
begin
  if Owner is TComponent then begin
    vOwner := TComponent(Owner);
    vController := get_controller(vOwner);
    if vController <> nil then
      with vController do begin
        ControlCollection.Values['Button_Index'] := IntToStr(AButtonIndex);
        ButtonClickHandler(vOwner, FOnClickStart, FOnClickFinish);
      end;
  end;
end;

{ TORAColumnProperties }

function TORAColumnProperties.getColumnType: Longint;
var
  vClass: TClass;
begin
  if Properties = nil then vClass := nil
  else vClass := Properties.ClassType;
  Result := get_ORAColumnType(vClass);
end;

function TORAColumnProperties.getDataSet: TDataSet;
begin
  Result := nil;
  if Properties is TORALookupComboBoxProperties then
      Result := TORALookupComboBoxProperties(Properties).SrcSQL
  else if Properties is TORACheckComboBoxProperties then
      Result := TORACheckComboBoxProperties(Properties).FDataSet
  else if Properties is TORAButtonEditProperties then
      Result := TORAButtonEditProperties(Properties).FOnClickStart
end;

function TORAColumnProperties.getStoreProperty(const pName: String): Variant;
begin
  Result := Unassigned;
  if Properties is TORAButtonEditProperties then
    with TORAButtonEditProperties(Properties) do
      case StorePropertyIndex[pName] of
        0: if OnClickStart <> nil then Result := getLayoutInterface(OnClickStart).SQL.Text;
        1: if OnClickFinish <> nil then Result := getLayoutInterface(OnClickFinish).SQL.Text;
      else inherited;
      end
  else
    case StorePropertyIndex[pName] of
      0: if srcData <> nil then Result := getLayoutInterface(srcData).SQL.Text;
    else inherited;
    end;
end;

function TORAColumnProperties.getStorePropertyCount: Longint;
begin
  Result := inherited;
  if Properties is TORAButtonEditProperties then Result := Length(cButtonPropertyNames)
  else if Properties is TORALookupComboBoxProperties then Result := Length(cSrcPropertyNames)
  else if Properties is TORACheckComboBoxProperties then Result := Length(cSrcPropertyNames);
end;

function TORAColumnProperties.getStorePropertyNames: PString;
begin
  if Properties is TORAButtonEditProperties then Result := @cButtonPropertyNames[0]
  else if Properties is TORALookupComboBoxProperties then Result := @cSrcPropertyNames[0]
  else if Properties is TORACheckComboBoxProperties then Result := @cSrcPropertyNames[0]
  else Result := nil;
end;

procedure TORAColumnProperties.initSourceData;
begin
  if (Properties is TORACheckComboBoxProperties) And (srcData <> nil) then
    with srcData, getLayoutInterface(srcData), TORACheckComboBoxProperties(Properties) do begin
      if (SQL.Text <> '') and (Controller.doBeforeExecute(srcData) or
        (LayoutSession <> Controller.Session) or (Items.count = 0)) then begin
        if LayoutSession <> Controller.Session then LayoutSession := Controller.Session;
        try
          ORALoadCollection(Items, srcData);
        except
          on E: Exception do Controller.showException(self.Name + '(srcData):', E);
        end;
      end;
    end
  else if not(Properties is TORAButtonEditProperties) then inherited;
end;

procedure TORAColumnProperties.setColumnType(const Value: Longint);
begin
  SetPropertiesClass(get_ORAColumnType(Value));
end;

procedure TORAColumnProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  if Properties is TORAButtonEditProperties then
    with TORAButtonEditProperties(Properties) do
      case StorePropertyIndex[pName] of
        0: if OnClickStart <> nil then getLayoutInterface(OnClickStart).SQL.Text := Value;
        1: if OnClickFinish <> nil then getLayoutInterface(OnClickFinish).SQL.Text := Value;
      else inherited;
      end
  else
    case StorePropertyIndex[pName] of
      0: if srcData <> nil then getLayoutInterface(srcData).SQL.Text := Value;
    else inherited;
    end;
end;

{ TORAColumnsProperty }

procedure TORAColumnsProperty.Edit;
var
  vPersistent: TPersistent;
begin
  vPersistent := TPersistent(GetOrdValue);
  if vPersistent is TComponent then
      showViewColumns(TComponent(vPersistent), TfrmORALayoutCustomize(getOwnerByClass(Inspector,
      TfrmORALayoutCustomize)));
end;

function TORAColumnsProperty.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaDialog, ipaReadOnly];
end;

{ TORAColumnProperty }

// function TORAColumnProperty.GetAttributes: TcxPropertyAttributes;
// begin
// if PropList[0].PropInfo.SetProc = nil then Result := [ipaValueList, ipaReadOnly]
// else Result := [ipaValueList, ipaSortList, ipaRevertable];
// end;
//
// function TORAColumnProperty.GetValue: string;
// var
// vPersistent: TPersistent;
// begin
// vPersistent := TPersistent(GetOrdValue);
// if vPersistent is TComponent then Result := TComponent(vPersistent).Name
// else Result := '';
// end;
//
// procedure TORAColumnProperty.GetValues(Proc: TGetStrProc);
// var vComp : TPersistent;
// begin
// vComp:=GetComponent(0);
// inherited;
//
// end;
//
// procedure TORAColumnProperty.SetValue(const Value: string);
// var
// I: Integer;
// begin
// I := get_ORAColumnType(Value);
// with GetTypeData(GetPropType)^ do
// if (I < Low(type_mapping)) or (I > High(type_mapping)) then
// raise EcxPropertyError.Create(SInvalidPropertyValue);
// SetOrdValue(I);
// if Inspector.Owner is TfrmORALayoutCustomize then
// TfrmORALayoutCustomize(Inspector.Owner).RefreshSelection;
// end;

{ TORACheckComboBoxProperties }

procedure TORACheckComboBoxProperties.myValueToCheckStates(Sender: TObject;
  const AEditValue: TcxEditValue; var ACheckStates: TcxCheckStates);
var
  I: Longint;
  vVal: String;
begin
  if EditValueFormat = cvfCaptions then begin
    vVal := ',' + StringReplace(VarToStr(AEditValue), ' ', '', [rfReplaceAll, rfIgnoreCase]) + ',';
    with Items do
      for I := 0 to count - 1 do
        if AnsiPos(',' + IntToStr(Items[I].tag) + ',', vVal) <> 0 then ACheckStates[I] := cbsChecked
        else ACheckStates[I] := cbsUnchecked;
  end
  else cxCheckBox.CalculateCheckStates(AEditValue, Items, EditValueFormat, ACheckStates);
end;

procedure TORACheckComboBoxProperties.myCheckStatesToValue(Sender: TObject;
  const ACheckStates: TcxCheckStates; out AValue: TcxEditValue);
var
  I: Longint;
begin
  if EditValueFormat = cvfCaptions then begin
    with Items do begin
      for I := 0 to count - 1 do
        if ACheckStates[I] = cbsChecked then
            AValue := AValue + ifthen(AValue = '', '', ',') + IntToStr(Items[I].tag);
    end;
  end
  else AValue := cxCheckBox.CalculateCheckStatesValue(ACheckStates, Items, EditValueFormat);
end;

constructor TORACheckComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited;
  UseMouseWheel := False;
  OnEditValueToStates := myValueToCheckStates;
  OnStatesToEditValue := myCheckStatesToValue;
  if AOwner is TComponent then begin
    FDataSet := stdLayoutQuery(TComponent(AOwner));
    FDataSet.Name := 'srcData';
  end
  else FDataSet := nil;
end;

destructor TORACheckComboBoxProperties.Destroy;
begin
  FreeAndNil(FDataSet);
  inherited;
end;

initialization

GetRegisteredEditProperties.Register(TORALookupComboBoxProperties, 'Спец.выпадающий редактор1');
GetRegisteredEditProperties.Register(TORACheckComboBoxProperties, 'Спец.выпадающий редактор2');
GetRegisteredEditProperties.Register(TORAButtonEditProperties, 'Кнопочный редактор');

cxRegisterPropertyEditor(TypeInfo(Longint), TORAColumnProperties, 'ColumnType',
  TORAColumnTypeProperty);
cxRegisterPropertyEditor(TypeInfo(TDataSet), TcxCustomEditProperties, '', TORADataSetProperty);
cxRegisterPropertyEditor(TypeInfo(TComponent), TORAControlProperties, 'ORALayoutColumns',
  TORAColumnsProperty);

register_ORAColumnType('не определен', nil);
register_ORAColumnType('Строка', TcxTextEditProperties);
register_ORAColumnType('Число', TcxCurrencyEditProperties);
register_ORAColumnType('Дата', TcxDateEditProperties);
register_ORAColumnType('Галочка', TcxCheckBoxProperties);
register_ORAColumnType('Список (один)', TORALookupComboBoxProperties);
register_ORAColumnType('Список (мульти)', TORACheckComboBoxProperties);
register_ORAColumnType('Кнопочный редактор', TORAButtonEditProperties);
register_ORAColumnType('Картинка', TcxImageProperties);

finalization

SetLength(type_mapping, 0);

end.
