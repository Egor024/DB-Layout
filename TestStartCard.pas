unit TestStartCard;

interface

uses
  jpeg, cxImage, cxLabel, Windows, Forms,
  cxLookAndFeelPainters, Classes, Controls, cxGraphics, cxControls,
  cxLookAndFeels, cxEdit, cxContainer, GIFImg, dxGDIPlusClasses;

type
  TfrmStartCard = class(TForm)
    cxLabel1: TcxLabel;
    cxImage1: TcxImage;
    procedure FormActivate(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfrmStartCard.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TfrmStartCard.FormActivate(Sender: TObject);
begin
  Top := round((Screen.Height) / 2.5)-Self.Height;
end;

initialization
RegisterClass(TfrmStartCard);
finalization
UnRegisterClass(TfrmStartCard);

end.
