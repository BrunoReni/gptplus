#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSC020.CH"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC02*   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC020   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os clientes disponiveis para o usuario logado.       ���
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
Web Function PWSC020()

Local cHtml 	:= ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//������������������������������������������Ŀ
//�Clientes cadastrados para o usuario logado�
//��������������������������������������������
HttpPost->PWSC020CLI := GetUserCli()

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC020APH	:= { 	STR0001	,;                      //T�tulos em Aberto
								"W_PWSC021.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//���������������������������������������������������
	//�Nao ha clientes cadastrados para o usuario logado�
	//���������������������������������������������������
	Case Empty( HttpPost->PWSC020CLI )
		HttpSession->PWSC020APH[3] := STR0003					//"N�o h� clientes a consultar."
		
	//���������������������������Ŀ
	//�Apenas 1 cliente cadastrado�
	//�����������������������������
	Case Len( HttpPost->PWSC020CLI ) == 2
		HttpSession->CODCLIERP := HttpPost->PWSC020CLI[2][2]

		Return W_PWSC021()

	//�������������������
	//�Mais de 1 cliente�
	//�������������������
   //	Otherwise
   //		cHtml += ExecInPage( "PWSC020" )

EndCase

cHtml += ExecInPage( "PWSC020" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC021   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de busca dos titulos em aberto para o cliente          ���
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
Web Function PWSC021()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObjFin							//Objeto WS - WSFINANCECUSTOMERBILL
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������������������������������������������Ŀ
//�Preenche a Session do Codigo do Cliente com o Post da selecao de Clientes�
//���������������������������������������������������������������������������
If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC021APH := { STR0001, "W_PWSC022.APW" }            //"T�tulos em Aberto"

//����������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCECUSTOMERBILL�
//������������������������������������������������
oObjFin := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERBILL' ), WSFINANCECUSTOMERBILL():New() )
WsChgUrl( @oObjFin, "FINANCECUSTOMERBILL.APW" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSC021HEADER )
	HttpSession->PWSC021HEADER := { NIL, NIL }

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
	If Empty( HttpSession->PWSC021HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "BILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSC021HEADER[1] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "",STR0019, "", "W_PWSC020.APW" )         //Atencao
		EndIf
	EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSC021HEADER[2] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSC021HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0019, "", "W_PWSC020.APW" )       	// Atencao
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSC021INDEX )
	HttpSession->PWSC021INDEX := {}
	
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
		HttpSession->PWSC021INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0019, "", "W_PWSC020.APW" )           //Atencao
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSC021INFO )
	HttpSession->PWSC021INFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEC021" )
		aWebCols := ExecBlock( "PEC021", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSC021INFO, HttpSession->PWSC021HEADER[2][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSC021INFO		, HttpSession->PWSC021HEADER[2][1]	,;
					HttpSession->PWSC021INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSC021" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC022   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com os titulos em aberto para o cliente selecionado.   ���
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
Web Function PWSC022()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCECUSTOMERBILL

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������                        
HttpSession->PWSC022APH := { STR0004	, ;						//"T�tulos em Aberto - Resultado da Busca T�TULOS EM ABERTO"
								"W_PWSC023.APW", ;				//Pagina para onde sera enviado o POST
								"W_PWSC021.APW" }				//Pagina de Volta

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSC022INFO := {}

//����������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCECUSTOMERBILL�
//������������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERBILL' ), WSFINANCECUSTOMERBILL():New() )
WsChgUrl( @oObj, "FINANCECUSTOMERBILL.APW" )

//����������������������������Ŀ
//�Parametros do metodo BRWBILL�
//������������������������������
oObj:cUSERCODE			:= GetUsrCode()
oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
oObj:cQUERYADDWHERE		:= ""
oObj:cINDEXKEY			:= HttpPost->CINDEX

//cUSERCODE,cCUSTOMERID,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWBILL()
	//�������������������������Ŀ
	//�Retorno do metodo BRWBILL�
	//���������������������������
	HttpSession->PWSC022RESULT := { oObj:oWSBRWBILLRESULT:oWSBILLVIEW }
Else
	Return PWSHtmlAlert( "", STR0019, "", "W_PWSC020.APW" )        //Atencao
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSC022RESULT ) .AND. Len( HttpSession->PWSC022RESULT[1] ) > 0
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEC022" )
		aWebCols := ExecBlock( "PEC022", .F., .F., {} )
	Else
		aAdd( aWebCols, "PREFIX" )
		aAdd( aWebCols, "BILLNUMBER" )
		aAdd( aWebCols, "INSTALLMENT" )
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
	GridHeader(	HttpSession->PWSC022INFO, HttpSession->PWSC021HEADER[1][1], aWebCols )
             
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSC022INFO		, HttpSession->PWSC021HEADER[1][1]	,;
					HttpSession->PWSC022RESULT[1]	, aWebCols							,;
					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "",STR0019 ,STR0020, "W_PWSC021.APW" )		//Aten��o / A busca n�o retornou nenhum t�tulo em aberto cadastrado para este cliente
EndIf

cHtml += ExecInPage( "PWSC022" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC023   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSC023()

Local cHtml 	:= ""					//Pagina WEB
Local nPosTit 	:= 0					//Posicao do Titulo dentro do array de retorno do metodo BRWBILL
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObj								//Objeto WS - WSFINANCECUSTOMERBILL

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSC023APH := { 	STR0001 + ;                              //T�tulos em Aberto - T�tulo :
								HttpSession->PWSC022RESULT[1][nPosTit]:cPREFIX + ;
								HttpSession->PWSC022RESULT[1][nPosTit]:cBILLNUMBER + ;
								HttpSession->PWSC022RESULT[1][nPosTit]:cINSTALLMENT + ;
								HttpSession->PWSC022RESULT[1][nPosTit]:cBILLTYPE, ;
								"W_PWSC021.APW" }			//Pagina de Volta

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSC023INFO := {}

//��������������������������������������������Ŀ
//�Inicializa Objeto WS - WSFINANCECUSTOMERBILL�
//����������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERBILL' ), WSFINANCECUSTOMERBILL():New() )
WsChgUrl( @oObj, "FINANCECUSTOMERBILL.APW" )

//����������������������������Ŀ
//�Parametros do metodo GETBILL�
//������������������������������
oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
oObj:cPREFIX		:= HttpSession->PWSC022RESULT[1][nPosTit]:cPREFIX
oObj:cBILLNUMBER	:= HttpSession->PWSC022RESULT[1][nPosTit]:cBILLNUMBER
oObj:cINSTALLMENT	:= HttpSession->PWSC022RESULT[1][nPosTit]:cINSTALLMENT
oObj:cBILLTYPE		:= HttpSession->PWSC022RESULT[1][nPosTit]:cBILLTYPE

//cUSERCODE,cCUSTOMERID,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
If oObj:GETBILL()
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEC023" )
		aWebCols := ExecBlock( "PEC023", .F., .F., {} )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSC023INFO				, HttpSession->PWSC021HEADER[1][1]	,;
					HttpSession->PWSC022RESULT[1][nPosTit]	, aWebCols							,;
					.F., "H",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0019, "", "W_PWSC022.APW" )      	// Atencao
EndIf

cHtml += ExecInPage( "PWSC023" )

WEB EXTENDED END

Return cHtml