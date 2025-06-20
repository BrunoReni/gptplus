// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : JobMonitor - Gerencia a execu��o de JOBS
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 18.01.08 | 0548-Alan Candido | BOPS 139342 - Implementa��o e adequa��o de c�digo, 
//          |                   | em fun��o de re-estrutura��o para compartilhamento de 
//          |                   | c�digo.
// 18.11.08 | 0548-Alan Candido | FNC 00000005741/2008 (P10)
//          |                   | Ajuste no job JOB_BASESXS (JOB011) para utilizar RPC
//          |                   | em todas as suas op��es de processamento
// 05.05.09 | 0548-Alan Candido | FNC 00000009956/2009
//          |                   | Adequa��o do job JOB_BASETOP (job010) para uso em ODBC gen�rico
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "tbiconn.ch"
#include "TopConn.ch"
#include "JobMonit.ch"

/*
--------------------------------------------------------------------------------------
Inicia Job�s do SigaDW
Args: acJob -> string, nome do job
aaArgs -> array, array de parametros
acEnvironment -> string, nome do ambiente de execu��o
alStart -> logico, indica se � para executar SigaDWStart
acSignature -> string, utilizada como coment�rio para reconhecer jobs
pertinentes a um mesmo processo
Ret:
--------------------------------------------------------------------------------------
*/
function DWStartJob(acJob, aaArgs, acEnvironment, alStart, acSignature, alWait, acDW)

default aaArgs := {}
default acEnvironment := GetEnvServer()
default alStart := .F.
default acSignature := ""
default alWait := .f.

//###TODO WORKAROUND para tratar cPaisLoc := "BRA"

if type("oSigaDW") == "O"
	default acDW := oSigaDW:DWCurr()[2]
else 
	default acDW := ""
endif
	
aAdd(aaArgs, acDW)              // Nome do DW selecionado para processamento
aAdd(aaArgs, alStart)           // Executa SigaDWStart?
aAdd(aaArgs, acJob)             // Job a executar
aAdd(aaArgs, acSignature)       // Assinatura para reconhecimento do processo

return StartJob( "DWJobMonitor", acEnvironment, alWait, aaArgs) 

function DWWaitJob(acJob, aaArgs, acEnvironment, alStart, acSignature, acDW)

return DWStartJob(acJob, aaArgs, acEnvironment, alStart, acSignature, .t., acDW)

/*
--------------------------------------------------------------------------------------
Arg: aaArgs -> array, lista de arqumentos.
Ret:
--------------------------------------------------------------------------------------
*/                                         
function DWJobMonitor(aaParams)
	local cSignature := aaParams[len(aaParams)]
	local cJobName := aaParams[len(aaParams)-1]
	local lSigaDW := aaParams[len(aaParams)-2]
	local cDWName := aaParams[len(aaParams)-3]
	#define PARAMS_JOB  4
	
	local aArgs := {}, nInd
	local xRet := NIL
	
	//###TODO WORKAROUND para tratar cPaisLoc := "BRA"
	
	if lSigaDW
		SigaDWStart(,.T.)
		oSigaDW:SelectDW(cDWName)
	else
		public __DWJobName
		public __DWPrefixo := ""
		public __DWTopCon   := -1
		DWLoadCfg() // for�a a carga da configura��o do SigaDW (ini)
	    RPCSetType(3)  
	    
		PREPARE ENVIRONMENT EMPRESA DWEmpresa() FILIAL DWFilial()
		
	endif
	              
	for nInd := 1 to len(aaParams) - PARAMS_JOB
		aAdd(aArgs, aaParams[nInd])
	next
	
	cJobName += "("
	cJobName += DWConcatMacro(",", aArgs)
	cJobName += ")"
	if DWLogCallJob()
		DWLog(STR0001 + cJobName + "[ " + cDWName + "-" + DWEmpresa() + "/" + DWFilial() + " ]") //"Execu��o de "
	endif
	
	xRet := &cJobName
	
	if valType(xRet) == "U"
		DWLog(STR0004 + left(cJobName, at("(", cJobName) - 1)) //"Ocorreu um erro durante execu��o de "
		DWRaise(ERR_006, SOL_004)
	elseif DWLogCallJob()
		DWLog(STR0005 + left(cJobName, at("(", cJobName) - 1)) //"Executou "
	endif
return xRet

/*
--------------------------------------------------------------------------------------
Gera��o da tabela dimens�o tempo (calend�rio)
--------------------------------------------------------------------------------------
*/
static function Job001(adInic, adFinal) //JOB_INITCALEND

	oSigaDW:Calend():StartProc(adInic, adFinal, .t.)

return .t.

/*
--------------------------------------------------------------------------------------
Importa��o de tabelas do SigaAdv
Args: acServer -> string, endere�o do servidor
acEnvironment -> string, ambiente de execu��o
	acEmpresa -> string, c�digo da empresa
acFilial -> string, c�digo da filial
acAlias -> string, alias a ser importado
aaFieldList -> array, lista de campos desejados
aaFirstKey -> array, onde o 1o. elemento identifica a ordem e o 2o. a chave
abForCond -> code-block, bloco de c�digo para avalia��o FOR
abWhile -> code-block, bloco de c�digo para avalia��o WHILE

Ret: aRet -> array, contendo os registros da tabela
--------------------------------------------------------------------------------------
*/
static function Job002(acServer, acEnvironment, acEmpresa, acFilial, acAlias, ;
				aaFieldList, aaFirstKey, abForCond, abWhileCond, acTmpArq) //JOB_IMPORTSIGA
	local oRPCServer, cServer, nPort, nPos
	local aRet

	default aaFieldList := {}
	default aaFirstKey := { 0, "" }
	default acTmpArq := ""

	nPos := at(":", acServer)
	if nPos != 0
		cServer := left(acServer, nPos - 1)
		nPort := val(substr(acServer, nPos+1))
	else
		cServer := acServer
		nPort := DWDefaultPort()
	endif
	
	RPCSetType(3)
	create rpcconn oRPCServer;
		on server cServer PORT nPort;
		environment acEnvironment ;
		empresa acEmpresa filial acFilial clean

	ErrorBlock({|e| __webError(e)})
	
	if valType(oRPCServer) == "O"
		if left(aaFirstKey[2], 9) == "embedsql:"
			callproc in oRPCServer;
				function "RPCDWMain" ;
				parameters "TABLEEMBEDSQL", nil, { substr(aaFirstKey[2], 10), /*DWDIRINCLUDE(),*/ acTmpArq, acEmpresa, acFilial }; 
				result aRet
		else
			callproc in oRPCServer;
				function "RPCDWMain" ;
				parameters "TABLESXLIST", nil, { acAlias, aaFieldList, aaFirstKey,  abForCond, abWhileCond, acEmpresa, acFilial };
				result aRet
		endif
		if valType(aRet) != "A"	
			DWRaise(ERR_006, SOL_004, DWConcatWSep(" ", "DWJOB002" + STR0035, cServer, nPort, acEnvironment, acEmpresa, acFilial), .f.)  //"(retorno)"
		endif

		close rpcconn oRPCServer

	else                             
		conout(STR0034 + " - JOB002")  //"ATEN��O: Ocorreu erro de cria��o de RPC"
		DWRaise(ERR_006, SOL_004, DWConcatWSep(" ", "DWJOB002:", cServer, nPort, acEnvironment, acEmpresa, acFilial), .f.)
	endif

return aRet

/*
--------------------------------------------------------------------------------------
Importa��o de tabelas direto
Args: acFilename -> string, nome completo do arquivo
Ret: aRet -> array, contendo a defini��o de campos da tabela
--------------------------------------------------------------------------------------
*/
function Job003(acFilename) //JOB_IMPORTDIRETO
	local aFName, aTypes, aLen, aDec, aRet, nFCount, nInd

	USE (strTran(acFilename, "/", "\")) ALIAS ("TRA" + DWint2hex(seconds(),4)) NEW VIA RddDefault()
		
	nFCount := fCount()
	aFName := array(nFCount)
	aTypes := array(nFCount)
	aLen   := array(nFCount)
	aDec   := array(nFCount)
	aFields(aFName, aTypes, aLen, aDec)
	aRet := { }
	
	for nInd := 1 to nFCount
		//X3_ORDEM", "X3_CAMPO", "X3_TITULO", "X3_TIPO", "X3_TAMANHO", "X3_DECIMAL"
		aAdd(aRet, {nInd, aFName[nInd], aFName[nInd], aTypes[nInd], aLen[nInd], aDec[nInd] } )
	next
	dbCloseArea()

return aRet

/*
--------------------------------------------------------------------------------------
Cria o cubo fisicamente
Arg: anIDCubo -> integer, ID do cubo a ser inicializado
Ret: lRet -> logico, cria��o Ok
--------------------------------------------------------------------------------------
*/
static function Job005(anCubeID) // JOB_INITCUBE

	local oCube := oSigaDW:OpenCube(anCubeID, .t.)
	oCube:Close()
	
return .t.

/*
--------------------------------------------------------------------------------------
Cria a dimens�o fisicamente
Arg: anIDDim -> integer, ID da dimens�o a ser inicializada
Ret: lRet -> logico, cria��o Ok
--------------------------------------------------------------------------------------
*/                     
static function Job005A(anDimID) // JOB_INITDIM

	local oDim := oSigaDW:OpenDim(anDimID, .t.)
	oDim:Close()

return .t.

/*
--------------------------------------------------------------------------------------
Executa uma consulta
Arg: anID -> integer, ID da consulta a processar
anType -> boolean, tipo da consulta
Ret: lRet -> logico, constru��o ok
--------------------------------------------------------------------------------------
*/
static function Job008(anID, anType, acLogFile) //JOB_EXECCONS
	local oConsulta := TConsulta():New(anID, anType)
	local oFile := TDWFileIO():New(DwTempPath() + "\" + acLogFile)
	local lOk
	
	if oFile:Exists()
		lOk := oFile:Append(FO_EXCLUSIVE)
	else
		lOk := oFile:Create(FO_EXCLUSIVE + FO_WRITE)
	endif
    
	if lOk
		oConsulta:IPC(upper(acLogFile))
		oConsulta:BuildTable()
		oFile:close()
	endif

return lOk

/*
--------------------------------------------------------------------------------------
Conex�o via Top Connect
Arg: anType -> int, tipo do canex�o: 0-teste, 1-lista tabelas, 2-lista campos
acServer -> string, servidor Top Connect
acConType -> string, tipo de conex�o
acDatabase -> string, tipo do banco de dados
acAlias -> string, alias no Top Connect
acTable -> string, noma da tabela
alTop -> boolean, tabela criada pelo Top
Ret: lRet -> logico, execu��o OK
--------------------------------------------------------------------------------------
*/
static function Job010(anType,acServer,acConType,acDataBase,acAlias,acTable,alTop) //JOB_BASETOP
local cAlvo := iif(valType(acTable)=="A",alltrim(acTable[2]), "" )
local cTop := iif(acDataBase=="ODBC","","@!!@"), cAux, lIsTop := .f.
local aRet := {}, aRetTemp := {}, n := 0
local oQuery, aAux
local cServer := extractServer(acServer)
local nPort := extractPort(acServer)

TCCONTYPE(acConType)

if acConType == "APPC"
	if empty(nPort)
		nConecta := TCLINK(cTop+acDataBase, cServer)
	else
		nConecta := TCLINK(cTop+acDataBase, cServer, nPort)
	endif
else
	if "AS" $ acDataBase .and. "400" $ acDataBase         
		if empty(nPort)
			nConecta := TCLINK(acAlias, cServer)
		else
			nConecta := TCLINK(acAlias, cServer, nPort)
		endif
	else
		if empty(nPort)
			nConecta := TCLINK(cTop+acDataBase+"/"+acAlias,cServer)
		else
			nConecta := TCLINK(cTop+acDataBase+"/"+acAlias,cServer, nPort)
		endif
	endif
endIf

if anType == 0
	if nConecta >= 0
		aRet := {STR0017} //"Conex�o bem sucedida"
	elseif nConecta = -1
		aRet := {STR0018 + acServer } //"Falha na conex�o por n�o localizar servidor Top "
	elseif nConecta = -35
		aRet := {STR0019 + acAlias} //"Falha na conex�o por n�o localizar Ambiente "
	else
		aRet := {STR0020} //"Falha na conex�o"
	endif
elseif anType == 1
	if nConecta >= 0                                       
		// Obtem as tabelas (TABLE)
		DbUseArea(.t.,"TOPCONN","TOP_FILES","TRAB")
		WHILE !EOF()
			if left(TRAB->(FNAMF1), 4) == "TOP_" .or. ;
				(SGDB() $ DB_MSSQL_ALL .and. trim(TRAB->(FNAMF1)) == "dtproperties")
			elseif empty(cAlvo) .or. cAlvo $ TRAB->(FNAMF1)
				if tcCanOpen("TOP_FIELD")
	       			oQuery := TQuery():New(DWMakeName("TRA"))
	    	   		oQuery:FieldList("count(*)")
    	 			oQuery:FromList("TOP_FIELD")
    	 			if SGDB() == DB_DB2400
	  					oQuery:WhereClause("FNAMF2 LIKE '%"+TRIM(TRAB->(FNAMF1))+"%'")
    	 			else
	  					oQuery:WhereClause("FIELD_TABLE LIKE '%"+TRIM(TRAB->(FNAMF1))+"%'")
	  				endif
	  				oQuery:WithDeleted(.t.)
  					oQuery:Open()                 

					aAdd(aRet,{DBO_TABLE, Trim(TRAB->(FNAMF1)), Trim(TRAB->(FNAMF1)), oQuery:value(1) > 0})
					oQuery:Close()
				else
					aAdd(aRet,{DBO_TABLE, Trim(TRAB->(FNAMF1)), Trim(TRAB->(FNAMF1)), .f.})
  				endif
			endif
			DbSelectArea("TRAB")				
			DbSkip()
		enddo
		DBCloseArea()

		// Obtem as views (VIEWS)              
		if SGDB() $ DB_MSSQL_ALL
			oQuery := TQuery():New(DWMakeName("TRA"))
			oQuery:FieldList("TABLE_NAME")
 			oQuery:FromList("INFORMATION_SCHEMA.VIEWS")
 			oQuery:WhereClause("TABLE_NAME not in ('syssegments','sysconstraints')")
			if !empty(cAlvo)
				oQuery:WhereClause(oQuery:WhereClause() + " and TABLE_NAME LIKE '%"+cAlvo+"%'")
			endif
			oQuery:WithDeleted(.t.)
			oQuery:Open()
			while !oQuery:Eof()
				aAdd(aRet,{DBO_VIEW, oQuery:value('TABLE_NAME'), oQuery:value('TABLE_NAME'), .F.})
				oQuery:_next()
			enddo
			oQuery:Close()
		endIf            
		aRet := aSort(aRet,,, {|x,y| x[2] < y[2]})
	endIf
else
	if nConecta >= 0
		if alTop 
			// verifica se � uma tabela top-connet
			if tcCanOpen("TOP_FIELD")
	     		oQuery := TQuery():New(DWMakeName("TRA"))
    	 		oQuery:FieldList("count(*)")
  				oQuery:FromList("TOP_FIELD")
				if SGDB() == DB_DB2400
					oQuery:WhereClause("FNAMF2 LIKE '%"+upper(TRIM(acTable))+"%'")				
				else
					oQuery:WhereClause("FIELD_TABLE LIKE '%"+upper(TRIM(acTable))+"%'")
				endif
				oQuery:WithDeleted(.t.)
				oQuery:Open()
	    	    lIsTop := !oQuery:eof() .and. oQuery:value(1) > 0
				oQuery:Close()
			endif
			if lIsTop
				DbUseArea(.t.,"TOPCONN",acTable,"TRAB")
				aRetTemp := TRAB->(DBSTRUCT())
  			endif
		endif
		if !lIsTop
			if SGDB() $ DB_MSSQL_ALL .and. !(upper(left(acTable, 6)) == "SELECT")
	     	oQuery := TQuery():New(DWMakeName("TRAB"), "TRAB")
   	  		    oQuery:FieldList("COLUMN_NAME FName, DATA_TYPE FType, CHARACTER_MAXIMUM_LENGTH FLen")
  				oQuery:FromList("INFORMATION_SCHEMA.COLUMNS")
				oQuery:WhereClause("TABLE_NAME = '"+acTable+"'")
				oQuery:WithDeleted(.t.)
				oQuery:Open()
				while !oQuery:Eof()                
					aAux := { oQuery:value("FName"), oQuery:value("FType"), oQuery:value("FLen"), 0}
					if aAux[2] $ "char\varchar\nvarchar"
						aAux[2] := "C"
					elseif aAux[2] $ "float"
						aAux[2] := "N"
						aAux[3] := 15
						aAux[4] := 2
					elseif aAux[2] $ "int"
						aAux[2] := "N"
						aAux[3] := 10
						aAux[4] := 0
					endif
					aAdd(aRetTemp, aAux)
					oQuery:_next()
				enddo
				oQuery:Close()
			elseif upper(left(acTable, 6)) != "SELECT"
				acTable := "SELECT * FROM " + acTable
				if !(acDataBase == "ODBC")
				  acTable += " WHERE 0=1"
				endif
				
				TCQUERY (dwStripChr(acTable)) new alias "TRAB"
				aRetTemp := TRAB->(DBSTRUCT())
				DBCloseArea()
			else
				TCQUERY (dwStripChr(acTable)) new alias "TRAB"
				aRetTemp := TRAB->(DBSTRUCT())
				DBCloseArea()
			endif
		endif
		aRet := {}                        
		n := 0
		aeval(aRetTemp, { |x| n++, aAdd(aRet, {DWint2hex(n, 2), x[1], x[1], x[2], x[3], x[4] }) })
	endIf
endif

if nConecta >= 0
	TCQUIT()
endif

return aRet

/*
--------------------------------------------------------------------------------------
Testa Conex�o via Protheus SXS
Arg: acServer -> string, servidor Protheus
acEnvironment -> string, ambiente
acEmpresa -> string, codigo da empresa
acFilial -> string, codigo da filial
Ret: lRet -> logico, execu��o OK
--------------------------------------------------------------------------------------
*/
static function Job011(anType, acServer, acEnvironment, acEmpresa, acFilial, acTable) //JOB_BASESXS

local oRPCServer, cServer, nPort, nPos
local aRet := {}, aRetRPC, aParms, bLastError, cMsgErro := ""

nPos := at(":", acServer)
if nPos != 0
	cServer := left(acServer, nPos - 1)
	nPort := val(substr(acServer, nPos+1))
else
	cServer := acServer
	nPort := val(GetPvProfString("TCP", "PORT", dwStr(PORT_PROTHEUS), DWIniFile()))
endif

RPCSetType(3)

create rpcconn oRPCServer;
	on server cServer PORT nPort;
	environment acEnvironment ;
	empresa acEmpresa filial acFilial clean

bLastError := ErrorBlock({|e| __DWRPCError(e, @cMsgErro)})

if valType(oRPCServer) == "O"
	aRetRPC := {}
	aParms := {}
	if anType == 0
		aRetRPC := {STR0021} //"Falha na conex�o"
		callproc in oRPCServer;
		function "RPCDWMain" ;
		parameters "TESTCONNECTSXS", nil, { "0" };
		result aRetRPC
		if valtype(aRetRPC) == "L"
			aRet := {STR0022} //"Conex�o bem sucedida"
		endif
	elseif anType == 1
		callproc in oRPCServer;
			function "RPCDWMain" ;
			parameters "TABLESXLIST", nil, { "SX2", { "X2_CHAVE", "X2_ARQUIVO", "X2_NOME", "X2_PATH", "X2_MODO" }, nil,  acTable, nil, acEmpresa, acFilial };
			result aRet
	elseif anType == 11
		callproc in oRPCServer;
			function "RPCDWMain" ;
			parameters "TABLESXLIST", nil, { "SX9", { "X9_DOM", "X9_CDOM", "X9_EXPDOM", "X9_EXPCDOM" }, { 2, acTable },  nil, nil, acEmpresa, acFilial };
			result aRet
	else
		callproc in oRPCServer;
			function "RPCDWMain" ;
			parameters "TABLESXLIST", nil, { "SX3", { "X3_ORDEM", "X3_CAMPO", "X3_TITULO", "X3_TIPO", "X3_TAMANHO", "X3_DECIMAL" }, { 1, acTable },  nil, nil, acEmpresa, acFilial };
			result aRet
	endif

	close rpcconn oRPCServer
else
	aRet := {STR0020} //"Falha na conex�o"
endif

ErrorBlock(bLastError)

return aRet

/*
--------------------------------------------------------------------------------------
Testa Conex�o via Protheus Direto
Arg: acServer -> string, servidor Protheus
acCaminho -> string, diret�rio a partir da raiz do Protheus
Ret: lRet -> logico, execu��o OK
--------------------------------------------------------------------------------------
*/ 
static function Job012(anType, acServer, acEnvironment, acPath, acTable, acEmpresa, acFilial, acFilter) /*JOB_BASEDIR*/

	Local oRPCServer  
	Local cServer, cMsgErro := '', cExt := '', cFile := '', cSIGAMAT := 'SIGAMAT.EMP'
	Local nPort, nPos, nI 
	Local aParms, aRetRPC, aAux := {}, aSigaMat := {}, aRet := {STR0021} /*"Falha na conex�o"*/
	Local bLastError 
	
	Default acEmpresa 	:= DWEmpresa()
	Default acFilial 	:= DWFilial()
	Default acFilter 	:= ''     
                    
	acPath := dwFixPath(acPath)
	/*Verifica se a porta foi infomada juntamente com o nome do servidor.*/
	nPos := at(":", acServer)
	
	if nPos != 0
		cServer := left(acServer, nPos - 1)
		nPort := val(substr(acServer, nPos+1))
	else  
		cServer := acServer
		nPort := DWDefaultPort()
	endif
	
	RPCSetType(3)  
	
	/*Cria uma conex�o RPC com os par�metros recebidos.*/
	create rpcconn oRPCServer;
		on server cServer PORT nPort;
		environment acEnvironment;
		empresa acEmpresa filial acFilial clean  
		
	
	
	bLastError := ErrorBlock({|e| __DWRPCError(e, @cMsgErro)})
	
	if valType(oRPCServer) == "O"
		
		/*Recupera a extens�o dos arquivos do dicion�rio do alvo do RPC.*/	
		callproc in oRPCServer;
			function 'getDbExtension';
			result cExt
		
		/*Realiza o teste de conex�o.*/
		if anType == 0
			callproc in oRPCServer;
				function "RPCDWMain" ;
				parameters "TESTCONNECTDIR", nil, { acPath };
				result aRetRPC  
			
			if valtype(aRetRPC) == "L"
				if aRetRPC
					aRet := {STR0023} /*"Conex�o bem sucedida. Caminho OK"*/
				else
					aRet := {STR0024} /*"Erro: Caminho n�o localizado. (Conex�o OK)"*/
				endif
			endif 
		
		/*Recupera, sem RPC, a lista de arquivos de um determinado diret�rio.*/				
		elseif anType == 1             
			aRet := {directory(allTrim(acPath) + "*" + allTrim(cExt))}
			
		/*Recupera a lista de arquivos de um determinado diret�rio.*/
		elseif anType == 11  
			/*Recupera a lista de arquivos que tenham a extens�o do ambiente*/
			callproc in oRPCServer;
				function 'directory';
				parameters allTrim(acPath) + "*" + allTrim(cExt);
				result aRet 
			
			/*Recupera o arquivo sigamat.emp*/
			callproc in oRPCServer;	
				function 'directory';
				parameters allTrim(acPath) + cSIGAMAT;
				result aSigaMat 
                      
    		/*Atribui o arquivo sigamat.emp na lista de retorno da fun��o*/     
			if (len(aSigaMat)> 0)				    
			    aAdd(aRet, aSigaMat[1])
			endif
    
    		/*Realiza o filtro na lista de arquivos.*/  
			if (len(aRet) > 0 .and. !(acFilter == '')) 
				for nI := 1  to len(aRet)
					if (Upper(acFilter) $ Upper(aRet[nI][1])) 
					     aAdd(aAux,aRet[nI])
					endif									    
			    next nI
			endif 
			
			/*Atribui a lista, com o filtro, ao retorno da fun��o.*/ 
			if (len(aAux) > 0 .or. !(acFilter == '')) 
			    aRet := aClone(aAux)			
			endif   
				
		/*Recupera a lista de campos de um determinado arquivo.*/
		else	
			/*Verifica se o arquivo lido � o 'SIGAMAT.EMP'*/
			if (acTable $ cSIGAMAT)
			     cFile := cSIGAMAT 
			else
			     cFile := allTrim(acTable) + allTrim(cExt)
			endif
			
			/*Retorna a lista de campos do arquivo*/	   	   			
			callproc in oRPCServer;
				function "Job003";
				parameters allTrim(acPath) + cFile;
				result aRet 
			
			if valtype(aRet) != "A"
			  aRet := {}
			endif 
			
		endif   
		
	   close rpcconn oRPCServer
	    
	endif
	
	ErrorBlock(bLastError)

return aRet

/*
--------------------------------------------------------------------------------------
Executa SP em outra conex�o
acServer -> string, servidor Top Connect
acConType -> string, tipo de conex�o
acDatabase -> string, tipo do banco de dados
acSP -> string, nome da SP
axP? -> express�o, lista de parametros (max. 10)
Ret: aRet -> array, parametros retornados pela SP
--------------------------------------------------------------------------------------
*/
static function Job013(acServer,acConType,acDataBase,acAlias, acSP, axP1, axP2, axP3, axP4, axP5, axP6, axP7, axP8, axP9, axP0) //JOB_EXECSP
local aRet := NIL, nConecta
local cServer := extractServer(acServer)
local nPort := extractPort(acServer)

TCCONTYPE(acConType)

if acConType == "APPC"
	if empty(nPort)
		nConecta := TCLINK(acDataBase, cServer)
	else
		nConecta := TCLINK(acDataBase, cServer, nPort)
	endif
else
	if "AS" $ acDataBase .and. "400" $ acDataBase
		if empty(nPort)
			nConecta := TCLINK(acDataBase, cServer)
		else
			nConecta := TCLINK(acDataBase, cServer, nPort)
		endif
	else                                                 
		if empty(nPort)
			nConecta := TCLINK(acDataBase+"/"+acAlias, cServer)
		else
			nConecta := TCLINK(acDataBase+"/"+acAlias, cServer, nPort)
		endif
	endif
endIf

if nConecta >= 0
	aRet := DWExecSP(acSP, axP1, axP2, axP3, axP4, axP5, axP6, axP7, axP8, axP9, axP0, .t.)	
elseif nConecta = -1
	DWLog(STR0018 + acServer) //"Falha na conex�o por n�o localizar servidor Top "
elseif nConecta = -35
	DWLog(STR0019 + acAlias) //"Falha na conex�o por n�o localizar Ambiente "
else
	DWLog(STR0020) //"Falha na conex�o"
endif

if nConecta >= 0
	TCQUIT()
endif

return aRet

/*
--------------------------------------------------------------------------------------
Envia e-mails
acSubject -> string, assunto 
acText -> string, texto (corpo da mensagem
acTo -> string, destinatatio
acCc -> string, com copia (destinatario)
aaAttachs -> array, lista de anexoes
acEmpresa -> string, c�digo da empresa
acFilial -> string, c�digo da filial
acBcc -> string, copia oculta (destinatario)
Ret: boolean -> sempre retorna .t.
--------------------------------------------------------------------------------------
*/
static function Job014(acSubject, acText, acTo, acCc, aaAttachs, acEmpresa, acFilial, acBcc) //JOB_SENDMAIL
	
	DWSendMail(acSubject, acText, acTo, acCc, aaAttachs, acEmpresa, acFilial, acBcc)

return .t.
	
static function doGetSubDir(paRet, paCaminho, poRPC)
	local aRet
	local nInd	
                         
	for nInd := 1 to len(paRet)
		if left(paRet[nInd,1],1) != "."
			callproc in poRPC;
			function "directory";
			parameters iif(paCaminho=="\","",paCaminho) + "\" + paRet[nInd,1] +"\*.", "D" ;
			result aRet
			
			if valType(aRet) == "A" .and. len(aRet) != 0
				aAdd(paRet[nInd], aRet)
				doGetSubDir(aRet, iif(paCaminho=="\", "",paCaminho) + "\" + paRet[nInd,1], poRPC)
			endif
		endif
	next
return

/*
--------------------------------------------------------------------------------------
Responde as chamadas RPC
Args: acComando -> string, comando RPC
aaParms -> array, contem os parametros complementares conforme o acComando
Ret: xRet -> express�o, valor a ser retornado pelo RPC
--------------------------------------------------------------------------------------
*/
static _RPCMsgErro

function RPCDWMain(acComando, alSigaDW, aaParms)
	local xRet
	default alSigaDW := .f.
	acComando := upper(acComando)                         
	if acComando == "MSGERRO"
		xRet := _RPCMsgErro
	else                               
		if alSigaDW
			SigaDWStart(,.T.)
		endif
		_RPCMsgErro := ""
		if acComando == "FIELDLIST"
			if len(aaParms) != 4
				aSize(aaParms, 4)
			endif
			xRet := RPCFieldList(aaParms[1], aaParms[2], aaParms[3], aaParms[4])
//		elseif acComando == "STARTIMP"   -- comando desativado Alan Candido
//			if len(aaParms) < 3
//				aSize(aaParms, 3)
//			endif
//			xRet := RPCStartImp(aaParms[1], aaParms[2], aaParms[3])
		elseif acComando == "DIMLIST"
			if len(aaParms) != 4
				aSize(aaParms, 4)
			endif
			xRet := RPCDimList(aaParms[1], aaParms[2], aaParms[3], aaParms[4])
		elseif acComando == "WAITFOR"
			xRet := RPCWaitFor(aaParms[1])
		elseif acComando == "TESTCONNECTSXS"
			xRet := .T.
		elseif acComando == "TESTCONNECTDIR"
			xRet := RPCTestConnectDir(aaParms[1])
		elseif acComando == "TABLESXLIST"                                                        
			if valType(aaParms[4]) != "U"
				aaParms[4] := &("{||"+aaParms[4]+"}")
			endif
			if valType(aaParms[5]) != "U"
				aaParms[5] := &("{||"+aaParms[5]+"}")
			endif
			xRet := RPCTableSXList(aaParms[1],aaParms[2],aaParms[3], aaParms[4], aaParms[5], aaParms[6], aaParms[7])
		elseif acComando == "TABLEEMBEDSQL"
			xRet := RPCTableEmbedSql(aaParms[1], aaParms[2], aaParms[3], aaParms[4])
		elseif acComando == "FILEEXIST"
			xRet := RPCFileExist(aaParms[1], aaParms[2], aaParms[3], aaParms[4], aaParms[5])
		elseif acComando == "FILETYPE"
			xRet := RPCFileType(aaParms[1])
		endif
		if type("oSigaDW") == "O"
			oSigaDW:Log("RPC " + acComando + STR0025) //" (finalizado)"
			if !empty(_RPCMsgErro)
				oSigaDW:Log(STR0036 + acComando, _RPCMsgErro)  //"Erro RPC "
			endif
		else

			if !empty(_RPCMsgErro)
				conout(STR0036 + acComando, _RPCMsgErro)  //"Erro RPC "
			endif
		endif
	endif

return xRet

static function RPCFieldList(acTipo, acDW, acCubo, acDim)
	local aRet := { }
	local oFactFields
	local oDim, oDimFields
	default acDim = ""

	if oSigaDW:SelectDW(acDW)
		oCubes := oSigaDW:Cubes():CubeList()
		if oCubes:Seek(2, { acCubo })
			if acTipo == "FACT"
				oFactFields := InitTable(TAB_FACTFIELDS)
				if oFactFields:Seek(3, { oCubes:Value("id") } )
					while !oFactFields:Eof() .and. oFactFields:value("ID_CUBES") == oCubes:Value("id")
						if oFactFields:value("classe") != "C"
							aAdd(aRet, { oFactFields:value("nome"), oFactFields:value("tipo"), oFactFields:value("tam"), oFactFields:value("ndec") } )
						endif
						oFactFields:_Next()
					enddo
				else
					_RPCMsgErro := STR0026 + acDW + ":" + acCubo + STR0027 //"Cubo [ "###" ] n�o possue tabela de fatos"
				endif
			else
				oDim := InitTable(TAB_DIMENSAO)
				if !empty(acDim) .and. oDim:Seek(4, { oCubes:Value("id"), acDim } )
					oDimFields := InitTable(TAB_DIM_FIELDS)
					if oDimFields:Seek(2, { oDim:Value("id") } )
						while !oDimFields:Eof() .and. oDimFields:value("ID_DIM") == oDim:Value("id")
							aAdd(aRet, { oDimFields:value("nome"), oDimFields:value("tipo"), oDimFields:value("tam"), oDimFields:value("ndec") } )
							oDimFields:_Next()
						enddo
					else
						_RPCMsgErro := STR0026 + acDW + ":" + acCubo + ":" + acDim + STR0028 //"Cubo [ "###" ] n�o possue tabela de dimens�o"
					endif
				else
					_RPCMsgErro := STR0026 + acDW + ":" + acCubo + ":" + acDim + STR0029 //"Cubo [ "###" ] n�o � uma dimes�o v�lida"
				endif
			endif
		else
			_RPCMsgErro := STR0026 + acDW + ":" + acCubo + STR0030 //"Cubo [ "###" ] n�o localizado"
		endif
	else
		_RPCMsgErro := STR0031 + acDW + STR0030 //"Datawarehouse [ "###" ] n�o localizado"
	endif

return aRet

static function RPCDimList(acTipo, acDW, acCubo, acDimensao)
	local aRet := { }, oCube, nDim, aFields, oCubes
	local cbAux := { || .t. }

	default acDimensao := ""
	if !empty(acDimensao)
		cbAux := { || acDimensao == oCube:DimProp("nome", nDim)}
	endif

	if oSigaDW:SelectDW(acDW)
		oCubes := oSigaDW:Cubes():CubeList()
		if oCubes:Seek(2, { acCubo })
			if oSigaDW:VerifyCube(oCubes:value("id"))
				oCube := oSigaDW:OpenCube(oCubes:value("id"))
				for nDim := 1 to len(oCube:DimProp("nome"))
					if eval(cbAux)
						aAdd(aRet, { oCube:DimProp("nome", nDim), ;
						oCube:DimProp("fieldlist", nDim), ;
						oCube:DimProp("keylist", nDim) })
					endif
				next
			else
				_RPCMsgErro := STR0032 + acDW + ":" + acCubo + " ]" //"Falha na verifica��o do cubo [ "
			endif
		else
			_RPCMsgErro := STR0026 + acDW + ":" + acCubo + STR0030 //"Cubo [ "###" ] n�o localizado"
		endif
	else
		_RPCMsgErro := STR0031 + acDW + STR0030 //"Datawarehouse [ "###" ] n�o localizado"
	endif

return aRet

/*
ROTINA DESATIVADA - mantida para posterior reativa��o
Alan Candido
###############################################################

static function RPCStartImp(acFilename, acSignature, alWaitFor)

	default alWaitFor := .f.

	DWStartJob(JOB_READSCRIPT, { acFilename, acSignature, alWaitFor }, GetEnvServer(), .T., acSignature)

return .T.

###############################################################
*/

function RPCWaitFor(acSignature)
	local aInfo
	local nPos := -1
	local nThreadID := ThreadID()

	while nPos <> 0 .and. !DWKillApp()
		aInfo := oProcess:ThreadsInfo()
		nPos := ascan(aInfo, {|x| x[3] != nThreadID .and. acSignature $ x[11] })
		if nPos <> 0
			sleep(15000)
		endif
	enddo

return .T.
  

static function RPCTestConnectDir(acCaminho)	
	Local lRet	:= .F.

   	//Determina se o servidor est� rodando em Linux ou Windows. 	
   	lRet := file(acCaminho + iif (isSrvUnix(), "\.", "\*.*" ))

	if !lRet		
		_RPCMsgErro := "[ " + acCaminho + STR0030 //" ] n�o localizado"
	endif
return lRet


static function auxTableSXList(paFields, paRet)
	local aAux := {}

	aeval(paFields, {|x| aAdd(aAux, FieldGet(x))})
	aAdd(paRet, &(DWStr(aAux,.t.)))

return .t.

static function RPCTableSXList(pcAlias, paFieldList, paFirstKey, pbForCond, pbWhileCond, acEmpresa, acFilial)
	local aRet, aField, cFilterSX, aAreaSX
	local bEachRec := { || auxTableSXList(aFields, aRet) }
	public _MAST_KEY, _MAST_KEYLEN

	RPCSetType(3)
	Prepare Environment Empresa acEmpresa Filial acFilial
	
	dbSelectArea(pcAlias)        

	if valType(pbForCond) == "C"
		pbForCond := &("{||"+pbForCond+"}")
	endif
	if valType(pbWhileCond) == "C"
		pbWhileCond := &("{||"+pbWhileCond+"}")
	endif
	cFilterSX := DbFilter()
	aAreaSX := GetArea()
	set filter to 
  dbGoTop()

	aRet := {}
	aFields := {}
	
	if len(paFieldList) > 0  
		aEval(paFieldList, { |x| aAdd(aFields, FieldPos(x))})
	else
		aFields := array(fCount())
		aEval(aFields, { |x,i| aFields[i] := i})
	endif
	
	if valType(paFirstKey) == "A" .and. paFirstKey[1] != 0
		dbSetOrder(paFirstKey[1])
		dbSeek(paFirstKey[2], .t.)
		_MAST_KEY := paFirstKey[2]
		_MAST_KEYLEN := len(_MAST_KEY)
		default pbWhileCond := { || _MAST_KEY == left(&(indexkey()), _MAST_KEYLEN) }
	endif
	
	dbEval(bEachRec, pbForCond, pbWhileCond, , , .t.)
	
	RestArea(aAreaSX)	
	set filter to &(cFilterSX)

return aRet

static function RPCTableEmbedSql(pcSQL, /*acDirInclude,*/ acDWDSTmpArq, acEmpresa, acFilial)
	local aRet := NIL
    local cSQLResult := ""
	if dwUseEmbSQL("DWIMPSTR", pcSQL, nil, /*acDirInclude,*/ acDWDSTmpArq, acEmpresa, acFilial)
		aRet := {}                  
		//"X3_ORDEM", "X3_CAMPO", "X3_DESCRIC", "X3_TIPO", "X3_TAMANHO", "X3_DECIMAL", "X3_PICTURE"})
		aEval(DWIMPSTR->(DBStruct()), { |x, i| aAdd(aRet, { i, x[1], x[1], x[2], x[3], x[4], "" })})
		DWIMPSTR->(dbCloseArea())
	endif	

return aRet


static function RPCFileExist(acWD, acFile, alSXFile, acEmpresa, acFilial)
	local lRet

	if alSXFile
		RPCSetType(3)
		prepare environment empresa acEmpresa filial acFilial
		lRet := ChkFile(acFile)
	else
		lRet := file(acWD + acFile)
	endif		    

	if !lRet		
		_RPCMsgErro := "[ " + acFile + STR0030 //" ] n�o localizado"
	endif
	
return lRet

static function RPCFileType(acFile)
	local cRet := FT_ERROR
	    
	acFile := upper(right(acFile,4))
	if acFile == ".TXT"
		cRet := FT_TEXT   
	elseif acFile == ".DBF" .or. acFile == ".EMP" .or. acFile == ".DTC"
		cRet := FT_XBASE
	elseif acFile == ".XXX"
		cRet := FT_SX
	else
		_RPCMsgErro := "[ " + acFile + STR0033 //" ] n�o foi possivel determinar o tipo do arquivo"
	endif
	
return cRet
      
static function extractPort(acServer)
	local nPos := at(":", acServer)
	local nRet := 0
	
	if nPos != 0
		nRet := dwval(substr(acServer, nPos+1))
	endif  

return nRet

static function extractServer(acServer)
	local nPos := at(":", acServer)
	local cRet := acServer
	
	if nPos != 0
		cRet := left(cRet, nPos-1)
	endif  

return cRet

static function ParaEvitarAvisoErroAoCompilar()

	if .f.    
		JOB001(); JOB002(); JOB005(); JOB005A(); JOB008()
		JOB010(); JOB011(); JOB012(); JOB013(); JOB014()
		ParaEvitarAvisoErroAoCompilar()
	endif

return


