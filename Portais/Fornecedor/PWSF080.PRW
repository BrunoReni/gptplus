#INCLUDE "PWSF080.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF08*   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado ao         ���
���          � Documento de Entrada                                        ���
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
���Programa  �PWSF080   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os Fornecedores disponiveis para o usuario logado.   ���
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
Web Function PWSF080()

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
HttpSession->PWSF020APH := { STR0001, "W_PWSF081.APW", "" }//"Documento de Entrada"

Do Case
	//�������������������������������������������������������
	//�Nao ha fornecedores cadastrados para o usuario logado�
	//�������������������������������������������������������
	Case Empty( HttpPost->PWSF020FOR )
		HttpSession->PWSF020APH[3] := "" //"N�o h� clientes a consultar."
		cHtml += ExecInPage( "PWSF020" )

	//��������������������������������������������������������������Ŀ
	//�Apenas 1 fornecedor cadastrado.                               �
	//� Define a navega��o para pular a tela de sele��o de Fornecedor�
	//����������������������������������������������������������������
	Case Len( HttpPost->PWSF020FOR ) == 2	
		HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][2]
		cHtml += W_PWSF081()

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
���Programa  �PWSF081   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de Busca dos Documentos de Entrada do Fornecedor.      ���
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
Web Function PWSF081()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

If Empty( HttpSession->PWSF081HEADER )
	HttpSession->PWSF081HEADER := { { }, { } }
	
	//�����������������������������������������Ŀ
	//� HEADER Cabecalho - Documento de Entrada �
	//�������������������������������������������
	oObj:cHEADERTYPE := "INVOICEHEADERVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF081HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" ) //"Erro"
	EndIf

	//�����������������������������������������Ŀ
	//� HEADER Itens - Documento de Entrada     �
	//�������������������������������������������
	oObj:cHEADERTYPE := "INVOICEITEMVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF081HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" ) //"Erro"
	EndIf
EndIf

HttpSession->PWSF081APH := { STR0001, "W_PWSF082.APW", "W_PWSF084.APW" } //"Documento de Entrada"

cHtml += ExecInPage( "PWSF081" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF082   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de resultado da busca dos Documentos de Entrada.       ���
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
Web Function PWSF082()

Local cHtml 	:= ""
Local aWebCols 	:= {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

HttpSession->PWSF082APH := { STR0001+" - "+STR0003, "W_PWSF083.APW" }//"Documento de Entrada"###"Resultado Busca"

If !Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO )
	HttpPost->dREGISTERDATEFROM	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO	:= HttpGet->dREGISTERDATETO
EndIf

oObj:cUSERCODE				:= GetUsrCode()
oObj:nCUSTOMERORSUPPLIER	:= 2
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP
oObj:dREGISTERDATEFROM		:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO		:= CToD( HttpPost->dREGISTERDATETO )
oObj:dDELIVERYDATEFROM		:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dDELIVERYDATETO		:= CToD( HttpPost->dREGISTERDATETO )
oObj:cOperationType  		:= "E"

If !Empty( HttpPost->cBuscaAv )
	Do Case
		Case HttpPost->cComboAv == "1"
			oObj:cQUERYADDWHERENFE := "SF1.F1_DOC='" + HttpPost->cBuscaAv + "'"
	EndCase
Else
	oObj:cQUERYADDWHERENFE := ""
EndIf

//cUSERCODE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,dREGISTERDATEFROM,dREGISTERDATETO,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERENFE,cQUERYADDWHERENFS,cINDEXKEYNFE,cINDEXKEYNFS,cPURCHASENUMBER
If oObj:BRWINVOICE()
	HttpSession->PWSF082RESULT	:= { oObj:oWSBRWINVOICERESULT:oWSINVOICEHEADERVIEW }
	HttpSession->PWSF082INFO	:= { }

	If ExistBlock( "PEF082" )
		aWebCols := ExecBlock( "PEF082", .F., .F., { } )
	Else
		aAdd ( aWebCols, "INVOICENUMBER" )
		aAdd ( aWebCols, "SERIALNUMBER" )
		aAdd ( aWebCols, "INVOICETYPE" )
		aAdd ( aWebCols, "DOCUMENTTYPE" )
		aAdd ( aWebCols, "INVOICEDATE" )
		aAdd ( aWebCols, "REGISTERDATE" )
		aAdd ( aWebCols, "INVOICESTATUS" )
	EndIf

	GridHeader(		HttpSession->PWSF082INFO, ;
					HttpSession->PWSF081HEADER[1][1], ;
					aWebCols )

	GridLinesEx( {	HttpSession->PWSF082INFO, ;
					HttpSession->PWSF081HEADER[1][1], ;
					HttpSession->PWSF082RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSF082" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF083   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de visualizacao dos Documentos de Entrada.             ���
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
Web Function PWSF083()

Local cHtml 	:= ""
Local aWebCols 	:= {}
Local nI		:= 0
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

aNota := Separa( HttpGet->cNota, "|" )

HttpSession->PWSF083APH := { STR0004 + aNota[1] + " / " + aNota[2] + " / " +  ; //"Documento de Entrada N�mero : "
								aNota[3] , "W_PWSF082.APW" }

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

oObj:cUSERCODE				:= GetUsrCode()
oObj:cINVOICETYPE			:= aNota[3]
oObj:cSERIALNUMBER			:= aNota[2]
oObj:cINVOICENUMBER			:= aNota[1]
oObj:cDOCUMENTTYPE			:= aNota[4]
oObj:nCUSTOMERORSUPPLIER	:= 2
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP

//cUSERCODE,cINVOICETYPE,cSERIALNUMBER,cINVOICENUMBER,cDOCUMENTTYPE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,cQUERYADDWHERENFE,cQUERYADDWHERENFS
If oObj:GETINVOICE()
	HttpSession->PWSF083RESULT	:= { oObj:oWSGETINVOICERESULT }
	HttpSession->PWSF083INFO	:= { { }, { }, { } }
	HttpSession->PWSF083CQ		:= { }

	aWebCols := { }	
	If ExistBlock( "PEF083" )
		aWebCols := ExecBlock( "PEF083", .F., .F., { 1 } )
	Else
		aAdd ( aWebCols, "INVOICENUMBER" )
		aAdd ( aWebCols, "SERIALNUMBER" )
		aAdd ( aWebCols, "INVOICEDATE" )
		aAdd ( aWebCols, "REGISTERDATE" )
		aAdd ( aWebCols, "EXPENSESVALUE" )
		aAdd ( aWebCols, "INSURANCEVALUE" )
		aAdd ( aWebCols, "REIGHTVALUE" )
		aAdd ( aWebCols, "TOTALVALUE" )
	EndIf

	GridLinesEx( {	HttpSession->PWSF083INFO[1], ;
					HttpSession->PWSF081HEADER[1][1], ;
					HttpSession->PWSF083RESULT[1]:oWSINVOICEHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTSUPPLIERQUOTE", "SF1" )
	
	aAdd( HttpSession->PWSF083CQ, "" )
	
	For nI := 1 To Len( HttpSession->PWSF083RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW )
		aAdd( HttpSession->PWSF083CQ, HttpSession->PWSF083RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cQUALITYCONTROLDOCUMENT )
	Next nI

	aWebCols := { }
	If ExistBlock( "PEF083" )
		aWebCols := ExecBlock( "PEF083", .F., .F., { 2 } )
	EndIf

	GridHeader(		HttpSession->PWSF083INFO[2], ;
					HttpSession->PWSF081HEADER[2][1], ;
					aWebCols ,;
            	    HttpSession->PWSF083RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW )   

	GridLinesEx( {	HttpSession->PWSF083INFO[2], ;
					HttpSession->PWSF081HEADER[2][1], ;
					HttpSession->PWSF083RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW, ;
					aWebCols, .F., "A",, 0 } , "MTSUPPLIERQUOTE", "SD1" )

	cHtml += ExecInPage( "PWSF083" )

Else
	Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" ) //"Erro"
EndIf


WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF083A  �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de visualizacao dos detalhes dos itens dos             ���
���          � dos Documentos de Entrada.                                  ���
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
Web Function PWSF083A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF083A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF078   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para controle de qualidade.                            ���
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
Web Function PWSF084()

Local cHtml 	:= ""
Local aWebCols 	:= {}
Local nI		:= 0
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSF084APH := { STR0005 + HttpGet->cCQ, "W_PWSF082.APW" }//"Controle de Qualidade N�mero : "

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTQUALITYCONTROL"), WSMTQUALITYCONTROL():NEW())
WsChgUrl( @oObj, "MTQUALITYCONTROL.apw" )

If Empty( HttpSession->PWSF084HEADER )
	HttpSession->PWSF084HEADER := { {}, {} }

	oObj:cHEADERTYPE := "QUALITYCONTROLVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF084HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" )//"Erro"
	EndIf

	oObj:cHEADERTYPE := "QUALITYCONTROLTRANSACTIONSVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF084HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" )//"Erro"
	EndIf
EndIf

oObj:cUSERCODE := GetUsrCode()
oObj:cDOCUMENT := HttpGet->cCQ

//cUSERCODE,cDOCUMENT
If oObj:GETQUALITYCONTROL()
	HttpSession->PWSF084RESULT := { oObj:oWSGETQUALITYCONTROLRESULT }
	HttpSession->PWSF084INFO := { {}, {} }
	HttpSession->PWSF084DOC := {}
	
	If ExistBlock( "PEF084" )
		aWebCols := ExecBlock( "PEF084", .F., .F., { 1 } )
	EndIf

	GridLinesEx( { HttpSession->PWSF084INFO[1], ;
					HttpSession->PWSF084HEADER[1][1], ;
					HttpSession->PWSF084RESULT[1], ;
					aWebCols, .F., "H",, 0 } )
					
	aAdd( HttpSession->PWSF084DOC, "" )
	
	For nI := 1 To Len( HttpSession->PWSF084RESULT[1]:oWSTRANSACTIONS:oWSQUALITYCONTROLTRANSACTIONSVIEW )
		aAdd( HttpSession->PWSF084DOC, HttpSession->PWSF084RESULT[1]:oWSTRANSACTIONS:oWSQUALITYCONTROLTRANSACTIONSVIEW[nI]:cCERTIFICATE )
	Next nI

	If ExistBlock( "PEF084" )
		aWebCols := ExecBlock( "PEF084", .F., .F., { 2 } )
	EndIf

	GridHeader(	HttpSession->PWSF084INFO[2], ;
					HttpSession->PWSF084HEADER[2][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSF084INFO[2], ;
					HttpSession->PWSF084HEADER[2][1], ;
					HttpSession->PWSF084RESULT[1]:oWSTRANSACTIONS:oWSQUALITYCONTROLTRANSACTIONSVIEW, ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0002, "", "W_PWSF080.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSF084" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF078A  �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para detalhes de transacoes.                           ���
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
*/Web Function PWSF084A()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF084A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF085   �Autor  � Flavio Luiz Vicco   � Data �  28/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para documento de controle de qualidade.               ���
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
Web Function PWSF085()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSF084APH := { STR0006, "W_PWSF082.APW" }//"Documento Controle de Qualidade"

cHtml += ExecInPage( "PWSF085" )

WEB EXTENDED END

Return cHtml
