#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "JURR106P.CH"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   3000 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     2350 // Linha Final da p�gina de um relat�rio
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR106(cUser, cThread, cNomeTar, cCaminho, lAutomato, aFilAtiv, cDataIni, cDataFim, cTipos, cStatus, cResp)
Regras do relat�rio de Follow-ups

@param cUser Usuario
@param cThread Se��o
@param cNomeTar Nome enviado quando chamado pelo TOTVS LEGAL
@param cCaminho Caminho do arquivo quando chamado pelo TOTVS LEGAL  
@param lAutomato - Indica se � execu��o de automa��o
@param aFilAtiv  - Filtros do painel de atividades (Favoritos / Processos que cuido)
@param cDataIni  - Data inicio
@param cDataFim  - Data Fim
@param cTipos    - Tipos de follow-up
@param cStatus   - Status de follow-up
@param cResp     - Respons�veis do follow-up

@author Wellington Coelho
@since 19/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JURR106P(cUser, cThread, cNomeTar, cCaminho, lAutomato, aFilAtiv, cDataIni, cDataFim, cTipos, cStatus, cResp)
Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) // Fonte usada no nome do relat�rio
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos do relat�rio (T�tulo de campos e t�tulos no cabe�alho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos das sess�es
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}

Default cNomeTar  := ""
Default cCaminho  := ""
Default lAutomato := .F.

//T�tulo do Relat�rio
  // 1 - T�tulo,
  // 2 - Posi��o da descri��o,
  // 3 - Fonte do t�tulo
aRelat := {STR0001,65,oFont} //"Pauta de Compromissos"

//Cabe�alho do Relat�rio
  // 1 - T�tulo, 
  // 2 - Conte�do, 
  // 3 - Posi��o de in�cio da descri��o(considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. 
  //     Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. 
  //     Para isso considere sempre a posi��o da maior descri��o),
  // 4 - Fonte do t�tulo, 
  // 5 - Fonte da descri��o
//aCabec := {{"Data Compromisso: "   ,DToC(Date()) ,(nTamCarac*16),oFontTit,oFontDesc}}//,;
aCabec := {{""   ,"" ,(nTamCarac*16),oFontTit,oFontDesc}}//,;

//Campos do Relat�rio
  //Exemplo da primeira parte -> aAdd(aSessao, {"Relat�rio de Follow-ups",65,oFontSub,.F.,;// 
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
aAdd(aSessao, {STR0002 /*"Data Compromisso: "*/,65,oFontSub,.F.,,;
              {STR0003 /*"Data"*/               ,"NTA","NTA_DTFLWP","NTA_DTFLWP"  ,"D",65  ,500 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0004 /*"Hor�rio"*/            ,"NTA","NTA_HORA"  ,"NTA_HORA"    ,"C",300 ,500 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0005 /*"Respons�vel"*/        ,"RD0","RD0_NOME"  ,"J106QrResp()","C",500 ,680 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0006 /*"Tipo"*/               ,"NQS","NQS_DESC"  ,"NQS_DESC"    ,"C",1000,500 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0007 /*"Status"*/             ,"NQN","NQN_DESC"  ,"NQN_DESC"    ,"C",1400,500 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0008 /*"Cliente"*/            ,"SA1","A1_NREDUZ" ,"A1_NREDUZ"   ,"C",1800,500 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0009 /*"Caso"*/               ,"NVE","NVE_TITULO","NVE_TITULO"  ,"C",2200,1300,oFontTit,oFontDesc,(nTamCarac),.T.},;
              {STR0010 /*"Descri��o"*/          ,"NTA","NTA_DESC"  ,"RECNONTA"    ,"M",65  ,5000,oFontTit,oFontDesc,(nTamCarac),.T.}})

aAdd(aSessao, {"",65,oFontSub,.F.,J106QryIns(),;// T�tulo da sess�o do relat�rio
              {STR0011 /*"N�mero do Processo"*/ ,"NUQ","NUQ_NUMPRO","NUQ_NUMPRO"  ,"C",65  ,600 ,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0012 /*"Comarca"*/            ,"NQ6","NQ6_DESC"  ,"NQ6_DESC"    ,"C",500 ,1000,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0013 /*"Foro / Tribunal"*/    ,"NQC","NQC_DESC"  ,"NQC_DESC"    ,"C",1100,1000,oFontTit,oFontDesc,(nTamCarac),.F.},;
              {STR0014 /*"Vara / C�mara"*/      ,"NQE","NQE_DESC","NQE_DESC"      ,"C",1700,1000,oFontTit,oFontDesc,(nTamCarac),.T.},;
              {STR0015 /*"Observa��es"*/        ,"NUQ","NUQ_OBSERV","RECNONUQ"    ,"M",65  ,5000,oFontTit,oFontDesc,(nTamCarac),.F.}})

aAdd(aSessao, {"",65,oFontSub,.T.,,;// T�tulo da sess�o do relat�rio
              {STR0016 /*"Envolvidos"*/         ,"NT9","NT9_NOME","J106QryEnv()"  ,"C",65  ,4400,oFontTit,oFontDesc,(nTamCarac*10),.T.}})

JRelatorio(aRelat,aCabec,aSessao,J106QrPrin(cUser, cThread, aFilAtiv, cDataIni, cDataFim, cTipos, cStatus, cResp), cNomeTar, cCaminho, lAutomato) //Chamada da fun��o de impress�o do relat�rio em TMSPrinter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J106QrPrin(cUser, cThread, aFilAtiv, cDataIni, cDataFim, cTipos, cStatus, cResp)
Gera a query principal do relat�rio
 
Uso Geral.

@param cUser    - Usuario
@param cThread  - Se��o
@param aFilAtiv - Filtros do painel de atividades (Favoritos / Processos que cuido)
@param cDataIni  - Data inicio
@param cDataFim  - Data Fim
@param cTipos    - Tipos de follow-up
@param cStatus   - Status de follow-up
@param cResp     - Respons�veis do follow-u

@Return cQuery Query principal do relat�rio

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J106QrPrin(cUser, cThread, aFilAtiv, cDataIni, cDataFim, cTipos, cStatus, cResp)
Local cQuery  := ""
Local cWhere    := ""
Local cQryAux   := ""
Local nI        := 0

Default aFilAtiv := {}
Default cDataIni := ""
Default cDataFim := ""
Default cTipos   := ""
Default cStatus  := ""
Default cResp    := ""

	// Filtros do painel de atividades
	If Len(aFilAtiv) > 0 .OR. !Empty(cResp)
		cQryAux := ''
		If !Empty(cResp)
			cQryAux += " EXISTS (SELECT 1 FROM " + RetSqlName('NTE') + " NTE1 WHERE NTE1.D_E_L_E_T_ = ' ' "
			cQryAux += " AND NTA001.NTA_COD = NTE1.NTE_CFLWP AND NTE1.NTE_CPART IN " + FormatIn(cResp,',') + " ) "
		Endif

		For nI := 1 To Len(aFilAtiv)
			cQryAux += IIF( !Empty(cQryAux), " OR ", "" ) + WsJurCWhrAtv(aFilAtiv[nI])
		Next nI
		cQryAux := StrTran(cQryAux,'NTA.','NTA001.')

		cWhere += " AND ( " + cQryAux + " ) "
	EndIf

	cQuery := " SELECT SA1.A1_NREDUZ, NTA001.NTA_HORA, NQS.NQS_DESC, NTA001.NTA_DTFLWP, NQN.NQN_DESC, "
	cQuery += " NTA001.NTA_COD, NTA001.NTA_FILIAL, NTA001.NTA_CAJURI, NVE.NVE_TITULO, NTA001.R_E_C_N_O_ RECNONTA  "

	cQuery += " FROM " + RetSqlName("NTA") + " NTA001 "

	cQuery += "  INNER JOIN "  + RetSqlName("NWG") + " NWG "
	cQuery += "   ON ( NTA001.D_E_L_E_T_ = NWG.D_E_L_E_T_ ) "
	cQuery += "   AND ( NTA001.NTA_FILIAL = NWG.NWG_FILORI ) "
	cQuery += "   AND ( NTA001.NTA_CAJURI = NWG.NWG_CAJURI )"
	cQuery += "   AND ( NTA001.NTA_COD = NWG.NWG_CODFOL )"

	cQuery += "  INNER JOIN "  + RetSqlName("NSZ") + " NSZ "
	cQuery += "   ON ( NTA001.D_E_L_E_T_ = NSZ.D_E_L_E_T_ ) "
	cQuery += "   AND ( NTA001.NTA_FILIAL = NSZ.NSZ_FILIAL ) "
	cQuery += "   AND ( NTA001.NTA_CAJURI = NSZ.NSZ_COD )"

	cQuery += "  INNER JOIN " + RetSqlName("NQS") + " NQS "
	cQuery += "   ON ( NTA001.D_E_L_E_T_ = NQS.D_E_L_E_T_ ) "
	cQuery += "   AND ( NQS.NQS_FILIAL = '" + xFilial("NQS") + "') "
	cQuery += "   AND ( NTA001.NTA_CTIPO = NQS.NQS_COD ) "

	cQuery += "  INNER JOIN " + RetSqlName("NQN") + " NQN"
	cQuery += "   ON ( NTA001.D_E_L_E_T_ = NQN.D_E_L_E_T_ ) "
	cQuery += "   AND ( NQN.NQN_FILIAL = '" + xFilial("NQN") + "') "
	cQuery += "   AND ( NTA001.NTA_CRESUL = NQN.NQN_COD ) "

	cQuery += "  LEFT JOIN " + RetSqlName("SA1") + " SA1 " 
	cQuery += "   ON ( NSZ.D_E_L_E_T_ = SA1.D_E_L_E_T_ ) "
	cQuery += "   AND (SA1.A1_FILIAL = '" + xFilial("SA1") + "') "
	cQuery += "   AND ( NSZ.NSZ_CCLIEN = SA1.A1_COD ) "
	cQuery += "   AND ( NSZ.NSZ_LCLIEN = SA1.A1_LOJA )  "

	cQuery += "  INNER JOIN " + RetSqlName("NVE") + " NVE "
	cQuery += "   ON ( NSZ.D_E_L_E_T_ = NVE.D_E_L_E_T_ ) "
	cQuery += "   AND ( NSZ.NSZ_CCLIEN = NVE.NVE_CCLIEN ) "
	cQuery += "   AND ( NSZ.NSZ_LCLIEN = NVE.NVE_LCLIEN ) "
	cQuery += "   AND ( NSZ.NSZ_NUMCAS = NVE.NVE_NUMCAS ) "

	If !Empty(cStatus)
		cQuery += " LEFT  JOIN " + RetSqlName('NQN') + " NQN001 "
		cQuery +=      " ON ( NQN001.NQN_FILIAL = '" + xFilial("NQN") + "' "
		cQuery +=        " AND NQN001.NQN_COD = NTA001.NTA_CRESUL AND NQN001.D_E_L_E_T_ = ' ' ) "
	EndIf

	If JCompTable("NVE") == 'EEE'
		cQuery += " AND ( NVE.NVE_FILIAL = NSZ.NSZ_FILIAL ) "
	Else
		cQuery += " AND ( NVE.NVE_FILIAL = '" + xFilial("NVE") + "' ) "
	EndIf

	cQuery += " WHERE NWG_CUSER = '" +cUser+ "'"
	cQuery += "   AND NWG_SECAO = '" +cThread+ "'"
	cQuery += "   AND NTA001.D_E_L_E_T_ = ' ' "

	If !Empty(cDataIni)
		cQuery += " AND NTA001.NTA_DTFLWP >= '" + StrTran(cDataIni,"-","") + "' "
	EndIf

	If !Empty(cDataFim)
		cQuery += " AND NTA001.NTA_DTFLWP <= '" + StrTran(cDataFim,"-","") + "' "
	EndIf

	If !Empty(cTipos)
		cQuery += " AND NTA001.NTA_CTIPO IN " + formatIn(AllTrim( cTipos ),',') + "  "
	EndIf

	If !Empty(cStatus)
		If Len(cStatus) == 1
			cQuery += " AND NQN.NQN_TIPO IN " + formatIn(AllTrim(cStatus),',') + " "
		Else
			cQuery += " AND NQN.NQN_COD IN " + formatIn(AllTrim(cStatus),',') + " "
		EndIf
	EndIf

	cQuery += cWhere

	cQuery += " ORDER BY NTA001.NTA_DTFLWP, NTA001.NTA_HORA "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J106QryIns(cCajuri)
Gera a query do sub relat�rio de Instancias
 
Uso Geral.

@param cCajuri Codigo do assunto juridico posicionado

@Return cQueryIns Query do sub relat�rio de Instancias

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J106QryIns(cCajuri)
Local cQueryIns := ""

cQueryIns := " SELECT NUQ.NUQ_INSATU, NUQ.NUQ_NUMPRO, NUQ.NUQ_CAJURI, "
cQueryIns += "  NUQ.D_E_L_E_T_, NUQ.NUQ_FILIAL, NUQ.NUQ_INSTAN, "
cQueryIns += "  NQ6.NQ6_DESC, NQE.NQE_DESC, NQC.NQC_DESC, NUQ.R_E_C_N_O_ RECNONUQ  " 
cQueryIns += " FROM " + RetSqlName("NUQ") + " NUQ "
cQueryIns += "  LEFT OUTER JOIN " + RetSqlName("NQ6") + " NQ6 " 
cQueryIns += "   ON (NUQ.NUQ_CCOMAR = NQ6.NQ6_COD ) " 
cQueryIns += "   AND (NUQ.D_E_L_E_T_ = NQ6.D_E_L_E_T_ ) "
cQueryIns += "  LEFT OUTER JOIN " + RetSqlName("NQC") + " NQC " 
cQueryIns += "   ON ( NUQ.NUQ_CLOC2N = NQC.NQC_COD ) "
cQueryIns += "   AND (NUQ.D_E_L_E_T_ = NQC.D_E_L_E_T_ ) "
cQueryIns += "  LEFT OUTER JOIN " + RetSqlName("NQE") + " NQE "
cQueryIns += "   ON ( NUQ.NUQ_CLOC3N = NQE.NQE_COD ) "
cQueryIns += "   AND ( NUQ.D_E_L_E_T_ = NQE.D_E_L_E_T_ ) "
cQueryIns += " WHERE NUQ.NUQ_INSATU = '1'"
cQueryIns += "   AND NUQ.NUQ_CAJURI =  '@#NTA_CAJURI#@'"  
cQueryIns += "   AND NUQ.NUQ_FILIAL = '@#NTA_FILIAL#@' "

Return cQueryIns

//-------------------------------------------------------------------
/*/{Protheus.doc} J106QrResp(cCodFollow, cFilFUP)
Gera a query do sub relat�rio de Responsaveis
 
Uso Geral.

@param cCodFollow Codigo do Follow-up
@param cFilFUP    Filial do Follow-up

@Return cQueryResp query do sub relat�rio de Responsaveis

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J106QrResp(cCodFollow, cFilFUP)
Local cQueryResp := ""
Local cAliasResp := GetNextAlias()
Local cResp      := ""

Default cFilFUP := xFilial('NTE')

	cQueryResp := " SELECT RD0.RD0_NOME, NTE.NTE_CFLWP, NTE.NTE_FILIAL "
	cQueryResp += "   FROM " + RetSqlName("NTE") + " NTE "
	cQueryResp += "  INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQueryResp += "     ON RD0.D_E_L_E_T_ = NTE.D_E_L_E_T_ "
	cQueryResp += "    AND RD0.RD0_CODIGO = NTE.NTE_CPART "
	cQueryResp += "    AND RD0.RD0_FILIAL = '" + xFilial("RD0") + "'"
	cQueryResp += "  WHERE NTE.NTE_CFLWP = '" + cCodFollow + "'"
	cQueryResp += "    AND NTE.NTE_FILIAL = '" + cFilFUP + "'"
	cQueryResp += "    AND NTE.D_E_L_E_T_ = ' '"

	cQueryResp := ChangeQuery(cQueryResp)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryResp),cAliasResp,.T.,.T.)

	While (cAliasResp)->(!EOF())
		If EMPTY(cResp)
			cResp := Alltrim((cAliasResp)->RD0_NOME)
		Else
			cResp += " / " + Alltrim((cAliasResp)->RD0_NOME)
		EndIf
		(cAliasResp)->(DbSkip())
	End

	(cAliasResp)->(dbCloseArea())

Return cResp

//-------------------------------------------------------------------
/*/{Protheus.doc} J106QryEnv(cCajuri, cFilPro)
Gera a query do sub relat�rio de Envolvidos
Uso Geral.

@param cCajuri Codigo do assunto juridico posicionado
@param cFilPro Filial do assunto juridico posicionado

@Return cQueryEnv Query do sub relat�rio de envolvidos

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J106QryEnv(cCajuri, cFilPro)
Local cQueryEnv := ""
Local ENV       := GetNextAlias()
Local cEnv      := ""

	cQueryEnv := " SELECT NT9.NT9_NOME "
	cQueryEnv += "  FROM " + RetSqlName("NT9") + " NT9 "
	cQueryEnv += " WHERE  NT9.NT9_CAJURI = '" + cCajuri + "' "
	cQueryEnv += "  AND NT9.D_E_L_E_T_ = ' ' AND NT9.NT9_FILIAL = '" + cFilPro + "'"

	cQueryEnv := ChangeQuery(cQueryEnv)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryEnv),ENV,.T.,.T.)

	While (ENV)->(!EOF())
		
		If EMPTY(cEnv)
			cEnv := Alltrim((ENV)->NT9_NOME)
		Else
			cEnv += " / " + Alltrim((ENV)->NT9_NOME)
		EndIf
		(ENV)->(DbSkip())
	End

	(ENV)->(dbCloseArea())

Return cEnv
//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio(aRelat, aCabec, aSessao, cQuery, cNomeTar, cCaminho)
Executa a query principal e inicia a impress�o do relat�rio.
Ferramenta TMSPrinter
Uso Geral.

@param aRelat   Dados do t�tulo do relat�rio
@param aCabec   Dados do cabe�alho do relat�rio
@param aSessao  Dados do conte�do do relat�rio
@param cQuery   Query que ser� executada
@param cNomeTar Nome do arquivo enviado pelo TOTVS LEGAL
@param cCaminho Caminho do arquivo quando chamado pelo TOTVS LEGAL
@param lAutomato - Indica se � execu��o de automa��o

@Return nil

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat, aCabec, aSessao, cQuery, cNomeTar, cCaminho, lAutomato)

Local cNomeRel  := ""
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
Local cData     := ""
Local TMP       := GetNextAlias()

cNomeRel := IIF( !Empty(cNomeTar) .AND. lAutomato, cNomeTar, aRelat[1] ) //Nome do Relat�rio

If !lAutomato
	oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,, .T.,,, "PDF", .T. ) // Inicia o relat�rio
Else
	oPrint := FWMsPrinter():New( cNomeRel, IMP_SPOOL,,, .T.,,,) // Inicia o relat�rio
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

					If cCpoQry == "J106QrResp()"
						cValor := J106QrResp((TMP)->NTA_COD, (TMP)->NTA_FILIAL)
					ElseIf cCpoQry == "J106QryEnv()"
						cValor := J106QryEnv((TMP)->NTA_CAJURI, (TMP)->NTA_FILIAL)
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

				If lTitulo .And. !Empty(aSessao[nI][1])
					If (nLin + 80) >= nFimL // Verifica se o t�tulo da sess�o cabe na p�gina
						oPrint:EndPage() // Se for maior, encerra a p�gina atual
						ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
						nLinCalc := nLin // Inicia o controle das linhas impressas
						lTitulo := .T. // Indica que o t�tulo pode ser impresso 
						lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
					EndIf
					
				EndIf

				If nI == 1 .And. cData <> alltochar((TMP)->NTA_DTFLWP)
					JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI], alltochar((TMP)->NTA_DTFLWP)) //Imprime o t�tulo da sess�o no relat�rio
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

		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
		oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio

		nLin += nSalto //Adiciona uma linha em branco ap�s a linha impressa
		nLinCalc := nLin

		cData := alltochar((TMP)->NTA_DTFLWP)

		(TMP)->(DbSkip())
	End

	(TMP)->(dbCloseArea())
	
	aSize(aDados, 0) //Limpa array de dados
	aSize(aRelat, 0) //Limpa array de dados do relat�rio
	aSize(aCabec, 0) //Limpa array de dados do cabe�alho do relat�rio
	aSize(aSessao,0) //Limpa array de dados das sess�es do relat�rio
	
	oPrint:EndPage() // Finaliza a p�gina

	If Empty(cNomeTar)
		oPrint:CFILENAME  := cNomeRel + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') + '.rel'
		oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
	ElseIf !lAutomato
		oPrint:CFILENAME  := cNomeTar
		oPrint:CFILEPRINT := cCaminho + cNomeTar
	EndIf

	oPrint:Print()

	If Empty(cNomeTar)
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

//oPrint:SetPortrait()   // Define a orienta��o do relat�rio como retrato (Portrait).

oPrint:SetLandscape()

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )
//oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
//oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
nLin := 150

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )
//nLin := 40

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
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Local cValor := ""
Local cPicture := ""

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
		If cCpoTab == "NTA_HORA" 
			cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
			If !Empty(cPicture)
				cValor := TRANSFORM((TMP)->&(cCpoQry), cPicture)
				cValor := AllTrim(cValor)
			Else
				cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
			EndIf
		Else
			cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
		EndIf
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
Static Function JImpSub(cQuerySub, TMP, aSessao, nLinCalc, lQuebPag ,aRelat , aCabec, oPrint, nLin, lTitulo, lLinTit)

Local nJ
Local cValor := ""
Local aDados := {}
Local SUB := GetNextAlias()
Local lHori := aSessao[4]
Local cTxt := cQuerySub
Local cVar    := "" // CAMPO
Local xValor        // Valor do campo

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

			If lTitulo .And. !Empty(aSessao[1])
				If (nLin + 80) >= nFimL // Verifica se o t�tulo da sess�o cabe na p�gina
					oPrint:EndPage() // Se for maior, encerra a p�gina atual
					ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
					nLinCalc := nLin // Inicia o controle das linhas impressas
					lTitulo := .T. // Indica que o t�tulo pode ser impresso 
					lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
				EndIf

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
Local nJ
Local cTitulo := ""
Local nPosTit := 0
Local oFontTit
Local nPos := 0
Local nQtdCar := 0
Local oFontVal
Local nPosValor := 0
Local lQuebLin  := .F.
Local lImpTit   := .T.
Local cValor   := ""
Local nLinTit  := 0
Local nLinAtu  := 0
Local aSobra   := aClone(aDados)

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
Local nTam      := 0
Local aCampForm := {} // Array com cada palavra a ser escrita.
Local cValor    := ""
Local cValImp   := "" // Valor impresso
Local nX        := 0
Local nLargura  := 0

cTexto := StrTran(cTexto, Chr(13)+Chr(10), '')
cTexto := StrTran(cTexto, Chr(10), '')
aCampForm := STRTOKARR(cTexto, " ")

If nRazao == 0 //Tratamento para o server � linux
	nRazao := 288
EndIf

nTam := (nRazao * nQtdCar) / 350

If Len(aCampForm) == 0 // Caso n�o exista conte�do/valor
	If lImpTit // E o t�tulo do campo foi impresso 
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Ser� inserida a linha com conte�do em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conte�do/valor
	For nX := 1 To Len(aCampForm) // La�o para cada palavra a ser escrita

	 	nLargura := oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal )

		If nLargura == 0 // Tratamento para o server � linux
			nLargura := (Len( cValor + aCampForm[nX] ) * 17)
		EndIf 

		If nLargura <= nTam // Se a palavra atual for impressa e N�O passar do limite de tamanho da linha
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
Static Function JImpTitSes(oPrint, nLin, nLinCalc, aSessao, cData)
Local oBrush1

oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)

oBrush1 := TBrush():New( , CLR_LIGHTGRAY )
oPrint:FillRect( {nLin-20, nColIni, (nLin + 30), nColFim}, oBrush1 )
oBrush1:End()
	
	//aSessao[1] - T�tulo da sess�o do relat�rio
	//aSessao[2] - Posi��o da descri��o
	//aSessao[3] - Fonte da sess�o
oPrint:Say( nLin+15, aSessao[2], aSessao[1] + cData, aSessao[3])
	
nLin+=80
nLinCalc := nLin

Return
