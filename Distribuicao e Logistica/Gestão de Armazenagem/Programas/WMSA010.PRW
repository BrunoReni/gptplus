#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA010.CH'

#define WMSA01001 "WMSA01001"
#define WMSA01002 "WMSA01002"

//------------------------------------------------------------------------------
/*/{Protheus.doc} WMSA010
Cadastro de Unitizadores de Armazenagem

Unitizadores sao estruturas que comportam o produto, considerando sua largura,
comprimento, altura, capacidade de carga e quantidade maxima para empilhamento.

@author Jackson Patrick Werka
@since 13/03/2017
@version 12.1.17
/*/
//------------------------------------------------------------------------------
Function WMSA010()
Local oBrowse := Nil

	// Compatibiliza a DC1 com a D0T quando n�o houver registros
	CompatD0T()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("D0T")
	oBrowse:SetMenuDef("WMSA010")   // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001) // Cadastro de Unitizadores de Armazenagem
	oBrowse:SetAmbiente(.F.)        // Desabilita op��o Ambiente do menu A��es Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita op��o WalkThru do menu A��es Relacionadas
	oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
// Fun��o MenuDef
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.WMSA010" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.WMSA010" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.WMSA010" OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.WMSA010" OPERATION 5 ACCESS 0 // Excluir
Return ( aRotina )

//------------------------------------------------------------------------------
// Fun��o ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   := MPFormModel():New('WMSA010', /*bPreValid*/ , { |oModel| PosVldMdl(oModel) } , /*bComValid*/ ,/*bCancel*/ )
	Local oStruD0T := FWFormStruct(1, 'D0T')

	oStruD0T:SetProperty('D0T_PADRAO',MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID, "StaticCall(WMSA010,ValidField,A,B,C)"))
	oModel:AddFields('D0TMASTER', /*cOwner*/, oStruD0T)
Return oModel

//------------------------------------------------------------------------------
// Fun��o ViewDef
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('WMSA010')
	Local oView    := FWFormView():New()
	Local oStruD0T := FWFormStruct(2, 'D0T')
	oView:SetModel(oModel)
	oView:AddField('VIEWD0T', oStruD0T, 'D0TMASTER')
Return oView

//------------------------------------------------------------------------------
// Fun��o PosVldMdl
//------------------------------------------------------------------------------
Static Function PosVldMdl(oModel)
	Local oMdlD0T := oModel:GetModel("D0TMASTER")
	Local lRet    := .T.
	Local cCtrNor := ""
	Local cCtrAlt := ""

	If ( oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() ==  MODEL_OPERATION_UPDATE )
		cCtrNor := oMdlD0T:GetValue("D0T_CTRNOR")
		cCtrAlt := oMdlD0T:GetValue("D0T_CTRALT")
		If (cCtrNor == "2" .And. cCtrAlt == "1")
			oModel:SetErrorMessage('D0TMASTER',,,,WMSA01001,STR0007,STR0008) // Para unitizadores que n�o controlam norma n�o � poss�vel controlar altura por: Produto x Camada. // O controle de altura ser� alterado para ser por unitizador.
			oMdlD0T:SetValue("D0T_CTRALT","2")
			lRet := .F.
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
// Fun��o ValidField
//------------------------------------------------------------------------------
Static Function ValidField(oModel,cField,xValue)
Local lRet   := .T.
Local cQuery := ""
Local cAliasQry := ""

	If cField == "D0T_PADRAO" .And. xValue == "1"
		cQuery := " SELECT 1 "
		cQuery +=   " FROM "+RetSqlName("D0T")
		cQuery +=  " WHERE D0T_FILIAL = '"+xFilial("D0T")+"'"
		cQuery +=    " AND D0T_CODUNI <> '"+oModel:GetValue("D0T_CODUNI")+"'"
		cQuery +=    " AND D0T_PADRAO = '1'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			oModel:GetModel():SetErrorMessage('D0TMASTER',,,,WMSA01002,WmsFmtMsg("J� existe Tipo de Unitizador padr�o definido para filial [VAR01].",{{"[VAR01]",xFilial("D0T")}})) // J� existe Tipo de Unitizador padr�o definido para filial [VAR01].
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Fun��o de compatibiliza��o da DC1 com a D0T
//------------------------------------------------------------------------------
Static Function CompatD0T()
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasD0T  := ""
Local cAliasQry  := ""
Local cFilD0T    := xFilial("D0T")

	// Valida se n�o h� dados na tabela de unitizadores WMS
	cQuery := " SELECT 1"
	cQuery +=   " FROM "+RetSqlName("D0T")+" D0T"
	cQuery +=  " WHERE D0T.D0T_FILIAL = '"+cFilD0T+"'"
	cQuery +=    " AND D0T.D_E_L_E_T_ = ' '"
	cAliasD0T := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasD0T,.F.,.T.)
	If (cAliasD0T)->(Eof())
		cQuery := " SELECT DC1.DC1_CODUNI,"
		cQuery +=        " DC1.DC1_DESUNI,"
		cQuery +=        " DC1.DC1_ALTMAX,"
		cQuery +=        " DC1.DC1_LRGMAX,"
		cQuery +=        " DC1.DC1_CMPMAX,"
		cQuery +=        " DC1.DC1_CAPMAX,"
		cQuery +=        " DC1.DC1_EMPMAX,"
		cQuery +=        " DC1.DC1_TARA"
		cQuery +=   " FROM "+RetSqlName("DC1")+" DC1"
		cQuery +=  " WHERE DC1.DC1_FILIAL = '"+xFilial("DC1")+"'"
		cQuery +=    " AND DC1.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		While !(cAliasQry)->(Eof())
			Reclock("D0T",.T.)
			D0T->D0T_FILIAL := cFilD0T
			D0T->D0T_CODUNI := (cAliasQry)->DC1_CODUNI
			D0T->D0T_DESUNI := (cAliasQry)->DC1_DESUNI
			D0T->D0T_ALTURA := (cAliasQry)->DC1_ALTMAX
			D0T->D0T_LARGUR := (cAliasQry)->DC1_LRGMAX
			D0T->D0T_COMPRI := (cAliasQry)->DC1_CMPMAX
			D0T->D0T_CAPMAX := (cAliasQry)->DC1_CAPMAX
			D0T->D0T_EMPMAX := (cAliasQry)->DC1_EMPMAX
			D0T->D0T_TARA   := (cAliasQry)->DC1_TARA
			D0T->D0T_CTRALT := '1'
			D0T->D0T_CTRNOR := '1'
			D0T->D0T_PADRAO := '1'
			D0T->(MsUnlock())
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	(cAliasD0T)->(DbCloseArea())

RestArea(aAreaAnt)
Return
