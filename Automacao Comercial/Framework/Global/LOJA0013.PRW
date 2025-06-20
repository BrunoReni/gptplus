#INCLUDE "MSOBJECT.CH" 

User Function LOJA0013 ; Return  // "dummy" function - Internal Use

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Classe    �LJAAbstrataArquivos �Autor  �Vendas Clientes     � Data �  16/10/07   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata que possui as propriedades e metodos comuns dos  	    ���
���		     �arquivos.                                                  		    ���
�����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		    ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Class LJAAbstrataArquivos
	
	Data cNomeArq									//Nome do arquivo
	Data cPath										//Caminho do arquivo
	Data oArquivo									//Objeto do tipo LJCArquivo
	
	Method AbstArq()								//Metodo construtor
	Method Arquivo()								//Metodo que ira retornar o objeto do tipo LJCArquivo
	Method Gravar(cTexto)							//Metodo que ira gravar o arquivo
	Method Ler()                                   	//Metodo que ira ler o arquivo
	Method Apagar()									//Metodo que ira apagar o arquivo
	Method LerArqs()								//Metodo que ira ler todos os arquivos do diretorio
	
	//Metodos internos
	Method AbrirArq()								//Metodo que ira abrir ou criar um arquivo
	Method CriarDir()								//Metodo que ira criar um diretorio 

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AbstArq   �Autor  �Vendas Clientes     � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAAbstrataArquivos.		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbstArq() Class LJAAbstrataArquivos
	
	::cNomeArq 	:= ""
	::cPath		:= ""
	::oArquivo	:= Nil
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Arquivo   �Autor  �Vendas Clientes     � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em estanciar e retornar o objeto Arquivo.       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Arquivo() Class LJAAbstrataArquivos
	
	//Estancia o objeto Arquivo se necessario.
	If ::oArquivo == Nil
		::oArquivo := LJCArquivo():Arquivo(::cPath, ::cNomeArq)
	EndIf 
	
Return ::oArquivo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gravar    �Autor  �Vendas Clientes     � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o texto no arquivo. 				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTexto) - Texto a ser gravado.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gravar(cTexto) Class LJAAbstrataArquivos
	
	Local lRetorno := .F.						//Variavel de retorno do metodo

	//Abri ou cria um arquivo
	lRetorno := ::AbrirArq()
	
	If lRetorno
		//Escreve no arquivo
		lRetorno := ::Arquivo():Escrever(cTexto)			
	EndIf
	
	If lRetorno
		//Fecha o arquivo
		lRetorno := ::Arquivo():Fechar()			
	EndIf
	
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Ler            �Autor  �Vendas Clientes     � Data �  16/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em ler os dados do arquivo.	              	       ���
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
Method Ler() Class LJAAbstrataArquivos
	
	Local oRetorno 	:= Nil						//Variavel de retorno do metodo
	Local lRetorno 	:= .F.						//Variavel de controle para retorno de alguns metodos
	
	//Abri o arquivo
	lRetorno := ::AbrirArq()
	
	If lRetorno
		//Le os dados do arquivo
		oRetorno := ::Arquivo():Ler()
	EndIf
	
	If lRetorno
		//Fecha o arquivo
		lRetorno := ::Arquivo():Fechar()			
	EndIf
	
Return oRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Apagar         �Autor  �Vendas Clientes     � Data �  16/10/07   ���
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
Method Apagar() Class LJAAbstrataArquivos
	
	Local lRetorno 	:= .T.						//Variavel de retorno do metodo
	
	//Apaga o arquivo
	lRetorno := ::Arquivo():Apagar()
			
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �AbrirArq       �Autor  �Vendas Clientes     � Data �  16/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir ou criar um arquivo.              	       ���
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
Method AbrirArq() Class LJAAbstrataArquivos
	
	Local lRetorno 	:= .F.						//Variavel de retorno do metodo

	//Cria o diretorio se necessario
	lRetorno := ::CriarDir()

	If lRetorno
		//Verifica se o arquivo ja existe	
		If ::Arquivo():Existe()
			//Abre o arquivo
			lRetorno := ::Arquivo():Abrir()
		Else
			//Cria o arquivo
			lRetorno := ::Arquivo():Criar()	
		EndIf
	EndIf
			
Return lRetorno

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �CriarDir       �Autor  �Vendas Clientes     � Data �  17/10/07   ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o diretorio.			              	       ���
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
Method CriarDir() Class LJAAbstrataArquivos
	
	Local lRetorno 		:= .F.						//Variavel de retorno do metodo
	Local oDiretorio 	:= Nil						//Objeto do tipo Diretorio
	Local oGlobal		:= Nil						//Objeto do tipo LJCGlobal    
	Local oDirs			:= Nil						//Colecao com diretorios retornados da funcao Split
	Local nCount		:= 0                   		//Variavel de controle contador
	Local cDirAux		:= ""						//Variavel para criar os diretorios  
	Local nDirs			:= 0
	
	//Instancia o objeto Diretorio, passando o path completo
	oDiretorio := LJCDiretorio():Diretorio(::cPath)
	
	//Verifica se o diretorio existe
	If oDiretorio:Existe()
		lRetorno := .T.	
	Else
		//Instancia o objeto LJCGlobal
		oGlobal := LJCGlobal():Global()
		
		//Quebra diretorio a diretorio
		oDirs := oGlobal:Funcoes():Split(::cPath, ::Arquivo():cBarra) 
		
		nDirs			:= oDirs:Count()
		//Verifica os diretorios
		For nCount := 1 To nDirs	
			
			lRetorno := .F.
			
			If At(":", oDirs:Elements(nCount)) > 0
				cDirAux += AllTrim(oDirs:Elements(nCount))			
			Else
				cDirAux += ::Arquivo():cBarra + AllTrim(oDirs:Elements(nCount))
			EndIf
			
			//Instancia o objeto Diretorio
			oDiretorio := LJCDiretorio():Diretorio(cDirAux)
	
			//Verifica se o diretorio ja existe
			If oDiretorio:Existe()
				lRetorno := .T.
			Else
				//Cria o diretorio
				lRetorno := oDiretorio:Criar()
			EndIf
			
			//Verifica se criou o diretorio
			If !lRetorno
				Exit
			EndIf
			
			If ValType(oDirs:Elements(nCount)) == "O"
				oDirs:Elements(nCount) := FreeObj(oDirs:Elements(nCount))
			EndIf
		Next

		oDirs := FreeObj(oDirs)		
		oGlobal := FreeObj(oGlobal)

	EndIf  
	
	oDiretorio:Destroy()
	oDiretorio := FreeObj(oDiretorio)
				
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �LerArqs   �Autor  �Vendas Clientes     � Data �  18/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em ler todos os arquivos do diretorio.  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTexto) - Texto a ser gravado.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LerArqs() Class LJAAbstrataArquivos
	
	Local oDiretorio 	:= Nil						//Objeto do tipo Diretorio
	Local nCount		:= 0						//Variavel de controle tipo contador
	
	//Estancia o objeto Diretorio 
	oDiretorio := LJCDiretorio():Diretorio(::cPath)
	
	//Verifica se o diretorio existe
	If oDiretorio:Existe() 
		//Le os arquivos do diretorio		
		oDiretorio:Ler()
		//Le o conteudo(linhas) de cada arquivo				
		For nCount := 1 To oDiretorio:Arquivos():Count()
			oDiretorio:Arquivos():Elements(nCount):Ler()
		Next
	EndIf
		
Return oDiretorio:Arquivos()
