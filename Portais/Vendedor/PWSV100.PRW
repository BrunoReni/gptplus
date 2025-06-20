#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSV100.ch"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV10*   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado as         ���
���          � comissoes do vendedor.                                      ���
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
���Programa  �PWSV100   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
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
Web Function PWSV100()

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
HttpSession->PWSV020APH	:= { 	STR0001		, ;				//Comissoes
								"W_PWSV101.APW", ;				//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002 					//"Nao ha vendedores a consultar."
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV101()

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
���Programa  �PWSV101   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de busca de comissoes por data.                        ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������ͼ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV101()

Local cHtml 	:= ""					//Pagina WEB
Local oObj								//Objeto WS - WSMTSELLER

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV101APH := { 	STR0003		,;	//Comissoes - Busca COMISSOES
								"W_PWSV102.APW" }

//���������������������������������Ŀ
//�Inicializa Objeto WS - WSMTSELLER�
//�����������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
WsChgUrl( @oObj,"MTSELLER.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV101HEADER )
	HttpSession->PWSV101HEADER := { NIL }
	
	//�����������������������������������������������Ŀ
	//�Header da Estrutura COMISSIONVIEW              �
	//|- SELLERCODE           : Codido do Vendedor    |
	//|- CUSTOMERCODE         : Codigo do Cliente     |
	//|- DOCUMENT             : Documento             |
	//|- SALESORDER           : Pedido                |
	//|- REGISTERDATE         : Data da Comissao      |
	//|- RECEIVABLEDATE       : Vencimento da Comissao|
	//|- PAYMENTDATE          : Data do Pagamento     |
	//|- COMMISSIONBASE       :	Base da Comissao      |
	//|- COMMISSIONPERCENTAGE : Porc. da Comissao     |
	//|- COMMISSIONVALUE      : Valor da Comissao     |
	//|- GENERATEDBY          : Baixa / Emissao       |
	//�������������������������������������������������
	If Empty( HttpSession->PWSV101HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObj:cHEADERTYPE := "COMMISSIONVIEW"
		
		//cHEADERTYPE
		If oObj:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV101HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0004		,; //Atencao
								 "", "W_PWSV100.APW" )
		EndIf
	EndIf
EndIf

cHtml += ExecInPage( "PWSV101" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV102   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de retorno da busca de comissoes por data              ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Andrea F. �15/03/06�94847 �Incluido o campo nome do cliente no aHeader  ���
���          �        �      �da estrutura do browser de comissoes.        ���
���Cleber M. �06/04/06�95625 �Incluido tratamento p/ inicializar as varia- ���
���          �        �      �veis Vencto De/Vencto Ate que estavam retor- ���
���          �        �      �nando como tipo Nil.  					   ���
���Cleber M. �26/04/06�95625 �Tratamento dos parametros no retorno da vi-  ���
���          �        �      �sualizacao de comissoes.                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV102()

Local cHtml 	:= ""					//Pagina WEB
Local nI		:= 0					//Variavel de apoio
Local aWebCols 	:= {}					//Array contendo os campos aa serem mostrados na tela
Local oObj								//Objeto WS - WSMTSELLER

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV102APH := { 	STR0005		,;	//Comiss�es - Resultado da Busca COMISSOES
								"W_PESV103.APW"	,;
								"W_PWSV101.APW" }

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV102INFO := {}

//���������������������������������Ŀ
//�Inicializa Objeto WS - WSMTSELLER�
//�����������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
WsChgUrl( @oObj,"MTSELLER.APW" )

If !Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO )
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
EndIf

//����������������������������������������������������������Ŀ
//� Verifica se os parametros de Vencto. foram informados    �
//������������������������������������������������������������
If !Empty( HttpGet->dRECEIVABLEDATEFROM ) .AND. !Empty( HttpGet->dRECEIVABLEDATETO )
	HttpPost->dRECEIVABLEDATEFROM 	:= HttpGet->dRECEIVABLEDATEFROM
	HttpPost->dRECEIVABLEDATETO 	:= HttpGet->dRECEIVABLEDATETO
EndIf

//������������������������������Ŀ
//�Parametros do metodo GETHEADER�
//��������������������������������
oObj:cUSERCODE				:= GetUsrCode()
oObj:cSELLERCODE			:= HttpSession->CODVENERP
oObj:dREGISTERDATEFROM		:= CtoD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO 		:= CtoD( HttpPost->dREGISTERDATETO )
If !Empty( HttpPost->dRECEIVABLEDATEFROM )
	oObj:dRECEIVABLEDATEFROM	:= CtoD( HttpPost->dRECEIVABLEDATEFROM )
Else
	oObj:dRECEIVABLEDATEFROM	:= CtoD("")
EndIf
If !Empty( HttpPost->dRECEIVABLEDATETO )
	oObj:dRECEIVABLEDATETO 		:= CtoD( HttpPost->dRECEIVABLEDATETO )
Else
	oObj:dRECEIVABLEDATETO 		:= CtoD("")
EndIf
oObj:cQUERYADDWHERE	 		:= ""

//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,dRECEIVABLEDATEFROM,dRECEIVABLEDATETO,cQUERYADDWHERE
If oObj:GETCOMMISSION()
	HttpSession->nTotalComis := 0
	
	//���������������������������Ŀ
	//�Retorno do Metodo GETHEADER�
	//�����������������������������
	HttpSession->PWSV102RESULT := { oObj:oWSGETCOMMISSIONRESULT:oWSCOMMISSIONVIEW }
	
	//��������������������������������������Ŀ
	//� Atualiza o valor total de comissoes  �
	//����������������������������������������
	For nI := 1 To Len( HttpSession->PWSV102RESULT[1] )
		HttpSession->nTotalComis += HttpSession->PWSV102RESULT[1][nI]:nCOMMISSIONVALUE
	Next nI
Else
	Return PWSHtmlAlert( "", STR0004  		,;	//Atencao
						"", "W_PWSV101.APW" )
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV102RESULT ) .AND. Len( HttpSession->PWSV102RESULT[1] ) > 0
	//��������������������������������Ŀ
	//�Ponto de Entrada - COMISSIONVIEW�
	//����������������������������������
	If ExistBlock( "PEV102" )
		aWebCols := ExecBlock( "PEV102", .F., .F., {} )
	Else
		aAdd( aWebCols, "SELLERCODE" )
		aAdd( aWebCols, "CUSTOMERCODE" )
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "DOCUMENT" )
		aAdd( aWebCols, "SALESORDER" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "RECEIVABLEDATE" )
		aAdd( aWebCols, "COMMISSIONBASE" )
		aAdd( aWebCols, "COMMISSIONPERCENTAGE" )
		aAdd( aWebCols, "COMMISSIONVALUE" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader(	HttpSession->PWSV102INFO, HttpSession->PWSV101HEADER[1][1], aWebCols, HttpSession->PWSV102RESULT[1] )

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV102INFO		, HttpSession->PWSV101HEADER[1][1]	,;
					HttpSession->PWSV102RESULT[1]	, aWebCols							,;
					.F., "A",, 0 }, 'MTSELLER' )
Else
	Return PWSHtmlAlert( "", 	STR0004	,;	//Atencao
								STR0006	,;	//A busca nao retornou nenhuma comissao para este vendedor no periodo solicitado.
						 "W_PWSV101.APW" )
EndIf

cHtml += ExecInPage( "PWSV102" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV103   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela dos detalhes da comissao.                              ���
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
Web Function PWSV103()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV103APH := { 	STR0001		,;		//Comissoes
								"W_PWSV102.APW?dREGISTERDATEFROM=" + HttpGet->dREGISTERDATEFROM + "&dREGISTERDATETO=" + HttpGet->dREGISTERDATETO + "&dRECEIVABLEDATEFROM=" + HttpGet->dRECEIVABLEDATEFROM + "&dRECEIVABLEDATETO=" + HttpGet->dRECEIVABLEDATETO }

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV103INFO := {}

//��������������������������������Ŀ
//�Ponto de Entrada - COMISSIONVIEW�
//����������������������������������
If ExistBlock( "PEV103" )
	aWebCols := ExecBlock( "PEV103", .F., .F., {} )
EndIf

//�������������������������������������Ŀ
//�Funcao de montagem dos campos da tela�
//���������������������������������������
GridLinesEx( { 	HttpSession->PWSV103INFO									, HttpSession->PWSV101HEADER[1][1]	,;
				HttpSession->PWSV102RESULT[1][Val( HttpGet->cComissao )]	, aWebCols							,;
				.F., "H",, 0 } )

cHtml += ExecInPage( "PWSV103" )

WEB EXTENDED END

Return cHtml