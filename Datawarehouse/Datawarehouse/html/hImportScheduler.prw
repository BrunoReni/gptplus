// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um script/roteiro
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um script/roteiro
--------------------------------------------------------------------------------------
*/
Class TDWImportScheduler from TDWObject
	
	data fnID
	data fdDtBeg
	data fhHrBeg
	data fdDtEnd
	data fhHrEnd
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method DateBegin(acValue)
	method HourBegin(acValue)
	method DateEnd(acValue)
	method HourEnd(acValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportScheduler
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportScheduler
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportScheduler
	::fnID			:= 0
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportScheduler
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do Data de In�cio
--------------------------------------------------------------------------------------
*/
method DateBegin(acValue) class TDWImportScheduler
	property ::fdDtBeg := acValue
return ::fdDtBeg

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do Hora de In�cio
--------------------------------------------------------------------------------------
*/
method HourBegin(acValue) class TDWImportScheduler
	property ::fhHrBeg := acValue
return ::fhHrBeg

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do Data Final
--------------------------------------------------------------------------------------
*/
method DateEnd(acValue) class TDWImportScheduler
	property ::fdDtEnd := acValue
return ::fdDtEnd

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do Hora Final
--------------------------------------------------------------------------------------
*/
method HourEnd(acValue) class TDWImportScheduler
	property ::fhHrEnd := acValue
return ::fhHrEnd

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportScheduler
	property ::flSucess := alValue
return ::flSucess