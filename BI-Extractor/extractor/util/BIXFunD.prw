#INCLUDE "BIXEXTRACTOR.CH"

Static __cInstance
Static __aSM0Info := {}


//-------------------------------------------------------------------
/*/{Protheus.doc} BIXHasLicense
Identifica a disponibilidade de licenças do extrator.

3060 IBM Cognos - pacote com 5 licenças
3061 IBM Cognos - pacote com 10 licenças
3062 IBM Cognos - pacote com 25 licenças
3063 IBM Cognos - pacote com 50 licenças
3125 TOTVS Smart Analytics 

@return lLicence, Identifica a disponibilidade de licenças do extrator. 

@author  Valdiney V GOMES
@since   06/02/2017
/*/
//-------------------------------------------------------------------
Function BIXHasLicense( )
	Local lLicense := .T. 
	
	lLicense := ( cEmpAnt == "99" )
	
	If ! ( lLicense )
		lLicense := ( FWLSEnable( 3125 ) .Or. FWLSEnable( 3060 ) .Or. FWLSEnable( 3061 ) .Or.  FWLSEnable( 3062 ) .Or. FWLSEnable( 3063 ) )
	Endif
Return lLicense

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXInstance
Retorna a instância do extrator. 

@return cInstance, Instância do extrator. 

@author  Valdiney V GOMES
@since   06/02/2017
/*/
//-------------------------------------------------------------------
function BIXInstance()
	Local nInstance := 0

	If( Empty( __cInstance ) )
		__cInstance		:= "01"
		nInstance 		:= nBIVal( GetSrvProfString( "BIINSTANCE", "01" ) )
	
		If ( nInstance >= 1 .And. nInstance <= 99 )
			__cInstance := StrZero( nInstance, 2 )
		EndIf
	EndIf 
return __cInstance

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXConcatWSep
Concatena os valores de um array unidimentional separados por um token.
 
@param cToken, caracter, Separador.
@param aArray, array, Array unidimensional.
@return cResult, String resultante da concatenação do array com o token. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Function BIXConcatWSep( cToken, aArray )
	Local cResult 	:= ""
	Local nItem		:= 0
	
	Default cToken 	:= ""
	Default aArray 	:= {}
	
	For nItem := 1 To Len( aArray )
		If ( nItem == 1 )
			cResult += aArray[nItem]
		Else
			cResult += cToken + aArray[nItem] 
		EndIf	
	Next nItem	
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXValue
Retorna um valor convertido para a moeda de destino considerando a 
cotação da data informada; 

@param nValue, numérico, Valor a ser convertido.
@param xMFrom, indefinido, Moeda de origem.
@param xMTo, indefinido, Moeda de destino.
@param dDate, data, Data para cotação.
@param nFee, numérico, Taxa de conversão para o mercado internacional.
@return nResult, Valor convertido.

@author  Valdiney V GOMES
@since   06/02/2017
/*/
//-------------------------------------------------------------------
Function BIXValue( nValue, xMFrom, xMTo, dDate, nFee )
	Local nResult	:= 0

  	Default nValue 	:= 0
  	Default xMFrom 	:= 1 
  	Default xMTo  	:= 1
   	Default nFee	:= 0
  	Default dDate  	:= nil

	//-------------------------------------------------------------------
	// Identifica se o valor é zero.
	//-------------------------------------------------------------------	
  	If ! ( Empty( nValue ) )
  	  	xMFrom 	:= xBIConvTo( "N", xMFrom )
  		xMTo 	:= xBIConvTo( "N", xMTo )
  	
  		//-------------------------------------------------------------------
		// Identifica se a moeda de destino é a mesma de origem.
		//-------------------------------------------------------------------  	
  		If ! ( xMFrom == xMTo )
  			nResult := Round( xMoeda( nValue, xMFrom, xMTo, dDate, 3, nFee ), 2 )
  		Else
  			nResult := Round( nValue, 2 )
  		EndIf  	
  	Endif 
Return nResult

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetX5Title
Retorna o campo de descrição do SX5, para ser utilizad de acordo com o pais.

@return cField, Campo de descrição do SX5. 

@author  Valdiney V GOMES
@since   06/02/2017
/*/
//-------------------------------------------------------------------
Function BIXSX5Title( )
	Local cField := "" 
	Local cLang	 := FWRetIdiom()

	if cLang == "es"
		cField := "X5_DESCSPA X5_DESCRI"
	else
		if cLang == "en"
			cField := "X5_DESCENG X5_DESCRI"
	   else
	   		cField := "X5_DESCRI"
	   endif
	endif
Return cField

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCleanText
Remove os caracters ASCII fora do range de 32 à 126 apenas caracteres acentuados fora deste
range são mantidos. 

@param cText, caracter, Conteúdo que será limpo. 
@return cClean, caracter, Conteúdo com apenas os caracteres ASCII de 32 à 126 e caracteres acentuados. 
					
@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXCleanText( cText ) 
	Local cClean	:= ""
	Local cChar		:= ""
	Local nChar		:= 0
	Local nAsc		:= 0
	
	Default cText	:= ""
	
	cText := AllTrim( cText )
	
	For nChar := 1 To Len( cText ) 
		cChar	:= SubStr( cText, nChar, 1 ) 
		nAsc 	:= Asc( cChar )
		
		//-------------------------------------------------------------------
		// Range ASCII de 32 à 126 e letras aA, eE, iI, oO, uU e çÇ acentuadas.
		//-------------------------------------------------------------------
		If ( ( nAsc >= 32  .And. nAsc <= 126 ) .Or.; 
			 ( nAsc >= 192 .And. nAsc <= 196 ) .Or. ( nAsc >= 224 .And. nAsc <= 228 ) .Or.;
			 ( nAsc >= 200 .And. nAsc <= 203 ) .Or. ( nAsc >= 232 .And. nAsc <= 235 ) .Or.;
			 ( nAsc >= 204 .And. nAsc <= 207 ) .Or. ( nAsc >= 236 .And. nAsc <= 239 ) .Or.;
			 ( nAsc >= 210 .And. nAsc <= 214 ) .Or. ( nAsc >= 242 .And. nAsc <= 246 ) .Or.;
			 ( nAsc >= 217 .And. nAsc <= 220 ) .Or. ( nAsc >= 249 .And. nAsc <= 252 ) .Or.;
			 ( nAsc == 199 ) .Or. ( nAsc == 231 ) )
			 
			cClean += cChar
		EndIf 
  	Next nChar
Return cClean

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFOri
Retorna as informações da filial origem 

@param cFilialOri, caracter, Filial. 
@return aInfo, array, [1]Empresa [2]Unidade de Negocio [3] Filial. 
					
@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXFOri( cFilialOri )
	Local aInfo     := Array(3)
	Local aSM0Aux	:= {}	
	Local nPosSM0	:= 0	
	
	If !Empty( cFilialOri )
	//-------------------------------------------------------------------
	// Verifica se a filial já está no cache
	//------------------------------------------------------------------- 
		If (nPosSM0 := Ascan(__aSM0Info, {|x| x[1] == cFilialOri} )) == 0
			//-------------------------------------------------------------------
			// Carrega as informações da filial 
			//------------------------------------------------------------------- 
			aSM0Aux := FWArrFilAtu( , cFilialOri )
		
			//-------------------------------------------------------------------
			// Adiciona as informações da filial no cache 
			//------------------------------------------------------------------- 
			Aadd(__aSM0Info, { cFilialOri, aClone(aSM0Aux) })

			//-------------------------------------------------------------------
			// Atribui as informações conforme o conteúdo da _FILORI
			//------------------------------------------------------------------- 
			aInfo[1] := aSM0Aux[SM0_EMPRESA]
			aInfo[2] := aSM0Aux[SM0_UNIDNEG]
			aInfo[3] := aSM0Aux[SM0_CODFIL]
		Else
			//-------------------------------------------------------------------
			// Atribui as informações do cache 
			//------------------------------------------------------------------- 
			aInfo[1] := __aSM0Info[nPosSM0][2][SM0_EMPRESA]
			aInfo[2] := __aSM0Info[nPosSM0][2][SM0_UNIDNEG]
			aInfo[3] := __aSM0Info[nPosSM0][2][SM0_CODFIL]
		EndIf
	EndIf
				
Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetShare
Define a tabela de origem dos dados no Protheus.

@param, cTable, String, Tabela Origem.
@Return cShare, Retorna o nome da origem da entidade.

@author  Helio Leal
@since   12/09/2017
/*/
//-------------------------------------------------------------------
Function BIXGetShare( cTable )  
	Local cShare   := ""

	Default cTable := ""

    //------------------------------------------------------------------- 
    // Identifica se a tabela de origem da entidade está no dicionário. 
    //------------------------------------------------------------------- 
    If ( ! Empty( cTable ) ) .And. ( AliasInDic( cTable ) ) 
        cShare := AllTrim( FWSX2Util():GetFile( cTable ) )    
    EndIf 
Return cShare