#include 'Protheus.ch'
#include 'WMSR381.ch'

//-----------------------------------------------------------
/*/{Protheus.doc} WMSR381
Gera��o e impress�o do mapa de separa��o fracionado

@version	P11
@since   03/05/06 - revis�o 15/09/14
/*/
//-----------------------------------------------------------
Function WMSR381()
Local oReport
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WmsR380()
	EndIf
	//  Interface de impress�o
	oReport := ReportDef()
	oReport:PrintDialog()
Return
//------------------------------------------------------------
//  Defini��es do relat�rio
//------------------------------------------------------------
Static Function ReportDef()
Local oReport, oSection1, oSection2, oBreak
Local cAliasRel  := GetNextAlias()
	// Defini��o do relat�rio
	oReport := TReport():New('WMSR381', STR0001,'WMSR381',{|oReport| ReportPrint(oReport,cAliasRel)},STR0028) //  Mapa de Separa��o Fracionado ## Este relat�rio tem por objetivo Gerar e Imprimir ou apenas Imprimir um Mapa de Separa��o para quantidades fracionadas, de acordo com os par�metros informados.
	oReport:SetColSpace(2)
	oReport:lParamPage := .F.
	// Verifica os par�metros selecionados via Pergunte
	Pergunte(oReport:GetParam(),.F.)

	// Se��o 1 - Informa��es do mapa de separa��o e documento
	// TRSection:New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)
	oSection1 := TRSection():New(oReport,STR0029,{'D12','D0T','DA3'},,,,,,,,,,,.T.,,,,,3) // Cabe�alho Mapa de Separa��o
	TRCell():New(oSection1,'D12_MAPSEP' ,'D12',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'D12_CARGA'  ,'D12',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'D12_DOC'    ,'D12', STR0031  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| Iif(WmsCarga((cAliasRel)->D12_CARGA),'',(cAliasRel)->D12_DOC)}) // Pedido
	TRCell():New(oSection1,'D12_ENDDES' ,'D12',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'D12_IDUNIT' ,'D12',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	If WmsX312118("D0T","D0T_DESUNI",.T.)
		TRCell():New(oSection1,'D0T_DESUNI' ,'D0T',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	EndIf
	TRCell():New(oSection1,'DA3_PLACA'  ,'DA3', STR0025  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,  {|| W381Placa()             }  ) // Placa do Veiculo
	TRCell():New(oSection1,'D12_CLIFOR' ,'D12', STR0018  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'D12_LOJA'   ,'D12',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	// Se��o 2 - Itens do mapa de separa��o
	oSection2 := TRSection():New(oSection1,STR0030,{'D12','SB1'},,,,,,,,,,,.F.,0) // Itens do Mapa de Separa��o
	TRCell():New(oSection2,'D12_LOCORI' ,'D12')
	TRCell():New(oSection2,'D12_ENDORI' ,'D12',/*Titulo*/,/*Picture*/,  20       ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'D12_IDUNIT' ,'D12')
	TRCell():New(oSection2,'D12_PRODUT' ,'D12')
	TRCell():New(oSection2,'B1_DESC'    ,'SB1')
	TRCell():New(oSection2,'D12_LOTECT' ,'D12')
	TRCell():New(oSection2,'D12_NUMLOT' ,'D12')
	TRCell():New(oSection2,'D12_QTDMOV' ,'D12', STR0019  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'B1_UM'      ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'D12_CLIFOR' ,'D12', STR0018  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'D12_LOJA'   ,'D12',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	// Cabe�alhos e c�lulas que n�o devem aparecer no relat�rio
	oSection2:Cell('B1_UM'  ):HideHeader()

	// Define que a se��o filha utiliza a query da se��o pai na impress�o da se��o
	oSection2:SetParentQuery()

	// Defini��o das quebras e totalizadores que ser�o impressos
	oBreak := TRBreak():New(oSection1,oSection1:Cell('D12_MAPSEP'),STR0026,.T.) // 'Totais'
	TRFunction():New(oSection2:Cell('D12_PRODUT'),NIL,'COUNT',oBreak, STR0020,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.) // Nr. Itens
	TRFunction():New(oSection2:Cell('D12_PRODUT'),NIL,'SUM'  ,oBreak, STR0021,PesqPictQt('B1_PESO'),{|| ((cAliasRel)->D12_QTDMOV * (cAliasRel)->B1_PESO) },.F.,.F.,.F.)
	TRFunction():New(oSection2:Cell('D12_PRODUT'),Nil,'SUM'  ,oBreak, STR0022,"@E 999,999,999.9999",{|| ((cAliasRel)->D12_QTDMOV * (cAliasRel)->B5_ALTURLC * (cAliasRel)->B5_LARGLC * (cAliasRel)->B5_COMPRLC) },.F.,.F.,.F.)
Return oReport
//-----------------------------------------------------------
// Impress�o do relat�rio
//-----------------------------------------------------------
Static Function ReportPrint(oReport,cAliasRel)
Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
Local cSemMpSep := Space(TamSX3("D12_MAPSEP")[1])
Local cWhere    := ''
Local cMapa     := ''
Local cCodUni   := ''
Local cDesUni   := ''
Local cCodCFG   := ""
Local cPicCFG   := ""
Local cSeekQry  := ''
Local bSeekQry  := {||.T.}

	// Transforma parametros Range em expressao SQL
	MakeSqlExpr(oReport:GetParam())

	If mv_par01 == 1
		cWhere := "% D12.D12_STATUS = '4'"
		cWhere += " AND D12.D12_CARGA BETWEEN '"+mv_par02+"' AND '"+mv_par03+"'"
		cWhere += " AND D12.D12_DOC BETWEEN '"+mv_par04+"' AND '"+mv_par05+"'"
		If mv_par09 == 1
			cWhere += " AND D12.D12_MAPSEP  BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' %"
		Else
			cWhere += " AND D12.D12_MAPSEP = '"+cSemMpSep+"' %"
		EndIf
	Else
		cWhere := "% D12.D12_MAPSEP BETWEEN '"+mv_par06+"' AND '"+mv_par07+"'"
		cWhere += " AND D12.D12_MAPSEP <> '"+cSemMpSep+"'"
		cWhere += " AND D12.D12_STATUS IN ('4','3','2','-')"
		cWhere += " AND D12.D12_ATUEST = '1' %"
	EndIf

	// Query do relatorio
	oSection1:BeginQuery()
		BeginSql Alias cAliasRel
			SELECT D12.D12_CARGA,  D12.D12_SEQCAR, D12.D12_DOC,    D12.D12_SERIE, D12.D12_CLIFOR, D12.D12_LOJA,
			       D12.D12_PRODUT, D12.D12_LOTECT, D12.D12_NUMLOT, D12.D12_QTDMOV, D12.D12_LOCORI, D12.D12_ENDORI, 
			       D12.D12_IDUNIT, D12.D12_ENDDES, D12.D12_MAPSEP, D12.D12_IDMOV,  D12.R_E_C_N_O_ RECNOD12, D12.D12_ATUEST,
			       SB1.B1_DESC, SB1.B1_UM, SB1.B1_PESO,    SB5.B5_ALTURLC, SB5.B5_LARGLC,  SB5.B5_COMPRLC, SBE.BE_CODCFG
			  FROM %table:D12% D12
			 INNER JOIN %table:SB1% SB1
			    ON SB1.B1_FILIAL = %xFilial:SB1%
			   AND SB1.B1_COD = D12.D12_PRODUT
			   AND SB1.%NotDel%
			 INNER JOIN %table:SB5% SB5
			    ON SB5.B5_FILIAL = %xFilial:SB5%
			   AND SB5.B5_COD = D12.D12_PRODUT
			   AND SB5.B5_WMSEMB = '1'
			   AND SB5.%NotDel%
			INNER JOIN %table:SBE% SBE
				ON SBE.BE_FILIAL  = %xFilial:SBE%
			  AND SBE.BE_LOCAL   = D12.D12_LOCORI
			  AND SBE.BE_LOCALIZ = D12.D12_ENDORI
			  AND SBE.%NotDel%
			 WHERE D12.D12_FILIAL = %xFilial:D12%
			   AND D12.D12_ORIGEM = 'SC9'
			   AND D12.D12_MAPTIP = '1'
			   AND %Exp:cWhere%
			   AND D12.%NotDel%
			 ORDER BY D12.D12_CARGA,D12.D12_SEQCAR,D12.D12_CLIFOR,D12.D12_LOJA,D12.D12_DOC,
			          D12.D12_SERIE,D12.D12_ENDDES,D12.D12_ENDORI,D12.D12_IDUNIT
		EndSql
	oSection1:EndQuery()

	// Definindo as secoes filhas para utilizarem a query da secao pai
	oSection2:SetParentQuery()

	// Fluxo de impress�o do relat�rio
	oReport:SetMeter((cAliasRel)->(LastRec()))

	While !oReport:Cancel() .And. !(cAliasRel)->(Eof())

		If mv_par01 == 1
			cMapa := WMSProxSeq("MV_WMSMPSP","D12_MAPSEP")
		Else
			cMapa := (cAliasRel)->D12_MAPSEP
		EndIf

		// Busca c�digo e descri��o do unitizador
		If WmsArmUnit((cAliasRel)->D12_LOCORI)
			W381DesUni((cAliasRel)->D12_LOCORI,(cAliasRel)->D12_ENDORI,(cAliasRel)->D12_PRODUT,@cCodUni,@cDesUni)
		EndIf

		oSection1:Init()

		// In�cio da impress�o das informa��es do mapa de separa��o e documento
		oSection1:Cell('D12_MAPSEP'):SetValue(cMapa)
		oSection1:Cell('D12_IDUNIT'):SetValue(cCodUni)
		If WmsX312118("D0T","D0T_DESUNI",.T.)
			oSection1:Cell('D0T_DESUNI'):SetValue(cDesUni)
		EndIf

		// Impress�o do c�digo de barras
		oReport:PrintText('')
		oReport:SkipLine(5)

		MSBAR3("CODE128",2,0.5,Trim(cMapa),@oReport:oPrint,Nil,Nil,Nil,Nil ,1 ,Nil,Nil,Nil,.F.,,,.F.)

		// Guarda as informa��es para controlar a gera��o e impress�o de uma CARGA por mapa de separa��o, se utilizar carga
		// Ou um PEDIDO por mapa de separa��o, se n�o utilizar carga
		// Independente da quebra escolhida, dever� agrupar primeiro pelo n�mero do mapa
		// Pois pode ser que a gera��o tenha sido feita por um agrupamento a impress�o seja por outra
		// Desta forma dever� quebrar por mapa cada p�gina a ser impressa
		// Quando n�o tem mapa gerado este campo est� em branco n�o influenciando na quebra
		If WmsCarga((cAliasRel)->D12_CARGA)
			oSection1:Cell('D12_CLIFOR'):Disable()
			oSection1:Cell('D12_LOJA'):Disable()
			oSection2:Cell('D12_CLIFOR'):Enable()
			oSection2:Cell('D12_LOJA'):Enable()
			cSeekQry := (cAliasRel)->D12_MAPSEP+(cAliasRel)->D12_CARGA+(cAliasRel)->D12_SEQCAR+(cAliasRel)->D12_ENDDES
			bSeekQry := {|| cSeekQry == (cAliasRel)->D12_MAPSEP+(cAliasRel)->D12_CARGA+(cAliasRel)->D12_SEQCAR+(cAliasRel)->D12_ENDDES}
		Else
			oSection1:Cell('D12_CLIFOR'):Enable()
			oSection1:Cell('D12_LOJA'):Enable()
			oSection2:Cell('D12_CLIFOR'):Disable()
			oSection2:Cell('D12_LOJA'):Disable()
			cSeekQry := (cAliasRel)->D12_MAPSEP+(cAliasRel)->D12_DOC+(cAliasRel)->D12_CLIFOR+(cAliasRel)->D12_ENDDES
			bSeekQry := {|| cSeekQry == (cAliasRel)->D12_MAPSEP+(cAliasRel)->D12_DOC+(cAliasRel)->D12_CLIFOR+(cAliasRel)->D12_ENDDES}
		EndIf

		oSection1:PrintLine()
		oReport:PrintText(STR0007) // Nr.Separador     : _______________
		oReport:PrintText(STR0008) // Nr.Conferente    : _______________
		oReport:PrintText(STR0009) // Nr.Embalador     : _______________

		oSection2:Init()
		While !oReport:Cancel() .And. (cAliasRel)->(!Eof()) .And. Eval(bSeekQry)

			If cCodCFG <> (cAliasRel)->BE_CODCFG // Verifica se o codigo mudou
				cCodCFG := (cAliasRel)->BE_CODCFG // Atualiza flag
				cPicCFG := DLXPicEnd((cAliasRel)->BE_CODCFG) // Atualiza Picture
				oSection2:Cell('D12_ENDORI'):SetPicture(cPicCFG)
			EndIf
			// Somente imprime a atividade que movimenta estoque
			If (cAliasRel)->D12_ATUEST == "1"
				oSection2:PrintLine()
			EndIf

			// Se gera e imprime, atualiza registro D12
			If mv_par01 == 1
				D12->(DbGoTo((cAliasRel)->RECNOD12))
				RecLock('D12')
				D12->D12_MAPSEP := cMapa
				D12->(MsUnlock())
			EndIf
			oReport:IncMeter()
			(cAliasRel)->(DbSkip())
		EndDo
		oSection2:Finish()
		oSection1:Finish()
		oReport:EndPage()
	EndDo
	(cAliasRel)->(DbCloseArea())
Return
//-----------------------------------------------------------
// W381Placa
// Busca a placa do caminh�o que far� o transporte da carga
// pertencente ao mapa de separa��o
//-----------------------------------------------------------
Function W381Placa()
Local aAreaAnt  := GetArea()
Local cPlaca    := ''
Local cQuery    := ''
Local cAliasNew := GetNextAlias()
	cQuery := "SELECT DA3_PLACA"
	cQuery +=  " FROM "+RetSqlName('DA3')+" DA3, "+RetSqlName('DAK')+" DAK "
	cQuery += " WHERE DA3.DA3_COD    = DAK.DAK_CAMINH "
	cQuery +=   " AND DA3_FILIAL     = '"+xFilial('DA3')+"'"
	cQuery +=   " AND DAK.DAK_FILIAL = '"+xFilial('DAK')+"'"
	cQuery +=   " AND DAK.DAK_COD    = '"+D12->D12_CARGA+"'"
	cQuery +=   " AND DAK.DAK_SEQCAR = '"+D12->D12_SEQCAR+"'"
	cQuery +=   " AND DA3.D_E_L_E_T_ = ' '"
	cQuery +=   " AND DAK.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.T.,.F.)
	If (cAliasNew)->(!Eof())
		cPlaca := (cAliasNew)->DA3_PLACA
	EndIf
	RestArea(aAreaAnt)
Return cPlaca
//-----------------------------------------------------------
// W381DesUni
// Busca o c�digo e a descri��o do unitizador
// cCodUni  C�digo do unitizador
// cDesUni  Descri��o do unitizador
//-----------------------------------------------------------
Function W381DesUni(cArmazem,cEndereco,cProduto,cCodUni,cDesUni,lUsaPar)
Local aAreaAnt  := GetArea()
Local cQuery    := ''
Local cAliasNew := ''
Default lUsaPar := .T.
	If lUsaPar .And. !Empty(mv_par08)
		D0T->(DbSetOrder(1))
		If D0T->(MsSeek(xFilial('D0T')+mv_par08))
			cCodUni := D0T->D0T_CODUNI
			cDesUni := D0T->D0T_DESUNI
		EndIf
	Else
		cQuery := "SELECT D0T.D0T_CODUNI, D0T.D0T_DESUNI"
		cQuery +=  " FROM "+RetSqlName('SBE')+" SBE, "+RetSqlName('DC3')+" DC3, "+RetSqlName('DC2')+" DC2, "+RetSqlName('D0T')+" D0T"
		cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial('DC8')+"'"
		cQuery +=   " AND SBE.BE_LOCAL   = '"+cArmazem+"'"
		cQuery +=   " AND SBE.BE_LOCALIZ = '"+cEndereco+"'"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
		cQuery +=   " AND DC3.DC3_LOCAL  = '"+cArmazem+"'"
		cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
		cQuery +=   " AND DC3.DC3_TPESTR = SBE.BE_ESTFIS"
		cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DC2.DC2_FILIAL = '"+xFilial('DC2')+"'"
		cQuery +=   " AND DC2.DC2_CODNOR = DC3.DC3_CODNOR"
		cQuery +=   " AND DC2.D_E_L_E_T_ = ' '"
		cQuery +=   " AND D0T.D0T_FILIAL = '"+xFilial('D0T')+"'"
		cQuery +=   " AND D0T.D0T_CODUNI = DC2.DC2_CODUNI"
		cQuery +=   " AND D0T.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasNew := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.T.,.F.)

		If (cAliasNew)->(!Eof())
			cCodUni := (cAliasNew)->D0T_CODUNI
			cDesUni := (cAliasNew)->D0T_DESUNI
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return

