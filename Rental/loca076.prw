#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOCA076.CH"

/*/{PROTHEUS.DOC} LOCA076A
TOTVS RENTAL - m�dulo 94
Esta fun��o tem por finalidade a gera��o de uma nota de sa�da com base no pedido de vendas informado.
Buscamos no RM via WS a nota fiscal de sa�da com base no pedido de vendas
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 06/06/2022
/*/
Function LOCA076A(_cPedido, _cTipo, _cDel)
local oWsdl as object
local _nX
Local cError    := ""
Local cWarning  := ""
Local oXml      := NIL
Local _lRet
Local _cXmlTemp
Local _cNota
Local _cSerie
Local _aItens
Local _cItem
Local _cEnde    := AllTrim(getmv("MV_LOCX300",,"http://10.171.66.159:8051/EAIService/MEX?wsdl"))
Local _cUsu     := AllTrim(getmv("MV_LOCX301",,"mestre"))
Local _cSenha   := AllTrim(getmv("MV_LOCX302",,"totvs"))
Local _nY
Local _cTemp
Local _nConta
Local _aItensRet := {}
Local aOps
Local xxx
Local _cXml
Local _cResp
Local cAlias
Local nReg
Local nOpcX
Local lAutomato
Local lAglCtb
Local lContab
Local lCarteira

Private _cPSerie
Private _cPNota

    oWsdl := TWsdlManager():New()
    oWsdl:lVerbose := .T.
    oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs 

    //Verifica o endere�o, se existe algum servi�o dispon�vel e se existe o servi�o que quero utilizar
    if !oWsdl:ParseURL(_cEnde)
        msgalert(oWsdl:cError)
        Return
    else

        aOps := oWsdl:ListOperations()
        _lRet:= oWsdl:SetOperation( "receiveMessage" )

        //Informo o usu�rio e senha via basic em base64 no header da requisi��o
        oWsdl:AddHttpHeader("Authorization", "Basic " + Encode64(_cUsu+":"+_cSenha))

        If !_lRet
            Return
        EndIF

        //Informo o usu�rio e senha via basic em base64 no header da requisi��o
        //oWsdl:AddHttpHeader("Authorization", "Basic " + Encode64("mestre:totvs"))

        _cEnv := '<![CDATA[<?xml version="1.0" encoding="utf-8"?>'
        _cEnv += '<TOTVSMessage>'
        _cEnv += '<MessageInformation version="1.000">'
        _cEnv += '<UUID>'+FWUUID('000001')+'</UUID>'
        _cEnv += '<Type>BusinessMessage</Type>'
        _cEnv += '<Transaction>TRACEABILITYORDER</Transaction>'
        _cEnv += '<StandardVersion>1.000</StandardVersion>'
        _cEnv += '<SourceApplication>PROT</SourceApplication>'
        _cEnv += '<CompanyId>'+cEmpAnt+'</CompanyId>'
        _cEnv += '<BranchId>'+cFilAnt+'</BranchId>'
        _cEnv += '<Enterprise></Enterprise>'
        _cEnv += '<BusinessUnit></BusinessUnit>'
        _cEnv += '<CompanySharingMode>E</CompanySharingMode>'
        _cEnv += '<BusinessUnitySharingMode>E</BusinessUnitySharingMode>'
        _cEnv += '<BranchSharingMode>E</BranchSharingMode>'
        _cEnv += '<Product name="PROTHEUS" version="12"/>'
        _cEnv += '<GeneratedOn>2021-09-21T11:33:42Z</GeneratedOn>'
        _cEnv += '<DeliveryType>Sync</DeliveryType>'
        _cEnv += '</MessageInformation>'
        _cEnv += '<BusinessMessage>'
        _cEnv += '<BusinessEvent>'
        _cEnv += '<Entity>TRACEABILITYORDER</Entity>'
        _cEnv += '<Event>upsert</Event>'
        _cEnv += '<Identification>'
        _cEnv += '<key name="InternalId">'+cEmpAnt+'|'+cFilAnt+'|'+_cPedido+'|2</key>'
        _cEnv += '</Identification>'
        _cEnv += '</BusinessEvent>'
        _cEnv += '<BusinessContent>'
        _cEnv += '<RequestItem>'
        _cEnv += '<OrderInternalId>'+cEmpAnt+'|'+cFilAnt+'|'+_cPedido+'|2</OrderInternalId>'
        _cEnv += '<TypeOrder>'+_cTipo+'</TypeOrder>'
        _cEnv += '</RequestItem>'
        _cEnv += '</BusinessContent>'
        _cEnv += '</BusinessMessage>'
        _cEnv += '</TOTVSMessage>]]>'

        //conout("Pedido de vendas: "+_cPedido)

        _lRet := oWsdl:SetValue( 0, _cEnv )
        if !_lRet
            //Conout("Erro na leitura do Xml")
            Return
        EndIF

        // mensagem que � enviada
        xxx := oWsdl:GetSoapMsg()
        
        // Envia a mensagem SOAP ao servidor
        _lRet := oWsdl:SendSoapMsg()
        if !_lRet
            //Conout("Erro na leitura do Xml")
            Return
        EndIF

        // Pega a mensagem de resposta
        _cXmlTemp := oWsdl:GetSoapResponse()

        // Correcao do html do retorno do xml
        _cXml := xconvxml(_cXmlTemp)

        oXml := XmlParser( _cXml, "_", @cError, @cWarning )
        If (oXml == NIL )
            //conout("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
            Return
        Endif

        _cResp := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_RESPONSEMESSAGE:_RETURNCONTENT:_RETURNMESSAGE:TEXT 
        If upper(alltrim(substr(_cResp,1,7))) == "NENHUMA"
            //conout("N�o houve retorno valido para este pedido de vendas")

            // Houve um cancelamento
            If _cDel == "S"
                cAlias 		:= "SF2"
                nReg        := 1
                nOpcX       := 1
                lAutomato	:= .T.
                lAglCtb		:= .F.
                lContab		:= .F.
                lCarteira 	:= .F.
                SC6->(dbSetOrder(1))
                If SC6->(dbSeek(xFilial("SC6")+_cPedido))
                    SF2->(dbSetOrder(1))
                    If SF2->(dbSeek(xFilial("SF2")+SC6->C6_NOTA+SC6->C6_SERIE))
                        Ma521Mbrow(cAlias,nReg,nOpcX,lAutomato,lAglCtb,lContab,lCarteira)
                    EndIF
                EndIF
            EndIf
            Return
        EndIF

        If valtype(oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_number) == "O"
            _cNota  := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_number:Text
            _cSerie := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_invoicedocumentserie:Text
            _aItens := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_listoftitem:_item:_itemtype

            _cPSerie := _cSerie
            _cPNota  := _cNota

            //conout("Nota gerada no RM: "+_cNota)

            // Para tratamento dos itens quando precisar.
            _aItensRet := {}
            // Se o _aItens for um array � que tem mais de uma linha na SC6
            If valtype(_aItens) == "A"
                For _nX := 1 to len(_aItens)
                    _cItem := alltrim(_aitens[_nX]:_internalid:text)
                    _cTemp := ""
                    _nConta := 0
                    For _nY := 1 to len(_cItem)
                        If _nConta == 2
                            _cTemp += substr(_cItem,_nY,1)
                        EndIf
                        If substr(_cItem,_nY,1) == "|"
                            _nConta ++
                        EndIf
                    Next 
                    If !empty(_cTemp)
                        aadd(_aItensRet,{_cTemp})
                    EndIf
                Next
            EndIf
            // Se o _aItens for um objeto � que tem apenas uma linha na SC6
            If valtype(_aItens) == "O"
                _cItem := _aItens:_internalid:text
                _cTemp := ""
                _nConta := 0
                For _nY := 1 to len(_cItem)
                    If _nConta == 2
                        _cTemp += substr(_cItem,_nY,1)
                    EndIf
                    If substr(_cItem,_nY,1) == "|"
                        _nConta ++
                    EndIf
                Next 
                If !empty(_cTemp)
                    aadd(_aItensRet,{_cTemp})
                EndIf
            EndIF
        Else
            //conout("Erro no objeto 1")

        Endif
    endif

    If len(_aItensRet) > 0
        //conout("Vai tentar gerar o pedido")
        // Libera��o do pedido de vendas
        SC5->(dbSetOrder(1))
        SC5->(dbSeek(xFilial("SC5")+_cPedido))
        xlibpv(SC5->C5_NUM)
        SC5->(dbSeek(xFilial("SC5")+_cPedido))
        GRAVANFS(SC5->C5_NUM,_aItensRet, _cNota, _cSerie, _cTipo)
    EndIF

    FreeObj(oWsdl)
    oWsdl := nil
return

/*/{PROTHEUS.DOC} xconvxml
TOTVS RENTAL - m�dulo 94
Rotina para substituir os caracteres especiais que est�o vindo do retorno do WS do RM
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 11/10/2021
/*/
Static Function xconvxml(yyy,_nY)
Local _nX 
Local _nY
Local _cSubst := ""
Local _cLocaliza := ""
Local _cInicio
Local _cMeio
Local _cFim
Local yyy

/*
"&nbsp;" " "
"&lt;"   "<"
"&gt;"   ">"
"&amp;"  "&"
"&quot;" '"'
"&apos;" "'"
<&#xD;    >
*/

    For _nY := 1 to 8
        If _nY == 1
            _cLocaliza := "&gt;&#xD;"    
            _cSubst    := ">"
        ElseIf _nY == 2 
            _cLocaliza := "&gt; &#xD;"     
            _cSubst    := ">"    
        ElseIf _nY == 3 
            _cLocaliza := "&nbsp;"
            _cSubst    := " "
        ElseIf _nY == 4
            _cLocaliza := "&lt;"
            _cSubst    := "<"
        ElseIf _nY == 5
            _cLocaliza := "&gt;"
            _cSubst    := ">"
        ElseIf _nY == 6
            _cLocaliza := "&amp;"
            _cSubst    := "&"
        ElseIf _nY == 7
            _cLocaliza := "&quot;"
            _cSubst    := '"'
        Elseif _nY == 8
            _cLocaliza := "&apos"
            _cSubst    := "'"
        EndIf

        While at(_cLocaliza,yyy) > 0
            For _nX := 1 to len(yyy)
                If upper(substr(yyy, _nX, len(_cLocaliza))) == upper(_cLocaliza)
                    _cInicio := substr(yyy, 1, _nX - 1)
                    _cMeio   := _cSubst
                    _cFim    := substr(yyy, _nX + len(_cLocaliza), len(yyy))
                    yyy      := _cInicio + _cMeio + _cFim
                    Exit
                EndIF
            Next
        EndDo
    Next

Return yyy

/*/{PROTHEUS.DOC} xconvxml
TOTVS RENTAL - m�dulo 94
Rotina para liberacao do pedido de vendas
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function xlibpv(cPedido)
Local aArea     := GetArea()
Local aAreaC5   := SC5->(GetArea())
Local aAreaC6   := SC6->(GetArea())
Local aAreaC9   := SC9->(GetArea())
Local cPedido   := SC5->C5_NUM
Local aAreaAux  := {}
Local cBlqCred  := "  "
Local cBlqEst   := "  "
Local aLocal    := {}
Local _cItem2
Local _nReg1

Default cPedido := ""
    
    SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM
    
    //Se conseguir posicionar no pedido
    If SC5->(DbSeek(FWxFilial('SC5') + cPedido))
        SC6->(DbSetOrder(1)) 
        SC6->(dbSeek(xFilial("SC6")+cPedido))
        While ! SC6->(EoF()) .And. SC6->C6_FILIAL = FWxFilial('SC6') .And. SC6->C6_NUM == cPedido
            SC9->(DbSetOrder(1))
            If !SC9->(dbSeek(xFilial("SC6")+SC6->C6_NUM+SC6->C6_ITEM))
                _nReg1 := SC6->(Recno())
                nQtdLib   := SC6->C6_QTDVEN
                MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{|| .T.})
                SC6->(dbGoto(_nReg1))
            EndIF
            SC6->(DbSkip())
        EndDo
        MaLiberOk({SC5->C5_NUM})	
    EndIf

    RestArea(aAreaC9)
    RestArea(aAreaC6)
    RestArea(aAreaC5)
    RestArea(aArea)
Return

/*/{PROTHEUS.DOC} xconvxml
TOTVS RENTAL - m�dulo 94
Rotina para geracao da nota fiscal de saida
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function GRAVANFS( _cPedido, _aItens, _cNota, _cSerie, _cTipo )
Local _aAreaOld := getArea()
Local _aAreaSC5 := SC5->(getArea())
Local _aAreaSC6 := SC6->(getArea())
Local _aAreaSC9 := SC9->(getArea())
Local _aAreaSE4 := SE4->(getArea())
Local _aAreaSB1 := SB1->(getArea())
Local _aAreaSB2 := SB2->(getArea())
Local _aAreaSF4 := SF4->(getArea())
Local _aTabAux  := {}
Local _aPvlNfs  := {}
Local _cQuery   := ""
Local _cItem
Local _cItem2
Local _cTemp
Local _nX
Local _lPassa

    //conout("entrou na gera��o da nota")

    If empty(_cNota) .or. empty(_cSerie) .or. empty(_cPedido) .or. len(_aItens)==0
        Return .F.
    EndIF

    pergunte("MT460A",.F.)

    _aPvlNfs := {}

    SC5->( dbSetOrder(1) )	// C5_FILIAL + C5_NUM
    SC6->( dbSetOrder(1) )	// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
    SC9->( dbSetOrder(1) )	// C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

    If select("TRBNFR") > 0
        TRBNFR->(dbCloseArea())
    ENDIF
    _cQuery := " SELECT C9_PEDIDO PEDIDO , C9_ITEM   ITEM  , C9_SEQUEN  SEQUEN  , " + CRLF 
    _cQuery += "        C9_QTDLIB QUANT  , C9_PRCVEN VALOR , C9_PRODUTO PRODUTO , " + CRLF 
    _cQuery += "        SC9.R_E_C_N_O_ SC9RECNO, SC5.R_E_C_N_O_ SC5RECNO , "        + CRLF 
    _cQuery += "        SC6.R_E_C_N_O_ SC6RECNO, SE4.R_E_C_N_O_ SE4RECNO , "        + CRLF 
    _cQuery += "        SB1.R_E_C_N_O_ SB1RECNO, SB2.R_E_C_N_O_ SB2RECNO , "        + CRLF 
    _cQuery += "        SF4.R_E_C_N_O_ SF4RECNO "                                   + CRLF 
    _cQuery += " FROM " + RetSqlName("SC9") + " SC9 (NOLOCK) "                      + CRLF 
    _cQuery += "        INNER JOIN " + RetSqlName("SC6") + " SC6 (NOLOCK) ON  C6_FILIAL  = '" + xFilial("SC6") + "'"                + CRLF
    _cQuery += "                                                          AND C6_NUM     = C9_PEDIDO  AND C6_ITEM    = C9_ITEM "    + CRLF
    _cQuery += "                                                          AND C6_PRODUTO = C9_PRODUTO AND C6_BLQ NOT IN ('R','S') " + CRLF
    _cQuery += "                                                          AND SC6.D_E_L_E_T_ = '' "                                 + CRLF
    _cQuery += "        INNER JOIN " + RetSqlName("SC5") + " SC5 (NOLOCK) ON  C5_FILIAL  = '" + xFilial("SC5") + "'"                + CRLF
    _cQuery += "                                                          AND C5_NUM     = C6_NUM     AND SC5.D_E_L_E_T_ = '' "     + CRLF
    _cQuery += "        INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON  E4_FILIAL  = '" + xFilial("SE4") + "'"                + CRLF
    _cQuery += "                                                          AND E4_CODIGO  = C5_CONDPAG AND SE4.D_E_L_E_T_ = '' "     + CRLF 
    _cQuery += "        INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON  B1_FILIAL  = '" + xFilial("SB1") + "'"                + CRLF
    _cQuery += "                                                          AND B1_COD     = C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "     + CRLF
    _cQuery += "        INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) ON  B2_FILIAL  = '" + xFilial("SB2") + "'"                + CRLF
    _cQuery += "                                                          AND B2_COD     = C6_PRODUTO AND B2_LOCAL   = C6_LOCAL "   + CRLF
    _cQuery += "                                                          AND SB2.D_E_L_E_T_ = '' "                                 + CRLF
    _cQuery += "        INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) ON  F4_FILIAL  = '" + xFilial("SF4") + "'"                + CRLF
    _cQuery += "                                                          AND F4_CODIGO  = C6_TES     AND SF4.D_E_L_E_T_ = '' "     + CRLF
    _cQuery += " WHERE  C9_FILIAL  = '" + xFilial("SC9") + "'"                      + CRLF
    _cQuery += "   AND  C9_PEDIDO  = '" + _cPedido + "'"                            + CRLF
    _cQuery += "   AND  C9_NFISCAL = ''"                                            + CRLF
    _cQuery += "   AND  SC9.D_E_L_E_T_ = ''"                                        + CRLF
    _cQuery += " ORDER BY PEDIDO , ITEM , SEQUEN , PRODUTO " 
    _cQuery := changeQuery(_cQuery)	

    TCQUERY _cQuery NEW ALIAS "TRBNFR"

    while TRBNFR->(!eof())
        _aTabAux := {}
        _cTemp  := TRBNFR->ITEM
        _lPassa := .F.
        For _nX := 1 to len(_aItens)
            _cItem := _aItens[_nX][1]
            _cItem2 := _cItem
            If len(_cItem2) == 1
                _cItem2 := "0" + _cItem2
            EndIF
            If _cTemp == _cITem .or. _cTemp == _cITem2
                _lPassa := .T.
                exit
            EndIF    
        Next

        If !_lPassa
            TRBNFR->(dbSkip())
            Loop
        EndIF

        aadd( _aTabAux, TRBNFR->PEDIDO   )
        aadd( _aTabAux, TRBNFR->ITEM     )
        aadd( _aTabAux, TRBNFR->SEQUEN   )
        aadd( _aTabAux, TRBNFR->QUANT    )
        aadd( _aTabAux, TRBNFR->VALOR    )
        aadd( _aTabAux, TRBNFR->PRODUTO  )
        aadd( _aTabAux, .F.              )
        aadd( _aTabAux, TRBNFR->SC9RECNO )
        aadd( _aTabAux, TRBNFR->SC5RECNO )
        aadd( _aTabAux, TRBNFR->SC6RECNO )
        aadd( _aTabAux, TRBNFR->SE4RECNO )
        aadd( _aTabAux, TRBNFR->SB1RECNO )
        aadd( _aTabAux, TRBNFR->SB2RECNO )
        aadd( _aTabAux, TRBNFR->SF4RECNO )

        aadd( _aPvlNfs , aclone(_aTabAux) )

        TRBNFR->(dbSkip())
    EndDo

    TRBNFR->(dbCloseArea())

    if len(_aPvlNfs) > 0
        _cNota := MAPVLNFS(_aPvlNfs , _cSerie , .F. , .F. , .F. , .T. , .F. , 0 , 0 , .T. , .F.) 
        PUTGLBVALUE("CNF_PAR" , _cNota) 							// --> ALIMENTA NO. DA NF
    endif

    SF4->(RestArea( _aAreaSF4 ))
    SB2->(RestArea( _aAreaSB2 ))
    SB1->(RestArea( _aAreaSB1 ))
    SE4->(RestArea( _aAreaSE4 ))
    SC9->(RestArea( _aAreaSC9 ))
    SC6->(RestArea( _aAreaSC6 ))
    SC5->(RestArea( _aAreaSC5 ))

    If _cTipo == "002" // Complemento das notas de remessa
        xComple2(_cPedido, _cNota, _cSerie)
    Else // Complemento das notas de faturamento
        xComple1(_cPedido, _cNota, _cSerie)
    EndIF

    RestArea( _aAreaOLD )
    //conout("Geracao da nota fiscal: "+_cNota)
RETURN .T.

/*/{PROTHEUS.DOC} xconvxml
TOTVS RENTAL - m�dulo 94
Rotina para geracao do complemento das notas de remessa
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function xComple2(_cPedido, _cNota, _cSerie)
Local _aArea := GetArea()
    // Gravar o n�mero da nota de remessa no campo FQ2_NFSER
    // Frank em 06/07/21
    SF2->(RecLock("SF2",.F.))
    SF2->F2_IT_ROMA := FQ2->FQ2_NUM
    SF2->(MsUnlock())

    FQ2->(RecLock("FQ2",.F.))
    FQ2->FQ2_NFSER := alltrim(_cNota) +"\"+ _cSerie
    FQ2->(MsUnlock())

    SC6->(DBSETORDER(4))
    SC6->(DBSEEK(XFILIAL("SC6")+SF2->F2_DOC+SF2->F2_SERIE))
    WHILE !SC6->(EOF()) .AND. SC6->C6_FILIAL == XFILIAL("SC6") .AND. SC6->(C6_NOTA+C6_SERIE) == SF2->F2_DOC+SF2->F2_SERIE
        IF !EMPTY(SC6->C6_XAS)
            FQ3->(DBSETORDER(3))
            IF FQ3->(DBSEEK(XFILIAL("FQ3")+SC6->C6_XAS))
                IF EMPTY(FQ3->FQ3_NFREM) .AND. FQ3->FQ3_NUM = SF2->F2_IT_ROMA
                    FQ3->(RECLOCK("FQ3",.F.))
                    FQ3->FQ3_NFREM	:= SF2->F2_DOC
                    FQ3->FQ3_SERREM	:= SF2->F2_SERIE
                    FQ3->(MSUNLOCK())
                ENDIF
            ENDIF
        ENDIF
        SC6->(DBSKIP())
    ENDDO
    RestArea(_aArea)
Return

/*/{PROTHEUS.DOC} xconvxml
TOTVS RENTAL - m�dulo 94
Rotina para geracao do complemento das notas de faturamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function xComple1(_cPedido, _cNota, _cSerie)
Local _aArea := GetArea()
    SC5->(dbSetOrder(1))
    SC5->(dbSeek(xFilial("SC5")+_cPedido))
    SC6->(dbSetOrder(1))
    SC6->(dbSeek(xFilial("SC6")+_cPedido))
    While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == _cPedido
        If SC6->C6_NOTA <> _cNota .or. SC6->C6_SERIE <> _cSerie .or. empty(SC6->C6_XAS)
            SC6->(dbSkip())
            Loop
        EndIF
        FPA->(dbSetOrder(3))
        If FPA->(dbSeek(xFilial("FPA")+SC6->C6_XAS))
            FP1->(dbSetOrder(1))
            FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
            _dDtIni  := ctod("")
            _dDtFim  := ctod("")
            dProxFat := ctod("")
            dUltFat  := ctod("")
            nDiasTrb := 0
            _cPerLoc := ""
            do case
                case FPA->FPA_TPBASE == "M"
                    nDiasTrb := 30
                case FPA->FPA_TPBASE == "Q"
                    nDiasTrb := 15
                case FPA->FPA_TPBASE == "S"
                    nDiasTrb :=  7
                oTherWise
                    do case
                        case FPA->( fieldpos("FPA_LOCDIA") ) > 0 
                            nDiasTrb := FPA->FPA_LOCDIA 
                        case FPA->( fieldpos("FPA_PREDIA") ) > 0 
                            nDiasTrb := FPA->FPA_PREDIA 
                        oTherWise
                            nDiasTrb := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1 
                    endcase
            endcase
            If empty(FPA->FPA_ULTFAT) 
                do case
                    case (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30 .and. FP1->FP1_TPMES == "1" .and. empty(FPA->FPA_DTSCRT) 
                        _dDtIni := FPA->FPA_DTINI 
                        _dDtFim := FPA->FPA_DTFIM 
                    case (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30 .and. FP1->FP1_TPMES == "1" .and. !empty(FPA->FPA_DTSCRT) 
                        _dDtIni := FPA->FPA_DTINI 
                        _dDtFim := FPA->FPA_DTSCRT 
                    case (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30 .and. FP1->FP1_TPMES == "0" .and. empty(FPA->FPA_DTSCRT)
                        _dDtIni := FPA->FPA_DTINI 
                        _dDtFim := FPA->FPA_DTFIM 
                    case (FPA->FPA_DTFIM - FPA->FPA_DTINI) > 30 .and. FP1->FP1_TPMES == "0" .and. !empty(FPA->FPA_DTSCRT)
                        _dDtIni := FPA->FPA_DTINI 
                        _dDtFim := FPA->FPA_DTSCRT 
                    case (FPA->FPA_DTFIM - FPA->FPA_DTINI) < 30 .and. !empty(FPA->FPA_DTSCRT) 
                        _dDtIni := FPA->FPA_DTINI 
                        _dDtFim := FPA->FPA_DTSCRT 
                    case (FPA->FPA_DTFIM - FPA->FPA_DTINI) < 30 .and. empty(FPA->FPA_DTSCRT) 
                        _dDtIni := FPA->FPA_DTINI 
                        _dDtFim := FPA->FPA_DTFIM 
                    otherwise 
                endcase
                dProxFat := (FPA->FPA_DTFIM + nDiasTrb + 1) 
                dUltFat	 := FPA->FPA_DTFIM 
            else 										// SE TIVER DATA DE ULTIMO FATURAMENTO
                do case
                    case (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30 .and. FP1->FP1_TPMES == "1" .and. empty(FPA->FPA_DTSCRT) 
                        _dDtIni := FPA->FPA_ULTFAT 
                        _dDtFim := FPA->FPA_DTFIM 
                    case (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30 .and. FP1->FP1_TPMES == "1" .and. !empty(FPA->FPA_DTSCRT)
                        _dDtIni := FPA->FPA_ULTFAT 
                        _dDtFim := FPA->FPA_DTSCRT 
                    case (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30 .and. FP1->FP1_TPMES == "0" .and. empty(FPA->FPA_DTSCRT)
                        _dDtIni := FPA->FPA_ULTFAT 
                        _dDtFim := FPA->FPA_DTFIM 
                    case (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) > 30 .and. FP1->FP1_TPMES == "0" .and. !empty(FPA->FPA_DTSCRT) 
                        _dDtIni := FPA->FPA_ULTFAT 
                        _dDtFim := FPA->FPA_DTSCRT 
                    case (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) < 30 .and. !empty(FPA->FPA_DTSCRT)
                        _dDtIni := FPA->FPA_ULTFAT 
                        _dDtFim := FPA->FPA_DTSCRT 
                    case (FPA->FPA_DTFIM - FPA->FPA_ULTFAT) < 30 .and. empty(FPA->FPA_DTSCRT)
                        _dDtIni := FPA->FPA_ULTFAT 
                        _dDtFim := FPA->FPA_DTFIM  
                ENDCASE
                dProxFat := (FPA->FPA_DTFIM + nDiasTrb + 1) 
                dUltFat	 := FPA->FPA_DTFIM 
            ENDIF
            IF EMPTY(FPA->FPA_ULTFAT)
                _dDtIni := FPA->FPA_DTINI
            ELSE
                _dDtIni := FPA->FPA_ULTFAT + 1
            ENDIF
            IF FPA->FPA_TIPOSE $ "Z#O"
                _dDtIni  := FPA->FPA_DTINI 
                _dDtFim  := FPA->FPA_DTENRE 
                dProxFat := FPA->FPA_DTFIM 
                dUltFat  := FPA->FPA_DTFIM 
                nValLoc  := FPA->FPA_VRHOR 
            ELSE
                IF FP1->FP1_TPMES == "0"				// MES FECHADO
                    NDIASTRB := 30 
					_DDTFIM  := FPA->FPA_DTFIM 
					DULTFAT  := _DDTFIM 
					DPROXFAT := MONTHSUM(DULTFAT,1) 
							
					// somente se o dia for 30 e proximo mes 31
					// se for 29 de janeiro validar o maior dia de fevereiro
					// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
					If day(dProxFat) == 30 .or. (month(dUltfat) == 1 .and. day(dultfat) == 28)  .or. (month(dUltfat) == 2 .and. (day(dultfat) == 28.or.day(dultfat) == 29))
						nMes := month(dproxfat)
						while nMes == month(dproxfat)
							dProxFat ++
						EndDo
						dproxfat := dproxfat - 1
					EndIf

                    // Frank em 20/07/22 - somente quando for segundo faturamento em diante
					// considerar os dias corretos para o calculo
					IF !EMPTY(FPA->FPA_ULTFAT)
						NDIASTRB := _DDTFIM - _DDTINI + 1
					EndIf
							
	
					IF EMPTY(FPA->FPA_ULTFAT) //.AND. DAY(_DDTINI) - 1 <> DAY(_DDTFIM)
						NDIASTRB := _DDTFIM - _DDTINI + 1 
					ENDIF
	
					IF !EMPTY(FPA->FPA_DTSCRT)
						IF FPA->FPA_DTSCRT < _DDTFIM
							NDIASTRB := 30 - (_DDTFIM - FPA->FPA_DTSCRT)
							_DDTFIM  := FPA->FPA_DTSCRT
						ENDIF 
					ENDIF 

                else
                    if empty(FPA->FPA_DTSCRT)
                        _dDtFim := _dDtIni + nDiasTrb - 1
                    else
                        if _dDtIni + nDiasTrb - 1 < FPA->FPA_DTSCRT
                            _dDtFim := _dDtIni + nDiasTrb - 1
                        else
                            _dDtFim := FPA->FPA_DTSCRT
                        endif
                    endif
                    dUltFat  := _dDtFim
                    dProxFat := dUltFat + nDiasTrb
                ENDIF
            ENDIF
            _cPerLoc := dtoc(_dDtIni) + " A " + dtoc(_dDtFim) 
            
            SC6->(Reclock("SC6",.F.))
            SC6->C6_XPERLOC := _cPerLoc
            SC6->(MsUnlock())

            FPA->(RecLock("FPA",.F.))
            FPA->FPA_ULTFAT := dUltFat
            FPA->FPA_DTFIM  := dProxFat
            FPA->(MsUnlock())

        EndIF
        SC6->(dbSkip())
    EndDo
    RestArea(_aArea)
Return

/*/{PROTHEUS.DOC} LOCA076
TOTVS RENTAL - m�dulo 94
Rotina para processamento via Job das notas de remessa e notas de faturamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/

/*
[ONSTART]
JOBS=JOBRM
[JOBRM]
main=conout
environment=envp12
instances=3
nparms=2
parm1="01" 
parm2="0101"
*/
Function LOCA076(_cEmpX, _cFilX)
Local _lTela   := .F. // se exibe mensagens e barra de processamento 
    If empty(_cEmpX)
        _lTela := .T.               
        Processa({ || LOCA76I(_cEmpX, _cFilX, _lTela)},STR0001,STR0002,.T.) // "Integra��o RM - Localizando NFs"###"Gerando NFs"
    else
        LOCA76I(_cEmpX, _cFilX, _lTela)
    EndIF
Return

/*/{PROTHEUS.DOC} LOCA076I
TOTVS RENTAL - m�dulo 94
Processamento do Job das notas de remessa e notas de faturamento (inclusao)
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/

Function LOCA76I(_cEmpX, _cFilX, _lTela)
Local _cQuery
Local _cTipos 
Local _nX
Local _aTipos 
Local _cTesR1
Local _cTesR2
Local _cTipo
Local _nTot    := 0

Default _cEmpX := ""
Default _lTela := .F.

//conout("entrou na rotina de geracao das notas")

    If !empty(_cEmpX)
        PREPARE ENVIRONMENT EMPRESA _cEmpx FILIAL _cFilx
    else
        _lTela := .T.
    EndIF
    _cTipos := alltrim(GetMV("MV_LOCX299",,""))
    If empty(_cTipos)
        Return
    EndIF
    _aTipos := {}
    For _nX := 1 to len(_cTipos)
        If substr(_cTipos,_nX,1) == "["
            aadd(_aTipos,{substr(_cTipos,_nX+1,3),substr(_cTipos,_nX+5,3)})
        EndIf
    Next
    _cTesR1 := supergetmv("MV_LOCX084",.F.,"") 
    _cTesR2 := supergetmv("MV_LOCX083",.F.,"") 
    If !empty(_cTesR1)
        aadd(_aTipos,{"002",_cTesR1})
    EndIF
    If !empty(_cTesR2)
        aadd(_aTipos,{"002",_cTesR2})
    EndIF

    If _lTela
        If !pergunte("LOCA076",.T.)
            Return
        EndIF
    EndIF

    If select("TRBSC6") > 0
        TRBSC6->(dbCloseArea())
    ENDIF
    _cQuery := " SELECT DISTINCT SC5.R_E_C_N_O_ AS REGSC5 " 
    _cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK) " 
    _cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 (NOLOCK) ON  C5_FILIAL = '" + xFilial("SC5") + "'" 
    _cQuery += " AND SC5.C5_NUM = SC6.C6_NUM AND SC5.D_E_L_E_T_ = '' " 
    _cQuery += " WHERE  SC6.C6_FILIAL  = '" + xFilial("SC6") + "'" 
    If _lTela
        _cQuery += " AND SC6.C6_NUM >= '"+MV_PAR01+"' AND SC6.C6_NUM <= '"+MV_PAR02+"' "
    EndIF
    _cQuery += " AND SC6.C6_NOTA  = '' "
    _cQuery += " AND SC6.C6_XAS <> '' "
    _cQuery += " AND SC6.D_E_L_E_T_ = '' "  
    //_cQuery += " AND SC5.C5_NUM = '001241' "  
    _cQuery += " ORDER BY SC5.R_E_C_N_O_ " 
    _cQuery := changeQuery(_cQuery)
    TCQUERY _cQuery NEW ALIAS "TRBSC6"
    While !TRBSC6->(Eof())
        _nTot ++
        TRBSC6->(dbSkip())
    EndDo
    If _lTela
        ProcRegua(_nTot)
    EndIF
    TRBSC6->(dbGotop())
    While !TRBSC6->(Eof())
        SC5->(dbGoto(TRBSC6->REGSC5))
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))

        If _lTela
            IncProc(STR0003+SC5->C5_NUM) // "Processando o pedido de venda: "
        EndIf

        _cTipo := ""
        For _nX := 1 to len(_aTipos)
            If _aTipos[_nX][02] == SC6->C6_TES
                _cTipo := _aTipos[_nX][01]
                Exit
            EndIF
        Next

        //conout("Pedido de vendas a ser processado: "+SC5->C5_NUM)

        If !empty(_cTipo)    
            // Posicionamento na FQ2 - cabe�alho do romaneio
            FQ3->(dbSetOrder(3))
            If FQ3->(dbSeek(xFilial("FQ3")+SC6->C6_XAS)) // pegar qualquer linha da SC6 valida para gerar a integracao
                FQ2->(dbSetOrder(1))
                If FQ2->(dbSeek(xFilial("FQ2")+FQ3->FQ3_NUM))
                    //Conout("Integracao Protheus x RM - Processando o pedido de venda: "+SC5->C5_NUM)
                    LOCA076A(SC5->C5_NUM, _cTipo)
                    sleep(1000)
                Else
                    conou("nao acho a fq2")
                EndIf
            else
                //conout("n�o localizou o conj transp")
            EndIF
        EndIF
        TRBSC6->(dbSkip())
    EndDo
    TRBSC6->(dbCloseArea())

Return

/*/{PROTHEUS.DOC} LOCA076E
TOTVS RENTAL - m�dulo 94
EXCLUSAO: Rotina para processamento via Job das notas de remessa e notas de faturamento
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/

/*
[ONSTART]
JOBS=JOBRM
[JOBRM]
main=conout
environment=envp12
instances=3
nparms=2
parm1="01" 
parm2="0101"
*/
Function LOCA076E(_cEmpX, _cFilX)
Local _lTela := .F.
    If empty(_cEmpX)
        _lTela := .T.
    EndIf
    If _lTela    
        Processa({ || LOCA76E(_cEmpX, _cFilX, _lTela)},STR0004,STR0005,.T.) // "Integra��o RM - Localizando cancelamentos."###"Cancelamento das notas"
        //Processa({ || LOCA76EE(_cEmpX, _cFilX, _lTela)},STR0006,STR0007,.T.) //"Integra��o RM - Localizando cancelamentos NFe."###"Cancelamento das notas NFe"
    else
        LOCA76E(_cEmpX, _cFilX, _lTela)
        //LOCA76EE(_cEmpX, _cFilX, _lTela)
    EndIf
Return

/*/{PROTHEUS.DOC} LOCA76E
TOTVS RENTAL - m�dulo 94
Processamento do Job das notas de remessa e notas de faturamento (exclusao)
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/

Function LOCA76E(_cEmpX, _cFilX, _lTela)
Local _cQuery
Local _cTipos 
Local _nX
Local _aTipos 
Local _cTesR1
Local _cTesR2
Local _cTipo
Local _nTot    := 0

Default _cEmpX := ""
Default _lTela := .F.

    If !empty(_cEmpX)
        PREPARE ENVIRONMENT EMPRESA _cEmpx FILIAL _cFilx
    EndIF
    _cTipos := alltrim(GetMV("MV_LOCX299",,""))
    If empty(_cTipos)
        Return
    EndIF
    _aTipos := {}
    For _nX := 1 to len(_cTipos)
        If substr(_cTipos,_nX,1) == "["
            aadd(_aTipos,{substr(_cTipos,_nX+1,3),substr(_cTipos,_nX+5,3)})
        EndIf
    Next
    _cTesR1 := supergetmv("MV_LOCX084",.F.,"") 
    _cTesR2 := supergetmv("MV_LOCX083",.F.,"") 
    If !empty(_cTesR1)
        aadd(_aTipos,{"002",_cTesR1})
    EndIF
    If !empty(_cTesR2)
        aadd(_aTipos,{"002",_cTesR2})
    EndIF

    If select("TRBSC6") > 0
        TRBSC6->(dbCloseArea())
    ENDIF
    _cQuery := " SELECT DISTINCT SC5.R_E_C_N_O_ AS REGSC5 " 
    _cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK) " 
    _cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 (NOLOCK) ON  C5_FILIAL = '" + xFilial("SC5") + "'" 
    _cQuery += " AND SC5.C5_NUM = SC6.C6_NUM AND SC5.D_E_L_E_T_ = '' AND SC5.C5_EMISSAO >= '"+dtos(dDataBase-30)+"' "
    _cQuery += " WHERE  SC6.C6_FILIAL  = '" + xFilial("SC6") + "'" 
    _cQuery += " AND SC6.C6_NOTA  <> '' "
    _cQuery += " AND SC6.C6_XAS <> '' "
    _cQuery += " AND SC6.D_E_L_E_T_ = '' "  
    _cQuery += " ORDER BY SC5.R_E_C_N_O_ " 
    _cQuery := changeQuery(_cQuery)
    TCQUERY _cQuery NEW ALIAS "TRBSC6"
    While !TRBSC6->(Eof())
        _nTot ++
        TRBSC6->(dbSkip())
    EndDo

    If _lTela 
        ProcRegua(_nTot)
    EndIf

    TRBSC6->(dbGotop())
    While !TRBSC6->(Eof())
        SC5->(dbGoto(TRBSC6->REGSC5))
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
        If SC6->C6_DATFAT < dDatabase - 90
            TRBSC6->(dbSkip())
            Loop
        EndIf

        If _lTela
            IncProc(STR0008+SC5->C5_NUM) //"Processando o pedido de venda: "
        EndIf

        _cTipo := ""
        For _nX := 1 to len(_aTipos)
            If _aTipos[_nX][02] == SC6->C6_TES
                _cTipo := _aTipos[_nX][01]
                Exit
            EndIF
        Next

        If !empty(_cTipo)    
            // Posicionamento na FQ2 - cabe�alho do romaneio
            FQ3->(dbSetOrder(3))
            If FQ3->(dbSeek(xFilial("FQ3")+SC6->C6_XAS)) // pegar qualquer linha da SC6 valida para gerar a integracao
                FQ2->(dbSetOrder(1))
                If FQ2->(dbSeek(xFilial("FQ2")+FQ3->FQ3_NUM))
                    //Conout("Integracao Protheus x RM Extorno - Processando o pedido de venda: "+SC5->C5_NUM)
                    LOCA076A(SC5->C5_NUM, _cTipo, "S")
                EndIf
            EndIF
        EndIF
        TRBSC6->(dbSkip())
    EndDo
    TRBSC6->(dbCloseArea())

Return


/*/{PROTHEUS.DOC} LOCA76R
TOTVS RENTAL - m�dulo 94
Processamento do retorno das notas
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/

Function LOCA76R
    Processa({ || LOCA76RP()},STR0009,STR0010,,.T.) //"Integra��o RM - Retornos"###"Localizando as notas de retorno"
Return

/*/{PROTHEUS.DOC} LOCA76RP
TOTVS RENTAL - m�dulo 94
Processamento do retorno das notas
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/

Function LOCA76RP()
Local lGera         := .F.
Local nX
Local nJanelaa      := 385 
Local nJanelal      := 900
Local oBut1
Local oBut2
Local oBut3
Local nOpc          := "0"
Local nLbtaml	    := 438
Local nLbtama	    := 160	
Local lMark         := .F.
Local oOk           := LoadBitMap(GetResources(),"LBOK")
Local oNo           := LoadBitMap(GetResources(),"LBNO") 

Private aProcessa   := {}
Private aRetorno    := {}
Private aRetProc    := {}
Private aIteProc    := {}
Private oDlgRet
Private oLista

    FQ3->(dbSetOrder(1))
    FQ3->(dbSeek(xFilial("FQ2")+FQ2->FQ2_NUM))
    While !FQ3->(Eof()) .and. FQ3->(FQ3_FILIAL+FQ3_NUM) == xFilial("FQ3")+FQ2->FQ2_NUM

        FPA->(dbSetOrder(3))
        If FPA->(dbSeek(xFilial("FPA")+FQ3->FQ3_AS))

            lGera := .F.

            If !empty(FPA->FPA_NFREM) .and. empty(FPA->FPA_NFRET)
                lGera := .T.
            EndIf

            If lGera
                aadd(aProcessa,{    FQ3->FQ3_AS,;
                                    FQ3->FQ3_CODBEM,;
                                    FQ3->FQ3_PROD,;
                                    FQ3->FQ3_PROJET,;
                                    FQ3->FQ3_QTD,;
                                    FPA->FPA_NFREM,;    // Nota fiscal de sa�da
                                    FPA->FPA_SERREM,;   // S�rie da nota fiscal de sa�da
                                    FQ3->(Recno()),;
                                    FPA->(Recno()),;
                                    "",;                // Nota fiscal de retorno localizada no RM
                                    "",;                // S�rie da nota fiscal de retorno localizada no RM
                                    .T.,;               // Todas as informa��es do retorno batem com o envio
                                    "",;                // Motivo do erro no processamento 
                                    FPA->FPA_PEDIDO,;   // Pedido de vendas (remessa)
                                    FPA->FPA_FILREM})   // Filial da emiss�o do pedido de vendas
            EndIF
        EndIf
        FQ3->(dbSkip())
    EndDo

    ProcRegua(len(aProcessa))

    For nX := 1 to len(aProcessa)    
        //IncProc("Localizando o retorno da nota de remessa: "+alltrim(aProcessa[nX,6]))
        LOCA76RX(nX)
    Next

    If empty( aRetProc )
        MsgAlert(STR0011,STR0012) //"N�o foram localizados retornos no RM."###"Aten��o!"
    Else
        Define MsDialog oDlgRet Title STR0013 FROM 010,005 TO NJANELAA,NJANELAL PIXEL //"Avalia��o da nota de Retorno"
            @ 014,005 say STR0014 size 80,12 of oDlgRet pixel //"Contrato:"
            @ 010,035 msget FQ2->FQ2_PROJET size 120,12 of oDlgRet pixel When .F.
            @ 014,180 say STR0015 size 80,12 of oDlgRet pixel //"Romaneio:"
            @ 010,215 msget FQ2->FQ2_NUM size 120,12 of oDlgRet pixel When .F.

            @ 172,375 button oBut1 Prompt STR0016 size 70,12 of oDlgRet pixel action ( GERNFE(oDlgRet) ) //"Gerar Nota de Retorno"
            @ 172,300 button oBut2 Prompt STR0017 size 70,12 of oDlgRet pixel action (nOpc := "0", oDlgRet:end()) //"Cancela a Opera��o"
            @ 172,225 button oBut3 Prompt STR0018 size 70,12 of oDlgRet pixel action ( VERNFR() ) //"Dados NF Retorno"
        
        
            @ 0.5,0.7 ListBox oLista fields header " ",STR0019, STR0020, STR0021 size nLbtaml, nLbtama on dblClick (marcarregi(.F.))  //"Nota de Retorno"###"S�rie"###"Data"
            oLista:SETARRAY(aRetProc)
            oLista:BLINE := {|| { IF( aRetProc[oLista:NAT,1],OOK,ONO),;   // CHECKBOX
                                    aRetProc[oLista:NAT,2],;   	 	  // Nota de retorno
                                    aRetProc[oLista:NAT,3],;            // S�rie
                                    aRetProc[oLista:NAT,4]}}            // Data	
            
        
        Activate MsDialog oDlgRet Centered

    EndIf

Return

/*/{PROTHEUS.DOC} MARCARREGI
TOTVS RENTAL - m�dulo 94
Tratamento da listbox para selecao as notas de retorno
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function MARCARREGI(lTodos)
Local nI        := 0 
Local lMarcados := aRetProc[oLista:nAt,1]

    For nI := 1 to len(aRetProc)
        If aRetProc[nI,1] .and. nI <> oLista:nAt
            MsgAlert(STR0022,STR0023) //"J� existe uma nota selecionada."###"Aten��o!"
            Return .F.
        EndIF
    Next

    If lTodos
        lMarcados := ! lMarcados
        For nI := 1 to len(aRetProc)
            aRetProc[nI,1] := lMarcados
        Next 
    Else
        aRetProc[oLista:nAt,1] := !lMarcados
    EndIf

    oLista:refresh()
    oDlgRet:refresh()
	
Return

/*/{PROTHEUS.DOC} LOCA76RX
TOTVS RENTAL - m�dulo 94
Localizar as notas de retorno no RM
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Function LOCA76RX(nPos)
local oWsdl as object
local _nX, nI, _nZ, _nY
Local cError   := ""
Local cWarning := ""
Local oXml := NIL
Local _lRet
Local _cXmlTemp
Local _cNota
Local _cSerie
Local _aItens
Local _cItem
Local _cEnde    := AllTrim(getmv("MV_LOCX300",,"http://10.171.66.159:8051/EAIService/MEX?wsdl"))
Local _cUsu     := AllTrim(getmv("MV_LOCX301",,"mestre"))
Local _cSenha   := AllTrim(getmv("MV_LOCX302",,"totvs"))
Local _cTemp
Local _nConta
Local cNotaRet      := ""
Local cSerieRet     := ""
Local cData         := ""
Local cProduto      := ""
Local cVinculo      := ""
Local cUnidade      := ""
Local cUnitario     := ""
Local cTotal        := ""
Local nX
Local lAcha
Local cTmp          := ""
Local _aItensRet    := {}
Local cTempXXF
Local nRet
Local nRetItens

    IncProc(STR0024+alltrim(aProcessa[nPos,6])) //"Localizando o retorno da nota de remessa: "

    _cPedido    := aProcessa[nPos,14]
    _cTipo      := "002"
    _cDel       := "N"
    _cNota      := alltrim(aProcessa[nPos,6])
    _cSerie     := alltrim(aProcessa[nPos,7])

    oWsdl := TWsdlManager():New()
    oWsdl:lVerbose := .T.
    oWsdl:bNoCheckPeerCert := .T. // Desabilita o check de CAs 

    //Verifica o endere�o, se existe algum servi�o dispon�vel e se existe o servi�o que quero utilizar
    if !oWsdl:ParseURL(_cEnde)
        Return
    else

        //Informo o usu�rio e senha via basic em base64 no header da requisi��o
        oWsdl:AddHttpHeader("Authorization", "Basic " + Encode64(_cUsu+":"+_cSenha))

        aOps := oWsdl:ListOperations()
        _lRet:= oWsdl:SetOperation( "receiveMessage" )

        If !_lRet
            Return
        EndIF

        //Informo o usu�rio e senha via basic em base64 no header da requisi��o
        //oWsdl:AddHttpHeader("Authorization", "Basic " + Encode64("mestre:totvs"))

        _cEnv := '<![CDATA[<?xml version="1.0" encoding="utf-8"?>'
        _cEnv += '<TOTVSMessage>'
        _cEnv += '<MessageInformation version="1.000">'
        _cEnv += '<UUID>'+FWUUID('000001')+'</UUID>'
        _cEnv += '<Type>BusinessMessage</Type>'
        _cEnv += '<Transaction>TRACEABILITYORDER</Transaction>'
        _cEnv += '<StandardVersion>1.000</StandardVersion>'
        _cEnv += '<SourceApplication>PROT</SourceApplication>'
        _cEnv += '<CompanyId>'+cEmpAnt+'</CompanyId>'
        _cEnv += '<BranchId>'+cFilAnt+'</BranchId>'
        _cEnv += '<Enterprise></Enterprise>'
        _cEnv += '<BusinessUnit></BusinessUnit>'
        _cEnv += '<CompanySharingMode>E</CompanySharingMode>'
        _cEnv += '<BusinessUnitySharingMode>E</BusinessUnitySharingMode>'
        _cEnv += '<BranchSharingMode>E</BranchSharingMode>'
        _cEnv += '<Product name="PROTHEUS" version="12"/>'
        _cEnv += '<GeneratedOn>2021-09-21T11:33:42Z</GeneratedOn>'
        _cEnv += '<DeliveryType>Sync</DeliveryType>'
        _cEnv += '</MessageInformation>'
        _cEnv += '<BusinessMessage>'
        _cEnv += '<BusinessEvent>'
        _cEnv += '<Entity>TRACEABILITYORDER</Entity>'
        _cEnv += '<Event>upsert</Event>'
        _cEnv += '<Identification>'
        _cEnv += '<key name="InternalId">'+cEmpAnt+'|'+cFilAnt+'|'+_cPedido+'|2</key>'
        _cEnv += '</Identification>'
        _cEnv += '</BusinessEvent>'
        _cEnv += '<BusinessContent>'
        _cEnv += '<RequestItem>'
        _cEnv += '<OrderInternalId>'+cEmpAnt+'|'+cFilAnt+'|'+_cPedido+'|2</OrderInternalId>'
        _cEnv += '<TypeOrder>'+_cTipo+'</TypeOrder>'
        _cEnv += '<ShippingInvoiceSeries>'+_cSerie+'</ShippingInvoiceSeries>'
        _cEnv += '<ShippingInvoiceNumber>'+_cNota+'</ShippingInvoiceNumber>'
        _cEnv += '</RequestItem>'
        _cEnv += '</BusinessContent>'
        _cEnv += '</BusinessMessage>'
        _cEnv += '</TOTVSMessage>]]>'

        _lRet := oWsdl:SetValue( 0, _cEnv )
        if !_lRet
            Return
        EndIF

        // mensagem que � enviada
        xxx := oWsdl:GetSoapMsg()
        
        // Envia a mensagem SOAP ao servidor
        _lRet := oWsdl:SendSoapMsg()
        if !_lRet
            Return
        EndIF

        // Pega a mensagem de resposta
        _cXmlTemp := oWsdl:GetSoapResponse()

        // Correcao do html do retorno do xml
        _cXml := xconvxml(_cXmlTemp)

        oXml := XmlParser( _cXml, "_", @cError, @cWarning )
        If (oXml == NIL )
            Return
        Endif

        _cResp := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_RESPONSEMESSAGE:_RETURNCONTENT:_RETURNMESSAGE:TEXT 
        If upper(alltrim(substr(_cResp,1,7))) == "NENHUMA"
            Return
        EndIF

        // verificar se o conteudo vem como array
        // oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype
        // se n�o vier tem um item s�, manter o c�digo abaixo.
        // se for um array pegar para cada item do retorno do array o c�digo abaixo.
        // arrumar na segunda
        
        // Tratamento para retornar mais de uma nota no xml
        //If valtype(oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype) == "A"
        xObj := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype
        If type("xObj") == "A"
            aNotasRet := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype
            For nRet := 1 to len(aNotasRet)

                cNotaRet   := aNotasRet[nRet]:_number:text
                cSerieRet  := aNotasRet[nRet]:_invoicedocumentserie:text
                cData      := aNotasRet[nRet]:_RegisterDateTime:Text
                _aItensRet := {}

                // Frank em 26/07/2022
                // Se a nota do RM vier com tamanho diferente, no caso, menor do que a do Protheus
                // temos que inserir espacos em branco no final
                if len(cNotaRet) < tamsx3("F1_DOC")[1]
                    cNotaRet := cNotaRet + space( tamsx3("F1_DOC")[1] - len(cNotaRet) )
                EndIf
                if len(cSerieRet) < tamsx3("F1_SERIE")[1]
                    cSerieRet := cSerieRet + space( tamsx3("F1_SERIE")[1] - len(cSerieRet) )
                EndIf

                // Frank em 26/09/22 - n�o permitir retornar notas j� processadas
                SF1->(dbSetOrder(1))
                If SF1->(dbSeek(xFilial("SF1")+cNotaRet+cSerieRet))
                    Loop
                EndIf


                // Tratamento para quando retornar mais de um item por nota
                If valtype(aNotasRet[nRet]:_listoftitem:_item:_itemtype) == "A"
                    aRetIntes := aNotasRet[nRet]:_listoftitem:_item:_itemtype
                    For nRetItens := 1 to len(aRetIntes)
                        _cItem  := aRetIntes[nRetItens]:_InternalId:text
                        _cQuant := alltrim(aRetIntes[nRetItens]:_quantity:text)
                        
                        // Localizar registros na XXF
                        cProduto      := "" // c�digo do produto
                        cVinculo      := "" // vinculo com a nota fiscal de saida
                        cUnidade      := "" // unidade de medida
                        cUnitario     := "" // valor unitario
                        cTotal        := "" // valor total do item
                        cTmp          := "" // variavel para localizar na xxf os campos acima

                        // Produto
                        cTmp := aRetIntes[nRetItens]:_ItemInternalId:text
                        If valtype(cTmp) == "C"
                            //cTempXXF := "XXF->(dbSetOrder(1))"
                            //&(cTempXXF)
                            //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SB1")+"SB1"+"B1_COD    "+cTmp))'
                            //If &(cTempXXF)
                            //    cTempXXF := "XXF->XXF_INTVAL"
                            //    cProduto := &(cTempXXF)
                            //EndIf

                            _CQUERY := " SELECT XXF_INTVAL "
	                        _CQUERY += " FROM XXF "
	                        _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                            _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SB1")+"' AND "
                            _CQUERY += " XXF_ALIAS = 'SB1' AND "
                            _CQUERY += " XXF_FIELD = 'B1_COD' "
                            _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                            IF SELECT("TRBXXF") > 0
                                TRBXXF->(DBCLOSEAREA())
                            ENDIF
                            _CQUERY := CHANGEQUERY(_CQUERY)
                            TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                            If !TRBXXF->(Eof())
                                //cTempXXF := "XXF->XXF_INTVAL"
                                cProduto := TRBXXF->XXF_INTVAL //&(cTempXXF)
                            Else
                                cProduto := ""
                            EndIF
                            TRBXXF->(DBCLOSEAREA())

                        EndIf

                        // vinculo
                        cTmp := alltrim(aRetIntes[nRetItens]:_OrderItemInternalId:text)
                        If valtype(cTmp) == "C"

                            _CQUERY := " SELECT XXF_INTVAL "
	                        _CQUERY += " FROM XXF "
	                        _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                            _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SC6")+"' AND "
                            _CQUERY += " XXF_ALIAS = 'SC6' AND "
                            _CQUERY += " XXF_FIELD = 'C6_ITEM' "
                            _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                            IF SELECT("TRBXXF") > 0
                                TRBXXF->(DBCLOSEAREA())
                            ENDIF
                            _CQUERY := CHANGEQUERY(_CQUERY)
                            TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                            If !TRBXXF->(Eof())
                                //cTempXXF := "XXF->XXF_INTVAL"
                                cVinculo := TRBXXF->XXF_INTVAL //&(cTempXXF)
                            Else
                                cVinculo := ""
                            EndIF
                            TRBXXF->(DBCLOSEAREA())

                            //cTempXXF := "XXF->(dbSetOrder(1))"
                            //&(cTempXXF)
                            //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SC5")+"SC5"+"C5_NUM    "+cTmp))'
                            //If &(cTempXXF)
                            //    cTempXXF := "XXF->XXF_INTVAL"
                            //    cVinculo := &(cTempXXF)
                            //EndIf
                        EndIf

                        // Verificar se o item em quest�o faz parte do romaneio FQ3
                        // Posicionar na SC5
                        _cTemp  := "" // n�mero do pedido de vendas
                        _cTemp1 := "" // filial do pedido de vendas
                        _cTemp2 := "" // item da SC6
                        _nConta := 0
                        For _nY := 1 to len(cVinculo)
                            If _nConta == 1 .and. substr(cVinculo,_nY,1) <> "|"
                                _cTemp1 += substr(cVinculo,_nY,1)
                            EndIf
                            If _nConta == 2 .and. substr(cVinculo,_nY,1) <> "|"
                                _cTemp += substr(cVinculo,_nY,1)
                            EndIf
                            If _nConta == 3 .and. substr(cVinculo,_nY,1) <> "|"
                                _cTemp2 += substr(cVinculo,_nY,1)
                            EndIf
                            If substr(cVinculo,_nY,1) == "|"
                                _nConta ++
                            EndIf
                        Next 
                        SC6->(dbSetOrder(1))
                        SC6->(dbSeek(xFilial("SC6")+_cTemp+_cTemp2))
                      

                        // Unidade de medida
                        cTmp := alltrim(aRetIntes[nRetItens]:_UnitOfMeasureInternalId:text)
                        If valtype(cTmp) == "C"
                            //cTempXXF := "XXF->(dbSetOrder(1))"
                            //&(cTempXXF)
                            //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SAH")+"SAH"+"AH_UNIMED "+cTmp))'
                            //If &(cTempXXF)
                            //    cTempXXF := "XXF->XXF_INTVAL"
                            //    cUnidade := &(cTempXXF)
                            //EndIf

                            _CQUERY := " SELECT XXF_INTVAL "
	                        _CQUERY += " FROM XXF "
	                        _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                            _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SAH")+"' AND "
                            _CQUERY += " XXF_ALIAS = 'SAH' AND "
                            _CQUERY += " XXF_FIELD = 'AH_UNIMED' "
                            _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                            IF SELECT("TRBXXF") > 0
                                TRBXXF->(DBCLOSEAREA())
                            ENDIF
                            _CQUERY := CHANGEQUERY(_CQUERY)
                            TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                            If !TRBXXF->(Eof())
                                //cTempXXF := "XXF->XXF_INTVAL"
                                cUnidade := TRBXXF->XXF_INTVAL //&(cTempXXF)
                            Else
                                cUnidade := ""
                            EndIF
                            TRBXXF->(DBCLOSEAREA())


                        EndIf

                        cUnitario := alltrim(aRetIntes[nRetItens]:_UnitPrice:text)   
                        cTotal    := alltrim(aRetIntes[nRetItens]:_TotalPrice:text)
                        //cTotal := cUnitario

                        _cTemp := ""
                        _nConta := 0
                        For _nY := 1 to len(_cItem)
                            If _nConta == 2
                                _cTemp += substr(_cItem,_nY,1)
                            EndIf
                            If substr(_cItem,_nY,1) == "|"
                                _nConta ++
                            EndIf
                        Next 
                        If !empty(_cTemp)
                            aadd(_aItensRet,{_cTemp,cProduto,cVinculo,cUnidade,cUnitario,cTotal,_cItem,_cQuant})
                        EndIf

                        If len(_aItensRet) > 0
                            lAcha := .F.
                            For nX := 1 to len(aRetProc)
                                If alltrim(aRetProc[nX,2]) == alltrim(cNotaRet)
                                    lAcha := .T.
                                    exit
                                EndIF
                            Next
                            If !lAcha
                                aadd( aRetProc, { .F., cNotaRet, cSerieRet, ctod( substr(cData,9,2) + "/"+substr(cData,6,2)+"/"+substr(cData,1,4)) })
                                aadd( aIteProc, {cNotaRet, cSerieRet, _aItensRet})
                            EndIF
                        EndIf

                    Next
                Else
                    // Tratamento para quando retornar apenas um item da nota
                    _cItem  := aNotasRet[nRet]:_listoftitem:_item:_itemtype:_internalid:text
                    _cQuant := aNotasRet[nRet]:_listoftitem:_item:_itemtype:_quantity:text

                    // Localizar registros na XXF
                    cProduto      := "" // c�digo do produto
                    cVinculo      := "" // vinculo com a nota fiscal de saida
                    cUnidade      := "" // unidade de medida
                    cUnitario     := "" // valor unitario
                    cTotal        := "" // valor total do item
                    cTmp          := "" // variavel para localizar na xxf os campos acima

                    // Produto
                    cTmp := aNotasRet[nRet]:_listoftitem:_item:_itemtype:_ItemInternalId:text
                    If valtype(cTmp) == "C"
                        //cTempXXF := "XXF->(dbSetOrder(1))"
                        //&(cTempXXF)
                        //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SB1")+"SB1"+"B1_COD    "+cTmp))'
                        //If &(cTempXXF)
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cProduto := &(cTempXXF)
                        //EndIf

                        _CQUERY := " SELECT XXF_INTVAL "
	                    _CQUERY += " FROM XXF "
	                    _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                        _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SB1")+"' AND "
                        _CQUERY += " XXF_ALIAS = 'SB1' AND "
                        _CQUERY += " XXF_FIELD = 'B1_COD' "
                        _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                        IF SELECT("TRBXXF") > 0
                            TRBXXF->(DBCLOSEAREA())
                        ENDIF
                        _CQUERY := CHANGEQUERY(_CQUERY)
                        TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                        If !TRBXXF->(Eof())
                            //cTempXXF := "XXF->XXF_INTVAL"
                            cProduto := TRBXXF->XXF_INTVAL //&(cTempXXF)
                        Else
                            cProduto := ""
                        EndIF
                        TRBXXF->(DBCLOSEAREA())

                    EndIf

                    // vinculo
                    cTmp := alltrim(aNotasRet[nRet]:_listoftitem:_item:_itemtype:_OrderItemInternalId:text)
                    If valtype(cTmp) == "C"

                         If select("TRBXXF") > 0
                            TRBXXF->(dbCloseArea())
                        ENDIF
                        _CQUERY := " SELECT XXF_INTVAL "
	                    _CQUERY += " FROM XXF "
	                    _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                        _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SC6")+"' AND "
                        _CQUERY += " XXF_ALIAS = 'SC6' AND "
                        _CQUERY += " XXF_FIELD = 'C6_ITEM' "
                        _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                        _cQuery := changeQuery(_cQuery)
                        TCQUERY _cQuery NEW ALIAS "TRBXXF"
                        If !TRBXXF->(Eof())
                            //cTempXXF := TRBXXF->XXF_INTVAL
                            cVinculo := TRBXXF->XXF_INTVAL
                        Else
                            cVinculo := ""
                        EndIf
                        TRBXXF->(dbCloseArea())

                        //cTempXXF := "XXF->(dbSetOrder(1))"
                        //&(cTempXXF)
                        //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SC5")+"SC5"+"C5_NUM    "+cTmp))'
                        //If &(cTempXXF)
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cVinculo := &(cTempXXF)
                        //EndIf
                    EndIf

                    // Verificar se o item em quest�o faz parte do romaneio FQ3
                    // Posicionar na SC5
                    _cTemp  := "" // n�mero do pedido de vendas
                    _cTemp1 := "" // filial do pedido de vendas
                    _cTemp2 := "" // item da SC6
                    _nConta := 0
                    For _nY := 1 to len(cVinculo)
                        If _nConta == 1 .and. substr(cVinculo,_nY,1) <> "|"
                            _cTemp1 += substr(cVinculo,_nY,1)
                        EndIf
                        If _nConta == 2 .and. substr(cVinculo,_nY,1) <> "|"
                            _cTemp += substr(cVinculo,_nY,1)
                        EndIf
                        If _nConta == 3 .and. substr(cVinculo,_nY,1) <> "|"
                            _cTemp2 += substr(cVinculo,_nY,1)
                        EndIf
                        If substr(cVinculo,_nY,1) == "|"
                            _nConta ++
                        EndIf
                    Next 
                    SC6->(dbSetOrder(1))
                    SC6->(dbSeek(xFilial("SC6")+_cTemp+_cTemp2))

                    // Unidade de medida
                    cTmp := alltrim(aNotasRet[nRet]:_listoftitem:_item:_itemtype:_UnitOfMeasureInternalId:text)
                    If valtype(cTmp) == "C"
                        //cTempXXF := "XXF->(dbSetOrder(1))"
                        //&(cTempXXF)
                        //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SAH")+"SAH"+"AH_UNIMED "+cTmp))'
                        //If &(cTempXXF)
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cUnidade := &(cTempXXF)
                        //EndIf

                        _CQUERY := " SELECT XXF_INTVAL "
	                    _CQUERY += " FROM XXF "
	                    _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                        _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SAH")+"' AND "
                        _CQUERY += " XXF_ALIAS = 'SAH' AND "
                        _CQUERY += " XXF_FIELD = 'AH_UNIMED' "
                        _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                        _cQuery := changeQuery(_cQuery)
                        TCQUERY _cQuery NEW ALIAS "TRBXXF"
                        If !TRBXXF->(Eof())
                            //cTempXXF := TRBXXF->XXF_INTVAL
                            cVinculo := TRBXXF->XXF_INTVAL
                        Else
                            cVinculo := ""
                        EndIf
                        TRBXXF->(dbCloseArea())
                        //IF SELECT("TRBXXF") > 0
                        //    TRBXXF->(DBCLOSEAREA())
                        //ENDIF
                        //_CQUERY := CHANGEQUERY(_CQUERY)
                        //TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                        //If !TRBXXF->(Eof())
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cUnidade := &(cTempXXF)
                        //Else
                        //    cUnidade := ""
                        //EndIF
                        //TRBXXF->(DBCLOSEAREA())

                    EndIf

                    cUnitario := alltrim(aNotasRet[nRet]:_listoftitem:_item:_itemtype:_UnitPrice:text)   
                    cTotal    := alltrim(aNotasRet[nRet]:_listoftitem:_item:_itemtype:_TotalPrice:text)
                    //cTotal := cUnitario

                    _cTemp := ""
                    _nConta := 0
                    For _nY := 1 to len(_cItem)
                        If _nConta == 2
                            _cTemp += substr(_cItem,_nY,1)
                        EndIf
                        If substr(_cItem,_nY,1) == "|"
                            _nConta ++
                        EndIf
                    Next 
                    If !empty(_cTemp)
                        aadd(_aItensRet,{_cTemp,cProduto,cVinculo,cUnidade,cUnitario,cTotal,_cItem,_cQuant})
                    EndIf

                    If len(_aItensRet) > 0
                        lAcha := .F.
                        For nX := 1 to len(aRetProc)
                            If alltrim(aRetProc[nX,2]) == alltrim(cNotaRet)
                                lAcha := .T.
                                exit
                            EndIF
                        Next
                        If !lAcha
                            aadd( aRetProc, { .F., cNotaRet, cSerieRet, ctod( substr(cData,9,2) + "/"+substr(cData,6,2)+"/"+substr(cData,1,4)) })
                            aadd( aIteProc, {cNotaRet, cSerieRet, _aItensRet})
                        EndIF
                    EndIf

                EndIf
            Next
            
        Else
            // Tratamento para retornar apenas uma nota no xml
            // ------------------------------------------------------------------------------------
            //If valtype(oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_number) == "O"
            //xObj := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_number
            xObj := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype
            If type("xObj") == "O" // veio somente uma nota de entrada

                cNotaRet  := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_number:Text
                cSerieRet := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_invoicedocumentserie:Text
                cData     := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_RegisterDateTime:Text

                // Frank em 26/07/2022
                // Se a nota do RM vier com tamanho diferente, no caso, menor do que a do Protheus
                // temos que inserir espacos em branco no final
                if len(cNotaRet) < tamsx3("F1_DOC")[1]
                    cNotaRet := cNotaRet + space( tamsx3("F1_DOC")[1] - len(cNotaRet) )
                EndIf
                if len(cSerieRet) < tamsx3("F1_SERIE")[1]
                    cSerieRet := cSerieRet + space( tamsx3("F1_SERIE")[1] - len(cSerieRet) )
                EndIf

                _aItens := oxml:_s_envelope:_s_body:_RECEIVEMESSAGERESPONSE:_receivemessageresult:_totvsmessage:_responsemessage:_RETURNCONTENT:_returnitem:_returntype:_listoftitem:_item:_itemtype

                // Para tratamento dos itens quando precisar.
                _aItensRet := {}
                // Se o _aItens for um array � que tem mais de uma linha na SC6
                If valtype(_aItens) == "A"
                    For _nX := 1 to len(_aItens)
                        _cItem  := alltrim(_aitens[_nX]:_internalid:text)
                        _cQuant := alltrim(_aitens[_nX]:_quantity:text)

                        // Localizar registros na XXF
                        cProduto      := "" // c�digo do produto
                        cVinculo      := "" // vinculo com a nota fiscal de saida
                        cUnidade      := "" // unidade de medida
                        cUnitario     := "" // valor unitario
                        cTotal        := "" // valor total do item
                        cTmp          := "" // variavel para localizar na xxf os campos acima
                        
                        // Produto
                        cTmp := alltrim(_aitens[_nX]:_ItemInternalId:text)
                        If valtype(cTmp) == "C"
                            //cTempXXF := "XXF->(dbSetOrder(1))"
                            //&(cTempXXF)
                            //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SB1")+"SB1"+"B1_COD    "+cTmp))'
                            //If &(cTempXXF)
                            //    cTempXXF := "XXF->XXF_INTVAL"
                            //    cProduto := &(cTempXXF)
                            //EndIf
                            //cProduto := RetiraPipe(cProduto)

                            _CQUERY := " SELECT XXF_INTVAL "
                            _CQUERY += " FROM XXF "
                            _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                            _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SB1")+"' AND "
                            _CQUERY += " XXF_ALIAS = 'SB1' AND "
                            _CQUERY += " XXF_FIELD = 'B1_COD' "
                            _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                            IF SELECT("TRBXXF") > 0
                                TRBXXF->(DBCLOSEAREA())
                            ENDIF
                            _CQUERY := CHANGEQUERY(_CQUERY)
                            TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                            If !TRBXXF->(Eof())
                                //cTempXXF := "XXF->XXF_INTVAL"
                                cProduto := TRBXXF->XXF_INTVAL //&(cTempXXF)
                            Else
                                cProduto := ""
                            EndIF
                            TRBXXF->(DBCLOSEAREA())


                        EndIf

                        // vinculo
                        cTmp := alltrim(_aitens[_nX]:_OrderItemInternalId:text)
                        If valtype(cTmp) == "C"

                            If select("TRBXXF") > 0
                                TRBXXF->(dbCloseArea())
                            ENDIF
                            _CQUERY := " SELECT XXF_INTVAL "
                            _CQUERY += " FROM XXF "
                            _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                            _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SC6")+"' AND "
                            _CQUERY += " XXF_ALIAS = 'SC6' AND "
                            _CQUERY += " XXF_FIELD = 'C6_ITEM' "
                            _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                            _cQuery := changeQuery(_cQuery)
                            TCQUERY _cQuery NEW ALIAS "TRBXXF"
                            If !TRBXXF->(Eof())
                                //cTempXXF := TRBXXF->XXF_INTVAL
                                cVinculo := TRBXXF->XXF_INTVAL
                            EndIf
                            TRBXXF->(dbCloseArea())


                            //cTempXXF := "XXF->(dbSetOrder(1))"
                            //&(cTempXXF)
                            //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SC5")+"SC5"+"C5_NUM    "+cTmp))'
                            //If &(cTempXXF)
                            //    cTempXXF := "XXF->XXF_INTVAL"
                            //    cVinculo := &(cTempXXF)
                            //EndIf
                            //cVinculo := RetiraPipe(cVinculo)
                        EndIf

                        // Unidade de medida
                        cTmp := alltrim(_aitens[_nX]:_UnitOfMeasureInternalId:text)
                        If valtype(cTmp) == "C"
                            //cTempXXF := "XXF->(dbSetOrder(1))"
                            //&(cTempXXF)
                            //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SAH")+"SAH"+"AH_UNIMED "+cTmp))'
                            //If &(cTempXXF)
                            //    cTempXXF := "XXF->XXF_INTVAL"
                            //    cUnidade := &(cTempXXF)
                            //EndIf
                            //cUnidade := RetiraPipe(cUnidade)

                            _CQUERY := " SELECT XXF_INTVAL "
                            _CQUERY += " FROM XXF "
                            _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                            _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SAH")+"' AND "
                            _CQUERY += " XXF_ALIAS = 'SAH' AND "
                            _CQUERY += " XXF_FIELD = 'AH_UNIMED' "
                            _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                            IF SELECT("TRBXXF") > 0
                                TRBXXF->(DBCLOSEAREA())
                            ENDIF
                            _CQUERY := CHANGEQUERY(_CQUERY)
                            TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                            If !TRBXXF->(Eof())
                                //cTempXXF := "XXF->XXF_INTVAL"
                                cUnidade := TRBXXF->XXF_INTVAL //&(cTempXXF)
                            Else
                                cUnidade := ""
                            EndIF
                            TRBXXF->(DBCLOSEAREA())


                        EndIf

                        cUnitario := alltrim(_aitens[_nX]:_UnitPrice:text)   
                        cTotal    := alltrim(_aitens[_nX]:_TotalPrice:text)
                        //cTotal    := alltrim(str( val(cUnitario) * val(_cQuant) ))

                        _cTemp := ""
                        _nConta := 0
                        For _nY := 1 to len(_cItem)
                            If _nConta == 2
                                _cTemp += substr(_cItem,_nY,1)
                            EndIf
                            If substr(_cItem,_nY,1) == "|"
                                _nConta ++
                            EndIf
                        Next 
                        If !empty(_cTemp)
                            aadd(_aItensRet,{_cTemp,cProduto,cVinculo,cUnidade,cUnitario,cTotal,_cItem,_cQuant})
                        EndIf
                    Next
                EndIf
                        
                // Se o _aItens for um objeto � que tem apenas uma linha na SC6
                If valtype(_aItens) == "O"
                    _cItem  := _aItens:_internalid:text
                    _cQuant := _aItens:_quantity:text
                    _cTemp  := ""
                    _nConta := 0

                    // Localizar registros na XXF
                    cProduto      := "" // c�digo do produto
                    cVinculo      := "" // vinculo com a nota fiscal de saida
                    cUnidade      := "" // unidade de medida
                    cTmp          := "" // variavel para localizar na xxf os campos acima
                    
                    // Produto
                    cTmp := alltrim(_aItens:_ItemInternalId:text)
                    If valtype(cTmp) == "C"
                        //cTempXXF := "XXF->(dbSetOrder(1))"
                        //&(cTempXXF)
                        //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SB1")+"SB1"+"B1_COD    "+cTmp))'
                        //If &(cTempXXF)
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cProduto := &(cTempXXF)
                        //EndIf

                        _CQUERY := " SELECT XXF_INTVAL "
                        _CQUERY += " FROM XXF "
                        _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                        _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SB1")+"' AND "
                        _CQUERY += " XXF_ALIAS = 'SB1' AND "
                        _CQUERY += " XXF_FIELD = 'B1_COD' "
                        _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                        IF SELECT("TRBXXF") > 0
                            TRBXXF->(DBCLOSEAREA())
                        ENDIF
                        _CQUERY := CHANGEQUERY(_CQUERY)
                        TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                        If !TRBXXF->(Eof())
                            //cTempXXF := "XXF->XXF_INTVAL"
                            cProduto := TRBXXF->XXF_INTVAL //&(cTempXXF)
                        Else
                            cProduto := ""
                        EndIF
                        TRBXXF->(DBCLOSEAREA())


                    EndIf

                    // vinculo
                    cTmp := alltrim(_aItens:_OrderItemInternalId:text)
                    If valtype(cTmp) == "C"
                        If select("TRBXXF") > 0
                            TRBXXF->(dbCloseArea())
                        ENDIF
                        _CQUERY := " SELECT XXF_INTVAL "
                        _CQUERY += " FROM XXF "
                        _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                        _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SC6")+"' AND "
                        _CQUERY += " XXF_ALIAS = 'SC6' AND "
                        _CQUERY += " XXF_FIELD = 'C6_ITEM' "
                        _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                        _cQuery := changeQuery(_cQuery)
                        TCQUERY _cQuery NEW ALIAS "TRBXXF"
                        If !TRBXXF->(Eof())
                            //cTempXXF := TRBXXF->XXF_INTVAL
                            cVinculo := TRBXXF->XXF_INTVAL
                        Else
                            cVinculo := ""
                        EndIf
                        TRBXXF->(dbCloseArea())
                        
                        //cTempXXF := "XXF->(dbSetOrder(1))"
                        //&(cTempXXF)
                        //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SC5")+"SC5"+"C5_NUM    "+cTmp))'
                        //If &(cTempXXF)
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cVinculo := &(cTempXXF)
                        //EndIf
                    EndIf

                    // Unidade de medida
                    cTmp := alltrim(_aItens:_UnitOfMeasureInternalId:text)
                    If valtype(cTmp) == "C"
                        //cTempXXF := "XXF->(dbSetOrder(1))"
                        //&(cTempXXF)
                        //cTempXXF := 'XXF->(dbSeek("RM             "+RETSQLNAME("SAH")+"SAH"+"AH_UNIMED "+cTmp))'
                        //if &(cTempXXF)
                        //    cTempXXF := "XXF->XXF_INTVAL"
                        //    cUnidade := &(cTempXXF)
                        //EndIf

                        _CQUERY := " SELECT XXF_INTVAL "
                        _CQUERY += " FROM XXF "
                        _CQUERY += " WHERE XXF_EXTVAL = '" + cTmp + "' AND " 
                        _CQUERY += " XXF_TABLE = '"+RETSQLNAME("SAH")+"' AND "
                        _CQUERY += " XXF_ALIAS = 'SAH' AND "
                        _CQUERY += " XXF_FIELD = 'AH_UNIMED' "
                        _CQUERY += " AND R_E_C_D_E_L_ = '0' "
                        IF SELECT("TRBXXF") > 0
                            TRBXXF->(DBCLOSEAREA())
                        ENDIF
                        _CQUERY := CHANGEQUERY(_CQUERY)
                        TCQUERY _CQUERY NEW ALIAS "TRBXXF"

                        If !TRBXXF->(Eof())
                            //cTempXXF := "XXF->XXF_INTVAL"
                            cUnidade := TRBXXF->XXF_INTVAL //&(cTempXXF)
                        Else
                            cUnidade := ""
                        EndIF
                        TRBXXF->(DBCLOSEAREA())

                    EndIf

                    cUnitario := alltrim(_aItens:_UnitPrice:text)
                    cTotal    := alltrim(_aItens:_TotalPrice:text)
                    //cTotal := cUnitario

                    For _nY := 1 to len(_cItem)
                        If _nConta == 2
                            _cTemp += substr(_cItem,_nY,1)
                        EndIf
                        If substr(_cItem,_nY,1) == "|"
                            _nConta ++
                        EndIf
                    Next 
                    If !empty(_cTemp)
                        aadd(_aItensRet,{_cTemp,cProduto,cVinculo,cUnidade,cUnitario,cTotal,_cItem,_cQuant})
                    EndIf
                EndIF

                If len(_aItensRet) > 0
                    lAcha := .F.
                    For nX := 1 to len(aRetProc)
                        If alltrim(aRetProc[nX,2]) == alltrim(cNotaRet)
                            lAcha := .T.
                            exit
                        EndIF
                    Next
                    If !lAcha
                        aadd( aRetProc, { .F., cNotaRet, cSerieRet, ctod( substr(cData,9,2) + "/"+substr(cData,6,2)+"/"+substr(cData,1,4)) })
                        aadd( aIteProc, {cNotaRet, cSerieRet, _aItensRet})
                    EndIF
                EndIf
            Else // veio mais de uma nota no retorno do xml 26/09/2022
            
            EndIF
            
        Endif
    endif

    FreeObj(oWsdl)
    oWsdl := nil
return

/*/{PROTHEUS.DOC} VERNFR
TOTVS RENTAL - m�dulo 94
Rotina para visualizar a nota de retorno que veio do RM
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function VERNFR
Local nJanelaa      := 385 
Local nJanelal      := 900
Local oBut1
Local nOpc          := "0"
Local nLbtaml	    := 438
Local nLbtama	    := 140	
Local oDlgRet
Local oLista1
Local aItens        := {}
Local oOk           := LoadBitMap(GetResources(),'BR_VERDE')
Local oNo           := LoadBitMap(GetResources(),'BR_VERMELHO') 
Local nX
Local nY
Local lRet          := .T.
Local cErro         := ""

    Define MsDialog oDlgRet Title STR0025 FROM 010,005 TO NJANELAA,NJANELAL PIXEL //"Visualiza��o da nota de retorno"

            @ 014,005 say STR0026 size 80,12 of oDlgRet pixel //"Nota de Entrada:"
            @ 010,050 msget aRetProc[oLista:nAt,2] size 100,12 of oDlgRet pixel When .F.
            @ 014,160 say STR0027 size 80,12 of oDlgRet pixel //"S�rie:"
            @ 010,180 msget aRetProc[oLista:nAt,3] size 100,12 of oDlgRet pixel When .F.
            @ 014,290 say STR0028 size 80,12 of oDlgRet pixel //"Data:"
            @ 010,310 msget aRetProc[oLista:nAt,4] size 100,12 of oDlgRet pixel When .F.

            @ 172,375 button oBut1 Prompt STR0029 size 70,12 of oDlgRet pixel action (nOpc := "1", oDlgRet:end()) //"Sair"
        
            //aadd(aItens, {.F., "01","000001","TESTE","1","10,00","10,00"})
            //_cTemp,cProduto,cVinculo,cUnidade,cUnitario,cTotal,cItem,cQuant
            //aadd( aIteProc, {cNotaRet, cSerieRet, _aItensRet})
            For nX := 1 to len(aIteProc)
                If aIteProc[nX,1] == aRetProc[oLista:nAt,2]

                    If !aRetProc[oLista:nAt,1]
                        Loop
                    EndIF


                    For nY := 1 to len(aIteProc[nX,3])
                        SB1->(dbSetOrder(1))
                        cTmp := at("|",aIteProc[nX,3,nY,2])
                        cTmp := at("|",aIteProc[nX,3,nY,2],cTmp+1)
                        cTmp := alltrim(substr(aIteProc[nX,3,nY,2],cTmp+1,len(aIteProc[nX,3,nY,2])))
                        SB1->(dbSeek(xFilial("SB1")+cTmp))

                        SC6->(dbSetOrder(1))
                        nPos1 := at("|",aIteProc[nX,3,nY,3])
                        nPos2 := at("|",aIteProc[nX,3,nY,3],nPos1+1)
                        nPos3 := at("|",aIteProc[nX,3,nY,3],nPos2+1)
                        cFilx := substr(aIteProc[nX,3,nY,3],nPos1+1,len(xFilial("SC5")))
                        cPedx := substr(aIteProc[nX,3,nY,3],nPos2+1,TamSx3("C6_NUM")[1])
                        cItex := substr(aIteProc[nX,3,nY,3],nPos3+1,TamSx3("C6_ITEM")[1])
                        cErro := ""
                        lRet  := .T.
                        If !SC6->(dbSeek(cFilx+cPedx+cItex))
                            lRet := .F.
                            cErro := STR0030 //"Pedido de remessa n�o localizado. "
                        else
                            If SC6->C6_PRODUTO <> cTmp
                                lRet := .F.
                                cErro += STR0031 //"Produto diferente. "
                            EndIf
                            //a quantidade deve ser avaliada com base na fq3
                            //If SC6->C6_QTDVEN <> val(aIteProc[nX,3,nY,8])
                            //    lRet := .F.
                            //    cErro += STR0032 //"Quantidade diferente. "
                            //EndIf
                            If val(aIteProc[nX,3,nY,5]) == 0 //SC6->C6_PRCVEN <> val(aIteProc[nX,3,nY,5])
                                lRet := .F.
                                cErro += STR0055 //"Valor unit�rio zerado. "
                            EndIf
                            If val(aIteProc[nX,3,nY,6]) == 0//SC6->C6_VALOR <> val(aIteProc[nX,3,nY,6])
                                //lRet := .F.
                                //cErro += STR0033 //"Valor total zerado. "
                            EndIf
                        EndIf

                        aadd(aItens,{lRet,;                 // controle do retorno x envio
                                    aIteProc[nX,3,nY,1],;   // Item
                                    cTmp,;                  // C�digo do produto
                                    SB1->B1_DESC,;          // Descri��o do produto
                                    aIteProc[nX,3,nY,8],;   // Quantidade
                                    aIteProc[nX,3,nY,5],;   // Valor unit�rio
                                    aIteProc[nX,3,nY,6],;   // Valor total
                                    cErro })                // Conformidade entre sa�da e retorno
                    Next
                EndIf
            Next
                        
            If len(aItens) > 0
                @ 2,0.7 ListBox oLista1 fields header " ", STR0034, STR0035, STR0036, STR0037, STR0038, STR0039, STR0040  size nLbtaml, nLbtama  //"Item"###"Produto"###"Descri��o"###"Quantidade"###"Valor Unit�rio"###"Valor Total"###"Observa��o"
                oLista1:SETARRAY(aItens)
                oLista1:BLINE := {|| { IF( aItens[oLista1:NAT,1],OOK,ONO),;
                                    aItens[oLista1:NAT,2],;
                                    aItens[oLista1:NAT,3],;
                                    aItens[oLista1:NAT,4],;
                                    aItens[oLista1:NAT,5],;
                                    aItens[oLista1:NAT,6],;
                                    aItens[oLista1:NAT,7],;
                                    aItens[oLista1:NAT,8]}}
            else
                MsgAlert(STR0041,STR0042) //"N�o foram encontrados dados para esta nota."###"Aten��o!"
            EndIf
            
        Activate MsDialog oDlgRet Centered
Return

/*/{PROTHEUS.DOC} GERNFE
TOTVS RENTAL - m�dulo 94
Gera��o da nota fiscal de entrada
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function GERNFE(oDlgRet)
Local lRet      := .T.
Local cErro     := ""
Local nX
Local nY
Local cTmp
Local nPos1
Local nPos2
Local nPos3
Local cFilx
Local cPedx
Local cItex
Local aItens    := {}
Local cEsp
Local cResp
Local cNotax
Local cSeriex
Local aProdRM
Local aProdFQ3
Local lTem
Local lTem1
Local lTem2

    If MsgYesNo(STR0043,STR0044) //"Confirma a gera��o da nota fiscal de entrada?"###"Aten��o!"

        cNotax  := aRetProc[oLista:nAt,2]
        cSeriex := aRetProc[oLista:nAt,3]

        For nX := 1 to len(aIteProc)
            If aIteProc[nX,1] == aRetProc[oLista:nAt,2]

                If !aRetProc[oLista:nAt,1]
                    Loop
                EndIF

                For nY := 1 to len(aIteProc[nX,3])
                    SB1->(dbSetOrder(1))
                    cTmp := at("|",aIteProc[nX,3,nY,2])
                    cTmp := at("|",aIteProc[nX,3,nY,2],cTmp+1)
                    cTmp := alltrim(substr(aIteProc[nX,3,nY,2],cTmp+1,len(aIteProc[nX,3,nY,2])))
                    SB1->(dbSeek(xFilial("SB1")+cTmp))

                    SC6->(dbSetOrder(1))
                    nPos1 := at("|",aIteProc[nX,3,nY,3])
                    nPos2 := at("|",aIteProc[nX,3,nY,3],nPos1+1)
                    nPos3 := at("|",aIteProc[nX,3,nY,3],nPos2+1)
                    cFilx := substr(aIteProc[nX,3,nY,3],nPos1+1,len(xFilial("SC5")))
                    cPedx := substr(aIteProc[nX,3,nY,3],nPos2+1,TamSx3("C6_NUM")[1])
                    cItex := substr(aIteProc[nX,3,nY,3],nPos3+1,TamSx3("C6_ITEM")[1])
                    cErro := ""
                    lRet  := .T.
                    If !SC6->(dbSeek(cFilx+cPedx+cItex))
                        lRet := .F.
                        cErro := STR0045 //"Pedido de remessa n�o localizado. "
                    else
                        If SC6->C6_PRODUTO <> cTmp
                            lRet  := .F.
                            cEsp  := SC6->C6_PRODUTO
                            cResp := cTmp
                            cErro += STR0046+alltrim(cEsp)+STR0047+alltrim(cResp) //"Produto diferente. Esperado: "###" Recebido: "
                        EndIf
                        If SC6->C6_QTDVEN <> val(aIteProc[nX,3,nY,8])
                            lRet := .F.
                            cEsp  := str(SC6->C6_QTDVEN)
                            cResp := aIteProc[nX,3,nY,8]
                            cErro += STR0048+alltrim(cEsp)+STR0047+alltrim(cResp) //"Quantidade diferente. Esperado: "###" Recebido: "
                        EndIf
                        If SC6->C6_PRCVEN <> val(aIteProc[nX,3,nY,5])
                            lRet := .F.
                            cEsp  := str(SC6->C6_PRCVEN)
                            cResp := aIteProc[nX,3,nY,5]
                            cErro += STR0049+alltrim(cEsp)+STR0047+alltrim(cResp) //"Valor unit�rio diferente. Esperado: "###" Recebido: "
                        EndIf
                        If val(aIteProc[nX,3,nY,6]) == 0//SC6->C6_VALOR <> val(aIteProc[nX,3,nY,6])
                            //lRet := .F.
                            //cErro += STR0050 //"Valor total zerado. "
                        EndIf
                    EndIf

                    aadd(aItens,{lRet,;                 // controle do retorno x envio
                                aIteProc[nX,3,nY,1],;   // Item
                                cTmp,;                  // C�digo do produto
                                SB1->B1_DESC,;          // Descri��o do produto
                                aIteProc[nX,3,nY,8],;   // Quantidade
                                aIteProc[nX,3,nY,5],;   // Valor unit�rio
                                aIteProc[nX,3,nY,6],;   // Valor total
                                cErro,;                 // Conformidade entre sa�da e retorno
                                SC6->(Recno()) })       // Recno do SC6
                Next
            EndIf
        Next
        
        // Validacao se houve algum erro
        lRet := .T.

        aProdRM  := {} 
        aProdFQ3 := {}
        // Criar um array com totalizadores de produtos do recebido pelo rm
        For nX := 1 to len(aItens)
            lTem := .F.
            For nY := 1 to len(aProdRM)
                If aProdRM[nY,1] == aItens[nX,3]
                    lTem := .T.
                    aProdRM[nY,2] += val(aItens[nX,5])
                    Exit
                EndIF
            Next
            If !lTem
                aadd(aProdRM,{aItens[nX,3],val(aItens[nX,5])})
            EndIf
        Next

        // Criar um array com totalizadores de produtos do romaneio da fq3
        FQ3->(dbSetOrder(1))
        FQ3->(dbSeek(xFilial("FQ3")+FQ2->FQ2_NUM))
        While !FQ3->(Eof()) .and. FQ3->(FQ3_FILIAL+FQ3_NUM) == xFilial("FQ3")+FQ2->FQ2_NUM
            lTem := .F.
            For nY := 1 to len(aProdFQ3)
                If alltrim(aProdFQ3[nY,1]) == alltrim(FQ3->FQ3_PROD)
                    lTem := .T.
                    aProdFQ3[nY,2] += FQ3->FQ3_QTD
                    Exit
                EndIF
            Next
            If !lTem
                aadd(aProdFQ3,{FQ3->FQ3_PROD,FQ3->FQ3_QTD})
            EndIf
            FQ3->(dbSkip())
        EndDo

        cErro := ""

        // Validar se batem os totalizadores
        For nX := 1 to len(aProdRM)
            lTem1 := .F.
            lTem2 := .F.
            For nY := 1 to len(aProdFQ3)
                If alltrim(aProdRM[nX,1]) == alltrim(aProdFQ3[nY][1]) 
                    lTem1 := .T.
                EndIf
                If alltrim(aProdRM[nX,1]) == alltrim(aProdFQ3[nY][1]) .and. aProdRM[nX,2] == aProdFQ3[nY][2]
                    lTem2 := .T.
                EndIf
            Next
            If !lTem1 .or. !lTem2
                lRet := .F.
                If !lTem1 
                    cErro := STR0056 +alltrim(aProdRM[nX,1]) //"Produto n�o localizado: "
                EndIf
                If !lTem2 
                    cErro := STR0057+alltrim(aProdRM[nX,1])+STR0058 //"Quantidade do produto: "###" n�o confere."
                EndIf
            EndIF
        Next
        For nX := 1 to len(aProdFQ3)
            lTem1 := .F.
            lTem2 := .F.
            For nY := 1 to len(aProdRM)
                If alltrim(aProdFQ3[nX,1]) == alltrim(aProdRM[nY][1])
                    lTem1 := .T.
                EndIf
                If alltrim(aProdFQ3[nX,1]) == alltrim(aProdRM[nY][1]) .and. aProdFQ3[nX,2] == aProdRM[nY][2]
                    lTem2 := .T.
                EndIf
            Next
            If !lTem1 .or. !lTem2
                lRet := .F.
                If !lTem1 
                    cErro := STR0056+alltrim(aProdFQ3[nX,1]) //"Produto n�o localizado: "
                EndIf
                If !lTem2 
                    cErro := STR0057+alltrim(aProdFQ3[nX,1])+STR0058 //"Quantidade do produto: "###" n�o confere."
                EndIf
            EndIF
        Next

        If len(aItens) == 0
            cErro := STR0051 //"Nenhum item v�lido foi localizado para a emiss�o da nota fical de entrada."
            lRet  := .F.
        EndIf
        //For nX := 1 to len(aItens)
        //    if !empty(aItens[nX,8])
        //        lRet := .F.
        //    EndIf
        //Next
        If !empty(cErro) //!lRet
            MsgAlert(cErro,STR0052) //"Processo abortado."
        else
            lRet := A103Devx(aItens, cNotax, cSeriex)
        EndIF
    else
        lRet := .F.
    EndIf
    If lRet
        If alltrim(SF1->F1_DOC) == alltrim(cNotax)
            //If ExistBlock("MT103FIM") 	
            //    ExecBlock("MT103FIM",.T.,.T.,{3,1})
            //EndIF
        EndIF
        oDlgRet:End()
    EndIf
Return lRet

/*/{PROTHEUS.DOC} A103Devx
TOTVS RENTAL - m�dulo 94
Processamento da nota de entrada (geracao)
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function A103Devx(aItens, cNotax, cSeriex)	
Local cItem
Local lRet        := .T.
Local nX

Private aItenspx  := {}
Private aItensAx  := {}
Private aItensx   := {}
Private cTesDv    := SuperGetMV("MV_LOCX025",,"004")
Private cCliex
Private cLojax

Private cTipoNf   := "E" // Frank 25/11/2020 para uso na rotina do mata100b
Private cTEs             // Frank 25/11/2020 para uso na rotina do mata100b

    For nX:=1 to len(aItens)

        SC6->(dbGoto(aItens[nX,9]))
        cCliex := SC6->C6_CLI
        cLojax := SC6->C6_LOJA
        FPA->(dbSetOrder(3))
        If FPA->(dbSeek(xFilial("FPA")+SC6->C6_XAS))

            // Posicionar na FP0 para efeito no ponto de entrada mt103fim.
            FP0->(dbSetOrder(1))
            FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))

            SD2->(dbSetOrder(3))
            If SD2->(dbSeek(SC6->(C6_FILIAL+C6_NOTA+C6_SERIE+C6_CLI+C6_LOJA+C6_PRODUTO+FPA->FPA_ITEREM)))
                cNFORI      := SD2->D2_DOC
                cSERIORI    := SD2->D2_SERIE
                cITEMORI    := SD2->D2_ITEM
                aItensx     := {}
                aAdd( aItensx, { "D1_COD"     , aItens[nX,3]                    , Nil } )
                aAdd( aItensx, { "D1_QUANT"   , Val(aItens[nX,5])               , Nil } )										
                aAdd( aItensx, { "D1_VUNIT"   , Val(aItens[nX,6])               , Nil } )
                aAdd( aItensx, { "D1_TOTAL"   , Val(aItens[nX,7])               , Nil } )
                aAdd( aItensx, { "D1_TES" 	  , cTesDv		                    , Nil } )	
                aAdd( aItensx, { "D1_NFORI"   , SC6->C6_NOTA                    , Nil } )
                aAdd( aItensx, { "D1_SERIORI" , SC6->C6_SERIE                   , Nil } )
                aAdd( aItensx, { "D1_ITEMORI" , FPA->FPA_ITEREM                 , Nil } )
                aAdd( aItensx, { "D1_IDENTB6" , SD2->D2_IDENTB6                 , Nil } )
                nPos := aScan(aItensAx,{|x| x[1] == cNFORI .And. x[2] == cSERIORI .And. x[3] == cITEMORI })
                If nPos == 0
                    aAdd(aItensAx,{cNFORI,cSERIORI,cITEMORI})
                    aAdd(aItenspx,aItensx)
                EndIf 
            Else
                lRet := .F.
                exit
            EndIf
        else
            lRet := .F.
            exit
        EndIf
    Next
    If Len(aItenspx) > 0 .and. lRet
        ProcDv(cNotax, cSeriex)
    Else
        lRet := .F.
	EndIf

Return lRet


/*/{PROTHEUS.DOC} ProcDv
TOTVS RENTAL - m�dulo 94
geracao da nota de retorno
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 01/12/2021
/*/
Static Function ProcDv(cNotax, cSeriex)
Local aArea      := GetArea()
Local aAreaSF2   := SF2->(GetArea())
Local aCab       := {}
Local cTipoNF    := ""
Local lPoder3    := .T.
Local lFlagDev	 := SF2->(FieldPos("F2_FLAGDEV")) > 0  .And. GetNewPar("MV_FLAGDEV",.F.)
Local lRestDev	 := .T.
Local aLinha	 := {} // Frank Z Fuga em 08/09/2020 para funcionamento da fun��o M103FILDV
Local _lMostra	 := .F.
Local cTipo
Local lRet       := .T.

Private _lErroNf := .F. // variavel que sofre alteracao no fonte MT103FIM
Private _nZuc    := 1   // usado no ponto de entrada MT103FIM
Private cRomaX   := FQ2->FQ2_NUM // usado no ponto de entrada MT103FIM


	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+cTesDv))
	cTipo := "D"
	If SF4->F4_PODER3 == "D"
        cTipo := "B"
	EndIF

	aAdd( aCab , {"F1_DOC"      , cNotax                        , Nil} ) 
	aAdd( aCab , {"F1_SERIE"    , cSeriex                       , Nil} ) 	
	aAdd( aCab , {"F1_TIPO"     , cTipo                         , Nil} ) 	
	aAdd( aCab , {"F1_FORNECE"  , cCliex                        , Nil} ) 	
	aAdd( aCab , {"F1_LOJA"     , cLojax                        , Nil} ) 	
	aAdd( aCab , {"F1_EMISSAO"  , dDataBase                     , Nil} ) 	
	aAdd( aCab , {"F1_FORMUL"   , "N"                           , Nil} ) 	
	aAdd( aCab , {"F1_ESPECIE"  , Iif(Empty(CriaVar("F1_ESPECIE",.T.)),;
								 PadR("NF",Len(SF1->F1_ESPECIE)),CriaVar("F1_ESPECIE",.T.)), Nil } )  
	aAdd( aCab , { "F1_FRETE"   , 0                             , Nil} ) 
	aAdd( aCab , { "F1_SEGURO"  , 0                             , Nil} ) 
	aAdd( aCab , { "F1_DESPESA" , 0                             , Nil} ) 
	aAdd( aCab , { "F1_IT_ROMA" , FQ2->FQ2_NUM                  , Nil} ) 
	
	If cFilAnt <> SF2->F2_FILIAL
		cFilAux := cFilAnt  
		nRecSM0 := SM0->(RECNO())
		cFilAnt := cFilAnt 							
		Mata103( aCab, aItenspx , 3 , .T.)
		cFilAnt := cFilAux 
		SM0->(dbGoTo(nRecSM0))
	Else   
		Mata103( aCab, aItenspx , 3 , .T.)
		_lMostra := .T.
	EndIf

	If _lErroNF
		//MsgAlert("A nota de entrada n�o foi gerada.","Aten��o!")
        lRet := .F.
	EndIF

	If !_lErroNf
		RecLock("SF1",.F.)
		SF1->F1_IT_ROMA := FQ2->FQ2_NUM
		SF1->(MsUnLock())

		// Gravar o n�mero da nota de retorno no campo FQ2_NFSER
		// Frank em 06/07/21
		FQ2->(RecLock("FQ2",.F.))
		FQ2->FQ2_NFSER := SF1->F1_DOC +"/"+ SF1->F1_SERIE
		FQ2->(MsUnlock())
		
		If _lMostra
			MsgAlert(STR0053+alltrim(SF1->F1_DOC)+"-"+alltrim(SF1->F1_SERIE),STR0054) //"Nota de entrada gerada: "###"Aten��o!"
		EndIf
		cDoc := SF1->F1_DOC
	EndIf

	// --> Verifica se nao ha mais saldo para devolucao.
	If lFlagDev
		//lRestDev := xM103FILDV(@aLinha,@aItenspx,cDocSF2,cCliex,cLojax,.F.,@cTipoNF,@lPoder3,.F.)	
		//If !lRestDev
		//	RecLock("SF2",.F.)
		//	SF2->F2_FLAGDEV := "1"
		//	MsUnLock()
		//EndIf 
	EndIf 

	MsUnLockAll()
	
    RestArea(aAreaSF2)
    RestArea(aArea)

Return(.T.)



/*/{PROTHEUS.DOC} xM103FilDv
TOTVS RENTAL - m�dulo 94
Esta fun��o tem por finalidade a substitui��o da fun��o do padr�o M103FilDv
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 11/05/2020
/*/
Static Function xM103FilDv(aLinha,aItens,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3,lHelp,nHpP3,lHelpTES,cEspecie)
Local aAreaAnt  := {}
Local aSaldoTerc:= {}
Local aStruSD2  := {}
Local cFilSX5   := xFilial("SX5")
Local cAliasSF4 := ""
Local cAliasSD2 := ""
Local cCfop     := ""
Local cNFORI  	:= ""
Local cSERIORI	:= ""
Local cITEMORI	:= ""
Local cNewDSF2	:= ""
Local cDSF2Aux	:= ""
Local cQuery    := ""
Local cAliasCpl := ""
Local nTpCtlBN  := A410CtEmpBN()
Local nSldDev   := 0
Local nSldDevAux:= 0
Local nDesc     := 0
Local nTotal	:= 0
Local nVlCompl  := 0
Local nPosDiv	:= 0
Local nX		:= 0
Local lMt103FDV := .F. //ExistBlock("MT103FDV")
Local lCompl    := SuperGetMv("MV_RTCOMPL",.F.,"S") == "S"
Local lDevolucao:= .T.
Local lDevCode	:= .F.
Local lTravou	:= .F.
Local lExit		:= .F.

Default lHelp    := .T.
Default lHelpTES := .T.

    If !Empty(cDocSF2)												// Selecao foi feita por "Cliente/Fornecedor"

        cNewDSF2 := StrTran(StrTran(cDocSF2,"('",),"')",)			// Retira par�teses e aspas da string do documento, caso houver

        nPosDiv := At("','",cNewDSF2)								// String ',' identifica que foi selecionada mais de uma nota de saida
        If nPosDiv == 0												// Se foi selecionada apenas uma nota de saida
            DbSelectArea("SF2")
            DbSetOrder(1)
            If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
                lTravou := SoftLock("SF2")							// Tenta reservar o registro para prosseguir com o processo
            Else
                dbGoTop()
            EndIf
        Else														// Se foi selecionada mais de uma nota de saida
            cDSF2Aux := cNewDSF2
            For nX := 1 to Len(cDSF2Aux)
                nPosDiv := At("','",cDSF2Aux)
                If nPosDiv > 0
                    cNewDSF2 := SubStr(cDSF2Aux,1,(nPosDiv-1))		// Extrai a primeira nota/serie da string
                    cDSF2Aux := SubStr(cDSF2Aux,(nPosDiv+3),Len(cDSF2Aux)) // Grava nova string sem a primeira nota/serie
                Else
                    cNewDSF2 := cDSF2Aux
                    lExit := .T.
                EndIf
                If !Empty(cNewDSF2)
                    DbSelectArea("SF2")
                    DbSetOrder(1)
                    If MsSeek(xFilial("SF2")+cNewDSF2+cCliente+cLoja)
                        lTravou := SoftLock("SF2")					// Tenta reservar todos os registros para prosseguir com o processo
                    Else
                        dbGoTop()
                    EndIf
                EndIf
                If lExit
                    Exit
                EndIf
            Next nX
        EndIf
    Else
        lTravou := SoftLock("SF2")
    EndIf

    If lTravou

        If !Empty(SF2->F2_ESPECIE)
            cEspecie := SF2->F2_ESPECIE
        EndIf

        //�����������������������������������������������������������������Ŀ
        //� Montagem dos itens da Nota Fiscal de Devolucao/Retorno          �
        //�������������������������������������������������������������������
        DbSelectArea("SD2")
        DbSetOrder(3)

        cAliasSD2 := "Oms320Dev"
        cAliasSF4 := "Oms320Dev"
        aStruSD2  := SD2->(dbStruct())
        cQuery    := "SELECT SF4.F4_CODIGO, SF4.F4_CF, SF4.F4_PODER3, SF4.F4_QTDZERO, SF4.F4_ATUATF, SF4.F4_ESTOQUE, SD2.*, "
        cQuery    += " SD2.R_E_C_N_O_ SD2RECNO "
        cQuery    += " FROM "+RetSqlName("SD2")+" SD2,"
        cQuery    += RetSqlName("SF4")+" SF4 "
        cQuery    += " WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
        If !lCliente
            cQuery    += "SD2.D2_DOC   = '"+SF2->F2_DOC+"' AND "
            cQuery    += "SD2.D2_SERIE = '"+SF2->F2_SERIE+"' AND "
        Else
            If !Empty(cDocSF2)
                If UPPER(Alltrim(TCGetDb()))=="POSTGRES"
                    cQuery += " Concat(D2_DOC,D2_SERIE) IN "+cDocSF2+" AND "
                Else
                    cQuery += " D2_DOC||D2_SERIE IN "+cDocSF2+" AND "
                EndIf
            EndIf
        EndIf
        cQuery    += " SD2.D2_CLIENTE   = '"+cCliente+"' AND "
        cQuery    += " SD2.D2_LOJA      = '"+cLoja+"' AND "
        cQuery    += " ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
        cQuery    += " (SD2.D2_VALDEV  = 0) OR "
        cQuery    += " (SF4.F4_QTDZERO = '1' AND SD2.D2_VALDEV < SD2.D2_TOTAL)) AND "
        cQuery    += " SD2.D_E_L_E_T_  = ' ' AND "
        cQuery    += " SF4.F4_FILIAL   = '"+xFilial("SF4")+"' AND "
        cQuery    += " SF4.F4_CODIGO   = (SELECT F4_TESDV FROM "+RetSqlName("SF4")+" WHERE "
        cQuery    += " F4_FILIAL	   = '"+xFilial("SF4")+"' AND "
        cQuery    += " F4_CODIGO	   = SD2.D2_TES AND "
        cQuery    += " D_E_L_E_T_	   = ' ' ) AND "
        cQuery    += " SF4.D_E_L_E_T_  = ' ' "
        cQuery    += " ORDER BY "+SqlOrder(SD2->(IndexKey()))

        cQuery    := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

        For nX := 1 To Len(aStruSD2)
            If aStruSD2[nX][2]<>"C"
                TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
            EndIf
        Next nX

        If Eof()
            If lHelp
                Help(" ",1,"DSNOTESDT")
                nHpP3 := 1
            EndIf
            lDevolucao := .F.
            lHelpTES   := .F.
        EndIf

        While !Eof() .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
                (cAliasSD2)->D2_CLIENTE 		   == cCliente 		  .And.;
                (cAliasSD2)->D2_LOJA			   == cLoja 		  .And.;
                If(!lCliente,(cAliasSD2)->D2_DOC  == SF2->F2_DOC     .And.;
                (cAliasSD2)->D2_SERIE			   == SF2->F2_SERIE,.T.)

            If ((cAliasSD2)->D2_QTDEDEV < (cAliasSD2)->D2_QUANT) .Or. ((cAliasSD2)->D2_VALDEV == 0) .Or. ((cAliasSD2)->F4_QTDZERO == "1" .And. (cAliasSD2)->D2_VALDEV < (cAliasSD2)->D2_TOTAL)

                If (cAliasSD2)->F4_PODER3<>"D"
                    lPoder3 := .F.
                EndIf
                If lPoder3 .And. !cTipo$"B|N"
                    cTipo := IIF(cTipoNF=="B","N","B")
                ElseIf !cTipo$"B|N"
                    cTipo := "D"
                EndIf
                

                If !lMt103FDV //.Or. ExecBlock("MT103FDV",.F.,.F.,{cAliasSD2})
                    //�����������������������������������������������������������������Ŀ
                    //� Destroi o Array, o mesmo � carregado novamente pela CalcTerc    �
                    //�������������������������������������������������������������������
                    If Len(aSaldoTerc)>0
                        aSize(aSaldoTerc,0)
                    EndIf

                    //�����������������������������������������������������������������Ŀ
                    //� Calcula o Saldo a devolver                                      �
                    //�������������������������������������������������������������������
                    cTipoNF := (cAliasSD2)->D2_TIPO

                    Do Case
                        Case (cAliasSF4)->F4_PODER3=="D"
                            aSaldoTerc := CalcTerc((cAliasSD2)->D2_COD,(cAliasSD2)->D2_CLIENTE,(cAliasSD2)->D2_LOJA,(cAliasSD2)->D2_IDENTB6,(cAliasSD2)->D2_TES,cTipoNF)
                            nSldDev :=iif(Len(aSaldoTerc)>0,aSaldoTerc[1],0)
                        Case cTipoNF == "N"
                            nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
                        Case cTipoNF == "B" .And.(cAliasSF4)->F4_PODER3 =="N" .And. A103DevPdr((cAliasSF4)->F4_CODIGO)
                            nSldDev := (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
                            lPoder3 := .T.
                        OtherWise
                            nSldDev := 0
                    EndCase

                    //�����������������������������������������������������������������Ŀ
                    //� Efetua a montagem da Linha                                      �
                    //�������������������������������������������������������������������

                    If nSldDev > 0 .Or. (cTipoNF$"CIP" .And. (cAliasSD2)->D2_VALDEV == 0) .Or.;
                    ( (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_VALDEV == 0 .And. (cAliasSD2)->D2_TOTAL > 0 ) .Or.;
                        ( (cAliasSD2)->F4_QTDZERO == "1" .And. (cAliasSD2)->D2_VALDEV < (cAliasSD2)->D2_TOTAL )

                        lDevCode := .T.

                        //�����������������������������������������������������������������Ŀ
                        //� Verifica se deve considerar o preco das notas de complemento    �
                        //�������������������������������������������������������������������
                        If lCompl
                            //�����������������������������������������������������������������Ŀ
                            //� Verifica se existe nota de complemento de preco                 �
                            //�������������������������������������������������������������������
                            aAreaAnt  := GetArea()
                            cAliasCpl := GetNextAlias()
                            cQuery    := "SELECT SUM(SD2.D2_PRCVEN) AS D2_PRCVEN "
                            cQuery    += "  FROM "+RetSqlName("SD2")+" SD2 "
                            cQuery    += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
                            cQuery    += "   AND SD2.D2_TIPO    = 'C' "
                            cQuery    += "   AND SD2.D2_NFORI   = '"+SF2->F2_DOC+"'"
                            cQuery    += "   AND SD2.D2_SERIORI = '"+SF2->F2_SERIE+"'"
                            cQuery    += "   AND SD2.D2_ITEMORI = '"+(cAliasSD2)->D2_ITEM +"'"
                            cQuery    += "   AND ((SD2.D2_QTDEDEV < SD2.D2_QUANT) OR "
                            cQuery    += "       (SD2.D2_VALDEV = 0))"
                            cQuery    += "   AND SD2.D2_TES         = '"+(cAliasSD2)->D2_TES+"'"
                            cQuery    += "   AND SD2.D_E_L_E_T_     = ' ' "

                            cQuery    := ChangeQuery(cQuery)
                            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCpl,.T.,.T.)

                            TcSetField(cAliasCpl,"D2_PRCVEN","N",TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])

                            If !(cAliasCpl)->(Eof())
                                nVlCompl := (cAliasCpl)->D2_PRCVEN
                            Else
                                nVlCompl := 0
                            EndIf

                            (cAliasCpl)->(dbCloseArea())
                            RestArea(aAreaAnt)
                        EndIf

                        aLinha := {}
                        nDesc  := 0
                        AAdd( aLinha, { "D1_COD"    , (cAliasSD2)->D2_COD    , Nil } )
                        AAdd( aLinha, { "D1_QUANT"  , nSldDev, Nil } )
                        If (cAliasSD2)->D2_QUANT==nSldDev
                            If Len(aSaldoTerc)=0   // Nf sem Controle Poder Terceiros
                                If ((cAliasSD2)->F4_QTDZERO == "1" .And. (cAliasSD2)->D2_VALDEV < (cAliasSD2)->D2_TOTAL)
                                    AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_PRCVEN - (cAliasSD2)->D2_VALDEV), Nil })
                                ElseIf (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
                                    AAdd( aLinha, { "D1_VUNIT"  , (cAliasSD2)->D2_PRCVEN, Nil })
                                Else
                                    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
                                    AAdd( aLinha, { "D1_VUNIT"  , ((cAliasSD2)->D2_TOTAL+nDesc)/(cAliasSD2)->D2_QUANT, Nil })
                                EndIf
                            Else                   // Nf com Controle Poder Terceiros
                                If (cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR == 0
                                    AAdd( aLinha, { "D1_VUNIT"  , NoRound((aSaldoTerc[5]-aSaldoTerc[4])/nSldDev,TamSX3("D2_PRCVEN")[2]), Nil })
                                Else
                                    nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
                                    nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
                                    AAdd( aLinha, { "D1_VUNIT"  , NoRound(((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev,TamSX3("D2_PRCVEN")[2]), Nil })
                                EndIf
                            EndIf
                            nTotal:= A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL")
                            If nTotal == 0 .And. (cAliasSD2)->D2_QUANT == 0 .And. (cAliasSD2)->D2_PRCVEN == (cAliasSD2)->D2_TOTAL
                                If (cAliasSD2)->F4_QTDZERO == "1"
                                    nTotal := (cAliasSD2)->D2_TOTAL - (cAliasSD2)->D2_VALDEV
                                Else
                                    nTotal := (cAliasSD2)->D2_TOTAL
                                EndIf
                            EndIf
                            AAdd( aLinha, { "D1_TOTAL"  , nTotal,Nil } )
                            AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )
                            AAdd( aLinha, { "D1_VALFRE", (cAliasSD2)->D2_VALFRE, Nil } )
                            AAdd( aLinha, { "D1_SEGURO", (cAliasSD2)->D2_SEGURO, Nil } )
                            AAdd( aLinha, { "D1_DESPESA", (cAliasSD2)->D2_DESPESA, Nil } )
                        Else
                            nSldDevAux:= (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
                            If Len(aSaldoTerc)=0	// Nf sem Controle Poder Terceiros
                                nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
                                nDesc:=iif(nDesc>0,(nDesc/(cAliasSD2)->D2_QUANT)*IIf(nSldDevAux==0,1,nSldDevAux),0)
                                AAdd( aLinha, { "D1_VUNIT"  ,((((cAliasSD2)->D2_TOTAL+(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR))-(cAliasSD2)->D2_VALDEV)/IIf(nSldDevAux==0,1,nSldDevAux), Nil })
                            Else  					// Nf com Controle Poder Terceiros
                                nDesc:=(cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR
                                nDesc:=iif(nDesc>0,(nDesc/aSaldoTerc[6])*nSldDev,0)
                                AAdd( aLinha, { "D1_VUNIT"  , NoRound(((aSaldoTerc[5]+nDesc)-aSaldoTerc[4])/nSldDev,TamSX3("D2_PRCVEN")[2]), Nil })
                            EndIf

                            AAdd( aLinha, { "D1_TOTAL"  , A410Arred(aLinha[2][2]*aLinha[3][2],"D1_TOTAL"),Nil } )
                            AAdd( aLinha, { "D1_VALDESC", nDesc , Nil } )
                            AAdd( aLinha, { "D1_VALFRE" , A410Arred(((cAliasSD2)->D2_VALFRE/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_VALFRE"),Nil } )
                            AAdd( aLinha, { "D1_SEGURO" , A410Arred(((cAliasSD2)->D2_SEGURO/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_SEGURO"),Nil } )
                            AAdd( aLinha, { "D1_DESPESA" , A410Arred(((cAliasSD2)->D2_DESPESA/(cAliasSD2)->D2_QUANT)*nSldDev,"D1_DESPESA"),Nil } )
                        EndIf
                        AAdd( aLinha, { "D1_IPI"    , (cAliasSD2)->D2_IPI    , Nil } )
                        AAdd( aLinha, { "D1_LOCAL"  , (cAliasSD2)->D2_LOCAL  , Nil } )
                        AAdd( aLinha, { "D1_TES" 	, (cAliasSF4)->F4_CODIGO , Nil } )
                        
                        If ("000"$AllTrim((cAliasSF4)->F4_CF) .Or. "999"$AllTrim((cAliasSF4)->F4_CF))
                            cCfop := AllTrim((cAliasSF4)->F4_CF)
                        Else
                            cCfop := SubStr("123",At(SubStr((cAliasSD2)->D2_CF,1,1),"567"),1)+SubStr((cAliasSD2)->D2_CF,2)
                            //��������������������������������������������������������������������������������Ŀ
                            //� Verifica se existe CFOP equivalente considerando a CFOP do documento de saida  �
                            //����������������������������������������������������������������������������������
                            SX5->( dbSetOrder(1) )
                            If !SX5->(MsSeek( cFilSX5 + "13" + cCfop ))
                                cCfop := AllTrim((cAliasSF4)->F4_CF)
                            EndIf
                        EndIf
                        AAdd( aLinha, { "D1_CF"		, cCfop, Nil } )
                        AAdd( aLinha, { "D1_UM"     , (cAliasSD2)->D2_UM , Nil } )
                        If (nTpCtlBN != 0)
                            AAdd( aLinha, { "D1_OP" 	, A103OPBen(cAliasSD2, nTpCtlBN) , Nil } )
                        EndIf
                        If Rastro((cAliasSD2)->D2_COD) .And. (cAliasSF4)->F4_ESTOQUE == "S"
                            AAdd( aLinha, { "D1_LOTECTL", (cAliasSD2)->D2_LOTECTL, ".T." } )
                            If (cAliasSD2)->D2_ORIGLAN == "LO"
                                If Rastro((cAliasSD2)->D2_COD,"L") .AND. !Empty((cAliasSD2)->D2_NUMLOTE)
                                    AAdd( aLinha, { "D1_NUMLOTE", Nil , ".T." } )
                                Else
                                    AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )
                                EndIf
                            Else
                                AAdd( aLinha, { "D1_NUMLOTE", (cAliasSD2)->D2_NUMLOTE, ".T." } )
                            EndIf

                            AAdd( aLinha, { "D1_DTVALID", (cAliasSD2)->D2_DTVALID, ".T." } )
                            AAdd( aLinha, { "D1_POTENCI", (cAliasSD2)->D2_POTENCI, ".T." } )
                            SB8->(dbSetOrder(3)) // FILIAL+PRODUTO+LOCAL+LOTECTL+NUMLOTE+B8_DTVALID
                            If 	SB8->(MsSeek(xFilial("SB8")+(cAliasSD2)->D2_COD + (cAliasSD2)->D2_LOCAL + (cAliasSD2)->D2_LOTECTL + (cAliasSD2)->D2_NUMLOTE))
                                    AAdd( aLinha, { "D1_DFABRIC", SB8->B8_DFABRIC, ".T." } )
                            Endif
                        EndIf
                        cNFORI  := (cAliasSD2)->D2_DOC
                        cSERIORI:= (cAliasSD2)->D2_SERIE
                        cITEMORI:= (cAliasSD2)->D2_ITEM
                        If cTipo == "D"
                            SF4->(dbSetOrder(1))
                            If SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) .And. SF4->F4_PODER3$"D|R"
                                If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "N"
                                    cNFORI  := ""
                                    cSERIORI:= ""
                                    cITEMORI:= ""
                                    Help(" ",1,"A100NOTES")
                                EndIf
                                If SF4->(MsSeek(xFilial("SF4")+(cAliasSF4)->F4_CODIGO)) .And. SF4->F4_PODER3 == "R"
                                    cNFORI  := ""
                                    cSERIORI:= ""
                                    cITEMORI:= ""
                                    Help(" ",1,"A103TESNFD")
                                EndIf
                            EndIf
                        EndIf
                        AAdd( aLinha, { "D1_NFORI"  , cNFORI   			      , Nil } )
                        AAdd( aLinha, { "D1_SERIORI", cSERIORI  		      , Nil } )
                        AAdd( aLinha, { "D1_ITEMORI", cITEMORI   			  , Nil } )
                        AAdd( aLinha, { "D1_ICMSRET", ((cAliasSD2)->D2_ICMSRET / (cAliasSD2)->D2_QUANT )*nSldDev , Nil })
                        If (cAliasSF4)->F4_PODER3=="D"
                            AAdd( aLinha, { "D1_IDENTB6", (cAliasSD2)->D2_NUMSEQ, Nil } )
                        Endif

                        //Obt�m o valor do Acrescimo Financeiro na Nota de Origem e faz o rateio //
                        If (cAliasSD2)->D2_VALACRS >0
                            AAdd( aLinha, { "D1_VALACRS", ((cAliasSD2)->D2_VALACRS / (cAliasSD2)->D2_QUANT )*nSldDev , Nil })
                        Endif

                        //If ExistBlock("MT103LDV")
                        //	aLinha := ExecBlock("MT103LDV",.F.,.F.,{aLinha,cAliasSD2})
                        //EndIf

                        If !(Empty((cAliasSD2)->D2_CCUSTO ))
                            AAdd( aLinha, { "D1_CC"  , (cAliasSD2)->D2_CCUSTO  , Nil } )
                        EndIf

                        AAdd( aLinha, { "D1RECNO", (cAliasSD2)->SD2RECNO, Nil } )

                        AAdd( aItens, aLinha)
                    EndIf
                Else
                    lHelpTes := .F.
                EndIf
            Else
                nHpP3 := 1
            Endif
            DbSelectArea(cAliasSD2)
            dbSkip()
        EndDo

        (cAliasSD2)->(DbCloseArea())

        // Verifica se nenhum item foi processado
        If !lDevCode
            lDevolucao := .F.
        EndIf
        DbSelectArea("SD2")

    EndIf

Return lDevolucao

/*/{PROTHEUS.DOC} IntegDef
TOTVS RENTAL - m�dulo 94
Fun��o padr�o para chamada da integra��o via Mensagem �nica
@TYPE FUNCTION
@AUTHOR Jose Eulalio
@SINCE 23/06/2022
/*/
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon ) 
Local aRet 	  := {}
Default lJSon := .F.

aRet := LOCI076( cXml, nTypeTrans, cTypeMessage, cVersion )

Return aRet


// Rotina para encontrar o valor do xml corretamente na nota de retorno
// Frank Z Fuga em 06/10/22
/*
Static Function RetiraPipe(_cItem)
Local _nConta   := 0
Local _cTemp    := ""
Local _nY
_nConta := 0
For _nY := 1 to len(_cItem)
    If _nConta == 2
        _cTemp += substr(_cItem,_nY,1)
    EndIf
    If substr(_cItem,_nY,1) == "|"
        _nConta ++
    EndIf
Next
Return _cTemp*/
