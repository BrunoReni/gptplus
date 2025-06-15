#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PRAA806A
	Registro Associação de containers
@author siegklenes.beulke
@since 18/03/2015
@version 1.0

@example
	PRAA806A()
/*/
Function PRAA806A()
	Local aAreaZZ4 := (cAliasZZ4)->(GetArea())
	Private cAliasZZA := ""
	Private cAliasZZB := ""
	
	MontaDados()
	
	FWExecView("Associar container", "PRAA806A", 3,,{||.T.})
	(caliaszz4)->(dbclearfilter())
	RestArea(aAreaZZ4)
Return

Static Function GetStruct(nid)
	Local astru := {{{"ZZA_MARCAD", "C",03, 0}},;
					  {{"ZZB_RRCID" , "N",10, 0},;
					  	{"ZZB_MARCAD", "L",01, 0},;
					   {"ZZB_MARCA2","L",01, 0},;
					   {"ZZB_MARCA3","L",01, 0},;
					   {"ZZB_RCNTID", "N",10, 0},;
					   {"ZZB_CNTID" , "C",11, 0},;
					   {"ZZB_TISO"  , "C",04, 0},;
					   {"ZZB_TPTAM" , "C",02, 0},;
					   {"ZZB_TAR"   , "N",13, 2},;
					   {"ZZB_VAL"   , "N",13, 2},;
					   {"ZZB_PES"   , "N",13, 2}}}
					   
	Default nid := 1
Return astru[nid]

Static Function MontaDados()
	If Empty(cAliasZZA)
		cAliasZZA := GetNextAlias()
		cAliasZZA := CriaTabTmp(GetStruct(),{'ZZA_MARCAD'},cAliasZZA)
	Else
		dbSelectArea(cAliasZZA)
		ZAP
	EndIf
	
	If Empty(cAliasZZB)
		cAliasZZB := GetNextAlias()
		cAliasZZB := CriaTabTmp(GetStruct(2),{'ZZB_CNTID'},cAliasZZB)
	Else
		dbSelectArea(cAliasZZB)
		ZAP
	EndIf
	
	RecLock(cAliasZZA,.T.)
	(cAliasZZA)->ZZA_MARCAD := cValToChar(.T.)
	(cAliasZZA)->(MsUnLock())
	
	
Return
Static Function ModelDef()
	Local oModel
	Local oModelZZ4  := FWLoadModel('PRAA806')
	Local oStruZZ4   := oModelZZ4:GetModelStruct('PRAA806_ZZ4')[3]:OFORMMODELSTRUCT
	Local oStructZZA := FWFormModelStruct():New()
	Local oStructZZB := FWFormModelStruct():New()
	
	oStructZZA:AddTable(cAliasZZA, {'ZZA_MARCAD'},"Registro de documentos")
	oStructZZA:AddIndex(1,'01','ZZA_MARCAD','Indice 1','','',.T.)
	
	//Reserva:
	oStructZZA:AddField("ID"	, "ID reserva", 	"ZZA_MARCAD", "C",03, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZB:AddTable(cAliasZZB, {'ZZB_CNTID'},"Registro de documentos")
	oStructZZB:AddIndex(1,'01','ZZB_CNTID','Indice 1','','',.T.)
	
	oStructZZB:AddField("Item"	    , "Item", 	  "ZZB_MARCAD", "L",01, 0, {||A806AMARK('PRAA806A_ZZB','PRAA806A_ZZC','ZZB_CNTID',,'ZZB_MARCAD|ZZB_MARCA2')/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Item"	    , "Item", 	  "ZZB_MARCA2","L",01, 0, {||A806AMARK('PRAA806A_ZZC','PRAA806A_ZZB','ZZB_CNTID',,'ZZB_MARCAD|ZZB_MARCA2')/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Item"	    , "Item", 	  "ZZB_MARCA3","L",01, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("rrcid"     , "rrcid", "ZZB_RRCID"   , "N",10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Container"	, "Container","ZZB_CNTID" , "C",11, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Container"	, "Container","ZZB_RCNTID" , "N",10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("ISO"	    , "ISO", 	  "ZZB_TISO"  , "C",04, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Tam."	    , "Tam.", 	  "ZZB_TPTAM" , "C",02, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Tara"	    , "Tara", 	  "ZZB_TAR"   , "N",13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Valor (R$)", "Valor (R$)","ZZB_VAL"   , "N",13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZB:AddField("Peso (kg)" , "Peso (kg)", "ZZB_PES"   , "N",13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStruZZ4:Deactivate()
	oStruZZ4:AddField("Containers", "Containers"				, "ZZ4_QTCONT", "N",  13, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,/*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oModel := MPFormModel():New('PRAA806A', /*bPre*/, {|oModel|A806ABPOS(oModel)}, {|oModel|A806ABCOMMIT(oModel)} ,{|| FWFORMCANCEL(SELF)})
	oModel:SetDescription("Registro de documentos")
	
	oModel:AddFields('PRAA806A_ZZA', Nil, oStructZZA,,,)
	oModel:GetModel('PRAA806A_ZZA'):SetDescription("Documento")
	
	oModel:AddGrid('PRAA806_ZZ4','PRAA806A_ZZA',oStruZZ4)
	oModel:GetModel('PRAA806_ZZ4'):SetDescription("Documento")
	
	oModel:AddGrid('PRAA806A_ZZB','PRAA806A_ZZA',oStructZZB,,,,,{|oModel|A806LDCNT(oModel)})
	oModel:GetModel('PRAA806A_ZZB'):SetDescription("Containers (Reserva)")
	
	oModel:AddGrid('PRAA806A_ZZC','PRAA806A_ZZA',oStructZZB,,,,,{|oModel|A806LDCNT(oModel,.T.)})
	oModel:GetModel('PRAA806A_ZZC'):SetDescription("Containers associados")
	
	oModel:SetRelation("PRAA806_ZZ4",{{"cIntToBool(ZZ4_MARCAD)",'ZZA_MARCAD'}},"cValToChar(.T.)+ZZ4_NRDC")
	oModel:SetVldActivate ( { |oMod| A806AVLACT( oMod ) } )
	oModel:SetActivate ( { |oMod| A806ACTIVE( oMod ) } )
	
	oModel:GetModel('PRAA806A_ZZB'):SetOnlyQuery(.T.)
	oModel:GetModel('PRAA806A_ZZB'):SetOptional(.T.)
	oModel:GetModel('PRAA806A_ZZB'):SetNoInsertLine(.T.)
	oModel:GetModel('PRAA806A_ZZB'):SetNoDeleteLine(.T.)
	oModel:GetModel('PRAA806A_ZZC'):SetOnlyQuery(.T.)
//	oModel:GetModel('PRAA806A_ZZC'):SetOptional(.T.)
	oModel:GetModel('PRAA806A_ZZC'):SetNoInsertLine(.T.)
	oModel:GetModel('PRAA806A_ZZC'):SetNoDeleteLine(.T.)
	oModel:SetPrimaryKey({'ZZA_MARCAD'}) 
	
Return oModel

Function A806ACTIVE(oModel)
	Local aAreaZZ4 := nil
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local aStruZZ4 := oModelZZ4:GetStruct()
	Local nX
	Local nY
	Local aStruz := (cAliasZZ4)->(dbstruct())
    Default cAliasZZ4 := nil

	aAreaZZ4 := (cAliasZZ4)->(getArea())

	aStruZZ4 := aStruZZ4:AFIELDS

	(cAliasZZ4)->(DbSetOrder(2))
	(cAliasZZ4)->(dbSeek(cValToChar(ZZ4_MARCAD)))

	For nX := 1 To Len(aStruZZ4)
		If (nY := aScan(aStruz,{|x| AllTrim(x[1]) == AllTrim(aStruZZ4[nX][3])})) > 0
			oModelZZ4:LoadValue(aStruZZ4[nX][3],(cAliasZZ4)->(FieldGet(nY)))
		EndIf
	Next nX
	
	A806LDCNT(oModel:GetModel('PRAA806A_ZZB'))
	A806LDCNT(oModel:GetModel('PRAA806A_ZZC'),.T.)
RestArea(aAreaZZ4)
Return

Function A806AMARK(cModA,cModB,cFadd,lPerm,cCpoBloq,cCpoMarca3,aCpoCopy)
	Local oModel := FwModelActive()
	Local oModelA := oModel:GetModel(cModA) //'PRAA806A_ZZB'
	Local oModelB := oModel:GetModel(cModB)//'PRAA806A_ZZC'
	Local nLine := oModelA:GetLine()
	Local aStruc := oModelA:GetStruct()//Struct da tabela
	Local aDataBKP := aClone(oModelA:GetData())
	Local nX
	Local nY
	Local nRec := 1	
	Default lPerm := 	.T.
	Default cCpoMarca3 := 'ZZB_MARCA3'
	Default aCpoCopy := {} 
	
	if cModA =  "PRAA806A_ZZB"
		if !(Payload1Valid(oModelA:GetValue(cFadd),; 
		                   oModelA:GetValue("ZZB_PES"),; 
		                   (cAliasZZ4)->ZZ4_RESID)) 
			Return .T.
		endif
	endif	
	if cModA =  "PRAA807_ZZ4A"
		if !(Payload2Valid((cAliasZZ7)->ZZ7_CNTID,; 
		                   oModelA:GetValue("ZZ4_PESOKG"),; 
		                   (cAliasZZ7)->ZZ7_RESID,;
		                   oModel:GetModel('PRAA807_ZZ7'):GetValue('ZZ7_PESLIQ'),;//(cAliasZZ7)->ZZ7_PESDOC,;
		                   (cAliasZZ7)->ZZ7_RCNTID; 
		                  ))
			Return .T.
		endif
	endif	
	
	If Empty(oModelA:GetValue(cFadd))
		Return .T.
	EndIf
	If !Empty(oModelB:GetValue(cFadd))//'ZZB_CNTID'
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
	oModelB:LoadValue(cCpoMarca3,!oModelA:GetValue(cCpoMarca3,nLine))
	For nX := 1 To Len(aCpoCopy)
		oModelB:LoadValue(aCpoCopy[nX][1],oModelA:GetValue(aCpoCopy[nX][2]))
	Next nX
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

Function A806AVLACT(oMod)
	Local aAreaZZ4 := (cAliasZZ4)->(getArea())
    Local nCnt := 0

	(cAliasZZ4)->(DbSetOrder(2))
	(cAliasZZ4)->(dbgotop())
	
	While !(cAliasZZ4)->(Eof())
		If nCnt == 1
			oMod:SetErrorMessage('PRAA806A',,,,'3000','É permitido marcar somente um documento para associação com containers' ,'', nil, nil)
			Return .F.
		EndIf
		If (cAliasZZ4)->(ZZ4_MARCAD)
			nCnt++
		EndIf
	
	(cAliasZZ4)->(dbSkip())
	EndDo
	If nCnt == 0
		oMod:SetErrorMessage('PRAA806A',,,,'3000','É necessário marcar um documento antes de associá-lo a um container' ,'', nil, nil)
		Return .F.
	EndIf
	
RestArea(aAreaZZ4)
Return .T.

Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oModel := FWLoadModel('PRAA806A')
	Local oViewZZ4 := FWLoadView('PRAA806')
	Local oStruZZ4 := oViewZZ4:GetViewStruct('PRAA806_ZZ4')
	Local oStructZZB	:= FWFormViewStruct():New()
	Local oStructZZC	:= FWFormViewStruct():New()
	Local nX
	Local nTam
	oStruZZ4:Deactivate()
	For nX := Len(oStruZZ4:AFIELDS) to 1 Step -1
		If !(oStruZZ4:AFIELDS[nX][1] $ "ZZ4_RESERV|ZZ4_TPDOC|ZZ4_SRDC|ZZ4_NRDC|ZZ4_VLDC|ZZ4_PESOKG|ZZ4_DSBEN" )
			oStruZZ4:RemoveField(oStruZZ4:AFIELDS[nX][1])
		EndIf
	Next nX
	oStruZZ4:SetProperty("ZZ4_RESERV" , MVC_VIEW_ORDEM, "01")
	oStruZZ4:SetProperty("ZZ4_TPDOC" , MVC_VIEW_ORDEM, "02")
	oStruZZ4:SetProperty("ZZ4_SRDC" , MVC_VIEW_ORDEM, "03")
	oStruZZ4:SetProperty("ZZ4_NRDC" , MVC_VIEW_ORDEM, "04")
	oStruZZ4:SetProperty("ZZ4_VLDC" , MVC_VIEW_ORDEM, "05")
	oStruZZ4:SetProperty("ZZ4_PESOKG" , MVC_VIEW_ORDEM, "06")
	oStruZZ4:SetProperty("ZZ4_DSBEN" , MVC_VIEW_ORDEM, "08")
	
	oStruZZ4:AddField("ZZ4_QTCONT" ,"07","Containers"	, "Containers"				, , "N",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStruZZ4:SetProperty('*'  ,MVC_VIEW_CANCHANGE,.F.)
	
	oStructZZB:AddField("ZZB_MARCAD" ,"01","Item"	   	, "Item"	   			, , "L",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZB:AddField("ZZB_CNTID"  ,"02","Container"	, "Container"			, , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZB:AddField("ZZB_TISO"   ,"03","ISO"	   	, "ISO"	   				, , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZB:AddField("ZZB_TPTAM"  ,"04","Tam."	   	, "Tam."	   			, , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStructZZC:AddField("ZZB_MARCA2" ,"01","Item"	   	, "Item"	   			, , "L",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZC:AddField("ZZB_CNTID"  ,"02","Container"	, "Container"			, , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZC:AddField("ZZB_TISO"   ,"03","ISO"	   	, "ISO"	   				, , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZC:AddField("ZZB_TPTAM"  ,"04","Tam."	   	, "Tam."	   			, , "C",""/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZC:AddField("ZZB_TAR"   ,"05","Tara"     , "Tara"   			, , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZC:AddField("ZZB_VAL"   ,"06","Valor (R$)", "Valor (R$)"   	, , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZC:AddField("ZZB_PES"   ,"07","Peso (kg)", "Peso (kg)"	   		, , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/ ,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oView:SetModel(oModel)
	oView:AddGrid( "PRAA806_ZZ4" , oStruZZ4, /*cLinkID*/ )
	oView:AddGrid( "PRAA806A_ZZB" , oStructZZB, /*cLinkID*/ )
	oView:AddGrid( "PRAA806A_ZZC" , oStructZZC, /*cLinkID*/)
	
	oView:CreateHorizontalBox( "MASTER" , 15,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL" , 85,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	
	oView:createVerticalBox("DETAIL_LEFT", 40,"DETAIL")
	oView:CreateFolder("FOLDER_LEFT","DETAIL_LEFT")
	oView:addSheet("FOLDER_LEFT",'SHEET_LEFT',"Containers (Reserva)")
	nTam := 60
//	oView:CreateHorizontalBox("DETAIL_LEFT_UP" , nTam,,.T.,"FOLDER_LEFT",'SHEET_LEFT')
	oView:CreateHorizontalBox("DETAIL_LEFT_DOWN" , 100,,,"FOLDER_LEFT",'SHEET_LEFT')
	
	oView:createVerticalBox("DETAIL_RIGHT", 60,"DETAIL")
	oView:CreateFolder("FOLDER_RIGHT","DETAIL_RIGHT")
	oView:addSheet("FOLDER_RIGHT",'SHEET_RIGHT',"Containers associados")
	oView:CreateHorizontalBox("DETAIL_RIGHT_UP" , nTam,,.T.,"FOLDER_RIGHT",'SHEET_RIGHT')
	oView:CreateHorizontalBox("DETAIL_RIGHT_DOWN" , 100,,,"FOLDER_RIGHT",'SHEET_RIGHT')
	
//	oView:AddOtherObject("DETAIL_LEFT_UP_BUTTONS", {|oPanel, oObj| A806ABTN(oPanel, oObj)},,{|oPanel| })
	oView:AddOtherObject("DETAIL_RIGHT_UP_BUTTONS", {|oPanel, oObj| A806ABTND(oPanel, oObj)},,{|oPanel| })
		
	oView:SetOwnerView("PRAA806_ZZ4","MASTER")
//	oView:SetOwnerView("DETAIL_LEFT_UP_BUTTONS","DETAIL_LEFT_UP")
	oView:SetOwnerView("DETAIL_RIGHT_UP_BUTTONS","DETAIL_RIGHT_UP")
	oView:SetOwnerView("PRAA806A_ZZB","DETAIL_LEFT_DOWN")
	oView:SetOwnerView("PRAA806A_ZZC","DETAIL_RIGHT_DOWN")
	oView:AddUserButton( "Cadastro de Containes", 'CLIPS', { |oModel| PRAA807(),A806ARLD(oModel) } )
Return oView

Function A806ABTN(oPanel,oObj)
	Local nTamA := 6
	Local nTamB := 6
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP
	
	nTamA := 5
	nTamB := 5
	
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_RIGHT
	
	nTamA := 6
	nTamB := 6
	
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_BOTTOM
	
//	oButtonExc   :=tButton():New(5,5,'Excluír',oPanel,{|| A806RAT()},30,10,,,,.T.)
//	oButtonExc:Align := CONTROL_ALIGN_RIGHT
	
	nTamA := 5
	nTamB := 5
	
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_RIGHT
	
	oButtonOK :=tButton():New(5,5,"Incluir",oPanel,{||PRAA807()},30,10,,,,.T.)
	oButtonOK:Align := CONTROL_ALIGN_RIGHT
	
Return
Function A806ABTND(oPanel,oObj)
	Local nTamA := 6
	Local nTamB := 6
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP
	
	nTamA := 5
	nTamB := 5
	
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_RIGHT
	
	nTamA := 6
	nTamB := 6
	
	oPnlA := tPanel():New(00,00,,oPanel,,,,,,nTamA,nTamB,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_BOTTOM
	
	oButtonExc   :=tButton():New(5,5,'Rateio automático',oPanel,{|| A806RAT()},52,10,,,,.T.)
	oButtonExc:Align := CONTROL_ALIGN_RIGHT
		
Return

Function A806LDCNT(oModel,lFiltra)
	Local cQuery
	Local cAliastmp
	Local aAreaZZ4 := (cAliasZZ4)->(getArea())
	Local aRet := {}
	Local nRec := 1
	Local nX
	Local nY
	Local aStruz
	Local aStruc := oModel:GetStruct()//Struct da tabela
	aStruc := aStruc:AFIELDS
	Default lFiltra := .F.

	(cAliasZZ4)->(DbSetOrder(2))
	If (cAliasZZ4)->(dbSeek(cValToChar(ZZ4_MARCAD)))

//		Select * from tab_tmp_container where res_id = x.
		cQuery := 		   "	select isnull(a.cnt_id,'') ZZB_CNTID, "
		cQuery += 			"		    isnull(a.tiso_id,'') ZZB_TISO, "
		cQuery += 			"		    isnull(a.cnt_tara,0) ZZB_TAR, "
		cQuery += 			"		    b.rcnt_id ZZB_RCNTID, "
		cQuery += 			"			       d.tiso_tamanho ZZB_TPTAM, "
		cQuery += 			"			       e.rrc_id		 ZZB_RRCID, "
		cQuery += 			"			       e.dent_valor_rateio ZZB_VAL, "
		cQuery += 			"			       e.dent_peso_rateio  ZZB_PES "
		cQuery += 			"			       from tab_container a "
		cQuery += 			"			       inner join tab_reserva_container b "
		cQuery += 			"			       on b.cnt_id = a.cnt_id "
		cQuery += 			"			       inner join tab_reserva_programacao f "
		cQuery += 			"			       on f.trp_id = b.trp_id "
		cQuery += 			"			       and f.esp_id = 'CC' "
		cQuery += 			"			       and f.res_id = " + cValToChar((cAliasZZ4)->ZZ4_RESID)
		cQuery += 			"			       and IsNull(f.trp_cnt_cheio,0) = 1 "
		cQuery += 			"				       left join tab_tipo_iso d "
		cQuery += 			"				       on d.tiso_id  = a.tiso_id"
		cQuery += 			"				       left join tab_reserva_rateio_cnt e "
		cQuery += 			"				       on e.dent_id  = '" + (cAliasZZ4)->ZZ4_DENTID +"'"
		cQuery +=			"						and e.rcnt_id =        b.rcnt_id  "
		cQuery +=			"						and e.res_id = " + cValToChar((cAliasZZ4)->ZZ4_RESID)
		If lFiltra
			cQuery +=        "    where              e.rrc_id is not null "
		Else
			cQuery +=        "    where              e.rrc_id is null "
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
	RestArea(aAreaZZ4)
Return

Function A806RAT()
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local oModelZZC := oModel:GetModel('PRAA806A_ZZC')
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local nTam := oModelZZC:Length()
	Local nX
	Local nLine := oModelZZC:GetLine()
	Local aSoma := {0,0}
	Local cCNTID := oModelZZC:GetValue('ZZB_CNTID')
	
	If Empty(AllTrim(cCNTID))
	     MSGAlert('Para efetuar o rateio é necessário que a aba "Containers associados" possua registro(s).')
		 Return .F. 
	Else
		For nX := 1 To nTam
			oModelZZC:GoLine(nX)
			oModelZZC:LoadValue('ZZB_VAL',oModelZZ4:GetValue('ZZ4_VLDC')/nTam)
			oModelZZC:LoadValue('ZZB_PES',oModelZZ4:GetValue('ZZ4_PESOKG')/nTam)
			aSoma[1]+= oModelZZC:GetValue('ZZB_VAL')
			aSoma[2]+= oModelZZC:GetValue('ZZB_PES')
		Next nX
		
		If aSoma[1] != oModelZZ4:GetValue('ZZ4_VLDC')
			aSoma[1] := oModelZZ4:GetValue('ZZ4_VLDC') - aSoma[1]
			oModelZZC:LoadValue('ZZB_VAL',oModelZZC:GetValue('ZZB_VAL')+aSoma[1])
		EndIf
		
		If aSoma[2] != oModelZZ4:GetValue('ZZ4_PESOKG')
			aSoma[2] := oModelZZ4:GetValue('ZZ4_PESOKG') - aSoma[2]
			oModelZZC:LoadValue('ZZB_PES',oModelZZC:GetValue('ZZB_PES')+aSoma[2])
		EndIf
		
		oModelZZC:GoLine(nLine)
		If !Empty(oView) .And. oView:lActivate
			oView:refresh()
		EndIf
	EndIf
Return

Function A806ABPOS(oModel)
	Local lRet := .T.
	Local oModelZZC := oModel:GetModel('PRAA806A_ZZC')
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local nX
	Local aSoma := {0,0}
	Local lEmpty := .F.
	For nX := 1 To oModelZZC:Length()
		lEmpty := Empty(oModelZZC:GetValue('ZZB_CNTID',nX))
		If lEmpty
			Exit
		EndIf
		If oModelZZC:GetValue('ZZB_VAL',nX) == 0
			oModel:SetErrorMessage('PRAA806A',,,,'3000','Valor (R$) não preenchido (Linha ' + cValtochar(nX) + ').' ,'', nil, nil)
			Return .F.
		EndIf
		aSoma[1]+= oModelZZC:GetValue('ZZB_VAL',nX)
		
		If oModelZZC:GetValue('ZZB_PES',nX) == 0
			oModel:SetErrorMessage('PRAA806A',,,,'3000','Peso (KG) não preenchido (Linha ' + cValtochar(nX) + ').' ,'', nil, nil)
			Return .F.
		EndIf
		aSoma[2]+= oModelZZC:GetValue('ZZB_PES',nX)
	Next nX
	If !lEmpty
		If aSoma[1] != oModelZZ4:GetValue('ZZ4_VLDC',1)
			oModel:SetErrorMessage('PRAA806A',,,,'3000','A soma do valor rateado não corresponde com o valor do documento.' ,'', nil, nil)
			Return .F.
		EndIf
		
		If aSoma[2] != oModelZZ4:GetValue('ZZ4_PESOKG',1)
			oModel:SetErrorMessage('PRAA806A',,,,'3000','A soma do peso rateado não corresponde com o peso do documento.' ,'', nil, nil)
			Return .F.
		EndIf
	EndIf
	oModel:GetModel('PRAA806A_ZZA'):SetValue('ZZA_MARCAD',cValToChar(.T.))
aSize(aSoma,0)
Return lRet

Function A806ABCOMMIT(oModel)
    Local lRet := .T.
	Local aAreazz4 := (cAliasZZ4)->(GetArea())	
	
	lRet := FWFormCommit(oModel, , , , {|oModel| A806ATTS(oModel)},,)
	RestArea(aAreazz4)
	If lRet
		dbSelectArea(cAliasZZ4)
		RecLock(cAliasZZ4,.F.)
		(cAliasZZ4)->(dbDelete())
		(cAliasZZ4)->(msunlock())
	EndIf	
Return lRet

Function A806ATTS(oModel) // Dentro do controle de transação protheus
	Local lRet := .T.
	Local aResult
	Local nRegOp
	Local nI
	Local oModelZZB := oModel:GetModel('PRAA806A_ZZB')
	Local oModelZZC := oModel:GetModel('PRAA806A_ZZC')
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cErro 
	
	For nI := 1 To oModelZZC:Length()
		nRegOp := sGetRegOp(oModelZZC,nI)
		If nRegOp != 0 .And. !Empty(oModelZZC:GetValue('ZZB_CNTID',nI))
			aResult := TCSPExec("proc_diu_reserva_rat_cnt_ag",nRegOp,; // @w_operacao	int
								oModelZZC:GetValue('ZZB_RRCID',nI),; // @w_rrc_id	int //adicionar rrcid
								oModelZZ4:GetValue('ZZ4_RESID',1),; // @w_res_id	int
								oModelZZC:GetValue('ZZB_RCNTID',nI),; // @w_rcnt_id	int 	11
								oModelZZ4:GetValue('ZZ4_DENTID',1),; // @w_dent_id	varchar	30
								oModelZZC:GetValue('ZZB_VAL',nI),; // @w_dent_valor_rateio	float
								oModelZZC:GetValue('ZZB_PES',nI); // @w_dent_peso_rateio	float
						)
			IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
				cErro := AllTrim(TCSQLError())
				oModel:SetErrorMessage('PRAA806A',,,,,cErro )
				Return .F.
			elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
				cErro := "Ocorreu um erro no processo da gravação da reserva"+Chr(13)+AllTrim(aResult[1])
				oModel:SetErrorMessage('PRAA806A',,,,,cErro )
				Return .F.
			EndIF
		EndIf
	Next nI
	For nI := 1 To oModelZZB:Length()
		nRegOp := 0
		If oModelZZB:GetValue('ZZB_RRCID',nI) != 0 .And. oModelZZB:GetValue('ZZB_MARCA3',nI)
			nRegOp := 5
		EndIf
		If nRegOp != 0
			aResult := TCSPExec("proc_diu_reserva_rat_cnt_ag",nRegOp,; // @w_operacao	int
								oModelZZB:GetValue('ZZB_RRCID',nI),; // @w_rrc_id	int //adicionar rrcid
								oModelZZ4:GetValue('ZZ4_RESID',1),; // @w_res_id	int
								oModelZZB:GetValue('ZZB_RCNTID',nI),; // @w_rcnt_id	int
								oModelZZ4:GetValue('ZZ4_DENTID',1),; // @w_dent_id	varchar	30
								oModelZZB:GetValue('ZZB_VAL',nI),; // @w_dent_valor_rateio	float
								oModelZZB:GetValue('ZZB_PES',nI); // @w_dent_peso_rateio	float
						)
			IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
				cErro := AllTrim(TCSQLError())
				oModel:SetErrorMessage('PRAA806A',,,,,cErro )
				Return .F.
			elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
				cErro := "Ocorreu um erro no processo da gravação da reserva "+Chr(13)+AllTrim(aResult[1])
				oModel:SetErrorMessage('PRAA806A',,,,,cErro )
				Return .F.
			End IF
		EndIf
	Next nI
Return lRet

Function sGetRegOp(oModel,nX)
	Local nRegOp := 0 // Sem alteração
	Default nX := oModel:GetLine()
	
	If !oModel:IsDeleted(nX) .And. oModel:IsInserted(nX) // Inserção
       nRegOp := 3
    ElseIf !oModel:IsDeleted(nX) .And. !oModel:IsInserted(nX) .And. oModel:IsUpdated(nX)// Atualização
    	nRegOp := 4
    ElseIf oModel:IsDeleted(nX) .And. !oModel:IsInserted(nX) // Exclusão
    	nRegOp := 5
    EndIf
Return nRegOp

Function A806ARLD(oModel)
	Local oModelA := oModel:GetModel("PRAA806A_ZZB")
		
	oModelA:SetNoInsertLine(.F.)
	oModelA:SetNoDeleteLine(.F.)
	oModelA:DeleteLine()
	oModelA:ClearData()
	oModelA:InitLine()
	oModelA:GoLine(1)
	A806LDCNT(oModelA)
	oModelA:SetNoInsertLine(.T.)
	oModelA:SetNoDeleteLine(.T.)
	
Return


/*/{Protheus.doc} cIntToBool
Função que transforma Inteiro em char boolean
@author TOTVS
@since 08/03/2017
@version 1.0
@example
	cIntToBool(1)
/*/
function cIntToBool(IntVal)
	If IntVal == 1
		Return cValtoChar(.T.)
	Else
		Return cValtoChar(.F.)
	EndIf
Return

function Payload1Valid(aCntId, aPeso, aResId, aPesoDocumental)
	Local oPayload := SRPayload():New()
	Local cQryPayload 
	Local cPesoDocumental := 0
	Local cRCntId
	Local _Result := .T.

	ResId := cValToChar(aResId)	
	cQryPayload := oPayload:QryPayload(ResId, aCntId) 
	if aPesoDocumental = nil	
		cPesoDocumental := cQryPayload:FieldByName(PesoDocumental)
	else
		cPesoDocumental := aPesoDocumental
	endif
	//PesoCnt := cQryPayload:FieldByName(ContainerSuporta)	
	cRCntId := cQryPayload:FieldByName(RCNTID)
	
	/*if PesoCnt = 0
		cErro := "Container "+aCntId+" está com payload inválido! Corrija o cadastro do container!" + Chr(13) + Chr(10)
		MessageBox(cErro, "Erro cadastro container", 48)
		Return .F.
	endif	
	
	if (PesoDocumental + aPeso) > PesoCnt
		cErro := "O peso ultrapassa o payload para o Container" + Chr(13) + Chr(10)
		cErro := cErro + oPayload:ListDocStr(cRCntId) + Chr(13) + Chr(10)
		cErro := cErro + '-----------------------------' + Chr(13) + Chr(10)
		cErro := cErro + 'Peso documental já inserido: ' + cValtoChar(cPesoDocumental) +Chr(13) + Chr(10)
		cErro := cErro + 'Este container suporta: ' + cValtoChar(PesoCnt) + Chr(13) + Chr(10)
		cErro := cErro + 'Você está acrescentando: ' + cValtoChar(aPeso) + Chr(13) + Chr(10)
		MessageBox(cErro, "Payload", 48)
		Return .F.
	endif
	*/
	_Result := Payload2Valid(aCntId, aPeso, aResId, cPesoDocumental, cRCntId)
	cQryPayload:Destroy()
	oPayload:Destroy()
Return _Result

function Payload2Valid(aCntId, aPeso, aResId, aPesoDocumental, aRCntId)
	Local PesoCnt := 0
	Local oPayload := SRPayload():New()
	local _Result := .T.
	
	ResId := cValToChar(aResId)		
	PesoCnt := oPayload:Container(aCntId)
	if PesoCnt = 0
		cErro := "Container "+aCntId+" está com payload inválido! Corrija o cadastro do container!" + Chr(13) + Chr(10)
		MessageBox(cErro, "Erro cadastro container", 48)
		Return .F.
	endif	
	
	if (aPesoDocumental + aPeso) > PesoCnt
		cErro := "O peso ultrapassa o payload para o Container" + Chr(13) + Chr(10)
		cErro := cErro + oPayload:ListDocStr(aRCntId) + Chr(13) + Chr(10)
		cErro := cErro + '-----------------------------' + Chr(13) + Chr(10)
		cErro := cErro + 'Peso documental já inserido: ' + cValtoChar(aPesoDocumental) +Chr(13) + Chr(10)
		cErro := cErro + 'Este container suporta: ' + cValtoChar(PesoCnt) + Chr(13) + Chr(10)
		cErro := cErro + 'Você está acrescentando: ' + cValtoChar(aPeso) + Chr(13) + Chr(10)
		MessageBox(cErro, "Payload", 48)
		Return .F.
	endif
	oPayload:Destroy()
Return _Result

