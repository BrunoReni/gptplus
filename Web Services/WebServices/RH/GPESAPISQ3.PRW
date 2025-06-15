#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} nomeFunction
Realiza chamada da API de Cargos para envio dos dados à integração.
@type  Function
@author Wesley Alves Pereira
@since 25/08/2020
@version 1.0
/*/
Function GPESAPISQ3(aData)
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
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)
    Local nRec      := 0
    Local lHeader   := .T.

	// Montagem do Header
	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    aAdd(aHeader, "Authorization: " + cAuthlg)

    For nI := 1 To Len(aData)
        cIde := aData[nI][3]
        cOpe := aData[nI][1]
        nRec := aData[nI][2]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"
            oBody := JsonObject():new()
            oBody['id']         := cIde
            oBody['description']    := aData[nI][8]
            oBody['observation']    := aData[nI][10]

            cBody       := fComprJSn(@oBody)
            cResource   := "/ttalk/position?branchId=" +cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/position"
            cResource += "/" + cIde // Parâmetro para exclusão
            cResource += "?branchId="+cBranc+"&companyId="+cCompany
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
