#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCashName
Retorna o nome do caixa

@author  Varejo
@version P11.8
@since   27/03/2015
@return  cCashName			Retorna o codigo do caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCashName()
Local lPDVFirst 		:=  FindFunction("STFCfgIntegration") .AND. (STFCfgIntegration() == "FIRST")//Pdv Mobile						
Local cCashName		:=	Upper(cUsername)				// Retorna se todos os itens s�o de reserva

If lPDVFirst .and. !Empty(STFGetStat("CODIGO"))
	cCashName := "CAIXA_PDV_" + STFGetStat("CODIGO")  //o nome do usu�rio dever� ser gravado no cadastro de estacao ou parametro
EndIf

Return cCashName
