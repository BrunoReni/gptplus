#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//#INCLUDE "GTPA600B.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Defini��o do modelo de Dados GTPA600B
@sample	ViewDef() 
@return	oModel  Retorna o VIEW de Dados 
@author	GTP
@since		24/01/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStruct	

	oStruct := SetModelStruct()
	
	oModel := MPFormModel():New("GTPA600B",,{|oModel| G600BTudoOk(oModel)})
	
	oModel:AddFields("MASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Fechamento do Or�amento/Contrato")
	oModel:SetPrimaryKey({})
	oModel:SetCommit({|oModel| G600BCommit(oModel) })
	oModel:SetVldActivate({|oModel| G600BVldAct(oModel)})
	oModel:SetActivate( { |oModel|G600BActiv(oModel) } )

Return(oModel)

Static Function G600BVldAct(oModel)

	Local lRet := .T.

	If ( !(G6R->G6R_STATUS $ '1|4') )	//Aberto e Reaberto
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G600BVldAct","N�o � poss�vel efetuar o fechamento do contrato. O seu 'status' n�o � v�lido.", "Somente Contratos 'Abertos' ou 'Reabertos' podem ser fechados.")//Localidade n�o pode ser venda igual a n�o!
	EndIf		

Return(lRet)

/*/{Protheus.doc} G600BActiv(oModel)	
	Fun��o que ir� alimentar os campos de Usu�rio e Nome de Usu�rio
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		oModel, objeto, inst�ncia da classe FwFormModel
	@return nulo
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function G600BActiv(oModel)
	
	Local oSubMdl	:= oModel:GetModel("MASTER")

	If ( G600ChkNFlds(oSubMdl:GetStruct()) )

		oSubMdl:LoadValue("G6R_USRASS",__cUserId)
		oSubMdl:LoadValue("G6R_DSCUSR",FWGETUSERNAME(__cUserId))
	
	EndIf

Return()

/*/{Protheus.doc} G600BCommit(oModel)	
	Fun��o respons�vel pela persist�ncia dos dados no banco de dados.
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		oModel, objeto, inst�ncia da Classe FWFormModel()
	@return 
		lRet, l�gico, .t. Persist�ncia bem sucedida
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function G600BCommit(oModel)

	Local lRet := .T.
		
	Begin Transaction

	If ( lRet )		
		lRet := FwFormCommit(oModel)
	EndIf
	
	If ( lRet .And. G600ChkNFlds(oModel:GetModel("MASTER"):GetStruct()) )
	
		If ( lRet .And. oModel:GetValue("MASTER","G6R_STATUS") == '2' )		
			
			lRet := GeraPedVend(oModel) .And. GX300Viagem(oModel,SC5->C5_NUM)
			
			If ( lRet )
				lRet :=	oModel:LoadValue("MASTER","G6R_PEDIDO",SC5->C5_NUM) .And. FwFormCommit(oModel)
			EndIf

		EndIf

	EndIf

	If ( !lRet )	
		DisarmTransaction()
	EndIf
		
	End Transaction

Return(lRet)

/*/{Protheus.doc} GeraPedVend(oModel)	
	Fun��o respons�vel pela persist�ncia dos dados 
	no banco de dados dos pedidos de vendas.
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		oModel, objeto, inst�ncia da Classe FWFormModel()
	@return 
		lRet, l�gico, .t. Persist�ncia bem sucedida
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GeraPedVend(oModel)

	Local lRet 		:= .F.

	Local c1DupNat	:= Upper(SuperGetMv("MV_1DUPNAT",.F.,""))
	
	Local aCabec	:= {}
	Local aLinha	:= {}
	Local aItens	:= {}
	
	Local oSubMdl	:= oModel:GetModel("MASTER")

	Private lMsErroAuto	:= .F.

	aAdd(aCabec,{"C5_TIPO" 		,"N",								Nil})
	aAdd(aCabec,{"C5_CLIENTE"	,oSubMdl:GetValue("G6R_SA1COD"),	Nil})
	aAdd(aCabec,{"C5_LOJACLI"	,oSubMdl:GetValue("G6R_SA1LOJ"), 	Nil})
	aAdd(aCabec,{"C5_CLIENT"	,oSubMdl:GetValue("G6R_SA1COD"),	Nil})
	aAdd(aCabec,{"C5_LOJAENT"	,oSubMdl:GetValue("G6R_SA1LOJ"),	Nil})
	aAdd(aCabec,{"C5_CONDPAG"	,oSubMdl:GetValue("G6R_CONDPG"),	Nil})
	aAdd(aCabec,{"C5_TABELA" 	,oSubMdl:GetValue("G6R_TABELA"),	Nil})
	aAdd(aCabec,{"C5_MOEDA"  	,1,									Nil})
	aAdd(aCabec,{"C5_VEND1"  	,oSubMdl:GetValue("G6R_SA3COD"),	Nil})
	
	//Se parametro MV_1DUPNAT indica que natureza a ser considerada est� no campo C5_NATUREZ, �	
	// obrigado preencher o campo no cabe�alho do pedido.			   								�
	If ( "C5_NATUREZ" $ c1DupNat )
		aAdd(aCabec,{"C5_NATUREZ",GetAdvFval("SA1","A1_NATUREZ",xFilial("SA1")+oSubMdl:GetValue("G6R_SA1COD")+oSubMdl:GetValue("G6R_SA1LOJ"))  ,Nil})
	Endif
		   	
	aAdd(aLinha,{"C6_ITEM",		StrZero(1,TamSX3("C6_ITEM")[1]),	Nil})
	aAdd(aLinha,{"C6_PRODUTO",	oSubMdl:GetValue("G6R_PRODUT"),		Nil})
	aAdd(aLinha,{"C6_QTDVEN",	1,									Nil})
	aAdd(aLinha,{"C6_PRCVEN",	oSubMdl:GetValue("G6R_VALACO"),		Nil})
	aAdd(aLinha,{"C6_PRUNIT",	oSubMdl:GetValue("G6R_VALACO"),		Nil})
	aAdd(aLinha,{"C6_VALOR",	oSubMdl:GetValue("G6R_VALACO"),		Nil})
	aAdd(aLinha,{"C6_TES",		oSubMdl:GetValue("G6R_TES"),		Nil})
	aAdd(aLinha,{"C6_DESCONT",	oSubMdl:GetValue("G6R_PEDESC"),		Nil})
	aAdd(aLinha,{"C6_VALDESC",	oSubMdl:GetValue("G6R_VLDESC"),		Nil}) 
	
	aAdd(aItens,aLinha)
	
	FwMsgRun(Nil,{|| MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3)},Nil,"Gerando o pedido de venda...")
	
	lRet := !lMsErroAuto

	If ( lMsErroAuto )
		MostraErro()
	EndIf
	
	aCabec := {}
	aItens := {} 
	lMsErroAuto	:= .F.
Return(lRet)

/*/{Protheus.doc} G600BTudoOk(oModel)	
	Fun��o respons�vel pela valida��o dos dados digitados 
	nos principais campos.
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		oModel, objeto, inst�ncia da Classe FWFormModel()
	@return 
		lRet, l�gico, .t. Persist�ncia bem sucedida
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function G600BTudoOk(oModel)

	Local lRet	:= .T.

	Local oSubG6R	:= oModel:GetModel("MASTER")

	If ( G600ChkNFlds(oSubG6R:GetStruct()) )

		If ( Empty(oSubG6R:GetValue("G6R_FCS")) .And. Empty(oSubG6R:GetValue("G6R_FCI")) )
			lRet := .f.
			FWAlertHelp("Nenhum dos fatores (Sucesso ou Insucesso) foram preenchidos","Preencha um fator.","Sem Informa��o")
		EndIf

		If ( lRet )
			
			If ( !Empty(oSubG6R:GetValue("G6R_FCI")) .And. oSubG6R:GetValue("G6R_STATUS") != "3" )
				lRet := .f.
				FWAlertHelp("Para uso do fator de 'Insucesso' dever� ser informado um 'Status 3-Perdido'.","Ajuste o conte�do do campo 'Status Or�am.'.","Status Incorreto.")
			ElseIf ( !Empty(oSubG6R:GetValue("G6R_FCS")) .And. oSubG6R:GetValue("G6R_STATUS") != "2" )
				lRet := .f.
				FWAlertHelp("Para uso do fator de 'Sucesso' dever� ser informado 'Status 2-Ganho'.","Ajuste o conte�do do campo 'Status Or�am.'.","Status Incorreto.")
			EndIf

		EndIf
	
	EndIf

Return(lRet)

/*/{Protheus.doc} SetModelStruct()	
	Fun��o respons�vel pela cosntru��o da estrutura 
	do modelo de dados do cabe�alho
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		
	@return 
		oStruct, objeto, inst�ncia da classe FwFormModelStruct
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetModelStruct()

	Local oStruct := FWFormStruct(1, "G6R") 

	If ( G600ChkNFlds(oStruct) )
		// GATILHO - GRID TURNO                
		oStruct:AddTrigger(;	
			'G6R_FCI',;                   	// [01] Id do campo de origem
			'G6R_DESFCI',;                  	// [02] Id do campo de destino
			{ || .T. },; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
			{ |oSubMdl,cField,xContent| RuleTrigger(oSubMdl,cField,xContent,'G6R_DESFCI') } ) // [04] Bloco de codigo de execu��o do gatilho
		
		oStruct:AddTrigger(;	
			'G6R_FCI',;                   	// [01] Id do campo de origem
			'G6R_STATUS',;                  	// [02] Id do campo de destino
			{ || .T. },; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
			{ |oSubMdl,cField,xContent| RuleTrigger(oSubMdl,cField,xContent,'G6R_STATUS') } ) // [04] Bloco de codigo de execu��o do gatilho
		
		oStruct:AddTrigger(;	
			'G6R_FCS',;                   	// [01] Id do campo de origem
			'G6R_DESFCS',;                  	// [02] Id do campo de destino
			{ || .T. },; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
			{ |oSubMdl,cField,xContent| RuleTrigger(oSubMdl,cField,xContent,'G6R_DESFCS') } ) // [04] Bloco de codigo de execu��o do gatilho
		
		oStruct:AddTrigger(;	
			'G6R_FCS',;                   	// [01] Id do campo de origem
			'G6R_STATUS',;                  	// [02] Id do campo de destino
			{ || .T. },; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
			{ |oSubMdl,cField,xContent| RuleTrigger(oSubMdl,cField,xContent,'G6R_STATUS') } ) // [04] Bloco de codigo de execu��o do gatilho
		
		oStruct:AddTrigger(;	
			'G6R_CNTPRO',;                   	// [01] Id do campo de origem
			'G6R_NOMCNT',;                  	// [02] Id do campo de destino
			{ || .T. },; 						// [03] Bloco de codigo de valida��o da execu��o do gatilho
			{ |oSubMdl,cField,xContent| RuleTrigger(oSubMdl,cField,xContent,'G6R_NOMCNT') } ) // [04] Bloco de codigo de execu��o do gatilho

		//oStruct:SetProperty("*",MODEL_FIELD_OBRIGAT, .F.)
		oStruct:SetProperty("G6R_STATUS",MODEL_FIELD_OBRIGAT, .T.)

		oStruct:SetProperty("G6R_STATUS", MODEL_FIELD_WHEN, {|| !Empty(FwFldGet("G6R_FCS")) .Or. !Empty(FwFldGet("G6R_FCI")) })
		oStruct:SetProperty("G6R_FCS", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("G6R_FCI")) })
		oStruct:SetProperty("G6R_FCI", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("G6R_FCS")) })
		oStruct:SetProperty("G6R_DTASSI", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("G6R_FCI")) })
		oStruct:SetProperty("G6R_CNTPRO", MODEL_FIELD_WHEN, {|| Empty(FwFldGet("G6R_FCI")) })

	EndIf

Return(oStruct)

/*/{Protheus.doc} RuleTrigger()	
	Fun��o respons�vel pela execu��o dos gatilhos 	
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 
		oSubMdl, objeto, inst�ncia da Classe FwFormField
		cField, caractere, nome do campo disparador do gatilho
		xContent, qualquer, conte�do do campo cField
		cTarget, caractete, nome do campo destino do gatilho
	@return 
		xRet, qualquer, conte�do que ser� informado no campo destino
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function  RuleTrigger(oSubMdl,cField,xContent,cTarget)

	Local xRet

	If ( !Empty(xContent) )

		If ( cField $ 'G6R_FCS|G6R_FCI' )

			If ( cTarget == 'G6R_DESFCS' )
				xRet := AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+xContent,"X5_DESCRI"))
			ElseIf ( cTarget == 'G6R_DESFCI' )

				xRet := AllTrim(Posicione("SX5",1,xFilial("SX5")+"A6"+xContent,"X5_DESCRI"))
			
				oSubMdl:LoadValue("G6R_DTASSI", SToD(""))
				oSubMdl:LoadValue("G6R_CNTPRO","")
				oSubMdl:LoadValue("G6R_NOMCNT","")

			ElseIf ( cTarget == 'G6R_STATUS' )			
				xRet := Iif(cField == 'G6R_FCS','2','3')
			EndIf
		
		ElseIf ( cField == 'G6R_CNTPRO' )
			xRet := Alltrim(POSICIONE("SU5",1,XFILIAL("SU5")+xContent,"U5_CONTAT"))
		EndIf
	
	Else
		xRet := Iif(cTarget == 'G6R_STATUS', '1','')
	EndIf

Return(xRet)

/*/{Protheus.doc} SetViewStruct()	
	Fun��o respons�vel pela constru��o da estrutura da view
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 31/01/2022
	@version version
	@param 		
	@return 
		oStruct, objeto, inst�ncia da classe FwFormViewStruct
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SetViewStruct()

	Local oStruct := FWFormStruct(2, "G6R") 

	Local aFields	:= {}
	Local aNewFields:= {}

	Local nI		:= 0
	Local nNumber	:= 0

	If ( G600ChkNFlds(oStruct,aNewFields) )

		//Grupos de campos
		oStruct:AddGroup( "SUCESSO", "Sucesso", "" , 2 )
		oStruct:AddGroup( "INSUCESSO", "Insucesso", "" , 2 )
		oStruct:AddGroup( "ASSINATURA", "Assinatura", "" , 2 )
	
		aFields := aClone(oStruct:GetFields())

		For nI := 1 To Len(aFields)

			If ( aScan(aNewFields,aFields[nI,1]) == 0 /*.And. !(aFields[nI,3] $ "G6R_NROPOR|G6R_CODIGO|G6R_OPOREV")*/ )
				oStruct:RemoveField(aFields[nI,1])
			Else
				
				nNumber++				
				
				If ( aFields[nI,1] == "G6R_STATUS" )
					oStruct:SetProperty(aFields[nI,1],MVC_VIEW_ORDEM,"06")	
				Else
					
					If ( nNumber == 6 )
						nNumber := 7
					EndIf
					oStruct:SetProperty(aFields[nI,1],MVC_VIEW_ORDEM,StrZero(nNumber,2))	
				EndIf	
				
			EndIf

		Next nI
		
		//Defini��o de Consultas Padr�es
		oStruct:SetProperty("G6R_FCS", MVC_VIEW_LOOKUP , "A6")				
		oStruct:SetProperty("G6R_FCI", MVC_VIEW_LOOKUP , "A6")				
		oStruct:SetProperty("G6R_CNTPRO", MVC_VIEW_LOOKUP , "G6RSU5")				

		//Defini��o de altera��o de campo
		oStruct:SetProperty("G6R_STATUS" , MVC_VIEW_CANCHANGE, .F.)
		oStruct:SetProperty("G6R_DTASSI" , MVC_VIEW_CANCHANGE, .T.)
		oStruct:SetProperty("G6R_CNTPRO" , MVC_VIEW_CANCHANGE, .T.)

		//Defini��o dos agrupamentos de campos		
		oStruct:SetProperty("G6R_FCS" , MVC_VIEW_GROUP_NUMBER, "SUCESSO" )
		oStruct:SetProperty("G6R_DESFCS" , MVC_VIEW_GROUP_NUMBER, "SUCESSO" )
		oStruct:SetProperty("G6R_FCI" , MVC_VIEW_GROUP_NUMBER, "INSUCESSO" )
		oStruct:SetProperty("G6R_DESFCI" , MVC_VIEW_GROUP_NUMBER, "INSUCESSO" )
		oStruct:SetProperty("G6R_STATUS" , MVC_VIEW_GROUP_NUMBER, "ASSINATURA" )
		oStruct:SetProperty("G6R_DTASSI" , MVC_VIEW_GROUP_NUMBER, "ASSINATURA" )
		oStruct:SetProperty("G6R_CNTPRO" , MVC_VIEW_GROUP_NUMBER, "ASSINATURA" )
		oStruct:SetProperty("G6R_NOMCNT" , MVC_VIEW_GROUP_NUMBER, "ASSINATURA" )
		oStruct:SetProperty("G6R_USRASS" , MVC_VIEW_GROUP_NUMBER, "ASSINATURA" )
		oStruct:SetProperty("G6R_DSCUSR" , MVC_VIEW_GROUP_NUMBER, "ASSINATURA" )

	EndIf	

Return(oStruct)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Defini��o da view
@sample	ViewDef() 
@return	oModel  Retorna o VIEW de Dados 
@author	GTP
@since		14/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FwLoadModel('GTPA600B')
	Local oView		:= FWFormView():New()
	Local oStruct	

	oStruct := SetViewStruct()

	oView:SetModel(oModel)

	oView:AddField('VIEW_MASTER' ,oStruct,'MASTER')

	oView:CreateHorizontalBox('TELA', 100)

	oView:SetDescription('Contrato - Oportunidade')
	oView:SetOwnerView('VIEW_MASTER','TELA')

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA600B()
Executa para chamar a view
@sample	GTPA600B() 
@return	
@author	GTP
@since		14/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA600B()
Local lAprovOp 	:= GTPGetRules("APRVTRMOPE",,,.F.)

	Local lRet	:= .T.

	Local cMsg		:= ""
	Local cTitulo	:= ""

	Local nI		:= 0

	Local aFields	:= {}

	Local oModel

	If ( G600ChkNFlds(,aFields) )

		If !VldServExtr()
			lRet	:= .F.
		Endif

		If lRet .and. !VldTrechos()
			lRet	:= .F.
			FwAlertHelp('Existem trechos que n�o foram preechido a data/hora de sa�da ou chegada')
		Endif

		If lRet .and. G6R->G6R_QUANT <= 0
			lRet	:= .F.
			FwAlertHelp('N�o foi informado uma quantidade de ve�culos v�lido')
		Endif

		If lAprovOp .And. G6R->(FieldPos('G6R_APRVOP')) > 0 .And. G6R->G6R_APRVOP != '3'
			lRet := .F.
			FwAlertHelp('Aprova��o operacional obrigat�ria para o fechamento do contrato', 'Solicite ou aguarde a aprova��o para o contrato')
		Endif

		If ( lRet )

			oModel := FwLoadModel("GTPA600B")
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
			
			FWExecView("Fechamento Contrato", "GTPA600B", MODEL_OPERATION_UPDATE, /*[ oDlg ]*/, /*[ bCloseOnOK ]*/, /*[ bOk ]*/, /*[ nPercReducao ]*/, /*[ aEnableButtons ]*/, /*[ bCancel ]*/, /*[ cOperatId ]*/, /*[ cToolBar ]*/, oModel)
			
		EndIf	
	
	Else

		cMsg := "H� campos necess�rios ao processo que n�o est�o cadastrados no seu sistema." + chr(13)
		cMsg += "Os campo que devem existir, s�o: " + chr(13)
		
		For nI := 1 to Len(aFields)
			cTitulo := GetSx3Cache(aFields[nI],"X3_TITULO")
			cMsg += " - " + PadR(aFields[nI], 10) + Space(3) + "(" + Iif(ValType(cTitulo) == "C", Alltrim(cTitulo), " ") + "); " + chr(13)
		Next nI
		
		cMsg += "Entre em contato com o administrador de sistemas."
		
		FWAlertHelp("N�o � poss�vel efetuar o fechamento do contrato.",cMsg,"Dicion�rio/base de dados incompletos")
	EndIf

Return()
