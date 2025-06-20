#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSV070.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV07*   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � dados cadastrais do cliente.                                ���
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
���Programa  �PWSV070   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Grava o codigo do cliente na session do vendedor            ���
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
Web Function PWSV070()

Local cHtml := ""					//Pagina WEB
Local aVend	:= {}					//Array com as informacoes do vendedor

WEB EXTENDED INIT cHtml START "InSite"

aVend := GetUserVen()

HttpSession->CODVENERP := aVend[2][2]

cHtml += W_PWSV071()

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV071   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
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
Web Function PWSV071()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObjSeller						//Objeto WS - WSMTSELLERCUSTOMER
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV071APH := { 	STR0002	,;         			//Gerenciamento de Informacoes - Busca CLIENTES
								"W_PWSV072.APW" }			//Pagina para onde sera enviado o POST

//�������������������������������������������Ŀ
//�Inicializa o objeto WS - WSMTSELLERCUSTOMER�
//���������������������������������������������
oObjSeller := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgUrl( @oObjSeller, "MTSELLERCUSTOMER.apw" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV071HEADER )
	HttpSession->PWSV071HEADER := { NIL, NIL, NIL, NIL, NIL, NIL }
	
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
	If Empty( HttpSession->PWSV071HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjSeller:cHEADERTYPE := "CUSTOMERVIEW"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV071HEADER[1] := { oObjSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0011		,;  	//Atencao
								 "", "W_PWSV070.APW" )
		EndIf
	EndIf
	
	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSV071HEADER[2] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV071HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0011		,;	//Atencao
								 "", "W_PWSV070.APW" )
		EndIf
	EndIf

	//���������������������������������Ŀ
	//�Header da estrutura GENERICVIEW2 �
	//|- CODE        : Codigo do Cliente|
	//|- UNIT        : Loja do Cliente  |
	//|- DESCRIPTION : Nome do Cliente  |
	//�����������������������������������
	If Empty( HttpSession->PWSV071HEADER[3] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjSeller:cHEADERTYPE := "GENERICVIEW2"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV071HEADER[3] := { oObjSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0011		,;	//Atencao
								 "", "W_PWSV070.APW" )
		EndIf
	EndIf

	//������������������������������������������Ŀ
	//�Header da estrutura ADDRESSVIEW - Endereco�
	//|- ADDRESS       : Endereco                |
	//|- ADDRESSNUMBER : Numero                  |
	//|- DISTRICT      : Cidade                  |
	//|- STATE         : Estado                  |
	//|- ZIPCODE       : CEP                     |
	//|- ZONE          : Bairro                  |
	//��������������������������������������������
	If Empty( HttpSession->PWSV071HEADER[4] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjSeller:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV071HEADER[4] := { oObjSeller:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0011		,;	//Atencao
								 "", "W_PWSV070.APW" )
		EndIf
	EndIf

	//����������������������������������������Ŀ
	//�Header da estrutura PHONEVIEW - Telefone�
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//������������������������������������������
	If Empty( HttpSession->PWSV071HEADER[5] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjSeller:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV071HEADER[5] := { oObjSeller:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0011		,;	//Atencao
								 "", "W_PWSV070.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SA1�
//�����������������������
If Empty( HttpSession->PWSV071INDEX )
	HttpSession->PWSV071INDEX := {}
	
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
		HttpSession->PWSV071INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0011		,; //Atencao
							 "", "W_PWSV070.APW" )
	EndIf
EndIf

//������������������������������������Ŀ
//�Dados para montagem da Tela de Busca�
//��������������������������������������
If Empty( HttpSession->PWSV071BUSCA )
	HttpSession->PWSV071BUSCA := { {}, {} }
                          
	//��������������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSMTSELLERCUSTOMER�
	//����������������������������������������������������
	If ExistBlock( "PEV181" )
		aWebCols := ExecBlock( "PEV181", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "NICKNAME" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV071BUSCA[1], HttpSession->PWSV071HEADER[1][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEX( { 	HttpSession->PWSV071BUSCA[1]			, HttpSession->PWSV071HEADER[1][1]	,;
					MTSELLERCUSTOMER_CUSTOMERVIEW():New()	, 	aWebCols						,;
					.T.										, "A",, 0 },"MTSELLERCUSTOMER")
	
	aWebCols := {}
                                 
	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV181" )
		aWebCols := ExecBlock( "PEV181", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSV071BUSCA[2], HttpSession->PWSV071HEADER[2][1], aWebCols )

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEX( { HttpSession->PWSV071BUSCA[2]		, HttpSession->PWSV071HEADER[2][1]	,;
					HttpSession->PWSV071INDEX[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV071" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV072   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de retorno da busca de clientes.                       ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �02/08/07�129642�-Passagem dos parametros nome do WS e Alias  ���
���          �        �      �na GridLinesEx() para que seja possivel	   ���
���          �        �      �iniciar o metodo que inclui os campos de     ���
���          �        �      �usuario no aHeader.                      	   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV072()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV072APH := { 	STR0003							,;	//Gerenciamento de Informacoes - Resultado da Busca CLIENTES
								"W_PWSV073.APW"					,;	//Pagina para onde sera enviado o POST
								"W_PWSV071.APW" }					//Pagina de volta do Resultado da Busca

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV072INFO := {}

//�������������������������������������������Ŀ
//�Inicializa o objeto WS - WSMTSELLERCUSTOMER�
//���������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgURL( @oObj, "MTSELLERCUSTOMER.APW" )

If !Empty( HttpPost->CNAME ) .OR. !Empty( HttpPost->CNICKNAME )
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
		HttpSession->PWSV072RESULT := { oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 }
	Else
		Return PWSHtmlAlert( "", STR0011		,;	//Atencao
							 "", "W_PWSV070.APW" )
	EndIf
Else
	//������������������������������������������������������������������������Ŀ
	//� Quando os parametros de busca estao vazios, limpa a variavel de sessao �
	//��������������������������������������������������������������������������
	HttpSession->PWSV072RESULT := {}
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV072RESULT ) .AND. Len( HttpSession->PWSV072RESULT[1] ) > 0
	aWebCols := {}
	                                    
	//�����������������������������������Ŀ
	//�Ponto de Entrada - Dados do Cliente�
	//�������������������������������������
	If ExistBlock( "PEV182" )
		aWebCols := ExecBlock( "PEV182", .F., .F., {} )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV072INFO,;
				HttpSession->PWSV071HEADER[3][1],;
				aWebCols,;
				HttpSession->PWSV072RESULT[1] )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEX( { 	HttpSession->PWSV072INFO		, HttpSession->PWSV071HEADER[3][1]	,;
					HttpSession->PWSV072RESULT[1]	, aWebCols							,;
					.F.								, "A",, 0 },"MTSELLERCUSTOMER", "SA1" )
Else
	Return PWSHtmlAlert( "", STR0011	,;	//Atencao
						 STR0004		,;	//A busca nao retornou nenhum cliente cadastrado para este vendedor.
						 "W_PWSV071.APW" )
EndIf

cHtml += ExecInPage( "PWSV072" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV073   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com os dados do contato selecionado.                   ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �02/08/07�129642�-Passagem dos parametros nome do WS e Alias  ���
���          �        �      �na GridLinesEx() para que seja possivel	   ���
���          �        �      �iniciar o metodo que inclui os campos de     ���
���          �        �      �usuario no aHeader.                      	   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV073()

Local cHtml 		:= ""						//Pagina WEB
Local nI 			:= 0						//Variavel de apoio
Local nPosEnd		:= 0						//Posicao do tipo do endereco dentro do array de Enderecos do Contato
Local nPosTel		:= 0						//Posicao do tipo do telefone dentro do array de Telefones do Contato
Local aWebCols 		:= {}						//Array contendo os campos que serao utilizados na tela
Local oObj										//Objeto WS - WSMTSELLERCUSTOMER

WEB EXTENDED INIT cHtml START "InSite"

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSV073APH := { 	""				,;			//Titulo da pagina
								"W_PWSV074.APW"	,;			//Pagina para onde sera enviado o POST
								"W_PWSV071.APW" }			//Pagina de Volta

//�����������������������������������Ŀ
//�Session de armazenagem do objeto WS�
//�������������������������������������
HttpSession->PWSV073RESULT := {}

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSV073INFO := { {}, {}, {} }

//������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMER�
//��������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgUrl( @oObj, "MTSELLERCUSTOMER.APW" )

//����������������������������������������������������������������Ŀ
//�Array com os tipos de informacoes que serao apresentados na tela�
//�Ex: Tipo de Telefone, Tipos de Endereco, etc.                   �
//������������������������������������������������������������������
If Empty( Httpsession->PWSV072TYPES )
	Httpsession->PWSV072TYPES := { NIL, NIL }
	
	//�������������������
	//�Tipos de Endereco�
	//�������������������
	If Empty( Httpsession->PWSV072TYPES[1] )
		If oObj:GETTYPEOFADDRESS()
			//����������������������������������Ŀ
			//�Retorno do metodo GETTYPEOFADDRESS�
			//������������������������������������
			Httpsession->PWSV072TYPES[1] := { oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0011		,;	//Atencao
								 "", "W_PWSV073.APW" )
		EndIf
	EndIf
	
	//�������������������
	//�Tipos de Telefone�
	//�������������������
	If Empty( Httpsession->PWSV072TYPES[2] )
		If oObj:GETTYPEOFPHONE()
			//��������������������������������Ŀ
			//�Retorno do metodo GETTYPEOFPHONE�
			//����������������������������������
			Httpsession->PWSV072TYPES[2] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0011		,;	//Atencao
								 "", "W_PWSV073.APW" )
		EndIf
	EndIf
EndIf


HttpSession->PWSV073APH[1] := STR0005	; 			//"Gerenciamento de Informacoes - Dados Cadastrais: "
							 + HttpGet->cNAME

//��������������������������������Ŀ
//�Parametros do metodo GETCUSTOMER�
//����������������������������������
oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cCUSTOMERID	:= HttpGet->cCUSTOMERID

//cUSERCODE,cSELLERCODE,cCUSTOMERID
If oObj:GETCUSTOMER()
	//�����������������������������Ŀ
	//�Retorno do metodo GETCUSTOMER�
	//�������������������������������
	HttpSession->PWSV073RESULT := { oObj:oWSGETCUSTOMERRESULT }
Else
	Return PWSHtmlAlert( "", STR0011		,;	//Atencao
						 "", "W_PWSV073.APW" )
EndIf

	
//�������������������Ŀ
//�Endereco do Cliente�
//���������������������
For nI := 1 To Len( Httpsession->PWSV072TYPES[1][1] )
	If Empty( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		nPosEnd := 0
	Else
		nPosEnd := aScan( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, { |x| x:cTYPEOFADDRESS == Str( nI, 1 ) } )
	EndIf
	
	If nPosEnd == 0
		aAdd( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, MTSELLERCUSTOMER_ADDRESSVIEW():New() )
		aTail( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW ):cTYPEOFADDRESS := Str( nI, 1 )
	EndIf
Next nI

//��������������������Ŀ
//�Telefones :         �
//�Comercial   - Tipo 1�
//�FAX         - Tipo 2�
//�Celular     - Tipo 3�
//|Residencial - Tipo 4|
//����������������������
For nI := 1 To Len( Httpsession->PWSV072TYPES[2][1] )
	If Empty( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		nPosTel := 0
	Else
		nPosTel := aScan( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW, { |x| x:cTYPEOFPHONE == Str( nI, 1 ) } )
	EndIf

	If nPosTel == 0
		aAdd( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW, MTSELLERCUSTOMER_PHONEVIEW():New() )
		aTail( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW ):cTYPEOFPHONE := Str( nI, 1 )
	EndIf
Next nI

//����������������������������Ŀ
//�Telefones ordenado pelo Tipo�
//������������������������������
HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//�����������������������������������Ŀ
//�Ponto de Entrada - Dados do Cliente�
//�������������������������������������
If ExistBlock( "PEV073" )
	aWebCols := ExecBlock( "PEV073", .F., .F., { 1 } )
Else
	aAdd( aWebCols, "CUSTOMERCODE" )
	aAdd( aWebCols, "UNITCUSTOMERCODE" )
	aAdd( aWebCols, "NAME" )
	aAdd( aWebCols, "NICKNAME" )
	aAdd( aWebCols, "FEDERALID" )
	aAdd( aWebCols, "STATEID" )
	aAdd( aWebCols, "DISTRICTID" )
	aAdd( aWebCols, "HOMEPAGE" )
	aAdd( aWebCols, "EMAIL" )
EndIf

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV073INFO[1]		, HttpSession->PWSV071HEADER[1][1]	,;
				HttpSession->PWSV073RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 },"MTSELLERCUSTOMER", "SA1" )

aWebCols := {}

//��������������������������������������Ŀ
//�Ponto de Entrada - Endereco do Cliente�
//����������������������������������������
If ExistBlock( "PEV073" )
	aWebCols := ExecBlock( "PEV073", .F., .F., { 2 } )
Else
	aAdd( aWebCols, "ADDRESS" )
	aAdd( aWebCols, "ADDRESSNUMBER" )
	aAdd( aWebCols, "DISTRICT" )
	aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
										{ "CSTATE", "CCODE" };
									}, ;
									{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, "ZIPCODE" )
	aAdd( aWebCols, "ZONE" )
EndIf

For nI := 1 To Len( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	aAdd( HttpSession->PWSV073INFO[2], {} )
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV073INFO[2][nI]									, HttpSession->PWSV071HEADER[4][1]	,;
					HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	, aWebCols							,;
					.T.																, "H", Str( nI, 1 ), 2 }			,;
					"MTSELLERCUSTOMER", "SA1" )
Next nI

aWebCols := {}
     
//��������������������������������������Ŀ
//�Ponto de Entrada - Telefone do Cliente�
//����������������������������������������
If ExistBlock( "PEV073" )
	aWebCols := ExecBlock( "PEV073", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "COUNTRYAREACODE" )
	aAdd( aWebCols, "LOCALAREACODE" )
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSV073INFO[3], {} )

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV073INFO[3][1]							, HttpSession->PWSV071HEADER[5][1]	,;
				HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 }						,;
				"MTSELLERCUSTOMER", "SA1" )

aWebCols := {}

//��������������������������������������Ŀ
//�Ponto de Entrada - Telefone do Cliente�
//����������������������������������������
If ExistBlock( "PEV073" )
	aWebCols := ExecBlock( "PEV073", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSV073INFO[3], {} )
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV073INFO[3][nI]								,;
					HttpSession->PWSV071HEADER[5][1]							,;
					HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
					aWebCols													,;
					.T.															,;
					"H"															,;
					Str( nI, 1 )												,;
					IIf( nI <> Len( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) },;
					"MTSELLERCUSTOMER",;
					"SA1" 	)
Next nI

cHtml += ExecInPage( "PWSV073" )
	
WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV074   �Autor  �Luiz Felipe Couto    � Data �  21/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Inclusao ou alteracao do cliente.                           ���
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
Web Function PWSV074()

Local cHtml 	:= ""					//Pagina WEB
Local nI		:= 0					//Variavel de apoio
Local nLenAdd 	:= 0					//Tamanho do array de enderecos
Local nLenPho 	:= 0					//Tamanho do array de telefones
Local oObjSeller						//Objeto WS - WSMTSELLERCUSTOMER
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone

WEB EXTENDED INIT cHtml START "InSite"

//�����������������������������������������Ŀ
//�Inicializa Objeto WS - WSMTSELLERCUSTOMER�
//�������������������������������������������
oObjSeller := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgUrl( @oObjSeller, "MTSELLERCUSTOMER.APW" )

//��������������������������������������Ŀ
//�Inicializa Objeto WS - WSCFGVALIDATION�
//����������������������������������������
oCFGVal := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGVALIDATION' ), WSCFGVALIDATION():NEW() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//�������������������Ŀ
//�Verifica CNPJ / CGC�
//���������������������
If !Empty( HttpSession->PWSV073RESULT[1]:cFEDERALID )
	//�����������������������������������Ŀ
	//�Parametros do metodo CHECKFEDERALID�
	//�������������������������������������
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSV073RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		Return PWSHtmlAlert( "", STR0011		,;	//Atencao
							 "", "W_PWSV073.APW?cCUSTOMERID=" + HttpPost->cCUSTOMERID + "&cNAME=" + HttpPost->cNAME)
	EndIf
EndIf

//����������������������������������������������Ŀ
//�Armazena Informacoes do Cliente - CUSTOMERVIEW�
//������������������������������������������������
PWSSetObjToPost( HttpSession->PWSV073RESULT[1], HttpSession->PWSV071HEADER[1][1], HttpPost->aPost )

HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW := {}
HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW := {}

//���������������������������������������������������������Ŀ
//�Armazena Informacoes do Endereco do Cliente - ADDRESSVIEW�
//�����������������������������������������������������������
For nI := 1 To Len( Httpsession->PWSV072TYPES[1][1] )
	aAdd( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, MTSELLERCUSTOMER_ADDRESSVIEW():New() )
	
	HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS := Str( nI, 1 )

	PWSSetObjToPost( 	HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	,;
						HttpSession->PWSV071HEADER[4][1]								,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//�������������������������������������������������������Ŀ
//�Armazena Informacoes do Telefone do Cliente - PHONEVIEW�
//���������������������������������������������������������
For nI := 1 To Len( Httpsession->PWSV072TYPES[2][1] )
	aAdd( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW, MTSELLERCUSTOMER_PHONEVIEW():New() )

	HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE := Str( nI, 1 )

	PWSSetObjToPost( 	HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSV071HEADER[5][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//���������������������������������������������������������������
//�Clone do Objeto WS                                           |
//�Utilizado para a armazenagem da Session no Objeto de Gravacao�
//���������������������������������������������������������������
oObjClone := HttpSession->PWSV073RESULT[1]:CLONE()

//��������������������������������Ŀ
//�Parametros do metodo PUTCUSTOMER�
//����������������������������������
oObjSeller:cUSERCODE	:= GetUsrCode()
oObjSeller:cSELLERCODE	:= HttpSession->CODVENERP
oObjSeller:oWSCUSTOMER 	:= oObjClone

//�������������������Ŀ
//�Endereco do Cliente�
//���������������������
oObjSeller:oWSCUSTOMER:oWSADDRESSES := MTSELLERCUSTOMER_ARRAYOFADDRESSVIEW():New()

For nI := 1 To Len( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	If 	!Empty( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS ) .AND. ;
		!Empty( HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER )

		aAdd( oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW, MTSELLERCUSTOMER_ADDRESSVIEW():New() )
		nLenAdd := Len( oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW )
	
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cADDRESS		:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cADDRESSNUMBER	:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cDISTRICT		:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cSTATE			:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cTYPEOFADDRESS	:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cZIPCODE		:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE
		oObjSeller:oWSCUSTOMER:oWSADDRESSES:oWSADDRESSVIEW[nLenAdd]:cZONE			:= HttpSession->PWSV073RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE
	EndIf
Next nI

//�������������������Ŀ
//�Telefone do Cliente�
//���������������������
oObjSeller:oWSCUSTOMER:oWSPHONES := MTSELLERCUSTOMER_ARRAYOFPHONEVIEW():New()

For nI := 1 To Len( HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( oObjSeller:oWSCUSTOMER:oWSPHONES:oWSPHONEVIEW, MTSELLERCUSTOMER_PHONEVIEW():New() )
	nLenPho := Len( oObjSeller:oWSCUSTOMER:oWSPHONES:oWSPHONEVIEW )

	oObjSeller:oWSCUSTOMER:oWSPHONES:oWSPHONEVIEW[nLenPho]:cCOUNTRYAREACODE 	:= HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
	oObjSeller:oWSCUSTOMER:oWSPHONES:oWSPHONEVIEW[nLenPho]:cLOCALAREACODE 		:= HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
	oObjSeller:oWSCUSTOMER:oWSPHONES:oWSPHONEVIEW[nLenPho]:cPHONENUMBER 		:= HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
	oObjSeller:oWSCUSTOMER:oWSPHONES:oWSPHONEVIEW[nLenPho]:cTYPEOFPHONE			:= HttpSession->PWSV073RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
Next nI

//����������������������������Ŀ
//�Grava Informacoes do Cliente�
//������������������������������
//cUSERCODE,cSELLERCODE,oWSCUSTOMER
If oObjSeller:PUTCUSTOMER()
	HttpGet->cCUSTOMERID := oObjSeller:cPUTCUSTOMERRESULT

	Return PWSHtmlAlert( "", STR0011		,;		//Atencao
						STR0006				,; 		//Informacoes cadastradas com SUCESSO!
						 "W_PWSV073.APW?cCUSTOMERID=" + HttpPost->cCUSTOMERID + "&cNAME=" + HttpPost->cNAME )
Else
	Return PWSHtmlAlert( "", STR0011		,;	//Atencao
						 "", "W_PWSV073.APW?cCUSTOMERID=" + HttpPost->cCUSTOMERID + "&cNAME=" + HttpPost->cNAME )
EndIf

WEB EXTENDED END

Return cHtml
