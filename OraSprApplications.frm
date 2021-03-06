ORALayoutForm
FldFormCaption0   Справочник приложений Oracle
FldWidth�
FldHeight�

FldEnd
ORALayoutFormTdxLayoutControlContainerVersiondxLayoutControl1Group_RootTdxLayoutGroupIsUserDefined	False
ParentName	    Index�	AlignHorz	ahClient	AlignVert	avClientWidth Height IsFloat	FalseCaption	    ShowCaption	FalseCaptionAlignHorz CaptionAlignVert CaptionLayoutTabCaptionRotate	FalseTabCaptionAlignmentTabCaptionPosition Hidden	TrueLayoutDirection	
ldVertical	ItemIndex Expanded	True
ShowBorder	FalseShowExpandButton	False dxLayoutControl1Item1TdxLayoutItemIsUserDefined	True
ParentName	dxLayoutControl1Group_RootIndex 	AlignHorz	ahParentManaged	AlignVert	avClientWidth Height IsFloat	FalseCaption	    ShowCaption	TrueCaptionAlignHorz CaptionAlignVertCaptionLayout  dxLayoutControl1Item2TdxLayoutItemIsUserDefined	True
ParentName	dxLayoutControl1Group1Index 	AlignHorz	ahParentManaged	AlignVert	avParentManagedWidth Height IsFloat	FalseCaption	    ShowCaption	TrueCaptionAlignHorz CaptionAlignVertCaptionLayout  dxLayoutControl1Group1TdxLayoutGroupIsUserDefined	True
ParentName	dxLayoutControl1Group_RootIndex	AlignHorz	ahParentManaged	AlignVert	avParentManagedWidth Height IsFloat	FalseCaption	   Новая группаShowCaption	FalseCaptionAlignHorz CaptionAlignVert CaptionLayoutTabCaptionRotate	FalseTabCaptionAlignmentTabCaptionPosition Hidden	FalseLayoutDirection	ldHorizontal	ItemIndex Expanded	True
ShowBorder	FalseShowExpandButton	False dxLayoutControl1Item3TdxLayoutItemIsUserDefined	True
ParentName	dxLayoutControl1Group1Index	AlignHorz	ahParentManaged	AlignVert	avParentManagedWidth Height IsFloat	FalseCaption	    ShowCaption	TrueCaptionAlignHorz CaptionAlignVertCaptionLayout  
Ctl
dxLayoutControl1Item1   Таблица БДTPF0	TORATabletblApplicationsLeftTopWidth�Height�TabOrder  
FldsrcSQLf  declare
  cMenuTable constant varchar2(50) := 'FRM_MENUS';
  vSQL varchar2(4000);
begin
  for cc in (select distinct p.owner from all_objects p where p.object_name = cMenuTable) loop
    if vSQL is not null then
      vSQL := vSQL || '
  union all
  ';
    end if;
    vSQL := vSQL || 'select ''' || cc.owner || ''' as owner, m.name as app_name, m.icon from ' || cc.owner || '.' ||
            cMenuTable || ' m where m.id = 0';
  end loop;
  if vSQL is null then
    vSQL := 'select null as owner, null as app_name, null as icon from dual where 1=2';
  end if;
  open :res_cursor for vSQL;
end;

FldIDFieldowner
FldOnNewRecord    
FldUpdatingTable    
FldOnColumnChanged    
Fld
OnDblClick    
FldStyles    

FldEnd
TPF0TORATableViewtblApplicationsORATableView1Navigator.Buttons.CustomButtons
ImageIndexZVisible  Navigator.Buttons.ImagesfrmMain.cxImageListFindPanel.DisplayMode
fpdmManualFindPanel.UseExtendedSyntax	DataController.Filter.OptionsfcoCaseInsensitive /DataController.Summary.DefaultGroupSummaryItems )DataController.Summary.FooterSummaryItems $DataController.Summary.SummaryGroups OptionsSelection.CellSelectOptionsView.CellAutoHeight	OptionsView.GroupByBox  TPF0TORATableColumn tblApplicationsORATableView1ICONDataBinding.FieldNameICONPropertiesClassNameTcxImagePropertiesProperties.GraphicClassNameTIconWidth8  

FldEnd
TPF0TORATableColumn!tblApplicationsORATableView1OWNERDataBinding.FieldNameOWNERWidthW  

FldEnd
TPF0TORATableColumn$tblApplicationsORATableView1APP_NAMEDataBinding.FieldNameAPP_NAMEWidth�  

FldEnd

Ctl
dxLayoutControl1Item2   =>?:0TPF0
TORAButtonbtnOkLeftTop�WidthKHeightCaptionOkModalResultOptionsImage.ImagesfrmMain.cxImageListTabOrder  
FldOnClickStart    
FldOnClickFinish    

FldEnd

Ctl
dxLayoutControl1Item3   =>?:0TPF0
TORAButton	btnCancelLeftQTop�WidthKHeightCancel	CaptionCancelModalResultOptionsImage.ImagesfrmMain.cxImageListTabOrder  
FldOnClickStart    
FldOnClickFinish    

FldEnd


CtlEnd
