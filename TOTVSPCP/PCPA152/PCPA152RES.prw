#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"

/*/{Protheus.doc} PCPA152RES
API de processamento pcpa152

@type  WSCLASS
@author Marcelo Neumann
@since 01/02/2023
@version P12
/*/
WSRESTFUL PCPA152RES DESCRIPTION "PCPA152RES" FORMAT APPLICATION_JSON
	WSDATA BuscaRecursos   AS BOOLEAN
	WSDATA FilterIN        AS BOOLEAN OPTIONAL
	WSDATA HorasBloqueadas AS BOOLEAN OPTIONAL
	WSDATA DataFinal       AS DATE    OPTIONAL
	WSDATA DataInicial     AS DATE    OPTIONAL
	WSDATA Page            AS INTEGER OPTIONAL
	WSDATA PageSize        AS INTEGER OPTIONAL
	WSDATA codigo          AS STRING  OPTIONAL
	WSDATA descricao       AS STRING  OPTIONAL
	WSDATA Filter          AS STRING  OPTIONAL
	WSDATA FiltroOrdens    AS STRING  OPTIONAL
	WSDATA FiltroRecurso   AS STRING  OPTIONAL
	WSDATA FiltroTipoHoras AS STRING  OPTIONAL
	WSDATA grupo           AS STRING  OPTIONAL
	WSDATA Order           AS STRING  OPTIONAL
	WSDATA produto         AS STRING  OPTIONAL
	WSDATA Programacao     AS STRING  OPTIONAL
	WSDATA status          AS STRING  OPTIONAL
	WSDATA tipo            AS STRING  OPTIONAL
	WSDATA usuario         AS STRING  OPTIONAL

	WSMETHOD GET PROGRAMACOES;
		DESCRIPTION STR0026; //"Retorna todas as programações realizadas"
		WSSYNTAX "/api/pcp/v1/pcpa152res/programacoes" ;
		PATH "/api/pcp/v1/pcpa152res/programacoes" ;
		TTALK "v1"

	WSMETHOD GET RECURSOS;
		DESCRIPTION STR0027; //"Retorna todos os recursos"
		WSSYNTAX "/api/pcp/v1/pcpa152res/recursos" ;
		PATH "/api/pcp/v1/pcpa152res/recursos" ;
		TTALK "v1"

	WSMETHOD GET DISPONIBILIDADE;
		DESCRIPTION STR0028; //"Retorna o resultado de uma programação específica"
		WSSYNTAX "/api/pcp/v1/pcpa152res/disponibilidade/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152res/disponibilidade/{programacao}" ;
		TTALK "v1"

	WSMETHOD GET CENTROTRAB;
		DESCRIPTION STR0139; // "Retorna os centros de trabalho"
		WSSYNTAX "/api/pcp/v1/pcpa152res/centrotrab" ;
		PATH "/api/pcp/v1/pcpa152res/centrotrab" ;
		TTALK "v1"

	WSMETHOD GET PRODUTOS;
		DESCRIPTION STR0157 ; // "Retorna os produtos"
		WSSYNTAX "/api/pcp/v1/pcpa152res/produtos" ;
		PATH "/api/pcp/v1/pcpa152res/produtos" ;
		TTALK "v1"

	WSMETHOD GET GRUPOS;
		DESCRIPTION STR0158 ; // "Retorna os grupos de produto"
		WSSYNTAX "/api/pcp/v1/pcpa152res/grupos" ;
		PATH "/api/pcp/v1/pcpa152res/grupos" ;
		TTALK "v1"

	WSMETHOD GET TIPOS;
		DESCRIPTION STR0159 ; // "Retorna os tipos de produto"
		WSSYNTAX "/api/pcp/v1/pcpa152res/tipos" ;
		PATH "/api/pcp/v1/pcpa152res/tipos" ;
		TTALK "v1"

	WSMETHOD GET ORDENS;
		DESCRIPTION STR0160 ; // "Retorna as ordens de producao"
		WSSYNTAX "/api/pcp/v1/pcpa152res/ordens" ;
		PATH "/api/pcp/v1/pcpa152res/ordens" ;
		TTALK "v1"

	WSMETHOD GET DISTRIBUICAO;
		DESCRIPTION STR0179; // "Retorna a distribuicao das ordens"
		WSSYNTAX "/api/pcp/v1/pcpa152res/ordens/ditribuicao/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152res/ordens/ditribuicao/{programacao}" ;
		TTALK "v1"

	WSMETHOD GET PROGORDENS;
		DESCRIPTION STR0180; // "Retorna as ordens de produção consideradas em uma programação."
		WSSYNTAX "/api/pcp/v1/pcpa152res/ordens/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152res/ordens/{programacao}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET PROGRAMACOES /api/pcp/v1/pcpa152res/programacoes
Retorna as programações processadas

@type  WSMETHOD
@author Marcelo Neumann
@since 01/02/2023
@version P12
@param 01 Filter     , Caracter, Código da programação
@param 02 Page       , Numérico, Número da página a ser buscada
@param 03 PageSize   , Numérico, Tamanho da página
@param 04 Order      , Caracter, Ordenação da consulta (ORDER BY)
@param 05 codigo     , Caracter, Filtro de programação.
@param 06 status     , Caracter, Filtro de status da programação.
@param 07 usuario    , Caracter, Filtro de usuario.
@param 08 DataInicial, Date    , Filtro de data de inicio da programação.
@param 09 DataFinal  , Date    , Filtro de data final da programação.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET PROGRAMACOES QUERYPARAM Filter, Page, PageSize, Order, codigo, status, usuario, DataInicial, DataFinal WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodProg  := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodProg := Self:Filter
		Else
			cCodProg := Self:codigo
		EndIf

		aReturn := GetProgr(cCodProg, Self:Page, Self:PageSize, Self:status, Self:usuario, Self:DataInicial, Self:DataFinal)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} GetProgr
Retorna as programações processadas

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cProgramac, Caracter, Código da programação
@param 02 nPage     , Numérico, Número da página a ser buscada
@param 03 nPageSize , Numérico, Tamanho da página
@param 04 cStatus   , Caracter, Filtro de status.
@param 05 cUsuario  , Caracter, Filtro de usuario.
@param 06 dDataIni  , Date    , Filtro de data de inicio.
@param 07 dDataFim  , Date    , Filtro de data final.
@return aReturn, Array, Retorna as programações encontradas
/*/
Static Function GetProgr(cProgramac, nPage, nPageSize, cStatus, cUsuario, dDataIni, dDataFim)
	Local aReturn      := Array(3)
	Local cAlias       := GetNextAlias()
	Local cFilT4Y      := xFilial("T4Y")
	Local nPos         := 0
	Local oReturn      := JsonObject():New()
	Default cProgramac := ""
	Default nPage      := 1
	Default nPageSize  := 20

	dbSelectArea("T4X")

	cQuery := "SELECT T4X.T4X_PROG   programacao, "
	cQuery +=       " T4X.T4X_STATUS idStatus,    "
	cQuery +=       " T4X.T4X_USER   usuario,     "
	cQuery +=       " dataInicial.T4Y_VALOR dataInicial, "
	cQuery +=       " dataFinal.T4Y_VALOR dataFinal      "
	cQuery +=  " FROM " + RetSqlName("T4X") + " T4X "

	cQuery += " INNER JOIN " + RetSqlName("T4Y") + " dataInicial "
	cQuery +=    " ON dataInicial.T4Y_PROG   = T4X.T4X_PROG  "
	cQuery +=   " AND dataInicial.T4Y_PARAM  = 'dataInicial' "
	cQuery +=   " AND dataInicial.D_E_L_E_T_ = ' '           "
	cQuery +=   " AND dataInicial.T4Y_FILIAL = '" + cFilT4Y + "' "

	If !Empty(dDataIni)
		cQuery += " AND dataInicial.T4Y_VALOR >= '" + PCPConvDat(dDataIni, 2) + "' "
	EndIf

	cQuery += " INNER JOIN " + RetSqlName("T4Y") + " dataFinal "
	cQuery +=    " ON dataFinal.T4Y_PROG   = T4X.T4X_PROG "
	cQuery +=   " AND dataFinal.T4Y_PARAM  = 'dataFinal'  "
	cQuery +=   " AND dataFinal.D_E_L_E_T_ = ' '          "
	cQuery +=   " AND dataFinal.T4Y_FILIAL = '" + cFilT4Y + "' "

	If !Empty(dDataFim)
		cQuery += " AND dataFinal.T4Y_VALOR <= '" + PCPConvDat(dDataFim, 2) + "' "
	EndIf

	cQuery += " WHERE T4X.T4X_FILIAL = '" + xFilial("T4X") + "' "
	cQuery +=   " AND T4X.D_E_L_E_T_ = ' ' "

	If !Empty(cProgramac)
		cQuery += " AND T4X.T4X_PROG like '%" + cProgramac + "%'"
	EndIf

	If !Empty(cStatus)
		cQuery += " AND T4X.T4X_STATUS " + getFilter(cStatus, Nil, .T.)
	Else
		cQuery += " AND T4X.T4X_STATUS IN ('2', '4') "
	EndIf

	If !Empty(cUsuario)
		cQuery += " AND UPPER(T4X.T4X_USER) " + getFilter(cUsuario, Nil, .F.)
	EndIf

	cQuery += " ORDER BY programacao DESC "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nPos++
		aAdd(oReturn["items"], JsonObject():New())
		oReturn["items"][nPos]["programacao"] := RTrim((cAlias)->programacao)
		oReturn["items"][nPos]["idStatus"   ] := RTrim((cAlias)->idStatus)
		oReturn["items"][nPos]["dataInicial"] := PCPConvDat((cAlias)->dataInicial, 3)
		oReturn["items"][nPos]["dataFinal"  ] := PCPConvDat((cAlias)->dataFinal  , 3)
		oReturn["items"][nPos]["usuario"    ] := UsrRetName((cAlias)->usuario)
		oReturn["items"][nPos]["status"     ] := PCPA152Process():getDescricaoStatus(oReturn["items"][nPos]["idStatus"])
		oReturn["items"][nPos]["parametros" ] := P152GetPar(oReturn["items"][nPos]["programacao"])

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0029 //"Não existem programações para atender os filtros informados."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	aSize(oReturn["items"], 0)
	FwFreeObj(oReturn)

Return aReturn

/*/{Protheus.doc} GET RECURSOS /api/pcp/v1/pcpa152res/recursos
Retorna os recursos existentes

@type  WSMETHOD
@author Marcelo Neumann
@since 01/02/2023
@version P12
@param 01 Filter   , Caracter, Código do recurso
@param 02 Page     , Numérico, Número da página a ser buscada
@param 03 PageSize , Numérico, Tamanho da página
@param 04 Order    , Caracter, Ordenação da consulta (ORDER BY)
@param 05 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo   , Caracter, Filtro para codigo do recurso.
@param 07 descricao, Caracter, Filtro para descroção do recurso.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET RECURSOS QUERYPARAM Filter, Page, PageSize, Order, FilterIN, codigo, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodRecur := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodRecur := Self:Filter
		Else
			cCodRecur := Self:codigo
		EndIf

		aReturn := GetRecurs(cCodRecur, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} GetRecurs
Retorna os recursos existentes

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cRecurso , Caracter, Código do recurso
@param 02 nPage    , Numérico, Número da página a ser buscada
@param 03 nPageSize, Numérico, Tamanho da página
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescri  , Caracter, Filtro para descrição do recurso.
@return aReturn, array, Retorna os recursos encontrados
/*/
Static Function GetRecurs(cRecurso, nPage, nPageSize, lInFilter, cDescri)
	Local aReturn     := Array(3)
	Local cAlias      := GetNextAlias()
	Local lPagina     := .T.
	Local nPos        := 0
	Local oReturn     := JsonObject():New()
	Default cRecurso  := ""
	Default nPage     := 1
	Default nPageSize := 20

	cQuery := "SELECT H1_CODIGO recurso,"                   + ;
	                " H1_DESCRI descricaoRecurso"           + ;
	           " FROM " + RetSqlName("SH1")                 + ;
	          " WHERE H1_FILIAL = '" + xFilial("SH1") + "'" + ;
	            " AND D_E_L_E_T_ = ' '"

	If !Empty(cRecurso)
		cQuery += " AND UPPER(H1_CODIGO) " + getFilter(cRecurso, Nil, lInFilter)
	EndIf

	If !Empty(cDescri)
		cQuery += " AND UPPER(H1_DESCRI) " + getFilter(cDescri, Nil, lInFilter)
	EndIf

	cQuery += " ORDER BY recurso "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cRecurso))
	While (cAlias)->(!EoF())
		nPos++
		aAdd(oReturn["items"], JsonObject():New())
		oReturn["items"][nPos]["recurso"         ] := (cAlias)->recurso
		oReturn["items"][nPos]["descricaoRecurso"] := RTrim((cAlias)->descricaoRecurso)
		oReturn["items"][nPos]["color"           ] := "gray"

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If lPagina .And. nPos >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0030 //"Não existem recursos para atender os filtros informados."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	aSize(oReturn["items"], 0)
	FwFreeObj(oReturn)

Return aReturn

/*/{Protheus.doc} GET DISPONIBILIDADE /api/pcp/v1/pcpa152res/disponibilidade/{programacao}
Retorna a disponibilidade dos recursos da programação

@type  WSMETHOD
@author Marcelo Neumann
@since 01/02/2023
@version P12
@param 01 Programacao    , Caracter, Número da programação
@param 02 BuscaRecursos  , Lógico  , Indica se deve buscar e retornar os recursos da programação
@param 03 DataInicial    , Data    , Data inicial a ser buscada e apresentada
@param 04 DataFinal      , Data    , Data final a ser buscada e apresentada
@param 05 FiltroRecurso  , Caracter, Filtro de recursos
@param 06 FiltroTipoHoras, Caracter, Filtro de tipo de hora (MK_TIPO)
@param 07 HorasBloqueadas, Lógico  , Indica se deve incluir as horsa bloqueadas ou não na consulta
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET DISPONIBILIDADE WSRECEIVE Programacao QUERYPARAM BuscaRecursos, DataInicial, DataFinal, FiltroRecurso, FiltroTipoHoras, HorasBloqueadas WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := GetDispon(Self:programacao, Self:BuscaRecursos, Self:DataInicial, Self:DataFinal, Self:FiltroRecurso, Self:FiltroTipoHoras, Self:HorasBloqueadas)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} GetDispon
Retorna a disponibilidade dos recursos da programação

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 cProgramac, Caracter, Número da programação
@param 02 lBuscaRecs, Lógico  , Indica se deve buscar e retornar os recursos da programação
@param 03 dDataIni  , Data    , Data inicial a ser buscada e apresentada
@param 04 dDataFinal, Data    , Data final a ser buscada e apresentada
@param 05 cRecurso  , Caracter, Filtro de recursos
@param 06 cTipHoras , Caracter, Filtro de tipo de hora (MK_TIPO)
@param 07 lHrsBloq  , Lógico  , Indica se deve incluir as horsa bloqueadas ou não na consulta
@return aReturn, Array, Retorna a disponibilidade encontrada
/*/
Static Function GetDispon(cProgramac, lBuscaRecs, dDataIni, dDataFinal, cRecurso, cTipHoras, lHrsBloq)
	Local aReturn      := Array(3)
	Local cAlias       := GetNextAlias()
	Local cQryInTip    := ""
	Local nInd         := 0
	Local nPos         := 0
	Local oReturn      := JsonObject():New()
	Default cProgramac := ""
	Default lBuscaRecs := .T.
	Default dDataIni   := dDatabase
	Default dDataFinal := dDatabase + 1

	If lBuscaRecs
		oReturn["recursos"] := {}
		GetRecsDis(@oReturn, cProgramac, cRecurso)
	EndIf

	//Se não foi selecionado nenhum tipo de hora para ser exibido
	If Empty(cTipHoras) .And. !lHrsBloq
		oReturn["items"] := {}
	Else
		cQuery := "SELECT SMR.MR_RECURSO recurso,"                      + ;
		                " SMK.MK_DATDISP data,"                         + ;
		                " SMK.MK_HRINI   horaInicio,"                   + ;
		                " SMK.MK_HRFIM   horaFim,"                      + ;
		                " SMK.MK_TIPO    tipoHora,"                     + ;
		                " SMK.MK_BLOQUE  bloqueada,"                    + ;
		                " SMK.R_E_C_N_O_ id"                            + ;
		           " FROM " + RetSqlName("SMK") + " SMK"                + ;
		          " INNER JOIN " + RetSqlName("SMR") + " SMR"           + ;
		             " ON SMR.MR_FILIAL   = SMK.MK_FILIAL"              + ;
		            " AND SMR.MR_PROG     = SMK.MK_PROG"                + ;
		            " AND SMR.MR_DISP     = SMK.MK_DISP"                + ;
		            " AND SMR.D_E_L_E_T_  = ' '"                        + ;
		          " WHERE SMK.MK_FILIAL   = '" + xFilial("SMK")   + "'" + ;
		            " AND SMK.MK_PROG     = '" + cProgramac       + "'" + ;
		            " AND SMK.MK_DATDISP >= '" + DToS(dDataIni)   + "'" + ;
		            " AND SMK.MK_DATDISP  < '" + DToS(dDataFinal) + "'" + ;
		            " AND SMK.D_E_L_E_T_  = ' '"

		If cTipHoras <> "123"
			cQryInTip += "'" + SubStr(cTipHoras, 1, 1) + "'"

			nLen := Len(cTipHoras)
			For nInd := 2 To nLen
				cQryInTip += ",'" + SubStr(cTipHoras, nInd, 1) + "'"
			Next

			cQuery += " AND SMK.MK_TIPO IN (" + cQryInTip + ")"
		EndIf

		If !lHrsBloq
			cQuery += " AND SMK.MK_BLOQUE = '2'"
		EndIf

		cQuery += " ORDER BY data, horaInicio"

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

		TcSetField(cAlias, 'data', 'D', GetSx3Cache("T4X_DTINI", "X3_TAMANHO"), 0)

		oReturn["items"] := {}

		While (cAlias)->(!EoF())
			nPos++
			aAdd(oReturn["items"], JsonObject():New())
			oReturn["items"][nPos]["id"        ] := (cAlias)->id
			oReturn["items"][nPos]["resourceId"] := RTrim((cAlias)->recurso)
			oReturn["items"][nPos]["tipoHora"  ] := (cAlias)->tipoHora
			oReturn["items"][nPos]["bloqueada" ] := (cAlias)->bloqueada == "1"
			oReturn["items"][nPos]["start"     ] := PCPConvDat((cAlias)->data, 2) + "T" + (cAlias)->horaInicio + ":00"
			oReturn["items"][nPos]["end"       ] := PCPConvDat((cAlias)->data, 2) + "T" + (cAlias)->horaFim + ":00"

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	EndIf

	oReturn["hasNext"] := .F.

	If lBuscaRecs .And. Len(oReturn["recursos"]) > 0
		nPos++
	EndIf

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0031 //"Não existem registros de disponibilidade para atender os filtros informados."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	If lBuscaRecs
		aSize(oReturn["recursos"], 0)
	EndIf

	aSize(oReturn["items"], 0)
	FwFreeObj(oReturn)

Return aReturn

/*/{Protheus.doc} GetRecsDis
Retorna a disponibilidade dos recursos da programação

@type Static Function
@author Marcelo Neumann
@since 07/02/2023
@version P12
@param 01 oReturn   , Objeto  , Objeto Json do retorno a ser preenchido com o recurso (retorno por referência)
@param 02 cProgramac, Caracter, Número da programação que está sendo pesquisada
@param 03 cRecurso  , Caracter, Filtro de recursos
@return Nil
/*/
Static Function GetRecsDis(oReturn, cProgramac, cRecurso)
	Local cAlias := GetNextAlias()
	Local cWhere := ""
	Local nInd   := 0

	dbSelectArea("SMR")
	dbSelectArea("SMK")

	cWhere := "% SMR.MR_PROG = '" + cProgramac + "'"
	If !Empty(cRecurso)
		cWhere += " AND SMR.MR_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "')"
	EndIf
	cWhere += "%"

	BeginSql Alias cAlias
	  SELECT DISTINCT SMR.MR_RECURSO recurso, SH1.H1_DESCRI descricaoRecurso
	    FROM %Table:SMR% SMR
	   INNER JOIN %Table:SH1% SH1
	      ON SH1.H1_FILIAL = %xFilial:SH1%
	     AND SH1.H1_CODIGO = SMR.MR_RECURSO
	     AND SH1.%NotDel%
	   WHERE SMR.MR_FILIAL = %xFilial:SMR%
	     AND %Exp:cWhere%
	     AND SMR.%NotDel%
	   ORDER BY recurso
	EndSql

	While (cAlias)->(!Eof())
		nInd++
		aAdd(oReturn["recursos"], JsonObject():New())
		oReturn["recursos"][nInd]["recurso"         ] := RTrim((cAlias)->recurso)
		oReturn["recursos"][nInd]["descricaoRecurso"] := RTrim((cAlias)->recurso) + " - " +RTrim((cAlias)->descricaoRecurso)
		oReturn["recursos"][nInd]["color"           ] := "gray"

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} GET CENTROTRAB /api/pcp/v1/pcpa152res/centrotrab
Retorna os centros de trabalho para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 24/03/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos centros de trabalho.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 Order    , Caracter, Order by dos dados.
@param 05 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo   , Caracter, Filtro para o codigo do centro de trabalho
@param 07 descricao, Caracter, Filtro para a descrição do centro de trabalho
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET CENTROTRAB QUERYPARAM Filter, Page, PageSize, Order, FilterIN, codigo, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodCT    := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodCT := Self:Filter
		Else
			cCodCT := Self:codigo
		EndIf

		aReturn := getCenTrab(cCodCT, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getCenTrab
Retorna os centros de trabalho para filtro da programação.
@type  Function
@author Lucas Fagundes
@since 16/03/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos centros de trabalho.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescCT  , Caracter, Filtra os centros de trabalho pela descrição.
@return aReturn, Array, Array para return da API.
/*/
Function getCenTrab(cFilter, nPage, nPageSize, lInFilter, cDescCT)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local lPagina := .T.
	Local nCount  := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()
	Local lEmBranco := .F.

	Default nPage     := 1
	Default nPageSize := 20

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, @lEmBranco, lInFilter)
	EndIf

	oReturn["items"  ] := {}

	cQuery := " SELECT HB_COD  centroTrab, "
	cQuery +=        " HB_NOME descricaoCentroTrab "
	cQuery +=   " FROM " + RetSqlName("SHB")
	cQuery +=  " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=    " AND HB_FILIAL = '" + xFilial("SHB") + "' "

	If !Empty(cFilter)
		cQuery += " AND UPPER(HB_COD) " + cFilter
	EndIf

	If !Empty(cDescCT)
		cQuery += " AND UPPER(HB_NOME) " + getFilter(cDescCT, /*lEmBranco*/, lInFilter)
	EndIf

	cQuery += " ORDER BY centroTrab "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )

		// Se não houver filtro, inicia um registro a menos da paginação devido ao centro de trabalho em branco adicionado na página 1.
		If Empty(cFilter) .And. Empty(cDescCT)
			nStart -= 1
		EndIf

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	ElseIf (Empty(cFilter) .And. Empty(cDescCT)) .Or. lEmBranco
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["centroTrab"         ] := " "
		oReturn["items"][nCount]["descricaoCentroTrab"] := STR0140 // "Centro de trabalho em branco"
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["centroTrab"         ] := (cAlias)->centroTrab
		oReturn["items"][nCount]["descricaoCentroTrab"] := (cAlias)->descricaoCentroTrab

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getFilter
Monta condição para o IN dos filtros na query.
@type  Static Function
@author Lucas Fagundes
@since 23/03/2023
@version P12
@param 01 cFilter  , Caracter, String que vai coverter para fazer o IN na query.
@param 02 lEmBranco, Logico  , Retorna por referencia se está selecionado para filtrar valores em branco.
@param 03 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@return cCondQry, Caracter, Condição do filtro para a query.
/*/
Static Function getFilter(cFilter, lEmBranco, lInFilter)
	Local aFiltro  := {}
	Local cCondQry := ""
	Local nIndex   := 0
	Local nTotal   := 0

	cFilter := Upper(cFilter)

	If lInFilter
		aFiltro := StrTokArr(cFilter, ",")
		nTotal  := Len(aFiltro)

		cCondQry := " IN ( "

		For nIndex := 1 To nTotal
			If aFiltro[nIndex] == "' '"
				lEmBranco := .T.
				cCondQry += " ' ' "
			Else
				cCondQry += " '" + aFiltro[nIndex] + "' "
			EndIf

			If nIndex < nTotal
				cCondQry += ","
			EndIf
		Next

		cCondQry += " ) "

		aSize(aFiltro, 0)
	Else
		cCondQry := " LIKE '" + cFilter + "%' "
	EndIf

Return cCondQry

/*/{Protheus.doc} GET PRODUTOS /api/pcp/v1/pcpa152res/produtos
Retorna os produtos para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos produtos.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 Order    , Caracter, Order by dos dados.
@param 05 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo   , Caracter, Filtro de produto.
@param 07 descricao, Caracter, Filtro de descrição.
@param 08 tipo     , Caracter, Filtro de tipo.
@param 09 grupo    , Caracter, Filtro de grupo.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET PRODUTOS QUERYPARAM Filter, Page, PageSize, Order, FilterIN, codigo, descricao, tipo, grupo WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodProd  := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodProd := Self:Filter
		Else
			cCodProd := Self:codigo
		EndIf

		aReturn := getProds(cCodProd, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao, Self:tipo, Self:grupo)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getProds
Retorna os produtos para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos produtos.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDesc    , Caracter, Filtro de descrição.
@param 06 cTipo    , Caracter, Filtro de tipo.
@param 07 cGrupo   , Caracter, Filtro de grupo.
@return aReturn, Array, Array para return da API.
/*/
Static Function getProds(cFilter, nPage, nPageSize, lInFilter, cDesc, cTipo, cGrupo)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local lPagina := .T.
	Local nCount  := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, /*lEmBranco*/, lInFilter)
	EndIf

	oReturn["items"  ] := {}

	cQuery := " SELECT B1_COD  codProduto,  "
	cQuery +=        " B1_DESC descProduto, "
	cQuery +=        " B1_TIPO tipo,        "
	cQuery +=        " B1_GRUPO grupo       "
	cQuery +=   " FROM " + RetSqlName("SB1")
	cQuery +=  " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=    " AND B1_FILIAL = '" + xFilial("SB1") + "' "

	If !Empty(cFilter)
		cQuery += " AND UPPER(B1_COD) " + cFilter
	EndIf

	If !Empty(cDesc)
		cQuery += " AND UPPER(B1_DESC) " + getFilter(cDesc, /*lEmBranco*/, lInFilter)
	EndIf

	If !Empty(cTipo)
		cQuery += " AND UPPER(B1_TIPO) " + getFilter(cTipo, /*lEmBranco*/, .T.)
	EndIf

	If !Empty(cGrupo)
		cQuery += " AND UPPER(B1_GRUPO) " + getFilter(cGrupo, /*lEmBranco*/, .T.)
	EndIf

	cQuery += " ORDER BY codProduto "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["codProduto" ] := (cAlias)->codProduto
		oReturn["items"][nCount]["descProduto"] := (cAlias)->descProduto
		oReturn["items"][nCount]["tipo"       ] := (cAlias)->tipo
		oReturn["items"][nCount]["grupo"      ] := (cAlias)->grupo

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET GRUPOS /api/pcp/v1/pcpa152res/grupos
Retorna os grupos de produto para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos grupos.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 Order    , Caracter, Order by dos dados.
@param 05 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo   , Caracter, Filtro de código.
@param 07 descricao, Caracter, Filtro de descrição.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET GRUPOS QUERYPARAM Filter, Page, PageSize, Order, FilterIN, codigo, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodGrp   := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodGrp := Self:Filter
		Else
			cCodGrp := Self:codigo
		EndIf

		aReturn := getGrupos(cCodGrp, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getGrupos
Retorna os grupos de produto para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos grupos.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescGrp , Caracter, Filtro de descrição do grupo de produtos.
@return aReturn, Array, Array para return da API.
/*/
Static Function getGrupos(cFilter, nPage, nPageSize, lInFilter, cDescGrp)
	Local aReturn   := Array(3)
	Local cAlias    := GetNextAlias()
	Local cQuery    := ""
	Local lEmBranco := .F.
	Local lPagina   := .T.
	Local nCount    := 0
	Local nStart    := 0
	Local oReturn   := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, @lEmBranco, lInFilter)
	EndIf

	oReturn["items"  ] := {}

	cQuery := " SELECT BM_GRUPO  grupoProd, "
	cQuery +=        " BM_DESC   descGrupo "
	cQuery +=   " FROM " + RetSqlName("SBM")
	cQuery +=  " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=    " AND BM_FILIAL = '" + xFilial("SBM") + "' "

	If !Empty(cFilter)
		cQuery += " AND UPPER(BM_GRUPO) " + cFilter
	EndIf

	If !Empty(cDescGrp)
		cQuery += " AND UPPER(BM_DESC) " + getFilter(cDescGrp, /*lEmBranco*/, lInFilter)
	EndIf

	cQuery += " ORDER BY grupoProd "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )

		// Quando não houver filtro, inicia um registro a menos na paginação devido ao grupo em branco adicionado na página 1.
		If Empty(cFilter) .And. Empty(cDescGrp)
			nStart -= 1
		EndIf

		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf

	ElseIf (Empty(cFilter) .And. Empty(cDescGrp)) .Or. lEmBranco
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["grupoProd"] := " "
		oReturn["items"][nCount]["descGrupo"] := STR0176 // "Grupo em branco."
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["grupoProd"] := (cAlias)->grupoProd
		oReturn["items"][nCount]["descGrupo"] := (cAlias)->descGrupo

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET TIPOS /api/pcp/v1/pcpa152res/tipos
Retorna os tipos de produto para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter   , Caracter, Filtro dos tipos.
@param 02 Page     , Numerico, Página que será carregado na tela.
@param 03 PageSize , Numerico, Tamanho da página.
@param 04 Order    , Caracter, Order by dos dados.
@param 05 FilterIN , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo   , Caracter, Filtro de codigo.
@param 07 descricao, Caracter, Filtro de descrição.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET TIPOS QUERYPARAM Filter, Page, PageSize, Order, FilterIN, codigo, descricao WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodTipo  := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodTipo := Self:Filter
		Else
			cCodTipo := Self:codigo
		EndIf

		aReturn := getTipos(cCodTipo, Self:Page, Self:PageSize, Self:FilterIN, Self:descricao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getTipos
Retorna os tipos de produto para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos tipos.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cDescTp  , Caracter, Filtra pela descrição do tipo.
@return aReturn, Array, Array para return da API.
/*/
Static Function getTipos(cFilter, nPage, nPageSize, lInFilter, cDescTp)
	Local aReturn    := Array(3)
	Local aTipos     := {}
	Local lFiltroCod := !Empty(cFilter)
	Local lFiltroDes := !Empty(cDescTp)
	Local lInsere    := .F.
	Local lPagina    := .T.
	Local nContFilt  := 0
	Local nIndex     := 1
	Local nInseridos := 0
	Local nStart     := 0
	Local nTotal     := 0
	Local oReturn    := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	oReturn["items"] := {}

	aTipos := FwGetSX5("02")
	nTotal := Len(aTipos)

	If lFiltroCod
		cFilter := Upper(cFilter)
	EndIf

	If lFiltroDes
		cDescTp := Upper(cDescTp)
	EndIf

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0 .And. (!lFiltroCod .And. !lFiltroDes)
			nIndex := nStart+1
		EndIf
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While nIndex <= nTotal .And. (!lPagina .Or. nInseridos < nPageSize)
		If !lFiltroCod .And. !lFiltroDes
			lInsere := .T.
		Else
			If lInFilter
				lInsere := (!lFiltroCod .Or. Upper(RTrim(aTipos[nIndex][3])) $ cFilter) .And.;
				           (!lFiltroDes .Or. Upper(RTrim(aTipos[nIndex][4])) $ cDescTp)
			Else
				lInsere := (!lFiltroCod .Or. "|" + cFilter $ "|" + Upper(aTipos[nIndex][3])) .And.;
				           (!lFiltroDes .Or. "|" + cDescTp $ "|" + Upper(aTipos[nIndex][4]))
			EndIf

			If lInsere
				nContFilt++
				lInsere := nContFilt > nStart
			EndIf
		EndIf

		If lInsere
			nInseridos++
			aAdd(oReturn["items"], JsonObject():New())
			oReturn["items"][nInseridos]["tipoProd"] := aTipos[nIndex][3]
			oReturn["items"][nInseridos]["descTipo"] := aTipos[nIndex][4]
		EndIf
		nIndex++
	End

	If lPagina
		oReturn["hasNext"] := nIndex < nTotal
	Else
		lInsere := .F.

		While nIndex <= nTotal
			If lInFilter
				lInsere := RTrim(aTipos[nIndex][3]) $ cFilter
			Else
				lInsere := "|" + cFilter $ "|" + aTipos[nIndex][3]
			EndIf
			nIndex++
		End

		oReturn["hasNext"] := lInsere
	EndIf

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
	FwFreeArray(aTipos)
Return aReturn

/*/{Protheus.doc} GET ORDENS /api/pcp/v1/pcpa152res/ordens
Retorna as ordens de producao para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Filter     , Caracter, Filtro dos tipos.
@param 02 Page       , Numerico, Página que será carregado na tela.
@param 03 PageSize   , Numerico, Tamanho da página.
@param 04 Order      , Caracter, Order by dos dados.
@param 05 FilterIN   , Logico  , Indica que deve filtrar a query com IN.
@param 06 codigo     , Caracter, Filtro de codigo.
@param 07 produto    , Caracter, Filtro de produto.
@param 08 tipo       , Caracter, Filtro de tipo.
@param 09 DataInicial, Date    , Filtro de data de inicio.
@param 10 DataFinal  , Date    , Filtro de data de entrega.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET ORDENS QUERYPARAM Filter, Page, PageSize, Order, FilterIN, codigo, produto, tipo, DataInicial, DataFinal WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodOp    := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodOp := Self:Filter
		Else
			cCodOp := Self:codigo
		EndIf

		aReturn := getOrdens(cCodOp, Self:Page, Self:PageSize, Self:FilterIN, Nil, Self:produto, Self:tipo, Self:DataInicial, Self:DataFinal)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOrdens
Retorna as ordens de producao para exibir em tela.
@type  Static Function
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 cFilter  , Caracter, Filtro dos tipos.
@param 02 nPage    , Numerico, Página que será carregado na tela.
@param 03 nPageSize, Numerico, Tamanho da página.
@param 04 lInFilter, Logico  , Indica que deve filtrar a query com IN.
@param 05 cProg    , Caracter, Código da programação para fazer o filtro na tabela SMF.
@param 06 cProduto , Caracter, Filtro de produto.
@param 07 cTipo    , Caracter, Filtro por tipo de ordem de produção.
@param 08 dDataIni , Date    , Filtro de data inicial.
@param 09 dDataFim , Date    , Filtro de data de entrega.
@return aReturn, Array, Array para return da API.
/*/
Static Function getOrdens(cFilter, nPage, nPageSize, lInFilter, cProg, cProduto, cTipo, dDataIni, dDataFim)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cBanco  := TcGetDb()
	Local cQuery  := ""
	Local lPagina := .T.
	Local nCount  := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	If !Empty(cFilter)
		cFilter := getFilter(cFilter, /*lEmBranco*/, lInFilter)
	EndIf

	oReturn["items"] := {}

	cQuery := "SELECT SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD ordemProd, "
	cQuery +=        " SC2.C2_QUANT quant,    "
	cQuery +=        " SC2.C2_TPOP tipo,      "
	cQuery +=        " SC2.C2_DATPRI dataIni, "
	cQuery +=        " SC2.C2_DATPRF dataFim, "
	cQuery +=        " SC2.C2_PRODUTO produto "
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
	cQuery +=  " WHERE SC2.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "

	If !Empty(cProg)
		cQuery +=    " AND RTRIM(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) IN ( "
		cQuery +=            " SELECT DISTINCT RTRIM(SMF.MF_OP) "
		cQuery +=              " FROM " + RetSqlName("SMF") + " SMF "
		cQuery +=             " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
		cQuery +=               " AND SMF.MF_PROG    = '" + cProg + "' "
		cQuery +=               " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=    " ) "
	EndIf

	If !Empty(cFilter)
		cQuery += " AND UPPER(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) " + cFilter
	EndIf

	If !Empty(cProduto)
		cQuery += " AND UPPER(SC2.C2_PRODUTO) " + getFilter(cProduto, /*lEmBranco*/, .T.)
	EndIf

	If !Empty(cTipo)
		cQuery += " AND SC2.C2_TPOP " + getFilter(cTipo, /*lEmBranco*/, .T.)
	EndIf

	If !Empty(dDataIni)
		cQuery += " AND SC2.C2_DATPRI >= '" + DToS(dDataIni) + "' "
	EndIf

	If !Empty(dDataFim)
		cQuery += " AND SC2.C2_DATPRF <= '" + DToS(dDataFim) + "' "
	EndIf

	cQuery += " ORDER BY ordemProd"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	lPagina := !lInFilter .Or. (lInFilter .And. Empty(cFilter))
	While (cAlias)->(!EoF())
		nCount++
		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCount]["ordemProd"] := (cAlias)->ordemProd
		oReturn["items"][nCount]["quant"    ] := (cAlias)->quant
		oReturn["items"][nCount]["tipo"     ] := Iif((cAlias)->tipo == "F", STR0161 /*"Firme"*/, STR0162 /*"Prevista"*/)
		oReturn["items"][nCount]["dataIni"  ] := PCPConvDat((cAlias)->dataIni, 4)
		oReturn["items"][nCount]["dataFim"  ] := PCPConvDat((cAlias)->dataFim, 4)
		oReturn["items"][nCount]["produto"  ] := (cAlias)->produto

		(cAlias)->(dbSkip())
		If lPagina .And. nCount >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET DISTRIBUICAO /api/pcp/v1/pcpa152res/ordens/ditribuicao/{programacao}
Busca as distribuições das ops para exibir no gantt.
@type  WSMETHOD
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 Programacao  , Caracter, Código da programação.
@param 02 DataInicial  , Date    , Data de inicio das distribuições.
@param 03 DataFinal    , Date    , Data final das distribuições.
@param 04 FiltroRecurso, Caracter, Filtro de recursos.
@param 05 FiltroOrdens , Caracter, Filtro de ordens de produção.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET DISTRIBUICAO PATHPARAM Programacao QUERYPARAM DataInicial, DataFinal, FiltroRecurso, FiltroOrdens WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getDistrib(Self:Programacao, Self:DataInicial, Self:DataFinal, Self:FiltroRecurso, Self:FiltroOrdens)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getDistrib
Retorna a distribuição das ordens de produção para exibir no gant.
@type  Static Function
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 cProg     , Caracter, Código da programação que está sendo consultada.
@param 02 dDataIni  , Date    , Data de inicio do gant.
@param 03 dDataFim  , Date    , Data final do gant.
@param 04 cFiltroRec, Caracter, Filtro de recursos que será aplicado na busca pelas distribuições.
@param 05 cFiltroOP , Caracter, Filtro de OPs que será aplicado na busca pelas distribuições.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getDistrib(cProg, dDataIni, dDataFim, cFiltroRec, cFiltroOP)
	Local aReturn   := Array(3)
	Local cAlias    := ""
	Local cBanco    := TcGetDb()
	Local cQuery    := ""
	Local nSeqField := 0
	Local oItem     := Nil
	Local oQryBlock := FwExecStatement():New()
	Local oReturn   := JsonObject():New()

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	cQuery := " SELECT SMF.MF_OP      ordem,      "
	cQuery +=        " SMF.MF_OPER    operacao,   "
	cQuery +=        " SMF.MF_RECURSO recurso,    "
	cQuery +=        " SVM.VM_DATA    data,       "
	cQuery +=        " SVM.VM_INICIO  horaInicio, "
	cQuery +=        " SVM.VM_FIM     horaFim,    "
	cQuery +=        " SC2.C2_PRODUTO produto     "
	cQuery +=   " FROM " + RetSqlName("SVM") + " SVM "
	cQuery +=  " INNER JOIN " + RetSqlName("SMF") + " SMF "
	cQuery +=     " ON SMF.MF_FILIAL  =  ? "
	cQuery +=    " AND SMF.MF_PROG    = SVM.VM_PROG "
	cQuery +=    " AND SMF.MF_ID      = SVM.VM_ID "
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "

	If !Empty(cFiltroRec)
		cQuery += " AND SMF.MF_RECURSO IN (?) "
	EndIf

	If !Empty(cFiltroOP)
		cQuery += " AND SMF.MF_OP IN (?) "
	EndIf

	cQuery += " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=    " ON RTRIM(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) = RTRIM(SMF.MF_OP) "
	cQuery +=   " AND SC2.C2_FILIAL  =  ? "
	cQuery +=   " AND SC2.D_E_L_E_T_ = ' ' "

	cQuery +=  " WHERE SVM.VM_FILIAL  =  ?  "
	cQuery +=    " AND SVM.VM_PROG    =  ?  "
	cQuery +=    " AND SVM.VM_DATA    >= ?  "
	cQuery +=    " AND SVM.VM_DATA    <= ?  "
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' ' "

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	oQryBlock:setQuery(cQuery)

	nSeqField++
	oQryBlock:setString(nSeqField, xFilial("SMF")) // MF_FILIAL

	If !Empty(cFiltroRec)
		nSeqField++
		oQryBlock:setIn(nSeqField, StrTokArr(cFiltroRec, ", ")) // MF_RECURSO
	EndIf

	If !Empty(cFiltroOP)
		nSeqField++
		oQryBlock:setIn(nSeqField, StrTokArr(cFiltroOP, ", ")) // MF_OP
	EndIf

	nSeqField++
	oQryBlock:setString(nSeqField, xFilial("SC2")) // C2_FILIAL

	nSeqField++
	oQryBlock:setString(nSeqField, xFilial("SVM")) // VM_FILIAL

	nSeqField++
	oQryBlock:setString(nSeqField, cProg) // VM_PROG

	nSeqField++
	oQryBlock:setDate(nSeqField, dDataIni) // VM_DATA

	nSeqField++
	oQryBlock:setDate(nSeqField, dDataFim) // VM_DATA

	cAlias := oQryBlock:openAlias()

	TcSetField(cAlias, 'data', 'D', 8, 0)

	While (cAlias)->(!EoF())
		oItem := JsonObject():New()

		oItem["title"     ] := i18n(STR0181, {RTrim((cAlias)->ordem), RTrim((cAlias)->operacao), RTrim((cAlias)->produto)}) // "OP: #1[ordemProducao]#, Operação: #2[operacao]#, Produto: #3[produto]#"
		oItem["resourceId"] := RTrim((cAlias)->recurso)
		oItem["start"     ] := PCPConvDat((cAlias)->data, 2) + "T" + RTrim((cAlias)->horaInicio) + ":00"
		oItem["end"       ] := PCPConvDat((cAlias)->data, 2) + "T" + RTrim((cAlias)->horaFim) + ":00"
		oItem["color"     ] := "#1273aa"

		aAdd(oReturn["items"], oItem)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If Len(oReturn["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .T.
		aReturn[2] := 204
		aReturn[3] := oReturn:toJson()
	EndIf

	oQryBlock:destroy()
	FwFreeObj(oReturn)
	FwFreeObj(oQryBlock)
Return aReturn

/*/{Protheus.doc} GET ORDENS /api/pcp/v1/pcpa152res/ordens
Retorna as ordens de producao para exibir em tela.

@type  WSMETHOD
@author Lucas Fagundes
@since 10/04/2023
@version P12
@param 01 Programacao, Caracter, Código da programação.
@param 02 Filter     , Caracter, Filtro dos tipos.
@param 03 Page       , Numerico, Página que será carregado na tela.
@param 04 PageSize   , Numerico, Tamanho da página.
@param 05 Order      , Caracter, Order by dos dados.
@param 06 FilterIN   , Logico  , Indica que deve filtrar a query com IN.
@param 07 codigo     , Caracter, Filtro de código da op.
@param 08 produto    , Caracter, Filtro de produto.
@param 09 tipo       , Caracter, Filtro de tipo.
@param 10 DataInicial, Date    , Filtro de data de inicio.
@param 11 DataFinal  , Date    , Filtro de data de entrega.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
@return Nil
/*/
WSMETHOD GET PROGORDENS PATHPARAM Programacao QUERYPARAM Filter, Page, PageSize, FilterIN, codigo, produto, tipo, DataInicial, DataFinal WSSERVICE PCPA152RES
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152RES"), Break(oError)})
	Local cCodOP    := ""
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If Empty(Self:codigo)
			cCodOP := Self:Filter
		Else
			cCodOP := Self:codigo
		EndIf

		aReturn := getOrdens(cCodOP, Self:Page, Self:PageSize, Self:FilterIN, Self:Programacao, Self:produto, Self:tipo, Self:DataInicial, Self:DataFinal)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn
