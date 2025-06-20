#INCLUDE "Protheus.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSV020.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV02*   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � titulos em aberto.                                          ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Tatiana C.�118258 - Inclusao do campo loja na consulta de titulos       ���
��������������������������������������������������������������������������͹��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV020   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSV020()

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
HttpSession->PWSV020APH	:= { 	STR0001			,;			//Titulos em Aberto
								"W_PWSV021.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0003	//Nao ha vendedores a consultar
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV021()

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
���Programa  �PWSV021   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de busca dos titulos em aberto para o vendedor         ���
���          � selecionado.                                                ���
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
Web Function PWSV021()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObjFin							//Objeto WS - WSFINANCESELLERBILL
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV021APH := { STR0001		,;		//Titulos em Aberto
							 "W_PWSV022.APW" }

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESELLERBILL�
//����������������������������������������������
oObjFin := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObjFin, "FINANCESELLERBILL.APW" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV021HEADER )
	HttpSession->PWSV021HEADER := { NIL, NIL }

	//���������������������������������������������Ŀ
	//�Header da estrutura BILLVIEW - Titulo        �
	//|- PREFIX                : Prefixo            |
	//|- BILLNUMBER	           : Numero             |
	//|- INSTALLMENT           : Parcela            |
	//|- BILLTYPE              : Tipo               |
	//|- CLASSCODE             : Natureza           |
	//|- ISSUEDATE             : Data de Emissao    |
	//|- ORIGINALDUEDATE       : Data Original      |
	//|- REALDUEDATE           : Data Real          |
	//|- CURRENCY              : Moeda              |
	//|- CURRENCYSIMBOL        : Simbolo da Moeda   |
	//|- ORIGINALVALUE         : Valor Original     |
	//|- ORIGINALCURRENCYVALUE : VlCruz             |
	//|- DEDUCTIONSVALUE       : Abatimento         |
	//|- INCREASEVALUE         : Saldo do Decrescimo|
	//|- BALANCEVALUE          : Saldo              |
	//|- BALANCECURRENCYVALUE  : Saldo              |
	//|- BANK                  : Banco              |
	//|- HISTORY               : Historico          |
	//|- DELAYINDAYS           : Atraso             |
	//|- DAYLYINTERESTRATE     : Porcentagem Juros  |
	//|- DAYLYINTERESTVALUE    : Valor Juros        |
	//�����������������������������������������������
	If Empty( HttpSession->PWSV021HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "BILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV021HEADER[1] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0017,;       //Atencao
								 "", "W_PWSV020.APW" )
		EndIf
	EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSV021HEADER[2] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV021HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0017,; 	//Atencao
								 "", "W_PWSV020.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSV021INDEX )
	HttpSession->PWSV021INDEX := {}
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SE1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSV021INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0017,; 	//Atencao
							 "", "W_PWSV020.APW" )
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSV021INFO )
	HttpSession->PWSV021INFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV021" )
		aWebCols := ExecBlock( "PEV021", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSV021INFO, HttpSession->PWSV021HEADER[2][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV021INFO		, HttpSession->PWSV021HEADER[2][1]	,;
					HttpSession->PWSV021INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV021" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV022   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com os titulos em aberto para o vendedor selecionado.  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �14/05/07� 8.11 �Bops 125482: Correcao da busca por cliente/  ���
���          �        �      �loja e inclusao de consulta F3 para cliente. ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV022()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERBILL

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV022APH := { 	STR0004		,;					//Titulos em Aberto - Resultado da Busca TITULOS EM ABERTO
								"W_PWSV023.APW"	,;				//Pagina para onde sera enviado o POST
								"W_PWSV021.APW" }				//Pagina de Volta

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV022INFO := {}

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESELLERBILL�
//����������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObj, "FINANCESELLERBILL.APW" )

If 	!Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) .AND.;
	!Empty( HttpGet->dREALDUEDATEFROM ) .AND. !Empty( HttpGet->dREALDUEDATETO )
	
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
	HttpPost->dREALDUEDATEFROM 		:= HttpGet->dREALDUEDATEFROM
	HttpPost->dREALDUEDATETO 		:= HttpGet->dREALDUEDATETO
Endif

If ( !Empty( HttpGet->cCUSTOMERFROM ) .OR. !Empty( HttpGet->cCUSTOMERTO ) ) .AND.;
	( !Empty( HttpGet->cCUSTOMERUNITFROM ) .OR. !Empty( HttpGet->cCUSTOMERUNITTO ) )
	
	HttpPost->cCUSTOMERFROM 	:= HttpGet->cCUSTOMERFROM
	HttpPost->cCUSTOMERTO 		:= HttpGet->cCUSTOMERTO
	HttpPost->cCUSTOMERUNITFROM	:= HttpGet->cCUSTOMERUNITFROM
	HttpPost->cCUSTOMERUNITTO 	:= HttpGet->cCUSTOMERUNITTO
Endif


//����������������������������Ŀ
//�Parametros do metodo BRWBILL�
//������������������������������
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO	:= CToD( HttpPost->dREGISTERDATETO )
oObj:dREALDUEDATEFROM	:= CToD( HttpPost->dREALDUEDATEFROM )
oObj:dREALDUEDATETO		:= CToD( HttpPost->dREALDUEDATETO )

If ( !Empty( HttpPost->cCUSTOMERFROM ) .OR. !Empty( HttpPost->cCUSTOMERTO ) ) .AND.;
	( !Empty( HttpPost->cCUSTOMERUNITFROM ) .OR. !Empty( HttpPost->cCUSTOMERUNITTO ) )
	oObj:cQUERYADDWHERE	:= "A1_COD >= '" + HttpPost->cCUSTOMERFROM + "' AND "+"A1_COD <= '" + HttpPost->cCUSTOMERTO + "'AND "+"A1_LOJA >= '" + HttpPost->cCUSTOMERUNITFROM + "' AND "+"A1_LOJA <= '" + HttpPost->cCUSTOMERUNITTO + "'"
Endif

oObj:cINDEXKEY			:= HttpPost->CINDEX

//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,dREALDUEDATEFROM,dREALDUEDATETO,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWBILL()
	//�������������������������Ŀ
	//�Retorno do metodo BRWBILL�
	//���������������������������
	HttpSession->PWSV022RESULT := { oObj:oWSBRWBILLRESULT:oWSBILLVIEW }
Else
	Return PWSHtmlAlert( "", STR0017,; //Atencao
						 "", "W_PWSV020.APW" )
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV022RESULT ) .AND. Len( HttpSession->PWSV022RESULT[1] ) > 0
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEV022" )
		aWebCols := ExecBlock( "PEV022", .F., .F., {} )
	Else
		aAdd( aWebCols, "PREFIX" )
		aAdd( aWebCols, "BILLNUMBER" )
		aAdd( aWebCols, "INSTALLMENT" )
		aAdd( aWebCols, "CUSTOMERCODE" )		     
		aAdd( aWebCols, "UNITCUSTOMERCODE" )
		aAdd( aWebCols, "CUSTOMERNAME" )						
		aAdd( aWebCols, "BILLTYPE" )
		aAdd( aWebCols, "CLASSCODE" )
		aAdd( aWebCols, "ISSUEDATE" )
		aAdd( aWebCols, "ORIGINALDUEDATE" )
		aAdd( aWebCols, "REALDUEDATE" )
		aAdd( aWebCols, "ORIGINALVALUE" )
	EndIf


	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader(	HttpSession->PWSV022INFO	, HttpSession->PWSV021HEADER[1][1],;
				aWebCols					, HttpSession->PWSV022RESULT[1],;
				"FINANCESELLERBILL"			, "SE1" )
             
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV022INFO		, HttpSession->PWSV021HEADER[1][1]	,;
					HttpSession->PWSV022RESULT[1]	, aWebCols							,;
					.F., "A",, 0 }, "FINANCESELLERBILL", "SE1" )
Else
	Return PWSHtmlAlert( "", STR0017,;  //Atencao
							 STR0018,;  //A busca n�o retornou nenhum titulo em aberto cadastrado para este vendedor no periodo solicitado.
	  					"W_PWSV021.APW" )
EndIf

cHtml += ExecInPage( "PWSV022" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV023   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com o titulo selecionado.                              ���
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
Web Function PWSV023()

Local cHtml 	:= ""					//Pagina WEB
Local nPosTit 	:= 0			   		//Posicao do Titulo dentro do array de retorno do metodo BRWBILL
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERBILL

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSV023APH := { 	STR0001 + " " +;	//T�tulos em Aberto - T�tulo
								HttpSession->PWSV022RESULT[1][nPosTit]:cPREFIX + ;
								HttpSession->PWSV022RESULT[1][nPosTit]:cBILLNUMBER + ;
								HttpSession->PWSV022RESULT[1][nPosTit]:cINSTALLMENT + ;
								HttpSession->PWSV022RESULT[1][nPosTit]:cBILLTYPE, ;
								"W_PWSV022.APW?dREGISTERDATEFROM=" + HttpGet->dREGISTERDATEFROM + "&dREGISTERDATETO=" + HttpGet->dREGISTERDATETO + "&dREALDUEDATEFROM=" + HttpGet->dREALDUEDATEFROM + "&dREALDUEDATETO=" + HttpGet->dREALDUEDATETO + "&cCUSTOMERFROM=" + HttpGet->cCUSTOMERFROM + "&cCUSTOMERTO=" + HttpGet->cCUSTOMERTO + "&cCUSTOMERUNITFROM=" + HttpGet->cCUSTOMERUNITFROM + "&cCUSTOMERUNITTO=" + HttpGet->cCUSTOMERUNITTO }	//Pagina de Volta

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSV023INFO := {}

//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT�
//���������������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObj, "FINANCESELLERBILL.APW" )

//����������������������������Ŀ
//�Parametros do metodo GETBILL�
//������������������������������
oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cPREFIX		:= HttpSession->PWSV022RESULT[1][nPosTit]:cPREFIX
oObj:cBILLNUMBER	:= HttpSession->PWSV022RESULT[1][nPosTit]:cBILLNUMBER
oObj:cINSTALLMENT	:= HttpSession->PWSV022RESULT[1][nPosTit]:cINSTALLMENT
oObj:cBILLTYPE		:= HttpSession->PWSV022RESULT[1][nPosTit]:cBILLTYPE

//cUSERCODE,cSELLERCODE,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
If oObj:GETBILL()
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEV023" )
		aWebCols := ExecBlock( "PEV023", .F., .F., {} )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV023INFO				, HttpSession->PWSV021HEADER[1][1]	,;
					HttpSession->PWSV022RESULT[1][nPosTit]	, aWebCols							,;
					.F., "H",, 0 }, "FINANCESELLERBILL", "SE1" )
Else
	Return PWSHtmlAlert( "", STR0017,;	//Atencao
						 "", "W_PWSV022.APW" )
EndIf

cHtml += ExecInPage( "PWSV023" )

WEB EXTENDED END

Return cHtml
