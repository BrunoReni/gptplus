
#include "PLSMGER.CH"
#include "protheus.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR060 � Autor � Marco Paulo            � Data � 06.11.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Metas de Venda                                ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR060()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSR060()
PlsRelPad("Relatorio de Metas de Venda","PLSR060","PLSR20","Metas/Venda","PLSM080DEF")
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PlsR060QLc� Autor � Marco Paulo           � Data � 06.11.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Controla a quebra de localidades                           ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PlsR060QLc(lRodape)                                        ����
�������������������������������������������������������������������������Ĵ���
���Parametros� lRodape - Se .F. e' condicao da linha, se for .T. e' rodape����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PlsR060QLc(lRodape)
If uContro == NIL  // variavel de controle (PRIVATE da funcao de relatorio) - NAO DECLARAR NESTA FUNCAO POIS ELA E' UMA PRIVATE DA FUNCAO ANTERIOR
   uContro := {}
   aadd(uContro,{"LOCANT",NIL})  // controla localidade anterior
   aadd(uContro,{"TOTLOC",0})    // controla total por localidade
   aadd(uContro,{"TOTGER",0})    // controla total geral
EndIf
If !lRodape
   If uContro[01,02] == NIL .or. uContro[01,02] # BRR->BRR_CODREG
      If uContro[01,02] # NIL
         @ nLin++,00 pSay "     "+Str(uContro[02,02],6)+" Regra(s) de Venda "
      EndIf
      @ nLin++,00 pSay ""
      @ nLin++,00 pSay "Regra de Venda: "+BRR->BRR_CODREG
      uContro[01,02] := BRR->BRR_DESREG
      uContro[02,02] := 0
   EndIf
   uContro[02,02]++  // soma total por localidade
   uContro[03,02]++  // soma total geral
Else
   @ nLin++,00 pSay "     "+Str(uContro[02,02],6)+" Metas(s) com esta Regra."
   nLin++
   @ nLin++,00 pSay "     "+Str(uContro[03,02],6)+" Metas(s) listados."
EndIf   

Return .T.
