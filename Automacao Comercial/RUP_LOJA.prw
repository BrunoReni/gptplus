#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_LOJA.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_LOJA 
Fun��o para compatibiliza��o do release incremental. 
Esta fun��o � relativa ao m�dulo Controle de Lojas (SIGALOJA). 

@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA  

@Author Edilson Cruz
@since 19/10/2015
@version P12
*/
//-------------------------------------------------------------------
Function RUP_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Return Nil
