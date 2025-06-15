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
Class TDWImportScript from TDWObject
	
	data fnID
	data fcName
	data fcField
	data fcCpoorig
	data fcExpression
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Field(acValue)
	method Cpoorig(acValue)
	method Expression(acValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportScript
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportScript
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportScript
	::fnID			:= 0
	::fcName		:= ""
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportScript
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportScript
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do campo utilizado no roteiro
--------------------------------------------------------------------------------------
*/
method Field(acValue) class TDWImportScript
	property ::fcField := acValue
return ::fcField

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o da propriedade Cpoorig
--------------------------------------------------------------------------------------
*/
method Cpoorig(acValue) class TDWImportScript
	property ::fcCpoorig := acValue
return ::fcCpoorig

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o da propriedade Expression
--------------------------------------------------------------------------------------
*/
method Expression(acValue) class TDWImportScript
	property ::fcExpression := acValue
return ::fcExpression

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportScript
	property ::flSucess := alValue
return ::flSucess