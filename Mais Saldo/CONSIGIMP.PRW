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
#DEFINE nPageSizeDef    100000
#DEFINE nPageDef    	1


/*/{Protheus.doc} function CONSIGIMP
Lan�amento de parcelas do TOTVS Consignado para multiplas filiais.
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function CONSIGIMP()
	Local aBranch		  	:= {}

	Static _ScreenSelected 	:= {}

	Private nMaxCNPJDef     := 80
	Private aSelected 		:= {}
	Private aLog			:= {}
	Private aInstSelected	:= {}
	Private aPartner		:= {}
	Private nMaxInst		:= 0
	Private oParam  		:= JsonObject():New()
	Private oBrowse 		:= FWMarkBrowse():New()

	// Controle de valida��o do retorno de sucesso/erro/warnings da rotina GPEA580.
	Private lExecAutoError	:= .F.
	Private lMsErrorAuto	:= .F.
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T.	// Se ativada retorna no log atrav�s do GetAutoGRLog. Se desativada, grava em disco.

	// Cria par�metro de controle que define quantos CNPJs ser�o consultados na Integra��o por vez.
	If Getmv("MV_MAXCNPJ",,"0") == "0"
		fUpdSX6("MV_MAXCNPJ", "80", "N�mero de CNPJs por consulta na Import. Parcelas.", "C")
	EndIf

	nMaxCNPJDef := Val(GetMv("MV_MAXCNPJ"))

	If Pergunte("CONSIG001", .T.)
		oParam['month']  := SUBSTR(MV_PAR01, 5, 2)
		oParam['year']   := SUBSTR(MV_PAR01, 0, 4)
		oParam['status'] := MV_PAR02

		aBranch := CONSIGBRANCH()
		If Empty(aBranch)
			fCreateLog(402)
			Return
		EndIf

		fCreateScreen(aBranch)
	EndIf
Return


/*/{Protheus.doc} function fCreateScreen(aBranch)
Cria a tela tempor�ria de sele��o de Parcelas
@author  hugo.de.oliveira
@since   11/04/2022
@version 1.0
/*/
Static Function fCreateScreen(aBranch)
	Local aInstFiltered := {}
	Private cTmpTable   := GetNextAlias()

	// Se n�o encontrar parcelas ou n�o for informado nenhum status de situa��o do funcion�rio
	aInstFiltered := fGetInstallment(aBranch)
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
	oBrowse:SetMenuDef('CONSIGIMP')
	oBrowse:SetDescription(OemToAnsi(STR0006)) // STR0006: "Importa��o de Parcelas"
	oBrowse:SetAfterMark({|| fSelInst() })
	oBrowse:SetAllMark({|| fSelAllInst() })
	oBrowse:Activate()
	DbCloseArea()
Return


/*/{Protheus.doc} function fGetInstallment(aBranch)
Consulta parcelas de acordo com o CNPJ da Filial logada, per�odo e Status do funcion�rio.
@author  hugo.de.oliveira
@since   11/04/2022
@version 1.0
/*/
Static Function fGetInstallment(aBranch)
	Local oInteg
	Local cRacToken     := ""
	Local cParam 		:= ""
	Local aHeader       := {}
	Local aInstFiltered := {}
	Local aBranches		:= {}
	Local oInstallment  := JsonObject():New()
	Local lStatusEmpty  := (oParam['status'] == "*****")
	Local cEndPoint	    := fGetURLCsg()
	Local nX 			:= 1

	If Empty(cEndPoint) .OR. lStatusEmpty
		Return aInstFiltered
	EndIf

	oInteg    := FwRest():New(cEndPoint + "/api/erp/v1/installmentDetail")
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	aBranches := SplitArray(aBranch, nMaxCNPJDef)

	aInstFiltered := {}
	For nX := 1 To Len(aBranches)
		cParam := SetParam(aBranches[nX])
		oInteg:setPath("?" + cParam)
		
		If oInteg:Get(aHeader)
			If oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult())
				oInstallment:FromJson(oInteg:GetResult())
				aInstFiltered := fFilterInstallment(oInstallment, aBranch, aInstFiltered)
			EndIf
		EndIf
	Next nX
Return aInstFiltered


/*/{Protheus.doc} function SetParam(aBranch)
Seta par�metros usados na chamada da integra��o de consulta de parcelas.
@author  hugo.de.oliveira
@since   11/04/2022
@version 1.0
/*/
Static Function SetParam(aBranch)
	Local cRet := ""
	Local nX   := 1

	For nX := 1 To Len(aBranch)
		cRet += "CNPJs=" + aBranch[nX]['cnpjFilial'] + "&"
	Next nX

	cRet += "month=" + oParam['month'] + ;
			"&year=" + oParam['year'] + ;
			"&page=" +  ALLTRIM(STR(nPageDef)) + ;
			"&pageSize=" + ALLTRIM(STR(nPageSizeDef))
Return cRet



/*/{Protheus.doc} function fImpInst
Incia o processo de Importa��o das Parcelas
@author  hugo.de.oliveira
@since   04/02/2022 
@version 1.0
/*/
Function fImpInst()
	Local nX		  := 1
	Local aMat 		  := {}

	fSetSelected()

	// Valida sele��o de parcelas pelo usu�rio
	If Empty(aInstSelected)
		fCreateLog(403)
		Return
	EndIf

	For nX := 1 To Len(aInstSelected)
		aHeader := {}
		aItens 	:= {}
		If(Empty(aInstSelected[nX]['motivoInvalido']))
			aMat := fFormatToSave(aMat, aInstSelected[nX])
		EndIF
	Next nX

	fSaveInstallment(aMat)
	fCreateLog(200, {}, aMat)
	Closebrowse()
Return


/*/{Protheus.doc} function fSetSelected
Completa demais informa��es necess�rias para lan�amento na RGB
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fSetSelected()
	Local nX := 1

	For nX := 1 To Len(aInstSelected)
		aInstSelected[nX]['periodo'] 		   := oParam['year'] + oParam['month']
		aInstSelected[nX]['tipoInsercao'] 	   := "G" // Usado por rotinas autom�ticas, como no GPEA580
		aInstSelected[nX]['roteiro']		   := fGetRotOrdinar() // Roteiro da folha

		aInstSelected[nX]['processo']		   := fConsFunc(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['matricula'], "RA_PROCES")
		aInstSelected[nX]['centroDeCusto']	   := fConsFunc(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['matricula'], "RA_CC")
		aInstSelected[nX]['codFuncionario']	   := fConsFunc(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['matricula'], "RA_CODFUNC")

		aInstSelected[nX]['verba'] 			   := fGetS137Pd(cFilAnt, aInstSelected[nX]['codigoParceiro'])
		aInstSelected[nX]['tipoVerba'] 		   := fConsVerba(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['verba'], "RV_TIPO")
		aInstSelected[nX]['semana']  		   := fConsCabPer(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['processo'], oParam['year'], oParam['month'], "RCF_SEMANA")
		aInstSelected[nX]['fechamentoPeriodo'] := fConsPer(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['processo'], aInstSelected[nX]['periodo'], "RCH_DTFECH")
		aInstSelected[nX]['statusPeriodo'] 	   := fConsPer(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['processo'], aInstSelected[nX]['periodo'], "RCH_STATUS")
		aInstSelected[nX]['dtPgtoPeriodo']	   := fConsPer(aInstSelected[nX]['codigoFilial'], aInstSelected[nX]['processo'], aInstSelected[nX]['periodo'], "RCH_DTPAGO")
		aInstSelected[nX]['motivoInvalido']	   := fValidParc(aInstSelected[nX])		
	Next nX
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
	Local lPerAtivo    := .F.
	Local cMessage 	   := ""

	lPerAberto := (Empty(oInstSelected['fechamentoPeriodo']) .And. oInstSelected['statusPeriodo'] != "5")
	lPerAtivo  := fConsPer(oInstSelected['codigoFilial'], oInstSelected['processo'], oInstSelected['periodo'], "RCH_PERSEL") == "1"

	If Empty(oInstSelected['verba'])
		cMessage := "Verba associada ao parceiro '" + oInstSelected['codigoParceiro'] + "' n�o encontrada."

	ElseIf !lPerAtivo .OR. !lPerAberto
		cMessage := "Per�odo '" + oInstSelected['periodo'] +  "' n�o se encontra aberto."
	EndIf
Return cMessage


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
		cKeyRGB := xFilial(("RGB"), aInstSelected[nX]['codigoFilial']) + aInstSelected[nX]['matricula'] + aInstSelected[nX]['verba'] + aInstSelected[nX]['periodo']

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


/*/{Protheus.doc} function MenuDef
Realiza a cria��o dos menus da tela de importa��o.
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function MenuDef()
	Private aMenu :=  {}
	ADD OPTION aMenu TITLE OemToAnsi(STR0019) ACTION 'fImpInst()' 	OPERATION 7 ACCESS 0  // "Importar"
	ADD OPTION aMenu TITLE OemToAnsi(STR0020) ACTION 'fSelAllInst()' OPERATION 8  ACCESS 0 // "Marcar/Desmarcar"
Return aMenu


/*/{Protheus.doc} function fSelInst
Realiza a sele��o de 1 parcela
@author  hugo.de.oliveira
@since   24/03/2021
@version 1.0
/*/
Static Function fSelInst()
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
			oSelected['cnpjFilial'] 		:= Alltrim((cTmpTable)->TMP_CNPJ)
			oSelected['codigoFilial'] 		:= (cTmpTable)->TMP_CDFIL

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


/*/{Protheus.doc} function fSelAllInst
Realiza a sele��o de todas as parcelas
@author  hugo.de.oliveira
@since   24/03/2021
@version 1.0
/*/
Function fSelAllInst()
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

	aColumns  := fSetTmpColumn()
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


/*/{Protheus.doc} function fFilterInstallment(oInstallment, aBranch, aInstFiltered)
Realiza a filtragem das parcelas de acordo com o que o usu�rio escolheu
@author  hugo.de.oliveira
@since   04/02/2022
@version 1.0
/*/
Static Function fFilterInstallment(oInstallment, aBranch, aInstFiltered)
	Local nPos 			:= 1
	Local nX 			:= 1
	Local cCNPJ 		:= ""
	Local cBranchCode 	:= ""

	DEFAULT oInstallment  :=  JsonObject():New()
	DEFAULT aInstFiltered := {}
	DEFAULT aBranch 	  := {}

	For nX := 1 To Len(oInstallment['items'])
		cCNPJ := ALLTRIM(oInstallment['items'][nX]['companyCNPJ'])
		nPos  := aScan(aBranch, {|x| x['cnpjFilial'] == cCNPJ })
		cBranchCode := fAjustTam("RA_FILIAL", aBranch[nPos]['codigoFilial'])
		
		If fGetFolStatus(oInstallment['items'][nX]['employeeRegistration'], cBranchCode) $ oParam['status']
			oInstallment['items'][nX]['codigoFilial'] := cBranchCode
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
	(cTmpTable)->TMP_NOME	:= fConsFunc(oInstallment['codigoFilial'], fAjustTam("RA_MAT", oInstallment['employeeRegistration']), "RA_NOME")
	(cTmpTable)->TMP_REG	:= oInstallment['employeeRegistration']
	(cTmpTable)->TMP_INUMB  := cValToChar(oInstallment['installmentNumber'])
	(cTmpTable)->TMP_IVALUE := cValToChar(oInstallment['installmentValue'])
	(cTmpTable)->TMP_IREM   := cValToChar(oInstallment['installmentRemaining'])
	(cTmpTable)->TMP_CDEBIT := cValToChar(oInstallment['contractTotalDebit'])
	(cTmpTable)->TMP_CCODE  := oInstallment['contractCode']
	(cTmpTable)->TMP_IDINST := oInstallment['installmentId']
	(cTmpTable)->TMP_CNPJ   := oInstallment['companyCNPJ']
	(cTmpTable)->TMP_CDFIL  := oInstallment['codigoFilial']
Return


/*/{Protheus.doc} function fSetTmpColumn()
Cria colunas da tabela tempor�ria
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fSetTmpColumn()
	Local aColumns := {}

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
	aAdd(aColumns, { "TMP_CNPJ",   "C", 14,  00 })
	aAdd(aColumns, { "TMP_CDFIL",  "C", TamSx3("RA_FILIAL")[1], 00 })
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
	Local aFields  		:= { "Op. Cr�d.","CPF Func.","Mat. Func.", "Nome Func.","Num. Parc.", "Vl. Parc.", "Parc.Falt.", "Total Emp.", "Contrato","CNPJ","Cod. Fil." }
	Local aFieldValue	:= { { ||(cTmpTable)->TMP_PCODE }, 	 ;
							 { ||(cTmpTable)->TMP_CPF }, 	 ;
							 { ||(cTmpTable)->TMP_REG }, 	 ;
							 { ||(cTmpTable)->TMP_NOME }, 	 ;
							 { ||(cTmpTable)->TMP_INUMB }, 	 ;
					     	 { ||(cTmpTable)->TMP_IVALUE },  ;
							 { ||(cTmpTable)->TMP_IREM }, 	 ;
							 { ||(cTmpTable)->TMP_CDEBIT },  ;
							 { ||(cTmpTable)->TMP_CCODE }, 	 ;
							 { ||(cTmpTable)->TMP_CNPJ }, 	 ;
							 { ||(cTmpTable)->TMP_CDFIL } 	 ;
							}

	For nX := 1 to Len(aFields)
		If !Empty(aFields[nX])
			aAdd(aColsAux, {aFields[nX], aFieldValue[nX], "C", ,1, 11, 2,.F.,,,,,,,,1})
		EndIf
	Next nX
Return aColsAux


/*/{Protheus.doc} function fCreateLog
Monta LOG com resultado da importacao
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
	ElseIf nCode == 402
		aTitle := fCreateTitle(nAux, aTitle, oEmToAnsi("Selecione pelo menos uma filial para realizar a importa��o."))
	ElseIf nCode == 403
		aTitle :=  fCreateTitle(nAux, aTitle, STR0017) // STR0017: "Selecione pelo menos uma parcela para realizar a importa��o."
	Else
		aTitle := fCreateLine(nAux, aTitle, aMat)
	Endif
	
	// STR0010: "Log de Ocorrencias - Importa��o de Parcelas TOTVS Consignado"
	// STR0016: "CONSIG001"
	fMakeLog(aLog,  ; // Array que contem os Detalhes de Ocorrencia de Log
			aTitle, ; // Array que contem os Titulos de Acordo com as Ocorrencias
			NIL,	; // Pergunte a Ser Listado
			NIL,	; // Se Havera "Display" de Tela
			OemToAnsi(STR0016) + DTOS(dDataBase), ; // Nome Alternativo do Log
			OemToAnsi(STR0010), ; // Titulo Alternativo do Log
			"M", 	; // Tamanho Vertical do Relatorio de Log ("P","M","G")
			"P",	; // Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
			NIL,	; //Array com a Mesma Estrutura do retorno
			.F.,	; // Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
			NIL     ; // Array com as perguntas selecionadas
			)
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
	aAdd(aLog[nAux], oEmToAnsi(STR0021) + ": " + oParam['year'] + oParam['month']) // STR0021: "Per�odo"
	aAdd(aLog[nAux], oEmToAnsi(STR0022) + ": (" + oParam['status'] + ")") // STR0022: "Situa��es"
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
		cMotivo   := IIF(lMotivo, aLogInput[nX]["motivoInvalido"], cMotivo)
		aAdd(aLog[nAux], aLogInput[nX]['codigoFilial'] + Space(3) + ;
							aLogInput[nX]['matricula'] + Space(2) + ;
							aLogInput[nX]['nomeFuncionario'] + Space(nColSpace) + ;
								StrZero(Val(aLogInput[nX]['parcelasRestantes']),3) + Space(10) + ;
							Str(Val(aLogInput[nX]['valorParcela']),12,2) + Space(10) + ;
							cMotivo)				
	Next nX
return
