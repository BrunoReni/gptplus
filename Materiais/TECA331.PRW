#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"       
#INCLUDE "TECA331.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA331
Aloca��o Automatica dos Atendentes 

@sample 	TECA331(cNumContr, cNumOrcS) 

@author		Bruno O. Rosa
@since		10/05/2013       
@version	P12   
@param		ExpC1,	Numero do Contrato
@param		ExpC2, C�digo Or�amento de Servi�os	
	
@return		ExpL	Verdadeiro
/*/         
//------------------------------------------------------------------------------
Function TECA331(cNumContr,cNumOrcS)
	MsgInfo(STR0057) //"Aloca��o Automatica dos Atendentes: Rotina Descontinuada!"
Return (.T.) 