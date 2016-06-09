unit LayoutThreads;

interface

uses Classes, LayoutData, DB, Dialogs;

type
  TLayoutThread = class;
  TLayoutThreadClass = class of TLayoutThread;
  TOnThreadStateChanged = procedure(const AThread: TLayoutThread) of object;

  TLayoutThreadList = class(TList)
  private
    FOnStateChanged: TOnThreadStateChanged;
    function Get(Index: Integer): TLayoutThread;
    procedure Put(Index: Integer; const Value: TLayoutThread);
    function get—Count(pClass: TLayoutThreadClass): Longint;
  public
    procedure Terminate;
    property Items[Index: Integer]: TLayoutThread read Get write Put; default;
    property OnStateChanged: TOnThreadStateChanged read FOnStateChanged write FOnStateChanged;
    property —Count[pClass: TLayoutThreadClass]: Longint read get—Count;
  end;

  TLayoutThread = class(TThread)
  public
    class var ThreadList: TLayoutThreadList;
  private
    FOnStateChanged: TOnThreadStateChanged;
    FTotalSteps: Longint;
    FCurrentStep: Longint;
    FMessage: String;
    FButtons: TMsgDlgButtons;
    FConfirmResult: Integer;
    procedure synchDoStateChanged;
    procedure synchShowMessage;
    procedure synchConfirmation;
  protected
    FStartTimer: TDateTime;
    procedure DoStateChanged;
    function getStateText: String; virtual;
    procedure showMessage(const pMessage: String);
    function Confirmation(const pMessage: String; pButtons: TMsgDlgButtons): Integer;
  public
    constructor Create(CreateSuspended: Boolean); overload;
    destructor Destroy; override;
    function IndexOf: Integer; inline;
    procedure Terminate; virtual;
    property OnStateChanged: TOnThreadStateChanged read FOnStateChanged write FOnStateChanged;
    property StateText: String read getStateText;
    property TotalSteps: Longint read FTotalSteps write FTotalSteps;
    property CurrentStep: Longint read FCurrentStep write FCurrentStep;
    property StartTimer: TDateTime read FStartTimer write FStartTimer;
    property Terminated;
  end;

  TLayoutQueryThread = class(TLayoutThread)
  private
    FState: String;
    FSessionID: String;
    FQuery: TDataSet;
    FFetchAllRecords: Boolean;
    FSaveSessionOnExit: Boolean;
    FSaveQueryOnExit: Boolean;
    procedure setQuery(const Value: TDataSet);
    function getSession: TComponent;
    procedure setSession(const Value: TComponent);
    procedure setState(const Value: String);
  protected
    procedure Execute; override;
    function getStateText: String; override;
  public
    destructor Destroy; override;
    procedure Terminate; override;
    property LayoutSession: TComponent read getSession write setSession;
    property SessionID: String read FSessionID;
    property State: String read FState write setState;
    property Query: TDataSet read FQuery write setQuery;
    property FetchAllRecords: Boolean read FFetchAllRecords write FFetchAllRecords;
    property SaveSessionOnExit: Boolean read FSaveSessionOnExit write FSaveSessionOnExit;
    property SaveQueryOnExit: Boolean read FSaveQueryOnExit write FSaveQueryOnExit;
  end;

implementation

uses SysUtils, Controls;
{ TLayoutThread }

function TLayoutThread.Confirmation(const pMessage: String; pButtons: TMsgDlgButtons): Integer;
begin
  FMessage := pMessage;
  FButtons := pButtons;
  FConfirmResult := mrNone;
  Synchronize(synchConfirmation);
  Result := FConfirmResult;
end;

constructor TLayoutThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);

  FStartTimer := Now;
  ThreadList.Add(self);
  DoStateChanged;
end;

procedure TLayoutThread.showMessage(const pMessage: String);
begin
  FMessage := pMessage;
  Synchronize(synchShowMessage);
end;

procedure TLayoutThread.synchConfirmation;
begin
  FConfirmResult := Dialogs.MessageDlg(FMessage, mtConfirmation, FButtons, 0);
end;

procedure TLayoutThread.synchDoStateChanged;
begin
  if Assigned(OnStateChanged) then OnStateChanged(self);
  if Assigned(ThreadList.OnStateChanged) then ThreadList.OnStateChanged(self);
end;

procedure TLayoutThread.synchShowMessage;
begin
  Raise Exception.Create(FMessage);
end;

procedure TLayoutThread.Terminate;
begin
  inherited Terminate;
end;

destructor TLayoutThread.Destroy;
begin
  ThreadList.Extract(self);
  DoStateChanged;
  inherited;
end;

procedure TLayoutThread.DoStateChanged;
begin
  if Assigned(OnStateChanged) or Assigned(ThreadList.OnStateChanged) then
      Synchronize(synchDoStateChanged);
end;

function TLayoutThread.getStateText: String;
begin
  if Finished then Result := 'Finished'
  else if Terminated then Result := 'Terminated'
  else if Suspended then Result := 'Suspended'
  else if StartTimer <> 0 then Result := TimeToStr(Now - StartTimer)
  else Result := 'Unknown';
end;

function TLayoutThread.IndexOf: Integer;
begin
  Result := ThreadList.IndexOf(self);
end;

{ TLayoutThreadList }

function TLayoutThreadList.Get(Index: Integer): TLayoutThread;
begin
  Result := inherited Get(Index);
end;

function TLayoutThreadList.get—Count(pClass: TLayoutThreadClass): Longint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Items[I].InheritsFrom(pClass) then Inc(Result);
end;

procedure TLayoutThreadList.Put(Index: Integer; const Value: TLayoutThread);
begin
  inherited Put(Index, Value);
end;

procedure TLayoutThreadList.Terminate;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do Items[I].Terminate;
end;

{ TLayoutQueryThread }

procedure TLayoutQueryThread.Terminate;
begin
  inherited;
  if Query <> nil then getLayoutInterface(Query).BreakExec;
end;

procedure TLayoutQueryThread.setState(const Value: String);
begin
  FState := Value;
  DoStateChanged;
end;

destructor TLayoutQueryThread.Destroy;
var
  vQry, vSes: TObject;
begin
  if Query <> nil then getLayoutInterface(Query).BreakExec;
  if FSaveSessionOnExit And not FSaveQueryOnExit then vQry := FQuery
  else vQry := nil;
  vSes := LayoutSession;
  if not FSaveSessionOnExit And (vSes <> nil) then begin
    LayoutSession := nil;
    vSes.Free;
  end;
  inherited;
  if vQry <> nil then vQry.Free;
end;

procedure TLayoutQueryThread.Execute;
begin
  if (Query = nil) or (LayoutSession = nil) then exit;
  if not getLayoutInterface(LayoutSession).Connected then exit;
  with Query, getLayoutInterface(Query) do
    try
      self.State := 'Opening';
      Execute;
      if Terminated or not Active then exit;
      if FetchAllRecords And IsQuery then begin
        self.State := 'Fetching';
        while not Terminated And Active And not EOF do next;
        if Terminated or not Active then exit;
        First;
      end;
      self.State := 'Open';
    except
      on E: Exception do begin
        self.State := 'Error:' + E.ClassName;
        if not Terminated then showMessage(E.Message);
      end;
    end;
end;

function TLayoutQueryThread.getSession: TComponent;
begin
  if Query <> nil then Result := getLayoutInterface(Query).LayoutSession
  else Result := nil;
end;

function TLayoutQueryThread.getStateText: String;
begin
  if (State = 'Fetching') And FetchAllRecords then
      Result := 'Fetching: ' + Format('%.n', [0.0 + getLayoutInterface(Query).RowsProcessed]) +
      ' rows; ' + inherited
  else Result := State + ' ' + inherited;
end;

procedure TLayoutQueryThread.setQuery(const Value: TDataSet);
begin
  if FQuery = Value then exit;
  FQuery := Value;
  LayoutSession := LayoutSession;
  State := 'Init';
end;

procedure TLayoutQueryThread.setSession(const Value: TComponent);
begin
  if Value = nil then FSessionID := ''
  else FSessionID := getLayoutInterface(Value).get_session_id;
  inherited;
  if Value = nil then
    if FQuery = nil then exit
    else if not FSaveQueryOnExit then freeAndNil(FQuery)
    else getLayoutInterface(Query).LayoutSession := nil
  else begin
    if FQuery = nil then begin
      FQuery := stdLayoutQuery(Value);
      FSaveQueryOnExit := False;
    end
    else getLayoutInterface(Query).LayoutSession := Value;
  end;
end;

initialization

TLayoutThread.ThreadList := TLayoutThreadList.Create;

Finalization

TLayoutThread.ThreadList.Free;

end.
