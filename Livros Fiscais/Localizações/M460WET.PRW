#INCLUDE "Protheus.ch"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � M460WET  � Autor � Luciana Pires� Data � 06.12.11  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do imposto WET nas notas de sa�da para Austr�lia                          ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Austr�lia                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function M460WET(cCalculo,nItem,aInfo)
Local aImp 		:= {}
Local aItem 		:= {}
Local aArea		:= GetArea()

Local cImp			:= ""
Local cProd		:= ""
Local cConcept := ""

Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local nImp			:= 0
Local nBase		:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0
Local nPerc		:= 0

Local xRet

Local lxFis			:=	(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

/*
���������������������������������������������������������������Ŀ
� Observacao :                                                  �
�                                                               �
� a variavel ParamIxb tem como conteudo um Array[2], contendo : �
� [1,1] > Quantidade Vendida                                    �
� [1,2] > Preco Unitario                                        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete rateado para este Item ...             �
� [1,5] > Valor das Despesas rateado para este Item...          �
� [1,6] > Array Contendo os Impostos j� calculados, no caso de  �
�        incid�ncia de outros impostos.                         �
� [2,1] > Array aImposto, Contendo as Informa��es do Imposto que�
�         ser� calculado (funcao a460TexXIp -> fonte LOCXFUN.prx).                                       �
�����������������������������������������������������������������
*/

If !lXFis
   	aItem	:= ParamIxb[1]
   	aImp		:= ParamIxb[2]
	xRet     := ParamIxb[2]
   	cImp		:= aImp[01]
   	cProd 	:= SB1->B1_COD
Else
	xRet		:= 0
   	cImp		:= aInfo[01]
   	cProd	:= MaFisRet(nItem,"IT_PRODUTO")   
Endif           

                                 
//���������������������������������������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
Endif    
                         
//�����������������������������������������������������������������Ŀ
//�Guardo o conceito do produto�
//�������������������������������������������������������������������
If (SB1->(FieldPos("B1_CONWET")) > 0 .And. !Empty(SB1->B1_CONWET))				                                              
	cConcept := SB1->B1_CONWET
Endif
               
//�����������������������������������������������������������������Ŀ
//�Busca a aliquota padrao para o imposto �
//�������������������������������������������������������������������
DbSelectArea("SFB")    
SFB->(DbSetOrder(1))
If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

//�����������������������������������������������������������������Ŀ
//�Busca / posiciono a aliquota atrav�s da CCR �
//�������������������������������������������������������������������
dbSelectArea("CCR")
CCR->(dbSetOrder(3))	//CCR_FILIAL+CCR_CONCEP+CCR_IMP+CCR_PAIS
If CCR->(dbSeek(xFilial("CCR")+cConcept+cImp))
	If !Empty(CCR->CCR_ALIQ)
		nAliq 	:= CCR->CCR_ALIQ
		nPerc	:= CCR->CCR_PERC
	EndIf
EndIf

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
        
If !lXFis
	aImp[02] := nAliq
	aImp[03] := aItem[03]+aItem[04]+aItem[05]

	//����������������������������������������������������������������������Ŀ
	//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
	//������������������������������������������������������������������������
	If Subs(aImp[05],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		aImp[03]	-= aImp[18]
	Endif
	
	aImp[04] 	:= Round(aImp[03] * (nAliq/100),nDecs)	                                                             
  
	//�������������������������������������������������������Ŀ
	//�Retorna um array com base [3], aliquota [2] e valor [4]�
	//���������������������������������������������������������
	xRet:=aImp   
Else
	nBase	:= MaFisRet(nItem,"IT_VALMERC")
	
	//����������������������������������������������������������������������Ŀ
	//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
	//������������������������������������������������������������������������
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
		If SFC->FC_LIQUIDO=="S"
			nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
		Endif
	Endif
	
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))

	nImp := Round(nBase * (nAliq/100),nDecs)
  
	//�������������������������������������������������������������Ŀ
	//�Retorna o valor solicitado pela MatxFis (parametro cCalculo):�
	//�A = Aliquota de calculo                                      �
	//�B = Base de calculo                                          �
	//�V = Valor do imposto                                         �
	//���������������������������������������������������������������
	
	Do Case
	Case cCalculo=="B"
		xRet:=nBase
	Case cCalculo=="A"
		xRet:=nALiq
	Case cCalculo=="V"
		xRet:=nImp
	EndCase
EndIf
RestArea(aArea)
	
Return(xRet)
            