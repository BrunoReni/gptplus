#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PONA080API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

#DEFINE TAB 			 CHR ( 13 ) + CHR ( 10 )


/*
{Protheus.doc} WorkingShift
	API de Cadastro de Turnos                             
		
	@author	raquel.andrade
	@version	P12
	@since	27/01/2020
*/

WSRESTFUL workingshift DESCRIPTION STR0001 FORMAT "application/json" // STR0001: "Servi�o gen�rico para retorno das informa��es de Cadastro de Turnos."
	WSDATA companyId	 As String
	WSDATA branchId	     As String
	WSDATA page			 As Integer Optional
	WSDATA pageSize		 As Integer Optional
	WSDATA dateModified	 As String  Optional

	WSMETHOD GET DESCRIPTION oEmToAnsi(STR0006) PRODUCES 'application/json;charset=utf-8' WSSYNTAX "/api/rh/v1/workingshift/" PATH "/api/rh/v1/workingshift/" TTALK "v2"

END WSRESTFUL

WSMETHOD GET WSRECEIVE companyId, branchId, page, pageSize, dateModified WSSERVICE workingshift
	Local cResponse 	:= ""
	Local lRet 			:= .T.
	
	Local cCompanId := ""
	Local cBranchId := ""
	Local nNumePage	:= 1
	Local nPageSize := 1
	Local cDtUpDate := ""
	
	Local oGroupData := JsonObject():new()
		
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )
	Private oError
	
	DEFAULT Self:companyId 		:= ""
	DEFAULT Self:branchId 		:= ""
	DEFAULT Self:page 			:= PAGE_DEFAULT
	DEFAULT Self:pageSize 		:= PAGESIZE_DEFAULT
	DEFAULT Self:dateModified 	:= ""
	
	BEGIN SEQUENCE
	
		cCompanId := Self:companyId
		cBranchId := Self:branchId
		nNumePage := Self:page
		nPageSize := Self:pageSize
		cDtUpDate := Self:dateModified

		fResetErrorHandler()
		fSetErrorHandler(oEmToAnsi(STR0010)) // STR0010: "Erro ao preparar o ambiente com a Empresa e Filial informados!"
		
		// Set Default nPageSize
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		
		// Set Default nPage
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf

		If ! fcheckInfor(cCompanId,cBranchId,nNumePage,nPageSize,cDtUpDate)		
			lRet := .F.
			Return ( lRet )
		EndIf
		
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanId FILIAL cBranchId TABLES "SR6" MODULO "PON"

		fResetErrorHandler()

		If !fcheckDic()
			lRet := .F.
			Return ( lRet )
		EndIf
		
		// Create employeeList Object And items
		lRet := fGetData(@oGroupData, nNumePage, nPageSize, cDtUpDate)
		
		// Compress String And Set Response
		cResponse := fCompress(@oGroupData)
		::SetResponse(cResponse)		

	RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
		fSendError(500,oError:Description,.T.,500,STR0002,,) // STR0002: "Ocorreu uma falha no retorno da informa��oo."		
	END SEQUENCE

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetErrorHandler
Seta c�digo e mensagem de erro
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSetErrorHandler(cTitle)

bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
bErrorBlock    := ErrorBlock( bError )

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fResetErrorHandler
Reseta c�digo e mensagem de erro
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fResetErrorHandler(cTitle)

bError  := { |e| oError := e , Break(e) }
bErrorBlock    := ErrorBlock( bError )

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informa��es recebidas na assinatura da mensagem
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor(cCompanId,cBranchId,nNumePage,nPageSize,cDtUpDate)
Local dDataAss
Local cMessage := ""
Local cFormData := " (yyyy-mm-ddThh:mm:ss)"
If Empty(cCompanId)
	cMessage := oEmToAnsi(STR0004) + "companyId"
ElseIf Empty(cBranchId)
	cMessage := oEmToAnsi(STR0004) + "branchId"
EndIf

If ! Empty( cDtUpDate ) 
	If ! fValidDate(cDtUpDate)
		cMessage := oEmToAnsi(STR0004) + "dateModified" + cFormData
	EndIf
EndIf

If ! Empty( cDtUpDate )
	dDataAss := fClearDate(cDtUpDate) 
	lDataUp := .T.
	
	If Empty(cMessage)
		If Empty( dDataAss ) 
			cMessage := oEmToAnsi(STR0004) + "dateModified" + cFormData
		EndIf
	EndIf
EndIf

If Empty(cMessage)
	If ! FWFilExist(cCompanId,cBranchId)
		cMessage := oEmToAnsi(STR0004) + "companyId + branchId "
	EndIf	
EndIf

If ! Empty(cMessage)
	
	fSendError(400,cMessage,.T.,400,cMessage,,)
	
	Return (.F.)
	
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckDic
Valida a cria��o dos campos R6_USERLGA e R6_USERLGI
@author  raquel.andrade
@since   20/09/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckDic()
Local lRHULGA  := If(SR6->(ColumnPos("R6_USERLGA")) > 0, .T., .F.)
Local lRHULGI  := If(SR6->(ColumnPos("R6_USERLGI")) > 0, .T., .F.)
Local cMessage := ""

	If !lRHULGA
		cMessage := oEmToAnsi(STR0003) + oEmToAnsi(STR0007)// STR0003 + STR0007 : "Campo USERLGA n�o foi encontrado. Entidade (SR6)."
	ElseIf !lRHULGI
		cMessage := oEmToAnsi(STR0005) + oEmToAnsi(STR0007)// STR0005 + STR0007 : "Campo USERLGI n�o foi encontrado. Entidade (SR6)."
	EndIf

	If !Empty(cMessage)		
		fSendError(400,cMessage,.T.,400,cMessage,,)		
		Return (.F.)		
	EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetData
Busca os dados referente ao Cadastro de Turnos
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fGetData(oGroupData, nNumePage, nPageSize, cDtUpDate)

	Local cQuery  	 := ""
	Local lRet 		 := .T.
	Local dDataAss
	Local lDataUp    := .F.
	Local oItemData
	Local aItemQry   := {}    
	Local oCabecData := JsonObject():new()
	Local cDataBase  := TcGetDB() 
	Local cIdTab := ""
	
	Local cQrAlias := GetNextAlias()
	
	dbSelectArea("SR6")
	
	If ! Empty( cDtUpDate )
		dDataAss := fClearDate(cDtUpDate) 
		lDataUp := .T.
	EndIf
	
	// Create Paging Control
	cQuery := "		SELECT JSO.* FROM ( "
		
	If cDataBase == "ORACLE"
		cQuery +=  "	SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  "
	ElseIF cDataBase == "POSTGRES"
		cQuery += "		SELECT ROW_NUMBER() OVER( ORDER BY RECNO ) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, DADOS.* "
	Else
		cQuery += "		SELECT ROW_NUMBER() OVER( ORDER BY RECNO ) ITEMNUMBER, COUNT(1) OVER() TOTALNUMBER, DADOS.* "
	EndIf
	
	cQuery += "			FROM (	"
	cQuery += "			SELECT SR6.R_E_C_N_O_ RECNO, "
	cQuery += "					SR6.R6_FILIAL,	"
	cQuery += "					SR6.R6_TURNO,	"
	cQuery += "					SR6.R6_DESC,	"
	cQuery += "					SR6.R6_REVEZAM,	"
	cQuery += "					SR6.R6_HRNORMA 	"
	
	cQuery += "			FROM "+ RetSqlName("SR6") + " SR6"
	cQuery += "			WHERE SR6.D_E_L_E_T_ = ''	"
	cQuery += "			AND   SR6.R6_FILIAL = '" +xFilial("SR6") + "'" 
	
	// Tratamento para n�o considerar os registros bloqueados
	If SR6->(ColumnPos("R6_MSBLQL")) > 0
		cQuery += " AND R6_MSBLQL != '1' "
	EndIf
	If SR6->(ColumnPos("R6_MSBLQD")) > 0
		cQuery += " AND ( R6_MSBLQD = '        ' OR R6_MSBLQD > '" + dToS(Date()) + "')"
	EndIf
	
	If lDataUp
		cQuery += "     AND ( " 
			
			cQuery += "R6_USERLGA <> ' ' "
			If cDataBase == "ORACLE"
				cQuery += " 	AND REPLACE(TO_DATE('19960101','YYYYMMDD') + TO_NUMBER(CONCAT(TO_CHAR(ASCII(SUBSTR(RTRIM(R6_USERLGA),12,1))-50), TO_CHAR(ASCII(SUBSTR(R6_USERLGA,16,1))-50))) ,'/','') >= '" + DTOS(dDataAss) + "'"		
			ElseIF cDataBase == "POSTGRES"
				cQuery += "AND (REPLACE(CAST(to_date('19960101','YYYYMMDD') + " 
				cQuery += "CAST(CONCAT(REPLACE(CAST((ASCII(SUBSTR(R6_USERLGA,12,1))-50) AS VARCHAR),' ',''),"
				cQuery += "REPLACE(CAST((ASCII(SUBSTR(R6_USERLGA,16,1))-50) AS VARCHAR),' ','')) AS INT ) AS VARCHAR ),'-','')) >= '" + DTOS(dDataAss) + "' "
			ElseIF cDataBase == "DB2"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(R6_USERLGA,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(R6_USERLGA,16,1))-50 AS CHAR),' ','')) AS INT) '19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "INFORMIX"
				cQuery += " AND REPLACE(CAST(CAST( ADD_DAYS ('1996-01-01',CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(R6_USERLGA,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(R6_USERLGA,16,1))-50 AS CHAR),' ',''))AS INT)) AS INT) AS CHAR),'.','') >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "MYSQL"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(R6_USERLGA,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(R6_USERLGA,16,1))-50 AS CHAR),' ','')) AS INT),'19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			Else
				cQuery += " AND REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(R6_USERLGA),12,1))-50)+CONVERT(VARCHAR,ASCII(SUBSTRING(R6_USERLGA,16,1))-50)),'19960101'), 102),'.','')   >= '" + DTOS(dDataAss) + "'"			
			EndIf
	
			cQuery += "     OR " 
	
			cQuery += "R6_USERLGI <> ' ' "
			If cDataBase == "ORACLE"
				cQuery += " 	AND REPLACE(TO_DATE('19960101','YYYYMMDD') + TO_NUMBER(CONCAT(TO_CHAR(ASCII(SUBSTR(RTRIM(R6_USERLGI),12,1))-50), TO_CHAR(ASCII(SUBSTR(R6_USERLGI,16,1))-50))) ,'/','') >= '" + DTOS(dDataAss) + "'"		
			ElseIF cDataBase == "POSTGRES"
				cQuery += "AND (REPLACE(CAST(to_date('19960101','YYYYMMDD') + " 
				cQuery += "CAST(CONCAT(REPLACE(CAST((ASCII(SUBSTR(R6_USERLGI,12,1))-50) AS VARCHAR),' ',''),"
				cQuery += "REPLACE(CAST((ASCII(SUBSTR(R6_USERLGI,16,1))-50) AS VARCHAR),' ','')) AS INT ) AS VARCHAR ),'-','')) >= '" + DTOS(dDataAss) + "' "
			ElseIF cDataBase == "DB2"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(R6_USERLGI,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(R6_USERLGI,16,1))-50 AS CHAR),' ','')) AS INT) '19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "INFORMIX"
				cQuery += " AND REPLACE(CAST(CAST( ADD_DAYS ('1996-01-01',CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(R6_USERLGI,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(R6_USERLGI,16,1))-50 AS CHAR),' ',''))AS INT)) AS INT) AS CHAR),'.','') >= '" + DTOS(dDataAss) + "'"
			ElseIF cDataBase == "MYSQL"
				cQuery += " AND REPLACE(CONVERT(CHARACTER,DATEADD(DAY,CAST(CONCAT(REPLACE(CAST(ASCII(SUBSTR(R6_USERLGI,12,1))-50 AS CHAR),' ',''),REPLACE(CAST(ASCII(SUBSTR(R6_USERLGI,16,1))-50 AS CHAR),' ','')) AS INT),'19960101'),102),'.','')   >= '" + DTOS(dDataAss) + "'"
			Else
				cQuery += " AND REPLACE(CONVERT(VARCHAR, DATEADD(DAY,CONVERT(NUMERIC,CONVERT(VARCHAR,ASCII(SUBSTRING(RTRIM(R6_USERLGI),12,1))-50)+CONVERT(VARCHAR,ASCII(SUBSTRING(R6_USERLGI,16,1))-50)),'19960101'), 102),'.','')   >= '" + DTOS(dDataAss) + "'"			
			EndIf

		cQuery += "  ) " 

	EndIf	
	 
	cQuery += "			) DADOS "
	
	cQuery += "			) JSO"
	cQuery += "	        WHERE JSO.ITEMNUMBER BETWEEN " + Alltrim(Str((nNumePage - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((nNumePage * nPageSize))) + " "
	cQuery += "			ORDER BY 1,2,3,4,5	"
	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )
	
	// Check return Query
	IF !fValid(nNumePage, (cQrAlias)->ITEMNUMBER)
		lRet := .F.
	Endif
	
	(cQrAlias)->(DBGoTop())
	
	If lRet
		
		// Get items Properties
		While (cQrAlias)->(!Eof())
			
			oItemData := JsonObject():new()
			
			cIdTab := cEmpAnt                                         	+ "|"
			cIdTab += (cQrAlias)->R6_FILIAL								+ "|"
			cIdTab += (cQrAlias)->R6_TURNO									 
			
			oItemData["companyId"]			:= cEmpAnt						     
			oItemData["branchId"]			:= (cQrAlias)->R6_FILIAL			  						     
			oItemData["workShiftCode"]		:= (cQrAlias)->R6_TURNO			 						     
			oItemData["name"]				:= fSubstRH(AllTrim(Substr((cQrAlias)->R6_DESC,1,100)))
			oItemData["monthlyWorkingHours"]	:= Alltrim(STRTRAN(Transform((cQrAlias)->R6_HRNORMA,"@E 999.99"),",",":"))
			oItemData["relaySchema"]		:= AllTrim((cQrAlias)->R6_REVEZAM)												 
			oItemData["id"]					:= cIdTab
			
			AAdd(aItemQry, oItemData )
			
			oCabecData["hasNext"] 		  := Iif((cQrAlias)->ITEMNUMBER >= (cQrAlias)->TOTALNUMBER, .F., .T.)			
						
			(cQrAlias)->(DBSkip())
			
		EndDo
		
		oCabecData["items"] := aItemQry
		
		oGroupData := oCabecData
		
	EndIf

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fValid
Valida os dados da assinatura do metodo
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fValid(nNumePage, nItemNumb)
	Local cMessage := ""
	
	// Check Page
	If nItemNumb == 0
		cMessage := oEmToAnsi(STR0011) // STR0011: "Nenhum registro localizado."
	ElseIf nNumePage > nItemNumb
		cMessage := oEmToAnsi(STR0008) // STR0008: "A p�gina solicitada � maior do que a quantidade dispon�vel na consulta"
	EndIf

	If ! Empty(cMessage)
		fSendError(404,cMessage,.T.,404,cMessage,,)
		Return (.F.)
	Endif
	
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp

/*/{Protheus.doc} function fDateValid
Verify Date Input
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fValidDate(cDate)
	Local lRet := .T.

	// Formato Considerado como v�lido: "2001-01-01T18:25:43"
	If !Empty(cDate)
		If  SubStr(cDate, 5,  1) != "-" .OR. SubStr(cDate, 8,  1) != "-" .OR. ;
			SubStr(cDate, 11, 1) != "T" .OR. SubStr(cDate, 14, 1) != ":" .OR. ; 
			SubStr(cDate, 17, 1) != ":" .OR. ;
			Len(Alltrim(cDate)) < Len("2001-01-01T18:25:43") 
				lRet := .F.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function ClearDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fClearDate(cDate)
Local dData := STOD("")
	
	cDate := StrTran(cDate, "T", "")
	cDate := StrTran(cDate, ":", "")
	cDate := StrTran(cDate, "-", "")
	cDate := SubStr(cDate,1,8)
	dData := StoD(cDate)
	
Return ( dData )


//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  raquel.andrade
@since   27/01/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

DEFAULT nCode := 500
DEFAULT cMessage := STR0002
DEFAULT lJson := .T.
DEFAULT nStatus := 500
Default cDetailMsg := STR0002
Default cHelpUrl := "https://tdn.totvs.com/x/BJuMHw"
DEFAULT aDetails := {}

SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)
