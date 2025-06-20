#INCLUDE "UBAA020.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} UBAA020A
//TODO Descri��o auto-gerada.
@author silvana.torres
@since 14/11/2017
@version undefined

@type function
/*/
Function UBAA020A()

Return .T.

/*/{Protheus.doc} ViewDef
Retorna o modelo de visualiza��o da rotina
@author silvana.torres
@since 14/11/2017
@version undefined

@type function
/*/
Static Function ViewDef()
	Local oStruN70 		:= FWFormStruct(2,"N70") // Estrutura Model da N70 - Esteiras
	Local oStruN71GR 	:= FWFormStruct(2,"N71") // Estrutura Model para Grid N71 - Esteiras X Fard�o
	Local oModel   		:= FwLoadModel( 'UBAA020' )
	Local oView    		:= FWFormView():New()
 
	// Muda os campos para VISUAL
	oStruN70:SetProperty( 'N70_CODIGO' , MVC_VIEW_CANCHANGE , .F.)
	oStruN70:SetProperty( 'N70_DESCRI' , MVC_VIEW_CANCHANGE , .F.)
	oStruN70:SetProperty( 'N70_CODUNB' , MVC_VIEW_CANCHANGE , .F.)

	If !Empty(cUserBenf)
		oStruN70:RemoveField( "N70_CODUNB" )
	Endif
	 
	//Remove campos desnecess�rios para visualiza��o
	oStruN71GR:RemoveField("N71_SAFRA")
	oStruN71GR:RemoveField("N71_PRODUT")
	oStruN71GR:RemoveField("N71_LOJA")
	oStruN71GR:RemoveField("N71_FAZEN")
	oStruN71GR:RemoveField("N71_TALHAO")
	oStruN71GR:RemoveField("N71_VAR")
	oStruN71GR:RemoveField("N71_CODPRO")
	oStruN71GR:RemoveField("N71_DESPRO")

	// Adiciona na View o bot�o de Legenda
	oStruN71GR:AddField( "N71_STSLEG" ,'01' , "", "Legenda" , {} , 'BT' ,'@BMP', ;//"Status do Fard�o"
	 						NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	// Adiciona na View os bot�es de Baixo e Cima para reordena��o
	oStruN71GR:AddField( "N71_MOVUP"  ,'02' , "- ", "UP3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )
	oStruN71GR:AddField( "N71_MOVDW"  ,'03' , "+ ", "DOWN3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	oView:SetModel( oModel ) // Seta o Model na View

	oView:AddField( "UBAA020_N70", oStruN70, "N70UBAA020" ) // Field da Esteira
	
	oView:AddGrid( "UBAA020_N72", oStruN71GR, "N72UBAA020") // Grid do Esteira X Fard�o

	oView:CreateVerticallBox( "TELANOVA" , 100 ) // Box Pai

	// Cria��o de Layout 
	oView:CreateHorizontalBox( "SUPERIOR" , 15, "TELANOVA")
	oView:CreateHorizontalBox( "INFERIOR" , 85, "TELANOVA")

	// Atribui��o de Layouts a cada SubView 
	oView:SetOwnerView("UBAA020_N70", "SUPERIOR")
	oView:SetOwnerView("UBAA020_N72", "INFERIOR")
	
	oView:EnableTitleView("UBAA020_N70")

	// Fecha a tela ap�s salvar os dados�
	oView:SetCloseOnOk({||.T.})

Return oView
