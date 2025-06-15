#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PRAA807A
	Registro Associação de documentos
@author siegklenes.beulke
@since 18/03/2015
@version 1.0

@example
	PRAA807A()
/*/
Static a_TAM_CNT := {"10=10","20=20","30=30","40=40"}
Function PRAA807A()
	Local aAreaZZ7 := (cAliasZZ7)->(GetArea())
	Private cAliasZZC := ""
	Private cAliasZZD := ""
	Private cAliasZZ4 := ""
	Private a_PRC_DC := {''}
	SEL_AR_PRO()
	MontaDados()
	
	FWExecView("Associar documento", "PRAA807A", 3,,{||.T.})
	(caliasZZ7)->(dbclearfilter())
	RestArea(aAreaZZ7)
Return

Static Function GetStruct(nid)
	Local astru := {{{"ZZC_MARCAD", "C",03, 0}},;
					  {{"ZZ4_RRCID" , "N",10, 0},;
					  	{"ZZD_MARCAD", "L",01, 0},;
					   {"ZZD_MARCA2","L",01, 0},;
					   {"ZZD_MARCA3","L",01, 0},;
					   {"ZZD_CNTID" , "C",11, 0},;
					   {"ZZD_DENTID", "C",30, 0},;
					   {"ZZD_TISO"  , "C",04, 0},;
					   {"ZZD_TPTAM" , "C",02, 0},;
					   {"ZZD_TAR"   , "N",13, 2},;
					   {"ZZD_VAL"   , "N",13, 2},;
					   {"ZZD_PES"   , "N",13, 2}}}
					   
	Default nid := 1
Return astru[nid]

Static Function MontaDados()
	If Empty(cAliasZZC)
		cAliasZZC := GetNextAlias()
		cAliasZZC := CriaTabTmp(GetStruct(),{'ZZC_MARCAD'},cAliasZZC)
	Else
		dbSelectArea(cAliasZZC)
		ZAP
	EndIf
	
	If Empty(cAliasZZD)
		cAliasZZD := GetNextAlias()
		cAliasZZD := CriaTabTmp(GetStruct(2),{'ZZD_CNTID'},cAliasZZD)
	Else
		dbSelectArea(cAliasZZD)
		ZAP
	EndIf
	
	RecLock(cAliasZZC,.T.)
	(cAliasZZC)->ZZC_MARCAD := cValToChar(.T.)
	(cAliasZZC)->(MsUnLock())
	
	If Empty(cAliasZZ4)
		cAliasZZ4 := GetNextAlias()
		cAliasZZ4 := CriaTabTmp(GetZZ4Struct(),{'ZZ4_NRDC','cValToChar(ZZ4_MARCAD)+ZZ4_NRDC'},cAliasZZ4)
	Else
		dbSelectArea(cAliasZZ4)
		ZAP
	EndIf
	
Return
Static Function ModelDef()
	Local oModel
	Local oModelZZ7  := FWLoadModel('PRAA807')
	Local oModelZZ4  := FWLoadModel('PRAA806')
	Local oStruZZ7   := oModelZZ7:GetModelStruct('PRAA807_ZZ9')[3]:OFORMMODELSTRUCT
	Local oStruZZ4   := oModelZZ4:GetModelStruct('PRAA806_ZZ4')[3]:OFORMMODELSTRUCT
	Local oStructZZC := FWFormModelStruct():New()
	
	oStructZZC:AddTable(cAliasZZC, {'ZZC_MARCAD'},"Registro de containers")
	oStructZZC:AddIndex(1,'01','ZZC_MARCAD','Indice 1','','',.T.)
	
	//Reserva:
	oStructZZC:AddField("ID"	, "ID reserva", 	"ZZC_MARCAD", "C",03, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
		
	oStruZZ7:Deactivate()
	oStruZZ7:AddField("RESID"	, "Código da reserva", 	"ZZ7_RESID", "N",  10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ7:AddField("ZZ7_RCNTID"	, "Código da RNCID", 	"ZZ7_RCNTID", "N",  10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ7:AddField("Reserva"	, "Código da reserva", 	"ZZ7_RESERV", "C",  30, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ7:AddField("Documentos"  , "Documentos"  ,"ZZ7_QTDOC"  ,"N",13,0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,/*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ7:AddField("Peso Liquid.", "Peso Liquid.","ZZ7_PESLIQ" ,"N",13,2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,/*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/)
	oStruZZ7:AddField("Peso Bruto"  , "Peso Bruto"  ,"ZZ7_PESDOC" ,"N",13,2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,/*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ7:AddField("Valor (R$)"  , "Valor (R$)"  ,"ZZ7_VALDOC" ,"N",13,2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,/*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/)
	oStruZZ7:SetProperty("*",	MODEL_FIELD_OBRIGAT,.F.)
	oStruZZ7:SetProperty("ZZ7_CNTTAM", MODEL_FIELD_VALUES,a_TAM_CNT)

	oStruZZ4:Deactivate()
	oStruZZ4:AddField("Item"  , "Item" , "ZZ4_MARCA1","L",01, 0, {||A806AMARK('PRAA807_ZZ4A','PRAA807_ZZ4B','ZZ4_NRDC',,'ZZ4_MARCA1|ZZ4_MARCA2','ZZ4_MARCA3',{{"ZZ4_PESACF","ZZ4_PESCOF"},{"ZZ4_VLACOF","ZZ4_VLCOF"}}),A807AVLPCF(),A807AVLVCF()/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("Item"  , "Item" , "ZZ4_MARCAD","N",01, 0, {||A806AMARK('PRAA807_ZZ4A','PRAA807_ZZ4B','ZZ4_NRDC',,'ZZ4_MARCAD|ZZ4_MARCA2','ZZ4_MARCA3',{{"ZZ4_PESACF","ZZ4_PESCOF"},{"ZZ4_VLACOF","ZZ4_VLCOF"}}),A807AVLPCF(),A807AVLVCF()/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,.T./*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("Item"  , "Item" , "ZZ4_MARCA2","L",01, 0, {||A806AMARK('PRAA807_ZZ4B','PRAA807_ZZ4A','ZZ4_NRDC',,'ZZ4_MARCAD|ZZ4_MARCA2','ZZ4_MARCA3'),A807AVLPCF(),A807AVLVCF()/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("Item"  , "Item" , "ZZ4_MARCA3","L",01, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("rrcid" , "rrcid", "ZZ4_RRCID" ,"N",10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:SetProperty("*",	MODEL_FIELD_OBRIGAT,.F.)
	oStruZZ4:AddField("Peso (Kg)", "Peso (Kg)"				, "ZZ4_PESCOF", "N",  13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("Peso (Kg)", "Peso (Kg)"				, "ZZ4_PESACF", "N",  13, 2, {||A807AVLPCF()},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("Valor (R$)", "Valor (R$)"		,     "ZZ4_VLCOF"	, "N",  13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStruZZ4:AddField("Valor (R$)", "Valor (R$)"		,     "ZZ4_VLACOF"	, "N",  13, 2, {||A807AVLVCF()},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
    oModel := MPFormModel():New('PRAA807A', /*bPre*/, {|oModel|A807ABPOS(oModel)}, {|oModel|A807ABCOMMIT(oModel)},{|| FWFORMCANCEL(SELF)})
	oModel:SetDescription("Registro de containers")
	
	oModel:AddFields('PRAA807_ZZ4C', Nil, oStructZZC,,,)
	oModel:GetModel('PRAA807_ZZ4C'):SetDescription("Registro de containers")
	
	oModel:AddGrid('PRAA807_ZZ7','PRAA807_ZZ4C',oStruZZ7)
	oModel:GetModel('PRAA807_ZZ7'):SetDescription("Registro de containers")
	
	oModel:AddGrid('PRAA807_ZZ4A','PRAA807_ZZ4C',oStruZZ4,,,,,/*{|oModel|A807LDCNT(oModel)}*/)
	oModel:GetModel('PRAA807_ZZ4A'):SetDescription("Documentos (Reserva)")
	
	oModel:AddGrid('PRAA807_ZZ4B','PRAA807_ZZ4C',oStruZZ4,,,,,/*{|oModel|A807LDCNT(oModel,.T.)}*/)
	oModel:GetModel('PRAA807_ZZ4B'):SetDescription("Documentos associados")
	
	oModel:SetVldActivate ( { |oMod| A807AVLACT( oMod ) } )
	oModel:SetActivate ( { |oMod| A807AACTIVE( oMod ) } )
	
//	oModel:GetModel('PRAA807_ZZ4A'):SetOnlyQuery(.T.)
	oModel:GetModel('PRAA807_ZZ7'):SetOptional(.T.)
	oModel:GetModel('PRAA807_ZZ4A'):SetOptional(.T.)
	oModel:GetModel('PRAA807_ZZ4B'):SetOptional(.T.)
//	oModel:GetModel('PRAA807_ZZ4A'):SetNoInsertLine(.T.)
//	oModel:GetModel('PRAA807_ZZ4A'):SetNoDeleteLine(.T.)
//	oModel:GetModel('PRAA807_ZZ4B'):SetOnlyQuery(.T.)
//	oModel:GetModel('PRAA807_ZZ4B'):SetOptional(.T.)
//	oModel:GetModel('PRAA807_ZZ4B'):SetNoInsertLine(.T.)
//	oModel:GetModel('PRAA807_ZZ4B'):SetNoDeleteLine(.T.)
//	oModel:GetModel('PRAA807_ZZ7'):SetOnlyQuery(.T.)
//	oModel:GetModel('PRAA807_ZZ7'):SetOptional(.T.)
//	oModel:GetModel('PRAA807_ZZ7'):SetNoInsertLine(.T.)
//	oModel:GetModel('PRAA807_ZZ7'):SetNoDeleteLine(.T.)
//	oModel:GetModel('PRAA807_ZZ7'):SetNoUpdateLine(.T.)
	oModel:SetPrimaryKey({'ZZC_MARCAD'})
	
Return oModel

Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oModel := FWLoadModel('PRAA807A')
	Local oViewZZ7 := FWLoadView('PRAA807')
	Local oViewZZ4A := FWLoadView('PRAA806')
	Local oViewZZ4B := FWLoadView('PRAA806')
	Local oStruZZ7 := oViewZZ7:GetViewStruct('PRAA807_ZZ9')
	Local oStruZZ4A := oViewZZ4A:GetViewStruct('PRAA806_ZZ4')
	Local oStruZZ4B := oViewZZ4B:GetViewStruct('PRAA806_ZZ4')
	Local nX
	Local nTam
	oStruZZ7:Deactivate()
	For nX := Len(oStruZZ7:AFIELDS) to 1 Step -1
		If !(oStruZZ7:AFIELDS[nX][1] $ "ZZ7_RESERV|ZZ7_CNTID|ZZ7_CNTISO|ZZ7_CNTTAM|ZZ7_TAR" )
			oStruZZ7:RemoveField(oStruZZ7:AFIELDS[nX][1])
		EndIf
	Next nX
	
	oStruZZ7:SetProperty("ZZ7_CNTID" , MVC_VIEW_ORDEM, "02")
	oStruZZ7:SetProperty("ZZ7_CNTISO" , MVC_VIEW_ORDEM, "03")
	oStruZZ7:SetProperty("ZZ7_CNTTAM" , MVC_VIEW_ORDEM, "04")
	oStruZZ7:SetProperty("ZZ7_TAR" , MVC_VIEW_ORDEM, "05")
	oStruZZ7:SetProperty("ZZ7_CNTTAM", MVC_VIEW_COMBOBOX,a_TAM_CNT)
	
	oStruZZ7:AddField("ZZ7_RESERV" ,"01","Reserva"	   , "Código da reserva", , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ7:AddField("ZZ7_QTDOC"  ,"06","Documentos"  , "Documentos"       , , "N",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ7:AddField("ZZ7_VALDOC" ,"07","Valor (R$)"  , "Valor (R$)"       , , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ7:AddField("ZZ7_PESLIQ" ,"08","Peso Liquid.", "Peso Liquid."     , , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ7:AddField("ZZ7_PESDOC" ,"09","Peso Bruto"  , "Peso Bruto"       , , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStruZZ7:SetProperty('*'  ,MVC_VIEW_CANCHANGE,.F.)

	oStruZZ4A:Deactivate()
	For nX := Len(oStruZZ4A:AFIELDS) to 1 Step -1
		If !(oStruZZ4A:AFIELDS[nX][1] $ "ZZ4_TPDOC|ZZ4_SRDC|ZZ4_NRDC|ZZ4_VLDC|ZZ4_PESOKG" )
			oStruZZ4A:RemoveField(oStruZZ4A:AFIELDS[nX][1])
		EndIf
	Next nX
	
	oStruZZ4A:SetProperty("ZZ4_TPDOC" , MVC_VIEW_ORDEM, "02")
	oStruZZ4A:SetProperty("ZZ4_SRDC"  , MVC_VIEW_ORDEM, "03")
	oStruZZ4A:SetProperty("ZZ4_NRDC"  , MVC_VIEW_ORDEM, "04")
	oStruZZ4A:SetProperty("ZZ4_VLDC"  , MVC_VIEW_ORDEM, "05")
	oStruZZ4A:SetProperty("ZZ4_PESOKG", MVC_VIEW_ORDEM, "07")
	
	oStruZZ4A:SetProperty('*'  ,MVC_VIEW_CANCHANGE,.F.)
	oStruZZ4A:AddField("ZZ4_MARCA1" ,"01","Item"	   	, "Item"	   			, , "L",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStruZZ4A:AddField("ZZ4_VLCOF" ,"06","Valor restante"	   	, "Valor restante"	   			, , "GET","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ4A:AddField("ZZ4_PESCOF" ,"08","Peso restante"	   	, "Peso restante"	   			, , "GET","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStruZZ4B:Deactivate()
	For nX := Len(oStruZZ4B:AFIELDS) to 1 Step -1
		If !(oStruZZ4B:AFIELDS[nX][1] $ "ZZ4_TPDOC|ZZ4_SRDC|ZZ4_NRDC" )
			oStruZZ4B:RemoveField(oStruZZ4B:AFIELDS[nX][1])
		EndIf
	Next nX
	
	oStruZZ4B:SetProperty("ZZ4_TPDOC" , MVC_VIEW_ORDEM, "02")
	oStruZZ4B:SetProperty("ZZ4_SRDC"  , MVC_VIEW_ORDEM, "03")
	oStruZZ4B:SetProperty("ZZ4_NRDC"  , MVC_VIEW_ORDEM, "04")
//	oStruZZ4B:SetProperty("ZZ4_VLDC"  , MVC_VIEW_ORDEM, "05")
//	oStruZZ4B:SetProperty("ZZ4_PESOKG", MVC_VIEW_ORDEM, "06")
	oStruZZ4B:SetProperty('*'  ,MVC_VIEW_CANCHANGE,.F.)
	oStruZZ4B:AddField("ZZ4_MARCA2","01","Item"	   	, "Item"	   			, , "L",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ4B:AddField("ZZ4_VLACOF","05","Valor (R$)", "Valor (R$)"	, , "N","@E 9,999,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStruZZ4B:AddField("ZZ4_PESACF","06","Peso (Kg)"	   	, "Peso (Kg)"	   			, , "GET","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oView:SetModel(oModel)
	oView:AddGrid( "PRAA807_ZZ7" , oStruZZ7, /*cLinkID*/ )
	oView:AddGrid( "PRAA807_ZZ4A" , oStruZZ4A, /*cLinkID*/ )
	oView:AddGrid( "PRAA807_ZZ4B" , oStruZZ4B, /*cLinkID*/)
	
	oView:CreateHorizontalBox( "MASTER" , 15,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL" , 85,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	
	oView:createVerticalBox("DETAIL_LEFT", 50,"DETAIL")
	oView:CreateFolder("FOLDER_LEFT","DETAIL_LEFT")
	oView:AddSheet("FOLDER_LEFT",'SHEET_LEFT',"Documentos (Reserva)")
	oView:CreateHorizontalBox("DETAIL_LEFT_FOLDER" , 100,,,"FOLDER_LEFT",'SHEET_LEFT')
	
	oView:createVerticalBox("DETAIL_RIGHT", 50,"DETAIL")
	oView:CreateFolder("FOLDER_RIGHT","DETAIL_RIGHT")
	oView:addSheet("FOLDER_RIGHT",'SHEET_RIGHT',"Documentos associados")
	oView:CreateHorizontalBox("DETAIL_RIGHT_FOLDER" , 100,,,"FOLDER_RIGHT",'SHEET_RIGHT')
	
	oView:SetOwnerView("PRAA807_ZZ7","MASTER")
	oView:SetOwnerView("PRAA807_ZZ4A","DETAIL_LEFT_FOLDER")
	oView:SetOwnerView("PRAA807_ZZ4B","DETAIL_RIGHT_FOLDER")
Return oView

Function A807AACTIVE(oModel)
	Local aAreaZZ7 := (cAliasZZ7)->(getArea())
	Local oModelZZ7 := oModel:GetModel('PRAA807_ZZ7')
	Local aStruZZ7 := oModelZZ7:GetStruct()
	Local nX
	Local nY
	Local aStruz := (cAliasZZ7)->(dbstruct())
	aStruZZ7 := aStruZZ7:AFIELDS

	(cAliasZZ7)->(DbSetOrder(2))
	(cAliasZZ7)->(dbSeek(cValToChar(ZZ7_MARCAD)))
	For nX := 1 To Len(aStruZZ7)
		If (nY := aScan(aStruz,{|x| AllTrim(x[1]) == AllTrim(aStruZZ7[nX][3])})) > 0
			oModelZZ7:LoadValue(aStruZZ7[nX][3],(cAliasZZ7)->(FieldGet(nY)))
		EndIf
	Next nX
	oModelZZ7:SetValue('ZZ7_PESLIQ',oModelZZ7:GetValue('ZZ7_PESDOC'))
	oModelZZ7:SetValue('ZZ7_PESDOC',oModelZZ7:GetValue('ZZ7_PESDOC')+oModelZZ7:GetValue('ZZ7_TAR'))
	A807LDDOC(oModel:GetModel('PRAA807_ZZ4A'))
	A807LDDOC(oModel:GetModel('PRAA807_ZZ4B'),.T.)
RestArea(aAreaZZ7)
Return

Function A807AMARK(cModA,cModB,cFadd,lPerm,cCpoBloq)
	Local oModel := FwModelActive()
	Local oModelA := oModel:GetModel(cModA) //'PRAA807_ZZ4A'
	Local oModelB := oModel:GetModel(cModB)//'PRAA807_ZZ4B'
	Local nLine := oModelA:GetLine()
	Local aStruc := oModelA:GetStruct()//Struct da tabela
	Local aDataBKP := aClone(oModelA:GetData())
	Local nX
	Local nY
	Local nRec := 1
	Default lPerm := 	.T.
	If !Empty(oModelB:GetValue(cFadd))//'ZZD_CNTID'
		oModelB:AddLine(.T.)
	EndIf
	If lPerm
		oModelA:SetNoInsertLine(.F.)
		oModelA:SetNoDeleteLine(.F.)
	EndIf
	For nX := 1 To Len(aStruc:AFIELDS)
		If !(aStruc:AFIELDS[nX][3] $ cCpoBloq) 
			oModelB:LoadValue(aStruc:AFIELDS[nX][3],oModelA:GetValue(aStruc:AFIELDS[nX][3],nLine))
		EndIf
	Next nX
	oModelB:LoadValue('ZZ4_MARCA3',!oModelA:GetValue('ZZ4_MARCA3',nLine))
	
	oModelA:DeleteLine()
	oModelA:ClearData()
	oModelA:InitLine()
	oModelA:GoLine(1)
		
	For nX := 1 To Len(aDataBKP) 
		If nX != nLine
			If nRec > 1
				oModelA:AddLine(.T.)
			EndIf
			For nY:= 1 To Len(aStruc:AFIELDS)
				oModelA:LoadValue(aStruc:AFIELDS[nY][3],aDataBKP[nX][1][1][nY])
			Next nY
			nRec++
		EndIf
	Next nX
	If lPerm
		oModelA:SetNoInsertLine(.T.)
		oModelA:SetNoDeleteLine(.T.)
	EndIf
	oModelA:GoLine(1)
	oModelB:GoLine(1)
Return .T.

Function A807AVLACT(oMod)
	Local aAreaZZ7 := (cAliasZZ7)->(getArea())
	Local nCnt := 0
	Local Status := ''
	(cAliasZZ7)->(DbSetOrder(2))
	(cAliasZZ7)->(dbgotop())
	
	While !(cAliasZZ7)->(Eof())
		If nCnt == 1
			oMod:SetErrorMessage('PRAA807A',,,,'3000','É permitido marcar somente um container para associação com documentos' ,'', nil, nil)
			Return .F.
		EndIf
		If (cAliasZZ7)->(ZZ7_MARCAD)
			nCnt++
			Status := (cAliasZZ7)-> ZZ7_STATUS
		EndIf
	
	(cAliasZZ7)->(dbSkip())
	EndDo
	If nCnt == 0
		oMod:SetErrorMessage('PRAA807A',,,,'3000','É necessário marcar um container antes de associá-lo a um documento' ,'', nil, nil)
		Return .F.
	EndIf
	
	if  Status == '0'
		oMod:SetErrorMessage('PRAA807A',,,,'3000','Não é permitido associar um container com status vazio a um documento' ,'', nil, nil)
		Return .F.
	EndIf
	
RestArea(aAreaZZ7)
Return .T.

Function A807LDDOC(oModel,lFiltra)
	Local cQuery
	Local cAliastmp
	Local aAreaZZ7 := (cAliasZZ7)->(getArea())
	Local aRet := {}
	Local nRec := 1
	Local nX
	Local nY
	Local aStruz
	Local aStruc := oModel:GetStruct()//Struct da tabela
	Local cQueryTMP := ""
	Local cAlsTMP   := ""
	Local cTabela := "tab_tmp_doc_entrada"
	Local res_id  := "a"
	aStruc := aStruc:AFIELDS
	Default lFiltra := .F.
	
	(cAliasZZ7)->(DbSetOrder(2))
	If (cAliasZZ7)->(dbSeek(cValToChar(ZZ7_MARCAD)))
	
	    cQueryTMP := " SELECT a.dent_id  "
		cQueryTMP += " FROM tab_tmp_doc_entrada a "	
		cQueryTMP += " where a.res_id = " + cValToChar((cAliasZZ7)->ZZ7_RESID)
		
		    
		cAlsTMP := GetNextAlias()
					
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQueryTMP)), cAlsTMP, .F., .T.)
		If Empty((cAlsTMP)->dent_id)
		    cTabela := "tab_doc_entrada"
	        res_id  := "e"  
		EndIf
		
		(cAlsTMP)->(dbCloseArea())
	    
	    cQuery :=       "	select " +;
						" e.rrc_id ZZ4_RRCID,                         "+; 
						" a.dent_id ZZ4_DENTID,                         "+;
						"   c.doc_id ZZ4_TPDOC,                        "+;
						"   SUBSTRING (a.dent_id,                      "+;
						"              9,                              "+;
						"              13) ZZ4_NRDC,                   "+;
						"case when c.doc_id = 'NF' then                "+;
						"   SUBSTRING (a.dent_id,                      "+;
						"              6,                              "+;
						"              3) else '' end ZZ4_SRDC,        "+;
						"   a.dent_cif_tot ZZ4_VLDC,                   "+;
						"   a.dent_peso_bruto_tot ZZ4_PESOKG,          "+;
						"   a.dent_cif_tot - coalesce((SELECT SUM(rna.dent_valor_rateio) from tab_reserva_rateio_cnt rna where rna.rrc_id <> coalesce(e.rrc_id,0) and rna.dent_id = a.dent_id),0) ZZ4_VLCOF,          "+;
						"   a.dent_peso_bruto_tot - coalesce((SELECT SUM(rnb.dent_peso_rateio) from tab_reserva_rateio_cnt rnb where rnb.rrc_id <> coalesce(e.rrc_id,0) and rnb.dent_id = a.dent_id),0) ZZ4_PESCOF,          "+;
						"   e.dent_valor_rateio ZZ4_VLACOF,                   "+;
						"   e.dent_peso_rateio ZZ4_PESACF          "+;
						" FROM "+;
						cTabela + " a                       "+;
						" LEFT OUTER JOIN tab_documentos c            "+;
						"   ON c.doc_ordem1 = SUBSTRING (a.dent_id,5,1)"+;
						"left join tab_reserva_rateio_cnt e "+;
						" 	on e.dent_id = a.dent_id "+;
						"	and e.rcnt_id = '" + cValToChar((cAliasZZ7)->ZZ7_RCNTID) +"'  "+;
						" where " +res_id+ ".res_id  = " + cValToChar((cAliasZZ7)->ZZ7_RESID)
		If lFiltra
			cQuery +=        "                 and e.rrc_id is not null "
		Else
			cQuery +=        "                 and e.rrc_id is null "
		EndIf
		cAliasTmp := GetNextAlias()
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAliasTmp,.F.,.T.)
		aStruz := (cAliasTmp)->(dbstruct())
		While!(cAliasTmp)->(Eof())
			If nRec > 1
				oModel:AddLine(.T.)
			EndIf
			For nX := 1 To Len(aStruc)
				If (nY := aScan(aStruz,{|x| AllTrim(x[1]) == AllTrim(aStruc[nX][3])})) > 0
					oModel:LoadValue(aStruc[nX][3],(cAliasTmp)->(FieldGet(nY)))
				EndIf
			Next nX
			nRec++
			(cAliasTmp)->(dbSkip())
		EndDo
		(cAliasTmp)->(dbCloseArea())
	EndIf
	RestArea(aAreaZZ7)
Return

Function A807ABPOS(oModel)
	Local lRet := .T.
	Local nX
	Local oModelZZB := oModel:GetModel('PRAA807_ZZ4B')
	Local oModelZZ7 := oModel:GetModel('PRAA807_ZZ7')
	Local nTam := oModelZZB:Length()


	oModel:GetModel('PRAA807_ZZ4C'):SetValue('ZZC_MARCAD',cValToChar(.T.))
	For nX := 1 To nTam
		If Empty(oModelZZB:GetValue('ZZ4_DENTID',nX))
			Exit
		EndIf
		If oModelZZB:GetValue('ZZ4_VLACOF',nX) == 0
			oModel:SetErrorMessage('PRAA807A',,,,'3000','Valor (R$) não preenchido (Linha ' + cValtochar(nX) + ').' ,'', nil, nil)
			Return .F.
		EndIf
		
		If oModelZZB:GetValue('ZZ4_PESACF',nX) == 0
			oModel:SetErrorMessage('PRAA807A',,,,'3000','Peso (KG) não preenchido (Linha ' + cValtochar(nX) + ').' ,'', nil, nil)
			Return .F.
		EndIf
	Next nX
Return lRet

Function A807ABCOMMIT(oModel)
	Local lRet := .T.
	Local aAreaZZ7 := (cAliasZZ7)->(GetArea())
	lRet := FWFormCommit(oModel, , , , {|oModel| A807ATTS(oModel)},,)
	RestArea(aAreaZZ7)
	If lRet
		dbSelectArea(cAliasZZ7)
		RecLock(cAliasZZ7,.F.)
		(cAliasZZ7)->(dbDelete())
		(cAliasZZ7)->(msunlock())
	EndIf	
Return lRet

Function A807ATTS(oModel) // Dentro do controle de transação protheus
	Local lRet := .T.
	Local aResult
	Local nRegOp
	Local nI
	Local oModelZZD := oModel:GetModel('PRAA807_ZZ4A')
	Local oModelZZC := oModel:GetModel('PRAA807_ZZ4B')
	Local oModelZZ7 := oModel:GetModel('PRAA807_ZZ7')
	Local cErro 
	
	For nI := 1 To oModelZZC:Length()
		nRegOp := sGetRegOp(oModelZZC,nI)
		If nRegOp != 0 .And. !Empty(oModelZZC:GetValue('ZZ4_DENTID',nI))

				aResult := TCSPExec("proc_diu_reserva_rat_cnt_ag",nRegOp,; // @w_operacao	int
									oModelZZC:GetValue('ZZ4_RRCID' ,nI),; // @w_rrc_id	int //adicionar rrcid
									oModelZZ7:GetValue('ZZ7_RESID' ,1),; // @w_res_id	int
									oModelZZ7:GetValue('ZZ7_RCNTID',1),; // @w_Rcnt_id	INT
									oModelZZC:GetValue('ZZ4_DENTID',nI),; // @w_dent_id	varchar	30
									oModelZZC:GetValue('ZZ4_VLACOF'  ,nI),; // @w_dent_valor_rateio	float
									oModelZZC:GetValue('ZZ4_PESACF',nI); // @w_dent_peso_rateio	float
							)

			IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
				cErro := AllTrim(TCSQLError())
				oModel:SetErrorMessage('PRAA807A',,,,,cErro )
				Return .F.
			elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
				cErro := "Ocorreu um erro no processo da gravação da reserva"+Chr(13)+AllTrim(aResult[1])
				oModel:SetErrorMessage('PRAA807A',,,,,cErro )
				Return .F.
			EndIF
		EndIf
	Next nI
	For nI := 1 To oModelZZD:Length()
		nRegOp := 0
		If oModelZZD:GetValue('ZZ4_RRCID',nI) != 0 .And. oModelZZD:GetValue('ZZ4_MARCA3',nI)
			nRegOp := 5
		EndIf
		If nRegOp != 0

				aResult := TCSPExec("proc_diu_reserva_rat_cnt_ag",nRegOp,; // @w_operacao	int
									oModelZZD:GetValue('ZZ4_RRCID' ,nI),; // @w_rrc_id	int //adicionar rrcid
									oModelZZ7:GetValue('ZZ7_RESID' ,1),; // @w_res_id	int
									oModelZZ7:GetValue('ZZ7_RCNTID' ,1),; // @w_Rcnt_id	INT
									oModelZZD:GetValue('ZZ4_DENTID',nI),; // @w_dent_id	varchar	30
									oModelZZD:GetValue('ZZ4_VLACOF'  ,nI),; // @w_dent_valor_rateio	float
									oModelZZD:GetValue('ZZ4_PESACF',nI); // @w_dent_peso_rateio	float
							)

			IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
				cErro := AllTrim(TCSQLError())
				oModel:SetErrorMessage('PRAA807A',,,,,cErro )
				Return .F.
			elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
				cErro := "Ocorreu um erro no processo da gravação da reserva"+Chr(13)+AllTrim(aResult[1])
				oModel:SetErrorMessage('PRAA807A',,,,,cErro )
				Return .F.
			EndIF
		EndIf
	Next nI
Return lRet

Function A807AVLVCF()
	Local oModel := FwModelActive()
	Local oModelB := oModel:GetModel('PRAA807_ZZ4B')
	Local nLine := oModelB:GetLine()
	Local nTam := oModelB:Length()
	Local nX
	Local nSoma := 0
	If !Empty(oModelB:GetValue('ZZ4_NRDC')) .And. oModelB:GetValue('ZZ4_VLACOF') > oModelB:GetValue('ZZ4_VLCOF')
		oModel:SetErrorMessage('PRAA807A',,,,'3000','O Valor (R$) informado ultrapassa o disponível para rateio do documento.' ,'', nil, nil)
		Return .F.
	EndIf
	
	For nX := 1 to nTam
		nSoma += oModelB:GetValue('ZZ4_VLACOF',nX)
	Next nX
	oModel:GetModel('PRAA807_ZZ7'):SetValue('ZZ7_VALDOC',nSoma)
	oModelB:GoLine(nLine)
Return .T.

Function A807AVLPCF()
	Local oModel := FwModelActive()
	Local oModelB := oModel:GetModel('PRAA807_ZZ4B')
	Local nLine := oModelB:GetLine()
	Local nTam := oModelB:Length()	
	Local nX
	Local nSoma := 0
	If !Empty(oModelB:GetValue('ZZ4_NRDC')) .And. oModelB:GetValue('ZZ4_PESACF') > oModelB:GetValue('ZZ4_PESCOF')
		oModel:SetErrorMessage('PRAA807A',,,,'3000','O Peso (Kg) informado ultrapassa o disponível para rateio do documento.' ,'', nil, nil)
		Return .F.
	EndIf
	
	For nX := 1 to nTam
		nSoma += oModelB:GetValue('ZZ4_PESACF',nX)
	Next nX
	oModel:GetModel('PRAA807_ZZ7'):SetValue('ZZ7_PESLIQ',nSoma)
	oModel:GetModel('PRAA807_ZZ7'):SetValue('ZZ7_PESDOC',oModel:GetModel('PRAA807_ZZ7'):GetValue('ZZ7_PESLIQ')+oModel:GetModel('PRAA807_ZZ7'):GetValue('ZZ7_TAR'))
	oModelB:GoLine(nLine)
Return .T.
