unit ORAMainMenu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  dxBarCustomCustomizationForm, dxBar, cxClasses, ActnList, ImgList, StdCtrls, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxLayoutContainer, dxLayoutControlAdapters,
  ORALayout, Menus, cxButtons, dxLayoutControl, cxStyles, cxEdit, cxInplaceContainer,
  cxVGrid, cxOI, ORARoles;

type

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED or IMAGE_FILE_DEBUG_STRIPPED or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED or IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP or IMAGE_FILE_NET_RUN_FROM_SWAP}
  TORAMainMenuCustomizationForm = class(TdxBarCustomCustomizationForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    lbItems: TListBox;
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Item1: TdxLayoutItem;
    btnSave: TcxButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    btnLoad: TcxButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    btnAddButton: TcxButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    btnAddSubMenu: TcxButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    rtInspector: TcxRTTIInspector;
    dxLayoutControl1Item6: TdxLayoutItem;
    dxLayoutControl1SplitterItem1: TdxLayoutSplitterItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbItemsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnAddSubMenuClick(Sender: TObject);
    procedure btnAddButtonClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetBarListBox: TListBox; override;
    function GetCategoriesList: TListBox; override;
    function GetItemsListBox: TListBox; override;
    procedure SynchronizeListBoxes; override;
    procedure PrepareControls; override;

  public
    { Public declarations }
    procedure DesignSelectionChanged(Sender: TObject); override;
    procedure SelectPage(APageIndex: Integer); override;
    procedure SwitchToItemsPage; override;
    procedure UpdateHelpButton; override;
    procedure UpdateOptions; override;
  end;

implementation

uses DB, cxBarEditItem, Dialogs, ORALayoutCustomize, TypInfo, LayoutData;
{$R *.dfm}

type
  TORABarController = class(TInterfacedObject, IORALayoutInterface)
  private
    FInnerVariables: TDataSet;
    // IORALayoutInterface
    function GetLayoutName: String;
    function GetLayoutValue(const pControlName: String): String;
    procedure SetLayoutValue(const pControlName: String; const Value: String);
    function doBeforeExecute(const AQuery: TDataSet): Boolean;
    procedure doAfterExecute(const AQuery: TDataSet);
    function getInnerVariables: TDataSet;

    property InnerVariables: TDataSet read getInnerVariables;
  public
    constructor Create;
  end;

  TORABarSubItem = class(TdxBarSubItem)
  private
    FDB_Roles: TORADBRoles;
  protected
  published
    property DB_Roles: TORADBRoles read FDB_Roles write FDB_Roles;
  end;

  TORABarButton = class(TdxBarButton)
  private
    FDB_Roles: TORADBRoles;
    FOnClickStart: TDataSet;
    FOnClickFinish: TDataSet;
    function getClickFinishSQL: String;
    function getClickStartSQL: String;
    procedure setClickFinishSQL(const Value: String);
    procedure setClickStartSQL(const Value: String);
    procedure OnButtonClickHandler(Sender: TObject);
  protected
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DB_Roles: TORADBRoles read FDB_Roles write FDB_Roles;
    property OnClickStart: TDataSet read FOnClickStart;
    property OnClickFinish: TDataSet read FOnClickFinish;
    property ClickStartSQL: String read getClickStartSQL write setClickStartSQL;
    property ClickFinishSQL: String read getClickFinishSQL write setClickFinishSQL;
  end;

  TdxBarItemAccess = class(TdxBarItem);
  TdxBarWindowItemAccess = class(TdxBarWindowItem);
  TdxBarAccess = class(TdxBar);
  TdxBarManagerAccess = class(TdxBarManager);

  TReaderAccess = class(TReader);

var
  mainBarController: TORABarController;
  { TORAMainMenuCustomizationForm }

procedure TORAMainMenuCustomizationForm.btnAddButtonClick(Sender: TObject);
begin
  inherited;
  HostInterface.MainBarManager.AddItem(TORABarButton).Name :=
    HostInterface.MainBarManager.GetUniqueItemName(TORABarButton);
end;

procedure TORAMainMenuCustomizationForm.btnAddSubMenuClick(Sender: TObject);
begin
  inherited;
  HostInterface.MainBarManager.AddItem(TORABarSubItem).Name :=
    HostInterface.MainBarManager.GetUniqueItemName(TORABarSubItem);
end;

procedure TORAMainMenuCustomizationForm.btnLoadClick(Sender: TObject);
begin
  mainSession.loadORAMenuItems(0, HostInterface.MainBarManager);
end;

procedure TORAMainMenuCustomizationForm.btnSaveClick(Sender: TObject);
begin
  mainSession.saveORAMenuItems(0, HostInterface.MainBarManager);
end;

procedure TORAMainMenuCustomizationForm.DesignSelectionChanged(Sender: TObject);
begin
  if not(csDestroying in (Application.ComponentState + ComponentState)) then begin
    SynchronizeListBoxSelection(ListBox1);
    SynchronizeListBoxSelection(lbItems);
    rtInspector.InspectedObject := ItemList[lbItems.ItemIndex];
    // SynchronizeListBoxSelection(LAllCommands);
    // SynchronizeListBoxSelection(lbGroups);
  end;
end;

procedure TORAMainMenuCustomizationForm.FormCreate(Sender: TObject);

var
  I: Longint;
begin
  inherited;
  with HostInterface.MainBarManager.bars do
    for I := 0 to Count - 1 do Items[I].AllowCustomizing := True;
end;

procedure TORAMainMenuCustomizationForm.FormDestroy(Sender: TObject);

var
  I: Longint;
begin
  inherited;
  with HostInterface.MainBarManager.bars do
    for I := 0 to Count - 1 do Items[I].AllowCustomizing := False;
end;

function TORAMainMenuCustomizationForm.GetBarListBox: TListBox;
begin
  Result := ListBox1;
end;

function TORAMainMenuCustomizationForm.GetCategoriesList: TListBox;
begin
  Result := ListBox2;
end;

function TORAMainMenuCustomizationForm.GetItemsListBox: TListBox;
begin
  Result := lbItems;
end;

procedure TORAMainMenuCustomizationForm.SelectPage(APageIndex: Integer);
begin
  // PageControl.ActivePageIndex := APageIndex;
end;

procedure TORAMainMenuCustomizationForm.SwitchToItemsPage;
begin
  // PageControl.ActivePage := tsItems;
end;

procedure TORAMainMenuCustomizationForm.SynchronizeListBoxes;
begin
  SynchronizeListBox(ListBox1);
  SynchronizeListBox(ListBox2);
  SynchronizeListBox(lbItems);
  // SynchronizeListBox(LAllCommands);
  // SynchronizeListBox(lbGroups);
end;

procedure TORAMainMenuCustomizationForm.UpdateHelpButton;
begin
  // BHelp.Glyph := BarManager.HelpButtonGlyph;
  // BHelp.Visible := BarManager.ShowHelpButton;
end;

procedure TORAMainMenuCustomizationForm.UpdateOptions;
begin
  // StandardOptionsPanel.Visible := BarManager.GetPaintStyle = bmsStandard;
  // EnhancedOptionsPanel.Visible := BarManager.GetPaintStyle <> bmsStandard;
  //
  // CBMenusShowRecentItemsFirst.Checked := BarManager.MenusShowRecentItemsFirst;
  // CBShowFullMenusAfterDelay.Checked := BarManager.ShowFullMenusAfterDelay;
  // CBShowFullMenusAfterDelay.Enabled := CBMenusShowRecentItemsFirst.Checked;
  //
  // CBLargeIcons.Checked := BarManager.LargeIcons;
  // CBLargeIconsEx.Checked := BarManager.LargeIcons;
  // CBHint1.Checked := BarManager.ShowHint;
  // CBHint1Ex.Checked := BarManager.ShowHint;
  // CBHint2.Checked := BarManager.ShowShortcutInHint;
  // CBHint2Ex.Checked := BarManager.ShowShortcutInHint;
  // CBHint2Ex.Enabled := CBHint1Ex.Checked;
  // ComboBoxMenuAnimations.ItemIndex := Ord(BarManager.MenuAnimations);
  // ComboBoxMenuAnimationsEx.ItemIndex := Ord(BarManager.MenuAnimations);
end;

procedure TORAMainMenuCustomizationForm.lbItemsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);

  function BrushColors(aItem: TdxBarItem; ASelected: Boolean): TColor;
  begin
    Result := PainterClass.BrushColors(ASelected, aItem);
  end;

var
  aItem: TdxBarItem;
  R: TRect;
begin
  aItem := ItemList[Index];
  if aItem = nil then exit;

  TdxBarItemAccess(aItem).DrawCustomizingImage(lbItems.Canvas, Rect, State);
  R := Rect;
  if Index = lbItems.Items.Count - 1 then begin
    R := Rect;
    R.Top := R.Bottom;
    R.Bottom := ClientHeight;
    lbItems.Canvas.Brush.Color := BrushColors(aItem, False);
    lbItems.Canvas.FillRect(R);
  end;

  if odFocused in State then PainterClass.DrawFocusedRect(lbItems.Canvas, Rect, aItem);
end;

procedure TORAMainMenuCustomizationForm.PrepareControls;

begin
  inherited;

end;

{ TORABarButton }

constructor TORABarButton.Create(AOwner: TComponent);
begin
  inherited;

  FOnClickStart := TDataSet(stdLayoutQuery(self));
  FOnClickStart.Name := 'OnClickStart';
  FOnClickFinish := TDataSet(stdLayoutQuery(self));
  FOnClickFinish.Name := 'OnClickFinish';
  OnClick := OnButtonClickHandler;
end;

function TORABarButton.getClickFinishSQL: String;
begin
  Result := getLayoutInterface(OnClickFinish).SQL.Text;
end;

function TORABarButton.getClickStartSQL: String;
begin
  Result := getLayoutInterface(OnClickStart).SQL.Text;
end;

procedure TORABarButton.OnButtonClickHandler(Sender: TObject);
  procedure run_query(const pQuery: TDataSet);
  begin
    if pQuery <> nil then
      with pQuery, getLayoutInterface(pQuery) do
        if SQL.Text <> '' then begin
          LayoutSession := mainSessionComponent;
          mainBarController.doBeforeExecute(pQuery);
          try
            Execute;
          except
            on E: Exception do begin
              MessageDlg('BarButton (' + Name + '.' + pQuery.Name + '):' + #13#10 + E.Message,
                mtError, [mbOK], 0);
            end;
          end;
          mainBarController.doAfterExecute(pQuery);
        end;
  end;

begin
  if Assigned(HostInterface.preLayoutButtonClick) then
      HostInterface.preLayoutButtonClick(mainBarController);
  run_query(FOnClickStart);
  if Assigned(HostInterface.afterLayoutButtonClick) then
      HostInterface.afterLayoutButtonClick(mainBarController, FOnClickStart);
  run_query(FOnClickFinish);
end;

procedure TORABarButton.setClickFinishSQL(const Value: String);
begin
  getLayoutInterface(OnClickFinish).SQL.Text := Value;
end;

procedure TORABarButton.setClickStartSQL(const Value: String);
begin
  getLayoutInterface(OnClickStart).SQL.Text := Value;
end;

{ TORABarController }

constructor TORABarController.Create;
begin
  FInnerVariables := nil;
end;

procedure TORABarController.doAfterExecute(const AQuery: TDataSet);
begin
  doAfterExecute_std(self, AQuery);
end;

function TORABarController.doBeforeExecute(const AQuery: TDataSet): Boolean;
begin
  Result := doBeforeExecute_std(self, AQuery);
end;

function TORABarController.getInnerVariables: TDataSet;
begin
  if FInnerVariables = nil then begin
    FInnerVariables := stdLayoutQuery;
    getLayoutInterface(FInnerVariables).ParamCheck := False;
  end;
  Result := FInnerVariables;
end;

function TORABarController.GetLayoutName: String;
begin
  if HostInterface.MainBarManager <> nil then Result := HostInterface.MainBarManager.Name
  else Result := '';
end;

function TORABarController.GetLayoutValue(const pControlName: String): String;
var
  vControlName: String;
  vItem: TdxBarItem;
  vParam: TParam;
begin
  Result := '';
  if HostInterface.MainBarManager = nil then exit;

  if pControlName[1] = ':' then vControlName := AnsiUpperCase(PChar(pControlName) + 1)
  else vControlName := AnsiUpperCase(pControlName);

  vItem := HostInterface.MainBarManager.GetItemByName(vControlName);
  if vItem <> nil then begin
    if vItem is TcxCustomBarEditItem then
        Result := VarToStr(TcxCustomBarEditItem(vItem).CurEditValue)
    else if vItem is TdxBarButton then Result := BoolToStr(TdxBarButton(vItem).Down, True)
    else if vItem is TdxBarWindowItem then Result := TdxBarWindowItemAccess(vItem).CurText
    else Result := vItem.Caption;
    exit;
  end;

  // Цикл поиска vControlName среди внутренних переменных
  with getLayoutInterface(InnerVariables) do begin
    vParam := Params.FindParam(vControlName);
    if vParam = nil then Result := ''
    else Result := vParam.AsString;
  end;
end;

procedure TORABarController.SetLayoutValue(const pControlName, Value: String);
var
  vControlName: String;
  vItem: TdxBarItem;
  v: Boolean;
  vParam: TParam;
begin
  if HostInterface.MainBarManager = nil then exit;

  if pControlName[1] = ':' then vControlName := AnsiUpperCase(PChar(pControlName) + 1)
  else vControlName := AnsiUpperCase(pControlName);

  vItem := HostInterface.MainBarManager.GetItemByName(vControlName);
  if vItem <> nil then begin
    if vItem is TcxCustomBarEditItem then TcxCustomBarEditItem(vItem).EditValue := Value
    else if vItem is TdxBarButton then begin
      if TryStrToBool(Value, v) then TdxBarButton(vItem).Down := v;
    end
    else if vItem is TdxBarWindowItem then TdxBarWindowItemAccess(vItem).Text := Value
    else vItem.Caption := Value;
    exit;
  end;

  with getLayoutInterface(InnerVariables) do begin
    vParam := Params.FindParam(vControlName);
    if vParam <> nil then vParam.AsString := Value
    else
      with Params.CreateParam(ftWideString, vControlName, ptInputOutput) do begin
        Size := 4000;
        AsString := Value;
      end;
  end;
end;

initialization

mainBarController := TORABarController.Create;
RegisterClasses([TORABarSubItem, TORABarButton]);
dxBarRegisterItem(TORABarButton, TdxBarButtonControl, True);
dxBarRegisterItem(TORABarSubItem, TdxBarSubItemControl, True);
cxRegisterPropertyEditor(TypeInfo(Integer), TdxBarItem, 'ImageIndex', TORAImageIndexProperty);
cxRegisterPropertyEditor(TypeInfo(TDataSet), TdxBarItem, '', TORADataSetProperty);
cxRegisterPropertyEditor(TypeInfo(TORADBRoles), TdxBarItem, '', TORADBRolesProperty);

finalization

UnRegisterClasses([TORABarSubItem, TORABarButton]);
mainBarController.Free;

end.
