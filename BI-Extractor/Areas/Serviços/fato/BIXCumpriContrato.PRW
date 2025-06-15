#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCUMPRICONTRATO.CH"

REGISTER EXTRACTOR HOQ
    
#DEFINE POSTO_COBERTO 		"01"
#DEFINE POSTO_DESCOBERTO    "02"
#DEFINE POSTO_EXCEDIDO      "03"
#DEFINE DIA_NAO_CONTRATADO  "04"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCumpriContrato
O fluxo principal de dados considera as informações dos contratos de 
prestação de serviços com orçamento de serviço ativo 
(TFJ_STATUS = 1, partir de CN9_CONTRT+CN9_REVISA utilizando índice 5). 
Os contratos podem ter tipos de serviços contratados diferentes, 
correspondendo a três subfluxos: materiais de implantação (TFG), 
locação de equipamentos (TFI) e recursos humanos (TFF), gerando para 
cada dia pertencente ao range de datas indicado pelo usuário para a 
extração, um registro na tabela fato (para cada subfluxo). A Data da 
Agenda será o parâmetro chave para determinar as demais informações 
da tabela fato. 

@author  Valdiney V GOMES
@since   02/04/2014
/*/
//-------------------------------------------------------------------
Class BIXCumpriContrato from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCumpriContrato
	_Super:New( FACT, "HOQ", STR0001, "CN9", { SERVICO } ) //Fato Cumprimento de Contrato de Alocação de Recurso
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCumpriContrato
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOQ_EMPRES", "C", 32, 0, .T., "HJ4" ) //Empresa
	oModel:AddField( "HOQ_ESTABL", "C", 32, 0, .T., "HKK" ) //Estabelecimento
	oModel:AddField( "HOQ_SITCON", "C", 32, 0, .T., "HOL" ) //Situação do Contrato
	oModel:AddField( "HOQ_STTPOS", "C", 32, 0, .T., "HOO" ) //Status do Posto
	oModel:AddField( "HOQ_MOEDA" , "C", 32, 0, .T., "HJ6" ) //Moeda	
	oModel:AddField( "HOQ_TIPREC", "C", 32, 0, .T., "HOP" ) //Tipo de Recurso da Prestação de Serviço	
	oModel:AddField( "HOQ_POSTO" , "C", 32, 0, .T., "HOI" ) //Posto  
	oModel:AddField( "HOQ_CONTRA", "C", 32, 0, .T., "HOJ" ) //Contrato
	oModel:AddField( "HOQ_TPCONT", "C", 32, 0, .T., "HON" ) //Tipo de Contrato
	oModel:AddField( "HOQ_CLIENT", "C", 32, 0, .T., "HJ7" ) //Cliente
	oModel:AddField( "HOQ_ITEM"  , "C", 32, 0, .T., "HJ8" ) //Item
	oModel:AddField( "HOQ_UNITEM", "C", 32, 0, .T., "HHW" ) //Unidade de Medida do Item
	oModel:AddField( "HOQ_CARGO" , "C", 32, 0, .T., "HJP" ) //Cargo
	oModel:AddField( "HOQ_TURNO" , "C", 32, 0, .T., "HJU" ) //Turno

	oModel:AddField( "HOQ_DATA"  , "D", 08, 0, .F., "HK2" ) 
	oModel:AddField( "HOQ_DTEXTR", "D", 08, 0 ) 	
	oModel:AddField( "HOQ_SLDCON", "N", 18, 2 )   
	oModel:AddField( "HOQ_QTDCON", "N", 10, 0 ) 
	oModel:AddField( "HOQ_QTDALO", "N", 10, 0 ) 
	oModel:AddField( "HOQ_QITCON", "N", 04, 0 ) 
	oModel:FreeField()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para validação de integridade referencial.

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCumpriContrato
    Local aResource		:= {} 
    Local aMoeda    	:= BIXGetMxF( ::cEntity ) 
    Local dFinish		:= Nil  
    Local dDate			:= Nil
    Local nAllocated	:= 0
    Local nDay			:= 0  
    Local nMoeda		:= 0  
    Local cFilter		:= ""   
    Local cMoeda		:= ""
	Local cFlow			:= ""
	Local cSttPos		:= ""
 
 	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo )

	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
  	While ! (cFlow)->( Eof() )    
  		For nMoeda := 1 To Len( aMoeda ) 
  			cMoeda := aMoeda[nMoeda][1]   

	 		For nDay := StoD( cTo ) - STod( cFrom ) To 0 Step - 1   
	 	   		dDate 	:= ( StoD( cTo ) - nDay )           

	 	  	 	//-------------------------------------------------------------------
				// Identifica se a data de cobertura está dentro da vigência do contrato. 
				//-------------------------------------------------------------------  
				If ( ( dDate < (cFlow)->CN9_DTINIC ) .Or. ( dDate > (cFlow)->CN9_DTFIM ) ) 
			 		Loop    
			   	EndIf  	

	 	  	 	//-------------------------------------------------------------------
				// Itera por todos os postos do contrato. 
				//------------------------------------------------------------------- 
				TFL->( DBSetOrder(2) ) 
	 	 		If ( TFL->( DBSeek( xFilial("TFL") + (cFlow)->TFJ_CODIGO ) ) )      
	 	   			While ( ! TFL->( Eof() ) .And. TFL->TFL_FILIAL == xFilial("TFL") .And. TFL->TFL_CODPAI == (cFlow)->TFJ_CODIGO ) 

		 	   			//-------------------------------------------------------------------
						// Materiais de Implantação (TFG)
						//-------------------------------------------------------------------     
						TFF->( DBSetOrder(3) ) 
		 	   			If ( TFF->( DBSeek( xFilial("TFF") + TFL->TFL_CODIGO ) ) )  

		 	   				TFG->( DBSetOrder(3) ) 
			  	   			If ( TFG->( DBSeek( xFilial("TFG") + TFF->TFF_COD  ) ) )  
								cSttPos := ""

								//-------------------------------------------------------------------
								// Grava o Status do Posto. 
								//-------------------------------------------------------------------  
								If ( TFG->TFG_QTDVEN == nAllocated )
									cSttPos	:= POSTO_COBERTO 
								ElseIf( TFG->TFG_QTDVEN > nAllocated )
									cSttPos	:= POSTO_DESCOBERTO 
								ElseIf( TFG->TFG_QTDVEN < nAllocated )   
									cSttPos	:= POSTO_EXCEDIDO  
								EndIf 

								While ( ! TFG->( Eof() ) .And. TFG->TFG_FILIAL == xFilial("TFG") .And. TFG->TFG_CODPAI == TFF->TFF_COD ) 
									//-------------------------------------------------------------------
									// Inicializa o registro. 
									//------------------------------------------------------------------- 				
									oRecord:Init()
					
									//-------------------------------------------------------------------
									// Customização.
									//------------------------------------------------------------------- 
									oRecord:SetValue( "CN9_NUMERO"		, (cFlow)->CN9_NUMERO )
									oRecord:SetValue( "CN9_REVISA"		, (cFlow)->CN9_REVISA )
									oRecord:SetValue( "CN1_CODIGO"		, (cFlow)->CN9_TPCTO )
									oRecord:SetValue( "A1_COD"			, (cFlow)->TFJ_CODENT )
									oRecord:SetValue( "A1_LOJA"			, (cFlow)->TFJ_LOJA )
									oRecord:SetValue( "B1_COD"			, TFG->TFG_PRODUT )
									oRecord:SetValue( "AH_UNIMED"		, TFG->TFG_UM )
									oRecord:SetValue( "ABS_LOCAL"		, TFL->TFL_LOCAL )
									
									//-------------------------------------------------------------------
									// Lookups.
									//------------------------------------------------------------------- 
									oRecord:SetValue( "HOQ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )  
									oRecord:SetValue( "HOQ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
									oRecord:SetValue( "HOQ_POSTO" , oSeeker:Seek( "HOI", { TFL->TFL_LOCAL } ) ) 
									oRecord:SetValue( "HOQ_CONTRA", oSeeker:Seek( "HOJ", { (cFlow)->CN9_NUMERO	, (cFlow)->CN9_REVISA } ) ) 
									oRecord:SetValue( "HOQ_TPCONT", oSeeker:Seek( "HON", { (cFlow)->CN9_TPCTO } ) ) 
									oRecord:SetValue( "HOQ_CLIENT", oSeeker:Seek( "HJ7", { (cFlow)->TFJ_CODENT, (cFlow)->TFJ_LOJA } ) ) 
									oRecord:SetValue( "HOQ_ITEM"  , oSeeker:Seek( "HJ8", { TFG->TFG_PRODUT } ) ) 
									oRecord:SetValue( "HOQ_UNITEM", oSeeker:Seek( "HHW", { TFG->TFG_UM } ) ) 
									oRecord:SetValue( "HOQ_STTPOS", oSeeker:Seek( "HOO", { cSttPos } ) )  
									oRecord:SetValue( "HOQ_MOEDA" , oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )  
									oRecord:SetValue( "HOQ_TIPREC", oSeeker:Seek( "HOP", { "03" } ) ) 
									oRecord:SetValue( "HOQ_SITCON", oSeeker:Seek( "HOL", { (cFlow)->CN9_SITUAC } ) )  
									oRecord:SetValue( "HOQ_CARGO" , oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
									oRecord:SetValue( "HOQ_TURNO" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
									
									//-------------------------------------------------------------------
									// Indicadores.
									//------------------------------------------------------------------- 			
						 			oRecord:SetValue( "HOQ_QITCON", 1 )
						 			
									//-------------------------------------------------------------------
									// Grava a Quantidade Contratada. 
									//-------------------------------------------------------------------		
						 			oRecord:SetValue( "HOQ_QTDCON", TFG->TFG_QTDVEN )
						 			
					 				//-------------------------------------------------------------------
									// Grava o Saldo do Contrato. 
									//-------------------------------------------------------------------			
						 			oRecord:SetValue( "HOQ_SLDCON", BIXValue( (cFlow)->CN9_SALDO, (cFlow)->CN9_MOEDA, cMoeda, dDate) )  
		
							 		//-------------------------------------------------------------------
									// Grava a Quantidade Alocada. 
									//-------------------------------------------------------------------
									cFilter 	:= "TFS_CODTFG == '" + TFG->TFG_COD + "'.AND. TFS_FILIAL == '" + xFilial("TFS") +  "'"
							  		nAllocated 	:= 0 
							  		
							  		TFS->( DBSetFilter ( {|| &cFilter }, cFilter ) )  
							  		TFS->( dbGoTop() )  
							  		
						 			While ( ! TFS->( Eof() )  )   
						 				//-------------------------------------------------------------------
										// Somatório de todos TFS_QUANT a partir de TFG_COD relacionado com 
										// TFS_CODTFG até a data da agenda analisada. 
										//-------------------------------------------------------------------
						 				nAllocated	+= TFS->TFS_QUANT 
						 		   		TFS->( DBSkip() ) 		
						 			EndDo
					                                                      
					                TFS->( DBClearFilter() )                      
					                                       
	         						oRecord:SetValue( "HOQ_QTDALO", nAllocated )
	
									
						 			//-------------------------------------------------------------------
									// Grava a Data de Cobertura. 
									//------------------------------------------------------------------- 				 			
						 			oRecord:SetValue( "HOQ_DATA", dDate )
						 			oRecord:SetValue( "HOQ_DTEXTR", dToday )						 			
									
									//-------------------------------------------------------------------
									// Envia o registro para o pool de gravação. 
									//-------------------------------------------------------------------				
									oOutput:Send( oRecord ) 
							
			 	    	    		TFG->( DBSkip() ) 
			               		EndDo
			 	   			EndIf  
		 	   			EndIf 
		 	   			
		 	   	 		//-------------------------------------------------------------------
						// Locação de Equipamentos (TFI)
						//------------------------------------------------------------------- 		
		 	  			TFI->( DBSetOrder(3) ) 
		 	   			If ( TFI->( DBSeek( xFilial("TFI") + TFL->TFL_CODIGO ) ) )   
		         			While ( ! TFI->( Eof() ) .And. TFI->TFI_FILIAL == xFilial("TFI") .And. TFI->TFI_CODPAI == TFL->TFL_CODIGO ) 
			
						   		TEV->( DBSetOrder(2) ) 
		 	   					If ( TEV->( DBSeek( xFilial("TEV") + TFI->TFI_COD ) ) )
									If ( TEV->TEV_MODCOB == '2' )
										cSttPos := ""
										nAllocated 	:= 0
										
										If ( TFI->TFI_QTDVEN == nAllocated )
											cSttPos	:= POSTO_COBERTO  
										ElseIf( TFI->TFI_QTDVEN > nAllocated )
											cSttPos := POSTO_DESCOBERTO     
										ElseIf( TFI->TFI_QTDVEN < nAllocated )   
											cSttPos	:= POSTO_EXCEDIDO        
										EndIf 		

								   		TEW->( DBSetOrder(7) ) 
				 	   					If ( TEW->( DBSeek( xFilial("TEW") + TFI->TFI_COD ) ) )  
					 	   					While ( ! TEW->( Eof() ) .And. TEW->TEW_FILIAL == xFilial("TEW") .And. TEW->TEW_CODEQU == TFI->TFI_COD ) 
			                                  	//-------------------------------------------------------------------
			                                  	// Contagem de todos os registros retornados de TEW a partir de TFI_COD 
			                                  	// utilizando índice 7, desde que a data da agenda encontre-se entre 
			                                  	// TEW_DTRINI e a Data Final da Alocação do Equipamento. Para determinar 
			                                  	// a Data Final da Alocação do Equipamento deve-se seguir a seguinte regra: 
			                                  	// Caso TEW_DTAMNT esteja preenchida, esta é a Data Final de Alocação do 
			                                  	// Equipamento. Caso TEW_DTAMNT não esteja preenchida mas TEW_DTRFIM esteja 
			                                  	// preenchida, TEW_DTRFIM será a Data Final de Alocação do Equipamento. 
			                                  	// Caso nenhuma destas datas esteja preenchida, deve-se considerar que a Data 
			                                  	// Final de Alocação do Equipamento é a data em que a agenda está sendo verificada.
			            						//-------------------------------------------------------------------  	
			                                  	If ( dDate >= TEW->TEW_DTRINI )
			                                  		If ( ! Empty( TEW->TEW_DTAMNT ) )
			                                        	dFinish := TEW->TEW_DTAMNT 
			                                      	ElseIf ( ! Empty( TEW->TEW_DTRFIM  ) ) 
			                                      	 	dFinish := TEW->TEW_DTRFIM    
			                                      	Else 
			                                      		dFinish := dDate
			                                      	EndIf   
			                                      	
			                                      	If ( dDate <= dFinish )
			                                      		 nAllocated += 1
			                                      	EndIf                                  		                              	
			                                  	EndIf 
		
								 		   		TEW->( DBSkip() ) 		
								 			EndDo	  
				 	   					EndIf   

										//-------------------------------------------------------------------
										// Inicializa o registro. 
										//------------------------------------------------------------------- 				
										oRecord:Init()
										
										//-------------------------------------------------------------------
										// Customização.
										//------------------------------------------------------------------- 
										oRecord:SetValue( "CN9_NUMERO"		, (cFlow)->CN9_NUMERO )
										oRecord:SetValue( "CN9_REVISA"		, (cFlow)->CN9_REVISA )
										oRecord:SetValue( "CN1_CODIGO"		, (cFlow)->CN9_TPCTO )
										oRecord:SetValue( "A1_COD"			, (cFlow)->TFJ_CODENT )
										oRecord:SetValue( "A1_LOJA"			, (cFlow)->TFJ_LOJA )
										oRecord:SetValue( "B1_COD"			, TFI->TFI_PRODUT )
										oRecord:SetValue( "ABS_LOCAL"		, TFL->TFL_LOCAL )										
							
										//-------------------------------------------------------------------
										// Lookups.
										//------------------------------------------------------------------- 
										oRecord:SetValue( "HOQ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )  
										oRecord:SetValue( "HOQ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
										oRecord:SetValue( "HOQ_POSTO" , oSeeker:Seek( "HOI", { TFL->TFL_LOCAL } ) ) 
										oRecord:SetValue( "HOQ_CONTRA", oSeeker:Seek( "HOJ", { (cFlow)->CN9_NUMERO	, (cFlow)->CN9_REVISA } ) ) 
										oRecord:SetValue( "HOQ_TPCONT", oSeeker:Seek( "HON", { (cFlow)->CN9_TPCTO } ) ) 
										oRecord:SetValue( "HOQ_CLIENT", oSeeker:Seek( "HJ7", { (cFlow)->TFJ_CODENT, (cFlow)->TFJ_LOJA } ) ) 
										oRecord:SetValue( "HOQ_ITEM"  , oSeeker:Seek( "HJ8", { TFI->TFI_PRODUT } ) ) 
										oRecord:SetValue( "HOQ_SITCON", oSeeker:Seek( "HOL", { (cFlow)->CN9_SITUAC } ) )  
										oRecord:SetValue( "HOQ_TIPREC", oSeeker:Seek( "HOP", { "02" } ) ) 
										oRecord:SetValue( "HOQ_MOEDA" , oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )  
										oRecord:SetValue( "HOQ_STTPOS", oSeeker:Seek( "HOO", { cSttPos } ) )  
										oRecord:SetValue( "HOQ_CARGO" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
										oRecord:SetValue( "HOQ_TURNO" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
										oRecord:SetValue( "HOQ_UNITEM", oSeeker:oKey:GetKey( { UNDEFINED } ) )

										//-------------------------------------------------------------------
										// Indicadores.
										//------------------------------------------------------------------- 			
							 			oRecord:SetValue( "HOQ_QITCON", 1 )
							 			oRecord:SetValue( "HOQ_QTDCON", TFI->TFI_QTDVEN )
							 			oRecord:SetValue( "HOQ_SLDCON", BIXValue( (cFlow)->CN9_SALDO, (cFlow)->CN9_MOEDA, cMoeda, dDate) )
				 	   					oRecord:SetValue( "HOQ_QTDALO" , nAllocated )
							 			oRecord:SetValue( "HOQ_DATA", dDate )
							 			oRecord:SetValue( "HOQ_DTEXTR", dToday )	
		 	   					 	
										//-------------------------------------------------------------------
										// Envia o registro para o pool de gravação. 
										//-------------------------------------------------------------------				
										oOutput:Send( oRecord ) 
									EndIf 
		 	   					EndIf   		            	
		
		 	    	    		TFI->( DBSkip() ) 
		               		EndDo 
		 	   			EndIf 			
		
			   	 		//-------------------------------------------------------------------
						// Recursos Humanos (TFF)
						//------------------------------------------------------------------- 		
		 	  			TFF->( DBSetOrder(3) ) 
		 	   			If ( TFF->( DBSeek( xFilial("TFF") + TFL->TFL_CODIGO ) ) )   
		         			While ( ! TFF->( Eof() ) .And. TFF->TFF_FILIAL == xFilial("TFF") .And. TFF->TFF_CODPAI == TFL->TFL_CODIGO ) 
								nAllocated	:= 0  
								lEngaged	:= .T. 
								aResource	:= {}
								cSttPos 	:= ""

								If ( lEngaged )
									If ( TFF->TFF_QTDVEN == nAllocated )
										cSttPos	:= POSTO_COBERTO  
									ElseIf( TFF->TFF_QTDVEN > nAllocated )
										cSttPos	:= POSTO_DESCOBERTO     
									ElseIf( TFF->TFF_QTDVEN < nAllocated )   
										cSttPos	:= POSTO_EXCEDIDO        
									EndIf  
								Else
								 	cSttPos	:= DIA_NAO_CONTRATADO    
								EndIf
								
								cFilter := "ABQ_FILIAL == '" + xFilial("ABQ") + "'.AND. ABQ_CODTFF  == '" + TFF->TFF_COD +  "'"
						  		ABQ->( DBSetFilter ( {|| &cFilter }, cFilter ) )  
						  		ABQ->( dbGoTop() )  	
									               
								If ! ( ABQ->( Eof() ) )   
									//-------------------------------------------------------------------
									// Deve-se realizar a contagem de todos os registros retornados através 
									// do relacionamento entre ABB_IDCFAL e ABQ_CONTRT + ABQ_ITEM + ABQ_ORIGEM, 
									// a partir do relacionamento entre ABQ_CODTFF e TFF_COD...
									//-------------------------------------------------------------------
									cFilter := "ABB_FILIAL == '" + xFilial("ABB") + "'.AND. ABB_IDCFAL  == '" + ABQ->ABQ_CONTRT + ABQ->ABQ_ITEM + ABQ->ABQ_ORIGEM + "'"		 			         	        
							  		ABB->( DBSetFilter ( {|| &cFilter }, cFilter ) )  
							  		ABB->( dbGoTop() )  
							  		
						 			While ( ! ABB->( Eof() )  )   
						 			    //-------------------------------------------------------------------
						 			    // ...desde que a data da agenda encontre-se entre ABB_DTINI e ABB_DTFIM 
						 			    // e a agenda esteja ativa (ABB_ATIVO=1).   
						 			    //-------------------------------------------------------------------
	         							If ( ( dDate >= ABB->ABB_DTINI ) .And. ( dDate <= ABB->ABB_DTFIM ) .And. ( ABB->ABB_ATIVO == "1" ) ) 
	    									lEngaged := TxDiaTrab( dDate, ABQ->ABQ_TURNO )
	    									
	    									If ( lEngaged ) 
		    									If ( aScan( aResource, { |x| x[1] == ABB->ABB_CODTEC .And. x[2] == ABB->ABB_IDCFAL .And. x[3] == ABB->ABB_DTINI } ) == 0 )
		    										aAdd( aResource, { ABB->ABB_CODTEC, ABB->ABB_IDCFAL, ABB->ABB_DTINI } ) 
		    										nAllocated += 1 
		    									EndIf 
	                                 		EndIf 
				 		    		   	EndIf 
						 		   		ABB->( DBSkip() ) 		
						 			EndDo
						 			
						 		 	ABB->( DBClearFilter() )	  
								EndIf 
								
								ABQ->( DBClearFilter() )  


								//-------------------------------------------------------------------
								// Inicializa o registro. 
								//------------------------------------------------------------------- 				
								oRecord:Init()
								
								//-------------------------------------------------------------------
								// Customização.
								//------------------------------------------------------------------- 
								oRecord:SetValue( "CN9_NUMERO"		, (cFlow)->CN9_NUMERO )
								oRecord:SetValue( "CN9_REVISA"		, (cFlow)->CN9_REVISA )
								oRecord:SetValue( "CN1_CODIGO"		, (cFlow)->CN9_TPCTO )
								oRecord:SetValue( "A1_COD"			, (cFlow)->TFJ_CODENT )
								oRecord:SetValue( "A1_LOJA"			, (cFlow)->TFJ_LOJA )
								oRecord:SetValue( "B1_COD"			, TFF->TFF_PRODUT )
								oRecord:SetValue( "AH_UNIMED"		, TFF->TFF_UM )
								oRecord:SetValue( "R6_TURNO"		, TFF->TFF_TURNO )
								oRecord:SetValue( "RJ_FUNCAO"		, TFF->TFF_FUNCAO  )
								oRecord:SetValue( "ABS_LOCAL"		, TFL->TFL_LOCAL )								
					
								//-------------------------------------------------------------------
								// Lookups.
								//------------------------------------------------------------------- 
								oRecord:SetValue( "HOQ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )  
								oRecord:SetValue( "HOQ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
								oRecord:SetValue( "HOQ_POSTO" , oSeeker:Seek( "HOI", { TFL->TFL_LOCAL } ) ) 
								oRecord:SetValue( "HOQ_CONTRA", oSeeker:Seek( "HOJ", { (cFlow)->CN9_NUMERO	, (cFlow)->CN9_REVISA } ) ) 
								oRecord:SetValue( "HOQ_TPCONT", oSeeker:Seek( "HON", { (cFlow)->CN9_TPCTO } ) ) 
								oRecord:SetValue( "HOQ_CLIENT", oSeeker:Seek( "HJ7", { (cFlow)->TFJ_CODENT, (cFlow)->TFJ_LOJA } ) ) 
								oRecord:SetValue( "HOQ_ITEM"  , oSeeker:Seek( "HJ8", { TFF->TFF_PRODUT } ) ) 
								oRecord:SetValue( "HOQ_SITCON", oSeeker:Seek( "HOL", { (cFlow)->CN9_SITUAC } ) )  
								oRecord:SetValue( "HOQ_TIPREC", oSeeker:Seek( "HOP", { "01" } ) ) 
								oRecord:SetValue( "HOQ_MOEDA" , oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )  
								oRecord:SetValue( "HOQ_STTPOS", oSeeker:Seek( "HOO", { cSttPos } ) )  
								oRecord:SetValue( "HOQ_CARGO" , oSeeker:Seek( "HJP", { TFF->TFF_FUNCAO } ) )
								oRecord:SetValue( "HOQ_TURNO" , oSeeker:Seek( "HJU", { TFF->TFF_TURNO } ) ) 
								oRecord:SetValue( "HOQ_UNITEM", oSeeker:Seek( "HHW", { TFF->TFF_UM } ) ) 

								//-------------------------------------------------------------------
								// Indicadores.
								//------------------------------------------------------------------- 			
					 			oRecord:SetValue( "HOQ_QITCON", 1 )
					 			oRecord:SetValue( "HOQ_QTDCON", TFF->TFF_QTDVEN )
					 			oRecord:SetValue( "HOQ_SLDCON", BIXValue( (cFlow)->CN9_SALDO, (cFlow)->CN9_MOEDA, cMoeda, dDate) )  // Grava o Saldo do Contrato. 
								oRecord:SetValue( "HOQ_QTDALO", nAllocated )// Grava a Quantidade Alocada.     
					 			oRecord:SetValue( "HOQ_DATA", dDate )
					 			oRecord:SetValue( "HOQ_DTEXTR", dToday )	
		 
								//-------------------------------------------------------------------
								// Envia o registro para o pool de gravação. 
								//-------------------------------------------------------------------				
								oOutput:Send( oRecord ) 
		 
		 	    	    		TFF->( DBSkip() ) 
		               		EndDo 
		 	   			EndIf     
	 	    			TFL->( DBSkip() ) 
	 	    	    EndDo 
	 	    	EndIf  		 
	 		Next nDay 
	 	Next nMoeda 	
	 	
 		(cFlow)->( DBSkip() ) 
 	EndDo 

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()
	
 	//-------------------------------------------------------------------
	// Fecha a área de trabalho temporária. 
	//-------------------------------------------------------------------  		  
 	If ! ( Select( cFlow ) == 0 )
 		( cFlow )->( DBCloseArea() ) 
 	EndIf 		
return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma única tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Período inicial de extração.
@param cTo, caracter, Período final de extração.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restrição na recuperação de dados no formato {{campo, operação, valor}}. 
@return cFlow, Alias temporário. 

@author  Marcia Junko
@since   28/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCumpriContrato
	Local cDML 	:= ""  
       
	cDML += " SELECT" 
	cDML += " 		CN9.CN9_NUMERO," 
	cDML += " 		CN9.CN9_REVISA," 
	cDML += " 		CN9.CN9_SITUAC," 
	cDML += " 		CN9.CN9_TPCTO," 
	cDML += " 		CN9.CN9_SALDO," 
	cDML += " 		CN9.CN9_MOEDA," 
	cDML += " 		CN9.CN9_DTINIC," 
	cDML += " 		CN9.CN9_DTFIM," 
	cDML += " 		TFJ.TFJ_CODIGO," 
	cDML += " 		TFJ.TFJ_CODENT," 
	cDML += " 		TFJ.TFJ_LOJA" 
	cDML += " FROM " + RetSQLName("CN9") + " CN9"
	cDML += " INNER JOIN " + RetSQLName("TFJ") + " TFJ"
	cDML += " ON" 
	cDML += "		TFJ.TFJ_CONTRT = CN9.CN9_NUMERO"
	cDML += "		AND"
	cDML += "		TFJ.TFJ_CONREV = CN9.CN9_REVISA" 
	cDML += "		AND" 
	cDML += "		TFJ.TFJ_STATUS = '1'"  
	cDML += "		AND" 
	cDML += "		CN9.CN9_FILIAL = '" + xFilial("CN9") + "'"  
	cDML += "		AND" 
	cDML += "	   	CN9.D_E_L_E_T_ = ' '"  
	cDML += "		AND" 
	cDML += "		TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "'"         
	cDML += "		AND" 
	cDML += "	   	TFJ.D_E_L_E_T_ = ' '"  	 	 

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//-------------------------------------------------------------------  	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)  
	
	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "CN9_DTINIC"	, "D", 8, 0 )   
	TcSetField( ::cFlow, "CN9_DTFIM"	, "D", 8, 0 )     

Return ::cFlow