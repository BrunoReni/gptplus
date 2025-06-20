#INCLUDE "PROTHEUS.CH"
#INCLUDE "tdsBirt.CH"
#INCLUDE "FINR085P.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR085P � Autor � Jonathan Gonzalez     � Data � 26.05.14   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imp. de ordenes de pago en BIRT , de acuerdo a los           ���
���          � parametros que el usuario define.                            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR085P()                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                      ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
��� Marco A.   �07/04/2021�DMINA-�Se retira funcion ModelDef, ya que no es  ���
���            �          � 11817�necesaria en la estructura del Report.    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
FUNCTION FINR085P()
	//llamada a funcion para crear imagen IMG_FRANJA.BMP
	CreaImage()

	//������������������������������������������������������������������������������
	//SE COMIENZA A IMPRIMIR EL REPORTE Y SE LE ASIGNAN LOS PARAMETROS QUE SERAN
	//USADOS EN EL DATASET, PARA PODER FILTRAR LOS DATOS DE IMPRESION.
	//������������������������������������������������������������������������������
	If cPaisLoc == "ARG"
		DEFINE REPORT oRPT NAME FINR085PA TITLE STR0002  EXCLUSIVE
	Else
		DEFINE REPORT oRPT NAME FINR085P TITLE STR0002  EXCLUSIVE
	Endif

	ACTIVATE REPORT oRPT

RETURN