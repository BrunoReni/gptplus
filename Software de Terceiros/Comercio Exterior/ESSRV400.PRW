/*
Programa   : ESSRV400
Objetivo   : Chamar a rotina de Registro de Servi�os com a op��o Venda de Servi�os
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 31/08/2012 14:51 
Revisao    : 
*/

#Include 'Protheus.ch'
#Include "Average.ch"
Function ESSRV400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cTipo  := "V"
Default lCallInv := .F. 
ESSRS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
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
Private cAvStaticCall := "ESSRV400"
Private cTpReg := "V"
Private aRotina      := {}//FSY - 26/12/2013 - (Op��o: Conhecimento) Variavel deve ser private, utilizado para exibir as op��es no menu principal
   aRotina := MDSRS400() //Static Call(ESSRS400, MenuDef) 

Return aRotina 
