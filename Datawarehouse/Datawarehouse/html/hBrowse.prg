// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Main
// Fonte  : Object - Define o objeto b�sico para pagina��o
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.10.05 | Paulo R Vieira	  |
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

#define ORD_ASC 			"ASC" 		// Ordena��o do tipo ascendente
#define ORD_DESC 			"DESC" 		// Ordena��o do tipo descendente
                
/*
--------------------------------------------------------------------------------------
Classe: TDWBrowser
Uso   : Objeto b�sico para p�gina��o do sistema
--------------------------------------------------------------------------------------
*/
class TDWBrowser from TDWObject
	
	// Mensagem de aviso no rodap�
	data fcWarning
	
	// Propriedade Nome da Tabela
	data fcTable
	// Propriedade de Campos a serem exibidos
	data faShowFields
	// Propriedade de Campos de ordena��o
	data faOrdFields
	// Propriedade de Campos de chave para a pesquisa
	data faKeyFields
	// Propriedade da Clausula Where
 	data fcWhere
 	// Propriedade da pesquisa QBE
 	data faQBE
 	
 	data faPrimRegs
 	data faUltoRegs
 	
 	data fcOrder
 	data fcOrderField
	
	data foQuery
	data fnNumRegPag
	data faRegPag
	data fnCurrPag
	data fnTotPag
	
	data flOrdPagAsc
	data flOrdPagDesc
	
	data fcQBEQuery

	data faPropertyFields
	
	// flag modo de impress�o
	data flPrinting
	
	//query QBE no formato HTML
	data fcQBEInHtml
	
	// � uma tabela que poder� ser incializada pelo DW
	data flIsInitTableDW

	// n�mero m�ximo de registros/total
	data fnMaxRecords
	
	// sinaliza se � para realizar a distin��o dos registros da browse
	data flDistinctRecords
	
	// construtor
	method New(anNumRegPag) constructor
	
	// destrutor
	method Free()

	// atualiza a session
	method updateSession()
	
	// atualiza o ambiente com os valores da session
	method updateEnvironment()
	
	// Propriedade Nome da Tabela
	method table(acTableName)
	
	// Propriedade de Campos a serem exibidos
	method addShowField(acName, acType, anSize, anDecimal, anPos, alVisible)
	
	// Propriedade de Campos de ordena��o
	method addOrderField(acName, alOrder)
	
	// Propriedade de Campos de chave para a pesquisa
	method addKeyField(acName)
	
	// Propriedade da Clausula Where
 	method where(acWhere)

 	// Propriedade da pesquisa QBE
 	method addQBE(acFieldName, acQBEExpr, acFieldCapt)
 		
	method executarQuery(acAcao, acValorAcao, abProcRow)
	
	method execPrintPg(acWhere, aaPrimRegs)
	method execNextPg(acWhere, aaUltoRegs)
	method execPrevsPg(acWhere, aaPrimRegs)
	method execSelectPg(acWhere, acSelectionPage)
	method execFirstPg(acQBEWhere, acWhere)
	method execOrderPg(acWhere, aaPrimRegs, aaUltoRegs, lTipoOrdenacao)
	method execQBE(acWhere)
	
	method CurrentPage()
	method TotalPage()
 	method getQBEInHtml()
 	method Warning(acValue)
	method recuperarHeader()
	method tratarAcao(acAcao, acValorAcao)
	method campoOrdenado(acCampo)
	method ordenarAsc()
	method ordenarDesc()
	
	method concatOrder(lTrocarAsc, lTrocarDesc)
	method inicioPag()
	method fimPag()
	method montaCampChaves(aaKeyFields, acCondicao, aaValues) 
	method montaCampValDef(aaKeyFields, acCondicao, cValue)
	method findFieldProperty(acProperty, acFieldName)
	method retrieveOrder()
	method getQBEQuery()
	method checkNewOrder(acCondition)
	method getTypeProperty()
	method IsInitTableDW()
	method NumberRecordsPag(anNumRecords)
	method ShowAllRecords(alValue)
	method MaxRecords(anValue)
	method isPrinting(alValue)
	method retrieveKeyList()
	// sinaliza se � para realizar a distin��o dos registros da browse
	method DistinctRecords(alValue)
endclass

/*
--------------------------------------------------------------------------------------
Construtor da classe
Args: anNumRegPag - n�mero de registro contidos numa p�gina
--------------------------------------------------------------------------------------
*/
method New(anNumRegPag) class TDWBrowser
	
	_Super:New()
	
	if (valType(anNumRegPag) == "U")
		::fnNumRegPag := MAX_REG_POR_PAGINA // valor default
	elseif (valType(anNumRegPag) == 'N')
		::fnNumRegPag := anNumRegPag
	endif
	::foQuery			:= NIL

	::faRegPag 			:= {}
	::flOrdPagAsc		:= .T.
	::flOrdPagDesc		:= .F.
	::fcWarning         := ""
	::fcTable	  		:= ""
	::faShowFields		:= {}
	::faOrdFields		:= {}
	::faKeyFields		:= {}
	::fcWhere			:= NIL
	::faQBE				:= {}
	::faPropertyFields  := NIL
	::fcQBEInHtml		:= ""
	::flIsInitTableDW	:= .T.
	::flPrinting		:= .F.
	::flDistinctRecords	:= .F.
	
	::updateEnvironment()
return

/*
--------------------------------------------------------------------------------------
Destrutor da classe
Args: 
--------------------------------------------------------------------------------------
*/
method Free() class TDWBrowser
	
	IF !(valType(::foQuery) == "U")
		::foQuery:Close()
	ENDIF
	
return	

/*
--------------------------------------------------------------------------------------
Atualiza o ambiente com os conte�dos da Session
Args: 
Retorna:                                                       	
--------------------------------------------------------------------------------------
*/
method updateEnvironment() class TDWBrowser
	::fnCurrPag			:= isNull(HttpSession->nCurrentPage, 0)
	::fnTotPag			:= isNull(HttpSession->nTotalPages, 0)
	
	::fcQBEQuery 		:= isNull(HttpSession->cQBEQuery, "")
	::fcQBEInHtml 		:= isNull(HttpSession->cQBEHtmlQuery, "")
	
	::faPrimRegs 		:= HttpSession->aPrimRegPag
	::faUltoRegs 		:= HttpSession->aUltoRegPag
	
	::fcOrderField		:= HttpSession->cOrderField
	::fcOrder			:= HttpSession->cOrder
return

/*
--------------------------------------------------------------------------------------
Atualiza a Session com os conte�dos do ambiente 
Args: 
Retorna:
--------------------------------------------------------------------------------------
*/
method updateSession() class TDWBrowser
	HttpSession->nCurrentPage	:= ::fnCurrPag
	HttpSession->nTotalPages	:= ::fnTotPag
	HttpSession->cQBEQuery		:= ::fcQBEQuery
	HttpSession->cQBEHtmlQuery	:= ::fcQBEInHtml
	
	HttpSession->aPrimRegPag	:= ::faPrimRegs
	HttpSession->aUltoRegPag	:= ::faUltoRegs
	
	HttpSession->cOrderField	:= ::fcOrderField
	HttpSession->cOrder			:= ::fcOrder
return

/*
--------------------------------------------------------------------------------------
Propriedade Nome Tabela
Args: 
--------------------------------------------------------------------------------------
*/
method table(acTableName) class TDWBrowser
	
	property ::fcTable := acTableName
	
return ::fcTable

/*
--------------------------------------------------------------------------------------
Propriedade Warning (aviso no rodape)
Args: 
--------------------------------------------------------------------------------------
*/
method Warning(acValue) class TDWBrowser

	property ::fcWarning := acValue

return ::fcWarning

/*
--------------------------------------------------------------------------------------
Propriedade de Campos a serem exibidos
Args: 
--------------------------------------------------------------------------------------
*/
method addShowField(acName, acType, anSize, anDecimal, anPos, alVisible) class TDWBrowser
	IF !(acType == FIELD_MEMO)	
		aAdd(::faShowFields, {acName, acType, anSize, anDecimal, anPos, alVisible})
	ENDIF
return

/*
--------------------------------------------------------------------------------------
Propriedade de Campos de ordena��o
Args: 
--------------------------------------------------------------------------------------
*/
method addOrderField(acName, alOrder) class TDWBrowser
	aAdd(::faOrdFields, {acName, alOrder})
return

/*
--------------------------------------------------------------------------------------
Propriedade de Campos de chave para a pesquisa
Args: 
--------------------------------------------------------------------------------------
*/
method addKeyField(acName) class TDWBrowser
	aAdd(::faKeyFields, {acName})
return

/*
--------------------------------------------------------------------------------------
Propriedade da Clausula Where
Args: 
--------------------------------------------------------------------------------------
*/
method where(acWhere) class TDWBrowser
	::fcWhere := acWhere
return

/*
--------------------------------------------------------------------------------------
Propriedade da pesquisa QBE
Args: acFieldName, caracter, contendo o nome do campo
		acQBEExpr, caracter, contendo a express�o a ser pesquisada
		acFieldCapt, caracter, contendo o caption/label do campo
--------------------------------------------------------------------------------------
*/
method addQBE(acFieldName, acQBEExpr, acFieldCapt) class TDWBrowser
	default acFieldCapt := ::findFieldProperty(FIELD_CAPTION, acFieldName)
	acQBEExpr := alltrim(acQBEExpr)
	aAdd(::faQBE, {acFieldName, acQBEExpr, acFieldCapt})
return

/*
--------------------------------------------------------------------------------------
Executa uma query a partir das propriedades do objeto
Args: acAcaoPag, caracter, contendo uma a��o a ser executada
		acValorAcao, caracter, contendo um valor adicional � a��o
Retorna: array de array contendo o resultado da query
--------------------------------------------------------------------------------------
*/
method executarQuery(acAcaoPag, acValorAcao, abProcRow) class TDWBrowser
	Local nUltoRegPag
	Local cAcaoPag
	Local aTemp
	Local aRegPag 		:= {}
	Local nCont1, nCont2
	Local aStructTab
	Local lOrdDesc 	:= .F.
	Local nPrimRegSel
	Local aTroca
	Local lOrdenacao 	:= .F.
	Local cWhere
	Local cListaCampos
	Local aCamposSelect:= {}
	Local cFieldOrdem
	Local bField
	Local btTroca
	Local bKeyFields
	Local nTotPagTrunc
	Local cQBEWhere
	Local nReg
	Local bAddWhere := {|cAWhere| iif (valType(cWhere) == "U", cWhere := cAWhere, cWhere := cWhere + " AND " + cAWhere)}
	Local aDados := {}
	Local aControlFields := {}
	local i, field
	Local lRecountRecords := .F.
	Local nCountRec
	Local xProcRet
	
	// inicializa os campos para pesquisa de propriedades
	::findFieldProperty(FIELD_INICIALIZER)
	
	// verifica se a query passada como propriedade j� continha uma cla�sula where
	if !(valType(::fcWhere) == "U")
		eval(bAddWhere, ::fcWhere)
	endif
	
	// cria e inicializa a tquery
	::foQuery := TQuery():New(::fcTable, DWMakeName("BRW"))
	::foQuery:FromList(::fcTable)
	
	// une os arrays de campos de ordena��o e de exibi��o
	aEval(::faKeyFields, {|aElem| aAdd(aCamposSelect, aElem[1]) })
	aEval(::faOrdFields, {|aElem| aAdd(aCamposSelect, aElem[1]) })
	aEval(::faShowFields, {|aElem| aAdd(aCamposSelect, aElem[1]) })
	
	// verifica e corrigi duplicidade de campos
	DplItems(aCamposSelect, .T.)
	
	// monta os campos de exibi��o
	cListaCampos := DWConcatWSep(", ", aCamposSelect)
	
	// define os campos da query
	::foQuery:FieldList(cListaCampos)

	::foQuery:MakeDistinct(::DistinctRecords())
	
	// por default define a cla�sula where caso n�o a a��o n�o seja a "inicial" (em branco)
	IF !(valType(cWhere) == "U")
		::foQuery:WhereClause(cWhere)
	ENDIF
    
	// total de registros	
	nCountRec := ::foQuery:RecCount()
	
	// define e seta os campos a serem exibidos
	aEval(aCamposSelect, {|field| ::foQuery:addField(NIL, field, ::findFieldProperty(FIELD_TYPE, field), ::findFieldProperty(FIELD_SIZE, field),  ::findFieldProperty(FIELD_DEC_SIZE, field))})
	
	if (!(valType(::faPrimRegs) == "U") .and. !(valType(::faUltoRegs) == "U"))
		
		// verifica��es para determinadas a��es
		
		// verifica pesquisas por QBE anteriores
		if !(acAcaoPag == QUERY_QBE) .and. !empty(::fcQBEQuery)
			// adiciona a cla�sula ao atual where
			eval(bAddWhere, ::fcQBEQuery)
		endif
		
		// caso que exibir� todos os registros
		// exibir� a "1� p�gina" com todos os registros (sem nenhuma p�gina a mais)
		if acAcaoPag == QUERY_ALLRECORDS
			::execFirstPg(cQBEWhere, cWhere)
		
		// caso gen�rico cuja pagina��o contem s� uma p�gina
		elseif !(acAcaoPag == QUERY_QBE) .and. ::TotalPage() == 1
			::execFirstPg(cQBEWhere, cWhere)
		
		// Pr�xima P�gina
		elseif (acAcaoPag == NEXT_PAGE)
			if ::CurrentPage() >= ::TotalPage()
				acValorAcao := ::TotalPage()
				::execSelectPg(cWhere, acValorAcao)
			else
				::execNextPg(cWhere, ::faUltoRegs)
			endif
			
		// P�gina Anterior
		elseif (acAcaoPag == PREVS_PAGE)
			
			if ::CurrentPage() == 1
				::execFirstPg(cQBEWhere, cWhere)
			else
				::execPrevsPg(cWhere, ::faPrimRegs)
				lOrdDesc := .T.
			endif
			
		// Sele��o de p�ginas diretamente
		elseif (acAcaoPag == SELCT_PAGE)
			if DWVal(acValorAcao) == 1 .or. !(valType(DWVal(acValorAcao)) == "N")
				::execFirstPg(cQBEWhere, cWhere)
			elseif DWVal(acValorAcao) < 0
				::execFirstPg(cQBEWhere, cWhere)
			elseif DWVal(acValorAcao) > DWVal(::TotalPage())
				acValorAcao := ::TotalPage()
				::execSelectPg(cWhere, acValorAcao)
			else			
				::execSelectPg(cWhere, acValorAcao)
			endif
			
		// P�gina Inicial
		elseif (acAcaoPag == FIRST_PAGE)
				::execFirstPg(cQBEWhere, cWhere)
			
		// �ltima P�gina
		elseif (acAcaoPag == LAST_PAGE)
			acValorAcao := ::TotalPage()
			::execSelectPg(cWhere, acValorAcao)
			
		// Ordena��o (ASC/DESC) de p�gina
		elseif (acAcaoPag == ORDER_PAGE)
			::execOrderPg(cWhere, ::faPrimRegs, ::faUltoRegs, ::fcOrder)
			lOrdDesc := .F.
			
		// Ordena��o (ASC/DESC) de p�gina
		elseif (acAcaoPag == PRINT_PAGE)
			::execPrintPg(cWhere, ::faPrimRegs)
			cFieldOrdem := ::concatOrder(.F.,.F.)
			::foQuery:OrderBy(cFieldOrdem)			
			
		// Pesquisa por QBE
		elseif (acAcaoPag == QUERY_QBE)
			::execQBE(cWhere)
		endif
		
	// Sele��o de p�ginas diretamente: n�o precisa da pagina��o atual
	elseif (acAcaoPag == SELCT_PAGE)
		if DWVal(acValorAcao) == 1 .or. !(valType(DWVal(acValorAcao)) == "N")
			::execFirstPg(cQBEWhere, cWhere)
		elseif DWVal(acValorAcao) < 0
			::execFirstPg(cQBEWhere, cWhere)
		elseif DWVal(acValorAcao) > DWVal(::TotalPage())
			acValorAcao := ::TotalPage()
			::execSelectPg(cWhere, acValorAcao)
		else			
			::execSelectPg(cWhere, acValorAcao)
		endif
	
	else
		
		// por default define a cla�sula order by caso n�o a a��o n�o seja a "inicial" (em branco)
		cFieldOrdem := ::concatOrder(.F.,.F.)
		::foQuery:OrderBy(cFieldOrdem)
		
	endif
	
	// executa a query
	::foQuery:Open()

	// executa a pesquisa
	IF DWIsDebug()
		conout("====> (hBrowser.prw " + DTOC(Date()) + " " + Time() + " SQL STATEMENT)", ::foQuery:SQLinUse(), " *****")
	ENDIF

	// atualiza p�gina atual e total de p�gina
	if !(::foQuery:EOF())
		if ::fnCurrPag == 0
			::fnCurrPag := 1
		endif
		
		// verifica se � para exibir todos os registros
		if ::ShowAllRecords()
			if empty(::fnMaxRecords)
				::fnNumRegPag 	:= nCountRec
				::fnTotPag		:= 1
			else
				if ::fnMaxRecords <= nCountRec
					::fnTotPag 	:= ::fnMaxRecords / ::fnNumRegPag
				else
					::fnTotPag 	:= nCountRec / ::fnNumRegPag
				endif
				::fnNumRegPag 	:= ::fnMaxRecords
			endif
			::fnCurrPag		:= 1
			
		// n�o � para exibir todos os registros POR�M a a��o � a de QUERY_ALLRECORDS,
		// significando que � para cancelar a exibi��o de todos os registros e exibir normalmente
		elseif acAcaoPag == QUERY_ALLRECORDS
			lRecountRecords	:= .T.
		endif
		
		// s� realiza este recontagem do total de registros uma vez ao iniciar o session utilizado na browse
		if ::fnTotPag == 0 .OR. lRecountRecords
			if empty(::fnMaxRecords)
				::fnTotPag := nCountRec / ::fnNumRegPag
			else
				if ::fnMaxRecords <= nCountRec
					::fnTotPag 	:= ::fnMaxRecords / ::fnNumRegPag
				else
					::fnTotPag 	:= nCountRec / ::fnNumRegPag
				endif
			endif
			nTotPagTrunc := DWTrunc(::fnTotPag, 0, 0)
      if nTotPagTrunc == 0
        nTotPagTrunc := 1
      endif
			if !(nTotPagTrunc >= ::fnTotPag)
				++nTotPagTrunc
			endif
			::fnTotPag := nTotPagTrunc
		endif
	else
		::fnCurrPag := 0
		::fnTotPag := 0
	endif
	
	// concatena os campos para controle da pagina��o
	aEval(::retrieveKeyList(), {|aElem| aAdd(aControlFields, aElem[1])})
	aEval(::faOrdFields, {|aElem| aAdd(aControlFields, aElem[1])})

	// verifica e corrigi duplicidade de campos
	DplItems(aControlFields, .T.)
	
	// remonta o array de campos exibidos
	// Acrescenta ao final de cada array espec�fico de cada campo, o �ndice (nCont2) a partir do select da query
	for nCont1 := 1 to len(::faShowFields)
		for nCont2 := 1 to len(aCamposSelect)
			if ::faShowFields[nCont1][1] == aCamposSelect[nCont2]
				::faShowFields[nCont1][5] := nCont2
			endif
		next
	next
	
	if empty(::fnMaxRecords)
		::fnMaxRecords := ::fnNumRegPag
	endif
	
	if (lOrdDesc == .F.)
 		nCont1 := 0
		while nCont1 < ::fnMaxRecords .and. (!::foQuery:EOF() .and. nCont1 < ::fnNumRegPag)
			aDados := ::foQuery:Record(9)
			if valType(abProcRow) == "B"
				xProcRet :=	eval(abProcRow, aDados)
				if valType(xProcRet) == "L" .AND. !xProcRet
					::foQuery:_Next()
					loop
				endif
			endif
			
			// recupera o primeiro registro da p�gina atual
			IF nCont1 == 0
				::faPrimRegs := {}				
				for i := 1 to len(aControlFields)
					field := aControlFields[i]
					if !(valtype(::foQuery:Fields(field)) == "U")
					  aAdd(::faPrimRegs, {field, ::foQuery:Value(field)})
					endif
				next
			ENDIF

			// recupera o �ltimo registro da p�gina atual
			::faUltoRegs := {}
			for i := 1 to len(aControlFields)
				field := aControlFields[i]
				if !(valtype(::foQuery:Fields(field)) == "U")
				  aAdd(::faUltoRegs, {field, ::foQuery:Value(field)})
				endif
			next
			aTemp := {}
			
			FOR nCont2 := 1 TO len(::faShowFields)
				aADD(aTemp, {::faShowFields[nCont2][1], aDados[::faShowFields[nCont2][5]]})
			NEXT
			aADD(aRegPag, aTemp)
			nCont1 := nCont1 + 1
			::foQuery:_Next()
		enddo
	else
		nCont1 := ::fnNumRegPag
		aRegPag := Array(::fnNumRegPag)
				
		while .not. ::foQuery:EOF() .and. nCont1 > 0
			
			aDados := ::foQuery:Record(9)
			if valType(abProcRow) == "B"
				eval(abProcRow, aDados)
			endif			
			
			// recupera o primeiro registro da p�gina atual
			IF nCont1 == ::fnNumRegPag
				::faUltoRegs := {}
				aEval(aControlFields, {|field| aAdd(::faUltoRegs, {field, ::foQuery:Value(field)})})
			ENDIF
			// recupera o �ltimo registro da p�gina atual
			::faPrimRegs := {}
			aEval(aControlFields, {|field| aAdd(::faPrimRegs, {field, ::foQuery:Value(field)})})
			aTemp := {}
			FOR nCont2 := 1 TO len(::faShowFields)
				aADD(aTemp, {::faShowFields[nCont2][1], aDados[::faShowFields[nCont2][5]]})
 			NEXT                                                         
			aRegPag[nCont1] := aTemp
			nCont1 := nCont1 - 1
			::foQuery:_Next()
		enddo
		
 		if nCont1 > 0
			aTemp := {}
			aEval(aRegPag, {|elemArray| iif (!(valType(elemArray) == "U"), aAdd(aTemp, elemArray),)})
			aRegPag := aTemp                   	
		endif
	endif
	
	// verifica se � para distinguir os registros
//	if (::DistinctRecords())
//		DplArrayAbs(aRegPag, .T.)
//		::fnTotPag 	:= ::foQuery:reccount() / ::fnNumRegPag
//		::fnTotPag	:= DWTrunc(::fnTotPag, 0, 0)
    if ::fnTotPag == 0
    	::fnTotPag := 1
    endif
//	endif
	
	// atualiza a session
	::updateSession()
	
return aRegPag

/*
--------------------------------------------------------------------------------------
Executa uma consulta para o preview da impress�o do browse
Args: 	acWhere, string, contendo uma cla�sula where
		aaPrimRegs, array, contendo os valores do primeiro registro da p�gina atual
Retorna:
--------------------------------------------------------------------------------------
*/
method execPrintPg(acWhere, aaPrimRegs) class TDWBrowser
	Local cFieldOrdem
	Local bAddWhere := {|cAWhere| iif (valType(acWhere) == "U", acWhere := cAWhere, acWhere := acWhere + " AND " + cAWhere)}
	Local aPrepKeyList := {}
	Local aPrepKeyVal := {}
	Local cCondition := ""
		
	// verifica o tipo de ordena��o (.T./ASC ou .F./DESC)
	if ::retrieveOrder() == ::ordenarAsc()
		cFieldOrdem := ::concatOrder(.T.,.T.)
		cCondition := " >= "
	else
		cFieldOrdem := ::concatOrder(.F.,.T.)
		cCondition := " <= "
	endif
	
	aEval(::retrieveKeyList(), {|aElem| aAdd(aPrepKeyList, {aElem[1], ::findFieldProperty(FIELD_TYPE, aElem[1]), ::findFieldProperty(FIELD_SIZE, aElem[1])})})
	aEval(aaPrimRegs, {|aElem| aAdd(aPrepKeyVal, aElem[2])})
	eval(bAddWhere, prepKeyList(aPrepKeyList) + cCondition + prepKeyValue(aPrepKeyList, aPrepKeyVal))
		
	::foQuery:WhereClause(acWhere)
	::foQuery:OrderBy(cFieldOrdem)
	::fnCurrPag--
return

/*
--------------------------------------------------------------------------------------
Executa uma query de pr�xima de p�gina
Args: acWhere, string, contendo uma cla�sula where
		aaUltoRegs, array, contendo os valores do �ltimo registro da p�gina atual
Retorna:
--------------------------------------------------------------------------------------
*/
method execNextPg(acWhere, aaUltoRegs) class TDWBrowser
	Local cFieldOrdem
	Local bAddWhere := {|cAWhere| iif (valType(acWhere) == "U", acWhere := cAWhere, acWhere := acWhere + " AND " + cAWhere)}
	Local aPrepKeyList := {}
	Local aPrepKeyVal := {}
	Local cCondition := ""
	
	// verifica o tipo de ordena��o (.T./ASC ou .F./DESC)
	if ::retrieveOrder() == ::ordenarAsc()
		cFieldOrdem := ::concatOrder(.F.,.F.)
		cCondition 	:= " > "
	else
		cFieldOrdem := ::concatOrder(.T.,.F.)
		cCondition 	:= " < "
	endif
	
	aEval(::retrieveKeyList(), {|aElem| aAdd(aPrepKeyList, {aElem[1], ::findFieldProperty(FIELD_TYPE, aElem[1]), ::findFieldProperty(FIELD_SIZE, aElem[1])})})
	
	aEval(aaUltoRegs, {|aElem| aAdd(aPrepKeyVal, aElem[2])})
	eval(bAddWhere, prepKeyList(aPrepKeyList) + cCondition + prepKeyValue(aPrepKeyList, aPrepKeyVal))
	
	::foQuery:WhereClause(acWhere)
	::foQuery:OrderBy(cFieldOrdem)
	// atualiza a p�gina atual
	::fnCurrPag++
return

/*
--------------------------------------------------------------------------------------
Executa uma query de pr�xima de p�gina
Args: acWhere, string, contendo uma cla�sula where
		aaPrimRegs, array, contendo os valores do primeiro registro da p�gina atual
Retorna:
--------------------------------------------------------------------------------------
*/
method execPrevsPg(acWhere, aaPrimRegs) class TDWBrowser
	Local cFieldOrdem
	Local bAddWhere := {|cAWhere| iif (valType(acWhere) == "U", acWhere := cAWhere, acWhere := acWhere + " AND " + cAWhere)}
	Local aPrepKeyList := {}
	Local aPrepKeyVal := {}
	Local cCondition := ""
		
	// verifica o tipo de ordena��o (.T./ASC ou .F./DESC)
	if ::retrieveOrder() == ::ordenarAsc()
		cFieldOrdem := ::concatOrder(.T.,.T.)
		cCondition := " < "
	else
		cFieldOrdem := ::concatOrder(.F.,.T.)
		cCondition := " > "
	endif
	
	aEval(::retrieveKeyList(), {|aElem| aAdd(aPrepKeyList, {aElem[1], ::findFieldProperty(FIELD_TYPE, aElem[1]), ::findFieldProperty(FIELD_SIZE, aElem[1])})})
	aEval(aaPrimRegs, {|aElem| aAdd(aPrepKeyVal, aElem[2])})
	eval(bAddWhere, prepKeyList(aPrepKeyList) + cCondition + prepKeyValue(aPrepKeyList, aPrepKeyVal))
		
	::foQuery:WhereClause(acWhere)
	::foQuery:OrderBy(cFieldOrdem)
	::fnCurrPag--
return

/*
--------------------------------------------------------------------------------------
Executa uma query de sele��o de p�gina
Args: acWhere, string, contendo uma cla�sula where
Retorna:
--------------------------------------------------------------------------------------
*/
method execSelectPg(acWhere, acSelectionPage) class TDWBrowser
	Local cFieldOrdem, nQtdeRegs
	Local bAddWhere := {|cAWhere| iif (valType(acWhere) == "U", ;
												acWhere := cAWhere, ;
												acWhere := acWhere + " AND " + cAWhere)}
	Local cSctQuery
	Local cNewOrder
	Local aPrepKeyList := {}
	Local aPrepKeyVal := {}
	Local cCondition := ""
	
	// verifica o tipo de ordena��o (.T./ASC ou .F./DESC)
	if ::retrieveOrder() == ::ordenarAsc()
		cFieldOrdem := ::concatOrder(.F., .F.)
	else
		cFieldOrdem := ::concatOrder(.T., .F.)
	endif
	
	// realiza a pesquisa no banco de dados do 1� registro de uma p�gina
	::foQuery:WhereClause(acWhere)
	nQtdeRegs := ::fnNumRegPag * dwVal(acSelectionPage)
	if SGDB() == DB_ORACLE
		cSctQuery := "SELECT * FROM (" + ::foQuery:SQL() + ") X"
		if nQtdeRegs > 0
      cSctQuery += " where ROWNUM <= " + dwStr(nQtdeRegs)
    endif
    cSctQuery += " order by " + cFieldOrdem
	elseif SGDB() == DB_DB2
		cSctQuery := "SELECT * FROM (" + ::foQuery:SQL() + ") X" ;
						+ " Order By " + cFieldOrdem
		if nQtdeRegs > 0
      cSctQuery += " fetch first " + dwStr(nQtdeRegs) + " rows only"
    endif
	else
		if nQtdeRegs > 0
      cSctQuery := "SELECT TOP " + dwStr(nQtdeRegs)
    else
      cSctQuery := "SELECT "
    endif
    cSctQuery += " * FROM (" + ::foQuery:SQL() + ") X Order By " + cFieldOrdem
	endif
	
	::foQuery:Open(NIL, cSctQuery)
	
	// pega o �ltimo registro da pesquisa acima e que ser� utilizado como o 1� registro da pagina��o selecionada
	// Para calcular: N�RegistrosPorPagina * (PaginaEscolhida - 1) - 1
	// (PaginaEscolhida - 1) porque o come�o da pagina��o ser� o �ltimo registro da p�gina anterior a escolhida
	// (PaginaEscolhida...) - 1 porque devemos considerar, para pular os registros, q j� estamos em um registro
	nReg := DWStr(::fnNumRegPag * (DWVal(acSelectionPage) - 1) - 1)
	
	// pula at� o �ltimo registro
	DBSkip(DWVal(nReg))
	
	// verifica o tipo de ordena��o (.T./ASC ou .F./DESC)
	if ::retrieveOrder() == ::ordenarAsc()
		cCondition := " > "
	else
		cCondition := " < "
	endif

	aTemp := {}
	aEval(::retrieveKeyList(), {|field| aAdd(aTemp, {field[1], ::foQuery:Value(field[1])})})
		
	aEval(::retrieveKeyList(), {|aElem| aAdd(aPrepKeyList, {aElem[1], ::findFieldProperty(FIELD_TYPE, aElem[1]), ::findFieldProperty(FIELD_SIZE, aElem[1])})})
	aEval(aTemp, {|aElem| aAdd(aPrepKeyVal, aElem[2])})
	eval(bAddWhere, prepKeyList(aPrepKeyList) + cCondition + prepKeyValue(aPrepKeyList, aPrepKeyVal))
	
 	::foQuery:WhereClause(acWhere)
	::foQuery:OrderBy(cFieldOrdem)
	// atualiza a p�gina atual com a �ltima p�gina
	::fnCurrPag := DWVal(acSelectionPage)
return

/*
--------------------------------------------------------------------------------------
Executa uma query de sele��o da primeira p�gina
Args: acQBEWhere, string, contendo a cla�sula where de uma pesquisa QBE (caso exista)
		acWhere, string, contendo a cla�sula where
Retorna:
--------------------------------------------------------------------------------------
*/
method execFirstPg(acQBEWhere, acWhere) class TDWBrowser
	Local cFieldOrdem
	
	// verifica o tipo de ordena��o (.T./ASC ou .F./DESC)
	if ::retrieveOrder() == ::ordenarAsc()
		cFieldOrdem := ::concatOrder(.F.,.F.)
	else
		cFieldOrdem := ::concatOrder(.T.,.F.)
	endif
	
	::foQuery:WhereClause(acWhere)
	// realiza pesquisa com todos os campos
	::foQuery:OrderBy(cFieldOrdem)
	// atualiza a p�gina atual com sendo a primeira p�gina
	::fnCurrPag := 1
return

/*
--------------------------------------------------------------------------------------
Executa uma query de sele��o de ordena��o da pagina��o
Args: acWhere, string, contendo uma cla�sula where
		aaPrimRegs, array, contendo os valores do primeiro registro da p�gina atual
		aaUltoRegs, array, contendo os valores do �ltimo registro da p�gina atual
		lTipoOrdenacao, l�gico, tipo de ordena��o
Retorna:
--------------------------------------------------------------------------------------
*/
method execOrderPg(acWhere, aaPrimRegs, aaUltoRegs, lTipoOrdenacao) class TDWBrowser
	Local cFieldOrdem
	Local cWhereCond
	Local bAddWhere := {|cAWhere| iif (valType(cWhere) == "U", acWhere := cAWhere, acWhere := acWhere + " AND " + cAWhere)}
	
	cFieldOrdem := ::concatOrder(.F.,.F.)
	::foQuery:WhereClause(acWhere)
	
	::foQuery:OrderBy(cFieldOrdem)
	::fnCurrPag := 1
return

/*
--------------------------------------------------------------------------------------
Executa uma query de pesquisa de QBE
Args: acWhere, string, contendo uma cla�sula where
Retorna:
--------------------------------------------------------------------------------------
*/
method execQBE(acWhere) class TDWBrowser
	Local cFieldOrdem
	Local nTotPagTrunc
		
	Local cWhere := ""
	Local cHtml  := ""
	Local cQBEWhere
	Local cQBEHtml
	Local nInd
	Local aField
	Local cType
	Local bAddWhere := {|cAWhere| iif (valType(acWhere) == "U", acWhere := cAWhere, acWhere := acWhere + " AND " + cAWhere)}
	
	::fcQBEQuery			:= ""
	::fcQBEInHtml 			:= ""
	
	IF !(valType(::faQBE) == "U")
		FOR nInd := 1 TO len(::faQBE)
			aField := ::faQBE[nInd]
			IF !(aField[3] == "")
				cType		:= ::findFieldProperty(FIELD_TYPE, aField[1])
				cQBEWhere	:= QBE2Sql(aField[1], cType, {alltrim(aField[2])}, aField[3], "", NIL, .t.)
				cQBEHtml	:= QBE2Html(aField[1], cType, {aField[2]}, aField[3], "", NIL, .t.)
				cQBEWhere 	:= alltrim(cQBEWhere)
				IF !empty(cWhere)
					cWhere 	+= " AND "
					cHtml		+= " E "
				ENDIF
				cHtml			+= cQBEHtml
				cWhere 		+= cQBEWhere
			ENDIF
		NEXT
		
		// atualiza a query QBE no formato HTML
		::fcQBEInHtml := cHtml
	ENDIF
	
	if !empty(cWhere)
		eval(bAddWhere, cWhere)
		::fcQBEQuery	:= cWhere
	endif
	
	cFieldOrdem := ::concatOrder(.F.,.F.)
	// realiza pesquisa com todos os campos
	::foQuery:OrderBy(cFieldOrdem)
	::foQuery:WhereClause(acWhere)
	// atualiza a p�gina atual com sendo a primeira p�gina
	::fnCurrPag := 1

	::foQuery:subType(ST_DIMENSION)
	::fnTotPag := ::foQuery:RecCount() / ::fnNumRegPag
	nTotPagTrunc := DWTrunc(::fnTotPag, 0, 0)
	if !(nTotPagTrunc >= ::fnTotPag)
		++nTotPagTrunc
	endif                           	
	::fnTotPag := nTotPagTrunc
return

/*
--------------------------------------------------------------------------------------
Recupera os campos da tabela utilizada na query, que ser�o utilizados como
	headers de exibi��o
Args: 
Retorna: array
--------------------------------------------------------------------------------------
*/
method recuperarHeader() class TDWBrowser
	Local aStrut := ::foQuery:struct()
	Local aHeaders := {}
	Local nCont1
	Local nCont2
	Local cCampo
	
	FOR nCont1 := 1 TO len(aStrut)
		cCampo := aStrut[nCont1][1]
		FOR nCont2 := 1 TO len(::faShowFields)
			if cCampo == ::faShowFields[nCont2][1]
				aADD(aHeaders, aStrut[nCont1])
			endif
		NEXT
	NEXT
	
return aHeaders

/*
--------------------------------------------------------------------------------------
Tratar/gerenciar uma requisi��o para pagina��o
Args: acAcao - a��o da requisi��o (Pr�xima p�gina, p�gina anterior, etc)
		acValorAcao - caso a a��o necessite de uma valor extra, como no caso da
ordena��o (que ser� passado a a��o e o tipo de ordena��o: ASC ou DESC) e
sele��o de p�gina aleat�ria
--------------------------------------------------------------------------------------
*/
method tratarAcao(acAcao, acValorAcao) class TDWBrowser
	Local cPrimCampAsc
	Local nInd
	
	if (!(valType(acAcao) == "U"))	

		if (valType(::faPrimRegs) == "U")
			::faPrimRegs := {}
		endif
		if (valType(::faUltoRegs) == "U")
			::faUltoRegs := {}
		endif
		
		// caso a a��o requisitada seja para ordenar
		if acAcao == ORDER_PAGE
		   
			// caso n�o exista na sess�o uma ordena��o por um campo, a ordem default ser� DESC
			if valType(::fcOrderField) == "U"
				::fcOrder := ORDER_PAGE
			// caso exista na sess�o uma ordena��o para o campo em quest�o
			elseif ::fcOrderField == acValorAcao			
				// troca a ordem de ASC para DESC e vice versa
				if ::fcOrder == ::ordenarAsc()
					::fcOrder := ::ordenarDesc()
				else
					::fcOrder := ::ordenarAsc()
				endif
				// substitui o antigo campo de order pela ordena��o escolhida pelo usu�rio
				for nInd := 1 to len(::faOrdFields)
					if ::faOrdFields[nInd][1] == acValorAcao
						::faOrdFields[nInd] := {::fcOrderField, ::fcOrder}
						exit
					endif
				next
			// caso n�o exista na sess�o uma ordena��o para o campo em quest�o
			else
				::fcOrder := ::ordenarAsc()
			endif
		
			// atualiza o campo de ordena��o
			::fcOrderField := acValorAcao
			
		// caso a a��o seja de requisitar todos os registros
		elseif acAcao == QUERY_ALLRECORDS
			 if oUserDW:EnablePaging() == ENABLE_PAGING_TRUE
			    oUserDW:EnablePaging(ENABLE_PAGING_FALSE)
			 else
			    oUserDW:EnablePaging(ENABLE_PAGING_TRUE)
			 endif
		// caso a a��o seja de impress�o
		elseif acAcao == PRINT_PAGE
			::isPrinting(.T.)
		endif
		
	else
		::faPrimRegs		:= NIL
		::faUltoRegs		:= NIL
		
		aEval(::faOrdFields, {|aElem| iif (aElem[2], cPrimCampAsc := aElem[1],)})
		::fcOrderField		:= cPrimCampAsc
		::fcOrder			:= ::ordenarAsc()
		
		::fnCurrPag			:= 0
		::fnTotPag			:= 0
		::fcQBEQuery		:= NIL
		::fcQBEInHtml		:= ""
	endif
	
return

/*
--------------------------------------------------------------------------------------
Verifica se o campo passado como argumento esteja sendo utilizado para ordena��o
Args: acCampo - campo a ser verificado
Retorno: .F. quando o campo passado n�o esteja sendo utilizado para ordena��o.
			.T. caso contr�rio
--------------------------------------------------------------------------------------
*/
method campoOrdenado(acCampo) class TDWBrowser
	Local lCampo := .F.

	if ::fcOrderField == acCampo
		lCampo := .T.
	endif

return lCampo

/*
--------------------------------------------------------------------------------------
M�todos acessores �s propriedades
Args: 
--------------------------------------------------------------------------------------
*/
method ordenarAsc() class TDWBrowser
return ::flOrdPagAsc

method ordenarDesc() class TDWBrowser
return ::flOrdPagDesc

method CurrentPage() class TDWBrowser
return ::fnCurrPag

method TotalPage() class TDWBrowser
return ::fnTotPag

method getQBEInHtml() class TDWBrowser
return ::fcQBEInHtml

method getQBEQuery() class TDWBrowser
return ::fcQBEQuery

/*
--------------------------------------------------------------------------------------
Concatena os elementos do array de campos de ordena��o
Args: lTrocarAsc, l�gico, ordenando a troca ou n�o da ordem ascendente nos casos
	de p�gina anterior e �ltima p�gina
		lTrocarDesc, l�gico, ordenando a troca ou n�o da ordem ascendente nos casos
	de p�gina anterior e �ltima p�gina
--------------------------------------------------------------------------------------
*/
method concatOrder(lTrocarAsc, lTrocarDesc) class TDWBrowser
	Local cFieldOrdem
	Local cAsc	:= "ASC"
	Local cDesc	:= "DESC"
	Local aTemp := {}
	Local nInd1, nInd2, aAux := {}
	
	if lTrocarAsc == .T.
		cAsc	:= "DESC"
	endif
	
	if lTrocarDesc == .T.
		cDesc	:= "ASC"
	endif
	
	// monta/concatena os campos utilizados na ordena��o
	bTroca := {|ordem| iif (valType(ordem) == "U", ;
								"", ;
								iif (ordem == ::flOrdPagAsc, cAsc, cDesc))}
														
	bField := {|elem| iif (valType(cFieldOrdem) == "U",;
								cFieldOrdem := elem[1] + " " + eval(bTroca, elem[2]),;
								cFieldOrdem := cFieldOrdem + ", " + elem[1] + " " + eval(bTroca, elem[2])) }
	
	// acrescenta a ordena��o escolhida pelo usu�rio
	aTemp := {{::fcOrderField, ::fcOrder}}
	aEval(::faOrdFields, {|elem| aAdd(aTemp, elem)})
	
	::faOrdFields := aTemp
	
	aEval(::retrieveKeyList(), {|aElem| aAdd(::faOrdFields, {aElem[1], ::fcOrder})})
	
	DplArray(::faOrdFields, .T.)
	
	aEval(::faOrdFields, bField)
	
return cFieldOrdem

/*
--------------------------------------------------------------------------------------
Verifica se a pagina��o est� na p�gina inicial
Args: 
Retorna: .T. caso esteja no in�cio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method inicioPag() class TDWBrowser
	Local lInicioPag := .T.
	
	if (::CurrentPage() > 1)
		lInicioPag := .F.
	endif
return lInicioPag

/*
--------------------------------------------------------------------------------------
Verifica se a pagina��o est� na �ltima p�gina
Args: 
Retorna: .T. caso esteja na �ltima p�gina, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method fimPag() class TDWBrowser
	Local lFimPag := .T.
	
	if (::CurrentPage() < ::TotalPage())
		lFimPag := .F.
	endif
return lFimPag

/*
--------------------------------------------------------------------------------------
Monta os campos chaves para uma pesquisa
Args: aaKeyFields, array, contendo um array com os campos chaves da pesquisa
		acCondicao, string, contendo a condi��o utilizada nos campos chaves (Ex: >, <, >=, etc)
		aaValues, array de array, contendo os campos chave e os seus respectivos valores
Retorna: string, contendo a cla�sula where para os argumentos passados
--------------------------------------------------------------------------------------
*/
method montaCampChaves(aaKeyFields, acCondicao, aaValues) class TDWBrowser
	Local nCont1, nCont2
	Local cCampo
	Local cWhere
	Local cDelim := ""
	
	// itera pelo array de chaves
	FOR nCont1 := 1 TO len(aaKeyFields)
		// recupera um campo chave
		cCampo := aaKeyFields[nCont1][1]
		// itera pelo array de chaves/valores para recuperar o seu valor
		FOR nCont2 := 1 TO len(aaValues)
			// verifica se encontrou o valor para a chave
			IF cCampo == aaValues[nCont2][1]
				IF !(valType(cWhere) == "U")
					cWhere := cWhere + " AND "
				ELSE
					cWhere := ""
				ENDIF
				IF !(::findFieldProperty(FIELD_TYPE, cCampo) == "N")
					cDelim := "'"
				ENDIF
				cWhere := cWhere + cCampo + acCondicao + cDelim + aaValues[nCont2][2] + cDelim
			ENDIF
		NEXT
	NEXT
		
return cWhere

/*
--------------------------------------------------------------------------------------
Monta os campos chaves com um valor default passado como argumento
Args: aaKeyFields, array, contendo um array com os campos chaves da pesquisa
		acCondicao, string, contendo a condi��o utilizada nos campos chaves (Ex: >, <, >=, etc)
		cValue, caracter, contendo o valor destinado a todos os campos chaves
Retorna: string, contendo a cla�sula where para os argumentos passados
--------------------------------------------------------------------------------------
*/
method montaCampValDef(aaKeyFields, acCondicao, cValue) class TDWBrowser
	Local nCont1
	Local cWhere
	
	// itera pelo array de chaves
	FOR nCont1 := 1 TO len(aaKeyFields)
		IF !(valType(cWhere) == "U")
			cWhere := cWhere + " AND "
		ELSE
			cWhere := ""
		ENDIF
		cWhere := cWhere + aaKeyFields[nCont1] + acCondicao + cValue
	NEXT
		
return cWhere

/*
--------------------------------------------------------------------------------------
Pesquisa uma determinada propriedade de um campo.
Sendo poss�veis as propriedades:
	=> FIELD_TYPE - Pesquisa o tipo um campo
	=> FIELD_SIZE - Pesquisa o tamanho um campo
	=> FIELD_DEC_SIZE - Pesquisa o n�mero de casas decimais de um campo
Args: acProperty, string, nome da propriedade a ser pesquisada
		acFieldName, string, nome do campo a ser pesquisado
Retorna: string, contendo o valor da propriedade do campo pesquisado
--------------------------------------------------------------------------------------
*/
method findFieldProperty(acProperty, acFieldName) class TDWBrowser
	Local cReturn
	Local nInd
	Local nIndProperty
	Local oTable
	
	IF acProperty == FIELD_TYPE
		nIndProperty := FLD_TYPE
	ELSEIF acProperty == FIELD_SIZE
		nIndProperty := FLD_LEN
	ELSEIF acProperty == FIELD_DEC_SIZE
		nIndProperty := FLD_DEC
	ELSEIF acProperty == FIELD_CAPTION
		nIndProperty := FLD_TITLE
	ENDIF
	
	if acProperty == FIELD_INICIALIZER .OR. valType(::faPropertyFields) == "U"
		if ::flIsInitTableDW
			oTable := initTable(::fcTable)
	 		::faPropertyFields := oTable:Fields()
	 		oTable:Free()
	 	else
	 		oTable	 := TQuery():New(::fcTable, DWMakeName("BRWA"))
			oTable:SQL(NIL, "select * from " + ::fcTable + " where 1 = 0 Order By " + ::faOrdFields[1][1])
			oTable:Open()
			::faPropertyFields := oTable:Fields()
			oTable:Close()
		endif
	endif
	
	IF !(acProperty == FIELD_INICIALIZER)
		FOR nInd := 1 TO len(::faPropertyFields)
			IF acFieldName == ::faPropertyFields[nInd][1]
				cReturn := ::faPropertyFields[nInd][nIndProperty]
				EXIT
			ENDIF
		NEXT
	ENDIF

return cReturn



/*
--------------------------------------------------------------------------------------
Recupera a atual ordena��o da pagina��o
Args: 
Retorna: os valores contidos nas vari�veis flOrdPagAsc e flOrdPagDesc
--------------------------------------------------------------------------------------
*/
method retrieveOrder() class TDWBrowser
	Local lOrder := ::ordenarAsc()
	
	if ::fcOrder == ::ordenarDesc()
		lOrder := ::ordenarDesc()
	endif
	
return lOrder

/*
--------------------------------------------------------------------------------------
Verifica se existe uma nova ordena��o realizada pelo usu�rio.
Caso exista uma nova ordena��o, monta uma cla�sula where contendo essa nova ordem
Args: acCondition, string, contendo uma condi��o a ser acrescentada a cla�sula where montada
Retorna: a cla�sula where resultante da nova ordem
--------------------------------------------------------------------------------------
*/
method checkNewOrder(acCondition) class TDWBrowser
	Local nInd1
	Local lNewOrder 	:= .T.
	Local cReturn
	
	for nInd1 := 1 to len(::retrieveKeyList())
		if ::retrieveKeyList()[nInd1][1] == ::fcOrderField
			lNewOrder := .F.
			exit
		endif
	next
	
	if lNewOrder == .T.	
		cReturn := ::montaCampChaves({{::fcOrderField}}, acCondition, ::faUltoRegs)
	endif
	
return cReturn

/*
--------------------------------------------------------------------------------------
Recupera os campos de chave, considerando a reorganiza��o do browser pelo usu�rio
Args:
Retorna: array, contendo os campo de chave prim�ria
--------------------------------------------------------------------------------------
*/
method retrieveKeyList() class TDWBrowser
	Local aTemp
	
	// acrescenta a ordena��o escolhida pelo usu�rio
	aTemp := {{::fcOrderField}}
	aEval(::faKeyFields, {|elem| aAdd(aTemp, elem)})
	
	DplArray(aTemp, .T.)
	
	::faKeyFields := aTemp
	
return ::faKeyFields

/*
--------------------------------------------------------------------------------------
Prepara a lista de campos chaves para pagina��o
Args: aaKeyList, array, array com os campos chaves
Ret: Valor de caracteres, cont�m os campos chaves concatenados para uso em SQLs
--------------------------------------------------------------------------------------
*/                                                
static function prepKeyList(aaKeyList)
	local aRet := {}, cRet
	local nInd, cAux, nTam
                	
	nTam := 0      
	
	for nInd := 1 to len(aaKeyList) 
	
		if aaKeyList[nInd, 2] == "N"
		
			if SGDB() == DB_ORACLE 			
				cAux := "to_char(" + aaKeyList[nInd, 1] + ", '0"+replicate("9", aaKeyList[nInd, 3]-1)+"')" 
			elseif SGDB() == DB_INFORMIX
				cAux := "to_char(" + aaKeyList[nInd, 1] + ")"
			elseif SGDB() == DB_DB2
				cAux := "varchar(right(rtrim(repeat ('0', "+dwStr(aaKeyList[nInd, 3])+")||cast(cast(" + aaKeyList[nInd, 1] + " as char) as varchar("+dwStr(aaKeyList[nInd, 3])+"))),"+dwStr(aaKeyList[nInd, 3])+"))"
			else
				cAux := "right(rtrim(replicate('0', "+dwStr(aaKeyList[nInd, 3])+")+cast(" + aaKeyList[nInd, 1] + " as char("+dwStr(aaKeyList[nInd, 3])+"))),"+dwStr(aaKeyList[nInd, 3])+")"
			endif	 
						
		elseif aaKeyList[nInd, 2] == "C" .and. SGDB() $ DB_MSSQL_ALL
			cAux := "rtrim(" + aaKeyList[nInd, 1] + ")"  
			
		else   
			cAux := aaKeyList[nInd, 1]
		endif       
		
		nTam := nTam + aaKeyList[nInd, 3]
		aAdd(aRet, cAux)
	next

	if SGDB() == DB_ORACLE .or. SGDB() == DB_DB2 
		cRet := dwConcatWSep("||", aRet)   
		
		if SGDB() == DB_DB2
		   cRet := " cast( " + cRet + " as varchar(" + dwStr(nTam) + ")) "    
		endif
	else
		cRet := dwConcatWSep("+", aRet)
	endif
		
return cRet

/*
--------------------------------------------------------------------------------------
Prepara a lista de valores dos campos chaves para pagina��o
Args: aaKeyList, array, array com os campos chaves
      aaKeyValue, array, array com os campos com valores para os campos chaves
Ret: Valor L�gico, indica se h� (.T.) ou n�o (.F.) duplicidade
--------------------------------------------------------------------------------------
*/                                                
static function prepKeyValue(aaKeyList, aaKeyValue)
	local cRet := ""
	local nInd
	
	if !empty(aaKeyValue) .AND. len(aaKeyValue) > 0
		for nInd := 1 to len(aaKeyList)
			if aaKeyList[nInd, 2] == "N"
				if SGDB() == DB_ORACLE
					cRet += " "
				endif
				cRet += strZero(dwVal(aaKeyValue[nInd]), aaKeyList[nInd, 3])
			elseif aaKeyList[nInd, 2] == "D"
		   		cRet += dtos(aaKeyValue[nInd])
			else 
		   		cRet += aaKeyValue[nInd]
			endif                                   '
		next
	endif
	
	cRet := "'"+strTran(cRet, "'", "'+char(39)+'")+"'"
		
return cRet
                             
/*
--------------------------------------------------------------------------------------
M�todo que define se a tabela dessa browse pode ser inicializado pelo m�todo padr�o do DW (InitTable)
Args: alIsInitTable, l�gico, se ser� ou n�o inicializada pelo m�todo padr�o
Ret: Valor l�gico, .T. caso seja o acesso seja via init table e .F. caso seja feito via objeto TQuery
--------------------------------------------------------------------------------------
*/
method IsInitTableDW(alIsInitTable) class TDWBrowser
	property ::flIsInitTableDW := alIsInitTable
return ::flIsInitTableDW

/*
--------------------------------------------------------------------------------------
M�todo que define a quantidade de registros a serem manipulados
Args: anNumRecords, n�merico, quantidade
Ret: Valor Num�rico, contendo o n�mero de registros por p�gina
--------------------------------------------------------------------------------------
*/
method NumberRecordsPag(anNumRecords) class TDWBrowser
	property ::fnNumRegPag := anNumRecords
return ::fnNumRegPag

/*
--------------------------------------------------------------------------------------
M�todo que recupera a op��o de paginar ou n�o
Args: 
Ret: Valor L�gico, .T. em caso de todos registros e .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method ShowAllRecords() class TDWBrowser
	
return !(oUserDW:EnablePaging() == ENABLE_PAGING_TRUE)

/*
--------------------------------------------------------------------------------------
M�todo que recupera ou define a quantidade m�xima de registros/total
Args: anValue, n�merico, define a propriedade
Ret: Valor n�merico, .T. recupera a propriedade
--------------------------------------------------------------------------------------
*/
method MaxRecords(anValue) class TDWBrowser
	property ::fnMaxRecords := anValue
return ::fnMaxRecords

/*
--------------------------------------------------------------------------------------
M�todo que recupera ou define se o browse est� em mode de impress�o
Args: alValue, l�gico, define a propriedade
Ret: Valor L�gico, recupera a propriedade
--------------------------------------------------------------------------------------
*/
method isPrinting(alValue) class TDWBrowser
	property ::flPrinting := alValue
return ::flPrinting

/*
--------------------------------------------------------------------------------------
M�todo que sinaliza se � para realizar a distin��o dos registros da browse
Args: alValue, l�gico, define a propriedade
Ret: Valor L�gico, recupera a propriedade
--------------------------------------------------------------------------------------
*/
method DistinctRecords(alValue) class TDWBrowser
	property ::flDistinctRecords := alValue
return ::flDistinctRecords