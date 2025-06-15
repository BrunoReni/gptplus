#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "JURA310.CH"

PUBLISH MODEL REST NAME JURA310 SOURCE JURA310 RESOURCE OBJECT JurModRest

//--------------------------------------------------------------------
/*/{Protheus.doc} JURA310
Rotina de Pedidos - TOTVS Jur�dico Departamentos

@since 15/02/2023
/*/
//-------------------------------------------------------------------
Function JURA310()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) // Pedidos
	oBrowse:SetAlias( "O0W" )
	oBrowse:SetMenuDef( "JURA310" )
	oBrowse:SetLocate()
	oBrowse:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { STR0002 , "VIEWDEF.JURA310", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0003 , "VIEWDEF.JURA310", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0004 , "VIEWDEF.JURA310", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005 , "VIEWDEF.JURA310", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Pedidos

@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := Nil
Local oStructO0W := Nil
Local oStructNSY := Nil
Local cFldsNSY   := 'NSY_FILIAL|NSY_CAJURI|NSY_COD|NSY_CPEVLR|NSY_DPEVLR|'+;//Detalhe
					'NSY_CPROG|NSY_DPROG|NSY_CINSTA|NSY_PEINVL|'+;
					'NSY_CCOMON|NSY_PEDATA|NSY_DTJURO|NSY_CMOPED|NSY_PEVLR|' +; //Objeto
					'NSY_DTMULT|NSY_PERMUL|NSY_TOPEAT|'+;
					'NSY_CFCORC|NSY_DTCONT|NSY_DTJURC|NSY_INECON|NSY_CMOCON|'+; //Conting�ncia
					'NSY_DTMULC|NSY_PERMUC|NSY_VLCONT|NSY_CCORPC|NSY_CJURPC|'+;
					'NSY_PEVLRA|NSY_MULATU|NSY_CJURPE|NSY_TOPEAT|NSY_CCORPE|'+;
					'NSY_MULATC|NSY_VLCONA|NSY_TOTATC|'+;
					'NSY_CFCOR1|NSY_V1DATA|NSY_DTJUR1|NSY_CMOIN1|NSY_DTMUL1|NSY_PERMU1|'+; //1� inst�ncia
					'NSY_V1INVL|NSY_V1VLR|NSY_CCORP1|NSY_CJURP1|NSY_MULAT1|NSY_V1VLRA|'+;
					'NSY_CFCOR2|NSY_V2DATA|NSY_CMOIN2|NSY_DTMUL2|NSY_PERMU2|'+; //2� inst�ncia
					'NSY_CFMUL2|NSY_CMOEM2|NSY_VLRMU2|NSY_DTMUT2|NSY_DTINC2|'+;
					'NSY_CCORP2|NSY_CJURP2|NSY_MULAT2|NSY_V2VLRA|NSY_CCORM2|'+;
					'NSY_CJURM2|NSY_MUATU2|NSY_V2INVL|NSY_DTJUR2|NSY_V2VLR|' +;
					'NSY_CFCORT|NSY_TRDATA|NSY_CMOTRI|NSY_DTMUTR|NSY_PERMUT|'+; //Tribunal
					'NSY_CFMULT|NSY_CMOEMT|NSY_VLRMT|NSY_DTMUTT|NSY_DTINCT|'+;
					'NSY_CCORPT|NSY_CJURPT|NSY_VLRMUT|NSY_TRVLRA|'+;
					'NSY_CCORMT|NSY_CJURMT|NSY_MUATT|NSY_TRINVL|'+;
					'NSY_DTJURT|NSY_TRVLR|NSY_CVERBA|NSY_REDUT|' //Outros

	oStructO0W := FWFormStruct( 1, "O0W" )
	oStructNSY := FWFormStruct( 1, "NSY", {|x| AllTrim(x) +'|' $ cFldsNSY },,.F. )

	// Inclui as valida��es nos campos. N�o est� no Dicion�rio pois usa elementos do Modelo
	oStructO0W:SetProperty("O0W_CTPPED",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| ExistCpo("NSP", FwFldGet("O0W_CTPPED"),1).AND.JCallJ310(oModel,cField,nValAtu)})
	oStructO0W:SetProperty("O0W_DATPED",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	oStructO0W:SetProperty("O0W_DTJURO",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	oStructO0W:SetProperty("O0W_DTMULT",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	oStructO0W:SetProperty("O0W_PERMUL",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	oStructO0W:SetProperty("O0W_CFRCOR",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	oStructO0W:SetProperty("O0W_VPEDID",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu), JUpdPrgO0W(oModel,oModelAtu)})
	oStructO0W:SetProperty("O0W_VPROVA",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu), JUpdPrgO0W(oModel,oModelAtu)})
	oStructO0W:SetProperty("O0W_VPOSSI",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu), JUpdPrgO0W(oModel,oModelAtu)})
	oStructO0W:SetProperty("O0W_VREMOT",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu), JUpdPrgO0W(oModel,oModelAtu)})
	oStructO0W:SetProperty("O0W_VINCON",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu), JUpdPrgO0W(oModel,oModelAtu)})

	//-- Campos Valores Tribut�rios
	DbSelectArea("O0W")
	If ColumnPos("O0W_MULTRI") > 0
		oStructO0W:SetProperty("O0W_MULTRI",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	EndIf

	If ColumnPos("O0W_CFCMUL") > 0
		oStructO0W:SetProperty("O0W_CFCMUL",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| (Vazio().OR.ExistCpo("NW7", FwFldGet("O0W_CFCMUL"),1)) .AND. JCallJ310(oModel,cField,nValAtu)})
	EndIf

	If ColumnPos("O0W_PERENC") > 0
		oStructO0W:SetProperty("O0W_PERENC",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	EndIf

	If ColumnPos("O0W_PERHON") > 0
		oStructO0W:SetProperty("O0W_PERHON",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAtu)})
	EndIf

	If ColumnPos("O0W_REDUT") > 0
		oStructO0W:SetProperty("O0W_REDUT",MODEL_FIELD_VALID,{|oModelAtu,cField,nValAtu,nLinha,nValAnt| JCallJ310(oModel,cField,nValAnt)})
	EndIf

	oStructO0W:SetProperty("O0W_VPOSSI", MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty("O0W_VATPED", MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty("O0W_VATPOS", MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty("O0W_VATPRO", MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty("O0W_VATREM", MODEL_FIELD_WHEN, {|| .F.})
	oStructO0W:SetProperty("O0W_VATINC", MODEL_FIELD_WHEN, {|| .F.})

	// Remo��o das Valida��es pois est�o centralizadas nos Modelos padr�o
	oStructNSY:SetProperty("NSY_CPEVLR", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CINSTA", MODEL_FIELD_VALID, {|| .T. })	
	oStructNSY:SetProperty("NSY_CMOCON", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTJURC", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTMULC", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_PERMUC", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CFCOR1", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_V1DATA", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CMOIN1", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTMUL1", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_PERMU1", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CFCOR2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_V2DATA", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CMOIN2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTMUL2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_PERMU2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CFCORT", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_TRDATA", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CMOTRI", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTMUTR", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_PERMUT", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CFMUL2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CFMULT", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CMOEM2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CMOEMT", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_VLRMU2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_VLRMT" , MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTMUT2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTMUTT", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTINC2", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_DTINCT", MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_REDUT" , MODEL_FIELD_VALID, {|| .T. })
	oStructNSY:SetProperty("NSY_CFMUL2", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_CMOEM2", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_VLRMU2", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_DTMUT2", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_DTINC2", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_CFMULT", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_CMOEMT", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_VLRMT" , MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_DTMUTT", MODEL_FIELD_WHEN, {|| .T.})
	oStructNSY:SetProperty("NSY_DTINCT", MODEL_FIELD_WHEN, {|| .T.})

	oStructO0W:RemoveField( "NSY_CAJURI" )
	oStructNSY:RemoveField( "NSY_CVERBA" )

	oModel := MPFormModel():New( "JURA310", /*Pre-Validacao*/, {|oModel| J310TOK(oModel)} /*Pos-Validacao*/, {|oModel| J310Commit(oModel)} /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0001 ) // Pedidos

	// Detalhes de pedidos
	oModel:AddFields( "O0WMASTER", Nil, oStructO0W, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)

	// Grid dos valores
	oModel:AddGrid( "NSYDETAIL", "O0WMASTER", oStructNSY, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NSYDETAIL" ):SetUniqueLine({"NSY_COD"})
	oModel:SetRelation( "NSYDETAIL", { { "NSY_FILIAL", "xFilial('O0W')" }, { "NSY_CVERBA", "O0W_COD"}, { "NSY_CAJURI", "O0W_CAJURI"} }, NSY->( IndexKey( 1 ) ) )
	oModel:GetModel( "NSYDETAIL" ):SetDelAllLine( .F. )
	oModel:GetModel( "NSYDETAIL" ):SetNoInsertLine(.F.)
	oModel:SetOptional( "NSYDETAIL" , .F. )
	oModel:GetModel( "O0WMASTER" ):SetDescription( STR0001 )
	oModel:GetModel( "NSYDETAIL" ):SetDescription( STR0006 )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Pedidos

@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oStructO0W := Nil
Local oStructNSY := Nil
Local oModel  	 := FWLoadModel( "JURA310" )
Local aNSY       := { 'NSY_FILIAL','NSY_CAJURI','NSY_COD'   ,'NSY_DPEVLR','NSY_DPROG' ,;
					'NSY_VLCONT','NSY_VLCONA','NSY_DTJURC','NSY_DTMULC','NSY_PERMUC',;
					'NSY_CFCOR1','NSY_V1VLR' ,'NSY_CCORP1','NSY_CJURP1','NSY_MULAT1',; //1� inst�ncia
					'NSY_V1VLRA',;
					'NSY_CFCOR2','NSY_V2VLR' ,'NSY_CCORP2','NSY_CJURP2','NSY_MULAT2',; //2� inst�ncia
					'NSY_V2VLRA','NSY_CFMUL2','NSY_VLRMU2','NSY_CCORM2','NSY_CJURM2',;
					'NSY_MUATU2',;
					'NSY_CFCORT','NSY_TRVLR' ,'NSY_CCORPT','NSY_CJURPT','NSY_VLRMUT',; //Tribunal
					'NSY_TRVLRA','NSY_VLRMT' ,'NSY_CCORMT','NSY_CJURMT','NSY_MUATT' }

	oStructO0W := FWFormStruct( 2, "O0W" )
	oStructNSY := FWFormStruct( 2, "NSY", {|x| aScan(aNSY,AllTrim(x))> 0 } )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "O0WMASTER" , oStructO0W, "O0WMASTER" )
	oView:AddGrid(  "NSYDETAIL" , oStructNSY, "NSYDETAIL" )

	oView:CreateHorizontalBox( "FORMFIELD", 50 )
	oView:CreateHorizontalBox( "GRIDOBJET", 50 )

	oView:SetOwnerView( "O0WMASTER", "FORMFIELD" )
	oView:SetOwnerView( "NSYDETAIL", "GRIDOBJET" )
	oView:SetUseCursor( .T. )
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} JCallJ310
Criar e atualizar o NSYDETAIL com os dados inputados na O0W

@Param  oModel   - Modelo atual
@Param  cField   - Nome do Campo Alterado
@Param  nValAtu  - VAlor atual
@Return lRet     - Indica se setou os valores corretamente
@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function JCallJ310(oModel, cField, nValAtu)
Local oModelO0W  := oModel:GetModel("O0WMASTER")
Local oModelNSY  := oModel:GetModel("NSYDETAIL")
Local cTipoPed   := oModelO0W:GetValue("O0W_CTPPED")
Local cCajuri    := oModelO0W:GetValue("O0W_CAJURI")
Local cDatPed    := oModelO0W:GetValue("O0W_DATPED")
Local cInstan    := JurGetDados('NUQ', 2, xFilial('NSZ') + cCajuri + '1',{"NUQ_COD"})
Local aTipProg   := {'1','2','3','4'}
Local cMoeda     := SuperGetMv("MV_JCMOPRO", .F., "01")
Local nValTotPed := 0
Local nValorPed  := 0
Local nI         := 0
Local nLinePoss  := 0
Local nCount     := 0
Local lRet       := .T.
Local lAdicionar := .F.
Local cTipoProg  := ""
Local nGridNsy   := 0
Local lCposTrib  := .F.
Local lAtuRedut  := .F.

	If oModel:GetOperation() <> 5

		// Valida se possui os campos da O0W
		DbSelectArea("O0W")
		lAtuRedut := ColumnPos('O0W_REDUT') > 0    // Valor redutor prov�vel
		lCposTrib := ColumnPos('O0W_MULTRI') > 0 ; // Percentual de multa tribu
			.AND. ColumnPos('O0W_CFCMUL') > 0 ;    // Forma de correcao multa
			.AND. ColumnPos('O0W_PERENC') > 0 ;    // Percentual de encargos
			.AND. ColumnPos('O0W_PERHON') > 0 ;    // Percentual de honorario

		If Empty(cDatPed)
			oModelO0W:SetValue("O0W_DATPED", Date())
			cDatPed := oModelO0W:GetValue("O0W_DATPED")
		EndIf

		// Verifica qual o Tipo de Progn�stico a ser atualizado
		Do Case
			Case (cField == "O0W_VPROVA")
				cTipoProg := "1"
			Case (cField == "O0W_VREMOT")
				cTipoProg := "3"
			Case (cField == "O0W_VINCON")
				cTipoProg := "4"
			OtherWise
				cTipoProg := "0"  // Sem progn�stico
		End Case
		
		nValTotPed := oModelO0W:GetValue("O0W_VPEDID") // Valor de Pedido

		// Verifica se � uma inclus�o de uma nova Verba
		lAdicionar := oModelNSY:Length(.T.) == 1
		oModelNSY:SetNoInsertLine(.F.)

		If lAdicionar
			nCount := Len(aTipProg)
		Else
			nCount := oModelNSY:Length()
		EndIf

		nGridNsy := oModelNSY:GetLine()

		For nI := 1 To nCount
			// Se for a inclus�o, Seta os valores dos objetos
			If lAdicionar

				// Somente ir� jogar o valor no Progn. Possivel, caso contr�rio � Zero
				If aTipProg[nI] == '2'
					nValorPed := nValTotPed
				Else
					nValorPed := 0
				EndIf

				oModelNSY:SetValue("NSY_FILIAL", xFilial("NSY")                  )
				oModelNSY:LoadValue("NSY_CAJURI", cCajuri                        )
				oModelNSY:SetValue("NSY_CPEVLR", cTipoPed                        )
				oModelNSY:SetValue("NSY_CPROG" , J270Progn(aTipProg[nI])[1]      )
				oModelNSY:SetValue("NSY_CINSTA", cInstan                         )
				oModelNSY:SetValue("NSY_INECON", "2"                             )
				oModelNSY:SetValue("NSY_DTCONT", cDatPed                         )
				oModelNSY:SetValue("NSY_VLCONT", nValorPed                       )
				oModelNSY:SetValue("NSY_CMOCON", cMoeda                          )
				oModelNSY:SetValue("NSY_CFCORC", oModelO0W:GetValue("O0W_CFRCOR"))

				// Se ainda houver outro, adiciona uma nova linha
				If nI < Len(aTipProg)
					oModelNSY:AddLine()
				EndIf
				ConfirmSX8()
			Else
				// Caso haja mais de 1 linha, � considerado altera��o.
				oModelNSY:GoLine(nI)
				cCodTipPrg := J270Progn(,oModelNSY:GetValue("NSY_CPROG"))[2]

				If !oModelNSY:IsDeleted()

					If cCodTipPrg == '2'
						// Verifica se o Progn�stico � do tipo "Poss�vel" para ser Atualizado depois
						nLinePoss := nI
					ElseIf cCodTipPrg == cTipoProg
						// Verifica se a linha � do Tipo que est� validando
						oModelNSY:SetValue("NSY_VLCONT", nValAtu)
						If nValAtu == 0
							oModelNSY:LoadValue("NSY_CJURPC", 0)
							oModelNSY:LoadValue("NSY_CCORPC", 0)
							oModelNSY:LoadValue("NSY_VLCONA", 0)
						EndIf

						nValTotPed := nValTotPed - nValAtu
					Else
						nValTotPed := nValTotPed - oModelNSY:GetValue("NSY_VLCONT")
					EndIf
					oModelNSY:LoadValue("NSY_DTCONT",cDatPed)
				EndIf
			EndIf
			If lAtuRedut
				oModelNSY:SetValue("NSY_REDUT" , oModelO0W:GetValue("O0W_REDUT"))
			EndIf
		Next

		// Caso n�o seja a inclus�o, pega o valor calculado e atualiza na linha do Possivel
		If !lAdicionar
			oModelNSY:GoLine(nLinePoss)
			oModelNSY:LoadValue("NSY_PEVLR" , oModelO0W:GetValue("O0W_VPEDID"))
			oModelNSY:SetValue("NSY_CCOMON",  oModelO0W:GetValue("O0W_CFRCOR"))
			oModelNSY:LoadValue("NSY_PEINVL", '2')
			oModelNSY:LoadValue("NSY_CMOPED", cMoeda)
			oModelNSY:LoadValue("NSY_PEDATA", cDatPed)
			oModelNSY:LoadValue("NSY_DTJURO", oModelO0W:GetValue("O0W_DTJURO"))
			oModelNSY:LoadValue("NSY_DTCONT", cDatPed)
			oModelNSY:LoadValue("NSY_VLCONA", nValTotPed)
			lRet := oModelNSY:LoadValue("NSY_VLCONT", nValTotPed)

			// Tratamento necess�rio para quando o valor do pedido � zerado
			If nValTotPed == 0
				oModelNSY:LoadValue("NSY_CJURPC", 0)
				oModelNSY:LoadValue("NSY_CCORPC", 0)
				oModelNSY:LoadValue("NSY_VLCONA", 0)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdPrgO0W
Atualiza os valores dos Campos Virtuais

@param  oModel    - Modelo principal da rotina
@param  oModelLin - Submodelo da linha posicionada
@return .T.
@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function JUpdPrgO0W(oModel, oModelLin)

	If oModelLin == NIL
		oModelLin := oModel:GetModel("O0WMASTER")
	EndIf

	//Seta o prognostico da verba alterada
	oModelLin:SetValue("O0W_PROGNO", GetAvlCaso(oModelLin:GetValue("O0W_VPROVA"),;
		oModelLin:GetValue("O0W_VPOSSI"),;
		oModelLin:GetValue("O0W_VREMOT"),;
		oModelLin:GetValue("O0W_VINCON")))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAvlCaso
Tratamento para calcular o Progn�stico do Caso

@param nValProvav - Valor Provavel
@param nValPossiv - Valor Poss�vel
@param nValRemoto - Valor Remoto
@param nValIncont - Valor Incontroverso
@return cProgno - Progn�stico a ser retornado
@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function GetAvlCaso(nValProvav, nValPossiv, nValRemoto, nValIncont)
Local cProgno := STR0011 //  "Sem Progn�stico"

	Do Case
	Case (nValProvav > 0 )
		cProgno := STR0007   // Prov�vel
	Case (nValPossiv > 0 )
		cProgno := STR0008   // Poss�vel
	Case (nValIncont > 0)
		cProgno := STR0009   // Incontroverso
	Case (nValRemoto > 0)
		cProgno := STR0010   // Remoto
	OtherWise
		cProgno := STR0011   // Sem Progn�stico
	End Case

Return cProgno

//-------------------------------------------------------------------
/*/{Protheus.doc} J310TOK(oModel)
Pr�-valida��o do modelo

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function J310TOK(oModel)
Local lRet         := .F.
Local oModelO0W    := oModel:GetModel("O0WMASTER")
Local nJ310Opc     := oModel:GetOperation()
Local aArea        := GetArea()
Local aAreaO0W     := O0W->(GetArea())
Local cFluig       := SuperGetMV('MV_JFLUIGA',,'2')
Local lFluig       := .F.
Local lTipoAprov   := NQS->( FieldPos('NQS_TAPROV') ) > 0
Local lCodO0W      := O0W->( FieldPos("O0W_CODWF") ) > 0

	// Atualiza os dados na NSY e O0W
	If nJ310Opc <>  5
		J310SetData(oModel)	

		// Valida cadastro de progn�sticos
		If JUpdPrgO0W(oModel)
			lRet := J270vlProg()
		EndIf
	Else
		lRet := .T.
	EndIf

	If lRet		
		If nJ310Opc == 4
			DbSelectArea("O0W")
			O0W->( DbSetOrder(1) )	// O0W_FILIAL + O0W_COD

			// Posiciona na verba
			O0W->(DbSeek( xFilial("O0W") + oModelO0W:GetValue('O0W_COD'), .T. ))
		EndIf		

		If cFluig == '1'
			If lTipoAprov
				// Verifica se o Tipo de aprova��o � 6 - Objeto
				lFluig := !Empty(Posicione("NQS", 3, xFilial("NQS") + "6", "NQS_COD" )) .And. ;
					Posicione("NQS", 3, xFilial("NQS") + "6", "NQS_FLUIG" ) == "1" // NQS_FILIAL + NQS_TAPROV
			Else
				lFluig = .T.
			EndIf                     
		EndIf

		// Aprova��o de Objeto
		If lFluig .And. !IsInCallStack("JA106ConfNZK") .And. lCodO0W
			If !J270FFluig(oModel, oModelO0W, nJ310Opc, .T.)
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaO0W)
	RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} J310SetData(oModel)
Fun��o respons�vel por atualizar os dados nas tabelas NSY e O0W

@param  oModel - Modelo de dados da JURA310
@return .T.
@since 15/02/2023
/*/
//------------------------------------------------------------------------------
Static Function J310SetData(oModel)
Local nI         := 0
Local nGridNsy   := 1
Local oModelO0W  := oModel:GetModel("O0WMASTER")
Local oModelNSY  := oModel:GetModel("NSYDETAIL")
Local cMoeda     := ""
Local nValProvav := 0
Local nValPossiv := 0
Local nValRemoto := 0
Local nValIncont := 0
Local nMulta     := 0
Local nEncargo   := 0
Local nMultaEnc  := 0
Local nHonorario := 0
Local nMultaHon  := 0
Local lCposTrib  := .F.
Local lRedut     := .F.
Local lCposHist  := .F.
Local dDtMulta   := ''
Local dDtJuros   := ''

	// Valida se possui os campos da O0W para valores tribut�rios
	DbSelectArea("O0W")
	If (lCposTrib := ColumnPos('O0W_MULTRI') > 0 ;  // Percentual de multa tribu
		.AND. ColumnPos('O0W_CFCMUL') > 0 ;         // Forma de correcao multa
		.AND. ColumnPos('O0W_PERENC') > 0 ;         // Percentual de encargos
		.AND. ColumnPos('O0W_PERHON') > 0 )         // Percentual de honorario

		cMoeda    := SuperGetMv("MV_JCMOPRO", .F., "01")
	EndIf

	lRedut := ColumnPos('O0W_REDUT') > 0        // Valor redutor prov�vel
	lCposHist := ColumnPos('O0W_VLHIST') > 0 ;  // Valor hist�rico
			.AND. ColumnPos('O0W_DTHIST') > 0 ; // Data do valor hist�rico
			.AND. ColumnPos('O0W_FCHIST') > 0 ; // Forma de corre��o valor hist�rico
			.AND. ColumnPos('O0W_VRDHIS') > 0   // Valor redutor do hist�rico


	nGridNsy := oModelNSY:GetLine()

	If !Empty(oModelO0W:GetValue("O0W_DTMULT")) 
		dDtMulta := oModelO0W:GetValue("O0W_DTMULT")
	Else 
		dDtMulta := oModelO0W:GetValue("O0W_DATPED")
	EndIf

	If !Empty(oModelO0W:GetValue("O0W_DTJURO")) 
		dDtJuros :=  oModelO0W:GetValue("O0W_DTJURO")
	Else 
		dDtJuros := oModelO0W:GetValue("O0W_DATPED")
	EndIf

	For nI := 1 To oModelNSY:Length()

		oModelNSY:GoLine(nI)
		If !oModelNSY:IsDeleted()
			cCodTipPrg := J270Progn(,oModelNSY:GetValue("NSY_CPROG"))[2]

			Do Case
				Case cCodTipPrg == "1"    // Prov�vel
					nValProvav :=  oModelNSY:GetValue("NSY_VLCONT")
				Case cCodTipPrg == "2"    // Poss�vel
					nValPossiv :=  oModelNSY:GetValue("NSY_VLCONT")
				Case cCodTipPrg == "3"    // Remoto
					nValRemoto :=  oModelNSY:GetValue("NSY_VLCONT")
				Case cCodTipPrg == "4"    // Incontroverso
					nValIncont :=  oModelNSY:GetValue("NSY_VLCONT")
			End Case

			oModelNSY:SetValue("NSY_CPEVLR" , oModelO0W:GetValue("O0W_CTPPED"))
			oModelNSY:SetValue("NSY_CFCORC" , oModelO0W:GetValue("O0W_CFRCOR"))
			oModelNSY:SetValue("NSY_DTJURC" , oModelO0W:GetValue("O0W_DTJURO"))
			oModelNSY:LoadValue("NSY_DTMULC", oModelO0W:GetValue("O0W_DTMULT"))
			oModelNSY:LoadValue("NSY_PERMUC", oModelO0W:GetValue("O0W_PERMUL"))

			// Valida se possui os campos da O0W para valores tribut�rios, para atualizar os campos necessarios da NSY
			If lCposTrib
				If oModelO0W:isFieldUpdate("O0W_CFCMUL")//se alterar o campo de forma de corre��o, limpa os totalizadores da nsy
					oModelNSY:ClearField("NSY_CCORP1")
					oModelNSY:ClearField("NSY_CJURP1")
					oModelNSY:ClearField("NSY_MULAT1")
					oModelNSY:ClearField("NSY_V1VLRA")
				EndIf

				If Empty(oModelO0W:GetValue("O0W_MULTRI"))
					oModelNSY:ClearField("NSY_CFCOR1")
					oModelNSY:ClearField("NSY_V1DATA")
					oModelNSY:ClearField("NSY_DTJUR1")
					oModelNSY:ClearField("NSY_CMOIN1")
					oModelNSY:ClearField("NSY_DTMUL1")
					oModelNSY:ClearField("NSY_PERMU1")
					oModelNSY:ClearField("NSY_CCORP1")
					oModelNSY:ClearField("NSY_CJURP1")
					oModelNSY:ClearField("NSY_MULAT1")
					oModelNSY:ClearField("NSY_V1VLRA")
					oModelNSY:ClearField("NSY_V1VLR")
				Else
					//1� inst�ncia
					oModelNSY:SetValue("NSY_CFCOR1", oModelO0W:GetValue("O0W_CFCMUL"))
					oModelNSY:SetValue("NSY_V1DATA", oModelO0W:GetValue("O0W_DATPED"))
					oModelNSY:SetValue("NSY_DTJUR1", dDtJuros)
					oModelNSY:SetValue("NSY_CMOIN1", cMoeda)
					If JA094VlMult(oModelNSY:GetValue('NSY_CFCOR1'))
						oModelNSY:SetValue("NSY_DTMUL1", dDtMulta)
						oModelNSY:SetValue("NSY_PERMU1", "0")
					EndIf

					nMulta := oModelNSY:GetValue("NSY_VLCONT") * oModelO0W:GetValue("O0W_MULTRI")/100

					oModelNSY:LoadValue("NSY_V1VLR", nMulta)

					// Limpa os valores valores preenchidos pela corre��o
					oModelNSY:ClearField("NSY_CCORP1", nMulta)
					oModelNSY:ClearField("NSY_CJURP1", nMulta)
					oModelNSY:ClearField("NSY_MULAT1", nMulta)
					oModelNSY:ClearField("NSY_V1VLRA", nMulta)

				EndIf
				//2� instancia
				If Empty(oModelO0W:GetValue("O0W_PERENC"))
					oModelNSY:ClearField("NSY_CFCOR2")
					oModelNSY:ClearField("NSY_V2DATA")
					oModelNSY:ClearField("NSY_DTJUR2")
					oModelNSY:ClearField("NSY_CMOIN2")
					oModelNSY:ClearField("NSY_DTMUL2")
					oModelNSY:ClearField("NSY_PERMU2")
					oModelNSY:ClearField("NSY_V2VLR")
					oModelNSY:ClearField("NSY_CCORP2")
					oModelNSY:ClearField("NSY_CJURP2")
					oModelNSY:ClearField("NSY_MULAT2")
					oModelNSY:ClearField("NSY_V2VLRA")
					oModelNSY:ClearField("NSY_CFMUL2")
					oModelNSY:ClearField("NSY_DTMUT2")
					oModelNSY:ClearField("NSY_DTINC2")
					oModelNSY:ClearField("NSY_CMOEM2")
					oModelNSY:ClearField("NSY_VLRMU2")
					oModelNSY:ClearField("NSY_CCORM2")
					oModelNSY:ClearField("NSY_CJURM2")
					oModelNSY:ClearField("NSY_MUATU2")
				Else
					oModelNSY:SetValue("NSY_CFCOR2", oModelO0W:GetValue("O0W_CFRCOR"))
					oModelNSY:SetValue("NSY_V2DATA", oModelO0W:GetValue("O0W_DATPED"))
					oModelNSY:SetValue("NSY_DTJUR2", dDtJuros)
					oModelNSY:SetValue("NSY_CMOIN2", cMoeda)
					If JA094VlMult(oModelNSY:GetValue('NSY_CFCOR2'))
						oModelNSY:SetValue("NSY_DTMUL2", dDtMulta)
						oModelNSY:SetValue("NSY_PERMU2", "0")
					EndIf

					nEncargo := oModelNSY:GetValue("NSY_VLCONT") * oModelO0W:GetValue("O0W_PERENC")/100

					oModelNSY:SetValue("NSY_V2VLR", nEncargo)

					// Limpa os valores valores preenchidos pela corre��o
					oModelNSY:ClearField("NSY_CCORP2", nEncargo)
					oModelNSY:ClearField("NSY_CJURP2", nEncargo)
					oModelNSY:ClearField("NSY_MULAT2", nEncargo)
					oModelNSY:ClearField("NSY_V2VLRA", nEncargo)

					oModelNSY:SetValue("NSY_CFMUL2", oModelO0W:GetValue("O0W_CFCMUL"))
					oModelNSY:SetValue("NSY_DTMUT2", oModelO0W:GetValue("O0W_DATPED"))//Data Multa
					oModelNSY:SetValue("NSY_DTINC2", oModelO0W:GetValue("O0W_DATPED"))//Data Incidencia
					oModelNSY:SetValue("NSY_CMOEM2", cMoeda)

					nMultaEnc := oModelNSY:GetValue("NSY_V1VLR") * oModelO0W:GetValue("O0W_PERENC")/100

					oModelNSY:SetValue("NSY_VLRMU2", nMultaEnc)

					// Limpa os valores valores preenchidos pela corre��o
					oModelNSY:ClearField("NSY_CCORM2", nMultaEnc)
					oModelNSY:ClearField("NSY_CJURM2", nMultaEnc)
					oModelNSY:ClearField("NSY_MUATU2", nMultaEnc)
				EndIf
				//Tribunal Superior
				If Empty(oModelO0W:GetValue("O0W_PERHON"))
					oModelNSY:ClearField("NSY_CFCORT")
					oModelNSY:ClearField("NSY_TRDATA")
					oModelNSY:ClearField("NSY_DTJURT")
					oModelNSY:ClearField("NSY_CMOTRI")
					oModelNSY:ClearField("NSY_DTMUTR")
					oModelNSY:ClearField("NSY_PERMUT")
					oModelNSY:ClearField("NSY_TRVLR")
					oModelNSY:ClearField("NSY_CCORPT")
					oModelNSY:ClearField("NSY_CJURPT")
					oModelNSY:ClearField("NSY_VLRMUT")
					oModelNSY:ClearField("NSY_TRVLRA")
					oModelNSY:ClearField("NSY_CFMULT")
					oModelNSY:ClearField("NSY_DTMUTT")
					oModelNSY:ClearField("NSY_DTINCT")
					oModelNSY:ClearField("NSY_CMOEMT")
					oModelNSY:ClearField("NSY_VLRMT")
					oModelNSY:ClearField("NSY_CCORMT")
					oModelNSY:ClearField("NSY_CJURMT")
					oModelNSY:ClearField("NSY_MUATT")
				Else
					oModelNSY:SetValue("NSY_CFCORT", oModelO0W:GetValue("O0W_CFRCOR"))
					oModelNSY:SetValue("NSY_TRDATA", oModelO0W:GetValue("O0W_DATPED"))
					oModelNSY:SetValue("NSY_DTJURT", dDtJuros)
					
					oModelNSY:SetValue("NSY_CMOTRI", cMoeda)
					If JA094VlMult(oModelNSY:GetValue('NSY_CFCORT'))
						oModelNSY:SetValue("NSY_DTMUTR", dDtMulta)
						oModelNSY:SetValue("NSY_PERMUT", "0")
					EndIf

					nHonorario := oModelNSY:GetValue("NSY_VLCONT") * oModelO0W:GetValue("O0W_PERHON")/100

					oModelNSY:SetValue("NSY_TRVLR", nHonorario)

					// Limpa os valores valores preenchidos pela corre��o
					oModelNSY:ClearField("NSY_CCORPT", nHonorario)
					oModelNSY:ClearField("NSY_CJURPT", nHonorario)
					oModelNSY:ClearField("NSY_VLRMUT", nHonorario)
					oModelNSY:ClearField("NSY_TRVLRA", nHonorario)

					oModelNSY:SetValue("NSY_CFMULT", oModelO0W:GetValue("O0W_CFCMUL"))
					oModelNSY:SetValue("NSY_DTMUTT", oModelO0W:GetValue("O0W_DATPED"))//Data Multa
					oModelNSY:SetValue("NSY_DTINCT", oModelO0W:GetValue("O0W_DATPED"))//Data Incidencia
					oModelNSY:SetValue("NSY_CMOEMT", cMoeda)
					nMultaHon := oModelNSY:GetValue("NSY_V1VLR") * oModelO0W:GetValue("O0W_PERHON")/100
					oModelNSY:SetValue("NSY_VLRMT" , nMultaHon)

					// Limpa os valores valores preenchidos pela corre��o
					oModelNSY:ClearField("NSY_CCORMT", nMultaHon)
					oModelNSY:ClearField("NSY_CJURMT", nMultaHon)
					oModelNSY:ClearField("NSY_MUATT" , nMultaHon)
				EndIf

				// Flags de Valor Inestimavel
				oModelNSY:SetValue("NSY_V1INVL", '2')
				oModelNSY:SetValue("NSY_V2INVL", '2')
				oModelNSY:SetValue("NSY_TRINVL", '2')
			EndIf

			// Atualiza��o dos Valores Hist�ricos 
			If cCodTipPrg == '1' .AND. lCposHist
				J270UpdHis(oModelO0W, oModelNSY, cMoeda)
			EndIf
		EndIf

		// Redutor
		If lRedut
			oModelNSY:SetValue("NSY_REDUT" , oModelO0W:GetValue("O0W_REDUT"))
		EndIf
	Next nI

	oModelO0W:LoadValue("O0W_VPROVA",nValProvav)
	oModelO0W:LoadValue("O0W_VPOSSI",nValPossiv)
	oModelO0W:LoadValue("O0W_VREMOT",nValRemoto)
	oModelO0W:LoadValue("O0W_VINCON",nValIncont)

	oModelNSY:SetNoInsertLine(.T.)
	oModelNSY:GoLine(nGridNsy)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J310Commit(oModel)
Valida informa��es Commit

@param  oModel Model a ser verificado
@Return lRet   .T./.F. As informa��es s�o v�lidas ou n�o
@since 15/02/2023
/*/
//-------------------------------------------------------------------
Static Function J310Commit(oModel)
Local aAreaO13   := O13->(GetArea())
Local oModel282  := Nil
Local oModelO0W  := oModel:GetModel("O0WMASTER")
Local cProcesso  := oModelO0W:GetValue("O0W_CAJURI")
Local cMoeCod    := SuperGetMv("MV_JCMOPRO", .F., "01") // C�digo da moeda utilizada nos valores envolvidos\provis�o no processo quando estes valores vierem dos objetos
Local cFilProc   := xFilial("NSZ")
Local cPrognost  := ""
Local cVerba     := ""
Local aVlrPro    := {}
Local aVlEnvolvi := {}
Local dData      := Date()
Local lRet       := .F.
Local nVCProAtu  := 0
Local nVJProAtu  := 0
Local nVlrPro    := 0
Local nVlrProAtu := 0	

	Private cTipoAsJ   := JurGetDados("NSZ", 1, xFilial("NSZ") + cProcesso, "NSZ_TIPOAS")
	Private C162TipoAs := cTipoAsJ

	// Ajusta a corre��o e juros na NV3 
	JurHisCont(cProcesso,, Date(), 0 , '2', '1', 'NSZ',3)
	JurHisCont(cProcesso,, Date(), 0 , '3', '1', 'NSZ',3)
 
	lRet := FwFormCommit( oModel )

	If lRet .AND. oModel:GetOperation() <> 5
		cVerba := oModelO0W:getValue("O0W_COD")
 
		// Atualiza Valores
		If oModelO0W:isFieldUpdate("O0W_VPEDID") .Or. oModelO0W:isFieldUpdate("O0W_VPROVA") .Or.;
				oModelO0W:isFieldUpdate("O0W_VINCON") .Or. oModelO0W:isFieldUpdate("O0W_VREMOT") .Or.;
				oModelO0W:isFieldUpdate("O0W_CFRCOR") .Or. oModelO0W:isFieldUpdate("O0W_DATPED")
			
			JURCORVLRS('NSY', cProcesso, , , , .T., cVerba)
		EndIf

		JAtuValO0W(cProcesso, cVerba)

		// atualiza os valores de redutor da O0W
		If ColumnPos('O0W_REDUT') > 0
			J270Redut(cProcesso, oModelO0W:getValue("O0W_COD"), oModelO0W:GetValue("O0W_PROGNO"))
		EndIf
	EndIf

	//Busca progn�stico dos objetos
	cPrognost := J94ProgObj(cFilProc, cProcesso)

	//Busca valor provavel
	nVlrPro := JA094VlDis(cProcesso, "1", .F.)

	//Busca valor provavel atualizado
	aVlrPro    := JA094VlDis(cProcesso, "1", .T.,,.T.)
	nVlrProAtu := aVlrPro[1][1] // Valor atualizado
	nVCProAtu  := aVlrPro[1][2] // Valor de corre��o Atualizado
	nVJProAtu  := aVlrPro[1][3] // Valor de Juros Atualizado

	DbSelectArea("NSZ")
	NSZ->( DbSetOrder(1) )  // NSZ_FILIAL + NSZ_COD

	// Atualiza as informa��es nos campos do processo - NSZ
	If NSZ->( DbSeek(cFilProc + cProcesso) )
		// Busca valores envolvidos
		aVlEnvolvi := JA094VlEnv(cProcesso, cFilProc)

		NSZ->(RecLock("NSZ", .F.))

		NSZ->NSZ_CPROGN := cPrognost
		NSZ->NSZ_VLPROV := nVlrPro
		NSZ->NSZ_VAPROV := nVlrProAtu
		NSZ->NSZ_VCPROV := nVCProAtu
		NSZ->NSZ_VJPROV := nVJProAtu

		If (nVlrPro ) > 0
			NSZ->NSZ_DTPROV := dData
			NSZ->NSZ_CMOPRO := cMoeCod
		Else
			NSZ->NSZ_DTPROV := CtoD("")
			NSZ->NSZ_CMOPRO := ""
		EndIf

		NSZ->NSZ_VLENVO := aVlEnvolvi[1][1]
		NSZ->NSZ_VAENVO := aVlEnvolvi[1][2]
		NSZ->NSZ_VCENVO := aVlEnvolvi[1][3]
		NSZ->NSZ_VJENVO := aVlEnvolvi[1][4]
		If aVlEnvolvi[1][1] > 0
			NSZ->NSZ_DTENVO := dData
			NSZ->NSZ_CMOENV := cMoeCod
		Else
			NSZ->NSZ_DTENVO := CtoD("")
			NSZ->NSZ_CMOENV := ""
		EndIf
	EndIf

	NSZ->(MsUnlock())
	If __lSX8
		ConfirmSX8()
	EndIf

	// Grava��o do hist�rico de altera��es de pedidos
	If lRet .AND. FWAliasInDic("O13")
		J310SetLog(oModel282, oModelO0W)
	EndIf

	FWModelActive(oModel, .T.) // Volta o modelo ativo para a O0W
	RestArea(aAreaO13)

Return(lRet)

//------------------------------------------------------------------------------
/* /{Protheus.doc}

@since 16/02/2023
/*/
//------------------------------------------------------------------------------
Function J310SetLog(oModel282, oModelO0W)
Local cQuery     := ""
Local cCodO0W    := ""
Local aAliasO0W  := GetNextAlias()
Local aParams    := {}

	oModel282 := FWLoadModel("JURA282")
	oModel282:SetOperation(3) //Inclus�o
	oModel282:Activate()

	cCodO0W := oModelO0W:GetValue("O0W_COD")
	oModel282:SetValue( "O13MASTER", "O13_CPEDID", cCodO0W                          )
	oModel282:SetValue( "O13MASTER", "O13_USUALT", USRRETNAME(__CUSERID)            )
	oModel282:SetValue( "O13MASTER", "O13_PROGNO", oModelO0W:GetValue("O0W_PROGNO") )
	oModel282:SetValue( "O13MASTER", "O13_VPEDID", oModelO0W:GetValue("O0W_VPEDID") )
	oModel282:SetValue( "O13MASTER", "O13_VPOSSI", oModelO0W:GetValue("O0W_VPOSSI") )
	oModel282:SetValue( "O13MASTER", "O13_VPROVA", oModelO0W:GetValue("O0W_VPROVA") )
	oModel282:SetValue( "O13MASTER", "O13_VREMOT", oModelO0W:GetValue("O0W_VREMOT") )
	oModel282:SetValue( "O13MASTER", "O13_VINCON", oModelO0W:GetValue("O0W_VINCON") )
	oModel282:SetValue( "O13MASTER", "O13_CFRCOR", oModelO0W:GetValue("O0W_CFRCOR") )

	aAdd( aParams, xFilial("O0W") )
	aAdd( aParams, cCodO0W )

	// Busca os valores corrigidos
	cQuery := " SELECT O0W_VATPED, "
	cQuery +=        " O0W_VATPOS, "
	cQuery +=        " O0W_VATPRO, "
	cQuery +=        " O0W_VATREM, "
	cQuery +=        " O0W_VATINC  "
	cQuery += " FROM " +  RetSqlName("O0W")  + " O0W "
	cQuery += " WHERE O0W.O0W_FILIAL = ? "
	cQuery += "   AND O0W.O0W_COD = ? "
	cQuery += "   AND O0W.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), aAliasO0W, .T., .F. )

	If !(aAliasO0W)->(EOF())
		oModel282:SetValue( "O13MASTER", "O13_VATPED", (aAliasO0W)->O0W_VATPED )
		oModel282:SetValue( "O13MASTER", "O13_VATPOS", (aAliasO0W)->O0W_VATPOS )
		oModel282:SetValue( "O13MASTER", "O13_VATPRO", (aAliasO0W)->O0W_VATPRO )
		oModel282:SetValue( "O13MASTER", "O13_VATREM", (aAliasO0W)->O0W_VATREM )
		oModel282:SetValue( "O13MASTER", "O13_VATINC", (aAliasO0W)->O0W_VATINC )
	EndIf

	If ( lRet := oModel282:VldData() )
		lRet := oModel282:CommitData()
	EndIf

	If !lRet
		JurMsgErro(oModel282:aErrorMessage[6], STR0013, oModel282:aErrorMessage[7]) // "N�o foi poss�vel incluir o hist�rico do pedido. Verifique."
	EndIf

	oModel282:DeActivate()
	oModel282:Destroy()
	oModel282 := Nil

	(aAliasO0W)->(DbCloseArea())

Return .T.
