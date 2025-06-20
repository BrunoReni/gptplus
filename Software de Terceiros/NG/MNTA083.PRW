#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MNTA083.CH"

Static oST9 := Nil
Static lWhenEst := .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083
Cadastro de Pneus

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Function MNTA083()

	Local aNGBeginPrm := NGBeginPrm()
	Local oBrowse

	// Validation
	Local lValid	:= .T.
	Local cError	:= ''
	Local cSolution := ''
	Local lMNTA0833 := IIf( ExistBlock("MNTA0833"), .T., .F.)

	//Filtro Browse - somente pneus com o status diferente de 'Aguardando marca��o de fogo'
	Local cFiltro	:= "ST9->T9_CATBEM == '3'"
	Local cStaFog   := Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )

	If !FindFunction( 'MNTAmIIn' ) .Or. MNTAmIIn( 95 )

		// View
		Private cCadastro := STR0001 // "Cadastro de Pneus"
		Private lFrota	  := IIf( GetRPORelease() >= '12.1.033', MNTFrotas(), SuperGetMv( 'MV_NGMNTFR', .F., 'N' ) == 'S' )
		Private nOptRot   := 3

		//Variaveis utilizadas na consulta de OS referente ao bem corrente
		Private TIPOACOM  := IIF(M->T9_TEMCONT <> "N",.T.,.F.)
		Private TIPOACOM2 := IIF(M->TPE_SITUAC <>  2 ,.T.,.F.)
		Private lSITUACA  := .F.

		//--------------------------------------------------------------------------------------------------------------
		// Os pneus com status aguardando marca��o de fogo s� ser�o apresentados na rotina mnta086 - classifica��o
		//--------------------------------------------------------------------------------------------------------------
		If !Empty(cStaFog) .And. TQZ->( FieldPos("TQZ_NUMSEQ") ) > 0
			cFiltro	+= " .And. ST9->T9_STATUS != '" + cStaFog + "'"
		EndIf

		//Initial Validations
		If !lFrota
			lValid    := .F.
			cError    := STR0002 //'Para cadastro de pneus, precisa integra��o com frotas atrav�s do par�metro MV_NGMNTFR.'
			cSolution := STR0003 //'Acessar o m�dulo configurador SIGACFG e efetuar a altera��o do par�metro.'
		ElseIf GetNewPar('MV_NGPNEUS','N') <> 'S'
			lValid    := .F.
			cError    := STR0004 //'Para cadastro de pneus, precisa integra��o com pneus atrav�s do par�metro MV_NGPNEUS.'
			cSolution := STR0005 //'Acessar o m�dulo configurador SIGACFG e efetuar a altera��o do par�metro.'
		EndIf

		If !NGCADICBASE('T6_CATBEM','A','ST6',.F.)
			lValid    := .F.
			cError    := STR0025 //'Para cadastro de ve�culos, precisa da ultima release 12.1.7.'
			cSolution := STR0026 //'Atualizar o ambiente.'
		EndIf

		If lValid

			//Caso possua o ponto de entrada 'MNTA0832' ou 'MNTA0831' dever� trocar para o modelo MVC.
			If !FindFunction('U_MNTA083') .And. (FindFunction('U_MNTA0831') .Or. FindFunction('U_MNTA0832'))
				MsgInfo( STR0036, STR0035 ) // 'Os pontos de entrada "MNTA0831" e "MNTA0832" devem ser alterados conforme o novo modelo. Favor pesquisar a ISSUE MNG-6626 para o ponto de entrada "MNTA0831" e a ISSUE MNG-6281 para o ponto de entrada "MNTA0832" no TDN.' ## 'PONTO DE ENTRADA'
			EndIf

			If lMNTA0833
				cFiltro += ExecBlock("MNTA0833",.F.,.F.)
			EndIf

			//Initializes Browse
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias( 'ST9' )
			oBrowse:SetDescription( cCadastro )
			oBrowse:SetFilterDefault( cFiltro )
			oBrowse:SetMenuDef('MNTA083')
			LegendST9( oBrowse )
			oBrowse:Activate()
		ElseIf !Empty( cError )
			//Show error
			Help( " ",1,STR0006,,cError + CRLF + cSolution,3,1 ) // "NAO CONFORMIDADE"
		EndIf
	EndIf

	NGReturnPrm( aNGBeginPrm )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Options Menu

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Array
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {} //FWMVCMenu( "MNTA083" )

	ADD OPTION aRotina Title STR0028 Action 'MNTA080CAD("ST9",ST9->(Recno()),2,"3")' OPERATION 2 ACCESS 0   // 'Visualizar'
	ADD OPTION aRotina Title STR0029 Action 'MNTA080CAD("ST9",,3,"3")'               OPERATION 3 ACCESS 0   // 'Incluir'
	ADD OPTION aRotina Title STR0030 Action 'MNTA080CAD("ST9",ST9->(Recno()),4,"3")' OPERATION 4 ACCESS 0   // 'Alterar'
	ADD OPTION aRotina Title STR0031 Action 'MNTA080CAD("ST9",ST9->(Recno()),5,"3")' OPERATION 5 ACCESS 141 // 'Excluir'
	ADD OPTION aRotina Title STR0007 Action 'MNTA080INA()'                           OPERATION 6 ACCESS 0   //'Inativar'
	ADD OPTION aRotina Title STR0032 Action 'VIEWDEF.MNTA083'                        OPERATION 8 ACCESS 0   // 'Imprimir'
	ADD OPTION aRotina Title STR0033 Action 'MNTA080CAD("ST9",ST9->(Recno()),9,"3")' OPERATION 9 ACCESS 0   // 'Copiar'

	If ExistBlock("MNTA0834")
		aRotina := ExecBlock("MNTA0834",.F.,.F.,{aRotina})
	EndIf

	If Type("__lPyme") == "U" .Or. !__lPyme
		ADD OPTION aRotina Title STR0008 Action 'MsDocument' OPERATION 4 ACCESS 0 //"Conhecimento"
	EndIf

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Data model

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return oModel
/*/
//------------------------------------------------------------------------------
Static Function ModelDef

	Local oModel
	Local bPreValid	 := {|oModel| PreValida(oModel)	}  // Valida��o inicial
	Local bPosValid	 := {|oModel| ValidInfo(oModel)	}  // Valida��o final
	Local bCommit	 := {|oModel| CommitInfo(oModel) } // Grava��o do formulario
	Local bCancel    := {|oModel| ValCancel(oModel) } // Bloco de C�digo para Cancelamento

	// Creates the data model of the object
	oModel := MPFormModel():New('MNTA083',, bPosValid, bCommit, bCancel )

	// Validate model activation
	oModel:SetVldActivate( bPreValid )

	// Adds the description of the Data Model
	oModel:SetDescription( STR0001 ) // "Cadastro de Pneus"

	// Asset
	ModelST9( oModel )

	// Details
	ModelSTB(oModel)

	// Tire
	ModelTQS( oModel )

	// Second Counter
	ModelTPE(oModel)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelST9
Data Model from ST9

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ModelST9( oModel )

	Local aFldNoCopy := {}
	Local cAlias     := 'ST9'
	Local cModelId   := oModel:cId + '_' + cAlias
	Local oModelAux  := Nil
	Local oStructAux := FWFormStruct( 1, cAlias ) //Cria a estrutura a ser usada no Modelo de Dados
	Local aPe836     := {}
	Local nIndex     := 0

	//Altera a propriedade dos campos
	oStructAux:SetProperty('T9_CATBEM', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'"3"'))

	// O campo T9_TIPMOD n�o � obrigat�rio no dicion�rio, mas torna-se obrigat�rio para o m�dulo SIGAGFR
	oStructAux:SetProperty("T9_TIPMOD", MODEL_FIELD_OBRIGAT, .T.)

	//Remove campos de Veiculos
	oStructAux:RemoveField("T9_CODTMS" )
	oStructAux:RemoveField("T9_PLACA"  )
	oStructAux:RemoveField("T9_CAPMAX" )
	oStructAux:RemoveField("T9_MEDIA"  )
	oStructAux:RemoveField("T9_TIPVEI" )
	oStructAux:RemoveField("T9_CHASSI" )
	oStructAux:RemoveField("T9_CORVEI" )
	oStructAux:RemoveField("T9_DESCOR" )
	oStructAux:RemoveField("T9_CIDEMPL")
	oStructAux:RemoveField("T9_UFEMPLA")
	oStructAux:RemoveField("T9_RENAVAM")
	oStructAux:RemoveField("T9_NRMOTOR")
	oStructAux:RemoveField("T9_CEREVEI")
	oStructAux:RemoveField("T9_MEDMIN" )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0835")
		ExecBlock("MNTA0835",.F.,.F.,{1,cAlias,oStructAux})
	EndIf

	// Define campos que n�o podem ser copiados
	aAdd( aFldNoCopy, 'T9_CODIMOB' )
	aAdd( aFldNoCopy, 'T9_POSCONT' )
	aAdd( aFldNoCopy, 'T9_DTULTAC' )
	aAdd( aFldNoCopy, 'T9_CONTACU' )
	aAdd( aFldNoCopy, 'T9_VARDIA'  )
	aAdd( aFldNoCopy, 'T9_LIMICON' )
	aAdd( aFldNoCopy, 'T9_ESTRUTU' )
	aAdd( aFldNoCopy, 'T9_STATUS'  )
	aAdd( aFldNoCopy, 'T9_SITMAN'  )
	aAdd( aFldNoCopy, 'T9_SITBEM'  )
	aAdd( aFldNoCopy, 'T9_DTBAIXA' )
	aAdd( aFldNoCopy, 'T9_MTBAIXA' )
	aAdd( aFldNoCopy, 'T9_COMPRAD' )
	aAdd( aFldNoCopy, 'T9_DTVENDA' )
	aAdd( aFldNoCopy, 'T9_NFVENDA' )

	//Ponto de entrada para determinar campos que n�o ser�o copiados
	If ExistBlock("MNTA0836")
		aPe836 := ExecBlock("MNTA0836",.F.,.F.,{'ST9'})

		If ValType( aPe836 ) == 'A'
			For nIndex := 1 To Len( aPe836 )
				If Ascan( aFldNoCopy, aPe836[nIndex] ) == 0
					aAdd( aFldNoCopy, aPe836[nIndex] )
				EndIf
			Next nIndex
		EndIf

	EndIf

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( cModelId , , oStructAux )

	// Retorna componente especifico
	oModelAux := oModel:GetModel( cModelId )

	// Adiciona lista de campos ao modelo
	oModelAux:SetFldNoCopy( aFldNoCopy )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModelAux:SetDescription( NgSX2Nome( cAlias ) )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelTQS
Modelo de dados da TQS

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ModelTQS( oModel )

	Local oModelAux
	Local aFldNoCopy := {}
	Local aRelation  := {}
	Local cAlias     := 'TQS'
	Local cModelId   := oModel:cId + '_' + cAlias
	Local aPe836     := {}
	Local nIndex     := 0

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 1, cAlias )

	// Altera para n�o-obrigat�rios os campos do relacionamento
	oStructAux:SetProperty( 'TQS_CODBEM' , MODEL_FIELD_OBRIGAT, .F. )

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0835")
		ExecBlock("MNTA0835",.F.,.F.,{1,cAlias,oStructAux})
	EndIf

	// Define relacionamento entre ST9 e STB
	aAdd( aRelation , { 'TQS_FILIAL' , 'xFilial( "TQS" )' } )
	aAdd( aRelation , { 'TQS_CODBEM' , 'T9_CODBEM' } )

	// Define campos que n�o podem ser copiados
	aAdd( aFldNoCopy, 'TQS_PLACA' )
	aAdd( aFldNoCopy, 'TQS_POSIC' )
	aAdd( aFldNoCopy, 'TQS_KMOR' )
	aAdd( aFldNoCopy, 'TQS_KMR1' )
	aAdd( aFldNoCopy, 'TQS_KMR2' )
	aAdd( aFldNoCopy, 'TQS_KMR3' )
	aAdd( aFldNoCopy, 'TQS_KMR4' )
	aAdd( aFldNoCopy, 'TQS_BANDAA' )

	//Ponto de entrada para determinar campos que n�o ser�o copiados
	If ExistBlock("MNTA0836")
		aPe836 := ExecBlock("MNTA0836",.F.,.F.,{'TQS'})

		If ValType( aPe836 ) == 'A'
			For nIndex := 1 To Len( aPe836 )
				If Ascan( aFldNoCopy, aPe836[nIndex] ) == 0
					aAdd( aFldNoCopy, aPe836[nIndex] )
				EndIf
			Next nIndex
		EndIf
	EndIf

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( cModelId , oModel:cId + '_ST9' , oStructAux )

	oModelAux := oModel:GetModel( cModelId )

	oModelAux:SetFldNoCopy( aFldNoCopy )

	// Faz relaciomaneto entre os compomentes do model
	oModelAux:SetRelation( aRelation , ( cAlias )->( IndexKey( 1 ) ) )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModelAux:SetDescription( NgSX2Nome( cAlias ) )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return oView
/*/
//------------------------------------------------------------------------------
Static Function ViewDef

	Local oView, aWhenBtn
	Local oModel := FWLoadModel( 'MNTA083' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel( oModel )

	// Cria Box na view
	oView:CreateHorizontalBox( 'MAIN', 100 )

	// Cria Folder na view
	oView:CreateFolder( 'MAIN_FOLDER' , 'MAIN' )

	// Asset
	ViewST9( oView , oModel )

	// Details
	ViewSTB( oView , oModel )

	// Tire
	ViewTQS( oView , oModel )

	// Counter
	ViewCounter( oView , oModel )

	// Complementos
	aWhenBtn := WhenBtn()

	//Inclus�o de itens no A��es Relacionadas de acordo com o NGRightClick
	NGMVCUserBtn(oView , , , aWhenBtn )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewST9
View from ST9

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ViewST9( oView , oModel )

	Local cAlias := 'ST9'

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 2 , cAlias )

	oStructAux:SetProperty( 'T9_CODBEM'	, MVC_VIEW_TITULO , STR0009 ) // 'Pneu'
	oStructAux:SetProperty( 'T9_NOME'	, MVC_VIEW_TITULO , STR0010 ) // 'Nome Pneu'

	oStructAux:RemoveField("T9_CODTMS")
	oStructAux:RemoveField("T9_PLACA")
	oStructAux:RemoveField("T9_CAPMAX")
	oStructAux:RemoveField("T9_MEDIA")
	oStructAux:RemoveField("T9_TIPVEI")
	oStructAux:RemoveField("T9_CHASSI")
	oStructAux:RemoveField("T9_CORVEI")
	oStructAux:RemoveField("T9_DESCOR")
	oStructAux:RemoveField("T9_CIDEMPL")
	oStructAux:RemoveField("T9_UFEMPLA")
	oStructAux:RemoveField("T9_RENAVAM")
	oStructAux:RemoveField("T9_NRMOTOR")
	oStructAux:RemoveField("T9_CEREVEI")
	oStructAux:RemoveField("T9_MEDMIN")
	oStructAux:RemoveField("T9_CATBEM")

	//Ponto de entrada para remover campos da tela
	If ExistBlock("MNTA0835")
		ExecBlock("MNTA0835",.F.,.F.,{2,cAlias,oStructAux})
	EndIf

	// Remove todos os campos do agrupamento de contador
	FilterField( oStructAux , '004' , .T. )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	// Cria pastas nas folders
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , STR0011 ) //'Bem'

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

	SetKey(VK_F4, {|| fShowSB2() })

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} fShowSB2
Consulta de estoque

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function fShowSB2()

	Local oView := FwViewActive()

	If ValType( oView ) == 'O' .And. oView:GetFolderActive( "MAIN_FOLDER" , 2 )[2] == STR0011
		MntViewSB2( 'P' , M->T9_CODESTO )
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewTQS
View from TQS

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ViewTQS( oView , oModel )

	Local cAlias := 'TQS'

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructAux := FWFormStruct( 2 , cAlias )

	oStructAux:RemoveField("TQS_CODBEM")
	oStructAux:RemoveField("TQS_DESBEM")

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_' + cAlias , oStructAux , oModel:cId + '_' + cAlias )

	// Cria pastas nas folde
	oView:AddSheet( 'MAIN_FOLDER', 'ABA_' + cAlias , STR0009 ) //'Pneu'

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'BOX_' + cAlias , 100,,, 'MAIN_FOLDER', 'ABA_' + cAlias )

	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_' + cAlias , 'BOX_' + cAlias )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreValida
Pre valida��o para abertura do cadastro

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function PreValida( oModel )

	lWhenEst := .T.

	//Indica que controla hist. do estoque dos pneus
	If oModel:GetOperation() == 4

		cQryAlias := GetNextAlias()
		cQuery := " SELECT COUNT(*) AS TOTAL FROM " + RetSqlName("TQZ")
		cQuery += " WHERE  TQZ_CODBEM = '" + ST9->T9_CODBEM + "' "
		cQuery += " AND TQZ_PRODUT <> ' ' "
		cQuery += " AND TQZ_ALMOX <> ' ' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cQryAlias, .F., .T.)
		dbSelectArea(cQryAlias)
		If (cQryAlias)->TOTAL > 1
			lWhenEst := .F.
		EndIf
		(cQryAlias)->(dbCloseArea())
	EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Valida��o ao confirmar tela

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function ValidInfo( oModel )

	// Inicializa classe
	oST9 := MntPneu():New

	// Carrega a classe com modelo de dados
	oST9:ModelToClass( oModel )

	// Executa valida��o final
	oST9:Valid()

	// Se houver, apresenta erro
	oST9:ShowHelp()

Return oST9:IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Grava todas as informa��es

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Static Function CommitInfo(oModel)

	Local lAltLin    := .F.
	Local lMnt083   := ExistBlock("MNTA083")
	Local nX         := 0
	Local nLenSub    := Len(oModel:AallSubModels) //Verificar se possui SubModelos.

	If nLenSub > 0 .And. lMnt083//Caso possua Sub-Modelos
		For nX := 1 To nLenSub //Percorre todos.
			If oModel:AallSubModels[nX]:cId == 'MNTA083_STB'  //Verifica os modelos que possuem grid.
				If Len(oModel:AallSubModels[nX]:GetLinesChanged()) > 0 //Caso possua alguma linha alterada.
					lAltLin := .T.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf

	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oModel,'FORMCOMMITTTSPRE','MNTA083',lAltLin})
	EndIf

	Do Case
		Case oST9:IsUpsert() //Upsert - Executa inclus�o ou altera��o do cadastro

			If oST9:Upsert() .And. oST9:IsInsert()
				ConfirmSX8()
			EndIf

		Case oST9:IsDelete() // Delete - Executa exclus�o do cadastro
			oST9:Delete()
	Endcase

	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oST9,'MODELCOMMITTTS','MNTA083'})
	EndIf

	// Se houver, apresenta erro
	oST9:ShowHelp()

	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oModel,'FORMCOMMITTTSPOS','MNTA083',lAltLin})
	EndIf

	//Ponto de entrada executado ap�s grava��es
	If lMnt083
		ExecBlock("MNTA083",.F.,.F.,{oST9,'MODELCOMMITNTTS','MNTA083'})
	EndIf

	// Limpa classe
	oST9:Free()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNT083WHEN
Define modo de edi��o de Campos

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return lOpenField - Indica se campo ficar� aberto
/*/
//------------------------------------------------------------------------------
Function MNT083WHEN( cField )

	Local lOpenField := .T.
	Local lTemRI := .F.
	Local nCharIni, nCharEnd
	Local cAliasQry := ''

	Default cField := ReadVar()

	//--------------------------------------------------------------------------
	// Tratamento do nome de campo
	//--------------------------------------------------------------------------
	If '>' $ cField
		nCharIni	:= At( '>' , cField ) + 1
		nCharEnd	:= Len( cField )
		cField		:= SubStr( cField , nCharIni , nCharEnd )
		cField		:= Upper( cField )
		cField		:= Trim( cField )
	EndIf

	//--------------------------------------------------------------------------
	// TQS_EIXO/TQS_TIPEIX/TQS_PLACA/TQS_POSIC
	//--------------------------------------------------------------------------
	If cField $ "TQS_EIXO/TQS_TIPEIX/TQS_PLACA/TQS_POSIC"

		If .Not. Empty( M->T9_STATUS )
			lTemRI := ( GetNewPar('MV_NGSTARI','') == M->T9_STATUS )
		EndIf

		lOpenField :=  ( lTemRI .Or. ( M->T9_STATUS == GetNewPar('MV_NGSTAPL') .And. ( Inclui .Or. IsInCallStack( 'MNTA086' ) ) ) .Or.;
						Empty(M->T9_STATUS) .Or. IsInCallStack( 'Commit087' ) )

	//--------------------------------------------------------------------------
	// TQS_DTMEAT/TQS_HRMEAT/TQS_BANDAA
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_DTMEAT/TQS_HRMEAT/TQS_BANDAA"

		If Altera .And.;
			!IsInCallStack('MNTA086') .And. ; // classifica��o de pneus
			( Empty( M->T9_STATUS ) .Or. GetNewPar('MV_NGSTARI','') != M->T9_STATUS )
			lOpenField := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_SULCAT - Sulco
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_SULCAT"

		If !Inclui
		
			cAliasQry := getNextAlias()
			
			BeginSql Alias cAliasQry
				SELECT COUNT(TQV_CODBEM) TOTAL FROM %Table:TQV% TQV
					WHERE TQV.TQV_FILIAL = %xFilial:TQV% AND
					TQV.TQV_CODBEM = %exp:M->TQS_CODBEM% AND
					TQV.%NotDel%
			EndSql

			If (cAliasQry)->(TOTAL) > 1
				lOpenField := .F.
			EndIF

			(cAliasQry)->(dbCloseArea())

		EndIf

	//--------------------------------------------------------------------------
	// TQS_DESENH - Desenho
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_DESENH"

		lOpenField := ( M->TQS_BANDAA > '1' )

	//--------------------------------------------------------------------------
	// TQS_KMOR - Banda Original
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMOR"

		lOpenField := ( .Not. Empty( M->TQS_BANDAA ) )

	//--------------------------------------------------------------------------
	// TQS_KMR1 - Banda 2
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR1

		lOpenField := ( M->TQS_BANDAA > '1' )

	//--------------------------------------------------------------------------
	// TQS_KMR2 - Banda 3
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR2"

		lOpenField := ( M->TQS_BANDAA > '2' )

	//--------------------------------------------------------------------------
	// TQS_KMR3 - Banda 4
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR3"

		lOpenField := ( M->TQS_BANDAA > '3' )

	//--------------------------------------------------------------------------
	// TQS_KMR4 - Banda 5
	//--------------------------------------------------------------------------
	ElseIf cField $ "TQS_KMR4"

		lOpenField := ( M->TQS_BANDAA > '4' )

	//--------------------------------------------------------------------------
	// Campos de estoque
	//--------------------------------------------------------------------------
	ElseIf cField $ "T9_CODESTO/T9_LOCPAD"

		lOpenField := lWhenEst

		cStatusTire := GetNewPar("MV_NGSTAEU")
		cStatusTire += "/" + GetNewPar("MV_NGSTAER")
		cStatusTire += "/" + GetNewPar("MV_NGSTARS")
		cStatusTire += "/" + GetNewPar("MV_NGSTAEN")
		cStatusTire += "/" + GetNewPar("MV_NGSTEST")

		If IsIncallStack( 'MNTA085' ) // Gera pneus a partir de NF
			cStatusTire += "/" + Alltrim( SuperGetMv( 'MV_NGSTAFG', .F., '' ) )
		EndIf

		If lOpenField .And. M->T9_CATBEM == '3' .And. .Not. Empty( M->T9_STATUS )

			If GetNewPar("MV_NGMNTES","N") == 'S' .And.;
			GetNewPar("MV_NGPNEST","N") == 'S' .And.;
			.Not. ( M->T9_STATUS $ cStatusTire )

				lOpenField := .F.
			ElseIf M->T9_STATUS $ GetNewPar("MV_NGSTAPL")
				lOpenField := .F.
			EndIf
		EndIf
	EndIf

Return lOpenField

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083VLD
Field Validation

@author NG Inform�tica Ltda.
@since 01/01/2015
@version P12
@return Bool
/*/
//------------------------------------------------------------------------------
Function MNTA083VLD( cField )

	// Return variables
	Local lValid := .T.
	Local cError := ''
	Local aArea  := {}
	Local aTrigger := {}

	// Campo a ser validado
	Default cField := ReadVar()

	//--------------------------------------------------------------------------
	// Tratamento do nome de campo
	//--------------------------------------------------------------------------
	If '>' $ cField
		nCharIni	:= At( '>' , cField ) + 1
		nCharEnd	:= Len( cField )
		cField		:= SubStr( cField , nCharIni , nCharEnd )
		cField		:= Upper( cField )
		cField		:= Trim( cField )
	EndIf

	//--------------------------------------------------------------------------
	// T9_CODESTO - Stock
	//--------------------------------------------------------------------------
	If 'T9_CODESTO' $ cField

		If .Not. Empty( M->T9_CODESTO )
			lValid := ExistCpo( 'SB1' , M->T9_CODESTO )
		EndIf

	//--------------------------------------------------------------------------
	// T9_LOCPAD - WareHouse
	//--------------------------------------------------------------------------
	ElseIf 'T9_LOCPAD' $ cField

		If !Empty( M->T9_LOCPAD ) .And. !ExistCpo( 'NNR' , M->T9_LOCPAD )
			lValid := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_DTMEAT - Data Sulco Atual
	//--------------------------------------------------------------------------
	ElseIf 'TQS_DTMEAT' $ cField

		lValid := VALDT( M->TQS_DTMEAT )

		If dDataBase == M->TQS_DTMEAT .And. SubStr(Time(),1,5) < M->TQS_HRMEAT
			aAdd( aTrigger , { 'TQS' , 'TQS_HRMEAT' , '  :  ' }  )
		EndIf

	//--------------------------------------------------------------------------
	// TQS_HRMEAT - Hora Medi��o Sulco
	//--------------------------------------------------------------------------
	ElseIf 'TQS_HRMEAT' $ cField

		If .Not. NGVALHORA(M->TQS_HRMEAT,.T.)
			lValid := .F.
		ElseIf dDataBase == M->TQS_DTMEAT .And. SubStr(Time(),1,5) < M->TQS_HRMEAT
			cError := STR0016 //"Hora informada dever� ser menor que a hora atual!"
			lValid := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_BANDAA - Banda do Pneu
	//--------------------------------------------------------------------------
	ElseIf 'TQS_BANDAA' $ cField

		If Altera .And. M->TQS_BANDAA < TQS->TQS_BANDAA
			cError := STR0017 + Space(1) //"Banda dever� ser maior do que a"
			cError += STR0018 + CRLF //"Banda atual"
			cError += STR0018 + "..: " //"Banda atual"
			cError += NGRETSX3BOX("TQS_BANDAA",TQS->TQS_BANDAA)
			lValid := .F.
		EndIf

	//--------------------------------------------------------------------------
	// TQS_PLACA - Placa do Veiculo Pai
	//--------------------------------------------------------------------------
	ElseIf 'TQS_PLACA' $ cField

		If !Empty(M->TQS_PLACA)

			dbSelectArea( 'ST9' )
			dbSetOrder( 14 )
			dbSeek( M->TQS_PLACA + 'A' )
			If .Not. Found()
				lValid := .F.
				cError := STR0019 //"Placa informada n�o existe no cadastro de Bens."
			ElseIf ST9->T9_FILIAL <> xFilial("ST9")
				lValid := .F.
				cError := STR0027 //"N�o � poss�vel aplicar o pneu em um ve�culo de outra filial."
			EndIf

			If lValid .And. M->T9_TEMCONT == 'P'
				aAdd( aTrigger , { 'ST9' , 'T9_POSCONT' , ST9->T9_POSCONT }  )
			EndIf

			NGDBAREAORDE("ST9",1)
		EndIf

	//--------------------------------------------------------------------------
	// TQS_DOT - Data de Fabrica��o
	//--------------------------------------------------------------------------
	ElseIf 'TQS_DOT' $ cField

		If !Empty(M->TQS_DOT)
			cSemFab := Left(M->TQS_DOT,2) //semana de fabricacao
			dAnoFab := CToD("01/01/"+Right(M->TQS_DOT,2)) //ano de fabricacao
			cSemCor := StrZero(NGSEMANANO(dDataBase),2) //semana corrente
			dAnoCor := CToD("01/01/"+Right(cValToChar(YEAR(dDataBase)),2))  //ano corrente

			cDotM := AllTrim( M->TQS_DOT )
			If Len( cDotM ) < Len( M->TQS_DOT )
				lValid := .F.
				cError := STR0020 + Space(1) //"N�o foi preenchito corretamente o campo"
				cError += NGRETTITULO("TQS_DOT")
			EndIf

			If lValid .And. !NGSOCARACTER(cSemFab,"D",.F.)[1]
				lValid := .F.
				cError := STR0021 //"Semana de fabrica��o � invalida."

			EndIf

			cAnoCor := Right( cDotM , 2 )
			If lValid .And. !NGSOCARACTER(cAnoCor,"D",.F.)[1]
				lValid := .F.
				cError := STR0022 //"Ano de fabrica��o inv�lido."
			EndIf

			If lValid .And. Val(cSemFab) > 0 .AnD. Val(cSemFab) <= 53 //total de semanas por ano (365/7)
				If dAnoFab == dAnoCor
					If cSemFab > cSemCor
						lValid := .F.
						cError := STR0023 //"Semana de fabrica��o "
						cError += "(" + cSemFab + ")" + Space(1)
						cError += STR0024 + Space(1) //"deve ser igual ou menor � semana corrente"
						cError += "(" + cSemCor + ")."
					EndIf
				ElseIf dAnoFab > dAnoCor
					lValid := .F.
					cError := STR0012 //"Ano de fabrica��o deve ser igual ou menor ao ano corrente."
				EndIf
			ElseIf lValid
				lValid := .F.
				If Val( cSemFab ) > 52
					cError := STR0013 //"Semana de fabrica��o ultrapassa o limite de semanas por ano."
				Else
					cError := STR0014 //"Semana de fabrica��o inv�lida."
				EndIf
			EndIf
		EndIf

	//--------------------------------------------------------------------------
	// TQS_POSIC - Posi��o Pneu
	//--------------------------------------------------------------------------
	ElseIf 'TQS_POSIC' $ cField

		If !ExistCpo('TPS',M->TQS_POSIC) .Or. !MNTA083TPS(.F.)
			lValid := .F.
		Else
			aArea := GetArea()
			dbSelectArea( 'ST9' )
			dbSetOrder( 14 )
				If !Empty(M->TQS_PLACA) .And.;
					ST9->( dbSeek( M->TQS_PLACA + 'A' ) ) .And.;
					NGIFdbSeek('STC',ST9->T9_CODBEM+ST9->T9_TIPMOD+"B"+M->TQS_POSIC,6) .And.;
					M->TQS_CODBEM <> STC->TC_COMPONE

				lValid := .F.
				cError := STR0015 //"Localiza��o j� existe."
			EndIf
			dbSelectArea('ST9')
			dbSetOrder(1)
			RestArea(aArea)
		EndIf

	//--------------------------------------------------------------------------
	// TQS_KMOR - Km Percor Or
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMOR' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR1 - Km Banda R1
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR1' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR2 - Km Banda R2
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR2' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR3 - Km Banda R3
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR3' $ cField
	
		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_KMR4 - Km Banda R4
	//--------------------------------------------------------------------------
	ElseIf 'TQS_KMR4' $ cField

		lValid := Positivo()

	//--------------------------------------------------------------------------
	// TQS_SULCAT - Sulco Atual
	//--------------------------------------------------------------------------
	ElseIf 'TQS_SULCAT' $ cField

		lValid := Positivo()

	EndIf

	//--------------------------------------------------------------------------
	// Show error
	//--------------------------------------------------------------------------
	If .Not. Empty( cError )
		Help( " ",1,STR0006,,cError,3,1 )//"NAO CONFORMIDADE"
	EndIf

	//--------------------------------------------------------------------------
	// Run trigger
	//--------------------------------------------------------------------------
	ExecTrigger( aTrigger )

	If lValid
		ExecTrig( cField )
	EndIf

Return lValid

//---------------------------------------------------------------------------
/*/{Protheus.doc} MNTA083TPS
Cria o filtro para a consulta padr�o TPSEST

@param	lWhVld	, L�gico, Verifica se a valida��o � para filtro de conpad ou valid
@return lRet 	, L�gico, .T. para execu��o do filtro na consulta padr�o TTMCC.

@sample MNTA083TPS()
@author Alexandre Santos
@since 24/11/2017
/*/
//---------------------------------------------------------------------------
Function MNTA083TPS(lFilVld)

	Local cFilter	:= ""
	Local cCodFam	:= ""
	Local cCodMod	:= ""
	Local nX		:= 0
	Local lRet		:= .F.

	Default lFilVld 	:= .F.

	If !Empty(M->TQS_PLACA)

		dbSelectArea("ST9")
		dbSetOrder(14)
		If dbSeek(M->TQS_PLACA)
			cCodFam := ST9->T9_CODFAMI
			cCodMod := ST9->T9_TIPMOD

			dbSelectArea("TQ1")
			dbSetOrder(1)
			dbSeek(xFilial("TQ1") + cCodFam + cCodMod)
			While !Eof() .And. xFilial("TQ1") + cCodFam + cCodMod == TQ1->TQ1_FILIAL + TQ1->TQ1_DESENH + TQ1->TQ1_TIPMOD

				cFilter := ""

				For nX:= 1 to TQ1->TQ1_QTDPNE
					If lFilVld //Filtro CONPAD
						If nX == TQ1->TQ1_QTDPNE
							cFilter += "TPS->TPS_CODLOC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX))
						Else
							cFilter += "TPS->TPS_CODLOC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX)) + " .Or. "
						EndIf
					Else //Valid
						If nX == TQ1->TQ1_QTDPNE
							cFilter += "M->TQS_POSIC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX))
						Else
							cFilter += "M->TQS_POSIC == TQ1->TQ1_LOCPN" + AllTrim(Str(nX)) + " .Or. "
						EndIf
					EndIf
				Next

				If &(cFilter)
					lRet := .T.
					Exit
				EndIf

				TQ1->(dbSkip())
			End

			If !lRet
				Help('',1,STR0006,,STR0034,1,0) //NAO CONFORMIDADE
			EndIf
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValCancel
Fun��o de valida��o de quando cancelado o processo.
@type static

@author Guilherme Freudenburg
@since 26/03/2018

@param  oModel, Objeto, Objeto principal da rotina, contem os valores informados.
@return lRet  , L�gico, Retorna a verifica��o do ponto de entrada.
/*/
//------------------------------------------------------------------------------
Static Function ValCancel( oModel )

	Local lRet := .T.

	RollBackSX8()

	If ExistBlock( 'MNTA083' )
		lRet := ExecBlock( 'MNTA083', .F., .F., {oModel, 'FORMCANCEL', 'MNTA083'} )
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA083REL
Relacao do campo TQS_NOMPAI

@author Cau� Girardi
@since 06/10/22
@param cCampo, String, Campo a receber seu relacao 
@return cReturn
/*/
//---------------------------------------------------------------------
Function MNTA083REL(cCampo)

Local cReturn	:= ''
Local aArea		:= ST9->( GetArea() )

If cCampo == 'TQS_PLACA'

	If(!Inclui).AND.(!Empty(M->TQS_PLACA))

		cReturn := Posicione('ST9',14,M->TQS_PLACA,'T9_NOME')

	EndIf
	
EndIF

RestArea( aArea )

Return cReturn
