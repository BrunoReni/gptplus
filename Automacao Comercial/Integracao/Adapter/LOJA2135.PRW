#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFINTEGRA.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJADPSA1  �Autor  �Vendas Clientes     � Data �  15/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adapter de recebimento SA1    							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML recebido.						  	  ���
���			 �ExpC2 (2 - cError) - Retorna mensagem de erro.		  	  ���
���			 �ExpC3 (3 - cWarning) - Retorna mensagem de aviso.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJADPSA1(cXml, cError, cWarning)
	
	Local oAdapter	:= Nil						//Objeto do tipo LJAAdapXmlRec
	Local lRetorno := .F.						//Retorno dos adapters
	
	Conout('LOJA2135 - Inicio Processando Adapter SA1 (' + Time() + ')')
		
	//Instancia o objeto LJCAdapXmlRecSA1
	oAdapter := LJCAdapXmlRecSA1():New()

	//Processa o adapter de recebimento
	lRetorno := LJPROCADP(oAdapter, cXml, @cError, @cWarning)
	
	Destrutor(oAdapter, .T.)
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJADPSBM  �Autor  �Vendas Clientes     � Data �  15/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adapter de recebimento SBM    							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML recebido.						  	  ���
���			 �ExpC2 (2 - cError) - Retorna mensagem de erro.		  	  ���
���			 �ExpC3 (3 - cWarning) - Retorna mensagem de aviso.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJADPSBM(cXml, cError, cWarning)
	
	Local oAdapter	:= Nil						//Objeto do tipo LJAAdapXmlRec
	Local lRetorno := .F.						//Retorno dos adapters
	
	Conout('LOJA2135 - Inicio Processando Adapter SBM (' + Time() + ')')
		
	//Instancia o objeto LJCAdapXmlRecSBM
	oAdapter := LJCAdapXmlRecSBM():New()
	
	//Processa o adapter de recebimento
	lRetorno := LJPROCADP(oAdapter, cXml, @cError, @cWarning)
	
	Destrutor(oAdapter, .T.)
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJADPSB1  �Autor  �Vendas Clientes     � Data �  15/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adapter de recebimento SB1    							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML recebido.						  	  ���
���			 �ExpC2 (2 - cError) - Retorna mensagem de erro.		  	  ���
���			 �ExpC3 (3 - cWarning) - Retorna mensagem de aviso.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJADPSB1(cXml, cError, cWarning)
    
	Local oAdapter	:= Nil						//Objeto do tipo LJAAdapXmlRec
	Local lRetorno := .F.						//Retorno dos adapters
	
	Conout('LOJA2135 - Inicio Processando Adapter SB1 (' + Time() + ')')
	
	//Instancia o objeto LJCAdapXmlRecSB1
	oAdapter := LJCAdapXmlRecSB1():New()
	
	//Processa o adapter de recebimento
	lRetorno := LJPROCADP(oAdapter, cXml, @cError, @cWarning)
	
	Destrutor(oAdapter, .T.)
	
Return lRetorno 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJADPSB1  �Autor  �Vendas Clientes     � Data �  15/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adapter de recebimento SB1    							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML recebido.						  	  ���
���			 �ExpC2 (2 - cError) - Retorna mensagem de erro.		  	  ���
���			 �ExpC3 (3 - cWarning) - Retorna mensagem de aviso.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJADPSC5( cXml, cError, cWarning )
    
	Local oAdapter	:= Nil						//Objeto do tipo LJAAdapXmlRec
	Local lRetorno := .F.						//Retorno dos adapters

	Conout('LOJA2135 - Inicio Processando Adapter SC5 (' + Time() + ')')
	
	//Instancia o objeto LJCAdapXmlRecSB1
	oAdapter := LJCAdapXmlRecSC5():New()
	
	//Processa o adapter de recebimento
	lRetorno := LJPROCADP( oAdapter, cXml, @cError, @cWarning )
	
	Destrutor(oAdapter, .T.)
Return lRetorno 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJADPNCC  �Autor  �Vendas Clientes     � Data �  15/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adapter de recebimento NCC    							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML recebido.						  	  ���
���			 �ExpC2 (2 - cError) - Retorna mensagem de erro.		  	  ���
���			 �ExpC3 (3 - cWarning) - Retorna mensagem de aviso.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJADPNCC(cXml, cError, cWarning)
    
	Local oAdapter	:= Nil						//Objeto do tipo LJAAdapXmlRec
	Local lRetorno := .F.						//Retorno dos adapters

	Conout('LOJA2135 - Inicio Processando Adapter NCC (' + Time() + ')')
	
	//Instancia o objeto LJCAdapXmlRecNCC
	oAdapter := LJCAdapXmlRecNCC():New()
	
	//Processa o adapter de recebimento
	lRetorno := LJPROCADP(oAdapter, cXml, @cError, @cWarning)
	
	Destrutor(oAdapter, .T.)
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJPROCADP �Autor  �Vendas Clientes     � Data �  15/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa os Adapter's         							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oAdp) - Adapter a ser processado.			  	  ���
���			 �ExpC1 (2 - cXML) - XML recebido.						  	  ���
���			 �ExpC2 (3 - cError) - Retorna mensagem de erro.		  	  ���
���			 �ExpC3 (4 - cWarning) - Retorna mensagem de aviso.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJPROCADP(oAdp, cXmlRec, cError, cWarning)
	
	Local lRetorno := .F.		//Retorno da funcao
	
	//Processa o adapter de recebimento
	lRetorno := oAdp:Processar(cXmlRec)
	
	Conout('LOJA2135 - Fim Processamento (' + Time() + ')' + IIF(lRetorno,' com Sucesso', ' com Erro'))
			
	//Trata o retorno
	If !lRetorno
		cError := oAdp:cError
		cWarning := oAdp:cWarning
		
		Conout('LOJA2135 - Mensagem Erro (' + cError + ')')
		Conout('LOJA2135 - Mensagem Aviso (' + cWarning + ')')
	EndIf
		
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �LJCARGAINI�Autor  �Vendas Clientes     � Data �  08/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera carga inicial da integracao 							  ���
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
Function LJCARGAINI()

	Local oLJCBestSales 			:= Nil
	Local oLJCRM 					:= Nil
	Local oLJCSoftSite  			:= Nil	
	Local oLJCCargaIntegracaoForm   := Nil 

    //Cria Objeto de Configura��o da BestSales
    oLJCBestSales := LJCBestSales():New()
	   
    //Cria Objeto de Configura��o da RM
    oLJCRM        := LJCRM():New()
    
    //Cria Objeto de Configura��o da SoftSite
    oLJCSoftSite  := LJCSoftSite():New()
	
	oLJCCargaIntegracaoForm := LJCCargaIntegracaoForm():New()
	
	// Adiciona a integra��o da criterium na wizard de carga inicial
	oLJCCargaIntegracaoForm:AddIntegration( oLJCBestSales )
	// Adiciona a integra��o da RM na wizard de carga inicial
	oLJCCargaIntegracaoForm:AddIntegration( oLJCRM )
	// Adiciona a integra��o da SoftSite no Wizard de Carga Inicial
	oLJCCargaIntegracaoForm:AddIntegration( oLJCSoftSite )

	oLJCCargaIntegracaoForm:Show()

	Destrutor(oLJCBestSales) 
	Destrutor(oLJCRM)
	Destrutor(oLJCCargaIntegracaoForm, .T.)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Destrutor �Autor  �Vendas Clientes     � Data �  27/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Destroi o objeto criado liberando recurso de memoria		  ���
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
Static Function Destrutor(oObj, lClean)
    
	Default lClean := .F.

	If oObj <> Nil
		//Libera o objeto
		FreeObj(oObj)
		//Inicializa o objeto
		oObj := Nil
		
		If lClean
			//Libera recurso de memoria
			//Obs: este comando so precisa ser executado uma unica vez apos a execucao do processo
			DelClassIntf()
		EndIf
	EndIf

Return Nil
