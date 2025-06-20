#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IMPFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IMPGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5
//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
Function M460ICE(cCalculo,nItem,aInfo)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Local nDesconto	:=	0,xRet,lXFis,cImp,nOrdSFC,nRegSFC
SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,xRet,_CPROCNAME,_CZONCLSIGA")
SetPrvt("_LAGENTE,_LEXENTO,AFISCAL,_LCALCULAR,_LESLEGAL,_NALICUOTA,NALIQ")
SetPrvt("_NVALORMIN,_NREDUCIR,CTIPOEMPR,CTIPOCLI,CTIPOFORN,CZONFIS,CCFO,LRET")
SetPrvt("NFAXDE,NFAXATE,CRETICA,CMVAGENTE,NPOSLOJA,NPOSFORN,LRETCF")
/*/
___________________________________________________________________________
└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└ └
└+----------------------------------------------------------------------+└
└쪭uncion   쪴460ICE  � Autor � Denis Martins          쪭echa � 22.07.99└�
└+----------+-----------------------------------------------------------└�
└쪫escrip.  � Programa que Calcula ICA - Imposto Industria y Comercio   └�
└+----------+-----------------------------------------------------------└�
└쪾so       � MATA460                                                   └�
└+----------------------------------------------------------------------└�
└�         ACTUALIZACIONES EFECTUADAS DESDE LA CODIFICACION INICIAL     └�
└+----------------------------------------------------------------------└�
└쪷rogramador � Fecha  � BOPS �  Motivo de la Alteracion                └�
└+------------+--------+------+-----------------------------------------└�
└쪹ubens Pante�28/01/02� xxxx 쪴udado interpretacao da Aliquota para "por└�
└�            �        � xxxx 쫗il" ao inves de "por cento". Retirado    └�
└�            �        � xxxx 쪨llTrim() ao pegar CFO, pois o CFO e chave└�
└�            �        � xxxx 쫉e pesquisa.                              └�
└쪶scar G.    �15/10/18쪫MINA-3756쪩ase de c�lculo sin restar descuentos.└�
└�            �        �          쪬CU                                   └�
└+----------------------------------------------------------------------+└
└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└
�����������������������������������������������������������������������������
*/
lRet := .F.
lRetCF := .T.
	
If cPaisLoc == 'EQU'
	xRet:=M460ICEEQU(cCalculo,nItem,aInfo)
Else
	lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
	// .T. - metodo de calculo utilizando a matxfis
	// .F. - metodo antigo de calculo
	cAliasRot  := Alias()
	cOrdemRot  := IndexOrd()
	
	If !lXFis
		aItemINFO  := ParamIxb[1]
		xRet   := ParamIxb[2]
		cImp:=xRet[1]
	Else
		xRet:=0
		cImp:=aInfo[X_IMPOSTO]
		SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
	Endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eve-se verificar se cEspecie pertence a NCC/NCE/NDC/NDE para que ocor-�
	//퀁a busca no SA1, caso contrario deve-se buscar no SA2(Arq.Proveedores) �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If cModulo$'COM|EST|EIC'
		cTipoCliFor:= SA2->A2_TIPO
		cZonfis    := SA2->A2_EST
		If SA2->(FieldPos("A2_RETICA"))>0 
			cRetICA    := SA2->A2_RETICA
		Endif
		If SA2->(FieldPos("A2_CODICA"))>0 
			cCodICA    := SA2->A2_CODICA
		EndiF
	Else
		cTipoCliFor:= SA1->A1_TIPO
		cZonfis    := SA1->A1_EST
		If SA1->(FieldPos("A1_RETICA"))>0 
			cRetICA    := SA1->A1_RETICA
		Endif
		If SA1->(FieldPos("A1_CODICA"))>0 	
			cCodICA    := SA1->A1_CODICA
		EndIf	
	Endif
	
	// Busca o CFO do Tes Correspondente - SF4
	dbSelectArea("SF4")
	cCFO := SF4->F4_CF
	
	//Verifica na SFF se existe ZonFis correspondente para:
	// * Calculo de Imposto;
	// * Obtencao de Aliquota;
	// * Faixa de Imposto De/Ate.
	
	If cTipoCliFor == "3"
		lRetCF := .F.
	Else
		lRetCF := .T.
	Endif
	
	If lRetCF
		If cRetICA == "S"
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�{�
	//쿣erifico se existe no SFB, SFB->FB_ALIQ e SFB->FB_TABELA�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�{�
	If lRet
		If If(!lXFis,.T.,cCalculo$"AB")
			dbSelectArea("SFB")
			dbSetOrder(1)
			If dbSeek(xFilial("SFB")+cImp)
				If SFB->FB_TABELA == "N"
					If FB_FLAG != "1"
						RecLock("SFB",.F.)
						Replace FB_FLAG With "1"
					Endif
					nAliq   := SFB->FB_ALIQ
					If !lXFis
						xRet[02] := SFB->FB_ALIQ
					Endif
					nBase := 1
					lRet  := .T.
				Else
					dbSelectArea("SFF")
					dbSetOrder(5)
					If dbseek(xFilial("SFF")+cImp+cCFO+cZonfis)
						While !Eof()
							If SFF->FF_COD_TAB == cCodIca
								If FF_FLAG != "1"
									RecLock("SFF",.F.)
									Replace FF_FLAG With "1"
								Endif
								nAliq   := SFF->FF_ALIQ
								nFaxDe  := SFF->FF_FXDE
								nBase   := ( SFF->FF_PERC / 100 )
								lRet := .T.
								Exit
							Else
								lRet := .F.
							EndIf
							dbSkip()
						EndDo
					Else
						nBase   := 1
						nAliq   := 1
						lRet    := .T.
					Endif
				Endif
			Endif
		Endif
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿙o caso de nao estar cadastrado o campo SA1->A1_CODICA - Nao se Calcula�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If lRet
			If !lXFis
				//Tira os descontos se for pelo liquido .Bruno
				If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
					nDesconto	:=	xRet[18]
				Else
					nDesconto	:=	0
				Endif
				xRet[02]  := nAliq // Alicuota de Zona Fiscal
				xRet[03]  := ( aItemINFO[3] + aItemINFO[4] + aItemINFO[5]- nDesconto) * nBase
				//+---------------------------------------------------------------+
				//� Efectua el C�lculo del Impuesto, no caso do ICA a taxa sera   �
				//� calculada por mil(1000)                                       �
				//+---------------------------------------------------------------+
				If !Empty(cCodIca)
					xRet[04]  := round(xRet[03] * ( xRet[02]/1000) ,2)
				Else
					xRet[04]  := round(xRet[03] * ( xRet[02]/100) ,2)
				Endif
			Else
				Do Case
					Case cCalculo=="A"
						xRet:=nAliq
					Case cCalculo=="B"
						xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
						//Tira os descontos se for pelo liquido
						nOrdSFC:=(SFC->(IndexOrd()))
						nRegSFC:=(SFC->(Recno()))
						SFC->(DbSetOrder(2))
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							If SFC->FC_LIQUIDO=="S"
								xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
							Endif
						Endif
						SFC->(DbSetOrder(nOrdSFC))
						SFC->(DbGoto(nRegSFC))
						xRet:=xRet*nBase
					Case cCalculo=="V"
						nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
						nALiq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
						If !Empty(cCodIca)
							xRet:=nBase * ( nAliq/1000)
						Else
							xRet:=nBase * ( nAliq/100)
						Endif
				EndCase
			Endif
		Endif
	Endif
	dbSelectArea( cAliasRot )
	dbSetOrder( cOrdemRot )
EndIf
Return( xRet )        

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿘460ICEEQU튍utor  쿝enato Nagib        � Data �  15/06/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �  Calcula o imposto ICE para Equador                        볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       �                  Equador                                   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function M460ICEEQU(cCalculo,nItem,aInfo)

	Local lXFis
	Local lCalc
	Local xRet
	Local ValMerc
	Local nBase
	Local nAliq
	Local nValImp	
	Local aArea		:=GetArea()
	Local aAreaSFB	:=SFB->(GetArea())
	
	If MaFisFound()
		lXFis := .T.
		lCalc := .T.
	ElseIf ProcName(2)=="EXECBLOCK"
		lXFis := .F.
		lCalc := .T.
	Else
		xRet  := 0
		lCalc := .F.
	EndIF
	
	If lCalc
		
		//Calculo para rotina manual
		If lXFis
			If cCalculo == 'B'
				ValMerc:= MaFisRet(nItem,"IT_VALMERC")
				nBase:=ValMerc
				xRet:=nBase
			ElseIf cCalculo == 'V'
            	ValMerc:= MaFisRet(nItem,"IT_VALMERC")
            	nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				nALiq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
            	xRet:=nBase * ( nAliq/100)
	        ElseIf cCalculo == 'A'
				cProd 	:= MaFisRet(nItem,"IT_PRODUTO")
				dbSelectArea('SB1')
				dbSetOrder(1)
				If dbSeek(xFilial('SB1')+cProd)
					If SB1->B1_ALIQICE > 0
						nAliq:=SB1->B1_ALIQICE
					Else	
						dbSelectArea('SFB')
						dbSetOrder(1)
						If dbSeek(xFilial('SFB')+aInfo[1])
							nAliq:=SFB->FB_ALIQ
						EndIf
					EndIf
				EndIf
				xRet:=nAliq				 	
			EndIf	
		
		//Calculo para rotina automatica
		Else
			aItemINFO 		:= AClone( ParamIxb[1] )
			aImposto		:= AClone( ParamIxb[2] )
			
			//Aliquota
			cProd:=aImposto[16]
			dbSelectArea('SB1')
			dbSetOrder(1)
			If dbSeek(xFilial('SB1')+cProd)
				If SB1->B1_ALIQICE > 0
					nAliq:=SB1->B1_ALIQICE
				Else	
					dbSelectArea('SFB')
					dbSetOrder(1)
					If dbSeek(xFilial('SFB')+aInfo[1])
						nAliq:=SFB->FB_ALIQ
					EndIf
				EndIf
			EndIf
			
			aImposto[2]		:=nAliq
			aImposto[3]		:=aItemINFO[3]// Base de Calculo
			aImposto[4]		:=((aItemINFO[3] * nAliq)/100) 
			xRet	 	 	:= aImposto
		EndIf
		
	EndIf			

	RestArea(aArea)
	RestArea(aAreaSFB)

Return (xRet)
