#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry4080()
Query dos pendentes de apura��o do eventos R-4080

@author Rafael de Paula Leme
@since 17/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry4080(cPerApu, aFil, aInfEUF, nPage, nSize, lAll)

Local cQuery     as Character
Local cQryTot    as Character
Local cAlias     as Character
Local cAliasTot  as Character
Local cBd        as Character
Local cFilsV4K   as Character
Local cDataIni   as Character
Local cDataFim   as Character
Local cCompC1H   as Character
Local nTotReg	 as Numeric
Local nV4KPRID40 as Numeric
Local nC1HCNPJ   as Numeric
Local lHasNext   as Logical

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
cBd        := Upper(AllTrim(TcGetDb()))
cFilsV4K   := TafRetFilC("V4K", aFil)
cDataIni   := cPerApu + "01"
cDataFim   := DtoS(LastDay(StoD(cDataIni)))
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
nTotReg    := 0
nV4KPRID40 := TamSX3("V4K_PRID40")[1]
nC1HCNPJ   := TamSX3("C1H_CNPJ")[1]
lHasNext   := .F.

//Tratamento para pagina��o nos bancos n�o homologados
if TafBdVers() .and. nPage > 0 .and. nSize > 0
	
	cQuery += " SELECT LINE_NUMBER, FILIAL, CNPJ, NOME, VLD, VALLIQ, BASEIR, VALIR FROM ( "
	cQuery += " SELECT ROW_NUMBER() OVER ( "
	cQuery += " ORDER BY VLD, CNPJ "
	cQuery +="		) LINE_NUMBER  "
	cQuery += " ,FILIAL "
	cQuery += " ,CNPJ "
	cQuery += " ,NOME "
	cQuery += " ,VLD "
	cQuery += " ,VALLIQ "
	cQuery += " ,BASEIR "
	cQuery += " ,VALIR "
	cQuery += " FROM ( "
	
EndIf

cQuery += " SELECT TBGER.FILIAL FILIAL, TBGER.CNPJ CNPJ, TBGER.NOME NOME, "
cQuery += "	CASE WHEN (SELECT COUNT(V4K_PRID40) FROM " + RetSqlName("V4K") + " WHERE V4K_FILIAL = TBGER.FILIAL AND V4K_CGCFON = TBGER.CNPJ AND V4K_INDNAT = '1' AND "
cQuery += " V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += " V4K_PRID40 = '" + Space(nV4KPRID40) + "' AND "
cQuery += " D_E_L_E_T_ = ' ') > 0 THEN 'notValidated' ELSE 'validated' END VLD, "
cQuery += "	SUM(TBGER.VALLIQ) VALLIQ, "
cQuery += " SUM(TBGER.BASEIR) BASEIR, "
cQuery += " SUM(TBGER.VALIR)  VALIR "
cQuery += " FROM "
cQuery += " (SELECT V4K.V4K_FILIAL FILIAL, C1H.C1H_CNPJ CNPJ, C1H.C1H_NOME NOME, V4K.V4K_PRID40 PROCID, V4K.V4K_VLRLIQ VALLIQ, V4K.V4K_BASEIR BASEIR, V4K.V4K_VLRIR VALIR "
cQuery += " FROM " + RetSqlName("V4K") + " V4K "

//-----JOIN C1H X V4K
cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
If cCompC1H == "EEE"
	cQuery += " C1H.C1H_FILIAL = V4K.V4K_FILIAL "
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	ElseIf cCompC1H == "CCC" .Or. ( cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] == 0 )
		cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf
cQuery += " AND C1H.C1H_ID     = V4K.V4K_IDPART "
cQuery += " AND C1H.C1H_CNPJ   <> '" + Space(nC1HCNPJ) + "' "
cQuery += " AND C1H.C1H_PPES   = '2' "
cQuery += " AND C1H.D_E_L_E_T_ = ' ' "

cQuery += "	WHERE "
cQuery += "	V4K.V4K_FILIAL IN " + cFilsV4K + " AND "
cQuery += "	V4K.V4K_INDNAT = '1' AND "
cQuery += "	V4K.V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += "	V4K.D_E_L_E_T_ = ' ' "
cQuery += "	) TBGER "
cQuery += " GROUP BY TBGER.FILIAL, TBGER.CNPJ, TBGER.NOME "

if TafBdVers() .and. nPage > 0 .and. nSize > 0
	cQuery += " ) TAB ) TMP "
endIf

If lAll .Or. (nPage > 0 .And. nSize > 0) //paginacao e contagem considerando os dados ja agrupados
	cAliasTot := GetNextAlias()
	cQryTot := " SELECT COUNT(TBTOT.FILIAL) QTDREG FROM  ( " + cQuery + " ) TBTOT "
	cQryTot := ChangeQuery(cQryTot)
	TCQuery cQryTot New Alias (cAliasTot)
	nTotReg := (cAliasTot)->QTDREG
	(cAliasTot)->(DBCloseArea())
	If lAll
		lHasNext := .F.
	Else
		lHasNext := Iif((nPage * nSize) >= nTotReg, .F., .T.)
	Endif

EndIf

if TafBdVers() .and. nPage > 0 .and. nSize > 0
	cQuery += " WHERE LINE_NUMBER BETWEEN " + cValToChar(((nPage-1)*nSize) +1) + " AND " + cValToChar(nSize*nPage)
Else
	cQuery += " ORDER BY 4,1,2 "
	If !lAll .And. nPage > 0 .And. nSize > 0
		cQuery += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS "
		cQuery += " FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
	EndIf
EndIf


cQuery := ChangeQuery(cQuery)
cAlias := GetNextAlias()
TCQuery cQuery New Alias (cAlias)

Return {cAlias, nTotReg, lHasNext}

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0024080()
Monta Json de acordo com a query

@author Rafael de Paula Leme
@since 04/11/2022
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Function WS0024080(aApurac, oEstruct, cPeriodo, cEvent, aFiliais, oValidationError)

Local cAlias     as Character
Local cStatus	 as Character
Local nTSintetic as Numeric
Local lhasNext   as Logical

Default aApurac          := {'',0,.F.}
Default oEstruct         := Nil
Default cPeriodo         := '' 
Default cEvent 	         := ''
Default aFiliais         := {}
Default oValidationError := Nil

cAlias     := aApurac[1]
lhasNext   := aApurac[3]
nTSintetic := 0
cStatus    := ""
cCNPJ      := ""
cNome      := ""

If oValidationError == Nil .Or. oValidationError["registryKey"] == Nil
	oValidationError := JsonObject():New()
	oValidationError["registryKey"] := {}
Endif

If !(cAlias)->(EOF())
	(cAlias)->(DbGoTop())
	While !(cAlias)->(EOF())

		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])
			
		cStatus := Iif(Lower(Alltrim((cAlias)->VLD))=="notvalidated","notValidated","validated")
		
		oEstruct["eventDetail"][nTSintetic]["status"]      := cStatus
		oEstruct["eventDetail"][nTSintetic]["branchId"]    := (cAlias)->FILIAL
		oEstruct["eventDetail"][nTSintetic]["numInsc"]     := (cAlias)->CNPJ
		oEstruct["eventDetail"][nTSintetic]["key"]		   := (cAlias)->CNPJ
		oEstruct["eventDetail"][nTSintetic]["fontName"]	   := AllTrim(EncodeUTF8((cAlias)->NOME))
		oEstruct["eventDetail"][nTSintetic]["liquidValue"] := (cAlias)->VALLIQ
		oEstruct["eventDetail"][nTSintetic]["irBaseValue"] := (cAlias)->BASEIR
		oEstruct["eventDetail"][nTSintetic]["irValue"]     := (cAlias)->VALIR
		oEstruct["eventDetail"][nTSintetic]["errors"]      := 'errors'
		
		If Len(oValidationError["registryKey"]) > 0 		
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
Fun��o respons�vel por retornar o procid da tabela de log que cont�m o motivo do erro da apura��o

@author Denis Souza /Jose Felipe
@since 04/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)

Local cKeyError as Character
Local nX        as Numeric

cKeyError := ""
nX        := 1

For nX := 1 to Len(oValidationError["registryKey"])
	if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
		if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
			cKeyError := oValidationError["registryKey"][nX]["error"]
		endif
	endif
Next nX

Return (cKeyError)
