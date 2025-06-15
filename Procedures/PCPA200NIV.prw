#INCLUDE "PROTHEUS.CH"
#INCLUDE "MRPPROCED.CH"

/*/{Protheus.doc} MRPProced
Fonte para executar as procedures referentes ao MRP
@author vivian.beatriz
@since 28/04/2023
@version P12
@param cErro  , caracter, mensagem de erro (passado por refer�ncia)
@param lAllFil, L�gico  , indica se deve calcular o n�vel em todas as filiais.
@return lOk, l�gico, indica se tudo foi executado com sucesso
/*/
Function PCPA200NIV(cErro, lAllFil)
	Local lOk := .T.
	
	Default lAllFil := .F.

	lOk := CalcNivel(@cErro, lAllFil)

Return lOk

/*/{Protheus.doc} CalcNivel
Calcula o n�vel de cada Produto do MRP (HWA) de acordo com a Estrutura (T4N)
@author vivian.beatriz
@since 28/04/2023
@version P12
@param cErro  , caracter, mensagem de erro (passado por refer�ncia)
@param lAllFil, L�gico  , indica se deve calcular o n�vel em todas as filiais.
@return lOk, l�gico, indica se foi executada com sucesso
/*/
Static Function CalcNivel(cErro, lAllFil)

	Local aFilProc  := {}
	Local aResult   := {}
	Local cProcNam  := GetSPName("PCP001","24")
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
		If lAllFil 
			//Recupera todas as filiais para executar 1 a 1.
			aFilProc := FwAllFilial(,,cEmpAnt,.F.)
			nTotal   := Len(aFilProc)

			For nIndex := 1 To nTotal
				nIniFil := MicroSeconds()
				LogNiv(STR0006 + aFilProc[nIndex]) //"Inicio do recalculo dos niveis. Filial: "

				//Somente executa a procedure se existir alguma estrutura na filial
				If SG1->(dbSeek(xFilial("SG1", aFilProc[nIndex])))
					//Executa a procedure no banco recuperando o retorno
					aResult := Executa(lAbreTran, cProcNam, xFilial("SB1", aFilProc[nIndex]), xFilial("SG1", aFilProc[nIndex]), aFilProc[nIndex], "1")
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
			//Executa a procedure no banco recuperando o retorno
			aResult := Executa(lAbreTran, cProcNam, xFilial("SB1"), xFilial("SG1"), "", "0")
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
@author vivian.beatriz
@since 28/04/2023
@version P12
@param lAbreTran, Logic, Indica se deve abrir transa��o para executar a procedure
@return aResult, Array, Array com o retorno da stored procedure
/*/
Static Function Executa(lAbreTran, cProcName, cFilSB1, cFilT4N, cFil, cGravaSMB)
	Local aResult := {}

	//Executa a procedure no banco recuperando o retorno
	//Caso seja banco de dados Oracle e n�o esteja com DbAccess atualizado, ir� executar a 
	//procedure dentro de transa��o para efetuar o commit dos dados de forma correta.
	If lAbreTran
		BEGIN TRANSACTION
			aResult := TCSPEXEC(cProcName, cFilSB1, cFilSG1, cFil, cGravaSMB)
		END TRANSACTION
	Else
		aResult := TCSPEXEC(cProcName, cFilHWA, cFilT4N, cFil, cGravaSMB)
	EndIf
Return aResult

/*/{Protheus.doc} LogNiv
Fun��o para exibi��o de mensagens de log

@type  Static Function
@author vivian.beatriz
@since 28/04/2023
@version P12
@param cMessage, Character, Mensagem de log
@return Nil
/*/
Static Function LogNiv(cMessage)
	Local dDate := Date()
	Local cTime := Time()

	cMessage := "PCPA200NIV - " + DtoC(dDate) + " - " + cTime + ": " + cMessage

	LogMsg('PCPA200NIV', 0, 0, 1, '', '', cMessage)
Return Nil

/*/{Protheus.doc} VerIDProc
Identifica a sequ�ncia de controle do fonte ADVPL com a stored procedure.
Qualquer altera��o que envolva diretamente a procedure a variavel ser� incrementada.
@author vivian.beatriz
@since 28/04/2023
@version P12
@return vers�o da procedure (compatibilidade)
/*/
Static Function VerIDProc()
Return '001'
