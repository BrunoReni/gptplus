#Include "Protheus.ch"
#Include "FwMvcDef.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CENHISTMON
Descricao: Historico 

@author Hermiro J�nior
@since 02/09/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CENHISTMON(lAutom)
    Default lAutom  := .F.

    //A chamada desta fun��o saiu do PLSMVCCOMPROM. Agora est� dentro do menu (Miscelania/Central de Obriga��es/Monitoramento/Guia)
    //Chama as Rotinas Corretas Baseadas na Escolha do Hist�rico.
    CENMVCBRF('','Guias',"1",lAutom)
 
Return