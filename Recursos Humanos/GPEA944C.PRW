#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA944C.CH'

Static cMVPEM
Static cMVFeedz

/*/{Protheus.doc} GPEA944C
Cadastro de De x Para de Departamentos para o P&M/Swile
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Function GPEA944C()

Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdBrowse
Local cIdGrid
Local oBrowseREN
Local oBrowseRET
Local oDlgPrinc
Local oPanelUp
Local oPanelDown
Local oRelacRET
Local oTela

DEFAULT cMVPEM      := SuperGetMv( 'MV_APIPEM1', Nil, "" )
DEFAULT cMVFeedz    := SuperGetMv( 'MV_APIFEE1', Nil, "" )

If Empty(cMVPEM) .And. Empty(cMVFeedz)
	//"Aten��o"###"O cadastro do De x Para somente deve ser utilizado quando a integra��o com o P&M ou com a Feedz estiver ativa."###"Contate o administrador do sistema para efetuar o ajuste na parametriza��o."
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0027), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0028) } )
	Return .F.
EndIf

If !ChkFile("REN")
	//"Aten��o"###"A tabela REN n�o existe no dicion�rio. � necess�rio atualiza��o do ambiente para acesso � rotina."###"Contate o administrador do sistema para efetuar a atualiza��o do ambiente."
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0002), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0003) } )
	Return .F.
EndIf

If !Empty( xFilial("REN") ) .Or. !Empty( xFilial("RET") )
	//"Aten��o"###"As tabelas REN e RET devem possuir modo de acesso compartilhado."###"Contate o administrador do sistema para efetuar a corre��o do ambiente."
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0004), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0005) } )
	Return .F.
EndIf

If Empty( xFilial("SQB") )
	//"Aten��o"###"A tabela SQB possui modo de acesso compartilhado. Dessa forma, n�o � necess�rio realizar o cadastro do De x Para"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0006), 1, 0 )
	Return .F.
EndIf

DEFINE MsDialog oDlgPrinc Title OemToAnsi(STR0007) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel//"De x Para de Departamentos"

	oTela     := FWFormContainer():New( oDlgPrinc )
	cIdBrowse := oTela:CreateHorizontalBox( 50 )
	cIdGrid   := oTela:CreateHorizontalBox( 50 )

	oTela:Activate( oDlgPrinc, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdBrowse )
	oPanelDown  := oTela:GeTPanel( cIdGrid )

	oBrowseREN 	:= FWMBrowse():New()
	oBrowseREN:SetOwner( oPanelUp )
	oBrowseREN:SetAlias( "REN" )
	oBrowseREN:SetDescription( OemToAnsi( STR0007 ) )//"De x Para de Departamentos"
	oBrowseREN:DisableDetails()
	oBrowseREN:ForceQuitButton()
	oBrowseREN:SetFilterDefault( "REN_TIPO == '3'" )
	oBrowseREN:Activate()

	oBrowseRET	:= FWMBrowse():New()
	oBrowseRET:SetOwner( oPanelDown )
	oBrowseRET:SetDescription( OemToAnsi( STR0008 ) )//"Departamentos vinculados"
	oBrowseRET:DisableDetails()
	oBrowseRET:SetAlias( "RET" )
	oBrowseRET:SetCacheView( .F. )
	oBrowseRET:SetSeek( .F. )
	oBrowseRET:ExecuteFilter( .F. )
	oBrowseRET:SetUseFilter( .F. )
	oBrowseRET:SetMenuDef( "" )

	oRelacRET:= FWBrwRelation():New()
	oRelacRET:AddRelation( oBrowseREN, oBrowseRET, { { 'RET->RET_FILIAL', 'REN->REN_FILIAL' }, { 'RET->RET_TIPO', 'REN->REN_TIPO' }, { 'RET->RET_CODIGO', 'REN->REN_CODIGO' } } )

	oRelacRET:Activate()
	oBrowseRET:Activate()
	oBrowseREN:Refresh()
	oBrowseRET:Refresh()

ACTIVATE MsDialog oDlgPrinc Center

Return

/*/{Protheus.doc} ModelDef
Defini��o e detalhamento do Model
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function ModelDef()

Local bCommit		:= { |oMdl| GPEA944CGrv( oMdl ) }
Local bValid		:= { |oMdl| Gpea944CVld( oMdl ) }
Local oModel
Local oStructREN
Local oStructRET

// Criacao do Objeto de Modelagem de dados da tabela RET //
oModel	:= MPFormModel():New( "GPEA944C", NIL, bValid , bCommit )
oModel:SetDescription( OemToAnsi( STR0007 ) )//"De x Para de Departamentos"

oStructREN := FWFormStruct( 1, "REN" )
oStructREN:SetProperty( "REN_TIPO", MODEL_FIELD_INIT, { || "3" } )

oStructRET := FWFormStruct(1, "RET")
oStructRET:AddField( 	" "			       , ;              // [01] Titulo do campo "Periodo"
						""       		   , ;              // [02] ToolTip do campo
						"RET_OK"	       , ;              // [03] Id do Field
						"L"           	   , ;              // [04] Tipo do campo
						1		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						{ |oMdl| fVldMark_Ok(oMdl) } , ;  	// [07] Code-block de valida��o do campo
						{ |oMdl| fWhenOK(oMdl) } , ;   		// [08] Code-block de valida��o When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigat�rio
						{|| .T.}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo n�o pode receber valor em uma opera��o de update.
						.T.)          		           		// [14] Indica se o campo � virtual	
oStructRET:AddField( 	STR0009			   , ;           	// [01] Titulo do campo "Descri��o"
						STR0010			   , ;	            // [02] ToolTip do campo
						"RET_DESC"	       , ;              // [03] Id do Field
						"C"           	   , ;              // [04] Tipo do campo
						100		           , ;              // [05] Tamanho do campo
						0         		   , ;              // [06] Decimal do campo
						 				   , ;  			// [07] Code-block de valida��o do campo
										   , ;      		// [08] Code-block de valida��o When do campo
										   , ;              // [09] Lista de valores permitido do campo
						.F.                , ;              // [10] Indica se o campo tem preenchimento obrigat�rio
						{ || fDesc("SQB", RET->RET_CODCAD, "QB_DESCRIC", NIL, RET->RET_FILCAD)}		   , ;              // [11] Code-block de inicializacao do campo
						NIL                , ;              // [12] Indica se trata-se de um campo chave
						Nil                , ;              // [13] Indica se o campo n�o pode receber valor em uma opera��o de update.
						.T.)          		           		// [14] Indica se o campo � virtual	

oModel:AddFields( "GPEA944C_REN", NIL, oStructREN )
oModel:GetModel( "GPEA944C_REN" ):SetDescription( OemToAnsi ( STR0007 ) )//"De x Para de Departamentos
oModel:SetPrimaryKey({""})
oModel:AddGrid( "GPEA944C_RET", "GPEA944C_REN", oStructRET, /*bLinePre*/, /* bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:GetModel( "GPEA944C_RET" ):SetOptional( .T. )
oModel:GetModel( "GPEA944C_RET" ):SetNoInsertLine( .T. )
oModel:GetModel( "GPEA944C_RET" ):SetNoDeleteLine( .T. )
oModel:SetRelation( "GPEA944C_RET", { { "RET_FILIAL", "REN_FILIAL" }, { "RET_TIPO", "REN_TIPO" }, { "RET_CODIGO", "REN_CODIGO "} }, RET->( IndexKey(1) ) )

Return( oModel )

/*/{Protheus.doc} ViewDef
Defini��o da View
@author Allyson Luiz Mesashi
@since 22/03/2022
/*/
Static Function ViewDef()

Local oModel
Local oStructREN
Local oStructRET
Local oView

DEFAULT cMVPEM      := SuperGetMv( 'MV_APIPEM1', Nil, "" )
DEFAULT cMVFeedz    := SuperGetMv( 'MV_APIFEE1', Nil, "" )

oView := FWFormView():New()
oView:SetDescription( STR0007 )//"De x Para de Departamentos

oModel := FWLoadModel( "GPEA944C" )
oStructREN := FWFormStruct( 2, "REN" )
oStructREN:RemoveField( "REN_TIPO")

oStructRET := FWFormStruct( 2, "RET" )
oStructRET:SetProperty( "RET_FILCAD", MVC_VIEW_TITULO, STR0021 )//"Fil. Departamento"
oStructRET:SetProperty( "RET_CODCAD", MVC_VIEW_TITULO, STR0022 )//"C�d. Departamento"
oStructRET:RemoveField( "RET_TIPO" )
oStructRET:RemoveField( "RET_CODIGO" )
oStructRET:AddField( 	"RET_OK"              	, ;              // [01] Campo
						"01"  					, ;              // [02] Ordem
						" "                		, ;              // [03] Titulo
						"Ok"                	, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"L"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.T.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual
oStructRET:AddField( 	"RET_DESC"             	, ;              // [01] Campo
						"10"  					, ;              // [02] Ordem
						STR0009       			, ;              // [03] Titulo
						STR0009            		, ;              // [04] Descricao
						NIL              		, ;              // [05] Help
						"C"                		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
								                , ;              // [07] Picture
												, ;              // [08] PictVar
												, ;              // [09] F3
						.F.  		            , ;              // [10] Editavel
												, ;              // [11] Folder
						""                		, ;              // [12] Group
												, ;              // [13] Lista Combo
												, ;              // [14] Tam Max Combo
												, ;              // [15] Inic. Browse
						.T.)                                     // [16] Virtual 

oView:SetModel( oModel )
oView:AddField( "GPEA944C_REN", oStructREN )

oView:CreateHorizontalBox( "FIELDS", 30 )
oView:CreateHorizontalBox( "GRID", 70 )

oView:AddGrid( "GPEA944C_RET", oStructRET )

oView:addUserButton( STR0011 + " (F7)", "MAGIC_BMP", { |oModel| LoadDeptos(oModel) }, STR0011, VK_F7, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } )//"Vincular departamentos"

oView:SetOwnerView( "GPEA944C_REN", "FIELDS" )
oView:SetOwnerView( "GPEA944C_RET", "GRID" )

oView:EnableTitleView( "GPEA944C_REN", Iif( Empty(cMVFeedz), STR0023, STR0026) )//"Cadastro P&M"##"Cadastro Feedz"
oView:EnableTitleView( "GPEA944C_RET", STR0024 )//"Departamentos vinculados"

Return oView

/*/{Protheus.doc} GPEA944CGrv
Efetua grava��o do modelo de dados
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function GPEA944CGrv( oModel )

Local lRet			:= .T.
Local nCont
Local nOperation 	:= oModel:GetOperation()
Local nTam
Local oGrid

Begin Transaction 

	If nOperation == 3 .Or. nOperation == 4
		oGrid := oModel:GetModel( "GPEA944C_RET" )
		oModel:GetModel( "GPEA944C_RET" ):SetNoDeleteLine( .F. )
		nTam  := oGrid:Length()
		For nCont := 1 to nTam
			oGrid:GoLine( nCont )
			If !oGrid:GetValue( "RET_OK" ) .Or. Empty( oGrid:GetValue( "RET_CODCAD" ) )
				oGrid:DeleteLine()
			EndIf
		Next nCont
		oModel:GetModel( "GPEA944C_RET" ):SetNoDeleteLine( .T. )
	EndIf

	lRet := FWFormCommit( oModel )

End Transaction

Return lRet

/*/{Protheus.doc} GPEA944CVld
Efetua valida��o do modelo de dados
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function GPEA944CVld( oModel )

Local aAreaRET		:= RET->( GetArea() )
Local cCods			:= ""
Local lRet			:= .T.
Local nCont			:= 1
Local nOperation 	:= oModel:GetOperation()
Local oGrid

RET->( dbSetOrder(2) )

If nOperation == 3 .Or. nOperation == 4
	oGrid := oModel:GetModel( "GPEA944C_RET" )
	For nCont := 1 to oGrid:Length()
		oGrid:GoLine( nCont )
		If oGrid:GetValue( "RET_OK" ) .And. !oGrid:IsDeleted()
			If RET->( dbSeek( xFilial( "RET" )+"3"+oGrid:GetValue( "RET_FILCAD" )+oGrid:GetValue( "RET_CODCAD" ) ) )
				While !RET->( EoF() ) .And. RET->RET_FILIAL+RET->RET_TIPO+RET->RET_FILCAD+RET->RET_CODCAD == xFilial( "RET" )+"3"+oGrid:GetValue( "RET_FILCAD" )+oGrid:GetValue( "RET_CODCAD" )
					If RET->RET_CODIGO != oGrid:GetValue( "RET_CODIGO" )
						lRet 	:= .F.
						cCods	+= oGrid:GetValue( "RET_FILCAD" )+oGrid:GetValue( "RET_CODCAD" ) + "/"
						Exit
					EndIf
					RET->( dbSkip() )
				End
			EndIf
		EndIf
	Next nCont
EndIf

If !lRet
	//"Aten��o"###"O(s) departamento(s) de c�digo(s) abaixo j� foi(ram) vinculados a outro cadastro:"
	Help( " ", 1, OemToAnsi(STR0001), Nil, OemToAnsi(STR0025) + CRLF + cCods, 1, 0 )
EndIf

RestArea(aAreaRET)

Return lRet

/*/{Protheus.doc} fVldMark_Ok
Confirma desassocia��o do departamento
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function fVldMark_Ok(oModel)

If !M->RET_OK .And. !MsgYesNo( STR0020, STR0001)//"Desvincular o departamento?"###"Aten��o"
	oModel:LoadValue( "RET_OK", .T. )
EndIf

Return .T.

/*/{Protheus.doc} fWhenOK
Habilita o campo para sele��o do departamento apenas se a coluna estiver preenchida
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function fWhenOK(oGrid)

Local lRET 	:= .T.

If Empty(oGrid:GetValue("RET_CODCAD"))
	lRET := .F.
EndIf

Return lRET

/*/{Protheus.doc} LoadDeptos
Seleciona os departamentos que ser�o vinculados
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function LoadDeptos(oModel)

Local aArea 		:= GetArea()
Local aColumns		:= {}
Local aLstIndices	:= {}
Local aPesq			:= {}
Local aStru  		:= {}
Local cDeptos   	:= ""
Local cFilRET		:= xFilial("RET", REN->REN_FILIAL)
Local cIdGrid		:= ""
Local lInclui
Local nCont 		:= 0
Local nOpcX			:= 0
Local oDlgGrid
Local oFont
Local oGrid			:= oModel:GetModel("GPEA944C_RET")
Local oGroup
Local oMark
Local oPanel
Local oSize
Local oTela

Private cAliasTRB

Static cAliasRET
Static oArqRET

For nCont := 1 to oGrid:Length()
	oGrid:GoLine( nCont )
	If oGrid:GetValue( "RET_OK" )
		cDeptos += oGrid:GetValue( "RET_FILCAD" ) + oGrid:GetValue( "RET_CODCAD" ) + "#"
	EndIf
Next nCont

If oArqRET == Nil
	aAdd( aStru, { "OK"		, "C", 2				, 0 } )
	aAdd( aStru, { "FILIAL"	, "C", FwGetTamFilial	, 0 } )
	aAdd( aStru, { "CODIGO" , "C", 20				, 0 } )
	aAdd( aStru, { "NOME"  	, "C", 100				, 0 } )
	
	aAdd( aLstIndices, { "FILIAL", "CODIGO" } )
	aAdd( aLstIndices, { "NOME" } )

	cAliasRET := cAliasTRB := GetNextAlias()

	oArqRET := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	DbSelectArea("SQB")
	DbSetOrder(1)

	SQB->( dbGoTop() )

	While SQB->( !Eof() )
		If RecLock(cAliasTRB, .T.)
			(cAliasTRB)->FILIAL	:= SQB->QB_FILIAL
			(cAliasTRB)->CODIGO	:= SQB->QB_DEPTO
			(cAliasTRB)->NOME	:= SQB->QB_DESCRIC
			(cAliasTRB)->( MsUnlock() )
		EndIf
		SQB->( dbSkip() )
	EndDo
Else 
	cAliasTRB := cAliasRET
EndIf

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTRB)->FILIAL }") )
aColumns[Len(aColumns)]:SetTitle( STR0012 )//"Filial"
aColumns[Len(aColumns)]:SetSize( FwGetTamFilial )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTRB)->CODIGO }") )
aColumns[Len(aColumns)]:SetTitle( STR0013 )//"C�digo"
aColumns[Len(aColumns)]:SetSize( 2 )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aColumns, FWBrwColumn():New() )
aColumns[Len(aColumns)]:SetData( &("{ || (cAliasTRB)->NOME }") )
aColumns[Len(aColumns)]:SetTitle( STR0009 )//"Descri��o"
aColumns[Len(aColumns)]:SetSize( 40 )
aColumns[Len(aColumns)]:SetDecimal( 0 )
aColumns[Len(aColumns)]:SetPicture( "@!" )

aAdd( aPesq , {	STR0013, { { "CODIGO"	, "C", 20 , 0, "CODIGO", "@!" } }, 1 } )//"C�digo"
aAdd( aPesq , {	STR0009, { { "NOME"  	, "C", 100, 0, "NOME"  , "@!" } }, 1 } )//"Descri��o"

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO", (oSize:aWindSize[3]*1.1), (oSize:aWindSize[3]*0.4), .F., .F. )
oSize:aMargins 	:= { 0, 0, 0, 0 }
oSize:lProp 	:= .F. 		
oSize:Process()

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( STR0014 ) From 0,0 TO 600,1230 OF oMainWnd PIXEL//"Selecione os departamentos que ser�o vinculados"

oTela		:= FWFormContainer():New( oDlgGrid )
cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

oTela:Activate( oDlgGrid, .F. )

oPanel	:= oTela:GeTPanel( cIdGrid )

@ oSize:GetDimension( "CABECALHO", "LININI" )+1 , oSize:GetDimension( "CABECALHO", "COLINI" )+4 GROUP oGroup To oSize:GetDimension( "CABECALHO", "LINEND" ) * 0.090, oSize:GetDimension( "CABECALHO", "COLEND" ) * 0.431  OF oDlgGrid PIXEL
oGroup:oFont := oFont
@ oSize:GetDimension( "CABECALHO", "LININI" )+9 , oSize:GetDimension( "CABECALHO", "COLINI ")+6 SAY "" Of oDlgGrid Pixel

oMark := FWMarkBrowse():New()

oMark:SetOwner( oPanel )
oMark:SetAlias( cAliasTRB )
oMark:SetTemporary( .T.)
oMark:SetColumns( aColumns )
oMark:SetFieldMark( "OK" )
oMark:SetFilterDefault( "" )
oMark:SetIgnoreARotina( .T. )
oMark:SetMenuDef( "" )
oMark:SetSeek( .T., aPesq )
oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.) }

oMark:Activate()

SetMarkAll( oMark:Mark(), .F., cAliasTRB, cDeptos)

oMark:Refresh(.T.)

ACTIVATE MSDIALOG oDlgGrid CENTERED ON INIT EnchoiceBar( oDlgGrid, { ||nOpcX := 1, oDlgGrid:End() } ,{ || oDlgGrid:End() }, NIL, {} )

If nOpcX == 1
	(cAliasTRB)->(dbGoTop())

	lInclui := !Empty(cDeptos)

	If lInclui
		For nCont := 1 to oGrid:Length()
			oGrid:GoLine( nCont )
			oGrid:LoadValue( "RET_OK", .F. )
		Next nCont
	Else 
		oGrid:GoLine(1)
	EndIf

	While (cAliasTRB)->( !EoF() )
		If !Empty((cAliasTRB)->OK)			
			If lInclui
				If !oGrid:SeekLine( { { "RET_FILCAD", (cAliasTRB)->FILIAL }, { "RET_CODCAD", (cAliasTRB)->CODIGO } } )
					oGrid:AddLine( .T. )
				EndIf
			EndIf

			oGrid:LoadValue( "RET_FILIAL", cFilRET )
			oGrid:LoadValue( "RET_TIPO", "3" )
			oGrid:LoadValue( "RET_FILCAD", (cAliasTRB)->FILIAL )
			oGrid:LoadValue( "RET_CODCAD", (cAliasTRB)->CODIGO )
			oGrid:LoadValue( "RET_DESC", (cAliasTRB)->NOME )
			oGrid:LoadValue( "RET_OK", .T. )

			lInclui := .T.
		EndIf
		(cAliasTRB)->( dbSkip() )
	EndDo

	oGrid:GoLine(1)
EndIf

RestArea(aArea)

Return Nil

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca os registros
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function SetMarkAll(cMarca, lMarcar, cAliasTRB, cMarcados)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

Default cMarca := ""

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	If RecLock( (cAliasMark), .F. )
		If !Empty(cMarcados)
			If (cAliasMark)->FILIAL + (cAliasMark)->CODIGO $ cMarcados 
				(cAliasMark)->OK := cMarca
			Else 
				(cAliasMark)->OK := '  '
			EndIf
		Else
			(cAliasMark)->OK := IIf( lMarcar, cMarca, '  ' )
		EndIf
		MsUnLock()
	EndIf
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.

/*/{Protheus.doc} MenuDef
Defini��o do Menu
@author Allyson Luiz Mesashi
@since 23/05/2022
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0015)  Action 'PesqBrw'            OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0016)  Action 'VIEWDEF.GPEA944C'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0017)  Action 'VIEWDEF.GPEA944C'   OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0018)  Action 'VIEWDEF.GPEA944C'   OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0019)  Action 'VIEWDEF.GPEA944C'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina
