/*
Funcao      : WFSchEICPrev
Parametros  : Nil
Retorno     : Envio de Workflow
Objetivos   : Fun��o responsavel pela chamada de workflow de Previs�o de Entreda no Desembara�o via Schedule
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 27/09/2012 :: 09:55
*/
*-----------------------------*
Function WFSchEICPrev(aParams) 
*-----------------------------*
Return EASYGROUPWF('EMBARQUE_SCH_EIC',,.T.,aParams[1],aParams[2],.T.)