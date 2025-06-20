#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "TECA999.ch"

Static oFWSheet
Static cMemo
Static lCopyPl		:= .F.
Static lMdExemplo		:= .F.	
Static cTpPlan		:= ""
Static aCelulasBlock	:= {}
Static oCharge		:= Nil
Static cRetCod	:= "" 
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA999
Planilha de Pre�os de Servi�os
@sample 	TECA999() 
@param		Nenhum
@return	ExpL	Verdadeiro / Falso
@since		16/09/2013       
@version	P119
/*/
//------------------------------------------------------------------------------
Function TECA999()

Local oMBrowse
	
At999CadEx()
	
oMBrowse:= FWmBrowse():New() 
oMBrowse:SetAlias("ABW")
oMBrowse:SetDescription(STR0001) //"Modelo de Planilha de Pre�os de Servi�os"
oMBrowse:AddFilter(STR0002,"ABW_ULTIMA == '1'", .F.,.T., , , , ) //"Somente �ltima revis�o"
oMBrowse:SetDBFFilter()  							
oMBrowse:Activate()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define o menu funcional. 
@sample 	MenuDef() 
@param		Nenhum  
@return	ExpA Op��es da Rotina. 
@since		16/09/2013       
@version	P11   
/*/
//------------------------------------------------------------------------------

Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA999" OPERATION 2 ACCESS 0  // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA999" OPERATION 3 ACCESS 0  // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA999" OPERATION 4 ACCESS 0  // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA999" OPERATION 5 ACCESS 0  // "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "At999CpPl()"     OPERATION 7 ACCESS 0  // "Copiar"
Return( aRotina )


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Model
@sample 	ModelDef() 
@param		Nenhum
@return	ExpO Objeto FwFormModel 
@since		16/09/2013       
@version	P11   
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oStruABW		:= FWFormStruct( 1, "ABW" )				// Estrutura ABW.
Local bCommit 		:= {|oModel| At999Cmt(oModel,aCelulasBlock)}
Local bPosValid		:= {|oModel| IIF(!lMdExemplo,At999Vld(oModel),.T.) }
Local xAux

If At999CpCCT()
	xAux := FwStruTrigger( 'ABW_FUNCAO', 'ABW_SALARI', 'Posicione("SRJ",1,xFilial("SRJ")+FwFldGet("ABW_FUNCAO"),"RJ_SALARIO")', .F. )
		oStruABW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
Endif

oStruABW:AddField(STR0052,STR0052,'ABW_ALTERA','L',1) // 'Alterado' ### 'Alterado'

oStruABW:AddField(STR0052,STR0052,'ABW_FAKE','N',3) // 'Alterado' ### 'Alterado'

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("TECA999",/*bPreValid*/,bPosValid,bCommit )
oModel:AddFields("ABWMASTER",/*cOwner*/,oStruABW)
oModel:SetPrimaryKey({"ABW_FILIAL","ABW_CODIGO"})
oModel:SetDescription(STR0001) //"Modelo de Planilha de Pre�os de Servi�os" 
oModel:SetActivate( {|oModel| At999InDds( oModel ) } )
Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View
@sample 	ViewDef()
@param		Nenhum
@return	ExpO Objeto FwFormView 
@since		16/09/2013       
@version	P11   
/*/
//------------------------------------------------------------------------------

Static Function ViewDef() 

Local oView		:= Nil									// Interface de visualiza��o constru�da	
Local oModel		:= If( At999GLoad() <> NIl, At999GLoad(), FwLoadModel("TECA999") )					// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruABW	:= FWFormStruct(2,"ABW")				// Cria as estruturas a serem usadas na View

oView := FWFormView():New()								// Cria o objeto de View
oView:SetModel(oModel)									// Define qual Modelo de dados ser� utilizado
				
oView:AddField("VIEW_ABW",oStruABW,"ABWMASTER")		// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)

oView:AddOtherObject("VIEW_PLAN", {|oPanel| At999Plan(oPanel,cMemo)})

oStruABW:RemoveField("ABW_INSTRU")
oStruABW:RemoveField("ABW_ALTERA")
oStruABW:RemoveField("ABW_ULTIMA")
oStruABW:RemoveField("ABW_LISTA")
oStruABW:RemoveField("ABW_FAKE")

If !At999CpCCT()
	oStruABW:RemoveField("ABW_CODAA0")
	oStruABW:RemoveField("ABW_FUNCAO")
	oStruABW:RemoveField("ABW_SALARI")
Else
	oView:AddUserButton(STR0076,"",{|oModel| At999CarPl(oModel)},,,) // "Carregar Planilha"
Endif

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox("SUPERIOR" 	,25)		
oView:CreateHorizontalBox("INFERIOR"	,75)

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView("VIEW_ABW","SUPERIOR")
oView:SetOwnerView("VIEW_PLAN","INFERIOR")

oView:SetDescription( STR0001 ) //"Modelo de Planilha de Pre�os de Servi�os"

oView:SetViewAction( "BUTTONCANCEL", {|| aCelulasBlock := {}  } )

oView:SetCloseOnOk({||.T.}) //fecha a tela ap�s clicar no botao confirmar (o padrao era manter a tela aberta mesmo ap�s a edicao)

Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Plan
	Monta a Planilha de c�lculo para manipula��o. 
@sample 	At999Plan() 
@since		10/10/2013       
@version	P11.90
@param 		oPanel, Object, Painel do Objeto oView
@param		cMemo, Caracter, Conte�do do xml
/*/
//------------------------------------------------------------------------------
Static Function At999Plan( oPanel,cMemo  )

Local oFWLayer 
Local oList
Local oSay                                
Local oWinCampos
Local oWinPlanilha
Local oWinBloquead
Local nList	:= 1
Local aCellList	:= Array(1)
Local cXml	:= ABW->ABW_INSTRU
Local cLst := ABW->ABW_LISTA
Local bSalvar := {|| oFWSheet:Save(cGetFile(STR0009,STR0008)+'.xml') } //"Salvar Como..."
Local bAbrir := {|| cFile := cGetFile(STR0009,STR0010,,,.T.,) , IF(!empty(cFile), oFWSheet:Load(cFile),nil )  } //"Arquivo XML|*.xml","Escolha o arquivo"
Local bNovo := {||oFWSheet:Close(), oFWSheet:ReInit()}
Local bBloq	:= {|| At999BloCe(aCelulasBlock,oList)}
Local bLibera	:= {|| At999LibCe(aCelulasBlock,oList)}
Local cLista	:= ""
Local oMemo
Local cTexto := STR0011 + CHR(10) + CHR(10) +;	//A Planilha de forma��o de pre�os � utilizada para calcular o valor da presta��o de servi�os usando f�rmulas matem�ticas e rotinas em ADVPL.					
				  STR0012 + CHR(10) + CHR(10) +;	//� poss�vel atribuir os seguinte apelidos nas c�lulas da planilha para que no or�amento de servi�os sejam recuperados os valores de recursos humanos, materiais de implanta��o e materiais de consumo: 
				  STR0013 + CHR(10) +;	 			//TOTAL_RH - Este apelido � obrigat�rio e deve corresponder ao pre�o de venda unit�rio da forma��o do pre�o do recurso humano que se estiver calculando no momento.
				  STR0014 + CHR(10) +;	 			//TOTAL_MAT_IMP - Esta c�lula, quando presente, receber� o valor total do material de implanta��o estimado no or�amento de servi�os para o recurso humano manipulado.
				  STR0015 + CHR(10) +;				//TOTAL_MAT_CONS - Esta c�lula, quando presente, receber� o valor total do material de consumo estimado no or�amento de servi�os para o recurso humano manipulado.
				  STR0053 + CHR(10) +;				//TOTAL_LE_COB - Esta c�lula, quando presente, receber� a configura��o do tipo de cobran�a para o item da loca��o de equipamento.
				  STR0054 + CHR(10) +;				//TOTAL_LE_QUANT - Esta c�lula, quando presente, receber� a quantidade para o item da loca��o de equipamento.
				  STR0055 + CHR(10) + CHR(10) +;	//TOTAL_LE_VUNIT - Esta c�lula, quando presente, receber� o valor unit�rio para o item da loca��o de equipamento.
				  STR0016 + ; 						//A Planilha tamb�m permite configurar a quantidade de linhas, colunas, o tipo de c�lula que pode ser texto ou n�merico. Atrav�s do bot�o a��es � poss�vel criar uma nova planilha, abrir uma planilha a partir de um arquivo xml, salvar a planilha em arquivo xml
				  STR0017 + CHR(10) + CHR(10) +;	//(guardando a quantidade de linhas, colunas, nome, alias, valores, f�rmulas das c�lulas, c�lulas bloqueadas) e adicionar ou remover uma c�lula da lista de c�lulas liberadas ou bloqueadas para edi��o no or�amento de servi�os conforme tipo de planilha escolhido na cria��o do modelo.
				  STR0018 + ;							//As c�lulas da lista liberada ou bloqueada para edi��o ser�o gravadas para que no or�amento de servi�os seja poss�vel manipular apenas as celulas liberadas para edi��o. Se a lista for de c�lulas bloqueadas, apenas as c�lulas da lista ser�o bloqueadas pra edi��o e todas as demais ser�o liberadas.
				  STR0019 + CHR(10) + CHR(10) +;	//Se a lista de c�lulas for de c�lulas liberadas, apenas as c�lulas da lista ser�o liberadas para edi��o, todas as demais ser�o bloqueadas.
				  STR0050 								//"Para utilizar f�rmulas matem�ticas ou ADVPL � necess�rio utilizar o sinal de igual, =, exemplo: =VAL(SOMA1("10"))+1 ou =A1+A2 ou =A1+10 ou =U_USFUNC()"

If cTpPlan == "1"
	cLista := STR0020 //"Lista Liberada"
Else
	cLista := STR0021 //"Lista bloqueada"
EndIf
//---------------------------------------
// AUXILIARES , containers, botoes, etc
//---------------------------------------
oFWLayer	:= FWLayer():New()
oFWLayer:init( oPanel, .T. )
//oFWLayer:addLine( "Lin01", 22, .T. )
//oFWLayer:addCollumn("Col01", 90, .T., "Lin01" )
//oFWLayer:addCollumn("Col02", 10, .T., "Lin01" )
//oFWLayer:addWindow("Col01", "Win01", STR0022, 100, .f., .f., {||  },"Lin01" ) //"Instru��o"
//oFWLayer:addWindow("Col02", "Win03", cLista, 100, .F., .f., {|| Nil } ,"Lin01")
oFWLayer:addLine( "Lin02", 100, .T. )
oFWLayer:addCollumn("Col01", 100, .T., "Lin02" )
oFWLayer:setLinSplit( "Lin02", CONTROL_ALIGN_BOTTOM, {|| } )
oFWLayer:addWindow("Col01", "Win02", STR0023, 100,.F., .f., {|| Nil },"Lin02" ) //"Planilha"

oWinPlanilha	:= oFWLayer:getWinPanel("Col01"	, "Win02" ,"Lin02")

//oWinCampos		:= oFWLayer:getWinPanel("Col01"		, "Win01","Lin01" )
//oWinBloquead	:= oFWLayer:getWinPanel("Col02"	, "Win03","Lin01" )

//oList			:= tListBox():New(0,0,{|u|if(Pcount()>0,nList:=u,nList)},aCellList,80,45,,oWinBloquead,,,,.T.)

//@0.01,0.01 GET oMemo VAR cTexto OF oWinCampos MEMO size 540,52 FONT oWinCampos:oFont COLOR CLR_BLACK,CLR_HGRAY

//---------------------------------------
// PLANILHA
//---------------------------------------
oFWSheet := FWUIWorkSheet():New(oWinPlanilha,,75,15)

//adiciona menus
oFWSheet:AddItemMenu(STR0024,bNovo) //"Novo"
oFWSheet:AddItemMenu(STR0025,bAbrir) //"Abrir"
oFWSheet:AddItemMenu(STR0026,bSalvar) //"Salvar"
oFWSheet:AddItemMenu('-------------------') //"-------------------"
oFWSheet:AddItemMenu(STR0027,bBloq) //"Adicionar na Lista"
oFWSheet:AddItemMenu(STR0028,bLibera) //"Remover da Lista"
oFwSheet:SetMenuVisible(.T.,STR0029,50) //"A��es"

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If !Empty(cMemo)
	//At999CList(oList)
	If isBlind()
		oFWSheet:LoadXmlModel(cMemo)
	Else
		FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cMemo)}, Nil, STR0056)//"Carregando..."
	EndIf
	oFWSheet:Refresh(.T.)
	lCopyPl := .F.
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Cmt
	Realizar a grava��o dos dados
@sample 	At999Cmt() 
@since		10/10/2013       
@version	P11.90
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
@param		aCelulasBlock, Array, lista com as c�lulas adicionadas na lista.
@return	.T.
/*/
//------------------------------------------------------------------------------
Function At999Cmt(oModel,aCelulasBlock)

Local oMdlAbw := oModel:GetModel("ABWMASTER")
Local cCodP	:= oMdlAbw:GetValue("ABW_CODIGO")
Local bAfter	:= {|oModel,cID,cAlia| IIF(!lMdExemplo,At999GrvD(oModel,cID,cAlia),.T.)}
Local cRecno	:= ABW->(Recno())
Local cRevisa	:= ""
Local lRet		:= .T.

oModel:lModify := .T.

If lCopyPl
	oMdlAbw:SetValue("ABW_REVISA","001")
EndIf

If lRet .And. oMdlAbw:GetOperation() == MODEL_OPERATION_UPDATE

	oModel:SetValue("ABWMASTER","ABW_ULTIMA","2")
			
	lNewRevis := Aviso( STR0030, STR0031, { STR0032, STR0033 }, 2 ) == 1 //"Atencao !"###"Deseja gerar uma nova revisao deste modelo de planilha ?"###"Sim"###"Nao"
		
	At999VldPl(oModel)
		
	If lNewRevis
		cRevisa := Soma1( At999VfRev())
		At999NewRe(oModel,"ABWMASTER",cRevisa, aCelulasBlock)
		At999AlMem(oModel,aCelulasBlock)
		At999DesFl(cRecno)
	Else
		oModel:SetValue("ABWMASTER","ABW_ULTIMA","1")
		At999AlMem(oModel,aCelulasBlock, .f.)
		FWFormCommit(oModel,/*bBefore*/,bAfter,NIL)
		oMdlAbw:SetValue("ABW_ALTERA",.F.)
	EndIf
	
ElseIf lRet .And. oMdlAbw:GetOperation() == MODEL_OPERATION_INSERT
	
	oModel:SetValue("ABWMASTER","ABW_ULTIMA","1")
	At999AlMem(oModel,aCelulasBlock, .F.)
	FWFormCommit(oModel,/*bBefore*/,bAfter,NIL)
	oMdlAbw:SetValue("ABW_ALTERA",.F.)
	lMdExemplo := .F.

	oModel:SetValue("ABWMASTER","ABW_ULTIMA","1")
	At999AlMem(oModel,aCelulasBlock, .F.)
	FWFormCommit(oModel,/*bBefore*/,bAfter,NIL)
	oMdlAbw:SetValue("ABW_ALTERA",.F.)
	lMdExemplo := .F.
	
ElseIf oMdlAbw:GetOperation() == MODEL_OPERATION_DELETE
	
	nOpcDel	:=	Aviso(STR0034 ,STR0035 +CRLF+ STR0036,{STR0037,STR0038},3)  //"Selecione a op��o desejada" ,"Deseja excluir todas as revis�es desta planilha "#" ou somente a revis�o atual?",##"Todas"##"Atual"
							
	Do Case
		Case (nOpcDel == 1) // exclui todas as revis�es do modelo de planilha
			At999DelTd(cCodP)
		Case (nOpcDel == 2) // exclui somente esta revis�o
			FWFormCommit( oModel )
			At999RetRv(cCodP)
	EndCase
						
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999GrvD
	Realizar a grava��o do xml da planilha para o campo memo
@sample 	At999GrvD() 
@since		10/10/2013       
@version	P11.90
@param  	oModel, Objeto, 
@param  	cId, Caracter, 
@param  	cAlia, Caracter, 
/*/
//------------------------------------------------------------------------------
Function At999GrvD(oModel,cId,cAlia)

Local cPlan := ""

cPlan := oFWSheet:GetModel():GetXmlData()

RecLock(cAlia,.F.)
ABW->ABW_INSTRU := cPlan
ABW->(MsUnlock())
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999InDds
	Valida��o para excecutar o oModel	
@sample 	At999InDds() 
@since		10/10/2013       
@version	P11.90
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At999InDds(oModel)

Local aArea	:= GetArea()
Local oMdlAbw := oModel:GetModel("ABWMASTER")
Local cPerg	:= "TECA999"
Local nFator	:= Randomize(0, 100)

If oMdlAbw:GetOperation() == MODEL_OPERATION_UPDATE
	oMdlAbw:SetValue("ABW_FAKE",nFator)
Endif

If oMdlAbw:GetOperation() != MODEL_OPERATION_INSERT .OR. lCopyPl
	DbSelectArea("ABW")
	DbSetOrder(1)
	If DbSeek(xFilial("ABW")+ABW->ABW_CODIGO+ABW->ABW_REVISA)
		cMemo := oMdlAbw:GetValue("ABW_INSTRU")
		cTpPlan := oMdlAbw:GetValue("ABW_TPMODP")
	EndIf
Else
	Pergunte(cPerg)
	cTpPlan := Alltrim(STR(MV_PAR01))
	oModel:SetValue("ABWMASTER","ABW_TPMODP",cTpPlan)
	cMemo	:= ""
EndIf
If�(oMdlAbw:GetOperation() != MODEL_OPERATION_VIEW) .AND. (oMdlAbw:GetOperation() != MODEL_OPERATION_DELETE)
	oModel:lModify := .T.
EndIf
RestArea(aArea)
Return (cMemo)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999VldPl
	Valida��o de altera��o da planilha	
@sample 	At999VldPl() 
@since		10/10/2013       
@version	P11.90
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At999VldPl(oModel)

Local oMdlAbw := oModel:GetModel("ABWMASTER")

If cMemo <> oFWSheet:GetXmlModel(,,,,.F.,.T.,.F.)
	oMdlAbw:SetValue("ABW_ALTERA",.T.)
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999BloCe
	Adiciona as c�lulas no objeto oList
@sample 	At999BloCe() 
@since		14/10/2013       
@version	P11.90
@param		aCelulasBlock, Array, lista com as c�lulas adicionadas na lista
@param	 	oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Static Function At999BloCe(aCelulasBlock,oList)

Local nPosCel := 0

nPosCel := Ascan(aCelulasBlock,{|x| alltrim(x) == alltrim(oFwSheet:cCellSelec) })

If nPosCel == 0
	aAdd(aCelulasBlock, oFwSheet:cCellSelec)
	oList:Insert(oFwSheet:cCellSelec,Len(aCelulasBlock))
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999LibCe
	Remove as c�lulas do objeto oList
@sample 	At999LibCe() 
@since		10/10/2013       
@version	P11.90
@param		aCelulasBlock, Array, lista com as c�lulas adicionadas na lista
@param		oList, Object, Classe do TListBox
/*/
//------------------------------------------------------------------------------
Static Function At999LibCe(aCelulasBlock,oList)

Local nPosCel := 0

nPosCel := Ascan(aCelulasBlock,{|x| alltrim(x) == alltrim(oFwSheet:cCellSelec) })
If nPosCel > 0
	aDel(aCelulasBlock,nPosCel)
	aSize(aCelulasBlock,Len(aCelulasBlock)-1)
	oList:Del(nPosCel)
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999CpPl
	C�pia do registro escolhido 
@sample 	At999CpPl() 
@since		10/10/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At999CpPl()

Local aArea 		:= GetArea()
Local aAreaABW 	:= ABW->(GetArea())
Local lConfirma	:= .F.
Local lCancela		:= .F.
Local cCodPlan		:= ABW->ABW_CODIGO
Local cRevisa		:= ABW->ABW_REVISA
Local lRetorno		:= .T.

If lRetorno .and. ABW->(DbSeek(xFilial("ABW") + cCodPlan + cRevisa))

	nOperation	:= MODEL_OPERATION_INSERT

	oModel		:= FWLoadModel( 'TECA999' )
	lCopyPl	:= .T.
	oModel:SetOperation( nOperation ) // Inclus�o
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	oModel:SetValue("ABWMASTER","ABW_REVISA","001")
	At999SLoad(oModel)//controle para indicar model a ser considerado
	nRet		:= FWExecView( STR0007 , 'TECA999', nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnable'Butt'ons*/, /*bCancel*/ , "At999CpPl" /*cOperatId*/, /*cToolBar*/, oModel ) //"Copiar"
	At999SLoad(Nil)
	oModel:DeActivate()
EndIf
RestArea(aAreaABW)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999VfRev
	Verifica ultima revis�o da planilha	
@sample 	At999VfRev() 
@since		10/10/2013       
@version	P11.90
@return	cRev, Caracter, Revis�o do registro
/*/
//------------------------------------------------------------------------------
Function At999VfRev()

Local aArea		:= GetArea()
Local aAreaABW	:= ABW->(GetArea())
Local cCodP		:= ABW->ABW_CODIGO
Local cRev			:= ""

DbSelectArea("ABW")
DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO
If DbSeek(xFilial("ABW")+cCodP)
	While !EOF() .AND. xFilial("ABW")+cCodP == ABW->(ABW_FILIAL+ABW_CODIGO)
		cRev	:= ABW->ABW_REVISA
		ABW->(DbSkip())
	EndDo
EndIf
RestArea(aAreaABW)
RestArea(aArea)
Return cRev

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Vld
	Valida��o do apelido obrigat�rio da planilha 	
@sample 	At999Vld(oModel) 
@since		15/10/2013       
@version	P11.90
@param		oModel, Object, Classe do modelo de dados MpFormModel
/*/
//------------------------------------------------------------------------------
Function At999Vld(oModel)
Local oMdlAbw 	:= oModel:GetModel("ABWMASTER")
Local aArea		:= GetArea()
Local lRet		:= .T.
Local nFator	:= Randomize(0, 100)
Local cMsg		:= ""

If oMdlAbw:GetOperation() == MODEL_OPERATION_UPDATE .Or. oMdlAbw:GetOperation() == MODEL_OPERATION_INSERT
	If !At999VldCel(@cMsg)
		If !Empty(cMsg)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"",oModel:GetModel():GetId(), "",STR0030,	STR0057,'' ) //Aten��o##"Encontrado problemas nas formulas"
			AtShowLog(cMsg,STR0030,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)
			lRet := .F.
			oMdlAbw:SetValue("ABW_FAKE",nFator)
		EndIf
	EndIf
EndIf

If lRet .And. !At999CpCCT()
	If (oFWSheet:CellExists("TOTAL_RH"))
		If Empty(oFWSheet:GetCELLVALUE("TOTAL_RH"))
			Help(,, "At999Vld",,STR0051,1,0,,,,,,{STR0073}) //"A c�lula com o apelido TOTAL_RH n�o foi preenchida."##"Informe um conte�do para dar andamento � grava��o"
			lRet	:= .F.
		EndIf
	Else
		Help(,, "At999Vld",,STR0039,1,0,,,,,,{STR0073}) //"N�o foi definido o apelido TOTAL_RH obrigat�rio do modelo de planilha"##"Informe um conte�do para dar andamento � grava��o"
		lRet	:= .F.
	EndIf
EndIf	

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999NewRe
	Gera��o da nova revis�o para planilha	
@sample 	At999NewRe(oModel,cModel,cRevisa) 
@since		16/10/2013       
@version	P11.90
@param		oModel, Object, Classe do modelo de dados MpFormModel
@param		cModel, Caracter, 
@param		cRevisa, Caracter, C�digo da revis�o
/*/
//------------------------------------------------------------------------------
Function At999NewRe(oModel,cModel,cRevisa, aCellBlck)

Local aArea	:= GetArea()
Local aAreaABW	:= ABW->(GetArea())
Local cCodP	:= oModel:GetValue(cModel,"ABW_CODIGO")
Local cDesc	:= oModel:GetValue(cModel,"ABW_DESC")
Local aStruct	:= oModel:GetModel(cModel):GetStruct():aFields
Local aDados	:= oModel:GetModel(cModel):GetData()
Local aAux		:= {}
Local aCopy	:= {}
Local nX		:= 0
Local nY		:= 0
Local nCont	:= 0
Local nPosField	:= 0
Local cList := ""

Default aCellBlck := {}


cList := At999AlMem(oModel,aCellBlck, .T.)

For nX := 1 to Len(aStruct)
	aAdd(aAux,{aStruct[nX][3], aDados[nX][2] })
Next nX

aAdd(aCopy,aAux)
aAux := {}

For nY:= 1 to Len(aCopy)
	RecLock("ABW",.T.)
	For nCont := 1 To ABW->(FCount())
		Do Case
		Case ( FieldName(nCont) == "ABW_CODIGO" )
			FieldPut(nCont,cCodP) //C�digo da planilha
		Case ( FieldName(nCont) == "ABW_DESC" )
			FieldPut(nCont, cDesc ) //Descri��o
		Case ( FieldName(nCont) == "ABW_REVISA" )
			FieldPut(nCont, cRevisa) //Revis�o da planilha
		Case ( FieldName(nCont) == "ABW_INSTRU" )
			FieldPut(nCont, oFWSheet:GetModel():GetXmlData() ) //Xml da planilha
		Case ( FieldName(nCont) == "ABW_ULTIMA" )
			FieldPut(nCont, "1")
		Case (  FieldName(nCont) ==  "ABW_LISTA")
			FieldPut(nCont, cList)
		OtherWise
			nPosField := AScan(aCopy[nY], {|x| x[1] == FieldName(nCont)} )
			FieldPut(nCont,aCopy[nY][nPosField][2])
		EndCase
	Next nCont
	ABW->( MsUnLock() )
Next nY
RestArea(aAreaABW)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999DelTd
	Deleta todas as revis�es do modelo da planilha	
@sample 	At999DelTd(cCodP) 
@since		16/10/2013       
@version	P11.90
@param		cCodP, Caracter, C�digo da planilha
/*/
//------------------------------------------------------------------------------
Function At999DelTd(cCodP)

DbSelectArea("ABW")
DbSetOrder(1)
If ABW->(DbSeek(xFilial("ABW")+cCodP))
	While ABW->(!EOF()) .AND. ABW->ABW_FILIAL == xFilial("ABW") .AND. ABW->ABW_CODIGO == cCodP
		RecLock( "ABW", .F. )
		ABW->( DbDelete() )
		ABW->( MsUnLock() )
		ABW->(DbSkip())
	EndDo
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999RetRv
	Marca a ultima revis�o com a flag de ultima revis�o			
@sample 	At999RetRv(cCodP) 
@since		16/10/2013       
@version	P11.90
@param		cCodP, Caracter, C�digo da planilha
/*/
//------------------------------------------------------------------------------
Function At999RetRv(cCodP)

Local aArea		:= GetArea()
Local aAreaABW 	:= ABW->(GetArea())
Local cRev 		:= At999VfRev()

DbSelectArea("ABW")
DbSetOrder(1)
If !Empty(cRev)
	If ABW->(DbSeek(xFilial("ABW") + cCodP + cRev))
		If Reclock("ABW", .F.)
			ABW->ABW_ULTIMA := "1"
			ABW->( MsUnLock() )
		EndIf
	EndIf
EndIf
RestArea(aAreaABW)
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999DesFl
	Desabilita a flag de ultima revis�o		
@sample 	At999DesFl(cRecno) 
@since		10/10/2013       
@version	P11.90
@param		cRecno, Caracter, registro posicionado
/*/
//------------------------------------------------------------------------------
Function At999DesFl(cRecno)

Local aArea		:= GetArea()
Local aAreaABW 	:= ABW->(GetArea())

ABW->(DbGoto(cRecno))
If Reclock("ABW", .F.)
	ABW->ABW_ULTIMA := "2"
	ABW->( MsUnLock() )
EndIf
ABW->(RestArea(aAreaABW))
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999AlMem
	Atribui as c�lulas adicionadas na lista para o campo memo (ABW_LISTA)	
@sample 	At999AlMem() 
@since		18/10/2013       
@version	P11.90
@param		aCelulasBlock, Array, lista com as c�lulas adicionadas na lista
/*/
//------------------------------------------------------------------------------
Function At999AlMem(oModel,aCelulasBlock, lField)

Local aArea := GetArea()
Local nX	:= 0
Local cList	:= ""
Local oMdlABW	:= oModel:GetModel("ABWMASTER")

DEFAULT lField := .F.

For nX := 1 To Len(aCelulasBlock)
	cList	+= Alltrim(aCelulasBlock[nX])+";"
Next
If !lField 
	oMdlABW:SetValue("ABW_LISTA",cList)
EndIf
RestArea(aArea)
Return cList

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999CList
	Atualiza a lista com as c�lulas gravadas anteriormente.	
@sample 	At999CList() 
@since		18/10/2013       
@version	P11.90
@param		oList, Objeto, Classe do TLisBox
/*/
//------------------------------------------------------------------------------
Function At999CList(oList)

Local aArea := GetArea()
Local cList := ABW->ABW_LISTA
Local nX		:= 0

If !Empty(cList)
	aCelulasBlock := StrTokArr(cList,";")
	oList:Reset()
	For nX := 1 To Len(aCelulasBlock)
		oList:Insert(aCelulasBlock[nX],nX)
	Next
EndIf
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999CadEx
	Cadastro do Modelo exemplo.	
@sample 	At999CadEx() 
@since		28/10/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At999CadEx

Local aArea 		:= GetArea()
Local aAreaABW		:= ABW->(GetArea())
Local oModel
Local lRet 		:= .F.

DbSelectArea("ABW")
ABW->(DbSetOrder(1))

If ABW->(!DbSeek(xFilial("ABW")+'000001'))

	oModel:=FwloadModel('TECA999')
	oModel:SetOperation(3)
	oModel:Activate()

	oModel:SetValue("ABWMASTER","ABW_FILIAL",xFilial("ABW"))
	oModel:SetValue("ABWMASTER","ABW_CODIGO",'000001')
	oModel:SetValue("ABWMASTER","ABW_DESC",STR0040)  //"Modelo Exemplo"
	oModel:SetValue("ABWMASTER","ABW_REVISA","001")
	oModel:SetValue("ABWMASTER","ABW_INSTRU",At999MdExe())
	oModel:SetValue("ABWMASTER","ABW_TPMODP",cTpPlan)
	oModel:SetValue("ABWMASTER","ABW_LISTA","")

	lMdExemplo := .T.

	If lRet := oModel:VldData()
		oModel:CommitData()
	EndIf

	If !lRet

		aErro := oModel:GetErrorMessage()

		AutoGrLog( STR0041 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formul�rio de origem:"
		AutoGrLog( STR0042 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: "
		AutoGrLog( STR0043 + ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formul�rio de erro: "
		AutoGrLog( STR0044 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
		AutoGrLog( STR0045 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
		AutoGrLog( STR0046 + ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
		AutoGrLog( STR0047 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solu��o: "
		AutoGrLog( STR0048 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribu�do: "
		AutoGrLog( STR0049 + ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "

		MostraErro()

		// Desativamos o Model 
		oModel:DeActivate()
	EndIf

EndIf
RestArea(aArea)
RestArea(aAreaABW)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999MdExe
	Carrega XML do Modelo exemplo.	
@sample 	At999MdExe() 
@since		28/10/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At999MdExe()

Local cXml := ''

cXml += '<?xml version="1.0" encoding="UTF-8"?>'
cXml += '<FWMODELSHEET Operation="4" version="1.01">'
cXml += '	<MODEL_SHEET modeltype="FIELDS" >'
cXml += '		<TOTLINES order="1">'
cXml += '			<value>75</value>'
cXml += '		</TOTLINES>'
cXml += '		<TOTCOLUMNS order="2">'
cXml += '			<value>15</value>'
cXml += '		</TOTCOLUMNS>'
cXml += '		<MODEL_CELLS modeltype="GRID" optional="1">'
cXml += '		<struct>'
cXml += '			<NAME order="1"></NAME>'
cXml += '			<NICKNAME order="2"></NICKNAME>'
cXml += '			<FORMULA order="3"></FORMULA>'
cXml += '			<VALUE order="4"></VALUE>'
cXml += '			<PICTURE order="5"></PICTURE>'
cXml += '			<BLOCKCELL order="6"></BLOCKCELL>'
cXml += '			<BLOCKNAME order="7"></BLOCKNAME>'
cXml += '		</struct>'
cXml += '		<items>'
cXml += '			<item id="1" deleted="0" ><NAME>A1</NAME><VALUE>|| - MAO - DE - OBRA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="2" deleted="0" ><NAME>G1</NAME><VALUE>PORCENT(%)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="3" deleted="0" ><NAME>I1</NAME><VALUE>R$</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="4" deleted="0" ><NAME>A2</NAME><VALUE>01 - SALARIO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="5" deleted="0" ><NAME>I2</NAME><VALUE>1496.43</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="6" deleted="0" ><NAME>A3</NAME><VALUE>02 - ADICIONAL DE INSALUBRIDADE MEDIA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="7" deleted="0" ><NAME>I3</NAME><VALUE>299.29</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="8" deleted="0" ><NAME>A4</NAME><VALUE>TOTAL DAS REMUNERACOES</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="9" deleted="0" ><NAME>I4</NAME><FORMULA>=(I2+I3)</FORMULA><VALUE>1795.72</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="10" deleted="0" ><NAME>A6</NAME><VALUE>RESERVA TECNICA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="11" deleted="0" ><NAME>G6</NAME><VALUE>0.02</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="12" deleted="0" ><NAME>I6</NAME><FORMULA>=(I4*G6)/100</FORMULA><VALUE>0.359144</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="13" deleted="0" ><NAME>D7</NAME><VALUE>TOTAL</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="14" deleted="0" ><NAME>I7</NAME><FORMULA>=I4+I6</FORMULA><VALUE>1796.079144</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="15" deleted="0" ><NAME>A8</NAME><VALUE>II - ENCARGOS SOCIAIS: INC. S/O VALOR DA REMUNERACAO + RESERVA TECNICA.</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="16" deleted="0" ><NAME>A9</NAME><VALUE>GRUPO &quot;A&quot; - OBRIGACOES SOCIAIS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="17" deleted="0" ><NAME>G9</NAME></item>'
cXml += '			<item id="18" deleted="0" ><NAME>A10</NAME><VALUE>A1 - PREVIDENCIA SOCIALINSS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="19" deleted="0" ><NAME>G10</NAME><VALUE>20</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="20" deleted="0" ><NAME>I10</NAME><FORMULA>=(I7*G10)/100</FORMULA><VALUE>359.2158288</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="21" deleted="0" ><NAME>A11</NAME><VALUE>A2 - FGTS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="22" deleted="0" ><NAME>G11</NAME><VALUE>8</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="23" deleted="0" ><NAME>I11</NAME><FORMULA>=(I7*G11)/100</FORMULA><VALUE>143.68633152</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="24" deleted="0" ><NAME>A12</NAME><VALUE>A3 - SALARIO EDUCACAO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="25" deleted="0" ><NAME>G12</NAME><VALUE>2.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="26" deleted="0" ><NAME>I12</NAME><FORMULA>=(I7*G12)/100</FORMULA><VALUE>44.9019786</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="27" deleted="0" ><NAME>A13</NAME><VALUE>A4 - SESC</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="28" deleted="0" ><NAME>G13</NAME><VALUE>1.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="29" deleted="0" ><NAME>I13</NAME><FORMULA>=(I7*G13)/100</FORMULA><VALUE>26.94118716</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="30" deleted="0" ><NAME>A14</NAME><VALUE>A5 - SENAC</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="31" deleted="0" ><NAME>G14</NAME><VALUE>1</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="32" deleted="0" ><NAME>I14</NAME><FORMULA>=(I7*G14)/100</FORMULA><VALUE>17.96079144</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="33" deleted="0" ><NAME>A15</NAME><VALUE>A6 - INCRA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="34" deleted="0" ><NAME>G15</NAME><VALUE>0.2</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="35" deleted="0" ><NAME>I15</NAME><FORMULA>=(I7*G15)/100</FORMULA><VALUE>3.59215829</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="36" deleted="0" ><NAME>A16</NAME><VALUE>A7 - SEGURO ACIDENTE DE TRABALHO (SAT/INSS)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="37" deleted="0" ><NAME>G16</NAME><VALUE>3</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="38" deleted="0" ><NAME>I16</NAME><FORMULA>=(I7*G16)/100</FORMULA><VALUE>53.88237432</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="39" deleted="0" ><NAME>A17</NAME><VALUE>A8 - SEBRAE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="40" deleted="0" ><NAME>G17</NAME><VALUE>0.6</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="41" deleted="0" ><NAME>I17</NAME><FORMULA>=(I7*G17)/100</FORMULA><VALUE>10.77647486</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="42" deleted="0" ><NAME>A18</NAME><VALUE>TOTAL DO GRUPO &quot;A&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="43" deleted="0" ><NAME>G18</NAME><FORMULA>=G10+G11+G12+G13+G14+G15+G16+G17</FORMULA><VALUE>36.8</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="44" deleted="0" ><NAME>I18</NAME><FORMULA>=I10+I11+I12+I13+I14+I15+I16+I17</FORMULA><VALUE>660.95712499</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="45" deleted="0" ><NAME>A20</NAME><VALUE>GRUPO &quot;B&quot; - TEMPO DE TRABALHO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="46" deleted="0" ><NAME>A21</NAME><VALUE>B1 - FERIAS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="47" deleted="0" ><NAME>G21</NAME><VALUE>9.04</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="48" deleted="0" ><NAME>I21</NAME><FORMULA>=(I7*G21)/100</FORMULA><VALUE>162.36555462</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="49" deleted="0" ><NAME>A22</NAME><VALUE>B2 - FALTAS LEGAIS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="50" deleted="0" ><NAME>G22</NAME><VALUE>0.1</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="51" deleted="0" ><NAME>I22</NAME><FORMULA>=(I7*G22)/100</FORMULA><VALUE>1.79607914</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="52" deleted="0" ><NAME>A23</NAME><VALUE>B3 - AUSENCIA POR DOENCA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="53" deleted="0" ><NAME>G23</NAME><VALUE>1.61</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="54" deleted="0" ><NAME>I23</NAME><FORMULA>=(I7*G23)/100</FORMULA><VALUE>28.91687422</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="55" deleted="0" ><NAME>A24</NAME><VALUE>B4 - LICENCA PARTENIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="56" deleted="0" ><NAME>G24</NAME><VALUE>0.03</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="57" deleted="0" ><NAME>I24</NAME><FORMULA>=(I7*G24)/100</FORMULA><VALUE>0.53882374</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="58" deleted="0" ><NAME>A25</NAME><VALUE>B5 - ACIDENTE DE TRABALHO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="59" deleted="0" ><NAME>G25</NAME><VALUE>0.05</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="60" deleted="0" ><NAME>I25</NAME><FORMULA>=(I7*G25)/100</FORMULA><VALUE>0.89803957</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="61" deleted="0" ><NAME>A26</NAME><VALUE>B6 - AVISO PREVIO TRABALHADO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="62" deleted="0" ><NAME>G26</NAME><VALUE>0.08</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="63" deleted="0" ><NAME>I26</NAME><FORMULA>=(I7*G26)/100</FORMULA><VALUE>1.43686332</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="64" deleted="0" ><NAME>A27</NAME><VALUE>TOTAL DO GRUPO &quot;B&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="65" deleted="0" ><NAME>G27</NAME><FORMULA>=G21+G22+G23+G24+G25+G26</FORMULA><VALUE>10.91</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="66" deleted="0" ><NAME>I27</NAME><FORMULA>=I21+I22+I23+I24+I25+I26</FORMULA><VALUE>195.95223461</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="67" deleted="0" ><NAME>A29</NAME><VALUE>GRUPO &quot;C&quot; - GRATIFICACOES</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="68" deleted="0" ><NAME>A30</NAME><VALUE>C1 - ADICIONAL DE 1/3 DE FERIAS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="69" deleted="0" ><NAME>G30</NAME><VALUE>3.01</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="70" deleted="0" ><NAME>I30</NAME><FORMULA>=(I7*G30)/100</FORMULA><VALUE>54.06198223</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="71" deleted="0" ><NAME>A31</NAME><VALUE>C2 - 13º SALARIO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="72" deleted="0" ><NAME>G31</NAME><VALUE>9.17</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="73" deleted="0" ><NAME>H31</NAME></item>'
cXml += '			<item id="74" deleted="0" ><NAME>I31</NAME><FORMULA>=(I7*G31)/100</FORMULA><VALUE>164.7004575</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="75" deleted="0" ><NAME>A32</NAME><VALUE>TOTAL DO GRUPO &quot;C&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="76" deleted="0" ><NAME>G32</NAME><FORMULA>=G30+G31</FORMULA><VALUE>12.18</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="77" deleted="0" ><NAME>I32</NAME><FORMULA>=I30+I31</FORMULA><VALUE>218.76243973</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="78" deleted="0" ><NAME>A34</NAME><VALUE>GRUPO &quot;D&quot; - INDENIZACOES</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="79" deleted="0" ><NAME>A35</NAME><VALUE>D1 - AVISO PREVIO INDENIZADO + FERIAS E 1/3 CONST. + 13º + CONTRIB. SOCIAL</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="80" deleted="0" ><NAME>G35</NAME><VALUE>1.63</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="81" deleted="0" ><NAME>I35</NAME><FORMULA>=(I7*G35)/100</FORMULA><VALUE>29.27609005</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="82" deleted="0" ><NAME>A36</NAME><VALUE>D2 - FGTS SOBRE AVISO PREVIO + 13º INDENIZADO</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="83" deleted="0" ><NAME>G36</NAME><VALUE>0.12</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="84" deleted="0" ><NAME>I36</NAME><FORMULA>=(I7*G36)/100</FORMULA><VALUE>2.15529497</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="85" deleted="0" ><NAME>A37</NAME><VALUE>D3 - INCIDENCIA COMPENSATORIA POR DEMISSAO S/ JUSTA CAUSA</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="86" deleted="0" ><NAME>G37</NAME><VALUE>2.4</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="87" deleted="0" ><NAME>I37</NAME><FORMULA>=(I7*G37)/100</FORMULA><VALUE>43.10589946</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="88" deleted="0" ><NAME>A38</NAME><VALUE>TOTAL DO GRUPO &quot;D&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="89" deleted="0" ><NAME>G38</NAME><FORMULA>=G35+G36+G37</FORMULA><VALUE>4.15</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="90" deleted="0" ><NAME>I38</NAME><FORMULA>=I35+I36+I37</FORMULA><VALUE>74.53728448</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="91" deleted="0" ><NAME>A40</NAME><VALUE>GRUPO &quot;E&quot; - LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="92" deleted="0" ><NAME>A41</NAME><VALUE>E1 - APROVISIONAMENTO DE FERIAS SOBRE LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="93" deleted="0" ><NAME>G41</NAME><VALUE>0.02</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="94" deleted="0" ><NAME>I41</NAME><FORMULA>=(I7*G41)/100</FORMULA><VALUE>0.35921583</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="95" deleted="0" ><NAME>A42</NAME><VALUE>E2 - APROVISIONAMENTO 1/3 CONSTITUCIONAL FERIAS SOBRE LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="96" deleted="0" ><NAME>G42</NAME><VALUE>0.01</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="97" deleted="0" ><NAME>I42</NAME><FORMULA>=(I7*G42)/100</FORMULA><VALUE>0.17960791</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="98" deleted="0" ><NAME>A43</NAME><VALUE>E3 - INCIDENCIA DO GRUPO &quot;A&quot; SOBRE GRUPO LICENCA MATERNIDADE</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="99" deleted="0" ><NAME>G43</NAME><VALUE>0.1</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="100" deleted="0" ><NAME>I43</NAME><FORMULA>=(I7*G43)/100</FORMULA><VALUE>1.79607914</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="101" deleted="0" ><NAME>A44</NAME><VALUE>TOTAL DO GRUPO &quot;E&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="102" deleted="0" ><NAME>G44</NAME><FORMULA>=G41+G42+G43</FORMULA><VALUE>0.13</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="103" deleted="0" ><NAME>I44</NAME><FORMULA>=I41+I42+I43</FORMULA><VALUE>2.33490288</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="104" deleted="0" ><NAME>A46</NAME><VALUE>GRUPO &quot;F&quot; - INCIDENCIA DO GRUPO &quot;A&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="105" deleted="0" ><NAME>A47</NAME><VALUE>F1 - INCIDENCIA GRUPO A X (GRUPO B + C)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="106" deleted="0" ><NAME>G47</NAME><VALUE>8.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="107" deleted="0" ><NAME>I47</NAME><FORMULA>=(I7*G47)/100</FORMULA><VALUE>152.66672724</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="108" deleted="0" ><NAME>A48</NAME><VALUE>TOTAL DO GRUPO &quot;F&quot;</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="109" deleted="0" ><NAME>G48</NAME><FORMULA>=G47</FORMULA><VALUE>8.5</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="110" deleted="0" ><NAME>I48</NAME><FORMULA>=I47</FORMULA><VALUE>152.66672724</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="111" deleted="0" ><NAME>A50</NAME><VALUE>VALOR DOS ENCARGOS SOCIAIS</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="112" deleted="0" ><NAME>G50</NAME><FORMULA>=G18+G27+G32+G38+G44+G48</FORMULA><VALUE>72.67</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="113" deleted="0" ><NAME>I50</NAME><FORMULA>=(I7*G50)/100</FORMULA><VALUE>1305.21071394</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '			<item id="114" deleted="0" ><NAME>A52</NAME><VALUE>VALOR TOTAL DO MONTANTE &quot;A&quot;  (REMUNERACAO + RESERVA TECNICO + VALOR DOS ENCARGOS SOCIAIS)</VALUE><PICTURE>@!</PICTURE></item>'
cXml += '			<item id="115" deleted="0" ><NAME>I52</NAME><NICKNAME>TOTAL_RH</NICKNAME><FORMULA>=I7+I50</FORMULA><VALUE>3101.28985794</VALUE><PICTURE>@E 999,999,999.99</PICTURE></item>'
cXml += '		</items>'
cXml += '		</MODEL_CELLS>'
cXml += '	</MODEL_SHEET>'
cXml += '</FWMODELSHEET>'
Return cXml

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT999GLoad
Getter do modelo 

@since 17/10/2014
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function AT999GLoad()	
Return oCharge

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999SLoad
Setter do model
@since 17/10/2014
@version 1.0
@param oModel, FormModel, Model
/*/
//------------------------------------------------------------------------------
Static Function At999SLoad(oModel)
oCharge := oModel
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999VldCel
Valida��o de formulas
@since 04/03/2022
@version 1.0
@param cMsgErro, String com a mensagem de erro, enviado por referencia
/*/
//------------------------------------------------------------------------------
Static Function At999VldCel(cMsgErro)
Local lRet		:= .T.
Local aCelsErro	:= {}
Local cMsgCel	:= ""
Local cMsgCel1	:= ""
Local cMsgForm	:= ""
Local cMsgForm1	:= ""
Local nX 		:= 0

If MethIsMemberOf(oFWSheet,"VldFormulas") .And. !oFWSheet:VldFormulas(aCelsErro)
	If Len(aCelsErro) > 0
		cMsgCel	:= STR0058 //"Houve Erro na seguinte celula: "
		cMsgForm := STR0059 //"e na seguinte formula "
		For nX := 1 To Len(aCelsErro)
			cMsgCel1 := CRLF + aCelsErro[nX][2] + CRLF
			cMsgForm1 := CRLF + aCelsErro[nX][1] + CRLF
			cMsgForm1 += "----------------------------------------------" + CRLF	
			cMsgErro += cMsgCel + cMsgCel1 + cMsgForm + cMsgForm1
		Next nX
	EndIf 	
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} At999ConAA0()
Constru��o da consulta especifica do campo ABW_CODAA0 Base Operacional

@author Kaique Schiller
@since  08/07/2022
/*/
//------------------------------------------------------------------
Function At999ConAA0()
Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= "AA0REI"
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgEscTela	:= Nil
Local cQry			:= At999Qry("AA0")
Local aIndex		:= {}
Local aSeek 		:= {}
Local cProfID		:= "AA0REI"  //Indica o ID do browse para recuperar as informa��es do usuario	

Aadd( aSeek, { STR0060, {{"","C",TamSX3("AA0_CODIGO")[1],0,STR0060,,}} } )	 // "C�digo" ### "C�digo"
Aadd( aSeek, { STR0061, {{"","C",TamSX3("AA0_DESCRI")[1],0,STR0061,,}}}) // "Descri��o" ### "Descri��o"

Aadd( aIndex, "AA0_CODIGO" )
Aadd( aIndex, "AA0_DESCRI")
Aadd( aIndex, "AA0_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

IF !isBlind()
	nSuperior := 0
	nEsquerda := 0	
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65
	
	DEFINE MSDIALOG oDlgEscTela TITLE STR0062 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Base Operacional x CCT"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0062)  // "Base Operacional x CCT"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetProfileID(cProfID)

	oBrowse:SetDoubleClick({ || cRetCod := (oBrowse:Alias())->AA0_CODIGO, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0063), {|| cRetCod   := (oBrowse:Alias())->AA0_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0064),  {||  cRetCod  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  AA0_CODIGO  } TITLE STR0065 SIZE TamSX3("AA0_CODIGO")[1] 	OF oBrowse //"C�digo"
	ADD COLUMN oColumn DATA { ||  AA0_DESCRI } 	TITLE STR0061 SIZE TamSX3("AA0_DESCRI")[1] 	OF oBrowse //"Descri��o"

	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At999ConSRJ()
Constru��o da consulta especifica do campo ABW_FUNCAO Fun��o

@author Kaique Schiller
@since  08/07/2022
/*/
//------------------------------------------------------------------
Function At999ConSRJ(cCodBase)
Local lRet			:= .F.
Local oBrowse		:= Nil
Local cAls			:= "SRJRI4"
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgEscTela	:= Nil
Local cQry			:= At999Qry("SRJ",cCodBase)
Local aIndex		:= {}
Local aSeek 		:= {}
Local cProfID		:= "SRJRI4"  //Indica o ID do browse para recuperar as informa��es do usuario	
Default cCodBase := ""

Aadd( aSeek, { STR0060, {{"","C",TamSX3("RJ_FUNCAO")[1],0,STR0060,,}} } )	// "C�digo" ### "C�digo"
Aadd( aSeek, { STR0061, {{"","C",TamSX3("RJ_DESC")[1],0,STR0061,,}}}) // "Descri��o" ### "Descri��o"

Aadd( aIndex, "RJ_FUNCAO" )
Aadd( aIndex, "RJ_DESC")
Aadd( aIndex, "RJ_FILIAL")  // adicionado para n�o ter problema de n�o encontrar o �ltimo �ndice, em caso de adicionar mais deixe a filial por �ltimo

IF !isBlind()
	nSuperior := 0
	nEsquerda := 0	
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65
	
	DEFINE MSDIALOG oDlgEscTela TITLE STR0067 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL // "Fun��o x CCT"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(STR0067)  // "Fun��o x CCT"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetProfileID(cProfID)

	oBrowse:SetDoubleClick({ || cRetCod := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T. ,oDlgEscTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0063), {|| cRetCod   := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0064),  {||  cRetCod  := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()

	ADD COLUMN oColumn DATA { ||  RJ_FUNCAO  } 	TITLE STR0068 SIZE TamSX3("RJ_FUNCAO")[1] 	OF oBrowse //"Cod. Fun��o"
	ADD COLUMN oColumn DATA { ||  RJ_DESC } 	TITLE STR0061 SIZE TamSX3("RJ_DESC")[1] 	OF oBrowse //"Descri��o"
	ADD COLUMN oColumn DATA { ||  WY_CODIGO  } 	TITLE STR0066 SIZE TamSX3("WY_CODIGO")[1] 	OF oBrowse //"C�digo CCT"
	ADD COLUMN oColumn DATA { ||  WY_DESC } 	TITLE STR0061 SIZE TamSX3("WY_DESC")[1] 	OF oBrowse //"Descri��o"

	oBrowse:Activate()
	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At999RetCd()
Retorno da consulta especifica

@author Kaique Schiller
@since  08/07/2022
/*/
//------------------------------------------------------------------
Function At999RetCd()
Return cRetCod

//-------------------------------------------------------------------
/*/{Protheus.doc} At999VldBs()
Valida��o da Base Operacional x CCT
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Function At999VldBs(cCodBase)
Local lRet := .T. 
Local cQuery := ""
Local cAliasAA0 := ""
Default cCodBase := ""

If !Empty(cCodBase)
	cQuery := At999Qry("AA0",cCodBase)
	cAliasAA0 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA0,.T.,.T.)
	If (cAliasAA0)->(Eof())
		Help(,, "At999VldBs",,STR0069,1,0,,,,,,{STR0070}) //"N�o existe essa base operacional atrelada na CCT."##"Realize a amarra��o da base operacional com a CCT."
		lRet := .F.
	Endif
	(cAliasAA0)->(DbCloseArea())
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At999VldFn()
Valida��o da Fun��o x CCT
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Function At999VldFn(cCodBase,cCodFun)
Local lRet := .T.
Local cQuery := ""
Local cAliasSRJ := ""
Default cCodBase := ""
Default cCodFun := ""

If !Empty(cCodFun)
	cQuery := At999Qry("SRJ",cCodBase,cCodFun)
	cAliasSRJ := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRJ,.T.,.T.)
	If (cAliasSRJ)->(Eof())
		Help(,, "At999VldFn",,STR0071,1,0,,,,,,{STR0072}) //"N�o existe essa fun��o atrelada na CCT."##"Realize a amarra��o da fun��o com a CCT."
		lRet := .F.
	Endif
	(cAliasSRJ)->(DbCloseArea())
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At999Qry()
Valida��o da Fun��o x CCT
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Static Function At999Qry(cTbl,cCodBase,cCodFun)
Local cQry := ""
Default cTbl := ""
Default cCodBase := ""
Default cCodFun := ""

If cTbl == "AA0"
	cQry := " SELECT AA0_FILIAL, AA0_CODIGO, AA0_DESCRI "
	cQry += " FROM " + RetSqlName("AA0") + " AA0 "
	cQry += " INNER JOIN "+ RetSQLName('REI')  + " REI ON REI_FILIAL = '" + xFilial("REI") + "' AND REI.REI_CODAA0 = AA0.AA0_CODIGO"
	cQry += " AND REI.D_E_L_E_T_ =  ' ' "
	cQry += " INNER JOIN "+ RetSQLName('SWY')  + " SWY ON SWY.WY_FILIAL = '" + xFilial("SWY") + "' AND SWY.WY_CODIGO = REI.REI_CODCCT"
	cQry += " AND SWY.D_E_L_E_T_ =  ' ' "
	cQry += " WHERE AA0.AA0_FILIAL = '" +  xFilial('AA0') + "'"
	If !Empty(cCodBase)
		cQry += " AND AA0.AA0_CODIGO = '" + cCodBase + "' "
	Endif
	cQry += " AND AA0.D_E_L_E_T_ =  ' ' "
	cQry += " GROUP BY AA0_FILIAL, AA0_CODIGO, AA0_DESCRI "
ElseIf cTbl == "SRJ"
	cQry := " SELECT RJ_FILIAL, RJ_FUNCAO, RJ_DESC, WY_CODIGO, WY_DESC "
	cQry += " FROM " + RetSqlName("SRJ") + " SRJ "
	cQry += " INNER JOIN "+ RetSQLName('RI4')  + " RI4 ON RI4_FILIAL = '" + xFilial("RI4") + "' AND RI4.RI4_CODSRJ = SRJ.RJ_FUNCAO"
	cQry += " AND RI4.D_E_L_E_T_ =  ' ' "
	cQry += " INNER JOIN "+ RetSQLName('SWY')  + " SWY ON SWY.WY_FILIAL = '" + xFilial("SWY") + "' AND SWY.WY_CODIGO = RI4.RI4_CODCCT"
	cQry += " AND SWY.D_E_L_E_T_ =  ' ' "
	If !Empty(cCodBase)
		cQry += " INNER JOIN "+ RetSQLName('REI')  + " REI ON REI_FILIAL = '" + xFilial("REI") + "' AND REI.REI_CODCCT = RI4.RI4_CODCCT"
		cQry += " AND REI.REI_CODAA0 = '" + cCodBase + "' "
		cQry += " AND REI.D_E_L_E_T_ =  ' ' "
	Endif
	cQry += " WHERE SRJ.RJ_FILIAL = '" +  xFilial('SRJ') + "'"
	If !Empty(cCodFun)
		cQry += " AND SRJ.RJ_FUNCAO = '" + cCodFun + "' "
	Endif
	cQry += " AND SRJ.D_E_L_E_T_ =  ' ' "
Endif

cQry := ChangeQuery(cQry)

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} At999CpCCT()
Verificar se existe os campos e o parametro MV_TECXRH est� ativo.
@author Kaique Schiller
@since  11/07/2022
/*/
//------------------------------------------------------------------
Function At999CpCCT()
Local lRet := .F.

If SuperGetMv("MV_TECXRH",,.F.) .And. ABW->( ColumnPos('ABW_CODAA0') ) > 0 ;
								.And. ABW->( ColumnPos('ABW_FUNCAO') ) > 0 ;
								.And. ABW->( ColumnPos('ABW_SALARI') ) > 0 ;
								.And. ABW->( ColumnPos('ABW_CODTCW') ) > 0 ;
								.And. TableInDic("REI") .And. TableInDic("RI4")
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At999CarPl()
Realiza o carregamento da Planilha x CCT
@author Kaique Schiller
@since  12/07/2022
/*/
//------------------------------------------------------------------
Static Function At999CarPl(oMdl)
Local lRet := .T.
Local cXml := ""
Local oPlanXml :=  Nil
Default oMdl := Nil

If MsgYesNo(STR0074, STR0075 )//"Ao realizar o carregamento da planilha o sistema sobrescrever� as linhas e colunas abaixo, gostaria de continuar?"##"Aviso importante"	
	cXml := At999ExePl(oMdl:GetValue("ABWMASTER","ABW_SALARI"),;
					   oMdl:GetValue("ABWMASTER","ABW_FUNCAO"),;
					   oMdl:GetValue("ABWMASTER","ABW_CODTCW"))
	cMemo := cXml

	oPlanXml := FWUIWorkSheet():New(,.F.,,"PLAN_02")
	oPlanXml:LoadXmlModel(cMemo)
	cMemo := oPlanXml:GetModel():GetXmlData()
	oPlanXml:Close()

	oFWSheet:Close()
	oFWSheet:Reinit()	
	FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cMemo)}, Nil, STR0056)//"Carregando..."
	oFWSheet:Refresh(.T.)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999ExePl
	Carrega XML do Modelo com a CCT.	
@sample At999ExePl() 
@author Kaique Schiller
@since  12/07/2022
/*/
//------------------------------------------------------------------------------
Function At999ExePl(nSalario,cCodFun,cCodCfg)
Local cXml := ''
Local aTblConfig := {} 		  
Local nX	:= 0
Local nY	:= 0
Local nLinha := 5
Local oObj := Nil
Local aParamet := {}
Local aSalBase := {}
Local cNick    := ""
Local cFormula := ""
Default nSalario := 0
Default cCodFun := ""
Default cCodCfg := ""

oObj := PrestPlan():New()
oObj:defTotLines( "75" )
oObj:defTotColuns( "15" )
oObj:IniPlan()
oObj:IniItems()
oObj:AddValor("B1","","",STR0077,"@!","","") //"%Porcentagem"
oObj:AddValor("C1","","",STR0078,"@!","","") //"VALOR"
oObj:AddValor("D1","","",STR0079,"@!","","") //"TOTAL"
oObj:AddValor("A2","","",STR0080,"@!","","") //"MAO DE OBRA"
oObj:AddValor("A3","","",STR0081,"@!","","") //"SALARIO"
oObj:AddValor("A4","","",STR0093,"@!","","") //"VERBAS ADICIONAIS"
oObj:AddValor("C4","TOTAL_VERBAS","","0",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")

// Pesquisa SALARIO BASE
aSalBase := At999Pesq(cCodCfg,"SLBS")
If Empty(aSalBase)
	oObj:AddValor("C3","VALOR_SALARIO","="+cValToChar(nSalario),"",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
Else
	cNick    := aSalBase[2]
	cFormula := aSalBase[3]
	If Empty(cFormula)
		cFormula := cValToChar(nSalario)
	EndIf
	oObj:AddValor("B3","VALOR_SALARIO","="+cValToChar(nSalario),"",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
	oObj:AddValor("C3",cNick,"="+cFormula,"",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
EndIf

//Parametros de configura��o de calculo
oObj:AddValor("F1","","",STR0094,"@!","","") //"Parametros"
aParamet := At999Param(cCodCfg)
For nX := 1 to Len(aParamet)
	oObj:AddValor("F"+cValtoChar(nX+1),"","",aParamet[nX,1],"@!","","")
	oObj:AddValor("G"+cValtoChar(nX+1),aParamet[nX,2],"",aParamet[nX,3],aParamet[nX,4],"","")
	If !Empty(aParamet[nX,5])
		oObj:AddValor("H"+cValtoChar(nX+1),aParamet[nX,7],"",aParamet[nX,5],aParamet[nX,6],"","")
	Endif
Next nX

nLinha := 5
aTblConfig := At999Array(cCodCfg)
For nX := 1 to Len(aTblConfig)
	If Len(aTblConfig[nX]) >= 2
		//Formula e nick do total de m�o de obra AddValor(cName,cNickName,cFormula,cValue,cPicture,cBlockCell,cBlockName)
		If nX == 1
			oObj:AddValor("D2",aTblConfig[nX][1][2],aTblConfig[nX][1][3],"0",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
		Else
			nLinha++
			oObj:AddValor("A"+cValtoChar(nLinha),"","",aTblConfig[nX][1][1],"@!","","") //Descritivo
			If aTblConfig[nX][1][5] <> "=0"
				oObj:AddValor("B"+cValtoChar(nLinha),aTblConfig[nX][1][4],aTblConfig[nX][1][5],"0",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
			Endif
			oObj:AddValor("D"+cValtoChar(nLinha),aTblConfig[nX][1][2],aTblConfig[nX][1][3],"0",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
			nLinha++
		Endif
		For nY := 1 to Len(aTblConfig[nX,2])
			//Descritivo
			oObj:AddValor("A"+cValtoChar(nLinha),"","",aTblConfig[nX,2,nY,1],"@!","","") 
			//Porcentagem
			oObj:AddValor("B"+cValtoChar(nLinha),aTblConfig[nX,2,nY,4],aTblConfig[nX,2,nY,5],"0",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
			//Valor
			oObj:AddValor("C"+cValtoChar(nLinha),aTblConfig[nX,2,nY,2],aTblConfig[nX,2,nY,3],"0",Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),"","")
			nLinha++
		Next nY
	Endif
Next nX
oObj:FimItems()
oObj:FimPlan()
cXml := oObj:getXmlPlan()
oObj:destroy()
oObj:= Nil

Return cXml

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Array
	Realiza o preenchimento do array com as tabelas da Configura��o de Planilha
@sample At999Array() 
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Static Function At999Array(cCodCfg)
Local aRet := {}
Local cTabTemp := GetNextAlias()
Local aInsumos	:= {}
Local nX := 0
Local cFormVlr := "0"
Local cFormPrc := "0"
Local cNickVlr := ""
Local cNickPrc := ""
Local cNickLiq := ""
Local cNickCst := ""
Local cFields  := "%%"
Local lNickVlr := TDZ->(ColumnPos("TDZ_NICKVL")) > 0
Local lFieldTCX:= TCX->(ColumnPos("TCX_OBRGT")) > 0
Local cWhereTCX:= "%%"

Default cCodCfg := ""

If lFieldTCX
	cWhereTCX := "%AND TCX.TCX_OBRGT != '2'%"
EndIf

BeginSql Alias cTabTemp
	SELECT TCX.TCX_DESCRI, 
		   TCX.TCX_PORCEN, 
		   TCX.TCX_TIPOPE, 
		   TCX.TCX_CODTBL, 
		   TCX.TCX_TABELA,
		   TCX.TCX_ITEM,
		   TCX.TCX_PORALT,
		   TCX.TCX_NICK,
		   TCX.TCX_FORMUL,
		   TCX.TCX_NICKPO	
	FROM %Table:TCX% TCX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TCX.TCX_CODTCW
							AND TCW.%NotDel%
	WHERE 
		TCX.TCX_FILIAL = %xFilial:TCX%
		AND TCX.TCX_CODTCW = %Exp:cCodCfg% 
		AND TCX.TCX_TIPOPE = '1'
		AND TCX.TCX_NICK <> 'SLBS'
		AND TCX.%notDel%
		%exp:cWhereTCX%
	ORDER BY TCX.TCX_TIPOPE,TCX.TCX_ITEM
EndSql

//Primeiro registro � o descritivo e a formula 
If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TCX_FORMUL))
		cFormVlr := Alltrim((cTabTemp)->TCX_FORMUL)
	Endif

	Aadd(aRet,{{Alltrim((cTabTemp)->TCX_DESCRI),;
				Alltrim((cTabTemp)->TCX_NICK),;
				"="+cFormVlr,;
				Alltrim((cTabTemp)->TCX_NICKPO),;
				"="+cFormPrc},{}}) //"M�O DE OBRA"
Endif
(cTabTemp)->(DbSkip())

While !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty((cTabTemp)->TCX_FORMUL)
		cFormVlr := (cTabTemp)->TCX_FORMUL
	Endif

	cFormPrc := cValtoChar((cTabTemp)->TCX_PORALT)

	Aadd(aRet[Len(aRet),2],{Alltrim((cTabTemp)->TCX_DESCRI),;
							  Alltrim((cTabTemp)->TCX_NICK),;
				   	 		  "="+Alltrim(cFormVlr),;
							  Alltrim((cTabTemp)->TCX_NICKPO),;
				   	 		  Alltrim(cFormPrc)})
	
	(cTabTemp)->(DbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

cTabTemp := GetNextAlias()

BeginSql Alias cTabTemp
	SELECT TCX.TCX_DESCRI, 
		   TCX.TCX_PORCEN, 
		   TCX.TCX_TIPOPE, 
		   TCX.TCX_CODTBL, 
		   TCX.TCX_TABELA,
		   TCX.TCX_ITEM,
		   TCX.TCX_PORALT,
		   TCX.TCX_NICK,
		   TCX.TCX_FORMUL,
		   TCX.TCX_NICKPO
	FROM %Table:TCX% TCX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TCX.TCX_CODTCW
							AND TCW.%NotDel%
	WHERE TCX.TCX_FILIAL = %xFilial:TCX%
		AND TCX.TCX_CODTCW = %Exp:cCodCfg% 
		AND TCX.TCX_TIPOPE = '2'
		AND TCX.%notDel%
	ORDER BY TCX.TCX_TIPOPE,TCX.TCX_ITEM
EndSql

//Primeiro registro � o descritivo e a formula 
If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TCX_FORMUL))
		cFormVlr := Alltrim((cTabTemp)->TCX_FORMUL)
	Endif

	Aadd(aRet,{{Alltrim((cTabTemp)->TCX_DESCRI),;
				Alltrim((cTabTemp)->TCX_NICK),;
				"="+cFormVlr,;
				Alltrim((cTabTemp)->TCX_NICKPO),;
				"="+cFormPrc},{}}) //"ENCARGOS SOCIAIS"
Endif
(cTabTemp)->(DbSkip())

While !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"

	If !Empty((cTabTemp)->TCX_FORMUL)
		cFormVlr := (cTabTemp)->TCX_FORMUL
	Endif

	cFormPrc := cValtoChar((cTabTemp)->TCX_PORALT)

	Aadd(aRet[Len(aRet),2],{Alltrim((cTabTemp)->TCX_DESCRI),;
							Alltrim((cTabTemp)->TCX_NICK),;
				     		"="+Alltrim(cFormVlr),;
							Alltrim((cTabTemp)->TCX_NICKPO),;
				   	 		Alltrim(cFormPrc)})
	
	(cTabTemp)->(DbSkip())
EndDo
(cTabTemp)->(DbCloseArea())

cFormVlr := "0"
cFormPrc := "0"
aInsumos := At999Insum()
For nX := 1 To Len(aInsumos)
	If nX == 1
		cFormVlr := aInsumos[nX,2]
	Else
		cFormVlr += "+"+aInsumos[nX,2]
	Endif
Next nX
Aadd(aRet,{{STR0083,;
 	 "TOTAL_INSUMO",;
	  "="+Alltrim(cFormVlr),;
	  "",;
	  "="+cFormPrc},{}}) //INSUMOS

For nX := 1 To Len(aInsumos)
	Aadd(aRet[Len(aRet),2],{Alltrim(aInsumos[nX,1]),;
						  	  Alltrim(aInsumos[nX,2]),;
		 				      "=0",;
							  "",;
							  "0"})
Next nX

If lNickVlr
	cFields := "%, TDZ.TDZ_NICKVL%"
EndIf

cTabTemp := GetNextAlias()
BeginSql Alias cTabTemp
	SELECT TDZ.TDZ_ITEM,
		   TDZ.TDZ_CODSLY,
		   TDZ.TDZ_TIPBEN,
		   TDZ.TDZ_VLRDIF,
		   TDZ.TDZ_NICK,
		   TDZ.TDZ_FORMUL
		   %Exp:cFields%
	FROM %Table:TDZ% TDZ
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TDZ.TDZ_CODTCW
							AND TCW.%NotDel%
	WHERE TDZ.TDZ_FILIAL = %xFilial:TDZ%
		AND TDZ.TDZ_CODTCW = %Exp:cCodCfg% 
		AND TDZ.%notDel%
EndSql

//Primeiro registro � o descritivo e a formula 
If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"

	If !Empty(Alltrim((cTabTemp)->TDZ_FORMUL))
		cFormVlr := Alltrim((cTabTemp)->TDZ_FORMUL)
	Endif
	Aadd(aRet,{{STR0088,;
	Alltrim((cTabTemp)->TDZ_NICK),;
	"="+cFormVlr,;
	"",;
	"="+cFormPrc},{}}) //"BENEF�CIOS"
Endif

(cTabTemp)->(DbSkip())

While !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	cNickPrc := ""
	If !Empty((cTabTemp)->TDZ_FORMUL)
		cFormVlr := Alltrim((cTabTemp)->TDZ_FORMUL)
	Else
		cFormVlr := cValtoChar((cTabTemp)->TDZ_VLRDIF)
	Endif
	If lNickVlr .And. !Empty(Alltrim((cTabTemp)->TDZ_NICKVL))
		cNickPrc := Alltrim((cTabTemp)->TDZ_NICKVL)
		cFormPrc := cValtoChar((cTabTemp)->TDZ_VLRDIF)
	EndIf
	Aadd(aRet[Len(aRet),2],{Alltrim(At996aDsc((cTabTemp)->TDZ_CODSLY,(cTabTemp)->TDZ_TIPBEN,.T.)),;
						  	  									  Alltrim((cTabTemp)->TDZ_NICK),;
		 														  "="+cFormVlr,;
																  cNickPrc,;
																  Alltrim(cFormPrc)})
	(cTabTemp)->(DbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

cTabTemp := GetNextAlias()

BeginSql Alias cTabTemp
	SELECT TCW.TCW_NCKCUS, TCW_CUSTO
	FROM %Table:TCW% TCW
	WHERE TCW.TCW_FILIAL = %xFilial:TCW%
		AND TCW.TCW_CODIGO = %Exp:cCodCfg% 
		AND TCW.%notDel%
EndSql

If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TCW_CUSTO))
		cFormVlr := Alltrim((cTabTemp)->TCW_CUSTO)
	Endif
	cNickCst := Alltrim((cTabTemp)->TCW_NCKCUS)
	Aadd(aRet,{{STR0089,;
	Alltrim((cTabTemp)->TCW_NCKCUS),;
	"="+Alltrim(cFormVlr),;
	"",;
	"="+Alltrim(cFormPrc)},{}}) //"TOTAL DE CUSTO"

Endif

(cTabTemp)->(DbCloseArea())

cTabTemp := GetNextAlias()
BeginSql Alias cTabTemp
	SELECT TEX.TEX_VALOR, 
		   TEX.TEX_TIPOTX, 
		   TEX.TEX_TIPOPE, 
		   TEX.TEX_DESCRI,
		   TEX.TEX_NICK,
		   TEX.TEX_FORMUL,
		   TEX.TEX_NICKPO,
		   TEX.TEX_FORMPO
	FROM %Table:TEX% TEX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TEX.TEX_CODTCW
							AND TCW.%NotDel%
	WHERE TEX.TEX_FILIAL = %xFilial:TEX%
		AND TEX.TEX_CODTCW = %Exp:cCodCfg% 
		AND TEX.TEX_TIPOPE = '1'
		AND TEX.%notDel%
	ORDER BY TEX.TEX_ITEM
EndSql

If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TEX_FORMUL))
		cFormVlr := Alltrim((cTabTemp)->TEX_FORMUL)
	Endif
	If !Empty(Alltrim((cTabTemp)->TEX_FORMPO))
		cFormPrc := Alltrim((cTabTemp)->TEX_FORMPO)
	Endif	
	Aadd(aRet,{{Alltrim((cTabTemp)->TEX_DESCRI),;
				Alltrim((cTabTemp)->TEX_NICK),;
	  			"="+cFormVlr,;
				Alltrim((cTabTemp)->TEX_NICKPO),;
				"="+cFormPrc},{}}) //"TAXAS"
Endif

(cTabTemp)->(DbSkip())

While !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	cNickVlr := Alltrim((cTabTemp)->TEX_NICK)
	cNickPrc := Alltrim((cTabTemp)->TEX_NICKPO)
	If (cTabTemp)->TEX_TIPOTX == "1"
		cFormVlr := cValtoChar((cTabTemp)->TEX_VALOR)
	Elseif (cTabTemp)->TEX_TIPOTX == "2"
		cFormPrc := cValtoChar((cTabTemp)->TEX_VALOR)
		If !Empty((cTabTemp)->TEX_FORMUL)
			cFormVlr := (cTabTemp)->TEX_FORMUL
		Else
			If !Empty(cNickPrc) .And. !Empty(cNickCst)
				cFormVlr := cNickCst+"*"+cNickPrc+"/100"
			Endif
		Endif
	Endif
	Aadd(aRet[Len(aRet),2],{Alltrim((cTabTemp)->TEX_DESCRI),;
							  cNickVlr,;
				     		  "="+Alltrim(cFormVlr),;
							  cNickPrc,;
							  Alltrim(cFormPrc)})

	(cTabTemp)->(DbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

cTabTemp := GetNextAlias()

BeginSql Alias cTabTemp
	SELECT TCW.TCW_NICKLI, TCW_FORLIQ
	FROM %Table:TCW% TCW
	WHERE TCW.TCW_FILIAL = %xFilial:TCW%
		AND TCW.TCW_CODIGO = %Exp:cCodCfg% 
		AND TCW.%notDel%
EndSql

If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TCW_FORLIQ))
		cFormVlr := Alltrim((cTabTemp)->TCW_FORLIQ)
	Endif
	cNickLiq := Alltrim((cTabTemp)->TCW_NICKLI)
	Aadd(aRet,{{STR0107,;
	Alltrim((cTabTemp)->TCW_NICKLI),;
	"="+cFormVlr,;
	"",;
	"="+cFormPrc},{}}) //"TOTAL LIQUIDO"
Endif

(cTabTemp)->(DbCloseArea())

cTabTemp := GetNextAlias()
BeginSql Alias cTabTemp
	SELECT TEX.TEX_VALOR, 
		   TEX.TEX_TIPOTX, 
		   TEX.TEX_TIPOPE, 
		   TEX.TEX_DESCRI,
		   TEX.TEX_NICK,
		   TEX.TEX_FORMUL,
		   TEX.TEX_NICKPO,
		   TEX.TEX_FORMPO
	FROM %Table:TEX% TEX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TEX.TEX_CODTCW
							AND TCW.%NotDel%
	WHERE TEX.TEX_FILIAL = %xFilial:TEX%
		AND TEX.TEX_CODTCW = %Exp:cCodCfg% 
		AND TEX.TEX_TIPOPE = '2'
		AND TEX.%notDel%
	ORDER BY TEX.TEX_ITEM
EndSql

If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TEX_FORMUL))
		cFormVlr := Alltrim((cTabTemp)->TEX_FORMUL)
	Endif
	If !Empty(Alltrim((cTabTemp)->TEX_FORMPO))
		cFormPrc := Alltrim((cTabTemp)->TEX_FORMPO)
	Endif
	Aadd(aRet,{{Alltrim((cTabTemp)->TEX_DESCRI),;
				Alltrim((cTabTemp)->TEX_NICK),;
	  			"="+cFormVlr,;
				Alltrim((cTabTemp)->TEX_NICKPO),;
				"="+cFormPrc},{}}) //"IMPOSTOS"
Endif
(cTabTemp)->(DbSkip())

While !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	cNickVlr := Alltrim((cTabTemp)->TEX_NICK)
	cNickPrc := Alltrim((cTabTemp)->TEX_NICKPO)
	If (cTabTemp)->TEX_TIPOTX == "1"
		cFormVlr := cValtoChar((cTabTemp)->TEX_VALOR)
	Elseif (cTabTemp)->TEX_TIPOTX == "2"
		cFormPrc := cValtoChar((cTabTemp)->TEX_VALOR)
		If !Empty((cTabTemp)->TEX_FORMUL)
			cFormVlr := (cTabTemp)->TEX_FORMUL
		Else
			If !Empty(cNickPrc) .And. !Empty(cNickLiq)
				cFormVlr := cNickLiq+"*"+cNickPrc+"/100"
			Endif
		Endif
	Endif
	Aadd(aRet[Len(aRet),2],{Alltrim((cTabTemp)->TEX_DESCRI),;
							  cNickVlr,;
				     		  "="+Alltrim(cFormVlr),;
							  cNickPrc,;
							  Alltrim(cFormPrc)})

	(cTabTemp)->(DbSkip())
EndDo

(cTabTemp)->(DbCloseArea())

cTabTemp := GetNextAlias()

BeginSql Alias cTabTemp
	SELECT TCW.TCW_NICKBR, TCW_FORBRT
	FROM %Table:TCW% TCW
	WHERE TCW.TCW_FILIAL = %xFilial:TCW%
		AND TCW.TCW_CODIGO = %Exp:cCodCfg% 
		AND TCW.%notDel%
EndSql

If !(cTabTemp)->(EOF())
	cFormVlr := "0"
	cFormPrc := "0"
	If !Empty(Alltrim((cTabTemp)->TCW_FORBRT))
		cFormVlr := Alltrim((cTabTemp)->TCW_FORBRT)
	Endif
	Aadd(aRet,{{STR0092,;
		Alltrim((cTabTemp)->TCW_NICKBR),;
		"="+cFormVlr,;
		"",;
		"="+cFormPrc},{}}) //"TOTAL BRUTO"
Endif

(cTabTemp)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Insum
	Inclus�o do array de Insumos
@sample At999Insum()
@author Kaique Schiller
@since	13/07/2022       
/*/
//------------------------------------------------------------------------------
Static Function At999Insum()
Local aRet := {{STR0084,"TOTAL_MC"},;//"Material de Consumo"
			   {STR0085,"TOTAL_MI"},; //"Material de Implanta��o"
			   {STR0086,"TOTAL_UNIF"},; //"Uniforme"
			   {STR0087,"TOTAL_ARMA"}} //"Armamento"
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Param
	Parametros de configura��o de calculo
@sample At999Param()
@author Kaique Schiller
@since	21/02/2023       
/*/
//------------------------------------------------------------------------------
Static Function At999Param(cCodCfg)
Local aRetParam := {}
Local cFormVlr := ""
Local cTabTemp := ""
Local aParamAux := {}
Local nX := 0

If TableInDic("TXN") .And. TXN->( ColumnPos('TXN_CODIGO') ) > 0
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TXN.TXN_DESCRI, 
			TXN.TXN_FORMUL,
			TXN.TXN_NICK
		FROM %Table:TXN% TXN
		INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
								AND TCW.TCW_CODIGO = TXN.TXN_CODTCW
								AND TCW.%NotDel%
		WHERE TXN.TXN_FILIAL = %xFilial:TXN%
			AND TXN.TXN_CODTCW = %Exp:cCodCfg% 
			AND TXN.%notDel%
		ORDER BY TXN.TXN_ITEM
	EndSql

	While !(cTabTemp)->(EOF())
		cFormVlr := "0"
		If !Empty(Alltrim((cTabTemp)->TXN_FORMUL))
			cFormVlr := Alltrim((cTabTemp)->TXN_FORMUL)
		Endif
		Aadd(aRetParam,{Alltrim((cTabTemp)->TXN_DESCRI),;
						Alltrim((cTabTemp)->TXN_NICK),;
						"="+cFormVlr,;
						Alltrim(GetSx3Cache("TFF_SUBTOT","X3_PICTURE")),;
						"",;
						"",;
						""})
		(cTabTemp)->(DbSkip())
	EndDo

	(cTabTemp)->(DbCloseArea())
Endif

aParamAux := At999ParmB()
For nX := 1 to Len(aParamAux)
	Aadd(aRetParam,{aParamAux[nX,1],;
					aParamAux[nX,2],;
					aParamAux[nX,3],;
					aParamAux[nX,4],;
					aParamAux[nX,5],;
					aParamAux[nX,6],;
					aParamAux[nX,7]})
Next nX
Return aRetParam
//------------------------------------------------------------------------------
/*/{Protheus.doc} At999ParmB
	Outros parametros de configura��o de calculo
@sample At999ParmB()
@author Kaique Schiller
@since	21/02/2023
/*/
//------------------------------------------------------------------------------
Static Function At999ParmB()
Local aRetParam := {{STR0108,"PARAM_INSALUB","1","@E 9",x3Combo("TFF_INSALU","1"),"@!","DESC_INSALUB"},; //"Insalubridade"##"N�o Possui"
					{STR0109,"PARAM_GRAUINSALUB","1","@E 9",x3Combo("TFF_GRAUIN","1"),"@!","DESC_GRAU"},; //"Grau da Insalubridade"
					{STR0110,"PARAM_PERICULOSO","1","@E 9",x3Combo("TFF_PERICU","1"),"@!","DESC_PERICU"}} //"Periculosidade"
Return aRetParam

//------------------------------------------------------------------------------
/*/{Protheus.doc} At999Pesq
	Pesquisa da configura��o por Nick
@sample At999Pesq()
@author flavio.vicco
@since	29/05/2023       
/*/
//------------------------------------------------------------------------------
Static Function At999Pesq(cCodCfg,cPesq)
Local aRet := {}
Local cTabTemp := GetNextAlias()

Default cCodCfg := ""
Default cPesq   := ""

BeginSql Alias cTabTemp
	SELECT TCX.TCX_DESCRI, 
		   TCX.TCX_NICK,
		   TCX.TCX_FORMUL
	FROM %Table:TCX% TCX
	INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
							AND TCW.TCW_CODIGO = TCX.TCX_CODTCW
							AND TCW.%NotDel%
	WHERE 
		TCX.TCX_FILIAL = %xFilial:TCX%
		AND TCX.TCX_CODTCW = %Exp:cCodCfg% 
		AND TCX.TCX_TIPOPE = '1'
		AND TCX.TCX_NICK = %Exp:cPesq%
		AND TCX.%notDel%
	ORDER BY TCX.TCX_TIPOPE,TCX.TCX_ITEM
EndSql

If !(cTabTemp)->(EOF())
	Aadd(aRet, Alltrim((cTabTemp)->TCX_DESCRI))
	Aadd(aRet, Alltrim((cTabTemp)->TCX_NICK))
	Aadd(aRet, Alltrim((cTabTemp)->TCX_FORMUL))
EndIf
(cTabTemp)->(DbCloseArea())

Return aRet
