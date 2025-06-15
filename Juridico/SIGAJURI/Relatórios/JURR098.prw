#INCLUDE "JURR098.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE IMP_PDF   6
#DEFINE IMP_SPOOL 2
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   2350 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     3000 // Linha Final da p�gina de um relat�rio
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR098(cCajuri)
Regras do relat�rio de Garantias e alvaras

@param cCajuri Codigo do assunto juridico
@param cFilPro Filial do assunto juridico

@author Wellington Coelho
@since 19/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURR098(cCajuri, cFilPro, lAutomato, cNomeRel, cCaminho)

Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) // Fonte usada no nome do relat�rio
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.) // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.) // Fonte usada nos t�tulos do relat�rio (T�tulo de campos e t�tulos no cabe�alho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.) // Fonte usada nos t�tulos das sess�es
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}
Local cRelat     := STR0001 //"Extrato de Garantia"

//T�tulo do Relat�rio
  // 1 - T�tulo,
  // 2 - Posi��o da descri��o,
  // 3 - Fonte do t�tulo
aRelat := {cRelat,((2200-(1*Len(cRelat)))/2),oFont}//"Relat�rio de Garantias e alvaras"

//Cabe�alho do Relat�rio
  // 1 - T�tulo, 
  // 2 - Conte�do, 
  // 3 - Posi��o de in�cio da descri��o(considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. 
  //     Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. 
  //     Para isso considere sempre a posi��o da maior descri��o),
  // 4 - Fonte do t�tulo, 
  // 5 - Fonte da descri��o
aAdd(aCabec, {STR0002, DToC(Date()) ,(nTamCarac*13), oFontTit, oFontDesc})	//"Impress�o"
aAdd(aCabec, {STR0003, cCajuri 		,(nTamCarac*13), oFontTit, oFontDesc})	//"Assunto Jur�dico"

//Campos do Relat�rio
  //Exemplo da primeira parte -> aAdd(aSessao, {"Relat�rio de Garantias e alvaras",65,oFontSub,.F.,;// 
  // 1 - T�tulo da sess�o do relat�rio,
  // 2 - Posi��o de in�cio da descri��o, 
  // 3 - Fonte no quadro com t�tulo da sess�o,
  // 4 - Impress�o na horizontal -> T�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
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
      // 12 - Imprime o registro? (S/N)

aAdd(aSessao, {STR0004,65,oFontSub,.T.,,;																				//"Detalhe"
                {STR0005,"SA1","A1_NOME"   ,"A1_NOME"   ,"C",65  ,1500 ,oFontTit,oFontDesc,(nTamCarac*18),.F.,.T.},;	//"Cliente:"
                {STR0006,"SA1","A1_LOJA"   ,"A1_LOJA"   ,"C",1200,1800 ,oFontTit,oFontDesc,(nTamCarac*18),.T.,.T.},;	//"Loja:"
                {STR0007,"NVE","NVE_TITULO","NVE_TITULO","C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.F.,.T.},;	//"Caso:"
                {STR0008,"NUQ","NUQ_NUMPRO","NUQ_NUMPRO","C",1200,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.,.T.},;	//"Num. Processo:"
                {STR0009,"NQ6","NQ6_DESC"  ,"NQ6_DESC"  ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.F.,.T.},;	//"Comarca:" 
                {STR0010,"NQC","NQC_DESC"  ,"NQC_DESC"  ,"C",1200,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.,.T.},;	//"Localiza��o 2� N�vel:"
                {STR0011,"NQE","NQE_DESC"  ,"NQE_DESC"  ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.,.T.}})	//"Localiza��o 3� N�vel:"

aAdd(aSessao, {"",65,oFontSub,.F.,J98QryVlr(),;
                {STR0012,"NWB","NWB_DTINIC","NWB_DTINIC","D",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac),.F.,.T.},;	//"Data Inicial"
                {STR0013,"NWB","NWB_DTFIM" ,"NWB_DTFIM" ,"D",400 ,1000 ,oFontTit,oFontDesc,(nTamCarac),.F.,.T.},;	//"Data Final"
                {STR0014,"NWB","NWB_TIPO"  ,"NWB_TIPO"  ,"C",800 ,1000 ,oFontTit,oFontDesc,(nTamCarac),.F.,.T.},;	//"Tipo"
                {STR0015,"NWB","NWB_VALOR" ,"NWB_VALOR" ,"N",1500,1000 ,oFontTit,oFontDesc,(nTamCarac),.F.,.T.},;	//"Valor Garantia"
                {STR0016,"NWB","NWB_VALORA","NWB_VALORA","N",2000,1000 ,oFontTit,oFontDesc,(nTamCarac),.T.,.T.},;	//"Valor Levantamento"
                {STR0025,"NWB","NQW_DESC"  ,"NQW_DESC"  ,"C",2000,1000 ,oFontTit,oFontDesc,(nTamCarac),.T.,.F.}})	//"Descri��o Tipo Garantia"

JRelatorio(aRelat,aCabec,aSessao,J098QrPrin(cCajuri, cFilPro), lAutomato, cNomeRel, cCaminho) //Chamada da fun��o de impress�o do relat�rio em TMSPrinter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J098QrPrin(cCajuri, cFilPro)
Gera a query principal do relat�rio

@param cCajuri Codigo do assunto juridico
@param cFilPro Filial do assunto juridico

@Return cQuery Query principal do relat�rio

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J098QrPrin(cCajuri, cFilPro)
Local cQuery  := ""
Local cFilQry := JQryFilial("NSZ", "SA1", "NSZ001", "SA1001")

	cQuery += "SELECT SA1001.A1_NOME, SA1001.A1_LOJA, NVE001.NVE_TITULO, NUQ001.NUQ_NUMPRO, "
	cQuery += " NQ6001.NQ6_DESC, NQC001.NQC_DESC, NQE001.NQE_DESC, NSZ001.NSZ_COD, NSZ001.NSZ_FILIAL "
	cQuery += " FROM " + RetSqlName("NWB") + " NWB001 "

	cQuery += " INNER JOIN "  + RetSqlName("NSZ") + " NSZ001 "
	cQuery += " ON NSZ001.NSZ_COD = NWB001.NWB_CAJURI "
	cQuery += " AND NSZ001.D_E_L_E_T_ = '' "
	cQuery += " AND  NSZ001.NSZ_FILIAL = NWB001.NWB_FILIAL "

	cQuery += "  INNER JOIN " + RetSqlName("SA1") + " SA1001 "
	cQuery += " ON  NSZ001.NSZ_CCLIEN = SA1001.A1_COD "
	cQuery += " AND  NSZ001.NSZ_LCLIEN = SA1001.A1_LOJA "
	cQuery += " AND " + cFilQry
	cQuery += " AND SA1001.D_E_L_E_T_ = '' "

	cQuery += " INNER JOIN " + RetSqlName("NVE") + " NVE001 "
	cQuery += " ON  NVE001.D_E_L_E_T_ = '' "
	cQuery += " AND  NSZ001.NSZ_CCLIEN = NVE001.NVE_CCLIEN "
	cQuery += " AND  NSZ001.NSZ_LCLIEN = NVE001.NVE_LCLIEN "
	cQuery += " AND  NSZ001.NSZ_NUMCAS = NVE001.NVE_NUMCAS "

	If JCompTable("NVE") == 'EEE'
		cQuery += " AND NVE001.NVE_FILIAL = NSZ001.NSZ_FILIAL"
	Else
		cQuery += " AND NVE001.NVE_FILIAL = '" + xFilial("NVE") + "'"
	EndIf

	cQuery += " LEFT OUTER JOIN " + RetSqlName("NUQ") + " NUQ001 "
	cQuery += " ON NSZ001.D_E_L_E_T_ = '' " 
	cQuery += " AND NUQ001.NUQ_CAJURI = NSZ001.NSZ_COD "
	cQuery += " AND NUQ001.NUQ_FILIAL = NSZ001.NSZ_FILIAL"
	cQuery += " AND NUQ001.NUQ_INSATU = '1' "

	cQuery += " LEFT OUTER JOIN " + RetSqlName("NQ6") + " NQ6001 "
	cQuery += " ON NQ6001.D_E_L_E_T_ = ' ' "
	cQuery += " AND NQ6001.NQ6_FILIAL = '" + xFilial("NQ6") + "'"
	cQuery += " AND NQ6001.NQ6_COD = NUQ001.NUQ_CCOMAR "

	cQuery += " LEFT OUTER JOIN " + RetSqlName("NQC") + " NQC001 "
	cQuery += " ON NQC001.NQC_CCOMAR = NUQ001.NUQ_CCOMAR "
	cQuery += " AND NQC001.NQC_COD = NUQ001.NUQ_CLOC2N "
	cQuery += " AND NQC001.D_E_L_E_T_ = '' "
	cQuery += " AND NQC001.NQC_FILIAL = '" + xFilial("NQC") + "'"

	cQuery += " LEFT OUTER JOIN " + RetSqlName("NQE") + " NQE001 "
	cQuery += " ON NQE001.D_E_L_E_T_ = '' "
	cQuery += " AND NQE001.NQE_CLOC2N = NUQ001.NUQ_CLOC2N "
	cQuery += " AND NQE001.NQE_COD = NUQ001.NUQ_CLOC3N "
	cQuery += " AND NQE001.NQE_FILIAL = '" + xFilial("NQE") + "'"

	cQuery += " WHERE NWB001.D_E_L_E_T_= ' '"
	cQuery += "   AND NWB001.NWB_FILIAL = '" + cFilPro + "' "
	cQuery += "   AND NWB001.NWB_CAJURI = '" + cCajuri + "' "

	cQuery += " GROUP BY SA1001.A1_NOME, SA1001.A1_LOJA, NVE001.NVE_TITULO, "
	cQuery += " NUQ001.NUQ_NUMPRO, NQ6001.NQ6_DESC, NQC001.NQC_DESC, NQE001.NQE_DESC, NSZ001.NSZ_COD, NSZ001.NSZ_FILIAL"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J98QryVlr(cCajuri)
Gera a query do sub relat�rio de Envolvidos
 
Uso Geral.

@param cCajuri Codigo do assunto juridico posicionado

@Return cQueryEnv Query do sub relat�rio de envolvidos

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J98QryVlr(cCajuri)
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQuerySub  := ""

	// Clausula Select
	cQrySel := "SELECT NWB001.NWB_DTINIC, "
	cQrySel +=        " NWB001.NWB_DTFIM, "
	cQrySel +=        " NWB001.NWB_TIPO, "
	cQrySel +=        " NWB001.NWB_VALOR, "
	cQrySel +=        " NWB001.NWB_VALORA, "
	cQrySel +=        " NQW001.NQW_DESC "
	
	// Clausula From
	cQryFrm += " FROM " + RetSqlName("NWB") + " NWB001 " 
	cQryFrm += " LEFT JOIN " + RetSqlName("NT2") + " NT2001 ON NWB001.NWB_CAJURI = NT2001.NT2_CAJURI"
	cQryFrm +=                                            " AND NWB001.NWB_COD = NT2001.NT2_COD "
	cQryFrm +=                                            " AND NT2001.D_E_L_E_T_ = '' "
	cQryFrm += " LEFT JOIN " + RetSqlName("NQW") + " NQW001 ON NT2001.NT2_CTPGAR = NQW001.NQW_COD "
	
	// Clausula Where
	cQryWhr += " WHERE NWB001.D_E_L_E_T_= ' '"
	cQryWhr +=   " AND NWB001.NWB_FILIAL = '@#NSZ_FILIAL#@' "
	cQryWhr +=   " AND NWB001.NWB_CAJURI = '@#NSZ_COD#@' "
	cQryWhr +=   " AND NWB001.NWB_TIPO <> 'S' "
	cQryWhr += " ORDER BY NWB001.NWB_ORDEM "

	// Monta a Query
	cQuerySub := cQrySel + cQryFrm + cQryWhr

Return cQuerySub

//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio(aRelat,aCabec,aSessao,cQuery)
Executa a query principal e inicia a impress�o do relat�rio.
Ferramenta TMSPrinter
Uso Geral.

@param aRelat  Dados do t�tulo do relat�rio
@param aCabec  Dados do cabe�alho do relat�rio
@param aSessao Dados do conte�do do relat�rio
@param cQuery  Query que ser� executada

@Return nil

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat,aCabec,aSessao,cQuery, lAutomato, cNomeRel, cCaminho)

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

Default lAutomato := .F.
Default cNomerel  := AllTrim(aRelat[1]) //Nome do Relat�rio
Default cCaminho  := ""

If !lAutomato
	oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,,.T.,,, "PDF") // Inicia o relat�rio
else
	oPrint := FWMsPrinter():New( cNomeRel, IMP_SPOOL,,, .T.,,,) // Inicia o relat�rio
	//Altera o nome do arquivo de impress�o para o padr�o de impress�o automatica
	oPrint:CFILENAME  := cNomeRel
	oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
EndIf


cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMP,.T.,.T.)

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
			
			If !Empty(aSessao[nI][5]) // Nessa posi��o � indicada a query de um subreport
				JImpSub(aSessao[nI][5], TMP, aSessao[nI],@nLinCalc,@lQuebPag, aRelat, aCabec, @oPrint, @nLin, @lTitulo, @lLinTit) // Imprime os dados do subreport
			Else

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
				Next nJ
	
				nLinCalc := nLinCalc2 // Retorno do valor original da vari�vel
	
				If lQuebPag // Verifica se � necess�rio ocorrer a quebra de pagina
					oPrint:EndPage() // Se � necess�rio, encerra a p�gina atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lQuebPag := .F. // Limpa a vari�vel de quebra de p�gina
					lTitulo  := .T. // Indica que o t�tulo pode ser impresso 
					lLinTit  := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
				EndIf
				
				If lTitulo .And. !Empty(aSessao[nI][1])
					If (nLin + 80) >= nFimL // Verifica se o t�tulo da sess�o cabe na p�gina
						oPrint:EndPage() // Se for maior, encerra a p�gina atual
						ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
						nLinCalc := nLin // Inicia o controle das linhas impressas
						lTitulo := .T. // Indica que o t�tulo pode ser impresso 
						lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
					EndIf
					
				EndIf
				
				If nI == 1 
					JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI]) //Imprime o t�tulo da sess�o no relat�rio
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

		Next nI
		
		//nLin := nLinCalc + nSalto //Ap�s a impress�o da sess�o recalcula a linha de refer�ncia para impress�o
		
		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
		
		nLin += nSalto //Adiciona uma linha em branco ap�s a linha impressa
		nLinCalc := nLin
		
		(TMP)->(DbSkip())
	End

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
(TMP)->(dbCloseArea())


Return(Nil)
//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec(oPrint, nLin, aRelat, aCabec)
Imprime cabe�alho do relat�rio
 
Uso Geral.

@param oPrint  Objeto do Relat�rio (TMSPrinter)
@param nLin    Linha Corrente
@param aRelat  Dados do t�tulo do relat�rio
@param aCabec  Dados do cabe�alho do relat�rio

@Return nil

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
Local nSaltoCabe := 30
Local nI         := 0
Local oFontValor 
Local oFontRoda  := TFont():New("Arial",,-8,,.F.,,,,.T.,.F.) // Fonte usada no Rodap�

oPrint:SetPortrait()   // Define a orienta��o do relat�rio como retrato (Portrait).

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
nLin := 90

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )

//nLin += nSaltoCabe // Espa�o para que o cabe�alho fique um pouco abaixo do T�tulo do Relat�rio 

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

nLin+= nSaltoCabe // Inclui duas linhas em branco ap�s a impress�o do cabe�alho
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio

nLin+=40 //Recalcula a linha de refer�ncia para impress�o

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Trata os tipos de campos e imprime os valores
 
Uso Geral.

@param cTabela Nome da tabela
@param cCpoTab Nome do campo na tabela
@param cCpoQry Nome do campo na query
@param cTipo   Tipo do campo
@param TMP     Alias aberto da query principal
@param SUB     Alias aberto da query do sub relat�rio que esta sendo impresso
@param lSub    Indica se � um sub relat�rio

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 15/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Local cValor := ""
Local cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
Local lPicture := Iif(Empty(cPicture),.F.,.T.)

If lSub
	If cTipo == "D" // Tipo do campo
		TCSetField(SUB, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((SUB)->&(cCpoQry))) //Conte�do a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((SUB)->&(cCpoQry))) // Esse seek � para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "O" // Lista de op��es
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((SUB)->&(cCpoQry))) ) //Retorna o valor do campo
	ElseIf cTipo == "N"
		TcSetField(SUB, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
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
	ElseIf cTipo == "O" // Lista de op��es
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((TMP)->&(cCpoQry))) ) //Retorna o valor do campo
	ElseIf cTipo == "N"
		TcSetField(TMP, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
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
/*/{Protheus.doc} JImpSub(cQuerySub, TMP, aSessao, nLinCalc,lQuebPag, aRelat, aCabec, oPrint, nLin, lTitulo, lLinTit)
Imprime o sub relat�rio
 
Uso Geral.

@param cQuerySub  Query do sub Relat�rio
@param TMP        Alias aberto da query principal 
@param aSessao    Dados do conte�do do relat�rio
@param nLinCalc   Vari�vel de c�lculo de linhas
@param lQuebPag   Indica se deve existir quebra de pagina
@param aRelat     Dados do t�tulo do relat�rio
@param aCabec     Dados do cabe�alho do relat�rio
@param oPrint     Objeto do Relat�rio (TMSPrinter)
@param nLin       Linha Corrente
@param lTitulo    Indica se o titulo de ser impresso
@param lLinTit    Indica se a linha onde ser� impresso o titulo foi definida 

@return nil

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpSub(cQrySub, TMP, aSessao, nLinCalc, lQuebPag ,aRelat , aCabec, oPrint, nLin, lTitulo, lLinTit)
Local nJ     := 0
Local cValor := ""
Local aDados := {}
Local SUB    := GetNextAlias()
Local lHori  := aSessao[4]
Local cVar   := "" // CAMPO
Local xValor       // Valor do campo

	// Substitui os nomes dos campos passados na query por seus respectivos valores
	While RAT("#@", cQrySub) > 0 
		cVar     := SUBSTR(cQrySub, AT("@#", cQrySub) + 2, AT("#@", cQrySub) - (AT("@#", cQrySub) + 2))
		xValor   := (TMP)->(FieldGet(FieldPos(cVar)))
		cQrySub     := SUBSTR(cQrySub, 1,AT("@#", cQrySub)-1) + ALLTRIM(xValor) + SUBSTR(cQrySub, AT("#@", cQrySub)+2)
	End

	cQrySub := ChangeQuery(cQrySub)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySub),SUB,.T.,.T.)

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

		For nJ := 6 to Len(aSessao) // L� as informa��es de cada campo a ser impresso. O contador come�a em 6 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
			
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
			//lTitulo := .T. // Indica que o t�tulo pode ser impresso 
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

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDadosCpo(aSessao, cValor, nLinCalc, lQuebPag)
Fun��o para montar array com as descri��es e conte�dos dos campos que ser�o impressos, 
assim como suas coordenadas, fontes e quebra de linha ap�s a impress�o de cada campo. 
 
Uso Geral.

@param aSessao  Dados do conte�do do relat�rio
@param cValor   Conte�do do campo que ser� impresso
@param nLinCalc Vari�vel de c�lculo de linhas
@param lQuebPag Indica se deve existir quebra de pagina

@return aDados Array com a Sess�o formatada

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDadosCpo(aSessao, cValor, nLinCalc, lQuebPag)
Local aDados := {}
Local cTitulo := ""
Local nPosTit := 0
Local oFontTit
Local nPos := 0
Local nQtdCar := 0
Local oFontVal
Local nPosValor := 0
Local lQuebLin := .F.

cTitulo  := aSessao[1] //T�tulo da Coluna
nPosTit  := aSessao[6] //Indica a coordenada horizontal em pixels ou caracteres
oFontTit := aSessao[8] //Fonte do t�tulo
nPos     := aSessao[6] //Indica a coordenada horizontal para imprimir o valor do campo
nQtdCar  := aSessao[7] //Quantidade de caracteres para que seja feita a quebra de linha
oFontVal := aSessao[9] //Fonte usada para impress�o do conte�do
nPosValor:= aSessao[10] //Fonte usada para impress�o do conte�do
lQuebLin := aSessao[11] //Indica se deve existir a quebra de linha
lImprime := aSessao[12] //Indica se o campo deve ser impresso no relat�rio

If !lQuebPag // Verifica se ser� necess�ria quebra de p�gina para essa sess�o
	lQuebPag := ((Int((Len(cValor)/nQtdCar) + 1) * nSalto) + nLinCalc) > nFimL
	nLinCalc += (Int((Len(cValor)/nQtdCar) + 1) * nSalto) // Indica a linha que ser� usada para cada valor quando forem impressos - Usado apenas para uma simula��o.
EndIf

aDados := {cTitulo, nPosTit, oFontTit, cValor, nQtdCar, oFontVal, nPos, nPosValor, lQuebLin, lImprime}

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta)
Fun��o que trata as quebras de pagina e imprime as Sess�es na vertical e horizontal 
 
Uso Geral.

@param aDados    Array com a Sess�o formatada
@param nLin      Linha Corrente
@param nLinCalc  Vari�vel de c�lculo de linhas
@param oPrint    Objeto do Relat�rio (TMSPrinter)
@param nLinFinal Ultima linha que tem conte�do impresso 
@param lHori     Indica se impress�o ser� na horizontal ou vertical
@param lTitulo   Indica se o titulo deve ser impresso
@param lLinTit   Indica se a linha onde ser� impresso o titulo foi definida
@param aRelat    Dados do t�tulo do relat�rio
@param aCabec    Dados do cabe�alho do relat�rio 
@param lSalta    Indica se precisa continuar a impress�o do conte�do atual na pr�xima p�gina

@return nil

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta, lRecursivo)
Local nJ        := 0
Local cTitulo   := ""
Local nPosTit   := 0
Local oFontTit
Local nPos      := 0
Local nQtdCar   := 0
Local oFontVal
Local nPosValor := 0
Local lQuebLin  := .F.
Local lImpTit   := .T.
Local cValor    := ""
Local nLinTit   := 0
Local nLinAtu   := 0
Local aSobra    := aClone(aDados)
Local cTipo     := ""
Local nCorFont  := 0
Local lTrataVal := .F.
Local lImprime  := .T.

Default lSalta  := .F.
Default lHori   := .T.
If lRecursivo
	aSobra[4] := ""
Else
	aEval(aSobra,{|x| x[4] := ""}) // Limpa a posi��o de conte�do/valor dos campos no array de sobra, pois ele � preenchido com os dados do array aDados. Limpa para que seja preenchido com o conte�do da sobra.
EndIf

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

	lImprime := aDados[nJ][10] //Indica se o campo deve ser impresso no relat�rio
	
	If cTitulo == STR0012 //"Data Inicial"
		cTipo    := aDados[3][4]
		cTempVal := aDados[4][4]
	EndIf
	
	If cTipo == "A" //Formata valor do levantamento
		lTrataVal := .T. 
	EndIf
	
	If lTrataVal .AND. cTitulo == STR0016	//"Valor Levantamento"
		cValor := "-"+cValor //Formata valor do levantamento
		lTrataVal := .F.
	EndIf
	
	If (cTipo == "TT" .OR. cTipo == "TTSA") .AND. (cTitulo == STR0012 .OR. cTitulo == STR0013)	//"Data Inicial" //"Data Final"
		cValor := "" // N�o apresenta data
	EndIf
	
	If (cTitulo == STR0012 .OR. cTitulo == STR0013) .AND. cValor == "/  /"	//"Data Inicial" //"Data Final"
		cValor := ""
	EndIf
	
	If (cTitulo == STR0015 .OR. cTitulo == STR0016) .AND. !EMPTY(cValor)	//"Valor Garantia" //"Valor Levantamento"
		cValor := "R$  " + cValor
	EndIf
	
	If cTipo $ "A|G" .AND. cValor $ "A|G"
		cValor := cTipo + " - " + aDados[6][4] // Descri��o do tipo da garantia(NQW_DESC)
	EndIf

	If lHori // Impress�o na horizontal -> t�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
		nLinTit  := nLin
		nLinCalc := nLin
		If lTitulo .and. lImprime
			oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os t�tulos das colunas
		EndIf
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
				//nLin     += nSalto
				nLinCalc := nLin
				lLinTit := .T. // Indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
			EndIf
			
			If lTitulo .and. lImprime // Indica que o t�tulo pode ser impresso
				oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os t�tulos das colunas
				
				lTitulo := Len(aDados) <> nJ // Enquanto estiver preenchendo os t�tulos indica .T., para que os outros t�tulos sejam impressos. 
				                             // Ap�s o preenchimento do �ltimo t�tulo indica .F., n�o premitindo mais a impress�o dos t�tulos nessa p�gina.
				If cTitulo == STR0016	//"Valor Levantamento"
					lTitulo := .F.
				EndIf
				
				If cTitulo == STR0012	//"Data Inicial"
					nLinCalc += nSalto
				EndIf
				// Deve imprimir apenas uma vez por p�gina para que a letra n�o fique mais grossa.
				// Se n�o tiver esse tratamento a impress�o ser� feita v�rias vezes sobre a mesma palavra devido as condi��es do la�o, 
				// fazendo com que a grossura das letras nas palavras aumente e isso atrapalha.
				
			EndIf
		EndIf
		nPosValor := nPosTit // Indica que a posi��o (coluna) do conte�do/valor a ser impresso � a mesma que foi impresso o titulo, ou seja, o conte�do/valor ficar� logo abaixo do t�tulo
	EndIf

	nLinAtu := nLinCalc // Controle de linhas usadas para imprimir o conte�do atual
	
	If !(cTipo == "J" .and. cTempVal == "0,00") .and. lImprime
		JImpLin(@oPrint,@nLinAtu,nPosValor,cValor,oFontVal,nQtdCar,@aSobra[nJ], @lSalta, lImpTit, @cTipo, @nCorFont) //Imprime as linhas com os conte�dos/valores
	EndIf
	
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
		JImpRel(aSobra[nJ],@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta, .T.)
		aEval(aSobra,{|x| x[4] := ""})
	EndIf

	If lQuebLin // Indica que � necess�ria quebra de linha, ou seja, o pr�ximo campo ser� impresso na pr�xima linha
		//If !(cTipo == "J" .and. cTempVal == "0,00")
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
		//EndIf
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
/*/{Protheus.doc} JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit, cTipo, nCorFont)
Fun��o para montar array de titulos das colunas
 
Uso Geral.

@param oPrint    Objeto do Relat�rio (TMSPrinter)
@param nLinAtu   Linha onde ser� impresso a pr�xima informa��o
@param nPosValor Posi��o do conte�do
@param cTexto    Conte�do completo de cada coluna
@param oFontVal  Fonte usada para impress�o do conte�do
@param nQtdCar   Quantidade de caracteres para que seja feita a quebra de linha
@param aSobra    Array com o valor que n�o coube em alguma das colunas da p�gina anterior, e falta ser impresso
@param lSalta    Indica se precisa continuar a impress�o do conte�do atual na pr�xima p�gina
@param lImpTit   Indica se o t�tulo precisa ser impresso

@return nil

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit, cTipo, nCorFont)
Local nRazao    := oPrint:GetTextWidth( "oPrint:nPageWidth", oFontVal )
Local nTam      := (nRazao * nQtdCar) / 350
Local aCampForm := {} // Array com cada palavra a ser escrita.
Local cValor    := ""
Local cValImp   := "" // Valor impresso
Local nX        := 0
Local oBrush1

Default nCorFont  := 0
Default cTipo := ""

If LEFT(cTexto, 3) == "G -"
	cTexto := cTexto	//"G - Descri��o do Tipo da Garantia do registro posicionado"
ElseIf cTexto == 'J'
	cTexto := STR0018	//"Juros"
ElseIf cTexto == 'S'
	cTexto := STR0019	//"Saldo"
ElseIf LEFT(cTexto, 3) == "A -"
	cTexto := StrTran(cTexto, "A -", "L -")	//"L - Descri��o do Alvar� do registro posicionado" //Substitui��o de "A -" por "L -"
ElseIf cTexto == 'SF'
	cTexto := STR0021	//"Saldo em Ju�zo Atualizado"
ElseIf cTexto == 'SFSA'
	cTexto := STR0022	//"Saldo em Ju�zo"
ElseIf cTexto == 'TT'
	cTexto := STR0023	//"Total Saldo em Ju�zo Atualizado"
ElseIf cTexto == 'TTSA'
	cTexto := STR0024	//"Total Saldo em Ju�zo"
EndIf

cTexto	  := StrTran(cTexto, Chr(13), "")
cTexto 	  := StrTran(cTexto, Chr(10), "")
aCampForm := StrToKarr(cTexto, " ")

If Len(aCampForm) == 0 // Caso n�o exista conte�do/valor
	If lImpTit // E o t�tulo do campo foi impresso 
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, Nil ) // Ser� inserida a linha com conte�do em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conte�do/valor
	For nX := 1 To Len(aCampForm) // La�o para cada palavra a ser escrita
		If oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal ) <= nTam // Se a palavra atual for impressa e N�O passar do limite de tamanho da linha
			cValor += aCampForm[nX] + " " // Preenche a linha com a palavra atual
		
			If Len(aCampForm) == nX // Caso esteja na �ltima palavra
				
				If !EMPTY(cTipo) .AND. (cTipo == 'J' .OR. cTipo == 'SF' .OR. cTipo == 'SFSA')
					If cTipo == 'J' //'Juros' 
						oBrush1 := TBrush():New( , Rgb(255,255,0) )
						oPrint:FillRect( {(nLinAtu-25), nColIni, (nLinAtu+10), nColFim}, oBrush1 )
						oBrush1:End()
						oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil )
					ElseIf cTipo == 'SF' //'Saldo em Ju�zo Atualizado'
						oBrush1 := TBrush():New( , Rgb(169,169,169) )
						oPrint:FillRect( {(nLinAtu-25), nColIni, (nLinAtu+10), nColFim}, oBrush1 )
						oBrush1:End()
						oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil )
					ElseIf cTipo == 'SFSA' /*'Saldo em Ju�zo'*/
						oBrush1 := TBrush():New( , Rgb(0,0,0) )
						oPrint:FillRect( {(nLinAtu-25), nColIni, (nLinAtu+10), nColFim}, oBrush1 )
						oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil, CLR_WHITE ) // Insere a linha com o conte�do que estava em cValor
						nCorFont := CLR_WHITE
						oBrush1:End()
					EndIf
					cTipo := ""
				Else
					If cTipo == 'A' //'Levantamento"
						oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil, CLR_HRED )
						nCorFont := CLR_HRED
					ElseIf nCorFont == 0
						oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil ) // Insere a linha com o conte�do que estava em cValor
					Else
						oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil, nCorFont )
					EndIf
				EndIf
				nLinAtu += nSalto // Pula para a pr�xima linha
			EndIf
	
		Else // Se a palavra atual for impressa e passar do limite de tamanho da linha
			oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil ) // Insere a linha com o conte�do que estava em cValor sem a palavra que ocasionou a quebra.
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
			
			If Len(aCampForm) == nX
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor sem a palavra que ocasionou a quebra.
				nLinAtu += nSalto // Pula para a pr�xima linha	
			EndIf
			
		EndIf
		
	Next
EndIf

//Limpa array
aSize(aCampForm,0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpTitSes()
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
Static Function JImpTitSes(oPrint, nLin, nLinCalc, aSessao)
Local oBrush1

oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)

oBrush1 := TBrush():New( , CLR_LIGHTGRAY )
oPrint:FillRect( {nLin-20, nColIni, (nLin + 30), nColFim}, oBrush1 )
oBrush1:End()
	
	//aSessao[1] - T�tulo da sess�o do relat�rio
	//aSessao[2] - Posi��o da descri��o
	//aSessao[3] - Fonte da sess�o
oPrint:Say( nLin+15, aSessao[2], aSessao[1], aSessao[3])
	
nLin+=80
nLinCalc := nLin

Return
