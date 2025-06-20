#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

#DEFINE SEP_FIELDS ";"
Function GFEXWS()
Return

//----------------------------------------------------------------------------//
// Inicio Webservice
//----------------------------------------------------------------------------//  
WSSERVICE WSGFE DESCRIPTION "Servi�o de integra��o do Frete Embarcador (SIGAGFE)"
 
 WSDATA cRetorno 	as String
 WSDATA nRetorno 	as Integer
 WSDATA cTabela 	as String  
 WSDATA cCodInt 	as String
 WSDATA cDados  	as String
 WSDATA cFil 		as String
 WSDATA cOrigem 	as String
 WSDATA cParamSim 	as String 
 WSDATA cDadosGW1 	as String 
 WSDATA cDadosGW8 	as String 
 WSDATA cDadosGWU 	as String
 WSDATA cGW1FILIAL 	as String 
 WSDATA cGW1CDTPDC 	as String
 WSDATA cGW1EMISDC 	as String
 WSDATA cGW1SERDC  	as String
 WSDATA cGW1NRDC 	as String
 WSDATA cOPER 		as String
 WSDATA cChaveFt	as String
 WSDATA cParte		as String
 
 WSMETHOD PUTDATA DESCRIPTION "M�todo para inclus�o de registros"
 WSMETHOD DELDATA DESCRIPTION "M�todo para exclus�o de registros"
 WSMETHOD CONTTAB DESCRIPTION "Retorna o numero de registro de uma tabela com origem ERP e com situa��o ativo"
 WSMETHOD GETDATA DESCRIPTION "Retorna dados dos registros de uma determinada tabela"
 WSMETHOD SETDATA DESCRIPTION "M�todo para realizar altera��es da situa��o de integra��o de um registro"
 WSMETHOD UNDOINT DESCRIPTION "M�todo para restaurar a situa��o de integra��o de um registro j� integrado (descontinuado)"
 WSMETHOD SIMULATION DESCRIPTION "Realiza a simula��o de fretes"
 WSMETHOD CANCELADOCCARGA DESCRIPTION "Realiza o cancelamento do documento de carga"
 WSMETHOD PARTGETDATA DESCRIPTION "Retorna os dados do registro de uma determinada tabela em partes"
 WSMETHOD PARTGETDC DESCRIPTION "Retorna os dados do registro de uma determinada tabela em partes com chave"
  
ENDWSSERVICE
//----------------------------------------------------------------------------//
// Metodo PUTDATA
//----------------------------------------------------------------------------// 
WSMETHOD PUTDATA WSRECEIVE cTabela,cDados WSSEND cRetorno WSSERVICE WSGFE
	aDados := GFEWSDados(cDados)
	::cRetorno := GFEWSPUTD(cTabela,aDados)

Return .T.

//----------------------------------------------------------------------------//
// Metodo DELDATA
//----------------------------------------------------------------------------// 
WSMETHOD DELDATA WSRECEIVE cTabela,cDados WSSEND cRetorno WSSERVICE WSGFE
	
	aDados := GFEWSDados(cDados)
	::cRetorno := GFEWSDELD(cTabela,aDados)
	
Return .T.
 
//----------------------------------------------------------------------------//
// Metodo CONTTAB
//----------------------------------------------------------------------------// 
WSMETHOD CONTTAB WSRECEIVE cTabela,cDados WSSEND nRetorno WSSERVICE WSGFE
Local aRetIni

aRetIni := GFEWSInit()

if aRetIni[1]

	If len(Alltrim(cTabela)) > 3
		::nRetorno := "Nome da tabela deve conter apenas 3 letras"
		Return .T.
	Endif
	::nRetorno := GFEX101CON(cTabela)
Else
	::nRetorno := aRetIni[2]
EndIf

Return .T.      

//----------------------------------------------------------------------------//
// Metodo GETDATA
//----------------------------------------------------------------------------// 
WSMETHOD GETDATA WSRECEIVE cTabela,cCodInt,cFil WSSEND cRetorno WSSERVICE WSGFE
Local aRetIni

aRetIni := GFEWSInit()

if aRetIni[1]
	::cRetorno := GFEWSGETDATA(cTabela,cCodInt,cFil)
Else
	::cRetorno := aRetIni[2]
EndIf

Return .T.   

//----------------------------------------------------------------------------//
// Metodo PARTGETDATA
//----------------------------------------------------------------------------// 
WSMETHOD PARTGETDATA WSRECEIVE cTabela,cCodInt,cFil,cParte WSSEND cRetorno WSSERVICE WSGFE
	Local aRetIni
	
	aRetIni := GFEWSInit()
	
	if aRetIni[1]
		::cRetorno := GFEWSGETDATA(cTabela,cCodInt,cFil,cParte)
	Else
		::cRetorno := aRetIni[2]
	EndIf
Return .T. 

//----------------------------------------------------------------------------//
// Metodo PARTGETDC
//----------------------------------------------------------------------------// 
WSMETHOD PARTGETDC WSRECEIVE cTabela,cCodInt,cFil,cChaveFt,cParte WSSEND cRetorno WSSERVICE WSGFE
	Local aRetIni
	
	aRetIni := GFEWSInit()
	
	if aRetIni[1]
		::cRetorno := GFEWSGETDC(cTabela,cCodInt,cFil,cChaveFt,cParte)
	Else
		::cRetorno := aRetIni[2]
	EndIf
Return .T. 
             
//----------------------------------------------------------------------------//
// Metodo SETDATA
//----------------------------------------------------------------------------// 
WSMETHOD SETDATA WSRECEIVE cTabela,cCodInt,cDados WSSEND cRetorno WSSERVICE WSGFE
Local aRetIni

aRetIni := GFEWSInit()

if aRetIni[1]
	aDados := GFEWSDados(cDados)   
	::cRetorno := GFEWSSETDATA(cTabela,cCodInt,aDados) 
Else
	::cRetorno := aRetIni[2]
EndIf 

Return .T.     

//----------------------------------------------------------------------------//
// Metodo UNDOINT
//----------------------------------------------------------------------------// 
WSMETHOD UNDOINT WSRECEIVE cTabela,cCodInt,cDados WSSEND cRetorno WSSERVICE WSGFE
Local aRetIni

aRetIni := GFEWSInit()

if aRetIni[1]
	aDados := GFEWSDados(cDados)  
	::cRetorno := GFEWSUndo(cTabela,cCodInt,aDados) 
Else
	::cRetorno := aRetIni[2]
EndIf
Return .T.    


/*--------------------------------------------------------------------*/
/*/{Protheus.doc} SIMULATION
Novo m�todo para realizar a simula��o de fretes.
Usado pelo produto padr�o (Origem: PD400, sem consumir licen�a, por�m 
precisa  de um token de conex�o v�lido) ou para chamadas em programas 
customizados (Origem: CUSTOM, consumindo licen�a e n�o precisa de token)

@param cOrigem  	Origem da simula��o (PD4000 ou CUSTOM)
@param cParamSim	Par�metros da simula��o
@param cDadosGW1	Dados do documento de carga
@param cDadosGW8	Dados dos itens
@param cDadosGWU	Dados dos trechos

@author Israel Alcantara Possoli
@since 04/01/2015
@version 1.8
/*/
/*--------------------------------------------------------------------*/
WSMETHOD SIMULATION WSRECEIVE cOrigem,cParamSim,cDadosGW1,cDadosGW8,cDadosGWU WSSEND cRetorno WSSERVICE WSGFE
	Local aRetIni
	Local aParamSim, aDadosGW1, aDadosGW8, aDadosGWU
	Local aOrigem := {}
	Local cToken
	
	cOrigem := Upper(AllTrim(cOrigem))
	
	If Empty(cOrigem)
		::cRetorno := GFEWSRetError("Origem n�o informada.", "WSGFE:SIMULATION", .T.)
		Return .T.	
	EndIf
	
	aOrigem := STRTOKARR(cOrigem, SEP_FIELDS)
	
	cOrigem := aOrigem[1]
	
	If cOrigem != "CUSTOM"
		If Len(aOrigem) < 2
			::cRetorno := GFEWSRetError("Acesso de conex�o com o Frete Embarcador n�o permitido. Token n�o informado.", "WSGFE:SIMULATION", .T.)
			Return .T.			
		EndIf
	
		If !ValidToken(aOrigem[2])
			::cRetorno := GFEWSRetError("Acesso de conex�o com o Frete Embarcador n�o permitido. Token inv�lido.", "WSGFE:SIMULATION", .T.)
			Return .T.			
		EndIf
	EndIF
	
	GFETraceVerbose(GFETraceCfg(), "[WSGFE.SIMULATION] [BEGIN] Mensagem recebida ******* ", .F.)
	
	If cOrigem == "PD4000" .OR. cOrigem == "CUSTOM"
		GFETraceVerbose(GFETraceCfg(), "[WSGFE.SIMULATION] Origem: " + cOrigem , .F.)
		
		aParamSim := GFEWSDados(cParamSim)
		aDadosGW1 := GFEWSDados(cDadosGW1)
		aDadosGW8 := GFEWSMultiDados(cDadosGW8)
		aDadosGWU := GFEWSMultiDados(cDadosGWU)
		
		If ValType(aParamSim) != "A" .OR. Len(aParamSim) < 3
			GFETraceErro(GFETraceCfg(), "[WSGFE.SIMULATION] [" + cOrigem + "] ** Dados dos par�metros da simula��o inv�lido: " + cParamSim, .F.)
			
			::cRetorno := GFEWSRetError("Dados dos par�metros da simula��o inv�lido.", , .T., .F.)
			Return .T.
		EndIf
		
		If ValType(aDadosGW1) != "A" .OR. Len(aDadosGW1) < 17
			GFETraceErro(GFETraceCfg(), "[WSGFE.SIMULATION] [" + cOrigem + "] ** Dados do documento de carga inv�lido:" + cDadosGW1, .F.)
			
			::cRetorno := GFEWSRetError("Dados do documento de carga inv�lido.", , .T., .F.)
			Return .T.
		EndIf
		
		If ValType(aDadosGW8) != "A" .OR. Len(aDadosGW8[1]) < 7
			GFETraceErro(GFETraceCfg(),  "[WSGFE.SIMULATION] [" + cOrigem + "] ** Dados dos itens do documentos de carga inv�lido:" + cDadosGW8, .F.)
			
			::cRetorno := GFEWSRetError("Dados dos itens do documentos de carga inv�lido.", , .T., .F.)
			Return .T.
		EndIf
		
		If ValType(aDadosGWU) != "A" .OR. Len(aDadosGWU[1]) < 6
			GFETraceErro(GFETraceCfg(), "[WSGFE.SIMULATION] [" + cOrigem + "] ** Dados do(s) trecho(s) do documentos de carga inv�lido:" + cDadosGWU, .F.)
			
			::cRetorno := GFEWSRetError("Dados do(s) trecho(s) do documentos de carga inv�lido.", , .T., .F.)
			Return .T.
		EndIf
	Else
		GFETraceErro(GFETraceCfg(), "[WSGFE.SIMULATION] ** Origem da simula��o n�o suportada: " + cOrigem, .F.)
		
		::cRetorno := GFEWSRetError("Origem da simula��o n�o suportada (" + cOrigem + ")", , .T., .F.)
		Return .T.
	EndIF
	
	aRetIni := GFEWSInit()

	If !aRetIni[1]
		GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] [END] Retornando mensagem")
		
		::cRetorno := GFEWSRetError("Erro de conex�o com o Frete Embarcador. Motivo: " + aRetIni[2], , .T., .F.)
		Return .T.
	EndIf
	
	// Inicializa ambiente
	If cOrigem == "CUSTOM"
		If GetGlbValue("GFE_WS_ENV_SOURCE") == "GFEPREPAREIN"
			GFETraceErro(GFETraceCfg(), "[WSGFE.SIMULATION] [" + cOrigem + "] ** Acesso de conex�o com o Frete Embarcador n�o permitido. O servi�o do WebService para m�todos customizados deve ser iniciado com o par�metro PREPAREIN.", .F.)
			
			::cRetorno := GFEWSRetError("Acesso de conex�o com o Frete Embarcador n�o permitido. O servi�o do WebService para m�todos customizados deve ser iniciado com o par�metro PREPAREIN.", , .T., .F.)
			Return .T.		
		EndIf
	EndIf	

	
	GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] cDadosGW1: " + Decode64(cDadosGW1))
	GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] cDadosGW8: " + Decode64(cDadosGW8))
	GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] cDadosGWU: " + Decode64(cDadosGWU))
		
	::cRetorno := Encode64(GFEWSSIMULATION(cOrigem, aParamSim, aDadosGW1, aDadosGW8, aDadosGWU))
		
	GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] [END] Retornando mensagem")
Return .T.



/*--------------------------------------------------------------------*/
/* ValidToken
Valida o token de conex�o recebido pelo Datasul.
Usado pela nova simula��o de fretes para garantir que apenas o produto padr�o
uso o M�todo SIMULATION do WebService com Origem PD400 (n�o consome
licen�a).

@author Israel Alcantara Possoli
@since 04/01/2015
@version 1.8
*/
/*--------------------------------------------------------------------*/
Static Function ValidToken(cTokenComp)
	Local cDate  := DTOS(Date())
	Local nAux_1 := Val(SubStr(cDate, 1, 4))
	Local nAux_2 := Val(SubStr(cDate, 5, 2))
	Local nAux_3 := Val(SubStr(cDate, 7, 2))
	Local cToken   := ""
	Local cTokenAux
	
	nAux_1 := NoRound(nAux_1 / 4, 0) * nAux_3
	nAux_2 := NoRound((nAux_2 * 433) / nAux_3, 0) + 100
	nAux_3 := nAux_3 * 4752
	
	cToken := SubStr(cValToChar(nAux_1), 1, 3) + ;
	          SubStr(cValToChar(nAux_2), 1, 3) + ;
	          SubStr(cValToChar(nAux_3), 1, 3)
	 
	cTokenAux := SubStr(cTokenComp, 1, 3) + ;
			     SubStr(cTokenComp, 5, 3) + ;
			     SubStr(cTokenComp, 9, 3)
			     
	
	
	If SubStr(cTokenAux, 1, 9) == cToken
		Return .T.	
	EndIf
	
Return .F.

//----------------------------------------------------------------------------//
// Metodo CANCELADOCCARGA
//----------------------------------------------------------------------------// 
WSMETHOD CANCELADOCCARGA WSRECEIVE cGW1FILIAL,cGW1CDTPDC,cGW1EMISDC,cGW1SERDC,cGW1NRDC,cOPER WSSEND cRetorno WSSERVICE WSGFE
	Local aRetIni
	Local aRetCanDC
	Local cFilBkp
	
	aRetIni := GFEWSInit()
	
	If aRetIni[1]
		// Realizando o backup da Filial logada
		cFilBkp := cFilAnt
	
		// Necessario executar a altera��o do cFilAnt devio ao compartilhamento de tabelas
		cFilAnt := PADR(cGW1FILIAL,TamSX3("GW1_FILIAL")[1])

		aRetCanDC := GFE44CancelarDC(xFilial("GW1"),;
		 							 PADR(cGW1CDTPDC,TamSX3("GW1_CDTPDC")[1]),;
		 							 PADR(cGW1EMISDC,TamSX3("GW1_EMISDC")[1]),;
		 							 PADR(cGW1SERDC,TamSX3("GW1_SERDC")[1]),;
		 							 PADR(cGW1NRDC,TamSX3("GW1_NRDC")[1]),;
		 							 VAL(cOPER),;
		 							 .F.,; //Define se � apresentada pergunta quanto a op��o executada
		 							 .F.) // Define que a origem n�o deve ser validada
		
		cFilAnt := cFilBkp
		
		If aRetCanDC[1] == .F.
			::cRetorno := FwNoAccent(ANSIToOEM(aRetCanDC[2]))
		Else
			::cRetorno := ""
		EndIf
    Else
		::cRetorno := FwNoAccent(ANSIToOEM(aRetIni[2]))
	EndIf

Return .T.
