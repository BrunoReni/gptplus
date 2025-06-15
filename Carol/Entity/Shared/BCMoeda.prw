#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL MOEDA

//-------------------------------------------------------------------
/*/{Protheus.doc} BCMoeda
Visualizacao  das informacoes das  moedas.

@author  andreia.lima
@since   13/01/2021

/*/
//-------------------------------------------------------------------
Class BCMoeda from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
    Method LoadMoeda( )
    Method DescMoeda( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  andreia.lima
@since   13/01/2021

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCMoeda
	_Super:Setup("BCMoeda", DIMENSION, "SM2", , .F.)
Return

/*/{Protheus.doc} LoadMoeda
Retorna a quantidade de moedas utilizadas pelo sistema

@return aMoeda, Array de Moedas do sistema

@author  andreia.lima
@since   13/01/2021
/*/
//-------------------------------------------------------------------
Method LoadMoeda( ) Class BCMoeda
  	Local aMoeda	:= {}
  	Local aFinMoeda	:= ::DescMoeda()
  	Local nCount   	:= 0
     
  	For nCount := 1 To Len(aFinMoeda)
  		If !Empty( AllTrim( SubStr( aFinMoeda[ nCount ], 3, Len( aFinMoeda[ nCount ] ) - 2 ) ) )
    		Aadd( aMoeda,{ Alltrim(str(val(left( aFinMoeda[nCount], 2)))), Alltrim( substr( aFinMoeda[nCount], 3, len( aFinMoeda[nCount] ) - 2))})
    	EndIf
  	Next nCount   	
Return aMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} DescMoeda
Retorna moeda e descricao

@return aMoedaFin Moedas 

@author  andreia.lima
@since   13/01/2021
/*/
//-------------------------------------------------------------------
Method DescMoeda( ) Class BCMoeda
	Local cParamMoeda := ""
	Local cFilSX6     := ""
	Local aMoedaFin   := {} 

	//-------------------------------------------------------------------
	// Inicializa array com as moedas existentes
	//-------------------------------------------------------------------
	aMoedaFin := {}
	DbSelectArea( "SX6" )
	
	Getmv( "MV_MOEDA1" )
	
	cFilSX6 := SX6->X6_FIL
	
	While Substr( SX6->X6_VAR,1,8 ) == "MV_MOEDA" .And. SX6->( ! Eof() ) .And. ( SX6->X6_FIL == cFilSx6 )
		If Substr( SX6->X6_VAR,9,1 ) != "P" .And. Substr( SX6->X6_VAR,9,2 ) != "CM" // Desconsiderar plural e MV_MOEDACM
		    cParamMoeda := SX6->X6_VAR
			Aadd( aMoedaFin, StrZero( Val( Substr ( SX6->X6_VAR,9,2 ) ),2 ) + " " + GetMv( cParamMoeda ) )
		EndIf
		DbSkip()
	EndDo

	ASort( aMoedaFin )

Return ( aMoedaFin )

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  andreia.lima
@since   13/01/2021

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCMoeda
	
    Local cView    := ""
	Local cDatabase := Upper( TcGetDb() )
	Local nMoeda    := 0
	Local aMoeda    := {}

	aMoeda  := ::LoadMoeda()

	For nMoeda := 1 To Len( aMoeda )
		
		cView += "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, "
		cView += "<<CODE_INSTANCE>> AS INSTANCIA, <<CODE_COMPANY>> AS EMPRESA, "
        cView += "A.CODIGO_MOEDA, A.DESCRICAO_MOEDA FROM ("

		If ( "ORACLE" $ cDatabase )
			
			cView += "SELECT " + aMoeda[nMoeda][1] + " AS CODIGO_MOEDA, "
			cView += "'" + aMoeda[nMoeda][2] + "' AS DESCRICAO_MOEDA FROM DUAL) A "
		Else
			cView += "VALUES("+ aMoeda[nMoeda][1] + ","
			cView += "'" + aMoeda[nMoeda][2] + "'"
			cView += ")) A (CODIGO_MOEDA,DESCRICAO_MOEDA) "
		EndIf

		If (nMoeda < Len( aMoeda ) )
			cView += " UNION "
		EndIf
	
	Next nMoeda         
             
Return cView