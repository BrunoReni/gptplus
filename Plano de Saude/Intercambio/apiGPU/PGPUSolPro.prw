#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUSolPro
Classe para Enviar uma mensagem para a Unimed referente � uma 
manifesta��o de seu benefici�rio
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUSolPro From PLRN395GPU

    Method New()
    Method mntJson()
    Method procResp()
    Method procSolic(cJson, aAuto)
    Method jsonResp(aRet)
    
EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUSolPro
    
    _Super:new()
    self:cTransacao := "001"

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntJson
Monta Json de comunica��o com o GPU 
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method mntJson() Class PGPUSolPro
    
    Local oGPU := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    //Cabecalho
    Local cCodUniOri := self:aParam[01]
    Local cCodUniDes := self:aParam[02]
    Local cNumRegAns := self:aParam[03]
    Local cNumTraPre := self:aParam[04]
    Local dDatGer := self:aParam[05]
    Local cIDUsuario := self:aParam[06]
    //Body
    Local cCodUniBen := self:aParam[07]
    Local cIDBenef := self:aParam[08]
    Local cNome := self:aParam[09]
    Local cCPF := self:aParam[10]
    Local cDDD := self:aParam[11]
    Local cTelefone := self:aParam[12]
    Local cEmail := self:aParam[13]
    Local cTipManif := self:aParam[14]
    Local cTipCateg := self:aParam[15]
    Local cIDResp := self:aParam[16]
    Local cNumTraInt := self:aParam[17]
    Local cNumProAnt := self:aParam[18]
    Local cMsgLivre := self:aParam[19]

    //Cabecalho
    oCabec := self:setCabEnv("001", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDatGer, cIDUsuario)

    //Body
    oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
    oBody["id_benef"] := self:setAtributo(cIDBenef) 
    oBody["nome"] := self:setAtributo(cNome)     
    oBody["cd_cpf"] := self:setAtributo(cCPF)      
    oBody["ddd"] := self:setAtributo(cDDD)      
    oBody["telefone"] := self:setAtributo(cTelefone)
    oBody["email"] := self:setAtributo(cEmail)   
    oBody["tp_manifestacao"] := self:setAtributo(cTipManif) 
    oBody["tp_categoria_manifestacao"] := {self:setAtributo(cTipCateg, "N")} 
    oBody["id_resposta"] := self:setAtributo(cIDResp, "N")   
    oBody["nr_transacao_intercambio"] := self:setAtributo(cNumTraInt)
    oBody["nr_protocolo_anterior"] := self:setAtributo(cNumProAnt)
    oBody["mensagem"] := self:setAtributo(cMsgLivre) 
    //oBody["cd_uf"]
    //oBody["cd_cidade"]
    //oBody["cd_uni_atendimento"]

    //Monta json completo
    oGPU["cabecalho_transacao"] := oCabec
    oGPU["solicitar_protocolo"] := oBody

    self:cJson := FWJsonSerialize(oGPU, .F., .F.)
    
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procResp
Processa a resposta da comunicacao
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procResp() Class PGPUSolPro

    Local oResponse := JsonObject():New()
    Local lRet := .F.
    Local aRetFun := {}
    Local aCriticas := {}
    // Dados da Resposta
    Local cNumProto := ""
	Local cIdResp := "" 
    Local cIdErro := ""
    Local cMensagem := ""  

    oResponse:fromJSON(self:cRespJson)

    Do Case
        Case !self:lAuthentication .And. !self:lAuto
            Aadd(aCriticas,{"999", "Falha na autentica��o no GIU, verifique os dados no cadastro de Operadoras" })

        Case self:lSucess .And. oResponse["cabecalho_transacao"]["cd_transacao"] == "002"
            lRet := .T.
            cNumProto := oResponse["resposta_solicitar_protocolo"]["nr_protocolo"]
            cIdResp := cValToChar(oResponse["resposta_solicitar_protocolo"]["id_resposta"])

        Case !self:lSucess .And. oResponse["id_identificador"] == 2 // Conte�do com erro
            cIdErro := StrZero(oResponse["id_erro"], 4)
            cMensagem := self:GetAtributo(oResponse["mensagem"])
            If Val(cIdErro) <> 0
                Aadd(aCriticas,{cIdErro, cMensagem}) 
            Else
                Aadd(aCriticas, {"999", "Situacao Invalida"})
            EndIf

        OtherWise 
            Aadd(aCriticas,{"999", "Falha na comunicacao com o GPU." })

    EndCase

	// Monta array de especifico de retorno
	Aadd(aRetFun, lRet)
	Aadd(aRetFun, aCriticas)
	Aadd(aRetFun, cNumProto)
	Aadd(aRetFun ,cIdResp)

    self:impLog(IIF(lRet, "Json de Resposta processado com sucesso!", "Falha ao processar Json de Resposta."))

Return aRetFun


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicita��o
 
@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson, aAuto) Class PGPUSolPro

    Local oRequest := JsonObject():New()
    Local aJsonResp := {}
    //Cabecalho
    Local cCodUniOri := ''
	Local cCodUniDes := ''
	Local cNumRegAns := ''
	Local cNumTraPre := ''
	Local dDataGer := CToD(" / / ")
	Local cIdUsuario := ''
    //Body
	Local cMatric := ''
	Local cNomeBenef := ''
	Local cCPF := ''
	Local cDDD := ''
	Local cTelefone := ''
	Local cEmail := ''
	Local cTipManif := ''
	Local cTipCateg := ''
	Local cTipSentim := ''
    Local cIDResp := ''
	Local cNrTrolOri := ''
	Local cNumProAnt := ''
	Local cMsgLivre := ''

    Default aAuto := {.F.,""}

    self:impLog("Comunicacao de Recebimento - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:fromJSON(cJson)

    //Cabecalho
    self:setVarCab(oRequest, @cCodUniOri, @cCodUniDes, @cNumRegAns, @cNumTraPre, @dDataGer, @cIdUsuario)

	cMatric := self:GetAtributo(oRequest['solicitar_protocolo']['cd_unimed']) + self:GetAtributo(oRequest['solicitar_protocolo']['id_benef'])
	cNomeBenef := self:GetAtributo(oRequest['solicitar_protocolo']['nome'])
	cCPF := self:GetAtributo(oRequest['solicitar_protocolo']['cd_cpf'])
	cDDD := self:GetAtributo(oRequest['solicitar_protocolo']['ddd'])
	cTelefone := self:GetAtributo(oRequest['solicitar_protocolo']['telefone'])
	cEmail := self:GetAtributo(oRequest['solicitar_protocolo']['email'])
	cTipManif := self:GetAtributo(oRequest['solicitar_protocolo']['tp_manifestacao'])
	cTipCateg := self:GetAtributo(oRequest['solicitar_protocolo']['tp_categoria_manifestacao'][1])
	cIDResp := self:GetAtributo(oRequest['solicitar_protocolo']['id_resposta'])
	cNrTrolOri := self:GetAtributo(oRequest['solicitar_protocolo']['nr_transacao_intercambio'])
	cNumProAnt := self:GetAtributo(oRequest['solicitar_protocolo']['nr_protocolo_anterior'])
	cMsgLivre := self:GetAtributo(oRequest['solicitar_protocolo']['mensagem'])
	cTipSentim := "" //Removido da versao Rest

	//Chama funcao para processamento da solicitacao
    self:impLog("Processando Resposta...")
	aRet := PLSolProWB(cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, dDataGer, cIDUsuario,;
                       cMatric, cNomeBenef, cCPF, cDDD, cTelefone, cEmail, cTipManif, cTipCateg,;
                       cTipSentim, cIDResp, cNrTrolOri, cNumProAnt, cMsgLivre, aAuto)   

    // Monta Json de Resposta
    aJsonResp := self:jsonResp(aRet)

    self:impLog("Json de Resposta: "+aJsonResp[2])
    self:impLog("", .F.)
    
Return aJsonResp


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author renan.almeida
@since 31/05/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp(aRet) Class PGPUSolPro

    Local cJson := ""
    Local oResponse := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    Local lStatus := .T.
    //Cabecalho
    Local cCodUniOri := ""
	Local cCodUniDes := ""
	Local cNumRegAns := ""
	Local cNumTraPre := ""
    Local cIdUsuario := ""
    //Body
    Local cCodUniBen := ""
    Local cIDBenef := ""
    Local cNumProtocolo := ""
    Local cIDRespota := "" 
    Local cMensagem := "" 
    Local nIdErro := 0

    //Arquivo processado com sucesso
    If Empty(aRet[3])

        cCodUniOri := aRet[1][3]
        cCodUniDes := aRet[1][4]
        cNumRegAns := aRet[1][5]
        cNumTraPre := aRet[1][6]
        cIdUsuario := aRet[1][8]

        cCodUniBen := Strzero(Val(aRet[1][9]), 4)
        cIDBenef := aRet[1][10]
        cNumProtocolo := aRet[1][11]
        cIDRespota := aRet[1][12]  
        cMensagem := aRet[1][13]

        oCabec := self:setCabRes("002", cCodUniOri, cCodUniDes, cNumRegAns, cNumTraPre, ,cIdUsuario)

        oBody["cd_unimed"] := self:setAtributo(cCodUniBen)
        oBody["id_benef"] := self:setAtributo(cIDBenef)
        oBody["nr_protocolo"] := self:setAtributo(cNumProtocolo)
        oBody["id_resposta"] := self:setAtributo(cIDRespota, "N")
        oBody["mensagem"] := self:setAtributo(cMensagem)
        oBody["id_sistema"] := 1 // 1-Sistema pr�prio da Unimed | 2-Gest�o de Protocolos 

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        oResponse["resposta_solicitar_protocolo"] := oBody

        self:impLog("Resposta processada com sucesso!")
    Else // Arquivo com erro
        lStatus := .F.

        nIdErro := Val(aRet[3])
        oResponse["id_Identificador"] := 2 //1-Confirmado | 2-Conte�do com erro 
        oResponse["id_erro"] := nIdErro

        self:impLog("Resposta com Erro.")
    EndIf

    cJson := FWJsonSerialize(oResponse, .F., .F.)

Return {lStatus, cJson}