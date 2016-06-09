unit ORALayoutCustomize;

interface

uses Windows, SysUtils, Variants, Classes, Controls, Forms, Dialogs, dxLayoutCustomizeForm, cxEdit,
  dxLayoutContainer, StdCtrls, dxLayoutControl, cxStyles, cxInplaceContainer, cxTextEdit,
  cxCalendar, cxCurrencyEdit, TypInfo, cxOI, DB, RTLConsts, dxLayoutSelection, cxOICollectionEd,
  cxButtons, layoutForm, Graphics, ImgList, cxGraphics, cxControls, dxComCtrlsUtils, cxLookAndFeels,
  cxLookAndFeelPainters, ComCtrls, Menus, cxContainer, dxLayoutControlAdapters,
  dxLayoutcxEditAdapters, cxVGrid, ActnList, cxCheckBox, cxTreeView, Contnrs, Messages;

type
  TORAControlProperties = class;
  TORAComponentProperties = class;
  TORALayoutController = class;

  TORAControlPropertiesClass = class of TORAControlProperties;
  TORAComponentPropertiesClass = class of TORAComponentProperties;

  IORALayoutInterface = interface
    ['{D5D3A6DB-DD0B-451E-9A93-2FEC8C2A7D4E}']
    function GetLayoutName: String;
    function GetLayoutValue(const pValueName: String): String;
    procedure SetLayoutValue(const pValueName, aValue: String);
    function doBeforeExecute(const AQuery: TDataSet): Boolean;
    procedure doAfterExecute(const AQuery: TDataSet);

    property Values[const pControlName: String]: String read GetLayoutValue write SetLayoutValue;
  end;

  TORADataTypeProperty = class(TcxOrdinalProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  TORADataSetProperty = class(TcxClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TcxPropertyAttributes; override;
  end;

  TORAImageIndexProperty = class(TcxIntegerProperty)
    procedure Edit; override;
    function GetAttributes: TcxPropertyAttributes; override;
  end;

  TORAComponentProperties = class(TCollectionItem)
  private
    FIsInitSourceData: Boolean;
    FComponent: TComponent;
    function getController: TORALayoutController;
  protected
    function getLayoutItem: TdxCustomLayoutItem; virtual;
    function getName: String; virtual;
    procedure setName(const Value: String); virtual;
    function getDataSet: TDataSet; virtual;
    procedure initSourceData; virtual;
    procedure beforeOpenData; virtual;
    procedure afterOpenData; virtual;
    function getStorePropertyCount: Longint; virtual;
    function getStoreProperty(const pName: String): Variant; virtual; abstract;
    procedure setStoreProperty(const pName: String; const Value: Variant); virtual; abstract;
    function getStorePropertyNames: PString; virtual; abstract;
    function getStorePropertyName(const pIndex: Integer): String; inline;
    function getStorePropertyIndex(const pName: String): Integer;
    function GetDisplayName: string; override;
    function getCaption: String; virtual; abstract;
    procedure setCaption(const Value: String); virtual; abstract;
    procedure OnPropertyChanged(const aPropertyRow: TcxPropertyRow); virtual;
  public
    function startInitSourceData: Boolean;
    procedure endInitSourceData;
    property Component: TComponent read FComponent;
    property Controller: TORALayoutController read getController;
    procedure StoreToStream(const pWriter: TWriter); virtual;
    procedure RestoreFromStream(const pReader: TReader); virtual;
    property StoreProperty[const pName: String]: Variant read getStoreProperty
      write setStoreProperty;
    property StorePropertyNames: PString read getStorePropertyNames;
    property StorePropertyName[const pIndex: Longint]: String read getStorePropertyName;
    property StorePropertyIndex[const pName: String]: Integer read getStorePropertyIndex;
    property StorePropertyCount: Longint read getStorePropertyCount;
  public
    constructor Create(const AComponent: TComponent; const AController: TORALayoutController);
      reintroduce; virtual;
    property LayoutItem: TdxCustomLayoutItem read getLayoutItem;
    property srcData: TDataSet read getDataSet;
  published
    property Caption: String read getCaption write setCaption;
    property Name: String read getName write setName;
  end;

  TORAControlProperties = class(TORAComponentProperties)
  private
    function getDataType: Longint;
    procedure setDataType(const Value: Longint);
    function getTypeName: String;
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function getTabbedOptions: TdxLayoutTabbedOptions;
    function getEditStyle: TcxEditStyle;
    function GetTabOrder: Integer;
    procedure SetTabOrder(const Value: Integer);
  protected
    function getCaption: String; override;
    procedure setCaption(const Value: String); override;
    function GetValue: String; virtual;
    procedure SetValue(const aValue: String); virtual;
    function GetSubControlCount: Integer; virtual;
    function GetSubControl(const pIndex: Integer): TComponent; virtual;
    function GetSubValue(const pSubControlName: String): String; virtual;
    procedure SetSubValue(const pSubControlName, Value: String); virtual;
    procedure OnEditValueChanged(Sender: TObject);
  public
    property DataTypeName: String read getTypeName;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
    property Values[const pSubControlName: String]: String read GetSubValue write SetSubValue;
    function indexOfSubControl(const pSubControlName: String): Integer; virtual;
    property SubControlCount: Integer read GetSubControlCount;
    property SubControl[const pIndex: Integer]: TComponent read GetSubControl;
  published
    property DataType: Longint read getDataType write setDataType;
    property Value: String read GetValue write SetValue;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property TabOrder: Integer read GetTabOrder write SetTabOrder;
    property Style: TcxEditStyle read getEditStyle;
    property TabbedOptions: TdxLayoutTabbedOptions read getTabbedOptions;
  end;

  TORATextEditProperties = class(TORAControlProperties)
  private
    function getProperties: TcxCustomEditProperties;
    procedure OnChange(Sender: TObject);
    function getImmediatePost: Boolean;
    procedure setImmediatePost(const Value: Boolean);
  protected
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
  published
    property ImmediatePost: Boolean read getImmediatePost write setImmediatePost default False;
    property Properties: TcxCustomEditProperties read getProperties;
  end;

  TORARichTextProperties = class(TORATextEditProperties)
  protected
    function GetValue: String; override;
    procedure SetValue(const aValue: String); override;
  end;

  TORAButton = class(TcxButton)
  private
    FOnClickStart: TDataSet;
    FOnClickFinish: TDataSet;
    function getController: TORALayoutController; inline;
  public
    constructor Create(AOwner: TComponent); override;
    property Controller: TORALayoutController read getController;
  published
    property Enabled;
  end;

  TORAButtonProperties = class(TORAControlProperties)
  private
    function getProperties: TORAButton;
    function getOnClick(const pIndex: Longint): TDataSet;
    procedure OnButtonClickHandler(Sender: TObject);
  protected
    function getCaption: String; override;
    procedure setCaption(const Value: String); override;
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
    function GetValue: String; override;
    procedure SetValue(const aValue: String); override;
    function Button: TORAButton; inline;
  public
    constructor Create(const AComponent: TComponent;
      const AController: TORALayoutController); override;
  published
    property OnClickStart: TDataSet index 1 read getOnClick;
    property OnClickFinish: TDataSet index 2 read getOnClick;
    property Properties: TORAButton read getProperties;
  end;

  TORANumberEditProperties = class(TORATextEditProperties)
  private
    function getDisplayFormat: String;
    procedure setDisplayFormat(const Value: String);
  published
    property DisplayFormat: String read getDisplayFormat write setDisplayFormat;
  end;

  TORASrcDataEditProperties = class(TORAControlProperties)
  protected
    function getStorePropertyCount: Longint; override;
    function getStoreProperty(const pName: String): Variant; override;
    procedure setStoreProperty(const pName: String; const Value: Variant); override;
    function getStorePropertyNames: PString; override;
  public
  published
    property srcData: TDataSet read getDataSet;
  end;

  TControlCollectionProperty = class(TcxCollectionProperty)
  public
    function GetColOptions: TcxColOptions; override;
  end;

  TControlCollection = class(TCollection)
  private
    FController: TORALayoutController;
    FInnerVariables: TDataSet;
    function GetValue(const pControlName: String): String;
    procedure SetValue(const pControlName, pValue: String);
    // function doBeforeExecute(const AQuery: TDataSet): Boolean;
    // procedure doAfterExecute(const AQuery: TDataSet);
    procedure Removed(const AControl: TControl);
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    procedure Update(Item: TCollectionItem); override;
    function GetItem(const Index: Integer): TORAControlProperties; inline;
    // procedure initSourceData;
  public
    function IndexOf(const AControl: TControl): Longint; overload;
    function IndexOf(const aName: String): Longint; overload;
    function Add(const ATypeIndex: Longint; const ALayoutItem: TdxLayoutItem)
      : TORAControlProperties;
    function setDataType(const AIndex: Longint; const newDataType: Longint)
      : TORAControlProperties; overload;
    function setDataType(const AControl: TControl; const newDataType: Longint)
      : TORAControlProperties; overload;
    function setDataType(const ALayoutItem: TdxCustomLayoutItem; const newDataType: Longint)
      : TORAControlProperties; overload;
    constructor Create(const AController: TORALayoutController);
    destructor Destroy; override;
    property Controller: TORALayoutController read FController;
    property Items[const Index: Integer]: TORAControlProperties read GetItem; default;
    property Values[const pControlName: String]: String read GetValue write SetValue;
  end;

  TORAControllerState = (ocsLayoutModified, ocsRestoring, ocsEditValueChanging,
    ocsMultiValueChanged, ocsRestoreChanging);
  TORAControllerStates = set of TORAControllerState;

  TORALayoutController = class(TComponent, IORALayoutInterface)
  private
    FForm: TForm;
    FState: TORAControllerStates;
    FPrevOnLChanged: TNotifyEvent;
    FPrevOnSChanged: TNotifyEvent;
    FInitQuery: TDataSet;
    FChangeQuery: TDataSet;
    FCloseQuery: TDataSet;
    FTimerQuery: TDataSet;
    FTimerHandle: HWND;
    FTimerInterval: Cardinal;
    FExceptionCount: Longint;
    FControlCollection: TControlCollection;
    FTimerSuspended: Longint;
    function getLayout: TdxLayoutControl; inline;
    function GetCustomization: Boolean;
    procedure SetCustomization(const Value: Boolean);
    procedure OnLayoutChanged(Sender: TObject);
    procedure OnSelectionChanged(Sender: TObject);
    function getCaption: String;
    procedure setCaption(const Value: String);
    function GetHeight: Longint;
    function GetWidth: Longint;
    procedure SetHeight(const Value: Longint);
    procedure SetWidth(const Value: Longint);
    function getSession: TComponent;
    procedure get_instance_by_name(Reader: TReader; const Name: string; var Instance: Pointer);
    function getIconIndex: TImageIndex;
    procedure setIconIndex(const Value: TImageIndex);
    procedure SetInterval(const Value: Cardinal);
    procedure OnTimerWndProc(var Msg: TMessage);
    procedure OnReadingError(Reader: TReader; const Message: string; var Handled: Boolean);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    Constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure initControls(const initPLSQL: String = ''); overload;
    procedure initControls(const AController: TORALayoutController); overload;
    procedure DoCloseQuery;
    procedure OnEditValueChanged(const AControl: TORAControlProperties);
    procedure suspend_timer;
    procedure resume_timer;
    // IORALayoutInterface
    function GetLayoutName: String;
    function GetLayoutValue(const pControlName: String): String;
    procedure SetLayoutValue(const pControlName: String; const Value: String);
    function doBeforeExecute(const AQuery: TDataSet): Boolean;
    procedure doAfterExecute(const AQuery: TDataSet);

    function chkLayoutModified: Boolean;
    procedure showException(const pExceptionSrc: String; const p_Exception: Exception);
    procedure StoreToStream(pStream: TStream);
    procedure RestoreFromStream(pStream: TStream);
    procedure ButtonClickHandler(const pColumn: TComponent; const pOnClickStart: TDataSet;
      const pOnClickFinish: TDataSet);
    procedure DblClickHandler(const pOnDblClick: TDataSet; var AHandled: Boolean);
    function ClearLayout: Boolean;
    function getActiveLayoutItem: TdxCustomLayoutItem;
    property Layout: TdxLayoutControl read getLayout;
    property State: TORAControllerStates read FState write FState;
    property Customization: Boolean read GetCustomization write SetCustomization;
    property Session: TComponent read getSession;
  published
    property FormCaption: String read getCaption write setCaption;
    property IconIndex: TImageIndex read getIconIndex write setIconIndex default -1;
    property InitQuery: TDataSet read FInitQuery;
    property ChangeQuery: TDataSet read FChangeQuery;
    property TimerInterval: Cardinal read FTimerInterval write SetInterval default 0;
    property TimerQuery: TDataSet read FTimerQuery;
    property CloseQuery: TDataSet read FCloseQuery;
    property ControlCollection: TControlCollection read FControlCollection;
    Property Width: Longint read GetWidth write SetWidth;
    Property Height: Longint read GetHeight write SetHeight;
  end;

  TfrmORALayoutCustomize = class(TdxLayoutControlCustomizeForm)
    lcgSettings: TdxLayoutGroup;
    rttiProperties: TcxRTTIInspector;
    lcMainItem5: TdxLayoutItem;
    rttiCommonProperties: TcxRTTIInspector;
    lcMainItem2: TdxLayoutItem;
    miTreeViewCopy: TMenuItem;
    acORALayoutCopy: TAction;
    acORALayoutPaste: TAction;
    miTreeViewPaste: TMenuItem;
    lcMainSplitterItem1: TdxLayoutSplitterItem;
    procedure rttiPropertiesPropertyChanged(Sender: TObject);
    procedure acStoreExecute(Sender: TObject);
    // procedure acTreeViewItemsDeleteExecute(Sender: TObject);
    procedure acORALayoutCopyExecute(Sender: TObject);
    procedure acORALayoutPasteExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FItem: TComponent;
    procedure ClearInspected;
    procedure InitInspected;
    procedure setItem(const pItem: TComponent);
    function getController: TORALayoutController; inline;
  protected
    // procedure DeleteItems(AList: TComponentList; ATreeView: TTreeView);
    procedure RefreshEnableds; override;
  public
    { Public declarations }
    procedure RefreshSelection;
    property Item: TComponent read FItem write setItem;
    property Controller: TORALayoutController read getController;
  end;

function get_controller(const pComponent: TComponent): TORALayoutController;
procedure register_ORADataType(pDataTypeName: String;
  pPropertiesClass: TORAComponentPropertiesClass; pComponentClass: TComponentClass);
function getORAComponentPropertiesClass(const pComponentClass: TComponentClass)
  : TORAComponentPropertiesClass;
procedure LayoutStoreProperty(const aWriter: TWriter; const pPropName: String;
  const pValue: Variant);
procedure LayoutRestoreProperty(const aReader: TReader; var pPropName: String; var pValue: Variant);

function doBeforeExecute_std(const pLayout: IORALayoutInterface; const AQuery: TDataSet): Boolean;
procedure doAfterExecute_std(const pLayout: IORALayoutInterface; const AQuery: TDataSet);

const
  cControlBegin: String = #13#10'Ctl'#13#10;
  cControlBlockEnd: String = #13#10'CtlEnd'#13#10;
  cFieldBegin: String = #13#10'Fld';
  cFieldBlockEnd: String = #13#10'FldEnd'#13#10;

implementation

uses Utilities, ORALayout, OraSQLEdit, cxClasses, Math, StrUtils, ORAStyles, cxGridCustomTableView,
  ImageSelector, cxStorage, Clipbrd, cxRichEdit, OraClasses, LayoutData;

{$R *.dfm}

{ TfrmORALayoutCustomize }
type
  TcxCustomEditAccess = class(TcxCustomEdit);
  TcxEditingControlAccess = class(TcxEditingControl);
  TComponentAccess = class(TComponent);
  TdxCustomLayoutItemAccess = class(TdxCustomLayoutItem);

  TORAControlCopy_rec = record
    Control: TORAControlProperties;
    Controller: TORALayoutController;
  end;

  TType_mapping_rec = record
    DataTypeName: String;
    PropertiesClass: TORAComponentPropertiesClass;
    ComponentClass: TComponentClass;
  end;

const
  cButtonPropertyNames: array [0 .. 1] of String = ('OnClickStart', 'OnClickFinish');
  cSrcPropertyNames: array [0 .. 0] of String = ('srcSQL');
  cTextEditPropertyNames: array [0 .. 0] of String = ('ImmediatePost');
  cSignature: AnsiString = 'ORALayoutForm';
  cFormHandleName: String = 'FORM_HANDLE';
  cActiveControl: String = 'ACTIVECONTROL';
  cClipboard: String = 'CLIPBOARD';
  cXLSWorksheets: String = 'XLS_WORKSHEETS';

var
  type_mapping: array of TType_mapping_rec;
  ORAControlCopy: TORAControlCopy_rec;

procedure doAfterExecute_std(const pLayout: IORALayoutInterface; const AQuery: TDataSet);
var
  I: Integer;
begin
  with getLayoutInterface(AQuery), pLayout do
    if (SQL.Text <> '') Or (AQuery.Name = 'InitQuery') then
      for I := 0 to ParamCount - 1 do
        if Params[I].ParamType in [ptOutput, ptInputOutput] then
            Values[Params[I].Name] := Params[I].AsString;
end;

function doBeforeExecute_std(const pLayout: IORALayoutInterface; const AQuery: TDataSet): Boolean;
var
  I: Integer;
  oldVal, newVal: String;
begin
  Result := False;
  if AQuery = nil then exit;
  with getLayoutInterface(AQuery) do begin
    if SQL.Text = '' then exit;
    ParamCheck := True;
    for I := 0 to ParamCount - 1 do begin
      if AnsiPos(cClipboard, AnsiUpperCase(Params[I].Name)) <> 0 then begin
        with Params[I] do begin
          ParamType := ptInput;
          setBlobParam(I, Clipboard.AsText + #13#10);
        end;
      end
      else if AnsiPos(cXLSWorksheets, AnsiUpperCase(Params[I].Name)) <> 0 then begin
        with Params[I] do begin
          ParamType := ptInput;
          setBlobParam(I, HostInterface.getXLSWorksheets(1 { [xlssoWorksheets] } ));
        end;
      end
      else if AnsiPos('CURSOR', AnsiUpperCase(Params[I].Name)) = 0 then begin
        with Params[I] do
          if DataType <> ftWideString then begin
            DataType := ftWideString;
            Size := 4000;
            ParamType := ptInputOutput;
          end;
        oldVal := Params[I].AsString;
        newVal := pLayout.Values[Params[I].Name];
        if oldVal <> newVal then begin
          Result := True;
          Params[I].AsString := newVal;
        end;
      end
      else Params[I].DataType := ftCursor;
    end;
  end;
end;

procedure LayoutStoreProperty(const aWriter: TWriter; const pPropName: String;
  const pValue: Variant);
begin
  if VarIsEmpty(pValue) then exit;

  with aWriter do begin
    WriteString(cFieldBegin);
    WriteString(pPropName);
    WriteVariant(pValue);
  end;
end;

procedure LayoutRestoreProperty(const aReader: TReader; var pPropName: String; var pValue: Variant);
begin
  with aReader do begin
    pPropName := ReadString;
    pValue := ReadVariant;
  end;
end;

function get_controller(const pComponent: TComponent): TORALayoutController;
var
  vForm: TfrmORALayout;
begin
  vForm := TfrmORALayout(getOwnerByClass(pComponent, TfrmORALayout));
  if vForm = nil then Result := nil
  else Result := vForm.Controller;
end;

function get_ORADataType(pDataTypeName: String): Longint; overload;
begin
  for Result := Low(type_mapping) to High(type_mapping) do
    if type_mapping[Result].DataTypeName = pDataTypeName then exit;
  Result := -1;
end;

function get_ORADataType(pComponentClass: TComponentClass): Longint; overload;
begin
  for Result := Low(type_mapping) to High(type_mapping) do
    if type_mapping[Result].ComponentClass = pComponentClass then exit;
  Result := -1;
end;

procedure register_ORADataType(pDataTypeName: String;
  pPropertiesClass: TORAComponentPropertiesClass; pComponentClass: TComponentClass);
var
  vTypeIndex: Longint;
begin
  vTypeIndex := get_ORADataType(pDataTypeName);
  if vTypeIndex < 0 then begin
    vTypeIndex := get_ORADataType(pComponentClass);
    if vTypeIndex < 0 then begin
      SetLength(type_mapping, Length(type_mapping) + 1);
      vTypeIndex := High(type_mapping);
    end;
  end;
  with type_mapping[vTypeIndex] do begin
    DataTypeName := pDataTypeName;
    ComponentClass := pComponentClass;
    PropertiesClass := pPropertiesClass;
  end;
end;

function getORAComponentPropertiesClass(const pComponentClass: TComponentClass)
  : TORAComponentPropertiesClass;
var
  vTypeIndex: Longint;
begin
  vTypeIndex := get_ORADataType(pComponentClass);
  if vTypeIndex = -1 then vTypeIndex := get_ORADataType(nil);
  Result := type_mapping[vTypeIndex].PropertiesClass;
end;

procedure TfrmORALayoutCustomize.acORALayoutCopyExecute(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  if tvVisibleItems.SelectionCount = 1 then
    if TComponent(tvVisibleItems.Selections[0].Data) is TdxLayoutItem then
      with ORAControlCopy do begin
        Controller := self.Controller;
        I := Controller.ControlCollection.IndexOf
          (TdxLayoutItem(TComponent(tvVisibleItems.Selections[0].Data)).Control);
        if I >= 0 then Control := Controller.ControlCollection[I]
        else Control := nil;
      end;
end;

procedure TfrmORALayoutCustomize.acORALayoutPasteExecute(Sender: TObject);
var
  vNameSave: String;
  vGItem: TdxCustomLayoutItem;
  procedure AssignFromIItem(const pGroup: TdxLayoutGroup);
  var
    vStream: TMemoryStream;
    vWriter: TWriter;
    vReader: TReader;
    vDestItem: TdxLayoutItem;
    vDestControl: TORAControlProperties;

  begin
    vDestItem := TdxLayoutItem(pGroup.CreateItem(TdxLayoutItem));
    try
      vDestItem.Assign(ORAControlCopy.Control.LayoutItem);
    except
    end;
    vDestControl := Controller.ControlCollection.Add(ORAControlCopy.Control.DataType, vDestItem);
    vStream := TMemoryStream.Create;
    try
      vWriter := TWriter.Create(vStream, 2048);
      try
        with ORAControlCopy.Control do begin
          vNameSave := Name;
          Name := 'copiing_process';
          StoreToStream(vWriter);
          Name := vNameSave;
        end;
      finally
        vWriter.Free;
      end;
      vStream.Position := 0;
      vReader := TReader.Create(vStream, 2048);
      try
        with vDestControl do begin
          vNameSave := Name;
          RestoreFromStream(vReader);
          Name := vNameSave;
        end;

      finally
        vReader.Free;
      end;
    finally
      vStream.Free;
    end;
  end;

begin
  inherited;
  if ORAControlCopy.Control = nil then exit;
  vGItem := nil;
  if tvVisibleItems.SelectionCount = 1 then
      vGItem := TdxCustomLayoutItem(tvVisibleItems.Selections[0].Data);
  if vGItem = nil then vGItem := Controller.Layout.Items;
  if not(vGItem is TdxLayoutGroup) then vGItem := vGItem.Parent;
  AssignFromIItem(TdxLayoutGroup(vGItem));
end;

procedure TfrmORALayoutCustomize.acStoreExecute(Sender: TObject);
begin
  inherited;
  TfrmORALayout(Controller.FForm).btnSaveClick(self);
end;

// procedure TfrmORALayoutCustomize.acTreeViewItemsDeleteExecute(Sender: TObject);
// var
// AList: TComponentList;
// begin
// if tvVisibleItems.IsEditing then tvVisibleItems.Selected.EndEdit(True);
// AList := TComponentList.Create;
// try
// cxTreeViewGetSelection(tvVisibleItems.InnerTreeView, AList);
// DeleteItems(AList, tvVisibleItems.InnerTreeView);
// // RefreshTreeView;
// UpdateSelection;
// finally
// AList.Free;
// end;
// end;

procedure TfrmORALayoutCustomize.ClearInspected;
var
  vObj: TPersistent;
begin
  if rttiProperties.InspectedObject <> nil then begin
    vObj := rttiProperties.InspectedObject;
    rttiProperties.InspectedObject := nil;
    if vObj is TORAControlProperties then vObj.Free;
  end;
end;

// procedure TfrmORALayoutCustomize.DeleteItems(AList: TComponentList; ATreeView: TTreeView);
// var
// vControl: TControl;
// begin
// if AList.Count = 0 then exit;
// Container.SaveToUndo;
// BeginUpdate;
// ATreeView.Items.BeginUpdate;
// try
// Container.BeginUpdate;
// try
// while AList.Count > 0 do begin
// if AList[0] is TdxLayoutItem then
// with TdxLayoutItem(AList[0]) do
// if Control <> nil then begin
// vControl := Control;
// Controller.ControlCollection.Removed(vControl);
// Control := nil;
// vControl.Free;
// end;
// AList[0].Free;
// end;
// finally
// Container.EndUpdate;
// end;
// finally
// ATreeView.Items.EndUpdate;
// CancelUpdate;
// end;
// end;

procedure TfrmORALayoutCustomize.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  rttiProperties.CloseNonModalEditors;
  rttiCommonProperties.CloseNonModalEditors;
  inherited;
end;

function TfrmORALayoutCustomize.getController: TORALayoutController;
begin
  Result := get_controller(Container);
end;

procedure TfrmORALayoutCustomize.InitInspected;
var
  // vTypeIndex: Longint;
  vObj: TORAComponentProperties;
  vComp: TComponent;
begin
  vComp := FItem;
  if vComp <> nil then begin
    if (vComp is TdxLayoutItem) And (TdxLayoutItem(vComp).Control <> nil) then
        vComp := TdxLayoutItem(vComp).Control;
    // vTypeIndex := get_ORADataType(TControlClass(vComp.ClassType));
    // if vTypeIndex = -1 then vTypeIndex := get_ORADataType(nil);
    // vObj := type_mapping[vTypeIndex].PropertiesClass.Create(vComp, nil);
    vObj := getORAComponentPropertiesClass(TComponentClass(vComp.ClassType)).Create(vComp, nil);
    rttiProperties.InspectedObject := vObj;
  end;
end;

procedure TfrmORALayoutCustomize.setItem(const pItem: TComponent);
begin
  if FItem = pItem then exit;
  ClearInspected;
  FItem := pItem;
  InitInspected;
end;

procedure TfrmORALayoutCustomize.RefreshEnableds;
var
  aCanModify: Boolean;
begin
  inherited;
  if not IsLocked then begin
    aCanModify := CanAddItem And CanModify;
    acORALayoutPaste.Enabled := (ORAControlCopy.Control <> nil) And aCanModify;
    acORALayoutCopy.Enabled := aCanModify And (tvVisibleItems.SelectionCount = 1) and
      (TComponent(tvVisibleItems.Selections[0].Data) is TdxLayoutItem);
  end;
end;

procedure TfrmORALayoutCustomize.RefreshSelection;
begin
  ClearInspected;
  InitInspected;
end;

procedure TfrmORALayoutCustomize.rttiPropertiesPropertyChanged(Sender: TObject);
var
  vController: TORALayoutController;
begin
  inherited;
  vController := Controller;
  if (vController <> nil) And (vController.FForm.Visible) then
      vController.State := vController.State + [ocsLayoutModified];
  if Sender = rttiProperties then
    with rttiProperties do
      if (FocusedRow <> nil) And (InspectedObject is TORAComponentProperties) then
          TORAComponentProperties(InspectedObject).OnPropertyChanged(TcxPropertyRow(FocusedRow));

end;

{ TORAComponentProperties }

procedure TORAComponentProperties.afterOpenData;
begin

end;

procedure TORAComponentProperties.beforeOpenData;
begin

end;

constructor TORAComponentProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  FIsInitSourceData := False;
  if AComponent = nil then raise Exception.Create('Недопустимое использование nil');
  FComponent := AComponent;
  if AController = nil then inherited Create(nil)
  else inherited Create(AController.ControlCollection);
end;

function TORAComponentProperties.getController: TORALayoutController;
begin
  if (Component <> nil) And (Component.Owner is TORALayoutController) then
      Result := TORALayoutController(Component.Owner)
  else Result := get_controller(Component);
end;

function TORAComponentProperties.getDataSet: TDataSet;
begin
  Result := nil;
end;

function TORAComponentProperties.GetDisplayName: string;
begin
  Result := Caption;
  if Result = '' then Result := Name
  else Result := Result + ' - ' + Name;
end;

function TORAComponentProperties.getName: String;
begin
  Result := Component.Name;
end;

procedure TORAComponentProperties.setName(const Value: String);
begin
  if Value = '' then Component.Name := CreateUniqueName(nil, nil, Component, '', '')
  else Component.Name := Value;
end;

function TORAComponentProperties.getStorePropertyCount: Longint;
begin
  Result := 0;
end;

function TORAComponentProperties.getStorePropertyIndex(const pName: String): Integer;
var
  vCnt: Longint;
begin
  vCnt := StorePropertyCount - 1;
  for Result := 0 to vCnt do
    if AnsiSameText(pName, StorePropertyName[Result]) then exit;
  Result := -1;
end;

function TORAComponentProperties.getStorePropertyName(const pIndex: Integer): String;
begin
  Result := PString(Longint(StorePropertyNames) + pIndex * Sizeof(PString))^;
end;

function TORAComponentProperties.startInitSourceData: Boolean;
begin
  Result := not FIsInitSourceData And (srcData <> nil) And
    (getLayoutInterface(srcData).SQL.Text <> '');
  if Result then begin
    FIsInitSourceData := True;
    Controller.suspend_timer;
  end;
end;

procedure TORAComponentProperties.endInitSourceData;
begin
  FIsInitSourceData := False;
  Controller.resume_timer;
end;

procedure TORAComponentProperties.initSourceData;
var
  vOldVal: String;
begin
  if startInitSourceData then
    try
      with srcData, getLayoutInterface(srcData) do
        if Controller.doBeforeExecute(srcData) or not Active then begin
          if self is TORAControlProperties then vOldVal := TORAControlProperties(self).Value;
          if LayoutSession <> Controller.Session then LayoutSession := Controller.Session;
          try
            if Active then Close;
            try
              beforeOpenData;
              Open;
            finally
              afterOpenData
            end;
            ReadOnly := (FindField('ROWID') = nil) And (UpdatingTable = '');
          except
            on E: Exception do Controller.showException(self.Name + '(srcData):', E);
          end;
          if self is TORAControlProperties then
            with TORAControlProperties(self) do begin
              Value := vOldVal;
              if vOldVal <> Value then Controller.OnEditValueChanged(TORAControlProperties(self));
            end;
        end;
    finally
      endInitSourceData;
    end;
end;

procedure TORAComponentProperties.StoreToStream(const pWriter: TWriter);
var
  I: Longint;
  vName: String;
begin
  with pWriter do begin
    IgnoreChildren := True;
    WriteRootComponent(Component);
    for I := 0 to StorePropertyCount - 1 do begin
      vName := StorePropertyName[I];
      LayoutStoreProperty(pWriter, vName, StoreProperty[vName]);
    end;
    WriteString(cFieldBlockEnd);
  end;
end;

procedure TORAComponentProperties.RestoreFromStream(const pReader: TReader);
var
  vSign: String;
  val: Variant;
  vName: String;
begin
  with pReader do begin
    ReadRootComponent(Component);
    repeat
      vSign := ReadString;
      if vSign = cFieldBegin then begin
        LayoutRestoreProperty(pReader, vName, val);
        StoreProperty[vName] := val;
      end;
    until vSign = cFieldBlockEnd;
  end;
end;

{ TORAControlProperties }

constructor TORAControlProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;
  if AController <> nil then begin
    Value := Unassigned;
    if Component is TcxCustomEdit then
        TcxCustomEditAccess(Component).Properties.OnEditValueChanged := OnEditValueChanged
    else if Component is TCustomEdit then TEdit(Component).OnChange := OnEditValueChanged;
  end;
end;

function TORAControlProperties.getCaption: String;
begin
  // if Component is TcxCheckBox then Result := TcxCheckBox(Component).Caption  else
  if LayoutItem <> nil then Result := LayoutItem.CaptionOptions.Text
  else Result := '';
end;

function TORAControlProperties.getDataType: Longint;
begin
  for Result := Low(type_mapping) to High(type_mapping) do
    with type_mapping[Result] do
      if (PropertiesClass = self.ClassType) And (ComponentClass = Component.ClassType) then exit;
  Result := -1;
end;

function TORAControlProperties.getEditStyle: TcxEditStyle;
begin
  if Component is TcxCustomEdit then Result := TcxCustomEdit(Component).Style
  else Result := nil;
end;

function TORAControlProperties.GetHeight: Integer;
begin
  if Component is TControl then Result := TControl(Component).Height
  else if Component is TdxCustomLayoutItem then Result := TdxCustomLayoutItem(Component).Height
  else Result := 0;
end;

function TORAComponentProperties.getLayoutItem: TdxCustomLayoutItem;
begin
  if Component is TdxCustomLayoutItem then Result := TdxCustomLayoutItem(Component)
  else if Component is TControl then Result := Controller.Layout.FindItem(TControl(Component))
  else Result := nil;
end;

function TORAControlProperties.GetSubControl(const pIndex: Integer): TComponent;
begin
  Result := nil;
end;

function TORAControlProperties.GetSubControlCount: Integer;
begin
  Result := 0;
end;

function TORAControlProperties.GetSubValue(const pSubControlName: String): String;
begin
  Result := '';
end;

procedure TORAComponentProperties.OnPropertyChanged(const aPropertyRow: TcxPropertyRow);
begin
  if LayoutItem <> nil then TdxCustomLayoutItemAccess(LayoutItem).Changed;
end;

function TORAControlProperties.getTabbedOptions: TdxLayoutTabbedOptions;
begin
  if LayoutItem is TdxLayoutGroup then Result := TdxLayoutGroup(LayoutItem).TabbedOptions
  else Result := nil;
end;

function TORAControlProperties.GetTabOrder: Integer;
begin
  if Component is TWinControl then Result := TWinControl(Component).TabOrder
  else Result := 0;
end;

function TORAControlProperties.getTypeName: String;
begin
  Result := type_mapping[DataType].DataTypeName;
end;

function TORAControlProperties.GetValue: String;
begin
  if Component is TcxCustomEdit then Result := VarToStr(TcxCustomEdit(Component).EditValue)
  else if Component is TCustomEdit then Result := TCustomEdit(Component).Text
  else Result := '';
end;

function TORAControlProperties.GetWidth: Integer;
begin
  if Component is TControl then Result := TControl(Component).Width
  else if Component is TdxCustomLayoutItem then Result := TdxCustomLayoutItem(Component).Width
  else Result := 0;
end;

function TORAControlProperties.indexOfSubControl(const pSubControlName: String): Integer;
begin
  Result := -1;
end;

procedure TORAControlProperties.OnEditValueChanged(Sender: TObject);
begin
  if (Component is TCustomEdit) And not TCustomEdit(Component).Modified then exit;
  Controller.OnEditValueChanged(self);
end;

procedure TORAControlProperties.setCaption(const Value: String);
begin
  if LayoutItem <> nil then LayoutItem.CaptionOptions.Text := Value
end;

procedure TORAControlProperties.setDataType(const Value: Longint);
begin
  Controller.ControlCollection.setDataType(LayoutItem, Value);
end;

procedure TORAControlProperties.SetHeight(const Value: Integer);
begin
  if Component is TControl then TControl(Component).Height := Value
  else if Component is TdxCustomLayoutItem then TdxCustomLayoutItem(Component).Height := Value
end;

procedure TORAControlProperties.SetSubValue(const pSubControlName, Value: String);
begin

end;

procedure TORAControlProperties.SetTabOrder(const Value: Integer);
begin
  if Component is TWinControl then TWinControl(Component).TabOrder := Value;
end;

procedure TORAControlProperties.SetValue(const aValue: String);
begin
  if Component is TcxCustomEdit then begin
    if VarToStr(TcxCustomEdit(Component).EditValue) <> aValue then
        TcxCustomEdit(Component).EditValue := aValue
  end
  else if Component is TCustomEdit then begin
    if TCustomEdit(Component).Text <> aValue then TCustomEdit(Component).Text := aValue;
  end;
end;

procedure TORAControlProperties.SetWidth(const Value: Integer);
begin
  if Component is TControl then TControl(Component).Width := Value
  else if Component is TdxCustomLayoutItem then TdxCustomLayoutItem(Component).Width := Value
end;

function TORADataTypeProperty.GetAttributes: TcxPropertyAttributes;
begin
  if PropList[0].PropInfo.SetProc = nil then Result := [ipaValueList, ipaReadOnly]
  else Result := [ipaValueList, ipaSortList, ipaRevertable];
end;

function TORADataTypeProperty.GetValue: string;
var
  v: Longint;
begin
  v := GetOrdValue;
  if v < Low(type_mapping) then Result := ''
  else Result := type_mapping[v].DataTypeName;
end;

procedure TORADataTypeProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := Low(type_mapping) to High(type_mapping) do
    if type_mapping[I].PropertiesClass.InheritsFrom(TORAControlProperties) then
        Proc(type_mapping[I].DataTypeName);
end;

procedure TORADataTypeProperty.SetValue(const Value: string);
var
  I: Integer;
begin
  I := get_ORADataType(Value);
  with GetTypeData(GetPropType)^ do
    if (I < Low(type_mapping)) or (I > High(type_mapping)) then
        raise EcxPropertyError.Create(SInvalidPropertyValue);
  SetOrdValue(I);
  if Inspector.Owner is TfrmORALayoutCustomize then
      TfrmORALayoutCustomize(Inspector.Owner).RefreshSelection;
end;

{ TORANumberEditProperties }

function TORANumberEditProperties.getDisplayFormat: String;
begin
  if Component is TcxCustomTextEdit then
      Result := TcxCustomTextEdit(Component).Properties.DisplayFormat;
end;

procedure TORANumberEditProperties.setDisplayFormat(const Value: String);
begin
  if Component is TcxCustomTextEdit then
      TcxCustomTextEdit(Component).Properties.DisplayFormat := Value;
end;

{ TORATextEditProperties }

constructor TORATextEditProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;
  if AController <> nil then Properties.OnChange := OnChange;
end;

function TORATextEditProperties.getImmediatePost: Boolean;
begin
  Result := Properties.ImmediatePost;
end;

function TORATextEditProperties.getProperties: TcxCustomEditProperties;
begin
  if Component is TcxCustomEdit then Result := TcxCustomEditAccess(Component).Properties
  else Result := nil;
end;

function TORATextEditProperties.getStoreProperty(const pName: String): Variant;
begin
  case StorePropertyIndex[pName] of
    0: Result := ImmediatePost;
  else inherited;
  end;
end;

function TORATextEditProperties.getStorePropertyCount: Longint;
begin
  Result := Length(cTextEditPropertyNames) + inherited;
end;

function TORATextEditProperties.getStorePropertyNames: PString;
begin
  Result := @cTextEditPropertyNames[0];
end;

procedure TORATextEditProperties.OnChange(Sender: TObject);
begin
  if (Component is TcxCustomTextEdit) then
    with TcxCustomTextEdit(Component) do
      if ImmediatePost then begin
        EditValue := EditingText;
        OnEditValueChanged(Sender);
      end;
end;

procedure TORATextEditProperties.setImmediatePost(const Value: Boolean);
begin
  Properties.ImmediatePost := Value;
end;

procedure TORATextEditProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  case StorePropertyIndex[pName] of
    0: ImmediatePost := VarAsType(Value, varBoolean);
  else inherited;
  end;
end;

{ TORADataSetProperty }

procedure TORADataSetProperty.Edit;
var
  vPersistent: TPersistent;
begin
  vPersistent := TPersistent(GetOrdValue);
  if vPersistent is TDataSet then
    with getLayoutInterface(TDataSet(vPersistent)) do begin
      if LayoutSession = nil then
        if Inspector.Owner is TfrmORALayoutCustomize then
            LayoutSession := TfrmORALayoutCustomize(Inspector.Owner).Controller.Session
        else LayoutSession := mainSessionComponent;

      if ExecuteSQLEditor(TDataSet(vPersistent)) then PostChangedNotification;
    end;
end;

function TORADataSetProperty.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaDialog, ipaReadOnly];
end;

{ TORALayoutController }

function TORALayoutController.ClearLayout: Boolean;
var
  vItem: TdxLayoutItem;
begin
  Result := { chkDataModified And } chkLayoutModified;
  if not Result then exit;

  with ControlCollection do
    while Count > 0 do
      with Items[Count - 1] do begin
        if Component is TControl then begin
          vItem := Layout.FindItem(TControl(Component));
          if vItem <> nil then vItem.Control := nil;
        end;
        FreeAndNil(FComponent);
        Free;
      end;

  Layout.Clear;
  FState := FState - [ocsLayoutModified];
end;

constructor TORALayoutController.Create(AOwner: TComponent);
begin
  if AOwner is TfrmORALayout then begin

    inherited;
    FForm := TfrmORALayout(AOwner);
    FControlCollection := TControlCollection.Create(self);
    FInitQuery := stdLayoutQuery(self);
    FInitQuery.Name := 'InitQuery';
    FChangeQuery := stdLayoutQuery(self);
    FChangeQuery.Name := 'ChangeQuery';
    FCloseQuery := stdLayoutQuery(self);
    FCloseQuery.Name := 'CLoseQuery';
    FTimerQuery := stdLayoutQuery(self);
    FTimerQuery.Name := 'TimerQuery';
    FTimerHandle := AllocateHWnd(OnTimerWndProc);
    FTimerInterval := 0;
    FExceptionCount := 0;
    FTimerSuspended := 0;

    if Layout.Container <> nil then begin
      FPrevOnLChanged := Layout.Container.OnChanged;
      FPrevOnSChanged := Layout.Container.OnSelectionChanged;
      Layout.Container.OnChanged := OnLayoutChanged;
      Layout.Container.OnSelectionChanged := OnSelectionChanged;
    end;
    FState := [];

    Layout.CustomizeFormClass := TfrmORALayoutCustomize;
  end
  else raise Exception.Create('Недопустимое использование контроллера');
end;

procedure TORALayoutController.DblClickHandler(const pOnDblClick: TDataSet; var AHandled: Boolean);
begin
  if Assigned(HostInterface.preLayoutButtonClick) then HostInterface.preLayoutButtonClick(self);
  if pOnDblClick <> nil then
    with pOnDblClick, getLayoutInterface(pOnDblClick) do
      If SQL.Text <> '' then begin
        doBeforeExecute(pOnDblClick);
        try
          Execute;
        except
          on E: Exception do showException(FormCaption + '(dblClick):', E);
        end;
        doAfterExecute(pOnDblClick);
      end;
  if Assigned(HostInterface.afterLayoutButtonClick) then
      HostInterface.afterLayoutButtonClick(self, pOnDblClick);
  if fsModal in FForm.FormState then FForm.ModalResult := mrOk;
end;

destructor TORALayoutController.Destroy;
begin
  if ORAControlCopy.Controller = self then ORAControlCopy.Control := nil;
  FreeAndNil(FControlCollection);
  // useMainSession := True;
  TimerInterval := 0;
  DeallocateHWnd(FTimerHandle);
  FTimerHandle := 0;
  inherited;
end;

procedure TORALayoutController.doAfterExecute(const AQuery: TDataSet);
var
  I: Longint;
begin
  doAfterExecute_std(self, AQuery);
  with ControlCollection do
    for I := 0 to Count - 1 do Items[I].initSourceData;
end;

function TORALayoutController.doBeforeExecute(const AQuery: TDataSet): Boolean;
begin
  Result := doBeforeExecute_std(self, AQuery);
end;

procedure TORALayoutController.DoCloseQuery;
begin
  with getLayoutInterface(CloseQuery) do
    if doBeforeExecute(CloseQuery) or (SQL.Text <> '') then
      try
        Execute;
      except
        on E: Exception do showException(FormCaption + '(close):', E);
      end;
end;

function TORALayoutController.GetCustomization: Boolean;
begin
  Result := TfrmORALayout(FForm).cbEditMode.EditValue
end;

function TORALayoutController.GetHeight: Longint;
begin
  Result := FForm.Height;
end;

function TORALayoutController.getIconIndex: TImageIndex;
begin
  Result := TfrmORALayout(FForm).IconIndex;
end;

function TORALayoutController.getLayout: TdxLayoutControl;
begin
  Result := TfrmORALayout(FForm).dxLayoutControl1;
end;

function TORALayoutController.GetLayoutName: String;
begin
  Result := FForm.Caption;
end;

function TORALayoutController.GetLayoutValue(const pControlName: String): String;
begin
  Result := ControlCollection.Values[pControlName];
end;

function TORALayoutController.getSession: TComponent;
begin
  Result := getLayoutInterface(FInitQuery).LayoutSession;
end;

function TORALayoutController.GetWidth: Longint;
begin
  Result := FForm.Width;
end;

procedure TORALayoutController.get_instance_by_name(Reader: TReader; const Name: string;
  var Instance: Pointer);
var
  S, P: PChar;
  vName: string;
  vName0: string;
  function prepare_name(pName: String): String;
  begin
    P := PChar(pName);
    S := P;
    while not CharInSet(P^, ['.', '-', #0]) do Inc(P);
    SetString(Result, S, P - S);
  end;

begin
  if Reader.Owner = nil then exit;
  vName := Name;
  while True do begin
    if vName = '' then exit;
    vName0 := prepare_name(vName);
    if Application.FindComponent(vName0) <> nil then exit;
    if (CompareText(Reader.Owner.Name, vName0) = 0) or
      ((Reader.Owner.Owner <> nil) And (CompareText(Reader.Owner.Owner.Name, vName0) = 0)) then
        vName := copy(vName, Length(vName0) + 2, 99999)
    else begin
      Instance := Reader.Owner.FindComponent(vName0);
      if (Instance = nil) And (Reader.Owner.Owner <> nil) then
          Instance := Reader.Owner.Owner.FindComponent(vName0);
      exit;
    end;
  end;
end;

procedure TORALayoutController.initControls(const AController: TORALayoutController);
var
  I: Integer;
  ndx: Integer;
begin
  try
    State := State + [ocsRestoring];
    with ControlCollection do
      for I := 0 to Count - 1 do begin
        ndx := AController.ControlCollection.IndexOf(Items[I].Name);
        if ndx >= 0 then Items[I].Value := AController.ControlCollection.Items[ndx].Value;
      end;
  finally
    State := State - [ocsRestoring];
  end;
  OnEditValueChanged(nil);
end;

procedure TORALayoutController.initControls(const initPLSQL: String);
var
  vExtInitQuery: TDataSet;
  vExtInitQueryI: ILayoutQueryInterface;
  I, vExceptionCount: Integer;
  vParam: TParam;
  vChanged: Boolean;
  vStr: String;
begin
  vExtInitQuery := stdLayoutQuery(self, Session, initPLSQL);
  vExtInitQueryI := getLayoutInterface(vExtInitQuery);
  try
    if initPLSQL <> '' then
      with vExtInitQueryI do begin
        for I := 0 to ParamCount - 1 do
          with Params[I] do begin
            DataType := ftWideString;
            Size := 4000;
            ParamType := ptInputOutput;
          end;
        vParam := Params.FindParam(cFormHandleName);
        if vParam <> nil then vParam.AsString := ControlCollection.Values[cFormHandleName];
        try
          Execute;
        except
          on E: Exception do begin
            showException(FormCaption + '(extInit):', E);
            exit;
          end;
        end;
      end;
    with InitQuery, getLayoutInterface(InitQuery) do begin
      if SQL.Text <> '' then begin
        for I := 0 to ParamCount - 1 do
          with Params[I] do begin
            DataType := ftWideString;
            Size := 4000;
            ParamType := ptInputOutput;
            if AnsiCompareText(cFormHandleName, Name) = 0 then
                AsString := ControlCollection.Values[cFormHandleName]
            else begin
              if vExtInitQueryI.Params.Count = 0 then vParam := nil
              else vParam := vExtInitQueryI.Params.FindParam(Params[I].Name);
              if vParam = nil then AsString := ''
              else AsString := vParam.AsString;
            end;
          end;
        try
          Execute;
        except
          on E: Exception do begin
            showException(FormCaption + '(intInit):', E);
            exit;
          end;
        end;
      end;
      for I := 0 to vExtInitQueryI.Params.Count - 1 do
        with vExtInitQueryI.Params[I] do begin
          vParam := Params.FindParam(Name);
          if vParam = nil then begin
            vStr := AsString;
            with Params.CreateParam(ftWideString, Name, ptInputOutput) do begin
              Size := 4000;
              AsString := vStr;
            end;
          end;
        end;
    end;
  finally
    vExtInitQueryI := nil;
    vExtInitQuery.Free;
  end;
  I := 0;
  vExceptionCount := FExceptionCount;
  repeat
    try
      State := State + [ocsRestoring];
      doAfterExecute(InitQuery);
    finally
      State := State - [ocsRestoring];
    end;
    if vExceptionCount < FExceptionCount then exit;
    vChanged := ocsRestoreChanging in State;
    OnEditValueChanged(nil);
    if vExceptionCount < FExceptionCount then exit;
    I := I + 1;
    if I > 10 then begin
      MessageDlg(FormCaption + ': инициализация зациклена.', mtError, [mbOK], 0);
      exit;
    end;
  until not vChanged;
end;

procedure TORALayoutController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) And (AComponent is TControl) And (ControlCollection <> nil) then begin
    ControlCollection.Removed(TControl(AComponent));
  end;
end;

procedure TORALayoutController.setCaption(const Value: String);
begin
  FForm.Caption := Value;
end;

procedure TORALayoutController.SetCustomization(const Value: Boolean);
// var
// I: Integer;
begin
  if Customization <> Value then begin
    TfrmORALayout(FForm).cbEditMode.EditValue := Value;
  end;
  Layout.Customization := Customization;

  // with FForm do
  // for I := 0 to ComponentCount - 1 do
  // if Components[I] is TdxCustomLayoutItem then
  // TComponentAccess(Components[I]).SetDesigning(Value);
  with Layout do begin
    if Value And (CustomizeForm <> nil) then
      with TfrmORALayoutCustomize(CustomizeForm) do begin
        Caption := Caption + ': ' + FForm.Caption;
        rttiCommonProperties.InspectedObject := self;
      end;
  end;
end;

procedure TORALayoutController.SetHeight(const Value: Longint);
begin
  FForm.Height := Value;
end;

procedure TORALayoutController.setIconIndex(const Value: TImageIndex);
begin
  TfrmORALayout(FForm).IconIndex := Value;
end;

procedure TORALayoutController.SetInterval(const Value: Cardinal);
begin
  if FTimerInterval = Value then exit;
  FTimerInterval := Value;
  KillTimer(FTimerHandle, 1);
  if FTimerInterval <> 0 then
    if SetTimer(FTimerHandle, 1, FTimerInterval, nil) = 0 then
        raise EOutOfResources.Create('Нет больше места. Даже для таймера.');
end;

procedure TORALayoutController.SetLayoutValue(const pControlName, Value: String);
begin
  ControlCollection.Values[pControlName] := Value;
end;

procedure TORALayoutController.SetWidth(const Value: Longint);
begin
  FForm.Width := Value;
end;

procedure TORALayoutController.showException(const pExceptionSrc: String;
  const p_Exception: Exception);
begin
  FExceptionCount := FExceptionCount + 1;
  MessageDlg(pExceptionSrc + #13#10 + p_Exception.Message, mtError, [mbOK], 0);
end;

procedure TORALayoutController.StoreToStream(pStream: TStream);
var
  vWriter: TWriter;

  I: Longint;
  procedure write_myself();
  var
    vProps: PPropList;
    I, vCount: Longint;
    val: Variant;
  begin
    vCount := GetPropList(self.ClassInfo, tkProperties, nil);
    GetMem(vProps, vCount * Sizeof(Pointer));
    try
      GetPropList(self.ClassInfo, tkProperties, vProps, False);
      with vWriter do begin
        WriteStr(cSignature);
        for I := 0 to vCount - 1 do begin
          val := Unassigned;
          if Assigned(vProps[I].GetProc) And Assigned(vProps[I].SetProc) then begin
            val := GetPropValue(self, vProps[I])
          end
          else if (vProps[I].PropType^.Kind = tkClass) And
            (GetObjectPropClass(vProps[I]).InheritsFrom(TDataSet)) then
            with getLayoutInterface(TDataSet(GetOrdProp(self, vProps[I]))) do
              if SQL.Text <> '' then val := SQL.Text;
          if val <> Unassigned then begin
            WriteString(cFieldBegin);
            WriteStr(vProps[I].Name);
            WriteVariant(val);
          end;
        end;
        WriteString(cFieldBlockEnd);
        FlushBuffer;
      end;
    finally
      FreeMem(vProps);
    end;
  end;

begin
  vWriter := TWriter.Create(pStream, 2048);
  try
    write_myself();
    Layout.Container.StoreToStream(pStream, String(cSignature));
    with ControlCollection do
      for I := 0 to Count - 1 do
        with TORAControlProperties(Items[I]) do begin
          with vWriter do begin
            WriteString(cControlBegin);
            WriteString(LayoutItem.Name);
            WriteString(DataTypeName);
          end;
          StoreToStream(vWriter);
        end;
    vWriter.WriteString(cControlBlockEnd);
  finally
    vWriter.Free;
  end;
  FState := FState - [ocsLayoutModified];
end;

procedure TORALayoutController.suspend_timer;
begin
  FTimerSuspended := FTimerSuspended + 1;
end;

procedure TORALayoutController.ButtonClickHandler(const pColumn: TComponent;
  const pOnClickStart: TDataSet; const pOnClickFinish: TDataSet);
  procedure run_query(const pQuery: TDataSet);
  var
    vStr: string;
  begin
    with pQuery, getLayoutInterface(pQuery) do
      if (pQuery <> nil) And (SQL.Text <> '') then begin
        LayoutSession := Session;
        doBeforeExecute(pQuery);
        try
          Execute;
        except
          on E: Exception do begin
            if pColumn <> nil then vStr := pColumn.Name
            else vStr := '';
            showException('Button:' + vStr + ',' + pQuery.Name + ':', E);
            FForm.ModalResult := mrNone;
          end;
        end;
        doAfterExecute(pQuery);
      end;
  end;

begin
  if self = nil then exit;
  with ControlCollection do begin
    Values['BUTTON_REPEAT'] := '';
    repeat
      if Assigned(HostInterface.preLayoutButtonClick) then HostInterface.preLayoutButtonClick(self);
      run_query(pOnClickStart);
      if Assigned(HostInterface.afterLayoutButtonClick) then
          HostInterface.afterLayoutButtonClick(self, pOnClickStart);
      run_query(pOnClickFinish);
    until Values['BUTTON_REPEAT'] = '';
  end;
  if pColumn is TcxCustomGridTableItem then begin
    try
      TcxCustomGridTableItem(pColumn).GridView.DataController.Post;
    except
    end;
    if FForm = Screen.ActiveForm then TcxCustomGridTableItem(pColumn).GridView.Site.SetFocus;
  end
  else if pColumn is TcxEditingControl then TcxEditingControlAccess(pColumn).DataController.Post
  else OnEditValueChanged(nil);
end;

function TORALayoutController.chkLayoutModified: Boolean;
begin
  if Customization then Customization := False;

  Result := not(ocsLayoutModified in State);
  if Result then exit;
  Result := True;
  case MessageDlg('Макет формы "' + TfrmORALayout(FForm).ORAName + '" модифицирован. Сохранить?',
    mtConfirmation, mbYesNoCancel, 0) of
    mrYes: mainSession.saveORAForm(TfrmORALayout(FForm));
    mrCancel: Result := False;
  end;
end;

procedure TORALayoutController.OnEditValueChanged(const AControl: TORAControlProperties);
var
  vLQueryInterface: ILayoutQueryInterface;
begin
  if ocsRestoring in State then begin
    State := State + [ocsRestoreChanging];
    exit;
  end;

  if ocsEditValueChanging in State then begin
    State := State + [ocsMultiValueChanged];
  end
  else
    try
      vLQueryInterface := getLayoutInterface(ChangeQuery);
      suspend_timer;
      State := State + [ocsEditValueChanging];
      repeat
        State := State - [ocsMultiValueChanged];
        if doBeforeExecute(ChangeQuery) then
          try
            vLQueryInterface.Execute;
          except
            on E: Exception do showException('ChangeQuery:', E);
          end;
        doAfterExecute(ChangeQuery);
      until not(ocsMultiValueChanged in State);
    finally
      State := State - [ocsEditValueChanging, ocsRestoreChanging];
      resume_timer;
    end;
end;

procedure TORALayoutController.OnLayoutChanged(Sender: TObject);
  function adopt_one_alien: Boolean;
  var
    vSrcController: TORALayoutController;
    vItem: TdxCustomLayoutItem;
    vControl: TControl;
    I: Longint;
    vRename: Boolean;

  begin
    Result := False;
    with Layout.Container do
      for I := 0 to AbsoluteItemCount - 1 do begin
        vItem := AbsoluteItems[I];
        Result := vItem.Owner <> self.Owner;
        if Result then begin
          FreeAndNil(TdxCustomLayoutItemAccess(vItem).FFloatForm);
          vSrcController := get_controller(vItem);
          vRename := self.Owner.FindComponent(vItem.Name) <> nil;
          self.Owner.InsertComponent(vItem);
          if vRename then vItem.Name := CreateUniqueName(FForm, nil, vItem, '', '');
          if vItem is TdxLayoutItem then begin
            vControl := TdxLayoutItem(vItem).Control;
            if vControl <> nil then
              with vSrcController.ControlCollection do
                  Items[IndexOf(vControl)].Collection := ControlCollection;
          end;
          exit;
        end;
      end;
  end;

begin
  if FForm.Visible then State := State + [ocsLayoutModified];

  if (Layout.Container <> nil) then begin
    while adopt_one_alien do;
    with Layout.Container do
      if Assigned(FPrevOnLChanged) then FPrevOnLChanged(Sender);
  end;
end;

procedure TORALayoutController.OnReadingError(Reader: TReader; const Message: string;
  var Handled: Boolean);
begin
  ShowMessage(Message);
  Handled := True;
end;

procedure TORALayoutController.OnSelectionChanged(Sender: TObject);
begin
  with Layout do begin
    if (Container <> nil) And Assigned(FPrevOnSChanged) then FPrevOnSChanged(Sender);
    if Customization And (CustomizeForm is TfrmORALayoutCustomize) then
        TfrmORALayoutCustomize(CustomizeForm).Item := getActiveLayoutItem;
  end;
end;

procedure TORALayoutController.OnTimerWndProc(var Msg: TMessage);
var
  vExceptionCount: Longint;
begin
  with Msg, getLayoutInterface(TimerQuery) do
    if (Msg = WM_TIMER) And (SQL.Text <> '') then begin
      if FTimerSuspended = 0 then
        try
          suspend_timer;
          begin
            vExceptionCount := FExceptionCount;
            doBeforeExecute(TimerQuery);
            try
              Execute;
            except
              on E: Exception do showException('Timer:', E);
            end;
            doAfterExecute(TimerQuery);
            if vExceptionCount < FExceptionCount then TimerInterval := 0;
          end;
          Result := -1;
        finally
          resume_timer;
        end;
    end
    else Result := DefWindowProc(FTimerHandle, Msg, wParam, lParam);
end;

procedure TORALayoutController.RestoreFromStream(pStream: TStream);
var
  vTypeIndex: Longint;
  vCItem: TdxCustomLayoutItem;
  vReader: TReader;
  vSign: String;
  vStr: String;
  procedure read_myself();
  var
    vSign: String;
    vPropName: String;
    val: Variant;
    vProp: PPropInfo;
  begin
    with vReader do begin
      if ReadStr() <> String(cSignature) then raise Exception.Create('Нарушен формат данных');
      repeat
        vSign := ReadString;
        if vSign = cFieldBegin then begin
          vPropName := ReadStr();
          val := ReadVariant();
          vProp := GetPropInfo(self.ClassInfo, vPropName);
          if (vProp <> nil) then
            if Assigned(vProp.SetProc) then SetPropValue(self, vProp, val)
            else if (vProp.PropType^.Kind = tkClass) And
              (GetObjectPropClass(vProp).InheritsFrom(TDataSet)) then
                getLayoutInterface(TDataSet(GetOrdProp(self, vProp))).SQL.Text := val;
        end;
      until vSign = cFieldBlockEnd;
      FlushBuffer;
    end;
  end;

begin
  with pStream do
    if Position < Size then begin
      vReader := TReader.Create(pStream, 2048);
      vReader.OnError := OnReadingError;
      vReader.OnFindComponentInstance := get_instance_by_name;
      try
        FState := FState + [ocsRestoring];
        read_myself();
        with Layout do
          try
            BeginUpdate;
            Container.RestoreFromStream(pStream, String(cSignature));
            with vReader do begin
              repeat
                vSign := ReadString;
                if vSign = cControlBegin then begin
                  vStr := ReadString();
                  vCItem := Layout.FindItem(vStr);
                  vStr := ReadString();
                  vTypeIndex := get_ORADataType(vStr);
                  if vTypeIndex = -1 then
                      raise Exception.Create('Неизвестный тип поля "' + vStr + '"');
                  ControlCollection.setDataType(vCItem, vTypeIndex).RestoreFromStream(vReader);
                end;
              until vSign = cControlBlockEnd;
            end;
          finally
            EndUpdate;
          end;
      finally
        FState := FState - [ocsRestoring];
        vReader.Free;
      end;
    end;
  FState := FState - [ocsLayoutModified];
end;

procedure TORALayoutController.resume_timer;
begin
  if FTimerSuspended = 0 then raise Exception.Create('Timer is not suspended');
  FTimerSuspended := FTimerSuspended - 1;
end;

function TORALayoutController.getActiveLayoutItem: TdxCustomLayoutItem;
var
  AList: TList;
  AIntf: IdxLayoutDesignerHelper;
begin
  AList := TList.Create;
  Result := nil;
  try
    if Supports(Layout.Container, IdxLayoutDesignerHelper, AIntf) then begin
      AIntf.GetSelection(AList);
      AIntf := nil;
    end;
    if (AList.Count = 1) then Result := AList[0];
  finally
    AList.Free;
  end;
end;

function TORALayoutController.getCaption: String;
begin
  Result := FForm.Caption;
end;

{ TControlCollection }

function TControlCollection.Add(const ATypeIndex: Longint; const ALayoutItem: TdxLayoutItem)
  : TORAControlProperties;
begin
  if (ATypeIndex <= Low(type_mapping)) Or (ATypeIndex > High(type_mapping)) Or
    (not type_mapping[ATypeIndex].PropertiesClass.InheritsFrom(TORAControlProperties)) Or
    (not type_mapping[ATypeIndex].ComponentClass.InheritsFrom(TControl)) then
      raise Exception.Create('Недопустимый тип объекта');
  with ALayoutItem do begin
    if Control <> nil then raise Exception.Create('Лайоут не пуст')
    else
      with type_mapping[ATypeIndex] do begin
        // Control := TControl(ComponentClass.Create(Controller));
        Control := TControl(ComponentClass.Create(ALayoutItem));
        Control.Name := CreateUniqueName(nil, nil, Control, '', '');
        Result := TORAControlProperties(PropertiesClass.Create(Control, Controller));
      end;
  end;
end;

constructor TControlCollection.Create(const AController: TORALayoutController);
begin
  inherited Create(TORAControlProperties);
  FController := AController;
  FInnerVariables := stdLayoutQuery(AController);
  getLayoutInterface(FInnerVariables).ParamCheck := False;
end;

destructor TControlCollection.Destroy;
begin
  FInnerVariables.Free;
  inherited;
end;

function TControlCollection.GetItem(const Index: Integer): TORAControlProperties;
begin
  Result := TORAControlProperties( inherited GetItem(Index));
end;

type
  TdxLayoutContainerAccess = class(TdxLayoutContainer);

function TControlCollection.GetValue(const pControlName: String): String;
var
  I: Longint;
  vControlName: String;
  PropInfo: PPropInfo;
  vItem: TdxCustomLayoutItem;
  vParam: TParam;
begin
  if pControlName[1] = ':' then vControlName := AnsiUpperCase(PChar(pControlName) + 1)
  else vControlName := AnsiUpperCase(pControlName);
  // Запрос на уникальный идентификатор FORM_HANDLE
  if vControlName = cFormHandleName then begin
    Result := IntToHex(Longint(Controller.FForm), 8);
    exit;
  end;
  // Запрос на определение активного объекта
  if vControlName = cActiveControl then begin
    vItem := TdxLayoutContainerAccess(Controller.Layout.Container).FindFocusedItem();
    if vItem is TdxLayoutItem then begin
      if TdxLayoutItem(vItem).Control <> nil then Result := TdxLayoutItem(vItem).Control.Name
      else Result := vItem.Name;
    end
    else Result := '';
    exit;
  end;
  // Цикл поиска vControlName среди Conltors и subConltors
  for I := 0 to Count - 1 do begin
    if AnsiUpperCase(Items[I].Name) = vControlName then begin
      Result := Items[I].Value;
      exit;
    end;
    if Items[I].indexOfSubControl(vControlName) >= 0 then begin
      Result := Items[I].Values[vControlName];
      exit;
    end;
    if AnsiPos(AnsiUpperCase(Items[I].Name), vControlName) = 1 then begin
      // Property конкретного контрола
      PropInfo := GetPropInfo(Items[I].Component, PChar(vControlName) + Length(Items[I].Name));
      if PropInfo <> nil then begin
        Result := VarToStr(GetPropValue(Items[I].Component, PropInfo, True));
        exit;
      end;
    end;
  end;
  // Property самой формы
  PropInfo := GetPropInfo(Controller.FForm, vControlName);
  if PropInfo <> nil then begin
    Result := VarToStr(GetPropValue(Controller.FForm, PropInfo, True));
    exit;
  end;
  // Проверка нет ли vControlName среди TdxLayoutGroups
  vItem := Controller.Layout.FindItem(vControlName);
  if vItem is TdxLayoutGroup then
    with TdxLayoutGroup(vItem) do begin
      Result := Items[ItemIndex].Name;
      exit;
    end;
  // Цикл поиска vControlName среди внутренних переменных
  with getLayoutInterface(FInnerVariables) do begin
    vParam := Params.FindParam(vControlName);
    if vParam = nil then Result := ''
    else Result := vParam.AsString;
  end;
end;

function TControlCollection.IndexOf(const aName: String): Longint;
begin
  for Result := 0 to Count - 1 do
    if TORAControlProperties(Items[Result]).Component.Name = aName then exit;
  Result := -1;
end;

procedure TControlCollection.Removed(const AControl: TControl);
var
  I: Longint;
  vParam: TParam;
begin
  with getLayoutInterface(FInnerVariables) do begin
    vParam := Params.FindParam(AControl.Name);
    if vParam <> nil then Params.Delete(vParam.Index);
  end;
  I := IndexOf(AControl);
  if I >= 0 then
    with Items[I] do begin
      FComponent := nil;
      Free;
    end;
end;

function TControlCollection.IndexOf(const AControl: TControl): Longint;
begin
  for Result := 0 to Count - 1 do
    if TORAControlProperties(Items[Result]).Component = AControl then exit;
  Result := -1;
end;

procedure TControlCollection.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited;
  if TORAControlProperties(Item).Component <> nil then
    case Action of
      cnAdded: TORAControlProperties(Item).Component.FreeNotification(Controller);
      cnDeleting: TORAControlProperties(Item).Component.RemoveFreeNotification(Controller);
    end;
end;

function TControlCollection.setDataType(const AIndex, newDataType: Integer): TORAControlProperties;
var
  vItem: TdxLayoutItem;
  vControl: TControl;
begin
  Result := TORAControlProperties(Items[AIndex]);
  with Result do begin
    if DataType = newDataType then exit;
    vItem := TdxLayoutItem(LayoutItem);
    vControl := vItem.Control;
    vItem.Control := nil;
  end;
  if newDataType > Low(type_mapping) then begin
    Result := Add(newDataType, vItem);
    with Result do begin
      vControl.Owner.RemoveComponent(vControl);
      Component.Name := vControl.Name;
      Index := AIndex;
    end;
  end;
  vControl.Free;
end;

function TControlCollection.setDataType(const AControl: TControl; const newDataType: Integer)
  : TORAControlProperties;
begin
  Result := setDataType(IndexOf(AControl), newDataType);
end;

function TControlCollection.setDataType(const ALayoutItem: TdxCustomLayoutItem;
  const newDataType: Integer): TORAControlProperties;
var
  vItem: TdxLayoutItem;
begin
  if ALayoutItem is TdxLayoutItem then vItem := TdxLayoutItem(ALayoutItem)
  else if ALayoutItem is TdxLayoutGroup then
      vItem := TdxLayoutItem(TdxLayoutGroup(ALayoutItem).CreateItem(TdxLayoutItem))
  else raise Exception.Create('Недопустимый тип лайоута');
  if vItem.Control = nil then Result := Add(newDataType, vItem)
  else Result := setDataType(vItem.Control, newDataType);
end;

procedure TControlCollection.SetValue(const pControlName, pValue: String);
var
  I: Longint;
  vControlName: String;
  PropInfo: PPropInfo;
  vItem: TdxCustomLayoutItem;
  vParam: TParam;
  vStyle: TcxStyle;
begin
  if pControlName[1] = ':' then vControlName := AnsiUpperCase(PChar(pControlName) + 1)
  else vControlName := AnsiUpperCase(pControlName);
  // Запрос на установку активного объекта
  if vControlName = cActiveControl then begin
    for I := 0 to Count - 1 do
      if AnsiSameText(Items[I].Name, pValue) then
        if Items[I].Component is TWinControl then TWinControl(Items[I].Component).SetFocus;
    exit;
  end;
  for I := 0 to Count - 1 do begin
    if AnsiSameText(Items[I].Name, vControlName) then begin
      // Конкретный контрол
      Items[I].Value := pValue;
      exit;
    end;
    if Items[I].indexOfSubControl(vControlName) >= 0 then begin
      // Конкретный саб-контрол
      Items[I].Values[vControlName] := pValue;
      exit;
    end;
    if AnsiPos(AnsiUpperCase(Items[I].Name), vControlName) = 1 then begin
      // Property конкретного контрола
      PropInfo := GetPropInfo(Items[I].Component, PChar(vControlName) + Length(Items[I].Name));
      if PropInfo <> nil then begin
        try
          if (PropInfo.Name = 'Style') And (Items[I].Component is TcxCustomEdit) then
            with TcxCustomEdit(Items[I].Component).Style do begin
              vStyle := LayoutStyles(pValue);
              if vStyle <> nil then begin
                Color := vStyle.Color;
                Font := vStyle.Font;
                TextColor := vStyle.TextColor;
                Font := vStyle.Font;
              end;
            end
          else SetPropValue(Items[I].Component, PropInfo, pValue);
        except
          on E: Exception do Controller.showException(Items[I].Name + '.' + String(PropInfo.Name) + ':', E);
        end;
        exit;
      end;
    end;
  end;
  // Property самой формы
  PropInfo := GetPropInfo(Controller.FForm, vControlName);
  if PropInfo <> nil then begin
    try
      SetPropValue(Controller.FForm, PropInfo, pValue);
    except
      on E: Exception do Controller.showException('Form.' + String(PropInfo.Name) + ':', E);
    end;
    exit;
  end;
  vItem := Controller.Layout.FindItem(vControlName);
  if vItem is TdxLayoutGroup then
    with TdxLayoutGroup(vItem) do begin
      // Result := Items[ItemIndex].Name;
      exit;
    end;
  with getLayoutInterface(FInnerVariables) do begin
    vParam := Params.FindParam(vControlName);
    if vParam <> nil then vParam.AsString := pValue
    else
      with Params.CreateParam(ftWideString, vControlName, ptInputOutput) do begin
        Size := 4000;
        AsString := pValue;
      end;
  end;
end;

procedure TControlCollection.Update(Item: TCollectionItem);
begin
  inherited;
  with Controller do
    if FForm.Visible then FState := FState + [ocsLayoutModified];
end;

{ TControlCollectionProperty }

function TControlCollectionProperty.GetColOptions: TcxColOptions;
begin
  Result := [coDelete, coMove];
end;

{ TORASrcDataEditProperties }

function TORASrcDataEditProperties.getStoreProperty(const pName: String): Variant;
begin
  case StorePropertyIndex[pName] of
    0: if srcData <> nil then Result := getLayoutInterface(srcData).SQL.Text;
  else inherited;
  end;
end;

function TORASrcDataEditProperties.getStorePropertyCount: Longint;
begin
  Result := Length(cSrcPropertyNames) + inherited;
end;

function TORASrcDataEditProperties.getStorePropertyNames: PString;
begin
  Result := @cSrcPropertyNames[0];
end;

procedure TORASrcDataEditProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  case StorePropertyIndex[pName] of
    0: if srcData <> nil then begin
        getLayoutInterface(srcData).SQL.Text := Value;
        initSourceData;
      end;
  else inherited;
  end;
end;

{ TORAButtonProperties }

constructor TORAButton.Create(AOwner: TComponent);
begin
  inherited;
  FOnClickStart := stdLayoutQuery(self);
  FOnClickStart.Name := 'OnClickStart';
  FOnClickFinish := stdLayoutQuery(self);
  FOnClickFinish.Name := 'OnClickFinish';

  OptionsImage.Images := HostInterface.LayoutImages;
end;

function TORAButtonProperties.Button: TORAButton;
begin
  Result := TORAButton(Component);
end;

constructor TORAButtonProperties.Create(const AComponent: TComponent;
  const AController: TORALayoutController);
begin
  inherited;
  if AController <> nil then Button.OnClick := OnButtonClickHandler;
end;

function TORAButtonProperties.getCaption: String;
begin
  Result := Button.Caption;
end;

function TORAButtonProperties.getOnClick(const pIndex: Longint): TDataSet;
begin
  case pIndex of
    1: Result := Button.FOnClickStart;
    2: Result := Button.FOnClickFinish;
  else Result := nil;
  end;
end;

function TORAButtonProperties.getProperties: TORAButton;
begin
  Result := TORAButton(Component);
end;

function TORAButtonProperties.getStoreProperty(const pName: String): Variant;
begin
  Result := Unassigned;
  case StorePropertyIndex[pName] of
    0: if OnClickStart <> nil then Result := getLayoutInterface(OnClickStart).SQL.Text;
    1: if OnClickFinish <> nil then Result := getLayoutInterface(OnClickFinish).SQL.Text;
  else inherited;
  end;
end;

function TORAButtonProperties.getStorePropertyCount: Longint;
begin
  Result := Length(cButtonPropertyNames) + inherited;
end;

function TORAButtonProperties.getStorePropertyNames: PString;
begin
  Result := @cButtonPropertyNames[0];
end;

function TORAButtonProperties.GetValue: String;
begin
  Result := BoolToStr(Button.Down, True);
end;

procedure TORAButtonProperties.setCaption(const Value: String);
begin
  Button.Caption := Value;
  inherited setCaption('');
end;

procedure TORAButtonProperties.setStoreProperty(const pName: String; const Value: Variant);
begin
  case StorePropertyIndex[pName] of
    0: if OnClickStart <> nil then getLayoutInterface(OnClickStart).SQL.Text := Value;
    1: if OnClickFinish <> nil then getLayoutInterface(OnClickFinish).SQL.Text := Value;
  else inherited;
  end;
end;

procedure TORAButtonProperties.SetValue(const aValue: String);
var
  v: Boolean;
begin
  if TryStrToBool(aValue, v) then Button.Down := v;
end;

function TORAButton.getController: TORALayoutController;
begin
  Result := get_controller(self);
end;

procedure TORAButtonProperties.OnButtonClickHandler(Sender: TObject);
begin
  Controller.ButtonClickHandler(nil, OnClickStart, OnClickFinish);
  if Button.SpeedButtonOptions.GroupIndex <> 0 then Controller.OnEditValueChanged(self);
end;

{ TORAImageIndexProperty }

procedure TORAImageIndexProperty.Edit;
begin
  SetOrdValue(ImageSelector.selectImage(HostInterface.LayoutImages, GetOrdValue));
  PostChangedNotification;
end;

function TORAImageIndexProperty.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaDialog, ipaRevertable];
end;

{ TORARichTextProperties }

function TORARichTextProperties.GetValue: String;
begin
  Result := TcxRichEdit(Component).Lines.Text;
end;

procedure TORARichTextProperties.SetValue(const aValue: String);
begin
  if TcxRichEdit(Component).Lines.Text <> aValue then TcxRichEdit(Component).Lines.Text := aValue;
end;

initialization

ORAControlCopy.Control := nil;

register_ORADataType('не определено', TORAControlProperties, nil);
register_ORADataType('Строка', TORATextEditProperties, TcxTextEdit);
register_ORADataType('Число', TORANumberEditProperties, TcxCurrencyEdit);
register_ORADataType('Дата', TORATextEditProperties, TcxDateEdit);
register_ORADataType('Кнопка', TORAButtonProperties, TORAButton);
register_ORADataType('Галочка', TORATextEditProperties, TcxCheckBox);
register_ORADataType('Текст', TORARichTextProperties, TcxRichEdit);

cxRegisterPropertyEditor(TypeInfo(Longint), TORAControlProperties, 'DataType',
  TORADataTypeProperty);
cxRegisterPropertyEditor(TypeInfo(TDataSet), TORAComponentProperties, '', TORADataSetProperty);
cxRegisterPropertyEditor(TypeInfo(TDataSet), TORALayoutController, '', TORADataSetProperty);
cxRegisterPropertyEditor(TypeInfo(TControlCollection), nil, '', TControlCollectionProperty);
cxRegisterPropertyEditor(TypeInfo(TImageIndex), nil, '', TORAImageIndexProperty);

finalization

SetLength(type_mapping, 0);

end.
