#INCLUDE "SFPV007.ch"
#include "eADVPL.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SFPV007A  �Autor  �Rodrigo de A.Godinho� Data �  30/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fonte complementar do SFPV007 devido restricao de tamanho   ���
���          �dos fontes para Palm                                        ���
�������������������������������������������������������������������������͹��
���Uso       �SFA                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �PVFldDesc    �Autor  �Rodrigo de A.Godinho� Data �  30/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.  �Funcao de criacao do folder com as opcoes de desconto no       ���
���       �cabecalho do pedido de venda.                                  ���
�������������������������������������������������������������������������͹��
���Uso    �SFA                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PVFldDesc(oPVDesc,aObj,oObj,aCabPed,cCliente)

// Folder de Informacoes de descontos do pedido de venda #### "Descontos"
@ 35,01 TO 139,158 CAPTION STR0037 OF oPVDesc //"Descontos"
@ 18,03 GET oObj VAR cCliente SIZE 150,12 READONLY MULTILINE OF oPVDesc
@ 40,42 GET oObj VAR aCabPed[18,1] PICTURE "@E 99.99" SIZE 30,12 of oPVDesc
AADD(aObj[2],oObj)
SetText(aObj[2,9],"")
@ 40,03 BUTTON oObj CAPTION STR0033 SIZE 34,10 ACTION PVQTde(aObj[2,9]) of oPVDesc  
AADD(aObj[2],oObj)
// Tabela de Preco
@ 40,119 GET oObj VAR aCabPed[19,1] PICTURE "@E 99.99" SIZE 30,12 of oPVDesc
AADD(aObj[2],oObj)
SetText(aObj[2,11],"")
@ 40,80 BUTTON oObj CAPTION STR0034 SIZE 34,10 ACTION PVQTde(aObj[2,11]) of oPVDesc 
AADD(aObj[2],oObj)
//
@ 54,42 GET oObj VAR aCabPed[20,1] PICTURE "@E 99.99" SIZE 30,12 of oPVDesc
AADD(aObj[2],oObj)
SetText(aObj[2,13],"")
@ 54,03 BUTTON oObj CAPTION STR0035 SIZE 34,10 ACTION PVQTde(aObj[2,13]) of oPVDesc  
AADD(aObj[2],oObj)
// Tabela de Preco
@ 54,119 GET oObj VAR aCabPed[21,1] PICTURE "@E 99.99" SIZE 30,12 of oPVDesc
AADD(aObj[2],oObj)
SetText(aObj[2,15],"")
@ 54,80 BUTTON oObj CAPTION STR0036 SIZE 34,10 ACTION PVQTde(aObj[2,15]) of oPVDesc 
AADD(aObj[2],oObj)
Return nil