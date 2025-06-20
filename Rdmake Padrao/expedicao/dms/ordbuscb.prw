#Include "PROTHEUS.CH" 
#Include "TopConn.CH" 

// 浜様様様曜様様様様�
// � Versao �   12   �
// 藩様様様擁様様様様�
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � ORDBUSCB � Autor � Andre Luis Almeida � Data �  07/10/05    艮�
臼�Programa  � ORDBUSCB � Autor � Alecsandre Ferreira � Data � 10/09/21    艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様 恒�
臼�Desc.     �Imprime Ordem de Busca                                       艮�
臼�Desc.     �10/09/21 - Altera艫o do Report para utilizar a classe TReport艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様 恒�
臼�Uso       � Balcao                                                      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様 識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼 臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
User Function ORDBUSCB(cT)
   	Local oReport
	Local bCampo := {|nCPO| Field(nCPO)}
	Private cTitulo := ""
	Private cDesc := ""
	Private cAlias := "QRYVS3"
	Private cNomeRel := "ORDBUSCB"
	Private aOrdem := {}
	Private cX := If(cT==Nil,"",cT)
	Private cOper := ""

	if Type("ParamIXB") != "U"
		cX := ParamIxb[1]
		If Len(ParamIxb) > 1
			cOper := ParamIxb[2]
			if len(ParamIxb) == 3
				aDelet := ParamIxb[3]
			Endif	
		EndIf
	Endif

	if cX == "OR"
		cX := "O"
	endif	

	If cX # "O" // Pela NF
		DbSelectArea("VS1")
		DbSetOrder(3)
		DbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
		M->VS1_NUMORC := VS1->VS1_NUMORC
		cTitulo:= "NF:"+SF2->F2_DOC+"-"+SF2->F2_SERIE+" Orcamento:"+VS1->VS1_NUMORC+"  Dt NF: "+transform(SF2->F2_EMISSAO,"@E 999,999,999.99")
	Else
		If Type("M->VS1_NUMORC") == "U"
			M->VS1_NUMORC := VS1->VS1_NUMORC
		Endif
		cTitulo:= "Orcamento:"+VS1->VS1_NUMORC
	Endif

	oReport := RptDefOB()
    oReport:nFontBody := 12
    oReport:oPage:nPaperSize := 9
    oReport:PrintDialog()
Return .T.

Static Function RptDefOB()
    Local oReport
    Local oSection1
    Local oSection2
	Local oSection3
		
	oReport := TReport():New(;
        cNomeRel,;
        cTitulo,;
        ,;
        {|oReport| RptRunOB(oReport)},;
        cDesc;
    )

	oReport:SetLineHeight(45)
    oSection1 := TRSection():New(oReport)
    oSection1:SetLinesBefore(1)
    oSection1:SetHeaderPage()

	TRCell():New(oSection1, "A1_COD", "SA1", "C�d. Cli.",, 12)
	TRCell():New(oSection1, "A1_NOME", "SA1", "Cliente",, 40)
	If cX # "O"
    	TrCell():New(oSection1,"A3_NOME", "SA3", "Vendedor",, 20)
	Endif
    TrCell():New(oSection1,"VV1_PLAVEI", "VV1", "Placa",, 12)
	TRCell():New(oSection1,"VV1_FILIAL", "VV1", "Filial Destino",, 12)

	oSection2 := TRSection():New(oReport)
	TRCell():New(oSection2, "SEQUEN",  	  "",    "Seq.",,      12)
	TRCell():New(oSection2, "B1_GRUPO",   "SB1", "Grupo",,     12)
	TRCell():New(oSection2, "B1_CODITE",  "SB1", "C�digo",,    45)
	TRCell():New(oSection2, "B1_DESC",    "SB1", "Descri艫o",, 30)
	TRCell():New(oSection2, "B5_LOCALI2", "SB5", "Locacao",,   24)
	TRCell():New(oSection2, "VS3_QTDITE", "VS3", "Qtde.",,     12)
	oSection2:SetLinesBefore(2)

	oSection3 := TRSection():New(oReport)
    TRCell():New(oSection3,"COL1",    '', '', , 10)
    TrCell():New(oSection3,"COLRESP", '', '', , 40)
    TrCell():New(oSection3,"COL3",    '', '', , 20)
    TrCell():New(oSection3,"COLPREST",'', '', , 40)
    TrCell():New(oSection3,"COL5",    '', '', , 10)
	oSection3:SetLinesBefore(5)
    oSection3:SetHeaderSection(.F.)
Return oReport

Static Function RptRunOB(oReport)
	Local cQuery  := "SQLSDB"
	Local nCntFor := 0
	Local lEntrou := .F.
	Local lControlaCancela := .F.
	Local lControlaImpressao := .F.
	Local aTRB := {}
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	cAlias := "VS3"
	cNomRel := "ORDB_" + M->VS1_NUMORC + "_" + __cUserId
	cDesc1 := "Ordem de Busca"
	aOrdem := {}
	lHabil := .F.
	lVS1_OBSNFI := .F.

	DbSelectArea("VS3")
	DbSetOrder(1)
	If !DbSeek(xFilial("VS3")+M->VS1_NUMORC)
		Return
	EndIf

	If FunName() <> "OFIOR700" .And. cOper <> "CANCELA" .And. !Empty(cOper)
		lControlaImpressao := .T.
	EndIf

	If cOper == "CANCELA"
		lControlaCancela := .T.
	EndIf

	While !Eof() .AND. VS3->VS3_FILIAL == xFilial("VS3") .AND. VS3->VS3_NUMORC == VS1->VS1_NUMORC
		if VS3->VS3_QTDITE-VS3->VS3_QTDTRA > 0
			lEntrou := .T.
			Exit
		Endif
		dbSkip()
	EndDo
	If !lEntrou
		Return
	Endif 	
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("VS1_OBSNFI")
		lVS1_OBSNFI := .T.
	EndIf

	DbSelectArea("VS1")
	cPlaca := space(8)
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)

	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
	cPlaca := Transform(VV1->VV1_PLAVEI, "@R !!!-!!!!")

	DbSelectArea("VS3")
	DbSetOrder(1)
	DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
	While !Eof() .AND. VS3->VS3_FILIAL == xFilial("VS3") .AND. VS3->VS3_NUMORC == VS1->VS1_NUMORC
		If (lControlaImpressao .And. VS3->VS3_IMPRES == "1") .Or. (lControlaCancela .And. VS3->VS3_IMPRES == "0")
			DbSkip()
			Loop
		EndIf
		if Type("ParamIXB") != "U"
			if len(ParamIxb) == 3
				if aScan(aDelet, {|x| x == VS3->VS3_SEQUEN}) == 0
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)

		If Localiza(SB1->B1_COD)
			cQuery := " SELECT "
			cQuery += " 	SDB.DB_LOCAL, "
			cQuery += " 	SDB.DB_LOCALIZ, "
			cQuery += " 	SDB.DB_QUANT "
			cQuery += " FROM "
			cQuery += 		RetSqlName("SDB") + " SDB "
			cQuery += " WHERE "
			cQuery += " 	SDB.DB_FILIAL = '" + xFilial("SDB") + "' "
			cQuery += " 	AND SDB.DB_PRODUTO = '" + SB1->B1_COD + "' "
			cQuery += "		AND SDB.DB_DOC = '" + VS3->VS3_DOCSDB + "' "
			cQuery += "		AND SDB.DB_QUANT > 0 "
			cQuery += "		AND SDB.DB_TM > '500' "
			cQuery += " 	AND SDB.D_E_L_E_T_ = '' "
			cQuery += " ORDER BY "
			cQuery += "		SDB.R_E_C_N_O_ "
			TcQuery cQuery New Alias cAlias
		
			If !(cQuery)->(Eof())
				Do While !(cQuery)->(Eof())
					AADD(aTRB,;
						{VS3->VS3_GRUITE,;
						VS3->VS3_CODITE,;
						Substr(SB1->B1_DESC, 1, 20),;
						(cQuery)->(DB_LOCALIZ),;
						(cQuery)->(DB_QUANT)};
					)
					(cQuery)->(DbSkip())
				Enddo
			Else
				DbSelectArea("SB5")
				DbSetOrder(1)
				DbSeek(xFilial("SB5")+SB1->B1_COD)
				if VS3->VS3_QTDITE-VS3->VS3_QTDTRA > 0 
					AADD(aTRB,;
						{VS3->VS3_GRUITE,;
						VS3->VS3_CODITE,;
						Substr(SB1->B1_DESC, 1, 20),;
						FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2"),;
						VS3->VS3_QTDITE - VS3->VS3_QTDTRA};
					)
				Endif
			Endif
			(cQuery)->(DbCloseArea())
		Else
			DbSelectArea("SB5")
			DbSetOrder(1)
			DbSeek(xFilial("SB5")+SB1->B1_COD)
		
			if VS3->VS3_QTDITE-VS3->VS3_QTDTRA > 0 
				AADD(aTRB,;
					{VS3->VS3_GRUITE,;
					VS3->VS3_CODITE,;
					Substr(SB1->B1_DESC,1,20),;
					FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2"),;
					VS3->VS3_QTDITE - VS3->VS3_QTDTRA};
				)
			Endif		
		Endif
	
		DbSelectArea("VS3")
		DbSkip()
	EndDo

	oSection1:Init()
	oSection1:Cell("A1_COD"):SetValue(Alltrim(VS1->VS1_CLIFAT + "-" + VS1->VS1_LOJA))
	oSection1:Cell("A1_NOME"):SetValue(left(SA1->A1_NOME, 35))
	If cX # "O"
    	oSection1:Cell("A3_NOME"):SetValue(left(SA3->A3_NOME, 10))
	Endif
    oSection1:Cell("VV1_PLAVEI"):SetValue(cPlaca)
	oSection1:Cell("VV1_FILIAL"):SetValue(VS1->VS1_FILDES)
    oSection1:PrintLine()
    oSection1:Print()
    oSection1:Finish()

	oSection2:Init()
	For nCntFor := 1 To Len(aTRB)
		oSection2:Cell("SEQUEN"):SetValue(StrZero(nCntFor, 2))
		oSection2:Cell("B1_GRUPO"):SetValue(aTRB[nCntFor][1])
		oSection2:Cell("B1_CODITE"):SetValue(aTRB[nCntFor][2])
		oSection2:Cell("B1_DESC"):SetValue(aTRB[nCntFor][3])
		oSection2:Cell("B5_LOCALI2"):SetValue(aTRB[nCntFor][4])
		oSection2:Cell("VS3_QTDITE"):SetValue(aTRB[nCntFor][5])
		oSection2:PrintLine()
	Next
	oSection2:Print()
	oSection2:Finish()

	oSection3:Init()
    oSection3:Cell("COL1"):SetValue(Replicate(" ", 10))
    oSection3:Cell("COLRESP"):SetValue(Replicate("_", 40))
    oSection3:Cell("COL3"):SetValue(Replicate(" ", 10))
    oSection3:Cell("COLPREST"):SetValue(Replicate("_", 40))
    oSection3:Cell("COL5"):SetValue(Replicate(" ", 10))
    oSection3:PrintLine()

    oReport:SkipLine(2)
    oSection3:Cell('COLRESP'):SetAlign('CENTER')
    oSection3:Cell('COLPREST'):SetAlign('CENTER')

    oSection3:Cell("COL1"):SetValue(Replicate(" ", 10))
    oSection3:Cell("COLRESP"):SetValue('Atendente')
    oSection3:Cell("COL3"):SetValue(Replicate(" ", 10))
    oSection3:Cell("COLPREST"):SetValue('Retirado Por')
    oSection3:Cell("COL5"):SetValue(Replicate(" ", 10))
    oSection3:PrintLine()
	
    oSection3:Print()
    oSection3:Finish()
Return oReport
