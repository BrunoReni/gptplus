// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um cubo
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um cubo
--------------------------------------------------------------------------------------
*/
Class TDWImportCube from TDWObject
	
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
method New(anID) class TDWImportCube
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportCube
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportCube
	::fnID			:= 0
	::fcName		:= ""
	::faAttributes	:= {}
	::faDataSources := {}
	::flOverrided 	:= .F.
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id do cubo
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportCube
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do cubo
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportCube
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos attributos do cubo
--------------------------------------------------------------------------------------
*/
method Attributes(aaValues) class TDWImportCube
	property ::faAttributes := aaValues
return ::faAttributes

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos attributos virtuais da dimens�o
--------------------------------------------------------------------------------------
*/
method VirtAttributes(aaValues) class TDWImportCube
	property ::faVirtAttrib := aaValues
return ::faVirtAttrib

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o dos datasources do cubo
--------------------------------------------------------------------------------------
*/
method DataSources(aaValues) class TDWImportCube
	property ::faDataSources := aaValues
return ::faDataSources

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de remo��o/sobrescrita de um cubo
--------------------------------------------------------------------------------------
*/
method Overrided(alValue) class TDWImportCube
	property ::flOverrided := alValue
return ::flOverrided

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o de um cubo
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportCube
	property ::flSucess := alValue
return ::flSucess