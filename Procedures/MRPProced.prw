#INCLUDE "PROTHEUS.CH"
#INCLUDE "MRPPROCED.CH"

/*/{Protheus.doc} MRPProced
Fonte para executar as procedures referentes ao MRP
@author marcelo.neumann
@since 12/11/2019
@version P12
@param cErro  , caracter, mensagem de erro (passado por refer�ncia)
@param lAllFil, L�gico  , indica se deve calcular o n�vel em todas as filiais.
@return lOk, l�gico, indica se tudo foi executado com sucesso
/*/
Function MRPProced(cErro, lAllFil)
	Local lOk := .T.
	
	Default lAllFil := .F.

	lOk := CalcNivel(@cErro, lAllFil)

Return lOk

/*/{Protheus.doc} CalcNivel
Calcula o n�vel de cada Produto do MRP (HWA) de acordo com a Estrutura (T4N)
@author marcelo.neumann
@since 12/11/2019
@version P12
@param cErro  , caracter, mensagem de erro (passado por refer�ncia)
@param lAllFil, L�gico  , indica se deve calcular o n�vel em todas as filiais.
@return lOk, l�gico, indica se foi executada com sucesso
/*/
Static Function CalcNivel(cErro, lAllFil)

	Local aFilProc  := {}
	Local aResult   := {}
	Local cProcNam  := GetSPName("MRP001","24")
	Local lOk       := .T.
	Local lAbreTran := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local nInicio   := MicroSeconds()
	Local nIniFil   := 0

	LogNiv(STR0005) //"Inicio do recalculo dos niveis."

	//Prote��o para DbAccess desatualizado, referente a abertura indevida de transa��o
	//para banco de dados oracle na execu��o da Procedure. Corre��o estar� dispon�vel a partir da build 22.1.1.1 do DbAccess
	If TCGetDB() == "ORACLE" .And. TCVersion() < "22.1.1.1"
		lAbreTran := .T.
		LogNiv("[ABRE_TRANCACAO]=TRUE")
	EndIf

	//Verifica se a procedure existe
	If ExistProc(cProcNam, VerIDProc())
		cProcNam := xProcedures(cProcNam)
		//Verifica se deve executar para todas as filiais.
		If lAllFil .And. FwAliasInDic("SMB", .F.)
			//Primeiro elimina a tabela SMB para incluir novamente com os n�veis atualizados
			If deletaSMB(@cErro)
				//Recupera todas as filiais para executar 1 a 1.
				aFilProc := FwAllFilial(,,cEmpAnt,.F.)
				nTotal   := Len(aFilProc)

				For nIndex := 1 To nTotal
					nIniFil := MicroSeconds()
					LogNiv(STR0006 + aFilProc[nIndex]) //"Inicio do recalculo dos niveis. Filial: "

					//Somente executa a procedure se existir alguma estrutura na filial
					If T4N->(dbSeek(xFilial("T4N", aFilProc[nIndex])))
						//Executa a procedure no banco recuperando o retorno
						aResult := Executa(lAbreTran, cProcNam, xFilial("HWA", aFilProc[nIndex]), xFilial("T4N", aFilProc[nIndex]), aFilProc[nIndex], "1")
						//Se ocorreu algum erro, retorna o status de execu��o como falso
						If Empty(aResult) .Or. Valtype(aResult) <> "A"
							cErro := STR0001 + AllTrim(cProcNam) + ": " + TcSqlError() //"Erro na execu��o da Stored Procedure "
							lOk   := .F.
						EndIf
					EndIf

					LogNiv(STR0007 + aFilProc[nIndex] + ". " + STR0008 + cValToChar(MicroSeconds()-nIniFil)) //"Termino do recalculo de niveis. Filial: " Tempo total: "
					If !lOk
						Exit
					EndIf
				Next nIndex

				aSize(aFilProc, 0)
			Else
				lOk := .F.
			EndIf
		Else
			//Executa a procedure no banco recuperando o retorno
			aResult := Executa(lAbreTran, cProcNam, xFilial("HWA"), xFilial("T4N"), "", "0")
			//Se ocorreu algum erro, retorna o status de execu��o como falso
			If Empty(aResult) .Or. Valtype(aResult) <> "A"
				cErro := STR0001 + AllTrim(cProcNam) + ": " + TcSqlError() //"Erro na execu��o da Stored Procedure "
				lOk   := .F.
			EndIf
		EndIf

	Else
		cErro := STR0002 + AllTrim(cProcNam) + STR0003 //"Stored Procedure " XXX " n�o instalada no banco de dados."
		lOk   := .F.
	EndIf

	LogNiv(STR0009 + cValToChar(MicroSeconds()-nInicio)) //"Termino do recalculo de niveis. Tempo total: "

	If !lOk
		LogNiv(STR0010 + cErro) // "Recalculo de niveis processado com erro. "
	EndIf

Return lOk

/*/{Protheus.doc} Executa
Faz a execu��o da Stored Procedure de rec�lculo de n�veis do MRP.

@type  Static Function
@author lucas.franca
@since 26/10/2022
@version P12
@param lAbreTran, Logic, Indica se deve abrir transa��o para executar a procedure
@return aResult, Array, Array com o retorno da stored procedure
/*/
Static Function Executa(lAbreTran, cProcName, cFilHWA, cFilT4N, cFil, cGravaSMB)
	Local aResult := {}

	//Executa a procedure no banco recuperando o retorno
	//Caso seja banco de dados Oracle e n�o esteja com DbAccess atualizado, ir� executar a 
	//procedure dentro de transa��o para efetuar o commit dos dados de forma correta.
	If lAbreTran
		BEGIN TRANSACTION
			aResult := TCSPEXEC(cProcName, cFilHWA, cFilT4N, cFil, cGravaSMB)
		END TRANSACTION
	Else
		aResult := TCSPEXEC(cProcName, cFilHWA, cFilT4N, cFil, cGravaSMB)
	EndIf
Return aResult

/*/{Protheus.doc} deletaSMB
Faz a exclus�o dos dados da tabela SMB

@type  Static Function
@author lucas.franca
@since 11/09/2020
@version P12
@param cErro, caracter, mensagem de erro (passado por refer�ncia)
@return lRet, l�gico  , indica se foi executada com sucesso
/*/
Static Function deletaSMB(cErro)
	Local cSql := ""
	Local lRet := .T.

	cSql := "DELETE FROM " + RetSqlName("SMB")

	If TcSqlExec(cSql) < 0
		cErro := STR0004 + TcSqlError() //"Erro ao excluir os dados da tabela SMB. "
		lRet  := .F.
	EndIf
Return lRet

/*/{Protheus.doc} LogNiv
Fun��o para exibi��o de mensagens de log

@type  Static Function
@author lucas.franca
@since 17/09/2020
@version P12
@param cMessage, Character, Mensagem de log
@return Nil
/*/
Static Function LogNiv(cMessage)
	Local dDate := Date()
	Local cTime := Time()

	cMessage := "MRPProced - " + DtoC(dDate) + " - " + cTime + ": " + cMessage

	LogMsg('MRPProced', 0, 0, 1, '', '', cMessage)
Return Nil

/*/{Protheus.doc} VerIDProc
Identifica a sequ�ncia de controle do fonte ADVPL com a stored procedure.
Qualquer altera��o que envolva diretamente a procedure a variavel ser� incrementada.
@author marcelo.neumann
@since 12/11/2019
@version P12
@return vers�o da procedure (compatibilidade)
/*/
Static Function VerIDProc()
Return '003'

/* ---------------------------------------------------------------------------------
Fun��es executadas durante a exibi��o de informa��es detalhadas do processo na 
interface de gest�o de procedures.
Faz a execu��o de fun��es STATIC propriet�rias das rotinas donas dos processos.IMPORTANTE: 
- Essas fun��es n�o podem ter interface alguma, nem intera��o com usu�rio.
--------------------------------------------------------------------------------- */
// Processo 24 - PROCEDURES DO M.R.P
Function EngSPS24Signature()
Return VerIDPROc()
