#INCLUDE "MSOBJECT.CH" 

User Function LOJA0012 ; Return  // "dummy" function - Internal Use

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Classe    �LJALog 			  �Autor  �Vendas Clientes     � Data �  14/11/07   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata de log.										  	    ���
�����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		    ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Class LJALog From LJAAbstrataArquivos
	
	Data nTamLog									//Determina o tamanho do log
	
	Method ALog()									//Metodo construtor
	Method DataHora()    							//Metodo que ira retornar data e hora.
   	Method VerTamArq()								//Metodo que ira verificar o tamanho do arquivo
   	Method Gravar(cTexto)							//Responsavel em gravar o arquivo de log
   	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ALog      �Autor  �Vendas Clientes     � Data �  14/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJALog.          		              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ALog() Class LJALog

	Local cTamLog := ""								//Determina o tamanho do log
	//Executa o metodo construtor da classe pai.
	::AbstArq()
 	
	cTamLog := SuperGetMV('MV_LJTMLOG',, "0") 
	
	If Val(cTamLog) == 0
		//Configura o log em 100Kb
		::nTamLog := 100 * 1000
	ElseIf Val(cTamLog) > 1000
		//Configura o log em 1Mb
		::nTamLog := 1000 * 1000	
	Else
		::nTamLog := Val(cTamLog) * 1000		
	EndIf
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �DataHora  �Autor  �Vendas Clientes     � Data �  14/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retorna a data e hora no formato 			  ���
���			 �dd/mm/yyyy hh:mm:ss								  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �String												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DataHora() Class LJALog
	
	Local cRetorno := ""					//Variavel de retorno do metodo
	
	cRetorno =  StrZero(Day(Date()),2) + "/" + StrZero(Month(Date()),2) + "/" + Str(Year(Date()),4)
	cRetorno += " " + SubStr(Time(),1,2) + ":" + SubStr(Time(),4,2) + ":" + SubStr(Time(),7,2)
	
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �VerTamArq �Autor  �Vendas Clientes     � Data �  14/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em verificar o tamanho do arquivo e renomea-lo  ���
���			 �se ultrapassar 1MB.								  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VerTamArq() Class LJALog
	
	Local oDiretorio 	:= Nil						//Objeto do tipo Diretorio
	Local cNome			:= ""						//Nome do arquivo a ser renomeado
	
	//Instancia o objeto Diretorio 
	oDiretorio := LJCDiretorio():Diretorio(::cPath)
	
	//Verifica se o diretorio existe
	If oDiretorio:Existe()                
		//Le os arquivos do diretorio		
		oDiretorio:Ler()
		//Verifica se o arquivo existe           
		If oDiretorio:Arquivos():Contains(Upper(::cNomeArq))
			//Verifica se o arquivo esta com mais de 1MB
			If oDiretorio:Arquivos():ElementKey(Upper(::cNomeArq)):nTamanho >= ::nTamLog
				
				//Verifica se o path esta vindo com barra no final
				If Substr(::cPath, Len(::cPath), 1) != ::Arquivo():cBarra
					::cPath	:= ::cPath + ::Arquivo():cBarra
				EndIf
				

				oDiretorio := LJCDiretorio():Diretorio(::cPath + "bkp")
				
				//Cria o diretorio de BKP se n�o existir
				If !oDiretorio:Existe()
					oDiretorio:Criar()
				EndIf
				//Monta o nome do arquivo no formato
				//Nome + DDMMYYYY + HHMMSS + "." + extensao
				//Exemplo: LJTEF14112007120510.LOG
				cNome := ::cPath + "bkp" + ::Arquivo():cBarra + Substr(::cNomeArq, 1, AT(".", ::cNomeArq) - 1)
				cNome += StrZero(Day(Date()),2) + StrZero(Month(Date()),2) + Str(Year(Date()),4) + SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2)
				cNome += Substr(::cNomeArq, RAT(".", ::cNomeArq))
							
				//Renomeia o arquivo
				::Arquivo():Renomear(cNome)        
							
			EndIf

		EndIf 

	EndIf    	
	oDiretorio:Destroy()
	oDiretorio := FreeObj(oDiretorio)

	   	
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gravar    �Autor  �Vendas Clientes     � Data �  04/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o arquivo de log.			  		  ���
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
Method Gravar(cTexto) Class LJALog
	
	Local lRetorno := .T.						//Variavel de retorno do metodo
	
	//Verifica se precisa renomear o arquivo
	::VerTamArq()
	
	//Adiciona data e hora no texto.
	cTexto = ::DataHora() + " - " + cTexto
		
	//Chama o metodo da classe pai para gravar o arquivo
	If lRetorno
		lRetorno := _Super:Gravar(cTexto)
	EndIf
			
Return lRetorno
