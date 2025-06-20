#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA153B
Realiza a apura��o do Simples Nacional via Job/Schedule

@param cCodEmp    - C�digo do grupo de empresa (cEmpAnt)
@param cCodFil    - C�digo da filial (cFilAnt)
@param cMesRef    - M�s e ano do per�odo a ser processado. Exemplo: "012023" onde 01 � o m�s de janeiro e 2023 o ano.
@param nAprvAliq  - Indica se as al�quotas dever�o ser aprovadas de forma autom�tica: 1=Sim e 2=N�o.
@param nRegime    - Regime de apura��o das receitas: 1=Compet�ncia e 2=Regime de Caixa.
@param nMovFinCtb - Indica se ser�o geradas movimenta��es financeiras e cont�beis: 1=N�o, 2=Somente T�tulo, 3=T�tulo+Cont�bil.
@param nAgrpFil   - 1=Indica que as filiais ser�o agrupadas, centralizando a apura��o na filial logada. 2=A apura��o ser� realizada apenas para a filial logada
@param cFilDe     - Caso o agrupamento de filiais esteja habilitado, indica a primeira filial do range
@param cFilAte    - Caso o agrupamento de filiais esteja habilitado, indica a ultima filial do range
@param lTestAuto  - Indica se a rotina foi chamada por um script de automa��o.


@author leandro.faggyas
@since 01/03/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------
Function FISA153B(cCodEmp,cCodFil, cMesRef, nAprvAliq, nRegime, nMovFinCtb, nAgrpFil, cFilDe, cFilAte,  lTestAuto )
	Local lAliqAuto    := .F.
	Local lSchedule    := ValType(cCodEmp) == "U" // Se � execu�ao via Schedule
	Local dDataAnt     := Ctod("") //Guarda a data do per�odo anterior � data base.
	Local oSX1         := FWSX1Util():New()
	Local oGrupoSX1    := Nil
	Local aFilSel      := {} //Caso seja passado um range de filiais, esse array ir� guardar todas as filiais passadas.

	Default cCodEmp    := ""
	Default cCodFil    := ""
	Default cMesRef    := ""
	Default nAprvAliq  := 1
	Default nRegime    := 1
	Default nMovFinCtb := 1
	Default nAgrpFil   := 2
	Default cFilDe     := ""
	Default cFilAte    := ""
	Default lTestAuto  := .F.  //Esse par�metro ser� passado como verdadeiro pelas nossas suites de teste

	Private lAutomato   := .T. //Indica que a execu��o ser� via Job
	Private lPosPerRed 	:= .F.
	Private lPosPredRed := .F.

	//Mensagem simples, de forma reduzida, somente par�metros obrigat�rios
	FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Inicio do servico de apuracao automatico do Simples Nacional." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	lSchedule := Empty(cCodEmp) .And. !Empty(cEmpAnt) .And. !Empty(cFilAnt)

	If lSchedule

		oSX1:AddGroup("FSA153JOB")
		oSX1:SearchGroup()
		oGrupoSX1 := oSX1:GetGroup("FSA153JOB")

		IF Len(oGrupoSX1[2]) > 0 //Caso o m�todo GetGroup retorne um array vazio, significa que o sistema n�o encontrou o pergunte FSA153JOB.
			nAprvAliq     := MV_PAR01
			nRegime       := MV_PAR02
			nMovFinCtb    := MV_PAR03
			cMesRef       := MV_PAR04
			nAgrpFil      := MV_PAR05
			cFilDe        := MV_PAR06
			cFilAte       := MV_PAR07
		EndIf

	ElseIf !lTestAuto

		RpcSetType( 3 )
		RpcSetEnv(cCodEmp,cCodFil,,,'FIS')
		FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Ambiente acessado.", /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	EndIf

	If Empty(cMesRef)
		dDataAnt     := FirstDay(dDataBase)-1
		cMesRef      := StrZero(Month(dDataAnt), 2) + cValtochar(Year(dDataAnt))
	EndIf

	lAliqAuto := nAprvAliq == 1
	
	IF Pergunte("FSA153")
		//Atualizo os par�metros do pergunte FSA153 conforme o esperado pela rotina de apura��o.
		MV_PAR01 := cMesRef
		If nAgrpFil==1 .And. !Empty(cFilAte)
			MV_PAR02 := 1 //Seleciona Filiais = 1-Sim
			aFilSel := F153FRange(cFilDe,cFilAte)
		Else
			MV_PAR02 := 2 //Seleciona Filiais = 2-N�o
		EndIf
		MV_PAR03 := nRegime
		MV_PAR04 := nMovFinCtb

		If FISA153() //A fun��o FISA153 � chamada para posicionar todas as tabelas necess�rias, fazer algumas verifica��es e realizar Carga Inicial

			FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Iniciando apuracao referente ao periodo " + SubStr(cMesRef,1,2) + "/" + SubStr(cMesRef,3) + "." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/) 
			FS153Apura( aFilSel )
			FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Apuracao concluida!" , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

			If lAliqAuto 
				AprvAlqAut( aFilSel, cMesRef )
			EndIf

			FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Processamento finalizado." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

		EndIf

	EndIf

	If !lSchedule .And. !lTestAuto
		RESET ENVIRONMENT
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AprvAlqAut
Efetua a aprova��o das aliquotas de forma autom�tica quando chamado via JOB ou Schedule.
Verifica todas as filiais que foram consideradas na apura��o e faz a aprova��o de todas as filiais envolvidas, levando em considera��o o n�vel de compartilhamento das tabelas.
Caso as aliquotas por algum motivo j� estejam aprovadas, essa rotina n�o far� desaprova��es.

@author  leandro.faggyas
@since   01.03.2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function AprvAlqAut( aFilSel, cMesRef )
	Local nX       := 0
	Local cFilBkp  := cFilAnt
	Local cFilPos  := ""
	Local aAreaF1E := F1E->(GetArea())
	Local cMesApu  := SubStr(cMesRef,1,2)
	Local cAnoApu  := SubStr(cMesRef,3)

	DbSelectArea("F1E")
	F1E->(DbSetOrder(1)) //F1E_FILIAL+F1E_ANO+F1E_MES+F1E_APROV+F1E_ID

	FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Iniciando da aprovacao automatica de aliquotas." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	For nX := 1 To Len(aFilSel)

		cFilPos := PADR(aFilSel[nX,2], LEN(cFilAnt))

		If F1E->(MsSeek(xFilial( "F1E", cFilPos ) + cAnoApu + cMesApu + "2")) //Fa�o o Seek por Filial, levando em considera��o somente as aliquotas que n�o est�o aprovadas.
			cFilAnt := cFilPos
			FSA155ALQOK( .T. )
		EndIf

	Next nX

	cFilAnt := cFilBkp

	FWLogMsg("INFO", /*cTransactionId*/, "FISA153B", /*cCategory*/, /*cStep*/, /*cMsgId*/, "Finalizando a aprovacao automatica de aliquotas." , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

	RestArea( aAreaF1E )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aParam - Array com os parametros

@author  leandro.faggyas
@since   01.03.2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function Scheddef()

Local aParam  := {}

aParam := { "P",;           //Tipo R para relatorio P para processo
            "FSA153JOB",;   //Pergunte do relatorio, caso nao use passar ParamDef
            ,;              //Alias
            ,;              //Array de ordens
            }               //Titulo

Return aParam
