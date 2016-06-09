unit MDIButtonGroup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, CommCtrl, CategoryButtons, ButtonGroup, Math, UxTheme, Themes;

type
  PNotifyEvent = ^TNotifyEvent;

  TMDIButtonGroup = class(TButtonGroup)
  private
    FActivateList, FDestroyList: TList;
    FOnBeforeDrawButton: TGrpButtonDrawEvent;
    FOnAfterDrawButton: TGrpButtonDrawEvent;
    FOnDrawButton: TGrpButtonDrawEvent;
    FOnDrawIcon: TGrpButtonDrawIconEvent;
    FOnDrawText: TGrpButtonDrawEvent;
    FRegularButtonColor: TColor;
    FSelectedButtonColor: TColor;
    FHotButtonColor: TColor;
    FHotButton: Integer;
    FAutoSize: boolean;
    FCloseButtonsRect: array of TRect;
    FCloseButtonMouseDownIndex: Integer;
    FCloseButtonShowPushed: boolean;
    FCloseButtonShowHot: boolean;
    function CalcButtonsPerRow: Integer;
    procedure ChildActivate(Sender: TObject);
    procedure ChildDestroy(Sender: TObject);
    procedure SetOnDrawButton(const Value: TGrpButtonDrawEvent);
    procedure SetOnDrawIcon(const Value: TGrpButtonDrawIconEvent);
    procedure SetHotButtonColor(const Value: TColor);
    procedure SetRegularButtonColor(const Value: TColor);
    procedure SetSelectedButtonColor(const Value: TColor);
    function GetCaption(index: Integer): string;
    function GetCount: Integer;
    function GetGlyph(index: Integer): Integer;
    function GetHint(index: Integer): string;
    function GetChild(index: Integer): TForm;
    function GetMinimized: Integer;
    procedure SetCaption(index: Integer; const Value: string);
    procedure SetGlyph(index: Integer; const Value: Integer);
    procedure SetHint(index: Integer; const Value: string);
    function GetActiveChild: TForm;
  protected
    procedure SetAutoSize(Value: boolean); override;
    procedure DoItemClicked(const Index: Integer); override;
    procedure DrawButton(Index: Integer; Canvas: TCanvas; _Rect: TRect;
      State: TButtonDrawState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddButton(AChild: TForm; AImageIndex: Integer; AHint: string);
    procedure DelButton(AChild: TForm);
    function IndexOf(AForm: TForm): Integer;
    procedure MinimizeAll;
    procedure CloseAll;
    function GetChildIndex(AChild: TForm): Integer;
    property ActiveMDIChild: TForm read GetActiveChild;
    property MDIChildCount: Integer read GetCount;
    property MDIChildren[index: Integer]: TForm read GetChild;
    property MinimizedCount: Integer read GetMinimized;
    property Captions[index: Integer]: string read GetCaption write SetCaption;
    property Glyphs[index: Integer]: Integer read GetGlyph write SetGlyph;
    property Hints[index: Integer]: string read GetHint write SetHint;
    property HotButtonIndex: Integer read FHotButton;
  published
    property AutoSize: boolean read FAutoSize write SetAutoSize;
    property HotButtonColor: TColor read FHotButtonColor write SetHotButtonColor;
    property RegularButtonColor: TColor read FRegularButtonColor
      write SetRegularButtonColor nodefault;
    property SelectedButtonColor: TColor read FSelectedButtonColor
      write SetSelectedButtonColor nodefault;

    property OnAfterDrawButton: TGrpButtonDrawEvent read FOnAfterDrawButton
      write FOnAfterDrawButton;
    property OnBeforeDrawButton: TGrpButtonDrawEvent read FOnBeforeDrawButton
      write FOnBeforeDrawButton;
    property OnDrawButton: TGrpButtonDrawEvent read FOnDrawButton
      write SetOnDrawButton;
    property OnDrawIcon: TGrpButtonDrawIconEvent read FOnDrawIcon
      write SetOnDrawIcon;
    property OnDrawText: TGrpButtonDrawEvent read FOnDrawText write FOnDrawText;
  end;

implementation

uses GraphUtil;

{ TMDIButtonGroup }

procedure TMDIButtonGroup.AddButton;
var
  i: Integer;
  ae, de: PNotifyEvent;
begin
  if Assigned(AChild) then
  begin
    for i := 0 to Self.Items.Count - 1 do
      if TForm(Self.Items[i].Data) = AChild then
        Exit;
    with Self.Items.Add do
    begin
      Caption := AChild.Caption;
      Hint := AHint;
      ImageIndex := AImageIndex;
      Data := AChild;
    end;
    if Assigned(AChild.OnActivate) then
    begin
      new(ae);
      ae^ := AChild.OnActivate;
      FActivateList.Add(ae);
    end
    else
      FActivateList.Add(nil);
    if Assigned(AChild.OnDestroy) then
    begin
      new(de);
      de^ := AChild.OnDestroy;
      FDestroyList.Add(de);
    end
    else
      FDestroyList.Add(nil);
    AChild.Hint := AHint;
    AChild.OnActivate := ChildActivate;
    AChild.OnDestroy := ChildDestroy;

    Self.ItemIndex := Self.Items.Count - 1;
    Self.Invalidate;

    ScrollIntoView(Self.ItemIndex);
  end;
end;

function TMDIButtonGroup.CalcButtonsPerRow: Integer;
begin
  if gboFullSize in ButtonOptions then
    Result := 1
  else
  begin
    Result := ClientWidth div ButtonWidth;
    if Result = 0 then
      Result := 1;
  end;
end;

procedure TMDIButtonGroup.ChildActivate(Sender: TObject);
var
  i: Integer;
begin
  if not(Sender is TMDIButtonGroup) then
    for i := 0 to Self.Items.Count - 1 do
      if Self.Items[i].Data = Sender then
      begin
        Self.ItemIndex := i;
        Break;
      end;

  if (Self.ItemIndex > -1) then
  begin
    if Assigned(FActivateList[Self.ItemIndex]) then
      TNotifyEvent(FActivateList[Self.ItemIndex]^)
        (TForm(Self.Items[Self.ItemIndex].Data));
    ScrollIntoView(Self.ItemIndex);
  end;
end;

function TMDIButtonGroup.IndexOf(AForm: TForm): Integer;
begin
  for Result := 0 to Items.Count - 1 do
    if Items[Result].Data = AForm then
      Exit;
  Result := -1;
end;

procedure TMDIButtonGroup.DelButton(AChild: TForm);
var
  idx: Integer;
begin
  idx := IndexOf(AChild);
  try
    if (idx > -1) then
    begin
      FActivateList.Delete(idx);
      FDestroyList.Delete(idx);
      Items.Delete(idx);
    end;
    ItemIndex := GetChildIndex(TForm(Owner).ActiveMDIChild);
  except
  end;
end;

procedure TMDIButtonGroup.ChildDestroy(Sender: TObject);
var
  idx: Integer;
begin
  if not(Sender is TForm) then
    Exit;
  idx := IndexOf(TForm(Sender));
  try
    if (idx > -1) then
    begin
      if Assigned(FDestroyList[idx]) then
        TNotifyEvent(FDestroyList[idx]^)(TForm(Sender));
      FActivateList.Delete(idx);
      FDestroyList.Delete(idx);
      Items.Delete(idx);
    end;
    ItemIndex := GetChildIndex(TForm(Owner).ActiveMDIChild);
  except
  end;
end;

procedure TMDIButtonGroup.CloseAll;
var
  i, n: Integer;
begin
  n := TForm(Owner).MDIChildCount;
  for i := n - 1 downto 0 do
  begin
    TForm(Owner).MDIChildren[i].Close;
  end;
end;

constructor TMDIButtonGroup.Create(AOwner: TComponent);
begin
  inherited;

  FActivateList := TList.Create;
  FDestroyList := TList.Create;

  FCloseButtonMouseDownIndex:= -1;
  Self.BorderStyle := bsNone;
  Self.ButtonOptions := [gboGroupStyle, gboShowCaptions];
  Self.ShowHint := True;
end;

destructor TMDIButtonGroup.Destroy;
begin
  FActivateList.Free;
  FDestroyList.Free;
  PopupMenu := nil;
  inherited;
end;

procedure TMDIButtonGroup.DoItemClicked(const Index: Integer);
var
  child: TForm;
begin
  SendMessage(Application.MainForm.ClientHandle, WM_SETREDRAW, 0, 0);
  // отключаем пеpеpисовки окна у mainform
  try
    Self.ItemIndex := Index;
    if Self.ItemIndex > -1 then
    begin
      child := TForm(Self.Items[Self.ItemIndex].Data);
      SendMessage(child.Handle, WM_NCACTIVATE, WA_ACTIVE, 0);
      child.SetFocus;
      child.BringToFront;
      if child.WindowState = wsMinimized then
        child.WindowState := wsNormal;
    end;
    inherited;
    UpdateButton(Self.ItemIndex);
  finally
    SendMessage(Application.MainForm.ClientHandle, WM_SETREDRAW, 1, 0);
    // вкл  WM_SETREDRAW
    // и пеpеpисуем область rect mainform
    RedrawWindow(Application.MainForm.ClientHandle, nil, 0,
      RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_NOINTERNALPAINT)
  end;
end;

procedure TMDIButtonGroup.DrawButton(Index: Integer; Canvas: TCanvas;
  _Rect: TRect; State: TButtonDrawState);
var
  TextLeft, TextTop, i: Integer;
  RectHeight: Integer;
  ImgTop: Integer;
  TextOffset: Integer;
  FillColor: TColor;
  EdgeColor: TColor;
  InsertIndication: TRect;
  TextRect: TRect;
  OrgRect: TRect;
  Caption: string;
  CloseBtnSize: Integer;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
  CloseBtnRect: TRect;
begin
  if Assigned(FOnDrawButton) and (not(csDesigning in ComponentState)) then
    FOnDrawButton(Self, Index, Canvas, _Rect, State)
  else
  begin
    OrgRect := _Rect;
    if Assigned(FOnBeforeDrawButton) then
      FOnBeforeDrawButton(Self, Index, Canvas, _Rect, State);
    InflateRect(_Rect, -1, -1);

    if Length(FCloseButtonsRect) <> Self.Items.Count then
    begin
      SetLength(FCloseButtonsRect, Self.Items.Count);
      FCloseButtonMouseDownIndex := -1;

      for i := 0 to Length(FCloseButtonsRect) - 1 do
      begin
        FCloseButtonsRect[i] := Rect(0, 0, 0, 0);
      end;
    end;

    Canvas.Font.Color := clBtnText;
    if bdsHot in State then
    begin
      FillColor := FHotButtonColor;
      if bdsSelected in State then
        FillColor := GetShadowColor(FillColor, -10);
      EdgeColor := GetShadowColor(FillColor);
    end
    else if bdsSelected in State then
    begin
      FillColor := FSelectedButtonColor;
      EdgeColor := GetShadowColor(FillColor);
    end
    else
    begin
      FillColor := FRegularButtonColor;
      if (bdsFocused in State) then
        EdgeColor := GetShadowColor(FSelectedButtonColor)
      else
        EdgeColor := GetShadowColor(FillColor);
    end;

    Canvas.Brush.Color := FillColor;
    if FillColor <> clNone then
    begin
      Canvas.FillRect(_Rect);
      { Draw the edge outline }
      Canvas.Brush.Color := EdgeColor;
      Canvas.FrameRect(_Rect);
    end;

    if bdsFocused in State then
    begin
      InflateRect(_Rect, -1, -1);
      Canvas.FrameRect(_Rect);
    end;

    Canvas.Brush.Color := FillColor;

    TextLeft := _Rect.Left + 4;
    RectHeight := _Rect.Bottom - _Rect.Top;
    TextTop := _Rect.Top + (RectHeight - Canvas.TextHeight('Wg')) div 2;

    if gboFullSize in ButtonOptions then
      Inc(TextLeft, 4);

    if TextTop < _Rect.Top then
      TextTop := _Rect.Top;
    if bdsDown in State then
    begin
      Inc(TextTop);
      Inc(TextLeft);
    end;

    // draw Close Btn
    CloseBtnSize := 15;
    if InRange(Index, 0, Length(FCloseButtonsRect) - 1) then
    begin

      CloseBtnRect.Top := _Rect.Top + 2;
      CloseBtnRect.Right := _Rect.Right - 3;

      CloseBtnRect.Bottom := CloseBtnRect.Top + CloseBtnSize;
      CloseBtnRect.Left := CloseBtnRect.Right - CloseBtnSize;
      FCloseButtonsRect[Index] := CloseBtnRect;

      Canvas.FillRect(_Rect);

      if not UseThemes then
      begin
        if (FCloseButtonMouseDownIndex = Index) and FCloseButtonShowPushed then
          CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED
        else
          CloseBtnDrawState := DFCS_CAPTIONCLOSE;

        Windows.DrawFrameControl(Canvas.Handle, FCloseButtonsRect[Index],
          DFC_CAPTION, CloseBtnDrawState);
      end
      else
      begin
        Dec(FCloseButtonsRect[Index].Left);

        if (bdsHot in State) and (FCloseButtonShowHot) and
          (not FCloseButtonShowPushed) then
          CloseBtnDrawDetails := ThemeServices.GetElementDetails
            (twCloseButtonHot)
        else if (FCloseButtonMouseDownIndex = Index) and
          FCloseButtonShowPushed then
          CloseBtnDrawDetails := ThemeServices.GetElementDetails
            (twCloseButtonPushed)
        else
          CloseBtnDrawDetails := ThemeServices.GetElementDetails
            (twCloseButtonNormal);

        ThemeServices.DrawElement(Canvas.Handle, CloseBtnDrawDetails,
          FCloseButtonsRect[Index]);
      end;
    end;

    { прорисовка значка }
    TextOffset := 0;
    if Assigned(FOnDrawIcon) then
      FOnDrawIcon(Self, Index, Canvas, OrgRect, State, TextOffset)
    else if (Images <> nil) and (Items[Index].ImageIndex > -1) and
      (Items[Index].ImageIndex < Images.Count) then
    begin
      ImgTop := _Rect.Top + (RectHeight - Images.Height) div 2;
      if ImgTop < _Rect.Top then
        ImgTop := _Rect.Top;
      if bdsDown in State then
        Inc(ImgTop);
      Images.Draw(Canvas, TextLeft - 1, ImgTop, Items[Index].ImageIndex);
      TextOffset := Images.Width + 1;
    end;

    //
    if [bdsInsertLeft, bdsInsertTop, bdsInsertRight, bdsInsertBottom] * State
      <> [] then
    begin
      Canvas.Brush.Color := GetShadowColor(EdgeColor);
      InsertIndication := _Rect;
      if bdsInsertLeft in State then
      begin
        Dec(InsertIndication.Left, 2);
        InsertIndication.Right := InsertIndication.Left + 2;
      end
      else if bdsInsertTop in State then
      begin
        Dec(InsertIndication.Top);
        InsertIndication.Bottom := InsertIndication.Top + 2;
      end
      else if bdsInsertRight in State then
      begin
        Inc(InsertIndication.Right, 2);
        InsertIndication.Left := InsertIndication.Right - 2;
      end
      else if bdsInsertBottom in State then
      begin
        Inc(InsertIndication.Bottom);
        InsertIndication.Top := InsertIndication.Bottom - 2;
      end;
      Canvas.FillRect(InsertIndication);
      Canvas.Brush.Color := FillColor;
    end;

    // caption
    if gboShowCaptions in ButtonOptions then
    begin
      if FillColor = clNone then
        Canvas.Brush.Style := bsClear;

      //
      Inc(TextLeft, TextOffset);
      TextRect.Left := TextLeft;
      TextRect.Right := _Rect.Right - CloseBtnSize - 4;
      TextRect.Top := TextTop;
      TextRect.Bottom := _Rect.Bottom - 1;

      if Assigned(FOnDrawText) then
        FOnDrawText(Self, Index, Canvas, TextRect, State)
      else
      begin
        Caption := Items[Index].Caption;
        Canvas.TextRect(TextRect, Caption, [tfEndEllipsis]);
      end;
    end;

    if Assigned(FOnAfterDrawButton) then
      FOnAfterDrawButton(Self, Index, Canvas, OrgRect, State);
  end;
  Canvas.Brush.Color := Color; { восстановить цвет по умолчанию }
end;

function TMDIButtonGroup.GetActiveChild: TForm;
begin
  Result := GetChild(Self.ItemIndex);
end;

function TMDIButtonGroup.GetCaption(index: Integer): string;
begin
  if (index > -1) and (index < Self.Items.Count) then
    Result := Self.Items[index].Caption
  else
    Result := '';
end;

function TMDIButtonGroup.GetChild(index: Integer): TForm;
begin
  if (index > -1) and (index < Self.Items.Count) then
    Result := TForm(Self.Items[index].Data)
  else
    Result := nil;
end;

function TMDIButtonGroup.GetChildIndex(AChild: TForm): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Self.MDIChildCount - 1 do
    if Self.MDIChildren[i] = AChild then
    begin
      Result := i;
      Break;
    end;
end;

function TMDIButtonGroup.GetCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Self.Items.Count - 1 do
    if Assigned(Self.Items[i].Data) and
      (TObject(Self.Items[i].Data) is TForm) then
      Inc(Result);
end;

function TMDIButtonGroup.GetGlyph(index: Integer): Integer;
begin
  if (index > -1) and (index < Self.Items.Count) then
    Result := Self.Items[index].ImageIndex
  else
    Result := -1;
end;

function TMDIButtonGroup.GetHint(index: Integer): string;
begin
  if (index > -1) and (index < Self.Items.Count) then
    Result := Self.Items[index].Hint
  else
    Result := '';
end;

function TMDIButtonGroup.GetMinimized: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Self.Items.Count - 1 do
    if GetChild(i).WindowState = wsMinimized then
      Inc(Result);
end;

procedure TMDIButtonGroup.MinimizeAll;
var
  i, n: Integer;
begin
  n := TForm(Owner).MDIChildCount;
  for i := n - 1 downto 0 do
    TForm(Owner).MDIChildren[i].WindowState := wsMinimized;
  TForm(Owner).ArrangeIcons;
end;

procedure TMDIButtonGroup.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i: Integer;
begin
  inherited;
  FHotButton := Self.IndexOfButtonAt(X, Y);

  if FHotButton = -1 then
    Exit;

  FCloseButtonMouseDownIndex := -1;

  if Button = mbLeft then
  begin
    for i := 0 to Length(FCloseButtonsRect) - 1 do
    begin
      if PtInRect(FCloseButtonsRect[i], Point(X, Y)) then
      begin
        FCloseButtonMouseDownIndex := i;
        FCloseButtonShowPushed := True;
        Self.Repaint;
      end;
    end;
  end;
end;

procedure TMDIButtonGroup.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if (Button = mbLeft) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    if PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y)) then
    begin
      // ShowMessage('Button ' + IntToStr(FCloseButtonMouseDownIndex + 1) + ' pressed!');
      MDIChildren[FCloseButtonMouseDownIndex].Close;
      FCloseButtonShowPushed := false;
      FCloseButtonMouseDownIndex := -1;
    end;
  end;
end;

procedure TMDIButtonGroup.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);
var
  Inside: boolean;
begin
  inherited;

  FHotButton := Self.IndexOfButtonAt(X, Y);

  if FHotButton = -1 then
  begin
    FCloseButtonShowHot := false;
    Exit;
  end
  else
    FCloseButtonShowHot := True;

  if (ssLeft in Shift) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    Inside := PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex],
      Point(X, Y));
    if FCloseButtonShowPushed <> Inside then
    begin
      FCloseButtonShowPushed := Inside;
      Repaint;
    end;
  end;
end;

procedure TMDIButtonGroup.Resize;
var
  ButtonsPerRow: Integer;
  TotalRowsNeeded: Integer;
begin
  inherited;

  ButtonsPerRow := CalcButtonsPerRow;

  if FAutoSize then
  begin
    Windows.ShowScrollBar(Handle, SB_VERT, false);
    TotalRowsNeeded := Items.Count div ButtonsPerRow;
    if Items.Count mod ButtonsPerRow <> 0 then
      Inc(TotalRowsNeeded);
    Height := TotalRowsNeeded * ButtonHeight;
  end
  else
  begin
    Height := ButtonHeight;
    inherited;
  end;
end;

procedure TMDIButtonGroup.SetAutoSize(Value: boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    Resize;
    Invalidate;
  end;
end;

procedure TMDIButtonGroup.SetCaption(index: Integer; const Value: string);
begin
  if (index > -1) and (index < Self.Items.Count) then
    Self.Items[index].Caption := Value;
end;

procedure TMDIButtonGroup.SetGlyph(index: Integer; const Value: Integer);
begin
  if (index > -1) and (index < Self.Items.Count) then
    Self.Items[index].ImageIndex := Value;
end;

procedure TMDIButtonGroup.SetHint(index: Integer; const Value: string);
begin
  if (index > -1) and (index < Self.Items.Count) then
    Self.Items[index].Hint := Value;
end;

procedure TMDIButtonGroup.SetHotButtonColor(const Value: TColor);
begin
  if FHotButtonColor <> Value then
  begin
    FHotButtonColor := Value;
    Invalidate;
  end;
end;

procedure TMDIButtonGroup.SetOnDrawButton(const Value: TGrpButtonDrawEvent);
begin
  FOnDrawButton := Value;
  Invalidate;
end;

procedure TMDIButtonGroup.SetOnDrawIcon(const Value: TGrpButtonDrawIconEvent);
begin
  FOnDrawIcon := Value;
  Invalidate;
end;

procedure TMDIButtonGroup.SetRegularButtonColor(const Value: TColor);
begin
  if FRegularButtonColor <> Value then
  begin
    FRegularButtonColor := Value;
    Invalidate;
  end;
end;

procedure TMDIButtonGroup.SetSelectedButtonColor(const Value: TColor);
begin
  if FSelectedButtonColor <> Value then
  begin
    FSelectedButtonColor := Value;
    Invalidate;
  end;
end;

end.
