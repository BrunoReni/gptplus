#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA020.ch'

#DEFINE SOURCEFATHER "CTBA020"

//--------------------------------------------------
/*/{Protheus.doc} CTBA020RUS
Cadastro de Plano de Contas localizado para RUSSIA.

O fonte cont�m browse, menu, model e view propria, todos herdados do CTBA020. 
Qualquer regra que se aplique somente para a RUSSIA deve ser definida aqui.

As valida��es e integra��es realizadas ap�s/durante a grava��o devem ser definidas em eventos do modelo, 
criar como sugest�o a classe CTBA020EVRUS.

@type function
 
@author TOTVS
@since 09/08/2017
@version P12.1.18
/*/
//--------------------------------------------------
Function CTBA020RUS()
Local oBrowse := BrowseDef()

If 	oBrowse <> Nil
	oBrowse:Activate()
EndIf
	
Return

//--------------------------------------------------
/*/{Protheus.doc} BrowseDef
Tela de navegacao da rotina.

@author TOTVS
@since 24/07/2017
@version P12.1.18

@return objeto, definicoes do browse
/*/
//--------------------------------------------------
Static Function BrowseDef()
Local oBrowse := FWLoadBrw(SOURCEFATHER) 

Return oBrowse

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional.

@author TOTVS
@since 07/03/2007
@version P12.1.18

@return array, opcoes de menu da rotina
/*/
//--------------------------------------------------
Static Function MenuDef()
Local aRotina := FWLoadMenuDef(SOURCEFATHER)

If SuperGetMV("MV_CTRCTB",.F.,"2") == "1"
	ADD OPTION aRotina TITLE STR0067 ACTION "CTBA001" OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 //"Controles Cont�beis"
EndIf

Return aRotina

//--------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��es da interface grafica da rotina.

@author TOTVS
@since 25/07/2017
@version P12.1.18

@return objeto, interface grafica
/*/
//--------------------------------------------------
Static Function ViewDef()
Local oView := FWLoadView(SOURCEFATHER)

Return oView

//--------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��es do modelo de dados da rotina.

@author TOTVS
@since 25/07/2017
@version P12.1.18

@return objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function ModelDef()
Local oModel := FWLoadModel(SOURCEFATHER)

	oModel:InstallEvent("CTBA020EVRUS",, CTBA020EVRUS():New())

Return oModel