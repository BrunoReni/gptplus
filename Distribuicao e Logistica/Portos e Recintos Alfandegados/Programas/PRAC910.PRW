#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC910.CH"

/*/{Protheus.doc} PRAC910
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    21/06/2012
@obs      2.2.3 Extrato consulta - 1.4 - Relação de Notas Fiscais - RNF
/*/

Function PRAC910()
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
	//Private cAliasTb := SCTBTMPG()                //Tabela temporária
	Private cAliasTb := SGetNAlias()            //Tabela temporária
	Private nColSize := 0                         //Quantidade de registros
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
						//Campo, Descricao    , Tipo, Tamanho, Alias, Mascara       , Nil, Zoom            , Validacao                                , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002      , "C" , 50     , nil  , ""            , nil, "C910ZOOMP(o, 1)", {|xConteud, o| C910VCON(xConteud, o)} , nil})
		Aadd(aFields, {"P2"  , STR0003      , "C" , 30     , nil  , "@E 99/9999"  , nil, "C910ZOOMP(o, 2)", nil                                      , nil})
		Aadd(aFields, {"P3"  , STR0004      , "C" , 30     , nil  , ""            , nil, "C910ZOOMP(o, 3)", {|xConteud, o| C910VALNF(xConteud, o)}     , nil})
		Aadd(aFields, {"P4"  , "Opcao"      , "C" , 1      , nil  , ""            , nil, nil             , nil                                      , nil})

		aStructDesc := C910CTB(@aStruct)

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==" ,"%P1%",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1=='%P1%' .AND. P2==NULL .AND. P3==NULL .AND. P4=='0'", .F., .F.,nil,.T., aFilParser, '0')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","1"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003, "P1==NULL .AND. P2=='%P2%' .AND. P3=='NULL' .AND. P4=='1'", .F., .F.,nil,.T., aFilParser, '1')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","2"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0004, "P1==NULL .AND. P2==NULL .AND. P3=='%P3%' .AND. P8=='2'", .F., .F.,nil,.T., aFilParser, '2')

		//Ativa o browse
		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros

		//Funcao que será executada no momento em que o filtro for acionado, para tratar as informações
		oBrowse:oFWFilter:SetExecute({||C910FILTER(oBrowse)})

		//-------------------------------------------------------------------
		//@param   oObject Objeto do tipo container
		//@param   lNoButtons Indica se apresenta os botões que permitem a inclusão, exclusão e execução dos filtros
		//@param   lNoEsc Somente permite o fechamento da janela através da opção Executar
		//-------------------------------------------------------------------
		//Obriga a abertura do filtro no momento da abertura da tela, para consultas tipo array
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C910FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_extrato_1_4_w "
	Local cParams     := ""
	Local nMax        := 0
	Local oColumn
	//Local aStruct
	Local nI          := 0
	// Recupera os filtros do Browse
	Local oFilter     := oBrowse:FWFilter()
	Local aFilter     := nil
	Local cMsg := ""
	Local cRet := ''
	Local cCampo := ''

	//Efetua a validação se tem algum filtro selecionado
	if !SVALFILTRO(oFilter)
		alert(STR0028)
		return
	endif

	//Recupera todos os filtros informado pelo usuário depois da solicitação de informações
	aFilter      := oFilter:GetFilter(.T.)
	//Processa os filtros para recuperar os parametros para as procedures
	if (!C910GF(aFilter, @cParams, @cMsg))
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

	//Apaga as colunas existente no Browse
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

	//Atualiza a grid para utilizar as novas informações
	oBrowse:updateBrowse()

Return .T.

static function C910GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'
	Local cParam := ''

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STrim(STransType(aFilter[i][4][12][1]))

	cParams := ""

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0"
		//Monta a estrutura de parametros para passar para a procedure
		if (SEmpty(STrim(STransType(aFilter[i][4][3][1]))))
			cMsg := STR0030
			return .F.
		endif

		cParams += "'"+STrim(STransType(aFilter[i][4][3][1]))+"',NULL,NULL,"
		cParams += cOpcao
	elseif cOpcao == "1"
		//Monta a estrutura de parametros para passar para a procedure
		if ( (SEmpty(STrim(STransType(aFilter[i][4][6][1])))) .OR. (STrim(STransType(aFilter[i][4][6][1])) == '/') )
			cMsg := STR0031
			return .F.
		endif

		cParam := StrTran(STrim(STransType(aFilter[i][4][6][1])), '/', '')

		cParams += "NULL,'"+cParam+"',NULL,"
		cParams += cOpcao
	elseif cOpcao == "2"
		//Monta a estrutura de parametros para passar para a procedure
		if (SEmpty(STrim(STransType(aFilter[i][4][9][1]))))
			cMsg := STR0032
			return .F.
		endif

		cParams += "NULL,NULL,'"+STrim(STransType(aFilter[i][4][9][1]))+"',"
		cParams += cOpcao
	endif

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C910ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1 //Conhecimento
		aZoom := SZoomConhec(.T.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif

	elseif nTipoZoom == 2 //Relação das NF
		aZoom := SZoomRelNF()
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	elseif nTipoZoom == 3 //Notas Fiscais
		aZoom := SZoomNFs()
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	endif

return lRet

function C910VCON(xConteud, o)
	if !SEmpty(xConteud)
		if C910ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0029)
			return .F.
		end
	end
return .T.

function C910VALNF(xConteud, o)
	if !SEmpty(xConteud)
		if C910ZOOMP(o, 3)
			return .T.
		else
			Alert(STR0029)
			return .F.
		end
	end
return .T.

static function C910CTB(aStruct)
	Local aStructDesc := {     ;
	    {STR0005, 15},;
		{STR0006, 15},;
		{STR0007, 15},;
		{STR0008, 15},;
		{STR0002, 15},;
		{STR0009, 15},;
		{STR0010, 15},;
		{STR0011, 15},;
		{STR0012, 15},;
		{STR0013, 15},;
		{STR0014, 15},;
		{STR0015, 15},;
		{STR0016, 15},;
		{STR0017, 50},;
		{STR0018, 20},;
		{STR0019, 30},;
		{STR0020, 20},;
		{STR0021, 15},;
		{STR0022, 15},;
		{STR0023, 50},;
		{STR0024, 15},;
		{STR0025, 30},;
		{STR0026, 10},;
		{STR0027, 30};
	}

	aStruct := {    ;
	    {'CP1'  ,'N',100 ,0},  ;
	    {'CP2'  ,'C',100 ,0},  ;
	    {'CP3'  ,'C',100 ,0},  ;
	    {'CP4'  ,'C',100 ,0},  ;
	    {'CP5'  ,'C',100 ,0},  ;
	    {'CP6'  ,'C',100 ,0},  ;
	    {'CP7'  ,'C',100 ,0},  ;
	    {'CP8'  ,'C',100 ,0},  ;
	    {'CP9'  ,'C',100 ,0},  ;
	    {'CP10' ,'C',100 ,0},  ;
	    {'CP11' ,'C',100 ,0},  ;
	    {'CP12' ,'C',100 ,0},  ;
	    {'CP13' ,'C',100 ,0},  ;
	    {'CP14' ,'C',100 ,0},  ;
	    {'CP15' ,'C',100 ,0},  ;
	    {'CP16' ,'C',100 ,0},  ;
	    {'CP17' ,'C',100 ,0},  ;
	    {'CP18' ,'C',100 ,0},  ;
	    {'CP19' ,'C',100 ,0},  ;
	    {'CP20' ,'C',100 ,0},  ;
	    {'CP21' ,'C',100 ,0},  ;
	    {'CP22' ,'C',100 ,0},  ;
	    {'CP23' ,'C',100 ,0},  ;
	    {'CP24' ,'C',100 ,0}   ;
	}

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
