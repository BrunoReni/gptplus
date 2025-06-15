// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um attributo de uma dimens�o ou cubo
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um attributo de uma dimens�o ou cubo
--------------------------------------------------------------------------------------
*/
Class TDWImportAttribute from TDWObject
	
	data fnID
	data fcName
	data fnKeySeq
	data fcClasse
	data fcDimName
	data flDimExist
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method Name(acValue)
	method KeySeq(anValue)
	method Classe(acValue)
	method DimExist(alValue)
	method DimName(acValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportAttribute
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportAttribute
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportAttribute
	::fnID			:= 0
	::fcName		:= ""
	::flSucess		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id do attributo
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportAttribute
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do attributo
--------------------------------------------------------------------------------------
*/
method Name(acValue) class TDWImportAttribute
	property ::fcName := acValue
return ::fcName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do attributo
--------------------------------------------------------------------------------------
*/
method KeySeq(anValue) class TDWImportAttribute
	property ::fnKeySeq := anValue
return ::fnKeySeq

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do attributo
--------------------------------------------------------------------------------------
*/
method Classe(acValue) class TDWImportAttribute
	property ::fcClasse := acValue
return ::fcClasse

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela recupera��o da flag se existe ou n�o a dimens�a para este atributo
--------------------------------------------------------------------------------------
*/
method DimExist(alValue) class TDWImportAttribute
	property ::flDimExist := alValue
return ::flDimExist

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome da dimens�o relacionada com este attributo
--------------------------------------------------------------------------------------
*/
method DimName(acValue) class TDWImportAttribute
	property ::fcDimName := acValue
return ::fcDimName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o de um attributo de uma dimens�o ou cubo
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportAttribute
	property ::flSucess := alValue
return ::flSucess