#include "SIGAWIN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460SELO  �Autor  �Ricardo Borges      � Data � 16/06/2009  ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula do Imposto de Selo para Angola                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis - Localizacao Angola                                ���
��                                                                        ���
�����������������������������������������������������������������������������           
�����������������������������������������������������������������������������
*/
Function M460SELO(cCalculo,nItem,aInfo)

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
Local nDecAlq    	:= 0.00
Local nDecBase   	:= 0.00
Local nArreBase  	:= 0.00
Local nArreAlq	 	:= 0.00  

Local lAliqSel   	:= .F. 
Local lArredBase	:= GetNewPar("MV_ARBSSEL",.T.) 
Local lArredSelo 	:= GetNewPar("MV_ARVLSEL",.T.) 
Local lXFis			:= .F.

Local xRet                                             

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
               
//���������������������������������������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
	lAliqSel	:= IF(!EMPTY(SBI->BI_ALQSEL),.T.,.F.)
	nAliq 		:= SBI->BI_ALQSEL
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	lAliqSel	:= IF(!EMPTY(SB1->B1_ALQSEL),.T.,.F.)
	nAliq 		:= SB1->B1_ALQSEL
Endif    

//����������������������������������������������������������������������������������������������Ŀ
//�Busca a aliquota do Cadastro Impostos Variaveis quando nao tiver no Cad. Produto = B1_ALIQSEL �
//������������������������������������������������������������������������������������������������
If !lAliqSel
   	DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))                
   	If SFB->(Dbseek(xFilial("SFB")+cImp))
		nAliq := SFB->FB_ALIQ
	Endif
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
	If cCalculo == "B" .Or. cCalculo == "V"  // Necessita entrar aqui para calcular a base quando for V, pois por algum 
										     // motivo ele n�o carrega o valor da base para calcular o valor do imposto (cCalculo == "V").
										     // No caso do imposto de Consumo e empreitada ele carrega.
	
		//��������������������������������������������������������������������Ŀ
		//�Base de calculo composta pelo valor da mercadoria + frete + seguro  �
		//�Observacao Importante: em Angola nao ha a figura de frete e seguro, �
		//�porem o sistema deve estar preparado para utilizar esses valores no �
		//�calculo do imposto.                                                 �
		//����������������������������������������������������������������������
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				
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

//������������������������������������������������������������������Ŀ
//�Efetua o calculo do imposto com base na base de calculo encontrada�
//��������������������������������������������������������������������
If !lXFis
       
	//���������������������������������������������
	//�Pega Decimais da Base de Calculo do Imposto�
	//���������������������������������������������        
	nBase := Round(nBase,2)
	nDecBase := (nBase - int(nBase))   
	nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)    
	
	//�������������������������������������������������������������������������������
	//�Arredonda a Base de Calculo de Imposto, caso o par�metro MV_ARBSSEL seja .T..�
	//�������������������������������������������������������������������������������
    If lArredBase
		nBase    := Int(nBase) + nArreBase
	EndIf
	
	aImp[03] := nBase		    
      
	//���������������������������������������Ŀ
	//�Calcula Imposto com a Base Arredondada �
	//�����������������������������������������
	nImp := Round((( nAliq * nBase) /100 ),2)
   
	//����������������������������������Ŀ
	//�Pega Decimais do Valor do Imposto �
	//������������������������������������
	nDecAlq  	:= (nImp - int(nImp))
	nArreAlq  	:= IF(nDecAlq >= 0.01, 1.0, 0.0) 
                                                                           

	//���������������������������������������������������������������������
	//�Arredonda o Valor do Imposto, caso o par�metro MV_ARVLSEL seja .T..�
	//���������������������������������������������������������������������	
	If lArredSelo   
		nImp := Int(nImp) + nArreAlq	   
	EndIf
		
	aImp[02] 	:= nAliq
	aImp[04] 	:= nImp                   
	xRet 		:= aImp

Else 

	//���������������������������������������������
	//�Pega Decimais da Base de Calculo do Imposto�
	//��������������������������������������������� 
	nBase := Round(nBase,2)
	
    nDecBase := (nBase - int(nBase))   
    nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)
            
            
	//�������������������������������������������������������������������������������
	//�Arredonda a Base de Calculo de Imposto, caso o par�metro MV_ARBSSEL seja .T..�
	//�������������������������������������������������������������������������������
    If lArredBase
	    nBase    := Int(nBase) + nArreBase                                                            
	EndIf

    Do Case
		//�������������������������������������������Ŀ
		//�Para verificar a base de calculo do imposto�
		//���������������������������������������������
		Case cCalculo == "B"
            
		//������������������������������������Ŀ
		//�Retorna a base de calculo do imposto�
		//��������������������������������������
  		xRet := nBase                         
            
		//�����������������������������������������������Ŀ
		//�Para verificar a aliquota de calculo do imposto�
		//�������������������������������������������������
		Case cCalculo == "A"
       
            xRet := nALiq
       
		//�����������������������Ŀ
		//�Para calcular o imposto�
		//�������������������������
		Case cCalculo == "V"

			//��������������������������������������Ŀ
			//�Calcula Imposto com a Base Arredondada�
			//����������������������������������������
			nImp    := Round((( nAliq * nBase) /100 ),2)
				        
			//���������������������������������Ŀ
			//�Pega Decimais do Valor do Imposto�
			//�����������������������������������
		    nDecAlq		:= (nImp - int(nImp))
		    nArreAlq	:= IF(nDecAlq >= 0.01, 1.0, 0.0) 
	        
			//���������������������������������������������������������������������
			//�Arredonda o Valor do Imposto, caso o par�metro MV_ARVLSEL seja .T..�
			//���������������������������������������������������������������������	
			If lArredSelo   
			    nImp    := Int(nImp) + nArreAlq	   
			EndIF

			//��������������������������Ŀ
			//�Retorna o valor do imposto�
			//����������������������������
	        xRet 	:= nImp

    EndCase   

Endif                   

RestArea(aArea)

Return(xRet)