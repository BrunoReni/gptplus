#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

#DEFINE _VERSAO "1.0"

Function LOJA2124 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXMLEnvSE5  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em prepara o XML de envio da entidade SA3        ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXMLEnvSE5 From LJAAdapXML
	   		
	Data oCampos										//Objeto do tipo LJCCampos
	
	Method New()					                   	//Metodo construtor
	Method Gerar()	    								//Metodo que ira processar os dados da integracao SE5
	Method Finalizar()				    				//Finaliza a integracao enviando o XML para o EAI
	
	//Metodos internos
	Method GerarXml()									//Gera o XML da entidade SE5
	Method CamposXML()									//Sao os campos nao usados que precisam compor o XML
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXMLEnvSE5.	                  ���
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
Method New() Class LJCAdapXMLEnvSE5
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::cProcesso		:= _MOVIMENTOBANCARIO
	
	::cDocType     	:= _ASSINCRONA
	::cFuncCode    	:= "MOVIMENTOBANCARIO"
	::cFuncDesc    	:= "Movimentacao Bancaria"
	
	::cVersao		:= _VERSAO
	::cIdentific   	:= "0000000001"
    ::cFuncao 		:= "LJADPSE5"
	
	::oCampos		:= Nil
		
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar a integracao SE5.				  ���
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
Method Gerar() Class LJCAdapXMLEnvSE5

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
Method Finalizar()  Class LJCAdapXMLEnvSE5
	
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
���Desc.     �Responsavel em gerar o XML da entidade SE5.				  ���
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
Method GerarXml() Class LJCAdapXMLEnvSE5

	Local lRetorno 	:= .T.					//Retorno do metodo
	
	//Sao os campos nao usados que precisam compor o XML
    ::CamposXML()
    	
	//Instanciar o objeto LJCGeraXmlSE5
	::oGeraXml := LJCGeraXmlSE5():New()
	
	//Chama o metodo da classe pai
	lRetorno := _Super:GerarXml(::oCampos)

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CamposXML �Autor  �Vendas Clientes     � Data �  15/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Sao os campos nao usados que precisam compor o XML		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CamposXML() Class LJCAdapXMLEnvSE5

	Local oEntSE5 	:= Nil					//Objeto do tipo LJCEntMovBancario
	Local oCampo	:= Nil					//Objeto do tipo LJCDadosCampo
	
	oEntSE5 := LJCEntMovBancario():New("SE5")
	
	If oEntSE5:Campos():Count() > 0 
	
		::oCampos := LJCList():New()    
	
		oCampo := oEntSE5:Campos():ElementKey("E5_FILIAL")
		::oCampos:ADD(oCampo)
	
		oCampo := oEntSE5:Campos():ElementKey("E5_NUMERO")
		::oCampos:ADD(oCampo)
		
		oCampo := oEntSE5:Campos():ElementKey("E5_TIPO")
		::oCampos:ADD(oCampo)
	
	EndIf

Return Nil