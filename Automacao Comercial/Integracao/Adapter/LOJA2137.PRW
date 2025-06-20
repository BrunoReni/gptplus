#INCLUDE "MSOBJECT.CH"
//#INCLUDE "DEFINTEGRA.CH"

Function LOJA2137 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXmlRecNCC  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em processar o XML de recebimento da entidade SA1���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXmlRecNCC From LJCAdapXmlRecSE1
    
	Method New()					                   	//Metodo construtor
	Method Processar(cXml)    							//Metodo que ira processar os dados da integracao SE1
	
	//Metodos internos
	Method ValDefault()									//Seta os valores default
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXmlRecNCC.	                  ���
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
Method New() Class LJCAdapXmlRecNCC
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Processar �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar o XML SE1.				  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXml) - XML recebido.	    				  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Processar(cXml) Class LJCAdapXmlRecNCC

	Local lRetorno 	:= .T.					//Retorno do metodo
    
    ::cXml := cXml
    
    //Le o dicionario
    ::LerDic()
    
    //Carrega a estrutura do xml recebido
    lRetorno := ::LerXml()
    
    If lRetorno
		//Consistir dados
    	lRetorno := ::ConsistDad()    	
    EndIf
    
    If lRetorno 
    	//Prepara dados para envio
    	lRetorno := ::PrepDados()
    EndIf
    
    If lRetorno
		//Seta os valores default
    	lRetorno := ::ValDefault()    	
    EndIf
    
    If lRetorno 
    	//Envia dados para rotina automatica
    	lRetorno := ::EnvDados()
    EndIf
	            
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValDefault�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em atribuir os valores default    			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValDefault() Class LJCAdapXmlRecNCC
	
	Local lRetorno 	:= .T.   					//Retorno do metodo
	Local cParcela 	:= ""						//Parcela a gerar
	Local cPrefixo	:= ""						//E1_PREFIXO
	Local cNumero	:= ""						//E1_NUM
	Local aArea 	:= {}						//Guarda a area do SE1
	Local cNaturez	:= ""						//Natureza
	
	aArea := SE1->(GetArea())
	
	cPrefixo 	:= ::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:_E1_PREFIXO:_VALUE:TEXT
	cNumero 	:= ::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:_E1_NUM:_VALUE:TEXT
	
	//cParcela 	:= SuperGetMV("MV_1DUP")
	cNaturez	:= &(SuperGetMV("MV_NATNCC"))
	
	//Verifica se existe o Node PARCELA
	If ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1, "_E1_PARCELA") == NIL 
		
		DbSelectArea("SE1")
	
		DbSetOrder(1)
	
		While SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + "NCC"))
			cParcela := CHR(ASC(cParcela)+1)
		End
	
		AADD(::aEnvio, {"E1_PARCELA", cParcela, NIL})	
	EndIf
	
	AADD(::aEnvio, {"E1_NATUREZ", cNaturez, NIL})	
	AADD(::aEnvio, {"E1_SITUACA", "0", NIL})	
	AADD(::aEnvio, {"E1_ORIGEM", "INTEGRACAO", NIL})	
	AADD(::aEnvio, {"E1_MULTNAT", "2", NIL})	
	AADD(::aEnvio, {"E1_FLUXO", "N", NIL})	
	
	RestArea(aArea)
		
Return lRetorno