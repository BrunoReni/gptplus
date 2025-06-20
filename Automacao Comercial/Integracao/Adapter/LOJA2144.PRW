#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2144 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCCargaInicialInt�Autor  �Vendas Clientes     � Data �  08/07/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gerar a carga inicial para o EAI         	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCCargaInicialInt
	
	Data oProcessos										// Objeto do tipo LJCEntTabProcInt, entidade dos processos da integracao
	Data cProcessText									// Texto com o processo
	Data nTotal											// Total de processos
	Data cTableText										// Texto com a tabela	
	Data nItemTotal										// Total de tabelas
	Data nSubItemTotal									// Total de registros
	Data nValue											// Processo atual
	Data nItemValue										// Tabela atual
	Data nSubItemValue									// Registro atual
	Data aoObservers									// Array com as classes que observam essa
	Data lCancel
			
	Method New()					                   	// Metodo construtor
	Method Gerar()		    							// Metodo que ira gerar os dados da carga inicial
	Method GetClassInterface()
	Method ProcInt()									// Carrega os processos da integracao
	Method Update()
	Method AddObserver()
	Method Notify()
	Method Cancel()
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  08/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCargaInicialInt.	                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCCargaInicialInt
    
    ::oProcessos := Nil
    
	Self:aoObservers	:= {}    
	Self:nTotal			:= 0
	Self:nItemTotal		:= 0
	Self:nSubItemTotal	:= 0
	Self:nValue			:= 0
	Self:nItemValue		:= 0	
	Self:nSubItemValue	:= 0
	Self:cProcessText	:= ""
	Self:cTableText		:= ""
	
	Self:lCancel		:= .F.
    	
	//Carrega os processos da integracao
	::ProcInt()
	
Return Self  

Method AddObserver( oObserver ) Class LJCCargaInicialInt
	aAdd( Self:aoObservers, oObserver )
Return 

Method Cancel() Class LJCCargaInicialInt
	Self:lCancel := .T.
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  08/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em processar a integracao. Metodo abstrato,     ���
���			 �tem que ser subscrito pelas classes filhos.	          	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar() Class LJCCargaInicialInt

    Local nProcessos	:= 0					// Variavel auxiliar contador dos processos cadastrados
	        
	Self:nTotal := ::oProcessos:Count()
	Self:nValue := 0
	For nProcessos := 1 To ::oProcessos:Count()    		
		
		
		// Verifica se o processo esta habilitado
		If ::oProcessos:Elements(nProcessos):DadosGet("MDO_HABINC") .And. ::oProcessos:Elements(nProcessos):DadosGet("MDO_HABCAR")
			// Carrega a carga do processo
			oCargaFactory := LJCCargaFactory():New()
			oCarga := oCargaFactory:Create( ::oProcessos:Elements(nProcessos):DadosGet("MDO_CODIGO") )
			
			Self:cProcessText := ::oProcessos:Elements(nProcessos):DadosGet("MDO_CODIGO")			
			// Avisa todas as classes que observam essa que algo foi atualizado
			Self:Notify()			
						
			If oCarga != Nil
				// Observa o processamento da carga
				oCarga:AddObserver(Self)			
			
				// Executa a carga
				If !oCarga:Execute()
					Return .F.
				EndIf
			EndIf			
		EndIf
		
		Self:nValue := nProcessos 
		// Avisa todas as classes que observam essa que algo foi atualizado
		Self:Notify()		
		
		// Verifica se foi solicitado o cancelamento do processamento
		If Self:lCancel
			Return .F.
		EndIf
	Next    
    
Return .T.  

Method GetClassInterface() Class LJCCargaInicialInt
Return "LJCCargaInicialInt"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ProcInt   �Autor  �Vendas Clientes     � Data �  08/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar os processos de integracao cadastra ���
���			 �dos na entidade MDO.							          	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ProcInt() Class LJCCargaInicialInt									
    
    Local oProcesso := Nil              //Objeto do tipo LJCRegistrosEntidades com o retorno da consulta
    
    //Instancia o objeto LJCEntProcInt
	oProcesso := LJCEntProcInt():New()
	
	//Consulta pelo indice 1
	::oProcessos := oProcesso:Consultar(1)

Return Nil

Method Update( oSubject ) Class LJCCargaInicialInt
	Self:nItemTotal := oSubject:nTotal
	Self:nItemValue := oSubject:nValue
	Self:cTableText := oSubject:cProgressText
	Self:nSubItemTotal := oSubject:nItemTotal
	Self:nSubItemValue := oSubject:nItemValue
	Self:Notify()   
	
	If Self:lCancel
		oSubject:Cancel()
	EndIf	
Return

Method Notify() Class LJCCargaInicialInt
	Local nCount := 1	// Contador tempor�rio
	
	For nCount := 1 To Len(Self:aoObservers)
		Self:aoObservers[nCount]:Update(Self)
	Next
Return
