#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_LOJA.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_LOJA 
Função para compatibilização do release incremental. 
Esta função é relativa ao módulo Controle de Lojas (SIGALOJA). 

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA  

@Author Edilson Cruz
@since 19/10/2015
@version P12
*/
//-------------------------------------------------------------------
Function RUP_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Return Nil
