{$J+ Assignable Typed Constants}
unit OraSQLEdit;

interface

uses
  Variants, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, Grids, ExtCtrls, Menus, DAScript, DB, OraVarEdit,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxDBData, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  dxLayoutContainer, dxLayoutLookAndFeels, dxLayoutControl, JvExControls, JvEditorCommon,
  JvEditor, JvHLEditor, LayoutData, cxButtons;

type
  TSQLEditForm = class(TForm)
    StatusBar: TStatusBar;
    TopPanel: TPanel;
    LogonBtn: TSpeedButton;
    ExecuteBtn: TSpeedButton;
    DescribeBtn: TSpeedButton;
    VariablesBtn: TSpeedButton;
    PBox: TPaintBox;
    RightPanel: TPanel;
    ExitBtn: TSpeedButton;
    OkayBtn: TSpeedButton;
    HelpBtn: TSpeedButton;
    OpenHelp: TOpenDialog;
    LoadBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    OpenSQL: TOpenDialog;
    SaveSQL: TSaveDialog;
    FontDialog: TFontDialog;
    SetupBtn: TSpeedButton;
    BreakBtn: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    SetupPopup: TPopupMenu;
    TextFont: TMenuItem;
    ListFont: TMenuItem;
    ExportBtn: TSpeedButton;
    tvGridView: TcxGridDBTableView;
    GridViewLevel1: TcxGridLevel;
    GridView: TcxGrid;
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1SplitterItem1: TdxLayoutSplitterItem;
    dxLayoutLookAndFeelList1: TdxLayoutLookAndFeelList;
    dxLayoutStandardLookAndFeel1: TdxLayoutStandardLookAndFeel;
    dxLayoutControl1Item3: TdxLayoutItem;
    SQLEdit: TJvHLEditor;
    btnTemplate: TcxButton;
    SQLEditDataSource: TDataSource;
    procedure VariablesBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LogonBtnClick(Sender: TObject);
    procedure ExecuteBtnClick(Sender: TObject);
    procedure OkayBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure DescribeBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DropIt(Sender, Source: TObject; X, Y: Integer);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SQLEditChange(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure SetupBtnClick(Sender: TObject);
    procedure TextFontClick(Sender: TObject);
    procedure ListFontClick(Sender: TObject);
    procedure BreakBtnClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SQLEditQueryAfterExecute(Sender: TObject; Result: Boolean);
    procedure SQLEditQueryAfterFetch(DataSet: TDataSet);
    procedure btnTemplateClick(Sender: TObject);
  private
    procedure SendToPLSQLDev;
  public
    SQLEditQuery: TDataSet;
    SQLEditQueryI: ILayoutQueryInterface;
    SQLEditSessionI: ILayoutSessionInterface;
    Start: Integer;
    Drag: Boolean;
    SQLDir, SQLFile: string;
    AllowChange: Boolean;
    TextEditMode: Boolean;
    procedure checkFinished;
    function GetCursorWord: String;
    procedure SetFonts;
    function SelectFont(Font: TFont; Section: string): Boolean;
{$IFNDEF LINUX}
    procedure HandlePLSQLDevMsg(wParam, lParam: Integer);
    procedure DefaultHandler(var Message); override;
{$ENDIF}
    procedure SetSQLEdit(S: string);
    function CanDescribe: Boolean;
  end;

function ExecuteSQLEditor(Q: TDataSet): Boolean;

implementation

uses Registry, Ora;
{$R *.dfm}

const
  Executing = 'Executing...';

const // PL/SQL Developer interface
  QueryName: string = '';
  PLSQLDevId = 'PLSQLDevInterface';
  PLSQLDevMsg: Cardinal = 0;
  wm_QueryAvailable = 1000;
  wm_PLSQLDevQueryAvailable = 1001;

  // External Oracle Datatypes
  otInteger = 3;
  otFloat = 4;
  otString = 5;
  otLong = 8;
  otDate = 12;
  otLongRaw = 24;
  otBoolean = 252; // Does not work as bind variable!
  otCLOB = 112;
  otNCLOB = -112;
  otBLOB = 113;
  otBFile = 114;
  otCursor = 116;
  otObject = 108;
  otReference = 110;
  otDBChar = 96;
  otChar = 97;
  otPLSQLString = 10;
  otSubst = 1; // Substitution variable, will be replaced in the SQL text
  otTimestamp = 187;

var
  Reg: TRegistry;
  RegSection: string;
  LeftMargin: Integer = 1;
  TopMargin: Integer = 1;

function Confirm(Text, Caption, Style: string): Integer;
var
  K: TMsgDlgButtons;
begin
  K := [];
  if Pos('Y', Style) > 0 then K := K + [mbYes];
  if Pos('N', Style) > 0 then K := K + [mbNo];
  if Pos('C', Style) > 0 then K := K + [mbCancel];
  if Pos('O', Style) > 0 then K := K + [mbOK];
{$IFNDEF LINUX}
  if Pos('I', Style) > 0 then K := K + [mbIgnore];
  if Pos('A', Style) > 0 then K := K + [mbAll];
{$ENDIF}
  Result := MessageDlg(Text, mtConfirmation, K, 0);
end;

procedure WriteInteger(Key: string; Value: Integer);
begin
  if Reg <> nil then Reg.WriteInteger(Key, Value);
end;

procedure WriteString(Key: string; Value: string);
begin
  if Reg <> nil then Reg.WriteString(Key, Value);
end;

function ReadInteger(Key: string; Default: Integer): Integer;
begin
  Result := Default;
  if (Reg <> nil) and Reg.ValueExists(Key) then Result := Reg.ReadInteger(Key);
end;

function ReadString(Key: string; Default: string): string;
begin
  Result := Default;
  if (Reg <> nil) and Reg.ValueExists(Key) then Result := Reg.ReadString(Key);
end;

function ReadRegString(Root: HKEY; const Key, Name: String): string;
var
  Handle: HKEY;
  Buffer: Array [0 .. 256] of Char;
  BufSize: Integer;
  DataType: Integer;
begin
  Result := '';
  if RegOpenKeyEx(Root, PChar(Key), 0, KEY_READ, Handle) = ERROR_SUCCESS then begin
    BufSize := SizeOf(Buffer);
    DataType := reg_sz;
    if RegQueryValueEx(Handle, PChar(Name), nil, @DataType, @Buffer, @BufSize) = ERROR_SUCCESS then
        Result := Buffer;
    RegCloseKey(Handle);
  end;
end;

procedure CloseRegistry;
begin
  if Reg <> nil then begin
    Reg.CloseKey;
    Reg.Free;
    Reg := nil;
  end;
end;

function OpenRegistry(Section: string): Boolean;
begin
  CloseRegistry;
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  RegSection := 'Software\OraForms\' + Section;
  Result := Reg.OpenKey(RegSection, True);
  if not Result then CloseRegistry;
end;

// PL/SQL Developer interface functions

{$IFNDEF LINUX}

const
  DAOOraDataTypeMap: array [TFieldType] of Word = (
    // ftUnknown, ftString, ftSmallint, ftInteger, ftWord
    otString, otString, otInteger, otInteger, otInteger,
    // ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime
    otBoolean, otFloat, otFloat, 0, otDate, otDate, otDate,
    // ftBytes, ftVarBytes, ftAutoInc,
    0, 0, 0,
    // ftBlob, ftMemo,  ftGraphic, ftFmtMemo
    otBLOB, otCLOB, 0, 0,
    // ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar, ftWideString
    0, 0, 0, otCursor, otString, otString,
    // ftLargeint, ftADT,    ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob
    otInteger, otObject, 0, otReference, 0, otBLOB, otCLOB,
    // ftVariant, ftInterface, ftIDispatch,  ftGuid,
    0, 0, 0, 0,
    // ftTimeStamp, ftFMTBcd,
    otTimestamp, 0
    // ftFixedWideChar, ftWideMemo, ftOraTimeStamp, ftOraInterval,
    , 0, otCLOB, otTimestamp, 0
    // ftLongWord, ftShortint, ftByte,   ftExtended, ftConnection, ftParams, ftStream
    , otInteger, otInteger, otChar, otFloat, 0, 0, 0
    // ftTimeStampOffset, ftObject, ftSingle
    , 0, otObject, otFloat);

procedure TSQLEditForm.SendToPLSQLDev;
var
  MHandle, WHandle: THandle;
  Data: Pointer;
  Size: Integer;
  S: AnsiString;
  i: Integer;
  procedure AddString(SubString: string);
  begin
    S := S + AnsiString(SubString) + #0;
  end;

begin
  // PLSQLDevMsg := RegisterWindowMessage(PLSQLDevId);
  // Build the string that is going to get transmitted to PL/SQL Developer
  S := '';
  AddString('Direct Oracle Access'); // First an application name
  AddString(QueryName); // Object name
  AddString(SQLEditQueryI.SQL.Text); // The query text
  for i := 0 to SQLEditQueryI.ParamCount - 1 do // and the variables
  begin // name, type and value
    AddString(SQLEditQueryI.params[i].name);
    AddString(IntToStr(DAOOraDataTypeMap[SQLEditQueryI.params[i].DataType]));
    if SQLEditQueryI.params[i].DataType <> ftCursor then AddString(SQLEditQueryI.params[i].AsString)
    else AddString('<Cursor>');

    // v := Q.GetVariable(Q.VariableName(i));
    // if VarIsNull(v) or VarIsEmpty(v) then AddString('') else AddString(string(v));
  end;
  Size := Length(S);
  // Create a block of shared memory
  MHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, Size, PLSQLDevId);
  if MHandle <> 0 then begin
    Data := MapViewOfFile(MHandle, FILE_MAP_WRITE, 0, 0, Size);
    if Data <> nil then begin
      Move(S[1], Data^, Size);
      // Send a message that a query is available
      WHandle := FindWindow('TPLSQLDevForm', nil);
      if WHandle = 0 then begin
        ShowMessage('«апустите PL/SQL Developer');
      end;
      if WHandle <> 0 then SendMessage(WHandle, PLSQLDevMsg, wm_QueryAvailable, Size);
      UnmapViewOfFile(Data);
    end;
    CloseHandle(MHandle);
  end;
end;

procedure TSQLEditForm.HandlePLSQLDevMsg(wParam, lParam: Integer);
var
  Handle: THandle;
  Data: Pointer;
  S: AnsiString;
  Product, Title: string;
  index: Integer;
  vName, vType, vValue: string;
  function GetString(const S: AnsiString): string;
  begin
    Result := '';
    inc(index);
    while (index <= Length(S)) and (S[index] <> #0) do begin
      Result := Result + Char(S[index]);
      inc(index);
    end;
  end;

begin
  if wParam = wm_PLSQLDevQueryAvailable then begin
    S := '';
    Handle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, lParam, PLSQLDevId);
    if (Handle <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then begin
      Data := MapViewOfFile(Handle, FILE_MAP_READ, 0, 0, lParam);
      SetLength(S, lParam);
      Move(Data^, S[1], lParam);
      UnmapViewOfFile(Data);
    end;
    if Handle <> 0 then CloseHandle(Handle);
    if S <> '' then begin
      index := 0;
      Product := GetString(S);
      Title := GetString(S);
      SQLEdit.Lines.Text := GetString(S);
      SQLEditQueryI.params.Clear;
      repeat
        vName := GetString(S);
        vType := GetString(S);
        vValue := GetString(S);
        if vName <> '' then begin
          try
            with SQLEditQueryI.params.CreateParam(ftUnknown, vName, ptInputOutput) do
              if vValue <> '' then AsString := vValue;
          except
          end;
        end;
      until vName = '';
      Application.BringToFront;
    end;
  end;
end;

procedure TSQLEditForm.DefaultHandler(var Message);
begin
  inherited DefaultHandler(Message);
  with TMessage(Message) do begin
    if Msg = PLSQLDevMsg then begin
      HandlePLSQLDevMsg(wParam, lParam);
      Result := 0;
    end;
  end;
end;
{$ENDIF}
// Start the plain text Editor
// function ExecuteEditor(var S: string): Boolean;
// var
// SQLForm: TSQLEditForm;
// i: Integer;
// P: Pointer;
// begin
// Result := False;
// P := @SetDefaults;
// SetDefaults := nil;
// Application.CreateForm(TSQLEditForm, SQLForm);
// with SQLForm do begin
// ScriptMode := False;
// ScriptMode := True;
// for i := SQLForm.ComponentCount - 1 downto 0 do begin
// if Components[i].Tag < 0 then TControl(Components[i]).Visible := False
// else begin
// if Components[i] is TSpeedButton then begin
// if Components[i].Tag <> 2 then
// TSpeedButton(Components[i]).Left := TSpeedButton(Components[i]).Left -
// LoadBtn.Left + 4;
// end;
// end;
// end;
// SQLEdit.Align := alClient;
// {$IFDEF LINUX}
// TabControl.Tabs.Clear;
// {$ELSE}
// TabControl.Tabs.Text := '';
// {$ENDIF}
// SetFonts;
// SQLEdit.Text := S;
// Caption := 'Editor';
// OkayBtn.Enabled := False;
// if (ShowModal = mrOK) then begin
// S := SQLEdit.Text;
// Result := True;
// end;
// Free;
// end;
// SetDefaults := P;
// end;

// Start the SQL Editor
function ExecuteSQLEditor(Q: TDataSet): Boolean;
var
  SQLForm: TSQLEditForm;
  vLQueryInterface: ILayoutQueryInterface;
  vLSessionInterface: ILayoutSessionInterface;
begin
  Result := False;
  vLQueryInterface := getLayoutInterface(Q);
  vLSessionInterface := getLayoutInterface(vLQueryInterface.LayoutSession);
  Application.CreateForm(TSQLEditForm, SQLForm);
  with SQLForm do
    try
      SQLEditQuery := stdLayoutQuery(SQLForm, vLSessionInterface.clone);
      SQLEditQueryI:= getLayoutInterface(SQLEditQuery);
      SQLEditQueryI.AfterExecute := SQLEditQueryAfterExecute;
      SQLEditQueryI.AfterFetch := SQLEditQueryAfterFetch;
      if not Supports(SQLEditQueryI.LayoutSession, ILayoutSessionInterface, SQLEditSessionI) then
          exit;
      SQLEditDataSource.DataSet := SQLEditQuery;
      TextEditMode := False;
      SetFonts;
      SQLEditQueryI.NonBlocking := True;
      SQLEditQueryI.SQL.Text := vLQueryInterface.SQL.Text;
      SQLEditQueryI.params.Assign(vLQueryInterface.params);
      // vSQLEditQueryI.Options.FieldsAsString := vLQueryInterface.Options.FieldsAsString;
      SQLEdit.Lines := SQLEditQueryI.SQL;
      SQLEdit.SelStart := 0;
      QueryName := Q.name;
      Caption := Q.Owner.name + '.' + QueryName + ' SQL Editor';
      OkayBtn.Enabled := False;
      if ShowModal = mrOK then begin
        vLQueryInterface.SQL.Text := Trim(SQLEdit.Lines.Text);
        vLQueryInterface.params.Assign(SQLEditQueryI.params);
        Result := True;
      end;
    finally
      SQLEditQueryI.LayoutSession.Free;
      SQLEditQueryI := nil;
      Free;
    end;
end;

// Start the Script Command Editor
// function ExecuteCommandEditor(Q: TOraScript): Boolean;
// var
// SQLForm: TSQLEditForm;
// procedure AdjustControl(C: TControl);
// var
// D: Integer;
// begin
// D := SQLForm.FirstBtn.Left - SQLForm.ExportBtn.Left;
// C.Visible := True;
// C.Left := C.Left - D;
// end;
//
// begin
// Result := False;
// Application.CreateForm(TSQLEditForm, SQLForm);
// with SQLForm do begin
// ScriptMode := True;
// TextEditMode := False;
// ExportBtn.Visible := False;
// HelpBtn.Visible := False;
// AdjustControl(ScriptScrollBar);
// AdjustControl(PrevBtn);
// AdjustControl(NextBtn);
// AdjustControl(LastBtn);
// AdjustControl(InsertBtn);
// AdjustControl(DeleteBtn);
// AdjustControl(FirstBtn);
// TabControl.TabIndex := 0;
// CommandIndex := 0;
//
// CommandResults.Visible := True;
// CommandResults.Align := alClient;
// CommandResults.Clear;
//
// CheckCommandIndex;
// SetFonts;
// VariablesBtn.Enabled := False;
// SQLEditScript.SQL := Q.SQL;
// // SQLEditScript.Lines := Q.Lines;
// SQLEditScript.AutoCommit := Q.AutoCommit;
// // SQLEditScript.ExitOnError := Q.ExitOnError;
// // SQLEditScript.OutputOptions := Q.OutputOptions;
// if Q.Session <> nil then begin
// if Q.Session.Connected then begin
// LogonBtn.Enabled := False;
// SQLEditQuery.Session := Q.Session;
// SQLEditScript.Session := Q.Session;
// end else begin
// // Read logon settings from registry
// SQLEditSession.Username := Q.Session.Username;
// SQLEditSession.Password := Q.Session.Password;
// SQLEditSession.ConnectString := Q.Session.ConnectString;
// end;
// SQLEditSessionConnectChange(Q.Session, Q.Session.Connected);
// end else begin
// if OpenRegistry('Logon') then begin
// SQLEditSession.Username := ReadString('Username', '');
// SQLEditSession.Password := ReadString('Password', '');
// SQLEditSession.ConnectString := ReadString('ConnectString', '');
// CloseRegistry;
// end;
// end;
// SQLEdit.Lines := SQLEditScript.SQL;
// SQLEdit.SelStart := 0;
// QueryName := Q.name;
// Caption := Q.Owner.name + '.' + QueryName + ' Command Editor';
// OkayBtn.Enabled := False;
// DescribeBtn.Enabled := CanDescribe;
// if (ShowModal = mrOK) then begin
// if (TabControl.TabIndex = 1) then StoreCommand
// else SQLEditScript.SQL := SQLEdit.Lines;
// TabControl.TabIndex := 0;
// Q.SQL := SQLEditScript.SQL;
// Result := True;
// end;
// Free;
// end;
// end;

// The SQL Editor mainform

// Read settings from HKEY_CURRENT_USER/Software/DOA/SQL Editor
procedure TSQLEditForm.FormCreate(Sender: TObject);
var
  h: Integer;
begin
  // QBCreate(Self.Handle);
  PLSQLDevMsg := RegisterWindowMessage(PLSQLDevId);
  // ChangeGlyphInit(Self);
  // ChangeGlyphs(TopPanel);
  // ChangeGlyphs(RightPanel);
  // ChangeGlyphClose;
  if OpenRegistry('SQL Editor') then begin
    Left := ReadInteger('Left', Left);
    Top := ReadInteger('Top', Top);
    Width := ReadInteger('Width', Width);
    Height := ReadInteger('Height', Height);
    h := ReadInteger('Splitter', SQLEdit.Height);
    if h > Height - (TopPanel.Height * 4) then h := Height - (TopPanel.Height * 4);
    if h < 20 then h := 20;
    SQLEdit.Height := h;
    WindowState := TWindowState(ReadInteger('State', Ord(WindowState)));
    SQLDir := ReadString('SQL Files', SQLDir);
    CloseRegistry;
  end;
  Start := -1;
  Drag := False;
  AllowChange := True;
end;

procedure TSQLEditForm.FormActivate(Sender: TObject);
begin
end;

// Save settings on exit
procedure TSQLEditForm.FormDestroy(Sender: TObject);
begin
  if SQLEditQueryI <> nil then SQLEditQueryI.BreakExec;
  if not TextEditMode then begin
    if OpenRegistry('SQL Editor') then begin
      if WindowState = wsNormal then begin
        WriteInteger('Left', Left);
        WriteInteger('Top', Top);
        WriteInteger('Width', Width);
        WriteInteger('Height', Height);
      end;
      WriteInteger('State', Ord(WindowState));
      WriteInteger('Splitter', SQLEdit.Height);
      WriteString('SQL Files', SQLDir);
      CloseRegistry;
    end;
  end;
  // QBFree;
end;

// Manually LogOn or LogOff
procedure TSQLEditForm.LogonBtnClick(Sender: TObject);
begin
  with SQLEditSessionI do Connected := not Connected;
end;

// Execute a query and display the results
procedure TSQLEditForm.ExecuteBtnClick(Sender: TObject);
var
  i: Integer;
  // hasCursor: Boolean;
  procedure SetExecuteMode;
  begin
    StatusBar.SimpleText := Executing;
    Screen.Cursor := crAppStart;
    BreakBtn.Enabled := True;
    ExecuteBtn.Enabled := False;
    DescribeBtn.Enabled := False;
  end;
  function Normalize(const S: string): string;
  var
    C: Integer;
  begin
    Result := S;
    for C := 1 to Length(S) do
      if S[C] < #32 then Result[C] := ' ';
  end;

begin
  if not SQLEditSessionI.Connected then exit;
  tvGridView.ClearItems;
  if not SQLEditQueryI.Executing then begin
    SetExecuteMode;
    with SQLEditQueryI do begin
      SQL.Text := SQLEdit.Lines.Text;
      ParamCheck := True;
      for i := 0 to ParamCount - 1 do
        with params[i] do
          if DataType = ftUnknown then begin
            if AnsiPos('CURSOR', AnsiUpperCase(name)) <> 0 then begin
              DataType := ftCursor;
            end else begin
              DataType := ftWideString;
              Size := 4000;
              ParamType := ptInputOutput;
            end;
          end;
      Execute;
    end;
  end;
end;

procedure TSQLEditForm.BreakBtnClick(Sender: TObject);
begin
  SQLEditQueryI.BreakExec;
  SQLEditQuery.Active := False;
  checkFinished;
end;

// Describe a query to search for errors
procedure TSQLEditForm.DescribeBtnClick(Sender: TObject);
// var
// ft: Integer;
begin
  // if not LoggedOn then Exit;
  // try
  // if ScriptMode and (TabControl.TabIndex = 1) then StoreCommand;
  // SQLEditQuery.SQL.Text := SQLEdit.Text;
  // SQLEditQuery.Describe;
  // ft := SQLEditQuery.FunctionType;
  // if not IsQuery then
  // StatusBar.SimpleText := 'Cannot parse this SQL statement'
  // else
  // StatusBar.SimpleText := 'OK';
  // except
  // on E:Exception do
  // begin
  // GotoError;
  // StatusBar.SimpleText := E.Message;
  // ShowMessage(StatusBar.SimpleText);
  // end;
  // end;
end;

// Start the variables editor
procedure TSQLEditForm.VariablesBtnClick(Sender: TObject);
begin
  SQLEditQueryI.SQL.Text := SQLEdit.Lines.Text;
  if ExecuteVariablesEditor(SQLEditQuery, '') then OkayBtn.Enabled := True;
end;

// Load SQL text
procedure TSQLEditForm.LoadBtnClick(Sender: TObject);
begin
  with OpenSQL do begin
    InitialDir := SQLDir;
    Filename := SQLFile;
    if Execute then begin
      SQLDir := ExtractFilePath(Filename);
      SQLFile := ExtractFilename(Filename);
      SQLEdit.Lines.LoadFromFile(Filename);
    end;
  end;
end;

// Save SQL text
procedure TSQLEditForm.SaveBtnClick(Sender: TObject);
begin
  with SaveSQL do begin
    InitialDir := SQLDir;
    Filename := SQLFile;
    if Execute then begin
      SQLDir := ExtractFilePath(Filename);
      SQLFile := ExtractFilename(Filename);
      SQLEdit.Lines.SaveToFile(Filename);
    end;
  end;
end;

procedure TSQLEditForm.ExportBtnClick(Sender: TObject);
begin
  SQLEditQueryI.SQL.Text := SQLEdit.Lines.Text;
  SendToPLSQLDev;
end;

// Return the word the cursor is on
function TSQLEditForm.GetCursorWord: String;
{$IFNDEF LINUX}
const
  IdentSet: set of AnsiChar = ['.', 'a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '#', '$'];
var
  i, j, P: Integer;
  S: string;
{$ENDIF}
begin
{$IFNDEF LINUX}
  P := SQLEdit.Perform(em_LineFromChar, SQLEdit.SelStart, 0);
  S := SQLEdit.Lines[P];
  i := SQLEdit.SelStart - SQLEdit.Perform(em_LineIndex, P, 0) + 1;
  while (i > 1) and (AnsiChar(S[i - 1]) in IdentSet) do Dec(i);
  j := i;
  while (j <= Length(S)) and (AnsiChar(S[j]) in IdentSet) do inc(j);
  Result := Copy(S, i, j - i);
{$ENDIF}
end;

// Open help
procedure TSQLEditForm.HelpBtnClick(Sender: TObject);
begin
end;

// Invoke help when F1 is pressed
procedure TSQLEditForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_F1 then begin
    HelpBtnClick(nil);
    Key := 0;
  end;
  if Key = vk_F8 then begin
    if ExecuteBtn.Enabled then ExecuteBtnClick(nil);
    Key := 0;
  end;
  if Key = vk_Escape then begin
    if BreakBtn.Enabled then BreakBtnClick(nil);
    Key := 0;
  end;
  if ssCtrl in Shift then begin
    if Key = Ord('R') then begin
      if ExecuteBtn.Enabled then ExecuteBtnClick(nil);
      Key := 0;
    end;
    if Key = Ord('D') then begin
      if DescribeBtn.Enabled then DescribeBtnClick(nil);
      Key := 0;
    end;
    if Key = Ord('P') then begin
      if VariablesBtn.Enabled then VariablesBtnClick(nil);
      Key := 0;
    end;
    if Key = 13 then begin
      if OkayBtn.Enabled then OkayBtnClick(nil);
      Key := 0;
    end;
  end;
end;

// Two events needed for the splitter. Delphi 3 has a splitter component but
// we wanted to be Delphi 2 compatible, and this one is smooth
procedure TSQLEditForm.DropIt(Sender, Source: TObject; X, Y: Integer);
begin
  Start := -1;
  Drag := False;
end;

procedure TSQLEditForm.SQLEditChange(Sender: TObject);
begin
  if SQLEdit.Modified and AllowChange then OkayBtn.Enabled := True;
end;

procedure TSQLEditForm.SQLEditQueryAfterExecute(Sender: TObject; Result: Boolean);
begin
  if Result then tvGridView.DataController.CreateAllItems(True);
  checkFinished;
end;

procedure TSQLEditForm.SQLEditQueryAfterFetch(DataSet: TDataSet);
var
  S: String;
begin
  Application.ProcessMessages;
  GridView.Refresh;
  S := IntToStr(SQLEditQueryI.RowsProcessed) + ' rows processed';
  if SQLEditQueryI.Fetching then
      S := S + ' .' + StringOfChar('.', SQLEditQueryI.RowsProcessed mod 4)
  else checkFinished;
  StatusBar.SimpleText := S;
end;

procedure TSQLEditForm.SetSQLEdit(S: string);
begin
  AllowChange := False;
  SQLEdit.Lines.BeginUpdate;
  SQLEdit.Lines.Text := S;
  SQLEdit.SelStart := 0;
  SQLEdit.Lines.EndUpdate;
  SQLEdit.Modified := False;
{$IFNDEF LINUX}
  SQLEdit.Perform(EM_SCROLLCARET, 0, 0);
{$ENDIF}
  AllowChange := True;
end;

procedure TSQLEditForm.OkayBtnClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TSQLEditForm.ExitBtnClick(Sender: TObject);
var
  Key: Integer;
  S: string;
begin
  if OkayBtn.Enabled then begin
    S := 'Save changes to ' + QueryName + '?';
    Key := Confirm(S, 'Confirm', 'YNC');
    case Key of
      IDYES: ModalResult := mrOK;
      IDNO: ModalResult := mrCancel;
    end;
  end
  else ModalResult := mrCancel;
end;

function StyleToInt(Style: TFontStyles): Integer;
begin
  Result := 0;
  if fsBold in Style then inc(Result, 1);
  if fsItalic in Style then inc(Result, 2);
  if fsUnderline in Style then inc(Result, 4);
  if fsStrikeOut in Style then inc(Result, 8);
end;

function IntToStyle(i: Integer): TFontStyles;
begin
  Result := [];
  if i and 1 <> 0 then Result := Result + [fsBold];
  if i and 2 <> 0 then Result := Result + [fsItalic];
  if i and 4 <> 0 then Result := Result + [fsUnderline];
  if i and 8 <> 0 then Result := Result + [fsStrikeOut];
end;

procedure TSQLEditForm.SetFonts;
begin
  if OpenRegistry('SQL Editor\TextFont') then begin
    SQLEdit.Font.name := ReadString('Name', 'Courier New');
    SQLEdit.Font.Color := ReadInteger('Color', clWindowText);
    SQLEdit.Font.Size := ReadInteger('Size', 8);
    SQLEdit.Font.Style := IntToStyle(ReadInteger('Style', 0));
    CloseRegistry;
  end;
  // if OpenRegistry('SQL Editor\ListFont') then begin
  // ListView.Font.name := ReadString('Name', 'MS Sans Serif');
  // ListView.Font.Color := ReadInteger('Color', clWindowText);
  // ListView.Font.Size := ReadInteger('Size', 8);
  // ListView.Font.Style := IntToStyle(ReadInteger('Style', 0));
  // CommandResults.Font := ListView.Font;
  // CloseRegistry;
  // PBox.Font := ListView.Font;
  // end;
end;

function TSQLEditForm.SelectFont(Font: TFont; Section: string): Boolean;
begin
  Result := False;
  FontDialog.Font := Font;
  if FontDialog.Execute then begin
    if OpenRegistry(Section) then begin
      WriteString('Name', FontDialog.Font.name);
      WriteInteger('Color', FontDialog.Font.Color);
      WriteInteger('Size', FontDialog.Font.Size);
      WriteInteger('Style', StyleToInt(FontDialog.Font.Style));
      CloseRegistry;
    end;
    Result := True;
  end;
end;

procedure TSQLEditForm.SetupBtnClick(Sender: TObject);
var
  P: TPoint;
begin
  P := ClientToScreen(Point(SetupBtn.Left, SetupBtn.Top + SetupBtn.Height));
  SetupPopup.Popup(P.X, P.Y);
end;

procedure TSQLEditForm.TextFontClick(Sender: TObject);
begin
  if SelectFont(SQLEdit.Font, 'SQL Editor\TextFont') then SetFonts;
end;

procedure TSQLEditForm.ListFontClick(Sender: TObject);
begin
  // if SelectFont(ListView.Font, 'SQL Editor\ListFont') then SetFonts;
end;

procedure TSQLEditForm.checkFinished;
begin
  with SQLEditQueryI do
    if (IsQuery And Fetched) Or (not IsQuery And not Executing) then begin
      BreakBtn.Enabled := False;
      ExecuteBtn.Enabled := True;
      DescribeBtn.Enabled := CanDescribe;
      Screen.Cursor := crDefault;
      if StatusBar.SimpleText = OraSQLEdit.Executing then StatusBar.SimpleText := 'OK'
    end;
end;

procedure TSQLEditForm.btnTemplateClick(Sender: TObject);
begin
  with SQLEdit.Lines do
      Text := 'begin' + #13#10 + '  :SHOW_CLASS_NAME := ''showORAForm'';' + #13#10 +
      '  :SHOW_PARAM_IN := ''[им€ формы]'';' + #13#10 + '/*' + #13#10 + '  параметры инициализации'
      + #13#10 + '  :SHOW_PARAM_IN2 := ''' + #13#10 + '  begin' + #13#10 +
      '    :[параметр 1] := '''''' || [значение 1] ||'''''';' + #13#10 +
      '    :[параметр 2] := '''''' || [значение 2] ||'''''';' + #13#10 + '  end;'';' + #13#10 + '*/'
      + #13#10 + '/*' + #13#10 + '  запрос результата. модальное окно.' + #13#10 +
      '  :SHOW_PARAM_OUT := ''[им€ результата]'';' + #13#10 + '*/' + #13#10 + 'end;' + Text;
end;

function TSQLEditForm.CanDescribe: Boolean;
begin
  Result := True;
end;

end.
