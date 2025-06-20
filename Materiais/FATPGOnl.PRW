#Include "PanelOnLine.ch"
#Include "FatPgOnL.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FATPGONL  � Autor � Marco Bianchi         � Data � 18/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Painel de Gestao.                                             ���
���          �Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �FATPGONL(oPGOnline)                                           ���
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

Function FATPGONL(oPGOnline)

Local aToolBar  := {}
Local cString   := ""

//������������������������������������������������������������������������Ŀ
//�Meta de Venda                                                           �
//��������������������������������������������������������������������������
//Botao de Help do Painel
cString := STR0002 // "O objetivo deste painel � demonstrar o indicador de meta de venda. Para o c�lculo do valor realizado, ser�o considerados apenas TES que geram duplicata e atualizam estoque. No valor realizado j� est�o deduzidas as devolu��es."
	Aadd( aToolBar, { "S4WB016N",STR0008,"{ || MsgInfo('"+cString+"') }" } )
PANELONLINE oPGOnline ADDPANEL ;
	TITLE  STR0001;	// "Metas de Venda x Realizado"
	DESCR STR0001 ;	// "Metas de Venda x Realizado"
	TYPE 4 ;
	PARAMETERS "FATP010" ;	
	ONLOAD "FATP010" ;
	REFRESH 300 ;     
	TOOLBAR aToolBar ;	
	NAME "1"
                      
//������������������������������������������������������������������������Ŀ
//�Perda de Faturamento                                                    �
//��������������������������������������������������������������������������
//Botao de Help do Painel
cString := STR0004 //"O objetivo deste painel � demonstrar o indicador de perda de faturamento, representado pelo valor dos pedidos de venda que n�o foram faturados por bloqueio de credito, bloqueio de estoque ou por elimina��o de res�duo."
aToolBar  := {}
Aadd( aToolBar, { "S4WB016N",STR0008,"{ || MsgInfo('"+cString+"') }" } )
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003 ;	// "Perda de Faturamento"
	DESCR STR0003 ;	// "Perda de Faturamento"
	TYPE 3 ;
	ONLOAD "FATP020" ;
	REFRESH 300 ;
	TOOLBAR aToolBar ;
	NAME "2";
	PYME

//������������������������������������������������������������������������Ŀ
//�Carteira de Pedidos de Venda                                            �
//��������������������������������������������������������������������������
//Botao de Help do Painel
aToolBar  := {}
cString := STR0007
Aadd( aToolBar, { "S4WB016N",STR0008,"{ || MsgInfo('"+cString+"') }" } )	// "O objetivo deste painel � demonstrar os indicadores de capta��o de pedidos de venda. Apresenta as seguintes informacoes no dia e dentro do mes: Quantidade de pedidos de venda, quantidade de clientes com pedidos de venda, valor total dos pedidos e desconto total dos pedidos. A data considerada para o filtro foi a data de emissao do pedido. Nao sao considerados pedidos do tipo B e D."
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005 ;	// "Carteira de Pedidos de Venda"
	DESCR STR0005 ;	// "Carteira de Pedidos de Venda"
	TYPE 2 ;
	ONLOAD "FATP030" ;
	REFRESH 300 ;
	DEFAULT 1 ;	      
	TOOLBAR aToolBar ;	
	NAME "3";
	TITLECOMBO STR0006;	// "Periodo"
	PYME

Return                                   
