#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "GPEM923.CH"
#INCLUDE "GPESAPISR7.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISR7
Realiza chamada da API de histórico funcional para envio dos dados à integração.
@type  Function
@author Wesley Alves Pereira
@since 28/04/2020
@version 1.0
/*/
Function GPESAPISR7(aData)

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
    Local cMat      := ""
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

	// Montagem do Header
	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    aAdd(aHeader, "Authorization: " +cAuthlg)

    For nI := 1 To Len(aData)

        cIde := aData[nI][03]
        cOpe := aData[nI][01]
        nRec := aData[nI][02]

        cMat := aData[nI][04]+"|"+aData[nI][05]+"|"+aData[nI][06]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"

            oBody := JsonObject():new()
            oBody['id']                          := cIde
            oBody['erpId']                       := cIde
            oBody['erpCompany']                  := aData[nI][04]
            oBody['erpBranch']                   := aData[nI][05]
            oBody['employee']                    := cMat
            oBody['occurrenceDate']              := formatDate(aData[nI][07])
            oBody['costCenter']                  := aData[nI][08]
            oBody['costCenterDescription']       := aData[nI][09]
            oBody['department']                  := aData[nI][10]
            oBody['departmentDescription']       := aData[nI][11]
            oBody['occupation']                  := aData[nI][12]
            oBody['occupationDescription']       := aData[nI][13]
            oBody['employeePosition']            := aData[nI][14]
            oBody['employeePositionDescription'] := aData[nI][15]
            oBody['sefipCategory']               := aData[nI][16]

            cBody := fComprJSn(@oBody)

            cResource := "/ttalk/functionalHistory?branchId="+cBranc+"&companyId="+cCompany

        Else

            cResource := "/ttalk/functionalHistory"
            cResource += "/" + StrTran( cIde, "|", "" ) // Parâmetro para exclusão
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

        If cRetCode == "202" .AND. lHeader .AND. cOpe == "E" .AND. Empty(cRet)
            lRet := .T.
        EndIf

        If lRet .AND. lHeader

            fAtuRJPRet(nRec, cRetCode, cRet)

        EndIf

    Next nI

    FreeObj( oBody )
    FreeObj( oRet )
    FreeObj( oNG )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function formatDate
Return JSON Date Format
@author  Wesley Alves Pereira
@since   28/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function formatDate(cDate)
	Local cNewDate := ""

	DEFAULT cDate := ""

	IF !Empty(cDate)
		cNewDate := FwTimeStamp( 6, Stod(cDate),"00:00:00")
	Else
        cNewDate := FwTimeStamp( 6, Stod("20991231"),"00:00:00")
    EndIf

Return cNewDate
