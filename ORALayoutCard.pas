unit ORALayoutCard;

interface

uses TypInfo, Classes, SysUtils, cxOI, cxGrid, cxGridDBDataDefinitions, cxGridCustomTableView,
  Controls, cxCheckBox, cxDBLookupComboBox, cxButtonEdit, ORALayoutColumnEdit, dxLayoutContainer,
  cxEdit, ORALayoutGrid, cxGridLayoutView, cxGridDBLayoutView, ORALayoutCustomize, DB,
  cxGridCustomView, ORANavigators, cxTextEdit, cxCurrencyEdit, cxCalendar, cxStyles, dxCore,
  cxCustomData, cxControls;

type
  TORACardColumn = class(TcxGridDBLayoutViewItem)
  private
    function getStringStyles: String;
    procedure setStringStyles(const Value: String);
    function getStringLayout: AnsiString;
    procedure setStringLayout(const Value: AnsiString);
  public
  published
    property StringStyles: String read getStringStyles write setStringStyles;
    property StringLayout: AnsiString read getStringLayout write setStringLayout;
  end;

  TORACardView = class(TcxGridDBLayoutView)
  private
    function getStringCardLayout: AnsiString;
    procedure setStringCardLayout(const Value: AnsiString);
  protected
    function GetNavigatorClass: TcxGridViewNavigatorClass; override;
  public
    function GetItemClass: TcxCustomGridTableItemClass; override;
  published
    property StringCardLayout: AnsiString read getStringCardLayout write setStringCardLayout;
  end;

  TORALayoutCard = class(TORATable)
  private
  protected
    function GetDefaultViewClass: TcxCustomGridViewClass; override;
  public
  end;

  TORACardColumnProperties = class(TORATableItemProperties)
  private
    function getLayoutOptions: TcxGridLayoutItem;
    function getColumn: TORACardColumn;
  public
    property Column: TORACardColumn read getColumn;
  published
    property LayoutItem: TcxGridLayoutItem read getLayoutOptions;
  end;

  TORAGridCardProperties = class(TORAGridProperties)

  end;

implementation

uses cxStorage, ORAStyles;

const
  cSignature: String = 'ORACardLayout';

  { TORALayoutCard }

function TORALayoutCard.GetDefaultViewClass: TcxCustomGridViewClass;
begin
  Result := TORACardView;
end;

{ TORACardColumnProperties }

function TORACardColumnProperties.getColumn: TORACardColumn;
begin
  Result := TORACardColumn(Component);
end;

function TORACardColumnProperties.getLayoutOptions: TcxGridLayoutItem;
begin
  Result := Column.LayoutItem;
end;

{ TORACardView }

function TORACardView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TORACardColumn;
end;

function TORACardView.GetNavigatorClass: TcxGridViewNavigatorClass;
begin
  Result := TORATableViewNavigator;
end;

function TORACardView.getStringCardLayout: AnsiString;
var
  AStream: TMemoryStream;
begin
  AStream := TMemoryStream.Create;
  try
    Container.StoreToStream(AStream, cSignature);
    Result := StreamToString(AStream);
  finally
    AStream.Free;
  end;
end;

procedure TORACardView.setStringCardLayout(const Value: AnsiString);
var
  AStream: TMemoryStream;
begin
  AStream := TMemoryStream.Create;
  try
    StringToStream(dxVariantToAnsiString(Value), AStream);
    AStream.Position := 0;
    Container.RestoreFromStream(AStream, cSignature);
  finally
    AStream.Free;
  end;
end;

{ TORACardColumn }

function TORACardColumn.getStringLayout: AnsiString;
var
  AStream: TMemoryStream;
begin
  AStream := TMemoryStream.Create;
  try
    AStream.WriteComponent(LayoutItem);
    Result := StreamToString(AStream);
  finally
    AStream.Free;
  end;
end;

function TORACardColumn.getStringStyles: String;
begin
  Result := styles2string(Styles);
end;

procedure TORACardColumn.setStringLayout(const Value: AnsiString);
var
  AStream: TMemoryStream;
begin
  AStream := TMemoryStream.Create;
  try
    StringToStream(dxVariantToAnsiString(Value), AStream);
    AStream.Position := 0;
    AStream.ReadComponent(LayoutItem);
  finally
    AStream.Free;
  end;
end;

procedure TORACardColumn.setStringStyles(const Value: String);
begin
  string2styles(Styles, Value);
end;

initialization

register_ORADataType('Карточки БД', TORAGridCardProperties, TORALayoutCard);
register_ORADataType('Колонка карточки', TORACardColumnProperties, TORACardColumn);

end.
