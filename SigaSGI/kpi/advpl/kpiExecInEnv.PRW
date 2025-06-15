//######################################################################################
//Projeto: KPI
//Modulo : Ferramentas
//Fonte  : KPIExecInEnv.prw
//---------+-------------------+--------------------------------------------------------
//Data     | Autor             | Descricao
//---------+-------------------+--------------------------------------------------------
//19.05.06 | Alexandre Silva - Estabelece um conexão com um enviroment possibilitando a 
//         | execucao de funcoes neste enviromente.
//--------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "TbiConn.ch"
/*--------------------------------------------------------------------------------------
@class KPIExecInEnv
--------------------------------------------------------------------------------------*/
class KPIExecInEnv from TBIObject
	
	data cServerName
	data oRPC		
	data nPort
	data cEnvironment
	data c_Empresa
	data c_Filial
	data lPrepEnv
	
	method New() constructor
	method NewKPIExecInEnv()
	method xExecFunction(cFunction)
	method lEndConnection()
	method lConnect(cEnviroment) 
	method lFindFunction(cFunName)
	method setEnvironment(cEnv) 
	method setPortNumber(nPortNumber)
	method setServer(cServerName)
	method setFilial(cFil)
	method setEmpresa(cEmp) 
	method setPrepEnv(lPrep) 
	
	
endclass

/*-------------------------------------------------------------------------------------
@contrutor
--------------------------------------------------------------------------------------*/
method New() class KPIExecInEnv

	::NewKPIExecInEnv()
	
return

/*-------------------------------------------------------------------------------------
@method NewKPIExecInEnv - Cricao do objeto
@return - .t. sempre verdadeiro.
--------------------------------------------------------------------------------------*/
method NewKPIExecInEnv() class KPIExecInEnv

	::cServerName	:=	"127.0.0.1"
	::nPort			:=	4321
	::cEnvironment	:=	""
	::c_Empresa		:=	"99"
	::c_Filial		:=	"01"
	::lPrepEnv		:=	.f.

return .t.

/*-------------------------------------------------------------------------------------
@method lConnect(cEnv)
Faz a conexao do enviroment solicitado
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method lConnect() class KPIExecInEnv
	local lOk := .f.
	
	if	empty(::cServerName) .or. empty(::cEnvironment) .or. ;
		empty(::c_Empresa) .or. empty(::c_Filial)
		//::fcLastMsg := STR0001/*//"Parâmetros para conexão insuficientes/inválidos"*/
	else
		
		//RPCSetType(3)
	
		begin sequence
			if ::lPrepEnv
				create rpcconn ::oRPC;
				on server ::cServerName port ::nPort;
				environment ::cEnvironment;            
				empresa ::c_Empresa filial ::c_Filial
			else       
				create rpcconn ::oRPC;
				on server ::cServerName port ::nPort;
				environment ::cEnvironment;            
				empresa ::c_Empresa filial ::c_Filial clean
			endif
		end sequence

		if(valtype(::oRPC) != "U")
			lOk := .t.
		endif
	endif
     
return lOk 

/*-------------------------------------------------------------------------------------
@method setFilial(nFil)
Seta a empresa em que o ambiente cai rodar.
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method setFilial(cFil) class KPIExecInEnv
	::c_Filial := cFil

/*-------------------------------------------------------------------------------------
@method setEmpresa(nEnv)
Seta a empresa em que o ambiente cai rodar.
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method setEmpresa(cEmp) class KPIExecInEnv
	::c_Empresa:= cEmp

/*-------------------------------------------------------------------------------------
@method setEnvironment(cEnv)
Seta o ambiente em que a funcao vai rodar.
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method setEnvironment(cEnv) class KPIExecInEnv
	::cEnvironment := cEnv

/*-------------------------------------------------------------------------------------
@method setPortNumber(nPortNumber)
Seta o numero da porta.
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method setPortNumber(nPortNumber) class KPIExecInEnv
	::nPort := nPortNumber

/*-------------------------------------------------------------------------------------
@method setServer(cServerName)
Seta o nome do servidor para conexao RPC
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method setServer(cServerName) class KPIExecInEnv
	::cServerName := cServerName


/*-------------------------------------------------------------------------------------
@method setServer(cServerName)
Seta se executa o Prepare Env antes de executar a função
@return - .t. se conectar
--------------------------------------------------------------------------------------*/
method setPrepEnv(lPrep) class KPIExecInEnv
	::lPrepEnv := lPrep
/*-------------------------------------------------------------------------------------


@method xExecFunction()
Executa a funcao no enviroment criado
@return - x - O que funcao que foi executada retornar.
--------------------------------------------------------------------------------------*/
method xExecFunction(cFunction) class KPIExecInEnv
    local cParametro 	:= ""
    local cNomeFunc		:= ""
   	private xFunReturn
    
    //Verificamos se possui parametros
    if rat("(",cFunction) > 0
    	//Capturamos somente os parametros e passamos como um único valor para função a ser executada
		cParametro := subStr(cFunction,rat("(",cFunction) ,len(cFunction))
		cParametro := strTran(cParametro,"(","")
		cParametro := strTran(cParametro,")","")
		cParametro := strTran(cParametro,"'","")
		cParametro := strTran(cParametro,'"',"")
		cParametro := alltrim(cParametro)
		
		//Capturamos somente o nome da função
		cNomeFunc := subStr(cFunction,0 ,rat("(",cFunction) -1)
		cNomeFunc := alltrim(cNomeFunc)
	else
		cParametro:= ""
		cNomeFunc := alltrim(cFunction)		
	endif
    
                                  
	CallProc In ::oRPC;
		Function cNomeFunc;
		Parameters cParametro;
		Result xFunReturn  
		

return xFunReturn 

/*-------------------------------------------------------------------------------------
@method lEndConnection()
Finaliza a conecao executada.
@return - x - O que funcao que foi executada retornar.
--------------------------------------------------------------------------------------*/
method lEndConnection() class KPIExecInEnv

	 close rpcconn ::oRPC
	 
return .t.

/*-------------------------------------------------------------------------------------
@methodlFindFunction(cFunName)
Verifica se uma funcao existe em um repositorio especifico.
@return - x - O que funcao que foi executada retornar.
--------------------------------------------------------------------------------------*/
method lFindFunction(cFunName) class KPIExecInEnv
	local lExiste := .f.
	private xFunReturn 
	
	if(valtype(::oRPC) != "U")
		CallProc In ::oRPC;
			Function "FindFunction";
			Parameters cFunName;
			Result xFunReturn
	endif			
	
	lExiste := xFunReturn
	
return lExiste

function _KPIExecInEnv()
return nil