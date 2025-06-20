#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

#DEFINE _VERSAO "1.0"

Function LOJA2158 ; Return  // "dummy" function - Internal Use 
                      
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXmlEnvSM0  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em prepara o XML de envio da entidade SM0        ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXmlEnvSM0 From LJAAdapXML       
                        
	Data oCampos

	Method New()					                   	// Metodo construtor
	Method Gerar()		    							// Metodo que ira processar os dados da integracao SA1
	Method Finalizar()				    				// Finaliza a integracao enviando o XML para o EAI
	Method GerarXml()									// Gera o XML da entidade SA1
	Method CamposXML()									// Cria a array com os campos que n�o s�o usados mas devem ser adicionados
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXmlEnvSM0.	                  ���
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
Method New() Class LJCAdapXmlEnvSM0
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::cProcesso		:= _EMPRESASFILIAIS
	::cDocType     	:= _ASSINCRONA
	::cFuncCode    	:= "EMPRESASFILIAIS"
	::cFuncDesc    	:= "Empresas e filiais"
	::cVersao		:= _VERSAO
	::cIdentific   	:= "0000000001"
    ::cFuncao 		:= ""

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar a integracao SM0.				  ���
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
Method Gerar() Class LJCAdapXmlEnvSM0

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
Method Finalizar()  Class LJCAdapXmlEnvSM0
	
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
���Desc.     �Responsavel em gerar o XML da entidade SM0.				  ���
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
Method GerarXml() Class LJCAdapXmlEnvSM0

	Local lRetorno 	:= .T.					//Retorno do metodo
		
	// Instanciar o objeto LJCGeraXmlSA1
	Self:oGeraXml := LJCGeraXmlSM0():New()
	
	// Carrega os campos do SM0
	Self:CamposXML()
	
	// Chama o metodo da classe pai
	lRetorno := _Super:GerarXml( Self:oCampos )
	
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
Method CamposXML() Class LJCAdapXMLEnvSM0
	Local oLJCEntidadeFactory	:= Nil					// Criador do objeto que representa a entidade
	Local oEntSM0 				:= Nil					// Objeto do tipo LJCEntMovBancario
	Local oDadosCampo			:= Nil					// Objeto do tipo LJCDadosCampo
	
	 oLJCEntidadeFactory := LJCEntidadeFactory():New()
	 oEntSM0 := oLJCEntidadeFactory:Create( "SM0" )
	
	If oEntSM0:Campos():Count() > 0 
	
		Self:oCampos := LJCList():New()    
		
		oDadosCampo := LJCDadosCampo():New()
		oDadosCampo:cNome		:= "M0_CODIGO"
		oDadosCampo:cTipo		:= ValType(SM0->M0_CODIGO)
		oDadosCampo:nTamanho	:= Len(SM0->M0_CODIGO)
		oDadosCampo:nCasasDec	:= 0
		oDadosCampo:cFormato	:= ""
		oDadosCampo:cOrdem		:= 1
		oDadosCampo:cTitulo		:= ""
		oDadosCampo:cDescricao	:= ""	
		Self:oCampos:Add( oDadosCampo )
	
		oDadosCampo := LJCDadosCampo():New()
		oDadosCampo:cNome		:= "M0_CODFIL"
		oDadosCampo:cTipo		:= ValType(SM0->M0_CODFIL)
		oDadosCampo:nTamanho	:= Len(SM0->M0_CODFIL)
		oDadosCampo:nCasasDec	:= 0
		oDadosCampo:cFormato	:= ""
		oDadosCampo:cOrdem		:= 1
		oDadosCampo:cTitulo		:= ""
		oDadosCampo:cDescricao	:= ""
		Self:oCampos:Add( oDadosCampo )   
		          
		oDadosCampo := LJCDadosCampo():New()
		oDadosCampo:cNome		:= "M0_FILIAL"
		oDadosCampo:cTipo		:= ValType(SM0->M0_FILIAL)
		oDadosCampo:nTamanho	:= Len(SM0->M0_FILIAL)
		oDadosCampo:nCasasDec	:= 0
		oDadosCampo:cFormato	:= ""
		oDadosCampo:cOrdem		:= 1
		oDadosCampo:cTitulo		:= ""
		oDadosCampo:cDescricao	:= ""	
		Self:oCampos:Add( oDadosCampo )     

		oDadosCampo := LJCDadosCampo():New()
		oDadosCampo:cNome		:= "M0_NOME"
		oDadosCampo:cTipo		:= ValType(SM0->M0_NOME)
		oDadosCampo:nTamanho	:= Len(SM0->M0_NOME)
		oDadosCampo:nCasasDec	:= 0
		oDadosCampo:cFormato	:= ""
		oDadosCampo:cOrdem		:= 1
		oDadosCampo:cTitulo		:= ""
		oDadosCampo:cDescricao	:= ""	
		Self:oCampos:Add( oDadosCampo )   		
		
	EndIf

Return Nil								