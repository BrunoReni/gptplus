/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100SUN	� Autor � MARCELLO GABRIEL     � Data � 08.08.2002 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo de imposto sobre venda de bens ou servicos sultuosos���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico                                                    ���
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
FUNCTION M100SUN(cCalculo,nItem,aInfo)
Local aItem,lXFis,cImp,xRet,nOrdSFC,nRegSFC
Local nBase:=0,nAliq:=0,lALIQ:=.f.,lIsento:=.f.,cFil,cAux,cGrp
Local cDbf:=alias(),nOrd:=IndexOrd()
Local cImpIncid,nE,nI

dbSelectArea("SFF")     // verificando as excecoes fiscais
dbSetOrder(3)
cFil:=xfilial()
lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXfis
   aItem:=ParamIxb[1]
   xRet:=ParamIxb[2]
   cImp:=xRet[1]
	cImpIncid:=xRet[10]
Else
	cImp:=aInfo[1]
	If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
		SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
	Else
		SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
	Endif
    xRet:=0
	cImpIncid:=""
Endif            

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRUPO)
Else
	cGrp:=Alltrim(SB1->B1_GRUPO)
Endif

if dbseek(cFil+cImp)
   while FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
         cAux:=Alltrim(FF_GRUPO)
         if cAux!=""
            lAliq:=(cAux==cGrp)
         endif
         if lAliq
            if !(lIsento:=(FF_TIPO=="S"))
               nAliq:=FF_ALIQ
            endif
         endif
         dbskip()
   enddo
endif
if !lIsento
   if !lAliq .And. If(!lXFis,.T.,cCalculo=="A")
      dbselectar("SFB")    // busca a aliquota padrao
      if dbseek(xfilial()+cImp)
         nAliq:=SFB->FB_ALIQ
      endif
   endif
   If !lXFis
      nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
      //Tira os descontos se for pelo liquido .Bruno
      If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
         nBase-=xRet[18]
      Endif
		//+---------------------------------------------------------------+
		//� Soma a Base de C�lculo os Impostos Incidentes                 �
		//+---------------------------------------------------------Lucas-+
		nI:=At(cImpIncid,";" )
		nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		While nI>1
			nE:=AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
			If nE>0
				nBase+=aItem[6,nE,4]
			End
			cImpIncid:=Stuff(cImpIncid,1,nI,"")
			nI:=At(cImpIncid,";")
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		Enddo
   Else
       If cCalculo=="B"
          nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
          //Tira os descontos se for pelo liquido
          nOrdSFC:=(SFC->(IndexOrd()))
          nRegSFC:=(SFC->(Recno()))
          SFC->(DbSetOrder(2))
          If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
             If SFC->FC_LIQUIDO=="S"
                nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
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
						If Trim(aImpRef[nI][1])$cImpIncid
							nBase+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
       Endif   
   Endif
endif
If !lXFis
   xRet[02]:=nAliq
   xRet[03]:=nBase
   xRet[04]:=(nAliq * nBase)/100
Else 
    Do Case
       Case cCalculo=="B"
            xRet:=nBase
       Case cCalculo=="A"
            xRet:=nALiq
       Case cCalculo=="V"
            nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
            nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
            xRet:=(nAliq * nBase)/100
    EndCase
Endif
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(xRet)
