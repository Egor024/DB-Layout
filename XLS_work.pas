unit XLS_work;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, layoutForm,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxLayoutContainer, dxLayoutControl,
  cxContainer, cxEdit, cxListBox, dxLayoutControlAdapters, Menus, StdCtrls, cxButtons, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, dxmdaset, cxGridLevel, cxClasses, cxGridCustomView, cxGrid,
  cxInplaceContainer, cxVGrid, cxBlobEdit, cxDropDownEdit, cxTextEdit, LayoutThreads, cxButtonEdit,
  cxCheckBox;

type
  TfrmXLSwork = class(TfrmLayout)
    btnRefresh: TcxButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    tvFiles: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    dxLayoutControl1Item4: TdxLayoutItem;
    mdFiles: TdxMemData;
    dsFiles: TDataSource;
    mdFilesName: TStringField;
    mdFilesFullName: TStringField;
    tvFilesName: TcxGridDBColumn;
    tvFilesFullName: TcxGridDBColumn;
    dxLayoutControl1SplitterItem1: TdxLayoutSplitterItem;
    tvSheets: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    dxLayoutControl1Item1: TdxLayoutItem;
    mdSheets: TdxMemData;
    mdSheetsName: TStringField;
    dsSheets: TDataSource;
    tvSheetsName: TcxGridDBColumn;
    vgParams: TcxVerticalGrid;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1SplitterItem2: TdxLayoutSplitterItem;
    btnSave: TcxButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    btnRun: TcxButton;
    dxLayoutControl1Item6: TdxLayoutItem;
    procedure btnRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvFilesStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure tvSheetsStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure tvFilesFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure tvSheetsFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure OnEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TxlsSheetParamKind = (spkUserDefined, spkSELECT, spkMACRO, spkCELL, spkOPTIONS);

  TxlsSheetParam = class
  private
    FName: String;
    FKind: TxlsSheetParamKind;
    FValue: String;
    FFormula: String;
    procedure SetValue(const Value: String); virtual;
    procedure SetFormula(const Value: String);
  public
    constructor Create(const pName: String);
    function getVGFormulaEditRow(const pVG: TcxVerticalGrid): TcxEditorRow;
    function getVGValueEditRow(const pVG: TcxVerticalGrid): TcxEditorRow;
    property Name: String read FName;
    property Kind: TxlsSheetParamKind read FKind;
    property Value: String read FValue write SetValue;
    property Formula: String read FFormula write SetFormula;
  end;

  TxlsSheetParams = class(TList)
  private
    FisVirtual: Boolean;
    function Get(Index: Integer): TxlsSheetParam; inline;
    procedure Put(Index: Integer; const Value: TxlsSheetParam); inline;
    function getParamValue(const pName: String): String;
    procedure setParamValue(const pName, Value: String);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create; overload;
    constructor Create(const pSrcParams: TxlsSheetParams); overload;
    procedure Load(const pFullFileName: String; const pSheetName: String); overload;
    procedure Load(const pSrcParams: TxlsSheetParams); overload;
    procedure SaveValues(const pFullFileName: String; const pSheetName: String);
    procedure SaveFormulas(const pFullFileName: String; const pSheetName: String);
    function Add(const pParamName: String): TxlsSheetParam;
    function IndexOf(const pName: String): Integer;
    property Items[Index: Integer]: TxlsSheetParam read Get write Put; default;
    property Value[const pName: String]: String read getParamValue write setParamValue;
    property isVirtual: Boolean read FisVirtual write FisVirtual;
  end;

  TxlsWorkThread = class(TLayoutQueryThread)
  private
    FFullFileName: String;
    FRunnigSheetName: String;
    FParams: TxlsSheetParams;
  protected
    function prepare_sheet: Boolean;
    procedure run_sheet;
    function getStateText: String; override;
    procedure Execute; override;
  public
    constructor Create(const pFullFileName: String; const pIsVirtual: Boolean); overload;
    destructor Destroy; override;
    function check_worksheet: Boolean;
    property Params: TxlsSheetParams read FParams;
    property RunnigSheetName: String read FRunnigSheetName write FRunnigSheetName;
  end;

  TReportMode = (rmUser, rmDesigner, rmTemplate);

  TxlsReportThread = class(TxlsWorkThread)
  private
    FReportID: Variant;
    FPath: String;
    FReportMode: TReportMode;
    FWorkbook: OleVariant;
    function prepare_workbook: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const pReportID: Variant; const pPath: String;
      const pReportMode: TReportMode); overload;
  end;

procedure showXLSworkSettings;
function isWorksheetRunnable(const pFullFileName: String; const pSheetName: String): Boolean;
procedure save_XLS_report(const p_ReportID: Variant; const p_file: String = '');

const
  stdXLSParamNames: array [TxlsSheetParamKind] of String = ('', 'SELECT', 'MACRO', 'CELL',
    'OPTIONS');

implementation

uses Utilities, StrUtils, ORAStyles, ActiveX, ExcelApp, ORALayout, LayoutData,
  OraSQLEdit,
  cxCalendar;
{$R *.dfm}

const
  stdCategoryCaptions: array [Boolean] of String = ('Настраиваемые', 'Стандартные');

var
  frmXLSwork: TfrmXLSwork;

procedure save_XLS_report(const p_ReportID: Variant; const p_file: String);
var
  Stream: TStream;
  v_file: String;
  vDS : TDataSet;
begin
  vDS:=stdLayoutQuery;
  with vDS, getLayoutInterface(vDS) do
    try
      SQL.text := 'select x.id, x.file_name, x.xls_file, x.rowid from ' + mainSession.Schema +
        '.v_XLS_REPORTS x where x.id=' + VarToStr(p_ReportID);
      open;
      if not EOF then begin
        if p_file = '' then v_file := FieldByName('file_name').AsString
        else v_file := p_file;
        if MessageDlg('Подтвердите сохранение шаблона отчета (№' + VarToStr(p_ReportID) + ') "' +
          v_file + '"', mtConfirmation, mbYesNo, 0) = mrYes then begin
          Edit;
          FieldByName('file_name').AsString := v_file;
          with TBlobField(FieldByName('xls_file')) do begin
            Stream := TFileStream.Create(v_file, fmOpenRead);
            try
              LoadFromStream(Stream);
              if Stream.Size = 0 then
                if MessageDlg('Файл ''' + v_file + ''' не содержит данных! Продолжить?',
                  mtConfirmation, mbYesNo, 0) <> mrYes then begin
                  Cancel;
                  exit;
                end;
            finally
              Stream.Free;
            end;
          end;
          Post;
          getLayoutInterface(LayoutSession).Commit;
          showmessage('Шаблон сохранен');
        end
      end
      else raise Exception.Create('Недопустимый ID (' + VarToStr(p_ReportID) + ') отчета');
    finally
      Free;
    end;
end;

function isWorksheetRunnable(const pFullFileName: String; const pSheetName: String): Boolean;
var
  vData: Variant;
begin
  ExcelSemafor.get_cells(pFullFileName, pSheetName, 'A1', @vData);
  try
    Result := VarToStr(vData) = 'Данные для реестра';
  except
    Result := False;
  end;
end;

function TxlsWorkThread.check_worksheet: Boolean;
begin
  Result := Params.isVirtual or isWorksheetRunnable(FFullFileName, FRunnigSheetName);
end;

procedure showXLSworkSettings;
begin
  if frmXLSwork <> nil then frmXLSwork.BringToFront
  else begin
    frmXLSwork := TfrmXLSwork.Create(Application);
    frmXLSwork.btnRefreshClick(nil);
    frmXLSwork.Show;
  end;
end;

procedure TfrmXLSwork.btnRefreshClick(Sender: TObject);
var
  vBooks: TStringList;
  vPos: Longint;
  I: Longint;
begin
  inherited;
  vBooks := TStringList.Create;
  try
    tvFiles.BeginUpdate();
    vBooks.text := getXLSWorksheets([xlssoInvisible]);
    with mdFiles do begin
      Close;
      open;
      for I := 0 to vBooks.Count - 1 do begin
        vPos := AnsiPos(#9, vBooks[I]);
        if vPos <> 0 then begin
          Append;
          mdFilesFullName.AsString := Copy(vBooks[I], 0, vPos - 1);
          mdFilesName.AsString := Copy(vBooks[I], vPos + 1, 2000);
          Post;
        end;
      end;
    end;
  finally
    tvFiles.EndUpdate;
    vBooks.Free;
  end;
end;

procedure TfrmXLSwork.btnRunClick(Sender: TObject);
var
  I: Integer;
  vCRow: TcxCategoryRow;
begin
  inherited;
  if not vgParams.Enabled then exit;
  vCRow := TcxCategoryRow(vgParams.RowByCaption(stdCategoryCaptions[spkUserDefined <>
    spkUserDefined]));
  if not isWorksheetRunnable(mdFilesFullName.AsString, mdSheetsName.AsString) then exit;
  with TxlsWorkThread.Create(mdFilesFullName.AsString, False) do begin
    RunnigSheetName := mdSheetsName.AsString;
    if vCRow <> nil then
      for I := 0 to vCRow.Count - 1 do begin
        if vCRow.Rows[I] is TcxEditorRow then
          with TcxEditorRow(vCRow.Rows[I]).Properties do Params.Value[Caption] := VarToStr(Value)
      end;
    Start;
  end;
end;

procedure TfrmXLSwork.btnSaveClick(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  if not vgParams.Enabled then exit;
  if not isWorksheetRunnable(mdFilesFullName.AsString, mdSheetsName.AsString) then exit;
  with TxlsSheetParams.Create do
    try
      Load(mdFilesFullName.AsString, mdSheetsName.AsString);
      for I := 0 to Count - 1 do begin
        Items[I].Formula := VarToStr(Items[I].getVGFormulaEditRow(vgParams).Properties.Value);
      end;
      SaveFormulas(mdFilesFullName.AsString, mdSheetsName.AsString);
    finally
      Free;
    end;
end;

procedure TfrmXLSwork.FormClose(Sender: TObject;

  var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  frmXLSwork := nil;
end;

procedure TfrmXLSwork.tvFilesFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  I: Longint;
  vWB: OleVariant;
begin
  inherited;
  with mdSheets do
    try
      tvSheets.BeginUpdate();
      Close;
      if AFocusedRecord = nil then exit;
      vWB := getXLSWorkbook(VarToStr(AFocusedRecord.Values[tvFilesFullName.Index]), False);
      if not VarIsType(vWB, varDispatch) then exit;
      open;
      for I := 1 to vWB.Worksheets.Count do begin
        Append;
        mdSheetsName.AsString := VarToStr(vWB.Worksheets[I].Name);
        Post;
      end;
    finally
      tvSheets.EndUpdate;
    end;
end;

procedure TfrmXLSwork.tvFilesStylesGetContentStyle(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;

  var AStyle: TcxStyle);
var
  vWB: OleVariant;
  I: Integer;

begin
  inherited;
  vWB := getXLSWorkbook(VarToStr(ARecord.Values[tvFilesFullName.Index]), False);
  if VarIsType(vWB, varDispatch) then begin
    for I := 1 to vWB.Worksheets.Count do begin
      if isWorksheetRunnable(vWB.FullName, IntToStr(I)) then begin
        AStyle := LayoutStyles('stBold');
        exit;
      end;
    end;
  end
  else AStyle := LayoutStyles('stItalicGray');

end;

procedure TfrmXLSwork.tvSheetsFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  I: Integer;
begin
  inherited;
  vgParams.ClearRows;
  vgParams.Enabled := isWorksheetRunnable(mdFilesFullName.AsString, mdSheetsName.AsString);
  if not vgParams.Enabled then exit;
  with TxlsSheetParams.Create do
    try
      Load(mdFilesFullName.AsString, mdSheetsName.AsString);
      for I := 0 to Count - 1 do begin
        Items[I].getVGFormulaEditRow(vgParams).Properties.Value := Items[I].Formula;
      end;
    finally
      Free;
    end;
end;

procedure TfrmXLSwork.tvSheetsStylesGetContentStyle(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  inherited;
  if isWorksheetRunnable(mdFilesFullName.AsString, VarToStr(ARecord.Values[tvSheetsName.Index]))
  then AStyle := LayoutStyles('stBold');
end;

procedure TfrmXLSwork.OnEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  vQuery: TDataSet;
begin
  vQuery := stdLayoutQuery(Application);
  with getLayoutInterface(vQuery) do
    try
      SQL.text := VarToStr(TcxButtonEdit(Sender).EditingText);
      if ExecuteSQLEditor(vQuery) then TcxButtonEdit(Sender).EditingText := SQL.text;
    finally
      vQuery.Free;
    end;
end;

{ TxlsSheetParam }

constructor TxlsSheetParam.Create(const pName: String);
var
  I: Integer;
begin
  FName := UpperCase(pName);
  FValue := '';
  FFormula := '';
  I := AnsiIndexStr(FName, stdXLSParamNames);
  if I < 0 then FKind := spkUserDefined
  else FKind := TxlsSheetParamKind(I);
end;

function TxlsSheetParam.getVGFormulaEditRow(const pVG: TcxVerticalGrid): TcxEditorRow;
var
  vCRow: TcxCategoryRow;
begin
  vCRow := TcxCategoryRow(pVG.RowByCaption(stdCategoryCaptions[Kind <> spkUserDefined]));
  if vCRow = nil then begin
    vCRow := TcxCategoryRow(pVG.Add(TcxCategoryRow));
    vCRow.Properties.Caption := stdCategoryCaptions[Kind <> spkUserDefined];
  end;
  Result := TcxEditorRow(pVG.RowByCaption(Name));
  if Result = nil then begin
    Result := TcxEditorRow(pVG.AddChild(vCRow, TcxEditorRow));
    with TcxEditorRow(Result).Properties do begin
      Caption := Name;
      if Kind = spkSELECT then begin
        EditPropertiesClass := TcxButtonEditProperties;
        EditProperties.OnButtonClick := TfrmXLSwork(nil).OnEditPropertiesButtonClick;
      end
      else EditPropertiesClass := TcxTextEditProperties;
    end;
  end;
end;

function TxlsSheetParam.getVGValueEditRow(const pVG: TcxVerticalGrid): TcxEditorRow;
begin
  Result := nil;
  if Kind <> spkUserDefined then exit;
  Result := TcxEditorRow(pVG.RowByCaption(Name));
  if Result = nil then begin
    Result := TcxEditorRow(pVG.Add(TcxEditorRow));
    with TcxEditorRow(Result).Properties do begin
      Caption := Name;
      if AnsiPos('DATE', Name) <> 0 then EditPropertiesClass := TcxDateEditProperties
      else if AnsiPos('CHK', Name) <> 0 then EditPropertiesClass := TcxCheckBoxProperties
      else EditPropertiesClass := TcxTextEditProperties;
    end;
  end;
end;

procedure TxlsSheetParam.SetFormula(const Value: String);
begin
  FFormula := Value;
end;

procedure TxlsSheetParam.SetValue(const Value: String);
begin
  FValue := Value;
end;

{ TxlsSheetParams }

function TxlsSheetParams.Add(const pParamName: String): TxlsSheetParam;
var
  vNdx: Longint;
begin
  vNdx := IndexOf(pParamName);
  if vNdx = -1 then begin
    Result := TxlsSheetParam.Create(pParamName);
    inherited Add(Result);
  end
  else Result := Items[vNdx];
end;

constructor TxlsSheetParams.Create;
begin
  FisVirtual := False;
end;

constructor TxlsSheetParams.Create(const pSrcParams: TxlsSheetParams);
begin
  inherited Create;
  if pSrcParams <> nil then FisVirtual := pSrcParams.isVirtual
  else FisVirtual := False;
  if FisVirtual then Load(pSrcParams);
end;

function TxlsSheetParams.Get(Index: Integer): TxlsSheetParam;
begin
  Result := inherited Items[Index]
end;

function TxlsSheetParams.IndexOf(

  const pName: String): Integer;
var
  vName: String;
begin
  vName := UpperCase(pName);
  for Result := 0 to Count - 1 do
    if Items[Result].Name = vName then exit;
  Result := -1;
end;

procedure TxlsSheetParams.Load(const pSrcParams: TxlsSheetParams);
var
  I: Longint;
begin
  for I := 0 to pSrcParams.Count - 1 do Add(pSrcParams[I].Name).Value := pSrcParams[I].Value;
end;

procedure TxlsSheetParams.Load(const pFullFileName: String; const pSheetName: String);
var
  vWS: OleVariant;
  vParams: Variant;
  vParamName: String;
  I: Longint;
  vKind: TxlsSheetParamKind;
begin
  if isVirtual then exit;
  inherited;
  with ExcelSemafor do
    if wait_for_semafor then
      try
        vWS := getXLSWorksheet(pFullFileName, pSheetName, False);
        vParams := vWS.UsedRange.Columns['A:B'].Value;
        for I := VarArrayLowBound(vParams, 1) + 1 to VarArrayHighBound(vParams, 1) do begin
          vParamName := VarArrayGet(vParams, [I, 1]);
          if (vParamName <> '') And (IndexOf(vParamName) = -1) then
            with Add(vParamName) do begin
              Value := VarArrayGet(vParams, [I, 2]);
              Formula := vWS.UsedRange.cells[I, 2].Formula;
            end;
        end;
      finally
        clear_semafor;
      end;
  for vKind := spkSELECT to High(TxlsSheetParamKind) do
    if IndexOf(stdXLSParamNames[vKind]) = -1 then Add(stdXLSParamNames[vKind]);
end;

procedure TxlsSheetParams.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if (Action = lnDeleted) And (Ptr <> nil) then TxlsSheetParam(Ptr).Free;
end;

procedure TxlsSheetParams.Put(Index: Integer;

  const Value: TxlsSheetParam);
begin
  inherited Items[Index] := Value;
end;

procedure TxlsSheetParams.SaveFormulas(const pFullFileName: String; const pSheetName: String);
var
  vWS: OleVariant;
  vParams: Variant;
  vParamName: String;
  I: Longint;
  vParamNdx: Integer;
begin
  if isVirtual then exit;
  inherited;
  with ExcelSemafor do
    if wait_for_semafor then
      try
        vWS := getXLSWorksheet(pFullFileName, pSheetName, False);
        vParams := vWS.UsedRange.Columns[1].Value;
        for I := VarArrayLowBound(vParams, 1) + 1 to VarArrayHighBound(vParams, 1) do begin
          vParamName := VarArrayGet(vParams, [I, 1]);
          vParamNdx := IndexOf(vParamName);
          if vParamNdx <> -1 then vWS.UsedRange.cells[I, 2].Formula := Items[vParamNdx].Formula;
        end;
      finally
        clear_semafor;
      end;
end;

procedure TxlsSheetParams.SaveValues(const pFullFileName: String; const pSheetName: String);
var
  vWS: OleVariant;
  vParams: Variant;
  vParamName: String;
  I: Longint;
  vParamNdx: Integer;
begin
  if isVirtual then exit;
  inherited;
  with ExcelSemafor do
    if wait_for_semafor then
      try
        vWS := getXLSWorksheet(pFullFileName, pSheetName, False);
        vParams := vWS.UsedRange.Columns[1].Value;
        for I := VarArrayLowBound(vParams, 1) + 1 to VarArrayHighBound(vParams, 1) do begin
          vParamName := VarArrayGet(vParams, [I, 1]);
          vParamNdx := IndexOf(vParamName);
          if (vParamNdx <> -1) And (Items[vParamNdx].Kind = spkUserDefined) And
            (Items[vParamNdx].Value <> '') And
            ((Length(Items[vParamNdx].Formula) = 0) or (Items[vParamNdx].Formula[1] <> '=')) then
          begin
            vWS.UsedRange.cells[I, 2].NumberFormat := Variant('@');
            vWS.UsedRange.cells[I, 2].Value := Items[vParamNdx].Value;
          end;
        end;
      finally
        clear_semafor;
      end;

end;

procedure TxlsSheetParams.setParamValue(const pName, Value: String);
begin
  Add(pName).Value := Value;
end;

{ TxlsWorkThread }

constructor TxlsWorkThread.Create(const pFullFileName: String; const pIsVirtual: Boolean);
begin
  inherited Create(True);
  FFullFileName := pFullFileName;
  FRunnigSheetName := '';
  FreeOnTerminate := True;
  TotalSteps := 1;
  try
    LayoutSession := mainSession.clone;
  except
    LayoutSession := nil;
  end;
  FetchAllRecords := True;
  FParams := TxlsSheetParams.Create;
  FParams.isVirtual := pIsVirtual;
end;

destructor TxlsWorkThread.Destroy;
begin
  FParams.Free;
  inherited;
end;

procedure TxlsWorkThread.Execute;
begin
  try
    CoInitializeEx(nil, 2);
    if not Terminated then begin
      DoStateChanged;
      if Terminated then exit;
      if prepare_sheet then run_sheet;
      DoStateChanged;
    end;
  except
    on E: Exception do showmessage(E.Message + #13#10 + E.StackTrace);
  end;
end;

function TxlsSheetParams.getParamValue(const pName: String): String;
var
  ndx: Longint;
begin
  Result := '';
  ndx := IndexOf(pName);
  if ndx = -1 then exit;
  Result := Items[ndx].Value;
end;

function TxlsWorkThread.getStateText: String;
begin
  Result := FRunnigSheetName + ': ' + inherited getStateText;
end;

function TxlsWorkThread.prepare_sheet: Boolean;
var
  vVal: String;
  I: Longint;
begin
  Result := Params.isVirtual;
  if Result then exit;
  Result := check_worksheet;
  if not Result then exit;
  with TxlsSheetParams.Create do
    try
      Load(FFullFileName, FRunnigSheetName);
      for I := 0 to Count - 1 do begin
        vVal := Params.Value[Items[I].Name];
        if vVal <> '' then Items[I].Value := vVal;
      end;
      SaveValues(FFullFileName, FRunnigSheetName);
    finally
      Free;
    end;
end;

procedure TxlsWorkThread.run_sheet;
const
  ClearDirections: array [Boolean] of TExcelClearDirection = (ecdVert, ecdHoriz);
var
  vCell: String;
  vFldCnt, I, vTotalRows: Longint;
  vVal, vMACRO: String;
  vHoriz, vNoClear: Boolean;
  vCaptionLine: Longint;
  vLData: Variant;
  vCellsCnt: Variant;

  function set_cells(const pAddress: String; const pClearDir: TExcelClearDirection;
    const pData: Variant): Longint;
  begin
    Result := ExcelSemafor.set_cells(FFullFileName, FRunnigSheetName, pAddress, @pData,
      ifThen(vNoClear, ecdNone, pClearDir));
  end;
  procedure get_options(const pOptions: String);
  begin
    vHoriz := AnsiContainsText(pOptions, 'horiz');
    if AnsiContainsText(pOptions, 'no_cap') then vCaptionLine := 1
    else vCaptionLine := 0;
    vNoClear := AnsiContainsText(pOptions, 'no_clear');
  end;

begin
  if not check_worksheet then exit;

  with TxlsSheetParams.Create(Params) do
    try
      Load(FFullFileName, FRunnigSheetName);
      vCell := Value[stdXLSParamNames[spkCELL]];
      with Query, getLayoutInterface(Query) do begin
        SQL.text := Value[stdXLSParamNames[spkSELECT]];
        if (SQL.text <> '') And (vCell <> '') then begin
          for I := 0 to ParamCount - 1 do begin
            vVal := Value[Params[I].Name];
            with Params[I] do
              if AnsiPos('CURSOR', AnsiUpperCase(Name)) <> 0 then Datatype := ftCursor
              else begin
                Datatype := ftWideString;
                Size := 4000;
                ParamType := ptInputOutput;
                AsString := vVal;
              end;
          end;
          if not self.Params.isVirtual then begin
            // vLData := ;
            set_cells('C1', ecdNone, SQL.text);
          end;
          vLData := '';
          try
            inherited Execute;
          except
            on E: Exception do begin
              vLData := E.Message;
              // GetErrorPos(errRow, errCol);
              // vLData := E.Message + #10 + 'ErrorRow: ' + IntToStr(errRow) + '; ErrorColumn: ' +
              // IntToStr(errCol);
            end;
          end;
          if vLData <> '' then set_cells(vCell, ecdNone, vLData)
          else if Active And not Terminated then begin
            vTotalRows := RecordCount;
            vFldCnt := FieldCount;
            get_options(Value[stdXLSParamNames[spkOPTIONS]]);
            if vTotalRows >= vCaptionLine then
              try
                if vHoriz then
                    vLData := VarArrayCreate([1, vFldCnt, vCaptionLine, vTotalRows], varVariant)
                else vLData := VarArrayCreate([vCaptionLine, vTotalRows, 1, vFldCnt], varVariant);
                if vCaptionLine = 0 then
                  for I := 0 to vFldCnt - 1 do begin
                    if vHoriz then VarArrayPut(vLData, Fields[I].FieldName, [I + 1, vCaptionLine])
                    else VarArrayPut(vLData, Fields[I].FieldName, [vCaptionLine, I + 1]);
                  end;
                self.State := 'Fetching';
                while not EOF do begin
                  if Terminated then exit;
                  for I := 0 to vFldCnt - 1 do begin
                    if vHoriz then VarArrayPut(vLData, Fields[I].AsVariant, [I + 1, RecNo])
                    else VarArrayPut(vLData, Fields[I].AsVariant, [RecNo, I + 1]);
                  end;
                  Next;
                end;
                if Terminated then exit;
                Close;
                self.State := 'Excel';
                vCellsCnt := set_cells(vCell, ClearDirections[vHoriz], vLData);
                if not self.Params.isVirtual then begin
                  set_cells('F1', ecdNone, ExcelSemafor.LastOleError);
                  set_cells('E1', ecdNone, vCellsCnt);
                end;
              finally
                self.State := 'Cleanup';
                VarClear(vLData);
              end
            else begin
              ExcelSemafor.clear_cells(FFullFileName, FRunnigSheetName, vCell,
                ifThen(vHoriz, vFldCnt, -1), ifThen(vHoriz, -1, vFldCnt));
              set_cells('E1', ecdNone, 'Нет данных');
            end;
            if not self.Params.isVirtual then begin
              set_cells('D1', ecdNone, SysUtils.Now);
            end;
          end;
        end;
      end;
      vMACRO := Value[stdXLSParamNames[spkMACRO]];
      if (vMACRO <> '') And not Terminated then
        try
          State := 'MACRO';
          ExcelSemafor.call_macro(FFullFileName, vMACRO);
          State := '';
        except
          on E: Exception do showmessage(E.Message + #10 + E.ClassName);
        end;
    finally
      Free;
    end;
  // SET_CLIENT_INFO(Session, '');
end;

{ TxlsReportThread }

constructor TxlsReportThread.Create(const pReportID: Variant; const pPath: String;
  const pReportMode: TReportMode);
begin
  inherited Create('', False);
  FPath := pPath;
  if FPath = '' then FPath := mainSession.get_user_param('XLS-Reports', 'Default Reports Path');
  if FPath = '' then FPath := defaultFilePath;
  FReportMode := pReportMode;
  FReportID := pReportID;
end;

procedure TxlsReportThread.Execute;
var
  I: Integer;
  function get_sheet_name: Boolean;
  begin
    try
      FRunnigSheetName := FWorkbook.Worksheets[I].Name;
      Result := True;
    except
      FRunnigSheetName := '';
      Result := False;
    end;
  end;

begin
  try
    CoInitializeEx(nil, 2);
    if VarIsNumeric(FReportID) then
      try
        DoStateChanged;
        if prepare_workbook and (FReportMode <> rmTemplate) then begin
          if not Terminated And (VarType(FWorkbook) = varDispatch) then begin
            DoStateChanged;
            for I := 1 to TotalSteps do begin
              if Terminated then exit;
              if get_sheet_name then prepare_sheet;
            end;
            for I := 1 to TotalSteps do begin
              if Terminated then exit;
              if get_sheet_name And check_worksheet then begin
                run_sheet;
                if FReportMode = rmUser then
                  try
                    FWorkbook.Worksheets[I].Visible := 2; { xlSheetVeryHidden }
                  except
                  end;
              end;
            end;
            FWorkbook.Application.DisplayAlerts := False;
            FWorkbook.save;
            FWorkbook.Application.DisplayAlerts := True;
          end;
        end;
      finally
        if VarIsType(FWorkbook, varDispatch) then begin
          FWorkbook.Application.Visible := True;
          FWorkbook.Application.WindowState := -4137;
        end;
      end;
  except
    on E: Exception do showmessage(E.Message + #13#10 + E.StackTrace);
  end;
end;

function TxlsReportThread.prepare_workbook: Boolean;
var
  vFileName: String;
  vFileExt: String;
  vIndex: String;
  vNames: OleVariant;
  vNameItem: OleVariant;
  vSheetNdx, vNameNdx, vIndexL: Longint;
  vDS : TDataSet;

  function full_file_name: string;
  begin
    if FReportMode = rmTemplate then Result := vFileName
    else Result := FPath + vFileName + vIndex + vFileExt;
  end;
  function check_file: Boolean;
  begin
    Result := not FileExists(full_file_name);
    if Result then exit;
    if FReportMode = rmTemplate then begin
      if Confirmation('Файл ''' + full_file_name + ''' существует. Перезаписать?', mbYesNo) <>
        mrYes then exit;
    end;
    Result := DeleteFile(full_file_name);
  end;

begin
  Result := False;
  TotalSteps := 0;
  vDS := stdLayoutQuery(nil, LayoutSession);
  with vDS, getLayoutInterface(vDS) do
    try
      SQL.Add('select x.file_name, x.xls_file from ' + mainSession.Schema +
        '.v_XLS_REPORTS x where x.id=' + IntToStr(FReportID));
      open;
      if not EOF then begin
        vIndex := '';
        vIndexL := 1;
        vFileName := FieldByName('file_name').AsString;
        if FReportMode <> rmTemplate then begin
          vFileName := ExtractFileName(vFileName);
          vFileExt := ExtractFileExt(vFileName);
          SetLength(vFileName, Length(vFileName) - Length(vFileExt));
        end;
        while not check_file do begin
          if FReportMode = rmTemplate then begin
            showmessage('Файл ''' + full_file_name + ''' занят или не является допустимым.');
            exit;
          end;
          vIndex := '(' + IntToStr(vIndexL) + ')';
          vIndexL := vIndexL + 1;
        end;
        FFullFileName := full_file_name;
        TBlobField(FieldByName('xls_file')).SaveToFile(FFullFileName);
        with TExcelApplication.Create(Application) do
          try
            AsOLE.DisplayAlerts := False;
            FWorkbook := AsOLE.Workbooks.open(FFullFileName, 0);
            AsOLE.DisplayAlerts := True;
            TotalSteps := AsOLE.Worksheets.Count;
            for vSheetNdx := 1 to TotalSteps do begin
              vNames := AsOLE.Worksheets.Item[vSheetNdx].Names;
              for vNameNdx := 1 to vNames.Count do begin
                vNameItem := vNames.Item(vNameNdx);
                if AnsiPos('Print_Area', vNameItem.Name) <> 0 then
                    vNameItem.Name := 'Область_печати';
              end;
            end;
          except
            on E: Exception do begin
              AsOLE.Quit;
              Free;
              raise E;
            end;
          end;
      end;
    finally
      Free;
    end;
  Result := True;
end;

end.
