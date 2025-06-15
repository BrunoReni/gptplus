#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry4020()
Query dos pendentes de apuração e relatorio R4020

@author Rafael de Paula Leme
@since 01/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry4020( cPerApu, aFil, aInfEUF, nPage, nSize, lAll )

Local cCompC1H   as Character
Local cBd		 as Character
Local cQuery     as Character
Local cQryTot    as Character
Local cAlias     as Character
Local cAliasTot  as Character
Local cSubstr    as Character
Local lHasNext   as Logical
Local lSubPgt    as Logical
Local lAgroup    as Logical
Local lRowNum    as Logical
Local nTotReg	 as Numeric
Local cFilsC20   as Character
Local cFilsLEM   as Character
Local cFilsV3U	 as Character
Local cFilsTbGer as Character
Local cIsNull    as Character
Local cQueryFin  as Character
Local nC20PRID40 as Numeric
Local nLEMPRID40 as Numeric
Local nV3UPRID40 as Numeric
Local cQryV3O    as Character

Default cPerApu := ""
Default aFil    := {}
Default aInfEUF := {}
Default nPage 	:= 1
Default nSize 	:= 20
Default lAll    := .F.

cQuery     := ""
cQryTot    := ""
cAlias	   := ""
cAliasTot  := ""
cSubstr    := ""
cQueryFin  := ""
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
lHasNext   := .F.
lSubPgt    := .F.
lAgroup    := .T.
nTotReg    := 0
cFilsC20   := TafRetFilC( "C20", aFil )
cFilsLEM   := TafRetFilC( "LEM", aFil )
cFilsV3U   := TafRetFilC( "V3U", aFil )
cFilsTbGer := '(TBGER.FILIAL)'
cIsNull    := ""
cBd		   := Upper(AllTrim(TcGetDb()))
nC20PRID40 := TamSX3("C20_PRID40")[1]
nLEMPRID40 := TamSX3("LEM_PRID40")[1]
nV3UPRID40 := TamSX3("V3U_PRID40")[1]
lRowNum    := Iif(FindFunction("TafBdVers"),TafBdVers(),.F.)
cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.D_E_L_E_T_ = ' ' AND V3O.V3O_CODIGO LIKE '20%') "

cIsNull := "COALESCE" 
cSubStr := "SUBSTRING"

cQuery += " TMP.FILIAL FILIAL, TMP.CNPJ CNPJ, TMP.NIF NIF, TMP.CODPAR CODPAR, TMP.NOME NOME, TMP.VLD VLD, TMP.VALBRUTO VALBRUTO, TMP.BASEIR BASEIR, "
cQuery += " TMP.VALIR VALIR, TMP.VALPIS VALPIS, TMP.VALCOFINS VALCOFINS, TMP.VALCSLL VALCSLL, TMP.TOTREG TOTREG "
cQuery += " FROM ( "
cQuery += " SELECT TBGER.FILIAL FILIAL, TBGER.CNPJ CNPJ, TBGER.NIF, TBGER.CODPAR,  TBGER.NOME NOME, "
cQuery += " CASE WHEN MIN(TBGER.PRID40) = ' ' "
cQuery += " THEN 'notValidated' ELSE 'validated' END VLD, "
cQuery += " SUM(TBGER.VALBRUTO) VALBRUTO, "
cQuery += " SUM(TBGER.BASEIR) BASEIR, SUM(TBGER.VALIR) VALIR, SUM(TBGER.VALPIS) VALPIS, "
cQuery += " SUM(TBGER.VALCOFINS) VALCOFINS, SUM(TBGER.VALCSLL) VALCSLL, "
cQuery += " COUNT(TBGER.FILIAL || TBGER.NUMERO) TOTREG " 

cQuery += " FROM ( "

//NOTAS FISCAIS
cQuery += " SELECT C20.C20_FILIAL FILIAL, C1H.C1H_CNPJ CNPJ, C1H.C1H_NOME NOME, C20.C20_CHVNF NUMERO, MIN(C20.C20_PRID40) PRID40, ' ' PARCELA, "
cQuery += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQuery += cIsNull + " (SUM(C30.C30_TOTAL),0) VALBRUTO, " + cIsNull + " (SUM(C35.C35_BASE),0) BASEIR, " + cIsNull + " (SUM(C35.C35_VALOR),0) VALIR, 0 VALPIS, 0 VALCOFINS, 0 VALCSLL "
cQuery += QryNfs4020(cPerApu, cFilsC20, aInfEUF, cCompC1H, lAgroup)
cQuery += " UNION ALL "

//FATURAS
cQuery += " SELECT LEM.LEM_FILIAL FILIAL, C1H.C1H_CNPJ CNPJ, C1H.C1H_NOME NOME, LEM.LEM_NUMERO NUMERO, LEM.LEM_PRID40 PRID40,' ' PARCELA, "
cQuery += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQuery += " LEM.LEM_VLBRUT VALBRUTO, V47.V47_BASECA BASEIR, V47.V47_VLTRIB VALIR, 0 VALPIS, 0 VALCOFINS, 0 VALCSLL "
cQuery += QryFat4020(cPerApu, cFilsLEM, aInfEUF, cCompC1H)
cQuery += " UNION ALL "

//PAGAMENTOS
lSubPgt := .T.
cQuery += " SELECT DISTINCT V3U.V3U_FILIAL FILIAL, C1H.C1H_CNPJ CNPJ, C1H.C1H_NOME NOME, V3U.V3U_NUMERO NUMERO, V3U.V3U_PRID40 PRID40, V3U.V3U_PARCEL PARCELA, "
cQuery += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQuery += " CASE WHEN "
cQuery += "	(SELECT SUM(LEM.LEM_VLBRUT) " + QryFat4020(cPerApu, cFilsLEM, aInfEUF, cCompC1H, lSubPgt) + " ) > 0 THEN 0 ELSE V3V.V3V_VALOR END VALBRUTO, "
cQuery += " (SELECT SUM(V46.V46_BASE)  FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE  AND   V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' ') BASEIR, "
cQuery += " (SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE  AND   V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' ') VALIR, "
cQuery += " (SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE  AND   V46.V46_IDTRIB = '000010' AND V46.D_E_L_E_T_ = ' ') VALPIS, "
cQuery += " (SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE  AND   V46.V46_IDTRIB = '000011' AND V46.D_E_L_E_T_ = ' ') VALCOFINS, "
cQuery += " (SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE  AND   V46.V46_IDTRIB = '000018' AND V46.D_E_L_E_T_ = ' ') VALCSLL "
cQuery += QryPgt4020(cPerApu, cFilsV3U, aInfEUF, cCompC1H, , cQryV3O)
cQuery += " ) TBGER "
cQuery += " GROUP BY "
cQuery += " TBGER.FILIAL, TBGER.CNPJ, TBGER.NIF, TBGER.CODPAR, TBGER.NOME ) TMP "

//Retorna o total de registros para saber se HasNext será true o false
If !lAll .And. nPage > 0 .And. nSize > 0 
	cAliasTot := GetNextAlias()
	cQryTot := " SELECT COUNT(TBTOT.FILIAL || TBTOT.CNPJ || TBTOT.NIF || TBTOT.CODPAR) QTDREG FROM  ( SELECT " + cQuery + " ) TBTOT " 
	cQryTot := ChangeQuery(cQryTot)
	TCQuery cQryTot New Alias (cAliasTot)
	nTotReg := (cAliasTot)->QTDREG
	(cAliasTot)->(DBCloseArea())
	
	lHasNext := Iif((nPage * nSize) >= nTotReg, .F., .T.)
EndIf

//Paginação utilizando ROW_NUMBER para os bancos não homologados
If !lAll .And. lRowNum .And. nPage > 0 .And. nSize > 0
	cQueryFin += " SELECT "
	cQueryFin += " TAB.LINE_NUMBER LINE_NUMBER, TAB.FILIAL FILIAL, TAB.CNPJ CNPJ, TAB.NIF NIF, TAB.CODPAR CODPAR, TAB.NOME NOME, TAB.VLD VLD, "
	cQueryFin += " TAB.VALBRUTO VALBRUTO, TAB.BASEIR BASEIR, TAB.VALIR VALIR, TAB.VALPIS, TAB.VALCOFINS VALCOFINS, TAB.VALCSLL VALCSLL, TAB.TOTREG TOTREG "
	cQueryFin += " FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY TMP.VLD, TMP.FILIAL, TMP.CNPJ) LINE_NUMBER, " + cQuery + " ) TAB "
	cQueryFin += " WHERE LINE_NUMBER BETWEEN " + cValToChar(((nPage-1)*nSize) +1) + " AND " + cValToChar(nSize*nPage) 
ElseIf !lAll .And. !lRowNum .And. nPage > 0 .And. nSize > 0
	//Paginação utilizando FETCH.
	cQueryFin += " SELECT " + cQuery + " ORDER BY TMP.VLD, TMP.FILIAL, TMP.CNPJ "
	cQueryFin += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS "
	cQueryFin += " FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
EndIf

// Query utilizada para a apuração do evento R-4020 utilizando o botão apurar todos.
If lAll	.And. nPage = 0 .And. nSize = 0
	cQueryFin += " SELECT " + cQuery + " ORDER BY TMP.VLD, TMP.FILIAL, TMP.CNPJ "
	lHasNext  := .F.
EndIf

cQueryFin := ChangeQuery( cQueryFin )
cAlias := GetNextAlias()
TCQuery cQueryFin New Alias (cAlias)

Return {cAlias, nTotReg, lHasNext}

//-------------------------------------------------------------------
/*/{Protheus.doc} QryNfs4020()

@author Rafael de Paula Leme
@since 01/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function QryNfs4020(cPerApu, cFilsC20, aInfEUF, cCompC1H, lAgroup, lReport, cCompV3X, cCompV4F)

Local cQuery     as Character
Local cDataIni   as Character
Local cDataFim   as Character
Local nC1HCNPJ   as Numeric
Local nC30CNATRE as Numeric
Local cQryV3O	 as Character

Default cPerApu  := ""
Default cFilsC20 := ""
Default aInfEUF  := {}
Default cCompC1H := ""
Default lAgroup  := .F.
Default lReport  := .F.
Default cCompV3X := ""
Default cCompV4F := ""

cQuery     := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
nC1HCNPJ   := TamSX3("C1H_CNPJ")[1]
nC30CNATRE := TamSX3("C30_CNATRE")[1]
cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.D_E_L_E_T_ = ' ' AND V3O.V3O_CODIGO LIKE '20%') "	

//NOTAS FISCAIS
cQuery += " FROM " + RetSqlName("C20") + " C20 "

//-----JOIN C1H X C20
cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
If cCompC1H == "EEE"
	cQuery += " C1H.C1H_FILIAL = C20.C20_FILIAL "
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompC1H == "CCC" .Or. ( cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf
cQuery += " AND C1H.C1H_ID     = C20.C20_CODPAR "
cQuery += " AND (( C1H.C1H_CNPJ   <> '" + Space(nC1HCNPJ) + "' AND C1H.C1H_PPES   = '2') OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ')) " 
cQuery += " AND C1H.D_E_L_E_T_ = ' ' "

if lReport
	cQuery += " LEFT JOIN " + RetSqlName("T9A") + " T9A ON "
	cQuery += " T9A.T9A_FILIAL = '" + xFilial("T9A") + "' "
	cQuery += " AND T9A.T9A_ID = C1H.C1H_IDTRIB "
	cQuery += " AND T9A.D_E_L_E_T_ = ' ' "
endif

//-----JOIN C30 X C20
cQuery += " INNER JOIN " + RetSqlName("C30") + " C30 ON "
cQuery += " C30.C30_FILIAL     = C20.C20_FILIAL "
cQuery += "	AND C30.C30_CHVNF  = C20.C20_CHVNF "
cQuery += " AND C30.C30_CNATRE <> '" + Space(nC30CNATRE) + "' "
cQuery += " AND C30.D_E_L_E_T_ = ' ' "

if lReport
	cQuery += " INNER JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
	cQuery += " AND V3O.V3O_ID = C30.C30_CNATRE "
	cQuery += " AND V3O.D_E_L_E_T_ = ' ' "
	
	cQuery += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON "
	If cCompV3X == "EEE"
		cQuery += " V3X.V3X_FILIAL = C20.C20_FILIAL "
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompV3X == "CCC" .Or. ( cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQuery += " V3X.V3X_FILIAL = '" + xFilial("V3X") + "' "
		EndIf
	EndIf
	cQuery += " AND V3X.V3X_ID = C30.C30_IFCISC "
	cQuery += " AND V3X.D_E_L_E_T_ = ' ' "
endif

//-----JOIN C35 X C30
cQuery += " LEFT JOIN " + RetSqlName("C35") + " C35 ON "
cQuery += " C35.C35_FILIAL     = C30.C30_FILIAL "
cQuery += " AND C35.C35_CHVNF  = C30.C30_CHVNF "
cQuery += " AND C35.C35_NUMITE = C30.C30_NUMITE "
cQuery += " AND C35.C35_CODITE = C30.C30_CODITE "
cQuery += " AND C35.C35_CODTRI = '000012' " //IR
cQuery += " AND C35.D_E_L_E_T_ = ' ' "

//-----JOIN LEM X C20
cQuery += " LEFT JOIN " + RetSqlName("LEM") + " LEM ON "
cQuery += " LEM.LEM_FILIAL     = C20.C20_FILIAL "
cQuery += " AND LEM.LEM_DOCORI = C20.C20_CHVNF "
cQuery += " AND LEM.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "
cQuery += " C20.C20_FILIAL     IN " + cFilsC20
cQuery += "	AND C20.C20_DTDOC  BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery += " AND C20.C20_INDOPE = '0' "
cQuery += " AND LEM.LEM_DOCORI IS NULL "
cQuery += " AND (C35.C35_BASE > 0 OR (C35.C35_CODTRI IS NULL AND C30.C30_CNATRE IN " + cQryV3O + " ))"
cQuery += " AND C20.D_E_L_E_T_ = ' ' "


if !lReport .And. lAgroup
	cQuery += " GROUP BY C20.C20_FILIAL, C1H.C1H_CNPJ, C1H.C1H_NOME, C1H.C1H_PAISEX,C1H.C1H_NIF,C1H.C1H_CODPAR, C20.C20_CHVNF "
endif

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFat4020()

@author Rafael de Paula Leme
@since 01/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function QryFat4020( cPerApu, cFilsLEM, aInfEUF, cCompC1H, lSubPgt, lReport, cCompV3X, cCompV4F )

Local cQuery      as Character
Local cDataIni    as Character
Local cDataFim    as Character
Local cFilJoinC1H as Character
Local nC1HCNPJ    as Numeric
Local nV3SIDNATR  as Numeric
Local cQryV3O	  as Character

Default cPerApu  := ""
Default cFilsLEM := ""
Default aInfEUF  := {}
Default cCompC1H := ""
Default lSubPgt := .F.
Default lReport := .F.
Default cCompV3X := ""
Default cCompV4F := ""

cQuery     := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
nC1HCNPJ   := TamSX3("C1H_CNPJ")[1]
nV3SIDNATR := TamSX3("V3S_IDNATR")[1]
cFilJoinC1H := 'LEM.LEM_FILIAL'
cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.D_E_L_E_T_ = ' ' AND V3O.V3O_CODIGO LIKE '20%') "

//FATURAS
cQuery += " FROM " + RetSqlName("LEM") + " LEM "
//----- Se nao for subquery chamando no pagamento realiza o JOIN C1H X LEM
If !lSubPgt

	cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = " + cFilJoinC1H + " "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(" + cFilJoinC1H + ",1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(" + cFilJoinC1H + ",1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompC1H == "CCC" .Or. ( cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
		EndIf
	EndIf

	cQuery += " AND C1H.C1H_ID     = LEM.LEM_IDPART "
	cQuery += " AND (( C1H.C1H_CNPJ   <> '" + Space(nC1HCNPJ) + "' AND C1H.C1H_PPES   = '2') OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ')) " 
	cQuery += " AND C1H.D_E_L_E_T_ = ' ' "
EndIf
if lReport
	cQuery += " LEFT JOIN " + RetSqlName("T9A") + " T9A ON "
	cQuery += " T9A.T9A_FILIAL = '" + xFilial("T9A") + "' "
	cQuery += " AND T9A.T9A_ID = C1H.C1H_IDTRIB "
	cQuery += " AND T9A.D_E_L_E_T_ = ' ' "
endif

cQuery += " INNER JOIN " + RetSqlName("V3S") + " V3S ON "
cQuery += " V3S.V3S_FILIAL      = LEM.LEM_FILIAL "
cQuery += " AND V3S.V3S_ID      = LEM.LEM_ID "
cQuery += " AND V3S.V3S_IDPART  = LEM.LEM_IDPART "
cQuery += " AND V3S.V3S_NUMFAT  = LEM.LEM_NUMERO "
cQuery += " AND V3S.V3S_IDNATR  <> '" + Space(nV3SIDNATR) + "' "
cQuery += " AND V3S.D_E_L_E_T_  = ' ' "

if lReport
	cQuery += " INNER JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
	cQuery += " AND V3O.V3O_ID = V3S.V3S_IDNATR "
	cQuery += " AND V3O.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName("T9E") + " T9E ON "
	cQuery += " T9E.T9E_FILIAL = LEM.LEM_FILIAL "
	cQuery += " AND T9E.T9E_ID = LEM.LEM_ID "
	cQuery += " AND T9E.T9E_CNATRE = V3S.V3S_IDNATR "
	cQuery += " AND T9E.T9E_CODTRI = '000012' "
	cQuery += " AND T9E.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName("V4F") + " V4F ON "
	If cCompV4F == "EEE"
		cQuery += " V4F.V4F_FILIAL = V3S.V3S_FILIAL "
	Else
		If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3S.V3S_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3S.V3S_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQuery += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
		EndIf
	EndIf
	cQuery += " AND V4F.V4F_ID = V3S.V3S_IDPROC "
	cQuery += " AND V4F.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON "
	If cCompV3X == "EEE"
		cQuery += " V3X.V3X_FILIAL = LEM.LEM_FILIAL " 
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompV3X == "CCC" .Or. ( cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQuery += " V3X.V3X_FILIAL = '" + xFilial("V3X") + "' "
		EndIf
	EndIf
	cQuery += " AND V3X.V3X_ID = V3S.V3S_IFCISC "
	cQuery += " AND V3X.D_E_L_E_T_ = ' ' "
endif

cQuery += " LEFT JOIN " + RetSqlName("V47") + " V47 ON "
cQuery += " V47.V47_FILIAL     = V3S.V3S_FILIAL "
cQuery += " AND V47.V47_ID     = V3S.V3S_ID "
cQuery += " AND V47.V47_IDPART = V3S.V3S_IDPART "
cQuery += " AND V47.V47_NUMFAT = V3S.V3S_NUMFAT "
cQuery += " AND V47.V47_IDNATR = V3S.V3S_IDNATR "
cQuery += " AND V47.V47_DECTER = V3S.V3S_DECTER "
cQuery += " AND V47.V47_IDTRIB = '000012' " //IR
cQuery += " AND V47.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "

If lSubPgt == .T.
	cQuery += " LEM.LEM_FILIAL = V3U.V3U_FILIAL "
	cQuery += " AND LEM.LEM_NUMERO = V3U.V3U_NUMERO "
	cQuery += " AND LEM.LEM_DTEMIS = V3U.V3U_DTPAGT "
Else	
	cQuery += " LEM.LEM_FILIAL IN " + cFilsLEM
	cQuery += " AND LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
EndIf

cQuery += " AND LEM.LEM_NATTIT       = '0' "
cQuery += " AND LEM.D_E_L_E_T_       = ' ' "
cQuery += " AND (V47.V47_BASECA > 0 OR (V47.V47_IDTRIB IS NULL AND V3S.V3S_IDNATR IN " + cQryV3O + " ))"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} QryPgt4020()

@author Rafael de Paula Leme
@since 01/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function QryPgt4020( cPerApu, cFilsV3U, aInfEUF, cCompC1H, lReport, cCompV3X, cCompV4F )

Local cQuery	 as Character
Local cDataIni	 as Character
Local cDataFim	 as Character
Local nC1HCNPJ   as Numeric
Local nV3VCNATRE as Numeric
Local cQryV3O	 as Character

Default cPerApu  := ""
Default cFilsV3U := ""
Default cCompC1H := ""
Default aInfEUF  := {}
Default lReport  := .F.
Default cCompV3X := .F.
Default cCompV4F := ''

cQuery     := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
nC1HCNPJ   := TamSX3("C1H_CNPJ")[1]
nV3VCNATRE := TamSX3("V3V_CNATRE")[1]
cQryV3O    := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE (V3O.V3O_CODIGO LIKE '20%' OR V3O.V3O_TRIB = '8') AND V3O.D_E_L_E_T_ = ' ') "

cQuery += " FROM " + RetSqlName("V3U") + " V3U "

//-----JOIN C1H X V3U
cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
If cCompC1H == "EEE"
	cQuery += " C1H.C1H_FILIAL = V3U.V3U_FILIAL "
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3U.V3U_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3U.V3U_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompC1H == "CCC" .Or. ( cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf
cQuery += " AND C1H.C1H_ID     = V3U.V3U_IDPART "
cQuery += " AND (( C1H.C1H_CNPJ   <> '" + Space(nC1HCNPJ) + "' AND C1H.C1H_PPES   = '2') OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ')) " 
cQuery += " AND C1H.D_E_L_E_T_ = ' ' "

if lReport
	cQuery += " LEFT JOIN " + RetSqlName("T9A") + " T9A ON "
	cQuery += " T9A.T9A_FILIAL = '" + xFilial("T9A") + "' "
	cQuery += " AND T9A.T9A_ID = C1H.C1H_IDTRIB "
	cQuery += " AND T9A.D_E_L_E_T_ = ' ' "
endif

cQuery += " INNER JOIN " + RetSqlName("V3V") + " V3V ON "
cQuery += " V3V.V3V_FILIAL     = V3U.V3U_FILIAL "
cQuery += " AND V3V.V3V_ID     = V3U.V3U_ID "
cQuery += " AND V3V.V3V_CNATRE <> '" + Space(nV3VCNATRE) + "' "
cQuery += " AND V3V.D_E_L_E_T_ = ' ' "

cQuery += " INNER JOIN " + RetSqlName("V3O")  + " V3O ON "
cQuery += " V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND "
cQuery += " V3O.V3O_ID = V3V.V3V_CNATRE AND V3O.D_E_L_E_T_ = ' ' "

if lReport
	cQuery += " LEFT JOIN " + RetSqlName("V4F") + " V4F ON "
	If cCompV4F == "EEE"
		cQuery += " V4F.V4F_FILIAL = V3V.V3V_FILIAL "
	Else
		If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQuery += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
		EndIf
	EndIf
	cQuery += " AND V4F.V4F_ID = V3V.V3V_IDPROC "
	cQuery += " AND V4F.D_E_L_E_T_ = ' ' "
	
	cQuery += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON "
	If cCompV3X == "EEE"
		cQuery += " V3X.V3X_FILIAL = V3V.V3V_FILIAL "
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompV3X == "CCC" .Or. ( cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQuery += " V3X.V3X_FILIAL = '" + xFilial("V3X") + "' "
		EndIf
	EndIf
	cQuery += " AND V3X.V3X_ID = V3V.V3V_IFCISC "
	cQuery += " AND V3X.D_E_L_E_T_ = ' ' "
endif

cQuery += " LEFT JOIN " + RetSqlName("V46") + " V46 ON "
cQuery += " V46.V46_FILIAL = V3V.V3V_FILIAL "
cQuery += " AND V46.V46_ID = V3V.V3V_ID "
cQuery += " AND V46.V46_IDNAT = V3V.V3V_CNATRE "
cQuery += " AND V46.V46_IDTRIB IN ('000010','000011','000018','000028','000029','000030') "
cQuery += " AND V46.D_E_L_E_T_ = ' ' "

cQuery += " WHERE "
cQuery += " V3U.V3U_FILIAL IN " + cFilsV3U
cQuery += " AND V3U.V3U_DTPAGT BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
cQuery += " AND (V46.V46_BASE > 0 "
cQuery += " OR (V46.V46_IDTRIB IS NULL AND V3V.V3V_CNATRE IN " + cQryV3O + " ))"
cQuery += " AND V3U.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0024020()
Monta Json de acordo com a query

@author Rafael de Paula Leme
@since 04/11/2022
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Function WS0024020(aApurac, oEstruct, cPeriodo, cEvent, aFiliais, lAll, oValidationError)

local cAlias       as character
local cFil		   as character
local cStatus	   as character
local cCNPJ		   as character
local nTSintetic   as numeric
local lhasNext     as logical

Default aApurac  := {'',0,.F.}
Default oEstruct := Nil
Default cPeriodo := '' 
Default cEvent 	 := ''
Default aFiliais := {}
Default lAll     := .F.
Default oValidationError := Nil

cAlias     := aApurac[1]
lhasNext   := aApurac[3]
nTSintetic := 0
cStatus    := ""
cFil	   := ""
cCNPJ      := ""

If oValidationError == Nil
	oValidationError := JsonObject():New()
Endif
if oValidationError["registryKey"] == Nil
	oValidationError["registryKey"] := {}
endif

If !(cAlias)->(EOF())
	(cAlias)->(DbGoTop())
	While !(cAlias)->(EOF())

		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])
		cFil 	:= (cAlias)->FILIAL
		cCNPJ	:= (cAlias)->CNPJ
		cStatus := Iif(Lower(Alltrim((cAlias)->VLD))=="notvalidated","notValidated","validated")
		oEstruct["eventDetail"][nTSintetic]["status"]          := cStatus
		oEstruct["eventDetail"][nTSintetic]["branchId"]        := (cAlias)->FILIAL
		oEstruct["eventDetail"][nTSintetic]["providerCNPJ"]    := (cAlias)->CNPJ
		oEstruct["eventDetail"][nTSintetic]["key"]			   := (cAlias)->CNPJ
		oEstruct["eventDetail"][nTSintetic]["providerName"]    := AllTrim(EncodeUTF8((cAlias)->NOME)) 
		oEstruct["eventDetail"][nTSintetic]["totalDocs"]       := (cAlias)->TOTREG
		oEstruct["eventDetail"][nTSintetic]["grossAmount"]     := (cAlias)->VALBRUTO
		oEstruct["eventDetail"][nTSintetic]["incomeTaxBase"]   := (cAlias)->BASEIR
		oEstruct["eventDetail"][nTSintetic]["incomeTaxAmount"] := (cAlias)->VALIR
		oEstruct["eventDetail"][nTSintetic]["pisValue"]        := (cAlias)->VALPIS
		oEstruct["eventDetail"][nTSintetic]["cofinsValue"]     := (cAlias)->VALCOFINS
		oEstruct["eventDetail"][nTSintetic]["csllValue"]       := (cAlias)->VALCSLL
		oEstruct["eventDetail"][nTSintetic]["nif"]    		   := (cAlias)->NIF
		oEstruct["eventDetail"][nTSintetic]["providerCode"]    := (cAlias)->CODPAR
		oEstruct["eventDetail"][nTSintetic]["errors"]          := 'errors'
		If Len(oValidationError["registryKey"]) > 0 // Chave de busca do erro da apuração			
			oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"] := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
		EndIf		
		(cAlias)->(dbSkip())
	EndDo
Else
	aadd(oEstruct["eventDetail"],JsonObject():New())
	oEstruct["eventDetail"] := {}
Endif

oEstruct['hasNext'] := lhasNext

(cAlias)->(DBCloseArea())

Return oEstruct

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Denis Souza /Jose Felipe
@since 04/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)

local cKeyError as character
local nX        as numeric
local cKey		as character
cKeyError       := ""
cKey	        := ""
nX              := 1

If !Empty(alltrim(oEstruct["key"]))  
	cKey := alltrim(oEstruct["key"])
ElseIf !Empty(alltrim(oEstruct["nif"]))
	cKey := alltrim(oEstruct["nif"])
ElseIf !Empty(alltrim(oEstruct["providerCode"]))
	cKey := alltrim(oEstruct["providerCode"])
EndIf	

For nX := 1 to Len(oValidationError["registryKey"])
	if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
		if alltrim(oValidationError["registryKey"][nX]["id"]) == cKey
			cKeyError := oValidationError["registryKey"][nX]["error"]
		endif
	endif
Next nX

return ( cKeyError )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WsRel4020
Função responsável por retornar a query para geração dp arquivo CSV

@author Denis Souza / Jose Riquelme
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
function WsRel4020( cPeriod, cCompC1H, cCompC1G, aInfEUF, cFilsC20, cFilsLEM, cFilsV3U, cBanco, cCompV3X, cCompV4F )

local cQry 		as character
local lReport 	as logical
local lAgroup   as logical
local lSubPgt	as logical
local cDataIni  as Character
local cDataFim  as Character

default cPeriod  := ''
default cCompC1H := ''
default cCompC1G := ''
default aInfEUF  := {}
default cFilsC20 := ''
default cFilsLEM := ''
default cFilsV3U := ''
default cBanco   := ''
default cCompV3X := ''
default cCompV4F := ''

lReport := .T.
lAgroup := .F.
lSubPgt := .F.
cQry    := ''

cDataIni   := cPeriod + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )

//Campos Gerais do Relatorio
cQry += TafGerField()

//Bloco com campos provenientes das notas
cQry += TafNtField(cBanco,aInfEUF,cCompC1G)
cQry += QryNfs4020( cPeriod, cFilsC20, aInfEUF, cCompC1H, lAgroup, lReport, cCompV3X, cCompV4F )
cQry += "GROUP BY "
cQry += "C20.C20_FILIAL,C1H.C1H_CNPJ,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,T9A.T9A_DESCRI,C1H.C1H_NOME,C20.C20_FCISCP,V3X.V3X_CNPJ,C1H.C1H_PAISEX, "
cQry += "C20.C20_CHVNF,C20.C20_NUMDOC,C30.C30_NUMITE,C20.C20_SERIE,C20.C20_DTDOC,V3O.V3O_CODIGO,V3O.V3O_DESCR,C35.C35_ALIQ "

cQry += " UNION ALL "
//Bloco com campos provenientes das faturas
cQry += TafFtField(cDataIni,cDataFim,cCompV4F,aInfEUF,cCompC1G,cBanco)
cQry += QryFat4020( cPeriod, cFilsLEM, aInfEUF, cCompC1H, lSubPgt, lReport, cCompV3X, cCompV4F )
cQry += " GROUP BY LEM.LEM_FILIAL,C1H.C1H_CNPJ,C1H.C1H_PAISEX,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,T9A.T9A_DESCRI, "
cQry += " LEM.LEM_FCISCP,LEM.LEM_NUMERO,LEM.LEM_DTEMIS,LEM.LEM_ID,LEM.LEM_VLBRUT,LEM.LEM_IDPART,V3X.V3X_CNPJ, "
cQry += " V4F.V4F_INDRRA, V4F.V4F_NRPROC,V4F.V4F_CNPJOR,V3S.V3S_IDNATR,V3O.V3O_CODIGO,V3S.V3S_IDPROC,V3O.V3O_DESCR,V47.V47_ALIQ "
cQry += " ) TMPFAT "

cQry += " UNION ALL "
//Bloco com campos provenientes dos pagamentos
cQry += TafPgtField(cDataIni, cDataFim, cBanco,cCompV4F, cCompC1H, aInfEUF, cCompC1G, cFilsLEM)
cQry += QryPgt4020( cPeriod, cFilsV3U, aInfEUF, cCompC1H, lReport, cCompV3X, cCompV4F )
cQry += " ) TMPPGT "

cQry += ") TBGER ORDER BY FILIAL, CNPJ, NUMERO, CODNAT, NUMITE, SERIE_PARC "

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Colunas Gerais do Relatorio R4020

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafGerField()

local cQry as Character

cQry := "SELECT " 
cQry += "TBGER.FILIAL FILIAL "		//01 Filial (02 Descrição da Filial, 03 CNPJ da Filial )
cQry += ",TBGER.CNPJ CNPJ "			//04 CNPJ Participante
cQry += ",TBGER.CODPAR "			//05 Código Participante
cQry += ",TBGER.INDNIF "			//06 Indicativo NIF
cQry += ",TBGER.NIF "				//07 Numero NIF
cQry += ",TBGER.FORMATRIBUTACAO "	//08 Forma Tributação
cQry += ",TBGER.NOME NOME "			//09 Nome Beneficiário
cQry += ",TBGER.INDFCISCP "			//10 Indicativo de FCI/SCP
cQry += ",TBGER.CNPJFCISCP "		//11 CNPJ da FCI/SCP 
cQry += ",TBGER.INDRRA "			//12 Informação de RRA ou Processo Judicial
cQry += ",TBGER.NRRRAPJD "			//13 Número de Inscrição do Processo RRA/Processo Judicial
cQry += ",TBGER.CNPJOR "			//14 CNPJ Origem Recurso
cQry += ",TBGER.CUSTADV "			//15 Total de Custas com Advogados
cQry += ",TBGER.CUSTJUD "			//16 Total de Custas Judiciais
cQry += ",TBGER.TIPO "				//17 Tipo
cQry += ",TBGER.SERIE_PARC "		//18 Série Documento
cQry += ",TBGER.NUMERO "			//19 Número Documento
cQry += ",TBGER.NUMITE "			//   Número item
cQry += ",TBGER.DTEMISPGT "			//20 Data Emissão/Pagamento
cQry += ",TBGER.ID "				//21 ID do Documento
cQry += ",TBGER.CODNAT "			//22 Natureza de Rendimento
cQry += ",TBGER.DSCNAT "			//   Descricao Natureza
cQry += ",TBGER.VALBRUTO "			//23 Valor do Documento
cQry += ",TBGER.BASEIR "			//24 Base de Cálculo IR
cQry += ",TBGER.ALIQIR "			//25 Alíquota do IR
cQry += ",TBGER.VALIR "				//26 Valor do IR
cQry += ",TBGER.BASEPIS "			//27 Base de Cálculo PIS
cQry += ",TBGER.ALIQPIS "			//28 Alíquota do PIS
cQry += ",TBGER.VALPIS "			//29 Valor do PIS
cQry += ",TBGER.BASECOFINS "		//30 Base de Cálculo COFINS
cQry += ",TBGER.ALIQCOFINS "		//31 Alíquota do COFINS
cQry += ",TBGER.VALCOFINS "			//32 Valor do COFINS
cQry += ",TBGER.BASECSLL "			//33 Base de Cálculo CSLL
cQry += ",TBGER.ALIQCSLL "			//34 Alíquota do CSLL
cQry += ",TBGER.VALCSLL "			//35 Valor do CSLL
cQry += ",TBGER.VBSIR "				//36 Valor Base Suspensa IR	
cQry += ",TBGER.VRSIR "				//37 Valor Retido Suspenso IR	
cQry += ",TBGER.VBSPIS "			//38 Valor Base Suspensa PIS	
cQry += ",TBGER.VRSPIS "			//39 Valor Retido Suspenso PIS	
cQry += ",TBGER.VBSCOFINS "			//40 Valor Base Suspensa COFINS	
cQry += ",TBGER.VRSCOFINS "			//41 Valor Retido Suspenso COFINS	
cQry += ",TBGER.VBSCSLL "			//42 Valor Base Suspensa CSLL	
cQry += ",TBGER.VRSCSLL "			//43 Valor Retido Suspenso CSLL
cQry += ",TBGER.NPROCREF "			//44 Número do Processo Referenciado

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes das notas fiscais que se enquadram no R4020

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafNtField(cBanco,aInfEUF,cCompC1G)

local cQry as Character

default cBanco   := ''
default aInfEUF  := {}
default cCompC1G := ''

cQry := "FROM ( SELECT "
cQry += "C20.C20_FILIAL FILIAL "
cQry += ",C1H.C1H_CNPJ CNPJ "
cQry += ",C1H.C1H_CODPAR CODPAR "
cQry += ",C1H.C1H_INDNIF INDNIF "
cQry += ",C1H.C1H_NIF NIF "
cQry += ",COALESCE(T9A.T9A_DESCRI, '') FORMATRIBUTACAO "
cQry += ",C1H.C1H_NOME NOME "
cQry += ",C20.C20_FCISCP INDFCISCP "
cQry += ",COALESCE(V3X.V3X_CNPJ, '') CNPJFCISCP "
cQry += ",'' INDRRA "
cQry += ",'' NRRRAPJD "
cQry += ",'' CNPJOR "
cQry += ",0 CUSTADV "
cQry += ",0 CUSTJUD "
cQry += ",C20.C20_CHVNF ID "
cQry += ",'NFS' TIPO "
cQry += ",C20.C20_NUMDOC NUMERO "
cQry += ",C30.C30_NUMITE NUMITE "
cQry += ",C20.C20_SERIE SERIE_PARC "
cQry += ",C20.C20_DTDOC DTEMISPGT "
cQry += ",V3O.V3O_CODIGO CODNAT "
cQry += ",V3O.V3O_DESCR DSCNAT "
cQry += ",COALESCE(SUM(C30.C30_TOTAL), 0) VALBRUTO "
cQry += ",COALESCE(SUM(C35.C35_BASE), 0) BASEIR "
cQry += ",COALESCE(C35.C35_ALIQ, 0) ALIQIR "
cQry += ",COALESCE(SUM(C35.C35_VALOR), 0) VALIR "
cQry += ",0 BASEPIS "
cQry += ",0 ALIQPIS "
cQry += ",0 VALPIS "
cQry += ",0 BASECOFINS "
cQry += ",0 ALIQCOFINS "
cQry += ",0 VALCOFINS "
cQry += ",0 BASECSLL "
cQry += ",0 ALIQCSLL "
cQry += ",0 VALCSLL "
cQry += ",COALESCE((SELECT SUM(T9Q.T9Q_BSSUSP) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF  AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.D_E_L_E_T_ = ' ' AND T9Q.T9Q_CODTRI = '000012'),0) VBSIR "
cQry += ",COALESCE((SELECT SUM(T9Q.T9Q_VALSUS) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF  AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.D_E_L_E_T_ = ' ' AND T9Q.T9Q_CODTRI = '000012'),0) VRSIR "
cQry += ",0 VBSPIS "
cQry += ",0 VRSPIS "
cQry += ",0 VBSCOFINS "
cQry += ",0 VRSCOFINS "
cQry += ",0 VBSCSLL "
cQry += ",0 VRSCSLL "

cQry += ",COALESCE(( "
If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("T9Q") + " T9Q INNER JOIN " + RetSqlName("C1G") + " C1G ON "
If cCompC1G == "EEE"
	cQry += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL "
Else
	If cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9Q.T9Q_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1G == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9Q.T9Q_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompC1G == "CCC" .Or. ( cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "C1G.C1G_FILIAL = '" + xFilial("C1G") + "' "
	EndIf
EndIf
cQry += "AND C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "
cQry += " WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
cQry += " AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.D_E_L_E_T_ = ' ' AND T9Q.T9Q_CODTRI = '000012' "
if cBanco == "ORACLE"
	cQry += " AND ROWNUM <= 1 "
ElseIf cBanco == "DB2"
	cQry += "FETCH FIRST 1 ROWS ONLY "
Elseif cBanco $ "POSTGRES|DB2"
	cQry += " LIMIT 1 "
Endif
cQry += " ),'') NPROCREF "

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes das faturas que se enquadram no R4020

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafFtField(cDataIni, cDataFim, cCompV4F, aInfEUF, cCompC1G, cBanco)

Local cQry as Character

Default cDataIni := ''
Default cDataFim := ''
Default cCompV4F := ''
Default aInfEUF  := {}
Default cCompC1G := ''
Default cBanco   := ''

cQry := " SELECT "
cQry += " TMPFAT.FILIAL "
cQry += " ,TMPFAT.CNPJ "
cQry += " ,TMPFAT.CODPAR "
cQry += " ,TMPFAT.INDNIF "
cQry += " ,TMPFAT.NIF "
cQry += " ,TMPFAT.FORMATRIBUTACAO "
cQry += " ,TMPFAT.NOME NOME "
cQry += " ,TMPFAT.INDFCISCP "
cQry += " ,TMPFAT.CNPJFCISCP "
cQry += " ,TMPFAT.INDRRA "
cQry += " ,TMPFAT.NRRRAPJD "
cQry += " ,TMPFAT.CNPJOR "

cQry += " ,COALESCE(( SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN  " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += " AND V4GADV.V4G_ID = V4F.V4F_ID AND V4GADV.V4G_TPDESP = '1' AND V4GADV.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GADV.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = TMPFAT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(TMPFAT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(TMPFAT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += " AND V4F.V4F_ID = TMPFAT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' ' ), 0) CUSTADV "

cQry += " ,COALESCE(( SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN  " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += " AND V4GJUD.V4G_ID = V4F.V4F_ID AND V4GJUD.V4G_TPDESP = '2' AND V4GJUD.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GJUD.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = TMPFAT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(TMPFAT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(TMPFAT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += " AND V4F.V4F_ID = TMPFAT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' ' ), 0) CUSTJUD "

cQry += " ,TMPFAT.ID "
cQry += " ,TMPFAT.TIPO "
cQry += " ,TMPFAT.NUMERO "
cQry += " ,' ' NUMITE "
cQry += " ,TMPFAT.SERIE_PARC "
cQry += " ,TMPFAT.DTEMISPGT "
cQry += " ,TMPFAT.CODNAT "
cQry += " ,TMPFAT.DSCNAT "
cQry += " ,TMPFAT.VALBRUTO "
cQry += " ,TMPFAT.BASEIR "
cQry += " ,TMPFAT.ALIQIR "
cQry += " ,TMPFAT.VALIR "
cQry += " ,0 BASEPIS "
cQry += " ,0 ALIQPIS "
cQry += " ,0 VALPIS "
cQry += " ,0 BASECOFINS "
cQry += " ,0 ALIQCOFINS "
cQry += " ,0 VALCOFINS "
cQry += " ,0 BASECSLL "
cQry += " ,0 ALIQCSLL "
cQry += " ,0 VALCSLL "
cQry += " ,TMPFAT.VBSIR "
cQry += " ,TMPFAT.VRSIR "
cQry += " ,0 VBSPIS "
cQry += " ,0 VRSPIS "
cQry += " ,0 VBSCOFINS "
cQry += " ,0 VRSCOFINS "
cQry += " ,0 VBSCSLL "
cQry += " ,0 VRSCSLL "
cQry += " ,TMPFAT.NPROCREF "

cQry += "FROM ( "

cQry += " SELECT "
cQry += " LEM.LEM_FILIAL FILIAL "
cQry += " ,C1H.C1H_CNPJ CNPJ "
cQry += " ,C1H.C1H_CODPAR CODPAR "
cQry += " ,C1H.C1H_INDNIF INDNIF "
cQry += " ,C1H.C1H_NIF NIF "
cQry += " ,COALESCE(T9A.T9A_DESCRI, '') FORMATRIBUTACAO "
cQry += " ,C1H.C1H_NOME NOME "
cQry += " ,LEM.LEM_FCISCP INDFCISCP "
cQry += " ,COALESCE(V3X.V3X_CNPJ, '') CNPJFCISCP "
cQry += " ,V3S.V3S_IDPROC IDRRAPJUD "
cQry += " ,COALESCE(V4F.V4F_INDRRA, '') INDRRA "
cQry += " ,COALESCE(V4F.V4F_NRPROC, '') NRRRAPJD "
cQry += " ,COALESCE(V4F.V4F_CNPJOR, '') CNPJOR "
cQry += " ,'FAT' TIPO "
cQry += " ,LEM.LEM_NUMERO NUMERO "
cQry += " ,' ' SERIE_PARC "
cQry += " ,LEM.LEM_DTEMIS DTEMISPGT "
cQry += " ,LEM.LEM_ID ID "
cQry += " ,V3S.V3S_IDNATR IDNATR "
cQry += " ,V3O.V3O_CODIGO CODNAT "
cQry += " ,V3O.V3O_DESCR DSCNAT "
cQry += " ,LEM.LEM_VLBRUT VALBRUTO "
cQry += " ,COALESCE(SUM(V47.V47_BASECA),0) BASEIR "
cQry += " ,COALESCE(V47.V47_ALIQ, 0) ALIQIR "
cQry += " ,COALESCE(SUM(V47.V47_VLTRIB),0) VALIR "

cQry += ",COALESCE(( "
If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("T9E") + " T9E INNER JOIN " + RetSqlName("C1G") + " C1G ON "
If cCompC1G == "EEE"
	cQry += " C1G.C1G_FILIAL = T9E.T9E_FILIAL "
Else
	If cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9E.T9E_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1G == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9E.T9E_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompC1G == "CCC" .Or. ( cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "C1G.C1G_FILIAL = '" + xFilial("C1G") + "' "
	EndIf
EndIf
cQry += "AND C1G.C1G_ID = T9E.T9E_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "
cQry += "WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = '000012' AND T9E.D_E_L_E_T_ = ' ' "
if cBanco == "ORACLE"
	cQry += " AND ROWNUM <= 1 "
Elseif cBanco $ "POSTGRES|DB2"
	cQry += " LIMIT 1 "
Endif
cQry += " ),'') NPROCREF "

cQry += ",COALESCE((SELECT SUM(T9E.T9E_BSSUSP) FROM " + RetSqlName("T9E") + " T9E "
cQry += "WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = '000012' AND T9E.D_E_L_E_T_ = ' '),0) VBSIR "

cQry += ",COALESCE((SELECT SUM(T9E.T9E_VALSUS) FROM " + RetSqlName("T9E") + " T9E "
cQry += "WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = '000012' AND T9E.D_E_L_E_T_ = ' '),0) VRSIR "

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes dos pagamentos que se enquadram no R4020

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafPgtField( cDataIni, cDataFim, cBanco, cCompV4F, cCompC1H, aInfEUF, cCompC1G, cFilsLEM)

Local cQry 	   	 as Character
Local nC1HCNPJ 	 as Numeric
Local nV3SIDNATR as Numeric

Default cDataIni := ''
Default cDataFim := ''
Default cBanco   := ''
Default cCompV4F := ''
Default aInfEUF  := {}
Default cCompC1G := ''
Default cFilsLEM := ''

nC1HCNPJ := TamSX3("C1H_CNPJ")[1]
nV3SIDNATR := TamSX3("V3S_IDNATR")[1]

cQry := " SELECT TMPPGT.FILIAL "
cQry += " ,TMPPGT.CNPJ "
cQry += " ,TMPPGT.CODPAR "
cQry += " ,TMPPGT.INDNIF "
cQry += " ,TMPPGT.NIF
cQry += " ,TMPPGT.FORMATRIBUTACAO "
cQry += " ,TMPPGT.NOME NOME "
cQry += " ,TMPPGT.INDFCISCP "
cQry += " ,TMPPGT.CNPJFCISCP "
cQry += " ,TMPPGT.INDRRA "
cQry += " ,TMPPGT.NRRRAPJD "
cQry += " ,TMPPGT.CNPJOR "

cQry += " ,COALESCE(( SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += " AND V4GADV.V4G_ID = V4F.V4F_ID AND V4GADV.V4G_TPDESP = '1' AND V4GADV.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GADV.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = TMPPGT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(TMPPGT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(TMPPGT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += " AND V4F.V4F_ID = TMPPGT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' ' ), 0) CUSTADV "

cQry += " ,COALESCE((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += " AND V4GJUD.V4G_ID = V4F.V4F_ID AND V4GJUD.V4G_TPDESP = '2' AND V4GJUD.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GJUD.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = TMPPGT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(TMPPGT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(TMPPGT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += " AND V4F.V4F_ID = TMPPGT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' ' ), 0) CUSTJUD "

cQry += " ,TMPPGT.ID "
cQry += " ,TMPPGT.TIPO "
cQry += " ,TMPPGT.NUMERO "
cQry += " ,TMPPGT.NUMITE "
cQry += " ,TMPPGT.SERIE_PARC "
cQry += " ,TMPPGT.DTEMISPGT "
cQry += " ,TMPPGT.CODNAT "
cQry += " ,TMPPGT.DSCNAT "
cQry += " ,TMPPGT.VALBRUTO "
cQry += " ,TMPPGT.BASEIR "
cQry += " ,TMPPGT.ALIQIR "
cQry += " ,TMPPGT.VALIR "
cQry += " ,TMPPGT.BASEPIS "
cQry += " ,TMPPGT.ALIQPIS "
cQry += " ,TMPPGT.VALPIS "
cQry += " ,TMPPGT.BASECOFINS "
cQry += " ,TMPPGT.ALIQCOFINS "
cQry += " ,TMPPGT.VALCOFINS  "
cQry += " ,TMPPGT.BASECSLL "
cQry += " ,TMPPGT.ALIQCSLL "
cQry += " ,TMPPGT.VALCSLL "
cQry += " ,TMPPGT.VBSIR "
cQry += " ,TMPPGT.VRSIR "
cQry += " ,TMPPGT.VBSPIS "
cQry += " ,TMPPGT.VRSPIS "
cQry += " ,TMPPGT.VBSCOFINS "
cQry += " ,TMPPGT.VRSCOFINS "
cQry += " ,TMPPGT.VBSCSLL "
cQry += " ,TMPPGT.VRSCSLL "
cQry += " ,TMPPGT.NPROCREF "

cQry += " FROM ( SELECT "
cQry += "  DISTINCT V3U.V3U_FILIAL FILIAL "
cQry += " ,C1H.C1H_CNPJ CNPJ "
cQry += " ,C1H.C1H_CODPAR CODPAR "
cQry += " ,C1H.C1H_INDNIF INDNIF "
cQry += " ,C1H.C1H_NIF NIF "
cQry += " ,COALESCE(T9A.T9A_DESCRI, '') FORMATRIBUTACAO "
cQry += " ,C1H.C1H_NOME NOME "
cQry += " ,V3U.V3U_FCISCP INDFCISCP "
cQry += " ,COALESCE(V3X.V3X_CNPJ, '') CNPJFCISCP "
cQry += " ,V3V.V3V_IDPROC IDRRAPJUD "
cQry += " ,COALESCE(V4F.V4F_INDRRA, '') INDRRA "
cQry += " ,COALESCE(V4F.V4F_NRPROC, '') NRRRAPJD "
cQry += " ,COALESCE(V4F.V4F_CNPJOR, '') CNPJOR "
cQry += " ,'PGT' TIPO "
cQry += " ,V3U.V3U_NUMERO NUMERO "
cQry += " ,' ' NUMITE "
cQry += " ,V3U.V3U_PARCEL SERIE_PARC "
cQry += " ,V3U.V3U_DTPAGT DTEMISPGT "
cQry += " ,V3U.V3U_ID ID "
cQry += " ,V3O.V3O_CODIGO CODNAT "
cQry += " ,V3O.V3O_DESCR DSCNAT "

cQry += " ,CASE WHEN ( "
cQry += " SELECT SUM(LEM.LEM_VLBRUT)" + QryFat4020(Left(cDataIni,6), cFilsLEM, aInfEUF, cCompC1H, .T.) + " ) > 0 THEN 0 ELSE V3V.V3V_VALOR END VALBRUTO "
cQry += " ,COALESCE((SELECT SUM(V46.V46_BASE) FROM "   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' ' ),0) BASEIR "
cQry += " ,COALESCE((SELECT V46.V46_ALIQ FROM " 	   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' ' ),0) ALIQIR "
cQry += " ,COALESCE((SELECT SUM(V46.V46_VALOR) FROM "  + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' ' ),0) VALIR "
cQry += " ,COALESCE((SELECT SUM(V46.V46_BASE) FROM "   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000010' AND V46.D_E_L_E_T_ = ' ' ),0) BASEPIS "
cQry += " ,COALESCE((SELECT V46.V46_ALIQ FROM " 	   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000010' AND V46.D_E_L_E_T_ = ' ' ),0) ALIQPIS "
cQry += " ,COALESCE((SELECT SUM(V46.V46_VALOR) FROM "  + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000010' AND V46.D_E_L_E_T_ = ' ' ),0) VALPIS "
cQry += " ,COALESCE((SELECT SUM(V46.V46_BASE) FROM "   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000011' AND V46.D_E_L_E_T_ = ' ' ),0) BASECOFINS "
cQry += " ,COALESCE((SELECT V46.V46_ALIQ FROM " 	   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000011' AND V46.D_E_L_E_T_ = ' ' ),0) ALIQCOFINS "
cQry += " ,COALESCE((SELECT SUM(V46.V46_VALOR) FROM "  + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000011' AND V46.D_E_L_E_T_ = ' ' ),0) VALCOFINS "
cQry += " ,COALESCE((SELECT SUM(V46.V46_BASE) FROM "   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000018' AND V46.D_E_L_E_T_ = ' ' ),0) BASECSLL "
cQry += " ,COALESCE((SELECT V46.V46_ALIQ FROM " 	   + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000018' AND V46.D_E_L_E_T_ = ' ' ),0) ALIQCSLL "
cQry += " ,COALESCE((SELECT SUM(V46.V46_VALOR) FROM "  + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000018' AND V46.D_E_L_E_T_ = ' ' ),0) VALCSLL

cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000028' AND V4H.D_E_L_E_T_ = ' '),0) VBSIR "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000028' AND V4H.D_E_L_E_T_ = ' '),0) VRSIR "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000010' AND V4H.D_E_L_E_T_ = ' '),0) VBSPIS "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000010' AND V4H.D_E_L_E_T_ = ' '),0) VRSPIS "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000011' AND V4H.D_E_L_E_T_ = ' '),0) VBSCOFINS "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000011' AND V4H.D_E_L_E_T_ = ' '),0) VRSCOFINS "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000018' AND V4H.D_E_L_E_T_ = ' '),0) VBSCSLL "
cQry += " ,COALESCE((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000018' AND V4H.D_E_L_E_T_ = ' '),0) VRSCSLL "

cQry += ",COALESCE(( "
If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("V4H") + " V4H INNER JOIN " + RetSqlName("C1G") + " C1G ON "
If cCompC1G == "EEE"
	cQry += " C1G.C1G_FILIAL = V4H.V4H_FILIAL "
Else
	If cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V4H.V4H_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1G == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V4H.V4H_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompC1G == "CCC" .Or. ( cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "C1G.C1G_FILIAL = '" + xFilial("C1G") + "' "
	EndIf
EndIf
cQry += "AND C1G.C1G_ID = V4H.V4H_IDPROC AND C1G.D_E_L_E_T_ = ' ' "
cQry += "WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
cQry += " AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.D_E_L_E_T_ = ' ' AND V4H.V4H_IDTRIB IN ( '000010','000011','000018','000028','000029','000030') "
if cBanco == "ORACLE"
	cQry += " AND ROWNUM <= 1 "
ElseIf cBanco == "DB2"
	cQry += "FETCH FIRST 1 ROWS ONLY "
Elseif cBanco $ "POSTGRES"
	cQry += " LIMIT 1 "
Endif
cQry += " ),'') NPROCREF "

Return cQry
