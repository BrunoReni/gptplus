#INCLUDE "Protheus.ch"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � M100LCT  � Autor � Luciana Pires� Data � 06.09.11  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do imposto LCT nas notas de entrada para Austr�lia                          ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Austr�lia                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function M100LCT(cCalculo,nItem,aInfo)
Local aImp 		:= {}
Local aItem 		:= {}
Local aArea		:= GetArea()
Local	 aImpRef	:= {}
Local	 aImpAliq	:= {}
Local aImpVal	:= {}

Local cImp			:= ""
Local cProd		:= ""
Local cTipo		:= ""

Local nMinLCT1	:= SuperGetMV("MV_LCTMIN1",,57466) //M�nimo Comum
Local nMinLCT2	:= SuperGetMV("MV_LCTMIN2",,75375)	//M�nimo Baixo consumo
Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local nImp			:= 0
Local nBase		:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0
Local nAliqGST	:= 0
Local nValGST	:= 0
Local nI				:= 0

Local xRet	

Local lxFis	:=	(MafisFound() .And. ProcName(1)!="EXECBLOCK")
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
�         ser� calculado  (funcao a100TexXIp -> fonte LOCXFUN.prx).                                       �
�����������������������������������������������������������������
*/

If !lXFis
   aItem		:= ParamIxb[1]
   aImp		:= ParamIxb[2]
   cImp		:= aImp[01]
   cProd 	:= SB1->B1_COD
Else
   cImp		:= aInfo[01]
   cProd		:= MaFisRet(nItem,"IT_PRODUTO")
Endif
                                   
//���������������������������������������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
	If  (SBI->(FieldPos("BI_TPLCT")) > 0) 
		cTipo := SBI->BI_TPLCT
	Endif
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	If  (SB1->(FieldPos("B1_TPLCT")) > 0) 
		cTipo := SB1->B1_TPLCT
	Endif
Endif    
               
//�����������������������������������������������������������������Ŀ
//�Busca a aliquota padrao para o imposto �
//�������������������������������������������������������������������
DbSelectArea("SFB")    
SFB->(DbSetOrder(1))
If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

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

	//����������������������������������������������������������Ŀ
	//�Localiza a al�quota e o valor do GST. 
	//������������������������������������������������������������
	nPos  := aScan(aItem[6],{|x| SubStr(x[1],1,2) $ "GS" })
	If nPos > 0
		nAliqGST 	:= aItem[6,nPos,2]   	//Aliquota
		nValGST 	:= aItem[6,nPos,4]		//Valor
	EndIf

	//�������������������������������������������������������������Ŀ
	//�Verifica se pelo m�nimo (e se tiver GST), o LCT dever� ser calculado ou n�o                              �
	//���������������������������������������������������������������
	If nValGST > 0 .And. cTipo <> "3" 
        If cTipo == "1" .And. aImp[03] > nMinLCT1    								//Tipo Comum
			aImp[03]	-= nMinLCT1															//Tenho que excluir o m�nimo da base
			aImp[03]	:= Round(aImp[03] /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a al�quota do LCT				
			aImp[04]	:= Round(aImp[03] * aImp[02]/100,nDecs)
		ElseIf  cTipo == "2" .And. aImp[03] > nMinLCT2   							//Tipo Baixo Consumo
			aImp[03]	-= nMinLCT2															//Tenho que excluir o m�nimo da base
			aImp[03]	:= Round(aImp[03] /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a al�quota do LCT				
			aImp[04]	:= Round(aImp[03] * aImp[02]/100,nDecs)					
		Else
			// Se n�o atingir o m�nimo o LCT n�o � calculado
			aImp[02]	:= 0	//Aliquota
			aImp[03] 	:= 0	//Base
			aImp[04] 	:= 0	//Imposto			              
		Endif
	Else	   
		// Neste caso o LCT n�o � calculado
		aImp[02]	:= 0	//Aliquota
		aImp[03] 	:= 0	//Base
		aImp[04] 	:= 0	//Imposto			              
	Endif

	//�������������������������������������������������������Ŀ
	//�Retorna um array com base [3], aliquota [2] e valor [4]�
	//���������������������������������������������������������
	xRet:=aImp   
Else
	nBase:=MaFisRet(nItem,"IT_VALMERC")
	
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

	//����������������������������������Ŀ
	//�Localiza a liquota e o valor do imposto do GST            �
	//������������������������������������
	aImpRef		:= MaFisRet(nItem,"IT_DESCIV")
	aImpAliq	:= MaFisRet(nItem,"IT_ALIQIMP")   
	aImpVal		:= MaFisRet(nItem,"IT_VALIMP")
	For nI:=1 to Len(aImpRef)
		If !Empty(aImpRef[nI])
			If "GS"$Alltrim(aImpRef[nI][1])
				nAliqGST	:= aImpAliq[nI]  
				nValGST	:= aImpVal[nI]
			Endif
		Endif
	Next

	//�������������������������������������������������������������Ŀ
	//�Verifica se pelo m�nimo (e se tiver GST), o LCT dever� ser calculado ou n�o                              �
	//���������������������������������������������������������������
	If nValGST > 0 .And. cTipo <> "3"
        If cTipo == "1" .And. nBase > nMinLCT1    							//Tipo Comum
			nBase	-= nMinLCT1														//Tenho que excluir o m�nimo da base
			nBase	:= Round(nBase /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a al�quota do LCT				
			nImp		:= Round(nBase * nAliq/100,nDecs)
		ElseIf  cTipo == "2" .And. nBase > nMinLCT2   					//Tipo Baixo Consumo
			nBase	-= nMinLCT2														//Tenho que excluir o m�nimo da base
			nBase	:= Round(nBase /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a al�quota do LCT				
			nImp		:= Round(nBase * nAliq/100,nDecs)
		Else
			// Se n�o atingir o m�nimo o LCT n�o � calculado
			nBase	:= 0
			nALiq 	:= 0
			nImp	 	:= 0
		Endif			              
	Else	   
		// Neste caso o LCT n�o � calculado
		nBase	:= 0
		nALiq 	:= 0
		nImp	 	:= 0			              
	Endif

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
