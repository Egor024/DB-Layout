unit ORALayoutDropdown;

interface

uses Classes, DB, cxCheckComboBox, ORALayoutCustomize, cxDBLookupComboBox, LayoutData, cxEdit,
  Windows;

type

  TORACheckComboBoxProperties = class(TORASrcDataEditProperties)
  private
    function getProperties: TcxCustomEditProperties;
  protected
    procedure initSourceData; override;
    function getDataSet: TDataSet; override;
  public
    procedure StoreToStream(const pWriter: TWriter); override;
  published
    property Properties: TcxCustomEditProperties read getProperties;
  end;

  TORALookupComboBoxProperties = class(TORASrcDataEditProperties)
  private
    function getProperties: TcxCustomEditProperties;
    procedure fixDoMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
  protected
    function getDataSet: TDataSet; override;
    procedure initSourceData; override;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
  published
    property Properties: TcxCustomEditProperties read getProperties;
  end;

procedure ORALoadCollection(const pBoxItems: TcxCheckComboBoxItems; const pDataSet: TDataSet);

implementation

uses Utilities, OraError, cxCheckBox, cxStorage, Variants, SysUtils, Dialogs;

type

  TspecCheckComboBoxProperties = class(TcxCheckComboBoxProperties)
  private
  protected
    procedure CalculateCheckStatesByEditValue(Sender: TObject; const AEditValue: TcxEditValue;
      var ACheckStates: TcxCheckStates); override;
    function CalculateEditValueByCheckStates(Sender: TObject; const ACheckStates: TcxCheckStates)
      : TcxEditValue; override;
  public
    constructor Create(AOwner: TPersistent); override;
  end;

  TORACheckComboBox = class(TcxCheckComboBox)
  private
    FLoaded: Boolean;
    FDataSet: TDataSet;
    procedure buttonClick(Sender: TObject; AButtonIndex: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure reload(const p_DefValue: Variant);
  published
    property Enabled;
  end;

  TORAcxLookupComboBoxProperties = class(TcxLookupComboBoxProperties)
  published
    property ClearKey default VK_DELETE;
    property DropDownWidth default 300;
    property DropDownRows default 18;
    property DropDownSizeable default True;
  end;

  TORALookupComboBox = class(TcxCustomLookupComboBox)
  private
  protected
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    constructor Create(AOwner: TComponent); override;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property Enabled;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure ORALoadCollection(const pBoxItems: TcxCheckComboBoxItems; const pDataSet: TDataSet);
var
  p: Integer;
  vSession: TComponent;
  procedure initTcxCheckComboBoxItem(const p_item: TcxCheckComboBoxItem; const p_fields: TFields);
  begin
    with p_item, p_fields do begin
      Tag := Fields[0].AsInteger;
      if Count >= 2 then ShortDescription := Fields[1].AsString
      else ShortDescription := IntToStr(Tag);
      if Count >= 3 then Description := ShortDescription + '_' + Fields[2].AsString
      else Description := ShortDescription;
    end;
  end;

begin
  if (pBoxItems = nil) Or (pDataSet = nil) then exit;
  vSession := getLayoutInterface(pDataSet).LayoutSession;
  if (vSession = nil) Or (not getLayoutInterface(vSession).Connected) then exit;
  try
    TcxCheckComboBoxProperties(pBoxItems.Owner).BeginUpdate;
    pBoxItems.Clear;

    p := 0;

    with pBoxItems, pDataSet do
      try
        if not Active then begin
          Open;
          p := 2;
        end;
        if RecNo <> 0 then MoveBy(-RecNo);
        while not EOF do begin
          initTcxCheckComboBoxItem(Add, Fields);
          Next;
        end;
      finally
        if p = 2 then pDataSet.Close;
      end;
  finally
    TcxCheckComboBoxProperties(pBoxItems.Owner).EndUpdate;
  end;

end;

constructor TspecCheckComboBoxProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  EditValueFormat := cvfStatesString;
  DropDownSizeable := True;
  DropDownRows := 18;
  DropDownWidth := 200;
  Delimiter := ',';
end;

function TspecCheckComboBoxProperties.CalculateEditValueByCheckStates(Sender: TObject;
  const ACheckStates: TcxCheckStates): TcxEditValue;
begin
  Result := Utilities.CalculateEditValueByCheckStates(Items, ACheckStates);
end;

procedure TspecCheckComboBoxProperties.CalculateCheckStatesByEditValue(Sender: TObject;
  const AEditValue: TcxEditValue; var ACheckStates: TcxCheckStates);
begin
  Utilities.CalculateCheckStatesByEditValue(Items, AEditValue, ACheckStates);
end;

{ TORADropdownEditProperties }

function TORACheckComboBoxProperties.getDataSet: TDataSet;
begin
  Result := TORACheckComboBox(Component).FDataSet;
end;

function TORACheckComboBoxProperties.getProperties: TcxCustomEditProperties;
begin
  Result := TORACheckComboBox(Component).Properties;
end;

procedure TORACheckComboBoxProperties.initSourceData;
var
  vOldVal: String;
begin
  if startInitSourceData then
    try
      with srcData, getLayoutInterface(srcData) do
        if not TORACheckComboBox(Component).FLoaded or Controller.doBeforeExecute(srcData) or
          (LayoutSession <> Controller.Session) then begin
          vOldVal := Value;
          if LayoutSession <> Controller.Session then LayoutSession := Controller.Session;
          try
            TORACheckComboBox(Component).reload(vOldVal);
          except
            on E: Exception do Controller.showException(self.Name + '(srcData):', E);
          end;
          if vOldVal <> Value then Controller.OnEditValueChanged(self);
        end;
    finally
      endInitSourceData;
    end;
end;

procedure TORACheckComboBoxProperties.StoreToStream(const pWriter: TWriter);
var
  I: Longint;
  vName: String;
  vValue: String;
begin
  with TORACheckComboBox(Component), Properties do
    try
      BeginUpdate;
      vValue := EditValue;
      Items.Clear;
      with pWriter do begin
        IgnoreChildren := True;
        WriteRootComponent(Component);
        for I := 0 to StorePropertyCount - 1 do begin
          vName := StorePropertyName[I];
          LayoutStoreProperty(pWriter, vName, StoreProperty[vName]);
        end;
        WriteString(cFieldBlockEnd);
      end;
      reload(vValue);
    finally
      EndUpdate;
    end;
end;

{ TORACheckComboBox }

procedure TORACheckComboBox.buttonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if AButtonIndex = 1 then EditValue := '';
end;

constructor TORACheckComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataSet := stdLayoutQuery(self);
  FDataSet.Name := 'srcData';
  FLoaded := False;
  with Properties.Buttons.Add do begin
    Kind := bkText;
    Caption := 'X';
  end;
  with Properties do begin
    OnButtonClick := buttonClick;
  end;
end;

class function TORACheckComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TspecCheckComboBoxProperties;
end;

procedure TORACheckComboBox.reload(const p_DefValue: Variant);
begin
  if getLayoutInterface(FDataSet).SQL.Text = '' then exit;

  ORALoadCollection(Properties.Items, FDataSet);
  Value := p_DefValue;
  FLoaded := True;
end;

{ TORALookupComboBoxProperties }

constructor TORALookupComboBoxProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;
  TORALookupComboBox(AComponent).OnMouseWheel := fixDoMouseWheel;
end;

procedure TORALookupComboBoxProperties.fixDoMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  APoint: TPoint;
begin
  with TORALookupComboBox(Sender) do begin
    APoint := ScreenToClient(MousePos);
    if not PtInRect(ClientBounds, APoint) then Abort;
  end;
end;

function TORALookupComboBoxProperties.getDataSet: TDataSet;
begin
  Result := TcxCustomLookupComboBox(Component).Properties.ListSource.DataSet;
end;

function TORALookupComboBoxProperties.getProperties: TcxCustomEditProperties;
begin
  Result := TcxCustomLookupComboBox(Component).Properties;
end;

procedure TORALookupComboBoxProperties.initSourceData;
var
  vOldVal: String;
  I: Longint;
begin
  with srcData, getLayoutInterface(srcData) do
    if Controller.doBeforeExecute(srcData) or not Active then begin
      vOldVal := Value;
      if LayoutSession <> Controller.Session then LayoutSession := Controller.Session;
      if Active then Refresh
      else if ((LayoutSession <> nil) And (getLayoutInterface(LayoutSession).Connected) And
        (SQL.Text <> '')) then begin
        try
          Open;
        except
          on E: EOraError do
              MessageDlg(self.Name + ':' + E.Message + #13#10 + E.ToString, mtError, [mbOK], 0);
        end;
        with TcxCustomLookupComboBox(Component).Properties do
          if Active And (ListColumns.Count = 0) then begin
            for I := 0 to FieldCount - 1 do
              if I = 0 then KeyFieldNames := Fields.Fields[I].FieldName
              else ListColumns.Add.FieldName := Fields.Fields[I].FieldName;
          end;
      end;
      Value := vOldVal;
      if vOldVal <> Value then Controller.OnEditValueChanged(self);
    end;
end;

{ TORALookupComboBox }

constructor TORALookupComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  with Properties do begin
    ClearKey := VK_DELETE;
    DropDownWidth := 300;
    DropDownRows := 18;
    DropDownSizeable := True;
    ListOptions.ShowHeader := False;
    ListSource := TDataSource.Create(self);
    ListSource.DataSet := stdLayoutQuery(self);
    ListSource.DataSet.Name := 'srcData';
  end;
end;

class function TORALookupComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TORAcxLookupComboBoxProperties;
end;

initialization

register_ORADataType('Список (один)', TORALookupComboBoxProperties, TORALookupComboBox);
register_ORADataType('Список (мульти)', TORACheckComboBoxProperties, TORACheckComboBox);

end.
