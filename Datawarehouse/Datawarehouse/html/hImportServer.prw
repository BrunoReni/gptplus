// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um conex�o/server
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de uma conex�o
--------------------------------------------------------------------------------------
*/
Class TDWImportServer from TDWObject
	
	data fnID
	data fcName
	data flIgnored
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Ignored(alValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportServer
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportServer
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportServer
	::fnID			:= 0
	::fcName		:= ""
	::flIgnored 	:= .F.
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id da conex�o
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportServer
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome da conex�o
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportServer
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de remo��o/sobrescrita de uma conex�o
--------------------------------------------------------------------------------------
*/
method Ignored(alValue) class TDWImportServer
	property ::flIgnored := alValue
return ::flIgnored

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o de uma conex�o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportServer
	property ::flSucess := alValue
return ::flSucess