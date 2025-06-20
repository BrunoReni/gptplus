#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPIRD0
Realiza chamada da API de pessoas para envio dos dados � integra��o.
@type  Function
@author Wesley Alves Pereira
@since 05/05/2020
@version 1.0
/*/
Function GPESAPIRD0(aData)
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
    Local cPhone    := ""
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)
    Local nRec      := 0
    Local lHeader   := .T.

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
            oBody['company']        := aData[nI][04]
            oBody['branch']         := aData[nI][05]
            oBody['registration']   := aData[nI][06]
            oBody['name']           := ALLTRIM(aData[nI][07])
            oBody['birth']          := formatDate(aData[nI][08])
            oBody['cpf']            := aData[nI][09]
            oBody['gender']         := aData[nI][10]

            If !Empty(aData[nI][11])
                oBody['rg'] := ALLTRIM(aData[nI][11])
            EndIf

            If !Empty(aData[nI][12])
                oBody['email'] := ALLTRIM(aData[nI][12])
            EndIf

            oBody['street']         := ALLTRIM(aData[nI][13])
            oBody['number']         := aData[nI][14]
            oBody['district']       := ALLTRIM(aData[nI][15])
            oBody['city']           := ALLTRIM(aData[nI][16])
            oBody['zipCode']        := ALLTRIM(aData[nI][17])

            cPhone := fFormTel(ALLTRIM(aData[nI][18]), ALLTRIM(aData[nI][19]))

            If !Empty(cPhone)
                oBody['phone'] := cPhone
            EndIf

            cBody := fComprJSn(@oBody)
            cResource := "/ttalk/person?branchId="+cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/person"
            cResource += "/" + cIde // Par�metro para exclus�o
            cResource += "?branchId="+cBranc+"&companyId="+cCompany
        EndIf

        oNG := FwRest():New(cURI)
        oNG:setPath(cResource)

        //Assumindo a responsabilidade de avaliar o HTTP Code retornado pela requisi��o
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
/*/{Protheus.doc} function formatDate
Return JSON Date Format
@author  Wesley Alves Pereira
@since   05/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function formatDate(cDate)
	Local cNewDate := ""

	DEFAULT cDate := ""

	IF !Empty(cDate)
		cNewDate := SubStr(cDate,1,4)+"-"+SubStr(cDate,5,2)+"-"+SubStr(cDate,7,2)+"T"+"00:00:00"
	Else
        cNewDate := "2099-12-31T00:00:00"
    EndIf

Return cNewDate
