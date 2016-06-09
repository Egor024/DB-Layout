// Direct Oracle Access - Variables property editor form
// Copyright 1997 - 2003 Allround Automations
// support@allroundautomations.com
// http://www.allroundautomations.com

unit OraVarEdit;

interface

uses
  Variants, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ClipBrd, Buttons, LayoutData, DB;

type
  TVariablesForm = class(TForm)
    ButtonPanel: TPanel;
    MainPanel: TPanel;
    HelpPanel: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    MainGroupBox: TGroupBox;
    VarPanel: TPanel;
    VarTopPanel: TPanel;
    VarList: TListBox;
    Label1: TLabel;
    EditPanel: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    PLSQLTablePanel: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    TableSizeEdit: TEdit;
    StringSizeEdit: TEdit;
    TypeList: TComboBox;
    NameEdit: TEdit;
    NewBtn: TButton;
    DeleteBtn: TButton;
    ScanBtn: TButton;
    ValueEdit: TEdit;
    TableCheck: TCheckBox;
    MemoryPanel: TPanel;
    MemoryLabel: TLabel;
    CopyBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure VarListClick(Sender: TObject);
    procedure VarChange(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ValueEditExit(Sender: TObject);
    procedure TableSizeEditExit(Sender: TObject);
    procedure StringSizeEditExit(Sender: TObject);
    procedure TableCheckClick(Sender: TObject);
    procedure TypeListChange(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    Silent: Boolean;
    WorkQuery: TDataSet;
    WorkQueryI: ILayoutQueryInterface;
    QueryName: string;
    procedure BuildVarList;
    procedure EnableButtons;
    procedure AddVariable(AName: string);
    procedure DimPLSQLTable;
    procedure EnableTableFields;
    procedure SetMemoryPanel;
    procedure SelectVariable(Index: Integer);
    procedure FormActivate;
  public
    Changed: Boolean;
    CopiedParams: TParams;
    CopiedQuery: TDataSet;
    CopiedQueryI: ILayoutQueryInterface;
  end;

function ExecuteVariablesEditor(Q: TDataSet; ComponentName: string): Boolean;

const
  ftNames: array [TFieldType] of String = ('ftUnknown', 'ftString', 'ftSmallint', 'ftInteger',
    'ftWord', // 0..4
    'ftBoolean', 'ftFloat', 'ftCurrency', 'ftBCD', 'ftDate', 'ftTime', 'ftDateTime', // 5..11
    'ftBytes', 'ftVarBytes', 'ftAutoInc', 'ftBlob', 'ftMemo', 'ftGraphic', 'ftFmtMemo', // 12..18
    'ftParadoxOle', 'ftDBaseOle', 'ftTypedBinary', 'ftCursor', 'ftFixedChar', 'ftWideString',
    // 19..24
    'ftLargeint', 'ftADT', 'ftArray', 'ftReference', 'ftDataSet', 'ftOraBlob', 'ftOraClob',
    // 25..31
    'ftVariant', 'ftInterface', 'ftIDispatch', 'ftGuid', 'ftTimeStamp', 'ftFMTBcd', // 32..37
    'ftFixedWideChar', 'ftWideMemo', 'ftOraTimeStamp', 'ftOraInterval', // 38..41
    'ftLongWord', 'ftShortint', 'ftByte', 'ftExtended', 'ftConnection', 'ftParams', 'ftStream',
    // 42..48
    'ftTimeStampOffset', 'ftObject', 'ftSingle');

implementation

{$R *.dfm}

// Execute the VariablesEditor, return true if something changed
function ExecuteVariablesEditor(Q: TDataSet; ComponentName: string): Boolean;
begin
  if ComponentName = '' then ComponentName := Q.Name;
  with TVariablesForm.Create(nil) do
    try
      CopiedQuery := Q;
      CopiedQueryI := getLayoutInterface(Q);
      WorkQuery := stdLayoutQuery(nil, CopiedQueryI.LayoutSession);
      WorkQueryI := getLayoutInterface(WorkQuery);
      QueryName := ComponentName;
      CopiedParams := CopiedQueryI.Params;
      Caption := Q.Owner.Name + '.' + Q.Name + ' Variables';
      FormActivate;
      Result := (ShowModal = mrOK) and Changed;
    finally
      CopiedQueryI := nil;
      WorkQueryI := nil;
      Free;
    end;
end;

{
  function TypeString(T: Integer): String;
  begin
  case T of
  otString : Result := 'String';
  otDate : Result := 'Date';
  otInteger : Result := 'Integer';
  otFloat : Result := 'Float';
  otLong : Result := 'Long';
  otLongRaw : Result := 'Long Raw';
  otCursor : Result := 'Cursor';
  otCLOB : Result := 'CLOB';
  otBLOB : Result := 'BLOB';
  otBFile : Result := 'BFile';
  otReference : Result := 'Reference';
  otObject : Result := 'Object';
  otPLSQLString : Result := 'PL/SQL String';
  otChar : Result := 'Char';
  otSubst : Result := 'Substitution';
  otTimestamp : Result := 'Timestamp';
  otTimestampTZ : Result := 'Timestamp with Time Zone';
  otTimestampLTZ : Result := 'Timestamp with Local Time Zone';
  else
  Result := '?';
  end;
  end;
}

procedure TVariablesForm.BuildVarList;
var
  i: Integer;
begin
  VarList.Clear;
  for i := 0 to WorkQueryI.Params.Count - 1 do
      VarList.Items.Add(WorkQueryI.Params[i].Name + ' (' +
      ftNames[WorkQueryI.Params[i].DataType] + ')');
  CopyBtn.Enabled := WorkQueryI.Params.Count > 0;
end;

procedure TVariablesForm.FormCreate(Sender: TObject);
begin
{$IFDEF CompilerVersion4} {$IFNDEF CompilerVersion5}
  VarList.MultiSelect := True;
{$ENDIF} {$ENDIF}
  Silent := True;
  Changed := False;
  Width := EditPanel.Width + 30 + 160;
  Height := ButtonPanel.Height * 8 + 10;
  EnableButtons;
end;

procedure TVariablesForm.FormActivate;
begin
{$IFDEF CompilerVersion4}
  Constraints.MinHeight := 10 + Height - (EditPanel.Height - (NewBtn.Top + NewBtn.Height));
  Constraints.MinWidth := 10 + Width - VarList.Width;
{$ENDIF}
  WorkQueryI.Params.Assign(CopiedQueryI.Params);
  BuildVarList;
  if CopiedParams.Count > 0 then SelectVariable(0)
  else SelectVariable(-1);
  VarListClick(nil);
  Silent := False;
  // InitForm(self);
end;

procedure TVariablesForm.FormDestroy(Sender: TObject);
begin
  CopiedQueryI := nil;
  WorkQueryI := nil;
  WorkQuery.Free;
end;

procedure TVariablesForm.EnableButtons;
begin
  DeleteBtn.Enabled := (VarList.ItemIndex >= 0);
  NameEdit.Enabled := (VarList.ItemIndex >= 0);
  TypeList.Enabled := (VarList.ItemIndex >= 0);
  ValueEdit.Enabled := True;
end;

procedure TVariablesForm.VarListClick(Sender: TObject);
var
  v: Variant;
begin
  Silent := True;
  if (VarList.ItemIndex < 0) or (VarList.Items.Count = 0) then begin
    NameEdit.Text := '';
    TypeList.ItemIndex := -1;
    ValueEdit.Text := '';
    Silent := False;
    EnableButtons;
    exit;
  end;
  with WorkQueryI.Params[VarList.ItemIndex] do begin
    NameEdit.Text := Name;
    v := WorkQueryI.Params.ParamByName(Name).Value;
    if VarIsEmpty(v) or VarIsNull(v) then ValueEdit.Text := ''
    else ValueEdit.Text := v;
    TypeList.ItemIndex := Integer(DataType);
    {
      case DataType of
      otInteger: TypeList.ItemIndex := 0;
      otFloat: TypeList.ItemIndex := 1;
      otString: TypeList.ItemIndex := 2;
      otDate: TypeList.ItemIndex := 3;
      otLong: TypeList.ItemIndex := 4;
      otLongRaw: TypeList.ItemIndex := 5;
      otCursor: TypeList.ItemIndex := 6;
      otCLOB: TypeList.ItemIndex := 7;
      otBLOB: TypeList.ItemIndex := 8;
      otBFile: TypeList.ItemIndex := 9;
      otReference: TypeList.ItemIndex := 10;
      otObject: TypeList.ItemIndex := 11;
      otPLSQLString: TypeList.ItemIndex := 12;
      otChar: TypeList.ItemIndex := 13;
      otSubst: TypeList.ItemIndex := 14;
      otTimestamp: TypeList.ItemIndex := 15;
      otTimestampTZ: TypeList.ItemIndex := 16;
      otTimestampLTZ: TypeList.ItemIndex := 17;
      else begin
      SHowMessage('Unknown type:' + IntToStr(BufType));;
      TypeList.ItemIndex := -1;
      end;
      end;
    }
    // TableCheck.Checked := IsPLSQLTable;
    // if IsPLSQLTable then
    // begin
    // TableSizeEdit.Text := IntToStr(ArraySize);
    // if BufType = otString then StringSizeEdit.Text := IntToStr(BufSize - 1);
    // end;
    // EnableTableFields;
    SetMemoryPanel;
  end;
  EnableButtons;
  Silent := False;
end;

procedure TVariablesForm.AddVariable(AName: string);
begin
  if AName = '' then exit;
  if WorkQueryI.Params.FindParam(AName) <> nil then exit;
  Changed := True;
  WorkQueryI.Params.CreateParam(ftWideString, AName, ptInputOutput).Size := 4000;
  BuildVarList;
  SelectVariable(-1);
  VarListClick(nil);
  VarList.SetFocus;
end;

procedure TVariablesForm.VarChange(Sender: TObject);
var
  i: Integer;
  NewType: TFieldType;
begin
  if Silent then exit;
  i := VarList.ItemIndex;
  if i < 0 then exit;
  Changed := True;
  with WorkQueryI.Params[i] do begin
    Name := NameEdit.Text;
    NewType := TFieldType(TypeList.ItemIndex);
    VarList.Items[i] := Name + ' (' + ftNames[NewType] + ')';
    if DataType <> NewType then begin
      DataType := NewType;
      ValueEdit.Text := '';
    end;
    SelectVariable(i);
  end;
  EnableButtons;
end;

procedure TVariablesForm.NewBtnClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 1 to 100 do begin
    if WorkQueryI.Params.FindParam('var' + IntToStr(i)) = nil then begin
      WorkQueryI.Params.CreateParam(ftWideString, 'var' + IntToStr(i), ptInputOutput).Size := 4000;
      Break;
    end;
  end;
  BuildVarList;
  SelectVariable(VarList.Items.Count - 1);
  VarListClick(nil);
  NameEdit.SetFocus;
  Changed := True;
end;

procedure TVariablesForm.SelectVariable(Index: Integer);
begin
  VarList.ItemIndex := Index;
  if VarList.MultiSelect and (Index >= 0) then VarList.Selected[Index] := True;
end;

procedure TVariablesForm.DeleteBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := VarList.ItemIndex;
  WorkQueryI.Params.Delete(VarList.ItemIndex);
  BuildVarList;
  if Index >= VarList.Items.Count then Index := VarList.Items.Count - 1;
  SelectVariable(Index);
  VarListClick(nil);
  Changed := True;
end;

procedure TVariablesForm.OKBtnClick(Sender: TObject);
begin
  if Screen.ActiveControl is TEdit then begin
    if Assigned(TEdit(Screen.ActiveControl).OnExit) then TEdit(Screen.ActiveControl).OnExit(Sender);
  end;
  CopiedQueryI.Params.Assign(WorkQueryI.Params);
end;

procedure TVariablesForm.ValueEditExit(Sender: TObject);
begin
  if (ActiveControl = CancelBtn) or (ActiveControl = DeleteBtn) then exit;
  try
    if ValueEdit.Text = '' then WorkQueryI.Params.ParamByName(NameEdit.Text).Value := Null
    else WorkQueryI.Params.ParamByName(NameEdit.Text).AsString := ValueEdit.Text;
    Changed := True;
  except
    on E: Exception do begin
      ShowMessage('Error converting value');
      ValueEdit.SetFocus;
    end;
  end;
end;

procedure TVariablesForm.DimPLSQLTable;
var
  i: Integer;
  VarName: string;
  VarType: TFieldType;
begin
  i := VarList.ItemIndex;
  if i < 0 then exit;
  Changed := True;
  with WorkQueryI.Params[i] do begin
    VarName := Name;
    VarType := DataType;
  end;
  if not TableCheck.Checked then WorkQueryI.Params.CreateParam(VarType, VarName, ptInputOutput);
  SetMemoryPanel;
end;

procedure TVariablesForm.TableSizeEditExit(Sender: TObject);
begin
  if (ActiveControl = CancelBtn) or (ActiveControl = DeleteBtn) then exit;
  try
    DimPLSQLTable;
  except
    on E: Exception do begin
      ShowMessage(E.Message);
      TableSizeEdit.SetFocus;
    end;
  end;
end;

procedure TVariablesForm.StringSizeEditExit(Sender: TObject);
begin
  if (ActiveControl = CancelBtn) or (ActiveControl = DeleteBtn) then exit;
  try
    DimPLSQLTable;
  except
    on E: Exception do begin
      ShowMessage(E.Message);
      StringSizeEdit.SetFocus;
    end;
  end;
end;

procedure TVariablesForm.TableCheckClick(Sender: TObject);
begin
  if Silent then exit;
  Silent := True;
  try
    if TableCheck.Checked then begin
      EnableTableFields;
      TableSizeEdit.Text := '25';
      if TypeList.ItemIndex = 2 then StringSizeEdit.Text := '40';
    end;
    EnableTableFields;
    DimPLSQLTable;
  finally
    Silent := False;
  end;
end;

procedure TVariablesForm.TypeListChange(Sender: TObject);
begin
  Silent := True;
  try
    if TypeList.ItemIndex in [0, 1, 2, 3] then begin
      TableCheck.Enabled := True;
      EnableTableFields;
    end else begin
      TableCheck.Enabled := False;
      TableCheck.Checked := False;
      EnableTableFields;
    end;
  finally
    Silent := False;
  end;
  VarChange(Sender);
end;

procedure TVariablesForm.EnableTableFields;
// var
// OldSilent: Boolean;
begin
  // OldSilent := Silent;
  // Silent := False;
  // try
  // TableCheck.Enabled := TypeList.ItemIndex in [0, 1, 2, 3];
  // if TableCheck.Checked then
  // begin
  // TableSizeEdit.Enabled := True;
  // if TableSizeEdit.Text = '' then TableSizeEdit.Text := '25';
  // if TypeList.ItemIndex <> 2 then
  // begin
  // StringSizeEdit.Enabled := False;
  // StringSizeEdit.Text := '';
  // end else begin
  // StringSizeEdit.Enabled := True;
  // if StringSizeEdit.Text = '' then StringSizeEdit.Text := '40';
  // end;
  // ValueEdit.Enabled := False;
  // ValueEdit.Text := '';
  // end else begin
  // TableSizeEdit.Text := '';
  // TableSizeEdit.Enabled := False;
  // StringSizeEdit.Text := '';
  // StringSizeEdit.Enabled := False;
  // ValueEdit.Enabled := True;
  // end;
  // finally
  // Silent := OldSilent;
  // end;
end;

procedure TVariablesForm.SetMemoryPanel;
// var
// OldWidth, ElementSize, Memory: Integer;
// s: string;
begin
  // if TableCheck.Checked then
  // begin
  // MemoryPanel.Visible := True;
  // ElementSize := 0;
  // case TypeList.ItemIndex of
  // 0: ElementSize := 22;
  // 1: ElementSize := 22;
  // 2: ElementSize := StrToInt(StringSizeEdit.Text);
  // 3: ElementSize := 7;
  // end;
  // Memory := ElementSize * StrToInt(TableSizeEdit.Text);
  // if Memory > 32512 then
  // begin
  // MemoryLabel.Font.Color := clRed;
  // s := ' bytes (Oracle8 only!) '
  // end else begin
  // MemoryLabel.Font.Color := clWindowText;
  // s := ' bytes ';
  // end;
  // MemoryLabel.Caption := ' ' + IntToStr(Memory) + s;
  // OldWidth := MemoryPanel.Width;
  // MemoryPanel.Width := MemoryLabel.Width;
  // MemoryPanel.Left := MemoryPanel.Left - (MemoryPanel.Width - OldWidth);
  // end else begin
  // MemoryPanel.Visible := False;
  // end;
end;

procedure TVariablesForm.CopyBtnClick(Sender: TObject);
var
  i: Integer;
  s: string;
  function VarName(Name: string): string;
  begin
    Result := Name;
    if (Result <> '') and (Result[1] = ':') then Delete(Result, 1, 1);
  end;

begin
  s := '';
  for i := 0 to WorkQueryI.Params.Count - 1 do begin
    s := s + '  ' + QueryName + '.SetVariable(''' + VarName(WorkQueryI.Params[i].Name) +
      ''', );' + #13#10;
  end;
  if s <> '' then ClipBoard.AsText := s;
end;

procedure TVariablesForm.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = vk_down) and (Shift = []) then begin
    Key := 0;
    if VarList.ItemIndex < VarList.Items.Count - 1 then begin
      VarList.ItemIndex := VarList.ItemIndex + 1;
      ValueEditExit(Nil);
      VarListClick(Nil);
      if Sender is TEdit then TEdit(Sender).SelectAll;
    end;
  end;
  if (Key = vk_up) and (Shift = []) then begin
    Key := 0;
    if VarList.ItemIndex > 0 then begin
      VarList.ItemIndex := VarList.ItemIndex - 1;
      ValueEditExit(Nil);
      VarListClick(Nil);
      if Sender is TEdit then TEdit(Sender).SelectAll;
    end;
  end;
end;

end.
