#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1206 ; Return  // "dummy" function - Internal Use 

/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCCampo          �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar as caracteristica de cada campo da    ���
���			 �tabela e executar a traducao do mesmo se necessario				  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/    
Class LJCCampo
	
	Data cTabela                                         	//Nome da tabela
	Data cCampo												//Nome do campo
	Data nTipo                                              //Tipo de dado do campo
	Data cValor 											//Valor do campo
	Data nSequencia 										//Posicao do campo
	Data lChave												//Se o campo faz para da chave primaria
	Data nTamanho											//Tamanho do campo
		
	Method New(cTabela, cCampo, nTipo, cValor, ;
	           nSequencia, lChave, nTamanho)				//Metodo construtor
	Method GetCampo()										//Retorna o campo
	Method GetTipo()										//Retorna o tipo de dado do campo
	Method GetValor()  										//Retorna o valor do campo
	Method GetSequencia()                           		//Retorna a posicao do campo
	Method Traduzir()										//Executa a traducao do campo
	Method Executar()										//Executa a atualizacao do campo
	Method BuscaRegistro(cTabela, cCampo)					//Busca o recno da tabela de traducao SLY

EndClass             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCampo.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
���			 �ExpC2 (2 - cCampo)  - Nome do campo.						  ���
���			 �ExpN1 (3 - nTipo) - Tipo de dado do campo                   ���
���			 �ExpC3 (4 - cValor) - Valor do campo.				          ���
���			 �ExpN2 (5 - nSequencia)  - Posicao campo.   				  ���
���			 �ExpL1 (6 - lChave) - Se o campos pertence a chave primaria  ���
���			 �ExpN3 (7 - nTamanho) - Tamanho do campo.  		          ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cTabela, cCampo, nTipo, cValor, ;
           nSequencia, lChave, nTamanho) Class LJCCampo

	Default lChave := .F.	

	::cTabela		:= cTabela
	::cCampo 		:= cCampo
	::nTipo 		:= nTipo
	::cValor 		:= cValor	      
	::nSequencia 	:= nSequencia
	::lChave		:= lChave
	::nTamanho		:= nTamanho
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetCampo  �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o campo.						                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCampo() Class LJCCampo
Return ::cCampo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetTipo   �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o tipo do campo.  			                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTipo() Class LJCCampo
Return ::nTipo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetValor  �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o valor do campo.  			                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetValor() Class LJCCampo
Return ::cValor

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �GetSequencia �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Retorna a posicao do campo.  			                         ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�															     ���
����������������������������������������������������������������������������͹��
���Retorno   �Numerico							  	                         ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method GetSequencia() Class LJCCampo
Return ::nSequencia

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �Traduzir     �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Executa a traducao do campo.  		                         ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�															     ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto							  	                         ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method Traduzir() Class LJCCampo

	Local cFormula  := ""								//Formula utilizada para traduzir o campo  
	Local cTabDest	:= ""								//Tabela de destino
	Local cCampo	:= "" 								//Nome do campo
	Local nRecno    := 0 								//Recno da tabela
	Local Valor		:= ""								//Valor do campo
	Local oCampDest := Nil								//Objeto do tipo LJCCampo
	            
	If Upper(Left(::cCampo, 2)) = "PK" 
		::lChave := .T.
		::cCampo := SubStr(::cCampo, 3, Len(::cCampo))
	EndIf   
	
	nRecno := ::BuscaRegistro(::cTabela, ::cCampo) 

	If nRecno == 0 
		Return oCampDest
	EndIf

	DbSelectArea("SLY")
	
	DbGoto( nRecno ) 
		
	Valor := AllTrim(::cValor)

	If AllTrim(SLY->LY_FORMULA) <> ""
	
		cFormula 	:= &(SLY->LY_FORMULA)

		//bOldError := ErrorBlock( {|x| IntVerifErro(x) } ) // muda code-block de erro
		
		//Begin Sequence
			Eval(cFormula)
		//Recover
		//	Valor := ::cValor
		//End Sequence
		
		//ErrorBlock( bOldError ) // Restaura rotina de erro anterior

	Endif	
	
	cCampo 		:= Trim(SLY->LY_CPDEST)
	cTabDest	:= Trim(SLY->LY_TABDEST)  
	
	oCampDest = LJCCampo():new(cTabDest, cCampo, ::nTipo, Valor, ::nSequencia, ::lChave, ::nTamanho)
	
Return  oCampDest

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �Executar     �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Executa a atualizacao do campo.  		                         ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�															     ���
����������������������������������������������������������������������������͹��
���Retorno   �      							  	                         ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method Executar() Class LJCCampo

	Local cCampo := ::cCampo
	Local cTabela := ::cTabela
	
	If FieldPos(::cCampo) > 0                  
		Replace &(::cTabela + "->" + ::cCampo) With ::cValor
	EndIf

Return Nil

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �BuscaRegistro�Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Busca o recno da tabela de traducao SLY.                       ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					     ���
���			 �ExpC2 (2 - cCampo)  - Nome do campo.						     ���
����������������������������������������������������������������������������͹��
���Retorno   �Numerico							  	                         ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method BuscaRegistro(cTabela, cCampo) Class LJCCampo
	
	Local nRecno := 0							//Retorno do metodo
	Local cQuery := ""							//Auxiliar para montar o comando select
	
	cQuery := "select R_E_C_N_O_ recnoReg from " + RetSqlName("SLY")
	cQuery += " where LY_TABORIG = '" +  cTabela + "'"         
	cQuery += " and LY_CPORIG = '" +  cCampo + "'"    
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "RNC", .T., .F. )
	
	DbSelectArea("RNC")
	
	RNC->(DbGoTop())  

	nRecno := RNC->recnoReg
	
	DbCloseArea()

Return nRecno