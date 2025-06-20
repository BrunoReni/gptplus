#include "SIGAWIN.CH"        
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _VLRTOTAL  3

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �   M100ISE  � Autor � Armando Waiteman� Data �   08/08/00  ���
�������������������������������������������������������������������������͹��
���                CALCULO DO IMPOSTO SOBRE SERVICOS                      ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � M100ISE                                                   ���
�������������������������������������������������������������������������͹��
��� Parametros�                                         			      ���
�������������������������������������������������������������������������͹��
��� Retorno   � aImposto                                                  ���
�������������������������������������������������������������������������͹��
��� Uso       � MATA10x, LOJA010 e LOJA220, chamado pelo ponto de entrada ���
�������������������������������������������������������������������������͹��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������͹��
���Programador� Data   � BOPS �  Motivo da Alteracao                      ���
�������������������������������������������������������������������������͹��
��� Nava      �31/07/01�      � Reescrito pela funcao GetCountryList.     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100ISE()

LOCAL cFunct
LOCAL aRet
LOCAL aArea
LOCAL aCountry // Array de Paises nesta forma : // { { "BRA" , "Brasil", "BR" } , { "ARG" , "Argentina","AR"} ,

aArea		:= GetArea()
aCountry	:= GetCountryList()
cFunct	:= "M100ISE" + aCountry[Ascan( aCountry, { |x| x[1] == cPaisLoc } )][3] // retorna pais com 2 letras
aRet		:= &( cFunct )()

RestArea( aArea )

RETURN aRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �  M100ISECR � Autor � Nava            � Data �   31/07/01  ���
�������������������������������������������������������������������������͹��
���                CALCULO DO IMPOSTO SOBRE SERVICOS COSTA RICA           ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � M100ISECR                                                 ���
�������������������������������������������������������������������������͹��
��� Parametros�                                         			      ���
�������������������������������������������������������������������������͹��
��� Retorno   � aImposto                                                  ���
�������������������������������������������������������������������������͹��
��� Uso       � MATA10x, LOJA010 e LOJA220, chamado pelo ponto de entrada ���
�������������������������������������������������������������������������͹��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������͹��
���Programador� Data   � BOPS �  Motivo da Alteracao                      ���
�������������������������������������������������������������������������͹��
��� Nava      �31/07/01�      � Desenvolvimento inicial                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100ISECR()

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
	If SFB->( DbSeek( xFilial("SFB")+cImp ) )
		aImposto[_ALIQUOTA]  := SFB->FB_ALIQ         //Aliquota do imposto
		aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL] //Base de calculo
		aImposto[_IMPUESTO]  := Round(aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100) ,2)
	Endif
EndIf

Return( aImposto )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �  M100ISERD � Autor � Armando Waiteman� Data �   08/08/00  ���
�������������������������������������������������������������������������͹��
���       CALCULO DO IMPOSTO SOBRE SERVICOS REPUBLICA DOMINICANA          ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � M100ISERD                                                 ���
�������������������������������������������������������������������������͹��
��� Parametros�                                         			      ���
�������������������������������������������������������������������������͹��
��� Retorno   � aImposto                                                  ���
�������������������������������������������������������������������������͹��
��� Uso       � MATA10x, LOJA010 e LOJA220, chamado pelo ponto de entrada ���
�������������������������������������������������������������������������͹��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������͹��
���Programador� Data   � BOPS �  Motivo da Alteracao                      ���
�������������������������������������������������������������������������͹��
��� Armando   �08/08/00�      � Desenvolvimento inicial                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100ISERD()

Local lRet 
Local cArea
Local aItemINFO  := ParamIxb[1]
Local aImposto   := ParamIxb[2]

cArea:=GetArea()

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
	DbSelectArea("SFB")
	DbSetOrder(1)
	If DbSeek(xFilial("SFB")+aImposto[1])
		aImposto[_ALIQUOTA]  := SFB->FB_ALIQ         //Aliquota do imposto
		aImposto[_BASECALC]  := aItemINFO[_VLRTOTAL] //Base de calculo
		aImposto[_IMPUESTO]  := Round(aImposto[_BASECALC] * ( aImposto[_ALIQUOTA]/100) ,2)
	Endif
EndIf
	

RestArea(cArea)

Return( aImposto )