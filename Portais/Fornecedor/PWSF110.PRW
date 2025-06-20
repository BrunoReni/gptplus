#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSF110.CH"

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
���Programa  �PWSF11*   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a          ���
���          � Alteracao dos Dados Cadastrais do Fornecedor.               ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Coments.  �Funcoes Pertinentes ao Menu Financeiro (fornecedores):       ���
���          � Notas de Debito [Ok] W_PWSF110                              ���
���          �                                                             ���
���          �Aphs Envolvidos :                                            ���
���          � PWSF020.APH     Sele��o de Fornecedores                     ���
���          � PWSF111.APH     Browse de Notas de Debito                   ���
���          � PWSF112.APH     Detalhes das Notas de Debito                ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF026   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os fornecedores disponives para o usuario logado.    ���
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
Web Function PWSF110()

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
HttpSession->PWSF020APH := { STR0001 , ;  // "Notas de D�bito"
                              "W_PWSF111A.APW", ;   // Proxima Tela
                              "" }                  // Msg de Erro

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
      cHtml += W_PWSF111A()

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
���Programa  �PWSF111A  �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de Busca das Notas de Debito do Fornecedor.            ���
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
Web Function PWSF111A()

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
HttpSession->PWSF111AAPH := { STR0001 , ;   //"Notas de D�bito"
                              "W_PWSF111.APW", ;      //Proxima Tela
                              "W_PWSF110.APW" }       //Pagina de retorno

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
If Empty( HttpSession->PWSF111HEADER )
   HttpSession->PWSF111HEADER := { NIL, NIL }

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
      HttpSession->PWSF111HEADER[1] := { oObj:oWSGetHEADERRESULT:OWSBRWHEADER }
   Else
      Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF110.APW" )
   EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSF111HEADER[2] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSF111HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF020.APW" )
		EndIf
	EndIf

EndIf //If Empty(

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSF111INDEX )
	HttpSession->PWSF111INDEX := {}
	
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
		HttpSession->PWSF111INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF020.APW" )
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSF111AINFO )
	HttpSession->PWSF111AINFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEF111A" )
		aWebCols := ExecBlock( "PEF111A", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   GridHeader( HttpSession->PWSF111AINFO, ;
               HttpSession->PWSF111HEADER[2][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
   GridLinesEx( { HttpSession->PWSF111AINFO, ;
               HttpSession->PWSF111HEADER[2][1], ;
               HttpSession->PWSF111INDEX[1], ;
               aWebCols, .F., "A", NIL, 0 } )
EndIf

cHtml += ExecInPage( "PWSF111A" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF111   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     �Segunda Tela : Consulta de Notas de Debito                   ���
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
Web Function PWSF111()

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

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF111APH := { STR0001 , ;   //"Notas de D�bito"
                              "W_PWSF112.APW", ;     // Proxima Tela
                              "W_PWSF111A.APW" }     //Pagina de retorno

HttpSession->PWSF111INFO := { }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR , {|x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } ) 

   If nPos > 0
      HttpSession->PWSF111APH[1] := STR0001+" : "+HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC]

      //�������������������������������������������������������������Ŀ
      //�Header a ser utilizado pelas funcoes GridHeader e GridLinesEx�
      //���������������������������������������������������������������

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
      oObj:cQUERYADDWHERE := ""
      oObj:cINDEXKEY      := HttpPost->cINDEX
      //cUSERCODE,cSUPPLIERID,cQUERYADDWHERE,cINDEXKEY
      If oObj:BRWDEBITNOTE()
         HttpSession->PWSF111RESULT := { oObj:oWSBRWDEBITNOTERESULT:oWSBILLVIEW }
      Else
         Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF110.APW" )
      EndIf

      //���������������������������Ŀ
      //�Verifica Resultado da Busca�
      //�����������������������������
      If !Empty( HttpSession->PWSF111RESULT ) .AND. Len( HttpSession->PWSF111RESULT[1] ) > 0

         //���������������������������Ŀ
         //� Cabecalho dos Titulos     �
         //�����������������������������
         If ExistBlock( "PEF111" )
            aWebCols := ExecBlock( "PEF111", .F., .F., {} )
         EndIf

         GridHeader( HttpSession->PWSF111INFO, ;
                     HttpSession->PWSF111HEADER[1][1], ;
                     aWebCols )

         GridLinesEx( { HttpSession->PWSF111INFO, ;
                        HttpSession->PWSF111HEADER[1][1], ;
                        HttpSession->PWSF111RESULT[1], ;
                        aWebCols, .F., "A", NIL, 0 } )

         cHtml += ExecInPage( "PWSF111" )

      Else
	      Return PWSHtmlAlert( "", STR0003 , STR0004 , "W_PWSF110.APW" ) //"A busca n�o retornou nenhuma nota de d�bito para este fornecedor no per�odo solicitado."
      EndIf

   EndIf //If nPos > 0

EndIf

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF112   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     �Tela de Zoom de Nota de Debito                               ���
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
Web Function PWSF112()

Local cHtml    := ""
Local nPosTit  := 0
Local aWebCols := {}


WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

HttpSession->PWSF112APH := { STR0001 , ;   //"Notas de D�bito"
                              "W_PWSF111.APW" }      //Pagina de retorno


HttpSession->PWSF112INFO := { }

nPosTit := Val( HttpGet->cTitulo )

If nPosTit > 0

	If ExistBlock( "PEF112" )
		aWebCols := ExecBlock( "PEF112", .F., .F., {} )
	EndIf        

	GridLinesEx( {	HttpSession->PWSF112INFO ,;
                  HttpSession->PWSF111HEADER[1][1],;
                  HttpSession->PWSF111RESULT[1][nPosTit], aWebCols, .F., "H",,0 } )
           	
	cHtml += ExecInPage( "PWSF112" )

Else
	// Caso n�o tenha recebido o t�tulo a visualizar 
	// via post , retorna o browse de Titulos
	cHtml += ExecInPage( "PWSF111" )
EndIf

WEB EXTENDED END

Return cHtml
