#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSV030.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV03*   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado ao         ���
���          � catalogo de produtos                                        ���
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
���Programa  �PWSV030   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
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
Web Function PWSV030()

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
HttpSession->PWSV020APH	:= { 	STR0002				,;      //Catalogo de Produtos
								"W_PWSV031.APW"			,;		//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0003		//Nao ha vendedores a consultar
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV031()

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
���Programa  �PWSV031   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de apresentacao da busca dos produtos.                 ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �18/05/06�98717 �Passagem de parametro com o nome do WS na    ���
���          �        �      �funcao GridLinesEx() para que seja possivel  ���
���          �        �      �iniciar o metodo que inclui os campos de     ���
���          �        �      �usuario no aHeader.                      	   ���
���Cleber M. �01/06/07�126843�Alteracao no aWebCols para permitir consulta ���
���          �        �      �F3 no campo Produto (PRODUCTCODE).           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV031()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols	:= {}				//Array contendo os campos que serao apresentados na tela
Local oObjProd						//Objeto WS - WSMTPRODUCT
Local oObjIndex						//Objeto WS - WSCFGDICTIONARY
Local cNomeWS	:= "MTPRODUCT"		//Nome do WS

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV031APH := { 	STR0004		,;				//Catalogo de Produtos - Busca"
								"W_PWSV032.APW" } 				//Pagina para onde sera enviado o POST

//����������������������������������Ŀ
//�Inicializa Objeto WS - WSMTPRODUCT�
//������������������������������������
oObjProd := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
WsChgUrl( @oObjProd, "MTPRODUCT.APW" )

//��������������������������������������Ŀ
//�Inicializa Objeto WS - WSCFGDICTIONARY�
//����������������������������������������
 oObjIndex := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV031HEADER )
	HttpSession->PWSV031HEADER := { NIL, NIL, NIL, NIL }

	//�����������������������������������������������������������������������Ŀ
	//�Header da estrutura PRODUCTVIEW - Produto                              �
	//|- PRODUCTCODE                  : Codigo                                |
	//|- DESCRIPTION                  : Descricao                             |
	//|- SCIENCEDESCRIPTION           : Descricao Cientifica                  |
	//|- MEASUREUNIT                  : Unidade de Medida                     |
	//|- DESCRIPTIONMEASUREUNIT       : Descricao da Unidade de Medida        |
	//|- SECONDMEASUREUNIT            : Segunda Unidade de Medida             |
	//|- DESCRIPTIONSECONDMEASUREUNIT : Descricao da Segunda Unidade de Medida|
	//|- TYPEOFPRODUCT                : Tipo                                  |
	//|- DESCRIPTIONTYPEOFPRODUCT     : Descricao do Tipo                     |
	//|- GROUPOFPRODUCT               : Grupo                                 |
	//|- DESCRIPTIONGROUPOFPRODUCT    : Descricao do Grupo                    |
	//|- NCM                          : Nomenclatura Ext. Mercosul            |
	//|- QUANTITYPERPACKAGE           : Quntidade por Embalagem               |
	//|- ORDERPOINT                   : Ponto de Pedido                       |
	//|- NETWEIGHT                    : Peso Liquido                          |
	//|- GROSSWEIGHT                  : Peso Bruto                            |
	//|- LEADTIME                     : Prazo de Entrega                      |
	//|- TYPEOFLEADTIME               : Tipo de Prazo de Entrega              |
	//|- ECONOMICLOT                  : Lote Economico                        |
	//|- MINIMUMLOT                   : Lote Minimo                           |
	//|- MINIMUMGRADE                 : Nota Minima                           |
	//|- TERMOFVALIDATY               : Termo de Validade                     |
	//|- BARCODE                      : Codigo de Barra                       |
	//|- STORAGELENGHT                : Comprimento da Armazenagem            |
	//|- STORAGEWIDTH                 : Largura da Armazenagem                |
	//|- STORAGEHEIGHT                : Altura da Armazenagem                 |
	//|- STORAGEMAXIMUMPILING         : Fator de Armazenamento                |
	//|- STANDARDWAREHOUSE            : Armazem                               |
	//�������������������������������������������������������������������������
	If Empty( HttpSession->PWSV031HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjProd:cHEADERTYPE := "PRODUCTVIEW"

		If oObjProd:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV031HEADER[1] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;	//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf
	
	//�������������������������������������������������������Ŀ
	//�Header da estrutura do GENERICVIEW2 - Consulta Generica�
	//|- CODE        : Ordem                                  |
	//|- DESCRIPTION : Chave                                  |
	//���������������������������������������������������������
	If Empty( HttpSession->PWSV031HEADER[2] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV031HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf

	//�����������������������������������������Ŀ
	//�Header da estrutura do PRICEVIEW         �
	//|- PRODUCTCODE     : Codigo do Produto    |
	//|- PAYMENTPLANCODE : Condicao de Pagamento|
	//|- PRICETABLECODE  : Tabela de Preco      |
	//|- PRICE           : Preco                |
	//|- QUANTITYLIMIT   : Quantidade Limite    |
	//|- CURRENCY        : Moeda                |
	//|- CURRENCYSIMBOL  : Simbolo da Moeda     |
	//�������������������������������������������
	If Empty( HttpSession->PWSV031HEADER[3] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjProd:cHEADERTYPE := "PRICEVIEW"
		
		If oObjProd:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV031HEADER[3] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf

	//����������������������������������������������������������Ŀ
	//�Header da estrutura do INVENTORYVIEW                      �
	//|- PRODUCTCODE              : Codigo do Produto            |
	//|- QUANTITY                 : Quantidade                   |
	//|- COST                     : Custo                        |
	//|- CURRENCY                 : Moeda                        |
	//|- CURRENCYSIMBOL           : Simbolo da Moeda             |
	//|- TYPEOFBALANCE            : Tipo de Situacao             |
	//|- DESCRIPTIONTYPEOFBALANCE : Descricao do Tipo de Situacao|
	//|- WAREHOUSE                : Armazem                      |
	//������������������������������������������������������������
	If Empty( HttpSession->PWSV031HEADER[4] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjProd:cHEADERTYPE := "INVENTORYVIEW"

		If oObjProd:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV031HEADER[4] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SB1�
//�����������������������
If Empty( HttpSession->PWSV031INDEX )
	HttpSession->PWSV031INDEX := { NIL }
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SB1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSV031INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Atencao
							 "", "W_PWSV030.APW" )
	EndIf
EndIf

//������������������������������������Ŀ
//�Dados para montagem da Tela de Busca�
//��������������������������������������
If Empty( HttpSession->PWSV031BUSCA )
	HttpSession->PWSV031BUSCA := { {}, {} }
											
	//�������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSMTPRODUCT�
	//���������������������������������������������
	If ExistBlock( "PEV031" )
		aWebCols := ExecBlock( "PEV031", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, { "PRODUCTCODE", "N", { "GETCATALOG", ;
												{ "CPRODUCTCODE", "CPRODUCTCODE" } }, ;
												{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
												{ "CGROUPOFPRODUCT", "CGROUPCODE" } }, ;
												{ "CGROUPCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
												{ "CTYPEOFPRODUCT", "CCODE" } }, ;
												{ "CCODE", "CDESCRIPTION" } } )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV031BUSCA[1], HttpSession->PWSV031HEADER[1][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV031BUSCA[1]	, HttpSession->PWSV031HEADER[1][1]	,;
					MTPRODUCT_PRODUCTVIEW():New()	, 	aWebCols						,;
					.T., "A",, 0 }, cNomeWS )
	
	aWebCols := {}
	
	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV031" )
		aWebCols := ExecBlock( "PEV031", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV031BUSCA[2], HttpSession->PWSV031HEADER[2][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV031BUSCA[2], HttpSession->PWSV031HEADER[2][1]	,;
					HttpSession->PWSV031INDEX[1], aWebCols							,;
					.F., "A",, 0 }, cNomeWS )
EndIf

cHtml += ExecInPage( "PWSV031" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV032   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de retorno da Busca por Produtos.                      ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �18/05/06�98717 �Passagem de parametro com o nome do WS na    ���
���          �        �      �funcao GridLinesEx() para que seja possivel  ���
���          �        �      �iniciar o metodo que inclui os campos de     ���
���          �        �      �usuario no aHeader.                      	   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV032()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj								//Objeto WS - WSMTPRODUCT
Local cNomeWS	:= "MTPRODUCT"      	//Nome do WS a ser passado na GridLinesEx

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV032APH := { 	STR0006		,;		//Catalogo de Produtos - Resultado da Busca 
								"W_PWSV031.APW" }		//Pagina de volta do Resultado da Busca

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV032INFO := {}

//������������������������������������Ŀ
//�Inicializa o objeto WS - WSMTPRODUCT�
//��������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
WsChgURL( @oObj, "MTPRODUCT.APW" )

If !Empty( HttpPost->CPRODUCTCODE ) .OR. !Empty( HttpPost->CDESCRIPTION ) .OR. ;
	!Empty( HttpPost->CDESCRIPTION ) .OR. !Empty( HttpPost->CTYPEOFPRODUCT ) .OR. ;
	!Empty( HttpPost->CGROUPOFPRODUCT )
	
	//�������������������������������Ŀ
	//�Parametros do metodo GETCATALOG�
	//���������������������������������
	oObj:cUSERCODE			:= GetUsrCode()
	oObj:cTYPEOFPRODUCTIN	:= HttpPost->CTYPEOFPRODUCT
	oObj:cGROUPOFPRODUCTIN	:= HttpPost->CGROUPOFPRODUCT
	oObj:cPRODUCTCODELIKE	:= IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" )
	oObj:cDESCRIPTIONLIKE	:= IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" )
	oObj:nPAGELEN			:= 0
	oObj:nPAGEFIRST			:= 0
	oObj:cQUERYADDWHERE		:= ""
	oObj:cINDEXKEY			:= IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, )

	//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GETCATALOG()
		//������������������������������
		//�Retorno do Metodo GETCATALOG�
		//������������������������������
		HttpSession->PWSV032RESULT := { oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Atencao
							 "", "W_PWSV031.APW" )
	EndIf
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV032RESULT ) .AND. Len( HttpSession->PWSV032RESULT[1] ) > 0
	//�������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSMTPRODUCT�
	//���������������������������������������������
	If ExistBlock( "PEV032" )
		aWebCols := ExecBlock( "PEV032", .F., .F., {} )
	Else
		aAdd( aWebCols, "PRODUCTCODE" )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, "MEASUREUNIT" )
		aAdd( aWebCols, "TYPEOFPRODUCT" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV032INFO,;			//Array p/ disponibilizacao HTML
				HttpSession->PWSV031HEADER[1][1],;	//Header dos campos a serem mostrados
				aWebCols,;							//Array com os campos a serem mostrados
				HttpSession->PWSV032RESULT[1] )		//Obj. para uso dos campos de usuario
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV032INFO		, HttpSession->PWSV031HEADER[1][1]	,;
					HttpSession->PWSV032RESULT[1]	, aWebCols							,;
					.F., "A",, 0 }, cNomeWS )
Else
	Return PWSHtmlAlert( "", STR0005	,;		//Atencao
						STR0007		,;      //A busca nao retornou nenhum produto.
						"W_PWSV031.APW" )
EndIf

cHtml += ExecInPage( "PWSV032" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV032   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de retorno da Busca por Produtos.                      ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �18/05/06�98717 �Passagem de parametro com o nome do WS na    ���
���          �        �      �funcao GridLinesEx() para que seja possivel  ���
���          �        �      �iniciar o metodo que inclui os campos de     ���
���          �        �      �usuario no aHeader.                      	   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV033()

Local cHtml 	:= ""						//Pagina WEB
Local nPosProd	:= 0						//Posicao do Produto dentro do array de Retorno do Metodo GETCATALOG
Local aWebCols 	:= {}						//Array contendo os campos a serem mostrados na tela
Local oObj									//Objeto WS - WSMTPRODUCT
Local cNomeWS	:= "MTPRODUCT"				//Nome do WS

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV033APH := { 	STR0008	,; 		//Catalogo de Produtos - Detalhes do Produto
								STR0009	,;      //Tabelas de Preco
								STR0010	,;		//Posicao de Estoque
								"W_PWSV031.APW" }

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV033INFO := { {}, {}, {} }

//����������������������������������Ŀ
//�Inicializa Objeto WS - WSMTPRODUCT�
//������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
WsChgUrl( @oObj, "MTPRODUCT.APW" )

nPosProd := aScan( HttpSession->PWSV032RESULT[1], { |x| AllTrim( x:cPRODUCTCODE ) == AllTrim( HttpGet->CPRODUCTCODE ) } )

If nPosProd > 0
	aWebCols := {}
	
	//�������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSMTPRODUCT�
	//���������������������������������������������
	If ExistBlock( "PEV033" )
		aWebCols := ExecBlock( "PEV033", .F., .F., { 1 } )
	EndIf

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV033INFO[1]				, HttpSession->PWSV031HEADER[1][1]	,;
					HttpSession->PWSV032RESULT[1][nPosProd]	, aWebCols							,;
					.F., "H",, 0 }, cNomeWS )
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETPRICE�
	//�������������������������������
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpGet->CPRODUCTCODE

	//cUSERCODE,cPRODUCTCODE,cQUERYADDWHERE
	If oObj:GETPRICE()
		aWebCols := {}	            
			
		//�������������������������������������������Ŀ
		//�Ponto de Entrada - Campos do WS WSMTPRODUCT�
		//���������������������������������������������
		If ExistBlock( "PEV033" )
			aWebCols := ExecBlock( "PEV033", .F., .F., { 2 } )
		EndIf
			
		//��������������������������������������������������Ŀ
		//�Funcao de montagem da descricao dos campos da tela�
		//����������������������������������������������������
		GridHeader(	HttpSession->PWSV033INFO[2], HttpSession->PWSV031HEADER[3][1], aWebCols, oObj:oWSGETPRICERESULT:oWSPRICEVIEW )
	
		//�������������������������������������Ŀ
		//�Funcao de montagem dos campos da tela�
		//���������������������������������������
		GridLinesEx( { 	HttpSession->PWSV033INFO[2]			, HttpSession->PWSV031HEADER[3][1]	,;
						oObj:oWSGETPRICERESULT:oWSPRICEVIEW	, aWebCols							,;
						.F., "A",, 0 }, cNomeWS )
	Else
		Return PWSHtmlAlert( "", STR0005		,;		//Atencao
							 "", "PWSV032.APW" )
	EndIf
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETIMAGE�
	//�������������������������������
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpGet->CPRODUCTCODE

	//cUSERCODE,cPRODUCTCODE
	If oObj:GETIMAGE()
		HttpSession->_IMG_PROD := oObj:cGETIMAGERESULT
	Else
		Return PWSHtmlAlert( "", STR0005		,;		//Atencao
							 "", "PWSV032.APW" )
	EndIf
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETSTOCK�
	//�������������������������������
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpGet->CPRODUCTCODE
	oObj:cWAREHOUSE		:= HttpSession->PWSV032RESULT[1][nPosProd]:cSTANDARDWAREHOUSE
	
	//cUSERCODE,cPRODUCTCODE,cWAREHOUSE
	If oObj:GETSTOCK()
		aWebCols := {}
		
		//�������������������������������������������Ŀ
		//�Ponto de Entrada - Campos do WS WSMTPRODUCT�
		//���������������������������������������������
		If ExistBlock( "PEV033" )
			aWebCols := ExecBlock( "PEV033", .F., .F., { 3 } )
		EndIf
		
		//��������������������������������������������������Ŀ
		//�Funcao de montagem da descricao dos campos da tela�
		//����������������������������������������������������
		GridHeader(	HttpSession->PWSV033INFO[3], HttpSession->PWSV031HEADER[4][1], aWebCols, oObj:oWSGETSTOCKRESULT:oWSINVENTORYVIEW )
	
		//�������������������������������������Ŀ
		//�Funcao de montagem dos campos da tela�
		//���������������������������������������
		GridLinesEx( { 	HttpSession->PWSV033INFO[3]				, HttpSession->PWSV031HEADER[4][1]	,;
						oObj:oWSGETSTOCKRESULT:oWSINVENTORYVIEW	, aWebCols							,;
						.F., "A",, 0 }, cNomeWS )
	Else
		Return PWSHtmlAlert( "", STR0005		,;		//Atencao
							 "", "PWSV032.APW" )
	EndIf
EndIf

cHtml += ExecInPage( "PWSV033" )

WEB EXTENDED END

Return cHtml
