// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de uma express�o de um filtro
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de uma express�o de um filtro
--------------------------------------------------------------------------------------
*/
Class TDWImportExpression from TDWObject
	
	data fnID
	data flIsSQL
	data flDimExist
	data fnDimID
	data fcDimName
	data flDimFldExist
	data fnDimFldID
	data fcDimFldName
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method IsSQL(alValue)
	method DimExist(alVAlue)
	method DimID(anID)
	method DimName(acVAlue)
	method DimFldExist(alVAlue)
	method DimFldID(anID)
	method DimFldName(acVAlue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportExpression
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportExpression
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportExpression
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id deste filtro
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportExpression
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por definir flag se esta express�o � SQL ou QBE
--------------------------------------------------------------------------------------
*/
method IsSQL(alValue) class TDWImportExpression
	property ::flIsSQL := alValue
return ::flIsSQL

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por definir flag da exist�ncia ou n�o da dimens�o associada
--------------------------------------------------------------------------------------
*/
method DimExist(alVAlue) class TDWImportExpression
	property ::flDimExist := alValue
return ::flDimExist

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id da dimens�o associada
--------------------------------------------------------------------------------------
*/
method DimID(anValue) class TDWImportExpression
	property ::fnDimID := anValue
return ::fnDimID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome da dimens�o associada
--------------------------------------------------------------------------------------
*/
method DimName(acValue) class TDWImportExpression
	property ::fcDimName := acValue
return ::fcDimName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por definir flag da exist�ncia ou n�o na dimens�o do campo utilizado pela express�o
--------------------------------------------------------------------------------------
*/
method DimFldExist(alVAlue) class TDWImportExpression
	property ::flDimFldExist := alValue
return ::flDimFldExist

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id do campo da dimens�o utilizada na express�o
--------------------------------------------------------------------------------------
*/
method DimFldID(anValue) class TDWImportExpression
	property ::fnDimFldID := anValue
return ::fnDimFldID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do campo da dimens�o utilizada na express�o
--------------------------------------------------------------------------------------
*/
method DimFldName(acValue) class TDWImportExpression
	property ::fcDimFldName := acValue
return ::fcDimFldName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso de uma importa��o desta express�o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportExpression
	property ::flSucess := alValue
return ::flSucess