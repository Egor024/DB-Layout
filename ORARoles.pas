unit ORARoles;

interface

uses
  SysUtils, Classes, cxOI;

type

  TORADBRoleNum = 0 .. SizeOf(Integer) * 8 - 1;

  TORADBRole = class(TObject)
    FNum: TORADBRoleNum;
    FBrief: String;
    FName: String;
  public
    property num: TORADBRoleNum read FNum write FNum;
    property brief: String read FBrief write FBrief;
    property name: String read FName write FName;
    constructor Create(const pNum: TORADBRoleNum; const pBrief: String; const pName: String);
  end;

  TORADBRolesList = class(TList)
    function GetRole(const pNum: TORADBRoleNum): TORADBRole;
    function GetItem(const pIndex: Integer): TORADBRole; inline;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(Item: TORADBRole): Integer; inline;
    property Items[const pIndex: Integer]: TORADBRole read GetItem; default;
    property Role[const pNum: TORADBRoleNum]: TORADBRole read GetRole;
  end;

  TORADBRoles = set of TORADBRoleNum;

  TORADBRolesProperty = class(TcxOrdinalProperty)
  public
    function GetAttributes: TcxPropertyAttributes; override;
    procedure GetProperties(AOwner: TComponent; Proc: TcxGetPropEditProc); override;
    function GetValue: string; override;
  end;

  TORADBRoleProperty = class(TcxPropertyEditor)
  private
    FRoleIndex: Integer;
    FRoles: TORADBRolesProperty;
    function getRoleNum: TORADBRoleNum; inline;
  protected
    constructor Create(const pRoles: TORADBRolesProperty; const aRoleIndex: Integer); reintroduce;
    property RoleNum: TORADBRoleNum read getRoleNum;
  public
    destructor Destroy; override;
    function AllEqual: Boolean; override;
    function GetAttributes: TcxPropertyAttributes; override;
    function GetName: string; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
    function IsDefaultValue: Boolean; override;
  end;

const
  Developer_ORADBRole: TORADBRoleNum = 0;

var
  allOraDBRoles: TORADBRolesList = nil;

implementation

uses TypInfo;

function TORADBRolesProperty.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaMultiSelect, ipaSubProperties, ipaReadOnly, ipaRevertable];
end;

procedure TORADBRolesProperty.GetProperties(AOwner: TComponent; Proc: TcxGetPropEditProc);
var
  I: Integer;
begin
  with allOraDBRoles do
    for I := 0 to Count - 1 do Proc(TORADBRoleProperty.Create(self, I));
end;

function TORADBRolesProperty.GetValue: string;
var
  S: TORADBRoles;
  I: Integer;
begin
  Integer(S) := GetOrdValue;
  Result := '[';
  with allOraDBRoles do
    for I := 0 to Count - 1 do
      with Items[I] do
        if num in S then begin
          if Length(Result) <> 1 then Result := Result + ',';
          Result := Result + brief;
        end;
  Result := Result + ']';
end;

{ TORADBRolesList }

function TORADBRolesList.Add(Item: TORADBRole): Integer;
begin
  Result := inherited Add(Item);
end;

function TORADBRolesList.GetItem(const pIndex: Integer): TORADBRole;
begin
  Result := TORADBRole( inherited Get(pIndex));
end;

function TORADBRolesList.GetRole(const pNum: TORADBRoleNum): TORADBRole;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Role[I].num = pNum then begin
      Result := Role[I];
      exit;
    end;
  Result := nil;
end;

procedure TORADBRolesList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then TORADBRole(Ptr).Free;
end;

{ TORADBRole }

constructor TORADBRole.Create(const pNum: TORADBRoleNum; const pBrief, pName: String);
begin
  num := pNum;
  brief := pBrief;
  Name := pName;
end;

constructor TORADBRoleProperty.Create(const pRoles: TORADBRolesProperty; const aRoleIndex: Integer);
begin
  FRoles := pRoles;
  FRoleIndex := aRoleIndex;
end;

destructor TORADBRoleProperty.Destroy;
begin
end;

function TORADBRoleProperty.AllEqual: Boolean;
var
  I: Integer;
  S: TORADBRoles;
  v: Boolean;
begin
  Result := False;
  with allOraDBRoles do
    if Count > 1 then begin
      Integer(S) := FRoles.GetOrdValue;
      v := RoleNum in S;
      for I := 1 to Count - 1 do begin
        Integer(S) := FRoles.GetOrdValueAt(I);
        if (RoleNum in S) <> v then exit;
      end;
    end;
  Result := True;
end;

function TORADBRoleProperty.GetAttributes: TcxPropertyAttributes;
begin
  Result := [ipaMultiSelect, ipaValueList, ipaSortList, ipaRevertable];
  if FRoles.PropList^[0].PropInfo.SetProc = nil then Include(Result, ipaReadOnly);
end;

function TORADBRoleProperty.GetName: string;
begin
  with allOraDBRoles.Items[FRoleIndex] do Result := name + '_' + brief;
end;

function TORADBRoleProperty.getRoleNum: TORADBRoleNum;
begin
  Result := allOraDBRoles.Items[FRoleIndex].num;
end;

function TORADBRoleProperty.GetValue: string;
var
  S: TORADBRoles;
begin
  Integer(S) := FRoles.GetOrdValue;
  if RoleNum in S then Result := 'True'
  else Result := 'False';
end;

procedure TORADBRoleProperty.GetValues(Proc: TGetStrProc);
begin
  Proc('False');
  Proc('True');
end;

procedure TORADBRoleProperty.SetValue(const Value: string);
var
  S: TORADBRoles;
begin
  Integer(S) := FRoles.GetOrdValue;
  if CompareText(Value, 'True') = 0 then Include(S, RoleNum)
  else Exclude(S, RoleNum);
  FRoles.SetOrdValue(Integer(S));
end;

function TORADBRoleProperty.IsDefaultValue: Boolean;
var
  S1, S2: TORADBRoles;
  HasStoredProc: Integer;
  ProcAsInt: Integer;
begin
  Result := FRoles.IsDefaultValue;
  if not Result then begin
    ProcAsInt := Integer(PPropInfo(FRoles.GetPropInfo)^.StoredProc);
    HasStoredProc := ProcAsInt and $FFFFFF00;
    if HasStoredProc = 0 then begin
      Integer(S1) := PPropInfo(FRoles.GetPropInfo)^.Default;
      Integer(S2) := FRoles.GetOrdValue;
      Result := not((RoleNum in S1) xor (RoleNum in S2));
    end;
  end;
end;

initialization

allOraDBRoles := TORADBRolesList.Create;

finalization

allOraDBRoles.Free;

end.
