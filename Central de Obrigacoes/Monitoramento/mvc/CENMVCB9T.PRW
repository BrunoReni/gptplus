#Include "Protheus.ch"
#Include "FwMvcDef.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBVZ
Descricao:  Rotina MVC do Valor Pr�-Estabelecido referente ao Projeto de 
            Monitoramento TISS.

@author Hermiro J�nior
@since 29/08/2019
@version 1.0

@Param: cFiltro -> Filtro do mBrowse vinda do Fonte CENMVCBVZ
		lAutom	-> .T. - Automa��o de Testes | .F. = Chamada da Fun��o padr�o.
/*/
//-------------------------------------------------------------------
Function CENMVCB9T(cFiltro,lAutom)

    Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Valor Pr�-Estabelecido" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "B9T"
	Private oDlgB9T
	
	Default lAutom	:= .F.
	Default cFiltro	:= 	" B9T_FILIAL = xFilial( 'B9T' ) .AND. " +;
						" B9T_CODOPE = B3D->B3D_CODOPE .AND. " +;
						" B9T_CDOBRI = B3D->B3D_CDOBRI .AND. " +;
						" B9T_ANO = B3D->B3D_ANO .AND. " +;
						" B9T_CDCOMP = B3D->B3D_CODIGO "
	
	//Ordena a tabela pela Indice 1 na Abertura do Browse
    (cAlias)->(dbSetOrder(2))
	// Cria��o dos Componentes Visuais
	
	If !lAutom	
		Define MsDialog oDlgB9T Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel	
		oFWLayer:Init( oDlgB9T, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf
	// Cria a Tela do Browse
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:AddLegend( "B9T_STATUS=='1'", "YELLOW"	, "Pendente Valida��o" )
	oBrowse:AddLegend( "B9T_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "B9T_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "B9T_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "B9T_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "B9T_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "B9T_STATUS=='7'", "WHITE"	, "Pendente Gera��o do Arquivo" )
	oBrowse:AddLegend( "B9T_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	oBrowse:SetMenuDef( 'CENMVCB9T' )
	oBrowse:SetProfileID( 'CENMVCB9T' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgB9T Center
	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Op��es do Menu

@author Hermiro J�nior
@since 29/08/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	
	Private aRotina	:= {}

    aAdd( aRotina, { "Visualizar"				, 'VIEWDEF.CENMVCB9T'					, 0 , 2 , 0 , Nil } ) // Visualiza��o das Guias
    aAdd( aRotina, { "Validar Guias"			, 'VldVlrPre(.F.)'						, 0 , 2 , 0 , Nil } ) // Valida��o do Valor Pre Estabelecido
	aAdd( aRotina, { "Cr�ticas Guia" 			, 'VisCriPre(.F.,"1")'					, 0 , 2 , 0 , Nil } ) // Visualiza��o das Criticas  do Valor Pre Estabelecido
	aAdd( aRotina, { "Criticas XTR" 			, 'VisCriPre(.F.,"3")'					, 0 , 2 , 0 , Nil } ) // Visualiza��o das Criticas  do Valor Pre Estabelecido
	aAdd( aRotina, { "Hist�rico de Guias"		, 'VisGuiIden(B9T->B9T_IDVLRP,.F.)'		, 0 , 2 , 0 , Nil } ) // Visualiza��o das Guias Identificadas como Valor Pre Estabelecido.

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author Hermiro J�nior
@since 29/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

	Local oStrB9T	:= FwFormStruct(1,'B9T')

	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMVCB9T')
	oModel:AddFields( 'B9TMASTER', NIL, oStrB9T )
	oModel:GetModel( 'B9TMASTER' ):SetDescription( "Valor Pr�-Estabelecido")
	oModel:SetDescription( "Valor Pr�-Estabelecido" )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: View da Rotina de Outra Remunera��o. 

@author Hermiro J�nior
@since 29/08/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMVCB9T' )
	Local oStruBVQ 	:= FWFormStruct( 2, 'B9T' ) 
	Local oView    	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B9T' , oStruBVQ, 'B9TMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_B9T', 'SUPERIOR' )
	//Insiro descri��es nas views
	oView:EnableTitleView( 'VIEW_B9T', "Dados Valor Pr�-Estabelecido" )

	oView:AddUserButton( 'Criticas Vld'	, 'CLIPS', {|oView| VisCriPre(.F.,"1")} )
	oView:AddUserButton( 'Criticas XTR'	, 'CLIPS', {|oView| VisCriPre(.F.,"3")} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVlrPre
Descricao: Validacao do Valor Pre Estabelecido 

@author Hermiro J�nior
@since 02/09/2019
@version 1.0

@Param:
/*/
//-------------------------------------------------------------------
Function VldVlrPre(lAutom)
	Default lAutom		:= .F. 

	If lAutom .Or. MsgYesNo("Este processo ir� validar todos as guias pendentes em segundo plano. Deseja continuar?")
		Msginfo("Processo iniciado. Para acompanhar o andamento da valida��o, atualize a tela.")
		StartJob("B9TVldJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.T.,B9T->B9T_CODOPE)
		DelClassIntf()
	else
		Msginfo("O Job sera processado posteriormente de acordo com a parametrizacao.")
	EndIf

Return

Function B9TVldJob(cEmp, cFil, lJob, cCodOpe)
	Local aSvcVldr      := {}
	Local aSvcVlInd     := {}
	Default lJob := .T.
	
	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
                    
	aSvcVldr  := {SvcVlGrVPr():New()}
	aSvcVlInd := {SVCVLINVPR():New()}
	ExecVldMon(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VisGuiIden
Descricao: Visualiza��o Guias com o mesmo identificador 

@author Hermiro J�nior
@since 02/09/2019
@version 1.0

@Param: cIdVlrEst 	-> Identificador da Tabela B9T/B9T
		lAutom		-> .T. - Automa��o de Testes | .F. = Chamada da Fun��o padr�o.
/*/
//-------------------------------------------------------------------
Function VisGuiIden(cIdVlrEst,lAutom)

	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Hist�rico de Guias" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "B9T"
    Private oDlgIdVlr
	Private aRotina	:=	{}
	Default cIdVlrEst	:= ''
	Default lAutom		:= .F.

	// Adiciona a Rotina ao Menu
	aAdd( aRotina, { "Cr�ticas Guia", 'VisCriPre(.F.,"1")'	 , 0 , 7 , 0 , Nil } ) // Visualiza��o das Criticas
	aAdd( aRotina, { "Cr�ticas XTR", 'VisCriPre(.F.,"3")'	 , 0 , 7 , 0 , Nil } ) // Visualiza��o das Criticas
    aAdd( aRotina, { "Visualizar"  , 'VIEWDEF.CENMVCB9T', 0 , 2 , 0 , Nil } ) // Visualiza��o   das Guias
	//Ordena a tabela pela Indice 1 na Abertura do Browse
    (cAlias)->(dbSetOrder(1))
	//Defino o Filtro Padr�o
	If !Empty(cIdVlrEst)
		cFiltro		:= "B9T_FILIAL==xFilial('B9T') .AND. B9T_IDVLRP =='"+cIdVlrEst+"' "
	EndIf
	// Cria��o dos Componentes Visuais
	If !lAutom
		// Cria a Tela do Browse
		Define MsDialog oDlgIdVlr Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgIdVlr, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf 
	//Cria��o do Browse da B9T
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	oBrowse:SetProfileID( 'VisGuiIden' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	oBrowse:AddLegend( "B9T_STATUS=='1'", "YELLOW"	, "Pendente Valida��o" )
	oBrowse:AddLegend( "B9T_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "B9T_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "B9T_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "B9T_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "B9T_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "B9T_STATUS=='7'", "WHITE"	, "Pendente Gera��o do Arquivo" )
	oBrowse:AddLegend( "B9T_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	//Ativa os componentes visuais da Dialog e MBrowse
	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgIdVlr Center
	EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}
Descricao:  Visualiza��o das Criticas das Guias de Valor preestabelecido. 

@author Everton Mateus
@since 02/09/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function VisCriPre(lAuto,cTipo)

	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
			   		" B3F_TIPO = '" + cTipo + "' .AND. " +;
			   		" B3F_ORICRI $ 'B9T' .AND. SubStr(B3F_IDEORI,1,88) = '" + B9T->(B9T_CODOPE+B9T_CNES+B9T_CPFCNP+B9T_CDMNPR+B9T_RGOPIN+B9T_IDVLRP+B9T_COMCOB+B9T_CDOBRI+B9T_ANO+B9T_CDCOMP+B9T_LOTE) + "'" 
	
	Default cTipo := "1"
	Default lAuto := .F.

	If(!lAuto)
		PLBRWCrit(cFiltro, lAuto)
	EndIf		
Return 