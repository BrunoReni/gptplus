#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1202 ; Return  // "dummy" function - Internal Use 
 
/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCExporta        �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em exportar os dados da integracao               ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/ 
Class LJCExporta
                                       
	Data oDadosExportacao									//Objeto do tipo LJCDadosExportacao com os dados da exportacao
	Data cProcesso											//Codigo do processo que sera exportado
	Data lUsaTradut											//Se a integracao vai utilizar o tradudor
	Data cTransacao											//Codigo da transacao
	Data oNumTrans											//Objeto do tipo LJCNumeroTransacao que controla o numero da transacao

	Method New(oDadosExportacao, cProcesso, lUsaTradut)		//Metodo construtor
	Method Executar()										//Executar a exportacao
	Method Ler() 											//Le a estrutura (campos e indices) das tabelas a serem exportadas
	Method Montar()                                         //Monta os dados (valores de cada campo da tabela) a serem exportados
	Method Atualizar()                                      //Atualiza os dados na tabela de saida da integracao 

EndClass        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCExporta.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadosExportacao) - Dados da exportacao.		  ���
���			 �ExpC1 (2 - cProcesso)  - Codigo do processo.				  ���
���			 �ExpL1 (3 - lUsaTradut) - Utiliza tradutor.		          ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oDadosExportacao, cProcesso, lUsaTradut) Class LJCExporta
	
	Default lUsaTradut := .F.
	
	::cTransacao		:= ""
	::oDadosExportacao  := oDadosExportacao
	::cProcesso			:= cProcesso
	::lUsaTradut		:= lUsaTradut
	::oNumTrans			:= Nil
	
	::Executar()
	
Return Self

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Executar      �Autor  �Vendas Clientes     � Data �  23/04/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em executar a exportacao.  						   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                             ���
������������������������������������������������������������������������������͹��
���Parametros�											                       ���															  
������������������������������������������������������������������������������͹��
���Retorno   �											   				       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Executar() Class LJCExporta
       
	Local oEstrutura := Nil							//Objeto do tipo LJCEstrutura coma a estrutura da tabela
	local oTransacao := Nil                         //Objeto do tipo LJCMontar com os dados da tabela
	
	//Le a estrutura da tabela
	oEstrutura := ::Ler()  
	
	//Monta os dados para exportacao	
	oTransacao := ::Montar(oEstrutura)
	
	//Atualiza os dados da exportacao na tabela de saida
	::Atualizar(oTransacao)	

Return Nil

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Ler           �Autor  �Vendas Clientes     � Data �  23/04/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em ler a estrutura das tabelas a serem exportadas    ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                             ���
������������������������������������������������������������������������������͹��
���Parametros�											                       ���															  
������������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Ler() Class LJCExporta

	Local oEstrutura := Nil						//Objeto do tipo LJCEstrutura com a estrutura da tabela
	
	oEstrutura := LJCEstrutura():New(::oDadosExportacao)
	
	oEstrutura:Executar()

Return oEstrutura

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Montar        �Autor  �Vendas Clientes     � Data �  23/04/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em montar os dados a serem exportados    			   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                             ���
������������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oEstrutura) - Estrutura da tabela.		       		   ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Montar(oEstrutura) Class LJCExporta

	Local oMontar := Nil							//Objeto do tipo LJCMontar com os dados da tabela
	
	oMontar := LJCMontar():new(::oDadosExportacao, oEstrutura)
	
	::oNumTrans := oMontar:oNTransacao
	
Return oMontar:GetTransacao()


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �Atualizar     �Autor  �Vendas Clientes     � Data �  23/04/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em montar os dados a serem exportados    			   ���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                             ���
������������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oTransacao) - Dados da tabela que serao inseridos.    ���
������������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method Atualizar(oTransacao) class LJCExporta

	Local oAtualizar := Nil						//Objeto do tipo LJCInsereExportacao
	
	oAtualizar := LJCInsereExportacao():New(oTransacao, ::cProcesso, ::lUsaTradut)
	
	//Guarda o numero da transacao
	::cTransacao := oAtualizar:cTransacao
    
    //Libera o numero da transacao no server
	::oNumTrans:oGetTrans:FreeTrans()
	
Return Nil