#include "SIGAWIN.CH"
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460ISCP  �Autor  �FELIPE V. NAMBARA   � Data � 23/10/2009 ��/�
�������������������������������������������������������������������������͹��
���Desc.     �Calcula Imposto ISC para Peru NF Sa�da                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis - Localizacao Peru                                  ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M460ISCP(cCalculo,nItem,aInfo)

Local aImp 			:= {}
Local aItem 		:= {}                                                        
Local aArea			:= GetArea()
Local aImpRef 		:= {}
Local aImpVal 		:= {}

Local cImp			:= ""
Local cTes   		:= ""
Local cProd			:= ""
Local cImpIncid		:= ""

Local nOrdSFC   	:= 0    
Local nRegSFC   	:= 0
Local nImp   		:= 0
Local nBase			:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0  
Local nPos	 		:= 0
Local nI			:= 0
Local nE			:= 0
Local lXFis			:= .F.
Local xRet                                             
Local nlAliqX       := 0

//�������������������������������������������������������������������Ŀ
//�Identifica se a chamada da funcao do calculo do imposto esta sendo �
//�feita pela matxfis ou pelas rotinas manuais do localizado.         �
//���������������������������������������������������������������������
lXFis := (MafisFound() .And. ProcName(1)!="EXECBLOCK")

/*
�������������������������������������������������������������������������������Ŀ
� Observacao :                                                                  �
�                                                                               �
� A variavel ParamIxb tem como conteudo um Array[2], contendo :                 �
� [1,1] > Quantidade Vendida                                                    �
� [1,2] > Preco Unitario                                                        �
� [1,3] > Valor Total do Item, com Descontos etc...                             �
� [1,4] > Valor do Frete rateado para este Item                                 �
�         Para Portugal, o imposto do frete e calculado em separado do item     �
� [1,5] > Valor das Despesas rateado para este Item                             �
�         Para Portugal, o imposto das despesas e calculado em separado do item �
� [1,6] > Array Contendo os Impostos j� calculados, no caso de incid�ncia de    �
�         outros impostos.                                                      �
� [2,1] > Array aImposto, contendo as Informa��es do Imposto que ser� calculado.�
���������������������������������������������������������������������������������
*/
If !lXfis
	aItem		:= ParamIxb[1]
	aImp		:= ParamIxb[2]
	cImp		:= aImp[1]
	cImpIncid	:= aImp[10]
	cTes		:= SF4->F4_CODIGO
	cProd 		:= SB1->B1_COD
Else
   cImp			:= aInfo[1]
   cTes			:= MaFisRet(nItem,"IT_TES")
   cProd		:= MaFisRet(nItem,"IT_PRODUTO")   
   cImpIncid	:= ""
Endif           
               

//�����������������������������������������������������������������������������������������������������Ŀ
//�Verifica a base de calculo do imposto e se ha o cadastro de impostos incidentes nesta base de calculo�
//�������������������������������������������������������������������������������������������������������
If !lXFis 	 
	//��������������������������������������������������������������������Ŀ
	//�Base de calculo composta pelo valor da mercadoria + frete + seguro  �
	//�Observacao Importante: em Angola nao ha a figura de frete e seguro, �
	//�porem o sistema deve estar preparado para utilizar esses valores no �
	//�calculo do imposto.                                                 �
	//����������������������������������������������������������������������
	nBase := aItem[3]+aItem[4]+aItem[5] 

	//������������������������������������������������Ŀ
	//�Reduz os descontos concedidos da base de calculo�
	//��������������������������������������������������
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18]) == "N"
		nBase -= aImp[18]
	Endif                                              

	//��������������������������������������������������������������������Ŀ
	//�Soma na base de calculo todos os demais impostos incidentes.        �
	//�Observacao Importante: em Angola nao existem impostos que incidem um�
	//�sobre o outro, porem o sistema deve estar preparado para utilizar   �
	//�esses valores no calculo do imposto.                                �
	//����������������������������������������������������������������������
	nI := At(cImpIncid,";" )
	nI := If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	While nI>1
		nE := AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
		If nE > 0
			nBase += aItem[6,nE,4]
		Endif
		cImpIncid := Stuff(cImpIncid,1,nI,"")
		nI := At(cImpIncid,";")
		nI := If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	Enddo

Else 

	//������������������������������������������������������������������������������Ŀ
	//�Somente efetua esse processamento se a chamada da funcao estiver sendo        �
	//�feita para montagem da base de calculo do imposto. Como a matxfis chama       �
	//�sempre 3 vezes as funcoes de impostos, esse filtro eh importante para diminuir�
	//�a lentidao do processamento.                                                  �
	//��������������������������������������������������������������������������������
	If cCalculo == "B" .Or. cCalculo == "V"  
	
		//��������������������������������������������������������������������Ŀ
		//�Base de calculo composta pelo valor da mercadoria + frete + seguro  �
		//�Observacao Importante: em Angola nao ha a figura de frete e seguro, �
		//�porem o sistema deve estar preparado para utilizar esses valores no �
		//�calculo do imposto.                                                 �
		//����������������������������������������������������������������������      
		
		If FunName() $ "MATA410"
			If M->C5_TPFRETE == "F"
				nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			Else
				nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			EndIf
		Else
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		EndIf
		
		
				
		//������������������������������������������������Ŀ
		//�Reduz os descontos concedidos da base de calculo�
		//��������������������������������������������������
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	
		//������������������������������������������������Ŀ
		//�Efetua o desconto tambem nos impostos incidentes�
		//��������������������������������������������������
		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))	
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			cImpIncid := Alltrim(SFC->FC_INCIMP)
			If SFC->FC_LIQUIDO == "S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif   
		Endif   
	
		//��������������������������������������������������������������������Ŀ
		//�Soma na base de calculo todos os demais impostos incidentes.        �
		//�Observacao Importante: em Angola nao existem impostos que incidem um�
		//�sobre o outro, porem o sistema deve estar preparado para utilizar   �
		//�esses valores no calculo do imposto.                                �
		//����������������������������������������������������������������������
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		If !Empty(cImpIncid)
			aImpRef:=MaFisRet(nItem,"IT_DESCIV")
			aImpVal:=MaFisRet(nItem,"IT_VALIMP")
			For nI:=1 to Len(aImpRef)
				If !Empty(aImpRef[nI])
					If Trim(aImpRef[nI][1])$cImpIncid
						nBase += aImpVal[nI]
					Endif
				Endif
			Next
		Endif 
		
	Endif

Endif

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
                     
//����������������������������������������������Ŀ
//�Incio de c�lculo do imposto ISC para entrada  �
//������������������������������������������������
                                                
//����������������������������������������������������������������������Ŀ
//� Abaixo � a condi��o caso o imposto seja calculado para notas fiscais �
//� de saida com pedido de venda                                         �
//������������������������������������������������������������������������

If !lXFis

	//��������������������������������������������������������������Ŀ
	//� Se houver alguma exce��o fiscal o valor da aliquota por uni-  � 
	//� dade � utilizado para c�lcularo imposto e o valor da aliquota �
	//� fica zerada		                                              �
	//�����������������������������������������������������������������
    
	
	DbSelectArea("SFF")
	DbSetOrder(3)
	If DbSeek(xFilial("SFF")+aImp[1])
	    If SFF->FF_VLRISC > 0
			nlAliqX := SFF->FF_VLRISC 
			
			aImp[2] := 0
			aImp[3] := aItem[3]+aItem[4]+aItem[5]
			aImp[4] := aItem[1]*nlAliqX
			
			xRet:=aImp						
		EndIf		                
	EndIf

	//���������������������������������������������������������������Ŀ
	//� Caso n�o haja nenhuma exce��o fiscal � verificado se h� valor �
	//� no campo B1_VLRISC. Se houver o c�lculo � feito por unidade   �
	//�����������������������������������������������������������������
			
	If nlAliqX <= 0 .And. SB1->B1_VLRISC > 0
		nlAliqX := SB1->B1_VLRISC  
	
		aImp[2] := 0
		aImp[3] := aItem[3]+aItem[4]+aItem[5]
		aImp[4] := aItem[1]*nlAliqX		

		xRet:=aImp 
	EndIf

	//�������������������������������������������������������������Ŀ
	//� Caso n�o haja nenhuma exce��o fiscal e o valor do campo     � 
	//� B1_VLRISC esteja zerado, � verificado se o vampo B1_ALQISC  �
	//� possui valor. Se houver, o imposto � calculado por taxa uti-�
	//� lizando a aliquota do campo B1_VLRISC	                    � 
	//���������������������������������������������������������������
	
	If nlAliqX <= 0 .And. SB1->B1_ALQISC > 0
			nlAliqX := SB1->B1_ALQISC
			nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	
			aImp[02]:=nlAliqX
			aImp[03]:=nBase
	
			If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
				aImp[3]	-=aImp[18]
			Endif
			
			aImp[4] := Round(aImp[3]*aImp[2]/100,2)
			xRet:=aImp				
	EndIf
			

	//�������������������������������������������������������������Ŀ
	//� Caso n�o haja nenhuma exce��o fisca, o valor do campo       � 
	//� B1_VLRISC esteja zerado e o valor do campo B1_ALQISC esteja �
	//� zerado o imposto � calculado pela taxa utilizando como ali- � 
	//� quota o valor do campo FB_ALIQ (Aliquota padr�o) 	        � 
	//���������������������������������������������������������������			

				
	If nlAliqX <= 0 
		DbSelectArea("SFB")
		DbSetOrder(1)		
		If SFB->(Dbseek(xfilial()+aImp[1]))
			nlAliqX := SFB->FB_ALIQ
			nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	
			aImp[02]:=nlAliqX
			aImp[03]:=nBase
			
			If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
				aImp[3]	-=aImp[18]
			Endif                                                                         
			
			aImp[4] := Round(aImp[3]*aImp[2]/100,2)
			xRet:=aImp						
		EndIf
	EndIf
               
Else 

	//����������������������������������������������������������������������Ŀ
	//� Abaixo � a condi��o caso o imposto seja calculado para notas fiscais �
	//� de entrada manual, com pedido e notas de deb/cr�d.                   �  
	//� O c�lculo do imposto respeita a mesma regra utilizada acima          �	
	//������������������������������������������������������������������������
	
	Do Case

		Case cCalculo=="B"
 					
			xRet := nBase

		Case cCalculo=="A"

			DbSelectArea("SFF")
			DbSetOrder(3)
			If DbSeek(xFilial("SFF")+cImp)
			    If SFF->FF_VLRISC > 0
					nlAliqX := SFF->FF_VLRISC
					xRet    := 0
				EndIf
			EndIf
			
			If nlAliqX <= 0 
				DbSelectArea("SB1")
				DbSetOrder(1)
				If DbSeek(xFilial("SB1")+cProd)
					If SB1->B1_VLRISC > 0
						nlAliqX := SB1->B1_VLRISC
						xRet    := 0
					EndIf
				EndIf	  
			EndIf
			
			If nlAliqX <= 0 .And. SB1->B1_ALQISC > 0
				nlAliqX := SB1->B1_ALQISC
				xRet    := nlAliqX
			EndIf
			
			If nlAliqX <= 0
				DbSelectArea("SFB")
				DbSetOrder(1)
				If Dbseek(xfilial()+cImp)
					nlAliqX := SFB->FB_ALIQ
					xRet    := nlAliqX
				EndIf
			EndIf
			
       Case cCalculo=="V"

			DbSelectArea("SFF")
			DbSetOrder(3)
			If DbSeek(xFilial("SFF")+cImp)
			    If SFF->FF_VLRISC > 0
					nlAliqX := SFF->FF_VLRISC
					xRet := Round(SFF->FF_VLRISC*MaFisRet(nItem,"IT_QUANT"),2)
				EndIf
			EndIf
							
			If nlAliqX <= 0
				DbSelectArea("SB1")
				DbSetOrder(1)
				If DbSeek(xFilial("SB1")+cProd)
					If SB1->B1_VLRISC > 0
						nlAliqX := SB1->B1_VLRISC
						xRet := Round(SB1->B1_VLRISC*MaFisRet(nItem,"IT_QUANT"),2)
					EndIf
				EndIf					
			EndIf
					
			If nlAliqX <= 0 .And. SB1->B1_ALQISC > 0
				nlAliqX := SB1->B1_ALQISC
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
            	            
				xRet := Round((( nAliq * nBase) /100 ),2)
			EndIf
			
			If nlAliqX <= 0 
				DbSelectArea("SFB")
				DbSetOrder(1)		
				If SFB->(Dbseek(xfilial()+cImp))
					nlAliqX := SFB->FB_ALIQ
					
					nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
	            	            
					xRet := Round((( nAliq * nBase) /100 ),2)										
				EndIf
			EndIf   
	EndCase   

Endif

RestArea(aArea)

Return(xRet)  