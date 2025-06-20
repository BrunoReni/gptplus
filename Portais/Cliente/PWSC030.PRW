#INCLUDE "PWSC030.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------------------------
// Tela de Sele��o de Cliente
Web Function PWSC030A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSC020CLI	:= GetUserCli()

HttpSession->PWSC020APH := {	STR0002 ,;	// Processamento de Pedidos //"Produto x Cliente"
										"W_PWSC030.APW"	,;				// Proxima Tela
										"" }
	
If Len(HTTPPOST->PWSC020CLI) <= 1   

	HttpSession->PWSC020APH[3] := STR0003 //"N�o h� clientes a consultar."
	cHtml += ExecInPage( "PWSC020" )
	
ElseIF Len(HTTPPOST->PWSC020CLI) = 2

	// Apenas 1 cliente . Define a navega��o para pular a tela de sele��o de cliente
	
	HttpSession->CODCLIERP	:= HTTPPOST->PWSC020CLI[2][2]
	
	cHtml += W_PWSC030()

Else

	// Mais de 1 cliente ? Chama tela de sele��o de CLientes
	
	cHtml += ExecInPage( "PWSC020" )

Endif

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSC030   �Autor  �Microsiga           � Data �  03/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para chamar Grid de Produtos com a busca             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PORTAIS                                                    ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Andrea F. �14/03/06�94316 �Passagem de parametro com o nome do WS na   ���
���          �        �      �funcao GridLineEx() para ser possivel       ���
���          �        �      �iniciar o metodo que inclui os campos       ���
���          �        �      �de usuario no aheader.                      ���
���Cleber M. �04/05/06�97488 �Passagem do obj. HttpSession->PWSC030RESULT ���
���          �        �      �na GridHeader para permitir a visualizacao  ���
���          �        �      �dos campos incluidos via Ponto de Entrada.  ���
���Cleber M. �05/06/07�126084�Alteracao no aWebCols para permitir consul- ���
���          �        �      �ta F3 no campo Produto (PRODUCTCODE).       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Web Function PWSC030()

Local cHtml 	:= ""							//Pagina Web
Local oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCT' ), WSMTPRODUCT():New() )	//Objeto WS - WSMTPRODUCT
Local oIndex 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )	//Objeto WS - WSCFGDICTIONARY
Local aWebCols 	:= {}							//Array contendo os campos a serem mostrados na tela
Local cNomeWs	:= "MTPRODUCT"					//Nome do WebService utilizado

Private cMsg 	:= ""
Private aJsGrid := {}

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTPRODUCT.APW" )
WsChgUrl( @oIndex, "CFGDICTIONARY.APW" )

If Empty( HttpSession->PWSC030HEADER )
	HttpSession->PWSC030HEADER := { NIL, NIL }

	If oObj:GETHEADER( "PRODUCTVIEW" )
		HttpSession->PWSC030HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
	
	If oIndex:GETHEADER()
		HttpSession->PWSC030HEADER[2] := oIndex:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWSC030INDEX )
	HttpSession->PWSC030INDEX := {}
	
	If oIndex:GETINDEX( GetUsrCode(), "SB1" )
		HttpSession->PWSC030INDEX := oIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWSC030INFO )
	HttpSession->PWSC030INFO := { {}, {} }

	If ExistBlock( "PEC030" )
		aWebCols := ExecBlock( "PEC030", .F., .F., {1} )
	Else
		//����������������������������������������������Ŀ
		//� Define campos da tela / parametros de busca  �
		//������������������������������������������������
		aWebCols := {}
		aAdd( aWebCols, { "PRODUCTCODE", "N", { "GETCATALOG", ;
												{ "CPRODUCTCODE", "CPRODUCTCODE" } }, ;
												{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
														{ "CGROUPOFPRODUCT", "CGROUPCODE" };
													}, ;
													{ "CGROUPCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
														{ "CTYPEOFPRODUCT", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
	EndIf

	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWSC030INFO[1], HttpSession->PWSC030HEADER[1], aWebCols )
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEx( { HttpSession->PWSC030INFO[1], ;
				HttpSession->PWSC030HEADER[1], ;
				MTPRODUCT_PRODUCTVIEW():New(), ;
				aWebCols, .T., "A",, 0 },cNomeWs )
	
	aWebCols := {}
                                      
	If ExistBlock( "PEC030" )
		aWebCols := ExecBlock( "PEC030", .F., .F., {2} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWSC030INFO[2], HttpSession->PWSC030HEADER[2], aWebCols )
	
	GridLinesEx( { HttpSession->PWSC030INFO[2], ;
				HttpSession->PWSC030HEADER[2], ;
				HttpSession->PWSC030INDEX, ;
				aWebCols, .F., "A",, 0 },cNomeWs )
EndIf

HttpSession->PWSC030RESULT := {}
HttpSession->PWSC030BRW := {}
HttpSession->_030TEMPCTR := "1"

//������������������������������������������������Ŀ
//� Efetua a busca de produtos conforme parametros �
//��������������������������������������������������
If !Empty( HttpPost->CPRODUCTCODE ) .OR. !Empty( HttpPost->CDESCRIPTION ) .OR. ;
	!Empty( HttpPost->CDESCRIPTION ) .OR. !Empty( HttpPost->CTYPEOFPRODUCT ) .OR. ;
	!Empty( HttpPost->CGROUPOFPRODUCT )
	HttpSession->_030TEMPCTR := ""
	
	//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GETCATALOG( GetUsrCode(), HttpPost->CTYPEOFPRODUCT, HttpPost->CGROUPOFPRODUCT, IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" ), IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" ), 0, 0, "", IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, ) )
		HttpSession->PWSC030RESULT := oObj:oWSGETCATALOGRESULT:OWSPRODUCTVIEW
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC030.APW" ) //"Erro"
	EndIf
EndIf

//�������������������������������Ŀ
//� Controla o resultado da busca �
//���������������������������������
If !Empty( HttpSession->PWSC030RESULT )
                                            
	If ExistBlock( "PEC030" )
		aWebCols := ExecBlock( "PEC030", .F., .F., {3} )
	Else
		aWebCols := {}
		aadd( aWebCols, "PRODUCTCODE" )
		aadd( aWebCols, "DESCRIPTION" )
	EndIf                                             
	
	GridHeader( HttpSession->PWSC030BRW,;
				HttpSession->PWSC030HEADER[1],;
				aWebCols,;
				HttpSession->PWSC030RESULT )
	
	GridLinesEx( { HttpSession->PWSC030BRW, ;
				HttpSession->PWSC030HEADER[1], ;
				HttpSession->PWSC030RESULT, ;
				aWebCols, .F., "A",, 0 },cNomeWs )
EndIf

cHtml += ExecInPage( "PWSC030" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------------------------

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSC031   �Autor  �Microsiga           � Data �  03/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para chamar os detalhes do produto selecionado       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PORTAIS                                                    ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Andrea F. �14/03/06�94316 �Passagem de parametro com o nome do WS na   ���
���          �        �      �funcao GridLineEx() para ser possivel       ���
���          �        �      �iniciar o metodo que inclui os campos       ���
���          �        �      �de usuario no aheader.                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSC031()

Local cHtml 	:= ""
Local oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCT' ), WSMTPRODUCT():New() )
Local aWebCols 	:= {}
Local cNomeWs	:= "MTPRODUCT"

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTPRODUCT.apw" )

If Val(HttpPost->radio) <= 0
	cHtml += W_PWSC031()
Else
	If Empty( HttpSession->PWSC031HEADER )
		HttpSession->PWSC031HEADER := { {}, {}, {}, {} }
	EndIf

	If Empty( HttpSession->PWSC031HEADER[1] )
		If oObj:GETHEADER( "PRODUCTVIEW" )
			HttpSession->PWSC031HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWSC031HEADER[2] )
		If oObj:GETHEADER( "PRICEVIEW" )
			HttpSession->PWSC031HEADER[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWSC031HEADER[3] )
		If oObj:GETHEADER( "INVENTORYVIEW" )
			HttpSession->PWSC031HEADER[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
	
	If Empty( HttpSession->PWSC031HEADER[4] )
		If oObj:GETHEADER( "INVENTORYCUSTOMERVIEW" )
			HttpSession->PWSC031HEADER[4] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
	
	HttpSession->PWSC031INFO := { {}, {}, {}, {} }
                 
	If ExistBlock( "PEC031" )
		aWebCols := ExecBlock( "PEC031", .F., .F., {1} )
	Else
		aWebCols := {}
		aadd( aWebCols, "PRODUCTCODE" )
		aadd( aWebCols, "DESCRIPTION" )
		aadd( aWebCols, "SCIENCEDESCRIPTION" )
		aadd( aWebCols, "DESCRIPTIONMEASUREUNIT" )
		aadd( aWebCols, "DESCRIPTIONSECONDMEASUREUNIT" )
		aadd( aWebCols, "DESCRIPTIONTYPEOFPRODUCT" )
		aadd( aWebCols, "DESCRIPTIONGROUPOFPRODUCT" )
		aadd( aWebCols, "NCM" )
		aadd( aWebCols, "QUANTITYPERPACKAGE" )
		aadd( aWebCols, "ORDERPOINT" )
		aadd( aWebCols, "NETWEIGHT" )
		aadd( aWebCols, "GROSSWEIGHT" )
		aadd( aWebCols, "LEADTIME" )
		aadd( aWebCols, "TYPEOFLEADTIME" )
		aadd( aWebCols, "ECONOMICLOT" )
		aadd( aWebCols, "MINIMUMLOT" )
		aadd( aWebCols, "MINIMUMGRADE" )
		aadd( aWebCols, "TERMOFVALIDATY" )
		aadd( aWebCols, "BARCODE" )
		aadd( aWebCols, "STORAGELENGHT" )
		aadd( aWebCols, "STORAGEWIDTH" )
		aadd( aWebCols, "STORAGEHEIGHT" )
		aadd( aWebCols, "STORAGEMAXIMUMPILING" )
		aadd( aWebCols, "STANDARDWAREHOUSE" )
	EndIf                                             

	GridLinesEx( { HttpSession->PWSC031INFO[1], ;
				HttpSession->PWSC031HEADER[1], ;
				HttpSession->PWSC030RESULT[ Val( HttpPost->radio ) ], ;
				aWebCols, .F., "H",, 0 },cNomeWs )
	
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpSession->PWSC030RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE
		
	If oObj:GETPRICE()
		If ExistBlock( "PEC031" )
			aWebCols := ExecBlock( "PEC031", .F., .F., {2} )
		Else
			aWebCols := {}
		EndIf

		GridHeader(	HttpSession->PWSC031INFO[2], HttpSession->PWSC031HEADER[2], aWebCols )

		GridLinesEx( { HttpSession->PWSC031INFO[2], ;
					HttpSession->PWSC031HEADER[2], ;
					oObj:oWSGETPRICERESULT:oWSPRICEVIEW, aWebCols, .F., "A",, 0 },cNomeWs )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC030.APW" ) //"Erro"
	EndIf
	
	If oObj:GETIMAGE( GetUsrCode(), HttpSession->PWSC030RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE )
		HttpSession->_IMG_PROD := oObj:cGETIMAGERESULT
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC030.APW" ) //"Erro"
	EndIf
	
	If oObj:GETSTOCK( GetUsrCode(), HttpSession->PWSC030RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE, HttpSession->PWSC030RESULT[ Val( HttpPost->radio ) ]:cSTANDARDWAREHOUSE )
		aWebCols := {}
         
		If ExistBlock( "PEC031" )
			aWebCols := ExecBlock( "PEC031", .F., .F., {3} )
		Else
			aWebCols := {}
			aadd( aWebCols, "PRODUCTCODE" )
			aadd( aWebCols, "QUANTITY" )
			aadd( aWebCols, "CURRENCY" )
			aadd( aWebCols, "CURRENCYSIMBOL" )
			aadd( aWebCols, "TYPEOFBALANCE" )
			aadd( aWebCols, "DESCRIPTIONTYPEOFBALANCE" )
			aadd( aWebCols, "WAREHOUSE" )
		EndIf

		GridHeader(	HttpSession->PWSC031INFO[3], HttpSession->PWSC031HEADER[3], aWebCols )

		GridLinesEx( { HttpSession->PWSC031INFO[3], ;
					HttpSession->PWSC031HEADER[3], oObj:oWSGETSTOCKRESULT:OWSINVENTORYVIEW,;
					aWebCols, .F., "A",, 0 },cNomeWs )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC030.APW" ) //"Erro"
	EndIf

	cHtml += ExecInPage( "PWSC031" )

EndIf

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC031A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWSC031A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
// Tela de Sele��o de Cliente
Web Function PWSC032A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSC020CLI	:= GetUserCli()

HttpSession->PWSC020APH := {	STR0002 ,;	// Processamento de Pedidos //"Produto x Cliente"
										"W_PWSC032.APW"	,;				// Proxima Tela
										"" }
	
If Len(HTTPPOST->PWSC020CLI) <= 1   

	HttpSession->PWSC020APH[3] := STR0003 //"N�o h� clientes a consultar."
	cHtml += ExecInPage( "PWSC020" )
	
ElseIF Len(HTTPPOST->PWSC020CLI) = 2

	// Apenas 1 cliente . Define a navega��o para pular a tela de sele��o de cliente
	
	HttpSession->CODCLIERP	:= HTTPPOST->PWSC020CLI[2][2]
	
	cHtml += W_PWSC032()

Else

	// Mais de 1 cliente ? Chama tela de sele��o de CLientes
	
	cHtml += ExecInPage( "PWSC020" )

Endif

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSC032   �Autor  �Microsiga           � Data �  03/29/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para chamar Grid de Produtos com a busca             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PORTAIS                                                    ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Cleber M. �29/03/06�95126 �-Alterada para guardar o conteudo do cliente���
���          �        �      �default do Portal na variavel HttpSession-> ���
���          �        �      �CODCLIERP para ser usada no metodo 		  ���
���          �        �      �GetCatalog(). 					          ���
���          �        �      �-Alterado parametro da GridLinesEx de "H" p/���
���          �        �      �"A" corrigindo a exibicao dos produtos. 	  ���
���Cleber M. �11/06/07�126837�Alteracao no aWebCols para permitir consul- ���
���          �        �      �ta F3 no campo Produto (PRODUCTCODE).       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSC032()

Local cHtml		:= ""							//Pagina WEB
Local oObj		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCT' ), WSMTCUSTOMERPRODUCT():New() )	//Objeto WS - WSMTCUSTOMERPRODUCT
Local oIndex	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )	//Objeto WS - WSCFGDICTIONARY
Local aWebCols	:= {}							//Array contendo os campos que serao mostrados na tela
Private cMsg	:= ""							//Mensagem
Private aJsGrid	:= {}							//Array com os dados do Grid

WEB EXTENDED INIT cHtml START "InSite"

//�����������������������������������Ŀ
//� Pega o cliente default do Portal  �
//�������������������������������������
HTTPPOST->PWSC020CLI	:= GetUserCli()
If Len(HTTPPOST->PWSC020CLI) >= 2
	HttpSession->CODCLIERP	:= HTTPPOST->PWSC020CLI[2][2]
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC032.APW" ) //"N�o h� clientes a consultar."
EndIf

WsChgUrl( @oObj, "MTCUSTOMERPRODUCT.APW" )
WsChgUrl( @oIndex, "CFGDICTIONARY.APW" )

If Empty( HttpSession->PWSC032HEADER )
	HttpSession->PWSC032HEADER := { NIL, NIL }

	If oObj:GETHEADER( "PRODUCTVIEW" )
		HttpSession->PWSC032HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
	
	If oIndex:GETHEADER()
		HttpSession->PWSC032HEADER[2] := oIndex:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWSC032INDEX )
	HttpSession->PWSC032INDEX := {}
	
	If oIndex:GETINDEX( GetUsrCode(), "SB1" )
		HttpSession->PWSC032INDEX := oIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

//�����������������������������
//� Montagem da tela de busca �
//�����������������������������
If Empty( HttpSession->PWSC032INFO )
	HttpSession->PWSC032INFO := { {}, {} }
                                                                                 
	If ExistBlock( "PEC032" )
		aWebCols := ExecBlock( "PEC032", .F., .F., {1} )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "PRODUCTCODE", "N", { "GETCATALOG", ;
												{ "CPRODUCTCODE", "CPRODUCTCODE" } }, ;
												{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
														{ "CGROUPOFPRODUCT", "CGROUPCODE" };
													}, ;
													{ "CGROUPCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
														{ "CTYPEOFPRODUCT", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
	EndIf
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWSC032INFO[1], HttpSession->PWSC032HEADER[1], aWebCols )
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEx( { HttpSession->PWSC032INFO[1], ;
				HttpSession->PWSC032HEADER[1], ;
				MTCUSTOMERPRODUCT_PRODUCTVIEW():New(), ;
				aWebCols, .T., "A",, 0 } )
	
	aWebCols := {}
                                 
	If ExistBlock( "PEC032" )
		aWebCols := ExecBlock( "PEC032", .F., .F., {2} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWSC032INFO[2], HttpSession->PWSC032HEADER[2], aWebCols )
	
	GridLinesEx( { HttpSession->PWSC032INFO[2], ;
				HttpSession->PWSC032HEADER[2], ;
				HttpSession->PWSC032INDEX, ;
				aWebCols, .F., "A",, 0 } )
EndIf

HttpSession->PWSC032RESULT := {}
HttpSession->PWSC032BRW := {}
HttpSession->_030TEMPCTR := "1"

//������������������������������������������������Ŀ
//� Efetua a busca de produtos conforme parametros �
//��������������������������������������������������
If !Empty( HttpPost->CPRODUCTCODE ) .OR. !Empty( HttpPost->CDESCRIPTION ) .OR. ;
	!Empty( HttpPost->CDESCRIPTION ) .OR. !Empty( HttpPost->CTYPEOFPRODUCT ) .OR. ;
	!Empty( HttpPost->CGROUPOFPRODUCT )
	HttpSession->_030TEMPCTR := ""
	
	//cUSERCODE,cCUSTOMERID,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GETCATALOG( GetUsrCode(), HttpSession->CODCLIERP, HttpPost->CTYPEOFPRODUCT, HttpPost->CGROUPOFPRODUCT, IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" ), IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" ), 50, 0, "", IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, ) )
		HttpSession->PWSC032RESULT := { oObj:oWSGETCATALOGRESULT:OWSPRODUCTVIEW }
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC032.APW" ) //"Erro"
	EndIf
EndIf

//�������������������������������Ŀ
//� Controla o resultado da busca �
//���������������������������������
If !Empty( HttpSession->PWSC032RESULT )
                                     
	If ExistBlock( "PEC032" )
		aWebCols := ExecBlock( "PEC032", .F., .F., {3} )
	Else
		aWebCols := {}
		aadd( aWebCols, "PRODUCTCODE" )
		aadd( aWebCols, "DESCRIPTION" )
	EndIf

	GridHeader( HttpSession->PWSC032BRW, HttpSession->PWSC032HEADER[1], aWebCols )
	
	GridLinesEx( { HttpSession->PWSC032BRW, ;
				HttpSession->PWSC032HEADER[1], ;
				HttpSession->PWSC032RESULT[1][1], ;
				aWebCols, .F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSC032" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------------------------

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSC033   �Autor  �Microsiga           � Data �  03/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para chamar os detalhes do produto selecionado       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �PORTAIS                                                     ���
�������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Andrea F. �14/03/06�94316 �Passagem de parametro com o nome do WS na   ���
���          �        �      �funcao GridLineEx() para ser possivel       ���
���          �        �      �iniciar o metodo que inclui os campos       ���
���          �        �      �de usuario no aheader.                      ���
���Cleber M. �11/10/06�107039�Alterado parametro da GridLinesEx de "H" p/ ���
���          �        �      �"A" corrigindo a exibicao das tabelas de 	  ���
���          �        �      �preco, posicao em estoque e estoque em nosso���
���          �        �      �poder.                                   	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Web Function PWSC033()

Local cHtml 	:= ""								//Pagina HTML a executar
Local oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCT' ), WSMTCUSTOMERPRODUCT():New() )		//Objeto WS da classe WSMTCUSTOMERPRODUCT
Local aWebCols 	:= {}								//Array com os campos a exibir
Local cNomeWS	:= "MTCUSTOMERPRODUCT"				//Nome do WebService usado

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTCUSTOMERPRODUCT.apw" )

If Val(HttpPost->radio) <= 0
	cHtml += W_PWSC033()
Else
	If Empty( HttpSession->PWSC033HEADER )
		HttpSession->PWSC033HEADER := { {}, {}, {}, {} }
	EndIf

	If Empty( HttpSession->PWSC033HEADER[1] )
		If oObj:GETHEADER( "PRODUCTVIEW" )
			HttpSession->PWSC033HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWSC033HEADER[2] )
		If oObj:GETHEADER( "PRICEVIEW" )
			HttpSession->PWSC033HEADER[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWSC033HEADER[3] )
		If oObj:GETHEADER( "INVENTORYVIEW" )
			HttpSession->PWSC033HEADER[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
	
	If Empty( HttpSession->PWSC033HEADER[4] )
		If oObj:GETHEADER( "INVENTORYVIEW" )
			HttpSession->PWSC033HEADER[4] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
	
	HttpSession->PWSC033INFO := { {}, {}, {}, {} }
                                           
	If ExistBlock( "PEC033" )
		aWebCols := ExecBlock( "PEC033", .F., .F., {1} )
	Else
		aWebCols := {}
		aadd( aWebCols, "PRODUCTCODE" )
		aadd( aWebCols, "DESCRIPTION" )
		aadd( aWebCols, "SCIENCEDESCRIPTION" )
		aadd( aWebCols, "DESCRIPTIONMEASUREUNIT" )
		aadd( aWebCols, "DESCRIPTIONSECONDMEASUREUNIT" )
		aadd( aWebCols, "DESCRIPTIONTYPEOFPRODUCT" )
		aadd( aWebCols, "DESCRIPTIONGROUPOFPRODUCT" )
		aadd( aWebCols, "NCM" )
		aadd( aWebCols, "QUANTITYPERPACKAGE" )
		aadd( aWebCols, "ORDERPOINT" )
		aadd( aWebCols, "NETWEIGHT" )
		aadd( aWebCols, "GROSSWEIGHT" )
		aadd( aWebCols, "LEADTIME" )
		aadd( aWebCols, "TYPEOFLEADTIME" )
		aadd( aWebCols, "ECONOMICLOT" )
		aadd( aWebCols, "MINIMUMLOT" )
		aadd( aWebCols, "MINIMUMGRADE" )
		aadd( aWebCols, "TERMOFVALIDATY" )
		aadd( aWebCols, "BARCODE" )
		aadd( aWebCols, "STORAGELENGHT" )
		aadd( aWebCols, "STORAGEWIDTH" )
		aadd( aWebCols, "STORAGEHEIGHT" )
		aadd( aWebCols, "STORAGEMAXIMUMPILING" )
		aadd( aWebCols, "STANDARDWAREHOUSE" )
	EndIf
	
	GridLinesEx( { HttpSession->PWSC033INFO[1], ;
				HttpSession->PWSC033HEADER[1], ;
				HttpSession->PWSC032RESULT[1][ Val( HttpPost->radio ) ], ;
				aWebCols, .F., "H",, 0 },cNomeWS )
		
	//cUSERCODE,cCUSTOMERID,cPRODUCTCODE,cQUERYADDWHERE
	If oObj:GETPRICE( GetUsrCode(), HttpSession->CODCLIERP, HttpSession->PWSC032RESULT[1][ Val( HttpPost->radio ) ]:cPRODUCTCODE )

		If ExistBlock( "PEC033" )
			aWebCols := ExecBlock( "PEC033", .F., .F., {2} )
		Else
			aWebCols := {}
		EndIf
	
		GridHeader(	HttpSession->PWSC033INFO[2], HttpSession->PWSC033HEADER[2], {} )

		GridLinesEx( { HttpSession->PWSC033INFO[2], ;
					HttpSession->PWSC033HEADER[2], ;
					oObj:oWSGETPRICERESULT:OWSPRICEVIEW, aWebCols, .F., "A",, 0 },cNomeWS )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC032.APW" ) //"Erro"
	EndIf
	
	//cUSERCODE,cCUSTOMERID,cPRODUCTCODE
	If oObj:GETIMAGE( GetUsrCode(), HttpSession->CODCLIERP, HttpSession->PWSC032RESULT[1][ Val( HttpPost->radio ) ]:cPRODUCTCODE )
		HttpSession->_IMG_PROD := oObj:cGETIMAGERESULT
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC032.APW" ) //"Erro"
	EndIf
	
	//cUSERCODE,cCUSTOMERID,cPRODUCTCODE,cWAREHOUSE
	If oObj:GETSTOCK( GetUsrCode(), HttpSession->CODCLIERP, HttpSession->PWSC032RESULT[1][ Val( HttpPost->radio ) ]:cPRODUCTCODE, HttpSession->PWSC032RESULT[1][ Val( HttpPost->radio ) ]:cSTANDARDWAREHOUSE )
		aWebCols := {}
                                       
		If ExistBlock( "PEC033" )
			aWebCols := ExecBlock( "PEC033", .F., .F., {3} )
		Else
			aWebCols := {}
			aadd( aWebCols, "PRODUCTCODE" )
			aadd( aWebCols, "QUANTITY" )
			aadd( aWebCols, "CURRENCY" )
			aadd( aWebCols, "CURRENCYSIMBOL" )
			aadd( aWebCols, "TYPEOFBALANCE" )
			aadd( aWebCols, "DESCRIPTIONTYPEOFBALANCE" )
			aadd( aWebCols, "WAREHOUSE" )
		EndIf         

		GridHeader(	HttpSession->PWSC033INFO[3], HttpSession->PWSC033HEADER[3], aWebCols )

		GridLinesEx( { HttpSession->PWSC033INFO[3], ;
					HttpSession->PWSC033HEADER[3], oObj:oWSGETSTOCKRESULT:OWSINVENTORYVIEW,;
					aWebCols, .F., "A",, 0 },cNomeWS )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC032.APW" ) //"Erro"
	EndIf

	//cUSERCODE,cCUSTOMERID,cPRODUCTCODE,dINVENTORYDATE,nTYPEOFINVENTORY,cQUERYADDWHERE
	If oObj:GETINVENTORY( GetUsrCode(), HttpSession->CODCLIERP, HttpSession->PWSC032RESULT[1][ Val( HttpPost->radio ) ]:cPRODUCTCODE, Date() )
		aWebCols := {}
		          
		If ExistBlock( "PEC033" )
			aWebCols := ExecBlock( "PEC033", .F., .F., {4} )
		Else
			aWebCols := {}
		EndIf         		
		
		GridHeader(	HttpSession->PWSC033INFO[4], HttpSession->PWSC033HEADER[4], aWebCols )

		GridLinesEx( { HttpSession->PWSC033INFO[4], ;
					HttpSession->PWSC033HEADER[4], oObj:oWSGETINVENTORYRESULT:oWSINVENTORYVIEW,;
					aWebCols, .F., "A",, 0 },cNomeWS )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC032.APW" ) //"Erro"
	EndIf

	cHtml += ExecInPage( "PWSC033" )

EndIf

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC033A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWSC033A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC034()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERPRODUCT' ), WSMTCUSTOMERPRODUCT():New() )
WsChgUrl( @oObj, "MTCUSTOMERPRODUCT.apw" )

If !Empty( HttpPost->cProduto )
	HttpSession->PWSC034INFO := {}
	
	oObj:cUSERCODE			:= GetUsrCode()
	oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
	oObj:cPRODUCTCODE		:= HttpPost->cProduto
	oObj:dREGISTERDATEFROM	:= Date() - 365
	oObj:dREGISTERDATETO	:= Date()
	oObj:cTYPEOFMOVEMENT	:= HttpPost->cTipoMov

	//cUSERCODE,cCUSTOMERID,cPRODUCTCODE,dREGISTERDATEFROM,dREGISTERDATETO,cTYPEOFMOVEMENT,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE
	If oObj:BRWEXTERNALINVOICE()
		HttpSession->PWSC034RESULT := { oObj:oWSBRWEXTERNALINVOICERESULT:oWSEXTERNALINVOICEVIEW }
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWSC032.APW" ) //"Erro"
	EndIf
EndIf

cHtml := ExecInPage( "PWSC034" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC035()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWSC035" )

WEB EXTENDED END

Return cHtml
