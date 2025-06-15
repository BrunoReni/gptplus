#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

/*/{Protheus.doc} MrpDominio_Fantasma
Regras de neg�cio MRP - Produtos Fantasmas

@author    lucas.franca
@since     09/05/2019
@version   1
/*/
CLASS MrpDominio_Fantasma FROM LongClassName

	DATA oDominio AS Object //inst�ncia da camada de dom�nio
	DATA oDados   AS Object //inst�ncia da camada de dados
	DATA oLogs    AS Object //inst�ncia da camada de dados

	METHOD new(oDominio) CONSTRUCTOR
	METHOD processaFantasma(cFilAux, cProduto, cComponent, nNecComp, nPeriodo, cIDOpcCmp, aBaixaPorOP, cList, oRastrPais, cCodPai, lExplodiu, dLTReal, cCodPrPais)

ENDCLASS

/*/{Protheus.doc} new
M�todo construtor

@author    lucas.franca
@since     09/05/2019
@version   1
@param 01 - oDominio, Object, objeto da camada de dom�nio
@param 02 - oDados  , Object, objeto da camada de dados
/*/
METHOD new(oDominio) CLASS MrpDominio_Fantasma
	::oDominio := oDominio
	::oDados   := ::oDominio:oDados
	::oLogs    := ::oDominio:oLogs
Return Self

/*/{Protheus.doc} processaFantasma
Faz o processamento da explos�o de estrutura do produto fantasma.

@author    lucas.franca
@since     09/05/2019
@version   1
@param 01 - cFilAux   , caracter, c�digo da filial para processamento
@param 02 - cProduto  , Caracter, C�digo do produto pai da estrutura
@param 03 - cComponent, Caracter, C�digo do componente na estrutura
@param 04 - nNecComp  , Num�rico, Quantidade da necessidade do produto fantasma.
@param 05 - nPeriodo  , Num�rico, Per�odo do MRP onde existe a necessidade do produto fantasma.
@param 06 - cIDOpcCmp , caracter, ID opcional do componente
@param 07 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substitui��o},...}
@param 08 - cList     , caracter, chave produto + chr(13) + per�odo referente chaves da aBaixaPorOP
@param 09 - oRastrPais, objeto  , objeto Json para controle/otimiza��o das altera��es de rastreabilidade no regitro Pai durante explos�o na estrutura
@param 10 - cCodPai   , caracter, C�digo do produto pai do fantasma em processamento
@param 11 - lExplodiu , logico  , Vari�vel de controle utilizada para identificar se explodiu a necessidade para algum componente. Uso interno e com recursividade (explodirEstrutura).
@param 12 - dLTReal    , date   , data real de in�cio ap�s aplicado o leadtime, sem reajustar aos per�odos do MRP
@param 13 - cCodPrPais , caracter, controle de recursividade - registra a cadeia de produtos que iniciaram a explos�o de forma recursiva (fantasmas)
@return Nil
/*/
METHOD processaFantasma(cFilAux   , cProduto, cComponent, nNecComp, nPeriodo  , cIDOpcCmp, aBaixaPorOP, cList,;
                        oRastrPais, cCodPai , lExplodiu , dLTReal , cCodPrPais) CLASS MrpDominio_Fantasma
	Local nIndex     := 0
	Local nIndQbr    := 0
	Local nPosQtd    := 0
	Local nPosSub    := 0
	Local nPosQbr    := 0
	Local nTotal     := 0
	Local nTotalX    := 0
	Local nTotOPs    := 0
	Local nPerLead   := Nil
	Local dDataLead  := Nil
	Local dLTRealFan := Nil

	Default cList   := cProduto + chr(13) + cValToChar(nPeriodo)

	//Gera o LOG de recursividade de produtos fantasmas.
	::oLogs:log(STR0079 + AllTrim(cProduto)   + "| " + ; //"Chamada recursiva de produto fantasma. Produto PAI: "
	            STR0080 + AllTrim(cComponent) + "| " + ; //"Produto FANTASMA: "
				STR0081 + cValToChar(nNecComp)+ "| " + ; //"Quantidade calculada do produto FANTASMA: "
				STR0082 + cValToChar(nPeriodo) , "28")   //"Per�odo: "

	//Atualiza quantidade Pai no controle de rastreabilidade
	If aBaixaPorOP != Nil
		nTotal  := Len(aBaixaPorOP)
		nPosQtd := ::oDominio:oRastreio:getPosicao("ABAIXA_POS_QTD_PAI")
		nPosSub := ::oDominio:oRastreio:getPosicao("ABAIXA_POS_QTD_SUBSTITUICAO")
		nPosQbr := ::oDominio:oRastreio:getPosicao("ABAIXA_POS_QUEBRAS_QUANTIDADE")
		For nIndex := 1 to nTotal
			nTotOPs += aBaixaPorOP[nIndex][nPosQtd] - aBaixaPorOP[nIndex][nPosSub]
		Next

		For nIndex := 1 to nTotal
			aBaixaPorOP[nIndex][nPosQtd] := (aBaixaPorOP[nIndex][nPosQtd] * nNecComp) / nTotOPs

			//Ajusta totaliza��o das quebras
			If nPosQbr <= Len(aBaixaPorOP[nIndex]) .AND. aBaixaPorOP[nIndex][nPosQbr] != Nil
				nTotalX := Len(aBaixaPorOP[nIndex][nPosQbr])
				For nIndQbr := 1 to nTotalX
					aBaixaPorOP[nIndex][nPosQbr][nIndQbr][1] := (aBaixaPorOP[nIndex][nPosQbr][nIndQbr][1] * nNecComp) / nTotOPs
				Next
			EndIf
		Next
	EndIf

	//Calcula LeadTime
	nPerLead  := nPeriodo
	dDataLead := ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
	::oDominio:oLeadTime:aplicar(cFilAux, cFilAux + cComponent, @nPerLead, @dDataLead, , , @dLTRealFan)  //Aplica o Lead Time do produto
	dLTReal := Min(dLTReal, dLTRealFan)
	
	//Explode a estrutura do produto fantasma de forma recursiva.
	cCodPrPais += RTrim(cComponent) + "|"
	::oDominio:explodirEstrutura(cFilAux, cComponent, nNecComp, nPerLead, nPeriodo, cCodPai, cIDOpcCmp, aBaixaPorOP, , , , cList, @oRastrPais, , @lExplodiu, dLTReal, cCodPrPais)

Return Nil