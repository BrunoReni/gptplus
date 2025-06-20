#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOLABORADOR.CH"

REGISTER EXTRACTOR HJM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXColaborador
As informa��es s�o visualizadas por c�digo ou nome do Cliente. 

@author  Helio Leal
@since   05/06/2017
/*/
//-------------------------------------------------------------------
Class BIXColaborador from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   05/06/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXColaborador
	_Super:New( DIMENSION, "HJM", STR0009, "SRA" ) //"Cliente"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   05/06/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXColaborador 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJM_COLABR" )
	oModel:SetBK( { "HJM_CODIGO" } )

	oModel:AddField( "HJM_COLABR" , "C", 32, 0 )
	oModel:AddField( "HJM_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HJM_PNECES", "C", 01, 0 )		
	oModel:AddField( "HJM_GENERO", "C", 01, 0 )	
	oModel:AddField( "HJM_DSGNRO", "C", 50, 0 )		
	oModel:AddField( "HJM_RACA"	 , "N", 04, 0 )
	oModel:AddField( "HJM_DSRACA", "C", 50, 0 )
	oModel:AddField( "HJM_DTNASC", "D", 08, 0 )	
	oModel:AddField( "HJM_EXTEMP", "C", 100, 0 )	
	oModel:AddField( "HJM_NOME"	 , "C", 120, 0 )	
	oModel:AddField( "HJM_DESLIG", "C", 01, 0 )		
	oModel:AddField( "HJM_PRSERV", "C", 01, 0 )	
	oModel:AddField( "HJM_EXTERN", "C", 01, 0 )

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

@author  Helio Leal
@since   05/06/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXColaborador
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "RA_MAT", "RA_DEFIFIS", "RA_SEXO", "RA_NASC", "RA_NOME", "RA_DEMISSA", "RA_SITFOLH", "RA_CATFUNC", "RA_RACACOR" } )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue("RA_MAT"		, (cFlow)->RA_MAT)

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue("HJM_CODIGO"	, (cFlow)->RA_MAT)
		oRecord:SetValue("HJM_PNECES"	, (cFlow)->RA_DEFIFIS)
		oRecord:SetValue("HJM_GENERO"	, (cFlow)->RA_SEXO)
		oRecord:SetValue("HJM_DTNASC"	, STod( (cFlow)->RA_NASC ) )
		oRecord:SetValue("HJM_NOME"		, (cFlow)->RA_NOME)
		oRecord:SetValue("HJM_COLABR"	, oKey:GetKey( { (cFlow)->RA_MAT} ) )
		
		
		
		oRecord:SetValue("HJM_EXTERN"	, ' ')
		oRecord:SetValue("HJM_EXTEMP"	, ' ')
		oRecord:SetValue("HJM_DSGNRO"	, If( (cFlow)->RA_SEXO == "F", STR0001, STR0002 ) ) //"Feminino"###"Masculino"
		oRecord:SetValue("HJM_DESLIG"	, If( ! Empty( (cFlow)->RA_DEMISSA ) .And. (cFlow)->RA_SITFOLH == "D", "T", "F" ) )
		oRecord:SetValue("HJM_PRSERV"	, If( (cFlow)->RA_CATFUNC == "A", "S", "N" ) )

		Do Case
			Case (cFlow)->RA_RACACOR == "1" 
				oRecord:SetValue("HJM_DSRACA"	, STR0003) // "Indigena"
				oRecord:SetValue("HJM_RACA"  	, 1 )
			Case (cFlow)->RA_RACACOR == "2" 
				oRecord:SetValue("HJM_DSRACA", STR0004) // "Branca"
				oRecord:SetValue("HJM_RACA", 2)
			Case (cFlow)->RA_RACACOR == "4" 
				oRecord:SetValue("HJM_DSRACA", STR0005) // "Negra"
				oRecord:SetValue("HJM_RACA", 4 )
			Case (cFlow)->RA_RACACOR == "6" 
				oRecord:SetValue("HJM_DSRACA", STR0006) // "Amarela"
				oRecord:SetValue("HJM_RACA", 6 )
			Case (cFlow)->RA_RACACOR == "8" 
				oRecord:SetValue("HJM_DSRACA", STR0007) // "Parda"
				oRecord:SetValue("HJM_RACA"	 , 8)
			Otherwise
				oRecord:SetValue("HJM_DSRACA", STR0008) // "Nao Informado"
				oRecord:SetValue("HJM_RACA"	 , 9)
		EndCase	

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