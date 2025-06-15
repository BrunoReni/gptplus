#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXAREAS.CH"

//---------------------------------------------------------------------------------
/*/{Protheus.doc} BIXSelAreas
Tela de seleção de apps para extração.

@param cApp, caracter, Lista de áreas selecionadas separadas por vírgula.
@return lOk, Indica se foi selecionada alguma área.

@author  Valdiney V GOMES
@since   21/06/2016         	
/*/
//---------------------------------------------------------------------------------
Function BIXSelAreas( cApp )	
	Local oDialog		:= nil
	Local oBrowse		:= nil
	Local aApp			:= {}
	Local aMark			:= {}
	Local aReturn		:= {}
	Local aMarked		:= {}
	Local nApp			:= 0
	Local nMark			:= 0
	Local lOk			:= .F. 
	Local lMarked		:= .F. 
	Local bMark			:= nil
	Local bOK  	   		:= nil
	Local bCancel  		:= nil
	Local bHeaderClick	:= nil
	
	Default cApp		:= ""

	aApp 			:= BIXRegister( )
	bMark			:= { || aMark[oBrowse:nAt][1] := ! aMark[oBrowse:nAt][1] } 
	bOK  	   		:= { || lOk := .T., oDialog:End() }
	bCancel  		:= { || oDialog:End() } 
	bHeaderClick	:= { || BIXMarkAll( aMark ), oBrowse:Refresh() } 

	//-------------------------------------------------------------------
	// Recupera os apps selecionados na tela de parâmetros. 
	//-------------------------------------------------------------------
	aMarked	:= aBIToken( cApp, ",", .F. )

	//-------------------------------------------------------------------
	// Recupera a lista de áreas. 
	//-------------------------------------------------------------------
	For nApp := 1 To Len( aApp )
		//--------------------------------------------------------------
		// Carrega a lista de áreas, desconsiderando PCO (descontinuado)
		//--------------------------------------------------------------
		If aApp[nApp][1] != PCO
			lMarked := ! Empty( aScan( aMarked, { |x| AllTrim( x ) == aApp[nApp][1] } ) )
			aAdd( aMark, { lMarked, aApp[nApp][1], aApp[nApp][2] } )
		EndIf
	Next nApp

	//------------------------------------------------------------------- 
	// Monta a lista de áreas. 
	//-------------------------------------------------------------------                     
	DEFINE DIALOG oDialog TITLE STR0008 FROM 050, 150 TO 400,600 PIXEL  //"Áreas"
		DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aMark NO REPORT NO LOCATE NO CONFIG OF oDialog 
			ADD MARKCOLUMN oColumn DATA { || If( aMark[oBrowse:nAt][1], "LBOK", "LBNO" ) } DOUBLECLICK bMark HEADERCLICK bHeaderClick OF oBrowse 
        	ADD COLUMN oColumn DATA {|| aMark[oBrowse:nAt, 3] } TITLE STR0010 SIZE 10 OF oBrowse // "Área" 
        ACTIVATE FWBROWSE oBrowse
	ACTIVATE DIALOG oDialog CENTERED ON INIT EnChoiceBar( oDialog, bOK, bCancel, .F.,{},,,.F.,.F.,.F.,.T., .F. )

	//------------------------------------------------------------------- 
	// Recupera as áreas selecionadas na tela de seleção. 
	//-------------------------------------------------------------------  	
	If ( lOk )
		For nMark := 1 To Len( aMark )
			If ( aMark[nMark][1] )
				aAdd( aReturn, aMark[nMark][2] )
			EndIf 
		Next nMark	
	EndIf 
		
	//------------------------------------------------------------------- 
	// Retorna a lista de áreas selecionadas. 
	//------------------------------------------------------------------- 	
	cApp := PadR ( BIXConcatWSep( ",", aReturn ), 99 )
Return lOk
 
//---------------------------------------------------------------------------------
/*/{Protheus.doc} BIXMarkAll
Marca/Desmarca Todas as áreas. 

@param aApp, array, lista de apps. 

@author  Valdiney V GOMES
@since   17/10/2014       	
/*/
//---------------------------------------------------------------------------------
Static Function BIXMarkAll( aApp ) 
	Local nApp 		:= 0
	Local lMarked	:= .F.
	
	Default aApp	:= {}
		
	lMarked := ! ( aScan( aApp, {| x | x[1] == .T. } ) == 0 )

	For nApp := 1 To Len( aApp )
		aApp[nApp][1] := ! lMarked
	Next nApp
Return nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXValidArea
Valida area digitada no pergunte

@protected
@author  BI TEAM
@version P12
@since   16/01/2018
@return .F. caso inválido
	
/*/
//-------------------------------------------------------------------
function BIXValidArea()
return BIXVldArea()

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVerifPeriodo
Verifica o tipo de filtro de período selecionado para considerar
parâmetros de data

@protected
@author  BI TEAM
@version P12
@since   16/01/2018
@return .F. caso inválido
	
/*/
//-------------------------------------------------------------------
function BIXVerifPeriodo()
return BIXVerPeriodo()