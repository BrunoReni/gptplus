#INCLUDE "CTBR818.CH"
#Include "PROTHEUS.Ch"
#INCLUDE "tdsBirt.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR818  � Autor � Jonathan Gonzalez     � Data � 30.12.14   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Demonstracao das origens e aplicacoes de recursos (BIRT)     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR818()                                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���jonathan glz�08/09/2015�TTHAMD�Se cambia la forma de imprimir el archivo ���
���            �          �      �Termino Auxiliares para que no permita    ���
���            �          �      �imprimir archivo mayoresa 2 mil caracteres���
���            �          �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CTBR818()
	Local cPerg	:= "CTR520"

		Help(" ",1,STR0032,,STR0031,1,0)  //Mensagem de descontinua��o e bloqueio a partir de 01/10/2022.
		
		If Date() >= CTOD("01/10/2022")
			Return
		Endif

		if Pergunte(cPerg,.T.)
			If mv_par06 == 1 //Valida si se imprimira el saldo anterior
				DEFINE REPORT oRPT NAME CTBR818 TITLE STR0001 EXCLUSIVE //ESTADO DE ORIGENES E INVERSIONES DE RECURSOS
				ACTIVATE REPORT oRPT
			Else
				DEFINE REPORT oRPT NAME CTBR818a TITLE STR0001 EXCLUSIVE //ESTADO DE ORIGENES E INVERSIONES DE RECURSOS
				ACTIVATE REPORT oRPT
			EndIf
		EndIf
RETURN

