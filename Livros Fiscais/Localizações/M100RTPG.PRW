#include "SIGAWIN.CH"

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������͸��
���Funcao    �                   M100ITB                 �Data  18/06/2001   ���
����������������������������������������������������������������������������Ĵ��
���Descricao �Executa a funcao propria a cada pais para o calculo do IVA     ���
����������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function M100RTPG()
Local aRet:={}  
Local cFunc
Local cAreaAtu

cAreaAtu:=GetArea()

cFunc:="M100RTPG"+left(cPaisLoc,2)
cFunc:=cFunc+"()"
aRet:=&(cFunc)


RestArea(cAreaAtu)

return(aRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �M100RETPAG� Autor � Armando P. Waiteman  � Data � 02.12.1999 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � CALCULO DO VALOR DE RETENCAO NA ORDEM DE PAGTO              ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
STATIC FUNCTION M100RTPGDO()
Local aImp,aItem
Local nBase:=0,nAliq:=0

If MafisFound()
   Return
Endif 

/*
���������������������������������������������������������������Ŀ
� A variavel ParamIxb tem como conteudo um Array[2,?]:          �
�                                                               �
� [1,1] > Quantidade Vendida                     		        �
� [1,2] > Preco Unitario                            	        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,?] > Array aImposto, Contendo as Informa�oes do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/
aItem:=ParamIxb[1]
aImp:=ParamIxb[2]
   If SFB->(dbseek(xfilial("SFB")+aImp[1]))
      nAliq:=SFB->FB_ALIQ
   endif

nBase:=aItem[3]

aImp[02]:=nAliq
aImp[03]:=nBase
aImp[04]:=(nAliq * nBase)/100

RETURN(aImp)
