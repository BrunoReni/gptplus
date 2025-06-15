/* ######################################################################################
// Projeto: KPI
// Modulo : Indicador
// Fonte  : KpiIndicadorFormula
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 11.11.08 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"

/*--------------------------------------------------------------------------------------
@entity Exibição de fórmulas de indicadores
--------------------------------------------------------------------------------------*/

//Constante para o array os valores calculados para indicadores
#define VAL_REAL			1
#define VAL_META			2
#define VAL_REAL_ACU		3
#define VAL_META_ACU		4
#define VAL_REAL_STATUS		5
#define VAL_ACUM_STATUS		6
#define VAL_PREVIA			7

//Constante para o array os valores calculados para metafórmulas
#define AC_VALOR	1
#define AC_META		2
#define AC_PREVIA	3

Class TKPIIndicadorFormula from TBITable
	method New() constructor
	method NewIndicadorFormula()
	method oToXMLNode(cID,cRequest)
	method oIndicFormulaToXMLNode(cID, oXmlNode) 
EndClass

method New() class TKPIIndicadorFormula
	::NewIndicadorFormula()
return

method NewIndicadorFormula() class TKPIIndicadorFormula
return

method oToXMLNode(cID,cRequest) class TKPIIndicadorFormula
	Local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	Local aRequest 		:= DwToken(cRequest, "|")
	Local oXML     		:= Nil
	Local oXMLAttrib	:= Nil
	Local nDecimals		:= 2
	
	oXML := TBIXmlNode():New("INDICADOR_FORMULA")
	oXML := ::oIndicFormulaToXMLNode(cID, oXML, aRequest[1], aRequest[2], aRequest[3])
	
	oXMLAttrib := TBIXmlAttrib():New() 
	
	if(oParametro:lSeek(1, {"DECIMALVAR"}))
		nDecimals := oParametro:nValue("DADO")
	endif
	
	oXMLAttrib:lSet("PERCENTDEC", nDecimals)
	oXML:oAttrib(oXMLAttrib)
return oXML

method oIndicFormulaToXMLNode(cID, oXmlNode, cDtAlvo, cDtDe, cDtAte, cSuffix) class TKPIIndicadorFormula
	Local oIndicador 	:= ::oOwner():oGetTable("INDICADOR")
	Local oScoreCard 	:= ::oOwner():oGetTable("SCORECARD")
	Local oMetaFormula	:= ::oOwner():oGetTable("METAFORMULA")
	Local oCalcMetaForm := ::oOwner():oGetTable("CALC_INDICADOR")
	Local oPlanilha		:= ::oOwner():oGetTable("PLANILHA")
	Local oIndicXmlNode
	Local oXmlAttrib
	Local oFormula
	Local nItemFormulas
	Local nInd
	Local oIndMetaForm
	Local aValores
	Local aAux
	Local nMetaID
	Local nVlrReal := nVlrMeta := nVlrAcReal := nVlrAcMeta := nVlrRealStatus := nVlrAcStatus := nVlrPrevia := 0
	Local lPrivado
	Local cFormula
	
	Default cSuffix		:= ""
	
	If oIndicador:lSeek(1, { cID })   
		cSuffix 	+= cID
		oXmlAttrib 	:= TBIXmlAttrib():New()
		oXmlAttrib	:lSet("ID", allTrim(oIndicador:cValue("ID")))
		lPrivado 	:= oIndicador:lValue("ISPRIVATE")	  

		If oScoreCard:lSeek(1,{oIndicador:cValue("ID_SCOREC")})
			oXmlAttrib:lSet("DEPARTAMENTO", allTrim(oScoreCard:cValue("NOME")))
			oXmlAttrib:lSet("NOME", allTrim(oIndicador:cValue("NOME"))) 
			oXmlAttrib:lSet("CODIGO", allTrim(oIndicador:cValue("ID_CODCLI")))
		Else
			oXmlAttrib:lSet("DEPARTAMENTO", "-")
			oXmlAttrib:lSet("NOME", allTrim(oIndicador:cValue("NOME")))
			oXmlAttrib:lSet("CODIGO", allTrim(oIndicador:cValue("ID_CODCLI")))
		EndIf
		
		If (lPrivado) .And. !(Vazio(KPILimpaFormula(oIndicador:cValue("FORMULA"))))
			oXmlAttrib:lSet("FORMULA", AllTrim(oIndicador:cValue("DESCFORMU")) )
	   		cFormula  := KPIUnCripto( KPILimpaFormula(oIndicador:cValue("FORMULA") ) )  
		Else  		
			oXmlAttrib:lSet("FORMULA", allTrim(oIndicador:cRetFormula(oIndicador:cValue("FORMULA"))))  
	  		cFormula  := oIndicador:cValue("FORMULA")  
	    EndIf	

		if(oPlanilha:lDateSeek(cID, cToD(cDtAlvo), oIndicador:nValue("FREQ")))
	   		aValores := oIndicador:aGetIndValores(cDtAlvo, cDtDe, cDtAte)
		else
			aValores	:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}
		endif				
		
		oXmlAttrib:lSet("VALOR_REAL"		, aValores[VAL_REAL])
		oXmlAttrib:lSet("VALOR_META"		, aValores[VAL_META])
		oXmlAttrib:lSet("VALOR_PREVIA"		, aValores[VAL_PREVIA])
		oXmlAttrib:lSet("VALOR_REAL_ACUM"	, aValores[VAL_REAL_ACU])
		oXmlAttrib:lSet("VALOR_META_ACUM"	, aValores[VAL_META_ACU])
		oXmlAttrib:lSet("VALOR_REAL_STATUS"	, aValores[VAL_REAL_STATUS])
		oXmlAttrib:lSet("VALOR_ACUM_STATUS"	, aValores[VAL_ACUM_STATUS])

		if(oIndicador:lValue("IND_ESTRAT"))
			oXmlAttrib:lSet("TENDENCIA", KPI_IMG_VAZIO)
		else
			oXmlAttrib:lSet("TENDENCIA", oIndicador:nIndTendencia(oPlanilha, aValores[VAL_REAL_STATUS], oIndicador:lValue("ASCEND")))
		endif
		
		oFormula 		:=	oIndicador:oFormulaToXML(cFormula)
		nItemFormulas 	:= oFormula:nChildCount("ITEMFORMULA")
		
		If ( nItemFormulas > 0 )
			oXmlAttrib:lSet("TIPO", "IND_FORMULA")
		Else
			oXmlAttrib:lSet("TIPO", "INDICADORES")
		EndIf
		
		oIndicXmlNode := TBIXmlNode():New("INDICADOR"+cSuffix, "", oXmlAttrib)
		
		If nItemFormulas > 0
			For nInd := 1 to nItemFormulas
				oItemInd := oFormula:oChildByPos(nInd)
				::oIndicFormulaToXMLNode( oItemInd:oChildByName("INDICA_ID"):cGetValue("VALUE"), oIndicXmlNode, cDtAlvo, cDtDe, cDtAte, cSuffix )
			Next
		EndIf
		
		If !(cID == oIndicador:cValue("ID"))
			oIndicador:lSeek(1, { cID })
		EndIf
		
		aAux := oIndicador:aContemMF(cFormula)
		If valType(aAux) == "A" .and. len(aAux) > 0
			For nInd := 1 to len(aAux)
				nMetaID := strTran(aAux[nInd], "M.", "")
				cSuffix += DwStr(nMetaID)
				If oMetaFormula:lSeek(1, {nMetaID})
					oXmlAttrib := TBIXmlAttrib():New()
					oXmlAttrib:lSet("TIPO", "METAFORMULAS")
					oXmlAttrib:lSet("ID", allTrim(nMetaID))
					oXmlAttrib:lSet("NOME", oMetaFormula:cValue("NOME"))
					//oXmlAttrib:lSet("FORMULA", oIndicador:cRetFormula(oMetaFormula:cValue("FORMULA")))
					oXmlAttrib:lSet("FORMULA", AllTrim( oMetaFormula:cValue("FORMULA") ) )
					
					oCalcMetaForm:oIndicador 	:= oIndicador
					oCalcMetaForm:oPlanilha		:= oPlanilha
					oCalcMetaForm:lCal_CriaLog("","teste.log")
					aValores := oCalcMetaForm:aCalc_Indicador(oPlanilha:aDateConv(cToD(cDtAlvo), oIndicador:nValue("FREQ")), oMetaFormula:cValue("FORMULA"), .F.)
					
					oXmlAttrib:lSet("DEPARTAMENTO", "-")
					oXmlAttrib:lSet("VALOR_REAL", aValores[AC_VALOR] + " = " + cBIStr(&(aValores[AC_VALOR])))
					oXmlAttrib:lSet("VALOR_META", aValores[AC_META] + " = " + cBIStr(&(aValores[AC_META])))
					oXmlAttrib:lSet("VALOR_PREVIA", aValores[AC_PREVIA] + " = " + cBIStr(&(aValores[AC_PREVIA])))
					oXmlAttrib:lSet("VALOR_REAL_ACUM", "-")
					oXmlAttrib:lSet("VALOR_META_ACUM", "-")
					oXmlAttrib:lSet("VALOR_REAL_STATUS", "5")
					oXmlAttrib:lSet("VALOR_ACUM_STATUS", "5")
					oXmlAttrib:lSet("TENDENCIA", "5")
					
					oIndMetaForm := TBIXmlNode():New("METAFORMULA"+cSuffix, "", oXmlAttrib)
					
					oFormula :=	oIndicador:oFormulaToXML(oMetaFormula:cValue("FORMULA"))
					nItemFormulas := oFormula:nChildCount("ITEMFORMULA")
					
					If nItemFormulas > 0
						For nInd := 1 to nItemFormulas
							oItemInd := oFormula:oChildByPos(nInd)
							
							::oIndicFormulaToXMLNode( oItemInd:oChildByName("INDICA_ID"):cGetValue("VALUE"), oIndMetaForm, cDtAlvo, cDtDe, cDtAte, cSuffix )
						Next
					EndIf
					
					oIndicXmlNode:AddChild(oIndMetaForm)
					
					If !(cID == oIndicador:cValue("ID"))
						oIndicador:lSeek(1, { cID })
					EndIf
					
				EndIf
			Next
		EndIf
		
		oXmlNode:AddChild(oIndicXmlNode)
	EndIf
	
return oXmlNode

function _KpiIndicadorFormula()
return .t.