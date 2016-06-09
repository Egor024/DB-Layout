unit layoutForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MDIButtonGroup, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxLayoutContainer,ImgList, dxLayoutControl, cxStyles;

type
  TfrmLayout = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  private
    { Private declarations }
    FIconIndex: Integer;
    procedure setIconIndex(const Value: Integer);
  public
    { Public declarations }
  published
    property IconIndex: Integer read FIconIndex write setIconIndex default -1;
  end;

function get_MDI_form(AClassName: String; OwnerForm: TForm = nil): TForm;
function showForm(AClassName: String): TForm;

var
  MainFormTabControl: TMDIButtonGroup = nil;

implementation

{$R *.dfm}

function showForm(AClassName: String): TForm;
var
  vClass: TPersistentClass;
begin
  Result := get_MDI_form(AClassName);
  if Result <> nil then Result.BringToFront
  else begin
    vClass := GetClass(AClassName);
    if (vClass <> nil) And vClass.InheritsFrom(TForm) then begin
      Result := TFormClass(vClass).Create(nil);
      Result.Show;
    end;
  end;
end;

function get_MDI_form(AClassName: String; OwnerForm: TForm = nil): TForm;
var
  i: Integer;
begin
  Result := nil;
  if Application.MainForm = nil then exit;

  with Application.MainForm do
    for i := 0 to MDIChildCount - 1 do
      if (MDIChildren[i].ClassName = AClassName) and (MDIChildren[i].Owner = OwnerForm) then begin
        Result := MDIChildren[i];
        break;
      end;
end;

procedure TfrmLayout.CMTextChanged(var Message: TMessage);
var i : longint;
begin
  inherited;
  if MainFormTabControl <> nil then
    with MainFormTabControl do begin
      i := IndexOf(self);
      if i < 0 then exit;
      Items[i].Caption := Caption;
    end;
end;

procedure TfrmLayout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FormStyle = fsMDIChild then begin
    Action := caFree;
  end;
end;

procedure TfrmLayout.FormCreate(Sender: TObject);
begin
  if ((MainFormTabControl <> nil) and (FormStyle = fsMDIChild)) then begin
    MainFormTabControl.AddButton(self, IconIndex, Caption);
  end;
end;

procedure TfrmLayout.setIconIndex(const Value: Integer);
var
  i: Longint;
begin
  FIconIndex := Value;
  if ((MainFormTabControl <> nil) And (Value <> -1)) then
    with MainFormTabControl do begin
      Images.GetIcon(IconIndex, Icon);
      i := IndexOf(self);
      if i < 0 then exit;
      Items[i].ImageIndex := Value;
    end;
end;

{ TdxLayoutControl }

Initialization

RegisterClass(TfrmLayout);

Finalization

UnRegisterClass(TfrmLayout);

end.
