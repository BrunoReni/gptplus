#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURR095M.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_PDF   6
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   2350 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     3000 // Linha Final da p�gina de um relat�rio
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR095M
Regras do relat�rio de Marcas e patentes

@param cUser Usuario
@param cThread Se��o
@param cDir Diret�rio de trabalho
@param cNomeRel Nome do relat�rio

@author Wellington Coelho
@since 19/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JURR095M(cUser, cThread, cDir, cNomerel)
Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) // Fonte usada no nome do relat�rio
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos do relat�rio (T�tulo de campos e t�tulos no cabe�alho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos das sess�es
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}

//T�tulo do Relat�rio
  // 1 - T�tulo,
  // 2 - Posi��o da descri��o,
  // 3 - Fonte do t�tulo
aRelat := {STR0001,800,oFont}//"Relat�rio de Marcas e patentes"		//"Marcas e patentes"

//Cabe�alho do Relat�rio
  // 1 - T�tulo, 
  // 2 - Conte�do, 
  // 3 - Posi��o de in�cio da descri��o(considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. 
  //     Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. 
  //     Para isso considere sempre a posi��o da maior descri��o),
  // 4 - Fonte do t�tulo, 
  // 5 - Fonte da descri��o
aCabec := {{STR0002,DToC(Date()) ,(nTamCarac*9),oFontTit,oFontDesc}}		//"Impress�o"

//Campos do Relat�rio
  //Exemplo da primeira parte -> aAdd(aSessao, {"Relat�rio de Marcas e patentes",65,oFontSub,.F.,;// 
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
aAdd(aSessao, {"",65,oFontSub,.T.,,;
                {STR0003 ,"NSZ","NSZ_COD"    ,"NSZ_COD"    ,"C",65  ,250  ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"Processo"
                {STR0004 ,"NSZ","NSZ_NUMPED" ,"NSZ_NUMPED" ,"C",650 ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"N�mero do pedido"
                {STR0005 ,"NSZ","NSZ_BITMAP" ,"NSZ_BITMAP" ,"I",2000,1000 ,oFontTit,oFontDesc,(0),.T.},;			//"Imagem"
                {STR0006 ,"NSZ","NSZ_NOMEMA" ,"NSZ_NOMEMA" ,"C",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Marca"
                {STR0007 ,"NY8","NY8_DESC"   ,"NY8_DESC"   ,"C",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Apresenta��o"
                {STR0008 ,"NSZ","NSV_DESC"   ,"NSV_DESC"   ,"C",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Classe"
                {STR0009 ,"NSZ","NSZ_DTSOLI" ,"NSZ_DTSOLI" ,"D",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Concess�o"
                {STR0010 ,"NSZ","NSZ_DTSITU" ,"NSZ_DTSITU" ,"D",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Data da Situa��o"
                {STR0011 ,"NSZ","NSZ_SITREL" ,"NSZ_SITREL" ,"C",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Situa��o"
                {STR0012 ,"NT4","NT4_DESC"   ,"RECNONT4"   ,"M",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.}})	//"Status"

JRelatorio(aRelat,aCabec,aSessao,J95MQrPrin(cUser, cThread),cDir, cNomerel) //Chamada da fun��o de impress�o do relat�rio em TMSPrinter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J95MQrPrin(cUser, cThread)
Gera a query principal do relat�rio
 
Uso Geral.

@param cUser Usuario
@param cThread Se��o

@Return cQuery Query principal do relat�rio

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J95MQrPrin(cUser, cThread)
Local cQuery := ""

cQuery := " SELECT NSZ001.NSZ_COD, NSZ_BITMAP, NSV001.NSV_DESC, NY8001.NY8_DESC, NSZ001.NSZ_NOMEMA, "
cQuery += "  NSZ001.NSZ_DTSOLI, NSZ001.NSZ_SITREL, NSZ001.NSZ_DTSITU, NSZ001.NSZ_NUMPED, "
cQuery += "  NSZ001.NSZ_FILIAL, NSZ001.D_E_L_E_T_, NQ3001.NQ3_CUSER, NQ3001.D_E_L_E_T_, NQ3001.NQ3_SECAO, "

cQuery += " (SELECT R_E_C_N_O_ FROM " + RetSqlName("NT4")
cQuery += "  WHERE D_E_L_E_T_ = ' ' AND NT4_FILIAL = NSZ001.NSZ_FILIAL AND NT4_CAJURI=NSZ001.NSZ_COD " 
cQuery += "  AND (NT4_DTANDA||NT4_COD) = (SELECT MAX(NT4_DTANDA||NT4_COD) FROM " + RetSqlName("NT4") + " WHERE D_E_L_E_T_ = ' ' "
cQuery += "  AND NT4_CAJURI = NSZ001.NSZ_COD AND NT4_FILIAL = NSZ001.NSZ_FILIAL  )) RECNONT4 "


cQuery += " FROM " + RetSqlName("NQ3") + " NQ3001 " 

cQuery += "  INNER JOIN "  + RetSqlName("NSZ") + " NSZ001 "
cQuery += "   ON ( NSZ001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( NSZ001.NSZ_FILIAL = NQ3001.NQ3_FILORI )"
cQuery += "   AND ( NSZ001.NSZ_COD = NQ3001.NQ3_CAJURI )"

cQuery += "  LEFT OUTER JOIN "  + RetSqlName("NY8") + " NY8001 "
cQuery += "   ON ( NY8001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( NY8001.NY8_FILIAL = '" + xFilial("NY8") + "')"
cQuery += "   AND ( NY8001.NY8_COD = NSZ001.NSZ_CNATMA ) "

cQuery += "  LEFT OUTER JOIN " + RetSqlName("NSV") + " NSV001 "
cQuery += "   ON ( NSV001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( NSV001.NSV_FILIAL = '" + xFilial("NSV") + "')"
cQuery += "   AND ( NSV001.NSV_COD = NSZ001.NSZ_CCLASS )"

cQuery += " WHERE  NQ3001.D_E_L_E_T_= ' '"
cQuery += "   AND NQ3001.NQ3_FILIAL = '" + xFilial("NQ3") + "'"
cQuery += "   AND NQ3001.NQ3_SECAO = '" +cThread+ "'"
cQuery += "   AND NQ3001.NQ3_CUSER = '" +cUser+ "'"
cQuery += "   AND NQ3001.NQ3_SECAO = '" +cThread+ "'"

cQuery += " ORDER BY NSZ001.NSZ_COD, NSZ001.NSZ_DTSOLI  " 

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio
Executa a query principal e inicia a impress�o do relat�rio.
Ferramenta TMSPrinter
Uso Geral.

@param aRelat   Dados do t�tulo do relat�rio
@param aCabec   Dados do cabe�alho do relat�rio
@param aSessao  Dados do conte�do do relat�rio
@param cQuery   Query que ser� executada
@param cDir     Diret�rio onde ser� gerado o arquivo
@param cNomerel Nome do arquivo gerado

@Return nil

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat,aCabec,aSessao,cQuery, cDir, cNomerel)
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
Local cTmpDir   := __cUserID +  SubStr(AllTrim(Str(ThreadId())),1,4)

Default cNomeRel := aRelat[1] //Nome do Relat�rio

oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,,.T. ) // Inicia o relat�rio

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
				nLinCalc2 := nLinCalc // Backup da pr�xima linha a ser usada, pois na fun��o JDadosCpo abaixo a variavel tem seu conte�do alterado para
		                      // que seja realizada uma simula��o das linhas usadas para impress�o do conte�do. 

				nLinFinal := 0 // Limpa a vari�vel

				For nJ := 6 to Len(aSessao[nI]) // L� as informa��es de cada campo a ser impresso. O contador come�a em 6 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
					cTabela  := aSessao[nI][nJ][2] //Tabela
					cCpoTab  := aSessao[nI][nJ][3] //Nome do campo na tabela
					cCpoQry  := aSessao[nI][nJ][4] //Nome do campo na query
					cTipo    := aSessao[nI][nJ][5] //Tipo do campo

					If cTipo == "I"
						
						cDir := Iif( 'spool' $ Lower(cDir), '\spool\' + cTmpDir + "\", cDir)
						cDir := Iif("Linux" $ GetSrvInfo()[2],StrTran(cTmpDir, "\", "/" ), cDir)

						cValor := cDir + (TMP)->NSZ_COD
						cValor += Iif(File(cValor + ".bmp"),".bmp",".jpg")
					Else
						cValor := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,,.F.) // Retorna o conte�do/valor a ser impresso. Chama essa fun��o para tratar o valor caso seja um memo ou data
					EndIf
					
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

		Next nI
		
		//nLin := nLinCalc + nSalto //Ap�s a impress�o da sess�o recalcula a linha de refer�ncia para impress�o
		
		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
		
		nLin += nSalto //Adiciona uma linha em branco ap�s a linha impressa
		nLinCalc := nLin
		
		(TMP)->(DbSkip())
	End

(TMP)->(dbCloseArea())

aSize(aDados,0)  //Limpa array de dados
aSize(aRelat,0)  //Limpa array de dados do relat�rio
aSize(aCabec,0)  //Limpa array de dados do cabe�alho do relat�rio
aSize(aSessao,0) //Limpa array de dados das sess�es do relat�rio

oPrint:EndPage() // Finaliza a p�gina

oPrint:CFILENAME := cNomeRel + '.rel'
oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
oPrint:Print()

FErase(oPrint:CFILEPRINT)
EndIf

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
//nLin+=10
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

If lSub
	If cTipo == "D" // Tipo do campo
		TCSetField(SUB, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((SUB)->&(cCpoQry))) //Conte�do a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((SUB)->&(cCpoQry))) // Esse seek � para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
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
	Else
		cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
	EndIf
EndIf

Return cValor

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

If !lQuebPag // Verifica se ser� necess�ria quebra de p�gina para essa sess�o
	lQuebPag := ((Int((Len(cValor)/nQtdCar) + 1) * nSalto) + nLinCalc) > nFimL
	nLinCalc += (Int((Len(cValor)/nQtdCar) + 1) * nSalto) // Indica a linha que ser� usada para cada valor quando forem impressos - Usado apenas para uma simula��o.
EndIf

aDados := {cTitulo, nPosTit, oFontTit, cValor, nQtdCar, oFontVal, nPos, nPosValor, lQuebLin}

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
Local aSobra    := aClone(aDados)
Local cBarra    := Iif("Linux" $ GetSrvInfo()[2],"/","\")
Local cTitulo   := ""
Local cValor    := ""
Local lImpTit   := .T.
Local lQuebLin  := .F.
Local nJ        := 0
Local nLinAtu   := 0
Local nLinTit   := 0
Local nPos      := 0
Local nPosTit   := 0
Local nPosValor := 0
Local nQtdCar   := 0
Local oFontTit  := Nil
Local oFontVal  := Nil

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

	If lRecursivo
		cTitulo  := aDados[1] //T�tulo da Coluna
		nPosTit  := aDados[2] //Indica a coordenada horizontal em pixels ou caracteres
		oFontTit := aDados[3] //Fonte do t�tulo
		cValor   := aDados[4] //Valor a ser impresso
		nQtdCar  := aDados[5] //Quantidade de caracteres para que seja feita a quebra de linha
		oFontVal := aDados[6] //Fonte usada para impress�o do conte�do
		nPos     := aDados[7] //Indica a coordenada horizontal para imprimir o valor do campo
		nPosValor:= aDados[8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
		lQuebLin := aDados[9] // Indica se deve existir quebra de linha ap�s a impress�o do campo
	Else
		cTitulo  := aDados[nJ][1] //T�tulo da Coluna
		nPosTit  := aDados[nJ][2] //Indica a coordenada horizontal em pixels ou caracteres
		oFontTit := aDados[nJ][3] //Fonte do t�tulo
		cValor   := aDados[nJ][4] //Valor a ser impresso
		nQtdCar  := aDados[nJ][5] //Quantidade de caracteres para que seja feita a quebra de linha
		oFontVal := aDados[nJ][6] //Fonte usada para impress�o do conte�do
		nPos     := aDados[nJ][7] //Indica a coordenada horizontal para imprimir o valor do campo
		nPosValor:= aDados[nJ][8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
		lQuebLin := aDados[nJ][9] // Indica se deve existir quebra de linha ap�s a impress�o do campo
	EndIf

		If lHori // Impress�o na horizontal -> t�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
			nLinTit  := nLin
			nLinCalc := nLin
			If lTitulo .AND. cTitulo != "Imagem"
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

		If cTitulo == "Imagem"

			If ! File(cValor)
				cDir := SubStr(cValor, 0, rat(cBarra, cValor)) + __cUserID + SubStr(AllTrim(Str(ThreadId())),1,4)
				cValor := cDir + SubStr(cValor, rat(cBarra, cValor))
			EndIf

			oPrint:SayBitmap ( nLinAtu - 30, nPosValor, cValor, 250, 250, .T. )
		Else
			JImpLin(@oPrint,@nLinAtu,nPosValor,cValor,oFontVal,nQtdCar,@aSobra[nJ], @lSalta, lImpTit) //Imprime as linhas com os conte�dos/valores
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
		If lRecursivo
			Exit
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
/*/{Protheus.doc} JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit)
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
Static Function JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit)
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
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, Nil ) // Ser� inserida a linha com conte�do em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conte�do/valor
	For nX := 1 To Len(aCampForm) // La�o para cada palavra a ser escrita
		If oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal ) <= nTam // Se a palavra atual for impressa e N�O passar do limite de tamanho da linha
			cValor += aCampForm[nX] + " " // Preenche a linha com a palavra atual
		
			If Len(aCampForm) == nX // Caso esteja na �ltima palavra
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal, nil ) // Insere a linha com o conte�do que estava em cValor
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
