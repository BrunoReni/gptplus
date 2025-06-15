#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpdetails.CH"

#DEFINE ARRAY_POS_CHAVE	            1
#DEFINE ARRAY_POS_EMPRESA           2
#DEFINE ARRAY_POS_TICKET            3
#DEFINE ARRAY_POS_PRODUTO           4
#DEFINE ARRAY_POS_ID_OPCIONAL       5
#DEFINE ARRAY_POS_PERIODO           6
#DEFINE ARRAY_POS_TIPO_DOCUMENTO    7
#DEFINE ARRAY_POS_CODIGO_DOCUMENTO  8
#DEFINE ARRAY_POS_PRODUTO_PAI       9
#DEFINE ARRAY_POS_TIPO_REGISTRO     10
#DEFINE ARRAY_POS_QUANTIDADE        11
#DEFINE ARRAY_POS_DOC_MRP           12
#DEFINE ARRAY_POS_QTD_TOTAL         13
#DEFINE ARRAY_POS_SIZE              13

Static _oQryHWG   := Nil
Static _oQryAGL   := Nil
Static _lHWCAglut := Nil
Static _cTpEstSeg := Nil
Static _cTpPontoP := Nil

/*/{Protheus.doc} mrpdetails
API de detalhes dos resultados do MRP

@type  WSCLASS
@author renan.roeder
@since 31/01/2022
@version P12.1.37
/*/
WSRESTFUL mrpdetails DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Detalhes dos resultados do MRP"
	WSDATA branchId   AS STRING OPTIONAL
	WSDATA document   AS STRING OPTIONAL
	WSDATA ticket     AS STRING
	WSDATA product    AS STRING
	WSDATA idOpc      AS STRING OPTIONAL
	WSDATA periodFrom AS STRING OPTIONAL
	WSDATA periodTo   AS STRING OPTIONAL
	WSDATA type       AS STRING OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL

	WSMETHOD GET DETAILS;
		DESCRIPTION STR0002; //"Retorna os resultados do cálculo do MRP para o ticket e produto especificados"
		WSSYNTAX "api/pcp/v1/mrpdetails/{ticket}/{product}" ;
		PATH "api/pcp/v1/mrpdetails/{ticket}/{product}" ;
		TTALK "v1"
	
	WSMETHOD GET TRANSFER;
		DESCRIPTION STR0006; //"Retorna todas as transferências de um produto para um ticket (SMA)"
		WSSYNTAX "api/pcp/v1/mrpdetails/transferences/{ticket}/{product}" ;
		PATH "api/pcp/v1/mrpdetails/transferences/{ticket}/{product}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET DETAILS api/pcp/v1/mrpdetails/{ticket}/{product}
Retorna os detalhes dos resultados do mrp

@type WSMETHOD
@author renan.roeder
@since 31/01/2022
@version P12.1.37
@param 01 ticket     , Caracter, código único do processo para fazer a pesquisa
@param 02 product    , Caracter, código do produto
@param 03 branchId   , Caracter, filial considerada no filtro
@param 04 periodFrom , Caracter, periodo inicial do calculo a ser considerado
@param 05 periodTo   , Caracter, periodo final do calculo a ser considerado
@param 06 idOpc      , Caracter, identificador do opcional
@param 07 document   , Caracter, identificador do documento considerado no filtro
@param 08 type       , Caracter, tipo de registro considerado no filtro
@param 09 nPage      , Number  , Página de busca
@param 10 nPageSize  , Number  , tamanho da página
@return   lRet       , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET DETAILS PATHPARAM ticket, product WSRECEIVE branchId, periodFrom, periodTo, idOpc, document, type, Page, PageSize WSSERVICE mrpdetails

	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getResDet(Self:ticket, Self:product, Self:branchId, Self:periodFrom, Self:periodTo, Self:idOpc, Self:document, Self:type, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} getResDet
Retorna os detalhes dos resultados do mrp

@type Function
@author renan.roeder
@since 31/01/2022
@version P12.1.37
@param 01 cTicket   , Caracter, código único do processo
@param 02 cProduct  , Caracter, código do produto
@param 03 cBranchId , Caracter, código da filial
@param 04 cPerFrom  , Caracter, código inicial do filtro de periodo
@param 05 cPerTo    , Caracter, código final do filtro de periodo
@param 06 cIdOpc    , Caracter, identificador do opcional
@param 07 cDocument , Caracter, documento considerado no filtro
@param 08 cTypeReg  , Caracter, tipo de registro
@param 09 nPage     , Number  , Página de busca
@param 10 nPageSize , Number  , tamanho da página
@return   aReturn   , Array   , Array com as informacoes da requisicao
/*/
Function getResDet(cTicket, cProduct, cBranchId, cPerFrom, cPerTo, cIdOpc, cDocument, cTypeReg, nPage, nPageSize)
	Local aDadosSP   := {}
	Local aResult    := {}
	Local aCalculo   := {}
	Local aReturn    := {}
	Local cBanco     := TCGetDB()
	Local cTipos     := ""
	Local cTiposFil  := ""
	Local cQueryHWC  := ""
	Local cQuerySMV  := ""
	Local cAliasHWC  := GetNextAlias()
	Local cAliasSMV  := GetNextAlias()
	Local cContrData := ""
	Local cDocType   := ""
	Local cDocumento := ""
	Local cOpEmp     := ""
	Local cProdPai   := ""
	Local cRecno     := ""
	Local cRegOrder  := ""
	Local cType      := ""
	Local lAglutina  := vldAglut(cProduct, cTicket)
	Local lGerouDoc  := gerouDoc(cTicket)
	Local lUsaME     := MrpTiktME(cTicket, .T.)[2]["useMultiBranches"]
	Local nIndCalc   := 0
	Local nIndResult := 0
	Local nPosDivPai := 0
	Local nTamQtd    := GetSx3Cache("MV_QUANT", "X3_TAMANHO")
	Local nDecQtd    := GetSx3Cache("MV_QUANT", "X3_DECIMAL")
	Local nQtCalc    := 0
	Local nQuant     := 0
	Local nPos       := 0
	Local nRegStart  := 0
	Local nRegEnd    := 0
	Local oJsAglut   := Nil
	Local oJsonRet   := JsonObject():New()
	Local oJsonAGL   := JsonObject():New()
	Local oJsDocTran := JsonObject():New()
	Local oJsDocDem  := JsonObject():New()
	Local oTranfAgl  := JsonObject():New()

	Default cIdOpc    := ""
	Default nPage     := 1
	Default nPageSize := 20
	
	If !AliasInDic("SMV")
		aAdd(aReturn, .F.)
		aAdd(aReturn, STR0005) //"Tabela SMV não existe no dicionário de dados"
		aAdd(aReturn, 400)
		FreeObj(oJsonRet)
		Return aReturn
	EndIf

	If Empty(_cTpEstSeg)
		_cTpEstSeg := MrpDGetSTR("ES")
		_cTpPontoP := MrpDGetSTR("PP")
	EndIf

	cTipos    := "|"+_cTpEstSeg+"|"+_cTpPontoP+"|Pré-OP|SUBPRD|ESTNEG|TRANF_PR|LTVENC|0|1|2|3|4|5|9|"
	cTiposFil := "|"+_cTpEstSeg+"|"+_cTpPontoP+"|SUBPRD|ESTNEG|"
	// Se cIdOpc estiver vazio, seta com um espaço em branco para buscar corretamente em banco de dados ORACLE.
	If Empty(cIdOpc)
		cIdOpc := " " 
	EndIf

	cQuerySMV += "SELECT MV_FILIAL, "
	cQuerySMV +=       " MV_TICKET, "
	cQuerySMV +=       " MV_PRODUT, "
	cQuerySMV +=       " MV_IDOPC, "
	cQuerySMV +=       " MV_DATAMRP, "
	cQuerySMV +=       " MV_TIPDOC, "
	cQuerySMV +=       " MV_DOCUM, "
	cQuerySMV +=       " MV_TIPREG, "
	cQuerySMV +=       " MV_TABELA, "
	cQuerySMV +=       " MV_QUANT, "
	cQuerySMV +=       " CASE "
	cQuerySMV +=        " WHEN MV_TABELA = 'T4Q' THEN "
	cQuerySMV +=            " (SELECT PAI.T4Q_PROD "
	cQuerySMV +=               " FROM "+RetSqlName("T4Q")+" FILHO "
	cQuerySMV +=              " INNER JOIN "+RetSqlName("T4Q")+" PAI  "
	cQuerySMV +=                 " ON FILHO.T4Q_FILIAL = PAI.T4Q_FILIAL "
	cQuerySMV +=                " AND FILHO.T4Q_OPPAI  = PAI.T4Q_OP "
	cQuerySMV +=              " WHERE FILHO.T4Q_OP = MV_DOCUM ) "
	cQuerySMV +=        " WHEN MV_TABELA = 'T4T' THEN "
	cQuerySMV +=            " (SELECT PAI.T4Q_PROD "
	cQuerySMV +=               " FROM "+RetSqlName("T4T")+" FILHO  "
	cQuerySMV +=              " INNER JOIN "+RetSqlName("T4Q")+" PAI  "
	cQuerySMV +=                 " ON FILHO.T4T_FILIAL = PAI.T4Q_FILIAL "
	cQuerySMV +=                " AND FILHO.T4T_OP = PAI.T4Q_OP  "
	
	If "MSSQL" $ cBanco
		cQuerySMV +=          " WHERE FILHO.T4T_NUM + FILHO.T4T_SEQ = MV_DOCUM ) "
	Else
		cQuerySMV +=          " WHERE FILHO.T4T_NUM || FILHO.T4T_SEQ = MV_DOCUM ) "
	EndIf
	cQuerySMV +=        " WHEN MV_TABELA = 'T4U' THEN "
	cQuerySMV +=            " (SELECT PAI.T4Q_PROD "
	cQuerySMV +=               " FROM "+RetSqlName("T4U")+" FILHO  "
	cQuerySMV +=              " INNER JOIN "+RetSqlName("T4Q")+" PAI  "
	cQuerySMV +=                 " ON FILHO.T4U_FILIAL = PAI.T4Q_FILIAL "
	cQuerySMV +=                " AND FILHO.T4U_OP     = PAI.T4Q_OP  "
	
	If "MSSQL" $ cBanco
		cQuerySMV +=          " WHERE FILHO.T4U_NUM + FILHO.T4U_SEQ = MV_DOCUM ) "
	Else
		cQuerySMV +=          " WHERE FILHO.T4U_NUM || FILHO.T4U_SEQ = MV_DOCUM ) "
	EndIf
	
	cQuerySMV +=        " ELSE ' ' "
	cQuerySMV +=       " END PRODPAI "
	cQuerySMV += " FROM ( SELECT MV_FILIAL, "
	cQuerySMV +=               " MV_TICKET, "
	cQuerySMV +=               " MV_PRODUT, "
	cQuerySMV +=               " MV_IDOPC, "
	cQuerySMV +=               " MV_DATAMRP, "
	cQuerySMV +=               " MV_TIPDOC, "
	cQuerySMV +=               " MV_DOCUM, "
	cQuerySMV +=               " MV_TIPREG, "
	cQuerySMV +=               " MV_TABELA, "
	cQuerySMV +=               " SUM(MV_QUANT) AS MV_QUANT "
	cQuerySMV +=          " FROM " + RetSqlName("SMV")
	cQuerySMV +=         " WHERE MV_TICKET = '" + cTicket  + "'"
	cQuerySMV +=           " AND MV_PRODUT = '" + cProduct + "'"
	cQuerySMV +=           " AND MV_IDOPC  = '" + cIdOpc   + "'"
	cQuerySMV +=           " AND NOT EXISTS (SELECT 1 "
	cQuerySMV +=                             " FROM " + RetSqlName("HWG") + " HWG "
	cQuerySMV +=                            " INNER JOIN " + RetSqlName("HWC") + " HWC "
	cQuerySMV +=                              "  ON HWC.HWC_DOCPAI = HWG.HWG_DOCAGL "
	cQuerySMV +=                              " AND HWC.HWC_TICKET = HWG.HWG_TICKET "
	cQuerySMV +=                              " AND HWC.HWC_TPDCPA = '1' "
	cQuerySMV +=                            " WHERE HWG.HWG_TICKET = MV_TICKET "
	cQuerySMV +=                              " AND HWG.HWG_DOCORI = MV_DOCUM "
	cQuerySMV +=                              " AND MV_TABELA = 'T4J' "
	cQuerySMV +=                            " UNION "
	cQuerySMV +=                           " SELECT 1 "
	cQuerySMV +=                             " FROM " + RetSqlName("HWC") + " HWC "
	cQuerySMV +=                            " WHERE HWC.HWC_TICKET = MV_TICKET "
	cQuerySMV +=                              " AND HWC.HWC_DOCPAI = MV_DOCUM "
	cQuerySMV +=                              " AND HWC.HWC_TPDCPA = '1' "
	cQuerySMV +=                              " AND MV_TABELA = 'T4J') "

	If !Empty(cBranchId)
		cQuerySMV +=                          " AND MV_FILIAL = '"+cBranchId+"'"
	EndIf

	If !Empty(cPerTo)
		cQuerySMV +=                          " AND MV_DATAMRP <= '" + convDate(cPerTo, 2) + "'"
	EndIf

	cQuerySMV +=      " GROUP BY MV_FILIAL, "
	cQuerySMV +=               " MV_TICKET, "
	cQuerySMV +=               " MV_PRODUT, "
	cQuerySMV +=               " MV_IDOPC, "
	cQuerySMV +=               " MV_DATAMRP, "
	cQuerySMV +=               " MV_TIPDOC, "
	cQuerySMV +=               " MV_DOCUM, "
	cQuerySMV +=               " MV_TIPREG, "
	cQuerySMV +=               " MV_TABELA) INTERNO "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySMV),cAliasSMV,.F.,.F.)
	TcSetField(cAliasSMV, "MV_QUANT", "N", nTamQtd, nDecQtd)
	
	While (cAliasSMV)->(!Eof())
		cRecno     := "0" + Soma1(cRecno)
		cDocumento := (cAliasSMV)->MV_DOCUM
		cProdPai   := (cAliasSMV)->PRODPAI
		Do Case
			Case (cAliasSMV)->MV_TABELA == "T4V" // Saldo Inicial
				cRegOrder := "|00|"
				cDocType  := "SI"

			Case Trim((cAliasSMV)->MV_TABELA) == "ET" // Em Terceiro
				cRegOrder := "|01|"
				cDocType  := "ET"

			Case Trim((cAliasSMV)->MV_TABELA) == "DT" //De Terceiro
				cRegOrder := "|02|"
				cDocType  := "DT"

			Case Trim((cAliasSMV)->MV_TABELA) == "SB" //Saldo Bloqueado
				cRegOrder := "|03|"
				cDocType  := "SB"

			Case (cAliasSMV)->MV_TABELA == "HWX" //Saldo Rejeitado
				cRegOrder := "|04|"
				cDocType  := "SR"

			Case (cAliasSMV)->MV_TABELA == "T4S" //Empenho
				cRegOrder  := "|11|"
				cDocType   := "EM"
				nPosDivPai := At("|", cDocumento)
				cProdPai   := Left(cDocumento, (nPosDivPai-1))
				cDocumento := opEmp(AllTrim((cAliasSMV)->MV_DOCUM))

			Case (cAliasSMV)->MV_TABELA == "T4J" //"Demanda
				cRegOrder := "|12|"
				cDocType  := "DM"
				oJsDocDem[RTrim((cAliasSMV)->MV_DOCUM)] := trataDcDem(RTrim((cAliasSMV)->MV_DOCUM), lUsaME)

			Case (cAliasSMV)->MV_TABELA == "T4Q" //Ordem de Produção
				cRegOrder := "|13|"
				cDocType  := "OP"

			Case (cAliasSMV)->MV_TABELA == "T4T" //Solicitação de Compra
				cRegOrder := "|14|"
				cDocType  := "SC"

			Case (cAliasSMV)->MV_TABELA == "T4U" //Pedido de Compra
				cRegOrder := "|15|"
				cDocType  := "PC"

			Otherwise
				cRegOrder := "|16|"
				cDocType  := (cAliasSMV)->MV_TIPDOC
		EndCase

		addToCalc(@aCalculo                               , ;
		          (cAliasSMV)->MV_DATAMRP+cRegOrder+cRecno, ;
		          (cAliasSMV)->MV_FILIAL                  , ;
		          (cAliasSMV)->MV_TICKET                  , ;
		          (cAliasSMV)->MV_PRODUT                  , ;
		          (cAliasSMV)->MV_IDOPC                   , ;
		          (cAliasSMV)->MV_DATAMRP                 , ;
		          cDocType                                , ;
		          cDocumento                              , ;
		          cProdPai                                , ;
		          (cAliasSMV)->MV_TIPREG                  , ;
		          (cAliasSMV)->MV_QUANT                   , ;
		          ""                                       )
		(cAliasSMV)->(dbSkip())
	End
	(cAliasSMV)->(dbCloseArea())

	cQueryHWC := "SELECT HWC.HWC_FILIAL,"
	cQueryHWC +=       " HWC.HWC_TICKET,"
	cQueryHWC +=       " HWC.HWC_PRODUT,"
	cQueryHWC +=       " HWC.HWC_IDOPC,"
	cQueryHWC +=       " HWC.HWC_DATA,"
	cQueryHWC +=       " HWC.HWC_TPDCPA,"
	cQueryHWC +=       " HWC.HWC_DOCPAI,"
	cQueryHWC +=       " HWC.HWC_DOCERP,"
	cQueryHWC +=       " HWC.HWC_QTNEOR,"
	cQueryHWC +=       " HWC.HWC_QTNECE,"
	cQueryHWC +=       " HWC.HWC_QTRSAI,"
	cQueryHWC +=       " HWC.HWC_DOCFIL,"
	cQueryHWC +=       " HWB.HWB_NIVEL,"
	cQueryHWC +=       " PAI.HWC_PRODUT PROD_PAI,"
	cQueryHWC +=       " HWC.R_E_C_N_O_"

	If temHWCAglu()
		cQueryHWC +=   " ,HWC.HWC_AGLUT "
	Else
		cQueryHWC +=   " ,' ' HWC_AGLUT "
	EndIf

	cQueryHWC +=  " FROM " + RetSqlName("HWC") + " HWC "
	cQueryHWC += " INNER JOIN " + RetSqlName("HWB") + " HWB "
	cQueryHWC +=    " ON HWC.HWC_FILIAL = HWB.HWB_FILIAL"
	cQueryHWC +=   " AND HWC.HWC_TICKET = HWB.HWB_TICKET"
	cQueryHWC +=   " AND HWC.HWC_PRODUT = HWB.HWB_PRODUT"
	cQueryHWC +=   " AND HWC.HWC_DATA   = HWB.HWB_DATA"
	cQueryHWC +=   " AND HWC.HWC_IDOPC  = HWB.HWB_IDOPC"

	cQueryHWC +=  " LEFT OUTER JOIN " + RetSqlName("HWC") + " PAI"
	cQueryHWC +=    " ON HWC.HWC_FILIAL = PAI.HWC_FILIAL"
	cQueryHWC +=   " AND HWC.HWC_TICKET = PAI.HWC_TICKET"
	cQueryHWC +=   " AND HWC.HWC_DOCPAI = PAI.HWC_DOCFIL"

	cQueryHWC += " WHERE HWC.HWC_TICKET = '" + cTicket  + "'"
	cQueryHWC +=   " AND HWC.HWC_PRODUT = '" + cProduct + "'"
	cQueryHWC +=   " AND HWC.HWC_IDOPC = '" + cIdOpc + "'"
	
	If !Empty(cBranchId)
		cQueryHWC += " AND HWC.HWC_FILIAL = '"+cBranchId+"'"
	EndIf
	If !Empty(cPerTo)
		cQueryHWC += " AND HWC.HWC_DATA <= '" + convDate(cPerTo, 2) + "'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryHWC),cAliasHWC,.F.,.F.)

	TcSetField(cAliasHWC, "HWC_QTNEOR", "N", nTamQtd, nDecQtd)
	TcSetField(cAliasHWC, "HWC_QTNECE", "N", nTamQtd, nDecQtd)

	While (cAliasHWC)->(!Eof())
		cRecno   := cValToChar((cAliasHWC)->R_E_C_N_O_)
		cProdPai := (cAliasHWC)->PROD_PAI
		cDocType := IIf((cAliasHWC)->HWB_NIVEL == "99", "SC", "OP")

		If docTranf((cAliasHWC)->HWC_DOCFIL)
			oJsDocTran[(cAliasHWC)->HWC_DOCFIL] := {RTrim((cAliasHWC)->HWC_DOCPAI), ""}
			If Trim((cAliasHWC)->HWC_TPDCPA) $ cTiposFil
				oJsDocTran[(cAliasHWC)->HWC_DOCFIL][2] := RTrim((cAliasHWC)->HWC_FILIAL)
			EndIf
		EndIf

		/*
			Valida se o registro deve ser exibido na lista conforme o tipo de documento pai.
			A validação está aqui e não na query, pois todos os tipos devem gerar o json
			de controle "oJsDocTran".
		*/
		If (Trim((cAliasHWC)->HWC_TPDCPA) $ cTipos) == .F.
			(cAliasHWC)->(dbSkip())
			Loop
		EndIf

		Do Case
			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == _cTpEstSeg //"Est.Seg."
				cType    := "|10|"
				cDocType := "ES"
				
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,STR0004, cProdPai, "2", (cAliasHWC)->HWC_QTNEOR, (cAliasHWC)->HWC_DOCPAI) //"Segurança"

				cType    := "|20|"
				cDocType := IIf((cAliasHWC)->HWB_NIVEL == "99", "SC", "OP")
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai ,"1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "Pré-OP"
				cType    := "|21|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "1"//plano mestre
				cType    := "|19|"
				cDocType := "PM"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) $ "0|2|3|4|5|9"
				cType    := "|22|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "SUBPRD"
				cType    := "|17|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, (cAliasHWC)->HWC_DOCPAI, cProdPai, "1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "ESTNEG"
				cType    := "|18|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == _cTpPontoP //"Ponto Ped."
				cType    := "|30|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, (cAliasHWC)->HWC_DOCPAI)
				
			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "TRANF_PR"
				If Empty((cAliasHWC)->HWC_AGLUT)
					cType    := "|24|"
					cDocType := "TR"
					addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP) , cProdPai, "1", (cAliasHWC)->HWC_QTRSAI, (cAliasHWC)->HWC_DOCPAI)
				Else
					oTranfAgl[Trim((cAliasHWC)->HWC_AGLUT)] := .T.
				EndIf
			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "LTVENC"
				cType    := "|01|"
				cDocType := "LV"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, fmtLtVenc((cAliasHWC)->HWC_DOCPAI), "", "2", (cAliasHWC)->HWC_QTNEOR, (cAliasHWC)->HWC_DOCPAI)
		EndCase
		
		(cAliasHWC)->(dbSkip())
	End
	(cAliasHWC)->(dbCloseArea())

	cQueryHWC := "SELECT OP.HWC_FILIAL,"
	cQueryHWC +=       " OP.HWC_TICKET,"
	cQueryHWC +=       " OP.HWC_PRODUT,"
	cQueryHWC +=       " OP.HWC_IDOPC,"
	cQueryHWC +=       " OP.HWC_DATA,"
	cQueryHWC +=       " OP.HWC_TPDCPA,"
	cQueryHWC +=       " OP.HWC_DOCPAI,"
	cQueryHWC +=       " OP.HWC_DOCERP,"
	cQueryHWC +=       " OP.HWC_QTEMPE,"
	cQueryHWC +=       " OP.HWC_QTNECE,"
	cQueryHWC +=       " PAI.HWC_PRODUT PROD_PAI,"
	cQueryHWC +=       " HWB.HWB_NIVEL,"
 	cQueryHWC +=       " OP.R_E_C_N_O_,"
	cQueryHWC +=       " OP.HWC_QTNEOR,"

	If lAglutina
		cQueryHWC +=   " ' ' opEmpenhada "
	Else
		cQueryHWC += " PAI.HWC_DOCERP opEmpenhada "
	EndIf
	
	cQueryHWC +=  " FROM " + RetSqlName("HWC") + " OP"
	cQueryHWC += " INNER JOIN " + RetSqlName("HWB") + " HWB"
	cQueryHWC +=    " ON HWB.HWB_FILIAL = OP.HWC_FILIAL "
	cQueryHWC +=   " AND HWB.HWB_TICKET = OP.HWC_TICKET "
	cQueryHWC +=   " AND HWB.HWB_DATA   = OP.HWC_DATA "
	cQueryHWC +=   " AND HWB.HWB_PRODUT = OP.HWC_PRODUT "
	cQueryHWC +=   " AND HWB.HWB_IDOPC  = OP.HWC_IDOPC "
	cQueryHWC +=   " AND HWB.D_E_L_E_T_ = ' ' "
	cQueryHWC +=  " LEFT OUTER JOIN " + RetSqlName("HWC") + " PAI"
	cQueryHWC +=    " ON PAI.HWC_FILIAL = OP.HWC_FILIAL "
	cQueryHWC +=   " AND PAI.HWC_TICKET = OP.HWC_TICKET "
	cQueryHWC +=   " AND PAI.HWC_DOCFIL = OP.HWC_DOCPAI "
	cQueryHWC += " WHERE OP.HWC_TICKET = '" + cTicket  + "'"
	cQueryHWC +=   " AND OP.HWC_PRODUT = '" + cProduct + "'"
	cQueryHWC +=   " AND OP.HWC_TPDCPA IN ('OP','AGL') "
	cQueryHWC +=   " AND OP.HWC_IDOPC = '" + cIdOpc + "'"
	cQueryHWC +=   " AND OP.D_E_L_E_T_ = ' ' "

	If !Empty(cBranchId)
		cQueryHWC += " AND OP.HWC_FILIAL = '"+cBranchId+"'"
	EndIf

	If !Empty(cPerTo)
		cQueryHWC += " AND OP.HWC_DATA <= '" + convDate(cPerTo, 2) + "'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryHWC),cAliasHWC,.F.,.F.)

	TcSetField(cAliasHWC, "HWC_QTEMPE", "N", nTamQtd, nDecQtd)
	TcSetField(cAliasHWC, "HWC_QTNECE", "N", nTamQtd, nDecQtd)

	While (cAliasHWC)->(!Eof())
		cOpEmp   := (cAliasHWC)->(opEmpenhada)
		cRecno   := cValToChar((cAliasHWC)->R_E_C_N_O_)
		cProdPai := (cAliasHWC)->PROD_PAI

		If Empty(cOpEmp)
			cOpEmp := " "
		EndIf

		nQuant   := (cAliasHWC)->HWC_QTEMPE
		cType    := "|11|"
		cDocType := "EM"
		addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA, cDocType,Iif( lGerouDoc, cOpEmp, (cAliasHWC)->HWC_DOCPAI), cProdPai, "2", nQuant, (cAliasHWC)->HWC_DOCPAI) 
		
		nQuant   := (cAliasHWC)->HWC_QTNECE
		cType    := "|23|"
		cDocType := IIf((cAliasHWC)->HWB_NIVEL == "99", "SC", "OP")
		
		If oTranfAgl:HasProperty(Trim((cAliasHWC)->HWC_DOCPAI))
			cDocType := "OT"
		EndIf
		
		addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA, cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), (cAliasHWC)->HWC_DOCPAI, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", nQuant, (cAliasHWC)->HWC_DOCPAI)

		(cAliasHWC)->(dbSkip())
	End
	(cAliasHWC)->(dbCloseArea())

	//Ordena resultados pela chave
	If Len(aCalculo) > 0
		aCalculo := aSort( aCalculo,,, { | x,y | x[1] < y[1] })

		cContrData := aCalculo[1][6]//inicializa controle de datas
	EndIf

	For nIndCalc := 1 To Len(aCalculo)

		If cContrData != aCalculo[nIndCalc][ARRAY_POS_PERIODO]
			//A cada mudança de data incluir saldo do período no array
			aDadosSP := Array(ARRAY_POS_SIZE)

			aDadosSP[ARRAY_POS_CHAVE           ] := aCalculo[nIndCalc][ARRAY_POS_CHAVE]
			aDadosSP[ARRAY_POS_EMPRESA         ] := " "
			aDadosSP[ARRAY_POS_TICKET          ] := aCalculo[nIndCalc][ARRAY_POS_TICKET]
			aDadosSP[ARRAY_POS_PRODUTO         ] := aCalculo[nIndCalc][ARRAY_POS_PRODUTO]
			aDadosSP[ARRAY_POS_ID_OPCIONAL     ] := aCalculo[nIndCalc][ARRAY_POS_ID_OPCIONAL]
			aDadosSP[ARRAY_POS_PERIODO         ] := aCalculo[nIndCalc][ARRAY_POS_PERIODO]
			aDadosSP[ARRAY_POS_TIPO_DOCUMENTO  ] := "SP"
			aDadosSP[ARRAY_POS_CODIGO_DOCUMENTO] := " "
			aDadosSP[ARRAY_POS_PRODUTO_PAI     ] := " "
			aDadosSP[ARRAY_POS_TIPO_REGISTRO   ] := "4"
			aDadosSP[ARRAY_POS_QUANTIDADE      ] := " "
			aDadosSP[ARRAY_POS_DOC_MRP         ] := " "
			aDadosSP[ARRAY_POS_QTD_TOTAL       ] := nQtCalc

			aAdd(aResult, aDadosSP)

			cContrData := aCalculo[nIndCalc][ARRAY_POS_PERIODO]
		EndIf

		If aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] == "1" .Or. aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] == "3"
			nQtCalc += aCalculo[nIndCalc][ARRAY_POS_QUANTIDADE]
		ElseIf aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] == "2"
			nQtCalc -= aCalculo[nIndCalc][ARRAY_POS_QUANTIDADE]
		EndIf
		nQtCalc := Round(nQtCalc, nDecQtd)

		//Filtros
		If !Empty(cPerFrom) .And. aCalculo[nIndCalc][ARRAY_POS_PERIODO] < cPerFrom
			Loop
		EndIf
		If !Empty(cTypeReg) .And. aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] != cTypeReg
			Loop
		EndIf
		If !Empty(cDocument) .And. aCalculo[nIndCalc][ARRAY_POS_CODIGO_DOCUMENTO] != cDocument
			Loop 
		EndIf

		aCalculo[nIndCalc][ARRAY_POS_QTD_TOTAL] := nQtCalc
		aAdd(aResult, aCalculo[nIndCalc])
				
	Next nIndCalc

	//define a paginação
	If nPage == 1
		nRegStart := nPage	
		nRegEnd   := nPageSize
	Else
		nRegStart := ((nPage-1) * nPageSize)+1
		nRegEnd   := nPage * nPageSize
	EndIf
	//impede que o laço seja maior que o array de resultados
	If nRegEnd > Len(aResult)
		nRegEnd := Len(aResult)
	EndIf

	getHWG(cTicket, cProduct, @oJsonAGL, lUsaME, @oJsDocDem)

	oJsonRet["items"] := {}
	oJsonRet["hasNext"] := .F.
	//preenche json de resultados
	For nIndResult := nRegStart To nRegEnd
	
		aAdd(oJsonRet["items"], JsonObject():New())
		nPos++
		
		oJsonRet["items"][nPos]["branchId"     ] := aResult[nIndResult][ARRAY_POS_EMPRESA] 
		oJsonRet["items"][nPos]["ticket"       ] := aResult[nIndResult][ARRAY_POS_TICKET] 
		oJsonRet["items"][nPos]["product"      ] := aResult[nIndResult][ARRAY_POS_PRODUTO] 
		oJsonRet["items"][nPos]["optionalId"   ] := aResult[nIndResult][ARRAY_POS_ID_OPCIONAL] 
		oJsonRet["items"][nPos]["periodDate"   ] := aResult[nIndResult][ARRAY_POS_PERIODO] 
		oJsonRet["items"][nPos]["documentType" ] := aResult[nIndResult][ARRAY_POS_TIPO_DOCUMENTO] 
		oJsonRet["items"][nPos]["documentCode" ] := aResult[nIndResult][ARRAY_POS_CODIGO_DOCUMENTO] 
		oJsonRet["items"][nPos]["fatherProduct"] := aResult[nIndResult][ARRAY_POS_PRODUTO_PAI] 
		oJsonRet["items"][nPos]["registerType" ] := aResult[nIndResult][ARRAY_POS_TIPO_REGISTRO] 
		oJsonRet["items"][nPos]["quantity"     ] := aResult[nIndResult][ARRAY_POS_QUANTIDADE] 
		oJsonRet["items"][nPos]["balance"      ] := aResult[nIndResult][ARRAY_POS_QTD_TOTAL]

		If oJsDocDem:HasProperty(oJsonRet["items"][nPos]["documentCode"])
			oJsonRet["items"][nPos]["documentCode"] := oJsDocDem[oJsonRet["items"][nPos]["documentCode"]]
		EndIf

		cDocumento := aResult[nIndResult][ARRAY_POS_DOC_MRP]

		If docTranf(cDocumento) .And. oJsDocTran:HasProperty(cDocumento)
			//Se for um documento de transferência, altera para buscar os detalhes do 
			//documento que originou a transferência na filial de origem
			cDocumento := oJsDocTran[cDocumento][1]
		EndIf

		If oJsonAGL:HasProperty(cDocumento)
			If docTranf(cDocumento)
				//Caso o documento de transferência tenha sido aglutinado, busca as origens existentes a partir de oJsonAGL
				oJsonRet["items"][nPos]["detail"] := detTrfAgl(cTicket, cDocumento, @oJsonAGL)
			Else
				oJsonRet["items"][nPos]["detail"] := oJsonAGL[cDocumento]
			EndIf

			If Len(oJsonAGL[cDocumento]) == 1
				oJsonRet["items"][nPos]["fatherProduct"] := oJsonAGL[cDocumento][1]["prodOrigem"]
			EndIf
		ElseIf SUBSTR(cDocumento, 0, 3) == 'AGL'
			oJsonRet["items"][nPos]["detail"] := buscaAgl(cDocumento, cTicket, oJsonAGL)

		ElseIf aResult[nIndResult][ARRAY_POS_TIPO_DOCUMENTO] == "TR"
			oJsonRet["items"][nPos]["detail"] := {JsonObject():New()}
			oJsonRet["items"][nPos]["detail"][1]["prodOrigem"] := RTrim(aResult[nIndResult][ARRAY_POS_PRODUTO])
			oJsonRet["items"][nPos]["detail"][1]["quantidade"] := aResult[nIndResult][ARRAY_POS_QUANTIDADE]
			oJsonRet["items"][nPos]["detail"][1]["docOrigem" ] := cDocumento

			If oJsDocTran:HasProperty(aResult[nIndResult][ARRAY_POS_DOC_MRP]) .And.;
			   !Empty(oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][2])
				
				oJsonRet["items"][nPos]["detail"][1]["docOrigem"] := STR0010 + ": " + ; //Filial
				                                                     oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][2] +;
				                                                     "| " + RTrim(oJsonRet["items"][nPos]["detail"][1]["docOrigem"])
			EndIf
		ElseIf aResult[nIndResult][ARRAY_POS_TIPO_REGISTRO] == "1" .And.;
		       !Empty(aResult[nIndResult][ARRAY_POS_DOC_MRP])      .And.;
		       RTrim(aResult[nIndResult][ARRAY_POS_DOC_MRP]) <> RTrim(aResult[nIndResult][ARRAY_POS_CODIGO_DOCUMENTO])
			//Caso não aglutine, verifica se o doc entrada é uma OP real, e adiciona como detalhe a demanda que originou a necessidade
			oJsonRet["items"][nPos]["detail"] := {JsonObject():New()}
			oJsonRet["items"][nPos]["detail"][1]["prodOrigem"] := RTrim(aResult[nIndResult][ARRAY_POS_PRODUTO])
			oJsonRet["items"][nPos]["detail"][1]["quantidade"] := aResult[nIndResult][ARRAY_POS_QUANTIDADE]
			oJsonRet["items"][nPos]["detail"][1]["docOrigem" ] := aResult[nIndResult][ARRAY_POS_DOC_MRP]
		EndIf

		If oJsonRet["items"][nPos]:HasProperty("detail") 
			ajustaDcDm(oJsonRet["items"][nPos]["detail"], oJsDocDem)
		EndIf

	Next nIndResult

	If nRegEnd < Len(aResult)
		oJsonRet["hasNext"] := .T.
	EndIf
	
	If Len(oJsonRet["items"]) > 0
		aAdd(aReturn, .T.)
		aAdd(aReturn, EncodeUTF8(oJsonRet:toJSON()))
		aAdd(aReturn, 200)
	Else
		aAdd(aReturn, .F.)
		aAdd(aReturn, EncodeUTF8(STR0003)) //"Não foram encontrados registros com os parâmetros passados."
		aAdd(aReturn, 204)
	EndIf

	FwFreeArray(aResult)
	FwFreeArray(aCalculo)

	aSize(oJsonRet["items"], 0)
	FreeObj(oJsonRet)
	FreeObj(oJsAglut)
	FreeObj(oJsDocTran)
	FreeObj(oJsDocDem)
	FreeObj(oTranfAgl)
Return aReturn

/*/{Protheus.doc} addToCalc
Adiciona um registro no JSON que está armazenando as informações que serão retornadas

@type Function
@author renan.roeder
@since 31/01/2022
@version P12.1.37
@param 01 aCalculo , Array  , Array com os dados do período
@param 02 cChave   , Caracter, chave do json
@param 03 cFilCalc , Caracter, filial
@param 04 cTicket  , Caracter, ticket
@param 05 cProduct , Caracter, produto
@param 06 cIdOPC   , Caracter, ID do Opcional do produto
@param 07 cPeriod  , Caracter, período do MRP
@param 08 cDocType , Caracter, tipo do documento
@param 09 cDocument, Caracter, descrição do documento
@param 10 cProdPai , Caracter, código do produto pai (usado para empenhos)
@param 11 cRegType , Caracter, tipo do registro (saldo,entrada,saída)
@param 12 nQuant   , Numeric , quantidade do documento
@param 13 cDocMrp  , Caracter, Número do documento interno no MRP
@return Nil
/*/
Static Function addToCalc(aCalculo, cChave, cFilCalc, cTicket, cProduct, cIdOPC, cPeriod, cDocType, cDocument, cProdPai, cRegType, nQuant, cDocMrp)
	Local aAux := {}

	//Se a quantidade for zero, não precisa listar
	If nQuant == 0
		Return
	EndIf 

	cIdOPC := getOpciona(cFilCalc, cTicket, cIdOPC)

	aAux := Array(ARRAY_POS_SIZE)

	aAux[ARRAY_POS_CHAVE           ] := RTrim(cChave)
	aAux[ARRAY_POS_EMPRESA         ] := RTrim(cFilCalc)
	aAux[ARRAY_POS_TICKET          ] := RTrim(cTicket)
	aAux[ARRAY_POS_PRODUTO         ] := RTrim(cProduct)
	aAux[ARRAY_POS_ID_OPCIONAL     ] := RTrim(cIdOPC)
	aAux[ARRAY_POS_PERIODO         ] := convDate(RTrim(cPeriod), 1)
	aAux[ARRAY_POS_TIPO_DOCUMENTO  ] := RTrim(cDocType)
	aAux[ARRAY_POS_CODIGO_DOCUMENTO] := RTrim(cDocument)
	aAux[ARRAY_POS_PRODUTO_PAI     ] := RTrim(cProdPai)
	aAux[ARRAY_POS_TIPO_REGISTRO   ] := RTrim(cRegType)
	aAux[ARRAY_POS_QUANTIDADE      ] := nQuant
	aAux[ARRAY_POS_DOC_MRP         ] := RTrim(cDocMrp)
	aAux[ARRAY_POS_QTD_TOTAL       ] := 0 // Inicia com 0. Será definido na montagem dos dados que vão para a tela.

	aAdd(aCalculo, aAux)

Return

/*/{Protheus.doc} getOpciona
Retorna a string do opcional a ser exibida

@type Function
@author marcelo.neumann
@since 07/02/2022
@version P12.1.37
@param 01 cFilCalc, Caracter, filial
@param 02 cTicket , Caracter, ticket do MRP
@param 03 cIdOPC  , Caracter, ID do opcional a ser pesquisado
@return cOpcional , Caracter, string opcional referente ao ID passado
/*/
Static Function getOpciona(cFilCalc, cTicket, cIdOPC)
	Local aRetOpc   := {}
	Local cOpcional := ""
	Local oJsonOpc  := Nil

	If !Empty(cIdOPC)
		aRetOpc := MrpGetOPC(cFilCalc, cTicket, cIdOPC)
		If aRetOpc[1]
			oJsonOpc := JsonObject():New()
			oJsonOpc:fromJson(aRetOpc[2])
			cOpcional := oJsonOpc["optionalString"]
			FreeObj(oJsonOpc)
		EndIf
		aSize(aRetOpc, 0)
	EndIf

Return cOpcional


/*/{Protheus.doc} convDate
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD também o inverso

@type  Static Function
@author douglas.heydt
@since 15/03/2022
@version P12.1.27
@param cData, Character, Data no formato AAAAMMDD
@param nType, Character, Tipo da formatação necessária 
			nType 1 = AAAAMMDD para AAAA-MM-DD; 
			nType 2 = AAAA-MM-DD para AAAAMMDD;
@return cData, Character, Data no formato AAAA-MM-DD
/*/
Static Function convDate(dData, nType)
	Local cData := ""
	If nType == 1
		cData := Left(dData, 4) + "-" + SubStr(dData, 5, 2) + "-" + Right(dData, 2)
	else
		cData := REPLACE(dData,"-", "")
	endIf
		
Return cData


/*/{Protheus.doc} getHWG
Busca detalhamento de registros aglutinados

@type  Static Function
@author douglas.heydt
@since 01/06/2022
@version P12.1.27
@param 01 cTicket  , Character, Codigo único do processo para fazer a busca.
@param 02 cProduto , Character, Código do produto.
@param 03 oJsonAgl , Object   , Objeto Json que vai conter os registros.
@param 04 lUsaMe   , Logic    , Identifica se utiliza multi-empresa
@param 05 oJsDocDem, Object   , Json que guarda o documento de demandas formatado para exibição na tela.
/*/
Function getHWG(cTicket, cProduto, oJsonAgl, lUsaME, oJsDocDem)
	Local cAliasQry := ""
	Local cQuery    := ""
	Local cDocAnt   := ""
	Local cDocAgl   := ""
	Local cDocOri   := ""
	Local nPos      := 1

	If _oQryHWG == Nil 
		cQuery := " SELECT (CASE WHEN HWG.HWG_DOCAGL LIKE 'EMP%' "
		cQuery +=        " THEN (SELECT SMV.MV_DOCUM "
		cQuery +=                " FROM " + RetSqlName("SMV") + " SMV "
		cQuery +=               " WHERE SMV.MV_DOCUM LIKE '%|' + HWG.HWG_DOCORI "
		cQuery +=                 " AND SMV.MV_TICKET = HWG.HWG_TICKET "
		cQuery +=                 " AND SMV.MV_PRODUT = HWG.HWG_PROD "
		cQuery +=                 " AND SMV.MV_TABELA = 'T4S' "
		cQuery +=                 " AND SMV.D_E_L_E_T_ = ' ') "
		cQuery +=        " ELSE HWG.HWG_PRODOR END) HWG_PRODOR, "
		cQuery +=        " HWG.HWG_DOCORI, "
		cQuery +=        " HWG.HWG_NECESS, "
		cQuery +=        " HWG.HWG_QTEMPE, "
		cQuery +=        " HWG.HWG_DOCAGL, "
		cQuery +=        " HWC.HWC_DOCERP, "
		cQuery +=        " HWG.HWG_PROD,    " 
		cQuery +=        " HWG.HWG_QTRSAI  " 
		cQuery +=    " FROM " + RetSqlName("HWG") + " HWG "
		cQuery +=    " LEFT OUTER JOIN " + RetSqlName("HWC") + " HWC "
		cQuery +=     " ON HWC.HWC_TICKET = HWG.HWG_TICKET "
		cQuery +=    " AND HWC.HWC_DOCPAI = HWG.HWG_DOCORI "
		cQuery +=    " AND HWC.HWC_SEQUEN = HWG.HWG_SEQORI "
		cQuery +=    " AND HWC.HWC_PRODUT = HWG.HWG_PRODOR "
		DbSelectArea("HWG")
		If FieldPos("HWG_DOCFIL") > 0
			cQuery += " AND HWC.HWC_DOCFIL = HWG.HWG_DOCFIL "
		EndIf
		cQuery +=  " WHERE HWG.HWG_TICKET = ?"
		cQuery +=    " AND HWG.HWG_PROD   = ?"
		cQuery +=    " AND HWG.HWG_TPDCOR <> 'TRANF_ES' "
		cQuery +=  " ORDER BY HWG.HWG_DOCAGL "

		If Upper(TCGetDb()) $ "POSTGRES|ORACLE"
			cQuery := StrTran(cQuery, '+', '||')
		EndIf
		_oQryHWG := FwExecStatement():New(cQuery)
	EndIf

	_oQryHWG:SetString(1, cTicket)
	_oQryHWG:SetString(2, cProduto)

	cAliasQry := _oQryHWG:OpenAlias()

	While (cAliasQry)->(!Eof())
		cDocAgl := AllTrim((cAliasQry)->HWG_DOCAGL)
		If cDocAgl <> cDocAnt
			nPos := 0
			oJsonAgl[cDocAgl] := {}
		EndIf
		
		If Left(cDocAgl, 3) == "DEM" 
			cDocOri := RTrim((cAliasQry)->HWG_DOCORI)
			If oJsDocDem:HasProperty(cDocOri) == .F.
				oJsDocDem[cDocOri] := trataDcDem(cDocOri, lUsaME)
			EndIf
		EndIf
		
		nPos++
		aAdd(oJsonAgl[cDocAgl], JsonObject():New() )
		If SUBSTR(cDocAgl, 0, 3) == 'EMP'
			oJsonAgl[cDocAgl][nPos]['prodOrigem'] := Strtokarr2((cAliasQry)->HWG_PRODOR, "|", .T.)[1]
			oJsonAgl[cDocAgl][nPos]['docOrigem' ] := opEmp((cAliasQry)->HWG_DOCORI)
		Else
			oJsonAgl[cDocAgl][nPos]['prodOrigem'] := Iif(!Empty((cAliasQry)->HWG_PRODOR), (cAliasQry)->HWG_PRODOR, (cAliasQry)->HWG_PROD)
			oJsonAgl[cDocAgl][nPos]['docOrigem' ] := Iif(!Empty((cAliasQry)->HWC_DOCERP), (cAliasQry)->HWC_DOCERP, (cAliasQry)->HWG_DOCORI)
		EndIf
		
		oJsonAgl[cDocAgl][nPos]['quantidade'] := 0
		If(cAliasQry)->HWG_NECESS > 0
			oJsonAgl[cDocAgl][nPos]['quantidade'] := (cAliasQry)->HWG_NECESS
		ElseIf (cAliasQry)->HWG_QTEMPE > 0
			oJsonAgl[cDocAgl][nPos]['quantidade'] := (cAliasQry)->HWG_QTEMPE
		ElseIf (cAliasQry)->HWG_QTRSAI > 0
			oJsonAgl[cDocAgl][nPos]['quantidade'] := (cAliasQry)->HWG_QTRSAI
		EndIf

		cDocAnt   := cDocAgl
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())
	
Return 

/*/{Protheus.doc} GET TRANSFER api/pcp/v1/mrpdetails/transferences/{ticket}
Busca os registros de transferências que devem ser processados

@type  WSMETHOD
@author douglas.Heydt
@since 01/06/2022
@version P12
@param 01 ticket     , Character, Codigo único do processo para fazer a pesquisa.
@param 02 product    , Character, Código do produto para filtrar a consulta. Se vazio, não será realizado filtro.
@param 03 periodFrom , Caracter, periodo inicial do calculo a ser considerado
@param 04 periodTo   , Caracter, periodo final do calculo a ser considerado
@param 05 nPage      , Number  , Página de busca
@param 06 nPageSize  , Number  , tamanho da página

/*/
WSMETHOD GET TRANSFER PATHPARAM ticket, product QUERYPARAM periodFrom, periodTo, Page,PageSize  WSSERVICE mrpdetails
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getTrf(Self:ticket, Self:product, Self:periodFrom, Self:periodTo, Self:Page, Self:PageSize )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} getTrf
Busca os registros de transferencias de um produto (SMA)

@type  Function
@author douglas.heydt
@since 03/06/2022
@version P12
@param 01 cTicket   , Character, Codigo único do processo para fazer a pesquisa.
@param 02 cProduto  , Character, Código do produto para filtrar a consulta. Se vazio, não será realizado filtro.
@param 03 cPerFrom  , Caracter , periodo inicial do calculo a ser considerado
@param 04 cPerTo    , Caracter , periodo final do calculo a ser considerado
@param 05 nPage     , Number   , Página de busca
@param 06 nPageSize , Number   , tamanho da página

@return   aResult , Array    , Resultado da consulta.
                               [1] - Lógico. Indica se encontrou ou não registros
                               [2] - Dados retornados. Se lRetJSON = .T., os dados serão JsonObject.
                                                       Se lRetJson = .F., os dados serão uma string JSON.
                               [3] - Numeric. Código HTTP de resposta.
/*/
Static Function getTrf(cTicket, cProduto, cPerFrom, cPerTo, nPage, nPageSize )
	Local aResult 	:= {.T.,"",200}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nStart    := 0
	Local oDados    := JsonObject():New()

	Default nPage    := 1
	Default nPageSize:= 20

	aResult[1] := .F.
	aResult[3] := 400

	If FWAliasInDic("SMA", .F.)
		cQuery := " SELECT SMA.MA_FILIAL, "
		cQuery +=        " SMA.MA_FILORIG, "
		cQuery +=        " SMA.MA_FILDEST, "
		cQuery +=        " SMA.MA_PROD, "
		cQuery +=        " SMA.MA_TICKET, "
		cQuery +=        " SMA.MA_DTTRANS, "
		cQuery +=        " SMA.MA_DTRECEB, "
		cQuery +=        " SMA.MA_QTDTRAN, "
		cQuery +=        " SMA.MA_ARMORIG, "
		cQuery +=        " SMA.MA_ARMDEST, "
		cQuery +=        " SMA.MA_DOCUM, "
		cQuery +=        " SMA.MA_STATUS, "
		cQuery +=        " SMA.MA_MSG, "
		cQuery +=        " SMA.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("SMA") + " SMA "
		cQuery +=  " WHERE SMA.MA_TICKET  = '" + cTicket + "' "
		cQuery +=    " AND SMA.MA_FILIAL  = '" + xFilial("SMA") + "' "
		cQuery +=    " AND SMA.D_E_L_E_T_ = ' ' "
		cQuery += " AND SMA.MA_PROD = '" + cProduto + "' "

		If !Empty(cPerFrom)
			cQuery += "	AND SMA.MA_DTTRANS >= '"+convDate(cPerFrom, 2)+"' "
		EndIf

		If !Empty(cPerTo)
			cQuery += " AND SMA.MA_DTTRANS <= '"+convDate(cPerTo, 2)+"' "
		EndIf

		cQuery +=  " ORDER BY SMA.MA_FILORIG, SMA.MA_DTTRANS, SMA.MA_PROD"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

		oDados["items"] := {}

		If nPage > 1
			nStart := ( (nPage-1) * nPageSize )
			If nStart > 0
				(cAliasQry)->(DbSkip(nStart))
			EndIf
		EndIf

		nPos := 0
		While (cAliasQry)->(!Eof())

			aAdd(oDados["items"], JsonObject():New())
			nPos++

			oDados["items"][nPos]['branchId'            ] := (cAliasQry)->MA_FILIAL
			oDados["items"][nPos]['originBranchId'      ] := (cAliasQry)->MA_FILORIG
			oDados["items"][nPos]['destinyBranchId'     ] := (cAliasQry)->MA_FILDEST
			oDados["items"][nPos]['product'             ] := (cAliasQry)->MA_PROD
			oDados["items"][nPos]['transferenceDate'    ] := convDate((cAliasQry)->MA_DTTRANS, 1)   
			oDados["items"][nPos]['receiptDate'         ] := convDate((cAliasQry)->MA_DTRECEB, 1)
			oDados["items"][nPos]['transferenceQuantity'] := (cAliasQry)->MA_QTDTRAN
			oDados["items"][nPos]['originWarehouse'     ] := (cAliasQry)->MA_ARMORIG
			oDados["items"][nPos]['destinyWarehouse'    ] := (cAliasQry)->MA_ARMDEST
			IF (cAliasQry)->MA_STATUS == '1'
				oDados["items"][nPos]['document'        ] := (cAliasQry)->MA_MSG
			ELSE
				oDados["items"][nPos]['document'        ] := (cAliasQry)->MA_DOCUM
			ENDIF

			oDados["items"][nPos]['status'              ] := (cAliasQry)->MA_STATUS

			If Empty((cAliasQry)->MA_MSG) .Or. (cAliasQry)->MA_STATUS != '2'
				oDados["items"][nPos]["message" ] := {''}
			Else
				oDados["items"][nPos]["message" ] := {'message', EncodeUTF8((cAliasQry)->MA_MSG)}
			EndIf
			
			oDados["items"][nPos]['ticket'              ] := (cAliasQry)->MA_TICKET
			oDados["items"][nPos]['recordNumber'        ] := (cAliasQry)->R_E_C_N_O_

			(cAliasQry)->(dbSkip())

			//Verifica tamanho da página
			If nPos >= nPageSize
				Exit
			EndIf     
		End
		oDados["hasNext"] := (cAliasQry)->(!Eof())

		(cAliasQry)->(dbCloseArea())
		
		aResult[2] := oDados:toJson()

		If nPos > 0
			aResult[1] := .T.
			aResult[3] := 200
		Else
			aResult[1] := .F.
			aResult[3] := 204
		EndIf

		aSize(oDados["items"],0)
	EndIf

	FreeObj(oDados)

Return aResult

/*/{Protheus.doc} fmtLtVenc
Formata o documento de lote vencido.
@type  Static Function
@author Lucas Fagundes
@since 11/08/2022
@version P12
@param cDocPai, Caracter, Informações do lote/sub-lote/validade.
@return cDocFmt, Caracter, Documento formatado.
/*/
Static Function fmtLtVenc(cDocPai)
	Local cDocFmt := ""

	cDocFmt := STR0007 + cDocPai // "Armazém: "

Return cDocFmt

/*/{Protheus.doc} vldAglut
Retorna se aglutinou OP/SC de acordo com o nível do produto na tabela HWA.
@type  Static Function
@author Lucas Fagundes
@since 06/10/2022
@version P12
@param 01 cProduto, Caracter, Produto para buscar o nível.
@param 02 cTicket , Caracter, Ticket que irá verificar se aglutinou.
@return lAglut, Logico, Retorna se aglutinou dependendo do nível do produto.
/*/
Static Function vldAglut(cProduto, cTicket)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local lAglut := .F.

	cQuery := " SELECT CASE "
	cQuery +=        " WHEN HWA.HWA_NIVEL = '99' THEN (SELECT HW1.HW1_VAL "
	cQuery +=                                          " FROM " + RetSqlName("HW1") + " HW1 "
	cQuery +=                                         " WHERE HW1.HW1_TICKET = '" + cTicket + "' "
	cQuery +=                                           " AND HW1.HW1_PARAM  = 'consolidatePurchaseRequest') "
	cQuery +=        " ELSE (SELECT HW1.HW1_VAL "
	cQuery +=                " FROM " + RetSqlName("HW1") + " HW1 "
	cQuery +=               " WHERE HW1.HW1_TICKET = '" + cTicket + "' "
	cQuery +=                 " AND HW1.HW1_PARAM  = 'consolidateProductionOrder') "
	cQuery +=        " END aglutina "
	cQuery +=   " FROM " + RetSqlName("HWA") + " HWA "
	cQuery +=  " WHERE HWA.HWA_PROD = '" + cProduto + "' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If (cAlias)->(!EoF())
		lAglut := (cAlias)->(aglutina) == "1"
	EndIf
	(cAlias)->(dbCloseArea())

Return lAglut

/*/{Protheus.doc} opEmp
Quebra a chave do empenho montada no cálculo e retorna a ordem de produção para exibir na tela.
@type  Static Function
@author Lucas Fagundes
@since 10/10/2022
@version P12
@param cChaveEmp, Caracter, Chave do empenho que irá buscar a op.
@return cOp, Caracter, Ordem de produção que será exibida na tela.
/*/
Static Function opEmp(cChaveEmp)
	Local aChave := Strtokarr2(cChaveEmp, ";", .T.)
	Local cOP := ""

	/*
	* aChave[1] == T4S_FILIAL
	* aChave[2] == T4S_PROD
	* aChave[3] == T4S_SEQ
	* aChave[4] == T4S_LOCAL
	* aChave[5] == T4S_OP
	* aChave[6] == T4S_OPORIG
	* aChave[7] == T4S_DT
	*/
	cOP := aChave[5]

	aSize(aChave, 0)
Return cOP

/*/{Protheus.doc} gerouDoc
Consulta o status do ticket e retorna se gerou documento ou não.
@type  Static Function
@author Lucas Fagundes
@since 10/10/2022
@version P12
@param cTicket, Caracter, Ticket que irá consultar o status
@return lGerou, lGerou, Retorna .T. se gerou os documentos
/*/
Static Function gerouDoc(cTicket)
	Local lGerou := .F.

	HW3->(DbSetOrder(1)) // HW3_FILIAL+HW3_TICKET
	If HW3->(DbSeek(xFilial('HW3')+PadR(AllTrim(cTicket), GetSx3Cache("HW3_TICKET", "X3_TAMANHO"))))
		lGerou := HW3->HW3_STATUS == "6" .Or. HW3->HW3_STATUS == "7" .Or. HW3->HW3_STATUS == "9"
	EndIf

Return lGerou

/*/{Protheus.doc} buscaAgl
Busca os documentos aglutinados a partir do código do documento aglutinador
@type  Static Function
@author Lucas Fagundes
@since 11/10/2022
@version P12
@param 01 cCodAgl , Caracter  , Documento aglutinador que irá buscar os aglutinados.
@param 02 cTicket , Caracter  , Ticket do MRP que irá buscar os doumentos.
@param 03 oJsonAGL, JsonObject, JSON com os dados dos documentos aglutinados
@return aAgl, Array, Array com os documentos aglutinados (já formatado para exibir nos detalhes da tela).
/*/
Static Function buscaAgl(cCodAgl, cTicket, oJsonAGL)
	Local aAgl     := {}
	Local aRetAux  := {}
	Local cAlias   := ""
	Local cDoc     := ""
	Local cQuery   := ""
	Local lAddAgl  := .T.
	Local nLenAgl  := 0
	Local oJsonAux := Nil

	If !temHWCAglu()
		Return aAgl
	EndIf

	If _oQryAGL == Nil
		cQuery += " SELECT HWC.HWC_FILIAL, "
		cQuery +=        " HWC.HWC_DOCPAI, "
		cQuery +=        " HWC.HWC_DOCERP, "
		cQuery +=        " HWC.HWC_QTNEOR, "
		cQuery +=        " HWC.HWC_PRODUT, "
		cQuery +=        " HWC.HWC_TPDCPA, "
		cQuery +=        " HWG.HWG_DOCORI, "
		cQuery +=        " HWG.HWG_TPDCOR, "
		cQuery +=        " HWG.HWG_NECESS, "
		cQuery +=        " HWG.HWG_PRODOR, "
		cQuery +=        " HWG.HWG_QTRSAI, "
		cQuery +=        " (SELECT erpHWC.HWC_DOCERP "
		cQuery +=           " FROM " + RetSqlName("HWC") + " erpHWC "
		cQuery +=          " WHERE erpHWC.HWC_TICKET = HWG.HWG_TICKET "
		cQuery +=            " AND  erpHWC.HWC_DOCPAI = HWG.HWG_DOCORI "
		cQuery +=            " AND  erpHWC.HWC_DOCFIL = HWG.HWG_DOCFIL) documentoErpHWC"
		cQuery +=   " FROM " + RetSqlName("HWC") + " HWC "
		cQuery +=   " LEFT OUTER JOIN " + RetSqlName("HWG") + " HWG "
		cQuery +=     " ON HWG.HWG_DOCAGL = HWC.HWC_DOCPAI "
		cQuery +=    " AND HWG.HWG_TICKET = HWC.HWC_TICKET "
		cQuery +=  " WHERE HWC.HWC_TICKET = ?"
		cQuery +=    " AND HWC.HWC_AGLUT  = ?"
		cQuery +=    " AND HWC.D_E_L_E_T_ = ' '"

		_oQryAGL := FwExecStatement():New(cQuery)
	EndIf

	_oQryAGL:SetString(1, cTicket)
	_oQryAGL:SetString(2, cCodAgl)
		
	cAlias := _oQryAGL:OpenAlias()
	While (cAlias)->(!Eof())
		lAddAgl  := .T.
		oJsonAux := JsonObject():New()

		If    !Empty((cAlias)->HWG_DOCORI) ;
		.And. Left((cAlias)->HWG_DOCORI, 3) == "AGL" ;
		.And. RTrim((cAlias)->HWG_PRODOR)   == RTrim((cAlias)->HWC_PRODUT)
			
			lAddAgl := .F.
			aRetAux := buscaAgl((cAlias)->HWG_DOCORI, cTicket, @oJsonAGL)
			nLenAgl := Len(aAgl)
			aSize(aAgl, nLenAgl + Len( aRetAux ))
			aCopy(aRetAux, aAgl, /*nInicio*/, /*nFim*/, nLenAgl+1)
			aRetAux := {}

		ElseIf !Empty((cAlias)->HWG_DOCORI)
			If !Empty((cAlias)->(documentoErpHWC))
				oJsonAux["docOrigem"] := (cAlias)->(documentoErpHWC)
			ElseIf AllTrim((cAlias)->HWG_TPDCOR) == "Pré-OP"
				oJsonAux["docOrigem"] := opEmp((cAlias)->HWG_DOCORI)
			Else
				oJsonAux["docOrigem"] := (cAlias)->HWG_DOCORI
			EndIf

			oJsonAux["prodOrigem"] := Iif(!Empty((cAlias)->HWG_PRODOR), (cAlias)->HWG_PRODOR, (cAlias)->HWC_PRODUT)
			oJsonAux["quantidade"] := (cAlias)->HWG_NECESS

		Else
			If !Empty((cAlias)->HWC_DOCERP)
				oJsonAux["docOrigem"] := (cAlias)->HWC_DOCERP
			ElseIf AllTrim((cAlias)->HWC_TPDCPA) == "Pré-OP"
				oJsonAux["docOrigem"] := opEmp((cAlias)->HWC_DOCPAI)
			Else
				oJsonAux["docOrigem"] := (cAlias)->HWC_DOCPAI
			EndIf

			If AllTrim((cAlias)->HWC_TPDCPA) $ "|" + _cTpEstSeg + "|" + _cTpPontoP + "|"
				oJsonAux["docOrigem"] := STR0010 + ": " + (cAlias)->(HWC_FILIAL) + "|" + RTrim(oJsonAux["docOrigem"]) //"Filial"
			EndIf

			oJsonAux["prodOrigem"] := (cAlias)->HWC_PRODUT
			oJsonAux["quantidade"] := (cAlias)->HWC_QTNEOR
		EndIf

		If lAddAgl .And. AllTrim((cAlias)->HWC_TPDCPA) == "TRANF_PR"
			cDoc                   := RTrim(oJsonAux["docOrigem"])
			oJsonAux["quantidade"] := (cAlias)->HWG_QTRSAI
			If oJsonAGL:HasProperty(cDoc)
				nLenAgl := Len(aAgl)
				aSize(aAgl, nLenAgl + Len( oJsonAGL[cDoc] ))
				aCopy(oJsonAGL[cDoc], aAgl, /*nInicio*/, /*nFim*/, nLenAgl+1)
				lAddAgl := .F.
			EndIf
		EndIf

		If lAddAgl
			aAdd(aAgl, oJsonAux)
		EndIf
		oJsonAux := Nil
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return aAgl

/*/{Protheus.doc} docTranf
Verifica se um número de documento é referente a uma transferência

@type  Static Function
@author lucas.franca
@since 10/05/2023
@version P12
@param cDocumento, Caracter, Número do documento para avaliação
@return lTranf, Logic, .T. se o documento for uma transferência
/*/
Static Function docTranf(cDocumento)
	Local lTranf := .F.

	If Left(cDocumento, 5) == "TRANF"
		lTranf := .T.
	EndIf
	
Return lTranf

/*/{Protheus.doc} detTrfAgl
Monta o retorno de detalhes para uma linha do tipo Transferência quando existe aglutinação.

@type  Static Function
@author lucas.franca
@since 10/05/2023
@version P12
@param 01 cTicket   , Caracter  , Número do ticket do MRP
@param 02 cDocumento, Caracter  , Número do documento que está sendo retornado
@param 03 oJsonAGL  , JsonObject, JSON com os dados de aglutinação carregados 
@return aDet, Array, Array com os dados de detalhe da transferência
/*/
Static Function detTrfAgl(cTicket, cDocumento, oJsonAGL)
	Local aAgl    := Nil
	Local aDet    := {}
	Local cDoc    := ""
	Local nLenDet := 0
	Local nIndex  := 0
	Local nTotal  := Len(oJsonAGL[cDocumento])

	For nIndex := 1 To nTotal
		cDoc    := RTrim(oJsonAGL[cDocumento][nIndex]["docOrigem"])
		nLenDet := Len(aDet) 
		If oJsonAGL:HasProperty( cDoc )
			aSize(aDet, nLenDet + Len( oJsonAGL[ cDoc ] ))
			aCopy(oJsonAGL[ cDoc ], aDet, /*nInicio*/, /*nFim*/, nLenDet+1)
		Else
			aAgl := buscaAgl(cDoc, cTicket, oJsonAGL)
			If !Empty(aAgl)
				aSize(aDet, nLenDet + Len( aAgl ))
				aCopy(aAgl, aDet, /*nInicio*/, /*nFim*/, nLenDet+1)
				aAgl := Nil
			EndIf
		EndIf
	Next nIndex
Return aDet

/*/{Protheus.doc} temHWCAglu
Valida se existe na base o campo HWC_AGLUT.

@type  Static Function
@author lucas.franca
@since 11/05/2023
@version P12
@return _lHWCAglut, Logic, Identifica se possui o campo HWC_AGLUT
/*/
Static Function temHWCAglu()
	If _lHWCAglut == Nil
		DbSelectArea("HWC")
		_lHWCAglut := FieldPos("HWC_AGLUT") > 0
	EndIf	
Return _lHWCAglut

/*/{Protheus.doc} trataDcDem
Trata a exibição para os documentos que são relacionados a alguma demanda.

@type  Static Function
@author lucas.franca
@since 11/05/2023
@version P12
@param 01 cDoc  , Caracter, Documento para conversão
@param 02 lUsaME, Logic, Identifica se utiliza multi-empresas
@return cDocRet, Caracter, Documento formatado
/*/
Static Function trataDcDem(cDoc, lUsaME)
	Local cDocRet := ""
	Local cVrFil  := P136GetInf(cDoc, "VR_FILIAL")
	Local cVrCod  := P136GetInf(cDoc, "VR_CODIGO")
	Local nVrSeq  := P136GetInf(cDoc, "VR_SEQUEN")

	If lUsaME 
		cDocRet := STR0010 + ": " + RTrim(cVrFil) + "| " //"Filial"
	EndIf

	cDocRet += I18N(STR0011, {RTrim(cVrCod), nVrSeq}) //"Demanda: #1[ID]# | Sequência: #2[SEQ]#"
Return cDocRet

/*/{Protheus.doc} ajustaDcDm
Verifica a necessidade de substituir o documento para exibição

@type  Static Function
@author lucas.franca
@since 11/05/2023
@version P12
@param 01 aDetail  , Array     , Array com os detalhes de retorno
@param 02 oJsDocDem, JsonObject, Json com o de-para dos documentos para transformar
@return Nil
/*/
Static Function ajustaDcDm(aDetail, oJsDocDem)
	Local cDoc   := ""
	Local nIndex := 0
	Local nTotal := Len(aDetail)

	For nIndex := 1 To nTotal 
		cDoc := RTrim(aDetail[nIndex]["docOrigem"])
		If oJsDocDem:HasProperty(cDoc)
			aDetail[nIndex]["docOrigem"] := oJsDocDem[cDoc]
		EndIf
	Next nIndex
Return Nil
