#Include 'Protheus.ch'
#Include 'TMSAC30.ch'

Static lTMC30Pst := ExistBlock("TMC30PST")

/*{Protheus.doc} TMSAC30()
Fun��o Dummy. Utilizada na verifica��o da existencia de fonte

@author Carlos Alberto Gomes Junior
@since 14/07/2022
*/
Function TMSAC30()
Return

/*{Protheus.doc} TMSBCACOLENT()
Classe para integra��o SIGATMS x Coleta/Entrega

@author Valdemar Roberto Mognon
@since 09/03/2022
*/
CLASS TMSBCACOLENT

    DATA alias_config  AS CHARACTER
    DATA last_error    AS CHARACTER
    DATA all_error     AS CHARACTER
    DATA desc_error    AS CHARACTER
    DATA access_token  AS CHARACTER
    DATA time_token    AS CHARACTER
    DATA data_token    AS DATA
    DATA time_expire   AS NUMERIC
    DATA url_token     AS CHARACTER
    DATA client_id     AS CHARACTER
    DATA client_secret AS CHARACTER
    DATA acr_values    AS CHARACTER
    DATA username      AS CHARACTER
    DATA password      AS CHARACTER
    DATA config_recno  AS NUMERIC
    DATA url_app       AS CHARACTER
    DATA type_file     AS CHARACTER
    DATA result_ok     AS CHARACTER
    DATA codfon        AS CHARACTER
    DATA filext        AS CHARACTER

    METHOD New() Constructor
    METHOD IsTokenActive()
    METHOD DbGetToken()
    METHOD GetToken()
    METHOD GetActiveToken()
    METHOD Post()
    METHOD Get()
    
END CLASS

/*{Protheus.doc} New()
M�todo construtor da classe

@author Valdemar Roberto Mognon
@since 09/03/2022
@version 1.0
*/
METHOD New(cAliasConf) CLASS TMSBCACOLENT

DEFAULT cAliasConf := ""

    ::Alias_Config  := cAliasConf
    ::last_error    := ""
    ::all_error     := ""
    ::desc_error    := ""
    ::access_token  := ""
    ::data_token    := CtoD("")
    ::time_token    := ""
    ::time_expire   := 0
    ::url_token     := ""
    ::client_id     := ""
    ::client_secret := ""
    ::acr_values    := ""
    ::username      := ""
    ::password      := ""
    ::config_recno  := 0
    ::type_file     := ""

Return

/*{Protheus.doc} IsTokenActive()
Busca se existe configura��o e token Ativo

@author Carlos A. Gomes Jr.
@since 16/03/22
*/
METHOD IsTokenActive() CLASS TMSBCACOLENT
Local lRet := .F.

    If !Empty(::access_token)
        lRet := CalcVldDt(::data_token,::time_token,::time_expire)
    EndIf

    If !lRet .And. ::DbGetToken() .And. !Empty(::data_token)
        lRet := CalcVldDt(::data_token,::time_token,::time_expire)
    EndIf

Return lRet

/*{Protheus.doc} CalcVldDt()
Calcula se o Token ainda � valido

@author Carlos A. Gomes Jr.
@since 16/03/22
*/
Static Function CalcVldDt(dDtToken,cHrToken,nExpire)

Local lRet  := .F.
Local cTime := ""
Local nSecs := 0

DEFAULT dDtToken := CtoD("")
DEFAULT cHrToken := ""
DEFAULT nExpire  := 0

    If dDataBase == dDtToken 
        cTime := ElapTime( cHrToken, Time() ) 
        nSecs := Hrs2Min( cTime ) * 60 + Val( SubStr( cTime, 7, 2 ) )
        lRet  := ( nExpire > nSecs )
    EndIf

Return lRet

/*{Protheus.doc} DbGetToken()
Busca configura��o de Token na base

@author Carlos A. Gomes Jr.
@since 16/03/22
*/
METHOD DbGetToken() CLASS TMSBCACOLENT

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lRet      := .F.
Local cPrefix   := ::Alias_Config
Local aArea

    If !Empty(cPrefix)
        aAreas := { GetArea(cPrefix), GetArea() }
        cQuery  := "SELECT " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_DTTOKE DTTOKE, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_HRTOKE HRTOKE, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_EXPIRE EXPIRE, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_URLTOK URLTOK, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_ID     ID, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_SECRET SECRET, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_TENANT TENANT, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_USER   USUAR, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_PASSW  PASSW, " + CRLF
        cQuery  += cPrefix + "." + cPrefix + "_URLAPP URLAPP, " + CRLF
        cQuery  += cPrefix + ".R_E_C_N_O_  RECNO " + CRLF
        cQuery  += "FROM " + RetSQLName(cPrefix) + " " + cPrefix + " " + CRLF
        cQuery  += "INNER JOIN " + RetSQLName("DN0") + " DN0 ON " + CRLF
        cQuery  += "     DN0.DN0_FILIAL = '" + xFilial("DN0") + "' " + CRLF
        cQuery  += " AND DN0.DN0_CODIGO = " + cPrefix + "." + cPrefix + "_CODCON " + CRLF
        cQuery  += " AND DN0.DN0_ATIVO  = '1' " + CRLF
        cQuery  += " AND DN0.DN0_CODMOD = " + StrZer(nModulo,2) + " " + CRLF
        cQuery  += " AND DN0.D_E_L_E_T_ = '' " + CRLF
        cQuery  += "WHERE " + cPrefix + "." + cPrefix + "_FILIAL = '" + xFilial(cPrefix) + "' " + CRLF
        cQuery  += "  AND " + cPrefix + "." + cPrefix + "_MSBLQL = '2' " + CRLF
        cQuery  += "  AND " + cPrefix + "." + "D_E_L_E_T_ = '' " + CRLF

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
        TcSetField(cAliasQry,"DTTOKE", "D", 8, 0)

        If (cAliasQry)->(Eof())
            ::result_ok := ""
            ::all_error += ( ::last_error := STR0001 + cPrefix + STR0002 ) + CRLF	//-- "Configura��o " # " n�o encontrada."

        Else
            DbSelectArea(cPrefix)
            DbGoTo((cAliasQry)->RECNO)
            ::access_token  := (cPrefix)->(FieldGet(FieldPos(cPrefix+"_TOKEN")))
            ::data_token    := (cAliasQry)->DTTOKE
            ::time_token    := AllTrim((cAliasQry)->HRTOKE)
            ::time_expire   := (cAliasQry)->EXPIRE
            ::url_token     := AllTrim((cAliasQry)->URLTOK) + Iif(Right(AllTrim((cAliasQry)->URLTOK),1) != "/","/","")
            ::client_id     := AllTrim((cAliasQry)->ID)
            ::client_secret := AllTrim((cAliasQry)->SECRET)
            ::acr_values    := AllTrim((cAliasQry)->TENANT)
            ::username      := Lower(AllTrim((cAliasQry)->USUAR))
            ::password      := AllTrim((cAliasQry)->PASSW)
            ::url_app       := AllTrim((cAliasQry)->URLAPP) + Iif(Right(AllTrim((cAliasQry)->URLAPP),1) != "/","/","")
            ::config_recno  := (cAliasQry)->RECNO
            ::codfon        := (cPrefix)->(FieldGet(FieldPos(cPrefix+"_CODFON")))
            ::filext        := AllTrim(Posicione("DN8",1,xFilial("DN8")+::codfon+cFilAnt,"DN8_FILEXT"))
            ::last_error    := ""
            lRet            := .T.

        EndIf
        (cAliasQry)->(DbCloseArea())
        AEval( aAreas, {|aArea| RestArea(aArea) } )

    Else
        ::result_ok := ""
        ::all_error += ( ::last_error := STR0003 ) + CRLF	//-- "Configura��o de Token n�o informada."

    EndIf

Return lRet

/*{Protheus.doc} GetToken()
Busca se Novo Token ativo no colant

@author Carlos A. Gomes Jr.
@since 17/03/22
*/
METHOD GetToken(cClientID,cSecret,cACRval,cUserName,cPass,cUrlToke,lGrava) CLASS TMSBCACOLENT
Local lRet       := .F.
Local cParams    := ""
Local cResult    := ""
Local oResult AS OBJECT
Local oClient AS OBJECT

DEFAULT lGrava    := .T.

    If Empty(cClientID) .Or. Empty(cSecret) .Or. Empty(cACRval) .Or. Empty(cUserName) .Or. Empty(cPass) .Or. Empty(cUrlToke)
        If ::DbGetToken()
            DEFAULT cClientID := ::client_id
            DEFAULT cSecret   := ::client_secret
            DEFAULT cACRval   := ::acr_values
            DEFAULT cUserName := ::username
            DEFAULT cPass     := ::password
            DEFAULT cUrlToke  := ::url_token

        EndIf
    EndIf

    If !Empty(cClientID) .And. !Empty(cSecret) .And. !Empty(cACRval) .And. !Empty(cUserName) .And. !Empty(cPass) .And. !Empty(cUrlToke)
        cParams := "grant_type=password"
        cParams += "&client_id=" + cClientID
        cParams += "&client_secret=" + cSecret
        cParams += "&acr_values=" + cACRval
        cParams += "&scope=authorization_api"
        cParams += "&username=" + cUserName
        cParams += "&password=" + cPass
        oClient := FwRest():New(cUrlToke)
        oClient:SetPath("token")
        oClient:SetPostParams( EncodeUTF8(cParams) )
        ::data_token := dDataBase
        ::time_token := Time()
        lRet := oClient:Post({"Content-Type: application/x-www-form-urlencoded"}) 

        If lRet
            cResult := oClient:GetResult()
            If FWJsonDeserialize(cResult,@oResult)
                If AttIsMemberOf(oResult,"access_token")
                    ::access_token := oResult:access_token
                    If AttIsMemberOf(oResult,"expires_in")
                        ::time_expire := oResult:expires_in
                        If lGrava
                            DbGrvToken(Self)
                        EndIf
                    EndIf
                    lRet := .T.
                    ::last_error := ""
                EndIf 
            EndIf

        Else
            ::result_ok := ""
            ::all_error += ( ::last_error := AllTrim( oClient:GetLastError() ) ) + CRLF
            cResult := oClient:GetResult()
            If FWJsonDeserialize(cResult,@oResult)
                If AttIsMemberOf(oResult,"error")
                    ::desc_error += oResult:error + CRLF
                EndIf
                If AttIsMemberOf(oResult,"error_description")
                    ::desc_error += oResult:error_description
                EndIf
            EndIf

        EndIf
    Else
        ::result_ok := ""
        ::all_error += ( ::last_error := STR0011 ) + CRLF
    EndIf

    FWFreeObj(oClient)
    FWFreeObj(oResult)

Return { lRet, Iif(lRet,::access_token,"") }

/*{Protheus.doc} DbGrvToken()
Atualiza Token

@author Carlos A. Gomes Jr.
@since 17/03/22
*/
Static Function DbGrvToken(oSelf)
Local aAreas := { GetArea(oSelf:Alias_Config), GetArea() }

    DbSelectArea(oSelf:Alias_Config)
    DbGoTo(oSelf:config_recno)
    RecLock(oSelf:Alias_Config,.F.)
    FieldPut( FieldPos( oSelf:Alias_Config+"_TOKEN"  ), oSelf:access_token )
    FieldPut( FieldPos( oSelf:Alias_Config+"_DTTOKE" ), oSelf:data_token )
    FieldPut( FieldPos( oSelf:Alias_Config+"_HRTOKE" ), oSelf:time_token )
    FieldPut( FieldPos( oSelf:Alias_Config+"_EXPIRE" ), oSelf:time_expire  )
    MsUnLock()
    AEval( aAreas, { |aArea| RestArea(aArea) } )

Return

/*{Protheus.doc} GetActiveToken()
Busca o token atual e se expirado busca o novo.

@author Carlos A. Gomes Jr.
@since 17/03/22
*/
METHOD GetActiveToken() CLASS TMSBCACOLENT
Local lRet := .F.

    If ! ( lRet := ::IsTokenActive() )
        lRet := ::GetToken()[1]
    EndIf

Return { lRet, Iif(lRet,::access_token,"") }

/*{Protheus.doc} Post()
Efetua o post no sistema externo

@author     Carlos A. Gomes Jr.
@since      22/03/2022
*/
METHOD Post(cApiRun,cBody,cChangeURL) CLASS TMSBCACOLENT
Local lRet     := .F.
Local aHeader  := {}
Local cResErro := ""
Local nPosCpo  := 0
Local cTempID  := ""
Local cTmpBody := ""
Local oClient AS OBJECT

DEFAULT cApiRun    := "" // Exemplo "core/api/v1/localidades"
DEFAULT cBody      := ""
DEFAULT cChangeURL := ""

    If ::GetActiveToken()[1]
        If lTMC30Pst
            cTmpBody := ExecBlock("TMC30PST",.F.,.F.,{cApiRun,cBody,cChangeURL})
            If ValType(cTmpBody) == "C"
                cBody := cTmpBody
            EndIf
        EndIf
		If Empty(cChangeURL)
	        oClient	:= FwRest():New(  ::url_app )
		Else
			oClient	:= FwRest():New( cChangeURL )
		EndIf
        oClient:SetPath( cApiRun )
        oClient:SetPostParams(EncodeUTF8(cBody))

   		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + ::access_token)

        If oClient:Post(aHeader)
            If AttIsMemberOf( oClient, "oResponseH" ) .And. AttIsMemberOf( oClient:oResponseH, "aHeaderFields" )
                For nPosCpo := 1 To Len(oClient:oResponseH:aHeaderFields)
                    If oClient:oResponseH:aHeaderFields[nPosCpo][1] == "Location"
                        cTempID := oClient:oResponseH:aHeaderFields[nPosCpo][2] //Location = URL redirecionamento para pagina de resultado da inclus�o
                        cTempID := StrTran(cTempID,Chr(13),"")      //Remove Chr(13) do fim da linha
                        cTempID := StrTran(cTempID,::url_app,"")    //Remove inicio da URL do aplicativo
                        cTempID := StrTran(cTempID,cApiRun,"")      //Remove o EndePoint da URL
                        cTempID := AllTrim(StrTran(cTempID,"/","")) //Remove a barra invertida se n�o tiver retirado no EndPoint
                        cTempID := StrTran(cTempID,"portallogistico","")//Remove a nomenclatura do portallogistico
                        ::result_ok := cTempID                      //O que sobra � o ID
                        Exit
                    EndIf
                Next
            Else
                ::result_ok := oClient:GetResult()
            EndIf
            ::last_error := ""
            lRet := .T.

        Else
            ::result_ok  := ""
            ::all_error  += ( ::last_error := oClient:GetLastError() )
            ::desc_error := "Erro sem descri��o."
            cResErro := oClient:GetResult()
            If !Empty(cResErro)
                ::desc_error := DeCodeUTF8(cResErro)
            EndIf

        EndIf

    EndIf
    
    FWFreeObj(oClient)

Return { lRet, ::result_ok }

/*{Protheus.doc} Get()
Busca dados em API

@author     Carlos A. Gomes Jr.
@since      23/03/2022
*/
METHOD Get(cApiRun,cQueryParam,cChangeURL) CLASS TMSBCACOLENT
Local lRet    := .F.
Local aHeader := {}
Local cResErro := ""
Local oClient AS OBJECT

DEFAULT cApiRun     := "" // Exemplo "query/api/v1/localidades"
DEFAULT cQueryParam := ""
DEFAULT cChangeURL  := ""

    If ::GetActiveToken()[1]
        
        If Empty(cChangeURL)
            oClient	:= FwRest():New( ::url_app )
        Else
            oClient	:= FwRest():New( cChangeURL )
        EndIf
        oClient:SetPath( cApiRun + EncodeUTF8(cQueryParam) )

   		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + ::access_token)

        If oClient:Get(aHeader)
            ::last_error := ""
            ::result_ok  := oClient:GetResult()
            lRet := .T.

        Else
            ::result_ok  := ""
            ::all_error  += ( ::last_error := oClient:GetLastError() )
            ::desc_error := "Erro sem descri��o."
            cResErro := oClient:GetResult()
            If !Empty(cResErro)
                ::desc_error := DeCodeUTF8(cResErro)
            EndIf

        EndIf
    EndIf

    FWFreeObj(oClient)

Return { lRet, ::result_ok }

/*{Protheus.doc} TMSAC30Cli()
Busca pelo cliente e Endere�o 

Retrona IDExterno do cliente ou do endere�o conforme par�metro informado
@author     Carlos A. Gomes Jr.
@since      29/03/2022
*/
Function TMSAC30Cli( oColEnt, aLayout, aCliDados, lExecAlt )
Local aResGet    := {}
Local aResGet2   := {}
Local cRetId     := ""
Local nEnder     := 0
Local lHasNext   := .T.
Local nPage      := 1
Local nPosCod    := 0
Local cComplemen := ""
Local nPosComp   := 0
Local nPosNum    := 0
Local nPosTel    := 0
Local nPosIdLoc  := 0
Local aCompDados := 0

Local oResult AS Object

DEFAULT lExecAlt := .T.

    If (nPosCod := AScan(aLayout,{|x| AllTrim(x[1]) == "CODIGO" }) ) > 0
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/clientes","?documentoIdentificacao=" + aCliDados[nPosCod] + "&page=" + AllTrim(Str(nPage)) ) )[1]
                If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult )
                    If AttIsMemberOf( oResult, "hasNext" )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" ) .And. Len(oResult:items) >= 1
                        If Empty(cRetId)
                            //No vetor :itens estamos tratando apenas a posi��o 1 pois a Regra do Portal � que
                            //n�o deve existir mais de um cliente com o mesmo documento de identifica��o
                            cRetId := oResult:items[1]:id
                        EndIf
                        If AttIsMemberOf( oResult:items[1], "enderecos" )
                            If (nPosComp := AScan(aLayout,{|x| AllTrim(x[1]) == "COMPLEMENT" }) ) > 0 .And. ;
                            (nPosNum := AScan(aLayout,{|x| AllTrim(x[1]) == "NUMERO" }) ) > 0 .And. ;
                            (nPosTel := AScan(aLayout,{|x| AllTrim(x[1]) == "FONE" }) ) > 0 .And. ;
                            (nPosIDLoc := AScan(aLayout,{|x| AllTrim(x[1]) == "IDLOCAL" }) ) > 0
                                For nEnder := 1 To Len( oResult:items[1]:enderecos )
                                    cComplemen := ""
                                    If AttIsMemberOf( oResult:items[1]:enderecos[nEnder], "complemento" )
                                        cComplemen := oResult:items[1]:enderecos[nEnder]:complemento
                                    EndIf
                                    If AllTrim(aCliDados[nPosIDLoc]) == oResult:items[1]:enderecos[nEnder]:localidade:Id .And. ;
                                        AllTrim(aCliDados[nPosNum]) == oResult:items[1]:enderecos[nEnder]:numero .And. ;
                                        AllTrim(aCliDados[nPosTel]) == oResult:items[1]:enderecos[nEnder]:telefone .And. ;
                                        AllTrim(aCliDados[nPosComp]) == cComplemen
                                        lExecAlt  := .F.
                                        Exit
                                    EndIf
                                Next
                                If !lExecAlt
                                    Exit
                                EndIf
                            Else
                                TMSAC30Err( "TMSAC30026", STR0012 , STR0013 )
                            EndIf
                        EndIf
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30004", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
    Else
        TMSAC30Err( "TMSAC30024", STR0012 , STR0013 )
    EndIf

    FwFreeArray(aCompDados)
    FwFreeArray(aResGet2)
    FwFreeArray(aResGet)
    FWFreeObj(oResult)

Return cRetId

/*{Protheus.doc} TMSAC30GDC()
Busca pelo Documento

@author     Carlos A. Gomes Jr.
@since      30/03/2022
*/
Function TMSAC30GDC( oColEnt, aLayout, aDocDados, lExecAlt )
Local cRetId   := ""
Local aResGet  := {}
Local nItem    := 0
Local nPosKey  := 0
Local lHasNext := .T.
Local nPage    := 1
Local oResult As Object

DEFAULT lExecAlt := .F.

    If (nPosKey := AScan(aLayout,{|x| AllTrim(x[1]) == "CHAVEDOC" }) ) > 0
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/coletasEntregas", "?externalId="+FWURLEncode(aDocDados[nPosKey]) + "&situacaoDiferenteDe=EXCLUIDA" + "&page=" + AllTrim(Str(nPage)) ) )[1]
                If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult )
                    If AttIsMemberOf( oResult, "hasNext" )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nItem := 1 To Len( oResult:items )
                            If !Empty(oResult:items[nItem]:externalId) .And. oResult:items[nItem]:externalId == aDocDados[nPosKey] .And. oResult:items[nItem]:situacao != "EXCLUIDA"
                                lExecAlt := oResult:items[nItem]:situacao == "FINALIZADA_COM_INSUCESSO"
                                cRetId   := oResult:items[nItem]:id
                                lHasNext := .F.
                                Exit
                            EndIf
                        Next
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30008", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
    Else
        TMSAC30Err( "TMSAC30024", STR0012 , STR0014 )
    EndIf

    FWFreeObj(oResult)
    FwFreeArray(aResGet)

Return cRetId

/*{Protheus.doc} TMSAC30GDV()
Busca Documentos de uma Viagem ou Apenas o Status da Viagem

@author     Carlos A. Gomes Jr.
@since      06/04/2022
*/
Function TMSAC30GDV(cIDVia,cDocInVia,lTarefas)
Local aDocVia  := {.F.,{}}
Local aResGet  := {}
Local nItem    := 0
Local aDocTemp := {}
Local aDocsOrd := {}
Local oColEnt As Object
Local oResult As Object

DEFAULT cDocInVia := ""
DEFAULT lTarefas  := .T.

    oColEnt := TMSBCACOLENT():New("DN1")
    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/viagens","/"+cIDVia+Iif(lTarefas,"/tarefas","") ) )[1]
        If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult )
            If lTarefas
                If AttIsMemberOf( oResult, "items" )
                    For nItem := 1 To Len( oResult:items )
                        If !Empty(oResult:items[nItem]:coletaEntregaId)
                            aDocTemp := {}
                            AAdd( aDocTemp, oResult:items[nItem]:coletaEntregaId ) //01
                            AAdd( aDocTemp, oResult:items[nItem]:tipo )            //02
                            AAdd( aDocTemp, oResult:items[nItem]:externalId )      //03
                            AAdd( aDocTemp, oResult:items[nItem]:situacao )        //04
                            AAdd( aDocTemp, oResult:items[nItem]:sequencia )       //05
                            AAdd( aDocsOrd, aDocTemp )
                            If Empty(cDocInVia) .Or. oResult:items[nItem]:coletaEntregaId == cDocInVia
                                aDocVia[1] := .T.
                            EndIf
                        EndIf
                    Next
                    If !Empty(aDocsOrd)
                        ASort( aDocsOrd, ,, {|x,y| x[5] < y[5] } )
                    EndIf
                    aDocVia[2] := AClone(aDocsOrd)
                EndIf
            Else
                If AttIsMemberOf( oResult, "situacao" )
                    aDocVia[1] := .T.
                    aDocVia[2] := oResult:situacao
                EndIf
            EndIf
        EndIf
    Else
        TMSAC30Err( "TMSAC30011", oColEnt:last_error, oColEnt:desc_error )
    EndIf
    FWFreeObj(oColEnt)

Return aDocVia

/*{Protheus.doc} TMSAC30ExV()
Exclui a Viagem

@author     Carlos A. Gomes Jr.
@since      06/04/2022
*/
Function TMSAC30ExV(cIDVia)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    If !( lRet := oColEnt:Post( "coletaentrega/core/api/v1/viagens/"+cIDVia+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMSAC30ExA()
Exclui a Viagem e os Documentos que nela estavam.

@author     Carlos A. Gomes Jr.
@since      07/04/2022
*/
Function TMSAC30ExA(cIDVia)
Local lRet     := .F.
Local aDocsVia := {}

    aDocsVia := TMSAC30GDV(cIDVia)
    If ( nDocs := AScan(aDocsVia[2],{|aDoc| aDoc[4] != "CRIADA" .And. aDoc[4] != "AGUARDANDO_INICIO" }) ) > 0
        TMSAC30Err( "TMSAC30015", STR0006 + aDocsVia[2][nDocs][3] + STR0007, STR0008 )
    Else
        lRet := TMSAC30ExV(cIDVia)
    EndIf

Return lRet

/*{Protheus.doc} TMSAC30GEv()
Busca Evidencias do  Documento

@author     Carlos A. Gomes Jr.
@since      28/04/2022
*/
Function TMSAC30GEv(cDocId)
Local aEvidencia := {.F.,{}}
Local aResGet    := {}
Local nItem      := 0
Local aDTTarefa  := SToD("")
Local cUltData   := ""
Local oResult As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/coletasEntregas","/"+cDocId+"/evidencias" ) )[1]
        If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult )
            If AttIsMemberOf( oResult, "items" )
                For nItem := 1 To Len( oResult:items )
                    aEvidencia[1] := .T.
                    aDTTarefa := UTCToLocal( StrTran(Left(oResult:items[nItem]:dataSituacao,10),"-",""), Substr(oResult:items[nItem]:dataSituacao,12,8) )
                    If Empty(cUltData) .Or. cUltData < aDTTarefa[1] + aDTTarefa[2]
                        cUltData := aDTTarefa[1] + aDTTarefa[2]
                        aEvidencia[2] := { StoD(aDTTarefa[1]), StrTran(Left(aDTTarefa[2],5),":","") } //01 e 02
                        If AttIsMemberOf( oResult:items[nItem], "fotos" )
                            If ValType(oResult:items[nItem]:fotos) != "A"
                                AAdd(aEvidencia[2], { oResult:items[nItem]:fotos } ) //03
                            ElseIf Len(oResult:items[nItem]:fotos) >= 1
                                AAdd(aEvidencia[2], aClone(oResult:items[nItem]:fotos) ) //03
                            Else
                                AAdd(aEvidencia[2], {""} ) //03
                            EndIf
                        Else
                            AAdd(aEvidencia[2], {""} ) //03
                        EndIf
                        If AttIsMemberOf( oResult:items[nItem], "recebedor" ) .And. oResult:items[nItem]:recebedor != Nil
                            AAdd(aEvidencia[2], oResult:items[nItem]:recebedor:nome ) //04
                            If AttIsMemberOf( oResult:items[nItem]:recebedor, "documento" ) .And. oResult:items[nItem]:recebedor:documento != Nil
                                AAdd(aEvidencia[2], oResult:items[nItem]:recebedor:documento ) //05
                            Else
                                AAdd(aEvidencia[2], "" ) //05
                            EndIf
                        Else
                            AAdd(aEvidencia[2], "" ) //04
                            AAdd(aEvidencia[2], "" ) //05
                        EndIf
                        AAdd(aEvidencia[2], oResult:items[nItem]:situacao ) //06
                        AAdd(aEvidencia[2], oResult:items[nItem]:motivo ) //07
                        AAdd(aEvidencia[2], oResult:items[nItem]:relato ) //08
                        If !Empty(oResult:items[nItem]:localizacao:latitude)
                            AAdd(aEvidencia[2], cValToChar(oResult:items[nItem]:localizacao:latitude) ) //09
                        Else
                            AAdd(aEvidencia[2], "-23.5085783" ) //09 TOTVS SP
                        EndIf
                        If !Empty(oResult:items[nItem]:localizacao:longitude)
                            AAdd(aEvidencia[2], cValToChar(oResult:items[nItem]:localizacao:longitude) ) //10
                        Else
                            AAdd(aEvidencia[2], "-46.6518496" ) //10 TOTVS SP
                        EndIf
                        If AttIsMemberOf( oResult:items[nItem], "situacaoDocumentacaoTarefa" ) .And. oResult:items[nItem]:situacaoDocumentacaoTarefa != Nil
                            AAdd(aEvidencia[2], oResult:items[nItem]:situacaoDocumentacaoTarefa ) //11
                        Else
                            AAdd(aEvidencia[2], "PENDENTE_ANALISE" ) //11
                        EndIf
                    EndIf
                Next
            EndIf
        EndIf
    Else
        TMSAC30Err( "TMSAC30020", oColEnt:last_error, oColEnt:desc_error )
    EndIf

    FWFreeObj(oResult)

Return aEvidencia

/*{Protheus.doc} TMSAC30Img()
Busca Imagem da Evidencia no Storage do Rac

@author     Carlos A. Gomes Jr.
@since      28/04/2022
*/
Function TMSAC30Img(aIdImg)
Local aDadosEvid := {.F., Array(5) }
Local aResGet    := {}
Local nImg       := 0
Local oResult As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    For nImg := 1 To Len(aIdImg)
        If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/arquivos", "/" + aIdImg[nImg] ) )[1]
            If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult ) .And. ( Empty(aDadosEvid[2][3]) .Or. aDadosEvid[2][3] > AllTrim(oResult:nome) )
                aDadosEvid[2][1] := AllTrim(oResult:id)                                            //01 - Id da Imagem
                aDadosEvid[2][2] := AllTrim(oResult:url)                                           //02 - Url da Imagem
                aDadosEvid[2][3] := AllTrim(oResult:nome)                                          //03 - Nome da Imagem
                aDadosEvid[2][4] := AllTrim(Substr(oResult:nome,At(AllTrim(oResult:nome),".")))    //04 - Tipo da Imagem
                aDadosEvid[2][5] := HttpGet(AllTrim(oResult:url))                                  //05 - Imagem
                aDadosEvid[1]    := .T.
            EndIf
        EndIf
    Next
    FWFreeObj(oResult)

Return aDadosEvid

/*{Protheus.doc} TMSAC30Err()
Registra / Apresenta Erro de Integra��o

@author     Carlos A. Gomes Jr.
@since      16/05/2022
*/
Static cLogErro := ""
Function TMSAC30Err( cFun��o, cMensagem, cDetalhe, lJson )
Local cMsgTrat := ""
Local nDetErr  := 0
Local oErro As Object

DEFAULT cFun��o   := ""
DEFAULT cMensagem := ""
DEFAULT cDetalhe  := ""
DEFAULT lJson     := .T.

    cMsgTrat := cDetalhe
    If lJson
        If FWJsonDeserialize( cDetalhe, @oErro )
            If AttIsMemberOf( oErro, "message" )
                cMsgTrat := oErro:message + CRLF
            EndIf
            If AttIsMemberOf( oErro, "detailedMessage" )
                cMsgTrat += oErro:detailedMessage
            EndIf
            If AttIsMemberOf( oErro, "details" )
                For nDetErr := 1 To Len(oErro:details)
                    cMsgTrat += CRLF
                    cMsgTrat += "* "+oErro:details[nDetErr]:message + CRLF
                    cMsgTrat += " -"+oErro:details[nDetErr]:detailedMessage
                Next
            EndIf
        EndIf
    EndIf

    cLogErro += DtoC(dDataBase) + "-" + Time() + CRLF
    cLogErro += cFun��o + " - " + cMensagem + CRLF
    cLogErro += cMsgTrat + CRLF + CRLF

    If !IsBlind()
        Help(" ", , cFun��o + "-" + cMensagem, , cMsgTrat, 2, 1)
    EndIf
    
    FWFreeObj(oErro)

Return

/*{Protheus.doc} TMSAC30GEr()
Retorna Erros de Integra��o e Limpa o Buffer de Erro

@author     Carlos A. Gomes Jr.
@since      16/05/2022
*/
Function TMSAC30GEr
Local cErro := cLogErro
    cLogErro := ""
Return cErro

/*{Protheus.doc} TMSAC30PEr()
Adiciona mensagens no Buffer de Erros de Integra��o.
@author     Carlos A. Gomes Jr.
@since      16/05/2022
*/
Function TMSAC30PEr(cMensagem)
Default cMensagem := ""
    cLogErro += cMensagem
Return

/*{Protheus.doc} TMSAC30VIA()
Busca Status da Viagem para Inserir documento em andamento
@author     Carlos Alberto Gomes Jr.
@since      19/08/2022
*/
Function TMSAC30VIA( oColEnt, aLayout, aViaDados, lExecAlt )
Local cRetIdVia := ""
Local nPosKey   := 0

    If (nPosKey := AScan(aLayout,{|x| AllTrim(x[1]) == "IDVIAGEM" }) ) > 0 .And. !Empty(aViaDados[nPosKey])
        If ( aViagem := TMSAC30GDV(aViaDados[nPosKey],,.F.) )[1]
            If aViagem[2] == "DESPACHO_CONFIRMADO"
                lExecAlt  := .T.
                cRetIdVia := AllTrim(aViaDados[nPosKey])
            Else
                lExecAlt := .F.
            EndIf
        EndIf
    EndIf

Return cRetIdVia
/*{Protheus.doc} TMC30CanCol()
Cancela Documento Coleta no Portal Log�stico 
@author     Carlos A. Gomes Jr.
@Changed    Rafael Souza
@since      14/09/2022
*/
Function TMC30CanCol(cIdExt)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object
    
    If IsInCallStack("TMSA460")
       cJson := '{"statusDocumento": "CANCELADA"}'
    EndIf 
    
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosColeta/"+cIdExt+"/alterarStatusDocumento", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TM30StsDoc()
Atualiza Status Operacional no Portal Log�stico 
@author     Carlos A. Gomes Jr.
@Changed    Rafael Souza
@since      15/09/2022
*/
Function TM30StsDoc(cIdExt, cStatus)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

Default cIdExt  := ""
Default cStatus := ""
    
    If cStatus == '1' //- Coleta em aberto
        cJson := '{"statusOperacional": "NAO_INICIADA"}'
    ElseIf cStatus == '3' //-- Coleta em tr�nsito
        cJson := '{"statusOperacional": "EM_EXECUCAO"}'
    ElseIf cStatus == '4' // Coleta encerrada
        cJson := '{"statusOperacional": "COLETA_FINALIZADA"}'
    EndIf    
    
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosColeta/"+cIdExt+"/alterarStatusOperacional", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMC30ExFat()
Exclui Fatura no Portal Log�stico
API respons�vel por deletar um documento financeiro. 
@Changed    Rafael Souza
@since      03/10/2022
*/
Function TMC30ExFat(cIdExt)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object
        
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosFinanceiros/"+cIdExt+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TM30EnStt
Atualiza Status Operacional do Documento de Carga no Portal Log�stico
@author     Rodrigo Pirolo
@since      04/10/2022
@version    12.1.27
@return     Logico
@param 
@type       function
*/
//-------------------------------------------------------------------

Function TM30AltStt( aDUDStatus, nEndPoint, cText, cProces )

	Local oColEnt	    := Nil
	Local aToken	    := {}
    Local cCodFonDTC    := ""
	Local nX		    := 0

    Default aDUDStatus  := {}
    Default nEndPoint   := 0
    Default cText       := ""
    Default cProces     := ""
	
    oColEnt  := TMSBCACOLENT():New("DND")

    oColEnt:DbGetToken()
    aToken := oColEnt:GetToken( , , , , , , .T. )

    If aToken[1]
        
        DND->( DbGoTo( oColEnt:config_recno ) )
        DN5->( DbSetOrder(3) )
        
        cCodFonDTC := DND->DND_CODFON

        If !Empty(cProces)
            cProcesDTC := PadR( cProces, Len(DN5->DN5_PROCES) )
            MntQryDn5( cCodFonDTC, nEndPoint, cProcesDTC, cText )
        Else
            For nX := 1 To Len(aDUDStatus)
                
                cProcesDTC := PadR( aDUDStatus[nX][1], Len(DN5->DN5_PROCES) )

                MntQryDn5( cCodFonDTC, nEndPoint, cProcesDTC, cText, aDUDStatus[nX][2] )

            Next nX
        EndIf
    EndIf

    FwFreeArray( aToken )
    FWFreeObj( oColEnt )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} TM30EnStt
Atualiza Status Operacional do Documento de Carga no Portal Log�stico
@author     Rodrigo Pirolo
@since      04/10/2022
@version    12.1.27
@return     Logico
@param 
@type       function
*/
//-------------------------------------------------------------------

Static Function MntQryDn5( cCodFonDTC, nEndPoint, cProcesDTC, cText, cStatus )
    
Local cAliasDN5 := ""
Local cQuery    := ""

Default cCodFonDTC  := ""
Default nEndPoint   := 1
Default cProcesDTC  := ""
Default cStatus     := ""

    cAliasDN5 := GetNextAlias()

    cQuery := " SELECT DN5.DN5_CODFON, DN5.DN5_CODREG, DN5.DN5_IDEXT, DN5.R_E_C_N_O_ REGISTRO "
    cQuery += " FROM " + RetSqlName("DN5") + " DN5 "
    cQuery += " WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
    cQuery += 	" AND DN5.DN5_CODFON = '" + cCodFonDTC + "' "

    If nEndPoint <= 3
        cQuery += 	" AND DN5.DN5_CODREG = '1000' "
    Else
        cQuery += 	" AND DN5.DN5_CODREG = '2000' "
    EndIf

    cQuery += 	" AND DN5.DN5_PROCES = '" + cProcesDTC + "' "
    cQuery += 	" AND DN5.DN5_STATUS = '1' "
    cQuery += 	" AND DN5.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasDN5, .F., .T. )

    While (cAliasDN5)->(!Eof())

        If !Empty( AllTrim( (cAliasDN5)->(DN5_IDEXT) ) )
            TM30EnvPL( nEndPoint, AllTrim((cAliasDN5)->(DN5_IDEXT)), cStatus, cText )
        EndIf

        (cAliasDN5)->( DbSkip() )

    EndDo

    (cAliasDN5)->( DbCloseArea() )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} TM30EnStt
Atualiza Status Operacional do Documento de Carga no Portal Log�stico
@author     Rodrigo Pirolo
@since      04/10/2022
@version    12.1.27
@return     Logico
@param      nEndPoint   - qual endpoint usar�
@param      cIdExt      - Id Externo do Portal Logistico
@param      cText       - Texto do 
@type       function
*/
//-------------------------------------------------------------------

Function TM30EnvPL( nEndPoint, cIdExt, cStatus, cText )

    Local lRet      := .F.
    Local cJson     := ""
    Local cEndPoint := ""
    Local nConex    := 0
    Local cHttpCode := ""
    Local oColEnt As Object

    Default nEndPoint   := 0
    Default cIdExt      := ""
    Default cStatus     := ""
    Default cText       := ""

    If nEndPoint == 1
        cEndPoint   := "core/api/v1/documentosCarga/" + cIdExt +"/alterarStatusComprovantePendente"
        cJson       := '{"comprovanteEntregaPendente":"' + cText + '"}'
    ElseIf nEndPoint == 2 .OR. nEndPoint == 5
        If nEndPoint == 2
            cEndPoint   := "core/api/v1/documentosCarga/" + cIdExt +"/informarDataHoraEntrega"
            cJson       := '{"dataHoraEntrega": "' + cText + '"}'
        Else
            cEndPoint   := "core/api/v1/documentosTransporte/" + cIdExt +"/informarDataHoraEntrega"
            cJson       := '{"dataHoraEntrega": "' + cText + '"}'
        EndIf
    ElseIf nEndPoint == 3 .OR. nEndPoint == 4
        
        If nEndPoint == 3
            cEndPoint   := "core/api/v1/documentosCarga/" + cIdExt +"/alterarStatusOperacional"
        Else
            cEndPoint   := "core/api/v1/documentosTransporte/" + cIdExt +"/alterarStatusOperacional"
        EndIf

        If cStatus $ '1/9' //- 1=Em Aberto;9=Cancelado
            cJson := '{"statusOperacional": "NAO_INICIADO"}'
        ElseIf cStatus $ '3' //-- 3=Carregado
            cJson := '{"statusOperacional": "EM_CROSSDOCKING"}'
        ElseIf cStatus $ '2' //-- 2=Em Transito
            cJson := '{"statusOperacional": "EM_TRANSITO"}'
        ElseIf cStatus == '4' // 4=Encerrado
            cJson := '{"statusOperacional": "ENTREGUE"}'
        EndIf
    EndIf
    
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( cEndPoint, cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMC30FtVen()
Altera Status da Fatura no Portal Log�stico para vencido.
@Changed    Rafael Souza
@since      02/01/2023
*/
Function TMC30FtVen(cIdExt)
Local lRet      := .F.
Local cJson     := '{"statusDocumento": "VENCIDO"}'
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object
        
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosFinanceiros/"+cIdExt+"/alterarStatusDocumento", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMSAC30GDD()
Busca Situa��o do Documento
@author     Carlos Alberto Gomes Junior
@since      13/01/2023
*/
Function TMSAC30GDD( oColEnt, cIdExt )
Local aSituac  := {.F.,{""}}
Local aResGet  := {}
Local oResult As Object

    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/coletasEntregas/"+cIdExt ) )[1]
        If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult )
            aSituac[2][1] := oResult:situacao
            aSituac[1]    := .T.
        EndIf
    Else
        TMSAC30Err( "TMSAC30016", oColEnt:last_error, oColEnt:desc_error )
    EndIf

    FWFreeObj(oResult)
    FwFreeArray(aResGet)

Return aSituac

/*{Protheus.doc} TMSAC30ExN()
Exclui a Nota Fiscal (tarefa entrega)
@author     Carlos Alberto Gomes Junior
@since      06/04/2022
*/
Function TMSAC30ExN(cIDNFiscal)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    If !( lRet := oColEnt:Post( "coletaentrega/core/api/v1/entregas/"+cIDNFiscal+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30017", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMC30GHist
Rotina de gera��o da tabela hist�rico de integra��o
@author Carlos Alberto Gomes Junior
@Since 20/01/2023
*/
Function TMC30GHist(cProces)

Local lRet     := .F.
Local nPosStru := 1
Local cCodReg  := ""
Local aStruct  := {}
Local aLayout  := {}
Local aAreaReg := {}
Local aAreas   := { DN5->(GetArea()) , GetArea() }
Local oColEnt

DEFAULT cProces := ""

	If !Empty(cProces)
        oColEnt := TMSBCACOLENT():New("DN1")
        If oColEnt:DbGetToken()
            DN1->(DbGoTo(oColEnt:config_recno))

            //-- Inicializa a estrutura
            aStruct := TMSMntStru(DN1->DN1_CODFON,.T.) //XXX_CODFON
            TMSSetVar("aStruct",aStruct)
            
            //-- Define o processo
            TMSSetVar("cProcesso",cProces)

            //-- Inicializa o localizador
            TMSSetVar("aLocaliza",{})

            //-- Inicializa Chave da NotaFiscal
            TMSSetVar("aChaveNFC",{})

            For nPosStru := 1 To Len(aStruct)
                Aadd(aAreaReg,(aStruct[nPosStru,3])->(GetArea()))
                //-- N�o � adicional de ningu�m e ainda n�o foi processado
                If (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nPosStru,1] +  aStruct[nPosStru,2]}) == 0) .And. aStruct[nPosStru,10] == "2"
                    //Verifica se a condi��o do registro do layout n�o foi informada ou foi atendida
                    If Empty(aStruct[nPosStru][9]) .Or. &(aStruct[nPosStru][9])
                        //Verifica se n�o depende de outro registro ou se sim se esse registro ja foi processado
                        If Empty(aStruct[nPosStru,6]) .Or. AScan(aStruct,{|x| x[1]+x[2] == aStruct[nPosStru][1]+aStruct[nPosStru][6] .And. x[10] == "2" })
                            aLayout := BscLayout(aStruct[nPosStru,1],aStruct[nPosStru,2])
                            //Verifica se encontrou o layout
                            If !Empty(aLayout)
                                //-- Inicia a grava��o dos registros e guarda qual o primeiro registro (principal)
                                If Empty(cCodReg)
                                    cCodReg := aStruct[nPosStru][2]
                                EndIf
                                MontaReg( Aclone(aLayout), nPosStru, , ,.T.)
                                TMSCtrLoop( Aclone(aLayout), nPosStru )
                            EndIf
                        EndIf
                    EndIf
                EndIf
                aStruct := TMSGetVar("aStruct")
            Next nPosStru
            AEval(aAreaReg,{|x,y| RestArea(x),FwFreeArray(x)})

            DN5->(DbSetOrder(3))
            DN5->(DbSeek(xFilial("DN5")+DN1->DN1_CODFON+cCodReg+cProces))
            Do While !DN5->(Eof()) .And. DN5->(DN5_FILIAL+DN5_CODFON+DN5_CODREG+DN5_PROCES) == xFilial("DN5")+DN1->DN1_CODFON+cCodReg+Padr(cProces,Len(DN5->DN5_PROCES))
                If ( lRet := ( DN5->DN5_STATUS == "2" ) )
                    Exit
                EndIf
                DN5->(DbSkip())
            EndDo

        EndIf

        AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

        FwFreeArray(aAreaReg)
        FwFreeArray(aAreas)
		FwFreeArray(aStruct)
		FwFreeArray(aLayout)
		FwFreeArray(aAreaReg)
        TMSSetVar("aStruct", {} )
        TMSSetVar("cProcesso", "" )
        TMSSetVar("aLocaliza",{})
        TMSSetVar("aChaveNFC",{})

    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMSAC30GCh()
Busca chaves de DANFE de uma coleta realizada.

@author     Carlos A. Gomes Jr.
@since      06/04/2022
*/
Function TMSAC30GCh( cIDCol )
Local aChvCol  := {.F.,{}}
Local aResGet  := {}
Local nItem    := 0
Local aChaves  := {}
Local oColEnt As Object
Local oResult As Object

DEFAULT cIDCol  := ""

    oColEnt := TMSBCACOLENT():New("DN1")
    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/documentocarga/coletasEntregas/" + cIDCol ) )[1]
        If FWJsonDeserialize( DecodeUTF8(aResGet[2]), @oResult )
            If AttIsMemberOf( oResult, "items" )
                For nItem := 1 To Len( oResult:items )
                    If AttIsMemberOf( oResult:items[nItem], "chave" ) .And. !Empty(oResult:items[nItem]:chave)
                        AAdd( aChaves, oResult:items[nItem]:chave )
                        aChvCol[1] := .T.
                    EndIf
                Next
                aChvCol[2] := AClone(aChaves)
            EndIf
        EndIf
    Else
        TMSAC30Err( "TMSAC30011", oColEnt:last_error, oColEnt:desc_error )
    EndIf
    FwFreeArray(aChaves)
    FWFreeObj(oColEnt)

Return aChvCol


