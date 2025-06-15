#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1211 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCMontar         �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em montar os dados para exportacao               ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/      
Class LJCMontar

	Data oDadosExportacao								//Objeto do tipo LJCDadosExportacao
	Data oEstrutura										//Objeto do tipo LJCEstrutura
	Data oTransacao                                   	//Objeto do tipo LJCTransacao
	Data oNTransacao                                 	//Objeto do tipo LJCNumeroTransacao

	Method New(aDadosExportacao, aEstrutura)   			//Metodo construtor
	Method Executar()                               	//Executa a montagem dos dados a serem exportados
	Method MontaTabela()                            	//Monta a estrutura da tabela com os dados a serem exportados
	Method GetTransacao()								//Retorna a transacao com os dados a serem exportados

EndClass             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCMontar.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosExportacao) - Objeto LJCDadosExportacao.	  ���
���			 �ExpO2 (2 - oEstrutura) - Objeto LJCEstrutura. 			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New(oDadosExportacao, oEstrutura) Class LJCMontar
		
	::oDadosExportacao 	:= oDadosExportacao
	::oEstrutura		:= oEstrutura
	
	::oNTransacao := LJCNumeroTransacao():New()

	::oTransacao := LJCTransacao():new(::oNTransacao:Executar())

	::Executar() 
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Executar  �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa a montagem dos dados a serem exportados.            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosExportacao) - Objeto LJCDadosExportacao.	  ���
���			 �ExpO2 (2 - oEstrutura) - Objeto LJCEstrutura. 			  ���
�������������������������������������������������������������������������͹��
���Retorno   �      									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	                                               
Method Executar() Class LJCMontar

	Local nConta                  
	Local oDadosTabela
	Local oDadosChave 
	Local oTabela   
		
	For nConta = 1 To Len(::oDadosExportacao:GetExportacao()) 
	
		oDadosTabela := ::oEstrutura:GetEstrutura()[nConta]		
		oDadosChave  := ::oDadosExportacao:GetExportacao()[nConta]
	
	   	oTabela := ::MontaTabela(oDadosTabela, oDadosChave, nConta)
	   	
	   	//Verifica se encontrou os dados da tabela
	   	If !oTabela == Nil
	   		::oTransacao:Incluir(oTabela)
	   	EndIf
			
	Next

Return Nil

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �MontaTabela  �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Retorna a transacao com os dados a serem exportados.			 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosTabela) - Objeto LJCEstrutura.   	  	     ���
���			 �ExpO2 (2 - oChaveBusca) - Objeto LJCDadoExportacao.		     ���
���			 �ExpN1 (2 - nProcedimento) - Ordem de procedimento.		     ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto   									   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/	  	   
Method MontaTabela(oDadosTabela, oChaveBusca, nProcedimento) Class LJCMontar

    local lChave  := .F.
	Local nConta  := 0    
	Local nPos	  := 0
	Local cChave  := "" 
	Local cTabela := oChaveBusca:GetTabela()
	Local cCampo  := ""
	Local cField  := ""
	Local oTabela := Nil
	Local oCampo
	Local oIndice := Nil
	Local aFieldInd := {}
	
    
    //Defini o indice para busca
	oIndice := oChaveBusca:GetIndice()
	
	If ValType(oIndice) == "C"    
		//Busca o indice pelo NICKNAME
		oIndice := oDadosTabela:getIndNic(oIndice) 		
	EndIf
	
	//Encontra a chave de busca
	cChave := oDadosTabela:getIndice()[oIndice]

	//Abre a tabela para busca
	DbSelectArea(cTabela) 
		
	dbSetOrder(oIndice)

	//Procura na base de dados a informacao a ser enviada com base na chave identificada
	If DbSeek(oChaveBusca:GetChave())
		//Cria a tabela que armazenara os dados para serem inseridos
		oTabela := LJCTabela():New(cTabela, oChaveBusca:GetTipo(), nProcedimento, ::oTransacao:GetNumTransacao() )    
	
		//le campo a campo para o envio
		For nConta = 1 to Len(oDadosTabela:GetTabela())
			cCampo := oDadosTabela:GetTabela()[nConta]:cCampo  

			If FieldPos(cCampo) > 0
				cTipo  := oDadosTabela:GetTabela()[nConta]:nTipo
							
				cValor := &(cTabela + "->" + cCampo)                         
				If Valtype(cValor) == 'C'
					If Len(cValor) == 0
						cValor := Space(2) 
					EndIf
				EndIf
				
				//Ajusta valor(caracter especial) de campo de Log, convertendo para formato base 64Bytes
				If 'USERLG' $ cCampo
					cValor := Encode64(cValor)             
				EndIf
				
				lChave := Iif(At( Trim(cCampo), cChave) > 0 , .T. , .F.)

				//Caso o campo esteja vazio n�o devera enviar, exceto quando fizer parte da chave ou campo numerico
				//Incluido os campos caracter da tabela SA1 para tratar casos de retirada do conteudo. Necessario o tratamento para todos campos devido limitacoes na identificacao por campo alterado. 
				If !Empty(cValor) .OR. lChave .OR. cTipo == 'N' .OR. 'PAFMD5' $ cCampo .OR. ( Alltrim(cTabela) == "SA1" .AND. cTipo == "C" )

					oCampo = LJCCampo():new(cTabela, cCampo, ConverteTipo(cTipo), cValor, nConta, lChave, oDadosTabela:GetTabela()[nConta]:nTamanho)
					
					//Guarda a chave no array para que possa ordenar o �ndice e evitar problemas de grava��o no PDV
					If lChave
						Aadd(aFieldInd,{AllTrim(cCampo),oCampo})
					Else
						oTabela:IncluirObjeto(oCampo)
					EndIf

				EndIf
				
			EndIf

		Next nConta
		
		//Organiza o �ndice para que o dado enviado ao PDV na altera��o e/ou dele��o seja encontrado. 
		If Len(aFieldInd) > 0
			For nConta := 1 to Len(aFieldInd)
			    
			    cChave := AllTrim(cChave)
				nPos   := At("+",cChave)
				
				If nPos == 0
					cField := Substr(cChave,1,Len(cChave))
					cChave := Substr(cChave,1,Len(cChave))
				Else
					cField := Substr(cChave,1,nPos-1)
					cChave := Substr(cChave,nPos+1,Len(cChave))
				EndIf

				nPos := Ascan(aFieldInd,{|x| x[1] == cField})
				If nPos > 0
					oTabela:IncluirObjeto(aFieldInd[nPos][2])
				EndIf
			Next nConta++
		EndIf
	
	EndIf

Return oTabela 

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �GetTransacao �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Retorna a transacao com os dados a serem exportados.			 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�																 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto   									   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/	   
Method GetTransacao() Class LJCMontar
Return ::oTransacao
