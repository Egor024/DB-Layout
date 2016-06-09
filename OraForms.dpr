program OraForms;



{$R *.dres}

uses
  Forms,
  LMain in 'LMain.pas' {frmMain},
  PassChange in 'PassChange.pas' {frmPassChange},
  XLS_work in 'XLS_work.pas' {frmXLSwork},
  ShowProgress in 'ShowProgress.pas' {frmProgress},
  XLS_user_work in 'XLS_user_work.pas' {frmXLSUserWork},
  LayoutORAData in 'LayoutORAData.pas',
  LayoutData in 'LayoutData.pas',
  TestStartCard in 'TestStartCard.pas' {frmStartCard};

{$R *.RES}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  frmMain.WindowState:=wsMaximized;
  Application.Run;
end.
