#INCLUDE "MSOBJECT.CH" 
#INCLUDE "AUTODEF.CH"

User Function LOJA0014 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDiretorio     �Autor  �Vendas Clientes     � Data �  17/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel manipular diretorios.                           ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDiretorio
			
	Data oArquivos									//Objeto do tipo Arquivos
	Data cPath				    					//Path do diretorio
	Data cBarra										//barra "/" para Linux "\" para windows
	
	Method Diretorio(cPath)							//Metodo construtor
	Method Apagar()									//Metodo que ira apagar o diretorio
	Method Criar()                                  //Metodo que ira criar o diretorio
	Method Existe()                                 //Metodo que ira verificar se o diretorio existe
	Method Arquivos()								//Metodo que ira retornar uma colecao de DadosArq
	Method Ler()                                  	//Metodo que ira ler os arquivos do diretorio
	Method Destroy()								//Metodo que destroi o componente
		
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Diretorio �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDiretorio.       		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cPath) - O Path do diretorio.				      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Diretorio(cPath) Class LJCDiretorio
	
	::oArquivos 	:= LJCArquivos():Arquivos()
	::cPath			:= cPath
	
	If GetRemoteType() <> REMOTE_LINUX
		::cBarra := "\"
	Else
		::cBarra := "/"	
	EndIf
			
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Apagar    �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em apagar o diretorio. 				  		  ���
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
Method Apagar() Class LJCDiretorio
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
	
	//Apaga o diretorio
	lRetorno := DirRemove(::cPath)
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Criar     �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o diretorio. 				  		  ���
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
Method Criar() Class LJCDiretorio
	
	Local lRetorno := .T.						//Variavel de retorno do metodo

	//Cria o diretorio
	lRetorno := (MAKEDIR(::cPath) == 0)
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Existe    �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar se o diretorio existe.	  		  ���
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
Method Existe() Class LJCDiretorio
	
	Local lRetorno 		:= .T.						//Variavel de retorno do metodo
	Local aDiretorios   := {}						//Array com os diretorios retornados
	
	//���������������������������������������Ŀ
	//�Tratamento para retirar a ultima barra.�
	//�����������������������������������������
	If SubStr(::cPath,Len(::cPath),1) == "\" .OR. SubStr(::cPath,Len(::cPath),1) == "/"
		::cPath := SubStr(::cPath,1,Len(::cPath)-1)
	EndIf	
		
	aDiretorios := Directory(::cPath, "D")
	
	lRetorno := (Len(aDiretorios) > 0)
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Arquivos  �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar uma colecao de LJCDadosArquivo.	  ���
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
Method Arquivos() Class LJCDiretorio
Return ::oArquivos   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Destroy   �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em destruir o objeto							  ���
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
Method Destroy() Class LJCDiretorio 
       Local nC := 0
       Local nTot := ::oArquivos:Count()
       
       For nC := 1 to nTot
       		::oArquivos:Elements(nC) := FreeObj(::oArquivos:Elements(nC) )
       Next

Return ::oArquivos

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Ler       �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em ler os arquivos do diretorio.  	  		  ���
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
Method Ler() Class LJCDiretorio
	
	Local aArquivos		:= {}						//Array com o retorno dos arquivos do diretorio
	Local oDadosArq		:= Nil						//Objeto do tipo DadosArq com informacoes sobre o arquivo
	Local nCount		:= 0						//Variavel de controle contador
	
	//Estancia o objeto Arquivos (esta inicializando toda vez que pede para ler)
	::oArquivos	:= LJCArquivos():Arquivos()
	
	//Busca os arquivos
	aArquivos := DIRECTORY(::cPath + ::cBarra + "*.*")
	
	For nCount := 1 To Len(aArquivos)
		//Estancia o objeto LJCDadosArquivo
		oDadosArq := LJCDadosArquivo():DadosArq(::cPath, aArquivos[nCount][1])
		//Atribui os valores ao objeto		
		oDadosArq:cNomeArq 	:= aArquivos[nCount][1]
		oDadosArq:nTamanho 	:= aArquivos[nCount][2]
		oDadosArq:dDataMod  := aArquivos[nCount][3]
		oDadosArq:cHoraMod	:= aArquivos[nCount][4]
		oDadosArq:cAtribut	:= aArquivos[nCount][5]  
		//Adiciona o objeto na colecao				
		::oArquivos:Add(oDadosArq:cNomeArq ,oDadosArq)
	Next
	
Return ::oArquivos