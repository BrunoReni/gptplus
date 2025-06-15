#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1205 ; Return  // "dummy" function - Internal Use 

/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCTabela         �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em processar os dados da tabela                  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/   
Class LJCTabela

	Data cTipoProc														//Tipo do processo								        
	Data aTabela                                                		//Array com os campos da tabela
	Data cTabela                                                        //Nome da tabela
	Data nProcedimento                                                  //Numero do procedimento
	Data nTransacao            											//Numero da transacao
	Data oDadosTabela													
	
 	Method New(cTabela, cTipoProc, nProcedimento, nTransacao)         	//Metodo construtor
    Method NewExporta(cTabela, cTipoProc, nProcedimento, nTransacao, ;
                      oDadosTabela) Constructor                      	//Metodo construtor
    Method Incluir(cTipoProc, cCampo, cTipo, cValor, ;
                   nSequencia)											//Inclui campo da tabela  
    Method IncluirObjeto(oCampo)  										//Inclui objeto LJCCampo na tabela
    Method Executar()                                                  	//Processa os dados da tabela na base de dados
    Method GetTabela()													//Retorna os campos da tabela   
    Method Traduzir()													//Traduz os campos da tabela               
    Method BuscaRegistro()                                             	//Busca o recno da tabela de traducao
       	
EndClass            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTabela.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
���			 �ExpC2 (2 - cTipoProc)  - Tipo de procedimento.			  ���
���			 �ExpN1 (3 - nProcedimento) - Numero do procedimento          ���
���			 �ExpN2 (4 - nTransacao)   - Numero da transacao.	          ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cTabela, cTipoProc, nProcedimento, nTransacao) Class LJCTabela

	::aTabela 			:= {}                 
	::cTabela 			:= cTabela
	::cTipoProc			:= cTipoProc
	::nProcedimento 	:= nProcedimento
	::nTransacao		:= nTransacao   
	
Return Self      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �newExporta�Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCTabela.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
���			 �ExpC2 (2 - cTipoProc) - Tipo de procedimento.			      ���
���			 �ExpN1 (3 - nProcedimento) - Numero do procedimento          ���
���			 �ExpN2 (4 - nTransacao) - Numero da transacao.	              ���
���			 �ExpO1 (5 - oDadosTabela) - Dados da tabela.   	          ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method newExporta(cTabela, cTipoProc, nProcedimento, nTransacao, ;
                  oDadosTabela) Class LJCTabela

	::New(cTabela, cTipoProc, nProcedimento, nTransacao)
	
	::oDadosTabela := oDadosTabela
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Incluir   �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em incluir o campo na tabela.                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipoProc) - Tipo de procedimento. 			  ���
���			 �ExpC2 (2 - cCampo) - Campo da tabela.			      		  ���
���			 �ExpC3 (3 - cTipo) - Tipo do campo          				  ���
���			 �ExpC4 (4 - cValor) - Valor do campo.	        		      ���
���			 �ExpN1 (5 - nSequecia) - Sequencia.			   	          ���
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Incluir(cTipoProc, cCampo, cTipo, cValor, ;
               nSequencia) Class LJCTabela
	
	Local oCampo := Nil								//Objeto do tipo LJCCampo
	
	oCampo := LJCCampo():New(::cTabela, cCampo, cTipo, cValor, nSequencia)
	                        
	::IncluirObjeto(oCampo)

Return 

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �IncluirObjeto�Autor  �Vendas Clientes     � Data �  23/04/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Responsavel em incluir o campo na tabela.                      ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oCampo) - Objeto LJCCampo. 			  	         ���
����������������������������������������������������������������������������͹��
���Retorno   �											   				     ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method IncluirObjeto(oCampo) Class LJCTabela

	AADD(::aTabela, oCampo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Executar  �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar os dados da tabela na base de dados���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico    								   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Executar() Class LJCTabela

	Local oExecutar := Nil						//Objeto do tipo LJADados 	     

	If ::cTipoProc = "INSERT"
		oExecutar := LJCInserir():New(::aTabela, ::cTabela)		
	ElseIf ::cTipoProc = "UPDATE"
		oExecutar:= LJCAlterar():New(::aTabela, ::cTabela)		
	ElseIf ::cTipoProc = "DELETE"
		oExecutar:= LJCApagar():New(::aTabela, ::cTabela)		
	EndIf		   
	
	Return oExecutar:bOk

	Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetTabela �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os campos da tabela 				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Array      								   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTabela() Class LJCTabela
Return ::aTabela

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Traduzir  �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em traduzir os campos da tabela 				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�													  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto      								   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Traduzir() Class LJCTabela

	Local nConta	:= 0							//Variavel de controle contador      
	Local cTabDest 	:= ""                      		//Tabela de destino
	Local aTmp 		:= TMP->(GetArea())        	//Array com a alias atual
	
	Local oTabDest  := Nil							//Objeto do tipo LJCTabela
	Local oCampDest := Nil                         	//Objeto do tipo LJCTabela
	Local nRecno 	:= ::BuscaRegistro(::cTabela)  //Recno da tabela de traducao
	               
	If nRecno <> 0 

		DbSelectArea("SLY") 
			
		DbGoto(	nRecno )

		cTabDest := Trim(SLY->LY_TABDEST)
		
		oTabDest := LJCTabela():New(cTabDest, ::cTipoProc, ::nProcedimento, ::nTransacao)
		
		For nConta = 1 to Len(::aTabela)
			
			oCampDest := ::aTabela[nConta]:Traduzir()
			
			If oCampDest <> NIL
				oTabDest:IncluirObjeto(oCampDest)
			EndIf
					
		Next
		
	EndIf
	
	RestArea(aTmp)

Return oTabDest

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Traduzir  �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em buscar o recno da tabela de traducao 		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico     								   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaRegistro(cTabela) Class LJCTabela
	
	Local nRecno								//Recno da tabela
	Local cQuery                                //Query a ser executada
	
	cQuery := "select R_E_C_N_O_ recnoReg from " + RetSqlName("SLY")
	cQuery += " where LY_TABORIG = '" +  cTabela + "'"         
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "RNC", .T., .F.)
	
	DbSelectArea("RNC")
	
	RNC->(DbGoTop())  

	nRecno := RNC->recnoReg
	
	dbCloseArea()

Return nRecno