#INCLUDE "MSOBJECT.CH"

Function LOJA2103 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJAAdapXML        �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata responsavel em manter os dados comuns dos adapters  ���
���			 �Nao pode ser instanciada						 	  				  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJAAdapXML From LJAIntegracao
	
	Data oGeraXml										//Objeto do tipo LJAGeraXml
	Data oXmls											//Objeto do tipo LJCDadosXML
	Data oEAI											//Objeto do tipo LJCEAI
	Data cDocType										//Tipo de transacao - 1 (Sincrona) ou 2 (Assincrona) 
	Data cFuncCode										//Funcao (GlobalDocumentFunctionCode)
	Data cFuncDesc										//Descricao da funcao (GlobalDocumentFunctionDescription)
    
    Data cVersao										// Versao do Adapter 					(LayOut)
    Data cIdentific										// Identicacao da transacao do adapter 	(LayOut)
    Data cFuncao										// Funcao da transacao do adapter      	(LayOut)

	Method New()					                   				//Metodo construtor
	Method GuardarXml(cXml, cTabela, cVersao, cIdentific, cFuncao)	//Guarda os XMLs gerados no objeto oXmls
	Method EnviarEai()												//Envia os Xmls para o EAI
	Method GerarXml(oCampos)										//Gera o XML da entidade
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAAdapXML.			                  ���
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
Method New() Class LJAAdapXML
    
	//Executa o metodo construtor da classe pai
	_Super:New()
    
	//Instancia o objeto LJCDadosXML
	::oXmls := LJCDadosXML():New()
	
	//Instancia o objeto LJCEAI	
	::oEAI := LJCEAI():New()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GuardarXml�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em guardar os XMLs gerados               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML Gerado.	    				  	  ���
���			 �ExpC2 (2 - cTabela) - Nome da tabela.						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GuardarXml(cXml, cTabela, cVersao, cIdentific, cFuncao) Class LJAAdapXML
	
	Local oDadoXml  := Nil					//Objeto do tipo LJCDadoXML
	
	//Instancia o objeto LJCDadoXML
	oDadoXml := LJCDadoXML():New(cXml, cTabela, cVersao, cIdentific, cFuncao)
                
	//Adiciona o objeto na colecao			
	::oXmls:ADD(oDadoXml)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EnviarEai �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em enviar os XMLs para o EAI             ���
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
Method EnviarEai() Class LJAAdapXML
	
	Local lRetorno 	 	:= .T.					//Retorno do metodo
	Local nCount    	:= 0
	
	If ::oXmls:Count() > 0
	
		Conout('LOJA2103 - INICIO (' + Time() + ') : Enviando mensagem para EAI...')
				
		Conout('LOJA2103 - (' + Time() + ') Enviando mensagem para EAI..1')
									 			
		::oEAI:cSetDocType        	:= ::cDocType
		::oEAI:cSetFuncCode        	:= ::cFuncCode  
		::oEAI:cSetFuncDescription  := RemoveAcento(::cFuncDesc)
		
		Conout('LOJA2103 - (' + Time() + ') Enviando mensagem para EAI..2')
		    
	    //Guarda informacoes do cabecario
		::oEAI:InfCab()
		
		Conout('LOJA2103 - (' + Time() + ') Enviando mensagem para EAI..3')
		    
	    //Envia transacao uma a uma em quanto existir xml guardado
		For nCount := 1 To ::oXmls:Count()        
		
		Conout('LOJA2103 - (' + Time() + ') Enviando mensagem para EAI..4')
		
			::oEAI:Transacao(	::oXmls:Elements(nCount):cIdentific, 	;
								::oXmls:Elements(nCount):cVersao, 		;
								::oXmls:Elements(nCount):cFuncao,		;
								::oXmls:Elements(nCount):cXml)
		Next	
		
		Conout('LOJA2103 - (' + Time() + ') Enviando mensagem para EAI..5')
		
		//Salva transacao
		lRetorno := ::oEAI:Save()
	    
		Conout('LOJA2103 - FIM (' + Time() + ') : Enviando mensagem para EAI...')
	
	EndIf

Return lRetorno												

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GerarXml  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gerar o XML.				  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpCO (1 - oCampos) - Campos adicionais. LJCCampos    	  ���											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GerarXml( oCampos ) Class LJAAdapXML
    
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local nCount	:= 0					//Variavel contador
	
	DEFAULT oCampos := Nil
		
	//Gera XML
	For nCount := 1 To ::oDadosInt:Count()

		//Verifica se o XML ja foi gerado
		If !::oDadosInt:Elements(nCount):lXml 
	
			lRetorno := ::oGeraXml:Gerar(::oDadosInt:Elements(nCount), oCampos)
	
			If lRetorno
			    //Indica que o XML ja foi gerado
			    ::oDadosInt:Elements(nCount):lXml := .T.
			    
			    //Guarda o XML gerado
				::GuardarXml(::oGeraXml:cXml, ::oDadosInt:Elements(nCount):cTabela, ::cVersao, ::cIdentific, ::cFuncao)
			Else
				//Tratar erro	
			EndIf
		
		EndIf
		
	Next		

Return lRetorno									

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Function � RemoveAcento �Autor  �Vendas Clientes  � Data �  13/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove os acentos e caracteres especiais das string		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�1 - cString - String a ser convertida				    	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
Static Function RemoveAcento(cString)
Local nX        := 0 
Local nY        := 0 
Local cSubStr   := ""
Local cRetorno  := ""

Local cStrEsp	:= "����������������������"
Local cStrEqu   := "AAAAaaaaOOOoooCcEEeerUu" //char equivalente ao char especial

For nX:= 1 To Len(cString)
	cSubStr := SubStr(cString,nX,1)
	nY := At(cSubStr,cStrEsp)
	If nY > 0 
		cSubStr := SubStr(cStrEqu,nY,1)
	EndIf
    
	cRetorno += cSubStr
Next nX

Return cRetorno								