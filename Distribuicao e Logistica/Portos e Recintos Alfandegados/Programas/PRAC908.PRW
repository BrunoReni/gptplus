#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC908.CH"

/*/{Protheus.doc} PRAC908
@author   Marcio Franklin Carvalho de Noronha
@version  P12
@since    12/06/2012
@obs      2.2.3 Extrato consulta - 1.2 - Entrada/Saída de Veículos de Carga
/*/

Function PRAC908()
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
	Private nCodTrans := ''
	Private lFronteira := .F.

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

       lFronteira := C908FRONT()

		oLayer := FWLayer():new() //Cria uma camada na janela
		oLayer:init(oDlg,.T.)
		oLayer:addColumn('Col01',100,.F.) //Adiciona uma coluna na camada
		oLayer:addWindow('Col01','C1_Win01',STR0001,100,.T.,.F.,,,) //Adiciona um componente de windows na camada e coluna

		oPanel  := oLayer:getWinPanel('Col01','C1_Win01') //Recupera o objeto do Window

		//Adiciona no array os campos de filtro da tela
						//Campo, Descricao     , Tipo  , Tamanho, Alias, Mascara, Nil, Zoom            , Validacao                         , ValorPadrao
 		Aadd(aFields, {"P1"   , STR0002      , "C"   , 20     , nil  , ""     , nil, "C908ZOOMP(o, 1)", {|xConteud,o| C908VPL(xConteud, o, 1)} , nil})
 		Aadd(aFields, {"P2"   , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date() - 30)})
 		Aadd(aFields, {"P3"   , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date())})
  		Aadd(aFields, {"P4"   , STR0005      , "C"   , 20     , nil  , ""     , nil, "C908ZOOMP(o, 5)", {|xConteud, o| C908VPL(xConteud, o, 5)} , nil})
  		Aadd(aFields, {"P5"   , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date() - 30)})
  		Aadd(aFields, {"P6"   , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date())})
  		Aadd(aFields, {"P7"   , STR0006      , "C"   , 20     , nil  , ""     , nil, "C908ZOOMP(o, 2)", {|xConteud, o| C908VTRAN(xConteud, o)} , nil})
  		Aadd(aFields, {"P8"   , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date() - 30)})
  		Aadd(aFields, {"P9"   , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date())})
  		Aadd(aFields, {"P10"  , STR0007      , "C"   , 20     , nil  , ""     , nil, "C908ZOOMP(o, 6)", {|xConteud, o| C908VCL(xConteud, o)} , nil})
  		Aadd(aFields, {"P11"  , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                                  , (Date() - 30)})
  		Aadd(aFields, {"P12"  , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                                  , (Date())})
  		Aadd(aFields, {"P13"  , STR0008      , "C"   , 20     , nil  , ""     , nil, "C908ZOOMP(o, 3)", {|xConteud, o| C908VCON(xConteud, o)} , nil})
  		Aadd(aFields, {"P14"  , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                                  , (Date() - 30)})
  		Aadd(aFields, {"P15"  , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                                  , (Date())})
   		Aadd(aFields, {"P16"  , STR0009      , "C"   , 20     , nil  , ""     , nil, "C908ZOOMP(o, 4)", {|xConteud, o| C908VCON(xConteud, o, '3')} , nil})
  		Aadd(aFields, {"P17"  , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date() - 30)})
  		Aadd(aFields, {"P18"  , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date())})
  		Aadd(aFields, {"P19"  , STR0010      , "C"   , 20     , nil  , ""     , nil, nil             , nil                               , nil})
  		Aadd(aFields, {"P20"  , STR0003      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date() - 30)})
  		Aadd(aFields, {"P21"  , STR0004      , "D"   , 10     , nil  , ""     , nil, nil             , nil                               , (Date())})
  		Aadd(aFields, {"P22"  , "Opcao"      , "C"   , 1      , nil  , ""     , nil, nil             , nil                               , nil})

		aStructDesc := C908CTB(@aStruct)

		//Cria um componente de browse no window
		oBrowse := SCBROWSE(oPanel, cAliasTb, aFields)

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","%P1%",@aFilParser)
		SAddFilPar("P2" ,"==","%P2%",@aFilParser)
		SAddFilPar("P3" ,"==","%P3%",@aFilParser)
		SAddFilPar("P4" ,"==","NULL",@aFilParser)
		SAddFilPar("P5" ,"==","NULL",@aFilParser)
		SAddFilPar("P6" ,"==","NULL",@aFilParser)
		SAddFilPar("P7" ,"==","NULL",@aFilParser)
		SAddFilPar("P8" ,"==","NULL",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","0"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0002, "P1=='%P1%' .AND. P2=='%P2%' .AND. P3=='%P3%' .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22=='0'", .F., .F.,nil,.T., aFilParser, '0')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)
		SAddFilPar("P4" ,"==","%P4%",@aFilParser)
		SAddFilPar("P5" ,"==","%P5%",@aFilParser)
		SAddFilPar("P6" ,"==","%P6%",@aFilParser)
		SAddFilPar("P7" ,"==","NULL",@aFilParser)
		SAddFilPar("P8" ,"==","NULL",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","1"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0005, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4=='%P4%' .AND. P5=='%P5%' .AND. P6=='%P6%' .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22=='1'", .F., .F.,nil,.T., aFilParser, '1')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)
		SAddFilPar("P4" ,"==","NULL",@aFilParser)
		SAddFilPar("P5" ,"==","NULL",@aFilParser)
		SAddFilPar("P6" ,"==","NULL",@aFilParser)
		SAddFilPar("P7" ,"==","%P7%",@aFilParser)
		SAddFilPar("P8" ,"==","%P8%",@aFilParser)
		SAddFilPar("P9" ,"==","%P9%",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","2"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0006, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7=='%P7%' .AND. P8=='%P8%' .AND. P9=='%P9%' .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22=='2'", .F., .F.,nil,.T., aFilParser, '2')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)
		SAddFilPar("P4" ,"==","NULL",@aFilParser)
		SAddFilPar("P5" ,"==","NULL",@aFilParser)
		SAddFilPar("P6" ,"==","NULL",@aFilParser)
		SAddFilPar("P7" ,"==","NULL",@aFilParser)
		SAddFilPar("P8" ,"==","NULL",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)
		SAddFilPar("P10","==","%P10%",@aFilParser)
		SAddFilPar("P11","==","%P11%",@aFilParser)
		SAddFilPar("P12","==","%P12%",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","3"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0007, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10=='%P10%' .AND. P11=='%P11%' .AND. P12=='%P12%' .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22=='3'", .F., .F.,nil,.T., aFilParser, '3')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)
		SAddFilPar("P4" ,"==","NULL",@aFilParser)
		SAddFilPar("P5" ,"==","NULL",@aFilParser)
		SAddFilPar("P6" ,"==","NULL",@aFilParser)
		SAddFilPar("P7" ,"==","NULL",@aFilParser)
		SAddFilPar("P8" ,"==","NULL",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","%P13%",@aFilParser)
		SAddFilPar("P14","==","%P14%",@aFilParser)
		SAddFilPar("P15","==","%P15%",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","4"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0008, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13=='%P13%' .AND. P14=='%P14%' .AND. P15=='%P15%' .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22=='4'", .F., .F.,nil,.T., aFilParser, '4')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)
		SAddFilPar("P4" ,"==","NULL",@aFilParser)
		SAddFilPar("P5" ,"==","NULL",@aFilParser)
		SAddFilPar("P6" ,"==","NULL",@aFilParser)
		SAddFilPar("P7" ,"==","NULL",@aFilParser)
		SAddFilPar("P8" ,"==","NULL",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","%P16%",@aFilParser)
		SAddFilPar("P17","==","%P17%",@aFilParser)
		SAddFilPar("P18","==","%P18%",@aFilParser)
		SAddFilPar("P19","==","NULL",@aFilParser)
		SAddFilPar("P20","==","NULL",@aFilParser)
		SAddFilPar("P21","==","NULL",@aFilParser)
		SAddFilPar("P22","==","5"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0009, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16=='%P16%' .AND. P17=='%P17%' .AND. P18=='%P18%' .AND. P19==NULL .AND. P20==NULL .AND. P21==NULL .AND. P22=='5'", .F., .F.,nil,.T., aFilParser, '5')

		//Cria o componente Parse para trabalhar em conjunto com os fields e filtros
		aFilParser := {}
		SAddFilPar("P1" ,"==","NULL",@aFilParser)
		SAddFilPar("P2" ,"==","NULL",@aFilParser)
		SAddFilPar("P3" ,"==","NULL",@aFilParser)
		SAddFilPar("P4" ,"==","NULL",@aFilParser)
		SAddFilPar("P5" ,"==","NULL",@aFilParser)
		SAddFilPar("P6" ,"==","NULL",@aFilParser)
		SAddFilPar("P7" ,"==","NULL",@aFilParser)
		SAddFilPar("P8" ,"==","NULL",@aFilParser)
		SAddFilPar("P9" ,"==","NULL",@aFilParser)
		SAddFilPar("P10","==","NULL",@aFilParser)
		SAddFilPar("P11","==","NULL",@aFilParser)
		SAddFilPar("P12","==","NULL",@aFilParser)
		SAddFilPar("P13","==","NULL",@aFilParser)
		SAddFilPar("P14","==","NULL",@aFilParser)
		SAddFilPar("P15","==","NULL",@aFilParser)
		SAddFilPar("P16","==","NULL",@aFilParser)
		SAddFilPar("P17","==","NULL",@aFilParser)
		SAddFilPar("P18","==","NULL",@aFilParser)
		SAddFilPar("P19","==","%P19%",@aFilParser)
		SAddFilPar("P20","==","%P20%",@aFilParser)
		SAddFilPar("P21","==","%P21%",@aFilParser)
		SAddFilPar("P22","==","6"   ,@aFilParser)
		//Cria um filtro
		oBrowse:AddFilter(STR0010, "P1==NULL .AND. P2==NULL .AND. P3==NULL .AND. P4==NULL .AND. P5==NULL .AND. P6==NULL .AND. P7==NULL .AND. P8==NULL .AND. P9==NULL .AND. P10==NULL .AND. P11==NULL .AND. P12==NULL .AND. P13==NULL .AND. P14==NULL .AND. P15==NULL .AND. P16==NULL .AND. P17==NULL .AND. P18==NULL .AND. P19=='%P19%' .AND. P20=='%P20%' .AND. P21=='%21%' .AND. P22=='6'", .F., .F.,nil,.T., aFilParser, '6')

		//Ativa o browse
		oBrowse:Activate()
		DES_FIL_BW(oBrowse)//Desabilita edicao filtros

		//Funcao que será executada no momento em que o filtro for acionado, para tratar as informações
		oBrowse:oFWFilter:SetExecute({||C908FILTER(oBrowse)})

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

Static Function C908FILTER(oBrowse)
	Local cQuery      := "exec proc_rfb_extrato_1_2_w "
	Local cSql        := "select * from "+cAliasTb
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
		alert(STR0061)
		return
	endif

	//Recupera todos os filtros informado pelo usuário depois da solicitação de informações
	aFilter      := oFilter:GetFilter(.T.)
	//Processa os filtros para recuperar os parametros para as procedures
	if (!C908GF(aFilter, @cParams, @cMsg))
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
		
		if (aStructDesc[nI][1]<>'Motivação do acesso') 
		    oBrowse:SetColumns({oColumn})
		else
		  if C908MOTIVO() 
		     oBrowse:SetColumns({oColumn})		  
		  endif 		   
		endif
	next

	//Atualiza a grid para utilizar as novas informações
	oBrowse:updateBrowse()

Return .T.

static function C908GF(aFilter, cParams, cMsg)
	Local i := 1
	Local nMaxParse := 0
	Local cOpcao := '0'

	if (aFilter == nil .OR. empty(aFilter))
		cMsg := ""
		return .F.
	endif

	cOpcao := STransType(aFilter[i][4][66][1])

	cParams := cOpcao+","

	//Verifica a opção selecionada pelo usuário

	if cOpcao == "0" //POR VEÍCULO
		//Monta a estrutura de parametros para passar para a procedure
		if Rtrim(Ltrim(STransType(aFilter[i][4][3][1]))) <> ''
		   cParams += "'"+STrim(STransType(aFilter[i][4][3][1]))+"'"
		else 
		   cParams += "NULL"
		End if
		cParams += ",NULL,NULL,NULL,NULL,NULL,'"
		cParams += SDBDate(aFilter[i][4][6][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][9][1],'23:59:59')+"'"
	elseif cOpcao == "1" //POR REBOQUE
	    if Rtrim(Ltrim(STransType(aFilter[i][4][12][1]))) <> ''
		   cParams += "'"+STrim(STransType(aFilter[i][4][12][1]))+"'"
		else 
		   cParams += "NULL"
		End if
		cParams += ",NULL,NULL,NULL,NULL,NULL,'"
		cParams += SDBDate(aFilter[i][4][15][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][18][1],'23:59:59')+"'"
	elseif cOpcao == "2" //POR TRANSPORTADORA
	    if Rtrim(Ltrim(STransType(nCodTrans))) <> ''
		   cParams += "NULL,"+STrim(STransType(nCodTrans))+",NULL,NULL,NULL,NULL,'"
		else 
		   cParams += "NULL,NULL,NULL,NULL,NULL,NULL, '"
		End if
		cParams += SDBDate(aFilter[i][4][24][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][27][1],'23:59:59')+"'"
	elseif cOpcao == "3" //POR BENEFICIÁRIO
		if Rtrim(Ltrim(STransType(nCodTrans))) <> ''
	       cParams += "NULL,NULL,"+STrim(STransType(nCodTrans))+",NULL,NULL,NULL,'"
		else 
		   cParams += "NULL,NULL,NULL,NULL,NULL,NULL, '"
		End if
		cParams += SDBDate(aFilter[i][4][33][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][36][1],'23:59:59')+"'"
	elseif cOpcao == "4" //POR CONHECIMENTO DE TRANSPORTE
	    if Rtrim(Ltrim(STransType(aFilter[i][4][39][1]))) <> ''
		   cParams += "NULL,NULL,NULL,'"+STrim(STransType(aFilter[i][4][39][1]))+"',NULL,NULL,'"
		else 
		  cParams += "NULL,NULL,NULL,NULL,NULL,NULL,'"
		End if
		cParams += SDBDate(aFilter[i][4][42][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][45][1],'23:59:59')+"'"
	elseif cOpcao == "5" //POR CE MARCANTE
		if Rtrim(Ltrim(STransType(aFilter[i][4][48][1]))) <> ''		  
		   cParams += "NULL,NULL,NULL,NULL,'"+STrim(STransType(aFilter[i][4][48][1]))+"',NULL,'"
		else 
		   cParams += "NULL,NULL,NULL,NULL,NULL,NULL, '"
		End if
		cParams += SDBDate(aFilter[i][4][51][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][54][1],'23:59:59')+"'"
	elseif cOpcao == "6" //POR UNIQUE CONSIG. NUMBER
		if Rtrim(Ltrim(STransType(aFilter[i][4][57][1]))) <> ''   
		   cParams += "NULL,NULL,NULL,NULL,NULL,'"+STrim(STransType(aFilter[i][4][57][1]))+"','"
		else 
		   cParams += "NULL,NULL,NULL,NULL,NULL,NULL,'"
		End if
		cParams += SDBDate(aFilter[i][4][60][1],'00:00:00')+"','"
		cParams += SDBDate(aFilter[i][4][63][1],'23:59:59')+"'"
	endif

	cParams += ",'"+SGetDBOwner()+cAliasTb+"'"
return .T.

function C908ZOOMP(oObj, nTipoZoom)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.

	if nTipoZoom == 1 //Placa Veículo
		aZoom := SZoomPlaca(.F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	elseif nTipoZoom == 5 //Placa Reboque
		aZoom := SZoomPlaca(.T.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)

		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
		endif
	elseif nTipoZoom == 2 //Transp
		aZoom := SZoomTran2()
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[2],"C")
			nCodTrans := STransType(aRetZoom[1],"C")
		else
			oObj:cText := '                         '
			nCodTrans := ''
		endif
	elseif nTipoZoom == 6 //Benef
		aZoom := SZoomCigCli(.T., .T., .F., .F., .T., .F.)
		aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		if !SEmpty(aRetZoom)
			oObj:cText := STransType(aRetZoom[1],"C")
			nCodTrans := STransType(aRetZoom[2],"C")
		else
			oObj:cText := '                         '
			nCodTrans := ''
		endif
	elseif nTipoZoom == 3 //	Conhecimento
	    aZoom := SZoomConhec(.T.)
		 aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		 if !SEmpty(aRetZoom)
		 	 oObj:cText := STransType(aRetZoom[1],"C")
		 else
		 	 oObj:cText := '                                                  '
		 endif
	elseif nTipoZoom == 4 //	Mercante
	    aZoom := SZoomConhec(.F.,.F.,.T.)
		 aRetZoom := PRAC938(aZoom, oObj:cText, @lRet)
		 if !SEmpty(aRetZoom)
		 	 oObj:cText := STransType(aRetZoom[1],"C")
		 else
		 	 oObj:cText := '                                                  '
		 endif
	endif

return lRet

function C908VPL(xConteud, o,Opc)
	if !SEmpty(xConteud)
		if C908ZOOMP(o, Opc)
			return .T.
		else
			Alert(STR0060)
			return .F.
		endif
	end
return

function C908VTRAN(xConteud, o)
	if !SEmpty(xConteud)
		if C908ZOOMP(o, 2)
			return .T.
		else
			Alert(STR0060)
			return .F.
		end
	end
return

function C908VCL(xConteud, o)
	if !SEmpty(xConteud)
		if C908ZOOMP(o, 6)
			return .T.
		else
			Alert(STR0060)
			return .F.
		end
	end
return

function C908VCON(xConteud, o, cOpc)
	Local cOpcao
	DEFAULT cOpc := '1'

	if cOpc == '3'
	   cOpcao := 4
	else
	   cOpcao := 3
	end if

	if !SEmpty(xConteud)
		if C908ZOOMP(o, cOpcao)
			return .T.
		else
			Alert(STR0060)
			return .F.
		end
	end
return .T.

static function C908CTB(aStruct)
  Local aStructDesc 
  
  
     aStructDesc := {     ;
	      {STR0011, 7},    ;//Operação
	      {STR0012, 15},   ;//Via transporte
	      {STR0013, 15},   ;//Placa caminhão
	      {STR0014, 15},   ;//Placa reboque
	      {STR0015, 15},   ;//Nome embarq/voo
	      {STR0050, 10},   ;//Data atracação	
	      {'Data de desatracação/Saida', 10},;//Data desatracação   
	      {STR0016, 40},   ;//Nome transportadora
	      {STR0017, 15},   ;//CNPJ/CPF Transp.
	      {STR0018, 10},   ;//Tipo documento
	      {STR0019, 15},   ;//Número
	      {STR0020, 10},   ;//Data emissão
	      {STR0021, 15},   ;//Local embarque
	      {STR0022, 40},   ;//Beneficiário
	      {STR0062, 10},   ;//CNPJ/CPF Benef.
	      {STR0023, 40},   ;//Consignatário
	      {STR0063, 10},   ;//CNPJ/CPF Consig.
	      {STR0024, 15},   ;//País
	      {STR0009, 10},   ;//CE Mercadante
	      {STR0010, 10},   ;//Unique Consig. Number
	      {STR0025, 10},   ;//Peso bruto
	      {STR0026, 10},   ;//Peso líquido
	      {STR0027, 15},   ;//Desc. mercadorias
	      {STR0029, 15},   ;//Tipo unidade
	      {STR0030, 10},   ;//M2
	      {STR0031, 10},   ;//M3
	      {STR0032, 10},   ;//Comprimento
	      {STR0033, 10},   ;//Largura
	      {STR0034, 10},   ;//Altura
	      {STR0035, 15},   ;//Número identificador
	      {STR0036, 10},   ;//Dispositivo segurança
	      {STR0037, 10},   ;//Nr. ticket pesagem (ent)
	      {STR0038, 10},   ;//Identificação pesg. (ent)
	      {STR0039, 15},   ;//Tipo unid. pesg. (ent)
	      {STR0040, 10},   ;//Peso entrada (ent)
	      {STR0041, 10},   ;//Peso saída (ent)
	      {STR0042, 10},   ;//Tara (ent)
	      {STR0043, 10},   ;//Tara container (ent)
	      {STR0044, 15},   ;//Peso aferido (ent)
	      {STR0045, 10},   ;//Nr. ticket pesagem (sai)
	      {STR0064, 10},   ;//Identificação pesg. (sai)
	      {STR0065, 10},   ;//Tipo unid. pesg. (sai)
	      {STR0066, 10},   ;//Peso entrada (sai)
	      {STR0067, 10},   ;//Peso saída (sai)
	      {'Tara (sai)', 10},   ;//Tara (sai)
	      {'Tara Container (sai)', 10},   ;//Tara container (sai)
	      {'Peso Aferido (sai)', 10},   ;//Peso aferido (sai)
	      {STR0047, 10},   ;//CPF condutor
	      {STR0048, 10},   ;//CNH condutor
	      {STR0049, 40},   ;//Nome condutor
	      {STR0071, 15},   ;//Função
	      {STR0072, 100},  ;//Motivo de Acesso
	      {STR0051, 10},   ;//Tipo doc. aduaneiro
	      {STR0052, 10},   ;//Numero atracação
	      {STR0053, 15},   ;//Via transp (imp)
	      {STR0054, 15},   ;//Embarcação/voo (imp)
	      {STR0055, 15},   ;//Data atracação (imp)
	      {'Data desatracação (imp)', 15},   ;//Data atracação (imp)
	      {STR0056, 15},   ;//Identificação veículo (imp)
	      {STR0057, 15},   ;//Identificação reboque (imp)
	      {STR0058, 15},   ;//Tipo documento (imp)
	      {STR0059, 20}   ;//Documento aduaneiro
	  }

	  aStruct := {    ;
	      {'CP1'  ,'C',100 ,0},  ;
	      {'CP2'  ,'C',100 ,0},  ;
	      {'CP3'  ,'C',100  ,0},  ;
	      {'CP4'  ,'C',100  ,0},  ;
	      {'CP5'  ,'C',100  ,0},  ;
	      {'CP6'  ,'C',100  ,0},  ;
	      {'CP7'  ,'C',100  ,0},  ; 
	      {'CP8'  ,'C',100  ,0},  ;
	      {'CP9'  ,'C',100  ,0},  ;
	      {'CP10' ,'C',100  ,0},  ;
	      {'CP11' ,'C',100  ,0},  ;
	      {'CP12' ,'C',100  ,0},  ;
	      {'CP13' ,'C',100  ,0},  ;
	      {'CP14' ,'C',100  ,0},  ;
	      {'CP15' ,'C',100  ,0},  ;
	      {'CP16' ,'C',100  ,0},  ;
	      {'CP17' ,'C',100  ,0},  ;
	      {'CP18' ,'C',100  ,0},  ;
	      {'CP19' ,'C',100  ,0},  ;
	      {'CP20' ,'C',100  ,0},  ;
	      {'CP21' ,'C',100  ,0},  ;
	      {'CP22' ,'C',100  ,0},  ;
	      {'CP24' ,'C',100  ,0},  ;
	      {'CP25' ,'C',100  ,0},  ;
	      {'CP26' ,'C',100  ,0},  ;
	      {'CP27' ,'C',100  ,0},  ;
	      {'CP28' ,'C',100  ,0},  ;
	      {'CP29' ,'C',100  ,0},  ;
	      {'CP30' ,'C',100  ,0},  ;
	      {'CP31' ,'C',100  ,0},  ;
	      {'CP32' ,'C',100  ,0},  ;
	      {'CP33' ,'C',100  ,0},  ;
	      {'CP34' ,'C',100  ,0},  ;
	      {'CP35' ,'C',100  ,0},  ;
	      {'CP36' ,'C',100  ,0},  ;
	      {'CP37' ,'C',100  ,0},  ;
	      {'CP38' ,'C',100  ,0},  ;
	      {'CP39' ,'C',100  ,0},  ;
	      {'CP40' ,'C',100  ,0},  ;
	      {'CP41' ,'C',100  ,0},  ;
	      {'CP42' ,'C',100  ,0},  ;
	      {'CP43' ,'C',100  ,0},  ;
	      {'CP44' ,'C',100  ,0},  ;
	      {'CP45' ,'C',100  ,0},  ;
	      {'CP46' ,'C',100  ,0},  ;
	      {'CP47' ,'C',100  ,0},  ;
	      {'CP48' ,'C',100  ,0},  ;
	      {'CP49' ,'C',100  ,0},  ;
	      {'CP50' ,'C',100  ,0},  ;
	      {'CP51' ,'C',100  ,0},  ;
	      {'CP52' ,'C',100  ,0},  ; 
	      {'CP53' ,'C',255  ,0},  ; 
	      {'CP54' ,'C',100  ,0},  ;
	      {'CP55' ,'C',100  ,0},  ;
	      {'CP56' ,'C',100  ,0},  ;
	      {'CP57' ,'C',100  ,0},  ;
	      {'CP58' ,'C',100  ,0},  ;
	      {'CP59' ,'C',100  ,0},  ;
	      {'CP60' ,'C',100  ,0},  ;
	      {'CP61' ,'C',100  ,0},  ;
	      {'CP62' ,'C',100  ,0},  ;
	      {'CP63' ,'C',100  ,0};  
	  }   
   
  	SDelTb(cAliasTb)
	SCriaTb(cAliasTb, aStruct)
return aStructDesc
 
function C908FRONT()
	Local lRet := .T.
	Local cQuery := ''
	Local cAlias := GetNextAlias()
	
	cQuery := " select param_valor from tab_parametro where param_desc = 'FRONTEIRA' "
	           
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	if (cAlias)->(param_valor) = '1'
		lRet := .T.
	else
		lRet := .F.
	endif
	
return lRet

function C908MOTIVO()
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
 