#INCLUDE 'protheus.ch'
#INCLUDE 'restful.ch'

#DEFINE ALL "02"

//-------------------------------------------------------------------
/*/{Protheus.doc} APIs Padrão do PLS

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
WsRestful totvsHealthPlans Description "Serviços Rest dedicados a integrações padrões TOTVS Saúde Planos" Format APPLICATION_JSON

    //Atributos gerais padrao guia TOTVS - https://api.totvs.com.br/guia
    WSDATA apiVersion   as STRING OPTIONAL
    WSDATA fields       as STRING OPTIONAL
    WSDATA page         as STRING OPTIONAL
    WSDATA pageSize     as STRING OPTIONAL
    WSDATA filter       as STRING OPTIONAL
    WSDATA expand       as STRING OPTIONAL
    WSDATA order        as STRING OPTIONAL
    
    //Atributos userUsage obrigatorios
    WSDATA subscriberId   as STRING OPTIONAL
    WSDATA initialPeriod  as STRING OPTIONAL
    WSDATA finalPeriod    as STRING OPTIONAL

    //Atributos userUsage opcionais
    WSDATA procedureCode  as STRING OPTIONAL
    WSDATA executionDate as STRING OPTIONAL
    WSDATA healthProviderCode as STRING OPTIONAL
    WSDATA locationCode as STRING OPTIONAL
    WSDATA healthProviderDocument as STRING OPTIONAL
    WSDATA cid as STRING OPTIONAL
    WSDATA procedureName as STRING OPTIONAL
    WSDATA healthProviderName as STRING OPTIONAL
    WSDATA quantity as STRING OPTIONAL
    WSDATA toothRegion as STRING OPTIONAL
    WSDATA face as STRING OPTIONAL
    
    //Atributos internação
    WSDATA authorizationId as STRING OPTIONAL

    //Atributos glossedAppeal
    WsData protocol         as string optional
    WsData formNumber       as string optional
    WsData justification    as string optional
    WsData operation        as string optional
    WsData items            as string optional
    WsData appealProtocol   as string optional
    WsData status           as string optional
    WsData sequential       as string optional

    //Atributos knowledgeBank
    WsData alias            as string optional
    WsData attachmentsKey   as string optional
    WsData fileName         as string optional
    WsData file             as string optional

    //atributos elegibilidade
    WsData cardNumberOrCpf as string optional

    //atributos autorizacao de procedimentos
    WsData procedureId as string optional 

    //atributos authorizations
    WsData idHealthIns as string optional
    WsData authorizationType as string optional
    WSDATA resendBatch as Boolean optional

    //atributos clinicalStaff
    WSDATA specialtyCode as string optional
    WsData id as integer optional

    //Endpoints
    WSMETHOD GET userUsage DESCRIPTION "" ;
    WSsyntax "{apiVersion}/userUsage" ;
    PATH "{apiVersion}/userUsage" PRODUCES APPLICATION_JSON
    
    WSMETHOD POST glossedAppeal DESCRIPTION "" ;
    WSsyntax "{apiVersion}/glossedAppeal" ;
    PATH "{apiVersion}/glossedAppeal" PRODUCES APPLICATION_JSON

    WSMETHOD GET glossedAppeal DESCRIPTION "" ;
    WSsyntax "{apiVersion}/glossedAppeal" ;
    PATH "{apiVersion}/glossedAppeal" PRODUCES APPLICATION_JSON

    WSMETHOD GET itemAppeal DESCRIPTION "" ;
    WSsyntax "{apiVersion}/itemAppeal" ;
    PATH "{apiVersion}/itemAppeal" PRODUCES APPLICATION_JSON

    WSMETHOD GET appealValid DESCRIPTION "" ;
    WSsyntax "{apiVersion}/appealValid" ;
    PATH "{apiVersion}/appealValid" PRODUCES APPLICATION_JSON

    WSMETHOD GET knowledgeBank DESCRIPTION "" ;
    WSsyntax "{apiVersion}/knowledgeBank" ;
    PATH "{apiVersion}/knowledgeBank" PRODUCES APPLICATION_JSON

    WSMETHOD POST knowledgeBank DESCRIPTION "" ;
    WSsyntax "{apiVersion}/knowledgeBank" ;
    PATH "{apiVersion}/knowledgeBank" PRODUCES APPLICATION_JSON

    WSMETHOD POST postAuditXml DESCRIPTION "" ;
    WSsyntax "{apiVersion}/postAuditXml" ;
    PATH "{apiVersion}/postAuditXml" PRODUCES APPLICATION_JSON

    WSMETHOD PUT batchNotes DESCRIPTION "Alteração do campo de notas de um lote" ;
    WSsyntax "{apiVersion}/batchNotes/{protocol}";
    PATH "{apiVersion}/batchNotes/{protocol}" PRODUCES APPLICATION_JSON  

    WSMETHOD PUT hospitalizationDate DESCRIPTION "Informar data de internação/alta" ;
    WSsyntax "{apiVersion}/hospitalizationDate/{authorizationId}";
    PATH "{apiVersion}/hospitalizationDate/{authorizationId}" PRODUCES APPLICATION_JSON  

    WSMETHOD POST tokenBenef DESCRIPTION "Retorna o token de atendimento de um beneficiario" ;
    WSsyntax "{apiVersion}/tokenBenef/{subscriberId}";
    PATH "{apiVersion}/tokenBenef/{subscriberId}" PRODUCES APPLICATION_JSON 

    //************** integracao HAT *******************

    WSMETHOD GET beneficiaryElegibility DESCRIPTION "Find beneficiary by CPF or CARD NUMBER" ;
        WSsyntax "{apiVersion}/beneficiaryElegibility";
        PATH "{apiVersion}/beneficiaryElegibility" PRODUCES APPLICATION_JSON

    WSMETHOD POST procedureAuthorization DESCRIPTION "Authorization of procedure" ;
        WSsyntax "{apiVersion}/procedureAuthorization" ;
        PATH "{apiVersion}/procedureAuthorization" PRODUCES APPLICATION_JSON

    WSMETHOD GET authorizations DESCRIPTION "Retorna os dados do atendimento de um beneficiario" ;
        WSsyntax "{apiVersion}/authorizations/{idHealthIns}";
        PATH "{apiVersion}/authorizations/{idHealthIns}" PRODUCES APPLICATION_JSON 

    WSMETHOD POST authorizations DESCRIPTION "Verifica se pode realizar o reenvio de uma Solic TISS online no HAT" ;
        WSsyntax "{apiVersion}/authorizations" ;
        PATH "{apiVersion}/authorizations" PRODUCES APPLICATION_JSON

    WSMETHOD POST pegTransfer DESCRIPTION "Realiza a transferencias de guias para PEGs de faturamento" ;
        WSsyntax "{apiVersion}/pegTransfer" ;
        PATH "{apiVersion}/pegTransfer" PRODUCES APPLICATION_JSON

    WSMETHOD POST postProf DESCRIPTION "Cadastra profissional de Saude" ;
        WSsyntax "{apiVersion}/professionals" ;
        PATH "{apiVersion}/professionals" PRODUCES APPLICATION_JSON

    WSMETHOD GET accreditations DESCRIPTION "Acreditacoes do prestador" ;
        WSsyntax "{apiVersion}/accreditations" ;
        PATH "{apiVersion}/accreditations" PRODUCES APPLICATION_JSON
    
    WSMETHOD GET healthProviders DESCRIPTION "Dados de um prestador" ;
        WSsyntax "{apiVersion}/healthProviders/{healthProviderCode}" ;
        PATH "{apiVersion}/healthProviders/{healthProviderCode}" PRODUCES APPLICATION_JSON

    WSMETHOD GET clinicalStaff DESCRIPTION "Retorna Corpo Clinico" ;
        WSsyntax "{apiVersion}/clinicalStaff" ;
        PATH "{apiVersion}/clinicalStaff" PRODUCES APPLICATION_JSON

    WSMETHOD POST clinicalStaff DESCRIPTION "Adiciona um profissional em um corpo clinico" ;
        WSsyntax "{apiVersion}/clinicalStaff" ;
        PATH "{apiVersion}/clinicalStaff" PRODUCES APPLICATION_JSON

    WSMETHOD PUT blockClinicallStaff DESCRIPTION "Bloqueia um profissional do corpo clinico" ;
        WSsyntax "{apiVersion}/clinicalStaff/{id}/block" ;
        PATH "{apiVersion}/clinicalStaff/{id}/block" PRODUCES APPLICATION_JSON

    //*************************************************

    // Manutenção Cadastral do Beneficiário
    WSMETHOD POST SolCanBenef DESCRIPTION "Solicita protocolo de bloqueio dos beneficiários pela RN 402" ;
    WSsyntax "{version}/beneficiaries/{subscriberId}/block" ;
    PATH "{version}/beneficiaries/{subscriberId}/block" PRODUCES APPLICATION_JSON

    WSMETHOD GET RetCanBenef DESCRIPTION "Retorna solicitação de protocolo de bloqueio do beneficiários" ;
    WSsyntax "{version}/beneficiaries/{subscriberId}/block" ;
    PATH "{version}/beneficiaries/{subscriberId}/block" PRODUCES APPLICATION_JSON

End WsRestful


//-------------------------------------------------------------------
/*/{Protheus.doc} userUsage
Extrato de utilização de beneficiários de saúde

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
WSMETHOD GET userUsage QUERYPARAM page, pageSize, fields, expand, order, initialPeriod, finalPeriod, subscriberId, ;
                                  procedureCode, executionDate, healthProviderCode, healthProviderDocument, cid, ;
                                  procedureName, healthProviderName, quantity, toothRegion, face WSSERVICE totvsHealthPlans
        
    Local oRequest

    Default self:fields    := ""
    Default self:page      := "1"
    Default self:pageSize  := "20"
    Default self:expand    := ""
    Default self:order     := ""
    //Atributos de Pesquisa
    Default self:subscriberId  := ""
    Default self:initialPeriod := ""
    Default self:finalPeriod   := ""
    //Atributos de Pesquisa opcionais
    Default self:procedureCode := ""
    Default self:executionDate := ""
    Default self:healthProviderCode := ""
    Default self:healthProviderDocument := ""
    Default self:cid := ""
    Default self:procedureName := ""
    Default self:healthProviderName := ""
    Default self:quantity := ""
    Default self:toothRegion := ""
    Default self:face := ""

    oRequest := PLUtzUsReq():New(self)
    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyPageSize()
        oRequest:buscar()
        oRequest:procGet(ALL)
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} glossedAppeal

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod POST glossedAppeal WSService totvsHealthPlans
    local oRequest 	                    := PLSGlosaRequest():new(self)
    default self:protocol               := ""
    default self:formNumber             := ""
    default self:operation              := ""
    default self:items                  := ""
    default self:justification          := ""
    default self:healthProviderCode     := ""    

    oRequest:initRequest()

    if oRequest:checkAuth() .and. oRequest:checkBody() 
        oRequest:inclui()
    endif

    cJson := EncodeUTF8(FWJsonSerialize(oRequest:oJson))
    ::setResponse(cJson)

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} glossedAppeal

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET glossedAppeal QUERYPARAM healthProviderCode, page, pageSize, fields, expand, order, protocol, formNumber,;
                                        initialPeriod, finalPeriod, appealProtocol, status WSService totvsHealthPlans

    local oRequest 	            := nil
    default self:formNumber     := ""
    default self:fields         := ""
    default self:page           := "1"
    default self:pageSize       := "20"
    default self:expand         := ""
    default self:order          := ""
    //Atributos de Pesquisa
    default self:initialPeriod  := ""
    default self:finalPeriod    := ""

    oRequest := PLSB4DReq():New(self)
    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyPageSize()
        oRequest:buscar()
        oRequest:procGet(ALL)
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} itemAppeal

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET itemAppeal QUERYPARAM healthProviderCode, sequential, page, pageSize, fields, expand, order, status WSService totvsHealthPlans

    local oRequest 	            := nil
    default self:fields         := ""
    default self:page           := "1"
    default self:pageSize       := "20"
    default self:expand         := ""
    default self:order          := ""
    default self:status         := ""

    oRequest := PLSB4EReq():New(self)
    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyPageSize()
        oRequest:buscar()
        oRequest:procGet(ALL)
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} appealValid

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET appealValid QUERYPARAM protocol, formNumber, healthProviderCode WSService totvsHealthPlans
    local oRecurso 	            := PLSGlosaValid():new(self)
    local lResult 		        := oRecurso:get()
    default self:formNumber     := ""    

    freeObj(oRecurso)
    oRecurso := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} knowledgeBank

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET knowledgeBank QUERYPARAM alias, attachmentsKey, fileName WSService totvsHealthPlans
    local oAC9 	            := PLSAC9Req():new(self)
    local lResult 		    := oAC9:get()

    freeObj(oAC9)
    oAC9 := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} knowledgeBank
de 
@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod POST knowledgeBank WSService totvsHealthPlans
    local oAC9 	            := PLSAC9Req():new(self)
    local lResult 		    := .f.

    oAC9:initRequest()

    if oAC9:checkAuth() .and. oAC9:checkBody()
        lResult := oAC9:post()
    endif

    freeObj(oAC9)
    oAC9 := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} postAuditXml
de 
@author    Lucas Nonato
@version   V12
@since     10/08/2021
/*/
WSMethod POST postAuditXml WSService totvsHealthPlans
    local oPos 	            := PostAuditReq():new(self)
    local lResult 		    := .f.

    oPos:initRequest()

    if oPos:checkAuth() .and. oPos:checkBody()
        lResult := oPos:post()
    endif

    freeObj(oPos)
    oPos := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} batchNotes
de 
@author    Lucas Nonato
@version   V12
@since     10/08/2021
/*/
WSMethod PUT batchNotes PATHPARAM protocol WSService totvsHealthPlans
    local oRequest  := PLSBCIOBSReq():new(self)
    local lResult   := .f.

    if oRequest:checkBody()
        lResult := oRequest:put()
    endif

    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} hospitalizationDate
de 
@author    Lucas Nonato
@version   V12
@since     05/09/2022
/*/
WSMethod PUT hospitalizationDate PATHPARAM authorizationId WSService totvsHealthPlans
    local oRequest  := PLSDtIntSvc():new(self)
    
    if oRequest:checkBody()
        oRequest:put()
    endif

    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} userUsage
Extrato de utilização de beneficiários de saúde

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
WSMETHOD POST tokenBenef PATHPARAM subscriberId WSSERVICE totvsHealthPlans
    Local oRequest := TotpBenReq():new(self)

    oRequest:validTotp()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} beneficiaryElegibility return data of beneficiary by CPF or CARD NUMBER

@author  PLSTEAM
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod GET beneficiaryElegibility QUERYPARAM cardNumberOrCpf WSService totvsHealthPlans

    local lResult  := .f.
    local oRequest := PLSBenefElegSvc():new(self)

    if oRequest:valida()
        lResult := oRequest:elegibility()
    endIf

    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return lResult


//-------------------------------------------------------------------
/*/{Protheus.doc} procedureAuthorization return if the procedure is autorization or denied

@author  PLSTEAM
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod POST procedureAuthorization QUERYPARAM procedureId WSService totvsHealthPlans

    local lResult  := .f.
    local oRequest := PLSProcAuthSvc():new(self)

    if oRequest:valida()
        lResult := oRequest:authorization()
    endIf

    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return lResult


//-------------------------------------------------------------------
/*/{Protheus.doc} SolCanBenef
Solicita protocolo de bloqueio dos beneficiários pela RN 402

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/06/2022
/*/
//------------------------------------------------------------------- 
WSMETHOD POST SolCanBenef QUERYPARAM subscriberId WSService totvsHealthPlans

    Local oRequest := nil

    Default self:subscriberId := ""

    oRequest := PLSBenefBloqReq():New(self)

    oRequest:Post()
    oRequest:EndRequest()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCanBenef
Retorna solicitação de protocolo de bloqueio do beneficiários

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------- 
WSMETHOD GET RetCanBenef QUERYPARAM subscriberId WSService totvsHealthPlans

    Local oRequest := nil

    Default self:subscriberId := ""

    oRequest := PLSBenefBloqReq():New(self)

    oRequest:Get()
    oRequest:EndRequest()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} authorizations
Retorna dados de uma guia (usado na contingencia HAT x PLS)

@author  sakai
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod GET authorizations PATHPARAM idHealthIns QUERYPARAM authorizationType WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    Default self:authorizationType := ""
    
    if oRequest:valida(self:authorizationType)
        oRequest:authorization()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} authorizations
Verifica se e possivel realizar o reenvio de uma 
guia gerada pelo TISS ON (usado na contingencia HAT x PLS)

@author  sakai
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod POST authorizations QUERYPARAM resendBatch WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    Default self:resendBatch := .F.
    
    if oRequest:checkAuth()
        if self:resendBatch
            oRequest:checkBodyResend()
            oRequest:procReenvioHAT()        
        else //Nao achou acao de POST
            oRequest:faultPostOption()
        endIf
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} pegTransfer
Realiza a transferencia de guias em PEGS temporarias para PEGS de faturamento

@author  PLSTEAM
@version P12
@since   04/10/2022
/*/
//-------------------------------------------------------------------
WSMethod POST pegTransfer WSService totvsHealthPlans
    
    local oRequest := PLPegTransferReq():new(self)
    
    oRequest:valida()
    oRequest:processa()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} postProf
Realiza a cadastro de um profissional de Saude

@author  sakai
@version P12
@since   08/02/2023
/*/
//-------------------------------------------------------------------
WSMethod POST postProf WSService totvsHealthPlans
    
    local oRequest := PLProfessionalsReq():new(self)
    
    oRequest:valida()
    oRequest:procPost()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} accreditations

@author    Lucas Nonato
@version   V12
@since     04/04/2023
/*/
WSMethod GET accreditations QUERYPARAM healthProviderCode,locationCode WSService totvsHealthPlans

    local oRequest 	                        := nil
    default self:healthProviderCode         := ""
    default self:locationCode               := ""

    oRequest := PLSB7PReq():New(self)
    oRequest:initRequest()
    if oRequest:valida()
        oRequest:procGet()
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} healthProviders

@author    Sakai
@version   V12
@since     22/05/2023
/*/
WSMETHOD GET healthProviders PATHPARAM healthProviderCode WSService totvsHealthPlans

    local oRequest := PLSHealthProvidersRequest():new(self)
   
    if oRequest:valida()
        oRequest:getRda()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} clinicalStaff

@author    Sakai
@version   V12
@since     22/05/2023
/*/
WSMETHOD GET clinicalStaff QUERYPARAM healthProviderCode,locationCode,specialtyCode,pageSize,page WSService totvsHealthPlans

    local oRequest := nil
    default self:healthProviderCode := ''
    default self:locationCode       := ''
    default self:specialtyCode      := ''
    default self:pageSize := '10'
    default self:page := '1'

    oRequest := PLSClinicalStaffRequest():new(self)
    if oRequest:validaGet()
        oRequest:getClinicalStaff()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} clinicalStaff

@author    Sakai
@version   V12
@since     22/05/2023
/*/
WSMETHOD POST clinicalStaff  WSService totvsHealthPlans

    local oRequest := PLSClinicalStaffRequest():new(self)

    if oRequest:validaPost()
        oRequest:postClinicalStaff()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} blockClinicallStaff
de 
@author    Lucas Nonato
@version   V12
@since     24/05/2023
/*/
WSMethod PUT blockClinicallStaff WSService totvsHealthPlans

    local oRequest  := PLSClinicalStaffRequest():new(self)
    local lResult   := .f.

    lResult := oRequest:block()    

    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil    

    delClassIntf()

return lResult