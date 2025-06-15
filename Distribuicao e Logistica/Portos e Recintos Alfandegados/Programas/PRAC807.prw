#INCLUDE "PRAC807.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

Function PRAC808() 
	Local oBrowse
	Local oButton
	Local oColumn
	Local aIndex := {}
	Local aSeek  := {}
	Local cAlias2 := GetNextAlias()
	Local cAliasAGE := 'AGEN'
	Local aCamposAGE := {}
	Local oLayer := nil
	Local oTopGrid := nil
	Local aStruct := nil
	Local nMax := 0
	Local nStart := 0
	Local cCampo := ''
	Local aCols := {}
	Local aArrData := {}
	Local oSayDtInicial := nil
	Local oPanel := nil
	Local oTopGrid2 := nil
	Local oFont := nil
	Local oSay1 := nil
	Local oSay2 := nil
	Local oTGet01 := nil
	Local oTGet02 := nil
	Local cDataInicial := nil
	Local cDataFinal := nil
	Local oTButtonAdd := nil
	Local oTButtonOK  := nil
	Local oTButtonCancel  := nil
	Local cConsulta  := ''
	Private cAlias := GetNextAlias()
	Private oBrowseT := nil
	Private aArrAgen := {}
	Private oColumn1 := nil
	Private oColumn2 := nil
	Private oColumn3 := nil
	Private oColumn4 := nil
	Private cQuery := ""
	Private oDlg := nil
	
	if cdc_id <> ''	
		cQuery := "  select b.dc_id, CONVERT(VARCHAR,  c.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  c.paj_datahora_ini,108) as data_inicio, " 
		cQuery += "	CONVERT(VARCHAR,c.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,c.paj_datahora_fim,108)  as data_fim,  "
		cQuery += "	c.paj_id, c.pa_id, "
		cQuery += "	CONVERT(VARCHAR,  c.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  c.paj_datahora_ini,108) + ' - ' + CONVERT(VARCHAR,c.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,c.paj_datahora_fim,108)  as result_data, "
		cQuery += "   CONVERT(VARCHAR,  c.paj_datahora_ini,103) as data_dt_inicio, "
		cQuery += "   CONVERT(VARCHAR,  c.paj_datahora_ini,108) as horas_inicio, "
		cQuery += "  CONVERT(VARCHAR,  c.paj_datahora_fim,103) as data_dt_fim, "
		cQuery += "   CONVERT(VARCHAR,  c.paj_datahora_fim,108) as horas_fim, "
		cQuery += "   d.pa_bloqueado "
		cQuery += "			from tab_portal_agenda_janela c "
		cQuery += "            inner join tab_portal_agenda d "
		cQuery += "                 on d.pa_id = c.pa_id "
		cQuery += "            left join tab_portal_janela_capacidade b "
		cQuery += "                 on b.paj_id = c.paj_id "
		cQuery += "            left join tab_portal_operacoes a "
		cQuery += "                 on a.pjc_id = b.pjc_id "
		cQuery += "              where 1 = 1  "
		cQuery += "                and (( a.modal_id = '" + cModal_id + "' and a.op_id = " + cOperacao + " and a.sub_id =  " + cSubOperacao +  "  and b.dc_id = " + cdc_id + " ) or b.pjc_id is null ) "
	else
		cQuery := "  select 0 as dc_id, CONVERT(VARCHAR,  a.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  a.paj_datahora_ini,108) as data_inicio, " 
		cQuery += "	CONVERT(VARCHAR,a.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,a.paj_datahora_fim,108)  as data_fim,  "
		cQuery += "	a.paj_id, a.pa_id, "
		cQuery += "	CONVERT(VARCHAR,  a.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  a.paj_datahora_ini,108) + ' - ' + CONVERT(VARCHAR,a.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,a.paj_datahora_fim,108)  as result_data, "
		cQuery += "   CONVERT(VARCHAR,  a.paj_datahora_ini,103) as data_dt_inicio, "
		cQuery += "   CONVERT(VARCHAR,  a.paj_datahora_ini,108) as horas_inicio, "
		cQuery += "  CONVERT(VARCHAR,  a.paj_datahora_fim,103) as data_dt_fim, "
		cQuery += "   CONVERT(VARCHAR,  a.paj_datahora_fim,108) as horas_fim, "
		cQuery += "   d.pa_bloqueado "
		cQuery +=  "		from tab_portal_agenda_janela a               "
		cQuery +=  "        left join tab_portal_janela_capacidade b "
		cQuery +=  "          on b.paj_id = a.paj_id "
		cQuery +=  "        left join tab_portal_agenda d "                
		cQuery +=  "           on d.pa_id = a.pa_id where 1=1 and b.pjc_id  is null "	
	endif

    cQuery += "   and  d.pa_bloqueado = 0 "
	cQuery += "   and ('" + SDBDate(Date(),time()) + "' >= d.pa_dt_liberacao_ini "
	cQuery += "   and  '" + SDBDate(Date(),time()) + "' <= d.pa_dt_liberacao_fim ) "
    
	if (alltrim(dtoc(dData))  = '/  /' )
		ldDataVazio := .T.
		if (alltrim(dtoc(dData2))  != '/  /' )
       	dData := dData2
		else
       	dData := date()
    	endif
	endif
    
	if (alltrim(dtoc(dData2))  = '/  /' )
    	ldData2Vazio := .T.
    	dData2 := date()
	endif
    
	if (alltrim(dtoc(dData)) <> '') .and. (alltrim(dtoc(dData2)) <> '')
		cConsulta := cQuery + " and paj_datahora_ini >= '" +  SDBDate(alltrim(dtoc(dData)),'00:00:00.000') + "' and paj_datahora_fim <= '" + SDBDate(alltrim(dtoc(dData2)),'23:59:59.999') + "' order by paj_datahora_ini asc "
	endif
    
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cConsulta),cAlias, .F., .T.)

	While !(cAlias)->(Eof())
      Aadd(aArrAgen,{;  	
     	               (cAlias)->data_inicio,;
     	               (cAlias)->data_fim,;
     	               (cAlias)->result_data,;
     	               (cAlias)->paj_id,;
     	               (cAlias)->pa_id,;
     	               (cAlias)->data_dt_inicio,;
     	               (cAlias)->horas_inicio,;
     	               (cAlias)->data_dt_fim,;
     	               (cAlias)->horas_fim,;
     	               (cAlias)->pa_bloqueado,;
     	               (cAlias)->dc_id;
     	               })
      (cAlias)->(DbSkip())
   EndDo
   (cAlias)->(DbCloseArea())
      
	DEFINE MSDIALOG oDlg Title STR0001 FROM 0,0 TO 600,800 PIXEL
	
	oLayer := FWLayer():new()
	oLayer:Init(oDlg,.F.)
	
	oLayer:addLine('LinhaSuperior',20,.F.,)
	oLayer:addLine('LinhaInferior',76,.F.,)
	oLayer:addLine('Rodape',4,.F.,)
	
	oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
	oLayer:addColumn('ColInferior',100,.F.,'LinhaInferior')
	oLayer:addColumn('ColRodape',100,.F.,'Rodape')
	
	oLayer:addWindow('ColSuperior','C1_Win01','Data',100,.F.,.F.,,'LinhaSuperior',)
	oLayer:addWindow('ColInferior','C1_Win02','Agenda',100,.F.,.F.,,'LinhaInferior',)
	
	oTopGrid   := oLayer:getwinpanel('ColInferior','C1_Win02','LinhaInferior')
	oTopGrid2   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')

	oFont := TFont():New('Arial',,15,.T.)	
	oSay1 := TSay():Create(oTopGrid2,{||STR0002},4 ,0,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)
	@ 2,35 MSGET oData VAR dData PICTURE "@D" SIZE 50, 10 OF oTopGrid2 PIXEL HASBUTTON
	
	oSay2 := TSay():Create(oTopGrid2,{||'até:'},4 ,85,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)      
	@ 2,100 MSGET oData VAR dData2 PICTURE "@D" SIZE 50, 10 OF oTopGrid2 PIXEL HASBUTTON
		
	oTButtonAdd := TButton():Create( oTopGrid2, 3, 156,STR0003           ,{||A807FILT()}   ,40,10,,,,.T.,,,,,,)
	oTButtonCancel := TButton():Create(  oLayer:getColPanel('ColRodape','Rodape'),0,300,'Cancelar' ,{||A807CANC()},40,10,,,,.T.,,,,,,)
	oTButtonOK      := TButton():Create(  oLayer:getColPanel('ColRodape','Rodape'),0,350,'Confirmar',{||A807OK()},40,10,,,,.T.,,,,,,)

	oBrowseT := FWBrowse():New(oTopGrid)
	oBrowseT:SetDataArray()
	oBrowseT:SetArray(aArrAgen)
	oBrowseT:SetDoubleClick({||A807OK()})

	oColumn1 := FWBrwColumn():New()
	oColumn1:SetData(  &("{ || aArrAgen[oBrowseT:At(),1]}") )
	oColumn1:SetTitle('Data/hora inicial')
	oColumn1:SetSize(30)
	ocolumn1:setforecolor(3788455)
	oBrowseT:SetColumns({oColumn1})


	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData( &("{ || aArrAgen[oBrowseT:At(),2]}")  )
	oColumn2:SetTitle('Data/hora final')
	oColumn2:SetSize(30)
	oColumn2:setautosize(.T.)
	oBrowseT:SetColumns({oColumn2})

	oBrowseT:Activate()
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return

static function A807OK()
	Local lRet := .T.
	
	if (dData > dData2)
		alert(STR0004)
		return .F.
	endif
	
	if (empty(aArrAgen) = .F.) .and. (alltrim(str(aArrAgen[oBrowseT:At(),11])) <> '' .and. alltrim(str(aArrAgen[oBrowseT:At(),11])) <> '0')
		cdc_id := alltrim(str(aArrAgen[oBrowseT:At(),11]))
		if val_operando(cOperacao,cSubOperacao,alltrim(str(aArrAgen[oBrowseT:At(),4])), nQuantidade, 'F') = .F.
			return .F.
		endif
	endif
	
	if (empty(aArrAgen) = .F.)
		paj_id := alltrim(str(aArrAgen[oBrowseT:At(),4]))
		pa_id := alltrim(str(aArrAgen[oBrowseT:At(),5]))
		cResul_Agen :=  alltrim(aArrAgen[oBrowseT:At(),3])
		
		dt_agen_ini := alltrim(aArrAgen[oBrowseT:At(),6])
		hr_agen_ini := alltrim(aArrAgen[oBrowseT:At(),7])
		dt_agen_fim := alltrim(aArrAgen[oBrowseT:At(),8])
		hr_agen_fim := alltrim(aArrAgen[oBrowseT:At(),9])
		
		pa_bloqueado := alltrim(aArrAgen[oBrowseT:At(),10])
		oDlg:end()
	else
		paj_id := '0'
		pa_id := '0'
		cResul_Agen :=  ''
		
		dt_agen_ini := '/  /'
		hr_agen_ini := ':'
		dt_agen_fim := '/  /'
		hr_agen_fim := ':'
		
		pa_bloqueado := '0'
		oDlg:end()
	endif
	
return lRet

static function A807CANC()

	if ldDataVazio = .T.
		dData = ctod('/  /') 
	end
		
	if ldData2Vazio = .T.
		dData2 = ctod('/  /') 
	end

    lCancel := .T.	
	oDlg:end()		
return 


static function A807FILT()
	Local cFiltro := ''
	Local selectFiltro := ''

	if (dData > dData2)
		alert('Data inicial deve ser menor ou iguam à data final.')
	else
		if (alltrim(dtoc(dData)) <> '') .and. (alltrim(dtoc(dData2)) <> '')
			cFiltro := " and paj_datahora_ini >= '" + SDBDate(alltrim(dtoc(dData)),'00:00:00.000') + "' and paj_datahora_fim <= '" + SDBDate(alltrim(dtoc(dData2)),'23:59:59.999') + "' order by paj_datahora_ini asc "
		endif	

		selectFiltro :=  cQuery + cFiltro

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,selectFiltro),cAlias, .F., .T.)
		dbselectarea(cAlias)

		oBrowseT:DeActivate(.T.)

		(cAlias)->(dbgotop())
		aArrAgen := {}
		While (cAlias)->(!Eof())
			Aadd(aArrAgen,{;      	
	     		(cAlias)->data_inicio,;
	     	    (cAlias)->data_fim,;
	     	    (cAlias)->result_data,;
	     	    (cAlias)->paj_id,;
	     	    (cAlias)->pa_id,;
	     	    (cAlias)->data_dt_inicio,;
	     	    (cAlias)->horas_inicio,;
	     	    (cAlias)->data_dt_fim,;
	     	    (cAlias)->horas_fim,;
	     	    (cAlias)->pa_bloqueado,;
     	        (cAlias)->dc_id;
			})
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())

		oBrowseT:SetDataArray()
		oBrowseT:SetArray(aArrAgen)		
		oBrowseT:activate()
	endif

return
