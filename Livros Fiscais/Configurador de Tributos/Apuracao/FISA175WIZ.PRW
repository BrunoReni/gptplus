#Include "FISA175WIZ.ch"
#INCLUDE "PROTHEUS.CH"

// Prote��o pois em bin�rios 32 bits o objeto TSay n�o possui o m�todo SetTextAlign.
STATIC oSayCheck  := TSay():New()
STATIC lMethAlign := MethIsMemberOf(oSayCheck, "SetTextAlign")
STATIC oFont18 := TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA175WIZ()

Fun��o principal para execu��o da Wizard.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA175WIZ()

Local aParams := {}

aParams := x175WWiz()

Return aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WWiz()

Fun��o respons�vel pela montagem da wizard de parametriza��o da
apura��o.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WWiz()

Local aCoords     := FWGetDialogSize()
Local oPagIni     := NIL
Local cAlsDados   := ""
Local nSteps      := 0
Local oStepWiz    := NIL
Local aParams     := {}
Local oMarkBr     := NIL

// Tabela tempor�ria para utilizar no MarkBrowse de sele��o dos tributos...
oTmpTbl := x175WTRB()

// Cria a wizard
oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.8, aCoords[4] * 0.8})
oStepWiz:ActiveUISteps()

nSteps +=1

oPagIni := oStepWiz:AddStep(cValToChar(nSteps))
//Altera a descri��o do step
oPagIni:SetStepDescription(STR0001) //"Par�metros"
//Define o bloco de constru��o
oPagIni:SetConstruction({|Panel|x175WParam(Panel, oTmpTbl, @oMarkBr)})
//Define o bloco ao clicar no bot�o Pr�ximo
oPagIni:SetNextAction({|| x175WValid(oMarkBr) .And. x175WGetPar(@aParams, oMarkBr) })

oStepWiz:Activate()
oStepWiz:Destroy()

// Exclui a tabela tempor�ria do MarkBrowse
oTmpTbl:Delete()

Return aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WParam()

Fun��o respons�vel por retornar a estrutura dos campos utilizados nas
MGMGET's dos filtros.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WParam(oPanel, oTmpTbl, oMarkBr)

Local aRet := {}
Local nPos := 0
Local oLayer   := NIL
Local oPanel0  := NIL
Local oPanel1  := NIL
Local oPanel2  := NIL
Local cAlsMark := ""
Local aFields := {}
Local aEstrut := {}
Local aColumns := {}

PRIVATE oGetsProd := NIL

// Cria��o das layers para montagem do layout da p�gina
oLayer := FWLayer():New()
oLayer:Init(oPanel,.F.)
oLayer:AddLine('LIN0', 10, .F.)
oLayer:AddLine('LIN1', 30, .F.)
oLayer:addCollumn('LIN1_COL1',100,.F.,'LIN1')
oLayer:AddLine('LIN2', 60, .F.)
oLayer:addCollumn('LIN2_COL1',100,.F.,'LIN2')
oLayer:AddWindow('LIN2_COL1','W1',"Tributos",100,.F.,.F.,,'LIN2')

// Obtendo paineis conforme distribui��o das layers
oPanel0 := oLayer:getLinePanel('LIN0')
oPanel1 := oLayer:getColPanel('LIN1_COL1', 'LIN1')
oPanel2 := oLayer:getWinPanel('LIN2_COL1', 'W1', 'LIN2')

// T�tulo da p�gina
oSayTitulo := TSay():New(5,5,{||STR0002},oPanel0,,oFont18,,,,.T.,,,(oPanel0:nWidth / 2) - 5,(oPanel0:nHeight / 2) - 5) //"Informe os par�metros para execu��o da apura��o e selecione o(s) tributo(s) que ser�o apurados..."
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Montagem da MsMGet
aEstrut := x175WEstru()
aEval(aEstrut, {|x| aAdd(aFields, x[2])})
oGetsProd := MsmGet():New(,,3,,,,aFields,{0,3,((oPanel1:nClientHeight/2)-5),((oPanel1:nClientWidth/2)-5)},,,,,,oPanel1,,,.T.,,,.T.,aEstrut,,,,,.T.)

// Alias que ser� utilizado no MarkBrowse - Recupera o alias da tabela tempor�ria.
cAlsMark := oTmpTbl:GetAlias()

// Cria as colunas do MarkBrowse conforme a estrutura da tabela tempor�ria.
aColumns := x175WStr2Col(oTmpTbl:GetStruct():aFields) 

// Cria��o do MarkBrowse
oMarkBr:= FWMarkBrowse():New()
oMarkBr:SetOwner(oPanel2)
oMarkBr:SetDataTable(.T.)
oMarkBr:SetAlias(cAlsMark) //Indica o alias da tabela que ser� utilizada no Browse
oMarkBr:SetColumns(aColumns)
oMarkBr:SetFieldMark("TRB_OK") //Indica o campo que dever� ser atualizado com a marca no registro
oMarkBr:SetMark("OK", cAlsMark, "TRB_OK")
oMarkBr:SetAllMark({||x175WMarkAll(oMarkBr)})
oMarkBr:SetMenuDef("")
oMarkBr:SetIgnoreARotina(.T.)
oMarkBr:SetAmbiente(.F.)
oMarkBr:oBrowse:SetDBFFilter(.F.)
oMarkBr:oBrowse:SetUseFilter(.F.) //Habilita a utiliza��o do filtro no Browse
oMarkBr:SetWalkThru(.F.)
oMarkBr:DisableReport()
oMarkBr:DisableDetails()
oMarkBr:Activate()

oGetsProd:SetFocus()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WEstru()

Fun��o respons�vel por retornar a estrutura dos campos utilizados nas
MGMGET's dos filtros.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WEstru()

Local nPos := 0
Local aRet := {}

nPos := x175WAddStru(@aRet)

aRet[nPos][01] := "Data Inicial"
aRet[nPos][02] := 'dDataIni'
aRet[nPos][03] := 'D'
aRet[nPos][04] := 8
_SetNamedPrvt( "dDataIni" , cToD("//"), 'FISA175WIZ')

nPos := x175WAddStru(@aRet)

aRet[nPos][01] := "Data Final"
aRet[nPos][02] := 'dDataFim'
aRet[nPos][03] := 'D'
aRet[nPos][04] := 8
_SetNamedPrvt( "dDataFim" , cToD("//"), 'FISA175WIZ')

nPos := x175WAddStru(@aRet)

aRet[nPos][01] := "Seleciona Filiais"
aRet[nPos][02] := 'cSelFil'
aRet[nPos][03] := 'C'
aRet[nPos][04] := 1
aRet[nPos][15] := "1=Sim;2=N�o"
aRet[nPos][07] := {||Pertence("12")}
_SetNamedPrvt( "cSelFil" , "2", 'FISA175WIZ')

/*
nPos := x175WAddStru(@aRet)

aRet[nPos][01] := "Processamento"
aRet[nPos][02] := 'cTpProc'
aRet[nPos][03] := 'C'
aRet[nPos][04] := 1
aRet[nPos][15] := "1=Centralizado;2=Individualizado"
aRet[nPos][07] := {||Pertence("12")}
_SetNamedPrvt( "cTpProc" , "1", 'FISA175WIZ') */

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WGetPar()

Fun��o respons�vel por retornar os parametros configurados na wizard.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WGetPar(aParams, oMark)

Local cAlsMark := oMark:Alias()
Local cMark    := oMark:Mark()
Local cTributos := ""

aAdd(aParams, dDataIni)
aAdd(aParams, dDataFim)
aAdd(aParams, cSelFil)

// Lista dos tributos selecionados
(cAlsMark)->( DbGoTop() )
While (cAlsMark)->( !EOF() ) 
    If oMark:IsMark(cMark)
        cTributos += (cAlsMark)->F2E_TRIB + "|"
    EndIf
    (cAlsMark)->( DbSkip() )
EndDo

// Tratamento p/ retirar o �ltimo pipe para que a formata��o fique correta na query.
// Se a string terminar com pipe a fun��o FormatIn retorna a ultima posi��o em branco.
aAdd(aParams, SubStr(cTributos, 1, Len(cTributos) - 1))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WAddStru()

Fun��o respons�vel por adicionar um item de estrutura com os valores
DEFAULT. Este item ser� utilizado pela fun��o x175Estrut para composi��o
das MGMGET's utilizadas nos steps de filtro.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WAddStru(aEstruct)

Local nPosicao   := 0

DEFAULT aEstruct := {}

Aadd(aEstruct,{})
nPosicao := Len(aEstruct)

Aadd(aEstruct[nPosicao],'')			// 01 - Titulo
Aadd(aEstruct[nPosicao],'')			// 02 - Campo
Aadd(aEstruct[nPosicao],'')			// 03 - Tipo
Aadd(aEstruct[nPosicao],0)			// 04 - Tamanho
Aadd(aEstruct[nPosicao],0)			// 05 - Decimal
Aadd(aEstruct[nPosicao],'')			// 06 - Picture
Aadd(aEstruct[nPosicao],{|| .T. })	// 07 - Valid
Aadd(aEstruct[nPosicao],.F.)		// 08 - Obrigat
Aadd(aEstruct[nPosicao],1)			// 09 - Nivel
Aadd(aEstruct[nPosicao],'')			// 10 - Inicializador Padr�o
Aadd(aEstruct[nPosicao],'')			// 11 - F3
Aadd(aEstruct[nPosicao],{|| })		// 12 - When
Aadd(aEstruct[nPosicao],.F.)		// 13 - Visual
Aadd(aEstruct[nPosicao],.F.)		// 14 - Chave
Aadd(aEstruct[nPosicao],'')			// 15 - Box - Op��o do combo
Aadd(aEstruct[nPosicao],0)			// 16 - Folder
Aadd(aEstruct[nPosicao],.F.)		// 17 - N�o Alter�vel
Aadd(aEstruct[nPosicao],'')			// 18 - PictVar
Aadd(aEstruct[nPosicao],'N')		// 19 - Gatilho

Return nPosicao

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WTRB()

Fun��o respons�vel por criar e fazer a carga da tabela tempor�ria que
ser� utilizada na montagem do MarkBrowse dos perfis.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WTRB(cAlsDados)

Local oTmpTbl := NIL
Local cAlsQry := GetNextAlias()
Local cAlsTmp := GetNextAlias()
Local aCampos := {}

// Campos
aAdd(aCampos, {"TRB_OK", "C", 2, 0})
aAdd(aCampos, {"F2E_TRIB", "C", TamSX3("F2E_TRIB")[1], TamSX3("F2E_TRIB")[2]}) 
aAdd(aCampos, {"F2E_DESC", "C", TamSX3("F2E_DESC")[1], TamSX3("F2E_DESC")[2]}) 

// Cria��o da tabela tempor�ria
oTmpTbl := FWTemporaryTable():New(cAlsTmp, aCampos)

// Adicionando �ndices
oTmpTbl:AddIndex("1", {"F2E_TRIB"})

// Cria a tabela
oTmpTbl:Create()

// Query para retornar os tributos da F2E...
BeginSQL Alias cAlsQry
  	SELECT DISTINCT F2E.F2E_TRIB, F2E.F2E_DESC
	FROM %table:F2E% F2E
    INNER JOIN %Table:F2B% F2B ON F2B.F2B_FILIAL = %xFilial:F2B% AND F2B.F2B_TRIB = F2E.F2E_TRIB AND F2B.%NotDel%
    INNER JOIN %Table:F2G% F2G ON F2G.F2G_FILIAL = %xFilial:F2G% AND F2G.F2G_CODIGO = F2B.F2B_RAPUR AND F2G.%NotDel%
	WHERE 
    F2E.F2E_FILIAL = %xFilial:F2E% AND
	F2E.%NotDel%
    ORDER BY F2E.F2E_TRIB
EndSQL

dbSelectArea(cAlsQry)
(cAlsQry)->(dbGoTop())

// Populando a tabela tempor�ria com o conte�do do alias passado por par�metro...
While !(cAlsQry)->(EoF())

    RecLock(cAlsTmp, .T.)
        (cAlsTmp)->TRB_OK := Space(2)
        (cAlsTmp)->F2E_TRIB := (cAlsQry)->F2E_TRIB
        (cAlsTmp)->F2E_DESC := (cAlsQry)->F2E_DESC
    (cAlsTmp)->(MsUnlock())

    (cAlsQry)->(dbSkip())

EndDo

// Fechando o alias da query
(cAlsQry)->(dbCloseArea())

Return oTmpTbl

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WStr2Col()

Fun��o respons�vel por "converter" a estrutura da tabela passada em 
um array de FWBrwColumn que ser�o utilizadas na montagem do markbrowse
e tamb�m do browse de resumo dos perfis.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WStr2Col(aCampos)

Local aRet := {}
Local nX := 0
Local nPosRet := 0

For nX := 1 to Len(aCampos)
     If aCampos[nX][1] <> "TRB_OK"
        AAdd(aRet,FWBrwColumn():New())
        nPosRet := Len(aRet)
        aRet[nPosRet]:SetData( &("{||"+aCampos[nX][1]+"}") )
        aRet[nPosRet]:SetTitle(RetTitle(aCampos[nX][1])) 
        aRet[nPosRet]:SetSize(aCampos[nX][3])
        aRet[nPosRet]:SetDecimal(aCampos[nX][4])
        aRet[nPosRet]:SetPicture("@!")
    EndIf
Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WMarkAll()

Fun��o respons�vel por marcar/desmarcar todos os registros.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 18/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WMarkAll(oObjMark)

Local cAlsMark := oObjMark:Alias()
Local cMark    := oObjMark:Mark()

(cAlsMark)->( DbGoTop() )
While (cAlsMark)->( !EOF() ) 
    RecLock(cAlsMark, .F.)
    If oObjMark:IsMark(cMark)
        (cAlsMark)->TRB_OK := "  "
    Else
        (cAlsMark)->TRB_OK := cMark
    EndIF
    MsUnlock()
    (cAlsMark)->( DbSkip() )
EndDo

//Retorno para a primeira linha
(cAlsMark)->( DbGoTop() )
oObjMark:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} x175WValid()

Fun��o que faz valida��o da sele��o dos perfis, � necess�rio ter ao menos 
um perfil selecionado para prosseguir.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175WValid(oObjMark) 

Local cAlsMark := oObjMark:Alias()
Local cMark    := oObjMark:Mark()
Local lRet     := .T.
Local nSel     := 0

// Verifica se as datas foram preenchidas
If Empty(dDataIni) .Or. Empty(dDataFim)
    lRet := .F.
    Alert(STR0003) //"Os campos de data inicial e data final devem ser preenchidos."
EndIf

// Verifica se ao menos um tributo foi selecionado.
If lRet 
    // Percorre as linhas verificando se alguma foi marcada.
    (cAlsMark)->( DbGoTop() )
    While (cAlsMark)->( !EOF() ) 
        If oObjMark:IsMark(cMark)
            nSel++
        EndIF
        (cAlsMark)->( DbSkip() )
    EndDo

    //Retorno para a primeira linha
    (cAlsMark)->( DbGoTop() )
    oObjMark:Refresh(.T.)

    If nSel == 0
        lRet := .F.
        Alert(STR0004) //"Dever� ser selecionado ao menos um tributo para apurar."
    EndIF
EndIf

// Verifica se a data final � >= � data inicial.
If lRet
    If dDataFim < dDataIni
        lRet := .F.
        Alert(STR0005) //"A data final deve ser maior ou igual � data inicial."
    EndIf
EndIf

Return lRet

