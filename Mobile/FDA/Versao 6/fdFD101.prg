#INCLUDE "FDFD101.ch"
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
Local nNotas   := 0, nTotNot := 0
SetText(oBox,aOptions[nOpt])
aSize(aShow,0)
If nOpt == 1
	If HAT->(dbSeek(cData))
		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
			If HAT->AT_FLGVIS == "1"
				HA1->(dbSetOrder(1))
				HA1->(dbSeek(HAT->AT_CLI))
				AADD(aShow,{ HA1->A1_NOME, HAT->AT_LOJA })
				nOcor++
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
	If HAT->(dbSeek(cData))
		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
	 		If HAT->AT_FLGVIS == "2"
	 			HA1->(dbSetOrder(1))
	 			HA1->(dbSeek(HAT->AT_CLI))
		  		HX5->(dbSeek("OC"+HAT->AT_OCO))
	      		AADD(aShow,{ HA1->A1_NOME, HAT->AT_LOJA ,HX5->X5_DESCRI })
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
 	If HAT->(dbSeek(cData))
   		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
   			If HAT->AT_FLGVIS == "1"
     			nPedidos++                
	  			nItems   += HAT->AT_QTDIT
       			nTotVend += HAT->AT_VALPED
    		ElseIf HAT->AT_FLGVIS == "2"
      			nOcor++
   			EndIf
   			nVisitas++
   			HAT->(dbSkip())
	 	End
  	EndIf	
  	AADD(aShow,{STR0004,AllTrim(Str(nPedidos,0))}) //"Pedidos:"
  	AADD(aShow,{STR0005, Transform(nTotVend,"@E 9999999.99")}) //"Vendas:"
  	AADD(aShow,{STR0006, Transform(if(nPedidos>0,nTotVend/nPedidos,0),"@E 9999999.99")}) //"Vendas x pedido:"
  	AADD(aShow,{STR0007, AllTrim(Str(if(nPedidos>0,nItems/nPedidos,0)))}) //"Items x pedido:"
  	AADD(aShow,{STR0008,AllTrim(Str(nVisitas))}) //"Visitas:"
  	AADD(aShow,{STR0009,AllTrim(Str(nOcor))}) //"Ocorr�ncias:"
  	AADD(aShow,{STR0010,Transform(if(nVisitas>0,(100*nPedidos)/nVisitas,0),"@E 999.99")+"%"}) //"% Positiva��o:"
  	HideControl(oPosit)
  	HideControl(oOcorr)
  	SetArray(oResumo,aShow)
  	ShowControl(oResumo)
  	HideControl(oLbl)
ElseIf nOpt == 4
 	If HAT->(dbSeek(cData))
   		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
   			If HAT->AT_FLGVIS == "4"
     			nNotas++                
	  			nItems   += HAT->AT_QTDIT
       			nTotNot  += HAT->AT_VALPED
    		ElseIf HAT->AT_FLGVIS == "4"
      			nOcor++
   			EndIf
   			nVisitas++
   			HAT->(dbSkip())
	 	End
  	EndIf	
  	AADD(aShow,{STR0011,AllTrim(Str(nNotas,0))}) //"Notas:"
  	AADD(aShow,{STR0005, Transform(nTotNot,"@E 9999999.99")}) //"Vendas:"
  	AADD(aShow,{STR0012, Transform(if(nNotas>0,nTotNot/nNotas,0),STR0013)}) //"Vendas x Notas:"###"@E 9999999.99"
  	AADD(aShow,{STR0014, AllTrim(Str(if(nNotas>0,nItems/nNotas,0)))}) //"Items x Notas:"
  	AADD(aShow,{STR0008,AllTrim(Str(nVisitas))}) //"Visitas:"
  	AADD(aShow,{STR0009,AllTrim(Str(nOcor))}) //"Ocorr�ncias:"
  	AADD(aShow,{STR0010,Transform(if(nVisitas>0,(100*nNotas)/nVisitas,0),"@E 999.99")+"%"}) //"% Positiva��o:"
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

if !MsgYesOrNo(STR0015,STR0016) //"Limpa hist�rico de atendimento?"###"Fechamento do Dia"
  return
endif

MsgStatus(STR0017) //"Aguarde..."
HA1->(dbSetOrder(1))
HAT->(dbGoTop())
While !HAT->(Eof())
   if HA1->(dbSeek(HAT->AT_CLI))
      HA1->A1_FLGVIS := ""
   endif
   HAT->(dbSkip())
end
HAT->(__dbZap())
ClearStatus()
FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

Return Nil
