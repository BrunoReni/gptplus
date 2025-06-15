#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSPFSALTLOTE.CH"

Static _JWSAltLote := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPFSAltLote
Métodos WS da Alteração em lote do SIGAPFS

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL WSPFSAltLote DESCRIPTION STR0001 // "Webservice PFS - Alteração em Lote"

WSDATA codPart      as String
WSDATA entidade     as String
WSDATA searchKey    as String
WSDATA qtdTotal     as Boolean
WSDATA socioRevisor as Boolean
WSDATA pageSize     as Number
WSDATA page         as Number

	WSMETHOD GET clientes        DESCRIPTION STR0002  PATH "cliente/{codPart}"         PRODUCES APPLICATION_JSON // "Busca os clientes no qual o participante é sócio / revisor"
	WSMETHOD GET casos           DESCRIPTION STR0003  PATH "caso/{codPart}"            PRODUCES APPLICATION_JSON // "Busca os casos no qual o participante é sócio / revisor"
	WSMETHOD GET contratos       DESCRIPTION STR0004  PATH "contrato/{codPart}"        PRODUCES APPLICATION_JSON // "Busca os contratos no qual o participante é sócio / revisor"
	WSMETHOD GET juncaoContratos DESCRIPTION STR0005  PATH "juncaoContrato/{codPart}"  PRODUCES APPLICATION_JSON // "Busca registrso da junção no qual o participante é sócio / revisor"
	WSMETHOD GET preFaturas      DESCRIPTION STR0006  PATH "preFatura/{codPart}"       PRODUCES APPLICATION_JSON // "Busca pre faturas no qual o participante é sócio / revisor"
	WSMETHOD GET fatAdicional    DESCRIPTION STR0007  PATH "faturaAdicional/{codPart}" PRODUCES APPLICATION_JSON // "Busca as faturas adicionais no qual o participante é sócio / revisor"
	WSMETHOD GET timesheet       DESCRIPTION STR0008  PATH "timesheet/{codPart}"       PRODUCES APPLICATION_JSON // "Busca os time sheets no qual o participante é sócio / revisor"
	WSMETHOD GET titReceber      DESCRIPTION STR0009  PATH "tituloReceber/{codPart}"   PRODUCES APPLICATION_JSON // "Busca os títulos a receber no qual o participante é sócio / revisor"
	WSMETHOD GET fatura          DESCRIPTION STR0010  PATH "fatura/{codPart}"          PRODUCES APPLICATION_JSON // "Busca as faturas no qual o participante é sócio / revisor"
	WSMETHOD GET socRevList      DESCRIPTION STR0017  PATH "listSociosRev/{entidade}"  PRODUCES APPLICATION_JSON // "Busca a lista de sócios / revisores"

	WSMETHOD PUT altPreFatura    DESCRIPTION STR0011  PATH "revisor/preFatura/{codPart}"      PRODUCES APPLICATION_JSON // "Alteração do Revisor na Pré-fatura"
	WSMETHOD PUT altContrato     DESCRIPTION STR0018  PATH "revisor/contrato/{codPart}"       PRODUCES APPLICATION_JSON // "Alteração do sócio responsável do contrato"
	WSMETHOD PUT altCaso         DESCRIPTION STR0030  PATH "revisor/caso/{codPart}"           PRODUCES APPLICATION_JSON // "Alteração de revisor e sócio do caso"
	WSMETHOD PUT altJuncoes      DESCRIPTION STR0027  PATH "revisor/juncaoContrato/{codPart}" PRODUCES APPLICATION_JSON // "Alteração do sócio responsável das junções de contrato"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET clientes
Busca os clientes no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/cliente/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET clientes PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local nIndexJSon := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal

Default cCodPart := ""
Default lTotal   := .F.

	cQuery := WSALQryCli(lTotal)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{cCodPart, cCodPart}), cAlias, .T., .F. )

	If !(cAlias)->(EOF())
		If lTotal
			oResponse['total'] := (cAlias)->QTD_CLIENTES
		Else
			oResponse := {}

			While (cAlias)->(!Eof())
				nIndexJSon++
				Aadd(oResponse, JsonObject():New())
				oResponse[nIndexJSon]['codCliente'] := (cAlias)->A1_COD
				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALCliPart(lCount)
Responsável por filtrar os clientes de acordo com o participante
sócio responsável pelo cliente e responsável da cobrança

@param lCount - Indica se deverá retornar a quantidade de registros
@return cQuery - Query com filtros

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALQryCli(lCount)
Local cQuery  := " SELECT"
Local cCampos := " A1_COD"

Default lCount := .F.

	If lCount
		cQuery += " COUNT(NUH.NUH_CPART) QTD_CLIENTES"
	Else
		cQuery += cCampos
	EndIf

	cQuery += " FROM " + RetSqlName( "SA1" ) + " SA1"
	cQuery +=     " INNER JOIN " + RetSqlName( "NUH" ) + " NUH"
	cQuery +=      " ON NUH.NUH_FILIAL = SA1.A1_FILIAL"
	cQuery +=          " AND NUH.NUH_COD = SA1.A1_COD"
	cQuery +=          " AND NUH.NUH_LOJA = SA1.A1_LOJA"
	cQuery +=          " AND NUH.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
	cQuery +=      " ON RD0.RD0_CODIGO = NUH.NUH_CPART"
	cQuery +=          " AND RD0.D_E_L_E_T_ = ' '"
	cQuery += " WHERE ( NUH.NUH_CPART = ?"           // Sócio Responsável do cliente
	cQuery +=            " OR NUH.NUH_SRCCOD = ? )"  // Sócio Responsavel da cobrança
	cQuery +=     " AND SA1.D_E_L_E_T_ = ' '"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET casos
Busca os casos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/caso/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET casos PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local nIndexJSon := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local nI         := 0
Local nPosSitCas := 0
Local nQtdPart   := 0
Local aCbxSitCas := STRTOKARR(JurEncUTF8(ALLTRIM(GetSx3Cache("NVE_SITUAC","X3_CBOX"))),";")
Local aParams    := {}
Local aParMltPart:= {}
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)

Default cCodPart := ""
Default lTotal   := .F.

	For nI := 1 To Len(aCbxSitCas)
		aCbxSitCas[nI] := StrTokArr(aCbxSitCas[nI],"=")
	Next nI

	// Trecho necessário para setar os valores de filtro da query utilizados pelo TCGenQry2
	If lMultRev
		nQtdPart := 6
	Else
		nQtdPart := 4
	EndIf

	For nI := 1 To nQtdPart
		aAdd(aParams, cCodPart)
	Next nI

	cQuery := WSALCasPart(lTotal)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )

	If !(cAlias)->(EOF())
		If lTotal
			oResponse['total'] := (cAlias)->QTD_CASOS
		Else
			oResponse := {}

			While (cAlias)->(!Eof())
				nIndexJSon++
				Aadd(oResponse, JsonObject():New())
				oResponse[nIndexJSon]['codigo']           := (cAlias)->NVE_FILIAL + (cAlias)->NVE_CCLIEN + ;
															 (cAlias)->NVE_LCLIEN + (cAlias)->NVE_NUMCAS
				oResponse[nIndexJSon]['codGrupoCliente']  := (cAlias)->NVE_CGRPCL
				oResponse[nIndexJSon]['descGrupoCliente'] := JConvUTF8((cAlias)->ACY_DESCRI)
				oResponse[nIndexJSon]['codCliente']       := (cAlias)->NVE_CCLIEN

				If !lLojaAuto
					oResponse[nIndexJSon]['codCliente'] := (cAlias)->NVE_CCLIEN + ;
														   " - " + (cAlias)->NVE_LCLIEN
				EndIf

				oResponse[nIndexJSon]['cliente']    := JConvUTF8((cAlias)->A1_NOME)
				oResponse[nIndexJSon]['codCaso']    := (cAlias)->NVE_NUMCAS
				oResponse[nIndexJSon]['tituloCaso'] := JConvUTF8((cAlias)->NVE_TITULO)
				oResponse[nIndexJSon]['codArea']    := (cAlias)->NVE_CAREAJ
				oResponse[nIndexJSon]['area']       := JConvUTF8((cAlias)->NRB_DESC)

				nPosSitCas := aScan(aCbxSitCas, {|x| x[1] == (cAlias)->NVE_SITUAC})

				oResponse[nIndexJSon]['situacao']              := JSonObject():New()
				oResponse[nIndexJSon]['situacao']['codigo']    := (cAlias)->NVE_SITUAC
				oResponse[nIndexJSon]['situacao']['descricao'] := JConvUTF8(aCbxSitCas[nPosSitCas][2])

				oResponse[nIndexJSon]['socio']                 := JSonObject():New()
				oResponse[nIndexJSon]['socio']['codigo']       := (cAlias)->SOCIOCODIGO
				oResponse[nIndexJSon]['socio']['nome']         := JConvUTF8((cAlias)->SOCIONOME)
				oResponse[nIndexJSon]['socio']['sigla']        := JConvUTF8((cAlias)->SOCIOSIGLA)

				oResponse[nIndexJSon]['revisor']               := JSonObject():New()
				oResponse[nIndexJSon]['revisor']['codigo']     := (cAlias)->REVCODIGO
				oResponse[nIndexJSon]['revisor']['nome']       := JConvUTF8((cAlias)->REVNOME)
				oResponse[nIndexJSon]['revisor']['sigla']      := JConvUTF8((cAlias)->REVSIGLA)
				oResponse[nIndexJson]['multRevisores']         := {}

				If (lMultRev)
					aAdd(aParMltPart, (cAlias)->NVE_CCLIEN)
					aAdd(aParMltPart, (cAlias)->NVE_LCLIEN)
					aAdd(aParMltPart, (cAlias)->NVE_NUMCAS)

					oResponse[nIndexJson]['multRevisores']     := MultPart(cQryMltPart("CASO"), aParMltPart)
					aSize(aParMltPart, 0)
				EndIf

				(cAlias)->( dbSkip() )
			EndDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	aSize(aParams,    0)
	aSize(aCbxSitCas, 0)
	aParams     := Nil
	aCbxSitCas  := Nil
	aParMltPart := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALCasPart(lCount)
Responsável por filtrar os casos de acordo com o participante revisor
do faturamento do caso, sócio responsável ou Revisor do remanejamento.
Filtra casos ativos e/ou casos inativos cujos lançamentos estão pendente
de faturamento.

@param lCount  - Indica se deverá retornar a quantidade de registros
@return cQuery - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALCasPart(lCount)
Local lMultRev := SuperGetMV("MV_JMULTRV",, .F.)
Local cQuery   := " SELECT"
Default lCount := .F.

	If lCount
		cQuery += " COUNT(NVE.NVE_NUMCAS) QTD_CASOS"
	Else
		cQuery += "  NVE_FILIAL"
		cQuery += " ,NVE_CGRPCL"
		cQuery += " ,ACY_DESCRI"
		cQuery += " ,NVE_CCLIEN"
		cQuery += " ,NVE_LCLIEN"
		cQuery += " ,A1_NOME"
		cQuery += " ,NVE_NUMCAS"
		cQuery += " ,NVE_TITULO"
		cQuery += " ,NVE_CAREAJ"
		cQuery += " ,NRB_DESC"
		cQuery += " ,NVE_SITUAC"
		cQuery += " ,NVE.NVE_CPART1 REVCODIGO"
		cQuery += " ,RD0REV.RD0_NOME REVNOME"
		cQuery += " ,RD0REV.RD0_SIGLA REVSIGLA"
		cQuery += " ,NVE.NVE_CPART5 SOCIOCODIGO"
		cQuery += " ,RD0SOC.RD0_NOME SOCIONOME"
		cQuery += " ,RD0SOC.RD0_SIGLA SOCIOSIGLA"
	EndIf

	cQuery +=  " FROM " + RetSqlName("NVE") + " NVE"
	cQuery +=  " LEFT JOIN " + RetSqlName("RD0") + " RD0REV"
	cQuery +=    " ON ( RD0REV.RD0_CODIGO = NVE.NVE_CPART1"
	cQuery +=   " AND RD0REV.D_E_L_E_T_ = ' ' )"
	cQuery +=  " LEFT JOIN " + RetSqlName("RD0") + " RD0SOC"
	cQuery +=    " ON ( RD0SOC.RD0_CODIGO = NVE.NVE_CPART5"
	cQuery +=   " AND RD0SOC.D_E_L_E_T_ = ' ' )"
	cQuery +=  " LEFT JOIN " + RetSqlName("NRB") + " NRB"
	cQuery +=    " ON ( NRB.NRB_COD = NVE.NVE_CAREAJ"
	cQuery +=   " AND NRB.D_E_L_E_T_ = ' ' )"
	cQuery +=  " LEFT JOIN " + RetSqlName("ACY") + " ACY"
	cQuery +=    " ON ( ACY.ACY_GRPVEN = NVE.NVE_CGRPCL"
	cQuery +=   " AND ACY.D_E_L_E_T_ = ' ' )"
	cQuery +=  " LEFT JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=    " ON ( SA1.A1_COD = NVE.NVE_CCLIEN"
	cQuery +=   " AND SA1.A1_LOJA = NVE.NVE_LCLIEN"
	cQuery +=   " AND SA1.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE NVE.D_E_L_E_T_ = ' '"

	// Processos em Andamento e com o Participante como Sócio, Revisor ou Multiplo
	cQuery +=   " AND ("
	cQuery +=         " ( NVE.NVE_SITUAC = '1'"  // 1=Em andamento
	cQuery +=       " AND ( NVE.NVE_CPART1 = ?"
	cQuery +=          " OR NVE.NVE_CPART5 = ?"
	
	// Verifica os multiplos Revisores 
	If (lMultRev)
		cQuery +=          " OR EXISTS ("
		cQuery +=             " SELECT OHN.OHN_CCASO,"
		cQuery +=                    " OHN.OHN_CPART"
		cQuery +=               " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=              " INNER JOIN " + RetSqlName("RD0") + " RD0"
		cQuery +=                 " ON RD0.RD0_CODIGO = OHN.OHN_CPART"
		cQuery +=                " AND RD0.D_E_L_E_T_ = ' '"
		cQuery +=              " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                " AND OHN.OHN_FILIAL = NVE.NVE_FILIAL"
		cQuery +=                " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                " AND OHN.OHN_CPART = ?"
		cQuery +=                    " )"
	EndIf

	cQuery +=           " ) "
	cQuery +=         " )"
	
	// Inicia verificação de Casos encerrados buscando lançamentos em aberto
	cQuery +=      " OR ( NVE.NVE_SITUAC = '2'"    // 2=Encerrado
	cQuery +=       " AND ( NVE.NVE_CPART1 = ?"
	cQuery +=          " OR NVE.NVE_CPART5 = ?"
	
	// Verifica os multiplos Revisores 
	If (lMultRev)
		cQuery +=          " OR EXISTS ("
		cQuery +=             " SELECT OHN.OHN_CCASO,"
		cQuery +=                    " OHN.OHN_CPART"
		cQuery +=               " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=              " INNER JOIN " + RetSqlName("RD0") + " RD0"
		cQuery +=                 " ON RD0.RD0_CODIGO = OHN.OHN_CPART"
		cQuery +=                " AND RD0.D_E_L_E_T_ = ' '"
		cQuery +=              " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                " AND OHN.OHN_FILIAL = NVE.NVE_FILIAL"
		cQuery +=                " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                " AND OHN.OHN_CPART = ?"
		cQuery +=                    " )"
	EndIf

	cQuery +=           " )"
	cQuery +=     " AND ("
	cQuery +=         " EXISTS ("
	
	// Verifica Casos de Faturas Adicionais pendentes de faturamento
	cQuery +=         " SELECT NVE.NVE_NUMCAS"
	cQuery +=           " FROM " + RetSqlName("NVV") + " NVV"
	cQuery +=          " INNER JOIN " + RetSqlName("NVW") + " NVW"
	cQuery +=             " ON NVW.NVW_FILIAL = NVV.NVV_FILIAL"
	cQuery +=            " AND NVW.NVW_CODFAD = NVV.NVV_COD"
	cQuery +=            " AND NVW.D_E_L_E_T_ = ' '"
	cQuery +=          " WHERE NVV.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN"
	cQuery +=            " AND NVE.NVE_LCLIEN = NVW.NVW_CLOJA"
	cQuery +=            " AND NVE.NVE_NUMCAS = NVW.NVW_CCASO"
	cQuery +=            " AND NVV.NVV_SITUAC = '1'"        // 1=Pendente
	cQuery +=                " )"
	cQuery +=      " OR EXISTS ("
	
	// Verifica os casos de Time Sheets pendentes de faturamento
	cQuery +=         " SELECT NVE.NVE_NUMCAS"
	cQuery +=           " FROM " + RetSqlName("NUE") + " NUE"
	cQuery +=          " WHERE NUE.NUE_FILIAL = NVE.NVE_FILIAL"
	cQuery +=            " AND NUE.NUE_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=            " AND NUE.NUE_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=            " AND NUE.NUE_CCASO = NVE.NVE_NUMCAS"
	cQuery +=            " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NUE.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NUE.NUE_SITUAC = '1'"        // 1=Pendente
	cQuery +=                " )"
	cQuery +=      " OR EXISTS ("

	// Verifica os casos de Lançamento Tabelados pendentes de faturamento
	cQuery +=         " SELECT NVE.NVE_NUMCAS"
	cQuery +=           " FROM " + RetSqlName("NV4") + " NV4"
	cQuery +=          " WHERE NV4.NV4_FILIAL = NVE.NVE_FILIAL"
	cQuery +=            " AND NV4.NV4_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=            " AND NV4.NV4_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=            " AND NV4.NV4_CCASO = NVE.NVE_NUMCAS"
	cQuery +=            " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NV4.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NV4.NV4_SITUAC = '1'"        // 1=Pendente
	cQuery +=                " )"
	cQuery +=      " OR EXISTS ("

	// Verifica os casos de Despesas pendentes de faturamento
	cQuery +=         " SELECT NVE.NVE_NUMCAS"
	cQuery +=           " FROM " + RetSqlName("NVY") + " NVY"
	cQuery +=          " WHERE NVY.NVY_FILIAL = NVE.NVE_FILIAL"
	cQuery +=            " AND NVY.NVY_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=            " AND NVY.NVY_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=            " AND NVY.NVY_CCASO = NVE.NVE_NUMCAS"
	cQuery +=            " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NVY.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NVY.NVY_SITUAC = '1'"        // 1=Pendente
	cQuery +=                " )"
	cQuery +=      " OR EXISTS ("

	// Verifica os casos de Fixo parcelado pendentes de faturamento
	cQuery +=         " SELECT NVE.NVE_NUMCAS"
	cQuery +=           " FROM " + RetSqlName("NT1") + " NT1"
	cQuery +=          " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=             " ON NT0.NT0_FILIAL = NT1.NT1_FILIAL"
	cQuery +=            " AND NT0.NT0_COD = NT1.NT1_CCONTR"
	cQuery +=            " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=          " INNER JOIN " + RetSqlName("NUT") + " NUT"
	cQuery +=             " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
	cQuery +=            " AND NUT.NUT_CCONTR = NT0.NT0_COD"
	cQuery +=            " AND NUT.D_E_L_E_T_ = ' '"
	cQuery +=          " WHERE NT1.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
	cQuery +=            " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
	cQuery +=            " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
	cQuery +=            " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=            " AND NT1.NT1_SITUAC = '1'"        // 1=Pendente
	cQuery +=                " )"
	cQuery +=         " )"
	cQuery +=       " )"
	cQuery +=   " )"
Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} GET contratos
Busca os contratos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/contrato/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET contratos PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local nIndexJSon := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Default cCodPart := ""
Default lTotal   := .F.

	cQuery := WSALContrPart(lTotal)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{cCodPart}), cAlias, .T., .F. )

	If !(cAlias)->(EOF())
		If lTotal
			oResponse['total'] := (cAlias)->QTD_CONTRATOS
		Else
			oResponse := {}

			While (cAlias)->(!Eof())
				nIndexJSon++
				Aadd(oResponse, JsonObject():New())
				oResponse[nIndexJSon]['codigo']            := (cAlias)->NT0_FILIAL + (cAlias)->NT0_COD
				oResponse[nIndexJSon]['codGrupo']          := (cAlias)->NT0_CGRPCL
				oResponse[nIndexJSon]['descGrupo']         := JConvUTF8((cAlias)->ACY_DESCRI)
				oResponse[nIndexJSon]['codCliente']        := (cAlias)->NT0_CCLIEN

				If !lLojaAuto
					oResponse[nIndexJSon]['codCliente']    := oResponse[nIndexJSon]['codCliente'] + " - " + ;
															  (cAlias)->NT0_CLOJA
				EndIf

				oResponse[nIndexJSon]['cliente']           := JConvUTF8((cAlias)->A1_NOME)
				oResponse[nIndexJSon]['descricao']         := JConvUTF8((cAlias)->NT0_NOME)
				oResponse[nIndexJSon]['codTipoHonorario']  := (cAlias)->NT0_CTPHON
				oResponse[nIndexJSon]['descTipoHonorario'] := JConvUTF8((cAlias)->NRA_DESC)
				oResponse[nIndexJSon]['codSocio']          := (cAlias)->RD0_CODIGO
				oResponse[nIndexJSon]['codOriginal']       := (cAlias)->RD0_CODIGO
				oResponse[nIndexJSon]['siglaSocio']        := JConvUTF8((cAlias)->RD0_SIGLA)
				oResponse[nIndexJSon]['descSocio']         := JConvUTF8((cAlias)->RD0_NOME)
				oResponse[nIndexJSon]['situacao']          := (cAlias)->NT0_SIT
				oResponse[nIndexJSon]['ativo']             := (cAlias)->NT0_ATIVO
				oResponse[nIndexJSon]['updated']           := .F.
				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALContrPart(lCount)
Responsável por filtrar os contratos de acordo com o participante revisor
sócio responsável. Filtra contratos ativos.

@param lCount  - Indica se deverá retornar a quantidade de registros
@return cQuery - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALContrPart(lCount)
Local cQuery  := " SELECT"

Default lCount := .F.

	If lCount
		cQuery += " COUNT(NT0.NT0_CPART1) QTD_CONTRATOS"
	Else
		cQuery += " NT0_FILIAL"
		cQuery += " ,NT0_COD"
		cQuery += " ,NT0_CGRPCL"
		cQuery += " ,NT0_CCLIEN"
		cQuery += " ,NT0_CLOJA"
		cQuery += " ,NT0_NOME"
		cQuery += " ,NT0_CTPHON"
		cQuery += " ,NT0_CPART1"
		cQuery += " ,NT0_SIT"
		cQuery += " ,NT0_ATIVO"
		cQuery += " ,RD0_CODIGO"
		cQuery += " ,RD0_SIGLA"
		cQuery += " ,RD0_NOME"
		cQuery += " ,ACY_DESCRI"
		cQuery += " ,A1_NOME"
		cQuery += " ,NRA_DESC"
	EndIf

	cQuery +=  " FROM " + RetSqlName( "NT0" ) + " NT0"
	cQuery += " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
	cQuery +=    " ON RD0.RD0_CODIGO = NT0.NT0_CPART1"
	cQuery +=   " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " +  RetSqlName('ACY') + " ACY"
	cQuery +=    " ON (ACY.ACY_GRPVEN = NT0.NT0_CGRPCL"
	cQuery +=   " AND ACY.D_E_L_E_T_ = ' ')"
	cQuery += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1"
	cQuery +=    " ON NT0.NT0_CCLIEN = SA1.A1_COD"
	cQuery +=   " AND NT0.NT0_CLOJA = SA1.A1_LOJA"
	cQuery +=   " AND SA1.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN " + RetSqlName( "NRA" ) + " NRA"
	cQuery +=    " ON NT0.NT0_CTPHON = NRA.NRA_COD"
	cQuery +=   " AND NRA.D_E_L_E_T_ = ' '"
	cQuery += " WHERE NT0.NT0_CPART1 = ?"
	cQuery +=   " AND NT0.D_E_L_E_T_ = ' '"

	If !lCount
		cQuery += " ORDER BY NT0.NT0_COD"
	EndIf

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} GET juncaoContratos
Busca os contratos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/juncaoContrato/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET juncaoContratos PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local nIndexJSon := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Default cCodPart := ""
Default lTotal   := .F.

	cQuery := WSALJContPart(lTotal)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{cCodPart}), cAlias, .T., .F. )

	If !(cAlias)->(EOF())
		If lTotal
			oResponse['total'] := (cAlias)->QTD_JUNCAO
		Else
			oResponse := {}

			While (cAlias)->(!Eof())
				nIndexJSon++
				Aadd(oResponse, JsonObject():New())
				oResponse[nIndexJSon]['codigo']     := (cAlias)->NW2_FILIAL + (cAlias)->NW2_COD
				oResponse[nIndexJSon]['codGrupo']   := (cAlias)->NW2_CGRUPO
				oResponse[nIndexJSon]['descGrupo']  := JConvUTF8((cAlias)->ACY_DESCRI)
				oResponse[nIndexJSon]['codCliente'] := (cAlias)->NW2_CCLIEN

				If !lLojaAuto
					oResponse[nIndexJSon]['codCliente'] := oResponse[nIndexJSon]['codCliente'] + " - " + (cAlias)->NW2_CLOJA
				EndIf

				oResponse[nIndexJSon]['cliente']     := JConvUTF8((cAlias)->A1_NOME)
				oResponse[nIndexJSon]['descricao']   := JConvUTF8((cAlias)->NW2_DESC)
				oResponse[nIndexJSon]['codSocio']    := (cAlias)->RD0_CODIGO
				oResponse[nIndexJSon]['codOriginal'] := (cAlias)->RD0_CODIGO
				oResponse[nIndexJSon]['siglaSocio']  := JConvUTF8((cAlias)->RD0_SIGLA)
				oResponse[nIndexJSon]['descSocio']   := JConvUTF8((cAlias)->RD0_NOME)
				oResponse[nIndexJSon]['updated']     := .F.
				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALJContPart(lCount)
Responsável por filtrar os contratos da Junção de contratos de acordo
com o participante revisor da junção. Filtra contratos da Junção de
contratos que estão ativos. Considera se ao menos um dos contratos
da junção estiver ativo.

@param lCount  - Indica se deverá retornar a quantidade de registros
@return cQuery - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALJContPart(lCount)
Local cQuery  := " SELECT"

Default lCount := .F.

	If lCount
		cQuery += " COUNT(NW2.NW2_COD) QTD_JUNCAO"
	Else
		cQuery +=  " ACY.ACY_DESCRI"
		cQuery += " ,NW2.NW2_FILIAL"
		cQuery += " ,NW2.NW2_CGRUPO"
		cQuery += " ,NW2.NW2_CCLIEN"
		cQuery += " ,NW2.NW2_COD"
		cQuery += " ,NW2.NW2_CLOJA"
		cQuery += " ,NW2.NW2_DESC"
		cQuery += " ,NW2.NW2_CPART"
		cQuery += " ,SA1.A1_NOME"
		cQuery += " ,RD0.RD0_CODIGO"
		cQuery += " ,RD0.RD0_SIGLA"
		cQuery += " ,RD0.RD0_NOME"
	EndIf

	cQuery += " FROM " + RetSqlName( "NW2" ) + " NW2"
	cQuery +=       " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
	cQuery +=           " ON RD0.RD0_CODIGO = NW2.NW2_CPART"
	cQuery +=               " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=       " INNER JOIN ( SELECT NW3.NW3_CJCONT, COUNT(1) QTD"
	cQuery +=                      " FROM " + RetSqlName( "NW3" ) + " NW3" 
	cQuery +=                             " INNER JOIN " + RetSqlName( "NT0" ) + " NT0"
	cQuery +=                                 " ON (NT0.NT0_COD = NW3.NW3_CCONTR)"
	cQuery +=                             " WHERE NW3.D_E_L_E_T_ = ' '"
	cQuery +=                                  " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=                                  " AND NT0_ATIVO = '1'"   // Ativo? 1=Sim (Se ao menos um dos contratos da junção estiver ativo)
	cQuery +=                             " GROUP BY NW3.NW3_CJCONT"
	cQuery +=                             " HAVING COUNT(1) > 0"
	cQuery +=                   " ) SUBNW3"
	cQuery +=                      " ON (SUBNW3.NW3_CJCONT = NW2.NW2_COD)"

	// Cliente
	cQuery += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1"
	cQuery +=       " ON NW2.NW2_CCLIEN = SA1.A1_COD"
	cQuery +=       " AND NW2.NW2_CLOJA = SA1.A1_LOJA"
	cQuery +=       " AND SA1.D_E_L_E_T_  = ' '"

	// Grupo de cliente
	cQuery += " LEFT JOIN " +  RetSqlName('ACY') + " ACY"
	cQuery +=      " ON (ACY.ACY_GRPVEN = NW2.NW2_CGRUPO"
	cQuery +=      " AND ACY.D_E_L_E_T_ = ' ')"

	cQuery += " WHERE NW2.D_E_L_E_T_ = ' '"
	cQuery +=       " AND NW2.NW2_CPART = ?"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET preFaturas
Busca os contratos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/preFatura/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET preFaturas PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local nIndexJSon := 0
Local cAlias     := GetNextAlias()
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)

Default cCodPart := ""
Default lTotal   := .F.

	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL, WSALPFatPart(lTotal),{cCodPart, cCodPart}), cAlias, .T., .F. )

	If !(cAlias)->(Eof())
		If lTotal
			oResponse['total'] := (cAlias)->QTD_PRE_FAT
		Else
			oResponse := {}

			While (cAlias)->(!Eof())
				nIndexJSon++
				Aadd(oResponse, JsonObject():New())
				oResponse[nIndexJSon]['codigo']         := (cAlias)->NX0_FILIAL + (cAlias)->NX0_COD
				oResponse[nIndexJSon]['situacao']       := JConvUTF8((cAlias)->NX0_SITUAC)
				oResponse[nIndexJSon]['dataEmissao']    := (cAlias)->NX0_DTEMI
				oResponse[nIndexJSon]['vlrHonorario']   := (cAlias)->NX0_VLFATH
				oResponse[nIndexJSon]['vlrDespesa']     := (cAlias)->NX0_VLFATD
				oResponse[nIndexJSon]['codEscritorio']  := (cAlias)->NX0_CESCR
				oResponse[nIndexJSon]['codCliente']     := (cAlias)->NX0_CCLIEN
				
				If !lLojaAuto
					oResponse[nIndexJSon]['codCliente'] := oResponse[nIndexJSon]['codCliente'] + " - " + (cAlias)->NX0_CLOJA
				EndIf
				
				oResponse[nIndexJSon]['cliente']        := JConvUTF8((cAlias)->A1_NOME)
				oResponse[nIndexJSon]['codContr']       := (cAlias)->NX0_CCONTR
				oResponse[nIndexJSon]['capa']           := RetPartCapa(cAlias)
				oResponse[nIndexJSon]['descEscritorio'] := JConvUTF8((cAlias)->NS7_NOME)
				oResponse[nIndexJSon]['descMoeda']      := JConvUTF8((cAlias)->CTO_DESC)
				oResponse[nIndexJSon]['simbMoeda']      := AllTrim((cAlias)->CTO_SIMB)
				oResponse[nIndexJson]['contratos']      := JConvUTF8(PreFatCont((cAlias)->NX0_COD))
				oResponse[nIndexJson]['casos']          := JConvUTF8(PreFatCaso((cAlias)->NX0_COD))
				oResponse[nIndexJson]['multRevisores']  := {}

				If (lMultRev)
					oResponse[nIndexJson]['multRevisores']  := MultPart(cQryMltPart('PREFATURA'), { (cAlias)->NX0_COD })
				EndIf

				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	RestArea(aArea)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPartCapa(cAlias)
Responsável por filtrar as Pré-Faturas de acordo com o participante
revisor. Filtra contratos da Junção de
contratos que estão ativos. Considera se ao menos um dos contratos
da junção estiver ativo.

@param lCount  - Indica se deverá retornar a quantidade de registros
@return cQuery - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPartCapa(cAlias)
Local oPart := JSonObject():New()

	oPart['codigo']      := (cAlias)->RD0_CODIGO
	oPart['nome']        := JConvUTF8((cAlias)->RD0_NOME)
	oPart['sigla']       := JConvUTF8((cAlias)->RD0_SIGLA)
	oPart['codOriginal'] := (cAlias)->RD0_CODIGO
	oPart['updated']     := .F.
	oPart['deleted']     := .F.
Return oPart

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALPFatPart(lCount)
Responsável por filtrar as Pré-Faturas de acordo com o participante
revisor. Filtra contratos da Junção de
contratos que estão ativos. Considera se ao menos um dos contratos
da junção estiver ativo.

@param lCount  - Indica se deverá retornar a quantidade de registros
@return cQuery - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALPFatPart(lCount)
Local cQryPreFat  := " SELECT"

Default lCount := .F.

	If lCount
		cQryPreFat += " COUNT(NX0.NX0_CPART) QTD_PRE_FAT"
	Else
		cQryPreFat += "  NX0.NX0_FILIAL"
		cQryPreFat += " ,NX0.NX0_COD"
		cQryPreFat += " ,NX0.NX0_SITUAC"
		cQryPreFat += " ,NX0.NX0_DTEMI"
		cQryPreFat += " ,NX0.NX0_VLFATH"
		cQryPreFat += " ,NX0.NX0_VLFATD"
		cQryPreFat += " ,NX0.NX0_CESCR"
		cQryPreFat += " ,NX0.NX0_CCLIEN"
		cQryPreFat += " ,NX0.NX0_CLOJA"
		cQryPreFat += " ,SA1.A1_NOME"
		cQryPreFat += " ,NX0.NX0_CCONTR"
		cQryPreFat += " ,RD0CAPA.RD0_CODIGO"
		cQryPreFat += " ,RD0CAPA.RD0_NOME"
		cQryPreFat += " ,RD0CAPA.RD0_SIGLA"
		cQryPreFat += " ,NS7.NS7_NOME"
		cQryPreFat += " ,CTO.CTO_DESC"
		cQryPreFat += " ,CTO.CTO_SIMB"
	EndIf

	cQryPreFat +=  " FROM " + RetSqlName( "NX0" ) + " NX0"
	cQryPreFat += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1"
	cQryPreFat +=    " ON NX0.NX0_CCLIEN  = SA1.A1_COD"
	cQryPreFat +=   " AND NX0.NX0_CLOJA   = SA1.A1_LOJA"
	cQryPreFat +=   " AND SA1.D_E_L_E_T_  = ' '"
	cQryPreFat += " INNER JOIN " + RetSqlName( "NS7" ) + " NS7"
	cQryPreFat +=    " ON NX0.NX0_CESCR   = NS7.NS7_COD"
	cQryPreFat +=   " AND NS7.D_E_L_E_T_  = ' '"
	cQryPreFat += " INNER JOIN " + RetSqlName( "RD0" ) + " RD0CAPA"
	cQryPreFat +=    " ON NX0.NX0_CPART   = RD0CAPA.RD0_CODIGO"
	cQryPreFat +=   " AND RD0CAPA.D_E_L_E_T_ = ' '"
	cQryPreFat += " INNER JOIN " + RetSqlName( "CTO" ) + " CTO"
	cQryPreFat +=    " ON CTO.CTO_MOEDA   = NX0.NX0_CMOEDA"
	cQryPreFat +=   " AND CTO.CTO_FILIAL  = NS7.NS7_CFILIA"
	cQryPreFat +=   " AND CTO.D_E_L_E_T_  = ' '"
	cQryPreFat += " WHERE NX0.D_E_L_E_T_  = ' '"
	cQryPreFat +=   " AND NX0_SITUAC IN('2',"   // 2 - Análise
	cQryPreFat +=                     " '3',"   // 3 - Alterada
	cQryPreFat +=                     " '7',"   // 7 - Minuta cancelada
	cQryPreFat +=                     " 'C',"   // C - Em revisão
	cQryPreFat +=                     " 'E',"   // E - Revisada com restrições
	cQryPreFat +=                     " 'B')"   // B - Minuta Sócio Cancelada
	cQryPreFat +=   " AND ( NX0.NX0_CPART = ?"

	// Verifica se o participante está no grid em múltiplos revisores
	cQryPreFat +=      " OR EXISTS ("
	cQryPreFat +=         " SELECT OHN.OHN_CCASO"
	cQryPreFat +=           " FROM " + RetSqlName( "OHN" ) + " OHN"
	cQryPreFat +=          " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
	cQryPreFat +=             " ON RD0.RD0_CODIGO = OHN.OHN_CPART"
	cQryPreFat +=            " AND RD0.D_E_L_E_T_ = ' '"
	cQryPreFat +=          " WHERE OHN.OHN_FILIAL = NX0.NX0_FILIAL"
	cQryPreFat +=            " AND OHN.OHN_CPREFT = NX0.NX0_COD"
	cQryPreFat +=            " AND OHN.OHN_CPART = ?"
	cQryPreFat +=            " AND OHN.D_E_L_E_T_ = ' '"
	cQryPreFat +=          " )"
	cQryPreFat +=       " )"

	If !lCount
		cQryPreFat += " ORDER BY NX0.NX0_COD"
	EndIf
Return cQryPreFat

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFatCaso(cPreFat)
Responsável por busca número do caso e título do caso

@param cPreFat - Código da Pré-Fatura 
@return cResp  - String com numero do caso + título do caso

@author Victor Gonçalves
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreFatCaso(cPreFat)
Local cQuery := ""
Local cAlias := ""
Local cResp  := ""

	cQuery +=  " SELECT NVE.NVE_TITULO"
	cQuery +=        " ,NVE.NVE_NUMCAS"
	cQuery +=  " FROM " + RetSqlName( "NX1" ) + " NX1"
	cQuery +=       " INNER JOIN " + RetSqlName( "NVE" ) + " NVE"
	cQuery +=         " ON NX1.NX1_FILIAL = NVE.NVE_FILIAL"
	cQuery +=             " AND NX1.NX1_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=             " AND NX1.NX1_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=             " AND NX1.NX1_CCASO = NVE.NVE_NUMCAS"
	cQuery +=      " WHERE NX1.NX1_CPREFT = ?"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ cPreFat }), cAlias, .T., .T. )

	While !( cAlias )->(Eof()) 
		cResp += (cAlias)->NVE_NUMCAS + (cAlias)->NVE_TITULO + ";"
		(cAlias)->( dbSkip() )
	End

	If Len(cResp) > 0
		cResp := SUBSTR( cResp, 0, Len(cResp)-1)
	EndIf

	( cAlias )->( dbCloseArea() )
	
Return cResp

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFatCont(cPreFat)
Responsável por retornar o código e título do contrato

@param cPreFat - Código da Pré-Fatura 
@return cResp  - String com o código e título do contrato

@author Victor Gonçalves
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreFatCont(cPreFat)
Local cQuery := ""
Local cAlias := ""
Local cResp  := ""

	cQuery +=  " SELECT NT0.NT0_NOME"
	cQuery +=        " ,NT0.NT0_COD"
	cQuery +=       " FROM " + RetSqlName( "NX8" ) + " NX8"
	cQuery +=             " INNER JOIN " + RetSqlName( "NT0" ) + " NT0"
	cQuery +=                 " ON NX8.NX8_CCLIEN = NT0.NT0_CCLIEN"
	cQuery +=                     " AND NX8.NX8_CLOJA = NT0.NT0_CLOJA"
	cQuery +=                     " AND NX8.NX8_CCONTR = NT0.NT0_COD"
	cQuery += 	   " WHERE NX8.NX8_CPREFT = ?"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ cPreFat }), cAlias, .T., .T. )

	While !( cAlias )->(Eof()) 
		cResp += (cAlias)->NT0_COD + (cAlias)->NT0_NOME + ";"
		(cAlias)->( dbSkip() )
	End

	If Len(cResp) > 0
		cResp := SUBSTR( cResp, 0, Len(cResp)-1)
	EndIf

	( cAlias )->( dbCloseArea() )

Return cResp

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFatMult(cPreFat)
Responsável por retornar a lista de mútiplos revisores  da pré fatura

@param cPreFat   - Código da Pré-Fatura
@return oResponse - Objeto com a lista de mútiplos revisores da pré fatura

@author Victor Gonçalves
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MultPart(cQuery, aParams)
Local oResponse  := {}
Local aCboxTpRev := {}
Local cAliasMlt  := ""
Local nIndexJSon := 0
Local nI         := 0

Default cQuery   := ""
Default aParams  := {}

	// 1=Honorários;2=Despesas;3=Ambos
	aCboxTpRev := STRTOKARR(JurEncUTF8(ALLTRIM(GetSx3Cache("OHN_REVISA","X3_CBOX"))),";")

	For nI := 1 To Len(aCboxTpRev)
		aCboxTpRev[nI] := StrTokArr(aCboxTpRev[nI],"=")
	Next nI

	cAliasMlt := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL, cQuery, aParams ), cAliasMlt, .T., .T. )

	While !( cAliasMlt )->(Eof()) 
		nIndexJSon++
		Aadd(oResponse, JsonObject():New())
		oResponse[nIndexJSon]['chave'] := (cAliasMlt)->OHN_FILIAL ;
										+ (cAliasMlt)->OHN_CPREFT ;
										+ (cAliasMlt)->OHN_CCONTR ;
										+ (cAliasMlt)->OHN_CCLIEN ;
										+ (cAliasMlt)->OHN_CLOJA  ;
										+ (cAliasMlt)->OHN_CCASO  ;
										+ (cAliasMlt)->OHN_CPART  ;
										+ (cAliasMlt)->OHN_REVISA

		oResponse[nIndexJSon]['participante']                := JsonObject():New()
		oResponse[nIndexJSon]['participante']['codigo']      := (cAliasMlt)->RD0_CODIGO
		oResponse[nIndexJSon]['participante']['nome']        := JConvUTF8((cAliasMlt)->RD0_NOME)
		oResponse[nIndexJSon]['participante']['sigla']       := JConvUTF8((cAliasMlt)->RD0_SIGLA)
		oResponse[nIndexJSon]['participante']['codOriginal'] := (cAliasMlt)->RD0_CODIGO
		oResponse[nIndexJSon]['participante']['updated']     := .F.
		oResponse[nIndexJSon]['participante']['deleted']     := .F.

		nPosTipRev := aScan(aCboxTpRev, {|x| x[1] == (cAliasMlt)->OHN_REVISA})
		oResponse[nIndexJSon]['tipoRevisao']                 := JSonObject():New()
		oResponse[nIndexJSon]['tipoRevisao']['codigo']       := (cAliasMlt)->OHN_REVISA
		oResponse[nIndexJSon]['tipoRevisao']['descricao']    := JConvUTF8(aCboxTpRev[nPosTipRev][2])

		(cAliasMlt)->( dbSkip() )
	End

	( cAliasMlt )->( dbCloseArea() )

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fatAdicional
Busca as Faturas Adicionais no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/faturaAdicional/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET fatAdicional PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local lHasOcorre := .F.
Local nIndexJSon := 0
Local cQuery     := ""
Local cAlias     := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal

Default lTotal   := .F.

	DbSelectArea("NVV")
	lHasOcorre := NVV->(FieldPos("NVV_OCORRE")) > 0
	NVV->( DBCloseArea() )

	If lTotal
		cQuery += " SELECT COUNT(1) QtdTotal"
	Else
		cQuery += " SELECT NVV_COD,"
		cQuery +=        " NVV_DTBASE,"
		cQuery +=        " NVV_CGRUPO,"
		cQuery +=        " ACY.ACY_DESCRI,"
		cQuery +=        " NVV_CCLIEN,"
		cQuery +=        " NVV_CLOJA,"
		cQuery +=        " SA1.A1_NOME,"
		cQuery +=        " NVV_CCONTR,"
		cQuery +=        " NT0.NT0_NOME,"
		cQuery +=        " NVV_VALORH,"
		cQuery +=        " NVV_VALORT,"
		cQuery +=        " NVV_VALORD,"
		cQuery +=        " NVV_VALDTR"

		If lHasOcorre
			cQuery +=        " ,NVV_OCORRE"
		EndIf
	EndIf

	cQuery += " FROM " + RetSqlName('NVV') + " NVV INNER JOIN " +  RetSqlName('RD0') + " RD0 ON (RD0.RD0_CODIGO = NVV.NVV_CPART1"
	cQuery +=                                                                             " AND RD0.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " +  RetSqlName('SA1') + " SA1 ON (SA1.A1_COD = NVV.NVV_CCLIEN"
	cQuery +=                                                                             " AND SA1.A1_LOJA = NVV.NVV_CLOJA"
	cQuery +=                                                                             " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " +  RetSqlName('NT0') + " NT0 ON (NT0.NT0_COD = NVV.NVV_CCONTR"
	cQuery +=                                                                             " AND NT0.NT0_CCLIEN = NVV.NVV_CCLIEN"
	cQuery +=                                                                             " AND NT0.NT0_CLOJA = NVV.NVV_CLOJA"
	cQuery +=                                                                             " AND NT0.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " LEFT  JOIN " +  RetSqlName('ACY') + " ACY ON (ACY.ACY_GRPVEN = NVV.NVV_CGRUPO"
	cQuery +=                                                                             " AND ACY.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NVV_CPART1 = ?"
	cQuery +=        " AND NVV.D_E_L_E_T_ = ' '"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart }), cAlias, .T., .F. )

	If (lTotal)
		oResponse['total'] := (cAlias)->QtdTotal
	Else
		oResponse := {}

		While !( cAlias )->(Eof())
			nIndexJSon++
			Aadd(oResponse, JsonObject():New())
			oResponse[nIndexJSon]['codigo']             := (cAlias)->NVV_COD
			oResponse[nIndexJSon]['database']           := (cAlias)->NVV_DTBASE
			oResponse[nIndexJSon]['codGrupo']           := (cAlias)->NVV_CGRUPO
			oResponse[nIndexJSon]['descGrupo']          := JConvUTF8((cAlias)->ACY_DESCRI)
			oResponse[nIndexJSon]['codCliente']         := (cAlias)->NVV_CCLIEN
			oResponse[nIndexJSon]['lojaCliente']        := (cAlias)->NVV_CLOJA
			oResponse[nIndexJSon]['cliente']            := JConvUTF8((cAlias)->A1_NOME)
			oResponse[nIndexJSon]['codContrato']        := (cAlias)->NVV_CCONTR
			oResponse[nIndexJSon]['nomeContrato']       := JConvUTF8((cAlias)->NT0_NOME)
			oResponse[nIndexJSon]['valorTS']            := (cAlias)->NVV_VALORH
			oResponse[nIndexJSon]['valorTabelado']      := (cAlias)->NVV_VALORT
			oResponse[nIndexJSon]['valorDespesa']       := (cAlias)->NVV_VALORD
			oResponse[nIndexJSon]['valorDespesaTrib']   := (cAlias)->NVV_VALDTR

			If lHasOcorre
				oResponse[nIndexJSon]['flagOcorrencia'] := (cAlias)->NVV_OCORRE
			EndIf

			(cAlias)->( dbSkip() )
		End
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET timesheet
Busca os Time Sheets no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/timesheet/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET timesheet PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local nIndexJSon := 0
Local cQuery     := ""
Local cAlias     := ""
Local cDesc      := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal

Default lTotal   := .F.

	If lTotal
		cQuery += " SELECT COUNT(1) QtdTotal"
	Else
		cQuery += " SELECT NUE.NUE_COD,"
		cQuery +=        " NUE.NUE_DATATS,"
		cQuery +=        " NUE.NUE_CPART1,"
		cQuery +=        " RD0SOL.RD0_NOME  NOME_SOL,"
		cQuery +=        " RD0SOL.RD0_SIGLA SIGLA_SOL,"
		cQuery +=        " NUE.NUE_CPART2,"
		cQuery +=        " RD0REV.RD0_NOME  NOME_REV,"
		cQuery +=        " RD0REV.RD0_SIGLA SIGLA_REV,"
		cQuery +=        " NUE.NUE_CCLIEN,"
		cQuery +=        " NUE.NUE_CLOJA,"
		cQuery +=        " SA1.A1_NOME,"
		cQuery +=        " NUE.NUE_CCASO,"
		cQuery +=        " NVE.NVE_TITULO,"
		cQuery +=        " NUE.NUE_CATIVI,"
		cQuery +=        " NRC.NRC_DESC,"
		cQuery +=        " NUE.NUE_HORAL,"
		cQuery +=        " NUE.NUE_HORAR,"
		cQuery +=        " NUE.NUE_UTL,"
		cQuery +=        " NUE.NUE_UTR,"
		cQuery +=        " NUE.NUE_COBRAR,"
		cQuery +=        " NUE.NUE_CMOEDA,"
		cQuery +=        " CTO.CTO_SIMB,"
		cQuery +=        " CTO.CTO_DESC,"
		cQuery +=        " NUE.NUE_VALOR,"
		cQuery +=        " NUE.NUE_FILIAL "
	EndIf

	cQuery += " FROM " +  RetSqlName("NUE") + " NUE INNER JOIN " +  RetSqlName("RD0") + " RD0SOL ON (RD0SOL.RD0_CODIGO = NUE.NUE_CPART1"
	cQuery +=                                                                                  " AND RD0SOL.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("RD0") + " RD0REV ON (RD0REV.RD0_CODIGO = NUE.NUE_CPART2"
	cQuery +=                                                                                  " AND RD0REV.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("SA1") + " SA1 ON (SA1.A1_COD     = NUE.NUE_CCLIEN"
	cQuery +=                                                                               " AND SA1.A1_LOJA    = NUE.NUE_CLOJA"
	cQuery +=                                                                               " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("NVE") + " NVE ON (NVE.NVE_CCLIEN = NUE.NUE_CCLIEN"
	cQuery +=                                                                               " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
	cQuery +=                                                                               " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO"
	cQuery +=                                                                               " AND NVE.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("NRC") + " NRC ON (NRC.NRC_COD    = NUE.NUE_CATIVI"
	cQuery +=                                                                               " AND NRC.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("NS7") + " NS7 ON (NS7.NS7_COD    = NUE.NUE_CESCR"
	cQuery +=                                                                               " AND NS7.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("CTO") + " CTO ON (CTO.CTO_MOEDA  = NUE.NUE_CMOEDA"
	cQuery +=                                                                               " AND CTO.CTO_FILIAL = NS7.NS7_CFILIA"
	cQuery +=                                                                               " AND CTO.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE ( NUE.NUE_CPART1 = ?"
	cQuery +=          " OR NUE.NUE_CPART2 = ? )"
	cQuery +=   " AND NUE.D_E_L_E_T_ = ' '"
	cQuery +=   " AND NUE.NUE_SITUAC = '1'"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart, Self:codPart }), cAlias, .T., .F. )

	If (lTotal)
		If !( cAlias )->(Eof())
			oResponse['total'] := (cAlias)->QtdTotal
		EndIf
	Else
		oResponse := {}
		While !( cAlias )->(Eof())
			nIndexJSon++
			cDesc := JurGetDados("NUE", 1, (cAlias)->NUE_FILIAL + (cAlias)->NUE_COD, "NUE_DESC")
			Aadd(oResponse, JsonObject():New())
			oResponse[nIndexJSon]['codigo']           := (cAlias)->NUE_COD
			oResponse[nIndexJSon]['data']             := (cAlias)->NUE_DATATS
			oResponse[nIndexJSon]['codPartSolic']     := (cAlias)->NUE_CPART1
			oResponse[nIndexJSon]['nomePartSolic']    := JConvUTF8((cAlias)->NOME_SOL)
			oResponse[nIndexJSon]['siglaPartSolic']   := (cAlias)->SIGLA_SOL
			oResponse[nIndexJSon]['codPartRevis']     := (cAlias)->NUE_CPART2
			oResponse[nIndexJSon]['nomePartRevis']    := JConvUTF8((cAlias)->NOME_REV)
			oResponse[nIndexJSon]['siglaPartRevis']   := (cAlias)->SIGLA_REV
			oResponse[nIndexJSon]['codCliente']       := (cAlias)->NUE_CCLIEN
			oResponse[nIndexJSon]['lojaCliente']      := (cAlias)->NUE_CLOJA
			oResponse[nIndexJSon]['cliente']          := JConvUTF8((cAlias)->A1_NOME)
			oResponse[nIndexJSon]['codCaso']          := (cAlias)->NUE_CCASO
			oResponse[nIndexJSon]['tituloCaso']       := JConvUTF8((cAlias)->NVE_TITULO)
			oResponse[nIndexJSon]['codAtividade']     := (cAlias)->NUE_CATIVI
			oResponse[nIndexJSon]['descAtividade']    := JConvUTF8((cAlias)->NRC_DESC)
			oResponse[nIndexJSon]['horaLancada']      := (cAlias)->NUE_HORAL
			oResponse[nIndexJSon]['horaRevisada']     := (cAlias)->NUE_HORAR
			oResponse[nIndexJSon]['UTLancada']        := (cAlias)->NUE_UTL
			oResponse[nIndexJSon]['UTRevisada']       := (cAlias)->NUE_UTR
			oResponse[nIndexJSon]['cobrar']           := (cAlias)->NUE_COBRAR
			oResponse[nIndexJSon]['codMoeda']         := (cAlias)->NUE_CMOEDA
			oResponse[nIndexJSon]['simbMoeda']        := (cAlias)->CTO_SIMB
			oResponse[nIndexJSon]['descMoeda']        := JConvUTF8((cAlias)->CTO_DESC)
			oResponse[nIndexJSon]['valorTS']          := (cAlias)->NUE_VALOR
			oResponse[nIndexJSon]['descTS']           := JConvUTF8(cDesc)
			(cAlias)->( dbSkip() )
		End
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GET titReceber
Busca os Títulos a receber no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/tituloReceber/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET titReceber PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local nIndexJSon := 0
Local cQuery     := ""
Local cAlias     := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal
Local cAnoMes    := AnoMes(Date())

Default lTotal   := .F.

	If lTotal
		cQuery += " SELECT COUNT(*) QtdTotal"
	Else
		cQuery += " SELECT SE1.E1_PREFIXO"
		cQuery +=       " ,SE1.E1_NUM"
		cQuery +=       " ,SE1.E1_PARCELA"
		cQuery +=       " ,SE1.E1_TIPO"
		cQuery +=       " ,NXA.NXA_CPART"
		cQuery +=       " ,RD0.RD0_SIGLA"
		cQuery +=       " ,RD0.RD0_NOME"
		cQuery +=       " ,SE1.E1_NATUREZ"
		cQuery +=       " ,SED.ED_DESCRIC"
		cQuery +=       " ,SE1.E1_EMISSAO"
		cQuery +=       " ,SE1.E1_VENCTO"
		cQuery +=       " ,SE1.E1_VENCREA"
		cQuery +=       " ,SE1.E1_VALOR"
		cQuery +=       " ,SE1.E1_VLRREAL"
		cQuery +=       " ,OHH.OHH_SALDO"
		cQuery +=       " ,SE1.E1_HIST"
	EndIf

	cQuery += " FROM " + RetSqlName("OHH") + " OHH INNER JOIN " + RetSqlName("OHT") + " OHT ON (OHT.OHT_PREFIX = OHH.OHH_PREFIX"
	cQuery +=                                                                             " AND OHT.OHT_TITNUM = OHH.OHH_NUM"
	cQuery +=                                                                             " AND OHT.OHT_TITPAR = OHH.OHH_PARCEL"
	cQuery +=                                                                             " AND OHT.OHT_TITTPO = OHH.OHH_TIPO"
	cQuery +=                                                                             " AND OHT.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("SE1") + " SE1 ON (SE1.E1_PREFIXO = OHH.OHH_PREFIX"
	cQuery +=                                                                             " AND SE1.E1_NUM     = OHH.OHH_NUM"
	cQuery +=                                                                             " AND SE1.E1_PARCELA = OHH.OHH_PARCEL"
	cQuery +=                                                                             " AND SE1.E1_TIPO    = OHH.OHH_TIPO"
	cQuery +=                                                                             " AND SE1.E1_CLIENTE = OHH.OHH_CCLIEN"
	cQuery +=                                                                             " AND SE1.E1_LOJA    = OHH.OHH_CLOJA"
	cQuery +=                                                                             " AND SE1.E1_NATUREZ = OHH.OHH_CNATUR"
	cQuery +=                                                                             " AND SE1.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("NXA") + " NXA ON (NXA.NXA_CESCR  = OHT.OHT_FTESCR"
	cQuery +=                                                                             " AND NXA.NXA_COD    = OHT.OHT_CFATUR"
	cQuery +=                                                                             " AND NXA.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("NS7") + " NS7 ON (NS7.NS7_COD    = OHT.OHT_FTESCR"
	cQuery +=                                                                             " AND NS7.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (SA1.A1_COD     = NXA.NXA_CCLIEN"
	cQuery +=                                                                             " AND SA1.A1_LOJA    = NXA.NXA_CLOJA"
	cQuery +=                                                                             " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("NT0") + " NT0 ON (NT0.NT0_COD    = NXA.NXA_CCONTR"
	cQuery +=                                                                             " AND NT0.NT0_CCLIEN = NXA.NXA_CCLIEN"
	cQuery +=                                                                             " AND NT0.NT0_CLOJA  = NXA.NXA_CLOJA"
	cQuery +=                                                                             " AND NT0.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("SED") + " SED ON (SED.ED_FILIAL  = NS7.NS7_CFILIA"
	cQuery +=                                                                             " AND SED.ED_CODIGO  = OHH.OHH_CNATUR"
	cQuery +=                                                                             " AND SED.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_CODIGO = NXA.NXA_CPART"
	cQuery +=                                                                             " AND RD0.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NXA.NXA_CPART = ?"
	cQuery +=   " AND OHH.OHH_ANOMES = ?"
	cQuery +=   " AND OHH.D_E_L_E_T_ = ' '"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart, cAnoMes }), cAlias, .T., .F. )
	
	If (lTotal)
		oResponse['total'] := (cAlias)->QtdTotal
	Else
		oResponse := {}
		While !( cAlias )->(Eof())
			nIndexJSon++
			Aadd(oResponse, JsonObject():New())
			oResponse[nIndexJSon]['prefixo']            := (cAlias)->E1_PREFIXO
			oResponse[nIndexJSon]['numero']             := (cAlias)->E1_NUM
			oResponse[nIndexJSon]['parcela']            := (cAlias)->E1_PARCELA
			oResponse[nIndexJSon]['tipo']               := (cAlias)->E1_TIPO
			oResponse[nIndexJSon]['codPart']            := (cAlias)->NXA_CPART
			oResponse[nIndexJSon]['siglaPart']          := (cAlias)->RD0_SIGLA
			oResponse[nIndexJSon]['nomePart']           := JConvUTF8((cAlias)->RD0_NOME)
			oResponse[nIndexJSon]['codNatureza']        := (cAlias)->E1_NATUREZ
			oResponse[nIndexJSon]['descNatureza']       := JConvUTF8((cAlias)->ED_DESCRIC)
			oResponse[nIndexJSon]['dataEmissao']        := (cAlias)->E1_EMISSAO
			oResponse[nIndexJSon]['dataVencimento']     := (cAlias)->E1_VENCTO
			oResponse[nIndexJSon]['dataVencimentoReal'] := (cAlias)->E1_VENCREA
			oResponse[nIndexJSon]['valor']              := (cAlias)->E1_VALOR
			oResponse[nIndexJSon]['valorReal']          := (cAlias)->E1_VLRREAL
			oResponse[nIndexJSon]['saldo']              := (cAlias)->OHH_SALDO
			oResponse[nIndexJSon]['historico']          := JConvUTF8((cAlias)->E1_HIST)
			(cAlias)->( dbSkip() )
		End
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fatura
Busca as Faturas pendente do Revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/fatura/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET fatura PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local nIndexJSon := 0
Local cQuery     := ""
Local cAlias     := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal
Local cAnoMes    := AnoMes(Date())

Default lTotal   := .F.

	If lTotal
		cQuery += " SELECT COUNT(1) QtdTotal"
		cQuery += " FROM ( SELECT OHH_CESCR, OHH_CFATUR"
		cQuery +=          " FROM " + RetSqlName("OHH") + " OHH"
		cQuery +=         " INNER JOIN " + RetSqlName("NXA") + " NXA ON (NXA.NXA_CESCR  = OHH.OHH_CESCR"
		cQuery +=                                                  " AND NXA.NXA_COD    = OHH.OHH_CFATUR"
		cQuery +=                                                  " AND NXA.D_E_L_E_T_ = ' ')"
		cQuery +=         " WHERE OHH.D_E_L_E_T_ = ' '"
		cQuery +=           " AND OHH_CFATUR <> ' '"
		cQuery +=           " AND NXA.NXA_CPART = ?"
		cQuery +=           " AND OHH_ANOMES = ?"
		cQuery +=         " GROUP BY OHH.OHH_CFATUR,"
		cQuery +=                  " OHH.OHH_CESCR) FATURAS_PART"
	Else
		cQuery += " SELECT OHH.OHH_CFATUR,"
		cQuery +=        " COUNT(1) QtdTitRec,"
		cQuery +=        " NXA.NXA_DTEMI,"
		cQuery +=        " NXA.NXA_CMOEDA,"
		cQuery +=        " CTO.CTO_DESC,"
		cQuery +=        " NXA.NXA_VLFATH,"
		cQuery +=        " NXA.NXA_VLFATD,"
		cQuery +=        " OHH.OHH_CESCR,"
		cQuery +=        " NS7.NS7_NOME,"
		cQuery +=        " NXA.NXA_CPART,"
		cQuery +=        " RD0.RD0_SIGLA,"
		cQuery +=        " RD0.RD0_NOME,"
		cQuery +=        " SUM(OHH.OHH_SALDO) OHH_SALDO"
		cQuery +=   " FROM " + RetSqlName("OHH") + " OHH"
		cQuery +=  " INNER JOIN " + RetSqlName("NXA") + " NXA ON (NXA.NXA_CESCR  = OHH.OHH_CESCR"
		cQuery +=                                           " AND NXA.NXA_COD    = OHH.OHH_CFATUR"
		cQuery +=                                           " AND NXA.D_E_L_E_T_ = ' ')"
		cQuery +=  " INNER JOIN " + RetSqlName("NS7") + " NS7 ON (NS7.NS7_COD    = NXA.NXA_CESCR"
		cQuery +=                                           " AND NS7.D_E_L_E_T_ = ' ')"
		cQuery +=                                    " INNER JOIN " + RetSqlName("CTO") + " CTO ON (CTO.CTO_MOEDA  = NXA.NXA_CMOEDA"
		cQuery +=                                                                             " AND CTO.CTO_FILIAL = NS7.NS7_CFILIA"
		cQuery +=                                                                             " AND CTO.D_E_L_E_T_ = ' ')"
		cQuery +=                                    " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_CODIGO = NXA.NXA_CPART"
		cQuery +=                                                                             " AND RD0.D_E_L_E_T_ = ' ')"
		cQuery += " WHERE NXA.NXA_CPART = ?"
		cQuery +=   " AND OHH.OHH_ANOMES = ?"
		cQuery +=   " AND OHH.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY OHH.OHH_CESCR, "
		cQuery +=          " OHH.OHH_CFATUR,"
		cQuery +=          " NXA.NXA_DTEMI, "
		cQuery +=          " NXA.NXA_CMOEDA,"
		cQuery +=          " CTO.CTO_DESC,"
		cQuery +=          " NXA.NXA_VLFATH,"
		cQuery +=          " NXA.NXA_VLFATD,"
		cQuery +=          " NS7.NS7_NOME,"
		cQuery +=          " NXA.NXA_CPART,"
		cQuery +=          " RD0.RD0_SIGLA,"
		cQuery +=          " RD0.RD0_NOME"
	EndIf

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart, cAnoMes }), cAlias, .T., .F. )
	
	If (lTotal)
		oResponse['total'] := (cAlias)->QtdTotal
	Else
		oResponse := {}
		While !( cAlias )->(Eof())
			nIndexJSon++
			Aadd(oResponse, JsonObject():New())
			oResponse[nIndexJSon]['codigo']            := (cAlias)->OHH_CFATUR
			oResponse[nIndexJSon]['quantTitulos']      := (cAlias)->QtdTitRec
			oResponse[nIndexJSon]['dataEmissao']       := (cAlias)->NXA_DTEMI
			oResponse[nIndexJSon]['codMoeda']          := (cAlias)->NXA_CMOEDA
			oResponse[nIndexJSon]['descMoeda']         := JConvUTF8((cAlias)->CTO_DESC)
			oResponse[nIndexJSon]['valorHonorario']    := (cAlias)->NXA_VLFATH
			oResponse[nIndexJSon]['valorDespesa']      := (cAlias)->NXA_VLFATD
			oResponse[nIndexJSon]['codEscritorio']     := (cAlias)->OHH_CESCR
			oResponse[nIndexJSon]['nomeEscritorio']    := JConvUTF8((cAlias)->NS7_NOME)
			oResponse[nIndexJSon]['codParticipante']   := (cAlias)->NXA_CPART
			oResponse[nIndexJSon]['siglaParticipante'] := (cAlias)->RD0_SIGLA
			oResponse[nIndexJSon]['nomeParticipante']  := JConvUTF8((cAlias)->RD0_NOME)
			oResponse[nIndexJSon]['saldoFatura']       := (cAlias)->OHH_SALDO
			(cAlias)->( dbSkip() )
		End	
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altRevisor
Realiza a alteração em Lote do Revisor

@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NX0)",
	"campoAlterado: ["revisor", "socio", "multiplo"],
	"participanteDestino": "RD0_CODIGO",
	"multiplos": [
		{
			"id": 0,
			"chave": "X2_UNICO (OHN)",
			"participanteDestino": "RD0_CODIGO"
		},
		{
			"id": 1,
			"chave": "X2_UNICO (OHN)",
			"participanteDestino": "RD0_CODIGO"
		}
	]
}

@author Willian Kazahaya
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altPreFatura PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)
Local cPartOri   := Decode64(Self:codPart) 
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cBody      := Self:GetContent()
Local cPreFatChv := ""
Local cNewRd0Cod := ""
Local nI         := 0
Local lAltRevis  := .F.
Local lAltMltRev := .F.
Local aCmpAltera := {}
Local aBdMultRev := {}
Local oModel     := Nil

	oBody:fromJson(cBody)
	cPreFatChv := Decode64(oBody['chave'])
	aCmpAltera := oBody['campoAlterado']

	lAltRevis  := aScan(aCmpAltera, 'revisor' ) > 0
	lAltMltRev := aScan(aCmpAltera, 'multiplo') > 0

	DbSelectArea("NX0")
	NX0->( DbSetOrder(1) ) // NX0_FILIAL+NX0_COD+NX0_SITUAC

	If NX0->( DbSeek(cPreFatChv) )
		oModel := FWLoadModel("JURA202F")
		oModel:SetOperation(4)
		oModel:Activate()

		If (lAltRevis)
			cNewRd0Cod := oBody['revisor']['codigo']
			If (oModel:GetValue("NX0MASTER", "NX0_CPART") == cPartOri)
				lRet := oModel:SetValue("NX0MASTER","NX0_CPART", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0014) //"Erro na atualização do Participante Revisor!"
			EndIf
		EndIf

		If (lMultRev .And. lAltMltRev)
			aBdMultRev := oBody['multiplos']

			For nI := 1 To Len(aBdMultRev)
				lRet := AltMltRevMdl(oModel:GetModel("OHNDETAIL"), aBdMultRev[nI], cPartOri)

				If !lRet
					Exit
				EndIf
			Next nI
		EndIf

		// Roda os Valids e Commits
		If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
			lRet := JRestError(500, JMdlError(oModel))
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		lRet := JRestError(400, STR0013) //"A pré-fatura não foi localizada. Favor verificar!"
	EndIf
	
	If (lRet)
		oResponse['codigo']  := cPreFatChv
		oResponse['message'] := STR0016    //"Pré-fatura atualizada com sucesso!"
		Self:SetResponse(oResponse:toJson())
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JWSIsAltLote
Retorna se é a Rotina de Alteração em Lote

@author Willian Kazahaya
@since 09/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWSIsAltLote()
Return _JWSAltLote

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altContrato
Realiza a alteração em Lote do sócio responsável do contrato

@param codPart - Código do participante
@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NT0)",
	"campoAlterado: ["socio"],
	"participanteDestino": "RD0_CODIGO",
	"socio": {
		"codigo": "003584"
	}
	"multiplos": []
}

@author Rebeca Facchinato Asunção
@since 18/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altContrato PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local oModel     := Nil
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cPartOri   := Decode64(Self:codPart)
Local cBody      := Self:GetContent()
Local cChave     := ""
Local cNewRd0Cod := ""

	oBody:fromJson(cBody)
	cChave := Decode64(oBody['chave'])

	DbSelectArea("NT0")
	NT0->( DbSetOrder(1) )  // NT0_FILIAL + NT0_COD
	
	If NT0->(DbSeek( cChave ))
		oModel := FWLoadModel("JURA096")
		oModel:SetOperation(4)
		oModel:Activate()

		cNewRd0Cod := oBody['socio']['codigo']
		If !Empty(cNewRd0Cod)
			If (oModel:GetValue("NT0MASTER", "NT0_CPART1") == cPartOri) .AND. !(cNewRd0Cod == cPartOri)
				lRet := oModel:SetValue("NT0MASTER","NT0_CPART1", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0019) // "Erro na atualização do Participante sócio responsável!"
			EndIf

			If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
				lRet := JRestError(500, JMdlError(oModel))
			EndIf

			oModel:DeActivate()
			oModel:Destroy()

		Else
			lRet := JRestError(400, STR0021) // "Participante destino não encontrado!"
		EndIf

	Else
		lRet := JRestError(400, STR0022) // "O contrato não foi localizado. Favor verificar!"
	EndIf

	If (lRet)
		oResponse['codigo']  := cChave
		oResponse['message'] := STR0023    // "Contrato atualizado com sucesso!"
		Self:SetResponse(oResponse:toJson())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET socRevList
Busca a lista de sócios / revisores, de acordo com a entidade selecionada

@param searchKey  - Código da natureza

@author Rebeca Facchinato Asunção
@since 19/05/2023
@version 1.0
http://localhost:12173/rest/WSPFSAltLote/listSociosRev/{entidade}
/*/
//-------------------------------------------------------------------
WSMETHOD GET socRevList PATHPARAM entidade QUERYPARAM searchKey, socioRevisor WSREST WSPFSAltLote

Local cAlias     := GetNextAlias()
Local oResponse  := JSonObject():New()
Local cEntidade  := self:entidade
Local cSearchKey := Self:searchKey
Local cQuery     := ""
Local nI         := 0
Local aDadosQry  := {}
Local aParams    := {}

Default cEntidade  := ""
Default cSearchKey := ""
Default lSocRev    := .F.

	Self:SetContentType("application/json")
	oResponse['items'] := {}

	aDadosQry := aClone(JWSALPart(cSearchKey, cEntidade))
	aParams   := { xFilial("RD0"), xFilial("NUR"), "%" + aDadosQry[2] + "%" }
	cQuery    := aDadosQry[1]
	cQuery    := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )

	While !(cAlias)->(Eof())
		nI++
		aAdd(oResponse['items'], JsonObject():New())
		aTail(oResponse['items'])['codigo']  := (cAlias)->RD0_CODIGO
		aTail(oResponse['items'])['nome']    := JConvUTF8((cAlias)->RD0_NOME)
		aTail(oResponse['items'])['sigla']   := JConvUTF8((cAlias)->RD0_SIGLA)
		aTail(oResponse['items'])['socio']   := (cAlias)->NUR_SOCIO == '1'
		aTail(oResponse['items'])['revisor'] := (cAlias)->NUR_REVFAT == '1'

		If(nI == 10)
			Exit
		EndIf

		(cAlias)->( dbSkip() )
	EndDo

	(cAlias)->( dbCloseArea() )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	aSize(aDadosQry, 0)
	aSize(aParams, 0)
	aDadosQry := Nil
	aParams   := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSALPart
Monta a query de busca de participantes de acordo com o tipo Sócios / Revisores

@param  cTipo      - Tipo de filtro de participantes
@param  searchKey  - valor a ser pesquisado (código / nome / sigla)
@param  lSocRev    - Indica se deve buscar sócios / revisores
@param cEntidade   - Indica a entidade que que busca a lista de participantes
@return Array
		Array[1] - cQuery - Query para busca de participantes
		Array[2] - cSearchKey - Termo utilizado no filtro de busca

@author Rebeca Facchinato Asunção
@since 23/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWSALPart( cSearchKey, cEntidade )
Local cQuery := ""
Local cCampo := "RD0_NOME || RD0_SIGLA || RD0_CODIGO"

Default cTipo      := ""
Default cSearchKey := ""
Default cEntidade  := ""
Default lSocRev    := .F.

	cQuery := " SELECT RD0.RD0_SIGLA"
	cQuery +=       " ,RD0.RD0_CODIGO"
	cQuery +=       " ,RD0.RD0_NOME"
	cQuery +=       " ,RD0.R_E_C_N_O_ RD0RECNO"
	cQuery +=       " ,NUR.NUR_SOCIO"
	cQuery +=       " ,NUR.NUR_REVFAT"
	cQuery +=  " FROM " + RetSqlName("RD0") + " RD0"
	cQuery += " INNER JOIN " + RetSqlName("NUR") + " NUR"
	cQuery +=    " ON (NUR.NUR_CPART = RD0.RD0_CODIGO"
	cQuery +=   " AND NUR.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE RD0.D_E_L_E_T_ = ' '"
	cQuery +=   " AND RD0.RD0_MSBLQL = '2'" // Bloqueado? 2=Não
	cQuery +=   " AND RD0.RD0_TPJUR  = '1'" // Participante jurídico? 1=Sim
	cQuery +=   " AND RD0.RD0_FILIAL = ?"
	cQuery +=   " AND NUR.NUR_FILIAL = ?"

	If !(cEntidade == "All")
		If (cEntidade == "PREFATURAS" .OR. cEntidade == "CASOS")
			cQuery += " AND (NUR.NUR_SOCIO = '1' OR  NUR.NUR_REVFAT = '1')"
		Else  // Contrato, Cliente e Juncao
			cQuery += " AND NUR.NUR_SOCIO = '1'"
		EndIf
	EndIf

	If !Empty(cSearchKey)
		If ValType(DecodeUTF8(cSearchKey)) <> "U"
			cSearchKey := DecodeUTF8(cSearchKey)
		EndIf

		cSearchKey := JurClearStr(cSearchKey, .T., .T.,.F., .T.)
		cCampo     := JurClearStr("RD0_NOME || RD0_SIGLA || RD0_CODIGO", .T., .T. , .T., .T.)
		cQuery     += " AND " + cCampo + " LIKE ?"
	EndIf
	cQuery += " ORDER BY RD0.RD0_NOME"
Return { cQuery, cSearchKey }

//-------------------------------------------------------------------
/*/{Protheus.doc} JMdlError(oModel)
Centraliza o retorno dos erros de Modelo

@param  oModel - Modelo que deu erro
@return cMsgError - Mensagem de erro

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JMdlError(oModel)
Local cMsgError := ""
	cMsgError := STR0024 + CRLF  // "Erro: "

	If !Empty(oModel:aErrorMessage[4])
		cMsgError += STR0025 + oModel:aErrorMessage[4] + CRLF  // "Campo: "
	EndIf

	If !Empty(oModel:aErrorMessage[5])
		cMsgError += STR0026 + oModel:aErrorMessage[5] + CRLF  // "Razao: "
	EndIf

	cMsgError += oModel:aErrorMessage[6] + CRLF   // Mensagem
Return cMsgError

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altJuncoes
Realiza a alteração em Lote do sócio responsável da junção de contratos

@param codPart - Código do participante
@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/revisor/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NW2)",
	"campoAlterado: ["socio"],
	"participanteDestino": "RD0_CODIGO",
	"socio": {
		"codigo": "003584"
	}
	"multiplos": []
}

@author Rebeca Facchinato Asunção
@since 31/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altJuncoes PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local oModel     := Nil
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cPartOri   := Decode64(Self:codPart)
Local cBody      := Self:GetContent()
Local cChave     := ""
Local cNewRd0Cod := ""

	oBody:fromJson(cBody)
	cChave := Decode64(oBody['chave'])

	DbSelectArea("NW2")
	NW2->( DbSetOrder(1) )  // NW2_FILIAL + NW2_COD
	
	If NW2->(DbSeek( cChave ))
		oModel := FWLoadModel("JURA056")
		oModel:SetOperation(4)
		oModel:Activate()

		cNewRd0Cod := oBody['socio']['codigo']
		If !Empty(cNewRd0Cod)
			If (oModel:GetValue("NW2MASTER", "NW2_CPART") == cPartOri) .AND. !(cNewRd0Cod == cPartOri)
				lRet := oModel:SetValue("NW2MASTER","NW2_CPART", cNewRd0Cod)
				lRet := lRet .AND. oModel:SetValue("NW2MASTER","NW2_SIGLA", oBody['socio']['sigla'])
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0019) // "Erro na atualização do Participante sócio responsável!"
			EndIf

			If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
				lRet := JRestError(500, JMdlError(oModel))
			EndIf

			oModel:DeActivate()
			oModel:Destroy()

		Else
			lRet := JRestError(400, STR0021) // "Participante destino não encontrado!"
		EndIf

	Else
		lRet := JRestError(400, STR0028) // "A junção de contratos não foi localizada. Favor verificar!"
	EndIf

	If (lRet)
		oResponse['codigo']  := cChave
		oResponse['message'] := STR0029    // "Junção de contratos atualizada com sucesso!"
		Self:SetResponse(oResponse:toJson())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cQryMltPart(cEntida)
Gera a query dos Multiplos participantes

@param  cEntida - Entidade da query
@return cQuery  - Query a ser rodada

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function cQryMltPart(cEntida)
Local cQuery  := ""

	cQuery += "  SELECT RD0MULTI.RD0_NOME"
	cQuery +=        " ,RD0MULTI.RD0_CODIGO"
	cQuery +=        " ,RD0MULTI.RD0_SIGLA"
	cQuery +=        " ,OHN.OHN_FILIAL"
	cQuery +=        " ,OHN.OHN_CPREFT"
	cQuery +=        " ,OHN.OHN_CCONTR"
	cQuery +=        " ,OHN.OHN_CCLIEN"
	cQuery +=        " ,OHN.OHN_CLOJA"
	cQuery +=        " ,OHN.OHN_CCASO"
	cQuery +=        " ,OHN.OHN_CPART"
	cQuery +=        " ,OHN.OHN_REVISA"
	cQuery +=   " FROM " + RetSqlName( "OHN" ) + " OHN"
	cQuery +=  " INNER JOIN " + RetSqlName( "RD0" ) + " RD0MULTI"
	cQuery +=     " ON OHN.OHN_CPART = RD0MULTI.RD0_CODIGO"
	cQuery +=  " WHERE OHN.D_E_L_E_T_ = ' '"

	If (cEntida == "PREFATURA")
		cQuery +=    " AND OHN.OHN_CPREFT = ?"
	ElseIf (cEntida == "CASO")
		cQuery +=    " AND OHN.OHN_CPREFT = ' '"
		cQuery +=    " AND OHN.OHN_CCLIEN = ?"
		cQuery +=    " AND OHN.OHN_CLOJA = ?"
		cQuery +=    " AND OHN.OHN_CCASO = ?"
	EndIf
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} cQryMltPart(cEntida)
Gera a query dos Multiplos participantes

@param  cEntida - Entidade da query
@return cQuery  - Query a ser rodada

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altCaso PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .T.
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)
Local cPartOri   := Decode64(Self:codPart)
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cBody      := Self:GetContent()
Local cChvCaso   := ""
Local cNewRd0Cod := ""
Local nI         := 0
Local lAltRevis  := .F.
Local lAltMltRev := .F.
Local lAltSocio  := .F.
Local aCmpAltera := {}
Local oModel     := Nil

	oBody:fromJson(cBody)
	cChvCaso   := Decode64(oBody['chave'])
	aCmpAltera := oBody['campoAlterado']

	lAltRevis  := aScan(aCmpAltera, 'revisor' ) > 0
	lAltSocio  := aScan(aCmpAltera, 'socio'   ) > 0
	lAltMltRev := aScan(aCmpAltera, 'multiplo') > 0

	DbSelectArea("NVE")
	NVE->( DbSetOrder(1) )  // NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS + NVE_SITUAC

	If NVE->( DbSeek(cChvCaso) )
		oModel := FWLoadModel("JURA070")
		oModel:SetOperation(4)
		oModel:Activate()

		If lAltSocio
			cNewRd0Cod := oBody['socio']['codigo']
			If (oModel:GetValue("NVEMASTER", "NVE_CPART5") == cPartOri)
				lRet := oModel:SetValue("NVEMASTER","NVE_CPART5", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0031) //"Erro na atualização do Participante Sócio!"
			EndIf
		EndIf

		If lRet .AND. lAltRevis
			cNewRd0Cod := oBody['revisor']['codigo']
			If (oModel:GetValue("NVEMASTER", "NVE_CPART1") == cPartOri)
				lRet := oModel:SetValue("NVEMASTER","NVE_CPART1", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0014) //"Erro na atualização do Participante Revisor!"
			EndIf
		EndIf

		If lRet .AND. (lMultRev .And. lAltMltRev)
			aBdMultRev := oBody['multiplos']

			For nI := 1 To Len(aBdMultRev)
				lRet := AltMltRevMdl(oModel:GetModel("OHNDETAIL"), aBdMultRev[nI], cPartOri)

				If !lRet
					Exit
				EndIf
			Next nI
		EndIf
		
		// Roda os Valids e Commits
		If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
			lRet := JRestError(500, JMdlError(oModel))
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		lRet := JRestError(400, STR0032) //"O caso não foi localizado. Favor verificar!"
	EndIf

	If (lRet)
		oResponse['codigo']  := cChvCaso
		oResponse['message'] := STR0033 // "Caso atualizado com sucesso!"
		Self:SetResponse(oResponse:toJson())
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AltMltRevMdl(oModelOHN, oItemRev, cPartOri)
Gera a query dos Multiplos participantes

@param oModelOHN - Modelo do grid de múltiplos
@param oItemRev  - Linha posicionada do grid de múltiplos
@param cPartOri  - Partipante origem
@return lRet     - 	Indica se atualizou os múltiplos com sucesso!

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AltMltRevMdl(oModelOHN, oItemRev, cPartOri)
Local lRet       := .T.
Local nIndLoc    := 0
Local nX         := 0
Local cChvMdlOHN := ""

	// Somente procura quando houve atualização ou exclusão
	If (oItemRev['deleted'] .Or. oItemRev['updated'] ) 
		For nX := 1 To oModelOHN:Length()
			cChvMdlOHN := oModelOHN:GetValue("OHN_FILIAL",nX) + ;
							oModelOHN:GetValue("OHN_CPREFT",nX) + ;
							oModelOHN:GetValue("OHN_CCONTR",nX) + ;
							oModelOHN:GetValue("OHN_CCLIEN",nX) + ;
							oModelOHN:GetValue("OHN_CLOJA",nX)  + ;
							oModelOHN:GetValue("OHN_CCASO",nX)  + ;
							oModelOHN:GetValue("OHN_CPART",nX)  + ;
							oModelOHN:GetValue("OHN_REVISA",nX)

			// Verifica se a chave foi bate com a chave do JSON
			If (Decode64(oItemRev['chave']) == cChvMdlOHN)
				nIndLoc := nX
				Exit
			EndIf
		Next nX

		// OHN_FILIAL + OHN_CPREFT + OHN_CCONTR + OHN_CCLIEN + OHN_CLOJA + OHN_CCASO + OHN_CPART + OHN_REVISA
		If nIndLoc > 0
			oModelOHN:GoLine(nIndLoc)
			If (oItemRev['deleted'])
				lRet := oModelOHN:DeleteLine()
			ElseIf (oItemRev['updated'])
				If (cPartOri == oModelOHN:GetValue("OHN_CPART",nIndLoc))
					lRet := oModelOHN:SetValue("OHN_CPART", oItemRev['participante'])
				EndIf
			EndIf

			If !(lRet)
				lRet := JRestError(500, STR0015) //"Erro na atualização do Responsável Multiplo!"
			EndIf
		EndIf
	EndIf
Return lRet

