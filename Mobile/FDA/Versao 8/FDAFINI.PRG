#include "FDAFINI.CH"                                                                                                                              
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FdaFisIni  � Autor � Henry Fila           � Data � 18.10.2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa os dados da funcao fiscal                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function FdaFisIni(cCodCliFor,cLoja,cTipoNF,cEspecie,aFdaNfCab,aFdaNfItem,aFdaCab,aFdaItem)  

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(RetFilial("HA1")+cCodCliFor+cLoja)

Aadd( aFdaNfCab, cTipoNF )
Aadd( aFdaNfCab, If(Empty(HA1->HA1_INSCR).Or."ISENT"$HA1->HA1_INSCR,.T.,.F.) )
Aadd( aFdaNfCab, HA1->HA1_GRPTRIB )
Aadd( aFdaNfCab, MV_ESTADO)
Aadd( aFdaNfCab, HA1->HA1_EST)
Aadd( aFdaNfCab, cCodCliFor)
Aadd( aFdaNfCab, cLoja)
Aadd( aFdaNfCab, HA1->HA1_NATUREZ)
Aadd( aFdaNfCab, (!Empty(HA1->HA1_SUFRAMA).And.HA1->HA1_CALCSUF<>'N') ) 
Aadd( aFdaNfCab, 1)   //nMoeda
Aadd( aFdaNfCab, 1)   //nTxMoeda
Aadd( aFdaNfCab, 0)   //Base do Icms    //12
Aadd( aFdaNfCab, 0)   //Valor do Icms   //13 
Aadd( aFdaNfCab, 0)   //Base do Ipi     //14
Aadd( aFdaNfCab, 0)   //Valor do Ipi    //15 

Return
