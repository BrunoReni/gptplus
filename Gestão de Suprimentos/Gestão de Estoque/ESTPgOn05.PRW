#include "protheus.ch"
#include "msgraphi.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ESTPgOn05� Autor � Nereu Humberto Junior � Data � 26/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo 5           ���
���          � Lotes Vencidos                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ESTPgOn05()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {bClick,aCabec,aValores)                           ���
���          � bClick = Bloco de codigo para execucao do duplo-click no   ���
���          �          browse.                                           ���
���          � aCabec = Array contendo o cabecalho             		      ���
���          � aValores = Array contendo os valores da lista              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAEST                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  ESTPgOn05(oPGOnline)

Local aRet:= {}

aRet := ESTPgOn04(oPGOnline,2)

Return(aRet)