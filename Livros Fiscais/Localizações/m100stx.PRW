#include "SIGAWIN.CH"        
#DEFINE _NOMEIMP   01 
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100STX	� Autor � Leonardo Ruben       � Data � 08.08.2000 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � CALCULO DA "SALES TAX" PARA OS ESTADOS UNIDOS               ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Localizacoes                                                ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���Ronny Ctvrtnik|01/02/01�      �Reforma para codigo em cada aliq.        ���
���Luis Enriquez |06/12/18�DMINA-�Rep. DMINA-381Se modifica funcion M100STx���
���              |(EUA)   �1012  �para calculo de impuesto STX en facturas ���
���              |        �      �de entrada.                              ���
���              |        �      �Rep. DMINA-655 se toman valor de SA1 para���
���              |        �      �Cliente Revendedor o Cons. Final y se    ���
���              |        �      �agrega F1_TPACTIV func. M100STx          ���
���Vero Flores   |01/02/19�DMINA-�Replica del DMINA-5414 Se modifica       ���
���              |(EUA)   �5952  � funcion M100STx para calculo de impuesto���
���              |        �      �STX en pedidos de compra.                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function M100STx(cCalculo,nItem,aInfo)
Local lRet      := .T.
Local cTipoCli  := "" 
Local cAgeRet   := ""
Local cAliasRot := Alias()
Local cOrdemRot := IndexOrd()
Local aItemInfo,aImposto,lXFis,cImp,xRet,nOrdSFC,nRegSFC
Local nBase    := 0
Local nAliq    := 0
Local cCodMun  := ""
Local cZonFis  := ""
Local nCodTab  := TamSx3("FF_COD_TAB")[1]      
Local cTipCtbr := ''
Local cActiv   := ''                           


lXFis := (MaFisFound() .and. ProcName(1)  <> "EXECBLOCK")

If !lXFis
   aItemINFO:=ParamIxb[1]
   aImposto:=ParamIxb[2]
   cImp := aImposto[1]
   xRet := aImposto
Else
   cImp := aInfo[1]
   xRet := 0
Endif   



If cModulo == 'FAT' .or. cModulo == 'TMK' .or. cModulo == 'FRT'
   cTipoCli   := SA1->A1_TIPO
   cZonNum    := SA1->A1_CODZON // Codigo ref. FF_NUM                 
   cAgeRet    := SA1->A1_RETIVA
Else
   cTipoForn  := SA2->A2_TIPO
   cZonNum    := SA2->A2_CODZON // Codigo ref. FF_NUM
   cAgeRet    := SA2->A2_RETIVA
Endif

//������������������������������������Ŀ
//�Verifica se e agente de retencao    �
//��������������������������������������
lRet := (cAgeRet=="1")  // sim

If lRet
	//Verifica na SFF se existe ZonFis correspondente para:
	// * Calculo de Imposto;
	// * Obtencao de Aliquota;
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1)) //FB_FILIAL + FB_CODIGO
	If SFB->(dbSeek(xFilial("SFB") + cImp))
		lRet := .T.
		
		  IF FUNNAME() $ 'MATA101N/MATA121' //factura de entrada | pedido de compra
			cTipCtbr := Alltrim(SM0->M0_COD_ATV)
			cActiv   := SubStr(SM0->M0_DSCCNA,1,nCodTab)
		  cCodMun   :=  IIF(FUNNAME() == 'MATA101N',M->F1_CODMUN,SA2->A2_COD_MUN) //MAFISRET(,'NF_CODMUN')
           ELSEIF  FUNNAME()=='MATA465N'//Nota de credito
			cTipCtbr := SA1->A1_CONTRBE
			cActiv   := M->F1_TPACTIV
			cCodMun   :=  M->F1_CODMUN //MAFISRET(,'NF_CODMUN')
		EndIf    	    
       
		If cTipCtbr == '2' //REVENDEDOR 
			nAliq := 0
		ElseIf  cTipCtbr  == '1'
			nAliq  := SFB->FB_ALIQ
			// Si el emisor el lugar de entrega tiene presencia
			CC2->(dbSelectArea("CC2"))
			CC2->(dbSetOrder(3)) //CC2_FILIAL+CC2_CODMUN
			If CC2->(MsSeek(xFilial("CC2") + cCodMun))
				SFF->(dbSelectArea("SFF"))
				SFF->(dbSetOrder(18))//FF_FILIAL + FF_IMPOSTO + FF_CODMUN + FF_CFO_V
			   			
				If SFF->(MsSeek(xFilial("SFF") + cImp))  //Busca por impuesto		
					If CC2->CC2_PRESEN == '1' //Proveedor NO tiene presencia fisica	
						cCodMun   :=  IIF(FUNNAME() == 'MATA101N',M->F1_CODMUN,SA2->A2_COD_MUN)
					Else  //Proveedor SI tiene presencia fisica	
						cCodMun :=IIF(FUNNAME() == 'MATA101N',M->F1_PROVENT,SA2->A2_COD_MUN) 
				 	EndIf
				 	
				 	CC2->(dbSelectArea("CC2"))
					CC2->(dbSetOrder(3)) //CC2_FILIAL+CC2_CODMUN
					If CC2->(MsSeek(xFilial("CC2") + cCodMun))
				 			cZonFis:= CC2->CC2_EST
				 	Else		
				 			cZonFis:=''
				 	EndIf
				 			
				 	SFF->(dbSelectArea("SFF"))
				 	While !SFF->(EOF())       	
						If SFF->FF_IMPOSTO == cImp .and. SFF->FF_ZONFIS == cZonFis ;
							.AND. SFF->FF_CODMUN == cCodMun ;
							.AND. SFF->FF_COD_TAB == cActiv
								nAliq  := SFF->FF_ALIQ // Alicuota de Zona Fiscal 
			      		EndIf
			      		SFF->(DbSkip())
		      		EndDo
				EndIf
			EndIf	
		EndIf             
	   If lRet 
  	   	  If !lXFis
	         nBase  := aItemINFO[_VLRTOTAL] + aItemINFO[_FLETE] + aItemINFO[_GASTOS] // Base de C�lculo
			 aImposto[_ALIQUOTA] := nAliq
	   	     aImposto[_BASECALC] := nBase 
             If Subs(aImposto[5],4,1) == "S"  
  		        aImposto[_BASECALC]	-=	aImposto[18]
		        nBase := aImposto[_BASECALC]
	         Endif	   	     	   	     
	   	     aImposto[_IMPUESTO]  := Round(nBase * ( nAliq/100) ,2)
	   	     xRet := aImposto
	   	  Else               
	   	     nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
	   	     If cCalculo $ "B|V"	   	     
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
             EndIf                   
	   	     Do Case
		        Case cCalculo=="B"		        
                     xRet:=nBase
       		    Case cCalculo=="A"
		             xRet:=nAliq
		        Case cCalculo=="V"
           		     xRet:=(nAliq * nBase)/100
			 EndCase
	   	  Endif   
	   Endif   
	Endif
EndIf
	
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( xRet ) 
