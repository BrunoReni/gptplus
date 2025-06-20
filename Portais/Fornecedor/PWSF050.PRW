#INCLUDE "PWSF050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE MYUSERCODE GetUsrCode()

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF05*   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado ao         ���
���          � processamento de Pedidos de Compra.                         ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Coments   � Aphs Envolvidos :                                           ���
���          � PWSF020.APH 		Sele��o de Fornecedores                    ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF050   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os fornecedores disponives para o usuario logado.    ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF050()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//�Fornecedores cadastrados para o usuario logado�
//������������������������������������������������
HttpPost->PWSF020FOR := GetUserFor()
HttpSession->PWSF020FOR := HttpPost->PWSF020FOR

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF020APH := {	STR0001 ,;			// Processamento de Pedidos //"Processamento de Pedidos de compra"
								"W_PWSF051.APW"	,;	// Proxima Tela
								""	} 				// Msg de Erro
Do Case
	//�������������������������������������������������������
	//�Nao ha fornecedores cadastrados para o usuario logado�
	//�������������������������������������������������������
	Case Empty( HttpPost->PWSF020FOR )
		HttpSession->PWSF020APH[3] := STR0002 //"N�o h� fornecedores a consultar."
		cHtml += ExecInPage( "PWSF020" )
	
	//��������������������������������������������������������������Ŀ
	//�Apenas 1 fornecedor cadastrado.                               �
	//� Define a navega��o para pular a tela de sele��o de Fornecedor�
	//����������������������������������������������������������������
	Case Len( HttpPost->PWSF020FOR ) == 2
		HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][2]
		cHtml += W_PWSF051()

	//�������������������������������������������������������������
	//�Mais de 1 fornecedor. Chama tela de sele��o de Fornecedores�
	//�������������������������������������������������������������
	Otherwise
		cHtml += ExecInPage( "PWSF020" )

EndCase

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF061   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para escolha de Pedidos.                               ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF051()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpSession->PWSF051APH := { STR0001, "W_PWSF052.APW", "W_PWSF054.APW" }//"Processamento de Cota��es"

//�������������������������������������������Ŀ
//� Inicializa o WS - MTSUPPLIERPURCHASEORDER �
//���������������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgURL( @oObj, "MTSUPPLIERPURCHASEORDER.APW" )

//�������������������������������������������������������������Ŀ
//�Header a ser utilizado pelas funcoes GridHeader e GridLinesEx�
//���������������������������������������������������������������
If Empty( HttpSession->PWSF051HEADER )
	HttpSession->PWSF051HEADER := { { }, { }, { } }

	//��������������������������������������Ŀ
	//� Header do Cabecalho dos Pedidos:     �
	//�-cCONTACT             : Contato       �
	//�-nCURRENCY            : Moeda         �
	//�-nCURRENCYRATE        : Taxa Moeda    �
	//�-nDISCOUNTINCASCADE1  : Desconto1     �
	//�-nDISCOUNTINCASCADE2  : Desconto2     �
	//�-nDISCOUNTINCASCADE3  : Desconto3     �
	//�-cPURCHASEORDERID     : Num.Pedido    �
	//�-cPURCHASEORDERSTATUS : Status        �
	//�-oWSPURCHASERES       : Compradores   �
	//�-dREGISTERDATE        : Dt.Emissao    �
	//�-dREGISTERDATE        : Dt.Emissao    �
	//�-cPURCHASORDERSTATUS  : Status        �
	//����������������������������������������
	oObj:cHEADERTYPE := "PURCHASEORDERHEADERVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF051HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		If Empty( HttpSession->PWSF051HEADBKP )
			HttpSession->PWSF051HEADBKP := HttpSession->PWSF051HEADER[1]
		EndIf
 	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWSF050.APW" )
	EndIf

	//��������������������������������������Ŀ
	//� Header dos Itens dos Pedidos:        �
	//�  dDELIVERYDATE       : Dt.Entrega    �
	//�  cDESCRIPTIONPRODUCT : Descricao     �
	//�  nDISCOUNTPERCENT    : % Desc.Item   �
	//�  nDISCOUNTVALUE      : Vlr. Desconto �
	//�  nEXPENSESVALUE      : Vlr. Despesas �
	//�  nFREIGHTVALUE       : Vlr. Frete    �
	//�  nINSURANCEVALUE     : Vlr. Seguro   �
	//�  cMEASUREUNIT        : U.M.          �
	//�  cNOTES              : Obsevacoes    �
	//�  cPAYMENTPLANCODE    : Cond. Pagto   �
	//�  cPRODUCTCODE        : Cod. Produto  �
	//�  cPURCHASEORDERID    : Num Pedido    �
	//�  nQUANTITY           : Quantidade    �
	//�  nQUANTITYDELIVERED  : Qtde. Entreg  �
	//�  cQUOTEID            : Num Cotacao   �
	//�  cSEQUENTIALID       : Item          �
	//�  oWSTAXES            : Impostos      �
	//�  nTOTALVALUE         : Vlr. Total    �
	//�  nUNITPRICE          : Preco Unit.   �
	//�  oWSUSERFIELDS       : Cpos Usuar.   �
	//����������������������������������������
	oObj:cHEADERTYPE := "PURCHASEORDERITEMVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF051HEADER[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWSF050.APW" )
	EndIf
EndIf

cHtml += ExecInPage( "PWSF051" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF052   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para escolha de cotacoes.                              ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF052()

Local cHtml    := ""
Local aWebCols := {}
Local oObj

 
WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpSession->PWSF051HEADBKP )
	If Len( HttpSession->PWSF051HEADER[1] ) != Len( HttpSession->PWSF051HEADBKP )
		HttpSession->PWSF051HEADER[1] := HttpSession->PWSF051HEADBKP
	EndIf
EndIf

//�������������������������������������������Ŀ
//� Inicializa o WS - MTSUPPLIERPURCHASEORDER �
//���������������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgURL( @oObj, "MTSUPPLIERPURCHASEORDER.APW" )

HttpSession->PWSF052APH := { STR0003 , "W_PWSF053.APW", "W_PWSF051.APW" } //"Resultado Busca"

If ( !Empty( HttpGet->dDELIVERYDATEFROM ) .AND. !Empty( HttpGet->dDELIVERYDATETO ) )
	HttpPost->dDELIVERYDATEFROM	:= HttpGet->dDELIVERYDATEFROM
	HttpPost->dDELIVERYDATETO	:= HttpGet->dDELIVERYDATETO
EndIf

oObj:cUSERCODE := MYUSERCODE
oObj:cSUPPLIER := HttpSession->CODFORERP
If ( !Empty( HttpPost->dDELIVERYDATEFROM ) .AND. !Empty( HttpPost->dDELIVERYDATETO ) )
	oObj:dDELIVERYDATEFROM := CToD( HttpPost->dDELIVERYDATEFROM )
	oObj:dDELIVERYDATETO   := CToD( HttpPost->dDELIVERYDATETO )
EndIf

If !Empty( HttpPost->cBuscaAv )
	Do Case
	Case HttpPost->cComboAv == "1"
		oObj:cQUERYADDWHERE	:= "SC7.C7_NUM='" + HttpPost->cBuscaAv + "'"
	EndCase
Else
	oObj:cQUERYADDWHERE	:= ""
EndIf

//���������������������������������Ŀ
//� Metodo BRWPURCHASEORDER         �
//�����������������������������������
//cUSERCODE,cSUPPLIER,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERE
If oObj:BRWPURCHASEORDER()
	HttpSession->PWSF052RESULT := oObj:oWSBRWPURCHASEORDERRESULT:oWSPURCHASEORDERHEADERVIEW
	HttpSession->PWSF052INFO := { }
Else
	Return PWSHtmlAlert( "", STR0004 , "", "W_PWSF050.APW" ) // Atencao
EndIf

//���������������������������Ŀ
//� Cabecalhos dos Pedidos    �
//�����������������������������
aWebCols := { }
If ExistBlock( "PEF052" )
	aWebCols := ExecBlock( "PEF052", .F., .F., {} )
EndIf

GridHeader(	HttpSession->PWSF052INFO, ;
			HttpSession->PWSF051HEADER[1], ;
			aWebCols )

GridLinesEx( {	HttpSession->PWSF052INFO, ;
				HttpSession->PWSF051HEADER[1], ;
				HttpSession->PWSF052RESULT, ;
				aWebCols, .F., "A", NIL, 0 } )

cHtml += ExecInPage( "PWSF052" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF053   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para detalhes dos Pedidos.                             ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF053()

Local cHtml		:= ""
Local aWebCols 	:= {}
Local nI		:= 0
Local nDespesas	:= 0
Local nFrete	:= 0
Local nSeguro	:= 0
Local nTotal	:= 0
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->cPedido )
   HttpGet->cCotacao := HttpPost->cPedido
EndIf

HttpSession->PWSF053APH := { STR0005 + HttpGet->cPedido, "W_PWSF054.APW", "W_PWSF052.APW" } //"Pedido N�mero: "

//�������������������������������������������Ŀ
//� Inicializa o WS - MTSUPPLIERPURCHASEORDER �
//���������������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgURL( @oObj, "MTSUPPLIERPURCHASEORDER.APW" )

oObj:cUSERCODE			:= MYUSERCODE
oObj:cPURCHASEORDERID	:= HttpGet->cPedido
oObj:cSUPPLIER			:= HttpSession->CODFORERP
//cUSERCODE,cPURCHASEORDERID,cSUPPLIER,cQUERYADDWHERE
If oObj:GETPURCHASEORDER()
	HttpSession->PWSF053RESULT	:= { oObj:oWSGETPURCHASEORDERRESULT }
	HttpSession->PWSF053INFO	:= { { }, { } }
	HttpSession->PWSF053TOTAIS	:= { }

	//���������������������������Ŀ
	//�   - C A B E C A L H O -   �
	//�����������������������������
	aWebCols := { }
	If ExistBlock( "PEF053" )
		aWebCols := ExecBlock( "PEF053", .F., .F., { 1 } )
	EndIf

	GridLinesEx( {	Httpsession->PWSF053INFO[1] ,;
					HttpSession->PWSF051HEADER[1],;
					HttpSession->PWSF053RESULT[1]:oWSPOHEADER,;
					aWebCols, .F., "H", NIL, 0 },;
					"MTSUPPLIERPURCHASEORDER", "SC7" )

	//���������������������������Ŀ
	//�   -     I T E N S     -   �
	//�����������������������������
	aWebCols := { }
	If ExistBlock( "PEF053" )
		aWebCols := ExecBlock( "PEF053", .F., .F., { 2 } )
	EndIf

	GridHeader(		HttpSession->PWSF053INFO[2], ;
					HttpSession->PWSF051HEADER[2], ;
					aWebCols, ;
					HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW, ;
					"MTSUPPLIERPURCHASEORDER", "SC7" )

	GridLinesEx( {	HttpSession->PWSF053INFO[2], ;
					HttpSession->PWSF051HEADER[2], ;
					HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW, ;
					aWebCols, .F., "A",, 0 }, ;
					"MTSUPPLIERPURCHASEORDER", "SC7" )

	//���������������������������Ŀ
	//�   -    T O T A I S    -   �
	//�����������������������������
	For nI := 1 To Len( HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW )
		nTotal		+= HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW[nI]:nTOTALVALUE
		nSeguro		+= HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW[nI]:nINSURANCEVALUE
		nDespesas	+= HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW[nI]:nEXPENSESVALUE
		nFrete		+= HttpSession->PWSF053RESULT[1]:oWSPOITEM:oWSPURCHASEORDERITEMVIEW[nI]:nFREIGHTVALUE
	Next nI
	aAdd( HttpSession->PWSF053TOTAIS, Transform( nTotal,	"@E 99,999,999.99" ))
	aAdd( HttpSession->PWSF053TOTAIS, Transform( nSeguro,	"@E 99,999,999.99" ))
	aAdd( HttpSession->PWSF053TOTAIS, Transform( nDespesas,	"@E 99,999,999.99" ))
	aAdd( HttpSession->PWSF053TOTAIS, Transform( nFrete,	"@E 99,999,999.99" ))

	cHtml += ExecInPage( "PWSF053" )

Else
	Return PWSHtmlAlert( "", STR0004 , "", "W_PWSF050.APW" ) //atencao
EndIf

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF053A  �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para detalhes de itens do Pedido.                      ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF053A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF053A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF054   �Autor  � Flavio Luiz Vicco   � Data �  21/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     �  Mostra detalhes das taxas dos de itens do Pedido.          ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSF054()

Local cHtml := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():NEW())
WsChgURL( @oObj, "MTSUPPLIERPURCHASEORDER.APW" )

HttpSession->PWSF054INFO := { }

If Empty( HttpSession->PWSF051HEADER[3] )
	HttpSession->PWSF051HEADER[3] := {}

	oObj:cHEADERTYPE := "TAXESVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF051HEADER[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWSF050.APW" )
	EndIf
EndIf

If ExistBlock( "PEF054" )
	aWebCols := ExecBlock( "PEF054", .F., .F., {} )
EndIf

GridHeader(	HttpSession->PWSF054INFO, ;
			HttpSession->PWSF051HEADER[3] ,;
			aWebCols )

GridLinesEx( {	HttpSession->PWSF054INFO, ;
				HttpSession->PWSF051HEADER[3], ;
				HttpSession->PWSF053RESULT[1]:OWSPOITEM:OWSPURCHASEORDERITEMVIEW[ Val( HttpGet->cCod ) ]:OWSTAXES:OWSTAXESVIEW, ;
				aWebCols, .F., "A",, 0 }  )

cHtml += ExecInPage( "PWSF054" )

WEB EXTENDED END

Return cHtml
