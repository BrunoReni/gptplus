#INCLUDE "MSOBJECT.CH" 

#DEFINE PATH GetClientDir() + "transtef"			//Diretorio onde sera gravado os arquivos de transacao

User Function LOJA0009 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCTransacoesTef �Autor  �Vendas Clientes     � Data �  16/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gravar o arquivo de controle para as transa- ���
���		     �coes de tef.                                                 		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCTransacoesTef From LJAAbstrataArquivos
			
	Method TransTef(cData, cHora)					//Metodo construtor
	Method _Gravar(cTexto)							//Metodo que ira gravar o arquivo
	Method Gravar(cTexto)							//Metodo que ira gravar o arquivo	
		
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TransTef  �Autor  �Vendas Clientes     � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTransacoesTef.   		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cData) - Data da transacao DDMMAAAA.		      ���
���			 �ExpC2 (2 - cHora) - Hora da transacao HHMMSS.  		      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransTef(cData, cHora) Class LJCTransacoesTef
	
	Default cData := ""
	Default cHora := ""
		
	//Executa o metodo construtor da classe pai.
	::AbstArq()
	
	::cNomeArq 	:= "tef" + cData + cHora + ".txt" 
	::cPath		:= PATH
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �_Gravar   �Autor  �Vendas Clientes     � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar um arquivo. 				  		  ���
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
Method _Gravar(cTexto) Class LJCTransacoesTef
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
	
	//Se o arquivo existir, apaga.
	If ::Arquivo():Existe()
		lRetorno := ::Arquivo():Apagar()
	EndIf
		
	//Chama o metodo da classe pai para gravar o arquivo
	If lRetorno
		lRetorno := ::Gravar(cTexto)
	EndIf
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gravar    �Autor  �Vendas Clientes     � Data �  21/11/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar um arquivo. 				  		  ���
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
Method Gravar(cTexto) Class LJCTransacoesTef
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
	
	//Se o arquivo existir, apaga.
	If ::Arquivo():Existe()
		lRetorno := ::Arquivo():Apagar()
	EndIf
		
	//Chama o metodo da classe pai para gravar o arquivo
	If lRetorno
		lRetorno := _Super:Gravar(cTexto)
	EndIf
		
Return lRetorno
