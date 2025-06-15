#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH" 

                                                                                                              
Function IONICS ; Return  // "dummy" function - Internal Use                                                  
                                                                                               
/*                                                                                              
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �IONICS      �Autor  �Vendas Clientes     � Data �  01/06/09   	 ���              
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos as bombas de  ���
���combustivel que utilizam o CONCENTRADOR IONICS						 		 ���
��������������������������������������������������������������������������������͹��                              
���Uso       �SigaLoja 	                                       		             ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/           
                                                   
Class Ionics From ConcBMBGas                                    
	                                                                                         
	Method New(oTotvsApi)									//Metodo construtor   
	
	Method AbrirPorta(cPorta)							   	//Abre a porta serial para comunicacao com o ECF  
	Method FechaPorta()								  		//Fechar a porta serial
	Method PortName()										//Fun��o respons�vel por retornar o nome da porta serial que est� sendo utilizada pela DLL.
	Method IniciaDll(cPath)									//Fun��o respons�vel por inicializar par�metros internos da dll.
	Method RstAutom() 										//Reset na automa��o em caso de troca de bomba, ou local dos pontos.
	Method VersaoDll() 										//Consulta a vers�o da biblioteca APET.dll.
	Method VSAutom(nEndereco)								//Consulta a vers�o do firmware APET.
	Method AutomacaoSer(nEndereco)							//Consulta o n�mero de s�rie do APET.
	Method Laco(nEndereco) 									//Retorna dados de configura��o dos la�os.
	Method LacoST(nEndereco) 								//Retorna dados de configura��o dos la�os em formato string.	
	Method ConfigLaco(nEndereco, nTPBomba, nPonto) 			//Configura n�mero de pontos e tipo de bomba do la�o 1.	
	Method ConfLacoRe(nEndereco, nTPBomba, nPonto, nLaco)	//Configura n�mero de pontos e tipo de bomba dos la�os.
	Method AlModPonto(nEndereco, nPonto, nModoPonto) 		//Envia comando para modificar o modo de opera��o do ponto.
	Method AltPreco(nEndereco, nBico, cPreco) 				//Envia comando para modificar o pre�o do bico.	
	Method LePreco(nEndereco, nBico) 						//L� o valor do pre�o unit�rio do bico.	
	Method LeEncerra(nEndereco, nBico) 						//Consulta o valor do encerrante no bico.	
	Method LeAbast(nEndereco) 								//Faz a leitura do primeiro abastecimento pendente no buffer e incrementa o ponteiro para a pr�xima posi��o de mem�ria.	
	Method LeSTAbast(nEndereco)	     						//Faz a leitura de abastecimento com retorno em string.                     	
	Method LeMensagem()    									//Retorna uma mensagem da fila de mensagens da automa��o.
	Method AutAbast(nEndereco, nBico, cAutorizacao) 		//Permite que o bico realize um abastecimento.	
	Method PreDeterm(nEndereco, nBico, nValor, cStrAbast)	//Permite que seja predeterminado um abastecimento. 
	Method TratarRet(cRetorno, nTipoTrat, cNomeFunc)        //Trata o retorno da DLL

EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  01/01/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe Ionics.     			    	     	 ���
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
		
Method New(oTotvsApi) Class Ionics                                                         
   
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
	     	
Return Self            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Numero da porta COM 									  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirPorta(cPorta) Class Ionics
	                                                                                           
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	//Local nTipoTrat := 2
 

	//Prepara os parametros de envio                                      
	oParams := ::PrepParam({APET, "InicializaSerial", cPorta})
 
    //Envia o comando                                         
    cRetorno := ::EnviarCom(oParams)                                        

    //Trata o retorno
    //::TratarRet(cRetorno, nTipoTrat, "InicializaSerial")

Return cRetorno      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento da porta serial.          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno										              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FechaPorta() Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	//Local nTipoTrat := 2
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "FechaSerial"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "FechaSerial")
    
Return cRetorno        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome da porta serial.     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PortName() Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local nTipoTrat := 3

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "PortName"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "PortName")
    
Return cRetorno        
                                                    	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por iniciar parametros internos da DLL   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Caminho da onde se encontra a DLL					  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno										              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IniciaDll(cPath) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local nTipoTrat := 2
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "InicializaDll", cPath})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "InicializaDll")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por resetar a automacao   				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 															  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno										              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RstAutom() Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local nTipoTrat := 2
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "ResetAutomacao"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno  
	::TratarRet(cRetorno, nTipoTrat, "ResetAutomacao")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por consultar a versao da DLL   		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 															  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno								            		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VersaoDll() Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local nTipoTrat := 4

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "VersaoDll"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
   	::TratarRet(cRetorno, nTipoTrat, "VersaoDll")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por consultar versao do Firmware do APET ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET 								      ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VSAutom(nEndereco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))  
	Local nTipoTrat := 4
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "VersaoAutomacao", cEndereco})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "VersaoAutomacao")
    
Return cRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por consultar o numero de serie da DLL   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 						 								      ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno							            			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AutomacaoSer(nEndereco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco)) 
	Local nTipoTrat := 4 

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "AutomacaoNumSerie",cEndereco})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "AutomacaoNumSerie")
    
Return cRetorno   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar as configuracoes dos lacos  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET 								      ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno										              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Laco(nEndereco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cConfig   := space(20)//Estrutura que recebera a configuracao do laco
	Local cEndereco := ALLTRIM(str(nEndereco))  
	Local nTipoTrat := 2

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "ConfiguracaoLaco", cEndereco, cConfig})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "ConfiguracaoLaco")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por configurar retornar configuracao dos ���
���			  lacos em formato string 									  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET 								      ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno								            		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LacoST(nEndereco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))       
	Local nTipoTrat := 4

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "ConfigLacoST", cEndereco})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "ConfigLacoST")
    
Return cRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o n�mero de pontos e   	  ���
���			  tipo de bomba do la�o 1									  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���			   2 - Tipo de bomba										  ���
���  		   3 - Numero do Ponto 										  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno										              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfigLaco(nEndereco, nTPBomba, nPonto) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cTPBomba  := ALLTRIM(str(nTPBomba))
	Local cPonto 	:= ALLTRIM(str(nPonto))   
	Local nTipoTrat := 2

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "ConfigurarLaco", cEndereco, cTPBomba, cPonto})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "ConfigLacoST")
    
Return cRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o n�mero de pontos e   	  ���
���			  tipo de bomba dos la�os									  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���			   2 - Tipo de bomba										  ���
���  		   3 - Numero do Ponto 										  ���
��� 		   4 - Numero do laco										  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfLacoRe(nEndereco, nTPBomba, nPonto, nLaco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cTPBomba  := ALLTRIM(str(nTPBomba))
	Local cPonto 	:= ALLTRIM(str(nPonto))
	Local cLaco 	:= ALLTRIM(str(nLaco))
	Local nTipoTrat := 2

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "ConfigurarLacoRef", cEndereco, cTPBomba, cPonto, cLaco})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "ConfigurarLacoRef")
    
Return cRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por modificar o modo de operacao do ponto���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���  		   2 - Numero do Ponto 										  ���
��� 		   3 - Numero do modo do ponto								  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AlModPonto(nEndereco, nPonto, nModoPonto) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cPonto 	:= ALLTRIM(str(nPonto))
	Local cModoPonto:= ALLTRIM(str(nModoPonto)) 
	Local nTipoTrat := 2

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "AlteraModoPonto", cEndereco, cPonto, cModoPonto})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "AlteraModoPonto")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por alterar o preco do bico              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���  		   2 - Numero do Bico 										  ���
��� 		   3 - Novo preco								  			  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AltPreco(nEndereco, nBico, cPreco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cBico 	:= ALLTRIM(str(nBico))
	Local cPreco	:= ALLTRIM(cPreco)  
	Local nTipoTrat := 2                                                                

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "AlteraPreco", cEndereco, cBico, cPreco})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "AlteraPreco")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por ler o preco do bico              	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���  		   2 - Numero do Bico 										  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno								            		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LePreco(nEndereco, nBico) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cBico 	:= ALLTRIM(str(nBico))                        
	Local nTipoTrat := 3

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "LePreco", cEndereco, cBico})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "LePreco")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por consultar valor do encerrante no bico���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���  		   2 - Numero do Bico 										  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeEncerra(nEndereco, nBico) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cBico 	:= ALLTRIM(str(nBico)) 
	Local nTipoTrat := 4

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "LeEncerrante", cEndereco, cBico})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "LeEncerrante")
    
Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por ler primeiro abastecimento pendente  ��� 
��� 		 no buffer e posiciona no proximo ponteiro					  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno									            	  ���
�������������������������������������������������������������������������ͼ�� 
��� I M P O R T A N T E !!! ESTA FUNCAO SER� SUBSTITUIDA POR LeSTAbast    ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeAbast(nEndereco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cStrAbast := space(20)//Recebera as informacoes do abastecimento pendente no buffer
	Local nTipoTrat := 4

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "LeAbast", cEndereco, cStrAbast})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "LeAbast")
    
Return cRetorno  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por ler o abatecimento com retorno em    ��� 
��� 		 string							  							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno            										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeSTAbast(nEndereco) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local nTipoTrat := 1
	Local aDados 	:= {}

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "LeSTAbast", cEndereco})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams) 
    
    aDados  	:= strtokarr(cRetorno, "|")
	cTrat 		:= substr(aDados[1], 3) + "|" + substr(aDados[2], 3)  //ES especifica o estado atual da bomba
		
    //Trata o retorno
    ::TratarRet(cTrat, nTipoTrat, "LeSTAbast")
    
Return cRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retonar uma mensagem da fila de      ��� 
��� 		 mensagens da automacao							  			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 															  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno            										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeMensagem() Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local nTipoTrat := 4

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "LeMensagem"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "LeMensagem")
    
Return cRetorno  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel permitir que um bico faca abastecimento  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���			   2 - Numero do Bico										  ���
���  		   3 - Tipo de autotizacao:  C=cancela / A=autoriza			  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno            										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AutAbast(nEndereco, nBico, cAutorizacao) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cBico  	:= ALLTRIM(str(nBico))  
	Local nTipoTrat := 2
                                                                                                 
	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "AutorizaAbast", cEndereco, cBico, ALLTRIM(cAutorizacao)})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "AutorizaAbast")
    
Return cRetorno        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IONICS �Autor  �Vendas Clientes     � Data �  01/01/09   	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel permitir que seja predeterminado um      ���
���			  abastecimento      										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� 1 - Localizacao do APET									  ���
���			   2 - Numero do Bico										  ���
���  		   3 - Valor que deseja liberar ($ ou L)  			  		  ���
���  		   4 - Tipo de abastecimento ($ ou L)	  			  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �cRetorno            										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PreDeterm(nEndereco, nBico, nValor, cStrAbast) Class Ionics

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       //String contendo o retorno da funcao que envia o comando para a serial
	Local cEndereco := ALLTRIM(str(nEndereco))
	Local cBico  	:= ALLTRIM(str(nBico))
	Local cValor  	:= str(nValor)
	Local nTipoTrat := 2

	//Prepara os parametros de envio
	oParams := ::PrepParam({APET, "PreDeterminacao", cEndereco, cBico, cValor, cStrAbast})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    ::TratarRet(cRetorno, nTipoTrat, "PreDeterminacao")
                             
Return cRetorno     

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �TratarRet	       �Autor  �Vendas Clientes     � Data �  01/06/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o retorno da TotvsApi.dll/so				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 		                                          		 	 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRetorno) - Retorno do comando enviado.   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �cRetorno														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method TratarRet(cRetorno, nTipoTrat, cNomeFunc) Class Ionics
   
	Local cMsg 		:= "Erro ao executar " + cNomeFunc + " verifique o arquivo de log do concentrador."   
	Local cMensagem := "" 
	Local cErro 	:= ""
	Local cBico		:= ""
	
	Do Case
		
		Case nTipoTrat == 1	
		//0 Normal
		//1 In�cio de Abastecimento
		//2 Fim do Abastecimento
		//3 Estado de Erro
		//4 Bomba Bloqueada
		//5 Sem Abastecimentos
		//6 Mensagem da Automa��o.
		    
			cErro := substr(cRetorno, 1, 1)
			cBico := substr(cRetorno, 3, 1)  
			
			IF cErro == "4"
				MsgStop("Bomba bloqueada")    
			ElseIF (cErro == "3")      
				MsgStop("ERRO ao ler o abastecimento. Bico:  " + cBico)
			ElseIF (cErro == "6")  
				cMensagem := ::LeMensagem()
				MsgStop(cMensagem)
			EndIF	
		
		Case nTipoTrat == 2  
		
			IF cRetorno == "F"
				
				MsgStop(cMsg)    
			
			EndIF
		
		Case nTipoTrat == 3 
		
			IF cRetorno == "0"
				
				MsgStop(cMsg)    
			
			EndIF
	EndCase

Return  .T.                                                                                     


    