#INCLUDE 'protheus.ch'
#INCLUDE 'restful.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} APIs GPU para utiliazacao protocolos RN 395

@author  Renan Sakai / Vinicius Queiros Teixeira
@version Protheus 12
@since   31/05/2021
/*/
//-------------------------------------------------------------------
WsRestful PLSGPURest Description "APIs GPU para utiliazacao protocolos RN 395" Format APPLICATION_JSON

    //Atributos gerais padrao guia TOTVS - https://api.totvs.com.br/guia
    WSDATA apiVersion as STRING OPTIONAL
   
    //Endpoints
    WSMETHOD POST solicitarProtocolo DESCRIPTION "Solicitar Protocolo de Atendimento - Benefici�rio" ;
    WSsyntax "{apiVersion}/solicitarProtocolo" ;
    PATH "{apiVersion}/solicitarProtocolo" PRODUCES APPLICATION_JSON

    WSMETHOD POST complementaProtocolo DESCRIPTION "Complementar Protocolo de Atendimento" ;
    WSsyntax "{apiVersion}/complementaProtocolo" ;
    PATH "{apiVersion}/complementaProtocolo" PRODUCES APPLICATION_JSON
    
    WSMETHOD POST responderAtendimento DESCRIPTION "Responder Atendimento" ;
    WSsyntax "{apiVersion}/responderAtendimento" ;
    PATH "{apiVersion}/responderAtendimento" PRODUCES APPLICATION_JSON

    WSMETHOD POST consultaStatusProtocolo DESCRIPTION "Consulta Status de Protocolo" ;
    WSsyntax "{apiVersion}/consultaStatusProtocolo" ;
    PATH "{apiVersion}/consultaStatusProtocolo" PRODUCES APPLICATION_JSON

    WSMETHOD POST historicoProtocoloConsulta DESCRIPTION "Consultar Historico do Protocolo" ;
    WSsyntax "{apiVersion}/historicoProtocoloConsulta" ;
    PATH "{apiVersion}/historicoProtocoloConsulta" PRODUCES APPLICATION_JSON

    WSMETHOD POST cancelarAtendimento DESCRIPTION "Cancelar Atendimento" ;
    WSsyntax "{apiVersion}/cancelarAtendimento" ;
    PATH "{apiVersion}/cancelarAtendimento" PRODUCES APPLICATION_JSON

    WSMETHOD POST encaminharExecucao DESCRIPTION "Encaminhar Execu��o da Manifesta��o" ;
    WSsyntax "{apiVersion}/encaminharExecucao" ;
    PATH "{apiVersion}/encaminharExecucao" PRODUCES APPLICATION_JSON

    WSMETHOD POST protocoloNaoCliente DESCRIPTION "Solicitar Protocolo de Atendimento � N�o cliente" ;
    WSsyntax "{apiVersion}/protocoloNaoCliente" ;
    PATH "{apiVersion}/protocoloNaoCliente" PRODUCES APPLICATION_JSON

    WSMETHOD POST statusNaoCliente DESCRIPTION "Solicitar Status Protocolo de Atendimento � N�o cliente" ;
    WSsyntax "{apiVersion}/statusNaoCliente" ;
    PATH "{apiVersion}/statusNaoCliente" PRODUCES APPLICATION_JSON

End WsRestful


//-------------------------------------------------------------------
/*/{Protheus.doc} solicitarProtocolo
Disponibilizar o servi�o 'Solicitar Protocolo de Atendimento - Beneficiario'

@author  Renan Sakai
@version Protheus 12
@since   21/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST solicitarProtocolo WSSERVICE PLSGPURest
        
    Local oRequest := PGPUSolPro():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf
    
    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} complementaProtocolo
Disponibilizar o servi�o 'Complementar Protocolo de Atendimento'

@author  Renan Sakai
@version Protheus 12
@since   21/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST complementaProtocolo WSSERVICE PLSGPURest
        
    Local oRequest := PGPUComPro():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} responderAtendimento
Disponibilizar o servi�o 'Responder Atendimento'

@author  Renan Sakai
@version Protheus 12
@since   21/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST responderAtendimento WSSERVICE PLSGPURest
        
    Local oRequest := PGPUResAte():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} consultaStatusProtocolo
Disponibilizar o servi�o �Consulta Status de Protocolo�.

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   26/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST consultaStatusProtocolo WSSERVICE PLSGPURest
        
    Local oRequest := PGPUConSta():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} historicoProtocoloConsulta
Disponibilizar o servi�o �Consultar Historico do Protocolo�.

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   26/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST historicoProtocoloConsulta WSSERVICE PLSGPURest
        
    Local oRequest := PGPUConHis():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} cancelarAtendimento
Disponibilizar o servi�o �Cancelar Atendimento�.

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   26/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST cancelarAtendimento WSSERVICE PLSGPURest
        
    Local oRequest := PGPUCanAte():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} encaminharExecucao
Disponibilizar o servi�o �Encaminhar Execu��o da Manifesta��o�.

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   27/05/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST encaminharExecucao WSSERVICE PLSGPURest
        
    Local oRequest := PGPUEncExe():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic( self:GetContent() )
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} protocoloNaoCliente
Enviar uma mensagem para a Unimed respons�vel pela �rea de atua��o 
informada pelo "n�o cliente".

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   26/07/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST protocoloNaoCliente WSSERVICE PLSGPURest
        
    Local oRequest := PGPUSolNoClient():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic(self:GetContent())
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} statusNaoCliente
Enviar uma mensagem para a Unimed referente � consulta de status de 
um protocolo existente de um n�o cliente.

@author  Vinicius Queiros Teixeira
@version Protheus 12
@since   26/07/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST statusNaoCliente WSSERVICE PLSGPURest
        
    Local oRequest := PGPUStaNoClient():new(self)
    Local cJsonRet := ""
    Local lStatus := .T.
    Local aRetorno := {}

    aRetorno := oRequest:procSolic(self:GetContent())
    If Len(aRetorno) > 0
        lStatus := aRetorno[1]
        cJsonRet := aRetorno[2]

        ::setResponse( EncodeUTF8(cJsonRet) )
        If lStatus 
            self:setStatus(200)
        Else
            self:setStatus(400)
        EndIf
    EndIf

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.