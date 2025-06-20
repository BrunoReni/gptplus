#include "SIGAWIN.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    1 //Nome do imposto
#DEFINE X_NUMIMP     2 //Sufixo do imposto


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �M100PIV   � Autor � Felipe V. Nambara      � Data � 04.11.09  ���
���������������������������������������������������������������������������Ĵ��
���Descricao �Programa que Calcula PIV   (PERU)                             ���
���������������������������������������������������������������������������Ĵ��
���Uso       �MATXFIS/MATA468N                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function M100PIV(cCalculo,nItem,aInfo)

Local nDecs := 0
Local nI	:= 0
Local lXFis
Local nBase := 0
Local cAliasROT, cOrdemROT
Local aImpRef,aImpVal
Local aArea		   := GetArea()
Local nlAlqPIV	   := 0       
Local cPOSIPI      := ""
SetPrvt("AITEMINFO,xRet,CIMPINCID")
SetPrvt("NI,NEE")

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
cAliasRot:= Alias()
cOrdemRot:= IndexOrd()
/*
���������������������������������������������������������������Ŀ
� Observacao :                                                  �
�                                                               �
� a variavel ParamIxb tem como conteudo um Array[2], contendo : �
� [1,1] > Quantidade Vendida                                    �
� [1,2] > Preco Unitario                                        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,1] > Array xRet, Contendo as Informa��es do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/

If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet:=ParamIxb[2]
	cImpIncid:=xRet[10]		
Endif

nMoedaCor := IIf(Type("nMoedaCor")	=="U",1,nMoedaCor)
nDecs := MsDecimais(nMoedaCor)

//+-------------------------------------------------------------------+
//� Considerar o Tipo do Cliente.                                     �
//�                                                                   �
//� A => Afecto                                                       �
//� N => Resp. Nao Afecto  , n�o gera IVA nas notas                   �
//+-------------------------------------------------------------------+

//+---------------------------------------------------------------+
//� No estan siendo consideradas las devoluciones...		         �
//+----------------------------------------------------------Bruno+

If !lXFis
	DbSelectArea("SYD")       
	DbSetOrder(1)
	If DbSeek(xFilial("SYD") + SB1->B1_POSIPI )
		nlAlqPIV := SYD->YD_ALQPIV
	Endif
	
	If SB1->(FieldPos('B1_ALQPIGV')) >0 .And. SB1->B1_ALQPIGV <> 0 .And. Empty(SB1->B1_POSIPI )
		nlAlqPIV:=SB1->B1_ALQPIGV	
	EndIf
	
	If nlAlqPIV == 0
		DbSelectArea("SFB")
		DbSetOrder(1)		
		If SFB->(Dbseek(xfilial()+xRet[1]))
			nlAlqPIV := SFB->FB_ALIQ
		EndIf		     	
	EndIf
	xRet[2] := nlAlqPIV
	xRet[11] := aItemINFO[4]									// Rateio do Frete
	xRet[13] := aIteMINFO[5]     				    			// Rateio de Despesas
	xRet[3] := aItemINFO[3]                                    // Base de C�lculo sem frete, seguro ou despesa.
	
	//Tira os descontos se for pelo liquido .Bruno
	If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
		xRet[3]	-=	xRet[18]
		//nBase := xRet[3]
	Endif

	//+---------------------------------------------------------------+
	//� Soma a Base de C�lculo os Impostos Incidentes                 �
	//+----------------------------------------------------------Lucas+
	nI := At( cImpIncid,";" )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	
	While nI > 1
		nEE:= AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
		If nEE> 0
			xRet[3] := xRet[3]+aItemINFO[6,nEE,4]
		Endif
		cImpIncid := Stuff( cImpIncid,1,nI,"" )
		nI := At( cImpIncid,";" )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	End


		
	//+---------------------------------------------------------------+
	//� Efetua o C�lculo do Imposto                                   �
	//+----------------------------------------------------------Lucas+
	xRet[4] := Round(xRet[2] * (xRet[3]/100),nDecs)
Else

	//��������������������������������������Ŀ
    //�Valor da Base aplicada a Aliquota    �
	//��������������������������������������Ŀ  
	Do Case
		Case cCalculo == "B"
			xRet   := MaFisRet(nItem,"IT_VALMERC") // Base de C�lculo sem frete, seguro ou despesa.

			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+ aInfo[X_IMPOSTO])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					If  SF1->(FieldPos("F1_ADIANT")) > 0 
						xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_ADIANTTOT"),MaFisRet(nItem,"IT_ADIANTTOT"))
					EndIf
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			//+---------------------------------------------------------------+
			//� Soma a Base de C�lculo os Impostos Incidentes                 �
			//+---------------------------------------------------------------+
			If !Empty(cImpIncid)
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				For nI:=1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						IF Trim(aImpRef[nI][1])$cImpIncid
							xRet+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
		Case cCalculo == "A"
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1") + MaFisRet(nItem,"IT_PRODUTO"))
				cPOSIPI := SB1->B1_POSIPI
			EndIf
			DbSelectArea("SYD")
			DbSetOrder(1)
			If DbSeek(xFilial("SYD") + cPOSIPI)
				nlAlqPIV := SYD->YD_ALQPIV
			Endif
			
			If SB1->(FieldPos('B1_ALQPIGV')) >0 .And. SB1->B1_ALQPIGV <> 0 .And. Empty(cPOSIPI)
				nlAlqPIV:=SB1->B1_ALQPIGV	
			EndIf
			
			If nlAlqPIV == 0
				DbSelectArea("SFB")
				DbSetOrder(1)		
				If SFB->(Dbseek(xfilial()+aInfo[X_IMPOSTO]))
					nlAlqPIV := SFB->FB_ALIQ
				EndIf		     	
			EndIf                                                                     
			xRet:=  nlAlqPIV 
			
		Case cCalculo == "V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			nlAlqPIV:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			xRet := Round(((nlAlqPIV * nBase)/100),nDecs)
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES"))))
					If SFC->FC_CALCULO=="T"
						If MaFisRet(,'NF_BASEIV'+aInfo[2])+ nBase >  MaFisRet(,"NF_MINIV"+aInfo[2])
							If MaFisRet(,'NF_BASEIV'+aInfo[2]) > 0
								xRet := MaRetBasT(aInfo[X_NUMIMP],nItem,nlAlqPIV) *(nlAlqPIV /100)
								xRet := xRet - ((xRet *nlAlqPIV) / 100)
							Else
								xRet := MaRetBasT(aInfo[X_NUMIMP],nItem,nlAlqPIV) *(nlAlqPIV /100)
						 	EndIf
			  			Endif
					Else
						If MaFisRet(nItem,'IT_BASEIV'+aInfo[2]) >= SFF->FF_IMPORTE
							If nlAlqPIV > 0							
								xRet := Round(((nlAlqPIV * nBase)/100),nDecs)							
							EndIf
			  			Endif
					Endif
				Endif
			DbSelectArea("SFF")
			DbSetOrder(16)
			SFF->(Dbseek(xfilial()+aInfo[X_IMPOSTO]))
			If xRet <= SFF->FF_IMPORTE
			 xRet := 0
			EndIf
	EndCase

Endif

RestArea(aArea)

Return( xRet )
