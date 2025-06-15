#INCLUDE "BIXEXTRACTOR.CH"
#include "BIXAREAS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVldArea
Valida area digitada no pergunte

@protected
@author  Márcia Junko
@version P12
@since   03/07/2015
@return .F. caso inválido

/*/
//-------------------------------------------------------------------
function BIXVldArea()
	local aValue 	:= strTokArr(MV_PAR04,",")
	local nItem 	:= 0
	local lValid 	:= .F.
	local aLista 	:= BIXRegister()          
	local aVerif	:= {}
	local cMsg		:= ""
	   
	If ( Empty( MV_PAR04 ) )
		lValid := .T. 
	EndIf 
	     
	If ! ( lValid )	
		lValid := .T.
		
		For nItem := 1 to len(aValue)                     
			//Verifica se a área já não foi indicada anteriormente
			if (aScan(aVerif, {|x| x == AllTrim(aValue[nItem]) })) > 0
				lValid := .F.		
				cMsg += STR0011 + aValue[nItem] + CRLF //Área duplicada: 
			Else
			  	aAdd(aVerif, aValue[nItem])
			EndIf
			//Verifica se a área indicada está disponível		
			if ( aScan(aLista, {|x| x[1] == AllTrim(aValue[nItem]) }) == 0 )
				lValid := .F.
				cMsg += STR0012 + aValue[nItem] + CRLF //Área inválida: 
			endif
		Next  
	EndIf
	
	//Exibe a mensagem de inconsistência da seleção de área
	If !( lValid )
		APMsgStop(cMsg)
	EndIf             
return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVerPeriodo
Verifica o tipo de filtro de período selecionado para considerar
parâmetros de data

@return .F. caso inválido

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXVerPeriodo()
	local aValue 	:= MV_PAR01
	local lValid 	:= .T.
	
	//Verifica se o período é de data específica
	If aValue <> 5
		//Limpa os parâmetros que não serão utilizados
		MV_PAR02 := cTod("//")
		MV_PAR03 := cTod("//")
	EndIf	
return lValid