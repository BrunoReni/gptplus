
#include "PLSMGER.CH"
#include "protheus.ch"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR020 � Autor � Eduardo Motta          � Data � 27.06.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Rede Referenciada                             ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR020()                                                  ����
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
Function PLSR020()
PlsRelPad("Relatorio de Rede Referenciada","PLSR020","PLSR20","Rede Referenciada","PLSM010DEF")
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PlsR020QLc� Autor � Eduardo Motta         � Data � 31.10.01 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Controla a quebra de localidades                           ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PlsR020QLc(lRodape)                                        ����
�������������������������������������������������������������������������Ĵ���
���Parametros� lRodape - Se .F. e' condicao da linha, se for .T. e' rodape����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PlsR020QLc(lRodape)
If uContro == NIL  // variavel de controle (PRIVATE da funcao de relatorio) - NAO DECLARAR NESTA FUNCAO POIS ELA E' UMA PRIVATE DA FUNCAO ANTERIOR
   uContro := {}
   aadd(uContro,{"LOCANT",NIL})  // controla localidade anterior
   aadd(uContro,{"TOTLOC",0})    // controla total por localidade
   aadd(uContro,{"TOTGER",0})    // controla total geral
EndIf
If !lRodape
   If uContro[01,02] == NIL .or. uContro[01,02] # BB8->BB8_DESLOC
      If uContro[01,02] # NIL
         @ nLin++,00 pSay "     "+Str(uContro[02,02],6)+" credenciado(s) nesta localidade."
      EndIf
      @ nLin++,00 pSay ""
      @ nLin++,00 pSay "Localidade : "+BB8->BB8_DESLOC
      uContro[01,02] := BB8->BB8_DESLOC
      uContro[02,02] := 0
   EndIf
   uContro[02,02]++  // soma total por localidade
   uContro[03,02]++  // soma total geral
Else
   @ nLin++,00 pSay "     "+Str(uContro[02,02],6)+" credenciado(s) nesta localidade."
   nLin++
   @ nLin++,00 pSay "     "+Str(uContro[03,02],6)+" credenciado(s) listados."
EndIf   

Return .T.
