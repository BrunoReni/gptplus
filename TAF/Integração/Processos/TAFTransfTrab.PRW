#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} TafTransfTrab
Classe para gerenciamento do processo de transfer�ncia de funcion�rios
celetistas e TSV utilizando a integra��o online. 

@type class
@author Evandro dos Santos O. Teixeira
@since 24/04/2021
@version 1.0
/*/
Class TafTransfTrab

    Data oJson           
    Data aInterface 

    Method New() Constructor

    Method setErrorTransfer(lError,cErrorCode,cErrorDescription)
    Method setTransferGroup(lTransferGroup)
    Method setSameBaseCNPJ(lSameBaseCNPJ)
    Method setOriginKey(cOriginKey)
    Method setDestinyKey(cDestinyKey)
    Method setErrorCode(cErrorCode)
    Method setErrorDescription(cErrorDescription)
    Method setReceipt(cReceipt)
    Method setStatus(cStatus)
    Method setIndKey(nIndKey)
    Method setOrigBranch(cOriginBranch) 
    Method setDestBranch(cDestinyBranch)
    Method setOrigGroup(cOriginGroup) 
    Method setDestGroup(cDestinyGroup)

    Method thereIsError()
    Method isTransferGroup()
    Method isSameBaseCNPJ()
    Method getOriginKey()
    Method getDestinyKey()
    Method getErrorCode()
    Method getErrorDescription()
    Method getReceipt()
    Method getStatus()
    Method getIndKey()
    Method getOrigBranch() 
    Method getDestBranch()
    Method getOrigGroup() 
    Method getDestGroup()
    Method getJson()

EndClass

/*/{Protheus.doc} New
Metodo Construtor

@param - cJsonTransf (opcional) - String Json com chaves e valores
correspondentes a Classe. 
Esse par�metro � util quando h� necessidade de enviar o objeto para outra thread,
desta forma � poss�vel gerar um Json da classe atrav�s do m�todo getJson() e realizar
a passagem de par�metro para o StarJob/ManualJob etc .. Ent�o na nova thread voc�
instancia novamente a classe passando o Json no m�todo construtor. 
Obs: N�o � poss�vel passar um objeto por par�metro para outra thread.

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/04/2021
@version 1.0
/*/
Method New(cJsonTransf) Class TafTransfTrab

    Local nX := 0
    Local cKey := ""
    Local cValue := ""	

    Default cJsonTransf := ""

    ::oJson := JsonObject():new()
    ::aInterface := {}

    If Empty(cJsonTransf)

        //Queria ter criado uma Interface utilizando tlpp para garantir os atributos da classe, por�m os 
        //clientes protheus GPE podem estar em garantia extendida e utilizando bin�rios incompat�veis
        //Estou utilizando um objeto Json no lugar dos atributos por que n�o � poss�vel passar um objeto   
        //como par�metro para outra Thread, utilizando um objeto Json encapsulado consigo fazer o Deserialize  
        //e enviar uma String Json como par�emtro. 
        aAdd(::aInterface,{'lError',.F.})
        aAdd(::aInterface,{'lTransferGroup',.F.})
        aAdd(::aInterface,{'lSameBaseCNPJ',.F.})
        aAdd(::aInterface,{'cOriginKey',""})
        aAdd(::aInterface,{'cDestinyKey',""})
        aAdd(::aInterface,{'cErrorCode',""})
        aAdd(::aInterface,{'cErrorDescription',""})
        aAdd(::aInterface,{'cReceipt',""})
        aAdd(::aInterface,{'cStatus',""})
        aAdd(::aInterface,{'cOriginBranch',""})
        aAdd(::aInterface,{'cDestinyBranch',""})
        aAdd(::aInterface,{'cOriginGroup',""})
        aAdd(::aInterface,{'cDestinyGroup',""})
        aAdd(::aInterface,{'nIndKey',0})

        For nX := 1 To Len(::aInterface)
            cKey := ::aInterface[nX][1]
            cValue := ::aInterface[nX][2]
            ::oJson[&('cKey')] := cValue 
        Next nX
    Else 
        ::oJson:FromJSON(cJsonTransf)
    EndIf 

Return Nil   

/*/{Protheus.doc} setErrorTransfer
O objetivo deste m�todo � informar que houve erro em alguma etapa do processo 
de transfer�ncia.

@param lError (obrigat�rio) - Informa se houve erro (.T. - Sim, .F. - n�o)
@param cErrorCode - C�digo do Erro conforme defini��es do processo de integra��o 
TAF eSocial 
@param cErrorDescription - Descri��o do Erro  

@type Method
@author Evandro dos Santos O. Teixeira
@since 24/04/2021
@version 1.0
/*/
Method setErrorTransfer(lError,cErrorCode,cErrorDescription) Class TafTransfTrab 

    Default cErrorCode := ""
    Default cErrorDescription := ""

    ::oJson['lError'] := lError
    ::oJson['cErrorCode'] := cErrorCode
    ::oJson['cErrorDescription'] := cErrorDescription 
Return Nil  

//Todos os m�todos abaixo s�o Setters e Getters

Method setTransferGroup(lTransferGroup) Class TafTransfTrab
    ::oJson['lTransferGroup'] := lTransferGroup 
Return Nil 

Method setSameBaseCNPJ(lSameBaseCNPJ) Class TafTransfTrab
    ::oJson['lSameBaseCNPJ'] := lSameBaseCNPJ 
Return Nil 

Method setOriginKey(cOriginKey) Class TafTransfTrab
    ::oJson['cOriginKey'] := cOriginKey
Return Nil 

Method setDestinyKey(cDestinyKey ) Class TafTransfTrab
    ::oJson['cDestinyKey'] := cDestinyKey 
Return Nil 

Method setErrorCode(cErrorCode) Class TafTransfTrab
    ::oJson['cErrorCode'] := cErrorCode
Return Nil 

Method setErrorDescription(cErrorDescription) Class TafTransfTrab
    ::oJson['cErrorDescription'] := cErrorDescription 
Return Nil 

Method setReceipt (cReceipt) Class TafTransfTrab
    ::oJson['cReceipt'] := cReceipt 
Return Nil 

Method setStatus (cStatus) Class TafTransfTrab
    ::oJson['cStatus'] := cStatus 
Return Nil 

Method setIndKey (nIndKey) Class TafTransfTrab
    ::oJson['nIndKey'] := nIndKey 
Return Nil 

Method setOrigBranch(cOriginBranch) Class TafTransfTrab
    ::oJson['cOriginBranch'] := cOriginBranch 
Return Nil 

Method setDestBranch(cDestinyBranch) Class TafTransfTrab
    ::oJson['cDestinyBranch'] := cDestinyBranch 
Return Nil 

Method setOrigGroup(cOriginGroup) Class TafTransfTrab
    ::oJson['cOriginGroup'] := cOriginGroup 
Return Nil 

Method setDestGroup(cDestinyGroup) Class TafTransfTrab
    ::oJson['cDestinyGroup'] := cDestinyGroup 
Return Nil 

Method thereIsError() Class TafTransfTrab 
Return ::oJson:GetJsonObject('lError')

Method isTransferGroup() Class TafTransfTrab 
Return ::oJson:GetJsonObject('lTransferGroup') 

Method isSameBaseCNPJ() Class TafTransfTrab 
Return ::oJson:GetJsonObject('lSameBaseCNPJ')

Method getOriginKey() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cOriginKey')  

Method getDestinyKey() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cDestinyKey')  

Method getErrorCode() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cErrorCode')  

Method getErrorDescription() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cErrorDescription')   

Method getReceipt() Class TafTransfTrab
Return ::oJson:GetJsonObject('cReceipt')   

Method getStatus() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cStatus')   

Method getIndKey() Class TafTransfTrab 
Return ::oJson:GetJsonObject('nIndKey')    

Method getOrigBranch() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cOriginBranch')  

Method getDestBranch() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cDestinyBranch')  

Method getOrigGroup() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cOriginGroup')  

Method getDestGroup() Class TafTransfTrab 
Return ::oJson:GetJsonObject('cDestinyGroup')  

Method getJson() Class TafTransfTrab
Return ::oJson:toJSON() 
