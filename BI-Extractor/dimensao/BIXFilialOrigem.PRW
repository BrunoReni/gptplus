#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFILIALORIGEM.CH"

REGISTER EXTRACTOR HO9

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFilialOrigem
Visualzia as informa��es pela filial de origem. A filial de origem � 
a filial de onde parte o transporte de mercadorias.

@author  Valdiney V GOMES
@version P12 
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXFilialOrigem from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXFilialOrigem
	_Super:New( DIMENSION, "HO9", STR0001 ) // "Filial Origem"
Return Self      

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFilialOrigem 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO9_FILORI" )
	oModel:SetBK( { "HO9_CODIGO" } )

	oModel:AddField( "HO9_FILORI", "C", 32, 0 )
	oModel:AddField( "HO9_CODIGO", "C", 12, 0 )
	oModel:AddField( "HO9_NOME"  , "C", 100, 0 )
	
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
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFilialOrigem
	Local aFilOri :=  FwLoadSM0()
	Local nPosFil	:= 0
	
	For nPosFil := 1 to Len(aFilOri) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO9_FILORI", oKey:GetKey( { aFilOri[nPosFil,02] }, , .F. ) ) // C�digo da Filial
		oRecord:SetValue( "HO9_CODIGO", aFilOri[nPosFil,02] ) // C�digo completo da Filial
		oRecord:SetValue( "HO9_NOME"  , aFilOri[nPosFil,07] ) // Nome da Filial
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next nCount	

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
	
	//-------------------------------------------------------------------
	// Mata as vari�veis do tipo array para diminuir o consumo de mem�ria 
	//-------------------------------------------------------------------  		  
	aSize(aFilOri, 0)
	aFilOri := Nil	
	
Return nil