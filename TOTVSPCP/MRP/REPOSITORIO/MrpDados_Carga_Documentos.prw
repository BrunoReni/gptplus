#INCLUDE "TOTVS.CH"
#INCLUDE 'MrpDados.ch'

#DEFINE MAT_FILIAL   1
#DEFINE MAT_DATA     2
#DEFINE MAT_PRODUT   3
#DEFINE MAT_SLDINI   4
#DEFINE MAT_ENTPRE   5
#DEFINE MAT_SAIPRE   6
#DEFINE MAT_SAIEST   7
#DEFINE MAT_SALDO    8
#DEFINE MAT_NECESS   9
#DEFINE MAT_TPREPO  10
#DEFINE MAT_EXPLOD  11
#DEFINE MAT_THREAD  12
#DEFINE MAT_IDOPC   13
#DEFINE MAT_DTINI   14
#DEFINE MAT_QTRENT  15
#DEFINE MAT_QTRSAI  16
#DEFINE TAM_MAT     16

#DEFINE ARRAY_OP_POS_INDOPC     1
#DEFINE ARRAY_OP_POS_QTDOPC     2
#DEFINE ARRAY_OP_POS_IDREG      3
#DEFINE ARRAY_OP_POS_FILIAL     4
#DEFINE ARRAY_OP_POS_PROD       5
#DEFINE ARRAY_OP_POS_DATA       6
#DEFINE ARRAY_OP_POS_PATH       7
#DEFINE ARRAY_OP_POS_SALDO      8
#DEFINE ARRAY_OP_POS_OP         9
#DEFINE ARRAY_OP_POS_MOPC      10
#DEFINE ARRAY_OP_POS_RECNO     11
#DEFINE ARRAY_OP_TAMAN         11

#DEFINE ARRAY_OPC_EMP_INDOPC    1
#DEFINE ARRAY_OPC_EMP_QTDOPC    2
#DEFINE ARRAY_OPC_EMP_CHAVEEMP  3
#DEFINE ARRAY_OPC_EMP_FILIAL    4
#DEFINE ARRAY_OPC_EMP_PRODEMP   5
#DEFINE ARRAY_OPC_EMP_RECNOOP   6
#DEFINE ARRAY_OPC_EMP_RECNOORG  7
#DEFINE ARRAY_OPC_EMP_MOPC      8
#DEFINE ARRAY_OPC_EMP_PATHOP    9
#DEFINE ARRAY_OPC_EMP_OPORIG   10
#DEFINE ARRAY_OPC_EMP_DT       11
#DEFINE ARRAY_OPC_EMP_PRODOP   12
#DEFINE ARRAY_OPC_EMP_OP       13
#DEFINE ARRAY_OPC_EMP_SEQ      14
#DEFINE ARRAY_OPC_EMP_SAIDPRE  15
#DEFINE ARRAY_OPC_EMP_TAMAN    15

#DEFINE ARRAY_OPC_DEM_INDOPC   1
#DEFINE ARRAY_OPC_DEM_QTDOPC   2
#DEFINE ARRAY_OPC_DEM_IDREG    3
#DEFINE ARRAY_OPC_DEM_FILIAL   4
#DEFINE ARRAY_OPC_DEM_PROD     5
#DEFINE ARRAY_OPC_DEM_MOPC     6
#DEFINE ARRAY_OPC_DEM_RECNO    7
#DEFINE ARRAY_OPC_DEM_QUANT    8
#DEFINE ARRAY_OPC_DEM_ORIG     9
#DEFINE ARRAY_OPC_DEM_DATA    10
#DEFINE ARRAY_OPC_HWE_MOPC    11
#DEFINE ARRAY_OPC_HWE_RECNO   12
#DEFINE ARRAY_OPC_HWA_MOPC    13
#DEFINE ARRAY_OPC_HWA_RECNO   14
#DEFINE ARRAY_OPC_DEM_TAMAN   14

#DEFINE ARRAY_CARGA_EMP_FILIAL   1
#DEFINE ARRAY_CARGA_EMP_PRODEMP  2
#DEFINE ARRAY_CARGA_EMP_CHAVEEMP 3
#DEFINE ARRAY_CARGA_EMP_SEQ      4
#DEFINE ARRAY_CARGA_EMP_DT       5
#DEFINE ARRAY_CARGA_EMP_OP       6
#DEFINE ARRAY_CARGA_EMP_PRODOP   7
#DEFINE ARRAY_CARGA_EMP_OPORIG   8
#DEFINE ARRAY_CARGA_EMP_QUANT    9
#DEFINE ARRAY_CARGA_EMP_OPC      10
#DEFINE ARRAY_CARGA_EMP_SIZE     10

/*/{Protheus.doc} MrpDados_Carga_Documentos
Classe para carregar os dados em memoria

@author marcelo.neumann
@since 08/07/2019
@version 1
/*/
CLASS MrpDados_Carga_Documentos FROM LongNameClass

	DATA lDem_Ok   AS LOGICAL
	DATA lEmp_Ok   AS LOGICAL
	DATA lOPs_Ok   AS LOGICAL
	DATA lPCs_Ok   AS LOGICAL
	DATA lSCs_Ok   AS LOGICAL
	DATA oCarga    AS OBJECT
	DATA oCacheOpc AS OBJECT

	METHOD new() CONSTRUCTOR

	METHOD cargaDocsComOpcional()
	METHOD cargaFinalizada()
	METHOD getPerCarInicial(oDados)
	METHOD getPerCarga(oDados)

	METHOD demandas()
	METHOD entradasEmpenho()
	METHOD entradasOP()
	METHOD entradasPC()
	METHOD entradasSC()

	METHOD adicionaListaOpcional(aDados, cNivel)
	METHOD gravaListaOpcionalGlobal(oLogs)
	METHOD getNaoCarregados(aDados)
	METHOD limpaListaOpcional(cDoc)
	METHOD montaQueryDemandas(oDominio,cTicket,lFilReser)
	METHOD reservaDemandasProcessamento(cTicket)
	METHOD retornaQtdOpcionais(cMOpc)

	METHOD whereT4Q(oDominio, lHorFirme, lValidMRP, lUsaExists, lDatLimite, lFiltraOP, cTabFil, cColFil)

ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe MrpDados_Carga_Documentos

@author marcelo.neumann
@since 08/07/2019
@version 1
@param oCarga, objeto, instância da classe principal MrpDados_CargaMemoria
@return Self , objeto, instância do objeto MrpDados_Carga_Documentos criado
/*/
METHOD new(oCarga) CLASS MrpDados_Carga_Documentos

	Self:oCarga    := oCarga
	Self:lDem_Ok   := .F.
	Self:lEmp_Ok   := .F.
	Self:lOPs_Ok   := .F.
	Self:lPCs_Ok   := .F.
	Self:lSCs_Ok   := .F.
	Self:oCacheOpc := JsonObject():New()

Return Self

/*/{Protheus.doc} getPerCarInicial
Retorna a quantidade de registros que serão carregados na carga inicial

@author marcelo.neumann
@since 19/04/2021
@version 1
@param oDados   , objeto  , intância do objeto de Dados
@return nPercent, numérico, percentual da carga
/*/
METHOD getPerCarInicial(oDados) CLASS MrpDados_Carga_Documentos

	//Método mantido para não ser necerrária a alteração do MrpDados_CargaMemoria.prw caso necessite incluir alguma carga nova

Return 100

/*/{Protheus.doc} getPerCarga
Retorna a quantidade de registros que serão carregados na carga

@author marcelo.neumann
@since 19/04/2021
@version 1
@param oDados   , objeto  , intância do objeto de Dados
@return nPercent, numérico, percentual da carga
/*/
METHOD getPerCarga(oDados) CLASS MrpDados_Carga_Documentos
	Local nLidos   := 0
	Local nPercent := 0
	Local nQuant   := 0
	Local nTotal   := 0

	nQuant := oDados:oMatriz:getflag("qtd_registros_total_empenhos")
	If nQuant <> Nil
		nTotal += nQuant

		nQuant := oDados:oMatriz:getflag("qtd_registros_lidos_empenhos")
		If nQuant <> Nil
			nLidos += nQuant
		EndIf

		If nTotal == 0
			nPercent += 30
		Else
			nPercent += ((nLidos * 100) / nTotal) * 0.3
		EndIf
	EndIf

	nTotal := 0
	nLidos := 0
	nQuant := oDados:oMatriz:getflag("qtd_registros_total_demandas")
	If nQuant <> Nil
		nTotal += nQuant

		nQuant := oDados:oMatriz:getflag("qtd_registros_lidos_demandas")
		If nQuant <> Nil
			nLidos += nQuant
		EndIf

		If nTotal == 0
			nPercent += 30
		Else
			nPercent += ((nLidos * 100) / nTotal) * 0.3
		EndIf
	EndIf

	nTotal := 0
	nLidos := 0
	nQuant := oDados:oMatriz:getflag("qtd_registros_total_ops")
	If nQuant <> Nil
		nTotal += nQuant

		nQuant := oDados:oMatriz:getflag("qtd_registros_lidos_ops")
		If nQuant <> Nil
			nLidos += nQuant
		EndIf

		If nTotal == 0
			nPercent += 20
		Else
			nPercent += ((nLidos * 100) / nTotal) * 0.2
		EndIf
	EndIf

	nTotal := 0
	nLidos := 0
	nQuant := oDados:oMatriz:getflag("qtd_registros_total_pedidos")
	If nQuant <> Nil
		nTotal += nQuant

		nQuant := oDados:oMatriz:getflag("qtd_registros_total_scs")
		If nQuant <> Nil
			nTotal += nQuant

			nQuant := oDados:oMatriz:getflag("qtd_registros_lidos_pedidos")
			If nQuant <> Nil
				nLidos += nQuant
			EndIf

			nQuant := oDados:oMatriz:getflag("qtd_registros_lidos_scs")
			If nQuant <> Nil
				nLidos += nQuant
			EndIf

			If nTotal == 0
				nPercent += 20
			Else
				nPercent += ((nLidos * 100) / nTotal) * 0.2
			EndIf
		EndIf
	EndIf

Return nPercent

/*/{Protheus.doc} cargaFinalizada
Indica se toda a carga dos dados dos Documentos foi finalizada

@author marcelo.neumann
@since 15/04/2021
@version 1
@return lRet, lógico, indica se a carga foi finalizada
/*/
METHOD cargaFinalizada() CLASS MrpDados_Carga_Documentos
	Local lError := .F.

	If !Self:lEmp_Ok
		If Self:oCarga:oDados:oMatriz:getFlag("termino_carga_Emp", @lError) == "S"
			Self:lEmp_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lOPs_Ok
		If Self:oCarga:oDados:oMatriz:getFlag("termino_carga_OP", @lError) == "S"
			Self:lOPs_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lPCs_Ok
		If Self:oCarga:oDados:oMatriz:getFlag("termino_carga_PC", @lError) == "S"
			Self:lPCs_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lSCs_Ok
		If Self:oCarga:oDados:oMatriz:getFlag("termino_carga_SC", @lError) == "S"
			Self:lSCs_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

	If !Self:lDem_Ok
		If Self:oCarga:oDados:oMatriz:getFlag("termino_carga_DEM", @lError) == "S"
			Self:lDem_Ok := .T.
		Else
			Return .F.
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} reservaDemandasProcessamento
Reserva as demandas que serão processadas pelo MRP atualizando o campo T4J_PROC para 3

@author ricardo.prandi
@since 23/11/2021
@version 1.0
@param cTicket , caracter, número do ticket para processamento do MRP
@return lOk    , logic   , indica se foi possível realizar a reserva
/*/
METHOD reservaDemandasProcessamento(cTicket) CLASS MrpDados_Carga_Documentos

	Local aQuery     := {}
	Local cWhere     := ""
	Local lOk        := .T.
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oCargaDocs := MrpDados_Carga_Documentos():New()

	aQuery := oCargaDocs:montaQueryDemandas(oDominio,cTicket,.F.)

	cWhere := " R_E_C_N_O_ IN (SELECT T4J.R_E_C_N_O_ FROM " + aQuery[2] + " ) "

	lOk := oCarga:atualizaRegistrosNoBanco("T4J", "T4J_PROC = '3'", cWhere)

	aSize(aQuery, 0)
	aQuery := Nil

Return lOk

/*/{Protheus.doc} montaQueryDemandas
Monta a query de demandas utilizada para a carga e a reserva

@author ricardo.prandi
@since 23/11/2021
@version 1.0
@param 01 oDominio , object  , instância do objeto MrpDominio
@param 02 cTicket  , caracter, número do ticket para processamento do MRP
@param 03 lFilReser, logic   , indica se irá filtrar apenas as demandas já reservadas para o MRP (T4J_PROC = '3')
@return aReturn, array   , array contendo o select completo.
                           Posição 01 - Fields
						   Posição 02 - FROM e WHERE
						   Posição 03 - ORDER BY
/*/
METHOD montaQueryDemandas(oDominio,cTicket,lFilReser) CLASS MrpDados_Carga_Documentos
	Local aReturn    := {}
	Local aRetPE     := {}
	Local cFields    := ""
	Local cOrder     := ""
	Local cQueryCon  := ""
	Local dFimDemand := Nil
	Local dIniDemand := Nil
	Local lT4JCODE   := !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO"))
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lUsaME     := .F.
	Local oCarga     := Nil
	Local oMultiEmp  := Nil

	oCarga     := oDominio:oDados:oCargaMemoria
	oMultiEmp  := oDominio:oMultiEmp

	//Monta os campos da clausula SELECT
	cFields := " T4J.T4J_PROD, "
	cFields += " T4J.T4J_DATA, "
	cFields += " T4J.T4J_QUANT, "
	cFields += " T4J.T4J_ORIGEM, "
	cFields += " T4J.T4J_IDREG, "
	cFields += " T4J.R_E_C_N_O_, "
	cFields += " T4J.T4J_LOCAL "

	If lT4JCODE
		cFields += " , T4J.T4J_CODE "
	EndIf

	lUsaME := oMultiEmp:utilizaMultiEmpresa()
	If lUsaME
		cFields += " , T4J.T4J_FILIAL, COALESCE(SMB.MB_NIVEL, '99') AS PRODNIVEL"
	Else
		cFields += " , HWA.HWA_NIVEL AS PRODNIVEL"
	EndIf

	cFields += " , HWA.R_E_C_N_O_ AS RECNOHWA"

	If oDominio:oParametros["lUsesProductIndicator"]
		cFields += " , HWE.R_E_C_N_O_ AS RECNOHWE"
		cFields += " , HWE.HWE_MOPC "
	EndIf

	cFields += " , HWA.HWA_MOPC "
	cFields += " , T4J.T4J_MOPC "

	dIniDemand := oDominio:oParametros["dInicioDemandas"]
	dFimDemand := oDominio:oParametros["dFimDemandas"]

	//Corrige data fim demandas superior ao último periodo
	If dFimDemand > oDominio:oPeriodos:ultimaDataDoMRP()
		If oDominio:oParametros["lEventLog"]
			dLimite    := oDominio:oPeriodos:ultimaDataDoMRP()
		Else
			dFimDemand := oDominio:oPeriodos:ultimaDataDoMRP()
		EndIf
	EndIf

	//Carrega o FROM e WHERE clause
	cQueryCon := RetSqlName("T4J") + " T4J "
	cQueryCon += oCarga:montaJoinHWA("T4J.T4J_PROD", cTicket, .F., "T4J.T4J_FILIAL", "T4J", oMultiEmp, .T.)

	cQueryCon += " WHERE "

	cQueryCon += " T4J_DATA >= '" + DtoS(dIniDemand) + "'"

	If dFimDemand != Nil
		cQueryCon += " AND T4J_DATA <= '" + DtoS(dFimDemand) + "'"
	EndIf

	If lUsaME
		cQueryCon += " AND " + oMultiEmp:queryFilial("T4J", "T4J_FILIAL", .F.)
	Else
		cQueryCon += " AND T4J_FILIAL = '" + xFilial("T4J") + "' "
	EndIf

	If lFilReser
		cQueryCon += " AND T4J_PROC = '3' "
	Else
		//Parâmetro para considerar ou não as demandas já processadas
		If oDominio:oParametros["lDemandsProcessed"]
			cQueryCon += " AND (T4J_PROC = '2' OR T4J_PROC = '1') "
		Else
			cQueryCon += " AND (T4J_PROC = '2') "
		EndIf
	EndIf

	//Parâmetro para filtrar os documentos
	If !Empty(oDominio:oParametros["cDocuments"])
		cQueryCon += " AND " + oDominio:oSeletivos:scriptInSQL("T4J_DOC", "cDocuments", "T4J_FILIAL")
	EndIf

	//Parâmetro para filtrar os códigos de demandas
	If lT4JCODE .AND. !Empty(oDominio:oParametros["cDemandCodes"])
		cQueryCon += " AND " + oDominio:oSeletivos:scriptInSQL("T4J_CODE", "cDemandCodes", "T4J_FILIAL")
	EndIf

	//Valida o filtro de Tipo ou Grupo de Produtos
	cQueryCon += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4J_PROD",.F.,.T.,.F.)

	//Parâmetro de seleção dos tipos de demandas a serem processadas
	cQueryCon += " AND ( 1 != 1 "
	If !Empty(oDominio:oParametros["cDemandType"])
		If "1" $ oDominio:oParametros["cDemandType"]
			cQueryCon += " OR T4J_ORIGEM = '3' "
		EndIf

		If "2" $ oDominio:oParametros["cDemandType"]
			cQueryCon += " OR T4J_ORIGEM = '2' "
		EndIf

		If "3" $ oDominio:oParametros["cDemandType"]
			cQueryCon += " OR T4J_ORIGEM = '1' "
		EndIf

		If "4" $ oDominio:oParametros["cDemandType"]
			cQueryCon += " OR T4J_ORIGEM = '4' "
		EndIf

		If "9" $ oDominio:oParametros["cDemandType"]
			cQueryCon += " OR T4J_ORIGEM = '9' "
		EndIf
	EndIf

	cQueryCon += " ) "

	cQueryCon += " AND ( "

	cQueryCon += " ("
	If !Empty(oDominio:oParametros["cWarehouses"])
		cQueryCon += oDominio:oSeletivos:scriptInSQL("T4J.T4J_LOCAL", "cWarehouses")
		cQueryCon += " AND "
	EndIf
	cQueryCon += " EXISTS ( " + condLocal("T4J", "T4J.T4J_LOCAL", "T4J.T4J_FILIAL", oMultiEmp) + " ) "
	cQueryCon += " ) OR T4J.T4J_LOCAL = ' ' "

	cQueryCon += " ) "

	//Monta Order By
	cOrder := " T4J.T4J_FILIAL, T4J.T4J_PROD, T4J.T4J_DATA "

	If lP712SQL
		aRetPE := ExecBlock("P712SQL", .F., .F., {"T4J",cFields,cQueryCon,cOrder})

		If aRetPE != Nil .And. Len(aRetPE) == 3
			cFields   := aRetPE[1]
			cQueryCon := aRetPE[2]
			cOrder    := aRetPE[3]
		EndIf
	EndIf

	aReturn := {cFields,cQueryCon,cOrder}
	aSize(aRetPE, 0)
	aRetPE := Nil

Return aReturn

/*/{Protheus.doc} demandas
Carrega os dados das Demandas

@author marcelo.neumann
@since 31/03/2021
@version 1.0
/*/
METHOD demandas() CLASS MrpDados_Carga_Documentos

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargDem", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargDem(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargDem
Processa a carga dos dados dos Demandas

@author marcelo.neumann
@since 11/07/2019
@version 1.0
@param cTicket, caracter, número do ticket para processamento do MRP
/*/
Function MrpCargDem(cTicket)
	Local aDadosDem  := {}
	Local cAliasQry  := ""
	Local cChaveProd := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := ""
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local dFimDemand := Nil
	Local dLimite    := Nil
	Local dOriginal  := Nil
	Local lTemOpc    := .F.
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oMatriz    := Nil
	Local oMultiEmp  := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oCargaDocs := MrpDados_Carga_Documentos():New(oCarga)
	oMatriz    := oDominio:oDados:oMatriz
	oLogs      := oDominio:oDados:oLogs
	oMultiEmp  := oDominio:oMultiEmp
	oStatus    := MrpDados_Status():New(cTicket)
	lUsaME     := oMultiEmp:utilizaMultiEmpresa()

	If oStatus:preparaAmbiente()
		oDominio:oAglutina:aguardaCargaEstrutura()

		dFimDemand := oDominio:oParametros["dFimDemandas"]

		//Corrige data fim demandas superior ao último periodo
		If dFimDemand > oDominio:oPeriodos:ultimaDataDoMRP()
			If oDominio:oParametros["lEventLog"]
				dLimite    := oDominio:oPeriodos:ultimaDataDoMRP()
			Else
				dFimDemand := oDominio:oPeriodos:ultimaDataDoMRP()
			EndIf
		EndIf

		aQuery := oCargaDocs:montaQueryDemandas(oDominio,cTicket,.T.)

		cFields := "% " + oCarga:trataOptimizerOracle() + " " +  aQuery[1] + "%"

		cQueryCon := "%" + aQuery[2] + "%"
		cOrder    := "%" + aQuery[3] + "%"

		If oCarga:aguardaCalculoNiveis(oStatus)
		    
			CFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(1) TOTAL%" 
	
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT %Exp:cFieldCnt%
				FROM %Exp:cQueryCon%
			EndSql
			If (cAliasQry)->(!Eof())
				nTotal := (cAliasQry)->TOTAL
			EndIf
			(cAliasQry)->(dbCloseArea())
		Else
			oMatriz:setFlag("termino_carga_DEM", "S")
		EndIf
	EndIf

	oMatriz:setFlag("qtd_registros_total_demandas", nTotal, , , .T.)
	oMatriz:setFlag("qtd_registros_lidos_demandas", 0     , , , .T.)

	If nTotal > 0
		BeginSql Alias cAliasQry
			COLUMN T4J_DATA AS DATE
			SELECT %Exp:cFields%
		  	FROM %Exp:cQueryCon%
		 	ORDER BY %Exp:cOrder%
		EndSql

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			aDadosDem := Array(ARRAY_OPC_DEM_TAMAN)
			nIndRegs++

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oMatriz:setFlag("termino_carga_DEM", "S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->T4J_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			dOriginal := (cAliasQry)->T4J_DATA
			cProduto  := PadR((cAliasQry)->T4J_PROD, oCarga:nTamCod)

			If oDominio:oParametros["lEventLog"]
				//Loga Evento 005 - Data de necessidade invalida - Data posterior ao prazo maximo do MRP
				If dLimite != Nil .AND. dOriginal > dLimite
					oDominio:oEventos:loga("005", cProduto, dOriginal, {cProduto, (cAliasQry)->T4J_QUANT, dOriginal, "T4J", (cAliasQry)->T4J_IDREG}, cFilAux)
					(cAliasQry)->(dbSkip())
					Loop
				//Gera Evento 004 - Data de necessidade invalida - Data anterior a database (Novas necessidades do MRP com data anterior a base do sistema)
				ElseIf dOriginal < oDominio:oParametros["dDataIni"]
					oDominio:oEventos:loga("004", cProduto, dOriginal,;
										   {"", (cAliasQry)->T4J_QUANT, dOriginal,;
										   (cAliasQry)->T4J_IDREG,;
										   "",;
										   "T4J", ""},;
										   cFilAux)
				EndIf
			EndIf

			aDadosDem[ARRAY_OPC_DEM_FILIAL] := cFilAux
			aDadosDem[ARRAY_OPC_DEM_PROD  ] := cProduto
			aDadosDem[ARRAY_OPC_DEM_MOPC  ] := (cAliasQry)->T4J_MOPC
			aDadosDem[ARRAY_OPC_DEM_RECNO ] := (cAliasQry)->R_E_C_N_O_
			aDadosDem[ARRAY_OPC_DEM_QUANT ] := (cAliasQry)->T4J_QUANT
			aDadosDem[ARRAY_OPC_DEM_ORIG  ] := (cAliasQry)->T4J_ORIGEM
			aDadosDem[ARRAY_OPC_DEM_IDREG ] := (cAliasQry)->T4J_IDREG
			aDadosDem[ARRAY_OPC_DEM_DATA  ] := dOriginal
			aDadosDem[ARRAY_OPC_HWA_MOPC  ] := (cAliasQry)->HWA_MOPC
			aDadosDem[ARRAY_OPC_HWA_RECNO ] := (cAliasQry)->RECNOHWA

			If oDominio:oParametros["lUsesProductIndicator"]
				aDadosDem[ARRAY_OPC_HWE_MOPC  ] := (cAliasQry)->HWE_MOPC
				aDadosDem[ARRAY_OPC_HWE_RECNO ] := (cAliasQry)->RECNOHWE
			Else
				aDadosDem[ARRAY_OPC_HWE_MOPC  ] := Nil
				aDadosDem[ARRAY_OPC_HWE_RECNO ] := Nil
			EndIf

			//Se possui Opcional, a carga deve ser somente ao final
			If (cAliasQry)->T4J_MOPC != NIL .AND. !Empty((cAliasQry)->T4J_MOPC)
				aDadosDem[ARRAY_OPC_DEM_INDOPC] := "DEM"
				aDadosDem[ARRAY_OPC_DEM_QTDOPC] := oCargaDocs:retornaQtdOpcionais((cAliasQry)->T4J_MOPC)

				If aDadosDem[ARRAY_OPC_DEM_QTDOPC] <> "0"
					cChaveProd := cFilAux + cProduto
					oCargaDocs:adicionaListaOpcional(aDadosDem, (cAliasQry)->PRODNIVEL)
					lTemOpc := .T.

					aSize(aDadosDem, 0)
					(cAliasQry)->(dbSkip())
					Loop
				EndIf
			EndIf

			If !cargaDem(aDadosDem, oDominio)
				oLogs:log(STR0055 + "T4J", "E") //"Erro na carga de dados da tabela para memoria: "
			EndIf

			aSize(aDadosDem, 0)
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Registra dados de opcionais na memória global.
	oCargaDocs:gravaListaOpcionalGlobal(oLogs)

	//Registra documentos (SMV) na memória global
	oCarga:registraDocumentos("T4J")

	oLogs:log("Tempo de carga de Demandas (Sem Opcional): "           + cValToChar(MicroSeconds() - nTempoIni)            , "CM")
	oLogs:log("Quantidade de Demandas carregadas em memoria: "        + cValToChar(nIndRegs) + " de " + cValToChar(nTotal), "CM")
	oLogs:log("Quantidade de itens da matriz carregados em memoria: " + cValToChar(oDominio:oDados:tamanhoLista("MAT"))   , "CM")

	If !lTemOpc
		nTempoIni := MicroSeconds()
		oDominio:oAglutina:incluiRastreios("1", @nTotal)  //1 - Carga de Demandas
		oLogs:log("Tempo de carga das aglutinacoes das Demandas (nao existe demanda com opcional): " + cValToChar(MicroSeconds() - nTempoIni), "CM")
		oLogs:log("Quantidade de registros na lista de demandas aglutinadas: " + cValToChar(nTotal)                    , "CM")
	EndIf

	//Grava flag de conclusão global
	oMatriz:setFlag("termino_carga_DEM", "S")
Return

/*/{Protheus.doc} entradasOP
Carrega os dados dos Ordens de Produção

@author douglas.heydt
@since 13/09/2019
@version 1.0
/*/
METHOD entradasOP() CLASS MrpDados_Carga_Documentos

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaOP", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaOP(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaOP
Processa a carga dos dados das Ordens de Produção

@author marcelo.neumann
@since 08/07/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaOP(cTicket)
	Local aDadosOpc  := {}
	Local aRetPE     := {}
	Local cAliasQry  := ""
	Local cChaveProd := ""
	Local cFields    := "T4Q.T4Q_PROD, T4Q.T4Q_SALDO, T4Q.T4Q_DATA, T4Q.T4Q_OP, T4Q.R_E_C_N_O_ RECNO, T4Q.T4Q_IDREG, T4Q.T4Q_MOPC"
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := "%T4Q.T4Q_FILIAL, T4Q.T4Q_PROD, T4Q.T4Q_DATA%"
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local cWhere     := ""
	Local cWhereIN   := ""
	Local lHorFirme  := .F.
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nResto     := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil
	Local oJsEvtEntr := NIL
	Local oLogs      := Nil
	Local oMatriz    := Nil
	Local oMultiEmp  := Nil
	Local oOpcionais := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oCargaDocs := MrpDados_Carga_Documentos():New(oCarga)
	oLogs      := oDominio:oDados:oLogs
	oMatriz    := oDominio:oDados:oMatriz
	oMultiEmp  := oDominio:oMultiEmp
	oOpcionais := oDominio:oOpcionais
	oStatus    := MrpDados_Status():New(cTicket)

	If oDominio:oParametros["lEventLog"]
		oJsEvtEntr := JsonObject():New()
	EndIf

	If oStatus:preparaAmbiente()
		lUsaME := oMultiEmp:utilizaMultiEmpresa()
		If lUsaME
			cFields := oCarga:trataOptimizerOracle() + "T4Q_FILIAL, COALESCE(SMB.MB_NIVEL, '99') AS PRODNIVEL," + cFields
		Else
			cFields := oCarga:trataOptimizerOracle() + "HWA.HWA_NIVEL AS PRODNIVEL," + cFields
		EndIf

		cFields  += ",T4Q_PATHOP"

		cFields := "%" + cFields + "%"
		lHorFirme := oDominio:oParametros["lHorizonteFirme"] .AND. "|1.1|" $ oDominio:oParametros["cDocumentType"]

		cQueryCon := "%" + RetSqlName("T4Q") + " T4Q "
		cQueryCon += oCarga:montaJoinHWA("T4Q.T4Q_PROD", cTicket, .T., "T4Q.T4Q_FILIAL", "T4Q", oMultiEmp, .T.)

		cWhere := oCargaDocs:whereT4Q(oDominio, lHorFirme, .T., .F., /*5*/, .T.)

		//Atribui Filtro Relacionado ao Horizonte Firme
		If lHorFirme
			MrpDominio_HorizonteFirme():criaScriptIN(oDominio:oParametros["dDataIni"], "T4Q", "T4Q_PROD", "T4Q_DATA", cWhere, @cWhereIN, oDominio)
			cWhere += " AND ((T4Q.T4Q_TIPO <> '1') OR (T4Q.R_E_C_N_O_ IN ("
			cWhere += cWhereIN
			cWhere += ")))"
		EndIf
		cQueryCon += " WHERE " + cWhere + "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"T4Q",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3
				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf

		If oCarga:aguardaCalculoNiveis(oStatus)
		    
			CFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(*) TOTAL%" 
			
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT %Exp:cFieldCnt%
				  FROM %Exp:cQueryCon%
			EndSql
			If (cAliasQry)->(!Eof())
				nTotal := (cAliasQry)->TOTAL
			EndIf
			(cAliasQry)->(dbCloseArea())
		Else
			oMatriz:setFlag("termino_carga_OP", "S")
		EndIf
	EndIf

	oMatriz:setFlag("qtd_registros_total_ops", nTotal)
	oMatriz:setFlag("qtd_registros_lidos_ops", 0)

	If nTotal > 0
		BeginSql Alias cAliasQry
			COLUMN T4Q_DATA AS DATE
			SELECT %Exp:cFields%
			  FROM %Exp:cQueryCon%
			 ORDER BY %Exp:cOrder%
		EndSql

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			aDadosOpc := Array(ARRAY_OP_TAMAN)

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oMatriz:setFlag("termino_carga_OP", "'S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->(T4Q_FILIAL), oMultiEmp:tamanhoFilial())
			EndIf

			cProduto := PadR((cAliasQry)->(T4Q_PROD), oCarga:nTamCod)

			//Loga Evento 006 - Documento planejado em atraso
			If oDominio:oParametros["lEventLog"] .And. (cAliasQry)->(T4Q_DATA) < oDominio:oParametros["dDataIni"]
				oDominio:oEventos:loga("006", cProduto, (cAliasQry)->(T4Q_DATA), {(cAliasQry)->(T4Q_DATA), (cAliasQry)->(T4Q_OP), "", "T4Q"}, cFilAux)
			EndIf

			aDadosOpc[ARRAY_OP_POS_FILIAL] := cFilAux
			aDadosOpc[ARRAY_OP_POS_PROD  ] := cProduto
			aDadosOpc[ARRAY_OP_POS_DATA  ] := (cAliasQry)->(T4Q_DATA)
			aDadosOpc[ARRAY_OP_POS_PATH  ] := (cAliasQry)->(T4Q_PATHOP)
			aDadosOpc[ARRAY_OP_POS_SALDO ] := (cAliasQry)->(T4Q_SALDO)
			aDadosOpc[ARRAY_OP_POS_IDREG ] := (cAliasQry)->(T4Q_IDREG)
			aDadosOpc[ARRAY_OP_POS_OP    ] := (cAliasQry)->(T4Q_OP)
			aDadosOpc[ARRAY_OP_POS_MOPC  ] := (cAliasQry)->(T4Q_MOPC)
			aDadosOpc[ARRAY_OP_POS_RECNO ] := (cAliasQry)->(RECNO)

			//Se possui Opcional, a carga deve ser somente ao final
			If !Empty((cAliasQry)->(T4Q_MOPC))
				aDadosOpc[ARRAY_OP_POS_INDOPC] := "OP"
				aDadosOpc[ARRAY_OP_POS_QTDOPC] := oCargaDocs:retornaQtdOpcionais((cAliasQry)->T4Q_MOPC)

				If aDadosOpc[ARRAY_OP_POS_QTDOPC] <> "0"
					cChaveProd := cFilAux + cProduto
					oCargaDocs:adicionaListaOpcional(aDadosOpc, (cAliasQry)->PRODNIVEL)

					aSize(aDadosOpc, 0)
					(cAliasQry)->(dbSkip())
					Loop
				EndIf
			EndIf

			nIndRegs++
			If !cargaOP(aDadosOpc, oDominio, @oJsEvtEntr)
				oLogs:log(STR0055 + "T4Q", "E") //"Erro na carga de dados da tabela para memoria: "
			EndIf

			//Atualiza contador de registros lidos
			nResto := Mod(nIndRegs, 50)
			If nResto == 0
				oMatriz:setFlag("qtd_registros_lidos_ops", 50, , , .T.)
			EndIf

			aSize(aDadosOpc, 0)
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())

		nResto := Mod(nIndRegs, 50)
		If nResto > 0
			oMatriz:setFlag("qtd_registros_lidos_ops", nResto, , , .T.)
		EndIf
	EndIf

	//Registra dados de opcionais na memória global.
	oCargaDocs:gravaListaOpcionalGlobal(oLogs)

	//Registra documentos (SMV) na memória global
	oCarga:registraDocumentos("T4Q")

	oLogs:log("Tempo de carga de Ordens de Produção (Sem Opcional): "    + cValToChar(MicroSeconds() - nTempoIni)            , "CM")
	oLogs:log("Quantidade de Ordens de Produção carregadas em memoria: " + cValToChar(nIndRegs) + " de " + cValToChar(nTotal), "CM")
	oLogs:log("Quantidade de itens da matriz carregados em memoria: "    + cValToChar(oDominio:oDados:tamanhoLista("MAT"))   , "CM")

	//Grava flag de conclusão global
	oMatriz:setFlag("termino_carga_OP", "S")

	If oDominio:oParametros["lEventLog"]
		oDominio:oEventos:incluiEntradas(oJsEvtEntr, "T4Q")
		FreeObj(oJsEvtEntr)
		oJsEvtEntr := Nil
	EndIf

	If oDominio:oParametros["lRastreiaEntradas"]
		If !oDominio:oRastreioEntradas:efetivaInclusao()
			If oStatus:getStatus("status") <> "4"
				oLogs:log(STR0055 + "T4Q", "E") //"Erro na carga de dados da tabela para memoria: "
			EndIf
		EndIf
	EndIf

	//Limpa os arrays da memória
	aSize(aRetPE, 0)
	aRetPE := Nil
Return

/*/{Protheus.doc} entradasEmpenho
Carrega os dados dos Empenhos

@author marcelo.neumann
@since 16/03/2020
@version 1.0
/*/
METHOD entradasEmpenho() CLASS MrpDados_Carga_Documentos

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaEm", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaEm(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaEm
Processa a carga dos dados dos Empenhos

@author marcelo.neumann
@since 16/03/2020
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaEm(cTicket)
	Local aDadosOpc  := {}
	Local aPrepAglut := {}
	Local aRetPE     := {}
	Local cBanco     := ""
	Local cChaveEmpe := ""
	Local cChaveProd := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := "%T4S.T4S_FILIAL, T4S.T4S_PROD, T4S.T4S_SEQ, T4S.T4S_LOCAL, T4S.T4S_OP, T4S.T4S_OPORIG, T4S.T4S_DT%"
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local cWhere     := ""
	Local cWhereIN   := ""
	Local dLimite    := Nil
	Local lHorFirme  := .F.
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lTemOpc    := .F.
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nQtdOpc    := 0
	Local nQtdSaiPre := 0
	Local nResto     := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oMatriz    := Nil
	Local oMultiEmp  := Nil
	Local oOpcionais := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oCargaDocs := MrpDados_Carga_Documentos():New(oCarga)
	oLogs      := oDominio:oDados:oLogs
	oMatriz    := oDominio:oDados:oMatriz
	oMultiEmp  := oDominio:oMultiEmp
	oOpcionais := oDominio:oOpcionais
	oStatus    := MrpDados_Status():New(cTicket)

	If oStatus:preparaAmbiente()
		cBanco    := TcGetDB()
		lHorFirme := oDominio:oParametros["lHorizonteFirme"] .AND. "|1.1|" $ oDominio:oParametros["cDocumentType"]
		lUsaME    := oMultiEmp:utilizaMultiEmpresa()

		cFields := oCarga:trataOptimizerOracle() + "T4S.T4S_FILIAL, "
		cFields += "T4S.T4S_OP, "
		cFields += "T4S.T4S_OPORIG, "
		cFields += "T4S.T4S_PROD, "
		cFields += "T4S.T4S_SEQ, "
		cFields += "SUM(T4S.T4S_QTD) QUANT, "
		cFields += "T4S.T4S_DT, "
		cFields += "SUM(T4S.T4S_QSUSP) QSUSP, "
		cFields += "T4S.T4S_LOCAL,"
		cFields += "T4Q.R_E_C_N_O_ RECNOOP,"
		cFields += "T4Q.T4Q_PROD,"

		If lUsaME
			cFields += "COALESCE(SMB.MB_NIVEL, '99') AS PRODNIVEL,"
		Else
			cFields += "HWA.HWA_NIVEL AS PRODNIVEL,"
		EndIf

		If cBanco == "ORACLE"
			cFields += " T4QORIG.R_E_C_N_O_ RECNOORG,"
			cFields += " UTL_RAW.CAST_TO_VARCHAR2(T4Q.T4Q_MOPC) T4Q_MOPC,"
			cFields += " UTL_RAW.CAST_TO_VARCHAR2(T4QORIG.T4Q_PATHOP) T4Q_PATHOP"
		Else
			cFields += " T4Q.T4Q_MOPC, "
			cFields += " T4QORIG.T4Q_PATHOP "
		EndIf

		cFields := "%" + cFields + "%"

		cQueryCon += "%" + RetSqlName("T4Q") + " T4Q "
		cQueryCon += " INNER JOIN " + RetSqlName("T4S") + " T4S "
		cQueryCon +=    " ON T4Q.T4Q_OP     = T4S.T4S_OP"
		cQueryCon +=   " AND T4S.D_E_L_E_T_ = ' '"

		If lUsaME
			cQueryCon += " AND " + oMultiEmp:queryFilial("T4S", "T4S_FILIAL", .T.)
			cQueryCon += " AND T4Q.T4Q_FILIAL = T4S.T4S_FILIAL "
		Else
			cQueryCon += " AND T4S.T4S_FILIAL = '" + xFilial("T4S") + "'"
		EndIf
		If !("|2|" $ oDominio:oParametros["cDocumentType"])
			cQueryCon += " AND (T4S.T4S_QTD - T4S.T4S_QSUSP) <> 0"
		EndIf

		//Parâmetro para filtrar os armazéns
		If !Empty(oDominio:oParametros["cWarehouses"])
			cQueryCon += " AND " + oDominio:oSeletivos:scriptInSQL("T4S.T4S_LOCAL", "cWarehouses")
		EndIf

		cQueryCon += " AND EXISTS ( " + condLocal("T4S", "T4S.T4S_LOCAL", "T4S.T4S_FILIAL", oMultiEmp) + " ) "

		cQueryCon += oCarga:montaJoinHWA("T4S.T4S_PROD", cTicket, .T., "T4S.T4S_FILIAL", "T4S", oMultiEmp, .T.)

		cQueryCon += " LEFT OUTER JOIN " + RetSqlName("T4Q") + " T4QORIG "
		cQueryCon +=   " ON T4QORIG.T4Q_FILIAL = T4S.T4S_FILIAL "
		cQueryCon +=  " AND T4QORIG.T4Q_OP     = T4S.T4S_OPORIG "
		cQueryCon +=  " AND T4QORIG.D_E_L_E_T_ = ' ' "
		cQueryCon +=  " AND T4S.T4S_OPORIG    <> ' ' "

		cWhere := oCargaDocs:whereT4Q(oDominio, lHorFirme, .F., /*04*/, .F., .F.)

		//Atribui Filtro Relacionado ao Horizonte Firme
		If lHorFirme
			MrpDominio_HorizonteFirme():criaScriptIN(oDominio:oParametros["dDataIni"], "T4Q", "T4Q_PROD", "T4Q_DATA", cWhere, @cWhereIN, oDominio)
			cWhere += " AND ((T4Q.T4Q_TIPO <> '1') OR (T4Q.R_E_C_N_O_ IN ("
			cWhere += cWhereIN
			cWhere += ")))"
		EndIf

		dLimite   := oDominio:oPeriodos:ultimaDataDoMRP()
		If !oDominio:oParametros["lEventLog"]
			cWhere += " AND T4S.T4S_DT <= '" + DtoS(dLimite) + "' "
		EndIf

		cWhere += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4S.T4S_PROD",.F.,.T.,.F.)    //Valida o filtro de Tipo ou Grupo de Produto,.F.,.T.,.F.)

		cQueryCon += " WHERE " + cWhere
		cQueryCon += " GROUP BY T4S.T4S_FILIAL, "
		cQueryCon +=          " T4S.T4S_OP, "
		cQueryCon +=          " T4S.T4S_OPORIG, "
		cQueryCon +=          " T4S.T4S_PROD, "
		cQueryCon +=          " T4S.T4S_SEQ, "
		cQueryCon +=          " T4S.T4S_DT, "
		cQueryCon +=          " T4S.T4S_LOCAL,"
		cQueryCon +=          " T4Q.R_E_C_N_O_,"
		cQueryCon +=          " T4Q.T4Q_PROD,"

		If lUsaME
			cQueryCon += " SMB.MB_NIVEL,"
		Else
			cQueryCon += " HWA.HWA_NIVEL,"
		EndIf

		If cBanco == "ORACLE"
			cQueryCon += " T4QORIG.R_E_C_N_O_,"
			cQueryCon += " UTL_RAW.CAST_TO_VARCHAR2(T4Q.T4Q_MOPC),"
			cQueryCon += " UTL_RAW.CAST_TO_VARCHAR2(T4QORIG.T4Q_PATHOP)"
		Else
			cQueryCon += " T4Q.T4Q_MOPC,"
			cQueryCon += " T4QORIG.T4Q_PATHOP"
		EndIf

		cQueryCon += "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"T4S",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3
				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf

		If oCarga:aguardaCalculoNiveis(oStatus)
		    CFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(*) TOTAL%" 
		    
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT %Exp:cFieldCnt%
				FROM (SELECT 1 AS REG FROM %Exp:cQueryCon%) T
			EndSql

			If (cAliasQry)->(!Eof())
				nTotal := (cAliasQry)->TOTAL
			EndIf
			(cAliasQry)->(dbCloseArea())
		Else
			oMatriz:setFlag("termino_carga_Emp", "S")
		EndIf
	EndIf

	oMatriz:setFlag("qtd_registros_total_empenhos", nTotal)
	oMatriz:setFlag("qtd_registros_lidos_empenhos", 0)

	If nTotal > 0
		BeginSql Alias cAliasQry
			COLUMN T4S_DT AS DATE
			SELECT %Exp:cFields%
			  FROM %Exp:cQueryCon%
			 ORDER BY %Exp:cOrder%
		EndSql

		//Flag de controle das threads referentes ao aglutina:prepara()
		oDominio:oDados:oMatriz:setFlag("ExecPrepAglutina", 0)

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oMatriz:setFlag("termino_carga_Emp", "S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->T4S_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			cProduto := PadR((cAliasQry)->T4S_PROD, oCarga:nTamCod)

			If !("|2|" $ oDominio:oParametros["cDocumentType"])
				nQtdSaiPre := (cAliasQry)->QUANT - (cAliasQry)->QSUSP
			Else
				nQtdSaiPre := (cAliasQry)->QUANT
			EndIf

			If !Empty((cAliasQry)->T4S_PROD)
				cChaveEmpe := RTrim((cAliasQry)->T4S_FILIAL) + ";"
				cChaveEmpe += RTrim((cAliasQry)->T4S_PROD)   + ";"
				cChaveEmpe += RTrim((cAliasQry)->T4S_SEQ)    + ";"
				cChaveEmpe += RTrim((cAliasQry)->T4S_LOCAL)  + ";"
				cChaveEmpe += RTrim((cAliasQry)->T4S_OP)     + ";"
				cChaveEmpe += RTrim((cAliasQry)->T4S_OPORIG) + ";"
				cChaveEmpe += DToS((cAliasQry)->T4S_DT)

				//Tratamento para quando possui o Opcional
				If !Empty((cAliasQry)->T4Q_MOPC)
					nQtdOpc := oCargaDocs:retornaQtdOpcionais((cAliasQry)->T4Q_MOPC)

					//Se o opcional está preenchido, separa para carregar depois
					If nQtdOpc <> "0"
						aDadosOpc := Array(ARRAY_OPC_EMP_TAMAN)
						aDadosOpc[ARRAY_OPC_EMP_INDOPC  ] := "EMP"
						aDadosOpc[ARRAY_OPC_EMP_QTDOPC  ] := nQtdOpc
						aDadosOpc[ARRAY_OPC_EMP_FILIAL  ] := cFilAux
						aDadosOpc[ARRAY_OPC_EMP_PRODEMP ] := cProduto
						aDadosOpc[ARRAY_OPC_EMP_CHAVEEMP] := cChaveEmpe
						aDadosOpc[ARRAY_OPC_EMP_RECNOOP ] := (cAliasQry)->RECNOOP
						aDadosOpc[ARRAY_OPC_EMP_RECNOORG] := Iif(cBanco == "ORACLE", (cAliasQry)->RECNOORG, "")
						aDadosOpc[ARRAY_OPC_EMP_MOPC    ] := (cAliasQry)->T4Q_MOPC
						aDadosOpc[ARRAY_OPC_EMP_PATHOP  ] := (cAliasQry)->T4Q_PATHOP
						aDadosOpc[ARRAY_OPC_EMP_OPORIG  ] := (cAliasQry)->T4S_OPORIG
						aDadosOpc[ARRAY_OPC_EMP_DT      ] := (cAliasQry)->T4S_DT
						aDadosOpc[ARRAY_OPC_EMP_PRODOP  ] := (cAliasQry)->T4Q_PROD
						aDadosOpc[ARRAY_OPC_EMP_OP      ] := (cAliasQry)->T4S_OP
						aDadosOpc[ARRAY_OPC_EMP_SEQ     ] := (cAliasQry)->T4S_SEQ
						aDadosOpc[ARRAY_OPC_EMP_SAIDPRE ] := nQtdSaiPre

						cChaveProd := cFilAux + cProduto
						oCargaDocs:adicionaListaOpcional(aDadosOpc, (cAliasQry)->PRODNIVEL)
						lTemOpc := .T.

						aSize(aDadosOpc, 0)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
				EndIf

				aCarga := Array(ARRAY_CARGA_EMP_SIZE)
				aCarga[ARRAY_CARGA_EMP_FILIAL  ] := cFilAux
				aCarga[ARRAY_CARGA_EMP_PRODEMP ] := cProduto
				aCarga[ARRAY_CARGA_EMP_CHAVEEMP] := cChaveEmpe
				aCarga[ARRAY_CARGA_EMP_SEQ     ] := (cAliasQry)->T4S_SEQ
				aCarga[ARRAY_CARGA_EMP_DT      ] := (cAliasQry)->T4S_DT
				aCarga[ARRAY_CARGA_EMP_OP      ] := (cAliasQry)->T4S_OP
				aCarga[ARRAY_CARGA_EMP_PRODOP  ] := (cAliasQry)->T4Q_PROD
				aCarga[ARRAY_CARGA_EMP_OPORIG  ] := (cAliasQry)->T4S_OPORIG
				aCarga[ARRAY_CARGA_EMP_QUANT   ] := nQtdSaiPre
				aCarga[ARRAY_CARGA_EMP_OPC     ] := ""

				If !cargaEmp(aCarga, cTicket, oDominio, @aPrepAglut)
					oLogs:log(STR0055 + "T4S", "E") //"Erro na carga de dados da tabela para memoria: "
				EndIf

				aSize(aCarga, 0)
				nIndRegs++

				//Se roda em multi-thread, agrupa registros para delegar à outra thread
				If oDominio:oParametros["nThreads"] >= 1 .And. Mod(nIndRegs, 1000) == 0
					oDominio:oDados:oMatriz:setFlag("ExecPrepAglutina",1,,,.T.)
					PCPIPCGO(oDominio:oParametros["cSemaforoThreads"], .F., "MrpAglPrep", aPrepAglut, .T., cTicket) //Delega para processamento em Thread
					aSize(aPrepAglut,0)
				EndIf
			EndIf

			//Atualiza contador de registros lidos
			nResto := Mod(nIndRegs, 50)
			If nResto == 0
				oMatriz:setFlag("qtd_registros_lidos_empenhos", 50, , , .T.)
			EndIf

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())

		//Se roda em multi-thread e o agrupador não chegou em 1000, chama o aglutina:prepara
		If oDominio:oParametros["nThreads"] >= 1
			If nIndRegs == 1 .Or. Mod(nIndRegs-1, 1000) > 0
				MrpAglPrep(aPrepAglut, .F., cTicket)
				aSize(aPrepAglut,0)
			EndIf
		EndIf

		nResto := Mod(nIndRegs, 50)
		If nResto > 0
			oMatriz:setFlag("qtd_registros_lidos_empenhos", nResto, , , .T.)
		EndIf

		//Aguarda encerrar todas as threads para incluir a rastreabilidade
		While oMatriz:getFlag("ExecPrepAglutina") <> 0
			Sleep(500)
		End

		//Inclui rastreabilidade dos empenhos caso não tenha empenho com opcional
		If !lTemOpc
			oDominio:oAglutina:incluiRastreios("2")  //2 - Carga de Empenhos
		EndIf
	EndIf

	//Registra dados de opcionais na memória global.
	oCargaDocs:gravaListaOpcionalGlobal(oLogs)

	//Registra documentos (SMV) na memória global
	oCarga:registraDocumentos("T4S")

	oLogs:log("Tempo de carga de Empenhos (Sem Opcional): "           + cValToChar(MicroSeconds() - nTempoIni)            , "CM")
	oLogs:log("Quantidade de Empenhos carregados em memoria: "        + cValToChar(nIndRegs) + " de " + cValToChar(nTotal), "CM")
	oLogs:log("Quantidade de itens da matriz carregados em memoria: " + cValToChar(oDominio:oDados:tamanhoLista("MAT"))   , "CM")

	//Grava flag de conclusão global
	oMatriz:setFlag("termino_carga_Emp", "S")

	//Limpa os arrays da memória
	aSize(aRetPE, 0)
	aRetPE := Nil
Return

/*/{Protheus.doc} entradasPC
Carrega os dados dos Pedidos de Compra

@author marcelo.neumann
@since 04/10/2019
@version 1.0
/*/
METHOD entradasPC() CLASS MrpDados_Carga_Documentos

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaPC", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaPC(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaPC
Processa a carga dos dados dos Pedidos de Compra

@author marcelo.neumann
@since 04/10/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaPC(cTicket)
	Local aAux       := {}
	Local aRegistro  := {}
	Local aRetPE     := {}
	Local cAliasQry  := ""
	Local cChave     := ""
	Local cChaveProd := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := "%T4U.T4U_FILIAL, T4U.T4U_PROD, T4U.T4U_SEQ, T4U.T4U_LOCAL, T4U.T4U_DTENT%"
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local cWhere     := ""
	Local cWhereIN   := ""
	Local dEntrega   := Nil
	Local dLimite    := Nil
	Local lHorFirme  := .F.
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nPeriodo   := 0
	Local nQtdEntPrv := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oJsEvtEntr := Nil
	Local oMatriz    := Nil
	Local oMultiEmp  := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oCargaDocs := MrpDados_Carga_Documentos():New()
	oLogs      := oDominio:oDados:oLogs
	oMatriz    := oDominio:oDados:oMatriz
	oMultiEmp  := oDominio:oMultiEmp
	oStatus    := MrpDados_Status():New(cTicket)

	If oDominio:oParametros["lEventLog"]
		oJsEvtEntr := JsonObject():New()
	EndIf

	If oStatus:preparaAmbiente()
		lHorFirme := oDominio:oParametros["lHorizonteFirme"] .AND. "|1.1|" $ oDominio:oParametros["cDocumentType"]
		lUsaME    := oMultiEmp:utilizaMultiEmpresa()

		cFields := oCarga:trataOptimizerOracle() + " T4U.T4U_PROD, "
		cFields += " T4U.T4U_QTD, "
		cFields += " T4U.T4U_DTENT, "
		cFields += " T4U.T4U_QUJE, "
		cFields += " T4U.T4U_NUM, "
		cFields += " T4U.T4U_SEQ, "
		cFields += " T4U.T4U_IDREG, "
		cFields += " T4U.T4U_FILIAL "

		cFields := "%" + cFields + "%"

		cQueryCon := "%" + RetSqlName("T4U") + " T4U "
		cQueryCon += oCarga:montaJoinHWA("T4U.T4U_PROD", cTicket, .T., "T4U.T4U_FILIAL", "T4U", oMultiEmp)
		cQueryCon += " LEFT OUTER JOIN " + RetSqlName("T4Q") + " T4Q "
		cQueryCon +=   " ON T4Q.T4Q_OP = T4U.T4U_OP "

		cQueryCon += "AND " + oCargaDocs:whereT4Q(oDominio, lHorFirme, .F., /*04*/, .F., .F., "T4U", "T4U.T4U_FILIAL", .F., .F.)

		If lUsaME
			cWhere += oMultiEmp:queryFilial("T4U", "T4U_FILIAL", .T.)
		Else
			cWhere += " T4U.T4U_FILIAL = '" + xFilial("T4U") + "' "
		EndIf

		cWhere += " AND (( " + ANDT4QTIPO(oDominio:oParametros["cDocumentType"], lHorFirme)
		cWhere += " AND "    + ANDT4QSITU(oDominio:oParametros["cDocumentType"]) + " ) "
		cWhere += "  OR (T4U.T4U_OP    = ' ' OR (T4U.T4U_OP IS NOT NULL AND T4Q.T4Q_OP IS NULL)) ) "

		cWhere += " AND T4U.T4U_QUJE  < T4U.T4U_QTD"
		cWhere += " AND (T4U.T4U_TIPO = '1' "

		If "|1.3|" $ oDominio:oParametros["cDocumentType"] .OR. lHorFirme
			cWhere +=  "OR T4U.T4U_TIPO = '2' "
		EndIf

		cWhere += ")"

		dLimite := oDominio:oPeriodos:ultimaDataDoMRP()
		If !Empty(dLimite)
			cWhere += " AND T4U.T4U_DTENT <= '" + DtoS(dLimite) + "' "
		EndIf

		//Valida o filtro de Tipo ou Grupo de Produtos
		cWhere += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4U.T4U_PROD",.F.,.T.,.F.)

		//Parâmetro para filtrar os armazéns
		If !Empty(oDominio:oParametros["cWarehouses"])
			cWhere += " AND " + oDominio:oSeletivos:scriptInSQL("T4U.T4U_LOCAL", "cWarehouses")
		EndIf

		cWhere += " AND EXISTS ( " + condLocal("T4U", "T4U.T4U_LOCAL", "T4U.T4U_FILIAL", oMultiEmp) + " ) "

		//Atribui Filtro Relacionado ao Horizonte Firme
		If lHorFirme
			MrpDominio_HorizonteFirme():criaScriptIN(oDominio:oParametros["dDataIni"], "T4U", "T4U_PROD", "T4U_DTENT", cWhere, @cWhereIN, oDominio)
			cWhere += " AND ((T4U.T4U_TIPO <> '2') OR (T4U.R_E_C_N_O_ IN ("
			cWhere += cWhereIN
			cWhere += ")))"
		EndIf
		cQueryCon += " WHERE " + cWhere + "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"T4U",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3
				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf
		
		CFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(1) TOTAL%" 
        
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT %Exp:cFieldCnt%
			  FROM %Exp:cQueryCon%
		EndSql

		If (cAliasQry)->(!Eof())
			nTotal := (cAliasQry)->TOTAL
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	oMatriz:setFlag("qtd_registros_total_pedidos", nTotal, , , .T.)
	oMatriz:setFlag("qtd_registros_lidos_pedidos", 0     , , , .T.)

	If nTotal > 0
		aAux := Array(TAM_MAT)

		BeginSql Alias cAliasQry
			COLUMN T4U_DTENT AS DATE
			SELECT %Exp:cFields%
			  FROM %Exp:cQueryCon%
			 ORDER BY %Exp:cOrder%
		EndSql

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			nIndRegs++

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oMatriz:setFlag("termino_carga_PC", "S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->T4U_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			cProduto := PadR((cAliasQry)->T4U_PROD, oCarga:nTamCod)
			dEntrega := ConvDatPer(cFilAux, oDominio, (cAliasQry)->T4U_DTENT, @nPeriodo, .F.)

			//Loga Evento 006 - Documento planejado em atraso
			If oDominio:oParametros["lEventLog"] .And. (cAliasQry)->T4U_DTENT < oDominio:oParametros["dDataIni"]
				oDominio:oEventos:loga("006", cProduto, (cAliasQry)->T4U_DTENT, {(cAliasQry)->T4U_DTENT, (cAliasQry)->T4U_NUM, (cAliasQry)->T4U_SEQ, "T4U"}, cFilAux)
			EndIf

			cChaveProd := cFilAux + cProduto
			cChave     := DtoS(dEntrega) + cChaveProd
			nQtdEntPrv := (cAliasQry)->T4U_QTD - (cAliasQry)->T4U_QUJE

			aSize(aRegistro, 0)

			//Guarda o registro na Matriz
			oMatriz:trava(cChave)

			If oMatriz:getRow(1, cChave, Nil, @aRegistro, .F., .T.)
				aRegistro[MAT_ENTPRE] += nQtdEntPrv

				If !oMatriz:updRow(1, cChave, Nil, aRegistro, .F., .T.)
					If oStatus:getStatus("status") == "4"
						Exit
					Else
						oLogs:log(STR0055 + "T4U", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf
				EndIf
			Else
				aAux[MAT_FILIAL] := cFilAux
				aAux[MAT_DATA]   := dEntrega
				aAux[MAT_PRODUT] := cProduto
				aAux[MAT_SLDINI] := 0
				aAux[MAT_ENTPRE] := nQtdEntPrv
				aAux[MAT_SAIPRE] := 0
				aAux[MAT_SAIEST] := 0
				aAux[MAT_SALDO]  := 0
				aAux[MAT_NECESS] := 0
				aAux[MAT_QTRENT] := 0
				aAux[MAT_QTRSAI] := 0
				aAux[MAT_TPREPO] := " "
				aAux[MAT_EXPLOD] := .F.
				aAux[MAT_THREAD] := -1
				aAux[MAT_IDOPC]  := ""
				aAux[MAT_DTINI]  := dEntrega

				If !oMatriz:addRow(cChave, aAux, , , , cChaveProd)
					If oStatus:getStatus("status") == "4"
						Exit
					Else
						oLogs:log(STR0055 + "T4U", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf
				EndIf

				//Cria lista deste produto para registrar os periodos
				If !oMatriz:existList("Periodos_Produto_" + cChaveProd)
					oMatriz:createList("Periodos_Produto_" + cChaveProd)
				EndIf
				oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)
			EndIf

			oMatriz:destrava(cChave)

			oCarga:addLogDocumento(cFilAux, cProduto, "", dEntrega, (cAliasQry)->T4U_NUM+(cAliasQry)->T4U_SEQ, "T4U", nQtdEntPrv)

			If oDominio:oParametros["lEventLog"]
				If oJsEvtEntr[cChaveProd] == Nil
					oJsEvtEntr[cChaveProd] := {}
				EndIf
				//Adiciona {cDocumento, cItem, cAlias, nPeriodo, nQuantidade, nControle, lPossuiLog, nPriConsumo, nPrioridade, dData}
				aAdd(oJsEvtEntr[cChaveProd], {(cAliasQry)->T4U_NUM, (cAliasQry)->T4U_SEQ, "T4U", nPeriodo, nQtdEntPrv, nQtdEntPrv, .F., 0, 10, (cAliasQry)->T4U_DTENT})
			EndIf

			If oDominio:oParametros["lRastreiaEntradas"]
				If !oDominio:oRastreioEntradas:addEntradaPrevista(cFilAux, "PC", (cAliasQry)->T4U_NUM+(cAliasQry)->T4U_SEQ, dEntrega, cProduto, nQtdEntPrv, "")
					If oStatus:getStatus("status") <> "4"
						oLogs:log(STR0055 + "T4U", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf
				EndIf
			EndIf

			oMatriz:setFlag("qtd_registros_lidos_pedidos", 1, , , .T.)

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Registra documentos (SMV) na memória global
	oCarga:registraDocumentos("T4U")

	oLogs:log(STR0066 + cValToChar(MicroSeconds() - nTempoIni)       , "CM") //"Tempo de carga de Pedidos de Compra "
	oLogs:log(STR0067 + cValToChar(nTotal)                           , "CM") //"Quantidade de Pedidos de Compra carregados em memória: "
	oLogs:logb({|| STR0026 + cValToChar(oDominio:oDados:tamanhoLista("MAT"))}, "CM") //"Quantidade de itens da matriz carregados em memoria: "

	//Grava flag de conclusão global
	oMatriz:setFlag("termino_carga_PC", "S")

	If oDominio:oParametros["lEventLog"]
		oDominio:oEventos:incluiEntradas(oJsEvtEntr, "T4U")
		FreeObj(oJsEvtEntr)
		oJsEvtEntr := Nil
	EndIf

	If oDominio:oParametros["lRastreiaEntradas"]
		If !oDominio:oRastreioEntradas:efetivaInclusao()
			If oStatus:getStatus("status") <> "4"
				oLogs:log(STR0055 + "T4U", "E") //"Erro na carga de dados da tabela para memoria: "
			EndIf
		EndIf
	EndIf

	//Limpa os arrays da memória
	aSize(aAux, 0)
	aAux := Nil
	aSize(aRegistro, 0)
	aRegistro := Nil
	aSize(aRetPE, 0)
	aRetPE := Nil

Return

/*/{Protheus.doc} entradasSC
Carrega os dados das Solicitações de Compras

@author douglas.heydt
@since 09/09/2019
@version 1.0
/*/
METHOD entradasSC() CLASS MrpDados_Carga_Documentos

	If Self:oCarga:processaMultiThread()
		PCPIPCGO(Self:oCarga:oDados:oParametros["cSemaforoThreads"], .F., "MrpCargaSC", Self:oCarga:oDados:oParametros["ticket"])
	Else
		MrpCargaSC(Self:oCarga:oDados:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpCargaSC
Processa a carga dos dados das Solicitações de Compras

@author marcelo.neumann
@since 08/07/2019
@version 1.0
@param cTicket, caracter, número do ticket de processamento do MRP
/*/
Function MrpCargaSC(cTicket)
	Local aAux       := {}
	Local aRegistro  := {}
	Local aRetPE     := {}
	Local cAliasQry  := ""
	Local cChave     := ""
	Local cChaveProd := ""
	Local cFields    := ""
	Local cFieldCnt  := ""
	Local cFilAux    := ""
	Local cOrder     := "%T4T.T4T_FILIAL, T4T.T4T_PROD, T4T.T4T_SEQ, T4T.T4T_LOCAL, T4T.T4T_DTENT%"
	Local cProduto   := ""
	Local cQueryCon  := ""
	Local cWhere     := ""
	Local cWhereIN   := ""
	Local dEntrega   := Nil
	Local dLimite    := Nil
	Local lHorFirme  := .F.	
	Local lP712SQL   := ExistBlock("P712SQL")
	Local lUsaME     := .F.
	Local nIndRegs   := 0
	Local nPeriodo   := 0
	Local nQtdEntPrv := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotal     := 0
	Local oCarga     := Nil
	Local oCargaDocs := Nil
	Local oDominio   := Nil
	Local oLogs      := Nil
	Local oJsEvtEntr := Nil
	Local oMatriz    := Nil
	Local oMultiEmp  := Nil
	Local oStatus    := Nil

	//Prepara o ambiente (quando for uma nova thread)
	oDominio   := MRPPrepDom(cTicket, .T.)
	oCarga     := oDominio:oDados:oCargaMemoria
	oCargaDocs := MrpDados_Carga_Documentos():New()
	oLogs      := oDominio:oDados:oLogs
	oMatriz    := oDominio:oDados:oMatriz
	oMultiEmp  := oDominio:oMultiEmp
	oStatus    := MrpDados_Status():New(cTicket)

	If oDominio:oParametros["lEventLog"]
		oJsEvtEntr := JsonObject():New()
	EndIf

	If oStatus:preparaAmbiente()
		lHorFirme := oDominio:oParametros["lHorizonteFirme"] .AND. "|1.1|" $ oDominio:oParametros["cDocumentType"]
		lUsaME    := oMultiEmp:utilizaMultiEmpresa()

		cFields := oCarga:trataOptimizerOracle() + " T4T.T4T_PROD, "
		cFields += " T4T.T4T_QTD, "
		cFields += " T4T.T4T_DTENT, "
		cFields += " T4T.T4T_QUJE, "
		cFields += " T4T.T4T_NUM, "
		cFields += " T4T.T4T_SEQ, "
		cFields += " T4T.T4T_IDREG, "
		cFields += " T4T.T4T_FILIAL "

		cFields := "%" + cFields + "%"

		cQueryCon := "%" + RetSqlName("T4T") + " T4T "
		cQueryCon += oCarga:montaJoinHWA("T4T.T4T_PROD", cTicket, .T., "T4T.T4T_FILIAL", "T4T", oMultiEmp)
		cQueryCon += " LEFT OUTER JOIN " + RetSqlName("T4Q") + " T4Q "
		cQueryCon +=   " ON T4Q.T4Q_OP = T4T.T4T_OP "

		cQueryCon += "AND " + oCargaDocs:whereT4Q(oDominio, lHorFirme, .F., /*04*/, .F., .F., "T4T", "T4T.T4T_FILIAL", .F., .F.)

		If lUsaME
			cWhere += oMultiEmp:queryFilial("T4T", "T4T_FILIAL", .T.)
		Else
			cWhere += " T4T.T4T_FILIAL = '" + xFilial("T4T") + "' "
		EndIf

		cWhere += " AND (( " + ANDT4QTIPO(oDominio:oParametros["cDocumentType"], lHorFirme)
		cWhere += " AND "    + ANDT4QSITU(oDominio:oParametros["cDocumentType"]) + " ) "
		cWhere += "  OR  (T4T.T4T_OP = ' ' OR (T4T.T4T_OP IS NOT NULL AND T4Q.T4Q_OP IS NULL)) ) "
		cWhere += " AND (T4T.T4T_TIPO = '1' "

		If "|1.3|" $ oDominio:oParametros["cDocumentType"] .OR. lHorFirme
			cWhere +=  "OR T4T.T4T_TIPO = '2' "
		EndIf

		cWhere += ")"

		dLimite := oDominio:oPeriodos:ultimaDataDoMRP()
		If !Empty(dLimite)
			cWhere += " AND T4T.T4T_DTENT <= '" + DtoS(dLimite) + "' "
		EndIf

		cWhere += " AND T4T.T4T_QTD > T4T.T4T_QUJE "

		//Valida o filtro de Tipo ou Grupo de Produtos
		cWhere += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4T.T4T_PROD",.F.,.T.,.F.)

		//Parâmetro para filtrar os armazéns
		If !Empty(oDominio:oParametros["cWarehouses"])
			cWhere += " AND " + oDominio:oSeletivos:scriptInSQL("T4T.T4T_LOCAL", "cWarehouses")
		EndIf

		cWhere += " AND EXISTS ( " + condLocal("T4T", "T4T.T4T_LOCAL", "T4T.T4T_FILIAL", oMultiEmp) + " ) "

		//Atribui Filtro Relacionado ao Horizonte Firme
		If lHorFirme
			MrpDominio_HorizonteFirme():criaScriptIN(oDominio:oParametros["dDataIni"], "T4T", "T4T_PROD", "T4T_DTENT", cWhere, @cWhereIN, oDominio)
			cWhere += " AND ((T4T.T4T_TIPO <> '2') OR (T4T.R_E_C_N_O_ IN ( "
			cWhere += cWhereIN
			cWhere += " ))) "
		EndIf
		cQueryCon += " WHERE " + cWhere + "%"

		If lP712SQL
			aRetPE := ExecBlock("P712SQL", .F., .F., {"T4T",cFields,cQueryCon,cOrder})

			If aRetPE != Nil .And. Len(aRetPE) == 3
				cFields   := aRetPE[1]
				cQueryCon := aRetPE[2]
				cOrder    := aRetPE[3]
			EndIf
		EndIf
        
		CFieldCnt := "%" + oCarga:trataOptimizerOracle() + " " + "COUNT(1) TOTAL%" 
		
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT %Exp:cFieldCnt%
			  FROM %Exp:cQueryCon%
		EndSql

		If (cAliasQry)->(!Eof())
			nTotal := (cAliasQry)->TOTAL
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	oMatriz:setFlag("qtd_registros_total_scs", nTotal, , , .T.)
	oMatriz:setFlag("qtd_registros_lidos_scs", 0     , , , .T.)

	If nTotal > 0
		aAux := Array(TAM_MAT)

		BeginSql Alias cAliasQry
			COLUMN T4T_DTENT AS DATE
			SELECT %Exp:cFields%
			  FROM %Exp:cQueryCon%
			 ORDER BY %Exp:cOrder%
		EndSql

		//Processa todos os registros encontrados
		While (cAliasQry)->(!Eof())
			nIndRegs++

			//Checa cancelamento a cada X delegacoes
			If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .AND. oStatus:getStatus("status") == "4"
				oMatriz:setFlag("termino_carga_SC", "S")
				Exit
			EndIf

			If lUsaME
				cFilAux := PadR((cAliasQry)->T4T_FILIAL, oMultiEmp:tamanhoFilial())
			EndIf

			cProduto := PadR((cAliasQry)->T4T_PROD, oCarga:nTamCod)
			dEntrega := ConvDatPer(cFilAux, oDominio, (cAliasQry)->T4T_DTENT, @nPeriodo, .F.)

			//Loga Evento 006 - Documento planejado em atraso
			If oDominio:oParametros["lEventLog"] .And. (cAliasQry)->T4T_DTENT < oDominio:oParametros["dDataIni"]
				oDominio:oEventos:loga("006", cProduto, (cAliasQry)->T4T_DTENT, {(cAliasQry)->T4T_DTENT, (cAliasQry)->T4T_NUM, (cAliasQry)->T4T_SEQ, "T4T"}, cFilAux)
			EndIf

			cChaveProd := cFilAux + cProduto
			cChave     := DtoS(dEntrega) + cChaveProd
			aSize(aRegistro, 0)

			nQtdEntPrv := (cAliasQry)->T4T_QTD - (cAliasQry)->T4T_QUJE

			//Guarda o registro na Matriz
			oMatriz:trava(cChave)

			If oMatriz:getRow(1, cChave, Nil, @aRegistro, .F., .T.)
				aRegistro[MAT_ENTPRE] += nQtdEntPrv

				If !oMatriz:updRow(1, cChave, Nil, aRegistro, .F., .T.)
					If oStatus:getStatus("status") == "4"
						Exit
					Else
						oLogs:log(STR0055 + "T4T", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf
				EndIf
			Else
				aAux[MAT_FILIAL] := cFilAux
				aAux[MAT_DATA]   := dEntrega
				aAux[MAT_PRODUT] := cProduto
				aAux[MAT_SLDINI] := 0
				aAux[MAT_ENTPRE] := nQtdEntPrv
				aAux[MAT_SAIPRE] := 0
				aAux[MAT_SAIEST] := 0
				aAux[MAT_SALDO]  := 0
				aAux[MAT_NECESS] := 0
				aAux[MAT_QTRENT] := 0
				aAux[MAT_QTRSAI] := 0
				aAux[MAT_TPREPO] := " "
				aAux[MAT_EXPLOD] := .F.
				aAux[MAT_THREAD] := -1
				aAux[MAT_IDOPC]  := ""
				aAux[MAT_DTINI]  := dEntrega

				If !oMatriz:addRow(cChave, aAux, , , , cChaveProd)
					If oStatus:getStatus("status") == "4"
						Exit
					Else
						oLogs:log(STR0055 + "T4T", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf
				EndIf

				//Cria lista deste produto para registrar os periodos
				If !oMatriz:existList("Periodos_Produto_" + cChaveProd)
					oMatriz:createList("Periodos_Produto_" + cChaveProd)
				EndIf
				oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)
			EndIf

			oMatriz:destrava(cChave)

			oCarga:addLogDocumento(cFilAux, cProduto, "", dEntrega, (cAliasQry)->T4T_NUM+(cAliasQry)->T4T_SEQ, "T4T", nQtdEntPrv)

			If oDominio:oParametros["lEventLog"]
				If oJsEvtEntr[cChaveProd] == Nil
					oJsEvtEntr[cChaveProd] := {}
				EndIf
				//Adiciona {cDocumento, cItem, cAlias, nPeriodo, nQuantidade, nControle, lPossuiLog, nPriConsumo, nPrioridade, dData}
				aAdd(oJsEvtEntr[cChaveProd], {(cAliasQry)->T4T_NUM, (cAliasQry)->T4T_SEQ, "T4T", nPeriodo, nQtdEntPrv, nQtdEntPrv, .F., 0, 20, (cAliasQry)->T4T_DTENT})
			EndIf

			If oDominio:oParametros["lRastreiaEntradas"]
				If !oDominio:oRastreioEntradas:addEntradaPrevista(cFilAux, "SC", (cAliasQry)->T4T_NUM+(cAliasQry)->T4T_SEQ, dEntrega, cProduto, nQtdEntPrv, "")
					If oStatus:getStatus("status") <> "4"
						oLogs:log(STR0055 + "T4T", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf
				EndIf
			EndIf

			oMatriz:setFlag("qtd_registros_lidos_scs", 1, , , .T.)

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Registra documentos (SMV) na memória global
	oCarga:registraDocumentos("T4T")

	oLogs:log(STR0036 + cValToChar(MicroSeconds() - nTempoIni)               , "CM") //"Tempo de carga de Solicitações de Compras "
	oLogs:log(STR0061 + cValToChar(nTotal)                                   , "CM") //"Quantidade de Solicitações de Compra carregadas em memória: "
	oLogs:logb({|| STR0026 + cValToChar(oDominio:oDados:tamanhoLista("MAT"))}, "CM") //"Quantidade de itens da matriz carregados em memoria: "

	//Grava flag de conclusão global
	oMatriz:setFlag("termino_carga_SC", "S")

	If oDominio:oParametros["lEventLog"]
		oDominio:oEventos:incluiEntradas(oJsEvtEntr, "T4T")
		FreeObj(oJsEvtEntr)
		oJsEvtEntr := Nil
	EndIf

	If oDominio:oParametros["lRastreiaEntradas"]
		If !oDominio:oRastreioEntradas:efetivaInclusao()
			If oStatus:getStatus("status") <> "4"
				oLogs:log(STR0055 + "T4T", "E") //"Erro na carga de dados da tabela para memoria: "
			EndIf
		EndIf
	EndIf

	//Limpa os arrays da memória
	aSize(aAux, 0)
	aAux := Nil
	aSize(aRegistro, 0)
	aRegistro := Nil
	aSize(aRetPE, 0)
	aRetPE := Nil

Return

/*/{Protheus.doc} ConvDatPer
Converte a data para uma data referente ao período (menor ou igual)

@author marcelo.neumann
@since 08/07/2019
@version 1.0
@param 01 cFilAux   , caracter, código da filial
@param 02 oDominio  , objeto  , instância da classe de Domínio
@param 03 dData     , data    , data a ser convertida
@param 04 nIndPeriod, número  , indice do periodo atual retornado por referencia
@param 05 lVerCalend, lógico  , indica se deverá ser considerado dia útil do calendário
@return   dData     , data    , data convertida no periodo. Em caso de data superior ao ultimo periodo retorna Nil.
/*/
Static Function ConvDatPer(cFilAux, oDominio, dData, nIndPeriod, lVerCalend)
	Local aPeriodos := oDominio:oPeriodos:retornaArrayPeriodos(cFilAux)
	Local nLeadTime := oDominio:oParametros["nLeadTime"]
	Local nIndAux   := 0

	nIndPeriod := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dData)
	nIndAux    := nIndPeriod

	If Len(aPeriodos) > 0
		If nLeadTime != 1 .And. lVerCalend
			While nIndPeriod > 0 .And. !oDominio:oPeriodos:verificaDataUtil(cFilAux, aPeriodos[nIndPeriod])
				nIndPeriod--
			EndDo

			//Se não encontrou uma data útil anterior a data atual, utiliza o primeiro período útil.
			If nIndAux > 0 .And. nIndPeriod == 0
				nIndPeriod := oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)
			EndIf
		EndIf

		If nIndPeriod == 0
			If dData < aPeriodos[1]
				If nLeadTime != 1 .And. lVerCalend
					//Quando utiliza calendário e a demanda
					//é de uma data anterior ao primeiro período do MRP,
					//joga a demanda para o primeiro período útil do MRP.
					dData      := oDominio:oPeriodos:buscaProximoDiaUtil(cFilAux, aPeriodos[1])
					nIndPeriod := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dData)
				EndIf

				If nIndPeriod == 0
					nIndPeriod := 1
					dData      := aPeriodos[1]
				EndIf
			Else
				nIndPeriod := Len(aPeriodos)
				dData      := aTail(aPeriodos)
			EndIf
		Else
			dData := aPeriodos[nIndPeriod]
		EndIf
	EndIf

Return dData

/*/{Protheus.doc} whereT4Q
Retorna o filtro para busca das Ordens de Produção (usado também na carga dos Empenhos)

@author marcelo.neumann
@since 16/03/2019
@version 1.0
@param 01 oDominio  , objeto, instância da classe de Domínio
@param 02 lHorFirme , lógico, indica se deve considerar o horizonte firme de documentos previstos
@param 03 lValidMrp , lógico, identifica se será validado o campo HWA_MRP para a query.
@param 04 lUsaExists, lógico, Identifica se deve adicionar o EXISTS principal da tabela HWA (oSeletivos:scriptExistsProdutoSQL)
@param 05 lDatLimite, lógico, Indica se filtrará as OPs pela data limite do MRP.
@param 06 lFiltraOP , lógico, Indica se está fazendo o filtro para a OP ou para outras tabelas.
@param 07 cTabFil   , string, Tabela utilizada no JOIN para adicionar o filtro quando utilizado multi-empresa.
@param 08 cColFil   , string, Coluna de filial da tabela utilizada no JOIN para adicionar o filtro quando utilizado multi-empresa.
@param 09 lFilTipo  , lógico, Filtra o tipo da OP
@param 10 lFilSitu  , lógico, Filtra a situação da OP
@return cWhere, caracter, filtro de busca das OPs
/*/
METHOD whereT4Q(oDominio, lHorFirme, lValidMRP, lUsaExists, lDatLimite, lFiltraOP, cTabFil, cColFil, lFilTipo, lFilSitu) CLASS MrpDados_Carga_Documentos
	Local cAlias     := ""
	Local cWhere     := ""
	Local cWhereSitu := ""
	Local cWhereTipo := ""
	Local dLimite    := oDominio:oPeriodos:ultimaDataDoMRP()

	Default cColFil    := ""
	Default cTabFil    := ""
	Default lUsaExists := .T.
	Default lDatLimite := .T.
	Default lFiltraOP  := .F.
	Default lFilTipo   := .T.
	Default lFilSitu   := .T.

	cWhere := " T4Q.T4Q_SALDO > 0 "

	If lFilTipo
		cWhereTipo := ANDT4QTIPO(oDominio:oParametros["cDocumentType"], lHorFirme)
		cWhere += " AND " + cWhereTipo
	EndIf
	If lFilSitu
		cWhereSitu := ANDT4QSITU(oDominio:oParametros["cDocumentType"])
		cWhere += " AND " + cWhereSitu
	EndIf

	If lDatLimite .And. !Empty(dLimite)
		cWhere += " AND T4Q.T4Q_DATA <= '" + DtoS(dLimite) + "'"
	EndIf

	If lFiltraOP
		cWhere += " AND " + oDominio:oSeletivos:scriptExistsProdutoSQL("T4Q.T4Q_PROD", .F., lValidMRP, lUsaExists)
	EndIf

	If oDominio:oMultiEmp:utilizaMultiEmpresa()
		If !Empty(cTabFil) .And. !Empty(cColFil)
			cAlias  := Left( cColFil, At(".", cColFil) - 1 )
			cColFil := StrTran(cColFil, cAlias + ".", "")
			cWhere   += " AND " + oDominio:oDados:oCargaMemoria:relacionaFilial("T4Q", "T4Q", "T4Q_FILIAL", cTabFil, cAlias, cColFil, .T., .T., .T.)
		Else
			cWhere += " AND " + oDominio:oMultiEmp:queryFilial("T4Q", "T4Q_FILIAL", .T.)
		EndIf
	Else
		cWhere += " AND T4Q.T4Q_FILIAL = '" + xFilial("T4Q") + "'"
	EndIf

	cWhere += " AND EXISTS ( " + condLocal("T4Q", "T4Q.T4Q_LOCAL", "T4Q.T4Q_FILIAL", oDominio:oMultiEmp) + " ) "

	//Parâmetro para filtrar os armazéns
	If !Empty(oDominio:oParametros["cWarehouses"]) .And. lFiltraOP
		cWhere += " AND " + oDominio:oSeletivos:scriptInSQL("T4Q.T4Q_LOCAL", "cWarehouses")
	EndIf

	cWhere += " AND T4Q.D_E_L_E_T_ = ' ' "

Return cWhere

/*/{Protheus.doc} ANDT4QTIPO
Retorna o filtro do Tipo da OP de acordo com o que foi informado na tela

@author renan.roeder
@since 14/07/2020
@version 1.0
@param 01 cDocType , caracter, parâmetro "cDocumentType" (oParametros)
@param 02 lHorFirme, lógico  , indica se deve considerar o horizonte firme de documentos previstos
@return cCondicao, caracter  , filtro do tipo das OPs
/*/
Static Function ANDT4QTIPO(cDocType, lHorFirme)
	Local cCondicao := ""

	cCondicao := "(T4Q.T4Q_TIPO = '4' "

	If "|1.3|" $ cDocType .Or. lHorFirme
		cCondicao += "OR T4Q.T4Q_TIPO = '1' "
	EndIf
	cCondicao += ")"

Return cCondicao

/*/{Protheus.doc} ANDT4QSITU
Retorna o filtro da Situação da OP de acordo com o que foi informado na tela

@author renan.roeder
@since 14/07/2020
@version 1.0
@param cDocType  , caracter, parâmetro "cDocumentType" (oParametros)
@return cCondicao, caracter, filtro do tipo das OPs
/*/
Static Function ANDT4QSITU(cDocType)
	Local cCondicao := "(T4Q.T4Q_SITUA = '1' "

	//cDocumentType = 3 (Sacramentadas) = T4Q.T4Q_SITUA = '2' (Sacramentadas)
	If "|3|" $ cDocType
		cCondicao += " OR T4Q.T4Q_SITUA = '2'"
	EndIf

	//cDocumentType = 2 (Suspensas) = T4Q.T4Q_SITUA = '3' (Suspensas)
	If "|2|" $ cDocType
		cCondicao += " OR T4Q.T4Q_SITUA = '3'"
	EndIf
	cCondicao += ")"

Return cCondicao

/*/{Protheus.doc} MrpAglPrep
Prepara o empenho no fonte de Aglutinação

@author marcelo.neumann
@since 18/03/2019
@version 1.0
@param 01 aPrepAglut, array   , array com a aglutinação
@param 02 lThread   , lógico  , indica se é uma nova thread
@param 03 cTicket   , caracter, número do ticket de processamento do MRP
@return Nil
/*/
Function MrpAglPrep(aPrepAglut, lThread, cTicket)
	Local aDados   := {}
	Local cDocAgl  := ""
	Local cDocOri  := ""
	Local cDocPai  := ""
	Local nIndex   := 0
	Local nSeqOri  := 0
	Local nTotEmp  := Len(aPrepAglut)
	Local oDominio := Nil

	oDominio := MRPPrepDom(cTicket)

	For nIndex := 1 To nTotEmp
		aDados := oDominio:oAglutina:prepara(aPrepAglut[nIndex][6]                    ,; //Código da filial
                                             "2"                                      ,; //2 - Carga de Empenhos
                                             "Pré-OP"                                 ,;
                                             {"Pré-OP", aPrepAglut[nIndex][1], "", ""},;
                                             aPrepAglut[nIndex][1]                    ,;
                                             aPrepAglut[nIndex][2]                    ,;
                                             aPrepAglut[nIndex][3]                    ,;
                                             ""                                       ,;
                                             aPrepAglut[nIndex][4]                    ,;
                                             aPrepAglut[nIndex][5]                    )

		If oDominio:oParametros["lRastreiaEntradas"]
			cDocOri := aPrepAglut[nIndex][7]
			cDocPai := aPrepAglut[nIndex][9]
			If !Empty(aDados)
				If aDados[oDominio:oAglutina:getPosicao("AGLUTINA")] .And. aPrepAglut[nIndex][4] > 0
					cDocAgl := aDados[oDominio:oAglutina:getPosicao("DOCUMENTO")]
					nSeqOri := Len(aDados[oDominio:oAglutina:getPosicao("ADOC_PAI")])


					oDominio:oRastreioEntradas:addAglutinado(aPrepAglut[nIndex][6], ; //Filial
					                                         cDocAgl              , ; //Documento Aglutinado
					                                         "Pré-OP"             , ; //Tipo Origem
					                                         aPrepAglut[nIndex][1], ; //Id Regisgtro Origem
					                                         nSeqOri              , ; //Sequência Origem
					                                         aPrepAglut[nIndex][8], ; //TRT do produto
					                                         aPrepAglut[nIndex][4], ; //Necessidade
					                                         0)                       //Substituição

					oDominio:oRastreioEntradas:addRelacionamentoDocFilho(cDocAgl, nSeqOri, cDocOri)
				EndIf

				If aPrepAglut[nIndex][4] < 0
					//Empenho negativo adiciona como entrada de saldo.
					oDominio:oRastreioEntradas:addNovoSaldo(aPrepAglut[nIndex][06]    ,;
					                                        "OP"                      ,;
					                                        aPrepAglut[nIndex][07]    ,;
					                                        aPrepAglut[nIndex][10]    ,;
					                                        aPrepAglut[nIndex][02]    ,;
					                                        Abs(aPrepAglut[nIndex][04]))
				EndIf

				aSize(aDados, 0)
			EndIf

			oDominio:oRastreioEntradas:addDocEmpenho(aPrepAglut[nIndex][1], cDocOri, cDocPai)
		EndIf
	Next nIndex

	If lThread
		oDominio:oDados:oMatriz:setFlag("ExecPrepAglutina",-1,,,.T.)
	EndIf

Return

/*/{Protheus.doc} condLocal
Monta query para a condição exists que verifica se o armazém entra no MRP.
@type  Static Function
@author Lucas Fagundes
@since 28/09/2022
@version P12
@param 01 cTabela  , Caractere, Tabela que irá utilizar a query.
@param 02 cColAmz  , Caractere, Coluna do armazém na tabela que está carregando os documentos.
@param 03 cColFil  , Caractere, Coluna da filial na tabela que está carregando os documentos.
@param 04 oMultiEmp, Object   , Instancia da classe multi-empresa para buscar a filiais.
@return cQuery, Caractere, Query para ser inserida na condição exists.
/*/
Static Function condLocal(cTabela, cColAmz, cColFil, oMultiEmp)
	Local cAlias := ""
	Local cQuery := ""

	cQuery := " SELECT 1"
	cQuery += " FROM " + RetSqlName("HWY") + " HWY"
	cQuery += " WHERE HWY.HWY_COD = " + cColAmz
	cQuery +=   " AND HWY.HWY_MRP = '1'"

	If oMultiEmp:utilizaMultiEmpresa()
		cAlias  := Left( cColFil, At(".", cColFil) - 1 )
		cColFil := StrTran(cColFil, cAlias + ".", "")
		
		cQuery += " AND " + oMultiEmp:oDados:oCargaMemoria:relacionaFilial("HWY", "HWY", "HWY_FILIAL", cTabela, cAlias, cColFil, .T., .T., .T.)
	Else
		cQuery += " AND HWY.HWY_FILIAL = '" + xFilial("HWY") + "'"
	EndIf

Return cQuery

/*/{Protheus.doc} adicionaListaOpcional
Salva o array com dados para ser carregado após a carga de produtos.
@author Lucas Fagundes
@since 29/08/2022
@version P12
@param 01 aDados, Array    , Array com os dados que serão salvos.
@param 02 cNivel, Caractere, Nível do produto
@return Nil
/*/
METHOD adicionaListaOpcional(aDados, cNivel) CLASS MrpDados_Carga_Documentos
	
	If Self:oCacheOpc:HasProperty(cNivel) == .F.
		Self:oCacheOpc[cNivel] := {}
	EndIf
	aAdd(Self:oCacheOpc[cNivel], aClone(aDados))

Return Nil

/*/{Protheus.doc} gravaListaOpcionalGlobal
Grava o array de opcionais na global

@author lucas.franca
@since 04/04/2023
@version P12
@param 01 oLogs, Object, Objeto de LOGS do MRP
@return Nil
/*/
METHOD gravaListaOpcionalGlobal(oLogs) CLASS MrpDados_Carga_Documentos
	Local aNames := Self:oCacheOpc:GetNames()
	Local nIndex := 0
	Local nTotal := 0
	Local oDados := Self:oCarga:oDados:oOpcionais

	If !Empty(aNames)
		oLogs:log("Iniciando exportacao de dados de opcionais para a memoria global " + Time(), "CM")
		If !oDados:existAList("OPC_CARGA_DOC")
			oDados:createAList("OPC_CARGA_DOC")
		EndIf
		
		nTotal := Len(aNames)
		For nIndex := 1 To nTotal
			oDados:setItemAList("OPC_CARGA_DOC", aNames[nIndex], Self:oCacheOpc[aNames[nIndex]], .T., .F., .T., 2)
			aSize(Self:oCacheOpc[aNames[nIndex]], 0)
			Self:oCacheOpc:DelName(aNames[nIndex])
		Next nIndex
		aSize(aNames, 0)
		oLogs:log("Termino exportacao de dados de opcionais para a memoria global. " + Time(), "CM")
	EndIf

Return

/*/{Protheus.doc} getNaoCarregados
Retorna os dados de registros salvos durante a carga de um determinado documento.
@author Lucas Fagundes
@since 29/08/2022
@version P12
@param  aDados, Array , Retorna por referência os dados salvos.
@return lError, Logico, Retorna a ocorrência de erros.
/*/
METHOD getNaoCarregados(aDados) CLASS MrpDados_Carga_Documentos
	Local lError := .F.
	Local oDados := Self:oCarga:oDados:oOpcionais

	oDados:getAllAList("OPC_CARGA_DOC", @aDados, @lError)

Return lError

/*/{Protheus.doc} limpaListaOpcional
Limpa a global com os opcionais de um determinado tipo de documento.
@author Lucas Fagundes
@since 03/01/2023
@version P12
@param cDoc, Caractere, Tipo de documento que irá limpar a lista de opcionais
@return Nil
/*/
METHOD limpaListaOpcional()  CLASS MrpDados_Carga_Documentos
	Local oDados := Self:oCarga:oDados:oOpcionais

	oDados:cleanAList("OPC_CARGA_DOC")

Return Nil

/*/{Protheus.doc} cargaOP
Carrega um registro de ordem de produção na memória.
@type  Static Function
@author Lucas Fagundes
@since 29/08/2022
@version P12
@param 01 aDados    , Array , Array com os dados da ordem de produção. x[1] - Filial
                                                                       x[2] - Produto
                                                                       x[3] - T4Q_DATA
                                                                       x[4] - T4Q_PATHOP
                                                                       x[5] - T4Q_SALDO
                                                                       x[6] - T4Q_IDREG
                                                                       x[7] - T4Q_OP
                                                                       x[8] - T4Q_MOPC
                                                                       x[9] - RECNO
@param 02 oDominio  , Object, Instancia da classe de dominio do MRP.
@param 03 oJsEvtEntr, Object, Json que será carregado as entradas para a classe de eventos.
@return lRet, Logico, Indica se conseguiu ou não carregar o registro na memória.
/*/
Static Function cargaOP(aDados, oDominio, oJsEvtEntr)
	Local aAux       := {}
	Local aPathOrig  := {}
	Local aRegistro  := {}
	Local cChave     := ""
	Local cChaveProd := ""
	Local cIDInterme := ""
	Local cOpcional  := ""
	Local dEntrega   := Nil
	Local lRet       := .T.
	Local nPeriodo   := 0
	Local nQtdEntPrv := 0
	Local oCarga     := oDominio:oDados:oCargaMemoria
	Local oMatriz    := oDominio:oDados:oMatriz
	Local oOpcionais := oDominio:oOpcionais
	Local lOpcional := !Empty(aDados[ARRAY_OP_POS_MOPC])

	dEntrega := ConvDatPer(aDados[ARRAY_OP_POS_FILIAL], oDominio, aDados[ARRAY_OP_POS_DATA], @nPeriodo)

	If lOpcional
		If !Empty(aDados[ARRAY_OP_POS_PATH])
			aPathOrig := {{aDados[ARRAY_OP_POS_PATH], aDados[ARRAY_OP_POS_SALDO]}}
			If aDados[ARRAY_OP_POS_PATH] == "|SEM_PATH|"
				aPathOrig[1][1] := ""
			EndIf
		Else
			oOpcionais:montaT4QPath(aDados[ARRAY_OP_POS_FILIAL], aDados[ARRAY_OP_POS_IDREG], aDados[ARRAY_OP_POS_OP], @aPathOrig)

			If Empty(aPathOrig)
				aAdd(aPathOrig, {"", aDados[ARRAY_OP_POS_SALDO]})
			EndIf
		EndIf

		If !Empty(aPathOrig[1][1])
			cOpcional  := oOpcionais:converteJsonEmID(aDados[ARRAY_OP_POS_FILIAL], aDados[ARRAY_OP_POS_MOPC], 'T4Q', aDados[ARRAY_OP_POS_RECNO], aPathOrig[1][1], @cIDInterme, .T.)
			If !Empty(cIDInterme)
				cOpcional  := cIDInterme
			EndIf
		EndIf

		nQtdEntPrv := aPathOrig[1][2]
	Else
		cOpcional := ""
		nQtdEntPrv := aDados[ARRAY_OP_POS_SALDO]
	EndIf

	cChaveProd := aDados[ARRAY_OP_POS_FILIAL] + aDados[ARRAY_OP_POS_PROD] + Iif(Empty(cOpcional),"", "|" + cOpcional)
	cChave     := DtoS(dEntrega) + cChaveProd

	//Guarda o registro na Matriz
	oMatriz:trava(cChave)
	If oMatriz:getRow(1, cChave, Nil, @aRegistro, .F., .T.)
		aRegistro[MAT_ENTPRE] += nQtdEntPrv

		If !oMatriz:updRow(1, cChave, Nil, aRegistro, .F., .T.)
			lRet := .F.
		EndIf
	Else
		aAux := Array(TAM_MAT)

		aAux[MAT_FILIAL] := aDados[ARRAY_OP_POS_FILIAL]
		aAux[MAT_DATA]   := dEntrega
		aAux[MAT_PRODUT] := aDados[ARRAY_OP_POS_PROD]
		aAux[MAT_SLDINI] := 0
		aAux[MAT_ENTPRE] := nQtdEntPrv
		aAux[MAT_SAIPRE] := 0
		aAux[MAT_SAIEST] := 0
		aAux[MAT_SALDO]  := 0
		aAux[MAT_NECESS] := 0
		aAux[MAT_QTRENT] := 0
		aAux[MAT_QTRSAI] := 0
		aAux[MAT_TPREPO] := " "
		aAux[MAT_EXPLOD] := .F.
		aAux[MAT_THREAD] := -1
		aAux[MAT_IDOPC]  := cOpcional
		aAux[MAT_DTINI]  := dEntrega

		If !oMatriz:addRow(cChave, aAux, , , , cChaveProd)
			lRet := .F.
		EndIf

		//Cria lista deste produto para registrar os periodos
		If !oMatriz:existList("Periodos_Produto_" + cChaveProd)
			oMatriz:createList("Periodos_Produto_" + cChaveProd)
		EndIf
		oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)

		If !Empty(cOpcional)
			oOpcionais:adicionaLista(aDados[ARRAY_OP_POS_FILIAL], aDados[ARRAY_OP_POS_PROD], cOpcional)
		EndIf
	EndIf
	oMatriz:destrava(cChave)

	oCarga:addLogDocumento(aDados[ARRAY_OP_POS_FILIAL], aDados[ARRAY_OP_POS_PROD], cOpcional, dEntrega, aDados[ARRAY_OP_POS_OP], "T4Q", nQtdEntPrv)

	If oDominio:oParametros["lEventLog"]
		If oJsEvtEntr[cChaveProd] == Nil
			oJsEvtEntr[cChaveProd] := {}
		EndIf

		//Adiciona {cDocumento, cItem, cAlias, nPeriodo, nQuantidade, nControle, lPossuiLog, nPriConsumo, nPrioridade, dData}
		aAdd(oJsEvtEntr[cChaveProd], {aDados[ARRAY_OP_POS_OP], "", "T4Q", nPeriodo, nQtdEntPrv, nQtdEntPrv, .F., 0, Iif(oDominio:oDados:possuiEstrutura(aDados[ARRAY_OP_POS_FILIAL], aDados[ARRAY_OP_POS_PROD]), 1, 30), aDados[ARRAY_OP_POS_DATA]})
	EndIf

	If oDominio:oParametros["lRastreiaEntradas"]
		If !oDominio:oRastreioEntradas:addEntradaPrevista(aDados[ARRAY_OP_POS_FILIAL], "OP", aDados[ARRAY_OP_POS_OP], dEntrega, aDados[ARRAY_OP_POS_PROD], nQtdEntPrv, cOpcional)
			lRet := .F.
		EndIf
	EndIf

	FwFreeArray(aPathOrig)
	aSize(aAux, 0)
	aSize(aRegistro, 0)
Return lRet

/*/{Protheus.doc} procOpcEmp
Carrega um registro de empenho para a memória.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2022
@version P12
@param 01 aDados, Array, Array com os dados do registro x[01] - cFilAux
                                                        x[02] - cProduto
                                                        x[03] - cChaveEmpe
                                                        x[04] - (cAliasQry)->RECNOOP
                                                        x[05] - (cAliasQry)->RECNOORG // Apenas ORACLE
                                                        x[06] - (cAliasQry)->T4Q_MOPC
                                                        x[07] - (cAliasQry)->T4Q_PATHOP
                                                        x[08] - (cAliasQry)->T4S_OPORIG
                                                        x[09] - (cAliasQry)->T4S_DT
                                                        x[10] - (cAliasQry)->T4Q_PROD
                                                        x[11] - (cAliasQry)->T4S_OP
                                                        x[12] - (cAliasQry)->T4S_SEQ
														x[13] - (cAliasQry)->QUANT ou (cAliasQry)->QUANT - (cAliasQry)->QSUSP // De acordo com o parâmetro "cDocumentType"
@param 02 oDominio  , Object   , Instancia da classe de dominio do MRP.
@param 03 cTicket   , Caractere, Ticket que está sendo processado no MRP.
@param 04 aPrepAglut, Array    , Retorna por referencia o array com preparado para aglutinação.
@return lRet, Logico, Indica se conseguiu ou não carregar o registro na memória.
/*/
Static Function procOpcEmp(aDados, oDominio, cTicket, aPrepAglut)
	Local aCarga     := {}
	Local aPathOrig  := {}
	Local cOpcional  := ""
	Local dEntrega   := Nil
	Local dLimite    := Nil
	Local lRet       := .T.
	Local mOpcOp     := ""
	Local mPathOp    := ""
	Local nIndOpc    := 0
	Local nPeriodo   := 0
	Local nTotOpc    := 0
	Local oOpcionais := oDominio:oOpcionais
	Local cBanco    := TcGetDB()

	dEntrega := ConvDatPer(aDados[ARRAY_OPC_EMP_FILIAL], oDominio, aDados[ARRAY_OPC_EMP_DT], @nPeriodo, .T.)
	dLimite   := oDominio:oPeriodos:ultimaDataDoMRP()

	If cBanco == "ORACLE"
		//Quando oracle, necessário posicionar nas tabelas para recuperar
		//o opcional correto, pois na query é convertido para CHAR para possibilitar o GROUP BY.
		T4Q->(dbGoTo(aDados[ARRAY_OPC_EMP_RECNOOP]))
		mOpcOp := T4Q->T4Q_MOPC

		T4Q->(dbGoTo(aDados[ARRAY_OPC_EMP_RECNOORG]))
		mPathOp := T4Q->T4Q_PATHOP
	Else
		mOpcOp  := aDados[ARRAY_OPC_EMP_MOPC]
		mPathOp := aDados[ARRAY_OPC_EMP_PATHOP]
	EndIf

	If !Empty(mPathOp) .Or. Empty(aDados[ARRAY_OPC_EMP_OPORIG])
		If Empty(mPathOp)
			T4Q->(dbGoTo(aDados[ARRAY_OPC_EMP_RECNOOP]))
			mPathOp := AllTrim(T4Q->T4Q_PATHOP)
			mPathOP += "|" + AllTrim(aDados[ARRAY_OPC_EMP_PRODEMP]) + ";" + Iif(Empty(aDados[ARRAY_OPC_EMP_SEQ]), "", AllTrim(aDados[ARRAY_OPC_EMP_SEQ]))
		EndIf

		aPathOrig := {{mPathOp, aDados[ARRAY_OPC_EMP_SAIDPRE]}}
		If mPathOp == "|SEM_PATH|"
			aPathOrig[1][1] := ""
		EndIf
	Else
		oOpcionais:montaT4SPath(aDados[ARRAY_OPC_EMP_FILIAL], aDados[ARRAY_OPC_EMP_CHAVEEMP], aDados[ARRAY_OPC_EMP_PRODEMP], @aPathOrig)
	EndIf

	nTotOPC := Len(aPathOrig)
	If nTotOPC > 0
		For nIndOpc := 1 To nTotOPC
			aCarga := Array(ARRAY_CARGA_EMP_SIZE)
			cOpcional := ""

			If !Empty(aPathOrig[nIndOpc][1])
				oOpcionais:converteJsonEmID(aDados[ARRAY_OPC_EMP_FILIAL], mOpcOp, 'T4Q', aDados[ARRAY_OPC_EMP_RECNOOP], aPathOrig[nIndOpc][1], @cOpcional, .T.)
			EndIf

			aCarga[ARRAY_CARGA_EMP_FILIAL  ] := aDados[ARRAY_OPC_EMP_FILIAL]
			aCarga[ARRAY_CARGA_EMP_PRODEMP ] := aDados[ARRAY_OPC_EMP_PRODEMP]
			aCarga[ARRAY_CARGA_EMP_CHAVEEMP] := aDados[ARRAY_OPC_EMP_CHAVEEMP]
			aCarga[ARRAY_CARGA_EMP_SEQ     ] := aDados[ARRAY_OPC_EMP_SEQ]
			aCarga[ARRAY_CARGA_EMP_DT      ] := aDados[ARRAY_OPC_EMP_DT]
			aCarga[ARRAY_CARGA_EMP_OP      ] := aDados[ARRAY_OPC_EMP_OP]
			aCarga[ARRAY_CARGA_EMP_PRODOP  ] := aDados[ARRAY_OPC_EMP_PRODOP]
			aCarga[ARRAY_CARGA_EMP_OPORIG  ] := aDados[ARRAY_OPC_EMP_OPORIG]
			aCarga[ARRAY_CARGA_EMP_QUANT   ] := aPathOrig[nIndOpc][2]
			aCarga[ARRAY_CARGA_EMP_OPC     ] := cOpcional

			If !cargaEmp(aCarga, cTicket, oDominio, @aPrepAglut)
				lRet := .F.
				Exit
			EndIf

			aSize(aCarga, 0)
		Next
	EndIf

Return lRet

/*/{Protheus.doc} cargaEmp
Função responsavel por realizar a carga de um empenho para a memória.
@type  Static Function
@author Lucas Fagundes
@since 11/10/2022
@version P21
@param 01 aDados    , Array   , Array com os dados que serão carregados.
@param 02 cTicket   , Caracter, Ticket em execução do MRP.
@param 03 oDominio  , Object  , Instância da classe de dominio do MRP.
@param 04 aPrepAglut, Array   , Retorna por referencia o array com preparado para aglutinação.
@return lRet, Logico, Retorna se carregou o registro com sucesso.
/*/
Static Function cargaEmp(aDados, cTicket, oDominio, aPrepAglut)
	Local aAux       := {}
	Local aRegistro  := {}
	Local cChave     := ""
	Local cChaveProd := ""
	Local dEntrega   := Nil
	Local dLimite    := Nil
	Local lRet       := .T.
	Local nPeriodo   := 0
	Local oCarga     := Nil
	Local oMatriz    := Nil

	dEntrega   := ConvDatPer(aDados[ARRAY_CARGA_EMP_FILIAL], oDominio, aDados[ARRAY_CARGA_EMP_DT], @nPeriodo, .T.)
	dLimite    := oDominio:oPeriodos:ultimaDataDoMRP()
	cChaveProd := aDados[ARRAY_CARGA_EMP_FILIAL] + aDados[ARRAY_CARGA_EMP_PRODEMP] + Iif(Empty(aDados[ARRAY_CARGA_EMP_OPC]),"", "|" + aDados[ARRAY_CARGA_EMP_OPC])
	cChave     := DtoS(dEntrega) + cChaveProd
	oCarga     := oDominio:oDados:oCargaMemoria
	oMatriz    := oDominio:oDados:oMatriz

	//Loga Evento 005 - Data de necessidade invalida - Data posterior ao prazo maximo do MRP
	If aDados[ARRAY_CARGA_EMP_DT] > dLimite
		If oDominio:oParametros["lEventLog"]
			oDominio:oEventos:loga("005", aDados[ARRAY_CARGA_EMP_PRODEMP], aDados[ARRAY_CARGA_EMP_DT], {cChaveProd, aDados[ARRAY_CARGA_EMP_QUANT], aDados[ARRAY_CARGA_EMP_DT], "T4S", aDados[ARRAY_CARGA_EMP_OP]}, aDados[ARRAY_CARGA_EMP_FILIAL])
		EndIf
		Return .F.
	EndIf

	//Guarda o registro na Matriz
	oMatriz:trava(cChave)
	If oMatriz:getRow(1, cChave, Nil, @aRegistro, .F., .T.)
		aRegistro[MAT_SAIPRE] += aDados[ARRAY_CARGA_EMP_QUANT]

		If !oMatriz:updRow(1, cChave, Nil, aRegistro, .F., .T.)
			lRet := .F.
		EndIf
	Else
		aAux := Array(TAM_MAT)

		aAux[MAT_FILIAL] := aDados[ARRAY_CARGA_EMP_FILIAL]
		aAux[MAT_DATA]   := dEntrega
		aAux[MAT_PRODUT] := aDados[ARRAY_CARGA_EMP_PRODEMP]
		aAux[MAT_SLDINI] := 0
		aAux[MAT_ENTPRE] := 0
		aAux[MAT_SAIPRE] := aDados[ARRAY_CARGA_EMP_QUANT]
		aAux[MAT_SAIEST] := 0
		aAux[MAT_SALDO]  := 0
		aAux[MAT_NECESS] := 0
		aAux[MAT_QTRENT] := 0
		aAux[MAT_QTRSAI] := 0
		aAux[MAT_TPREPO] := " "
		aAux[MAT_EXPLOD] := .F.
		aAux[MAT_THREAD] := -1
		aAux[MAT_IDOPC]  := aDados[ARRAY_CARGA_EMP_OPC]
		aAux[MAT_DTINI]  := dEntrega

		If oMatriz:addRow(cChave, aAux, , , , cChaveProd)
			//Cria lista deste produto para registrar os periodos
			If !oMatriz:existList("Periodos_Produto_" + cChaveProd)
				oMatriz:createList("Periodos_Produto_" + cChaveProd)
			EndIf
			oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)
		Else
			lRet := .F.
		EndIf
	EndIf
	oMatriz:destrava(cChave)

	oCarga:addLogDocumento(aDados[ARRAY_CARGA_EMP_FILIAL], aDados[ARRAY_CARGA_EMP_PRODEMP], aDados[ARRAY_CARGA_EMP_OPC], dEntrega, RTrim(aDados[ARRAY_CARGA_EMP_PRODOP])+"|"+aDados[ARRAY_CARGA_EMP_CHAVEEMP], "T4S", aDados[ARRAY_CARGA_EMP_QUANT])

	//Se roda em multi-thread, agrupa registros para delegar à outra thread
	If oDominio:oParametros["nThreads"] >= 1
		aAdd(aPrepAglut, {aDados[ARRAY_CARGA_EMP_CHAVEEMP] ,;
		                    aDados[ARRAY_CARGA_EMP_PRODEMP],;
		                    aDados[ARRAY_CARGA_EMP_OPC]    ,;
		                    aDados[ARRAY_CARGA_EMP_QUANT]  ,;
		                    nPeriodo                       ,;
		                    aDados[ARRAY_CARGA_EMP_FILIAL] ,;
		                    aDados[ARRAY_CARGA_EMP_OP]     ,;
		                    aDados[ARRAY_CARGA_EMP_SEQ]    ,;
		                    aDados[ARRAY_CARGA_EMP_OPORIG] ,;
		                    aDados[ARRAY_CARGA_EMP_DT]     })
	Else
		MrpAglPrep({{aDados[ARRAY_CARGA_EMP_CHAVEEMP]  ,;
		                aDados[ARRAY_CARGA_EMP_PRODEMP],;
		                aDados[ARRAY_CARGA_EMP_OPC]    ,;
		                aDados[ARRAY_CARGA_EMP_QUANT]  ,;
		                nPeriodo                       ,;
		                aDados[ARRAY_CARGA_EMP_FILIAL] ,;
		                aDados[ARRAY_CARGA_EMP_OP]     ,;
		                aDados[ARRAY_CARGA_EMP_SEQ]    ,;
		                aDados[ARRAY_CARGA_EMP_OPORIG] ,;
		                aDados[ARRAY_CARGA_EMP_DT] }}  ,;
		                .F., cTicket)
	EndIf

	aSize(aAux, 0)
	aSize(aRegistro, 0)
Return lRet

/*/{Protheus.doc} cargaDem
Carrega um registro de demanda na memória.
@type  Static Function
@author Lucas Fagundes
@since 31/08/2022
@version P12
@param 01 aDados, Array, Array com as informações do registro que será carregado. aDados[ARRAY_OPC_DEM_FILIAL] := cFilAux
                                                                                  aDados[ARRAY_OPC_DEM_PROD  ] := cProduto
                                                                                  aDados[ARRAY_OPC_DEM_MOPC  ] := (cAliasQry)->T4J_MOPC
                                                                                  aDados[ARRAY_OPC_DEM_RECNO ] := (cAliasQry)->R_E_C_N_O_
                                                                                  aDados[ARRAY_OPC_DEM_QUANT ] := (cAliasQry)->T4J_QUANT
                                                                                  aDados[ARRAY_OPC_DEM_ORIG  ] := (cAliasQry)->T4J_ORIGEM
                                                                                  aDados[ARRAY_OPC_DEM_IDREG ] := (cAliasQry)->T4J_IDREG
                                                                                  aDados[ARRAY_OPC_DEM_DATA  ] := dOriginal
                                                                                  aDados[ARRAY_OPC_HWE_MOPC  ] := (cAliasQry)->HWE_MOPC
                                                                                  aDados[ARRAY_OPC_HWE_RECNO ] := (cAliasQry)->RECNOHWE
                                                                                  aDados[ARRAY_OPC_HWA_MOPC  ] := (cAliasQry)->HWA_MOPC
                                                                                  aDados[ARRAY_OPC_HWA_RECNO ] := (cAliasQry)->RECNOHWA
@param 02 oDominio  , Object   , Instancia da classe de dominio do MRP.
@return lRet, Logico, Indica se conseguiu ou não carregar o registro na memória.
/*/
Static Function cargaDem(aDados, oDominio)
	Local aRegistro  := {}
	Local cChave     := ""
	Local cChaveProd := ""
	Local cIDInterme := ""
	Local cOpcional  := ""
	Local dEntrega   := Nil
	Local lRet       := .T.
	Local nPeriodo   := 0
	Local oCarga     := oDominio:oDados:oCargaMemoria
	Local oMatriz    := oDominio:oDados:oMatriz
	Local oOpcionais := oDominio:oOpcionais

	dEntrega   := ConvDatPer(aDados[ARRAY_OPC_DEM_FILIAL], oDominio, aDados[ARRAY_OPC_DEM_DATA], @nPeriodo, .T.)

	//Tratamento para quando possui o Opcional
	If !Empty(aDados[ARRAY_OPC_DEM_MOPC])
		cOpcional  := oOpcionais:converteJsonEmID(aDados[ARRAY_OPC_DEM_FILIAL], aDados[ARRAY_OPC_DEM_MOPC], 'T4J', aDados[ARRAY_OPC_DEM_RECNO], AllTrim(aDados[ARRAY_OPC_DEM_PROD]), @cIDInterme, .T.)
		If !Empty(cIDInterme)
			cOpcional := cIDInterme
		EndIf
	Else
		If oDominio:oParametros["lUsesProductIndicator"] .AND. !Empty(aDados[ARRAY_OPC_HWE_RECNO]) .And. !Empty(aDados[ARRAY_OPC_HWE_MOPC])
			cOpcional  := oOpcionais:converteJsonEmID(aDados[ARRAY_OPC_DEM_FILIAL], aDados[ARRAY_OPC_HWE_MOPC], 'HWE', aDados[ARRAY_OPC_HWE_RECNO])
		ElseIf Empty(aDados[ARRAY_OPC_HWE_RECNO]) .And. !Empty(aDados[ARRAY_OPC_HWA_MOPC])
			cOpcional  := oOpcionais:converteJsonEmID(aDados[ARRAY_OPC_DEM_FILIAL], aDados[ARRAY_OPC_HWA_MOPC], 'HWA', aDados[ARRAY_OPC_HWA_RECNO])
		Else
			cOpcional  := ""
		EndIf
	EndIf

	cChaveProd := aDados[ARRAY_OPC_DEM_FILIAL] + aDados[ARRAY_OPC_DEM_PROD] + Iif(Empty(cOpcional),"", "|" + cOpcional)
	cChave     := DtoS(dEntrega) + cChaveProd

	// Guarda o registro na Matriz
	oMatriz:trava(cChave)
	If oMatriz:getRow(1, cChave, Nil, @aRegistro, .F., .T.)
		aRegistro[MAT_SAIPRE] += aDados[ARRAY_OPC_DEM_QUANT]

		If !oMatriz:updRow(1, cChave, Nil, aRegistro, .F., .T.)
			lRet := .F.
		EndIf
	Else
		aAux := Array(TAM_MAT)

		aAux[MAT_FILIAL] := aDados[ARRAY_OPC_DEM_FILIAL]
		aAux[MAT_DATA]   := dEntrega
		aAux[MAT_PRODUT] := aDados[ARRAY_OPC_DEM_PROD]
		aAux[MAT_SLDINI] := 0
		aAux[MAT_ENTPRE] := 0
		aAux[MAT_SAIPRE] := aDados[ARRAY_OPC_DEM_QUANT]
		aAux[MAT_SAIEST] := 0
		aAux[MAT_SALDO]  := 0
		aAux[MAT_NECESS] := 0
		aAux[MAT_QTRENT] := 0
		aAux[MAT_QTRSAI] := 0
		aAux[MAT_TPREPO] := " "
		aAux[MAT_EXPLOD] := .F.
		aAux[MAT_THREAD] := -1
		aAux[MAT_IDOPC]  := cOpcional
		aAux[MAT_DTINI]  := dEntrega

		If !oMatriz:addRow(cChave, aAux, , , , cChaveProd)
			lRet := .F.
		EndIf

		//Cria lista deste produto para registrar os periodos
		If !oMatriz:existList("Periodos_Produto_" + cChaveProd)
			oMatriz:createList("Periodos_Produto_" + cChaveProd)
		EndIf
		oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)

		If !Empty(cOpcional)
			oOpcionais:adicionaLista(aDados[ARRAY_OPC_DEM_FILIAL], aDados[ARRAY_OPC_DEM_PROD], cOpcional)
		EndIf
	EndIf

	oDominio:oAglutina:prepara(aDados[ARRAY_OPC_DEM_FILIAL]                                     ,; //Código da filial
	                           "1"                                                              ,; //1 - Carga de Demandas
	                           aDados[ARRAY_OPC_DEM_ORIG]                                       ,;
	                           {aDados[ARRAY_OPC_DEM_ORIG], aDados[ARRAY_OPC_DEM_IDREG], "", ""},;
	                           aDados[ARRAY_OPC_DEM_IDREG]                                      ,;
	                           aDados[ARRAY_OPC_DEM_PROD]                                       ,;
	                           cOpcional                                                        ,;
	                           ""                                                               ,;
	                           aDados[ARRAY_OPC_DEM_QUANT]                                      ,;
	                           nPeriodo)

	oMatriz:destrava(cChave)
	oMatriz:setFlag("qtd_registros_lidos_demandas", 1, , , .T.)

	oCarga:addLogDocumento(aDados[ARRAY_OPC_DEM_FILIAL], aDados[ARRAY_OPC_DEM_PROD], cOpcional, dEntrega, aDados[ARRAY_OPC_DEM_IDREG], "T4J", aDados[ARRAY_OPC_DEM_QUANT])

	aSize(aRegistro, 0)
Return lRet

/*/{Protheus.doc} retornaQtdOpcionais
Retorna a quantidade de opcionais

@author marcelo.neumann
@since 26/01/2023
@version P12
@param  cMOpc     , caracter, opcional a ser avaliado
@return cMaxQtdOpc, caracter, indica quantos opcionais existem no maior "key"
/*/
METHOD retornaQtdOpcionais(cMOpc) CLASS MrpDados_Carga_Documentos
	Local cError     := ""
	Local nIndOpc    := 1
	Local cMaxQtdOpc := "0"
	Local nMaxQtdOpc := 0
	Local nQtdOpc    := 0
	Local nStart     := 1
	Local nLenOpc    := 0
	Local oJsonOpc   := JsonObject():New()

	If cMOpc == "[]"
		Return cMaxQtdOpc
	EndIf

	cMOpc  := '{"OPTIONAL": ' + cMOpc + '}'
	cError := oJsonOpc:fromJSON(cMOpc)
	If !Empty(cError)
		cError := oJsonOpc:fromJSON(Self:oCarga:trataJsonString(cMOpc))
	EndIf

	If Empty(cError)
		nLenOpc := Len(oJsonOpc["OPTIONAL"])
		For nIndOpc := 1 To nLenOpc
			While .T.
				nQtdOpc++
				nStart := At(";", oJsonOpc["OPTIONAL"][nIndOpc]["key"], nStart)
				If nStart == 0
					Exit
				EndIf

				nStart++
			End
			If nMaxQtdOpc < nQtdOpc
				nMaxQtdOpc := nQtdOpc
			EndIf
		Next nIndOpc
	Else
		Self:oCarga:oDados:oLogs:log(STR0081 + ProcName(0) + " - Line " + cValToChar(ProcLine(0)) + ": '" + AllTrim(cMOpc) + "'", "E") //"Erro na conversão do arquivo Json - Function "
	EndIf

	FreeObj(oJsonOpc)

Return cValToChar(nMaxQtdOpc)

/*/{Protheus.doc} cargaDocsComOpcional
Realiza as cargas dos documentos que possuem Opcionais

@author marcelo.neumann
@since 25/01/2023
@version 1
@return Nil
/*/
METHOD cargaDocsComOpcional() CLASS MrpDados_Carga_Documentos
	Local aAux       := {}
	Local aPends     := {}
	Local aPrepAglut := {}
	Local cTicket    := Self:oCarga:oDados:oParametros["ticket"]
	Local nIndex     := 0
	Local nIndDem    := 0
	Local nIndEmp    := 0
	Local nIndNivel  := 0
	Local nIndOP     := 0
	Local nIndRegs   := 0
	Local nResto     := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotChv    := 0
	Local oDominio   := Self:oCarga:oDados:oDominio
	Local oLogs      := oDominio:oDados:oLogs
	Local oJsEvtEntr := NIL
	Local oMatriz    := Self:oCarga:oDados:oMatriz
	Local oStatus    := MrpDados_Status():New(Self:oCarga:oDados:oParametros["ticket"])

	If oDominio:oParametros["lEventLog"]
		oJsEvtEntr := JsonObject():New()
	EndIf

	If !Self:getNaoCarregados(@aAux)
		oLogs:log("Opcionais -> Iniciando carga dos opcionais.", "CM")

		//Ordena pelo Nível
		aSort(aAux, , , {|x,y| x[1] < y[1] })

		For nIndNivel := 1 To Len(aAux)
			//Ordena pela quantidade de Opcionais (mais opcionais por primeiro)
			aSort(aAux[nIndNivel][2], , , {|x,y| x[2] + "_" + x[3] > y[2] + "_" + y[3]})

			//Percorre as chaves com pendencias
			nTotChv := Len(aAux[nIndNivel][2])
			For nIndex := 1 To nTotChv
				nIndRegs++

				//Checa cancelamento a cada X delegacoes
				If (nIndRegs == 1 .OR. Mod(nIndRegs, oDominio:oParametros["nX_Para_Cancel"]) == 0) .And. oStatus:getStatus("status") == "4"
					Exit
				EndIf

				aPends := aAux[nIndNivel][2][nIndex]

				If aPends[1] == "DEM"
					nIndDem++
					If !cargaDem(aPends, oDominio)
						oLogs:log(STR0055 + "T4J", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf

				ElseIf aPends[1] == "OP"
					nIndOP++
					If !cargaOP(aPends, oDominio, @oJsEvtEntr)
						oLogs:log(STR0055 + "T4Q", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf

					//Atualiza contador de registros lidos
					nResto := Mod(nIndOP, 50)
					If nResto == 0
						oMatriz:setFlag("qtd_registros_lidos_ops", 50, , , .T.)
					EndIf

				ElseIf aPends[1] == "EMP"
					nIndEmp++
					If !procOpcEmp(aPends, oDominio, cTicket, @aPrepAglut)
						oLogs:log(STR0055 + "T4S", "E") //"Erro na carga de dados da tabela para memoria: "
					EndIf

					If oDominio:oParametros["nThreads"] >= 1 .And. Mod(nIndEmp, 1000) == 0
						oDominio:oDados:oMatriz:setFlag("ExecPrepAglutina",1,,,.T.)

						PCPIPCGO(oDominio:oParametros["cSemaforoThreads"], .F., "MrpAglPrep", aPrepAglut, .T., cTicket)
						aSize(aPrepAglut,0)
					EndIf

					//Atualiza contador de registros lidos
					nResto := Mod(nIndEmp, 50)
					If nResto == 0
						oMatriz:setFlag("qtd_registros_lidos_empenhos", 50, , , .T.)
					EndIf
				EndIf

				FwFreeArray(aPends)
			Next nIndex
		Next nIndNivel

		FwFreeArray(aAux)
		Self:limpaListaOpcional()
	Endif

	//Finaliza a carga de Demandas
	If nIndDem > 0
		Self:oCarga:registraDocumentos("T4J")
		oDominio:oAglutina:incluiRastreios("1")  //1 - Carga de Demandas
	EndIf

	//Finaliza a carga de OPs
	If nIndOP > 0
		//Registra documentos (SMV) na memória global
		Self:oCarga:registraDocumentos("T4Q")

		If oDominio:oParametros["lEventLog"]
			oDominio:oEventos:incluiEntradas(oJsEvtEntr, "T4Q")
		EndIf

		If oDominio:oParametros["lRastreiaEntradas"]
			If !oDominio:oRastreioEntradas:efetivaInclusao()
				If oStatus:getStatus("status") <> "4"
					oLogs:log(STR0055 + "T4Q", "E") //"Erro na carga de dados da tabela para memoria: "
				EndIf
			EndIf
		EndIf

		nResto := Mod(nIndOP, 50)
		If nResto > 0
			oMatriz:setFlag("qtd_registros_lidos_ops", nResto, , , .T.)
		EndIf
	EndIf
	FreeObj(oJsEvtEntr)
	oJsEvtEntr := Nil

	//Finaliza a carga de Empenhos
	If nIndEmp > 0
		iF !Empty(aPrepAglut)
			MrpAglPrep(aPrepAglut, .F., cTicket)
		Endif

		//Aguarda encerrar todas as threads para incluir a rastreabilidade
		While oMatriz:getFlag("ExecPrepAglutina") <> 0
			Sleep(500)
		End

		oDominio:oAglutina:incluiRastreios("2")  //2 - Carga de Empenhos
		Self:oCarga:registraDocumentos("T4S")
		aSize(aPrepAglut,0)

		nResto := Mod(nIndEmp, 50)
		If nResto > 0
			oMatriz:setFlag("qtd_registros_lidos_empenhos", nResto, , , .T.)
		EndIf
	EndIf

	oLogs:log("Opcionais -> Tempo de carga dos Opcionais: "           + cValToChar(MicroSeconds() - nTempoIni)         , "CM")
	oLogs:log("Opcionais -> Quantidade de Opcionais: "                + cValToChar(nIndRegs)                           , "CM")
	oLogs:log("Quantidade de itens da matriz carregados em memoria: " + cValToChar(oDominio:oDados:tamanhoLista("MAT")), "CM")

Return
