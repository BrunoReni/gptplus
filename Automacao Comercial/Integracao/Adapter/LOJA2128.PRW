#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

#DEFINE _VERSAO "1.0"

Function LOJA2128 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXMLEnvVenda�Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em prepara o XML de envio da venda.			  ���
���		     �SF2, SD2, SE1, SE5, SEF											  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXMLEnvVenda From LJAAdapXML
	   		
	Method New()					                   	//Metodo construtor
	Method Gerar()		    							//Metodo que ira processar os dados da integracao SF2
	Method Finalizar()				    				//Finaliza a integracao enviando o XML para o EAI
	
	//Metodos internos
	Method GerarXml()									//Gera o XML da entidade SF2
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCADAPXMLENVSF2.	                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCAdapXMLEnvVenda
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::cProcesso		:= _CUPOMFISCAL
	
	::cDocType     	:= _ASSINCRONA
	::cFuncCode    	:= "CUPOMFISCAL"
	::cFuncDesc    	:= "Cupom Fiscal"
	
	::cVersao		:= _VERSAO
	::cIdentific   	:= "0000000001"
    ::cFuncao 		:= "LJADPVEN"
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar a integracao SF2.				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar() Class LJCAdapXMLEnvVenda

	Local lRetorno 	:= .T.					//Retorno do metodo
    
    If ::Integrar()
    
	    //Gerar o XML de envio
	    lRetorno := ::GerarXml()
	    
    EndIf
    
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Finalizar �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Finaliza a integracao enviando o XML para o EAI.			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Finalizar()  Class LJCAdapXMLEnvVenda
	
	Local lRetorno 	:= .T.					//Retorno do metodo
    
    //Enviar o XML gerado para o EAI
   	lRetorno := ::EnviarEAI()
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GerarXml  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gerar o XML da entidade SF2.				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GerarXml() Class LJCAdapXMLEnvVenda

	Local lRetorno 	:= .T.					//Retorno do metodo
	Local nCount	:= 0					//Variavel contador
	Local oAdapter	:= Nil					//Objeto do tipo LJAAdapXml
	Local nCountXML	:= 0					//Contador dos xml's gerados
	
	//Gera XML de cada adapter
	For nCount := 1 To ::oDadosInt:Count()
	    
		//Verifica se o XML ja foi gerado
		If !::oDadosInt:Elements(nCount):lXml
	
			Do Case
				
				Case ::oDadosInt:Elements(nCount):cTabela = "SF2"			
					//Instancia o objeto LJCAdapXmlEnvSF2
		      		oAdapter := LJCAdapXmlEnvSF2():New()
		      		
				Case ::oDadosInt:Elements(nCount):cTabela = "SE1"			
					//Instancia o objeto LJCAdapXmlEnvSE1
					oAdapter := LJCAdapXmlEnvSE1():New()
					
				Case ::oDadosInt:Elements(nCount):cTabela = "SE5"			
					//Instancia o objeto LJCAdapXmlEnvSE5
					oAdapter := LJCAdapXmlEnvSE5():New()
								
				Case ::oDadosInt:Elements(nCount):cTabela = "SEF"			
					//Instancia o objeto LJCAdapXmlEnvSEF
					oAdapter := LJCAdapXmlEnvSEF():New()
				
				Case ::oDadosInt:Elements(nCount):cTabela = "SLX"			
					//Instancia o objeto LJCAdapXmlEnvSLX
					oAdapter := LJCAdapXmlEnvSLX():New()					
		
			End Case
			
			//Adiciona os dados da integracao para geracao do XML
	   		oAdapter:Inserir(	::oDadosInt:Elements(nCount):cTabela, ;
	   							::oDadosInt:Elements(nCount):cChave, ;
	   							::oDadosInt:Elements(nCount):cIndice, ;
	   							::oDadosInt:Elements(nCount):cTipo)
		    
		    //Gera o XML  		
		    If oAdapter:GerarXml()
				
				//Indica que o XML ja foi gerado
      			::oDadosInt:Elements(nCount):lXml := .T.
				
				For nCountXML := 1 To oAdapter:oXmls:Count()
	      			//Guarda XML
	      			::GuardarXml(	oAdapter:oXmls:Elements(nCountXML):cXml, ;
	      				           	oAdapter:oXmls:Elements(nCountXML):cTabela, ;
	      				           	oAdapter:oXmls:Elements(nCountXML):cVersao, ;
	      				           	oAdapter:oXmls:Elements(nCountXML):cIdentific, ;
	      				           	oAdapter:oXmls:Elements(nCountXML):cFuncao)
	 			Next
	       	EndIf
	    
	    EndIf
	Next			
	
Return lRetorno									