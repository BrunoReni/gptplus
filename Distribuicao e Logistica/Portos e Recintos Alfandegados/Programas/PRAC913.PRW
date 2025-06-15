#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC913.CH"

/*/{Protheus.doc} PRAC913
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    28/06/2012
@obs      2.2.3 Extrato consulta - 1.7 Unitização de carga
/*/

Function PRAC913()
	Local oDlg       := nil                       //Janela
	Local aFields    := {}                        //Campos de pesquisa
	Local oPanel     := nil                       //Painel
	Local oLayer     := nil                       //Layout
	Local aFilParser := {}                        //Configuração dos filtros
	Local aCoors     := FWGetDialogSize(oMainWnd) //Coordenada da janela
	Local oBrowse    := nil                       //GRID
	Local nI         := 0
	Local nMax       := 0
	Local aSeek      := {}
	Local aIndex     := {}

	Private cAliasTb := SGetNAlias()            //Tabela temporária
	Private nColSize := 0                       //Quantidade de registros
	Private nTipoDoc := '-1'
	Private aStructDesc
	Private aStruct

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01') //Recupera o objeto do Window

		//Adiciona no array os campos de filtro da tela
						//Campo, Descricao   , Tipo, Tamanho, Alias, Mascara            , Nil, Zoom            , Validacao                          , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "C" , 50     , nil  , ""                 , nil, "C913ZOOMP(o, 1)", {|xConteud, o| C913VCONHE(xConteud, o)}  , nil})
		Aadd(aFields, {"P4"  , "Conhecimento de Transporte Nacional (NF, RNF)"     , "C" , 50     , nil  , ""                 , nil, "C913ZOOMP(o, 4)", {|xConteud, o| C913VNAS(xConteud, o)}  , nil})
		Aadd(aFields, {"P2"  , STR0003     , "C" , 50     , nil  , "@R 99/999999-9"  , nil, "C913ZOOMP(o, 2)", {|xConteud, o| C913VALL(xConteud, o)}   , nil})
		Aadd(aFields, {"P3"  , "Opcao"     , "C" , 1      , nil  , ""                 , nil, nil             , nil                                      , nil})

		C913CTB()

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==" ,"%P1%",@aFilParser)
		SAddFilPar("P4","==" ,"NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1=='%P1%'  AND. P4=='NULL' .AND. P2==NULL .AND. P3=='0'", .F., .F.,nil,.T., aFilParser, '0')
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==" ,"NULL",@aFilParser)
		SAddFilPar("P4","==" ,"%P4%",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","4"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter("Conhecimento de Transporte Nacional (NF, RNF)", "P1=='NULL' AND. P4=='%P4%' .AND. P2==NULL .AND. P3=='4'", .F., .F.,nil,.T., aFilParser, '4')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P4","==" ,"NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","1"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003, "P1==NULL AND. P4=='NULL' .AND. P2=='%P2%' .AND. P3=='1'", .F., .F.,nil,.T., aFilParser, '1')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C913FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C913FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_extrato_1_7_w "
	Local cParams     := ""
	Local nMax        := 0
	Local oColumn
	Local nI          := 0
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''

	if !SVALFILTRO(oFilter)
		alert(STR0004)
		return
	endif

	aFilter      := oFilter:GetFilter(.T.)

	if (!C913GF(aFilter, @cParams, @cMsg))
		if (!SEmpty(cMsg))
			alert(cMsg)
		endif
		return
	endif

	cQuery += " " + cParams

	TcSqlExec(cQuery)
	TcRefresh(cAliasTb) 

	(cAliasTb)->(dbCloseArea())
	DbUseArea(.T.,'TOPCONN',cAliasTb,cAliasTb,.T.,.F.)

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

	oBrowse:updateBrowse()

Return .T.

static function C913GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'
	Local cCampo

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[i][4][12][1])

	cParams := ""

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0"
	    cCampo := STrim(STransType(aFilter[i][4][3][1]))
	    if SEmpty(cCampo)
		    cMsg := STR0013
		    return .F.
	    endif
		//Monta a estrutura de parametros para passar para a procedure
		cParams += "'"+cCampo+"',NULL,"
		cParams += cOpcao
	elseif cOpcao == "1"
	    cCampo := STrim(STransType(aFilter[i][4][9][1]))
	    if SEmpty(cCampo)
		    cMsg := STR0013
		    return .F.
	    endif
		//Monta a estrutura de parametros para passar para a procedure
		cParams += "NULL,'"+cCampo+"',"
		cParams += cOpcao
	elseif cOpcao == "4"
	    cCampo := STrim(STransType(aFilter[i][4][6][1]))
	    if SEmpty(cCampo)
		    cMsg := STR0013
		    return .F.
	    endif
	    cOpcao = '0'
		//Monta a estrutura de parametros para passar para a procedure
		cParams += "'"+cCampo+"',NULL,"
		cParams += cOpcao
	endif

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C913ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1 //Conhecimento
		aZoom := SZoomConh9(.T.,.F.,.F.,.T.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                              '
		endif

	elseif nTipoZoom == 2 //Lote
		aZoom := SZoomConhec(.F.,.T.,.F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom) 
			oObj:cText := StrTran(StrTran(STransType(aRetZoom[1],"C"),"/",""),"-","")
		else
			oObj:cText := '                              '
		endif		
	elseif nTipoZoom == 4
		aZoom := SZoomConh9(.T.,.F.,.F.,.F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                              '
		endif
	endif

return lRet

function C913VCONHE(xConteud, o)
	if !SEmpty(xConteud)
	   if C913ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0010)
			return .F.
		end
	end
return .T.

function C913VALL(xConteud, o)
	if !SEmpty(xConteud)
		if C913ZOOMP(o, 2)
			return .T.
		else
			Alert(STR0011)
			return .F.
		end
	end
return .T.

function C913VNAS(xConteud, o)
	if !SEmpty(xConteud)
	   if C913ZOOMP(o, 4)
			return .T.
		else
			Alert(STR0010)
			return .F.
		end
	end
return .T.

static function C913CTB()
	    aStructDesc := {  ;
	    {STR0003, 20},;
		{STR0004, 20},;
		{STR0005, 20},;
		{STR0006, 20},;
		{STR0007, 20},;
		{STR0008, 20},;
		{STR0009, 20};
	}

	aStruct := {    ;
	    {'CP1'  ,'C',100 ,0}, ;
	    {'CP2'  ,'C',100 ,0}, ;
	    {'CP3'  ,'C',100 ,0}, ;
	    {'CP4'  ,'C',100 ,0}, ;
	    {'CP5'  ,'C',100 ,0}, ;
	    {'CP6'  ,'C',100 ,0}, ;
	    {'CP7'  ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
