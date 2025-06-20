#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVldValor
Valida os valores utilizados em opera��es de indicadores

@param xValue1, valor do primeiro item da opera��o
@param xValue2, valor do segundo item da opera��o
@param nTipo, tipo da opera��o a ser realizada, que pode ser:
       		1 - Opera��o com valores n�o negativos
       		2 - Opera��o com valores negativos
       		3 - Opera��o com datas

@author  BI TEAM
@since   10/07/2012
/*/
//-------------------------------------------------------------------
Function BIXVldValor( xValue1, xValue2, nTipo )
	Local xResult 	:= nil

	Default nTipo   := 1

	If ( ! Empty( xValue1 ) .And. ! Empty( xValue2 ) )
		Do Case
			//-------------------------------------------------------------------
			// Opera��o com valores n�o negativos.
			//-------------------------------------------------------------------
			Case ( nTipo == 1 )
				xResult := Abs( xValue1 - xValue2 )
			//-------------------------------------------------------------------
			// Opera��o com valores negativos.
			//-------------------------------------------------------------------	
			Case ( nTipo == 2 )
				xResult := xValue1 - xValue2
			//-------------------------------------------------------------------
			// Opera��o com datas.
			//-------------------------------------------------------------------	
			Case nTipo == 3
				If ( xValue2 > xValue1 )
					xResult := xValue2
					xValue2 := xValue1
					xValue1 := xResult
				EndIf
	
				xResult := ( xValue1 - xValue2 )	
		EndCase
	Else
		xResult := 0
	EndIf
Return xResult

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXIniDate
Retorna a nova data de in�cio conforme as configura��es de meses retroativos.

@param cDataDe, caracter, Data inicial da extra��o. 
@param cParam, caracter, Nome do parametro a ser validado para c�lculo dos meses retroativos
@param nMinimo, caracter, Quantidade m�nima de meses a ser considerada.
@return cResult, Data de in�cio conforme as configura��es de meses retroativos.

@author  Marcia Junko
@since   20/10/2014
/*/
//-------------------------------------------------------------------
Function BIXIniDate(cDataDe, cParam, nMinimo)
	Local cResult		:= ""
	Local cNewDay 		:= Nil
	Local cNewMonth 	:= Nil
	Local cNewYear		:= Nil
	Local nInterval 	:= 0
	Local nQtdAno		:= 0  	
	Local nQtdMeses		:= 0
	Local nAuxMeses 	:= 0
	
	Default nMinimo 	:= 2

	nInterval 	:= BIXParInfo( cParam, "N", nMinimo )
	
	//-------------------------------------------------------------------
	// Quando o intervalo puder ser calculado em anos, subtrai apenas o ano da data  
	//-------------------------------------------------------------------
	If Mod(nInterval, 12) == 0
		nQtdAno := nInterval / 12
		
		//-------------------------------------------------------------------
		// Armazena a data de in�cio para extra��o  
		//-------------------------------------------------------------------
		cNewDay := StrZero( Day( SToD( cDataDe ) ), 2 )	
		cNewMonth := StrZero( Month( SToD( cDataDe ) ), 2)
		
		//-------------------------------------------------------------------
		// Determina o ano que ser� utilizado.  
		//-------------------------------------------------------------------
		cNewYear := StrZero( Year( SToD( cDataDe ) ) - nQtdAno, 4)
	Else
		//-------------------------------------------------------------------
		// Calcula a quantidade de anos a ser processada  
		//-------------------------------------------------------------------
		nQtdAno := Int(nInterval / 12)
		
		//-------------------------------------------------------------------
		// Armazena a data de in�cio para extra��o  
		//-------------------------------------------------------------------
		cNewDay := StrZero( Day( SToD( cDataDe ) ), 2 )
		
		//-------------------------------------------------------------------
		// Determina quantos meses adjacenes ser�o processados  
		//-------------------------------------------------------------------
		nQtdMeses := Mod(nInterval, 12)
		
		//-------------------------------------------------------------------
		// Determina o m�s que ser� utilizado conforme informado no par�metro  
		//-------------------------------------------------------------------
		nAuxMeses := Month( SToD( cDataDe ) ) - nInterval
		
		If nAuxMeses < 0
			//-------------------------------------------------------------------
			// Caso a diferen�a seja maior que 1 ano, soma para achar o m�s correto   
			//-------------------------------------------------------------------		
			If nAuxMeses >= -12 
				nAuxMeses := 12 + ( nAuxMeses )
			Else
				//-------------------------------------------------------------------
				// Subtrai o resultado da quantidade de meses para achar o m�s correto.
				//-------------------------------------------------------------------		
				nAuxMeses := 12 - nQtdMeses
			EndIf
		EndIf
		cNewMonth := StrZero( nAuxMeses, 2 )
		
		//-------------------------------------------------------------------
		// Determina o ano que ser� utilizado.  
		//-------------------------------------------------------------------
		If cNewMonth > StrZero( Month( SToD( cDataDe ) ), 2 )
			cNewYear :=  Year( SToD( cDataDe ) ) - 1
		Else
			If nQtdAno >= 1
				cNewYear :=  Year( SToD( cDataDe ) ) - nQtdAno 
			Else
				cNewYear :=  Year( SToD( cDataDe ) ) 
			EndIf
		EndIf
		cNewYear	:= StrZero( cNewYear, 4)
	EndIf	
	
	//-------------------------------------------------------------------
	// Determina a nova data que ser� utilizada na extra��o  
	//-------------------------------------------------------------------
	cResult	:= cNewYear + cNewMonth + cNewDay
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXInterval
Retorna os intervalos mensais dentro de um per�odo de data informado.

@return aInterval, Lista no formato {{primeiro dia m�s, �ltimo dia m�s}, ...}

@author  Valdiney V GOMES
@since   28/10/2014
/*/
//-------------------------------------------------------------------
Function BIXInterval( cDataDe, cDataAte, lToText )
	Local dDateFrom := SToD( cDataDe )
	Local dDateTo 	:= SToD( cDataAte )
	Local dDate		:= dDateFrom	
	Local nInterval	:= dDateTo - dDateFrom 
	Local nDay 		:= 0
	Local nMonth	:= 0
	Local aInterval	:= {}
	
	Default lToText	:= .F. 
		
	//-------------------------------------------------------------------
	// Percorre todos os dias do intervalo informado. 
	//-------------------------------------------------------------------  	
	For nDay := 0 To nInterval 
		If ! ( Month( dDate ) == nMonth ) 
			//-------------------------------------------------------------------
			// Guarda o primeiro e o �ltimo dia de cada m�s. 
			//-------------------------------------------------------------------  		
			If ( lToText )
				aAdd( aInterval, { DToS( FirstDay( dDate ) ), DToS( LastDay( dDate ) ) } )
			Else
				aAdd( aInterval, { FirstDay( dDate ), LastDay( dDate ) } )
			EndIf 
			
			nMonth := Month( dDate )
		EndIf 

		dDate += 1
	Next 
Return aInterval

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLock
Monta um nome para um arquivo de lock com identificador e entidade.

@param cID, caracter, Identificador do lock. 
@param cEntity, caracter, Nome da entidade. 
@return cLock, Retorna o nome do arquivo de lock. 

@author  Valdiney V GOMES
@since   05/12/2014
/*/
//-------------------------------------------------------------------
Function BIXLock( cID, cEntity, lCompany )
	Local cLock := ""
	
	Default cID 		:= ""
	Default cEntity 	:= ""
	Default lCompany 	:= .T. 

	//-------------------------------------------------------------------
	// Monta o arquivo de lock. 
	//------------------------------------------------------------------- 	
	cLock += GetPathSemaforo()
	cLock += "TOTVSBA"
	cLock += "_"
	cLock += AllTrim( cID )
	
	//-------------------------------------------------------------------
	// Identifica se o bloqueio considera entidade. 
	//-------------------------------------------------------------------	
	If ! Empty( cEntity )
		cLock += "_"
		cLock += AllTrim( cEntity )
	EndIf 

	//-------------------------------------------------------------------
	// Identifica se o bloqueio considera empresa. 
	//-------------------------------------------------------------------	
	If ( lCompany )
		cLock += "_"	
		cLock += AllTrim( cEmpAnt )
	EndIf 
	
	cLock += '.'	
	cLock += "LCK"	
Return cLock

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXHasLock
Identifica se existe lock para a entidade em outra thread. 

@param cEntity, caracter, Entidade que ser� extra�da.
@param cName, caracter, Tipo de lock que est� sendo validado. 
@return lIsLocked, Identifica se a entidade est� locada. 

@author  Valdiney V GOMES
@since   01/12/2014
/*/
//-------------------------------------------------------------------
Function BIXHasLock( cEntity, cName )
	Local cLock 		:= BIXLock( Upper( cName ), cEntity, .F. ) 
	Local lIsLocked 	:= .F. 

	If ( File( cLock ) )
		If ! ( FErase( cLock ) == 0 )
			lIsLocked := .T. 
		EndIf 
	EndIf 
Return lIsLocked

//------------------------------------------------------------------
/*/{Protheus.doc} BIXTblTmpAlias
Retorna um nome que n�o exista na base para uso pela tabela tempor�ria.

@return cTable, Retorna um nome v�lido para a tabela tempor�ria

@author  Marcia Junko
@since   10/08/2015
/*/
//-------------------------------------------------------------------
Function BIXTblTmpAlias( cTable )
	Default cTable := CriaTrab(, .F.)

	If ( TCCanOpen( cTable ) )
		While ( TCCanOpen( cTable := CriaTrab(, .F. ) ) )
		End
	EndIf	
Return cTable

//------------------------------------------------------------------
/*/{Protheus.doc} BIXVldCondition
Fun��o respons�vel por validar o conte�do utilizado na cl�usula WHERE
das querys, realizando tratamento nos casos de ap�strofe para a query
ser executada corretamente.

@param cCondition, Caracter, Conte�do utilizado para compara��o no WHERE.
@return cAux, Retorna a condi��o ajustada para uso na query.

@author  Marcia Junko
@since   16/04/2016
/*/
//-------------------------------------------------------------------
Function BIXVldCondition( cCondition )
	Local cAux 			:= ""
	
	Default cCondition 	:= ""
	
	cAux := StrTran( cCondition, Chr(39), Chr(39) + Chr(39) )	
Return cAux

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXHasEntryPoint  
Verifica a exist�ncia dos pontos de entrada BIEXTGRV e BIEXTENT.
  * BIEXTGRV: Preenche os campos livres.
  * BIEXTENT: Verifica previamente a exist�ncia de uma entidade, 
este PE � recomendado para aumentar a perfomance na execu��o dos extratores 
quando h� customiza��o.

@param cEntity, string, Entidade que est� sendo executada (verifica se h� PE para ela).
@return lEntryPoint, boolean, Retorna a exist�ncia de pontos de entrada.

@author  Helio Leal
@since   04/08/2017
/*/
//------------------------------------------------------------------- 
Function BIXHasEntryPoint( cEntity )
	Local lEntryPoint := Existblock( "BIEXTGRV" )
	
	Default cEntity := ""

	If ( lEntryPoint )
		If ( ExistBlock( "BIEXTENT" ) )
			aEntity 	:= ExecBlock( "BIEXTENT" )

			lEntryPoint := ( Empty( aEntity ) )

			If ! ( lEntryPoint )
				//-------------------------------------------------------------
				// Verifica a exist�ncia da entidade que est� sendo executada.
				//-------------------------------------------------------------
				lEntryPoint := ( ! Empty( AScan( aEntity, { | x | x == cEntity } ) ) )
			EndIf
		EndIf
	EndIf
Return lEntryPoint

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRunEntryPoint  
Execu��o dos Pontos de Entrada. 

@param oRecord, object, Registro que est� sendo executado.
@param lEntryPoint, boolean, verifica se h� pontos de entrada.
@param cEntity, string, entidade sendo executada no momento.
@param lIsDim, boolean, Verifica se � uma dimens�o

@author  Helio Leal
@since   04/08/2017
/*/
//------------------------------------------------------------------- 
Function BIXRunEntryPoint( oRecord, lEntryPoint, cEntity, lIsDim )
	Local aField 	:= {}
	Local nField	:= 0
	Local lKey		:= .F.
	Local lOutput	:= .F.

	Default oRecord     := Nil
	Default lEntryPoint := .F.
	Default cEntity     := ""
	Default lIsDim       := .T.
	

	If !( oRecord == Nil ) .And. ( lEntryPoint )
		aField := Execblock( "BIEXTGRV", .F., .F., { cEntity, oRecord:GetStruct( .F. ), lIsDim } )
		
		For nField := 1 To Len( aField )
			lKey    := aField[nField][6]
			lOutput := aField[nField][7]

			//-------------------------------------------------------------------
			// Impede a altera��o dos campos chave e internos.
			//-------------------------------------------------------------------
			If ( ( lOutput ) .And. ! ( lKey ) )
				oRecord:SetValue( aField[nField][1], aField[nField][2] )
			EndIf
		Next nField

		//-------------------------------------------------------------------
		// Mata as vari�veis do tipo array para diminuir o consumo de mem�ria 
		//------------------------------------------------------------------- 
		aSize(aField, 0)
		aField	:= Nil
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRunUsrTab  
Execu��o do Ponto de Entrada BIUSRTAB.
  * BIUSRTAB: Abertura de tabelas necess�rias para o processo de customiza��o.

@param cEntity, string, entidade sendo executada no momento.

@author  Helio Leal
@since   04/08/2017
/*/
//------------------------------------------------------------------- 
Function BIXRunUsrTab( cEntity )
	Local nTable    := 0
	Local aTables   := {}
	Local lBIUsrTab := Existblock("BIUSRTAB")

	Default cEntity := ""

	If ( lBIUsrTab )
		aTables := Execblock("BIUSRTAB", .F., .F., { cEntity } )

		//-----------------------------------------------
		// Podem ser abertas no m�ximo 50 tabelas.
		//-----------------------------------------------
		If ValType( aTables ) == "A" .And. Len( aTables ) <= 50
			For nTable := 1 To Len( aTables )
				dbSelectArea( aTables[nTable] )
			Next
			
		 	//-------------------------------------------------------------------
			// Mata as vari�veis do tipo array para diminuir o consumo de mem�ria 
			//------------------------------------------------------------------- 
			aSize(aTables, 0)
			aTables	:= Nil
		EndIf
	EndIf
Return Nil