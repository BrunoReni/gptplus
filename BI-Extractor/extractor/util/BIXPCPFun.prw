#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCostStd
Responsável por Retorna a composicao do custo padrao do item, seja ele comprado ou fabricado.

@author  Equipe Materiais (Andre Anjos)
@version P11
@since   23/10/2012
@param nTipo, parâmetros necessário à execução deste extrator
	nTipo 1 -> Custo Padrão
	nTipo 2 -> Custo Médio
@param nIndica, parâmetros necessário à execução deste extrator
	nIndica 1 -> Custo total (custo material + custo MOD)
	nIndica 2 -> Custo material
	nIndica 3 -> Custo MOD
@param cProduto, código do produto
@param dDataRef, data de referência para explosão da estrutura.
@param nRot, 1 se houver roteiro de produção
@param cMoeda, código da moeda
@return Custo solicitado
/*/
//-------------------------------------------------------------------

Function RetCostStd(nTipo, nIndica, cProduto, dDataRef, nRot, cMoeda)

Local   aAreaSB1  := {}
Local   aAreaSB2  := {}
Local   aAreaSG1  := {}
Local   nRet      := 0
Local   nQtd      := 0
Local   cOpc      := ""
Local   cRev      := ""
Local   cRot      := ""
Private cTipoTemp := SuperGetMV("MV_TPHR",.F.,"C")
Private nPrecisao := SuperGetMV("MV_PRECISA",.F.,4)

DEFAULT cMoeda    := "1"
DEFAULT dDataRef  := dDataBase
DEFAULT nRot      := 0

aAreaSB1 := SB1->(GetArea())
aAreaSB2 := SB2->(GetArea())
aAreaSG1 := SG1->(GetArea())

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + cProduto))

cOpc := SB1->B1_OPC
cRev := SB1->B1_REVATU

If nRot == 1
	cRot := If(Empty(SB1->B1_OPERPAD), "01", SB1->B1_OPERPAD)
	nRet := RetCostRoteiro(nTipo, cProduto, cRot)[1]
EndIf

SB2->(dbSetOrder(1))
SB2->(dbSeek(xFilial("SB2")+SB1->(SB1->B1_COD + SB1->B1_LOCPAD)))

SG1->(dbSetOrder(1))
If !SG1->(dbSeek(xFilial("SG1") + cProduto)) // Caso nao possua estrutura o custo e do proprio produto, quando total ou material
	If nIndica == 1 .Or. (nIndica == 2 .And. !IsProdMOD(cProduto)) .Or. (nIndica == 3 .And. IsProdMOD(cProduto))
		nRet += If(nTipo == 1, RetFldProd(SB1->B1_COD, "B1_CUSTD"), &("SB2->B2_CM" + cMoeda))
	EndIf
Else
	// Se possui estrutura, processa a soma do custo dos itens
	While !SG1->(EOF()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1") + cProduto
		SB1->(dbSeek(xFilial("SB1") + SG1->G1_COMP))
		
		// Posiciona SB2 para pegar custo medio
		SB2->(dbSeek(xFilial("SB2") + SB1->(B1_COD + B1_LOCPAD)))
		
		nQtd := ExplEstr(1, dDataRef, cOpc, cRev)
		
		// Se item nao usado ou MOD e nao considera MOD, pula
		If (QtdComp(nQtd) == QtdComp(0)) .Or. (nIndica == 2 .And. IsProdMod(SB1->B1_COD))
			SG1->(dbSkip())
			Loop
		EndIf
		
		// Acumula custo do item
		nRet += (nQtd * If(nTipo == 1, RetFldProd(SB1->B1_COD, "B1_CUSTD"), &("SB2->B2_CM" + cMoeda)))
		
		SG1->(dbSkip())
	End
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aAreaSG1)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCostRoteiro
Responsável por Retorna a composicao do custo padrao do item, seja ele comprado ou fabricado.

@author  Equipe Materiais (Andre Anjos)
@version P11
@since   23/10/2012
@param nTipo, parâmetros necessário à execução deste extrator
	nTipo 1 -> Custo Padrão
	nTipo 2 -> Custo Médio
@param cProduto, código do produto
@param cRot, código do roteiro de produção
@param cMoeda, código da moeda
@return Custo solicitado
/*/
//-------------------------------------------------------------------

Function RetCostRoteiro(nTipo, cProduto, cRot, cMoeda)

Local   aAreaSB1  := {}
Local   aAreaSB2  := {}
Local   aAreaSG2  := {}
Local   aAreaSH1  := {}
Local   nCusto    := 0
Local   nRet      := 0
Local   nQtdeAux  := 0
Local   nHrsOper  := 0
Local   nHrTotal  := 0
Private cTipoTemp := SuperGetMV("MV_TPHR",.F.,"C")
Private nPrecisao := SuperGetMV("MV_PRECISA",.F.,4)
DEFAULT cMoeda    := "1"

aAreaSB1 := SB1->(GetArea())
aAreaSB2 := SB2->(GetArea())
aAreaSG2 := SG2->(GetArea())
aAreaSH1 := SH1->(GetArea())

// Busca MOD's relacionadas ao roteiro de operacao
SH1->(dbSetOrder(1))
SG2->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SG2->(dbSeek(xFilial("SG2") + cProduto + cRot))

While !SG2->(EOF()) .And. SG2->(G2_FILIAL + G2_PRODUTO + G2_CODIGO) == xFilial("SG2") + cProduto + cRot
	
	// Valida recurso e posiciona no cadastro da MOD
	If SH1->(dbSeek(xFilial("SH1") + SG2->G2_RECURSO)) .And. SB1->(dbSeek(xFilial("SB1") + APrModRec(SG2->G2_RECURSO)))
		
		// Posiciona SB2 para pegar custo medio
		SB2->(dbSeek(xFilial("SB2") + SB1->(B1_COD + B1_LOCPAD)))
		
		// Obtem custo da MOD
		nCusto := If(nTipo == 1, RetFldProd(SB1->B1_COD, "B1_CUSTD"), &("SB2->B2_CM" + cMoeda))
		
		// Calcula tempo de duracao baseado no tipo de operacao
		If SG2->G2_TPOPER $ " 1"
			nHrsOper := Round(1 * (If(Empty(A690HoraCt(SG2->G2_TEMPAD)), 1, A690HoraCt(SG2->G2_TEMPAD)) / If(Empty(SG2->G2_LOTEPAD), 1, SG2->G2_LOTEPAD)), 5)
			
			If SH1->H1_MAOOBRA # 0
				nHrsOper := Round(nHrsOper / SH1->H1_MAOOBRA, 5)
			EndIf
			
		ElseIf SG2->G2_TPOPER == "4"
			nQtdeAux := 1 % If(Empty(SG2->G2_LOTEPAD), 1, SG2->G2_LOTEPAD)
			nQtdeAux := 1 + If(nQtdeAux > 0,If(Empty(SG2->G2_LOTEPAD), 1, SG2->G2_LOTEPAD) - nQtdeAux, 0)
			nHrsOper := Round(nQtdeAux * (If(Empty(A690HoraCt(SG2->G2_TEMPAD)), 1, A690HoraCt(SG2->G2_TEMPAD)) / If(Empty(SG2->G2_LOTEPAD), 1, SG2->G2_LOTEPAD)), 5)
			
			If SH1->H1_MAOOBRA # 0
				nHrsOper := Round(nHrsOper / SH1->H1_MAOOBRA, 5)
			EndIf
			
		ElseIf SG2->G2_TPOPER == "2" .Or. SG2->G2_TPOPER == "3"
			nHrsOper := If(Empty(A690HoraCt(SG2->G2_TEMPAD)), 1 ,A690HoraCt(SG2->G2_TEMPAD))
		EndIf
		
		nHrsOper += A690HoraCt(If(Empty(SG2->G2_FORMSTP), SG2->G2_SETUP, Formula(SG2->G2_FORMSTP)))	// Soma setup
		nHrsOper += A690HoraCt(If(SG2->(FieldPos("G2_TEMPEND"))>0, SG2->G2_TEMPEND, 0))				// Soma tempo fim da operacao
		
		nRet += nCusto * nHrsOper
		nHrTotal += nHrsOper
	EndIf
	SG2->(dbSkip())
End

RestArea(aAreaSB1)
RestArea(aAreaSB2)
RestArea(aAreaSG2)
RestArea(aAreaSH1)

Return {nRet, nHrTotal} // Custo total e valor das horas