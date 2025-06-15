#INCLUDE "WMSA260.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA26001 "WMSA26001"
#DEFINE WMSA26002 "WMSA26002"

Static oBrowse  := Nil
Static lMarkAll := .F. // Indicador de marca/desmarca todos

//-------------------------------------
/*/{Protheus.doc} WMSA260
Exclusao de uma faixa de enderecos no SBE.
@author Alex Egydio
@since 12/06/2001
@version 2.0
/*/
//-------------------------------------
Function WMSA260()

	If Pergunte("DLA260", .T.)
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDescription(STR0001) // Exclusão de Endereços
		oBrowse:SetMenuDef("WMSA260")
		oBrowse:SetAlias("SBE")
		oBrowse:SetFieldMark("BE_OK")
		oBrowse:SetAllMark({||AllMark()})
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:Activate()
	EndIf

Return Nil

//-----------------------------------
/*{Protheus.doc} MenuDef
Função MenuDef

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "WMA260Proc" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-----------------------------------
/*{Protheus.doc} MontaQuery
Monta a expressão para filtro dos dados

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function MontaQuery()
Local cQuery := ""

	cQuery :=     " BE_FILIAL   = '"+xFilial("SBE")+"'"
	cQuery += " AND BE_LOCAL   >= '"+MV_PAR01+"'"
	cQuery += " AND BE_LOCAL   <= '"+MV_PAR02+"'"
	cQuery += " AND BE_CODZON  >= '"+MV_PAR03+"'"
	cQuery += " AND BE_CODZON  <= '"+MV_PAR04+"'"
	cQuery += " AND BE_ESTFIS  >= '"+MV_PAR05+"'"
	cQuery += " AND BE_ESTFIS  <= '"+MV_PAR06+"'"
	cQuery += " AND BE_LOCALIZ >= '"+MV_PAR07+"'"
	cQuery += " AND BE_LOCALIZ <= '"+MV_PAR08+"'"

Return cQuery

//-----------------------------------
/*{Protheus.doc} AllMark
Marca ou desmarca todos os registros

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function AllMark()
Local aAreaSBE := SBE->(GetArea())
Local cSpace   := Space(TamSX3("BE_OK")[1])

	lMarkAll := !lMarkAll

	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	SBE->(DbGoTop())

	While !SBE->(Eof())
		RecLock("SBE",.F.)
		SBE->BE_OK := Iif(lMarkAll,cSpace,oBrowse:cMark)
		SBE->(MsUnLock())
		SBE->(DbSkip())
	EndDo

RestArea(aAreaSBE)
oBrowse:Refresh()
Return Nil

//-----------------------------------
/*{Protheus.doc} WMA260Proc
Inicia o processo de exclusão dos endereços

@author  Alex Egydio
@version P12
@Since   12/06/2001
*/
//-----------------------------------
Function WMA260Proc( cAlias, nReg, nOpcx )
	Processa({|lEnd| WMA260Manut(,,@lEnd)},STR0001,STR0003,.T.) // Excluindo Enderecos
Return NIL

//-----------------------------------
/*{Protheus.doc} WMA260Manut
Executa os tratamentos de rotina padrão e rotina automática

@author  Alex Egydio
@version P12
@Since   12/06/2001
*/
//-----------------------------------
Function WMA260Manut(aRotAuto,xCompat,lEnd)
Local aAreaSBE   := SBE->(GetArea())
Local aAreaAnt   := GetArea()
Local l260Auto   := .F.
Local l260Erro   := .F.
Local nX         := 0
Local nY         := 0
Local cQuery     := ""
Local cAliasQry  := ""
Local nRegs      := 0

Default aRotAuto := {}
Default lEnd     := .F.

	// Execucao via Rotina Automatica
	If Len(aRotAuto) > 0
		l260Auto := .T.
	EndIf

	If l260Auto
		// Valida o Array da Rotina Automatica
		For nX := 1 To Len(aRotAuto)
			If  !(Len(aRotAuto[nX])==4)
				l260Erro := .T.
				Exit
			EndIf
			For nY := 1 To 4
				If  !(ValType(aRotAuto[nX,nY])=='C').Or.Empty(aRotAuto[nX,nY])
					l260Erro := .T.
					Exit
				EndIf
			Next nY
		Next nX

		If l260Erro
			WmsMessage(STR0007,WMSA26002,,,,STR0008) // Um ou mais campos obrigatórios não foram preenchidos. // Preencha os campos cujos títulos possuem o símbolo '*' (asterisco).
			Return
		EndIf

		For nX := 1 To Len(aRotAuto)
			DeletEnder(aRotAuto[nX,2],aRotAuto[nX,3],aRotAuto[nX,4],aRotAuto[nX,5],l260Auto)
		Next nX

	Else
		cQuery := "SELECT BE_LOCAL,"
		cQuery +=       " BE_LOCALIZ,"
		cQuery +=       " BE_ESTFIS,"
		cQuery +=       " SBE.R_E_C_N_O_ RECNOSBE"
		cQuery += " FROM "+RetSqlName("SBE")+" SBE"
		cQuery += " WHERE " + MontaQuery()
		cQuery +=   " AND SBE.BE_OK      = '"+oBrowse:cMark+"'"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			// Estabelece tamanho da régua de progressão
			(cAliasQry)->(DbEval({|| nRegs++ }))
			ProcRegua(nRegs)

			// Posiciona no início do cursor, por causa do DBEval
			(cAliasQry)->(DbGoTop())

			While !(cAliasQry)->(Eof())
				// Incremento da régua de progressão
				IncProc()

				// Tratamento do botão cancelar
				If lEnd
					Exit
				EndIf

				// Deleta o endereço
				If !DeletEnder((cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ,(cAliasQry)->BE_ESTFIS,(cAliasQry)->RECNOSBE,l260Auto)
					Exit
				EndIf

				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	oBrowse:Refresh()

RestArea(aAreaSBE)
RestArea(aAreaAnt)
Return Nil

//-----------------------------------
/*{Protheus.doc} DeletEnder
Efetua validação de saldo e exclusão dos endereços

@author  Squad WMS
@version P12
@Since   03/04/2019
*/
//-----------------------------------
Static Function DeletEnder(cArmazem,cEndereco,cEstFis,nRecnoSBE,l260Auto)
Local aAreaSBF := SBF->(GetArea())
Local aAreaD14 := D14->(GetArea())
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lSaldo   := .F.
Local nRet     := 0

		// Verifica se a saldo no endereco
		If lWmsNew
			D14->(DbSetOrder(4)) // D14_FILIAL+D14_LOCAL+D14_ESTFIS+D14_ENDER
			If D14->(DbSeek(xFilial("D14")+cArmazem+cEstFis+cEndereco))
				lSaldo := .T.
			EndIf
		Else
			SBF->(DbSetOrder(6)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_ESTFIS
			If SBF->(DbSeek(xFilial("SBF")+cArmazem+cEndereco+cEstFis)) .And. SBFSaldo(,,,,.T.) > 0
				lSaldo := .T.
			EndIf
		EndIf

		If lSaldo
			If !l260Auto
				nRet := WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco},{"[VAR03]",cEstFis}}),WMSA26001,10,,{STR0005,STR0006}) // Existe saldo em estoque no armazém/endereço/estrutura [VAR01]/[VAR02]/[VAR03]. Este endereço não será excluído. // Continuar // Cancelar
				If nRet == 2 // Cancelar
					Return .F.
				EndIf
			Else
				nRet := 1
			EndIf
		Else
			nRet := 0
		EndIf

		// Exclui os Enderecos Selecionados
		If nRet == 0
			// Posiciona no registro correspondente
			SBE->(DbGoto(nRecnoSBE))
			If !SBE->(Eof())
				RecLock("SBE",.F.)
				SBE->(DbDelete())
				SBE->(MsUnLock())
			EndIf
		EndIf

RestArea(aAreaSBF)
RestArea(aAreaD14)
Return .T.
