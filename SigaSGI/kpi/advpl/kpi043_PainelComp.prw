// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI043_PainelComp.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 28.09.06 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI043_PainelComp.ch"

/*--------------------------------------------------------------------------------------
@entity Painel de Indicadores
Paineis de Indicadores dos Scorecards que o usuario tem direito de visualização.
@table KPI043
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PAINELCOMP"
#define TAG_GROUP  "PAINEISCOMP"
#define TEXT_ENTITY STR0001/*//"Painel de Indicadores"*/
#define TEXT_GROUP  STR0002/*//"Paineis de Indicadores"*/

class TKPI043 from TBITable
	method New() constructor
	method NewKPI043()

	// diversos registros
	method oToXMLRecList()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method oToXMLNode(cId, cLoadCmd)
	method nExecute(cID, cExecCMD)
	
	method hasUserPermission()
	method cFormatNumber(nValue, nCasaDecimal)
endclass
	
method New() class TKPI043
	::NewKPI043()
return

method NewKPI043() class TKPI043
	// Table
	::NewTable("SGI043")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	::addField(TBIField():New("ID_USER"		,"C"	,010))
	::addField(TBIField():New("DATADE"		,"D"	))
	::addField(TBIField():New("DATAATE"		,"D"	))
	::addField(TBIField():New("OCVARIACAO"	,"L"	))
	::addField(TBIField():New("OCACUMULAD"	,"L"	))
	::addField(TBIField():New("OCREALACUM"	,"L"	))
	::addField(TBIField():New("OCMETAACUM"	,"L"	))  
	::addField(TBIField():New("FREQUENCIA"	,"N"	))
	::addField(TBIField():New("UNIDADE"		,"C"	,010))
	::addField(TBIField():New("OCVALORES"	,"L"	))
	::addField(TBIField():New("OCSWAPXY"	,"L"	))  
	::addField(TBIField():New("GRAFTIPO"	,"N"	))     
	::addField(TBIField():New("VARPERCENT"	,"L"	))  	
	::addField(TBIField():New("ACUMULADO"	,"L"	)) 
	::addField(TBIField():New("PUBLICO"		,"L"	))	 
	
	// Indexes 
	::addIndex(TBIIndex():New("SGI043I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI043I02",	{"NOME"},	.f.))
	::addIndex(TBIIndex():New("SGI043I03",	{"ID_USER", "ID"},	.t.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI043
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	//Gera o no de detalhes
	::SetOrder(1)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI043
	local oXMLNodeLista, oAttrib, oXMLNode, nInd

	oXMLNodeLista := TBIXMLNode():New("LISTA")
	
	//Colunas
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
	::SetOrder(1)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			if(::hasUserPermission())
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
				for nInd := 1 to len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				next
			endif
		endif			
		::_Next()		
	end

	oXMLNodeLista:oAddChild(oXMLNode)

return oXMLNodeLista

// Carregar
method oToXMLNode( cId, cLoadCmd ) class TKPI043
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY), oNode
	local aDatas 		:= {}  
	local aFields  		:= {}  
	local nInd
	local dDataDe 		
	local dDataAte 		
      
	aFields := ::xRecord(RF_ARRAY) 
	
	for nInd := 1 to len(aFields)
		if ValType(aFields[nInd][2]) == "L"
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], xBIConvTo("L",aFields[nInd][2])))   
		else                                                                          
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		endif
	next

	If( ! Empty( AllTrim(cLoadCmd) ) )
		aDatas 		:= aBiToken(cLoadCmd,"|") 
		dDataDe 	:= xBIConvTo("D",aDatas[1])
		dDataAte 	:= xBIConvTo("D",aDatas[2])   
		
		If ( dDataAte < dDataDe ) 
			dDataDe := dDataAte
		EndIf		
	EndIf        
       
    //Perído De Até.      
	oXMLNode:oAddChild(TBIXMLNode():New("DATADE", dDataDe))    
	oXMLNode:oAddChild(TBIXMLNode():New("DATAATE", dDataAte))  

	//Scorecards.
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.T.))
            
	//Unidades.
	oXMLNode:oAddChild(::oOwner():oGetTable("UNIDADE"):oToXMLList())    

    //Frequencia.
	oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oXMLFrequencia()) 
      
  	//Verifica se o usuário pode editar o painel.      
	oXMLNode:oAddChild(TBIXMLNode():New("EDITA", ::hasUserPermission(.T.)))  
 
	//Adiciona os painéis comparativos. 
	oNode := ::oOwner():oGetTable("PCOMPXIND"):oToXMLCards(::cValue("ID"),dDataDe,dDataAte) 

	if(valType(oNode)=="O")
		oXMLNode:oAddChild(oNode)
	endif		
return oXMLNode

/**
* Insere nova entidade
*/
method nInsFromXML(oXML, cPath) class TKPI043
	Local aFields  		:= {}    
	Local aPainel  		:= {}
	Local nInd    		:= 0	
	Local nPainel 		:= 0
	Local nStatus 		:= KPI_ST_OK
	Local oTable  		:= Nil   
	Local cID			:=  ::cMakeID()        
	
	Private oXMLInput 	:= oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})
    
	//Recupera os valores enviados no XML.
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next         
	  
	//Insere o ID para entidade.
	aAdd(aFields, {"ID", cID}) 
	
	//Insere o ID do usuário logado. 
	aAdd(aFields, {"ID_USER", oKpiCore:foSecurity:oLoggedUser():cValue("ID")})

	If(::lAppend(aFields))        
	
		//Extrai e grava lista de indicadores deste painel
		oTable := ::oOwner():oGetTable("PCOMPXIND")    
				
		//Remove a relação existente entre painel e indicadores. 
		oTable:nDelFromXML(cId) 		
		
		//Recupera todos os indicadores inseridos no painel. 
		aPainel = aBiToken(&("oXMLInput:"+cPath+":_PAINEISID:TEXT"),"|",.F.)  
		
		//Grava a lista de indicadores do painel. 		
		For nPainel := 1 To Len(aPainel)
			oTable:lAppend({{"ID"			, oTable:cMakeID()},;
							{"ID_PAINEL"	, cID},;
							{"ID_INDIC"		, aPainel[nPainel]},;
							{"ID_ORDEXIB"	, cBIStr(nPainel)} })
		Next

	else                  
	
		//Recupera o erro na gravação. 
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif
return nStatus

/**
* Atualiza entidade ja existente.
*/
method nUpdFromXML(oXML, cPath) class TKPI043
   	Local cID    		:= ""
	Local nFrequencia   := 0
	Local nStatus 		:= KPI_ST_OK
	Local nInd          := 0
	Local nPainel 		:= 0
	Local oTable        := Nil
	Local aPainel 		:= {}   
	
	Private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)

	//Recupera os valores enviados no XML.
	for nInd := 1 to len(aFields) 
	
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		 
		//Recupera o ID do painel que está sendo alterado. 
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

    //Verifica se o painel realmente existe. 
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else                             
	
		//Atualiza os dados do painel.  
		if(::lUpdate(aFields))   	
			
			//Extrai e grava lista de indicadores deste painel
			oTable := ::oOwner():oGetTable("PCOMPXIND")   
					
			//Remove a relação existente entre painel e indicadores. 
			oTable:nDelFromXML(cId) 		
			
			//Recupera todos os indicadores inseridos no painel. 
			aPainel = aBiToken(&("oXMLInput:"+cPath+":_PAINEISID:TEXT"),"|",.F.)   
			
			//Atualiza a lista de indicadores do painel. 		
			For nPainel := 1 To Len(aPainel)
				oTable:lAppend({{"ID"			, oTable:cMakeID()},;
								{"ID_PAINEL"	, cID},;
								{"ID_INDIC"		, aPainel[nPainel]},;
								{"ID_ORDEXIB"	, cBIStr(nPainel)} })
			Next
		
		else    
		
			//Recupera o erro na atualização. 
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif
return nStatus

/** 
*Excluir entidade do server.   
*@param Caracter ID da entidade.
*@return Numérico Indica se a operação foi bem sucedida.
*/
method nDelFromXML(cID) class TKPI043
	local nStatus 	:= KPI_ST_OK

	if(nStatus == KPI_ST_OK)
		if(::lSeek(1,{cID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
    endif
return nStatus

/**
* Verifica se o usuario tem permissao para visualizar o painel  
* @return Lógico Indica se o usuário tem permissão. 
*/
method hasUserPermission(lJustEdit) class TKPI043
	local lPermission 	:= .F.
	local oUser			:= ::oOwner():foSecurity:oLoggedUser()
	local cUsuAtual 	:= alltrim(oUser:cValue("ID"))
	Local lPublico 		:= .F.
	    
	Default lJustEdit 	:= .F.
	
	If ( ! lJustEdit )	        
		lPublico := ::lValue("PUBLICO")            	
	EndIf                 
		   
		   
	If ( oUser:lValue("ADMIN") .or. (cUsuAtual == alltrim(::cValue("ID_USER"))) .or. lPublico )
		lPermission := .t.
	EndIf	
return lPermission

/**
* Executa a exportação do painel comparativo.
* @param ID ID da painel a ser exportado. 
* @param cLoadCmd Parâmetros para a exportacao.  
* @return Numérico Indica se a exportacao foi realizada com sucesso. 
*/
method nExecute(cID, cLoadCmd) class TKPI043
	local nStatus 		:= KPI_ST_OK 
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local oPComp 		:= ::oOwner():oGetTable("PCOMPXIND") 
	local oInd			:= ::oOwner():oGetTable("INDICADOR")         
	local oPlanilha		:= ::oOwner():oGetTable("PLANILHA")
	local oDepto		:= ::oOwner():oGetTable("SCORECARD")
	local cDepto		:= ""  
	local cDataTmp		:= ""
	local aDados 		:= aBiToken(cLoadCmd,"|")
	local aDataDe		:= {}
	local aDataAte		:= {} 
	local cDiretorio	:= "\sgiExport\"
	local oXlsFile		:= nil   
	local aPeriodo		:= {}
 	local aPrevia		:= {}
 	local aReal			:= {}
 	local aMeta			:= {}
    local aRealAc		:= {}
    local aMetaAc		:= {}
    local aVarAc		:= {}  
 	local aVlrAcum		:= {}
 	local aTemp			:= {}   
    local nRow			:= 2 
    local nVarDecimnal	:= 2 
    local nPreviaAcum	:= 0
    local nCount		:= 0
    local i				:= 0
    local lValorPrevio	:= .f.
    local lShowVar		:= .f. 
    local lShowAcum		:= .f.
    local lShowRealAc	:= .f.
    local lShowMetaAc	:= .f.
    local lVarPercent 	:= .f.  /*Exibir variação em percentual.*/	
	Local nDecimais 	:= 0   	/*Número de casas decimais.*/
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	

	oXlsFile	:= TBIFileIO():New(oKPICore:cKpiPath()+ cDiretorio + "planilha_paineis_comparativos.xls")
	// Cria o arquivo xls
	If ! oXlsFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		nStatus := KPI_ST_GENERALERROR
	endif	
	
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
		if(lValorPrevio)
			nRow += 1
		endif
	endif     
	
	//Exibir variação em percentual	
	if(oParametro:lSeek(1, {"SHOWVARCOL"}))
		lVarPercent := oParametro:lValue("DADO")
	endif  
	
	//Casas decimais da variação em percentual
	if(oParametro:lSeek(1, {"DECIMALVAR"}))
		nVarDecimnal := int(oParametro:nValue("DADO"))        
	endif
	
	if ( xBIConvTo("L",aDados[3]) )
		lShowVar := .t.
		nRow += 1
		nRow += 1	//variacao acumulada
    endif    
    
   	if ( xBIConvTo("L",aDados[4]) )
   	 	lShowAcum := .t.
   	endif
    
   	if ( xBIConvTo("L",aDados[5]) )
   	 	lShowRealAc := .t.
		nRow += 1
   	endif
    
   	if ( xBIConvTo("L",aDados[6]) )
   	 	lShowMetaAc := .t.
		nRow += 1
   	endif
	
	oXlsFile:nWriteLN('<html>')
	oXlsFile:nWriteLN('<head>')
	oXlsFile:nWriteLN('	<title>' + STR0003 + '</title>') //Planilha
	oXlsFile:nWriteLN('	<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
	oXlsFile:nWriteLN('</head>')
	oXlsFile:nWriteLN('<body>')
	oXlsFile:nWriteLN('	<table width="100%" align="left" border="1" cellpadding="0" cellspacing="0">')
	
	oPComp:SetOrder(4)
	oPComp:lSoftSeek(4, {cID})  
	
	while(!oPComp:lEof() .and. cID == alltrim(oPComp:cValue("ID_PAINEL")) )
        if(oInd:lSeek(1,{oPComp:cValue("ID_INDIC")}) .and.!  alltrim(oPComp:cValue("ID_INDIC"))=="0" )
        		aPeriodo	:= {}
 				aPrevia		:= {}
 				aReal		:= {}
 				aMeta		:= {} 
 				aRealAc		:= {}
			    aVarAc      := {}
 				aMetaAc		:= {}
 				aReal		:= {}
 				aMeta		:= {}
				aDataDe	 := oPlanilha:aDateConv(xbiconvto("D",aDados[1]), oInd:nValue("FREQ"))
				aDataAte := oPlanilha:aDateConv(xbiconvto("D",aDados[2]), oInd:nValue("FREQ"))
				aPeriodo := oPlanilha:aQtdFrequencia(aDataDe, aDataAte, oInd:nValue("FREQ"))

				/*Recupera o número de casas decimais definida para o indicador.*/
				nDecimais := oInd:nValue("DECIMAIS")	

				for nCount := 1 to len(aPeriodo)
				 	if(oPlanilha:lSeek(2, {oInd:cValue("ID"),	aPeriodo[nCount][1][1],;
	 						 						 			aPeriodo[nCount][1][2],;
	 															aPeriodo[nCount][1][3] }) )
		 				//Convertemos aPeriodo para data
				 		//Dia										
				 	  	if aPeriodo[nCount][1][3] == "00" 
				 	  		cDataTmp := "01"
				 	  	else                
				 	  		cDataTmp := aPeriodo[nCount][1][3]
				 	  	endif
				 	  	//Mes
				 	  	if aPeriodo[nCount][1][2] == "00" 
				 	  		cDataTmp += "/01"
				 	  	else                
				 	  		cDataTmp += "/" + aPeriodo[nCount][1][2]
				 	  	endif                                        
				 	  	//Ano
				 	  	cDataTmp += "/" + aPeriodo[nCount][1][1]
		 	  	
						aTemp := oInd:aGetIndValores(ctod(cDataTmp),aDados[1],ctod(cDataTmp))
						aadd(aReal		, 	aTemp[1] 	)
						aadd(aMeta		,	aTemp[2]  	)
						aadd(aRealAc	,	aTemp[3]  	)
						aadd(aMetaAc	,	aTemp[4]  	)
						aadd(aPrevia	, 	aTemp[7]	)
					Else
						aadd(aReal		, 	0 	)
						aadd(aMeta		,	0  	)
						aadd(aRealAc	,	0  	)
						aadd(aMetaAc	,	0  	)
						aadd(aPrevia	, 	0	)
					Endif
				Next
				
				aVlrAcum := oInd:aGetIndValores(aDados[1],aDados[1],aDados[2])
				
				cDepto := ""
				if oDepto:lSeek(1, {oInd:cValue("ID_SCOREC")})
					cDepto := oDepto:cValue("NOME")
				endif
				
 				//Cabecalho - Inicio 
 				
 				oXlsFile:nWriteLN('		<tr>')      
				oXlsFile:nWriteLN('			<td align="center" width="16%" >')
				oXlsFile:nWriteLN('				<strong>')
				oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(cTextScor)				
				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('				</strong>')
				oXlsFile:nWriteLN('			</td>')	  
								
				oXlsFile:nWriteLN('			<td align="center" width="16%">')
				oXlsFile:nWriteLN('				<strong>')
				oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(STR0010)				//"Indicador"
				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('				</strong>')
				oXlsFile:nWriteLN('			</td>')	   
				
				oXlsFile:nWriteLN('			<td align="center" width="16%">')
				oXlsFile:nWriteLN('				<strong>')
				oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN("Orientação")			 	//"Orientacao"
				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('				</strong>')
				oXlsFile:nWriteLN('			</td>')	 

			    oXlsFile:nWriteLN('			<td align="center" width="16%">')
				oXlsFile:nWriteLN('				<strong>')
				oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN('					   '+STR0004) //Valores
				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('				</strong>')
				oXlsFile:nWriteLN('			</td>')
 				for i := 1  to len(aPeriodo)
					oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<strong>')
					oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN(aPeriodo[i][2])
					oXlsFile:nWriteLN('			   		</font>')
					oXlsFile:nWriteLN('				</strong>')
					oXlsFile:nWriteLN('			</td>')     					
 				next i  
 				if(lShowAcum)
	 				oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<strong>')
					oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN('					   ' + STR0009) //Acumulado
					oXlsFile:nWriteLN('					</font>')
					oXlsFile:nWriteLN('				</strong>')
					oXlsFile:nWriteLN('			</td>')
				endif
				oXlsFile:nWriteLN('		</tr>')				
 				//Fim
				
				
				//Departamento
				oXlsFile:nWriteLN('		<tr>')
				oXlsFile:nWriteLN('			<td align="center" width="16%" rowspan="'+ alltrim(str(nRow)) +'">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(cDepto)
				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('			</td>')			
						
				//Indicador
				oXlsFile:nWriteLN('			<td align="center" width="16%" rowspan="'+ alltrim(str(nRow)) +'">')
				oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(oInd:cValue("NOME"))
				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('			</td>')	 
				
				//Orientacao
				oXlsFile:nWriteLN('			<td align="center" width="16%" rowspan="'+ alltrim(str(nRow)) +'">')
				oXlsFile:nWriteLN('					<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				 
				If (oInd:lValue("ASCEND"))				
					oXlsFile:nWriteLN("Ascendente")
				Else
					oXlsFile:nWriteLN("Descentente")
				EndIf

				oXlsFile:nWriteLN('					</font>')
				oXlsFile:nWriteLN('			</td>')	     
				
				//Previa - Inicio 
				if(lValorPrevio)
				    oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN('					'+STR0006) //Previa
					oXlsFile:nWriteLN('				</font>')
					oXlsFile:nWriteLN('			</td>')
	 				for i := 1  to len(aPeriodo)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(aPrevia[i], nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')     					
	 				next i                              
	 				if(lShowAcum)
	 					//Tratando os acumulados de previa
						if(oInd:cValue("ACUM_TIPO") == "2")
							nPreviaAcum := oInd:calcPreviaAcum(aDataAte,aDataAte,oInd:cValue("ACUM_TIPO"))		
						else
							nPreviaAcum := oInd:calcPreviaAcum(aDataDe,aDataAte,oInd:cValue("ACUM_TIPO"))		
						endif                        
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(nPreviaAcum, nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')   
					endif					
	 				oXlsFile:nWriteLN('		</tr>')  
	 				oXlsFile:nWriteLN('		<tr>')
				endif
				//Fim
				
				//Real - Inicio
			    oXlsFile:nWriteLN('			<td align="center" width="16%">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN('					'+STR0005) //Real
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
 				for i := 1  to len(aPeriodo)
					oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN(::cFormatNumber(aReal[i], nDecimais))
					oXlsFile:nWriteLN('			 	</font>')
					oXlsFile:nWriteLN('			</td>')     					
 				next i
 				//Acumulado
 				if(lShowAcum)
					oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN(::cFormatNumber(aVlrAcum[3], nDecimais))
					oXlsFile:nWriteLN('			 	</font>')
					oXlsFile:nWriteLN('			</td>')   
				endif
 				oXlsFile:nWriteLN('		</tr>')				
 				//Fim  
 				
				//Meta - Inicio
				oXlsFile:nWriteLN('		<tr>')
			    oXlsFile:nWriteLN('			<td align="center" width="16%">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN('					'+STR0007) //Meta
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
 				for i := 1  to len(aPeriodo)
					oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN(::cFormatNumber(aMeta[i], nDecimais))
					oXlsFile:nWriteLN('			 	</font>')
					oXlsFile:nWriteLN('			</td>')     					
 				next i                
 				//Acumulado
 				if(lShowAcum)
					oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN(::cFormatNumber(aVlrAcum[4], nDecimais))
					oXlsFile:nWriteLN('			 	</font>')
					oXlsFile:nWriteLN('			</td>')   
				endif
 				oXlsFile:nWriteLN('		</tr>')				
 				//Fim
				
				//Variacao - Inicio
				if(lShowVar)
					oXlsFile:nWriteLN('		<tr>')
				    oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN('					'+STR0008) //Variação
					oXlsFile:nWriteLN('				</font>')
					oXlsFile:nWriteLN('			</td>')
	 				for i := 1  to len(aPeriodo)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(round(oInd:nGetVar(lVarPercent,aReal[i],aMeta[i]), nVarDecimnal),nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')     					
	 				next i          
	 				//Acumulado
	 				if(lShowAcum)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(round(oInd:nGetVar(lVarPercent,aVlrAcum[3],aVlrAcum[4]), nVarDecimnal), nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')   
					endif						
	 				oXlsFile:nWriteLN('		</tr>')
 				endif				
 				//Fim  
 				
 				//Real Acumulado - Inicio
 				if(lShowRealAc)
				    oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN('					'+ STR0012)		//'Real Acumulado'
					oXlsFile:nWriteLN('				</font>')
					oXlsFile:nWriteLN('			</td>')
	 				for i := 1  to len(aPeriodo)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(aRealAc[i], nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')     					
	 				next i
	 				//Acumulado
	 				if(lShowAcum)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(aRealAc[len(ARealAc)], nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')   
					endif
	 				oXlsFile:nWriteLN('		</tr>')				
	 			Endif
 				//Fim  
 				
 				//Meta Acumulado - Inicio
 				if(lShowMetaAc)
				    oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN('					'+ STR0013)	//'Meta Acumulada'
					oXlsFile:nWriteLN('				</font>')
					oXlsFile:nWriteLN('			</td>')
	 				for i := 1  to len(aPeriodo)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(aMetaAc[i], nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')     					
	 				next i
	 				//Acumulado
	 				if(lShowAcum)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(aMetaAc[len(aMetaAc)], nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')   
					endif
	 				oXlsFile:nWriteLN('		</tr>')				
	 			Endif
 				//Fim  
				
				//Variacao Acumulada - Inicio
				if(lShowVar)
					oXlsFile:nWriteLN('		<tr>')
				    oXlsFile:nWriteLN('			<td align="center" width="16%">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN('					' + STR0014)	//'Variação Acumulada'
					oXlsFile:nWriteLN('				</font>')
					oXlsFile:nWriteLN('			</td>')
	 				for i := 1  to len(aPeriodo)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(round(oInd:nGetVar(lVarPercent,aRealAc[i],aMetaAc[i]), nVarDecimnal), nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')     					
	 				next i          
	 				//Acumulado
	 				if(lShowAcum)
						oXlsFile:nWriteLN('			<td align="center" width="16%">')
						oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
						oXlsFile:nWriteLN(::cFormatNumber(round(oInd:nGetVar(lVarPercent,aVlrAcum[3],aVlrAcum[4]), nVarDecimnal), nDecimais))
						oXlsFile:nWriteLN('			 	</font>')
						oXlsFile:nWriteLN('			</td>')   
					endif
	 				oXlsFile:nWriteLN('		</tr>')
 				endif				
 				//Fim
 				
 				oXlsFile:nWriteLN('		<tr>')
 				oXlsFile:nWriteLN('			<td>') 				 				
 				oXlsFile:nWriteLN('			</td>') 				
 				oXlsFile:nWriteLN('		</tr>')
		endif
		oPComp:_Next()
	end

	oXlsFile:nWriteLN('	</table>')
	oXlsFile:nWriteLN('</body>')   
	oXlsFile:nWriteLN('</html>')   
	oXlsFile:lClose()

return nStatus
     
/**
* Formata um número com o número de casas decimais desejadas. 
* @param nValue Valor numérico a ser formatado.
* @param nCasaDecimal  Número de casas decimais desejadas.
* @peturn (Caracter) Valor formatado.
*/    
method cFormatNumber(nValue, nCasaDecimal) class TKPI043  
	Local cRet 
    
    Default nCasaDecimal 	:= 0
    Default nValue 			:= 0

    If (nCasaDecimal == 0)
     	cRet := Transform(nValue, "@E 999,999,999,999")     	
    Else
    	cRet := Transform(nValue, "@E 999,999,999,999" + "." + Replicate("9",nCasaDecimal)) 
    EndIf
       	  
return cRet

function _KPI043_PainelComp()
return nil