#INCLUDE "DEFECF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJXTEFA.CH"

#DEFINE DELIMIT		"<@#DELIMIT#@>"
#DEFINE FIMSTR		"<@#FIMSTR#@>"

Function LJCSAT ; Return  	// "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCSAT       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, que realiza integracao com CP (Tef do Mexico )	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCSAT
   			
	Data oTotvsAPI				// Objeto do tipo LJCTotvsAPI
	Data cUltimaSessao			// Armazena o numero da ultima sessao
	Data oGlobal					//Log do SAT

	Method New(oTotvsAPI)									
	Method EnviarCom(oParams)								
	Method PrepParam(aDados)                              	
	Method TratarRet(cRetorno) 
	Method GravarLog(cMensagem)								//Grava o log do ecf
	Method GravLogEnv(oParams)								//Grava o log dos dados enviados
	Method GravLogRet(cRetorno, oParams)					//Grava o log dos dados retornados

	   							

EndClass


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJAEcf.       			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oTotvsAPI) - Objeto do tipo LJCTotvsApi.    			 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New() Class LJCSAT

    Self:oTotvsAPI  := LJCTotvsApi():New()  
    Self:oTotvsAPI:AbrirCom()
    Self:oGlobal		:= LJCGlobal():Global()  

Return Self
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �EnviarCom	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em enviar o comando para TotvsApi.dll/so.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method EnviarCom(oParams) Class LJCSAT 

	Local nCount 	:= 0							//Variavel de contador
	Local cBuffer 	:= ""    					//Buffer que sera enviado a totvsapi
	Local cRetorno  := ""                     //Retorno do metodo
    
If oParams <> Nil


	//Grava log de envio
	::GravLogEnv(oParams)
	
	
	//Coloca os parametros em cBuffer
	For nCount := 1 To oParams:Count()
		cBuffer += oParams:Elements(nCount):cParametro + DELIMIT
	Next
	
	cBuffer += FIMSTR
	cBuffer := Encode64(cBuffer)
	/* Possivel erro: caso ocorra o valor do PadR deve ser alterado 
	   [FATAL][SERVER] [Thread 4768] [THROW] ExecInDllRun2 - The Buffer cannot be bigger than 20kb at file .\appbase.cpp line 177
	*/
	cBuffer := PadR(cBuffer, 512000) //512000 mil caracteres
	
	//envio para dll o xml
	If ExeDLLRun2(Self:oTotvsAPI:nHandle, 1, @cBuffer) == 1 
		cBuffer := Decode64(cBuffer)

		nPos := At(DELIMIT, cBuffer)	    

		If nPos == 0
			nPos := At(FIMSTR, cBuffer)
		EndIf
		nFinal := At(FIMSTR, cBuffer)
		If nFinal == 0 
			cRetorno := cBuffer
		Else
			cRetorno := Substr(cBuffer, 1, nPos - 1)
		EndIf
		
		If nPos <> nFinal
			cBuffer := Substr(cBuffer, nPos + Len(DELIMIT), nFinal - (nPos + Len(DELIMIT)))
		Else
			cBuffer := ""
		EndIf
		
		Self:oTotvsAPI:TrataRet(cBuffer, oParams) //tratamento do retorno
		
		
		//Grava log de retorno
		::GravLogRet(cRetorno, oParams)
	Else
		//Problemas de comunicacao com a dll/so
		cRetorno := "-999"
	EndIf 
Else
	cRetorno := ""	
EndIf	        
	
Return cRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �PrepParam	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em preparar os parametros de envio para TotvsApi.dll/so���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPA1 (1 - aDados) - Array com os parametros.     				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method PrepParam(aDados) Class LJCSAT
	
	Local oParams := Nil		// Objeto do tipo LJCParamsAPI
	Local oParam 	:= Nil		// Objeto do tipo LJCParamAPI
	Local nCount	:= 0		// Contador
	
	oParams := LJCParamsAPI():New()
	
	For nCount := 1 To Len(aDados)
		
		oParam := LJCParamAPI():New(aDados[nCount])
		
		oParams:ADD(nCount, oParam)
		
	Next nCount
	
Return oParams


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GravarLog	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o log do ecf					    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTexto) - Mensagem do log.          				 	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GravarLog(cTexto) Class LJCSAT
	
	::oGlobal:GravarArq():Log():Ecf():Gravar(cTexto)
		
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GravLogEnv       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o log com os dados de envio.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oParams) - Objeto do tipo LJCParamsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GravLogEnv(oParams) Class LJCSAT
	
	Local cAux		:= ""									//Variavel auxiliar para gravacao do log
	Local nCount	:= ""									//Variavel auxiliar contador
	
	cAux := "Comando Enviado: "
	
	For nCount := 2 To oParams:Count()
		
		If nCount == 2 .AND. nCount == oParams:Count()
			cAux += oParams:Elements(nCount):cParametro + "()"
		
		ElseIf nCount == 2 .AND. nCount < oParams:Count()
			cAux += oParams:Elements(nCount):cParametro + "("		
		
		ElseIf nCount > 2
			cAux += oParams:Elements(nCount):cParametro + ","
			
		EndIf
	Next
	
	If (nCount - 1) > 2 .AND. (nCount -1) == oParams:Count()
		cAux := Substr(cAux, 1, Len(cAux) - 1) + ")"
	EndIf
	
	cAux := Left(cAux, Min(Len(cAux), 300))
	
	::GravarLog(cAux)
	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GravLogRet       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o log com os dados de retorno.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRetorno) - Retorno da dll.							 ���
���			 �EXPO1 (2 - oParams) - Objeto do tipo LJCParamsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GravLogRet(cRetorno, oParams) Class LJCSAT
	
	Local cAux		:= ""									//Variavel auxiliar para gravacao do log
	Local nCount	:= ""									//Variavel auxiliar contador
	
	cAux := "Retorno: " + cRetorno
	
	For nCount := 2 To oParams:Count()
		
		If nCount == 2 .AND. nCount < oParams:Count()
			cAux += " -> ("		

		ElseIf nCount > 2
			cAux += oParams:Elements(nCount):cParametro + ","

		EndIf
	Next
	
	If (nCount - 1) > 2 .AND. (nCount -1) == oParams:Count()
		cAux := Substr(cAux, 1, Len(cAux) - 1) + ")"
	EndIf
	
	cAux := Left(cAux, Min(Len(cAux), 300))
	
	::GravarLog(cAux)
	
Return Nil