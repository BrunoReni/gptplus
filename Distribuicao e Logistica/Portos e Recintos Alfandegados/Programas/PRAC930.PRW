#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC930.CH"

/*/{Protheus.doc} PRAC930
@author   Felipe Machado de Oliveira
@version  P12
@since    02/08/2012
@obs      2.2.18 b) Justificativa de alterações
/*/
Function PRAC930()
	Local oDlg      := nil
	Local aCoors    := FWGetDialogSize(oMainWnd)
	Local oLayer    := nil
	Local oPanel    := nil	
	Local oBrowse   := nil
	Local aFields       := {}
	Private cSelectReal := ''
	Private cSelectAlte := ''	
	Private cAlias      := ''
	Private aStruct     := {}
	Private aStructDesc := {}
	
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]
	
		oLayer := FWLayer():new()
      	oLayer:init(oDlg,.F.)    
      	oLayer:addColumn('Col01',100,.F.)
      	oLayer:addWindow('Col01','C1_Win01',STR0001,100,.F.,.F.,,,)
      	//oLayer:addWindow('Col01','C1_Win02',''     , 5,.F.,.F.,,,)
      	
		oPanel  := oLayer:getWinPanel('Col01','C1_Win01')
		      	
					 //Campo  , Descricao                 , Tipo, Tamanho , Alias, Mascara  , Nil , Zoom          , Validacao , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002 , "C" , 20      , nil  , nil      , nil , "C931ZOOMM(o)" , {|xConteud| C931VALID1(xConteud)}, nil})
		Aadd(aFields, {"P2"  , STR0003 , "D" , 10      , nil  , nil      , nil , nil           , nil                             , nil})
		Aadd(aFields, {"P3"  , STR0004 , "D" , 10      , nil  , nil      , nil , nil           , nil                             , nil})

		cAlias := SCTBTMPG()	
		oBrowse := SCBROWSE(oPanel, cAlias, aFields)

		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)

		oBrowse:AddFilter(STR0005 , "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' ", .T., .T.,nil,.T., aFilParser, '0')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C931FILTER(oBrowse,oLayer)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)      	
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	SDelTb(cAlias)
return

Static Function C931FILTER(oBrowse,oLayer)
	Local oFilter       := oBrowse:FWFilter()
	Local aFilter       := nil
	Local cMsg          := ""
	Local cInsert       := ""		
	Local cSelect       := " select "	
	Local nI            := 0
	Local cTabela       := ""
	Local cQtdAlterados  := "  "
	Local cQtdRealizados := "  "
	
	aFilter := oFilter:GetFilter(.T.)

	if (!C931GFields(aFilter, @cMsg, @cTabela, @cSelect))
		if (!SEmpty(cMsg))
			Alert(cMsg)		
		endif		
		return
	endif	
	
	cInsert := "insert into "+SGetDBOwner()+cAlias
	cInsert += cSelect

	TcSqlExec(cInsert)
	TcRefresh(cAlias) 
	
	(cAlias)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAlias,cAlias,.T.,.F.)
	
	nColSize := Len(oBrowse:aColumns)
	for nI := 1 to nColSize
		oBrowse:DelColumn(nI)
	next
	
	nColSize := Len(aStruct)

	for nI := 1 to nColSize
		oColumn := nil

		cCampo := STransType(aStruct[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDesc[nI][1]   )
		oColumn:SetSize(  aStructDesc[nI][2]   )

		oBrowse:SetColumns({oColumn})
	next

	oBrowse:UpdateBrowse()
		
	cQtdAlterados  := C930RETQTD(cSelectAlte)
	cQtdRealizados := C930RETQTD(cSelectReal)

	oLayer:setWinTitle('Col01','C1_Win01',STR0001+'        ('+ STR0015 + ': ' + cQtdAlterados + ' | ' + STR0016 + ': '  + cQtdRealizados+')' )	
	
return
	
static function C931GFields(aFilter, cMsg, cTabela, cSelect)
	Local cDe         := ""
	Local cAte        := ""	
	Local nCols       := 0
	Local cFirstField := ""
	
	if (aFilter == nil .OR. empty(aFilter))
		cMsg := STR0006
		return .F.
	endif
	
	cTabela := aFilter[1][4][3][1]	
	cDe     := aFilter[1][4][6][1]
	cAte    := aFilter[1][4][9][1]
	
	if SEmpty(cTabela) .OR. SEmpty(cDe) .OR. SEmpty(cAte)
		cMsg := STR0006
		return .F.
	endif

	do case
		case cTabela == "tab_cesv"
			cSelect += "cesv_id, "
			cFirstField := "cesv_id"
			nCols := 4			

		case cTabela == "tab_lote"
			cSelect += "lote_id, "
			cFirstField := "lote_id" 
			nCols := 4			

		case cTabela == "tab_lote_item"
			cSelect += "lote_id, litem_numero, "
			cFirstField := "lote_id"
			nCols := 5			

		case cTabela == "tab_usuarios"
			cSelect += "usu_id, "
			cFirstField := "usu_id"
			nCols := 4
		
		case cTabela == "tab_balanca"
			cSelect += "a.bal_id, "
			cFirstField := "a.bal_id"
			nCols := 4
		
		case cTabela == "tab_di_item"
			cSelect += "dsai_id, "
			cFirstField := "dsai_id"
			nCols := 4

	endcase
	
	C931CTMP(cTabela,nCols)

	cSelectReal := " select count(*) "+;
	                 "   from sara_log.."+STrim(cTabela)+;
	                 "  where log_datahora between '" + STrim(SDBDate(cDe, "00:00:00")) + "' and '" + STrim(SDBDate(cAte, "23:59:59")) + "' "
	   
   if  ((cTabela <> 'tab_balanca') .and. (cTabela <> 'tab_di_item'))   
	 cSelect +=  " IsNull(convert(varchar(200),log_justificativa), ' '),"+;
                " IsNull(convert(varchar(20),log_datahora,103)++ ' ' ++"+;
                "        convert(varchar(20),log_datahora,108), ' '),"+;
                " IsNull(convert(varchar, "+;       
                "          case when len(log_usuario) = 12 "+;
                "          then substring(log_usuario,2,3) + '.' + substring(log_usuario,5,3)+'.'+substring(log_usuario,8,3)+'-'+substring(log_usuario,11,2) "+;
                "          else log_usuario end "+;	  		           	  		           	  		           
                "         ), ' ') as cpf_formatado, "+; 
                " ' ' as D_E_L_E_T, ROW_NUMBER() OVER(ORDER BY "+cFirstField+") AS R_E_C_N_O_"+;
                " from sara_log.." + STrim(cTabela) + " where log_datahora between '" + STrim(SDBDate(cDe, "00:00:00")) + "' and '" + STrim(SDBDate(cAte, "23:59:59")) + "' and log_operacao = 'U' "+;
                " and IsNull(log_justificativa,'') <> '' "
     cSelectAlte := cSelectReal + " and log_operacao = 'U' and IsNull(log_justificativa,'') <> '' "
   else
     if cTabela <> 'tab_di_item'
       cSelect +=" IsNull(convert(varchar(200),b.bal_justificativa), ' '),"+;
                 " IsNull(convert(varchar(20),log_datahora,103)++ ' ' ++"+;
                 "        convert(varchar(20),log_datahora,108), ' '),"+;
                 " IsNull(convert(varchar, "+;       
                 "          case when len(log_usuario) = 12 "+;
                 "          then substring(log_usuario,2,3) + '.' + substring(log_usuario,5,3)+'.'+substring(log_usuario,8,3)+'-'+substring(log_usuario,11,2) "+;
                 "          else log_usuario end "+;	  		           	  		           	  		           
                 "         ), ' ') as cpf_formatado, "+; 
                 " ' ' as D_E_L_E_T, ROW_NUMBER() OVER(ORDER BY "+cFirstField+") AS R_E_C_N_O_"+;
                 " from sara_log.." + STrim(cTabela) +" a left join tab_balanca_compl b on b.cesv_id = a.cesv_id   and b.bal_id  = a.bal_id "+; 
                 " where log_datahora between '" + STrim(SDBDate(cDe, "00:00:00")) + "' and '" + STrim(SDBDate(cAte, "23:59:59")) + "' and log_operacao = 'U' "+;
                 " and IsNull(b.bal_justificativa,'') <> '' "
      
       cSelectReal := " select count(*) "+;
                      "   from sara_log.."+STrim(cTabela)+" a left join tab_balanca_compl b on b.cesv_id = a.cesv_id and b.bal_id  = a.bal_id "+;
                      "  where log_datahora between '" + STrim(SDBDate(cDe, "00:00:00")) + "' and '" + STrim(SDBDate(cAte, "23:59:59")) + "' "
       
       cSelectAlte := cSelectReal + " and log_operacao = 'U' and IsNull(b.bal_justificativa,'') <> '' "
       
                      
     else
       cSelect +=" IsNull(convert(varchar(200),dsai_justif_retifica), ' '),"+;
                 " IsNull(convert(varchar(20),log_datahora,103)++ ' ' ++"+;
                 "        convert(varchar(20),log_datahora,108), ' '),"+;
                 " IsNull(convert(varchar, "+;       
                 "          case when len(log_usuario) = 12 "+;
                 "          then substring(log_usuario,2,3) + '.' + substring(log_usuario,5,3)+'.'+substring(log_usuario,8,3)+'-'+substring(log_usuario,11,2) "+;
                 "          else log_usuario end "+;	  		           	  		           	  		           
                 "         ), ' ') as cpf_formatado, "+; 
                 " ' ' as D_E_L_E_T, ROW_NUMBER() OVER(ORDER BY "+cFirstField+") AS R_E_C_N_O_"+;
                 " from sara_log.." + STrim(cTabela) + " where log_datahora between '" + STrim(SDBDate(cDe, "00:00:00")) + "' and '" + STrim(SDBDate(cAte, "23:59:59")) + "' and log_operacao = 'U' "+;
                 " and IsNull(dsai_justif_retifica,'') <> '' "
       cSelectAlte := cSelectReal + " and log_operacao = 'U' and IsNull(dsai_justif_retifica,'') <> '' "
     end if
   end if		
return .T.

Function C931VALID1(xConteud)
	Local lRet := SValTable(xConteud)
		
	if lRet
		return .T. 
	else
		Alert(STR0007)
		return .F.
	endif	

return

Function C931ZOOMM(oObj)
	Local aZoom    := {}
	Local aRetZoom := {}
	
	aZoom    := SZoomTable()
	aRetZoom := PRAC938(aZoom)

	if !SEmpty(aRetZoom)
		oObj:cText := aRetZoom[1]
	else
		oObj:cText := nil
	endif
return 

Static Function C931CTMP(cTabela,nCols)
	Local i
	
	aStruct := {}
	for i := 1 to nCols
		Aadd(aStruct, {"CP"+STransType(i) ,"C", 200 ,0})		
	next

	aStructDesc := {}
	do case 
		case AllTrim(cTabela) == 'tab_cesv'
			Aadd(aStructDesc, {STR0008 , 15})
		
		case AllTrim(cTabela) == 'tab_lote'
			Aadd(aStructDesc, {STR0009 , 15})
		
		case AllTrim(cTabela) == 'tab_lote_item'
			Aadd(aStructDesc, {STR0009 , 15})
			Aadd(aStructDesc, {STR0010 , 15})				
	
		case AllTrim(cTabela) == 'tab_usuarios'
			Aadd(aStructDesc, {STR0011 , 15})
		
		case AllTrim(cTabela) == 'tab_balanca'
			Aadd(aStructDesc, {'Pesagem' , 15})
			
		case AllTrim(cTabela) == 'tab_di_item'
			Aadd(aStructDesc, {'Documento de saída' , 15})
			
	endcase
		
//	Aadd(aStructDesc, {STR0012 ,  5})
	Aadd(aStructDesc, {STR0013 , 50})
	Aadd(aStructDesc, {STR0014 , 15})
	Aadd(aStructDesc, {STR0011 , 15})	
	
	SDelTb(cAlias)
	SCriaTb(cAlias, aStruct)	
return

Static Function C930RETQTD(cQuery)
	Local cAliasT := GetNextAlias()	
	Local cQtd := ''
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)		
	dbSelectArea(cAliasT)
		
	(cAliasT)->(DbGoTop())
	
	cQtd := cValtoChar((cAliasT)->(Fieldget(1)))	
	
	(cAliasT)->(dbCloseArea())				
	
return cQtd
