{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
unit ExportSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Forms, Dialogs, cxButtons, ExtCtrls, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxCheckBox, cxRadioGroup, cxGridExportLink, ComObj, cxGrid,
  cxGraphics, dxLayoutContainer, dxLayoutControl, cxClasses, cxGridLevel, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxDataStorage, cxTL, cxTLExportLink,
  StdCtrls, dxLayoutcxEditAdapters, cxLookAndFeelPainters, dxLayoutControlAdapters, cxLookAndFeels,
  Menus, cxGroupBox, Controls, cxMaskEdit, cxDropDownEdit;

type
  TfrmExportSettings = class(TForm)
    btnCancel: TcxButton;
    btnOK: TcxButton;
    SaveDialog: TSaveDialog;
    btnFileName: TcxButton;
    rgSaveAll: TcxRadioGroup;
    rgUseNative: TcxRadioGroup;
    chbExpand: TcxCheckBox;
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    grExcel: TdxLayoutGroup;
    dxLayoutControl1Group3: TdxLayoutGroup;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group4: TdxLayoutGroup;
    edFileName: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group6: TdxLayoutGroup;
    dxLayoutControl1Item7: TdxLayoutItem;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Item6: TdxLayoutItem;
    grMain: TdxLayoutGroup;
    rgFileFormat: TcxRadioGroup;
    dxLayoutControl1Item12: TdxLayoutItem;
    rgViewFormat: TcxRadioGroup;
    dxLayoutControl1Item1: TdxLayoutItem;
    rgNewExist: TcxRadioGroup;
    dxLayoutControl1Item9: TdxLayoutItem;
    btnSaveSettings: TcxButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    edWorksheet: TcxComboBox;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    dxLayoutControl1Group2: TdxLayoutGroup;
    edCell: TcxTextEdit;
    dxLayoutControl1Item13: TdxLayoutItem;
    dxLayoutControl1Group7: TdxLayoutGroup;
    btnDelSettings: TcxButton;
    dxLayoutControl1Item14: TdxLayoutItem;
    dxLayoutControl1Group8: TdxLayoutGroup;
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure btnFileNameClick(Sender: TObject);
    procedure rgFileFormatPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveSettingsClick(Sender: TObject);
    procedure rgNewExistPropertiesEditValueChanged(Sender: TObject);
    procedure rgViewFormatPropertiesEditValueChanged(Sender: TObject);
    procedure cbWorksheetPropertiesInitPopup(Sender: TObject);
    procedure btnDelSettingsClick(Sender: TObject);
  private
    { Private declarations }
    FControl: TcxControl;
    FCurrentView: TMemoryStream;
    FSavedView: TMemoryStream;
    function getRegKey: String;
    procedure getSettings;
    procedure reload_view(const pStream: TMemoryStream);
    function AbleFileName: string;
    function FileFormat: String;
    function isTreeList: Boolean; inline;
    function AsTreeList: TcxCustomTreeList; inline;
    function AsGrid: TcxGrid; inline;
    function AsGridView: TcxCustomGridView; inline;
    function useNative: Boolean; inline;
    function SaveAll: Boolean; inline;
    function useNewFile: Boolean; inline;
    function useCurrViewFormat: Boolean; inline;
  public
    { Public declarations }
  end;

  TspecGridTableViewExport = class(TcxGridTableViewExport)
  protected
    function GetViewItemValueEx(ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AProperties: TcxCustomEditProperties): Variant; override;
  end;

procedure ExportSettingsShow(const pControl: TcxControl; const multi_select: Boolean);

var
  frmExportSettings: TfrmExportSettings;

implementation

uses ExcelApp, LayoutData, ORALayout, Utilities;
{$R *.dfm}

function TfrmExportSettings.getRegKey: String;
var
  vForm: TfrmORALayout;
begin
  Result := '';
  vForm := TfrmORALayout(getParentByClass(FControl, TfrmORALayout));
  if (vForm = nil) or (FControl.Name = '') then exit;
  Result := 'ExportSettings\' + vForm.ORAName + '\' + FControl.Name;
end;

procedure ExportSettingsShow(const pControl: TcxControl; const multi_select: Boolean);
begin
  Application.CreateForm(TfrmExportSettings, frmExportSettings);
  with frmExportSettings do begin
    FControl := pControl;
    if isTreeList then begin
      AsTreeList.StoreToStream(FCurrentView);
      rgNewExist.Enabled := False;
    end
    else AsGridView.StoreToStream(FCurrentView, [gsoUseFilter, gsoUseSummary]);
    if multi_select then rgSaveAll.ItemIndex := 1;
    getSettings;
    rgNewExistPropertiesEditValueChanged(nil);
    if not useCurrViewFormat then rgViewFormatPropertiesEditValueChanged(nil);
    ShowModal;
  end;
end;

function TfrmExportSettings.AbleFileName: string;
var
  i: integer;
  vExportPath: string;
  vGrdName: string;
  vExt: string;
begin
  Result := edFileName.Text;
  if not useNewFile And (Result <> '') then begin
    exit;
  end;
  vExportPath := ExtractFilePath(Result);
  vGrdName := ExtractFileName(Result);
  if vExportPath = '' then vExportPath := defaultFilePath;
  if vGrdName = '' then vGrdName := FControl.Name
  else begin
    vExt := ExtractFileExt(Result);
    SetLength(vGrdName, Length(vGrdName) - Length(vExt));
    i := Length(vGrdName);
    if vGrdName[i] = ')' then begin
      repeat i := i - 1;
      until not((i > 0) And (vGrdName[i] >= '0') And (vGrdName[i] <= '9'));
      if (i > 1) And (vGrdName[i] = '(') then SetLength(vGrdName, i - 1);
    end;
  end;
  Result := vExportPath + vGrdName + '.' + FileFormat;
  if not useNewFile then exit;
  i := 0;
  while True do begin
    if not FileExists(Result) then exit;
    i := i + 1;
    Result := vExportPath + vGrdName + '(' + IntToStr(i) + ').' + FileFormat;
  end;
end;

function TfrmExportSettings.AsGrid: TcxGrid;
begin
  Result := TcxGrid(FControl);
end;

function TfrmExportSettings.AsGridView: TcxCustomGridView;
begin
  Result := TcxCustomGrid(FControl).ActiveView;
end;

function TfrmExportSettings.AsTreeList: TcxCustomTreeList;
begin
  Result := TcxCustomTreeList(FControl);
end;

procedure TfrmExportSettings.btnCancelClick(Sender: TObject);
begin
  frmExportSettings.Close;
end;

procedure TfrmExportSettings.btnDelSettingsClick(Sender: TObject);
var
  vRegKey: String;
begin
  vRegKey := getRegKey;
  if vRegKey <> '' then begin
    mainSession.clear_user_params(vRegKey);
    mainSession.Commit;
  end;
  btnDelSettings.Enabled := False;
end;

procedure TfrmExportSettings.btnFileNameClick(Sender: TObject);
begin
  if SaveDialog.Execute then edFileName.Text := SaveDialog.FileName;
end;

procedure specExportGridToFile(AFileName: string; AExportType: integer; AGrid: TcxGrid;
  AExpand, ASaveAll, AUseNativeFormat: Boolean; const ASeparator, ABeginString, AEndString: string;
  const AFileExt: string);
var
  AView: TcxCustomGridView;
  AGridExport: TcxGridCustomExport;
begin
  if AGrid <> nil then begin
    if AFileExt <> '' then AFileName := ChangeFileExt(AFileName, '.' + AFileExt);
    AView := AGrid.ActiveLevel.GridView;
    AGridExport := TspecGridTableViewExport.Create(AFileName, AExportType, AView, AGrid, nil);
    AGridExport.SaveAll := ASaveAll;
    AGridExport.expand := AExpand;
    AGridExport.UseNativeFormat := AUseNativeFormat;
    AGridExport.AddSeparators([ASeparator, ABeginString, AEndString]);
    AGrid.BeginExport;
    try
      AGrid.BeginUpdate;
      try
        try
          AGridExport.DoExport;
        finally
          AGridExport.Free;
        end;
      finally
        AGrid.EndUpdate;
      end;
    finally
      AGrid.EndExport;
    end;
  end;
end;

procedure prepare_grid_data(const pGridView: TcxCustomGridView; const pExpand: Boolean;
  const pSaveAll: Boolean; var vData: Variant);
var
  i, ii, ri: integer;
  vRecordCount: Longint;
  vItemsCount: Longint;
  vNeedDisplayValue: Boolean;

begin
  if not(pGridView is TcxCustomGridTableView) then exit;
  with TcxCustomGridTableView(pGridView) do begin
    vItemsCount := VisibleItemCount;
    if vItemsCount = 0 then exit;
    if pExpand then ViewData.expand(True);
    vRecordCount := Controller.SelectedRecordCount;
    if not pSaveAll And (vRecordCount > 0) then begin
      vData := VarArrayCreate([0, vRecordCount, 1, vItemsCount], varVariant);
      for i := 0 to vItemsCount - 1 do begin
        VarArrayPut(vData, VisibleItems[i].Caption, [0, i + 1]);
        vNeedDisplayValue := VisibleItems[i].Properties is TcxCustomDropDownEditProperties;
        for ii := 0 to vRecordCount - 1 do
          if vNeedDisplayValue then
              VarArrayPut(vData, Controller.SelectedRecords[ii].DisplayTexts[VisibleItems[i].Index],
              [ii + 1, i + 1])
          else VarArrayPut(vData, Controller.SelectedRecords[ii].Values[VisibleItems[i].Index],
              [ii + 1, i + 1]);
      end;
    end else begin
      vRecordCount := DataController.FilteredRecordCount;
      if vRecordCount > 0 then begin
        vData := VarArrayCreate([0, vRecordCount, 1, vItemsCount], varVariant);
        for i := 0 to vItemsCount - 1 do begin
          VarArrayPut(vData, VisibleItems[i].Caption, [0, i + 1]);
          vNeedDisplayValue := VisibleItems[i].Properties is TcxCustomDropDownEditProperties;
          for ii := 0 to vRecordCount - 1 do begin
            ri := DataController.FilteredRecordIndex[ii];
            if vNeedDisplayValue then
                VarArrayPut(vData, DataController.DisplayTexts[ri, VisibleItems[i].Index],
                [ii + 1, i + 1])
            else VarArrayPut(vData, DataController.Values[ri, VisibleItems[i].Index],
                [ii + 1, i + 1]);
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmExportSettings.btnOKClick(Sender: TObject);
var
  vExcel: OleVariant;
  vWB: OleVariant;
  vWS: OleVariant;
  vData: Variant;

  file_name: string;
  expand: Boolean;
begin
  file_name := edFileName.Text;
  expand := chbExpand.Checked;
  if useNewFile then begin
    vExcel := CreateOleObject('Excel.Application');
    case rgFileFormat.ItemIndex of
      0: begin
          if isTreeList then
              cxExportTLToExcel(file_name, AsTreeList, expand, SaveAll, useNative, 'xls')
          else ExportGridToExcel(file_name, AsGrid, expand, SaveAll, useNative, 'xls');
          vExcel.Visible := True;
          vExcel.Workbooks.Open(file_name);
        end;
      1: begin
          if isTreeList then
              cxExportTLToXLSX(file_name, AsTreeList, expand, SaveAll, useNative, 'xlsx')
          else ExportGridToXLSX(file_name, AsGrid, expand, SaveAll, useNative, 'xlsx');
          if VarToStr(vExcel.Version) <> '11.0' then begin
            vExcel.Visible := True;
            vExcel.Workbooks.Open(file_name);
          end
          else vExcel.Quit;
        end;
      2: begin
          if isTreeList then
              cxExportTLToText(file_name, AsTreeList, expand, SaveAll, #9, '"', '"', 'csv')
          else if AsGridView is TcxGridTableView then
              specExportGridToFile(file_name, integer($00000004), AsGrid, expand, SaveAll, True, #9,
              '"', '"', 'csv')
          else ExportGridToText(file_name, AsGrid, expand, SaveAll, #9, '"', '"', 'csv');
          vExcel.Visible := True;
          vExcel.Workbooks.OpenText(file_name, 1251, 1, 1, 1, False, True, True);
        end;
    end;
  end else begin
    vWB := getXLSWorkbook(file_name, True);
    if not VarIsType(vWB, varDispatch) then begin
      ShowMessage('Файл "' + file_name + '" не доступен');
      exit;
    end;
    vWB.Application.Visible := True;
    try
      vWS := vWB.Worksheets[edWorksheet.Text];
    except
    end;
    if not VarIsType(vWS, varDispatch) then
      try
        vWS := vWB.Worksheets.Add;
        vWS.Name := edWorksheet.Text;
      except
        if VarIsType(vWS, varDispatch) then begin
          vWS.Application.DisplayAlerts := False;
          vWS.Delete;
          vWS.Application.DisplayAlerts := True;
        end;
        ShowMessage('Лист "' + edWorksheet.Text + '" не доступен');
        exit;
      end;
    prepare_grid_data(AsGridView, expand, SaveAll, vData);
    ExcelSemafor.set_cells(file_name, edWorksheet.Text, edCell.Text, @vData, ecdVert);
  end;
  frmExportSettings.Close;
end;

procedure TfrmExportSettings.btnSaveSettingsClick(Sender: TObject);
var
  vRegKey: String;
  procedure save_value(const pcxEdit: TcxCustomEdit);
  begin
    mainSession.set_user_param(vRegKey, pcxEdit.Name, VarToStr(pcxEdit.EditValue));
  end;

begin
  vRegKey := getRegKey;
  if vRegKey = '' then exit;

  save_value(edFileName);
  save_value(rgNewExist);
  save_value(rgSaveAll);
  save_value(rgUseNative);
  save_value(rgNewExist);
  save_value(chbExpand);
  save_value(rgFileFormat);
  save_value(rgViewFormat);
  save_value(edWorksheet);
  save_value(edCell);
  if useCurrViewFormat or (FSavedView.size = 0) then begin
    FCurrentView.Position := 0;
    mainSession.set_user_bparam(vRegKey, 'ViewData', FCurrentView);
    with FSavedView do begin
      Position := 0;
      size := 0;
      CopyFrom(FCurrentView, 0);
    end;
  end;
  mainSession.set_user_param(vRegKey, 'Time', DateTimeToStr(Now));
  mainSession.Commit;
  btnDelSettings.Enabled := True;

end;

procedure TfrmExportSettings.cbWorksheetPropertiesInitPopup(Sender: TObject);
var
  vWB: OleVariant;
  i: Longint;
begin
  edWorksheet.Properties.Items.Text := '';
  vWB := getXLSWorkbook(edFileName.Text, False);
  if VarIsType(vWB, varDispatch) then
    with edWorksheet.Properties.Items do
      for i := 1 to vWB.Worksheets.count do Add(vWB.Worksheets[i].Name);
end;

function TfrmExportSettings.FileFormat: String;
begin
  if rgFileFormat.ItemIndex >= 0 then
      Result := rgFileFormat.Properties.Items[rgFileFormat.ItemIndex].Caption
  else Result := 'ERROR';
end;

procedure TfrmExportSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  reload_view(FCurrentView);
  Action := caFree;
  FCurrentView.Free;
  FSavedView.Free;
end;

procedure TfrmExportSettings.FormCreate(Sender: TObject);
begin
  FCurrentView := TMemoryStream.Create;
  FSavedView := TMemoryStream.Create;
end;

procedure TfrmExportSettings.getSettings;
var
  vRegKey: String;
  vTime: String;
  procedure get_value(const pcxEdit: TcxCustomEdit);
  begin
    pcxEdit.EditValue := mainSession.get_user_param(vRegKey, pcxEdit.Name);
  end;
  procedure get_stream;
  begin
    with FSavedView do begin
      size := 0;
      Position := 0;
      mainSession.get_user_bparam(FSavedView, vRegKey, 'ViewData');
    end;
  end;

begin
  vRegKey := getRegKey;
  if vRegKey = '' then exit;

  vTime := mainSession.get_user_param(vRegKey, 'Time');
  if vTime = '' then exit;
  btnDelSettings.Enabled := True;
  get_value(edFileName);
  get_value(rgNewExist);
  get_value(rgSaveAll);
  get_value(rgUseNative);
  get_value(rgNewExist);
  get_value(chbExpand);
  get_value(rgFileFormat);
  get_value(rgViewFormat);
  get_value(edWorksheet);
  get_value(edCell);
  get_stream;

end;

function TfrmExportSettings.isTreeList: Boolean;
begin
  Result := FControl is TcxCustomTreeList;
end;

function TfrmExportSettings.useNewFile: Boolean;
begin
  Result := rgNewExist.ItemIndex = 0;
end;

procedure TfrmExportSettings.rgFileFormatPropertiesEditValueChanged(Sender: TObject);
begin
  edFileName.Text := ChangeFileExt(edFileName.Text, '.' + FileFormat);
end;

procedure TfrmExportSettings.rgNewExistPropertiesEditValueChanged(Sender: TObject);
begin
  if useNewFile then edFileName.Text := AbleFileName();
  edWorksheet.Enabled := not useNewFile;
  edCell.Enabled := not useNewFile;
  rgFileFormat.Enabled := useNewFile;
  rgUseNative.Enabled := useNewFile;
end;

procedure TfrmExportSettings.reload_view(const pStream: TMemoryStream);
begin
  if pStream.size = 0 then exit;
  pStream.Position := 0;
  try
    if isTreeList then AsTreeList.RestoreFromStream(pStream, True, useCurrViewFormat)
    else AsGridView.RestoreFromStream(pStream, True, useCurrViewFormat,
        [gsoUseFilter, gsoUseSummary]);
  except
    on E: EReadError do ShowMessage(E.Message);
  end;
end;

procedure TfrmExportSettings.rgViewFormatPropertiesEditValueChanged(Sender: TObject);

begin
  if useCurrViewFormat then reload_view(FCurrentView)
  else reload_view(FSavedView);
end;

function TfrmExportSettings.SaveAll: Boolean;
begin
  Result := rgSaveAll.ItemIndex = 0;
end;

function TfrmExportSettings.useNative: Boolean;
begin
  Result := rgUseNative.ItemIndex = 0;
end;

function TfrmExportSettings.useCurrViewFormat: Boolean;
begin
  Result := rgViewFormat.ItemIndex = 0;
end;

{ TspecGridTableViewExport }

function TspecGridTableViewExport.GetViewItemValueEx(ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AProperties: TcxCustomEditProperties): Variant;
begin
  if AItem.DataBinding.ValueTypeClass.InheritsFrom(TcxFloatValueType) then begin
    Result := VarToStr(ARecord.Values[AItem.Index]);
    AProperties := nil;
  end
  else inherited;
end;

end.
