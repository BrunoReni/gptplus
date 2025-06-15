#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC932.CH"

/*/{Protheus.doc} PRAC932
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    16/07/2012
@obs      2.2.18 c) Usuários e perfils de acesso -> Relatorio
/*/

Function PRAC932()
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

	Private cAliasTb := SGetNAlias()              //Tabela temporária
	Private nColSize := 0                         //Quantidade de registros
	Private nTipoDoc := '-1'
	Private aStructDesc
	Private aStruct
	Private cUsuario := ''

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01') //Recupera o objeto do Window

		//Adiciona no array os campos de filtro da tela
						//Campo, Descricao   , Tipo, Tamanho, Alias, Mascara            , Nil, Zoom            , Validacao                               , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "C" , 20     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P2"  , STR0003     , "C" , 20     , nil  , ""                 , nil, "C932ZOOMP(o, 1)", {|xConteud, o| C932VLPESS(xConteud, o)}  , nil})
		Aadd(aFields, {"P3"  , STR0014     , "D" , 20     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P4"  , STR0015     , "D" , 20     , nil  , ""                 , nil, ""              , nil                                     , nil})
		Aadd(aFields, {"P5"  , "Opcao"     , "C" , 1      , nil  , ""                 , nil, nil             , nil                                     , nil})

		C932CTB()

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5=='0'", .T., .T.,nil,.T., aFilParser, '0')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C932FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C932FILTER(oBrowse)
	Local cQuery      := "proc_rfb_log_outras_consultas_w "
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
		alert(STR0013)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C932GF(aFilter, @cParams, @cMsg))
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

static function C932GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'
	Local cCampo1
	Local cCampo2
	Local cCampo3

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cParams := ""
	cOpcao := STransType(aFilter[i][4][15][1])

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0" //Pesquisar: Usuário e Data
		//Monta a estrutura de parametros para passar para a procedure
		cCampo1 := STrim(STransType(cUsuario))
		cCampo2 := STrim(aFilter[i][4][9][1])
		cCampo3 := STrim(aFilter[i][4][12][1])

		if SEmpty(cCampo1)
		    cMsg := STR0016
		    return .F.
	    endif

	    if SEmpty(cCampo2)
		    cMsg := STR0017
		    return .F.
	    endif

	    if SEmpty(cCampo3)
		    cMsg := STR0017
		    return .F.
	    endif

		cParams += "'"+cCampo1+"',"
		cParams += "'"+SDBDate(cCampo2,'00:00:00')+"',"
		cParams += "'"+SDBDate(cCampo3,'23:59:59')+"'"
	endif

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C932ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	aZoom := SZoomUsu(.T., .F., .T., .F., .F., .T.)
	aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

	if !SEmpty(aRetZoom)
		oObj:cText := STransType(aRetZoom[2],"C")
		cUsuario := STransType(aRetZoom[1],"C")
	else
		oObj:cText := '                                                               '
		cUsuario := ''
	endif

return lRet

function C932VLPESS(xConteud, o)
   Local lRet   := .T.

	cUsuario := ''

	if !SEmpty(xConteud)
		if C932ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0012)
			return .F.
		end
	end

return lRet


static function C932CTB()
	    aStructDesc := {  ;
	    {STR0005, 15},;
		{STR0006, 40},;
		{STR0007, 20},;
		{STR0008, 20},;
		{STR0009, 15},;
		{STR0010, 15},;
		{STR0011, 15} ;
	}

	aStruct := {    ;
	    {'CP1'    ,'C',100 ,0}, ;
	    {'CP2'    ,'C',100 ,0}, ;
	    {'CP3'    ,'C',100 ,0}, ;
	    {'CP4'    ,'C',100 ,0}, ;
	    {'CP5'    ,'C',100 ,0}, ;
	    {'CP6'    ,'C',100 ,0}, ;
	    {'CP7'    ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
