// #######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI015_Ind.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 30.08.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI015_Ind.ch"

//Constante do array data de analise
#define ANALISE_ALVODE		01
#define ANALISE_ALVOATE		02
#define ANALISE_ACUMDE 		03
#define ANALISE_ACUMATE 	04

/*--------------------------------------------------------------------------------------
@entity Indicador
Indicador no KPI. Contém os alvos.
Indicador de performance. Indicadores estao atreladas a objetivos.
@table KPI015
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "INDICADOR"
#define TAG_GROUP  "INDICADORES"
#define TEXT_ENTITY STR0001/*//"Indicador"*/
#define TEXT_GROUP  STR0002/*//"Indicadores"*/

/*aFormula*/
#define IND_VALOR		0
#define IND_FORMULA		1
/*Identifica que o indicador não é proprietário.*/
#define PUBLICO 	"F"
/*Identifica que o indicador é proprietário.*/
#define PRIVADO 	"T"


class TKPI015 from TBITable
	method New() constructor
	method NewKPI015()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList()
	method oToXMLRecList(cCmdSQL)	
	method oToXMLCheckList(cCmdSQL)    
	method oToXMLIndList(cCmdSQL)
	method oXMLFrequencia()
	method oXMLTipoAtualizacao()
	
	// registro atual
	method oToXMLNode( cId, cLoadCmd )
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)
	method oXMLUnidade()
	method oFormulaToXML(cFormula)	
	method nValidaFormula(cNewFormula, lPrivado)
	method nExecute(cID, cExecCMD)
	method aContemMF(cFormu) 
	method lDependInd(codIndPai, aMetaForm)
	method oAddIndItem(aDataAnalise,isScoOwner,cUserID)
	method nHasUserAcao(cIndID,cUserID,isScoOwner,dDataDe)
	
	//exclusão de dependências
	method nDelDepend(cID, lDelChildren)

	//Calculos
	method nIndTendencia(oPlaValor,nIndStatus,lAscendente,lMelhorFaixa)
	method nIndStatus(oPlaValor)
	method calcIndAcum(aDataDe,aDataAte,cTipoCalc)
	method calcPreviaAcum(aDataDe,aDataAte,cTipoCalc)
	method calcMetaAcum(aDataDe,aDataAte,cTipoCalc) 
	method aIndValores(oPlaValor, aVlrAcum)
	method nQtdFrequencia(aDataDe, aDataAte, nFrequencia) 	
	method lCompDataFreq(nFrequencia,dData,dDataComp)
	method nGetFxStatus(aVlrInd)
	method aGetMetas(lAcumulado,aDataDe,aDataAte)
	method nCalcPorcentagem(lAscend, nValor, nMeta, lMelhorFaixa)
	method nAcum_Formula(nTipoCalc,cFormula,aDataDe,aDataAte)
	method aGetIndValores(dDataAlvo,dDataDe,dDataAte)   
	method nCountRoot(nAcuTipo)      
	method nGetVar(lVarPer,nReal,nMeta)
	method nGetTolPercent()  
	method nGetSupPercent()  
	method nGetTolValor(nMeta,lAscend,lMelhorF)
	method nGetSupValor(nMeta,lAscend,lMelhorF)   
	method nGetIndStatus(aValores)  
	method aGetSupFaixa(nMeta, nTolera)
	method aGetTolFaixa(nMeta, nTolera)
		                                     
	//Integridade
	method aChkItemFormula(cItemFormula)
	method checRefCircular(indID,cIndFormula) 
	method cFindCodClieDup(cCodID,cCodClie)
	method lComparaFormulas(formulaA,formulaB)	//Método que compara se duas fórmulas são iguais
	method cRetFormula(cFormula)				//Método que recebe a fórmula do jeito que esta no bd e retorna a fórmula da maneira que é visualizada no cadastro
	
	//Outros
	method cGetFreqName(nFreq)		//Retorna o nome da frequencia.	
	method cGetPeriodo(nFreq, dDate)//Retorna o perido baseado na frequencia do indicador
	method cGetAcumName(nValor)
	method cGetUserOwnerSco()
	Method aFilhos(cIDIndicador, aFilhos)      
  
	Method isResp(cUser, cTipoResp)       
	method cNomePeriodo(nFrequencia)
endclass

method New() class TKPI015
	::NewKPI015()
return

method NewKPI015() class TKPI015
	//Table
	::NewTable("SGI015")
	::cEntity(TAG_ENTITY)

	//Chave primaria e chaves estrangeiras.
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_GRUPO"	,"C"	,10))//Id do Grupo.
	::addField(TBIField():New("ID_CODCLI"	,"C"	,255))//Id usado pelo cliente.
	::addField(TBIField():New("ID_SCOREC"	,"C"	,10))//Id do Scorecard associado.
	::addField(TBIField():New("ID_INDICA"	,"C"	,10))//Id do Indicador associado.
	::addField(TBIField():New("ID_RESPCOL"	,"C"	,10))//Id do Responsavel pela coleta.
	::addField(TBIField():New("TP_RESPCOL"	,"C"	,01))//Tipo do responsavel pela coleta " " usuario, 1 grupo
	::addField(TBIField():New("ID_RESP"		,"C"	,10))//Id da pessoa responsavel pela cobranca
	::addField(TBIField():New("TP_RESP"		,"C"	,01))//Tipo do responsavel pelo indicador "" usuario, 1 grupo
	::addField(TBIField():New("TIPO_ATU"	,"C"	,01))//Tipo de atualização: Manual, via planilha ou via fonte de dados
	::addField(TBIField():New("ISOWNER"		,"C"	,01))//True = Indicador pai

	//Campos
	::addField(TBIField():New("FORMULA"		,"M"		))
	::addField(TBIField():New("DECIMAIS"	,"N"		))// Numero de casas decimais
	::addField(TBIField():New("FREQ"		,"N"		))// Constante no KPIdefs.ch indica Frequencia
	::addField(TBIField():New("ACUM_TIPO"	,"C"	,001))// Tipo do acumulado.
	::addField(TBIField():New("ITENS_CAL"	,"C"	,003))//Itens para calculo 0-Real e Meta 1-Real 2-Meta	
	::addField(TBIField():New("ASCEND"		,"C"	,001))// Orientação - Quanto maior melhor
	::addField(TBIField():New("MELHORF"		,"C"	,001))// Orientação - Melhor na faixa
	::addField(TBIField():New("NOME"		,"C"	,255))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	::addField(TBIField():New("DESCFORMU"	,"C"	,255))//Descricao da Formula
	::addField(TBIField():New("VISIVEL"		,"C"	,001))
	::addField(TBIField():New("IND_ESTRAT"	,"C"	,001))	
	::addField(TBIField():New("UNIDADE"		,"C"	,010))// String que indica Unidade
	::addField(TBIField():New("SUPERA"		,"N"	,019,06	)) //Supera em da meta
	::addField(TBIField():New("TOLERAN"		,"N"	,019,06	)) //Tolerância da meta	
	::addField(TBIField():New("ALVO1"		,"N" 	,019,06	)) //Sempre verde
	::addField(TBIField():New("ALVO2"		,"N"	,019,06	)) //Sempre Vermelho
	::addField(TBIField():New("ALVO3"		,"N"	,019,06	)) //Sempre Azul

	::addField(TBIField():New("PESO"		,"N"	,003,00	)) //Peso do indicador para calculo do status do scorecarding.
	::addField(TBIField():New("ORDEM"		,"N"	,003,00	)) //Ordem dos Indicadores
	::addField(TBIField():New("DIA_LIMITE"	,"N"	,002,00	)) //Dia limite para preenchimento da planilha
	::addField(TBIField():New("LINK"		,"C"	,255))	   //Link customizado 
	::addField(TBIField():New("ISPRIVATE"	,"C"	,01))	   //True = Fórmula Protegida.
	::addField(TBIField():New("ISCONSOLID"	,"C"	,01))	   	//True = Indicador Consolidador.
	::addField(TBIField():New("VERIFICA"	,"C"	,255))    	//Método de verificação dos resultados.
	::addField(TBIField():New("GRAPH_UP"	,"C"	,06))	 	 	//Gráfico superior GGVVPP. XX GRAFICO, YY VISUALIZAÇÃO, PP PERCENTUAL OU VALOR
	::addField(TBIField():New("GRAPH_DO"	,"C"	,06))	 		//Gráfico inferior GGVVPP. XX GRAFICO, YY VISUALIZAÇÃO, PP PERCENTUAL OU VALOR
	
	//Indexes
	::addIndex(TBIIndex():New("SGI015I01",	{"ID"}						, .t.))
	::addIndex(TBIIndex():New("SGI015I02",	{"ID_GRUPO"}				, .f.))
	::addIndex(TBIIndex():New("SGI015I03",	{"ID_SCOREC"}				, .f.))
	::addIndex(TBIIndex():New("SGI015I04",	{"ID_INDICA"}				, .f.))
	::addIndex(TBIIndex():New("SGI015I05",	{"NOME"}					, .f.))
	::addIndex(TBIIndex():New("SGI015I06",	{"ID_CODCLI"}				, .f.))
	::addIndex(TBIIndex():New("SGI015I07",	{"ID_RESPCOL", "TP_RESPCOL"}, .f.))
	::addIndex(TBIIndex():New("SGI015I08",	{"ID_RESP", "TP_RESP"}		, .f.))
	::addIndex(TBIIndex():New("SGI015I09",	{"UNIDADE"}					, .f.))
return

//Arvore
method oArvore(nParentID) class TKPI015
return oXMLArvore

//Lista dos Registros de Indicadores
method oToXMLRecList(cCmdSQL) class TKPI015
	local oXMLNodeLista, oAttrib, oXMLNode, nInd
	local oPlan		:= ::oOwner():oGetTable("PLANILHA")
	local cComando
	local nFreq
	local cAno, cMes, cDia	
	local dDtPer      
	local cPeriodo
	local aDataDe 	:= {}
	local aDataAte	:= {}   
	local aData		:= {}   
	local nDataDifDe, nDataDifAt      
	local lJustifica := .T.
	
	oXMLNodeLista := TBIXMLNode():New("LISTA")                     
	
	if Valtype(cCmdSQL) == "O"
		cComando	:= cCmdSQL:_COMANDO:TEXT
		if(Upper(cComando) == "GET_PERIODO") 
			nFreq 		:= xBIConvTo("N",cCmdSQL:_FREQUENCIA:TEXT)
			cAno		:= xBIConvTo("N",cCmdSQL:_ANO:TEXT)
			cMes		:= xBIConvTo("N",cCmdSQL:_MES:TEXT)
			cDia		:= xBIConvTo("N",cCmdSQL:_DIA:TEXT)
			lLote		:= xBIConvTo("L",cCmdSQL:_METALOTE:TEXT)

			aAdd(aData,cAno)
			aAdd(aData,cMes)
			aAdd(aData,cDia)

			oAttrib := TBIXMLAttrib():New()			

			if lLote
				aDataDe 	:= oPlan:aDateConv(xBIConvTo("D",cCmdSQL:_PERIODODE:TEXT)	, nFreq)
				aDataAte	:= oPlan:aDateConv(xBIConvTo("D",cCmdSQL:_PERIODOATE:TEXT)	, nFreq)
				//aPeriodo 	:= oPlan:aQtdFrequencia(aDataDe, aDataAte, nFreq)
				
				nDataDifDe 	:= oPlan:nCompFreq(aData,aDataDe)
				nDataDifAt	:= oPlan:nCompFreq(aData,aDataAte)
			
				if (nDataDifDe == 0 .Or. nDataDifDe == 1) .And. (nDataDifAt == 0 .Or. nDataDifAt == -1)
					lJustifica := .F.						
					oAttrib:lSet("JUSTIFICA", lJustifica)
				endif
			endif
			 
			if lJustifica						
				dDtPer	:= oPlan:dPerToDate(cAno,cMes,cDia,nFreq)
				cPeriodo:= ::cGetPeriodo(nFreq, dDtPer)    

				oAttrib:lSet("PERIODO"	, cPeriodo)
				oAttrib:lSet("JUSTIFICA", lJustifica)
			endif
			oNode := TBIXMLNode():New("PERIODOS",,oAttrib)
			oXMLNodeLista:oAddChild(oNode)
		endif
	else
		aParam := aBIToken(cCmdSQL, ",",.f.)
		
		if (len(aParam)>1 .and. aParam[2]=="SELECIONAR")
			oXMLNodeLista := ::oToXMLCheckList(cCmdSql)
		elseif (len(aParam)>1 .and. aParam[2]=="LSTINDICADOR")
			oXMLNodeLista := ::oToXMLIndList(aParam[1])
		elseIf (len(aParam)>1 .and. aParam[2]=="LST_IND_SCORECARD")	
			oXMLNodeLista:oAddChild(::oToXMLList(aParam[1],.t.))
		else
			cCmdSql := aParam[1]
			//Colunas
			oAttrib := TBIXMLAttrib():New()
			//Tipo
			oAttrib:lSet("TIPO", TAG_ENTITY)
			oAttrib:lSet("RETORNA", .f.)
		       
			//Ordem
			oAttrib:lSet("TAG000", "ORDEM")
			oAttrib:lSet("CAB000", STR0038) //"Ordem"
			oAttrib:lSet("CLA000", KPI_INT)
			
			//Nome
			oAttrib:lSet("TAG001", "NOME")
			oAttrib:lSet("CAB001", TEXT_ENTITY)
			oAttrib:lSet("CLA001", KPI_STRING)   
	
			//Id
			oAttrib:lSet("TAG002", "ID")
			oAttrib:lSet("CAB002", STR0039) //Cód.
			oAttrib:lSet("CLA002", KPI_STRING)
			
		
			//Gera o principal
			oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
			
			//Gera o no de detalhes  
			::SetOrder(5)
			if ! empty(cCmdSQL)
				::cSQLFilter(cCmdSQL)
				::lFiltered(.t.)
			endif
			::_First()
		
			while(!::lEof())
				if( !(alltrim(::cValue("ID")) == "0"))
					oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
					aFields := {{"ID",""},{"NOME",""},{"ID_SCOREC",""}, {"ORDEM",""}}
		
					for nInd := 1 to len(aFields)
						oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ::cValue(aFields[nInd][1])))
					next
				endif
				::_Next()		
			end
			oXMLNodeLista:oAddChild(oXMLNode)
		endif
		::cSQLFilter("")
	endif 
return oXMLNodeLista

//Lista dos Indicadores
method oToXMLIndList(cCmdSQL) class TKPI015       
	local oXMLNodeLista, oAttrib, oXMLNode, nInd 
	
	oXMLNodeLista := TBIXMLNode():New("LISTA")
	
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
       
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)   

	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	::SetOrder(5)
	if ! empty(cCmdSQL)
		::cSQLFilter(cCmdSQL)
		::lFiltered(.t.)
	endif
	::_First()

	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := {{"ID",""},{"NOME",""},{"ID_SCOREC",""}}

			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ::cValue(aFields[nInd][1])))
			next
		endif
		::_Next()		
	end

	oXMLNodeLista:oAddChild(oXMLNode)
	::cSQLFilter("")
return oXMLNodeLista

//Lista dos Registros de Indicadores
method oToXMLCheckList(cCmdSQL, aParam) class TKPI015
	local oXMLNodeLista, oAttrib, oXMLNode 
	local oPlanilha		:= ::oOwner():oGetTable("PLANILHA")	
	local oPlano 		:= ::oOwner():oGetTable("PLANOACAO")
	local oAprxInd 		:= ::oOwner():oGetTable("SCORXIND")
	local aValores		:= {} 
	local nInd			:=	0	
	local nDecimais		:=	2
	local lValorPrevio	:= .f.   
	local lIndVermelho	:= .f. //TRUE:	Incluir obrigatoriamente na apresentação, indicadores que não atingiram a meta.
	local lSelecao		:= .f. 
	local lVarPercent	:= .f.
	local lEnable		:= .t.   
	local oUser		 	:= oKpiCore:foSecurity:oLoggedUser()                                                                 
	local lIsAdmin	 	:= oUser:lValue("ADMIN")
	local oParametro	:= oKpiCore:oGetTable("PARAMETRO")
	
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif               
	
	if(!lIsAdmin .and. oParametro:lSeek(1, {"INDVERM_APRESENT"}))
		lIndVermelho := oParametro:lValue("DADO")
	endif  
	
	//Exibir variação em percentual	
	if(oParametro:lSeek(1, {"SHOWVARCOL"}))
		lVarPercent := oParametro:lValue("DADO")
	endif
	
	oXMLNodeLista := TBIXMLNode():New("LISTA")
	aParam := aBIToken(cCmdSQL, ",",.f.)

	cCmdSql := aParam[1]
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	//CheckBox de Seleção de indicadores
	oAttrib:lSet("TAG000", "SELECAO")
	oAttrib:lSet("CAB000", STR0027) //Selecione
	oAttrib:lSet("CLA000", KPI_BOOLEAN)
	oAttrib:lSet("EDT000", .T.)
	oAttrib:lSet("CUM000", .F.)
	//Nome
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", TEXT_ENTITY)
	oAttrib:lSet("CLA001", KPI_STRING)
	
	//Real
	oAttrib:lSet("TAG002", "REAL")
	oAttrib:lSet("CAB002", ::oOwner():getStrCustom():getStrReal() ) //"Real"
	oAttrib:lSet("CLA002", KPI_FLOAT)
	//Meta
	oAttrib:lSet("TAG003", "META")
	oAttrib:lSet("CAB003", ::oOwner():getStrCustom():getStrMeta() ) //"Meta"
	oAttrib:lSet("CLA003", KPI_FLOAT)
	//% Meta
	oAttrib:lSet("TAG004", "VARIACAO")
	oAttrib:lSet("CAB004", STR0030) //"Variação"
	oAttrib:lSet("CLA004", KPI_FLOAT)
	//Real Acumulado
	oAttrib:lSet("TAG005", "REALACUM")
	oAttrib:lSet("CAB005", ::oOwner():getStrCustom():getStrReal() + " Acum.") //"Real Acum."
	oAttrib:lSet("CLA005", KPI_FLOAT)
	//Meta Acumulada
	oAttrib:lSet("TAG006", "METAACUM")
	oAttrib:lSet("CAB006", ::oOwner():getStrCustom():getStrMeta() + " Acum.") //"Meta Acum."
	oAttrib:lSet("CLA006", KPI_FLOAT)
	//% Meta
	oAttrib:lSet("TAG007", "VARIACAOACUM")
	oAttrib:lSet("CAB007", STR0033) //"Variação Acum."
	oAttrib:lSet("CLA007", KPI_FLOAT)

	if(lValorPrevio)
		//Previa
		oAttrib:lSet("TAG008", "PREVIA")
		oAttrib:lSet("CAB008", ::oOwner():getStrCustom():getStrPrevia() ) //"Prévia"
		oAttrib:lSet("CLA008", KPI_FLOAT)
	endif
	
	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	::SetOrder(5)
	if ! empty(cCmdSQL)
		::cSQLFilter(cCmdSQL)
		::lFiltered(.t.)
	endif
	::_First()
	
	oAprxInd:cSQLFilter("ID_APRES ='" + xbiconvto("C",aParam[6]) + "'") //filtra a apresentação
	oAprxInd:lFiltered(.t.)

	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := {{"ID",""},{"NOME",""},{"ID_SCOREC",""}}

			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ::cValue(aFields[nInd][1])))
			next

			if(oPlanilha:lDateSeek(::cValue("ID"),cTod(aParam[5]),::nValue("FREQ")))
				aValores 	:= ::aGetIndValores(aParam[5],aParam[3],aParam[4])
				nDecimais 	:=	::nValue("DECIMAIS")
			else
				aValores	:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}
				nDecimais 	:= 2
			endif				
			
			if(aValores[VAL_ACUM_STATUS] == STATUS_RED .and. lIndVermelho)
				lSelecao := .t.                                 
				lEnable  := .f.		
			else            
				lEnable  := .t.
				if(oAprxInd:lSeek(2,{::cValue("ID_SCOREC"),::cValue("ID")}))
					lSelecao := .t.
				else               
					lSelecao := .f.
				endif
			endif
			
			oNode:oAddChild(TBIXMLNode():New("SELECAO", lSelecao))
			oNode:oAddChild(TBIXMLNode():New("ENABLE",  lEnable ))			
			
			oNode:oAddChild(TBIXMLNode():New("REAL"			,aValores[VAL_REAL] ))
			oNode:oAddChild(TBIXMLNode():New("META"			,aValores[VAL_META] ))
			
			if(lValorPrevio)
				oNode:oAddChild(TBIXMLNode():New("PREVIA"	,aValores[VAL_PREVIA] ))
			endif

			oNode:oAddChild(TBIXMLNode():New("VARIACAO"		,::nGetVar(lVarPercent,aValores[VAL_REAL],aValores[VAL_META]) ))
			oNode:oAddChild(TBIXMLNode():New("REALACUM"		,aValores[VAL_REAL_ACU] ))
			oNode:oAddChild(TBIXMLNode():New("METAACUM"		,aValores[VAL_META_ACU] ))
			oNode:oAddChild(TBIXMLNode():New("VARIACAOACUM" ,::nGetVar(lVarPercent,aValores[VAL_REAL_ACU],aValores[VAL_META_ACU]) ))
			oNode:oAddChild(TBIXMLNode():New("STATUS_ACU"   ,aValores[VAL_ACUM_STATUS]))			
			oNode:oAddChild(TBIXMLNode():New("STATUS"		,aValores[VAL_REAL_STATUS]))			
			oNode:oAddChild(TBIXMLNode():New("DECIMAIS"		,nDecimais))			
			oNode:oAddChild(TBIXMLNode():New("IND_ESTRAT"	,::cValue("IND_ESTRAT")))
		endif
		
		oNode:oAddChild(oPlano:oToXMLList(::cValue("ID"), 1))
		::_Next()
	end

	oAprxInd:cSQLFilter("")
	::cSQLFilter("")	

	oXMLNodeLista:oAddChild(oXMLNode)
return oXMLNodeLista

/*
*Metodo que retorna os valores calculado dos indicadores.
*ATENCAO* Tanto o arquivo de indicadores quanto o arquivo de valores DEVEM estar POSICIONADOS *ATENCAO
*/
method aGetIndValores(dDataAlvo,dDataDe,dDataAte) class TKPI015
	local aValores	 := {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}
	local aVlrAcumu  := {}
	local aVlrMeta	 := {}
	local oPlanilha	 := ::oOwner():oGetTable("PLANILHA")	 
	Local oParametro := ::oOwner():oGetTable("PARAMETRO") 	
	local aDataDe 	 := oPlanilha:aDateConv(xbiconvto("D",dDataDe),  ::nValue("FREQ"))
	local aDataAte 	 := oPlanilha:aDateConv(xbiconvto("D",dDataAte), ::nValue("FREQ"))
	local aDataAlvo	 := oPlanilha:aDateConv(xbiconvto("D",dDataAlvo),::nValue("FREQ"))	
	local nMeta		 :=	0
	local nReal		 :=	0
	local nPrevia	 :=	0
	local nMetaAcum	 :=	0
	local nRealAcum	 :=	0	
	local nAcuStatus := ESTAVEL_GRAY
	local nStatus	 := ESTAVEL_GRAY
    local lTemValor  := .F.      
    local lMelhorF   :=	::lValue("MELHORF")   

 	//Adicionando valor do indicador.                                                    
	if(oPlanilha:lDateSeek( ::cValue("ID"), dDataAlvo, ::nValue("FREQ")))
		nReal 		:= oPlanilha:nValue("VALOR")
		nMeta 		:= ::aGetMetas(.f.)[1]
		nPrevia		:= oPlanilha:nValue("PREVIA")  
		
		lTemValor 	:= .T.
	Else    
		nReal 		:= 0
		nMeta 		:= ::aGetMetas(.f.)[1]
		nPrevia		:= 0  
		
		lTemValor 	:= .F.
	EndIf             

	//Recupera o Real acumulado. 
	If lMelhorF
		nRealAcum	:=	::calcIndAcum(aDataDe,aDataAlvo,::cValue("ACUM_TIPO"))
	Else
		If(::cValue("ACUM_TIPO") == "2")
			nRealAcum	:=	::calcIndAcum(aDataAlvo,aDataAlvo,::cValue("ACUM_TIPO"))
		Else
			nRealAcum	:=	::calcIndAcum(aDataDe	,aDataAte,::cValue("ACUM_TIPO"))
		EndIf		
	EndIf
    
	//Recupera a meta Acumulada.    
	If lMelhorF
		nMetaAcum	:=	::calcMetaAcum(aDataDe,aDataAlvo,::cValue("ACUM_TIPO"))
	Else
		if(::cValue("ACUM_TIPO") == "2")
			nMetaAcum	:=	::calcMetaAcum(aDataAlvo,aDataAlvo,::cValue("ACUM_TIPO"))
		else
			nMetaAcum	:=	::calcMetaAcum(aDataDe,aDataAte,::cValue("ACUM_TIPO"))
		endif
	EndIf	
         
  	//Realiza o tratatamento dos valores acumulados.  
	If (::nValue("ALVO1")==0 .and. ::nValue("ALVO2")==0 .and. ::nValue("ALVO3")==0 )
		aVlrAcumu	:= {0, 0, nMetaAcum, nRealAcum,0}
	Else
		aVlrMeta	:= ::aGetMetas(.T.,aDataDe,aDataAte)
		aVlrAcumu 	:= {aVlrMeta[1], aVlrMeta[2], nMetaAcum, nRealAcum,aVlrMeta[3]}			
	EndIf
	   
	//Recupera o status do indicador. 					
	nStatus		:= iif( lTemValor, ::nIndStatus(oPlanilha),  ESTAVEL_GRAY )  

	//Recupera o status acumulado do indicador.   
	If (lMelhorF)
		nAcuStatus := ::nGetFxStatus(  ::aIndValores(oPlanilha, aVlrAcumu) ) 
	Else
		nAcuStatus := ::nGetIndStatus( ::aIndValores(oPlanilha, aVlrAcumu) ) 
	EndIf

	aValores[VAL_REAL]			:= nReal	
	aValores[VAL_META]			:= nMeta
	aValores[VAL_REAL_ACU]		:= nRealAcum
	aValores[VAL_META_ACU]		:= nMetaAcum
	aValores[VAL_REAL_STATUS]	:= nStatus
	aValores[VAL_ACUM_STATUS]	:= nAcuStatus
   	aValores[VAL_PREVIA]		:= nPrevia      
return aValores

// Lista XML para anexar ao pai
method oToXMLList(cFilter, lScorec) class TKPI015
	local oNode, oAttrib, oXMLNode, nInd
	local oDepto 	 := nil
	
	Default cFilter  := ""  //Filtro
	Default lScorec	 := .f. //Exibir Departamentos
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	if lScorec     
		// Scorecard
		oAttrib:lSet("TAG000", "SCOREC")
		oAttrib:lSet("CAB000", ::oOwner():getStrCustom():getStrSco(CAD_OBJETIVO))
		oAttrib:lSet("CLA000", KPI_STRING)
		// Nome
		oAttrib:lSet("TAG001", "NOME")
		oAttrib:lSet("CAB001", TEXT_ENTITY)
		oAttrib:lSet("CLA001", KPI_STRING)  
	else 
		// Nome
		oAttrib:lSet("TAG000", "NOME")
		oAttrib:lSet("CAB000", TEXT_ENTITY)
		oAttrib:lSet("CLA000", KPI_STRING)  
	endif                               

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	::SavePos()	
	::SetOrder(5)//Ordem de nome
	
	//Se o id do grupo for passado como parâmetro, filtrar os indicadores que pertecem ao grupo
	if!(cFilter == "")
		::cSQLFilter(cFilter)
		::lFiltered(.t.)
		::_first()
	endif
	
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := {{"ID",""},{"NOME",""},{"ID_SCOREC",""}}
			for nInd := 1 to len(aFields)
				if aFields[nInd][1] == "ID_SCOREC" 
					if lScorec // Exibi o nome do departamento
						oDepto := ::oOwner():oGetTable("SCORECARD")
						if oDepto:lSeek(1, {::cValue(aFields[nInd][1])})
							oNode:oAddChild(TBIXMLNode():New("SCOREC", oDepto:cValue("NOME")))	   
							oNode:oAddChild(TBIXMLNode():New("ID_SCOREC", oDepto:cValue("ID")))	
						else                                                        
							oNode:oAddChild(TBIXMLNode():New("SCOREC", ""))	
							oNode:oAddChild(TBIXMLNode():New("ID_SCOREC", ""))	
						endif 
					endif
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ::cValue(aFields[nInd][1])))
				endif
			next
		endif			
		::_Next()		
	end
	::cSQLFilter("")
	::RestPos()
return oXMLNode

// Carregar
method oToXMLNode( cId, cLoadCmd ) class TKPI015
	local oXMLNode   		:= TBIXMLNode():New(TAG_ENTITY)
	local oParametro 		:= ::oOwner():oGetTable("PARAMETRO")  
	local oUser		 		:= oKpiCore:foSecurity:oLoggedUser()
	local lIsAdmin	 		:= oUser:lValue("ADMIN")      
	local oUsrGrp			:= ::oOwner():oGetTool("USERGROUP")
	local oDWConsulta		:= nil
	local oTableGrupo		:= nil
	local oTabMetaFormula	:= nil
	local oTabPlanilha		:= nil
	local oTabUnidade		:= nil
	local aFields			:= {}
	local aDatas			:= {}
	local nInd				:= 0
	local nBlqInd	 		:= 0 
	local cAno				:= ""
	local cFormula  		:= ""
	local nBlqVlr	 		:= KPI_PLANIND_OK 
	local xValue			:= ""
	local cTpResp			:= ""
	local cTpRespCol		:= ""
	
	if(!empty(cLoadCMD) .and. subs(cLoadCMD,1,9) == 'TABLECARD')
		aDatas := aBIToken(cLoadCmd, "|", .f.)
		if(len(aDatas)>2)
			dDataDe := xBIConvTo("D",aDatas[2])
			ddataate := xBIConvTo("D",aDatas[3])
		endif
		oXMLNode := ::oOwner():oGetTable("PCOMPXIND"):oMakeTableComp(dDataDe, dDataAte, self)		
	elseif(!empty(cLoadCMD) .and. subs(cLoadCMD,1,11) == 'FILTER_YEAR')
		oTabPlanilha 	:= ::oOwner():oGetTable("PLANILHA")	
		aDatas := aBIToken(cLoadCmd, "|", .f.)                                              
		cAno := aDatas[2]
		oXMLNode:oAddChild(oTabPlanilha:oToXMLList(::cValue("ID"),::nValue("FREQ"),cAno)) 
	else
		oTableGrupo		:= ::oOwner():oGetTable("GRUPO_IND")
		oTabMetaFormula	:= ::oOwner():oGetTable("METAFORMULA")
		oTabPlanilha	:= ::oOwner():oGetTable("PLANILHA")	
		oTabUnidade		:= ::oOwner():oGetTable("UNIDADE")
		oDWConsulta		:= ::oOwner():oGetTable("DWCONSULTA")		

		/*Recebe o valor da fórmula*/
		cFormula := Alltrim(DwStr(::cValue("FORMULA")))

		//Restrições
		if !lIsAdmin
			//Verifica se o usuario tem permissao para efetuar manutencao no indicador
			if !(::oOwner():foSecurity:lHasAccess("INDICADOR", "0", "MANUTENCAO"))
				nBlqInd := 1  
			endif				
			
			//Verifica se o usuario tem permissao de visualizacao na planilha
			if !(::oOwner():foSecurity:lHasAccess("PLANILHA", "0", "CARREGAR"))
				nBlqVlr := KPI_PLANIND_NORIGHTS        		
			//Verifica se bloqueia alteracoes para indicadores que possuam formulas
			elseif oParametro:lSeek(1, {"BLQ_ALT_VLR"}) .and. oParametro:lValue("DADO") .and. len(cFormula) > 0
				nBlqVlr := KPI_PLANIND_FORMULE
			//Verifica se somente responsaveis pelo departamento, indicador e coleta podem alterar a planilha
			elseif oParametro:lSeek(1, {"OWNER_ALT_PLANILHA"}) .and. oParametro:lValue("DADO")
				if !(  ::isResp(oUser:cValue("ID"),RESP_COL);  //Responsavel pela coleta.
					.or. ::isResp(oUser:cValue("ID"),RESP_IND);	//Responsavel pela cobranca.
				  	.or. (::cGetUserOwnerSco() == oUser:cValue("ID")) )	//Dono do Departamento
						nBlqVlr := KPI_PLANIND_OWNER
	            endif
			endif
		endif    

		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			xValue := aFields[nInd][2]
			If aFields[nInd][1] == "TP_RESP" 
				If empty(xValue)
					xValue := TIPO_USUARIO
				EndIf
				cTpResp := xValue
			ElseIf aFields[nInd][1] == "TP_RESPCOL"
				If empty(xValue)
					xValue := TIPO_USUARIO
				EndIf
				cTpRespCol := xValue
			EndIf
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], xValue))
		next

		oXMLNode:oAddChild(TBIXMLNode():New("VALOR_PREVIO",(oParametro:getValue("VALOR_PREVIO") == "T") ))  
		oXMLNode:oAddChild(TBIXMLNode():New("INFO_INC_META",(oParametro:getValue("INFO_INC_META"))))
		oXMLNode:oAddChild(TBIXMLNode():New("INFO_ALT_META",(oParametro:getValue("INFO_ALT_META"))))
		oXMLNode:oAddChild(TBIXMLNode():New("INFO_EXC_META",(oParametro:getValue("INFO_EXC_META"))))				
		oXMLNode:oAddChild(TBIXMLNode():New("BLQ_ALT_VLR", nBlqVlr))
		oXMLNode:oAddChild(TBIXMLNode():New("BLQ_ALT_IND", nBlqInd))
		oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN",if(lIsAdmin,"T","F")))
		oXMLNode:oAddChild(TBIXMLNode():New("DW_URL",oParametro:getValue("DW_URL")))
		oXMLNode:oAddChild(TBIXMLNode():New("VERIFICADOR", ::cValue("NOME")))
		oXMLNode:oAddChild(TBIXMLNode():New("AVAL_META_SCORE",(oParametro:getValue("AVAL_META_SCORE"))))

		//Acrescenta combos
		oXMLNode:oAddChild(::oXMLFrequencia())
		oXMLNode:oAddChild(::oXMLTipoAtualizacao())
		oXMLNode:oAddChild(oTableGrupo:oToXMLList())//Grupo de Indicadores.
		oXMLNode:oAddChild(oTabMetaFormula:oToXMLList())//Lista da tabela formulas
		oXMLNode:oAddChild(::oFormulaToXML(cFormula))//Transforma a formula em XML.
    	
		oXMLNode:oAddChild(oUsrGrp:oTreeUsrGrp())		
		oXMLNode:oAddChild(oUsrGrp:oUsuGroup())
		
		oXMLNode:oAddChild(oTabUnidade:oToXMLList())		
		
		oXMLNode:oAddChild(oTabUnidade:oToXMLList())//Adiciona a lista de unidades de medida

		//Filtro por Ano
		cAno := alltrim(str(year(date())))
		oXMLNode:oAddChild(oTabPlanilha:oGetAllYear(::cValue("ID")))   
		oXMLNode:oAddChild(TBIXMLNode():New("ID_CBOYEAR", cAno))
		
		//Dados da planilha de valores
		oXMLNode:oAddChild(oTabPlanilha:oToXMLList(::cValue("ID"),::nValue("FREQ"),cAno))  
		
		//Lista de consultas
		oXMLNode:oAddChild(oDWConsulta:oToXmlList(cID))
		oXMLNode:oAddChild(TBIXMLNode():New("SGI_USER",alltrim(oUser:cValue("NOME"))))		
		
		oXMLNode:oAddChild(TBIXMLNode():New("TP_RESP_ID_RESP", 		cTpResp + ::cValue("ID_RESP")))
		oXMLNode:oAddChild(TBIXMLNode():New("TP_RESPCOL_ID_RESPCOL",cTpRespCol + ::cValue("ID_RESPCOL")))
    endif
return oXMLNode              


// Retorna o ID do responsável do departamento no indicador posicionado
method cGetUserOwnerSco() class TKPI015 
	local oDepto   		:= ::oOwner():oGetTable("SCORECARD") 
	local cRet 			:= ""
	
	if oDepto:lSeek(1, {::cValue("ID_SCOREC")})
		cRet := oDepto:cValue("RESPID")
	endif
return cRet

	
/*Insere nova entidade*/
method nInsFromXML(oXML, cPath) class TKPI015
	local aFields, nInd, nStatus := KPI_ST_OK, aIndTend
	local nQtdReg,cCodID,nTotReg,aRegNode
	local oTabPlanilha 	:= ::oOwner():oGetTable("PLANILHA")
	local oDWConsulta	:= ::oOwner():oGetTable("DWCONSULTA")	
	local nFreq 		:= 0
	local cCodClieDup	:= ""
	local oDepto		:= NIL
	local cLog			:= ""  

	Private oXMLInput 	:= oXML

	aFields := ::xRecord(RF_ARRAY, {"ID","PLANILHA"})       

	/*Extrai valores do XML*/
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))

		if(aFields[nInd][1] == "FORMULA")
			if(::nValidaFormula(aFields[nInd][2]) == KPI_ST_VALIDATION )
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif
		endif

		if aFields[nInd][1] == "FREQ"
			nFreq := aFields[nInd][2]
		endif 

		 //Validacao do cod. do cliente
		if aFields[nInd][1] == "ID_CODCLI"
			cCodClieDup := ::cFindCodClieDup("0",aFields[nInd][2])
		    if len(cCodClieDup) > 0
			    ::fcMsg := cCodClieDup
				return KPI_ST_VALIDATION
		    endif
		endif
	next

	::oOwner():oOltpController():lBeginTransaction()

	cCodID := ::cMakeID()
	aAdd(aFields, {"ID",cCodID})

	// Gravacao do indicador
	if !::lAppend(aFields)
		if ::nLastError() == DBERROR_UNIQUE
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif  
	else
		cLog := STR0045 //"Incluido o indicador"
		cLog += ": " + alltrim( ::cValue( "NOME" ) )

		oDepto := ::oOwner():oGetTable("SCORECARD")

		if oDepto:lSeek(1, { ::cValue("ID_SCOREC") } )
			cLog += "<br>"
			cLog += "Scorecard"
			cLog += ": " + oDepto:cValue("NOME")
		endif 
		oKpiCore:LogUser( cLog )
	endif	

	if nStatus == KPI_ST_OK
		//Gravacao da planilha de valores
		if valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PLANILHAS"), "_PLANILHA"))!="U"
			aRegNode := &("oXMLInput:"+cPath+":_"+"PLANILHAS")//Pegando os valores da planilhas
			if valtype(aRegNode:_PLANILHA)=="A"
				for nQtdReg := 1 to len(aRegNode:_PLANILHA)
					nStatus	:= oTabPlanilha:nInsFromXML(aRegNode:_PLANILHA[nQtdReg],cCodID,nFreq)

					if nStatus != KPI_ST_OK
						::fcMsg := oTabPlanilha:fcMsg
						exit
					endif
				next nQtdReg
			elseif valtype(aRegNode:_PLANILHA)=="O"
				nStatus	:= oTabPlanilha:nInsFromXML(aRegNode:_PLANILHA,cCodID,nFreq)
				::fcMsg := oTabPlanilha:fcMsg
			endif
		endif
	endif

	if nStatus == KPI_ST_OK	
		//Gravacao da planilha de consultas
		if valtype(XmlChildEx(&("oXMLInput:"+cPath+":_DWCONSULTAS"), "_DWCONSULTA"))!="U"
			aRegNode := &("oXMLInput:"+cPath+":_"+"DWCONSULTAS")//Pegando os valores da planilhas
			if valtype(aRegNode:_DWCONSULTA)=="A"
				for nQtdReg := 1 to len(aRegNode:_DWCONSULTA)
					nStatus	:= oDWConsulta:nInsFromXML(aRegNode:_DWCONSULTA[nQtdReg],cCodID)

					if(nStatus != KPI_ST_OK)
						::fcMsg := oDWConsulta:fcMsg
						exit
					endif
				next nQtdReg
			elseif valtype(aRegNode:_DWCONSULTA)=="O"
				nStatus	:= oDWConsulta:nInsFromXML(aRegNode:_DWCONSULTA,cCodID)
				::fcMsg := oDWConsulta:fcMsg			
			endif
		endif
	endif

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI015
	local oTabPlanilha 	:= ::oOwner():oGetTable("PLANILHA")
	local oDWConsulta	:= ::oOwner():oGetTable("DWCONSULTA")		
	Local oJustAlt		:= ::oOwner():oGetTable("ALTERACAOMETA")
	local oNodePlan		:= nil 	
	local cFormula		:= ""
	local cIdGrupo		:= ""	
	local cCodID		:= ""
	local cNewFormula	:= ""  
	local cOldFormula 	:= ""      
	local cCodClieDup	:= ""
	local lPosicionado 	:= .f.
	local lChanged 		:= .f.
	local lPossuiGrupo	:= .f.	
	local aSavePos		:= {}		
	local nFreq			:= 0
	local nInd			:= 0
	local nQtdReg		:= 0
	local nStatus 		:= KPI_ST_OK	
	local oDepto		:= NIL
	local cLog			:= ""
	/*Recebe a infomação de propriedade [T|F]*/
	Local lPrivado		:= .F.
	
	Private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)	
	       
	/*Rasteira a posição do atributo fórmula que será usada para recuperar o valor.*/ 
	nPos := aScan(aFields, {|x| DwStr(x[1]) == "ISPRIVATE"})

	/*Idenfica se o indicador é proprietário.*/
	lPrivado :=  AllTrim(&("oXMLInput:"+cPath+":_"+aFields[nPos][1]+":TEXT")) == PRIVADO   

	/*Extrai valores do XML*/
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))

		if(aFields[nInd][1] == "ID")
			cCodID := aFields[nInd][2]
			if(::lSeek(1, {cCodID}))
				if(lPrivado)
					/*Atribui a expressão descriptografada a variável cOldFormula para ser utilizada no processamento.*/
					cOldFormula := KPIUnCripto(KPILimpaFormula(self:cValue("FORMULA")))
				Else
					/*Atribui a expressão a variável cOldFormula para ser utilizada no processamento.*/
					cOldFormula := alltrim(::cValue("FORMULA"))
				EndIf
				lPosicionado := .t.
			endif
		endif	

		if(aFields[nInd][1] =="FREQ")
			nFreq := aFields[nInd][2]
		endif

        //Validacao do cod. do cliente
		if( aFields[nInd][1] =="ID_CODCLI" )   
			cCodClieDup := ::cFindCodClieDup(cCodID,aFields[nInd][2])
		    if len(cCodClieDup) > 0
			    ::fcMsg := cCodClieDup
				return KPI_ST_VALIDATION  			 
		    endif
		endif
		
		//Validacao da formula.
		if(aFields[nInd][1] == "FORMULA")				
			cNewFormula	:= 	aFields[nInd][2]

			if(::nValidaFormula(cNewFormula, lPrivado)==KPI_ST_VALIDATION)
				return KPI_ST_VALIDATION
			else
				//metodo que verifica se a formula contém meta formula e retorna um array das meta formulas
				aMetaForm := ::aContemMF(aFields[nInd][2])
				if(!empty(aMetaForm))    
					// verifica se alguma meta formula contida no array contem o indicador pai
					if(::lDependInd(cCodID, aMetaForm))
						::fcMsg := STR0021 //"A meta fórmula não pode conter o indicador de origem em sua fórmula"
						return KPI_ST_VALIDATION  
					else
						::fcMsg := ""
					endif
				endif
				
				if(lPrivado)
					/*Atribui a expressão descriptografada a variável cOldFormula para ser utilizada no processamento.*/
					cNewFormula := KPIUnCripto(KPILimpaFormula(aFields[nInd][2]))
				EndIf
		
				if!(::lComparaFormulas(cOldFormula,cNewFormula))
					 lChanged := .t.
				endif
			endif

			if len(aFields[nInd][2]) == 0
				aFields[nInd][2] := " "
			endif
		endif
	next
	
	::oOwner():oOltpController():lBeginTransaction()
	
	// Verifica condições de gravação (append ou update)
	if(!lPosicionado)
		nStatus := KPI_ST_BADID
	else       
		//Valida referencia circular.
		dbSelectArea(::cAlias())
		aSavePos	:=	{IndexOrd(), recno(), ::cSqlFilter()}

		if (! empty(cNewFormula) .and. ::checRefCircular("I." + alltrim(cCodID),cNewFormula))
			::fcMsg := STR0023 // "Está fórmual contém referência circular."
			nStatus := KPI_ST_VALIDATION  
		endif

		if nStatus == KPI_ST_OK
			::faSavePos:= aSavePos
	
			::RestPos()
		endif

		if nStatus == KPI_ST_OK			
			//Gravacao do indicador
			if !::lUpdate(aFields)
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			else
				cLog := STR0046 // "Alterado o indicador"
				cLog += ": " + alltrim( ::cValue( "NOME" ) )
	
				oDepto := ::oOwner():oGetTable("SCORECARD")
	
				if oDepto:lSeek(1, { ::cValue("ID_SCOREC") } )
					cLog += "<br>"
					cLog += "Scorecard"
					cLog += ": " + oDepto:cValue("NOME")
				endif 

				oKpiCore:LogUser( cLog )

				//Gravando os registros marcado para exclusao
				if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PLANILHAS"), "_REG_EXCLUIDO"))!="U")
					aRegNode := &("oXMLInput:"+cPath+":_PLANILHAS:_REG_EXCLUIDO")//Pegando os valores da planilhas
					if(valtype(aRegNode:_EXCLUIDOS:_PLANILHA)=="A")		
						aRegNode := aRegNode:_EXCLUIDOS:_PLANILHA
						for nQtdReg := 1 to len(aRegNode)
							nStatus	:= oTabPlanilha:nDelFromXML(aRegNode[nQtdReg])
							if(nStatus != KPI_ST_OK)
								::fcMsg := oTabPlanilha:fcMsg
								exit
							endif			
						next nQtdReg
					else
						nStatus	:= oTabPlanilha:nDelFromXML(aRegNode:_EXCLUIDOS:_PLANILHA)				
					endif
				endif				
	            
				if nStatus == KPI_ST_OK
					//Atualizando os valores da planilha
					if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PLANILHAS"), "_PLANILHA"))!="U")
						aRegNode := &("oXMLInput:"+cPath+":_PLANILHAS")//Pegando os valores da planilhas
						if(valtype(aRegNode:_PLANILHA)=="A")
							for nQtdReg := 1 to len(aRegNode:_PLANILHA)  
								//Atualiza apenas as linhas da planilha que sofreram alteração.
								If ( aRegNode:_PLANILHA[nQtdReg]:_UPDATED:TEXT == "T" )
									nStatus	:= oTabPlanilha:nUpdFromXML(aRegNode:_PLANILHA[nQtdReg],cCodID,nFreq)
									if(nStatus != KPI_ST_OK)
										::fcMsg := oTabPlanilha:fcMsg
										exit
									endif	 
								EndIf		
							next nQtdReg
						elseif(valtype(aRegNode:_PLANILHA)=="O")
							nStatus	:= oTabPlanilha:nUpdFromXML(aRegNode:_PLANILHA,cCodID,nFreq)
							::fcMsg := oTabPlanilha:fcMsg					
						endif
					endif
				endif
				      
				
				if nStatus == KPI_ST_OK
					//Gravação da integração com o DW
					if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_DWCONSULTAS"), "_REG_EXCLUIDO"))!="U")
						aRegNode := &("oXMLInput:"+cPath+":_DWCONSULTAS:_REG_EXCLUIDO")//Pegando os valores da planilhas
						if(valtype(aRegNode:_EXCLUIDOS:_DWCONSULTA)=="A")		
							aRegNode := aRegNode:_EXCLUIDOS:_DWCONSULTA
							for nQtdReg := 1 to len(aRegNode)
								nStatus	:= oDWConsulta:nDelFromXML(aRegNode[nQtdReg])
								if(nStatus != KPI_ST_OK)
									::fcMsg := oDWConsulta:fcMsg
									exit
								endif			
							next nQtdReg
						else
							nStatus	:= oDWConsulta:nDelFromXML(aRegNode:_EXCLUIDOS:_DWCONSULTA)				
						endif
					endif
				endif

				if nStatus == KPI_ST_OK		
					//Atualizando os valores da planilha
					if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_DWCONSULTAS"), "_DWCONSULTA"))!="U")
						aRegNode := &("oXMLInput:"+cPath+":_DWCONSULTAS")//Pegando os valores da planilhas
						if(valtype(aRegNode:_DWCONSULTA)=="A")
							for nQtdReg := 1 to len(aRegNode:_DWCONSULTA)
								nStatus	:= oDWConsulta:nUpdFromXML(aRegNode:_DWCONSULTA[nQtdReg],cCodID)
								if(nStatus != KPI_ST_OK)
									::fcMsg := oDWConsulta:fcMsg
									exit
								endif			
							next nQtdReg
						elseif(valtype(aRegNode:_DWCONSULTA)=="O")
							nStatus	:= oDWConsulta:nUpdFromXML(aRegNode:_DWCONSULTA,cCodID)
							::fcMsg := oDWConsulta:fcMsg					
						endif			
					endif
				endif
			endif	
		endif
	endif

	if nStatus == KPI_ST_OK
		cIdGrupo := alltrim(::cValue("ID_GRUPO"))
		if( (!empty(cIdGrupo)) .and. (!cIdGrupo == "0"))
			lPossuiGrupo := .t.
		endif
    endif 
    
   	//Gravacao da Justificativa de Alteracao de Meta
	If nStatus == KPI_ST_OK
		//Gravacao da planilha de consultas
		If (valType(XmlChildEx(&("oXMLInput:"+cPath+":_JUSTIFICATIVAS"),"_JUSTIFICATIVA")) != "U")
			aRegNode := &("oXMLInput:"+cPath+":_"+"JUSTIFICATIVAS")   

			oJustAlt:clrIdJust() 

			If (valType(aRegNode:_JUSTIFICATIVA)=="A")
				For nQtdReg := 1 To Len(aRegNode:_JUSTIFICATIVA)
					nStatus	:= oJustAlt:nInsFromXML(aRegNode:_JUSTIFICATIVA[nQtdReg])

					If (nStatus != KPI_ST_OK)
						Exit
					EndIf			
				Next nQtdReg
			ElseIf (valType(aRegNode:_JUSTIFICATIVA) == "O")
				nStatus	:= oJustAlt:nInsFromXML(aRegNode:_JUSTIFICATIVA)
			EndIf
			
			If (nStatus == KPI_ST_OK)
				oJustAlt:lEmailJust()
			EndIf                    
		EndIf	                                                				
	EndIf

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

    if nStatus == KPI_ST_OK .and. lChanged .and. lPossuiGrupo
		nStatus := KPI_ST_FORMULA_CHANGE
	endif
return nStatus

// Exluir dependências (transação deve ser controlada do método chamador)
method nDelDepend(cID, lDelChildren) class TKPI015
	local nStatus		:= KPI_ST_OK 
	local oKpiCore		:= ::oOwner()
	local oPlanilha		:= nil
	local oGraph		:= nil
	local oDWConsulta	:= nil
	local oPlano		:= nil  
	local oJustific		:= nil
	local oNota			:= nil

	default lDelChildren := .F.

	//KPI016: Plano
	oPlano := oKpiCore:oGetTable("PLANOACAO")

	if(oPlano:lSeek(2,{cID}))
		if lDelChildren
			while !oPlano:lEof() .and. oPlano:cValue("ID_IND") == cID
				nStatus := oPlano:lDelete()

				if nStatus == KPI_ST_OK
					::_Next()
				else
					EXIT
				endif
			enddo
		else
			::fcMsg := STR0024 + STR0025 + alltrim(oPlano:cValue("NOME")) + "'!"
			nStatus := KPI_ST_VALIDATION
		endif
	endif

	//Verifica se existem indicadores filhos
	if nStatus == KPI_ST_OK .and. ::lSeek(4, {cId})
		//KPI015: Indicador
		if lDelChildren
			while !::lEof() .and. ::cValue("ID_INDICA") == cID
				//remove em cascata (sem abrir nova transação)
				nStatus := ::nDelFromXML(::cValue("ID"), ,.F.)

				if nStatus == KPI_ST_OK
					::_Next()
				else
					EXIT
				endif
			enddo
		else
			::fcMsg := "<html>" + STR0059 + "<br/><br/>" + STR0060 + "<br/>"

			while !::lEof() .and. ::cValue("ID_INDICA") == cID
				::fcMsg += "- " + alltrim(::cValue("NOME")) + "<br/>"

				::_Next()
			enddo
			::fcMsg += "</html>"

			nStatus := KPI_ST_VALIDATION
		endif
	endif

	if nStatus == KPI_ST_OK
		oPlanilha := oKpiCore:oGetTable("PLANILHA")
		oPlanilha:SetOrder(2) // Por ordem de id
		oPlanilha:cSQLFilter("PARENTID = '" + cID + "'") // Filtra pelo paI
		oPlanilha:lFiltered(.t.)
		oPlanilha:_First()

		while !oPlanilha:lEof()
			if !oPlanilha:lDelete()
				nStatus := KPI_ST_INUSE

				EXIT
			endif
			oPlanilha:_Next()
		enddo
		oPlanilha:cSQLFilter("")
	endif

	if nStatus == KPI_ST_OK
		//Excluindo as personalizacoes do grafico.
		oGraph := oKpiCore:oGetTable("GRAPH_IND")

		oGraph:setOrder(1) // Por ordem de id
		oGraph:cSQLFilter("INDICADOR = '" + cID + "'") 
		oGraph:lFiltered(.t.)
		oGraph:_First()

		while(!oGraph:lEof())
			if(!oGraph:lDelete())
				nStatus := KPI_ST_INUSE
				EXIT
			endif
			oGraph:_Next()
		enddo
	endif

	if nStatus == KPI_ST_OK	
		//Excluir as consultas de integração com o DW
		oDWConsulta := oKpiCore:oGetTable("DWCONSULTA")

		oDWConsulta:SetOrder(2) // Por ordem de id
		oDWConsulta:cSQLFilter("PARENTID = '" + cID + "'") // Filtra pelo paI
		oDWConsulta:lFiltered(.t.)
		oDWConsulta:_First()

		while(!oDWConsulta:lEof())
			if(!oDWConsulta:lDelete())
				nStatus := KPI_ST_INUSE
				EXIT
			endif
			oDWConsulta:_Next()
		enddo
		oDWConsulta:cSQLFilter("")
	endif   
	
	if nStatus == KPI_ST_OK
		//Excluindo as justificativas da alteracao de meta
		oJustific := oKpiCore:oGetTable("ALTERACAOMETA")

		if (oJustific:lSeek(2,{cID}))
			while(!oJustific:lEof() .And. oJustific:cValue("INDIC_ID") == cID)
				if(!oJustific:lDelete())
					nStatus := KPI_ST_INUSE
					EXIT
				endif
				oJustific:_Next()
			enddo
		EndIf
	endif	
             
	if nStatus == KPI_ST_OK	
		//Excluir notas para o indicador 
		oNota := oKpiCore:oGetTable("NOTA")

		oNota:SetOrder(2) // Por ordem de id
		oNota:cSQLFilter("ID_INDICA = '" + cID + "'") // Filtra pelo paI
		oNota:lFiltered(.t.)
		oNota:_First()

		while(!oNota:lEof())
			if(!oNota:lDelete())
				nStatus := KPI_ST_INUSE
				EXIT
			endif
			oNota:_Next()
		enddo
		oNota:cSQLFilter("")
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(cID, cCmd, lTransaction) class TKPI015
	local nStatus		:= KPI_ST_OK 
	local oKpiCore		:= ::oOwner()
	local oDepto		:= nil
	local cLog			:= ""

	default lTransaction := .T.

	if lTransaction
		oKpiCore:oOltpController():lBeginTransaction()
	endif

	if nStatus == KPI_ST_OK
		// Remove dependências
		nStatus := ::nDelDepend(cID)
	endif

	// Deleta o elemento
	if nStatus == KPI_ST_OK
		if ::lSeek(1, {cID})
			if !::lDelete()
				nStatus := KPI_ST_INUSE
			else
				cLog := STR0047 //"Excluido o indicador"
				cLog += ": " + alltrim( ::cValue( "NOME" ) )

				oDepto := ::oOwner():oGetTable("SCORECARD")

				if oDepto:lSeek(1, { ::cValue("ID_SCOREC") } )
					cLog += "<br>"
					cLog += "Scorecard"
					cLog += ": " + oDepto:cValue("NOME")
				endif 
				oKpiCore:LogUser( cLog )
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
    endif

	if lTransaction
		if nStatus != KPI_ST_OK
			oKpiCore:oOltpController():lRollback()
		endif
		oKpiCore:oOltpController():lEndTransaction()
	endif
return nStatus

// Unidade
method oXMLUnidade() class TKPI015
	local oAttrib, oNode, oXMLOutput
	local nInd, aUnidades := {STR0013,STR0014,STR0015,STR0016,STR0017,STR0018  }//"Reais", "Dólares", "Kgs", "Tons", "%", "Pontos"

	//Ordena o array aUnidades por nome
	ASORT(aUnidades,,, { |x, y| UPPER(x) < UPPER(y) })
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("UNIDADES",,oAttrib)

	for nInd := 1 to len(aUnidades)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("UNIDADE"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aUnidades[nInd]))
	next
return oXMLOutput

//Retorna a Frequencia
method oXMLFrequencia() class TKPI015
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("FREQUENCIAS",,oAttrib)
	
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_ANUAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0004))	//Anual
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_SEMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0005))	//Semestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_QUADRIMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0006))	//Quadrimestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_TRIMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0007))	//Trimestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_BIMESTRAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0008))	//Bimestral
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_MENSAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0009))	//Mensal
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_QUINZENAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))	//Quinzenal
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_SEMANAL))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0011))	//Semanal
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("FREQUENCIA"))
	oNode:oAddChild(TBIXMLNode():New("ID", KPI_FREQ_DIARIA))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0012))	//Diaria
return oXMLOutput

//Retorna os Tipos de Atualizações
method oXMLTipoAtualizacao() class TKPI015
	local oAttrib, oNode, oXMLOutput

	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("TIPOS",,oAttrib)
	
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOATU"))
	oNode:oAddChild(TBIXMLNode():New("ID", 1))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0040))	//Manual
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOATU"))
	oNode:oAddChild(TBIXMLNode():New("ID", 2))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0041))	//Via Planilha
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOATU"))
	oNode:oAddChild(TBIXMLNode():New("ID", 3))
	oNode:oAddChild(TBIXMLNode():New("NOME", STR0042))	//Via Fonte de Dados
return oXMLOutput

//Retorna a Frequencia
method nQtdFrequencia(aDataDe, aDataAte, nFrequencia) class TKPI015
	local nVezes := 1
	local nAnoDe := val(aDataDe[1])
	local nMesDe := val(aDataDe[2])
	local nAnoAte := val(aDataAte[1])
	local nMesAte := val(aDataAte[2])
		
	do case
		case nFrequencia == KPI_FREQ_ANUAL
			nVezes := nAnoAte - nAnoDe
		case nFrequencia == KPI_FREQ_SEMESTRAL
			nVezes := (nAnoAte - nAnoDe) * 2
			nVezes += abs((nMesAte - nMesDe) + 1)
		case nFrequencia == KPI_FREQ_QUADRIMESTRAL
			nVezes := (nAnoAte - nAnoDe) * 3
			nVezes += abs((nMesAte - nMesDe) + 1)
		case nFrequencia == KPI_FREQ_TRIMESTRAL
			nVezes := (nAnoAte - nAnoDe) * 4
			nVezes += abs((nMesAte - nMesDe) + 1)
		case nFrequencia == KPI_FREQ_BIMESTRAL
			nVezes := (nAnoAte - nAnoDe) * 6
			nVezes += abs((nMesAte - nMesDe) + 1)
		case nFrequencia == KPI_FREQ_MENSAL
			nVezes := (nAnoAte - nAnoDe) * 12
			nVezes += abs((nMesAte - nMesDe) + 1)
		case nFrequencia == KPI_FREQ_QUINZENAL
			nVezes := (nAnoAte - nAnoDe) * 24
			nVezes += abs((nMesAte - nMesDe) * 2)
		case nFrequencia == KPI_FREQ_SEMANAL
			nVezes := cTod(aDataAte[3]+'/'+aDataAte[2]+'/'+aDataAte[1]) - cTod(aDataDe[3]+'/'+aDataDe[2]+'/'+aDataDe[1])
			nVezes := nVezes / 7
		case nFrequencia == KPI_FREQ_DIARIA
			nVezes := cTod(aDataAte[3]+'/'+aDataAte[2]+'/'+aDataAte[1]) - cTod(aDataDe[3]+'/'+aDataDe[2]+'/'+aDataDe[1])
	endcase
return nVezes

/*
*Retorna o nome da frequencia.
*/
method cGetFreqName(nFreq) class TKPI015
	local cFreqName := ""

	if(nFreq == KPI_FREQ_ANUAL)
		cFreqName := STR0004
	elseif(nFreq == KPI_FREQ_SEMESTRAL)	
		cFreqName := STR0005
	elseif(nFreq == KPI_FREQ_TRIMESTRAL)	
		cFreqName := STR0007
	elseif(nFreq == KPI_FREQ_QUADRIMESTRAL)	
		cFreqName := STR0006 
	elseif(nFreq == KPI_FREQ_BIMESTRAL)	
		cFreqName := STR0008
	elseif(nFreq == KPI_FREQ_MENSAL)	
		cFreqName := STR0009
	elseif(nFreq == KPI_FREQ_QUINZENAL)	
		cFreqName := STR0010
	elseif(nFreq == KPI_FREQ_SEMANAL)	
		cFreqName := STR0011
	elseif(nFreq == KPI_FREQ_DIARIA)	
		cFreqName := STR0012
	endif
return cFreqName   

/*
*Retorna o perido baseado na frequencia do indicador
*/
method cGetPeriodo(nFreq, dDate) class TKPI015  
	Local cRet 		:= ""
    Local nSemana 	:= 1 

	if(nFreq == KPI_FREQ_ANUAL)
		cRet := alltrim(str(year(ddate)))
	elseif(nFreq == KPI_FREQ_SEMESTRAL)	
		if month(ddate) < 7
			cRet := "1º Sem./" + alltrim(str(year(ddate)))
		else
			cRet := "2º Sem./" + alltrim(str(year(ddate)))
		endif
	elseif(nFreq == KPI_FREQ_TRIMESTRAL)
		if month(ddate) < 4
			cRet := "1º Tri./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 7
			cRet := "2º Tri./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 10
			cRet := "3º Tri./" + alltrim(str(year(ddate)))
		else                                              
			cRet := "4º Tri./" + alltrim(str(year(ddate)))
		endif
	elseif(nFreq == KPI_FREQ_QUADRIMESTRAL)	
		if month(ddate) < 5
			cRet := "1º Qua./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 9
			cRet := "2º Qua./" + alltrim(str(year(ddate)))
		else                                              
			cRet := "3º Qua./" + alltrim(str(year(ddate)))
		endif
	elseif(nFreq == KPI_FREQ_BIMESTRAL)	
		if month(ddate) < 3
			cRet := "1º Bim./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 5
			cRet := "2º Bim./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 7
			cRet := "3º Bim./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 9
			cRet := "4º Bim./" + alltrim(str(year(ddate)))
		elseif month(ddate) < 11
			cRet := "5º Bim./" + alltrim(str(year(ddate)))
		else                                              
			cRet := "6º Bim./" + alltrim(str(year(ddate)))
		endif
	elseif(nFreq == KPI_FREQ_MENSAL)	
		cRet := left(mesExtenso(ddate),3) + "./" + alltrim(str(year(ddate)))
	elseif(nFreq == KPI_FREQ_QUINZENAL)	  
		if day(ddate) < 16
			cRet := "1º Qui./" + left(mesExtenso(ddate),3) + "/" +alltrim(str(year(ddate)))
		else                                              
			cRet := "2º Qui./" + left(mesExtenso(ddate),3) + "/" +alltrim(str(year(ddate)))
		endif
	elseif(nFreq == KPI_FREQ_SEMANAL)
		nSemana := nBIWeekOfYear( ddate )
		
		//-------------------------------------------------------------------
		// Verifica em qual semana do ano uma data se enquadra. 
		//-------------------------------------------------------------------
  		If( ( Month( dDate ) == 1 ) .And. ( Day( dDate ) <= 3 ) .And. ( nSemana > 1 ) )        
			//-------------------------------------------------------------------
			// Retorna o ano anterior. 
			//-------------------------------------------------------------------  
			cRet := cBIStr(nSemana) + "° Sem./" + cBIStr(Year(ddate) - 1 )    
			
		ElseIf( ( Month( dDate ) == 12 ) .And. ( Day( dDate ) >= 29 ) .And. ( nSemana == 1 ) )        
			//-------------------------------------------------------------------
			// Retorna o ano seguinte. 
			//-------------------------------------------------------------------  
			cRet := cBIStr(nSemana) + "° Sem./" + cBIStr(Year(ddate) + 1 )
		Else                                 
			//-------------------------------------------------------------------
			// Retorna o ano corrente. 
			//-------------------------------------------------------------------  
	   		cRet := cBIStr(nSemana) + "° Sem./" + cBIStr(Year(ddate) ) 
		EndIf       
	elseif(nFreq == KPI_FREQ_DIARIA)	
		cRet := dtoc(ddate)
	endif
return cRet   

//Transforma o formula em item XML.
method oFormulaToXML(cFormula) class TKPI015
	local oAttrib,oXMLNodeForm,oNode, nNumInd,aFormula, cItemFormula,cCodInd

	//Colunas
	oAttrib := TBIXMLAttrib():New()

	//Tipo
	oAttrib:lSet("TIPO", "LISTAFORMULA")
	oAttrib:lSet("RETORNA", .f.)

	oXMLNodeForm := TBIXMLNode():New("LISTAFORMULA")
	aFormula = aBIToken(cFormula, "|", .f.)
	
	for nNumInd = 1 to len(aFormula)
		cItemFormula = aFormula[nNumInd]
		if(Rat("I.", cItemFormula)>0)
			cCodInd := right(cItemFormula,len(cItemFormula)-2)
			::SavePos()
			if(::lSeek(1, {cCodInd}))
				oNode := oXMLNodeForm:oAddChild(TBIXMLNode():New("ITEMFORMULA"))
				oNode:oAddChild(TBIXMLNode():New("INDICA_ID", cCodInd))
				oNode:oAddChild(TBIXMLNode():New("INDICA_NAME",::cValue("NOME")))
				oNode:oAddChild(TBIXMLNode():New("SCORE_ID", ::cValue("ID_SCOREC")))
			endif				
			::RestPos()
		endif
	next nNumInd
return oXMLNodeForm

//Validacao da formula.
method nValidaFormula(cNewFormula, lPrivado) class TKPI015
	local	lRet		:= .t.
	local	lFisrt 		:= .t.
	local 	cNextItem	:=	""
	local 	nItem		:=	0
	local 	cItemFormula:=	"" 
	local 	aFormula	:= {}
	local   cFormula	:= ""	
   
    Default lPrivado := .F. 
    
    /*Idenfifica se o indicador é proprietário.*/        
    if (lPrivado) .And. !(KPILimpaFormula(cNewFormula) == "")
    	/*Atribui a expressão descriptografada a variável cNewFormula para ser utilizada no processamento.*/             
		cNewFormula := KPIUnCripto( KPILimpaFormula(cNewFormula))
    EndIf

	cFormula 	:= alltrim(strTran(cNewFormula,"I.",""))
	cFormula 	:= strTran(cFormula,"M.","")
	cFormula 	:= strTran(cFormula,"|","")

	//Tratamento para o erro gerado pela validacao da formula.
	begin sequence
		oErro := ErrorBlock({|e|conout("Erro na Fórmula: " + cFormula),lRet:= .F.})
		cTeste:= &cFormula
		ErrorBlock(oErro)
	end sequence		

	if(lRet)
		cFormula :=	alltrim(cNewFormula)
		cFormula :=	strTran(cFormula,"(","")
		cFormula :=	strTran(cFormula,")","")
		aFormula := aBIToken(cFormula, "|",.f.)
		
		for nItem := 1 to len(aFormula)
			cItemFormula := aFormula[nItem]
			if(! Empty(cItemFormula))
				//Checagem para determinar o primeiro item
				if(lFisrt)
					lFisrt := .f.
					if(at(cItemFormula,"*-/+") == 0)
						cNextItem	:=	"OPERANDO"
					else
						cNextItem	:=	"OPERADOR"
					endif				
				endif
				
				if(cNextItem ==	"OPERANDO" .and. at(cItemFormula,"*-/+") == 0 )
					cNextItem	:=	"OPERADOR"
				else
					if(cNextItem == "OPERADOR" .and. at(cItemFormula,"*-/+") > 0 )
						cNextItem := "OPERANDO"
					else
						lRet := .f.
						exit				
					endif
				endif
			endif			
		next nItem
	endif
	
	if lRet
		::fcMsg := STR0019//"A fórmula digitada é valida."	
		return KPI_ST_OK	
	else
		::fcMsg := STR0020//"A fórmula digitada está com erro."
		return KPI_ST_VALIDATION
	endif	       
Return
	
//Validacao via nExecute da formula.
Method nExecute(cID, cExecCMD) Class TKPI015
	Local oPlanilha := ::oOwner():oGetTable("PLANILHA")
	Local aComandos := aBIToken(cExecCMD, "#", .F.)
	Local nStatus 	:= KPI_ST_OK
	Local i			:= 0
	
	Do Case
		Case aComandos[1] == "META_EM_LOTE"
			If(::oOwner():foSecurity:lHasAccess("PLANILHA", "0", "ALTERAR") .And. ::lSeek(1, {cID}))
				aDataDe 	:= oPlanilha:aDateConv(xbiconvto("D", aComandos[2]), ::nValue("FREQ"))
				aDataAte 	:= oPlanilha:aDateConv(xbiconvto("D", aComandos[3]), ::nValue("FREQ"))
				
				aPeriodo 	:= oPlanilha:aQtdFrequencia( aDataDe, aDataAte, ::nValue("FREQ") )
				       
				::oOwner():oOltpController():lBeginTransaction()
				
				For i := 1 to Len(aPeriodo)					
					nAno := nBIVal(aPeriodo[i][1][1])
					nMes :=	nBIVal(aPeriodo[i][1][2])
					nDia := nBIVal(aPeriodo[i][1][3])
					
					dData := oPlanilha:dPerToDate(nAno, nMes, nDia, ::nValue("FREQ") )
					
					//Verifica existe valor na planilha para a data informada. 
					If (oPlanilha:lDateSeek(::cValue("ID"), dData ,::nValue("FREQ")) )
						//Verifica se o usuário tem permissão de alterar a meta para o período.      
						If(oPlanilha:nPermiteAlt(2/*META*/, {nAno, nMes, nDia}, ::nValue("FREQ"), ::cValue("ID")) == KPI_ST_OK)
							//Atualiza a meta.
							If !(oPlanilha:lUpdate({{"META", nBIVal(aComandos[4])}}))							
								If(oPlanilha:nLastError() == DBERROR_UNIQUE)
									nStatus := KPI_ST_UNIQUE
								Else
									nStatus := KPI_ST_INUSE
								EndIf
								EXIT
							EndIf
						EndIf
					EndIf
				Next i
				
				if nStatus != KPI_ST_OK
					::oOwner():oOltpController():lRollBack()
				endif

				::oOwner():oOltpController():lEndTransaction()
			EndIf			
		Case aComandos[1] == "FORMULA"
			lPrivado 	:= .F.
			
			If(::lSeek(1, {cID}))
				lPrivado :=  ::lValue("ISPRIVATE")
			EndIf
			
			nStatus := ::nValidaFormula(aComandos[2], lPrivado)			
	EndCase
Return nStatus

/*
*Retorna o Status do Indicador
*Recebe um array com os valores para comparar
*/            
method nGetIndStatus(aVlrInd) class TKPI015
	local nStatus 	 :=	ESTAVEL_GRAY
 	local nAlvoVerd	 :=	aVlrInd[1]
	local nAlvoVerm	 :=	aVlrInd[2]
	local nValorMeta := aVlrInd[3]
	local nValor	 :=	aVlrInd[4]	
	local nAlvoAzul	 :=	aVlrInd[5]
	local lAscend	 :=	::lValue("ASCEND")     
	local oParametro := ::oOwner():oGetTable("PARAMETRO") 
	local lPlanilha  := oParametro:getValue("AVAL_META_SCORE") == "T" 	
	local nValorSup  := 0
	local nValorTol  := 0
	            
	If !lPlanilha
		If(lAscend)	      
			If nValor >= nAlvoVerd
				nStatus	:=	STATUS_GREEN
				If nAlvoAzul > nAlvoVerd .And. nValor >= nAlvoAzul
					nStatus	:=	STATUS_BLUE		
				Endif
			Else
				nStatus	:=	STATUS_RED
				If nAlvoVerm <> nAlvoVerd .And. nValor >= nAlvoVerm 
					nStatus	:=	STATUS_YELLOW						
				Endif
			Endif 	
		Else
			If nValor <= nAlvoVerd
				nStatus	:=	STATUS_GREEN
				If nAlvoAzul < nAlvoVerd .And. nValor <= nAlvoAzul
					nStatus	:=	STATUS_BLUE		
				Endif
			Else
				nStatus	:=	STATUS_RED
				If nAlvoVerm <> nAlvoVerd .And. nValor <= nAlvoVerm 
					nStatus	:=	STATUS_YELLOW						
				Endif
			Endif  
		Endif
	Else
		If(lAscend)                       
	   		nValorSup := ::nGetSupValor( nValorMeta, lAscend )
	   		nValorTol := ::nGetTolValor( nValorMeta, lAscend )
	   		
			If nValor >= nValorMeta
				If nValorSup == 0 
					nStatus := STATUS_GREEN
				Else 
					If nValor <= nValorSup
						nStatus := STATUS_GREEN
					Else
						nStatus := STATUS_BLUE
					EndIf
				EndIf				
			ElseIf nValor < nValorMeta 
				If nValorTol == 0
					nStatus := STATUS_RED
				Else
					If nValorTol <= nValor
						nStatus := STATUS_YELLOW                   
					Else                               
						nStatus := STATUS_RED
					EndIf 
				EndIf
			EndIf 
		Else        
	   		nValorSup := ::nGetSupValor( nValorMeta, lAscend )
	   		nValorTol := ::nGetTolValor( nValorMeta, lAscend )
	   		
			If nValor <= nValorMeta
				If nValorSup == 0
					nStatus := STATUS_GREEN
				Else 
					If nValor >= nValorSup
						nStatus := STATUS_GREEN
					Else
						nStatus := STATUS_BLUE
					EndIf
				EndIf				
			ElseIf nValor > nValorMeta 
				If nValorTol == 0
					nStatus := STATUS_RED
				Else
					If nValorTol >= nValor
						nStatus := STATUS_YELLOW                   
					Else
						nStatus := STATUS_RED
					EndIf 
				EndIf
			EndIf
		EndIf
	endif			
return nStatus

//Verifica o status do indicador.
method nIndStatus(oPlaValor) class TKPI015   
	If ::lValue("MELHORF")   
		Return ::nGetFxStatus(::aIndValores(oPlaValor))
	Else                                           
		Return ::nGetIndStatus(::aIndValores(oPlaValor))
	EndIf

//Verifica o status da tendencia
method nIndTendencia(oPlaValor,nIndStatus,lAscendente,lMelhorFaixa)  class TKPI015
	local nTendencia	:= ESTAVEL_GRAY
	local cParentID		:= oPlaValor:cValue("PARENTID")
	local nValorAtu		:= oPlaValor:nValue("VALOR")
	local nValorAnt		:= 0

	oPlaValor:SavePos()	
	oPlaValor:_Next(-1)

	//Verifico se existe um valor anterior para calcular a tendencia.
	if(!oPlaValor:lBof() .and. cParentID == oPlaValor:cValue("PARENTID"))
		nValorAnt		:= oPlaValor:nValue("VALOR")

		//Verificando a tendencia
		do case
			case nIndStatus == STATUS_BLUE
				if(lAscendente)
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_BLUEUP
					elseif nValorAtu < nValorAnt
						nTendencia 	:= TEND_BLUEDN	
					else
						nTendencia	:= ESTAVEL_BLUE
					endif  
				ElseIf (lMelhorFaixa)
					// Implementar código				
				else
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_BLUEDN
					elseif nValorAtu< nValorAnt
						nTendencia 	:= TEND_BLUEUP	
					else
						nTendencia	:= ESTAVEL_BLUE
					endif				
				endif				
			case nIndStatus == STATUS_RED 
				if(lAscendente .Or. lMelhorFaixa)
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_REDUP
					elseif nValorAtu < nValorAnt
						nTendencia 	:= TEND_REDDN	
					else
						nTendencia	:= ESTAVEL_RED
					endif 
				ElseIf (lMelhorFaixa)				
					// Implementar Código
				Else
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_REDDN
					elseif nValorAtu< nValorAnt
						nTendencia 	:= TEND_REDUP	
					else
						nTendencia	:= ESTAVEL_RED
					endif				
				endif				
			case nIndStatus == STATUS_GREEN
				if(lAscendente .Or. lMelhorFaixa)
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_GREENUP
					elseif nValorAtu< nValorAnt
						nTendencia 	:= TEND_GREENDN	
					else
						nTendencia	:= ESTAVEL_GREEN			
					endif				
				ElseIf (lMelhorFaixa)
					// Implementar Código
				Else
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_GREENDN
					elseif nValorAtu< nValorAnt
						nTendencia 	:= TEND_GREENUP
					else
						nTendencia	:= ESTAVEL_GREEN			
					endif				
				endif					
			otherwise
				if(lAscendente .Or. lMelhorFaixa)
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_YELLOWUP
					elseif nValorAtu	< nValorAnt
						nTendencia 	:= TEND_YELLOWDN	
					else
						nTendencia	:= ESTAVEL_YELLOW			
					endif 
				ElseIf (lMelhorFaixa)
					// Implementar Código
				Else
					if nValorAtu	> nValorAnt
						nTendencia 	:= TEND_YELLOWDN
					elseif nValorAtu	< nValorAnt
						nTendencia 	:= TEND_YELLOWUP	
					else
						nTendencia	:= ESTAVEL_YELLOW			
					endif
				endif
		endcase			
	endif
	oPlaValor:RestPos()
return nTendencia

/*Metodo otimizado para calcular o acumulado de um indicador em um periodo*/
method calcIndAcum(aDataDe,aDataAte,cTipoCalc,cIndID) class TKPI015
	local nValorAcum	:= 0
	Local cFormula 		:= ""
	/*Identifica se o indicador é proprietário.*/
	Local lPrivado 	:= ::lValue("ISPRIVATE")

	default cTipoCalc	:= "0"
	default cIndID		:= ::cValue("ID")
         
 	If (lPrivado)
		/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/
	 	cFormula := KPIUnCripto(KPILimpaFormula(::cValue("FORMULA")))    
	Else  		
		/*Atribui a expressão a variável cFormula para ser utilizada no processamento.*/
	 	cFormula  := Alltrim(DwStr(::cValue("FORMULA")))  
	EndIf

	//Para efeito de melhoria de performance a soma dos acumulados e realizada via comando SQL.
	cOldAlias := alias()

	if(cTipoCalc == "0")//Soma.
		cSql :=	"select Sum(VALOR) from SGI015B Where " 
	elseif(cTipoCalc == "1")//Media.
		cSql :=	"select Avg(VALOR) from SGI015B Where " 
	elseif(cTipoCalc == "2")//Sem calculo do acumulado.
		cSql :=	"select VALOR from SGI015B Where " 		
	elseif(cTipoCalc == "3")//Acumulado pela formula
		nValorAcum := ::nAcum_Formula(1, cFormula ,aDataDe,aDataAte)
	endif
	
	if ! (cTipoCalc == "3")
		cSql +=	"PARENTID = '" + cIndID + "' and "
  		cSql +=	cBISQLConcat({"ANO","MES","DIA"}) + " >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
   		cSql +=	cBISQLConcat({"ANO","MES","DIA"}) + " <= '" + aDataAte[01] 	+ aDataAte[02] 	+ aDataAte[03] 	+ "' and "	
		cSql +=	"D_E_L_E_T_ <> '*'"   
			
		If (cTipoCalc == "2")
			cSql += " ORDER BY " + cBISQLConcat({"ANO","MES","DIA"}) + " DESC "
		EndIf  
			
		dbUseArea( .T., "LOCAL", tcGenQry(,,cSql), "__TRB", .F., .T.)
		nValorAcum := FieldGet(1)
		dbCloseArea()
		dbSelectArea(cOldAlias)
	endif		
return nValorAcum
                                                                            
/*Metodo otimizado para calcular o acumulado de um indicador em um periodo*/
method calcPreviaAcum(aDataDe,aDataAte,cTipoCalc,cIndID) class TKPI015
	local nValorAcum	:= 0
	/*Recebe a expressão da fórmula*/
	Local cFormula 		:= ""    
	/*Identifica se o indicador é proprietário.*/
	Local lPrivado 	:= ::lValue("ISPRIVATE")

	default cTipoCalc	:= "0"
	default cIndID		:= ::cValue("ID")
          
 	If (lPrivado)
		/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/
	 	cFormula := KPIUnCripto(KPILimpaFormula(::cValue("FORMULA")))   
	Else  		
		/*Atribui a expressão a variável cFormula para ser utilizada no processamento.*/
	 	cFormula  := Alltrim(DwStr(::cValue("FORMULA")))  
	EndIf

	//Para efeito de melhoria de performance a soma dos acumulados e realizada via comando SQL.
	cOldAlias := alias()

	if(cTipoCalc == "0")//Soma.
		cSql :=	"select Sum(PREVIA) from SGI015B Where " 
	elseif(cTipoCalc == "1")//Media.
		cSql :=	"select Avg(PREVIA) from SGI015B Where " 
	elseif(cTipoCalc == "2")//Sem calculo do acumulado.
		cSql :=	"select PREVIA from SGI015B Where " 		
	elseif(cTipoCalc == "3")//Acumulado pela formula
		nValorAcum := ::nAcum_Formula(3, cFormula ,aDataDe,aDataAte)
	endif
	
	if ! (cTipoCalc == "3")
		cSql +=	"PARENTID = '" + cIndID + "' and "
  		cSql +=	cBISQLConcat({"ANO","MES","DIA"}) + " >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
   		cSql +=	cBISQLConcat({"ANO","MES","DIA"}) + " <= '" + aDataAte[01] 	+ aDataAte[02] 	+ aDataAte[03] 	+ "' and "	
		cSql +=	"D_E_L_E_T_ <> '*'"   
			
		If (cTipoCalc == "2")
			cSql += " ORDER BY " + cBISQLConcat({"ANO","MES","DIA"}) + " DESC "
		EndIf  
			
		dbUseArea( .T., "LOCAL", tcGenQry(,,cSql), "__TRB", .F., .T.)
		nValorAcum := FieldGet(1)
		dbCloseArea()
		dbSelectArea(cOldAlias)
	endif		
return nValorAcum

/*
	Retorna os valores verde e vermelho da meta.
*/
method aGetMetas(lAcumulado,aDataDe,aDataAte) class TKPI015
	local oPlaValor		:= ::oOwner():oGetTable("PLANILHA")         
	local aValorMeta	:= {oPlaValor:nValue("META") ,oPlaValor:nValue("META"),oPlaValor:nValue("META") }//Verde, Vermelho,Azul      
	local oParametro	:= oKpiCore:oGetTable("PARAMETRO")

	// Se não estiver respeitando os valores da planilha, carrega as informações do alvo, caso contrário
	// as informações devem vir da própria planilha.
	If !( oParametro:getValue("AVAL_META_SCORE") == "T" )
		If (::nValue("ALVO1") != 0 .and. ::nValue("ALVO2") !=0 .and. ::nValue("ALVO3") !=0 )
			If (lAcumulado .and. ::cValue("ACUM_TIPO") == "0" )//Soma)		
				nQtdOcorre 	:= ::nQtdFrequencia(aDataDe,aDataAte,::nValue("FREQ"))
				aValorMeta	:=  {::nValue("ALVO1") * nQtdOcorre, ::nValue("ALVO2") * nQtdOcorre, ::nValue("ALVO3") * nQtdOcorre }
			Else
				aValorMeta	:=  {::nValue("ALVO1"), ::nValue("ALVO2"),::nValue("ALVO3")}		
			EndIf
		EndIf
	EndIf                                                      
return aValorMeta

/*
	Metodo otimizado para calcular o acumulado de uma meta em um periodo
*/
method calcMetaAcum(aDataDe,aDataAte,cTipoCalc,lPosicionado,cMetaID) class TKPI015
	local nValorAcum 	:= 	0
	local nQtdOcorre	:= 	0//Numero de vezes que a frequencia ocorre no periodo.
	local nVlrVerde		:=	0
	local nVlrVermelho	:=	0
	local nFrequencia	:=	0
	local aPeriodoDe	:=  aDataDe
	local aPeriodoAte	:=  aDataAte		
	local cIndFormula	:=	""    
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO") 
	Local oPlaValor     := ::oOwner():oGetTable("PLANILHA")

	default cTipoCalc 	:=	"0"
    default lPosicionado:=	.t.
    default cMetaID		:=  ::cValue("ID") 

	/*
	* Quando o arquivo nao esta posicionado faz a pesquisa dos dados necessarios via query.
	* Este recurso foi usado pq a tabela pode estar filtrada.
	*/
	if(lPosicionado)
		// Se não estiver pegando os valores da planilha, atribui o valor dos alvos.
		If ! ( oParametro:getValue("AVAL_META_SCORE") == "T" )   
			nVlrVerde 		:=	::nValue("ALVO1")
			nVlrVermelho	:=	::nValue("ALVO2")  
		EndIf    
		
		nFrequencia		:=	::nValue("FREQ")
		
		If (::lValue("ISPRIVATE"))
			/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/
	 		cIndFormula  := KPIUnCripto( KPILimpaFormula(::cValue("FORMULA"))) 
   		Else  		
			/*Atribui a expressão a variável cFormula para ser utilizada no processamento.*/
	 		cIndFormula  := Alltrim(DwStr(::cValue("FORMULA")))  
   		EndIf		        	
	else    
		cOldAlias := alias()
		dbUseArea(.t.,"TOPCONN","SGI015","__TRBIND",.t.,.t.)
   	   	dbselectarea("__TRBIND")
   	   	
		if select("__TRBIND") == 0
		  	conout("NAO ESTA ABERTO") 
  	    else
	  	    dbSetIndex("SGI015I01") 
   		   	dbsetorder(1)
		  	if dbseek(cMetaID)
	  			nVlrVerde		:=	__TRBIND->ALVO1
				nVlrVermelho	:=	__TRBIND->ALVO2
				nFrequencia		:=	__TRBIND->FREQ   
				
				If (__TRBIND->ISPRIVATE == PRIVADO)
					/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/
			 		 cIndFormula  := KPIUnCripto( KPILimpaFormula(__TRBIND->FORMULA)) 
		   		Else  		
					/*Atribui a expressão a variável cFormula para ser utilizada no processamento.*/
			 		cIndFormula		:=	__TRBIND->FORMULA  
		   		EndIf
		  	endif
		  	dbclosearea()
		endif
		dbSelectArea(cOldAlias)
	endif    
		
	if(nVlrVermelho == 0 .and. nVlrVerde == 0)
		//Para efeito de melhoria de performance a soma dos acumulados e realizada via comando SQL.
		cOldAlias := alias()

		if(cTipoCalc == "0")//Soma
			cSql :=	"select Sum(META) from SGI015B Where " 
		elseif(cTipoCalc == "1")//Media
			cSql :=	"select Avg(META) from SGI015B Where " 
		elseif(cTipoCalc == "2")//Sem calculo de acumulado.
			cSql :=	"select META from SGI015B Where " 		
		elseif(cTipoCalc == "3")//Acumulado pela formula
			nValorAcum := ::nAcum_Formula(2,cIndFormula,aDataDe,aDataAte)
		endif
	
		if ! (cTipoCalc == "3")
			cSql +=	"PARENTID = '" + cMetaID + "' and "
  			cSql +=	cBISQLConcat({"ANO","MES","DIA"}) + " >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
   			cSql +=	cBISQLConcat({"ANO","MES","DIA"}) + " <= '" + aDataAte[01] 	+ aDataAte[02] 	+ aDataAte[03] 	+ "' and "	
			cSql +=	"D_E_L_E_T_ <> '*'"   
			
			If (cTipoCalc == "2")
				cSql += " ORDER BY " + cBISQLConcat({"ANO","MES","DIA"}) + " DESC "
			EndIf  
				
			dbUseArea( .T., "LOCAL", tcGenQry(,,cSql), "__TRB", .F., .T.)
			nValorAcum := FieldGet(1)
			dbCloseArea()
			dbSelectArea(cOldAlias)
		endif			
	else
		if(cTipoCalc == "0")//Soma
			If oParametro:getValue("AVAL_META_SCORE") == "T"  
				cOldAlias   := Alias()
		        cSql        := "SELECT SUM(META) FROM SGI015B WHERE PARENTID = '" + cMetaID + "' AND "
		        cSql        += cBISQLConcat({"ANO","MES","DIA"}) + " >= '" + aDataDe[01] 	+ aDataDe[02] 	+ aDataDe[03] 	+ "' and "	
    			cSql        += cBISQLConcat({"ANO","MES","DIA"}) + " <= '" + aDataAte[01] 	+ aDataAte[02] 	+ aDataAte[03] 	+ "' and "
				cSql        += "D_E_L_E_T_ <> '*'"  	
    			
    			dbUseArea( .T., "LOCAL", tcGenQry(,,cSql), "__TRB", .F., .T.)
		   		nValorAcum := FieldGet(1)
				dbCloseArea()
				dbSelectArea(cOldAlias)
			Else
				nQtdOcorre 	:= ::nQtdFrequencia(aPeriodoDe,aPeriodoAte,nFrequencia)
				nValorAcum 	:= nVlrVerde * nQtdOcorre 
			EndIf
		elseif(cTipoCalc == "1")//Media
			nValorAcum 	:= nVlrVerde
		elseif(cTipoCalc == "2")//Sem calculo de acumulado.
			nValorAcum 	:= nVlrVerde
		elseif(cTipoCalc == "3")//Sem calculo de acumulado.
			nValorAcum 	:= nVlrVerde
		endif
	endif		
return nValorAcum

//Verifica o status do indicador.
method aIndValores(oPlaValor,aValores) class TKPI015
 	local nAlvoVerd	:=	0
	local nAlvoVerm	:=	0
	local nAlvoAzul :=	0	
	local nValor	:=	0
	local nValorMeta:=	0
	local lAscend	:=	::lValue("ASCEND")
	local lMelhorF	:=	::lValue("MELHORF")
 	local nToleran	:=	::nValue("TOLERAN")
	local nSupera	:=  ::nValue("SUPERA")

	default aValores	:=	{}
		 	
 	if(len(aValores) > 0)
		nAlvoVerd	:=	aValores[1]
		nAlvoVerm	:=	aValores[2]
		nValor		:=	aValores[4]
		nValorMeta	:=	aValores[3]
		nAlvoAzul 	:=	aValores[5]
 	else
		nAlvoVerd	:=	::nValue("ALVO1")
		nAlvoVerm	:=	::nValue("ALVO2")
		nAlvoAzul 	:=	::nValue("ALVO3")
		nValor		:=	oPlaValor:nValue("VALOR")
		nValorMeta	:=	oPlaValor:nValue("META") 
 	endif
 	
	if nAlvoVerd == 0 .and. nAlvoVerm == 0 .and. nAlvoAzul == 0    
		nAlvoVerd	:=	nValorMeta		
		nAlvoVerm	:=	nValorMeta		
	
		if nToleran != 0
			If (lAscend)
				nAlvoVerm	:=	nValorMeta - ( (nToleran /100) * nValorMeta)//Quando maior melhor subtrai da meta para gerar o amarelo			
			ElseIf (lMelhorF)
				// Implementar Código
			Else
				nAlvoVerm	:=	nValorMeta + ( (nToleran /100) * nValorMeta)//Caso contrario soma a meta para gerar o amarelo.
			EndIf
		endif	
		
		If nSupera != 0
			If lAscend
				nAlvoAzul := nValorMeta * (1 + (nSupera / 100))
			ElseIf (lMelhorF)
				// Implementar Código
			Else
				nAlvoAzul := nValorMeta * (1 - (nSupera / 100))		
			EndIf
		EndIf     
	endif 	 	
return {nAlvoVerd,nAlvoVerm,nValorMeta,nValor,nAlvoAzul}

/*Metodo que verifica se a formula contém meta formula e retorna um array das meta formulas*/
method aContemMF(cFormu) class TKPI015
	local i
	local aMetaForm := {}
	
	aFormu:= aBIToken(cFormu, "|", .f.)	
	for i:=1 to len(aFormu)
		if(!empty(aFormu[i]))
			if(at("M", aFormu[i])!=0)
				aAdd(aMetaForm, aFormu[i])
			endif
		endif
	next i
return aMetaForm

method lDependInd(codIndPai, aMetaForm) class TKPI015
	local lDepende	:= .f.
	local oTabMeta	:= ::oOwner():oGetTable("METAFORMULA")
	local i      
	
	for i:=1 to len(aMetaForm)
		cCodMF := allTrim(strTran(aMetaForm[i],"M.",""))
		if(!oTabMeta:lSeek(1, {cCodMF}))
			nStatus := KPI_ST_BADID
		else 
			cFormuMF := oTabMeta:cValue("FORMULA")
			if(at("I."+codIndPai, cFormuMF)!=0)
				return .t.
			endif
		endif
	next i
return lDepende

/*
*Verifica se a data passada atraves de dia mes e ano
*e a mesma quando convertida na frequencia
*/
method lCompDataFreq(nFrequencia,dData,dDataComp) class TKPI015
	local lRet := .F.

	if year(dData) == year(dDataComp)
		do case
			case nFrequencia == KPI_FREQ_ANUAL	
				lRet	:= .T.
			case nFrequencia == KPI_FREQ_SEMESTRAL
				if month(dData) <= 6 .And. month(dDataComp) <= 6
					lRet	:= .T.			
				elseIf month(dData) >= 7 .And. month(dDataComp) >= 7 
					lRet	:= .T.
				endif
			case nFrequencia == KPI_FREQ_QUADRIMESTRAL	
				if ( month(dData) >= 1 .And. month(dData) <= 4) .And.;
				   ( month(dDataComp) >= 1 .And. month(dDataComp) <= 4) 				
							lRet := .T.
				elseif ( month(dData) >= 5 .And. month(dData) <= 8) .And.;
					   ( month(dDataComp) >= 5 .And. month(dDataComp) <= 8) 				
							lRet	:= .T.			
				elseif ( month(dData) >= 9 .And. month(dData) <= 12) .And.;
					   ( month(dDataComp) >= 9 .And. month(dDataComp) <= 12) 				
							lRet	:= .T.			
				endif
			case nFrequencia == KPI_FREQ_TRIMESTRAL	
				if ( month(dData) >= 1 .And. month(dData) <= 3) .And.;
				   ( month(dDataComp) >= 1 .And. month(dDataComp) <= 3) 				
							lRet := .T.
				elseif ( month(dData) >= 4 .And. month(dData) <= 6) .And.;
					   ( month(dDataComp) >= 4 .And. month(dDataComp) <= 6) 				
							lRet	:= .T.			
				elseif ( month(dData) >= 7 .And. month(dData) <= 9) .And.;
					   ( month(dDataComp) >= 7 .And. month(dDataComp) <= 9) 				
							lRet	:= .T.			
				elseif ( month(dData) >= 10 .And. month(dData) <= 12) .And.;
					   ( month(dDataComp) >= 10 .And. month(dDataComp) <= 12) 
							lRet	:= .T.			
				endif
			case nFrequencia == KPI_FREQ_BIMESTRAL	
				if ( month(dData) >= 1 .And. month(dData) <= 2) .And.;
				   ( month(dDataComp) >= 1 .And. month(dDataComp) <= 2) 				
							lRet := .T.
				elseif ( month(dData) >= 3  .And. month(dData) <= 4) .And.;
					   ( month(dDataComp) >= 3  .And. month(dDataComp) <= 4) 				
							lRet	:= .T.			
				elseif ( month(dData) >= 5  .And. month(dData) <= 6) .And.;
					   ( month(dDataComp) >= 5  .And. month(dDataComp) <= 6) 				
							lRet	:= .T.			
				elseif ( month(dData) >= 7  .And. month(dData) <= 8) .And.;
					   ( month(dDataComp) >= 7  .And. month(dDataComp) <= 8) 
							lRet	:= .T.			
				elseif ( month(dData) >= 9  .And. month(dData) <= 10) .And.;
					   ( month(dDataComp) >= 9  .And. month(dDataComp) <= 10) 
							lRet	:= .T.			
				elseif ( month(dData) >= 11 .And. month(dData) <= 12) .And.;
					   ( month(dDataComp) >= 11 .And. month(dDataComp) <= 12) 
							lRet	:= .T.			
				endif
			case nFrequencia == KPI_FREQ_MENSAL	
				if month(dData) == month(dDataComp) 
					lRet	:= .T.
				endif			
			case nFrequencia == KPI_FREQ_QUINZENAL
				if month(dData) ==  month(dDataComp)
					if  (day(dData) >= 1 .And. day(dDataComp) >= 1) .And.;
						(day(dData) <= 15 .And. day(dDataComp) <= 15)
							lRet := .T.
					elseif (day(dData) >= 16 .And. day(dDataComp) >= 16)
							lRet := .T.
					endif
				endif
			case nFrequencia == KPI_FREQ_SEMANAL
				if nBIWeekOfYear(dData) == nBIWeekOfYear( dDataComp )
					lRet := .T.
				endif
			case nFrequencia == KPI_FREQ_DIARIA		
				if dData == dDataComp
					lRet := .T.
				endif
		endcase
	endif
return lRet

/*
* Verifica se o indicador esta em referencia circular
*/
method checRefCircular(indID,cIndFormula) class TKPI015
	local aItemFormula	:=	{}
	local aItem			:=	{}
	/*Recebe a expressão da fórmula.*/
	local cFormula		:=	""
	local iItem			:=	0
	local cItemFormula	:=	""
	local lRet			:=	.f.
	/*Identifica se o indicador é proprietário.*/
	Local lPrivado 	:= ::lValue("ISPRIVATE")
	
	private indRef	:=	indID

	default cIndFormula:=""
	
	if(cIndFormula == "")
		If (lPrivado)
			/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/
	 		cFormula  := KPIUnCripto( KPILimpaFormula(::cValue("FORMULA")))   
		Else  		
			/*Atribui a expressão a variável cFormula para ser utilizada no processamento.*/
	 		cFormula  := Alltrim(DwStr(::cValue("FORMULA")))  
   		EndIf
	else
		cFormula	:= cIndFormula
	endif		
	
	aItemFormula:= aBIToken(cFormula, "|",.f.)

	for iItem := 1 to len(aItemFormula)
		cItemFormula := aItemFormula[iItem]
		//Verifica se e uma formula.
		if(at("I.", cItemFormula) != 0 .or. at("M.", cItemFormula) != 0)
			/*
			*Checa o item da formula para ver se esta em referencia circular.
			*/
			aItem	:= ::aChkItemFormula(alltrim(cItemFormula),indRef)

			if(len(aItem) > 0 .and. aItem[1] == IND_FORMULA)
				//Chamada para novo calculo da formula
        		lRet := iif(aItem[2] == ".T.",.t.,.f.)
				if(! lRet)
					::SavePos()	
					lRet := ::checRefCircular(indRef,aItem[2])
					::RestPos()
				endif
			endif
		endif  
		
		if(lRet)//"Referencia circular encontrada."
			exit
		endif
	next iItem
return lRet

/*
* Descrição: Checa o item da formuala.
* Caso contenha outra formula, retorna o item da formula.
* senao retorna o valor da formula.
*/			 
method aChkItemFormula(cItemFormula,indRef) class TKPI015
	local aFormula 		:= {}
	local cID			:=	""
	local oTable 		//Pose ser a tabela do indicador ou a da meta formula	
	local aItensFormula	:= {}
	/*Identifica se o indicador é proprietário.*/
	Local lPrivado 	:= .F.
	/*Recebe a expressão da fórmula.*/ 
	Local cFormula 		:= ""

	//Verifica o tipo da formula.
	if(at("I", cItemFormula) != 0)
		cID			:=	strTran(cItemFormula, "I.", "")
		oTable 		:=	::oOwner():oGetTable("INDICADOR")
		lPrivado 	:=  oTable:lValue("ISPRIVATE")
	elseif(at("M", cItemFormula) != 0)
		cID			:=	strTran(cItemFormula, "M.", "")
		oTable 		:= ::oOwner():oGetTable("METAFORMULA")
	else
		return
	endif
              
 	If (lPrivado)
		/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/
	 	cFormula  := KPIUnCripto( KPILimpaFormula(oTable:cValue("FORMULA")) )  
	Else  		
		/*Atribui a expressão a variável cFormula para ser utilizada no processamento.*/
	 	cFormula  := Alltrim(DwStr(oTable:cValue("FORMULA")))  
	EndIf

	if(oTable:lSeek(1,{cID}) .and. ! empty(cFormula))
		//Se for igual a zero nao esta em referencia circular
		aItensFormula:= aBIToken(cFormula, "|", .f.)	

		if(	ascan(aItensFormula, { |x|  x   == indRef}) == 0)
			aadd(aFormula, IND_FORMULA)
			aadd(aFormula, cFormula)
		else
			aadd(aFormula, IND_FORMULA)
			aadd(aFormula, ".T.")
		endif
	endif
return aFormula

method lComparaFormulas(formulaA,formulaB) class TKPI015
	local lCompFormula	:= .t.
	local aformulaA		:= aBIToken(alltrim(formulaA), "|")
	local aformulaB		:= aBIToken(alltrim(formulaB), "|")
	local nPosicao
	
	if(len(aformulaA) != len(aformulaB))
		return .f.
	endif
	
    for nPosicao := 1 to len(aformulaA)
    	if!( alltrim(aformulaA[nPosicao]) == alltrim(aformulaB[nPosicao]) )
    		return .f.
    	endif
    next i
return lCompFormula

method cRetFormula(cFormula) class TKPI015
	local cFormuCompl := "", aItemFormula := "", iItem, cIdItem := "", cNomeItem := ""
	local oMetaFormula
	local oScorecard
	local oKpiCore	:= ::oOwner()
	
	oMetaFormuça	:= oKPICore:oGetTable("METAFORMULA")
	oScorecard		:= oKPICore:oGetTable("SCORECARD")

	::savePos()
	::cSQLFilter("")
	oMetaFormula:savePos()
	oScorecard:savePos()
	oScorecard:cSQLFilter("")
	aItemFormula:= aBIToken(alltrim(cFormula), "|",.f.)
	for iItem := 1 to len(aItemFormula)
		cNomeItem := ""
		cItemFormula := aItemFormula[iItem]
		//Verifica se e uma formula.
		if(at("I.", cItemFormula) != 0)
			cIdItem := alltrim(strTran(cItemFormula, "I.", ""))
			if(::lSeek(1, {cIdItem}))
				if(oScorecard:lSeek(1, {::cValue("ID_SCOREC")}))
					cNomeItem := alltrim(oScorecard:cValue("NOME")) + ">" + alltrim(::cValue("NOME"))
				endif
			endif
			cFormuCompl := cFormuCompl + cNomeItem
		elseif(at("M.", cItemFormula) != 0)
			cIdItem := strTran(cItemFormula, "M.", "")
			if(oMetaFormula:lSeek(1, {cIdItem}))
				cNomeItem := alltrim(oMetaFormula:cValue("NOME"))
			endif
			cFormuCompl := cFormuCompl + cNomeItem
		else
			cFormuCompl := cFormuCompl + cItemFormula
		endif
	next iItem

	::restPos()
	oMetaFormula:restPos()
	oScorecard:restPos()
return cFormuCompl

method nCalcPorcentagem(lAscend, nValor, nMeta, lMelhorFaixa) class TKPI015
	local nPorcentagem
	local nDeslocamento := 100
	local nValorAcum	:= nValor		+ nDeslocamento
	local nMetaAcum		:= nMeta		+ nDeslocamento
	local nDiferenca	:= nMetaAcum 	- nValorAcum
	local nFormula		:= iif(nMeta == 1,nDiferenca/nMeta,(nDiferenca*100)/nMeta)
	local nFormulaZero	:= (nDiferenca*100)/nMetaAcum
	
	If lAscend
		If (nMeta != 0)
			//Valor positivo e meta positiva
			If (nValor >= 0 .and. nMeta > 0)
				nPorcentagem := 100 - nFormula
			//Valor negativo e meta positiva
			ElseIf (nValor <= 0 .and. nMeta > 0)
				nPorcentagem := (nFormula * -1) + 100
			//Valor positivo e meta negativa
			ElseIf (nValor >= 0 .and. nMeta < 0)
				nPorcentagem := nFormula + 100
			//Valor negativo e meta negativa
			ElseIf (nValor <= 0 .and. nMeta < 0)
				If (nValor > nMeta)
					nPorcentagem := 100 + nFormula
				Else
					nPorcentagem := 100 - nFormula * -1
				EndIf
			EndIf
		Else
			If (nValor >= 0)
				nPorcentagem := (nFormulaZero * -1) + 100
			Else
				nPorcentagem := 100 - nFormulaZero
			EndIf
		EndIf 
	ElseIf lMelhorFaixa   
		// Implementar Código 
	Else
		If (nMeta != 0)
			//Valor positivo e meta positiva
			If (nValor >= 0 .and. nMeta > 0)
				nPorcentagem := 100 + nFormula
			//Valor negativo e meta positiva
			ElseIf (nValor <= 0 .and. nMeta > 0)
				nPorcentagem := 100 + nFormula
			//Valor positivo e meta negativa
			ElseIf (nValor >= 0 .and. nMeta < 0)
				nPorcentagem := 100 + nFormula
			//Valor negativo e meta negativa
			ElseIf (nValor <= 0 .and. nMeta < 0)
				nPorcentagem := 100 - nFormula
			EndIf
		Else
			nPorcentagem := 100 + nFormulaZero
		EndIf
	EndIf   
Return nPorcentagem


/*
*Faz o calculo do valor acumulado usando a formula.
*/
method nAcum_Formula(nTipoCalc,cItemFormula,aDataDe,aDataAte) class TKPI015
	local oMetaFormula	:= ::oOwner():oGetTable("METAFORMULA")
   	local aFormula  	:= 	aBIToken(cItemFormula, "|", .f.)
	local nValor		:=	0
	local nNumInd		:= 	""   	
	local cItemFormula	:=	""
	local cFormula		:=	""
	local cCodInd		:=	""
	local cCodMeta		:=	""
    
	if len(aFormula) > 0
		for nNumInd = 1 to len(aFormula)
			cItemFormula := aFormula[nNumInd]
			if(Rat("I.", cItemFormula)>0)//Se for indicador
				cCodInd := right(cItemFormula,len(cItemFormula)-2)
	
				if(nTipoCalc==1)
	            	cItemFormula := "(" + cBIStr(::calcIndAcum(aDataDe,aDataAte,"0",cCodInd)) + ")"
				elseif(nTipoCalc==3)
	            	cItemFormula := "(" + cBIStr(::calcPreviaAcum(aDataDe,aDataAte,"0",cCodInd)) + ")"	            	
				else
	            	cItemFormula := "(" + cBIStr(::calcMetaAcum(aDataDe,aDataAte,"0",.f.,cCodInd)) + ")"
				endif	            	
			elseif(Rat("M.", cItemFormula)>0)//Se for meta formula
				cCodMeta := right(cItemFormula,len(cItemFormula)-2)
				if(oMetaFormula:lSeek(1, {cCodMeta}))
	            	cItemFormula := "(" + cBIStr(::nAcum_Formula(nTipoCalc,oMetaFormula:cValue("FORMULA"),aDataDe,aDataAte)) + ")"
				endif						
			endif
			cFormula += cItemFormula
		next nNumInd
		nValor := &cFormula
	else
		nValor := 0
	endif		
return nValor

method cGetAcumName(nAcuTipo) class TKPI015
	local cTipoAcumulado := ""
	
	do case
		case nAcuTipo = 0
			cTipoAcumulado := STR0034//"Soma"		
		case nAcuTipo = 1
			cTipoAcumulado := STR0035//"Média"		
		case nAcuTipo = 2           
			cTipoAcumulado := STR0036//"Último valor"		
		case nAcuTipo = 3
			cTipoAcumulado := STR0037//"Usando a fórmula"
	endcase
return cTipoAcumulado := ""

//Verifica se ja existe algun código do cliente cadastrado 
//Caso exista retorna a mensagem de erro
method cFindCodClieDup(cCodID,cCodClie) class TKPI015
	local oScorecard 	:= nil  
	local aSaveArea		:= {}
	local cRet 			:= ""
	
	if len(alltrim(cCodClie)) > 0
		aSaveArea	:=	{IndexOrd(), recno(), ::cSqlFilter()}
		::cSQLFilter("ID<>'"+cCodID+"' AND ID_CODCLI='"+cCodClie+"'") 
		::lFiltered(.t.)
		::_First()
	        
		//Verifica se existe cod duplicado
		if(!::lEof())
			//Montando a mensagem de erro    
			oScorecard := ::oOwner():oGetTable("SCORECARD")
			if oScorecard:lSeek(1, { ::cValue("ID_SCOREC") })
			    cRet := "<html>" +;
			    		STR0044 + "<br>" + ;	//"O Cód. de Importação informado já foi cadastrado no:"
						STR0001 + ": " + alltrim(::cValue("NOME")) + CRLF + "<br>" +; 	//"Indicador: "
				 		::oOwner():getStrCustom():getStrSco() + ": " + alltrim(oScorecard:cValue("NOME")) +; //"Departamento: " 
				 		"<br>&nbsp;</html>"
			endif
		endif
		::cSQLFilter("")	
		::faSavePos:= aSaveArea
		::RestPos()
	endif		
return cRet


//Retorna a quantidade de registros pai
method nCountRoot(nAcuTipo) class TKPI015
	local cSql 		:= "select count(ID) from SGI015 where D_E_L_E_T_ <> '*' and ID_INDICA = '0'"
	local cOldAlias := alias()
	local nCount	:= 0
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nCount := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)
return nCount	        

//Calcula a variação
method nGetVar(lVarPer,nReal,nMeta) class TKPI015
	Local nRet		:= 0
	Local lAscend	:= ::lValue("ASCEND")
	Local lMelhorF	:= ::lValue("MELHORF")

	If(lVarPer)
		If nMeta <> 0
			If lAscend
				// Cálculo para Quanto Maior melhor.
				nRet := (nReal * 100) / nMeta
			ElseIf (lMelhorF)
				// Implementar Código
			Else
				// Cálculo para Quanto Menor melhor.
				nRet := (nMeta * 100 ) / nReal
			EndIf
		EndIf
	Else
		nRet := (nReal - nMeta)
	EndIf
return nRet


//Retorna o pecentual de tolerância
//OBS:Indicador deve estar posicionado
method nGetTolPercent() class TKPI015
	local nRet 			:= 0                                     
	local nAlvo1		:= ::nValue("ALVO1")
	local nAlvo2		:= ::nValue("ALVO2")
	local nToleran		:= ::nValue("TOLERAN")
	local lAscend	 	:= ::lValue("ASCEND")   
	local lMelhorF  	:= ::lValue("MELHORF") 

	if (nAlvo1 != 0 .or. nAlvo2 != 0) .and. (nAlvo1 != nAlvo2)
		If (lAscend)
			nRet := ((nAlvo1-nAlvo2)*100)/nAlvo1                
		ElseIf (lMelhorF)
			nRet := nToleran		
		Else
			nRet := ((nAlvo2-nAlvo1)*100)/nAlvo2
		EndIf
	else
		nRet := nToleran
	endif 
return nRet   

//Retorna o valor maximo de tolerancia
method nGetTolValor( nMeta , lAscend ) class TKPI015
	local nRet     := 0
	local nToleran := ::nValue("TOLERAN")            
	
	If nToleran == 0
		nRet := 0
	Else
		If (lAscend)
			nRet := nMeta - ( nMeta * ( nToleran / 100 ) )	  
		Else
			nRet := nMeta + ( nMeta * ( nToleran / 100 ) )	  
		EndIf
	EndIf
return nRet	
                                      
//Retorna o valor maximo de superação
method nGetSupValor( nMeta , lAscend ) class TKPI015
	local nRet          := 0
	local nSupera		:= ::nValue("SUPERA")            
	
	If nSupera == 0
		nRet := 0
	Else    
		If (lAscend)
			nRet := nMeta + ( nMeta * ( nSupera / 100 ) )	
		Else
			nRet := nMeta - ( nMeta * ( nSupera / 100 ) )	
		EndIf
	EndIf
return nRet	

//Retorna o pecentual de supera
//OBS:Indicador deve estar posicionado
Method nGetSupPercent() Class TKPI015
	Local nRet 		:= 0                                     
	Local nAlvo1	:= ::nValue("ALVO1")
	Local nAlvo3	:= ::nValue("ALVO3")
	Local nSupera	:= ::nValue("SUPERA")
	Local lAscend	:= ::lValue("ASCEND")
	local lMelhorF  	:= ::lValue("MELHORF") 
   
	If (nAlvo1 != 0 .Or. nAlvo3 != 0) .And. (nAlvo1 != nAlvo3)
		If (lAscend)
			nRet := ((nAlvo3*100)/nAlvo1)-100   
		Elseif lMelhorF
			nRet := nSupera		
		Else
			nRet := 100-((nAlvo3*100)/nAlvo1)
		EndIf
	Else
		nRet := nSupera
	EndIf	     
Return nRet   


/*-------------------------------------------------------------------------------------
Adiciona os dados do indicador ao no xml requisitado
@param aDataAnalise - Data de analise do indicador.
@return 			- XML para com os dados do indicador.
--------------------------------------------------------------------------------------*/
method oAddIndItem(aDataAnalise,isScoOwner,cUserID) class TKPI015
	local oNodeInd			:= TBIXMLNode():New("PLANILHA")
	local oPlaValor			:= ::oOwner():oGetTable("PLANILHA")
	local oUnidade			:= ::oOwner():oGetTable("UNIDADE")
	local oSysProp			:= ::oOwner():oGetTable("PARAMETRO")
	local oNota				:= ::oOwner():oGetTable("NOTA") 
	local oAnalitico		:= ::oOwner():oGetTable("ANALITICO")  
	local aValores			:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY, 0}
	local cIndEst			:= ""
	local cMask				:= "@E 999,999,999,999"
	local cIdUnidade		:= ""
	local cIndID			:= ::cValue("ID")
	local nImgAcao			:= KPI_IMG_VAZIO
	local nValor 			:= 0
	local nMeta				:= 0
	local nPrevia 			:= 0
	local sVar				:= 0
	local nVarPerc			:= 0
	local nVarDecm			:= 0
	local dAcaoDe			:= aDataAnalise[ANALISE_ALVODE]
	local nVarDecimal		:= 2 
	
	//Numero de casas decimais
	nVarDecimal  := val(oSysProp:getValue("DECIMALVAR"))
	
	if nVarDecimal > 0
		cMask += "." + replicate("9",nVarDecimal)
	endif
	
	//Se estiver montando a coluna para o primeiro periodo verifica o status.
	aValores 	:= ::aGetIndValores(aDataAnalise[ANALISE_ALVODE],aDataAnalise[ANALISE_ACUMDE],aDataAnalise[ANALISE_ACUMATE])
	
	//Verifica se existe um plano de acao para este indicador.
	if(oSysProp:lSeek(1,{"NUM_DIA_PRO_FIN"}))
		dAcaoDe	:= dAcaoDe - oSysProp:nValue("DADO")
	else
		dAcaoDe	:= dAcaoDe - 90
	endif
	
	oNodeInd:oAddChild(TBIXMLNode():New("PESO"		, alltrim(::cValue("PESO"))))
	
	oNodeInd:oAddChild(TBIXMLNode():New("ORDEM"		, alltrim(::cValue("ORDEM"))))
	
	oNodeInd:oAddChild(TBIXMLNode():New("GRAPH_UP"	, ::cValue("GRAPH_UP")))
	
	oNodeInd:oAddChild(TBIXMLNode():New("GRAPH_DO"	, ::cValue("GRAPH_DO")))
	
	oNodeInd:oAddChild(TBIXMLNode():New("ASCEND"	, ::lValue("ASCEND")))
	
	oNodeInd:oAddChild(TBIXMLNode():New("MELHORF"	, ::lValue("MELHORF")))
	
	oNodeInd:oAddChild(TBIXMLNode():New("TOLERAN"	, ::nGetTolPercent()))   
	
	oNodeInd:oAddChild(TBIXMLNode():New("SUPERA"	, ::nGetSupPercent()))
	  
	oNodeInd:oAddChild(TBIXMLNode():New("NOTA"		, oNota:nImagemNota(::cValue("ID"))))
	
	nImgAcao := ::nHasUserAcao(cIndID,cUserID,isScoOwner,dAcaoDe)
	
	if aValores[VAL_REAL_STATUS] == STATUS_RED .and. nImgAcao == KPI_IMG_VAZIO
		nImgAcao := KPI_IMG_EXCLAMACAO
	endif
	
	oNodeInd:oAddChild(TBIXMLNode():New("ACAO",nImgAcao))           
	
   	//Unidade de Medida do Indicador. 
	cIdUnidade := ::cValue("UNIDADE")
	if(oUnidade:lSeek(1, {cIdUnidade}))
		oNodeInd:oAddChild(TBIXMLNode():New("UNIDADE", alltrim(oUnidade:cValue("NOME"))))
	else
		oNodeInd:oAddChild(TBIXMLNode():New("UNIDADE", ""))
	endif
	
    //Frequência do Indicador. 
	oNodeInd:oAddChild(TBIXMLNode():New("FREQNOME", ::cGetPeriodo(::nValue("FREQ"),aDataAnalise[ANALISE_ALVODE])))
	//Descricao do indicador
	oNodeInd:oAddChild(TBIXMLNode():New("INDICADOR", alltrim(::cValue("NOME"))))
	//Link Customizado
	oNodeInd:oAddChild(TBIXMLNode():New("LINK", AllTrim( ::cValue( "LINK" ) ) ) )
	
	nValor		:=	aValores[VAL_REAL]
	nMeta		:=	aValores[VAL_META]
	nPrevia 	:=	aValores[VAL_PREVIA]
	
	//Preenchendo as colunas de valor. As colunas de valor podem variar conforme a quantidade de periodos(meses)
	if(oSysProp:getValue("VALOR_PREVIO") == "T")
		oNodeInd:oAddChild(TBIXMLNode():New("PREVIA",nPrevia))
	endif
	
	//Coluna de valor
	oNodeInd:oAddChild(TBIXMLNode():New("VALOR",nValor))
	//Coluna de Meta
	oNodeInd:oAddChild(TBIXMLNode():New("META",nMeta))
	
	//Coluna de Variacao
	nVarPerc		:= ::nGetVar(.T.,nValor,nMeta)
	nVarDecm		:= ::nGetVar(.F.,nValor,nMeta)
	
	if oSysProp:getValue("SHOWVARCOL") == "T"
		sVar 		= alltrim(transform(nVarPerc, cMask)) + " %"
		sVarHint	= "<html><table><tr><td align='center'>"
		sVarHint	+= "Variação"
		sVarHint	+= "<br/>"
		sVarHint	+= alltrim(transform(nVarDecm, cMask))
		sVarHint	+= "</td></tr></table></html>"
	else
		sVar 		= alltrim(transform(nVarDecm, cMask))
		sVarHint	= "<html><table><tr><td align='center'>"
		sVarHint	+= "Percentual Atingido"
		sVarHint	+= "<br/>"
		sVarHint	+= alltrim(transform(nVarPerc, cMask)) + " %"
		sVarHint	+= "</td></tr></table></html>"
	endif
	oNodeInd:oAddChild(TBIXMLNode():New("VARIACAO",sVar))    
	oNodeInd:oAddChild(TBIXMLNode():New("VARIACAO_PERC",nVarPerc))    	
	oNodeInd:oAddChild(TBIXMLNode():New("VAR_HINT",sVarHint))
	oNodeInd:oAddChild(TBIXMLNode():New("STATUS", aValores[VAL_REAL_STATUS])) //Verificao status do indicador
	
	oNodeInd:oAddChild(TBIXMLNode():New("STATUS_DATAALVO", aValores[VAL_REAL_STATUS]))//Verificao status do indicador
	
	if(::lValue("IND_ESTRAT"))
		oNodeInd:oAddChild(TBIXMLNode():New("TENDENCIA",KPI_IMG_VAZIO))
	else
		oNodeInd:oAddChild(TBIXMLNode():New("TENDENCIA",::nIndTendencia(oPlaValor,aValores[VAL_REAL_STATUS],::lValue("ASCEND"),::lValue("MELHORF"))))
	endif

	//Totalizacao do valor do indicador
	oNodeInd:oAddChild(TBIXMLNode():New("ACUMULADO_PERIDO",aValores[VAL_REAL_ACU]))
	
	//Totalizacao do valor da meta.*/
	oNodeInd:oAddChild(TBIXMLNode():New("ACUMULADO_META",aValores[VAL_META_ACU]))
	
	//Variacao da totalizacao
	nVarPerc		:= round(::nGetVar(.T.,aValores[VAL_REAL_ACU],aValores[VAL_META_ACU]), nVarDecimal )
	nVarDecm		:= round(::nGetVar(.F.,aValores[VAL_REAL_ACU],aValores[VAL_META_ACU]), nVarDecimal )
	if oSysProp:getValue("SHOWVARCOL") == "T"
		sVar 		= alltrim(transform(nVarPerc, cMask)) + " %"
		sVarHint	= "<html><table><tr><td align='center'>"
		sVarHint	+= "Variação"
		sVarHint	+= "<br/>"
		sVarHint	+= alltrim(transform(nVarDecm, cMask))
		sVarHint	+= "</td></tr></table></html>"
	else
		sVar 		= alltrim(transform(nVarDecm, cMask))
		sVarHint	= "<html><table><tr><td align='center'>"
		sVarHint	+= "Percentual Atingido"
		sVarHint	+= "<br/>"
		sVarHint	+= alltrim(transform(nVarPerc, cMask)) + " %"
		sVarHint	+= "</td></tr></table></html>"
	endif
	oNodeInd:oAddChild(TBIXMLNode():New("VARIA_ACUMULADA",sVar))
	oNodeInd:oAddChild(TBIXMLNode():New("VARIA_ACUMUHINT",sVarHint))
	oNodeInd:oAddChild(TBIXMLNode():New("STATUS_ACU",aValores[VAL_ACUM_STATUS]))
	
	//Recupera o número de casas decimais para formatação de valores.
	oNodeInd:oAddChild(TBIXMLNode():New("ID",cIndID))
	oNodeInd:oAddChild(TBIXMLNode():New("DECIMAIS",::nValue("DECIMAIS")))
	
	//Indica se o indicador é estratégico.
	cIndEst	:= ::cValue("IND_ESTRAT")
	oNodeInd:oAddChild(TBIXMLNode():New("IND_ESTRAT",cIndEst))
	
	if(cIndEst == "T" )
		oNodeInd:oAddChild(TBIXMLNode():New("DESCRICAO",::cValue("DESCRICAO")))
	endif
	
	//Indica se o indicador é consolidador.
	oNodeInd:oAddChild(TBIXMLNode():New("ISCONSOLID", ::cValue("ISCONSOLID")))
	
	//Indica se existem dados analíticos para o indicador.  
	oNodeInd:oAddChild(TBIXMLNode():New("ANALITICO", oAnalitico:lAnalitico(::cValue("ID"), aDataAnalise[ANALISE_ALVODE])))
	
	//Verifica de existem outros indicadores para fazer o drill.
	cOldAlias := alias()
	cSql :=	"select ID_INDICA from SGI015 Where "
	cSql +=	"ID_INDICA 	= '" + cIndID + "' and "
	cSql +=	"VISIVEL 	= 'T' and "
	cSql +=	"D_E_L_E_T_ != '*'"
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	
	if ! eof()
		oNodeInd:oAddChild(TBIXMLNode():New("DRILL",.t.))
	else
		oNodeInd:oAddChild(TBIXMLNode():New("DRILL",.f.))
	endif
	
	dbCloseArea()
	dbSelectArea(cOldAlias)
return oNodeInd

/*---------------------------------------------
Retorna o numero indentificando se o usario tem acesso ao plano de acao do indicador.
@param (Caracter)cIndID
@param (Caracter)cUserID
@param (Lógico)isScoOwner
@param (Data) dDataDe
@return (Númerico)Status do indicador.
-----------------------------------------------*/
method nHasUserAcao(cIndID,cUserID,isScoOwner,dDataDe) class TKPI015
	local nAcesso	:=	KPI_IMG_VAZIO
	local oPlanoAcao:=	::oOwner():oGetTable("PLANOACAO")
	
	if(oPlanoAcao:lSoftSeek(2,{cIndID}))
		while( ! oPlanoAcao:lEof() .and. oPlanoAcao:cValue("ID_IND") == cIndID )
			if(isScoOwner)
				nAcesso := KPI_IMG_PLANOACAO
			else
				if(oPlanoAcao:lUsuResp(cUserID))
					nAcesso := KPI_IMG_PLANOACAO
				endif
			endif

			//Verifica esta no intervalo de data para mostrar.			
			if(nAcesso == KPI_IMG_PLANOACAO .and.;
				((oPlanoAcao:nValue("STATUS") != 6 .and. oPlanoAcao:nValue("STATUS") != 3) .or.;
				(oPlanoAcao:dValue("DATAFIM") >= dDataDe .and. oPlanoAcao:dValue("DATAFIM") <= date() )))
				exit
			else
				nAcesso	:=	KPI_IMG_VAZIO
			endif            
			oPlanoAcao:_Next()		
		end while
	endif 
return nAcesso 

/**   
Método recursivo para recuperação de todos os filhos de um indicador.
@param cIDIndicador ID do indicador pai.   
@param aFilhos 
@return 
*/
Method aFilhos( cIDIndicador, aFilhos ) Class TKPI015
	Local aSaveArea 	:= ::SavePos()	
	
	Default aFilhos	:= {}

	::cSQLFilter("ID_INDICA = '" + Padr( cIDIndicador, 10 ) + "'") 
	::lFiltered(.T.)
	::_First()

	While( ! ::lEof() ) 
		aAdd(aFilhos, ::cValue("ID") ) 
		::aFilhos( ::cValue("ID"),  aFilhos )
		::_Next()
	EndDo

	::cSQLFilter("") 
	::RestPos( aSaveArea )	
Return aFilhos


Function kpi015()
Return .T.                         

/**
  Metodo para verificar se o usuario logado e reponsavel pelo indicador ou pela coleta
  @param cUser		- ID do usuario.
  @param cTipoResp	- Tipo do Responsavel (Indicador / Coleta)
  @retur boolean
*/
Method isResp(cUser, cTipoResp) Class TKPI015
	Local lRet		:= .F.
	Local aUsuarios	:= {}
	Local oGrpXUser
	Local cField	:= "ID_RESP"
	
	If cTipoResp == RESP_COL
		cField := "ID_RESPCOL"
	EndIf

	If (::cValue(cTipoResp) == TIPO_USUARIO)
		If (cUser == ::cValue(cField))
			lRet := .T.
		EndIf
	Else//TIPO_GRUPO
		oGrpXUser := ::oOwner():oGetTable("GRPUSUARIO")
		aUsuarios := oGrpXUser:aUsersByGroup(::cValue(cField))

		If aScan(aUsuarios,{|x| x == cUser}) > 0
			lRet := .T.			
		EndIf
	EndIf
Return lRet              

method cNomePeriodo(nFrequencia) class TKPI015
	local cRet
	
	do case
		case nFrequencia == KPI_FREQ_ANUAL
			cRet := STR0004 //Anual
		case nFrequencia == KPI_FREQ_SEMESTRAL
			cRet := STR0005 //Semestral
		case nFrequencia == KPI_FREQ_QUADRIMESTRAL
			cRet := STR0006 //Quadrimestral
		case nFrequencia == KPI_FREQ_TRIMESTRAL
			cRet := STR0007 //Trimestral
		case nFrequencia == KPI_FREQ_BIMESTRAL
			cRet := STR0008 //Bimestral
		case nFrequencia == KPI_FREQ_MENSAL
			cRet := STR0009 //Mensal
		case nFrequencia == KPI_FREQ_QUINZENAL
			cRet := STR0010 //Quinzenal
		case nFrequencia == KPI_FREQ_SEMANAL
			cRet := STR0011 //Semanal
		case nFrequencia == KPI_FREQ_DIARIA
			cRet := STR0012 //Diaria
	endcase
return cRet

method nGetFxStatus(aVlrInd) class TKPI015
	local nStatus 	  := ESTAVEL_GRAY
	local nValorMeta  := aVlrInd[3]
	local nValor	  := aVlrInd[4]	
 	local nToleran    := ::nValue("TOLERAN")
	local nSupera	  := ::nValue("SUPERA")	  
	local aValorTol   := {}
	local aValorSup   := {}   
		
	aValorTol := ::aGetTolFaixa( nValorMeta, nToleran )	
   	aValorSup := ::aGetSupFaixa( nValorMeta, nSupera  )
   		
	If (nValor <= aValorTol[1] .AND. nValor >= aValorTol[2] )
		nStatus := STATUS_GREEN
	ElseIf (nValor > aValorTol[1] .AND. nValor <= aValorSup[1]) .OR. ;
		   (nValor < aValorTol[2] .AND. nValor >= aValorSup[2])
		nStatus := STATUS_YELLOW
	Else
		nStatus := STATUS_RED
	EndIf		
return nStatus  

method aGetTolFaixa(nMeta, nTolera) class TKPI015
	local aRetorno := {}
	local nValorA  := 0
	local nValorB  := 0
	
	nValorA  := nMeta + ( nMeta * ( nTolera / 100 ) )
	nValorB  := nMeta - ( nMeta * ( nTolera / 100 ) )
	aRetorno := { nValorA , nValorB }
return aRetorno     

method aGetSupFaixa( nMeta, nSupera ) class TKPI015
	local aRetorno := {}
	local nValorA  := 0
	local nValorB  := 0
	
	nValorA  := nMeta + ( nMeta * ( nSupera / 100 ) )
	nValorB  := nMeta - ( nMeta * ( nSupera / 100 ) )
	aRetorno := { nValorA , nValorB }
return aRetorno 