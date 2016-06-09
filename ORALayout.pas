unit ORALayout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, layoutForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxLayoutContainer, cxStyles, ImgList, DB, dxLayoutControl, cxCheckBox, dxBar, cxBarEditItem,
  cxClasses, cxContainer, cxEdit, cxTextEdit, dxLayoutcxEditAdapters, ORALayoutCustomize, Menus,
  StdCtrls, cxButtons, cxMemo, ExtCtrls, JvComponentBase, JvCaptionButton;

type
  TfrmORALayout = class(TfrmLayout)
    dxBarManager1: TdxBarManager;
    barXMLMenu: TdxBar;
    dxBarSubItem1: TdxBarSubItem;
    btnOpen: TdxBarButton;
    btnSave: TdxBarButton;
    btnNew: TdxBarButton;
    btnClose: TdxBarButton;
    cbEditMode: TcxBarEditItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    bgCustomize: TdxBarGroup;
    btnSaveAs: TdxBarButton;
    teName: TcxBarEditItem;
    teCode: TcxBarEditItem;
    btnNotes: TdxBarButton;
    pnlNotes: TPanel;
    memNotes: TcxMemo;
    btnNotesSave: TcxButton;
    JvCaptionButtonHelp: TJvCaptionButton;
    JvCaptionButtonClone: TJvCaptionButton;
    btnCaptions: TcxButton;
    procedure cbEditModePropertiesEditValueChanged(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure dxLayoutControl1Customization(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveAsClick(Sender: TObject);
    procedure dxLayoutControl1GetItemStoredProperties(Sender: TdxCustomLayoutControl;
      AItem: TdxCustomLayoutItem; AProperties: TStrings);
    procedure dxLayoutControl1GetItemStoredPropertyValue(Sender: TdxCustomLayoutControl;
      AItem: TdxCustomLayoutItem; const AName: string; var aValue: Variant);
    procedure dxLayoutControl1SetItemStoredPropertyValue(Sender: TdxCustomLayoutControl;
      AItem: TdxCustomLayoutItem; const AName: string; const aValue: Variant);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure teCodePropertiesChange(Sender: TObject);
    procedure teNamePropertiesChange(Sender: TObject);
    procedure btnNotesClick(Sender: TObject);
    procedure btnNotesSaveClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure JvCaptionButtonCloneClick(Sender: TObject);
    procedure btnCaptionsClick(Sender: TObject);
  private
    FController: TComponent;

    function getDeveloperMode: Boolean;
    procedure setDeveloperMode(const Value: Boolean);

    function getOraName: String;
    function getController: TORALayoutController; inline;
    { Private declarations }
  public
    { Public declarations }
    procedure AfterConstruction; override;
    destructor Destroy; override;
    property Controller: TORALayoutController read getController;
    property DeveloperMode: Boolean read getDeveloperMode write setDeveloperMode;
    property ORAName: String read getOraName;
  published
    property ModalResult;
  end;

  THostInterface = record
    MainBarManager: TdxBarManager;
    LayoutImages: TCustomImageList;
    LayoutStyleRepository: TcxStyleRepository;

    preLayoutButtonClick: procedure(const pORALayout: IORALayoutInterface);
    afterLayoutButtonClick: procedure(const pORALayout: IORALayoutInterface;
      const pClickQuery: TDataSet);

    // pScanOptions : TXLSScanOption = (xlssoWorksheets, xlssoInvisible);
    getXLSWorksheets: function(const pScanOptions: Byte): string;

  end;

var
  HostInterface: THostInterface = ();

implementation

uses LayoutData, StrUtils, cxStorage, ORALayoutCaptioner;

{$R *.dfm}

{ TfrmXMLLayout }

procedure TfrmORALayout.cbEditModePropertiesEditValueChanged(Sender: TObject);
begin
  inherited;
  Controller.Customization := cbEditMode.EditValue;
  if cbEditMode.EditValue then begin
    bgCustomize.Visible := ivAlways;
  end else begin
    bgCustomize.Visible := ivNever;
  end;
end;

destructor TfrmORALayout.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TfrmORALayout.btnOpenClick(Sender: TObject);
var
  vFStream: TFileStream;
begin
  if not Controller.ClearLayout then exit;

  if not OpenDialog1.Execute then exit;
  if OpenDialog1.Files.Count <> 1 then exit;

  vFStream := TFileStream.Create(OpenDialog1.Files[0], fmOpenRead);
  try
    Controller.RestoreFromStream(vFStream);
  finally
    vFStream.Free;
  end;
  Controller.initControls;
end;

procedure TfrmORALayout.btnSaveAsClick(Sender: TObject);
var
  vFStream: TFileStream;
  v_dest: String;
begin
  if not SaveDialog1.Execute then exit;
  if SaveDialog1.Files.Count <> 1 then exit;
  v_dest := SaveDialog1.Files[0];
  if AnsiUpperCase(RightStr(v_dest, 4)) <> '.FRM' then v_dest := v_dest + '.frm';
  vFStream := TFileStream.Create(v_dest, fmCreate);
  try
    Controller.StoreToStream(vFStream);
  finally
    vFStream.Free;
  end;
end;

procedure TfrmORALayout.btnSaveClick(Sender: TObject);
begin
  inherited;
  mainSession.saveORAForm(self);
end;

procedure TfrmORALayout.AfterConstruction;
begin
  inherited;
  FController := TORALayoutController.Create(self);
end;

procedure TfrmORALayout.btnCaptionsClick(Sender: TObject);
begin
  inherited;
  editCaptions(self);
end;

procedure TfrmORALayout.btnCloseClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmORALayout.btnNewClick(Sender: TObject);
begin
  inherited;
  Controller.ClearLayout;
end;

procedure TfrmORALayout.btnNotesClick(Sender: TObject);
begin
  inherited;
  if memNotes.Lines.Text = '' then
      memNotes.Lines.Text := mainSession.get_ORAForm_notes(teName.EditValue);
  pnlNotes.Visible := not pnlNotes.Visible;
  if pnlNotes.Visible then begin
    pnlNotes.ManualFloat(pnlNotes.ClientRect);
    if screen.ActiveForm <> self then dxLayoutControl1.SetFocus;
  end;
end;

procedure TfrmORALayout.btnNotesSaveClick(Sender: TObject);
begin
  inherited;
  mainSession.set_ORAForm_notes(teName.EditValue, memNotes.Lines.Text);
end;

procedure TfrmORALayout.dxLayoutControl1Customization(Sender: TObject);
var
  v: Boolean;
begin
  inherited;
  v := (dxLayoutControl1.Container <> nil) And (dxLayoutControl1.Customization);
  if cbEditMode.EditValue <> v then begin
    cbEditMode.EditValue := v;
    cbEditModePropertiesEditValueChanged(Sender);
  end;
end;

procedure TfrmORALayout.dxLayoutControl1GetItemStoredProperties(Sender: TdxCustomLayoutControl;
  AItem: TdxCustomLayoutItem; AProperties: TStrings);
begin
  inherited;
  if AItem is TdxLayoutGroup then begin
    AProperties.Add('TabCaptionRotate');
    AProperties.Add('TabCaptionAlignment');
    AProperties.Add('TabCaptionPosition');
  end;
end;

procedure TfrmORALayout.dxLayoutControl1GetItemStoredPropertyValue(Sender: TdxCustomLayoutControl;
  AItem: TdxCustomLayoutItem; const AName: string; var aValue: Variant);
begin
  inherited;
  if AItem is TdxLayoutGroup then
    with TdxLayoutGroup(AItem).TabbedOptions do begin
      if AName = 'TabCaptionRotate' then aValue := Rotate
      else if AName = 'TabCaptionAlignment' then aValue := Variant(TabCaptionAlignment)
      else if AName = 'TabCaptionPosition' then aValue := Variant(TabPosition)
    end;
end;

procedure TfrmORALayout.dxLayoutControl1SetItemStoredPropertyValue(Sender: TdxCustomLayoutControl;
  AItem: TdxCustomLayoutItem; const AName: string; const aValue: Variant);
begin
  inherited;
  if AItem is TdxLayoutGroup then
    with TdxLayoutGroup(AItem).TabbedOptions do begin
      if AName = 'TabCaptionRotate' then Rotate := aValue
      else if AName = 'TabCaptionAlignment' then TabCaptionAlignment := aValue
      else if AName = 'TabCaptionPosition' then TabPosition := aValue
    end;
end;

procedure TfrmORALayout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Controller.DoCloseQuery;
end;

procedure TfrmORALayout.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  with Controller do CanClose := not barXMLMenu.Visible Or chkLayoutModified;
end;

procedure TfrmORALayout.FormDeactivate(Sender: TObject);
begin
  inherited;
  if not Active then
    with pnlNotes do begin
      if Floating then TCustomDockForm(HostDockSite).Close;
      if Visible then Visible := False;
    end;
end;

function TfrmORALayout.getController: TORALayoutController;
begin
  Result := TORALayoutController(FController);
end;

function TfrmORALayout.getDeveloperMode: Boolean;
begin
  Result := barXMLMenu.Visible;
end;

function TfrmORALayout.getOraName: String;
begin
  Result := teName.EditValue
end;

procedure TfrmORALayout.JvCaptionButtonCloneClick(Sender: TObject);
var
  frm: TfrmORALayout;
begin
  inherited;
  frm := showORAForm(teName.EditValue, teCode.EditValue);
  if frm <> nil then frm.Controller.initControls(Controller);
end;

procedure TfrmORALayout.setDeveloperMode(const Value: Boolean);
var
  vStateSave: TORAControllerStates;
begin
  vStateSave := Controller.State;
  barXMLMenu.Visible := Value;
  Controller.State := vStateSave;
end;

procedure TfrmORALayout.teCodePropertiesChange(Sender: TObject);
begin
  inherited;
  teCode.EditValue := TcxTextEdit(Sender).EditingValue;
end;

procedure TfrmORALayout.teNamePropertiesChange(Sender: TObject);
begin
  inherited;
  teName.EditValue := TcxTextEdit(Sender).EditingValue;
end;

end.
