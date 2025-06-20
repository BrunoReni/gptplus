#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"

Function LOJA1342 ; Return 	 // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJANfOpos        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos os ECF'S do   ���
���			 �modelo LJANfDaruma											     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJANfOpos From LJAEcnf   
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
		
	Method New(oTotvsApi)														//Metodo construtor
	Method AbrirPorta(cPorta)													//Abre a porta serial para comunicacao com o ECF
	Method FechaPorta(cPorta)													//Fechar a porta serial	
   	Method AbrirCNF()
   	Method FechaCNF()
   	Method InicVar()															//Inicializando variaveis
	Method ImpTextoNf(cTexto)
	Method StImp()
	Method CarregMsg()
	Method ImpBitMap()
	Method TrataTexto(cTexto)
	Method TrataTags(cTexto)

EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJANfDaruma.     			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New(oTotvsApi) Class LJANfOpos
   
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
    
    //Carrega as mensagens
	::CarregMsg()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirPorta�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirPorta(cPorta) Class LJANfOpos
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

	oParams		:= ::PrepParam({"9","Open", "TOTVSIBM"}) 		
	cRetorno 	:= ::EnviarCom(oParams)        
	oRetorno 	:= ::TratarRet(cRetorno)        
		
	If oRetorno:cAcao == ERRO
		Return(oRetorno)
	EndIf
	
	////////////////////
	oParams		:= ::PrepParam({"9","ClaimDevice", "200"}) 	
	cRetorno 	:= ::EnviarCom(oParams)        
	oRetorno 	:= ::TratarRet(cRetorno)        
		
	If oRetorno:cAcao == ERRO
		Return(oRetorno)
	EndIf
	
	///////////////////
	oParams		:= ::PrepParam({"9","PutDeviceEnabled", "-1"}) 	
	cRetorno 	:= ::EnviarCom(oParams)        
	oRetorno 	:= ::TratarRet(cRetorno)        
	
	If oRetorno:cAcao == ERRO
		Return(oRetorno)
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InicVar   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em inicializar variaveis                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method InicVar() Class LJANfOpos

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �StImp		�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method StImp() Class LJANfOpos 
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({DARUMANF,"regPortaComunicacao_DUAL_DarumaFramework"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
        
Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ImpTextoNf       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTexto) - Modelo do ecf selecionado.		   	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method ImpTextoNf(cTexto) Class LJANfOpos
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	Default cTexto	:= "TEXTO VAZIO"
	
	oRetorno	:= ::TrataTexto(cTexto)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarregMsg �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregMsg() Class LJANfOpos
	::AdicMsgECF("0", "Sucesso", OK)
	::AdicMsgECF("", "Sucesso",  OK)
	::AdicMsgECF("106", "An illegal parameter or process, or unsupported function is specified",ERRO)
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarregMsg �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FechaPorta() Class LJANfOpos
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

	oParams		:= ::PrepParam({"9","Close"}) 	
	cRetorno 	:= ::EnviarCom(oParams)           
    oRetorno 	:= ::TratarRet(cRetorno)    

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarregMsg �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirCNF() Class LJANfOpos

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	oParams		:= ::PrepParam({"9","TransactionPrint", "2" , "11"}) 	
	cRetorno 	:= ::EnviarCom(oParams)        
    oRetorno 	:= ::TratarRet(cRetorno)    
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FechaCNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FechaCNF() Class LJANfOpos

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	oParams		:= ::PrepParam({"9","PrintNormal", "2" , chr(27) + "|5lF" }) 	
	cRetorno 	:= ::EnviarCom(oParams)        
	
	oParams		:= ::PrepParam({"9","CutPaper", "100"}) 	
	cRetorno 	:= ::EnviarCom(oParams)        
	
	oParams		:= ::PrepParam({"9","TransactionPrint", "2" , "12"}) 	
	cRetorno 	:= ::EnviarCom(oParams)        
    oRetorno 	:= ::TratarRet(cRetorno)    

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpBitMap �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpBitMap() Class LJANfOpos

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 		:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 		:= Nil      	//Objeto que sera retornado pela funcao
	Local cLineWidth    := ""			// Linhas
	
	///////////////////
	oParams		:= ::PrepParam({"9","GetRecLineWidth"}) 	
	cRetorno 	:= ::EnviarCom(oParams)        	
	
	If cRetorno <> "" .AND. Val(cRetorno) > 0
		cLineWidth := cValToChar(Val(cRetorno) / 5)
	EndIf
	
	oParams		:= ::PrepParam({"9","PrintBitmap", "2", "logo.bmp", cLineWidth, "2" }) 	
	cRetorno 	:= ::EnviarCom(oParams)        	
	oRetorno 	:= ::TratarRet(cRetorno)        
	
	If oRetorno:cAcao == ERRO
	 	Return(oRetorno)
	EndIf

Return oRetorno


/*����������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �TrataTexto       �Autor  �Vendas Clientes     � Data �  06/09/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Trata as tags enviadas por cTexto e enviar para as respectivas   	 ���
���			 �fun��es da LJANfOpos												 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTexto) - Modelo do ecf selecionado.		   	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������*/
Method TrataTexto(cTexto) Class LJANfOpos
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
Local cTextoAux	:= ""			//Auxiliar para cTexto

Default cTexto := ""

cTextoAux	:= cTexto
cTextoAux	:= AllTrim(::TrataTags(cTextoAux))
oParams		:= ::PrepParam({"9","PrintNormal", "2" , cTextoAux + chr(13)})
cRetorno 	:= ::EnviarCom(oParams)
oRetorno 	:= ::TratarRet(cRetorno)

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �TrataTags �Autor  �Vendas Clientes     � Data �  06/09/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � 													          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cMensagem) - Mensagem Promocional 			   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �cMsg									  					  ���
���������������������������������������������������������������������������*/
Method TrataTags( cTexto ) Class LJANfOpos
Local cMsg := ""

DEFAULT cTexto := ""

cMsg := cTexto
cMsg := RemoveTags( cMsg )

Return cMsg