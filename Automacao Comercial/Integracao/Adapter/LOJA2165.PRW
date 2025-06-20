#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2165 ; Return	// "dummy" function - Internal Use

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCCargaGenerica      �Autor  �Vendas Clientes     � Data �28/09/09 ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe com funcionalidade de carga gen�rica de 1 entidade.          ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCCargaGenerica From LJACarga
	Data cProcess		// Processa que da carga a ser efetuada
	
	Method New()
	Method Execute()
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCargaGenerica.                      ���
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
Method New( cProcess ) Class LJCCargaGenerica
	Self:cProcess := cProcess
	_Super:New()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Execute   �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa a carga inicial dos processos e tabelas cadastrados ���
���          �na tabela MDP, MDO.                                         ���
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
Method Execute() Class LJCCargaGenerica
	Local oProcTables		:= Nil
	Local oTables			:= Nil
	Local nTabela			:= 0
	Local cTable			:= ""
	Local oEntidadeFactory	:= Nil
	Local oEntidade			:= Nil
	Local oAdapterFactory	:= Nil
	Local oIndice			:= Nil	
	Local oIndices			:= Nil	
	Local nCount			:= 0
	Local oAdapter			:= Nil
	Local cChave			:= ""
	Local oRecords			:= Nil	
	
	// Consulta as tabelas do processo
	oProcTables := LJCEntTabProcInt():New()  
	oProcTables:DadosSet( "MDP_PROCES", Self:cProcess )
	oTables := oProcTables:Consultar( 1 )
	
	Self:nTotal := oTables:Count()
	Self:nValue := 0
	
	For nTabela := 1 To oTables:Count()

		// Pega a tabela em processo
		cTable := oTables:Elements(nTabela):DadosGet("MDP_TABELA")
		
		Self:cProgressText := cTable
		
		// Avisa todas as classes que observam essa, que algo foi atualizado
		Self:Notify()						

		// Pega a classe de manuseio da tabela
		oEntidadeFactory := LJCEntidadeFactory():New()
		oEntidade := oEntidadeFactory:Create( cTable )
		
		If oEntidade != NIL
			oRecords	:= oEntidade:Consultar(1)		
			
			// Monta a chave prim�ria		
			oIndices	:= oEntidade:Indices()		
			oIndice		:= oIndices:Elements(1)
			cChave := ""
			For nCount := 1 To oIndice:Campos():Count()
				cChave += "oRecords:Elements(nCount):DadosGet(oIndice:Campos():Elements(" + AllTrim(Str(nCount)) + "))" + If(nCount == oIndice:Campos():Count(), "", "+")
			Next		
			cChave := "Eval({||" + cChave + "})"
			
			Self:nItemTotal := oRecords:Count()
			Self:nItemValue := 0
			// Avisa todas as classes que observam essa, que algo foi atualizado
			Self:Notify()			
			
			// Para cada registro
			For nCount := 1 To oRecords:Count()

				
				// Cria o adaptador de envio utilizando o factory para isso
				oAdapterFactory := LJCAdapXmlEnvFactory():New()
				oAdapter := oAdapterFactory:Create( cTable )
				
				// Todo: Precisa tirar, pois fiz s� para facilitar o teste
				If cTable == "SX5" .And.;
					!( ;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "V0" .Or.;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "T2" .Or.;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "24" .Or.;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "12" ;
					)
					Loop
				EndIf
				
				// Insere os registros no adapter e envia pro EAI.
				If oAdapter != NIL			
					//Insere os dados da carga
					oAdapter:Inserir( cTable, &cChave , "1", _INCLUSAO)
					//Gera carga
					oAdapter:Gerar()
					//Finaliza carga
					oAdapter:Finalizar()					
				EndIf 
				
				If Self:lCancel
					Return .F.
				EndIf
				
				Self:nItemValue := nCount  
				// Avisa todas as classes que observam essa, que algo foi atualizado
				Self:Notify()								
				
			Next    
			
			Self:nItemTotal := 0
			Self:nItemValue := 0
			// Avisa todas as classes que observam essa, que algo foi atualizado			
			Self:Notify()							
		EndIf 
		
		Self:nValue := nTabela 
		// Avisa todas as classes que observam essa, que algo foi atualizado			
		Self:Notify()											 
	Next
	Self:nTotal := 0
	Self:nValue	:= 0
	// Avisa todas as classes que observam essa, que algo foi atualizado				
	Self:Notify()
Return .T.