#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOJA1207.CH"

Function LOJA1207 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCInserir        �Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em inserir o registro da importacao              ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/     
Class LJCInserir From LJADados

	Data bOk									//Identifica se o registro foi inserido
		
	Method New(aTabela, cTabela)				//Metodo construtor
	Method Executar()							//Executa o comando no banco
	Method BuscaRecno()							//Busca o recno da tabela

EndClass            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  11/06/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCInserir.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpA1 (1 - aTabela) - Dados da tabela. 					  ���
���			 �ExpC1 (2 - cCampo)  - Nome da tabela.						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(aTabela, cTabela) Class LJCInserir

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
Method Executar() Class LJCInserir       
        
	Local nConta 	:= 0													//Variavel auxiliar contador 
	Local oLog		:= Nil													//Objeto do tipo LJCLogIntegracao
	Local cCampos	
	Local cValues
	Local cWhere    	:= ""												//Armazena conteudo da chave para realizar Seek
	Local lRecLock		:= .T.   											//Sinaliza se RecLock sera de insert ou update
	Local aChaveReg		:= {{"","",""}}										//Armazena chave(Campo,Conteudo,Tipo) 
    
	//Armazena Campo chave      
	For nConta = 1 to Len( ::aTabela )
                                
		If Substr(::aTabela[nConta]:cCampo, 1, 2) == "PK"
			cValue 		:= ::aTabela[nConta]:cValor                    
			
			cCampo		:= AllTrim(Substr(::aTabela[nConta]:cCampo, 3))
			nTamCampo	:= TamSX3( cCampo )[1]
			
			cValue := Substr(cValue,1,nTamCampo)				
			cWhere += cValue   
			                                        
			//Armnazena Conteudo da Chave(Campo,Valor,Tipo)
			AAdd(aChaveReg,{cCampo,cValue,::aTabela[nConta]:nTipo})			
		EndIf        
			
	Next nConta
	
	
	//�������������������������������������������������������������Ŀ
	//�Tratamento somente para SA1, unico cadastro que pode ser 	�
	//�realizado em PDV(Offline) e subir para Retaguarda:			�
	//�Evita Chave Duplicada quando eh realizado o cadastro do mesmo�	
	//�cliente/CPF em PDV distinto sendo acionando Job(1115) 		�		
	//�simultaneo sendo "startado" Thread(Job1123) para cada PDV.	�			
	//���������������������������������������������������������������	
	If AllTrim(::cTabela) == "SA1"
		DbSelectArea(AllTrim(::cTabela))   
		DbSetOrder(1)
		If !DbSeek(cWhere) 
			RecLock(AllTrim(::cTabela), lRecLock)		   								
			
			For nConta = 2 to len( aChaveReg )			
				                                    
				cField	:= aChaveReg[nConta][1]
				cValues := aChaveReg[nConta][2]
				
				//Converte tipo de dados
				If aChaveReg[nConta][3] == "4"
					cValueS := STOD(cValueS)
				ElseIf aChaveReg[nConta][3] == "5"            
					cValues := Val(cValues)
				ElseIf aChaveReg[nConta][3] == "2"
					If Alltrim(cValues) == "T" .OR. Alltrim(cValues) == ".T."
						cValues := .T.
					Else
						cValues := .F.
					EndIf
				EndIf  	
				
				//Valida estrutura emitindo alerta quando nao localizar o campo na base        
		  		If FieldPos(cField) > 0 		
					Replace &(::cTabela + "->" + cField) With cValues	  		  		 
				Else 
					Conout(STR0001, AllTrim(::cTabela) + "->" + AllTrim(cField)) //"LOJA1207 - PROCESSO OFF-LINE: Campo n�o encontrado no dicion�rio local:"
				EndIf
				
			Next nConta            
			
			MsUnLock()			
		EndIf	
		lRecLock := .F.
	EndIf
	     
	DbSelectArea(AllTrim(::cTabela))   
	DbSetOrder(1)
	If !lRecLock .OR. !DbSeek(cWhere)
		RecLock(AllTrim(::cTabela), lRecLock)		   
		
		//�������������������������������������������������������������Ŀ
		//�Retirado instru��o SQL para deixar adequado a todos os fontes�
		//���������������������������������������������������������������
		
		For nConta = 1 to len( ::aTabela )
		
			If Substr(::aTabela[nConta]:cCampo, 1, 2) == "PK"
				cField	:=  Substr(::aTabela[nConta]:cCampo, 3)
			Else
				cField	:=  ::aTabela[nConta]:cCampo
			EndIf
		                                                          
			cValues := ::aTabela[nConta]:cValor
		        
	
			//Converte tipo de dados
			If ::aTabela[nConta]:nTipo == "4"
				cValueS := STOD(cValueS)
			ElseIf ::aTabela[nConta]:nTipo == "5"            
				cValues := Val(cValues)
			ElseIf ::aTabela[nConta]:nTipo == "2"
				If Alltrim(cValues) == "T" .OR. Alltrim(cValues) == ".T."
					cValues := .T.
				Else
					cValues := .F.
				EndIf
			EndIf  	
		    
			//Ajusta valor(caracter especial) de campo de Log, convertendo de formato base 64Bytes para o padrao
			If 'USERLG' $ cField
				cValues := Decode64(cValues)             
			EndIf
	  				  		           
	  		//Valida estrutura emitindo alerta quando nao localizar o campo na base        
	  		If FieldPos(cField) > 0 		
				Replace &(::cTabela + "->" + cField) With cValues	  		  		 
			Else 
				Conout(STR0001, AllTrim(::cTabela) + "->" + AllTrim(cField)) //"LOJA1207 - PROCESSO OFF-LINE: Campo n�o encontrado no dicion�rio local:"
			EndIf
		
			
		Next nConta            
		MsUnLock()
	EndIf
	           	
Return Nil

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �BuscaRecno   �Autor  �Vendas Clientes     � Data �  11/06/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Busca o recno da tabela.      				                 ���
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
Method BuscaRecno() Class LJCInserir

	Local cQuery								//Variavel auxiliar para montar o select
	Local nRecno								//Recno da tabela
	         
	cQuery := "select max(R_E_C_N_O_) RECNO from " + RetSqlName(::cTabela)
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRN", .T., .F. )
	
	dBSelectArea("TRN")
	
	TRN->( dbGoTop() )  

	nRecno := TRN->RECNO
	
	dbCloseArea()
	
	If nRecno == 0
		nRecno := 1
	Else
		nRecno++
	EndIf
	
Return nRecno
