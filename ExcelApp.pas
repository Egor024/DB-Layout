unit ExcelApp;

interface

uses
  SysUtils, ActiveX, OleServer, Classes;

type
  IExcelApplication = interface(IDispatch)
    ['{000208D5-0000-0000-C000-000000000046}']
    procedure Quit; safecall;
  end;

  TExcelApplication = class(TOleServer)
  private
    FIntf: IExcelApplication;
    FAutoQuit: Boolean;
    function GetDefaultInterface: IExcelApplication;
    function GetAsOleVariant: OleVariant; inline;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    procedure Quit;
  public
    constructor Create(AOwner: TComponent); override;
    constructor makeLink(const AOwner: TComponent; const AIExcel: IExcelApplication);
    procedure Connect; override;
    procedure Disconnect; override;
    property DefaultInterface: IExcelApplication read GetDefaultInterface;
    property AsOLE: OleVariant read GetAsOleVariant;
    property AutoQuit: Boolean read FAutoQuit write FAutoQuit;
  end;

  TExcelClearDirection = (ecdNone, ecdHoriz, ecdVert);

  TExcelSemafor = class
  private
    FFullFileName: String;
    FRunnigName: String;
    FAddress: String;
    FData: PVariant;
    FClear: TExcelClearDirection;
    FLastOleError: String;
    procedure set_semafor;
    function get_norm_address(const pWS: OleVariant): String;
  protected
  public
    function wait_for_semafor: Boolean;
    procedure clear_semafor;
    function do_set_cells: LongInt;
    function do_get_cells: Boolean;
    function SheetAsOle: OleVariant;

    procedure clear_cells(const pFullFileName: String; const pSheet: String; const pAddress: String;
      const pRows: LongInt; const pColumns: LongInt);
    function set_cells(const pFullFileName, pSheet: String; const pAddress: String;
      const pData: PVariant; const pClear: TExcelClearDirection): LongInt;
    function get_cells(const pFullFileName: String; const pSheet: String; const pAddress: String;
      const pData: PVariant): Boolean;
    procedure call_macro(const pFullFileName: String; const pMACRO: String);

    property LastOleError: string read FLastOleError;
  end;

  TXLSScanOption = (xlssoWorksheets, xlssoInvisible);
  TXLSScanOptions = set of TXLSScanOption;

function getXLSWorksheets(const pScanOptions: TXLSScanOptions): string;
function getXLSWorkbook(const p_xls_file: String; const p_OpenFile: Boolean): OleVariant;
function getXLSWorksheet(const p_xls_file: String; const p_sheet: String; const p_OpenFile: Boolean)
  : OleVariant; overload;
function getXLSWorksheet(const pWorkbook: OleVariant; const p_sheet: String): OleVariant; overload;
procedure showExcelWindow(const pFullFileName: String);

var
  ExcelSemafor: TExcelSemafor;

implementation

uses Variants, ComObj, Forms;

type
  TThreadAccess = class(TThread);

const
  GUID_ExcelWorkbook: TGUID = (D1: $000208DA; D2: $0000; D3: $0000;
    D4: ($C0, $00, $00, $00, $00, $00, $00, $46));

var
  FWorkThread: TThread = nil;

procedure TExcelApplication.InitServerData;
const
  CServerData: TServerData = (ClassID: '{00024500-0000-0000-C000-000000000046}';
    IntfIID: '{000208D5-0000-0000-C000-000000000046}';
    EventIID: '{00024413-0000-0000-C000-000000000046}'; LicenseKey: nil; Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TExcelApplication.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    1570: if 1 = AsOLE.Workbooks.Count then Free;
    // FOnWorkbookBeforeClose(Self,
    // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
    // WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
  end;
  // case DispID of
  // -1: Exit;  // DISPID_UNKNOWN
  // 1565: if Assigned(FOnNewWorkbook) then
  // FOnNewWorkbook(Self, IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook});
  // 1558: if Assigned(FOnSheetSelectionChange) then
  // FOnSheetSelectionChange(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as ExcelRange {const ExcelRange});
  // 1559: if Assigned(FOnSheetBeforeDoubleClick) then
  // FOnSheetBeforeDoubleClick(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as ExcelRange {const ExcelRange},
  // WordBool((TVarData(Params[2]).VPointer)^) {var WordBool});
  // 1560: if Assigned(FOnSheetBeforeRightClick) then
  // FOnSheetBeforeRightClick(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as ExcelRange {const ExcelRange},
  // WordBool((TVarData(Params[2]).VPointer)^) {var WordBool});
  // 1561: if Assigned(FOnSheetActivate) then
  // FOnSheetActivate(Self, Params[0] {const IDispatch});
  // 1562: if Assigned(FOnSheetDeactivate) then
  // FOnSheetDeactivate(Self, Params[0] {const IDispatch});
  // 1563: if Assigned(FOnSheetCalculate) then
  // FOnSheetCalculate(Self, Params[0] {const IDispatch});
  // 1564: if Assigned(FOnSheetChange) then
  // FOnSheetChange(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as ExcelRange {const ExcelRange});
  // 1567: if Assigned(FOnWorkbookOpen) then
  // FOnWorkbookOpen(Self, IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook});
  // 1568: if Assigned(FOnWorkbookActivate) then
  // FOnWorkbookActivate(Self, IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook});
  // 1569: if Assigned(FOnWorkbookDeactivate) then
  // FOnWorkbookDeactivate(Self, IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook});
  // 1570: if Assigned(FOnWorkbookBeforeClose) then
  // FOnWorkbookBeforeClose(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
  // 1571: if Assigned(FOnWorkbookBeforeSave) then
  // FOnWorkbookBeforeSave(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // Params[1] {WordBool},
  // WordBool((TVarData(Params[2]).VPointer)^) {var WordBool});
  // 1572: if Assigned(FOnWorkbookBeforePrint) then
  // FOnWorkbookBeforePrint(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
  // 1573: if Assigned(FOnWorkbookNewSheet) then
  // FOnWorkbookNewSheet(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // Params[1] {const IDispatch});
  // 1574: if Assigned(FOnWorkbookAddinInstall) then
  // FOnWorkbookAddinInstall(Self, IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook});
  // 1575: if Assigned(FOnWorkbookAddinUninstall) then
  // FOnWorkbookAddinUninstall(Self, IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook});
  // 1554: if Assigned(FOnWindowResize) then
  // FOnWindowResize(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as Window {const Window});
  // 1556: if Assigned(FOnWindowActivate) then
  // FOnWindowActivate(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as Window {const Window});
  // 1557: if Assigned(FOnWindowDeactivate) then
  // FOnWindowDeactivate(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as Window {const Window});
  // 1854: if Assigned(FOnSheetFollowHyperlink) then
  // FOnSheetFollowHyperlink(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as Hyperlink {const Hyperlink});
  // 2157: if Assigned(FOnSheetPivotTableUpdate) then
  // FOnSheetPivotTableUpdate(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable});
  // 2160: if Assigned(FOnWorkbookPivotTableCloseConnection) then
  // FOnWorkbookPivotTableCloseConnection(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable});
  // 2161: if Assigned(FOnWorkbookPivotTableOpenConnection) then
  // FOnWorkbookPivotTableOpenConnection(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable});
  // 2289: if Assigned(FOnWorkbookSync) then
  // FOnWorkbookSync(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // Params[1] {MsoSyncEventType});
  // 2290: if Assigned(FOnWorkbookBeforeXmlImport) then
  // FOnWorkbookBeforeXmlImport(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as XmlMap {const XmlMap},
  // Params[2] {const WideString},
  // Params[3] {WordBool},
  // WordBool((TVarData(Params[4]).VPointer)^) {var WordBool});
  // 2291: if Assigned(FOnWorkbookAfterXmlImport) then
  // FOnWorkbookAfterXmlImport(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as XmlMap {const XmlMap},
  // Params[2] {WordBool},
  // Params[3] {XlXmlImportResult});
  // 2292: if Assigned(FOnWorkbookBeforeXmlExport) then
  // FOnWorkbookBeforeXmlExport(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as XmlMap {const XmlMap},
  // Params[2] {const WideString},
  // WordBool((TVarData(Params[3]).VPointer)^) {var WordBool});
  // 2293: if Assigned(FOnWorkbookAfterXmlExport) then
  // FOnWorkbookAfterXmlExport(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as XmlMap {const XmlMap},
  // Params[2] {const WideString},
  // Params[3] {XlXmlExportResult});
  // 2611: if Assigned(FOnWorkbookRowsetComplete) then
  // FOnWorkbookRowsetComplete(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // Params[1] {const WideString},
  // Params[2] {const WideString},
  // Params[3] {WordBool});
  // 2612: if Assigned(FOnAfterCalculate) then
  // FOnAfterCalculate(Self);
  // 2895: if Assigned(FOnSheetPivotTableAfterValueChange) then
  // FOnSheetPivotTableAfterValueChange(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable},
  // IUnknown(TVarData(Params[2]).VPointer) as ExcelRange {const ExcelRange});
  // 2896: if Assigned(FOnSheetPivotTableBeforeAllocateChanges) then
  // FOnSheetPivotTableBeforeAllocateChanges(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable},
  // Params[2] {Integer},
  // Params[3] {Integer},
  // WordBool((TVarData(Params[4]).VPointer)^) {var WordBool});
  // 2897: if Assigned(FOnSheetPivotTableBeforeCommitChanges) then
  // FOnSheetPivotTableBeforeCommitChanges(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable},
  // Params[2] {Integer},
  // Params[3] {Integer},
  // WordBool((TVarData(Params[4]).VPointer)^) {var WordBool});
  // 2898: if Assigned(FOnSheetPivotTableBeforeDiscardChanges) then
  // FOnSheetPivotTableBeforeDiscardChanges(Self,
  // Params[0] {const IDispatch},
  // IUnknown(TVarData(Params[1]).VPointer) as PivotTable {const PivotTable},
  // Params[2] {Integer},
  // Params[3] {Integer});
  // 2903: if Assigned(FOnProtectedViewWindowOpen) then
  // FOnProtectedViewWindowOpen(Self, IUnknown(TVarData(Params[0]).VPointer) as ProtectedViewWindow {const ProtectedViewWindow});
  // 2905: if Assigned(FOnProtectedViewWindowBeforeEdit) then
  // FOnProtectedViewWindowBeforeEdit(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ProtectedViewWindow {const ProtectedViewWindow},
  // WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
  // 2906: if Assigned(FOnProtectedViewWindowBeforeClose) then
  // FOnProtectedViewWindowBeforeClose(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ProtectedViewWindow {const ProtectedViewWindow},
  // Params[1] {XlProtectedViewCloseReason},
  // WordBool((TVarData(Params[2]).VPointer)^) {var WordBool});
  // 2908: if Assigned(FOnProtectedViewWindowResize) then
  // FOnProtectedViewWindowResize(Self, IUnknown(TVarData(Params[0]).VPointer) as ProtectedViewWindow {const ProtectedViewWindow});
  // 2909: if Assigned(FOnProtectedViewWindowActivate) then
  // FOnProtectedViewWindowActivate(Self, IUnknown(TVarData(Params[0]).VPointer) as ProtectedViewWindow {const ProtectedViewWindow});
  // 2910: if Assigned(FOnProtectedViewWindowDeactivate) then
  // FOnProtectedViewWindowDeactivate(Self, IUnknown(TVarData(Params[0]).VPointer) as ProtectedViewWindow {const ProtectedViewWindow});
  // 2911: if Assigned(FOnWorkbookAfterSave) then
  // FOnWorkbookAfterSave(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // Params[1] {WordBool});
  // 2912: if Assigned(FOnWorkbookNewChart) then
  // FOnWorkbookNewChart(Self,
  // IUnknown(TVarData(Params[0]).VPointer) as ExcelWorkbook {const ExcelWorkbook},
  // IUnknown(TVarData(Params[1]).VPointer) as ExcelChart {const ExcelChart});
  // end; {case DispID}
end;

constructor TExcelApplication.makeLink(const AOwner: TComponent; const AIExcel: IExcelApplication);
begin
  inherited Create(AOwner);
  if AIExcel <> nil then begin
    ConnectEvents(AIExcel);
    FIntf := AIExcel;
  end;
end;

procedure TExcelApplication.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then begin
    punk := GetServer;
    ConnectEvents(punk);
    FIntf := punk as IExcelApplication;
  end;
end;

constructor TExcelApplication.Create(AOwner: TComponent);
begin
  inherited;
  ConnectKind := ckNewInstance;
end;

procedure TExcelApplication.Disconnect;
begin
  if FIntf <> nil then begin
    if FAutoQuit then Quit()
    else DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

procedure TExcelApplication.Quit;
begin
  DefaultInterface.Quit;
end;

function TExcelApplication.GetAsOleVariant: OleVariant;
begin
  result := DefaultInterface;
end;

function TExcelApplication.GetDefaultInterface: IExcelApplication;
begin
  if FIntf = nil then Connect;
  Assert(FIntf <> nil,
    'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  result := FIntf;
end;

{
  XLS-Утилиы
}

function try_xls_ready(const pExcelApp: OleVariant): Boolean;
begin
  result := False;
  try
    result := pExcelApp.Ready;
  except
    on E: Exception do
      if (E is EOleSysError) and (EOleSysError(E).ErrorCode = HRESULT($80010001)) then;
    else
      raise;
  end;
end;

function waitXLSReady(const pExcelApp: OleVariant; const pTimeout: TDateTime = 5. / SecsPerDay;
  const pErrSource: String = ''): Boolean;
var
  vTimer: TDateTime;
begin
  vTimer := Now;
  repeat
    result := try_xls_ready(pExcelApp);
    if result then exit;
  until Now - vTimer > Abs(pTimeout);
  if not result And (pErrSource <> '') then raise Exception.Create(pErrSource + ': Excel занят');

end;

function getXLSWorksheets(const pScanOptions: TXLSScanOptions): string;
var
  iBC: IBindCtx;
  iROT: IRunningObjectTable;
  iEMon: IEnumMoniker;
  iMon: IMoniker;
  I: LongInt;
  iWB: System.IDispatch;
  vWB: OleVariant;
  vWS: OleVariant;
  function isVisible(const pWB: OleVariant): Boolean;
  begin
    result := waitXLSReady(vWB.Application, 1. / SecsPerDay);
    if not result then exit;
    result := vWB.Windows.Count <> 0;
    if not result then exit;
    result := vWB.Windows[1].Visible And vWB.Application.Visible;
  end;

begin
  OleCheck(CreateBindCtx(0, iBC));
  OleCheck(GetRunningObjectTable(0, iROT));
  OleCheck(iROT.EnumRunning(iEMon));
  OleCheck(iEMon.Reset);
  OleCheck(iEMon.next(1, iMon, @I));
  while I = 1 do begin
    iMon.BindToObject(iBC, nil, GUID_ExcelWorkbook, iWB);
    if iWB <> nil then begin
      vWB := OleVariant(iWB);
      if (xlssoInvisible in pScanOptions) or isVisible(vWB) then begin
        if xlssoWorksheets in pScanOptions then
          for I := 1 to vWB.Worksheets.Count do begin
            vWS := vWB.Worksheets[I];
            result := result + vWB.FullName + #9 + vWB.Name + #9 + vWS.Name + #10;
          end
        else result := result + vWB.FullName + #9 + vWB.Name + #10;
      end;
    end;
    OleCheck(iEMon.next(1, iMon, @I));
  end;
end;

function getXLSWorkbook(const p_xls_file: String; const p_OpenFile: Boolean): OleVariant;
var
  iBC: IBindCtx;
  iROT: IRunningObjectTable;
  iEMon: IEnumMoniker;
  iMon: IMoniker;
  I: LongInt;
  iWB: System.IDispatch;
  vName0: PWideChar;
  vName: String;
  v_xls_file: String;

begin
  result := Unassigned;
  v_xls_file := UpperCase(p_xls_file);
  OleCheck(CreateBindCtx(0, iBC));
  OleCheck(GetRunningObjectTable(0, iROT));
  OleCheck(iROT.EnumRunning(iEMon));
  OleCheck(iEMon.Reset);
  OleCheck(iEMon.next(1, iMon, @I));
  while I = 1 do begin
    iMon.GetDisplayName(iBC, nil, vName0);
    vName := UpperCase(vName0);
    if (ExtractRelativePath(ExtractFileDrive(vName), vName)
      = ExtractRelativePath(ExtractFileDrive(v_xls_file), v_xls_file)) then begin
      iMon.BindToObject(iBC, nil, GUID_ExcelWorkbook, iWB);
      if iWB <> nil then begin
        waitXLSReady(OleVariant(iWB).Application, 5. / SecsPerDay, 'getXLSWorkbook');
        if UpperCase(OleVariant(iWB).FullName) = v_xls_file then begin
          result := OleVariant(iWB);
          exit;
        end;
      end;
    end;
    OleCheck(iEMon.next(1, iMon, @I));
  end;
  if p_OpenFile then
    with TExcelApplication.Create(Application) do
      try
        AsOLE.Visible := True;
        AsOLE.DisplayAlerts := False;
        if FileExists(p_xls_file) then result := AsOLE.Workbooks.open(p_xls_file, 0)
        else begin
          result := AsOLE.Workbooks.Add;
          result.SaveAs(p_xls_file);
        end;
        AsOLE.DisplayAlerts := True;
      except
        on E: Exception do begin
          AsOLE.Quit;
          Free;
          raise E;
        end;
      end;
end;

function getXLSWorksheet(const pWorkbook: OleVariant; const p_sheet: String): OleVariant;
var
  I: LongInt;
begin
  result := Unassigned;
  if VarIsType(pWorkbook, varDispatch) then begin
    if p_sheet = '' then result := pWorkbook.Worksheets[1]
    else if TryStrToInt(p_sheet, I) And (I <= pWorkbook.Worksheets.Count) then
        result := pWorkbook.Worksheets[I]
    else result := pWorkbook.Worksheets[p_sheet];
  end;
end;

function getXLSWorksheet(const p_xls_file: String; const p_sheet: String; const p_OpenFile: Boolean)
  : OleVariant;
begin
  result := getXLSWorksheet(getXLSWorkbook(p_xls_file, p_OpenFile), p_sheet);
end;

{ TExcelWorkThread }

procedure TExcelSemafor.call_macro(const pFullFileName, pMACRO: String);
var
  vOle: OleVariant;
begin
  try
    if wait_for_semafor then begin
      vOle := getXLSWorkbook(pFullFileName, False);
      if VarIsType(vOle, varDispatch) then vOle.Application.Run(pMACRO);
      // FWorkThread.Synchronize(FWorkThread, do_call_macro);
    end;
  finally
    clear_semafor;
  end;
end;

procedure TExcelSemafor.clear_cells(const pFullFileName, pSheet, pAddress: String;
  const pRows, pColumns: Integer);
var
  vOle: OleVariant;
  vCell: OleVariant;
  vAddress: String;
  vRows, vColumns: LongInt;
begin
  try
    if wait_for_semafor then begin
      FFullFileName := pFullFileName;
      FRunnigName := pSheet;
      FAddress := pAddress;
      vOle := SheetAsOle;
      if VarIsType(vOle, varDispatch) then begin
        vAddress := get_norm_address(vOle);
        try
          vCell := vOle.Application.Range[vAddress, EmptyParam];
        except
          vCell := Unassigned;
        end;
        if VarIsType(vCell, varDispatch) then
          if vCell.Worksheet.type = -4167 then begin
            if pRows > 0 then vRows := pRows
            else begin
              vOle := vCell.Worksheet.UsedRange.Rows;
              vRows := vOle.Row + vOle.Count - 1;
            end;
            if pColumns > 0 then vColumns := pColumns
            else begin
              vOle := vCell.Worksheet.UsedRange.Columns;
              vColumns := vOle.Column + vOle.Count - 1;
            end;
            vCell.Worksheet.Range[vCell, vCell.Cells[vRows, vColumns]].ClearContents;
          end;
      end;
    end;
  finally
    clear_semafor;
  end;
end;

procedure TExcelSemafor.clear_semafor;
begin
  if FWorkThread = TThread.CurrentThread then FWorkThread := nil;
end;

function TExcelSemafor.get_cells(const pFullFileName, pSheet: String; const pAddress: String;
  const pData: PVariant): Boolean;
begin
  result := False;
  try
    if wait_for_semafor then begin
      FFullFileName := pFullFileName;
      FRunnigName := pSheet;
      FAddress := pAddress;
      FData := pData;
      // FWorkThread.Synchronize(FWorkThread, do_get_cells);
      result := do_get_cells;
    end;
  finally
    clear_semafor;
  end;
end;

function TExcelSemafor.get_norm_address(const pWS: OleVariant): String;
begin
  result := FAddress;
  if VarIsType(pWS, varDispatch) then begin
    if AnsiPos('!', FAddress) = 0 then
        result := '''[' + extractFileName(FFullFileName) + ']' + pWS.Name + '''!' + FAddress
    else if not (AnsiPos('[', FAddress) in [1, 2]) then
      if AnsiPos('''', FAddress) = 0 then
          result := '''[' + extractFileName(FFullFileName) + ']' + StringReplace(FAddress, '!',
          '''!', [rfReplaceAll])
      else result := '''[' + extractFileName(FFullFileName) + ']' + Copy(FAddress, 2, 1000)
  end;
end;

function TExcelSemafor.do_get_cells: Boolean;
var
  vWS: OleVariant;
  vAddress: String;
begin
  result := False;
  vWS := SheetAsOle;
  if VarIsType(vWS, varDispatch) then begin
    vAddress := get_norm_address(vWS);
    try
      FData^ := vWS.Application.Range[vAddress, EmptyParam].Value;
      result := True;
    except
      on E: Exception do FData^ := E.Message;
    end;
  end
  else
end;

function TExcelSemafor.do_set_cells: LongInt;
var
  vOle: OleVariant;
  vCell: OleVariant;
  vForClear: LongInt;
  vAddress: String;
  vDataSize1, vDataSize2: LongInt;
begin
  result := -1;
  FLastOleError := '';
  vOle := SheetAsOle;
  if VarIsType(vOle, varDispatch) then begin
    result := -2;
    vAddress := get_norm_address(vOle);
    try
      vOle := vOle.Application;
      result := -3;
      vCell := vOle.Range[vAddress, EmptyParam];
      result := -4;
    except
      on E: Exception do begin
        FLastOleError := E.ToString + sLineBreak + 'norm:' + vAddress + sLineBreak + 'real:'
          + FAddress;
        vCell := Unassigned;
      end;
    end;
    if VarIsType(vCell, varDispatch) then begin
      result := -5;
      if vCell.Worksheet.type = -4167 then begin
        if VarIsArray(FData^) then begin
          vDataSize1 := VarArrayHighBound(FData^, 1) - VarArrayLowBound(FData^, 1) + 1;
          vDataSize2 := VarArrayHighBound(FData^, 2) - VarArrayLowBound(FData^, 2) + 1;
          if (vDataSize1 * vDataSize2 > 1) And (FClear <> ecdNone) then
              vCell.Worksheet.AutoFilterMode := False;
          result := vDataSize1 * vDataSize2;
          if result <> 0 then
              vCell.Worksheet.Range[vCell, vCell.Cells[vDataSize1, vDataSize2]].Value := FData^;
          case FClear of
            ecdHoriz: begin
                vOle := vCell.Worksheet.UsedRange.Columns;
                vForClear := vOle.Column + vOle.Count - 1 - (vCell.Column + vDataSize2);
                if vForClear >= 0 then
                    vCell.Worksheet.Range[vCell.Cells[1, vDataSize2 + 1],
                    vCell.Cells[vDataSize1, vDataSize2 + 1 + vForClear]].ClearContents;
              end;
            ecdVert: begin
                vOle := vCell.Worksheet.UsedRange.Rows;
                vForClear := vOle.Row + vOle.Count - 1 - (vCell.Row + vDataSize1);
                if vForClear >= 0 then
                    vCell.Worksheet.Range[vCell.Cells[vDataSize1 + 1, 1],
                    vCell.Cells[vDataSize1 + 1 + vForClear, vDataSize2]].ClearContents;
              end;
          end;
        end else begin
          vCell.Value := OleVariant(FData^);
          result := 1;
        end;
      end;
    end;
  end;
end;

function TExcelSemafor.set_cells(const pFullFileName, pSheet: String; const pAddress: String;
  const pData: PVariant; const pClear: TExcelClearDirection): LongInt;
begin
  result := -1;
  try
    if wait_for_semafor then begin
      FFullFileName := pFullFileName;
      FRunnigName := pSheet;
      FAddress := pAddress;
      FData := pData;
      FClear := pClear;
      // FWorkThread.Synchronize(FWorkThread, do_set_cells);
      result := do_set_cells;
    end;
  finally
    clear_semafor;
  end;
end;

procedure TExcelSemafor.set_semafor;
begin
  if FWorkThread = nil then FWorkThread := TThread(self)
end;

function TExcelSemafor.SheetAsOle: OleVariant;
begin
  result := getXLSWorkbook(FFullFileName, False);
  if not VarIsType(result, varDispatch) then exit;
  result := getXLSWorksheet(result, FRunnigName);
end;

function TExcelSemafor.wait_for_semafor: Boolean;
begin
  if FWorkThread = TThread.CurrentThread then
      raise Exception.Create('Зациклевание ожидание XLS-семафора');
  while FWorkThread <> TThread.CurrentThread do
    with TThreadAccess(TThread.CurrentThread) do begin
      if Terminated then break;
      if ThreadID = MainThreadID then begin
        // CheckSynchronize;
        TExcelSemafor(TThread.CurrentThread).set_semafor;
      end
      else Synchronize(TExcelSemafor(TThread.CurrentThread).set_semafor);
    end;
  result := FWorkThread = TThread.CurrentThread;
end;

procedure showExcelWindow(const pFullFileName: String);
var
  vWB: OleVariant;
  vApp: OleVariant;
begin
  vWB := getXLSWorkbook(pFullFileName, False);
  if VarIsType(vWB, varDispatch) then begin
    vApp := vWB.Application;
    vApp.Visible := True;
    vApp.WindowState := -4137;
  end;
end;

initialization

ExcelSemafor := TExcelSemafor.Create();

finalization

FreeAndNil(ExcelSemafor);

end.
