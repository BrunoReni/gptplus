#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFGFE
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Padr�o do Gest�o de Frete Embarcador.

@type 		Classe
@author 	Squad CRM / FAT 
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFGFE From FwModelEvent 

	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model.
	//---------------------
	Method ModelPosVld()
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFGFE
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar as valida��es das regras de neg�cio
do Gest�o de Frete Embarcador antes da grava��o do formulario.
Se retornar falso, n�o permite gravar.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFGFE
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
   		//------------------------------------------------------
		// Integra��o Protheus x GFE
		//------------------------------------------------------
		If !MATA030IPG( nOperation )
			lValid := .F.
		EndIf	   			
   	EndIf
Return lValid