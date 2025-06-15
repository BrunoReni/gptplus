#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPARAMETER.CH"

Static __aBIXParameter := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXParGetFaixa
Retorna o indentificador de uma faixa de dados na qual um valor se enquadra.

@param cParameter		Faixa a ser verificada.
@param nValue			Valor a ser procurado.
@param aRange			Conteúdo armazenado no parâmetro
@return cKey			Indentificador da faixa.

@author  Márcia Junko
@version P12
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXParGetFaixa( cParameter, nValue, aRange )
	Local cRange	:= ""
	Local nRange	:= 0
	Local cKey		:= UNDEFINED

	Default cParameter	:= ""
	Default nValue		:= 0
	Default aRange		:= {}

	If Empty( aRange )
		//-------------------------------------------------------------------
		// Recupera as faixas dos parâmetros.  
		//-------------------------------------------------------------------
		cRange	:= BIXParInfo( cParameter, "C", "" )
		aRange := aBIToken( cRange, ";", .F. )
	EndIF 	
	
	//-------------------------------------------------------------------
	// Percorre as faixa de dados.
	//-------------------------------------------------------------------
	For nRange := 1 To Len( aRange ) 
		//-------------------------------------------------------------------
		// Recupera o identificador do range do qual o valor pertence.
		//-------------------------------------------------------------------		
		If ! ( nRange == Len( aRange ) ) 
			If ( nRange == 1 .And. nValue == nBIVal( aRange[nRange] ) )
				cKey := cBIStr( nRange )
				Exit
			ElseIf( nValue > nBIVal( aRange[nRange] ) .And. nValue <= nBIVal( aRange[nRange + 1] ) )
				cKey := cBIStr( nRange )
				Exit
			EndIf 
		Else
			If ( nValue > nBIVal( aRange[nRange] ) )
				cKey := cBIStr( nRange )
				Exit
			EndIf 
		EndIf 
	Next nRange
Return cKey	

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXParUpdFato
Atualiza os parâmetros da tabela HJK já cadastrados para manter a 
compatibilidade com as alterações do campo HJK_CDFATO = '___'

@author  Márcia Junko
@version P12 
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXParUpdFato()
	Local aArea 		:= getArea()	
 	Local cFactFrom		:= Space(3)
 	Local cFactTo		:= "___"   
 	Local cQuery 		:= ""            

	If ! ( BIXLinkFSD() < 0 )
		BIXSetupTable("HJK")

		//-------------------------------------------------------------------
		// Monta a query para atualização dos parâmetros. 
		//-------------------------------------------------------------------	
		cQuery += " UPDATE HJK"
		cQuery += " SET" 
		cQuery += " 		HJK_CDFATO = '" + cFactTo   + "'"
		cQuery += " WHERE" 
		cQuery += " 		HJK_CDFATO = '" + cFactFrom + "'"
		
		//-------------------------------------------------------------------
		// Atualiza os parâmetros. 
		//-------------------------------------------------------------------
		If ( TcSQLExec( cQuery ) < 0 )
			BIXSysOut("BIXParUpdFato", TCSQLError() )
		EndIf 

		BIXUnlinkFSD()
	Endif
	
	RestArea( aArea )	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXParInfo
Retorna o conteúdo de um parâmetro da HJK, previnindo erro de execução. 

@param cParameter	Parametro cujo valor deverá ser retornado. 
@param cType		Tipo do parâmetro. 
@param xDefault		Valor default do parâmetro. 
@param cFact		Fato a qual o parâmetro foi vinculado. 

@return xReturn		Valor do parâmetro convertido para o tipo informado. 

@author  Márcia Junko
@version P12 
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXParInfo( cParameter, cType, xDefault, cFact, lCollection )  
 	Local aParameter 	:= {}
  	Local xReturn		:= Nil 
  	Local xValue		:= Nil
  	Local nPosParam	:= 0
  	
	Default cParameter 	:= ""
   	Default cType 		:= ""
   	Default xDefault 	:= ""
   	Default cFact   	:= '___' 
   	Default lCollection	:= .F. 
 	
	If (nPosParam := Ascan( __aBIXParameter, {|x| x[1] == cParameter} ) ) > 0 
 		xReturn := __aBIXParameter[ nPosParam ][2]
 	Else
	 	//-------------------------------------------------------------------
		// Recupera o conteúdo do parâmetro. 
		//-------------------------------------------------------------------    
	   	aParameter := BIXLoadParam( cParameter, cFact, lCollection ) 
		
	   	If ! ( lCollection ) 
			If ( ! ( aParameter == Nil ) .And. Len( aParameter ) >= 3 )
				//-------------------------------------------------------------------
				// Retorna o conteúdo do parâmetro. 
				//-------------------------------------------------------------------  
		   		xValue	 := AllTrim( aParameter[3] )	
		   		xReturn := xBIConvTo( cType, xValue ) 
				
				//-------------------------------------------------------------------
				// Retorna no mínimo o valor default de parâmetros numéricos. 
				//-------------------------------------------------------------------
		   		If ( cType == "N" )
		   			If ! ( Empty( xDefault ) )
		   				xDefault := xBIConvTo( cType, xDefault )
		   			
		   				If ( xReturn < xDefault )
		   					xReturn := xDefault
		   				EndIf    			
		   			EndIf 
		   		EndIf	   		 		
		   	Else
		   		//-------------------------------------------------------------------
				// Retorna o conteúdo default do parâmetro. 
				//-------------------------------------------------------------------  
		   		xReturn := xBIConvTo( cType, xDefault )
		   	EndIf 
		Else
			//-------------------------------------------------------------------
			// Retorna uma lista de valores. 
			//------------------------------------------------------------------- 
			If ! ( aParameter == Nil ) 
				xReturn := aParameter
			Else
				xReturn := {}		
			EndIf 
	   	EndIf
	   	
   		//-------------------------------------------------------------------
		// Deixa o conteúdo em cache para não efetuar a pesquisa novamente 
		//-------------------------------------------------------------------  
		Aadd( __aBIXParameter, { cParameter, xReturn } )
 	EndIf
Return xReturn