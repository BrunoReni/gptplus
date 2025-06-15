#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC909.CH"

/*/{Protheus.doc} PRAC909
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    14/06/2012
@obs      2.2.3 Extrato consulta - 1.3 - Entrada/Saída de Lote de Carga
/*/

Function PRAC909()
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
	Private cAliasTb := SGetNAlias()             //Tabela temporária
	Private nColSize := 0                        //Quantidade de registros
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
						//Campo, Descricao   , Tipo  , Tamanho, Alias, Mascara, Nil, Zoom            , Validacao                                , ValorPadrao
 		Aadd(aFields, {"P1"   , STR0075    , "C"   , 50     , nil  , ""     , nil, "C909ZOOMM(o, 1)", {|xConteud, o| C909VCONH(xConteud,  o)} , nil})
 		Aadd(aFields, {"P2"   , STR0076    , "C"   , 50     , nil  , ""     , nil, "C909ZOOMM(o, 2)", {|xConteud, o| C909VDOCE(xConteud, o)} , nil})
 		Aadd(aFields, {"P3"   , STR0005    , "C"   , 70     , nil  , ""     , nil, "C909ZOOMM(o, 3)", {|xConteud, o| C909VTRAN(xConteud,  o)} , nil})
  		Aadd(aFields, {"P4"   , STR0040    , "C"   , 70     , nil  , ""     , nil, "C909ZOOMM(o, 4)", {|xConteud, o| C909VCONS(xConteud,  o)} , nil}) 
  		Aadd(aFields, {"P5"   , STR0009    , "C"   , 50     , nil  , ""     , nil, nil             , nil                                      , nil})
  		Aadd(aFields, {"P6"   , STR0077    , "D"   , 10     , nil  , ""     , nil, nil             , nil                                      , (Date() - 30)})
  		Aadd(aFields, {"P7"   , STR0078    , "D"   , 10     , nil  , ""     , nil, nil             , nil                                      , Date()})
        Aadd(aFields, {"P8"   , "Opcao"    , "C"   , 1      , nil  , ""     , nil, nil             , nil                                      , nil})
        Aadd(aFields, {"P9"   , STR0085    , "C"   , 30     , nil  , ""     , nil, "C909ZOOMM(o, 5)", {|xConteud, o| C909VDOCSAI(xConteud, o)} , nil})
		aStructDesc := C909CTB(@aStruct)		

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","%P1%",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)		
		SAddFilPar("P4" ,"==","NULL",@aFilParser)		
		SAddFilPar("P5" ,"==","NULL",@aFilParser)		
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","0",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)	
		//Cria um filtro
		oBrowse:AddFilter(STR0075, "P1=='%P1%' .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='0' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '0')
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","%P2%",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)		
		SAddFilPar("P4" ,"==","NULL",@aFilParser)		
		SAddFilPar("P5" ,"==","NULL",@aFilParser)		
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","1",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)	
		//Cria um filtro
		oBrowse:AddFilter(STR0076, "P1==NULL .AND. P2=='%P2%' .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='1' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '1')
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","%P3%",@aFilParser)		
		SAddFilPar("P4" ,"==","NULL",@aFilParser)		
		SAddFilPar("P5" ,"==","NULL",@aFilParser)		
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","2",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)	
		//Cria um filtro
		oBrowse:AddFilter(STR0005, "P1==NULL .AND. P2==NULL .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='2' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '2')
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)		
		SAddFilPar("P4" ,"==","%P4%",@aFilParser)		
		SAddFilPar("P5" ,"==","NULL",@aFilParser)		
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","3",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)	
		//Cria um filtro
		oBrowse:AddFilter(STR0040, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4=='%P4%' .AND. P5==NULL .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='3' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '3')
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)		
		SAddFilPar("P4" ,"==","NULL",@aFilParser)		
		SAddFilPar("P5" ,"==","%P5%",@aFilParser)		
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","4",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)	
		//Cria um filtro
		oBrowse:AddFilter(STR0009, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='4' .AND. P9==NULL", .F., .F.,nil,.T., aFilParser, '4')
		
		
		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)		
		SAddFilPar("P4" ,"==","NULL",@aFilParser)		
		SAddFilPar("P5" ,"==","NULL",@aFilParser)				
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","5",@aFilParser)
		SAddFilPar("P9" ,"==","%P9%",@aFilParser)
			
		//Cria um filtro
		oBrowse:AddFilter(STR0085, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6=='%P6%' .AND. P7=='%P7%' .AND. P8=='5' .AND. P9=='%P9%'", .F., .F.,nil,.T., aFilParser, '5')
		
		
		//Ativa o browse
		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		
		//Funcao que será executada no momento em que o filtro for acionado, para tratar as informações
		oBrowse:oFWFilter:SetExecute({||C909FILTER(oBrowse)})

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

Static Function C909FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_extrato_1_3_w "
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
		alert(STR0073)
		return
	endif
	
	//Recupera todos os filtros informado pelo usuário depois da solicitação de informações	
	aFilter      := oFilter:GetFilter(.T.)
	//Processa os filtros para recuperar os parametros para as procedures
	if (!C909GF(aFilter, @cParams, @cMsg))
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
	//aStruct := DBStruct()

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

static function C909GF(aFilter, cParams, cMsg) 
	Local i := 1
	Local cOpcao := '0'

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif
	
	cOpcao := STransType(aFilter[i][4][24][1]) 
    
	cParams := cOpcao+","
 
	//Verifica a opção selecionada pelo usuário
	
	if cOpcao == "0" //POR CONHECIMENTO
		//Monta a estrutura de parametros para passar para a procedure
		if SEmpty(STrim(STransType(aFilter[i][4][3][1])))
			cMsg := STR0079
			return .F.
		endif
		
		cParams += "'"+STrim(STransType(aFilter[i][4][3][1]))+"'"
		cParams += ",NULL,NULL,NULL,NULL,NULL"
	elseif cOpcao == "1" //POR DOCUMENTO DE ENTRADA
		if SEmpty(STrim(STransType(aFilter[i][4][6][1])))
			cMsg := STR0080
			return .F.
		endif	
	
		cParams += "NULL,'"+STrim(STransType(aFilter[i][4][6][1]))+"',NULL,NULL,NULL,NULL"	
	elseif cOpcao == "2" //POR TRANSPORTADORA
		if SEmpty(STrim(STransType(aFilter[i][4][9][1])))
			cMsg := STR0081
			return .F.
		endif	
	
		cParams += "NULL,NULL,'"+STrim(STransType(aFilter[i][4][9][1]))+"',NULL,NULL,NULL"
	elseif cOpcao == "3" //POR CONSIGNATÁRIO
		if SEmpty(STrim(STransType(aFilter[i][4][12][1])))
			cMsg := STR0082
			return .F.
		endif	
	
		cParams += "NULL,NULL,NULL,'"+STrim(STransType(aFilter[i][4][12][1]))+"',NULL,NULL"
	elseif cOpcao == "4" //POR UNIQUE CONSIG. NUMBER
		if SEmpty(STrim(STransType(aFilter[i][4][15][1])))
			cMsg := STR0083
			return .F.
		endif	
	
		cParams += "NULL,NULL,NULL,NULL,'"+STrim(STransType(aFilter[i][4][15][1]))+"',NULL"
	elseif cOpcao == "5" //POR DOCUMENTO DE SAIDA
		if SEmpty(STrim(STransType(aFilter[i][4][27][1])))
			cMsg := STR0086
			return .F.
		endif	
	
		cParams += "NULL,NULL,NULL,NULL,NULL,'"+STrim(STransType(aFilter[i][4][27][1]))+"'"
	endif
	
	if ( (STrim(STransType(aFilter[1][4][18][1])) == '/  /') .OR. (STrim(STransType(aFilter[1][4][21][1])) == '/  /') ) 
		cMsg := STR0084
		return .F.
	endif			
	
	cParams += ",'"+(SDBDate(aFilter[1][4][18][1], '00:00:00'))+"',"
	cParams += "'" +(SDBDate(aFilter[1][4][21][1], '23:59:59'))+"' "

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'" 
return .T.

function C909ZOOMM(oObj, nTipoZoom)
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
	elseif nTipoZoom == 2 //Documento de entrada	
       aZoom := SZoomDocEnt()
       aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
       
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	elseif nTipoZoom == 3 //Transportadora
		aZoom := SZoomTransp(.F.,.T.,.F.,.T.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	elseif nTipoZoom == 4 //	Consignatário
	     aZoom := SZoomCigCli(.F.,.T.,.F., .F., .T., .F.)
		 aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		 
		 if !SEmpty(aRetZoom)
		 	 oObj:cText := STransType(aRetZoom[1],"C")
		 else
		 	 oObj:cText := '                         '
		 endif
	elseif nTipoZoom == 5 //	Documento de saída
	     aZoom := SZoomDSAI1()
		 aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		 
		 if !SEmpty(aRetZoom)
		 	 oObj:cText := STransType(aRetZoom[1],"C")
		 else
		 	 oObj:cText := '                         '
		 endif
	endif

return lRet

function C909VDOCE(xConteud, o)
	if !SEmpty(xConteud)
		if C909ZOOMM(o, 2)
			return .T.
		else
			Alert(STR0074)
			return .F.
		endif
	end		
return

function C909VTRAN(xConteud, o)
	if !SEmpty(xConteud)
		if C909ZOOMM(o, 3)
			return .T.
		else
			Alert(STR0074)
			return .F.
		end
	end 	
return

function C909VCONS(xConteud, o)
	if !SEmpty(xConteud)
		if C909ZOOMM(o, 4)
			return .T.
		else
			Alert(STR0074)
			return .F.
		end
	end 	
return


function C909VCONH(xConteud, o)
	if !SEmpty(xConteud)
		if C909ZOOMM(o, 1)
			return .T.
		else
			Alert(STR0074)
			return .F.
		end
	end 	
return .T.

function C909VDOCSAI(xConteud, o)
	if !SEmpty(xConteud)
		if C909ZOOMM(o, 5)
			return .T.
		else
			Alert(STR0074)
			return .F.
		endif
	end		
return


static function C909CTB(aStruct)
	Local aStructDesc := {     ;
	    {STR0002, 10},    ;
	    {STR0003, 15},   ; 
	    {STR0004, 15},   ;
	    {STR0005, 40},   ;
	    {STR0006, 15},   ;
	    {STR0037, 10},   ;
	    {STR0038, 10},   ;
	    {STR0039, 10},   ;
	    {STR0040, 40},   ;
	    {STR0041, 15},   ;
	    {STR0042, 10},   ;
	    {STR0007, 10},   ;
	    {STR0008, 15},   ;
	    {STR0009, 10},   ;
	    {STR0010, 20},   ;
	    {STR0011, 20},   ;
        {STR0030, 20},   ;
	    {STR0043, 40},   ;
	    {STR0044, 15},   ;
	    {STR0070, 15},   ;
	    {STR0071, 15},   ;
	    {STR0072, 15},   ;
	    {STR0012, 20},   ;
	    {STR0013, 20},   ;
	    {STR0014, 15},   ;
	    {STR0015, 15},   ;
	    {STR0016, 20},   ;
	    {STR0017, 20},   ;
	    {STR0018, 15},   ;
	    {STR0019, 20},   ;
	    {STR0020, 20},   ;
	    {STR0021, 20},   ;
	    {STR0022, 20},   ; 
	    {STR0023, 20},   ;
	    {STR0024, 20},   ;
	    {STR0025, 15},   ;
	    {STR0026, 20},   ;
	    {STR0027, 20},   ;
	    {"Tipo processo saída", 20}, ;
	    {STR0028, 20},   ;
	    {STR0029, 20},   ;    
	    {STR0032, 20},   ;
	    {STR0033, 20},   ;
	    {STR0034, 20},   ;
	    {STR0035, 20},   ;
	    {STR0036, 15},   ;
	    {STR0045, 15},   ;
        {STR0087, 15},   ;
	    {STR0046, 50},   ;
        {STR0052, 20},   ;
        {STR0051, 15},   ;
        {STR0050, 15},   ;
        {STR0053, 15},   ;
	    {STR0047, 10},   ;
        {STR0049, 20},   ;
        {STR0048, 20},   ;
        {STR0088, 10},   ;
        {STR0056, 15},   ;
        {STR0089, 15},   ;
        {STR0057, 15},   ;	    
	    {STR0054, 20},   ;
	    {STR0055, 20},   ;    
	    {STR0064, 30},   ;
	    {STR0065, 30},   ;
        {STR0069, 50},   ;
        {STR0068, 20},   ;
        {STR0067, 50},   ;	    
 	    {STR0066, 20},   ;    
        {STR0031, 20},   ;
	    {STR0058, 10},   ;
	    {STR0059, 30},   ;
	    {STR0060, 20},   ;
	    {STR0061, 20},   ;
	    {STR0062, 20},   ;
	    {STR0063, 10},   ;
	    {"Doc. Entreposto(DA)", 20},   ;     
	    {"CNPJ Emissor RTM", 20},      ;
	    {"Número RTM", 20},            ;
	    {"Quant. Volumes RTM", 20},    ;
	    {"Valor Mercadorias", 20},     ;
	    {"Termo Entrada Aeronave", 20} ;
	}
	
	aStruct := {    ;
	    {'CP1'  ,'C',40 ,0},  ;
	    {'CP2'  ,'C',50 ,0},  ;
	    {'CP3'  ,'C',20 ,0},  ;
	    {'CP4'  ,'C',100 ,0},  ;
	    {'CP5'  ,'C',100 ,0},  ;
	    {'CP6'  ,'C',20 ,0},  ;
	    {'CP7'  ,'C',20 ,0},  ;
	    {'CP8'  ,'C',20 ,0},  ;
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
	    {'CP24' ,'C',100 ,0},  ;
	    {'CP25' ,'C',100 ,0},  ;
	    {'CP26' ,'C',100 ,0},  ;
	    {'CP27' ,'C',100 ,0},  ;
	    {'CP28' ,'C',100 ,0},  ;
	    {'CP29' ,'C',100 ,0},  ;
	    {'CP30' ,'C',100 ,0},  ;
	    {'CP31' ,'C',100 ,0},  ;
	    {'CP32' ,'C',100 ,0},  ;
	    {'CP33' ,'C',100 ,0},  ;
	    {'CP34' ,'C',100 ,0},  ;
	    {'CP35' ,'C',100 ,0},  ;
	    {'CP36' ,'C',100 ,0},  ;
	    {'CP37' ,'C',100 ,0},  ;
	    {'CP38' ,'C',100 ,0},  ;    
	    {'CP39' ,'C',100 ,0},  ;
	    {'CP40' ,'C',100 ,0},  ;
	    {'CP41' ,'C',5000 ,0},  ;
	    {'CP42' ,'C',100 ,0},  ;
	    {'CP43' ,'C',100 ,0},  ;
	    {'CP44' ,'C',100 ,0},  ;
	    {'CP45' ,'C',100 ,0},  ;
	    {'CP46' ,'C',100 ,0},  ;
	    {'CP47' ,'C',100 ,0},  ;
	    {'CP48' ,'C',100 ,0},  ;
	    {'CP49' ,'C',100 ,0},  ;
	    {'CP50' ,'C',100 ,0},  ;
	    {'CP51' ,'C',100 ,0},  ;
	    {'CP52' ,'C',100 ,0},  ;
	    {'CP53' ,'C',100 ,0},  ;
	    {'CP54' ,'C',100 ,0},  ;
	    {'CP55' ,'C',100 ,0},  ;
	    {'CP56' ,'C',100 ,0},  ;
	    {'CP57' ,'C',100 ,0},  ;
	    {'CP58' ,'C',100 ,0},  ;
	    {'CP59' ,'C',100 ,0},  ;
	    {'CP60' ,'C',100 ,0},  ;
	    {'CP61' ,'C',100 ,0},  ;
	    {'CP62' ,'C',100 ,0},  ;
	    {'CP63' ,'C',100 ,0},  ;
	    {'CP64' ,'C',100 ,0},  ;
	    {'CP65' ,'C',100 ,0},  ;
	    {'CP66' ,'C',100 ,0},  ;
	    {'CP67' ,'C',100 ,0},  ;
	    {'CP68' ,'C',100 ,0},  ;
	    {'CP69' ,'C',100 ,0},  ;
	    {'CP70' ,'C',100 ,0},  ;
	    {'CP71' ,'C',100 ,0},  ;
	    {'CP72' ,'C',100 ,0},  ;
	    {'CP73' ,'C',100 ,0},  ;
	    {'CP74' ,'C',100 ,0},  ;
	    {'CP75' ,'C',100 ,0},  ;
	    {'CP76' ,'C',100 ,0},  ;
	    {'CP77' ,'C',100 ,0},  ;
	    {'CP78' ,'C',100 ,0},  ;	    
	    {'CP79' ,'C',100 ,0},  ;
	    {'CP80' ,'C',100 ,0},  ;
	    {'CP81' ,'C',100 ,0}   ;	    	    	       
	}

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
 