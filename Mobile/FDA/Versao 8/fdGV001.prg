#INCLUDE "FDGV001.ch"
#include "eADVPL.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GerenciaVendas()    �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Inicia o Modulo de Gerenciamento do Vendedor	 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GerenciaVendas()
Local oDlg, oLbx, aConsultas := {}, nItem := 1, oExec, oCancel

AADD(aConsultas,STR0001) //"Maiores clientes"
AADD(aConsultas,STR0002) //"Clientes mais visitados"
AADD(aConsultas,"Produtos mais vendidos")
AADD(aConsultas,STR0003) //"Vendas acumuladas no m�s"
AADD(aConsultas,STR0004) //"Clientes inativos"

DEFINE DIALOG oDlg TITLE STR0005  //"Gerenciamento do Vendedor"

@ 20,02 SAY STR0006 BOLD OF oDlg //"Selecione a consulta desejada:"
@ 35,02 LISTBOX oLbx VAR nItem ITEM aConsultas SIZE 155,100 OF oDlg

@ 142,15 BUTTON oExec CAPTION STR0007 SIZE 50,15 ACTION GVExec(nItem) OF oDlg //"Abrir"
@ 142,90 BUTTON oCancel CAPTION STR0008 SIZE 50,15 ACTION CloseDialog() OF oDlg //"Sair"

ACTIVATE DIALOG oDlg

Return nil            

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GVBigger()		   �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �  Maiores Clientes							 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GVBigger()
Local oDlg, oBrw, oBtn

DEFINE DIALOG oDlg TITLE STR0001 //"Maiores clientes"

@ 20,5 BROWSE oBrw SIZE 150,115 OF oDlg
@ 140,48 BUTTON oBtn CAPTION STR0008  ACTION CloseDialog() SIZE 65,15 OF oDlg //"Sair"

ACTIVATE DIALOG oDlg 

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GVVisited()		   �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �  Mais visitados   							 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GVVisited()
Local oDlg, oBrw, oBtn

DEFINE DIALOG oDlg TITLE STR0002 //"Clientes mais visitados"

@ 20,5 BROWSE oBrw SIZE 150,115 OF oDlg
@ 140,48 BUTTON oBtn CAPTION STR0008  ACTION CloseDialog() SIZE 65,15 OF oDlg //"Sair"

ACTIVATE DIALOG oDlg 

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GVSeller()		   �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �  Produtos mais vendidos						 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GVSeller()
Local oDlg, oBrw, oBtn

DEFINE DIALOG oDlg TITLE STR0009 //"Produtos mais vendidos"

@ 20,5 BROWSE oBrw SIZE 150,115 OF oDlg
@ 140,48 BUTTON oBtn CAPTION STR0008  ACTION CloseDialog() SIZE 65,15 OF oDlg //"Sair"

ACTIVATE DIALOG oDlg 

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GVSales()		   �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �  Vendas Acumuladas    						 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GVSales()
Local oDlg, oBrw, oBtn

DEFINE DIALOG oDlg TITLE STR0003 //"Vendas acumuladas no m�s"

@ 20,5 BROWSE oBrw SIZE 150,115 OF oDlg
@ 140,48 BUTTON oBtn CAPTION STR0008  ACTION CloseDialog() SIZE 65,15 OF oDlg //"Sair"

ACTIVATE DIALOG oDlg 

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GVInactive()		   �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �  Clientes Inativos    						 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GVInactive()
Local oDlg, oBrw, oBtn

DEFINE DIALOG oDlg TITLE STR0004 //"Clientes inativos"

@ 20,5 BROWSE oBrw SIZE 150,115 OF oDlg
@ 140,48 BUTTON oBtn CAPTION STR0008  ACTION CloseDialog() SIZE 65,15 OF oDlg //"Sair"

ACTIVATE DIALOG oDlg 

Return nil