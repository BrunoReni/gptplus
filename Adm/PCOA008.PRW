#include "pcoa008.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} PCOA008
Fun��o para cadastramento de unidade or�ament�ria.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Function PCOA008()

Private oBrowse := BrowseDef()

// Ativa browser.
oBrowse:Activate()

Return

/*/{Protheus.doc} BrowseDef
Defini��es do Browse

@author  Alison Kaique
@version P12.1.17
@since   27/11/2018
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('AMF')
	oBrowse:SetDescripton(STR0009)  // "Unidades Orcamentarias"

Return oBrowse

/*/{Protheus.doc} MenuDef
Menu para cadastramento de opera��es da planilha or�ament�ria.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA008')  // Retorna as op��es padr�es de menu.


/*/{Protheus.doc} ModelDef
Modelo para cadastramento de opera��es da planilha or�ament�ria.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AMF')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AMFModel', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descri��o do modelo de dados.
oModel:SetDescription(STR0001)

// Adiciona ao modelo um componente de formul�rio.
oModel:AddFields('AMFMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AMFMASTER'):SetDescription(STR0001)

// Configura chave prim�ria.
oModel:SetPrimaryKey({"AMF_FILIAL", "AMF_CODIGO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para cadastramento de opera��es da planilha or�ament�ria.

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA008')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AMF')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Define que a view ser� fechada ap�s a grava��o dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formul�rio (antiga enchoice).
oView:AddField('VIEW_AMF', oStruct, 'AMFMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibi��o.
oView:SetOwnerView('VIEW_AMF', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   09/04/2018
/*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()

If nOper != 1 .and. !PCOA008Usr()
	Help(,, 'Help',, STR0007, 1, 0)  // "Usu�rio sem acesso para manuten��o do cadastro de Unidade Or�ament�ria"
	lRet := .F.
Else
	If nOper == MODEL_OPERATION_DELETE
		lRet := PCOA008DEL()
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} PCOA008Usr
Verifica os usu�rios que tem acesso para efetuar altera��es referentes � unidade.

@author  Jair Ribeiro
@version P12
@since   11/04/2010
/*/
Function PCOA008Usr()
Local aUser := Separa(SuperGetMv("MV_PCOUNI",, "000000;000001"), ";")
Return (aScan(aUser, {|x| Alltrim(x) == RetCodUsr()}) > 0)


/*/{Protheus.doc} PCOA008DEL
Valida exclus�o de opera��o.

@author  Felipe Raposo
@version P12
@since   09/04/2018
/*/
Static Function PCOA008DEL

Local lRet       := .T.
Local aArea      := GetArea()
Local cQuery     := ""
Local cAliasTRB  := GetNextAlias()

cQuery := "SELECT max(AMY_CODUNI) UNIORC "
cQuery += " FROM " + RetSqlName("AMY")
cQuery += " WHERE "
cQuery += " AMY_FILIAL  = '" + xFilial("AMY") + "' "
cQuery += " AND AMY_CODUNI = '" + AMF->AMF_CODIGO + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(UNIORC) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())

If lRet
	cQuery := "SELECT max(AMP_CODUNI) UNIORC "
	cQuery += " FROM " + RetSqlName("AMP")
	cQuery += " WHERE "
	cQuery += " AMP_FILIAL  = '" + xFilial("AMP") + "' "
	cQuery += " AND AMP_CODUNI = '" + AMF->AMF_CODIGO + "' "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	If (cAliasTRB)->(!Eof() .and. RTrim(UNIORC) <> '')
		lRet := .F.
	EndIf
	(cAliasTRB)->(dbCloseArea())
EndIf

If !lRet
	Help(,, 'Help',, STR0010, 1, 0)  // "Unidade n�o pode ser exclu�da! Unidade vinculada a projeto do Planejamento"
EndIf

RestArea(aArea)

Return lRet


/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Felipe Raposo
@version P12
@since   09/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOI008(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)


/*/{Protheus.doc} PcoCadUOrc
Fun��o para inclusao unidade orcamentaria via consulta padrao botao incluir.

@author  Totvs
@version P12
@since   16/07/2020
/*/
Function PcoCadUOrc(cAlias, nRecno, nOpc)
Default cAlias := "AMF"
Default nRecno := 0
Default nOpc := 3

FWExecView (STR0009, 'PCOA008', nOpc, /*oDlg,  /*bCloseOnOk*/,  /*bOk*/,  /*nPercReducao*/,  /*aEnableButtons*/,  /*bCancel*/ )

Return
