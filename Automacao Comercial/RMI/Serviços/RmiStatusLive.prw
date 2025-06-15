#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMISTATUSLIVE.CH"

Static oJson     := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMISTATUS
Serviço que busca informações nos Assinantes

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMISTATUS(cEmpAmb, cFilAmb)

	Local lManual   := (cEmpAmb == Nil .Or. cFilAmb == Nil)
	Local lContinua := .T.
	Local cUser     := '000000'
    
    Default cEmpAmb := ""
	Default cFilAmb := ""

	If !lManual
		lContinua := .F.

		If !Empty(cEmpAmb) .And. !Empty(cFilAmb)
			lContinua := .T.

			RpcSetType(3) // Para nao consumir licenças na Threads
            RpcSetEnv(cEmpAmb, cFilAmb, , ,'LOJ', "RMISTATUS")
            LjGrvLog(" RMISTATUSLIVE ", "Iniciou ambiente: ", {cEmpAmb,cFilAmb,cModulo})  
			__CUSERID := cUser
		Else
            LjGrvLog(" RMISTATUS ",I18N(STR0001, {"RMISTATUS"}) ) //"Parâmetros incorretos no serviço."
		EndIf	
	EndIf
	
	If lContinua
	
		//Trava a execução para evitar que mais de uma sessão faça a execução.
		If !LockByName("RMISTATUS", .T., .T.)
            LjGrvLog(" RMISTATUSLIVE ", I18n(STR0002, {"RMISTATUS"}))    //"Serviço #1 já esta sendo utilizado por outra instância."
			Return Nil
		EndIf

        LjGrvLog(" RMISTATUSLIVE ", "Antes da Chamada da Função RMISTAEXE")
        Conout(" RMISTATUSLIVE - Antes da Chamada da Funcao RMISTAEXE ")    

        StartJob("RMISTAEXE", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt)

        Sleep(5000)
            
        //Libera a execução do login
        UnLockByName("RMISTATUS", .T., .T.)
	EndIf
    
    //Chama a funcao para o reprocessamento
    If lContinua .AND. ExistFunc("RmiReprocessa")
        RmiReprocessa("CHEF")
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMISTAEXE
Executa a busca

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMISTAEXE(cEmpEnv, cFilEnv, cProcesso)

Local aTicket   := ""
Local cSelect   := ""
Local cTabela   := ""
Local cSemaforo := ""

Default cEmpEnv := ""
Default cFilEnv := ""
Default cProcesso := "" 

cSemaforo := "RMISTAEXE" +"_"+ cEmpEnv +"_"+ "LIVE_STATUS" +"_"+ cProcesso

// -- Executa conciliador
If Alltrim(UPPER(cProcesso)) == "CONFERENCIA"
    StartJob("totvs.protheus.retail.rmi.servicos.SHPConciliador.SHPConciliador", GetEnvServer(), .F./*lEspera*/, cEmpEnv, cFilEnv)
EndIf 
// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
RpcSetType(3) // Para nao consumir licenças na Threads
RpcSetEnv(cEmpEnv, cFilEnv, , ,"LOJ" , "RmiStaExe")

nModulo := 12 //RpcSetEnv incia o modulo 5 por padrão, para validar AmIIn(12) foi preciso mudar nModulo 
If !AmIIn(12)
    LjGrvLog(" RMISTATUSLIVE ", "Não foi encontrado Licença para o Varejo-SIGALOJA: ")    
    ConOut("RMISTATUSLIVE - Não foi encontrado Licença para o Varejo-SIGALOJA:" )
    Return(.F.)
EndIf  

If !LockByName(cSemaforo, .T., .T.)
    LjGrvLog(" RMISTATUSLIVE ", I18n(STR0002, {"RMISTAEXE"}))   //"Serviço #1 já esta sendo utilizado por outra instância."
    Return Nil
EndIf

LjGrvLog(" RMISTATUSLIVE ", "Inicio da Função RMIStaExe, ante da Query") 
Conout(" RMISTATUSLIVE - Antes da Query da Funcao RMISTAEXE ")  

DbSelectArea("MHR")
MHR->(DbSetOrder(1))

cTabela := GetNextAlias()
cSelect := " SELECT TOP(50) * "
cSelect += " FROM " + RetSqlName("MHR") + " MHR Where MHR_STATUS = '6' "
cSelect += Iif(!Empty(cProcesso), "AND MHR_CPROCE = '" + cProcesso + "'", "")
cSelect += " AND MHR.D_E_L_E_T_ = ' ' AND MHR_CASSIN = 'LIVE' "
cSelect += " ORDER BY MHR_DATPRO,MHR_HORPRO "
DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

LjGrvLog(" RMISTATUSLIVE ", "Apos a Execução da Query, Query em execução:", cSelect) 
Conout(" RMISTATUSLIVE - Apos Query da Funcao RMISTAEXE ")  

While !(cTabela)->( Eof() )
    //Posiciona no Registro MHR para pegar campo Memo MHR_ENVIO
    MHR->(DbGoTo((cTabela)->R_E_C_N_O_))
    //Retorna o Array com 3 posiçoes Ticket/Sistema/Token
    aTicket := GetNumTicket(MHR->MHR_ENVIO)
    

    LjGrvLog(" RMISTATUSLIVE ", "Antes da chamada da Funcao SetStatus") 
    Conout(" RMISTATUSLIVE - Antes da chamada da Funcao SetStatus ")  
    //Busca o Status no Live e Atualiza o a tabela MHR e caso encontre erro MHL.
    SetStatus(aTicket)
    
    (cTabela)->( DbSkip() )
EndDo

(cTabela)->( DbCloseArea() )

MHR->(DbCloseArea())

UnLockByName(cSemaforo, .T., .T.)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatus
Executa a busca

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNumTicket(cXmlEnvio)
Local aRet          := {}
Local cToken        := ""
Local cSisSat       := "" 
Local cURL          := ""  
Local oEnviaObj     := Nil
Default cXmlEnvio   := ""

DbSelectArea("MHP")
MHP->(DbSetOrder(1))

DbSelectArea("MHO")
MHO->(DbSetOrder(1))

//MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
cToken := Alltrim(Posicione("MHO", 1, xFilial("MHO") + PADR("LIVE",TAMSX3("MHO_COD")[1]),"MHO_TOKEN"))
oJson := JsonObject():New()
oJson:FromJson(MHO->MHO_CONFIG) 
cURL  := oJson["url_token"]  
//Quando é Utilizado subsistemasatelite no Assinante. Utiliza o SubSatelite para confirmar o token
If MHP->(DbSeek(xFilial("MHP")+PadR("LIVE", TamSx3("MHP_CPROCE")[1])+ PadR(MHR->MHR_CPROCE, TamSx3("MHP_CPROCE")[1]) + '1'))

    oJson:FromJson(MHP->MHP_CONFIG)

    //caso o token esteja em branco é gerado outro para execução 
    If Empty(cToken) .or. (!Empty(oJson["subsistemasatelite"]) .and. Empty(Alltrim(oJson["subtoken"])))
        LjGrvLog("RMISTATUSLIVE", "O token esta em branco, será gerado outro")
        oEnviaObj := RmiEnvLiveObj():New(MHP->MHP_CPROCE)
        If oEnviaObj:oConfProce == Nil
            oEnviaObj:oConfProce := JsonObject():New()
        EndIf
        oEnviaObj:oConfProce:FromJson( AllTrim(MHP->MHP_CONFIG) )
        oEnviaObj:PreExecucao()
        cToken := oEnviaObj:cToken
        LjGrvLog("RMISTATUSLIVE", "O token gerado na rotina GetNumTicket. Token: ", cToken)
    EndIf

    If Empty(oJson["subsistemasatelite"])//Se nao existir subsistemasatelite utilizar o Satelite principal.
        oJson:FromJson(MHO->MHO_CONFIG)
        cSisSat := oJson["sistemasatelite"]
        cToken  := Alltrim(MHO->MHO_TOKEN)
    Else
        oJson:FromJson(MHP->MHP_CONFIG)
        cSisSat := oJson["subsistemasatelite"]
        cToken  := Iif(Empty(Alltrim(oJson["subtoken"])), oJson["subtoken"] := cToken, Alltrim(oJson["subtoken"]))
    EndIf
EndIf

Aadd(aRet,{RmiXGetTag(cXmlEnvio, "<Numero>", .F.), cSisSat,cToken,cURL})

MHP->(DbCloseArea())
MHO->(DbCloseArea())

LjGrvLog("RMISTATUSLIVE", "Retorna o Numero do Ticket e o Sistema Satelite" ,aRet)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatus
Executa a busca

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetStatus(aTicket)
Local cError    := ""
Local cBody     := ""
Local cSitua    := ""
Local cDetalhe  := ""
Local cRetorno  := ""
Local oSoapGet  := Nil

    oSoapGet := RMIConWsdl(aTicket[1][4], @cError)

    If !Empty(cError)
        lSucesso := .F.
        cRetorno := STR0003 + " [" + cError + "] "    //"Problema ao efetuar o ParseUrl verificar as configurações no cadastro de Assinantes, retorno: "
        
        LjGrvLog("RMISTATUSLIVE",cRetorno)
        
    Else
        
        LjGrvLog("RMISTATUSLIVE","PreExecucao - Parse Executado com sucesso ")
    
        If !oSoapGet:SetOperation("ConsultarStatusTicketLC_Integracao")   //"ObterChaveAcessoLC_Integracao"
            cError := I18n("Problema o Consultar end-point Live", {ProcName(), "SetOperation", "ConsultarStatusTicketLC_Integracao"} )     //"[#1] Problema ao efetuar o #2: #3"
            
            LjGrvLog("RMISTATUSLIVE",cError)
            Conout(" RMISTATUSLIVE - Erro ao setar a operacao " + cError) 
        Else
            cBody := "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>"
            cBody += "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:liv='http://LiveConnector/' xmlns:ren='http://schemas.datacontract.org/2004/07/Rentech.Framework.Data' xmlns:ren1='http://schemas.datacontract.org/2004/07/Rentech.PracticoLive.Connector.Objects'>"
            cBody +=   "<soapenv:Header/>"
            cBody +=   "<soapenv:Body>"
            cBody +=       "<liv:ConsultarStatusTicketLC_Integracao>"
            cBody +=         "<liv:parametro>"
            cBody +=            "<ren1:Chave>" + aTicket[1][3] + "</ren1:Chave>"
            cBody +=            "<ren1:CodigoSistemaSatelite>" + aTicket[1][2] + "</ren1:CodigoSistemaSatelite>"
            cBody +=            "<ren1:NumeroTicket>" + aTicket[1][1]+ "</ren1:NumeroTicket>"
            cBody +=         "</liv:parametro>"
            cBody +=       "</liv:ConsultarStatusTicketLC_Integracao>"
            cBody +=   "</soapenv:Body>"
            cBody += "</soapenv:Envelope>"        
            //Envia a mensagem a ser processada
            
            LjGrvLog("RMISTATUSLIVE","SetStatus - Body -> ",cBody)
            
            If oSoapGet:SendSoapMsg(cBody)
                
                LjGrvLog("RMISTATUSLIVE","SetStatus - Body com sucesso")
                cRetorno := DeCodeUtf8( oSoapGet:GetSoapResponse() )
            
                //Pesquisa a tag com o retorno do token
                cDetalhe := RmiXGetTag(cRetorno, "<a:DetalheSituacao>", .F.)
                cSitua   := RmiXGetTag(cRetorno, "<a:SituacaoProcessamento>", .F.)
                cSitua   := AllTrim( Upper(cSitua) )
                
                LjGrvLog("RMISTATUSLIVE","Retorno de RmiXGetTag", cSitua +" -> "+cDetalhe)

                If "PROCESSADO" $ cSitua
                    Grava(.T.,cDetalhe,"2")
                ElseIf "AGUARDANDO" $ cSitua .Or. "EMPROCESSAMENTO" $ cSitua
                    Grava(.T.,cSitua,"6")
                Else
                    Grava(.F.,cDetalhe,"3")
                EndIf
            Else
                lSucesso := .F.
                cRetorno := STR0005+oSoapGet:cError  //"" Problema ao efetuar SendSoapMsg "
                LjGrvLog("RMISTATUSLIVE",cRetorno)
                //caso a chave de acesso invalida limpa o campo pra gerar novamente.
                If UPPER("Chave de Acesso Inv") $ UPPER(cRetorno)

                    DbSelectArea("MHO")
                    MHO->(DbSetOrder(1))
                    If MHO->( DbSeek( xFilial("MHO") + PADR("LIVE",TAMSX3("MHO_COD")[1]) ) )  .and. Empty(oJson["subsistemasatelite"])
                        RecLock("MHO", .F.)
                            MHO->MHO_TOKEN := ""
                        MHO->( MsUnLock() )
                        MHO->(DbCommit())
                    EndIf
                    MHO->(DbCloseArea())

                    //Como a chave de acesso do subtoken já esta vencida limpo a tag no Json
                    If !Empty(oJson["subsistemasatelite"])
                        oJson["subtoken"] := ""
                    EndIF

                    LjGrvLog("RMISTATUSLIVE","Limpando campo MHO_TOKEN e a tag SubToken no Json no retorno Chave de Acesso Invalida ")
                EndIf
                //Chamei a gravação para atualizar a tentativa
                Grava(.T.,cRetorno,"6")
            EndIf

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição 

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Grava(lSucesso,cDetalhe,cStatus)

    Default cStatus  := IIF(lSucesso,"2","3") //1=A processar, 2=Processado, 3=Erro, 6=Aguardando Confirmação
    Default cDetalhe := "Processado com Sucesso"
    
    
    LjGrvLog("RMISTATUSLIVE"," Function Grava iniciando a gravação ", cDetalhe)
    Conout("RMISTATUSLIVE - Function Grava iniciando a gravação " +  cDetalhe)
    Begin Transaction

        RecLock("MHR", .F.)
            MHR->MHR_STATUS := cStatus
            MHR->MHR_RETORN := cDetalhe
        MHR->( MsUnLock() )

        If !Empty(oJson["subsistemasatelite"])
            RecLock("MHP", .F.)
                MHP->MHP_CONFIG := oJson:ToJson()
            MHP->( MsUnLock() )
        EndIF
        
        If cStatus == "3"
            LjGrvLog(" RMISTATUSLIVE ", "Ocorreu erro na gravação" ,{MHR->MHR_UIDMHQ,cDetalhe}) 
            RMIGRVLOG("IR", "MHR" , MHR->(Recno()), "ENVIA",;
                      cDetalhe  ,      ,      , 'MHR_STATUS',;
                        .F.          , 3      ,MHR->MHR_FILIAL+"|"+MHR->MHR_UIDMHQ+"|"+MHR->MHR_CASSIN+"|"+MHR->MHR_CPROCE,MHR->MHR_CPROCE,MHR->MHR_CASSIN,MHR->MHR_UIDMHQ)
        ElseIF cStatus == '2'
            Iif(Alltrim(MHR->MHR_CPROCE) == 'PRODUTO', ConfirmaImposto(MHR->MHR_UIDMHQ, MHR->MHR_CPROCE), "")
            GravaDePara(MHR->MHR_CPROCE)
        EndIf
    LjGrvLog("RMISTATUSLIVE"," Function Grava Fim da gravação ", cDetalhe)
    End Transaction
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição 

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConfirmaImposto(cUUID,cProcesso)

Local cSelect       := ""
Local cTabela       := ""
Local aArea         := GetArea()

Default cUUID       := ""
Default cProcesso   := ""

    cTabela := GetNextAlias()
    cSelect := " SELECT MHQIMP.R_E_C_N_O_, MHQIMP.MHQ_UUID "
    cSelect += " FROM " + RetSqlName("MHQ") + " MHQIMP "
    cSelect += "    WHERE MHQ_CHVUNI = (SELECT MHQ_CHVUNI FROM " + RetSqlName("MHQ") +  " MHQ WHERE MHQ.MHQ_UUID = '" + cUUID + "'"
    cSelect += "    AND MHQ.MHQ_CPROCE = '" + cProcesso + "'  AND MHQ.D_E_L_E_T_ = ' ') "
    cSelect += "    AND MHQ_CPROCE IN ('IMPOSTO PROD','IMPOSTO VENDA') AND MHQIMP.D_E_L_E_T_ = ' ' AND MHQIMP.MHQ_STATUS = '9' "
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    LjGrvLog("RMISTATUSLIVE"," Function ConfirmaImposto query executada", cSelect)

    DbSelectArea("MHQ")
    MHQ->(DbSetOrder(1)) //MHQ_FILIAL, MHQ_ORIGEM, MHQ_CPROCE, MHQ_CHVUNI, MHQ_EVENTO, MHQ_DATGER, MHQ_HORGER

    If (cTabela)->( Eof() )
        LjGrvLog("RMISTATUSLIVE"," Function ConfirmaImposto, não foi enontrado na MHQ o processo: IMPOSTO PROD, referente a integracao de produto pertencente ao UUID - ", cUUID)
    EndIf

    While !(cTabela)->( Eof() )
        
        MHQ->(DbGoTo((cTabela)->R_E_C_N_O_))
        RecLock("MHQ",.F.)
            MHQ->MHQ_STATUS = '1'
        MHQ->(MsUnLock())
        LjGrvLog("RMISTATUSLIVE"," Function ConfirmaImposto gravando status = 1 ", MHQ->MHQ_UUID)
        
        (cTabela)->(DbSkip())
    EndDo

(cTabela)->( DbCloseArea() )
RestArea(aArea)

Return Nil

/*/{Protheus.doc} GravaDePara
    Função para gravar de/para de cadastro, usado para confirmação da integração
    @type  Static Function
    @author Danilo Rodrigues
    @since 15/12/2022
    @version 1.0
    @param param_name, param_type, param_descr
    @return lRet
/*/
Static Function GravaDePara(cProcesso)

    Local aArea     := GetArea()
    Local aAreaMHQ  := MHQ->( GetArea() )
    Local cVlCad    := ""
    Local cChave    := MHR->MHR_FILIAL + MHR->MHR_UIDMHQ

    DbSelectArea("MHQ")
    DbSelectArea("MHN")
    MHN->( DbSetOrder(1) )    //MHN_FILIAL+MHN_COD
    If MHN->( DbSeek(xFilial("MHN") + cProcesso) )

        cVlCad := GetAdvFVal("MHQ", "MHQ_CHVUNI", cChave, 7, "")
    
        RmiDePaGrv("CONFIRMA", MHN->MHN_TABELA, /*cCampo*/, cVlCad, cVlCad, .T., MHR->MHR_UIDMHQ)
    EndIf
    
    RestArea(aAreaMHQ)
    RestArea(aArea)

Return Nil
