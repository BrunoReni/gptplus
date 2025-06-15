// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de uma dimens�o
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de uma dimens�o
--------------------------------------------------------------------------------------
*/
Class TDWImportDimension from TDWObject
	
	data fnID
	data fcName
	data faAttributes
	data faVirtAttrib
	data faDataSources
	data flOverrided
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method Attributes(aaValues)
	method VirtAttributes(aaValues)
	method DataSources(aaValues)
	method Overrided(alValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportDimension
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportDimension
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportDimension
	::fnID			:= 0
	::fcName		:= ""
	::faAttributes	:= {}
	::faDataSources := {}
	::flOverrided 	:= .F.
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id da dimens�o
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportDimension
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome da dimens�o
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportDimension
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos attributos da dimens�o
--------------------------------------------------------------------------------------
*/
method Attributes(aaValues) class TDWImportDimension
	property ::faAttributes := aaValues
return ::faAttributes

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos attributos virtuais da dimens�o
--------------------------------------------------------------------------------------
*/
method VirtAttributes(aaValues) class TDWImportDimension
	property ::faAttributes := aaValues
return ::faAttributes

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos datasources da dimens�o
--------------------------------------------------------------------------------------
*/
method DataSources(aaValues) class TDWImportDimension
	property ::faDataSources := aaValues
return ::faDataSources

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de remo��o/sobrescrita de uma dimens�o
--------------------------------------------------------------------------------------
*/
method Overrided(alValue) class TDWImportDimension
	property ::flOverrided := alValue
return ::flOverrided

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o de uma dimens�o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportDimension
	property ::flSucess := alValue
return ::flSucess