// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um data source
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um data source
--------------------------------------------------------------------------------------
*/
Class TDWImportDS from TDWObject
	
	data fnID
	data fcName
	data fcType
	data faScripts
	data faScheduler
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method TypeConn(acValue)
	method Scripts(aaValue)
	method Schedulers(aaValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportDS
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportDS
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportDS
	::fnID			:= 0
	::fcName		:= ""
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id do data source
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportDS
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do data source
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportDS
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do tipo de conex�o do data source
--------------------------------------------------------------------------------------
*/
method TypeConn(acValue) class TDWImportDS
	property ::fcType := acValue 
return ::fcType

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos scripts do data source
--------------------------------------------------------------------------------------
*/
method Scripts(aaValue) class TDWImportDS
	property ::faScripts := aaValue
return ::faScripts

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos agendamentos do data source
--------------------------------------------------------------------------------------
*/
method Schedulers(aaValue) class TDWImportDS
	property ::faScheduler := aaValue
return ::faScheduler

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o de um data source
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportDS
	property ::flSucess := alValue
return ::flSucess