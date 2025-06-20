#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1217 ; Return  // "dummy" function - Internal Use 

/* 
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������         
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCLeitura         �Autor  �Vendas Clientes     � Data �  23/04/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em fazer a leitura da tabela					             ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		     ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/ 
Class LJCLeitura

	Data oTransacoes                        		//Objeto com as transacoes	
	Data cFil										//Codigo da filial
		
	Method New(cFil)								//Metodo construtor
	Method Ler()									//Le os dados da tabela
	Method getTransacoes()							//Retorna as transacoes
	Method TemDados()								//Verifica se tem transacoes 
	Method BuscaDados()								//Busca os dados na tabela MD8

EndClass        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCLeitura.			                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cFil) - Codigo da filial.						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New(cFil) Class LJCLeitura

	Default cFil := ""

	::cFil = cFil

	::Ler()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Ler       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Le os dados da tabela.					                  ���
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
Method Ler() Class LJCLeitura
	        
	::BuscaDados()
	
	::oTransacoes := LJCSeparaTransacao():new()
	
Return Nil

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �getTransacoes   �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Retorna as transacoes											    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																    ���
�������������������������������������������������������������������������������͹��
���Retorno   �Objeto 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method getTransacoes() Class LJCLeitura
Return ::oTransacoes:GetTransacoes()  

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �TemDados        �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Verifica se tem transacoes									    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																    ���
�������������������������������������������������������������������������������͹��
���Retorno   �Logico 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method TemDados() Class LJCLeitura
Return ::oTransacoes:TemDados()  

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �BuscaDados      �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Busca os dados na tabela MD8									    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�																    ���
�������������������������������������������������������������������������������͹��
���Retorno   �		 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/	 
Method BuscaDados() Class LJCLeitura

	Local cQuery										//Armazena a query
    
    #IFDEF TOP
		cQuery := " SELECT"
		cQuery += " MD8_SERVWB, MD8_TIPO, MD8_NOME, MD8_VALOR, MD8_TPCPO,"
		cQuery += " MD8_MODULO,	MD8_REG, MD8_SEQ, MD8_SITPRO,"
		cQuery += " MD8_TRANS, MD8_STATUS, MD8_DATA" //, tip_integr, dat_inclusao	
		cQuery += " FROM " + RetSqlName("MD8")
		cQuery += " WHERE  MD8_STATUS = '1'"
	
		If ::cFil <> ""
			cQuery += " AND MD8_FILIAL = '" + ::cFil + "'"
		EndIf
		
		cQuery += " ORDER BY MD8_TRANS, MD8_REG, MD8_SEQ"
	
		cQuery  := ChangeQuery( cQuery )
	
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMP", .T., .F. )
	#ENDIF	
Return Nil
