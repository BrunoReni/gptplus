#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "LOJA0038.CH"

User Function LOJA0038 ; Return  // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCXML	       �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em possuir metodos e propriedades comuns para   ���
���			 �geracao e leitura do arquivo xml.									 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCXML
	
	Data cArquivo											//Caminho e nome onde o arquivo sera gravado
	Data cPath												//Path do arquivo
	Data cNomeArq											//Nome do arquivo
	Data oXml												//Objeto com a estrutura do Xml
	Data cMsg							  					//Mensagem de nao conformidade no processo
	Data cError												//Mensagem de erro
	Data cWarning											//Mensagem de aviso
		
	Method LJCXML(cPath, cNome)								//Metodo construtor
	Method New()											//Metodo construtor
	Method Criar(cEstrutura, cDelimit, cPath)				//Gera o objeto com a estrutura do XML
	Method Salvar(cPath)									//Salva o arquivo XML em disco
	Method ClonarNode(oNode, cNomeNode)						//Clona um node na estrutura do xml
	Method TransNodAr(oNode, cNomeNode)                 	//Transforma um node em array
	Method GetMsg()											//Retorna a mensagem de nao conformidade
	Method NodeExiste(oNode, cNomeNode)						//Verifica se o node existe
	Method CriarNode(oNode, cNomeNode, cRealNome, cTipo)	//Cria um novo node
	Method Destrutor()										//Limpa os objetos criados
	
	//Metodos internos
	Method XmlCriado(cPath)									//Verifica se o XML foi criado, salvo em disco
	
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �LJCXML	       �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCXML.					    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cPath)		- Path do arquivo.              		     ���
���			 �EXPC2 (2 - cNome) 	- Nome do arquivo.     					     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method LJCXML(cPath, cNome) Class LJCXML

	::cPath		:= cPath
	::cNomeArq	:= cNome
	
	//Verifica se o path esta vindo com barra no final
	If Substr(::cPath, Len(::cPath), 1) == "\"
		::cArquivo	:= ::cPath + ::cNomeArq	
	Else
		::cArquivo	:= ::cPath + "\" + ::cNomeArq
	EndIf
	
	::oXml		:= Nil
	::cMsg		:= ""
	::cError	:= ""
	::cWarning	:= ""
		
Return Self

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCXML.					    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cPath)	- Caminho do arquivo.  	            		     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New() Class LJCXML

	::oXml		:= Nil
	::cMsg		:= ""
	::cError	:= ""
	::cWarning	:= ""
	
Return Self

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Criar            �Autor  �Vendas Clientes     � Data �  06/05/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em gerar o objeto com a estrutura do XML ou Ler ���
���			 �um arquivo XML ja existente.                                 		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cEstrutura) - Estrutura do XML.            		     ���
���			 �EXPC2 (2 - cDelimit) - Delimitador.		            		     ���
���			 �EXPC3 (3 - cPath) - Caminho do arquivo.		            		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Criar(cEstrutura, cDelimit, cPath) Class LJCXML

	Local lRetorno  := .F.							//Retorno do metodo
	Local cError	:= ""							//Variavel de erro 
	Local cWarning  := ""							//Variavel de alerta
	
	DEFAULT cDelimit 	:= "_"
	DEFAULT cEstrutura 	:= NIL
	DEFAULT cPath 		:= NIL
	
	If cEstrutura <> NIL        
		//Deve-se efetuar encode para tratar os caracteres especiais antes do XmlParser,
		// pois cError nem cWarning est�o retornando valor fazendo com o objeto oXml fique nil e n�o seja cadastrado o cliente
        cEstrutura := EncodeUTF8(cEstrutura)
        	
		//Gera o Objeto XML com a estrutura definida
		::oXml := XmlParser(cEstrutura, cDelimit, @cError, @cWarning)
		
		//Solucao dada pelo FrameWork
	    If Empty(::oXml) .AND. "UTF-8" $ UPPER(cError)

   			//Converte o XML para UTF-8
   			cEstrutura := EncodeUTF8(cEstrutura)

   			//Gera o Objeto XML com a estrutura definida
			::oXml := XmlParser(cEstrutura, cDelimit, @cError, @cWarning)

	    EndIf
	Else
		//Carrega o XML a partir do arquivo
		::oXml := XmlParserFile(cPath, cDelimit, @cError, @cWarning)
	EndIf
    
    //Verifica se a estrutura foi criada
	lRetorno := (Empty(cError) .AND. Empty(cWarning))
								
	If !lRetorno
		::cMsg 		:= AllTrim(cError + IIF(!Empty(cError) .AND. !Empty(cWarning), " - ", "") + cWarning)
		::cError	:= cError
		::cWarning	:= cWarning
		Self:Destrutor()
	EndIf
	 
Return ::oXml

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Salvar           �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em salvar o arquivo XML em disco.           	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cPath) - Caminho do arquivo.	            		     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Salvar(cPath) Class LJCXML

	Local lRetorno  := .T.							//Retorno do metodo
	
	DEFAULT cPath := NIL
	
	//Salva o arquivo no disco
	If cPath <> NIl
		SAVE ::oXml XMLFILE cPath
		
		//Verifica se o arquivo foi salvo
		lRetorno := ::XmlCriado(cPath)	
	Else
		SAVE ::oXml XMLFILE ::cArquivo
		
		//Verifica se o arquivo foi salvo
		lRetorno := ::XmlCriado()	
	EndIf
	
Return lRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �XmlCriado        �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em salvar o arquivo XML em disco.           	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cPath) - Caminho do arquivo.	            		     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Logico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method XmlCriado(cPath) Class LJCXML

	Local lRetorno  := .T.							//Retorno do metodo
	Local oArquivo  := Nil							//Objeto do tipo LJArquivo
	
	DEFAULT cPath := NIL
	
	//Instancia o objeto do tipo LJCArquivo
	If cPatch = NIL
		oArquivo := LJCArquivo():Arquivo(::cPath, ::cNomeArq)
	Else
		oArquivo := LJCArquivo():New(cPath)	
	EndIf
	
	//Verifica se o arquivo existe
	lRetorno := oArquivo:Existe()
	
	If !lRetorno
		::cMsg := STR0001	
	EndIf

Return lRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ClonarNode       �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em clonar um node.					           	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oNode) 	- Objeto node a ser clonado.    		     ���
���			 �EXPC1 (2 - cNomeNode) - Nome do node.     					     ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ClonarNode(oNode, cNomeNode) Class LJCXML
	
	XmlCloneNode(oNode, cNomeNode)
	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �TransNodAr       �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em transformar um node em array.	           	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oNode) 	- Objeto node a ser clonado.    		     ���
���			 �EXPC1 (2 - cNomeNode) - Nome do node.     					     ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method TransNodAr(oNode, cNomeNode) Class LJCXML
	
	XmlNode2Arr(oNode, cNomeNode)
	
Return Nil	

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GetMsg           �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar a mensagem de nao conformidade.   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String    													     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GetMsg() Class LJCXML
Return ::cMsg

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �NodeExiste       �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em verificar se node existe.   	           	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oNode) 	- Objeto node pai.			    		     ���
���			 �EXPC1 (2 - cNomeNode) - Nome do node filho a ser procurado.	     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method NodeExiste(oNode, cNomeNode) Class LJCXML
	
	Local oRetorno  := NIL							//Retorno do metodo
		
	oRetorno := XmlChildEx(oNode, cNomeNode)
	
Return oRetorno	

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �CriarNode        �Autor  �Vendas Clientes     � Data �  26/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em criar um novo node.			   	           	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oNode) - Objeto node pai.				    		     ���
���			 �EXPC1 (2 - cNomeNode) - Nome do node filho a ser criado.		     ���
���			 �EXPC2 (3 - cRealNome) - Nome real do node.				         ���
���			 �EXPC3 (4 - cTipo) - Tipo (NOD - node / ATT - atributo.             ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method CriarNode(oNode, cNomeNode, cRealNome, cTipo) Class LJCXML
	
	XmlNewNode(oNode, cNomeNode, cRealNome, cTipo)
	
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Destrutor �Autor  �Vendas Clientes     � Data �  26/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Limpa os objetos que foram criados	         			  ���
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
Method Destrutor() Class LJCXML
	
	If Self:oXml <> Nil	
		FreeObj(Self:oXml)	
		Self:oXml := Nil
	EndIf

Return Nil
