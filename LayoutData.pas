unit LayoutData;

interface

uses
  Windows, Classes, SysUtils, cxStyles, cxGraphics, DB, ORARoles, ORALayout, dxBar;

type
  ILayoutSessionInterface = interface
    ['{86F11E9B-0C82-4BE6-99F3-D924F6472405}']
    function GetConnected: boolean;
    procedure SetConnected(pValue: boolean);
    function GetConnectString: String;
    procedure SetConnectString(pValue: String);
    function getSchema: String;
    procedure setSchema(const pValue: String);
    function getUserName: String;
    procedure setUserName(const pValue: String);
    function getLoginPrompt: boolean;
    procedure setLoginPrompt(const pValue: boolean);
    procedure Commit;
    procedure Rollback;
    function get_session_id: String;
    function get_session_info(const SID: String): String;
    function get_user_roles: TORADBRoles;
    function get_user_FIO: String;

    property LoginPrompt: boolean read getLoginPrompt write setLoginPrompt;
    property ConnectString: String read GetConnectString write SetConnectString;
    property Connected: boolean read GetConnected write SetConnected;
    property Schema: String read getSchema write setSchema;
    property UserName: String read getUserName write setUserName;

    procedure change_password(const pOldPassword: String; const pNewPassword: String);
    function clone: TComponent;
    function getLayoutQueryClass: TDataSetClass;

    function loadORAForm(const p_name: String; const p_version: String; const p_initPLSQL: String;
      const p_DeveloperMode: boolean = False): TfrmORALayout;
    procedure saveORAForm(const p_form: TfrmORALayout);
    procedure set_ORAForm_notes(const p_form_name: string; const p_notes: String);
    function get_ORAForm_notes(const p_form_name: string): String;

    function get_user_param(const p_form_name: String; p_param_name: String): String;
    procedure set_user_param(const p_form_name: String; const p_param_name: String;
      const p_value: String);
    procedure get_user_bparam(const pStream: TStream; const p_form_name: String;
      p_param_name: String);
    procedure set_user_bparam(const p_form_name: String; const p_param_name: String;
      const pStream: TStream);
    procedure clear_user_params(const p_form_name: String);

    procedure loadORARoles;
    procedure loadORAMenuItems(const p_menu_ID: Longint; const pBarManager: TdxBarManager);
    procedure saveORAMenuItems(const p_menu_ID: Longint; const pBarManager: TdxBarManager);

    procedure loadORAStyles(const pStyleRepositoryID: Longint;
      const pStyleRepository: TcxStyleRepository);
    procedure saveORAStyles(const pStyleRepositoryID: Longint;
      const pStyleRepository: TcxStyleRepository);

    procedure loadORAImageList(const pImageListID: Longint; const pImageList: TcxImageList);
    procedure saveORAImageList(const pImageListID: Longint; const pImageList: TcxImageList);

    procedure save_XLS2DB(const p_def: String; const p_xls_file: String; const p_sheet: String);
    procedure paste2DB(const p_def1: string; const p_delimiter: String = #9);

  end;

  TAfterExecuteEvent = procedure(Sender: TObject; Result: boolean) of object;
  TAfterFetchEvent = procedure(DataSet: TDataSet) of object;
  TLockMode = (lmNone, lmLockImmediate, lmLockDelayed);

  ILayoutQueryInterface = interface
    ['{62F08263-1D2B-4EBF-8BC0-9B66978E4EFF}']
    function getSQL: TStrings;
    function GetParamCheck: boolean;
    procedure SetParamCheck(const Value: boolean);
    function GetIsQuery: boolean;
    function getLayoutSession: TComponent;
    procedure setLayoutSession(const pSession: TComponent);
    function GetRowsProcessed: integer;
    function getParams: TParams;
    function GetParamCount: word;
    procedure SetUpdatingTable(const pValue: string);
    function GetUpdatingTable: string;
    procedure SetReadOnly(pValue: boolean);
    function GetReadOnly: boolean;
    procedure SetAutoCommit(pValue: boolean);
    function GetAutoCommit: boolean;
    procedure SetNonBlocking(pValue: boolean);
    function GetNonBlocking: boolean;
    procedure SetLockMode(Value: TLockMode);
    function GetLockMode: TLockMode;
    procedure SetKeyFields(const Value: string);
    function GetKeyFields: string;

    function getAfterExecute: TAfterExecuteEvent;
    procedure setAfterExecute(const pProc: TAfterExecuteEvent);
    function getAfterFetch: TAfterFetchEvent;
    procedure setAfterFetch(const pProc: TAfterFetchEvent);

    procedure setBlobParam(const pIndex: Longint; const pValue: WideString);

    procedure Execute;
    procedure BreakExec;
    function Executing: boolean;
    function Fetching: boolean;
    function Fetched: boolean;

    property SQL: TStrings read getSQL;
    property Params: TParams read getParams;
    property ParamCount: word read GetParamCount;
    property LayoutSession: TComponent read getLayoutSession write setLayoutSession;
    property IsQuery: boolean read GetIsQuery;
    property ParamCheck: boolean read GetParamCheck write SetParamCheck; // before SQL
    property RowsProcessed: integer read GetRowsProcessed;
    property AfterExecute: TAfterExecuteEvent read getAfterExecute write setAfterExecute;
    property AfterFetch: TAfterFetchEvent read getAfterFetch write setAfterFetch;
    property ReadOnly: boolean read GetReadOnly write SetReadOnly;
    property UpdatingTable: string read GetUpdatingTable write SetUpdatingTable;
    property NonBlocking: boolean read GetNonBlocking write SetNonBlocking;
    property LockMode: TLockMode read GetLockMode write SetLockMode;
    property AutoCommit: boolean read GetAutoCommit write SetAutoCommit;
    property KeyFields: string read GetKeyFields write SetKeyFields;
  end;

function init_main_session(const p_connect_string: String): boolean;
function set_main_schema(const p_schema: String): boolean;
function reinit_main_session: boolean;

function stdLayoutQuery(const pOwner: TComponent = nil; const pSession: TComponent = nil;
  const pSQL: String = ''): TDataSet;
function getLayoutInterface(const pDataSet: TDataSet): ILayoutQueryInterface; overload;
function getLayoutInterface(const pSession: TComponent): ILayoutSessionInterface; overload;

function DLookUp(const pSession: TComponent; p_sql: String): variant;
function DLookUpParam(const pSession: TComponent; p_sql: String; p_params: variant): variant;

function askORAForm(const p_name: String; const p_initPLSQL: String;
  p_ResultControl: String): String;
function showORAForm(const p_name: String; const p_version: String = '';
  const p_initPLSQL: String = ''; p_DeveloperMode: boolean = False): TfrmORALayout;

const
  ApplicationName: String = 'DBForms';
  defaultFilePath: String = 'C:\delphi\';
  SprApplicationFormName: String = 'SprApplicationForm';

var
  defaultSessionClass: TPersistentClass = nil;
  mainSession: ILayoutSessionInterface = nil;
  mainSessionComponent: TComponent = nil;
  userRoles: TORADBRoles = [];
  userFIO: String;

  mainCaption: string = '';

implementation

uses Forms, Controls, Dialogs, Variants, ORALayoutCustomize;

function getLayoutInterface(const pDataSet: TDataSet): ILayoutQueryInterface; overload;
begin
  if not Supports(pDataSet, ILayoutQueryInterface, Result) then
      raise Exception.Create('DataSet ÌÂ ÔÓ‰‰ÂÊË‚‡ÂÚ ILayoutQueryInterface');
end;

function getLayoutInterface(const pSession: TComponent): ILayoutSessionInterface; overload;
begin
  if not Supports(pSession, ILayoutSessionInterface, Result) then
      raise Exception.Create('—ÂÒÒËˇ ÌÂ ÔÓ‰‰ÂÊË‚‡ÂÚ ILayoutSessionInterface');
end;

function stdLayoutQuery(const pOwner: TComponent = nil; const pSession: TComponent = nil;
  const pSQL: String = ''): TDataSet;
var
  vSession: TComponent;
  vOwner: TComponent;
  vSessionInterface: ILayoutSessionInterface;
  vQueryInterface: ILayoutQueryInterface;
begin
  vSessionInterface := nil;
  if pSession <> nil then vSession := pSession
  else if Supports(pOwner, ILayoutSessionInterface, vSessionInterface) then vSession := pOwner
  else vSession := mainSessionComponent;
  if pOwner = nil then vOwner := vSession
  else vOwner := pOwner;

  if vSessionInterface = nil then vSessionInterface := getLayoutInterface(vSession);
  Result := vSessionInterface.getLayoutQueryClass.Create(vOwner);
  try
    vQueryInterface := getLayoutInterface(Result);
  except
    on E: Exception do begin
      Result.Free;
      raise E;
    end;
  end;
  vQueryInterface.LayoutSession := vSession;
  vQueryInterface.SQL.Text := pSQL;
end;

function DLookUp(const pSession: TComponent; p_sql: String): variant;
var
  I: integer;
  vDS: TDataSet;
begin
  vDS := stdLayoutQuery(nil, pSession, p_sql);
  try
    with vDS, getLayoutInterface(vDS) do begin
      try
        Execute;
      except
        on E: Exception do begin
          Result := 'Error: ' + E.message;
          exit;
        end;
      end;
      if EOF then begin
        Result := 'no data found';
        exit;
      end;
      try
        if FieldCount = 1 then Result := Fields[0].Value
        else begin
          Result := VarArrayCreate([0, FieldCount - 1], varVariant);
          for I := 0 to FieldCount - 1 do Result[I] := Fields[I].Value;
        end;
        Close;
      except
        on E: Exception do begin
          Result := 'Error: ' + E.message;
        end;
      end;
    end;
  finally
    vDS.Free;
  end;
end;

function DLookUpParam(const pSession: TComponent; p_sql: String; p_params: variant): variant;
var
  I, j, k: integer;
  s, s1, s2: variant;
  param_: TParam;
  vDS: TDataSet;
begin
  if not VarIsArray(p_params) then
      raise Exception.Create('Function FED_DLookUpParam. Parameter:p_params must be Array');
  I := VarArrayDimCount(p_params);
  if not I > 2 then
      raise Exception.Create
      ('Function FED_DLookUpParam. Parameter:p_params must have no more 1 dimention');
  vDS := stdLayoutQuery(nil, pSession, p_sql);
  try
    with vDS, getLayoutInterface(vDS) do begin
      ParamCheck := False;
      if not VarIsArray(p_params[0]) then begin
        s := p_params[0];
        s1 := p_params[1];
        s2 := p_params[2];
        param_ := Params.AddParameter;
        param_.Name := String(s);
        param_.DataType := TFieldType(s1);
        param_.Value := s2;
      end else begin
        j := VarArrayLowBound(p_params, 1);
        k := VarArrayHighBound(p_params, 1);
        for I := j to k do begin
          param_ := Params.AddParameter;
          param_.Name := String(p_params[I][0]);
          param_.DataType := TFieldType(p_params[I][1]);
          param_.Value := p_params[I][2];
        end;
      end;
      try
        Execute;
      except
        on E: Exception do begin
          Result := 'Error: ' + E.message;
          exit;
        end;
      end;
      If RecordCount = 0 then begin
        Result := 'no data found';
        exit;
      end;
      try
        if FieldCount = 1 then Result := Fields.Fields[0].Value
        else begin
          Result := VarArrayCreate([0, FieldCount - 1], varVariant);
          for I := 0 to FieldCount - 1 do Result[I] := Fields.Fields[I].Value;
        end;
      except
        on E: Exception do begin
          Result := 'Error: ' + E.message;
        end;
      end;
    end;
  finally
    vDS.Free;
  end;
end;

function set_main_schema(const p_schema: String): boolean;
begin
  userRoles := [];
  userFIO := '';

  Result := mainSession.Connected;
  if Result then begin
    try
      mainSession.Schema := p_schema;
    except
      on E: Exception do begin
        showmessage(E.message);
        mainSession.Schema := mainSession.UserName;
        Result := False;
      end;
    end;
    if Result And (mainSession.Schema <> '') then
      with mainSession do begin
        userRoles := get_user_roles;
        userFIO := get_user_FIO;
        if AnsiCompareText(Schema, UserName) = 0 then Include(userRoles, Developer_ORADBRole);
      end;
  end;
end;

function init_main_session(const p_connect_string: String): boolean;
var
  v—lass: TPersistentClass;
  v: Longint;
begin
  userRoles := [];
  if mainSessionComponent <> nil then begin
    mainSession := nil;
    FreeAndNil(mainSessionComponent);
  end;

  v := Pos(':', p_connect_string);
  v—lass := nil;
  if v <> 0 then v—lass := GetClass(copy(p_connect_string, 1, v - 1));
  if (v—lass = nil) or (not v—lass.InheritsFrom(TComponent)) then begin
    v—lass := defaultSessionClass;
    v := 0;
  end;

  mainSessionComponent := TComponentClass(v—lass).Create(Application);
  try
    mainSession := getLayoutInterface(mainSessionComponent);
    with mainSession do begin
      ConnectString := copy(p_connect_string, v + 1, 999);
      Schema := '';
      LoginPrompt := True;
      try
        Connected := True;
      except
      end;
      Result := Connected;
      set_main_schema('');
    end
  except
    mainSession := nil;
    FreeAndNil(mainSessionComponent);
    Result := False;
  end;
end;

function reinit_main_session: boolean;
begin
  userRoles := [];
  if not mainSession.Connected then begin
    Result := init_main_session(mainSession.ConnectString);
    exit;
  end
  else
    with mainSession do begin
      Connected := False;
      LoginPrompt := False;
      Connected := True;
      Result := Connected;
      set_main_schema(Schema);
    end;
end;

function askORAForm(const p_name: String; const p_initPLSQL: String;
  p_ResultControl: String): String;
var
  vFrm: TfrmORALayout;
begin
  vFrm := mainSession.loadORAForm(p_name, '', p_initPLSQL);
  Result := 'Unassigned';
  if vFrm = nil then exit;
  with vFrm do
    try
      if ModalResult = mrNone then ShowModal;
      case ModalResult of
        mrOk, mrYes, mrYesToAll: Result := Controller.ControlCollection.Values[p_ResultControl];
        mrAbort: Result := 'mrAbort';
        mrCancel: Result := 'mrCancel';
      end;
    finally
      Free;
    end;
end;

function showORAForm(const p_name: String; const p_version: String = '';
  const p_initPLSQL: String = ''; p_DeveloperMode: boolean = False): TfrmORALayout;
begin
  Result := mainSession.loadORAForm(p_name, p_version, p_initPLSQL, p_DeveloperMode);
  if Result <> nil then
    with Result do begin
      FormStyle := fsMDIChild;
      OnCreate(nil);
      with Controller do State := State - [ocsLayoutModified];
    end;
end;

initialization

RegisterClass(TcxImageList);

finalization

UnRegisterClass(TcxImageList);

end.
