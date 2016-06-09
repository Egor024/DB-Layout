unit Utilities;

interface

USES
  cxGridCustomTableView, cxLookAndFeelPainters, cxCheckBox, cxEdit, Classes, Windows,
  cxCustomData, Dialogs, DB, Controls, cxCheckComboBox, cxCheckListBox;

function getOwnerByClass(const pComp: TComponent; const pClass: TComponentClass): TComponent;
function getParentByClass(const pCntrl: TControl; const pClass: TWinControlClass): TWinControl;
function getChildByClass(const pCntrl: TComponent; const pClass: TComponentClass): TComponent;
function getChildByName(const pCntrl: TComponent; const pName: String): TComponent;

procedure CalculateCheckStatesByEditValue(const p_collection: TCollection;
  const AEditValue: TcxEditValue; var ACheckStates: TcxCheckStates);
function CalculateEditValueByCheckStates(const p_collection: TCollection;
  const ACheckStates: TcxCheckStates): TcxEditValue; overload;
function CalculateEditValueByCheckStates(const p_checkBox: TcxCustomCheckComboBox)
  : TcxEditValue; overload;
function CalculateEditValueByEditStates(AValue: TcxEditValue; const ACollection: TCollection)
  : TcxEditValue;
procedure SetCheckStatesByValues(const p_ChkComboBox: TcxCheckComboBox; const AValues: String);

function VarIsNumeric(const V: Variant): Boolean; overload;
function ifThen(const condition: Boolean; const vTrue, vFalse: Variant): Variant; inline; Overload;

procedure FreeAppMem;
function GetBuildTime: TDateTime;

function GetTempPath: string;
function GetTempFileName(const pPrefix: String): string;
function DeleteFiles(const pFileMask: string): Longint;

function chkClipboard2Strings: Longint;
function Clipboard2Strings(var RecordList, FieldsList: TStrings): Longint;

function ModalResult2String(const pModalResult: TModalResult): String;
function String2ModalButton(const pButtons: String; const pInsteadOfEmpty: TMsgDlgButtons = mbYesNo)
  : TMsgDlgButtons;
procedure CreateFieldMemData(AMemData: TDataSet; AFieldName: string; AFieldType: TFieldType);

procedure pasteToTableView(const p_text: String; const aTableView: TcxCustomGridTableView);

function compMask(const cStr, cMask: string; pCaseSensitive: boolean = False): boolean;

implementation

USES
  Variants, Masks, SysUtils, cxTextEdit, RTTI, Clipbrd;

function compMask(const cStr, cMask: string; pCaseSensitive: boolean): boolean;
begin
  if pCaseSensitive then Result := MatchesMask(cStr, cMask)
  else Result := MatchesMask(AnsiLowerCase(cStr), AnsiLowerCase(cMask));
end;

// Чистим память процесса приложения (пинок винде чтоб определила сколько на самом деле нужно в данный момент процессу оперативки)
Procedure FreeAppMem;
begin
  if Win32Platform <> VER_PLATFORM_WIN32_NT then exit;
  SetProcessWorkingSetSize(GetCurrentProcess, DWORD(-1), DWORD(-1));
end;

function GetBuildTime: TDateTime;
var
  Offset: DWORD;
  FD: LongRec;
  Date, Time: TDateTime;
begin
  Result := 0;
  Offset := PImageNtHeaders(HInstance + DWORD(PImageDosHeader(HInstance)._lfanew))
    .OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress;
  if Offset <> 0 then begin
    Integer(FD) := PInteger(Offset + HInstance + 4)^;
    if TryEncodeDate(FD.Hi shr 9 + 1980, FD.Hi shr 5 and 15, FD.Hi and 31, Date) and
      TryEncodeTime(FD.Lo shr 11, FD.Lo shr 5 and 63, FD.Lo and 31 shl 1, 0, Time) then
        Result := Date + Time;
  end;
end;

function GetTempPath: string;
var
  Len: Integer;
begin
  Result := ''; // DO NOT LOCALIZE
  SetLastError(ERROR_SUCCESS);

  // get memory for the buffer retaining the temp path (plus null-termination)
  Len := Windows.GetTempPath(0, nil);
  SetLength(Result, Len - 1);
  if Windows.GetTempPath(Len, PWideChar(Result)) <> 0 then begin
    Len := Windows.GetLongPathName(PChar(Result), nil, 0);
    SetLength(Result, Len - 1);
    Windows.GetLongPathName(PChar(Result), PChar(Result), Len);
  end;
end;

function GetTempFileName(const pPrefix: String): string;
var
  TempPath: string;
  ErrCode: UINT;
begin
  TempPath := GetTempPath;
  SetLength(Result, MAX_PATH);

  SetLastError(ERROR_SUCCESS);
  ErrCode := Windows.GetTempFileName(PChar(TempPath), PChar(pPrefix), 0, PChar(Result));
  // DO NOT LOCALIZE
  if ErrCode = 0 then raise EInOutError.Create(SysErrorMessage(GetLastError));

  SetLength(Result, StrLen(PChar(Result)));
end;

function DeleteFiles(const pFileMask: string): Longint;
var
  SearchRec: TSearchRec;
  V: Boolean;
begin
  Result := 0;
  V := FindFirst(ExpandFileName(pFileMask), faAnyFile, SearchRec) = 0;
  try
    if V then
      repeat
        if (SearchRec.Name[1] <> '.') and (SearchRec.Attr and faDirectory <> faDirectory) then begin
          if DeleteFile(ExtractFilePath(pFileMask) + SearchRec.Name) then Result := Result + 1;
        end;
      until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;
end;

function ifThen(const condition: Boolean; const vTrue, vFalse: Variant): Variant; inline; Overload;
begin
  if (condition) then Result := vTrue
  else Result := vFalse;
end;

function CompToString(VComp: TComponent): String;
var
  MemStream: TMemoryStream;
begin
  MemStream := TMemoryStream.Create;
  try
    MemStream.WriteComponent(VComp);
    MemStream.Position := 0;
    SetLength(Result, MemStream.Size * sizeof(char));
    BinToHex(MemStream.Memory, PWideChar(Result), MemStream.Size);
  finally
    MemStream.Free;
  end;
end;

procedure StringToComp(VComp: TComponent; const p_string: String);
var
  MemStream: TMemoryStream;
begin
  MemStream := TMemoryStream.Create;
  try
    MemStream.SetSize(Length(p_string) div sizeof(char));
    HexToBin(PWideChar(p_string), MemStream.Memory, MemStream.Size);
    MemStream.Position := 0;
    MemStream.ReadComponent(VComp);
  finally
    MemStream.Free;
  end;
end;

function object_to_str(p_obj: TObject): String;
var
  ctx: TRttiContext;
  t: TRttiType;
  i: Longint;
  Len: Longint;

begin
  with TRttiContext.Create do
    try
      t := ctx.GetType(p_obj.ClassType);
      Result := 'Class:' + p_obj.ClassName;
      Len := Length(t.GetProperties) - 1;
      for i := 0 to Len do
        with t.GetProperties[i] do begin
          if IsReadable And IsWritable then
            with GetValue(p_obj) do
              if not IsObject and not IsClass and not IsType<String> then
                  Result := Result + #13#10 + Name + #13#10 + ToString;
        end;
      t.Free;
    finally
      Free;
    end;

end;

procedure str_to_object(p_str: String; p_obj: TObject);
var
  ctx: TRttiContext;
  t: TRttiType;
  i: Longint;
  p: TRttiProperty;
  vstr: TStringList;

begin
  vstr := TStringList.Create;
  vstr.Text := p_str;
  if vstr[0] = 'Class:' + p_obj.ClassName then begin
    with TRttiContext.Create do
      try
        t := ctx.GetType(p_obj.ClassType);
        i := 1;
        while i < vstr.Count - 1 do begin
          try
            p := t.GetProperty(vstr[i])
          except
            p := nil;
          end;
          if (p <> nil) and p.IsWritable then begin
            try
              p.SetValue(p_obj, TValue.From<String>(vstr[i + 1]));
            except
            end;
          end;
          i := i + 2;
        end;
        t.Free;
      finally
        Free;
      end;
  end;
  vstr.Free;
end;

function VarIsNumeric(const V: Variant): Boolean; overload;
begin
  Result := Variants.VarIsNumeric(V);
  if not Result and VarIsStr(V) then
    try
      VarAsType(V, varDouble);
      Result := true;
    except
    end;
end;

function getParentByClass(const pCntrl: TControl; const pClass: TWinControlClass): TWinControl;
var
  vCntrl: TControl;
begin
  if pClass <> nil then begin
    vCntrl := pCntrl;
    while vCntrl <> nil do begin
      if vCntrl.InheritsFrom(pClass) then begin
        Result := TWinControl(vCntrl);
        exit;
      end;
      vCntrl := vCntrl.Parent;
    end;
  end;
  Result := nil;
end;

function getOwnerByClass(const pComp: TComponent; const pClass: TComponentClass): TComponent;
var
  VComp: TComponent;
begin
  if pClass <> nil then begin
    VComp := pComp;
    while VComp <> nil do begin
      if VComp.InheritsFrom(pClass) then begin
        Result := VComp;
        exit;
      end;
      VComp := VComp.Owner;
    end;
  end;
  Result := nil;
end;

function getChildByClass(const pCntrl: TComponent; const pClass: TComponentClass): TComponent;
var
  i: Longint;
begin
  if pClass <> nil then begin
    with pCntrl do
      for i := 0 to ComponentCount - 1 do
        if Components[i].InheritsFrom(pClass) then begin
          Result := Components[i];
          exit;
        end;
    with pCntrl do
      for i := 0 to ComponentCount - 1 do begin
        Result := getChildByClass(Components[i], pClass);
        if Result <> nil then exit;
      end;
  end;
  Result := nil;
end;

function getChildByName(const pCntrl: TComponent; const pName: String): TComponent;
var
  i: Longint;
begin
  if pName <> '' then begin
    Result := pCntrl.FindComponent(pName);
    if Result <> nil then exit;
    with pCntrl do
      for i := 0 to ComponentCount - 1 do begin
        Result := getChildByName(Components[i], pName);
        if Result <> nil then exit;
      end;
  end;
  Result := nil;
end;

function normCheckValue(const p_values: String): String;
begin
  Result := ',' + stringreplace(p_values, ' ', '', [rfReplaceAll]) + ',';
end;

function hasCheckValue(const p_values, p_value: String): Boolean;
begin
  Result := AnsiPos(',' + p_value + ',', p_values) <> 0;
end;

function checkTcxCheckComboBoxItem(const p_item: TCollectionItem;
  const p_value: TcxEditValue): Boolean;
begin
  with TcxCheckComboBoxItem(p_item) do
    try
      // Result := WordInStringExt(p_value, IntToStr(Tag), [' ', ',']) <> 0;
      Result := hasCheckValue(normCheckValue(p_value), IntToStr(Tag));
    except
      Result := False;
    end;
end;

procedure addTcxCheckComboBoxItem(const p_item: TCollectionItem; var p_value: TcxEditValue);
begin
  with TcxCheckComboBoxItem(p_item) do
    try
      if (VarType(p_value) <> varUString) Or (p_value = '') then p_value := IntToStr(Tag)
      else p_value := p_value + ',' + IntToStr(Tag);
    except
      p_value := IntToStr(Tag);
    end;
end;

procedure initTcxCheckComboBoxItem(const p_item: TCollectionItem; const p_fields: TFields);
begin
  with TcxCheckComboBoxItem(p_item), p_fields do begin
    Tag := Fields[0].AsInteger;
    if Count >= 2 then ShortDescription := Fields[1].AsString
    else ShortDescription := IntToStr(Tag);
    if Count >= 3 then Description := ShortDescription + '_' + Fields[2].AsString
    else Description := ShortDescription;
  end;
end;

function checkTCollectionItem(const p_item: TCollectionItem; const p_value: TcxEditValue): Boolean;
begin
  with p_item do
    try
      // Result := WordInStringExt(p_value, '''' + DisplayName + '''', [' ', ',']) <> 0;
      Result := hasCheckValue(normCheckValue(p_value), '''' + DisplayName + '''');
    except
      Result := False;
    end;
end;

procedure addTCollectionItem(const p_item: TCollectionItem; var p_value: TcxEditValue);
begin
  with p_item do
    try
      if (VarType(p_value) <> varUString) Or (p_value = '') then
          p_value := '''' + DisplayName + ''''
      else p_value := p_value + ',''' + DisplayName + '''';
    except
      p_value := '''' + DisplayName + '''';
    end;
end;

procedure initTCollectionItem(const p_item: TCollectionItem; const p_fields: TFields);
begin
  p_item.DisplayName := p_fields.Fields[0].AsString;
end;

procedure CalculateCheckStatesByEditValue(const p_collection: TCollection;
  const AEditValue: TcxEditValue; var ACheckStates: TcxCheckStates);
var
  i: Longint;
  checkItem: function(const p_item: TCollectionItem; const p_value: TcxEditValue): Boolean;
begin
  if (p_collection is TcxCheckComboBoxItems) or (p_collection is TcxCheckListBoxItems) then
      checkItem := checkTcxCheckComboBoxItem
  else checkItem := checkTCollectionItem;

  with p_collection do begin
    if Count <= 0 then exit;
    SetLength(ACheckStates, Count);
    for i := 0 to Count - 1 do
      if checkItem(Items[i], AEditValue) then ACheckStates[i] := cbsChecked
      else ACheckStates[i] := cbsUnChecked;
  end;
end;

function CalculateEditValueByCheckStates(const p_collection: TCollection;
  const ACheckStates: TcxCheckStates): TcxEditValue;
var
  i: Longint;
  addItem: procedure(const p_item: TCollectionItem; var p_value: TcxEditValue);
begin
  Result := '';
  if (p_collection is TcxCheckComboBoxItems) or (p_collection is TcxCheckListBoxItems) then
      addItem := addTcxCheckComboBoxItem
  else addItem := addTCollectionItem;
  with p_collection do
    for i := 0 to Length(ACheckStates) - 1 do
      if ACheckStates[i] = cbsChecked then addItem(Items[i], Result);
end;

function CalculateEditValueByEditStates(AValue: TcxEditValue; const ACollection: TCollection)
  : TcxEditValue;
var
  V: Int64;
  i, ACode: Integer;
  addItem: procedure(const p_item: TCollectionItem; var p_value: TcxEditValue);
begin
  Result := '';

  if VarIsNumeric(AValue) or VarIsStr(AValue) or VarIsNull(AValue) then begin
    if ACollection is TcxCheckComboBoxItems then addItem := addTcxCheckComboBoxItem
    else addItem := addTCollectionItem;
    if VarIsNull(AValue) then V := 0
    else if VarIsStr(AValue) then begin
      val(AValue, V, ACode);
      if not ACode = 0 then exit;
    end
    else V := VarAsType(AValue, varInt64);
    for i := 0 to ACollection.Count - 1 do begin
      if V and 1 <> 0 then addItem(ACollection.Items[i], Result);
      V := V shr 1;
      if V = 0 then exit;
    end;
  end
end;

function CalculateEditValueByCheckStates(const p_checkBox: TcxCustomCheckComboBox): TcxEditValue;
var
  i: Longint;
  str: String;
begin
  with p_checkBox, p_checkBox.Properties do
    for i := 0 to Items.Count - 1 do
      if States[i] = cbsChecked then begin
        if str = '' then str := IntToStr(Items[i].Tag)
        else str := str + ',' + IntToStr(Items[i].Tag);
      end;
  Result := str;
end;

procedure SetCheckStatesByValues(const p_ChkComboBox: TcxCheckComboBox; const AValues: String);
var
  i: Longint;
  vValues: String;
begin
  with p_ChkComboBox.Properties.Items do begin
    if Count <= 0 then exit;
    vValues := normCheckValue(AValues);
    for i := 0 to Count - 1 do
      with Items[i] do
        if hasCheckValue(vValues, IntToStr(Tag)) then p_ChkComboBox.States[i] := cbsChecked
        else p_ChkComboBox.States[i] := cbsUnChecked;
  end;
end;

function chkClipboard2Strings: Longint;
var
  RecordList, FieldsList: TStrings;
begin
  RecordList := TStringList.Create;
  FieldsList := TStringList.Create;
  try
    Result := Clipboard2Strings(RecordList, FieldsList);
  finally
    RecordList.Free;
    FieldsList.Free;
  end;
end;

function Clipboard2Strings(var RecordList, FieldsList: TStrings): Longint;
begin
  Result := 0;
  if not Clipboard.HasFormat(CF_TEXT) then exit;
  if RecordList = nil then RecordList := TStringList.Create;
  RecordList.Text := Clipboard.AsText;
  if RecordList.Count <> 0 then begin
    if FieldsList = nil then FieldsList := TStringList.Create;
    FieldsList.Text := stringreplace(RecordList.Strings[0], #9, #10, [rfReplaceAll]);
    Result := FieldsList.Count;
  end;
end;

procedure pasteToTableView(const p_text: String; const aTableView: TcxCustomGridTableView);
var
  vLines: TStringList;
  vValues: TStringList;
  II, i: Longint;
  vDataController: TcxCustomDataController;

begin
  vDataController := aTableView.DataController;
  if ([dceoInsert, dceoAppend] * vDataController.EditOperations) = [] then
      raise Exception.Create('невозможно сохранить данные в таблице "' + aTableView.Name + '"');

  vLines := TStringList.Create;
  vValues := TStringList.Create;
  with aTableView do
    try
      vDataController.BeginUpdate;
      vLines.Text := p_text;
      for i := 0 to vLines.Count - 1 do begin
        vValues.Text := stringreplace(vLines[i], #9, #10, [rfReplaceAll]);
        with vDataController do begin
          if dceoAppend in EditOperations then Append
          else Insert;
          for II := 0 to vValues.Count - 1 do
            if II < VisibleItemCount then
              with VisibleItems[II] do
                if (Properties = nil) or not Properties.ReadOnly then EditValue := vValues[II];
        end;
        vDataController.Post(true);
      end;
    finally
      vDataController.EndUpdate;
      vLines.Free;
      vValues.Free;
    end;
end;

const
  ModalResults: array [mrNone .. mrClose] of string = ('mrNone', 'mrOk', 'mrCancel', 'mrAbort',
    'mrRetry', 'mrIgnore', 'mrYes', 'mrNo', 'mrAll', 'mrNoToAll', 'mrYesToAll', 'mrClose');

function ModalResult2String(const pModalResult: TModalResult): String;
begin
  case pModalResult of
    Low(ModalResults) .. High(ModalResults): Result := ModalResults[pModalResult];
  else Result := IntToStr(pModalResult);
  end;
end;

const
  MsgDlgButtons: array [TMsgDlgBtn] of string = ('mbYes', 'mbNo', 'mbOK', 'mbCancel', 'mbAbort',
    'mbRetry', 'mbIgnore', 'mbAll', 'mbNoToAll', 'mbYesToAll', 'mbHelp', 'mbClose');

function String2ModalButton(const pButtons: String; const pInsteadOfEmpty: TMsgDlgButtons = mbYesNo)
  : TMsgDlgButtons;
var
  V: TMsgDlgBtn;
begin
  Result := [];
  for V := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    if AnsiPos(MsgDlgButtons[V], pButtons) <> 0 then Result := Result + [V];
  if Result = [] then Result := pInsteadOfEmpty;
end;

procedure CreateFieldMemData(AMemData: TDataSet; AFieldName: string; AFieldType: TFieldType);
begin
  if (AMemData = nil) or (AFieldName = '') then exit;
  with AMemData.FieldDefs.AddFieldDef do begin
    Name := AFieldName;
    DataType := AFieldType;
    CreateField(AMemData);
  end;
end;

end.
