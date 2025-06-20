#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "fileio.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "GPECONSIG001.CH"

#DEFINE nLogColDef 		35
#DEFINE nLogNameDef 	16
#DEFINE nMaxParcLog     20


/*/{Protheus.doc} function GPECONSIG001
Rotina utilizada escolher e lan�ar parcelas do TOTVS Consignado nos lan�amentos de Incid�ncias da Folha
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Main Function GPECONSIG001()
	Local cSM0		  		:= {}
	Local cParams 	  		:= ""

	Static _ScreenSelected 	:= {}

	Private cMonth 			:= ""
	Private cYear 			:= ""
	Private cStatusFilter 	:= ""
	Private aSelected 		:= {}
	Private aLog			:= {}
	Private aInstSelected	:= {}
	Private nMaxInst		:= 0
	Private oBrowse 		:= FWMarkBrowse():New()

	// Controle de valida��o do retorno de sucesso/erro/warnings da rotina GPEA580.
	Private lExecAutoError	:= .F.
	Private lMsErrorAuto	:= .F.
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T.	// Se ativada retorna no log atrav�s do GetAutoGRLog. Se desativada, grava em disco.
	Private lVerificaConsoleLog := .F.

	If !GetMv("MV_CONSIG", .F., .F.)
		Aviso(OemToAnsi(STR0001), OemToAnsi(STR0002), { OemToAnsi("Ok") }, 3) // STR0001: "Aviso Integra��o" e STR0002: "Para utilizar essa rotina � necess�rio ativar a chave do TOTVS Consignado."
		Return
	EndIf
	
	// Verifica se o Console log est� habilitado = 1.
	lVerificaConsoleLog :=  fGetSrvIni("General", "CONSOLELOG") == "1"

	// Se estiver habilitado ent�o direciona para a nova importa��o.
	If Getmv("MV_IMPMFIL",,.F.)
		CONSIGIMP()
		Return
	EndIf
	
	// Cria par�metro de controle da vers�o da Importa��o de Parcelas.
	If !Getmv("MV_IMPMFIL",,.F.)
		fUpdSX6("MV_IMPMFIL", ".F.", "Habilita Import. Parcelas. multi filiais", "L")
	EndIf

	If Pergunte("CONSIG001", .T.)
		cSM0 	  	  := FWArrFilAtu(cEmpAnt, cFilAnt)
		cYear 	  	  := SUBSTR(MV_PAR01, 0, 4)
		cMonth 	  	  := SUBSTR(MV_PAR01, 5, 2)
		cParams 	  := "CNPJs=" + cSM0[18] + "&month="+ cMonth +"&year=" + cYear + "&pageSize=100000"
		cStatusFilter := MV_PAR02
		fCreateScreen(cParams, cStatusFilter)
	EndIf
Return


/*/{Protheus.doc} function fCreateScreen
Cria a tela tempor�ria de sele��o de Parcelas
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fCreateScreen(cParams, cStatusFilter)
	Local aInstFiltered := {}
	Private cTmpTable   := GetNextAlias()

	// Se n�o encontrar parcelas ou n�o for informado nenhum status de situa��o do funcion�rio
	aInstFiltered := fGetInstallment(cParams, cStatusFilter)
	
	if (lVerificaConsoleLog)
		Conout("##### DEBUG DE DADOS - fCreateScreen - INICIO #####")
		Conout("##### DEBUG DE DADOS - cParams: " + VarInfo("cParams", cParams, , .F.))
		Conout("##### DEBUG DE DADOS - cStatusFilter: " + VarInfo("cStatusFilter", cStatusFilter, , .F.))
		Conout("##### DEBUG DE DADOS - aInstFiltered: " + VarInfo("aInstFiltered", aInstFiltered, , .F.))
		Conout("##### DEBUG DE DADOS - fCreateScreen - FIM #####")
	EndIf

	If Empty(aInstFiltered)
		fCreateLog(400)
		Return
	EndIf

	// Cria e seta a tabela Tempor�ria para apresenta��o dos dados recebidos da Integra��o com o Consignado.
	fSetTmpTable(aInstFiltered)

	// Seta as configura��es das caixas de sele��o das parcelas
	DbSelectArea(cTmpTable)
	oBrowse:SetAlias(cTmpTable)
	aColsMark := fMntColsMark()
	oBrowse:SetFields(aColsMark)
	oBrowse:SetFieldMark('TMP_OK')
	oBrowse:SetMenuDef('GPECONSIG001')
	oBrowse:SetDescription(OemToAnsi(STR0006)) // STR0006: "Importa��o de Parcelas"
	oBrowse:SetAfterMark({|| fSelect() })
	oBrowse:SetAllMark({|| fSelectAll() })
	oBrowse:Activate()
	DbCloseArea()
Return


/*/{Protheus.doc} function fGetInstallment
Consulta parcelas de acordo com o CNPJ da Filial logada, per�odo e Status do funcion�rio.
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fGetInstallment(cParams, cStatusFilter)
	Local oInteg
	Local cRacToken     := ""
	Local aHeader       := {}
	Local aInstFiltered := {}
	Local oInstallment  := JsonObject():New()
	Local lStatusEmpty  := (cStatusFilter == "*****")
	Local cEndPoint	    := fGetURLCsg()

	If Empty(cEndPoint) .OR. lStatusEmpty
		Return aInstFiltered
	EndIf

	oInteg    := FwRest():New(cEndPoint + "/api/erp/v1/installmentDetail")
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	oInteg:setPath("?" + cParams)

	If oInteg:Get(aHeader)
		If oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult())
			oInstallment:FromJson(oInteg:GetResult())
			
			// Realiza a filtragem das parcelas de acordo com o que o usu�rio escolheu
			aInstFiltered = fFilterInstallment(oInstallment, cStatusFilter)
		EndIf
	EndIf
Return aInstFiltered


/*/{Protheus.doc} function fImport
Incia o processo de Importa��o das Parcelas
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Function fImport()
	Local nX		  := 1
	Local aMat 		  := {}
	Local aMessage    := {}
	Local oValidGlob  := JsonObject():New()

	//Realiza as valida��es globais
	oValidGlob := fValidGlob(aInstSelected)

	If(oValidGlob["invalid"])
		aadd(aMessage, oValidGlob["message"])
		fCreateLog(oValidGlob["code"], aMessage)
		Return
	EndIf
	
	fSetSelected()

	// Passa por todas as parcelas selecionadas
	For nX := 1 To Len(aInstSelected)
		aHeader := {}
		aItens 	:= {}
		If(aInstSelected[nX]['motivo']['valid'])
			aMat := fFormatToSave(aMat, aInstSelected[nX])
		EndIF
	Next nX

	fSaveInstallment(aMat)
	fCreateLog(200, {}, aMat)
Return


/*/{Protheus.doc} function fValidGlob
Realiza valida��es que s�o independentes de cada funcion�rio
1 - Usu�rio n�o selecionou nenhuma parcela.
2 - N�o existe verba cadastrada para o parceiro.
3 - Roteiro FOL n�o est� cadastrado para este per�odo.
4 - Verifica se o per�odo est� aberto e ativo.
@author  alberto.ortiz
@since   08/03/2022
@version 1.0
/*/
Static Function fValidGlob(aInstSelected)
	Local oValidGlob  := JsonObject():New()
	Local cProcess    := ""
	Local cPeriodo    := cYear + cMonth
	Local cDTFech     := ""
	Local cStatusPer  := ""
	Local cRoteiro    := ""
	Local lPerAberto  := .T.
	Local lPerAtivo   := .T.
	
	DEFAULT aInstSelected := {}

	oValidGlob["invalid"]    := .F.
	oValidGlob["code"]     := 0
	oValidGlob["message"]  := ""		

	// Valida sele��o de parcelas pelo usu�rio
	If Empty(aInstSelected)
		oValidGlob["invalid"]  := .T.
		oValidGlob["code"]     := 301
		oValidGlob["message"]  := ""
	else
		cProcess   := fConsFunc(cFilAnt, aInstSelected[1]['matricula'], "RA_PROCES")
		cDTFech    := fConsPer(cFilAnt, cProcess, cPeriodo, "RCH_DTFECH")
    	cStatusPer := fConsPer(cFilAnt, cProcess, cPeriodo, "RCH_STATUS")
		cRoteiro   := fGetRotOrdinar()
    	lPerAberto := (Empty(cDTFech) .And. cStatusPer != "5")
		lPerAtivo  := fConsPer(cFilAnt, cProcess, cPeriodo, "RCH_PERSEL") == "1"	

		//Valida se o cliente possui verba cadastrada para este parceiro.
		If(Empty(fGetS137Pd(cFilAnt, aInstSelected[1]['codigoParceiro'])))
			oValidGlob["invalid"]  := .T.
			oValidGlob["code"]     := 302
			oValidGlob["message"]  := aInstSelected[1]['codigoParceiro']

		ElseIf(cRoteiro != "FOL")
			oValidGlob["invalid"]  := .T.
			oValidGlob["code"]     := 303
			oValidGlob["message"]  := ""

		ElseIf !lPerAtivo .OR. !lPerAberto
			oValidGlob["invalid"]  := .T.
			oValidGlob["code"]     := 304
			oValidGlob["message"]  := cPeriodo
		EndIf
	EndIf
Return oValidGlob


/*/{Protheus.doc} function fSetSelected
Completa demais informa��es necess�rias para lan�amento na RGB
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fSetSelected()
	Local nX := 1

	For nX := 1 To Len(aInstSelected)		
		aInstSelected[nX]['filialLogada']	   := cFilAnt
		aInstSelected[nX]['periodo'] 		   := cYear + cMonth
		aInstSelected[nX]['tipoInsercao'] 	   := "G" // Usado por rotinas autom�ticas, como no GPEA580
		aInstSelected[nX]['roteiro']		   := fGetRotOrdinar() // Roteiro da folha

		aInstSelected[nX]['processo']		   := fConsFunc(cFilAnt, aInstSelected[nX]['matricula'], "RA_PROCES")
		aInstSelected[nX]['centroDeCusto']	   := fConsFunc(cFilAnt, aInstSelected[nX]['matricula'], "RA_CC")
		aInstSelected[nX]['codFuncionario']	   := fConsFunc(cFilAnt, aInstSelected[nX]['matricula'], "RA_CODFUNC")

		aInstSelected[nX]['verba']	 		   := fGetS137Pd(cFilAnt, aInstSelected[nX]['codigoParceiro'])
		aInstSelected[nX]['tipoVerba'] 		   := fConsVerba(cFilAnt, aInstSelected[nX]['verba'], "RV_TIPO")

		aInstSelected[nX]['semana']  		   := fConsCabPer(cFilAnt, aInstSelected[nX]['processo'], cYear, cMonth, "RCF_SEMANA")
		aInstSelected[nX]['fechamentoPeriodo'] := fConsPer(cFilAnt, aInstSelected[nX]['processo'], aInstSelected[nX]['periodo'], "RCH_DTFECH")
		aInstSelected[nX]['statusPeriodo'] 	   := fConsPer(cFilAnt, aInstSelected[nX]['processo'], aInstSelected[nX]['periodo'], "RCH_STATUS")
		aInstSelected[nX]['dtPgtoPeriodo']	   := fConsPer(cFilAnt, aInstSelected[nX]['processo'], aInstSelected[nX]['periodo'], "RCH_DTPAGO")
		aInstSelected[nX]['motivo']	           := fValidParc(aInstSelected[nX])		
	Next nX

	if (lVerificaConsoleLog)
		Conout("##### DEBUG DE DADOS - fSetSelected - INICIO #####")
		Conout("##### DEBUG DE DADOS - aInstSelected: " + VarInfo("aInstSelected", aInstSelected, , .F.))
		Conout("##### DEBUG DE DADOS - fSetSelected - FIM #####")
	ENDIF

Return


/*/{Protheus.doc} function fValidParc
Valida dados obrigat�rios para lan�amento na folha.
1 - Centro de custo
2 - Processo
@author  alberto.ortiz
@since   07/03/2022
@version 1.0
/*/
Static Function fValidParc(oInstSelected)
	Local oValidIntern := JsonObject():New()

	oValidIntern['valid']  := .T.
	oValidIntern['reason'] := ''

	If (Empty(oInstSelected['centroDeCusto']))
		oValidIntern['valid'] := .F.
		oValidIntern['reason'] := 'Verificar centro de custo.'
	EndIf
Return oValidIntern


/*/{Protheus.doc} fFormatToSave(aMat, oInstSelected)
Formata Parcelas para o padr�o de recebimento da rotina GPEA580.
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
#### Estrutura do array aMat ####
aMat
	aHeader
		Field_1
		Field_2...
	aItens
		Item_1
			Field_1
			Field_2...
		Item_2...
			Field_1
			Field_2...
/*/
Static Function fFormatToSave(aMat, oInstSelected)
	Local nPosMat := 0
	Local aHeader := {} 
	Local aItens  := {}

	If !Empty(aMat)
		nPosMat := fPosMatEnc(oInstSelected['matricula'], aMat)
	EndIf

	// Adiciona nova parcela para o Funcion�rio
	aadd(aItens, fMakeItem(oInstSelected))

	// Cria novo header somente se funcion�rio ainda n�o foi adicionado no aMat
	If nPosMat == 0
		aadd(aHeader, fMakeHeader(oInstSelected))
		aadd(aMat, { aHeader, aItens })
	Else
		aadd(aMat[nPosMat][2], aItens[1])
	EndIf
Return aMat


/*/{Protheus.doc} function fPosMatEnc(cCPF, aMat)
Verifica matr�cula repetida
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
static Function fPosMatEnc(cMat, aMat)
	Local nX   := 1
	Local nPos := 0

	DEFAULT cMat  := ""

	If !Empty(cMat)
		For nX := 1 To Len(aMat)
			If aScan(aMat[nX][1][1], {|x| x[2] == cMat }) > 0
				nPos := nX
				Exit
			EndIf
		Next nX
	EndIf
Return nPos


/*/{Protheus.doc} function fSaveInstallment(aMat)
Realiza a grava��o do lan�amento na tabela RGB
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
static Function fSaveInstallment(aMat) // Lembrar de remover a fun��o pois j� existe no CONSIGCOMP
	Local nX 	  := 1
	Local aHeader := {}
	Local aItens  := {}
	DEFAULT aMat  := {}
	
	if (lVerificaConsoleLog)
		Conout("##### DEBUG DE DADOS - ENVIO AO GPEA580 - INICIO #####")
		Conout("##### DEBUG DE DADOS - aMat: " + VarInfo("aMat", aMat, , .F.)) // Apenas para gera��o de Logs
		Conout("##### DEBUG DE DADOS - ENVIO AO GPEA580 - FIM #####")
	ENDIF	

	If !Empty(aMat)
		For nX := 1 To LEN(aMat)
			aHeader 	:= aMat[nX][1][1]
			aItens 		:= aMat[nX][2]
	
			MSExecAuto({|X,Y,Z,K,W,V|Gpea580(X,Y,Z,K,W,V)}, Nil, aHeader, aItens, 4, Nil, "CONSIGNADO")
		Next nX
	EndIf
	
Return


/*/{Protheus.doc} function fMarkImported(aMat)
Consulta parcelas importadas por funcion�rio
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fMarkImported(aMat)
	Local aImported := {}
	Local nX 		:= 1
	Local nIdSize 	:= 26
	Local aArea 	:= GetArea()
	Local cKeyRGB 	:=  ""

	For nX := 1 To Len(aInstSelected)
		cKeyRGB := xFilial(("RGB"), cFilAnt) + aInstSelected[nX]['matricula'] + aInstSelected[nX]['verba'] + aInstSelected[nX]['periodo']

		RGB->(DbSetOrder(1)) // RGB_FILIAL, RGB_MAT, RGB_PD, RGB_PERIOD

		If RGB->(dbSeek(cKeyRGB))
			While RGB->(!Eof() .and. RGB_FILIAL + RGB_MAT + RGB_PD + RGB_PERIOD == cKeyRGB)
				If RGB->RGB_NUMID == Substring(aInstSelected[nX]['idParcela'], 0, nIdSize)
					Aadd(aImported, aInstSelected[nX])
					EXIT
				EndIf
				RGB->(dbSkip())
			EndDo
		EndIf
		RestArea(aArea)
	Next nX
Return aImported


/*/{Protheus.doc} function fMarkNotImported(aImported)
Marca as parcelas n�o importadas
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fMarkNotImported(aImported)
	Local nX := 1
	Local nY := 1
	Local aNotImported := {}
	Local lNotImported := .T.

	DEFAULT aImported := {}

	aNotImported := {}
	For nX := 1 To Len(aInstSelected)
		lNotImported := .T.
		For nY := 1 To Len(aImported)
			If aInstSelected[nX]['idParcela'] == aImported[nY]['idParcela']
				lNotImported := .F.
			EndIf
		Next nY
		If lNotImported
			Aadd(aNotImported, aInstSelected[nX])
		EndIf
	Next nX
Return aNotImported


/*/{Protheus.doc} function fGetLogDetail()
Preenche informa��es complementares do processamento do Log
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static function fGetLogDetail()
	Local aAllData 	 := {}
	Local aLogDetail := {}

	If lMsErroAuto
		aEval(GetAutoGRLog(),{|x| aadd(aAllData, x) })
		aAdd(aLogDetail, aAllData)
	EndIf
Return aLogDetail


/*/{Protheus.doc} function fGetS137Pd(cFilLog, cCdParc)
Consulta a verba configurada para determinado parceiro.
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fGetS137Pd(cFilLog, cCdParc)
	Local cValor 	:= ""
	Local cAlias	:= "RCC"
	Local cTabela 	:= "S137"

	DEFAULT cFilLog := ""
	DEFAULT cCdParc := ""
	
	If !Empty(cFilLog) .And. !Empty(cCdParc)
		(cAlias)->(dbSetOrder(1)) // RCC_FILIAL, RCC_CODIGO
		(cAlias)->(dbSeek(xFilial((cAlias), cFilLog ) + cTabela))

		// Primeiro procura na Filial espec�fica do registro na S137
		While (cAlias)->RCC_FILIAL == xFilial((cAlias), cFilLog) .AND. RCC->RCC_CODIGO == cTabela
			If (cAlias)->RCC_FIL == cFilLog .AND. (SUBSTR((cAlias)->RCC_CONTEU, 7, 4) == cCdParc)
				cValor := SUBSTR((cAlias)->RCC_CONTEU, 0, 3)
			EndIf
			(cAlias)->(DbSkip())
		EndDo

		// Caso n�o encontre, procura na Filial em branco(compartilhada) do registro na S137
		If Empty(cValor)
			(cAlias)->(dbSetOrder(1)) // RCC_FILIAL, RCC_CODIGO
			If (cAlias)->(dbSeek(xFilial((cAlias), cFilLog) + cTabela))
				While (cAlias)->RCC_FILIAL == xFilial(cAlias) .AND. (cAlias)->RCC_CODIGO == cTabela
					If Empty((cAlias)->RCC_FIL) .AND. SUBSTR((cAlias)->RCC_CONTEU, 7, 4) == cCdParc
						cValor := SUBSTR((cAlias)->RCC_CONTEU, 0, 3)
					EndIf
					(cAlias)->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
return cValor


/*/{Protheus.doc} function MenuDef
Realiza a cria��o dos menus da tela de importa��o.
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function MenuDef()
	Private aMenu :=  {}
	ADD OPTION aMenu TITLE OemToAnsi(STR0019) ACTION 'fImport()' 	OPERATION 7 ACCESS 0  // "Importar"
	ADD OPTION aMenu TITLE OemToAnsi(STR0020) ACTION 'fSelectAll()' OPERATION 8  ACCESS 0 // "Marcar/Desmarcar"
Return aMenu


/*/{Protheus.doc} function fSelect
Realiza a sele��o de 1 parcela
@author  hugo.de.oliveira
@since   24/03/2021
@version 1.0
/*/
Static Function fSelect()
	Local oSelected
	Local nPosition := fGetMarkPos()

	If oBrowse:IsMark()
			oSelected := JsonObject():New()
			oSelected['codigoParceiro'] 	:= Alltrim((cTmpTable)->TMP_PCODE)
			oSelected['cpf'] 				:= Alltrim((cTmpTable)->TMP_CPF)
			oSelected['nomeFuncionario'] 	:= Alltrim((cTmpTable)->TMP_NOME)
			oSelected['matricula'] 			:= Alltrim((cTmpTable)->TMP_REG)
			oSelected['numeroParcela'] 		:= Alltrim((cTmpTable)->TMP_INUMB)
			oSelected['valorParcela'] 		:= Alltrim((cTmpTable)->TMP_IVALUE)
			oSelected['parcelasRestantes'] 	:= Alltrim((cTmpTable)->TMP_IREM)
			oSelected['valorTotalContrato'] := Alltrim((cTmpTable)->TMP_CDEBIT)
			oSelected['codigoContrato'] 	:= Alltrim((cTmpTable)->TMP_CCODE)
			oSelected['idParcela'] 			:= Alltrim((cTmpTable)->TMP_IDINST)
			Aadd(aInstSelected, oSelected)	
			FreeObj(oSelected)
			Aadd(_ScreenSelected, oBrowse:At())
	Else
		If (nPosition > 0)
			nLastSize := Len(aInstSelected)
			aDel(aInstSelected, nPosition)
			aDel(_ScreenSelected, nPosition)
			aSize(aInstSelected, (nLastSize - 1))
			aSize(_ScreenSelected, (nLastSize - 1))
		EndIF
	EndIf
Return


/*/{Protheus.doc} function fGetMarkPos()
Realiza a consulta de registros selecionados na tela.
@author  hugo.de.oliveira
@since   24/03/2021
@version 1.0
/*/
Static Function fGetMarkPos()
	Local nPos 	:= 0
	Local nX 	:= 1

	For nX := 1 To Len(aInstSelected)
		If aInstSelected[nX]['idParcela'] == Alltrim((cTmpTable)->(TMP_IDINST))
			Return nX
		EndIf
	Next nX
Return nPos


/*/{Protheus.doc} function fSelectAll
Realiza a sele��o de todas as parcelas
@author  hugo.de.oliveira
@since   24/03/2021
@version 1.0
/*/
Function fSelectAll()
	Local nLast

	oBrowse:GoBottom(.F.)
	nLast := oBrowse:At()
	oBrowse:GoTop()
	
	While .T.
		oBrowse:MarkRec()
		If nLast == oBrowse:At()
			oBrowse:GoTop()
			Exit
		EndIf
		oBrowse:GoDown()
	EndDo
Return


/*/{Protheus.doc} function fSetTmpTable(aInstFiltered)
Cria e seta a tabela Tempor�ria para apresenta��o dos dados recebidos da Integra��o com o Consignado.
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fSetTmpTable(aInstFiltered)
	Local nX 		:= 1
	Local aColumns	:= {}
	Local lRet		:= .F.
	Local aArea		:= GetArea()

	aColumns  := fSetTmpColumn(aColumns)
	oTmpTable := FWTemporaryTable():New(cTmpTable, aColumns)
	oTmpTable:AddIndex("IDX1", {"TMP_CCODE"})
	oTmpTable:Create()

	// Preenche as parcelas j� fitradas na tabela tempor�ria
	DbSelectArea(cTmpTable)
		For nX := 1 To Len(aInstFiltered)
			RecLock(cTmpTable,.T.)
				fSetTmpFields(aInstFiltered[nX])
			MsUnLock()
		Next nX
		lRet := .T.
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} function fFilterInstallment(oInstallment, cStatusFilter)
Realiza a filtragem das parcelas de acordo com o que o usu�rio escolheu
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fFilterInstallment(oInstallment, cStatusFilter)
	Local nX := 1
	Local aInstFiltered := {}

	For nX := 1 To Len(oInstallment['items'])
		If fGetFolStatus(oInstallment['items'][nX]['employeeRegistration']) $ cStatusFilter
			aadd(aInstFiltered, oInstallment['items'][nX])
		EndIf
	Next nX
Return aInstFiltered


/*/{Protheus.doc} function fSetTmpFields(oInstallment)
Preenche as colunas da tabela tempor�ria
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fSetTmpFields(oInstallment)
	(cTmpTable)->TMP_PCODE  := oInstallment['partnerCode']
	(cTmpTable)->TMP_CPF	:= oInstallment['employeeCPF']
	(cTmpTable)->TMP_NOME	:= fConsFunc(cFilAnt, fAjustTam("RA_MAT", oInstallment['employeeRegistration']), "RA_NOME")
	(cTmpTable)->TMP_REG	:= oInstallment['employeeRegistration']
	(cTmpTable)->TMP_INUMB  := cValToChar(oInstallment['installmentNumber'])
	(cTmpTable)->TMP_IVALUE := cValToChar(oInstallment['installmentValue'])
	(cTmpTable)->TMP_IREM   := cValToChar(oInstallment['installmentRemaining'])
	(cTmpTable)->TMP_CDEBIT := cValToChar(oInstallment['contractTotalDebit'])
	(cTmpTable)->TMP_CCODE  := oInstallment['contractCode']
	(cTmpTable)->TMP_IDINST := oInstallment['installmentId']
Return


/*/{Protheus.doc} function fSetTmpColumn(aColumns)
Cria as colunas da tabela tempor�ria
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fSetTmpColumn(aColumns)
	DEFAULT aColumns := {}
	aAdd(aColumns, { "TMP_OK", 	   "C", 02,  00 })
	aAdd(aColumns, { "TMP_PCODE",  "C", 004, 00 })
	aAdd(aColumns, { "TMP_CPF",    "C", TamSx3("RA_CIC")[1], 00 })
	aAdd(aColumns, { "TMP_NOME",   "C", 500, 00 })
	aAdd(aColumns, { "TMP_REG",    "C", TamSx3("RA_MAT")[1], 00 })
	aAdd(aColumns, { "TMP_INUMB",  "C", 003, 00 })
	aAdd(aColumns, { "TMP_IVALUE", "C", 011, 00 })
	aAdd(aColumns, { "TMP_IREM",   "C", 003, 00 })
	aAdd(aColumns, { "TMP_CDEBIT", "C", 011, 00 })
	aAdd(aColumns, { "TMP_CCODE",  "C", 200, 00 })
	aAdd(aColumns, { "TMP_IDINST", "C", 50,  00 })
Return aColumns


/*/{Protheus.doc} function fMntColsMark
Cria coluna de marca��o das Parcelas
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fMntColsMark()
	Local nX			:= 0
	Local aColsAux 		:= {}
	Local aFields  		:= { "Op. Cr�d.","CPF Func.","Mat. Func.", "Nome Func.","Num. Parc.", "Vl. Parc.", "Parc.Falt.", "Total Emp.", "Contrato" }
	Local aFieldValue	:= { { ||(cTmpTable)->TMP_PCODE }, 	 ;
							 { ||(cTmpTable)->TMP_CPF }, 	 ;
							 { ||(cTmpTable)->TMP_REG }, 	 ;
							 { ||(cTmpTable)->TMP_NOME }, 	 ;
							 { ||(cTmpTable)->TMP_INUMB }, 	 ;
					     	 { ||(cTmpTable)->TMP_IVALUE },  ;
							 { ||(cTmpTable)->TMP_IREM }, 	 ;
							 { ||(cTmpTable)->TMP_CDEBIT },  ;
							 { ||(cTmpTable)->TMP_CCODE } 	 ;
							}

	For nX := 1 to Len(aFields)
		If !Empty(aFields[nX])
			aAdd(aColsAux, {aFields[nX], aFieldValue[nX], "C", ,1, 11, 2,.F.,,,,,,,,1})
		EndIf
	Next nX
Return aColsAux


/*/{Protheus.doc} function fMakeHeader(oInstSelected)
Monta os cabe�alhos que ser�o processados pelo ExecAuto580
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fMakeHeader(oInstSelected)
	Local aHeader := {}

	aadd(aHeader, {'RA_FILIAL', cFilAnt})
	aadd(aHeader, {'RA_MAT', 	oInstSelected['matricula']})
	aadd(aHeader, {'CPERIODO', 	oInstSelected['periodo']})
	aadd(aHeader, {'CROTEIRO', 	oInstSelected['roteiro']})
	aadd(aHeader, {'CNUMPAGTO', oInstSelected['semana']})
	
	if (lVerificaConsoleLog)
		Conout("##### DEBUG DE DADOS - fMakeHeader - INICIO #####")
		Conout("##### DEBUG DE DADOS - aHeader: " + VarInfo("aHeader", aHeader, , .F.))
		Conout("##### DEBUG DE DADOS - fMakeHeader - FIM #####")
	ENDIF

Return aHeader


/*/{Protheus.doc} function fMakeItem(oInstSelected)
Monta itens que ser�o enviados ao ExecAuto580
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fMakeItem(oInstSelected)
	Local aItens  := {}

	aAdd(aItens, {"RGB_FILIAL" , cFilAnt   						    , Nil })
	aAdd(aItens, {"RGB_MAT"    , oInstSelected['matricula'] 		, Nil })
	aAdd(aItens, {"RGB_PROCESS", oInstSelected['processo']   		, Nil })
	aAdd(aItens, {"RGB_CC"     , oInstSelected['centroDeCusto'] 	, Nil })
	aAdd(aItens, {"RGB_CODFUN" , oInstSelected['codFuncionario'] 	, Nil })
	aAdd(aItens, {"RGB_PD"     , oInstSelected['verba']   			, Nil })
	aAdd(aItens, {"RGB_SEMANA" , oInstSelected['semana']   			, Nil })
	aAdd(aItens, {"RGB_PERIOD" , oInstSelected['periodo']  			, Nil })
	aAdd(aItens, {"RGB_VALOR"  , VAL(oInstSelected['valorParcela'])	, Nil })
	aAdd(aItens, {"RGB_ROTEIR" , oInstSelected['roteiro']  			, Nil })
	aAdd(aItens, {"RGB_TIPO1"  , oInstSelected['tipoVerba'] 		, Nil })
	aAdd(aItens, {"RGB_TIPO2"  , oInstSelected['tipoInsercao'] 		, Nil })
	aAdd(aItens, {"RGB_DTREF"  , oInstSelected['dtPgtoPeriodo']  	, Nil })
	aAdd(aItens, {"RGB_NUMID"  , oInstSelected['idParcela']  		, Nil })
	aAdd(aItens, {"RGB_HORAS"  , VAL(oInstSelected['numeroParcela'] + "." + oInstSelected['parcelasRestantes']), Nil })
	
	if (lVerificaConsoleLog)
		Conout("##### DEBUG DE DADOS - fMakeItem - INICIO #####")
		Conout("##### DEBUG DE DADOS - aItens: " + VarInfo("aItens", aItens, , .F.))
		Conout("##### DEBUG DE DADOS - fMakeItem - FIM #####")
	ENDIF
Return aItens


/*/{Protheus.doc} function fCreateLog
Monta LOG com resultado da importacao
nCode == 200 - Sucesso
nCode == 300 - Valida��es de Campos obrigat�rios
nCode == 301 - Valida��o de sele��o de parcelas
nCode == 400 - N�o encontrado
@author  hugo.de.oliveira
@since   29/03/2021
@version 1.0
/*/
static Function fCreateLog(nCode, aMessage, aMat)
	Local nAux	 		:= 1
	Local aTitle 		:= {}
	DEFAULT nCode    	:= 200
	DEFAULT aMessage 	:= {}
	DEFAULT aMat  		:= {}

	aTitle := fCreateHeader(nAux, aTitle)

	If nCode == 400
		aTitle := fCreateTitle(nAux, aTitle, oEmToAnsi(STR0005)) // "N�o foram encontradas parcelas com o(s) par�metro(s) informado(s)"
	ElseIf nCode == 301
		aTitle :=  fCreateTitle(nAux, aTitle, STR0017) // STR0017: "Selecione pelo menos uma parcela para realizar a importa��o."
	ElseIf nCode == 302
		aTitle :=  fCreateTitle(nAux, aTitle, "N�o existe verba cadastrada para o parceiro: '" + aMessage[1] + "'.")
	ElseIf nCode == 303
		aTitle :=  fCreateTitle(nAux, aTitle, "Roteiro 'FOL' n�o est� cadastrado para este per�odo.")
	ElseIf nCode == 304
		aTitle :=  fCreateTitle(nAux, aTitle, "O per�odo '" + aMessage[1] +  "' n�o est� ativo ou n�o est� aberto")	
	Else
		aTitle := fCreateLine(nAux, aTitle, aMat)
	Endif
	
	// STR0010: "Log de Ocorrencias - Importa��o de Parcelas TOTVS Consignado" e STR0016: "CONSIG001"
	fMakeLog(aLog,aTitle,,,OemToAnsi(STR0016) + DTOS(dDataBase), OemToAnsi(STR0010), "M", "P",,.F.)

	aLog := {}
	aSelected := {}
Return


/*/{Protheus.doc} function fCreateTitle(nAux, aTitle, cMessage)
Realiza a cira��o de um novo t�tulo no log.
@author  hugo.de.oliveira
@since   28/03/2021
@version 1.0
/*/
Static function fCreateTitle(nAux, aTitle, cMessage)
	DEFAULT nAux 	 := 1
	DEFAULT cMessage := ""
	DEFAULT aTitle 	 := {}

	nAux ++
	aAdd(aLog, {})
	aAdd(aTitle, oEmToAnsi(cMessage))
	aAdd(aLog[nAux], replicate("-",130))
Return aTitle


/*/{Protheus.doc} function fCreateHeader(nAux, aTitle)
Realiza a montagem do Header do Log.
@author  hugo.de.oliveira
@since   12/11/2020
@version 1.0
/*/
Static Function fCreateHeader(nAux, aTitle)
	DEFAULT nAux 	 := 1
	DEFAULT aTitle 	 := {}

	aAdd(aTitle, oEmToAnsi(STR0007)) // STR0007: "Importa��o na Folha"
	aAdd(aLog, {})
	aAdd(aLog[nAux], oEmToAnsi(STR0012) + ": " + STR0013) // STR0012: "Destino" e STR0013: "Lan�amentos Mensais"
	aAdd(aLog[nAux], oEmToAnsi(STR0014) + ": " + STR0015) // STR0014: "Roteiro" e STR0015: "FOL"
	aAdd(aLog[nAux], oEmToAnsi(STR0021) + ": " + cYear + cMonth) // STR0021: "Per�odo"
	If !Empty(aInstSelected) .AND. !Empty(aInstSelected[1]['verba'])
		aAdd(aLog[nAux], oEmToAnsi(STR0026) + ": " + aInstSelected[1]['verba']) // STR0026: "Verba"
	Endif
	aAdd(aLog[nAux], oEmToAnsi(STR0022) + ": (" + cStatusFilter + ")") // STR0022: "Situa��es"
	aAdd(aLog[nAux], oEmToAnsi(STR0025) + ": " + ALLTRIM(STR(Len(aInstSelected)))) // STR0025: "Total de Parcelas Selecionadas"
Return aTitle


/*/{Protheus.doc} function fCreateLinefCreateLine(nAux, aTitle, aMat)
Realiza a cria��o das linhas do Log.
@author  hugo.de.oliveira
@since   28/03/2021
@version 1.0
/*/
Static function fCreateLine(nAux, aTitle, aMat)
	Local nX 			:= 1
	Local nY 			:= 1
	Local aImported 	:= {}
	Local aNotImported 	:= {}
	Local aLogDetail 	:= {}

	DEFAULT nAux 	:= 1
	DEFAULT aTitle 	:= {}
	DEFAULT aMat 	:= {}

	// Lan�amentos Importados
	aImported := fMarkImported(aMat)
	If len(aImported) > 0
		nAux ++
		aAdd(aLog, {})
		aAdd(aTitle, oEmToAnsi(STR0008) +"("+ALLTRIM(STR(Len(aImported)))+"): ") 	 // STR0008: "Lan�amentos Importados:"
		aAdd(aLog[nAux], oEmToAnsi(STR0011)) // STR0011: "Fil.       Mat.    Nome                               Parc. Restantes   Valor"
		aAdd(aLog[nAux], replicate("-",130))
		fCreateColumn(nAux, aImported, .F.)
	EndIf

	// Lan�amentos N�o Importados
	aNotImported := fMarkNotImported(aImported)
	If len(aNotImported) > 0
		nAux ++
		aAdd(aLog, {})
		aAdd(aTitle , oEmToAnsi(STR0009)+"("+ALLTRIM(STR(Len(aNotImported)))+"): ") 	 // STR0009: "Lan�amentos N�o Importados:"
		aAdd(aLog[nAux], oEmToAnsi(STR0011) + Space(3) + "Motivo.") // STR0011: "Fil.       Mat.    Nome                               Parc. Restantes   Valor"
		aAdd(aLog[nAux], replicate("-",130))
		fCreateColumn(nAux, aNotImported, .T.)
	EndIf

	// Preenche informa��es complementares do processamento do Log
	aLogDetail := fGetLogDetail()
	If len(aLogDetail) > 0
		nAux ++
		aAdd(aLog, {})
		aAdd(aTitle , oEmToAnsi(STR0024)) // "Informa��es complementares"
		For nX := 1 to len(aLogDetail)
			For nY := 1 to len(aLogDetail[nX])
				aAdd(aLog[nAux], aLogDetail[nX][nY])
			Next nY
		Next nX
	EndIf
Return aTitle


/*/{Protheus.doc} function fCreateColumn(nAux, aLogInput, lMotivo)
Realiza a montagem do log com os registros processados.
@author  hugo.de.oliveira
@since   28/03/2021
@version 1.0
/*/
static function fCreateColumn(nAux, aLogInput, lMotivo)
	Local nX := 1
	Local nColSpace := 1
	Local nColLog := MIN(nMaxParcLog, len(aLogInput))
	Local cMotivo := ""
 											//"Fil.       Mat.    Nome                               Parc. Restantes   Valor"
	DEFAULT aLogInput := {}
	DEFAULT lMotivo   := .F.

	For nX := 1 to nColLog
		nColSpace := nLogColDef - LEN(aLogInput[nX]['nomeFuncionario'])
		cMotivo   := IIF(lMotivo, aLogInput[nX]["motivo"]["reason"], cMotivo)
		aAdd(aLog[nAux], aLogInput[nX]['filialLogada'] + Space(3) + ;
							aLogInput[nX]['matricula'] + Space(2) + ;
							aLogInput[nX]['nomeFuncionario'] + Space(nColSpace) + ;
								StrZero(Val(aLogInput[nX]['parcelasRestantes']),3) + Space(10) + ;
							Str(Val(aLogInput[nX]['valorParcela']),12,2) + Space(10) + ;
							cMotivo)
							
	Next nX
return
