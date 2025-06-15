#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"


/*/{Protheus.doc} GPESAPISRA
Realiza chamada da API de Funcionários para envio dos dados à integração com a NG.
@type  Function
@author martins.marcio
@since 24/04/2020
@version 1.0
/*/
Function GPESAPISRA(aData)

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
    Local nGenerFun := 0 // 1-M / 2-F
    Local nStatFunc := 0 //1 - Ativo / 2 - Demitido / 3 - Férias / 4 - Afastado / 5 - Atestado / 6 - Quitação
    Local lHeader   := .T.
    Local cCodSucss := "200|201|202|203|204"
    Local cPhone    := ""
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

	// Montagem do Header
	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    aAdd(aHeader, "Authorization: " +cAuthlg)

    For nI := 1 To Len(aData)

        cOperac     := aData[nI][1]
        cId         := aData[nI][3]
        nGenerFun   := IIf(aData[nI][10] == "M",1,IIf(aData[nI][10] == "F",2,0))
        nStatFunc   := fGetSitua(aData[nI][23]) //RA_SITFOLH
        cPhone      := fFormTel(ALLTRIM(aData[nI][22][1]), ALLTRIM(aData[nI][22][2]))

        oBody := JsonObject():new()
        oBody['id']     := aData[nI][3]

        // Montagem dos demais campos do Body
        If !(cOperac == "E")
            oBody['id']          := aData[nI][3]
            oBody['erpCompany']     := aData[nI][4]
            oBody['erpBranch']      := aData[nI][5]
            oBody['registration']   := aData[nI][6]
            oBody['name']           := aData[nI][7]
            oBody['birth']          := formatDate(DtoS(aData[nI][8]))
            oBody['cpf']            := aData[nI][9]
            oBody['gender']         := nGenerFun
            If !Empty(aData[nI][11])
                oBody['rg']         := AllTrim(aData[nI][11])
            EndIf
            If !Empty(aData[nI][12])
                oBody['email']      := aData[nI][12]
            EndIf
            oBody['workshift']      := aData[nI][13]
            oBody['workshiftDescription'] := aData[nI][30]
            oBody['costCenter']     := aData[nI][14]
            oBody['costCenterDescription']  := aData[nI][31]
            oBody['occupation']     := aData[nI][15]
            oBody['occupationDescription']  := aData[nI][32]
            oBody['department']  := aData[nI][16]
            oBody['departmentDescription']  := aData[nI][33]
            oBody['street']         := aData[nI][17]
            oBody['number']         := Val(aData[nI][18])
            oBody['district']       := aData[nI][19]
            oBody['city']           := aData[nI][20]
            oBody['zipCode']        := aData[nI][21]
            If !Empty(cPhone)
                oBody['phone']      := cPhone
            EndIf
            oBody['situation']      := nStatFunc
            oBody['eSocialRoleId']  := aData[nI][24]
            oBody['admissionDate']  := formatDate(DtoS(aData[nI][25]))
            If !Empty(aData[nI][26])
                oBody['dismissalDate']  := formatDate(DtoS(aData[nI][26]))
            Else
                oBody['dismissalDate']  := Nil
            Endif
            oBody['pisCode']        := aData[nI][27]
            oBody['eSocialId']      := aData[nI][28]
            oBody['sefipCategory']  := aData[nI][29] //13.7 Cod GFIP no PPP

            oBody['mothersName']    := aData[nI][34]

            do case
                case aData[nI][35] == 'S' // Solteiro
                    oBody['civilStatus'] := 1
                case aData[nI][35] == 'C' // Casado
                    oBody['civilStatus'] := 2
                case aData[nI][35] == 'D' // Divorciado
                    oBody['civilStatus'] := 3
                case aData[nI][35] == 'V' // Viúvo
                    oBody['civilStatus'] := 4
                case aData[nI][35] == 'Q' // Separado Judicialmente
                    oBody['civilStatus'] := 5
            end case

            oBody['ctps']             := aData[nI][36]

            DO Case
                CASE aData[nI][37] $ ("10/20/25/30/35/40") //Ensino Básico/Fundamental
                    oBody['educationLevel'] := 1
                CASE aData[nI][37] $ ("45/50") //Ensino Médio
                    oBody['educationLevel']  := 2
                CASE aData[nI][37] $ ("55/85") //Graduação
                    oBody['educationLevel'] := 3
                CASE aData[nI][37] $ ("65") //Mestrado
                    oBody['educationLevel'] := 4
                CASE aData[nI][37] $ ("75/95") //Doutorado
                    oBody['educationLevel'] := 5
            END CASE

            oBody['state']                  := aData[nI][38]
            oBody['rais']                   := aData[nI][39]
            oBody['eSocialCategory']        := aData[nI][40]
            oBody['position']               := aData[nI][41] //cargo
            oBody['positionDescription']    := aData[nI][42] //descricao do cargo

            oBody['defFisica']              := aData[nI][43]
            oBody['defVisual']              := aData[nI][44]
            oBody['defAuditiva']            := aData[nI][45]
            oBody['defMental']              := aData[nI][46]
            oBody['defIntelectual']         := aData[nI][47]
            oBody['reabReadap']             := aData[nI][48]
            If !Empty(aData[nI][49])
                oBody['lastExamDate']       := formatDate(DtoS(aData[nI][49]))
            EndIf

            cResource   := "/ttalk/employee?branchId="+cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/employee"
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
            Case cOperac $ "A|D"
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

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Recebe o campo RA_SITFOLH e retorna o codigo de situation para a API
@author  Marcio Felipe Martins
@since   28/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fGetSitua(cSitFolh)

    Local nRet := 0

    Do Case
        Case Empty(cSitFolh)
            nRet := 1
        Case cSitFolh == "A"
            nRet := 4
        Case cSitFolh == "D"
            nRet := 2
        Case cSitFolh == "F"
            nRet := 3
        Case cSitFolh == "T"
            nRet := 2
    EndCase

Return nRet
