#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDominio.ch'

Static snPosCdCmp
Static snPosCdPai
Static snPosDTIni
Static snPosDTFim
Static snPosFixa
Static snPosQtdBP
Static snPosQtdCm
Static snPosQtdPE
Static snPosFanta

/*/{Protheus.doc} MrpDominio_Subproduto
Regras de Negocio - Processamento de Subproduto
@author    brunno.costa
@since     24/03/2020
@version   12
/*/
CLASS MrpDominio_Subproduto FROM LongClassName

	//Declaracao de propriedades da classe
	DATA oDominio  AS OBJECT   //Instancia da camada de dominio

	METHOD new() CONSTRUCTOR
	METHOD calculaNecessidadePai(nQtdComp, nQtdBPai, aItemEstru)
	METHOD geraNecessidadePai(cFilAux, cComponente, aItemEstru, nPeriodo, nQtd)
	METHOD preparaStatics()
	METHOD processar(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd)
	METHOD retornaPaiValido(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd)
	METHOD recursaoFantasma(cFilAux, aItemEstru, nPeriodo, nQtd, lInvalido)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - oDominio, objeto, instancia da classe de dom�nio do MRP
@return SELF - esta classe.
/*/
METHOD new(oDominio) CLASS MrpDominio_Subproduto
	Self:oDominio := oDominio

	//Prepara Var��veis Statics
	Self:preparaStatics()

Return Self
  
/*/{Protheus.doc} processar
Identifica Produto Pai v�lido para esta condi��o de subproduto
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cComponente, caracter, c�digo do componente subproduto
@param 03 - cIDOpc     , caracter, c�digo do IDOpcional do subproduto
@param 04 - nPeriodo   , n�mero  , per�odo da necessidade do subproduto
@param 05 - nQtd       , n�mero  , quantidade da necessidade do subproduto
@return lProcessado, l�gico, indica se houve execu��o v�lida de SubProduto gerando necessidade de produ��o de um produto Pai
/*/
METHOD processar(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd) CLASS MrpDominio_Subproduto
	Local lProcessado := .F.
	Local aItemEstru  := Self:retornaPaiValido(cFilAux, cComponente, cIDOpc, nPeriodo, @nQtd)

	If Empty(aItemEstru)
		lProcessado := .F.
	Else
		lProcessado := Self:geraNecessidadePai(cFilAux, cComponente, aItemEstru, nPeriodo, nQtd)
	EndIf

Return lProcessado

/*/{Protheus.doc} retornaPaiValido
Retorna Array da Estrutura Referente Pai V�lido do SubProduto
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cComponente, caracter, c�digo do componente subproduto
@param 03 - cIDOpc     , caracter, c�digo do IDOpcional do subproduto
@param 04 - nPeriodo   , n�mero  , per�odo da necessidade do subproduto
@param 05 - nQtd       , n�mero  , quantidade da necessidade do subproduto
@return aItemEstru, array, array com os dados da estrutura referente Pai V�lido do SubProduto
/*/
METHOD retornaPaiValido(cFilAux, cComponente, cIDOpc, nPeriodo, nQtd) CLASS MrpDominio_Subproduto
	Local aItemEstru := {}
	Local aPaisEstru := {}
	Local cChaveSP   := cComponente
	Local cProduto
	Local dDataNec
	Local lInvalido  := .F.
	Local nInd       := 0
	Local nTotal     := 0
	Local oSubProdutos := Self:oDominio:oDados:oSubProdutos

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		cChaveSP := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilAux) + cComponente
	EndIf

	oSubProdutos:getRow(1, cChaveSP, Nil, @aPaisEstru)
	If aPaisEstru != Nil .AND. !Empty(aPaisEstru)
		dDataNec := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
		nTotal   := Len(aPaisEstru)
		For nInd := 1 to nTotal
			cProduto := aPaisEstru[nInd][snPosCdPai]
			If aPaisEstru[nInd][snPosDTIni] <= dDataNec .And. ;
			   dDataNec <= aPaisEstru[nInd][snPosDTFim] .And. ;
			   Self:oDominio:oSeletivos:consideraProduto(cFilAux, cProduto)

				aItemEstru := Self:recursaoFantasma(cFilAux, aPaisEstru[nInd], nPeriodo, @nQtd, @lInvalido)
				If lInvalido
					aSize(aItemEstru, 0)
				Else
					Exit
				EndIf
			EndIf
		Next
	EndIf

Return aItemEstru

/*/{Protheus.doc} recursaoFantasma
Avalia necessidade de recurs�o da estrutura devido ocorr�ncia de produto Pai Fantasma
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cComponente, caracter, c�digo do componente subproduto
@param 02 - cIDOpc     , caracter, c�digo do IDOpcional do subproduto
@param 03 - nPeriodo   , n�mero  , per�odo da necessidade do subproduto
@param 04 - nQtd       , n�mero  , quantidade da necessidade do subproduto
@return aItemEstru, array, array com os dados da estrutura referente Pai V�lido do SubProduto
/*/
METHOD recursaoFantasma(cFilAux, aItemEstru, nPeriodo, nQtd, lInvalido) CLASS MrpDominio_Subproduto

	Local aItemPai
	Local aItemAvo
	Local cFantasma := aItemEstru[snPosCdPai]
	Local nQtdPai   := Self:calculaNecessidadePai(nQtd, aItemEstru)
	Local nQtdAvo

	aItemPai := Self:retornaPaiValido(cFilAux, cFantasma, /*cIDOpc*/, nPeriodo, @nQtdPai)

	If aItemPai != Nil .AND. !Empty(aItemPai) .AND. aItemPai[snPosFanta] //Produto Pai Fantasma
		nQtdAvo  := Self:calculaNecessidadePai(nQtdPai, aItemPai)
		aItemAvo := Self:retornaPaiValido(cFilAux, cFantasma, /*cIDOpc*/, nPeriodo, @nQtdAvo)
		If aItemAvo == Nil .or. Empty(aItemAvo)
			lInvalido  := .T.
		Else
			aItemEstru := aItemAvo
			nQtd       := nQtdAvo
		EndIf
	EndIf

Return aItemEstru

/*/{Protheus.doc} geraNecessidadePai
Gera necessidade do produto Pai para atender este subproduto
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cComponente, caracter, c�digo do componente subproduto
@param 03 - aItemEstru , array   , array com os dados da estrutura referente Pai V�lido do SubProduto
@param 04 - nPeriodo   , n�mero  , per�odo da necessidade do subproduto
@param 05 - nQtd       , n�mero  , quantidade da necessidade do subproduto
@return lProcessado, l�gico, indica se houve execu��o v�lida de SubProduto gerando necessidade de produ��o de um produto Pai
/*/
METHOD geraNecessidadePai(cFilAux, cComponente, aItemEstru, nPeriodo, nQtd) CLASS MrpDominio_Subproduto
	Local lProcessado := .F.
	Local cProduto    := aItemEstru[snPosCdPai]
	Local dDataNec
	Local nNecPai     := Self:calculaNecessidadePai(nQtd, aItemEstru)
	If nNecPai > 0
		dDataNec := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
		Self:oDominio:oRastreio:incluiNecessidade(cFilAux, "SUBPRD", cComponente, cProduto, /*cIDOpc*/, /*cTRT*/, nNecPai, nPeriodo, /*cListOrig*/, /*cRegra*/, /*cOrdSubst*/)
		Self:oDominio:oDados:atualizaMatriz(cFilAux, dDataNec, cProduto, /*cIDOpc*/, {"MAT_SAIPRE"}, {nNecPai}, cProduto)
		Self:oDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
		Self:oDOminio:oDados:gravaPeriodosProd(cFilAux + cProduto, nPeriodo, -1, (nPeriodo - 1))
		lProcessado := .T.
	EndIf
Return lProcessado

/*/{Protheus.doc} calculaNecessidadePai
Calcula a quantidade da necessidade correspondente ao produto Pai
@author    brunno.costa
@since     24/03/2020
@version   12.1.30
@param 01 - nQTdComp  , n�mero, necessidade do componente
@param 02 - aItemEstru, array , array com os dados da estrutura referente Pai V�lido do SubProduto
@return nNecPai, n�mero, quantidade de necessidade correspondente do produto Pai
/*/
METHOD calculaNecessidadePai(nQtdComp, aItemEstru) CLASS MrpDominio_Subproduto
	Local nQtdBPai   := aItemEstru[snPosQtdBP]
	Local nQtdCmpEst := aItemEstru[snPosQtdCm]
	Local nQtdPerda  := aItemEstru[snPosQtdPE]
	Local lFixa      := aItemEstru[snPosFixa] == "1"
	Local nNecPai    := nQtdComp

	nNecPai := Abs(((If(nQtdBPai <= 0, 1, nQtdBPai) / nQtdCmpEst) * (100 - nQtdPerda)) / 100)
	nNecPai := nQtdComp * nNecPai

	IF lFixa
		nNecPai := Int(nNecPai) + If(((nNecPai - Int(nNecPai)) > 0), 1, 0)
	EndIf

Return nNecPai

/*/{Protheus.doc} preparaStatics
Prepara Vari�veis Statics
@author    brunno.costa
@since     25/03/2020
@version   12.1.30
/*/
METHOD preparaStatics() CLASS MrpDominio_Subproduto
	If snPosDTIni == Nil
		snPosDTIni := Self:oDominio:oDados:posicaoCampo("EST_VLDINI")
		snPosDTFim := Self:oDominio:oDados:posicaoCampo("EST_VLDFIM")
		snPosQtdBP := Self:oDominio:oDados:posicaoCampo("EST_QTDB")
		snPosQtdCm := Self:oDominio:oDados:posicaoCampo("EST_QTD")
		snPosQtdPE := Self:oDominio:oDados:posicaoCampo("EST_PERDA")
		snPosCdPai := Self:oDominio:oDados:posicaoCampo("EST_CODPAI")
		snPosCdCmp := Self:oDominio:oDados:posicaoCampo("EST_CODFIL")
		snPosFixa  := Self:oDominio:oDados:posicaoCampo("EST_FIXA")
		snPosFanta := Self:oDominio:oDados:posicaoCampo("EST_FANT")
	EndIf
Return
