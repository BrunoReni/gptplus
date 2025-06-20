#INCLUDE "MSOBJECT.CH"

User Function LOJA0026 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCCodeBase		�Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em executar os comandos para CodeBase            ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCCodeBase From LJADataBase
    
	Data aAreaAtual								//Array que ira guardar os dados do alias atual
	Data aAreaEntid								//Array que ira guardar os dados do alias da entidade

	Method New(oEntidade)						//Metodo construtor
	Method Consultar()							//Metodo que ira consultar os dados da tabela atraves de um indice
	Method Alterar()							//Metodo que ira alterar os dados da tabela atraves de um indice
	Method Incluir()							//Metodo que ira incluir um registro na tabela
	Method Excluir()							//Metodo que ira excluir os dados da tabela atraves de um indice
	
	//Metodos internos
	Method GetArea()							//Metodo que ira guardar os dados da area atual e da entidade
	Method ResArea()							//Metodo que ira restaurar os dados da area atual e da entidade
	Method PosArquivo()							//Metodo que ira posicionar o arquivo no indice especificado
	Method MontaSeek()							//Metodo que ira montar o seek de procura do indice especificado
	Method FormataVal(cTipo, oValor, nTamanho)	//Metodo que ira formatar um valor, Subscrito da classe LJADataBase
	Method PertenIndc()							//Metodo que ira verificar se o registro posicionado eh referente ao indice informado
	Method AbreArqu()							//Metodo que ira abrir o arquivo
	Method Erro(oErro)							//Metodo que ira tratar o erro
			
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAEntidade.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oEntidade) - Entidade.			                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oEntidade) Class LJCCodeBase
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::oEntidade := oEntidade
	
	::aAreaAtual := {}
	::aAreaEntid := {}
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Consultar �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em consultar os dados da tabela atraves do 	  ���
���			 �indice especificado.									 	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Consultar() Class LJCCodeBase

	Local cCampo 	:= ""							//Nome do campo
	Local nCount	:= 0							//Varivel de controle contador
	Local oRecodSet := Nil							//Objeto do tipo LJCRegistrosEntidade, retorno do metodo
	Local oCloneEnt := Nil							//Objeto do tipo LJAEntidade
	Local nRegistro := 1							//Variavel do tipo contador
	
	//Estancia o objeto LJCRegistrosEntidade
	oRecodSet := LJCRegistrosEntidade():New()	

	//Guarda a posicao do arquivo atual e da entidade
	::GetArea()
	
	//Posiciona o arquivo		
	If ::PosArquivo()
		//Verifica se e final de arquivo
		While !EOF() .AND. ::PertenIndc()
			
			//Faz um clone da entidade
			oCloneEnt := ::oEntidade:Clonar()
			
			//Carrega a entidade com os dados consultados
			For nCount := 1 To oCloneEnt:Campos():Count()
				cCampo := oCloneEnt:Campos():Elements(nCount):cNome
				oCloneEnt:DadosSet(cCampo, &((::oEntidade:cTabela)->(cCampo)))
			Next
			
			//Adiciona o registro na colecao	
			oRecodSet:ADD("R" + AllTrim(Str(nRegistro)), oCloneEnt)    
			nRegistro++    
		    
			//Vai para o proximo registro
			(::oEntidade:cTabela)->(DbSkip())
		
		End
	EndIf
	
	//Restaura a posicao do arquivo atual e da entidade
	::ResArea()
								
Return oRecodSet
			
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Alterar   �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em alterar os dados da tabela atraves do indice ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Alterar() Class LJCCodeBase

	Local lRetorno  := .F.							//Retorno do metodo
	Local oCampo 	:= Nil							//Dados do campo
	Local nCount	:= 0							//Varivel de controle contador
	Local oIndice	:= Nil							//Indice da entidade    

	//Guarda a posicao do arquivo atual e da entidade
	::GetArea()
	
	//Posiciona o arquivo		
	If ::PosArquivo()
		
		//Pega os dados do indice
		oIndice :=	::oEntidade:Indices():ElementKey(::oEntidade:nIndice) 
		
		//Verifica se e final de arquivo
		While !EOF() .AND. ::PertenIndc()
			
			//Prepara o registro para alteracao
			If RecLock(::oEntidade:cTabela, .F.)
			
				For nCount := 1 To ::oEntidade:Campos():Count()
					//Pega os dados do campo na entidade
					oCampo := ::oEntidade:Campos():Elements(nCount)
					
					//Atualiza somente os campos que nao fazem parte do indice
					If !oIndice:Campos():Contains(oCampo:cNome)
						//Verifica se o campo nao esta nulo
						If !oCampo:oValor == Nil
							//Atribui o valor ao campo
							REPLACE &(oCampo:cNome) WITH oCampo:oValor
						EndIf
					EndIf
				Next
				
				//Libera o registro
				MsUnLock()
							
				//Vai para o proximo registro
				(::oEntidade:cTabela)->(DbSkip())
			
				lRetorno := .T.
			Else
				//Nao conseguiu dar lock no registro
				lRetorno := .F.
				Exit
			EndIf
		End
	EndIf
	
	//Restaura a posicao do arquivo atual e da entidade
	::ResArea()			

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Incluir   �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em incluir um registro na tabela				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Incluir() Class LJCCodeBase

	Local lRetorno 	:= .T.							//Retorno do metodo
	Local oCampo 	:= Nil							//Dados do campo
	Local nCount	:= 0							//Varivel de controle contador
	Local oIndice	:= Nil							//Indice da entidade    
	Local bOldError := Nil   						//Bloco de erro anterior
	Local cCampFil  := ""							//Nome do campo filial
    Private oObj 	:= Self							//Objeto LJCCodeBase, esta propria classe
	
	//Guarda a posicao do arquivo atual e da entidade
	::GetArea()
	
	//Abre o arquivo		
	::AbreArqu()
		
	Begin Sequence		
		//Muda o bloco de erro
		bOldError := ErrorBlock( {|x| oObj:erro()} )
		
		//Prepara o registro para inclusao
		RecLock(::oEntidade:cTabela, .T.)
		
		//Trata o nome do campo filial, se a entidade comecar com "S" significa que o campo comeca
		//com as duas ultima letras da entidade, senao, considerar as 3 letras da entidade
		If Substr(::oEntidade:cTabela, 1, 1) == "S"
			cCampFil := Substr(::oEntidade:cTabela, 2, 2) + "_FILIAL"
		Else
			cCampFil := Substr(::oEntidade:cTabela, 1, 3) + "_FILIAL"
		EndIf
		
		//Atribui valor ao campo FILIAL
		REPLACE &(cCampFil) WITH xFilial(::oEntidade:cTabela)
		
		//Carrega os campos com os dados da entidade
		For nCount := 1 To ::oEntidade:Campos():Count()
			//Pega os dados do campo na entidade
			oCampo := ::oEntidade:Campos():Elements(nCount)
			
			//Verifica se o campo nao esta nulo 
			If !oCampo:oValor == Nil
				//Atribui o valor ao campo
				If ValType (&(oCampo:cNome)) == "C" .and. ValType(oCampo:oValor) == "C"
					REPLACE &(oCampo:cNome) WITH oCampo:oValor				
                
                ElseIf ValType (&(oCampo:cNome)) == "C" .and. ValType(oCampo:oValor) == "D" 
                	REPLACE &(oCampo:cNome) WITH dToC(oCampo:oValor)
				
				ElseIf ValType (&(oCampo:cNome)) == "D" .and. ValType(oCampo:oValor) == "C" 
                	REPLACE &(oCampo:cNome) WITH cTod(oCampo:oValor)	            
	            
	            EndIf               
			EndIf
		Next
		
		//Libera o registro
		MsUnLock()
	Recover
		//Erro na inclusao
		lRetorno := .F.
	End Sequence 
	
	//Retorno o bloco de erro original
	ErrorBlock(bOldError)        
	
	//Restaura a posicao do arquivo atual e da entidade
	::ResArea()	
			
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Excluir   �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em excluir os dados da tabela atraves do indice ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Excluir() Class LJCCodeBase

	Local lRetorno  := .F.							//Retorno do metodo
	
	//Guarda a posicao do arquivo atual e da entidade
	::GetArea()
	
	//Posiciona o arquivo		
	If ::PosArquivo()

		//Verifica se e final de arquivo
		While !EOF() .AND. ::PertenIndc()
		
			//Prepara o registro para exclusao
			RecLock(::oEntidade:cTabela, .F.)
			
			//Exclui o registro	
			dbDelete()		
					
			//Libera o registro
			MsUnLock()
			
			//Vai para o proximo registro
			(::oEntidade:cTabela)->(DbSkip())
		End
	EndIf
	
	//Restaura a posicao do arquivo atual e da entidade
	::ResArea()	
			
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetArea   �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em guardar os dados da area atual e da entidade ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �		   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetArea() Class LJCCodeBase
	
	//Guarda a posicao do arquivo atual
	::aAreaAtual := GetArea()
	//Guarda a posicao do arquivo da entidade
	::aAreaEntid := (::oEntidade:cTabela)->(GetArea())

Return Nil							

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ResArea   �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em restaurar os dados da area atual e da entidad���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �		   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ResArea() Class LJCCodeBase
							
	//Restaura a posicao do arquivo da entidade
	RestArea(::aAreaEntid)
	//Restaura a posicao do arquivo atual
	RestArea(::aAreaAtual)
							
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PosArquivo�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em posicionar o arquivo no indice especificado  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico   									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PosArquivo() Class LJCCodeBase
	
	Local lRetorno := .F.				//Retorno do metodo
	Local cSeek		:= ""				//Chave de busca do indice 1
	
	//Monta chave de busca do indice 1
	cSeek := ::MontaSeek()
	
	//Seleciona o arquivo
	::AbreArqu()
	//Seta o indice
	DbSetOrder(::oEntidade:nIndice)
	//Posiciona o arquivo
	If DbSeek(cSeek)
		lRetorno := .T.
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �MontaSeek �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em montar o seek de procura do indice 		  ���
���			 �especificado										 		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter   									   			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MontaSeek() Class LJCCodeBase

	Local cRetorno 	:= ""				//Retorno do metodo
	Local oIndice 	:= Nil				//Objeto do tipo LJCDadosIndice
	Local nCount	:= 0				//Varivel de controle contador
	Local oCampo	:= Nil				//Campos da entidade, objeto do tipo LJCDadosCampo
	Local cCampo	:= ""				//Nome do campo do indice
	Local cCampFil	:= ""				//Guarda o nome do campo filial
		
	//Verifica se existe o indice na entidade
	If ::oEntidade:Indices():Contains(::oEntidade:nIndice)
		
		//Pega os dados do indice
		oIndice :=	::oEntidade:Indices():ElementKey(::oEntidade:nIndice) 
		
		//Verifica quantos campos tem no indice e pega os valores para montar o seek
		For nCount := 1 To oIndice:Campos():Count()
			
			//Pega o campo do indice
			cCampo := oIndice:Campos():Elements(nCount) 
			
			//Pega os dados do campo na entidade
			oCampo := ::oEntidade:Campos():ElementKey(cCampo)
			
			//Guarda o nome do campo filial, se a entidade comecar com "S" significa que o campo comeca
			//com as duas ultima letras da entidade, senao, considerar as 3 letras da entidade
			If Substr(::oEntidade:cTabela, 1, 1) == "S"
				cCampFil := Substr(::oEntidade:cTabela, 2, 2) + "_FILIAL"
			Else
				cCampFil := Substr(::oEntidade:cTabela, 1, 3) + "_FILIAL"
			EndIf
			
			//Verifica se o campo e filial e se foi atribuido valor a ele
			If cCampo == cCampFil
				If oCampo:oValor == Nil
					oCampo:oValor := xFilial(::oEntidade:cTabela)				
				EndIf			
			EndIf
			
			//Formata o valor e monta o seek
			If oCampo:oValor != Nil
				oCampo:oValor := ::FormataVal(oCampo:cTipo, oCampo:oValor, oCampo:nTamanho)
				cRetorno +=	oCampo:oValor			
			EndIf
		
		Next
		
	EndIf

Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �FormataVal�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em formatar um valor.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) 	- Tipo do campo.		              ���
���			 �ExpO1 (2 - oValor) 	- Valor a ser formatado.              ���
���			 �ExpN1 (3 - nTamanho) 	- Tamanho do campo.		              ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FormataVal(cTipo, oValor, nTamanho) Class LJCCodeBase
	
	Local oRetorno := Nil					//Retorno do metodo
    
	If oValor != Nil
		Do Case
			//Tipo caracter
			Case cTipo == "C"
				oRetorno := PadR(oValor, nTamanho , " ")
				
			//Tipo data
			Case cTipo == "D"
				oRetorno := DTOS(oValor)
			
			//Outros tipos			
			OtherWise
				oRetorno := oValor
		EndCase    
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PertenIndc�Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se o registro posicionado eh       ���
���			 �referente ao indice informado								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�												              ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PertenIndc() Class LJCCodeBase

	Local lRetorno := .T.				//Retorno do metodo
   	Local oIndice 	:= Nil				//Objeto do tipo LJCDadosIndice
	Local nCount	:= 0				//Varivel de controle contador
	Local oCampo	:= Nil				//Campos da entidade, objeto do tipo LJCDadosCampo
	Local cCampo	:= ""				//Nome do campo do indice
		
	//Pega os dados do indice
	oIndice :=	::oEntidade:Indices():ElementKey(::oEntidade:nIndice) 
	
	//Verifica quantos campos tem no indice e compara os valores
	For nCount := 1 To oIndice:Campos():Count()
		
		//Pega o campo do indice
		cCampo := oIndice:Campos():Elements(nCount) 
		
		//Pega os dados do campo na entidade
		oCampo := ::oEntidade:Campos():ElementKey(cCampo)
		
		//O campo nulo nao faz parte do seek			
		If oCampo:oValor != Nil
			//Compara se o valor e igual ao do registro posicionado
			If oCampo:oValor != &((::oEntidade:cTabela)->(cCampo))
				lRetorno := .F.
				Exit
			EndIf
		EndIf
	Next
   	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AbreArqu  �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir o arquivo					          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�												              ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbreArqu() Class LJCCodeBase
	
	//Seleciona o arquivo
	DbSelectArea(::oEntidade:cTabela)
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Erro      �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o erro   					          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oErro) - Objeto com os dados do erro.            ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Erro(oErro) Class LJCCodeBase
Return Nil
