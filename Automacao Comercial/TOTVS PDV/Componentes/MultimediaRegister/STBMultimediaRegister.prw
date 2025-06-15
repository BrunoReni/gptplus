#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBMRIsRegistered
Verifica se a Midia foi registrada na venda

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se registrou a midia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBMRIsRegistered()

Local lRet := .F.			// Retorna se registrou a Midia na Venda

lRet := !(Empty( STDGPBasket("SL1","L1_MIDIA") ))

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBMRSetMedia
Adiciona o Registro de Midia na venda

@param cCodMedia Codigo da midia
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se registrou a midia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBMRSetMedia( cCodMedia )

Local lRet 				:= .F.				// Retorna se Registrou a midia

Default cCodMedia		:= ""

ParamType 0 Var cCodMedia	AS Character	Default ""

lRet := STDSPBasket("SL1","L1_MIDIA",cCodMedia)

Return lRet
 

//-------------------------------------------------------------------
/*/{Protheus.doc} STBMRObrigat
Verifica se utiliza Registro de M�dia

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lUse					Retorna se utiliza Registro de M�dia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBMRUse()

Local lUse		:= .T.	// Retorna se utiliza registro de midia

If AllTrim(Str(SuperGetMv("MV_LJRGMID",,0))) == "0"
	lUse := .F.
EndIf

Return lUse


//-------------------------------------------------------------------
/*/{Protheus.doc} STBMRObrigat
Verifica se o Registro de m�dia � obrigat�rio

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lObrigat					Retorna se o Registro de m�dia � obrigat�rio
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBMRObrigat()

Local lObrigat		:= .F.		// Retorna se o registro de m�dia � obrigat�rio
Local cMultimidia	:= ""		// Armazena conte�do do parametro de midia

cMultimidia := AllTrim(Str(SuperGetMv("MV_LJRGMID",,0)))

If cMultimidia == "2"	
	lObrigat := .T.	
EndIf

Return lObrigat

