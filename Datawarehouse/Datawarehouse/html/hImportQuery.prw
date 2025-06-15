// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de uma consulta
--------------------------------------------------------------------------------------
*/
Class TDWImportQuery from TDWObject
	
	data fnID
	data fcName
	data fcCubeName
	data flCubeExist
	data faVirtIndicators
	data faTables
	data faGraphics
	data faFilters
	data faAlerts
	data faDoc
	data flOverrided
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method CubeName(acVAlue)
	method CubeExist(alVAlue)
	method VirtIndicators(aaValues)
	method Tables(aaValues)
	method Graphics(aaValues)
	method Filters(aaValues)
	method Alerts(aaValues)  
	method Doc(aDoc)
	method Overrided(alValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportQuery
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportQuery
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportQuery
	::fnID				:= 0
	::fcName			:= ""
	::fcCubeName		:= ""
	::flCubeExist		:= .T.
	::faVirtIndicators 	:= {}
	::faTables			:= {}
	::faGraphics		:= {}
	::faFilters			:= {}
	::faAlerts			:= {}
	::flOverrided 		:= .F.
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id de uma consulta
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportQuery
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome de uma consulta
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportQuery
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome de uma consulta
--------------------------------------------------------------------------------------
*/
method CubeName(acValue) class TDWImportQuery
	property ::fcCubeName := acValue
return ::fcCubeName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por definir flag da exist�ncia ou n�o do cubo associado a esta consulta
--------------------------------------------------------------------------------------
*/
method CubeExist(alVAlue) class TDWImportQuery
	property ::flCubeExist := alValue
return ::flCubeExist

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos indicadores virtuais de uma consulta
--------------------------------------------------------------------------------------
*/
method VirtIndicators(aaValues) class TDWImportQuery
	property ::faVirtIndicators := aaValues
return ::faVirtIndicators

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o das tabelas de uma consulta
--------------------------------------------------------------------------------------
*/
method Tables(aaValues) class TDWImportQuery
	property ::faTables := aaValues
return ::faTables

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos gr�ficos de uma consulta
--------------------------------------------------------------------------------------
*/
method Graphics(aaValues) class TDWImportQuery
	property ::faGraphics := aaValues
return ::faGraphics

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos filtros de uma consulta
--------------------------------------------------------------------------------------
*/
method Filters(aaValues) class TDWImportQuery
	property ::faFilters := aaValues
return ::faFilters

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos alertas de uma consulta
--------------------------------------------------------------------------------------
*/
method Alerts(aaValues) class TDWImportQuery
	property ::faAlerts := aaValues
return ::faAlerts
               
/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o da documenta��o de uma consulta
--------------------------------------------------------------------------------------
*/
method Doc(aDoc) class TDWImportQuery
	property ::faDoc := aDoc
return ::faDoc

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de remo��o/sobrescrita de uma consulta
--------------------------------------------------------------------------------------
*/
method Overrided(alValue) class TDWImportQuery
	property ::flOverrided := alValue
return ::flOverrided

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o de uma consulta
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportQuery
	property ::flSucess := alValue
return ::flSucess