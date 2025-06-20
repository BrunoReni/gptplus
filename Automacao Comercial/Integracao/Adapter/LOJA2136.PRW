#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

/*#DEFINE _INCLUSAO		 		"3"		//Inclusao
#DEFINE _ALTERACAO				"4"  	//Alteracao
#DEFINE _EXCLUSAO				"5"  	//Exclusao

#DEFINE _DELIMIT "_"*/

Function LOJA2136; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXmlRecSBM  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em processar o XML de recebimento da entidade SBM���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXmlRecSBM From LJAAdapXMLRec
    
	Data oCamposSBM										//Estrutura do dicionario SBM
	Data aEnvio											//Array a ser enviado para a rotina automatica
	
	Method New()					                   	//Metodo construtor
	Method Processar(cXml)    							//Metodo que ira processar os dados da integracao SBM
	
	//Metodos internos
	Method LerDic()										//Le o dicionario
	Method PrepDados()									//Prepara os dados para serem enviados
	Method ConsistDad()									//Consiste os dados recebidos
	Method EnvDados()									//Envia os dados para rotina automatica
	Method FormatCamp(cCampo, cValor)					//Formata o campo
		
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXmlRecSBM.	                  ���
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
Method New() Class LJCAdapXmlRecSBM
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::oCamposSBM 	:= NIL
	::aEnvio		:= {}
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Processar �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar o XML SBM.				  		  ���
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
Method Processar(cXml) Class LJCAdapXmlRecSBM

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
    	//Envia dados para rotina automatica
    	lRetorno := ::EnvDados()
    EndIf
	            
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �LerDic    �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel ler a estrutura do dicionario.		  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LerDic() Class LJCAdapXmlRecSBM
	
	::oCamposSBM := LJCCampos():New("SBM")
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PrepDados �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel preparar os dados para serem enviados.		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PrepDados() Class LJCAdapXmlRecSBM
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local cNode		:= ""					//String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					//Descricao do campo
	Local oRetorno	:= NIL					//Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					//Valor da tag
	Local nCount	:= 0 					//Variavel auxiliar contador
	
	Private oNode	:= Nil					//Usado para execucao da macro
	
	oNode := ::oEstruXml
	
	//Verifica se os campos do XML existem no dicionario		
	For nCount := 1 to ::oCamposSBM:Count()
	    
	    //Nome do campo
		cCampo := ::oCamposSBM:Elements(nCount):cNome
		
		//Verifica se o campo existe no XML
		oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_SBM:_GRUPOPRODUTO_SBM, _DELIMIT + cCampo)
		
		//Trata retorno		
		If oRetorno <> Nil
			//String para ser executada via macro
			cNode := "oNode:_FORMMODEL_SBM:_GRUPOPRODUTO_SBM:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
			
			//Pega o conteudo da tag via macro
		    cValor := &cNode
		    
		    //Converte o campo
			::ConverCamp(cCampo, @cValor, ::oCamposSBM)
		    
		    //Adiciona os dados no array de envio
		    AADD(::aEnvio, {cCampo, cValor, NIL})
		EndIf
	Next 
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EnvDados  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel enviar os dados para rotina automatica.		  ���
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
Method EnvDados() Class LJCAdapXmlRecSBM
    
	Local lRetorno 	:= .F.					//Retorno do metodo

    Private lMsErroAuto := .F.				//Cria a variavel do retorno da rotina automatica
    Private lAutoErrNoFile := .T.			//Habilita a gravacao do erro da rotina automatica
    
	//Executa a rotina automatica
	Mata035(::aEnvio, Val(::cOperacao))
	
	If lMsErroAuto
		//Busca o erro da rotina automatica
		::cError := ::ErroRotAut()
	Else
		lRetorno := .T.
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConsistDad�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel fazer a consistencia dos dados recebidos.		  ���
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
Method ConsistDad() Class LJCAdapXmlRecSBM
	
	Local lRetorno 	:= .T.							//Retorno do metodo
		
	//Verifica o tipo de operacao a se executada
	::cOperacao := ::oEstruXml:_FORMMODEL_SBM:_OPERATION:TEXT
	
	//Formata os campos BM_GRUPO no devido tamanho
	::oEstruXml:_FORMMODEL_SBM:_GRUPOPRODUTO_SBM:_BM_GRUPO:_VALUE:TEXT := ::FormatCamp("BM_GRUPO", ::oEstruXml:_FORMMODEL_SBM:_GRUPOPRODUTO_SBM:_BM_GRUPO:_VALUE:TEXT)
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �FormatCamp�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em formatar o campo.							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cCampo) - Campo a ser formatado.			  	  ���
���			 �ExpC2 (2 - cValor) - Valor a ser formatado.			  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Variant									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FormatCamp(cCampo, cValor) Class LJCAdapXmlRecSBM
	
	Local oRetorno := Nil					//Retorno do metodo
		
	Do Case

		Case cCampo = "BM_GRUPO"
		
			oRetorno := PadR(cValor, ::oCamposSBM:ElementKey(cCampo):nTamanho , " ") 
		
	End Case
	
Return oRetorno