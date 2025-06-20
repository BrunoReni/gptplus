// 浜様様様曜様様様様�
// � Versao �  8     �
// 藩様様様擁様様様様�
#include "protheus.ch"
#include "OFIOR430.ch"     

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  26/09/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007162_1"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIOR430 � Autor � Thiago                � Data � 25/03/02 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri�ao � Relacao de Itens p/ Contagem Fisica                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOR430
	Private aReturn := { "", 1, "", 2, 2, 1, "", 1 } //"Zebrado"###"Administracao"
	Private cPerg   := "OFR430"
	Private cTitulo := STR0003 // Contagem Fisica

	// Mesmo passando a pergunte para o TReport
	// preciso carregar para as MV_PAR existirem
	PERGUNTE(cPerg, .f.)

	OFR4300016_ChamadaImpressaoContagemFisica()
Return

/*/{Protheus.doc} OFR4300016_ChamadaImpressaoContagemFisica
Chamada para impress�o dos Itens para Contagem F�sica
@author Fernando Vitor Cavani
@since 23/01/2020
@version undefined
@type function
/*/
Static Function OFR4300016_ChamadaImpressaoContagemFisica()
	Local oReport

	oReport := ReportDef() // Nesta fun艫o n�s definimos a estrutura do relat�rio, por exemplo as se苺es, campos, totalizadores e etc.
	oReport:SetPortrait()  // Define orienta艫o de p�gina do relat�rio como retrato.
	oReport:PrintDialog()  // Essa fun艫o serve para disparar a impress�o do TReport, ela que faz com que seja exibida a tela de configura艫o de impressora e os bot�es de par�metros.
Return

/*/{Protheus.doc} ReportDef
Criando o padr�o para impress�o dos Itens para Contagem F�sica
@author Fernando Vitor Cavani
@since 23/01/2020
@version undefined
@type function
/*/
Static Function ReportDef()
	Local cDesc := ""
	Local oReport
	Local oSection1
	Local oSection2

	cTit := ""
	cLoc := cDes := cGrp := cCod := cDis := cRes := cQtd := ""

	// Descri艫o
	cDesc := STR0016 // Este programa tem como objetivo imprimir os itens para contagem f�sica

	// TReport
	oReport := TReport():New(           ;
		"OFIOR430",                     ;
		cTitulo,                        ;
		cPerg,                          ;
		{|oReport| OFIR430IMP(oReport)},;
		cDesc)

	// T�tulo
	oSection1 := TRSection():New(oReport, "oTitulo")

	oReport:Section(1):SetLineStyle() // Define se imprime as c�lulas da se艫o em linhas
	oSection1:SetLinesBefore(1)       // Define a quantidade de linhas que ser�o saltadas antes da impress�o da se艫o

	TRCell():New(oSection1, "oTit",, "", "@!", 80,, {|| cTit },,,,,,,,, .t.) // T�tulo

	// Dados
	oSection2 := TRSection():New(oReport, "oDados")

	oSection2:SetLinesBefore(1) // Define a quantidade de linhas que ser�o saltadas antes da impress�o da se艫o

	TRCell():New(oSection2, "oLoc",, STR0009, "@!"      ,  50,, {|| cLoc },,,        ,,,,,,) // Localizacao
	TRCell():New(oSection2, "oDes",, STR0012, "@!"      , 110,, {|| cDes },,,        ,,,,,,) // Descricao
	TRCell():New(oSection2, "oGrp",, STR0010, "@!"      ,  20,, {|| cGrp },,,        ,,,,,,) // Grupo
	TRCell():New(oSection2, "oCod",, STR0011, "@!"      ,  80,, {|| cCod },,,        ,,,,,,) // Cod Item
	TRCell():New(oSection2, "oDis",, STR0013, "@E 99999",  30,, {|| cDis },,, "RIGHT",,,,,,) // Qtd Disp
	TRCell():New(oSection2, "oRes",, STR0014, "@E 99999",  30,, {|| cRes },,, "RIGHT",,,,,,) // Qtd Res
	TRCell():New(oSection2, "oQtd",, STR0015, "@!"      ,  30,, {|| cQtd },,,        ,,,,,,) // Quantidade
Return(oReport)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �OFIR430IMP� Autor � Andre Luis Almeida    � Data � 13/08/09 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri�ao � Levantamento e Impressao                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Altera�ao � Alterado o PRW inteiro para SQL utilizando SB5 e/ou SBZ    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function OFIR430IMP(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cGruVei   := Left(GetNewPar("MV_GRUVEI", "VEI") + Space(10), Len(SB1->B1_GRUPO))
	Local cGruSrv   := Left(GetNewPar("MV_GRUSRV", "SRVC") + Space(10), Len(SB1->B1_GRUPO))
	Local lSBZ      := (SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ")
	Local cArmRes   := Left(GetMV("MV_RESITE") + Space(10), Len(SB2->B2_LOCAL))
	Local cQuery    := ""
	Local cQAlSB1   := "SQLSB1"

	// T�tulo
	oSection1:Init()

	cTit := STR0001 // "Relacao de Itens p/ Contagem Fisica"

	oSection1:PrintLine()
	oSection1:Finish()

	// SQL Principal
	If lSBZ .And. SBZ->(FieldPos("BZ_LOCALI2")) > 0
		cQuery := "SELECT * FROM (SELECT SB1.B1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC, "

        cQuery += "SUM(CASE WHEN SB2.B2_LOCAL <> '" + cArmRes + "' THEN SB2.B2_QATU ELSE 0 END) AS QTDEDIS, "
        cQuery += "SUM(CASE WHEN SB2.B2_LOCAL = '" + cArmRes + "' THEN SB2.B2_QATU ELSE 0 END) AS QTDERES, "

		If GetNewPar("MV_MIL0096", "S") == "N" // A loca艫o da pe�a tamb�m deve ser considerada na tabela SB5 quando o par�metro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=N�o Considera )
			cQuery += "SBZ.BZ_LOCALI2 LOCALI2 FROM " + RetSqlName("SB1") + " SB1 "
		Else
			cQuery += "CASE WHEN SBZ.BZ_LOCALI2 IS NULL THEN SB5.B5_LOCALI2 ELSE SBZ.BZ_LOCALI2 END LOCALI2 FROM " + RetSqlName("SB1") + " SB1 "
		EndIf

		cQuery += "LEFT JOIN " + RetSqlName("SB2") + " SB2 ON (SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB1.B1_COD = SB2.B2_COD "
		cQuery += "  AND ((SB2.B2_LOCAL >= '01' AND SB2.B2_LOCAL <= '50') OR (SB2.B2_LOCAL = '" + cArmRes + "')) AND SB2.D_E_L_E_T_ = ' ') "
		cQuery += "LEFT JOIN " + RetSqlName("SB5") + " SB5 ON (SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND SB1.B1_COD = SB5.B5_COD AND SB5.D_E_L_E_T_ = ' ') "
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON (SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "' AND SB1.B1_COD = SBZ.BZ_COD AND SBZ.D_E_L_E_T_ = ' ') "
		cQuery += "WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_GRUPO <> '" + cGruVei + "' AND SB1.B1_GRUPO <> '" + cGruSrv + "' AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  GROUP BY SB1.B1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC, "

		If GetNewPar("MV_MIL0096", "S") == "N" // A loca艫o da pe�a tamb�m deve ser considerada na tabela SB5 quando o par�metro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=N�o Considera )
			cQuery += "SBZ.BZ_LOCALI2 "
		Else
			cQuery += "CASE WHEN SBZ.BZ_LOCALI2 IS NULL THEN SB5.B5_LOCALI2 ELSE SBZ.BZ_LOCALI2 END "
		EndIf

		If MV_PAR03 == 2 // Apenas c/ Saldo
			cQuery�+=�"  HAVING SUM(SB2.B2_QATU) > 0 "
		EndIf

		cQuery�+=�"  ) TEMP "
		cQuery += "  WHERE TEMP.LOCALI2 >= '" + MV_PAR01 + "' AND TEMP.LOCALI2 <= '" + MV_PAR02 + "' "
		cQuery += "ORDER BY B1_GRUPO, B1_CODITE"
	Else
		cQuery := "SELECT SB1.B1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC, SB5.B5_LOCALI2 AS LOCALI2, "

        cQuery += "SUM(CASE WHEN SB2.B2_LOCAL <> '" + cArmRes + "' THEN SB2.B2_QATU ELSE 0 END) AS QTDEDIS, "
        cQuery += "SUM(CASE WHEN SB2.B2_LOCAL = '" + cArmRes + "' THEN SB2.B2_QATU ELSE 0 END) AS QTDERES "

		cQuery += "FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB2") + " SB2, "+ RetSqlName("SB5") + " SB5 "
		cQuery += "WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
		cQuery += "  AND SB1.B1_GRUPO <> '" + cGruVei + "' AND SB1.B1_GRUPO <> '" + cGruSrv + "' "
		cQuery += "  AND SB1.B1_COD = SB5.B5_COD AND SB5.B5_LOCALI2 >= '" + MV_PAR01 + "' AND SB5.B5_LOCALI2 <= '" + MV_PAR02 + "' "
		cQuery += "  AND SB1.B1_COD = SB2.B2_COD AND ((SB2.B2_LOCAL >= '01' AND SB2.B2_LOCAL <= '50') OR (SB2.B2_LOCAL = '" + cArmRes + "')) "

		If MV_PAR03 == 2 // Apenas c/ Saldo
			cQuery += "  AND SB2.B2_QATU > 0 "
		EndIf

		cQuery += "  AND SB1.D_E_L_E_T_ = ' ' AND SB2.D_E_L_E_T_ = ' '  AND SB5.D_E_L_E_T_ = ' ' "
		cQuery += "GROUP BY SB1.B1_COD, SB1.B1_GRUPO, SB1.B1_CODITE, SB1.B1_DESC, SB5.B5_LOCALI2 "
		cQuery += "ORDER BY SB1.B1_GRUPO, SB1.B1_CODITE"
	EndIf
	dbUseArea(.T., "TOPCONN", TcGenQry( ,,cQuery ), cQAlSB1, .F., .T.)

	// Dados
	oSection2:Init()

	While !(cQAlSB1)->(Eof())

		cLoc := Left((cQAlSB1)->(LOCALI2) + Space(15), 15) // Loca艫o
		cDes := Left((cQAlSB1)->(B1_DESC) + Space(23), 23) // Descri艫o do Item
		cGrp := (cQAlSB1)->(B1_GRUPO)                      // Grupo
		cCod := SubStr((cQAlSB1)->(B1_CODITE), 1, 17)      // C�digo do Item
		cRes := (cQAlSB1)->(QTDERES)                       // Reservado
		cDis := (cQAlSB1)->(QTDEDIS)                       // Dispon�vel

		cQtd := " __________ "                             // Quantidade

		oSection2:PrintLine()

		(cQAlSB1)->(DbSkip())
	EndDo

	oSection2:Finish()

	(cQAlSB1)->(DbCloseArea())
Return