#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"


/*/{Protheus.doc} GPESAPIRA4
Realiza chamada da API de Historico de Treinamentos para envio dos dados à integração com a NG.
@type  Function
@author martins.marcio
@since 22/04/2020
@version 1.0
/*/
Function GPESAPIRA4(aData)

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

    Local cOperac   := ""
    Local cId       := ""
    Local cEmployee := ""
    Local cTraining := ""
    Local lHeader   := .T.
    Local cCodSucss := "200|201|202|203|204"
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

	// Montagem do Header
	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    aAdd(aHeader, "Authorization: " +cAuthlg)

    For nI := 1 To Len(aData)

        cOperac     := aData[nI][1]
        cId         := aData[nI][3]

        oBody := JsonObject():new()
        oBody['id']     := cId

         // Montagem dos demais campos do Body
        If !(cOperac == "E")
            cEmployee   := aData[nI][4] + "|" + aData[nI][5] + "|" + aData[nI][6]
            cTraining   := aData[nI][4] + "|" + xFilial("RA1",aData[nI][5]) + "|" + aData[nI][8]

            oBody['erpId']              := aData[nI][3]
            oBody['erpCompany']         := aData[nI][4]
            oBody['erpBranch']          := aData[nI][5]
            oBody['employee']           := cEmployee
            oBody['expectedDate']       := formatDate(DtoS(aData[nI][7]))
            oBody['training']           := cTraining
            oBody['trainingDescription'] := aData[nI][9]
            oBody['completionDate']     := formatDate(DtoS(aData[nI][10]))
            oBody['approval']           := aData[nI][11]
            oBody['expirationDate']     := formatDate(DtoS(aData[nI][12]))

            cResource := "/ttalk/trainingHistory?branchId="+cBranc+"&companyId="+cCompany

        Else
            cResource := "/ttalk/trainingHistory"
            cResource += "/" + cId  // Id para exclusão
            cResource += "?branchId="+cBranc+"&companyId="+cCompany
        EndIf

        // Converte o objeto para texto e o compacta
        cBody := fComprJSn(@oBody)

        // Chamada da API
        oNG := FwRest():New(cURI)
        oNG:setPath(cResource)

        //Assumindo a responsabilidade de avaliar o HTTP Code retornado pela requisição
        oNG:SetChkStatus(.F.)

        oNG:SetPostParams(cBody)

        Do Case
            Case cOperac == "I"
                lHeader := oNG:Post(aHeader)
            Case cOperac == "A"
                lHeader := oNG:Put(aHeader,cBody)
            Case cOperac == "E"
                lHeader := oNG:Delete(aHeader)
        EndCase

        // Verificação de Retorno
        oRet := JsonObject():new()
        lRet := FWJsonDeserialize(oNG:GetResult(), @oRet)

        cRet	 := oNG:GetResult()
        cRetCode := oNG:GetHTTPCode()

        If !lRet .And. cOperac == "E" .And. cRetCode $ cCodSucss .AND. Empty(cRet)
            lRet := .T.
        EndIf

		If lRet .And. lHeader
            //Atualiza Retorno na RJP
            fAtuRJPRet(aData[nI][2], cRetCode, cRet)
        EndIf

        FreeObj( oBody )
        FreeObj( oRet )
        FreeObj( oNG )

    Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function formatDate
Return JSON Date Format
@author  Marcio Felipe Martins
@since   22/04/2020
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
