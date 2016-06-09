unit PassChange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, layoutForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxLayoutcxEditAdapters, dxLayoutControlAdapters, Menus, StdCtrls, cxButtons,
  dxLayoutContainer, cxTextEdit, dxLayoutControl;

type
  TfrmPassChange = class(TfrmLayout)
    teOldPass: TcxTextEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    teNewPass: TcxTextEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    teChkPass: TcxTextEdit;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    btnOK: TcxButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    btnCancel: TcxButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    procedure teNewPassPropertiesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//  tChangePasswordProc = procedure(const pOldPassword: String; const pNewPassword: String);
//  tChangePasswordMethod = procedure(const pOldPassword: String; const pNewPassword: String) of object;

//function changePassword(const pChProc: tChangePasswordProc): Boolean; overload;
function changePassword: Boolean; overload;

implementation

uses layoutData;
{$R *.dfm}

//function changePassword(const pChProc: tChangePasswordProc): Boolean;
//begin
//  Result := False;
//  with TfrmPassChange.Create(Application) do
//    try
//      repeat
//        if ShowModal = mrCancel then exit;
//        try
//          pChProc(teOldPass.EditValue, teNewPass.EditValue);
//          Result := True;
//          exit;
//        except
//          on E: Exception do begin
//            if MessageDlg('Ошибка смены пароля' + #13#10 + E.Message + #13#10 + 'Повторить?',
//              mtError, mbYesNo, 0) <> mrYes then exit;
//          end;
//        end;
//      until False;
//    finally
//      Free;
//      if Result then ShowMessage('Пароль успешно изменен');
//    end;
//end;

function changePassword: Boolean;
begin
  Result := False;
  with TfrmPassChange.Create(Application) do
    try
      repeat
        if ShowModal = mrCancel then exit;
        try
          mainSession.change_password(teOldPass.EditValue, teNewPass.EditValue);
          Result := True;
          exit;
        except
          on E: Exception do begin
            if MessageDlg('Ошибка смены пароля' + #13#10 + E.Message + #13#10 + 'Повторить?',
              mtError, mbYesNo, 0) <> mrYes then exit;
          end;
        end;
      until False;
    finally
      Free;
      if Result then ShowMessage('Пароль успешно изменен');
    end;
end;

procedure TfrmPassChange.teNewPassPropertiesChange(Sender: TObject);
begin
  inherited;
  btnOK.Enabled := (teNewPass.EditingText = teChkPass.EditingText) And
    (teNewPass.EditingText <> teOldPass.EditingText) and (teNewPass.EditingText <> '') and
    (teOldPass.EditingText <> '');

end;

end.
