unit ORALayoutVGrid;

interface

uses SysUtils, Classes, TypInfo, cxDBVGrid, cxVGrid, DB, ORALayoutCustomize,
  ORANavigators, cxInplaceContainer, cxOI, LayoutData;

type

  TORAVerticalGrid = class(TcxDBVerticalGrid)
  private
    FDataSet: TDataSet;
    function getSrcSQL: String;
    procedure setSrcSQL(const Value: String);
  protected
    function GetNavigatorClass: TcxControlNavigatorClass; override;
    // IcxStoredObject
    function GetProperties(AProperties: TStrings): Boolean; override;
    procedure GetPropertyValue(const AName: string; var AValue: Variant); override;
    procedure SetPropertyValue(const AName: string; const AValue: Variant); override;
    // IcxStoredParent
    function CreateChild(const AObjectName, AClassName: string): TObject; override;
    procedure GetStoredChildren(AChildren: TStringList); override;

    function GetEditorRowClass: TcxCustomRowClass; override;
    function GetMultiEditorRowClass: TcxCustomRowClass; override;

  public
    constructor Create(AOwner: TComponent); override;
  published
    property SrcSQL: String read getSrcSQL write setSrcSQL;
  end;

  TORAVerticalGridProperties = class(TORASrcDataEditProperties)
  private
    function getVGrid: TORAVerticalGrid; inline;
    function GetOptionsBehavior: TcxvgMultiRecordsOptionsBehavior;
    function GetOptionsData: TcxvgMultiRecordsOptionsData;
    function GetOptionsView: TcxvgMultiRecordsOptionsView;
    function GetStyles: TcxVerticalGridStyles;
  protected
    procedure initSourceData; override;
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
    function getDataSet: TDataSet; override;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
    procedure StoreToStream(const pWriter: TWriter); override;
  published
    property srcData: TDataSet read getDataSet;
    property OptionsView: TcxvgMultiRecordsOptionsView read GetOptionsView;
    property OptionsBehavior: TcxvgMultiRecordsOptionsBehavior read GetOptionsBehavior;
    property OptionsData: TcxvgMultiRecordsOptionsData read GetOptionsData;
    property Styles: TcxVerticalGridStyles read GetStyles;
    property VGrid: TORAVerticalGrid read getVGrid;
  end;

  TORARowProperties = class(TORAComponentProperties)
  private
  protected
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
  public
  published
  end;

  TORADBEditorRow = class(TcxDBEditorRow)
  private
    function getPLSQL: String;
    procedure setPLSQL(const Value: String);
  protected
    // IcxStoredObject
    // function GetObjectName: string; override;
    // function GetStoredProperties(AProperties: TStrings): Boolean; override;
    // procedure GetPropertyValue(const AName: string; var AValue: Variant); override;
    // procedure SetPropertyValue(const AName: string; const AValue: Variant); override;
    function getDataSet: TDataSet;
  public
    property srcData: TDataSet read getDataSet;
  published
    property srcPLSQL: String read getPLSQL write setPLSQL;
  end;

  TORARowEditorProperties = class(TORARowProperties)
  private
    function getRow: TORADBEditorRow; inline;
    function GetProperties: TcxDBEditorRowProperties; inline;
    function getFieldName: String;
    procedure setFieldName(const Value: String);
  protected
    function getDataSet: TDataSet; override;
    function getCaption: String; override;
    procedure setCaption(const Value: String); override;
  public
    property Row: TORADBEditorRow read getRow;
  published
    property srcData: TDataSet read getDataSet;
    property FieldName: String read getFieldName write setFieldName;
    property Properties: TcxDBEditorRowProperties read GetProperties;
  end;

  TORADBMultiEditorRow = class(TcxDBMultiEditorRow)

  end;

  TORARowMultiEditorProperties = class(TORARowProperties)
  private
    function getRow: TORADBMultiEditorRow; inline;
    function GetProperties: TcxDBMultiEditorRowProperties; inline;
  protected
    function getCaption: String; override;
    procedure setCaption(const Value: String); override;
  public
    property Row: TORADBMultiEditorRow read getRow;
  published
    property Properties: TcxDBMultiEditorRowProperties read GetProperties;
  end;

  TORACategoryRow = class(TcxCategoryRow)

  end;

  TORACategoryRowProperties = class(TORARowProperties)
  private
    function getRow: TORACategoryRow; inline;
    function GetProperties: TcxCaptionRowProperties; inline;
  protected
    function getCaption: String; override;
    procedure setCaption(const Value: String); override;
  public
    property Row: TORACategoryRow read getRow;
  published
    property Properties: TcxCaptionRowProperties read GetProperties;
  end;

implementation

uses cxFilter, RTLConsts, cxClasses, ORALayout, ORAStyles, ORALayoutVGridEditor,
  ORALayoutColumnEdit;

{ TORATable }
const
  cStylePropertyName: array [0 .. 1] of String = ('srcSQL', 'Styles');

constructor TORAVerticalGrid.Create(AOwner: TComponent);
begin
  inherited;
  Images := HostInterface.LayoutImages;
  FDataSet := stdLayoutQuery(self);
  FDataSet.name := 'srcData';
  with DataController do begin
    DataSource := TDataSource.Create(self);
    DataSource.DataSet := FDataSet;
    Filter.Options := [fcoCaseInsensitive];
  end;
end;

{ TORAVerticalGridProperties }

constructor TORAVerticalGridProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;

end;

function TORAVerticalGridProperties.getDataSet: TDataSet;
begin
  Result := VGrid.FDataSet;
end;

function TORAVerticalGridProperties.GetOptionsBehavior: TcxvgMultiRecordsOptionsBehavior;
begin
  Result := VGrid.OptionsBehavior;
end;

function TORAVerticalGridProperties.GetOptionsData: TcxvgMultiRecordsOptionsData;
begin
  Result := VGrid.OptionsData;
end;

function TORAVerticalGridProperties.GetOptionsView: TcxvgMultiRecordsOptionsView;
begin
  Result := VGrid.OptionsView;
end;

function TORAVerticalGridProperties.getStoreProperty(const pName: String): Variant;
begin
  case StorePropertyIndex[pName] of
    1: Result := styles2string(Styles);
  else inherited;
  end;
end;

function TORAVerticalGridProperties.getStorePropertyCount: Longint;
begin
  Result := Length(cStylePropertyName) { + inherited };
end;

function TORAVerticalGridProperties.getStorePropertyNames: PString;
begin
  Result := @cStylePropertyName[0];
end;

function TORAVerticalGridProperties.GetStyles: TcxVerticalGridStyles;
begin
  Result := VGrid.Styles;
end;

function TORAVerticalGridProperties.getVGrid: TORAVerticalGrid;
begin
  Result := TORAVerticalGrid(Component);
end;

procedure TORAVerticalGridProperties.initSourceData;
var
  I: Longint;
begin
  inherited;
  with VGrid.Rows do
    for I := 0 to Count - 1 do
      if Items[I] is TORADBEditorRow then
        with TORARowEditorProperties.Create(TORADBEditorRow(Items[I]), nil) do
          try
            initSourceData;
          finally
            Free;
          end;
end;

procedure TORAVerticalGridProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  case StorePropertyIndex[pName] of
    1: string2styles(Styles, Value);
  else inherited;
  end;
end;

procedure TORAVerticalGridProperties.StoreToStream(const pWriter: TWriter);
var
  I: Longint;
  vName: String;
begin
  with pWriter do begin
    IgnoreChildren := False;
    WriteRootComponent(Component);
    for I := 0 to StorePropertyCount - 1 do begin
      vName := StorePropertyName[I];
      LayoutStoreProperty(pWriter, vName, StoreProperty[vName]);
    end;
    WriteString(cFieldBlockEnd);
  end;
end;

{ TORARowEditorProperties }

function TORARowEditorProperties.getCaption: String;
begin
  Result := Properties.Caption;
end;

function TORARowEditorProperties.getDataSet: TDataSet;
begin
  Result := Row.srcData;
end;

function TORARowEditorProperties.getFieldName: String;
begin
  Result := Row.Properties.DataBinding.FieldName;
end;

function TORARowEditorProperties.GetProperties: TcxDBEditorRowProperties;
begin
  Result := Row.Properties;
end;

function TORARowEditorProperties.getRow: TORADBEditorRow;
begin
  Result := TORADBEditorRow(Component);
end;

function TORARowProperties.getStoreProperty(const pName: String): Variant;
begin
  Inherited;
end;

function TORARowProperties.getStorePropertyCount: Longint;
begin
  Result := Inherited;
end;

function TORARowProperties.getStorePropertyNames: PString;
begin
  Result := nil;
end;

procedure TORARowEditorProperties.setCaption(const Value: String);
begin
  inherited;
  Properties.Caption := Value;
end;

procedure TORARowEditorProperties.setFieldName(const Value: String);
begin
  Row.Properties.DataBinding.FieldName := Value;
end;

procedure TORARowProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  inherited;

end;

{ TORARowMultiEditorProperties }

function TORARowMultiEditorProperties.getCaption: String;
begin
  Result := 'caption?';
end;

function TORARowMultiEditorProperties.GetProperties: TcxDBMultiEditorRowProperties;
begin
  Result := Row.Properties;
end;

function TORARowMultiEditorProperties.getRow: TORADBMultiEditorRow;
begin
  Result := TORADBMultiEditorRow(Component);
end;

procedure TORARowMultiEditorProperties.setCaption(const Value: String);
begin
  inherited;

end;

{ TORACategoryRowProperties }

function TORACategoryRowProperties.getCaption: String;
begin
  Result := Properties.Caption;
end;

function TORACategoryRowProperties.GetProperties: TcxCaptionRowProperties;
begin
  Result := Row.Properties;
end;

function TORACategoryRowProperties.getRow: TORACategoryRow;
begin
  Result := TORACategoryRow(Component);
end;

procedure TORACategoryRowProperties.setCaption(const Value: String);
begin
  inherited;
  Properties.Caption := Value;
end;

function TORAVerticalGrid.CreateChild(const AObjectName, AClassName: string): TObject;
var
  ARow: TcxCustomRow;
begin
  if AClassName = 'TORACategoryRow' then ARow := Add(TORACategoryRow)
  else if AClassName = 'TORADBEditorRow' then ARow := Add(TORADBEditorRow)
  else if AClassName = 'TORADBMultiEditorRow' then ARow := Add(TORADBMultiEditorRow)
  else begin
    Result := nil;
    exit;
  end;
  ARow.name := AObjectName;
  Result := ARow;
end;

function TORAVerticalGrid.GetEditorRowClass: TcxCustomRowClass;
begin
  Result := TORADBEditorRow;
end;

function TORAVerticalGrid.GetMultiEditorRowClass: TcxCustomRowClass;
begin
  Result := TORADBMultiEditorRow;
end;

function TORAVerticalGrid.GetNavigatorClass: TcxControlNavigatorClass;
begin
  Result := TORAControlNavigator;
end;

function TORAVerticalGrid.GetProperties(AProperties: TStrings): Boolean;
begin
  Result := inherited;
  AProperties.Add('srcData');
end;

procedure TORAVerticalGrid.GetPropertyValue(const AName: string; var AValue: Variant);
begin
  if AName = 'srcData' then AValue := getLayoutInterface(FDataSet).SQL.Text
  else inherited;
end;

function TORAVerticalGrid.getSrcSQL: String;
begin
  Result := getLayoutInterface(FDataSet).SQL.Text;
end;

procedure TORAVerticalGrid.GetStoredChildren(AChildren: TStringList);
var
  I: Longint;
begin
  with Rows do
    for I := 0 to Count - 1 do AChildren.AddObject(Items[I].name, Items[I]);
end;

procedure TORAVerticalGrid.SetPropertyValue(const AName: string; const AValue: Variant);
begin
  if AName = 'srcData' then getLayoutInterface(FDataSet).SQL.Text := AValue
  else inherited;
end;

procedure TORAVerticalGrid.setSrcSQL(const Value: String);
begin
  getLayoutInterface(FDataSet).SQL.Text := Value;
end;

{ TORADBEditorRow }

function TORADBEditorRow.getDataSet: TDataSet;
begin
  if Properties.EditProperties is TORALookupComboBoxProperties then
      Result := TORALookupComboBoxProperties(Properties.EditProperties).SrcSQL
  else if Properties.EditProperties is TORACheckComboBoxProperties then
      Result := TORACheckComboBoxProperties(Properties.EditProperties).SrcSQL
  else Result := nil;
end;

function TORADBEditorRow.getPLSQL: String;
begin
  if srcData <> nil then Result := getLayoutInterface(srcData).SQL.Text
  else Result := '';
end;

procedure TORADBEditorRow.setPLSQL(const Value: String);
begin
  if srcData <> nil then getLayoutInterface(srcData).SQL.Text := Value;
end;

initialization

RegisterClasses([TORADBEditorRow, TORADBMultiEditorRow, TORACategoryRow]);

register_ORADataType('Вертикальный редактор', TORAVerticalGridProperties, TORAVerticalGrid);
register_ORADataType('Строка вертикального редактора', TORARowEditorProperties, TORADBEditorRow);
register_ORADataType('Мультистрока вертикального редактора', TORARowMultiEditorProperties,
  TORADBMultiEditorRow);
register_ORADataType('Строка-категория вертикального редактора', TORACategoryRowProperties,
  TORACategoryRow);

Finalization

UnRegisterClasses([TORADBEditorRow, TORADBMultiEditorRow, TORACategoryRow]);

end.
