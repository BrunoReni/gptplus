// 浜様様様曜様様様様�
// � Versao � 19     �
// 藩様様様擁様様様様�

#INCLUDE "ofior320.ch"
#include "protheus.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIOR320 � Autor � Thiago                � Data � 04/02/02 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri�ao � Itens com Locacao                                          咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOR320
	Private cAliasSB1      := "SQLSB1"
	Private cTamB5_LOCALI2 := Space(TamSX3("B5_LOCALI2")[1])
	Private cTamBZ_LOCALI2 := IIF(SBZ->(FieldPos("BZ_LOCALI2")) > 0, Space(TamSX3("BZ_LOCALI2")[1]), " ")
	Private lSBZ           := (SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ")
	Private lLocSoSBZ      := ( lSBZ .and. GetNewPar("MV_MIL0096","S") == "N" ) // A loca艫o da pe�a tamb�m deve ser considerada na tabela SB5 quando o par�metro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=N�o Considera )

	OFR320R3() // Executa vers�o anterior do fonte
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OFR320R3  �Autor  �Fabio               � Data �  09/04/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Impresao do relatorio.                                      艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � AP                                                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function OFR320R3()
	Private aReturn := {STR0002, 1, STR0003, 2, 2, 1, "", 1} // Itens X Loca艫o / Administracao
	Private cPerg   := "OFR320"
	Private cTitulo := STR0004 // Itens com Locacao

	ValidPerg()

	// Mesmo passando a pergunte para o TReport
	// preciso carregar para as MV_PAR existirem
	PERGUNTE(cPerg, .f.)

	OFR3200016_ChamadaImpressaoItensLocacao()
Return

/*/{Protheus.doc} OPR1300016_ChamadaImpressaoDemonstrativo
Chamada para impress�o dos Demonstrativos
@author Fernando Vitor Cavani
@since 04/03/2019
@version undefined
@type function
/*/
Static Function OFR3200016_ChamadaImpressaoItensLocacao()
	Local oReport

	oReport := ReportDef() // Nesta fun艫o n�s definimos a estrutura do relat�rio, por exemplo as se苺es, campos, totalizadores e etc.
	oReport:SetPortrait()  // Define orienta艫o de p�gina do relat�rio como retrato.
	oReport:PrintDialog()  // Essa fun艫o serve para disparar a impress�o do TReport, ela que faz com que seja exibida a tela de configura艫o de impressora e os bot�es de par�metros.
Return

/*/{Protheus.doc} ReportDef
Criando o padr�o para impress�o dos Itens com Loca艫o
@author Fernando Vitor Cavani
@since 04/03/2019
@version undefined
@type function
/*/
Static Function ReportDef()
	Local cDesc := ""
	Local oReport
	Local oSection1
	Local oSection2

	cTit := ""
	cLoc := cGrp := cCod := cDes := cQtd := ""

	// Descri艫o
	cDesc := STR0030 // Este programa tem como objetivo imprimir os itens com loca艫o ou com estoque e sem loca艫o

	// TReport
	oReport := TReport():New(           ;
		"OFIOR320",                       ;
		cTitulo,                        ;
		cPerg,                          ;
		{|oReport| OFIR320IMP(oReport)},;
		cDesc)

	// T�tulo
	oSection1 := TRSection():New(oReport, "oTitulo")

	oReport:Section(1):SetLineStyle() // Define se imprime as c�lulas da se艫o em linhas
	oSection1:SetLinesBefore(1)       // Define a quantidade de linhas que ser�o saltadas antes da impress�o da se艫o

	TRCell():New(oSection1, "oTit",, "", "@!", 80,, {|| cTit },,,,,,,,, .t.) // T�tulo

	// Dados
	oSection2 := TRSection():New(oReport, "oDados")

	oSection2:SetLinesBefore(1) // Define a quantidade de linhas que ser�o saltadas antes da impress�o da se艫o

	TRCell():New(oSection2, "oLoc",, STR0021, "@!"        ,  80,, {|| cLoc },,,        ,,,,,,) // Loca艫o
	TRCell():New(oSection2, "oGrp",, STR0022, "@!"        ,  10,, {|| cGrp },,,        ,,,,,,) // Grupo
	TRCell():New(oSection2, "oCod",, STR0023, "@!"        ,  80,, {|| cCod },,,        ,,,,,,) // C�digo do Item
	TRCell():New(oSection2, "oDes",, STR0024, "@!"        , 120,, {|| cDes },,,        ,,,,,,) // Descri艫o
	TRCell():New(oSection2, "oQtd",, STR0025, "@E 999,999",  20,, {|| cQtd },,, "RIGHT",,,,,,) // Quantidade
Return(oReport)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OFIR320IMP�Autor  �Thiago              � Data �  09/04/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Impressao do relatorio.                                     艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � AP                                                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function OFIR320IMP(oReport)
	Local oSection1 := oReport:Section(1)
	Local cGruVei   := Left(GetNewPar("MV_GRUVEI", "VEI") + Space(10), Len(SB1->B1_GRUPO))
	Local cGruSrv   := Left(GetNewPar("MV_GRUSRV", "SRVC") + Space(10), Len(SB1->B1_GRUPO))

	Private oSection2 := oReport:Section(2)

	lSBZ := (SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ")

	// T�tulo
	oSection1:Init()

	If MV_PAR01 == 1
		cTit := STR0004 // Itens com Locacao
	ElseIf MV_PAR01 == 2
		cTit := STR0006 // Itens com Estoque e sem Locacao
	Else
		cTit := STR0031 // Itens (Todos)
	EndIf

	oSection1:PrintLine()
	oSection1:Finish()

	// Dados
	oSection2:Init()

	// Itens com Loca艫o ou Ambos
	If MV_PAR01 == 1 .Or. MV_PAR01 == 3
		OFR3200026_ImpItensComLocacao(oReport, cGruVei, cGruSrv)
	EndIf

	// Autor Thiago
	// Data  04/02/02
	// Itens com Estoque e sem Loca艫o ou Ambos
	If MV_PAR01 == 2 .Or. MV_PAR01 == 3
		OFR3200036_ImpItensComEstoqueSemLocacao(oReport, cGruVei, cGruSrv)
	EndIf

	oSection2:Finish()
Return

/*/{Protheus.doc} OFR3200026_ImpItensComLocacao
Impress�o dos Itens com Loca艫o
@author Fernando Vitor Cavani
@since 04/03/2019
@version undefined
@param oReport, objeto  , Impressao
@param cGruVei, caracter, Par�metro MV_GRUVEI
@param cGruSrv, caracter, Par�metro MV_GRUSRV
@type function
/*/
Static Function OFR3200026_ImpItensComLocacao(oReport, cGruVei, cGruSrv)
	// Vinicius Gati - 19/11/14

	If lSBZ .And. SBZ->(FieldPos("BZ_LOCALI2")) > 0
		If lLocSoSBZ
			cQuery := " SELECT "
			cQuery += " 	SB1.B1_COD, "
			cQuery += " 	SB1.B1_GRUPO, "
			cQuery += " 	SB1.B1_CODITE, "
			cQuery += " 	SB1.B1_DESC, "
			cQuery += " 	SBZ.BZ_LOCALI2 LOCALI2, "
			cQuery += " 	SUM(SB2.B2_QATU) QTD "
			cQuery += " FROM "
			cQuery += " 	" + RetSqlName("SBZ") + " SBZ JOIN " + RetSqlName("SB1") + " SB1 "
			cQuery += " 	ON "
			cQuery += " 		BZ_FILIAL = '" + xFilial("SBZ") + "' "
			cQuery += " 		AND B1_FILIAL = '" + xFilial("SB1") + "' "
			cQuery += " 		AND B1_COD = BZ_COD "
			cQuery += " 		AND B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
			cQuery += " 		AND SBZ.BZ_LOCALI2 <> '" + cTamBZ_LOCALI2 + "' "
			cQuery += " 		AND B1_MSBLQL = '2' "
			cQuery += " 		AND SBZ.BZ_LOCALI2 >= '" + AllTrim(MV_PAR02) + "' "
			cQuery += " 		AND SBZ.BZ_LOCALI2 <= '" + AllTrim(MV_PAR03) + "' "
			cQuery += " 		AND SBZ.D_E_L_E_T_ = ' ' "
			cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " 	JOIN " + RetSqlName("SB2") + " SB2 "
			cQuery += " 	ON "
			cQuery += " 		B2_FILIAL = '" + xFilial("SB2") + "' "
			cQuery += " 		AND SB2.B2_COD = SB1.B1_COD "
			cQuery += " 		AND SB2.B2_LOCAL <= '50' "
			cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY "
			cQuery += " 	SB1.B1_COD, "
			cQuery += " 	SB1.B1_GRUPO, "
			cQuery += " 	SB1.B1_CODITE, "
			cQuery += " 	SB1.B1_DESC, "
			cQuery += " 	SBZ.BZ_LOCALI2 "
		Else
			cQuery := " SELECT "
			cQuery += " 	SB1.B1_COD, "
			cQuery += " 	SB1.B1_GRUPO, "
			cQuery += " 	SB1.B1_CODITE, "
			cQuery += " 	SB1.B1_DESC, "
			cQuery += " 	CASE
			cQuery += " 		WHEN (SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2 = '" + cTamBZ_LOCALI2 + "') THEN SB5.B5_LOCALI2 "
			cQuery += " 		ELSE SBZ.BZ_LOCALI2 "
			cQuery += " 	END LOCALI2, "
			cQuery += " 	SUM(SB2.B2_QATU) QTD "
			cQuery += " FROM "
			cQuery += " 	" + RetSqlName("SB1") + " SB1 JOIN " + RetSqlName("SB2") + " SB2 "
			cQuery += " 	ON "
			cQuery += " 		B1_FILIAL = '" + xFilial("SB1") + "' "
			cQuery += " 		AND SB2.B2_FILIAL = '" + xFilial('SB2') + "' "
			cQuery += " 		AND SB2.B2_COD = SB1.B1_COD "
			cQuery += " 		AND SB2.B2_LOCAL <= '50' "
			cQuery += " 		AND SB1.B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
			cQuery += " 		AND B1_MSBLQL = '2' "
			cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
			cQuery += "  		AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " 	LEFT JOIN " + RetSqlName("SBZ") + " SBZ "
			cQuery += " 	ON "
			cQuery += " 		SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "' "
			cQuery += " 		AND SBZ.BZ_COD = SB1.B1_COD "
			cQuery += " 		AND SBZ.BZ_LOCALI2 >= '" + AllTrim(MV_PAR02) + "' "
			cQuery += " 		AND SBZ.BZ_LOCALI2 <= '" + AllTrim(MV_PAR03) + "' "
			cQuery += " 		AND SBZ.BZ_LOCALI2 <> '" + cTamBZ_LOCALI2 + "' "
			cQuery += " 		AND SBZ.D_E_L_E_T_ = ' ' "
			cQuery += " 	LEFT JOIN " + RetSqlName("SB5") + " SB5 "
			cQuery += " 	ON "
			cQuery += " 		SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
			cQuery += " 		AND SB5.B5_COD = SB1.B1_COD "
			cQuery += " 		AND SB5.B5_LOCALI2 >= '" + AllTrim(MV_PAR02) + "' "
			cQuery += " 		AND SB5.B5_LOCALI2 <= '" + AllTrim(MV_PAR03) + "' "
			cQuery += " 		AND SB5.B5_LOCALI2 <> '" + cTamBZ_LOCALI2 + "' "
			cQuery += " 		AND SB5.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY "
			cQuery += " 	SB1.B1_COD, "
			cQuery += " 	SB1.B1_GRUPO, "
			cQuery += " 	SB1.B1_CODITE, "
			cQuery += " 	SB1.B1_DESC, "
			cQuery += " 	CASE "
			cQuery += " 		WHEN (SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2 = '" + cTamBZ_LOCALI2 + "') THEN SB5.B5_LOCALI2 "
			cQuery += " 		ELSE SBZ.BZ_LOCALI2 "
			cQuery += " 	END "
		Endif
	Else
		cQuery := " SELECT "
		cQuery += " 	SB1.B1_COD, "
		cQuery += " 	SB1.B1_GRUPO, "
		cQuery += " 	SB1.B1_CODITE, "
		cQuery += " 	SB1.B1_DESC, "
		cQuery += " 	SB5.B5_LOCALI2 LOCALI2, "
		cQuery += " 	SUM(SB2.B2_QATU) QTD "
		cQuery += " FROM "
		cQuery += " 	" + RetSqlName("SB5") + " SB5 JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += " 	ON "
		cQuery += " 		B5_FILIAL = '" + xFilial("SB5") + "' "
		cQuery += " 		AND B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " 		AND B5_COD = B1_COD "
		cQuery += " 		AND SB5.B5_LOCALI2 >= '" + AllTrim(MV_PAR02) + "' "
		cQuery += " 		AND SB5.B5_LOCALI2 <= '" + AllTrim(MV_PAR03) + "' "
		cQuery += " 		AND SB5.B5_LOCALI2 <> '" + cTamB5_LOCALI2 + "' "
		cQuery += " 		AND SB1.B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
		cQuery += " 		AND B1_MSBLQL = '2' "
		cQuery += " 		AND SB5.D_E_L_E_T_ = ' ' "
		cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " 	JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += " 	ON "
		cQuery += " 		B2_FILIAL = '" + xFilial("SB2") + "' "
		cQuery += " 		AND SB1.B1_COD = SB2.B2_COD "
		cQuery += " 		AND SB2.B2_LOCAL <= '50' "
		cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY "
		cQuery += " 	SB1.B1_COD, "
		cQuery += " 	SB1.B1_GRUPO, "
		cQuery += " 	SB1.B1_CODITE, "
		cQuery += " 	SB1.B1_DESC, "
		cQuery += " 	SB5.B5_LOCALI2 "
	EndIf


	If MV_PAR04 == 1 // Ordena艫o (Item)
		cQuery += " ORDER BY "
		cQUery += " 	2, "
		cQUery += " 	3 " // Ordena a coluna 2 e 3 (Grupo e C�digo)
	ElseIf MV_PAR04 == 2 // Ordena艫o (Loca艫o)
		cQuery += " ORDER BY "
		cQuery += " 	5 " // Ordena a coluna 5 (Endere�o DMS)
	EndIf
		
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasSB1, .T., .T.)
	Do While !(cAliasSB1)->(Eof())
		cLoc := (cAliasSB1)->LOCALI2
		cGrp := (cAliasSB1)->B1_GRUPO
		cCod := (cAliasSB1)->B1_CODITE
		cDes := (cAliasSB1)->B1_DESC
		cQtd := (cAliasSB1)->QTD

		oSection2:PrintLine()

		DbSelectArea(cAliasSB1)

		(cAliasSB1)->(DbSkip())
	EndDo

	(cAliasSB1)->(dbCloseArea())
Return

/*/{Protheus.doc} OFR3200036_ImpItensComEstoqueSemLocacao
Impress�o dos Itens com Estoque e sem Loca艫o
@author Fernando Vitor Cavani
@since 04/03/2019
@version undefined
@param oReport, objeto  , Impressao
@param cGruVei, caracter, Par�metro MV_GRUVEI
@param cGruSrv, caracter, Par�metro MV_GRUSRV
@type function
/*/
Static Function OFR3200036_ImpItensComEstoqueSemLocacao(oReport, cGruVei, cGruSrv)
	// Vinicius Gati - 19/11/14 (Se usa BZ � feito JOIN com BZ e o segundo SELECT s�o sempre para os registros que n�o est�o no BZ nem no B5)
	If lSBZ .And. SBZ->(FieldPos("BZ_LOCALI2")) > 0
		If lLocSoSBZ
			cQuery := " SELECT "
			cQuery += " 	SB1.B1_COD, "
			cQuery += " 	SB1.B1_GRUPO, "
			cQuery += " 	SB1.B1_CODITE, "
			cQuery += " 	SB1.B1_DESC, "
			cQuery += " 	SUM(SB2.B2_QATU) QTD "
			cQuery += " FROM "
			cQuery += " 	" + RetSqlName("SBZ") + " SBZ JOIN " + RetSqlName("SB1") + " SB1 "
			cQuery += " 	ON "
			cQuery += " 		SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			cQuery += " 		AND SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "' "
			cQuery += " 		AND SB1.B1_COD = SBZ.BZ_COD "
			cQuery += " 		AND SB1.B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
			cQuery += " 		AND SBZ.BZ_LOCALI2 = '" + cTamBZ_LOCALI2 + "' "
			cQuery += " 		AND B1_MSBLQL = '2' "
			cQuery += " 		AND SBZ.D_E_L_E_T_ = ' ' "
			cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " 	JOIN " + RetSqlName("SB2") + " SB2 "
			cQuery += " 	ON "
			cQuery += " 		SB2.B2_FILIAL = '" + xFilial('SB2') + "' "
			cQuery += " 		AND SB2.B2_COD = SB1.B1_COD "
			cQuery += " 		AND SB2.B2_LOCAL <= '50' "
			cQuery += " 		AND SB2.B2_QATU > 0 "
			cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
		Else
			cQuery := " SELECT "
			cQuery += " 	SB1.B1_COD, "
			cQuery += " 	SB1.B1_GRUPO, "
			cQuery += " 	SB1.B1_CODITE, "
			cQuery += " 	SB1.B1_DESC, "
			cQuery += " 	SUM(SB2.B2_QATU) QTD "
			cQuery += " FROM "
			cQuery += " 	" + RetSqlName("SB1") + " SB1 JOIN " + RetSqlName("SB2") + " SB2 "
			cQuery += " 	ON "
			cQuery += " 		SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			cQuery += " 		AND SB2.B2_FILIAL = '" + xFilial('SB2') + "' "
			cQuery += " 		AND SB2.B2_COD = SB1.B1_COD "
			cQuery += " 		AND SB1.B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
			cQuery += " 		AND SB2.B2_LOCAL <= '50' "
			cQuery += " 		AND SB2.B2_QATU > 0 "
			cQuery += " 		AND B1_MSBLQL = '2' "
			cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
			cQuery += " 	LEFT JOIN "+ RetSqlName("SBZ") + " SBZ "
			cQuery += " 	ON "
			cQuery += " 		SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "' "
			cQuery += " 		AND SBZ.BZ_COD = SB1.B1_COD "
			cQuery += " 		AND SBZ.BZ_LOCALI2 = '" + cTamBZ_LOCALI2 + "' "
			cQuery += " 		AND SBZ.D_E_L_E_T_ = ' ' "
			cQuery += " 	LEFT JOIN " + RetSqlName("SB5") + " SB5 "
			cQuery += " 	ON "
			cQuery += " 		SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
			cQuery += " 		AND SB5.B5_COD = SB1.B1_COD "
			cQuery += " 		AND SB5.B5_LOCALI2 = '" + cTamBZ_LOCALI2 + "' "
			cQuery += " 		AND SB5.D_E_L_E_T_ = ' ' "
		Endif
	Else
		cQuery := " SELECT "
		cQuery += " 	SB1.B1_COD, "
		cQuery += " 	SB1.B1_GRUPO, "
		cQuery += " 	SB1.B1_CODITE, "
		cQuery += " 	SB1.B1_DESC, "
		cQuery += " 	SUM(SB2.B2_QATU) QTD "
		cQuery += " FROM "
		cQuery += " 	" + RetSqlName("SB5") + " SB5 JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += " 	ON "
		cQuery += " 		SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " 		AND SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
		cQuery += " 		AND SB1.B1_COD = SB5.B5_COD "
		cQuery += " 		AND SB5.B5_LOCALI2 = '" + cTamB5_LOCALI2 + "' "
		cQuery += " 		AND B1_MSBLQL = '2' "
		cQuery += " 		AND SB1.B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
		cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " 		AND SB5.D_E_L_E_T_ = ' ' "
		cQuery += " 	JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += " 	ON "
		cQuery += " 		SB2.B2_FILIAL = '" + xFilial("SB2") + "' "
		cQuery += " 		AND SB2.B2_COD = SB1.B1_COD "
		cQuery += " 		AND SB2.B2_LOCAL <= '50' "
		cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
		cQuery += " 		AND SB2.B2_QATU > 0 "
		cQuery += " GROUP BY "
		cQuery += " 	SB1.B1_COD, "
		cQuery += " 	SB1.B1_GRUPO, "
		cQuery += " 	SB1.B1_CODITE, "
		cQuery += " 	SB1.B1_DESC "

		cQuery += " UNION ALL "

		cQuery += " SELECT "
		cQuery += " 	SB1.B1_COD, "
		cQuery += " 	SB1.B1_GRUPO, "
		cQuery += " 	SB1.B1_CODITE, "
		cQUery += " 	SB1.B1_DESC, "
		cQuery += " 	SUM(B2_QATU) QTD "
		cQuery += " FROM "
		cQuery += " 	" + RetSqlName("SB1") + " SB1 JOIN " + RetSqlName("SB2") + " SB2 "
		cQuery += " 	ON "
		cQuery += " 		SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " 		AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' "
		cQuery += " 		AND SB2.B2_COD = SB1.B1_COD "
		cQuery += " 		AND SB2.B2_QATU > 0 "
		cQuery += " 		AND SB1.B1_GRUPO NOT IN ('" + cGruVei + "', '" + cGruSrv + "') "
		cQuery += " 		AND B1_MSBLQL = '2' "
		cQuery += " 		AND SB2.B2_LOCAL <= '50' "
		cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " 		AND SB2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE "
		cQuery += " 	SB1.B1_COD NOT IN "
		cQuery += " 	(SELECT DISTINCT B5_COD FROM " + RetSqlName("SB5") + " B5 WHERE B5.D_E_L_E_T_ = ' ' AND B5.B5_FILIAL = '" + xFilial("SB5") + "') "
	EndIf
	cQuery += " 	GROUP BY "
	cQuery += " 		SB1.B1_COD, "
	cQuery += " 		SB1.B1_GRUPO, "
	cQuery += " 		SB1.B1_CODITE, "
	cQuery += " 		SB1.B1_DESC "

	If MV_PAR04 == 1 // Ordena艫o (Item)
		cQuery += " ORDER BY "
		cQuery += " 	2, "
		cQuery += " 	3 " // Ordena a coluna 2 e 3 (Grupo e C�digo)
	EndIf

	DbSelectArea("SB5")
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasSB1, .T., .T.)
	Do While !(cAliasSB1)->(Eof())

		SB5->(DbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD)) // faz esse posicionamento apenas para poder usar o FM_PRODSBZ corretamente, porque sem o Posicionamento do SB5, quando o conte�do � Branco, a fun~艫o pode estar pegando de qualquer registro posicionado
		cLoc := FM_PRODSBZ((cAliasSB1)->B1_COD, "SB5->B5_LOCALI2")
		If !Empty(cLoc)
			(cAliasSB1)->(DbSkip())
			Loop
		Endif
		cGrp := (cAliasSB1)->B1_GRUPO
		cCod := (cAliasSB1)->B1_CODITE
		cDes := (cAliasSB1)->B1_DESC
		cQtd := (cAliasSB1)->QTD

		oSection2:PrintLine()

		DbSelectArea(cAliasSB1)

		(cAliasSB1)->(DbSkip())
	EndDo

	(cAliasSB1)->(dbCloseArea())
Return

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Fun��o    �VALIDPERG � Autor � Ricardo Farinelli  � Data �  05/07/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descri��o � Verifica a existencia das perguntas criando-as caso seja   艮�
臼�          � necessario (caso nao existam).                             艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Programa principal                                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Static Function ValidPerg
	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i, j

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := "OFR320"
	cPerg := PADR(cPerg, LEN(SX1->X1_GRUPO))

	// Endere�o De
	aAdd(aRegs, {cPerg, "02", STR0018, "", "", "MV_CH2", "C", 50, 0, 0, "G", "", "MV_PAR02", "", "", "", "", "", "", "", "",; // Endere�o De
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

	// Endere�o Ate
	aAdd(aRegs, {cPerg, "03", STR0019, "", "", "MV_CH3", "C", 50, 0, 0, "G", "", "MV_PAR03", "", "", "", "", "", "", "", "",; // Endere�o Ate
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

	// Ordernar por: 
	aAdd(aRegs, {cPerg, "04", STR0027, "", "", "MV_CH4", "N",  1, 0, 1, "C", "", "MV_PAR04", STR0028, STR0028, STR0028, "", "", STR0029, STR0029, STR0029,; // Ordernar por: / Item / Locacao
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1", .T.)

			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i,j])
				EndIf
			Next

			MsUnlock()
		EndIf
	Next

	dbSelectArea(_sAlias)
Return