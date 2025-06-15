#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1216 ; Return  // "dummy" function - Internal Use 

/* 
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������         
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCImporta         �Autor  �Vendas Clientes     � Data �  23/04/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em importar os dados da integracao 			   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/   
Class LJCImporta
                   
	Data aTransacoes								//Array com as transacoes
	Data cFil										//Codigo da filial
		
	Method New(cFil, lTraduzir)						//Metodo construtor
	Method Executar()        						//Executa a importacao dos dados 
	Method Ler()                                   	//Le os dados da tabela
	Method Traduzir()                            	//Traduz os campos
	Method Atualizar()                       		//Atualiza os dados

EndClass             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCImporta.			                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cFil) - Codigo da filial.			  			  ���
���			 �ExpL1 (2 - lTraduzir) - Identifica se tem tradutor.		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New(cFil, lTraduzir) Class LJCImporta

	Default cFil 		:= ""
    Default lTraduzir 	:= .F.

	::cFil := cFil

	::Executar(lTraduzir)
	
Return Self

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �InserirTabela   �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Executa a importacao dos dados    							    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�ExpL1 (2 - lTraduzir) - Identifica se tem tradutor.		  	    ���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method Executar(lTraduzir) Class LJCImporta
    
	Local oLeitura		:= Nil							//Objeto do tipo LJCLeitura 
	Local oTraduzir		:= Nil                        	//Objeto do tipo LJCTraduzir
	Local lcontinuar 	:= .T.							//Variavel de controle do while	
	Local lLjPackTB		:= FindFunction("LjPackTB")		//indica se a Function LJPACKTB (LOJXFUNH.PRW) esta compilada

	While lcontinuar

		oLeitura := ::Ler()

		If oLeitura:TemDados()

			If lTraduzir
				oTraduzir := ::Traduzir(oLeitura)
				::Atualizar(oTraduzir)
			Else
				::Atualizar(oLeitura)
			EndIf
		Else
			lcontinuar := .F.
		EndIf

		#IFDEF TOP 
			dbSelectArea("TMP")
			dbCloseArea()
		#ELSE           
			dbSelectArea("MD8")
			dbCloseArea()
		#ENDIF
	End
	
	//deletamos fisicamente os registros da MD8, j� que ap�s os dados irem para a tabela de destino, n�o � necess�rio manter o hist�rico
	If lLjPackTB
		conout("Executando o PACK na tabela MD8")
		LJPACKTB('MD8')
	Else
		conout("Por favor, atualize o fonte LOJXFUNH.PRW")
	EndIf

Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Ler             �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Le os dados da tabela			    							    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �Objeto 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method Ler() Class LJCImporta

	Local oLeitura										//Objeto do tipo LJCLeitura 										    

	//Efetua a leitura da tabela e transforma em objeto de transacao	
	oLeitura := LJCLeitura():new(::cFil)                                 

Return oLeitura

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Traduzir        �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Faz a traducao dos campos		    							    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �Objeto 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	
Method Traduzir(oLeitura) Class LJCImporta

	Local oTraduzir										//Objeto do tipo LJCTraduzir                

	oTraduzir := LJCTraduzir():new( oLeitura:getTransacoes() )

Return oTraduzir

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Traduzir        �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Atualiza os dados     		    							    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																	���
�������������������������������������������������������������������������������͹��
���Retorno   �Logico 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/		
Method Atualizar(oDadosTrn) Class LJCImporta

	Local nConta		:= 0						//Variavell auxiliar contador
	Local lRetorno		:= .T.                   	//Retorno do metodo
	Local aTransacoes   := Nil                     	//Transacoes retornadas

	aTransacoes := oDadosTrn:GetTransacoes()

	For nConta = 1 To Len(aTransacoes)
		
		If !aTransacoes[nConta]:Executar()
			lRetorno := .F.
			Exit
		EndIf
	
	Next nConta

Return lRetorno
