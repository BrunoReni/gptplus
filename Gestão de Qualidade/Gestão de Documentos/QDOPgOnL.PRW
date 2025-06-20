#Include "PanelOnLine.ch"
#include "QDOPGOnl.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QDOPGOnl � Autor � Rafael S. Bernardi    � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Painel de Gestao On-line - Modulo SIGAQDO                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCPGOnl(ExpO1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = obj do proces.                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAQDO                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QDOPGOnl(oPGOnline)
Local aToolBar  := {} 
Local aToolBar2 := {}
Local aToolBar3 := {}
Local cHelp     := ""
Local cHelp2    := ""
Local cHelp3    := ""

cHelp := STR0004//"O sistema ira apresentar um grafico de barras com a quantidade de documentos "
cHelp += STR0005//"de acordo com a situacao em que se encontram no momento."

aToolBar:= {}
Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )
         
// Posic��o dos Documentos
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //"Posi��o dos Documentos" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0001 ; //"Posi��o dos Documentos" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	ONLOAD "QDOP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usu�rio sobre o resultado do painel
	DEFAULT 3	 ; //-- Default do Combo
	NAME "1" //--Ordem de Exibicao

cHelp2 := STR0006//"O sistema apresentar ira uma lista dos documentos vencidos e a vencer de acordo "
cHelp2 += STR0007//"com o intervalo determinado pelo usuario."

aToolBar2:= {}
Aadd( aToolBar2, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp2+'")) }') } )

// "Documentos Vencidos e a Vencer"
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002; //"Documentos Vencidos e a Vencer"
	DESCR STR0002 ; //"Documentos Vencidos e a Vencer"
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QDOP20" ;                   
	ONLOAD "QDOP020" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar2 ;//--Help que sera apresentado ao usu�rio sobre o resultado do painel
	DEFAULT 1 ; //-- Default do Combo
	NAME "2" //--Ordem de Exibicao
	
cHelp3 := STR0008//"O sistema ira apresentar as pendencias do documentos em duas dimensoes: "
cHelp3 += STR0009//"1� Pendentes por fase de elaboracao / 2� Avisos Pendentes."

aToolBar3:= {}
Aadd( aToolBar3, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp3+'")) }') } )

// Documentos Pendentes
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003; //"Documentos Pendentes"
	DESCR STR0003 ; //"Documentos Pendentes"
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "QDOP30" ;                   
	ONLOAD "QDOP030" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar3 ;//--Help que sera apresentado ao usu�rio sobre o resultado do painel
	DEFAULT 1 ; //-- Default do Combo
	NAME "3" //--Ordem de Exibicao
Return