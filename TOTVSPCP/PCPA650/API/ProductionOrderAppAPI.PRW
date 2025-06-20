#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PRODUCTIONORDERAPPAPI.CH"

#DEFINE RETURN_POS_STATUS     1
#DEFINE RETURN_POS_ERROR      2
#DEFINE RETURN_POS_ERROR_CODE 1
#DEFINE RETURN_POS_ERROR_MSG  2
#DEFINE RETURN_POS_JSON       3

WSRESTFUL prodOrderApp DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ordem de Produ��o App Minha Producao"

	WSDATA Product      AS STRING  OPTIONAL
    WSDATA FormCode     AS STRING  OPTIONAL
    WSDATA Fields		AS STRING  OPTIONAL
	WSDATA Order		AS STRING  OPTIONAL
	WSDATA Page			AS INTEGER OPTIONAL
	WSDATA PageSize		AS INTEGER OPTIONAL
    WSDATA FilterSearch AS STRING  OPTIONAL

	WSMETHOD POST prodOrder;
	    DESCRIPTION STR0002; //"Inclui a ordem de produ��o"
		WSSYNTAX "api/pcp/v1/prodOrder";
		PATH "/api/pcp/v1/prodOrder";
		TTALK "v1"

	WSMETHOD GET productInfo;
	    DESCRIPTION STR0003; //"Busca as informa��es do produto"
		WSSYNTAX "api/pcp/v1/productInfo";
		PATH "/api/pcp/v1/productInfo";
		TTALK "v1"

	WSMETHOD GET queryProducts;
	    DESCRIPTION STR0008; //"Busca os produtos"
		WSSYNTAX "api/pcp/v1/queryProducts";
		PATH "/api/pcp/v1/queryProducts";
		TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET productInfo WSRECEIVE Product, FormCode WSSERVICE prodOrderApp
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a fun��o para retornar os dados.
	aReturn := GetPrdInfo(Self:Product, Self:FormCode)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

Static Function GetPrdInfo(cProduct, cFormCode)
	Local aResult    :={.T., "", 200}
    Local cChave     := ""
    Local cJson      := ""
    Local cMsg       := STR0004
	Local lRet       := .F.
	Local oJson      := JsonObject():New()
    Local oPrdOrd    := Nil
    Local __lPEGetOP := ExistBlock("POGetPdInf")

    oJson["C2_PRODUTO"] := cProduct

    oPrdOrd := ProductionOrder():New(.F.)
    If oPrdOrd:validaProduto( oJson,"I")
        cChave := xFilial("SB1") + oJson['C2_PRODUTO']

        SB1->(dbSetOrder(1))
        lRet := cChave == SB1->B1_FILIAL + SB1->B1_COD .Or. SB1->(dbSeek(xFilial("SB1") + oJson["C2_PRODUTO"]))

        If lRet
            oJson["C2_PRODESC"] := SB1->B1_DESC
            oJson["C2_LOCAL"  ] := AllTrim(RetFldProd(SB1->B1_COD,"B1_LOCPAD"))
            oJson["C2_UM"     ] := AllTrim(SB1->B1_UM)
            oJson["C2_ROTEIRO"] := AllTrim(A650VldRot(SB1->B1_COD, SB1->B1_OPERPAD))
            oJson["C2_REVISAO"] := AllTrim(IIF(SuperGetMv("MV_REVFIL",.F.,.F.), PCPREVATU(SB1->B1_COD), SB1->B1_REVATU))
            oJson["C2_SEGUM"  ] := AllTrim(SB1->B1_SEGUM)
            oJson["C2_CC"     ] := AllTrim(SB1->B1_CC)
                          
            oJson["C2_PRIOR"  ] :=  "500"
            oJson["C2_EMISSAO"] :=  DTOC(date())
            oJson["C2_TPPR"   ] := "I"
            oJson["C2_STATUS"]  := "N"
            oJson["C2_TPOP"]    := "F"
            oJson["C2_OPTERCE"] := "2"
            oJson["C2_DIASOCI"] := SuperGetMV('MV_DIASOCI',.F.,99)


            cJson := oJson:ToJson()
            If __lPEGetOP
                cJson := ExecBlock("POGetPdInf", .F., .F., {cJson, cFormCode})
            EndIf

        EndIf
    EndIf

	If lRet
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(cJson)
		aResult[3] := 200
	Else
        aResult[1] := .F.
        If Len(oPrdOrd:aReturn) >= 2 .And. Len(oPrdOrd:aReturn[2]) == 2
            cMsg := EncodeUTF8(oPrdOrd:aReturn[2][2])
        EndIf
        aResult[2] := cMsg
        aResult[3] := 400
	EndIf

	FreeObj(oJson)
    FreeObj(oPrdOrd)

Return aResult

WSMETHOD POST prodOrders WSSERVICE prodOrderApp

	Local aResult    := {.T., {0,""}, ""}
    Local aRetVld    := {.T.,""}
    Local cJson      := Self:GetContent()
    Local lRet       := .T.
    Local lPEPostVld := ExistBlock("POPostVld")
    Local lPEPostMnt := ExistBlock("POPostMnt")
    Local oPrdOrder  := Nil

	Self:SetContentType("application/json")

    If lPEPostMnt
        cJson := ExecBlock("POPostMnt", .F., .F., {cJson})
	EndIf

    If lPEPostVld
        aRetVld := ExecBlock("POPostVld", .F., .F., {cJson})
	EndIf

    If aRetVld[1]
        oPrdOrder := ProductionOrder():New()
        aResult   := oPrdOrder:incluiOP(cJson)
        oPrdOrder:Destroy()
        FreeObj(oPrdOrder)
    Else
        lRet := .F.
        aResult[RETURN_POS_STATUS] := aRetVld[1]
        aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_MSG] := aRetVld[2]
        aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_CODE] := 400
    EndIf

    If !aResult[RETURN_POS_STATUS]
        SetRestFault(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_CODE], EncodeUTF8(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_MSG]))
        lRet := .F.
    Else
        Self:SetResponse(aResult[RETURN_POS_JSON])
    EndIf

	FwFreeArray(aResult)

Return lRet

WSMETHOD GET queryProducts WSRECEIVE Fields,Order,Page,PageSize,FilterSearch,FormCode WSSERVICE prodOrderApp
    Local cQuery     := ""
	Local cAlias     := GetNextAlias()
	Local lRet       := .T.
    Local nStart     := 0
    Local nCount     := 0
	Local oJson      := JsonObject():New()
    Local __lPEGetPr := ExistBlock("POGetProd")

    DEFAULT ::Fields   := "Code,Description,Barcode"
    DEFAULT ::Page     := 1
	DEFAULT ::PageSize := 20
	DEFAULT ::Order    := "Code"

    Self:SetContentType("application/json")

	If Empty(::FilterSearch)
		SetRestFault(400, EncodeUTF8(STR0006)) //"Texto da pesquisa n�o informado"
		lRet := .F.
	ElseIf Empty(::FormCode)
		SetRestFault(400, EncodeUTF8(STR0007)) //"Formul�rio n�o informado"
		lRet := .F.    
	EndIf

	If lRet
		cQuery := "SELECT B1_COD Code,B1_DESC Description,B1_CODBAR Barcode FROM "+RetSqlName("SB1")+" SB1 "
		cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
        cQuery += " AND (SB1.B1_COD LIKE '%"+::FilterSearch+"%' OR SB1.B1_DESC LIKE '%"+::FilterSearch+"%' OR SB1.B1_CODBAR LIKE '%"+::FilterSearch+"%') "
        cQuery += "ORDER BY " + ::Order + " "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

        If ::Page > 1
            nStart := ( (::Page-1) * ::PageSize )
            If nStart > 0
                (cAlias)->(DbSkip(nStart))
            EndIf
        EndIf

        oJson['items'] := {}
        While (cAlias)->(!Eof())
            nCount++

            Aadd(oJson['items'], JsonObject():New())
            oJson['items'][nCount]["Code"]          := (cAlias)->Code
            oJson['items'][nCount]["Description"]   := (cAlias)->Description
            oJson['items'][nCount]["CustomLabel1"]  := ""
            oJson['items'][nCount]["CustomValue1"]  := ""
            oJson['items'][nCount]["CustomLink1"]   := ""
            oJson['items'][nCount]["CustomLabel2"]  := ""
            oJson['items'][nCount]["CustomValue2"]  := ""
            oJson['items'][nCount]["CustomLink2"]   := ""

            (cAlias)->(dbSkip())

            If nCount >= ::PageSize
                Exit
            EndIf
	    End

        If __lPEGetPr
            oJson['items'] := ExecBlock("POGetProd", .F., .F., {oJson['items'], ::FormCode})
        EndIf

        oJson["hasNext"] := (cAlias)->(!Eof())

        If Len(oJson['items']) > 0
            ::SetResponse(EncodeUTF8(oJson:toJson()))
        Else
            SetRestFault(400, EncodeUTF8(STR0004)) //"Nenhum registro encontrado"
            lRet := .F.        
        EndIf
            
		
	EndIf

	FreeObj(oJson)

Return lRet
