#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "JURR163.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   3000 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     2350 // Linha Final da p�gina de um relat�rio
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR163()
Regras do relat�rio de Auditoria de acessos de usu�rios

@param lAutomato - Indica se � execu��o de automa��o
@param aUsuarios - Indica os usu�rios que ser�o considerados no relat�rio (automa��o)
@param cNomeRel  - Indica o nome do arquivo que ser� gravado (automa��o)

@author Wellington Coelho
@since 19/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JURR163(lAutomato, aUsuarios, cNomeRel)

	Processa( {|| J163Relat(lAutomato, aUsuarios, cNomeRel)} )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J163Relat()
Monta o relatorio

@param lAutomato - Indica se � execu��o de automa��o
@param aUsuarios - Indica os usu�rios que ser�o considerados no relat�rio (automa��o)
@param cNomeRel  - Indica o nome do arquivo que ser� gravado (automa��o)

@author Wellington Coelho
@since 19/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function J163Relat(lAutomato, aUsuarios, cNomeRel)

Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) 	// Fonte usada no nome do relat�rio
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos do relat�rio (T�tulo de campos e t�tulos no cabe�alho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos das sess�es
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}

ProcRegua(0)
IncProc(STR0030)	//"Gerando... Relat�rio"

//T�tulo do Relat�rio
  // 1 - T�tulo,
  // 2 - Posi��o da descri��o,
  // 3 - Fonte do t�tulo
aRelat := {STR0001,2400/2,oFont} //"Auditoria de acessos de usu�rios"

//Cabe�alho do Relat�rio
  // 1 - T�tulo,
  // 2 - Conte�do,
  // 3 - Posi��o de in�cio da descri��o(considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123.
  //     Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento.
  //     Para isso considere sempre a posi��o da maior descri��o),
  // 4 - Fonte do t�tulo,
  // 5 - Fonte da descri��o
aCabec := {{STR0002,DToC(Date()) ,(nTamCarac*8),oFontTit,oFontDesc}}//"Data"

//Campos do Relat�rio
  //Exemplo da primeira parte -> aAdd(aSessao, {"Relat�rio de Concess�es",65,oFontSub,.F.,;//
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

aAdd(aSessao, {STR0003,65,oFontSub,.F.,,; // T�tulo da sess�o do relat�rio "Usu�rio"
		{STR0004/*"C�digo pesquisa"*/   ,"NVK","NVK_CPESQ" 	,"NVK_CPESQ"  	,"C",060 ,200 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0005/*"Descri��o pesquisa"*/,"NVG","NVG_DESC"  	,"NVG_DESC"   	,"C",300 ,300 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0006/*"Tipo de pesquisa"*/  ,"NVG","NVG_TPPESQ"	,"NVG_TPPESQ" 	,"O",600 ,300 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0007/*"Tipo de acesso"*/    ,"NVK","NVK_TIPOA" 	,"NVK_TIPOA"  	,"O",900 ,500 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0029/*"Grupo"*/     		,"NZX","NZX_DESC" 	,"NZX_DESC" 	,"C",1250,1500,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0028/*"Correspondente"*/	,"SA2","A2_NOME" 	,"A2_NOME"  	,"C",2300,1700,oFontTit,oFontDesc,(nTamCarac*12),.F.}	})

aAdd(aSessao, {STR0008,100,oFontSub,.F.,J163RstCli(),; // T�tulo da sess�o do relat�rio "Restri��o de clientes"
		{STR0009/*"C�digo Cliente"*/ ,"NWO" ,"NWO_CCLIEN" ,"NWO_CCLIEN" ,"C",150 ,500 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0010/*"Loja"*/           ,"NWO" ,"NWO_CLOJA"  ,"NWO_CLOJA"  ,"C",650 ,350 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0011/*"Raz�o social"*/   ,"SA1" ,"A1_NOME "   ,"A1_NOME "   ,"C",1000,2000,oFontTit,oFontDesc,(nTamCarac*12),.F.}})

aAdd(aSessao, {STR0012,100,oFontSub,.F.,J163RstGru(),; // T�tulo da sess�o do relat�rio "Restri��o de grupos de clientes"
		{STR0013/*"C�digo Grupo"*/ ,"NY2" ,"NY2_CGRUP" ,"NY2_CGRUP" ,"C",150 ,200,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0014/*"Nome grupo"*/   ,"ACY" ,"ACY_DESCRI","ACY_DESCRI","C",650 ,900,oFontTit,oFontDesc,(nTamCarac*12),.F.}})

aAdd(aSessao, {STR0015,100,oFontSub,.F.,J163RstRot(),; // T�tulo da sess�o do relat�rio "Restri��o de acesso a rotinas"
		{STR0016/*"C�digo rotina"*/ ,"NWP" ,"NWP_CROT"  ,"NWP_CROT"  ,"C",150 ,200,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0017/*"Nome rotina"*/   ,"SX5" ,"X5_DESCRI" ,"X5_DESCRI" ,"C",400 ,500,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0018/*"Visualizar?"*/   ,"NWP" ,"NWP_CVISU" ,"NWP_CVISU" ,"O",800 ,200,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0019/*"Incluir?"*/      ,"NWP" ,"NWP_CINCLU","NWP_CINCLU","O",1150,200,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0020/*"Alterar?"*/      ,"NWP" ,"NWP_CALTER","NWP_CALTER","O",1500,200,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0021/*"Excluir?"*/      ,"NWP" ,"NWP_CEXCLU","NWP_CEXCLU","O",2000,200,oFontTit,oFontDesc,(nTamCarac*12),.F.}})

aAdd(aSessao, {STR0022,100,oFontSub,.F.,J163RstEsc(),; // T�tulo da sess�o do relat�rio "Restri��o de escrit�rio"
		{STR0023/*"C�digo escrit�rio"*/    ,"NYK" ,"NYK_CESCR","NYK_CESCR","C",150 ,200 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0024/*"Descri��o escrit�rio"*/ ,"NS7" ,"NS7_NOME" ,"NS7_NOME" ,"C",400 ,1000,oFontTit,oFontDesc,(nTamCarac*12),.F.}})

aAdd(aSessao, {STR0025,100,oFontSub,.F.,J163RstArea(),; // T�tulo da sess�o do relat�rio "Restri��o de �rea"
		{STR0026/*"C�digo �rea"*/     ,"NYL" ,"NYL_CAREA" ,"NYL_CAREA" ,"C",150 ,200 ,oFontTit,oFontDesc,(nTamCarac*12),.F.},;
		{STR0027/*"Descri��o �rea"*/  ,"NRB" ,"NRB_DESC " ,"NRB_DESC " ,"C",400 ,1000,oFontTit,oFontDesc,(nTamCarac*12),.F.}})

JRelatorio(aRelat,aCabec,aSessao, lAutomato, aUsuarios, cNomeRel)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J163QrPrin(cUsuario)
Gera a query principal do relat�rio

Uso Geral.

@param cUsuario c�digo do usu�rio

@Return cQuery Query principal do relat�rio

@author Wellington Coelho
@since 15/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163QrPrin(cUsuario)
Local cQuery := ""

cQuery := "SELECT NVK.NVK_CPESQ,NVG.NVG_DESC,NVG.NVG_TPPESQ,NVK.NVK_COD,NVK.NVK_TIPOA,NZX.NZX_DESC,SA2.A2_NOME "
cQuery += "FROM " + RetSqlName("NVK") + " NVK JOIN " + RetSqlName("NVG") + " NVG "
cQuery += "ON (NVK.NVK_CPESQ = NVG.NVG_CPESQ) "
cQuery += "LEFT JOIN " + RetSqlName("NZX") + " NZX "
cQuery += "ON (NZX.NZX_FILIAL = '" + xFilial("NZX") + "' AND NVK.NVK_CGRUP = NZX.NZX_COD AND NZX.D_E_L_E_T_ = ' ') "
cQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 "
cQuery += "ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND NVK.NVK_CCORR = SA2.A2_COD AND NVK.NVK_CLOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ') "
cQuery += "WHERE NVG.NVG_FILIAL = '" + xFilial("NVG") + "' "
cQuery += "AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
cQuery += "AND NVK.NVK_CUSER = '" + cUsuario + "' "
cQuery += "AND NVG.D_E_L_E_T_='' AND NVK.D_E_L_E_T_=''"

cQuery += " UNION "

cQuery += "SELECT NVK.NVK_CPESQ,NVG.NVG_DESC,NVG.NVG_TPPESQ,NVK.NVK_COD,NVK.NVK_TIPOA,NZX.NZX_DESC,SA2.A2_NOME "
cQuery += "FROM " + RetSqlName("NVK") + " NVK JOIN " + RetSqlName("NVG") + " NVG "
cQuery += "ON (NVK.NVK_CPESQ = NVG.NVG_CPESQ) "
cQuery += "LEFT JOIN " + RetSqlName("NZX") + " NZX "
cQuery += "ON (NZX.NZX_FILIAL = '" + xFilial("NZX") + "' AND NVK.NVK_CGRUP = NZX.NZX_COD AND NZX.D_E_L_E_T_ = ' ') "
cQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 "
cQuery += "ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND NVK.NVK_CCORR = SA2.A2_COD AND NVK.NVK_CLOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ') "
cQuery += "WHERE NVG.NVG_FILIAL = '" + xFilial("NVG") + "' "
cQuery += "AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
cQuery += "AND NVG.D_E_L_E_T_=' ' "
cQuery += "AND NVK.D_E_L_E_T_=' ' "
cQuery += "AND NVK.NVK_CGRUP IN ( "
//Grupos que esse usuario esta cadastrado
cQuery += "SELECT NZX.NZX_COD FROM " + RetSqlName("NZX") + " NZX "
cQuery += "INNER JOIN " + RetSqlName("NZY") + " NZY "
cQuery += "ON(NZY.NZY_CUSER = '"+ cUsuario + "')"
cQuery += "AND NZY.NZY_CGRUP = NZX.NZX_COD "
cQuery += "AND NZY.D_E_L_E_T_ = ' ' "
cQuery += "AND NZY.NZY_FILIAL = '" + xFilial("NZY") + "' "

cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J163RstCli()
Gera a query da aba de restri��o de clientes
Uso Geral.

@Return cQuery da aba de restri��o de clientes

@author Wellington Coelho
@since 16/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163RstCli()
Local cQuery := ""

cQuery := "SELECT NWO.NWO_CCLIEN, NWO.NWO_CLOJA, SA1.A1_NOME "
cQuery += " FROM " + RetSqlName("NWO") + " NWO "
cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
cQuery += "  ON ( NWO.NWO_CCLIEN = SA1.A1_COD "
cQuery += "  AND NWO.NWO_CLOJA = SA1.A1_LOJA "
cQuery += "  AND SA1.D_E_L_E_T_ = '' "
cQuery += "  AND SA1.A1_FILIAL = '"+xFilial("SA1")+"') "

cQuery += " WHERE NWO.D_E_L_E_T_ = ' '"
cQuery +=   " AND NWO.NWO_FILIAL = '"+xFilial("NWO")+"' "
cQuery +=   " AND NWO.NWO_CCONF = '@#NVK_COD#@' "
cQuery += " ORDER BY NWO.NWO_CCLIEN "

cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J163RstGru()
Gera a query da aba de restri��o de grupos de clientes
Uso Geral.

@Return cQuery da aba de restri��o de grupos de clientes

@author Wellington Coelho
@since 17/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163RstGru()
Local cQuery := ""

cQuery := "SELECT NY2.NY2_CGRUP, ACY_DESCRI "
cQuery += " FROM " + RetSqlName("NY2") + " NY2 "
cQuery += " INNER JOIN " + RetSqlName("ACY") + " ACY "
cQuery += "  ON ( NY2_CGRUP = ACY.ACY_GRPVEN "
cQuery += "  AND ACY.D_E_L_E_T_ = '' "
cQuery += "  AND ACY.ACY_FILIAL = '"+xFilial("ACY")+"') "

cQuery += " WHERE NY2.D_E_L_E_T_ = ' '"
cQuery +=   " AND NY2.NY2_FILIAL = '"+xFilial("NY2")+"' "
cQuery +=   " AND NY2.NY2_CCONF = '@#NVK_COD#@' "
cQuery += " ORDER BY NY2.NY2_CGRUP "

cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J163RstRot()
Gera a query da aba de restri��o de rotinas
Uso Geral.

@Return cQuery da aba de restri��o de rotinas

@author Wellington Coelho
@since 17/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163RstRot()
Local cQuery := ""

cQuery := "SELECT NWP.NWP_CROT, NWP.NWP_CVISU, NWP.NWP_CALTER, "
cQuery += " NWP.NWP_CINCLU, NWP.NWP_CEXCLU, X5_DESCRI "
cQuery += " FROM " + RetSqlName("NWP") + " NWP "
cQuery += " INNER JOIN " + RetSqlName("SX5") + " SX5 "
cQuery += "  ON ( NWP.NWP_CROT = X5_CHAVE "
cQuery += "  AND SX5.X5_TABELA = 'JX' "
cQuery += "  AND SX5.D_E_L_E_T_ = '' "
cQuery += "  AND SX5.X5_FILIAL = '"+xFilial("SX5")+"') "

cQuery += " WHERE NWP.D_E_L_E_T_ = ' '"
cQuery +=   " AND NWP.NWP_FILIAL = '"+xFilial("NWP")+"' "
cQuery +=   " AND NWP.NWP_CCONF = '@#NVK_COD#@' "
cQuery += " ORDER BY NWP.NWP_CROT "

cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J163RstEsc()
Gera a query da aba de restri��o de escrit�rio
Uso Geral.

@Return cQuery da aba de restri��o de escrit�rio

@author Wellington Coelho
@since 17/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163RstEsc()
Local cQuery := ""

cQuery := "SELECT NYK.NYK_CESCR, NS7.NS7_NOME "
cQuery += " FROM " + RetSqlName("NYK") + " NYK "
cQuery += " INNER JOIN " + RetSqlName("NS7") + " NS7 "
cQuery += "  ON ( NYK.NYK_CESCR = NS7.NS7_COD "
cQuery += "  AND NS7.D_E_L_E_T_ = '' "
cQuery += "  AND NS7.NS7_FILIAL = '"+xFilial("NS7")+"') "

cQuery += " WHERE NYK.D_E_L_E_T_ = ' '"
cQuery +=   " AND NYK.NYK_FILIAL = '"+xFilial("NYK")+"' "
cQuery +=   " AND NYK.NYK_CCONF = '@#NVK_COD#@' "
cQuery += " ORDER BY NYK.NYK_CESCR "

cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J163RstArea()
Gera a query da aba de restri��o de �rea
Uso Geral.

@Return cQuery da aba de restri��o de �rea

@author Wellington Coelho
@since 17/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163RstArea()
Local cQuery := ""

cQuery := "SELECT NYL.NYL_CAREA, NRB.NRB_DESC "
cQuery += " FROM " + RetSqlName("NYL") + " NYL "
cQuery += " INNER JOIN " + RetSqlName("NRB") + " NRB "
cQuery += "  ON ( NYL.NYL_CAREA = NRB.NRB_COD "
cQuery += "  AND NRB.D_E_L_E_T_ = '' "
cQuery += "  AND NRB.NRB_FILIAL = '"+xFilial("NRB")+"') "

cQuery += " WHERE NYL.D_E_L_E_T_ = ' '"
cQuery +=   " AND NYL.NYL_FILIAL = '"+xFilial("NYL")+"' "
cQuery +=   " AND NYL.NYL_CCONF = '@#NVK_COD#@' "
cQuery += " ORDER BY NYL.NYL_CAREA "


Return cQuery
//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio(aRelat,aCabec,aSessao)
Executa a query principal e inicia a impress�o do relat�rio.
Ferramenta TMSPrinter
Uso Geral.

@param aRelat  Dados do t�tulo do relat�rio
@param aCabec  Dados do cabe�alho do relat�rio
@param aSessao Dados do conte�do do relat�rio
@param lAutomato - Indica se � execu��o de automa��o
@param aAutoUsr  - Indica os usu�rios que ser�o considerados no relat�rio (automa��o)
@param cNomeArq  - Indica o nome do arquivo que ser� gravado (automa��o)

@Return nil

@author Wellington Coelho
@since 15/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat,aCabec,aSessao, lAutomato, aAutoUsr, cNomeArq)

Local cNomeRel  := ""
Local lHori     := .F.
Local lQuebPag  := .F.
Local lTitulo   := .T.
Local lLinTit   := .F.
Local lValor    := .F.
Local nI        := 0    // Contador
Local nJ        := 0    // Contador
Local nLin      := 0    // Linha Corrente
Local nLinCalc  := 0    // Contator de linhas - usada para os c�lculos de novas linhas
Local nLinCalc2 := 0
Local nLinFinal := 0
Local nConta    := 0
Local oPrint    := Nil
Local aDados    := {}
Local cQuerySub := ""
Local aUsuarios := ""
Local cTxt      := ""
Local cVar      := "" // CAMPO
Local xValor    // Valor do campo
Local TMP
Local nContUsu  := 0    // Contador
Local lFindFunc := FINDFUNCTION( 'FWSFALLUSERS' )
Local aAux      := {}

Default lAutomato := .F.
Default aAutoUsr  := {}
Default cNomeRel  := ""

cNomeRel := IIF( VALTYPE(cNomeArq) <> "U" .AND. !Empty(cNomeArq), cNomeArq, aRelat[1]) //Nome do Relat�rio

If !lAutomato
	oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,, .T.,,, "PDF" ) // Inicia o relat�rio
Else
	oPrint := FWMsPrinter():New( cNomeRel, IMP_SPOOL,,, .T.,,,) // Inicia o relat�rio
	oPrint:CFILENAME  := cNomeRel
	oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
EndIf

If lAutomato
	aUsuarios := aClone({ aAutoUsr })
Else 
	If lFindFunc
		aUsuarios := FWSFALLUSERS()
	Else
		aUsuarios := AllUsers()
	EndIf
EndIf

If Len (aUsuarios) > 0

	If lFindFunc
		ASORT(aUsuarios, , , { | x,y | x[4] < y[4] } )//Ordena array de usu�rios por nome
	Else
		ASORT(aUsuarios, , , { | x,y | x[1][2] < y[1][2] } )//Ordena array de usu�rios por nome
	EndIf

	For nContUsu := 1 To Len(aUsuarios)

		If lFindFunc
			aAux   := aClone( aUsuarios[nContUsu] )
			cQuery := J163QrPrin(aAux[2])
		Else
			aAux   := aClone( aUsuarios[nContUsu][1] )
			cQuery := J163QrPrin(aAux[1])
		EndIf

		nLinCalc := nLin // Inicia o controle das linhas impressas
		lTitulo := .T. // Indica que o t�tulo pode ser impresso
		lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
		nConta := 0

		TMP    := GetNextAlias()

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),TMP,.T.,.T.)

		If (TMP)->(!EOF())

			nConta := 0

			If nLin == 0//Verifica se � inicio de pagina
				ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Imprime cabe�alho
				nLinCalc := nLin // Inicia o controle das linhas impressas
			EndIf

			While (TMP)->(!EOF())

				For nI := 1 To Len(aSessao) // Inicia a impress�o de cada sess�o do relat�rio

					lValor := .F.
					lHori  := aSessao[nI][4]

					If nLin + nSalto >= nFimL // Verifica se a linha corrente � maior que linha final permitida por p�gina
						oPrint:EndPage() // Se for maior, encerra a p�gina atual
						ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
						nConta := 0
						nLinCalc := nLin // Inicia o controle das linhas impressas
						lTitulo := .T. // Indica que o t�tulo pode ser impresso
						lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada

						JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI], 1, aAux) //Imprime o t�tulo da sess�o no relat�rio
					EndIf

					If !Empty(aSessao[nI][5]) // Nessa posi��o � indicada a query de um subreport

						cQuerySub := aSessao[nI][5]

						cTxt := cQuerySub
						cVar    := "" // CAMPO

						While RAT("#@", cTxt) > 0 // Substitui os nomes dos campos passados na query por seus respectivos valores
							cVar     := SUBSTR(cTxt,AT("@#", cTxt) + 2,AT("#@", cTxt) - (AT("@#", cTxt) + 2))
							xValor   := (TMP)->(FieldGet(FieldPos(cVar)))
							cTxt     := SUBSTR(cTxt, 1,AT("@#", cTxt)-1) + ALLTRIM(xValor) + SUBSTR(cTxt, AT("#@", cTxt)+2)
						End

						cQuerySub := cTxt

						nConta := 0

						JImpSub(cQuerySub, aSessao[nI],@nLinCalc,@lQuebPag, aRelat, aCabec, @oPrint, @nLin, @lTitulo, @lLinTit, @nConta, aUsuarios, nContUsu)	// Imprime os dados do subreport

					Else

						nLinCalc2 := nLinCalc // Backup da pr�xima linha a ser usada, pois na fun��o JDadosCpo abaixo a variavel tem seu conte�do alterado para
			                      // que seja realizada uma simula��o das linhas usadas para impress�o do conte�do.

						nLinFinal := 0 // Limpa a vari�vel

						For nJ := 6 to Len(aSessao[nI]) // L� as informa��es de cada campo a ser impresso. O contador come�a em 6 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
							cTabela  := aSessao[nI][nJ][2] //Tabela
							cCpoTab  := aSessao[nI][nJ][3] //Nome do campo na tabela
							cCpoQry  := aSessao[nI][nJ][4] //Nome do campo na query
							cTipo    := aSessao[nI][nJ][5] //Tipo do campo
							cValor := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,,.F.,aAux) // Retorna o conte�do/valor a ser impresso. Chama essa fun��o para tratar o valor caso seja um memo ou data

							If !lValor .And. !Empty(AllTrim(cValor))//verifica se existe valor a ser exibido. Caso tenha imprime o titulo
								lValor := .T.
							EndIf

							aAdd(aDados,JDadosCpo(aSessao[nI][nJ],cValor,@nLinCalc,@lQuebPag)) // T�tulo e conte�do de cada campo s�o inseridos do array com os dados para serem impressos abaixo
						Next nJ

						nLinCalc := nLinCalc2 // Retorno do valor original da vari�vel

						If lValor .And. nConta == 0 // Se existir valor a ser impresso na sess�o imprime o t�tulo da sess�o.
							JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI], 1, aAux) //Imprime o t�tulo da sess�o no relat�rio
						EndIf

						If lQuebPag // Verifica se � necess�rio ocorrer a quebra de pagina
							oPrint:EndPage() // Se � necess�rio, encerra a p�gina atual
							ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
							nConta := 0
							nLinCalc := nLin // Inicia o controle das linhas impressas
							lQuebPag := .F. // Limpa a vari�vel de quebra de p�gina
							lTitulo  := .T. // Indica que o t�tulo pode ser impresso
							lLinTit  := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
							If lValor .And. nConta == 0 // Se existir valor a ser impresso na sess�o imprime o t�tulo da sess�o.
								JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI], 1, aAux) //Imprime o t�tulo da sess�o no relat�rio
							EndIf
						EndIf

					//Imprime os campos do relat�rio
						JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, lTitulo, lLinTit, aRelat,aCabec)

					//Limpa array de dados
						aSize(aDados,0)
						aDados := {}

						nLinCalc := nLinFinal //Indica a maior ref�ncia de uso de linhas para que sirva como refer�ncia para come�ar a impress�o do pr�ximo registro
						nLinFinal := 0 // Limpa a vari�vel
						nLin := nLinCalc+nSalto //Recalcula a linha de refer�ncia para impress�o
						nLinCalc := nLin //Indica a linha de refer�ncia para impress�o

					EndIf

				Next nI

				oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
				oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio

				nLin += nSalto //Adiciona uma linha em branco ap�s a linha impressa
				nLinCalc := nLin

				(TMP)->(DbSkip())

				nConta := 1
				lTitulo := .T.
				lLinTit := .F.
			Enddo

		EndIf

		(TMP)->(dbCloseArea())

	Next nContUsu

	aSize(aDados,0)  //Limpa array de dados
	aSize(aSessao,0) //Limpa array de dados das sess�es do relat�rio
	oPrint:EndPage() // Finaliza a p�gina

	If !lAutomato
		oPrint:CFILENAME  := cNomeRel + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') + '.rel'
		oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
	EndIf
	
	oPrint:Print()

	If !lAutomato
		FErase(oPrint:CFILEPRINT)
	EndIf

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
Local nSaltoCabe := 10
Local nI         := 0
Local oFontValor
Local oFontRoda  := TFont():New("Arial",,-8,,.F.,,,,.T.,.F.) // Fonte usada no Rodap�

oPrint:SetLandscape()

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )
nLin := 150

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )
nLin += 2*nSaltoCabe // Espa�o para que o cabe�alho fique um pouco abaixo do T�tulo do Relat�rio

If Len(aCabec) > 0
	If !EMPTY(aCabec[1][1])
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
EndIf

nLin+=20
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
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub,aUsuarios)
Local cValor := ""
Local cPicture := GetSx3Cache(cCpoTab,"X3_PICTURE")
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
	ElseIf cTipo == "N"
		TcSetField(TMP, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		If lPicture
			cValor   := TRANSFORM((TMP)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conte�do a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((TMP)->&(cCpoQry)))
		EndIf
	ElseIf cTipo == "O" // Lista de op��es
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((TMP)->&(cCpoQry))) ) //Retorna o valor do campo
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
@param TMP         Alias aberto da query principal
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
Static Function JImpSub(cQuerySub, aSessao, nLinCalc, lQuebPag ,aRelat , aCabec, oPrint, nLin, lTitulo, lLinTit, nConta, aUsuarios, nContUsu)
Local nJ        := 0
Local cValor    := ""
Local aDados    := {}
Local SUB       := GetNextAlias()
Local lHori     := aSessao[4]
Local cTxt      := cQuerySub
Local lValor    := .F.
Local lFindFunc := FINDFUNCTION( 'FWSFALLUSERS' )
Local aAux      := {}

cQuerySub := cTxt

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySub),SUB,.T.,.T.)

While (SUB)->(!EOF())
	If lFindFunc
		aAux := aClone( aUsuarios[nContUsu] )
	Else
		aAux := aClone( aUsuarios[nContUsu][1] )
	EndIf


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

		If !lValor .And. !Empty(AllTrim(cValor))
			lValor := .T.
		EndIf

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

		JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao, 1, aAux) //Imprime o t�tulo da sess�o no relat�rio
	EndIf

	If lTitulo .And. !Empty(aSessao[1])
		If (nLin + 120) >= nFimL // Verifica se o t�tulo da sess�o cabe na p�gina
			oPrint:EndPage() // Se for maior, encerra a p�gina atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o t�tulo pode ser impresso
			lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada

			JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao, 1, aAux) //Imprime o t�tulo da sess�o no relat�rio
		EndIf

	EndIf

	If lValor .And. nConta == 0 // Se existir valor a ser impresso na sess�o imprime o t�tulo da sess�o.
		JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao, 0) //Imprime o t�tulo da sess�o no relat�rio
	EndIf

	If !lHori // Caso a impress�o dos t�tulos seja na vertical - Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Relat�rio de andamentos)
		// Os t�tulos devem ser impressos
		lTitulo := .T. // Indica que o t�tulo pode ser impresso
		lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
	EndIf

	If nConta > 0 // Sess�es que s�o na vertical e aparecem o t�tulo somente no topo uma �nica vez, e n�o registro a registro
		lTitulo := .F.
		lLinTit := .T.
	EndIf

	//Imprime os campos do relat�rio
	JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, lTitulo, lLinTit, aRelat,aCabec)
	//Limpa array de dados
	aSize(aDados,0)
	aDados := {}

	nLinCalc := nLinFinal //Indica a maior ref�ncia de uso de linhas para que sirva como refer�ncia para come�ar a impress�o do pr�ximo registro

	nLinFinal := 0 // Limpa a vari�vel

	nLin := nLinCalc

	(SUB)->(DbSkip())

	nConta  := 1

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
Static Function JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta)
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

	If lQuebLin // Indica que � necess�ria quebra de linha, ou seja, o pr�ximo campo ser� impresso na pr�xima linha
		If nLinFinal >= nLin // Se a pr�xima linha a ser impressa (nLin) for menor que a �ltima linha que tem conte�do impresso (nLinFinal)
			nLin     := nLinFinal // Deve-se indicar a maior refer�ncia
		Else
			nLin     += nSalto // Caso contr�rio, pule uma linha.
			EndIf
			nLinTit  := nLin // Recebe a pr�xima linha dispon�vel para impress�o do t�tulo
			nLinCalc := nLin // Atualiza vari�vel de c�lculo de linhas
			lLinTit  := .F.  // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
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
	JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, lTitulo, lLinTit, aRelat,aCabec, @lSalta)
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
				If Len(aCampForm) == nX
					oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor sem a palavra que ocasionou a quebra.
					nLinAtu += nSalto // Pula para a pr�xima linha
				EndIf
			EndIf
		EndIf
	Next nX
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
Static Function JImpTitSes(oPrint, nLin, nLinCalc, aSessao, nTipo, aUsuarios)

Local lFindFunc := FINDFUNCTION( 'FWSFALLUSERS' )

Default nTipo := 0

If nTipo == 0
	//aSessao[1] - T�tulo da sess�o do relat�rio
	//aSessao[2] - Posi��o da descri��o
	//aSessao[3] - Fonte da sess�o

	oPrint:Say( nLin+15, aSessao[2], aSessao[1], aSessao[3])

	nLin+=80
	nLinCalc := nLin

Else
	oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
	oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
	oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
	oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)

	//aSessao[1] - T�tulo da sess�o do relat�rio
	//aSessao[2] - Posi��o da descri��o
	//aSessao[3] - Fonte da sess�o

	If lFindFunc
		oPrint:Say( nLin+15, aSessao[2], aUsuarios[2] + "  -  " +aUsuarios[4], aSessao[3])
	Else
		oPrint:Say( nLin+15, aSessao[2], aUsuarios[1] + "  -  " +aUsuarios[2], aSessao[3])
	EndIf

	nLin+=70
	nLinCalc := nLin
EndIf

Return
