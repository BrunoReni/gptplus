#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC942.CH"

/*/{Protheus.doc} PRAC942 
@author   Marcelo Nunes
@version  P12
@since    17/09/2014
@obs      2.17 Caixa de mensagens trocadas com a RFB
/*/ 

Function PRAC942()
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
						//Campo,Descricao   , Tipo,Tamanho, Alias, Mascara          , Nil, Zoom             , Validacao                              , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "D" , 10     , nil  , ""                  , nil, nil                , nil                                          , (Date()- 30)})
		Aadd(aFields, {"P2"  , STR0003     , "D" , 10     , nil  , ""                  , nil, nil                , nil                                          , (Date())})		
		Aadd(aFields, {"P3"  , "Opcao"     , "C" , 1      , nil  , ""                  , nil, nil                , nil                                          , nil})

		C942CTB()

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","%P1%",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0004, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='0'", .F., .F.,nil,.T., aFilParser, '0')

		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:oFWFilter:SetExecute({||C942FILTER(oBrowse)})
		oBrowse:oFWFilter:FilterBar(nil,.F.,.F.)

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTb(cAliasTb)
Return

Static Function C942FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_2_17_w"
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
		alert(STR0005)
		return
	endif

	aFilter := oFilter:GetFilter(.T.)

	if (!C942GF(aFilter, @cParams, @cMsg))
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

static function C942GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[i][4][9][1])

	cParams := ""

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0"	    
		if (STransType(aFilter[i][4][3][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][3][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][6][1]) ==  '  /  /    ')
		  cParams += "NULL"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][6][1],'23:59:59')+"'"
	    end if
	endif 

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T. 

static function C942CTB()
	    aStructDesc := {  ;
	    {STR0006, 15},;
		{STR0007, 10},;
		{STR0008, 30},;
		{STR0009, 10},;
		{STR0010, 100};		
	}
 
	aStruct := {    ;
	    {'CP1'  ,'C',100 ,0},;
	    {'CP2'  ,'C',100 ,0},;
	    {'CP3'  ,'C',250 ,0},;
	    {'CP4'  ,'C',100 ,0},;
	    {'CP5'  ,'C',1024 ,0};	    
	    }

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
 