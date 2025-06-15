#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "CTBA940.CH"

Function CTBA940()

//Atualização das configurações
CTBA940J()

If ReqMinimos()
    FWCallApp("ctba940")
EndIf

Return 

Static Function ReqMinimos ()

Local oBtnLink 
Local cMsg	     := ""
Local cTitle     := ""
Local cSubTitle  := ""
Local cLink      := ""
Local cVDBAccess := ""
Local lRet       := .T.

//Release
If  GetRPORelease() < "12.1.033" 
    cTitle    := STR0016 // ""Ambiente Desatualizado"
	cSubTitle := STR0009 // "Acesse o Portal do Cliente"
	cLink     := "https://suporte.totvs.com/portal/p/10098/download#000006/"
	
	cMsg += '<b>' + STR0001 + ' </b><br>' 	// "RPO está desatualizado"
    cMsg += ' ' + STR0002 + ' ' + GetRPORelease() + ' - ' + STR0003 + '12.1.033 <br><br>' 	//"Versão atual: " | "Versão mínima: "   	
EndIf
//DBAccess
cVDBAccess := TcVersion()
If cVDBAccess < "21.1.1.8"
	cTitle    := STR0016 // ""Ambiente Desatualizado"
	cSubTitle := STR0009 // "Acesse o Portal do Cliente"
	cLink     := "https://suporte.totvs.com/portal/p/10098/download#000006/"
	
	cMsg += '<b> '+ STR0007 + ' </b><br>'  	// DBAccess está desatualizado
	cMsg += ' ' + STR0002 + ' ' + cVDBAccess + "<br>" 	//"Versão atual: " | " Build: " 
	cMsg += ' ' + STR0003 + '21.1.1.8<br><br>'			//"Versão mínima: "###'ou maior igual a' 	
EndIf

//Configuracoes
If Empty(cMsg)
	//MultiprotocolPort
	//Por padrão a porta multiprotocolo vem ativa, caso a chave não exista, seu conteudo default é "1" (Ativa)
	If GetPvProfString("DRIVERS", "MULTIPROTOCOLPORT", "1", GetAdv97()) == "0"
		cTitle    := STR0017 // "Configurar Ambiente"
		cSubTitle := STR0015 // "Saiba mais"
		cLink     := "https://tdn.totvs.com/pages/viewpage.action?pageId=538506039"
		
		cMsg += '<b> '+ STR0012 + ' </b><br>' //"A porta multiprotocolo encontra-se desativada"
		cMsg += ' ' + STR0013 + "<br>"        //"Verifique as configurações da chave MultiProtocolPort no"
		cMsg += ' ' + STR0014 + "<br><br>"    //"appserver.ini"				
	EndIf

	//App_Environment
	If Empty(cMsg)
		If Empty(GetPvProfString("GENERAL", "APP_ENVIRONMENT", "", GetAdv97()))
			cTitle    := STR0017 // "Configurar Ambiente"
			cSubTitle := STR0015 // "Saiba mais"
			cLink     := "https://tdn.totvs.com/pages/viewpage.action?pageId=556382089"		
			
			cMsg += '<b> '+ STR0018 + ' </b><br>' //"A chave App_Environment encontra-se desabilitada"
			cMsg += ' ' + STR0019 + "<br>"        //"Verifique as configurações da chave App_Environment no"
			cMsg += ' ' + STR0014 + "<br><br>"    //"appserver.ini"				
		EndIf
	EndIf
EndIf

If !Empty(cMsg)
	DEFINE DIALOG oDlg TITLE cTitle FROM 180,180 TO 500,750 PIXEL
	// Cria fonte para ser usada no TSay
	oFont := TFont():New('Courier new',,-15,.T.)
   
	lHtml := .T.
	oSay := TSay():New(01,01,{||cMsg},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

	oBtnLink := TButton():New( 145, 5, cSubTitle, oDlg,, 150 ,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnLink:SetCSS("QPushButton {text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 0px;Text-align:left;font-size:16px}")
	oBtnLink:bLClicked := {|| ShellExecute("open", cLink,"","",3) }
	
	ACTIVATE DIALOG oDlg CENTERED

    lRet := .F.
EndIf
Return lRet 
