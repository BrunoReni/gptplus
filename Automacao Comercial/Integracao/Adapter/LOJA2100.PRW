#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2100 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJAIntegracao     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata responsavel em manter os dados a serem integrados	  ���
���			 �pelos adapters. Nao pode ser instanciada						 	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJAIntegracao
	
	Data oDadosInt										//Objeto do tipo LJCDadosIntegracao
	Data cProcesso										//Codigo do processo que esta sendo integrado
		
	Method New()					                   	//Metodo construtor
	Method Inserir(cTabela, cChave, cIndice, cTipo)  	//Metodo que ira adicionar um objeto na Colecao
	Method Gerar()		    							//Metodo que ira processar os dados da integracao
	Method Finalizar()									//Finaliza a integracao enviando o XML para o EAI
	Method Integrar()									//Verifica se precisa integrar algum dado do processo
	
	//Metodos internos
	Method ProcHabili()									//Verifica se o processo esta habilitado
	Method TabsHabili()									//Verifica se as tabelas do processo estao habilitadas	
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAIntegracao.		                  ���
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
Method New() Class LJAIntegracao
    
    //Instancia o objeto LJCDadosIntegracao
    Self:oDadosInt := LJCDadosIntegracao():New()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Inserir   �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar os dados da integracao.            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
���			 �ExpC2 (2 - cChave)  - Dados da chave.						  ���
���			 �ExpN1 (3 - cIndice) - Codigo do indice.			          ���
���			 �ExpC3 (4 - CTipo)   - Tipo de integracao do dado.	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Inserir(cTabela, cChave, cIndice, cTipo) Class LJAIntegracao

	Local oDadoInt := Nil					//Objeto do tipo LJCDadoIntegracao
	
	cTabela := AllTrim(Upper(cTabela))
	
	//Instancia o objeto LJCDadoIntegracao
	oDadoInt := LJCDadoIntegracao():New(cTabela, cChave, cIndice, cTipo)
	
	//Adiciona o dado da integracao na colecao
	Self:oDadosInt:Add(oDadoInt)
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar a integracao. Metodo abstrato,     ���
���			 �tem que ser subscrito pelas classes filhos.	          	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar() Class LJAIntegracao

	Local lRetorno 	:= .T.					//Retorno do metodo
    
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Finalizar �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Finaliza a integracao enviando o XML para o EAI.			  ���
���			 � Metodo abstrato tem que ser subscrito pelas classes filhos.���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Finalizar() Class LJAIntegracao

	Local lRetorno 	:= .T.					//Retorno do metodo
    
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ProcHabili�Autor  �Vendas Clientes     � Data �  26/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se o processo esta habilitado      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ProcHabili() Class LJAIntegracao

	Local lRetorno 	:= .F.				//Retorno do metodo
    Local oProcesso := Nil              //Objeto do tipo LJCEntProcessos
	Local oRetorno	:= Nil              //Objeto do tipo LJCRegistrosEntidades com o retorno da consulta
    
    //Instancia o objeto LJCEntProcInt
	oProcesso := LJCEntProcInt():New()
	
	//Seta os dados do indice 1
	oProcesso:DadosSet("MDO_CODIGO", Self:cProcesso)
	
	//Consulta pelo indice 1
	oRetorno := oProcesso:Consultar(1)

	//Verifica se encontrou
	If oRetorno:Count() > 0 
		//Verifica se o tipo de operacao esta habilitado
		If Self:oDadosInt:Elements(1):cTipo == _INCLUSAO
			//Operacao de inclusao
			lRetorno :=	oRetorno:Elements(1):DadosGet("MDO_HABINC")		
		ElseIf Self:oDadosInt:Elements(1):cTipo == _ALTERACAO
			//Operacao de alteracao
			lRetorno :=	oRetorno:Elements(1):DadosGet("MDO_HABALT")		
		ElseIf Self:oDadosInt:Elements(1):cTipo == _EXCLUSAO
			//Operacao de exclusao
			lRetorno :=	oRetorno:Elements(1):DadosGet("MDO_HABEXC")				
		EndIf
	EndIf
	
Return lRetorno

/*       
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TabsHabili�Autor  �Vendas Clientes     � Data �  26/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se as tabelas do processo          ���
���			 �estao habilitadas										      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TabsHabili() Class LJAIntegracao

	Local lRetorno 		:= .F.				//Retorno do metodo
    Local oTabsProc 	:= Nil              //Objeto do tipo LJCEntTabelasProcesso
	Local oRetorno		:= Nil              //Objeto do tipo LJCRegistrosEntidades com o retorno da consulta
    Local cTabela		:= ""				//Tabela do processo
    Local nCount		:= 0				//Variavel de controle contador para os registros da tabela MD2
    Local nTabProc		:= 0				//Variavel de controle contador das tabelas do processo    
    Local oDadosHab		:= Nil				//Dados da integra��o que ser�o integrados.
        
    //Instancia o objeto LJCEntTabProcInt
	oTabsProc := LJCEntTabProcInt():New()
	
	//Seta os dados do indice 1
	oTabsProc:DadosSet("MDP_PROCES", Self:cProcesso)
	
	//Consulta pelo indice 1
	oRetorno := oTabsProc:Consultar(1)
    
	//Instancia o objeto LJCDadosIntegracao
    oDadosHab := LJCDadosIntegracao():New()    

	//Verifica se os dados da integracao estao configurados
	For nTabProc := 1 To Self:oDadosInt:Count()
		
		//Tabela do processo da integracao
		cTabela := Self:oDadosInt:Elements(nTabProc):cTabela
        
		For nCount := 1 To oRetorno:Count()        
			If oRetorno:Elements(nCount):DadosGet("MDP_TABELA") == cTabela
				If oRetorno:Elements(nCount):DadosGet("MDP_HABILI")
					//Adiciona o dado habilitado para integracao
					oDadosHab:Add(Self:oDadosInt:Elements(nTabProc))
				EndIf
				
				Exit
			EndIf
       	Next
		
	Next
	
	//Adiciona somente o que estiver habilitado para integracao
	Self:oDadosInt := oDadosHab 
		
	//Verifica se existe algo para integrar
	lRetorno := Self:oDadosInt:Count() > 0
	
Return lRetorno

/*       
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TabsHabili�Autor  �Vendas Clientes     � Data �  26/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se precisa integrar algum 	      ���
���			 �dado do processo										      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Integrar() Class LJAIntegracao
	
	Local lRetorno 	:= .F.				//Retorno do metodo
	
	//Verifica se o processo esta habilitado
	lRetorno := Self:ProcHabili()
	
	If lRetorno
		//Verifica se alguma tabela do processo esta habilitada
		lRetorno := Self:TabsHabili()
	EndIf
	
Return lRetorno