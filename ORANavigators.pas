unit ORANavigators;

interface

  uses cxInplaceContainer, cxGridTableView, cxGridCustomTableView;

type

  TORAControlNavigator = class(TcxControlNavigator)
  protected
    function GetNavigatorButtonsClass: TcxExtEditingControlNavigatorButtonsClass; override;
  end;
  TORAControlNavigatorButtons = class(TcxExtEditingControlNavigatorButtons)
  protected
    function IsButtonVisibleByDefault(AIndex: Integer): Boolean; override;
  end;

  TORATableViewNavigator = class(TcxGridTableViewNavigator)
  protected
    function GetNavigatorButtonsClass: TcxGridViewNavigatorButtonsClass; override;
  end;
  TORATableViewNavigatorButtons = class(TcxGridTableViewNavigatorButtons)
  protected
    function IsButtonVisibleByDefault(AIndex: Integer): Boolean; override;
  end;


implementation

uses cxNavigator;

const
  cNavigatorButtonVisibility: array [0 .. NavigatorButtonCount - 1] of Boolean = (False, False,
    False, False, False, False, True, False, True, False, True, True, True, False, False, False);

{ TORAControlNavigator }

function TORAControlNavigator.GetNavigatorButtonsClass: TcxExtEditingControlNavigatorButtonsClass;
begin
  Result := TORAControlNavigatorButtons;
end;

{ TORAControlNavigatorButtons }

function TORAControlNavigatorButtons.IsButtonVisibleByDefault(AIndex: Integer): Boolean;
begin
  Result := cNavigatorButtonVisibility[AIndex];
end;

{ TORATableViewNavigator }

function TORATableViewNavigator.GetNavigatorButtonsClass: TcxGridViewNavigatorButtonsClass;
begin
  Result := TORATableViewNavigatorButtons;
end;

{ TORATableViewNavigatorButtons }

function TORATableViewNavigatorButtons.IsButtonVisibleByDefault(AIndex: Integer): Boolean;
begin
  Result := cNavigatorButtonVisibility[AIndex];
end;

end.
