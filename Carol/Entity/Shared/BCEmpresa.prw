#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL EMPRESA

//-------------------------------------------------------------------
/*/{Protheus.doc} BCEmpresa
Visualiza  as informações de Empresa.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Class BCEmpresa from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCEmpresa

	
	_Super:Setup("Empresa", DIMENSION, "SM0", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildView
Constrói a view da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCEmpresa
	Local cView     := ""
	Local aCompany  := BICompanySelected( )
	Local nCompany  := 0
	Local cDatabase := Upper( TcGetDb() )

	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nCompany := 1 To Len( aCompany )
		cView += "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO," + ;
			             "<<CODE_INSTANCE>> AS INSTANCIA,"
		cView += "'" + aCompany[nCompany] + "' AS COD_EMPRESA, "
		cView += "'" + AllTrim( FWEmpName( aCompany[nCompany] ) ) + "' AS DESC_EMPRESA "

		//------------------------------------------------------
		// Tratamento por banco para pegar uma tabela dummy.
		//------------------------------------------------------
		Do Case    
			Case ( "ORACLE" $ cDatabase )
				cView += " FROM DUAL "
			Case ( "DB2" $ cDatabase )
				cView += " FROM SYSIBM.SYSDUMMY1 "
		EndCase

		If (nCompany < Len( aCompany ) )
			cView += "UNION "
		EndIf
	Next nCompany
Return cView