#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"
#INCLUDE "LOJA2132.CH"


Function LOJA2132 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAdapXmlRecSA1  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em processar o XML de recebimento da entidade SA1���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCAdapXmlRecSA1 From LJAAdapXMLRec
    
	Data oCamposSa1										//Estrutura do dicionario SA1
	Data lSoIncluir										//Indica que eh somente para incluir o cliente n�o precisando replicar a mensagem para quem originou.    
	Data aEnvio											//Array a ser enviado para a rotina automatica
	
	Method New()					                   	//Metodo construtor
	Method Processar(cXml)    							//Metodo que ira processar os dados da integracao SA1
	Method Destrutor()									//Limpa os objetos que foram criados
	
	//Metodos internos
	Method LerDic()										//Le o dicionario
	Method PrepDados()									//Prepara os dados para serem enviados
	Method EnvDados()									//Envia os dados para rotina automatica
	Method ConsistDad()									//Consiste os dados recebidos
	Method GerarA1COD(cCGCCPF)							//Gera A1_COD a partir do CGCCPF
	Method FormatCamp(cCampo, cValor)					//Formata o campo
	Method ExisteSA1()									//Verifica se o cliente ja existe na base de dados
	Method ValDefault()									//Seta os valores default
	Method ReplInfo()									//Replica o cliente para a origem como alteracao			
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAdapXmlRecSA1.	                  ���
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
Method New() Class LJCAdapXmlRecSA1
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::oCamposSa1 	:= NIL
	::lSoIncluir 	:= .F.
	::aEnvio		:= {}
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Processar �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar o XML SA1.				  		  ���
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
Method Processar(cXml) Class LJCAdapXmlRecSA1

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
	
	Self:Destrutor()
	//Replica o cliente para a origem
	//::ReplInfo()
	            
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
Method LerDic() Class LJCAdapXmlRecSA1
	
	::oCamposSa1 := LJCCampos():New("SA1")
	
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
Method PrepDados() Class LJCAdapXmlRecSA1
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local cNode		:= ""					//String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					//Descricao do campo
	Local oRetorno	:= NIL					//Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					//Valor da tag
	Local nCount	:= 0 					//Variavel auxiliar contador
	
	Private oNode	:= Nil					//Usado para execucao da macro
	
	oNode := ::oEstruXml
	
	//Verifica se os campos do XML existem no dicionario		
	For nCount := 1 to ::oCamposSa1:Count()
	    
	    //Nome do campo
		cCampo := ::oCamposSa1:Elements(nCount):cNome
		
		//Verifica se o campo existe no XML
		oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1, _DELIMIT + cCampo)
		
		//Trata retorno		
		If oRetorno <> Nil
			//String para ser executada via macro
			cNode := "oNode:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
			
			//Pega o conteudo da tag via macro
		    cValor := &cNode
		    
		    //Converte o campo
			::ConverCamp(cCampo, @cValor, ::oCamposSa1)
		    
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
Method EnvDados() Class LJCAdapXmlRecSA1
    
	Local lRetorno 	:= .F.					//Retorno do metodo

    Private lMsErroAuto := .F.				//Cria a variavel do retorno da rotina automatica
    Private lAutoErrNoFile := .T.			//Habilita a gravacao do erro da rotina automatica
    
	//Executa a rotina automatica
	conout("EnvDados - cOperacao :" + ::cOperacao)
	Mata030(::aEnvio, Val(::cOperacao))
	
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
Method ConsistDad() Class LJCAdapXmlRecSA1
	
	Local lRetorno 	:= .T.							//Retorno do metodo
	/*
	Local lA1CGC 	:= .F.							//Indica se existe a tag A1_CGC no XML
	Local lA1COD 	:= .F.							//Indica se existe a tag A1_COD no XML
	Local cA1COD	:= ""							//Conteudo do A1_COD
	*/
		
	//Verifica o tipo de operacao a se executada
	::cOperacao := ::oEstruXml:_FORMMODEL_CLIENTES:_OPERATION:TEXT
	
	//Formata os campos A1_COD no devido tamanho
	::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD:_VALUE:TEXT := ::FormatCamp("A1_COD", ::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD:_VALUE:TEXT)
	
	Do Case
		//INCLUSAO
		Case ::cOperacao = _INCLUSAO     
			
			//Verificar se retornou o campo A1_CGC e A1_COD.
			//lA1CGC := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1, _DELIMIT + "A1_CGC")	<> NIL
			//lA1COD := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1, _DELIMIT + "A1_COD")	<> NIL
	        
	        //Se nao existir A1_COD e A1_CGC
	        /*If !lA1COD .AND. !lA1CGC
	        	
	        	::cError := STR0001 //"N�o foi poss�vel processar a mensagem porque o campo A1_CGC n�o foi cadastrado."	
	        	lRetorno := .F.    
	        
			//Se nao existir A1_COD e existir A1_CGC, gera a partir do A1_CGC o A1_COD. 
	        ElseIf !lA1COD .AND. lA1CGC
				
				cA1COD := ::GerarA1COD(::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_CGC:_VALUE:TEXT) 
				
				//Inclui o Node A1_COD e atribui o valor
				::oXml:CriarNode(::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1, _DELIMIT + "A1_COD", "A1_COD", "NOD")
				::oXml:CriarNode(::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD, _DELIMIT + "VALUE", "value", "NOD")

				//Alimenta a node A1_COD 
				::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD:_VALUE:TEXT := ::FormatCamp("A1_COD", cA1COD)
				
	        ElseIf lA1COD
	        	
	        	//Indica que eh somente para incluir o cliente n�o precisando replicar a mensagem para quem originou.
	        	::lSoIncluir := .T.
	        
	        EndIf*/
	                
	        //Se o registro ja existir, nao incluir novamente.
	    	//If lRetorno
	    		If ::ExisteSA1()
					::cError := STR0002 //"J� existe cliente cadastrado."	
	        		lRetorno := .F.    
	    		EndIf
	    	//EndIf
	    
		//ALTERACAO	
		Case ::cOperacao == _ALTERACAO 
			//Se nao existir o cliente na alteracao, processa como inclusao
			CONOUT("ALTERACAO")
			If !::ExisteSA1()
				CONOUT("CLIENTE NAO EXISTE - TRATAR COMO INCLUSAO")
				::cOperacao := _INCLUSAO	
	       	EndIf
		
		//EXCLUSAO	
		//Case ::cOperacao == _EXCLUSAO
		    
	EndCase
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GerarA1COD�Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel fazer a consistencia dos dados recebidos.		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - CGC) - CGCCPF do cliente.    				  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GerarA1COD(cCGCCPF) Class LJCAdapXmlRecSA1
	
	Local nTamCod		:= ::oCamposSa1:ElementKey("A1_COD"):nTamanho			//Tamanho do campo
	Local nDiv			:= 0                    								//Numero utilizado para geracao do A1_COD
	Local nResto		:= 0                    								//Guarda o resto da divisao
	Local cNumero		:= Space(nTamCod)										//Numero gerado
	Local cRetorno 		:= cNumero												//Retorno da funcao    	
	
	If Len(AllTrim(cCGCCPF)) > 11
		//Pessoa Juridica
		nDiv := Val(SubStr(cCGCCPF,1,8))
	Else
		//Pessoa Fisica
		nDiv := Val(SubStr(cCGCCPF,1,9))
	EndIf

	//Calcula codigo
	While nDiv >= 35
		//Pega o resto da divisao
		nResto := nDiv % 35
		//Pega o valor inteiro da divisao
		nDiv := int(nDiv / 35)
		cNumero:= AllTrim(IIf(nResto < 10, Str(nResto), Chr(nResto + 55))) + AllTrim(cNumero)
	End

	cNumero := AllTrim(IIf(nResto < 10, Str(nResto), Chr(nResto + 55))) + AllTrim(cNumero)
	
	cRetorno := Replicate("0", nTamCod - Len(AllTrim(cNumero))) + AllTrim(cNumero)
    
Return cRetorno

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
Method FormatCamp(cCampo, cValor) Class LJCAdapXmlRecSA1
	
	Local oRetorno := Nil					//Retorno do metodo
		
	Do Case

		Case cCampo = "A1_COD"
		
			oRetorno := PadR(cValor, ::oCamposSa1:ElementKey(cCampo):nTamanho , " ") 
		
	End Case
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ExisteSA1 �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel verificar se o cliente ja existe				  ���
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
Method ExisteSA1() Class LJCAdapXmlRecSA1
	
	Local lRetorno 	:= .F.							//Retorno do metodo
	Local oCliente	:= NIl							//Objeto do tipo LJCEntCliente
	Local oRet		:= NIL							//Retorno da consulta
	
	//Instancia o objeto LJCEntCliente
	oCliente := LJCEntCliente():New()
	
	//Atribui os valores da chave
	conout("cliente :" + ::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD:_VALUE:TEXT)
	oCliente:DadosSet("A1_COD", ::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD:_VALUE:TEXT)
	oCliente:DadosSet("A1_LOJA", ::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_LOJA:_VALUE:TEXT)
	
	//Consulta os dados	
	oRet := oCliente:Consultar(1)
	
	//Trata retorno
	If oRet:Count() > 0 
		conout("achou cliente")
		lRetorno := .T.
	EndIf	
	
	FreeObj(oCliente)
	oCliente := Nil
	
	FreeObj(oRet)
	oRet := Nil
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
Method ValDefault() Class LJCAdapXmlRecSA1
	
	Local lRetorno := .T.   				//Retorno do metodo
	
	//Adiciona A1_TIPO
    AADD(::aEnvio, {"A1_TIPO", "F", NIL})
    	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ReplInfo  �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em replicar o cliente para a origem			  ���
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
Method ReplInfo() Class LJCAdapXmlRecSA1
    
	/*Local oIntegracao 	:= Nil			//Objeto do tipo LJCADAPXMLENVSA1
	Local cChave		:= ""			//Chave do cliente    
    
	//Verifica se eh inclusao e se precisa replicar
	If ::cOperacao == _INCLUSAO .AND. ::lSoIncluir == .F.

		cChave := xFilial("SA1") + ::oEstruXml:_FORMMODEL_CLIENTES:_FORMMODEL_SA1:_A1_COD:_VALUE:TEXT + '01'
			
		//Instancia o objeto LJCADAPXMLENVSA1
		oIntegracao := LJCADAPXMLENVSA1():New() 
		
		//Insere os dados 
		oIntegracao:Inserir("SA1", cChave, "1", _ALTERACAO)
		
		//Processa
		oIntegracao:Processar()
	
	EndIf*/

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Destrutor �Autor  �Vendas Clientes     � Data �  26/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Limpa os objetos que foram criados	         			  ���
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
Method Destrutor() Class LJCAdapXmlRecSA1
	
   	_Super:Destrutor()
	
   	If Self:oCamposSA1 <> Nil
		FreeObj(Self:oCamposSA1)
		Self:oCamposSA1	:= NIL
	EndIf

Return Nil
