// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : hXmlMetadado - Gerencia e processa a saida do meta dados
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 07.11.05 | Paulo R Vieira	  | Fase 3                            
// 28.10.05 | 0548-Alan Candido | FNC 00000004148/2008 (8.11) 00000004172/2008 (9.12)
//          |                   | Ajuste na verifica��o da exist�ncia ou n�o da conex�o
//          |                   | na lista de conex�es a serem processadas
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

#define XML_NAME			"datawarehouse"

#define DW_NAME_XML			"dw"
#define DW_GENERATE_DATE	"generate"
#define DW_USER				"user"
#define DW_VERSION			"version"
#define DW_TEMPLATE			"template"
#define DW_TARGET			"targetID"

#define NODE_SERVERS		"servers"
#define NODE_DIMENSIONS 	"dimensions"
#define NODE_CUBES			"cubes"
#define NODE_QUERYS			"querys"
#define NODE_DATASOURCES 	"datasources"
#define NODE_ATTRIBUTES 	"attributes"
#define NODE_SCRIPTS	  	"scripts"
#define NODE_SCHEDULERS		"schedulers"                          
#define NODE_QUERYVIRTUAL 	"virtualFields"
#define NODE_FILTERS		"filters"
#define NODE_ALERTS			"alerts"
#define NODE_DIM_X			"dimX"
#define NODE_DIM_Y			"dimY"
#define NODE_MEASURES		"measures"

#define CHILD_SERVER		"server"
#define CHILD_DIMENSION 	"dimension"
#define CHILD_CUBE			"cube"
#define CHILD_QUERY			"query"
#define CHILD_DATASOURCE 	"datasource"
#define CHILD_ATTRIBUTE 	"attribute"
#define CHILD_VIRTUAL		"virtual"
#define CHILD_SCRIPT		"script"
#define CHILD_SCHEDULER		"scheduler"
#define CHILD_FIELD			"field"
#define CHILD_GRAPHIC		"graphic"
#define CHILD_TABLE			"table"
#define CHILD_FILTER		"filter"
#define CHILD_EXPRESSION	"expression"
#define CHILD_EX			"expr"
#define CHILD_ALERT			"alert"
#define CHILD_ALERT_SEL		"alertSel"
#define CHILD_OPTIONS		"options" 
#define CHILD_DOC			"doc"
#define CHILD_DOC_HTML		"docHtml"

#define DATA_SOURCE			"datasource"

#define TYPE_MULTILINE		"multiLineText"
#define TYPE_SCRIPT			"scripts"
#define TYPE_SCHEDULER		"schedulers"
#define TYPE_VALIDA			"valida"
#define TYPE_EXPR			"expr"
#define TYPE_EXPRESSION		"expression"
#define TYPE_PROPERTY		"property"
#define TYPE_SUBEXPRESSION	"expression"
#define TYPE_ALERTPROPERTY	"property"
#define TYPE_ALERTSEL		"alertSel"
#define TYPE_LAST_VALUE		"lastValue"

#define MULTI_LINE			"multiline"
#define MULTI_ON			"on"
#define MULTILINE_LINE 		"line"
/*
--------------------------------------------------------------------------------------
Classe: TDWXmlMetaDado
Uso   : Objeto b�sico para p�gina��o do sistema
--------------------------------------------------------------------------------------
*/
class TDWXmlMetaDado from TDWObject

	// propriedades de dimens�o
	data faDimProp
	data faDimAttr
	data faDimDS

	// propriedades de cubo
	data faCubeProp
	data faCubeAttr
	data faCubeVirtAttr
	data faCubeExpAttr
	data faCubeDS

	// propriedades de consultas
	data faQueryProp
	data faQueryVirtAttr
	data faQueryTable
	data faQueryGraphic
	data faQueryFilter
	data faQueryAlert
	data faQueryDoc
	data faQueryHTMLDoc
	
	// propriedades referentes ao objeto de gera��o de XML
	data foXML
	data foXmlServer
	data foXmlDimension
	data foXmlCube
	data foXmlQuery
	
	// construtor
	method New(alTemplate, anIDTarget) constructor
	
	// destrutor
	method Free()

	// Limpa as propriedades de dimens�o/dimension
	method FreeDimension()
	
	// Limpa as propriedades de cubo/cube
	method FreeCube()
	
	// Limpa as propriedades de consulta/query
	method FreeQuery()
		
	// acessores de tipos
	method getTypeMultiLineText()
	method getTypeScript()
	method getTypeScheduler()
	method getTypeValida()
	method getTypeEx()
	method getTypeSubExpression()
	method getTypePropAlert()
	method getTypeAlertSel()
	method getTypeGraphic()
	method getTypeTable()
	
	// adiciona propriedade � uma dimens�o
	method addDimProperty(acPropName, acPropValue)
	
	// adiciona atributo � uma dimens�o
	method addDimAttribute(aaAttribute)
	
	// adiciona datasource � uma dimens�o
	method addDimDataSource(aaDataSource)
	
	// adiciona um atributo de tipo gen�rico � um datasource
	method addDimGenericAttrDS(acType, aaAttribute)
	
	// adiciona um tipo espec�fico de child de dimens�o
	method addDimension()
	
	// adiciona propriedade � um cubo
	method addCubeProperty(acPropName, acPropValue)
	
	// adiciona atributo � um cubo
	method addCubeAttribute(aaAttribute)
	
	// adiciona atributo virtual � um cubo
	method addCubeVirtualAttribute(aaAttribute)
	
	// adiciona datasource � um cubo
	method addCubeDataSource(aaDataSource)
		
	// adiciona um atributo de tipo gen�rico � um datasource
	method addCubeGenericAttrDS(acType, aaAttribute)
	
	// adiciona um tipo espec�fico de cubo
	method addCube()
	
	// adiciona propriedade � uma consulta
	method addQueryProperty(acPropName, acPropValue)
	
	// adiciona atributo virtual � uma consulta
	method addQueryVirtualAttribute(aaAttribute)
	
	// adiciona tabela � uma consulta
	method addQueryTable(aaProprieties, aaDimX, aaDimY, aaInd)
	
	// adiciona gr�fico � uma consulta
	method addQueryGraphic(aaProprieties, aaDimX, aaDimY, aaInd)
	
	// adiciona filtro � uma consulta
	method addQFilter(aaProperty, aaExression)
	
	// adiciona filtro � uma consulta
	method addQFiltProp(aaProperty)
	
	// adiciona express�o ao filtro de uma consulta
	method addQFiltExpr(aaExression)
	
	// adiciona um child alert ao node alerts
	method addQAlertSel(alAlertSel)
	
	// adiciona uma propriedade � um alert
	method addQAlertProperty(aaProperty)

	// adiciona uma express�o � um node alertSel
	method addQAlertExpression(acExpression)	
	                 
	// adiciona um documento especifico da cosulta
	method addQDoc(acDoc)      
	
	// Limpa documento simples
	method clearDoc()
	            
	// adiciona um documento em HTML especifico da consulta - Uso na integracao P9 - Indicadores Nativos
	method addQDocHTML(aDoc)

	// limpa os documentos HTML	
	method clearHTMLDoc()
	
	// adiciona um tipo espec�fico de consulta
	method addQuery()
	
	// verifica se o atributo connector passado exist na estrutura de xml
	method verifyServers(aaAttribNames, aaAttribValues)
	
	// adiciona um server � estrutura de xml
	method addServer(aaServer)
	
	// salva o arquivo
	method SaveFile(acFilename, alHeader, acEncoding, alMakeEmpty)

endclass

/*
--------------------------------------------------------------------------------------
Construtor da classe
Args: 	alTemplate, booleano, contendo se deve ou n�o exibir o campo template no arquivo xml
		anIDTarget, n�merico, caso seja uma c�pia de metadados este argumento � o id copiado
--------------------------------------------------------------------------------------
*/
method New(alTemplate, anIDTarget) class TDWXmlMetaDado
	Local oAtt
	
	_Super:New()
	
	::foXML 			:= TBIXMLNode():New(XML_NAME)
	::foXmlServer 		:= ::foXML:oAddChild(TBIXMLNode():New(NODE_SERVERS))
	
	::foXmlDimension	:= ::foXML:oAddChild(TBIXMLNode():New(NODE_DIMENSIONS))
	::foXmlCube			:= ::foXML:oAddChild(TBIXMLNode():New(NODE_CUBES))
	::foXmlQuery 		:= ::foXML:oAddChild(TBIXMLNode():New(NODE_QUERYS))
		
	oAtt := ::foXML:oAttrib(TBIXMLAttrib():New())
	
	oAtt:lSet(DW_NAME_XML, oSigaDW:DWCurr()[2])
	oAtt:lSet(DW_GENERATE_DATE, dtos(date()) + " " + time())
	if valtype(oUserDW) == "O"
		oAtt:lSet(DW_USER, oUserDW:UserName())
	else
		oAtt:lSet(DW_USER, "(DW JOB)")
	endif
	oAtt:lSet(DW_VERSION, DWBuild())
	oAtt:lSet(DW_TEMPLATE, alTemplate)
	oAtt:lSet(DW_TARGET, anIDTarget)
	
	::faDimProp := {}
	::faDimAttr	:= {}
	::faDimDS	:= {}
	
	::faCubeProp		:= {}
	::faCubeAttr		:= {}
	::faCubeVirtAttr 	:= {}
	::faCubeExpAttr	:= {}
	::faCubeDS			:= {}
	
	::faQueryProp		:= {}
	::faQueryVirtAttr	:= {}
	::faQueryTable		:= {}
	::faQueryGraphic	:= {}
	::faQueryFilter		:= {}
	::faQueryAlert		:= {}
	::faQueryDoc		:= {}
	::faQueryHTMLDoc 	:= {}
return

/*
--------------------------------------------------------------------------------------
Destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method Free() class TDWXmlMetaDado
	_Super:Free()
return

/*
--------------------------------------------------------------------------------------
Limpa as propriedades de dimens�o/dimension
Args: 
--------------------------------------------------------------------------------------
*/
method FreeDimension() class TDWXmlMetaDado
	::faDimProp := {}
	::faDimAttr	:= {}
	::faDimDS	:= {}
return

/*
--------------------------------------------------------------------------------------
Limpa as propriedades de cubo/cube
Args: 
--------------------------------------------------------------------------------------
*/
method FreeCube() class TDWXmlMetaDado
	::faCubeProp		:= {}
	::faCubeAttr		:= {}
	::faCubeVirtAttr 	:= {}
	::faCubeExpAttr	:= {}
	::faCubeDS			:= {}
return

/*
--------------------------------------------------------------------------------------
Limpa as propriedades de consulta/query
Args: 
--------------------------------------------------------------------------------------
*/
method FreeQuery() class TDWXmlMetaDado
	::faQueryProp		:= {}
	::faQueryVirtAttr	:= {}
	::faQueryTable		:= {}
	::faQueryGraphic	:= {}
	::faQueryFilter	:= {}
return

/*
--------------------------------------------------------------------------------------
Acessor do tipo de atributo MultiLineText de um datasource
Args:
--------------------------------------------------------------------------------------
*/
method getTypeMultiLineText() class TDWXmlMetaDado
return TYPE_MULTILINE

/*
--------------------------------------------------------------------------------------
Acessor do tipo de atributo Script de um datasource
Args:
--------------------------------------------------------------------------------------
*/
method getTypeScript() class TDWXmlMetaDado
return TYPE_SCRIPT

/*
--------------------------------------------------------------------------------------
Acessor do tipo de atributo Scheduler de um datasource
Args:
--------------------------------------------------------------------------------------
*/
method getTypeScheduler() class TDWXmlMetaDado
return TYPE_SCHEDULER

/*
--------------------------------------------------------------------------------------
Acessor do tipo de atributo Valida de um datasource
Args:
--------------------------------------------------------------------------------------
*/
method getTypeValida() class TDWXmlMetaDado
return TYPE_VALIDA

/*
--------------------------------------------------------------------------------------
Acessor do tipo de atributo Expr de um datasource
Args:
--------------------------------------------------------------------------------------
*/
method getTypeEx() class TDWXmlMetaDado
return TYPE_EXPR

/*
--------------------------------------------------------------------------------------
Acessor do tipo de atributo Expression de um datasource
Args:
--------------------------------------------------------------------------------------
*/
method getTypeSubExpression() class TDWXmlMetaDado
return TYPE_SUBEXPRESSION

/*
--------------------------------------------------------------------------------------
Acessor do tipo de propriedade de alert de uma Expression
Args:
--------------------------------------------------------------------------------------
*/
method getTypePropAlert() class TDWXmlMetaDado
return TYPE_ALERTPROPERTY

/*
--------------------------------------------------------------------------------------
Acessor do tipo de alertSel de uma Expression
Args:
--------------------------------------------------------------------------------------
*/
method getTypeAlertSel() class TDWXmlMetaDado
return TYPE_ALERTSEL

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma propriedade � uma dimens�o,
para posterior adi��o ao xml
Args: acPropName, string, contendo o nome da propriedade
		acPropValue, string, contendo o valor para a propriedade
--------------------------------------------------------------------------------------
*/
method addDimProperty(acPropName, acPropValue) class TDWXmlMetaDado
	aAdd(::faDimProp, {acPropName, acPropValue})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um atributo completo � uma dimens�o,
para posterior adi��o ao xml.
Args: aaAttribute, array de array, contendo todas as propriedades de um atributo
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addDimAttribute(aaAttribute) class TDWXmlMetaDado
	aAdd(::faDimAttr, aaAttribute)
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um datasource completo � uma dimens�o,
para posterior adi��o ao xml.
Args: aaDataSource, array de array, contendo todas as propriedades de um datasource
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addDimDataSource(aaDataSource) class TDWXmlMetaDado
	aAdd(::faDimDS, { DATA_SOURCE, aaDataSource })
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um atributo de tipo gen�rico � um datasource.
Este atributo ficar� entre as chaves de xml de inicio e fim do datasource.
Args: acType, string, contendo o tipo do atributo gen�rico, podendo ser:
			- MultiLineText, recuperado atrav�s do m�todo getTypeMultiLineTextDS()
			- Script, recuperado atrav�s do m�todo getTypeScriptDS()
			- Scheduler, recuperado atrav�s do m�todo getTypeSchedulerDS()
			- Valida, recuperado atrav�s do m�todo getTypeValidaDS()
			- Expr, recuperado atrav�s do m�todo getTypeExDS()
		aaScript, array de array, contendo todas as propriedades do script
--------------------------------------------------------------------------------------
*/
method addDimGenericAttrDS(acType, aaAttribute) class TDWXmlMetaDado
	aAdd(::faDimDS, {acType, aaAttribute})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma dimens�o completa ao xml.
Para executar corretamente, esse m�todo necessita de que sejam adicionados os
dados referntes � esta dimens�o atrav�s dos seguintes m�todos de defini��o de propriedades auxiliares:
- addDimProperty(acPropName, acPropValue)
- addDimAttribute(aaAttribute)
- addDimDataSource(aaDataSource)
- addDimGenericAttrDS(acType, aaAttribute) (para cada tipo de atributo necess�rio ao datasource)
Args: 
--------------------------------------------------------------------------------------
*/
method addDimension() class TDWXmlMetaDado
	Local oDimension
	Local oAllAttributes, oAttribute, oNewAttribute, oNewNode
	Local oAllDataSources, oDataSource
	Local oAllScripts, oScript
	Local oAllSchedulers, oScheduler
	Local nInd, nInd2
	Local aScripts
	Local aSchedulers
	Local aMultiLineText
	Local aDataSource
	Local cValue, aValue
	
	// cria um node de dimens�o
	oDimension 	:= ::foXmlDimension:oAddChild(TBIXMLNode():New(CHILD_DIMENSION))
	
	// define as propriedades da dimens�o
	oAttribute 	:= oDimension:oAttrib(TBIXMLAttrib():New())
	for nInd := 1 to len(::faDimProp)
		oAttribute:lSet(DWSTR(::faDimProp[nInd][1]), ::faDimProp[nInd][2])
	next
	
	// define os atributos da dimens�o
	oAllAttributes	:= oDimension:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
	for nInd := 1 to len(::faDimAttr)
		oAttribute		:= oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_ATTRIBUTE))
		oNewAttribute 	:= oAttribute:oAttrib(TBIXMLAttrib():New())
		for nInd2 := 1 to len(::faDimAttr[nInd])
			oNewAttribute:lSet(::faDimAttr[nInd][nInd2][1], ::faDimAttr[nInd][nInd2][2])
	   next
	next

	// define as propriedades de datasources para a dimens�o
	oAllDataSources 	:= oDimension:oAddChild(TBIXMLNode():New(NODE_DATASOURCES))
  	
	for nInd := 1 to len(::faDimDS)
		if ::faDimDS[nInd][1] == DATA_SOURCE
			oDataSource	 := oAllDataSources:oAddChild(TBIXMLNode():New(CHILD_DATASOURCE))
		    oAllScripts			:= oDataSource:oAddChild(TBIXMLNode():New(NODE_SCRIPTS))
			oAllSchedulers		:= oDataSource:oAddChild(TBIXMLNode():New(NODE_SCHEDULERS))

			oNewAttribute := oDataSource:oAttrib(TBIXMLAttrib():New())
			aDataSource := ::faDimDS[nInd][2]
			for nInd2 := 1 to len(aDataSource)
				oNewAttribute:lSet(aDataSource[nInd2][1], aDataSource[nInd2][2])
			next
			
		elseif ::faDimDS[nInd][1] == TYPE_MULTILINE
			aMultiLineText := ::faDimDS[nInd][2]  
			if !empty(aMultiLineText[2])
				oNewNode		:= oDataSource:oAddChild(TBIXMLNode():New(aMultiLineText[1]))
				oNewAttribute	:= oNewNode:oAttrib(TBIXMLAttrib():New())
				oNewAttribute:lSet(MULTI_LINE, MULTI_ON)
				cValue := strTran(aMultiLineText[2], CRLF, "�")
				aValue := dwToken(cValue, "�")   
				for nInd2 := 1 to len(aValue)
					oNewNode2 := oNewNode:oAddChild(TBIXMLNode():New(MULTILINE_LINE, aValue[nInd2]))
				next
			endif			
		elseif ::faDimDS[nInd][1] == TYPE_SCRIPT
			aScripts 		:= ::faDimDS[nInd][2]
			oScript			:= oAllScripts:oAddChild(TBIXMLNode():New(CHILD_SCRIPT))
			oNewAttribute	:= oScript:oAttrib(TBIXMLAttrib():New())
			for nInd2 := 1 to len(aScripts)
				if aScripts[nInd2][1] == TYPE_VALIDA
					oScript:oAddChild(TBIXMLNode():New(TYPE_VALIDA, aScripts[nInd2][2]))
				elseif aScripts[nInd2][1] == TYPE_EXPR
					oScript:oAddChild(TBIXMLNode():New(CHILD_EX, aScripts[nInd2][2]))
				else
					oNewAttribute:lSet(aScripts[nInd2][1], aScripts[nInd2][2])
				endif
			next
			
		elseif ::faDimDS[nInd][1] == TYPE_SCHEDULER
			aSchedulers 	:= ::faDimDS[nInd][2]
			oScheduler		:= oAllSchedulers:oAddChild(TBIXMLNode():New(CHILD_SCHEDULER))
			oNewAttribute	:= oScheduler:oAttrib(TBIXMLAttrib():New())
			for nInd2 := 1 to len(aSchedulers)
				oNewAttribute:lSet(aSchedulers[nInd2][1], aSchedulers[nInd2][2])
			next
			
		endif
	next
	
	// Limpa as propriedades de dimens�o/dimension
	::FreeDimension()
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma propriedade � um cubo,
para posterior adi��o ao xml
Args: acPropName, string, contendo o nome da propriedade
		acPropValue, string, contendo o valor para a propriedade
--------------------------------------------------------------------------------------
*/
method addCubeProperty(acPropName, acPropValue) class TDWXmlMetaDado
	aAdd(::faCubeProp, {acPropName, acPropValue})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um atributo completo � um cubo,
para posterior adi��o ao xml.
Args: aaAttribute, array de array, contendo todas as propriedades de um atributo
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addCubeAttribute(aaAttribute) class TDWXmlMetaDado
	aAdd(::faCubeAttr, aaAttribute)
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um atributo virtual completo � um cubo,
para posterior adi��o ao xml.
Args: aaAttribute, array de array, contendo todas as propriedades de um atributo virtual
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addCubeVirtualAttribute(aaAttribute) class TDWXmlMetaDado
	aAdd(::faCubeVirtAttr, aaAttribute)
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um datasource completo � um cubo,
para posterior adi��o ao xml.
Args: aaDataSource, array de array, contendo todas as propriedades de um datasource
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addCubeDataSource(aaDataSource) class TDWXmlMetaDado
	aAdd(::faCubeDS, { DATA_SOURCE, aaDataSource })
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um atributo de tipo gen�rico � um datasource.
Este atributo ficar� entre as chaves de xml de inicio e fim do datasource.
Args: acType, string, contendo o tipo do atributo gen�rico, podendo ser:
			- MultiLineText, recuperado atrav�s do m�todo getTypeMultiLineText()
			- Script, recuperado atrav�s do m�todo getTypeScript()
			- Scheduler, recuperado atrav�s do m�todo getTypeScheduler()
			- Valida, recuperado atrav�s do m�todo getTypeValida()
			- Expr, recuperado atrav�s do m�todo getTypeEx()
			- Expresssion, recuperado atrav�s do m�todo getTypeEx()
		aaScript, array de array, contendo todas as propriedades do script
		
		
		
			method ()
	method ()
	method ()
	method ()
	method ()
	method ()
	method getTypePropAlert()
	method getTypeAlertSel()
	method getTypeGraphic()
	method getTypeTable()

--------------------------------------------------------------------------------------
*/
method addCubeGenericAttrDS(acType, aaAttribute) class TDWXmlMetaDado
	aAdd(::faCubeDS, {acType, aaAttribute})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um cubo completo ao xml.
Para executar corretamente, esse m�todo necessita de que sejam adicionados os
dados referntes � esta dimens�o atrav�s dos seguintes m�todos de defini��o de propriedades auxiliares:
- addDimProperty(acPropName, acPropValue)
- addDimAttribute(aaAttribute)
- addDimDataSource(aaDataSource)
- addDimGenericAttrDS(acType, aaAttribute) (para cada tipo de atributo necess�rio ao datasource)
Args: 
--------------------------------------------------------------------------------------
*/
method addCube() class TDWXmlMetaDado
	Local oCube
	Local oAllAttributes, oAttribute, oNewAttribute, oNewNode, oSubExpression
	Local oAllDataSources, oDataSource
	Local oAllScripts, oScript
	Local oAllSchedulers, oScheduler
	Local nInd, nInd2
	Local aScripts
	Local aSchedulers
	Local aMultiLineText
	Local aDataSource
	Local cValue, aValue
	
	// cria um node de cubo
	oCube	:= ::foXmlCube:oAddChild(TBIXMLNode():New(CHILD_CUBE))
	
	// define as propriedades do cubo
	oAttribute 	:= oCube:oAttrib(TBIXMLAttrib():New())
	for nInd := 1 to len(::faCubeProp)
		oAttribute:lSet(DWSTR(::faCubeProp[nInd][1]), ::faCubeProp[nInd][2])
	next
	
	// define os atributos do cubo
	oAllAttributes	:= oCube:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
	for nInd := 1 to len(::faCubeAttr)
		oAttribute		:= oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_ATTRIBUTE))
		oNewAttribute 	:= oAttribute:oAttrib(TBIXMLAttrib():New())
		for nInd2 := 1 to len(::faCubeAttr[nInd])
			oNewAttribute:lSet(::faCubeAttr[nInd][nInd2][1], ::faCubeAttr[nInd][nInd2][2])
	   next
	next
	
	// define os atributos virtuais do cubo
	for nInd := 1 to len(::faCubeVirtAttr)
		oAttribute		:= oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_VIRTUAL))
		oNewAttribute 	:= oAttribute:oAttrib(TBIXMLAttrib():New())

		for nInd2 := 1 to len(::faCubeVirtAttr[nInd])
			// campo especial de subexpression
			if ::faCubeVirtAttr[nInd][1][1] == TYPE_SUBEXPRESSION
				oSubExpression := oAttribute:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, ::faCubeVirtAttr[nInd][2]))
				oNewAttribute := oSubExpression:oAttrib(TBIXMLAttrib():New())
				oNewAttribute:lSet(::faCubeVirtAttr[nInd][3], ::faCubeVirtAttr[nInd][4])
			else
				oNewAttribute:lSet(::faCubeVirtAttr[nInd][nInd2][1], ::faCubeVirtAttr[nInd][nInd2][2])
			endif
	   next
	next

	// define as propriedades de datasources para o cubo
	oAllDataSources 	:= oCube:oAddChild(TBIXMLNode():New(NODE_DATASOURCES))
		
	for nInd := 1 to len(::faCubeDS)
		if ::faCubeDS[nInd][1] == DATA_SOURCE
			oDataSource	  		:= oAllDataSources:oAddChild(TBIXMLNode():New(CHILD_DATASOURCE))
			oAllScripts			:= oDataSource:oAddChild(TBIXMLNode():New(NODE_SCRIPTS))
			oAllSchedulers		:= oDataSource:oAddChild(TBIXMLNode():New(NODE_SCHEDULERS))

			oNewAttribute 	:= oDataSource:oAttrib(TBIXMLAttrib():New())
			aDataSource := ::faCubeDS[nInd][2]
			for nInd2 := 1 to len(aDataSource)
				oNewAttribute:lSet(aDataSource[nInd2][1], aDataSource[nInd2][2])
			next
			
		elseif ::faCubeDS[nInd][1] == TYPE_MULTILINE
			aMultiLineText := ::faCubeDS[nInd][2]
			if !empty(aMultiLineText[1]) .and. !empty(aMultiLineText[2])
				oNewNode		:= oDataSource:oAddChild(TBIXMLNode():New(aMultiLineText[1]))
				oNewAttribute	:= oNewNode:oAttrib(TBIXMLAttrib():New())
				oNewAttribute:lSet(MULTI_LINE, MULTI_ON)
				cValue := strTran(aMultiLineText[2], CRLF, "�")
				aValue := dwToken(cValue, "�")   
				for nInd2 := 1 to len(aValue)
					oNewNode2 := oNewNode:oAddChild(TBIXMLNode():New(MULTILINE_LINE, aValue[nInd2]))
				next
			endif
		elseif ::faCubeDS[nInd][1] == TYPE_SCRIPT
			aScripts 		:= ::faCubeDS[nInd][2]
			oScript			:= oAllScripts:oAddChild(TBIXMLNode():New(CHILD_SCRIPT))
			oNewAttribute	:= oScript:oAttrib(TBIXMLAttrib():New())
			for nInd2 := 1 to len(aScripts)
				if aScripts[nInd2][1] == TYPE_VALIDA
					oScript:oAddChild(TBIXMLNode():New(TYPE_VALIDA, aScripts[nInd2][2]))
				elseif aScripts[nInd2][1] == TYPE_EXPR 
					//oScript:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, aScripts[nInd2][2]))
					oScript:oAddChild(TBIXMLNode():New(CHILD_EX, aScripts[nInd2][2]))
				else
					oNewAttribute:lSet(aScripts[nInd2][1], aScripts[nInd2][2])
				endif
			next
			
		elseif ::faCubeDS[nInd][1] == TYPE_SCHEDULER
			aSchedulers 	:= ::faCubeDS[nInd][2]
			oScheduler		:= oAllSchedulers:oAddChild(TBIXMLNode():New(CHILD_SCHEDULER))
			oNewAttribute	:= oScheduler:oAttrib(TBIXMLAttrib():New())
			for nInd2 := 1 to len(aSchedulers)
				oNewAttribute:lSet(aSchedulers[nInd2][1], aSchedulers[nInd2][2])
			next
			
		endif
	next
	
	// Limpa as propriedades de cubo/cube
	::FreeCube()
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma propriedade � uma consulta,
para posterior adi��o ao xml
Args: acPropName, string, contendo o nome da propriedade
		acPropValue, string, contendo o valor para a propriedade
--------------------------------------------------------------------------------------
*/
method addQueryProperty(acPropName, acPropValue) class TDWXmlMetaDado
	aAdd(::faQueryProp, {acPropName, acPropValue})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um atributo virtual completo � uma consulta,
para posterior adi��o ao xml.
Args: aaAttribute, array de array, contendo todas as propriedades de um atributo virtual
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addQueryVirtualAttribute(aaAttribute) class TDWXmlMetaDado
	aAdd(::faQueryVirtAttr, aaAttribute)
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma tabela � uma consulta, para posterior adi��o ao xml.
Args: 	aaProprieties, array, cont�m as proprieades da tabela
		aaDimX, array, cont�m os valores para a dimens�o X da tabela
		aaDimY, array, cont�m os valores para a dimens�o Y da tabela
		aaInd, array, cont�m os indicadores de mensura��o da tabela
--------------------------------------------------------------------------------------
*/
method addQueryTable(aaProprieties, aaDimX, aaDimY, aaInd) class TDWXmlMetaDado
	aAdd(::faQueryTable, {aaProprieties, aaDimX, aaDimY, aaInd})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um gr�fico � uma consulta, para posterior adi��o ao xml.
Args: 	aaProprieties, array, cont�m as proprieades do gr�fico
		aaDimX, array, cont�m os valores para a dimens�o X do gr�fico
		aaDimY, array, cont�m os valores para a dimens�o Y do gr�fico
		aaInd, array, cont�m os indicadores de mensura��o do gr�fico
--------------------------------------------------------------------------------------
*/
method addQueryGraphic(aaProprieties, aaDimX, aaDimY, aaInd) class TDWXmlMetaDado
	aAdd(::faQueryGraphic, {aaProprieties, aaDimX, aaDimY, aaInd})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar propriedades � um filtro de uma consulta,
para posterior adi��o ao xml.
Args: aaProperty, array de array, contendo as propriedades de um filtro
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addQFiltProp(aaProperty) class TDWXmlMetaDado
	aAdd(::faQueryFilter, {TYPE_PROPERTY, aaProperty})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma express�o � um filtro de uma consulta,
para posterior adi��o ao xml.
Args: aaExression, array de array, contendo as expressions de um filtro
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addQFiltExpr(aaExression) class TDWXmlMetaDado
	aAdd(::faQueryFilter, {TYPE_EXPRESSION, aaExression})
return	

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um child alert ao node alerts
Args: alAlertSel, booleano, contendo o valor do node
--------------------------------------------------------------------------------------
*/
method addQAlertSel(alAlertSel) class TDWXmlMetaDado
	aAdd(::faQueryAlert, { TYPE_ALERTSEL, alAlertSel } )
return                    

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma propriedade � um alert
Args: aaProperty, array de array, contendo as propriedades
--------------------------------------------------------------------------------------
*/
method addQAlertProperty(aaProperty) class TDWXmlMetaDado
	aAdd(::faQueryAlert, { TYPE_ALERTPROPERTY, aaProperty})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma express�o � um node alertSel
Args: aaExpression, array de array, contendo as express�es
--------------------------------------------------------------------------------------
*/	
method addQAlertExpression(acExpression) class TDWXmlMetaDado
	aAdd(::faQueryAlert, {TYPE_EXPRESSION, acExpression})
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicinar a documentacao de uma consulta
Args: acDoc, array de String,  contendo a documentacao
--------------------------------------------------------------------------------------
*/
method addQDoc(acDoc) class TDWXmlMetaDado
	aAdd( ::faQueryDoc, acDoc )
return          
                              
/*
--------------------------------------------------------------------------------------
M�todo responsavel por limpar a lista de documentos das consultas
Args: nenhum
--------------------------------------------------------------------------------------
*/
method clearDoc () class TDWXmlMetaDado
	::faQueryDoc := {}
return

/* 
---------------------------------------------------------------------------------------
M�todp respons�vel por acidionar a documentacao em formato HTML - Integracao P9
Args: acDoc, array de String, contendo o HTML
---------------------------------------------------------------------------------------
*/
method addQDocHTML (acDoc) class TDWXmlMetaDado
	aAdd( ::faQueryHTMLDoc, acDoc )
return
  
/*
--------------------------------------------------------------------------------------
M�todo responsavel por limpar a lista de documentos HTML das consultas
Args: nenhum
--------------------------------------------------------------------------------------
*/ 
method clearHTMLDoc () class TDWXmlMetaDado
	::faQueryHTMLDoc := {}
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar uma consulta completa ao xml.
Para executar corretamente, esse m�todo necessita de que sejam adicionados os
dados referntes � esta dimens�o atrav�s dos seguintes m�todos de defini��o de propriedades auxiliares:
- addDimProperty(acPropName, acPropValue)
- addDimAttribute(aaAttribute)
- addDimDataSource(aaDataSource)
- addDimGenericAttrDS(acType, aaAttribute) (para cada tipo de atributo necess�rio ao datasource)
Args: 
--------------------------------------------------------------------------------------
*/
method addQuery() class TDWXmlMetaDado
	Local oQuery
	Local oNewAttribute, oField, oGraphic, oTable, oAllFilters, oFilter, oExpression, oNewExpression
	Local oAllAlerts, oAlert, oDimX, oDimY, oAllAttributes, oMeasure
	Local nInd, nInd2
	Local aProperties, aExpression, aDoc
	Local aDimX, aDimY, aInd
	
	// cria um node de query
	oQuery := ::foXmlQuery:oAddChild(TBIXMLNode():New(CHILD_QUERY))
	
	// define as propriedades da consulta
	oNewAttribute 	:= oQuery:oAttrib(TBIXMLAttrib():New())
	for nInd := 1 to len(::faQueryProp)
		oNewAttribute:lSet(DWSTR(::faQueryProp[nInd][1]), ::faQueryProp[nInd][2])
	next
	
	// define os atributos virtuais da consulta
	oVirtual		:= oQuery:oAddChild(TBIXMLNode():New(NODE_QUERYVIRTUAL))
	for nInd := 1 to len(::faQueryVirtAttr)
		oField	:= oVirtual:oAddChild(TBIXMLNode():New(CHILD_FIELD))
		// campo especial de subexpression
		if ::faQueryVirtAttr[nInd][1][1] == TYPE_SUBEXPRESSION
			oSubExpression := oField:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, ::faQueryVirtAttr[nInd][2]))
			oNewAttribute := oSubExpression:oAttrib(TBIXMLAttrib():New())
			oNewAttribute:lSet(::faQueryVirtAttr[nInd][3], ::faQueryVirtAttr[nInd][4])
		else
			oNewAttribute 	:= oField:oAttrib(TBIXMLAttrib():New(CHILD_FIELD))
			for nInd2 := 1 to len(::faQueryVirtAttr[nInd])
				// campo especial de subexpression
				if ::faQueryVirtAttr[nInd][nInd2][1] == TYPE_SUBEXPRESSION
					oSubExpression := oField:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, ::faQueryVirtAttr[nInd][nInd2][2]))
					oNewAttribute := oSubExpression:oAttrib(TBIXMLAttrib():New())
					oNewAttribute:lSet(::faQueryVirtAttr[nInd][nInd2][3], ::faQueryVirtAttr[nInd][nInd2][4])
				else
					oNewAttribute:lSet(::faQueryVirtAttr[nInd][nInd2][1], ::faQueryVirtAttr[nInd][nInd2][2])
				endif
		   next
		endif
	next
	
	// define os filtros da consulta
	oAllFilters := oQuery:oAddChild(TBIXMLNode():New(NODE_FILTERS))
	if len(::faQueryFilter) > 0
		for nInd := 1 to len(::faQueryFilter)
			oFilter := oAllFilters:oAddChild(TBIXMLNode():New(CHILD_FILTER))
			
			// 1 s�o as propriedades e 2 � a express�o
			aProperties := ::faQueryFilter[nInd][1]
			aExpression := ::faQueryFilter[nInd][2]
			
			// recupera/cria o xml para as propriedades do filtro
			oNewAttribute := oFilter:oAttrib(TBIXMLAttrib():New())
			for nInd2 := 1 to len(aProperties)
				oNewAttribute:lSet(aProperties[nInd2][1], aProperties[nInd2][2])
		   	next
			
			// recupera/cria o xml para as express�es do filtro
			if valType(aExpression) == "A" .and. len(aExpression) > 0
				if valType(aExpression[1]) == "A"
					oExpression := oFilter:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION))
					oNewAttribute := oExpression:oAttrib(TBIXMLAttrib():New())
					for nInd2 := 1 to len(aExpression)
						if valType(aExpression[nInd2]) == "A" .and. !(aExpression[nInd2][1] == TYPE_EXPRESSION)
							oNewAttribute:lSet(aExpression[nInd2][1], aExpression[nInd2][2])
						elseif aExpression[nInd2][1] == TYPE_EXPRESSION
							// caso seja uma express�o acrescenta o valor da express�o do n� xml <expression> atual
							If valType(aExpression[nInd2][2]) == "C"
								oNewExpression := oExpression:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, aExpression[nInd2][2]))
							Else
								oNewExpression := oExpression:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, aExpression[nInd2][2][1]))
								oNewAttribute := oNewExpression:oAttrib(TBIXMLAttrib():New())
								oNewAttribute:lSet(TYPE_LAST_VALUE, aExpression[nInd2][2][2])
							EndIf
							
							// E se houver pr�xima express�o CRIA um novo n� xml <expression>
							if nInd2 < len(aExpression)
								oExpression := oFilter:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION))
								oNewAttribute := oExpression:oAttrib(TBIXMLAttrib():New())
							endif
						endif
					next
				elseif aExpression[1] == TYPE_EXPRESSION
					oExpression := oFilter:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION))
					oExpression:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, aExpression[2]))
				endif
			endif
		next
	endif
	
	// define os alertas da consulta
	if len(::faQueryAlert) > 0
		oAllAlerts := oQuery:oAddChild(TBIXMLNode():New(NODE_ALERTS))
		oAlert := oAllAlerts:oAddChild(TBIXMLNode():New(CHILD_ALERT))
		for nInd := 1 to len(::faQueryAlert)
			// recupera/cria o xml para as express�es do filtro
			if ::faQueryAlert[nInd][1] == TYPE_PROPERTY
				oNewAttribute := oAlert:oAttrib(TBIXMLAttrib():New())
				aProperties := ::faQueryAlert[nInd][2]
				for nInd2 := 1 to len(aProperties)
					oNewAttribute:lSet(aProperties[nInd2][1], aProperties[nInd2][2])
				next
			elseif ::faQueryAlert[nInd][1] == TYPE_EXPRESSION
				oAlert:oAddChild(TBIXMLNode():New(CHILD_EXPRESSION, ::faQueryAlert[nInd][2]))
			elseif ::faQueryAlert[nInd][1] == TYPE_ALERTSEL
				if ::faQueryAlert[nInd][2] == "T" .OR. ::faQueryAlert[nInd][2] == "F"
					if nInd > 1
						oAlert := oAllAlerts:oAddChild(TBIXMLNode():New(CHILD_ALERT))					
					endif
					oAlertSel := oAlert:addChild(TBIXMLNode():New(CHILD_ALERT_SEL, '"' + ::faQueryAlert[nInd][2] + '"'))
				endif
			endif
		next
	endif
	
	// define as tabelas da consulta
	oTable			:= oQuery:oAddChild(TBIXMLNode():New(CHILD_TABLE))
	oDimX 			:= oTable:oAddChild(TBIXMLNode():New(NODE_DIM_X))
	oDimY 			:= oTable:oAddChild(TBIXMLNode():New(NODE_DIM_Y))
	oMeasure		:= oTable:oAddChild(TBIXMLNode():New(NODE_MEASURES))
	oNewAttribute 	:= oTable:oAttrib(TBIXMLAttrib():New())
	for nInd := 1 to len(::faQueryTable)
		// 1 s�o as propriedades da tabela, 2 s�o os valores da dimens�o x 3 s�o os valores da dimens�o y e 4 s�o os indicadores
		aProperties := ::faQueryTable[nInd][1]
		aDimX 		:= ::faQueryTable[nInd][2]
		aDimY		:= ::faQueryTable[nInd][3]
		aInd		:= ::faQueryTable[nInd][4]
		
		// define as propriedades da tabela
		for nInd2 := 1 to len(aProperties)
			oNewAttribute:lSet(aProperties[nInd2][1], aProperties[nInd2][2])
		next
		
		// define as propriedades da coordenada x da tabela
		for nInd2 := 1 to len(aDimX)
			oAllAttributes 	:= oDimX:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_DIMENSION, aDimX[nInd2][1]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_FIELD, aDimX[nInd2][2]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_OPTIONS, aDimX[nInd2][3]))
		next
		
		// define as propriedades da coordenada y da tabela
		for nInd2 := 1 to len(aDimY)
			oAllAttributes 	:= oDimY:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_DIMENSION, aDimY[nInd2][1]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_FIELD, aDimY[nInd2][2]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_OPTIONS, aDimY[nInd2][3]))
		next
		
		// define os valores/medidas para os indicadores
		for nInd2 := 1 to len(aInd)
			oAllAttributes 	:= oMeasure:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_FIELD, aInd[nInd2][1]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_OPTIONS, aInd[nInd2][2]))
		next
		
	next
 	
    // define os gr�ficos da consulta
	oGraphic		:= oQuery:oAddChild(TBIXMLNode():New(CHILD_GRAPHIC))
	oDimX 			:= oGraphic:oAddChild(TBIXMLNode():New(NODE_DIM_X))
	oDimY 			:= oGraphic:oAddChild(TBIXMLNode():New(NODE_DIM_Y))
	oMeasure		:= oGraphic:oAddChild(TBIXMLNode():New(NODE_MEASURES))
	oNewAttribute 	:= oGraphic:oAttrib(TBIXMLAttrib():New())
	for nInd := 1 to len(::faQueryGraphic)
		// 1 s�o as propriedades da tabela, 2 s�o os valores da dimens�o x 3 s�o os valores da dimens�o y e 4 s�o os indicadores
		aProperties := ::faQueryGraphic[nInd][1]
		aDimX 		:= ::faQueryGraphic[nInd][2]
		aDimY		:= ::faQueryGraphic[nInd][3]
		aInd		:= ::faQueryGraphic[nInd][4]
		
		// define as propriedades da tabela
		for nInd2 := 1 to len(aProperties)
			oNewAttribute:lSet(aProperties[nInd2][1], aProperties[nInd2][2])
		next
		
		// define as propriedades da coordenada x do gr�fico
		for nInd2 := 1 to len(aDimX)
			oAllAttributes 	:= oDimX:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_DIMENSION, aDimX[nInd2][1]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_FIELD, aDimX[nInd2][2]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_OPTIONS, aDimX[nInd2][3]))
		next
		
		// define as propriedades da coordenada y do gr�fico
		for nInd2 := 1 to len(aDimY)
			oAllAttributes 	:= oDimY:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_DIMENSION, aDimY[nInd2][1]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_FIELD, aDimY[nInd2][2]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_OPTIONS, aDimY[nInd2][3]))
		next
		
		// define os valores/medidas para os indicadores
		for nInd2 := 1 to len(aInd)
			oAllAttributes 	:= oMeasure:oAddChild(TBIXMLNode():New(NODE_ATTRIBUTES))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_FIELD, aInd[nInd2][1]))
			oAllAttributes:oAddChild(TBIXMLNode():New(CHILD_OPTIONS, aInd[nInd2][2]))
		next
		
	next 
	
	// define documentacao da consulta
	
	aDoc := ::faQueryDoc  
	if !empty(aDoc)
		oNewNode		:= oQuery:oAddChild(TBIXMLNode():New(CHILD_DOC))
		oNewAttribute	:= oNewNode:oAttrib(TBIXMLAttrib():New())
		oNewAttribute:lSet(MULTI_LINE, MULTI_ON)
		for nInd := 1 to len(aDoc[1])                                                       
			oNewNode2 := oNewNode:oAddChild(TBIXMLNode():New(MULTILINE_LINE, aDoc[1][nInd]))
		next
	endif	  
	
	aDoc := ::faQueryHTMLDoc
	if !empty(aDoc)
		oNewNode		:= oQuery:oAddChild(TBIXMLNode():New(CHILD_DOC_HTML))
		oNewAttribute	:= oNewNode:oAttrib(TBIXMLAttrib():New())
		oNewAttribute:lSet(MULTI_LINE, MULTI_ON)
		for nInd := 1 to len(aDoc[1])                                                       
			oNewNode2 := oNewNode:oAddChild(TBIXMLNode():New(MULTILINE_LINE, DWTrataExpXML(aDoc[1][nInd])))
		next
	endif	  				

	// Limpa as propriedades de consulta/query
	::FreeQuery()
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar a exist�ncia ou n�o de um node de server.
Retornar� .T. caso existe e .F. caso n�o exista
Args:	aaAttribNames, array, contendo os nomes de propriedades do node de server a ser pesquisado
		  aaAttribValues, array, contendo os valores das propriedades do node de server a ser pesquisado
		  nAttKey, number, indice de qual atribute � 'chave' de pesquisa
--------------------------------------------------------------------------------------
*/
method verifyServers(aaAttribNames, aaAttribValues, anAttKey) class TDWXmlMetaDado
	Local lReturn := .F.
	Local nCount := ::foXmlServer:nChildCount(CHILD_SERVER)
	Local nInd, nInd2
	Local xConector
	
	if !(len(aaAttribNames) == len(aaAttribValues))
		lReturn := NIL
	endif
	
	for nInd := 1 to nCount
		xConector := ::foXmlServer:oChildByPos(nInd)
		
		if xConector:oAttrib():cValue(aaAttribNames[anAttKey]) == aaAttribValues[anAttKey]
			lReturn := .T.
			exit
		endif
	next
	
return lReturn

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar um node de server ao xml
Args: aaServer, array de array, contendo as propriedades (NomeDoCampo/ValorDoCampo) do node de server
--------------------------------------------------------------------------------------
*/
method addServer(aaServer) class TDWXmlMetaDado
	
	Local oNewNode
	Local oNewAttribute
	Local nInd
	
	if len(aaServer) > 0
		oNewNode 		:= ::foXmlServer:oAddChild(TBIXMLNode():New(CHILD_SERVER))
		oNewAttribute 	:= oNewNode:oAttrib(TBIXMLAttrib():New())
		for nInd := 1 to len(aaServer)
			oNewAttribute:lSet(aaServer[nInd][1], aaServer[nInd][2])
		next
	endif
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por salvar o arquivo de xml.
Args: acFilename, string, nome do arquivo
		alHeader, booleano, Indica se gera o cabecalho do XML. Default e ISO-8859-1
		acEncoding, string, tipo de encoding do arquivo xml
		alMakeEmpty, booleano, indica se gera ou n�o os n�s que estiverem vazios. Default e .t.
--------------------------------------------------------------------------------------
*/
method SaveFile(acFilename, alHeader, acEncoding, alMakeEmpty) class TDWXmlMetaDado

	default alHeader 		:= .T.
	default acEncoding 	:= "ISO-8859-1"
	default alMakeEmpty	:= .T.

	::foXML:XMLFile(acFilename, alHeader, acEncoding, alMakeEmpty)
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por adicionar propriedades � um filtro de uma consulta,
para posterior adi��o ao xml.
Args: 	aaProperty, array de array, contendo as propriedades de um filtro
	espec�fico a ser adicionado
		aaExression, array de array, contendo as expressions de um filtro
	espec�fico a ser adicionado
--------------------------------------------------------------------------------------
*/
method addQFilter(aaProperty, aaExression) class TDWXmlMetaDado
	aAdd(::faQueryFilter, {aaProperty, aaExression})
return