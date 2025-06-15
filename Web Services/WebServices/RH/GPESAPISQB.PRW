#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISQB
Realiza chamada da API de departamentos para envio dos dados à integração.
@type  Function
@author Gisele Nuncherino
@since 18/08/2020
@version 1.0
/*/
Function GPESAPISQB(aData)
    Local oBody
    Local oRet
	Local oNG

    Local lRet	 	:= .F.
  	Local aHeader   := {}
    Local cBody     := ""
    Local nI        := 0

    Local cURI      := GetNewPar("MV_URIQR", Space(255))
    Local cResource := ""
    Local cUsrNG    := AllTrim(Decode64(GetNewPar("MV_EMAILQR", Space(255))))
    Local cPassNG   := AllTrim(Decode64(GetNewPar("MV_SENHAQR", Space(255))))
    Local cAuthlg   := "Basic " + Encode64(AllTrim(cUsrNG) + ":" + AllTrim(cPassNG))

    Local cIde      := ""
    Local cOpe      := ""
    Local nRec      := 0
    Local lHeader   := .T.
	Local cCompany  := Escape(cEmpAnt)

	// Montagem do Header
	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    aAdd(aHeader, "Authorization: " +cAuthlg)

    For nI := 1 To Len(aData)
        cIde := aData[nI][3]
        cOpe := aData[nI][1]
        nRec := aData[nI][2]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"
            oBody := JsonObject():new()
            oBody['id']             := cIde
            oBody['description']    := aData[nI][06]


            cBody := fCompress(@oBody)
            cResource := "/ttalk/department?branchId="+Escape(cFilAnt)+"&companyId="+cCompany
        Else
            cResource := "/ttalk/department"
            cResource += "/" + cIde // Parâmetro para exclusão
            cResource += "?branchId="+Escape(cFilAnt)+"&companyId="+cCompany
        EndIf

        oNG := FwRest():New(cURI)
        oNG:setPath(cResource)

        //Assumindo a responsabilidade de avaliar o HTTP Code retornado pela requisição
        oNG:SetChkStatus(.F.)

        Do Case
            Case cOpe == "I"
                oNG:SetPostParams(cBody)
                lHeader := oNG:Post(aHeader)
            Case cOpe == "A"
                oNG:SetPostParams(cBody)
                lHeader := oNG:Put(aHeader,cBody)
            Case cOpe == "E"
                lHeader := oNG:Delete(aHeader)
        EndCase

        oRet := JsonObject():new()
        lRet := FWJsonDeserialize(oNG:GetResult(), @oRet)

        cRet	 := oNG:GetResult()
        cRetCode := oNG:GetHTTPCode()

        If cRetCode == "204" .AND. lHeader .AND. cOpe == "E" .AND. Empty(cRet)
            lRet := .T.
        EndIf

        If lRet .And. lHeader
           fAtuRJPRet(aData[nI][2], cRetCode, cRet) // Atualiza Retorno na RJP
        EndIf

        FreeObj( oBody )
        FreeObj( oRet )
        FreeObj( oNG )

    Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Gisele Nuncherino
@since   18/08/2020
@version 1.0
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
