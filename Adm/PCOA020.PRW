#include "pcoa020.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} PCOA020
Fun��o para cadastramento de classes or�ament�rias.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Function PCOA020()

Private oBrowse := FwMBrowse():New()

// Ativa browser.
oBrowse:SetAlias('AK6')
oBrowse:SetDescripton(STR0001)  // "Cadastro de Classes Or�ament�rias"
oBrowse:Activate()

Return


/*/{Protheus.doc} MenuDef
Menu para cadastramento de classes or�ament�rias.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA020')


/*/{Protheus.doc} ModelDef
Modelo para cadastramento de classes or�ament�rias.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AK6')
Local oModel

// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AK6Model', /*bPreValid*/, /*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descri��o do modelo de dados.
oModel:SetDescription(STR0001)

// Adiciona ao modelo um componente de formul�rio.
oModel:AddFields('AK6MASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AK6MASTER'):SetDescription(STR0001)

// Configura chave prim�ria.
oModel:SetPrimaryKey({"AK6_FILIAL", "AK6_CODIGO"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ModelDef
View para cadastramento de classes or�ament�rias.

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA020')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AK6')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Define que a view ser� fechada ap�s a grava��o dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formul�rio (antiga enchoice).
oView:AddField('VIEW_AK6', oStruct, 'AK6MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibi��o.
oView:SetOwnerView('VIEW_AK6', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Felipe Raposo
@version P12.1.17
@since   10/04/2018
/*/
Static Function ValidPre(oModel)

Local lRet       := .T.
Local nOper      := oModel:getOperation()

If nOper == MODEL_OPERATION_DELETE
	lRet := A020ExclOK()
EndIf

Return lRet


/*/{Protheus.doc} PCOA020DEL
Valida exclus�o de classes or�ament�rias.

@author  Paulo Carnelossi
@version
@since   14/01/2009
/*/
Static Function A020ExclOK()

Local lRet       := .T.
Local aArea      := GetArea()
Local cQuery     := ""
Local cAliasTRB  := GetNextAlias()

// Verificar se utilizado na tabela de itens orcamentarios AK2.
cQuery := "SELECT max(AK2_CLASSE) CLASSE "
cQuery += " FROM " + RetSqlName("AK2")
cQuery += " WHERE "
cQuery += " AK2_FILIAL  = '" + xFilial("AK2") + "' "
cQuery += " AND AK2_CLASSE = '" + AK6->AK6_CODIGO + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(CLASSE) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())

// Verificar se utilizado na tabela de movimentos orcamentarios AKD.
If lRet
	cQuery := "SELECT max(AKD_CLASSE) CLASSE "
	cQuery += " FROM " + RetSqlName("AKD")
	cQuery += " WHERE "
	cQuery += " AKD_FILIAL  = '" + xFilial("AKD") + "' "
	cQuery += " AND AKD_CLASSE = '" + AK6->AK6_CODIGO + "' "
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

	If (cAliasTRB)->(!Eof() .and. RTrim(CLASSE) <> '')
		lRet := .F.
	EndIf
	(cAliasTRB)->(dbCloseArea())
EndIf

If !lRet
	Help(,, 'Help',, STR0008, 1, 0)  // "Classe orcamentaria nao pode ser excluida. Verifique planilha/movimento orcamentario."
EndIf

RestArea(aArea)

Return lRet


/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Felipe Raposo
@version P12
@since   10/04/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOI020(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
