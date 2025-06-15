#Include "Protheus.ch"
#Include "FwMVCDEF.ch"
#Include "TECA998.ch"

Static oFWSheet
Static oModel740

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA998
Planilha de cálculo no orçamento de serviços
@sample 	TECA998() 
@param		oModel -> Objeto do modelo
@since		22/10/2013       
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function TECA998(oModel,oView)

Local oMdlRh	:= Nil 
Local oMdlLE	:= Nil
Local cManip	:= ""
Local cRet		:= ""
Local cModelo	:= ""
Local oDlg
Local oOpcao
Local oBtn
Local nOpcao	:= 1
Local nOpcOk	:= 0
Local lLocEq	:= .F. 
Local lOk := .T.
Local lFacilit := IsInCallStack("At984aPlPc")
Local aModPla := {.F.,""}
Local lRet	:= .F.
Local lOrcSrv := At998Orc()
Default oView := Nil

If lFacilit
	oMdlRh	:= oModel:GetModel("TXSDETAIL")
Else
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	If isInCallStack("At870GerOrc")
		If oMdlRh:GetValue("TFF_COBCTR") != "2"
			//Manipular Planilha de item cobrado dentro da rotina de Item Extra
			lOk := .F.
			Help(,, "AT998COBCTR1",,STR0016,1,0,,,,,,{STR0017}) //"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf
	Else
		If oMdlRh:GetValue("TFF_COBCTR") == "2"
			//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
			lOk := .F.
			Help(,, "AT998COBCTR2",,STR0018,1,0,,,,,,{STR0019}) //"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)" 
		EndIf
	EndIf
Endif

If lOk

	If oView <> Nil .And. !lFacilit
		lLocEq := Upper(oView:GetFolderActive('ABAS', 2)[2]) == STR0014 // 'LOCAÇÃO DE EQUIPAMENTOS'
	EndIf
	
	If !lLocEq
		If lFacilit
			cManip := oMdlRh:GetValue("TXS_CALCMD")
			cRet := oMdlRh:GetValue("TXS_PLACOD") + oMdlRh:GetValue("TXS_PLAREV")
		Else
			cManip := oMdlRh:GetValue("TFF_CALCMD")
			cRet := oMdlRh:GetValue("TFF_PLACOD") + oMdlRh:GetValue("TFF_PLAREV")
		Endif
	Else	
		cManip		:= oMdlLE:GetValue("TFI_CALCMD")
		cRet 		:= oMdlLE:GetValue("TFI_PLACOD") + oMdlLE:GetValue("TFI_PLAREV")
	EndIf
	
	oModel740 := oModel
	
	DEFINE DIALOG oDlg TITLE STR0001 FROM 00,00 TO 110,130 PIXEL //"Planilha"
		oDlg:LEscClose	:= .F.
		oOpcao				:= TRadMenu():New(05,05,{STR0002,STR0003,STR0004},,oDlg,,,,,,,,45,40,,,,.T.) //'Manipular'#'Executar'#'Novo Modelo'
		oOpcao:bSetGet	:= {|x|IIf(PCount()==0,nOpcao,nOpcao:=x)}
		oBtn				:= TButton():New(35,05,STR0005,oDlg,{|| nOpcOk := 1, nOpcao, oDlg:End()},60,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //'Confirmar'
	ACTIVATE DIALOG oDlg CENTERED
	
	If	nOpcOk == 1
		If Empty(cManip) .OR. nOpcao == 3 .OR. nOpcao == 2

			If (lFacilit .And. nOpcao == 3) .Or. (nOpcao == 3 .And. lOrcSrv)
				aModPla	:= At998InPl()
			Else
				aModPla	:= At998ConsP(cRet)
			Endif
			lRet := aModPla[1]
			cRet := aModPla[2]
			If lRet
				DbSelectArea("ABW")
				DbSetOrder(1) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
				If ABW->(DbSeek(xFilial("ABW")+cRet))
					cModelo := ABW->ABW_INSTRU
					If nOpcao == 1 .OR. nOpcao == 3
						At998MdPla(cModelo,oModel,lLocEq, cRet)
					Else
						At998ExPla(cModelo,oModel,lLocEq, cRet)
					EndIf	
				EndIf
			EndIf
		Else
			If nOpcao == 1
				At998MdPla(cManip,oModel,lLocEq, cRet)
			Else
				At998ExPla(cManip,oModel,lLocEq, cRet)
			EndIf
		EndIf	
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998MdPla()

Monta a Planilha de cálculo para manipulação. 

@sample 	At998MdPla() 

@param		cXml, Caracter, Conteúdo do XML
			oModel, Object, Classe do modelo de dados MpFormModel   
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998MdPla(cXml,oModel,lLocEq, cCodRev)

Local oFWLayer 
Local oDlg
Local aSize	 		:= FWGetDialogSize( oMainWnd ) 	
Local oWinPlanilha
Local aCelulasBlock := At998Atrib()
Local cTpModelo		:= ABW->ABW_TPMODP
Local aNickBloq		:= {"TOTAL_RH","TOTAL_MAT_CONS","TOTAL_MAT_IMP","LUCRO", "TOTAL_ABATE_INS"}
Local oMdlRh		:= Nil 
Local oMdlVA        := Nil
Local nTotMI		:= 0 
Local nTotMC		:= 0
Local nTotUnif		:= 0
Local nTotArma		:= 0
Local bExpor		:= {|| TECA997(oFWSheet) }
Local lFacilit 		:= IsInCallStack("At984aPlPc")
Local lOrcSrv 		:= At998Orc()
Local nTamCpoCod 	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev 	:= TamSX3("TFF_PLAREV")[1]
Local nTotVer       := 0
Local nPercISS		:= 0
Local cDescPrd		:= Space(30)
Local cDescEsc 		:= Space(30)
Local cDescFunc 	:= Space(30)
Local oDscPrdRh		
Local oDscEscal
Local oDscFunc
Local oWinCampos	
Local cInsalub		:= "1"
Local cDscInsa		:= x3Combo("TFF_INSALU",cInsalub)
Local cGrauInsalub  := "1"
Local cDscGrau		:= x3Combo("TFF_GRAUIN",cGrauInsalub)
Local cPericulo		:= "1"
Local cDscPeric		:= x3Combo("TFF_PERICU",cPericulo)
Default cCodRev 	:= ""

If lFacilit
	oMdlRh	:= oModel:GetModel("TXSDETAIL")
	oMdlVA  := oModel:GetModel("TXXDETAIL")
	nTotMI	:= oMdlRh:GetValue("TXS_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TXS_TOTMC")	
	nTotUnif:= oMdlRh:GetValue("TXS_TOTUNI")
	nTotArma:= oMdlRh:GetValue("TXS_TOTARM")
	nTotVer := At998Verba(oMdlVA) 
	cDescPrd := SubStr(oMdlRh:GetValue("TXS_DESCRI"),1,30)
	cDescEsc := SubStr(oMdlRh:GetValue("TXS_DSCESC"),1,30)
	cDescFunc := SubStr(oMdlRh:GetValue("TXS_DESFUN"),1,30)
	If TXS->( ColumnPos('TXS_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TXS_INSALU")
		cDscInsa := x3Combo("TXS_INSALU",cInsalub)
	Endif
	If TXS->( ColumnPos('TXS_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TXS_GRAUIN")
		cDscGrau :=  x3Combo("TXS_GRAUIN",cGrauInsalub)
	Endif
	If TXS->( ColumnPos('TXS_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TXS_PERICU")
		cDscPeric := x3Combo("TXS_PERICU",cPericulo)
	Endif
Else
	oMdlRh	:= oModel:GetModel("TFF_RH")
	nTotMI	:= oMdlRh:GetValue("TFF_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TFF_TOTMC")
	oMdlBen := oModel:GetModel("ABP_BENEF")
	nTotVer := At998Verb(oMdlBen) 
	If lOrcSrv
		nTotUnif:= oMdlRh:GetValue("TFF_TOTUNI")
		nTotArma:= oMdlRh:GetValue("TFF_TOTARM")		
		nPercISS := At998GtISS(oModel:GetValue("TFL_LOC","TFL_LOCAL"),oModel:GetValue("TFF_RH","TFF_PRODUT"))
	Endif
	cDescPrd := SubStr(oMdlRh:GetValue("TFF_DESCRI"),1,30)
	cDescEsc := SubStr(oMdlRh:GetValue("TFF_NOMESC"),1,30)
	cDescFunc := SubStr(oMdlRh:GetValue("TFF_DFUNC"),1,30)
	If TFF->( ColumnPos('TFF_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TFF_INSALU")
		cDscInsa := x3Combo("TFF_INSALU",cInsalub)
	Endif
	If TFF->( ColumnPos('TFF_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TFF_GRAUIN")
		cDscGrau :=  x3Combo("TFF_GRAUIN",cGrauInsalub)
	Endif
	If TFF->( ColumnPos('TFF_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TFF_PERICU")
		cDscPeric := x3Combo("TFF_PERICU",cPericulo)
	Endif
Endif

DEFINE DIALOG oDlg TITLE STR0006 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL //"Planilha Preço"

	oFWLayer := FWLayer():New()
	oFWLayer:init( oDlg, .T. )
	oFWLayer:addLine( "Lin01", 15, .T. )	
	oFWLayer:addCollumn("Col01", 100, .T., "Lin01" )
	oFWLayer:addWindow("Col01", "Win01", STR0026, 100, .f., .f., {||  },"Lin01" ) //"Informações do Posto"

	oWinCampos := oFWLayer:getWinPanel("Col01", "Win01","Lin01" )

	@  4,0.01 SAY STR0027 Of oWinCampos PIXEL SIZE 45, 08 //"Descr. Prod RH:"
	@  1,40.01 GET oDscPrdRh VAR cDescPrd Picture PesqPict('TFF','TFF_DESCRI') WHEN .F. OF oWinCampos PIXEL

	@  4,225.01 SAY STR0028 Of oWinCampos PIXEL SIZE 45, 08 //"DesEscalacr. :"
	@  1,262.01 GET oDscEscal VAR cDescEsc Picture PesqPict('TFF','TFF_NOMESC') WHEN .F. OF oWinCampos PIXEL

	@  4,446.01 SAY STR0029 Of oWinCampos PIXEL SIZE 45, 08 //"Descr. Função:"
	@  1,479.01 GET oDscFunc VAR cDescFunc Picture PesqPict('TFF','TFF_DFUNC') WHEN .F. OF oWinCampos PIXEL

	oFWLayer:addLine( "Lin02", 85, .T. )
	oFWLayer:setLinSplit( "Lin02", CONTROL_ALIGN_BOTTOM, {|| } )
	oFWLayer:addCollumn("Col01", 100, .T., "Lin02" )
	oFWLayer:addWindow("Col01", "Win02", STR0001, 100,.F., .f., {|| Nil },"Lin02" ) //'Planilha'

	oWinPlanilha := oFWLayer:getWinPanel("Col01"	, "Win02" ,"Lin02")

//---------------------------------------
// PLANILHA
//---------------------------------------
oFWSheet := FWUIWorkSheet():New(oWinPlanilha)
IF At680Perm(NIL, __cUserId, "067", .T.)
	oFWSheet:AddItemMenu(STR0007,bExpor) //'Exportar para Excel'
Endif
oFwSheet:SetMenuVisible(.T.,STR0008,50) //"Ações"

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If !Empty(cXml) 
	If isBlind()
		oFWSheet:LoadXmlModel(cXml)
	Else
		FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, STR0020)//"Carregando..."
	EndIf
EndIf
If lFacilit .Or. lOrcSrv
	If oFWSheet:CellExists("TOTAL_MI")
		oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MC")
		oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
	EndIf
	If oFWSheet:CellExists("TOTAL_UNIF")
		oFWSheet:SetCellValue("TOTAL_UNIF", nTotUnif)
	EndIf
	If oFWSheet:CellExists("TOTAL_ARMA")
		oFWSheet:SetCellValue("TOTAL_ARMA", nTotArma)
	EndIf
	If oFWSheet:CellExists("TOTAL_VERBAS")
		oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
	EndIf
	If nPercISS > 0 .And. oFWSheet:CellExists("IMPOSTO_ISS")
		oFWSheet:SetCellValue("IMPOSTO_ISS", nPercISS)
	Endif
	If oFWSheet:CellExists("PARAM_INSALUB")
		oFWSheet:SetCellValue("PARAM_INSALUB",cInsalub )
	Endif
	If oFWSheet:CellExists("DESC_INSALUB")
		oFWSheet:SetCellValue("DESC_INSALUB",cDscInsa )
	Endif
	If oFWSheet:CellExists("PARAM_GRAUINSALUB")
		oFWSheet:SetCellValue("PARAM_GRAUINSALUB", cGrauInsalub )
	Endif
	If oFWSheet:CellExists("DESC_GRAU")
		oFWSheet:SetCellValue("DESC_GRAU", cDscGrau )
	Endif
	If oFWSheet:CellExists("PARAM_PERICULOSO")
		oFWSheet:SetCellValue("PARAM_PERICULOSO",cPericulo )
	Endif
	If oFWSheet:CellExists("DESC_PERICU")
		oFWSheet:SetCellValue("DESC_PERICU",cDscPeric )
	Endif
Else
	If oFWSheet:CellExists("TOTAL_MAT_IMP")
		oFWSheet:SetCellValue("TOTAL_MAT_IMP", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MAT_CONS")
		oFWSheet:SetCellValue("TOTAL_MAT_CONS", nTotMC)
	EndIf	
Endif
//.T. serão bloqueadas as celulas que NÃO estão no array passado aCells 
//.F. serão bloqueadas as celulas que estão no array passado aCells 
If cTpModelo == "1"
	oFWSheet:SetCellsBlock(aCelulasBlock, .T.) //'Lista Liberada'
Else
	oFWSheet:SetCellsBlock(aCelulasBlock, .F.) //'Lista bloqueada' 
EndIf

oFwSheet:SetNamesBlock(aNickBloq)

oFWSheet:Refresh(.T.)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||At998Grv(oModel,lLocEq,cCodRev),oDlg:End()},{||oDlg:End()})
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Atrib()

Atribui as células gravadas na lista do modelo da planilha 

@sample 	At998Atrib() 

@return	aCel-> Array, Contém células gravadas na lista. 

@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998Atrib()

Local aArea := GetArea()
Local aCell := {}

DbSelectArea("ABW")
DbSetOrder(1)

If ABW->(DbSeek(xFilial("ABW")+ABW->(ABW_CODIGO+ABW_REVISA)))
	aCell := StrTokArr(ABW->ABW_LISTA,";")
EndIf

RestArea(aArea)

Return aCell

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Grv()

Gravação do xml e do cálculo na planilha do item selecionado.

@sample 	At998Grv() 

@param		oModel, Object, Classe do modelo de dados MpFormModel  
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998Grv(oModel,lLocEq, cCodRev)

Local oMdlRh		:= Nil 
Local oMdlLE		:= Nil 
Local oMdlLEa		:= Nil 
Local cManip		:= ""
Local nTamCpoCod 	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev 	:= TamSX3("TFF_PLAREV")[1]
Local cTotAbINS		:= 0
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit  	:= IsInCallStack("At984aPlPc")
Local nTotRh 		:= 0
Local nTotPlan		:= 0
Local lOrcSrv		:= At998Orc()
Default lLocEq		:= .F.
Default cCodRev 	:= ""

Default lLocEq 		:= .F.

cManip := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)

If lFacilit
	oMdlRh := oModel:GetModel("TXSDETAIL")
	If oFWSheet:CellExists("TOTAL_CUSTOS")
		nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTOS")
	Elseif oFWSheet:CellExists("TOTAL_CUSTO")
		nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTO")
	Endif
	If oFWSheet:CellExists("TOTAL_BRUTO")
		nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
	Endif
Else
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	oMdlLEa := oModel:GetModel("TEV_ADICIO")
	If lOrcSrv 
		If oFWSheet:CellExists("TOTAL_CUSTOS")
			nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTOS")
		Elseif oFWSheet:CellExists("TOTAL_CUSTO")
			nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTO")
		Endif
		If oFWSheet:CellExists("TOTAL_BRUTO")
			nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
		Endif
	Else
		If oFWSheet:CellExists("TOTAL_RH")
			nTotRh := oFwSheet:GetCellValue("TOTAL_RH")	
		Endif
	Endif
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		cTotAbINS := oFwSheet:GetCellValue("TOTAL_ABATE_INS")
	EndIf
Endif

If !Empty(cManip) .AND. oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW .And. !lLocEq
	If lFacilit
		oMdlRh:SetValue("TXS_CALCMD",cManip)
		oMdlRh:SetValue("TXS_VLUNIT",Round(nTotRh, TamSX3("TXS_VLUNIT")[2]))
		oMdlRh:SetValue("TXS_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlRh:SetValue("TXS_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))	
		oMdlRh:SetValue("TXS_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
	Else
		oMdlRh:SetValue("TFF_CALCMD",cManip)
		oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotRh, TamSX3("TFF_PRCVEN")[2]))
		oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
	Endif
EndIf

If !lFacilit
	If !Empty(cManip) .AND. lAbtInss .And. cTotAbINS > 0
		oMdlRh:SetValue("TFF_ABTINS", cTotAbINS)
	EndIf

	If !Empty(cManip) .AND. oMdlLE:GetOperation() <> MODEL_OPERATION_VIEW .And. lLocEq .And. !Empty(oMdlLE:GetValue("TFI_PRODUT"))
		oMdlLE:SetValue("TFI_CALCMD",cManip)
		oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		If oFWSheet:CellExists("TOTAL_LE_COB")
			oMdlLEa:SetValue("TEV_MODCOB",if(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
		EndIf
		
		If oFWSheet:CellExists("TOTAL_LE_QUANT")
			oMdlLEa:SetValue("TEV_QTDE", if(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
		EndIf
		
		If oFWSheet:CellExists("TOTAL_LE_VUNIT")
			oMdlLEa:SetValue("TEV_VLRUNI", if(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
		EndIf
	EndIf
Endif

If lCpoCustom
	ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998ExPla()

Executa o cálculo do modelo da planilha sem visualizar a mesma. 

@sample 	At998ExPla() 

@param		cXml, Caracter, Conteúdo do XML
			oModel, Object, Classe do modelo de dados MpFormModel  
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998ExPla(cXml, oModel, lLocEq, cCodRev, lReplica)
Local oMdlLA		:= Nil
Local oMdlRh		:= Nil
Local oMdlVA		:= Nil
Local oMdlLE		:= Nil
Local oMdlLEa		:= Nil
Local oMdlTWO		:= Nil
Local oMdlBen		:= Nil
Local nTotMI		:= 0 
Local nTotMC		:= 0
Local nTotUnif		:= 0
Local nTotArma		:= 0
Local nTotal		:= 0
Local nX			:= 0
Local nY			:= 0
Local nTamCpoCod	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev	:= TamSX3("TFF_PLAREV")[1]
Local cTotAbINS 	:= 0
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit   	:= IsInCallStack("At984aPlPc")
Local nTotPlan		:= 0
Local lOrcSrv		:= At998Orc()
Local nTotVer       := 0
Local nPercISS		:= 0
Local nAjustEsc		:= ((((365*4)+1)/4)/12)/30
Local nHrsTot		:= 0
Local nTotFer		:= 0
Local nHrDia		:= 0
Local nHrsNot		:= 0
Local nQtdAlo		:= 0
Local cInsalub		:= "1"
Local cDscInsa		:= x3Combo("TFF_INSALU",cInsalub)
Local cGrauInsalub  := "1"
Local cDscGrau		:= x3Combo("TFF_GRAUIN",cGrauInsalub)
Local cPericulo		:= "1"
Local cDscPeric		:= x3Combo("TFF_PERICU",cPericulo)
Default lLocEq		:= .F.
Default cCodRev 	:= ""
Default lReplica 	:= .F.

oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If isBlind()
	oFwSheet:LoadXmlModel(cXml)
Else
	FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, STR0020)//"Carregando..."
EndIf
If lFacilit 
	oMdlRh := oModel:GetModel("TXSDETAIL")
	oMdlVA := oModel:GetModel("TXXDETAIL")
	nTotMI := oMdlRh:GetValue("TXS_TOTMI")
	nTotMC := oMdlRh:GetValue("TXS_TOTMC")
	nTotUnif:= oMdlRh:GetValue("TXS_TOTUNI")
	nTotArma:= oMdlRh:GetValue("TXS_TOTARM")
	nTotVer := At998Verba(oMdlVA) 

	If TXS->( ColumnPos('TXS_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TXS_INSALU")
		cDscInsa := x3Combo("TXS_INSALU",cInsalub)
	Endif
	If TXS->( ColumnPos('TXS_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TXS_GRAUIN")
		cDscGrau :=  x3Combo("TXS_GRAUIN",cGrauInsalub)
	Endif
	If TXS->( ColumnPos('TXS_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TXS_PERICU")
		cDscPeric := x3Combo("TXS_PERICU",cPericulo)
	Endif
	If oFWSheet:CellExists("TOTAL_MI")
		oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MC")
		oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
	EndIf
	If oFWSheet:CellExists("TOTAL_UNIF")
		oFWSheet:SetCellValue("TOTAL_UNIF", nTotUnif)
	EndIf
	If oFWSheet:CellExists("TOTAL_ARMA")
		oFWSheet:SetCellValue("TOTAL_ARMA", nTotArma)
	EndIf
	If oFWSheet:CellExists("TOTAL_VERBAS")
		oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
	EndIf
	If oFWSheet:CellExists("AJUSTE_ESCALA") .And. Empty(oFWSheet:GetCellValue("AJUSTE_ESCALA"))
		oFWSheet:SetCellValue("AJUSTE_ESCALA", nAjustEsc )
	EndIf
	nDiasTrb := At998DTrb(oMdlRh:GetValue("TXS_ESCALA"),oMdlRh:GetValue("TXS_TURNO"),@nHrsTot,@nHrDia)
	If oFWSheet:CellExists("MES_COMERCIAL") .And. oFWSheet:CellExists("AJUSTE_ESCALA") .And. Empty(oFWSheet:GetCellValue("MES_COMERCIAL"))
		oFWSheet:SetCellValue("MES_COMERCIAL","="+cValTochar(nDiasTrb)+"*G6" )
	EndIf
	If oFWSheet:CellExists("JORNADA_CALCULO") .And. Empty(oFWSheet:GetCellValue("JORNADA_CALCULO"))
		oFWSheet:SetCellValue("JORNADA_CALCULO","="+"G7"+"-G5")
	Endif
	If TXS->( ColumnPos('TXS_CALEND') ) > 0
		nTotFer := At998TotFer(oMdlRh:GetValue("TXS_CALEND"))
		If oFWSheet:CellExists("FERIADO") .And. Empty(oFWSheet:GetCellValue("FERIADO"))
			oFWSheet:SetCellValue("FERIADO","="+Iif(nTotFer <> 1 ,cValToChar(nTotFer)+"/12",cValToChar(nTotFer)))
		Endif
	Endif
	nHrsInt := At998TotInt(oMdlRh:GetValue("TXS_ESCALA"),oMdlRh:GetValue("TXS_TURNO"))
	If oFWSheet:CellExists("INTERVALO") .And. Empty(oFWSheet:GetCellValue("INTERVALO"))
		oFWSheet:SetCellValue("INTERVALO","="+cValToChar(nHrsInt) )
	Endif
	If oFWSheet:CellExists("JORNADA_COMERCIAL") .And. Empty(oFWSheet:GetCellValue("JORNADA_COMERCIAL"))
		oFWSheet:SetCellValue("JORNADA_COMERCIAL","="+cValToChar(nHrDia) )		
	Endif
	If oFWSheet:CellExists("TOTAL_HORAS") .And. Empty(oFWSheet:GetCellValue("TOTAL_HORAS"))
		oFWSheet:SetCellValue("TOTAL_HORAS","="+cValTochar(nHrsTot) )
	EndIf
	If oFWSheet:CellExists("HORA_EXTRA") .And. Empty(oFWSheet:GetCellValue("HORA_EXTRA"))
		oFWSheet:SetCellValue("HORA_EXTRA","="+"(G7*G2)-G8" )
	EndIf
	If oFWSheet:CellExists("VALOR_HORA") .And. Empty(oFWSheet:GetCellValue("VALOR_HORA"))
		oFWSheet:SetCellValue("VALOR_HORA","="+"D2/G8" )
	EndIf
	If oFWSheet:CellExists("VALOR_EXTRA") .And. Empty(oFWSheet:GetCellValue("VALOR_EXTRA"))
		oFWSheet:SetCellValue("VALOR_EXTRA","="+"G10*(CALC_HORA_EXTRA/100)")
	EndIf
	If oFWSheet:CellExists("VALOR_EXTRA_FERIADO") .And. Empty(oFWSheet:GetCellValue("VALOR_EXTRA_FERIADO"))
		oFWSheet:SetCellValue("VALOR_EXTRA_FERIADO","="+"G10*(CALC_HORA_EXTRAFER/100)")
	EndIf
	nHrsNot := At998HrNt(oMdlRh:GetValue("TXS_ESCALA"),oMdlRh:GetValue("TXS_TURNO"))
	If oFWSheet:CellExists("HORAS_NOTURNAS") .And. Empty(oFWSheet:GetCellValue("HORAS_NOTURNAS"))
		oFWSheet:SetCellValue("HORAS_NOTURNAS","="+cValToChar(nHrsNot) )
	Endif
	If oFWSheet:CellExists("PARAM_INSALUB")
		oFWSheet:SetCellValue("PARAM_INSALUB",cInsalub )
	Endif
	If oFWSheet:CellExists("DESC_INSALUB")
		oFWSheet:SetCellValue("DESC_INSALUB",cDscInsa )
	Endif
	If oFWSheet:CellExists("PARAM_GRAUINSALUB")
		oFWSheet:SetCellValue("PARAM_GRAUINSALUB", cGrauInsalub )
	Endif
	If oFWSheet:CellExists("DESC_GRAU")
		oFWSheet:SetCellValue("DESC_GRAU", cDscGrau )
	Endif
	If oFWSheet:CellExists("PARAM_PERICULOSO")
		oFWSheet:SetCellValue("PARAM_PERICULOSO",cPericulo )
	Endif
	If oFWSheet:CellExists("DESC_PERICU")
		oFWSheet:SetCellValue("DESC_PERICU",cDscPeric )
	Endif
	If oFWSheet:CellExists("NUMERO_PESSOAS") .And. Empty(oFWSheet:GetCellValue("NUMERO_PESSOAS"))
		If FindFunction("At740QtdAloc")
			nQtdAlo := At740QtdAloc(oMdlRh:GetValue("TXS_ESCALA"))
			oFWSheet:SetCellValue("NUMERO_PESSOAS","="+cValTochar(nQtdAlo))
		EndIf
	EndIf
Else
	oMdlLA := oModel:GetModel("TFL_LOC")
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	oMdlLEa := oModel:GetModel("TEV_ADICIO")
	oMdlTWO := oModel:GetModel("TWODETAIL")
	oMdlBen := oModel:GetModel("ABP_BENEF")
	nTotVer := At998Verb(oMdlBen) 
	nTotMI := oMdlRh:GetValue("TFF_TOTMI")
	nTotMC := oMdlRh:GetValue("TFF_TOTMC")
	nPercISS := At998GtISS(oModel:GetValue("TFL_LOC","TFL_LOCAL"),oModel:GetValue("TFF_RH","TFF_PRODUT"))
	If TFF->( ColumnPos('TFF_INSALU') ) > 0
		cInsalub := oMdlRh:GetValue("TFF_INSALU")
		cDscInsa := x3Combo("TFF_INSALU",cInsalub)
	Endif
	If TFF->( ColumnPos('TFF_GRAUIN') ) > 0
		cGrauInsalub := oMdlRh:GetValue("TFF_GRAUIN")
		cDscGrau :=  x3Combo("TFF_GRAUIN",cGrauInsalub)
	Endif
	If TFF->( ColumnPos('TFF_PERICU') ) > 0
		cPericulo := oMdlRh:GetValue("TFF_PERICU")
		cDscPeric := x3Combo("TFF_PERICU",cPericulo)
	Endif
	If lOrcSrv
		If oFWSheet:CellExists("TOTAL_MI")
			oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
		EndIf	
		If oFWSheet:CellExists("TOTAL_MC")
			oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
		EndIf
		If oFWSheet:CellExists("TOTAL_UNIF")
			oFWSheet:SetCellValue("TOTAL_UNIF", oMdlRh:GetValue("TFF_TOTUNI"))
		EndIf
		If oFWSheet:CellExists("TOTAL_ARMA")
			oFWSheet:SetCellValue("TOTAL_ARMA", oMdlRh:GetValue("TFF_TOTARM"))
		EndIf
		If oFWSheet:CellExists("TOTAL_VERBAS")
			oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
		EndIf
		If nPercISS > 0 .And. oFWSheet:CellExists("IMPOSTO_ISS")
			oFWSheet:SetCellValue("IMPOSTO_ISS", nPercISS)
		Endif
		If oFWSheet:CellExists("AJUSTE_ESCALA") .And. Empty(oFWSheet:GetCellValue("AJUSTE_ESCALA"))
			oFWSheet:SetCellValue("AJUSTE_ESCALA", nAjustEsc )
		EndIf
		nDiasTrb := At998DTrb(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"),@nHrsTot,@nHrDia)
		If oFWSheet:CellExists("MES_COMERCIAL") .And. Empty(oFWSheet:GetCellValue("MES_COMERCIAL"))
			oFWSheet:SetCellValue("MES_COMERCIAL","="+cValTochar(nDiasTrb)+"*G6" )
		EndIf
		If oFWSheet:CellExists("JORNADA_CALCULO") .And. Empty(oFWSheet:GetCellValue("JORNADA_CALCULO"))
			oFWSheet:SetCellValue("JORNADA_CALCULO","="+"G7"+"-G5")
		Endif
		nTotFer := At998TotFer(oMdlRh:GetValue("TFF_CALEND"))
		If oFWSheet:CellExists("FERIADO") .And. Empty(oFWSheet:GetCellValue("FERIADO"))
			oFWSheet:SetCellValue("FERIADO","="+Iif(nTotFer <> 1 ,cValToChar(nTotFer)+"/12",cValToChar(nTotFer)))
		Endif
		nHrsInt := At998TotInt(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"))
		If oFWSheet:CellExists("INTERVALO") .And. Empty(oFWSheet:GetCellValue("INTERVALO"))
			oFWSheet:SetCellValue("INTERVALO","="+cValToChar(nHrsInt) )
		Endif
		If oFWSheet:CellExists("JORNADA_COMERCIAL") .And. Empty(oFWSheet:GetCellValue("JORNADA_COMERCIAL"))
			oFWSheet:SetCellValue("JORNADA_COMERCIAL","="+cValToChar(nHrDia) )
		Endif
		If oFWSheet:CellExists("TOTAL_HORAS") .And. Empty(oFWSheet:GetCellValue("TOTAL_HORAS"))
			oFWSheet:SetCellValue("TOTAL_HORAS","="+cValTochar(nHrsTot) )
		EndIf
		If oFWSheet:CellExists("HORA_EXTRA") .And. Empty(oFWSheet:GetCellValue("HORA_EXTRA"))
			oFWSheet:SetCellValue("HORA_EXTRA","="+"(G7*G2)-G8" )
		EndIf
		If oFWSheet:CellExists("VALOR_HORA") .And. Empty(oFWSheet:GetCellValue("VALOR_HORA"))
			oFWSheet:SetCellValue("VALOR_HORA","="+"D2/G8" )
		EndIf
		If oFWSheet:CellExists("VALOR_EXTRA") .And. Empty(oFWSheet:GetCellValue("VALOR_EXTRA"))
			oFWSheet:SetCellValue("VALOR_EXTRA","="+"G10*(CALC_HORA_EXTRA/100)")
		EndIf
		If oFWSheet:CellExists("VALOR_EXTRA_FERIADO") .And. Empty(oFWSheet:GetCellValue("VALOR_EXTRA_FERIADO"))
			oFWSheet:SetCellValue("VALOR_EXTRA_FERIADO","="+"G10*(CALC_HORA_EXTRAFER/100)")
		EndIf
		nHrsNot := At998HrNt(oMdlRh:GetValue("TFF_ESCALA"),oMdlRh:GetValue("TFF_TURNO"))
		If oFWSheet:CellExists("HORAS_NOTURNAS") .And. Empty(oFWSheet:GetCellValue("HORAS_NOTURNAS"))
			oFWSheet:SetCellValue("HORAS_NOTURNAS","="+cValToChar(nHrsNot) )
		Endif
		If oFWSheet:CellExists("PARAM_INSALUB")
			oFWSheet:SetCellValue("PARAM_INSALUB",cInsalub )
		Endif
		If oFWSheet:CellExists("DESC_INSALUB")
			oFWSheet:SetCellValue("DESC_INSALUB",cDscInsa )
		Endif
		If oFWSheet:CellExists("PARAM_GRAUINSALUB")
			oFWSheet:SetCellValue("PARAM_GRAUINSALUB", cGrauInsalub )
		Endif
		If oFWSheet:CellExists("DESC_GRAU")
			oFWSheet:SetCellValue("DESC_GRAU", cDscGrau )
		Endif
		If oFWSheet:CellExists("PARAM_PERICULOSO")
			oFWSheet:SetCellValue("PARAM_PERICULOSO",cPericulo )
		Endif
		If oFWSheet:CellExists("DESC_PERICU")
			oFWSheet:SetCellValue("DESC_PERICU",cDscPeric )
		Endif
		If oFWSheet:CellExists("NUMERO_PESSOAS") .And. Empty(oFWSheet:GetCellValue("NUMERO_PESSOAS"))
			If FindFunction("At740QtdAloc")
				nQtdAlo := At740QtdAloc(oMdlRh:GetValue("TFF_ESCALA"))
				oFWSheet:SetCellValue("NUMERO_PESSOAS","="+cValTochar(nQtdAlo))
			EndIf
		EndIf
	Else
		If oFWSheet:CellExists("TOTAL_MAT_IMP")
			oFWSheet:SetCellValue("TOTAL_MAT_IMP", nTotMI)
		EndIf
		If oFWSheet:CellExists("TOTAL_MAT_CONS")
			oFWSheet:SetCellValue("TOTAL_MAT_CONS", nTotMC)
		EndIf
		If oFWSheet:CellExists("TOTAL_VERBAS")
			oFWSheet:SetCellValue("TOTAL_VERBAS", nTotVer)
		EndIf
		If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
			cTotAbINS := oFwSheet:GetCellValue("TOTAL_ABATE_INS")
		EndIf
	Endif
Endif

oFWSheet:Refresh(.T.)

If lFacilit .Or. lOrcSrv
	cXml := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, STR0020)//"Carregando..."
	If oFWSheet:CellExists("TOTAL_CUSTOS")
		nTotal := oFwSheet:GetCellValue("TOTAL_CUSTOS")
	Elseif oFWSheet:CellExists("TOTAL_CUSTO")
		nTotal := oFwSheet:GetCellValue("TOTAL_CUSTO")
	Endif
	If oFWSheet:CellExists("TOTAL_BRUTO")
		nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
	Endif
Else
	If oFWSheet:CellExists("TOTAL_RH")
		nTotal := oFwSheet:GetCellValue("TOTAL_RH")
	Endif
Endif

If oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW
	cXml := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	//Executar Planilha para item de RH
	If !( lLocEq )
		//Verifica se tem um facilitador vinculado
		If !lFacilit .And. !lReplica .AND. !( Empty(oMdlRh:GetValue('TFF_CHVTWO')) ) .And. oMdlLA:Length(.T.) > 1 .And. MsgYesNo(STR0015) // "Replicar a execução da Planilha para todos locais de atendimento que utilizam este mesmo facilitador? "
			For nX := 1 To oMdlLA:Length()
				oMdlLA:GoLine(nX)
				For nY := 1 To oMdlRh:Length()
					oMdlRh:GoLine(nY)
					If !( Empty(oMdlRh:GetValue('TFF_CHVTWO')) ) .And. SubStr(oMdlRh:GetValue('TFF_CHVTWO'),1,15) == oMdlTWO:GetValue('TWO_CODFAC')
						oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
						oMdlRh:SetValue("TFF_CALCMD",cXml)
						oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
						oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
						If lAbtInss .And. cTotAbINS > 0
							oMdlRh:SetValue("TFF_ABTINS",cTotAbINS)
						EndIf
					EndIf
				Next nY
			Next nX
		Else			
			If lFacilit
				oMdlRh:SetValue("TXS_VLUNIT", ROUND(nTotal, TamSX3("TXS_VLUNIT")[2]))
				oMdlRh:SetValue("TXS_CALCMD", cXml)
				oMdlRh:SetValue("TXS_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:SetValue("TXS_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				oMdlRh:SetValue("TXS_TOTPLA", ROUND(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
			Else
				oMdlRh:SetValue("TFF_PRCVEN", ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
				oMdlRh:SetValue("TFF_CALCMD", cXml)
				oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				If TFF->( ColumnPos('TFF_TOTPLA') ) > 0
					oMdlRh:SetValue("TFF_TOTPLA", ROUND(nTotPlan, TamSX3("TFF_TOTPLA")[2]))
				Endif
				If lAbtInss .And. cTotAbINS > 0
					oMdlRh:SetValue("TFF_ABTINS",cTotAbINS)
				EndIf
			Endif
			If lCpoCustom
				ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
			EndIf
		EndIf
	//Executar Planilha para item de Locação de Equipamento
	ElseIf !( Empty(oMdlLE:GetValue("TFI_PRODUT")) )
		//Verifica se tem um facilitador vinculado
		If !( Empty(oMdlLE:GetValue('TFI_CHVTWO')) ) .AND. oMdlLA:Length(.T.) > 1 .AND. MsgYesNo(STR0015) // "Replicar a execução da Planilha para todos locais de atendimento que utilizam este mesmo facilitador? "
			For nX := 1 To oMdlLA:Length()
				oMdlLA:GoLine(nX)
				For nY := 1 To oMdlLE:Length()
					oMdlLE:GoLine(nY)
					If  !( Empty(oMdlLE:GetValue('TFI_CHVTWO')) ) .And. SubStr(oMdlLE:GetValue('TFI_CHVTWO'),1,15) == oMdlTWO:GetValue('TWO_CODFAC')
						oMdlLE:SetValue("TFI_CALCMD", cXml)
						oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
						oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
						If oFWSheet:CellExists("TOTAL_LE_COB")
							oMdlLEa:SetValue("TEV_MODCOB",If(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
						EndIf
						If oFWSheet:CellExists("TOTAL_LE_QUANT")
							oMdlLEa:SetValue("TEV_QTDE", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
						EndIf
						If oFWSheet:CellExists("TOTAL_LE_VUNIT")
							oMdlLEa:SetValue("TEV_VLRUNI", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
						EndIf
					EndIf
				Next nY
			Next nX
		Else
			oMdlLE:SetValue("TFI_CALCMD", cXml)
			oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
			oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
			If oFWSheet:CellExists("TOTAL_LE_COB")
				oMdlLEa:SetValue("TEV_MODCOB",If(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
			EndIf
			If oFWSheet:CellExists("TOTAL_LE_QUANT")
				oMdlLEa:SetValue("TEV_QTDE", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
			EndIf
			If oFWSheet:CellExists("TOTAL_LE_VUNIT")
				oMdlLEa:SetValue("TEV_VLRUNI", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
			EndIf
		EndIf
	EndIf
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998ConsP()

Construção da consulta padrão da tabela ABW - MODELO PLANILHA PREC. SERVICOS

@sample 	At998ConsP() 

@return	lRet, Retorna qual botão foi selecionado .T. Confirmar, .F. Sair 
			cRet, Retorna o codigo+revisão do modelo selecionado

@since		23/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Static Function At998ConsP(cCodPlan)

Local oDlg
Local aBrowse	:= {}   
Local lRet		:= .F. 
Local cRet		:= ""
Local cFilABW 	:= xFilial("ABW")
Local nPos 		:= 0
Local lFacilit   := IsInCallStack("At984aPlPc")
Local lCCT := FindFunction("At999CpCCT") .And. At999CpCCT()

Default cCodPlan := ""


DbSelectArea("ABW")
DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO+ABW_REVISA
ABW->( DbSeek( cFilABW ) ) // posiciona no primeiro registro da filial

While ABW->(!EOF()) .And. ABW->ABW_FILIAL == cFilABW
	If ABW->(FieldPos("ABW_MSBLQL")) <= 0 .OR. ABW->ABW_MSBLQL != "1"
		If lFacilit .Or. (At998Orc())
			If lCCT .And. !Empty(ABW->ABW_CODTCW)
				aAdd(aBrowse,{ABW->ABW_CODIGO,ABW->ABW_DESC,ABW->ABW_REVISA})
				If !Empty(cCodPlan) .AND. cCodPlan  == ABW->ABW_CODIGO+ABW->ABW_REVISA
					nPos := Len(aBrowse)
				EndIf
			Endif
		Else
			aAdd(aBrowse,{ABW->ABW_CODIGO,ABW->ABW_DESC,ABW->ABW_REVISA})
			If !Empty(cCodPlan) .AND. cCodPlan  == ABW->ABW_CODIGO+ABW->ABW_REVISA
				nPos := Len(aBrowse)
			EndIf
		Endif
	EndIf
	ABW->(DbSkip())
End

If Len(aBrowse) > 0
	DEFINE MSDIALOG oDlg FROM 180,180 TO 550,700 PIXEL TITLE STR0009 //'Consulta Padrão'

	oBrowse := TWBrowse():New( 01 , 01,261, 160,,{STR0010,STR0011,STR0012},{30,40,10}, oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //"Código"#"Descrição"#"Revisão"
	oBrowse:SetArray(aBrowse)
	If nPos > 0
		//Posiciona na planilha selecionada
		oBrowse:GoPosition(nPos)
	EndIf
	oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]} }
	oBrowse:bLDblClick := {|| lRet := .T., cRet := aBrowse[oBrowse:nAt,01]+aBrowse[oBrowse:nAt,03] ,oDlg:End()}

	TButton():New(168,150,STR0005,oDlg,{|| lRet := .T., cRet := aBrowse[oBrowse:nAt,01]+aBrowse[oBrowse:nAt,03] ,oDlg:End() },50,13,,,,.T.) //'Confirmar'
	TButton():New(168,205,STR0013,oDlg,{|| lRet := .F. ,oDlg:End() },50,13,,,,.T.) //'Sair'

	ACTIVATE MSDIALOG oDlg CENTERED 
Else
	Help(,, "AT998COBCTR3",,STR0024,1,0,,,,,,{STR0025}) //"Não encontrou registros para essa consulta." ## "Incluir uma planilha de preços."
EndIf

Return {lRet,cRet}
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECGetValue()

Função para retornar qualquer valor do Orçamento de serviços, com o modelo instanciado


@return	xValue

@since		10/10/2016       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function TECGetValue(cAba,cCampo,nLinha,cErro)
Local aSaveLines	:= FWSaveRows()
Local xRet			:= Nil
Default nLinha := 0
Default cErro := ""

If Valtype(oModel740) == 'O'
	cAba := Upper(Alltrim(cAba)) 
	
	Do Case
		Case cAba == 'OR' //-- Cabeçalho Orçamento
			xRet := oModel740:GetValue('TFJ_REFER',cCampo) 
				
			
		Case cAba == 'LA' //-- Local de atendimento
			nlinha := If(nLinha == 0,oModel740:GetModel('TFL_LOC'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFL_LOC'):Length()
				cErro := 'Aba: LA ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida'
			Else
				xRet 	:= oModel740:GetValue('TFL_LOC',cCampo,nLinha)
			EndIf			
			
		
		Case cAba == 'RH' //-- Recursos humanos
			nlinha := If(nLinha == 0,oModel740:GetModel('TFF_RH'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFF_RH'):Length()
				cErro := 'Aba: RH ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFF_RH',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'MI' //-- Material de implantação
			nLinha := If(nLinha == 0,oModel740:GetModel('TFG_MI'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFG_MI'):Length()
				cErro := 'Aba: MI ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFG_MI',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'MC' //-- Material de consumo
			nlinha := If(nLinha == 0,oModel740:GetModel('TFH_MC'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFH_MC'):Length()
				cErro := 'Aba: MC ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFH_MC',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'LE' //-- Locação de equipamento
			nlinha := If(nLinha == 0,oModel740:GetModel('TFI_LE'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFI_LE'):Length()
				cErro := 'Aba: LE ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFI_LE',cCampo,nLinha)
			EndIf			
		
	EndCase
EndIf
FwRestRows( aSaveLines )
Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998InPl()
 Realiza a inclusão de uma Planilha de preço
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998InPl()
Local lRet := .F.
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
					{.T.,STR0021},{.T.,STR0022},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"
Local nRet := FWExecView(STR0023, "TECA999", MODEL_OPERATION_INSERT,, {||.T.},,, aButtons ) //"Planilha de Preço"
Local cCodPlan := ""

If nRet == 0
	lRet := .T.
	cCodPlan := ABW->(ABW_CODIGO+ABW_REVISA)
Endif

Return {lRet,cCodPlan}

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Orc()
 Verificar se foi feita a chamada pelo orçamento e orçamento simplificado
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998Orc()
Return SuperGetMv("MV_GSITORC",,"2") == "1" .And. (Isincallstack("TECA740") .Or. Isincallstack("TECA745") .Or. IsInCallStack("At600SeAtu") .Or. IsInCallStack("at870revis") )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Verb
Quantidades de batidas no dia
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function At998Verb(oModel)
Local nValor := 0
Local nX     := 0

If ABP->(ColumnPos('ABP_CONFCA'))
	For nX := 1 to oModel:Length()
		oModel:GoLine(nX)
		If !oModel:IsDeleted() .And. !Empty(oModel:GetValue("ABP_BENEFI"))
			If oModel:GetValue("ABP_CONFCA") != "1"
				nValor += oModel:GetValue("ABP_VALOR")
			EndIf
		Endif
	Next nX
Else
	For nX := 1 to oModel:Length()
		oModel:GoLine(nX)
		If !oModel:IsDeleted() .And.  !Empty(oModel:GetValue("ABP_BENEFI"))
			nValor += oModel:GetValue("ABP_VALOR")
		Endif
	Next nX
EndIf

Return nValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Verba
Retorna o valor da TXX na planilha - verbas adicionais
@since		24/10/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------
Static Function At998Verba(oModel)

Local cValor    := 0
Local nX := 0

For nX := 1 to oModel:Length()
	oModel:GoLine(nX)
	If !oModel:IsDeleted() .And. !Empty(oModel:GetValue("TXX_CODIGO"))
		cValor += oModel:GetValue("TXX_VALOR")
	Endif
Next nX

Return cValor

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998GtISS
Seleciona o valor do ISS
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Static Function At998GtISS(cCodLoc,cCodPrd)
Local cTabTemp := ""
Local nRetVlr := 0
Local cCodEst := ""
Local cCodMun := ""
Local cWhere  := "%%"
Default cCodLoc := ""

DbSelectArea("ABS")
ABS->(DbSetOrder(1))
If !Empty(cCodLoc) .And. ABS->(MsSeek(xFilial("ABS")+cCodLoc))
	cCodEst := ABS->ABS_ESTADO
	cCodMun := ABS->ABS_CODMUN
Endif

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
If !Empty(cCodPrd) .And. SB1->(MsSeek(xFilial("SB1")+ cCodPrd))
	cWhere := " AND CE1.CE1_CODISS = '" +SB1->B1_CODISS+"'"
	cWhere := "%"+cWhere+"%"
Endif

If !Empty(cCodEst) .And. !Empty(cCodMun)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT CE1_ALQISS
		FROM %Table:CE1% CE1
		WHERE CE1.CE1_FILIAL = %xFilial:CE1%
			AND CE1.CE1_ESTISS = %Exp:cCodEst% 
			AND CE1.CE1_CMUISS = %Exp:cCodMun%
			AND CE1.%NotDel%
			%exp:cWhere%
	EndSql
	If !(cTabTemp)->(EOF())
		nRetVlr := (cTabTemp)->CE1_ALQISS
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

Return nRetVlr

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998DTrb
Calculo conforme a projeção de dias trabalhados.
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Static Function At998DTrb(cEscala,cTurno,nHrsTot,nHrDia)
Local aTabPadrao := {}
Local aCalend := {}
Local nX := 0
Local nDiaTrab := 0
Local dDtIni := cTod("01/11/2021")
Local dDtFim := cTod("30/11/2021")
Local cTabTemp := ""
Local nHrIni := 0
Local nHrFim := 0
Default cEscala := ""
Default cTurno := ""
Default nHrsTot := 0
Default nHrDia := 0

If !Empty(cEscala)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDX.TDX_TURNO
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala% 
			AND TDX.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

If !Empty(cTurno)
	If ( CriaCalend(dDtIni,dDtFim,cTurno,"01",@aTabPadrao,@aCalend,xFilial("SRA")) )
		For nX := 1 To Len(aCalend)
			If aCalend[nX][6] == "S"
				If aCalend[nX][4] == "1E"
					If nDiaTrab <> 0
						nHrDia := TecConvHr(ElapTime(TecConvHr(nHrIni) + ":00", TecConvHr(nHrFim) + ":00"))
						nHrsTot += nHrDia		
					Endif
					nHrIni := aCalend[nX][3]
					nDiaTrab++
				Endif
				nHrFim := aCalend[nX][3]
				If Len(aCalend) == nX
					nHrDia := TecConvHr(ElapTime(TecConvHr(nHrIni) + ":00", TecConvHr(nHrFim) + ":00"))
					nHrsTot += nHrDia		
					nHrIni := 0
					nHrFim := 0
				Endif
			Endif
		Next nX
	Endif
Endif

Return nDiaTrab

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998TotFer
Total de feriados no ano
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Static Function At998TotFer(cCalend)
Local nTotFer := 1
Local cTabTemp := GetNextAlias()
Local dDtIni := cTod("01/01/"+cValtoChar(Year(dDatabase)))
Local dDtFim := cTod("31/12/"+cValtoChar(Year(dDatabase)))

If !Empty(cCalend)
	BeginSql Alias cTabTemp
		COLUMN RR0_DATA AS DATE
		SELECT COUNT(*) TOTALFER
		FROM %Table:RR0% RR0
		WHERE RR0.RR0_FILIAL = %xFilial:RR0%
			AND RR0.RR0_CODCAL = %Exp:cCalend%
			AND ( ( RR0.RR0_DATA BETWEEN %Exp:dDtIni% AND %Exp:dDtFim% ) OR RR0_FIXO = 'S' )
			AND RR0.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		nTotFer := (cTabTemp)->TOTALFER
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

Return nTotFer


//------------------------------------------------------------------------------
/*/{Protheus.doc} At998TotInt
Horas de intervalos
@since		28/09/2022
@author 	Kaique Schiller
@return 	nRetVlr
/*/
//------------------------------------------------------------------------------
Static Function At998TotInt(cEscala,cTurno)
Local nHrsInt := 0 
Default cEscala := ""
Default cTurno := ""

If !Empty(cEscala)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDX.TDX_TURNO
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala% 
			AND TDX.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

If !Empty(cTurno)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT PJ_HRSINT1,PJ_HRSINT2,PJ_HRSINT3
		FROM %Table:SPJ% SPJ
		WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
			AND SPJ.PJ_TURNO = %Exp:cTurno% 
			AND SPJ.PJ_TPDIA = 'S'
			AND (SPJ.PJ_HRSINT1 <> 0 OR SPJ.PJ_HRSINT2  <> 0 OR SPJ.PJ_HRSINT3 <> 0)
			AND SPJ.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
	 	nHrsInt := (cTabTemp)->PJ_HRSINT1+(cTabTemp)->PJ_HRSINT2+(cTabTemp)->PJ_HRSINT3
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

Return nHrsInt

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998HrNt
Horas Noturnas
@since		28/09/2022
@author 	Kaique Schiller
@return 	nHrsNot
/*/
//------------------------------------------------------------------------------
Static Function At998HrNt(cEscala,cTurno)
Local nHrsNot := 0 
Default cEscala := ""
Default cTurno := ""

If !Empty(cEscala)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDX.TDX_TURNO
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala% 
			AND TDX.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

If !Empty(cTurno)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT R6_INIHNOT,R6_FIMHNOT
		FROM %Table:SR6% SR6
		WHERE SR6.R6_FILIAL = %xFilial:SR6%
			AND SR6.R6_TURNO = %Exp:cTurno% 
			AND SR6.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
	 	nHrsNot := HoraToInt(ElapTime(IntToHora((cTabTemp)->R6_INIHNOT)+":00",IntToHora((cTabTemp)->R6_FIMHNOT)+":00"))
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

Return nHrsNot
