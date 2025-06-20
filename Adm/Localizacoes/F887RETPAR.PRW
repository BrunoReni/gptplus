#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887RETPAR
Clase responsable por el evento de reglas de negocio de 
localización de retenciones de Paraguay

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021
/*/
Class F887RETPAR From FwModelEvent 

	Method New() CONSTRUCTOR

	Method Destroy()
	
	Method InTTS()
	
	Method UPDSFE()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method New() Class F887RETPAR
	
Return Nil	


/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method Destroy() Class F887RETPAR

Return Nil


/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method InTTS(oModel, cModelId) Class F887RETPAR
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:UPDSFE(oModel)
	EndIf
	

Return Nil

/*/{Protheus.doc} UPDSFE
Metodo responsable por ejecutar reglas de negocio de Retenciones 
para la localización de Paraguay

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method UPDSFE(oModel) Class F887RETPAR
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local nX			:= 0

	SE1->(DbSetorder(1))
	For nX := 1 To oModelSEL:Length()
		If oModelSEL:GetValue("EL_TIPODOC",nX) $ "RI|RR" 
			If oModelSEL:GetValue("EL_VALIMP1",nX) > 0
				RecLock("SFE",.T.)
					FE_TIPO		:= Iif(oModelSEL:GetValue("EL_TIPODOC",nX)=="RI","I","R")
					FE_FILIAL   := xFilial('SE1')   
					FE_EMISSAO  := oModelSEL:GetValue("EL_EMISSAO",nX)
					FE_CLIENTE  := oModelSEL:GetValue("EL_CLIENTE",nX)
					FE_LOJCLI 	:= oModelSEL:GetValue("EL_LOJA",nX)
					FE_RECIBO   := oModelSEL:GetValue("EL_RECIBO",nX)
					FE_NFISCAL	:= oModelSEL:GetValue("EL_DOCTO",nX)
					FE_SERIE    := oModelSEL:GetValue("EL_SDOCTO",nX)
					FE_RETENC 	:= oModelSEL:GetValue("EL_VALOR",nX)
					FE_VALBASE 	:= oModelSEL:GetValue("EL_VALIMP1",nX)
					FE_ALIQ		:= oModelSEL:GetValue("EL_ALQIMP1",nX)
					FE_NROCERT	:= oModelSEL:GetValue("EL_NUMERO",nX)
				MsUnlock()
			EndIf
		EndIf
	Next nX
Return Nil
