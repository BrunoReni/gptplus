#INCLUDE "MSOBJECT.CH" 
#INCLUDE "AUTODEF.CH"

#DEFINE NOMEARQUIVO "ljtef" + IF(!FindFunction("STFGetStation"),  LjGetStation("LG_CODIGO"), STFGetStation("LG_CODIGO")) + ".log"		//Nome do arquivo de log do tef
#DEFINE PATH "\log\tef" + cEmpAnt + cFilAnt							//Diretorio onde sera gravado os arquivos de log.

User Function LOJA0011 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCTef    	   �Autor  �Vendas Clientes     � Data �  18/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gravar o log de tef.                         ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCTef From LJALog
			
	Data lHabilitad									//Se a gravacao do log esta habilitada
	Method Tef()									//Metodo construtor
	Method Gravar(cTexto)							//Metodo que ira gravar o arquivo de log de tef    
	Method _Gravar(cTexto)							//Metodo que ira gravar o arquivo de log de tef    

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Tef       �Autor  �Vendas Clientes     � Data �  18/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTef.						          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Tef() Class LJCTef
	
	Local cLog := 0								//Identifica se o log esta habilitado
	//Executa o metodo construtor da classe pai.
	::ALog()
	
	::cNomeArq 	:= NOMEARQUIVO 
	::cPath		:= StrTran(AllTrim(PATH), space(1),"")
	
	If GetRemoteType() == REMOTE_LINUX
		::cPath := StrTran(::cPath, "/", "\")	
	EndIf
	
	cLog := GetPvProfString("Log", "LogTef", "0", GetClientDir() + "TOTVSAPI.INI")
	
	::lHabilitad := (cLog == "1")
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gravar    �Autor  �Vendas Clientes     � Data �  19/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o arquivo de log de tef.	  		  ���
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
Method Gravar(cTexto) Class LJCTef
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
	
	If ::lHabilitad				
		//Chama o metodo da classe pai para gravar o arquivo
		lRetorno := _Super:Gravar(cTexto)
	EndIf
			
Return lRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �_Gravar   �Autor  �Vendas Clientes     � Data �  19/10/07   ���
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
Method _Gravar(cTexto) Class LJCTef
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
			
	//Chama o metodo da classe pai para gravar o arquivo
	lRetorno := ::Gravar(cTexto)
			
Return lRetorno
