#INCLUDE "SFFD101.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FDData			   �Autor - Ary Medeiros � Data �27/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Seleciona data para o Fechamento do Dia		 			  ���
�������������������������������������������������������������������������Ĵ��
���Acao :    �Click no Botao oBtn Caption Data                      	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oData      -> Campo Data da Consulta						  ���
���			 �dData      -> Data da Consulta    						  ���
���			 � * Parametros para uso no FDChange 						  ���
���			 �nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/***************************************************************************/
/* Seleciona data para o Fechamento do Dia                                 */
/***************************************************************************/
Function FDData(oData, dData,nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl)

dData := SelectDate(STR0001,dData) //"Selecione data..."
SetText(oData,dData)
FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

Return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FDChange			   �Autor - Ary Medeiros � Data �27/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Seleciona tipo de view:     					 			  ���
���			 � 1-) Clientes Positivados    					 			  ���
���			 � 2-) Clientes Nao Positivados    					 		  ���
���			 � 3-) Resumo do Dia        					 			  ���
�������������������������������������������������������������������������Ĵ��
���Acao :    �Click no ListBox oLbx                     				  ���
���          �FechamentoDia()		                     				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nOpt       -> Tipo View 									  ���
���			 �aOptions   -> Array do Tipo View     						  ���
���			 �oBox       -> Box do Tipo View            				  ���
���			 �oPosit     -> Box dos Clientes Positivados				  ���
���			 �oOco       -> Box dos Clientes nao Positivados			  ���
���			 �oResumo    -> Box do Resumo do Dia     					  ���
���			 �dData      -> Data da Consulta    						  ���
���			 �aShow      -> Array do Resultado do Tipo View selecionado   ���
���			 �oLbl       -> Label Tipo View  							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)
Local nPedidos := 0, nTotVend := 0, nItems := 0, nVisitas := 0, nOcor := 0
Local cData    :=dTos(dData)
Local cLastCliLoj := "", nTot := 0
Local cSFABONU := "F" ,cTesBon := ""
Local nTotQuant := 0
SetText(oBox,aOptions[nOpt])
aSize(aShow,0) 

If nOpt == 1
	dbSelectArea("HAT")
	dbSetOrder(1)
	If HAT->(dbSeek(RetFilial("HAT") + cData))
		While !HAT->(Eof()) .And. DtoS(HAT->HAT_DATA) == cData
			If HAT->HAT_FLGVIS == "1"                                
				If (HAT->HAT_CLI + HAT->HAT_LOJA) != cLastCliLoj
					HA1->(dbSetOrder(1))
					HA1->(dbSeek(RetFilial("HA1") + HAT->HAT_CLI + HAT->HAT_LOJA))
					// Posicao 3 = Concatenacao do Codigo do Cliente e da Loja
					AADD(aShow,{ HA1->HA1_NOME, HAT->HAT_LOJA, HA1->HA1_COD + HA1->HA1_LOJA})
					cLastCliLoj := HAT->HAT_CLI + HAT->HAT_LOJA
					nOcor++
				EndIf
			EndIf
			HAT->(dbSkip())
		End
	EndIf
	
	HideControl(oOcorr)
	HideControl(oResumo)
	SetArray(oPosit,aShow)
	ShowControl(oPosit)
	SetText(oLbl,STR0002 + AllTrim(Str(nOcor))) //"Clientes positivados: "
	ShowControl(oLbl)
ElseIf nOpt == 2
	If HAT->(dbSeek(RetFilial("HAT") + cData))
		While !HAT->(Eof()) .And. DtoS(HAT->HAT_DATA) == cData
	 		If HAT->HAT_FLGVIS == "2"
	 			HA1->(dbSetOrder(1))
	 			HA1->(dbSeek(RetFilial("HA1") + HAT->HAT_CLI))
		  		HX5->(dbSeek(RetFilial("HX5") + "OC"+HAT->HAT_OCO))
	      		AADD(aShow,{ HA1->HA1_NOME, HAT->HAT_LOJA ,HX5->HX5_DESCRI })
		  		nOcor++
	   		EndIf
	   		HAT->(dbSkip())
		End
  	EndIf
  	HideControl(oPosit)
  	HideControl(oResumo)
  	ShowControl(oOcorr)
  	SetText(oLbl,STR0003 + AllTrim(Str(nOcor))) //"Ocorr�ncias: "
  	ShowControl(oLbl)
ElseIf nOpt == 3
    
dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek(RetFilial("HCF") + "MV_SFABONU")   
   cSFABONU := AllTrim(HCF->HCF_VALOR)
EndIf

If dbSeek(RetFilial("HCF") + "MV_BONUSTS")   
   cTesBon:=AllTrim(HCF->HCF_VALOR)
   If Len(cTesBon) == 5
      cTesBon := Substr(cTesBon,2,3)
   Endif
Endif

If dbSeek(RetFilial("HCF") + "MV_SFTROCA")   
   cTsTroca := AllTrim(HCF->HCF_VALOR) 
   cTesBon:= cTesBon
   cTesBon+=  "/"
   cTesBon+= cTsTroca   
Endif

If cSFABONU == "T" 
   If HAT->(dbSeek(RetFilial("HAT") + cData))                                       
	  While !HAT->(Eof()) .And. DtoS(HAT->HAT_DATA) == cData
   	   	    If HAT->HAT_FLGVIS == "1"
     		   nPedidos++  
    		   nItems   += HAT->HAT_QTDIT              

			   dbSelectArea("HC6")
			   dbSetOrder(1)
			   dbSeek(RetFilial("HC6")+ HAT->HAT_NUMPED)
       		   If HC6->(dbSeek(RetFilial("HC6")+ HAT->HAT_NUMPED )) 
			      While !HC6->(Eof()) .And. HAT->HAT_NUMPED == HC6->HC6_NUM .And. !(HC6->HC6_TES $ cTesBon) 
	   					nTotQuant += HC6->HC6_QTDVEN
          		        nTotVend  += HC6->HC6_VALOR 
	   				    HC6->(dbSkip())		
	   			  EndDo
   		   	   EndIf
   			 
       		   If (HAT->HAT_CLI + HAT->HAT_LOJA) != cLastCliLoj
			  	  cLastCliLoj := HAT->HAT_CLI + HAT->HAT_LOJA
				  nVisitas++
			   EndIf
    		ElseIf HAT->HAT_FLGVIS == "2"
      			   nOcor++
   			EndIf
   			HAT->(dbSkip())
	  Enddo 
   EndIf 

ElseIf cSFABONU == "F"
    If HAT->(dbSeek(RetFilial("HAT") + cData))                                       
	   While !HAT->(Eof()) .And. DtoS(HAT->HAT_DATA) == cData
   			 If HAT->HAT_FLGVIS == "1"
     		    nPedidos++                
	  		    nItems   += HAT->HAT_QTDIT
       		    nTotVend += HAT->HAT_VALPED 
       		    dbSelectArea("HC6")
			    dbSetOrder(1)
			    dbSeek(RetFilial("HC6")+ HAT->HAT_NUMPED)
       		    If HC6->(dbSeek(RetFilial("HC6")+ HAT->HAT_NUMPED )) 
				   While !HC6->(Eof()) .And. HAT->HAT_NUMPED == HC6->HC6_NUM
	   					 nTotQuant += HC6->HC6_QTDVEN
	   				     HC6->(dbSkip())		
	   			   EndDo
   		   		EndIf
   			 
       			If (HAT->HAT_CLI + HAT->HAT_LOJA) != cLastCliLoj
					cLastCliLoj := HAT->HAT_CLI + HAT->HAT_LOJA
					nVisitas++
				EndIf
    		 ElseIf HAT->HAT_FLGVIS == "2"
      			    nOcor++
   			 EndIf
   			 HAT->(dbSkip())
	   Enddo 
    EndIf 
EndIF
     
nTot := nOcor + nVisitas 
AADD(aShow,{STR0004,AllTrim(Str(nPedidos,0))}) //"Pedidos:"
AADD(aShow,{STR0005, Transform(nTotVend,"@E 9999999.99")}) //"Vendas:"
AADD(aShow,{STR0006, Transform(if(nPedidos>0,nTotVend/nPedidos,0),"@E 9999999.99")}) //"Vendas x pedido:"
AADD(aShow,{STR0007, AllTrim(Str(if(nPedidos>0,nItems,0)))}) //"Items x pedido:"
AADD(aShow,{STR0014, AllTrim(Str(if(nPedidos>0,nTotQuant,0)))}) //"Itens Vend."
AADD(aShow,{STR0015, Transform(if(nPedidos>0,nTotVend/nTotQuant,0),"@E 9999999.99")}) //"M�dia Vend."
AADD(aShow,{STR0008,AllTrim(Str(nTot))}) //"Visitas:"
AADD(aShow,{STR0016,AllTrim(Str(nVisitas))}) //"Positivados:"
AADD(aShow,{STR0009,AllTrim(Str(nOcor))}) //"Ocorr�ncias:"
//AADD(aShow,{STR0010,Transform(if(nVisitas>0,(100*nPedidos)/nVisitas,0),"@E 999.99")+"%"}) //"% Positiva��o:"
AADD(aShow,{STR0010,Transform(if(nVisitas>0,(nVisitas/nTot)*100,0),"@E 999.99")+"%"}) //"% Positiva��o:"
HideControl(oPosit)
HideControl(oOcorr)
SetArray(oResumo,aShow)
ShowControl(oResumo)
HideControl(oLbl)
EndIf
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FDClean			   �Autor - Ary Medeiros � Data �27/06/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Limpa historico de atendimento   			 			  ���
�������������������������������������������������������������������������Ĵ��
���Acao :    �Click no Button oBtn Caption "Limpar"                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Todos os Parametros do FDChange, para uso na mesma		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/***************************************************************************/
/* Limpa historico de atendimento                                          */
/***************************************************************************/
Function FDClear(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

if !MsgYesOrNo(STR0011,STR0012) //"Limpa hist�rico de atendimento?"###"Fechamento do Dia"
  return
endif

MsgStatus(STR0013) //"Aguarde..."
HA1->(dbSetOrder(1))
HAT->(dbSeek(RetFilial("HAT")))
//HAT->(dbGoTop())
While !HAT->(Eof())
   If HA1->(dbSeek(RetFilial("HAT") + HAT->HAT_CLI))
      HA1->HA1_FLGVIS := "" 
      dbCommit()
      SetDirty("HA1",HA1->(RECNO()),.F.)
   endif
   HAT->(dbSkip())
end
HAT->(__dbZap())
ClearStatus()
FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

Return Nil
