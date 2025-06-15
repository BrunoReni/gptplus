#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry4010()
Query dos pendentes de apuração e relatorio R4010

@author Denis Souza
@since 25/10/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry4010( cPerApu, aFil, aInfEUF, nPage, nSize, lAll )

Local cFiliais	 As Character
Local cCompC1H   As Character
Local cDataIni   As Character
Local cDataFim   As Character
Local cBd		 As Character
Local cQuery     As Character
Local cQryRel    As Character
Local cQryTot    As Character
Local cIsNull	 As Character
Local cTopRow    As Character
Local cQueryFin  As Character
Local lHasNext   As Logical
Local lRowNum    as Logical
Local nTotReg    As numeric
Local nV3SIdNatR As numeric
Local nC30CNatRe As numeric
Local nV3VCNatRe As numeric
Local nTmPrId40  As numeric

Default cPerApu := ""
Default aFil    := {}
Default aInfEUF := {}
Default nPage 	:= 1
Default nSize 	:= 20
Default lAll    := .F.

cQuery     := ""
cQryRel    := ""
cQryTot    := ""
cIsNull    := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
cAlias	   := ""
cAliasTot  := ""
cTopRow    := ""
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cBd		   := Upper(AllTrim(TcGetDb()))
cFiliais   := TafRetFilC( "C20", aFil )
lHasNext   := .F.
nTotReg    := 0
nV3SIdNatR := TamSX3("V3S_IDNATR")[1]
nC30CNatRe := TamSX3("C30_CNATRE")[1]
nV3VCNatRe := TamSX3("V3V_CNATRE")[1]
nTmPrId40  := TamSX3("C20_PRID40")[1]
lRowNum    := Iif(FindFunction("TafBdVers"),TafBdVers(),.F.)

cIsNull := "COALESCE"

cQuery := " TMP.FILIAL, TMP.CPF, TMP.NIF, TMP.CODPAR, TMP.QTDDOC, TMP.VLBRUT, TMP.BASECA, TMP.VLTRIB, TMP.NOME, TMP.VLDED, TMP.VLD FROM ( "

cQuery += " SELECT TBGER.FILIAL, TBGER.CPF, TBGER.NIF, TBGER.CODPAR, COUNT(TBGER.DOCTO) QTDDOC, SUM(TBGER.VLBRUT) VLBRUT, SUM(TBGER.BASECA) BASECA, SUM(TBGER.VLTRIB) VLTRIB, SUM(TBGER.VLDED) VLDED "
cQuery += ", " + QryFilNome(cBd,cCompC1H,aInfEUF)
cQuery += " , CASE WHEN MIN( TBGER.PRID40 ) = ' ' THEN 'notValidated' ELSE 'validated' END VLD "

cQuery += " FROM ( "

//Importante: O cQryRel sera utilizado para o relatorio analitico, posteriormente o conteudo eh agregado no cQuery
cQryRel := " SELECT DISTINCT 'FAT' ROTINA, LEM.LEM_FILIAL FILIAL, LEM.LEM_NUMERO DOCTO, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQryRel += cIsNull + " (V3S.V3S_VALOR, 0) VLBRUT, " + cIsNull + " (V47.V47_BASECA, 0) BASECA, " + cIsNull + "(V47.V47_VLTRIB, 0) VLTRIB, "
cQryRel += "( SELECT SUM( " + cIsNull + " (V4L.V4L_VLRDED, 0) ) FROM " + RetSqlName("V4L") + " V4L WHERE "
cQryRel += " V4L.V4L_FILIAL = LEM.LEM_FILIAL AND V4L.V4L_ID = LEM.LEM_ID AND V4L.V4L_IDPART = LEM.LEM_IDPART AND V4L.V4L_NUMFAT = LEM.LEM_NUMERO "
cQryRel += " AND V4L.V4L_IDNATR = V3S.V3S_IDNATR AND V4L.V4L_DECTER = V3S.V3S_DECTER AND V4L.V4L_IDTRIB = V47.V47_IDTRIB AND V4L.D_E_L_E_T_ = ' ') VLDED, "
cQryRel += " LEM.LEM_PRID40 PRID40 "
cQryRel += QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,cFiliais,cDataIni,cDataFim,nTmPrId40)

cQryRel += " UNION "

cQryRel += " SELECT 'NFS' ROTINA, C20.C20_FILIAL FILIAL, C20.C20_CHVNF DOCTO, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' )  THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQryRel += cIsNull + " (SUM(C30.C30_TOTAL),0) VLBRUT, " + cIsNull + " (SUM(C35.C35_BASE),0) BASECA, " + cIsNull + " (SUM(C35.C35_VALOR),0) VLTRIB, "
cQryRel += " ( SELECT SUM( " + cIsNull + " (V4C.V4C_VLRDED,0) ) VLDED FROM " + RetSqlName("V4C") + " V4C "
cQryRel += " WHERE  V4C.V4C_FILIAL = C20.C20_FILIAL AND V4C.V4C_CHVNF = C20.C20_CHVNF AND V4C.D_E_L_E_T_ = ' ') VLDED, "
cQryRel += " MIN(C20.C20_PRID40) PRID40 "
cQryRel += QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,cFiliais,cDataIni,cDataFim,nTmPrId40)

cQryRel += " UNION "

cQryRel += " SELECT DISTINCT 'PGT' ROTINA, V3U.V3U_FILIAL FILIAL, V3U.V3U_NUMERO DOCTO, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQryRel += cIsNull + " (V3V.V3V_VALOR, 0) VLBRUT, " + cIsNull + " (V46.V46_BASE, 0) BASECA, " + cIsNull + " (V46.V46_VALOR, 0) VLTRIB, "
cQryRel += " ( SELECT SUM( " + cIsNull + "(V4I.V4I_VLRDED,0) ) FROM " + RetSqlName("V4I") + " V4I WHERE V4I.V4I_FILIAL = V3U.V3U_FILIAL "
cQryRel += " AND V4I.V4I_ID = V3U.V3U_ID AND V4I.V4I_IDNAT = V3V.V3V_CNATRE AND V4I.V4I_IDTRIB = V46.V46_IDTRIB AND V4I.D_E_L_E_T_ = ' ') VLDED, "
cQryRel += " V3U.V3U_PRID40 PRID40 "
cQryRel += QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,cFiliais,cDataIni,cDataFim,nTmPrId40)

cQry4010 := cQryRel

cQryRel += " UNION "

cQryRel += " SELECT DISTINCT 'PLS' ROTINA, V4B.V4B_FILIAL FILIAL, V4B.V4B_ID DOCTO, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
cQryRel += " 0 VLBRUT, 0 BASECA, 0 VLTRIB, 0 VLDED, V4B.V4B_PRID40 PRID40 "
cQryRel += " FROM " + RetSqlName("V4B") + " V4B "
cQryRel += QryFilReemb(cCompC1H,aInfEUF,cFiliais,cDataIni,cDataFim,cQry4010,nTmPrId40)
cQuery  += cQryRel
cQuery  += " ) TBGER GROUP BY TBGER.FILIAL, TBGER.CPF, TBGER.NIF, TBGER.CODPAR "
cQuery  += " ) TMP "

If !lAll .And. nPage > 0 .And. nSize > 0 //paginacao e contagem considerando os dados ja agrupados
	cAliasTot := GetNextAlias()
	cQryTot := " SELECT COUNT(TBTOT.FILIAL || TBTOT.CPF || TBTOT.NIF || TBTOT.CODPAR ) QTDREG FROM ( SELECT " + cQuery + " ) TBTOT " 
	If !("DB2" $ cBd )
		cQryTot := ChangeQuery(cQryTot)
	endif
	TCQuery cQryTot New Alias (cAliasTot)
	nTotReg := (cAliasTot)->QTDREG
	(cAliasTot)->(DBCloseArea())
	lHasNext := Iif((nPage * nSize) >= nTotReg, .F., .T.)
EndIf

If !lAll .And. lRowNum .And. nPage > 0 .And. nSize > 0
	cQueryFin := "SELECT TAB.LINE_NUMBER,TAB.VLD,TAB.FILIAL,TAB.CPF,TAB.NIF,TAB.CODPAR,TAB.QTDDOC,TAB.VLBRUT,TAB.BASECA,TAB.VLTRIB,TAB.NOME,TAB.VLDED "
	cQueryFin += "FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY TMP.VLD, TMP.FILIAL, TMP.CPF ) LINE_NUMBER, " + cQuery + " ) TAB "
	cQueryFin += "WHERE TAB.LINE_NUMBER BETWEEN " + cValToChar(((nPage-1)*nSize) +1) + " AND " + cValToChar(nSize*nPage)
ElseIf !lAll .And. !lRowNum .And. nPage > 0 .And. nSize > 0
	cQueryFin := "SELECT " + cQuery + " ORDER BY TMP.VLD, TMP.FILIAL, TMP.CPF "
	cQueryFin += "OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS "
	cQueryFin += "FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
EndIf

If lAll	.And. nPage == 0 .And. nSize == 0
	cQueryFin := " SELECT " + cQuery + " ORDER BY TMP.VLD, TMP.FILIAL, TMP.CPF "
	lHasNext  := .F.
EndIf

If !("DB2" $ cBd )
	cQueryFin := ChangeQuery( cQueryFin )
EndIf
cAlias := GetNextAlias()
TCQuery cQueryFin New Alias (cAlias)

Return {cAlias, nTotReg, lHasNext}

//-------------------------------------------------------------------
/*/{Protheus.doc} TafJoinC1H()
Tratamento de Join com a C1H

@author Denis Souza
@since 26/10/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function TafJoinC1H( cCompC1H , aInfEUF, cCmpJoin )

Local cString    := ''
Default cCompC1H := ''
Default aInfEUF  := {}
Default cCmpJoin := ''

If cCompC1H == "EEE"
	cString := " C1H.C1H_FILIAL = " + cCmpJoin
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cString := " LTRIM(RTRIM(SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) = LTRIM(RTRIM(SUBSTRING(" + cCmpJoin + ", 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cString := " LTRIM(RTRIM(SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + "))) = LTRIM(RTRIM(SUBSTRING(" +cCmpJoin + ", 1," + cValToChar(aInfEUF[1]) + "))) "
	//Necessario pois a filial faz parte do indice do bd, tratamento totalmente compartilhado ou sem gestão de empresa com compartilhado apenas no modo (filial).
	ElseIf cCompC1H == "CCC" .Or. ( cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cString := " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0024010()
Monta Json de acordo com a query

@author Denis Souza
@since 25/10/2022
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Function WS0024010(aApurac, oEstruct, cPeriodo, cEvent, aFiliais, lAll, oValidationError)

local cAliasR4010  As character
local cBranch	   As character
local cFil		   As character
local cStatus	   As character
local cCPF		   As character
local nTSintetic   As numeric
local lhasNext     As logical
local lValid	   As logical
local lEmptyPrId40 As logical
local aFilCPF	   As Array

Default aApurac  := {'',0,.F.}
Default oEstruct := Nil
Default cPeriodo := '' 
Default cEvent 	 := ''
Default aFiliais := {}
Default lAll     := .F.
Default oValidationError := Nil

cAliasR4010 := aApurac[1]
lhasNext    := aApurac[3]
cBranch		:= ""
nTSintetic 	:= 0

lEmptyPrId40 := .T.
lValid  	 := .F.
aFilCPF      := {}

if oValidationError == Nil
	oValidationError := JsonObject():New()
endif
if oValidationError["registryKey"] == Nil
	oValidationError["registryKey"] := {}
endif

if !(cAliasR4010)->(EOF())

	(cAliasR4010)->(DbGoTop())

	While !(cAliasR4010)->(EOF())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])
		cFil 	:= (cAliasR4010)->FILIAL
		cCPF	:= (cAliasR4010)->CPF
		cStatus := iif(Lower(Alltrim((cAliasR4010)->VLD))=="notvalidated","notValidated","validated")
		oEstruct["eventDetail"][nTSintetic]["status"]          := cStatus
		oEstruct["eventDetail"][nTSintetic]["branchId"]        := cFil
		oEstruct["eventDetail"][nTSintetic]["providerCPF"]     := cCPF
		oEstruct["eventDetail"][nTSintetic]["key"]			   := cCPF 
		oEstruct["eventDetail"][nTSintetic]["providerName"]    := alltrim(EncodeUTF8((cAliasR4010)->NOME)) 
		oEstruct["eventDetail"][nTSintetic]["totalDocs"]       := (cAliasR4010)->QTDDOC
		oEstruct["eventDetail"][nTSintetic]["grossAmount"]     := (cAliasR4010)->VLBRUT
		oEstruct["eventDetail"][nTSintetic]["incomeTaxAmount"] := (cAliasR4010)->VLTRIB
		oEstruct["eventDetail"][nTSintetic]["incomeTaxBase"]   := (cAliasR4010)->(BASECA+VLDED)
		oEstruct["eventDetail"][nTSintetic]["providerCode"]    := (cAliasR4010)->CODPAR
		oEstruct["eventDetail"][nTSintetic]["nif"]    		   := (cAliasR4010)->NIF

		oEstruct["eventDetail"][nTSintetic]["errors"]          := 'errors'
		If Len(oValidationError["registryKey"]) > 0 // Chave de busca do erro da apuração			
			oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"] := KeyError( oEstruct["eventDetail"][nTSintetic] , oValidationError )
		EndIf
		(cAliasR4010)->(dbSkip())
	EndDo
else
	aadd(oEstruct["eventDetail"],JsonObject():New())
	oEstruct["eventDetail"] := {}
endif

oEstruct['hasNext'] := lhasNext

(cAliasR4010)->(DBCloseArea())

aSize(aFilCPF,0)
aFilCPF := {}

Return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilNome        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilNome(cBd,cCompC1H,aInfEUF)

Local cQry  as character
Local cTop  as character
Local cTopRow as character

Default cBd      := ''
Default cCompC1H := ''
Default aInfEUF  := {}

cQry 	:= ""
cTop	:= ""
cTopRow := ""

Iif( cBd $ "INFORMIX", cTop += " C1H_NOME FROM (SELECT FIRST 1 C1H.C1H_NOME ", cTop += "")  
Iif( cBd $ "INFORMIX", cTopRow += " ) ", cTopRow += "")  

cQry := " ( SELECT "
If cBd $ "ORACLE|POSTGRES|DB2"
	cTop += " C1H.C1H_NOME "
	If cBd $ "ORACLE"
		cTopRow := " AND ROWNUM <= 1 "
	ElseIf cBd $ "POSTGRES|DB2"
		cTopRow := " LIMIT 1 "
	EndIf
ElseIf cBd $ "MSSQL7|MSSQL"
	cTop += " TOP 1 C1H.C1H_NOME "
Endif

cQry += cTop
cQry += " FROM " + RetSqlName("C1H") + " C1H WHERE "
cQry += TafJoinC1H( cCompC1H , aInfEUF, "TBGER.FILIAL" )
cQry += " AND ((TBGER.CPF <> ' ' AND C1H.C1H_CPF = TBGER.CPF AND C1H.C1H_PPES = '1' ) "
cQry += " OR ( TBGER.CODPAR <> ' ' AND C1H.C1H_CODPAR = TBGER.CODPAR AND C1H.C1H_PEEXTE = '1') "
cQry += " OR (TBGER.NIF <> ' ' AND C1H.C1H_NIF = TBGER.NIF AND C1H.C1H_PEEXTE = '1')) "
cQry += " AND C1H.D_E_L_E_T_ = ' ' "
          
If cBd $ "ORACLE|INFORMIX|DB2"
	cQry += cTopRow
EndIf
If cBd $ "POSTGRES"
	cQry += " ORDER BY C1H.C1H_FILIAL " + cTopRow
EndIf

cQry += " ) NOME "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilFat        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,cFiliais,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F)

Local cQry := ''

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default nV3SIdNatR := 0
Default cFiliais   := ''		
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default cCompV3X   := ''
Default cCompV4F   := ''

cQry := " FROM " + RetSqlName("LEM") + " LEM "
cQry += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
cQry += TafJoinC1H( cCompC1H , aInfEUF, "LEM.LEM_FILIAL" )
cQry += " AND C1H.C1H_ID = LEM.LEM_IDPART AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1')  OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) AND C1H.D_E_L_E_T_ = ' ' "
                                          
if lReport
	cQry += " LEFT JOIN " + RetSqlName("T9A") + " T9A ON T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "
endif

cQry += " INNER JOIN " + RetSqlName("V3S") + " V3S ON "
cQry += " V3S.V3S_FILIAL = LEM.LEM_FILIAL AND V3S.V3S_ID = LEM.LEM_ID AND V3S.V3S_IDPART = LEM.LEM_IDPART AND V3S.V3S_NUMFAT = LEM.LEM_NUMERO "
cQry += " AND V3S.V3S_IDNATR <> '" + Space(nV3SIdNatR) + "' AND V3S.D_E_L_E_T_ = ' ' "

if lReport
	cQry += " INNER JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND V3O.V3O_ID = V3S.V3S_IDNATR AND V3O.D_E_L_E_T_ = ' ' "

	cQry += " LEFT JOIN " + RetSqlName("V4F") + " V4F ON " //T160 ( V4F ) Despesas Processuais e RRA
	If cCompV4F == "EEE"
		cQry += " V4F.V4F_FILIAL = V3S.V3S_FILIAL "
	Else
		If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3S.V3S_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
		ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3S.V3S_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
		ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQry += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
		EndIf
	EndIf
	cQry += " AND V4F.V4F_ID = V3S.V3S_IDPROC AND V4F.D_E_L_E_T_ = ' ' "

	cQry += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON " //T159 ( V3X ) FCI e SCP
	If cCompV3X == "EEE"
		cQry += " V3X.V3X_FILIAL = LEM.LEM_FILIAL " 
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
		ElseIf cCompV3X == "CCC" .Or. ( cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQry += " V3X.V3X_FILIAL = '" + xFilial("V3X") + "' "
		EndIf
	EndIf
	cQry += " AND V3X.V3X_ID = V3S.V3S_IFCISC AND V3X.D_E_L_E_T_ = ' ' "
endif

cQry += " INNER JOIN " + RetSqlName("V47") + " V47 ON " //T154AH ( V47 ) Tributos do pagamento
cQry += " V47.V47_FILIAL = V3S.V3S_FILIAL AND V47.V47_ID = LEM.LEM_ID AND V47.V47_IDPART = LEM.LEM_IDPART AND V47.V47_NUMFAT = LEM.LEM_NUMERO AND V47.V47_IDNATR = V3S.V3S_IDNATR "
cQry += " AND V47.V47_DECTER = V3S.V3S_DECTER AND V47.V47_IDTRIB = '000012' AND V47.D_E_L_E_T_ = ' ' "

cQry += " WHERE LEM.LEM_FILIAL IN " + cFiliais + " AND LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND LEM.LEM_NATTIT = '0' AND LEM.D_E_L_E_T_ = ' ' "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilNota        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,cFiliais,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F)

Local cQry := ''

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default nC30CNatRe := 0
Default cFiliais   := ''
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default cCompV3X   := ''
Default cCompV4F   := ''

cQry := "FROM " + RetSqlName("C20") + " C20 " //T013 ( C20 ) Documento Fiscal
cQry += "INNER JOIN " + RetSqlName("C1H") + " C1H ON " //Participantes
cQry += TafJoinC1H( cCompC1H , aInfEUF, "C20.C20_FILIAL" )
cQry += " AND C1H.C1H_ID = C20.C20_CODPAR AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1')  OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) AND C1H.D_E_L_E_T_ = ' ' "
                                          
if lReport
	cQry += "LEFT JOIN " + RetSqlName("T9A") + " T9A ON " //Forma de tributacao
	cQry += "T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "
endif

cQry += " INNER JOIN " + RetSqlName("C30") + " C30 ON " //T015 ( C30 ) Itens da nota fiscal natureza rendimento
cQry += " C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.C30_CNATRE <> '" + Space(nC30CNatRe) + "' AND C30.D_E_L_E_T_ = ' ' "

if lReport
	cQry += " INNER JOIN " + RetSqlName("V3O") + " V3O ON " //Natureza de operacao
	cQry += " V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
	cQry += " AND V3O.V3O_ID = C30.C30_CNATRE "
	cQry += " AND V3O.D_E_L_E_T_ = ' ' "

	cQry += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON " //T159 ( V3X  FCI e SCP
	If cCompV3X == "EEE"
		cQry += " V3X.V3X_FILIAL = C20.C20_FILIAL "
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
		ElseIf cCompV3X == "CCC" .Or. ( cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQry += " V3X.V3X_FILIAL = '" + xFilial("V3X") + "' "
		EndIf
	EndIf
	cQry += " AND V3X.V3X_ID = C30.C30_IFCISC "
	cQry += " AND V3X.D_E_L_E_T_ = ' ' "
endif

cQry += " INNER JOIN " + RetSqlName("C35") + " C35 ON " //T015AE ( C35 ) Tributos do Item
cQry += " C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF = C30.C30_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.C35_CODTRI = '000012' AND C35.D_E_L_E_T_ = ' ' "

cQry += " LEFT JOIN " + RetSqlName("LEM") + " LEM ON " //T154 ( LEM ) Fatura
cQry += " LEM.LEM_FILIAL = C20.C20_FILIAL AND LEM.LEM_DOCORI = C20.C20_CHVNF AND LEM.D_E_L_E_T_ = ' ' "

cQry += " WHERE C20.C20_FILIAL IN " + cFiliais + " AND C20.C20_INDOPE = '0' AND C20.C20_DTDOC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND LEM.LEM_DOCORI IS NULL AND C20.D_E_L_E_T_ = ' ' "

if !lReport
	cQry += " GROUP BY C20.C20_FILIAL, C20.C20_CHVNF, C1H.C1H_CPF, C1H.C1H_PAISEX, C1H.C1H_NIF , C1H.C1H_CODPAR "
endif

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilPgto        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,cFiliais,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F)

Local cQry := ''

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default nV3VCNatRe := 0
Default cFiliais   := ''
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default cCompV3X   := ''
Default cCompV4F   := ''

cQry := "FROM " + RetSqlName("V3U") + " V3U " //T158 ( V3U ) Pagamento das Parcelas

cQry += "INNER JOIN " + RetSqlName("V3V") + " V3V ON " //T158AA ( V3V ) Natureza Rendimento
cQry += "V3V.V3V_FILIAL = V3U.V3U_FILIAL AND V3V.V3V_ID = V3U.V3U_ID AND V3V.V3V_CNATRE <> '" + Space(nV3VCNatRe) + "' AND V3V.D_E_L_E_T_ = ' ' "

if lReport
	cQry += " LEFT JOIN " + RetSqlName("V4F") + " V4F ON " //T160 ( V4F ) Despesas Processuais e RRA
	If cCompV4F == "EEE"
		cQry += " V4F.V4F_FILIAL = V3V.V3V_FILIAL "
	Else
		If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQry += " V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
		EndIf
	EndIf
	cQry += " AND V4F.V4F_ID = V3V.V3V_IDPROC "
	cQry += " AND V4F.D_E_L_E_T_ = ' ' "

	cQry += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON " //T159 ( V3X ) FCI e SCP
	If cCompV3X == "EEE"
		cQry += " V3X.V3X_FILIAL = V3V.V3V_FILIAL "
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
		ElseIf cCompV3X == "CCC" .Or. ( cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
			cQry += " V3X.V3X_FILIAL = '" + xFilial("V3X") + "' "
		EndIf
	EndIf
	cQry += " AND V3X.V3X_ID = V3V.V3V_IFCISC "
	cQry += " AND V3X.D_E_L_E_T_ = ' ' "
endif

cQry += "INNER JOIN " + RetSqlName("V3O")  + " V3O ON " //Natureza
cQry += "V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND V3O.V3O_ID = V3V.V3V_CNATRE AND V3O.D_E_L_E_T_ = ' ' "

cQry += "INNER JOIN " + RetSqlName("C1H") + " C1H ON " //Participantes
cQry += TafJoinC1H( cCompC1H , aInfEUF, "V3U.V3U_FILIAL" )
cQry += " AND C1H.C1H_ID = V3U.V3U_IDPART AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1') OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) AND C1H.D_E_L_E_T_ = ' ' "

if lReport
	cQry += "LEFT JOIN " + RetSqlName("T9A") + " T9A ON " //Forma de tributacao
	cQry += "T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "
endif

cQry += "LEFT JOIN " + RetSqlName("V46") + " V46 ON " //T158AB ( V46 ) Tributos Pagamento
cQry += "V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3U.V3U_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' ' "

cQry += " WHERE V3U.V3U_FILIAL IN " + cFiliais + " AND V3U.V3U_DTPAGT BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND V3U.D_E_L_E_T_ = ' ' "
cQry += " AND (V46.V46_IDTRIB IS NOT NULL OR (V46.V46_IDTRIB IS NULL AND V3O.V3O_TRIB = '8'))"

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilReemb        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilReemb(cCompC1H,aInfEUF,cFiliais,cDataIni,cDataFim,cQry4010,nTmPrId40,lReport)

Local cQry := ''

Default cCompC1H  := ''
Default aInfEUF	  := {}
Default cFiliais  := ''
Default cDataIni  := ''
Default cDataFim  := ''
Default cQry4010  := ''
Default nTmPrId40 := 0
Default lReport   := .F.

if lReport
	cQry += " FROM " + RetSqlName("V4B") + " V4B "
endif

cQry += "INNER JOIN " + RetSqlName("C1H") + " C1H ON "

cQry += TafJoinC1H( cCompC1H , aInfEUF, "V4B.V4B_FILIAL" )
cQry += " AND C1H.C1H_ID = V4B.V4B_IDPART AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1') OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) AND C1H.D_E_L_E_T_ = ' ' "

if lReport
	cQry += "LEFT JOIN " + RetSqlName("T9A") + " T9A ON "
	cQry += "T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "

	cQry += "LEFT JOIN " + RetSqlName("V3R") + " V3R ON "
	cQry += "V3R.V3R_FILIAL = '" + xFilial("V3R") + "' AND V3R.V3R_ID = V4B.V4B_IDPART AND V3R.V3R_CODIGO = V4B.V4B_CODDEP AND V3R.D_E_L_E_T_ = ' ' "
endif

cQry += "WHERE V4B.V4B_FILIAL IN " + cFiliais + " AND V4B.V4B_DTPGTO BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND V4B.D_E_L_E_T_ = ' ' "
cQry += "AND C1H.C1H_CPF IN ( SELECT DISTINCT TB2.CPF FROM ( " + cQry4010 + " ) TB2 ) "

Return cQry

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
local cKey 		as character
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
/*/{Protheus.doc} WsRel4010
Função responsável por retornar a query para geração do relatorio em planilha

@author Denis Souza
@since 10/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
function WsRel4010(cPeriod,cCompC1G,cCompC1H,aInfEUF,cFilsC20,cFilsLEM,cFilsV3U,cFilsV4B,cBanco,cCompV3X,cCompV4F,oTabTemp)

local cQry 		  as character
local cQuery4010  as character
local cDataIni    as Character
local cDataFim    as Character
local nV3SIdNatR  as numeric
local nC30CNatRe  as numeric
local nV3VCNatRe  as numeric
local nTmPrId40   as numeric
local lReport     as logical

default cPeriod  := ''
default cCompC1G := ''
default cCompC1H := ''
default aInfEUF  := {}
default cFilsC20 := ''
default cFilsLEM := ''
default cFilsV3U := ''
default cFilsV4B := ''
default cBanco   := ''
default cCompV3X := ''
default cCompV4F := ''
default oTabTemp := Nil

cQry 	 := ''
cDataIni := cPeriod + "01" //ex: 20220201
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

nV3SIdNatR := TamSX3("V3S_IDNATR")[1]
nC30CNatRe := TamSX3("C30_CNATRE")[1]
nV3VCNatRe := TamSX3("V3V_CNATRE")[1]
nTmPrId40  := TamSX3("C20_PRID40")[1]
lReport    := .T.

//Bloco com campos provenientes das notas
cQry += TafNtField(cBanco,cCompC1G,aInfEUF)
cQry += QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,cFilsC20,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F)
cQry += "GROUP BY C20.C20_FILIAL,C20.C20_CHVNF,C20.C20_NUMDOC,C20.C20_SERIE,C20.C20_DTDOC,C20.C20_FCISCP,C20.C20_CODPAR,C1H.C1H_CPF,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,C1H.C1H_PAISEX,"
cQry += "T9A.T9A_DESCRI,V3X.V3X_CNPJ,C30.C30_NUMITE,C30.C30_CODITE,V3O.V3O_CODIGO,C35.C35_CODTRI,C35.C35_ALIQ "

cQry += "UNION ALL " //Bloco com campos provenientes das faturas
cQry += TafFtField(cDataIni,cDataFim,cCompV4F,cCompC1G,aInfEUF,cBanco)
cQry += QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,cFilsLEM,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F)
cQry += "GROUP BY LEM.LEM_FILIAL,LEM.LEM_ID,LEM.LEM_NUMERO,LEM.LEM_DTEMIS,LEM.LEM_FCISCP,LEM.LEM_VLBRUT,LEM.LEM_IDPART,C1H.C1H_CPF,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,C1H.C1H_PAISEX,"
cQry += "T9A.T9A_DESCRI,V3X.V3X_CNPJ,V3S.V3S_IDPROC,V3S.V3S_IDNATR,V3S.V3S_DECTER,V4F.V4F_NRPROC,V4F.V4F_INDRRA,V4F.V4F_CNPJOR,V3O.V3O_CODIGO,V47.V47_IDTRIB,V47.V47_ALIQ) FAT "

cQry += "UNION ALL " //Bloco com campos provenientes dos pagamentos
cQry += TafPgtField(cDataIni,cDataFim,cBanco,cCompV4F,cCompC1H,cCompC1G,aInfEUF)
cQry += QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,cFilsV3U,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F)
cQry += "GROUP BY V3U.V3U_FILIAL,V3U.V3U_NUMERO,V3U.V3U_PARCEL,V3U.V3U_DTPAGT,V3U.V3U_ID,V3U.V3U_FCISCP,V3U.V3U_IDPART,C1H.C1H_CPF,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,"
cQry += "T9A.T9A_DESCRI,V3X.V3X_CNPJ,V3V.V3V_CNATRE,V3V.V3V_IDPROC,V3V.V3V_VALOR,V3O.V3O_CODIGO,V4F.V4F_INDRRA,V4F.V4F_NRPROC,V4F.V4F_CNPJOR) PGT "

cQuery4010 := cQry

cQry += "UNION ALL " //Bloco com campos provenientes dos reembolsos \ plano de saude
cQry += TafPlsField(cCompC1H,aInfEUF,cFilsV4B,cDataIni,cDataFim,cQuery4010,nTmPrId40,lReport,@oTabTemp,cBanco)

cQry := TafGerField() + " FROM ( " + cQry //Campos Gerais do Relatorio

cQry += ") TBGER ORDER BY FILIAL,CPF,DTEMISPGT,DOCTO,NUMITE,SERIEPARC,CODNAT "

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Colunas Gerais do Relatorio R4010

@author Denis Souza
@since 14/02/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafGerField()

local cQry as Character

cQry := "SELECT TBGER.FILIAL"	//01 Filial / Nome da filial / CNPJ
cQry += ",TBGER.CPF"			//02 CPF Beneficiário
cQry += ",TBGER.CODPAR"	 		//03 Código participante
cQry += ",TBGER.INDNIF"	 		//04 Indicativo NIF
cQry += ",TBGER.NIF"			//05 N° NIF
cQry += ",TBGER.FRMTRIB" 		//06 Forma Tributação
cQry += ",TBGER.NOME"			//07 Nome Beneficiário
cQry += ",TBGER.ROTINA"	 		//08 Tipo
cQry += ",TBGER.SERIEPARC" 		//09 Série / Parcela
cQry += ",TBGER.DOCTO"			//10 N° Documento
cQry += ",TBGER.NUMITE"	 		//11 N° do Item
cQry += ",TBGER.DTEMISPGT"		//12 Data emissão/pagamento
cQry += ",TBGER.ID"		 		//13 ID do documento
cQry += ",TBGER.CODNAT"	 		//14 Natureza de Rendimento
cQry += ",TBGER.INDFCISCP"		//15 Indicativo de FCI/SCP
cQry += ",TBGER.CNPJFCISCP" 	//16 CNPJ da FCI/SCP
cQry += ",TBGER.NRRRAPJD"		//17 Informação de RRA ou Proce
cQry += ",TBGER.INDRRA"	 		//18 N° de Inscrição do process
cQry += ",TBGER.CNPJOR"	 		//19 CNPJ Origem Recurso
cQry += ",TBGER.CUSTADV" 		//20 Total de Custas com advogados
cQry += ",TBGER.CUSTJUD" 		//21 Total de Custas Judiciais
cQry += ",TBGER.VALBRUTO"   	//22 Valor do documento
cQry += ",TBGER.BASEIR"	 		//23 Base de Cálculo IR
cQry += ",TBGER.ALIQIR"	 		//24 Alíquota do IR
cQry += ",TBGER.VALIR"	 		//25 Valor do IR
cQry += ",TBGER.TOTDEDU"    	//26 Total de deduções
cQry += ",TBGER.TDEDUDEP"   	//27 Valor total das deduções de dependentes
cQry += ",TBGER.TOTISEN"		//28 Total de Rendimentos Isentos
cQry += ",TBGER.VBSIR"	 		//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",TBGER.VRSIR"	 		//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",TBGER.TDEDUSUSP"  	//31 Valor da dedução suspensa
cQry += ",TBGER.NPROCREF"   	//32 N° do Processo Referenciado
cQry += ",TBGER.CNPJPLS"		//33 CNPJ PLS 
cQry += ",TBGER.BENEPLS"		//34 Beneficiário PLS
cQry += ",TBGER.CPFDEPE"		//35 CPF Dependente 
cQry += ",TBGER.TIPPGTO"		//36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",TBGER.VPGTPLS"		//37 Valor pago PLS
cQry += ",TBGER.REEMBAN"		//38 Reembolso ano anterior
cQry += ",TBGER.TPMEDIC"		//39 Tipo de Inscrição Médico
cQry += ",TBGER.NINSMED "		//40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafFtField
Registros/Campos provenientes das faturas que se enquadram no R4010

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafFtField(cDataIni,cDataFim,cCompV4F,cCompC1G,aInfEUF,cBanco)

local cQry 		as character
local cConcat	as character

Default cDataIni := ''
Default cDataFim := ''
Default cCompV4F := ''
Default cCompC1G := ''
Default aInfEUF  := {}
Default cBanco   := ''

If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) ) //tratamento do concat devido tcsqlexec nao converte com o padrao || no sql
	cConcat := ' + '
Else
	cConcat := ' || '
EndIf

cQry := "SELECT "
cQry += "FAT.FILIAL"	  //01 Filial / Nome da filial / CNPJ da filial
cQry += ",FAT.CPF"		  //02 CPF Beneficiário
cQry += ",FAT.CODPAR"	  //03 Código participante
cQry += ",FAT.INDNIF"	  //04 Indicativo NIF
cQry += ",FAT.NIF"		  //05 N° NIF
cQry += ",FAT.FRMTRIB"	  //06 Forma Tributação
cQry += ",FAT.NOME"		  //07 Nome Beneficiário
cQry += ",FAT.ROTINA"	  //08 Tipo
cQry += ",FAT.SERIEPARC"  //09 Série / Parcela
cQry += ",FAT.DOCTO"	  //10 N° Documento
cQry += ",FAT.NUMITE"	  //11 N° do Item
cQry += ",FAT.DTEMISPGT"  //12 Data emissão/pagamento
cQry += ",FAT.ID"		  //13 ID do documento
cQry += ",FAT.CODNAT"	  //14 Natureza de Rendimento
cQry += ",FAT.INDFCISCP"  //15 Indicativo de FCI/SCP
cQry += ",FAT.CNPJFCISCP" //16 CNPJ da FCI/SCP
cQry += ",FAT.NRRRAPJD"	  //17 Informação de RRA ou Processo Judicial
cQry += ",FAT.INDRRA"	  //18 N° de Inscrição do processo RRA/Processo Judicial
cQry += ",FAT.CNPJOR"	  //19 CNPJ Origem Recurso

cQry += ",COALESCE((SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += "AND V4GADV.V4G_ID = V4F.V4F_ID AND V4GADV.V4G_TPDESP = '1' AND V4GADV.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GADV.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += "V4F.V4F_FILIAL = FAT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = FAT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' '), 0) CUSTADV " //20 Total de Custas com advogados

cQry += ",COALESCE((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += "AND V4GJUD.V4G_ID = V4F.V4F_ID AND V4GJUD.V4G_TPDESP = '2' AND V4GJUD.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GJUD.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = FAT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = FAT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' '), 0) CUSTJUD " //21 Total de Custas Judiciais	

cQry += ",FAT.VALBRUTO"	//22 Valor do documento
cQry += ",FAT.BASEIR"	//23 Base de Cálculo IR
cQry += ",FAT.ALIQIR"	//24 Alíquota do IR
cQry += ",FAT.VALIR"	//25 Valor do IR
cQry += ",FAT.TOTDEDU"  //26 Total de deduções
cQry += ",FAT.TDEDUDEP" //27 Valor total das deduções de dependentes
cQry += ",FAT.TOTISEN"	//28 Total de Rendimentos Isentos
cQry += ",FAT.VBSIR"	//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",FAT.VRSIR"	//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",FAT.TDEDUSUSP"//31 Valor da dedução suspensa
cQry += ",FAT.NPROCREF" //32 N° do Processo Referenciado
cQry += ",FAT.CNPJPLS"	//33 CNPJ PLS 
cQry += ",FAT.BENEPLS"	//34 Beneficiário PLS
cQry += ",FAT.CPFDEPE"	//35 CPF Dependente 
cQry += ",FAT.TIPPGTO"	//36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",FAT.VPGTPLS"	//37 Valor pago PLS
cQry += ",FAT.REEMBAN"	//38 Reembolso ano anterior
cQry += ",FAT.TPMEDIC"	//39 Tipo de Inscrição Médico
cQry += ",FAT.NINSMED "	//40 Nr. Inscrição Médico

cQry += "FROM ( "

cQry += "SELECT "
cQry += "LEM.LEM_FILIAL FILIAL" 					//01 Filial / Nome da filial / CNPJ da filial
cQry += ",C1H.C1H_CPF CPF"		 					//02 CPF Beneficiário
cQry += ",C1H.C1H_CODPAR CODPAR" 					//03 Código participante

//04 Indicativo NIF
cQry += ",CASE WHEN C1H.C1H_INDNIF = '1' THEN 'Possui' WHEN C1H.C1H_INDNIF = '2' THEN 'Dispensado' "
cQry += "WHEN C1H.C1H_INDNIF = '3' THEN 'Pais nao exige' ELSE 'Nao Informado' END INDNIF"

cQry += ",C1H.C1H_NIF NIF" 						 	//05 N° NIF
cQry += ",COALESCE(T9A.T9A_DESCRI, '') FRMTRIB" 	//06 Forma Tributação
cQry += ",C1H.C1H_NOME NOME"						//07 Nome Beneficiário
cQry += ",'FAT' ROTINA"							 	//08 Tipo
cQry += " ,' ' SERIEPARC"							//09 Série / Parcela
cQry += ",LEM.LEM_NUMERO DOCTO"					 	//10 N° Documento
cQry += ",' ' NUMITE"								//11 N° do Item
cQry += ",LEM.LEM_DTEMIS DTEMISPGT"				 	//12 Data emissão/pagamento
cQry += ",LEM.LEM_ID ID"							//13 ID do documento
cQry += ",V3O.V3O_CODIGO CODNAT"					//14 Natureza de Rendimento

//15 Indicativo de FCI/SCP
cQry += ",CASE WHEN LEM.LEM_FCISCP = '1' THEN 'FCI' WHEN LEM.LEM_FCISCP = '2' THEN 'SCP' ELSE 'Nao Informado' END INDFCISCP"

cQry += ",COALESCE(V3X.V3X_CNPJ, '') CNPJFCISCP"	//16 CNPJ da FCI/SCP
cQry += ",V3S.V3S_IDPROC IDRRAPJUD"				 	//Utilizado no join sobre a query executada CMPS 20 e 21
cQry += ",COALESCE(V4F.V4F_NRPROC, '') NRRRAPJD"	//17 Informação de RRA ou Processo Judicial

//18 N° de Inscrição do processo RRA/Processo Judicial
cQry += ",COALESCE( CASE WHEN V4F.V4F_INDRRA = '1' THEN 'Sim' ELSE 'Nao' END , '') INDRRA"

cQry += ",COALESCE(V4F.V4F_CNPJOR, '') CNPJOR"		//19 CNPJ Origem Recurso
cQry += ",LEM.LEM_VLBRUT VALBRUTO"					//22 Valor do documento
cQry += ",COALESCE(SUM(V47.V47_BASECA),0) BASEIR"	//23 Base de Cálculo IR
cQry += ",COALESCE(V47.V47_ALIQ, 0) ALIQIR"		 	//24 Alíquota do IR
cQry += ",COALESCE(SUM(V47.V47_VLTRIB),0) VALIR"	//25 Valor do IR

//26 Total de deduções
cQry += ",COALESCE((SELECT SUM(V4L.V4L_VLRDED) FROM " + RetSqlName("V4L") + " V4L WHERE V4L.V4L_FILIAL = LEM.LEM_FILIAL AND V4L.V4L_ID = LEM.LEM_ID "
cQry += "AND V4L.V4L_IDPART = LEM.LEM_IDPART AND V4L.V4L_NUMFAT = LEM.LEM_NUMERO AND V4L.V4L_IDNATR = V3S.V3S_IDNATR "
cQry += "AND V4L.V4L_DECTER = V3S.V3S_DECTER AND V4L.V4L_IDTRIB = V47.V47_IDTRIB AND V4L.V4L_IDTRIB = '000012' AND V4L.D_E_L_E_T_ = ' '),0) TOTDEDU "

//27 Valor total das deduções de dependentes
cQry += ",COALESCE((SELECT SUM(V83.V83_VALDED) FROM " + RetSqlName("V83") + " V83 WHERE V83.V83_FILIAL = LEM.LEM_FILIAL AND V83.V83_ID = LEM.LEM_ID "
cQry += "AND V83.V83_IDPART = LEM.LEM_IDPART AND V83.V83_NUMFAT = LEM.LEM_NUMERO AND V83.V83_IDNATR = V3S.V3S_IDNATR AND V83.V83_DECTER = V3S.V3S_DECTER "
cQry += "AND V83.V83_IDTRIB = V47.V47_IDTRIB AND V83.V83_IDTRIB = '000012' AND V83.D_E_L_E_T_ = ' '),0) TDEDUDEP "

//28 Total de Rendimentos Isentos
cQry += ",COALESCE((SELECT SUM(V4M.V4M_VLRISE) FROM " + RetSqlName("V4M") + " V4M WHERE V4M.V4M_FILIAL = LEM.LEM_FILIAL AND V4M.V4M_ID = LEM.LEM_ID "
cQry += "AND V4M.V4M_IDPART = LEM.LEM_IDPART AND V4M.V4M_NUMFAT = LEM.LEM_NUMERO AND V4M.V4M_IDNATR = V3S.V3S_IDNATR "
cQry += "AND V4M.V4M_DECTER = V3S.V3S_DECTER AND V4M.V4M_IDTRIB = V47.V47_IDTRIB AND V4M.V4M_IDTRIB = '000012' AND V4M.D_E_L_E_T_ = ' '),0) TOTISEN "

//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",COALESCE((SELECT SUM(T9E.T9E_BSSUSP) FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = '000012' AND T9E.D_E_L_E_T_ = ' '),0) VBSIR "

//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",COALESCE((SELECT SUM(T9E.T9E_VALSUS) FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = '000012' AND T9E.D_E_L_E_T_ = ' '),0) VRSIR "

//31 Valor da dedução suspensa (Diferente da nota, onde V88 está por item, do pagamento, onde V90 está por natureza a V89 da fatura nao possui vinculo direto com a natureza)
cQry += ",COALESCE((SELECT SUM(V89.V89_VALDED) FROM " + RetSqlName("V89") + " V89 WHERE V89.V89_FILIAL = LEM.LEM_FILIAL AND V89.V89_ID = LEM.LEM_ID "
cQry += "AND V89.V89_IDPT9E = LEM.LEM_IDPART AND V89.V89_NFAT9E = LEM.LEM_NUMERO AND V89.V89_CODTRI = '000012' "
cQry += "AND V89.V89_TPPROC"+cConcat+"V89.V89_NUMPRO"+cConcat+"V89.V89_IDSUSP IN ( "
cQry += "SELECT DISTINCT T9E.T9E_TPPROC"+cConcat+"T9E.T9E_NUMPRO"+cConcat+"T9E.T9E_IDSUSP " 
cQry += "FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = '000012' AND T9E.D_E_L_E_T_ = ' ') "
cQry += "AND V89.D_E_L_E_T_ = ' '),0) TDEDUSUSP "

//32 N° do Processo Referenciado
cQry += ",COALESCE(( "
If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) )
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

cQry += ",' ' CNPJPLS"  //33 CNPJ PLS
cQry += ",' ' BENEPLS"  //34 Beneficiário PLS
cQry += ",' ' CPFDEPE"  //35 CPF Dependente
cQry += ",' ' TIPPGTO"  //36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",0 VPGTPLS" 	//37 Valor pago PLS
cQry += ",0 REEMBAN" 	//38 Reembolso ano anterior
cQry += ",' ' TPMEDIC"  //39 Tipo de Inscrição Médico
cQry += ",' ' NINSMED " //40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes das notas fiscais que se enquadram no R4020

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafNtField( cBanco, cCompC1G, aInfEUF)

local cQry as Character

default cBanco   := ''
default cCompC1G := ''
default aInfEUF  := {}

cQry := "SELECT "
cQry += "C20.C20_FILIAL FILIAL" 					  //01 Filial / Nome da filial / CNPJ da filial
cQry += ",C1H.C1H_CPF CPF"							  //02 CPF Beneficiário
cQry += ",C1H.C1H_CODPAR CODPAR" 					  //03 Código participante

//04 Indicativo NIF
cQry += ",CASE WHEN C1H.C1H_INDNIF = '1' THEN 'Possui' WHEN C1H.C1H_INDNIF = '2' THEN 'Dispensado' "
cQry += "WHEN C1H.C1H_INDNIF = '3' THEN 'Pais nao exige' ELSE 'Nao Informado' END INDNIF"

cQry += ",C1H.C1H_NIF NIF"							  //05 N° NIF
cQry += ",COALESCE(T9A.T9A_DESCRI, '') FRMTRIB" 	  //06 Forma Tributação 
cQry += ",C1H.C1H_NOME NOME" 						  //07 Nome Beneficiário
cQry += ",'NFS' ROTINA"							  	  //08 Tipo
cQry += ",C20.C20_SERIE SERIEPARC"				  	  //09 Série / Parcela
cQry += ",C20.C20_NUMDOC DOCTO"					  	  //10 N° Documento
cQry += ",C30.C30_NUMITE NUMITE"					  //11 N° do Item
cQry += ",C20.C20_DTDOC DTEMISPGT"					  //12 Data emissão/pagamento
cQry += ",C20.C20_CHVNF ID"						  	  //13 ID do documento
cQry += ",V3O.V3O_CODIGO CODNAT"					  //14 Natureza de Rendimento

//15 Indicativo de FCI/SCP
cQry += ",CASE WHEN C20.C20_FCISCP = '1' THEN 'FCI' WHEN C20.C20_FCISCP = '2' THEN 'SCP' ELSE 'Nao Informado' END INDFCISCP"

cQry += ",COALESCE(V3X.V3X_CNPJ, '') CNPJFCISCP"	  //16 CNPJ da FCI/SCP
cQry += ",'' NRRRAPJD" 							  	  //17 Informação de RRA ou Processo Judicial
cQry += ",'' INDRRA"								  //18 N° de Inscrição do processo RRA/Processo Judicial
cQry += ",'' CNPJOR"								  //19 CNPJ Origem Recurso
cQry += ",0 CUSTADV"								  //20 Total de Custas com advogados
cQry += ",0 CUSTJUD"								  //21 Total de Custas Judiciais
cQry += ",COALESCE(SUM(C30.C30_TOTAL), 0) VALBRUTO"   //22 Valor do documento
cQry += ",COALESCE(SUM(C35.C35_BASE), 0) BASEIR"	  //23 Base de Cálculo IR
cQry += ",COALESCE(C35.C35_ALIQ, 0) ALIQIR"		  	  //24 Alíquota do IR
cQry += ",COALESCE(SUM(C35.C35_VALOR), 0) VALIR"	  //25 Valor do IR

//26 Total de deduções
cQry += ",COALESCE((SELECT SUM(V4C.V4C_VLRDED) FROM " + RetSqlName("V4C") + " V4C WHERE V4C.V4C_FILIAL = C20.C20_FILIAL AND V4C.V4C_CHVNF = C20.C20_CHVNF "
cQry += "AND V4C.V4C_NUMITE = C30.C30_NUMITE AND V4C.V4C_CODITE = C30.C30_CODITE AND V4C.V4C_CODTRI = C35.C35_CODTRI "
cQry += "AND V4C.V4C_CODTRI = '000012' AND V4C.D_E_L_E_T_ = ' '),0) TOTDEDU "

//27 Valor total das deduções de dependentes
cQry += ",COALESCE((SELECT SUM(V84.V84_VALDED) FROM " + RetSqlName("V84") + " V84 WHERE V84.V84_FILIAL = C20.C20_FILIAL AND V84.V84_CHVNF = C20.C20_CHVNF "
cQry += "AND V84.V84_IDPART = C20.C20_CODPAR AND V84.V84_NUMITE = C30.C30_NUMITE AND V84.V84_CODITE = C30.C30_CODITE AND V84.V84_CODTRI = C35.C35_CODTRI "
cQry += "AND V84.V84_CODTRI = '000012' AND V84.D_E_L_E_T_ = ' '),0) TDEDUDEP "

//28 Total de Rendimentos Isentos
cQry += ",COALESCE((SELECT SUM(V4D.V4D_VLRISE) FROM " + RetSqlName("V4D") + " V4D WHERE V4D.V4D_FILIAL = C20.C20_FILIAL AND V4D.V4D_CHVNF = C20.C20_CHVNF "
cQry += "AND V4D.V4D_NUMITE = C30.C30_NUMITE AND V4D.V4D_CODITE = C30.C30_CODITE AND V4D.V4D_CODTRI = C35.C35_CODTRI "
cQry += "AND V4D.V4D_CODTRI = '000012' AND V4D.D_E_L_E_T_ = ' '),0) TOTISEN "

//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",COALESCE((SELECT SUM(T9Q.T9Q_BSSUSP) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
cQry += "AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.T9Q_CODTRI = '000012' AND T9Q.D_E_L_E_T_ = ' '),0) VBSIR "

//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",COALESCE((SELECT SUM(T9Q.T9Q_VALSUS) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
cQry += "AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.T9Q_CODTRI = '000012' AND T9Q.D_E_L_E_T_ = ' '),0) VRSIR "

//31 Valor da dedução suspensa
cQry += ",COALESCE((SELECT SUM(V88.V88_VALDED) FROM " + RetSqlName("V88") + " V88 WHERE V88.V88_FILIAL = C20.C20_FILIAL AND V88.V88_CHVNF = C20.C20_CHVNF "
cQry += "AND V88.V88_NUMITE = C30.C30_NUMITE AND V88.V88_IDPROC = C30.C30_CODITE AND V88.V88_CODTRI = '000012' AND V88.D_E_L_E_T_ = ' '),0) TDEDUSUSP "

cQry += ",COALESCE(( "
If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("T9Q") + " T9Q INNER JOIN "  + RetSqlName("C1G") + " C1G ON "
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
cQry += "WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF AND T9Q.T9Q_NUMITE = C30.C30_NUMITE "
cQry += "AND T9Q.T9Q_ID = C30.C30_CODITE AND T9Q.T9Q_CODTRI = '000012' AND T9Q.D_E_L_E_T_ = ' ' "
if cBanco == "ORACLE"
	cQry += " AND ROWNUM <= 1 "
Elseif cBanco $ "POSTGRES|DB2"
	cQry += " LIMIT 1 "
Endif
cQry += " ),'') NPROCREF "	//32 N° do Processo Referenciado

cQry += ",' ' CNPJPLS "		//33 CNPJ PLS
cQry += ",' ' BENEPLS "		//34 Beneficiário PLS
cQry += ",' ' CPFDEPE "		//35 CPF Dependente
cQry += ",' ' TIPPGTO "		//36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",0 VPGTPLS " 		//37 Valor pago PLS
cQry += ",0 REEMBAN " 		//38 Reembolso ano anterior
cQry += ",' ' TPMEDIC "		//39 Tipo de Inscrição Médico
cQry += ",' ' NINSMED "		//40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes dos pagamentos que se enquadram no R4010

@author Denis Souza
@since 15/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafPgtField( cDataIni, cDataFim, cBanco, cCompV4F, cCompC1H, cCompC1G, aInfEUF)

Local cQry 	   	 as Character
Local nC1HCNPJ 	 as Numeric
Local nV3SIDNATR as Numeric

Default cDataIni := ''
Default cDataFim := ''
Default cBanco   := ''
Default cCompV4F := ''
Default cCompC1G := ''
Default aInfEUF  := {}

nC1HCNPJ := TamSX3("C1H_CNPJ")[1]
nV3SIDNATR := TamSX3("V3S_IDNATR")[1]

cQry := "SELECT PGT.FILIAL"  //01 Filial / Nome da filial / CNPJ da filial
cQry += ",PGT.CPF"			 //02 CPF Beneficiário
cQry += ",PGT.CODPAR"		 //03 Código participante
cQry += ",PGT.INDNIF"		 //04 Indicativo NIF
cQry += ",PGT.NIF"			 //05 N° NIF
cQry += ",PGT.FRMTRIB"		 //06 Forma Tributação
cQry += ",PGT.NOME"		 	 //07 Nome Beneficiário
cQry += ",PGT.ROTINA"		 //08 Tipo
cQry += ",PGT.SERIEPARC"	 //09 Série / Parcela
cQry += ",PGT.DOCTO"		 //10 N° Documento
cQry += ",PGT.NUMITE"		 //11 N° do Item
cQry += ",PGT.DTEMISPGT"	 //12 Data emissão/pagamento
cQry += ",PGT.ID"			 //13 ID do documento
cQry += ",PGT.CODNAT"		 //14 Natureza de Rendimento
cQry += ",PGT.INDFCISCP"	 //15 Indicativo de FCI/SCP
cQry += ",PGT.CNPJFCISCP"	 //16 CNPJ da FCI/SCP
cQry += ",PGT.NRRRAPJD"	 	 //17 N° de Inscrição do processo RRA/Processo Judicial
cQry += ",PGT.INDRRA"		 //18 Informação de RRA ou Processo Judicial
cQry += ",PGT.CNPJOR"		 //19 CNPJ Origem Recurso

cQry += ",COALESCE(( SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += "AND V4GADV.V4G_ID = V4F.V4F_ID AND V4GADV.V4G_TPDESP = '1' AND V4GADV.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GADV.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += "V4F.V4F_FILIAL = PGT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = PGT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' '), 0) CUSTADV " //20 Total de Custas com advogados

cQry += ",COALESCE((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
cQry += "AND V4GJUD.V4G_ID = V4F.V4F_ID AND V4GJUD.V4G_TPDESP = '2' AND V4GJUD.V4G_DTDESP BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND V4GJUD.D_E_L_E_T_ = ' ' WHERE "
If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = PGT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	ElseIf cCompV4F == "CCC" .Or. ( cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQry += "V4F.V4F_FILIAL = '" + xFilial("V4F") + "' "
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = PGT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ' '), 0) CUSTJUD " //21 Total de Custas Judiciais

cQry += ",PGT.VALBRUTO"  //22 Valor do documento
cQry += ",PGT.BASEIR"	 //23 Base de Cálculo IR
cQry += ",PGT.ALIQIR"	 //24 Alíquota do IR
cQry += ",PGT.VALIR"	 //25 Valor do IR
cQry += ",PGT.TOTDEDU"	 //26 Total de deduções  	
cQry += ",PGT.TDEDUDEP"  //27 Valor total das deduções de dependentes 
cQry += ",PGT.TOTISEN"	 //28 Total de Rendimentos Isentos
cQry += ",PGT.VBSIR"	 //29 Valor do Rendimento Suspenso por processo judicial
cQry += ",PGT.VRSIR"	 //30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",PGT.TDEDUSUSP" //31 Valor da dedução suspensa
cQry += ",PGT.NPROCREF"	 //32 N° do Processo Referenciado
cQry += ",PGT.CNPJPLS" 	 //33 CNPJ PLS
cQry += ",PGT.BENEPLS" 	 //34 Beneficiário PLS
cQry += ",PGT.CPFDEPE" 	 //35 CPF Dependente
cQry += ",PGT.TIPPGTO" 	 //36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",PGT.VPGTPLS" 	 //37 Valor pago PLS
cQry += ",PGT.REEMBAN" 	 //38 Reembolso ano anterior
cQry += ",PGT.TPMEDIC" 	 //39 Tipo de Inscrição Médico
cQry += ",PGT.NINSMED "  //40 Nr. Inscrição Médico

cQry += " FROM ( "

cQry += "SELECT "
cQry += "V3U.V3U_FILIAL FILIAL"				 	//01 Filial / Nome da filial / CNPJ da filial
cQry += ",C1H.C1H_CPF CPF"						//02 CPF Beneficiário
cQry += ",C1H.C1H_CODPAR CODPAR"				//03 Código participante

//04 Indicativo NIF
cQry += ",CASE WHEN C1H.C1H_INDNIF = '1' THEN 'Possui' WHEN C1H.C1H_INDNIF = '2' THEN 'Dispensado' "
cQry += "WHEN C1H.C1H_INDNIF = '3' THEN 'Pais nao exige' ELSE 'Nao Informado' END INDNIF"

cQry += ",C1H.C1H_NIF NIF"						//05 N° NIF
cQry += ",COALESCE(T9A.T9A_DESCRI,'') FRMTRIB"	//06 Forma Tributação
cQry += ",C1H.C1H_NOME NOME"					//07 Nome Beneficiário
cQry += ",'PGT' ROTINA"						  	//08 Tipo
cQry += ",V3U.V3U_PARCEL SERIEPARC"				//09 Série / Parcela
cQry += ",V3U.V3U_NUMERO DOCTO"				  	//10 N° Documento
cQry += ",' ' NUMITE"							//11 N° do Item
cQry += ",V3U.V3U_DTPAGT DTEMISPGT"			 	//12 Data emissão/pagamento
cQry += ",V3U.V3U_ID ID"						//13 ID do documento
cQry += ",V3O.V3O_CODIGO CODNAT"				//14 Natureza de Rendimento

//15 Indicativo de FCI/SCP
cQry += ",CASE WHEN V3U.V3U_FCISCP = '1' THEN 'FCI' WHEN V3U.V3U_FCISCP = '2' THEN 'SCP' ELSE 'Nao Informado' END INDFCISCP"

cQry += ",COALESCE(V3X.V3X_CNPJ,'') CNPJFCISCP" 	//16 CNPJ da FCI/SCP

cQry += ",COALESCE(V4F.V4F_NRPROC,'') NRRRAPJD " 	//17 N° de Inscrição do processo RRA/Processo Judicial

cQry += ",COALESCE( CASE WHEN V4F.V4F_INDRRA = '1' THEN 'Sim' ELSE 'Nao' END , '') INDRRA" //18 Informação de RRA ou Processo Judicial

cQry += ",COALESCE(V4F.V4F_CNPJOR,'') CNPJOR"		//19 CNPJ Origem Recurso

cQry += ",V3V.V3V_IDPROC IDRRAPJUD"			  		//Utilizado no join query acima campos 20 e 21

cQry += ",V3V.V3V_VALOR VALBRUTO "					//22 Valor do documento

//23 Base de Cálculo IR
cQry += ",COALESCE((SELECT SUM(V46.V46_BASE) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
cQry += "AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' '),0) BASEIR" 

//24 Alíquota do IR
cQry += ",COALESCE((SELECT V46.V46_ALIQ FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
cQry += "AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' '),0) ALIQIR" 

//25 Valor do IR
cQry += ",COALESCE((SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
cQry += "AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = '000028' AND V46.D_E_L_E_T_ = ' '),0) VALIR" 

//26 Total de deduções
cQry += ",COALESCE((SELECT SUM(V4I.V4I_VLRDED) FROM " + RetSqlName("V4I") + " V4I WHERE V4I.V4I_FILIAL = V3U.V3U_FILIAL AND V4I.V4I_ID = V3U.V3U_ID "
cQry += "AND V4I.V4I_IDNAT = V3V.V3V_CNATRE AND V4I.V4I_IDTRIB = '000028' AND V4I.D_E_L_E_T_ = ' '),0) TOTDEDU"

//27 Valor total das deduções de dependentes
cQry += ",COALESCE((SELECT SUM(V85.V85_VALDED) FROM " + RetSqlName("V85") + " V85 WHERE V85.V85_FILIAL = V3U.V3U_FILIAL AND V85.V85_ID = V3U.V3U_ID "
cQry += "AND V85.V85_IDPART = V3U.V3U_IDPART AND V85.V85_IDNAT = V3V.V3V_CNATRE AND V85.V85_IDTRIB = '000028' AND V85.D_E_L_E_T_ = ' '),0) TDEDUDEP"

//28 Total de Rendimentos Isentos
cQry += ",COALESCE((SELECT SUM(V4J.V4J_VLRISE) FROM " + RetSqlName("V4J") + " V4J WHERE V4J.V4J_FILIAL = V3U.V3U_FILIAL AND V4J.V4J_ID = V3U.V3U_ID "
cQry += "AND V4J.V4J_IDNAT = V3V.V3V_CNATRE AND V4J.V4J_IDTRIB = '000028' AND V4J.D_E_L_E_T_ = ' '),0) TOTISEN"

//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",COALESCE((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
cQry += "AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000028' AND V4H.D_E_L_E_T_ = ' '),0) VBSIR"

//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",COALESCE((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
cQry += "AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000028' AND V4H.D_E_L_E_T_ = ' '),0) VRSIR"

//31 Valor da dedução suspensa
cQry += ",COALESCE((SELECT SUM(V90.V90_VALDED) FROM " + RetSqlName("V90") + " V90 WHERE V90.V90_FILIAL = V3U.V3U_FILIAL AND V90.V90_ID = V3U.V3U_ID "
cQry += "AND V90.V90_CNATRE = V3V.V3V_CNATRE AND V90.V90_IDTRIB = '000028' AND V90.D_E_L_E_T_ = ' '),0) TDEDUSUSP"

cQry += ",COALESCE(( "
If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("V4H") + " V4H INNER JOIN "  + RetSqlName("C1G") + " C1G ON "
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
cQry += "AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = '000028' AND V4H.D_E_L_E_T_ = ' ' "
if cBanco == "ORACLE"
	cQry += "AND ROWNUM <= 1 "
Elseif cBanco $ "POSTGRES|DB2"
	cQry += "LIMIT 1 "
Endif
cQry += " ),'') NPROCREF" //32 N° do Processo Referenciado

cQry += ",' ' CNPJPLS"	  //33 CNPJ PLS
cQry += ",' ' BENEPLS"	  //34 Beneficiário PLS
cQry += ",' ' CPFDEPE"	  //35 CPF Dependente
cQry += ",' ' TIPPGTO"	  //36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",0 VPGTPLS" 	  //37 Valor pago PLS
cQry += ",0 REEMBAN" 	  //38 Reembolso ano anterior
cQry += ",' ' TPMEDIC"	  //39 Tipo de Inscrição Médico
cQry += ",' ' NINSMED "	  //40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes dos pagamento\reembolso PLS que se enquadram no R4010

@author Denis Souza
@since 15/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafPlsField(cCompC1H,aInfEUF,cFilsV4B,cDataIni,cDataFim,cQuery4010,nTmPrId40,lReport,oTabTemp,cBanco)

Local cQry 		as Character
Local cInto 	as Character
Local cTabName 	as Character
Local cFields	as Character
Local aStru 	as Array

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default cFilsV4B   := ''
Default cDataIni   := ''
Default cDataFim   := ''
Default cQuery4010 := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default oTabTemp   := Nil
Default cBanco     := ''

aStru := {	{'FILIAL' 	 ,GetSx3Cache('V4B_FILIAL'	,'X3_TIPO'),GetSx3Cache('V4B_FILIAL','X3_TAMANHO'),GetSx3Cache('V4B_FILIAL'	,'X3_DECIMAL')},; //01
			{'CPF' 	  	 ,GetSx3Cache('C1H_CPF'   	,'X3_TIPO'),GetSx3Cache('C1H_CPF'   ,'X3_TAMANHO'),GetSx3Cache('C1H_CPF'   	,'X3_DECIMAL')},; //02
			{'CODPAR' 	 ,GetSx3Cache('C1H_CODPAR'	,'X3_TIPO'),GetSx3Cache('C1H_CODPAR','X3_TAMANHO'),GetSx3Cache('C1H_CODPAR'	,'X3_DECIMAL')},; //03
			{'INDNIF' 	 ,"C",15,0},; //04
			{'NIF'    	 ,GetSx3Cache('C1H_NIF'   	,'X3_TIPO'),GetSx3Cache('C1H_NIF'   ,'X3_TAMANHO'),GetSx3Cache('C1H_NIF'   	,'X3_DECIMAL')},; //05
			{'FRMTRIB'	 ,GetSx3Cache('T9A_DESCRI'	,'X3_TIPO'),GetSx3Cache('T9A_DESCRI','X3_TAMANHO'),GetSx3Cache('T9A_DESCRI'	,'X3_DECIMAL')},; //06
			{'NOME'		 ,GetSx3Cache('C1H_NOME'	,'X3_TIPO'),GetSx3Cache('C1H_NOME'	,'X3_TAMANHO'),GetSx3Cache('C1H_NOME'	,'X3_DECIMAL')},; //07
			{'ROTINA'	 ,"C",3,0 },; //08
			{'SERIEPARC' ,"C",1,0 },; //09
			{'DOCTO'	 ,"C",1,0 },; //10
			{'NUMITE'	 ,"C",1,0 },; //11
			{'DTEMISPGT' ,GetSx3Cache('V4B_DTPGTO'	,'X3_TIPO'),GetSx3Cache('V4B_DTPGTO','X3_TAMANHO'),GetSx3Cache('V4B_DTPGTO'	,'X3_DECIMAL')},; //12
			{'ID' 		 ,GetSx3Cache('V4B_ID'		,'X3_TIPO'),GetSx3Cache('V4B_ID'	,'X3_TAMANHO'),GetSx3Cache('V4B_ID'		,'X3_DECIMAL')},; //13
			{'CODNAT' 	 ,"C",1,0 },; //14
			{'INDFCISCP' ,"C",15,0},; //15
			{'CNPJFCISCP',"C",1,0 },; //16
			{'INDRRA' 	 ,"C",3,0 },; //17
			{'NRRRAPJD'  ,"C",1,0 },; //18
			{'CNPJOR'    ,"C",1,0 },; //19
			{'CUSTADV'   ,"N",1,0 },; //20
			{'CUSTJUD'   ,"N",1,0 },; //21
			{'VALBRUTO'  ,"N",1,0 },; //22
			{'BASEIR'    ,"N",1,0 },; //23
			{'ALIQIR'    ,"N",1,0 },; //24
			{'VALIR'     ,"N",1,0 },; //25
			{'TOTDEDU'   ,"N",1,0 },; //26
			{'TDEDUDEP'  ,"N",1,0 },; //27
			{'TOTISEN'   ,"N",1,0 },; //28
			{'VBSIR'   	 ,"N",1,0 },; //29
			{'VRSIR'   	 ,"N",1,0 },; //30
			{'TDEDUSUSP' ,"N",1,0 },; //31
			{'NPROCREF'  ,"C",1,0 },; //32
			{'CNPJPLS'   ,GetSx3Cache('V4B_CNPJ'	,'X3_TIPO'),GetSx3Cache('V4B_CNPJ'	,'X3_TAMANHO'),GetSx3Cache('V4B_CNPJ'	,'X3_DECIMAL')},;//33
			{'BENEPLS'   ,"C",10,0},; //34
			{'CPFDEPE'   ,GetSx3Cache('V3R_CPF'		,'X3_TIPO'),GetSx3Cache('V3R_CPF'	,'X3_TAMANHO'),GetSx3Cache('V3R_CPF'	,'X3_DECIMAL')},;//35
			{'TIPPGTO'   ,"C",15,0},; //36
			{'VPGTPLS'   ,GetSx3Cache('V4B_VLRPGT'	,'X3_TIPO'),GetSx3Cache('V4B_VLRPGT','X3_TAMANHO'),GetSx3Cache('V4B_VLRPGT'	,'X3_DECIMAL')},;//37
			{'REEMBAN'   ,GetSx3Cache('V4B_VRBANT'	,'X3_TIPO'),GetSx3Cache('V4B_VRBANT','X3_TAMANHO'),GetSx3Cache('V4B_VRBANT'	,'X3_DECIMAL')},;//38
			{'TPMEDIC'   ,"C",15,0},;//39
			{'NINSMED'   ,GetSx3Cache('V4B_NRINSC'	,'X3_TIPO'),GetSx3Cache('V4B_NRINSC','X3_TAMANHO'),GetSx3Cache('V4B_NRINSC'	,'X3_DECIMAL')}	}//40

//Cria tabela temporaria (TCGenQry Error - Query greater than 32768 bytes)
oTabTemp := FWTemporaryTable():New(,aStru)
oTabTemp:Create()
cTabName := oTabTemp:GetRealName()

cInto 	:= "INSERT INTO " + cTabName + "( "
cFields := "FILIAL"		 //01
cFields += ",CPF"		 //02
cFields += ",CODPAR"	 //03
cFields += ",INDNIF"	 //04
cFields += ",NIF"		 //05
cFields += ",FRMTRIB"	 //06
cFields += ",NOME"		 //07
cFields += ",ROTINA"	 //08
cFields += ",SERIEPARC"  //09
cFields += ",DOCTO"		 //10
cFields += ",NUMITE"	 //11
cFields += ",DTEMISPGT"	 //12
cFields += ",ID"		 //13
cFields += ",CODNAT"	 //14
cFields += ",INDFCISCP"	 //15
cFields += ",CNPJFCISCP" //16
cFields += ",INDRRA"	 //17
cFields += ",NRRRAPJD"	 //18
cFields += ",CNPJOR"	 //19
cFields += ",CUSTADV"	 //20
cFields += ",CUSTJUD"	 //21
cFields += ",VALBRUTO"	 //22
cFields += ",BASEIR"	 //23
cFields += ",ALIQIR"	 //24
cFields += ",VALIR"		 //25
cFields += ",TOTDEDU"	 //26
cFields += ",TDEDUDEP"	 //27
cFields += ",TOTISEN"	 //28
cFields += ",VBSIR"		 //29
cFields += ",VRSIR"		 //30
cFields += ",TDEDUSUSP"	 //31
cFields += ",NPROCREF"	 //32
cFields += ",CNPJPLS"	 //33
cFields += ",BENEPLS"	 //34
cFields += ",CPFDEPE"	 //35
cFields += ",TIPPGTO"	 //36
cFields += ",VPGTPLS"	 //37
cFields += ",REEMBAN"	 //38
cFields += ",TPMEDIC"	 //39
cFields += ",NINSMED"	 //40

cInto += cFields + " ) ( "

cInto += "SELECT DISTINCT V4B.V4B_FILIAL FILIAL"  //01 Filial /Nome da filial /CNPJ da filial
cInto += ",C1H.C1H_CPF CPF"		  				  //02 CPF Beneficiário
cInto += ",C1H.C1H_CODPAR CODPAR" 				  //03 Código participante

//04 Indicativo NIF
cInto += ",CASE WHEN C1H.C1H_INDNIF = '1' THEN 'Possui' WHEN C1H.C1H_INDNIF = '2' THEN 'Dispensado' "
cInto += "WHEN C1H.C1H_INDNIF = '3' THEN 'Pais nao exige' ELSE 'Nao Informado' END INDNIF"

cInto += ",C1H.C1H_NIF NIF"						  //05 N° NIF
cInto += ",COALESCE(T9A.T9A_DESCRI,'') FRMTRIB"   //06 Forma Tributação
cInto += ",C1H.C1H_NOME NOME"		 			  //07 Nome Beneficiário
cInto += ",'PLS' ROTINA"			 	 		  //08 Tipo
cInto += ",' ' SERIEPARC"			 			  //09 Série / Parcela
cInto += ",' ' DOCTO"				 			  //10 N° Documento
cInto += ",' ' NUMITE"				 			  //11 N° do Item
cInto += ",V4B.V4B_DTPGTO DTEMISPGT"	 		  //12 Data emissão/pagamento
cInto += ",V4B.V4B_ID ID"			 			  //13 ID do documento
cInto += ",' ' CODNAT"				 			  //14 Natureza de Rendimento
cInto += ",' ' INDFCISCP"			 			  //15 Indicativo de FCI/SCP
cInto += ",' ' CNPJFCISCP" 			 			  //16 CNPJ da FCI/SCP
cInto += ",' ' INDRRA"	  			 			  //17 N° de Inscrição do processo RRA/Processo Judicial
cInto += ",' ' NRRRAPJD" 			 			  //18 Informação de RRA ou Processo Judicial
cInto += ",' ' CNPJOR"	  			 			  //19 CNPJ Origem Recurso
cInto += ",0 CUSTADV" 				 			  //20 Total de Custas com advogados
cInto += ",0 CUSTJUD"				 			  //21 Total de Custas Judiciais
cInto += ",0 VALBRUTO" 				 			  //22 Valor do documento
cInto += ",0 BASEIR" 				 			  //23 Base de Cálculo IR
cInto += ",0 ALIQIR" 				 			  //24 Alíquota do IR
cInto += ",0 VALIR" 				 	 		  //25 Valor do IR
cInto += ",0 TOTDEDU" 				 			  //26 Total de deduções
cInto += ",0 TDEDUDEP" 				 			  //27 Valor total das deduções de dependentes
cInto += ",0 TOTISEN"	 			 			  //28 Total de Rendimentos Isentos
cInto += ",0 VBSIR"	 				 			  //29 Valor do Rendimento Suspenso por processo judicial
cInto += ",0 VRSIR"	 				 			  //30 Valor da retenção nao efetuada devido Processo Ref
cInto += ",0 TDEDUSUSP"				 			  //31 Valor da dedução suspensa
cInto += ",' ' NPROCREF" 			 			  //32 N° do Processo Referenciado
cInto += ",V4B.V4B_CNPJ CNPJPLS"	 	 		  //33 CNPJ PLS

//34 Beneficiário PLS
cInto += ",CASE WHEN V4B.V4B_INDBEN = '1' THEN 'Titular' ELSE 'Dependente' END BENEPLS"

cInto += ",COALESCE(V3R.V3R_CPF,'') CPFDEPE"	  //35 CPF Dependente

//36 Tipo Pagamento (Reembolso ou Co-Participação)
cInto += ",CASE WHEN V4B.V4B_TPPGTO = '1' THEN 'Co Participacao' ELSE 'Reembolso' END TIPPGTO"

cInto += ",V4B.V4B_VLRPGT VPGTPLS" 	 			  //37 Valor pago PLS
cInto += ",V4B.V4B_VRBANT REEMBAN" 	 			  //38 Reembolso ano anterior

//39 Tipo de Inscrição Médico
cInto += ",CASE WHEN V4B.V4B_TPINSC = '1' THEN 'Pessoa Juridica' ELSE 'Pessoa Fisica' END TPMEDIC"

cInto += ",V4B.V4B_NRINSC NINSMED " 	 		  //40 Nr. Inscrição Médico

cInto += QryFilReemb(cCompC1H,aInfEUF,cFilsV4B,cDataIni,cDataFim,cQuery4010,nTmPrId40,lReport) + ')'

if "ORA" $ cBanco //invalid identifier
	cInto := STRTRAN(cInto,"SUBSTRING","SUBSTR")
endif

tcSqlExec( cInto ) //Inclui registros na tabela temporária

cQry := "SELECT " + cFields + " FROM " + cTabName

Return cQry
