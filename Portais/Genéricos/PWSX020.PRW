#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSX020.CH"        


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX02*   �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado ao         ���
���          � cadastro de usuarios                                        ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX020   �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra a tela de cadastro de usuarios                       ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX020()

Local cHtml := ""                        	

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSX020" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX020A  �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra a tela de cadastro de usuarios                       ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX020A()

Local cHtml := ""                        	

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSX020A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX020B  �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra a tela de cadastro de usuarios                       ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX020B()

Local cHtml := ""                        	

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSX020B" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX021   �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Grava novos usuarios                                        ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX021()

Local cHtml := ""
Local oObj
Local aChks := IIF( HttpGet->act == "E", { {}, {} }, UsrMntChk() )
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite" 

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())
WsChgUrl(@oObj,"USERPORTAL.apw")

oObj:cUSERCODE 		:= GetUsrCode()
oObj:oWSUSERPCODE 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("USERPORTAL_LOGINUSERSTRUCT"), USERPORTAL_LOGINUSERSTRUCT():New())

oObj:oWSUSERPCODE:oWSUSERACCESSES := Iif(FindFunction("GetAuthWs"), GetAuthWs("USERPORTAL_ARRAYOFLOGINACCESSESSTRUCT"), USERPORTAL_ARRAYOFLOGINACCESSESSTRUCT():New())
For nI := 1 To Len( aChks[2] )//direitos
	aAdd( oObj:oWSUSERPCODE:oWSUSERACCESSES:oWSLOGINACCESSESSTRUCT, Iif(FindFunction("GetAuthWs"), GetAuthWs("USERPORTAL_LOGINACCESSESSTRUCT"), USERPORTAL_LOGINACCESSESSTRUCT():New()) )
	oObj:oWSUSERPCODE:oWSUSERACCESSES:oWSLOGINACCESSESSTRUCT[nI]:cNAME		:= ""
	oObj:oWSUSERPCODE:oWSUSERACCESSES:oWSLOGINACCESSESSTRUCT[nI]:cWEBSRV	:= aChks[2][nI]
	oObj:oWSUSERPCODE:oWSUSERACCESSES:oWSLOGINACCESSESSTRUCT[nI]:cWKFAPV	:= ""//aChks[2][nI]//FSY - 06/10/2015
Next nI

oObj:oWSUSERPCODE:oWSUSERENTIRIES			:= Iif(FindFunction("GetAuthWs"), GetAuthWs("USERPORTAL_ARRAYOFLOGINENTIRYSTRUCT"), USERPORTAL_ARRAYOFLOGINENTIRYSTRUCT():New())
For nI := 1 To Len( aChks[1] )//Cliente e Fornecedor
	aAdd( oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT, Iif(FindFunction("GetAuthWs"), GetAuthWs("USERPORTAL_LOGINENTIRYSTRUCT"), USERPORTAL_LOGINENTIRYSTRUCT():New()) )
	oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT[nI]:cENTIRY		:= IIF( SubStr( aChks[1][nI], 1, 1 ) == "C", "SA1", "SA2" )
	oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT[nI]:cFEDERALID	:= ""
	oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT[nI]:cID_ENTIRY	:= SubStr( aChks[1][nI], 2 )
	oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT[nI]:cNAME		:= ""
	oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT[nI]:cNICKNAME	:= ""
	oObj:oWSUSERPCODE:oWSUSERENTIRIES:oWSLOGINENTIRYSTRUCT[nI]:cSKIN		:= HttpPost->SKIN 
Next nI

oObj:oWSUSERPCODE:cUSERCODE			:= IIF( HttpGet->act == "E", HttpSession->_aUsuario[Val( HttpPost->CODUSU )]:cUSERCODE, HttpGet->CodUsu )
oObj:oWSUSERPCODE:cUSERGROUP		:= IIF( HttpPost->sel_Pivilevio == "2", HttpPost->sel_Grupo, "" )
oObj:oWSUSERPCODE:cUSERLOGIN		:= IIF( HttpGet->act == "E", HttpSession->_aUsuario[Val( HttpPost->CODUSU )]:cUSERLOGIN,AllTrim( HttpSession->USR_INFO[1]:cUSERLOGIN ) + "." + alltrim(HttpPost->txt_Usuario) )
oObj:oWSUSERPCODE:cUSERNAME			:= IIF( HttpGet->act == "E", HttpSession->_aUsuario[Val( HttpPost->CODUSU )]:cUSERNAME, HttpPost->txt_Nome )
oObj:oWSUSERPCODE:cUSERPASSWORD		:= IIF( HttpGet->act == "E", HttpSession->_aUsuario[Val( HttpPost->CODUSU )]:cUSERPASSWORD, HttpPost->txt_Senha )
oObj:oWSUSERPCODE:nUSERROLES		:= IIF( HttpGet->act == "E", HttpSession->_aUsuario[Val( HttpPost->CODUSU )]:nUSERROLES, Val( HttpPost->sel_Pivilevio ) )
oObj:oWSUSERPCODE:cUSEREMAIL		:= IIF( HttpGet->act == "E", HttpSession->_aUsuario[Val( HttpPost->CODUSU )]:cUSERNAME, HttpPost->txt_Email )
oObj:oWSUSERPCODE:cUSERSKIN			:= HttpPost->SKIN

//cUSERCODE,oWSUSERPCODE
If oObj:PRTPUTUSER()
	Return PWSHTMLALERT( "", STR0001, STR0002, "W_PWSX024.APW" ) //"Alerta" grava��o efetuada com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSX020.APW" ) //"Erro"
Endif    

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX022   �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra a tela de alteracao de senha                         ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX022( cMensagem )

Local cHtml := ""

Private cMsg := IIF( !Empty( cMensagem ), cMensagem, "" )

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSX022" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX023   �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Altera a senha do usuario                                   ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX023()

Local cHtml := ""

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())

	WsChgUrl(@oObj,"USERPORTAL.apw")
	
	If AllTrim( GetUsrSenha() ) != HttpPost->txt_Senha
		Return PWSHTMLAlert( "", STR0003, STR0004, "W_PWSX022.APW" ) //"Erro"###"Senha n�o confere"
	Endif
	
	//cUSERCODE,cUSEROLDPASSWORD,cUSERPASSWORD
	If oObj:PRTPSWUSER( GetUsrCode(), AllTrim(GetUsrSenha()), HttpPost->txt_NovaSenha )
		If !SetUsrSenha( HttpPost->txt_NovaSenha )
			HttpFreeSession()
		Endif

		Return PWSHTMLAlert( "", STR0005, STR0006, "W_PWSX022.APW" ) //"Altera��o de Senha"###"Confirma��o de Grava��o"
	Else
		Return PWSHTMLAlert( "", STR0003, "", "W_PWSX022.APW" ) //"Erro"
	Endif

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSX024   �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Consulta os usuarios cadastrados no sistema                 ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSX024()

Local cHtml := ""
Local oObj
Local aHeaderComp := {}
Local aHeader := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPORTAL"), WSUSERPORTAL():New())
WsChgUrl( @oObj, "USERPORTAL.apw" )

HttpPost->aUsuario := {}
HttpPost->cMsg := ""

If oObj:PRTHEADER( "LOGINUSERSTRUCT" )
	aHeaderComp := oObj:oWSPRTHEADERRESULT:oWSBRWHEADER

	If oObj:PRTGETGROUP( HttpSession->USR_INFO[1]:CUSERCODE )
		If Len( oObj:oWSPRTGETGROUPRESULT:oWSLOGINUSERSTRUCT ) == 0
			cHtml += ExecInPage( "PWSX020" )
		Else
			HttpSession->_aUsuario := oObj:oWSPRTGETGROUPRESULT:oWSLOGINUSERSTRUCT
			
			aadd(aHeader,"USERCODE") //NAO PODE SER APAGADO
			aadd(aHeader,"USERNAME") 
			aadd(aHeader,"USERGROUP")
			
			GridHeader(	HttpPost->aUsuario ,;
							aHeaderComp,;
							aHeader )
			
			GridLinesEx(	{ HttpPost->aUsuario ,;
							aHeaderComp,;
							oObj:oWSPRTGETGROUPRESULT:oWSLOGINUSERSTRUCT ,;
							aHeader, .F., "A", ,0 }  )
		     
		     cHtml += ExecInPage( "PWSX023" )
	     Endif
	
	Else

		HttpPost->cMsg := PWSGetWSError() 
		cHtml += ExecInPage( "PWSX023" )
	Endif
Endif

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �UsrMntChk �Autor  �Luiz Felipe Couto    � Data �  29/08/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Desmonta os checkbuttons enviados por POST                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function UsrMntChk()

Local nI := 0
Local nTam := Len( HttpPost->aPost )

Local aRet := { {}, {} }

For nI := 1 To nTam

	If Upper( SubStr( HttpPost->aPost[nI], 1, 4 ) ) == "CHKC"
		aAdd( aRet[1], "C"+SubStr( HttpPost->aPost[nI], 5 ) )
	ElseIf Upper( SubStr( HttpPost->aPost[nI], 1, 4 ) ) == "CHKF"
		aAdd( aRet[1], "F"+SubStr( HttpPost->aPost[nI], 5 ) )
	ElseIf Upper( SubStr( HttpPost->aPost[nI], 1, 4 ) ) == "CHKD"
		aAdd( aRet[2], SubStr( HttpPost->aPost[nI], 5 ) )
	Endif

Next

Return aRet
