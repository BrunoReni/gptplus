#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSF100.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE FORNECERP_ENTIDADE 1
#DEFINE FORNECERP_CODIGO   2
#DEFINE FORNECERP_NOMEFANT 3
#DEFINE FORNECERP_RAZAOSOC 4
#DEFINE FORNECERP_CPFCNPJ  5

#DEFINE MYUSERCODE GetUsrCode()

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF10*   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a          ���
���          � Alteracao dos Dados Cadastrais do Fornecedor.               ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Coments.  �Funcoes Pertinentes ao Menu Financeiro (fornecedores):       ���
���          � T�tulos Baixados	[Ok]         W_PWSF100                     ���
���          �                                                             ���
���          �Aphs Envolvidos :                                            ���
���          � PWSF020.APH Sele��o de Fornecedores                         ���
���          � PWSF101.APH Browse de Baixas                                ���
���          � PWSF102.APH Detalhes das Baixas                             ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF100   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os fornecedores disponiveis para o usuario logado.   ���
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
Web Function PWSF100()

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
HttpSession->PWSF020APH := { STR0001 , ;  // Titulo
                              "W_PWSF101A.APW", ;     // Proxima Tela
                              "" }                    // Msg de Erro

Do Case
	//�������������������������������������������������������
	//�Nao ha fornecedores cadastrados para o usuario logado�
	//�������������������������������������������������������
	Case Empty( HttpPost->PWSF020FOR )
		HttpSession->PWSF020APH[3] := STR0002 //"N�o h� Fornecedores a consultar."
		cHtml += ExecInPage( "PWSF020" )
	
	//��������������������������������������������������������������Ŀ
	//�Apenas 1 fornecedor cadastrado.                               �
	//� Define a navega��o para pular a tela de sele��o de Fornecedor�
	//����������������������������������������������������������������
	Case Len( HttpPost->PWSF020FOR ) == 2	
		HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][FORNECERP_CODIGO]	
		cHtml += W_PWSF101A()

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
���Programa  �PWSF101A  �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de Busca dos Titulos Baixados do Fornecedor.           ���
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
Web Function PWSF101A()

Local cHtml    := ""
Local aWebCols := {}
Local oObj
Local oObjIndex

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF101AAPH := { STR0001, ;  //"T�tulos Baixados"
                              "W_PWSF101.APW", ;      //Proxima Tela
                              "W_PWSF100.APW" }       //Pagina de retorno

//����������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESUPPLIERBILL�
//������������������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WSChgURL( @oObjIndex, "CFGDICTIONARY.APW" )

//�������������������������������������������������������������Ŀ
//�Header a ser utilizado pelas funcoes GridHeader e GridLinesEx�
//���������������������������������������������������������������
If Empty( HttpSession->PWSF101HEADER )
   HttpSession->PWSF101HEADER := { NIL, NIL, NIL }

   //���������������������������������������������Ŀ
   //�Header da estrutura BILLVIEW - Cabec Titulo: �
   //�PREFIX                : Prefixo              �
   //�BILLNUMBER            : No. Titulo           �
   //�INSTALLMENT           : Parcela              �
   //�BILLTYPE              : Tipo                 �
   //�CUSTOMERCODE          : Cliente              �
   //�UNITCUSTOMERCODE      : Loja                 �
   //�CUSTOMERNAME          : Nome                 �
   //�CLASSCODE             : Natureza             �
   //�ISSUEDATE             : DT Emissao           �
	//�ORIGINALDUEDATE       : Vencto Orig          �
	//�REALDUEDATE           : Vencto Real          �
	//�CURRENCY              : Moeda                �
	//�CURRENCYSYMBOL        : Moeda                �
	//�ORIGINALVALUE         : Vlr. Titulo          �
	//�ORIGINALCURRENCYVALUE : Vlr. R$              �
	//�DEDUCTIONSVALUE       : Abatimento           �
	//�DEDUCTIONSVALUE       : Sld.Acresc.          �
	//�INCREASEVALUE         : Sld.Decresc.         �
	//�BALANCEVALUE          : Saldo                �
	//�BALANCECURRENCYVALUE  : Saldo                �
	//�BANK                  : Portador             �
	//�HISTORY               : Historico            �
	//�DELAYINDATES          : Atrasados            �
	//�DELAYINTERESTRATE     : Porc Juros           �
	//�DELAYINTERESTVALUE    : Taxa Perman.         �
   //�����������������������������������������������
   oObj:cHEADERTYPE := "BILLVIEW"
   If oObj:GETHEADER()
      HttpSession->PWSF101HEADER[1] := { oObj:oWSGetHEADERRESULT:oWSBRWHEADER }
   Else
      Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
   EndIf

   //���������������������������������������������������Ŀ
   //�Header da estrutura PAIDBILLCOLLECTION - Titulo bxs�
   //�����������������������������������������������������
   oObj:cHEADERTYPE := "PAIDBILLVIEW"
   If oObj:GETHEADER()
      HttpSession->PWSF101HEADER[2] := { oObj:oWSGetHEADERRESULT:oWSBRWHEADER }
   Else
      Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
   EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSF101HEADER[3] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSF101HEADER[3] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
		EndIf
	EndIf

EndIf //If Empty

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSF101INDEX )
	HttpSession->PWSF101INDEX := {}
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SE2" // Tabela: Contas a Pagar
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSF101INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSF101AINFO )
	HttpSession->PWSF101AINFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEF101A" )
		aWebCols := ExecBlock( "PEF101A", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   GridHeader( HttpSession->PWSF101AINFO, ;
               HttpSession->PWSF101HEADER[3][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
   GridLinesEx( { HttpSession->PWSF101AINFO, ;
               HttpSession->PWSF101HEADER[3][1], ;
               HttpSession->PWSF101INDEX[1], ;
               aWebCols, .F., "A", NIL, 0 } )
EndIf

cHtml += ExecInPage( "PWSF101A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF101   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com Browse dos Titulos baixados do Fornecedor.         ���
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
Web Function PWSF101()

Local cHtml    := ""
Local nPos     := 0
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpSession->PWSF101APH := { STR0001 , ;   //Titulo baixados
                              "W_PWSF102.APW", ;      //Proxima Tela
                              "W_PWSF101A.APW" }       //Pagina de retorno

HttpSession->PWSF101INFO := { }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR , {|x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

   If nPos > 0
      HttpSession->PWSF101APH[1] := STR0001+": "+HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC]

      //����������������������������������������������Ŀ
      //�Inicializa o objeto WS - WSFINANCESUPPLIERBILL�
      //������������������������������������������������
      oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
      WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

      //��������������������������������Ŀ
      //�Parametros do metodo BRWPAIDBILL�
      //����������������������������������
      oObj:cUSERCODE      := MYUSERCODE
      oObj:cSUPPLIERID    := HttpSession->CODFORERP
      oObj:dDATEFROM      := CToD( HttpPost->dDATEFROM )
      oObj:dDATETO        := CToD( HttpPost->dDATETO )
      oObj:cQUERYADDWHERE := ""
      oObj:cINDEXKEY      := HttpPost->cINDEX
      //cUSERCODE,cSUPPLIERID,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
      If oObj:BRWPAIDBILL()
         HttpSession->PWSF101RESULT := { oObj:oWSBRWPAIDBILLRESULT:oWSBILLVIEW }
      Else
         Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF100.APW" )
      EndIf

      //���������������������������Ŀ
      //�Verifica Resultado da Busca�
      //�����������������������������
      If !Empty( HttpSession->PWSF101RESULT ) .AND. Len( HttpSession->PWSF101RESULT[1] ) > 0

         //���������������������������Ŀ
         //� Cabecalho dos Titulos     �
         //�����������������������������
         If ExistBlock( "PEF101" )
            aWebCols := ExecBlock( "PEF101", .F., .F., {} )
         Else
            aAdd( aWebCols, "PREFIX" )
            aAdd( aWebCols, "BILLNUMBER" )
            aAdd( aWebCols, "INSTALLMENT" )
            aAdd( aWebCols, "BILLTYPE" )
            aAdd( aWebCols, "ISSUEDATE" )
            aAdd( aWebCols, "REALDUEDATE" )
         EndIf
        
         GridHeader( HttpSession->PWSF101INFO, ;
                     HttpSession->PWSF101HEADER[1][1], ;
                     aWebCols ,;
                     HttpSession->PWSF101RESULT[1], "FINANCESUPPLIERBILL", "SE2" )

         GridLinesEx( { HttpSession->PWSF101INFO, ;
                        HttpSession->PWSF101HEADER[1][1], ;
                        HttpSession->PWSF101RESULT[1], ;
                        aWebCols, .F., "A", NIL, 0 }, "FINANCESUPPLIERBILL", "SE2" )

         cHtml += ExecInPage( "PWSF101" )

      Else
	      Return PWSHtmlAlert( "", STR0003 , STR0004 , "W_PWSF100.APW" ) //"A busca n�o retornou nenhuma titulo para este fornecedor no per�odo solicitado."
      EndIf

   EndIf //If nPos > 0

EndIf

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF102   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de detalhes dos titulos baixados.                      ���
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
Web Function PWSF102()

Local cHtml    := ""
Local nPosTit  := 0
Local nPos     := 0
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSF102APH := { 	STR0005 + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cPREFIX + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cBILLNUMBER + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cINSTALLMENT + ;
                              HttpSession->PWSF101RESULT[1][nPosTit]:cBILLTYPE, ;
                              STR0006 , ;
                              "W_PWSF101A.APW" }        //Pagina de Volta


HttpSession->PWSF102INFO   := { { }, { } }

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf


If nPosTit > 0

	nPosFor := aScan( HttpSession->PWSF020FOR, { |x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

	If nPosFor > 0
		//������������������������������������������������Ŀ
		//� Inicializa o objeto WS - WSFINANCESUPPLIERBILL �
		//��������������������������������������������������
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERBILL"), WSFINANCESUPPLIERBILL():New())
		WSChgURL( @oObj, "FINANCESUPPLIERBILL.APW" )

		//���������������������������������Ŀ
		//� Metodo GETPAIDBILL              �
		//�����������������������������������
		//cUSERCODE,cSUPPLIERID,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
		oObj:cUSERCODE    := MYUSERCODE
		oObj:cSUPPLIERID  := HttpSession->CODFORERP
		oObj:cPREFIX      := HttpSession->PWSF101RESULT[1][nPosTit]:cPREFIX
		oObj:cBILLNUMBER  := HttpSession->PWSF101RESULT[1][nPosTit]:cBILLNUMBER
		oObj:cINSTALLMENT := HttpSession->PWSF101RESULT[1][nPosTit]:cINSTALLMENT
		oObj:cBILLTYPE    := HttpSession->PWSF101RESULT[1][nPosTit]:cBILLTYPE
		If oObj:GETPAIDBILL()
			HttpSession->PWSF102RESULT := { oObj:oWSGETPAIDBILLRESULT }

			If ExistBlock( "PEF102" )
				aWebCols := ExecBlock( "PEF102", .F., .F., {1} )
			EndIf

			// --- Temporario : Necessario criar estrutura separada do Ctas a Receber (BILLVIEW)
			If (nPos := aScan(HttpSession->PWSF101HEADER[1][1],{|x| AllTrim(x:cHeaderTitle) == "Cliente"})) >0 
				HttpSession->PWSF101HEADER[1][1][nPos]:cHeaderTitle := STR0011 // "Fornecedor"
			EndIf

			GridLinesEx( { 	HttpSession->PWSF102INFO[1], ;
							HttpSession->PWSF101HEADER[1][1], ;
							HttpSession->PWSF102RESULT[1]:oWSBILL, ;
							aWebCols, .F., "H", NIL, 0 }, "FINANCESUPPLIERBILL", "SE2" )

			//������������������������Ŀ
			//�Ponto de Entrada - Baixa�
			//��������������������������
			If ExistBlock( "PEF102" )
				aWebCols := ExecBlock( "PEF102", .F., .F., { 2 } )
			EndIf

			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridHeader( HttpSession->PWSF102INFO[2], ;
						HttpSession->PWSF101HEADER[2][1], ;
						aWebCols ,;
						HttpSession->PWSF102RESULT[1]:oWSPAYMENT:oWSPAIDBILLVIEW, "FINANCESUPPLIERBILL", "SE5" )

			//��������������������������������������������������Ŀ
			//�Funcao de montagem da descricao dos campos da tela�
			//����������������������������������������������������
			GridLinesEx( {	HttpSession->PWSF102INFO[2], ;
							HttpSession->PWSF101HEADER[2][1], ;
							HttpSession->PWSF102RESULT[1]:oWSPAYMENT:oWSPAIDBILLVIEW, ;
							aWebCols, .F., "A", NIL, 0 }, "FINANCESUPPLIERBILL", "SE5" )

		Else
			Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF101.APW" )
		EndIf
	Else
		Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF101.APW" )
	EndIf

	cHtml += ExecInPage( "PWSF102" )

EndIf

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF102A  �Autor  � Flavio Luiz Vicco   � Data �  22/09/05   ���
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
Web Function PWSF102A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF102A" )

WEB EXTENDED END

Return cHtml
