#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1219 ; Return  // "dummy" function - Internal Use 

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������         
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCSeparaTransacao �Autor  �Vendas Clientes     � Data �  23/04/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em separar as transacoes da importacao            ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/  
Class LJCSeparaTransacao
     
	Data lTemTransacao									//Identifica se tem transacao
	Data aTransacoes                                  	//Array com as transacoes
	
	Method New()                                   		//Metodo construtor
	Method Separar()                               		//Separa o arquivo temporario em transacoes
	Method TemDados() 									//Retorna se dados foram encontrados para importacao
	Method IncluirTabela(oTabela, oTransacao)      		//Inclui a tabela na transacao e verifica se ja nao foi inserida
	Method AgrupaTabelas(oTabOrinal, oTabNova)        	//Agrupa tabelas iguais
	Method ExecutaAgrupaTabela(cTabela)     			//Verifica se a tabela deve agrupar para inclusao
	Method GetTransacoes()

EndClass          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCSeparaTransacao.	                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New() Class LJCSeparaTransacao

	::lTemTransacao := .F.
	
	::aTransacoes := {} 
	
	::Separar()
	
Return Self

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Separar         �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Separa o arquivo temporario em transacoes 					    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method Separar() Class LJCSeparaTransacao

	Local oTransacao							//Objeto do tipo LJCTransacao
	Local oTabela                              	//Objeto do tipo LJCSeparaTabela
	Local cTransacao	:= ""                  	//Numero da transacao
	Local cMD8Fil		:= ""
	Local lTemTabela	:= .F.
	Local lErro			:= .T.
	
    #IFDEF TOP

		dbSelectArea("TMP")
	
		TMP->( dbGoTop() )  
			
		cTransacao := TMP->MD8_TRANS
		
		oTransacao := LJCTransacao():new(cTransacao)
		
		While !TMP->(EOF()) .AND. cTransacao == TMP->MD8_TRANS
			
			::lTemTransacao := .T.
			
			oTabela := LJCSeparaTabela():new() 
			
			::IncluirTabela( oTabela:Separar(), @oTransacao)
			
		End     
	#ELSE                                        
		dbSelectArea("MD8")   

		nTamTrans	:= TamSX3("MD8_TRANS")[1]
		cTransacao	:= Replicate("0",nTamTrans)	
		
		MD8->(DbSetOrder(4)) //MD8_FILIAL + MD8_STATUS + MD8_TRANS + MD8_REG + MD8_SEQ
		cMD8Fil := xFilial("MD8")
		MD8->(DbSeek(cMD8Fil + "1"))
		
		cTransacao := MD8->MD8_TRANS
		            
		If !Empty(cTransacao)
			Conout("TRANSACAO:"+MD8->MD8_TRANS + " STATUS:"+MD8->MD8_STATUS+" NOME:"+MD8->MD8_NOME)
		EndIf
		
		oTransacao := LJCTransacao():new(cTransacao)
		                                                 
		While !MD8->(EOF()) .AND. cTransacao == MD8->MD8_TRANS .AND. MD8->MD8_STATUS == "1"
			
			//Caso o RefreshRate esteja com um tempo muito baixo e para evitar problemas na atualizacao
			//inserida validacao que verifica se est� mandando a sequencia necessaria para o processo
			If AllTrim(MD8->MD8_NOME) == "TABELA"
				lTemTabela := .T.
				Conout(" LOJA1219 - Campo Tabela encontrado ")
			EndIf
			
			If lTemTabela
				Conout(" LOJA1219 - Envia dados da transa��o ")
				::lTemTransacao := .T.
					
				oTabela := LJCSeparaTabela():new() 
					
				::IncluirTabela( oTabela:Separar(), @oTransacao)
				Conout(" LOJA1219 - Inclus�o de transacao efetuada")
			Else
				Exit
			EndIf
		EndDo
		
		//Tratamento de exce��o quando pacote incompleto e/ou com erro com isso permitir que o job n�o pare
		If !Empty(AllTrim(cTransacao)) .AND. !lTemTabela
			Conout(" LOJA1219 - Campo tabela n�o encontrado ")
			Conout(" LOJA1219 - Inicia tratamento de excecao ")
		
			MD8->(DbSetOrder(1)) //MD8_FILIAL+MD8_TRANS+MD8_REG+MD8_SEQ
			If MD8->(MsSeek(cMD8Fil + cTransacao))
				Conout(" LOJA1219 - Seta reprocessamento dos dados ")
				
				While !MD8->(Eof()) .AND. cTransacao == MD8->MD8_TRANS
					
					If AllTrim(MD8->MD8_NOME) == "TABELA"  
						lTemTabela	:= IIf(MD8->MD8_STATUS == "2",.T.,.F.)
					EndIf
					                         
					If lTemTabela .AND. MD8->MD8_STATUS == "2"
						RecLock("MD8",.F.)
						REPLACE MD8_STATUS WITH "1" //marca como "1" pra que na proxima vez o registro seja processado
						MD8->(MsUnlock())
						lErro := .F.
					Else
						Exit
					EndIf

					MD8->(DbSkip())
				EndDo
			EndIf

			//Caso nao haja o campo MD8->MD8_NOME == "TABELA" deve marcar com "3" que denota erro			
			If lErro                
				Conout(" LOJA1219 - TRANSACAO : " + cTransacao + " - STATUS : ERRO ")
				MD8->(DbSetOrder(1)) //MD8_FILIAL+MD8_TRANS+MD8_REG+MD8_SEQ				
				MD8->(MsSeek(cMD8Fil + cTransacao))
				While !MD8->(Eof()) .AND. cTransacao == MD8->MD8_TRANS
					RecLock("MD8",.F.)
					REPLACE MD8_STATUS WITH "3" //ERRO
					MD8->(MsUnlock())
					MD8->(DbSkip())	
				EndDo
			EndIf
		EndIf
		
	#ENDIF
	
	Aadd(::aTransacoes, oTransacao)

Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �GetTransacoes   �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Retorna as transacoes armazenadas 					            ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �Array		 									   		            ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method GetTransacoes() Class LJCSeparaTransacao
Return ::aTransacoes  

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �IncluirTabela   �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Inclui a tabela na transacao e verifica se ja nao foi inserida    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oTabela) - Dados da tabela.  			  	            ���
���			 �ExpO2 (2 - oTransacao) - Dados da transacao.      	  			���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method IncluirTabela(oTabela, oTransacao) class LJCSeparaTransacao

	Local nConta  := 0							//Variavel auxiliar contador                   
	Local bExiste := .F.						//Identifica se ja existe tabela inserida 
	
	For nConta = 1 To Len(oTransacao:GetTabelas())
		
		If oTransacao:GetTabelas()[nConta]:cTabela == oTabela:cTabela 
			If ::ExecutaAgrupaTabela(oTabela:cTabela)
				bExiste := .F.
			Else	
				bExiste := .T.
			EndIf      
			
			Exit
		Endif
	
	Next nConta
	
	If bExiste 
		::AgrupaTabelas(@oTransacao:aTabelas[nConta], oTabela)
	Else
		oTransacao:Incluir( oTabela )
	EndIf
	
Return Nil   

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Metodo    �ExecutaAgrupaTabela �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Verifica se a tabela deve agrupar para inclusao                       ���
�����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                                  ���
�����������������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela.  			  	                ���
�����������������������������������������������������������������������������������͹��
���Retorno   �Logico 									   		                    ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/	 
Method ExecutaAgrupaTabela(cTabela) class LJCSeparaTransacao
        
	Local bAgrupa := .T.						//Retorno do metodo 
	
	If  FindFunction("U_LJAGTAB") 

		//bOldError := ErrorBlock( {|x| IntVerifErro(x) } ) // muda code-block de erro		
		
		//Begin Sequence 
		
			bAgrupa := u_LJAGTAB( cTabela )
			
			If ValType(bAgrupa) <> "L"
				bAgrupa := .T. 				
			EndIf    
		
		//Recover                                          
		
		//	bAgrupa := .T.			
		
		//End Sequence
		
		//ErrorBlock( bOldError ) // Restaura rotina de erro anterior
	EndIf
	
Return bAgrupa

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �AgrupaTabelas   �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Agrupa tabelas iguais											    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oTabOrinal) - Dados da tabela original.  	            ���
���			 �ExpO2 (2 - oTabNova) - Dados da tabela nova.      	  			���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method AgrupaTabelas(oTabOrinal, oTabNova) Class LJCSeparaTransacao

	Local bNovo   := .T.
	Local nConta1 := 0
	Local nConta2 := 0
	
	For nConta1 = 1 To Len(oTabNova:getTabela())
	                    
		bNovo   := .T.
		
		For nConta2 = 1 To Len(oTabOrinal:getTabela())
			
			If  oTabNova:aTabela[nConta1]:cCampo = oTabOrinal:aTabela[nConta2]:cCampo 
				bNovo   := .F.
				Exit
			EndIf
		
		Next nConta2
		
		If bNovo = .T.
			oTabOrinal:IncluirObjeto(oTabNova:aTabela[nConta1])
		EndIf
	
	Next nConta1

Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �TemDados        �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Retorna se foi encontrado dados para importacao    		        ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �Logico 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method TemDados() Class LJCSeparaTransacao
Return ::lTemTransacao

