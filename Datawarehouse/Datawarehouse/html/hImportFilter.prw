// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um filtro para uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um filtro para uma consulta
--------------------------------------------------------------------------------------
*/
Class TDWImportFilter from TDWObject
	
	data fnID
	data fcName
	data fcType
	data faExprs
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Type(acValue)
	method Expressions(aaValues)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportFilter
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportFilter
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportFilter
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id deste filtro
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportFilter
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome deste filtro
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportFilter
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do tipo deste filtro
--------------------------------------------------------------------------------------
*/
method Type(acValue) class TDWImportFilter
	property ::fcType := acValue
return ::fcType

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o das express�es deste filtro
--------------------------------------------------------------------------------------
*/
method Expressions(aaValues) class TDWImportFilter
	property ::faExprs := aaValues
return ::faExprs

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o deste filtro
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportFilter
	property ::flSucess := alValue
return ::flSucess