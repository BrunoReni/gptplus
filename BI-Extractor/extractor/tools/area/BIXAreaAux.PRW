#INCLUDE "BIXEXTRACTOR.CH"
#include "BIXAREAS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVldArea
Valida area digitada no pergunte

@protected
@author  M�rcia Junko
@version P12
@since   03/07/2015
@return .F. caso inv�lido

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
			//Verifica se a �rea j� n�o foi indicada anteriormente
			if (aScan(aVerif, {|x| x == AllTrim(aValue[nItem]) })) > 0
				lValid := .F.		
				cMsg += STR0011 + aValue[nItem] + CRLF //�rea duplicada: 
			Else
			  	aAdd(aVerif, aValue[nItem])
			EndIf
			//Verifica se a �rea indicada est� dispon�vel		
			if ( aScan(aLista, {|x| x[1] == AllTrim(aValue[nItem]) }) == 0 )
				lValid := .F.
				cMsg += STR0012 + aValue[nItem] + CRLF //�rea inv�lida: 
			endif
		Next  
	EndIf
	
	//Exibe a mensagem de inconsist�ncia da sele��o de �rea
	If !( lValid )
		APMsgStop(cMsg)
	EndIf             
return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVerPeriodo
Verifica o tipo de filtro de per�odo selecionado para considerar
par�metros de data

@return .F. caso inv�lido

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXVerPeriodo()
	local aValue 	:= MV_PAR01
	local lValid 	:= .T.
	
	//Verifica se o per�odo � de data espec�fica
	If aValue <> 5
		//Limpa os par�metros que n�o ser�o utilizados
		MV_PAR02 := cTod("//")
		MV_PAR03 := cTod("//")
	EndIf	
return lValid