#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOJA1208.CH"

Function LOJA1208 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCAlterar        �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em alterar o registro da importacao              ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/     
Class LJCAlterar From LJCDados
    
    Data bOk									//Identifica se o registro foi inserido
	Data aTabela								//Dados da tabela
	Data cTabela								//Nome da tabela
	Data nTransacao            					//Numero da transacao
	
	Method New(aTabela, cTabela, nTransacao)	//Metodo construtor
	Method Executar()							//Executa o comando no banco
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCAlterar.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 (1 - aTabela) 	- Dados da tabela. 					  ���
���			 �ExpC2 (2 - cCampo)	- Nome do campo.					  ���
���			 �ExpN1 (3 - nTransacao)- Numero da transacao.		          ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(aTabela, cTabela, nTransacao) Class LJCAlterar

	::aTabela	 := aTabela
	::cTabela	 := cTabela      
	::nTransacao := nTransacao

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
Method Executar() Class LJCAlterar

	Local nConta 		:= 0													//Variavel auxiliar contador 
	Local oLog			:= Nil													//Objeto do tipo LJCLogIntegracao
	Local cCampo   		:= ""													//Nome do campo
	Local cUpdate
	Local cWhere		:= ""
	Local cTransacao 	:= ""													//Armazena o n�mero da transacao
	Local cIndice 		:= ""													//Indice a ser utilizado para encontrar o registro
	Local nIndice 		:= 1													//Numero do Indice a ser utilizado para encontrar o registro
	
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
	nIndice := LJIndiceSIX( AllTrim(::cTabela), cIndice )
	
	lTabela := ::cTabela 
	
	DbSelectArea(::cTabela)
	DbSetOrder(nIndice)
		
	If DbSeek(cWhere) 
		RecLock(::cTabela,.F.)  
		//Monta o comando para ser exeuctado na base de dados
		For nConta = 1 to len( ::aTabela )
	               
			If Substr(::aTabela[nConta]:cCampo, 1, 2) <> "PK" .AND. ::aTabela[nConta]:cCampo <> "TABELA"
				cCampo :=  ::aTabela[nConta]:cCampo
       	        cValue := ::aTabela[nConta]:cValor
	
		        //Converte tipo de dados
		  		If ::aTabela[nConta]:nTipo == "4"
					cValue := STOD(cValue)
		  		ElseIf ::aTabela[nConta]:nTipo == "5"            
					cValue := Val(cValue)
				ElseIf ::aTabela[nConta]:nTipo == "2"
					If Alltrim(cValue) == "T" .OR. Alltrim(cValue) == ".T."
						cValue := .T.
					Else
						cValue := .F.
					EndIf
		  		EndIf  	
		  		           
				//Ajusta valor(caracter especial) de campo de Log, convertendo de formato base 64Bytes para o padrao
				If 'USERLG' $ cCampo
					cValue := Decode64(cValue)             
				EndIf
	  				  		           
		  		//Valida estrutura emitindo alerta quando nao localizar o campo na base        
		  		If FieldPos(cCampo) > 0 		
					Replace &(::cTabela + "->" + cCampo) With cValue	  		  		 		  			
				Else 
					Conout(STR0004, AllTrim(::cTabela) + "->" + AllTrim(cCampo)) //"LOJA1208 - PROCESSO OFF-LINE: Campo n�o encontrado no dicion�rio local:"
				EndIf

			EndIf        
			
		Next nConta
		
		MsUnLock() // Confirma e finaliza a opera��o					
	
	Else                           
	
	    cTransacao := IIf(::nTransacao == Nil,"SN",::nTransacao)
		oLog := LJCLogIntegracao():New()
		oLog:Gravar( Repl("-", 40) )						
		oLog:Gravar( STR0001 + cTransacao ) //Transa��o:
		oLog:Gravar( STR0002 + ::cTabela + STR0003 + cWhere) //Tabela: // chave n�o encontrada.
	EndIf	
	

Return Nil         

//----------------------------------------------------------------
/*/{Protheus.doc} LJIndiceSIX
Retorna o numero do indice (SIX) a ser utilizado para pesquisar o registro na tabela.
@param	 cAlias - Tabela a ser considerada
@param	 cChave - Chave/Indice a ser considerado
@return	 nIndiceRet - Numero do indice (SIX)
@author  Varejo
@version P11.8
@since   23/04/2016
/*/
//------------------------------------------------------------------
Function LJIndiceSIX( cAlias, cChave )
Local nIndiceRet := 0

DbSelectArea("SIX")
SIX->(DbSetOrder(1))
SIX->(DbSeek(cAlias))
While SIX->(!Eof()) .And. SIX->INDICE == cAlias
	nIndiceRet++
	If AllTrim(SIX->CHAVE) == cChave
		nIndiceRet := Val(SIX->ORDEM)
		Exit
	EndIf
	SIX->(DbSkip())
End

//Se por algum motivo nao econtre o indice equivamente, por padrao retorna o indice "1".
If nIndiceRet == 0
	nIndiceRet := 1
EndIf

Return nIndiceRet
