#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

/*#DEFINE _INCLUSAO		 		"3"		//Inclusao
#DEFINE _ALTERACAO				"4"  	//Alteracao
#DEFINE _EXCLUSAO				"5"  	//Exclusao

#DEFINE _DELIMIT "_"*/

Function LOJA2133 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXmlRecSE1  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em processar o XML de recebimento da entidade SE1���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXmlRecSE1 From LJAAdapXMLRec
    
	Data oCamposSE1										//Estrutura do dicionario SE1
	Data aEnvio											//Array a ser enviado para a rotina automatica

	Method New()					                   	//Metodo construtor
	Method Processar(cXml)    							//Metodo que ira processar os dados da integracao SE1
	
	//Metodos internos
	Method LerDic()										//Le o dicionario
	Method PrepDados()									//Prepara os dados para serem enviados
	Method EnvDados()									//Envia os dados para rotina automatica
	Method ConsistDad()									//Consiste os dados recebidos
	Method FormatCamp(cCampo, cValor)					//Formata o campo
	Method ValDefault()									//Seta os valores default
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXmlRecSE1.	                  ���
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
Method New() Class LJCAdapXmlRecSE1
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::oCamposSE1 	:= NIL
	::aEnvio		:= {}
	
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
Method Processar(cXml) Class LJCAdapXmlRecSE1

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
Method LerDic() Class LJCAdapXmlRecSE1
	
	::oCamposSE1 := LJCCampos():New("SE1")
	
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
Method PrepDados() Class LJCAdapXmlRecSE1
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local cNode		:= ""					//String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					//Descricao do campo
	Local oRetorno	:= NIL					//Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					//Valor da tag
	Local nCount	:= 0 					//Variavel auxiliar contador
	
	Private oNode	:= Nil					//Usado para execucao da macro
	
	oNode := ::oEstruXml
	
	//Verifica se os campos do XML existem no dicionario		
	For nCount := 1 to ::oCamposSE1:Count()
	    
	    //Nome do campo
		cCampo := ::oCamposSE1:Elements(nCount):cNome
		
		//Verifica se o campo existe no XML
		oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1, _DELIMIT + cCampo)
		
		//Trata retorno		
		If oRetorno <> Nil
			//String para ser executada via macro
			cNode := "oNode:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
			
			//Pega o conteudo da tag via macro
		    cValor := &cNode
		    
		    //Converte o campo
			::ConverCamp(cCampo, @cValor, ::oCamposSE1)
		    
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
Method EnvDados() Class LJCAdapXmlRecSE1
    
	Local lRetorno 	:= .F.					//Retorno do metodo

    Private lMsErroAuto := .F.				//Cria a variavel do retorno da rotina automatica
    Private lAutoErrNoFile := .T.			//Habilita a gravacao do erro da rotina automatica
    
	//Executa a rotina automatica
	Fina040(::aEnvio, Val(::cOperacao))
	
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
Method ConsistDad() Class LJCAdapXmlRecSE1
	
	Local lRetorno 	:= .T.							//Retorno do metodo
		
	//Verifica o tipo de operacao a se executada
	::cOperacao := ::oEstruXml:_FORMMODEL_CONTASARECEBER:_OPERATION:TEXT
	
	//Formata os campos no devido tamanho
	::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:_E1_PREFIXO:_VALUE:TEXT := ::FormatCamp("E1_PREFIXO", ::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:_E1_PREFIXO:_VALUE:TEXT)
	::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:_E1_NUM:_VALUE:TEXT := ::FormatCamp("E1_NUM", ::oEstruXml:_FORMMODEL_CONTASARECEBER:_FORMMODEL_SE1:_E1_NUM:_VALUE:TEXT)
				
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
Method FormatCamp(cCampo, cValor) Class LJCAdapXmlRecSE1
	
	Local oRetorno := Nil					//Retorno do metodo
		
	Do Case

		Case cCampo = "E1_PREFIXO" .OR. cCampo = "E1_NUM"
		
			oRetorno := PadR(cValor, ::oCamposSE1:ElementKey(cCampo):nTamanho , " ") 
		
	End Case
	
Return oRetorno

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
Method ValDefault() Class LJCAdapXmlRecSE1
	
    Local lRetorno 	:= .T.   					//Retorno do metodo
	/*Local cParcela 	:= ""						//Parcela a gerar
	Local cPrefixo	:= ""						//E1_PREFIXO
	Local cNumero	:= ""						//E1_NUM
	Local aArea 	:= {}						//Guarda a area do SE1
	Local cNaturez	:= ""						//Natureza
	
	aArea := SE1->(GetArea())
	
	cPrefixo 	:= ::oEstruXml:_FORMMODEL_SE1:_CONTASARECEBER_SE1:_E1_PREFIXO:_VALUE:TEXT
	cNumero 	:= ::oEstruXml:_FORMMODEL_SE1:_CONTASARECEBER_SE1:_E1_NUM:_VALUE:TEXT
	
	cParcela 	:= SuperGetMV("MV_1DUP")
	cNaturez	:= &(SuperGetMV("MV_NATNCC"))
		
	DbSelectArea("SE1")
	
	DbSetOrder(1)
	
	While SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + "NCC"))
		cParcela := CHR(ASC(cParcela)+1)
	End
	
	AADD(::aEnvio, {"E1_PARCELA", cParcela, NIL})	
	AADD(::aEnvio, {"E1_NATUREZ", cNaturez, NIL})	
	AADD(::aEnvio, {"E1_SITUACA", "0", NIL})	
	AADD(::aEnvio, {"E1_ORIGEM", "INTEGRACAO", NIL})	
	AADD(::aEnvio, {"E1_MULTNAT", "2", NIL})	
	AADD(::aEnvio, {"E1_FLUXO", "N", NIL})	
	
	RestArea(aArea)
	
	//AADD(::aEnvio, {"E1_MOEDA", "", NIL})				
	//aAdd(aVetor,{"E1_PORTADO" 	,cL1Oper											,Nil})
	//aAdd(aVetor,{"E1_AGEDEP" 	,"."												,Nil})
	

		If cPaisLoc <> "BRA"
			DbSelectArea("SA6")
			DbSetOrder(1)
			If DbSeek( xFilial("SA6") + cL1Oper + "." + "NCC" )
				aAdd(aVetor,{"E1_MOEDA"		,Max(SA6->A6_MOEDA,1)						,Nil })
			Else
				aAdd(aVetor,{"E1_MOEDA"		,1											,Nil })
			EndIf
 			Else
			aAdd(aVetor,{"E1_MOEDA"		,1												,Nil })
		EndIf

		aAdd(aVetor,{"E1_BASCOM1"		,xMoeda(nValorGer,1,1,aNCCItens[nContaNCC][4])	,Nil }) */
    	
Return lRetorno