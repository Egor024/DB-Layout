unit OraImageListEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  cxImageListEditor, cxImageListEditorView, Dialogs, ActnList, ExtDlgs, ImgList, cxGraphics, Menus,
  ComCtrls, ToolWin, ExtCtrls, StdCtrls;

type
  TORAImageListEditor = class(TcxImageListEditor)
  protected
    function GetEditorFormClass: TcxCustomImageListEditorFormClass; override;
  public
    function Edit(AImageList: TcxImagelist): Boolean;
    procedure ExportToFile(const AFileName: string);
    procedure ImportFromFile(const AFileName: string);
  end;

  TfrmOraImageListEditor = class(TcxImageListEditorForm)
    ExportALL: TMenuItem;
    actExportALL: TAction;
    tbbSaveToOra: TToolButton;
    ToolButton2: TToolButton;
    tbbRestoreFromOra: TToolButton;
    procedure actExportALLExecute(Sender: TObject);
    procedure tbbImportClick(Sender: TObject);
    procedure tbbSaveToOraClick(Sender: TObject);
    procedure tbbRestoreFromOraClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses LayoutData;
{$R *.dfm}
{ TORAImageListEditor }

function TORAImageListEditor.Edit(AImageList: TcxImagelist): Boolean;
begin
  ImageList := AImageList;
//  FEditorForm.Caption := '';
  FEditorForm.ShowModal;
  Result := ImageListModified;
end;

procedure TORAImageListEditor.ExportToFile(const AFileName: string);
begin
  with TFileStream.Create(AFileName, fmCreate) do
    try
      WriteComponent(ImageList);
    finally
      Free;
    end;
end;

function TORAImageListEditor.GetEditorFormClass: TcxCustomImageListEditorFormClass;
begin
  Result := TfrmOraImageListEditor;
end;

procedure TORAImageListEditor.ImportFromFile(const AFileName: string);
begin
  ClearImages;
  with TFileStream.Create(AFileName, fmOpenRead) do
    try
      ReadComponent(ImageList);
      SynchronizeData(0, ImageList.Count);
    finally
      Free;
    end;
end;

procedure TfrmOraImageListEditor.actExportALLExecute(Sender: TObject);
begin
  spdSave.DefaultExt := '*.cxli';
  spdSave.Filter := 'TcxImageList (*.cxli)|*.cxli';
  if spdSave.Execute then TORAImageListEditor(FImageListEditor).ExportToFile(spdSave.FileName);
end;

procedure TfrmOraImageListEditor.tbbImportClick(Sender: TObject);
begin
  opdOpen.DefaultExt := '*.cxli';
  opdOpen.Filter := 'TcxImageList (*.cxli)|*.cxli';
  if opdOpen.Execute then TORAImageListEditor(FImageListEditor).ImportFromFile(opdOpen.FileName);
end;

procedure TfrmOraImageListEditor.tbbRestoreFromOraClick(Sender: TObject);
begin
  if MessageDlg('ѕодтвердите восстановление иконок из базы данных', mtConfirmation, mbYesNo, 0) <>
    mrYes then exit;

  with FImageListEditor do begin
    ClearImages;
    mainSession.loadORAImageList(0, ImageList);
    SynchronizeData(0, ImageList.Count);
  end;
end;

procedure TfrmOraImageListEditor.tbbSaveToOraClick(Sender: TObject);
begin
  if MessageDlg('ѕодтвердите сохранение иконок в базе данных', mtConfirmation, mbYesNo, 0) <>
    mrYes then exit;
  mainSession.saveORAImageList(0, FImageListEditor.ImageList);
  MessageDlg('»конки сохранены', mtInformation, [mbOK], 0);
end;

end.
