#INCLUDE "BIXEXTRACTOR.CH"

Static __aTable
Static __aProperty
Static __nLink
Static __nLinkERP
Static __nLinkFSD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOpenLink
Define a estrutura da tabela de conexão com a Fluig Smart Data de extração e 
realiza a criação, abertura e ajustes na estrutura do arquivo. 

@author  Valdiney V GOMES
@since   07/01/2014
/*/
//-------------------------------------------------------------------
Static Function BIXOpenLink()   
	Local oLink		:= nil
	Local nTable	:= 1      

	If ( __aTable == nil )
		__nLink		:= 0
		__nLinkERP 	:= 0	
 		__nLinkFSD	:= 0	
	
		//-------------------------------------------------------------------
		// Lista de tabelas de conexão com a Fluig Smart Data. 
		//------------------------------------------------------------------- 
		__aTable := {}	   
		                 
		//-------------------------------------------------------------------
		// Cria a tabela de processos. 
		//-------------------------------------------------------------------  
		oLink := TBITable():New( "HYN", "HYN" ) 
	
		oLink:AddField( TBIField():New( "HYN_ID" 		,"C" ,08 ,0))
		oLink:AddField( TBIField():New( "HYN_CONN" 		,"C" ,10 ,0))
		oLink:AddField( TBIField():New( "HYN_DB" 		,"C" ,20 ,0))	
		oLink:AddField( TBIField():New( "HYN_SERVER" 	,"C" ,40 ,0))			
		oLink:AddField( TBIField():New( "HYN_PORT"  	,"C" ,05 ,0))	    
		oLink:AddField( TBIField():New( "HYN_ALIAS"  	,"C" ,40 ,0))
		
		oLink:AddIndex( TBIIndex():New( "HYN1", {"HYN_ID"}, .T.) )  
			
		aAdd( __aTable, oLink )
	EndIf
	
	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( __aTable ) 
		If !( __aTable[nTable]:lIsOpen( ) )
			__aTable[nTable]:ChkStruct( .F., .F., .F., .T. )
			__aTable[nTable]:lOpen( )
		EndIf
	Next nTable 
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLinkProperty
Define a estrutura da tabela de conexão com a Fluig Smart Data de extração e 
realiza a criação, abertura e ajustes na estrutura do arquivo. 

@param cID, caracter, Identificador da FSD
@param cProperty, caracter, Propriedade de conexão com FSD desejada. 
@return cValue, Valor da propriedade desejada. 

@author  Valdiney V GOMES
@since   07/01/2014
/*/
//-------------------------------------------------------------------
Function BIXLinkProperty( cID, cProperty )
	Local cValue 		:= ""
	Local nProperty		:= 0
	
	Default cID 		:= "DEFAULT"
	Default cProperty	:= ""
	
	If	( __aProperty == nil )
		__aProperty := { }
	EndIf
	
	//-------------------------------------------------------------------
	// Busca o conteúdo do cache de propriedades. 
	//-------------------------------------------------------------------		
	nProperty := aScan( __aProperty, {|x| x[1] == cID .And. x[2] == cProperty } )
		
	If ! ( nProperty == 0 )
		cValue := __aProperty[nProperty][3]
	EndIf 

	If ( Empty( cValue ) )
		//-------------------------------------------------------------------
		// Abre a tabela de parâmetros de conexão com a Fluig Smart Data. 
		//-------------------------------------------------------------------	
		If( BIXOpenLink() )		
			//-------------------------------------------------------------------
			// Busca as propriedades de conexão com a Fluig Smart Data...
			//-------------------------------------------------------------------
			If ( HYN->( MSSeek( cID ) ) )
				//-------------------------------------------------------------------
				// ... da tabela HYN.  
				//------------------------------------------------------------------- 
				Do Case
			   		Case cProperty == "CONNECTION" 
						cValue := HYN->HYN_CONN
			   		Case cProperty == "DATABASE" 
						cValue := HYN->HYN_DB
			   		Case cProperty == "SERVER" 
						cValue := HYN->HYN_SERVER
					Case cProperty == "PORT" 
						cValue := HYN->HYN_PORT
					Case cProperty == "ALIAS" 
						cValue := HYN->HYN_ALIAS
			   	EndCase	
			Else	
				//-------------------------------------------------------------------
				// ... dos parâmetros do Protheus.  
				//------------------------------------------------------------------- 
				Do Case
			   		Case cProperty == "CONNECTION" 
						cValue := SuperGetMv("MV_BIXTCON",, "")
			   		Case cProperty == "DATABASE" 
						cValue := SuperGetMv("MV_BIXDB"	 ,, "")
			   		Case cProperty == "SERVER" 
						cValue := SuperGetMv("MV_BIXSRVR",, "") 
					Case cProperty == "PORT" 
						cValue := SuperGetMv("MV_BIXPORT",, "")
					Case cProperty == "ALIAS" 
						cValue := SuperGetMv("MV_BIXALIA",, "")
			   	EndCase	
			EndIf 
			
			aAdd( __aProperty, { cID, cProperty, cValue } ) 
		EndIf
	EndIf 
Return AllTrim( cValue )

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLinkRecord
Define a estrutura da tabela de conexão com a Fluig Smart Data de extração e 
realiza a criação, abertura e ajustes na estrutura do arquivo. 

@param cID, caracter, Identificador da FSD
@param cConnection, caracter, Tipo de conexão com a FSD
@param cDatabase, caracter, Database da FSD
@param cServer, caracter, Servidor da FSD
@param cPort, caracter, Porta de conexão com a FSD
@param cAlias, caracter, Alias da FSD

@author  Valdiney V GOMES
@since   07/01/2014
/*/
//-------------------------------------------------------------------
Function BIXLinkRecord( cID, cConnection, cDatabase, cServer, cPort, cAlias )
	Local lInsert	:= .T.  
	
	Default cID 		:= "DEFAULT"
	Default cConnection	:= ""
	Default cDatabase	:= ""
	Default cServer		:= ""
	Default cPort		:= ""
	Default cAlias		:= ""
	
	//-------------------------------------------------------------------
	// Limpa o conteúdo do cache de propriedades. 
	//-------------------------------------------------------------------	
	__aProperty := {}		
	
	//-------------------------------------------------------------------
	// Abre a tabela de parâmetros de conexão com a Fluig Smart Data. 
	//-------------------------------------------------------------------	
	If( BIXOpenLink() ) 
		//-------------------------------------------------------------------
		// Identifica se insere ou atualiza uma propriedade. 
		//------------------------------------------------------------------- 
		lInsert := ! ( HYN->( DBSeek( cID ) ) )
	
		//-------------------------------------------------------------------
		// Grava as propriedades da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		If( RecLock( "HYN", lInsert ) )
			HYN->HYN_ID		:= cID
			HYN->HYN_CONN	:= cConnection
			HYN->HYN_DB		:= cDatabase
			HYN->HYN_SERVER	:= cServer
			HYN->HYN_PORT	:= cPort
			HYN->HYN_ALIAS	:= cAlias
	
			HYN->( MsUnlock() )
		EndIf
	EndIf
Return nil
	
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetLink
Recupera a conexão corrente. 

@return nLink, Conexão com o ERP ou com a FSD  

@author  Valdiney V GOMES
@since   15/03/2016
/*/
//-------------------------------------------------------------------
Function BIXGetLink()
Return __nLink	
	
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSetLink
Define a conexão corrente.

@param nLink, numérico, Conexão com o ERP ou com a FSD  
@return nLink, Conexão com o ERP ou com a FSD  

@author  Valdiney V GOMES
@since   15/03/2016
/*/
//-------------------------------------------------------------------
Function BIXSetLink( nLink )
	Default nLink := 0

	If ( TCSetConn( nLink ) )
		__nLink	:= nLink
	EndIf 
Return __nLink	

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUnlinkFSD
Realiza a conexão com o ERP. 
 
@return nLink, Conexão com o ERP.  

@author  Valdiney V GOMES
@since   15/03/2016
/*/
//-------------------------------------------------------------------
Function BIXUnlinkFSD()
	If ( TCSetConn( __nLinkERP ) )
		__nLink	:= __nLinkERP
	EndIf 
Return __nLink

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLinkFSD
Realiza a conexão com a FLuig Smart Data. 
 
@return nLink, Conexão com a FLuig Smart Data.   

@author  Valdiney V GOMES
@since   15/03/2016
/*/
//-------------------------------------------------------------------
Function BIXLinkFSD()
	Local cType		:= ""	
	Local cDatabase	:= ""
	Local cAlias	:= ""	
	Local cServer	:= ""		
	Local cPort		:= ""	
	Local bLogger	:= nil	

	If ( Empty( __nLinkFSD ) )
		//-------------------------------------------------------------------
		// Define o logger para a conexão.  
		//------------------------------------------------------------------- 
		bLogger	:= {|x| BIXSysOut( "BIXLINK", x ) }
	
		//-------------------------------------------------------------------
		// Recupera os parâmetros para conexão.  
		//------------------------------------------------------------------- 
	 	cType		:= BIXLinkProperty(,"CONNECTION")	
	 	cDatabase	:= BIXLinkProperty(,"DATABASE") 	
	 	cAlias		:= BIXLinkProperty(,"ALIAS")		
	 	cServer		:= BIXLinkProperty(,"SERVER")		
	 	cPort		:= BIXLinkProperty(,"PORT")		

		//-------------------------------------------------------------------
		// Abre a conexão com a Fluig Smart Data.  
		//------------------------------------------------------------------- 	
		If ! ( Empty( cType ) .Or. Empty( cDatabase ) .Or. Empty( cAlias ) .Or. Empty( cServer )  .Or. Empty( cPort )  )
			__nLinkFSD 	:= nBIOpenDB( cDatabase, cAlias, cServer, cType, bLogger, nBIVal( cPort ) )
			__nLink		:= __nLinkFSD
		Endif
	Else
		//-------------------------------------------------------------------
		// Define como ativa a conexão com a Fluig Smart Data.  
		//------------------------------------------------------------------- 
		If ( TCSetConn( __nLinkFSD ) )
			__nLink	:= __nLinkFSD
		EndIf 
	EndIf
Return __nLink

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCloseFSD
Fecha a conexão com a FLuig Smart Data. 

@return nLink, Conexão com o ERP.   

@author  Valdiney V GOMES
@since   15/03/2016
/*/
//-------------------------------------------------------------------
Function BIXCloseFSD()
	If ! ( Empty( __nLinkFSD ) )
		If( TcUnlink( __nLinkFSD ) )
			__nLink := __nLinkERP
		EndIf 
	EndIf 
Return __nLink