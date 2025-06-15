// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um agregado (coordenada X OU coordenada Y)
//						para uma tabela OU gr�fico de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um agregado Y
--------------------------------------------------------------------------------------
*/
Class TDWImportAgdo from TDWObject
	
	data fnID
	data flDimExist
	data fnDimID
	data fcDimName
	data fcFieldName
	data fcFieldValue
	data flSucess
	
	method New(anID)
	method DimExist(alValue)
	method DimID(anValue)
	method DimName(acValue)
	method FieldName(acValue)
	method FieldValue(acValue)
	method Free()
	method Clean()
	
	method ID(anID)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportAgdo
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportAgdo
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportAgdo
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportAgdo
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por definir flag da exist�ncia ou n�o da dimens�o associada a este agregado
--------------------------------------------------------------------------------------
*/
method DimExist(alValue) class TDWImportAgdo
	property ::flDimExist := alValue
return ::flDimExist

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id da dimens�o
--------------------------------------------------------------------------------------
*/
method DimID(anValue) class TDWImportAgdo
	property ::fnDimID := anValue
return ::fnDimID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome da dimens�o
--------------------------------------------------------------------------------------
*/
method DimName(acValue) class TDWImportAgdo
	property ::fcDimName := acValue
return ::fcDimName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do campo
--------------------------------------------------------------------------------------
*/
method FieldName(acValue) class TDWImportAgdo
	property ::fcFieldName := acValue
return ::fcFieldName

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do valor associado ao campo agregado
--------------------------------------------------------------------------------------
*/
method FieldValue(acValue) class TDWImportAgdo
	property ::fcFieldValue := acValue
return ::fcFieldValue

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso da importa��o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportAgdo
	property ::flSucess := alValue
return ::flSucess