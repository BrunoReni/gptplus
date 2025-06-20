#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSysOut
Fun��o respons�vel pela exibi��o de uma mensagem de log conforme
o tipo de mensagem no par�metro BIXSysOutType

@param cLocation, caracter, Localiza��o aonde ocorreu o evento
@param cMessage, caracter, Mensagem a ser exibida
@param nType, num�rico, Tipo de mensagem.
@param cStack, caracter ,Descri��o do erro

@author  M�rcia Junko
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
		conout( cBIStr( Date() ) + " " + Time() + " - " + STR0002 + cBIStr( cMessage ) ) //"ATEN��O"
		conout("")
	EndIf
	
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadMoeda
Retorna a quantidade de moedas utilizadas pelo sistema

@return aBIMoedas, Array de Moedas do sistema, ou da fato requisitada.

@author  M�rcia Junko
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
Respons�vel por executar uma fun��o externa aos extratores

@param cFunction, caracter, Fun��o a ser executada
@param cLocation, caracter, �rea do segmento aonde a fun��o est� sendo chamada
@param aParms, array, Vetor com os par�metros a serem passados para a fun��o a ser chamada
@return xRet, Retorno da fun��o chamada

@author  M�rcia Junko
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
	// verifica se existe a fun��o a ser chamada
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
      		xRet := EVal(bFunExec, aParms) //Executa a fun��o a ser chamada
    	End Sequence
  	Else
  		lOk := .F.
  		cError := STR0003 + cFunction + " - " + cLocation + CRLF
    	BIXSysOut("BIXFuncWrapper", cError, MSG_ERROR) //"Fun��o n�o encontrada"
  	EndIf

	//-------------------------------------------------------------------		
	// Verifica se ocorreu erro na execu��o da fun��o.
	//-------------------------------------------------------------------
	If !( lOk )
		//-------------------------------------------------------------------
		// Cria mensagem de erro.
		//-------------------------------------------------------------------
    	BIXSysOut("BIXFuncWrapper", STR0004 + cFunction + " - " + cLocation + ": " + cError, MSG_ERROR) //"Aten��o: o processo de extra��o terminou com ERRO"
    	
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
Verifica se o campo est� cadastrado no SX3.

@param cCampo, caracter, Nome do campo a ser pesquisado
@return lFind, Retorna .T. se o campo for encontrado no SX3.

@author  M�rcia Junko
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
Retorna moeda e descri��o

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
