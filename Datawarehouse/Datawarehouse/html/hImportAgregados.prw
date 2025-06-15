// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - cont�m os resultados de uma importa��o de agregados (coordenada X e Y)
//						e dos indicadores para uma tabela OU gr�fico de uma consulta
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.02.06 | Paulo R Vieira	| Fase 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe respons�vel por conter os resultados pela importa��o de um agregado
--------------------------------------------------------------------------------------
*/
Class TDWImportAgregados from TDWObject
	
	data fnID
	data faLevelX
	data faLevelY
	data faMeasures
	data flSucess
	
	method New(anID)
	method Free()
	method Clean()
	
	method ID(anID)
	method AgregX(aaValue)
	method AgregY(aaValue)
	method Measures(aaValue)
	method Sucess(alValue)
	
EndClass

/*
--------------------------------------------------------------------------------------
Construtor
--------------------------------------------------------------------------------------
*/
method New(anID) class TDWImportAgregados
	_Super:New()
	::Clean()
	::ID(anID)
return

/*
--------------------------------------------------------------------------------------
Destrutor
--------------------------------------------------------------------------------------
*/
method Free() class TDWImportAgregados
	::Clean()
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela limpeza para o objeto
--------------------------------------------------------------------------------------
*/
method Clean() class TDWImportAgregados
	::fnID				:= 0
	::flSucess	   		:= .T.
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do id
--------------------------------------------------------------------------------------
*/
method ID(anValue) class TDWImportAgregados
	property ::fnID := anValue
return ::fnID

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do nome
--------------------------------------------------------------------------------------
*/
method AgregX(aaValue) class TDWImportAgregados
	property ::faLevelX := aaValue
return ::faLevelX

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do Level/Coordernada Y
--------------------------------------------------------------------------------------
*/
method AgregY(aaValue) class TDWImportAgregados
	property ::faLevelY := aaValue
return ::faLevelY

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o do measures/indicadores
--------------------------------------------------------------------------------------
*/
method Measures(aaValue) class TDWImportAgregados
	property ::faMeasures := aaValue
return ::faMeasures

/*
--------------------------------------------------------------------------------------
M�todo respons�vel pela defini��o de sucesso da importa��o
--------------------------------------------------------------------------------------
*/
method Sucess(alValue) class TDWImportAgregados
	property ::flSucess := alValue
return ::flSucess