#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'JURA309.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA309
Restri��o de acesso TOTVS Jur�dico Departamento
/*/
//-------------------------------------------------------------------
Function JURA309()

Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001)//"Restri��o de acesso TOTVS Jur�dico Departamento"
	oBrowse:SetAlias( "O1G" )
    oBrowse:SetMenuDef( 'JURA309' )
    oBrowse:SetLocate()
	oBrowse:Activate()
	

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "VIEWDEF.JURA309", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003 , "VIEWDEF.JURA309", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004 , "VIEWDEF.JURA309", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005 , "VIEWDEF.JURA309", 0, 5, 0, NIL } ) //"Excluir"


Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela defini��o do modelo
@since 02/12/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrO1G   := FWFormStruct(1,'O1G')
	oModel := MPFormModel():New('JURA309', /*bPreValidacao*/, {|oModel| J309TOK(oModel)}/*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('O1GMASTER',/*cOwner*/,oStrO1G,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001) //"Restri��o de acesso TOTVS Jur�dico Departamento"
	oModel:GetModel('O1GMASTER'):SetDescription(STR0006) //"Restri��o de Acesso"
	oModel:SetPrimaryKey( { "O1G_FILIAL", "O1G_GRPUSU", "O1G_ROTINA" } )

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel pela defini��o da view
@since 02/12/2021
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel  := FwLoadModel('JURA309')
Local oStructO1G := FWFormStruct(2, 'O1G')
Local oView   

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA309_VIEW" ,oStructO1G,'O1GMASTER')
	oView:CreateHorizontalBox( "TELA", 100 )
	oView:SetOwnerView( "JURA309_VIEW", "TELA")
	oView:SetDescription(STR0006) //"Restri��o de Acesso"
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J309vldRot( cRotina )
Respons�vel pela valida��o no preenchimento do campo O1G_ROTINA

@param  cRotina - Indica o Rotina que deve ser validada
					1=Publica��es
					2=Distribui��es
					3=Configura��es
					4=Cadastro B�sico
					5=Usu�rios
@return lRet    - Indica se o valor � v�lido
/*/
//-------------------------------------------------------------------
Function J309vldRot( cRotina )
Local lRet := .F.
Default cRotina := ""

	If Empty( cRotina ) .AND. VALTYPE(M->O1G_ROTINA) <> "U"
		cRotina := M->O1G_ROTINA
	EndIf

	lRet := cRotina $ "12345"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J309Rotina(cRotina)
Respons�vel por compor os itens no combo box do campo O1G_ROTINA

@param cRotina       - Indica o Rotina atual do registro
@retrunr cCboxRotina - Descri��o dos Rotina

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J309Rotina( cRotina )

Local cCboxRotina := ""

	cCboxRotina := "1=" + STR0007 + ";"  // "1=Publica��es"
	cCboxRotina += "2=" + STR0008 + ";"  // "2=Distribui��es"
	cCboxRotina += "3=" + STR0009 + ";"  // "3=Configura��es"
	cCboxRotina += "4=" + STR0010 + ";"  // "4=Cadastro B�sico"
	cCboxRotina += "5=" + STR0011 + ";"  // "5=Usu�rios"

Return cCboxRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} J309TOK
Valida informa��es ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@sample
oModel:AddFields( "NTAMASTER", NIL, oStruct,, {|oX| J309TOK(oModel)})

@since 20/07/09
/*/
//-------------------------------------------------------------------
Function J309TOK(oModel)
Local nOpc       := oModel:GetOperation()
Local lRet       := .T.

	If nOpc == 4
		oModel:SetValue("O1GMASTER",'O1G_DTALTE' ,DATE())
		If !Empty(__CUSERID)
			oModel:LoadValue("O1GMASTER",'O1G_USUALT',Left( PswChave(__CUSERID), TamSX3('O1G_USUALT')[1] ) )
		EndIf
	EndIf

Return lRet
