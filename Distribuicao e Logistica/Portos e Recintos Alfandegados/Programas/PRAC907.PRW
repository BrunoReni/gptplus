#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC907.CH"

/*/{Protheus.doc} PRAC907
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    11/06/2012
@obs      2.2.3 Extrato consulta - 1.1 - Entrada/Saída de Pessoas
/*/

Function PRAC907()
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
	Private cCodUsu := ''

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		cCodUsu := ''

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.F.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01') //Recupera o objeto do Window

		//Adiciona no array os campos de filtro da tela
						//Campo, Descricao   , Tipo, Tamanho, Alias, Mascara, Nil, Zoom            , Validacao                              , ValorPadrao
		Aadd(aFields, {"P1"  , STR0002     , "C" , 100    , nil  , ""     , nil, "C907ZOOMP(o, 1)", {|xConteud, o| C907VPES(xConteud, o)} , nil})
		Aadd(aFields, {"P2"  , STR0003     , "C" , 15     , nil  , "@R 99.999.999/9999-99"     , nil, nil             , nil                                    , nil})
		Aadd(aFields, {"P3"  , STR0004     , "D" , 10     , nil  , ""     , nil, nil             , nil                                    , (Date() - 30)})
		Aadd(aFields, {"P4"  , STR0005     , "D" , 10     , nil  , ""     , nil, nil             , nil                                    , (Date())})
		Aadd(aFields, {"P5"  , STR0006     , "D" , 10     , nil  , ""     , nil, nil             , nil                                    , (Date() - 30)})
		Aadd(aFields, {"P6"  , STR0007     , "D" , 10     , nil  , ""     , nil, nil             , nil                                    , (Date())})
		Aadd(aFields, {"P7"  , "Opcao"     , "C" , 1      , nil  , ""     , nil, nil             , nil                                    , (Date())})

		aStructDesc := C907CTB(@aStruct)

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==" ,"%P1%",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1=='%P1%' .AND. P2==NULL .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7=='0'", .F., .F.,nil,.T., aFilParser, '0')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","1"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003 + ' - RG', "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7=='1'", .F., .F.,nil,.T., aFilParser, '1')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","2"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003 + ' - CNH', "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7=='2'", .F., .F.,nil,.T., aFilParser, '2')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","%P2%",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","3"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0003 + ' - CPF', "P1==NULL .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7=='3'", .F., .F.,nil,.T., aFilParser, '3')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","%P3%",@aFilParser)
		SAddFilPar("P4","==","%P4%",@aFilParser)
		SAddFilPar("P5","==","NULL",@aFilParser)
		SAddFilPar("P6","==","NULL",@aFilParser)
		SAddFilPar("P7","==","4"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0016, "P1==NULL .AND. P2==NULL .AND. P3=='%P3%' .AND. P4=='%P4%' .AND. P5==NULL .AND. P6==NULL .AND. P7=='4'", .F., .F.,nil,.T., aFilParser, '4')

				//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1","==","NULL",@aFilParser)
		SAddFilPar("P2","==","NULL",@aFilParser)
		SAddFilPar("P3","==","NULL",@aFilParser)
		SAddFilPar("P4","==","NULL",@aFilParser)
		SAddFilPar("P5","==","%P5%",@aFilParser)
		SAddFilPar("P6","==","%P6%",@aFilParser)
		SAddFilPar("P7","==","5"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0017, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7=='5'", .F., .F.,nil,.T., aFilParser, '5')

		//Ativa o browse
		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros
		oBrowse:FWFilter():CleanFilter(.T.)
		
		oBrowse:FWFilter():DisableSave(.T.)
        oBrowse:FWFilter():DisableDel(.T.)   
        oBrowse:FWFilter():DisableAdd(.T.)

		//Funcao que será executada no momento em que o filtro for acionado, para tratar as informações
		oBrowse:oFWFilter:SetExecute({||C907FILTER(oBrowse)})

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

Static Function C907FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_extrato_1_1_w "
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
		alert(STR0014)
		return
	endif

	if (SCHKFILTRO(oFilter) == 4)
		oFilter:aFields[2][6] = '@R 999.999.999-99'
	else
		oFilter:aFields[2][6] = ''
	endif

	//Recupera todos os filtros informado pelo usuário depois da solicitação de informações
	aFilter      := oFilter:GetFilter(.T.)
	//Processa os filtros para recuperar os parametros para as procedures
	if (!C907GF(aFilter, @cParams, @cMsg))
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
		
		if (aStructDesc[nI][1]<>'Motivação do acesso') 
		    oBrowse:SetColumns({oColumn})
		else
		  if C907MOTIVO() 
		     oBrowse:SetColumns({oColumn})		  
		  endif 		   
		endif
//		if (aStructDesc[nI][1]=='Motivação do acesso')
//           oColumn:SetDelete(.T.)
//		   oColumn:SetDetails(.F.)
//		endif		
//		oBrowse:SetColumns({oColumn})
	next

	//Atualiza a grid para utilizar as novas informações
	oBrowse:updateBrowse()

Return .T.

static function C907GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'
	Local cCPF := ''

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[i][4][21][1])

	//cParams := cOpcao+","
	cParams := ""

	//Verifica a opção selecionada pelo usuário
	if cOpcao == "0"
		//Monta a estrutura de parametros para passar para a procedure
		cParams += "0,NULL,NULL,"
	    
	    if (STransType(aFilter[i][4][9][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][9][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][12][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][12][1],'23:59:59')+"',"
	    end if
		
		cParams += cCodUsu
	elseif cOpcao == "1"
		cParams += "1,1,'"+STrim(STransType(aFilter[i][4][6][1]))+"',"
		
		if (STransType(aFilter[i][4][9][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][9][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][12][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][12][1],'23:59:59')+"',"
	    end if
	    
		cParams += "NULL,"
	elseif cOpcao == "2"
		cParams += "1,2,'"+STrim(STransType(aFilter[i][4][6][1]))+"',"
	
		if (STransType(aFilter[i][4][9][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][9][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][12][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][12][1],'23:59:59')+"',"
	    end if
		
		cParams += "NULL,"
	elseif cOpcao == "3"
		cCPF := STrim(STransType(aFilter[i][4][6][1]))
		cCPF := strtran(cCPF, '.', '')
		cCPF := strtran(cCPF, '-', '')

		cParams += "1,0,'"+cCPF+"',"
		
		if (STransType(aFilter[i][4][9][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][9][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][12][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][12][1],'23:59:59')+"',"
	    end if
		
		cParams += "NULL,"
	elseif cOpcao == "4"
		cParams += "2,NULL,NULL,"
		
		if (STransType(aFilter[i][4][9][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][9][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][12][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][12][1],'23:59:59')+"',"
	    end if
	    
		cParams += "NULL,"
	elseif cOpcao == "5"
		cParams += "3,NULL,NULL,"
		
		if (STransType(aFilter[i][4][15][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][15][1],'00:00:00')+"',"
		end if
		
		if (STransType(aFilter[i][4][18][1]) ==  '  /  /    ')
		  cParams += "NULL,"
		else
		  cParams += "'"+SDBDate(aFilter[i][4][18][1],'23:59:59')+"',"
	    end if	
		
		cParams += "NULL,"
	endif

	cParams += "'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C907ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1 //Nome
		aZoom := SZoomPess(.T., .T., .F., .F., .T., .F., .F., .F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[2],"C")
			cCodUsu := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
			cCodUsu := ''
		endif

	elseif nTipoZoom == 2 //Documento
		aZoom := SZoomTpDoc()
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	endif

return lRet

function C907VPES(xConteud, o)
	if !SEmpty(xConteud)
		if C907ZOOMP(o, 1)
			return .T.
		else
			Alert(STR0015)
			return .F.
		endif
	else
		cCodUsu := ''
	endif
return

static function C907CTB(aStruct)

	Local aStructDesc := {     ;
	    {"CPF",   10},;
	    {STR0002, 40},;
	    {STR0009, 10},;
	    {STR0010, 10},;
	    {STR0011, 15},;	        	    
	    {STR0018, 15},;
	    {STR0012, 12},;
	    {STR0013, 12},;	    
	    {STR0019, 50},;
	    {"Carteira Nacional de Habilitação (CNH)",   10} ;
	}

	aStruct := {    ;
	    {'CP1'   ,'C',100 ,0},  ;
	    {'CP2'   ,'C',100 ,0},  ;
	    {'CP3'   ,'C',100 ,0},  ;
	    {'CP4'   ,'C',100 ,0},  ;
	    {'CP5'   ,'C',100 ,0},  ;
	    {'CP6'   ,'C',100 ,0},  ;
	    {'CP7'   ,'C',100 ,0},  ;	
	    {'CP8'   ,'C',100 ,0},  ;
	    {'CP9'   ,'C',100 ,0},  ;
	    {'CP10'  ,'C',100 ,0}   ;
	    }

	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc

function C907MOTIVO()
	Local lRet := .T.
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	
	cQuery := " select param_valor from tab_parametro where param_desc = 'Utiliza_Motivo_Acesso' "
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	if (cAlias)->(param_valor) = 'S'
		lRet := .T.
	else
		lRet := .F.
	endif
	
return lRet

