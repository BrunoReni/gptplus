#include 'protheus.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsAtuArte
Carrega Informa��es do arquivo de configura��o
@author PLS Projetos
@since 07/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PrjTussAtu(oArtefato)

Local lRet	:= .F.
Default cDirTerm	:= ""
Default cVerAtual	:= ""


PLSIMPTERM(oArtefato:cDestino,oArtefato:cVersion)
lRet := .T.

Return lRet


