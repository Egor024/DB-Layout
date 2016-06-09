unit LayoutORAData;

interface

uses
  Classes, DB, Ora, DBAccess, LayoutData, ORALayout, dxBar, cxStyles, cxGraphics, OdacVcl, ORARoles;

type
  TOraLayoutQuery = class;

  TOraLayoutSession = class(TOraSession, ILayoutSessionInterface)
  private
    procedure ConnectionErrorEvent(Sender: TObject; E: EDAError; var Fail: boolean);
    function GetConnectString: String;
    procedure SetConnectString(pValue: String);
    function getSchema: String;
    procedure setSchema(const pValue: String);
    function getLoginPrompt: boolean;
    procedure setLoginPrompt(const pValue: boolean);
    function getUserName: String;
    procedure setUserName(const pValue: String);
    function get_session_id: String;
    function get_session_info(const SID: String): String;
    function get_user_roles: TORADBRoles;
    function get_user_FIO: String;
    function getLayoutQueryClass: TDataSetClass;
    procedure change_password(const pOldPassword: String; const pNewPassword: String);
    function clone: TComponent;
    function loadORAForm(const p_name: String; const p_version: String; const p_initPLSQL: String;
      const p_DeveloperMode: boolean = False): TfrmORALayout;
    procedure saveORAForm(const p_form: TfrmORALayout);
    procedure set_ORAForm_notes(const p_form_name: string; const p_notes: String);
    function get_ORAForm_notes(const p_form_name: string): String;

    function get_user_param(const p_form_name: String; p_param_name: String): String;
    procedure set_user_param(const p_form_name: String; const p_param_name: String;
      const p_value: String);
    procedure get_user_bparam(const pStream: TStream; const p_form_name: String;
      p_param_name: String);
    procedure set_user_bparam(const p_form_name: String; const p_param_name: String;
      const pStream: TStream);
    procedure clear_user_params(const p_form_name: String);

    procedure loadORARoles;
    procedure loadORAMenuItems(const p_menu_ID: Longint; const pBarManager: TdxBarManager);
    procedure saveORAMenuItems(const p_menu_ID: Longint; const pBarManager: TdxBarManager);

    procedure loadORAStyles(const pStyleRepositoryID: Longint;
      const pStyleRepository: TcxStyleRepository);
    procedure saveORAStyles(const pStyleRepositoryID: Longint;
      const pStyleRepository: TcxStyleRepository);

    procedure loadORAImageList(const pImageListID: Longint; const pImageList: TcxImageList);
    procedure saveORAImageList(const pImageListID: Longint; const pImageList: TcxImageList);

    procedure save_XLS2DB(const p_def: String; const p_xls_file: String; const p_sheet: String);
    procedure paste2DB(const p_def1: string; const p_delimiter: String = #9);

  public
    constructor Create(Owner: TComponent); override;
  end;

  TOraLayoutQuery = class(TOraQuery, ILayoutQueryInterface)
  private
  protected
    function getSQL: TStrings;
    function GetParamCount: word;
    function getParams: TParams;
    function GetParamCheck: boolean;
    procedure SetParamCheck(const Value: boolean);
    function GetRowsProcessed: integer;
    function getLayoutSession: TComponent;
    procedure setLayoutSession(const pSession: TComponent);
    function GetAutoCommit: boolean;
    procedure SetAutoCommit(pValue: boolean);
    function GetNonBlocking: boolean;
    procedure SetNonBlocking(pValue: boolean);
    function GetLockMode: TLockMode;
    procedure SetLockMode(Value: TLockMode);
    function GetKeyFields: string;

    function GetUpdatingTable: string;
    function GetReadOnly: boolean;

    function getAfterExecute: TAfterExecuteEvent;
    procedure setAfterExecute(const pProc: TAfterExecuteEvent);
    function getAfterFetch: TAfterFetchEvent;
    procedure setAfterFetch(const pProc: TAfterFetchEvent);

    procedure setBlobParam(const pIndex: Longint; const pValue: WideString);
  public
    constructor Create(Owner: TComponent); override;
    procedure Execute; override;
  end;

implementation

Uses Windows, Variants, Forms, Utilities, SysUtils, OraClasses, Dialogs, Clipbrd, cxClasses,
  TypInfo,
  MemData, ExcelApp, ComObj, Ole2, ShowProgress, PassChange;

const
  cSprApplicationsSQL: string = 'declare' + #13#10 +
    '  cMenuTable constant varchar2(50) := ''FRM_MENUS'';' + #13#10 + '  vSQL varchar2(4000);' +
    #13#10 + 'begin' + #13#10 +
    '  for cc in (select distinct p.owner from all_objects p where p.object_name = cMenuTable) loop'
    + #13#10 + '    if vSQL is not null then' + #13#10 + '      vSQL := vSQL || ''' + #13#10 +
    '  union all' + #13#10 + '  '';' + #13#10 + '    end if;' + #13#10 +
    '    vSQL := vSQL || ''select '''''' || cc.owner || '''''' as owner, m.name as app_name, m.icon from '' || cc.owner || ''.'' ||'
    + #13#10 + '            cMenuTable || '' m where m.id = 0'';' + #13#10 + '  end loop;' + #13#10
    + '  if vSQL is null then' + #13#10 +
    '    vSQL := ''select null as owner, null as app_name, null as icon from dual where 1=2'';' +
    #13#10 + '  end if;' + #13#10 + '  open :res_cursor for vSQL;' + #13#10 + 'end;';

procedure TOraLayoutSession.change_password(const pOldPassword: String; const pNewPassword: String);
begin
  if pOldPassword <> Password then raise Exception.Create('Неверен действующий пароль');
  ChangePassword(pNewPassword);
end;

function TOraLayoutSession.clone: TComponent;
var
  vRes: TOraLayoutSession;
begin
  if not Connected then raise Exception.Create('Клонируемая сессия не активна');
  vRes := TOraLayoutSession.Create(self);
  Result := vRes;
  with vRes do begin
    AutoCommit := self.AutoCommit;
    Options := self.Options;
    Server := self.Server;
    Schema := self.Schema;
    Username := self.Username;
    Password := self.Password;
    LoginPrompt := False;
    Connected := True;
  end;
end;

procedure TOraLayoutSession.ConnectionErrorEvent(Sender: TObject; E: EDAError; var Fail: boolean);
begin
  if E.ErrorCode = 28001 then Fail := not PassChange.ChangePassword;
end;

constructor TOraLayoutSession.Create(Owner: TComponent);
begin
  inherited;
  AutoCommit := True;
  Options.DateLanguage := 'RUSSIAN';
  Options.Direct := True;
  LoginPrompt := True;
  Schema := '';
  OnError := ConnectionErrorEvent;
end;

procedure TOraLayoutSession.paste2DB(const p_def1: string; const p_delimiter: String = #9);
begin
  if not Clipboard.HasFormat(CF_TEXT) then exit;
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin ' + Schema + '.clipboard2tmptable(:p_def1,:p_clpbrd,:p_delimiter); end;';
      Params.ParamByName('p_def1').AsString := p_def1;
      Params.ParamByName('p_delimiter').AsString := p_delimiter;
      with TOraParams(Params).ParamByName('p_clpbrd') do begin
        ParamType := ptInput;
        DataType := ftOraBlob;
        with AsOraBlob do begin
          OCISvcCtx := self.OCISvcCtx;
          CreateTemporary(ltBlob);
          AsWideString := Clipboard.AsText + #13#10;
          WriteLob;
        end;
      end;
      Execute;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.loadORARoles;
begin
  allOraDBRoles.Clear;
  allOraDBRoles.Add(TORADBRole.Create(Developer_ORADBRole, 'dev', 'Разработчик'));
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select id, brief, name from ' + Schema +
        '.V_SPR_ROLES t where id <> 0 order by id';
      try
        open;
      except
      end;
      while not EOF do begin
        allOraDBRoles.Add(TORADBRole.Create(FieldByName('id').AsInteger,
          FieldByName('brief').AsString, FieldByName('name').AsString));
        next;
      end;
    finally
      Free;
    end;
end;

type
  TReaderAccess = class(TReader);

procedure TOraLayoutSession.loadORAStyles(const pStyleRepositoryID: Longint;
  const pStyleRepository: TcxStyleRepository);
var
  aStream: TStream;
begin
  if Schema = '' then exit;
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select t.* from ' + Schema + '.FRM_STYLES t where t.id = :ID';
      Params.ParamByName('ID').AsInteger := pStyleRepositoryID;
      try
        open;
      except
      end;
      if not EOF then begin
        aStream := CreateBlobStream(FieldByName('style'), bmRead);
        try
          if aStream.Size > 0 then
            with TReader.Create(aStream, 2048) do
              try
                pStyleRepository.Clear;
                ReadRootComponent(pStyleRepository);
              finally
                Free;
              end;
        finally
          aStream.Free;
        end;
      end;
      Close;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.saveORAStyles(const pStyleRepositoryID: Longint;
  const pStyleRepository: TcxStyleRepository);
var
  aStream: TStream;
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select t.*, t.rowid from ' + Schema + '.FRM_STYLES t where t.id = :ID';
      Params.ParamByName('ID').AsInteger := pStyleRepositoryID;
      open;
      if EOF then Insert
      else Edit;
      FieldByName('ID').AsInteger := pStyleRepositoryID;
      aStream := CreateBlobStream(FieldByName('style'), bmWrite);
      try
        with TWriter.Create(aStream, 2048) do
          try
            WriteRootComponent(pStyleRepository);
          finally
            Free;
          end;
      finally
        aStream.Free;
      end;
      Post;
      Close;
      Session.Commit;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.loadORAImageList(const pImageListID: Longint;
  const pImageList: TcxImageList);
var
  vImageList: TComponent;
begin
  if Schema = '' then exit;
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select t.images from ' + Schema + '.FRM_MENUS t where t.id = :ID';
      Params.ParamByName('ID').AsInteger := pImageListID;
      try
        open;
      except
      end;
      if not EOF then begin
        with CreateBlobStream(FieldByName('images'), bmRead) do
          try
            if Size <> 0 then begin
              vImageList := ReadComponent(nil);
              try
                pImageList.Clear;
                pImageList.Assign(vImageList);
              finally
                vImageList.Free;
              end;
            end;
          finally
            Free;
          end;
      end;
      Close;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.saveORAImageList(const pImageListID: Longint;
  const pImageList: TcxImageList);
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select t.ID, t.images, t.rowid from ' + Schema + '.FRM_MENUS t where t.id = :ID';
      Params.ParamByName('ID').AsInteger := pImageListID;
      open;
      if EOF then Insert
      else Edit;
      FieldByName('ID').AsInteger := pImageListID;
      with CreateBlobStream(FieldByName('images'), bmWrite) do
        try
          WriteComponent(pImageList);
        finally
          Free;
        end;
      Post;
      Close;
      Session.Commit;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.loadORAMenuItems(const p_menu_ID: Longint;
  const pBarManager: TdxBarManager);
var
  aClass: TPersistentClass;
  aItem, aOldItem: TComponent;
  aStream: TStream;
  iLinksOwner: IdxBarLinksOwner;
  I: Longint;
  chk: boolean;
  function get_item_by_name(const pName: String): TComponent;
  begin
    with pBarManager do begin
      Result := GetItemByName(pName);
      if Result = nil then Result := BarByComponentName(pName);
    end;
  end;
  procedure read_links(const pStream: TStream; const pItemLinks: TdxBarItemLinks);
  var
    aItemName: String;
    aLink: TdxBarItemLink;
    aItem: TdxBarItem;
  begin
    aLink := nil;
    with pItemLinks do
      while Count > 0 do items[0].Free;

    with TReaderAccess(TReader.Create(pStream, 2048)) do
      try
        ReadListBegin;
        while not EndOfList do
          with pItemLinks do begin
            aItemName := ReadString;
            if pItemLinks = nil then aItem := nil
            else aItem := pBarManager.GetItemByName(aItemName);
            if aItem <> nil then aLink := Add(aItem);
            ReadListBegin;
            while not EndOfList do
              if aItem <> nil then ReadProperty(aLink)
              else SkipProperty;
            ReadListEnd;
          end;
        ReadListEnd;
      finally
        Free;
      end;
  end;

begin
  with pBarManager do
    repeat
      chk := False;
      for I := 0 to itemCount - 1 do begin
        chk := (items[I].ClassName <> 'TdxBarButton') And (items[I].ClassName <> 'TdxBarSubItem')
          and (items[I].ClassName <> 'TcxBarEditItem');
        if chk then begin
          items[I].Free;
          break;
        end;
      end;
    until not chk;

    if Schema = '' then exit;
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select m.name, m.icon from ' + Schema + '.FRM_MENUS m' + #13#10 +
        ' where m.id = :menu_id';
      Params.ParamByName('menu_id').AsInteger := p_menu_ID;
      try
        open;
        mainCaption := FieldByName('name').AsString;
        aStream := CreateBlobStream(FieldByName('icon'), bmRead);
        try
          if aStream.Size > 0 then Application.Icon.LoadFromStream(aStream);
        finally
          aStream.Free;
        end;
      except
        on E: Exception do begin
          // ShowMessage(E.Message);
          exit;
        end;
      end;
      if Developer_ORADBRole in userRoles then
          SQL.Text := 'select mi.type_name, mi.name, mi.properties' + #13#10 + '  from ' + Schema +
          '.FRM_MENU_ITEMS mi' + #13#10 + ' where mi.menu_id = :menu_id'
      else begin
        SQL.Text := 'select mi.type_name, mi.name, mi.properties' + #13#10 + '  from ' + Schema +
          '.FRM_MENU_ITEMS mi' + #13#10 + ' where mi.menu_id = :menu_id' + #13#10 +
          '   and (mi.type_name=''TdxBar'' or bitand(mi.db_roles, :u_db_roles) <> 0)';
        Params.ParamByName('u_db_roles').AsInteger := integer(userRoles);
      end;
      Params.ParamByName('menu_id').AsInteger := p_menu_ID;
      try
        open;
      except
        on E: Exception do begin
          showmessage(E.Message);
          exit;
        end;
      end;
      while not EOF do begin
        aClass := GetClass(FieldByName('type_name').AsString);
        if (aClass <> nil) And (aClass.InheritsFrom(TcxCustomComponent)) then begin
          aOldItem := get_item_by_name(FieldByName('name').AsString);
          if (aOldItem <> nil) { And (aOldItem.ClassType = aClass) } then
              aItem := TdxBarItem(aOldItem)
          else begin
            aOldItem.Free;
            if aClass = TdxBar then aItem := pBarManager.Bars.Add
            else aItem := pBarManager.AddItem(TdxBarItemClass(aClass));
            aItem.Name := FieldByName('name').AsString;
          end;
          aStream := CreateBlobStream(FieldByName('properties'), bmRead);
          try
            with TReader.Create(aStream, 2048) do
              try;
                try;
                  ReadRootComponent(aItem);
                except
                  on E: Exception do
                      showmessage('loadORAMenuItems (' + aItem.Name + '):' + E.Message);
                end;
              finally
                Free;
              end;
          finally
            aStream.Free;
          end;
        end;
        next;
      end;
      Close;
      SQL.Text := 'select mi.name, mi.links' + #13#10 + '  from ' + Schema + '.FRM_MENU_ITEMS mi' +
        #13#10 + ' where mi.menu_id = :menu_id' + #13#10 + '   and mi.links is not null';
      open;
      while not EOF do begin
        aItem := get_item_by_name(FieldByName('name').AsString);
        if (aItem <> nil) and aItem.GetInterface(IdxBarLinksOwner, iLinksOwner) And
          (iLinksOwner.GetItemLinks <> nil) then begin
          aStream := CreateBlobStream(FieldByName('links'), bmRead);
          try
            read_links(aStream, iLinksOwner.GetItemLinks);
          finally
            aStream.Free;
          end;
        end;
        next;
      end;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.saveORAMenuItems(const p_menu_ID: Longint;
  const pBarManager: TdxBarManager);
var
  I: Longint;
  PropInfo: PPropInfo;
  aStream: TStream;
  procedure write_links(const pStream: TStream; const pItemLinks: TdxBarItemLinks);
  var
    II: Longint;
  begin
    with TWriter.Create(pStream, 2048) do
      try
        with pItemLinks do begin
          WriteListBegin;
          for II := 0 to Count - 1 do
            if items[II].Item <> nil then begin
              WriteString(items[II].Item.Name);
              WriteListBegin;
              WriteProperties(items[II]);
              WriteListEnd;
            end;
          WriteListEnd;
        end;
      finally
        Free;
      end;
  end;
  procedure write_item(const pFields: TFields; const pComponent: TcxCustomComponent);
  var
    iLinksOwner: IdxBarLinksOwner;
  begin
    with TOraDataSet(pFields.DataSet) do begin
      with pComponent do
        if Name <> '' then begin
          Params.ParamByName('name').AsString := Name;
          open;
          if EOF then Insert
          else Edit;
          FieldByName('menu_id').AsInteger := p_menu_ID;
          FieldByName('type_name').AsString := ClassName;
          FieldByName('name').AsString := Name;
          PropInfo := GetPropInfo(pComponent, 'DB_Roles');
          if PropInfo <> nil then
              FieldByName('DB_ROLES').AsInteger := GetOrdProp(pComponent, PropInfo)
          else FieldByName('DB_ROLES').AsVariant := Null;
          aStream := CreateBlobStream(FieldByName('properties'), bmWrite);
          try
            with TWriter.Create(aStream, 2048) do
              try
                WriteRootComponent(pComponent);
              finally
                Free;
              end;
          finally
            aStream.Free;
          end;
          if pComponent.GetInterface(IdxBarLinksOwner, iLinksOwner) And
            (iLinksOwner.GetItemLinks <> nil) and (iLinksOwner.GetItemLinks.Count <> 0) then begin
            aStream := CreateBlobStream(FieldByName('links'), bmWrite);
            try
              write_links(aStream, iLinksOwner.GetItemLinks);
            finally
              aStream.Free;
            end;
          end
          else FieldByName('links').AsVariant := Null;
          Post;
          Close;
        end;
    end;
  end;

begin
  try
    with TOraLayoutQuery(stdLayoutQuery(self)) do
      try
        SQL.Text := 'update ' + Schema +
          '.FRM_MENU_ITEMS mi set mi.type_name = ''updating...'' where mi.menu_id = :menu_id';
        Params.ParamByName('menu_id').AsInteger := p_menu_ID;
        Execute;
      finally
        Free;
      end;
    with TOraLayoutQuery(stdLayoutQuery(self)) do
      try
        LocalConstraints := False;
        Options.TemporaryLobUpdate := True;
        SQL.Text := 'select mi.*, mi.rowid' + #13#10 + '  from ' + Schema + '.FRM_MENU_ITEMS mi' +
          #13#10 + ' where mi.menu_id = :menu_id' + #13#10 + '   And upper(mi.name) = upper(:name)';
        Params.ParamByName('menu_id').AsInteger := p_menu_ID;
        with pBarManager do begin
          for I := 0 to itemCount - 1 do write_item(Fields, items[I]);
          for I := 0 to Bars.Count - 1 do write_item(Fields, Bars[I]);
        end;
      finally
        Free;
      end;
    with TOraLayoutQuery(stdLayoutQuery(self)) do
      try
        SQL.Text := 'delete from ' + Schema +
          '.FRM_MENU_ITEMS mi where mi.type_name = ''updating...'' And mi.menu_id = :menu_id';
        Params.ParamByName('menu_id').AsInteger := p_menu_ID;
        Execute;
        Session.Commit;
      finally
        Free;
      end;
  except
    on E: Exception do begin
      Rollback;
      raise Exception.Create(E.Message);
    end;
  end;
end;

function TOraLayoutSession.loadORAForm(const p_name: String; const p_version: String;
  const p_initPLSQL: String; const p_DeveloperMode: boolean = False): TfrmORALayout;
var
  vStream: TMemoryStream;
  vVersion: String;
  vName: String;
begin
  Result := nil;
  if Schema = '' then exit;
  vVersion := p_version;
  vName := p_name;
  vStream := TMemoryStream.Create();
  try
    if p_name = SprApplicationFormName then begin
      with TResourceStream.Create(HInstance, 'OraSprApplications', RT_RCDATA) do try
        SaveToStream(vStream);
        vVersion := 'default';
      finally
        Free;
      end;
    end
    else
      with TOraLayoutQuery(stdLayoutQuery(self)) do
        try
          SQL.Text := 'begin ' + Schema +
            '.pkg_forms.get_layout(:pr_name, :pr_code, :r_layout); end;';
          Params.ParamByName('pr_name').AsString := p_name;
          Params.ParamByName('pr_code').AsString := vVersion;
          with Params.ParamByName('r_layout') do begin
            ParamType := ptOutput;
            DataType := ftOraBlob;
          end;
          Execute;
          vVersion := Params.ParamByName('pr_code').AsString;
          vName := Params.ParamByName('pr_name').AsString;
          Params.ParamByName('r_layout').AsOraBlob.SaveToStream(vStream);
        finally
          Free;
        end;
    if vVersion <> '' then begin
      Result := TfrmORALayout.Create(Application);
      vStream.Position := 0;
      with Result do
        try
          teName.EditValue := vName;
          teCode.EditValue := vVersion;
          with Controller do begin
            RestoreFromStream(vStream);
            initControls(p_initPLSQL);
          end;
        finally
          DeveloperMode := p_DeveloperMode;
        end;
    end;
  finally
    vStream.Free;
  end;
end;

procedure TOraLayoutSession.saveORAForm(const p_form: TfrmORALayout);
var
  vStream: TMemoryStream;
begin
  if p_form.teName.EditValue = SprApplicationFormName then exit;

  vStream := TMemoryStream.Create();
  try
    p_form.Controller.StoreToStream(vStream);
    vStream.Position := 0;
    with TOraLayoutQuery(stdLayoutQuery(self)) do
      try
        SQL.Text := 'begin ' + Schema +
          '.pkg_forms.upsert_layout(:p_name,:p_code,:p_layout); commit; end;';
        Params.ParamByName('p_name').AsString := p_form.teName.EditValue;
        Params.ParamByName('p_code').AsString := p_form.teCode.EditValue;
        with Params.ParamByName('p_layout') do begin
          ParamType := ptInput;
          DataType := ftOraBlob;
          with AsOraBlob do begin
            OCISvcCtx := Session.OCISvcCtx;
            CreateTemporary(ltBlob);
            LoadFromStream(vStream);
            WriteLob;
          end;
        end;
        Execute;
      finally
        Free;
      end;
  finally
    vStream.Free;
  end;
end;

procedure TOraLayoutSession.SetConnectString(pValue: String);
begin
  Server := pValue;
end;

procedure TOraLayoutSession.setLoginPrompt(const pValue: boolean);
begin
  inherited LoginPrompt := pValue;
end;

procedure TOraLayoutSession.setSchema(const pValue: String);
begin
  inherited Schema := pValue;
end;

procedure TOraLayoutSession.setUserName(const pValue: String);
begin
  inherited Username := pValue;
end;

procedure TOraLayoutSession.set_ORAForm_notes(const p_form_name: string; const p_notes: String);
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin ' + Schema + '.pkg_forms.set_notes(:p_name,:p_notes); commit; end;';
      Params.ParamByName('p_name').AsString := p_form_name;
      Params.ParamByName('p_notes').AsString := p_notes;
      Execute;
    finally
      Free;
    end;
end;

function TOraLayoutSession.GetConnectString: String;
begin
  Result := Server;
end;

function TOraLayoutSession.getLayoutQueryClass: TDataSetClass;
begin
  Result := TOraLayoutQuery;
end;

function TOraLayoutSession.getLoginPrompt: boolean;
begin
  Result := inherited LoginPrompt;
end;

function TOraLayoutSession.getSchema: String;
begin
  Result := inherited Schema;
end;

function TOraLayoutSession.get_session_info(const SID: String): String;
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'select s.CLIENT_INFO from V$USER_SESSION s where s.sid=:P_ID';
      Params.ParamByName('p_ID').AsString := SID;
      try
        Active := True;
      except
      end;
      if not EOF then Result := FieldByName('CLIENT_INFO').AsString
      else Result := '';
    finally
      Free;
    end;
end;

function TOraLayoutSession.getUserName: String;
begin
  Result := inherited Username;
end;

function TOraLayoutSession.get_ORAForm_notes(const p_form_name: string): String;
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin :vNotes := ' + Schema + '.pkg_forms.get_notes(:p_name); end;';
      Params.ParamByName('vNotes').AsString := '';
      Params.ParamByName('p_name').AsString := p_form_name;
      Execute;
      Result := Params.ParamByName('vNotes').AsString;
    finally
      Free;
    end;
end;

function TOraLayoutSession.get_session_id: String;
begin
  Result := DLookUp(self, 'select sys_context(''USERENV'', ''SID'') from dual');
end;

procedure TOraLayoutSession.save_XLS2DB(const p_def: String; const p_xls_file: String;
  const p_sheet: String);
var
  vWS: OleVariant;
  vData: Variant;
  II, I: integer;
begin
  vWS := getXLSWorksheet(p_xls_file, p_sheet, True);
  vData := vWS.UsedRange.Value;
  if not VarIsEmpty(vData) then
    with TfrmProgress.Create(Application) do
      try
        Progress.Properties.Min := VarArrayLowBound(vData, 1);
        Progress.Properties.Max := VarArrayHighBound(vData, 1);
        Show;
        with TOraLayoutQuery(stdLayoutQuery(self)) do
          try
            SQL.Text := 'select t.*, rowid from tmp_xls_import t';
            CachedUpdates := True;
            open;
            for I := VarArrayLowBound(vData, 1) to VarArrayHighBound(vData, 1) do begin
              Progress.Position := I;
              Progress.Properties.Text := IntToStr(I) + '/' + IntToStr(VarArrayHighBound(vData, 1));
              Progress.Repaint;
              Append;
              Fields[0].AsString := p_def;
              Fields[1].AsInteger := I;
              for II := 1 to Fields.Count - 3 do begin
                if (II >= VarArrayLowBound(vData, 2)) And (II <= VarArrayHighBound(vData, 2)) then
                    Fields[1 + II].AsString := VarToStr(vData[I, II])
              end;
              Post;
              if I mod 100 = 0 then CommitUpdates;
            end;
            CommitUpdates;
            Session.Commit;
          finally
            Free;
          end;
      finally
        Free;
      end;
  if not vWS.Application.Visible then vWS.Application.Quit;

end;

function TOraLayoutSession.get_user_param(const p_form_name: String; p_param_name: String): String;
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin :result := ' + Schema +
        '.pkg_common.get_user_param(:p_form_name, :p_param_name); end;';
      with Params do begin
        ParamByName('result').AsString := '';
        ParamByName('p_form_name').AsString := p_form_name;
        ParamByName('p_param_name').AsString := p_param_name;
        Execute;
        Result := ParamByName('result').AsString;
      end;
    finally
      Free;
    end;
end;

function TOraLayoutSession.get_user_roles: TORADBRoles;
var
  vRoles: Variant;
begin
  Result := [];
  vRoles := DLookUp(mainSessionComponent, 'select u.APP_ROLES from ' + Schema +
    '.v_spr_users u where login = user');
  if Utilities.VarIsNumeric(vRoles) then
      Result := TORADBRoles(integer(VarAsType(vRoles, varInteger)));
end;

procedure TOraLayoutSession.set_user_param(const p_form_name: String; const p_param_name: String;
  const p_value: String);
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin ' + Schema +
        '.pkg_common.set_user_param(:p_form_name, :p_param_name, :p_value); end;';
      with Params do begin
        ParamByName('p_form_name').AsString := p_form_name;
        ParamByName('p_param_name').AsString := p_param_name;
        ParamByName('p_value').AsString := p_value;
        Execute;
      end;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.clear_user_params(const p_form_name: String);
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin ' + Schema + '.pkg_common.clear_user_params(:p_form_name); end;';
      Params.ParamByName('p_form_name').AsString := p_form_name;
      Execute;
    finally
      Free;
    end;
end;

procedure TOraLayoutSession.get_user_bparam(const pStream: TStream; const p_form_name: String;
  p_param_name: String);
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin :result := ' + Session.Schema +
        '.pkg_common.get_user_bparam(:p_form_name, :p_param_name); end;';
      with Params do begin
        ParamByName('p_form_name').AsString := p_form_name;
        ParamByName('p_param_name').AsString := p_param_name;
        with ParamByName('result') do begin
          ParamType := ptOutput;
          DataType := ftOraBlob;
          with AsOraBlob do begin
            OCISvcCtx := Session.OCISvcCtx;
            CreateTemporary(ltBlob);
            Execute;
            SaveToStream(pStream);
          end;
        end;
      end;
    finally
      Free;
    end;
end;

function TOraLayoutSession.get_user_FIO: String;
begin
  Result := VarToStr(DLookUp(mainSessionComponent, 'select u.FIO from ' + Schema +
    '.v_spr_users u where login = user'));
end;

procedure TOraLayoutSession.set_user_bparam(const p_form_name: String; const p_param_name: String;
  const pStream: TStream);
begin
  with TOraLayoutQuery(stdLayoutQuery(self)) do
    try
      SQL.Text := 'begin ' + Session.Schema +
        '.pkg_common.set_user_bparam(:p_form_name, :p_param_name, :p_value); end;';
      with Params do begin
        ParamByName('p_form_name').AsString := p_form_name;
        ParamByName('p_param_name').AsString := p_param_name;
        with ParamByName('p_value') do begin
          ParamType := ptInput;
          DataType := ftOraBlob;
          with AsOraBlob do begin
            OCISvcCtx := Session.OCISvcCtx;
            CreateTemporary(ltBlob);
            LoadFromStream(pStream);
            WriteLob;
          end;
        end;
        Execute;
      end;
    finally
      Free;
    end;
end;

{ TOraLayoutQuery }

constructor TOraLayoutQuery.Create(Owner: TComponent);
begin
  inherited;
  AutoCommit := False;
  Options.RequiredFields := False;
  Options.TemporaryLobUpdate := True;
end;

procedure TOraLayoutQuery.Execute;
begin
  inherited;
end;

function TOraLayoutQuery.getAfterExecute: TAfterExecuteEvent;
begin
  Result := AfterExecute;
end;

function TOraLayoutQuery.getAfterFetch: TAfterFetchEvent;
begin
  Result := TAfterFetchEvent(AfterFetch);
end;

function TOraLayoutQuery.GetAutoCommit: boolean;
begin
  Result := inherited AutoCommit;
end;

function TOraLayoutQuery.GetKeyFields: string;
begin
  Result := inherited KeyFields;
end;

function TOraLayoutQuery.getLayoutSession: TComponent;
begin
  Result := Session;
end;

function TOraLayoutQuery.GetLockMode: TLockMode;
begin
  Result := LayoutData.TLockMode( inherited LockMode);
end;

function TOraLayoutQuery.GetNonBlocking: boolean;
begin
  Result := inherited NonBlocking;
end;

function TOraLayoutQuery.GetParamCheck: boolean;
begin
  Result := inherited ParamCheck;
end;

function TOraLayoutQuery.GetParamCount: word;
begin
  Result := inherited ParamCount;
end;

function TOraLayoutQuery.getParams: TParams;
begin
  Result := inherited Params;
end;

function TOraLayoutQuery.GetReadOnly: boolean;
begin
  Result := inherited ReadOnly;
end;

function TOraLayoutQuery.GetRowsProcessed: integer;
begin
  Result := inherited RowsProcessed;
end;

function TOraLayoutQuery.getSQL: TStrings;
begin
  Result := inherited SQL;
end;

function TOraLayoutQuery.GetUpdatingTable: string;
begin
  Result := inherited UpdatingTable;
end;

procedure TOraLayoutQuery.setAfterExecute(const pProc: TAfterExecuteEvent);
begin
  inherited AfterExecute := pProc;
end;

procedure TOraLayoutQuery.setAfterFetch(const pProc: TAfterFetchEvent);
begin
  inherited AfterFetch := DBAccess.TAfterFetchEvent(pProc);
end;

procedure TOraLayoutQuery.SetAutoCommit(pValue: boolean);
begin
  inherited AutoCommit := pValue;
end;

procedure TOraLayoutQuery.setBlobParam(const pIndex: integer; const pValue: WideString);
begin
  with Params[pIndex] do begin
    DataType := ftOraBlob;
    with AsOraBlob do begin
      if (Session = nil) And (mainSessionComponent is TOraLayoutSession) then
          OCISvcCtx := TOraLayoutSession(mainSessionComponent).OCISvcCtx
      else OCISvcCtx := Session.OCISvcCtx;
      CreateTemporary(ltBlob);
      AsWideString := Clipboard.AsText + #13#10;
      WriteLob;
    end;
  end;
end;

procedure TOraLayoutQuery.setLayoutSession(const pSession: TComponent);
begin
  if pSession is TOraLayoutSession then Session := TOraLayoutSession(pSession);
end;

procedure TOraLayoutQuery.SetLockMode(Value: TLockMode);
begin
  inherited LockMode := Ora.TLockMode(Value);
end;

procedure TOraLayoutQuery.SetNonBlocking(pValue: boolean);
begin
  inherited NonBlocking := pValue;
end;

procedure TOraLayoutQuery.SetParamCheck(const Value: boolean);
begin
  inherited ParamCheck := Value;
end;

initialization

Classes.RegisterClass(TOraLayoutSession);
LayoutData.defaultSessionClass := TOraLayoutSession;

finalization

Classes.UnRegisterClass(TOraLayoutSession);

end.
