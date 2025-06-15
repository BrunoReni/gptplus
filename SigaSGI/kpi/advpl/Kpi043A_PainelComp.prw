// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI043A_PCompxInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 11.09.06 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI043A_PainelComp.ch"

/*--------------------------------------------------------------------------------------
@class TKPI043A
@entity PAINELXIND
Objeto que representa os indicadores de um Painel
@table KPI043A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY 		"PCOMPXIND"
#define TAG_GROUP  		"PCOMPXINDS"
#define TEXT_ENTITY 	STR0001/*//"Painel / Indicadores "*/
#define TEXT_GROUP  	STR0002/*//"Paineis / Indicadores "*/

#define REAL 			1
#define META  			2
#define REALACUMULADO  	3
#define METAACUMULADO  	4
#define STATUSSIMPLES	5	
#define STATUSACUMULADO 6
#define PREVIA          7
#define VALORACUMULADO  8

class TKPI043A from TBITable
	method New() constructor
	method NewKPI043A()
	method oToXMLList(cParentID)
	method oToXMLCards(cParentID, dDataDe, dDataAte)	
	method nInsFromXML(cPainelID,oXML)
	method nUpdFromXML(cPainelID,oXML)
	method nDelFromXML(cPainelID)  
	method oXMLStatus(aPeriodo, aValores)
	method oXMLAcumuladoStatus(aPeriodo, aValores) 
	method oXMLTable(aPeriodo, aValores, oIndicador, lPrevia, lPercentual, 	aDataDe, aDataAte) 
	method oXMLGraph(aPeriodo, aValores, oIndicador)
	method oMakeTableComp(dDataDe, dDataAte,oIndicador)	

	method aValores(aPeriodo, oIndicador)
endclass

method New() class TKPI043A
	::NewKPI043A()
return

method NewKPI043A() class TKPI043A
	// Table
	::NewTable("SGI043A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_PAINEL"	,"C"	,10))	//Id do Grupo.
	::addField(TBIField():New("ID_INDIC"	,"C"	,10))	//Id usado 
	::addField(TBIField():New("ID_ORDEXIB"	,"C"	,3,0))	//Ordem de exibicao

	// Indexes
	::addIndex(TBIIndex():New("SGI043AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI043AI02",	{"ID_PAINEL","ID_INDIC"},.f.))
	::addIndex(TBIIndex():New("SGI043AI03",	{"ID_INDIC"},.f.))
	::addIndex(TBIIndex():New("SGI043AI04",	{"ID_PAINEL","ID_ORDEXIB"},.f.))	
return

/**
Lista de painéis comparativos.
@param cParentID
@return oXMLNode
*/
method oToXMLList(nParentID) class TKPI043A
	local oNode
	local oAttrib
	local oXMLNode
	local nInd

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	::SetOrder(1)
	::cSQLFilter("PARENTID = '"+cBIStr(nParentID)+"'") 
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		aFields := ::xRecord(RF_ARRAY, {"ID"})		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY)) 
		
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "ID_INDIC")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))			
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
			endif
		next

		::_Next()
	end
	::cSQLFilter("") 

return oXMLNode

/**
Lista de paineis comparativos.
@param cParentID
@param dDataDe
@param dDataAte
@return oXMLNode
*/
method oToXMLCards(cParentID, dDataDe, dDataAte) class TKPI043A
	local oAttrib
	local oXMLNode
	local oIndicador
		
	::SetOrder(4)	
	::lSoftSeek(4, {cParentId})

	if(!::lEof() .and. cParentId == ::cValue("ID_PAINEL"))
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("TIPO", "CARD")
		oAttrib:lSet("RETORNA", .f.)  

		oXMLNode := TBIXMLNode():New("CARDS",,oAttrib)
		oIndicador := ::oOwner():oGetTable("INDICADOR")  
		
		while(!::lEof() .and. cParentId == ::cValue("ID_PAINEL"))
			if(oIndicador:lSeek(1,{::cValue("ID_INDIC")}) .and. ! alltrim(::cValue("ID_INDIC"))=="0" )
				oXmlNode:oAddChild(::oMakeTableComp(dDataDe, dDataAte, oIndicador))
			endif  
			
			::_Next() 			
		end
	endif 
	
return oXMLNode

/**
Montagem do tabela do painel comparativo.
@param dDataDe
@param dDataAte
@param oInd
@return oXMLNode
*/
method oMakeTableComp(dDataDe, dDataAte, oIndicador) class TKPI043A
	local oPlanilha		:= ::oOwner():oGetTable("PLANILHA")
	local oDepto		:= ::oOwner():oGetTable("SCORECARD")
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO") 
	local oXMLNode		:= Nil
	local oAttrib		:= Nil
	local aDataDe 		:= {}
	local aDataAte 		:= {}
   	local aPeriodo		:= {}
	Local aValores		:= {} 
	local nDecimal		:= 2   
	local cNome			:= ""   
	local lPrevia		:= .F.       
	local lPercentual 	:= .F. 
       
    //Recupera os parâmetros para o painel comparativo.                              
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lPrevia := oParametro:lValue("DADO")
	endif      
	
	if(oParametro:lSeek(1, {"SHOWVARCOL"}))
		lPercentual := oParametro:lValue("DADO")
	endif
	
	if(oParametro:lSeek(1, {"DECIMALVAR"}))
		nDecimal := int(oParametro:nValue("DADO"))        
	endif                                                     

	//Converte o período para um array no formato {ano, mes, dia}.
 	aDataDe 		:= oPlanilha:aDateConv(xbiconvto("D",dDataDe),  oIndicador:nValue("FREQ"))
	aDataAte 		:= oPlanilha:aDateConv(xbiconvto("D",dDataAte), oIndicador:nValue("FREQ")) 
	
	//Recupe a quantidade de períodos para a análise.
	aPeriodo 	:= oPlanilha:aQtdFrequencia( aDataDe, aDataAte, oIndicador:nValue("FREQ") )

	//Recupera os valores para determinado período. 
	aValores 	:= ::aValores(aPeriodo, oIndicador, dDataDe, dDataAte)

 	//Montagem do XML.
    oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "CARD")
	oAttrib:lSet("RETORNA", .f.)
	oXMLNode := TBIXMLNode():New("CARD",,oAttrib)
    
	//Adiciona a TABELA.
	oXMLNode:oAddChild( ::oXMLTable(aPeriodo, aValores, oIndicador, lPrevia, lPercentual, aDataDe, 	aDataAte) ) 
	
    //Adiciona o STATUS.
	oXMLNode:oAddChild( ::oXMLStatus(aPeriodo, aValores) )  	

	//Adiciona o STATUS ACUMULADO.
	oXMLNode:oAddChild( ::oXMLAcumuladoStatus(aPeriodo, aValores) )  	
	
	//Adiciona o GRAFICO. 
	oXMLNode:oAddChild( ::oXMLGraph(aPeriodo, aValores, oIndicador) )
         
	//Adiciona as demais informações.
	oXMLNode:oAddChild(TBIXMLNode():New("ENTITY"	 	, TAG_ENTITY))
	
	if oDepto:lSeek(1, {oIndicador:cValue("ID_SCOREC")})
		cNome := alltrim(oDepto:cValue("NOME")) + " - " + alltrim(oIndicador:cValue("NOME"))
	endif
	
	oXMLNode:oAddChild(TBIXMLNode():New("NOME"		 	, cNome))  
	oXMLNode:oAddChild(TBIXMLNode():New("IDSCOREC"		, oDepto:cValue("ID"))) 
 	
	oXMLNode:oAddChild(TBIXMLNode():New("ENTID" 	 	, oIndicador:cValue("ID")))
	oXMLNode:oAddChild(TBIXMLNode():New("ID" 		 	, oIndicador:cValue("ID")))
	oXMLNode:oAddChild(TBIXMLNode():New("DECIMAIS"	 	, oIndicador:nValue("DECIMAIS")))   
	oXMLNode:oAddChild(TBIXMLNode():New("ASCEND"	 	, oIndicador:cValue("ASCEND")))
	
	oXMLNode:oAddChild(TBIXMLNode():New("PREVIA"	 	, lPrevia))
	oXMLNode:oAddChild(TBIXMLNode():New("VARPERCENT"	, lPercentual)) 
	oXMLNode:oAddChild(TBIXMLNode():New("PERCENTDEC"	, nDecimal)) 
	
	oXMLNode:oAddChild(TBIXMLNode():New("ORDEMEXIB" 	, ::nValue("ID_ORDEXIB")))
	
return oXMLNode

/** 
Montagem dos arrays contendo os valores dos indicadores.
@param aPeriodo 
@param oIndicador
@param dDataDe
@return aRet 
*/ 
method aValores(aPeriodo, oIndicador, dDataDe, dDataAte) class TKPI043A  
	local oPlanilha	:= ::oOwner():oGetTable("PLANILHA")
	Local aReal 		:= {}
	Local aMeta		:= {}
	Local aRealAcum	:= {}
	Local aMetaAcum	:= {}
	Local aStatus		:= {}
	Local aStatus2	:= {}
	Local aPrevia		:= {}
	Local aVlrAcum 	:= {}
	Local aTemp		:= {}
	Local nCount 		:= 1  
	Local cDataTmp	:= ""
	Local nMesCtrl	:= 0

	For nCount := 1 To Len(aPeriodo)
		If(oPlanilha:lSeek(2, {oIndicador:cValue("ID"),aPeriodo[nCount][1][1], aPeriodo[nCount][1][2],aPeriodo[nCount][1][3] }))
			cDataTmp := cFormatDate( aPeriodo[nCount], oIndicador:nValue("FREQ") )

		 	aTemp := oIndicador:aGetIndValores(ctod(cDataTmp),dDataDe,ctod(cDataTmp))

			aadd(aReal		, 	aTemp[1] 	)
			aadd(aMeta		,	aTemp[2]  	)
			aadd(aRealAcum,	aTemp[3]  	)
			aadd(aMetaAcum,	aTemp[4]  	)
			aadd(aStatus	,	aTemp[5]	)
			aadd(aStatus2	,	aTemp[6]	)
			aadd(aPrevia	, 	aTemp[7]	)
	 	Else                                         
			aadd(aReal		, 	0 				)	
			aadd(aMeta		,	0  				)
			aadd(aRealAcum,	0  				)
			aadd(aMetaAcum,	0  				)
			aadd(aStatus	,	ESTAVEL_GRAY	)
			aadd(aStatus2	,	ESTAVEL_GRAY	)
			aadd(aPrevia	, 	0				)	
	 	EndIf
	Next nCount	 
	  	
	aVlrAcum 	:= oIndicador:aGetIndValores(dDataAte,dDataDe,dDataAte)

return { aReal, aMeta, aRealAcum, aMetaAcum, aStatus, aStatus2, aPrevia, aVlrAcum }  
 
/*******************************************************************
	Formata a data para a frequência correta.
	@Param aPeriodo periodo a ser tratado
	@Param nFreq  frequência.
	@Return Data tratada.
	@Author Helio Leal.
 *******************************************************************/
Function cFormatDate(aPeriodo, nFreq)
	Local cDataTmp := ""
	
	Default nFreq := KPI_FREQ_MENSAL

	If ( aPeriodo[1][3] == "00" )
 		cDataTmp := "01"
  	Else
 		cDataTmp := aPeriodo[1][3]
 	EndIf

	If nFreq == KPI_FREQ_BIMESTRAL	
		If ( aPeriodo[1][2] == "00" )
  			cDataTmp += "/02"
	  	Else
	  		If aPeriodo[1][2] == '01'
		  		cDataTmp += "/02"
		  	ElseIf aPeriodo[1][2] == '02'
		  		cDataTmp += "/04"
		  	ElseIf aPeriodo[1][2] == '03'
		  		cDataTmp += "/06"
		  	ElseIf aPeriodo[1][2] == '04'
		  		cDataTmp += "/08"
		  	ElseIf aPeriodo[1][2] == '05'
		  		cDataTmp += "/10"
		  	ElseIf aPeriodo[1][2] == '06'
		  		cDataTmp += "/12"
		  	EndIf
	  	EndIf
	Else
 	  	If ( aPeriodo[1][2] == "00" )
 	  		cDataTmp += "/01"
 	  	Else
 	  		cDataTmp += "/" + aPeriodo[1][2]
 	  	EndIf
	EndIf

  	cDataTmp += "/" + aPeriodo[1][1]

Return cDataTmp
 
/** 
Montagem da tabela do painél comparativo.
@param aPeriodo 
@param aValores
@param oIndicador
@param lPrevia
@param lPercentual
@return aRet 
*/ 
method oXMLTable(aPeriodo, aValores, oIndicador, lPrevia, lPercentual, 	aDataDe, aDataAte) class TKPI043A  
	Local nCount 		:= 1
	Local oCardAttrib	:= Nil
		
	//Montagem da TABELA.
    oCardAttrib := TBIXMLAttrib():New()
	oCardAttrib:lSet("TIPO", "TABLE")
	oCardAttrib:lSet("RETORNA", .f.)

	oCardAttrib:lSet("TAG000", "TIPO")
	oCardAttrib:lSet("CAB000", " ")
	oCardAttrib:lSet("CLA000", KPI_STRING) 
    
	//Montagem do CABECALHO da TABELA.
	for nCount := 1 to len(aPeriodo)
		oCardAttrib:lSet("TAG" + padl(nCount,3,"0"), "COL" + allTrim(str(nCount)) )
		oCardAttrib:lSet("CAB" + padl(nCount,3,"0"), aPeriodo[nCount][2])
		oCardAttrib:lSet("CLA" + padl(nCount,3,"0"), KPI_FLOAT)
	next nCount        
	                                      
	oCardAttrib:lSet("TAG" + padl(nCount,3,"0"), "ACUM")
	oCardAttrib:lSet("CAB" + padl(nCount,3,"0"), STR0028)
	oCardAttrib:lSet("CLA" + padl(nCount,3,"0"), KPI_FLOAT)
	   		
	oXMLCard := TBIXMLNode():New("TABLE",,oCardAttrib)
  
    //Adiciona o REAL. 
	oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
	oNode:oAddChild(TBIXMLNode():New("IDLINHA", "REAL"))
	oNode:oAddChild(TBIXMLNode():New("TIPO", ::oOwner():getStrCustom():getStrReal()))  //"Real"
	
	for nCount := 1 to len(aPeriodo)
	   	oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[REAL][nCount]))
	next nCount  
	
	oNode:oAddChild(TBIXMLNode():New("ACUM", aValores[VALORACUMULADO][3]))
	
	//Adiciona a META.
	oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
	oNode:oAddChild(TBIXMLNode():New("IDLINHA", "META"))
	oNode:oAddChild(TBIXMLNode():New("TIPO", ::oOwner():getStrCustom():getStrMeta())) //Meta
	
	For nCount := 1 To Len(aPeriodo)
	   	oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[META][nCount]))          
	Next nCount  
	                                                      
	oNode:oAddChild(TBIXMLNode():New("ACUM", aValores[VALORACUMULADO][4]))
	      
	//Adiciona a PREVIA.
	if ( lPrevia )
		oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
  		oNode:oAddChild(TBIXMLNode():New("IDLINHA", "PREVIA"))
		oNode:oAddChild(TBIXMLNode():New("TIPO", ::oOwner():getStrCustom():getStrPrevia())) //Prévia
		
		for nCount := 1 to len(aPeriodo)
		   	oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[PREVIA][nCount]))          
		next nCount

		if(oIndicador:cValue("ACUM_TIPO") == "2")
			nPreviaAcum := oIndicador:calcPreviaAcum(aDataAte,aDataAte,oIndicador:cValue("ACUM_TIPO"))		
		else
			nPreviaAcum := oIndicador:calcPreviaAcum(aDataDe,aDataAte,oIndicador:cValue("ACUM_TIPO"))		
		endif 		                      
		oNode:oAddChild(TBIXMLNode():New("ACUM", nPreviaAcum))
    endif   	
	
	//Adiciona a VARIACAO.
	oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
	oNode:oAddChild(TBIXMLNode():New("IDLINHA", "VARIACAO"))
	oNode:oAddChild(TBIXMLNode():New("TIPO", STR0006 )) //Variação
	
	for nCount := 1 to len(aPeriodo)
		nValores := oIndicador:nGetVar(lPercentual,aValores[REAL][nCount],aValores[META][nCount])
		oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), nValores)) 
	next nCount
	      
	oNode:oAddChild(TBIXMLNode():New("ACUM", oIndicador:nGetVar(lPercentual,aValores[VALORACUMULADO][3],aValores[VALORACUMULADO][4])))

	//Adiciona o REAL ACUMULADO.
	oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
	oNode:oAddChild(TBIXMLNode():New("IDLINHA", "REALACUM"))
	oNode:oAddChild(TBIXMLNode():New("TIPO", ::oOwner():getStrCustom():getStrReal() + STR0032 )) //Real Acumulado
	
	for nCount := 1 to len(aPeriodo)
		oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[REALACUMULADO][nCount])) 
	next nCount 
	     
	oNode:oAddChild(TBIXMLNode():New("ACUM", aValores[REALACUMULADO][len(aValores[REALACUMULADO])]))

	//Adiciona a META ACUMULADA. 
	oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
	oNode:oAddChild(TBIXMLNode():New("IDLINHA", "METAACUM"))
	oNode:oAddChild(TBIXMLNode():New("TIPO", ::oOwner():getStrCustom():getStrMeta() + STR0031)) //Meta Acumulada
	
	for nCount := 1 to len(aPeriodo)
		oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[METAACUMULADO][nCount])) 
	next nCount
	      
	oNode:oAddChild(TBIXMLNode():New("ACUM", aValores[METAACUMULADO][len(aValores[METAACUMULADO])]))

	//Adiciona a VARIACAO ACUMULADA. 
	oNode := oXMLCard:oAddChild(TBIXMLNode():New("LINHA"))
	oNode:oAddChild(TBIXMLNode():New("IDLINHA", "VARIACUM"))
	oNode:oAddChild(TBIXMLNode():New("TIPO", STR0027)) //Variacao Acumulada
	
	for nCount := 1 to len(aPeriodo)
		nValores := oIndicador:nGetVar(lPercentual,aValores[REALACUMULADO][nCount],aValores[METAACUMULADO][nCount])
		oNode:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), nValores)) 
	next nCount      
	
	oNode:oAddChild(TBIXMLNode():New("ACUM", oIndicador:nGetVar(lPercentual,aValores[VALORACUMULADO][3],aValores[VALORACUMULADO][4])))

Return oXMLCard 
 
/** 
Montagem do status.
@param aPeriodo
@param aValores     
@return  oXMLStat
*/
method oXMLStatus(aPeriodo, aValores) class TKPI043A 
	Local nCount := 1
	Local oXMLStat
	Local oStatAttrib
	Local oNodeStat    
    
	oStatAttrib := TBIXMLAttrib():New()
	oStatAttrib:lSet("TIPO", "STATUS")
	oStatAttrib:lSet("RETORNA", .f.)

	oStatAttrib:lSet("TAG000", "TIPO")
	oStatAttrib:lSet("CAB000", STR0030) //"Tipo"
	oStatAttrib:lSet("CLA000", KPI_STRING)
	
	for nCount := 1 to len(aPeriodo)
		oStatAttrib:lSet("TAG" + padl(nCount,3,"0"), "COL" + allTrim(str(nCount)) )
		oStatAttrib:lSet("CAB" + padl(nCount,3,"0"), aPeriodo[nCount][2])
		oStatAttrib:lSet("CLA" + padl(nCount,3,"0"), KPI_STRING)
	next nCount   
	
	oStatAttrib:lSet("TAG" + padl(nCount,3,"0"), "ACUM")
	oStatAttrib:lSet("CAB" + padl(nCount,3,"0"), STR0028)
	oStatAttrib:lSet("CLA" + padl(nCount,3,"0"), KPI_STRING)
	    
	oXMLStat := TBIXMLNode():New("STATUS",,oStatAttrib)
	oNodeStat := oXMLStat:oAddChild(TBIXMLNode():New("LINHA"))
	oNodeStat:oAddChild(TBIXMLNode():New("TIPO", STR0029)) //"Status"   
	
	for nCount := 1 to len(aPeriodo)
		oNodeStat:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[STATUSSIMPLES][nCount])) 
	next nCount    
	         
	oNodeStat:oAddChild(TBIXMLNode():New("COL" + allTrim(str(len(aPeriodo)+1)) , aValores[VALORACUMULADO][6])) 	

Return oXMLStat
  
/**                          
Montagem do status acumulado.
@param aPeriodo
@param aValores     
@return  oXMLStat
*/
method oXMLAcumuladoStatus(aPeriodo, aValores) class TKPI043A 
	Local oXMLStat  	:= Nil 
	Local oStatAttrib	:= Nil
	Local oNodeStat  	:= Nil
	Local nCount 		:= 1
	   
	oStatAttrib := TBIXMLAttrib():New()
	oStatAttrib:lSet("TIPO", "STATUS")
	oStatAttrib:lSet("RETORNA", .f.)

	oStatAttrib:lSet("TAG000", "TIPO")
	oStatAttrib:lSet("CAB000", STR0030) //"Tipo"
	oStatAttrib:lSet("CLA000", KPI_STRING)
	
	for nCount := 1 to len(aPeriodo)
		oStatAttrib:lSet("TAG" + padl(nCount,3,"0"), "COL" + allTrim(str(nCount)) )
		oStatAttrib:lSet("CAB" + padl(nCount,3,"0"), aPeriodo[nCount][2])
		oStatAttrib:lSet("CLA" + padl(nCount,3,"0"), KPI_STRING)
	next nCount 
	
	oStatAttrib:lSet("TAG" + padl(nCount,3,"0"), "ACUM")
	oStatAttrib:lSet("CAB" + padl(nCount,3,"0"), STR0028)
	oStatAttrib:lSet("CLA" + padl(nCount,3,"0"), KPI_STRING)

	oXMLStat := TBIXMLNode():New("STATUS_AC",,oStatAttrib)
	oNodeStat := oXMLStat:oAddChild(TBIXMLNode():New("LINHA"))
	oNodeStat:oAddChild(TBIXMLNode():New("TIPO", STR0029)) //"Status"  
	
	for nCount := 1 to len(aPeriodo)
		oNodeStat:oAddChild(TBIXMLNode():New("COL" + allTrim(str(nCount)), aValores[STATUSACUMULADO][nCount])) 
	next nCount       
	      
	oNodeStat:oAddChild(TBIXMLNode():New("COL" + allTrim(str(len(aPeriodo)+1)) , aValores[VALORACUMULADO][6]))

Return oXMLStat

/**
Montagem dos valores para o gráfico. 
@param aPeriodo
@param aValores      
@return 
*/
method oXMLGraph(aPeriodo, aValores, oIndicador) class TKPI043A 
	Local oXMLGraph	:= Nil
	Local oNodeX	:= Nil
	Local oNodeY 	:= Nil

	Local nCount 	:= 1
	
	oXMLGraph:= TBIXMLNode():New("GRAPH")
           
    
    //Monta os dados do eixo X [Período].      
	oNodeX := oXMLGraph:oAddChild(TBIXMLNode():New("PERIODO")) 
	
	for nCount := 1 to len(aPeriodo)
		oNodeX:oAddChild( TBIXMLNode():New("EIXOX" + Padl((nCount),3,"0"), aPeriodo[nCount][2]) )		
	next nCount        

   	oNodeX:oAddChild( TBIXMLNode():New("XACUM", STR0028) )
            
     
    //Monta os dados do eixo Y [Realizado].       
	oNodeY := oXMLGraph:oAddChild(TBIXMLNode():New("VALOR"))  

	for nCount := 1 to len(aPeriodo)
		oNodeY:oAddChild(TBIXMLNode():New("EIXOY" + Padl((nCount),3,"0"), aValores[REAL][nCount]) )	   	
	next nCount
	
	oNodeY:oAddChild(TBIXMLNode():New("YACUM", aValores[VALORACUMULADO][3]) )     
	
	
	//Monta os dados do eixo Y [Variação].       
	oNodeY := oXMLGraph:oAddChild(TBIXMLNode():New("VARIACAO"))  

	for nCount := 1 to len(aPeriodo)
		oNodeY:oAddChild(TBIXMLNode():New("EIXOY" + Padl((nCount),3,"0"), oIndicador:nGetVar(.T.,aValores[REAL][nCount],aValores[META][nCount]) ) )	   	
	next nCount
	
	oNodeY:oAddChild(TBIXMLNode():New("YACUM", oIndicador:nGetVar(.T.,aValores[VALORACUMULADO][3],aValores[VALORACUMULADO][4]) ) )   
 
Return oXMLGraph
             
//Faz a atualização dos temas gravados
method nUpdFromXML(cPainelID, oXML) class TKPI043A
	local nStatus 		:= KPI_ST_OK
	local nFoundItem 
	local nItem 		:= 0  
	local aItemOk 		:= {}
	local aFields 
	 
	private aTemaObj := oXml

	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	::cSQLFilter("ID_PAINEL = '" + cBIStr(cPainelID)+"'")
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		nFoundItem := ascan(aTemaObj,{|x| x:_ID:TEXT == alltrim(::cValue("ID_INDIC"))})

		if(nFoundItem > 0)
			aadd(aItemOk, nFoundItem)
		endif			
		
		//Nao encontrou no XML apaga.
		if(nFoundItem == 0)			
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
				exit							
			endif
		endif    
		
		::_Next()
	end
	::cSQLFilter("")

	for nItem := 1 to len(aTemaObj)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		if nFoundItem == 0
			//Nao esta no array de itemOk Inclui.
			::nInsFromXML(cPainelID,oXml, nItem)
		endif
	next nItem

return nStatus

//Insere a entidade no server
method nInsFromXML(cPainelID,oXml,nItemInc) class TKPI043A
	local nStatus := KPI_ST_OK
	local nInd
	local nTemas 
	local aFields 
	
	private aTemaObj := oXml

	default nItemInc := 0
	
	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	for nTemas := 1 to len(aTemaObj)
		//Verifica se devo incluir um item especifico.
		if(nItemInc == 0 .or. nTemas == nItemInc)
			aFields := ::xRecord(RF_ARRAY, {"ID_INDIC","ID_PAINEL"})
					
			// Extrai valores do XML
			for nInd := 1 to len(aFields)
				cType := ::aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("aTemaObj["+alltrim(str(nTemas))+"]:_"+aFields[nInd][1]+":TEXT"))
				if(aFields[nInd][1] == "ID")			
					aAdd( aFields, {"ID_INDIC", aFields[nInd][2]})
					aFields[nInd][2] := ::cMakeID()
				endif
			next
	
			aAdd( aFields, {"ID_PAINEL", cPainelID})
			
			// Grava
			if(!::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			endif
		endif
	next nTemas

return nStatus

/**
Exclui tabelas do painel comparativo.    
@param cIDPainel Grupo de tabela a ser excluída. 
@return nStatus Indica o status da exclusão. 
*/
Method nDelFromXML(cIDPainel) class TKPI043A
	Local nStatus := KPI_ST_OK

	::cSQLFilter("ID_PAINEL = '" + cBIStr(cIDPainel)+"'")
	::lFiltered(.T.)
	::_First() 
	
	while(!::lEof())
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif  
		
		::_Next()
	end
	::cSQLFilter("")    
    
Return nStatus


function _KPI043A_PCompxInd()
return nil
