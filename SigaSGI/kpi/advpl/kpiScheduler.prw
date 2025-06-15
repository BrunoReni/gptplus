// ######################################################################################
// Projeto: KPI
// Modulo : Agendador
// Fonte  : TKPIScheduler.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 19.10.04 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpiScheduler.ch"

class TKPIScheduler from TBIScheduler
	data scheLog
	
	method New( cInstancia ) constructor
	method NewKPIScheduler( cInstancia )
	method lOpen()
	method cClassName()
	method nExecute(nID, cLoadCMD)
	
	//Metodos de log
	method lSche_CriaLog(cPathSite,cLogName) 
	method lSche_WriteLog(cMensagem)
	method lSche_CloseLog()
	
endclass
	
method New( cInstancia ) class TKPIScheduler
	::NewKPIScheduler( cInstancia )
return

method NewKPIScheduler( cInstancia ) class TKPIScheduler
	::NewBIScheduler("SGI030", "AGENDADOR", cInstancia )
return

method lOpen() class TKPIScheduler
	local lRet 		:= .t.
	local cTableName:= "SGI030"
	local cAlias	:= "AGENDADOR"

	// Abrir driver
	nBIOpenDBIni(,,)
	
	use (cTablename) alias (cAlias) shared new via ("TOPCONN")

	if(lRet := !neterr())
		::OpenIndexes()
		::lClose()
		use (cTablename) alias (cAlias) shared new via ("TOPCONN")
		::OpenIndexes()
	   	::InitFields()
	endif
	
return lRet

method cClassName() class TKPIScheduler
return "TKPIScheduler"

method nExecute(nID, cExecCMD) class TKPIScheduler
	
	if(cExecCMD=="START")
		::Start()
	elseIf(cExecCMD=="STOP")
		::Stop()
    endif
    
return KPI_ST_OK    

/*
*Cria o arquivo de log
*/
method lSche_CriaLog(cPathSite,cLogName) class TKPIScheduler
	cPathSite	:=	strtran(cPathSite,"\","/")
	::scheLog	:= 	TBIFileIO():New(oKpiCore:cKpiPath()+"logs\Imports\"+ cLogName + ".html")

	// Cria o arquivo htm
	If ! ::scheLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0001)  //"Erro na criacao do arquivo de log de importação."
	else
		::scheLog:nWriteLN('<html>')
		::scheLog:nWriteLN('<head>')
		::scheLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
  		::scheLog:nWriteLN('<title>'+STR0004+'</title>')
		::scheLog:nWriteLN('<link href= "'+ cPathSite + 'imagens/report.css" rel="stylesheet" type="text/css">')
		::scheLog:nWriteLN('</head>')
		::scheLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::scheLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::scheLog:nWriteLN('<tr>')
		::scheLog:nWriteLN('<td class="titulo"><div align="center">'+STR0004+ '</div></td>')
		::scheLog:nWriteLN('</tr>')
		::scheLog:nWriteLN('</table>')
		::scheLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::scheLog:nWriteLN('<tr>')
		::scheLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0002+'</td>')
		::scheLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0003+'</td>')
		::scheLog:nWriteLN('</tr>')
	endif

return .t.

/*
*Grava um evento no log.
*/
method lSche_WriteLog(cMensagem) class TKPIScheduler

	  ::scheLog:nWriteLN('<tr>')
	    ::scheLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	    ::scheLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	  ::scheLog:nWriteLN('</tr>')

return .t.

/*
*Fecha o arquivo de log.
*/
method lSche_CloseLog() class TKPIScheduler
	::scheLog:nWriteLN('</table>')
	::scheLog:nWriteLN('<br>')
	::scheLog:nWriteLN('</body>')
	::scheLog:nWriteLN('</html>')
	::scheLog:lClose()

return .t.

function _TKPIScheduler()
return nil