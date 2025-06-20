#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES002B
Fun��o de importa��o de par�metros do m�dulo GFE a partir de arquivo .txt

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFES002B(cArquivo)
Local aHeader := {}

Private oBrowse
Private cAliasPar

	CriaTab(aHeader)

	If CarregaDados(cArquivo,cAliasPar)

		oBrowse := FWMarkBrowse():New()
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(cAliasPar)
		oBrowse:SetFields(aHeader)
		oBrowse:SetFieldMark("X6_MARK")
		oBrowse:SetCustomMarkRec({|| GFES002MRK(.F.)})
		oBrowse:SetAllMark({|| GFES002MRK(.T.)})
		oBrowse:SetMenuDef("GFES002B")
		oBrowse:SetDescription("Par�metros do Sistema")
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:AddLegend("(cAliasPar)->X6_CONTARQ==(cAliasPar)->X6_CONTLOC","GREEN","Conte�do Igual")
		oBrowse:AddLegend("(cAliasPar)->X6_CONTARQ!=(cAliasPar)->X6_CONTLOC","RED"  ,"Conte�do Divergente")
		oBrowse:Activate()

	EndIf

Return

//-------------------------------------------------------------------
// Fun��o MenuDef
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Importar" ACTION "StaticCall(GFES002B,GFES002IMP)" OPERATION 3  ACCESS 0 //Monitor

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTab
Fun��o que cria a estrutura da tabela tempor�ria utilizada para
apresenta��o dos dados

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTab(aHeader)
Local aStruct    := {}
Local nTamFilial := Len(xFilial("SX6"))

	aHeader := {{"Filial"          ,"(cAliasPar)->X6_FIL"    ,"C",nTamFilial,0,"@!"},;
				{"Par�metro"       ,"(cAliasPar)->X6_VAR"    ,"C",10        ,0,"@!"},;
				{"Tipo"            ,"(cAliasPar)->X6_TIPO"   ,"C",1         ,0,"@!"},;
				{"Descri��o"       ,"(cAliasPar)->X6_DESCRIC","C",150       ,0,"@X"},;
				{"Conte�do Arquivo","(cAliasPar)->X6_CONTARQ","C",300       ,0,"@X"},;
				{"Conte�do Local"  ,"(cAliasPar)->X6_CONTLOC","C",300       ,0,"@X"}}

	aStruct := {{"X6_MARK"   ,"C",2         ,0},;
				{"X6_FIL"    ,"C",nTamFilial,0},;
				{"X6_VAR"    ,"C",10        ,0},;
				{"X6_TIPO"   ,"C",1         ,0},;
				{"X6_DESCRIC","C",150       ,0},;
				{"X6_CONTARQ","C",300       ,0},;
				{"X6_CONTLOC","C",300       ,0}}

	cAliasPar := GFECriaTab({aStruct,{"X6_VAR"}})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaDados
L� o arquivo e carrega os dados na tabela tempor�ria

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarregaDados(cArquivo,cAliasPar)
Local nHandle    := 0
Local cLine      := ""
Local cFil       := ""
Local cParametro := ""
Local cTipo      := ""
Local cDescricao := ""
Local cContArq   := ""
Local nInc       := 0

	// Abre o arquivo
	nHandle := FT_FUse(cArquivo)

	// Se houver erro de abertura abandona processamento
	If nHandle < 0
		MsgStop("Erro na abertura do arquivo!","Carregamento dos Dados")
		Return .F.
	EndIf


	nInc := CpoFilArq()

	// Posiciona na primeria linha
	FT_FGoTop()

	ProcRegua(FT_FLastRec())

	//Percorre todo o arquivo
	While !FT_FEOF()

		IncProc()

		cLine  := FT_FReadLn() // Retorna a linha corrente

		If  ("FILIAL" $ cLine) .Or. ("=" $ cLine) .Or. ("�" $ cLine)
			FT_FSKIP()
			Loop
		EndIf

		cFil       := AllTrim(SubStr(cLine, 1        , nInc))
		cParametro := AllTrim(SubStr(cLine, nInc+4   , 10))
		cTipo 	   := AllTrim(SubStr(cLine, nInc+17  , 1))
		cDescricao := AllTrim(SubStr(cLine, nInc+24  , 101))
		cContArq   := AllTrim(SubStr(cLine, nInc+127 , 30))
		cContLoc   := AllTrim(cValToChar(SuperGetMV(cParametro,.F.,"")))

		// Grava dados na tabela tempor�ria
		RecLock((cAliasPar),.T.)
			(cAliasPar)->X6_FIL     := cFil // Deve importar de acordo com a filial corrente
			(cAliasPar)->X6_VAR     := cParametro
			(cAliasPar)->X6_TIPO    := cTipo
			(cAliasPar)->X6_DESCRIC := cDescricao
			(cAliasPar)->X6_CONTARQ := cContArq
			If Empty(cContLoc)
				(cAliasPar)->X6_CONTLOC := "Par�metro em branco"
			Else
				(cAliasPar)->X6_CONTLOC := cContLoc
			EndIf
		(cAliasPar)->(MsUnlock())

		// Pula para pr�xima linha
		FT_FSKIP()

	EndDo

	// Fecha o arquivo
	FT_FUSE()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar
Importa os par�metros marcados para o sistema

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES002IMP()

	Processa({|| Importacao()},"Importa��o de Par�metros do Sistema","Aguarde...")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar
Importa os par�metros marcados para o sistema

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Importacao()
	Local lDiver := .F.

	(cAliasPar)->(DbGoTop())
	ProcRegua((cAliasPar)->(LastRec()))

	While (cAliasPar)->(!Eof())
		//Incrementa r�gua de progress�o
		IncProc()
		//Importa apenas os registros marcados e que n�o possuem divergencia
		If !Empty((cAliasPar)->X6_MARK) 
			If (cAliasPar)->X6_CONTARQ == (cAliasPar)->X6_CONTLOC
				PutMv((cAliasPar)->X6_VAR,(cAliasPar)->X6_CONTARQ,.F.)
			Else 
				lDiver := .T.
			EndIf
		EndIf
		(cAliasPar)->(DbSkip())
	EndDo

	If lDiver
		MsgStop("Existem registros com divergencia que n�o ser�o importados!")
	EndIf 
	MsgInfo("Importa��o finalizada!")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES002MRK
Fun��o de marca��o dos registros

@author  Matheus de Souza
@since   21/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES002MRK(lAllMark)
Local cMark := Iif(oBrowse:IsMark(oBrowse:Mark()),"  ",oBrowse:Mark())

	//Marca todos os registros
	If lAllMark
		(cAliasPar)->(DbGoTop())
		While (cAliasPar)->(!Eof())
			RecLock((cAliasPar),.F.)
			(cAliasPar)->X6_MARK := cMark
			(cAliasPar)->(MsUnlock())
			(cAliasPar)->(DbSkip())
		EndDo
		(cAliasPar)->(DbGoTop())
		oBrowse:GoTop()
	//Marca apenas um registro
	Else
		RecLock((cAliasPar),.F.)
		(cAliasPar)->X6_MARK := cMark
		(cAliasPar)->(MsUnlock())
	EndIf

	oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CpoFilArq
Descobre o tamanho do campo Filial no arquivo de importa��o

@author  Matheus de Souza
@since   21/12/2022
@obs     Para os casos em que os ambientes de exporta��o e importa��o
         possu�rem tamanho de filial diferentes
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CpoFilArq()
Local nRet := 0

	FT_FGoTop()

	//Percorre todo o arquivo
	While !FT_FEOF()

		cLine := FT_FReadLn() // Retorna a linha corrente

		If  ("FILIAL" $ cLine) .Or. ("=" $ cLine) .Or. ("�" $ cLine)
			FT_FSKIP()
			Loop
		Else
			nRet := (At("|",cLine) - 2)
			Exit
		EndIf

	EndDo

Return nRet
