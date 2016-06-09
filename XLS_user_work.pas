unit XLS_user_work;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, layoutForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, DB, cxDBData,
  dxLayoutContainer, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, dxmdaset,
  cxGridLevel, cxClasses, cxGridCustomView, cxGrid, dxLayoutControl, dxLayoutControlAdapters, Menus,
  StdCtrls, cxButtons, cxInplaceContainer, cxVGrid, dxLayoutcxEditAdapters, cxContainer, cxCheckBox;

type
  TfrmXLSUserWork = class(TfrmLayout)
    tvSheets: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    dxLayoutControl1Item1: TdxLayoutItem;
    dsSheets: TDataSource;
    mdSheets: TdxMemData;
    mdSheetsName: TStringField;
    mdSheetsFullName: TStringField;
    mdSheetsSheet: TStringField;
    tvSheetsName: TcxGridDBColumn;
    tvSheetsSheet: TcxGridDBColumn;
    btnRefresh: TcxButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    vgParams: TcxVerticalGrid;
    dxLayoutControl1Item3: TdxLayoutItem;
    tvSheetsFullName: TcxGridDBColumn;
    btnExecute: TcxButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    procedure btnRefreshClick(Sender: TObject);
    procedure tvSheetsSelectionChanged(Sender: TcxCustomGridTableView);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExecuteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure showXLSUserWork;

implementation

uses ExcelApp, XLS_work;
{$R *.dfm}

var
  frmXLSUserWork: TfrmXLSUserWork;

procedure showXLSUserWork;
begin
  if frmXLSUserWork <> nil then frmXLSUserWork.BringToFront
  else begin
    frmXLSUserWork := TfrmXLSUserWork.Create(Application);
    try
      frmXLSUserWork.btnRefreshClick(nil);
      frmXLSUserWork.Show;
    except
      frmXLSUserWork.Free;
      frmXLSUserWork := nil;
    end;
  end;
end;

procedure TfrmXLSUserWork.btnExecuteClick(Sender: TObject);
var
  I, II: Integer;
  vFullName: String;
  vList: TList;
begin
  inherited;
  vList := TList.Create;
  try
    with tvSheets.Controller do
      for I := 0 to SelectedRecordCount - 1 do
        with SelectedRecords[I] do begin
          vFullName := VarToStr(Values[tvSheetsFullName.Index]);
          if isWorksheetRunnable(vFullName, VarToStr(Values[tvSheetsSheet.Index])) then begin
            vList.Add(TxlsWorkThread.Create(vFullName, False));
            Application.MainForm.Repaint;
            with TxlsWorkThread(vList.Items[vList.Count - 1]) do begin
              Priority := tpLower;
              RunnigSheetName := VarToStr(Values[tvSheetsSheet.Index]);
              for II := 0 to vgParams.Rows.Count - 1 do begin
                if vgParams.Rows[II] is TcxEditorRow then
                  with TcxEditorRow(vgParams.Rows[II]).Properties do
                      Params.Value[Caption] := VarToStr(Value)
              end;
            end;
          end;
        end;
    for I := 0 to vList.Count - 1 do TxlsWorkThread(vList.Items[I]).Start;
  finally
    vList.Free;
  end;
end;

procedure TfrmXLSUserWork.btnRefreshClick(Sender: TObject);
var
  vBooks: TStringList;
  vPos: Longint;
  II, I: Longint;
  vWB: OleVariant;
  vFullName: String;
begin
  inherited;
  vBooks := TStringList.Create;
  try
    tvSheets.BeginUpdate();
    vBooks.Text := getXLSWorksheets([]);
    with mdSheets do begin
      Close;
      Open;
      for I := 0 to vBooks.Count - 1 do begin
        vPos := AnsiPos(#9, vBooks[I]);
        if vPos <> 0 then begin
          vFullName := Copy(vBooks[I], 0, vPos - 1);
          vWB := getXLSWorkbook(vFullName, False);
          if VarIsType(vWB, varDispatch) then begin
            for II := 1 to vWB.Worksheets.Count do begin
              if isWorksheetRunnable(vFullName, vWB.Worksheets[II].Name) then begin
                Append;
                mdSheetsFullName.AsString := vFullName;
                mdSheetsName.AsString := Copy(vBooks[I], vPos + 1, 2000);
                mdSheetsSheet.AsVariant := vWB.Worksheets[II].Name;
                Post;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    tvSheets.EndUpdate;
    vBooks.Free;
  end;
end;

procedure TfrmXLSUserWork.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
  frmXLSUserWork := nil;
end;

procedure TfrmXLSUserWork.tvSheetsSelectionChanged(Sender: TcxCustomGridTableView);
var
  I: Integer;
begin
  inherited;
  vgParams.ClearRows;
  with tvSheets.Controller do
    with TxlsSheetParams.Create do
      try
        for I := 0 to SelectedRecordCount - 1 do
          with SelectedRecords[I] do begin
            if isWorksheetRunnable(VarToStr(Values[tvSheetsFullName.Index]),
              VarToStr(Values[tvSheetsSheet.Index])) then
                Load(VarToStr(Values[tvSheetsFullName.Index]),
                VarToStr(Values[tvSheetsSheet.Index]));
          end;
        for I := 0 to Count - 1 do begin
          with Items[I] do
            if Kind = spkUserDefined then getVGValueEditRow(vgParams).Properties.Value := Value;
        end;
      finally
        Free;
      end;
end;

end.
