#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSC160.CH"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC16*   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � titulos baixados.                                           ���
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
���Programa  �PWSC160   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSC160()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//������������������������������������������Ŀ
//�Clientes cadastrados para o usuario logado�
//��������������������������������������������
HttpPost->PWSC020CLI := GetUserCli()

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC020APH	:= { 	STR0001	,;       //"T�tulos Baixados"
								"W_PWSC161.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//���������������������������������������������������
	//�Nao ha clientes cadastrados para o usuario logado�
	//���������������������������������������������������
	Case Empty( HttpPost->PWSC020CLI )
		HttpSession->PWSC020APH[3] := STR0002                  //"N�o h� clientes a consultar."
		
	//���������������������������Ŀ
	//�Apenas 1 cliente cadastrado�
	//�����������������������������
	Case Len( HttpPost->PWSC020CLI ) == 2
		HttpSession->CODCLIERP := HttpPost->PWSC020CLI[2][2]

		Return W_PWSC161()

	//�������������������
	//�Mais de 1 cliente�
	//�������������������
	//Otherwise
		//cHtml += ExecInPage( "PWSC020" )

EndCase

cHtml += ExecInPage( "PWSC020" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC161   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de busca dos titulos baixados para o cliente           ���
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
Web Function PWSC161()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObjFin							//Objeto WS - WSFINANCECUSTOMERBILL
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC161APH := { STR0001, "W_PWSC162.APW" }       //"T�tulos Baixados"

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCECUSTOMERBILL�
//����������������������������������������������
oObjFin := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERBILL' ), WSFINANCECUSTOMERBILL():New() )
WsChgUrl( @oObjFin, "FINANCECUSTOMERBILL.APW" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSC161HEADER )
	HttpSession->PWSC161HEADER := { NIL, NIL, NIL }

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
	If Empty( HttpSession->PWSC161HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "BILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSC161HEADER[1] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003, "", "W_PWSC160.APW" )        //"Aten��o"
		EndIf
	EndIf

	//�������������������������������������������������������������Ŀ
	//�Header da estrutura PAIDBILLVIEW - Baixa                     �
	//|- REASONOFWRITEOFF  : Motivo                                 |
	//|- BANK              : Banco                                  |
	//|- BANKACCOUNT       : Conta                                  |
	//|- PAIDDATE          : Data do Pagamento                      |
	//|- CREDITDATE        : Data do Credito                        |
	//|- CURRENCY          : Moeda                                  |
	//|- CURRENCYSIMBOL    : Simbolo da Moeda                       |
	//|- VALUEPAID         : Valor Pago                             |
	//|- CURRENCYVALUEPAID : Valor Pago na Moeda Corrente           |
	//|- HISTORY           : Historico                              |
	//|- WRITEOFFTYPE      : 1-Principal;2-Descontos;3-Multa;4-Juros|
	//|- TYPEDESCRIPTION   : 1-Principal;2-Descontos;3-Multa;4-Juros|
	//���������������������������������������������������������������
	If Empty( HttpSession->PWSC161HEADER[2] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "PAIDBILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSC161HEADER[2] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003, "", "W_PWSC160.APW" )        //"Aten��o"
		EndIf
	EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSC161HEADER[3] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSC161HEADER[3] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003, "", "W_PWSC160.APW" )           //"Aten��o"
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSC161INDEX )
	HttpSession->PWSC161INDEX := {}
	
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
		HttpSession->PWSC161INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003, "", "W_PWSC160.APW" )         //"Aten��o"
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSC161INFO )
	HttpSession->PWSC161INFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEC161" )
		aWebCols := ExecBlock( "PEC161", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSC161INFO, HttpSession->PWSC161HEADER[3][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSC161INFO		, HttpSession->PWSC161HEADER[3][1]	,;
					HttpSession->PWSC161INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSC161" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC162   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSC162()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCECUSTOMERBILL

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSC162APH := { 	STR0004, ;                      //"T�tulos Baixados - Resultado da Busca T�TULOS BAIXADOS"
								"W_PWSC163.APW", ;				//Pagina para onde sera enviado o POST
								"W_PWSC161.APW" }				//Pagina de Volta

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSC162INFO := {}

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCECUSTOMERBILL�
//����������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERBILL' ), WSFINANCECUSTOMERBILL():New() )
WsChgUrl( @oObj, "FINANCECUSTOMERBILL.APW" )

//��������������������������������Ŀ
//�Parametros do metodo BRWPAIDBILL�
//����������������������������������
oObj:cUSERCODE			:= GetUsrCode()
oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:cQUERYADDWHERE		:= ""
oObj:cINDEXKEY			:= HttpPost->CINDEX

//cUSERCODE,cCUSTOMERID,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWPAIDBILL()
	//�����������������������������Ŀ
	//�Retorno do metodo BRWPAIDBILL�
	//�������������������������������
	HttpSession->PWSC162RESULT := { oObj:oWSBRWPAIDBILLRESULT:oWSBILLVIEW }
Else
	Return PWSHtmlAlert( "", STR0003, "", "W_PWSC160.APW" )           //"Aten��o"
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSC162RESULT ) .AND. Len( HttpSession->PWSC162RESULT[1] ) > 0
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEC162" )
		aWebCols := ExecBlock( "PEC162", .F., .F., {} )
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
	GridHeader(	HttpSession->PWSC162INFO, HttpSession->PWSC161HEADER[1][1], aWebCols )
             
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSC162INFO		, HttpSession->PWSC161HEADER[1][1]	,;
					HttpSession->PWSC162RESULT[1]	, aWebCols							,;
					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0003, STR0005, "W_PWSC161.APW" )   //"Aten��o"  /"A busca n�o retornou nenhum t�tulo baixado cadastrado para este cliente no per�odo solicitado."
EndIf

cHtml += ExecInPage( "PWSC162" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC163   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSC163()

Local cHtml 	:= ""					//Pagina WEB
Local nPosTit 	:= 0					//Posicao do Titulo dentro do array de retorno do metodo BRWPAIDBILL
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObj								//Objeto WS - WSFINANCECUSTOMERBILL

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSC163APH := { 	"T�tulos Baixados - T�tulo : " + ;
								HttpSession->PWSC162RESULT[1][nPosTit]:cPREFIX + ;
								HttpSession->PWSC162RESULT[1][nPosTit]:cBILLNUMBER + ;
								HttpSession->PWSC162RESULT[1][nPosTit]:cINSTALLMENT + ;
								HttpSession->PWSC162RESULT[1][nPosTit]:cBILLTYPE, ;
								"Baixas do T�tulo", ;
								"W_PWSC161.APW" }			//Pagina de Volta

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSC163INFO := { {}, {} }

//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMCUSTOMERCUSTOMERCONTACT�
//���������������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERBILL' ), WSFINANCECUSTOMERBILL():New() )
WsChgUrl( @oObj, "FINANCECUSTOMERBILL.APW" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->PWSC162RESULT[1][nPosTit]:cCUSTOMERCODE + HttpSession->PWSC162RESULT[1][nPosTit]:cUNITCUSTOMERCODE
oObj:cPREFIX		:= HttpSession->PWSC162RESULT[1][nPosTit]:cPREFIX
oObj:cBILLNUMBER	:= HttpSession->PWSC162RESULT[1][nPosTit]:cBILLNUMBER
oObj:cINSTALLMENT	:= HttpSession->PWSC162RESULT[1][nPosTit]:cINSTALLMENT
oObj:cBILLTYPE		:= HttpSession->PWSC162RESULT[1][nPosTit]:cBILLTYPE

//cUSERCODE,cCUSTOMERID,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
If oObj:GETPAIDBILL()
	HttpSession->PWSC163RESULT := { oObj:oWSGETPAIDBILLRESULT }

	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEC163" )
		aWebCols := ExecBlock( "PEC163", .F., .F., { 1 } )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSC163INFO[1]				, HttpSession->PWSC161HEADER[1][1]	,;
					HttpSession->PWSC162RESULT[1][nPosTit]	, aWebCols							,;
					.F., "H",, 0 } )

	//������������������������Ŀ
	//�Ponto de Entrada - Baixa�
	//��������������������������
	If ExistBlock( "PEC163" )
		aWebCols := ExecBlock( "PEC163", .F., .F., { 2 } )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader(	HttpSession->PWSC163INFO[2], HttpSession->PWSC161HEADER[2][1] )
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSC163INFO[2]									, HttpSession->PWSC161HEADER[2][1]	,;
					HttpSession->PWSC163RESULT[1]:oWSPAYMENT:oWSPAIDBILLVIEW	, aWebCols							,;
					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "", "Aten��o", "", "W_PWSC162.APW" )
EndIf

cHtml += ExecInPage( "PWSC163" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC163A  �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com as baixas do titulos selecionado.                  ���
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
Web Function PWSC163A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC163A" )

WEB EXTENDED END

Return cHtml