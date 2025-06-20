#INCLUDE "PWSV110.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Sele��o de vendedor - Para agenda
Web Function PWSV110()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := {	STR0001 ,;	// Processamento de Pedidos //"Agenda"
										"W_PWSV111.APW"	,;				// Proxima Tela
										"" ,;	 								// Msg de Erro
										"110" }								// Fun��o chamadora
										
HttpSession->FONTES := {"W_PWSV110.APW","W_PWSV112.APW"}
	
If Len(HTTPPOST->PWSV020VEN) <= 1   

	HttpSession->PWSV020APH[3] := STR0002 //"N�o h� vendedores a consultar."
	cHtml += ExecInPage( "PWSV020" )
	
ElseIF Len(HTTPPOST->PWSV020VEN) = 2

	// Apenas 1 vendedor . Define a navega��o para pular a tela de sele��o de vendedores
	
	HTTPPOST->CODVENERP	:= HTTPPOST->PWSV020VEN[2][2]
	
	cHtml += W_PWSV111()

Else

	// Mais de 1 vendedores ? Chama tela de sele��o
	
	cHtml += ExecInPage( "PWSV020" )

Endif

WEB EXTENDED END

Return cHtml


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV111   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para busca/escolha de compromissos (Agenda)			   ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �24/03/06�95260 �- Corrigida a passagem de parametro para a   ���
���          �        �      �GridLinesEx() e a visualizacao dos registros ���
���          �        �      �da Agenda.                                   ���
���Cleber M. �29/12/06�116083�- Limpa as variaveis HttpSession para dar um ���
���          �        �      �refresh na tela de busca.                    ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV111()

Local cHtml 	:= ""							//Pagina Web
Local aWebCols 	:= {}							//Array contendo os campos a serem mostrados na tela
Local oObj 										//Objeto WS - WSFTSELLERCALENDAR
Local nX 		:= 0							//Variavel auxiliar em For...Next
Private cMsg 	:= ""							//Mensagem

WEB EXTENDED INIT cHtml START "InSite"


oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERCALENDAR' ), WSFTSELLERCALENDAR():NEW() )
WsChgUrl(@oObj,"FTSELLERCALENDAR.apw")

HttpSession->oTmp := NIL

HTTPSession->_BrwComp := {}
HTTPSession->_Comps   := {}

If HttpPost->CODVENERP != Nil
	HttpSession->_CODVEN := HttpPost->CODVENERP
	HttpSession->CODVENERP := HttpPost->CODVENERP
EndIf

HttpSession->HEADV110_1 := {}

If oObj:GETHEADER("CALENDARVIEW")
	HttpSession->HEADV110_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSV110.APW" ) //"Erro"
EndIf


If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil

	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWSV111" )

Else

	HTTPSession->_BrwComp := {}
	HTTPSession->_Comps   := {}
	
	If ExistBlock( "PEV111" )
		aWebCols := ExecBlock( "PEV111", .F., .F., {} )
	EndIf

	GridHeader(	HTTPSession->_BrwComp ,;
					HttpSession->HEADV110_1 ,;
					aWebCols )

	oObj:dDATEFROM	:= CtoD( HttpPost->DataDe )
	oObj:dDATETO 	:= CtoD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE	 	:= ""
	oObj:cINDEXKEY			:= "AD7_DATA"

	If oObj:BRWCALENDAR( GetUsrCode(), HttpSession->_CODVEN )

		HTTPSession->_Comps := oObj:oWSBRWCALENDARRESULT:oWSCALENDARVIEW
		
		For nX := 1 to Len(HTTPSession->_Comps)
			GridLinesEX( {	HTTPSession->_BrwComp ,;
							HttpSession->HEADV110_1,;
							HTTPSession->_Comps[nX] ,;
							aWebCols,.F.,"A",,0 } )
		Next nX

	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV110.APW" ) //"Erro"
	EndIf

EndIf

cHtml += ExecInPage( "PWSV111" )

WEB EXTENDED END

Return cHtml


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV112   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para manuten��o de compromissos (Agenda)			   ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �17/11/06�111492�Alteracao na montagem do aWebCols p/ permitir���
���          �        �      �consulta F3 nos campos Cliente e Prospect.   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV112()

Local cHtml := ""			//Pagina HTML
Local aWebCols := {}		//Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpGet->cAct )
	HttpPost->cAct := HttpGet->cAct
EndIf

HttpSession->DetalhesComiss := {}

Do Case
	Case HttpPost->cAct == "V"
	
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {1} )
		EndIf
	
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HTTPSession->_Comps[ val( HttpPost->radio ) ] ,;
						aWebCols, .F., "H",,0 } )

	Case HttpPost->cAct == "I"
		If Empty( HttpSession->oTmp )
			HttpSession->oTmp := { FTSELLERCALENDAR_CALENDARVIEW():NEW() }
		EndIf
		
		HttpSession->oTmp[1]:dEVENTDATE := Date()
		
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {2} )
		Else
			//���������������������������������������Ŀ
			//� Campos a serem apresentados na pagina �
			//�����������������������������������������
			aAdd(aWebCols, "SUBJECT")
			aAdd(aWebCols, "EVENTDATE")
			aAdd(aWebCols, "STARTTIME")
			aAdd(aWebCols, "ENDTIME")
			aAdd(aWebCols, "NOTE")
			aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
											{ "CCUSTOMERCODE", "CCODE" }, ;
											{ "CUNITCUSTOMERCODE", "CUNIT" } ;
											}, ;
											{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
			aAdd(aWebCols, "UNITCUSTOMERCODE") 
			aAdd(aWebCols, { "PROSPECTCODE", "N", { "BRWPROSPECT", ;
											{ "CPROSPECTCODE", "CPROSPECTCODE" }, ;
											{ "CUNITPROSPECTCODE", "CUNITPROSPECTCODE" } ;
											}, ;
											{ "CPROSPECTCODE", "CUNITPROSPECTCODE", "CNAME" } } )	
											
			aAdd(aWebCols, "UNITPROSPECTCODE") 
			aAdd(aWebCols, "OPORTUNITY")  
			aAdd(aWebCols, "CONTACT")
		EndIf
		
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HttpSession->oTmp[1] ,;
						aWebCols, .T., "H",,0 },"FTSELLERCALENDAR" )

		
	Case HttpPost->cAct == "A" 
	
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {3} )
		Else
			//���������������������������������������Ŀ
			//� Campos a serem apresentados na pagina �
			//�����������������������������������������
			aAdd(aWebCols, "SUBJECT")
			aAdd(aWebCols, "EVENTDATE")
			aAdd(aWebCols, "STARTTIME")
			aAdd(aWebCols, "ENDTIME")
			aAdd(aWebCols, "NOTE")
			aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
											{ "CCUSTOMERCODE", "CCODE" }, ;
											{ "CUNITCUSTOMERCODE", "CUNIT" } ;
											}, ;
											{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
			aAdd(aWebCols, "UNITCUSTOMERCODE") 
			aAdd(aWebCols, { "PROSPECTCODE", "N", { "BRWPROSPECT", ;
											{ "CPROSPECTCODE", "CPROSPECTCODE" }, ;
											{ "CUNITPROSPECTCODE", "CUNITPROSPECTCODE" } ;
											}, ;
											{ "CPROSPECTCODE", "CUNITPROSPECTCODE", "CNAME" } } )	
											
			aAdd(aWebCols, "UNITPROSPECTCODE") 
			aAdd(aWebCols, "OPORTUNITY")  
			aAdd(aWebCols, "CONTACT")
		EndIf
	
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HTTPSession->_Comps[ val( HttpPost->radio ) ] ,;
						aWebCols, .T., "H",,0 } )
	
	Case HttpPost->cAct == "E"
	
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {4} )
		EndIf         
	
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HTTPSession->_Comps[ val( HttpPost->radio ) ] ,;
						aWebCols, .F., "H",,0 } )
	OtherWise
		// Se n�o entrou em nada � erro, ent�o volto para a tela de consulta....
		Return W_PWSV111()
EndCase

cHtml += ExecInPage( "PWSV112" )

WEB EXTENDED END

Return cHtml


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV113   �Autor  �Luiz Felipe Couto    � Data �  27/04/04   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para manuten��o de compromissos (Agenda)			   ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �11/05/06�98456 �- Inicializada a variavel de objeto oTmp que ���
���          �        �      �sera usada na alteracao da agenda.           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV113()

Local cHtml := ""										//Pagina Web
Local oObj												//Objeto WS - WSFTSELLERCALENDAR
Local oTmp	:= FTSELLERCALENDAR_CALENDARVIEW():NEW()	//Objeto WS - FTSELLERCALENDAR_CALENDARVIEW

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERCALENDAR' ), WSFTSELLERCALENDAR():NEW() )
WsChgUrl(@oObj,"FTSELLERCALENDAR.apw")

Do Case
	Case HttpPost->cAct == "I"
		PWSSetObjToPost( HttpSession->oTmp[1], HttpSession->HEADV110_1, HttpPost->aPost )
		If oObj:PUTCALENDAR( GetUsrCode(), HttpSession->_CODVEN, HttpSession->oTmp[1] )
			Return PWSHTMLALERT( "", STR0004, STR0005 + oObj:cPUTCALENDARRESULT + STR0006, "W_PWSV110.APW" ) //"Aviso"###"Compromisso n�mero: "###" incluido com sucesso."
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV112.APW?cAct=I" ) //"Erro"
		EndIf
		
	Case HttpPost->cAct == "A"
		PWSSetObjToPost( oTmp, HttpSession->HEADV110_1, HttpPost->aPost )
		If oObj:PUTCALENDAR( GetUsrCode(), HttpSession->_CODVEN, oTmp )
			cMsg := STR0005 + oObj:cPUTCALENDARRESULT + STR0007 //"Compromisso n�mero: "###" alterado com sucesso."
			Return PWSHTMLALERT( "", STR0004, cMsg, "W_PWSV110.APW" ) //"Aviso"
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV111.APW" ) //"Erro"
		EndIf
	
	Case HttpPost->cAct == "E"
		If oObj:DELCALENDAR( GetUsrCode(), HttpSession->_CODVEN, HTTPSession->_Comps[ val( HttpPost->cPos ) ] )
			cMsg := STR0005 + oObj:cDELCALENDARRESULT + STR0008 //"Compromisso n�mero: "###" excluido com sucesso."
			Return PWSHTMLALERT( "", STR0004, cMsg, "W_PWSV110.APW" ) //"Aviso"
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV111.APW" ) //"Erro"
		EndIf
	
	OtherWise
		// Se n�o entrou em nada � erro, ent�o volto para a tela de consulta....
		Return W_PWSV111()
EndCase

cHtml += ExecInPage( "PWSV113" )

WEB EXTENDED END

Return cHtml
