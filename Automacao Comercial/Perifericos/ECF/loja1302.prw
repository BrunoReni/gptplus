#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"

Function LOJA1302 ; Return  	// "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJAECF           �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos os ECF'S      ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJAEcf
   			
	Data oTotvsAPI											//Objeto do tipo LJCTotvsAPI
	Data oMensagens											//Objeto do tipo LJCMensagensECF
	Data oAliquotas											//Objeto do tipo LJCAliquotasECF
	Data oFormas											//Objeto do tipo LJCFormasECF
	Data oTotsNF											//Objeto do tipo LJCTotalizadoresECF
	Data oGerencial											//Objeto do tipo LJCGerenciaisECF
	Data oFlagsFisc											//Objeto do tipo LJCFlagsFiscaisECF	
	Data oDadosRedZ											//Objeto do tipo LJCDadosReducaoZ	
	Data cCnpj												//Cnpj cadastrado no ecf    
	Data cIE												//Incricao estatual cadastrado no ecf
	Data cIM												//Incricao municipal cadastrado no ecf
	Data cModelo											//Modelo do ecf
	Data cFabric											//Fabricante do ecf
	Data cTipo												//Tipo da impressora
	Data cFirmWare											//Versao do FirmWare cadastrado no ecf
	Data cRazaoSoc											//Razao Social cadastrada no ecf
	Data cFantasia											//Nome fantasia cadastrado no ecf
	Data cEndereco1											//Endereco linha 1 cadastrado no ecf						
	Data cEndereco2											//Endereco linha 2 cadastrado no ecf						
	Data cOperador											//Operador cadastrado no ecf						
	Data cLoja												//Loja cadastrado no ecf						
	Data cNumEcf											//Numero do caixa cadastrado no ecf						
	Data cNrSerie											//Numero de serie do ecf						
	Data oGlobal											//Objeto do tipo LJCGlobal
	Data cPathMFD											//Caminho e nome do arquivo da Memoria Fita Detalhe
	Data cPathMF											//Caminho e nome do arquivo da Memoria Fiscal
	Data cPathTipoE											//Caminho e nome do arquivo Tipo E Ato Cotepe 17/04 PAF-ECF
	Data cDataIns											//Data de Instalacao do Software Basico da impressora
	Data cHoraIns											//Hora de Instalacao do Software Basico da impressora
		
	Method New(oTotvsAPI)									//Metodo construtor
		
	//Metodos publicos
	Method EnviarCom(oParams)								//Envia o comando para a ProtheusAPI    
	Method PrepParam(aDados)                              	//Prepara os parametros para ser enviados
	Method TratarRet(cRetorno)    							//Trata o retorno do comando enviado para o ecf
	Method AdicMsgECF(cCodigo, cMensagem, cAcao)           	//Adiciona mensagem de retorno no objeto oMensagens
	Method AdicAliq(cIndice, nAliquota, lIss)           	//Adiciona uma aliquota no objeto oAliquotas
	Method AdicTotNf(cIndice, cTotaliz, cTipo, cLegenda)   	//Adiciona um totalizador NF no objeto oTotNF
	Method AdicGerenc(cIndice, cGerencial)           		//Adiciona RG no objeto oGerencial
	Method AdicForma(cIndice, cForma, lVincula)           	//Adiciona uma forma pgto no objeto oFormas
	Method GetForma(cForma)									//Retorna se a forma esta cadastrada no ecf
	Method GetTotaliz(cTotaliz)								//Retorna se o totalizador esta cadastrada no ecf
	Method GravarLog(cMensagem)								//Grava o log do ecf
	Method GravLogEnv(oParams)								//Grava o log dos dados enviados
	Method GravLogRet(cRetorno, oParams)					//Grava o log dos dados retornados
	Method PrepRel()										//Prepara o relatprio a ser impresso
	
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
Method New(oTotvsAPI) Class LJAEcf

	::oTotvsAPI 	:= oTotvsAPI
	::oMensagens 	:= LJCMensagensECF():New()    
    ::oAliquotas	:= LJCAliquotasECF():New()
	::oFormas		:= LJCFormasECF():New()
	::oTotsNF		:= LJCTotalizadoresECF():New()
	::oGerencial	:= LJCGerenciaisECF():New()
	::oFlagsFisc	:= LJCFlagsFiscaisECF():New()
	::oDadosRedZ	:= Nil
	::oGlobal		:= LJCGlobal():Global()    

	::cCnpj			:= ""
	::cIE			:= ""
	::cIM			:= ""
	::cModelo		:= ""
	::cFabric		:= ""
	::cTipo			:= ""
	::cFirmWare		:= ""
	::cFantasia		:= ""
	::cEndereco1	:= ""
	::cEndereco2	:= ""
	::cOperador		:= ""
	::cLoja			:= ""
	::cNumEcf		:= ""
	::cNrSerie		:= ""
    ::cRazaoSoc		:= "" 
    ::cPathMFD 		:= ""	
    ::cPathMF		:= ""
    ::cPathTipoE	:= ""
    ::cDataIns		:= ""
	::cHoraIns		:= ""
        
	//Adiciona a mensagem de erro ao tentar enviar algum comando para TotvsApi.dll/so
	::AdicMsgECF("-999", "Erro de comunica��o com TotvsAPI.DLL/SO", ERRO)
	//Adiciona a mensagem de forma n�o cadastrada no ECF    
	::AdicMsgECF("-998", "Forma de pagamento n�o cadastrada na impressora fiscal", ERRO)
	//Adiciona mensagem generica de comando ok
	::AdicMsgECF("-997", "Comando executado com sucesso", OK)
	//Adiciona a mensagem de totalizador n�o cadastrado no ECF    
	::AdicMsgECF("-996", "Totalizador nao fiscal n�o cadastrado na impressora fiscal", ERRO)
	
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
Method EnviarCom(oParams) Class LJAEcf
	
	Local cRetorno 	:= ""									//Retorno do metodo
	
	//Grava log de envio
	::GravLogEnv(oParams)
	
	cRetorno := ::oTotvsAPI:EnviarCom(oParams)
	
	//Grava log de retorno
	::GravLogRet(cRetorno, oParams)
		
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
Method PrepParam(aDados) Class LJAEcf
	
	Local oParams 	:= Nil							//Objeto do tipo LJCParamsAPI
	Local oParam 	:= Nil                         	//Objeto do tipo LJCParamAPI
	Local nCount	:= 0
	
	oParams := LJCParamsAPI():New()
	
	For nCount := 1 To Len(aDados)
		
		oParam := LJCParamAPI():New(aDados[nCount])
		
		oParams:ADD(nCount, oParam)
	Next
	
Return oParams

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �TratarRet	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o retorno da TotvsApi.dll/so				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRetorno) - Retorno do comando enviado.   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method TratarRet(cRetorno) Class LJAEcf
	
	Local oRetorno := Nil							//Objeto do tipo LJCRetornoEcf
	
	oRetorno := LJCRetornoEcf():New()
		
	If ::oMensagens:Contains(cRetorno)
		oRetorno:cCodigo 	:= cRetorno
		oRetorno:cMensagem 	:= ::oMensagens:ElementKey(cRetorno):cMensagem
		oRetorno:cAcao		:= ::oMensagens:ElementKey(cRetorno):cAcao
	Else
		oRetorno:cCodigo 	:= cRetorno
		oRetorno:cMensagem 	:= "Problema desconhecido, favor contatar suporte"
		oRetorno:cAcao		:= ERRO
	EndIf
	
Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AdicMsgECF       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em adicionar as mensagens retornadas pelo ecf 		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCodigo) - Codigo da mensagem.			   				 ���
���			 �EXPC2 (2 - cMensagem) - Mensagem.   								 ���
���			 �EXPC3 (3 - cAcao) - Acao a ser tomada.			   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AdicMsgECF(cCodigo, cMensagem, cAcao) Class LJAEcf
	
	Local oMsg := Nil
	
	oMsg := LJCMensagemECF():New(cCodigo, cMensagem, cAcao)
	
	::oMensagens:ADD(cCodigo, oMsg)
	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AdicAliq 	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em adicionar uma aliquota no objeto oAliquotas 		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice utilizado pelo ecf.	   				 ���
���			 �EXPN1 (2 - nAliquota) - Valor da aliquota.						 ���
���			 �EXPL1 (3 - lIss) - Se a aliquota e de iss.		   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AdicAliq(cIndice, nAliquota, lIss) Class LJAEcf
    
	Local oAliquota := Nil						//Objeto do tipo LJCAliquotaEcf
	
	oAliquota := LJCAliquotaEcf():New(cIndice, nAliquota, lIss)
	
	::oAliquotas:ADD(nAliquota, oAliquota, .T.)
   	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AdicTotNf	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em adicionar um totalizador NF no objeto oTotNF  	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice utilizado pelo ecf.	   				 ���
���			 �EXPC2 (2 - cTotaliz) - Descricao do totalizador.					 ���
���			 �EXPC3 (3 - cTipo) - Tipo (E- entrada de valor / S - saida de valor)���
���			 �EXPC4 (4 - cLegenda) - Legenda que o totalizador pertence          ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AdicTotNf(cIndice, cTotaliz, cTipo, cLegenda) Class LJAEcf
	
	Local oTotNf := Nil						//Objeto do tipo LJCTotalizadorEcf
	
	oTotNf := LJCTotalizadorEcf():New(cIndice, cTotaliz, cTipo, cLegenda)
	
	::oTotsNF:ADD(Upper(AllTrim(cTotaliz)), oTotNf, .T.)
	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AdicGerenc       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em adicionar RG no objeto oGerencial    	     		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice utilizado pelo ecf.	   				 ���
���			 �EXPC2 (2 - cGerencial) - Descricao do relatorio gerencial.		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AdicGerenc(cIndice, cGerencial) Class LJAEcf
	
	Local oGerencial := Nil						//Objeto do tipo LJCGerencialEcf
	
	oGerencial := LJCGerencialEcf():New(cIndice, cGerencial)
	
	::oGerencial:ADD(Upper(AllTrim(cGerencial)), oGerencial, .T.)
	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AdicForma        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em adicionar uma forma pgto no objeto oFormas	 		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice utilizado pelo ecf.	   				 ���
���			 �EXPC2 (2 - cForma) - Descricao da forma.							 ���
���			 �EXPL1 (3 - lVincula) - Se a forma vincula.		   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �																     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AdicForma(cIndice, cForma, lVincula) Class LJAEcf
	
	Local oForma := Nil						//Objeto do tipo LJCFormaEcf
	
	oForma := LJCFormaEcf():New(cIndice, cForma, lVincula)
	
	::oFormas:ADD(Upper(AllTrim(cForma)), oForma, .T.)
	
Return Nil	

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GetForma         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar se a forma esta cadastrada no ecf	 		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Indice utilizado pelo ecf.	   				 ���																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GetForma(cForma) Class LJAEcf

	Local oRetorno := Nil
	
	cForma := Upper(AllTrim(cForma))
	
	If ::oFormas:Contains(cForma)
		//Forma de pagto encontrada no ecf
		oRetorno := ::TratarRet("-997")
		oRetorno:oRetorno := ::oFormas:ElementKey(cForma)
	Else
		//Forma nao cadastrada no ecf
		oRetorno := ::TratarRet("-998")
		oRetorno:cMensagem += " (" + cForma + ")"
	EndIf
	
Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �GetTotaliz       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar se o totalizador esta cadastrado no ecf	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTotaliz) - Totalizador utilizado pelo ecf.			 ���																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method GetTotaliz(cTotaliz) Class LJAEcf

	Local oRetorno := Nil
	
	cTotaliz := Upper(AllTrim(cTotaliz))
	
	If ::oTotsNF:Contains(cTotaliz)
		//Totalizador encontrado no ecf
		oRetorno := ::TratarRet("-997")
		oRetorno:oRetorno := ::oTotsNF:ElementKey(cTotaliz)
	Else
		//Totalizador nao cadastrado no ecf
		oRetorno := ::TratarRet("-996")  
		oRetorno:cMensagem += " (" + cTotaliz + ")"
	EndIf
	
Return oRetorno


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
Method GravarLog(cTexto) Class LJAEcf
	
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
Method GravLogEnv(oParams) Class LJAEcf
	
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
Method GravLogRet(cRetorno, oParams) Class LJAEcf
	
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
	
	::GravarLog(cAux)
	
Return Nil

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �PrepRel          �Autor  �Vendas Clientes     � Data �  16/04/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Prepara o relatorio para ser impresso com a quantidade maxima de	 ���
���Desc.     �bytes por comando e com o delimitador de quebra de linha			 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oRelOrig) - Relatorio original.						 ���
���			 �EXPC1 (2 - cDelLinha) - Delimitador de quebra de linha do ECF.	 ���
���			 �EXPN1 (3 - nBytes) - Quantidades de bytes suportado pelo ECF.		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �String														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/	
Method PrepRel(oRelOrig, cDelLinha, nBytes) Class LJAEcf

	Local oRelatorio 	:= Nil							//Objeto com as linhas do relatorio
	Local cAux			:= ""							//Variavel auxiliar que guarda o agrupamento das linhas		
	Local nCount		:= 0							//Contador de linhas do relatorio
	Local cLinhaRel		:= ""							//Variavel com cada linha do relatorio
	
	//Instancia o objeto LJCRelatoriosEcf
   	oRelatorio := LJCRelatoriosEcf():New()
	
	For nCount := 1 To oRelOrig:Count()
		
		cAux := cLinhaRel + oRelOrig:Elements(nCount) + cDelLinha
		
		If Len(cAux) <= nBytes
			
			cLinhaRel := cAux
		
		ElseIf Len(cAux) > nBytes
			oRelatorio:ADD(oRelatorio:Count(), cLinhaRel)

			cLinhaRel := oRelOrig:Elements(nCount) + cDelLinha
		EndIf
		
		If nCount == oRelOrig:Count()
			oRelatorio:ADD(oRelatorio:Count(), cLinhaRel)			
		EndIf
			
	Next
	
Return oRelatorio
