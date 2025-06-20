#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB5P

Manutencao de balancete

@author Jos� Paulo
@since 28/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCB5P(lAuto,cDescri)
	Local oBrowse	:= Nil
	Local cFiltro := " B5P_FILIAL = xFilial( 'B5I' ) .AND. B5P_CODOPE = B5I->B5I_CODOPE .AND. B5P_CMPLOT = B5I->B5I_CMPLOT .AND. B5P_NUMLOT = B5I->B5I_NUMLOT "
	Default lAuto   := .F.
	Default cDescri := "Ocorr�ncias Gerais"

	If cDescri == "OCORR�NCIAS POR GUIA"
		cDescri:= "Ocorr�ncias por Guia"
	elseif cDescri == "OCORR�NCIAS GERAIS"
		cDescri:= "Ocorr�ncias Gerais"
	endif

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B5P')
	oBrowse:SetDescription(cDescri)
	oBrowse:SetMenuDef( 'CENMVCB5P' )
	IF Select("GRPB5P") > 0 
		cFiltro += " .AND. B5P->B5P_NMGOPE  = '" + ALLTRIM(GRPB5P->B5P_NMGOPE) + "' "
	EndIf
	oBrowse:SetFilterDefault(cFiltro)

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author Jos� Paulo
@since 28/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}
	aAdd( aRotina, { "Visualizar" , 'VIEWDEF.CENMVCB5P'		   , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Guia"       , "VISGUIMO(.f.)"               , 0 , 2 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B5P

@return oModel	objeto model criado

@author Jos� Paulo
@since 28/01/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB5P 	:= FWFormStruct( 1, 'B5P', , )
	Local oModel		:= Nil
	
	oModel := MPFormModel():New( "Ocorr�ncias por Guia", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B5PMASTER', NIL , oStruB5P )
	oModel:GetModel( 'B5PMASTER' ):SetDescription( "Ocorr�ncias Gerais" )
	oModel:SetPrimaryKey({"B5P_FILIAL","B5P_CODOPE","B5P_CMPLOT","B5P_NUMLOT","B5P_NMGOPE","B5P_CODGRU","B5P_CODPAD","B5P_CODPRO","B5P_CDCMER","B5P_CDCMGU"})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B5P

@return oView	objeto view criado

@author Jos� Paulo
@since 28/01/2020
/*/
//--------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCB5P' )
	Local oStruB5P := FWFormStruct( 2, 'B5P' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B5P' , oStruB5P , 'B5PMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B5P', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B5P', 'Ocorr�ncias Gerais' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Chama a fun��o que cont�m as guias do monitoramento (BRF), com o FWExecView j� abro a tela com benefici�rio

@author Jos� Paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------

function VISGUIMO(lTelaP)
	Local lMsg     := .F.
	Default lTelaP := .F.

	IF Select("GRPB5P") > 0 .And. lTelaP 
		lMsg:=BRF->(MsSeek(xFilial("BRF")+B5P->(GRPB5P->B5P_CODOPE+GRPB5P->B5P_NMGOPE)) )
	else
		lMsg:=BRF->(MsSeek(xFilial("BRF")+B5P->(B5P_CODOPE+B5P_NMGOPE)) )
	EndIf

	if lMsg
		FWExecView('Visualiza��o da Guia','CENMVCBRF',MODEL_OPERATION_VIEW)
	else
		ApMsgInfo("Guia n�o encontrada")
	endif

return