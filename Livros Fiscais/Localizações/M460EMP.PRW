#include "SIGAWIN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460EMP  �Autor  �Ricardo Borges      � Data � 25/06/2009  ��/�
�������������������������������������������������������������������������͹��
���Desc.     �Calcula Imposto de Empreitada para Angola                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis - Localizacao Angola                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M460EMP(cCalculo,nItem,aInfo) 

Local aImp 		:= {}
Local aItem 	:= {}
Local aArea		:= GetArea()
Local aImpRef 	:= {}
Local aImpVal 	:= {}

Local cImp		:= ""
Local cTes   	:= ""
Local cRegiao	:= ""
Local cGrupo	:= ""                      
Local cProd		:= ""
Local cImpIncid	:= ""

Local nOrdSFC   := 0    
Local nRegSFC   := 0
Local nImp   	:= 0
Local nBase		:= 0
Local nAliq 	:= 0
Local nDecs 	:= 0  
Local nPos	 	:= 0
Local nI		:= 0
Local nE		:= 0

Local lIsento	:= .F.
Local lImpDep	:= .F.
Local lCalcLiq	:= .F.
Local lAliqEmp   := .F. 
Local lArredBase := GetNewPar("MV_ARBSEMP",.T.) 
Local lArredEmp  := GetNewPar("MV_ARVLEMP",.T.) 
Local nDecAlq    := 0.00
Local nDecBase   := 0.00	
Local nPerEmp 	 := 0.00
Local nArreBase  := 0.00
Local nArreImp	 := 0.00  
Local cGrpAces	:= GetNewPar("MV_GRPACES","FR=004;SE=005;DT=006;DN=007;TA=008")
Local cImpDesp	:= "IFD|IDD|ISD|ITD"
Local xRet                  
Local lXFis		:= .F.

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
                               

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
   aItem	:= ParamIxb[1]
   aImp		:= ParamIxb[2]
   cImp		:= aImp[1]
   cTes		:= SF4->F4_CODIGO
   cProd 	:= SB1->B1_COD
Else
   cImp		:= aInfo[1]
   cTes		:= MaFisRet(nItem,"IT_TES")
   cProd	:= MaFisRet(nItem,"IT_PRODUTO")   
Endif           
               
//�����������������������������L����������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	lAliqEmp:=IF(!EMPTY(SB1->B1_ALQEMP),.T.,.F.)
	nAliq := SB1->B1_ALQEMP
Endif    
    
	//����������������������������������������������������������������������������������������������Ŀ
	//�Busca a aliquota do Cadastro Impostos Variaveis quando nao tiver no Cad. Produto = B1_ALQCON �
	//������������������������������������������������������������������������������������������������
	If !lAliqEmp
	   	DbSelectArea("SFB")    
	   	SFB->(DbSetOrder(1))                
	   	If SFB->(Dbseek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
	Endif	
	
	If !lXFis 

		nBase := aItem[3] 
		cImpIncid:= aImp[10]


	Else           

		nBase := MaFisRet(nItem,"IT_VALMERC")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			//�������������������������������������������������������Ŀ
			//�Somente quando for IVA de mercadorias aplica o desconto�
			//���������������������������������������������������������
			nBase += MaFisRet(nItem,"IT_DESCONTO")
		Endif
		cImpIncid:=""
	Endif

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

//����������������������������������������������Ŀ
//�Verifica os descontos e os impostos incidentes�
//������������������������������������������������
If !lXFis

	//����������������������������������������������Ŀ
	//�Soma a Base de Calculo os Impostos Incidentes �
	//������������������������������������������������
	nI := At(cImpIncid,";" )
	nI := Iif(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	While nI > 1
		nE := AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
		If nE > 0
			nBase += aItem[6,nE,4]
		Endif
		cImpIncid := Stuff(cImpIncid,1,nI,"")
		nI := At(cImpIncid,";")
		nI := Iif(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	Enddo

	//����������������������������������������������������������������������Ŀ
	//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
	//������������������������������������������������������������������������
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		//�������������������������������������������������������Ŀ
		//�Somente quando for IVA de mercadorias aplica o desconto�
		//���������������������������������������������������������
		If !(cImp $ cImpDesp)
			nBase -= aImp[18]
		Endif
	Endif

Else
           
	If cCalculo == "B"
		//�������������������������������������������������������Ŀ
		//�Somente quando for IVA de mercadorias aplica o desconto�
		//���������������������������������������������������������
		If !(cImp $ cImpDesp)
			nOrdSFC := (SFC->(IndexOrd()))
			nRegSFC := (SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
				cImpIncid := Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO == "S"
					nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif   
			Endif   
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
		Endif
		
		//����������������������������������������������Ŀ
		//�Soma a Base de Calculo os Impostos Incidentes �
		//������������������������������������������������
		If !Empty(cImpIncid)
			aImpRef := MaFisRet(nItem,"IT_DESCIV")
			aImpVal := MaFisRet(nItem,"IT_VALIMP")
			For nI := 1 to Len(aImpRef)
				If !Empty(aImpRef[nI])
					If Trim(aImpRef[nI][1]) $ cImpIncid
						nBase += aImpVal[nI]
					Endif
				Endif
			Next
		Endif
	Endif
Endif

If !lXFis                
    
   //������������������������������������������������Ŀ
   //�Pega Percentual para Base de Calculo do Imposto �
   //������������������������������������������������Ŀ   
   aArea:=GetArea()
   DbSelectArea("SF4")    
   SF4->(DbSetOrder(1))                
   If SF4->(Dbseek(xFilial("SF4")+cTes))
      nPerEmp := SF4->F4_PERCEMP   
   Endif   
   RestArea(aArea)

   //������������������������������������������������Ŀ
   //�Aplica Percentual na Base de Calculo do Imposto �
   //������������������������������������������������Ŀ
   nBase	:= Round(( nBase * ( nPerEmp / 100) ),2)

   //���������������������������������������������Ŀ
   //�Pega Decimais da Base de Calculo do Imposto  �
   //���������������������������������������������Ŀ   
   nDecBase := (nBase - int(nBase))
   nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)

	//�������������������������������������������������������������������������������
	//�Arredonda a Base de Calculo de Imposto, caso o par�metro MV_ARBSEMP seja .T..�
	//�������������������������������������������������������������������������������
	If lArredBase
		nBase := int(nBase) + nArreBase
	EndIf
      
   aImp[03] := nBase
   
   aImp[04] := Round((( nAliq * nBase) /100 ),2)

	nImp := aImp[04]
	
   //�����������������������������������Ŀ
   //�Pega Decimais do Valor do Imposto  �
   //������������������������������������Ŀ   
   nDecAlq  := (nImp - int(nImp))
   nArreImp := IF(nDecAlq >= 0.01, 1.0, 0.0)
     
	//���������������������������������������������������������������������
	//�Arredonda o Valor do Imposto, caso o par�metro MV_ARVLEMP seja .T..�
	//���������������������������������������������������������������������	
	If lArredEmp
		aImp[04] := int(nImp) + nArreImp
	EndIf
	
    aImp[02] := nAliq
 
   xRet := aImp     
   
Else 

   //������������������������������������������������Ŀ
   //�Pega Percentual para Base de Calculo do Imposto �
   //������������������������������������������������Ŀ   
   aArea:=GetArea()
   DbSelectArea("SF4")    
   SF4->(DbSetOrder(1))                
   If SF4->(Dbseek(xFilial("SF4")+cTes))
      nPerEmp := SF4->F4_PERCEMP   
   Endif   
   RestArea(aArea)

   //������������������������������������������������Ŀ
   //�Aplica Percentual na Base de Calculo do Imposto �
   //������������������������������������������������Ŀ
   nBase	:= Round(( nBase * ( nPerEmp / 100)),2)
   
   //���������������������������������������������Ŀ
   //�Pega Decimais da Base de Calculo do Imposto  �
   //���������������������������������������������Ŀ   
   nDecBase := (nBase - int(nBase))
   nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)		

	//�������������������������������������������������������������������������������
	//�Arredonda a Base de Calculo de Imposto, caso o par�metro MV_ARBSEMP seja .T..�
	//�������������������������������������������������������������������������������
	If lArredBase				   		   
		nBase    := int(nBase) + nArreBase       
	EndIf

    Do Case

       Case cCalculo=="B"            
					
           xRet := nBase

       Case cCalculo=="A"

            xRet := nALiq

       Case cCalculo=="V"
       
		   nImp := Round((( nAliq * nBase) /100 ),2)
   
		   //�����������������������������������Ŀ
		   //�Pega Decimais do Valor do Imposto  �
		   //������������������������������������Ŀ   
		   nDecAlq  := ( nImp - int(nImp) )
		   nArreImp := IF(nDecAlq >= 0.01, 1.0, 0.0)
		   
			//���������������������������������������������������������������������
			//�Arredonda o Valor do Imposto, caso o par�metro MV_ARVLEMP seja .T..�
			//���������������������������������������������������������������������	
			If lArredEmp
				nImp := int( nImp ) + nArreImp 	       
			EndIf

           xRet := nImp

    EndCase   

Endif                   


Return(xRet)