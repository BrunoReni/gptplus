#INCLUDE "Protheus.ch"
#INCLUDE "PanelOnLine.ch"
#INCLUDE "LojaPgOnL.ch"

/*                
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJAPGONL    � Autor �Vendas Clientes      � Data � 26/02/07 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Exibe os paineis de gest�o para o modulo SIGALOJA			   ���
��������������������������������������������������������������������������Ĵ��
���Uso       �Automa��o Comercial                                          ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function LOJAPGONL(oPgOnline) 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ;        // "M�dia de vendas por PDV por m�s"
	DESCR STR0002 ;        // "Exibe a m�dia de vendas efetuadas por m�s por PDV"
	TYPE 5 ; 
	ONLOAD "LOJP010" ; 
	PARAMETERS "LOJP010" ; 
	REFRESH 3600 ;         // 1 Hora
	DEFAULT 5 ; 
	NAME "1" ; 
	PYME 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003 ;        // "Ranking de venda das lojas"
	DESCR STR0004 ;        // "Exibe o ranking das lojas que mais vendem"
	TYPE 1 ; 
	ONLOAD "LOJP701" ; 
	PARAMETERS "LJP701" ; 
	REFRESH 14400 ;        // 4 Horas
	DEFAULT 1 ; 
	NAME "2" ; 
	PYME 

Return Nil