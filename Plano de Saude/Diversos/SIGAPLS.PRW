#IFDEF PROTHEUS
	#define cVerAdv  "99"
	#define cResAdv  "ADVB"
#ELSE
	#define cVerAdv	"99"
	#define cResAdv	"ADVA"
#ENDIF
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SIGAPLS   �Autor  �Microsiga           � Data �  02/25/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#include "sigapls.ch"
#include "PROTHEUS.ch"
//#include "Siga.ch"

#define TAB   Chr( 9 )
#define SRCPAINT	 15597702	// 0xEE0086
#define SRCAND 	  8913094



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � WriteDbg � Autor � Ary Medeiros		    � Data � 05/07/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao auxiliar para Depuracao 24 Horas					  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGA24 - Compilar com /dDEBUG 							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#IFDEF DEBUG
	 Function WriteDbg(cFunction,cValor)
	 FWrite(nDebug,cFunction+": "+cValor+CHR(13)+CHR(10))
	 Return nil
#ENDIF


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AbrePLS  � Autor � Ary Medeiros          � Data � 05/07/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao auxiliar														  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAPLS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AbrePLS()

//����������������������������������������������������������������������Ŀ
//� Inicializa variaveis padroes do sistema										 �
//������������������������������������������������������������������������
MV_RELT	 := __RELDIR
MV_CENT	 := GetMV("MV_CENT")
MV_MILHAR := GetMV("MV_MILHAR")



//����������������������������������������������������������������������Ŀ
//� Inicializa o simbolo das moedas 												 �
//������������������������������������������������������������������������
MV_SIMB1 := GetMV("MV_SIMB1")
MV_SIMB2 := GetMV("MV_SIMB2")
MV_SIMB3 := GetMV("MV_SIMB3")
MV_SIMB4 := GetMV("MV_SIMB4")
MV_SIMB5 := GetMV("MV_SIMB5")

//����������������������������������������������������������������������Ŀ
//� Verifica se lotes estao com validade vencida								 �
//������������������������������������������������������������������������
If GETMV("MV_LOTVENC") == "N" .And. GETMV("MV_RASTRO") == "S"
	Processa({|lEnd| BloqData()},OemToAnsi(STR0004),OemToAnsi(STR0005),.F.) //"Verificando Data de Validade dos Lotes"###"Verificando Lotes com data de validade vencida ..."
EndIf
Return Nil


