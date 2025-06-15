#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1220 ; Return  // "dummy" function - Internal Use 

/* 
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������         
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCSeparaTabela    �Autor  �Vendas Clientes     � Data �  23/04/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em separar os dados da tabela MD8				   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/  
Class LJCSeparaTabela
    
	Data oTabela										//Objeto do tipo LJCTabela
	Data cTipoProc										//Tipo de procedimento
	Data cTabela										//Nome da tabela
	Data nProcedimento									//Codigo do procedimento
	Data nTransacao										//Numero da transacao
		
	Method New()										//Metodo construtor
	Method Separar()									//Separa os dados da tabela

EndClass            

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �New             �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCSeparaTabela.  				    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�												  	                ���
�������������������������������������������������������������������������������͹��
���Retorno   �Objeto 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method New() Class LJCSeparaTabela
		
    #IFDEF TOP   
		If Upper(TMP->MD8_NOME) = "TABELA"   
			::cTabela 			:= TMP->MD8_VALOR
			::cTipoProc			:= TMP->MD8_TIPO
			::nProcedimento 	:= TMP->MD8_REG
			::nTransacao		:= TMP->MD8_TRANS
			
			::oTabela := LJCTabela():New(::cTabela, ::cTipoProc, ::nProcedimento, ::nTransacao) 
			
			TMP->(dbSkip())
		EndIf
	#ELSE
		If Upper(MD8->MD8_NOME) = "TABELA"   
			::cTabela 			:= MD8->MD8_VALOR
			::cTipoProc			:= MD8->MD8_TIPO
			::nProcedimento 	:= MD8->MD8_REG
			::nTransacao		:= MD8->MD8_TRANS
			
			::oTabela := LJCTabela():New(::cTabela, ::cTipoProc, ::nProcedimento, ::nTransacao) 
			
			MD8->(dbSkip())
		EndIf
	#ENDIF
			
Return Self

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͻ��
���Metodo    �Separar         �Autor  �Vendas Clientes     � Data �  11/06/08 	���
�������������������������������������������������������������������������������͹��
���Desc.     �Separa os dados da tabela.					  				    ���
�������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                              ���
�������������������������������������������������������������������������������͹��
���Parametros�												  	                ���
�������������������������������������������������������������������������������͹��
���Retorno   �Objeto 									   		                ���
�������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Method Separar() Class LJCSeparaTabela

	Local cTipoProc 	:= ""
	Local cCampo		:= ""
	Local cTipo			:= ""
	Local cValor		:= ""
	Local nSequencia	:= 0
	Local nTransacao	   

    #IFDEF TOP                                 
    
    	nTransacao 	:= TMP->MD8_TRANS
    	    
		While !TMP->(EOF()) .AND. ::nProcedimento = TMP->MD8_REG .AND. nTransacao = TMP->MD8_TRANS
	
		  	cTipoProc	:= TMP->MD8_TIPO
			cCampo		:= TMP->MD8_NOME
			cTipo		:= TMP->MD8_TPCPO
			cValor		:= TMP->MD8_VALOR
			nSequencia 	:= TMP->MD8_SEQ
			
			::oTabela:Incluir(cTipoProc, cCampo, cTipo, cValor, nSequencia) 
			
			TMP->(dbSkip())
			
		End
	#ELSE 
    	nTransacao 	:= MD8->MD8_TRANS
    	    
		While !MD8->(EOF()) .AND. ::nProcedimento == MD8->MD8_REG .AND. nTransacao == MD8->MD8_TRANS
		  	cTipoProc	:= MD8->MD8_TIPO
			cCampo		:= MD8->MD8_NOME
			cTipo		:= MD8->MD8_TPCPO
			cValor		:= MD8->MD8_VALOR
			nSequencia 	:= MD8->MD8_SEQ
			
			::oTabela:Incluir(cTipoProc, cCampo, cTipo, cValor, nSequencia) 
			   
			MD8->(dbSkip())		
		End	
	#ENDIF

Return ::oTabela
