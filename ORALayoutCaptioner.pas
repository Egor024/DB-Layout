unit ORALayoutCaptioner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, layoutForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxCustomData,
  cxStyles, cxTL, cxTLdxBarBuiltInMenu, dxLayoutContainer, DB, dxmdaset, cxInplaceContainer,
  cxTLData, cxDBTL, dxLayoutControl, ORALayout, ComCtrls, cxContainer, cxEdit, cxTreeView,
  cxMaskEdit, cxTextEdit, dxLayoutControlAdapters, Menus, StdCtrls, cxButtons, cxCheckBox,
  cxClasses;

type
  TfrmCaptioner = class(TfrmLayout)
    mdControls: TdxMemData;
    dsControls: TDataSource;
    mdControlsControlName: TStringField;
    mdControlsParentName: TStringField;
    mdControlsCaption: TStringField;
    tlControls: TcxDBTreeList;
    dxLayoutControl1Item1: TdxLayoutItem;
    tlControlsCaption: TcxDBTreeListColumn;
    mdControlsPointer: TIntegerField;
    btnSave: TcxButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    btnLoad: TcxButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    mdControlsChanged: TBooleanField;
    tlControlsChanged: TcxDBTreeListColumn;
    cxStyleRepository1: TcxStyleRepository;
    stChanged: TcxStyle;
    procedure tlControlsCaptionPropertiesEditValueChanged(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure tlControlsStylesGetContentStyle(Sender: TcxCustomTreeList; AColumn: TcxTreeListColumn;
      ANode: TcxTreeListNode; var AStyle: TcxStyle);
  private
    FForm: TfrmORALayout;
    { Private declarations }
  public
    { Public declarations }
    procedure initializeCaptions(const aForm: TfrmORALayout);
  end;

procedure editCaptions(const aForm: TfrmORALayout);

implementation

uses StrUtils, ORALayoutCustomize;

{$R *.dfm}

procedure editCaptions(const aForm: TfrmORALayout);
begin
  with TfrmCaptioner.Create(Application) do
    try
      initializeCaptions(aForm);
      ShowModal;
    finally
      Free;
    end;
end;

{ TfrmCaptioner }

procedure TfrmCaptioner.btnLoadClick(Sender: TObject);
var
  I, II: Integer;
  vFStream: TFileStream;
  vControlName: String;
  vComponent: TComponent;
begin
  if not OpenDialog1.Execute then exit;
  if OpenDialog1.Files.Count <> 1 then exit;

  vFStream := TFileStream.Create(OpenDialog1.Files[0], fmOpenRead);
  with mdControls do
    try
      Close;
      open;
      LoadFromStream(vFStream);
      First;
      while not EOF do begin
        vControlName := AnsiUpperCase(mdControlsControlName.AsString);
        if AnsiUpperCase(FForm.dxLayoutControl1Group_Root.Name) = vControlName then begin
          mdControls.Edit;
          mdControlsChanged.Value := FForm.Caption <> mdControlsCaption.AsString;
          FForm.Caption := mdControlsCaption.AsString;
          mdControlsPointer.AsInteger := Integer(FForm);
          mdControls.Post;
        end else begin
          mdControls.Edit;
          mdControlsPointer.AsInteger := 0;
          mdControlsChanged.Value := False;
          mdControls.Post;
          with FForm.Controller.ControlCollection do
            for I := 0 to Count - 1 do begin
              if AnsiUpperCase(Items[I].Name) = vControlName then begin
                mdControls.Edit;
                mdControlsChanged.Value := Items[I].Caption <> mdControlsCaption.AsString;
                Items[I].Caption := mdControlsCaption.AsString;
                mdControlsPointer.AsInteger := Integer(Items[I]);
                mdControls.Post;
                break;
              end;
              II := Items[I].indexOfSubControl(vControlName);
              if II >= 0 then begin
                mdControls.Edit;
                vComponent := Items[I].SubControl[II];
                with getORAComponentPropertiesClass(TComponentClass(vComponent.ClassType))
                  .Create(vComponent, nil) do
                  try
                    mdControlsChanged.Value := Caption <> mdControlsCaption.AsString;
                    Caption := mdControlsCaption.AsString;
                    mdControlsPointer.AsInteger := Integer(vComponent);
                  finally
                    Free;
                  end;
                mdControls.Post;
                break;
              end;
              vComponent := FForm.FindComponent(vControlName);
              if vComponent is TdxLayoutGroup then begin
                mdControls.Edit;
                mdControlsChanged.Value := TdxLayoutGroup(vComponent).Caption <>
                  mdControlsCaption.AsString;
                TdxLayoutGroup(vComponent).Caption := mdControlsCaption.AsString;
                mdControlsPointer.AsInteger := Integer(vComponent);
                mdControls.Post;
                break;
              end;
            end;
        end;
        Next;
      end;
    finally
      vFStream.Free;
    end;

  tlControls.Root.Expand(True);
  // Controller.initControls;
end;

procedure TfrmCaptioner.btnSaveClick(Sender: TObject);
var
  vFStream: TFileStream;
  v_dest: String;
begin
  inherited;
  if not SaveDialog1.Execute then exit;
  if SaveDialog1.Files.Count <> 1 then exit;
  v_dest := SaveDialog1.Files[0];
  if AnsiUpperCase(RightStr(v_dest, 9)) <> '.CAPTIONS' then v_dest := v_dest + '.Captions';
  vFStream := TFileStream.Create(v_dest, fmCreate);
  try
    mdControls.SaveToStream(vFStream);
  finally
    vFStream.Free;
  end;
end;

procedure TfrmCaptioner.initializeCaptions(const aForm: TfrmORALayout);
  procedure append_group(const aLayoutGroup: TdxLayoutGroup);
  var
    I, II: Integer;
    vControl: TORAControlProperties;
    vSubControl: TComponent;
  begin
    with aLayoutGroup do
      for I := 0 to Count - 1 do begin
        if Items[I] is TdxLayoutItem then
          with TdxLayoutItem(Items[I]) do
            if Control <> nil then begin
              with FForm.Controller.ControlCollection do vControl := Items[IndexOf(Control)];
              mdControls.AppendRecord([0, Integer(vControl), vControl.Name, aLayoutGroup.Name,
                vControl.Caption]);
              for II := 0 to vControl.SubControlCount - 1 do begin
                vSubControl := vControl.SubControl[II];
                with getORAComponentPropertiesClass(TComponentClass(vSubControl.ClassType))
                  .Create(vSubControl, nil) do
                  try
                    mdControls.AppendRecord([0, Integer(vSubControl), vSubControl.Name,
                      vControl.Name, Caption]);
                  finally
                    Free;
                  end;
              end;
            end;
        if Items[I] is TdxLayoutGroup then begin
          mdControls.AppendRecord([0, Integer(Items[I]), Items[I].Name, aLayoutGroup.Name,
            Items[I].Caption]);
          append_group(TdxLayoutGroup(Items[I]));
        end;
      end;
  end;

begin
  FForm := aForm;
  with mdControls do begin
    Close;
    open;
    AppendRecord([0, Integer(FForm), FForm.dxLayoutControl1Group_Root.Name, '', FForm.Caption]);
    append_group(FForm.dxLayoutControl1Group_Root);
  end;
end;

procedure TfrmCaptioner.tlControlsCaptionPropertiesEditValueChanged(Sender: TObject);
var
  vComponent: TPersistent;
begin
  inherited;
  tlControlsCaption.EditValue := tlControls.InplaceEditor.EditingValue;
  vComponent := Pointer(mdControlsPointer.AsInteger);
  if vComponent is TORAComponentProperties then
      TORAComponentProperties(vComponent).Caption := tlControlsCaption.EditValue
  else if vComponent is TCustomForm then
      TCustomForm(vComponent).Caption := tlControlsCaption.EditValue
  else
    with getORAComponentPropertiesClass(TComponentClass(vComponent.ClassType))
      .Create(TComponent(vComponent), nil) do
      try
        Caption := tlControlsCaption.EditValue;
      finally
        Free;
      end;
  with mdControls do begin
    Edit;
    mdControlsChanged.Value := True;
    Post;
  end;

end;

procedure TfrmCaptioner.tlControlsStylesGetContentStyle(Sender: TcxCustomTreeList;
  AColumn: TcxTreeListColumn; ANode: TcxTreeListNode; var AStyle: TcxStyle);
var
  v: Variant;
begin
  inherited;
  v := ANode.Values[tlControlsChanged.Position.ColIndex];
  if not VarIsNull(v) And v then AStyle := stChanged
  else AStyle := nil
end;

end.
