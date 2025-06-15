#INCLUDE "BIXEXTRACTOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDate
Classe responsável por avaliar o intervalo de extração de acordo com o
tipo de período configurado para a entidade.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Class BIXDate
	Data dFrom
	Data dTo
	Data nPeriod
	Data lHist
	Data dMesAnt

	Method New( dFrom, dTo, nPeriod ) CONSTRUCTOR
	Method GetFrom( lString )
	Method GetTo( lString )
	Method Destroy( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método contrutor.

@param dFrom, date, Data Inicial.
@param dTo, date, Data Final.
@param nPeriod, numérico, Período.
@Return Self, Instância da Classe.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method New( dFrom, dTo, nPeriod ) Class BIXDate
	Local   lHist   := ( Month(dFrom) <> Month(dTo) )
	Local   nMes    := Month(Date()) - 1
	Local   dMesAnt := SToD( cBiStr( Year( Date() ) ) + StrZero( nMes, 2 ) + '01' )
	
	Default dFrom 	:= Date( )
	Default dTo 	:= Date( )
	Default nPeriod	:= PERIOD_RANGE

	::dFrom 	:= dFrom
	::dTo 		:= dTo
	::nPeriod	:= nPeriod
	::lHist     := lHist
	::dMesAnt   := dMesAnt

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFrom
Retorna a data inicial para extração.

@param lString, lógico, Identifica se o retorno deve ser caracter.
@Return uFrom, Data inicial para extração. 

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method GetFrom( lString ) Class BIXDate
	Local uFrom := nil
	
	Default lString := .F. 
	
	//--------------------------------------------------------------------
	// Período de Extração considera os meses completos de extração
	//--------------------------------------------------------------------	
	If ( ::nPeriod == PERIOD_MONTH_RANGE )
		uFrom := FirstDay( ::dFrom )

	//--------------------------------------------------------------------
	// Período de Extração Mensal e somente para o mês corrente
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_CURRENT )
		uFrom := FirstDay( Date( ) ) 	
	
	//--------------------------------------------------------------------
	// Período de Extração considera somente o mês indicado como mês
	// final de extração
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_FINAL )
		uFrom := FirstDay( ::dTo ) 

	//--------------------------------------------------------------------
	// Caso a carga seja histórica, o Período de Extração considera
	// os registros até o mês anterior a data de extração
	// Mas caso a carga seja incremental, o Período de Extração considera
	// somente o mês corrente
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_HIST_INC )
		If ::lHist 
			uFrom := FirstDay( ::dFrom )	
		Else
			uFrom := FirstDay( Date() )
		EndIf
	Else
		uFrom := ::dFrom 
	EndIf
	
	If( lString )
		uFrom := DToS( uFrom )
	EndIf 	
Return uFrom

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTo
Retorna a data final para extração.

@param lString, lógico, Identifica se o retorno deve ser caracter. 
@Return uFrom, Data final para extração. 

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method GetTo( lString ) Class BIXDate
	Local uTo := nil
	
	Default lString := .F.  
	
	//--------------------------------------------------------------------
	// Período de Extração considera os meses completos de extração
	//--------------------------------------------------------------------		
	If ( ::nPeriod == PERIOD_MONTH_RANGE )
		uTo := LastDay( ::dTo )
	
	//--------------------------------------------------------------------
	// Período de Extração Mensal e somente para o mês corrente
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_CURRENT )
		uTo := LastDay( Date( ) ) 

	//--------------------------------------------------------------------
	// Período de Extração considera somente o mês indicado como mês
	// final de extração
	//--------------------------------------------------------------------		
	ElseIf( ::nPeriod == PERIOD_MONTH_FINAL )
		uTo := LastDay( ::dTo ) 

	//--------------------------------------------------------------------
	// Caso a carga seja histórica, o Período de Extração considera
	// os registros até o mês anterior a data de extração
	// Mas caso a carga seja incremental, o Período de Extração considera
	// somente o mês corrente
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_HIST_INC )
		if ::lHist 	
			uTo := LastDay( ::dMesAnt )
		Else
			uTo := LastDay( Date() )
		EndIf
	Else
		uTo := ::dTo 
	EndIf
	
	If( lString )
		uTo := DToS( uTo )
	EndIf 	
Return uTo

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Destroy() Class BIXModel
	::dFrom 	:= nil 
	::dTo		:= nil
	::nPeriod	:= nil
	::lHist     := nil
	::dMesAnt   := nil
Return nil