#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSysOut
Função responsável pela exibição de uma mensagem de log conforme
o tipo de mensagem no parâmetro BIXSysOutType

@param cLocation, caracter, Localização aonde ocorreu o evento
@param cMessage, caracter, Mensagem a ser exibida
@param nType, numérico, Tipo de mensagem.
@param cStack, caracter ,Descrição do erro

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXSysOut(cLocation, cMessage, nType, cStack )
	Default cLocation	:= ""
	Default cMessage	:= ""
	Default cStack 		:= ""
	Default nType		:= MSG_INFO

	If ( nType == MSG_INFO )
		conout( cBIStr( Date() ) + " " + Time() + " - " + cBIStr( cMessage ) )
	ElseIf nType == MSG_ERROR
		conout( cBIStr( Date() ) + " " + Time() + " - " + STR0001 + cBIStr( cMessage ) ) //"ERRO GRAVE"
		conout( replicate("-", 61) )

		If ! Empty( cStack )
			conout( cStack )
			conout( replicate("-", 61) )
	    EndIf

		conout("")
	ElseIf nType == WARNING
		conout( cBIStr( Date() ) + " " + Time() + " - " + STR0002 + cBIStr( cMessage ) ) //"ATENÇÃO"
		conout("")
	EndIf
	
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadMoeda
Retorna a quantidade de moedas utilizadas pelo sistema

@return aBIMoedas, Array de Moedas do sistema, ou da fato requisitada.

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXLoadMoeda()
  	Local aBiMoeda		:= {}
  	Local aFinMoeda		:= BIXDescMoeda()
  	Local nCount   		:= 0
     
  	For nCount := 1 To Len(aFinMoeda)
  		If !Empty( AllTrim( SubStr( aFinMoeda[ nCount ], 3, Len( aFinMoeda[ nCount ] ) - 2 ) ) )
    		Aadd( aBiMoeda,{ val( left( aFinMoeda[nCount], 2)), Alltrim( substr( aFinMoeda[nCount], 3, len( aFinMoeda[nCount] ) - 2))})
    	EndIf
  	Next nCount   	
Return aBiMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFuncWrapper
Responsável por executar uma função externa aos extratores

@param cFunction, caracter, Função a ser executada
@param cLocation, caracter, Área do segmento aonde a função está sendo chamada
@param aParms, array, Vetor com os parâmetros a serem passados para a função a ser chamada
@return xRet, Retorno da função chamada

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXFuncWrapper( cFunction, cLocation, aParms, cEntity )
  	Local nInd
  	Local xRet
  	Local bFunExec
	Local bError     := Nil
	Local lOk        := .T.
	Local cError     := ""
  	Local cVariables := ""
  	Local cValues    := ""

  	Default aParms 		:= {}
  	Default cLocation 	:= ""
  	Default cEntity      := ""

	bError := ErrorBlock( { | e | lOk := .F., cError := e:ErrorStack } )
	
	//-------------------------------------------------------------------		
	// verifica se existe a função a ser chamada
	//-------------------------------------------------------------------		
  	If FindFunction(cFunction)
    	For nInd := 1 to len(aParms)
      		cVariables 	+=  ", var" + cBIStr(nInd)
      		cValues 	+= ", aParms[" + cBIStr(nInd) + "]"
    	Next
    	cVariables 	:= substr(cVariables, 3)
    	cValues		:= substr(cValues	, 3)

    	bFunExec := "'{|" + cVariables + "| " + cFunction + "(" + cVariables + ")}'"
    	bFunExec := &("{ |aParms| EVal(&(" + bFunExec + "), " + cValues + ")}")

    	Begin Sequence
      		xRet := EVal(bFunExec, aParms) //Executa a função a ser chamada
    	End Sequence
  	Else
  		lOk := .F.
  		cError := STR0003 + cFunction + " - " + cLocation + CRLF
    	BIXSysOut("BIXFuncWrapper", cError, MSG_ERROR) //"Função não encontrada"
  	EndIf

	//-------------------------------------------------------------------		
	// Verifica se ocorreu erro na execução da função.
	//-------------------------------------------------------------------
	If !( lOk )
		//-------------------------------------------------------------------
		// Cria mensagem de erro.
		//-------------------------------------------------------------------
    	BIXSysOut("BIXFuncWrapper", STR0004 + cFunction + " - " + cLocation + ": " + cError, MSG_ERROR) //"Atenção: o processo de extração terminou com ERRO"
    	
    	//-------------------------------------------------------------------
		// Atualiza o status da entidade. 
		//-------------------------------------------------------------------
		BIXSaveParam( "STATUS", "ERROR", cEntity,,,,, cError )

		Break
	EndIf

  	ErrorBlock( bError )
return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBEFindX3
Verifica se o campo está cadastrado no SX3.

@param cCampo, caracter, Nome do campo a ser pesquisado
@return lFind, Retorna .T. se o campo for encontrado no SX3.

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXBEFindX3(cCampo)
	Local aArea := SX3->(GetArea())
	Local lFind	:= .F.
	
	DBSelectArea("SX3")
	
	SX3->( DBSetOrder( 2 ) )
	
	If ( SX3->( DBSeek( cCampo ) ) )
		lFind := .T.
	EndIf
	
	RestArea(aArea)
return lFind 


//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDescMoeda
Retorna moeda e descrição

@return aMoedaFin Moedas 

@author  Totvs
@version P12 
@since   05/07/2018
/*/
//-------------------------------------------------------------------
Function BIXDescMoeda()
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
