// ######################################################################################
// Projeto: KPI
// Modulo : Relatório com Estatística de Planos de Ações de Indicadores
// Fonte  : KPI053_EstatisticaPlan.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 30.01.06 | 2487 Eduardo Konigami Miyoshi
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI054_EstatisticaPlan.ch"

/*--------------------------------------------------------------------------------------
@class TKPI054
@entity RELESTATPLAN
Relatório com Estatísticas de Plano de Ações de Indicadores
@table KPI054
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELESTATPLAN"
#define TAG_GROUP  "RELESTATPLANS"
#define TEXT_ENTITY STR0001/*//"Relatório com Estatísticas de Plano de Ações de Indicadores"*/
#define TEXT_GROUP  STR0002/*//"Relatórios com Estatísticas de Planos de Ações de Indicadores"*/

class TKPI054 from TBITable
	method New() constructor
	method NewKPI054()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLStatus()
	method oXMLTipoImprimir()

	// registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
	// executar 
	method nExecute(cID, cExecCMD)
	
	//faz a carga da base, quando é executado pelo primeira vez
	method carregaTabela()
	
	//calculo dos resultados
	method nCalculaVencido(cIdInd)
	method nPercFinVenc(cIdInd)
	method nTotalAcoes(cIdInd)
	method nTotalFin(cIdInd)
	method nCalcPorcentagem(cIdInd)
endclass

method New() class TKPI054
	::NewKPI054()
return
method NewKPI054() class TKPI054
	
	// Table
	::NewTable("SGI054")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"C", 10))
	::addField(TBIField():New("PARENTID",	"C", 10))
	::addField(TBIField():New("NOME",		"C", 60))
	::addField(TBIField():New("DESCRICAO",	"C", 255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	::addField(TBIField():New("ID_SCORE",	"C", 10))
    

	// Indexes
	::addIndex(TBIIndex():New("SGI054I01",	{"ID"},		.t.))
	
return

// Arvore
method oArvore(nParentID) class TKPI054
	local oXMLArvore, oNode
	
	::SetOrder(1) // Por ordem de ID
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "0")
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TKPI054
	local aFields, oNode, oAttrib, oXMLNode, nInd

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
	::SetOrder(2) // Por ordem de Nome
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","DESCRICAO","IMPDESC","ID_SCORE"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Carregar
method oToXMLNode() class TKPI054
	local aFields, nInd, nStatus := KPI_ST_OK
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	::SetOrder(1) // Por ordem de ID
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", "0"}}))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif

	if nStatus == KPI_ST_OK
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY,{})
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			endif	
		next
	endif
	
	//Indica se o usuario logado e administrador.
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN", ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")))

	// Acrescenta children
	//oXMLNode:oAddChild(::oOwner():oGetTable("INDICADOR"):oToXMLList())
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI054
	local nStatus := KPI_ST_OK,	nID, nInd, oTable, cNome
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif
	next

	// Verifica condições de gravação (append ou update)
	::SetOrder(1) // Por ordem de ID
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", "0"} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif
return nStatus

// Execute
method nExecute(cID, cExecCMD) class TKPI054
	local aParms := {} 
	local cPathSite	:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	private nStatus := KPI_ST_OK
	if(::lSeek(1, {cID})) // Posiciona no ID informado

		// 1 | 2 - Nome do arquivo gerado | Indicadores
		aParms := aBiToken(cExecCMD, "|")
		// 3 - KPIPATH da Working THREAD
		aAdd(aParms, ::oOwner():cKpiPath())
		// 4 - Diretorio do site.
		aAdd(aParms, strtran(cPathSite,"\","/"))
		// 5 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))
		// 6 - Descricao
		aAdd(aParms, alltrim(::cValue("DESCRICAO")))
		// 7 - Imprime descrição
		aAdd(aParms, ::lValue("IMPDESC"))
		// 8 - Id do Scorecard
		aAdd(aParms, alltrim(::cValue("ID_SCORE")))
		// 9 - Id
		aAdd(aParms, alltrim(::cValue("ID")))
		
		// Executando JOB
		//StartJob("KPIEstatPlanJob", GetEnvServer(), .f., aParms)
		nStatus := KPIEstatPlanJob(aParms)
		if(nStatus == KPI_ST_OK)
			::fcMsg := STR0016
		elseif(nStatus == KPI_ST_GENERALERROR)
			::fcMsg := STR0017
		endif
	
	else

		nStatus := 	KPI_ST_BADID

	endif

return nStatus

// Funcao executa o job
function KPIEstatPlanJob(aParms)
	local cNome, cDescricao, lImpDesc, cScorecard, aInd := {}
	local nRegistros := 0, cIdIndicador := "", nVencidas, nFinVenc, nAtraVenc, nTotalAcoes, nFinTot
	local cKpiPath, cReportName, cId, cSitePath
	local oScorecard, oIndicador
	local oHtmFile        
	local cHierarq

 	public oKPICore, cKPIErrorMsg := ""
 	
 	// Coleta os parametros
	
	// 1 - Nome do arquivo que sera salvo, nome do userDe e nome do userAte
	cReportName := aParms[1]
	// 2 - Indicadores
	if!(valType(aParms[2]) == "C")
		aParms[2] := alltrim(str(aParms[2]))
	endif
	aInd 		:= aBiToken(aParms[2], ",", .f.)
    // 3 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[3]
	// 8 - Diretório do site
    cSitePath	:= aParms[4]
	// 5 - Nome
	cNome		:= aParms[5]
	// 6 - Descrição
	cDescricao 	:= aParms[6]
	// 7 - Imprime Descrição?
	lImpDesc	:= aParms[7]
	// 8 - Scorecard
	cScorecard	:= aParms[8]
	// 9 - ID do Relatório
	cId			:= aParms[9]
	
	oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL054_" + alltrim(cID) + ".html")

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0004 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL054_"*/
		oKPICore:Log(STR0005, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return KPI_ST_GENERALERROR
	endif
		
	cCorInd		 	:= "#C6E2FF" //cor da tabela de Indicadores
	cCorCabecalho	:= "#aca6d2" //cor dos cabeçalhos
	cCorRespImp		:= "#e2e1f2" //cor dos resultados
	cCorRespPar		:= "#d3d1e9" //cor dos resultados
		
	// Montagem do cabeçalho do relatório
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('	<title>' + STR0007 + '</title>')
	oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
    oHtmFile:nWriteLN('<link href="'+cSitePath+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	oHtmFile:nWriteLN('</head>')
	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	oScorecard := oKPICore:oGetTable("SCORECARD")
	oIndicador := oKPICore:oGetTable("INDICADOR")
	oEstatPlan := oKPICore:oGetTable("RELESTATPLAN")
	
	while(nRegistros < len(aInd))
		nRegistros++
		//se for o primeiro registro, imprime o cabecalho
		if(nRegistros==1)
			oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('	<tr>')
			oHtmFile:nWriteLN('		<td>')
			oHtmFile:nWriteLN('			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela">')
			oHtmFile:nWriteLN('				<tr>')
			oHtmFile:nWriteLN('					<td class="tdlogo"><img class="imglogo" src="'+cSitePath+'imagens/art_logo_clie.sgi"></td>')
			oHtmFile:nWriteLN('					<td class="titulo" align="center">' + STR0001 + '<br>')
			if(lImpDesc)
				oHtmFile:nWriteLN('					<strong><span class="texto">'+ cDescricao +'</span></strong></td>')
			endif				
			oHtmFile:nWriteLN('					<td width="150" align="right" valign="top" class="texto">'+STR0007+ dtoc(date()) + '</td>')
			oHtmFile:nWriteLN('				</tr>')
			oHtmFile:nWriteLN('			</table>')
			oHtmFile:nWriteLN('		</td>')
			oHtmFile:nWriteLN('	</tr>')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td>&nbsp;</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
		    lCabecalho := .t.
			oHtmFile:nWriteLN('<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" class="tabela">')  
			oHtmFile:nWriteLN('	<tr align="center" height="25">')
			oHtmFile:nWriteLN('		<td class="cabecalho_1"></td>')
			oHtmFile:nWriteLN('		<td colspan="3" class="cabecalho_1">')
			oHtmFile:nWriteLN(			STR0010)
			oHtmFile:nWriteLN('		&nbsp;</td>')
			oHtmFile:nWriteLN('		<td colspan="2" class="cabecalho_1">')
			oHtmFile:nWriteLN(			STR0011)
			oHtmFile:nWriteLN('		&nbsp;</td>')
			oHtmFile:nWriteLN('	</tr>')
			oHtmFile:nWriteLN('	<tr align="center" height="25">')
			oHtmFile:nWriteLN('		<td width="30%" class="cabecalho_2"><strong>')
			
			oScorecard:_first()
			if(oScorecard:lSeek(1, {cScorecard}))

				//PEGA A HIERARQUIA A SER EXIBIDA - CASO SEJA VAZIA, FICA A PADRAO
				cHierarq := oScorecard:cGetScoreName(oScoreCard:cValue("ID"))
				
				oHtmFile:nWriteLN( cHierarq )

			endif
			
			oHtmFile:nWriteLN('		&nbsp;</strong></td>')
			oHtmFile:nWriteLN('		<td width="14%" class="cabecalho_2"><strong>')
			oHtmFile:nWriteLN(			STR0012)
			oHtmFile:nWriteLN('		&nbsp;</strong></center></td>')
			oHtmFile:nWriteLN('		<td width="14%" class="cabecalho_2"><strong>')
			oHtmFile:nWriteLN(			STR0013)
			oHtmFile:nWriteLN('		&nbsp;</strong></td>')
			oHtmFile:nWriteLN('		<td width="14%" class="cabecalho_2"><strong>')
			oHtmFile:nWriteLN(			STR0014)
			oHtmFile:nWriteLN('		&nbsp;</strong></td>')
			oHtmFile:nWriteLN('		<td width="14%" class="cabecalho_2"><strong>')
			oHtmFile:nWriteLN(			STR0015)
			oHtmFile:nWriteLN('		&nbsp;</strong></td>')
			oHtmFile:nWriteLN('		<td width="14%" class="cabecalho_2"><strong>')
			oHtmFile:nWriteLN(			STR0013)
			oHtmFile:nWriteLN('		&nbsp;</strong></td>')
			oHtmFile:nWriteLN('	</tr>')
		endif
		if((nRegistros % 2) == 1 )
			oHtmFile:nWriteLN('	<tr height="20" class="texto2">')
		else
			oHtmFile:nWriteLN('	<tr height="20" class="texto">')
		endif
		oHtmFile:nWriteLN('			<td width="30%">')
		cIdIndicador := alltrim(aInd[nRegistros])
		if(oIndicador:lSeek(1, { cIdIndicador } ))
			oHtmFile:nWriteLN(			alltrim(oIndicador:cValue("NOME")))
		endif
		
		nVencidas 	:= oEstatPlan:nCalculaVencido( cIdIndicador)
		nFinVenc	:= oEstatPlan:nPercFinVenc( cIdIndicador )
		nAtraVenc	:= nVencidas - nFinVenc
		nTotalAcoes	:= oEstatPlan:nTotalAcoes( cIdIndicador )
		nFinTot		:= oEstatPlan:nTotalFin( cIdIndicador )
		
		oHtmFile:nWriteLN('			&nbsp;</td>')
		oHtmFile:nWriteLN('	   		<td width="14%" align="center">')
		oHtmFile:nWriteLN(				alltrim(str(nVencidas)))
		oHtmFile:nWriteLN('			&nbsp;</td>')
		oHtmFile:nWriteLN('			<td width="14%" align="center">')
		oHtmFile:nWriteLN(				str(oEstatPlan:nCalcPorcentagem(nVencidas, nFinVenc)))
		oHtmFile:nWriteLN('			&nbsp;</td>')
		oHtmFile:nWriteLN('			<td width="14%" align="center"">')
		oHtmFile:nWriteLN(				str(oEstatPlan:nCalcPorcentagem(nVencidas, nAtraVenc)))
		oHtmFile:nWriteLN('			&nbsp;</td>')
		oHtmFile:nWriteLN('			<td width="14%" align="center">')
		oHtmFile:nWriteLN(				alltrim(str(nTotalAcoes)))
		oHtmFile:nWriteLN('			&nbsp;</td>')
		oHtmFile:nWriteLN('			<td width="14%" align="center">')
		oHtmFile:nWriteLN(				str(oEstatPlan:nCalcPorcentagem(nTotalAcoes, nFinTot)))
		oHtmFile:nWriteLN('			&nbsp;</td>')
		oHtmFile:nWriteLN('		</tr>')
		oScorecard:_next()
	enddo
	// Fim table 1
	oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('<br><br>')
	if(nRegistros == 0)
		// Montagem do rodap&eacute; do relat&oacute;rio 
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		STR0008)
		oHtmFile:nWriteLN('	</font>')
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		STR0009)
		oHtmFile:nWriteLN('	</font>')
	endif
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
               
	//Faz a copia do relatorio para o diretorio de Spool
	oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + cReportName, oKPICore:cKpiPath())
	oHtmFile:lClose()
	oKPICore:Log(STR0006+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
return nStatus

method carregaTabela() class TKPI054
	if(::nRecCount() == 0)
		::lAppend({ {"ID", "1"}, {"PARENTID", ""}, {"NOME", ""}, {"DESCRICAO", ""}, {"IMPDESC", .f.}, {"ID_SCORE", ""} })
	endif  
return

/*
 *Calcula o valor do campo Vencidos
 */
method nCalculaVencido(cIdInd) class TKPI054
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()
	
	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016"
	cSql +=	" WHERE ID_IND='"+ cIdInd +"' AND DATAFIM<'"+ dtos(date()) +"' AND D_E_L_E_T_<>'*'"
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula o valor do campo % Finalizadas Vencidas
 */
method nPercFinVenc(cIdInd) class TKPI054
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_IND='"+ cIdInd +"' AND DATAFIM<'"+ dtos(date()) + "' AND STATUS='3' AND D_E_L_E_T_<>'*'"//Status 3 - Executada
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula o valor do campo Total de Ações
 */
method nTotalAcoes(cIdInd) class TKPI054
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_IND='"+ cIdInd +"'  AND D_E_L_E_T_<>'*'"
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

method nTotalFin(cIdInd) class TKPI054
	local nValorAcum := 0
	
	//Para efeito de melhoria de performance a soma dos planos vencidos e realizada via comando SQL.
	cOldAlias := alias()

	cSql :=	"SELECT COUNT(ID)"
	cSql +=	" FROM SGI016" 
	cSql +=	" WHERE ID_IND='"+ cIdInd +"' AND STATUS='3' AND D_E_L_E_T_<>'*'"//Status 3 - Executada
			
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
	nValorAcum := FieldGet(1)
	dbCloseArea()
	dbSelectArea(cOldAlias)

return nValorAcum

/*
 *Calcula a porcentagem
 */
method nCalcPorcentagem(nTotal, nValor) class TKPI054
	local nPorcentagem := 0
	if(nTotal != 0)
		nPorcentagem := round( ( (nValor*100)/nTotal ), 2 )
	endif
return nPorcentagem