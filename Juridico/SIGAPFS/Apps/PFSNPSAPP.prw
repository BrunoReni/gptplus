#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PFSNPSAPP.CH"
 
#DEFINE SW_SHOW	5	 // Mostra na posi��o mais recente da janela

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSNPSAPP
App de NPS com Dialog

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSNPSAPP(lMsgValid)
Local oDlg := Nil
Local oNPS := GsNps():New()

Default lMsgValid := .F.

	If (canOpenApp())
		oNps:setProductName("PreFatJuridico") // Chave Agrupadora do Produto

		If (oNps:canSendAnswer())
			// 1� Param: Nome da Aplica��o
			// 2� Param: Dialog. Caso vazio, pega a janela inteira
			// 6� Param: Nome do fonte caso seja diferente do App
			DEFINE MSDIALOG oDlg FROM 0,0 TO 33, 120 TITLE "NPS" Style 128

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( PfsNps( oDlg ) )
		EndIf
	Else
		If (lMsgValid)
			JurMsgErro(STR0001,, STR0002) // "O ambiente n�o est� preparado para utilizar os apps" //"Verifique a configura��o do Appserver."
		EndIf
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PfsNps( oDlg )
Chamada do APP dentro da Dialog

@param oDlg - Dialog de destino para App abrir

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PfsNps( oDlg )
	FWCallApp( "tecnps", oDlg, , , , "PFSNPSAPP")
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Chamada do APP dentro da Dialog

@param oWebChannel - WebChannel para enviar informa��o para o App
@param cType - "Tipo" da chamada na chamada Via App
@param cContent - Conteudo adicional recebido do App

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Do Case
		Case cType == "preLoad"
			appPreLoad(oWebChannel)
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} appPreLoad(oWebChannel)
Passa os par�metros de PreLoad para o App

@param oWebChannel - WebChannel para enviar informa��o para o App

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function appPreLoad(oWebChannel)
	// Para desenvolvimento trocar para PreFatDev
	// Para produ��o trocar para PreFatJuridico
	oWebChannel:AdvPLToJS( "setProdutoNPS", "PreFatJuridico") 
	oWebChannel:AdvPLToJS( "setURLEndpoint", "WSPfsMet/nps" )
	oWebChannel:AdvPLToJS( "setProductLabel", STR0003 ) //"TOTVS Pr� Faturamento de Servi�os"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} canOpenApp()
Verifica se � possivel chamar a rotina

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function canOpenApp()
Local lRet := .T.
Local cCfgAppEnv := GetPvProfString( "GENERAL", "APP_ENVIRONMENT", "-", GetAdv97() )
	lRet := (cCfgAppEnv != "-") .And. (GetBuild() >= "7.00.170117A-20190628")

	If (lRet .And. FindFunction("CanUseWebUI"))
		lRet := CanUseWebUI()
	EndIf
Return lRet
