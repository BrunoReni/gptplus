#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA895.CH'

Static oModel:= nil

//-----------------------------------------------------------------
/*/{Protheus.doc} TECA895()
Itens Intercambiaveis
@sample 	TECA895()
@since		02/09/2016
@author	Francisco Oliveira
@version 	P12
@return 	cRet, Caractere
/*/
//-----------------------------------------------------------------
Function TECA895()
	
	Local oBrowse := FWmBrowse():New()
	
	oBrowse:SetAlias('TWY')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()
	
Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Rotina para constru��o do menu
@sample 	MenuDef()
@author	Francisco Oliveira
@since		02/09/2016
@version	P12
@Return	aRotina: Objeto com todas as op��es inseridas no menu.
/*/
//-----------------------------------------------------------------
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TECA895' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA895' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TECA895' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.TECA895' OPERATION 5 ACCESS 0
	
Return aRotina

//-----------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Rotina para constru��o da Model
@sample 	ModelDef()
@author	Francisco Oliveira
@since		02/09/2016
@version	P12
@Return	Objeto com a Model em execu��o
/*/
//-----------------------------------------------------------------
Static Function ModelDef()
	
	Local oStruTWY	:= FWFormStruct( 1, 'TWY', {|cCampo|  ( Alltrim( cCampo )$"|TWY_CODPRO|TWY_DESPRO|TWY_ATIVO|")})
	Local oStruDET	:= FWFormStruct( 1, 'TWY', {|cCampo| !( Alltrim( cCampo )$"|TWY_CODPRO|TWY_DESPRO|TWY_ATIVO|")})
	Local bPos 		:= {|oModel| AT895VldPos(oModel)} //bPosValidacao
	Local bPreVal 	:= {|oMdlG,nLine,cAcao,cCampo,xValor| At895PreVl( oMdlG,nLine,cAcao,cCampo,xValor ) }
	Local bTudoOk 	:= {|oModel| At895TdOk( oModel ) }
	
	oModel := MPFormModel():New( 'TECA895',/*bPreValidacao*/, bTudoOk/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields( 'TWYMASTER', /*cOwner*/, oStruTWY )
	oModel:AddGrid( 'TWYDETAIL', 'TWYMASTER', oStruDET, bPreVal, bPos )
	
	oModel:SetRelation('TWYDETAIL',{{"TWY_FILIAL","xFilial('TWY')"},{"TWY_CODPRO", "TWY_CODPRO"}},TWY->(IndexKey(1)))
	
	oModel:GetModel("TWYDETAIL"):SetUniqueLine({"TWY_CODINT"})
	
	oModel:GetModel("TWYDETAIL"):SetOptional(.T.)
	
	oModel:SetDescription(STR0006)
	
	oModel:SetPrimaryKey( { "TWY_FILIAL", "TWY_CODPRO", "TWY_CODINT" } )
	
Return oModel

//-----------------------------------------------------------------
/*/{Protheus.doc} Viewdef()
Rotina para constru��o da Model
@sample 	Viewdef()
@author	Francisco Oliveira
@since		02/09/2016
@version	P12
@Return	oView: Objeto com todos os campos para a cria��o da tela
/*/
//-----------------------------------------------------------------
Static Function Viewdef()

	Local oModel   := ModelDef()
	Local oStruTWY := FWFormStruct( 2, 'TWY', {|cCampo|  ( Alltrim( cCampo )$"|TWY_CODPRO|TWY_DESPRO|TWY_ATIVO|")})
	Local oStruDET := FWFormStruct( 2, 'TWY', {|cCampo| !( Alltrim( cCampo )$"|TWY_CODPRO|TWY_DESPRO|TWY_ATIVO|")})
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	
	oView:AddField('VIEW_TWY',oStruTWY,'TWYMASTER')
	oView:AddGrid('VIEW_DET',oStruDET,'TWYDETAIL' )
	
	oView:CreateHorizontalBox('SUPERIOR',25)
	oView:CreateHorizontalBox('INFERIOR',75)
	
	oView:SetOwnerView('VIEW_TWY','SUPERIOR')
	oView:SetOwnerView('VIEW_DET','INFERIOR')
	
	oView:AddIncrementField( 'VIEW_DET', 'TWY_ITEM' )
	
Return oView

//-----------------------------------------------------------------
/*/{Protheus.doc} AT895VldPos(oModel)
Fun��o que valida se o produto do cabe�alho n�o esta na Grid.
@sample 	Viewdef()
@author	Francisco Oliveira
@since		02/09/2016
@version	P12
@Return	lRet: Retorna se o registro do c�digo atual foi localizado na tabela SE1 para altera��o.
/*/
//-----------------------------------------------------------------
Static Function AT895VldPos(oModel)

	Local lRet			:= .T.
	Local cCodProd	:= FwFldGet("TWY_CODPRO")
	
	If Alltrim(FwFldGet("TWY_CODINT")) == Alltrim(cCodProd)
		Aviso(STR0007,STR0008,{"Ok"}, 3)
		lRet	:= .F.
	Endif
	
Return lRet

/*/{Protheus.doc} At895PreVl
	Valida o tipo de produto inserido no cadastro

@author		josimar.assuncao
@since		16.11.2016
@version	P12
@param 		oMdlG, Objeto FwFormGridModel, grid sendo validado
@param 		nLine, Num�rico, n�mero da linha sendo validada 
@param 		cAcao, Caracter, a��o em opera��o no campo/linha
@param 		cCampo, Caracter, campo sendo validado
@return		L�gico, determina se a opera��o deve prosseguir ou n�o
/*/
Static Function At895PreVl(oMdlG,nLine,cAcao,cCampo,cConteudo)
Local lMatConsumo := .F.
Local lMatImplant := .F.
Local lMatUni	  := .F.
Local lRet		  := .T.

Default cAcao := ""
Default cCampo := ""

DbSelectArea("SB1")
SB1->( DbSetOrder( 1 ) ) // B1_FILIAL + B1_COD

If cAcao == "SETVALUE" .And. cCampo == "TWY_CODINT" .And. SB1->( DbSeek(xFilial("SB1")+cConteudo) )
	
	lMatImplant := Posicione("SB5", 1, xFilial("SB5")+cConteudo,"B5_GSMI" ) == "1" //MATERIAL IMPLANTA��O
	lMatConsumo := Posicione("SB5", 1, xFilial("SB5")+cConteudo,"B5_GSMC" ) == "1" //MATERIAL CONSUMO
	lMatUni		:= Posicione("SB5", 1, xFilial("SB5")+cConteudo,"B5_TPISERV" ) == "6" //UNIFORME
	
	If (!lMatImplant .And. !lMatConsumo .And. !lMatUni)
		lRet := .F.
		Help( , , "AT895PREVL_01", ,STR0009, 1, 0,,,,,,;  // "Produto n�o pode ser selecionado pois n�o est� definido como material de implanta��o, material de consumo ou uniforme."
		 			{STR0010})  // "Selecione um produto que esteja definido como Material de Implanta��o, Material de Consumo ou uniforme, no cadastro de Complemento de Produtos."
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} At895TdOk
	Valida se o produto inserido no cabe�alho corresponde a um produto com configura��o para material de implanta��o ou consumo

@author		josimar.assuncao
@since		16.11.2016
@version	P12
@param 		oModel, Objeto FwFormModel/MpFormModel, objeto principal do modelo de dados MVC
@return		L�gico, determina se a opera��o deve prosseguir ou n�o
/*/
Static Function At895TdOk( oModel )
Local oMdlCab := oModel:GetModel("TWYMASTER")
Local cPrdCab := oMdlCab:GetValue("TWY_CODPRO")
Local lMatConsumo := .F.
Local lMatImplant := .F.
Local lMatUni	  := .F.
Local lRet 		  := .T.

If !Empty( cPrdCab )
	
	lMatImplant := Posicione("SB5", 1, xFilial("SB5")+cPrdCab,"B5_GSMI" ) == "1" //MATERIAL IMPLANTA��O
	lMatConsumo := Posicione("SB5", 1, xFilial("SB5")+cPrdCab,"B5_GSMC" ) == "1" //MATERIAL CONSUMO
	lMatUni		:= Posicione("SB5", 1, xFilial("SB5")+cPrdCab,"B5_TPISERV" ) == "6" //UNIFORME
	
	If (!lMatImplant .And. !lMatConsumo .And. !lMatUni)
		lRet := .F. 
		Help( , , "AT895TDOK_01", ,STR0009, 1, 0,,,,,,;  // "Produto n�o pode ser selecionado pois n�o est� definido como material de implanta��o, material de consumo ou uniforme."
		 			{STR0010} )  // "Selecione um produto que esteja definido como Material de Implanta��o, Material de Consumo ou uniforme, no cadastro de Complemento de Produtos."
	EndIf	
EndIf

Return lRet
