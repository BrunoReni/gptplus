#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROVENDA.CH"

REGISTER EXTRACTOR HSN

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProVenda
Visualiza as informa��es por c�digo ou descri��o do processo de venda. 
O processo de venda determina o processo para realizar uma venda de 
determinada organiza��o, contendo etapas sequenciais que determinam 
os passos para completar a venda.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXProVenda from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )     
	Method Flow()	
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXProVenda
	_Super:New( DIMENSION, "HSN", STR0001, "AC2" ) //"Processo de Venda"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXProVenda 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSN_PROVEN" )
	oModel:SetBK( { "HSN_CODIGO" } )

	oModel:AddField( "HSN_PROVEN" , "C", 32, 0 )
	oModel:AddField( "HSN_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSN_DESC"   , "C", 30, 0 )		
	oModel:AddField( "HSN_CODEST" , "C", 10, 0 )		
	oModel:AddField( "HSN_DESEST" , "C", 30, 0 )		
	
	oModel:FreeField() 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

@author  Marcia Junko
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXProVenda
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "AC2_PROVEN", "AC2_STAGE", "AC2_DESCRI", "AC1_DESCRI" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "AC2_PROVEN", (cFlow)->AC2_PROVEN )
		oRecord:SetValue( "AC2_STAGE", (cFlow)->AC2_STAGE )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSN_PROVEN" , oKey:GetKey( { (cFlow)->AC2_PROVEN } ) )		
		oRecord:SetValue( "HSN_CODIGO" , (cFlow)->AC2_PROVEN )
		oRecord:SetValue( "HSN_CODEST"   , (cFlow)->AC2_STAGE )
		oRecord:SetValue( "HSN_DESEST"   , (cFlow)->AC2_DESCRI )
		oRecord:SetValue( "HSN_DESC"   , (cFlow)->AC1_DESCRI )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

		(cFlow)->( DBSkip() ) 
	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
	
	(cFlow)->( DBCloseArea() ) 
Return nil   			

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma �nica tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restri��o na recupera��o de dados no formato {{campo, opera��o, valor}}. 
@return cFlow, Alias tempor�rio. 

@author  Marcia Junko
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXProVenda
	Local cDML	:= ""

	cDML := "SELECT AC2_PROVEN, AC2_STAGE, AC2_DESCRI, AC1_DESCRI " + ;
		"FROM " + RetSqlName("AC2") + " AC2 " + ;
		"LEFT JOIN " + RetSQLName("AC1") + " AC1 " + ;
		"ON AC1_FILIAL = '" + xFilial("AC1") + "' " + ;
			"AND AC1_PROVEN = AC2_PROVEN " + ;
			"AND AC1.D_E_L_E_T_= ' ' " + ;
		"WHERE AC2_FILIAL = '" + xFilial("AC2") + "' " + ;
			"AND AC2.D_E_L_E_T_ = ' '"
	
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )
	
	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cDML ), ::cFlow := GetNextAlias() , .T., .F. )
Return ::cFlow
