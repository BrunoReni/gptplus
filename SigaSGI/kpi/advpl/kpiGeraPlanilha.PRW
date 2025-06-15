// ######################################################################################
// Projeto: KPI
// Modulo : Geração de planilha para o agendamento
// Fonte  : KPIExportData.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.01.06 | 2487 Eduardo Konigami Miyoshi
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPIGeraPlanilha.ch"

/*--------------------------------------------------------------------------------------
@class TKPI053
@entity RelScoreInd
Relatório Scorecards e Indicadores
@table KPI053
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GERAPLANILHA"
#define TAG_GROUP  "GERAPLANILHAS"
#define TEXT_ENTITY STR0001/*//"Geração da Planilha para a importação."*/
#define TEXT_GROUP  STR0002/*//"Geração daa Planilhaa para as importações."*/

#define ORDEM_ID		1
#define ORDEM_CODCLI	2
#define ORDEM_NOME		3

class TKPIGeraPlanilha from TBITable
	method New() constructor
	method NewKPIExportData()

	// registro atual
	method oToXMLNode(nParentID)   
	method oGetScore()     
	method oSimpleGetChild()         
	method oRecursiveGetChild(cEnabled,cSelected)
	
	// executar 
	method nExecute(cID, cExecCMD)
	method delFile(cNameFile)      

endclass

method New() class TKPIGeraPlanilha
	::NewKPIExportData()
return

method NewKPIExportData() class TKPIGeraPlanilha
	::NewObject()
return

// Carregar
method oToXMLNode() class TKPIGeraPlanilha
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)  

	// Acrescenta children
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.t.))
	oXMLNode:oAddChild(TBIXMLNode():New("SCORESELECTED", {}))
	oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oXMLTipoAtualizacao())  
	
//	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oArvore(.T.,"0",.T., {}))
	oXMLNode:oAddChild(::oGetScore())
	
return oXMLNode

// Execute
method nExecute(cID, cExecCMD) class TKPIGeraPlanilha
	local nStatus 	:= KPI_ST_OK
	local aParms 	:= aBiToken(cExecCMD, "|")
	local aExec		:= {}
	
	if aParms[1] == "DELFILE"
		 ::delFile(aParms[2])
	elseif aParms[1] == "IMPORTFILE"
		aadd(aExec, ::oOwner():cKpiPath())
		aadd(aExec, iif(empty(aParms[2]), ::oOwner():cKpiPath(),aParms[2])) 
		StartJob("kpiImportData",GetEnvServer(),.t.,aExec)
	else
		KPIGeraPlanilha(aParms)
	endif
return nStatus        


//Deletar arquivo a ser importado
method delFile(cNameFile) class TKPIGeraPlanilha    
local oFile := TBIFileIO():New(::oOwner():cKpiPath() + "\sgiimport\" + cNameFile )     

	if oFile:lExists() 
		oFile:lErase()
	endif
return

// Funcao executa o job
function KPIGeraPlanilha(aParms)
	local oIndicador		:= oKpiCore:oGetTable("INDICADOR")
	local oDepto			:= oKpiCore:oGetTable("SCORECARD")
	local oPlanilha			:= oKpiCore:oGetTable("PLANILHA")
	local oParametro		:= oKpiCore:oGetTable("PARAMETRO")	
	local cPeriodoDe, cDiretorio, cPeriodoAte
	local aInds := {}, dProxData
	local oXlsFile, nContador, nTipoOrdem
	local nPos, dDataAtual
	local cScorecards		:= ""
	local cValor 			:= ""
	local cMeta 			:= ""
	local cPrevia 			:= "" 
	local cSQLTemp			:= ""	
	local cFiltroFormula	:= ""  	
	local nFiltroAtualiza	:= "" 
	local lExportaValor		:= .f.
	local lValorPrevio		:= .f.
	local nFiltroFormula	:= 0
	local nCasaDec 			:= 0	
	local nValor 			:= 0
	local nMeta				:= 0
	local nPrevia 			:= 0  
	local cNomeDpto			:= "" 
	local cIdDpto			:= ""
	
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif
    
    //1 - Período de
    cPeriodoDe		:= aParms[1]
    //2 - Periodo ate
    cPeriodoAte		:= aParms[2]
    //3 - Scorecards
    cScorecards 	:= aParms[3]
    //4 - Tipo da ordenação
    nTipoOrdem 		:= aParms[4]
    //5 - Diretorio de gravacao
	 cDiretorio	:= "\sgiExport\"
    //6 - Exporta Valores?
    lExportaValor	:= aParms[6]
    //7 - Tipo do filtro para as formulas?
    nFiltroFormula	:= aParms[7]
    //8 - Tipo do filtro para a atualizacao
    nFiltroAtualiza := aParms[8]

	oKpiCore:Log(STR0003 + "sgiexport002.xls]", KPI_LOG_SCRFILE)/*//"Iniciando geração da planilha [Planilha_para_Importacao_"*/
	oXlsFile	:= TBIFileIO():New(oKPICore:cKpiPath()+ cDiretorio + "sgiexport002.xls")  
	
	
	// Cria o arquivo xls
	If ! oXlsFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0011 + "sgiexport002.xls]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [Planilha_para_Importacao_"*/
		oKPICore:Log(STR0012, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif	
	
	if(nTipoOrdem == ORDEM_ID)
		oIndicador:setOrder(1)
	elseif(nTipoOrdem == ORDEM_CODCLI)
		oIndicador:setOrder(6)
	else
	
		oIndicador:setOrder(5)
	endif

	if(cScorecards=="'-1'")
		cSQLTemp := "IND_ESTRAT = 'F'"
	else
		cSQLTemp := "ID_SCOREC IN (" + cScorecards + ") AND IND_ESTRAT = 'F'"
	endif

	if(! empty(cFiltroFormula))
		cSQLTemp += cFiltroFormula
	endif

	if(!empty(nFiltroAtualiza))
		cSQLTemp += " AND TIPO_ATU = '"+cBiStr(nFiltroAtualiza)+"'"
	endif

	oIndicador:cSQLFilter(cSQLTemp)
	oIndicador:lFiltered(.t.)
	oIndicador:_First()
	
	while(! oIndicador:lEof())
		if(oIndicador:nValue("ID") != 0)                                 
		
			if lFiltroFormula(nFiltroFormula, oIndicador:cValue("FORMULA")) 
	            
	            if !(cIdDpto == oIndicador:cValue("ID_SCOREC"))
		     		cIdDpto	:= oIndicador:cValue("ID_SCOREC")
			   		if oDepto:lSeek(1,{cIdDpto} )
			   			cNomeDpto := oDepto:cValue("NOME")
			   		else                                  
			   			cNomeDpto := ""
			   		endif
			   	endif	
			
				aAdd(aInds, {	oIndicador:cValue("ID"), ;
								oIndicador:cValue("ID_CODCLI"), ;
								"PERIODO", ;
								cNomeDpto + " - " + oIndicador:cValue("NOME"), ;
								oIndicador:nValue("FREQ"), ;
								oIndicador:nValue("DECIMAIS") })
			endif
		endif
		oIndicador:_Next()
	enddo
	oIndicador:cSQLFilter("")

	// Montagem do cabeçalho do relatlório
	oXlsFile:nWriteLN('<html>')
	oXlsFile:nWriteLN('<head>')
	oXlsFile:nWriteLN('	<title>'+"AAAAAAAAAAAAAAAA"+'</title>')
	oXlsFile:nWriteLN('	<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
	oXlsFile:nWriteLN('</head>')

	oXlsFile:nWriteLN('<body>')
	
	oXlsFile:nWriteLN('	<table width="80%" align="left" border="0" cellpadding="0" cellspacing="0">')
	oXlsFile:nWriteLN('		<tr>')
	oXlsFile:nWriteLN('			<td align="center" width="16%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0005)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')
	oXlsFile:nWriteLN('			<td align="center" width="16%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0006)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')
	oXlsFile:nWriteLN('			<td align="center" width="16%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0007)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')
	oXlsFile:nWriteLN('			<td align="center" width="16%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0008)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')
	oXlsFile:nWriteLN('			<td align="center" width="16%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0009)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')
	oXlsFile:nWriteLN('			<td align="center" width="20%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0010)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')    
	oXlsFile:nWriteLN('			<td align="center" width="20%">')
	oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
	oXlsFile:nWriteLN(					STR0015)
	oXlsFile:nWriteLN('				</font></strong>')
	oXlsFile:nWriteLN('			</td>')    
	if(lValorPrevio)
		oXlsFile:nWriteLN('			<td align="center" width="20%">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(				 	STR0014)
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
	endif
	oXlsFile:nWriteLN('		</tr>')
	
	for nPos := 1 to len(aInds)
		dDataAtual	:=	ctod(cPeriodoDe)
		dProxData	:=	ctod(cPeriodoDe)
		nContador	:= 1
		//if(oPlanilha:lSoftSeek(2, { alltrim(aInds[nPos][1]) }))
		//	oPlanilha:aGetIndValores()
		//oPlanilha:_First()
		 
		do while (dDataAtual >= ctod(cPeriodoDe)  .and. dDataAtual < ctod(cPeriodoAte)) .or. nContador == 1
			cValor	:= ""
			cMeta	:= ""
			cPrevia	:= ""
			if(dProxData == dDataAtual  .or. ;
				!oIndicador:lCompDataFreq(aInds[nPos][5],dDataAtual,dProxData))
		        if(lExportaValor)
			        aDataValor := oPlanilha:aDateConv(dProxData, aInds[nPos][5])
			        if(oPlanilha:lSeek(2, { aInds[nPos][1], aDataValor[1], aDataValor[2], aDataValor[3] }))
						nCasaDec:= aInds[nPos][6]
						nValor	:=	Round(oPlanilha:nValue("VALOR"),nCasaDec)
						nMeta	:=	Round(oPlanilha:nValue("META"),nCasaDec)
						nPrevia	:=	Round(oPlanilha:nValue("PREVIA"),nCasaDec)
						//-----------------------------------\\									
			        	cValor	:=	nFormatVlr(nValor,nCasaDec) 
			        	cMeta	:= 	nFormatVlr(nMeta,nCasaDec) 
			        	cPrevia	:= 	nFormatVlr(nPrevia,nCasaDec) 
			        endif
			 	endif
				//	aValores := oIndicador:aGetIndValores(dDataAtual, dDataAtual, ctod(cPeriodoAte))
				//endif
		        oXlsFile:nWriteLN('		<tr>')
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(alltrim(aInds[nPos][1]))
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(alltrim(aInds[nPos][2]))
				oXlsFile:nWriteLN('</font>')
				oXlsFile:nWriteLN('			</td>')
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN('&nbsp; ' +	dtoc(dProxData) + '&nbsp;')
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(					alltrim(cValor))
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(					alltrim(cMeta))
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
				oXlsFile:nWriteLN('			<td align="left">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(					aInds[nPos][4])
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>') 
				oXlsFile:nWriteLN('			<td align="left">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				oXlsFile:nWriteLN(					"F")
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
				if(lValorPrevio)
					oXlsFile:nWriteLN('			<td align="center">')
					oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
					oXlsFile:nWriteLN(					alltrim(cPrevia))
					oXlsFile:nWriteLN('				</font>')
					oXlsFile:nWriteLN('			</td>')
				endif
				oXlsFile:nWriteLN('		</tr>')
				nContador++	
			endif
			
			dDataAtual		:= dProxData
			dProxData		:= dDataAtual + 1
		end while
				
	next nPos
		
	oXlsFile:nWriteLN('	</table>')
	
	oXlsFile:nWriteLN('</body>')
	oXlsFile:nWriteLN('</html>')
               
	//Faz a copia do relatorio para o diretorio de Spool
	oXlsFile:lCopyFile(cDiretorio, oKpiCore:cKpiPath())
	oXlsFile:lClose()
	oKpiCore:Log(STR0004+"sgiexport002]", KPI_LOG_SCRFILE)/*//"Finalizando geração da Planilha ["*/

return  

static function nFormatVlr(nVlr, nCasaDec)
	local nVlrFrmt := 0
	
	if (nCasaDec > 0 )
		nVlrFrmt := transform(nVlr, "@E 999999999999." + replicate("9",nCasaDec))
	else
		nVlrFrmt := transform(nVlr, "@E 999999999999")	
	endif
	
	nVlrFrmt := alltrim(nVlrFrmt)

return nVlrFrmt  

static function lFiltroFormula(nFiltroFormula, cFormula)    
local lRet := .t.

	do case
		case nFiltroFormula == 0 //"FORMULA IS NULL"
  			if len(cFormula) > 1
  				lRet := .f.
  			else       
  				lRet := .t.
  			endif
		case nFiltroFormula  == 1 //"FORMULA IS NOT NULL"
			if len(cFormula) > 1
  				lRet := .t.
  			else       
  				lRet := .f.
  			endif
		otherwise
			lRet := .t.
	endcase
	
return lRet

method oGetScore() class TKPIGeraPlanilha
	Local oXMLArvore	:= Nil	
	Local oTreeNode 	:= Nil 
	Local cEnabled		:= "True"
	Local cSelected		:= "False"
	Local oParametro 	:= ::oOwner():oGetTable("PARAMETRO")
	Local lRecursive	:= xBIConvTo("L", oParametro:getValue("PERMISSAO_RECURSIVA") )               
	
	Private oSco		:= ::oOwner():oGetTable("SCORECARD") 
           
	//Ordena pela Ordem depois por ID. 
	oSco:SetOrder(6)
	oSco:_First()   
	
	if(! oSco:lEof())

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "0")
		oAttrib:lSet("TIPO", "DPTS")
		oAttrib:lSet("NOME", "Entidade")
		oAttrib:lSet("ENABLED", cEnabled)
		oAttrib:lSet("SELECTED", cSelected)          
		oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )		
		oXMLArvore := TBIXMLNode():New("DPTS","",oAttrib)
                        
		while(!oSco:lEof())
			
			if ( !(alltrim(oSco:cValue("ID")) == "0") .and. Empty(oSco:cValue("PARENTID")))
				oSco:SavePos()

				If (lRecursive )  
					oTreeNode := ::oRecursiveGetChild(cEnabled,cSelected)  
				Else
					oTreeNode := ::oSimpleGetChild()
				EndIf 
		
				if !( oTreeNode == Nil )    
					oXMLArvore:oAddChild(oTreeNode)  
				endif 
				
				oSco:SetOrder(1)
				oSco:RestPos()  
				
			endif				
			oSco:_Next()
		enddo                                                     
	endif

return oXMLArvore                            

method oSimpleGetChild() class TKPIGeraPlanilha
	local cId 			:= ""
	local cParentID 	:= ""  
	local cEnabled 		:= "True" 	
	local cSelected     := "False"    
	local nRec 			:= 0
	local oNode			:= Nil
	local oXMLNode		:= Nil
	local oAttrib   	:= Nil
	Local cOrdem		:= ""   
	
	oSco:SetOrder(5) 
	nRec := oSco:nRecno()   
	
	cParentID 	:= oSco:cValue("PARENTID")
	cId			:= oSco:cValue("ID")
	cOrdem 		:= Padl(AllTrim(oSco:cValue("ORDEM")),3,"0")       
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID"		, cID)
	oAttrib:lSet("NOME"		, alltrim(oSco:cValue("NOME")))
	oAttrib:lSet("ENABLED"	, cEnabled)
	oAttrib:lSet("SELECTED"	, cSelected)
	oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )
	
	oXMLNode := TBIXMLNode():New("DPTS" + "." + cOrdem + "." + alltrim(cID),"",oAttrib)	
	
	if oSco:lSeek(2,{cID}) 
		while(oSco:cValue("PARENTID") == cID .and. ! oSco:lEof())                 
			if oSco:lSeek(1, {oSco:cValue("ID")}) 
				oNode := ::oSimpleGetChild()
				if !oNode==nil 
					if oXMLNode==nil   
						oXMLNode:= oNode
					else                         
						oXMLNode:oAddChild(oNode)
					endif
				endif
			endif    
			oSco:_Next()
		enddo		
	endif

	oSco:lGoTo(nRec)

return oXMLNode    

method oRecursiveGetChild(cEnabled,cSelected) class TKPIGeraPlanilha
	local cId 			:= ""
	local cParentID 	:= ""     
	local nRec 			:= 0     
	local cEnabled 		:= "True" 	
	local cSelected     := "False"  
	local oNode			:= nil
	local oXMLNode		:= nil
	local oAttrib   	:= nil
	Local cOrdem 		:= ""   
	
	oSco:SetOrder(5) 
	nRec := oSco:nRecno()   
	
	cParentID 	:= oSco:cValue("PARENTID")
	cId			:= oSco:cValue("ID")
	cOrdem 		:= Padl(AllTrim(oSco:cValue("ORDEM")),3,"0")           
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID"		, cID)
	oAttrib:lSet("NOME"		, alltrim(oSco:cValue("NOME")))
	oAttrib:lSet("ENABLED"	, cEnabled)
	oAttrib:lSet("SELECTED"	, cSelected)
	oAttrib:lSet("DESCRICAO", alltrim(oSco:cValue("DESCRICAO")))
	oAttrib:lSet("PARENTID"	, oSco:cValue("PARENTID") )  
	oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )
	
	oXMLNode := TBIXMLNode():New("DPTS" + "." + cOrdem + "." + alltrim(cID),"",oAttrib)	         

	if oSco:lSeek(2,{cID}) //Tem nos filhos
		while(oSco:cValue("PARENTID") == cID .and. ! oSco:lEof())                 
			if oSco:lSeek(1, {oSco:cValue("ID")}) 
				oNode := ::oRecursiveGetChild(cEnabled , cSelected)
				if !oNode==nil 
					if oXMLNode==nil   
						oXMLNode:= oNode
					else                         
						oXMLNode:oAddChild(oNode)
					endif
				endif
			endif    
			oSco:_Next()
		enddo		
	endif

	oSco:lGoTo(nRec)

return oXMLNode