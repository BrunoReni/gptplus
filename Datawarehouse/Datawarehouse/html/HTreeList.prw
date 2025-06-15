// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Htm
// Fonte  : THTreeList - Objeto THTreeList, respons�vel por conter uma lista de objetos
// Dependencia Externa:
//				JSTree.js
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.12.05 |2481-Paulo R Vieira| Fase 3 - Novo Layout
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

#define OBJETO 					1
#define OBJETO_METHOD			2

/*
--------------------------------------------------------------------------------------
Classe: THTreeList
Uso   : Lista de objetos
--------------------------------------------------------------------------------------
*/
Class THTreeList from TDWObject
	
    // array contendo a lista de objetos
    data faList
    
   	data fcName
    data fcBackground
    data faCoord
    
	// construtor
	method New() constructor
	
	// destrutor
	method Free()
	
	// adiciona um objeto
	method addToList(aoObject, abMethodCall)
	
	// retorna uma string contendo a representa��o da lista de objetos adicionados
	method Buffer(aBuffer, alBottom)
	
	method Name(acValue)
	method Width(anValue)
	method Height(anValue)
	method Background(acImageFile)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor padr�o
--------------------------------------------------------------------------------------
*/
method New() class THTreeList
	_Super:New()
	
	::faList		:= {}
	::fcBackground	:= ""
 	::fcName		:= ""
	::faCoord 	:= { 0, 0 }
	
return

/*
--------------------------------------------------------------------------------------
Destrutor padr�o
--------------------------------------------------------------------------------------
*/
method Free() class THTreeList
	
	_Super:Free()
	
	::faList		:= {}
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um objeto � lista
Args: aoObject, objeto, cont�m o objeto a ser adicionado
      abMethodCall, block code, OPCIONAL (default Buffer), cont�m a execu��o do m�todo que
      	dever� ser envocado no objeto passado como 1� argumento.
--------------------------------------------------------------------------------------
*/
method addToList(aoObject, abMethodCall) class THTreeList
	
	default abMethodCall := { |poObject, paBuffer, plBottom| poObject:Buffer(paBuffer, plBottom) }

	aoObject:TreeList(.T.)
	aoObject:Width(1)
	aAdd(::faList, { aoObject, abMethodCall })
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por recuperar uma string contendo a representa��o da lista de objetos
adicionados mais as informa��es adicionais
Args: aaBuffer, array, cont�m o array aonde ser� adicionada a string
      alBottom, l�gico, cont�m o flag para a utiliza��o do bottom
--------------------------------------------------------------------------------------
*/
method Buffer(aaBuffer, alBottom) class THTreeList
	Local nInd
	
	cAux := "<div id=" + ::Name() + " style='"
	if !empty(::fcBackground)
		if left(::fcBackground, 6) == "color:"
			cAux += "background:" + substr(::fcBackground,7)+";"
		else
			cAux += "background-image:url(" + urlImage(::fcBackground) + ");"
		endif	
	endif	         
	cAux += "width:" + buildMeasure(::Width()) + ";"
	if !empty(::Height())
		cAux += "height:"+ buildMeasure(::Height()) + ";"
	endif             
	cAux += "'>"
	aAdd(aaBuffer, cAux)
	
	// recupera as informa��es dos objetos da lista
	if len(::faList) > 0
		for nInd := 1 to len(::faList)
			eval(::faList[nInd][OBJETO_METHOD], ::faList[nInd][OBJETO], aaBuffer, alBottom)
		next
	endif	
	
	aAdd(aaBuffer, "</div>")
	
return

/*
--------------------------------------------------------------------------------------
Propriedade Background
Arg: acImageFile -> string, path+nome do arquivo a ser colocado como background
--------------------------------------------------------------------------------------
*/                         
method Background(acImageFile) class THTreeList

	property ::fcBackground := acImageFile

return ::fcBackground

/*
--------------------------------------------------------------------------------------
Propriedade Name
--------------------------------------------------------------------------------------
*/                         
method Name(acValue) class THTreeList
               
	property ::fcName := acValue
	
return ::fcName

/*
--------------------------------------------------------------------------------------
Propriedade Width
--------------------------------------------------------------------------------------
*/                         
method Width(anValue) class THTreeList
               
	property ::faCoord[1] := anValue
	
return ::faCoord[1]

/*
--------------------------------------------------------------------------------------
Propriedade Height
--------------------------------------------------------------------------------------
*/                         
method Height(anValue) class THTreeList
               
	property ::faCoord[2] := anValue
	
return ::faCoord[2]