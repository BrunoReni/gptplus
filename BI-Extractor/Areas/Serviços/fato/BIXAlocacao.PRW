#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXALOCACAO.CH"

REGISTER EXTRACTOR HOR

#DEFINE ALOCADO	"01"
#DEFINE OCIOSO	"02"
#DEFINE FOLGA 	"03"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAlocacao
O fluxo principal de dados considera as informações dos atendente (AA1), 
gerando para cada dia pertencente ao range de datas indicado pelo usuário 
para a extração, um registro na tabela fato. O Atendente e a Data da Agenda 
serão os parâmetros chaves para determinar as demais informações da tabela fato.

@author  Valdiney V GOMES
@since   31/03/2014
/*/
//-------------------------------------------------------------------
Class BIXAlocacao from BIXEntity
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
Method New() Class BIXAlocacao
	_Super:New( FACT, "HOR", STR0001, "AA1", { SERVICO } ) // Alocação de Atendentes
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXAlocacao
	Local oModel := BIXModel():Build( Self )
 
	oModel:AddField( "HOR_EMPRES", "C", 32, 0, .T., "HJ4" ) //Empresa
	oModel:AddField( "HOR_ESTABL", "C", 32, 0, .T., "HKK" ) //Estabelecimento
	oModel:AddField( "HOR_SITATE", "C", 32, 0, .T., "HOM" ) //Situação do Atendente
	oModel:AddField( "HOR_ATENDE", "C", 32, 0, .T., "HOH" ) //Atendente  
	oModel:AddField( "HOR_CCUSTO", "C", 32, 0, .T., "HJ5" ) //Centro de Custo
	oModel:AddField( "HOR_TURNO" , "C", 32, 0, .T., "HJU" ) //Turno
	oModel:AddField( "HOR_CARGO" , "C", 32, 0, .T., "HJP" ) //Cargo
	  
	oModel:AddField( "HOR_DATA"  	, "D", 8, 0, .F., "HK2" ) 
	oModel:AddField( "HOR_DTEXTR"  	, "D", 8, 0 ) 
	oModel:AddField( "HOR_QTDAGE"  	, "N", 4, 0 ) 
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXAlocacao
	Local cCostCenter 	:= ''
	Local cShift   		:= ''
	Local cJob 			:= ''  
	Local cSequence		:= Nil 
	Local dDate			:= Nil 
	Local dAdmission	:= Nil 
	Local dDismiss   	:= Nil 
    Local nDay			:= 0   
    Local lAllocated	:= .F. 
	
	Local cFlow			:= ""
	Local cSitAte		:= ""

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo )
	
	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! ( cFlow )->( Eof() )   	  
 	   	cCostCenter := (cFlow)->AA1_CC
 	 	cShift 		:= (cFlow)->AA1_TURNO 
 	 	cJob 		:= (cFlow)->AA1_FUNCAO 
 	 	cSequence  	:= Nil
 	 	dAdmission	:= Nil
 	 	dDismiss	:= Date()   	
 	        
 	 	//-------------------------------------------------------------------
		// Para o preenchimento dos campos de dimensões Centro de Custo, Turno 
		// e Cargo é necessário verificar o preenchimento do campo AA1_CDFUNC. 
		// Caso o campo esteja com o código do funcionário devidamente cadastrado, 
		// utiliza-se os campos de dimensões vindos da tabela SRA. 
		//------------------------------------------------------------------- 
 	   	If ! ( Empty( ( cFlow )->AA1_CDFUNC ) )
 	   		If ( SRA->( MsSeek( ( cFlow )->AA1_FUNFIL + ( cFlow )->AA1_CDFUNC ) ) )   		 
 	   		 	cCostCenter	:= SRA->RA_CC 
	 	   		cShift 	   	:= SRA->RA_TNOTRAB 
	 	   		cJob		:= SRA->RA_CODFUNC 	
	 	   		cSequence	:= SRA->RA_SEQTURN  
	 	   		dAdmission	:= SRA->RA_ADMISSA 
				dDismiss	:= If ( Empty( SRA->RA_DEMISSA ), Date(), SRA->RA_DEMISSA )     
 	   		EndIf    
 	   	EndIf   

 	 	//-------------------------------------------------------------------
		// Itera pelos registros do subfluxo. 
		//------------------------------------------------------------------- 
 		For nDay := StoD( cTo ) - STod( cFrom ) To 0 Step - 1  
 			dDate 		:= ( StoD( cTo ) - nDay ) 
 			lAllocated 	:= .F. 
			cSitAte		:= ""
          
	 	 	//-------------------------------------------------------------------
			// Identifica se o atendente é funcionário na data da agenda. 
			//-------------------------------------------------------------------  
			If ( ( ! ( dAdmission == Nil ) .And. dDate < dAdmission ) .Or. ( dDate > dDismiss ) ) 
		 		Loop    
		   	EndIf 		

            //-------------------------------------------------------------------
			// Grava a Situação do Atendente. 
			//-------------------------------------------------------------------              
 			If ( TxDiaTrab( dDate, cShift, cSequence ) )   
 		    	If ( ABB->( MsSeek( xFilial("ABB") + (cFlow)->AA1_CODTEC  + DToS( dDate ) ) ) )   		 
 		    		While ! ABB->( Eof() ) .And. ( ABB->ABB_FILIAL == xFilial("ABB") )  .And. ( ABB->ABB_CODTEC == (cFlow)->AA1_CODTEC ) 
 		    			//------------------------------------------------------------------- 
 		    			// Verifica se o atendente possui agenda para a data da agenda analisada. 
 		    			// Esta verificação deve ser realizada identificando a data da agenda entre 
 		    			// as datas ABB_DTINI e ABB_DTFIM de agendas ativas (ABB_ATIVO = 1).
 		    		 	//------------------------------------------------------------------- 
 		    		   	If ( ( dDate >= ABB->ABB_DTINI ) .And. ( dDate <= ABB->ABB_DTFIM ) .And. ( ABB->ABB_ATIVO == "1" ) )    
 		    		   		lAllocated := .T. 
							Exit  
 		    		   	EndIf 
 		    		   	  
 		    	   		ABB->( DBSkip() )		
 		    		EndDo 		    	
 		    	EndIf 		                     
				                
				cSitAte := If ( lAllocated, ALOCADO, OCIOSO )
 		 	Else
 		 		cSitAte := FOLGA
 			EndIf 
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "AA1_CODTEC"		, (cFlow)->AA1_CODTEC )
			oRecord:SetValue( "CTT_CUSTO"		, cCostCenter )
			oRecord:SetValue( "R6_TURNO"		, cShift )
			oRecord:SetValue( "RJ_FUNCAO"		, cJob )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HOR_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HOR_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HOR_SITATE", oSeeker:Seek( "HOM", { cSitAte } ) ) 
			oRecord:SetValue( "HOR_ATENDE", oSeeker:Seek( "HOH", { (cFlow)->AA1_CODTEC } ) ) 
			oRecord:SetValue( "HOR_CCUSTO", oSeeker:Seek( "HJ5", { cCostCenter } ) ) 
			oRecord:SetValue( "HOR_TURNO" , oSeeker:Seek( "HJU", { cShift } ) ) 
			oRecord:SetValue( "HOR_CARGO" , oSeeker:Seek( "HJP", { cJob } ) ) 
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
 			oRecord:SetValue( "HOR_DATA",	dDate )		// Grava a Data da Agenda.
 			oRecord:SetValue( "HOR_DTEXTR", dToday)	  
 			oRecord:SetValue( "HOR_QTDAGE", 1 )		// Grava a Quantidade. 

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
 		Next nDay
 		( cFlow )->( DBSkip() ) 
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
return   

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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXAlocacao
	Local cDML 	:= ""  

	cDML += " SELECT" 
	cDML += " 		AA1.AA1_CC,"
	cDML += " 		AA1.AA1_TURNO,"   
	cDML += " 		AA1.AA1_FUNCAO,"   
	cDML += " 		AA1.AA1_CODTEC,"  
	cDML += " 		AA1.AA1_FUNFIL,"  
	cDML += " 		AA1.AA1_CDFUNC"   
	cDML += " FROM " + RetSQLName("AA1") + " AA1"
	cDML += " WHERE 
	cDML += "		AA1.AA1_FILIAL = '" + xFilial("AA1") + "'"         
	cDML += "		AND" 
	cDML += "	   	AA1.D_E_L_E_T_ = ' '"   	 	 

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias(), .T., .F. )  

Return ::cFlow