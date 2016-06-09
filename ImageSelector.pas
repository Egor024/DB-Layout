unit ImageSelector;

interface

uses
  Windows, Forms, layoutForm,
  dxLayoutContainer, Classes, Controls, dxLayoutControl, ComCtrls,
  ImgList, cxButtons, cxLookAndFeelPainters, cxLookAndFeels, dxLayoutControlAdapters,
  Menus, cxGraphics, cxControls, StdCtrls;

type
  TfrmImageSelector = class(TfrmLayout)
    lvImages: TListView;
    dxLayoutControl1Item1: TdxLayoutItem;
    cxButton1: TcxButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    cxButton2: TcxButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    cxButton3: TcxButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    procedure lvImagesDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function selectImage(const pImageList: TCustomImageList;
  const pImageIndex: TImageIndex = -1): Longint;

implementation

uses SysUtils, Graphics;
{$R *.dfm}

function selectImage(const pImageList: TCustomImageList; const pImageIndex: TImageIndex): Longint;
var
  I: Longint;
begin
  Result := -1;
  if pImageList = nil then exit;

  With TfrmImageSelector.Create(Application) do
    try
      lvImages.LargeImages := pImageList;
      with pImageList do
        for I := 0 to Count - 1 do
          with lvImages.Items.Add do begin
            Caption := IntToStr(I);
            ImageIndex := I;
          end;
      lvImages.ItemIndex := pImageIndex;
      case showModal of
        mrOK: Result := lvImages.ItemIndex;
        mrIgnore: Result := -1;
      else Result := pImageIndex;
      end;
    finally
      Free;
    end;
end;

procedure TfrmImageSelector.lvImagesDblClick(Sender: TObject);
begin
  inherited;
  ModalResult := mrOK;
end;

end.
