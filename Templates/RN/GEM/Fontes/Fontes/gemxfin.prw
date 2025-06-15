#INCLUDE "PROTHEUS.CH"
#INCLUDE "gemxfin.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMCondPagt� Autor � Reynaldo Miyashita    � Data �17.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a condicao de pagamento esta vinculado com       ��� 
���          � uma condicao de venda.                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GMCondPagto()                                               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lCondicao = .T., a condicao de pagamento �h vinculada        ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMCondPagto()
Local aArea       := GetArea()
Local lCondicao   := .F. 
Local lExiste     := .F. 
Local cCndPagto   := iIf( ParamIxb[1] == NIL ,"" ,ParamIxb[1] )
Local cTipoTitulo := iIf( ParamIxb[2] == NIL ,"" ,ParamIxb[2] )
       
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( .F. )
EndIf
               
	// condicoes de pagamento
	dbSelectArea("SE4")
	dbSetOrder(1) // E4_FILIAL+E4_CODIGO
	If SE4->(FieldPos("E4_CODCND")) > 0 
		// se existir a condicao de pagamento
		If dbSeek(xFilial("SE4")+cCndPagto)  
		
			If cCndPagto == GetMV("MV_GMCPAG")
				lExiste := .T. 
			Else
				// Foi informado uma condicao de venda
				If ! empty(SE4->E4_CODCND)
					lExiste := .T. 
				EndIf
			EndIf
			
			If lExiste .AND. ((cTipoTitulo == "") .OR. (cTipoTitulo $ MVPROVIS))
				lCondicao := .T.
			EndIf
		EndIf
	EndIf
	
	RestArea( aArea )
	
Return lCondicao


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMTipTit � Autor � Reynaldo Miyashita    � Data �04.05.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Tipo de titulo a gravado na tabela SE1 na gera��o  ��� 
���          � dos titulos a receber no faturamento.                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GEMTipTit()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cTipoTit - C�digo do tipo de titulo                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMTipTit()
Local cTipoParc  := ParamIxb[1]
Local dVenctoTit := ParamIxb[2]
Local cCond      := iIf( ParamIxb[3] == NIL ,space(TamSX3("F2_COND")) ,ParamIxb[3] )

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( cTipoParc )
EndIf

	If ! Empty(cCond)
		If ExistTemplate("GMCondPagto")
			If ExecTemplate("GMCondPagto",.F.,.F.,{cCond,} )
				// se o mes/ano de vencimento for maior que o mes/ano corrente,
				// o titulo deve ser provisorio
				If left(dtos(dVenctoTit),6) > left(dtos(dDatabase),6)
					cTipoParc := MVPROVIS
				EndIf
			EndIf
		EndIf
	EndIf
	
Return cTipoParc


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMCondicao� Autor � Reynaldo Miyashita    � Data �17.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Gera os data de vencimentos e parcelas para serem gerados    ��� 
���          � os titulos conforme o codigo de condicao de venda.           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GMCondicao()                                                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Data de vencimento do titulo                ���
���          � aTitulos[n][2] - Valor do titulo                             ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
���������������A���������������������������������������������������������������
/*/
Template Function GMCondicao()
Local aArea     := GetArea()
Local cCndPagto := iIf( ParamIxb[1] == NIL ,""        ,ParamIxb[1] )
Local dPriVenc  := iIf( ParamIxb[2] == NIL ,dDatabase ,ParamIxb[2] )
Local nCapital  := iIf( ParamIxb[3] == NIL ,0         ,ParamIxb[3] )
Local lCompleto := iIf( ParamIxb[4] == NIL ,.F.       ,ParamIxb[4] )
Local aTitGer   := {}
Local aTitulos  := {}
Local aCondVnd  := {}

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( {} )
EndIf

	// busca a condicao de pagamento
	dbSelectArea("SE4")	
	SE4->(dbSetOrder(1)) // E4_FILIAL+E4_CODIGO
	If MsSeek( xFilial("SE4")+cCndPagto )
		// se existe um codigo de condicao de venda e existe capital a ser financiado.
		If ! Empty(SE4->E4_CODCND) .AND. nCapital > 0
			aTitGer := T_GMTitCndVnd( SE4->E4_CODCND ,dPriVenc ,nCapital )
			
			// Gera as parcelas conforme a condicao de venda informado
			If lCompleto
				aTitulos := aClone(aTitGer)
			Else
				//
				// aTitulo[3] - Data de Vencimento 
				// aTitulo[5] - Valor da parcela
				//
				aEval(aTitGer,{|aTitulo| aAdd( aTitulos,{ aTitulo[3],aTitulo[5]}) })
			EndIf
		Endif
	EndIf
	restArea(aArea)
	
Return( aTitulos )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMCndVndTi� Autor � Reynaldo Miyashita    � Data �10.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Gera os titulos de acordo com a condicao de venda            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GMCnd1VndTit( cCondVnd ,cItem ,dPriVenc ,nCapital )         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cCondVnd - Codigo da condicao de venda                       ���
���          � cItem - Item da condicao de venda                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nCapital - Valor a ser financiado                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aNewTit[n][1] - Item da condicao de venda                    ���
���          � aNewTit[n][2] - Parcela do titulos                           ���
���          � aNewTit[n][3] - Data de vencimento do titulo                 ���
���          � aNewTit[n][4] - Valor do titulo                              ���
���          � aNewTit[n][5] - Juros Fcto                                   ���
���          � aNewTit[n][6] - Saldo devedor                                ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/                                                          
Template Function GMTitCndVnd( cCondVnd ,dPriVenc ,nCapital )
Local aArea    := {}
Local nGrp     := 0
Local nCount   := 0
Local nCnt2    := 0
Local aTitulos := {}
Local aTmpTit  := {}
Local aNewTit  := {}
Local aConjunto := {}
Local nPerCorr := 0
Local lItCND   := .F.
Local dJurIni  := stod("")

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( {} )
EndIf

aArea    := GetArea()

// corrige o tamanho da variavel de acordo com o SX3 do campo
cCondVnd := padr(cCondVnd ,TamSx3("LIS_CODCND")[1])

// existencia da condicao de venda (cabecalho)
dbSelectArea("LIR")
dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
If MsSeek( xFilial("LIR")+cCondVnd )
	// existencia de itens da condicao de venda (item)
	dbSelectArea("LIS")
	dbSetOrder(1) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
	MsSeek( xFilial("LIS")+cCondVnd )
	While xFilial("LIS")+LIS->LIS_CODCND == LIR->LIR_FILIAL+LIR->LIR_CODCND
		lItCND   := .T.
		// se o item da condicao de venda estah ativo
		If LIS->LIS_ATIVO == "1"
		
			dJurIni := dPriVenc
			
			// existencia do tipo de titulo para obtencao do intervalo entre titulos.
			dbSelectArea("LFD")
			dbSetOrder(1) // LFD_FILIAL+LFD_COD
			If MsSeek( xFilial("LFD")+LIS->LIS_TIPPAR )
				// calcula o valor a ser financiado neste item de condicao de venda
				nVlrFin := round( nCapital * (LIS->LIS_PERCLT/100) ,TamSX3("E1_VALOR")[2])
			
				nPerCorr := 0 //LFD->LFD_INTCOR
			
				// gera os titulos de acordo com o sistema de amortizacao escolhida.
				aTitulos := T_GMGeraTit( LIS->LIS_TPSIST ,dPriVenc ,LIS->LIS_TAXANO ,LFD->LFD_INTERV ;
				                        ,LIS->LIS_NUMPAR ,nVlrFin ,/*% do indice de correcao*/ ,nPerCorr ,LIS->LIS_TPPRIC ,dJurINI )
				
				//
				aAdd( aConjunto ,{ LIS->LIS_ITEM ;
				                  ,LIS->LIS_TIPPAR ;
				                  ,LIS->LIS_TPDESC ;
				                  ,iIf(LFD->(FieldPos("LFD_EXCLUS"))>0,iIf(Empty(LFD->LFD_EXCLUS),"2",LFD->LFD_EXCLUS),"2") ;
				                  ,LFD->LFD_INTERV ;
				                  ,aTitulos } )
				
			EndIf
		EndIf
		dbSelectArea("LIS")
		dbSkip()
	Enddo
	
	// reordena as datas das parcelas
	GMPRCPARC( @aConjunto ) 
	
	// se naum encontrou nenhum item da condicao de venda
	If ! lItCND
		Alert(STR0001 + LIR->LIR_CODCND + "-"+LIR->LIR_DESCRI) //"N�o foi encontrado os itens da condicao de venda: "
	Else           
		//
		// aTitulos[1] Item da condicao de venda
		// aTitulos[2] Numero da Parcela do Titulo
		// aTitulos[3] Data de Vencimento
		// aTitulos[4] Descricao do Tipo de Parcela
		// aTitulos[5] Valor da Parcela
		// aTitulos[6] Valor Juros Financiado
		// aTitulos[7] Saldo Devedor
		//
		aTitulos := {}
		For nCount := 1 To Len( aConjunto )
			For nCnt2 := 1 To Len( aConjunto[nCount][6] )
				aAdd( aTitulos ,{ aConjunto[nCount][1]           ; // [1] Item da condicao de venda
				                 ,aConjunto[nCount][6][nCnt2][1] ; // [2] Numero da Parcela do Titulo 
				                 ,aConjunto[nCount][6][nCnt2][2] ; // [3] Data de Vencimento 
				                 ,aConjunto[nCount][3]           ; // [4] Descricao do Tipo de Parcela
				                 ,aConjunto[nCount][6][nCnt2][3] ; // [5] Valor da Parcela
				                 ,aConjunto[nCount][6][nCnt2][4] ; // [6] Valor Juros Financiado
				                 ,aConjunto[nCount][6][nCnt2][5] ; // [7] Saldo Devedor
				               })
			Next nCnt2
		Next nCount

		// ordena pela data de vencimento e item da condicao de venda
		aSort( aTitulos ,,,{|x,y|dtos(x[3])+x[1] < dtos(y[3])+y[1]} )
		
		// re-ordena os numeros da parcela
		For nCount := 1 To len(aTitulos) 
			aAdd(aTitulos[nCount] ,aTitulos[nCount][2])
			aTitulos[nCount][2] := nCount
		Next nCount 
	EndIf
	
EndIf

restArea(aArea)

Return aTitulos


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMGeraTit � Autor � Reynaldo Miyashita    � Data �01.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com os Titulos                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GMGeraTit( cSistema ,dPriVenc ,nTaxa ,nIntervalo ;          ���
���          �            ,nQtdTitulos ,nCapital )                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cSistema - Codigo do sistema de amortizacao(1-Price,2-SACRE, ���
���          �            3-SAC,4-NENHUM)                                   ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nTaxa - Valor da taxa anual em porcentagem                   ���
���          � nIntervalo  - Intervalo(tempo) entre as titulos              ���
���          � nQtdTitulos - Quantidade de titulos                          ���
���          � nCapital    - Valor a ser financiado                         ���
���          � nInd - Percentual do reajuste dos juros da prestacoes        ���
���          � nPerCorr - Periodo(meses)de recalculo das prestacoes         ���
���          � cTipoPrice - Se a Price eh Begin ou End                      ���
���          � dJurIni - Data de inicio do juros na prestacao               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMGeraTit( cSistema ,dPriVenc ,nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,nIndCM ,nPerCorr ,cTipoPrice ,dJurIni )
Local aTitulos := {} 
Local nBegin   := 0 //End

DEFAULT nIndCM     := 0
DEFAULT nPerCorr   := 0
DEFAULT cTipoPrice := "2"

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( {} )
EndIf

	Do Case
		// Price
		Case cSistema == "1"
			If cTipoPrice == "1"
				nBegin := 0 //End
			Else
				nBegin := 1 //Begin
			EndIf
			aTitulos := T_GMPrice( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,nBegin ,dJurIni )
		//SACRE
		Case cSistema == "2"
			aTitulos := T_GMSacre( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
		//SAC                                                     
		Case cSistema == "3"
			aTitulos := T_GMSAC( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
			
		// Sem sistema.
		Case cSistema == "4"
			aTitulos := T_GMTit( nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr )
			
		// Juros Simples
		Case cSistema == "5"
			aTitulos := T_GMJURSimp( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
			
		// Juros Composto
		Case cSistema == "6"
			aTitulos := T_GMJURComp( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
			
		// Definido pelo Usuario
		OtherWise
			If ExistBlock("GMFIN01")
				aTitulos := ExecBlock("GMFIN01",.F.,.F.,{cSistema ,nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni })
			EndIf
	EndCase
	
Return( aTitulos )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMPrice    � Autor � Reynaldo Miyashita    � Data �01.03.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com os Titulos calculados no sistema de     ���
���          � amortizacao da PRICE                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GMPrice( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital          ���
���          �            ,dPriVenc ,nInd ,nPerCorr ,nBegin )               ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa - Valor da taxa anual em porcentagem                   ���
���          � nIntervalo - Intervalo(meses) entre as titulos               ���
���          � nQtdTitulos- Quantidade de titulos                           ���
���          � nCapital - Valor a ser financiado                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nInd - Percentual do reajuste dos juros da prestacoes        ���
���          � nPerCorr - Periodo(meses)de recalculo das prestacoes         ���
���          � nBegin - (0)End      (1)Begin                                ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMPrice( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nInd ,nPerCorr ,nBegin ,dJurIni )
Local nTitulo    := 0
Local nMeses     := 0
Local nAmort     := 0
Local aPrestacao := {}
Local aTitulos   := {}
Local nSldoDev   := 0
Local dVencto    := stod("")
Local dInicio    := stod("")
Local nTaxPer    := 0
//Local cConsidera := GetNewPar("MV_GEMJRFA","S") // define se deve considerar o numero de meses antes do 1o vencto para calculo 
                                                // do juros financiado, caso o inicio de juros for antes do 1o vencimento.
dVencto  := dPriVenc
dInicio  := dPriVenc
nSldoDev := nCapital
nQtdSemJF := 0

For nTitulo := 1 To nQtdTitulos

	// calcula a diferenca de meses	
	nMeses := GMDateDiff(dJurIni ,dVencto ,"MM")
	
  /*	    If !(cConsidera=="S")
    	nMeses -= 1
    EndIf */
    
	If nMeses < 0
		nAmort := GMPriTit( 0 ,nQtdTitulos-(nTitulo-1) ,nSldoDev )[1]
		nAmort := Round( nAmort ,2 )
		aPrestacao := { nAmort ,nAmort ,0 ,0 ,0 }
		
		nSldoDev := nSldoDev - aPrestacao[2]
		
		aAdd( aTitulos ,{ nTitulo       ;
		                 ,dVencto       ;
		                 ,aPrestacao[1] ; // valor titulo
		                 ,aPrestacao[3] ; // juros + juros postecipados
		                 ,nSldoDev      ;
		                 ,aPrestacao[2]} ) // valor do amortizado
		
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nIntervalo*nTitulo))
		nQtdSemJF++
	Else
		Exit
	EndIf
	
Next nTitulo

nQtdTitulos -= nQtdSemJF //(nQtdSemJF-1)
nTaxPer     := t_GMCoefSistema( nTaxa ,1 )/100
nSldoDev    := nSldoDev*((1+nTaxPer)^nMeses)
dInicio     := dVencto

If	nQtdTitulos > 1
	nCapital    := nSldoDev
	For nTitulo := 1 To nQtdTitulos
		
		aPrestacao := GMPriPrice( nTaxa ,nInd ,nIntervalo ,nQtdTitulos ,nCapital ,nBegin , ,nTitulo )
		nSldoDev   := nSldoDev - aPrestacao[2]
		
		aAdd( aTitulos ,{ nTitulo       ;
		                 ,dVencto       ;
		                 ,aPrestacao[1] ; // valor titulo
		                 ,aPrestacao[3] ; // juros + juros postecipados
		                 ,nSldoDev      ;
		                ,aPrestacao[2]} ) // valor do amortizado} )
			
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nIntervalo*nTitulo))
		
	Next nTitulo
ElseIf nQtdTitulos == 1
	nJurFin		:= nSldoDev-nCapital
	
 	aAdd( aTitulos 	, { nQtdTitulos  ;
   		           	, dVencto        ;
   	      	        	, nSldoDev		 ; // valor titulo
               		 	, nJurFin  		 ; // juros + juros postecipados
                 		, nSldoDev       ;
                 		, nCapital		 } ) // valor do amortizado} )
EndIf

Return( aTitulos )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMSacre   � Autor � Reynaldo Miyashita    � Data �01.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com as titulos calculados no sistema de     ���
���          � amortizacao da SACRE                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GMSACRE( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital          ���
���          �            ,dPriVenc ,nInd ,nPerCorr )                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa - Valor da taxa anual em porcentagem                   ���
���          � nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nQtdTitulos- Quantidade de titulos                           ���
���          � nCapital - Valor a ser financiado                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nInd - Percentual do reajuste dos juros da prestacoes        ���
���          � nPerCorr - Periodo(meses)de recalculo das prestacoes         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMSacre( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
Local aTitulos   := {}
Local aPrestacao := {}
Local nPrestacao := 0
Local nCount     := 0
Local nDecTaxa   := 0
Local nContaMes  := 0
Local dVencto    := stod("")
Local dInicio    := stod("")
Local nSldoDev   := 0
Local nNum       := 0 
Local nMeses     := 0 

DEFAULT dPriVenc := dDatabase
DEFAULT nIndCM   := 0
DEFAULT nPerCorr := 0
                
	If (dJurIni==NIL) .or. Empty(dJurIni)
		dJurIni  := dPriVenc
	EndIf
	    
	// calcula o coeficente da taxa
	nDecTaxa := t_GMCoefSistema( nTaxa ,nIntervalo )/100
	
	nSldoDev := nCapital
	dVencto  := dPriVenc
	dInicio  := dPriVenc
	
	// Se houve meses antes do inicio do juros financiado
	If (nMeses := GMDateDiff( dVencto ,dJurIni ,"MM" )) >= 0 
		// Valor da prestacao sem juros financiado
		nPrestacao := GMPriTit( 0 ,nQtdTitulos ,nSldoDev )[1]
		nMeses := iIf( nMeses == 0 ,1 ,nMeses )
		nMeses := iIf( nMeses > nQtdTitulos ,nQtdTitulos ,nMeses )

		For nCount := 1 To nMeses

			nSldoDev := nSldoDev - nPrestacao

			aAdd( aTitulos ,{ nCount     ;
			                 ,dVencto    ;
			                 ,nPrestacao ; // valor titulo
			                 ,0          ; // juros + juros postecipados
			                 ,nSldoDev   ;
			                 } )
			//
			// data de vencimento da proxima titulo
			//
			dVencto := GMNextMonth( dInicio ,(nIntervalo*nCount) )

		Next nCount
		
		nQtdTitulos -= nMeses
		nMeses := 0
		
	Else
		nMeses := iIf( (nMeses*-1)>1 ,nMeses*-1 ,0 )
	EndIf
	
	dInicio := dVencto
	nNum := Len(aTitulos)
	For nCount := 1 to nQtdTitulos
	
		nNum++
		// retorna o valor da prestacao
		aPrestacao := GMPriSacre( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos-(nCount-1) ,nSldoDev )
		aPrestacao[1] := Round( aPrestacao[1] ,2 ) // Valor da prestacao
		aPrestacao[2] := Round( aPrestacao[2] ,2 ) // Amortizacao
		aPrestacao[3] := Round( aPrestacao[3] ,2 ) // Juros Mensal + Juros Postecipados
		aPrestacao[4] := Round( aPrestacao[4] ,2 ) // Saldo Devedor

		// Saldo Devedor
		nSldoDev := nSldoDev - aPrestacao[2]
		
		aAdd( aTitulos ,{ nNum          ;
		                 ,dVencto       ;
		                 ,aPrestacao[1] ; // valor titulo
		                 ,aPrestacao[3] ; // juros + juros postecipados
		                 ,nSldoDev      ;
		                 } )
		                 
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nIntervalo*nCount) )

		nContaMes += nIntervalo
		If nContaMes == nPerCorr .and. nPerCorr <> 0
			nContaMes := 0
			
			// retorna o valor da prestacao
			nPrestacao   := GMPriSacre( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos-nCount ,nSldoDev )[1]
			nPrestacao := Round( nPrestacao ,2 )
			
		EndIf
		
	Next nCount

Return( aTitulos )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMSAC     � Autor � Reynaldo Miyashita    � Data � 01.03.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com as titulos calculados no sistema de     ���
���          � amortizacao da SAC                                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GMSAC( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital            ���
���          �            ,dPriVenc ,nInd ,nPerCorr )                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa - Valor da taxa anual em porcentagem                   ���
���          � nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nQtdTitulos- Quantidade de titulos                           ���
���          � nCapital - Valor a ser financiado                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nInd - Percentual do reajuste dos juros da prestacoes        ���
���          � nPerCorr - Periodo(meses)de recalculo das prestacoes         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMSAC( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
Local aTitulos   := {}
Local nPrestacao := 0
Local nAmort     := 0
Local nJurosFcto := 0
Local nCount     := 0
Local nDecTaxa   := 0
Local nContaMes  := 0
Local dVencto    := stod("")
Local dInicio    := stod("")
Local nSldoDev   := 0
Local nNum       := 0 
Local nMeses     := 0

DEFAULT dPriVenc := dDatabase()
DEFAULT nIndCM   := 0
DEFAULT nPerCorr := 0
                
	If (dJurIni==NIL) .or. Empty(dJurIni)
		dJurIni  := dPriVenc
	EndIf
	    
	nSldoDev := nCapital
	dVencto  := dPriVenc
	dInicio  := dPriVenc 
	
	// Se houve meses antes do inicio do juros financiado
	If (nMeses := GMDateDiff( dVencto ,dJurIni ,"MM" )) >= 0 
		// Valor da prestacao sem juros financiado
		nPrestacao := GMPriTit( 0 ,nQtdTitulos ,nSldoDev )[1]
		nMeses := iIf( nMeses == 0 ,1 ,nMeses )
		nMeses := iIf( nMeses > nQtdTitulos ,nQtdTitulos ,nMeses )

		For nCount := 1 To nMeses

			nSldoDev := nSldoDev - nPrestacao

			aAdd( aTitulos ,{ nCount     ;
			                 ,dVencto    ;
			                 ,nPrestacao ; // valor titulo
			                 ,0          ; // juros + juros postecipados
			                 ,nSldoDev   ;
			                 } )
			//
			// data de vencimento da proxima titulo
			//
			dVencto := GMNextMonth( dInicio ,(nIntervalo*nCount) )

		Next nCount
		
		nQtdTitulos -= nMeses
		nMeses := 0
		
	Else
		nMeses := iif( (nMeses*-1)>1, nMeses*-1 ,0 )
	EndIf
	
	// calcula o coeficente da taxa
	nDecTaxa := t_GMCoefSistema( nTaxa ,nIntervalo )/100
	// Valor de Amortizacao
	nAmort   := GMPriSAC( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos ,nSldoDev )[2]
	
	dInicio  := dVencto
	nNum := Len(aTitulos)
	For nCount := 1 to nQtdTitulos
	
		nJurosFcto := t_GMCalcJur( nDecTaxa ,nIndCM/100 ,nSldoDev )
		nPrestacao := nAmort + nJurosFcto
		
		nSldoDev := nSldoDev - nAmort
		nNum++
		
		aAdd( aTitulos ,{ nCount     ;
		                 ,dVencto    ;
		                 ,nPrestacao ;
		                 ,nJurosFcto ;
		                 ,nSldoDev   } )
		
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nIntervalo*nCount) )

		nContaMes += nIntervalo
		If nContaMes == nPerCorr .and. nPerCorr <> 0
			nContaMes := 0
			
			// retorna o valor da prestacao
			nAmort := GMPriSAC( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos-nCount ,nSldoDev )[2]
			nAmort := Round( nAmort ,2 )
			
		EndIf

	Next nCount

Return( aTitulos )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMTit     � Autor � Reynaldo Miyashita    � Data �01.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com as titulos calculadas pela divisao      ���
���          � do Valor a se financiado pelo no. de parcelas                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GMTit( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc )���
���������������������������������������������������������������������������Ĵ��
���Parametros� nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nQtdTitulos- Quantidade de titulos                           ���
���          � nCapital - Valor a ser financiado                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nIndCM -                                                     ���
���          � nPerCorr -                                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMTit( nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr )
Local nCount       := 0
Local aTitulos     := {}
Local dVencto      := stod("")
Local dInicio      := stod("")
Local nSldoDevedor := 0
Local nContaMes    := 0
       
	nSldoDevedor := nCapital*(1+(nIndCM/100)) 
	nPrestacao   := GMPriTit( nIndCM ,nQtdTitulos ,nCapital )[1]
	dVencto      := dPriVenc
	dInicio      := dPriVenc
	
	For nCount := 1 to nQtdTitulos
	
		nSldoDevedor := nSldoDevedor-nPrestacao
	
		aAdd( aTitulos ,{ nCount       ;
                         ,dVencto      ;
                         ,nPrestacao   ;
		                 ,0            ;
                         ,nSldoDevedor } )
		
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nCount*nIntervalo) )
		
		nContaMes += nIntervalo
		If nContaMes == nPerCorr .and. nPerCorr <> 0
			nContaMes  := 0
			// valor da prestacao
			nPrestacao := GMPriTit( nIndCM ,nQtdTitulos-nCount ,nSldoDevedor )[1]
		EndIf

	Next nCount

	If !(nSldoDevedor == 0) .and. Len(aTitulos) >0 
		aTitulos[Len(aTitulos)][3] += nSldoDevedor
		aTitulos[Len(aTitulos)][5] := 0
	EndIf
Return( aTitulos )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMLIXPARC� Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os dados adicionais sobre as prestacoes.               ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GEMLIXPARC()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMLIXPARC()

Local aArea      := {}
Local cPrefixo   := iIf( ParamIxb[ 1] == NIL ,"" ,ParamIxb[ 1] )
Local cNum       := iIf( ParamIxb[ 2] == NIL ,"" ,ParamIxb[ 2] )
Local cParcela   := iIf( ParamIxb[ 3] == NIL ,"" ,ParamIxb[ 3] )
Local cTipo      := iIf( ParamIxb[ 4] == NIL ,"" ,ParamIxb[ 4] )
Local cCondPagto := iIf( ParamIxb[ 5] == NIL ,"" ,ParamIxb[ 5] )
Local nVlrTit    := iIf( ParamIxb[ 6] == NIL ,0  ,ParamIxb[ 6] )
Local aDetTit    := iIf( ParamIxb[ 7] == NIL ,{} ,ParamIxb[ 7] )
Local cItem      := ""
Local CItNum     := ""
Local nJuros     := 0
Local dVenc      := stod("")
Local lContinua  := .F.
    
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If ! HasTemplate("LOT")
	Return( .T. )
Endif

	aArea := GetArea()
	
	If Len(aDetTit) >0 
		cItem      := aDetTit[1] // Item da condicao de venda
		cItNum     := StrZero( aDetTit[2] ,TamSX3("LIX_ITNUM")[1]) // Item do Item da condicao de venda
		dVenc      := aDetTit[3] // Data de Vencimento
		nJuros     := aDetTit[6] // Juros Financiamento do Titulo
	EndIf

	If cCondPagto == GetMV("MV_GMCPAG")
		lContinua := .T.
	Else
		// Verifica se existe o campo da condicao de venda na condicao de pagamento 
		dbSelectArea("SE4")
		If SE4->(FieldPos("E4_CODCND")) > 0 
			dbSetOrder(1) // E4_FILIAL+E4_CODIGO
			If dbSeek(xFilial("SE4")+cCondPagto)
				// Verifica se o cadastro da condicao de pagamento 
				dbSelectArea("LIR")
				dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
				If MsSeek( xFilial("LIR")+SE4->E4_CODCND)
					lContinua := .T.
			    EndIf
		    EndIf
	    EndIf
	EndIf
	
	If lContinua
		dbSelectArea("LIX")
		dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		lEncontrou := LIX->(MsSeek( xFilial("LIX")+cPrefixo+cNum+cParcela+cTipo))

		RecLock("LIX",(!lEncontrou))
		If (!lEncontrou)
			LIX->LIX_FILIAL := xFilial("LIX")
			LIX->LIX_PREFIX := cPrefixo
			LIX->LIX_NUM    := cNum
			LIX->LIX_PARCEL := cParcela
			LIX->LIX_TIPO   := cTipo
			LIX->LIX_CODCND := cCondPagto
			LIX->LIX_ITCND  := cItem
			LIX->LIX_ITNUM  := cItNum // item do item da condicao de venda.
			LIX->LIX_DTVENC := dVenc
		EndIf
		LIX->LIX_ORIAMO := nVlrTit - nJuros
		LIX->LIX_ORIJUR := nJuros
		LIX->(MSUnLock())
		
	EndIf
	
	RestArea( aArea )

Return( .T. )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMCalcJur � Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � calcula o juros baseado no valor informado.                  ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �T_GMCalcJur( nTaxa ,nIndCM ,nValor )                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa  - Valor da Taxa de juros em decimal                   ���
���          � nIndCM - Valor do Indice de Correcao monetaria em decimal    ���
���          � nValor - Valor Base para calculo do Juros                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � nValJuros - Valor do juros                                   ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMCalcJur( nTaxa ,nIndCM ,nValor )
Local nValJuros := 0

DEFAULT nIndCM := 0

	nValJuros := round(((1+nTaxa)*(1+nIndCM)-1)*nValor,2)

Return( nValJuros )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMPriSacre� Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor da prestacao, amortizacao, juros e saldo     ��� 
���            devedor da primeira parcela no Sistema de Amortizacao        ��� 
���            Crescente (SACRE)                                            ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMPriSacre( nTaxa ,nIndCM ,nIntervalo ,nQtdTit ,nCapital )   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa  - Valor da Taxa de juros em percentual                ���
���          � nIndCM - Valor do Indice de Correcao monetaria em percentual ���
���          � nIntervalo - Periodo entre uma prestacao e outra             ���
���          � nQtdTit - Total de parcelas a serem pagas no Financiamento   ���
���          � nCapital - Capital a ser financiado                          ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ARRAY[1] - Valor da prestacao                                ���
���            ARRAY[2] - Valor do Juros                                    ���
���            ARRAY[3] - Valor da Amortizacao                              ���
���            ARRAY[4] - Valor do Saldo Devedor                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GMPriSacre( nTaxa ,nIndCM ,nIntervalo ,nQtdTit ,nCapital )
Local nVlrPrest := 0
Local nJuros    := 0
Local nAmort    := 0
Local nDecTaxa  := 0

	nDecTaxa := t_GMCoefSistema( nTaxa ,nIntervalo )/100

	nAmort := Round( (nCapital/nQtdTit) ,2)
	
	nCapital := round(nCapital*(1+(nIndCM/100)),2)
	
	nJuros := t_GMCalcJur( nDecTaxa ,0 ,nCapital )

	nVlrPrest := nAmort + nJuros 
	
Return( {nVlrPrest ,nAmort ,nJuros ,(nCapital-nAmort) } )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMPriSAC  � Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor da prestacao, amortizacao, juros e saldo     ��� 
���            devedor da primeira parcela no Sistema de Amortizacao        ��� 
���            Constante(SAC)                                               ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMPriSAC( nTaxa ,nIndCM ,nIntervalo ,nQtdTit ,nCapital )     ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa  - Valor da Taxa de juros em percentual                ���
���          � nIndCM - Valor do Indice de Correcao monetaria em percentual ���
���          � nIntervalo - Periodo entre uma prestacao e outra             ���
���          � nQtdTit - Total de parcelas a serem pagas no Financiamento   ���
���          � nCapital - Capital a ser financiado                          ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ARRAY[1] - Valor da prestacao                                ���
���            ARRAY[2] - Valor do Juros                                    ���
���            ARRAY[3] - Valor da Amortizacao                              ���
���            ARRAY[4] - Valor do Saldo Devedor                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GMPriSAC( nTaxa ,nIndCM ,nIntervalo ,nQtdTit ,nCapital )
Local nVlrPrest := 0
Local nJuros := 0
Local nAmort := 0
Local nDecTaxa  := 0
	
	nDecTaxa := t_GMCoefSistema( nTaxa ,nIntervalo )
	
	nAmort := Round( (nCapital/nQtdTit) ,2)
	
	nCapital := round(nCapital*(1+(nIndCM/100)),2)
	
	nJuros := t_GMCalcJur( nDecTaxa/100 ,0 ,nCapital )
	
	nVlrPrest := nAmort + nJuros 
	
Return( {nVlrPrest ,nAmort ,nJuros ,(nCapital-nAmort) } )

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMPriPRICE� Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor da prestacao, amortizacao, juros e saldo     ��� 
���          � devedor da primeira parcela no Sistema de Amortizacao        ��� 
���          � Frances (PRICE)                                              ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMPriPrice( nTaxa ,nIndCM ,nIntervalo ,nQtdTit ,nCapital     ���
���          �            ,nBegin )                                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa  - Valor da Taxa de juros em percentual                ���
���          � nIndCM - Valor do Indice de Correcao monetaria em percentual ���
���          � nIntervalo - Periodo entre uma prestacao e outra             ���
���          � nQtdTit - Total de parcelas a serem pagas no Financiamento   ���
���          � nCapital - Capital a ser financiado                          ���
���          � nBegin - 0 = metodo End (padrao)                             ���
���          �          1 = metodo Begin                                    ���
���          � nPeriodo - Periodo do inicio de juros ate o 1o. vencto.      ���
���          � nParcela - numero de ordem da parcela                        ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ARRAY[1] - Valor da prestacao                                ���
���          � ARRAY[2] - Valor do Juros                                    ���
���          � ARRAY[3] - Valor da Amortizacao                              ���
���          � ARRAY[4] - Valor do Saldo Devedor                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function GMPriPrice( nTaxa ,nIndCM ,nIntervalo ,nQtdTit ,nCapital ,nBegin ,nPeriodo ,nParcela)
Local nVlrPrest  := 0
Local nAmort     := 0
Local nJuros     := 0
Local nDecTaxa   := 0
Local nTaxPer    := 0

DEFAULT nBegin   := 0 //metodo "End"
DEFAULT nPeriodo := 0
DEFAULT nParcela := 0

	// Coeficiente conforme nIntervalo informado, calculo da taxa proporcional
	nDecTaxa := t_GMCoefSistema( nTaxa ,nIntervalo )/100	
	
	If nPeriodo > 0	
		nTaxPer  := t_GMCoefSistema( nTaxa ,1 )/100
		nCapital := nCapital *((1+nTaxPer)^nPeriodo)
	EndIf
	
	nVlrPrest := Round ( nCapital * ( (1+nDecTaxa)^(nQtdTit-nBegin)*nDecTaxa ) / ( (1+nDecTaxa)^nQtdTit-1) ,2)
	
	If nBegin==1 .And. nParcela==1 //se metodo Begin e primeira parcela do financiamento entao
		nAmort := nVlrPrest
	Else
		nAmort := Round( nVlrPrest / ( (1+nDecTaxa)^(nQtdTit-(nParcela-1)) ) ,2)
	EndIf
	nJuros    := nVlrPrest - nAmort
	
	//nVlrPrest := (  (nCapital*    ((nDecTaxa+1)^nQtdTit)   )*nDecTaxa)       / (((nDecTaxa+1)^nQtdTit)-1)
 	//nJuros    := iIf( nQtdTit == 1 .and. nBegin == 1 ,0 ,nCapital*nDecTaxa )
 	//nAmort    := nVlrPrest-nJuros
 	
Return( {nVlrPrest ,nAmort ,nJuros} )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMPriTit  � Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor da prestacao, amortizacao, juros e saldo     ��� 
���            devedor da primeira parcela utilizando a seguinte formula:   ��� 
���            Capital / quantidade de Titulos                              ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMPriTit( nIndCM ,nQtdTit ,nCapital )                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nIndCM - Valor do Indice de Correcao monetaria em percentual ���
���          � nQtdTit - Total de parcelas a serem pagas no Financiamento   ���
���          � nCapital - Capital a ser financiado                          ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ARRAY[1] - Valor da prestacao                                ���
���            ARRAY[2] - Valor do Juros                                    ���
���            ARRAY[3] - Valor da Amortizacao                              ���
���            ARRAY[4] - Valor do Saldo Devedor                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GMPriTit( nIndCM ,nQtdTit ,nCapital )

Local nVlrPrest := 0

	nCapital  := round(nCapital*(1+(nIndCM/100)) ,2)
	nVlrPrest := Round( nCapital / nQtdTit ,2)
	
Return( {nVlrPrest ,nVlrPrest ,0 ,(nCapital-nVlrPrest) } )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMGerPriTi� Autor � Reynaldo Miyashita    � Data �28.03.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor da prestacao, amortizacao, juros e saldo     ��� 
���            devedor da primeira parcela no Sistema de Amortizacao        ��� 
���            Frances (PRICE)                                              ��� 
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GMGerPriTit( cSistema ,nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos���
���                        ,nCapital ,cTipoPrice )                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cSistema - Codigo do Sistema de Amortizacao a ser utilizado  ���
���          � nTaxa  - Valor da Taxa de juros em percentual                ���
���          � nIndCM - Valor do Indice de Correcao monetaria em percentual ���
���          � nIntervalo - Periodo entre uma prestacao e outra             ���
���          � nQtdTitulos - Total de parcelas a serem pagas no Financiament���
���          � nCapital - Capital a ser financiado                          ���
���          � cTipoPrice - '1' = metodo End (padrao)                       ���
���          �              '2' = metodo Begin                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � ARRAY[1] - Valor da prestacao                                ���
���            ARRAY[2] - Valor do Juros                                    ���
���            ARRAY[3] - Valor da Amortizacao                              ���
���            ARRAY[4] - Valor do Saldo Devedor                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMGerPriTit( cSistema ,nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos ,nCapital ,cTipoPrice ,nPeriodo )

Local aTitulo  := {} 
Local nBegin   := 0 //End

DEFAULT nIndCM := 0
DEFAULT cTipoPrice := "2"
	
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios
ChkTemplate("LOT")

    Do Case
	    // Price
		Case cSistema == "1"
			If cTipoPrice == "1"
				nBegin := 0 // End
			Else
				nBegin := 1 //Begin
			EndIf 
			aTitulo := GMPriPrice( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos ,nCapital ,nBegin ,nPeriodo ,1 )
		//SACRE
		Case cSistema == "2"
			aTitulo := GMPriSacre( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos ,nCapital )
		//SAC                                                     
		Case cSistema == "3"
			aTitulo := GMPriSAC( nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos ,nCapital )
			
		// Sem sistema.
		Case cSistema == "4"
			aTitulo := GMPriTit( nIndCM ,nQtdTitulos ,nCapital )
			
		// Juros Simples
		// Como o juros mensal eh adicionado mensalmente, o valor inicial � sem juros
		Case cSistema == "5"
//			aTitulo := GM1JurSimp( nTaxa ,nIndCM ,nIntervalo ,nPeriodo ,nAmort )
			aTitulo := GMPriTit( nIndCM ,nQtdTitulos ,nCapital )
			
		// Juros Composto
		// Como o juros mensal eh adicionado mensalmente, o valor inicial � sem juros
		Case cSistema == "6"
//			aTitulo := GM1JurComp( nTaxa ,nIndCM ,nIntervalo ,nPeriodo ,nAmort )
			aTitulo := GMPriTit( nIndCM ,nQtdTitulos ,nCapital )
			
		// Outros
		Otherwise
			If ExistBlock("GMFIN02")
				aTitulos := ExecBlock("GMFIN02",.F.,.F.,{cSistema ,nTaxa ,nIndCM ,nIntervalo ,nQtdTitulos ,nCapital })
			EndIf
	EndCase
	
Return( aTitulo )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMCoefSist� Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo do novo Coeficiente para calculo das prestacoes, gera���
���           o valor da taxa proporcional pro periodo informado.           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMCoefSistema( nTaxAno, nPer, nRound)                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMCoefSistema( nTaxa, nPer, nRound)
Local nCoef    := 0
Local cTpTaxa  := SuperGetMV("MV_GMTPTAX",,"E")

DEFAULT nRound := TamSX3("LIS_COEF")[2]
If nRound == NIL
	nRound := 4
Endif

If cTpTaxa == "P"
	// calcula a taxa proporcional da informada por ano.
	nCoef := T_GEMTaxProp( nTaxa ,nPer )
Else
	// calcula a taxa equivalente ao da informada por ano.
	nCoef := T_GEMTaxEq( nTaxa ,nPer )
EndIf
nCoef := Round(nCoef,nRound)

Return( nCoef )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMSldCalc� Autor � Reynaldo Miyashita    � Data �15.07.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o saldo devedor ou pago de um contrato               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GEMSldCalc( cContrato ,lDevedor )                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMSldCalc( cContrato ,nTipo ,lDevedor )

Local nTotAmort   := 0
Local nTotJuros   := 0
Local nTotCMAmort := 0
Local nTotCMJuros := 0
Local aCMRet      := {}
Local aArea       := GetArea()

DEFAULT lDevedor := .T.
DEFAULT nTipo    := 0

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("LIT")
dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
If dbSeek(xFilial("LIT")+cContrato)

	dbSelectArea("SE1")
	dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	dbSeek(xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL)
	While SE1->(!eof()) .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+LIT->LIT_PREFIX+LIT->LIT_DUPL
	
		If lDevedor
			// Somente os titulos a receber que foram NAO baixados parcial ou total
			If ROUND(SE1->E1_SALDO,2) > 0 
				dbSelectArea("LIX")
				dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				If dbSeek(xFilial("LIX")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
					// Retorna o ultimo indice e correcao monetaria aplicado no titulo
					aCMRet := GEMCmTit( LIX->(Recno()) ,dDatabase )
					
					nTotAmort   := nTotAmort   + LIX->LIX_ORIAMO
					nTotJuros   := nTotJuros   + LIX->LIX_ORIJUR
					nTotCMAmort := nTotCMAmort + aCMRet[2]
					nTotCMJuros := nTotCMJuros + aCMRet[3]
				EndIf
			EndIf
		Else
			// Somente os titulos a receber que foram baixados parcial ou total
			If ROUND(SE1->E1_SALDO,2) == 0 .or. ROUND(SE1->E1_SALDO,2) # ROUND(SE1->E1_VALOR,2)
				dbSelectArea("LIX")
				dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
				If dbSeek(xFilial("LIX")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
					// Retorna o ultimo indice e correcao monetaria aplicado no titulo
					aCMRet := GEMCmTit( LIX->(Recno()) ,dDatabase )
					
					nTotAmort   := nTotAmort   + LIX->LIX_ORIAMO
					nTotJuros   := nTotJuros   + LIX->LIX_ORIJUR
					nTotCMAmort := nTotCMAmort + aCMRet[2]
					nTotCMJuros := nTotCMJuros + aCMRet[3]
				EndIf
			EndIf
		EndIf
		SE1->(dbSkip())
	EndDo

EndIf

Do Case             
	// amortizado, juros, cm do amortizao, cm do juros
	Case nTipo == 1
		aRet := { nTotAmort ,nTotJuros ,nTotCMAmort ,nTotCMJuros }
	// amortizado+CM, juros + CM 
	Case nTipo == 2
		aRet := {nTotAmort+nTotCMAmort,nTotJuros+nTotCMJuros}
	// (amortizado+CM) + (juros + CM )
	OtherWise 
		aRet := {nTotAmort+nTotCMAmort+nTotJuros+nTotCMJuros}
EndCase

restArea( aArea )
	
Return( aRet )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMTaxEq  � Autor � Reynaldo Miyashita    � Data �24.04.2006  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula taxa equivalente referente a taxa e periodo informado ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GEMTaxEq( nTaxa ,nPer )                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa = Taxa a ser calculada                                 ���
���          � nPer  = Quantidade de periodos para ser calculado            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � nCoef = Taxa proporcional                                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � GEMXFIN,GEMMA410                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMTaxEq( nTaxa ,nPer )
Local nCoef := 0

	nCoef := (((1 + (nTaxa/100))^(nPer/12))-1)*100

Return( nCoef )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMTaxProp� Autor � Reynaldo Miyashita    � Data �24.04.2006  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula a taxa proporcial referente a taxa e periodo informado���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GEMTaxProp( nTaxa ,nPer )                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa = Taxa a ser calculada                                 ���
���          � nPer  = Quantidade de periodos para ser calculado            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � nCoef = Taxa proporcional                                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � GEMXFIN,GEMMA410                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMTaxProp( nTaxa ,nPer )
Local nCoef := 0

	nCoef := nTaxa/(12/nPer)
	
Return( nCoef )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMJURSi� Autor � Reynaldo Miyashita    � Data �12.05.2005     ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com as titulos calculadas pelo juros simples���
���          � pelo no. de parcelas                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GMJURSi( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital          ���
���Sintaxe   �              ,dInicio ,dPriVenc ,nIndCM ,nPerCorr )          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nQtdTitulos- Quantidade de titulos                           ���
���          � nCapital - Valor a ser financiado                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nIndCM -                                                     ���
���          � nPerCorr -                                                   ���
���          � dInicio  - Data de Inicio do juros                           ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMJURSimp( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurINI )
Local nCount     := 0
Local nContaMes  := 0
Local nMeses     := 0
Local aTitulos   := {}
Local nSldoDev   := 0
Local nAmort     := 0
Local dVencto    := stod("")
Local dInicio    := stod("")
Local aPrestacao := {}
       
	nSldoDev := nCapital*(1+(nIndCM/100))
	
	nAmort       := GMPriTit( 0 ,nQtdTitulos ,nSldoDev )[1]
	dVencto      := dPriVenc
	dInicio      := dPriVenc
	
	If (dJurINI==NIL) .or. Empty(dJurINI)
		dJurINI  := dPriVenc
	EndIf
	
	If (nMeses := GMDateDiff( dJurINI,dVencto ,"MM" )) < 0
		nMeses := 0
	EndIf
    
	dInicio := dVencto
	For nCount := 1 to nQtdTitulos
		// calcula o valor da prestacao pelo juros simples	
		aPrestacao   := GM1JurSimp( nTaxa ,nIndCM ,1 ,nMeses ,nAmort )
		
		nSldoDev -= nAmort
	
		aAdd( aTitulos ,{ nCount       ;
                         ,dVencto      ;
                         ,aPrestacao[1];
		                 ,aPrestacao[3];
                         ,nSldoDev } )
		
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nCount*nIntervalo) )
		If left(dtos(dVencto),6) > left(dtos(dJurINI),6)
			nMeses += nIntervalo
		EndIf
		
		nContaMes += nIntervalo
		If nContaMes == nPerCorr .and. nPerCorr <> 0
			nContaMes  := 0
			// valor da prestacao
			nSldoDev := nSldoDev*(1+(nIndCM/100))
			nAmort   := nSldoDev/(nQtdTitulos-nCount)
		EndIf

	Next nCount

	If !(nSldoDev == 0) .and. Len(aTitulos) >0 
		aTitulos[Len(aTitulos)][3] += nSldoDev
		aTitulos[Len(aTitulos)][5] := 0
	EndIf
Return( aTitulos )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMJURCo� Autor � Reynaldo Miyashita    � Data �12.05.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com as titulos calculadas pelo juros        ���
���          � Composto pelo no. de parcelas                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GMJURComp( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital        ���
���Sintaxe   �              ,dInicio ,dPriVenc ,nIndCM ,nPerCorr )          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nQtdTitulos- Quantidade de titulos                           ���
���          � nCapital - Valor a ser financiado                            ���
���          � dPriVenc - Data de vencimento da primeira prestacao          ���
���          � nIndCM -                                                     ���
���          � nPerCorr -                                                   ���
���          � dInicio  - Data de Inicio do juros                           ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Numero do titulo                            ���
���          � aTitulos[n][2] - Data de vencimento do titulo                ���
���          � aTitulos[n][3] - Valor do titulo                             ���
���          � aTitulos[n][4] - Juros                                       ���
���          � aTitulos[n][5] - Saldo Devedor                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMJURComp( nTaxa ,nIntervalo ,nQtdTitulos ,nCapital ,dPriVenc ,nIndCM ,nPerCorr ,dJurIni )
Local nCount     := 0
Local nContaMes  := 0
Local nMeses     := 0
Local nSldoDev   := 0
Local nAmort     := 0
Local aPrestacao := {}
Local aTitulos   := {}
Local dVencto    := stod("")
Local dInicio    := stod("")
       
	nSldoDev := nCapital*(1+(nIndCM/100))
	
	nAmort       := GMPriTit( 0 ,nQtdTitulos ,nSldoDev )[2]
	dVencto      := dPriVenc
	dInicio      := dPriVenc
	
	If (dJurINI==NIL) .or. Empty(dJurINI)
		dJurINI  := dPriVenc
	EndIf
	
	If (nMeses := GMDateDiff( dJurINI ,dVencto ,"MM" )) < 0
		nMeses := 0
	EndIf
    
	dInicio := dVencto
	For nCount := 1 to nQtdTitulos
	
		// calcula o valor da prestacao pelo juros simples	
		aPrestacao := GM1JurComp( nTaxa ,nIndCM ,nIntervalo ,nMeses ,nAmort )

		nSldoDev -= nAmort // Amortizacao
	
		aAdd( aTitulos ,{ nCount       ;
                         ,dVencto      ;
                         ,aPrestacao[1];
		                 ,aPrestacao[3];
                         ,nSldoDev     } )
		
		//
		// data de vencimento da proxima titulo
		//
		dVencto := GMNextMonth( dInicio ,(nCount*nIntervalo) )
		If left(dtos(dVencto),6) > left(dtos(dJurINI),6)
			nMeses += nIntervalo
		EndIf
		
		nContaMes += nIntervalo
		If nContaMes == nPerCorr .and. nPerCorr <> 0
			nContaMes  := 0
			// valor da prestacao
			nSldoDev := nSldoDev*(1+(nIndCM/100))
		EndIf

	Next nCount

	If !(nSldoDev == 0) .and. Len(aTitulos) >0 
		aTitulos[Len(aTitulos)][3] += nSldoDev
		aTitulos[Len(aTitulos)][5] := 0
	EndIf
Return( aTitulos )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GM1JurComp� Autor � Reynaldo Miyashita    � Data �12.05.2005   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com o titulo calculado pelo juros simples   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GM1JurComp( nTaxa ,nIndCM ,nIntervalo ,nTempo ,nCapital )   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa      - Taxa anual do juros a ser aplicado              ���
���          � nIndCM -                                                     ���
���          � nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nTempo - No de meses a ser considerado no calculo            ���
���          � nCapital - Valor a ser financiado                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Valor do titulo                             ���
���          � aTitulos[n][2] - Amortizacao                                 ���
���          � aTitulos[n][3] - Juros                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GM1JurComp( nTaxa ,nIndCM ,nIntervalo ,nTempo ,nCapital )
Local nVlrPrest := 0
Local nAmort    := 0
Local nDecTaxa  := 0

	nDecTaxa  := t_GMCoefSistema( nTaxa ,nIntervalo )/100
	
	nVlrPrest := round(nCapital*((1+nDecTaxa)^(nTempo/nIntervalo)) ,2)
	nAmort    := nCapital

Return( {nVlrPrest ,nAmort ,(nVlrPrest-nCapital) } )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GM1JrSimp� Autor � Reynaldo Miyashita    � Data �12.05.2005   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna um array com o titulo calculado pelo juros simples   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � T_GM1JrSimp( nTaxa ,nIndCM ,nIntervalo ,nTempo ,nCapital )   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTaxa      - Taxa anual do juros a ser aplicado              ���
���          � nIndCM -                                                     ���
���          � nIntervalo - Intervalo(tempo) entre as titulos               ���
���          � nTempo - No de meses a ser considerado no calculo            ���
���          � nCapital - Valor a ser financiado                            ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � aTitulos[n][1] - Valor do titulo                             ���
���          � aTitulos[n][2] - Amortizacao                                 ���
���          � aTitulos[n][3] - Juros                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GM1JurSimp( nTaxa ,nIndCM ,nIntervalo ,nTempo ,nCapital )
Local nAmort    := 0
Local nJuros    := 0
Local nDecTaxa  := 0

Default nTempo := 1

	nDecTaxa := t_GMCoefSistema( nTaxa ,nIntervalo )/100
	
	nJuros    := round(nCapital*nDecTaxa*nTempo ,2)
	nAmort    := nCapital
	
Return( { (nAmort + nJuros) ,nAmort ,nJuros } )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GEMCoefCM� Autor � Reynaldo Miyashita    � Data �12.05.2005   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMCoefCM( cIndice ,nMes ,dIndice )

Local aArea     := GetArea()
Local nIndContr := 0
Local nIndCorr  := 0  
Local cMsgError := ""
Local aRetorno  := {}
Local dIndCM    := stod("")
Local dIndCMAnt := stod("")
Local lIndice   := .T.

DEFAULT cIndice := ""

	//
	// Cadastro de indices
	//
	dbSelectArea("AAD")
	dbSetOrder(1) // AAD_FILIAL+AAD_CODIND
	If dbSeek(xFilial("AAD")+cIndice)
		If nMes == NIL
			nMes := AAD->AAD_QTDMES 
        EndIf
	        
		//
		// monta a data do indice de referencia para correcao monetaria do mes informado
		//
		dIndCM := dIndice
		If nMes > 0
			dIndCM    := GMNextMonth(dIndice ,nMes)
		ElseIf nMes < 0
			dIndCM    := GMPrevMonth(dIndice ,nMes*-1)
		EndIf
        
		//
		// TABELA DE INDICES DE CORRECAO 
		//
		dbSelectArea("AAE")
		dbSetOrder(1) // AAE_FILIAL+AAE_CODIND+DTOS(AAE_DATA)
		
		// indice do periodo a ser corrigido
		If dbSeek(xFilial("AAE")+cIndice+dtos(dIndCM))
			// data e o indice(percentual) da correcao monetaria.
			nIndCorr := (AAE->AAE_INDICE * Iif(AAE->AAE_SINAL == "2", -1, 1))

			//
			// se for por indice
			//
			If lIndice
				dIndCMAnt := GMPrevMonth(dIndCM ,1)
			
				// indice do mes anterior 
				If dbSeek(xFilial("AAE")+cIndice+dtos(dIndCMAnt) )
					// data e o indice(percentual) da correcao monetaria.
					nIndContr := (AAE->AAE_INDICE * Iif(AAE->AAE_SINAL == "2", -1, 1))
				Else
					// A Data  ## do indice ### para cm nao existe
					cMsgError := STR0002 + dtoc(dIndCMAnt) + STR0003 + cIndice + STR0004
				EndIf
				
			// Variacao do indice por periodo
			Else
				nIndContr := 100
			EndIf

		Else
			//"A data '"  ## "' do indice '"  ## "' para correcao monetaria nao existe."
			cMsgError := STR0002 + dtoc(dIndCM) + STR0003 + cIndice + STR0004
		EndIf
		
	Else
			// A Taxa   ### nao foi encontrrada para cm.
		cMsgError :=  STR0005 + cIndice + STR0006
	EndIf

	aRetorno := { nIndCorr ,nIndContr ,cMsgError ,dIndCM }

RestArea(aArea)
Return( aRetorno )
