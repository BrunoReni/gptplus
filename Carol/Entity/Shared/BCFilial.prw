#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL FILIAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BCFilial
Visualiza as  informações de Filial.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Class BCFilial from BCEntity
	Method Setup() CONSTRUCTOR
	Method BuildView( )
	Method GetCompFilial()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method Setup() Class BCFilial
	_Super:Setup("Filial", DIMENSION, "SM0", .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildView
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCFilial
	Local cView       := ""
	Local cFrom       := ""
	Local cDescricao  := ""
	Local aFilial     := ::GetCompFilial()
	Local aGrpEmpUnit := {}
	Local nFilial     := 0
	Local nGrpEmpUnit := 0
	Local nLenFilial  := 0
	
	Local cDatabase := Upper( TcGetDb() )	

	//-----------------------------------------------------------
	// Tratamento por banco para usar o FROM em uma tabela dummy.
	//-----------------------------------------------------------
	Do Case    
		Case ( "ORACLE" $ cDatabase )
			cFrom := " FROM DUAL "
		Case ( "DB2" $ cDatabase )
			cFrom := " FROM SYSIBM.SYSDUMMY1 "
	EndCase
	
	If Len( aFilial ) > 0
		nLenFilial := FWSizeFilial() + Len( aFilial[1][1] )
	EndIf	
	
	//------------------------------------------------
	// Monta select para as filiais
	//------------------------------------------------

	For nFilial := 1 To Len( aFilial )

		// Adiciona a empresa
		If ( ! Empty( aFilial[nFilial][3] ) .And. aScan(aGrpEmpUnit, {|empresa| empresa[2] == Padr( aFilial[nFilial][3], nLenFilial )}) == 0)
			cDescricao := AllTrim( aFilial[nFilial][19] )
			
			If(Empty(cDescricao))
				cDescricao := 'Empresa - ' + aFilial[nFilial][3]
			EndIf
			
			AAdd(aGrpEmpUnit, {aFilial[nFilial][1], Padr( aFilial[nFilial][3], nLenFilial), cDescricao}) //grupo, empresa, descrição da empresa
		EndIf
	    
		// Adiciona a unidade
		If (! Empty( aFilial[nFilial][4] ))
			cDescricao := AllTrim( aFilial[nFilial][20] )
			
			If(Empty(cDescricao))
				cDescricao := 'Unidade - ' + aFilial[nFilial][4]
			EndIf

			//Verifica se não há empresa
			If ( Empty( aFilial[nFilial][3] ) )
				If ( aScan( aGrpEmpUnit, { |unidade| unidade[2] == Padr( aFilial[nFilial][4], nLenFilial ) } ) == 0)
					AAdd( aGrpEmpUnit, { aFilial[nFilial][1], Padr( aFilial[nFilial][4], nLenFilial ), cDescricao } ) //grupo, unidade, descrição da unidade
				EndIf
			Else
				If ( aScan( aGrpEmpUnit, { |unidade| unidade[2] == Padr( aFilial[nFilial][3] + aFilial[nFilial][4], nLenFilial ) } ) == 0)
					AAdd( aGrpEmpUnit, { aFilial[nFilial][1], Padr( aFilial[nFilial][3] + aFilial[nFilial][4], nLenFilial ), cDescricao } ) // grupo, empresa + unidade, descrição da unidade
				EndIf	
			EndIf
		EndIf
		

		If !Empty(cView)
			cView += "UNION "
		EndIf
		
		cView += "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO," + ;
			             "<<CODE_INSTANCE>> AS INSTANCIA,"
		cView += "'" + aFilial[nFilial][1] + "' AS COD_EMPRESA,"	             
		cView += "'" + aFilial[nFilial][2] + "' AS COD_FILIAL,"
		cView += "'" + AllTrim( aFilial[nFilial][7] ) + "' AS DESC_FILIAL "
		cView += cFrom
		
	Next nFilial
	
	//------------------------------------------
	// Monta select para as empresas e unidades
	//------------------------------------------
	For nGrpEmpUnit := 1 To Len( aGrpEmpUnit )
		cView += "UNION "
		cView += "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO," + ;
			             "<<CODE_INSTANCE>> AS INSTANCIA,"
		cView += "'" + aGrpEmpUnit[nGrpEmpUnit][1] + "' AS COD_EMPRESA,"	             
		cView += "'" + aGrpEmpUnit[nGrpEmpUnit][2] + "' AS COD_FILIAL,"
		cView += "'" + aGrpEmpUnit[nGrpEmpUnit][3] + "' AS DESC_FILIAL "
		cView += cFrom
	Next 
	 	
Return cView

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompFilial
Retorna somente as filiais das empresas selecionadas para instalação.
@return array, filiais.

@author  Andreia Lima
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method GetCompFilial() Class BCFilial
	Local aCompFilial := {}
	Local aAllFilial  := FWLoadSM0()
	Local aCompany    := BICompanySelected( )
	Local nCompany    := 0
	Local nFilial     := 0
	
	For nCompany := 1 To Len( aCompany )
		For nFilial := 1 To Len( aAllFilial )
			If ( aCompany[nCompany] == aAllFilial[nFilial][1] ) 
				AADD( aCompFilial, aAllFilial[nFilial] )
			EndIf	
		Next nFilial
	Next nCompany
	
Return aCompFilial