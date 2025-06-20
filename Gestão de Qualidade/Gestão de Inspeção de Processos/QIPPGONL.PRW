#Include "PanelOnLine.ch"
#include "QIPPGOnl.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QIPPGOnl � Autor � Rafael S. Bernardi    � Data �17/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Painel de Gestao On-line - Modulo SIGAQIP                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIPPGOnl(ExpO1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = obj do proces.                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAQIP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QIPPGOnl(oPGOnline)
Local aToolBar  := {} 
Local aToolBar2 := {}
Local cHelp     := ""
Local cHelp2    := ""

         
cHelp := STR0005//"O sistema ira listar a(s) ordem(s) de producao e seu status em relacao "
cHelp += STR0006//"ao resultado (Inspecionada / A Inspecionar)."

aToolBar:= {}
Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - Ordens de produ��o inspecionadas / a inspecionar
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //"Ordens de produ��o inspecionadas / a inspecionar" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0001 ; //"Ordens de produ��o inspecionadas / a inspecionar" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QIPP10" ; //--Grupo de Perguntas
	ONLOAD "QIPP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usu�rio sobre o resultado do painel
	DEFAULT 5	 ; //-- Default do Combo
	NAME "1" //--Ordem de Exibicao
	
cHelp2 := STR0007//"O sistema ira apresentar uma lista no estilo de ranking com duas dimesoes: "
cHelp2 += STR0008//"1� = quantidade de nao-conformidades por classe / "
cHelp2 += STR0009//"2� = quantidade de nao-conformidades por produto"

aToolBar2:= {}
Aadd( aToolBar2, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp2+'")) }') } )
	
PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0002; // "N�o-Conformidades X Produtos"  	
	DESCR STR0002+" - "+STR0003; 	// "N�o-Conformidades X Produtos"###"Inspe��o de Processos"
	TYPE 2;  
	PARAMETERS "QIP020";
	ONLOAD "QIPP020"; 		
	REFRESH 600;
	TOOLBAR aToolBar2 ;//--Help que sera apresentado ao usu�rio sobre o resultado do painel
	DEFAULT 1; 			
	TITLECOMBO STR0004; 			//"Analisar : "
	NAME "2"
	
Return