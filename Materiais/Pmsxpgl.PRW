#include "pmsxpgl.ch"
#include "PanelOnLine.ch"
#include "Protheus.Ch"
#include "pmsicons.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �PMSPGOnl  � Autor � Ana Paula N. Silva    � Data � 15/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o dos paineis de gest�o PMS                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PMSPgOnl                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAPMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PMSPGOnl(oPGOnline)

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0001; //"Recursos maior aloc. mes"
	DESCR STR0001; //"Recursos maior aloc. mes"
	TYPE 1;    
	PARAMETERS 'PMSOL1';
 	ONLOAD "PMSLOnl01";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0008+"') }"}}; //"Lista a qtde. de apontamentos dos recursos(c�digo e descri��o) por ordem decrescente de apontamento."
	NAME "PmsLOnl01"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0002; //"Projetos com data de entrega proxima"
	DESCR STR0002; //"Projetos com data de entrega proxima"
	TYPE 1;    
	PARAMETERS 'PMSOL2';
 	ONLOAD "PMSLOnl02";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0009+"') }"}}; //"Lista os projetos em aberto com a data prevista de t�rmino pr�xima."
	NAME "PMSLOnl02"
               
PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0003; //"Projetos com data de inicio proxima"
	DESCR STR0003; //"Projetos com data de inicio proxima"
	TYPE 1;    
	PARAMETERS 'PMSOL03';
 	ONLOAD "PMSLOnl03";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0010+"') }"}}; //"Lista os projetos em aberto com a data prevista de in�cio pr�xima."
	NAME "PMSLOnl03"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0004; //"Maiores Consumos por Produto"
	DESCR STR0004; //"Maiores Consumos por Produto"
	TYPE 2;
	PARAMETERS "PMSOL04";
 	ONLOAD "PMSLOnl04";
	REFRESH 300;
	DEFAULT 1;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0011+"') }"}}; //"Lista os projetos e as maiores quantidades consumidas por produto."
	NAME "PMSLOnl04";
	TITLECOMBO STR0005 //"Produto"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0006; //"Recursos com mais Horas Previstas no Per�odo"
	DESCR STR0006; //"Recursos com mais Horas Previstas no Per�odo"
	TYPE 1;    
	PARAMETERS "PMSOL05";
 	ONLOAD "PMSLOnl05";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0012+"') }"}}; //"Lista os recursos e a quantidade de horas que est�o alocados dentro do per�odo em ordem decrescente."
	NAME "PMSLOnl05"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0007; //"Equipes com mais Horas Alocadas no Per�odo"
	DESCR STR0007; //"Equipes com mais Horas Alocadas no Per�odo"
	TYPE 1;
	PARAMETERS "PMSOL06";
 	ONLOAD "PMSLOnl06";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0013+"') }"}}; //"Lista as equipes e a quantidade de horas que est�o alocadas dentro do per�odo em ordem decrescente."
	NAME "PMSLOnl06"

Return

