#Include "PanelOnLine.ch"
#Include "OmsPgOnl.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �OMSPGONL  � Autor � Marco Bianchi         � Data � 15/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Painel de Gestao.                                             ���
���          �Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �OMSPGONL(oPGOnline)                                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/


Function OMSPGONL(oPGOnline)

Local cString
Local aToolBar := {}
//������������������������������������������������������������������������Ŀ
//�Ocupacao por Frota                                                      �
//��������������������������������������������������������������������������
cString := STR0005 //"O objetivo deste painel � de demonstrar a utiliza��o da frota de veiculos em rela��o as cargas transportadas, utilizando como indicador peso e hora, para que o gestor possa analisar a efici�ncia de sua logistica."
Aadd( aToolBar, { "S4WB016N",STR0004,"{ || MsgInfo('"+cString+"') }" } )	
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001;	// "Ocupacao da Frota" 
	DESCR STR0002;	// "Ocupacao de Frota por Peso/Utiliza��o" 
	TYPE 4 ;
	ONLOAD "OMSP010" ;
	TOOLBAR aToolBar ;	
	REFRESH 300 ;
	NAME "1"    

//������������������������������������������������������������������������Ŀ
//�Faturamento por Rota                                                    �
//��������������������������������������������������������������������������
cString := STR0005 //"O objetivo deste painel � de demonstrar o valor total das notas fiscais transportadas por rota de entrega, para que o gestor possa analisar a viabilidade de uma rota. "
aToolBar := {}
Aadd( aToolBar, { "S4WB016N",STR0004,"{ || MsgInfo('"+cString+"') }" } )	
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003;	// "Faturamento por Rota" 
	DESCR STR0003;	// "Faturamento por Rota" 
	TYPE 1 ;
	ONLOAD "OMSP020" ;
	TOOLBAR aToolBar ;	
	REFRESH 300 ;
	NAME "2"
	                          
Return