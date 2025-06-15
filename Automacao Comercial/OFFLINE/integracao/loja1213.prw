#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1213 ; Return  // "dummy" function - Internal Use 

/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCTransacao      �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em executar as transacoes                        ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/ 
Class LJCTransacao

	Data aTabelas									//Array com as tabelas a serem exportadas      
	Data aTabTraduz									//Array com as tabelas a serem traduzidas 
	Data nTransacao									//Numero da transacao
	
	Method New(nTransacao)							//Metodo construtor
	Method Incluir(Tabela)							//Incluir a tabela no array aTabelas
	Method Executar()                               //Executa o processamento da transacao
	Method GetTabelas()								//Retorna aTabelas
	Method GetNumTransacao()						//Retorna nTransacao
	Method Traduzir()                               //Traduz a transacao
	Method Finalizar()                              //Finaliza a transacao
	Method Erro()                                   //Trata o erro caso ocorra

EndClass                  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTransacao.		                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nTransacao) - Numero da transacao.  			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New(nTransacao) Class LJCTransacao

	::aTabelas := {}
	
	::nTransacao := nTransacao
	
Return Self

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �Incluir      �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Incluir a tabela no array aTabelas.							 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oTabela) - Tabela a ser inserida. 	  	  			 ���
����������������������������������������������������������������������������͹��
���Retorno   �		   									   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/	  
Method Incluir(oTabela) class LJCTransacao

	Aadd(::aTabelas, oTabela)

Return Nil

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �Executar     �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Executa o processamento da transacao.							 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�										     	  	  			 ���
����������������������������������������������������������������������������͹��
���Retorno   �Logico   									   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/	  
Method Executar() class LJCTransacao
	
	Local nConta := 0							//Varialvel auxiliar contador
	Local lOk := .T.							//Identifica se o processo finalizou com sucesso
		
	For nConta = 1 to len(::aTabelas)
		if !::aTabelas[nConta]:Executar()
			lOk := .F. 
			Exit
		EndIf			
	Next nConta

	If lOk
		::Finalizar()
	EndIf
		

	If !lOk 
		::Erro()  
	EndIf

Return lOk
                 
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �GetTabelas   �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Retorna aTabelas.												 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�										     	  	  			 ���
����������������������������������������������������������������������������͹��
���Retorno   �Array   									   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/	 
Method GetTabelas() class LJCTransacao
Return ::aTabelas

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �Traduzir     �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Traduz a transacao.											 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�											 	  	  			 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto   									   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/	 
Method Traduzir() class LJCTransacao

	Local nConta     := 0                           //Variavel auxiliar contador
	Local oTFinal    := Nil							//Objeto do tipo LJCTransacao
	Local oTraduzir  := Nil							//Objeto do tipo LJCTraduzir
	
	oTFinal := LJCTransacao():new(::nTransacao)
	
	For nConta = 1 to Len(::aTabelas)
	
		oTraduzir := ::aTabelas[nConta]:Traduzir()
	                 
		oTFinal:Incluir(oTraduzir)
		
	Next nConta
	
Return oTFinal

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �GetNumTransacao �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Retorna nTransacao.											    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�										     	  	  			    ���
�������������������������������������������������������������������������������͹��
���Retorno   �Numerico 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method GetNumTransacao() Class LJCTransacao
Return ::nTransacao

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Finalizar       �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Finaliza a transacao.											    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�										     	  	  			    ���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method Finalizar() Class LJCTransacao

	Local cQuery	:= ""						//Monta a query
 
    #IFDEF TOP

		cQuery := "DELETE " + RetSqlName("MD8")
		cQuery += " WHERE MD8_TRANS = '" + ::nTransacao + "'"

		TcSqlExec(cQuery)

	#ELSE

		DbSelectArea("MD8")

		cMD8Reg := Space(TamSx3("MD8_REG")[1])
		cMD8Seq := Space(TamSx3("MD8_SEQ")[1])

		MD8->( DbSetOrder(1) )	//MD8_FILIAL+MD8_TRANS+MD8_REG+MD8_SEQ
		MD8->( DbSeek(xFilial("MD8") + ::nTransacao + cMD8Reg + cMD8Seq, .T.) )
		
		BEGIN TRANSACTION
					    
			While !MD8->( EoF() ) .AND. ::nTransacao == MD8->MD8_TRANS
			    RecLock("MD8",.F.)
					MD8->( DBDelete() )
			    MD8->( MsUnLock() )
				MD8->( DbSkip() )
			End
	
			If MD8->( EoF() )
				Sleep(5000)
			EndIf

		
		END TRANSACTION
	#ENDIF
		
Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Finalizar       �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Trata o erro													    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�										     	  	  			    ���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method Erro() Class LJCTransacao

	Local cQuery	:= ""												//Monta query 
	Local oLog		:= Nil												//Objeto do tipo LJCLogIntegracao 
	Local EntMDC 	:= Nil												//Objeto do tipo LJCEntNaoConfIntegra
	Local cErro		:= ""												//Erro gerado 
	Local oEmail	:= Nil												//Objeto do tipo LJCEmailIntegracao
	Local cAmbiente	:= AllTrim(SuperGetMV("MV_LJAMBIE", Nil, ""))		//Parametro que define o codigo do ambiente
	
	cErro := tcsqlerror()
	
	oLog := LJCLogIntegracao():New()
	
	oLog:Gravar( Repl("-", 40) )
	
	oLog:Gravar( "Erro na transacao =" + ::nTransacao)
	
	oLog:Gravar(cErro)
	                    
	#IFDEF TOP

		cQuery := "UPDATE " + RetSqlName("MD8") + " SET MD8_STATUS = 3, MD8_SITPRO = 3"
		cQuery += " WHERE MD8_TRANS = '" + ::nTransacao + "'"
		
		TcSqlExec(cQuery)
	
	#ELSE
		DbSelectArea("MD8") 

		cMD8Reg 	:=	Space(TamSx3("MD8_REG")[1])
		cMD8Seq 	:=	Space(TamSx3("MD8_SEQ")[1])

		DbSetOrder(1)    	//MD8_TRANS+MD8_REG+MD8_SEQ
		DbSeek(xFilial("MD8") + ::nTransacao + cMD8Reg + cMD8Seq, .T.)
		
		BEGIN TRANSACTION
					    
		While !MD8->(EOF()) .AND. ::nTransacao = MD8->MD8_TRANS
		    RecLock("MD8",.F.)		
			Replace MD8_STATUS With "3"
			Replace MD8_SITPRO With "3"   
		    MsUnLock()
			DbSkip()
		End       	
		
		END TRANSACTION
	#ENDIF
	
	//Inclui os dados na tabela de nao conformidade
	EntMDC := LJCEntNaoConfIntegra():New()
	
	EntMDC:DadosSet("MDC_TRANS", ::nTransacao)
	EntMDC:DadosSet("MDC_DESC", Substr(cErro, 1, 254))
	EntMDC:DadosSet("MDC_TPTAB", "IE")
	
	EntMDC:Incluir()
	
		
	//Envia o email
	oEmail := LJCEmailIntegracao():New()
	
	oEmail:Env0iar("Integracao", "N�o conformidade no processo de importa��o da integra��o", ;
	"N�o Conformidade na Transa��o (" + ::nTransacao + "), do ambiente(" + cAmbiente + ") - " + cErro)    
  	
Return Nil
