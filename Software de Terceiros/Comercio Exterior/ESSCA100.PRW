/*
Programa   : ESSCA100
Objetivo   : Chamar a rotina de Processo de Servi�os com a op��o Aquisi��o de Servi�os
Retorno    : Nil
Autor      : 
Data/Hora  : 
Revisao    : 
*/
#Include 'Protheus.ch'
#Include "Average.ch"

Function ESSCA100()
Local cTipo  := "A"
Local cOpcao := "CONTROLE_SERVICOS_AQUISICAO" 

If AvFlags(cOpcao)
   ESSCI100(cTipo)
Else
   EasyHelp("Este ambiente n�o est� preparado para executar esta rotina.  Favor aplicar o update USSIGAESS() ou entrar em contato com o suporte Trade-Easy.","Aviso")
EndIf   

Return .T.