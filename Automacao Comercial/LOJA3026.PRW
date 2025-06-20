#INCLUDE 'PROTHEUS.CH'

Static aDescTotFP := {.F. , .F., .F., .F.}	//utilizado quando a nova Regra de Desconto for por Total e por Forma de Pagamento
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿐strutura de aDescTotFP														                     �
//�[1] - L : indica se a regra de desconto por total, eh por Forma de Pagamento                      �
//�[2] - L : indica se a regra de desconto por Forma de Pagamento, eh Proporcional                   �
//�[3] - L : indica se a regra de desconto por Forma de Pagamento, esta associada a Adm. Financeira. �
//|[4] - L : indica se a Regra de Desconto por TODAS as Forma de Pagamento (MB4 vazio)				 |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Static aMEI	:= {}
Static aMB4 := {}	//aMB4[1] - codigo da Regra de Desconto Varejo | aMB4[2] - vetor com as formas de pagamento

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿝GDesTol  � Vendas� Clientes    		 � Data �  12/08/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿐fetua o calculo das parcelas da condicao de pagamento      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튥intaxe   쿐xpN1:=RGDesTol(ExpL1,ExpN1,ExpC1,ExpA1)                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇�          쿐xpL1 - Controla se vai validar por tipo de pagto.          볍�
굇�          쿐xpN2 - Valor do total da venda.                            볍�
굇�          쿐xpC3 - Codigo da condicao de pagto selecionada.            볍�
굇�          쿐xpA4 - Array com os tipos de pagtos gerados apos selecao   볍�
굇�			 �		   da condicao de pagto.							  볍�  
굇�          쿐xpC5 - Codigo do cliente		                              볍�
굇�          쿐xpC6 - Codigo da loja do cliente				              볍�
굇�          쿐xpN7 - Valor total da venda (Bruto)  					  볍�
굇�          쿐xpN8 - Forma de Pagamento			  					  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿐xpN1 - Percentual de desconto do total da venda.           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿗OJXFUNE/FRTA271H/LOJA701B                                  볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Function RGDesTol( lTipoPgto, nVal, cCondPag, aTipoPagto, cCliente, cLoja , nVlrTotVda, cFormPagto, lTelaPgto )
Local nDescPer		:= 0	  			// Retorno da funcao com perc. de desconto
Local lAcumu		:= .T.	  			// Controla se a regra e acumulativa
Local nA			:= 0				// Variavel auxilial para loop
Local nX			:= 0				// Variavel auxiliar para loop
Local nValTotal		:= nVal				// Total da Venda
Local nValTotAux 	:= nValTotal		// Variavel auxiliar para armazenar valor total com desconto ja aplicado
Local lAplRegT		:= .T.				// Valida todas as inf. para verificar se aplica a regra
Local nValorCal		:= 0				// Valor final com desconto
Local nValTotalD	:= 0				// Valor do desconto na validacao da funcao de
Local aArea			:= {}
Local lAchouRDVld 	:= .F. 				//Indica se achou alguma regra de desconto valida para aplicar
Local lA1_CLIFUN    	:= SA1->(ColumnPos("A1_CLIFUN")) > 0 //Importante: esta valida豫o deve ser mantida, pois este campo existe no compatibilizador da 11.80 e n�o existe no dicion�rio da 12
Local cCliFun		:= ""				//Cliente funcionario
Local lAI0_CLIFU	:= AI0->(ColumnPos("AI0_CLIFUN")) > 0 //Foi protegido este campo pois este programa vai subir na release 12.1.16 e campo na posterior

Default lTipoPgto 	:= .F. 				// lTipoPgto
Default nVal		:= 0 				// nVal
Default cCondPag	:= "" 				// cCondPag
Default aTipoPagto	:= {} 				// aTipoPagto
Default cCliente	:= "" 				// cCliente
Default cLoja		:= "" 				// cLoja
Default nVlrTotVda	:= 0 				// Valor total da venda (Bruto) para calculo do desconto sem proporcional que � sobre a venda inteira
Default cFormPagto	:= ""				// Forma de Pagamento
Default lTelaPgto 	:= .F.				// Define se esta na tela de pagamento, para considerar somente regras de desconto que possuem associacao a formas de pagamento

//alimentamos o array estatico aMEI
LjSetArrMEI()

//alimentamos o array estatico aMB4
LjSetArrMB4()

//se o valor total da venda for 0.01, o desconto nao pode ser aplicado
If nValTotal <= 0.01
	Return 0
EndIf 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Resolve o problema conforme chamado THRNW1, caso�
//� a regra de desconto anterior n�o for acumulativa�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If cPaisLoc == "ARG" .AND. ExistFunc("LJGETRACUMUL")
	If !LjGetRAcumul() .AND. Len(aMEI) > 1 
		Return( 0 )
	EndIf
EndIf		


For nA := 1 To Len( aMEI )
	
	lAplRegT := .T.
	
	lAcumu := IIF(aMEI[nA][9] == "N",.F.,.T.)
	
	//Quando identificar uma regra que nao eh acumulativa e ja tiver encontrado alguma outra regra valida, 
	//entao desconsidera a regra de nao eh acumulativa
	If lAchouRDVld .And. !lAcumu
		Loop
	EndIf

	LjSetRAcumul( lAcumu )

	// redefinimos lTipoPgto(parametro da funcao), pois na chamada da funcao RgDesTol, 
	//nao eh possivel determinar se a Regra de Desconto possui desconto por Forma de Pagamento
	lTipoPgto := LjChkDesFP( aMEI[nA][1] )
	
	
	If lTelaPgto .AND. !lTipoPgto
		//Se a regra de desconto nao esta associada a alguma forma de pagamento e se estiver na tela de pagamento (SIGALOJA F7),
		//desconsidera a regra de desconto, pois so deve ser considerada a partir deste ponto somente regras associadas a formas de pagamento
		Loop
	EndIf

	If !Empty(aTipoPagto)
		//Se existir registros, nao executa mais a funcao, somente
		// quando selecionar o tipo de pagamento		
		For nX := 1 to Len(aTipoPagto)
			lAplRegT := VTemPagto(lTipoPgto, aMEI[nA][1],aTipoPagto[nX][3],cCondPag)
			If lAplRegT
				Exit
			EndIf
		Next nX
	EndIf	

	
	//Se a regra estiver cadastrada com cliente compara com o cliente da venda atual	
	If !Empty(AllTrim(aMEI[nA][10]) + AllTrim(aMEI[nA][11])) .AND. !(AllTrim(aMEI[nA][10]) + AllTrim(aMEI[nA][11]) == (AllTrim(cCliente) + AllTrim(cLoja))) 
		lAplRegT := .F.
	EndIf       
			
	//Salvamos a area pois a funcao Posicione() altera o Alias
	aArea := GetArea()

	
	//Se a regra estiver cadastrada com grupo de cliente compara com o grupo que o cliente da venda atual
	If !Empty(AllTrim(aMEI[nA][5])) .And. !(AllTrim(Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_GRPVEN")) == aMEI[nA][5])
		lAplRegT := .F.
	EndIf 
		
	//Se a regra for por desconto de funcionario, porem no cad de cli
	// nao estiver como desconto de funcionario nao se aplica a regra
	If (aMEI[nA][6] == "S") 
			If lAI0_CLIFU
				cCliFun := GetAdvFVal("AI0","AI0_CLIFUN",xFilial("AI0")+cCliente+cLoja,1,"2")
			EndIf
			
			If Empty(cCliFun) 
				If  lA1_CLIFUN 
					 cCliFun := GetAdvFVal("SA1","A1_CLIFUN",xFilial("SA1")+cCliente+cLoja,1,"2")
				EndIf		
			EndIf
			
			If !(cCliFun == "1")
				lAplReg := .F.
			EndIf 

	EndIf	

	RestArea(aArea)
	
	If lAplRegT  
		
		lAchouRDVld := .T.
		
		//Add na var. o valor total da venda, para calcular o percentual
		// final da venda  depois de calcular todas as regras
		If nValorCal == 0
			nValorCal := nValTotal
		EndIf

		If lTipoPgto
			ValDescPagto(aMEI[nA][1], aTipoPagto, nValTotAux, cCondPag, @nValTotalD, nVlrTotVda, cFormPagto)
			nValTotAux := nValTotAux - ( nValorCal * (nValTotalD/100) )
			nValorCal := ( nValorCal - ( nValorCal * (nValTotalD/100) ) )
		Else
			//Avalia qual desconto sera aplicado, conforme as faixas de valores			
			nValorCal := VldVlrDesc( aMEI[nA][1], nValTotAux ) //avalia qual desconto sera aplicado, atraves das faixas de valores
			nValTotAux := nValorCal
		EndIf
	EndIf
Next nA

nDescPer := CalPerc(nValTotal,nValorCal)

Return nDescPer


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿣alidPerio튍utor  쿘icrosiga           � Data �  05/02/11   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿣alidacao do periodo de vigencia da regra                   볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Sigaloja                                                   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/    
Function ValidPer( dDatDe, dDatAte, cCodReg, dDataIncio )   

Local lRet     := .F.				// Retorno da Funcao
Local cTime    := Time()			// Horario atual da chamada da funcao para validar com horario da regra
Local dData    := Date()			// Armazena a data atual para validar a data da regra
Local cDiaSem  := CDOW(dData)		// Converte data para um dia da semana   
Local aHora    := {}				// Armazena a hora da regra para validar horario    

Default dDatDe 	:= CTOD(" ")		// Data De
Default dDatAte := CTOD(" ")		// Data Ate
Default cCodReg := " "				// CodReg
Default dDataIncio := CTOD(" ")		// DataIncio

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿜uando painel de gestao valida a hora e data, pode ser que          �
//� a data de solicitacao nao seja a data atual, por isto a necessidade�
//� de passar a data por parametro.                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If !(dDataIncio == CTOD(" "))
	dData    := dDataIncio 
	cDiaSem  := CDOW(dData)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se a data informada e permitida para aplicar a regra de      �
//� de acordo com a data atual (Painel de gesta a data atual vem por   �
//� parametro).                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If (dData >= dDatDe) .And. (dData <= dDatAte)
	DbSelectArea("MB7")
	DbSetOrder(1) //MB7_FILIAL+MB7_CODREG
	If DbSeek(xFilial("MB7") + cCodReg)  
		Do Case   
		Case Upper(cDiaSem) == "SUNDAY"		//Domingo
			aHora := {AllTrim(MB7->MB7_HRDOMI), AllTrim(MB7->MB7_HRDOMF)}
		Case Upper(cDiaSem) == "MONDAY"		//Segunda
			aHora := {AllTrim(MB7->MB7_HRSEGI), AllTrim(MB7->MB7_HRSEGF)}
		Case Upper(cDiaSem) == "TUESDAY"	//Terca
			aHora := {AllTrim(MB7->MB7_HRTERI), AllTrim(MB7->MB7_HRTERF)}
		Case Upper(cDiaSem) == "WEDNESDAY" //Quarta
			aHora := {AllTrim(MB7->MB7_HRQUAI), AllTrim(MB7->MB7_HRQUAF)}
		Case Upper(cDiaSem) == "THURSDAY"	//Quinta
			aHora := {AllTrim(MB7->MB7_HRQUII), AllTrim(MB7->MB7_HRQUIF)}
		Case Upper(cDiaSem) == "FRIDAY"		//Sexta
			aHora := {AllTrim(MB7->MB7_HRSEXI), AllTrim(MB7->MB7_HRSEXF)} 
		Case Upper(cDiaSem) == "SATURDAY"	//Sabado
			aHora := {AllTrim(MB7->MB7_HRSABI), AllTrim(MB7->MB7_HRSABF)}
		End
	EndIf
	MB7->(DbCloseArea())
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣alida se a hora da regra e permitida para ser aplicada de acordo   �
//� com a data atual.                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If Len(aHora) < 1
	lRet := .F. 
Else
	If cTime > aHora[1] .And. cTime < aHora[2]
		lRet := .T.	
	EndIf
EndIf	

Return(lRet) 

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎alPerc   튍utor  � Vendas Clientes    � Data �  12/08/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿐fetua o calculo do % geral a ser aplicado na venda.        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튥intaxe   쿐xpL1:=CalPerc(ExpL1,ExpC1)                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇�          쿐xpN1 - Valor total da venda.                               볍�
굇�          쿐xpN2 - Valor total de desconto.                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿐xpN3 - % total de desconto.                                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿗OJA3026/LOJA3025                                           볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/    
Function CalPerc( nValTotal, nValComDesc ) 

Local nRet := 0    			// Retorno

Default nValTotal 	:= 0
Default nValComDesc := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿏esconto maior que a venda, zera o valor com desconto, nao�
//� efetuando o calculo e retornando zero o % de desc.       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If nValComDesc >= nValTotal
	nValComDesc := 0
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿞o aplica o desconto com valor com desc. maior que zero   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If nValComDesc > 0 
	nRet := 100 - ((nValComDesc * 100) /  nValTotal)
EndIf	

Return nRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿣TemPagto 튍utor  � Vendas Clientes    � Data �  12/08/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿐fetua a validao se a regra e por tipo de pagamento         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튥intaxe   쿐xpL1:=VTemPagto(ExpL1,ExpC1)                               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇�          쿐xpL1 - Controla e se por tipo de pagto                     볍�
굇�          쿐xpC1 - Codigo da regra a ser validada                      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿐xpL1 - Ret. logico se tem ou nao tipo de pagamento         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿗OJA3026                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/ 
Static Function VTemPagto( lTipoPgto, cReg, cFormPag, cCondPag)  
Local aArea	:= GetArea()
Local lRet 	:= .T.			//Retorno da Funcao
Local lAplica	:= .T.			// Controla se a regra de desconto sera aplicada 
Local lCpoFrm	:= MB5->(FieldPos("MB5_CODFRM")) > 0 	//  Controla se existem o campar par vincular a MB4 e a MB5

Default lTipoPgto 	:= .F.		// lTipoPgto
Default cReg 		:= ""		// cReg    
Default cFormPag	:= ""		// Forma de Pagamento 
Default cCondPag	:= ""		// Condi豫o de Pagamento 


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e for salva a variavel, e porque a chamanda desta funcao e     �
//� para calcular somente o total e nao por tipo de pagamento.     �
//쿐xistindo registro, e porque a esta regra foi feita para tipo de�
//� pagamento.                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lTipoPgto

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿣alidacao se tem tipo de pagamento                              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("MB4") 
		MB4->( DbSetOrder(1) )	//MB4_FILIAL+MB4_CODREG+MB4_CODFRM
		
		If MB4->( DbSeek(xFilial("MB4") + cReg) )
			While MB4->(!Eof()) .AND. MB4->MB4_FILIAL + MB4->MB4_CODREG == xFilial("MB4") + cReg
				
				If AllTrim(MB4->MB4_CODFRM) == AllTrim(cFormPag) 
					DbSelectArea("MB5")
					MB5->( DbSetOrder(1) )	//MB5_FILIAL+MB5_CODREG+MB5_CODPG
					
					If MB5->( DbSeek(xFilial("MB5") + cReg) )
						lRet := .F.

						While (!MB5->(Eof())) .AND. (MB5->(MB5_FILIAL + MB5_CODREG) == xFilial("MB5") + cReg)
						
					        If MB5->(AllTrim(MB5_CODPG)) == AllTrim(cCondPag)
								lRet := .T.
							EndIf     
							
							MB5->( DbSkip() )	
						EndDo	          						
					// Caso a regra nao tenha nenhuma CONDICAO DE PAGAMENTO cadastrada, lRet sera setada com true.
					Else 
						lRet := .T.
						Exit
				    EndIf

				Else
					lRet := .F.
				EndIf

				MB4->( DbSkip() ) 
			EndDo 
		EndIf

    
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	//쿣alidacao se tem adm. por tipo de pagamento                     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	If lRet
		DbSelectArea("MB6")
		MB6->( DbSetOrder(1) )	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN
		If MB6->( DbSeek(xFilial("MB6") + cReg) )
			lRet := .F.
		EndIf
	EndIf
Else
	
	If lAplica
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
		//쿣alidacao se tem tipo de pagamento, sem registro nao aplica regra    	 	�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��	
		DbSelectArea("MB4")
		MB4->( DbSetOrder(1) )	//MB4_FILIAL+MB4_CODREG+MB4_CODFRM
		If MB4->( DbSeek(xFilial("MB4") + cReg) )
			While (!MB4->(Eof())) .AND. (MB4->(MB4_FILIAL + MB4_CODREG) == xFilial("MB4") + cReg)
				   
				If MB4->(AllTrim(MB4_CODFRM)) == AllTrim(cFormPag)

					//Validacao se tem CONDICAO DE PAGAMENTO, que eh dependente da FORMA DE PAGAMENTO
					DbSelectArea("MB5")					
					
					If !lCpoFrm // Nova busca , por forma de pgto vinculada a tabela de forma de pgto

						MB5->( DbSetOrder(1) )//MB5_FILIAL+MB5_CODREG+MB5_CODPG
						If MB5->( DbSeek(xFilial("MB5") + cReg) )						    
							lAplica := .F.
							While MB5->( !EOF() )
								If MB5->(MB5_FILIAL+MB5_CODREG + AllTrim(MB5_CODPG)) == xFilial("MB5") + cReg + AllTrim(cCondPag)
									lAplica := .T.
									Exit
								EndIf     
								
								MB5->( DbSkip() )	
							EndDo	          
						
						// Caso a regra nao tenha nenhuma condicao de pagamento cadastrada, lAplica sera setada com true.
						Else 
							lAplica := .T.
							Exit
					    EndIf	
	
					Else
						MB5->(DbSetOrder(2))//MB5_FILIAL+MB5_CODREG+MB5_CODFRM
				
						// se achou a forma na MB5 , procura pela condicao amarrada a forma na MB5.
						// Se nao encontrar nenhuma CONDICAO na MB5 (SEM FORMA NA MB5), � porque se quer dar desconto para todas as formas de pgto (MB4).
						If MB5->(DbSeek(xFilial("MB5") + cReg +  AllTrim(cFormPag)))  
							lAplica := .F.
				
							// se houver alguma CONDICAO amarrada a forma na MB5, mas n�o esta selecionada no ptgto (cCondPag em branco),
							// nao aplica desconto.
							While	!Empty(cCondPag).AND. ; 
									MB5->(!EOF()) 	.AND. ;
									MB5->(MB5_FILIAL+MB5_CODREG + AllTrim(MB5_CODFRM)) == xFilial("MB5") + cReg +  AllTrim(cFormPag)
									If Alltrim(MB5->MB5_CODPG) == AllTrim(cCondPag) 
										lAplica := .T.
										Exit
									EndIf	
								MB5->( DbSkip() )	
							EndDo
						// Caso a regra nao tenha nenhuma condicao de pagamento cadastrada, lAplica sera setada com true.
						Else 
							lAplica := .T.
							Exit
					    EndIf
					    
				    EndIf	
					If lAplica //Achou uma regra aplic�vel para a forma, sai do la�o
						Exit
					EndIf
				Else
					lAplica := .F.			
				EndIf
				MB4->(DbSkip())
			EndDo
		EndIf
	EndIf
    
	If !lAplica
		lRet := .F.
	EndIf	
EndIf	

RestArea(aArea)

Return(lRet) 
                

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿣alDescPagto 튍utor  � Vendas Clientes    � Data �  12/08/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿣alidacao se a regra e por tipo de pagamento e proporcional    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튥intaxe   쿐xpL1:=VTemPagto(ExpL1,ExpC1)                                  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇�          쿐xpC1 - Codigo da regra a ser validada.                        볍�
굇�          쿐xpA2 - Tipos de pagamento geraod apor selecao da condicao.    볍�
굇�          쿐xpN3 - Valor total da venda.                                  볍�
굇�          쿐xpC4 - Condicao de pagamento selecionada.                     볍�
굇�          쿐xpN5 - % de desconto a ser retornado.                         볍�
굇�          쿐xpN6 - % Valor total da venda (Bruto).                        볍�
굇�          쿐xpC7 - Forma de Pagamento									 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿐xpN1 - Valor de % de desconto no caso de proprocional         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿗OJA3026                                                       볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/ 
Static Function ValDescPagto(cReg		, aTipoFrm	, nValVenda	, cCondPgto	, ;
							 nPercDesc	, nVlrTotVda, cFormPgto	)

Local nA 	   		:= 0			//Controle do laco For  
Local aTipo			:= {}			//Guarda as informacoes de tipo mais valor 
Local nValorCal		:= 0			//pode indicar o total com o desconto aplicado ou somente o desconto   
Local lAplicDesc	:= .F.			//Controla se vai aplicar a regra      
Local lTemPro		:= .F.			//Controla a existencia de prod. proporcional
Local nValorTotal	:= 0			// valor acumulado

Default cReg		:= ""			//cReg   
Default aTipoFrm	:= {} 	   		//aTipoFrm                                                                
Default nValVenda	:= 0 			//Valor da Venda para calulcar %
Default cCondPgto	:= ""			//Condicao de Pagamento
Default nPercDesc	:= 0 	   		//Retorno com % de desconto 
Default nVlrTotVda	:= 0 			//Valor total da venda (Bruto) para calculo do desconto sem proporcional que � sobre a venda inteira  
Default cFormPgto	:= ""

//formata a variavel cFormPgto de acordo com o campo MB4_CODFRM
cFormPgto := PadR( cFormPgto, TamSX3("MB4_CODFRM")[1] )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifica a existencia de alguma forma de pagto for proporcional.�
//쿐xistindo, para a pesquisa, e vai validar se a froma de pagto da�
//� venda e igual ao da regra, e aplicar somente aquele tipo.      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("MB4")
MB4->( DbSetOrder(2) )	//MB4_FILIAL + MB4_CODREG + MB4_PROPOR
If MB4->( DbSeek(xFilial("MB4") + cReg + "1") )
	lTemPro := .T.
	LjSetDesFP(2, lTemPro)	//indica que o desconto na forma de pagamento eh proporcional
EndIf

If lTemPro
	MB4->( DbSetOrder(1) ) //MB4_FILIAL + MB4_CODREG + MB4_CODFRM
	If MB4->( DbSeek(xFilial("MB4") + cReg + cFormPgto) )
		nPosMoney := aScan( aTipoFrm, {|x| AllTrim(cFormPgto) == AllTrim(x[3])} )
		If nPosMoney > 0
			AADD( aTipo, {aTipoFrm[nPosMoney][2], cFormPgto} )
			lAplicDesc := .T.
		EndIf
	EndIf
Else
	MB4->( DbSetOrder(1) ) //MB4_FILIAL + MB4_CODREG + MB4_CODFRM
	If MB4->( DbSeek(xFilial("MB4") + cReg + cFormPgto) )
		lAplicDesc := .T.
	EndIf
EndIf
MB4->( DbCloseArea() )

DbSelectArea("MB5")
MB5->( DbSetOrder(1) )	//MB5_FILIAL+MB5_CODREG+MB5_CODPG    
If MB5->( DbSeek(xFilial("MB5") + cReg + cCondPgto) )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	//쿞e achou uma con dicao de pgto.                          �
	//쿎heca se a forma de pgto tamb. esta cadastrada na regra.�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	DbSelectArea("MB4")
	MB4->( DbSetOrder(1) )	//MB4_FILIAL+MB4_CODREG+MB4_CODFRM
	If MB4->( DbSeek(xFilial("MB4") + cReg) )
		While !MB4->(Eof()) .And. (MB4->MB4_CODREG == cReg)
  			For nA := 1 To Len(aTipoFrm)
				If AllTrim(aTipoFrm[nA][3]) == AllTrim(MB4->MB4_CODFRM)
					lAplicDesc := .T.
				EndIf
    		Next nA
			MB4->( DbSkip() )
		EndDo
	EndIf
	MB4->( DbCloseArea() )
EndIf
MB5->( DbCloseArea() )

DbSelectArea("MB6")
MB6->( DbSetOrder(1) )	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN
If cFormPgto <> "R$" .AND. MB6->( DbSeek(xFilial("MB6") + cReg) )
	LjSetDesFP(3, .T.)	//indica que o desconto na forma de pagamento estah associada a Administradora Financeira
	lAplicDesc := .F.
	While !MB6->(Eof()) .AND. (MB6->MB6_CODREG == cReg)   

		DbSelectArea("SAE")
		SAE->( DbSetOrder(1) )	//AE_FILIAL+AE_COD
		If SAE->( DbSeek(xFilial("SAE") + MB6->MB6_ADMFIN) )

			DbSelectArea("SX5")
			SX5->( DbSetOrder(1) )
			If SX5->( DbSeek(xFilial("SX5") + "24" + SAE->AE_TIPO) )
				For nA := 1 To Len(aTipoFrm)
    				If (Len(aTipoFrm[nA]) > 3 .And. AllTrim(aTipoFrm[nA][4]) == AllTrim(MB6->MB6_ADMFIN)) .AND. (AllTrim(SX5->X5_CHAVE) == AllTrim(aTipoFrm[nA][3]))
						lAplicDesc := .T.  
					EndIf 
                Next nA
			EndIf

		EndIf
		MB6->( DbSkip() )
	EndDo
EndIf

If lAplicDesc

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿎arrega para Var. nPercDesc o valor a ser aplicado o desconto.  �
	//쿞endo a opcao proporcional, o valor da variavel somente o valor �
	//�  da parcela com proporcional, nao sendo, valor total da venda. �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If (Len(aTipo) > 0) .AND. lTemPro
		nValorTotal := 0
		For nA := 1 To Len(aTipo)
			nValorTotal := aTipo[nA][1]
		Next nA
	Else
		nValorTotal := 0
	
		// Se recebeu o valor total da venda, usa p calcular o desconto sobre o total  
		If nVlrTotVda > 0
			nValorTotal := nVlrTotVda
		Else
			For nA := 1 To Len(aTipoFrm)
				nValorTotal += aTipoFrm[nA][2]
			Next nA
		EndIf
	EndIf
	
	nValorCal := VldVlrDesc( cReg, nValorTotal )
	
	If nVlrTotVda > 0
		nPercDesc := CalPerc(nValorTotal, (nValorTotal - nValorCal) )
	Else
		nPercDesc := CalPerc(nValVenda , (nValVenda  - nValorCal) )
	EndIf
EndIf

Return Nil


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿗jGetDesFP튍utor  쿛rotheus            � Data �  16/01/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝etorna o conteudo do array aDescTotFP					  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튥intaxe   쿐xpL1 := LjGetDescFP(ExpN1)                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpN1 - Posicao do array aDescTotFP	                      볍�
굇�          �  [1] - retorna se a regra de desconto eh por Forma de Pgto 볍�
굇�          �  [2] - retorna se a regra de desconto e Proporcional		  볍�
굇�          �  [3] - retorna se a regra de desconto por forma de pagto   볍�
굇�          �        estah associada a Adm. Financeira.                  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿐xpL1 - Valor da Opcao ( Sim(.T.) ou Nao(.F.) )			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA                                                   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/    
Function LjGetDesFP(nTipo)
Local lRet		:= .F.
Default	nTipo	:= 1

If ValType(aDescTotFP) == "A"
	lRet := aDescTotFP[nTipo]
Else
	lRet := .F.
EndIf

Return lRet


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿗jSetDesFP튍utor  쿛rotheus            � Data �  16/01/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿌tribui ao array estatico aDescTotFP, um valor que indica	 볍�
굇�			 | se o desconto eh por forma de pagamento e/ou proporcional  	볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튥intaxe   쿗jSetDesFP(ExpN1, ExpL2)	                                  	볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇�          쿐xpN1 - Opcao que se deseja alterar	                     볍�
굇�          �  [0] - Reseta o array com os valores padroes (.F.)		  볍�
굇�          �  [1] - Regra de desconto por Forma de Pgto 				  볍�
굇�          �  [2] - Regra de desconto eh Proporcional		 			  볍�
굇�          �  [3] - Regra de desconto por Forma de Pgto associada a Adm.볍�
굇�          �        Financeira.                   		 			  볍�
굇�          쿐xpL2 - Valor da opcao (.T. ou .F.)						  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA                                                   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/    
Function LjSetDesFP(nTipo, lOpc)
Default nTipo	:= 1
Default lOpc	:= .F.

If ValType(aDescTotFP) <> "A"
	aDescTotFP := Array(4)
EndIf

Do Case
	Case nTipo == 0 //reseta os valores do array
		aDescTotFP[1] := .F.
		aDescTotFP[2] := .F.
		aDescTotFP[3] := .F.
		aDescTotFP[4] := .F.
	Case nTipo == 1 //indica se a Regra de Desconto eh por Forma de Pagamento 
		aDescTotFP[1] := lOpc
	Case nTipo == 2	//indica se a Regra de Desconto por Forma de Pagamento eh Proporcional
		aDescTotFP[2] := lOpc
	Case nTipo == 3	//indica se a Regra de Desconto por Forma de Pagamento estah associada a alguma Adm. Financeira
		aDescTotFP[3] := lOpc
	Case nTipo == 4	//indica se a Regra de Desconto por TODAS as Forma de Pagamento (MB4 vazio)
		aDescTotFP[4] := lOpc
		
EndCase

Return Nil

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿗jChkDesFP튍utor  쿛rotheus            � Data �  16/01/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿣erifica se a regra de desconto eh por Forma de Pagamento	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA                                                   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function LjChkDesFP(cCodReg)
Local lRet := .F.

DbSelectArea("MB4")
MB4->( DbSetOrder(1) )	//MB4_FILIAL + MB4_CODREG + MB4_CODFRM
If MB4->( MsSeek(xFilial("MB4") + cCodReg) )
	LjSetDesFP(1,.T.)  // por forma de pagamento  (R$ , CC .... )

	//verifica se ha adm, relaciona a forma de pagamento ,
	//no caso de CC e CD eh necessario para escolher a adm Financeira
	//para aplicar o desconto se a adm for igual a cadastrada na regra de desconto	
	DbSelectArea("MB6")
	MB6->( DbSetOrder(1) )	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN
	If MB6->( DbSeek(xFilial("MB6") + cCodReg) )   
		LjSetDesFP(3, .T.)	//indica que o desconto na forma de pagamento estah associada a Administradora Financeira
	EndIf
		
	lRet := .T.
Else
	LjSetDesFP(4, .T.)  // todas as formas
EndIf
MB4->( DbCloseArea() )

Return lRet

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿣ldVlrDesc튍utor  쿛rotheus            � Data �  21/01/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿣alida se o desconto pode ser aplicado conforme as faixas   볍�
굇�			 � de valores. Se validado, retorna o total com o desconto	  볍�
굇�			 | aplicado ou somente o valor de desconto					  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA                                                   볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Static Function VldVlrDesc(cCodReg, nVlrTotal)

Local lZerarDesc:= .F.		//indica se deve zerar o valor de desconto, caso ele seja maior que o valor total
Local nDesconto	:= 0		//desconto aplicado, o mesmo pode ser em R$ ou %

Default nVlrTotal	:= 0
Default cCodReg		:= ""

DbSelectArea("MB2")
MB2->( DbSetOrder(1) )
If MB2->( DbSeek(xFilial("MB2") + cCodReg) )

	While !MB2->( Eof() ) .AND. MB2_CODREG == cCodReg
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�                                   
		//쿏esconto sendo maior que o valor da venda, ele deixa como 0,01 �  
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If (nVlrTotal >= MB2->MB2_VLRINI) .AND. (nVlrTotal <= MB2->MB2_VLRFIM)	
	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿣erifica se o desconto vai ser por % ou R$�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If MB2->MB2_PDESC > 0	//desconto por porcentagem
				If MB2->MB2_PDESC <= 99.99 .AND. (nVlrTotal - (nVlrTotal * (MB2->MB2_PDESC / 100))) >= 0.01
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿞e for desconto por Forma de Pagamento, retorna o valor de		|
					//�	desconto, caso contrario, retorna o valor total ja descontado.	|
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					If LjGetDesFP(1)
						nDesconto := nVlrTotal * (MB2->MB2_PDESC / 100)	//retorna somente o valor de desconto
					Else
						nDesconto := nVlrTotal - ( nVlrTotal * (MB2->MB2_PDESC / 100) )	//retorna total com o desconto aplicado
					EndIf
				Else
					lZerarDesc := .T.
				EndIf
			Else	//desconto por valor
				If MB2->MB2_VLRFX <= nVlrTotal .AND. (nVlrTotal - MB2->MB2_VLRFX) >= 0.01
					nDesconto := nVlrTotal - MB2->MB2_VLRFX		//retorna total com o desconto aplicado
				Else
					lZerarDesc := .T.
				EndIf
			EndIf
	
			If lZerarDesc
				nDesconto := 0.01
				Exit
			EndIf
		EndIf
	
		MB2->( DbSkip() )
	EndDo
EndIf

Return nDesconto

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//|ATENCAO!																										|
//쿙a versao 28/12/2012/16:36, existiam dois blocos de codigos com a mesma finalidade, porem com uma diferenca,	|
//| no trecho que calcula o desconto com base na porcentagem, um trecho retornava o valor de desconto e outro, o|
//| valor total com desconto aplicado. Mas em ambos os casos, se o desconto fosse aplicado atraves de um valor	|
//| fixo, o valor retornado eh o total com o desconto aplicado. Necessario avaliacao desse caso!				�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿗J3026_VER튍utor  쿛rotheus            � Data � 03/Out/2013 볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Funcao apenas para verificar a versao deste fonte no RPO.  볍�
굇�			 � Isso eh necessario para saber qdo. eh possivel utilizar em 볍�
굇�			 � outro fonte, algum tratamento novo criado neste fonte.     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿐xpC1 - Data da ultima alteracao para controle de versao.   볍�
굇�          �       No formato AAAMMDD                                   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � SIGALOJA                                                   볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Function LJ3026_VER()
Return "20140704"

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴敲굇
굇튡rograma  � LjLoadMEI   튍utor  쿣arejo			    � Data � 28/03/2014 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴묽�
굇튒esc.     � Alimentamos o array estatico aRetLj7T, que eh usado para		볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� nExp1 -  Reseta(0) ou alimenta(1) o array aRetLj7T			볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function LjSetArrMB4()

Local nI 		:= 0
Local aArea		:= {}

If Len(aMB4) == 0
	
	aArea := GetArea()

	DbSelectArea("MB4")
	MB4->( DbSetOrder(1) )	//MB4_FILIAL + MB4_CODREG + MB4_CODFRM

	For nI := 1 to Len( aMEI )

		Aadd( aMB4, Array(2) )

		aTail(aMB4)[1] := aMEI[nI][1]
		aTail(aMB4)[2] := {}

		If MB4->( MsSeek(xFilial("MB4") + aMEI[nI][1]) )
			While xFilial("MB4") + aMEI[nI][1] == MB4->MB4_FILIAL + MB4->MB4_CODREG
				Aadd( aTail(aMB4)[2], AllTrim(MB4->MB4_CODFRM) )
				MB4->( DbSkip() )
			End
		EndIf	
		//se nao houver Formas de Pagamento cadastradas na MB4, assume-se que a regra vale para todas as formas
	Next
	
	MB4->( DbCloseArea() )
	RestArea( aArea )

EndIf

Return Nil


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴敲굇
굇튡rograma  � LjAplicRDV  튍utor  쿣arejo			    � Data � 28/03/2014 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴묽�
굇튒esc.     � Alimentamos o array estatico aRetLj7T, que eh usado para		볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� nExp1 -  Reseta(0) ou alimenta(1) o array aRetLj7T			볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function LjVldFrmPg( cFormPagto )

Local nI		:= 0
Local nX		:= 0
Local nPos		:= 0
Local nPosAux	:= 0
Local lRet		:= .T.	//indica se deve aplicar ou nao, a regra de desconto varejo

Default cFormPagto 	:= ""

If Len(aMEI) > 0

	BEGIN SEQUENCE

	//se a regra for Proporcional, nao verificamos as formas de pagamento
	If !LjGetDesFP(2)

		//se aMB4 for vazio, assumimos que o desconto sera aplicado para todas as formas de pgto
		If Empty(aMB4)			
			//se existir alguma forma de pgto no aPgtos, o desconto ja foi aplicado
			nPos := aScan( aPgtos, {|x| !Empty(x[3])} )
			If nPos > 0				
				lRet := .F.
				BREAK
			EndIf			
		EndIf

		//1a. se a Forma de Pgto ja existir no aPgtos, o desconto ja foi aplicado
		nPos := aScan( aPgtos, {|x| x[3] == cFormPagto} )
		If nPos > 0
			lRet :=  .F.
			BREAK
		EndIf

		//2a. se alguma regra possui uma forma de pgto que esta contida no aPgtos, o desconto ja foi aplicado
		For nI := 1 To Len(aMEI)

			nPos := aScan( aMB4, {|x| x[1] == aMEI[nI][1]} )
			If nPos > 0
				For nX := 1 to Len( aMB4[nPos][2] )
					nPosAux := aScan( aPgtos, {|x| x[3] == aMB4[nPos][2][nX]} )
					If nPosAux > 0
						lRet := .F.
						BREAK
					EndIf
				Next
			EndIf
		Next
	EndIf

	END SEQUENCE

EndIf

Return lRet


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴敲굇
굇튡rograma  � LjLoadMEI   튍utor  쿣arejo			    � Data � 28/03/2014 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴묽�
굇튒esc.     � Alimentamos o array estatico aRetLj7T, que eh usado para		볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� nExp1 -  Reseta(0) ou alimenta(1) o array aRetLj7T			볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function LjSetArrMEI()

Local aArea 		:= {}
Local lFindRegra	:= .F.
                 
//alimentamos aMEI uma unica vez, para melhora de performance
If Len(aMEI) == 0
	
	//guardamos a area
	aArea := GetArea()
	
	DbSelectArea("MEI")
	MEI->( DbSetOrder(3) )	//MEI_FILIAL + MEI_TPIMPD

	If MEI->( DbSeek(xFilial("MEI") + "T") )	
		Do While !MEI->( Eof() ) .AND. MEI->MEI_FILIAL+AllTrim(MEI->MEI_TPIMPD) == xFilial("MEI")+"T"		
			
			// Valida o dia e horario da regra		
			If ValidPer(MEI->MEI_DATDE, MEI->MEI_DATATE, MEI->MEI_CODREG) .AND. (MEI->MEI_ATIVA == "1")
				DbSelectArea("MEJ")
				MEJ->( DbSetOrder(2) ) //MEJ_FILIAL + MEJ_CODREG
				
				// Verifica para qual filial foi criada a regra
				If MEJ->( DbSeek(xFilial("MEJ") + MEI->MEI_CODREG) )
					DbSelectArea("MB3")
					MB3->( DbSetOrder(1) )	//MB3_FILIAL + MB3_CODREG + MB3_CODEMP + MB3_CODFIL
					If DbSeek(xFilial("MB3") + MEJ->MEJ_CODREG + cEmpAnt)
						Do While !MB3->(Eof()) .AND. MB3->MB3_FILIAL+MB3->MB3_CODREG+MB3->MB3_CODEMP == xFilial("MB3")+MEJ->MEJ_CODREG+cEmpAnt 

							// 1. Tipo Filial
							// 2. Tipo Grupo de Filiais
							
							IF MB3->MB3_TIPO == "1"
								If MB3_CODFIL == cFilAnt
									lFindRegra := .T.
								EndIf
							ElseIF MB3->MB3_TIPO == "2"
						
								// Explode o grupo de filiais
								// SAU � Grupo de Filiais
								DbSelectArea("SAU")
								SAU->(dbSetOrder(1))
								IF SAU->( dbSeek( xFilial("SAU") + MB3->MB3_CODGRU ) )             
								
									Do While SAU->( !EOF() .And. SAU->AU_FILIAL+AllTrim(SAU->AU_CODGRUP) == xFilial("SAU")+AllTrim(MB3->MB3_CODGRU) )	
										If SAU->AU_CODFIL == cFilAnt								
											lFindRegra := .T.
											Exit
										EndIf
										SAU->( DbSkip() )															
									EndDo	
								EndIf	
							EndIf
							// Se encontrou Regra que atenda condi豫o
							If lFindRegra
								AADD( aMEI,;
								{	MEI->MEI_CODREG, MEJ->MEJ_PRINUM, MEI->MEI_DATDE	, MEI->MEI_DATATE,;
									MEI->MEI_GRPVEN, MEI->MEI_DESFUN, MEI->MEI_PRDMOS	, MEI->MEI_PRDSLD,;
									MEI->MEI_ACUMUL, MEI->MEI_CODCLI, MEI->MEI_LOJA	;
								}	)
								lFindRegra := .F.
							EndIf
							MB3->( DbSkip() )																						
						EndDo		
					EndIf
				EndIf

			EndIf			
			MEI->( DbSkip() )
		EndDo
	EndIf
	
	//Ordena o array pelo segundo campo MEJ->MEJ_PRINUM (ou seja, por Prioridade)	
	aMEI := aSort(aMEI,,,{|x,y| x[2] < y[2]})
	
	//restauramos a area
	RestArea(aArea)

EndIf
	
Return Nil

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴敲굇
굇튡rograma  � LjVerRegAdm 튍utor  쿣arejo			    � Data � 04/07/2014 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴묽�
굇튒esc.     � Verifica se uma das regras exigem Adm Financeira  	     	볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   � LExp1 -  .T./.F.			볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function LjVerRegAdm()   
Local aArea := GetArea()
Local lRet := .F.   //Retorno da Rotina
Local lAcum := .T.  //Regra Acumulativa
Local nA	:= 1 

//alimentamos o array estatico aMEI
LjSetArrMEI()
DbSelectArea("MB4")
MB4->( DbSetOrder(1) )	//MB4_FILIAL + MB4_CODREG + MB4_CODFRM 

DbSelectArea("MB6")
MB6->( DbSetOrder(1) )	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN

Do While nA <=  Len( aMEI )  .AND. lAcum .AND. !lRet

	If MB4->( MsSeek(xFilial("MB4") + aMEI[nA][1]) )
	
		//verifica se ha adm, relaciona a forma de pagamento ,
		//no caso de CC e CD eh necessario para escolher a adm Financeira
		//para aplicar o desconto se a adm for igual a cadastrada na regra de desconto	
	
		lRet :=  MB6->( DbSeek(xFilial("MB6") + aMEI[nA][1]) )   
	
	EndIf

	lAcum := IIF(aMEI[nA][9] == "N",.F.,.T.)	
	nA++
EndDo

RestArea(aArea)
Return lRet
