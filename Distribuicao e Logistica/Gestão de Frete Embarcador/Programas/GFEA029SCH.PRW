#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029SCH
Fun��o respons�vel pelo schedule

@author Jo�o Leonardo Schmidt
@since 11/03/2019
@version 1.0

/*/
//------------------------------------------------------------------- 
Function GFEA029SCH(aParam)
	RPCSetType(3) // Tipo do licenciamento (necess�rio dessa forma)
	RpcSetEnv(aParam[1],aParam[2],,,"GFE") // Sobe o ambiente do protheus para a empresa/filial do processo do schedule

	GFEA29VENC()
	GFEA29LEM()
	GFEA29NOV()
	GFEA029COT()
Return