#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXINSTITUICAO.CH"

REGISTER EXTRACTOR HJN

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXInstituicao
Visualiza as informa��es por c�digo ou nome da Institui��o de Ensino 
respons�vel pelo curso. As Institui��es podem ser Internas ou Externas 
� organiza��o, e s�o respons�veis em ministrar os Treinamentos e 
Palestras aos funcion�rios em determinado curso/treinamento.

@author  BI TEAM
@since   06/08/2010
/*/
//-------------------------------------------------------------------
Class BIXInstituicao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXInstituicao
	_Super:New( DIMENSION, "HJN", STR0001, "RA0" ) //"Institui��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXInstituicao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJN_INSTIT" )
	oModel:SetBK( { "HJN_CODIGO" } )

	oModel:AddField( "HJN_INSTIT" , "C", 32, 0 )
	oModel:AddField( "HJN_CODIGO" , "C", 16, 0 )		
	oModel:AddField( "HJN_DESC"   , "C", 100, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXInstituicao
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "RA0_ENTIDA", "RA0_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RA0_ENTIDA", 	(cFlow)->RA0_ENTIDA )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJN_INSTIT" , oKey:GetKey( { (cFlow)->RA0_ENTIDA } ) )		
		oRecord:SetValue( "HJN_CODIGO", (cFlow)->RA0_ENTIDA )
		oRecord:SetValue( "HJN_DESC"  , (cFlow)->RA0_DESC )
		
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
Return nil