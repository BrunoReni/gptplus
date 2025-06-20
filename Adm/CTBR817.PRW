#INCLUDE "PROTHEUS.CH"
#INCLUDE "tdsBirt.CH"
#INCLUDE "CTBR817.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR817  � Autor � Jonathan Gonzalez     � Data � 15.12.14   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imp. del relatorio flujo de caja en formato BIRT             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR817()                                                    ���
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
���Jonathan Glz�30/06/2017�MMI-  �Se cambia el grupo de preguntas se crean  ���
���            �          �  6119�los grupos CTBR817A y CTBR817B, se cambia ���
���            �          �      �las validaciones y el titulo del reporte. ���
���            �          �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
FUNCTION CTBR817()
	Local cPerg := "CTR817A"

	Private nMvPAR01 := 0
	Private nMvPAR02 := 0

	Help(" ",1,STR0054,,STR0053,1,0)  //Mensagem de descontinuacao e bloqueio a partir de 01/10/2022.

	If Date() >= CTOD("01/10/2022")
		Return
	Endif

		//chama a tela de perguntas
		Pergunte(cPerg,.T.)
		nMvPAR01 := MV_PAR01
		nMvPAR02 := MV_PAR02

		if nMvPAR01 == 1
			If nMvPAR02 == 2
                                                      //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: SI" " - Metodo: Indirecto"
				DEFINE REPORT oRPT NAME CTBR817 TITLE STR0002 + STR0049 + STR0052 EXCLUSIVE
				ACTIVATE REPORT oRPT
			Else
                                                      //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: SI" " - Metodo: Directo"
				DEFINE REPORT oRPT NAME CTBR817a TITLE STR0002 + STR0049 + STR0051 EXCLUSIVE
				ACTIVATE REPORT oRPT
			EndIf
		else
			If nMvPAR02 == 2
                                                      //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: NO" " - Metodo: Indirecto"
				DEFINE REPORT oRPT NAME CTBR817v TITLE STR0002 + STR0050 + STR0052 EXCLUSIVE
				ACTIVATE REPORT oRPT
			Else
                                                       //DEMOSTRACION DEL FLUJO DE CAJA " - Variacion: NO" " - Metodo: Directo"
				DEFINE REPORT oRPT NAME CTBR817av TITLE STR0002 + STR0050 + STR0051 EXCLUSIVE
				ACTIVATE REPORT oRPT
			EndIf
		endif
RETURN
