#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ICMS_ST "000004"
#DEFINE IPI	"000005"
#DEFINE R2050 1,1

Function WS0022050(aApurac, oEstruct, oValidationError)

	local cNrInsc		as character
	local cBranch		as character
	local cCompany		as character
	local cCompAux		as character
	local nTSintetic    as numeric
	LOCAL nTotDoc		as numeric
	local lNewBranch	as logical

	default oValidationError["registryKey"] = {}

	cNrInsc		:= ""
	cBranch		:= ""
	cCompany	:= ""
	nTSintetic 	:= 0
	nTotDoc		:= 0

	(aApurac[R2050])->(DBGOTOP())

	While !(aApurac[R2050])->(eof())
		cBranch := Posicione("SM0",1,SM0->M0_CODIGO + (aApurac[R2050])->FILIAL,"M0_FILIAL")
		cCompany := SM0->M0_NOMECOM
		cNrInsc := SM0->M0_CGC
		lNewBranch := cNrInsc <> cCompAux

		If lNewBranch
			nTotDoc := 1
			aadd(oEstruct["eventDetail"],JsonObject():New())
			nTSintetic := len(oEstruct["eventDetail"])

			//C�digo da Filial
			oEstruct["eventDetail"][nTSintetic]["branchId"]         :=  (aApurac[R2050])->FILIAL

			// Nome da Filial
			oEstruct["eventDetail"][nTSintetic]["branch"]           := alltrim(EncodeUTF8(cBranch))

			// Raz�o Social
			oEstruct["eventDetail"][nTSintetic]["company"]          := cCompany

			// CNPJ
			oEstruct["eventDetail"][nTSintetic]["taxNumber"]        := cNrInsc

			// Status
			oEstruct["eventDetail"][nTSintetic]["status"]           := Iif(Empty((aApurac[R2050])->STATUS), 'notValidated', 'validated')

			//Total Bruto
			oEstruct["eventDetail"][nTSintetic]["totalGrossValue"]  := (aApurac[R2050])->VLRBRUTO

			// Quantidade de filiais para apura��o
			oEstruct["eventDetail"][nTSintetic]["totalInvoice"]   	:= (aApurac[R2050])->QTDDOC

			//Id de apura��o
			oEstruct["eventDetail"][nTSintetic]["key"]              := cNrInsc

		    //Propriedade errors que habilita o icone no frontend
    		oEstruct["eventDetail"][nTSintetic]["errors"]           := 'errors'

			If Len(oValidationError["registryKey"]) > 0
				// Chave de busca do erro da apura��o
				oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"]  := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
        	EndIf
		Else
			// Quantidade de filiais para apura��o
			oEstruct["eventDetail"][nTSintetic]["totalInvoice"]   	+= (aApurac[R2050])->QTDDOC

			//Total Bruto
			oEstruct["eventDetail"][nTSintetic]["totalGrossValue"]  += (aApurac[R2050])->VLRBRUTO
		EndIf

		cCompAux := cNrInsc

		(aApurac[R2050])->(dbSkip())
	EndDo

Return oEstruct

Function WS002D2050(aApurac, oEstruct)
	local nTAnalytic  as numeric

	nTAnalytic :=  0

	(aApurac[R2050])->(dbGoTop())

	While !(aApurac[R2050])->(eof())

		aAdd( oEstruct["invoices"],JsonObject():New())
		nTAnalytic   :=  len(oEstruct["invoices"])

		//Filial
		oEstruct["invoices"][nTAnalytic]["branchId"]  :=  (aApurac[R2050])->FILIAL

		//Tipo
		oEstruct["invoices"][nTAnalytic]["invoiceKey"]  :=  (aApurac[R2050])->CHVNF

		//Num. doc
		oEstruct["invoices"][nTAnalytic]["invoice"]  :=  (aApurac[R2050])->NUMDOC

		// S�rie
		oEstruct["invoices"][nTAnalytic]["invoiceSeries"]  :=  (aApurac[R2050])->SERIE

		// item
		oEstruct["invoices"][nTAnalytic]["item"]  :=  (aApurac[R2050])->NUMITEM

		// Data de emiss�o
		oEstruct["invoices"][nTAnalytic]["issueDate"]  :=  SToD((aApurac[R2050])->DTEMISS)

		// Valor bruto
		oEstruct["invoices"][nTAnalytic]["grossValue"]  :=  (aApurac[R2050])->VLRBRUTO

		(aApurac[R2050])->(DbSkip())
	EndDo

Return oEstruct

Function WS002S2050(aApurac, oEstruct)
	local nTAnalytic  as numeric

	nTAnalytic :=  0

	(aApurac[R2050])->(dbGoTop())

	While !(aApurac[R2050])->(eof())

		aAdd( oEstruct["tax"],JsonObject():New())
		nTAnalytic   :=  len(oEstruct["tax"])

		//Descri��o tributo
		oEstruct["tax"][nTAnalytic]["taxDescription"]  :=  alltrim(EncodeUTF8((aApurac[R2050])->DESCRI))

		//Valor base
		oEstruct["tax"][nTAnalytic]["taxBase"]  :=  (aApurac[R2050])->VLRBASE

		// Aliquota
		oEstruct["tax"][nTAnalytic]["aliquot"]  :=  (aApurac[R2050])->ALIQ

		// Valor tributo
		oEstruct["tax"][nTAnalytic]["value"]  :=  (aApurac[R2050])->VALOR

		(aApurac[R2050])->(DbSkip())
	EndDo

Return oEstruct

Function WSQry2050(cPerApu, aFil, nView, cChvNF, cItemNF)

	local cAlias2050 	as character
	Local cCompC1H	 	as Character
	Local cFiliais	 	as Character
	Local cQuery 	 		as Character
	Local cBd		 			as Character
	Local c2050TRB		as Character
	Local cAl2050		 	as Character
	Local nValIPI			as numeric
	Local nValICMSST	as numeric
	Local nVlIcmsFrt	as numeric
	Local aRet		 		as array
	Local aInfoEUF		as array
	Local aCamp				as array
	Local lIPI				as logical
	Local lICMSST			as logical
	Local lICMSFRETE	as logical
	Local oTemp2050		as object
	Local aIndTab		as array
	Local nTamItem		as numeric

	Default cChvNF	:= ""
	Default cItemNF	:= ""
	Default nView	:= 1

	cAlias2050 	:= GetNextAlias()
	cCompC1H		:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cFiliais		:= RetFil(aFil)
	cBd					:= TcGetDb()
	cQuery			:= ""
	aRet				:= {}
	aInfoEUF		:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	lICMSFRETE  := .F.
	c2050TRB		:= SuperGetMV("MV_2050TRB",," ")
	aIndTab := {}
	nTamItem	:= TamSX3("C30_NUMITE")[1]

	//SELECT
	If nView == 1
		cQuery	+= " C20.C20_FILIAL AS FILIAL, C30.C30_VLOPER AS VLRBRUTO, COUNT( DISTINCT C20_CHVNF) AS QTDDOC,"
		cQuery	+= " C20.C20_CHVNF AS CHVNF, C30.C30_NUMITE     AS NUMITEM,  "
		cQuery	+= " CASE "
		cQuery	+= " WHEN C20.C20_PROCID <> ' ' THEN '3' "
		cQuery	+= " WHEN C20.C20_PROCID = ' ' THEN ' ' "
		cQuery	+= " END AS STATUS "
	ElseIf nView == 2
		cQuery	+= " C20.C20_FILIAL AS FILIAL, C20.C20_CHVNF AS CHVNF, C20.C20_NUMDOC AS NUMDOC, "
		cQuery	+= " C20.C20_SERIE AS SERIE, C30.C30_NUMITE AS NUMITEM, "
		cQuery	+= " C20.C20_DTDOC AS DTEMISS, C30.C30_VLOPER AS VLRBRUTO "
	ElseIf nView == 3
		cQuery	+= " C3S.C3S_DESCRI AS DESCRI, C35.C35_BASE AS VLRBASE, "
		cQuery	+= " C35.C35_ALIQ AS ALIQ, C35.C35_VALOR AS VALOR "
	EndIf

	cQuery	+= " FROM " + RetSqlName("C20") + " C20 "

	//INNER JOIN
	cQuery	+= " INNER JOIN " + RetSqlName("C30") + " C30 ON "
	cQuery	+= " C30_FILIAL = C20.C20_FILIAL AND "
	cQuery	+= " C30.C30_CHVNF = C20.C20_CHVNF AND "
	cQuery	+= " C30.D_E_L_E_T_ = ' ' "
	cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
	cQuery	+= " C1H.C1H_ID = C20.C20_CODPAR AND "
	cQuery	+= " C1H.C1H_INDDES <> '1' AND "
	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = C20.C20_FILIAL AND "
	Else
		If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") AND "
		ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") AND "
		Else
			cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H")  + "' AND "
		EndIf
	EndIf

	cQuery	+= "  C1H.D_E_L_E_T_ = ' ' "
	cQuery	+= " INNER JOIN " + RetSqlName("C35") + " C35 ON
	cQuery	+= " C35.C35_FILIAL = C30.C30_FILIAL AND "
	cQuery	+= " C35.C35_CHVNF = C30.C30_CHVNF AND "
	cQuery	+= " C35.C35_NUMITE = C30.C30_NUMITE AND "
	cQuery	+= " C35.C35_CODTRI IN ('000013','000024','000025') AND "
	cQuery	+= " C35.D_E_L_E_T_ = ' ' "

	If nView == 3
		cQuery	+= " INNER JOIN " + RetSqlName("C3S") + " C3S ON "
		cQuery	+= " C3S.C3S_FILIAL = '" + xFilial("C3S") + "' AND "
		cQuery	+= " C3S.C3S_ID = C35.C35_CODTRI AND "
		cQuery	+= " C3S.D_E_L_E_T_ = ' ' "
	EndIf

// WHERE
	cQuery	+= " WHERE C20.C20_FILIAL IN (" + cFiliais + ") AND "
	cQuery	+= " C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND "
	cQuery	+=  " C20.C20_INDOPE = '1' AND "
	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery	+=  " SUBSTR(C20.C20_DTDOC,1,6) = '"+ cPerApu +"' AND "
	ElseIf cBd $ "INFORMIX"
		cQuery	+=  " C20.C20_DTDOC[1,6] = '"+ cPerApu +"' AND "
	Else
		cQuery	+=  " SUBSTRING(C20.C20_DTDOC,1,6) = '"+ cPerApu +"' AND "
	EndIf
	If nView == 3 .And. !Empty(cChvNF) .And. !Empty(cItemNF)
		cQuery	+= " C20.C20_CHVNF = '" + cChvNF + "' AND "
		cQuery	+= " C30.C30_NUMITE = '" + cItemNF + "' AND "
	EndIf
	cQuery	+= " C30.C30_IDTSER = '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' AND "
	cQuery	+= " C30.C30_SRVMUN = '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' AND "
	cQuery	+= " C30.C30_CODSER = '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' AND "
	cQuery	+= " C30.C30_TPREPA = '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + "' AND "
	cQuery	+= " C20.D_E_L_E_T_ = ' ' "
	If nView == 1
		cQuery	+= " GROUP BY C20_FILIAL, C20_PROCID, C20_CHVNF, C30_NUMITE, C30_VLOPER "
		cQuery	+= " ORDER BY C20_FILIAL, C20_PROCID, C20_CHVNF, C30_NUMITE, C30_VLOPER "
	ElseIf nView == 2
		cQuery	+= " GROUP BY C20_FILIAL, C20_CHVNF, C20_NUMDOC, C20_SERIE, C30_NUMITE, C20_DTDOC, C30_VLOPER"
		cQuery	+= " ORDER BY C20_FILIAL, C20_CHVNF, C20_NUMDOC, C20_SERIE, C30_NUMITE, C20_DTDOC, C30_VLOPER"
	EndIf

	cQuery	:= "%" + cQuery + "%"

	BeginSql Alias cAlias2050
		SELECT
			%EXP:cQuery%	
	EndSql

	If nView != 3
		lIPI		:= Iif( "1" $ c2050TRB, .T., .F. ) // 1 - IPI
		lICMSST		:= Iif( "2" $ c2050TRB, .T., .F. ) // 2 - ICMS ST
		If TAFColumnPos("C30_ICMSFT")
			lICMSFRETE := Iif( "3" $ c2050TRB, .T., .F. ) // 3 - ICMS ST do frete
		EndIf

		If (cAlias2050)->(!EOF())

			DbSelectArea(cAlias2050)
			(cAlias2050)->(DbGoTop())

			cAl2050	:= GetNextAlias()
			If nView == 1
				aCamp := {	{'FILIAL'	,'C', TamSX3("C20_FILIAL")[1] 				,0} ,;	//CPERIODO+CTPINSC+CNRINSC
					{'VLRBRUTO'	,'N', 14 				,2} ,;
					{'QTDDOC'	,'N', 02 				,0} ,;
					{'CHVNF'	,'C', 15 				,0} ,;
					{'NUMITEM'	,'C', nTamItem 			,0} ,;
					{'STATUS'	,'C', 01 				,0}	}
					aIndTab := {'FILIAL', 'STATUS', 'CHVNF', 'NUMITEM', 'VLRBRUTO', 'QTDDOC' }
			Else
				aCamp := {	{'FILIAL'	,'C', TamSX3("C20_FILIAL")[1] 				,0} ,;	//CPERIODO+CTPINSC+CNRINSC
					{'CHVNF'	,'C', 15 				,0} ,;
					{'NUMDOC'	,'C', 60 				,0} ,;
					{'SERIE'	,'C', 20 				,0} ,;
					{'NUMITEM'	,'C', nTamItem 			,0} ,;
					{'DTEMISS'	,'C', 08 				,0} ,;
					{'VLRBRUTO'	,'N', 14 				,2}	}
					aIndTab := {'FILIAL', 'CHVNF', 'NUMDOC', 'SERIE', 'NUMITEM', 'DTEMISS', 'VLRBRUTO' }
			EndIf

			oTemp2050 := Nil
			oTemp2050	:= FWTemporaryTable():New(cAl2050, aCamp)
			oTemp2050:AddIndex('1', aIndTab)
			oTemp2050:Create()

			While (cAlias2050)->(!EOF())

				nValIPI 		:= 0
				nValICMSST	:= 0
				nVlIcmsFrt	:= 0

				nValIPI			+=	Iif(lIPI, GetValTRB((cAlias2050)->CHVNF, (cAlias2050)->NUMITEM, (cAlias2050)->FILIAL	, IPI), 0 )
				nValICMSST	+=	Iif(lICMSST, GetValTRB((cAlias2050)->CHVNF, (cAlias2050)->NUMITEM, (cAlias2050)->FILIAL, ICMS_ST), 0 )

				If lICMSFRETE
					nVlIcmsFrt += GetICMSFRT( (cAlias2050)->CHVNF, (cAlias2050)->NUMITEM, (cAlias2050)->FILIAL )
				EndIF

				RecLock(cAl2050, .T.)

				If nView == 1
					(cAl2050)->FILIAL		:= (cAlias2050)->FILIAL
					(cAl2050)->VLRBRUTO	:= (cAlias2050)->VLRBRUTO - nValIPI - nValICMSST - nVlIcmsFrt
					(cAl2050)->QTDDOC		:= (cAlias2050)->QTDDOC
					(cAl2050)->CHVNF		:= (cAlias2050)->CHVNF
					(cAl2050)->NUMITEM	:= (cAlias2050)->NUMITEM
					(cAl2050)->STATUS		:= (cAlias2050)->STATUS
				Else
					(cAl2050)->FILIAL		:= (cAlias2050)->FILIAL
					(cAl2050)->CHVNF		:= (cAlias2050)->CHVNF
					(cAl2050)->NUMDOC		:= (cAlias2050)->NUMDOC
					(cAl2050)->SERIE		:= (cAlias2050)->SERIE
					(cAl2050)->NUMITEM	:= (cAlias2050)->NUMITEM
					(cAl2050)->DTEMISS	:= (cAlias2050)->DTEMISS
					(cAl2050)->VLRBRUTO	:= (cAlias2050)->VLRBRUTO - nValIPI - nValICMSST - nVlIcmsFrt
				EndIf
				(cAl2050)->(MsUnLock())

				(cAlias2050)->(DbSkip())
			EndDo
			aAdd(aRet, { cAl2050 })
		EndIf
	EndIf

	If Empty(aRet)
		aAdd(aRet, { cAlias2050 })
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuração
para que fique no formato de execução do IN no SQL

@author Henrique Pereira
@since 08/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function RetFil(aFil)
	Local cRetFils	as Character
	Local nX		as Numeric

	cRetFils	:= ""
	nX			:= 0

	If !Empty(xFilial("C20")) .And. Len(aFil) > 0

		For nX := 1 to Len(aFil)
			If nX > 1
				cRetFils += " , '" + xFilial("C20", aFil[nX][2]) + "'"
			Else
				cRetFils += "'" + xFilial("C20", aFil[nX][2]) + "'"
			EndIf
		Next nX
	Else
		cRetFils := "'" + xFilial("C20") + "'"
	EndIf

Return cRetFils

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValTRB()
Pega o valor do IPI e do ICMSST na tabela C35 quando houver, para posteriormente somar ao valor bruto.
@author Matheus Prada	
@since 31/01/2019
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Static Function GetValTRB(cChvNF, cNumIte, cFil, cCodTrib)

	Local cAlC35	:= GetNextAlias()
	Local nRet 		:= 0

	BeginSql alias cAlC35
		SELECT C35_VALOR
		FROM %Table:C35% C35
		WHERE
			C35_FILIAL = %Exp:cFil%
			AND C35_CHVNF = %Exp:cChvNF%
			AND C35_NUMITE = %Exp:cNumIte%
			AND C35_CODTRI = %Exp:cCodTrib%
			AND C35.%NotDel%
	EndSql

	If (cAlC35)->(!EOF())
		nRet := (cAlC35)->C35_VALOR
	Endif

	(cAlC35)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetICMSFRT()
Pega o valor ICMS-ST do frete do item na tabela C30 quando houver, para posteriormente abater do valor bruto.
@author Matheus Prada	
@since 22/08/2019
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Static Function GetICMSFRT( cChvNF, cNumIte, cFil )

	Local cAlC30	:= GetNextAlias( )
	Local nRet 		:= 0

	BeginSql alias cAlC30
		SELECT C30_ICMSFT
		FROM %Table:C30% C30
		WHERE
			C30_FILIAL = %Exp:cFil%
			AND C30_CHVNF = %Exp:cChvNF%
			AND C30_NUMITE = %Exp:cNumIte%
			AND C30.%NotDel%
	EndSql

	If ( cAlC30 )->( !EOF( ) )
		nRet := ( cAlC30 )->C30_ICMSFT
	Endif

	( cAlC30 )->( DbCloseArea( ) )

Return nRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Fun��o respons�vel por retornar o procid da tabela de log que cont�m o motivo do erro da apura��o

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function KeyError(oEstruct, oValidationError)
    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oValidationError["registryKey"])
        if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
            if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
                cKeyError := oValidationError["registryKey"][nX]["error"]
            endif
        endif
    Next nX

return ( cKeyError )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryRel2050
Fun��o respons�vel por retornar a query para gera��o dp arquivo CSV

@author Katielly Feitosa 
@since 04/08/2020
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Function QryRel2050(cPerApu,  aFil)
	local aInfoEUF		as array
	local aRet 			as array 
	local cCompC1H		as character
	local cQuery 		as character
	local cBd			as character
	local cAliasApr		as character		
	local cFiliais		as character
	local nTamIDSUSP	as Numeric

	aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	aRet 		:= {}
	cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cQuery		:= ""
	cBd			:= TcGetDb()
	cAliasApr	:=	GetNextAlias()
	cFiliais	:= RetFil(aFil)
	nTamIDSUSP	:= 0

	//SELECT
	cQuery	:= " C20.C20_FILIAL AS FIL, C20.C20_CHVNF AS CHVNF, C20.C20_DTDOC AS DTEMISSAONF, C20.C20_SERIE AS SERIE,   "
	cQuery	+= " C20.C20_NUMDOC AS NUMDOC, C35_VALOR AS VALOR, C35_CODTRI AS CODTRI, "
	cQuery	+= " C30.C30_VLOPER AS VLRRECBRUTA, C30.C30_NUMITE AS NUMITE,"
	cQuery	+= " C1G.C1G_NUMPRO AS NUMPRO, T5L.T5L_INDDEC AS INDSUSP, T5L.T5L_CODSUS AS CODSUS, T9Q.T9Q_VALSUS AS VALSUS, " 

	cQuery 	+= " CASE "
	cQuery 	+= " WHEN C1H.C1H_PAA = '1'" 
	cQuery 	+= " THEN '8'"
	cQuery 	+= " WHEN C1H.C1H_PAA <> '1' AND "

	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery 	+= " SUBSTR(C0Y.C0Y_CODIGO,1,1) = '7' "

	ElseIf cBd $ "INFORMIX"
		cQuery 	+= " C0Y.C0Y_CODIGO[1,1] = '7'" 			

	Else //MSSQL,MYSQL,PROGRESS
		cQuery 	+= " SUBSTRING(C0Y.C0Y_CODIGO,1,1) = '7' "
	EndIf

	cQuery 	+= " THEN '9'"
	cQuery 	+= " WHEN C1H.C1H_PAA <> '1' AND "

	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery 	+= " SUBSTR(C0Y.C0Y_CODIGO,1,1) <> '7'"

	ElseIf cBd $ "INFORMIX"
		cQuery 	+= " C0Y.C0Y_CODIGO[1,1] <> '7'"

	Else //MSSQL,MYSQL,PROGRESS
		cQuery 	+= " SUBSTRING(C0Y.C0Y_CODIGO,1,1) <> '7'"
	EndIf
	cQuery	+= " THEN '1'"
	cQuery  += " END AS INDCOM, "
	cQuery  += " C20.R_E_C_N_O_ AS RECNO"
		
	cQuery	+= " FROM " + RetSqlName("C20") + " C20"

	//INNER JOIN
	cQuery	+= " INNER JOIN " + RetSqlName("C30") "
	cQuery	+= " C30 On C20.C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ <> '*' "
	cQuery	+= " AND C20.C20_CHVNF = C30.C30_CHVNF AND "
	cQuery	+= " C30.C30_IDTSER = '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' "
	cQuery	+= " AND C30.C30_SRVMUN = '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' "
	cQuery	+= " AND C30.C30_CODSER = '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' "
	cQuery	+= " AND C30.C30_TPREPA = '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + "' "	

	cQuery	+= " INNER JOIN " + RetSqlName("C35") "
	cQuery	+= " C35 On C30.C30_FILIAL = C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND "
	cQuery	+= " C30.C30_NUMITE = C35.C35_NUMITE AND C35.C35_CODTRI IN ('000013','000024','000025') "
	cQuery	+= " AND C35.D_E_L_E_T_ <> '*' "

	cQuery	+= " INNER JOIN " + RetSqlName("C1H") "
	cQuery	+= " C1H ON C1H.C1H_ID = C20.C20_CODPAR " 
	cQuery	+= " AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ <> '*' "

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
	Else
		If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
		ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
		Else
			cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
		EndIf
	EndIf

	cQuery	+= " INNER JOIN " + RetSqlName("C0Y") "
	cQuery	+= " C0Y ON C0Y.C0Y_ID = C30.C30_CFOP "

	cQuery	+= " LEFT JOIN " + RetSqlName("T9Q") + " T9Q ON "
	cQuery	+= "  T9Q.T9Q_FILIAL = C30.C30_FILIAL "
	cQuery	+= " AND T9Q_CHVNF = C30.C30_CHVNF "
	cQuery	+= " AND T9Q.T9Q_CODTRI = C35.C35_CODTRI "
	cQuery	+= " AND T9Q.D_E_L_E_T_ = ' ' "

	cQuery +=  " LEFT JOIN " +  RetSqlName("C1G") + " C1G ON "
	cQuery += " C1G.C1G_FILIAL = '" + xFilial("C1G") + "' AND "
	cQuery += " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ <> '*' "

	If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
		if cBd $ "POSTGRES"
			nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
			cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND  T9Q.T9Q_FILIAL = C20.C20_FILIAL  AND "
		Else
			cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS AND  T9Q.T9Q_FILIAL = C20.C20_FILIAL  AND "
		Endif
	Else
		cQuery += " LEFT JOIN " + RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L.T5L_ID+T5L.T5L_VERSAO+T5L.T5L_CODSUS AND  T9Q.T9Q_FILIAL = C20.C20_FILIAL  AND "
	EndIf
	cQuery += " T5L.D_E_L_E_T_ <> '*' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

	//WHERE
	cQuery	+= " WHERE C20.C20_FILIAL IN (" + cFiliais + ")  "
	cQuery	+= " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
	cQuery	+= " AND C20.D_E_L_E_T_ <> '*'  "
	cQuery	+= " AND C20.C20_INDOPE = '1' AND "

	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery	+=  " SUBSTR(C20.C20_DTDOC,1,6) = '"+ cPerApu +"'"
			
	ElseIf cBd $ "INFORMIX"
		cQuery	+=  " C20.C20_DTDOC[1,6] = '"+ cPerApu +"'"

	Else
		cQuery	+=  " SUBSTRING(C20.C20_DTDOC,1,6) = '"+ cPerApu +"'"
	EndIf

	cQuery += " ORDER BY 1,2,9"

	cQuery		:= "%" + cQuery + "%"

	BeginSql Alias cAliasApr

		COLUMN DTEMISSAONF AS DATE
		
		SELECT distinct
			%EXP:cQuery%	
	EndSql

	aAdd(aRet, { cAliasApr })

Return aRet
