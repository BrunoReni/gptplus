// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : DWDefs - Rotinas de apoio a DWDefs.ch
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 20.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

/*
--------------------------------------------------------------------------------------
Executa HTMLBegin (inicializa tHtmPage)
Arg: aoHtmPage -> objeto, tHtmPage j� inicializada
	  anProcID -> num�rico, ID de processo
Ret: oRet -> objeto, tHtmPage inicializada
--------------------------------------------------------------------------------------
*/                                 
function DWHtmBegin(aoHtmPage, anProcID)
	local oRet := aoHtmPage

	if valType(oRet) == "O"
		oRet:flAutoFooter := .f.
	endif

return oRet

/*
--------------------------------------------------------------------------------------
Executa HTMLSession (indica a sess�o de tHtmPage)
Arg: @alInit -> l�gico, indica se j� houve ou n�o inicializa��o
	  aoSession -> objeto, sess�o a ser identificada como corrente
Ret: 
--------------------------------------------------------------------------------------
*/                                 
function DWHtmSession(alInit, aoSession)

	if alInit
		clearVarSetGet("_HTMLLines")
	endif	

	varSetGet("_HTMLLines", { |x| iif(valtype(x)=="U", aoSession, NIL)})
	alInit := .t.

return 

/*
--------------------------------------------------------------------------------------
Verifica se a conex�o ainda � valida
Arg:
Ret: logico
--------------------------------------------------------------------------------------
*/                                 
function DWHttpQuit()
	local lRet := .t.
                                              
	if DWKillApp() .or. (DWisWebEx() .and. !HttpIsConnected())
		break
	endif

return lRet
