unit ORAStyles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxLayoutContainer,
  cxContainer, cxEdit, cxListBox, dxLayoutControl, cxOI, cxStyles, cxInplaceContainer, cxVGrid,
  dxLayoutControlAdapters, Menus, StdCtrls, cxButtons;

type
  TORALayoutStyleProperty = class(TcxComponentProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TfrmORAStyles = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    lbStyles: TcxListBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    styleEditor: TcxRTTIInspector;
    dxLayoutControl1Item2: TdxLayoutItem;
    btnAddNewStyle: TcxButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    btnSave: TcxButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure lbStylesClick(Sender: TObject);
    procedure btnAddNewStyleClick(Sender: TObject);
    procedure styleEditorPropertyChanged(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure editLayoutStyles;
function LayoutStyles(const pStyleName: String): TcxStyle;
function styles2string(const pStyles: TcxCustomStyles): String;
procedure string2styles(const pStyles: TcxCustomStyles; const pValues: String);

implementation

uses cxClasses, LayoutData, ORALayout;

type
  TcxCustomStylesAccsee = class(TcxCustomStyles);
{$R *.dfm}

function styles2string(const pStyles: TcxCustomStyles): String;
var
  I: Longint;
begin
  Result := '';
  if pStyles = nil then exit;
  with TcxCustomStylesAccsee(pStyles) do
    for I := 0 to Count - 1 do
        Result := Result + IntToStr(Items[I].Index) + ';' + Items[I].Item.Name + ';';
end;

procedure string2styles(const pStyles: TcxCustomStyles; const pValues: String);
var
  I, ndx: Longint;
begin
  if pStyles = nil then exit;
  with TStringList.Create do
    try
      Text := StringReplace(pValues, ';', #13#10, [rfReplaceAll]);
      for I := 0 to (Count shr 1) - 1 do
        try
          ndx := StrToInt(Strings[I]);
          pStyles.Values[ndx] := LayoutStyles(Strings[I + 1]);
        except
        end;
    finally
      Free;
    end;
end;

procedure editLayoutStyles;
begin
  if HostInterface.LayoutStyleRepository = nil then exit;
  with TfrmORAStyles.Create(Application) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

function LayoutStyles(const pStyleName: String): TcxStyle;
var
  I: Integer;
begin
  if HostInterface.LayoutStyleRepository <> nil then
    with HostInterface.LayoutStyleRepository do
      for I := 0 to Count - 1 do
        if AnsiCompareText(Items[I].Name, pStyleName) = 0 then begin
          Result := TcxStyle(Items[I]);
          exit;
        end;
  Result := nil;
end;
{ TORALayoutStyleProperty }

function TORALayoutStyleProperty.GetValue: string;
begin
  if GetOrdValue <> 0 then Result := TcxStyle(GetOrdValue).Name
  else Result := '';
end;

procedure TORALayoutStyleProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  with HostInterface.LayoutStyleRepository do
    for I := 0 to Count - 1 do begin
      Proc(Items[I].Name);
    end;
end;

procedure TORALayoutStyleProperty.SetValue(const Value: string);
begin
  SetOrdValue(Longint(LayoutStyles(Value)));
end;

procedure TfrmORAStyles.btnAddNewStyleClick(Sender: TObject);
var
  vStyle: TcxCustomStyle;
begin
  vStyle := HostInterface.LayoutStyleRepository.CreateItem(TcxStyle);
  vStyle.Name := CreateUniqueName(nil, nil, vStyle, '', '');
  lbStyles.AddItem(vStyle.Name, vStyle);
  lbStyles.ItemIndex := lbStyles.Count - 1;
  styleEditor.InspectedObject := vStyle;
end;

procedure TfrmORAStyles.btnSaveClick(Sender: TObject);
begin
  mainSession.saveORAStyles(0, HostInterface.LayoutStyleRepository);
end;

procedure TfrmORAStyles.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  with HostInterface.LayoutStyleRepository do
    for I := 0 to Count - 1 do lbStyles.AddItem(Items[I].Name, Items[I]);
end;

procedure TfrmORAStyles.lbStylesClick(Sender: TObject);
begin
  if lbStyles.ItemIndex = -1 then styleEditor.InspectedObject := nil
  else styleEditor.InspectedObject := TPersistent(lbStyles.Items.Objects[lbStyles.ItemIndex]);
end;

procedure TfrmORAStyles.styleEditorPropertyChanged(Sender: TObject);
begin
  if styleEditor.FocusedRow = nil then exit;
  with TcxPropertyRow(styleEditor.FocusedRow).PropertyEditor do
    if getName = 'Name' then
      with lbStyles do Items[ItemIndex] := GetValue;
end;

initialization

cxRegisterPropertyEditor(TypeInfo(TcxStyle), nil, '', TORALayoutStyleProperty);

end.
