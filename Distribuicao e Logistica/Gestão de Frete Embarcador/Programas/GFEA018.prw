#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

//====================================================================================================================\\
/*/{Protheus.doc}GFEA018
//====================================================================================================================
	@description
	Rotina de Cadastro Pra�as de Ped�gio

	@author		Lucas Farias
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//===================================================================================================================\\

Function GFEA018()
	Local oBrowse
	Private aRotina := MenuDef()
	
	DbSelectArea("GVX")	//Cria tabela GVX
	DbSelectArea("GVY") //Cria tabela GVY
	DbSelectArea("GVZ") //Cria tabela GVZ
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GVX")						// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA018")				// Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription("Pra�as de Ped�gio")	// Descri��o do browse

	oBrowse:Activate()
 
Return(Nil)

// FIM da Funcao GFEA018
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}MenuDef
//====================================================================================================================
	@description
	Defini��o do Menu

	@author		Lucas Farias
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//===================================================================================================================\\

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.GFEA018" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.GFEA018" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.GFEA018" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.GFEA018" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"	  	ACTION "VIEWDEF.GFEA018" OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"		ACTION "VIEWDEF.GFEA018" OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Anexo"		ACTION "MsDocument('GVX',GVX->(RecNo()),3)" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Reajuste"		ACTION "GFEA018RE(GVX->GVX_NRPCPD)"	   OPERATION 4 ACCESS 0//DLOGGFE-11387 alterado menu de posi��o
	

Return aRotina
// FIM da Funcao MenuDef
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}ModelDef
//====================================================================================================================
	@description
	Defini��o do Modelo de Dados

	@author		Lucas Farias
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//===================================================================================================================\\

Static Function ModelDef()
	Local oStruGVX
	Local oStruGVY
	Local oStruGVZ
	Local oModel

	oModel := MPFormModel():New("GFEA018" /*cID*/, /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	
	// Monta as estruturas das tabelas
	oStruGVX := FWFormStruct( 1, "GVX", ,/*lViewUsado*/ )
	oStruGVY := FWFormStruct( 1, "GVY", ,/*lViewUsado*/ )
	oStruGVZ := FWFormStruct( 1, "GVZ", ,/*lViewUsado*/ )
		
	oModel:AddFields( "GFEA018_GVX", /*cOwner*/, oStruGVX, /*bPre*/, /*bPost*/, /*bLoad*/)
	
	oModel:SetPrimaryKey( {"GVX_FILIAL" , "GVX_NRPCPD"} )

	oModel:AddGrid( "GFEA018_GVY", "GFEA018_GVX", oStruGVY, /*bLinePre*/, { |oModelGrid, nLine| GFEA018LPOS("GFEA018_GVY", oModelGrid, nLine ) }/*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
	oModel:AddGrid( "GFEA018_GVZ", "GFEA018_GVX", oStruGVZ, /*bLinePre*/, { |oModelGrid, nLine| GFEA018LPOS("GFEA018_GVZ", oModelGrid, nLine ) }/*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
	
	// Propriedades das Grids
	oModel:SetRelation( "GFEA018_GVY", { {"GVY_FILIAL", "xFilial('GVY')"}, {"GVY_NRPCPD","GVX_NRPCPD"} }, GVY->(IndexKey( 1 )) )
	oModel:SetRelation( "GFEA018_GVZ", { {"GVZ_FILIAL", "xFilial('GVZ')"}, {"GVZ_NRPCPD","GVX_NRPCPD"} }, GVZ->(IndexKey( 1 )) )
	
	// Permite salvar sem nenhum item relacionado
	oModel:GetModel( "GFEA018_GVY" ):lOptional := .T.
	oModel:GetModel( "GFEA018_GVZ" ):lOptional := .T.
	
	// Permite deletar todas as linhas
	oModel:GetModel( "GFEA018_GVY" ):SetDelAllLine( .T. )
	oModel:GetModel( "GFEA018_GVZ" ):SetDelAllLine( .T. )
	
	// Define duplica��o de linhas
	oModel:GetModel( "GFEA018_GVY" ):SetUniqueLine( { "GVY_DATVIG", "GVY_CATPED" } )
	oModel:GetModel( "GFEA018_GVZ" ):SetUniqueLine( { "GVZ_NRCIDO", "GVZ_NRCIDD" } )
	
	// Aumenta numero maximo de linha das GRID's
	oModel:GetModel( "GFEA018_GVY" ):SetMaxLine( 9999 )
	oModel:GetModel( "GFEA018_GVZ" ):SetMaxLine( 9999 )
	
Return(oModel)
// FIM da Funcao ModelDef
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}ViewDef
//====================================================================================================================
	@description
	Constru��o da Interface.

	@author		Lucas Farias
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//===================================================================================================================\\

Static Function ViewDef()
	Local oStruGVX
	Local oStruGVY
	Local oStruGVZ
	Local oModel
	Local oView
 
	oView := FWFormView():New()

	oModel	:= ModelDef()

	oView:SetModel( oModel )

	// Monta as estruturas das tabelas
	oStruGVX := FWFormStruct( 2, "GVX", ,/*lViewUsado*/ )
	oStruGVY := FWFormStruct( 2, "GVY", ,/*lViewUsado*/ )
	oStruGVZ := FWFormStruct( 2, "GVZ", ,/*lViewUsado*/ )
	
	// Monta Grupos
	/*
	oStruGVX:AddGroup("PracaId"		, "Identifica��o"	, "", 2)
	oStruGVX:AddGroup("PracaInfo"	, "Informa��es"		, "", 2)
	
	oStruGVX:SetProperty("*"			, MVC_VIEW_GROUP_NUMBER, "PracaInfo")
	oStruGVX:SetProperty("GVX_NRPCPD"	, MVC_VIEW_GROUP_NUMBER, "PracaId")
	oStruGVX:SetProperty("GVX_DESCRI"	, MVC_VIEW_GROUP_NUMBER, "PracaId")
	*/
	
	oStruGVY:RemoveField("GVY_NRPCPD")
	oStruGVZ:RemoveField("GVZ_NRPCPD")
	
	// Monta Layout
	oView:SetModel(oModel)
	
	oView:AddField( "GFEA018_GVX" , oStruGVX )
	oView:AddGrid( "GFEA018_GVY" , oStruGVY )
	oView:AddGrid( "GFEA018_GVZ" , oStruGVZ )
	
	oView:CreateHorizontalBox( "MASTER_PRACA"	, 25 )
	oView:CreateHorizontalBox( "FOLDERS"		, 75 )

	oView:CreateFolder("IDFOLDER","FOLDERS")
	
	oView:AddSheet("IDFOLDER","IDSHEET01","Pra�as X Tarifas")
	oView:AddSheet("IDFOLDER","IDSHEET02","Pra�as X Rotas")

	oView:CreateHorizontalBox( "DETAIL_TARIFA"	, 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_ROTAS"	, 100,,,"IDFOLDER","IDSHEET02" )

	oView:SetOwnerView( "GFEA018_GVX" , "MASTER_PRACA" )
	oView:SetOwnerView( "GFEA018_GVY" , "DETAIL_TARIFA" )
	oView:SetOwnerView( "GFEA018_GVZ" , "DETAIL_ROTAS" )

Return oView
// FIM da Funcao ViewDef
//======================================================================================================================

//====================================================================================================================\\
/*/{Protheus.doc}GFEA018LPOS
//====================================================================================================================
	@description
	P�s Valida��o da linha da FORMGRID da tabela Detail. 
	Recebe como par�metro o ModelGrid e o n�mero da linha do FORMGRID.

	@author		Lucas Farias
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//===================================================================================================================\\

Function GFEA018LPOS(cId,oModelGrid,nLine)
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local aSaveLines	:= FWSaveRows(oModel) //Salva Linha Atual
	Local oModelGVY		:= oModel:GetModel("GFEA018_GVY")
	Local oModelGVZ		:= oModel:GetModel("GFEA018_GVZ")
	Local lRet 			:= .T.
	
	If cId == "GFEA018_GVY"
		
	ElseIf cId == "GFEA018_GVZ"
		oModelGVZ:GoLine(nLine)
			
		If !oModelGVZ:IsDeleted(nLine)
			
			If GFXCP12127("GVZ_NRRGOR")
				// Valida��o se Cidade Origem e Destino e/ou Regi�o Origem e Destino est�o preenchidas
				If (Empty(oModelGVZ:GetValue("GVZ_NRCIDO")) .And. Empty(oModelGVZ:GetValue("GVZ_NRRGOR"))) .And.;
				 (!(Empty(oModelGVZ:GetValue("GVZ_NRCIDD"))) .Or. !(Empty(oModelGVZ:GetValue("GVZ_NRRGDS"))) ) 
					oModel:SetErrorMessage(,,,,,"Cidade Origem ou Regi�o Origem da linha " + cValtochar(nLine) + " n�o foi preenchida.","� necess�rio preencher Cidade ou Regi�o Origem quando a Cidade ou a Regi�o Destino foi preenchida.")
					lRet := .F.
				ElseIf (Empty(oModelGVZ:GetValue("GVZ_NRCIDD")) .And. Empty(oModelGVZ:GetValue("GVZ_NRRGDS"))) .And.;
				 (!(Empty(oModelGVZ:GetValue("GVZ_NRCIDO"))) .Or. !(Empty(oModelGVZ:GetValue("GVZ_NRRGOR"))) )
					oModel:SetErrorMessage(,,,,,"Cidade Destino ou Regi�o Destino da linha " + cValtochar(nLine) + " n�o foi preenchida.","� necess�rio preencher quando a Cidade Origem ou a Regi�o Origem foi preenchida.")
					lRet := .F.
				EndIf
				
				If !Empty(oModelGVZ:GetValue("GVZ_NRCIDO")) .AND. !Empty(oModelGVZ:GetValue("GVZ_NRRGOR"))
					oModel:SetErrorMessage(,,,,,"Cidade Origem e Regi�o Origem da linha " + cValtochar(nLine) + " foram preenchidas.","Preencha apenas um dos campos de Origem.")
					lRet := .F.
				ElseIf !Empty(oModelGVZ:GetValue("GVZ_NRCIDD")) .AND. !Empty(oModelGVZ:GetValue("GVZ_NRRGDS"))
					oModel:SetErrorMessage(,,,,,"Cidade Destino e Regi�o Destino da linha " + cValtochar(nLine) + " foram preenchidas.","Preencha apenas um dos campos de Destino.")
					lRet := .F.
				EndIf
			
			Else			
			
				// Valida��o se Cidade Origem e Destino est�o preenchidas.
				If Empty(oModelGVZ:GetValue("GVZ_NRCIDO")) .AND. !(Empty(oModelGVZ:GetValue("GVZ_NRCIDD")))
					oModel:SetErrorMessage(,,,,,"Cidade Origem da linha " + cValtochar(nLine) + " n�o foi preenchida.","� necess�rio preencher quando a Cidade Destino foi preenchida.")
					lRet := .F.
				ElseIf Empty(oModelGVZ:GetValue("GVZ_NRCIDD")) .AND. !(Empty(oModelGVZ:GetValue("GVZ_NRCIDO")))
					oModel:SetErrorMessage(,,,,,"Cidade Destino da linha " + cValtochar(nLine) + " n�o foi preenchida.","� necess�rio preencher quando a Cidade Origem foi preenchida.")
					lRet := .F.
				EndIf	
			Endif		
			

		EndIf

	EndIf
	
	FWRestRows( aSaveLines )//Restaura Backup
	//oView:Refresh()
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GFEA018RE
	@description Permite reajustar de forma simples as Tarifas de Ped�gio

	@author		Gabriela Lima
	@version	1.0
	@since		21 de Agosto de 2017
/*/
//----------------------------------------------------------------------
Function GFEA018RE(cPraca)
	Local oButtonOK
	Local oButtonCanc
	Private dData := STOD("")
	Private cPercR := PADR("0",5)
	Private cValR := PADR("0",5)
	Private oDlg
	Private cPracaPD := cPraca 

	DEFINE MSDIALOG oDlg TITLE "Reajuste da data de vig�ncia" From 4,0 To 16,40 OF oMainWnd 

	@ 19, 006  SAY "Nova data de vig�ncia:" SIZE 70,7 PIXEL OF oDlg 
	@ 34, 006  SAY "Percentual de reajuste:" SIZE 70,7 PIXEL OF oDlg 
	@ 49, 006  SAY "Valor de reajuste:" SIZE 70,7 PIXEL OF oDlg 
	
 	@ 18, 070  MSGET dData  SIZE 45,7 OF oDlg PIXEL HASBUTTON 
	@ 33, 070  MSGET cPercR PICTURE "@9999" SIZE 20,7 OF oDlg PIXEL  
	@ 48, 070  MSGET cValR  PICTURE "@999999" SIZE 20,7 OF oDlg PIXEL  
	
	oButtonOK   := tButton():New(70,95,'OK',oDlg,{||If(GFEA018OK(dData,cPercR,cValR),oDlg:End(),lRet:=.F.)},25,10,,,,.T.)
	oButtonCanc := tButton():New(70,125,"Cancelar",oDlg,{||lRet:=.F.,(oDlg:End())},25,10,,,,.T.) 

	ACTIVATE MSDIALOG oDlg centered

Return

//------------------------------------------------------------------------------
/*/ Cria nova vig�ncia de Tarifas das Pra�as de Ped�gio.
Faz o reajuste sobre os valores das vig�ncias mais recentes de cada categoria /*/
//------------------------------------------------------------------------------
Function GFEA018OK(dData,cPercR,cValR) 
	Local lRet := .T.
	Local cQuery := ""
	Local nI
	Local aRetPrPed := {}
	Local nPercR, nValR 
	Private cAliPrPed := GetNextAlias()

	//DLOGGFE-11387 realizado convers�o das strings antes de fazer as compara��es. Valor nunca � nulo pois, vem de um get
	nValR := Val(StrTran(cValR,",",".")) 
	nPercR := Val(StrTran(cPercR,",",".")) 

	If Empty(dData) 
		Help(,,'HELP',,'Campo obrigat�rio.',1,0,,,,,,{"Preencha a nova data de vig�ncia para o reajuste."})
		lRet := .F.
	ElseIf nPercR == 0 .And. nValR == 0
		Help(,,'HELP',,'Campo obrigat�rio.',1,0,,,,,,{"Preencha o valor ou a porcentagem para o reajuste."})
		lRet := .F.
	ElseIf nPercR > 0 .And. nValR > 0 
		Help(,,'HELP',,'Preencha o valor ou a porcentagem para o reajuste.',1,0,,,,,,{""})
		lRet := .F.
	EndIf
	
	If lRet
		GVY->(dbGoTop())
		GVY->(dbSetOrder(1))// GVY_FILIAL+GVY_NRPCPD+DTOS(GVY_DATVIG)+GVY_CATPED 
		If GVY->(dbSeek(xFilial("GVY")+cPracaPD ))

			cQuery := " SELECT GVY_FILIAL, GVY_NRPCPD, GVY_DATVIG, GVY_CATPED, GVY_VALOR"
			cQuery += " FROM " + RetSQLName("GVY") + " GVY "
			cQuery += " WHERE GVY.GVY_NRPCPD='"+cPracaPD+"' "
			cQuery += " AND GVY.D_E_L_E_T_ = ' ' "
			cQuery += " AND GVY.GVY_DATVIG = (SELECT MAX(GVY_DATVIG) "
			cQuery += " FROM " + RetSQLName("GVY") + " GVY "
			cQuery += " WHERE GVY.GVY_NRPCPD='"+cPracaPD+"'"
			cQuery += " AND GVY.D_E_L_E_T_ = ' ')"
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliPrPed, .F., .T.)
			
			(cAliPrPed)->(dbGoTop())
			While !(cAliPrPed)->(EoF())
				AADD(aRetPrPed,{(cAliPrPed)->GVY_FILIAL,(cAliPrPed)->GVY_NRPCPD,(cAliPrPed)->GVY_DATVIG,(cAliPrPed)->GVY_VALOR,(cAliPrPed)->GVY_CATPED})
				(cAliPrPed)->(dbSkip())
			EndDo
			(cAliPrPed)->(dbCloseArea())
		EndIf

		For nI := 1 To Len(aRetPrPed)
			If dData <= STOD(aRetPrPed[nI][3])
				Help(,,'HELP',,'Data inv�lida.',1,0,,,,,,{"A data informada precisa ser maior que a vig�ncia mais recente em Pra�as x Tarifas."})
				lRet := .F.
				Exit
			Else
				GVY->(dbGoTop())
				GVY->(dbSetOrder(1))// GVY_FILIAL+GVY_NRPCPD+DTOS(GVY_DATVIG)+GVY_CATPED 
				If GVY->(dbSeek(xFilial("GVY")+aRetPrPed[nI][2]+aRetPrPed[nI][3]+aRetPrPed[nI][5] ))
					If nValR > 0						 
						nValor := nValR + aRetPrPed[nI][4]
					Else						 
						nValor := (nPercR * aRetPrPed[nI][4]) / 100
						nValor := nValor + aRetPrPed[nI][4]
					EndIf
					RecLock("GVY", .T.)
						GVY->GVY_FILIAL	:= aRetPrPed[nI][1]
						GVY->GVY_NRPCPD	:= aRetPrPed[nI][2]
						GVY->GVY_DATVIG := dData
						GVY->GVY_VALOR  := nValor
						GVY->GVY_CATPED := aRetPrPed[nI][5]
					GVY->(MsUnlock())
				EndIf
			EndIf
		Next nI	

		If lRet
			MsgInfo("Reajuste realizado com sucesso.")
		EndIf
		
	EndIf
Return lRet
