#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV220.CH"
#INCLUDE "APWEBEX.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV22*   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a ficha    ���
���          � cadastral do cliente.                                       ���
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
���Programa  �PWSV220   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os vendedores disponiveis para o usuario logado.     ���
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
Web Function PWSV220()

Local cHtml := ""					//Pagina WEB
Local aVend	:= {}					//Array de vendedores cadastrados para o usuario logado

WEB EXTENDED INIT cHtml START "InSite"

//��������������������������������������������Ŀ
//�Vendedores cadastrados para o usuario logado�
//����������������������������������������������
aVend := GetUserVen()

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV020APH	:= { 	STR0001			,;			//Ficha cadastral
								"W_PWSV221.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002					//Nao ha vendedores a consultar
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV221()

	//��������������������
	//�Mais de 1 vendedor�
	//��������������������
	Otherwise
		cHtml += ExecInPage( "PWSV020" )

EndCase

cHtml += ExecInPage( "PWSV020" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV221   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de apresentacao da busca do cliente.                   ���
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
Web Function PWSV221()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObjSeller						//Objeto WS - WSMTSELLERCUSTOMER
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV221APH := { 	STR0003		,; 						//Ficha Cadastral - Busca CLIENTES
								"W_PWSV222.APW" }						//Pagina para onde sera enviado o POST

//�������������������������������������������Ŀ
//�Inicializa o objeto WS - WSMTSELLERCUSTOMER�
//���������������������������������������������
oObjSeller 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgUrl( @oObjSeller, "MTSELLERCUSTOMER.apw" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )


//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV221HEADER )
	HttpSession->PWSV221HEADER := { NIL, NIL, NIL, NIL, NIL, NIL }
	
	//������������������������������������������Ŀ
	//�Header da estrutura CUSTOMERVIEW - Cliente�
	//�- CUSTOMERCODE     : Codigo               �
	//�- UNITCUSTOMERCODE : Loja                 �
	//�- NAME             : Nome                 �
	//�- NICKNAME         : Nome Fantasia        �
	//�- FEDERALID        : CNPJ                 �
	//�- STATEID          : IE                   �
	//�- DISTRICTID       : Municipio            �
	//�- HOMEPAGE         : HomePage             �
	//�- EMAIL            : E-mail               �
	//��������������������������������������������
	If Empty( HttpSession->PWSV221HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjSeller:cHEADERTYPE := "CUSTOMERVIEW"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV221HEADER[1] := { oObjSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0004		,;		//Atencao
								 "", "W_PWSV220.APW" )
		EndIf
	EndIf
	
	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSV221HEADER[2] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV221HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0004		,;	//Atencao
								 "", "W_PWSV220.APW" )
		EndIf
	EndIf

	//���������������������������������Ŀ
	//�Header da estrutura GENERICVIEW2 �
	//|- CODE        : Codigo do Cliente|
	//|- UNIT        : Loja do Cliente  |
	//|- DESCRIPTION : Nome do Cliente  |
	//�����������������������������������
	If Empty( HttpSession->PWSV221HEADER[3] )
		If oObjSeller:GETHEADER( "GENERICVIEW2" )
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV221HEADER[3] := { oObjSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0004		,;	//Atencao
								 "", "W_PWSV220.APW" )
		EndIf
	EndIf

EndIf

//���������������������Ŀ
//�Indices da Tabela SA1�
//�����������������������
If Empty( HttpSession->PWSV221INDEX )
	HttpSession->PWSV221INDEX := {}
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SA1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSV221INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0004		,;	//Atencao
							 "", "W_PWSV220.APW" )
	EndIf
EndIf

//������������������������������������Ŀ
//�Dados para montagem da Tela de Busca�
//��������������������������������������
If Empty( HttpSession->PWSV221BUSCA )
	HttpSession->PWSV221BUSCA := { {}, {} }
                          
	//��������������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSMTSELLERCUSTOMER�
	//����������������������������������������������������
	If ExistBlock( "PEV221" )
		aWebCols := ExecBlock( "PEV221", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "NICKNAME" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV221BUSCA[1], HttpSession->PWSV221HEADER[1][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV221BUSCA[1]			, HttpSession->PWSV221HEADER[1][1]	,;
					MTSELLERCUSTOMER_CUSTOMERVIEW():New()	, 	aWebCols						,;
					.T., "A",, 0 },"MTSELLERCUSTOMER" )
	
	aWebCols := {}
                                 
	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV221" )
		aWebCols := ExecBlock( "PEV221", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSV221BUSCA[2], HttpSession->PWSV221HEADER[2][1], aWebCols )

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV221BUSCA[2], HttpSession->PWSV221HEADER[2][1]	,;
					HttpSession->PWSV221INDEX[1], aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV221" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV222   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de retorno da busca de clientes.                       ���
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
Web Function PWSV222()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV222APH := { 	STR0005		, ;			//Ficha Cadastral - Resultado da Busca CLIENTES
								"W_PWSV223.APW"	, ;			//Pagina para onde sera enviado o POST
								"W_PWSV221.APW" }			//Pagina de volta do Resultado da Busca

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV222INFO := {}

//�������������������������������������������Ŀ
//�Inicializa o objeto WS - WSMTSELLERCUSTOMER�
//���������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgURL( @oObj, "MTSELLERCUSTOMER.APW" )

If !Empty( HttpGet->CNAME ) .OR. !Empty( HttpGet->CNICKNAME )
	HttpPost->CNAME 		:= HttpGet->CNAME
	HttpPost->CNICKNAME 	:= HttpGet->CNICKNAME
Endif

//��������������������������������Ŀ
//�Parametros do metodo BRWCUSTOMER�
//����������������������������������
oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:nPAGELEN		:= 0
oObj:nPAGEFIRST		:= 0
oObj:cNAMELIKE		:= IIf( !Empty( HttpPost->CNAME ), Upper( HttpPost->CNAME ), "" )
oObj:cNICKNAMELIKE	:= IIf( !Empty( HttpPost->CNICKNAME ), Upper( HttpPost->CNICKNAME ), "" )
oObj:cQUERYADDWHERE	:= ""
oObj:cINDEXKEY		:= HttpPost->CINDEX

//cUSERCODE,cSELLERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWCUSTOMER()
	//�����������������������������Ŀ
	//�Retorno do metodo BRWCUSTOMER�
	//�������������������������������
	HttpSession->PWSV222RESULT := { oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 }
Else
	Return PWSHtmlAlert( "", STR0004		,;	//Atencao
						 "", "W_PWSV220.APW" )
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV222RESULT ) .AND. Len( HttpSession->PWSV222RESULT[1] ) > 0
	aWebCols := {}
	                                    
	//�����������������������������������Ŀ
	//�Ponto de Entrada - Dados do Cliente�
	//�������������������������������������
	If ExistBlock( "PEV222" )
		aWebCols := ExecBlock( "PEV222", .F., .F., {} )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV222INFO, HttpSession->PWSV221HEADER[3][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEX( { 	HttpSession->PWSV222INFO		, HttpSession->PWSV221HEADER[3][1]	,;
					HttpSession->PWSV222RESULT[1]	, aWebCols							,;
					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "",STR0004		,; //Atencao
							STR0006		,; //A busca nao retornou nenhum cliente cadastrado para este vendedor.
						 "W_PWSV221.APW" )
EndIf

cHtml += ExecInPage( "PWSV222" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV223   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela da ficha cadastral do cliente.                         ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �01/08/07�129641�Concatenacao do titulo a exibir com o codigo ���
���          �        �      �do cliente. 								   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV223()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERCUSTOMERREGFORM
Local oObjRegForm						//Objeto WS - WSFINANCESELLERCUSTOMERREGFORM

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV223APH := { STR0007 + " " + HttpGet->cCUSTOMERID,; //Ficha Cadastral - Cliente 
							"W_PWSV222.APW?cNAME=" + HttpGet->cNAME + "&cNICKNAME=" + HttpGet->cNICKNAME }			//Pagina de volta do Resultado da Busca

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV223INFO := {}

//�������������������������������������������Ŀ
//�Inicializa o objeto WS - WSMTSELLERCUSTOMER�
//���������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERCUSTOMERREGFORM' ), WSFINANCESELLERCUSTOMERREGFORM():New() )
WsChgURL( @oObj, "FINANCESELLERCUSTOMERREGFORM.APW" )

//�������������������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESELLERCUSTOMERREGFORM�
//���������������������������������������������������������
oObjRegForm := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERCUSTOMERREGFORM' ), WSFINANCESELLERCUSTOMERREGFORM():New() )
WsChgUrl( @oObjRegForm, "FINANCESELLERCUSTOMERREGFORM.APW" )

//���������������������������������Ŀ
//�Header da estrutura REGFORMSTRUCT�
//�����������������������������������
If Empty( HttpSession->PWSV221HEADER[4] )
	If oObjRegForm:GETHEADER()
		//���������������������������Ŀ
		//�Retorno do Metodo GETHEADER�
		//�����������������������������
		HttpSession->PWSV221HEADER[4] := { oObjRegForm:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0004		,;	//Atencao
							 "", "W_PWSV220.APW" )
	EndIf
EndIf
	
oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cCUSTOMERID	:= HttpGet->cCUSTOMERID

//cUSERCODE,cSELLERCODE,cCUSTOMERID
If oObj:GETREGFORM()
	//����������������������������������Ŀ
	//�Ponto de Entrada - Ficha Cadastral�
	//������������������������������������
	If ExistBlock( "PEV223" )
		aWebCols := ExecBlock( "PEV223", .F., .F., {} )
	EndIf

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEX( { 	HttpSession->PWSV223INFO	, HttpSession->PWSV221HEADER[4][1]	,;
					oObj:oWSGETREGFORMRESULT	, aWebCols							,;
					.F., "H",, 0 },"FINANCESELLERCUSTOMERREGFORM" )
Else
	Return PWSHtmlAlert( "", STR0004		,;	//Atencao
						 "", "W_PWSV222.APW" )
EndIf

cHtml += ExecInPage( "PWSV223" )

WEB EXTENDED END

Return cHtml
