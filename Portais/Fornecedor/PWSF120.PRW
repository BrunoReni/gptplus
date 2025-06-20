#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSF120.CH"

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
���Programa  �PWSF12*   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a          ���
���          � Consulta da Ficha Financeira do Fornecedor.                 ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���          �Aphs Envolvidos :                                            ���
���          � PWSF120.APH 		Ficha Financeira                          ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSF120   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     �Tela de Selecao de Fornecedor - Ficha Financeira             ���
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
Web Function PWSF120()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//�Fornecedores cadastrados para o usuario logado�
//������������������������������������������������
HttpPost->PWSF020FOR	:= GetUserFor()
HttpSession->PWSF020FOR := HttpPost->PWSF020FOR

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSF020APH := {	STR0001 , ;  // "Ficha Cadastral"
										"W_PWSF121.APW", ;    // Pagina de Post
										""	} 					    // Msg de Erro

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
      cHtml += W_PWSF121()

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
���Programa  �PWSF121   �Autor  � Flavio Luiz Vicco   � Data �  22/09/2005 ���
��������������������������������������������������������������������������͹��
���Desc.     �Consulta da Ficha Financeira do Fornecedor                   ���
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
Web Function PWSF121()

Local cHtml    := ""
Local aWebCols := { }
Local nPos     := 0
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//����������������������������������������������Ŀ
//� Fornecedor Selecionado                       �
//������������������������������������������������
If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSF121INFO := { }

If !Empty( HttpSession->CODFORERP )
   nPos := aScan( HttpSession->PWSF020FOR, { |x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )

   If nPos > 0

      //���������������������������������������Ŀ
      //�Informacoes a serem utilizadas pelo APH�
      //�����������������������������������������
      HttpSession->PWSF121APH := { STR0001+" : " + HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC],  ; // Titulo
                                   "W_PWSF120.APW" }     // Pagina de Volta

      //������������������������������������������Ŀ
      //� Inicializa o WS - FINANCESUPPLIERREGFORM �
      //��������������������������������������������
      oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSFINANCESUPPLIERREGFORM"), WSFINANCESUPPLIERREGFORM():NEW())
      WsChgUrl( @oObj,"FINANCESUPPLIERREGFORM.APW" )

      If Empty( HttpSession->PWSF121HEADER )
         HttpSession->PWSF121HEADER := { NIL }

         //�����������������������������������Ŀ
         //� Metodo GETHEADER                  �
         //�������������������������������������
         //NULLPARAM
         If oObj:GETHEADER()
            HttpSession->PWSF121HEADER := { oObj:oWSGetHEADERRESULT:OWSBRWHEADER }
         Else
   	      Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF120.APW" )
         EndIf
      EndIf

      //�����������������������������������Ŀ                                                           	
      //� Metodo GETREGFORM                 �
      //�������������������������������������
      //cUSERCODE,cSUPPLIERID
      oObj:cUSERCODE   := MYUSERCODE
      oObj:cSUPPLIERID := HttpPost->CODFORERP
      If oObj:GETREGFORM()
          HttpSession->PWSF121RESULT := { oObj:oWSGETREGFORMRESULT }
      Else
         Return PWSHtmlAlert( "", STR0003 , "", "W_PWSF120.APW" )
      EndIf

      //���������������������������Ŀ
      //�Verifica Resultado da Busca�
      //�����������������������������
      If !Empty( HttpSession->PWSF121RESULT ) .AND. Len( HttpSession->PWSF121RESULT ) > 0

         aWebCols := { }

         If ExistBlock( "PEF121" )
            aWebCols := ExecBlock( "PEF121", .F., .F., {} )
         EndIf        

         GridLinesEx( { HttpSession->PWSF121INFO ,;
                        HttpSession->PWSF121HEADER[1], ;
                        HttpSession->PWSF121RESULT, ;
                        aWebCols, .F., "H", NIL, 0 } )

         cHtml += ExecInPage( "PWSF120" )

      Else
	      Return PWSHtmlAlert( "", STR0003 , STR0004 , "W_PWSF120.APW" ) //"A busca n�o retornou nenhum resultado."
      EndIf

   Else //If nPos > 0
      HttpSession->PWSF020APH[3] := STR0005 //"ERRO PWSF040#001 : Fornecedor Inv�lido"
   EndIf
EndIf

WEB EXTENDED END

Return cHtml
