#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVldValor
Valida os valores utilizados em operações de indicadores

@param xValue1, valor do primeiro item da operação
@param xValue2, valor do segundo item da operação
@param nTipo, tipo da operação a ser realizada, que pode ser:
       		1 - Operação com valores não negativos
       		2 - Operação com valores negativos
       		3 - Operação com datas

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
			// Operação com valores não negativos.
			//-------------------------------------------------------------------
			Case ( nTipo == 1 )
				xResult := Abs( xValue1 - xValue2 )
			//-------------------------------------------------------------------
			// Operação com valores negativos.
			//-------------------------------------------------------------------	
			Case ( nTipo == 2 )
				xResult := xValue1 - xValue2
			//-------------------------------------------------------------------
			// Operação com datas.
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
Retorna a nova data de início conforme as configurações de meses retroativos.

@param cDataDe, caracter, Data inicial da extração. 
@param cParam, caracter, Nome do parametro a ser validado para cálculo dos meses retroativos
@param nMinimo, caracter, Quantidade mínima de meses a ser considerada.
@return cResult, Data de início conforme as configurações de meses retroativos.

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
		// Armazena a data de início para extração  
		//-------------------------------------------------------------------
		cNewDay := StrZero( Day( SToD( cDataDe ) ), 2 )	
		cNewMonth := StrZero( Month( SToD( cDataDe ) ), 2)
		
		//-------------------------------------------------------------------
		// Determina o ano que será utilizado.  
		//-------------------------------------------------------------------
		cNewYear := StrZero( Year( SToD( cDataDe ) ) - nQtdAno, 4)
	Else
		//-------------------------------------------------------------------
		// Calcula a quantidade de anos a ser processada  
		//-------------------------------------------------------------------
		nQtdAno := Int(nInterval / 12)
		
		//-------------------------------------------------------------------
		// Armazena a data de início para extração  
		//-------------------------------------------------------------------
		cNewDay := StrZero( Day( SToD( cDataDe ) ), 2 )
		
		//-------------------------------------------------------------------
		// Determina quantos meses adjacenes serão processados  
		//-------------------------------------------------------------------
		nQtdMeses := Mod(nInterval, 12)
		
		//-------------------------------------------------------------------
		// Determina o mês que será utilizado conforme informado no parâmetro  
		//-------------------------------------------------------------------
		nAuxMeses := Month( SToD( cDataDe ) ) - nInterval
		
		If nAuxMeses < 0
			//-------------------------------------------------------------------
			// Caso a diferença seja maior que 1 ano, soma para achar o mês correto   
			//-------------------------------------------------------------------		
			If nAuxMeses >= -12 
				nAuxMeses := 12 + ( nAuxMeses )
			Else
				//-------------------------------------------------------------------
				// Subtrai o resultado da quantidade de meses para achar o mês correto.
				//-------------------------------------------------------------------		
				nAuxMeses := 12 - nQtdMeses
			EndIf
		EndIf
		cNewMonth := StrZero( nAuxMeses, 2 )
		
		//-------------------------------------------------------------------
		// Determina o ano que será utilizado.  
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
	// Determina a nova data que será utilizada na extração  
	//-------------------------------------------------------------------
	cResult	:= cNewYear + cNewMonth + cNewDay
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXInterval
Retorna os intervalos mensais dentro de um período de data informado.

@return aInterval, Lista no formato {{primeiro dia mês, último dia mês}, ...}

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
			// Guarda o primeiro e o último dia de cada mês. 
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

@param cEntity, caracter, Entidade que será extraída.
@param cName, caracter, Tipo de lock que está sendo validado. 
@return lIsLocked, Identifica se a entidade está locada. 

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
Retorna um nome que não exista na base para uso pela tabela temporária.

@return cTable, Retorna um nome válido para a tabela temporária

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
Função responsável por validar o conteúdo utilizado na cláusula WHERE
das querys, realizando tratamento nos casos de apóstrofe para a query
ser executada corretamente.

@param cCondition, Caracter, Conteúdo utilizado para comparação no WHERE.
@return cAux, Retorna a condição ajustada para uso na query.

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
Verifica a existência dos pontos de entrada BIEXTGRV e BIEXTENT.
  * BIEXTGRV: Preenche os campos livres.
  * BIEXTENT: Verifica previamente a existência de uma entidade, 
este PE é recomendado para aumentar a perfomance na execução dos extratores 
quando há customização.

@param cEntity, string, Entidade que está sendo executada (verifica se há PE para ela).
@return lEntryPoint, boolean, Retorna a existência de pontos de entrada.

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
				// Verifica a existência da entidade que está sendo executada.
				//-------------------------------------------------------------
				lEntryPoint := ( ! Empty( AScan( aEntity, { | x | x == cEntity } ) ) )
			EndIf
		EndIf
	EndIf
Return lEntryPoint

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRunEntryPoint  
Execução dos Pontos de Entrada. 

@param oRecord, object, Registro que está sendo executado.
@param lEntryPoint, boolean, verifica se há pontos de entrada.
@param cEntity, string, entidade sendo executada no momento.
@param lIsDim, boolean, Verifica se é uma dimensão

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
			// Impede a alteração dos campos chave e internos.
			//-------------------------------------------------------------------
			If ( ( lOutput ) .And. ! ( lKey ) )
				oRecord:SetValue( aField[nField][1], aField[nField][2] )
			EndIf
		Next nField

		//-------------------------------------------------------------------
		// Mata as variáveis do tipo array para diminuir o consumo de memória 
		//------------------------------------------------------------------- 
		aSize(aField, 0)
		aField	:= Nil
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRunUsrTab  
Execução do Ponto de Entrada BIUSRTAB.
  * BIUSRTAB: Abertura de tabelas necessárias para o processo de customização.

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
		// Podem ser abertas no máximo 50 tabelas.
		//-----------------------------------------------
		If ValType( aTables ) == "A" .And. Len( aTables ) <= 50
			For nTable := 1 To Len( aTables )
				dbSelectArea( aTables[nTable] )
			Next
			
		 	//-------------------------------------------------------------------
			// Mata as variáveis do tipo array para diminuir o consumo de memória 
			//------------------------------------------------------------------- 
			aSize(aTables, 0)
			aTables	:= Nil
		EndIf
	EndIf
Return Nil