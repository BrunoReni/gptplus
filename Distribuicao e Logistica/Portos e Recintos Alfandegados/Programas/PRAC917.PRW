#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC917.CH"

/*/{Protheus.doc} PRAC917
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    03/07/2012
@obs      2.2.3 Extrato consulta - 1.10A - Situação de lote de carga para verificação física
/*/

Function PRAC917()
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
						//Campo, Descricao   , Tipo, Tamanho, Alias, Mascara            , Nil, Zoom            , Validacao                               , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "C" , 50     , nil  , ""                 , nil, "C917ZOOMP(o, 1)", {|xConteud, o| C917VALIDA(xConteud, o)}  , nil})
		Aadd(aFields, {"P2"  , STR0003     , "C" , 50     , nil  , "@R 99/999999-9"  , nil, "C917ZOOMP(o, 2)", {|xConteud, o| C917VALI2(xConteud, o)} , nil})
		Aadd(aFields, {"P3"  , "Opcao"     , "C" , 1      , nil  , ""                 , nil, nil             , nil                                     , nil})

		C917CTB()

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==" ,"%P1%",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1=='%P1%' .AND. P2==NULL .AND. P3=='0'", .F., .F.,nil,.T., aFilParser, '0')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","1"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003, "P1==NULL .AND. P2=='%P2%' .AND. P3=='1'", .F., .F.,nil,.T., aFilParser, '1')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C917FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C917FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_extrato_1_10A_w "
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
		alert(STR0011)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C917GF(aFilter, @cParams, @cMsg))
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

static function C917GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cParams := ""
	cOpcao := STransType(aFilter[i][4][9][1])

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0" //Conhecimento
		//Monta a estrutura de parametros para passar para a procedure
		if (SEmpty(STrim(STransType(aFilter[i][4][3][1]))))
			cMsg := STR0013
			return .F.
		endif

		cParams += "'"+STrim(STransType(aFilter[i][4][3][1]))+"',NULL,"
		cParams += cOpcao
	elseif cOpcao == "1" //Lote
		//Monta a estrutura de parametros para passar para a procedure
		if (SEmpty(STrim(STransType(aFilter[i][4][6][1]))))
			cMsg := STR0014
			return .F.
		endif

		cParams += "NULL,'"+STrim(STransType(aFilter[i][4][6][1]))+"',"
		cParams += cOpcao
	endif

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C917ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1 //Conhecimento de Transporte
		aZoom := SZoomConhec(.T.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                              '
		endif

	elseif nTipoZoom == 2 //Lote de Carga
		aZoom := SZoomConhec(.F.,.T.,.F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := StrTran(StrTran(STransType(aRetZoom[1],"C"),"/",""),"-","")
		else
			oObj:cText := '                              '
		endif
	endif

return lRet

function C917VALIDA(xConteud, o)
	if !SEmpty(xConteud)
		if C917ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0012)
			return .F.
		end
	end
return .T.

function C917VALI2(xConteud, o)
	if !SEmpty(xConteud)
		if C917ZOOMP(o, 2)
			return .T.
		else
			Alert(STR0012)
			return .F.
		end
	end
return .T.

//static function C917CTB(aStruct)
static function C917CTB()
	    aStructDesc := {  ;
	    {STR0004, 30},;
		{'Tipo de Declaração Aduaneira' , 30},;
		{'Número', 15},;
		{STR0007, 10},;
		{STR0008, 15},;
		{STR0009, 10},;
		{STR0010, 15} ;
	}

	aStruct := {    ;
	    {'CP1'   ,'C',100 ,0}, ;
	    {'CP2'   ,'C',100 ,0}, ;
	    {'CP3'   ,'C',100 ,0}, ;
	    {'CP4'   ,'C',100 ,0}, ;
	    {'CP5'   ,'C',100 ,0}, ;
	    {'CP6'   ,'C',100 ,0}, ;
	    {'CP7'   ,'C',100 ,0}  ;
	    }

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
