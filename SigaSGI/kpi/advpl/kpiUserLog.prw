/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KpiUserLog.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.01.06 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KpiUserLog.ch"

/*--------------------------------------------------------------------------------------
@entity Userlog
Faz o log das acoes do usuario.
--------------------------------------------------------------------------------------*/
class TKPIUserLog from TBITable
    data cLogName
	data userLog
	data dDataAtual
			
	method New() constructor
	method TKPIUserLog()

	//Metodos de log
	method lCriaUserLog() 
	method lWriteUserLog()
	method lWriteFimLog()	
	method cGetEntDesc(cEntidade)
	
endclass
	
method New() class TKPIUserLog
	::TKPIUserLog()
return

method TKPIUserLog() class TKPIUserLog
	::dDataAtual := cTod("//")
			
return

/*
*Cria o arquivo de log
*/
method lCriaUserLog() class TKPIUserLog
	local cFileName := oKpiCore:cKpiPath() + "logs\userslog\"+ ::cLogName + ".html"
	local cPathSite		:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	local lError	:= .f.
	local lExiteLog	:= .f.

	::userLog	:= 	TBIFileIO():New(cFileName)
	if(::userLog:lExists())
		if ! ::userLog:lIsOpen()
			if ! ::userLog:lOpen(FO_READWRITE)
				oKPICore:Log(STR0027)//"Erro na abertura do arquivo de log de usuário."
				lError	:= .t.
			endif
		endif
		lExiteLog	:= .t.
	else
		if ! ::userLog:lCreate(FO_READWRITE,.t.)
			oKPICore:Log(STR0028)//"Erro na criação do arquivo de log de usuário."
			lError	:= .t.			
		endif
	endif
	
	// Cria o arquivo htm
	if(! lError .and. ! lExiteLog	)

		::userLog:nWriteLN('<html>')
		::userLog:nWriteLN('<head>')
		::userLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')    
		
		::userLog:nWriteLN('<meta http-equiv="Pragma" content="no-cache">')
		::userLog:nWriteLN('<meta http-equiv="expires" content="0">')
		
  		::userLog:nWriteLN('<title>'+STR0029+'</title>')
		::userLog:nWriteLN('<link href= "'+ cPathSite + 'imagens/report.css" rel="stylesheet" type="text/css">')
		::userLog:nWriteLN('</head>')
		::userLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::userLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::userLog:nWriteLN('<tr>')
		::userLog:nWriteLN('<td class="titulo"><div align="center">'+STR0029+ '</div></td>')
		::userLog:nWriteLN('</tr>')
		::userLog:nWriteLN('</table>')
		::userLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::userLog:nWriteLN('<tr>')
		::userLog:nWriteLN('<td width="20%" class="cabecalho_1">'+STR0030+'</td>')//"Data"
		::userLog:nWriteLN('<td width="20%" class="cabecalho_1">'+STR0031+'</td>')//"Usuario"
		::userLog:nWriteLN('<td width="60%" class="cabecalho_1">'+STR0032+'</td>')//"Opcao do Menu"
		::userLog:nWriteLN('</tr>')
		//Finaliza a tabela
		::lWriteFimLog()
	endif

return lError

/*
*Grava um evento no log.
*/
method lWriteUserLog(cMensagem,cUsuario) class TKPIUserLog
	local lError := .f.
	
	if(::dDataAtual != date())	
		::dDataAtual 	:= date()
		::cLogName 		:= alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
		::cLogName 		+= strtran(dToc(date()),"/","")
		lError			:= ::lCriaUserLog()
	else
		if ! ::userLog:lIsOpen()	
			if ! ::userLog:lOpen(FO_READWRITE)
				oKPICore:Log(STR0027)//"Erro na abertura do arquivo de log de usuário."
				::dDataAtual := cTod("//")
				::userLog:Free()
				lError	:=	 .t.
			endif
		endif			
    endif
    
    if(! lError)
		
		//Posiciono no final do arquivo
		::userLog:nGoEOF()
		//37 e o numero de caracteres que sao gravados no metodo lWriteFimLog
		FSeek(::userLog:fnHandle, -43, FS_END)

		::userLog:nWriteLN('<tr>')
		::userLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	    ::userLog:nWriteLN('<td class="texto">'+cUsuario+'</td>')
	    ::userLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	    ::userLog:nWriteLN('</tr>')

		::lWriteFimLog()
		::userLog:lClose()
	endif		

return .t.

method lWriteFimLog(cMensagem) class TKPIUserLog
	::userLog:nWriteLN('</table>')
	::userLog:nWriteLN('<br>')
	::userLog:nWriteLN('</body>')
	::userLog:nWriteLN('</html>')

return .t.


method cGetEntDesc(cEntidade) class TKPIUserLog
	local cNomeEntity := cEntidade
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	

	do case
		case cEntidade == "PARAMETRO"
			cNomeEntity := STR0026//"Configuração do sistema"
		case cEntidade == "USUARIO"	
			cNomeEntity := STR0001//"Cadastro de usuários"
		case cEntidade == "GRUPO"	
			cNomeEntity := STR0002//"Cadastro de grupos"
		case cEntidade == "GRPUSUARIO"
			cNomeEntity := STR0003//"Cadastro de grupos"
		case cEntidade == "MENSAGEM"
			cNomeEntity := STR0004//"Mensagens"
		case cEntidade == "SCORECARD"
			cNomeEntity := STR0033 + cTextScor	//"Cadastro de "
		case cEntidade == "PROJETO"	
			cNomeEntity := STR0006//"Cadastro de projetos"
		case cEntidade == "INDICADOR"
			cNomeEntity := STR0007//"Cadastro de indicadores"
		case cEntidade == "GRUPO_IND"
			cNomeEntity := STR0008//"Cadastro de grupo de indicadores"
		case cEntidade == "PLANOACAO"
			cNomeEntity := STR0009//"Cadastro de plano de ações"
		case cEntidade == "UNIDADE"	
			cNomeEntity := STR0010//"Cadastro de unidades"
		case cEntidade == "METAFORMULA"
			cNomeEntity := STR0011//"Cadastro de meta fórmulas"
		case cEntidade == "AGENDAMENTO"
			cNomeEntity := STR0012//"Agendamento"
		case cEntidade == "PAINEL"	
			cNomeEntity := STR0013//"Painel do scorecarding"
		case cEntidade == "RELPLAN"	
			cNomeEntity := STR0014//"Relatório de plano de ações"
		case cEntidade == "RELSCOREIND"
			cNomeEntity := STR0034 + cTextScor + STR0035 //"Retório de "###" por indicadores"
		case cEntidade == "USU_CONFIG"
			cNomeEntity := STR0016// "Configuração de usuários"
		case cEntidade == "SMTPCONF"
			cNomeEntity := STR0017// "Configuração do servidor de e-mail"
		case cEntidade == "AGENDADOR"
			cNomeEntity := STR0018//"Agendador"
		case cEntidade == "MENSAGENS_ENVIADAS"
			cNomeEntity := STR0019//"Mensagens enviadas"		
		case cEntidade == "MENSAGENS_RECEBIDAS"
			cNomeEntity := STR0020//"Mensagens recebidas"				
		case cEntidade == "MENSAGENS_EXCLUIDAS"
			cNomeEntity := STR0021//"Mensagens excluídas				
		case cEntidade == "SCORECARDING"
			cNomeEntity := STR0022//"Scorecarding"				
		case cEntidade == "GRAPH_IND"
			cNomeEntity := STR0023//"Gráfico do indicador"
		case cEntidade == "CALC_INDICADOR"
			cNomeEntity := STR0024//"Calculo dos indicadores"		
		case cEntidade == "SCO_DUPLICADOR"
			cNomeEntity := STR0036 + cTextScor //"Duplicador de"
	endcase

return cNomeEntity

function _KpiUserLog()
return nil