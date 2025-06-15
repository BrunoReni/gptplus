#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "WSJUROCORRENCIA.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} JurOcorrencia
Classe WS do Jur�dico para m�todos referente � ocorrencias

@since 06/10/22
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL JurOcorrencia DESCRIPTION STR0001 //"WS J�ridico Ocorr�ncias"

	WSMETHOD POST ocorrencia    DESCRIPTION STR0002 PATH "ocorrencia"           PRODUCES APPLICATION_JSON // "Cria fatura adicional conforme a ocorr�ncia"
	
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST ocorrencia
Realiza a resposta da ocorr�ncia.

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JurOcorrencia/ocorrencia
body - 
/*/
//-------------------------------------------------------------------
WSMETHOD POST ocorrencia WSREST JurOcorrencia

Local oRequest    := JsonObject():New()
Local cBody       := Self:GetContent()

	oRequest:FromJson(cBody)
	J033GrvOco(oRequest)

	Self:SetContentType("application/json")
	Self:SetResponse(oRequest:toJson())

Return .T.

//------------------------------------------------------------------------------
/* /{Protheus.doc} JOcoGetChave()
Fun��o respons�vel para retornar a chave conforme o tipo
@since 14/10/2022
@version 1.0
@param cTipo, character, Tipo de retorno
		1-Codigo T
		2-Chave de seguran�a
		3-Chave diaria
		4-Autentificacao
@return cRet, retorna a chave conforme o tipo informado
/*/
//------------------------------------------------------------------------------
Function JOcoGetChave(cTipo)
Local cRet := ""
Default cTipo := ""
	Do Case
		
		Case cTipo == '1'
			cRet := getCodigoT()
		Case cTipo == '2'
			cRet := getChaveSeguranca()
		Case cTipo == '3'
			cRet := getChaveDiaria()
		Case cTipo == '4'
			cRet := getAutenticacao()
	EndCase

Return cRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} getCodigoT()
Fun��o respons�vel para retornar o codigoT da configura��o
@since 14/10/2022
@version 1.0
@return cRet, retorna a chave de seguran�a
/*/
//------------------------------------------------------------------------------
Static Function getCodigoT()
Local cCodT := SuperGetMv('MV_JCFGOCO',, '')
	If Empty(cCodT)
		cCodT := FwGetIdLSV()
	Endif
Return cCodT

//------------------------------------------------------------------------------
/* /{Protheus.doc} getChaveSeguranca()
Fun��o respons�vel para retornar a chave de seguran�a
@since 14/10/2022
@version 1.0
@return cRet, retorna a chave de seguran�a
/*/
//------------------------------------------------------------------------------
Static Function getChaveSeguranca()
Local cRet  := ""
Local cCodT := getCodigoT()
	cRet := MD5( 'ocorrencia'+cCodT, 2 )
Return cRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} getChaveDiaria()
Fun��o respons�vel para retornar a chave diaria
@since 14/10/2022
@version 1.0
@return cRet, retorna a chave diaria
/*/
//------------------------------------------------------------------------------
Static Function getChaveDiaria()
Local cRet  := ""
Local cCodT  := getCodigoT()
Local cAno   := cValToChar(Year(date()))
Local cHora  := SubStr(Time(),1,2)
Local cChave := cCodT+cValToChar(Round((val(chora)*365/48),0))+cAno
	cRet := MD5( cChave, 2 ) 
Return cRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} getAutenticacao()
Fun��o respons�vel para retornar a autentica��o
@since 14/10/2022
@version 1.0
@return cRet, retorna a chave diaria
/*/
//------------------------------------------------------------------------------
Static Function getAutenticacao()
Local cRet            := ""
Local cChaveDiaria    := getChaveDiaria()
Local cChaveSeguranca := getChaveSeguranca()
	cRet := Encode64( cChaveDiaria+ ":!!:" +cChaveSeguranca) 
Return cRet 


//------------------------------------------------------------------------------
/* /{Protheus.doc} JRestOcor
Fun��o respons�vel pela cria��o do objeto rest configurado para ocorr�ncia
@since 19/10/2022
@version 1.0
@param cEndPoint, character, Endpoit da api
@param aHeader, array, Array passado por referencia para ser utilizado nas requisi��es
@return oRet, Objeto Rest configurado para a api com os headers inicias
@see (links_or_references)
@exemple
	JRestOcor('config/<codigoT>',@aHeader)
/*/
//------------------------------------------------------------------------------
Function JRestOcor(cEndPoint,aHeader)
Local oRest := FwRest():New("https://api.totvsjuridico.totvs.com.br/api/")
Default aHeader  := {}

	aAdd(aHeader,"Content-Type: application/json")
	aAdd(aHeader,"Authorization: "+JOcoGetChave('4'))

	oRest:SetPath(cEndPoint)

Return oRest
