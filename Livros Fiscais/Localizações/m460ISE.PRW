#include "SIGAWIN.CH"        
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �   M460ISE  � Autor � Armando Waiteman� Data �   08/08/00  ���
�������������������������������������������������������������������������͹��
���                CALCULO DO IMPOSTO SOBRE SERVICOS                      ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � M460ISE                                                   ���
�������������������������������������������������������������������������͹��
��� Parametros�                                         			      ���
�������������������������������������������������������������������������͹��
��� Retorno   � aImposto                                                  ���
�������������������������������������������������������������������������͹��
��� Uso       � MATA46x, LOJA010 e LOJA220, chamado pelo ponto de entrada ���
�������������������������������������������������������������������������͹��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������͹��
���Programador� Data   � BOPS �  Motivo da Alteracao                      ���
�������������������������������������������������������������������������͹��
��� Nava      �01/08/01�      � Reescrito pela funcao GetCountryList.     ���
���           �        �      �                                           ���
���           �        �      �                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M460ISE()

LOCAL cFunct
LOCAL aRet
LOCAL aArea
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,

aArea		:= GetArea()
aCountry	:= GetCountryList()
cFunct	:= "M460ISE" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet		:= &( cFunct )()

RestArea( aArea )

RETURN aRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M460ISERD� Autor � Leonardo Ruben       � Data � 08.08.2000 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � CALCULO DO IMPOSTO SOBRE SERVICOS PARA Republica Dominicana ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Localizacoes                                                ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function M460ISERD()

Local aItemINFO:= ParamIxb[1]
Local aImposto	:= ParamIxb[2]
Local aArea		:= GetArea()

If cModulo == 'FAT'                         
   cAgeRet    := SA1->A1_RETIVA
Else
   cAgeRet    := SA2->A2_RETIVA
Endif


//������������������������������������Ŀ
//�Verifica se e agente de retencao    �
//��������������������������������������
lRet := (cAgeRet=="1")  // sim

If lRet
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+aImposto[1])
       aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
       aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]
	   aImposto[_IMPUESTO]  := Round(aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100) ,2)
    EndIf
EndIf

RestArea(aArea)

Return( aImposto )                 

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao	 � M460ISECR� Autor � Marcello Navarro     � Data � 06.08.2001 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � CALCULO DO IMPOSTO SOBRE SERVICOS PARA Costa Rica           ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Localizacoes                                                ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Function M460ISECR()

LOCAL cImp
LOCAL lXFis	:= MafisFound()
LOCAL lCalc1:= .F.

If !lXfis
   aItemInfo:= ParamIxb[1]
   aImposto	:= ParamIxb[2]
   cImp		:= aImposto[1]
Else
	cImp	:= aInfo[1]
Endif           

If cModulo $ "FAT|LOJA|FRT|TMK"
	If SA1->A1_TIPO <> "2"
	   lCalc1 := .T.
	Endif
Else
	If SA2->A2_TIPO <> "2"
	   lCalc1 := .T.
	Endif
Endif

If lCalc1
	If SFB->( DbSeek(xFilial("SFB")+cImp ) )
		aImposto[_ALIQUOTA]  := SFB->FB_ALIQ
		aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL]
		aImposto[_IMPUESTO]  := Round(aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100) ,2)
    EndIf
EndIf

Return( aImposto )                 
