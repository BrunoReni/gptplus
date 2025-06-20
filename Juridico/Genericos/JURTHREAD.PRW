#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE DnToThread   3      //Total de thread dispon�vel para uso, por esta��o de trabalho

Function __JURTHREAD() // Function Dummy
	ApMsgInfo( 'JURTHREAD -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} JURTHREAD
Classa para controle de Thread na emiss�o de Pr�-Fatura.

@author Bruno Ritter
@since 20/10/2016
@version 2.0
/*/
//-------------------------------------------------------------------
Class JURTHREAD

	Data cCodUser
	Data cFunction
	Data nToThread
	Data bLog
	Data lError
	Data aParams
	Data lThreadStar
	Data lAutomato
	Data cLockByName
	Data lLock

	Method New() Constructor
	Method SetParams(aStruct)
	Method GetParams()
	Method SetFunction(cFunction)
	Method GetFunction()
	Method SetToThread(nToThread)
	Method GetToThread()
	Method SetLog()
	Method StartThread()
	Method SetLAutomato()
	Method GetLAutomato()
	
	Method ThreadUp()
	Method ThreadDown()
	Method IsThreadUp()

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor da Classe JURTHREAD

@author Felipe Bonvicini Conti
@since 10/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JURTHREAD

	Self:lError        := .F.
	Self:aParams       := {}
	Self:cCodUser      := __cUserID
	Self:nToThread     := DnToThread
	Self:bLog          := {|| .F. }
	Self:lAutomato     := .F.
	Self:cLockByName := 'JURTHREAD'+ Self:cCodUser
	Self:lLock       := .T.
	
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLAutomato()
M�todo para setar se est� sendo executado como teste automatizado

@author bruno.ritter
@since 02/03/2017
/*/
//-------------------------------------------------------------------
Method SetLAutomato(lAutomato) Class JURTHREAD
Local lRet := .T.

Default lAutomato := .F.

	If !Self:lError .And. ValType(lAutomato) == "L" .And. !Empty(lAutomato)
		Self:lAutomato := lAutomato
		lRet := lAutomato == Self:lAutomato
	Else
		lRet := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GetLAutomato()
M�todo para retornar se est� sendo executado como teste automatizado

@author bruno.ritter
@since 02/03/2017
/*/
//-------------------------------------------------------------------
Method GetLAutomato() Class JURTHREAD
Return Self:lAutomato

//-------------------------------------------------------------------
/*/{Protheus.doc} SetParams()
M�todo para setar os par�metros a serem executados pela cFunction

@author Felipe Bonvicini Conti
@since 05/03/13
/*/
//-------------------------------------------------------------------
Method SetParams(aParams) Class JURTHREAD
Local nI   := 1
Local lRet := .T.

Default aParams := {}

	If !Self:lError .And. ValType(aParams) == "A" .And. !Empty(aParams)
		Self:aParams := AClone(aParams)
		lRet := Len(aParams) == Len(Self:aParams)
	Else
		lRet := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GetParams()
M�todo para retornar os par�metros a serem executados pela cFunction

@author Felipe Bonvicini Conti
@since 05/03/13
/*/
//-------------------------------------------------------------------
Method GetParams() Class JURTHREAD
Return Self:aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFunction()
M�todo para setar o nome da function para ser executada na Thread

@author Felipe Bonvicini Conti
@since 09/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetFunction(cFunction) Class JURTHREAD
Local lRet := .T.

	If !Self:lError .And. ValType(cFunction) == "C"
		Self:cFunction := cFunction
		lRet := Self:cFunction == cFunction
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFunction()
M�todo para retornar o nome da function de emiss�o de pr�

@author Felipe Bonvicini Conti
@since 09/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFunction() Class JURTHREAD
Return Self:cFunction


//-------------------------------------------------------------------
/*/{Protheus.doc} SetToThread()
M�todo para setar o total de threads que podem ser abertas por esta��o de trabalho

@author Bruno Ritter
@since 17/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetToThread(nToThread) Class JURTHREAD
lRet := .T.

	If !Self:lError .And. ValType(nToThread) == "N" .And. nToThread > 0
		Self:nToThread := nToThread
		lRet := Self:nToThread == nToThread
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetToThread()
M�todo para retornar o total de threads de emiss�o de pr�
Se a 'Data (nToThread)' estiver com um valor inv�lido, o m�todo retorna o valor Padr�o

@author Bruno Ritter
@since 17/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetToThread() Class JURTHREAD
Local nRet := Self:nToThread

	If ValType(Self:nToThread) <> "N" .OR. Self:nToThread < 1
		nRet := DnToThread
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLog()
M�todo para setar o bloco a ser rodado para verificar se ir� utilizar o 

@author Felipe Bonvicini Conti
@since 18/11/11
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetLog(bValor) Class JURTHREAD
Local lRet := .T.

	Do Case
	Case ValType(bValor) == "B"
		Self:bLog := bValor
	Otherwise
		Self:bLog := {|| .F. }
		lRet := .F.
	End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StartThread()
M�todo para iniciar a thread para controle de emiss�o.

@author Bruno Ritter
@since 31/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method StartThread() Class JURTHREAD
Local lRet := .F.

Self:ThreadUp() //Inicia o controle de emiss�o

If !Self:lThreadStar .AND. !Empty(Self:GetFunction()) .AND. JurThreAbt("JURFILAIPC", 1) == 0
	StartJob( "JURFILAIPC", GetEnvServer(), .F.,;
	Self:GetFunction(), cEmpAnt, cFilAnt, Self:cCodUser, Eval(Self:bLog), Self:nToThread, Self:GetLAutomato())

	Self:lThreadStar := .T.
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilaIPC(cFunction, cEmpAux, cFilAux, cCodUser, lLog, nToThread, lAutomato)
Fun��o para controlar a emiss�o de pr�-fatura

@param cFunction  - Fun��o que ser� executada.
@param cEmpAux    - C�digo da empresa para abrir o ambiente
@param cFilAux    - C�digo da filial para abrir o ambiente
@param cCodUser   - C�digo do usu�rio para abrir o ambiente e o controle de emiss�o
@param lLog       - L�gico se vai registrar log (opcional)
@param nToThread  - M�ximo de thread que pode ser aberta para processar uma emiss�o de pr�-fatura por usu�rio
@Param lAutomato  - Automatiza��o de fonte

@author Bruno Ritter
@since 31/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURFILAIPC(cFunction, cEmpAux, cFilAux, cCodUser, lLog, nToThread, lAutomato)
Local nI         := 1
Local aParams    := {}
Local cText      := cFunction + ": " + cCodUser + ":"
Local cThread    := cValtochar(ThreadID())
Local lExit      := .F.
Local dInicio    := Date()
Local oFilaEx    := Nil
Local lOk        := .T.
Local lRet       := .F.

//Pode j� existir threads abertas se a tela foi fechada e aberta em curto per�odo de tempo, ou enquanto as threads estavam emitindo pr�-faturas
Local nThreadAbt := JurThreAbt("JURIPC", nToThread)

Default lLog      := .F.
Default lAutomato := .F.

	FWMonitorMsg(cText + ' Open environment / ID: ' + cThread)
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RPCSetType(3) // Prepara o ambiente e n�o consome licen�a
		RPCSetEnv(cEmpAux,cFilAux, , , , "JurFilaIPC")
	EndIf
	__cUserID := cCodUser
	cText     := cFunction + ": " + AllTrim(JurUsrName(cCodUser)) + " (" + cCodUser + "):"
	FWMonitorMsg(cText + ' Starting / ID: ' + cThread)

	//Abrir a primeira thread de emiss�o.
	If (nThreadAbt == 0)
		StartJob( "JURIPC", GetEnvServer(), .F., cFunction, cEmpAux, cFilAux, cCodUser, lLog, aParams, lAutomato)
		nThreadAbt += 1
	EndIf
	
	oFilaEx := JurFilaExe():New( "JURA201", "1" )
	
	While  lOk .OR. (!lExit .AND. dInicio == Date())
		aParams := oFilaEx:GetNext()

		If(ValType(aParams) == "A" .AND. Len(aParams) > 1)
			Iif(aParams[2] > 0, lOk := .T., lOk := .F. )
		Else
			aParams := {{}, 0}
			lOk := .F.
		EndIf

		If( lOk )
			lRet := .F.

			While( !lRet .AND. dInicio == Date() .AND. !KillApp())
				If(IPCCount( "JFILAIPC" ) > 0)
					lRet := IPCGo( "JFILAIPC", aParams)

				ElseIf (nThreadAbt < nToThread)

					StartJob( "JURIPC", GetEnvServer(), .F., cFunction, cEmpAux, cFilAux, cCodUser, lLog, aParams, lAutomato)
					nThreadAbt += 1
					lRet:= .T.

				Else
					Sleep(1000)
				EndIf
			EndDo

		Else
			lExit := !oFilaEx:IsOpenWindow("JURA201" + cCodUser) //Verifica se a tela de emiss�o foi fechada.
			Iif(lExit, ,Sleep(2000) )
		EndIf
	EndDo

	FWMonitorMsg(cText + ' Finish / ID: ' + cThread)
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RpcClearEnv() // Reseta o ambiente
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIPC()
Fun��o para executar a emiss�o de pr�-fatura conforme encaminhado pela fun��o JurFilaIPC()

@param cFunction  - Fun��o que ser� executada.
@param cEmpAux    - C�digo da empresa para abrir o ambiente
@param cFilAux    - C�digo da filial para abrir o ambiente
@param cCodUser   - C�digo do usu�rio para abrir o ambiente e o controle de emiss�o
@param lLog       - L�gico se vai registrar log (opcional)
@param aParamsIni - Retorno do JurFilaExe:GetNext() (opcional)
                    {aParam(OH1_PARAME), R_E_C_N_O_ (OH1)}

@author Bruno Ritter
@since 17/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURIPC(cFunction, cEmpAux, cFilAux, cCodUser, lLog, aParamsIni, lAutomato)
Local nI         := 1
Local aParams    := {{}, 0}
Local cText      := cFunction + ": " + cCodUser + ":"
Local cThread    := cValtochar(ThreadID())
Local lExit      := .F.
Local dInicio    := Date()
Local oFilaEx    := Nil
Local oThread    := Nil
Local lOk        := .T.

Default lLog       := .F.
Default aParamsIni := {}
Default lAutomato  := .F.

	FWMonitorMsg(cText + ' Open environment / ID: ' + cThread)
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RPCSetType(3)	// Prepara o ambiente e n�o consome licen�a
		RPCSetEnv(cEmpAux,cFilAux, , , , cFunction)
	EndIf
	__cUserID := cCodUser
	cText     := cFunction + ": " + AllTrim(JurUsrName(cCodUser)) + " (" + cCodUser + "):"
	FWMonitorMsg(cText + ' Starting / ID: ' + cThread)
	
	oThread := JurThread():New()
	oFilaEx := JurFilaExe():New( "JURA201", "1" )
	
	While  lOk .OR. (!lExit .AND. dInicio == Date())

		If (Len(aParamsIni) == 0)
			IPCWaitEx("JFILAIPC", 60000, @aParams)
			If(ValType(aParams) == "A" .AND. Len(aParams) > 1)
				Iif(aParams[2] > 0, lOk := .T., lOk := .F. )
			Else
				aParams := {{}, 0}
				lOk := .F.
			EndIf
		Else
			aParams := aClone(aParamsIni)
			aParamsIni := {}
		EndIf

		If( lOk )
			IIF(lLog, JurLogMsg("JurIPC: cFunction: "+cFunction +" / nRecno: " + cValToChar(aParams[2]) + " / ID: " + cThread), )
			Eval(&("{||"+cFunction+"( aParams, lAutomato )}"))
			aParams := {{}, 0}

		Else
			lExit := !oThread:IsThreadUp() .Or. !oFilaEx:IsOpenWindow("JURA201" + cCodUser) //Verifica se a tela de emiss�o foi fechada.
		EndIf
	EndDo

	If( JurThreAbt("JURIPC", 2) <= 1)
		oThread:ThreadDown() // Indica que foram finalizadas as emiss�es
	EndIf

	FWMonitorMsg(cText + ' Finish / ID: ' + cThread)
	If ( !Empty(cEmpAux) .And. !Empty(cFilAux) )
		RpcClearEnv() // Reseta o ambiente
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurThreAbt()
Verifica a quantidade de threads abertas da Esta��o de trabalho executando [cFunction]

@param cFunction - Fun��o a ser verificada
@param nMaxRet - Valor m�x de retorno desejado

@return Retorna um l�gico se existe uma thread ativa da cFunction

@author Bruno Ritter
@since 18/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurThreAbt(cFunction, nMaxThread)
Local nRet            := 0
Local aThread         := GetUserInfoArray()
Local cEnvServer      := GetEnvServer()
Local cComputerName   := GetComputerName()
Local nI              := 1
Local lMaxThread      := .F.

Default nMaxThread    := 0

lMaxThread := nMaxThread > 0

cFunction := Upper(cFunction)
	For nI := 1 To Len(aThread) //Controle de uso de Thread por Esta��o de trabalho / Server
		If    ( aThread[nI][2] == cComputerName ) ;
		.and. ( aThread[nI][5] == cFunction     ) ;
		.and. ( aThread[nI][6] == cEnvServer    )

			nRet += 1

			If(lMaxThread .AND. nRet == nMaxThread)
				Exit
			EndIf
		EndIf
	Next nI

Return nRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ThreadUp()
M�todo para ativar o controle de semaforo da tela (controle de abertura das Threads filhas)

@Return lRet .T. se conseguiu locar o semaforo

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ThreadUp() Class JURTHREAD

Self:lLock := LockByName(Self:cLockByName, .T., .F.)

Return (Self:lLock)


//-------------------------------------------------------------------
/*/{Protheus.doc} ThreadDown()
M�todo para desativar o controle de semaforo da tela (controle de fechamento das Threads filhas)

@Return Nil

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ThreadDown() Class JURTHREAD

UnlockByName(Self:cLockByName, .T., .F. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} IsThreadUp()
M�todo para verificar se a Thread Pai esta aberta

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method IsThreadUp() Class JURTHREAD

If Self:lLock .And. LockByName(Self:cLockByName, .T., .F.)
	Self:lLock := .F.
EndIf

Return (Self:lLock)


