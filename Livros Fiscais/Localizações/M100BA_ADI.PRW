//Constantes utilizadas nas localizacoes

#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _IVAFLETE  12
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �M100BA_ADI  � Autor � Bruno Sobieski  � Data �   02/12/99  ���
�������������������������������������������������������������������������͹��
���                 Programa que calcula o IMEBA adicional 1 e 2          ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � M100BA_ADI                                                ���
�������������������������������������������������������������������������͹��
��� Parametros�                                         			           ���
���         1 � cCalculo                                                  ���
���         2 � nItem                                                     ���
���         3 � aInfo                                                     ���
�������������������������������������������������������������������������͹��
��� Retorno   � aImposto                                                  ���
�������������������������������������������������������������������������͹��
��� Uso       � MATA10x, LOJA010 e LOJA220                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100BA_ADI(cCalculo,nItem,aInfo)

local aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp
Local nBase:=0, nAliq:=0
Local nDecs
Local aAgreg	:=	{}
Local nX	:=	0
Local nAliqImpAtu	:=	0
Local nIndice	:=	0
Local cAgregBase	:=	""
Local aAreaSFB	:=	{}
Local aAreaSFC	:=	{}
Local aImpTmp	:=	{}
Local nPosImp	:=	0
lXFis	:=	MafisFound() 

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
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/

If !lXfis
   aItem:=ParamIxb[1]
   aImp:=ParamIxb[2]
   cImp:=aImp[1]
Else
	cImp:=aInfo[1]
Endif           

nVlFicto	:=	SB1->B1_VLFICTO

If cModulo == "FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp := Alltrim(SBI->BI_GRPEBA)
Else
	cGrp := Alltrim(SB1->B1_GRPEBA)
Endif

DbSelectArea("SFB")    // busca a aliquota padrao
If Dbseek(xFilial()+cImp)
   nAliqImpAtu:=SFB->FB_ALIQ
Endif

If !lXFis
	If nVlFicto >0 .And.aItem[1] > 0
		nBase	:=	nVlFicto*aItem[1]
	Else	
	   //nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	   nBase:=aItem[3]+aItem[5]  //valor total + outros impostos
	Endif
Else
	If nVlFicto >0 .And.MaFisRet(nItem,"IT_QUANT") > 0
		nBase	:=	nVlFicto*MaFisRet(nItem,"IT_QUANT")
	Else	
   //	   nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
     	nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
	Endif
Endif


If !lXFis
	nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
   aImp[_ALIQUOTA]	:=	nAliqImpAtu
   aImp[_BASECALC]	:=	nBase

   //Tira os descontos se for pelo liquido .Bruno
   If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
	    aImp[_BASECALC]	-=	aImp[18]
	    nBase				:=	aImp[_BASECALC]
   Endif

	//��������������������������������������������������������������������������������������������Ŀ
	//�Verificar se este imposto pertence a um grupo de impostos, para os quais as bases devem ser �
	//�calculadas em conjunto, se pertencer, calculo as aliquotas de cada um dos impostos do grupos�
	//�para poder estabelecer a base de c�lculo                                                    �
	//����������������������������������������������������������������������������������������������
	DbSelectArea('SFC')
	aAreaSFC	:=	GetArea()
	DbSelectArea('SFB')
	aAreaSFB	:=	GetArea()
	If !Empty(SFC->FC_AGRBASE) .And. nBase > 0
		cAgregBase	:=	SFC->FC_AGRBASE
		nIndAtu		:=	Val(SFC->FC_SEQ)	
		SFC->(DbSeek(xFilial("SFC")+SF4->F4_CODIGO ))
		While !EOF() .And. SFC->FC_FILIAL+SFC->FC_TES == xFilial("SFC")+SF4->F4_CODIGO 
			If cAgregBase	==	SFC->FC_AGRBASE
				AAdd(aAgreg,{SFC->FC_SEQ,SFC->FC_IMPOSTO})
			Endif
			SFC->(DbSkip())
		Enddo
		nAliq	:=	0
		For nX:= 1 To Len(aAgreg)
			nIndice	:=	Val(aAgreg[nX][1])
			If nIndice > nIndAtu			
				SFB->(MsSeek(xFilial()+aAgreg[nX][2]))	
				aImpTmp  := {}
				AAdd( aImpTmp , SFB->FB_CODIGO )
				AAdd( aImpTmp , 0.00 )                                   
				AAdd( aImpTmp , 0.00 )
				AAdd( aImpTmp , 0.00 )
				AAdd( aImpTmp, SFC->FC_INCDUPL + SFC->FC_INCNOTA + SFC->FC_CREDITA + If(Type("SFC->FC_LIQUIDO")=="C",SFC->FC_LIQUIDO,"S"))
				AAdd( aImpTmp, "D1_VALIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, "D1_BASIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, "F1_VALIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, "F1_BASIMP"+SFB->FB_CPOLVRO)
				AAdd( aImpTmp, SFC->FC_INCIMP )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, 0.00 )
				AAdd( aImpTmp, SFC->FC_CALCULO )
				AAdd( aImpTmp, aImp[16])
				AAdd( aImpTmp, SFB->FB_CPOLVRO )  // [17]-Campo do Livro Fiscal.
				AAdd( aImpTmp, 0 )
				AADD( aImpTmp, {1,-1,0} )        //[19] Define se imposto vai somar, subtrair ou indiferente
				aImpTmp := ExecBlock( cFileRdMk,.F.,.F., { aClone(aItem), aImpTmp,;
					0, "D1_VALIMP"+SFB->FB_CPOLVRO,0} ,.T. )
				nAliq	+=	aImpTmp[2]
			ElseIf nIndice ==nIndAtu			
				nAliq	+=	aImp[_ALIQUOTA]
			Else
			  	nPosImp	:= Ascan(aItem[6],{|x| x[1]==aAgreg[nX][2]})
			  	If nPosImp > 0
					nAliq	+=	aItem[6][nPosImp][2]
				Endif			  
			Endif               
		Next
	Endif	


	RestArea(aAreaSFC)
	RestArea(aAreaSFB)

   //+---------------------------------------------------------------+
   //� Efetua o Calculo do Imposto                                   �
   //+---------------------------------------------------------------+
   aImp[_BASECALC] 	:= aImp[_BASECALC] /(1+(nAliq/100))
   aImp[_IMPUESTO]	:= aImp[_BASECALC]*aImp[_ALIQUOTA]/100
   
   xRet	:=	aImp
Else
   //Tira os descontos se for pelo liquido
   nOrdSFC:=(SFC->(IndexOrd()))
   nRegSFC:=(SFC->(Recno()))

	//�������������������������������������������������������Ŀ
	//�Verificar se a base do imposto eh o LIQUIDO ou o BRUTO,�
	//�e a sequencia do imposto atual                         �
	//���������������������������������������������������������
	If cCalculo == "B"
	   SFC->(DbSetOrder(2))
	   If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
	      If SFC->FC_LIQUIDO=="S"
	         nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
	      Endif   
			nIndAtu		:=	Val(SFC->FC_SEQ)
	   Endif   
	
		//��������������������������������������������������������������������������������������������Ŀ
		//�Verificar se este imposto pertence a um grupo de impostos, para os quais as bases devem ser �
		//�calculadas em conjunto, se pertencer, calculo as aliquotas de cada um dos impostos do grupos�
		//�para poder estabelecer a base de c�lculo                                                    �
		//����������������������������������������������������������������������������������������������
		If !Empty(SFC->FC_AGRBASE) .And. nBase > 0
			cAgregBase	:=	SFC->FC_AGRBASE
			nIndAtu		:=	Val(SFC->FC_SEQ)	
		
			SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES") ))
			While !EOF() .And. SFC->FC_FILIAL+SFC->FC_TES ==xFilial("SFC")+MaFisRet(nItem,"IT_TES") 
				If cAgregBase	==	SFC->FC_AGRBASE
					AAdd(aAgreg,{SFC->FC_SEQ,Posicione('SFB',1,xFilial('SFB')+SFC->FC_IMPOSTO,'SFB->FB_CPOLVRO')})
				Endif
				SFC->(DbSkip())
			Enddo
			nAliq	:=	0
			For nX:= 1 To Len(aAgreg)
				nIndice	:=	Val(aAgreg[nX][1])
				If nIndice >= nIndAtu			
					MaFisCalAl(nIndice,nItem)
				Endif               
		      nAliq	+=	MaFisRet(nItem,'IT_ALIQIV'+aAgreg[nX][2])
			Next
		Endif
	Endif	
		    
   SFC->(DbSetOrder(nOrdSFC))
   SFC->(DbGoto(nRegSFC))
 
   Do Case
      Case cCalculo=="B"
			nBase	:=	nBase /(1+(nAliq/100))
			xRet:=nBase
      Case cCalculo=="A"
         xRet:=nAliqImpAtu
      Case cCalculo=="V"
			nImp	:=	MaFisRet(nItem,'IT_BASEIV'+aInfo[X_NUMIMP]) * MaFisRet(nItem,'IT_ALIQIV'+aInfo[X_NUMIMP])/100
         xRet	:=	nImp
   EndCase    
Endif
	
Return( xRet )
