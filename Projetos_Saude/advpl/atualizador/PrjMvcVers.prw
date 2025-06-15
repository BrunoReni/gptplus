#include 'protheus.ch'
#include 'FWMVCDEF.CH'

/*/{Protheus.doc} 
    Tela de vers�es anteriores
    @author eduardo.bento
    @since 31/07/2020
/*/

Main Function PrjMvcVers()
     exibeVerAnt()
return

Function exibeVerAnt()

    Local cFiltro   := " BI9_FILIAL = '" + xFilial('BI9') + "' .AND. BI9_CODIGO = '" + BI8->BI8_CODIGO +"'"
    Local cNomeArt  := BI8->BI8_NOME
    Private oBrowse := nil
    
	oBrowse:= FWmBrowse():New()
	oBrowse:SetDescription( "Vers�es Dispon�veis de " + allTrim(cNomeArt) )
	oBrowse:SetAlias( "BI9" )
    oBrowse:SetFilterDefault(cFiltro)
	oBrowse:SetMenuDef('PrjMvcVers')
    oBrowse:SetProfileID( 'PrjMvcVers' )
	oBrowse:DisableDetails(.T.)

	oBrowse:AddLegend( "BI9_STATAU=='1'", "GREEN"	, "Status da Atualiza��o Autom�tica: Sucesso"		)
	oBrowse:AddLegend( "BI9_STATAU=='0'", "RED"		, "Status da Atualiza��o Autom�tica: Houve Erro"	)
	oBrowse:AddLegend( "BI9_STATAU=='2'", "YELLOW"	, "Status da Atualiza��o Autom�tica: Em Andamento"	)
	oBrowse:AddLegend( "Empty(BI9_STATAU) .or. BI9_STATAU=='3'","BLUE"	, "Status da Atualiza��o Autom�tica: Indefinido"	)
	
    //Ponto de entrada para mensagem
	If !isBlind()
		oBrowse:Activate()
	EndIf
 
Return .T.

Static Function MenuDef()
	Local aRotina 	:= {}
    Add Option aRotina Title "Escolher Vers�o"		Action "PrjAtuVerAnt()" 		Operation MODEL_OPERATION_UPDATE Access 0 
	Add Option aRotina Title "Visualizar Detalhes"	Action "VIEWDEF.PrjMvcVers"		Operation MODEL_OPERATION_VIEW Access 0
	Add Option aRotina Title "Importar Manualmente"	Action "PrjAtuManual (,'BI9')"	Operation MODEL_OPERATION_UPDATE Access 0 
Return aRotina

Static Function ModelDef()
	Local oStruBI9 	:= FWFormStruct( 1, 'BI9')
	Local oModel	:= Nil
	
	oModel := MPFormModel():New( 'PrjMvcVers', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	//Adi��o dos campos e Grids
	oModel:AddFields( 'BI9MASTER', /*cOwner*/ , oStruBI9 )

	//Descri��o
	oModel:GetModel( 'BI9MASTER' ):SetDescription( "Artefato Vers�o" )

Return oModel

Static Function ViewDef()
	Local oView		:= FWFormView():New()
	Local oModel	:= FWLoadModel( 'PrjMvcVers' )
	Local oStruBI9	:= FWFormStruct( 2, 'BI9' )
	
	oView:SetModel( oModel )

	//Vistas principais
	oView:AddField( 'VIEW_BI9' , oStruBI9 , 'BI9MASTER' )
    
	oView:EnableTitleView( 'VIEW_BI9', 'Destalhes da Vers�o' )

Return oView