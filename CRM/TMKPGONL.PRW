#INCLUDE "PanelOnLine.ch"
#INCLUDE "TMKPGONL.CH"

/*                
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �TMKPGONL     � Autor �Michel W. Mosca      � Data � 07/02/07 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Exibe os paineis de gestao para o modulo SIGATMK.			   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � CALL CENTER                                                 ���
��������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���Conrado Q.�22/02/07�115977�- Adicionado painel n�mero 2.                ���
���Michel M. �26/02/07�115978�- Adicionado painel numero 3.                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMKPGONL(oPgOnline) 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001;  // "Status dos atendimentos em cobran�a"
	DESCR STR0001;  // STR0002 // "Exibe a quantidade de atendimentos em cobran�a por campanha"
	TYPE 2 ;	         
	PARAMETERS "TMKH04";
	ONLOAD "TK274PGOn1"; 
	REFRESH 100 ;
	DEFAULT 2 ;
	NAME "1"
	                
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003; // "Status dos atendimentos em telemarketing"
	DESCR STR0003; // STR0004 // "Exibe a quantidade de atendimentos em telemarketing por campanha"
	TYPE 2 ;	         
	PARAMETERS "TMKH05";
	ONLOAD "TK272PGOn1"; 
	REFRESH 30 ;
	DEFAULT 2 ;
	NAME "2"  
	
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005;  //"Status dos Atendimentos de Televendas" ;
	DESCR STR0005;  //STR0006 //"Exibe a quantidade de atendimentos realizados pelo Televendas por campanha"; 
	TYPE 2 ;	         
	PARAMETERS "TMKH06";
	ONLOAD "TK273PGON3"; 
	REFRESH 100 ;
	DEFAULT 2 ;
	NAME "3" 		

Return       

