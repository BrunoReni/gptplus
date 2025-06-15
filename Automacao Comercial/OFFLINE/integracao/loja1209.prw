#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1209 ; Return  // "dummy" function - Internal Use 

/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCApagar         �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em apagar o registro da importacao               ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/     
Class LJCApagar From LJADados
     
    Data bOk									//Identifica se o registro foi inserido
	Data aTabela								//Dados da tabela
	Data cTabela								//Nome da tabela
	
	Method New(aTabela, cTabela)				//Metodo construtor
	Method Executar()							//Executa o comando no banco    

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCApagar.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 (1 - aTabela) - Dados da tabela. 					  ���
���			 �ExpC2 (2 - cCampo)  - Nome do campo.						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(aTabela, cTabela) class LJCApagar

	::aTabela := aTabela
	::cTabela := cTabela  

	::bOk := .T.
	
	::Executar()

Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Executar  �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa o comando no banco.			                      ���
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
Method Executar() class LJCApagar
              
	Local nConta 	:= 0													//Variavel auxiliar contador 
	Local oLog		:= Nil													//Objeto do tipo LJCLogIntegracao
	Local cCampo	:= ""													//Nome do campo
	Local cWhere    := ""
	Local cIndice 	:= ""													//Indice a ser utilizado para encontrar o registro
	Local nIndice 	:= 1													//Numero do Indice a ser utilizado para encontrar o registro
	
	#IFDEF TOP
	
		cDelete	:= "DELETE FROM " +	RetSqlName(::cTabela)
		cWhere	:= " WHERE " 
	
		//Monta o comando para ser exeuctado na base de dados
		For nConta = 1 to len( ::aTabela )
		    
			If Substr(::aTabela[nConta]:cCampo, 1, 2) == "PK"
				::aTabela[nConta]:lChave := .T.
				cCampo := Substr(::aTabela[nConta]:cCampo, 3)
			Else
				cCampo :=  ::aTabela[nConta]:cCampo
			EndIf        
		
			If ::aTabela[nConta]:lChave       
				cWhere	+=  cCampo  + " = " 
				cWhere	+=  ConverteValor(::aTabela[nConta]:nTipo, ::aTabela[nConta]:cValor)  + " AND "
			EndIf
				
		Next nConta
		
		cWhere  := left(cWhere, len(cWhere) - 4)
	
		If TcSqlExec(cDelete + cWhere) < 0
		
			oLog := LJCLogIntegracao():New()
		
			oLog:Gravar( Repl("-", 40) )		
			
			oLog:Gravar( cDelete + cWhere )
			
			oLog:Gravar( tcsqlerror() )
		
		EndIf
	
	#ELSE             
		//Armazena Campo chave
		For nConta = 1 to len( ::aTabela )
	                                
			If Substr(::aTabela[nConta]:cCampo, 1, 2) == "PK"
				cValue 		:= ::aTabela[nConta]:cValor                    
				
				cCampo		:= AllTrim(Substr(::aTabela[nConta]:cCampo, 3))
				nTamCampo	:= TamSX3( cCampo )[1]
				
				cValue := Substr(cValue,1,nTamCampo)				
				cWhere += cValue
				
				cIndice += cCampo + "+" //Monta o indice a ser utilizado
			EndIf        
				
		Next nConta      
		
		cIndice := Left(cIndice,Len(cIndice)-1) //Tira o ultimo sinal (+)
		If FindFunction("LJIndiceSIX")
			nIndice := LJIndiceSIX( AllTrim(::cTabela), cIndice )
		EndIf
	         
		lTabela := ::cTabela 
		
		DbSelectArea(::cTabela)
		DbSetOrder(nIndice)
				
		If DbSeek(cWhere) 
			RecLock(::cTabela,.F.)  

			DbDelete()			
			
			MsUnLock() // Confirma e finaliza a opera��o					
		EndIf	

	#ENDIF    


Return Nil
