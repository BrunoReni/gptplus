#Include "PanelOnLine.ch" 
#Include "QIEPGONL.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QIEPGOnl � Autor � Cicero Cruz           � Data � 28/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Painel de Gestao On-line - Ambiente Inpe��o de Entradas    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIEPGOnl(ExpO1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = obj do proces.                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAQIE                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Function QIEPGOnl(oPGOnline)

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0002; 					//"Indice de Qualidade Fornecedor X Produto"  	
	DESCR STR0002+" - "+STR0001; 	// "Indice de Qualidade Fornecedor X Produto"###"Inspe��o de Entradas"
	TYPE 2; 				
	PARAMETERS "QEP010";
	ONLOAD "QIEP010"; 		
	REFRESH 600; 			
	DEFAULT 1; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "1" 				

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0004; 					// "Resultados por Fornecedor X Produto "  	
	DESCR STR0004+" - "+STR0001; 	// "Resultados por Fornecedor X Produto "###"Inspe��o de Entradas"
	TYPE 2;
	PARAMETERS "QEP020";
	ONLOAD "QIEP020"; 		
	REFRESH 600; 			
	DEFAULT 1; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "2"

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0005; 					// "Entradas Inspecionadas/� Inspecionar"  	
	DESCR STR0005; 					// "Entradas Inspecionadas/� Inspecionar"
	TYPE 5; 				
	PARAMETERS "QEP030";
	ONLOAD "QIEP030"; 		
	REFRESH 3600; 			
	DEFAULT 5; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "3"

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0006; 					// "N�o-Conformidades X Fornecedor"  	
	DESCR STR0006+" - "+STR0001; 	// "N�o-Conformidades X Fornecedor"###"Inspe��o de Entradas"
	TYPE 2;
	PARAMETERS "QEP040";
	ONLOAD "QIEP040"; 		
	REFRESH 600; 			
	DEFAULT 1; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "4"
			
Return	
