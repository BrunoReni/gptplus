#INCLUDE "BIXEXTRACTOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDate
Classe respons�vel por avaliar o intervalo de extra��o de acordo com o
tipo de per�odo configurado para a entidade.

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
M�todo contrutor.

@param dFrom, date, Data Inicial.
@param dTo, date, Data Final.
@param nPeriod, num�rico, Per�odo.
@Return Self, Inst�ncia da Classe.

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
Retorna a data inicial para extra��o.

@param lString, l�gico, Identifica se o retorno deve ser caracter.
@Return uFrom, Data inicial para extra��o. 

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method GetFrom( lString ) Class BIXDate
	Local uFrom := nil
	
	Default lString := .F. 
	
	//--------------------------------------------------------------------
	// Per�odo de Extra��o considera os meses completos de extra��o
	//--------------------------------------------------------------------	
	If ( ::nPeriod == PERIOD_MONTH_RANGE )
		uFrom := FirstDay( ::dFrom )

	//--------------------------------------------------------------------
	// Per�odo de Extra��o Mensal e somente para o m�s corrente
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_CURRENT )
		uFrom := FirstDay( Date( ) ) 	
	
	//--------------------------------------------------------------------
	// Per�odo de Extra��o considera somente o m�s indicado como m�s
	// final de extra��o
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_FINAL )
		uFrom := FirstDay( ::dTo ) 

	//--------------------------------------------------------------------
	// Caso a carga seja hist�rica, o Per�odo de Extra��o considera
	// os registros at� o m�s anterior a data de extra��o
	// Mas caso a carga seja incremental, o Per�odo de Extra��o considera
	// somente o m�s corrente
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
Retorna a data final para extra��o.

@param lString, l�gico, Identifica se o retorno deve ser caracter. 
@Return uFrom, Data final para extra��o. 

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method GetTo( lString ) Class BIXDate
	Local uTo := nil
	
	Default lString := .F.  
	
	//--------------------------------------------------------------------
	// Per�odo de Extra��o considera os meses completos de extra��o
	//--------------------------------------------------------------------		
	If ( ::nPeriod == PERIOD_MONTH_RANGE )
		uTo := LastDay( ::dTo )
	
	//--------------------------------------------------------------------
	// Per�odo de Extra��o Mensal e somente para o m�s corrente
	//--------------------------------------------------------------------	
	ElseIf( ::nPeriod == PERIOD_MONTH_CURRENT )
		uTo := LastDay( Date( ) ) 

	//--------------------------------------------------------------------
	// Per�odo de Extra��o considera somente o m�s indicado como m�s
	// final de extra��o
	//--------------------------------------------------------------------		
	ElseIf( ::nPeriod == PERIOD_MONTH_FINAL )
		uTo := LastDay( ::dTo ) 

	//--------------------------------------------------------------------
	// Caso a carga seja hist�rica, o Per�odo de Extra��o considera
	// os registros at� o m�s anterior a data de extra��o
	// Mas caso a carga seja incremental, o Per�odo de Extra��o considera
	// somente o m�s corrente
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
Destroi o objeto e libera a mem�ria alocada. 

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