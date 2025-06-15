#Include 'Protheus.ch'

Function TAFDPMPPRD(aWizard, nCont, aTotalizFn, aTotaliz)
	
	/* Vari�veis - Arquivo Texto */
	Local cTxtSys := CriaTrab( , .F. ) + ".TXT"
	Local nHandle := MsFCreate( cTxtSys )
	Local cStrTxt := ""
	
	/* Vari�veis - SQL */
	Local cAliasProd := GetNextAlias() 
	Local cAliasIns  := GetNextAlias()
		
	/* Vari�veis - Wizard */
	Local cAgentReg := aWizard[1][5]             // Cod. Regulador ANP
	Local cMesRefer := Substr(aWizard[1][3],1,2) // M�s Refer�ncia
	Local cAnoRefer := LTRIM(STR(aWizard[1][4])) // Ano Refer�ncia
				
	Local cDtIniRef := CTOD("01/"+cMesRefer+"/"+cAnoRefer)
	Local cDtFimRef := Lastday(stod(cAnoRefer+cMesRefer+'01'),0)
		
	/* Vari�veis - Campos para gera��o */
	Local cOperacao  := ""
	Local cInstal1   := ""
	Local cProdANP   := ""
	Local cProdutoR  := ""
	Local nQtdPrdANP := 0
			
	/* Busca o C�digo da Instala��o ANP da Filial */	
	cInstal1 := POSICIONE("C1E",3,xFilial("C1E")+FWGETCODFILIAL+"1","C1E_CDINAN")
				
	BeginSql Alias cAliasProd
		SELECT	C0G.C0G_CODIGO COD_ANP,
		       SUM(T21.T21_QTDPRO) QTD_PROD,
		       C1L.C1L_TPPRD TP_PRD
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = T21.T21_FILIAL AND C1L.C1L_ID = T21.T21_CODITE AND C1L.%NotDel%
		   INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%			  	
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(cDtIniRef)% 
		  AND T18.T18_DTFIN <= %Exp:DTOS(cDtFimRef)%
		  AND T18.%NotDel%	
		GROUP BY C0G.C0G_CODIGO,
				  C1L.C1L_TPPRD	
	EndSql
	
	While !(cAliasProd)->(Eof())
	
		cOperacao := "1021004" // Cod. Opera��o ANP de Produ��o por Mistura
	
		If (cAliasProd)->TP_PRD = "2"
			cOperacao := "1021002" // Cod. Opera��o ANP de Produ��o Pr�pria
		ElseIf (cAliasProd)->TP_PRD = "3"
			cOperacao := "1021005" // Cod. Opera��o ANP de Produ��o por Reprocessamento
		EndIf	
		
		cProdANP   := (cAliasProd)->COD_ANP  // Produto Operado ANP
		nQtdPrdANP := (cAliasProd)->QTD_PROD // Quantidade Produzida do Item
							
		cStrTxt := StrZero(nCont,10)         // Contador Sequencial
		cStrTxt += StrZero(cAgentReg,10)     // Agente Regulado Informante
	 	cStrTxt += (cMesRefer+cAnoRefer)     // M�s de Refer�ncia (MMAAAA)
	 	cStrTxt += StrZero(VAL(cOperacao),7) // C�digo da Opera��o
	 	cStrTxt += StrZero(VAL(cInstal1),7)  // C�digo da Instala��o 1
	 	cStrTxt += StrZero(VAL(""),7)        // C�digo da Instala��o 2
	 	cStrTxt += StrZero(VAL(cProdANP),9)  // C�digo do Produto Operado
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado na Unidade de Medida Oficial ANP
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado em Quilogramas (KG)
	 	cStrTxt += StrZero(VAL(""),1)        // C�digo do Modal Utilizado na Movimenta��o
	 	cStrTxt += StrZero(VAL(""),7)        // C�digo do Ve�culo Utilizado no Modal
	 	cStrTxt += StrZero(VAL(""),14)       // Identifica��o do Terceiro Envolvido na Opera��o
	 	cStrTxt += StrZero(VAL(""),7)        // C�digo do Munic�pio (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),5)        // C�digo de Atividade Econ�mica do Terceiro
	 	cStrTxt += StrZero(VAL(""),4)        // C�digo do Pa�s (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),10)       // N�mero da Licen�a de Importa��o (LI)
	 	cStrTxt += StrZero(VAL(""),10)       // N�mero da Declara��o de Importa��o (DI)
	 	cStrTxt += StrZero(VAL(""),7)        // N�mero da Nota Fiscal da Opera��o Comercial
	 	cStrTxt += StrZero(VAL(""),2)        // C�digo da S�rie da Nota Fiscal da Opera��o Comercial
	 	cStrTxt += StrZero(VAL(""),8)        // Data da Opera��o Comercial (DDMMAAAA)
	 	cStrTxt += StrZero(VAL(""),1)        // C�digo do Servi�o Acordado (Dutos)
	 	cStrTxt += StrZero(VAL(""),3)        // C�digo da Caracter�stica F�sico-Qu�mica do Produto
	 	cStrTxt += StrZero(VAL(""),3)        // C�digo do M�todo Utilizado para Aferi��o da Caracter�stica
	 	cStrTxt += StrZero(VAL(""),2)        // C�digo da Unidade de Medida da Caracter�stica
	 	cStrTxt += StrZero(VAL(""),10)       // Valor Encontrado da Caracter�stica
	 	cStrTxt += StrZero(VAL(""),9)        // C�digo do Produto/Opera��o Resultante
	 	cStrTxt += StrZero(VAL(""),7)        // Massa Espec�fica do Produto
	 	cStrTxt += StrZero(VAL(""),2)        // Recipiente de GLP
	 	cStrTxt += StrZero(VAL(""),44)       // Chave de acesso da Nota Fiscal Eletr�nica (NF-e)
	 	cStrTxt += CRLF
	 		 	
	 	/* Realiza a soma das quantidades para os registros de Totaliza��o */
	 	SomaOpTot(nQtdPrdANP, nQtdPrdANP, cOperacao, cInstal1, cProdANP, "0", @aTotalizFn, @aTotaliz)
	 	
	 	WrtStrTxt( nHandle, cStrTxt )
	 														 				 				
	 	nCont++
	 	
	 	(cAliasProd)->(DbSkip())		
	EndDo
	(cAliasProd)->(DbCloseArea())
	
	BeginSql Alias cAliasIns
		SELECT	C0G_I.C0G_CODIGO COD_ANP_I,
				C0G_P.C0G_CODIGO COD_ANP_P,
		       SUM(T22.T22_QTDCON) QTD_CON,
		       C1L_I.C1L_TPPRD TP_PRD		       
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:T22% T22 ON T22.T22_FILIAL = T21.T21_FILIAL AND T22.T22_CODOP = T21.T21_CODOP AND T22.T22_CODITE = T21.T21_CODITE AND T22.%NotDel%
		   INNER JOIN %table:C1L% C1L_I ON C1L_I.C1L_FILIAL = T22.T22_FILIAL AND C1L_I.C1L_ID = T22.T22_CODINS AND C1L_I.%NotDel%
		   INNER JOIN %table:C1L% C1L_P ON C1L_P.C1L_FILIAL = T21.T21_FILIAL AND C1L_P.C1L_ID = T21.T21_CODITE AND C1L_P.%NotDel%
		   INNER JOIN %table:C0G% C0G_I ON C0G_I.C0G_ID = C1L_I.C1L_CODANP AND C0G_I.%NotDel%			  	
		   LEFT JOIN %table:C0G% C0G_P ON C0G_P.C0G_ID = C1L_P.C1L_CODANP AND C0G_P.%NotDel%
		   //Trazer todos os insumos(T22) com ANP mesmo que o produto final(T21) n�o possua c�digo ANP
		   //
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(cDtIniRef)% 
		  AND T18.T18_DTFIN <= %Exp:DTOS(cDtFimRef)%
		  AND T18.%NotDel%	
		GROUP BY C0G_I.C0G_CODIGO,
				  C0G_P.C0G_CODIGO,
				  C1L_I.C1L_TPPRD	
	EndSql
	
	While !(cAliasIns)->(Eof())
	
		cOperacao := "1022015" // Cod. Opera��o ANP de Sa�da para Produ��o por Mistura
	
		If (cAliasIns)->TP_PRD = "3"
			cOperacao := "1022018" // Cod. Opera��o ANP de Sa�da para Reprocessamento
		Elseif Empty((cAliasIns)->COD_ANP_P)
			cOperacao := "1022002"
		EndIf
		
		cProdANP   := (cAliasIns)->COD_ANP_I // Produto Operado ANP
		cProdutoR  := (cAliasIns)->COD_ANP_P // Produto/Opera��o Resultante
		nQtdPrdANP := (cAliasIns)->QTD_CON   // Quantidade Consumida do Item		
		
		cStrTxt := StrZero(nCont,10)         // Contador Sequencial
		cStrTxt += StrZero(cAgentReg,10)     // Agente Regulado Informante
	 	cStrTxt += (cMesRefer+cAnoRefer)     // M�s de Refer�ncia (MMAAAA)
	 	cStrTxt += StrZero(VAL(cOperacao),7) // C�digo da Opera��o
	 	cStrTxt += StrZero(VAL(cInstal1),7)  // C�digo da Instala��o 1
	 	cStrTxt += StrZero(VAL(""),7)        // C�digo da Instala��o 2
	 	cStrTxt += StrZero(VAL(cProdANP),9)  // C�digo do Produto Operado
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado na Unidade de Medida Oficial ANP
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado em Quilogramas (KG)
	 	cStrTxt += StrZero(VAL(""),1)        // C�digo do Modal Utilizado na Movimenta��o
	 	cStrTxt += StrZero(VAL(""),7)        // C�digo do Ve�culo Utilizado no Modal
	 	cStrTxt += StrZero(VAL(""),14)       // Identifica��o do Terceiro Envolvido na Opera��o
	 	cStrTxt += StrZero(VAL(""),7)        // C�digo do Munic�pio (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),5)        // C�digo de Atividade Econ�mica do Terceiro
	 	cStrTxt += StrZero(VAL(""),4)        // C�digo do Pa�s (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),10)       // N�mero da Licen�a de Importa��o (LI)
	 	cStrTxt += StrZero(VAL(""),10)       // N�mero da Declara��o de Importa��o (DI)
	 	cStrTxt += StrZero(VAL(""),7)        // N�mero da Nota Fiscal da Opera��o Comercial
	 	cStrTxt += StrZero(VAL(""),2)        // C�digo da S�rie da Nota Fiscal da Opera��o Comercial
	 	cStrTxt += StrZero(VAL(""),8)        // Data da Opera��o Comercial (DDMMAAAA)
	 	cStrTxt += StrZero(VAL(""),1)        // C�digo do Servi�o Acordado (Dutos)
	 	cStrTxt += StrZero(VAL(""),3)        // C�digo da Caracter�stica F�sico-Qu�mica do Produto
	 	cStrTxt += StrZero(VAL(""),3)        // C�digo do M�todo Utilizado para Aferi��o da Caracter�stica
	 	cStrTxt += StrZero(VAL(""),2)        // C�digo da Unidade de Medida da Caracter�stica
	 	cStrTxt += StrZero(VAL(""),10)       // Valor Encontrado da Caracter�stica
	 	cStrTxt += StrZero(VAL(cProdutoR),9) // C�digo do Produto/Opera��o Resultante
	 	cStrTxt += StrZero(VAL(""),7)        // Massa Espec�fica do Produto
	 	cStrTxt += StrZero(VAL(""),2)        // Recipiente de GLP
	 	cStrTxt += StrZero(VAL(""),44)       // Chave de acesso da Nota Fiscal Eletr�nica (NF-e)
	 	cStrTxt += CRLF
		
		/* Realiza a soma das quantidades para os registros de Totaliza��o */
	 	SomaOpTot(nQtdPrdANP, nQtdPrdANP, cOperacao, cInstal1, cProdANP, "1", @aTotalizFn, @aTotaliz)
	 	
	 	WrtStrTxt( nHandle, cStrTxt )
	 	
	 	nCont++
	
		(cAliasIns)->(DbSkip())		
	EndDo
	(cAliasIns)->(DbCloseArea())
	
	Begin Sequence 		 		 				 
 		GerTxtDPMP( nHandle, cTxtSys, "MOV_PRD" )
 	
 		Recover
		lFound := .F.
	End Sequence
	
Return
