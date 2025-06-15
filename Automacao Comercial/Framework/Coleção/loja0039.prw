#INCLUDE "MSOBJECT.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "LOJA0039.CH"

User Function LOJA0039 ; Return  // "dummy" function - Internal Use 

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJAEmail           �Autor  �Vendas Cliente      � Data �  24/03/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata responsavel em enviar email						   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJAEmail
	
	Data cError	                  						//Utilizada para guardar o erro de conexao e envio
	Data cServer										//Servidor por onde o email vai ser enviado (smtp.ig.com.br, 200.181.100.51, localhost)
	Data cEmail						   					//Email do remetente (Fulano@ig.com.br, protheus@teste.com.br)
	Data cPass											//Senha do remetente (123)
	Data lAuth											//Se possui autenticacao
	Data cContAuth										//Conta Autenticacao
	Data cPswAuth										//Senha Autenticacao
	
	Method New()										//Metodo construtor
	Method Enviar(cDe	, cPara, cCc, cAssunto, ;
             	  cAnexo, cMsg)   						//Metodo responsavel em enviar email	
        
	//Metodos internos
	Method EnviaEmail(cDe	, cPara, cCc, cAssunto, ;
             	 	  cAnexo, cMsg)   					//Metodo responsavel em enviar email	
	Method Conectar()									//Conecta no servidor
	Method Desconecta()									//Desconecta do servidor
	Method BuscarErro()									//Busca o erro de conexao ou envio
	Method Autenticar()									//Autentica o usuario
	
EndClass

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes     � Data �  24/03/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAEmail         		                 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�																 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto			    										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method New() Class LJAEmail

	::cError     := ""
	::cServer    := Trim(SuperGetMV('MV_RELSERV',, ""))
	::cEmail     := Trim(SuperGetMV('MV_RELACNT',, ""))
	::cPass      := Trim(SuperGetMV('MV_RELPSW' ,, ""))
	::lAuth      := SuperGetMV('MV_RELAUTH',, .F.)
	::cContAuth  := Trim(SuperGetMV('MV_RELACNT',, ""))
	::cPswAuth   := Trim(SuperGetMV('MV_RELAPSW',, ""))
    
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Enviar    �Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em enviar email								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDe)  	 - Nome do remetente.					  ���
���			 �ExpC2 (2 - cPara)  - Email do destinatario.				  ���
���			 �ExpC3 (3 - cCc)  	 - Com copia.							  ���
���			 �ExpC4 (4 - cAssunto)  - Assunto.		    				  ���
���			 �ExpC5 (5 - cAnexo)  - Caminho do anexo.					  ���
���			 �ExpC6 (6 - cMsg)  - Mensagem do email.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico			    									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Enviar(cDe	, cPara, cCc, cAssunto, ;
              cAnexo, cMsg) Class LJAEmail
	
	Local lRetorno   := .T.											//Retorno do metodo
		
	//Verifica se foi informado o nome remetente
	cDe      := IIf(cDe == NIL, Trim(SuperGetMV('MV_RELFROM',, '')), AllTrim(cDe))
	cDe      := IIf(Empty(cDe), "Totvs" , cDe)
	
	//Tira os espacos 
	cPara    := AllTrim(cPara)
	cCc      := AllTrim(cCC)
	cAssunto := AllTrim(cAssunto)
	cAnexo   := AllTrim(cAnexo)
		
	//Verifica se os parametros foram cadastrados
	If Empty(::cServer) .OR. Empty(::cEmail) .OR. Empty(::cPass)
	      lRetorno := .F.
	      //"N�o foram definidos os par�metros no server do Protheus para envio de e-mail (MV_RELSERV / MV_RELACNT / MV_RELPSW)"
	      Conout(STR0001)
	EndIf
	
	//Verifica se foi informado o destinatario
	If lRetorno
		If Empty(cPara)
		      lRet := .F.
		      //"N�o foram definidos detinatario para envio de e-mail"
		      Conout(STR0002)
		      Return lRet
		EndIf
	EndIf
		
	//Conecta no servidor
	If lRetorno
		lRetorno := ::Conectar()
	EndIf
	
	//Conecta no servidor
	If lRetorno
		lRetorno := ::Autenticar()
	EndIf
	
	//Envia o email
	If lRetorno
		lRetorno := ::EnviaEmail(cDe, cPara, cCc, cAssunto, cAnexo, cMsg)
	EndIf

	//Desconecta do servidor
	::Desconecta()
		
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Conectar  �Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em conectar no servidor						  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico			    									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Conectar() Class LJAEmail
	
	Local lRetorno := .F.							//Retorno do metodo
	
	//Conecta no servidor    
	CONNECT SMTP SERVER ::cServer ACCOUNT ::cEmail PASSWORD ::cPass RESULT lRetorno
	
	//Verifica se conectou
	If !lRetorno
		//Busca o erro
	    ::BuscarErro()
	    //"Falha na conex�o para envio de e-mail"
		Conout(STR0003 + " ( " + ::cError + " )")
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscarErro�Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em buscar o erro da conexao e envio			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscarErro() Class LJAEmail
	
	//Busca o erro
	GET MAIL ERROR ::cError
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Autenticar�Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em autenticar o usuario						  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico			    									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Autenticar() Class LJAEmail
	
	Local lRetorno := .T.							//Retorno do metodo
	Local nPosicao := 0								//Guarda a posicao do @ na string do email
	
	//Efetua a autenticacao se necessario
	If ::lAuth
	      // Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
	      If !(lRetorno := MailAuth(::cContAuth, ::cPswAuth))
	            // Se nao conseguiu fazer a Autenticacao usando o E-mail completo,
	            // tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
	            nPosicao := At('@', ::cContAuth)

                ::cContAuth := IIF(nPosicao > 0, SubStr(::cContAuth, 1, nPosicao - 1), ::cContAuth)

                If !(lRetorno := MailAuth(::cContAuth, ::cPswAuth))
                	//"N�o conseguiu autenticar conta de e-mail"
                	Conout(STR0004 + " ( " + cContAuth + " )")
				EndIf
	      EndIf
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Desconecta�Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em desconectar do servidor        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desconecta() Class LJAEmail
	
	//Desconecta do servidor
	DISCONNECT SMTP SERVER
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EnviaEmail�Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em enviar email								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDe)  	 - Nome do remetente.					  ���
���			 �ExpC2 (2 - cPara)  - Email do destinatario.				  ���
���			 �ExpC3 (3 - cCc)  	 - Com copia.							  ���
���			 �ExpC4 (4 - cAssunto)  - Assunto.		    				  ���
���			 �ExpC5 (5 - cAnexo)  - Caminho do anexo.					  ���
���			 �ExpC6 (6 - cMsg)  - Mensagem do email.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico			    									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EnviaEmail(cDe	, cPara, cCc, cAssunto, ;
                  cAnexo, cMsg) Class LJAEmail
	
	Local lRetorno   := .F.											//Retorno do metodo

	//Verifica como sera enviado o email 
	If Empty(cCc) .AND.  Empty(cAnexo)
	      SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lRetorno
	ElseIf  Empty(cCc) .AND. !Empty(cAnexo)
	      SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lRetorno
	ElseIf !Empty(cCc) .AND.  Empty(cAnexo)
	      SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lRetorno
	Else
	      SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lRetorno
	EndIf
	
	//Verifica se o email foi enviado
	If !lRetorno
	      //Busca o erro
	      ::BuscarErro()
	      //"Falha no envio do e-mail
	      Conout(STR0005 + " ( " + ::cError + " )")
	Else
	      //"Enviado e-mail para: ["
	      Conout(STR0006 + cPara + "]")
	      //"Assunto: ["
	      Conout(STR0007 + cAssunto + "]")
	EndIf
			
Return Nil