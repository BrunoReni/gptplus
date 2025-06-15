#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "JURR099.CH"

#DEFINE IMP_PDF   6
#DEFINE IMP_SPOOL 2
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   2350 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     3000 // Linha Final da p�gina de um relat�rio
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR099()
Regras do relat�rio de Despesas

@param cCodJur C�digo do Processo que ter� os andamentos impressos
                 no relat�rio
       cFilpro Filial
	   lAutomato Indica se vem de automa��o ou app totvs Juridico
	   cNomeRel  Quando vem de automa��o � enviado tamb�m o nome
	   cCaminho  Quando vem de automa��o � enviado tamb�m o caminho

@Return Nil

@author Jorge Luis Branco Martins Junior
@since 11/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JURR099(cCodJur, cFilpro, lAutomato, cNomeRel, cCaminho)
Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) // Fonte usada no nome do relat�rio
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos do relat�rio (T�tulo de campos e t�tulos no cabe�alho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos das sess�es
Local cQuery     := ""
Local cData      := ""
Local cSimbolo   := ""
Local cValor     := ""
Local cDesc      := ""
Local cDespesa   := ""
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}

Default lAutomato := .F.
Default cCaminho  := ""

cTpAssJur := JurGetDados("NSZ",1,xFilial("NSZ")+cCodJur, "NSZ_TIPOAS")

cData := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_DATA  " + Replicate(" ",10-len("NT3_DATA")), 'NUZ_DESCPO')
If Empty(AllTrim(cData))
	cData := JURX3INFO("NT3_DATA","X3_TITULO")
EndIf

cSimbolo := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_DMOEDA" + Replicate(" ",10-len("NT3_DMOEDA")), 'NUZ_DESCPO')
If Empty(AllTrim(cSimbolo))
	cSimbolo := JURX3INFO("NT3_DMOEDA","X3_TITULO")
EndIf

cValor := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_VALOR " + Replicate(" ",10-len("NT3_VALOR ")), 'NUZ_DESCPO')
If Empty(AllTrim(cValor))
	cValor := JURX3INFO("NT3_VALOR ","X3_TITULO")
EndIf

cDesc := JurGetDados('NUZ', 1, xFilial('NUZ') + cTpAssJur + "NT3_DESC" + Replicate(" ",10-len("NT3_DESC")), 'NUZ_DESCPO')
If Empty(AllTrim(cDesc))
	cDesc := JURX3INFO("NT3_DESC","X3_TITULO")
EndIf

cDespesa := JURX3INFO("NT3_DTPDES","X3_TITULO")

//T�tulo do Relat�rio
  // 1 - T�tulo,
  // 2 - Posi��o da descri��o,
  // 3 - Fonte do t�tulo
  // 4 - Orienta��o("R" = Retrato, "P"=Paisagem)
aRelat := {STR0001,800,oFont,"R"} //"Relat�rio de Despesas"

//Cabe�alho do Relat�rio
// 1 - T�tulo, 
  // 2 - Conte�do, 
  // 3 - Posi��o de in�cio da descri��o(considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. 
  //     Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. 
  //     Para isso considere sempre a posi��o da maior descri��o),
  // 4 - Fonte do t�tulo, 
  // 5 - Fonte da descri��o

aCabec := {{STR0002/*"Impress�o"*/   ,DToC(Date())                                                ,(nTamCarac*12),oFontTit,oFontDesc},;
           {STR0003/*"N�m Processo"*/,JurGetDados("NUQ",2,xFilial("NUQ")+cCodJur+"1","NUQ_NUMPRO"),(nTamCarac*12),oFontTit,oFontDesc},;
           {STR0004/*"Envolvidos"*/  ,JA099Envolv(cCodJur)                                        ,(nTamCarac*12),oFontTit,oFontDesc}}

cQuery := JA099QryRel(cCodJur,1, cFilpro)

//Campos do Relat�rio
  //Exemplo da primeira parte -> aAdd(aSessao, {"Andamentos",65,oFontSub,.F.,;// 
  // 1 - T�tulo da sess�o do relat�rio,
  // 2 - Posi��o de in�cio da descri��o, 
  // 3 - Fonte no quadro com t�tulo da sess�o,
  // 4 - Impress�o na horizontal? -> T�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
  // 5 - Query do subreport - Se for parte do relat�rio principal n�o precisa ser indicado
    // Arrays a partir da 6� posi��o
      // 1 - T�tulo do campo,
      // 2 - Tabela do campo,
      // 3 - Nome do campo no dicion�rio,
      // 4 - Nome do Campo na Query,
      // 5 - Tipo do Campo,
      // 6 - Indica a coordenada horizontal em pixels ou caracteres, 
      // 7 - Tamanho que o conte�do pode ocupar,
      // 8 - Fonte do t�tulo, 
      // 9 - Fonte da descri��o
      // 10 - Posi��o de in�cio da descri��o
      // 11 - Quebra Linha ap�s impress�o do conte�do?
aAdd(aSessao, {"",65,oFontSub,.F.,,;
	              	{cData /*Data*/      		,"NT3","NT3_DATA"	,"NT3_DATA"	,"D",65  , 1000 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
	              	{cDespesa /*Despesa*/		,"NSR","NSR_DESC"  	,"NSR_DESC" ,"C",500 , 1500 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
	                {""/*Simbolo Moeda*/ 	,"NT3","NT3_CMOEDA" ,"CTO_SIMB" ,"C",2000 , 1500	,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
	                {cValor /*Valor*/			,"NT3","NT3_VALOR"  ,"NT3_VALOR","N",2100, 1500 ,oFontTit,oFontDesc,(nTamCarac*5),.T.},;
	                {cDesc /*Descri��o*/      	,"NT3","NT3_DESC"  	,"RECNONT3" ,"M",65  , 3200 ,oFontTit,oFontDesc,(nTamCarac*12),.T.}})
nSessao := Len(aSessao)
	                
aAdd(aSessao, {"Totaldesp",65,oFontSub,.T.,JA099QryRel(cCodJur,2, cFilpro),.T.})
				nSessao := Len(aSessao)
				aAdd(aSessao[nSessao],{STR0005/*"Total"*/,"NT3","NT3_VALOR","TOTAL","N",2000,1500,oFontTit,oFontTit,(nTamCarac*5),.T.})

JRelatorio(aRelat, aCabec, aSessao, cQuery, lAutomato, cNomeRel, cCaminho) //Chamada da fun��o de impress�o do relat�rio em TMSPrinter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099Envolv()
Imprime cabe�alho do relat�rio de Andamentos
 
Uso Geral.

@param cAssJur C�digo do Processo que ter� os andamentos impressos
                 no relat�rio

@Return cEnv   Nome dos envolvidos separados por hifen

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA099Envolv(cAssJur)
Local cEnv := ""
Local cAtivo := JurGetDados("NT9",3,xFilial("NT9")+cAssJur+"11","NT9_NOME")   // Polo Ativo Principal
Local cPassivo := JurGetDados("NT9",3,xFilial("NT9")+cAssJur+"21","NT9_NOME") // Polo Pass�vo Principal

cEnv := Alltrim(cAtivo)

If !Empty(AllTrim(JurGetDados("NT9",3,xFilial("NT9")+cAssJur+"21","NT9_NOME")))
	cEnv += " / " + Alltrim(cPassivo)
EndIf

Return cEnv

//-------------------------------------------------------------------
/*/{Protheus.doc} JA099QryRel()
Retorna dados que ser�o impressos no relat�rio
 
Uso Geral.

@param cAssJur C�digo do Processo que ter� os andamentos impressos
                 no relat�rio
        aFiltro Filtro usado na pesquisa de andamentos 

@Return aDados Array contendo as informa��es dos andamentos

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA099QryRel(cAssJur, nTipo, cFilpro)
	Local aArea      := GetArea()
	Local cQrySelect := ""
	Local cQryWhere  := ""
	Local cQueryFrom := ""

If nTipo == 1	
	cQrySelect += " SELECT NSR.NSR_DESC NSR_DESC, "
	cQrySelect += 		 " NT3.NT3_DATA,"
	cQrySelect +=        " NT3.R_E_C_N_O_ RECNONT3,"
	cQrySelect +=        " CTO.CTO_SIMB,"	
	cQrySelect +=        " NT3.NT3_VALOR,"
	cQrySelect +=        " NT3.NT3_DESC "
	cQueryFrom += " FROM " + RetSqlName("NT3") + " NT3 "
	cQueryFrom +=  " LEFT OUTER JOIN " + RetSqlName("NSR") + " NSR ON ( " 
	cQueryFrom +=            " NT3.D_E_L_E_T_ = NSR.D_E_L_E_T_ AND " 
	cQueryFrom +=            " NT3.NT3_CTPDES = NSR.NSR_COD AND " 
	cQueryFrom +=            " NSR.NSR_FILIAL = '"+xFilial("NSR")+"') "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("NSZ") + " NSZ "
	cQueryFrom +=                " ON ( NT3.NT3_CAJURI = NSZ.NSZ_COD "
	cQueryFrom +=                     " AND NT3.D_E_L_E_T_ = NSZ.D_E_L_E_T_) "
	cQueryFrom +=                     " AND NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("CTO") + " CTO"
	cQueryFrom +=                " ON ( NT3.NT3_CMOEDA = CTO.CTO_MOEDA"
	cQueryFrom +=                     " AND CTO.CTO_FILIAL = '"+xFilial("CTO")+"') " 	
	cQryWhere  += " WHERE NT3_FILIAL = '"+cFilpro+"' "
	cQryWhere  +=       " AND NT3.D_E_L_E_T_ = ' ' "
	cQryWhere  +=       " AND NT3_CAJURI = '"+cAssJur+"' "
	cQryWhere  += " ORDER BY NT3.NT3_DATA DESC, NT3.NT3_COD DESC"
Else // Total
	cQrySelect += " SELECT SUM(NT3.NT3_VALOR) TOTAL"
	cQueryFrom += " FROM " + RetSqlName("NT3") + " NT3 "
	cQueryFrom +=  " LEFT OUTER JOIN " + RetSqlName("NSR") + " NSR ON ( " 
	cQueryFrom +=            " NT3.D_E_L_E_T_ = NSR.D_E_L_E_T_ AND " 
	cQueryFrom +=            " NT3.NT3_CTPDES = NSR.NSR_COD AND " 
	cQueryFrom +=            " NSR.NSR_FILIAL = '"+xFilial("NSR")+"') "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("NSZ") + " NSZ "
	cQueryFrom +=                " ON ( NT3.NT3_CAJURI = NSZ.NSZ_COD "
	cQueryFrom +=                     " AND NT3.D_E_L_E_T_ = NSZ.D_E_L_E_T_) "
	cQueryFrom +=                     " AND NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	cQueryFrom +=        " INNER JOIN "  + RetSqlName("CTO") + " CTO"
	cQueryFrom +=                " ON ( NT3.NT3_CMOEDA = CTO.CTO_MOEDA"
	cQueryFrom +=                     " AND CTO.CTO_FILIAL = '"+xFilial("CTO")+"') " 	
	cQryWhere  += " WHERE NT3_FILIAL = '"+cFilpro+"' "
	cQryWhere  +=       " AND NT3.D_E_L_E_T_ = ' ' "
	cQryWhere  +=       " AND NT3_CAJURI = '"+cAssJur+"' "
EndIf
	RestArea( aArea )

Return cQrySelect + cQueryFrom + cQryWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio()
Impress�o de Relat�rios SIGAJURI
Ferramenta TMSPrinter 
Uso Geral.

@param aRelat  Dados do t�tulo do relat�rio
       aCabec  Dados do cabe�alho do relat�rio
       aSessao Dados do conte�do do relat�rio
	   cQuery  Query que ser� executada
	   lAutomato Indica se vem de automa��o ou app totvs Juridico
	   cNomeRel  Quando vem de automa��o � enviado tamb�m o nome
	   cCaminho  Quando vem de automa��o � enviado tamb�m o caminho

@Return

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat, aCabec, aSessao, cQuery, lAutomato, cNomeRel, cCaminho)

Local lHori     := .F.
Local lQuebPag  := .F.
Local lTitulo   := .T. 
Local lLinTit   := .F.
Local nI        := 0    // Contador
Local nJ        := 0    // Contador
Local nLin      := 0    // Linha Corrente
Local nLinCalc  := 0    // Contator de linhas - usada para os c�lculos de novas linhas
Local nLinCalc2 := 0
Local nLinFinal := 0
Local oPrint    := Nil
Local aDados    := {}
Local TMP       := GetNextAlias()

Default cNomerel  := AllTrim(aRelat[1]) //Nome do Relat�rio


If !lAutomato
	oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,, .T.,,, "PDF" ) // Inicia o relat�rio
Else
	oPrint := FWMsPrinter():New( cNomeRel, IMP_SPOOL,,, .T.,,,) // Inicia o relat�rio
	//Altera o nome do arquivo de impress�o para o padr�o de impress�o automatica
	oPrint:CFILENAME  := cNomeRel
	oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMP,.T.,.T.)

If (TMP)->(!EOF())

	ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Imprime cabe�alho
	nLinCalc := nLin // Inicia o controle das linhas impressas

	While (TMP)->(!EOF())

		If nLin >= nFimL // Verifica se a linha corrente � maior que linha final permitida por p�gina
			oPrint:EndPage() // Se for maior, encerra a p�gina atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o t�tulo pode ser impresso 
			lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
		EndIf

		For nI := 1 To Len(aSessao) // Inicia a impress�o de cada sess�o do relat�rio
			
			lHori := aSessao[nI][4]
			
			If Empty(aSessao[nI][5]) // Nessa posi��o � indicada a query de um subreport
			
				nLinCalc2 := nLinCalc // Backup da pr�xima linha a ser usada, pois na fun��o JDadosCpo abaixo a variavel tem seu conte�do alterado para
		                      // que seja realizada uma simula��o das linhas usadas para impress�o do conte�do. 

				nLinFinal := 0 // Limpa a vari�vel

				For nJ := 6 to Len(aSessao[nI]) // L� as informa��es de cada campo a ser impresso. O contador come�a em 6 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
					cTabela  := aSessao[nI][nJ][2] //Tabela
					cCpoTab  := aSessao[nI][nJ][3] //Nome do campo na tabela
					cCpoQry  := aSessao[nI][nJ][4] //Nome do campo na query
					cTipo    := aSessao[nI][nJ][5] //Tipo do campo
					cValor := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,,.F.) // Retorna o conte�do/valor a ser impresso. Chama essa fun��o para tratar o valor caso seja um memo ou data
					
					aAdd(aDados,JDadosCpo(aSessao[nI][nJ],cValor,@nLinCalc,@lQuebPag)) // T�tulo e conte�do de cada campo s�o inseridos do array com os dados para serem impressos abaixo
				Next 
	
				nLinCalc := nLinCalc2 // Retorno do valor original da vari�vel
	
				If lQuebPag // Verifica se � necess�rio ocorrer a quebra de pagina
					oPrint:EndPage() // Se � necess�rio, encerra a p�gina atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lQuebPag := .F. // Limpa a vari�vel de quebra de p�gina
					lTitulo  := .T. // Indica que o t�tulo pode ser impresso 
					lLinTit  := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
				EndIf
				
				If nI > 1 // Inclui uma linha em branco no final de cada sess�o do relat�rio principal, desde que n�o seja a primeira sess�o 
					nLin += nSalto
				EndIf		
				
				If !lHori // Caso a impress�o dos t�tulos seja na vertical - Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Relat�rio de andamentos)
					// Os t�tulos devem ser impressos
					lTitulo := .T. // Indica que o t�tulo pode ser impresso 
					lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
				EndIf
				
				//Imprime os campos do relat�rio
				JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec)
				
				//Limpa array de dados
				aSize(aDados,0)
				aDados := {}
	
				nLinCalc := nLinFinal //Indica a maior ref�ncia de uso de linhas para que sirva como refer�ncia para come�ar a impress�o do pr�ximo registro
				
				nLinFinal := 0 // Limpa a vari�vel
				
				nLin := nLinCalc+nSalto //Recalcula a linha de refer�ncia para impress�o
			
				nLinCalc := nLin //Indica a linha de refer�ncia para impress�o
			EndIf
		Next

		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
		
		nLin += nSalto //Adiciona uma linha em branco ap�s a linha impressa
		nLinCalc := nLin
		
		(TMP)->(DbSkip())
	End

	For nI := 1 To Len(aSessao) // Inicia a impress�o de cada sess�o do relat�rio
		
		lHori := aSessao[nI][4]
		
		If !Empty(aSessao[nI][5]) // Nessa posi��o � indicada a query de um subreport
			JImpSub(aSessao[nI][5], TMP, aSessao[nI],@nLinCalc,@lQuebPag, aRelat, aCabec, @oPrint, @nLin, @lTitulo, @lLinTit) // Imprime os dados do subreport
		Endif
	Next
	
	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
	
	(TMP)->(dbCloseArea())
	
	aSize(aDados,0)  //Limpa array de dados
	aSize(aRelat,0)  //Limpa array de dados do relat�rio
	aSize(aCabec,0)  //Limpa array de dados do cabe�alho do relat�rio
	aSize(aSessao,0) //Limpa array de dados das sess�es do relat�rio
	
	oPrint:EndPage() // Finaliza a p�gina
	
	If !lAutomato
		If Empty(cCaminho)
			oPrint:CFILENAME  := Replace(AllTrim(cNomeRel),'.','') + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') + '.rel'
			oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
		Else
			oPrint:CFILENAME  := cNomeRel
			oPrint:CFILEPRINT := cCaminho + cNomeRel
		EndIf
	Endif
	
	oPrint:Print()
	
	If !lAutomato .And. Empty(cCaminho)
		FErase(oPrint:CFILEPRINT)
	Endif

EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec()
Imprime cabe�alho do relat�rio
 
Uso Geral.

@param oPrint  Objeto do Relat�rio
        nColIni Coluna inicial
        nColFim Coluna final
        nSalto  Salto de uma linha a outra
        nLin    Linha Corrente
        aRelat  Dados do t�tulo do relat�rio
        aCabec  Dados do cabe�alho do relat�rio
        aSessao Dados do conte�do do relat�rio

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpCabec(oPrint, nLin, aRelat, aCabec)
Local cTit       := aRelat[1] // T�tulo
Local nColTit    := aRelat[2] // Posi��o da T�tulo
Local oFontTit   := aRelat[3] // Fonte do T�tulo
Local cTitulo    := ""
Local cValor     := ""
Local nPosValor  := 0
Local nSaltoCabe := 40
Local nI         := 0
Local oFontValor
Local oFontRoda  := TFont():New("Arial",,-8,,.F.,,,,.T.,.F.) // Fonte usada no Rodap�

If aRelat[4] == "R"
	oPrint:SetPortrait()  // Define a orienta��o do relat�rio como retrato (Portrait).
Else
	oPrint:SetLandscape() // Define a orienta��o do relat�rio como paisagem (Landscape).
EndIf

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
nLin := 90

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )

nLin += 2*nSaltoCabe // Espa�o para que o cabe�alho fique um pouco abaixo do T�tulo do Relat�rio 

If Len(aCabec) > 0
	For nI := 1 to Len(aCabec)
		cTitulo    := aCabec[nI][1] // T�tulo
		cValor     := aCabec[nI][2] // Conte�do
		nPosValor  := aCabec[nI][3] // Posi��o do conte�do (considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. Para isso considere sempre a posi��o da maior descri��o)
		oFontTit   := aCabec[nI][4] // Fonte do t�tulo
		oFontValor := aCabec[nI][5] // Fonte do conte�do
		oPrint:Say( nLin += nSaltoCabe, 070                        , cTitulo + ":" , oFontTit   ) //Imprime o T�tulo
		oPrint:Say( nLin              , nPosValor + (nTamCarac * 4), cValor        , oFontValor ) //Imprime o Conte�do - Esse (nTamCarac * 4) � para dar um espa�o de 4 caracteres a mais do que o tamanho da descri��o
	Next
EndIf

//nLin+=2*nSaltoCabe // Inclui duas linhas em branco ap�s a impress�o do cabe�alho
nLin+=20
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio

nLin+=40 //Recalcula a linha de refer�ncia para impress�o

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataVal()
Trata os tipos de campos e imprime os valores
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        TMP      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 15/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Local cValor  	:= ""
Local lPicture	:=.F.
Local cPicture	:= ""

If lSub
	If cTipo == "D" // Tipo do campo
		TCSetField(SUB, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((SUB)->&(cCpoQry))) //Conte�do a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((SUB)->&(cCpoQry))) // Esse seek � para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
		ElseIf cTipo == "N" // Tipo do campo
		TcSetField( SUB, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
		lPicture := Iif(Empty(cPicture),.F.,.T.)
		If lPicture
			cValor   := TRANSFORM((SUB)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conte�do a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((SUB)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((SUB)->&(cCpoQry)))
	EndIf
Else 
	If cTipo == "D" // Tipo do campo
		TCSetField(TMP, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((TMP)->&(cCpoQry))) //Conte�do a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((TMP)->&(cCpoQry))) // Esse seek � para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "N" // Tipo do campo
		TcSetField( TMP, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
		lPicture := Iif(Empty(cPicture),.F.,.T.)
		If lPicture
			cValor   := TRANSFORM((TMP)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conte�do a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((TMP)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
	EndIf
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpSub()
Imprime o t�tulo da sess�o no relat�rio
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        TMP      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpSub(cQuerySub, TMP, aSessao, nLinCalc,lQuebPag, aRelat, aCabec, oPrint, nLin, lTitulo, lLinTit)
Local nJ     := 0
Local cValor := ""
Local aDados := {}
Local lHori  := aSessao[4]
Local cTxt   := cQuerySub
Local SUB    := GetNextAlias()
Local cVar   := "" // CAMPO
Local xValor       // Valor do campo

While RAT("#@", cTxt) > 0 // Substitui os nomes dos campos passados na query por seus respectivos valores
	cVar     := SUBSTR(cTxt,AT("@#", cTxt) + 2,AT("#@", cTxt) - (AT("@#", cTxt) + 2))
	xValor   := (TMP)->(FieldGet(FieldPos(cVar)))
	cTxt     := SUBSTR(cTxt, 1,AT("@#", cTxt)-1) + ALLTRIM(xValor) + SUBSTR(cTxt, AT("#@", cTxt)+2)
End

cQuerySub := cTxt

cQuerySub := ChangeQuery(cQuerySub)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySub),SUB,.T.,.T.)

While (SUB)->(!EOF())

	If nLin >= nFimL // Verifica se a linha corrente � maior que linha final permitida por p�gina
		oPrint:EndPage() // Se for maior, encerra a p�gina atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
		nLinCalc := nLin // Inicia o controle das linhas impressas
		lTitulo := .T. // Indica que o t�tulo pode ser impresso 
		lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
	EndIf
		
		nLinCalc2 := nLinCalc // Backup da pr�xima linha a ser usada, pois na fun��o JDadosCpo abaixo a variavel tem seu conte�do alterado para
		                      // que seja realizada uma simula��o das linhas usadas para impress�o do conte�do. 
		
		For nJ := 7 to Len(aSessao) // L� as informa��es de cada campo a ser impresso. O contador come�a em 6 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
			
			nLinFinal := 0 // Limpa a vari�vel
						
			cTabela  := aSessao[nJ][2] //Tabela
			cCpoTab  := aSessao[nJ][3] //Nome do campo na tabela
			cCpoQry  := aSessao[nJ][4] //Nome do campo na query
			cTipo    := aSessao[nJ][5] //Tipo do campo
			cValor   := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,,SUB,.T.) // Retorna o conte�do/valor a ser impresso. Chama essa fun��o para tratar o valor caso seja um memo ou data

			aAdd(aDados,JDadosCpo(aSessao[nJ],cValor,@nLinCalc,@lQuebPag)) // T�tulo e conte�do de cada campo s�o inseridos do array com os dados para serem impressos abaixo
		Next
		
		nLinCalc := nLinCalc2 // Retorno do valor original da vari�vel
		
		If lQuebPag // Verifica se � necess�rio ocorrer a quebra de pagina
			oPrint:EndPage() // Se � necess�rio, encerra a p�gina atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lQuebPag := .F. // Limpa a vari�vel de quebra de p�gina
			lTitulo  := .T. // Indica que o t�tulo pode ser impresso 
			lLinTit  := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
		EndIf

		If !lHori // Caso a impress�o dos t�tulos seja na vertical - Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Relat�rio de andamentos)
			// Os t�tulos devem ser impressos
			lTitulo := .T. // Indica que o t�tulo pode ser impresso 
			lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
		EndIf

		//Imprime os campos do relat�rio
		JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec)
		
		//Limpa array de dados
		aSize(aDados,0)
		aDados := {}

		nLinCalc := nLinFinal //Indica a maior ref�ncia de uso de linhas para que sirva como refer�ncia para come�ar a impress�o do pr�ximo registro
		
		nLinFinal := 0 // Limpa a vari�vel
		
		nLin := nLinCalc
	
	(SUB)->(DbSkip())
End

aSize(aDados,0)

(SUB)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JDadosCpo()
Fun��o para montar array de titulos das colunas
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        cAliasqry      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDadosCpo(aSessao,cValor,nLinCalc,lQuebPag)
Local aDados    := {}
Local lQuebLin  := .F.
Local cTitulo   := ""
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local nPosTit   := 0
Local oFontVal
Local oFontTit

	cTitulo  := aSessao[1] //T�tulo da Coluna
	nPosTit  := aSessao[6] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aSessao[8] //Fonte do t�tulo
	nPos     := aSessao[6] //Indica a coordenada horizontal para imprimir o valor do campo
	nQtdCar  := aSessao[7] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aSessao[9] //Fonte usada para impress�o do conte�do
	nPosValor:= aSessao[10] //Fonte usada para impress�o do conte�do
	lQuebLin := aSessao[11] //Indica se deve existir a quebra de linha

	If !lQuebPag // Verifica se ser� necess�ria quebra de p�gina para essa sess�o
		lQuebPag := ((Int((Len(cValor)/nQtdCar) + 1) * nSalto) + nLinCalc) > nFimL
		nLinCalc += (Int((Len(cValor)/nQtdCar) + 1) * nSalto) // Indica a linha que ser� usada para cada valor quando forem impressos - Usado apenas para uma simula��o.
	EndIf

	aDados := {cTitulo, nPosTit, oFontTit, cValor, nQtdCar, oFontVal, nPos, nPosValor, lQuebLin}

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpRel(aDados)
Fun��o para montar array de titulos das colunas
 
Uso Geral.

@param 

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpRel(aDados,nLin,nLinCalc,oPrint,nLinFinal,lHori, lTitulo, lLinTit, aRelat,aCabec, lSalta)
Local nJ        := 0
Local lQuebLin  := .F.
Local lImpTit   := .T.
Local cTitulo   := ""
Local cValor    := ""
Local nPosTit   := 0
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local nLinTit   := 0
Local nLinAtu   := 0
Local aSobra    := aClone(aDados)
Local oFontTit
Local oFontVal

aEval(aSobra,{|x| x[4] := ""}) // Limpa a posi��o de conte�do/valor dos campos no array de sobra, pois ele � preenchido com os dados do array aDados. Limpa para que seja preenchido com o conte�do da sobra. 

Default lSalta  := .F.
Default lHori   := .T.

If lSalta // Se for continua��o de impress�o do conte�do que n�o coube na p�gina anterior 
	lImpTit := .F. // Indica que os t�tulos n�o precisam ser impressos
	lSalta  := .F. // Limpa vari�vel
EndIf

For nJ := 1 to Len(aDados)

	cTitulo  := aDados[nJ][1] //T�tulo da Coluna
	nPosTit  := aDados[nJ][2] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aDados[nJ][3] //Fonte do t�tulo
	cValor   := aDados[nJ][4] //Valor a ser impresso
	nQtdCar  := aDados[nJ][5] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aDados[nJ][6] //Fonte usada para impress�o do conte�do
	nPos     := aDados[nJ][7] //Indica a coordenada horizontal para imprimir o valor do campo
	nPosValor:= aDados[nJ][8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
	lQuebLin := aDados[nJ][9] // Indica se deve existir quebra de linha ap�s a impress�o do campo

	If lHori // Impress�o na horizontal -> t�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
		nLinTit  := nLin
		nLinCalc := nLin
		oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os t�tulos das colunas
	Else // Impress�o na vertical -> Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Data
	     //                                                                                                                01/01/2016 )
		
		If lImpTit // Essa vari�vel indica se deve imprimir o t�tulo dos campos - Ser� .F. somente quando ocorrer quebra de um conte�do em mais de uma p�gina (lSalta == .T.).
			If !lLinTit // Como a linha onde ser� impresso o t�tulo dos campos ainda n�o foi definida entrar� nessa condi��o
				
				If (nLin + 2*nSalto) >= nFimL // Verifica se a linha corrente � maior que linha final permitida por p�gina
					oPrint:EndPage() // Se for maior, encerra a p�gina atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lTitulo := .T. // Indica que o t�tulo pode ser impresso 
					lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
					nLinFinal := 0 
				EndIf
				
				nLinTit  := nLin
				nLin     += nSalto
				nLinCalc := nLin
				lLinTit := .T. // Indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
			EndIf
			
			If lTitulo // Indica que o t�tulo pode ser impresso
				oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os t�tulos das colunas
				
				lTitulo := Len(aDados) <> nJ // Enquanto estiver preenchendo os t�tulos indica .T., para que os outros t�tulos sejam impressos. 
				                             // Ap�s o preenchimento do �ltimo t�tulo indica .F., n�o premitindo mais a impress�o dos t�tulos nessa p�gina.
				                             
				// Deve imprimir apenas uma vez por p�gina para que a letra n�o fique mais grossa.
				// Se n�o tiver esse tratamento a impress�o ser� feita v�rias vezes sobre a mesma palavra devido as condi��es do la�o, 
				// fazendo com que a grossura das letras nas palavras aumente e isso atrapalha.
				
			EndIf
		EndIf
		nPosValor := nPosTit // Indica que a posi��o (coluna) do conte�do/valor a ser impresso � a mesma que foi impresso o titulo, ou seja, o conte�do/valor ficar� logo abaixo do t�tulo
	EndIf

	nLinAtu := nLinCalc // Controle de linhas usadas para imprimir o conte�do atual

	JImpLin(@oPrint,@nLinAtu,nPosValor,cValor,oFontVal,nQtdCar,@aSobra[nJ], @lSalta, lImpTit) //Imprime as linhas com os conte�dos/valores

	// Verifica qual campo precisou de mais linhas para ser impresso
	// para usar esse valor como refer�ncia para come�ar a impress�o do pr�ximo registro
	If nLinAtu > nLinFinal
		nLinFinal := nLinAtu
	EndIf

	If lSalta .And. lQuebLin // Se precisa continuar a impress�o do conte�do atual na pr�xima p�gina 
		oPrint:EndPage() // Finaliza a p�gina atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho na pr�xima p�gina
		nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
		nLinAtu   := nLinCalc // Atualiza vari�vel linha atual
		lQuebPag  := .F. // Indica que n�o � necess�rio ocorrer a quebra de pagina, pois j� est� sendo quebrada nesse momento.
		lTitulo   := .T. // Indica que o t�tulo pode ser impresso 
		lLinTit   := .F. // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
		nLinFinal := 0 // Limpa vari�vel de controle da �ltima linha impressa.
		
		// Imprime o restante do conte�do que n�o coube na p�gina anterior.
		JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta)
		aEval(aSobra,{|x| x[4] := ""})
	EndIf
	
	If lQuebLin // Indica que � necess�ria quebra de linha, ou seja, o pr�ximo campo ser� impresso na pr�xima linha
		If nLinFinal >= nLin // Se a pr�xima linha a ser impressa (nLin) for menor que a �ltima linha que tem conte�do impresso (nLinFinal)
			nLin     := nLinFinal // Deve-se indicar a maior refer�ncia
		Else
			nLin     += nSalto // Caso contr�rio, pule uma linha.
		EndIf
		
		If nLin >= nFimL
			oPrint:EndPage() // Se for maior, encerra a p�gina atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o t�tulo pode ser impresso 
			lLinTit := .F. // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
			nLinFinal := 0 // Limpa vari�vel de controle da �ltima linha impressa.
		Else
			nLinTit  := nLin // Recebe a pr�xima linha dispon�vel para impress�o do t�tulo
			nLinCalc := nLin // Atualiza vari�vel de c�lculo de linhas
			lLinTit  := .F.  // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
		EndIf
	EndIf
	
Next nJ

If lSalta // Se precisa continuar a impress�o do conte�do atual na pr�xima p�gina 
	oPrint:EndPage() // Finaliza a p�gina atual
	ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho na pr�xima p�gina
	nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
	nLinAtu   := nLinCalc // Atualiza vari�vel linha atual
	lQuebPag  := .F. // Indica que n�o � necess�rio ocorrer a quebra de pagina, pois j� est� sendo quebrada nesse momento.
	lTitulo   := .T. // Indica que o t�tulo pode ser impresso 
	lLinTit   := .F. // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
	nLinFinal := 0 // Limpa vari�vel de controle da �ltima linha impressa.
	
	// Imprime o restante do conte�do que n�o coube na p�gina anterior.
	JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta)
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpLin(aDados)
Fun��o para montar array de titulos das colunas
 
Uso Geral.

@param 

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpLin(oPrint,nLinAtu,nPosValor,cTexto,oFontVal,nQtdCar,aSobra, lSalta, lImpTit)
Local nRazao    := oPrint:GetTextWidth( "oPrint:nPageWidth", oFontVal )
Local nTam      := (nRazao * nQtdCar) / 350
Local aCampForm := {} // Array com cada palavra a ser escrita.
Local cValor    := ""
Local cValImp   := "" // Valor impresso
Local nX        := 0

cTexto := StrTran(cTexto, Chr(13)+Chr(10), '')
cTexto := StrTran(cTexto, Chr(10), '')
aCampForm := STRTOKARR(cTexto, " ")

If Len(aCampForm) == 0 // Caso n�o exista conte�do/valor
	If lImpTit // E o t�tulo do campo foi impresso 
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Ser� inserida a linha com conte�do em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conte�do/valor
	For nX := 1 To Len(aCampForm) // La�o para cada palavra a ser escrita
		If oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal ) <= nTam // Se a palavra atual for impressa e N�O passar do limite de tamanho da linha
			cValor += aCampForm[nX] + " " // Preenche a linha com a palavra atual
		
			If Len(aCampForm) == nX // Caso esteja na �ltima palavra
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor
				nLinAtu += nSalto // Pula para a pr�xima linha
			EndIf
	
		Else // Se a palavra atual for impressa e passar do limite de tamanho da linha
			oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor sem a palavra que ocasionou a quebra.
			nLinAtu += nSalto // Pula para a pr�xima linha
					
			If nLinAtu + 2*nSalto > nFimL // Se a pr�xima linha a ser impressa N�O couber na p�gina atual
				lSalta := .T. // Indica que precisa continuar a impress�o do conte�do atual na pr�xima p�gina 
				If Empty(SubStr(cTexto,Len(cValImp+cValor)+2,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+3,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor)+1,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+2,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor),1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor),Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				EndIf
				Exit
			Else // Se a pr�xima linha a ser impressa couber na p�gina atual
				cValImp += cValor // Guarda todo o texto que j� foi impresso para que caso necessite de quebra o sistema saiba at� qual parte o texto j� foi impresso.
				cValor := aCampForm[nX] + " " // Preenche a linha com a palavra atual
			EndIf
		EndIf
		
	Next
EndIf

//Limpa array
aSize(aCampForm,0)

Return Nil
