/*
Programa   : EECPS400
Objetivo   : Chamar a rotina de Processo de Servi�os com a op��o Venda de Servi�os
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 17/08/2012 11:13 
Revisao    : 
*/

#Include 'Protheus.ch'
#Include "Average.ch"
Function EECPS400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
return ESSPV400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)

Function ESSPV400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cTipo  := "V"
Local cOpcao := "CONTROLE_SERVICOS_VENDA" 
Default lCallInv := .F.

If AvFlags(cOpcao)
   ESSPS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Else
   EasyHelp("Este ambiente n�o est� preparado para executar esta rotina.  Favor aplicar o update USSIGAESS() ou entrar em contato com o suporte Trade-Easy.","Aviso")
EndIf   

Return .T.

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Felipe Sales Martinez
Data       : 22/11/2012
*/ 
Static Function MenuDef() 
Private cAvStaticCall := "EECPS400"
Private cPed := "V"

   aRotina := MDSPS400() //Static Call(ESSPS400, MenuDef) 

Return aRotina 