#INCLUDE "MSOBJECT.CH" 
#INCLUDE "AUTODEF.CH"

#DEFINE FINALTEXTO Chr(13) + Chr(10)

User Function LOJA0003 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCArquivo       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCArquivo
	
	Data cNomeArq									//Nome do arquivo
	Data cPath										//Caminho do arquivo
	Data nHandle									//Handle do arquivo
	Data cArquivo									//cPath + cNomeArq
	Data oDados										//Objeto do tipo Dados com as linhas de texto do arquivo
	Data cBarra										//barra "/" para Linux "\" para windows
	
	Method Arquivo(cPath, cNomeArq)					//Metodo construtor
	Method New(cArquivo)                            //Metodo construtor
	Method Abrir(nModo) 							//Metodo que ira abrir o arquivo
	Method Fechar()                                	//Metodo que ira fechar o arquivo
	Method Escrever(cTexto)							//Metodo que ira escrever no final arquivo
	Method Ler()                                   	//Metodo que ira ler o arquivo
	Method Criar()									//Metodo que ira criar o arquivo
	Method Existe()									//Metodo que ira verificar se o arquivo existe
	Method Apagar()									//Metodo que ira apagar um arquivo    
	Method Dados()									//Metodo que ira retornar uma colecao com o conteudo do arquivo    
	Method EscrevXML(cTexto)    					//Metodo que ira escrever no inicio do arquivo (PROVISORIO)
	Method Renomear(cNomeArq)						//Metodo que ira renomear o arquivo             
	Method Copiar(cNomeArq)							//Metodo que ira cop�ar o arquivo

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Arquivo   �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCArquivo. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cPath)    - Caminho do arquivo.    			  ���
���          �EXPC2 (2 - cNomeArq) - Nome do arquivo.    			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Arquivo(cPath, cNomeArq) Class LJCArquivo
	
	Default cNomeArq 	:= ""
	Default cPath 		:= ""
	
	::cNomeArq 	:= cNomeArq
	::cPath		:= cPath
	::nHandle  	:= 0
	
	//Verifica se o path esta vindo com barra no final
	If GetRemoteType() <> REMOTE_LINUX
		
		::cBarra := "\"
		
		If Substr(::cPath, Len(::cPath), 1) == ::cBarra
			::cArquivo	:= ::cPath + ::cNomeArq	
		Else
			::cArquivo	:= ::cPath + ::cBarra + ::cNomeArq
		EndIf
	Else

		::cBarra := "/"
		
		If Substr(::cPath, Len(::cPath), 1) == ::cBarra
			::cArquivo	:= ::cPath + ::cNomeArq	
		Else
			::cArquivo	:= ::cPath + ::cBarra + ::cNomeArq
		EndIf
	EndIf
	
	::oDados	:= LJCDados():Dados()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCArquivo. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cArquivo) - Caminho do arquivo e Nome do Arquivo.���
���          �                                          			      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cArquivo) Class LJCArquivo

 	::cArquivo:= cArquivo            
	
	::nHandle  	:= 0
		
	::oDados	:= LJCDados():Dados()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Abrir     �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir um arquivo. 				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - nModo) - Modo de abertura do arquivo.   	      ���
���			 �					  0 - abri para ler			 			  ���
���			 �					  1 - abri para escrever				  ���
���			 �					  2 - abri para ler e escrever(default)	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Abrir(nModo) Class LJCArquivo
	
	Local lRetorno := .T.					//Variavel de retorno do metodo
	
	Default nModo := 2
	
	//Abre o arquivo
	::nHandle := FOPEN(::cArquivo, nModo)
	
	If ::nHandle == -1
		lRetorno := .F.	
	EndIf 
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Fechar    �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em fechar um arquivo. 				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Fechar() Class LJCArquivo
	
	Local lRetorno := .F.					//Variavel de retorno do metodo
	
	//Fecha o arquivo
	lRetorno := FCLOSE(::nHandle)
	
	::nHandle := 0
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Escrever       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em escrever no final do arquivo.	              	   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTexto) - Texto do arquivo.            	           ���
������������������������������������������������������������������������������͹��
���Retorno   �Logico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Escrever(cTexto) Class LJCArquivo
	
	Local lRetorno 	:= .T.						//Variavel de retorno do metodo
	Local nTamanho 	:= 0						//Tamanho do texto a ser escrito
	Local nRetorno 	:= 0						//Variavel de retorno do metodo FWRITE
	Local nSize		:= 0						//Tamanho de bytes do arquivo
	
	cTexto += FINALTEXTO
	
	//Posiciona no final do arquivo
	nSize := FSEEK(::nHandle, 0, 2)
	
	//Escreve no Arquivo
	nRetorno := FWRITE(::nHandle, cTexto)
	
	//Verifica se o comando foi executado
	nTamanho := Len(cTexto)
	
	If nRetorno != nTamanho
		lRetorno := .F.
	EndIf
	
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �EscrevXML      �Autor  �Vendas Clientes     � Data �  15/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em escrever o comentario no inicio do arquivo XML.   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTexto) - Texto do arquivo.            	           ���
������������������������������������������������������������������������������͹��
���Retorno   �Logico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method EscrevXML(cTexto) Class LJCArquivo
	
	Local lRetorno 	:= .T.						//Variavel de retorno do metodo
	Local nTamanho 	:= 0						//Tamanho do texto a ser escrito
	Local nRetorno 	:= 0						//Variavel de retorno do metodo FWRITE
	Local nSize		:= 0						//Tamanho de bytes no arquivo
	Local cRetorno	:= ""                       //Retorno do conteudo do arquivo
	
	cTexto += FINALTEXTO
			
	//Posiciona no inicio do arquivo para pegar o total de bytes escrito no arquivo
	nSize := FSEEK(::nHandle, 0, 2)
	
	//Posiciona no inicio do arquivo
	FSEEK(::nHandle, 0, 0)	
	
	//Le o Arquivo
	FREAD(::nHandle, cRetorno, nSize)
	
	//Posiciona no inicio do arquivo
	FSEEK(::nHandle, 0, 0)
	
	//Escreve no arquivo
	nRetorno := FWRITE(::nHandle, cTexto + cRetorno)
		
	//Verifica se o comando foi executado
	nTamanho := Len(cTexto + cRetorno)
	
	If nRetorno != nTamanho
		lRetorno := .F.
	EndIf
	
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Criar          �Autor  �Vendas Clientes     � Data �  15/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o arquivo.	              	               ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Logico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Criar() Class LJCArquivo
	
	Local lRetorno 	:= .T.						//Variavel de retorno do metodo
		
	//Cria o arquivo
	::nHandle := FCREATE(::cArquivo)	
	
	If ::nHandle == -1
		lRetorno := .F.	
	EndIf 
			
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Existe         �Autor  �Vendas Clientes     � Data �  15/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se o arquivo existe.            	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Logico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Existe() Class LJCArquivo
	
	Local lRetorno 	:= .F.						//Variavel de retorno do metodo
	
	//Verifica se o arquivo existe
	lRetorno := File(::cArquivo)
			
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Apagar         �Autor  �Vendas Clientes     � Data �  15/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em apagar um arquivo.			            	       ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Logico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Apagar() Class LJCArquivo
	
	Local lRetorno 	:= .T.						//Variavel de retorno do metodo
	Local nRetorno	:= 0						//Retorno da funcao FERASE
	
	//Apaga o arquivo
	nRetorno := FERASE(::cArquivo)
	
	If nRetorno == -1
		lRetorno := .F.	
	EndIf 
			
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Ler            �Autor  �Vendas Clientes     � Data �  15/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em ler o conteudo do arquivo.			               ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Ler() Class LJCArquivo
	
	Local cLinha		:= ""				//Retorno da leitura do arquivo
	Local nCount		:= 0 				//Variavel de controle do tipo contador
	Local oDadoLinha	:= Nil				//Objeto do tipo DadoLinha
	
	//Estancia o objeto Dados (esta inicializando)
	::oDados := LJCDados():Dados()		
	
	//Coloca o arquivo em uso
	FT_FUSE(::cArquivo)
	//Posiciona na primeira linha
	FT_FGOTOP()
 
	//Varre o arquivo
	While !FT_FEOF()
	   
	   nCount++
	   
	   //Estancia o objeto DadoLinha
	   oDadoLinha := LJCDadoLinha():DadoLinha()
	   //Pega a linha
	   cLinha := FT_FREADLN()
	   //Atribui a linha de texto ao objeto
	   oDadoLinha:cLinha := cLinha
	   //Adiciona o objeto DadoLinha na colecao
	   ::oDados:Add("L" + AllTrim(Str(nCount)), oDadoLinha)  
	   //Pula a linha
	   FT_FSKIP()
	End 
    
 	//Libera o arquivo
	FT_FUSE()
			
Return ::oDados

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Dados          �Autor  �Vendas Clientes     � Data �  17/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retorna uma colecao com os dados do arquivo.      ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Dados() Class LJCArquivo
Return ::oDados

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Renomear       �Autor  �Vendas Clientes     � Data �  14/11/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em renomear um arquivo.			            	   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cNomeArq) - Nome para qual ser� renomeado   		   ���
������������������������������������������������������������������������������͹��
���Retorno   �Numerico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Renomear(cNomeArq) Class LJCArquivo

	Local nRetorno := 0 				//Retorno do metodo
	
	//Renomeia o arquivo
	nRetorno := FRENAME(::cArquivo , cNomeArq) 

Return nRetorno  

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Copiar       �Autor  �Vendas Clientes     � Data �  14/11/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em copiar um arquivo.			            	   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        	   ���
������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cNomeArq) - Nome para qual ser� renomeado   		   ���
������������������������������������������������������������������������������͹��
���Retorno   �Numerico												           ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Copiar(cNomeArq) Class LJCArquivo

	Local lRetorno := .F.
	//Renomeia o arquivo
	lRetorno := __CopyFile(::cArquivo , cNomeArq) 

Return lRetorno
