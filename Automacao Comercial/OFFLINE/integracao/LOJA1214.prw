#INCLUDE "LJINTEGRA.CH"
 
Static oLog := LJCLogIntegracao():New()

Function LOJA1214 ; Return  // "dummy" function - Internal Use 

/* 
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������         
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCInsereExportacao�Autor  �Vendas Clientes     � Data �  23/04/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em inserir os dados da exportacao tabela MD6 e MD7���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/ 
Class LJCInsereExportacao

	Data oTransacao										//Objeto do tipo LJCTransacao
	Data nWebService                                    //Numero do web service
	Data cAmbiente										//Codigo do ambiente
	Data cProcesso										//Codigo do processo
	Data oEstrutMD6										//Objeto do tipo LJCEntSaida
	Data oEstrutMD7                                 	//Objeto do tipo LJCEntSaidaAmb
	Data lUsaTradut										//Verifica se utiliza traducao
	Data cTransacao										//Codigo da transacao
	Data lMatrizOff										//Identifica se o ambiente off-line eh matriz
	Data oGlobal										//Objeto do tipo LJCGlobal
	
	Method New(oTransacao, cProcesso)					//Metodo construtor
	Method Executar()								  	//Executa exportacao de cada tabela
	Method InserirTabela(oTabela)						//Prepara cada registro a ser inserido 
	Method BuscaSeqServico()                         	//Retorna nWebService
	Method InserirRegistro(nWebservico	, cTipoProcedimento	, cCampo		, cValor	, ;
						   cTipoCampo	,  cModulo			, Procedimento	, Sequencia ) 			//Insere na base de dados as informacoes da exportacao
	Method ReplAmb()									//Replica a transacao para os outros ambientes                             	
	Method InsereMD7(cAmbiente)							//Insere os dados da replicacao    
	Method FormatVal(cValor)                           	//Formata valor
	Method TamMd6(cTransacao)                           //Busca Tamanho dos Reg. na MD6

EndClass             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCInsereExportacao.	                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oTransacao) - Dados da transacao.  			  ���
���			 �ExpC1 (1 - cProcesso) - Codigo do processo.	  			  ���
���			 �ExpL1 (1 - lUsaTradut) - Identifica se utiliza traducao.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New(oTransacao, cProcesso, lUsaTradut) Class LJCInsereExportacao
	
	Default lUsaTradut := .F.
	
	::oEstrutMD6 	:= LJCEntSaida():New()
	::oEstrutMD7   	:= LJCEntSaidaAmb():New()
	::lUsaTradut	:= lUsaTradut
	::cAmbiente 	:= AllTrim(SuperGetMV("MV_LJAMBIE", Nil, ""))
	::lMatrizOff 	:= SuperGetMV("MV_LJMATOF", Nil, ".F.")
	::cProcesso		:= cProcesso
	::oTransacao 	:= oTransacao
	::nWebService 	:= 1 
	::cTransacao	:= StrZero(::oTransacao:GetNumTransacao(), ::oEstrutMD6:Campos():ElementKey("MD6_TRANS"):nTamanho)
	
	::oGlobal 		:= LJCGlobal():Global()
	
	::Executar()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Executar  �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa exportacao de cada tabela.    	                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method Executar() Class LJCInsereExportacao

	Local nConta 	:= 1									//Variavel auxiliar contador                     
	Local aDados 	:= ::oTransacao:GetTabelas()			//Dados das tabelas
	Local bOldError := Nil						       		//Bloco de erro

	    
	bOldError := ErrorBlock( {|x| IntVerifErro(x) } ) // muda code-block de erro

	Begin Transaction

	Begin Sequence
	    
		::oGlobal:GravarArq():Log():Integracao():Gravar(" ")
		::oGlobal:GravarArq():Log():Integracao():Gravar("Inicio - Exportando dados para tabela de saida MD6")
		::oGlobal:GravarArq():Log():Integracao():Gravar("Transacao: " + ::cTransacao + " - Ambiente: " + ::cAmbiente + " - Processo: " + ::cProcesso)
	
		For nConta = 1 To Len(aDados)
			
			::InserirTabela(aDados[nConta], nConta)		
			
		Next nConta
		
		::oGlobal:GravarArq():Log():Integracao():Gravar("Fim - Exportando dados para tabela de saida MD6")
		
		//Replica os dados para os ambientes
		If Len(aDados) > 0
			::ReplAmb()
		EndIf
    
        
	Recover          
		DisarmTransaction()  
		
		::oGlobal:GravarArq():Log():Integracao():Gravar("Erro na gravacao - " + tcsqlerror())
    	
	End Sequence 

	ErrorBlock( bOldError ) // Restaura rotina de erro anterior
		
	End Transaction 

	Leave1Code(Self:cTransacao)
    
Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �InserirTabela   �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Prepara cada registro a ser inserido							    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oTabela) - Dados da tabela.  			  	            ���
���			 �ExpN1 (1 - nProcedimento) - Numero do procedimento.	  			���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method InserirTabela(oTabela, nProcedimento) Class LJCInsereExportacao
	
	Local nConta      := 1										//Variavel auxiliar contador  
	Local nSequencia  := 1 										//Sequencia da transacao
	Local cTipoProced := ""										//Tipo de procedimento
    Local cLogCampos  := ""										//Auxiliar na gravacao do log	
	Local oCampo      := Nil									//Dados do campo
	Local cCampo      := ""										//Nome do campo
	Local cSeqTem     := ""
	Local aAreaMD6	  := MD6->(GetArea())
	
	//Insere o registo que identifica a tabela
    cSeqTem := StrZero(nSequencia, ::oEstrutMD6:Campos():ElementKey("MD6_SEQ"):nTamanho)
    
    	::InserirRegistro(::BuscaSeqServico(), oTabela:cTipoProc, "TABELA", oTabela:cTabela, ;
        	              3, "PROTHEUS", nProcedimento, nSequencia )
	
	::oGlobal:GravarArq():Log():Integracao():Gravar("	Tabela: " + oTabela:cTabela + " - " + oTabela:cTipoProc)
	
	
	For nConta := 1 To Len(oTabela:GetTabela()) 

		nSequencia++

		cSeqTem := StrZero(nSequencia, ::oEstrutMD6:Campos():ElementKey("MD6_SEQ"):nTamanho)

		oCampo := oTabela:GetTabela()[nConta]  
		cTipoProced := oTabela:cTipoProc

		If oCampo:lChave
			
			//If ::lUsaTradut			
				cCampo := "PK" + oCampo:cCampo
			//Else
			//	cCampo := oCampo:cCampo			
			//EndIf 
			
			If cTipoProced = "UPDATE"
				cTipoProced = "WHERE"
			Endif

		Else
			cCampo := oCampo:cCampo
			
			If cTipoProced = "UPDATE"
				cTipoProced = "SET"
			Endif

		Endif                                
				
		cLogCampos += AllTrim(oCampo:cCampo) + " = " + AllTrim(::FormatVal(oCampo:cValor)) + "; "
    
			::InserirRegistro(::BuscaSeqServico(), cTipoProced,  cCampo, oCampo:cValor, ;
								oCampo:nTipo, "PROTHEUS", nProcedimento, nSequencia )     

	Next nConta
	
	::oGlobal:GravarArq():Log():Integracao():Gravar("		" + Substr(cLogCampos, 1, Len(cLogCampos) - 2))

Return Nil 

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �InserirRegistro �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Prepara cada registro a ser inserido							    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nWebservico) - Numero WS.  			  	            ���
���			 �ExpC1 (2 - cTipoProcedimento) - Numero do procedimento  			���
���			 �ExpC2 (3 - cCampo) - Nome do campo.			    	  			���
���			 �ExpC3 (4 - cValor) - valor do campo.              	  			���
���			 �ExpC4 (5 - cTipoCampo) - Tipo do campo.				  			���
���			 �ExpC5 (6 - cModulo) - Modulo.					    	  			���
���			 �ExpN2 (7 - Procedimento) - Numero do procedimento.	  			���
���			 �ExpN1 (8 - Sequencia) - Sequencia da transacao.		  			���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method InserirRegistro(nWebservico	, cTipoProcedimento	, cCampo		, cValor	, ;
                       cTipoCampo	, cModulo			, Procedimento	, Sequencia	) Class LJCInsereExportacao

	cValor := ::FormatVal(cValor)
		
	::oEstrutMD6:Limpar()
	
	::oEstrutMD6:DadosSet("MD6_NOME", cCampo)
	::oEstrutMD6:DadosSet("MD6_VALOR", cValor)
	::oEstrutMD6:DadosSet("MD6_TRANS", ::cTransacao)
	::oEstrutMD6:DadosSet("MD6_REG", StrZero(Procedimento, ::oEstrutMD6:Campos():ElementKey("MD6_REG"):nTamanho))
	::oEstrutMD6:DadosSet("MD6_SEQ", StrZero(Sequencia, ::oEstrutMD6:Campos():ElementKey("MD6_SEQ"):nTamanho))
	::oEstrutMD6:DadosSet("MD6_TIPO", cTipoProcedimento)
	::oEstrutMD6:DadosSet("MD6_ORIGEM", ::cAmbiente)
	::oEstrutMD6:DadosSet("MD6_SERVWB", Alltrim(str(nWebServico)))
	::oEstrutMD6:DadosSet("MD6_MODULO", cModulo)	
	::oEstrutMD6:DadosSet("MD6_TPCPO", Alltrim(str(cTipoCampo)))
	::oEstrutMD6:DadosSet("MD6_STATUS", "1")
	::oEstrutMD6:DadosSet("MD6_SITPRO", "1")
	::oEstrutMD6:DadosSet("MD6_PROCES", ::cProcesso)   
	::oEstrutMD6:DadosSet("MD6_DATA", DToC(dDataBase))	                   
	::oEstrutMD6:Incluir()
		
Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �BuscaSeqServico �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Retorna nWebService											    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �Numerico 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method BuscaSeqServico() Class LJCInsereExportacao
Return (::nWebService++)   

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �ReplAmb         �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Replica a transacao para os ambientes.						    ���
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
Method ReplAmb() Class LJCInsereExportacao
		
	Local oAmbXProc		:= Nil						//Objeto do tipo LJCEntAmbProcessos
	Local oRtAmbProc	:= Nil						//Retorno da consulta do ambientes x processos
	Local nCount		:= 0						//Variavel de controle contador
	
	::oGlobal:GravarArq():Log():Integracao():Gravar(" ")
	::oGlobal:GravarArq():Log():Integracao():Gravar("Inicio - Replicando processo para tabela MD7")
	
	//Insere um registro para o ambiente atual somente se nao for matriz, este dado sera replicado
	//para o pai
	If !::lMatrizOff
		::InsereMD7(::cAmbiente)
	EndIf
	
	//Estancia o objeto LJCEntAmbientesProcessos
	oAmbXProc 	:= LJCEntAmbProcessos():New()
	
	//Consulta os ambientes para onde os dados serao replicados
	oAmbXProc:DadosSet("MD5_AMBORI", ::cAmbiente)
	oAmbXProc:DadosSet("MD5_PROCES", ::cProcesso)
	oRtAmbProc := oAmbXProc:Consultar(1)
	
	If oRtAmbProc:Count() > 0
		For nCount := 1 To oRtAmbProc:Count()
			//Insere os dados para replicacao dos ambientes
			::InsereMD7(oRtAmbProc:Elements(nCount):DadosGet("MD5_AMBDES"))	
		Next
	EndIf
	
	::oGlobal:GravarArq():Log():Integracao():Gravar("Fim - Replicando processo para tabela MD7")
	
Return Nil    

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �InsereMD7       �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Insere os dados da replicacao na tabela MD7.  				    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cAmbiente) - Codigo do ambiente.	  	                ���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method InsereMD7(cAmbiente) Class LJCInsereExportacao
	
	//Limpa os dados da entidade
	::oEstrutMD7:Limpar()
	
	//Atribui os dados aos campos da entidade
	::oEstrutMD7:DadosSet("MD7_TRANS", ::cTransacao)
	::oEstrutMD7:DadosSet("MD7_DEST", cAmbiente)
	::oEstrutMD7:DadosSet("MD7_STATUS", "1")
	
	If MD7->(FieldPos("MD7_TAMMD6")) > 0 
		::oEstrutMD7:DadosSet("MD7_TAMMD6", ::TamMD6(::cTransacao))
	EndIf	
	
	//Insere o registro	
	::oEstrutMD7:Incluir()
	
	::oGlobal:GravarArq():Log():Integracao():Gravar("	Ambiente Origem: " + ::cAmbiente + " - Ambiente Destino: " + cAmbiente + " - Transacao: " + ::cTransacao + " - Processo: " + ::cProcesso)
	
Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �FormatVal       �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Formata o valor do campo.						  				    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cValor) - valor a ser formatado.	  	                ���
�������������������������������������������������������������������������������͹��
���Retorno   �Caracter		 									   		        ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method FormatVal(cValor) class LJCInsereExportacao
	
	Local cRetorno := ""    

	If ValType(cValor) = "D"
		cRetorno := DTOS(cValor)
	ElseIf ValType(cValor) = "L"
		cRetorno = IIF(cValor == .T., "T", "F")
	ElseIf ValType(cValor) != "C"                                
		cRetorno = Str(cValor)
	Else
		cRetorno = cValor
	EndIf

Return cRetorno

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �TamMD6          �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Busca tamanho em bytes do registro MD6 relacionado na MD7         ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cValor) - valor a ser formatado.	  	                ���
�������������������������������������������������������������������������������͹��
���Retorno   �Caracter		 									   		        ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method TamMD6(cTransacao) class LJCInsereExportacao
	
	Local nTamMD6 := 0    
	Local aArea := GetArea()

	dbSelectArea("MD6")
	MD6->(dbSetOrder(1))
	If MD6->(msSeek(xFilial("MD6")+cTransacao))
		While MD6->(!EOF() .AND. cTransacao == MD6->MD6_TRANS )
			nTamMD6 +=  MD6->(RECSIZE())
			MD6->(dbSkip())
		End
	EndIf
	RestArea(aArea)

Return Alltrim(Str(nTamMD6))
