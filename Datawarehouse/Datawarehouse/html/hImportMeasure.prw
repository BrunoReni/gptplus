// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de um indicador para uma
//						tabela OU gr�fico de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um indicador
--------------------------------------------------------------------------------------
*/
Class TDWImportMeasure from TDWObject
	
	data fnID
	data flIndExist
	data fcMeasField
	data fcMeasValue
	data flSucess
	
	method New(anID)	
	method ID(anID)
	method Free()
	method Clean()
	method Sucess(alValue)
	
	method IndExist(alValue)
	method MeasureField(acValue)
	method MeasureValue(acValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportMeasure
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportMeasure
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportMeasure
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportMeasure
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por definir flag da exist�ncia ou n�o do indicador associado a esta medi��o
--------------------------------------------------------------------------------------
*/
method IndExist(alValue) class TDWImportMeasure
	property ::flIndExist := alValue
return ::flIndExist

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome do campo associado a medi��o
--------------------------------------------------------------------------------------
*/
method MeasureField(acValue) class TDWImportMeasure
	property ::fcMeasField := acValue
return ::fcMeasField

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do valor associado ao campo de medi��o
--------------------------------------------------------------------------------------
*/
method MeasureValue(acValue) class TDWImportMeasure
	property ::fcMeasValue := acValue
return ::fcMeasValue

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso da importa��o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportMeasure
	property ::flSucess := alValue
return ::flSucess