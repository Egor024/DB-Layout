unit CalcTool;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxControls, cxContainer, cxEdit, cxLabel, cxGridDBTableView, Menus,
  cxLookAndFeelPainters, StdCtrls, cxButtons, cxRadioGroup, ExtCtrls,
  cxGroupBox,
  cxGrid, cxGridCustomTableView, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalc,
  cxCurrencyEdit, cxGraphics, cxLookAndFeels;

type
  TfrmCalcTool = class(TForm)
    Panel1: TPanel;
    rgFuntions: TcxRadioGroup;
    rbtAverage: TcxRadioButton;
    rbtRowCount: TcxRadioButton;
    rbtSumm: TcxRadioButton;
    cxCurrencyEdit1: TcxCurrencyEdit;
    Panel2: TPanel;
    cxButton1: TcxButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rbtRowCountClick(Sender: TObject);
    procedure rbtAverageClick(Sender: TObject);
    procedure rbtSummClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cxCurrencyEdit1FocusChanged(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
  private
    PreviosOnSelectionChanged: TcxGridCustomTableViewEvent;
    FView: TcxCustomGridTableView;
    function GridSumm(A_TV: TcxCustomGridTableView): double;
    function GridAverange(A_TV: TcxCustomGridTableView): double;
    function GridRowCount(A_TV: TcxCustomGridTableView): integer;
    procedure set_position(aSender: TcxCustomGridTableView);
    { Private declarations }
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure OnSelectionChanged(Sender: TcxCustomGridTableView);
    procedure OnButtonClick(Sender: TObject; AButtonIndex: integer);

  public
    FText: string;
    Constructor Create(AOwner: TComponent); override;
    { Public declarations }
  end;

procedure CalcToolShow(tv: TcxCustomGridTableView);

implementation

uses cxGridCustomView, cxCustomData;

{$R *.dfm}

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
      for i := 0 to ComponentCount - 1 do
        if Components[i] is TWinControl then begin
          Result := getChildByClass(TWinControl(Components[i]), pClass);
          if Result <> nil then exit;
        end;
  end;
  Result := nil;
end;

procedure CalcToolShow(tv: TcxCustomGridTableView);
var
  vFrm: TCustomForm;
begin
  if Assigned(Pointer(@tv.OnSelectionChanged)) and
    (Pointer(@tv.OnSelectionChanged) = Pointer(@TfrmCalcTool.OnSelectionChanged)) then
  begin
    vFrm := TCustomForm(getChildByClass(tv, TfrmCalcTool));
    if vFrm <> nil then
      vFrm.Close;
    exit;
  end;
  with TfrmCalcTool.Create(tv) do
    try
      cxCurrencyEdit1.Properties.Buttons.Add;
      cxCurrencyEdit1.Properties.OnButtonClick := OnButtonClick;
      set_position(tv);
      Show;
      cxButton1.SetFocus;
      vFrm := getParentForm(tv.Site);
      if vFrm <> nil then
        vFrm.BringToFront;
    except
      Free;
      raise;
    end;
end;

constructor TfrmCalcTool.Create(AOwner: TComponent);
begin
  if AOwner is TcxCustomGridTableView then
  begin
    inherited;
    FView := AOwner as TcxCustomGridTableView;
    PreviosOnSelectionChanged := FView.OnSelectionChanged;
    FView.OnSelectionChanged := OnSelectionChanged;
    FView.FreeNotification(Self);
    try
      cxCurrencyEdit1.Value := GridSumm(FView)
    Except
    end;
  end
  else
    Raise Exception.Create('Не верный тип Owner');
end;

procedure TfrmCalcTool.cxButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmCalcTool.cxCurrencyEdit1FocusChanged(Sender: TObject);
begin
  cxCurrencyEdit1.EditingText := VarTostr(cxCurrencyEdit1.EditValue);
end;

procedure TfrmCalcTool.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FView.OnSelectionChanged := PreviosOnSelectionChanged;
  Action := caFree;
end;

procedure TfrmCalcTool.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_f1 then
    if HtmlHelp(Handle, 'mk:@MSITStore:C:\DELPHI\HelpPower.chm::/CalcTool.htm', 0, 0) = 0 then
      MessageDlg('Не удалось открыть файл справки.', mtError, [mbOK], 0);
  if (Shift = [ssAlt]) and (Key = Ord('C')) then
    Close;
end;

function TfrmCalcTool.GridAverange(A_TV: TcxCustomGridTableView): double;
var
  i, i_row, col_index: integer;
  d: double;
  ARowIndex: integer;
  ARowInfo: TcxRowInfo;
begin
  i_row := 0;
  col_index := A_TV.Controller.FocusedItem.Index;
  with A_TV.DataController do
  begin
    d := 0;
    for i := 0 to GetSelectedCount - 1 do
    begin
      ARowIndex := GetSelectedRowIndex(i);
      ARowInfo := GetRowInfo(ARowIndex);
      if ARowInfo.Level < Groups.GroupingItemCount then
        Continue
      else
      begin
        if Values[ARowInfo.RecordIndex, col_index] <> null then
        // если значение ячейки не null, тогда
        begin
          d := d + StrToFloat(Values[ARowInfo.RecordIndex, col_index]);
          inc(i_row);
        end; // if Values[ARowInfo.RecordIndex, col_index] <> null..
      end; // else..
    end; // for i := 0 to GetSelectedCount..
  end; // with A_TV.DataController..
  Result := d / i_row;
end;

function TfrmCalcTool.GridRowCount(A_TV: TcxCustomGridTableView): integer;
begin
  Result := A_TV.DataController.GetSelectedCount;
end;

function TfrmCalcTool.GridSumm(A_TV: TcxCustomGridTableView): double;
var
  i, col_index: integer;
  d: double;
  ARowIndex: integer;
  ARowInfo: TcxRowInfo;
begin
  col_index := A_TV.Controller.FocusedItem.Index;
  with A_TV.DataController do
  begin
    d := 0;
    for i := 0 to GetSelectedCount - 1 do
    begin
      ARowIndex := GetSelectedRowIndex(i);
      ARowInfo := GetRowInfo(ARowIndex);
      if ARowInfo.Level < Groups.GroupingItemCount then
        Continue
      else if Values[ARowInfo.RecordIndex, col_index] <> null then
        d := d + StrToFloat(Values[ARowInfo.RecordIndex, col_index]);
    end;
  end;
  Result := d;
end;

procedure TfrmCalcTool.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) then
  begin
    if (AComponent = FView) then
    begin
      Free;
    end;
  end;
end;

procedure TfrmCalcTool.OnButtonClick(Sender: TObject; AButtonIndex: integer);
begin
  if rgFuntions.Visible then
  begin
    rgFuntions.Visible := False;
    ClientHeight := cxCurrencyEdit1.Height;
  end
  else
  begin
    rgFuntions.Visible := True;
    ClientHeight := 99;
  end;
end;

procedure TfrmCalcTool.OnSelectionChanged(Sender: TcxCustomGridTableView);
begin
  if Assigned(PreviosOnSelectionChanged) then
    PreviosOnSelectionChanged(Sender);
  set_position(Sender);

  if rbtSumm.Checked then
    try
      cxCurrencyEdit1.Value := GridSumm(Sender)
    Except
    end;
  if rbtAverage.Checked then
    try
      cxCurrencyEdit1.Value := GridAverange(Sender);
    Except
    end;
  if rbtRowCount.Checked then
    try
      cxCurrencyEdit1.Value := GridRowCount(Sender)
    Except
    end;
end;

procedure TfrmCalcTool.rbtAverageClick(Sender: TObject);
begin
  try
    cxCurrencyEdit1.Value := GridAverange(FView)
  Except
  end;
end;

procedure TfrmCalcTool.rbtRowCountClick(Sender: TObject);
begin
  try
    cxCurrencyEdit1.Value := GridRowCount(FView)
  Except
  end;
end;

procedure TfrmCalcTool.rbtSummClick(Sender: TObject);
begin
  try
    cxCurrencyEdit1.Value := GridSumm(FView)
  Except
  end;
end;

procedure TfrmCalcTool.set_position(aSender: TcxCustomGridTableView);
begin
  if (aSender.Controller.FocusedRecord <> nil) And (aSender.Controller.FocusedItem <> nil) and
    (aSender.Controller.FocusedRecord.ViewInfo <> nil) then
    with aSender.Controller.FocusedRecord.ViewInfo.GetBoundsForItem(aSender.Controller.FocusedItem),
      aSender.Site.ClientToScreen(BottomRight) do
    begin
      Self.Top := Y;
      Self.left := X;
      Self.Caption := aSender.Controller.FocusedItem.Caption;
    end;
end;

end.
