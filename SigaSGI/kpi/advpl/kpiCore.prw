// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPICore - Objeto principal KPI - contem todas as referencias
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli  
// 04.01.05 | 0739 Aline Correa do Vale - criacao do metodo oContext 
// 18.08.05 | 1776 Alexandre Alves da Silva - Importado para uso no KPI
// --------------------------------------------------------------------------------------
#include "KPIDefs.ch"
#include "BIDefs.ch"
#include "KPICore.ch"

// Versão do KPI do RPO //Versao, Fase , Data da compilacao
#define KPI_VERSIONS {	"2.01.120410",; //ano;mes;dia
						"2.01.120301",; 
						"2.00.140911",; //Versão com suporte para metodologia BSC.
						"1.20.110125",; //Versão de controle do N1
						"1.20.100521",; //[Personalização de string]
						"1.10.080820",;
						"1.10.071201",;
 						"1.10.070410"}

/*--------------------------------------------------------------------------------------
@class: TKPIObject->TKPICore
Classe principal do KPI, eh para o KPI como o registry eh para o windows.
--------------------------------------------------------------------------------------*/
class TKPICore from TBIObject
	data foLogger		// Faz o log das operações do sistema
	data foLogUser		// Faz o log das operações que o usuario faz no sistema.
	data foEnableLogUser// Indica se o log do usuario esta ativo.
	data foSecurity		// Objeto que rege a segurança de todos os recursos
	data foSystemVar	// Objeto que gerencia variaveis do sistema
	data fnUserCard		// Id cartao com as informações de autenticação do usuario
	data fnThread		// Numero da thread KPI, normalmente a ordem em que foi iniciada
	data fnDBStatus		// Status retornado pelo Top após abertura de tabelas
	data fcHelpServer	// Servidor de ajuda do Protheus, sera pego no INI, tag helpserver
	data fcKpiPath		// Path onde o KPI está instalado, baseado em GetJobProfString()
	data faTables		// Tabelas do KPI
	data fnContextID	// ID Estrategia Atual
	data foOltpController// Controle de transação
	data foScheduler	// Agendador de tarefas (Job)
	data fnTrade		// Identifica a marca esta usando o sistema 1-Microsiga,2-LogoCenter,3-RM
	data foStrCustom		// String personalizada pelo usuário
	
	method New() constructor
	method NewKPICore()
    
	// Versao
	method cKPIVersion()
	method lUpdateDB()
	method UpdateVersion()
	method ExecUpdate(cUpdate)
	method CreatePolicyFile()//Cria o arquivo .java.policy
	method SchedInit( lStart ) //inicializa o job do Agendador

	// Internacionalização
	method LanguageInit()
	method getStrCustom()

	// Base de dados
	method nDBOpen()
	method oGetTable(cEntity)
	method oAncestor(cParentType, oChildTable)
	method cGetParent(oChildTable)
	method oOltpController()
	method oContext(oChildTable, nParentId)   
	Method ResetMakeID()
	
	// Login
	method nContextID()
	method lSetupCard(nCard)
	method nLogin(cUser, cPassword, cSessao)
	method xSessionValue(cVar, xValue)
	method oGetTool(cToolName)
	method lRecPassword(cUserName, cEmail) 	

	// Log
	method LogInit()
	method Log(cText, nType)
	method lEnableUserLog(lValue) 
	method LogUser(cText) 
	method nTrade(fnValue) 
	
	// Resposta
	method cRequest(cContent)
	method oArvore(cTipo, lIncluiPessoas)
	method nThread(nValue)
	method nDBStatus(nValue)
	method cHelpURL(cEntity)
	method cHelpServer()
	method cKpiPath()
	method cListPessoas(nUserCod) 	
	method aListPessoas(nUserCod)  
	method oCreateBSCCommand(cEntity,cCommand)  

	// Conversão de código de entidades (scorecards)
	method entityByCode(cEntityType)
	method entityByName(cEntityName)
	
	//DeskTop
	method CreateJNPL()
endclass
/*--------------------------------------------------------------------------------------
@constructor New(cKpiPath)
@param cKpiPath - Path de instalação do KPI. Se não for passado irá procurar no ini.
Constroe o objeto em memória.
--------------------------------------------------------------------------------------*/
method New(cKPIPath) class TKPICore
	::NewKPICore(cKpiPath)
return

method NewKPICore(cKpiPath) class TKPICore
	::NewObject()
	    
	// Status padrao para inicio
	::fnDBStatus := -1
	
	// Arquivo de log (inicia no construtor para todas as threads terem o nome do log)
	::foLogger := TBIFileIO():New("sgi.log")
	::foLogger:oOwner(self)
	
	// Arquivo de log (inicia no construtor para todas as threads terem o nome do log)
	::foLogUser := TKPIUserLog():New()
	::foLogUser:oOwner(self)
	

	// SystemVar
	::foSystemVar := TKPISystemVar():New()
	::foSystemVar:oOwner(self)
	
	// Strings personalizada pelo cliente
	::foStrCustom := TKPIStrCustom():New()
	::foStrCustom:oOwner(self)
	
	// Path do KPI
	::fcKpiPath := iif(empty(cKpiPath), GetJobProfString("SGIPATH", "ERROR"), cKpiPath)
	if(empty(::fcKpiPath) .or. ::fcKpiPath=="ERROR")
		conout(STR0022+lower(GetADV97())) //"Aviso: Kpipath não definido em "
	else
		if(right(::fcKpiPath,1)!= cBIGetSeparatorBar())
			::fcKpiPath += cBIGetSeparatorBar()
		endif	

		if(left(::fcKpiPath,1)!= cBIGetSeparatorBar())
			::fcKpiPath := cBIGetSeparatorBar() + ::fcKpiPath
		endif  
	endif	

	// Arquivo de Help
	::fcHelpServer := GetSrvProfString("HELPSERVER", "ERROR")
	if(::fcHelpServer=="ERROR")
		conout(STR0023+lower(GetADV97())) //"Aviso: Helpserver não definido em "
		conout(STR0024) //"Aviso: Continuando sem acesso a ajuda no KPI."
	endif
    
	// Tabelas de Sistema (Classe, Grupo, Entidade, Entidade-Pai, Ponteiro para Tabela/NOT_A_TABLE)
	::faTables := {;
		{"TKPI001"		,"PARAMETROS"			,"PARAMETRO"			,""					,NIL},;
		{"TKPI002"		,"USUARIOS"				,"USUARIO"				,""					,NIL},;
		{"TKPI002A"		,"GRUPOS"				,"GRUPO"				,""					,NIL},;
		{"TKPI002B"		,"GRPUSUARIOS"			,"GRPUSUARIO"			,""					,NIL},;
		{"TKPI003"		,"REGRAS"				,"REGRA"				,""					,NIL},;
		{"TKPI004"		,"MENSAGENS"			,"MENSAGEM"				,""					,NIL},;
		{"TKPI004A"		,"DESTINATARIOS"		,"DESTINATARIO"			,"MENSAGEM"			,NIL},;
		{"TKPI010"		,"SCORECARDS"			,"SCORECARD"			,""					,NIL},;
		{"TKPI010A"		,"SCORS_X_USERS"		,"SCOR_X_USER"			,""					,NIL},;
		{"TKPI010B"		,"ORGANIZACOES"			,"ORGANIZACAO"			,"SCORECARD"		,NIL},;
		{"TKPI010C"		,"ESTRATEGIAS"			,"ESTRATEGIA"			,"SCORECARD"		,NIL},;
		{"TKPI010D"		,"PERSPECTIVAS"			,"PERSPECTIVA"			,"SCORECARD"		,NIL},;
		{"TKPI010E"		,"OBJETIVOS"			,"OBJETIVO"				,"SCORECARD"		,NIL},;
		{"TKPI011"		,"MAPASESTRATEGICOS"	,"MAPAESTRATEGICO"		,""					,NIL},;
		{"TKPI011A"		,"MAPAPERSPECTIVAS"		,"MAPAPERSPECTIVA"		,"MAPAESTRATEGICO"	,NIL},;
		{"TKPI011B"		,"MAPAELEMENTOS"		,"MAPAELEMENTO"			,"MAPAESTRATEGICO"	,NIL},;
		{"TKPI011C"		,"MAPAOBJETIVOS"		,"MAPAOBJETIVO"			,"MAPAESTRATEGICO"	,NIL},;
		{"TKPI011D"		,"MAPALIGACOES"			,"MAPALIGACAO"			,"MAPAESTRATEGICO"	,NIL},;
		{"TKPI011E1"	,"MAPAGRUPOS" 			,"MAPAGRUPO"			,"MAPAESTRATEGICO"	,NIL},;
		{"TKPI013"		,"TEMASESTRATEGICOS"	,"TEMAESTRATEGICO"		,"TEMAESTRATEGICO"	,NIL},;		
		{"TKPI013A"		,"TEMASXOBJETIVOS"		,"TEMAXOBJETIVO"		,"TEMAXOBJETIVO"	,NIL},;
		{"TKPI014"		,"PROJETOS"				,"PROJETO"				,""					,NIL},;
		{"TKPI014A"		,"PERM_PROJETOS"		,"PERM_PROJETO"			,""					,NIL},;
		{"TKPI015"		,"INDICADORES"			,"INDICADOR"			,""					,NIL},;
		{"TKPI015A"		,"GRUPO_INDS"			,"GRUPO_IND"			,""					,NIL},;
		{"TKPI015B"		,"PLANILHAS"			,"PLANILHA"				,""					,NIL},;
		{"TKPI015C"		,"DWCONSULTAS"			,"DWCONSULTA"			,"INDICADOR"		,NIL},; 
		{"TKPI015D"		,"NOTAS"		   		,"NOTA"		   			,"INDICADOR"		,NIL},; 		
		{"TKPI015E"		,"ANALITICOS"			,"ANALITICO"			,"PLANILHA"			,NIL},;
		{"TKPI015G"		,"ALTERACAOMETAS"		,"ALTERACAOMETA"		,"INDICADOR"		,NIL},;		
		{"TKPI016"		,"PLANOSACAO"			,"PLANOACAO"			,""					,NIL},;
		{"TKPI016B"		,"PLANODOCS"			,"PLANODOC"				,"PLANOACAO"		,NIL},;
		{"TKPI017"		,"UNIDADES"				,"UNIDADE"				,""					,NIL},;
		{"TKPI018"		,"GRUPO_ACOES"			,"GRUPO_ACAO"			,""					,NIL},;		
		{"TKPI019"		,"PACOTES"				,"PACOTE"				,""					,NIL},;
		{"TKPI019A"		,"PACOTEXGRPINDS"		,"PACOTEXGRPIND"		,"PACOTE"			,NIL},;
		{"TKPI019B"		,"PACOTEXDEPTOS"		,"PACOTEXDEPTO"			,"PACOTE"			,NIL},;
		{"TKPI019C"		,"PACOTEXUSERS"			,"PACOTEXUSER"			,"PACOTE"			,NIL},;
		{"TKPI020"		,"METAFORMULAS"			,"METAFORMULA"			,""					,NIL},;		
		{"TKPI021"		,"DATASRCS"				,"DATASRC"				,""					,NIL},;
		{"TKPI022"		,"ESP_PEIXES"			,"ESP_PEIXE"			,""					,NIL},;
		{"TKPI022A"		,"ESP_PEIXE_CAUSAS"		,"ESP_PEIXE_CAUSA"		,""					,NIL},;
		{"TKPI022B"		,"ESP_PEIXE_EFEITOS"	,"ESP_PEIXE_EFEITO"		,""					,NIL},;
		{"TKPI030"		,"AGENDAMENTOS"			,"AGENDAMENTO"			,""	 				,NIL},;
		{"TKPI041"		,"PAINEIS"				,"PAINEL"				,""	 				,NIL},; 
		{"TKPI041A"		,"PAINELXINDS"			,"PAINELXIND"			,"PAINEIS"	 		,NIL},;
		{"TKPI043"		,"PAINEISCOMP"			,"PAINELCOMP"			,""					,NIL},; 
		{"TKPI043A"		,"PCOMPXINDS"			,"PCOMPXIND"			,"PAINEISCOMP"		,NIL},; 
		{"TKPI051"		,"RELPLANS"				,"RELPLAN"				,"RELATORIO"		,NIL},;
		{"TKPI052"		,"RELAPRS"				,"RELAPR"				,"RELATORIO"		,NIL},;
		{"TKPI052A"		,"APRXSCORS"			,"APRXSCOR"				,"RELAPR"			,NIL},;
		{"TKPI052B"		,"SCORXINDS"			,"SCORXIND"				,"APRXSCOR"			,NIL},;
		{"TKPI052C"		,"SCORXPRJS"			,"SCORXPRJ"				,"APRXSCOR"			,NIL},;
		{"TKPI052D"		,"INDXPLANS"			,"INDXPLAN"				,"SCORXIND"			,NIL},;
		{"TKPI053"		,"RELSCOREIND"			,"RELSCOREIND"			,"RELATORIO"		,NIL},;
		{"TKPI054"		,"RELESTATPLAN"			,"RELESTATPLAN"			,"RELATORIO"		,NIL},;  
		{"TKPI055"		,"RELBOOK"				,"RELBOOK"				,"RELATORIO"		,NIL},;
		{"TKPI055A"		,"RELBOOKXSCOR"			,"RELBOOKXSCOR"			,"RELBOOK"			,NIL},;		
		{"TKPI056"		,"RELIND"				,"RELIND"				,"RELATORIO"		,NIL},;
		{"TKPI056A"		,"RELINDXSCOR"			,"RELINDXSCOR"			,"RELIND"			,NIL},;
		{"TKPI056B"		,"RELINDXGRPIND"			,"RELINDXGRPIND"			,"RELIND"			,NIL},;
		{"TKPI060"		,"GRAPH_INDS"			,"GRAPH_IND"			,""					,NIL},;
		{"TKPI070"		,"USU_CONFIGS"			,"USU_CONFIG"			,""					,NIL},;
		{"TKPI080"		,"SMTPCONFS"			,"SMTPCONF"				,""					,NIL},;
		{"TKPI081"		,"RESTACESSOS"			,"RESTACESSO"			,""					,NIL}}
//		{"TKPI090"		,"CADDEPTOS"			,"CADDEPTO"	    		,""					,NIL} } 	 	

 return                                                                                 	

/*-------------------------------------------------------------------------------------
@property cKPIVersion()
Retorna a versao do RPO do kpi.
@return - . .f. se usuario invalido.
--------------------------------------------------------------------------------------*/
method cKPIVersion() class TKPICore
return KPI_VERSIONS[1]

function cKPIVersion()
return KPI_VERSIONS[1]

/*-------------------------------------------------------------------------------------
@method lUpdateDB()
Funcao inicializa base de dados do KPI.
Checa as estruturas das tabelas, atualizando-as se necessário.
@return - .t. se for a primeira abertura da base
--------------------------------------------------------------------------------------*/
method lUpdateDB() class TKPICore
	local oTable, nInd, lFirstBase := .t.
	
	::Log(STR0001, KPI_LOG_SCRFILE)/*//"Verificando a base de dados..."*/
	::nDBStatus(nBIOpenDBIni(nil,, { |x| ::Log(x, KPI_LOG_SCRFILE) })) 
	if(::nDBStatus() >= 0)
		// Se a versão do banco de dados for superior a do RPO, não permitir a execução do sistema
		oTable := TKPI001():New()
		if(oTable:lExists())
			oTable:lOpen()
			oTable:lSeek(1,{"KPIDBVERSION"})
			if(!oTable:lEof())
				if( oTable:cValue("DADO") > ::cKPIVersion() )
					::Log(STR0016, KPI_LOG_SCRFILE)/*//"Erro: RPO SigaKPI mais antigo do que a base. Impossivel inicializar."*/
					::nDBStatus(-999)
				endif
			endif
			//O log de operacoes de usuarios esta ativo?
			oTable:lSeek(1,{"LOG_USER_ENABLE"})
			if(! oTable:lEof() .and. alltrim(oTable:cValue("DADO"))=="T")
				::lEnableUserLog(.t.)
			else
				::lEnableUserLog(.f.)
			endif
			oTable:Free()
		endif
	endif

	if(::nDBStatus() >= 0)
		for nInd := 1 to len(::faTables)
			oTable := &(::faTables[nInd][1]+"():New()")
			oTable:bLogger({|x| ::Log(x, KPI_LOG_SCRFILE)})
			if(oTable:lExists())
				lFirstBase := .f.
			endif
			oTable:ChkStruct(.t.)
			oTable:Free()
		next

		::Log(STR0002, KPI_LOG_SCRFILE)/*//"Verificando indices..."*/
		for nInd := 1 to len(::faTables)
			oTable := &(::faTables[nInd][1]+"():New()")
			oTable:bLogger({|x| ::Log(x, KPI_LOG_SCRFILE)})
			oTable:lOpen(.t., .t.)
			oTable:Free()
		next
	
		::Log(STR0005, KPI_LOG_SCRFILE)/*//"Verificacao da base concluída..."*/

		BICloseDB()
	else
		::Log(STR0006, KPI_LOG_SCRFILE)/*//"Erro ao verificar base de dados..."*/
	endif                        

return lFirstBase

/*-------------------------------------------------------------------------------------
@method UpdateVersion(lFirstBase)
@param lFirstBase - Indica se a base foi criada pela primeira vez ou já existiam
Atualiza os dados do KPI se necessário.
--------------------------------------------------------------------------------------*/
method UpdateVersion(lFirstBase) class TKPICore
	local oVersion, aVersions, oTable, nI, aUpdate

	// Abre todas as Tabelas Exclusivas (.t.)
	if(::nDBOpen(.T.) < 0)
		::Log(cBIMsgTopError(nTopError), KPI_LOG_SCRFILE)
		::Log("  ")
		return
	endif

	if(lFirstBase)
		// Cria registro do release KPI
		oTable := ::oGetTable("PARAMETRO")
		oTable:lAppend({ {"CHAVE", "KPIDBVERSION"}, {"TIPO", "C"}, {"DADO", ::cKPIVersion()} })

		// Cria KPI ADMIN default na base
		oTable := ::oGetTable("USUARIO")
		oTable:lAppend({ {"ID", "0"},{"NOME", ""}, {"SENHA", ""}, {"COMPNOME", ""}, {"ADMIN", "f"},{"USERKPI", "f"} })/*//"Administrador"*/
		oTable:lAppend({ {"ID", "1"},{"NOME", "SGIADMIN"}, {"SENHA", cBIStr2Hex(pswencript("SGI"))}, {"COMPNOME", STR0003}, {"ADMIN", "t"},{"USERKPI", "t"} })/*//"Administrador"*/
		
		// Cria "Nova Organização" default na base
		oTable := ::oGetTable("SCORECARD")
		if(oTable:nRecCount() == 0)
			oTable:lAppend({ {"ID", "0"}, {"NOME", ""} })
		endif  
		
		// Cria "Novas Unidades" na base
		oTable := ::oGetTable("UNIDADE")
		oTable:carregaTabela()
	else
		oVersion := ::oGetTable("PARAMETRO")
		if(!oVersion:lSeek(1,{"KPIDBVERSION"}))
			oVersion:lAppend({{"CHAVE", "KPIDBVERSION"}, {"TIPO", "C"}, {"DADO", " 0.00.000000"}})
		endif

		//Se a tabela de scorecard for 0 adiciono o primeiro registro.
		oTable := ::oGetTable("SCORECARD")
		if(oTable:nRecCount() == 0)
			oTable:lAppend({ {"ID", "0"}, {"NOME", ""} })
		endif  

		// Vetor com as últimas atualizações
		aVersions := KPI_VERSIONS
                                
		// Vetor com as atualizações que deve ser executadas
		aUpdate := {}
		for nI := len(aVersions) to 1 step -1
			if( oVersion:cValue("DADO") < aVersions[nI] )
				aadd(aUpdate,aVersions[nI])
			endif
		next

		// Executa as atualizações necessárias			
		for nI := 1 to len(aUpdate)
			::ExecUpdate(aUpdate[nI])
			oVersion:lUpdate({{"DADO", aUpdate[nI]}})
		next
	endif                                               
	
	//Fecha Tabelas
	BICloseDB()

	::Log(STR0062, KPI_LOG_SCRFILE) //"Atualizacao dos dados concluida..."

return

/*-------------------------------------------------------------------------------------
@method ExecUpdate(cUpdate)
Executa atualização informada
@param cUpdate - Versão a ser atualizada
--------------------------------------------------------------------------------------*/
method ExecUpdate(cUpdate) class TKPICore
	local oTable	:= nil
	local oFile		:= nil
	local aFields	:= {}
	local aArea		:= {}
	local cQuery	:= ""
	local cAlias	:= ""
	local cPlano	:= ""	
	local cPath		:= ""
	local cPathOri	:= ""
	local cPathDest	:= ""
	local cMsg		:= ""
	local cArquivo	:= ""
	local nArqTrans	:= 0
	Local cTMP  	:= GetNextAlias()      
	Local cIdManut	:= KPI_SEC_MANUTENCAO     
	Local lError	:= .F.
	
	do case
		case cUpdate == ""
		case cUpdate == "1.10.080820"
			//--- atualizacao na estrutura de pastas para armazenagem dos documentos ---
			::Log(Replicate("*",80), KPI_LOG_SCRFILE)
			::Log(STR0053,KPI_LOG_SCRFILE) //"Atualização da estrutura de pastas de documentos"
			::Log(STR0054,KPI_LOG_SCRFILE) //"Leitura das informações para a nova estrutura de pastas"
			cPath := ::cKpiPath()
			cPathOri := "sgidocs\"
			cPathDest := "sgidocs\plano_acao\pl"
			oTable := ::oGetTable("PLANODOC")
			cQuery := "select ID_PLANO,DOCUMENTO from " + oTable:fcTablename
			cQuery += " where D_E_L_E_T_=''"
			cQuery += " order by ID_PLANO"
			cAlias := GetNextAlias()
			cQuery := ChangeQuery(cQuery)
			aArea := GetArea()
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
			::Log(STR0055,KPI_LOG_SCRFILE) //"Processamento das informações para a nova estrutra de pastas"
			nArqTrans := 0

			DbSelectArea(cAlias)
			While !((cAlias)->(Eof()))
				If cPlano <> (cAlias)->ID_PLANO
					cPlano := (cAlias)->ID_PLANO
					::Log(STR0056 + " " + cPlano,KPI_LOG_SCRFILE) //"Processamento do plano de ação"
					::Log("    " + STR0057 + " \sgi\sgidocs\plano_acao\pl" + cPlano,KPI_LOG_SCRFILE) //"novo local dos documentos"
				Endif
				cArquivo := AllTrim((cAlias)->DOCUMENTO)
				cMsg := STR0058 + " " + cArquivo //"cópia do arquivo"

				oFile := TBIFileIO():New(cPath + cPathOri + cArquivo)
				If oFile:lCopyFile(cArquivo, cPath + cPathDest + cPlano + "\")
					cMsg := "         (OK) " + cMsg
					nArqTrans++
				Else
					cMsg := "        (ERR) " + cMsg
				Endif
				oFile:Free()
				::Log(cMsg, KPI_LOG_SCRFILE)
				(cAlias)->(DbSkip())
			Enddo

			If nArqTrans == 0
				::Log(STR0060, KPI_LOG_SCRFILE)		//"Não houve transferência de arquivos para as novas pastas"
			Endif
			::Log(STR0059, KPI_LOG_SCRFILE) //"Atualização encerrada"
			::Log(Replicate("*",80), KPI_LOG_SCRFILE)
			//--------------------------------------------------------------------------
		case cUpdate == "1.10.071201"
			//----------------- Atualizando os Agendamentos ---------------------- 
			aFields := {	{"NOME"		, ""},;
							{"FREQ"		, ""},; 
							{"HORAFIRE"	, ""}};
			
			
			oTable := ::oGetTable("AGENDAMENTO")
			oTable:_First()
			while(!oTable:lEof())
				if !(alltrim(oTable:cValue("ID")) == "0")
					aFields[1][2] := oTable:cValue("NOME")
					aFields[2][2] := 1
					aFields[3][2] := oTable:cValue("HORAINI")
				       
					if !(oTable:lUpdate(aFields))
				   		conout(STR0063) //"Erro ao atualizar os agendamentos!"
				   	endif
				endif
				oTable:_Next()
			enddo
			//--------------------------------------------------------------------  
   		
		//Versão de controle do N1			                                 
        case cUpdate == "1.20.110125"       
         	::Log(STR0068 + '1.20.110125', KPI_LOG_SCRFILE)
            
     	//Versao de controle da seguranca na planilha de valores
     	case cUpdate == "2.01.120301"
          	::Log(Replicate("*",80), KPI_LOG_SCRFILE)
        	::Log(STR0068 + cUpdate, KPI_LOG_SCRFILE)

			oTable	:= ::oGetTable("REGRA")

			BeginSQL Alias cTMP

				SELECT * 
				FROM SGI003
				WHERE	ENTITY		= 'PLANILHA'		AND
						PERMITIDA	= '1'				AND
						IDOPERACAO	= %Exp:cIdManut%	AND
						%NotDel%

			EndSQL     		
	                  
			While (cTMP)->(!EOF())
				aFields := Reg120301(cTMP,Alltrim(Str(KPI_SEC_INCLUSAO)),oTable:cMakeID())
				oTable:lAppend(aFields)
				
				aFields := Reg120301(cTMP,Alltrim(Str(KPI_SEC_ALTERACAO)),oTable:cMakeID())
				oTable:lAppend(aFields)			
	            
				aFields := Reg120301(cTMP,Alltrim(Str(KPI_SEC_EXCLUSAO)),oTable:cMakeID())
				oTable:lAppend(aFields)
	
				(cTMP)->(dbSkip())
			EndDo
	
			(cTMP)->(dbCloseArea()) 
			
			::Log(STR0059, KPI_LOG_SCRFILE) //"Atualização encerrada"
			::Log(Replicate("*",80), KPI_LOG_SCRFILE)
			                        
		//versao de controle para responsaveis
		case cUpdate == "2.01.120410"
          	::Log(Replicate("*",80), KPI_LOG_SCRFILE)
        	::Log(STR0068 + cUpdate, KPI_LOG_SCRFILE)

			lError := .F.
			::oOltpController():lBeginTransaction()

			//Atualizacao SGI015 - Indicadores
			cQuery := "UPDATE SGI015 "
			cQuery += "SET   TP_RESP 	=	'U' "
			cQuery += "WHERE ID_RESP 	<>	' '	AND "
			cQuery += "	  	 TP_RESP 	=	' '	AND "
			cQuery += " 	 D_E_L_E_T_ =	' '"
			If (TCSQLExec(cQuery) < 0)
			    lError := .T.
			EndIf

			If !lError			
				cQuery := "UPDATE SGI015 "
				cQuery += "SET   TP_RESPCOL =	'U' "
				cQuery += "WHERE ID_RESPCOL <>	' '	AND "
				cQuery += "	  	 TP_RESPCOL =	' '	AND "
				cQuery += " 	 D_E_L_E_T_ =	' '"
				If (TCSQLExec(cQuery) < 0)
				    lError := .T.
				EndIf
			EndIf
				
			//Atualizacao SGI016 - Acao
			If !lError
				cQuery := "UPDATE SGI016 "
				cQuery += "SET   TP_RESP 	=	'U' "
				cQuery += "WHERE ID_RESP 	<>	' '	AND "
				cQuery += "	  	 TP_RESP 	=	' '	AND "
				cQuery += " 	 D_E_L_E_T_ =	' '"
				If (TCSQLExec(cQuery) < 0)
				    lError := .T.
				EndIf
			EndIf
				
			//Atualizacao SGI018 - Plano de Acao
			If !lError
				cQuery := "UPDATE SGI018 "
				cQuery += "SET   TP_RESP 	= 	'U' "
				cQuery += "WHERE ID_RESP 	<>	' '	AND "
				cQuery += "	  	 TP_RESP 	=	' '	AND "
				cQuery += " 	 D_E_L_E_T_ =	' '"
				If (TCSQLExec(cQuery) < 0)
				    lError := .T.
				EndIf
			EndIf
			
			//Atualizacao SGI016 - Acao
			If !lError
				BeginSQL Alias cTMP

					SELECT 	SGI016.ID,SGI016.ID_RESP
					FROM 	SGI016
					WHERE 	SGI016.%NotDel%

				EndSQL	           
				  
				aFields :={ {"ID_RESP"	, ""},; 
						{"TP_RESP"	, ""}};
			                    
				oTable := ::oGetTable("PLANOACAO")
				(cTMP)->(dbGoTop())

				While !lError .And. (cTMP)->(!EOF())
					If (oTable:lSeek(1,{(cTMP)->(ID)}))
						aFields[1][2] := (cTMP)->(ID_RESP)
						aFields[2][2] := TIPO_USUARIO
	
						If !(oTable:lUpdate(aFields))
							lError := .T.
					 	endif
					EndIf
					
					(cTMP)->(dbSkip())
				EndDo
				
				(cTMP)->(dbCloseArea())
			EndIf
								
			If lError
				::oOltpController():lRollback()				
			EndIf		
			::oOltpController():lEndTransaction()
	
			::Log(STR0059, KPI_LOG_SCRFILE) //"Atualização encerrada"
			::Log(Replicate("*",80), KPI_LOG_SCRFILE)
			
   	endcase

return
             
/*
  Reg120301 - Monta array para inclusao de regra
*/
Static Function Reg120301(cAlias,cOperacao,cID)
	Local 	aFields	:= {{"ID"			, cID}	,;
			{"OWNER"		, (cAlias)->OWNER}	,;
     		{"IDOWNER"		, (cAlias)->IDOWNER}	,;
     		{"ENTITY"		, (cAlias)->ENTITY}	,;
     		{"IDOPERACAO"	, cOperacao}			,;
     		{"PERMITIDA"	, (cAlias)->PERMITIDA}}

Return aFields


/*-------------------------------------------------------------------------------------
@method nDBOpen()
Inicializa as capacidades e recursos do KPI, incluindo banco de dados para uso.
É chamado pela working-thread após a inicialização da mesma.
@param lExclusive - .T. Exclusivo / .F. Compartilhado (Default)
@return - Indica o sucesso da operação.
--------------------------------------------------------------------------------------*/
method nDBOpen(lExclusive) class TKPICore
	local nInd                                                

	default lExclusive := .f.
	
	::nDBStatus(nBIOpenDBIni(,,))
	if(lRet := (::nDBStatus() >= 0))
		// Controle de transação
		// Deve ser instanciado antes da abertura das tabelas
		::foOltpController := TBIOltpController():New()
		for nInd := 1 to len(::faTables)
			::faTables[nInd][5] := &(::faTables[nInd][1]+"():New()")
			::faTables[nInd][5]:oOwner(self)
			::faTables[nInd][5]:bLogger({|x| ::Log(x, KPI_LOG_SCRFILE)})
			::faTables[nInd][5]:lOpen(lExclusive)
			::faTables[nInd][5]:oOltpController(::foOltpController)
		next

		// Security
		::foSecurity := TKPISecurity():New(self)
	else
		::Log(STR0008, KPI_LOG_SCRFILE)/*//"Erro ao tentar abrir as tabelas do KPI."*/
	endif
return ::nDBStatus()

/*-------------------------------------------------------------------------------------
@property oGetTable(cEntity)
Retorna um objeto de tabela instanciado para uso, TBIDataSet já aberto, (lOpen interno)
de acordo com o contexto do atual usuário, através de seu IDCard já credenciado.
@param cEntity - Entidade do KPI para qual será aberta a tabela.
@return - Objeto de tabela ou NIL se não conseguir abrir.
--------------------------------------------------------------------------------------*/
Method oGetTable(cEntity) Class TKPICore
	Local oTable  	:= Nil
	Local nPos      := 0     
	Local aPosicao	:= {}

	nPos := aScan(::faTables, {|x| x[3] == cEntity})
	
	If( nPos!=0 )
		oTable := ::faTables[nPos][5]
		
		If( ValType(oTable) != "O" )
			oTable := &(::faTables[nPos][1]+"():New()")
			oTable:lOpen() 
		Else
		   	aPosicao := oTable:SavePos()		
			oTable:_First()  			
			oTable:RestPos(aPosicao)
		EndIf
		
		If(!oTable:lIsOpen())
			::Log(STR0009+oTable:cTablename()+"]", KPI_LOG_RAISE)/*//"Erro ao fazer uso da tabela["*/
		EndIf
	Else
		oTable := ::oGetTool(cEntity)
	EndIf
Return oTable

/*-------------------------------------------------------------------------------------
@property oGetTool(cToolName)
Retorna um objeto ferramenta instanciado no core, para uso em operações de incluir, alterar, carregar.
@param cEntity - Entidade do KPI para qual será aberta a tabela.
@return - Objeto de tabela ou NIL se não conseguir abrir.
--------------------------------------------------------------------------------------*/
method oGetTool(cToolName) class TKPICore
	local oTool
	
	do case 
		case cToolName == "SYSTEMVAR"
			oTool := ::foSystemVar
		case cToolName == "AGENDADOR"
			oTool := ::foScheduler
		case cToolName == "MENSAGENS_ENVIADAS"
			oTool := TKPIMensagensEnviadas():New()
			oTool:oOwner(self)
		case cToolName == "MENSAGENS_RECEBIDAS"
			oTool := TKPIMensagensRecebidas():New()
			oTool:oOwner(self)
		case cToolName == "MENSAGENS_EXCLUIDAS"
			oTool := TKPIMensagensExcluidas():New()
			oTool:oOwner(self)
		case cToolName == "SCORECARDING"
			oTool := TKPIScoreCarding():New()
			oTool:oOwner(self)
		case cToolName == "CALC_INDICADOR"
			oTool := TKPICalcInd():New()
			oTool:oOwner(self)
		case cToolName == "SCO_DUPLICADOR"
			oTool := TKPIDuplicador():New()
			oTool:oOwner(self)
		case cToolName == "GERAPLANILHA"
			oTool := TKPIGeraPlanilha():New()
			oTool:oOwner(self)
		case cToolName == "EXPORTPLAN"
			oTool := TKPIExportPlanoAcao():New()
			oTool:oOwner(self)  
		case cToolName == "ORDEM_INDICADOR"
			oTool := TKPIOrdemIndicador():New()
			oTool:oOwner(self)                 
		case cToolName == "KPIUPLOAD"
			oTool := TKPIUpload():New()
			oTool:oOwner(self)		
		case cToolName == "KPICHANGEIMG"
			oTool := TKPIChangeImg():New()
			oTool:oOwner(self)		
		case cToolName == "CFGRESTACESSO"
			oTool := TKPICfgRestAcesso():New()
			oTool:oOwner(self)		
		case cToolName == "CFGPLANVLR"
			oTool := TKPICfgPlanVlr():New()
			oTool:oOwner(self)		
		case cToolName == "ESTIMPORT"
			oTool := TKPIEstImport():New()
			oTool:oOwner(self)		
		case cToolName == "ESTEXPORT"
			oTool := TKPIEstExport():New()
			oTool:oOwner(self)		
		case cToolName == "DW_CONF"
			oTool := TKPIConfDw():New()
			oTool:oOwner(self)
		case cToolName == "INDICADOR_FORMULA"
			oTool := TKPIIndicadorFormula():New()
			oTool:oOwner(self)  
		case cToolName == "ORDEM_SCORECARD" 
			oTool := TKPIOrdemScorecard():New()
			oTool:oOwner(self)  			
		case cToolName == "USERGROUP" 
			oTool := TKPIUSRGRP():New()
			oTool:oOwner(self)  			

	end case

return oTool

/*-------------------------------------------------------------------------------------
@property nContextID()
Retorna o ID da estratégia em que o usuário está atualmente.
@return - . .f. se usuario invalido.
--------------------------------------------------------------------------------------*/
method nContextID() class TKPICore
return ::fnContextID

/*-------------------------------------------------------------------------------------
@property lSetupCard(nCard)
Define o cartao do usuario desta working thread.
@param nCard - Cartao a ser inserido.
@return - .t. se o usuario valido. .f. se usuario invalido.
--------------------------------------------------------------------------------------*/
method lSetupCard(nCard) class TKPICore
return ::foSecurity:lSetupCard(nCard)

/*-------------------------------------------------------------------------------------
@method oLogin(cUser, cPassword, cSessao)
Retorna o usercard com base no usuário logado.
@param cUser - Nome de usuario para o qual sera gerado o usercard.
@param cPassword - Senha de usuario para o qual sera gerado o usercard.
@return - Usercard se usuario valido. 0 se usuario nao autorizado.
--------------------------------------------------------------------------------------*/
method nLogin(cUser, cPassword, cSessao) class TKPICore
return ::foSecurity:nLogin(cUser, cPassword, cSessao)

/*-------------------------------------------------------------------------------------
@property xSessionValue(cVar, xValue)
Grava ou Recupera uma Variavel de uma Sessão.
@param cVar - Nome da Variavel.
@param xValue - Valor da Variavel
@return - Valor da Variavel gravada na Sessão do Usuario.
--------------------------------------------------------------------------------------*/
method xSessionValue(cVar, xValue) class TKPICore
return ::foSystemVar:xSessionValue(cVar, xValue)

/*-------------------------------------------------------------------------------------
@method cRequest(cContent)
Atende a todas as requisições do client.
@param cContent - Conteudo XML a ser processado.
@return - String response para o client.
--------------------------------------------------------------------------------------*/
method cRequest(cContent) class TKPICore
	local oXMLInput, oXMLOutput
	local cID,  oTable, oNode, oAttrib
	local cExecCMD, cLoadCMD, cHelpCMD, cDelCMD
	local nStatus := KPI_ST_OK, cStatusMsg := ""
	local cFileName	:= "", cFileContent := ""
	local aFiles, nItemFile := 1
	local cCmdSQL:="",nRegDe:=0,cRegAte:=0
	local cError := "", cWarning := ""
	local cTipoAcao, cParentId, nAt   
	local cTempFile       
	local cTipoOri:= ""
	local oPar := nil
	local oCmd := nil
	local cEntityType := ""

	local nInd, nSecurityId, nSecParentId,lHasAccess
	
	private cTipo, aTransacoes       
	
	
	// MEDE O TEMPO DO PARSER
	// nTime1 := round(seconds()*1000, 0)
	// conout("* Antes de parsear: " + cBIStr(nTime1))
	// Decodifica os entities predefinidos que este parser equivocadamente nao faz
	// cContent := cBIXMLDecode(cContent)

	// Testa XML Parser
	oXmlInput := XmlParser(cContent, '_', @cError, @cWarning)

	// 	Parseia xml in
	//	CREATE oXMLInput XMLSTRING cContent;
	//	SETASARRAY ;
	// _TRANSACOES:_TRANSACAO
	
	// MEDE O TEMPO DO PARSER
	// nTime2 := round(seconds()*1000, 0)
	// conout("* Depois de parsear: " + cBIStr(nTime2) + " - Total: "+cBIStr(nTime2-nTime1))

	// Cria o root de XML out
	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))

	// Verifica sucesso do parse
	nXMLStatus := XMLError()
	if(empty(cError) .and. empty(cWarning))
		if(valtype(oXMLInput:_TRANSACOES:_TRANSACAO)!="U")
			if(valtype(oXMLInput:_TRANSACOES:_TRANSACAO)=="O")
				aTransacoes := {}
				aAdd(aTransacoes, oXMLInput:_TRANSACOES:_TRANSACAO)
			elseif(valtype(oXMLInput:_TRANSACOES:_TRANSACAO)=="A")
				aTransacoes := oXMLInput:_TRANSACOES:_TRANSACAO
			endif

			// Processa todas as transações
			for nInd := 1 to len(aTransacoes)
				do case
					// AJUDA <TIPO>                             			
					case aTransacoes[nInd]:_COMANDO:TEXT == "AJUDA"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						cHelpCMD := aTransacoes[nInd]:_HELPCMD:TEXT
						
						if(cHelpCMD == "POLITICA")
							::CreatePolicyFile()
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode := oNode:oAddChild(TBIXMLNode():New("AJUDA"))
							oNode:oAddChild(TBIXMLNode():New("URL",left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))+"h_kpiPolicy.apw"))
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode := oNode:oAddChild(TBIXMLNode():New("AJUDA"))
							oNode:oAddChild(TBIXMLNode():New("URL", ::cHelpURL(cHelpCMD)))
						endif							
					
					// ARVORE <TIPO>
					case aTransacoes[nInd]:_COMANDO:TEXT == "ARVORE"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT
						if(.t.)//Verificacao de seguranca
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode:oAddChild(::oArvore(cTipo))
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
						endif
					
					// CARREGAR <TIPO> <ID>                             			
					case aTransacoes[nInd]:_COMANDO:TEXT == "CARREGAR"
						cTipo	:= aTransacoes[nInd]:_TIPO:TEXT
						cID 	:= cBIStr(aTransacoes[nInd]:_ID:TEXT)

						if !(cTipo =="GETSTATUSWORK") // Barra de Status
							::LogUser(STR0035 +  ::foLogUser:cGetEntDesc(cTipo) + "<br>" + " ID: " + cID)
						endIf

						if(valtype(XmlChildEx(aTransacoes[nInd], "_LOADCMD"))!="U")
							cLoadCMD := aTransacoes[nInd]:_LOADCMD:TEXT
						endif

						if(cTipo=="DIRUSUARIOS") // Objeto abstrato
							if(::foSecurity:lHasAccess(cTipo, cID, "CARREGAR"))
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode := oNode:oAddChild(TBIXMLNode():New("DIRUSUARIOS"))
								oNode:oAddChild(TBIXMLNode():New("ID", 1))
								oNode:oAddChild(TBIXMLNode():New("NOME", STR0010))//"Diretório de Usuários"
								oNode:oAddChild(TBIXMLNode():New("TOTALUSUARIOS", ::oGetTable("USUARIO"):nSqlCount()))
								oNode:oAddChild(TBIXMLNode():New("TOTALGRUPOS", ::oGetTable("GRUPO"):nSqlCount()))
								oNode:oAddChild(::oGetTable("USUARIO"):oToXMLList())
								oNode:oAddChild(::oGetTable("GRUPO"):oToXMLList())
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
							endif
						elseif(cTipo=="AGENDADOR") // Objeto abstrato
							if(.t.)//Verificacao de seguranca
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode := oNode:oAddChild(TBIXMLNode():New("AGENDADOR"))
								oNode:oAddChild(TBIXMLNode():New("ID"		, "1"))
								oNode:oAddChild(TBIXMLNode():New("NOME"		, STR0021))//"Lista de Agendamentos"
								oNode:oAddChild(TBIXMLNode():New("SITUACAO"	,::foScheduler:isRunning()))
								oNode:oAddChild(::oGetTable("AGENDAMENTO"):oToXMLList())
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
							endif
						elseif( cTipo=="USU_CONFIG") 
							oTable := ::oGetTable(cTipo)
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode:oAddChild(oTable:oToXMLNode())
						elseif(cTipo=="GETSTATUSWORK") // Barra de Status
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
							oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
							oNode := oNode:oAddChild(TBIXMLNode():New("STATUSWORK"))
							                                                    
							if !empty(getGlbValue("bKpiCalcRun")) .and. getGlbValue("bKpiCalcRun") == "T"
								oNode:oAddChild(TBIXMLNode():New("CALCSTATUS", 2)) //Status Vermelho
							elseif !empty(getGlbValue("bKpiImpRun")) .and. getGlbValue("bKpiImpRun") == "T"
								oNode:oAddChild(TBIXMLNode():New("CALCSTATUS", 2)) //Status Vermelho
							elseif !empty(getGlbValue("bKpiIndUpdate")) .and. getGlbValue("bKpiIndUpdate") == "T"
								oNode:oAddChild(TBIXMLNode():New("CALCSTATUS", 1)) //Status Amarelo
							else
								oNode:oAddChild(TBIXMLNode():New("CALCSTATUS", 0)) //Status Verde
							endif
							                        
                        
						//Entidade virtual
						elseif(	cTipo	== "SCORECARDING"		.or.;
								cTipo	== "GRAPH_IND"			.or.;
								cTipo	== "SCO_DUPLICADOR"		.or.;
								cTipo	== "GERAPLANILHA"		.or.;
								cTipo	== "CALC_INDICADOR"		.or.;
								cTipo	== "ORDEM_INDICADOR"	.or.;
								cTipo	== "KPIUPLOAD"			.or.;
								cTipo	== "KPICHANGEIMG"		.or.;
								cTipo	== "CFGRESTACESSO"		.or.;
								cTipo	== "CFGPLANVLR"	 		.or.;
								cTipo	== "ESTIMPORT"	 		.or.;
								cTipo	== "ESTEXPORT"	 		.or.;
								cTipo	== "EXPORTPLAN"	 		.or.;
								cTipo	== "DW_CONF"			.or.;
								cTipo	== "INDICADOR_FORMULA"  .or.;  																
								cTipo	== "ORDEM_SCORECARD")

								
							if(::foSecurity:lHasAccess(cTipo,, "CARREGAR"))
								oTable := ::oGetTable(cTipo)
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLNode(cID,cLoadCMD))
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
							endif   
						//Entidades para qdo a analise BSC esta ativa.
						elseif(	cTipo	== "ORGANIZACAO"	.or.;
								cTipo	== "PERSPECTIVA"	.or.;
								cTipo	== "ESTRATEGIA"		.or.;
								cTipo	== "OBJETIVO"		)
								
							oTable := ::oGetTable("SCORECARD")
							if(valtype(XmlChildEx(aTransacoes[nInd], "_ID"))!="U")
								cID := cBIStr(aTransacoes[nInd]:_ID:TEXT)
							endif   
							
							//---------------------------------------------------
							// Inclusao (blank). 
							//---------------------------------------------------									
							if(alltrim(cID) == "0")
								//---------------------------------------------------
								// A tabela SGI010 deve ser posicionada no registro 0 antes da inclusão. 
								//---------------------------------------------------
								oTable:lSeek( 1, { cId } ) 
								//---------------------------------------------------
								// Retorna a estrutura do cadastro de estruturas. 
								//---------------------------------------------------
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLNode(::oCreateBSCCommand(cTipo,"INSERT")))     
							//---------------------------------------------------
							// Consulta/Visualizacao.
							//---------------------------------------------------
							elseif(oTable:lSeek(1, {cID}))
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLNode(::oCreateBSCCommand(cTipo,"VISUALIZATION")))
							endif
                               
						//---------------------------------------------------
						// Mapa Estratégico Modelo 1. 
						//---------------------------------------------------
						elseif cTipo == "MAPAESTRATEGICO1"
							cTipo := "MAPAESTRATEGICO"

							oTable := ::oGetTable(cTipo)
							if(valtype(XmlChildEx(aTransacoes[nInd], "_ID"))!="U")
								cID := cBIStr(aTransacoes[nInd]:_ID:TEXT)
							endif

							::foSecurity:foUserTable:SavePos()
							if(::foSecurity:lHasAccess(cTipo, cID, "CARREGAR"))
								::foSecurity:foUserTable:RestPos()
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLMap(cID, MAP_MODEL1))
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
							endif

						//Mapa Estratégico Modelo 2
						elseif cTipo == "MAPAESTRATEGICO2"
							cTipo := "MAPAESTRATEGICO"

							oTable := ::oGetTable(cTipo)
							if(valtype(XmlChildEx(aTransacoes[nInd], "_ID"))!="U")
								cID := cBIStr(aTransacoes[nInd]:_ID:TEXT)
							endif

							::foSecurity:foUserTable:SavePos()
							if(::foSecurity:lHasAccess(cTipo, cID, "CARREGAR"))
								::foSecurity:foUserTable:RestPos()
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLMap(cID, MAP_MODEL2))
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
							endif
                        
						ElseIf cTipo == "TEMAESTRATEGICO"
						
							oTable := ::oGetTable(cTipo)
							if(valtype(XmlChildEx(aTransacoes[nInd], "_ID"))!="U")
								cID := cBIStr(aTransacoes[nInd]:_ID:TEXT)
							endif
														
							if(valtype(XmlChildEx(aTransacoes[nInd], "_PARENTID"))!="U")
								cParentId := cBIStr(aTransacoes[nInd]:_PARENTID:TEXT)
							endif
                             
							if !oTable:lSeek(1,{"0"})
								while(! oTable:lAppend({{"ID", "0"}}))
									sleep(500)
									conout(STR0026) //"Tentando adicionar o registro de numero 0."
								end
							endif

							::foSecurity:foUserTable:SavePos()
							if(::foSecurity:lHasAccess(cTipo, cID, "CARREGAR"))
								::foSecurity:foUserTable:RestPos()
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								oNode:oAddChild(oTable:oToXMLNode(cID, cParentId))
							else
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
							endif
						else
							oTable := ::oGetTable(cTipo)
							if(valtype(XmlChildEx(aTransacoes[nInd], "_ID"))!="U")
								cID := cBIStr(aTransacoes[nInd]:_ID:TEXT)
							endif
															
							if(alltrim(cID) == "0") // Inclusao (blank)
								oPar := ::oGetTable("PARAMETRO")

								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))

								if(cTipo != "PARAMETRO" .and. ! oTable:lSeek(1,{"0"}) )
									while(! oTable:lAppend({{"ID", "0"}}))
										sleep(500)
										conout(STR0026) //"Tentando adicionar o registro de numero 0."
									end
								endif

								if(cTipo=="PLANOACAO" .and. (valtype(XmlChildEx(aTransacoes[nInd], "_PARENTID"))!="U"))
									//Na inclusao do plano de acao, pode ser identificado se a chamada eh dentro de projetos
									//neste caso não tem lista de indicadores nem scorecards, o parentid eh o codigo do projeto pai
									// e o tipoacao sera 2=projetos (a outra opção chamada no menu e 1=indicador)
									nAt := at("|",aTransacoes[nInd]:_PARENTID:TEXT)
									cParentId := subs(aTransacoes[nInd]:_PARENTID:TEXT,1,nAt-1)
									cTipoAcao = subs(aTransacoes[nInd]:_PARENTID:TEXT,nAt+1,(len(aTransacoes[nInd]:_PARENTID:TEXT)-nAt))
									oNode:oAddChild(oTable:oToXMLNode(cParentId, cTipoAcao))
								elseif(cTipo=="MENSAGEM")
									oNode:oAddChild(oTable:oToXMLNode("0","_BLANK"))
								elseif cTipo=="SCORECARD" .and. oPar:getValue("MODO_ANALISE") == ANALISE_BSC
									oNode:oAddChild(oTable:oArvoreMatrix())
								else
									oNode:oAddChild(oTable:oToXMLNode("_BLANK"))
								endif
								
							elseif(	cTipo=="MENSAGEM" .or.;
									cTipo=="MENSAGENS_ENVIADAS" .or.;
									cTipo=="MENSAGENS_RECEBIDAS" .or.;
									cTipo=="MENSAGENS_EXCLUIDAS" )
								// Tabela virtual
								if(.t.)//Verificacao de seguranca.
									oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
									oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
									oNode:oAddChild(oTable:oToXMLNode(cID, cLoadCMD))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
								endif
							elseif(oTable:lSeek(1, {cID}))
								// Tabela real       
								::foSecurity:foUserTable:SavePos()
								if(::foSecurity:lHasAccess(cTipo, cID, "CARREGAR"))
									::foSecurity:foUserTable:RestPos()
									oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
									oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
									oNode:oAddChild(oTable:oToXMLNode(cID, cLoadCMD))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
								endif
							else
								//Caso o ID seja menos 1 nao e necessario possicionar na tabela para retornar o registro.
								if(cID == "-1")
									oNodeRet := TBIXMLNode():New("RETORNOS")
									oNodeRet:oAddChild(oTable:oToXMLNode(cID, cLoadCMD))

									cStatusMsg := oTable:cMsg()
									if(!empty(cStatusMsg))
										oAttrib := TBIXMLAttrib():New()
										oAttrib:lSet("MSG", cStatusMsg)
										oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_VALIDATION, oAttrib))
                                    else
										oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
									endif
									oNode:oAddChild(oNode:oAddChild(oNodeRet))
								else
									oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_BADID))
								endif
							endif	
						endif
					
					// INCLUIR <TIPO>
					case aTransacoes[nInd]:_COMANDO:TEXT == "INCLUIR"
						cTipo 	:= aTransacoes[nInd]:_TIPO:TEXT
						cArvore := aTransacoes[nInd]:_ARVORETIPO:TEXT						
						cTipoOri:= cTipo

						do case 
							case cTipo == "ORGANIZACAO"
								cEntityType	:= CAD_ORGANIZACAO
								cTipo := "SCORECARD"

							case cTipo == "ESTRATEGIA"
								cEntityType	:= CAD_ESTRATEGIA
								cTipo := "SCORECARD"

							case cTipo == "PERSPECTIVA"
								cEntityType	:= CAD_PERSPECTIVA
								cTipo := "SCORECARD"

							case cTipo == "OBJETIVO"
								cEntityType	:= CAD_OBJETIVO
								cTipo := "SCORECARD"

							case cTipo == "SCORECARD"
								cEntityType	:= CAD_SCORECARD
								cTipo := "SCORECARD"
						endcase

						if cTipo == "SCORECARD"
							oCmd := ::oCreateBSCCommand(cTipoOri, "SAVE")
						endif

						oTable := ::oGetTable(cTipo)

						if(::foSecurity:lHasAccess(cTipo,"","MANUTENCAO"))
							nStatus := oTable:nInsFromXML(aTransacoes[nInd], "_REGISTROS:_"+cTipoOri, oCmd)
							
							//Retorna o ID da entidade para o formulário.
							If( nStatus==KPI_ST_OK )
								oNode:oAddChild(TBIXMLNode():New("ID", oTable:cValue("ID")))
								  
								//Identifica se a entidade pode enviar mensagem de alerta mesmo quando o status é KPI_ST_OK.  
								If ( oTable:flCanAlert )
									cStatusMsg := oTable:cMsg()
								EndIf
							Else
								cStatusMsg := oTable:cMsg()   
							EndIf	 

							//Retorna o status da operação. 
							oAttrib := TBIXMLAttrib():New()
							oAttrib:lSet("MSG", cStatusMsg )
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))   

							//Monta a árvore, caso seja uma tree. 
							If( cArvore != "NOTREE" )
								oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
								oNode:oAddChild(::oArvore(cArvore))
							EndIf  
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
						endif	
			
					// ALTERAR <TIPO>
					case aTransacoes[nInd]:_COMANDO:TEXT == "ALTERAR"
						cTipo 	:= aTransacoes[nInd]:_TIPO:TEXT
						cArvore := aTransacoes[nInd]:_ARVORETIPO:TEXT						
						cTipoOri:= cTipo

						if cTipo == "MAPAESTRATEGICO1" .or. cTipo == "MAPAESTRATEGICO2"
							cTipo := "MAPAESTRATEGICO"
							cTipoOri:= cTipo
						endif

						if(cTipo!="SYSTEMVAR")
							cID   := cBIStr(&("aTransacoes["+str(nInd)+"]:_REGISTROS:_"+cTipo+":_ID:TEXT"))
						else
							cID   := "0"
						endif
		                
						//Tratamento de segurança (UPDATING) do indicador é feito na própria classe
						if(	cTipo=="INDICADOR" .or. ::foSecurity:lHasAccess(cTipoOri, cID, "MANUTENCAO") )
							// Status
							oAttrib := TBIXMLAttrib():New()

							do case 
								case cTipo == "ORGANIZACAO"
									cEntityType	:= CAD_ORGANIZACAO
									cTipo := "SCORECARD"
	
								case cTipo == "ESTRATEGIA"
									cEntityType	:= CAD_ESTRATEGIA
									cTipo := "SCORECARD"
	
								case cTipo == "PERSPECTIVA"
									cEntityType	:= CAD_PERSPECTIVA
									cTipo := "SCORECARD"
	
								case cTipo == "OBJETIVO"
									cEntityType	:= CAD_OBJETIVO
									cTipo := "SCORECARD"
	
								case cTipo == "SCORECARD"
									cEntityType	:= CAD_SCORECARD
							endcase

							if cTipo == "SCORECARD"
								oCmd := ::oCreateBSCCommand(cTipoOri, "SAVE")
							endif

							// Tabela de objeto
							oTable := ::oGetTable(cTipo)
							nStatus := oTable:nUpdFromXML(aTransacoes[nInd], "_REGISTROS:_"+cTipoOri, oCmd)

							if(cTipo=="INDICADOR")
								if(nStatus == KPI_ST_FORMULA_CHANGE)								
									oAttrib:lSet("AFTER_UPDATE", "CHANGED_FORMULA")
									nStatus := KPI_ST_OK					
								endif
							endif
	
							If( nStatus == KPI_ST_OK )
								//Identifica se a entidade pode enviar mensagem de alerta mesmo quando o status é KPI_ST_OK.  
								If ( oTable:flCanAlert )
									cStatusMsg := oTable:cMsg()
								EndIf
							Else
							  	cStatusMsg := oTable:cMsg()  		
							EndIf							
							
							oAttrib:lSet("MSG", cStatusMsg)
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
							
							// Arvore e atualizações
							if(cArvore != "NOTREE")
								oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
								oNode:oAddChild(::oArvore(cArvore))
							endif								
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
						endif	
			
					// EXCLUIR <TIPO> <ID>
					case aTransacoes[nInd]:_COMANDO:TEXT == "EXCLUIR"
						cTipo 	:= aTransacoes[nInd]:_TIPO:TEXT
						cTipoOri:= cTipo						
						cArvore := aTransacoes[nInd]:_ARVORETIPO:TEXT
						cID 	:= cBIStr(aTransacoes[nInd]:_ID:TEXT)   
						
						if(valtype(XmlChildEx(aTransacoes[nInd], "_DELCMD"))!="U")
							cDelCMD := aTransacoes[nInd]:_DELCMD:TEXT
						endif
						
						//Entidades para qdo a analise BSC esta ativa.
						if cTipo	== "ORGANIZACAO"	.or.;
							cTipo	== "PERSPECTIVA"	.or.;
							cTipo	== "ESTRATEGIA"		.or.;
							cTipo	== "OBJETIVO"		
							cTipo 	:= "SCORECARD"
						endif	
						
						if(::foSecurity:lHasAccess(cTipoOri, cID, "MANUTENCAO"))
							// Tabela de objeto
							oTable := ::oGetTable(cTipo)
							nPosCpoID := ascan(oTable:faFields, {|y|y:FCFIELDNAME == "ID"})
							if(nPosCpoID != 0)		
								cID := padr(lTrim(cID),oTable:faFields[nPosCpoID]:FNLENGTH, " ") //Colocar espacos a direita.
							endif		

							nStatus := oTable:nDelFromXML(cID, cDelCMD)

							If( nStatus == KPI_ST_OK )
								oNode:oAddChild(TBIXMLNode():New("ID", oTable:cValue("ID")))  
								
								//Identifica se a entidade pode enviar mensagem de alerta mesmo quando o status é KPI_ST_OK.  
								If ( oTable:flCanAlert )
									cStatusMsg := oTable:cMsg()
								EndIf
							Else    
								cStatusMsg := oTable:cMsg()
							EndIf	

							// Status
							oAttrib := TBIXMLAttrib():New()
							oAttrib:lSet("MSG", cStatusMsg)
							oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
			
							// Arvore e atualizações
							if(cArvore != "NOTREE")
								oNode := oNode:oAddChild(TBIXMLNode():New("ATUALIZACOES"))
								oNode:oAddChild(::oArvore(cArvore))
							endif								
						else
							oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NORIGHTS))
						endif	                                      
						
					// EXECUTAR <TIPO> <ID>
					case aTransacoes[nInd]:_COMANDO:TEXT == "EXECUTAR"
						cTipo 		:= aTransacoes[nInd]:_TIPO:TEXT
						cID 		:= cBIStr(aTransacoes[nInd]:_ID:TEXT)
						cExecCMD 	:= aTransacoes[nInd]:_EXECCMD:TEXT                
						
						If cTipo == "MAPAESTRATEGICO2"
							cTipo := "MAPAESTRATEGICO"
						EndIf
					
						// Tabela de objeto
						oTable := ::oGetTable(cTipo)
						oTable:fcMsg := ""
						nStatus := oTable:nExecute(cID, cExecCMD)

						cStatusMsg := oTable:cMsg()

						// Status
						oAttrib := TBIXMLAttrib():New()
						oAttrib:lSet("MSG", cStatusMsg)
						oNode:oAddChild(TBIXMLNode():New("STATUS", nStatus, oAttrib))
			
					// SALVARBASE64 <SALVARBASE64>
					case aTransacoes[nInd]:_COMANDO:TEXT == "SALVARBASE64"
						cFileName 	 := aTransacoes[nInd]:_FILENAME:TEXT
						cFileContent := aTransacoes[nInd]:_FILECONTENT:TEXT
						cFileNew	 := aTransacoes[nInd]:_FILENEW:TEXT
						
						// Tratamento para alterar as barras para a criação do 
						// diretório de exportação caso ele não exista
						If "/" $ cFileName
							cFileName := Strtran(cFileName, "/","\")
						EndIf
		                
						// Gera arquivo 
						oFile := TBIFileIO():New(::cKpiPath()+ "\" +cFileName )
						if  cFileNew == "F"							
							::oGetTool("KPIUPLOAD"):writeFile(cFileContent,cFileName)
						else
							// Cria o arquivo 
							if ! oFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
								::Log(STR0013 + cFileName , KPI_LOG_SCRFILE) //"Erro na criação do arquivo."
								::Log(STR0014, KPI_LOG_SCRFILE) //"Operação abortada."
								oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_INUSE))
								oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
								return
							endif
							oFile:nWriteln(decode64(cFileContent))
							oFile:lClose()
						endif
		
						oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
						oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
		
					//LISTAR ARQUIVOS <LISTAR ARQUIVOS>
					case aTransacoes[nInd]:_COMANDO:TEXT == "LISTARARQUIVOS"
						cFileLocal 	 := ::cKpiPath()+ "\" + aTransacoes[nInd]:_LOCAL:TEXT
						aFiles := directory(cFileLocal)
		
						oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
						oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))
					
						oNode := oNode:oAddChild(TBIXMLNode():New("FILE"))
						oNode := oNode:oAddChild(TBIXMLNode():New("ARQUIVOS"))
		
						nFiles := len(aFiles)
						for nItemFile:=1 to nFiles 
							oNodeLine := oNode:oAddChild(TBIXMLNode():New("ARQUIVO"))
							oNodeLine:oAddChild(TBIXMLNode():New("NAME",	lower(aFiles[nItemFile][1])))
							oNodeLine:oAddChild(TBIXMLNode():New("SIZE",	str(aFiles[nItemFile][2]/1024,10,2)+ " Kb"))
							oNodeLine:oAddChild(TBIXMLNode():New("DATE",	dToc(aFiles[nItemFile][3]) + " " + aFiles[nItemFile][4]))
						next nItemFile

					//LISTRECORDS Lista os Registros da tabela.
					case aTransacoes[nInd]:_COMANDO:TEXT == "LISTRECORDS"
						cTipo := aTransacoes[nInd]:_TIPO:TEXT

						oTable := ::oGetTable(cTipo)
						oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
						oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))

						if	cTipo == "MAPAESTRATEGICO" .or. ;
							cTipo == "ESTRATEGIA" .or. ;
							cTipo == "PERSPECTIVA" .or. ;
							cTipo == "OBJETIVO"
							
							//Tratamento especial do mapa estratégico
							oNode:oAddChild(oTable:oProcCmd(aTransacoes[nInd]))
						else
							//Verifica se foi passado um comando SQL.
							if( valtype(XmlChildEx(aTransacoes[nInd], "_CMDSQL"))!="U" )
								if valtype(XmlChildEx(aTransacoes[nInd]:_CMDSQL, "_XML_COMMAND")) =="O" 
									cCmdSQL := aTransacoes[nInd]:_CMDSQL
								else
									cCmdSQL := aTransacoes[nInd]:_CMDSQL:TEXT
								endif
							else
								cCmdSQL := ""
							endif

							oNode:oAddChild(oTable:oToXMLRecList(cCmdSQL))
						endif

					// COMANDO NAO ENVIADO
					otherwise
						oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NOCMD))
				endcase
			next
		else
			// Nao ha nenhuma transacao
			oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_NOTRANSACTION))
		endif			
	else
		// Erro no parse
		oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_BADXML))
		if(!empty(cError))
			::Log(STR0064 + cError, KPI_LOG_SCRFILE) //"Erro no Parse "
		endif
		
		if(!empty(cWarning))
			::Log(STR0065 + cWarning, KPI_LOG_SCRFILE) //"Aviso no Parse "
		endif
	endif

	If (KPIIsDebug())  
	   ::Log(oXMLOutput:cXMLString(.T., "ISO-8859-1"), KPI_LOG_SCR)
	EndIf				
    
	/*Realiza a transferência para o client do arquivo XML gerado no server.*/
	HttpSend(oXMLOutput:cXMLString(.T., "ISO-8859-1")) 

Return Nil

/*-------------------------------------------------------------------------------------
@method LogInit()
Inicializa o arquivo de log do KPI.
--------------------------------------------------------------------------------------*/
method LogInit() class TKPICore
	if(!::foLogger:lExists())
		if(!::foLogger:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
			::Log(STR0011+::foLogger:cFileName(), KPI_LOG_RAISE)/*//"Erro na criação do arquivo: "*/
			::foLogger:lClose()
		endif	
	endif
return

/*-------------------------------------------------------------------------------------
@method SchedInit()
Inicializa o Scheduler junto com o KPI.
--------------------------------------------------------------------------------------*/
method SchedInit( lStart ) class TKPICore
	::foScheduler := TKPIScheduler():New(GetJobProfString("INSTANCENAME", "SGI"))
	if(lStart .and. !::foScheduler:isRunning())
		::foScheduler:Start()
	endif
return

/*-------------------------------------------------------------------------------------
@method Log(cText, nType)
Grava o log do KPI.
@param cText - Texto a ser trabalhado(logado).
@param nType - Constante identificando a operacao de log (default: KPI_LOG_SCR).
KPI_LOG_SCR - Somente apresenta na console.
KPI_LOG_FILE - Somente grava no arquivo de log.
KPI_LOG_RAISE - Grava no arquivo de log e levanta exceção no Protheus.
KPI_LOG_SCRFILE - Apresenta na console e grava no arquivo de log.
--------------------------------------------------------------------------------------*/
method Log(cText, nType) class TKPICore
return KPILogInFile(::foLogger, cText, nType)

/*-------------------------------------------------------------------------------------
@method Log(cText, nType)
Grava o log do KPI.
@param cText - Texto a ser trabalhado(logado).
@param nType - Constante identificando a operacao de log (default: KPI_LOG_SCR).
KPI_LOG_SCR - Somente apresenta na console.
KPI_LOG_FILE - Somente grava no arquivo de log.
KPI_LOG_RAISE - Grava no arquivo de log e levanta exceção no Protheus.
KPI_LOG_SCRFILE - Apresenta na console e grava no arquivo de log.
--------------------------------------------------------------------------------------*/
method LogUser(cText) class TKPICore
	local oUserTable	:= ::oGetTable("USUARIO")
	local oTable
	local cUser			:= ""

	//Verifica se devo registrar o log
	if(::lEnableUserLog())
		//Usuario logado
		::foSecurity:oLoggedUser()
		cUser := alltrim(oUserTable:cValue("NOME"))
		::foLogUser:lWriteUserLog(cText,cUser)		
	else
		if(valType(::lEnableUserLog())=="U")
			oTable:= ::oGetTable("PARAMETRO")			
			oTable:lSeek(1,{"LOG_USER_ENABLE"})
			if(! oTable:lEof() .and. alltrim(oTable:cValue("DADO"))=="T")
				::lEnableUserLog(.t.)
				::LogUser(cText)				
			else
				::lEnableUserLog(.f.)
			endif
		endif
	endif
	
return .t.


/*-------------------------------------------------------------------------------------
@property nThread(nValue)
Define/recupera o numero da thread kpi a qual pertence este obj KPICore.
@param nValue - Numerico indicando a ordem de abertura da thread.
@return - Numerico indicando a ordem de abertura da thread.
--------------------------------------------------------------------------------------*/
method nThread(nValue) class TKPICore
	property ::fnThread := nValue
return ::fnThread

/*-------------------------------------------------------------------------------------
@property nDBStatus(nValue)
Define/recupera o numero da DBStatus kpi a qual pertence este obj KPICore.
@param nValue - Numerico indicando a ordem de abertura da DBStatus.
@return - Numerico indicando a ordem de abertura da DBStatus.
--------------------------------------------------------------------------------------*/
method nDBStatus(nValue) class TKPICore
	property ::fnDBStatus := nValue
return ::fnDBStatus

/*-------------------------------------------------------------------------------------
@property lEnableUserLog(lValue)
Define/recupera o status do log de usuario
@param lValue - Logico indicando o status do log
@return - Logico indicando o status do log
--------------------------------------------------------------------------------------*/
method lEnableUserLog(lValue) class TKPICore
	property ::foEnableLogUser := lValue
return ::foEnableLogUser

/*-------------------------------------------------------------------------------------
@property cHelpServer()
Recupera o servidor de ajuda do Protheus, sera pego no INI, tag helpserver.
@return - Servidor de ajuda do protheus.
--------------------------------------------------------------------------------------*/
method cHelpServer() class TKPICore
return ::fcHelpServer

/*-------------------------------------------------------------------------------------
@property cKpiPath(cPath)
Define/Recupera o path no qual o kpi esta instalado.
@return - Path do kpi, a partir do rootpath.
--------------------------------------------------------------------------------------*/
method cKpiPath(cPath,cPathSeparador) class TKPICore
	default cPathSeparador := cBIGetSeparatorBar()
	property ::fcKpiPath := cPath

	if(cPathSeparador == cBIGetSeparatorBar())
		return ::fcKpiPath
	else
		return strTran(::fcKpiPath, cBIGetSeparatorBar() ,cPathSeparador)
	endif

/*-------------------------------------------------------------------------------------
@method cHelpURL(cEntity)
Recupera a URL do Help Server.
@param cEntity - Entidade do qual se quer o help.
@return - URL do Help Server.
--------------------------------------------------------------------------------------*/
method cHelpURL(cEntity) class TKPICore
	local aHelpPath, cHelpPath, cHelpServer, cHelpURL, nInd1

	// Matriz de paths para os helps, deve ser montada da seguinte forma:
	// cada elemento: { <chave URL 1>, <pagina Html correspondente ao help> }

	aHelpPath := 	{ ;
						{ "SIGASGI"		, "sigasgi.htm" },;
						{ "ORGANIZACAO"	, "cadastro_de_organizacao.htm" },;
						{ "ESTRATEGIA"	, "cadastro_de_estrategia.htm" },;
						{ "PERSPECTIVA"	, "cadastro_de_perspectiva.htm" },;
						{ "OBJETIVO"	, "cadastro_de_objetivo.htm" },;
						{ "SCORECARD"	, "cadastro_de_scorecards.htm" },;
						{ "UNIDADE"		, "unidades_de_medida.htm" },;
						{ "METAFORMULA"	, "meta_formulas.htm" },;
						{ "GRUPO_IND"	, "grupo_de_indicadores.htm" },;
						{ "INDICADOR"	, "indicadores.htm" },;
						{ "PLANOACAO"	, "planos_de_acoes_de_indicadores.htm" },;
						{ "GRUPO_ACAO"	, "planos_de_acoes_de_indicadores.htm" },;
						{ "PROJETO"		, "projetos.htm" },;
						{ "SCORECARDING", "scorecarding.htm" },;
						{ "PAINEL"		, "paineis.htm" },;
						{ "PAINELCOMP"	, "paineis.htm" },;
						{ "LST_PLANOACAO", "lista_de_planos_de_acoes.htm" },;
						{ "RELAPR"		, "apresentacoes.htm" },;      
						{ "RELPLAN"		, "relatorio_de_planos_de_acao.htm" },;      
						{ "RELSCOREIND"	, "relatorio_de_scorecards_e_indicadores.htm" },;
						{ "AGENDADOR"	, "agendador_de_tarefas.htm" },;
						{ "AGENDAMENTO"	, "agendador_de_tarefas.htm" },;
						{ "CALC_INDICADOR", "calculo_dos_indicadores.htm" },;
						{ "DATASRC"		, "fonte_de_dados.htm" },;
						{ "EXPORTPLAN"	, "exportacao_de_planos_de_acoes.htm" },;
						{ "GERAPLANILHA", "planilha_para_importacao.htm" },;
						{ "IMPPLANILHA" , "importacao_de_dados.htm"},;
						{ "DATASRC"		, "fonte_de_dados.htm" },;
						{ "PARAMETRO"	, "configuracao_do_sistema.htm" },;
						{ "SCO_DUPLICADOR", "duplicacao_de_scorecard.htm" },;
						{ "SMTPCONF"	, "servidor_de_email.htm" },;
						{ "MENSAGEM"	, "mensagens_e_emails.htm" },;	
						{ "USUARIO"		, "usuarios_grupos_e_seguranca.htm" },;
						{ "GRUPO"		, "usuarios_grupos_e_seguranca.htm" },; 
						{ "PACOTE"		, "pacotes.htm" },;	 
						{ "ESP_PEIXE"	, "espinha_de_peixe.htm" },;    
						{ "CFGPLANVLR"	, "planilha_de_valores.htm" },; 
						{ "CFGRESTACESSO", "restricao_de_acesso.htm" },; 
						{ "ESTEXPORT"   , "exportar.htm" },; 
						{ "ESTIMPORT"   , "importar.htm" },; 
						{ "DW_CONF"     , "conexao_sigadw.htm" }; 
   					}
	

	cHelpPath 	:= "/" + cKPILanguage() + "/sigasgi_"
	cHelpServer := Lower(::cHelpServer())
	cHelpServer := StrTran(cHelpServer, "http:", "")
	cHelpURL 	:= "http://" + cHelpServer + cHelpPath

	// Montar help a ser carregado
	nInd1 := aScan( aHelpPath, {|x| x[1]==cEntity} ) 

	if(nInd1 > 0)
		if(nInd1 == 1) //sigasgi.htm
			cHelpURL := "http://"+cHelpServer+"/"+cKPILanguage()+"/"+aHelpPath[nInd1,2]	
		else
			cHelpURL += aHelpPath[nInd1,2]
		endif
	else
		cHelpURL := "NOHELP"
	endif	
				
return cHelpURL     


function KPIEncode(acValue, alApplet)
	local cRet := acValue
	local aDe, aPara
	
	if valType(acValue) == "C"
		default alApplet := .f.
	
		if !alApplet                      			      //º        , ª      ,á         ,ã         ,â        ,à         ,é         ,ê        ,í         ,ô        ,ó         ,õ         ,ú         ,ü       ,ù         ,ç
			aDe   := { "<"   , ">"   , "  "          , "\" , chr(167),chr(166),chr(225)  ,chr(227)  ,chr(226) ,chr(224)  ,chr(233)  ,chr(234) ,chr(237)  ,chr(244) ,chr(243)  ,chr(245)  ,chr(250)  ,chr(252),chr(249)  ,chr(231)   }
			aPara := { "&lt;", "&gt;", "&nbsp;&nbsp;", "\\", "&ordm;","&ordf;","&aacute;","&atilde;","&acirc;","&agrave;","&eacute;","&ecirc;","&iacute;","&ocirc;","&oacute;","&otilde;","&uacute;","&uuml;","&ugrave;","&ccedil;" }
		else
			aDe   := { "\" , '"' , "'", CRLF, CR, LF  }
			aPara := { "\\", '\"', "\'", "\n", "\n", "" }
		endif
		aEval(aDe, { |x, i|cRet := strTran(cRet, x, aPara[i]) })
	endif
	
return cRet

/*-------------------------------------------------------------------------------------
@method oArvore(cTipo, lIncluiPessoas)
Retorna a arvore do tipo pedido.
@param cTipo - Tipo da arvore a ser montada.
@param lIncluiPessoas - Define se as Organizações terão o node "Pessoas".
@return - Node XML gerado com a arvore pedida.
--------------------------------------------------------------------------------------*/
method oArvore(cTipo, lIncluiPessoas) class TKPICore
	local oXMLArvore, oXMLNode, oAttrib, oTable//, oXMLChild
	local oNodeItem
	local cUser, cComp
	
	default lIncluiPessoas := .t.
	
	// Envia informação do usuario atualmente conectado
	oTable 	:= ::foSecurity:oLoggedUser()
	cUser 	:= alltrim(oTable:cValue("NOME"))
	cComp 	:= alltrim(oTable:cValue("COMPNOME"))

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("USUARIO", cComp+" ("+cUser+") ")
	oXMLArvore := TBIXMLNode():New("ARVORE",,oAttrib)
	
	if(cTipo=="CONFIGURACAO" .or.  cTipo=="USUARIO" .or. cTipo=="GRUPO" .or. cTipo=="GRPUSUARIO")
		// No de configuracoes
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", "CONFIGURACOES")
		oAttrib:lSet("NOME", STR0017		)//  "Configurações"

		oXMLNode := oXMLArvore:oAddChild(TBIXMLNode():New("CONFIGURACOES","",oAttrib))

		if(oTable:lValue("ADMIN"))   
			//**************************************************************************************************
			//Configurações
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "CONFIG")
			oAttrib:lSet("NOME", STR0045)		//"Configurações"
			oNodeItem := TBIXMLNode():New("CONFIG","",oAttrib) 
			
			//Parametros do Sistema
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "PARAMETRO")
			oAttrib:lSet("NOME", STR0046)		//"Parametros do Sistema"
			oNodeItem:oAddChild(TBIXMLNode():New("APARAMETRO", "", oAttrib))		
			
			//Planilha de Valores
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "CFGPLANVLR")
			oAttrib:lSet("NOME", STR0047)		//"Planilha de Valores"
			oNodeItem:oAddChild(TBIXMLNode():New("CFGPLANVLR", "", oAttrib))
			
			//Restrição de Acesso
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "CFGRESTACESSO")
			oAttrib:lSet("NOME", STR0048)		//"Restrição de Acesso"
			oNodeItem:oAddChild(TBIXMLNode():New("CFGRESTACESSO", "", oAttrib))  
			
			//Servidor de e-mail
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME",STR0028)//"Servidor de e-mail"
			oAttrib:lSet("TIPO", "SMTPCONF")		
			oNodeItem:oAddChild(TBIXMLNode():New("SMTPCONF","",oAttrib))
			
			//Integração DW
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME", STR0061)//"Conexão SIGADW"
			oAttrib:lSet("TIPO", "DW_CONF")		
			oNodeItem:oAddChild(TBIXMLNode():New("DW_CONF","",oAttrib))
                   
			oXMLNode:oAddChild(oNodeItem)                                   
			//**************************************************************************************************
			
             

			//**************************************************************************************************
			//Estrutura
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "METADADO")
			oAttrib:lSet("NOME", STR0049)		//"Estrutura"
			oNodeItem := TBIXMLNode():New("METADADO","",oAttrib) 
			
			//Exportar
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "ESTEXPORT")
			oAttrib:lSet("NOME", STR0050)		//"Exportar"
			oNodeItem:oAddChild(TBIXMLNode():New("ESTEXPORT", "", oAttrib))		
			
			//Importar
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "ESTIMPORT")
			oAttrib:lSet("NOME", STR0051)		//"Importar"
			oNodeItem:oAddChild(TBIXMLNode():New("ESTIMPORT", "", oAttrib))
            
			oXMLNode:oAddChild(oNodeItem)  
			//**************************************************************************************************
			


			//**************************************************************************************************
			//No Tarefas administrativas
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("TIPO", "TAREFAS_ADM")
			oAttrib:lSet("NOME", STR0033)	//"Tarefas administrativas"	
			oNodeItem := TBIXMLNode():New("TAREFA_ADM","",oAttrib)
			
			//Geração da Planilha para a importacao
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME", STR0052) //  "Planilha de dados" 
			oAttrib:lSet("TIPO", "GERAPLANILHA")								
			oNodeItem:oAddChild(TBIXMLNode():New("GERAPLANILHA","",oAttrib))
			
			//Geração de Plano de Ação
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME", STR0037)//  "Planilha de Planos de Ação"
			oAttrib:lSet("TIPO", "EXPORTPLAN")								
			oNodeItem:oAddChild(TBIXMLNode():New("EXPORTPLAN","",oAttrib))
			
			//Agendamento da importacao
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME", STR0018)//  "Importação de dados"
			oAttrib:lSet("TIPO", "AGENDADOR")								
			oNodeItem:oAddChild(TBIXMLNode():New("AGENDADOR","",oAttrib))

			//Tela de execucao do calculo
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME",STR0020 )//"Cálculo dos indicadores"
			oAttrib:lSet("TIPO", "CALC_INDICADOR")								
			oNodeItem:oAddChild(TBIXMLNode():New("CALC_INDICADOR","",oAttrib))

			//Tela de execucao do calculo
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 0)
			oAttrib:lSet("NOME",STR0038)//"Fonte de dados"
			oAttrib:lSet("TIPO", "LSTDATASRC")
			oNodeItem:oAddChild(TBIXMLNode():New("LSTDATASRC","",oAttrib))			

			oXMLNode:oAddChild(oNodeItem)
			//**************************************************************************************************
		endif			

		//No de Mensagens
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 0)
		oAttrib:lSet("TIPO", "MENSAGEM_ALL")
		oAttrib:lSet("NOME", STR0029)//"Mensagens"
		oNodeItem := TBIXMLNode():New("MENSAGEM","",oAttrib) 
		
		//Caixa de entrada
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", "MENSAGENS_RECEBIDAS")
		oAttrib:lSet("NOME", STR0032)//"Caixa de Entrada"
		oNodeItem:oAddChild(TBIXMLNode():New("MENSAGENS_ARECEBIDAS", "", oAttrib))		
	
		//Itens Enviados
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", "MENSAGENS_ENVIADAS")
		oAttrib:lSet("NOME", STR0031)//"Itens Enviados"
		oNodeItem:oAddChild(TBIXMLNode():New("MENSAGENS_ENVIADAS", "", oAttrib))
		
		//Itens Excluidos
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", "MENSAGENS_EXCLUIDAS")		
		oAttrib:lSet("NOME", STR0030)//"Itens Excluídos"
		oNodeItem:oAddChild(TBIXMLNode():New("MENSAGENS_EXCLUIDAS", "", oAttrib))
		
		oXMLNode:oAddChild(oNodeItem)

		if(oTable:lValue("ADMIN"))
			// Diretorio de usuarios
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", 1)
			oAttrib:lSet("NOME", 	STR0019)//"Cadastro de Usuários"
			oAttrib:lSet("FEEDBACK", 0)
			oXMLNode := oXMLNode:oAddChild(TBIXMLNode():New("DIRUSUARIOS","",oAttrib))
	
			if(::foSecurity:lHasAccess("GRUPO", "", "CARREGAR"))
				oXMLNode:oAddChild(::oGetTable("GRUPO"):oArvore())
			endif			
		
			//Arvore do usuario
			oXMLNode:oAddChild(::oGetTable("USUARIO"):oArvore())
		else
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", oTable:cValue("ID"))
			oAttrib:lSet("NOME", alltrim(oTable:cValue("COMPNOME")))
			oXMLNode:oAddChild(TBIXMLNode():New("USUARIO", "", oAttrib))
		endif
	else
		oXMLArvore:oAddChild(::oGetTable("SCORECARD"):oArvore(.T.))
	endif	
	
return oXMLArvore

/*-------------------------------------------------------------------------------------
@method oAncestor(cParentType, oChildTable)
Retorna uma tabela ancestral posicionada.
@param oChildTable - Tabela de entidade aberta e posicionada.
@param cParentType - Tipo da entidade a ser localizada como ancestral.
@return - Tabela de entidade ancestral de oTable.
--------------------------------------------------------------------------------------*/
method oAncestor(cParentType, oChildTable) class TKPICore
	local oTable, nPos, nOrder, nIDFinal
	local oAncestor := ::oGetTable(cParentType)
	local nParentID := oChildTable:nValue("PARENTID")

	while(oChildTable != oAncestor)
		// Encontro tabela anterior posicionada
		nPos := aScan(::faTables, { |x| x[5] == oChildTable })

		oTable := ::oGetTable(::faTables[nPos][4])
		if(valtype(oTable)!="U")
			nOrder := oTable:nGetOrder()
			oTable:SavePos()
			oTable:lSeek(1, {nParentID})
			oTable:cSqlFilter("")
			nParentID := oTable:nValue("PARENTID")
			nIDFinal := oTable:nValue("ID")
			oChildTable := oTable
			oTable:RestPos()
		else
			exit
		endif
	end

	if(valtype(oTable)!="U")
		oChildTable:lSeek(1, {nIDFinal})
		oChildTable:SetOrder(nOrder)
	endif

return oChildTable

/*-------------------------------------------------------------------------------------
@method LanguageInit()
Escreve os arquivos properties de internacionalização do Java.
--------------------------------------------------------------------------------------*/
method LanguageInit() class TKPICore
	local cDefault, cResource, cTexto, cLocale
	local aFiles, oPropFile, nInd, nCount
	
	// Internacionalização
	cDefault := ::cKpiPath()+"international.properties"
	if( cKPILanguage() == "PORTUGUESE" )
		cLocale := "pt_BR"
		cResource := ::cKpiPath()+"international_pt_BR.properties"
	elseif (  cKPILanguage() == "ENGLISH" )
		cLocale := "en"
		cResource := ::cKpiPath()+"international_en.properties"
	elseif ( cKPILanguage() =="SPANISH" )
		cLocale := "es"
		cResource := ::cKpiPath()+"international_es.properties"
    endif
    
	// cTexto deve ter o conteudo do arquivo properties	
	cTexto := cKPIInternational()
	
	// Arquivo default e da linguagem
	aFiles := {cDefault, cResource}
	for nInd := 1 to len(aFiles)
		oPropFile := TBIFileIO():New(aFiles[nInd])
		//if(!oPropFile:lExists())
		if(!oPropFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
			::Log(STR0011+oPropFile:cFileName(), KPI_LOG_RAISE)/*//"Erro na criação do arquivo: "*/
			oPropFile:lClose()
		//	endif	
		endif
	
		nCount := 0
		while((!oPropFile:lOpen(FO_WRITE+FO_EXCLUSIVE)) .and. nCount<60)
			sleep(500)
			nCount++
		enddo

		if(nCount == 30)  // se nao abrir em +-15 segundos da erro no conout e libera a thread
			::Log(STR0012+oPropFile:cFileName(), KPI_LOG_RAISE) //"Aviso: Timeout expirado ao tentar gravar arquivo: "
		else
			oPropFile:nWriteLn(cTexto)
			oPropFile:lClose()
		endif
	next

return   


/*-------------------------------------------------------------------------------------
@method CreatPolicyFile()
Cria o arquivo de .java.policy. Com as diretivas de seguranca para o applet.
--------------------------------------------------------------------------------------*/
method createPolicyFile() class TKPICore
	cFileName 	 := ".java.policy"
	cFileContent := 'grant codeBase "'+ left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER)) + '-" {'					+CRLF+;
	'permission java.security.AllPermission;'+CRLF+;
	'};'
	
	// Gera arquivo
	oFile := TBIFileIO():New(::cKpiPath()+"\"+cFileName)
	
	// Cria o arquivo
	if ! oFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		::Log(STR0013 + cFileName , KPI_LOG_SCRFILE)	//"Erro na criação do arquivo."
		::Log(STR0014, KPI_LOG_SCRFILE)					//"Operação abortada."
	else
		oFile:nWriteLN(cFileContent)
	Endif
	
oFile:lClose()
return
/*-------------------------------------------------------------------------------------
@function KPILogInFile(oFileStream, cText, nType)
Executa a gravação de cText no arquivo em oFileStream segundo critério de nType.
@param oFileStream - Instancia de TBIFileIO
@param cText - Texto a ser trabalhado(logado).
@param nType - Constante identificando a operacao de log (default: KPI_LOG_SCR).
KPI_LOG_SCR - Somente apresenta na console.
KPI_LOG_FILE - Somente grava no arquivo de log.
KPI_LOG_RAISE - Grava no arquivo de log e levanta exceção no Protheus.
KPI_LOG_SCRFILE - Apresenta na console e grava no arquivo de log.
--------------------------------------------------------------------------------------*/
function KPILogInFile(oFileStream, cText, nType)
	local nCount := 0
	
	default nType := KPI_LOG_SCR

	if(nType==KPI_LOG_SCRFILE .or. nType==KPI_LOG_FILE)
		nCount := 0	
		while((!oFileStream:lOpen(FO_WRITE+FO_EXCLUSIVE)) .and. nCount<60)
			sleep(500)
			nCount++
		enddo

		if(nCount == 60)  // se nao abrir em +-30 segundos da erro no conout e libera a thread
			conout(STR0012+oFileStream:cFileName())/*//"Aviso: Timeout expirado ao tentar gravar no arquivo: "*/
		else
			oFileStream:nGoEOF()
			oFileStream:nWriteLn(dtos(date())+"/"+time()+" = "+padr(cText,80)+padr(procname(1),15)+" ("+strZero(procline(1),4)+") ")
			oFileStream:lClose()
		endif
	endif	
	
	if(nType==KPI_LOG_SCR .or. nType==KPI_LOG_SCRFILE)
		Conout(ANSIToOEM(cText))
	endif

	if(nType==KPI_LOG_RAISE)
		ExUserException(cText)
	endif
return

/*-------------------------------------------------------------------------------------
@function KPIFileOpen(oTable, nTentativas)
Executa a abretura de uma tabela.
@param oTable - Nome da tabela
@param nTentativa - Numeros de tentativas de abertura (default: 5)
@return - .T./.F.
--------------------------------------------------------------------------------------*/
function KPIFileOpen(oTable, nTentativas)
	Local lRet := .F., nTry := 0

	Default nTentativas := 5
	
	while(!oTable:lOpen(.t.) .and. nTry < nTentativas)
		sleep(1000)
		nTry++
	enddo      
	
	if(nTry < nTentativas)
		lRet := .T.
	else
		::Log(STR0066, KPI_LOG_SCRFILE) //"Dados não atualizados!"
		::Log(STR0067 + oTable:cTableName() + " !", KPI_LOG_SCRFILE) //"Não foi possivel o acesso exclusivo a tabela "
	endif

return(lRet)

/*-------------------------------------------------------------------------------------
@method cGetParent(oChildTable)
Retorna o nome da Entidade Pai.
@param oChildTable - Tabela de entidade aberta e posicionada.
@return - Nome da Entidade Pai.
--------------------------------------------------------------------------------------*/
method cGetParent(oChildTable) class TKPICore
return ::faTables[aScan(::faTables, { |x| x[5] == oChildTable })][4]

/*-------------------------------------------------------------------------------------
@method cListPessoas(nUserCod)
Retorna uma lista com cod de pessoas associadas a o usuario
@param nUserCod - Codigo do usuario
@return - Lista dos usuarios.
--------------------------------------------------------------------------------------*/
method cListPessoas(nUserCod) class TKPICore
	local oPessoa		:= ::oGetTable("PESSOA")
	local aPessoas		:= {}
	
	oPessoa:SetOrder(4)
	oPessoa:lSeek(4,{nUserCod})
	
	while(!oPessoa:lEof() .And. oPessoa:nValue("USERID") == nUserCod)
		// Nao lista o ID 0, de inclusao
		if(oPessoa:nValue("ID")==0)
			oPessoa:_Next()
			loop
		endif			
		aadd(aPessoas,oPessoa:nValue("ID"))
		oPessoa:_Next()
	enddo                     
	
return "("+	cBIConcatMacro(",", aPessoas ) + ")"


/*-------------------------------------------------------------------------------------
@method aListPessoas(nUserCod)
Retorna uma lista com cod de pessoas associadas a o usuario
@param nUserCod - Codigo do usuario
@return - Lista dos usuarios.
--------------------------------------------------------------------------------------*/
method aListPessoas(nUserCod) class TKPICore
	local oPessoa		:= ::oGetTable("PESSOA")
	local aPessoas		:= {}
	
	oPessoa:SetOrder(4)
	oPessoa:lSeek(4,{nUserCod})
	
	while(!oPessoa:lEof() .And. oPessoa:nValue("USERID") == nUserCod)
		// Nao lista o ID 0, de inclusao
		if(oPessoa:nValue("ID")==0)
			oPessoa:_Next()
			loop
		endif			
		aadd(aPessoas,oPessoa:nValue("ID"))
		oPessoa:_Next()
	enddo                     

return  aPessoas 

/*-------------------------------------------------------------------------------------
@method oOltpController()
Retorna o Controle de Transações
@return - Controle de Transações.
--------------------------------------------------------------------------------------*/
method oCreateBSCCommand(cEntity,cCommand) class TKPICore
	local oBSCCommand	:= TBIXMLNode():New("COMMAND")
	local cEntityType	:= ""
	local oNode 		:= TBIXMLNode():New("INSTRUCTIONS")

	cEntityType	:= ::entityByName( cEntity )

	oNode:oAddChild(TBIXMLNode():New("ENTITY_TYPE_NAME",	cEntity))
	oNode:oAddChild(TBIXMLNode():New("ENTITY_TYPE_CODE",	cEntityType))

	oBSCCommand:oAddChild(oNode)

return oBSCCommand

/*-------------------------------------------------------------------------------------
@method oOltpController()
Retorna o Controle de Transações
@return - Controle de Transações.
--------------------------------------------------------------------------------------*/
method oOltpController() class TKPICore
return ::foOltpController

/*-------------------------------------------------------------------------------------
@method oContext(oChildTable)
Retorna os nomes da entidades, ids e nomes dos ancestrais posicionada.
@param oChildTable - Tabela de entidade aberta e posicionada.
@return - Tabela de entidade ancestral de oTable.
create siga0739 - 04/01/2005
--------------------------------------------------------------------------------------*/
method oContext(oChildTable, nParentInclusao) class TKPICore
	local oAttrib, oNode, oXMLOutput, nInd, cParent
	local oTable, aRetorno := {}
	local nParentID := oChildTable:nValue("PARENTID")

	default nParentInclusao := 0

	if(oChildTable:nValue("ID")==0) //inclusao
		nParentID := nParentInclusao
	endif
	
	cParent := ::cGetParent(oChildTable)
	
	while(!empty(cParent) .and. cParent != "SGI" )
		// Encontro tabela anterior posicionada
		oTable := ::oGetTable(cParent)
		if(valtype(oTable)!="U")
			oTable:SavePos()
			oTable:cSqlFilter("")
			oTable:lSeek(1, {nParentID})
			nParentID := oTable:nValue("PARENTID")
			aAdd(aRetorno,{cParent,oTable:nValue("ID"),oTable:cValue("NOME")})
			oChildTable := oTable
			cParent := ::cGetParent(oChildTable)
			oTable:RestPos()
		else
			cParent := ""
		endif
	end
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("CONTEXTOS",,oAttrib)

	for nInd := 1 to len(aRetorno)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("CONTEXTO"))
		oNode:oAddChild(TBIXMLNode():New("ENTIDADE", aRetorno[nInd][1]))
		oNode:oAddChild(TBIXMLNode():New("ID", aRetorno[nInd][2]))
		oNode:oAddChild(TBIXMLNode():New("NOME", aRetorno[nInd][3]))
	next

return oXMLOutput     

/*-------------------------------------------------------------------------------------
@property nTrade(nValue)
Configura ou Identifica a marca que esta sendo executada no SGI
@param nValue - Numerico identificando a marca que esta usando o sistema/ 1-Microsiga,2-LogoCenter,3-RM
@return - Numerico identificando a marca que esta usando o sistema
--------------------------------------------------------------------------------------*/
method nTrade(fnValue) class TKPICore
	property ::fnTrade := fnValue
return ::fnTrade


/*-------------------------------------------------------------------------------------
@method lRecPassword(cUserName, cEmail)
Envia um e-mail uma nova senha para o usuario.
@return - .T. se o email foi enviado com sucesso
create siga1776 - 19/04/2007
--------------------------------------------------------------------------------------*/
method lRecPassword(cUserName, cEmail) class TKPICore 
	local oUserTable	:= ::oGetTable("USUARIO")	
	local oSendMail		:= ::oGetTable("SMTPCONF")
	local cServer		:= ""
	local cPorta		:= ""
	local cConta		:= ""
	local cAutUsuario	:= ""
	local cAutSenha		:= ""
	local cCopia 		:= ""	
	local cCorpo 		:= ""
	local cAssunto		:= ""
	local cAnexos		:= ""
	local cFrom			:= ""	
	local lValid 		:= .f.	
	local cNewSenha		:= ""
	local lFoundUser	:= .f.
	local lFoundServer	:= .t.
	Local cProtocol := "0"

	if ! oSendMail:lSeek(1,{"1      "})
		//Se nao encontrar pelo id, tenta achar pela ordem
		oSendMail:_First()
		oSendMail:_Next()				
		if oSendMail:lEof()
			lFoundServer := .f.
		endif
	endif

	if lFoundServer
		cServer		:= alltrim(oSendMail:cValue("SERVIDOR"))
		cPorta		:= alltrim(oSendMail:cValue("PORTA"))
		cConta		:= alltrim(oSendMail:cValue("NOME"))
		cAutUsuario	:= alltrim(oSendMail:cValue("USUARIO"))
		cAutSenha	:= alltrim(oSendMail:cValue("SENHA"))
		cFrom		:= "SGI <" + alltrim(oSendMail:cValue("NOME")) + ">"
		cAssunto	:= STR0039//"Recuperação de senha"
		lFoundUser	:= oUserTable:lSeek(2,{cUserName})
		cProtocol := alltrim(oSendMail:cValue("PROTOCOLO"))
		
		if(lFoundUser .and. alltrim(oUserTable:cValue("EMAIL"))==cEmail)
			cNewSenha	:= alltrim(str(randomize(0,999999)))
			cNewSenha	:= padl(cNewSenha,6,"a")
			cCorpo		:= STR0040 + oUserTable:cValue("NOME") + STR0041 + cNewSenha +"."//"A nova senha do usuário: "
			//Gravando a nova senha	
			if oUserTable:lUpdate({{"SENHA",cBIStr2Hex(pswencript(cNewSenha))} })
				lValid := .t.
			endif
		else
			cEmail := cFrom 
			if(lFoundUser)
//				cCorpo := "A requisição de redefinição da senha do usuário " + cUserName + ", não foi atendida porque o e-mail cadastrado não confere com o e-mail solicitado."
				cCorpo := STR0042 + cUserName + STR0043
			else
//				cCorpo := "A requisição de redefinição da senha do usuário " + cUserName + ", não foi atendida porque o usuário não foi encontrado."
				cCorpo := STR0042 + cUserName + STR0044
			endif
		endif
		
		oSendMail:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cEmail, cAssunto, cCorpo, cAnexos, cFrom, cCopia,,cProtocol) 
		
		if(lValid)		
			cEmail := cFrom 
			//Enviando o e-mail para o administrador.
			oSendMail:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cEmail, cAssunto, cCorpo, cAnexos, cFrom, cCopia,,cProtocol)
		endif
	endif
	
return lValid        

/*-------------------------------------------------------------------------------------
Força a atualização das variáveis utilizada pela função MakeID.
@return  
	Nil
--------------------------------------------------------------------------------------*/  
        
Method ResetMakeID() class TKPICore 
	Local nInd                
	Local oTable   
	  
	for nInd := 1 to len(::faTables)
	   oTable := ::oGetTable(::faTables[nInd][3])
	   ClearGlbValue(oTable:fcTableName) 	   
	   oTable:Free()	   
	next 

Return  
           
/*------------------------------------------------------------
Montagem do arquivo JNLP. 
@Return:
	(Caracter) Caminho e nome do arquivo gerado. 	
-------------------------------------------------------------*/    
method CreateJNPL() class TKPICore	                                        
	Local cFile		:= ::cKpiPath() + 'sgi.jnlp'
	Local oFileJNPL := TBIFileIO():New(cFile)     
	Local cHost 	:= KPIFixPath(cBIGetWebHost())                  

	/*Cria o arquivo JNLP*/
	If (!oFileJNPL:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.))
		/*Erro na criação do arquivo.*/
		::Log(STR0013 + cFile , KPI_LOG_SCRFILE)	
	Else
	    /*Escreve o corpo do arquivo.*/
		oFileJNPL:nWriteLn('<?xml version="1.0" encoding="utf-8"?>')		
		oFileJNPL:nWriteLn('<jnlp spec="1.0+" codebase="' + cHost + '" href="sgi.jnlp">')
			   			
		oFileJNPL:nWriteLn('<information>')
				
		/*Define as informações gerais da aplicação.*/
		oFileJNPL:nWriteLn('<title>SGI Desktop</title>')
		oFileJNPL:nWriteLn('<vendor>TOTVS SA</vendor>')
		oFileJNPL:nWriteLn('<homepage href="www.totvs.com.br"/>')
		oFileJNPL:nWriteLn('<description>SGI WebStart</description>') 
				
		/*Define o ícone e a tela inicial.*/
		oFileJNPL:nWriteLn('<icon kind="shortcut" href="imagens/totvs.ico"/>') 
		oFileJNPL:nWriteLn('<icon href="imagens/splash_screen_totvs.jpg" kind="splash"/>') 
			    
		/*Define como será criado o atalho em ambiente Windows.*/
		oFileJNPL:nWriteLn('<shortcut online="true">')         
		oFileJNPL:nWriteLn('<desktop/>')
		oFileJNPL:nWriteLn('<menu submenu="TOTVS"/>')                  
		oFileJNPL:nWriteLn('</shortcut>')
			
		oFileJNPL:nWriteLn('</information>')
			
		/*Define as políticas de segurança da aplicação.*/
		oFileJNPL:nWriteLn('<security>')
		oFileJNPL:nWriteLn('<all-permissions />')
		oFileJNPL:nWriteLn('</security>')
			
		/*Defime o programa inicial a ser executado e os parâmetros necessários.*/
		oFileJNPL:nWriteLn('<application-desc main-class="kpi.applet.KpiApplication">')
		oFileJNPL:nWriteLn('<argument>' + cHost + '</argument>')
		oFileJNPL:nWriteLn('<argument>' + cKPILanguage() + '</argument>')
		oFileJNPL:nWriteLn('<argument>' + Iif(KpiIsDebug(),'T', 'F') + '</argument>')
		oFileJNPL:nWriteLn('<argument>' + getJobProfString("AnalysisMode", ANALISE_PDCA) + '</argument>') 	

		oFileJNPL:nWriteLn('</application-desc>')
		     
		/*Define os recursos necessários para a aplicação.*/
		oFileJNPL:nWriteLn('<resources>')
		oFileJNPL:nWriteLn('<j2se version="1.6+"/>')
		oFileJNPL:nWriteLn('<jar eager="true" href="sgi.jar" main="true"/>')
		oFileJNPL:nWriteLn('</resources>')
			
		oFileJNPL:nWriteLn('</jnlp>')
    EndIf
                                    
	/*Fecha o arquivo.*/
	oFileJNPL:lClose()
	
return cFile  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getStrCustom
Retorna objeto que contem as strings costumizadas pelo cliente
@author     2516 - Lucio Pelinson
@version    P11
@since      06/05/2010
/*/
//-------------------------------------------------------------------------------------
method getStrCustom() class TKPICore
return ::foStrCustom

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} entityByCode
Retorna nome da entidade de acordo com o código interno
@author     BI TEAM
@version    P11
@since      16/08/2011
/*/
//-------------------------------------------------------------------------------------
method entityByCode(cEntityType) class TKPICore
	local cEntity := ""

	do case 
		case cEntityType == CAD_ORGANIZACAO
			cEntity := "ORGANIZACAO"

		case cEntityType == CAD_ESTRATEGIA
			cEntity := "ESTRATEGIA"

		case cEntityType == CAD_PERSPECTIVA
			cEntity := "PERSPECTIVA"

		case cEntityType == CAD_OBJETIVO
			cEntity := "OBJETIVO"

		case cEntityType == CAD_SCORECARD
			cEntity := "SCORECARD"
	endcase

return cEntity

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} entityByName
Retorna código interno da entidade de acordo com o nome
@author     BI TEAM
@version    P11
@since      16/08/2011
/*/
//-------------------------------------------------------------------------------------
method entityByName(cEntityName) class TKPICore
	local cEntity := ""

	cEntityName := upper( allTrim( cEntityName ) )

	do case 
		case cEntityName == "ORGANIZACAO"
			cEntity := CAD_ORGANIZACAO

		case cEntityName == "ESTRATEGIA"
			cEntity := CAD_ESTRATEGIA

		case cEntityName == "PERSPECTIVA"
			cEntity := CAD_PERSPECTIVA

		case cEntityName == "OBJETIVO"
			cEntity := CAD_OBJETIVO

		case cEntityName == "SCORECARD"
			cEntity := CAD_SCORECARD
	endcase

return cEntity

/*------------------------------------------------------------
Remove espaços e tokens da formula criptografada [Hexadecimal]. 
@Param:
	cFormula - Formula em formato Hexadecimal.
@Return:
	Retona a expressão Hexadecimal sem espaços e sem tokens.
-------------------------------------------------------------*/
Function KPILimpaFormula(cFormula)                             
Return Alltrim(StrTran(cFormula ,"|",""))      
                  
/*
--------------------------------------------------------------------------------------
Assegura que os paths utilizados na montagem de endereço completo de arquivos terminem 
com BARRA INVERTIDA. 
@Param
	 (Caracter) cPath  Path a ser tratado.
	 (Caracter) cBar   Barra que será utilizada para na URL. 
@Return
	 (Caracter) Path tratado com BARRA INVERTIDA (Ex.: \System\)
--------------------------------------------------------------------------------------
*/
function KPIFixPath(cPath, cBar)
	Default cBar := "/"	
	
	cPath 	:= Iif( (right(cPath,1) $ "\/"), cPath, cPath + "\" )
   	cPath 	:= StrTran(cPath, "\", cBar)
	cPath 	:= StrTran(cPath, "/", cBar)   

return cPath                  
                      
/*---------------------------------------------------------------------
Criptografia baseada em chave.
@Param:
	cValue - Expressão a ser criptografada.
	cChave - Chave a ser utilizada na criptografia.  
@Return:
 	Retorna o correspondente em Hexadecimal da expressão criptografada [DWCRIPTO]. 	
---------------------------------------------------------------------*/
Function KPICripto(cValue, cChave)     
	Local cCifra 	:= ''
	Local cRet 	:= ''
	Local nLen 	:= 0  

	If !( Vazio(cValue) ) 	   
		cCifra	:= PoliEncript(cValue, cBIStr(cChave), 0)
   	 	nLen 	:= Len(cCifra)
		cRet	:= DWCripto(cCifra, nLen, 0 /*Nunca alterar este valor*/ )
	EndIf
                                       
Return cRet
 
/*------------------------------------------------------------
Descriptografia baseada em chave. 
@Param: 
	cCifra - Conteúdo criptografado pela função KPICripto().
	cChave - Chave utilizada na criptografia. [Default = LS_GetID()]
@Return:
	Retorna a expressão original. 	
-------------------------------------------------------------*/                                  
Function KPIUncripto(cCifra, cChave)
   	Local cRet		:= ''
   	Local cFormula 	:= ''
   	
   	Default cChave 	:= GetGlbValue("LICENSE_KEY") 
   	                             
   	If !( Vazio(cCifra) ) 
   		cFormula 	:= DWUnCripto(cCifra, 0 /*Nunca alterar este valor*/ )
   	  	cRet 		:= PoliEncript(cFormula, cBIStr(cChave) , 1)
   	EndIf  

Return cRet
