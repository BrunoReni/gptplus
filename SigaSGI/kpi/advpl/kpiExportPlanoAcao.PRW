// ######################################################################################
// Projeto: KPI
// Modulo : Geração de planilha de Planos de Ações
// Fonte  : KPIExportPlanoAcao.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.01.06 | 2487 Eduardo Konigami Miyoshi
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPIExportPlanoAcao.ch"

/*--------------------------------------------------------------------------------------
@class TKPI053
@entity RelScoreInd
Relatório Scorecards e Indicadores
@table KPI053
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "EXPORTPLAN"
#define TAG_GROUP  "EXPORTPLANS"
#define TEXT_ENTITY STR0001 //"Geração da Planilha de Plano de Ação."
#define TEXT_GROUP  STR0002 //"Geração das Planilhas de Planos de Ações."

#define ORDEM_ID		1
#define ORDEM_CODCLI	2
#define ORDEM_NOME		3

class TKPIExportPlanoAcao from TBITable
	method New() constructor
	method NewKPIExportPlanoAcao()

	// registro atual
	method oToXMLNode(nParentID)
	method oXMLStatus()
	method oXMLSituacao()
	method oXMLTipoAcao()
	
	// executar 
	method nExecute(cID, cExecCMD)
endclass

method New() class TKPIExportPlanoAcao
	::NewKPIExportPlanoAcao()
return

method NewKPIExportPlanoAcao() class TKPIExportPlanoAcao
	::NewObject()
return

// Carregar
method oToXMLNode() class TKPIExportPlanoAcao
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	
	// Acrescenta children
	oXmlResp := ::oOwner():oGetTable("USUARIO"):oToXMLList(.F.)
	oXMLNode:oAddChild(oXmlResp)
	oXMLNode:oAddChild(oXmlResp)
	oXMLNode:oAddChild(::oXMLStatus())
	oXMLNode:oAddChild(::oXMLSituacao())  
	oXMLNode:oAddChild(::oXMLTipoAcao())
return oXMLNode

// Status
method oXMLStatus() class TKPIExportPlanoAcao
	Local oAttrib 	 := TBIXMLAttrib():New()
	Local oNode 	 := Nil
	Local oXMLOutput := Nil
	local nInd		 := 0
	Local aStatus 	 := { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008 } //###"Näo Iniciada" # "Em Execucäo" # "Realizada" # "Esperando" # "Adiada" # "Cancelada"
	
	// Atributos
	oAttrib:lSet("RETORNA", .F.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("LSTSTATUS",,oAttrib)

	for nInd := 1 to len(aStatus)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("LSTSTATUS"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aStatus[nInd]))
	next
return oXMLOutput

// Situacao / Situacao do Plano de Ação (Vencidos e A vencer)
method oXMLSituacao() class TKPIExportPlanoAcao
	local oAttrib	 := TBIXMLAttrib():New()
	Local oNode		 := Nil
	Local oXMLOutput := Nil
	Local oParametro := ::oOwner():oGetTable("PARAMETRO")
	Local aSituacao	 := {}
	Local nInd		 := 0
	Local nPrazoVenc := 7

	if (oParametro:lSeek(1, {"PRAZO_PARA_VENC"}))
		nPrazoVenc := oParametro:nValue("DADO")
	endif
	
	if (nPrazoVenc > 1)
		aSituacao := { STR0009, STR0010 + alltrim( str( nPrazoVenc ) ) + STR0012 } //"Vencidos"###"A vencer em "###" dias"
	else
		aSituacao := { STR0009, STR0010 + alltrim( str( nPrazoVenc ) ) + STR0011 } //"Vencidos"###"A vencer em "###" dia"
	endif
	
	// Atributos
	oAttrib:lSet("RETORNA", .F.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("LSTSITUACAO", , oAttrib)

	for nInd := 1 to len(aSituacao)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aSituacao[nInd]))
	next
return oXMLOutput  

//Ações de Indicadores / Ações de Projetos
method oXMLTipoAcao() class TKPIExportPlanoAcao
	local oAttrib 	:= TBIXMLAttrib():New()
	Local oNode 	:= Nil
	Local oXMLNode 	:= Nil
	Local nI		:= 0    
	local aItens 	:= { {01, STR0037} ,; //"Ações de Indicadores"	
						 {02, STR0038} }  //"Ações de Projetos"

	// Atributos
	oAttrib:lSet("RETORNA", .F.)    

	// Tag pai
	oXMLNode := TBIXMLNode():New("LSTTIPOACAO", , oAttrib)
    
	For nI := 1 To Len( aItens ) 
		oNode := oXMLNode:oAddChild(TBIXMLNode():New("TIPOACAO"))
		oNode:oAddChild(TBIXMLNode():New("ID", aItens[nI][1]))		
		oNode:oAddChild(TBIXMLNode():New("NOME", aItens[nI][2]))                           
	Next
return oXMLNode

// Execute
method nExecute(cID, cExecCMD) class TKPIExportPlanoAcao
	local nStatus := KPI_ST_OK
	local aParms := {} 
	
	aParms := aBiToken(cExecCMD, "|")
	KPIExporPlanoAcao(aParms)
return nStatus

// Funcao executa o job
function KPIExporPlanoAcao(aParms)
	local oPlano		:= oKpiCore:oGetTable("PLANOACAO")
	local oIndicador	:= oKpiCore:oGetTable("INDICADOR")
	local oUsuario		:= oKpiCore:oGetTable("USUARIO")
	local oScorecard	:= oKpiCore:oGetTable("SCORECARD")    
	local oProjeto		:= oKpiCore:oGetTable("PROJETO")
	local oParametro	:= oKPICore:oGetTable("PARAMETRO")
	local cSituacao		:= "" //Situação
	Local cStatus		:= "" //Status
	Local cTipoAcao		:= "" //Tipo
	Local cDiretorio	:= "\sgiExport\" //Diretorio de gravacao do arquivo
	local cFiltro 		:= ""
	Local cRespFilter 	:= ""
	Local aResps		:= {} //Responsáveis
	Local aStatus 		:= { STR0003, STR0004, STR0005, STR0006, STR0007, STR0008 } //"Näo Iniciada" # "Em Execucäo" # "Realizada" # "Esperando" # "Adiada" # "Cancelada"
	Local dHoje 		:= Date()
	Local nRespId		:= 0
	Local nPrazoVenc 	:= 7
	Local nCont			:= 0 
	Local nFrom			:= 0
	Local nTo			:= 0
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
    cSituacao	:= alltrim( str( aParms[1] ))
    cStatus		:= alltrim( str( aParms[2] )) 
    cTipoAcao	:= alltrim( str( aParms[3] ))
    aResps		:= aBiToken( aParms[4] , ",")
    
	oKpiCore:Log( STR0013 + "sgiexport001.xls]", KPI_LOG_SCRFILE ) //"Iniciando geração da planilha [Planilha_para_Importacao_"
	oXlsFile := TBIFileIO():New( oKPICore:cKpiPath() + cDiretorio + "sgiexport001.xls" )
	// Cria o arquivo xls
	If ! oXlsFile:lCreate( FO_READWRITE + FO_EXCLUSIVE, .T. )
		oKPICore:Log( STR0016 + "sgiexport001.xls]", KPI_LOG_SCRFILE) //"Erro na criação do arquivo [Planilha_para_Importacao_"
		oKPICore:Log( STR0017, KPI_LOG_SCRFILE) //"Operação abortada"
		return
	endif	
	
	if ( oParametro:lSeek(1, {"PRAZO_PARA_VENC"} ) )
		nPrazoVenc := oParametro:nValue("DADO")
	endif
	
	// Montagem do cabeçalho do relatlório
	oXlsFile:nWriteLN('<html>')
	oXlsFile:nWriteLN('<head>')
	oXlsFile:nWriteLN('<title>' + STR0001 + '</title>') //"Criação da folha de cálculo para a importação."
	oXlsFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
	oXlsFile:nWriteLN('</head>')
	oXlsFile:nWriteLN('<body>')
	
	if cTipoAcao == "1"
		nFrom 	:= 1
		nTo   	:= 1
	elseif cTipoAcao == "2"
		nFrom 	:= 2
		nTo   	:= 2
	else         
		nFrom 	:= 1
		nTo   	:= 2
	endif
	
	for nCont := nFrom to nTo 
		cFiltro	:= "TIPOACAO = '" + alltrim(str(nCont)) + "'"	
	
		if (!empty( cSituacao ) .and. !(cSituacao == "0") )
			if(cSituacao == "1")
				cFiltro += " AND DATAFIM < '" + dtos( dHoje ) + "' and DATATERM = '        '"
			elseif(cSituacao == "2")
				cFiltro += " AND DATAFIM >= '" + dtos( dHoje ) + "' and DATAFIM <= '" + dtos( dHoje + nPrazoVenc ) + "'"
			endif
		endif
		
		if( !empty( cStatus ) .and. !( cStatus == "0" ) )
			if !empty( alltrim( cFiltro ) ) 
				cFiltro += " AND STATUS = '" + cStatus + "'"
			else
				cFiltro += " STATUS = '" + cStatus + "'"
			endif
		endif

		oXlsFile:nWriteLN('	<table width="80%" align="left" border="1" cellpadding="0" cellspacing="0">')  
		oXlsFile:nWriteLN('		<tr>')
		oXlsFile:nWriteLN('			<td>')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		
		if nCont == 1
			oXlsFile:nWriteLN(             STR0039) //Plano de ações de indicadores
		else
			oXlsFile:nWriteLN(             STR0040) //Plano de ações de projetos
		endif
		
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('    		</td>')
		oXlsFile:nWriteLN('	   </tr>')		
		
		oXlsFile:nWriteLN('		<tr>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')

		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0019) //"Criador"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					cTextScor) 
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		
		if nCont == 1
			oXlsFile:nWriteLN(				STR0021) //Indicadores
		else 
			oXlsFile:nWriteLN(              STR0041) //Projetos
		endif
		
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0022) //"Causa"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0023) //"Descrição"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0024) //"Objetivo"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0025) //"Como"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0026) //"Data Cadastro"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0027) //"Data Início"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0028) //"Data Fim"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0029) //"Finalizado em"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0030) //"Status"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0031) //"Observação do Status"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0032) //"% Realizado"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0033) //"Investimento"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0034) //"Descrição do Investimento"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0035) //"Resultado"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('			<td align="center">')
		oXlsFile:nWriteLN('				<strong><font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
		oXlsFile:nWriteLN(					STR0036) //"Responsável"
		oXlsFile:nWriteLN('				</font></strong>')
		oXlsFile:nWriteLN('			</td>')
		oXlsFile:nWriteLN('		</tr>')

		cRespFilter := ""
		For nRespId := 1 To Len( aResps )
			If ( nRespId == 1 )
				cRespFilter := "ID_RESP = " + alltrim( aResps[nRespId] )
			Else
				cRespFilter += " OR ID_RESP = " + alltrim( aResps[nRespId] )
			EndIf
		Next

		if !empty( Alltrim( cRespFilter ) )
			if !empty( alltrim( cFiltro ) )
				cFiltro += " AND (" + cRespFilter + ")"
			else
				cFiltro := cRespFilter
			endif
		endif

		oPlano:cSQLFilter( cFiltro )
		oPlano:lFiltered( .T. )
		oPlano:_First()

		while!(oPlano:lEof())
			oXlsFile:nWriteLN('		<tr>')
			
			//Nome do Plano
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("NOME") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
		 	
		 	//Criador
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			if(oUsuario:lSeek(1, { alltrim( oPlano:cValue("ID_OWNER") )}))
				oXlsFile:nWriteLN(				alltrim( oUsuario:cValue("NOME") ))
			endif
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Scorecard
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			if(oScorecard:lSeek(1, { alltrim( oPlano:cValue("ID_SCOREC") )}))
				oXlsFile:nWriteLN(					alltrim( oScorecard:cValue("NOME") ))
			endif
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			if nCont == 1
				//Indicador
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				if(oIndicador:lSeek(1, {alltrim( oPlano:cValue("ID_IND") )}))
					oXlsFile:nWriteLN(					alltrim( oIndicador:cValue("NOME") ))
				endif
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
			else 
				//Projeto
				oXlsFile:nWriteLN('			<td align="center">')
				oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
				if(oProjeto:lSeek(1, { alltrim( oPlano:cValue("ID_PROJ") )}))
					oXlsFile:nWriteLN(					alltrim( oProjeto:cValue("NOME") ))
				endif
				oXlsFile:nWriteLN('				</font>')
				oXlsFile:nWriteLN('			</td>')
			endif  

			//Causa
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("CAUSA") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Descrição
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("DESCRICAO") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Objetivo
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("OBJETIVO") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Como
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("COMO") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Data Cadastro
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( dtoc( oPlano:dValue("DATACADAST") ) ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Data Início
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( dtoc( oPlano:dValue("DATAINICIO") ) ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Data Fim
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( dtoc( oPlano:dValue("DATAFIM") ) ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Finalizado em
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( dtoc( oPlano:dValue("DATATERM") ) ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Status
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					aStatus[ val( alltrim( oPlano:cValue("STATUS") ) )] )
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Observação do Status
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("OBSERVACAO") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//% Realizado
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( str( oPlano:nValue("PERCREAL") ) ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Investimento
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( str( oPlano:nValue("VLRINVEST") ) ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Descrição do Investimento
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("INVESTIMEN") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Resultado
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			oXlsFile:nWriteLN(					alltrim( oPlano:cValue("RESULTADO") ))
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>')
			
			//Responsável
			oXlsFile:nWriteLN('			<td align="center">')
			oXlsFile:nWriteLN('				<font size="2" color="#000000" face="Verdana, Arial, Helvetica, sans-serif">')
			if(oUsuario:lSeek(1, { alltrim( oPlano:cValue("ID_RESP") )}))
				oXlsFile:nWriteLN(				alltrim( oUsuario:cValue("NOME") ))
			endif
			oXlsFile:nWriteLN('				</font>')
			oXlsFile:nWriteLN('			</td>') 
			oXlsFile:nWriteLN('		</tr>')

			oPlano:_Next()
		enddo

		oPlano:cSQLFilter("")  
		oProjeto:cSQLFilter("") 
		
		if (cTipoAcao == "0") .and. (nCont == 1)
			oXlsFile:nWriteLN('		<tr>')
			oXlsFile:nWriteLN('		</tr>') 
		endif	
		oXlsFile:nWriteLN('	</table>')
    next
   
   	oXlsFile:nWriteLN('</body>')
	oXlsFile:nWriteLN('</html>')
               
	// Faz a copia do relatorio para o diretorio de Spool
	oXlsFile:lCopyFile(cDiretorio, oKpiCore:cKpiPath())
	oXlsFile:lClose()
	oKpiCore:Log( STR0014 + "sgiexport001]", KPI_LOG_SCRFILE ) //"Finalizando geração da Planilha ["
return  