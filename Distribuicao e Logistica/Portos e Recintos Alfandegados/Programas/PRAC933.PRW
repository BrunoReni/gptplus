
#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC933.CH"


/*/{Protheus.doc} PRAC933
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    17/07/2012
@obs      2.18 d) Log de acesso ao sistema
/*/
Function PRAC933()
	Local oDlg       := nil                       //Janela
	Local aFields    := {}                        //Campos de pesquisa
	Local oPanel     := nil                       //Painel
	Local oLayer     := nil                       //Layout
	Local aFilParser := {}                        //Configuração dos filtros
	Local aCoors     := FWGetDialogSize(oMainWnd) //Coordenada da janela
	Local oBrowse    := nil
	Local oBrowseFiltro    := nil
	Local oBrowseResultado := nil
	Local nI         := 0
	Local nMax       := 0
	Local aSeek      := {}
	Local aIndex     := {}

	Private cAliasTbF := SGetNAlias()              //Tabela temporária
	Private cAliasTbR := SGetNAlias()              //Tabela temporária
	Private nColSize  := 0                         //Quantidade de registros
	Private nColSizeR := 0                         //Quantidade de registros
	Private nTipoDoc := '-1'
	Private aStructDesc
	Private aStruct
	Private aStructDR
	Private aStructR
	Private cUsuPesq := ''
	Private nLog     := 1
	
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

        oLayer := FWLayer():new() //Cria uma camada na janela
        oLayer:init(oDlg,.F.)
        oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
        oLayer:addWindow('Col01','C1_Win01',STR0001,50 /*tamanho em %*/,.T.,.F.,,,)
        oLayer:addWindow('Col01','C1_Win02',STR0026,50 /*tamanho em %*/,.T.,.T.,,,)

        oPanelFiltro  := oLayer:getWinPanel('Col01','C1_Win01')
        oPanelResultado := oLayer:getWinPanel('Col01','C1_Win02')
		//Adiciona no array os campos de filtro da tela
						//Campo, Descricao   , Tipo, Tamanho, Alias, Mascara            , Nil, Zoom            , Validacao                               , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "C" , 20     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P2"  , STR0003     , "C" , 15     , nil  , ""                 , nil, "C933ZOOMP(o, 1)", {|xConteud, o| C933VLPESS(xConteud, o)}  , nil})
		Aadd(aFields, {"P3"  , STR0005     , "D" , 20     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P4"  , STR0006     , "D" , 20     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P5"  , STR0007     , "C" ,  1     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P6"  , "Opcao"     , "C" ,  1     , nil  , ""                 , nil, nil             , nil                                     , nil})

		C933CTB()
		C933CTBR()

		//Cria um componente de browse no window
		oBrowseFiltro := SCBROWSE(oPanelFiltro, cAliasTbF, aFields)
		oBrowseResultado := SCBROWSE(oPanelResultado, cAliasTbR, nil)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","1",@aFilParser)
		SAddFilPar("P6","==","0",@aFilParser)
		//Cria um filtro
		oBrowseFiltro:AddFilter(STR0027, "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5=='1' .AND. P6=='0'", .F., .F.,nil,.T., aFilParser, '0')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","0",@aFilParser)
		SAddFilPar("P6","==","0",@aFilParser)
		//Cria um filtro
		oBrowseFiltro:AddFilter(STR0028, "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5=='0' .AND. P6=='0'", .F., .F.,nil,.T., aFilParser, '1')

		oBrowseFiltro:SetChange({|| C933CHANGE(oBrowseFiltro, oBrowseResultado)})

		oBrowseFiltro:Activate()
		DES_FIL_BW(oBrowseFiltro)//Desabilita edicao filtros
		oBrowseFiltro:oFWFilter:SetExecute({||C933FILTER(oBrowseFiltro, oBrowseResultado)})
		oBrowseFiltro:oFWFilter:FilterBar(nil,.F.,.F.)

       oBrowseResultado:Activate()
       DES_FIL_BW(oBrowseResultado)//Desabilita edicao filtros
	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTbF)
	SDelTb(cAliasTbR)
Return

static function C933CHANGE(oBrowseFiltro, oBrowseResultado)
    Local cUsuario
    Local dDataIni
    Local dDataFin
    Local cParam
    Local cObservacao
    Local cArray := {'',''}
    
    //verifica se o registro clicado é de portal WEB
    

    cUsuario := Alltrim(STrim((cAliasTbF)->(FieldGet(1))))

    cUsuario := Strim(cUsuario)

    if SEmpty(cUsuario) == .F.
	    cUsuario := STrim('c' + cUsuario)
	    dDataIni := STrim((cAliasTbF)->(FieldGet(3)))
	    dDataFin := STrim((cAliasTbF)->(FieldGet(4)))
	    
	    If AllTrim(dDataFin) == ''
	        dDataFin := DtoC(Date())+' '+ Time()
	    EndIf
	    
	    cObservacao := STrim((cAliasTbF)->(FieldGet(5)))
	     
	    If ((STrim((cAliasTbF)->(FieldGet(5)))) <> '')
	    	cArray := StrTokArr(cObservacao,'-')
	    EndIf
	    
	    nLog := 1
	    
	    If len(cArray) > 1
		    If (UPPER(AllTrim(cArray[2])) == 'PORTAL')
		        nLog := 2
		    EndIf
	    EndIf

	    dDataIni := substr(dDataIni,7,4)+"-"+substr(dDataIni,4,2)+"-"+substr(dDataIni,1,2)+" "+substr(dDataIni,12,8)+".000"
	    dDataFin := substr(dDataFin,7,4)+"-"+substr(dDataFin,4,2)+"-"+substr(dDataFin,1,2)+" "+substr(dDataFin,12,8)+".000"

	    cParam := "'" + cUsuario + "','" + dDataIni + "', '" +  dDataFin + "'"

	    cParam += ",'"+SGetDBOwner()+cAliasTbR+"'"

	    C933GridR(oBrowseResultado, cParam, oBrowseFiltro)
	 else
	    C933GridR(oBrowseResultado, "null,null,null,'"+SGetDBOwner()+cAliasTbR+"'", oBrowseFiltro)
	 endif

return

Static Function C933FILTER(oBrowseFiltro, oBrowseResultado)
	Local cQuery      := "proc_s_acesso_sistema_w "
	Local cParams     := ""
	Local cParamsR    := ""
	Local nMax        := 0
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowseFiltro:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''

	if !SVALFILTRO(oFilter)
		alert(STR0022)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)
	
	if (!C933GF(aFilter, @cParams, @cMsg, @cParamsR))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif

	cQuery += " " + cParams

	TcSqlExec(cQuery)
	TcRefresh(cAliasTbF) 

	(cAliasTbF)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAliasTbF,cAliasTbF,.T.,.F.)

	nColSize := Len(oBrowseFiltro:aColumns)

	for nI := 1 to nColSize
		oBrowseFiltro:DelColumn(nI)
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

		oBrowseFiltro:SetColumns({oColumn})
	next

	oBrowseFiltro:GoTop()
	oBrowseFiltro:updateBrowse()

    C933CHANGE(oBrowseFiltro, oBrowseResultado)
    //if C933GridR(oBrowseResultado, cParamsR) == .F.
    //   return .F.
    //endif

Return .T.

Static Function C933GridR(oBrowseResultado, cParamsR, oBrowseFiltro)
	Local cQuery      := "proc_pesq_log_usuario_w "
	Local cParams     := ""
	Local nMax        := 0
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowseResultado:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''

    If nLog = 2
	   cQuery += " 2, " + cParamsR
	Else
	   cQuery += " 1, " + cParamsR
	EndIf

	TcSqlExec(cQuery)
	TcRefresh(cAliasTbR) 

	(cAliasTbR)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAliasTbR,cAliasTbR,.T.,.F.)

   nColSizeR := Len(oBrowseResultado:aColumns)

	for nI := 1 to nColSizeR
		oBrowseResultado:DelColumn(nI)
	next
	nColSizeR := Len(aStructR)

	for nI := 1 to nColSizeR
		oColumn := nil

		cCampo := STransType(aStructR[nI][1])
		cCampo := "{|| "+cCampo+"}"

		oColumn := FWBrwColumn():New()
		oColumn:SetData(  &(cCampo) )
		oColumn:SetTitle( aStructDR[nI][1]   )
		oColumn:SetSize(  aStructDR[nI][2]   )

		oBrowseResultado:SetColumns({oColumn})
	next

	oBrowseResultado:updateBrowse()
	oBrowseFiltro:SetFocus() 

Return .T.

static function C933GF(aFilter, cParams, cMsg, cParamsR)
	Local i := 1
	Local cOpcao := '0'
	Local cCampo1
	Local cCampo2
	Local cCampo3
	Local cCampo4

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cParams := ""
	cOpcao := STransType(aFilter[i][4][18][1])

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0"
		//Monta a estrutura de parametros para passar para a procedure
		cCampo1 := STrim(cUsuPesq)
		cCampo2 := STrim(aFilter[i][4][9][1])
		cCampo3 := STrim(aFilter[i][4][12][1])
		cCampo4 := STrim(aFilter[i][4][15][1])

	    if SEmpty(cCampo2)
		    cMsg := STR0023
		    return .F.
	    endif

	    if SEmpty(cCampo3)
		    cMsg := STR0023
		    return .F.
	    endif

	    if SEmpty(cCampo4) == .F.
		    if cCampo4 != '0' .AND. cCampo4 != '1'
		       cMsg := STR0024
		       return .F.
		    endif
		 endif

		if SEmpty(cCampo1) = .F.
		   cParams += "'"+cCampo1+"',"
		else
		   cParams += "NULL,"
		endif
		cParams += "'"+SDBDate(cCampo2,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo3,'23:59:59')+"',"
		cParams += cCampo4

		if SEmpty(cCampo1) = .F.
		   cParamsR = "'"+cCampo1+"',"
		else
		   cParamsR = "NULL,"
		endif
		cParamsR += "'"+SDBDate(cCampo2,'00:00:00')+"',"
		cParamsR += "'"+SDBDate(cCampo3,'23:59:59')+"'"

	endif

	cParams += ",'"+SGetDBOwner()+cAliasTbF+"'"
	cParamsR += ",'"+SGetDBOwner()+cAliasTbR+"'"
	
return .T.

function C933ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	aZoom := SZoomUsu(.T., .F., .T., .F., .F., .T.)
	aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

	if !SEmpty(aRetZoom)
		oObj:cText := STransType(aRetZoom[2],"C")
		cUsuPesq   := STransType(aRetZoom[1],"C")
	else
		oObj:cText := '                          '
		cUsuPesq := ''
	endif
return lRet

function C933VLPESS(xConteud, o)
   Local lRet   := .T.

   cUsuPesq := ''

	if !SEmpty(xConteud)
		if C933ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0012)
			return .F.
		end
	end

return lRet


static function C933CTB()
	    aStructDesc := {  ;
	    {STR0008, 15},;
		{STR0003, 40},;
		{STR0009, 20},;
		{STR0010, 20},;
		{STR0011, 40},;
		{STR0012, 15},;
		{STR0013, 10},;
		{STR0014, 10} ;
	}

	aStruct := {    ;
	    {'CP1'    ,'C',100 ,0}, ;
	    {'CP2'    ,'C',100 ,0}, ;
	    {'CP3'    ,'C',100 ,0}, ;
	    {'CP4'    ,'C',100 ,0}, ;
	    {'CP5'    ,'C',100 ,0}, ;
	    {'CP6'    ,'C',100 ,0}, ;
	    {'CP7'    ,'C',100 ,0}, ;
	    {'CP8'    ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasTbF)
	SCriaTb(cAliasTbF, aStruct)
return aStructDesc

static function C933CTBR()
	    aStructDR := {  ;
	    {STR0015, 15},;
		{STR0016, 20},;
		{STR0017, 20},;
		{STR0018, 40},;
		{STR0019, 10},;
		{STR0020, 15} ;
	}

	aStructR := {    ;
	    {'CP9'     ,'C',100 ,0}, ;
	    {'CP10'    ,'C',100 ,0}, ;
	    {'CP11'    ,'C',100 ,0}, ;
	    {'CP12'    ,'C',100 ,0}, ;
	    {'CP13'    ,'C',100 ,0}, ;
	    {'CP14'    ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasTbR)
	SCriaTb(cAliasTbR, aStructR)
return aStructDR
