#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobUtzCon

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Class PMobUtzCon

	// Propriedades de uso geral
	Data oRequestModel
	Data message

	Data oMsUtlzModel
	Data cModelEndPoint

	// Dados de entrada	
	Data aModel
	Data oBody	
	Data oBeneficiario

	Data parametersMap
	Data tituloCodigo
	Data tituloId

	Data lMultiContract 	
	data lLoginByCPF		
	Data chaveBeneficiario
	Data oConfig

	Method New() CONSTRUCTOR

	// Metodos obrigatorios do padrao definido
	Method GetModel()
	Method SetParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)

	// Metodos de regras de negocio do servi�o
	Method extrato()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method New() Class PMobUtzCon
	
	// Obrigatorios para o padr�o definido
	self:oMsUtlzModel 		:= jSonObject():New()
	self:cModelEndPoint		:= nil
	self:oConfig			:= nil
	self:oRequestModel 		:= nil
	self:message 			:= ""

	// Dados de entrada 
	self:parametersMap		:= JsonObject():New()
	
	self:lMultiContract 	:= nil
	self:lLoginByCPF		:= nil
	self:chaveBeneficiario	:= nil

	// Modelos genericos da arquitetura de API	
	self:aModel 			:= {}
	self:oBody			  	:= JsonObject():New()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} extrato

Retorna o extrato de utiliza��o com base em um periodo previamente selecionado
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method extrato() Class PMobUtzCon

	// DEFINE os parametros 
	self:SetParameters()

	// Cria mapa referente ao cliente vinculado ao benefici�rio 
	self:oMsUtlzModel := PMobUtzMod():New(self:parametersMap) 
	self:oMsUtlzModel:oConfig := self:oConfig
	 
	If !self:oMsUtlzModel:extrato()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oMsUtlzModel:getMessage())
		Return(.F.)	
	Endif

	self:oRequestModel:SetDataResponse(self:oMsUtlzModel:getExtrato())	// Extrato de utiliza��o 	 

Return .T.	


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) Class PMobUtzCon
	self:oRequestModel := oRequestModel	
	self:SetBody(oRequestModel:oBody)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) Class PMobUtzCon
	self:oBody := oBody
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParameters

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetParameters() Class PMobUtzCon

	if lower(self:cModelEndPoint) == lower("/mobileSaude/extrato")

		self:parametersMap['multiContract']			:= self:oBody['multiContract']
		self:parametersMap['chaveBeneficiarioTipo']	:= self:oBody['chaveBeneficiarioTipo']
		self:parametersMap['chaveBeneficiario']		:= self:oBody['chaveBeneficiario']
		self:parametersMap['ano']					:= self:oBody['ano']
		self:parametersMap['mes']					:= self:oBody['mes']
		self:parametersMap['tipoUsuario']			:= self:oBody['tipoUsuario']
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method GetModel() Class PMobUtzCon

	Local lRet := .T.

	If lower(self:cModelEndPoint) == lower("/mobileSaude/extrato")
		   
		Aadd(self:aModel, "chaveBeneficiario")
		Aadd(self:aModel, "ano")
		Aadd(self:aModel, "mes")
		
	Else
		lRet := .F.	
	Endif

Return lRet