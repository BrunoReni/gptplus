#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE ABAIXA_POS_CHAVE                  1
#DEFINE ABAIXA_POS_DOCPAI                 2
#DEFINE ABAIXA_POS_NECESSIDADE            3
#DEFINE ABAIXA_POS_QTD_ESTOQUE            4
#DEFINE ABAIXA_POS_CONSUMO_ESTOQUE        5
#DEFINE ABAIXA_POS_QTD_SUBSTITUICAO       6
#DEFINE ABAIXA_POS_QUEBRAS_QUANTIDADE     7
#DEFINE ABAIXA_POS_TIPO_PAI               8
#DEFINE ABAIXA_POS_NEC_ORIG               9
#DEFINE ABAIXA_POS_REGRA_ALT             10
#DEFINE ABAIXA_POS_CHAVE_SUBST           11
#DEFINE ABAIXA_POS_TRANSFERENCIA_ENTRADA 12
#DEFINE ABAIXA_POS_TRANSFERENCIA_SAIDA   13
#DEFINE ABAIXA_POS_DOCFILHO              14
#DEFINE ABAIXA_POS_RASTRO_AGLUTINACAO    15
#DEFINE ABAIXA_POS_DOC_AGLUTINADOR       16
#DEFINE ABAIXA_SIZE                      16

#DEFINE ADADOS_POS_TIPOPAI                 1
#DEFINE ADADOS_POS_DOCPAI                  2
#DEFINE ADADOS_POS_DOCFILHO                3
#DEFINE ADADOS_POS_COMPONENTE              4
#DEFINE ADADOS_POS_PERIODO                 5
#DEFINE ADADOS_POS_TRT                     6
#DEFINE ADADOS_POS_QTD_ESTOQUE             7
#DEFINE ADADOS_POS_CONSUMO_ESTOQUE         8
#DEFINE ADADOS_POS_NEC_ORIGINAL            9
#DEFINE ADADOS_POS_NECESSIDADE             10
#DEFINE ADADOS_POS_QTD_SUBSTITUICAO        11
#DEFINE ADADOS_POS_CONSUMO_SUBSTITU        12
#DEFINE ADADOS_POS_QTD_SUBST_ORIGINAL      13 //Quantidade de substitui��o convertida no fator do produto original
#DEFINE ADADOS_POS_CHAVE_SUBSTITUICAO      14
#DEFINE ADADOS_POS_REGRA_ALTERNATIVO       15
#DEFINE ADADOS_POS_SUBST_ORDEM             16
#DEFINE ADADOS_POS_REVISAO                 17
#DEFINE ADADOS_POS_ROTEIRO                 18 //ROTEIRO DO PRODUTO PAI
#DEFINE ADADOS_POS_OPERACAO                19 //OPERA��O DO PRODUTO ATUAL NO ROTEIRO DO PRODUTO PAI
#DEFINE ADADOS_POS_ROTEIRO_DOCUMENTO_FILHO 20 //ROTEIRO DO PRODUTO ATUAL NO DOCUMENTO FILHO
#DEFINE ADADOS_POS_LOCAL                   21
#DEFINE ADADOS_POS_QUEBRAS_QUANTIDADE      22
#DEFINE ADADOS_POS_COMP_EXPL_ESTRUT        23
#DEFINE ADADOS_POS_ID_OPCIONAL             24
#DEFINE ADADOS_POS_VERSAO_PRODUCAO         25
#DEFINE ADADOS_POS_FILIAL                  26
#DEFINE ADADOS_POS_TRANSFERENCIA_ENTRADA   27
#DEFINE ADADOS_POS_TRANSFERENCIA_SAIDA     28
#DEFINE ADADOS_POS_RASTRO_AGLUTINACAO      29
#DEFINE ADADOS_POS_DOC_AGLUTINADOR         30
#DEFINE ADADOS_POS_ALTERNATIVOS            31
#DEFINE ADADOS_SIZE                        31

#DEFINE AINDICE3_POS_ID              1
#DEFINE AINDICE3_POS_IND2            2
#DEFINE AINDICE3_POS_IND3            3

Static snTamCod      := 90
Static slLog7        := Nil
Static slLogR1       := Nil
Static slLogR2       := Nil
Static slLogR3       := Nil
Static slLogR4       := Nil
Static slLogR6       := Nil
Static slLogR7       := Nil
Static slLogR8       := Nil
Static slLogR9       := Nil
Static slLogRS       := Nil

Static scTextESeg    := STR0143
Static scTextPPed    := STR0144

/*/{Protheus.doc} MrpDominio_Rastreio
Classe de controle do rastreio de OP's
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio_Rastreio FROM LongClassName

	DATA oDados          AS Object //Instancia da classe de dados do MRP
	DATA oDados_Rastreio AS Object //Inst�ncia da classe Global_Data de rastreabilidade
	DATA oParametros     AS Object //Instancia do objeto JSON de par�metros
	DATA oAlternativo    AS Object //Instancia da classe de dom�nio de alternativos - Matriz
	DATA nIOpeRotei      AS NUMERIC
	DATA nIOpeOpera      AS NUMERIC

	//M�todos P�blicos
	METHOD adicionaLoteVencido(aDocumento, aLotes)
	METHOD atualizaSubstituicao(cFilAux, cComponente, nPeriodo, aBaixaPorOP, lAltReg1, lNecBxaOp, nTotalSubs, lTranAlt)
	METHOD atualizaRastreio(cFilAux, cChaveProd, nPeriodo, aBaixaPorOP, aIndexAtu, cProduto)
	METHOD baixaPorOP(cFilAux, cComponente, nEstoque, nPeriodo, lAltReg1, nSaidas, nSldIni)
	METHOD desfazExplosoes(cFilAux, cComponente, nPeriodo, cChvCheck, cPrdLoop)
	METHOD desfazSubstituicoes(cFilAux, cProduto, nPeriodo, aBaixaPorOP, nConsumo)
	METHOD destruir()
	METHOD getPosicao(cCampo)
	METHOD incluiNecessidade(cFilAux, cTipoPai, cDocPai, cComponente, cIDOpc, cTRT, nQuantidade, nPeriodo, cListOrig, cRegra, cOrdSubst, cRoteiro, cOperacao, nQtrEnt, nQtrSai, cDocFilho, nSaldo, lSubsTran)
	METHOD inclusoesNecessidade(cFilAux, aBaixaPorOP, cComponente, cIDOpc, cTRT, nQuantidade, nPeriodo, cRegra, nQtdSEst, cRevisao, cRoteiro, cLocal, oRastrPais, lQtdFixa, nFPotencia, nFatPerda, cCodPai, cVersao, lFantasma, aOperacoes, dLeadTime, nQtdBase)
	METHOD montaBaixaPorOP(cChave, cDocPai, nNecess, nQtdEst, nConsumo, nSubstitui, aQuebras, cTipoPai, nNecOrigem, cRegraAlt, cChaveSub, nQtrEnt, nQtrSai, cDocFilho, aRastroAgl)
	METHOD necPPed_ES(cFilAux, cProduto, nPeriodo)
	METHOD ordenaRastreio(aRastreio, lContador)
	METHOD registraLoteVencido(cFilAux, cProduto, cIdOpc, nPeriodo, nDescontou, nSldIni, aLotes)
	METHOD retornaRastreio(cFilAux, cProduto, nPeriodo, cDocPai, cTRT, cListOrig)
	METHOD retornaAlternativos(cProduto, nPeriodo, lTranAlt)
	METHOD new() CONSTRUCTOR

	//Outros internos
	METHOD avaliaSubstOriginal(cFilAux, aAlternati, nEstoque, nSubstAlt, oSldSubst, lForcaOrig, aBaixaPorOP, lAltReg1)
	METHOD deletaRastreios(cFilAux, cList, cChave, nPeriodo, aComponentes, cTipoPai, cProdPai, cDocPai, lRecursiva, cChvCheck, lEfetiva, cPrdLoop)
	METHOD politicaDeEstoque(cFilAux, cProduto, nPeriodo, nEstoque, nSaidas, nSldIni, cIdOpc)
	METHOD todosAltConsumidos(cFilAux, cProdOri, cExcecao, nPeriodo, cPrimeiro)
	METHOD forcaSubstituicaoAlternativo(cFilAux, cProdOri, nPeriodo, nQtdOrig, nQtdAlt, aOriginal, cAlternativo, nSubstOrig, nSubstAlt, nSubstIni)
	METHOD forcaRecalculoOriginal(cFilAux, cProduto, nSaldo, nPeriodo, cAlternativo, aBaixaPorOP)
	METHOD retornaOperacao(cRoteiro, aOperacoes)
	METHOD getChaveEstSeg(cProduto, nPeriodo, lCompleta)

ENDCLASS

/*/{Protheus.doc} MrpDominio_Rastreio
M�todo construtor da classe MrpDominio_Rastreio
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - lCreate, l�gico, indica se deve criar a sess�o global de dados
@param 02 - oDados , objeto, instancia da camada de dados do MRP
@return, Self, objeto, instancia desta classe
/*/
METHOD new(oDados) CLASS MrpDominio_Rastreio

	Self:oDados          := oDados
	Self:oDados_Rastreio := oDados:oRastreio
	Self:oParametros     := oDados:oParametros
	Self:oAlternativo    := oDados:oDominio:oAlternativo
	Self:nIOpeRotei      := oDados:posicaoCampo("OPE_ROTE")
    Self:nIOpeOpera      := oDados:posicaoCampo("OPE_OPERA")

Return Self

/*/{Protheus.doc} inclusoesNecessidade
Inclui Rastreio da Necessidade Original referente Rastreabilidade Precessora
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux   , caracter, c�digo da filial para processamento
@param 02 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
							   {{1 - Id Rastreabilidade,;
							     2 - Documento Pai,;
							     3 - Quantidade Necessidade,;
							     4 - Quantidade Estoque,;
							     5 - Quantidade Baixa Estoque,;
							     6 - Quantidade Substitui��o
								 7 - ID Registro Substitu�do
								 8 - Tipo do Documento Pai},...}
@param 03 - cComponente, caracter, c�digo do componente a ser utilizado na inclus�o de necessidade
@param 04 - cIDOpc     , caracter, c�digo do ID do opcional
@param 05 - cTRT       , caracter, c�digo do TRT a ser utilizado na inclus�o de necessidade
@param 06 - nQuantidade, n�mero  , quantidade refer�ncia para inclus�o das necessidades
@param 07 - nPeriodo   , n�mero  , per�odo refer�ncia para inclus�o das necessidades
@param 08 - cRegra     , caracter,  regra de consumo dos alternativos:
								1- Valida Original; Valida Alternativo; Compra Original
								2- Valida Original; Valida Alternativo; Compra Alternativo
								3- Valida Alternativo; Compra Alternativo
@param 09 - nQtdSEst   , n�mero  , retorna a quantidade total do componente, considerando os arredondamentos.
@param 10 - cRevisao   , caracter, revis�o do produto Pai
@param 11 - cRoteiro   , caracter, roteiro de produ��o do produto Pai
@param 12 - cLocal    , caracter, local de consumo padr�o
@param 13 - oRastrPais, objeto  , objeto Json para controle/otimiza��o das altera��es de rastreabilidade no regitro Pai durante explos�o na estrutura
@param 14 - lQtdFixa  , l�gico, indica se o componente possui quantidade fixa ou n�o, caso .T., n�o executa multiplica��o da quantidade do componente pela qtd do pai
@param 15 - nFPotencia, num�rico, indica o fator de pot�ncia do componente, fator que age sobre a necessidade de cada componente
@param 16 - nFatPerda , num�rico, indica o fator de perda do componente
@param 17 - cCodPai   , caracter, c�digo do produto pai
@param 18 - cVersao   , caracter, c�digo da vers�o da produ��o
@param 19 - lFantasma , l�gico  , indica se � inclus�o relacionada a produto fantasma
@param 20 - aOperacoes, array   , opera��es existentes relacionadas a este componente
@param 21 - dLeadTime , data    , data lead time do componente utilizado no evento 004
@param 22 - nQtdBase  , num�rico, quantidade base da estrutura
@return Nil
/*/
METHOD inclusoesNecessidade(cFilAux, aBaixaPorOP, cComponente, cIDOpc, cTRT, nQuantidade, nPeriodo, ;
                            cRegra, nQtdSEst, cRevisao, cRoteiro, cLocal, oRastrPais, lQtdFixa, ;
                            nFPotencia, nFatPerda, cCodPai, cVersao, lFantasma, aOperacoes, ;
                            dLeadTime, nQtdBase) CLASS MrpDominio_Rastreio

	Local aDados     := {}
	Local aAreaPRD   := {}
	Local cChave     := ""
	Local cDocFilho  := ""
	Local cDocPai    := ""
	Local cOperacao  := ""
	Local lError     := .F.
	Local lAglutina  := .F.
	Local lAtual     := cFilAux + cComponente == ::oDados:oProdutos:cCurrentKey
	Local nEstoque   := 0
	Local nIndex     := 0
	Local nIndQuebra := 0
	Local nTotal     := Len(aBaixaPorOP)
	Local nTotQuebra := 0
	Local nNecPai    := 0

	Default cIDOpc     := ""
	Default cRegra     := "1"
	Default cRevisao   := ""
	Default cRoteiro   := ""
	Default cLocal     := ""
	Default cVersao    := ""
	Default lQtdFixa   := .F.
	Default nFatPerda  := 0
	Default nFPotencia := 0
	Default aOperacoes := {}
	Default nQtdBase   := 0

	//Mant�m o componente posicionado.
	If !lAtual
		aAreaPRD := ::oDados:retornaArea("PRD")
		::oDados:retornaCampo("PRD", 1, cFilAux + cComponente, "PRD_COD", , lAtual, , /*lProximo*/, , , .F. /*lVarios*/)
	EndIf

	nQtdSEst  := 0
	lAglutina := ::oDados:oDominio:oAglutina:avaliaAglutinacao(cFilAux, cComponente)

	//Gera registro de rastreabilidade quando inexist�ncia de OP
	If nTotal == 0
		nTotal := 1
		aAdd(aBaixaPorOP, {"ESTOQUE", "", 1, 0, 0, 0, {},"ESTOQUE"})
	EndIf

	If slLogR9 == Nil
		slLogR9 := ::oDados:oLogs:logValido("R9")
	EndIf

	If slLogR9
		//STR0120 - "Inclusoes necessidade do componente '"
		//STR0121 - "' de TRT '"
		//STR0122 - "' no per�odo '"
		//STR0123 - "' referente quantidade: "
		::oDados:oLogs:log(STR0120 + AllTrim(cComponente) + STR0121 + cTRT + STR0122 + cValToChar(nPeriodo) + STR0123 + cValToChar(nQuantidade), "R9")
	EndIf

	For nIndex := 1 to nTotal
		lError    := .F.

		nTotQuebra := Len(aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE])
		If nTotQuebra < 1 //Se n�o tiver o array de quebras, cria uma quebra com a qtd. total.
			aSize(aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE], 0)
			aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE] := {{aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE], ""}}
			nTotQuebra := 1
		EndIf

		cChave   := aBaixaPorOP[nIndex][ABAIXA_POS_CHAVE]

		//Atualiza o rastreio com as quebras de produ��o/compra definidas pelas pol�ticas de estoque.
		If oRastrPais[cChave] != Nil .And. !lFantasma
			oRastrPais[cChave][ADADOS_POS_QUEBRAS_QUANTIDADE] := aClone(aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE])
		EndIf

		For nIndQuebra := 1 To nTotQuebra
			cDocFilho := ""
			//Para cada quebra de produ��o, ir� gerar um novo registro de rastreabilidade filho, com um novo documento.
			nNecPai   := aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE][nIndQuebra][1]

			If nIndQuebra == 1
				nEstoque := aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
			EndIf

			If nNecPai == 0
				If aBaixaPorOP[nIndex][ABAIXA_POS_RASTRO_AGLUTINACAO][1] <> 0 .And. ;
				   ::oDados:oDominio:oAglutina:avaliaAglutinacao(cFilAux, cComponente, .F., aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI])
					
					::oDados:oDominio:oAglutina:prepara(cFilAux                                               ,;
					                                    "4"                                                   ,;
					                                    aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI]              ,;
					                                    {                                                      ;
					                                     aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI]             ,;
					                                     aBaixaPorOP[nIndex][ABAIXA_POS_DOCPAI]               ,;
					                                     cCodPai                                              ,;
					                                     ""                                                    ;
					                                    }                                                     ,;
					                                    aBaixaPorOP[nIndex][ABAIXA_POS_DOCPAI]                ,;
					                                    cComponente                                           ,;
					                                    cIDOpc                                                ,;
					                                    cTRT                                                  ,;
					                                    aBaixaPorOP[nIndex][ABAIXA_POS_RASTRO_AGLUTINACAO][1] ,;
					                                    nPeriodo                                              ,;
					                                    cRegra                                                ,;
					                                    .F.                                                   ,;
					                                    .T.                                                   ,;
					                                    .F.                                                   )

				EndIf

				Loop
			EndIf

			nNecComp := ::oDados:oDominio:ajustarNecessidadeExplosao(cFilAux, cComponente, nNecPai, nQuantidade, lQtdFixa, @nFPotencia, nFPotencia, nFatPerda, nQtdBase)

			//Gera Evento 004 - Data de necessidade invalida - Data anterior a database (Novas necessidades do MRP com data anterior a base do sistema)
			If Self:oDados:oParametros["lEventLog"] .And. nNecComp != 0 .And. dLeadTime != Nil .And. dLeadTime < Self:oDados:oParametros["dDataIni"]
				Self:oDados:oDominio:oEventos:loga("004", cComponente, dLeadTime, {AllTrim(Left(cCodPai, snTamCod)), nNecComp, dLeadTime, aBaixaPorOP[nIndex][ABAIXA_POS_DOCPAI], "", "", cTRT}, cFilAux)
			EndIf

			//Soma a qtd no totalizador p/ retornar a qtd total arredondada.
			nQtdSEst += nNecComp

			cDocPai := aBaixaPorOP[nIndex][ABAIXA_POS_DOCPAI]
			cDocPai += chr(13) + cValToChar(nIndQuebra)

			If oRastrPais[cChave] == Nil
				If !lAglutina
					cDocFilho := cChave
				EndIf

				//Atualiza necessidade do Documento Filho
				::oDados:oDominio:oAglutina:preparaEInclui(cFilAux, "4", "OP", {aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI], cDocPai, cCodPai}, @cDocFilho, cComponente, cIDOpc, cTRT, nNecComp, nPeriodo, cRegra, lAglutina, nIndQuebra != 1)
			Else
				//Gera ID Documento Filho
				If lAglutina .And. Empty(oRastrPais[cChave][ADADOS_POS_DOCFILHO])
					If oRastrPais[cChave][ADADOS_POS_TIPOPAI] == "AGL" .And. !Empty(aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2])
						cDocFilho := aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2]
					Else
						cDocFilho := ::oDados_Rastreio:proximaOP()
					EndIf
				Else
					If !Empty(oRastrPais[cChave][ADADOS_POS_DOCFILHO]) .And. nIndQuebra == 1
						cDocFilho := oRastrPais[cChave][ADADOS_POS_DOCFILHO]

					ElseIf Empty(aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2])
						If oRastrPais[cChave][ADADOS_POS_TIPOPAI] == "OP"
							cDocFilho := ::oDados_Rastreio:proximaOPItem(oRastrPais[cChave][ADADOS_POS_DOCPAI])
						Else
							cDocFilho := ::oDados_Rastreio:proximaOP()
						EndIf
					Else
						cDocFilho := aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2]
					EndIf
				EndIf

				//Atualiza Rastreio Registro Pai na Quebra
				//Quando aglutina Manter essa atualiza��o pois sem ela o relacionamento fica incorreto
				If Empty(oRastrPais[cChave][ADADOS_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2])
					oRastrPais[cChave][ADADOS_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2] := cDocFilho
					aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2] := cDocFilho
				EndIf

				//Atualiza necessidade do Documento Filho
				cOperacao := Self:retornaOperacao(cRoteiro, aOperacoes)
				::oDados:oDominio:oAglutina:preparaEInclui(cFilAux, "4", "OP", {aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI], cDocPai, cCodPai, oRastrPais[cChave][ADADOS_POS_QUEBRAS_QUANTIDADE][nIndQuebra][2]}, cDocFilho, cComponente, cIDOpc, cTRT, nNecComp, nPeriodo, cRegra, lAglutina, .F., cRoteiro, cOperacao)

				If nIndQuebra == 1
					//Somente atualiza estas informa��es quando for o primeiro
					//registro da quebra de produ��o/compra. Para os demais registros da quebra,
					//estes dados sempre ser�o iguais. As informa��es diferentes para cada
					//quebra estar�o armazenadas dentro do array ABAIXA_POS_QUEBRAS_QUANTIDADE{"QTD","DOCUMENTO"}
					If Empty(oRastrPais[cChave][ADADOS_POS_DOCFILHO])
						oRastrPais[cChave][ADADOS_POS_DOCFILHO           ] := cDocFilho
					EndIf
					oRastrPais[cChave][ADADOS_POS_QTD_ESTOQUE            ] := nEstoque
					oRastrPais[cChave][ADADOS_POS_REVISAO                ] := cRevisao
					oRastrPais[cChave][ADADOS_POS_ROTEIRO_DOCUMENTO_FILHO] := cRoteiro
					oRastrPais[cChave][ADADOS_POS_LOCAL                  ] := cLocal
					oRastrPais[cChave][ADADOS_POS_VERSAO_PRODUCAO        ] := cVersao
					If oRastrPais[cChave][ADADOS_POS_COMP_EXPL_ESTRUT] == Nil
						oRastrPais[cChave][ADADOS_POS_COMP_EXPL_ESTRUT   ] := {}
					Endif
					aAdd(oRastrPais[cChave][ADADOS_POS_COMP_EXPL_ESTRUT], (cComponente + Iif(!Empty(cIDOpc),"|"+cIDOpc,"") + chr(13) + cValToChar(nPeriodo) + chr(13) + cTRT + chr(13) + ""))
				EndIf
			EndIf

		Next nIndQuebra

	Next

	//Retorna o posicionamento do componente.
	If !lAtual
		::oDados:setaArea(aAreaPRD)
		aSize(aAreaPRD, 0)
	EndIf

	If aDados != Nil
		aSize(aDados, 0)
		aDados := Nil
	EndIf

Return Nil


/*/{Protheus.doc} retornaOperacao
Retorna a opera��o do roteiro relacionada ao componente
@author    brunno.costa
@since     15/04/2020
@version   1
@param 01 - cRoteiro  , caracter, c�digo do roteiro relacionado ao componente
@param 02 - aOperacoes, array   , array com as opera��es deste produto e componente
@return cOperacao, array, array com os dados do rastreio deste registro
/*/

METHOD retornaOperacao(cRoteiro, aOperacoes) CLASS MrpDominio_Rastreio

	Local cOperacao := ""
	Local nPos      := 0

	If !Empty(cRoteiro) .And. !Empty(aOperacoes)
		nPos := aScan(aOperacoes, {|x| AllTrim(x[Self:nIOpeRotei]) == cRoteiro})
		If nPos > 0
			cOperacao := aOperacoes[nPos][Self:nIOpeOpera]
		EndIf
	EndIf

Return cOperacao

/*/{Protheus.doc} retornaRastreio
Retorna registro de rastreabilidade do documento
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux  , caracter, c�digo da filial
@param 02 - cProduto , caracter, c�digo do produto
@param 03 - nPeriodo , n�mero  , n�mero do per�odo
@param 04 - cDocPai  , caracter, c�digo do documento pai do registro
@param 05 - cTRT     , caracter, c�digo do TRT do produto na estrutura
@param 06 - cListOrig, caracter, chave do registro original do Rastreio, quando alternativo
@return aRastreio, array, array com os dados do rastreio deste registro
/*/
METHOD retornaRastreio(cFilAux, cProduto, nPeriodo, cDocPai, cTRT, cListOrig) CLASS MrpDominio_Rastreio

	Local aRastreio
	Local cList
	Local cChave

	Default cListOrig := ""

	cList  := cFilAux + cProduto + chr(13) + cValToChar(nPeriodo)
	cChave := cDocPai + chr(13) + cTRT + chr(13) + cListOrig

	aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, cChave)

Return aRastreio

/*/{Protheus.doc} retornaAlternativos
Retorna C�digos dos Alternativos
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cProduto, caracter, c�digo do componente relacionado (filial + componente + id opcional)
@param 02 - nPeriodo, n�mero  , n�mero do per�odo
@param 03 - lTranAlt, l�gico  , identifica que � realizada atualiza��o para alternativos com transfer�ncia (multi-empresa)
@Return aAlteDeman, array, array com os c�digos dos produtos alternativos consumidos
/*/

METHOD retornaAlternativos(cProduto, nPeriodo, lTranAlt) CLASS MrpDominio_Rastreio

	Local aAlteDeman := {}
	Local cOrigDeman := ""

	Default lTranAlt := .F.

	If !lTranAlt .Or. Empty(::oAlternativo:aSubsTranf)
		cOrigDeman := "KEY_" + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)
		aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)
	Else
		//Recupera as informa��es de transfer�ncias realizadas para atender as substitui��es
		//para correta gera��o dos dados de rastreio (HWC) do produto alternativo.
		aAlteDeman := aClone(::oAlternativo:aSubsTranf)
	EndIf

Return aAlteDeman


/*/{Protheus.doc} incluiNecessidade
Inclui Rastreio da Necessidade Original
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux    , caracter, c�digo da filial
@param 02 - cTipoPai   , caracter, tipo do Documento Pai
@param 03 - cDocPai    , caracter, identificador do documento Pai
@param 04 - cComponente, caracter, c�digo do componente
@param 05 - cIDOpc     , caracter, ID do opcional deste produto
@param 06 - cTRT       , caracter, c�digo do TRT
@param 07 - nQuantidade, n�mero  , quantidade da necessidade
@param 08 - nPeriodo   , n�mero  , per�odo da necessidade
@param 09 - cListOrig  , caracter, cList relacionado ao registro original da substitui��o
@param 10 - cRegra     , caracter,  regra de consumo dos alternativos:
								1- Valida Original; Valida Alternativo; Compra Original
								2- Valida Original; Valida Alternativo; Compra Alternativo
								3- Valida Alternativo; Compra Alternativo
@param 11 - cOrdSubst  , caracter, indica a ordem do alternativo na substitui��o
@param 12 - cRoteiro   , caracter, c�digo do roteiro de opera��es do produto Pai
@param 13 - cOperacao  , caracter, c�digo da opera��o deste componente no roteiro do produto Pai
@param 14 - nQtrEnt    , n�mero  , quantidade transferida que entrou para o produto + filial + periodo
@param 15 - nQtrSai    , n�mero  , quantidade transferida que saiu para o produto + filial + periodo
@param 16 - cDocFilho  , caracter, numera��o do documento filho do registro
@param 17 - nSaldo     , n�mero  , Saldo do produto
@param 18 - lSubsTran  , n�mero  , Indica que deve substituir a quantidade de transfer�ncia existente (quando substitui��o)
@return cChave, caracter, chave do registro
/*/
METHOD incluiNecessidade(cFilAux, cTipoPai, cDocPai, cComponente, cIDOpc, cTRT, nQuantidade,;
                         nPeriodo, cListOrig, cRegra, cOrdSubst, cRoteiro, cOperacao, nQtrEnt,;
                         nQtrSai, cDocFilho, nSaldo, lSubsTran) CLASS MrpDominio_Rastreio

	Local aDados   := {}
	Local cList    := ""
	Local lError   := .F.
	Local cChave   := ""

	Default cTipoPai    := "ID"
	Default cDocFilho   := ""
	Default cDocPai     := ""
	Default cTRT        := ""
	Default cIDOpc      := ""
	Default cListOrig   := ""
	Default cOrdSubst   := "00"
	Default cRegra      := "1"
	Default cRoteiro    := ""
	Default cOperacao   := ""
	Default nQtrEnt     := 0
	Default nQtrSai     := 0
	Default nSaldo      := 0
	Default lSubsTran   := .F.

	If slLogR6 == Nil
		slLogR6 := ::oDados:oLogs:logValido("R6")
	EndIf
	If slLogR7 == Nil
		slLogR7 := ::oDados:oLogs:logValido("R7")
	EndIf

	//Recupera ID do Registro (ou Insere Novo e Recupera)
	cList := cFilAux + cComponente + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + cValToChar(nPeriodo)

	If !::oDados_Rastreio:oDados:existAList(cList)
		::oDados_Rastreio:oDados:createAList(cList)
	EndIf

	cChave := cDocPai + chr(13) + cTRT + chr(13) + cListOrig
	aDados := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
	If lError//Inclui novo registro
		lError := .F.
		aDados := Array(ADADOS_SIZE)
		aDados[ADADOS_POS_FILIAL                 ] := cFilAux
		aDados[ADADOS_POS_PERIODO                ] := nPeriodo
		aDados[ADADOS_POS_TIPOPAI                ] := AllTrim(cTipoPai)
		aDados[ADADOS_POS_DOCPAI                 ] := cDocPai
		aDados[ADADOS_POS_DOCFILHO               ] := cDocFilho
		aDados[ADADOS_POS_COMP_EXPL_ESTRUT       ] := {}
		aDados[ADADOS_POS_COMPONENTE             ] := cComponente
		aDados[ADADOS_POS_ID_OPCIONAL            ] := cIDOpc
		aDados[ADADOS_POS_TRT                    ] := cTRT
		aDados[ADADOS_POS_NEC_ORIGINAL           ] := nQuantidade
		aDados[ADADOS_POS_CONSUMO_ESTOQUE        ] := 0
		aDados[ADADOS_POS_NECESSIDADE            ] := Iif(nQuantidade < 0 .Or. "|TRANF" $ "|" + AllTrim(cTipoPai), 0, nQuantidade)
		aDados[ADADOS_POS_QTD_ESTOQUE            ] := nSaldo
		aDados[ADADOS_POS_QTD_SUBSTITUICAO       ] := 0
		aDados[ADADOS_POS_CONSUMO_SUBSTITU       ] := 0
		aDados[ADADOS_POS_CHAVE_SUBSTITUICAO     ] := cListOrig
		aDados[ADADOS_POS_SUBST_ORDEM            ] := cOrdSubst
		aDados[ADADOS_POS_REGRA_ALTERNATIVO      ] := cRegra
		aDados[ADADOS_POS_QUEBRAS_QUANTIDADE     ] := {}
		aDados[ADADOS_POS_ROTEIRO                ] := cRoteiro
		aDados[ADADOS_POS_OPERACAO               ] := cOperacao
		aDados[ADADOS_POS_ROTEIRO_DOCUMENTO_FILHO] := ""
		aDados[ADADOS_POS_TRANSFERENCIA_ENTRADA  ] := nQtrEnt
		aDados[ADADOS_POS_TRANSFERENCIA_SAIDA    ] := nQtrSai
		aDados[ADADOS_POS_RASTRO_AGLUTINACAO     ] := {0,""}
		aDados[ADADOS_POS_DOC_AGLUTINADOR        ] := {.F.,""}
		aDados[ADADOS_POS_ALTERNATIVOS           ] := Nil

		If slLogR6
			::oDados:oLogs:log("Inclui necessidade do produto " + RTrim(aDados[ADADOS_POS_COMPONENTE]) +;
			                   " e documento " + aDados[ADADOS_POS_DOCPAI]                             +;
			                   " (TRT:" + aDados[ADADOS_POS_TRT]  + "): "                             +;
			                   cValToChar(Iif(nQuantidade < 0, 0, nQuantidade))                        +;
			                   ". TRAN_ENTR=[" + cValToChar(nQtrEnt) + "]. TRAN_SAID=[" + cValToChar(nQtrSai) + "]", "R6")
		EndIf

	Else //Atualiza registro existente

		If slLogR7
			::oDados:oLogs:log("Atualiza necessidade do produto " + RTrim(aDados[ADADOS_POS_COMPONENTE]) +;
			                   " e documento " + aDados[ADADOS_POS_DOCPAI]                               +;
			                   " (TRT:" + aDados[ADADOS_POS_TRT]  + "): "                               +;
			                   cValToChar(aDados[ADADOS_POS_NEC_ORIGINAL]) + " + " + cValToChar(nQuantidade), "R7")
		EndIf
		// Se for Ponto de pedido, substitui a quantidade
		If aDados[ADADOS_POS_TIPOPAI] == scTextPPed  //Pont. Ped.
			aDados[ADADOS_POS_NEC_ORIGINAL] := nQuantidade
		Else
			aDados[ADADOS_POS_NEC_ORIGINAL] += nQuantidade
		EndIf

		If lSubsTran
			aDados[ADADOS_POS_TRANSFERENCIA_ENTRADA] := 0
			aDados[ADADOS_POS_TRANSFERENCIA_SAIDA  ] := 0
		EndIf

		If slLogR7
			::oDados:oLogs:log("Atualiza necessidade do produto " + RTrim(aDados[ADADOS_POS_COMPONENTE]) +;
			                   " e documento " + aDados[ADADOS_POS_DOCPAI]                               +;
			                   " (TRT:" + aDados[ADADOS_POS_TRT]  + "): "                                +;
			                   " [TRAN_ENTR]" + cValToChar(aDados[ADADOS_POS_TRANSFERENCIA_ENTRADA]) + " + " + cValToChar(nQtrEnt) +;
			                   " [TRAN_SAID]" + cValToChar(aDados[ADADOS_POS_TRANSFERENCIA_SAIDA]) + " + " + cValToChar(nQtrSai), "R7")
		EndIf

		aDados[ADADOS_POS_TRANSFERENCIA_ENTRADA] += nQtrEnt
		aDados[ADADOS_POS_TRANSFERENCIA_SAIDA  ] += nQtrSai

	EndIf
	::oDados_Rastreio:oDados:setItemAList(cList, cChave, aDados, @lError)

	aSize(aDados, 0)
	aDados := Nil

Return cChave

/*/{Protheus.doc} desfazSubstituicoes
Desfaz substitui��o de Rastreabilidade

@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cProduto   , caracter, c�digo do produto original relacionado
@param 03 - nPeriodo   , n�mero  , identificador do per�odo relacionado a substitui��o
@param 04 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
							   {{1 - Id Rastreabilidade,;
							     2 - Documento Pai,;
							     3 - Quantidade Necessidade,;
							     4 - Quantidade Estoque,;
							     5 - Quantidade Baixa Estoque,;
							     6 - Quantidade Substitui��o
								 7 - ID Registro Substitu�do
								 8 - Regra de Consumo do Alternativo},...}
@param 05 - nConsumo    , n�mero   , quantidade de consumo da substitui��o a ser desfeita
/*/

METHOD desfazSubstituicoes(cFilAux, cProduto, nPeriodo, aBaixaPorOP, nConsumo) CLASS MrpDominio_Rastreio

	Local aDados     := {}
	Local aDadosAlt  := {}
	Local cChave
	Local cList      := cFilAux + cProduto + chr(13) + cValToChar(nPeriodo)
	Local lError     := .F.
	Local nIndex
	Local nTotal     := Len(aBaixaPorOP)
	Local nSubstitui := -nConsumo

	If slLogR8 == Nil
		slLogR8 := ::oDados:oLogs:logValido("R8")
	EndIf

	If slLogR8
		::oDados:oLogs:log("Desfaz substituicoes do produto " + RTrim(cProduto) + " no periodo " + cValToChar(nPeriodo) + " referente consumo: " + cValToChar(nConsumo), "R8")
	EndIf

	For nIndex := 1 to nTotal
		aDadosAlt := {}
		lError    := .F.
		cChave    := aBaixaPorOP[nIndex][1]

		If nSubstitui == 0
			Exit
		EndIf

		aDados := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
		If !lError
			If aDados[ADADOS_POS_ALTERNATIVOS] != Nil 
				FreeObj(aDados[ADADOS_POS_ALTERNATIVOS])
				aDados[ADADOS_POS_ALTERNATIVOS] := Nil
			EndIf
			If !Empty(aDados[ADADOS_POS_CHAVE_SUBSTITUICAO])
				Loop
			EndIf

			If nSubstitui < aDados[ADADOS_POS_QTD_SUBSTITUICAO]
				If slLogR8
					::oDados:oLogs:log("Desfaz substituicoes do produto " + RTrim(cProduto) + " no periodo " + cValToChar(nPeriodo) + " pelo alternativo referente consumo " + cValToChar(nSubstitui), "R8")
				EndIf

				aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE]      += nSubstitui
				aDados[ADADOS_POS_QTD_SUBSTITUICAO]              -= nSubstitui
				aDados[ADADOS_POS_NECESSIDADE]                   += nSubstitui
				aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] := 0
				nSubstitui                                       := 0

				//Desconta necessidade original negativa
				If aDados[ADADOS_POS_NECESSIDADE] > 0 .And. aDados[ADADOS_POS_NEC_ORIGINAL] < 0
					aDados[ADADOS_POS_NECESSIDADE] += aDados[ADADOS_POS_NEC_ORIGINAL]
				EndIf

				::oDados_Rastreio:oDados:setItemAList(cList, cChave, aDados)
				Exit
			Else
				If slLogR8
					::oDados:oLogs:log("Desfaz substituicoes do produto " + AllTrim(cProduto) + " no periodo " + cValToChar(nPeriodo) + " pelo alternativo referente consumo " + cValToChar(aDados[ADADOS_POS_QTD_SUBSTITUICAO]), "R8")
				EndIf

				aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE]      += aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]
				aDados[ADADOS_POS_NECESSIDADE]                   += aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]
				nSubstitui                                       -= aDados[ADADOS_POS_QTD_SUBSTITUICAO]
				aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] := 0
				aDados[ADADOS_POS_QTD_SUBSTITUICAO]              := 0

				//Desconta necessidade original negativa
				If aDados[ADADOS_POS_NECESSIDADE] > 0 .And. aDados[ADADOS_POS_NEC_ORIGINAL] < 0
					aDados[ADADOS_POS_NECESSIDADE] += aDados[ADADOS_POS_NEC_ORIGINAL]
				EndIf

				::oDados_Rastreio:oDados:setItemAList(cList, cChave, aDados)
			EndIf
		EndIf
	Next

Return

/*/{Protheus.doc} atualizaSubstituicao
Atualiza Substitui��o - Produto Original

@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux     , caracter, c�digo da filial
@param 02 - cComponente , caracter, c�digo do componente para an�lise
@param 03 - nPeriodo    , n�mero  , per�odo para an�lise
@param 04 - aBaixaPorOP , array   , retorna por refer�ncia array com os dados de rastreabilidade origem (Documentos Pais)
@param 05 - lAltReg1    , logico  , indica se refere-se a atualiza��o no registro do produto alternativo com regra do tipo 1
@param 06 - lNecBxaOp   , logico  , indica que utiliza a necessidade do aBaixaPorOP para realiza��o do c�lculo.
@param 07 - nTotalSubs  , n�mero  , quantidade total de substitui��o que ser� considerada - utilizado quando lNecBxaOp == .T.
@param 08 - lTranAlt    , logico  , indica que a atualiza��o das substitui��es est� sendo feita para substitui��es com transfer�ncias de estoque (multi-empresa)
@return Nil
/*/
METHOD atualizaSubstituicao(cFilAux, cComponente, nPeriodo, aBaixaPorOP, lAltReg1, lNecBxaOp, nTotalSubs, lTranAlt) CLASS MrpDominio_Rastreio

	Local aAlteDeman := {} //C�digos dos Alternativos da Substitui��o
	Local aDados     := {}
	Local aDadosChvs := {}
	Local aDeleta    := {}
	Local aNames     := {}
	Local aRastreio  := {}
	Local cChave     := ""
	Local cChvLock   := ""
	Local cIdOpc     := ""
	Local cKeyOri    := ""
	Local cList      := cFilAux + cComponente + chr(13) + cValToChar(nPeriodo)
	Local lAlterou   := .F.
	Local lError     := .F.
	Local lPrimeiro  := .T.
	Local lZerou     := .F.
	Local nAux       := 0
	Local nContador  := 0
	Local nDestinos  := 0
	Local nEstoque   := 0
	Local nIndex     := 0
	Local nSubstitui := 0
	Local nTotal     := Len(aBaixaPorOP)
	Local nTotalDest := 0
	Local oSldSubst  := Nil

	Default lNecBxaOp  := .F.
	Default nTotalSubs := 0
	Default lTranAlt   := .F.

	If slLogR1 == Nil
		slLogR1 := ::oDados:oLogs:logValido("R1")
	EndIf

	If nTotal > 0
		//Analise Substitui��o - Produto ALTERNATIVO
		If lAltReg1
			oSldSubst := JsonObject():New()

			//Obt�m o saldo final, considerando as entradas, sa�das e necessidade;
			For nIndex := 1 To nTotal
				If lPrimeiro
					lPrimeiro := .F.
					nEstoque  := aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
				EndIf
				nEstoque -= aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG]
				nEstoque += aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE]
			Next nIndex

			For nIndex := 1 To nTotal
				//Recupera o registro de rastreabilidade
				lError    := .F.
				lZerou    := .F.
				aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, aBaixaPorOP[nIndex][ABAIXA_POS_CHAVE], @lError)
				If !lError
					If (AllTrim(aRastreio[ADADOS_POS_TIPOPAI]) $ "|" + scTextESeg + "|" + scTextPPed + "|1|") //"Est.Seg." | "Ponto Ped." | "PMP"
						Loop
					EndIf

					//Se conseguiu recuperar o registro, faz o lock e atualiza os dados de acordo com o aBaixaPorOP
					cChvLock := "dados_" + aRastreio[ADADOS_POS_DOCPAI];
										 + aRastreio[ADADOS_POS_COMPONENTE];
										 + aRastreio[ADADOS_POS_ID_OPCIONAL];
										 + aRastreio[ADADOS_POS_TRT]
					::oDados_Rastreio:oDados:lock(cChvLock)
					aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, aBaixaPorOP[nIndex][ABAIXA_POS_CHAVE], @lError)
					If lAlterou
						aRastreio[ADADOS_POS_QTD_ESTOQUE]           := nEstoque
						aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] := nEstoque

					EndIf
					nEstoque    += aRastreio[ADADOS_POS_TRANSFERENCIA_ENTRADA]
					lAlterou    := .F.
					nSubstitui  := aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]

					If !Empty(aRastreio[ADADOS_POS_CHAVE_SUBSTITUICAO]);
				   		.And. aRastreio[ADADOS_POS_REGRA_ALTERNATIVO] == "1"

						//Recupera Quantidade da Substitui��o no Produto Original
						If nEstoque == 0
							::avaliaSubstOriginal(cFilAux, @aRastreio, @nEstoque, @nSubstitui, @oSldSubst, .T., @aBaixaPorOP, lAltReg1)
							aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] := 0
							aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]           := 0
							aRastreio[ADADOS_POS_QTD_SUBST_ORIGINAL]         := 0
							nSubstitui                                       := 0
							nEstoque                                         := 0
							lAlterou                                         := .T.
							lZerou                                           := .T.

						Else
							::avaliaSubstOriginal(cFilAux, @aRastreio, @nEstoque, @nSubstitui, @oSldSubst, , @aBaixaPorOP, lAltReg1)
							aRastreio[ADADOS_POS_QTD_SUBSTITUICAO          ] := nSubstitui
							aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] := nSubstitui
							lAlterou                                         := .T.
							If nSubstitui == 0
								lZerou                                       := .T.
							EndIf
						EndIf
					Else

						If nSubstitui >= 0
							nEstoque += nSubstitui
						Else
							nEstoque += nSubstitui - aRastreio[ADADOS_POS_CONSUMO_ESTOQUE]
						EndIf

					EndIf

					//Atualiza rastreabilidade do produto alternativo
					If lZerou
						::oDados_Rastreio:oDados:delItemAList(cList, aBaixaPorOP[nIndex][ABAIXA_POS_CHAVE])
						aAdd(aDeleta, nIndex)
					ElseIf lAlterou
						::oDados_Rastreio:oDados:setItemAList(cList, aBaixaPorOP[nIndex][ABAIXA_POS_CHAVE], aRastreio)
					EndIf
					::oDados_Rastreio:oDados:unLock(cChvLock)

				EndIf
				If !lError
					aSize(aRastreio, 0)
				EndIf
			Next

			//Remove do aBaixaPorOp os elementos apagados.
			nTotal := Len(aDeleta)
			For nIndex := nTotal To 1 Step -1
				aDel(aBaixaPorOP, aDeleta[nIndex])
			Next nIndex
			If nTotal > 0
				aSize(aBaixaPorOP, Len(aBaixaPorOP) - nTotal)
			EndIf

			aNames := oSldSubst:GetNames()
			nTotal := Len(aNames)
			For nIndex := 1 To nTotal
				oSldSubst[aNames[nIndex]] := Nil
			Next nIndex
			aSize(aNames, 0)
			aNames := Nil

			FreeObj(oSldSubst)
			oSldSubst := Nil

		Else //Analise Substitui��o - Produto ORIGINAL
			If !lNecBxaOp .Or. Empty(nTotalSubs)
				cKeyOri := "KEY_ORI_" + cFilAux + AllTrim(cComponente) + "_" + cValToChar(nPeriodo)
				nAux    := ::oDados:oAlternativos:getFlag(cKeyOri)
				If nAux != Nil
					nTotalSubs += nAux
				EndIf
			EndIf

			If nTotalSubs > 0
				If slLogR1
					//STR0131 - "Atualizando substitui��o no produto original '"
					//STR0132 - "' e per�odo '"
					::oDados:oLogs:log(STR0131 + cFilAux + AllTrim(cComponente) + STR0132 + cValToChar(nPeriodo) + "': " + cValTochar(nTotalSubs), "R1")
				EndIf

				//Recupera registros de rastreabilidade das chaves
				nTotal := Len(aBaixaPorOP)
				For nIndex := 1 to nTotal
					lError := .F.
					aDados := {}
					cChave := aBaixaPorOP[nIndex][1]
					aDados := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
					If !lError
						cChvLock := "dados_" + aDados[ADADOS_POS_DOCPAI];
											 + aDados[ADADOS_POS_COMPONENTE];
											 + aDados[ADADOS_POS_ID_OPCIONAL];
											 + aDados[ADADOS_POS_TRT]
						::oDados_Rastreio:oDados:lock(cChvLock)
						nContador++
						aAdd(aDadosChvs, {cChave, aDados, StrZero(nContador, 5)})
					EndIf
				Next
				//Atualiza Total de Registros V�lidos e Ordena por OP
				aDadosChvs := ::ordenaRastreio(aDadosChvs, .T.)

				//Percorre Registros de Rastreabilidade
				nTotal := Len(aDadosChvs)
				For nIndex := 1 to nTotal
					lAlterou   := .F.
					lError     := .F.
					nSubstitui := 0
					aRastreio  := aDadosChvs[nIndex][2]
					cChvLock   := "dados_" + aRastreio[ADADOS_POS_DOCPAI];
					                       + aRastreio[ADADOS_POS_COMPONENTE];
					                       + aRastreio[ADADOS_POS_ID_OPCIONAL];
					                       + aRastreio[ADADOS_POS_TRT]

					If !Empty(aRastreio[ADADOS_POS_CHAVE_SUBSTITUICAO]) .Or. AllTrim(aRastreio[ADADOS_POS_TIPOPAI]) != "OP"
						::oDados_Rastreio:oDados:unLock(cChvLock)
						Loop
					EndIf

					If (aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] - nTotalSubs) > 0
						aRastreio[ADADOS_POS_NECESSIDADE]           += (aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] - nTotalSubs)
						aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE] := aRastreio[ADADOS_POS_NECESSIDADE]
						lAlterou                                    := .T.
					EndIf

					//Atualiza Substitui��o e Necessidades
					If nTotalSubs != 0
						If lNecBxaOp
							nSubstitui := nTotalSubs
							nTotalSubs := 0
						Else
							If nTotalSubs == aRastreio[ADADOS_POS_NECESSIDADE]
								nSubstitui += nTotalSubs
								nTotalSubs := 0

							ElseIf aRastreio[ADADOS_POS_NECESSIDADE] > nTotalSubs
								nSubstitui += nTotalSubs
								nTotalSubs := 0

							ElseIf aRastreio[ADADOS_POS_NECESSIDADE] < nTotalSubs
								nSubstitui += aRastreio[ADADOS_POS_NECESSIDADE]
								nTotalSubs -= nSubstitui

							EndIf
						EndIf
					EndIf

					If slLogR1
						::oDados:oLogs:log("Atualizando substituicao no produto original " + cFilAux + RTrim(cComponente)                   +;
						                   " e periodo " + cValToChar(nPeriodo) + "."                                                       +;
						                   "aRastreio[ADADOS_POS_NECESSIDADE]: " + cValTochar(aRastreio[ADADOS_POS_NECESSIDADE])            +;
						                   ", aRastreio[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValTochar(aRastreio[ADADOS_POS_CONSUMO_SUBSTITU])+;
						                   ", nSubstitui: " + cValTochar(nSubstitui)                                                        +;
						                   ", nTotalSubs: " + cValTochar(nTotalSubs), "R1")
					EndIf

					//Atualiza array para retorno
					aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] := nSubstitui
					
					//Atualiza vari�veis globais
					If aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] != nSubstitui
						lAlterou := .T.
						aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] := nSubstitui
						If slLogR1
							::oDados:oLogs:log("Atualizando substituicao no produto original " + cFilAux + RTrim(cComponente) + " e periodo " + cValToChar(nPeriodo) + "': " + cValTochar(nTotalSubs) + " nSubstitui: " + cValTochar(nSubstitui), "R1")
						EndIf
					EndIf

					If nSubstitui != 0
						lAlterou := .T.
						//Inclui registro do produto Alternativo na Rastreabilidade
						aAlteDeman  := ::retornaAlternativos(cFilAux + cComponente, nPeriodo, lTranAlt)
						nTotalDest := Len(aAlteDeman)
						If aRastreio[ADADOS_POS_ALTERNATIVOS] == Nil
							aRastreio[ADADOS_POS_ALTERNATIVOS] := JsonObject():New()
						EndIf
						For nDestinos := 1 to nTotalDest
							cChave   := RTrim(aAlteDeman[nDestinos][1])
							cDestino := aAlteDeman[nDestinos][1]

							::oDados:oDominio:oOpcionais:separaIdChaveProduto(@cDestino, @cIdOpc)

							If !aRastreio[ADADOS_POS_ALTERNATIVOS]:HasProperty(cChave)
								aRastreio[ADADOS_POS_ALTERNATIVOS][cChave] := 0
							EndIf

							If !lTranAlt
								//Verifica se este alternativo j� teve as necessidades inclu�das
								If aAlteDeman[nDestinos][3] == 0
									Loop
								EndIf
								
								//Desconta deste alternativo a qtd utilizada pelo original para n�o registrar a necessidade
								//do alternativo com duplicidade quando existem v�rios documentos para o mesmo produto original
								//e v�rios alternativos para o produto original
								If aAlteDeman[nDestinos][3] <= nSubstitui
									aRastreio[ADADOS_POS_ALTERNATIVOS][cChave] += aAlteDeman[nDestinos][3]
									
									nSubstitui               -= aAlteDeman[nDestinos][3]
									aAlteDeman[nDestinos][3] := 0
								Else
									aRastreio[ADADOS_POS_ALTERNATIVOS][cChave] += nSubstitui
									
									aAlteDeman[nDestinos][3] -= nSubstitui
									nSubstitui               := 0
								EndIf
							Else
								aRastreio[ADADOS_POS_ALTERNATIVOS][cChave] += ::oAlternativo:aplicaProdutoFator(cFilAux,;
								                                                                                aRastreio[ADADOS_POS_COMPONENTE],;
								                                                                                cDestino,;
								                                                                                aAlteDeman[nDestinos][2],;
								                                                                                .T.)
							EndIf

							If slLogR1
								::oDados:oLogs:log("Atualizando substituicao no produto original" + cFilAux + RTrim(cComponente) + " e periodo " + cValToChar(nPeriodo) + "': cChave:[" + cChave + "] Total: " + cValToChar(aRastreio[ADADOS_POS_ALTERNATIVOS][cChave]), "R1")
							EndIf

							::incluiNecessidade(cFilAux                                ,;
							                    aRastreio[ADADOS_POS_TIPOPAI]          ,;
							                    aRastreio[ADADOS_POS_DOCPAI]           ,;
							                    cDestino                               ,;
							                    cIdOpc                                 ,;
							                    aRastreio[ADADOS_POS_TRT]              ,;
							                    0                                      ,;
							                    nPeriodo                               ,;
							                    cList                                  ,;
							                    aRastreio[ADADOS_POS_REGRA_ALTERNATIVO],;
							                    PadL(nDestinos, 2, "0")                ,;
							                    aRastreio[ADADOS_POS_ROTEIRO]          ,;
							                    aRastreio[ADADOS_POS_OPERACAO]         ,;
							                    aAlteDeman[nDestinos][2]               ,;
							                    /*nQtrSai*/                            ,;
							                    /*cDocFilho*/                          ,;
							                    /*nSaldo*/                             ,;
							                    .T. /*lSubsTran*/                      )

							If nSubstitui == 0
								Exit
							EndIf
						Next

						If !lTranAlt .And. nTotalDest > 0
							//Atualiza na global os dados do array "aAlteDeman"
							::oDados:oAlternativos:setItemAList("substituicoes_produtos",;
							                                    "KEY_" + AllTrim(cFilAux + cComponente) + "_" + cValToChar(nPeriodo),;
							                                    aAlteDeman, .F., .T., .F.)
						EndIf
					EndIf

					//Atualiza rastreabilidade do produto original
					If lAlterou
						::oDados_Rastreio:oDados:setItemAList(cList, aDadosChvs[nIndex][1], aRastreio)
					EndIf

					::oDados_Rastreio:oDados:unLock(cChvLock)
				Next
			EndIf

		EndIf
	EndIf

	For nIndex := 1 to Len(aDadosChvs)
		aSize(aDadosChvs[nIndex][2], 0)
		aDadosChvs[nIndex][2] := Nil

		aSize(aDadosChvs[nIndex], 0)
		aDadosChvs[nIndex] := Nil
	Next
	aSize(aDadosChvs, 0)
	aDadosChvs := Nil

	aSize(aRastreio, 0)
	aRastreio := Nil

	aSize(aAlteDeman, 0)
	aAlteDeman := Nil

Return Nil

/*/{Protheus.doc} desfazExplosoes
Desfaz Explosoes Deste Componente
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cChaveProd , caracter, c�digo do componente com Opcional
@param 03 - nPeriodo   , n�mero  , identificador de per�odo
@param 04 - cChvCheck  , caracter, chave para verficia��o de recursividade de estrutura (multi-empresas)
@param 05 - cPrdLoop   , caracter, string com os c�digos de produtos concatenados. Utilizado para msg de erro em caso de recursividade.
/*/
METHOD desfazExplosoes(cFilAux, cChaveProd, nPeriodo, cChvCheck, cPrdLoop) CLASS MrpDominio_Rastreio

	Local aChaves    := {}
	Local aDados     := {}
	Local cList      := cFilAux + cChaveProd + chr(13) + cValToChar(nPeriodo)
	Local lError     := .F.
	Local lEfetiva   := Empty(cChvCheck)
	Local nIndex     := 0
	Local nTotal     := 0

	If slLogR2 == Nil
		slLogR2 := ::oDados:oLogs:logValido("R2")
	EndIf

	cPrdLoop += RTrim(cFilAux + cChaveProd) + "|"

	If lEfetiva
		//Para o produto que iniciou a desfazer, grava a chave para verificar se existir� loop no processo (multi-empresas)
		cChvCheck := cList
	ElseIf cChvCheck == cList
		::oDados:oDominio:interrompeCalculo(STR0186 + CHR(10) + I18N(STR0189, {RTrim(cChvCheck), cPrdLoop})) //"ESTRUTURA COM RECURSIVIDADE! Verifique o cadastro das estruturas." # "Desfazendo explos�es de estruturas. Chave: #1[CHAVE]#. Produtos: #2[PROD]#."
	EndIf

	If ::oDados_Rastreio:oDados:existAList(cList)
		aChaves  := ::oDados_Rastreio:getDocsComponente(cList)
		If aChaves == Nil
			aChaves := {}
		EndIf
		nTotal := Len(aChaves)
		If nTotal > 0 .And. slLogR2
			//STR0133 - "Desfazendo explos�es de rastreabilidade do produto '"
			//STR0132 - "' e per�odo '"
			::oDados:oLogs:log(STR0133 + AllTrim(cChaveProd) + STR0132 + cValToChar(nPeriodo) + "'.", "R2")
		EndIf
		For nIndex := 1 to nTotal
			lError := .F.
			aDados := ::oDados_Rastreio:oDados:getItemAList(cList, aChaves[nIndex], @lError)
			If !lError .and. !Empty(aDados)
				If !Empty(aDados[ADADOS_POS_DOCFILHO])
					::deletaRastreios(cFilAux, cList, aDados[ADADOS_POS_DOCFILHO], nPeriodo, aDados[ADADOS_POS_COMP_EXPL_ESTRUT], aDados[ADADOS_POS_TIPOPAI], aDados[ADADOS_POS_COMPONENTE], aDados[ADADOS_POS_DOCPAI], .F., cChvCheck, lEfetiva, cPrdLoop)
					If lEfetiva .And. !("|TRANF" $ "|" + aDados[ADADOS_POS_DOCFILHO])
						aDados[ADADOS_POS_DOCFILHO] := ""
					EndIf
				EndIf

				If lEfetiva
					aDados[ADADOS_POS_CONSUMO_ESTOQUE] := 0
					aDados[ADADOS_POS_NECESSIDADE    ] := Iif(aDados[ADADOS_POS_NEC_ORIGINAL] < 0, 0, aDados[ADADOS_POS_NEC_ORIGINAL])
					::oDados_Rastreio:oDados:setItemAList(cList, aChaves[nIndex], aDados)
				EndIf
			EndIf
		Next
	EndIf

	aSize(aDados, 0)
	aDados := Nil

Return

/*/{Protheus.doc} deletaRastreios
Exclui Rastreios relacionados ao cDocPai
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux     , caracter, c�digo da filial para processamento
@param 02 - cList       , caracter, c�digo da lista: produto + chr(13) + per�odo
@param 03 - cChave      , caracter, c�digo do documento Pai + chr(13) + TRT
@param 04 - nPeriodo    , n�mero  , n�mero do per�odo relacionado
@param 05 - aComponentes, array   , componentes referente explos�o na estrutura
@param 06 - cTipoPai    , caracter, tipo da demanda do produto pai
@param 07 - cProdPai    , caracter, c�digo do produto pai
@param 08 - cDocPai     , caracter, c�digo do documento pai
@param 09 - lRecursiva  , l�gico  , Indica chamada recursiva. N�o executa m�todo gravaSaidaEstrutura com qtd negativa.
@param 10 - cChvCheck   , caracter, chave do registro que iniciou a desfazer o c�lculo.
@param 11 - lEfetiva    , l�gico  , indica se ir� efetivar as dele��es, ou se est� apenas validando recursividade.
@param 12 - cPrdLoop    , caracter, string com os c�digos de produtos concatenados. Utilizado para msg de erro em caso de recursividade.
/*/
METHOD deletaRastreios(cFilAux, cList, cChave, nPeriodo, aComponentes, cTipoPai, cProdPai, cDocPai,;
                       lRecursiva, cChvCheck, lEfetiva, cPrdLoop) CLASS MrpDominio_Rastreio

	Local aDados      := {}
	Local aAuxComp    := {}
	Local cComponente := ""
	Local cChvLock    := ""
	Local cListAux    := ""
	Local cListRec    := ""
	Local cChaveAux   := ""
	Local cChaveMAT   := ""
	Local cChaveProd  := ""
	Local cDocAgl     := ""
	Local cIDOpc      := ""
	Local cProduto    := ""
	Local cRevAtuPai  := ""
	Local dLeadTime   := Nil
	Local nIndex      := 0
	Local nOldNec     := 0
	Local nPerLead    := 0
	Local nQtdDel     := 0
	Local nSaldo      := 0
	Local nTotal      := 0
	Local lError      := .F.

	Default aComponentes := ::oDados_Rastreio:getCmpDocPai(cList, cChave)

	nTotal := If(aComponentes == Nil, 0, Len(aComponentes))

	If slLogR3 == Nil
		slLogR3 := ::oDados:oLogs:logValido("R3")
	EndIf

	If slLog7 == Nil
		slLog7 := ::oDados:oLogs:logValido("7")
	EndIf

	If nTotal > 0 .And. slLogR3
		//STR0134 - "Deletando rastreios da lista (Produto e Serie) '"
		//STR0135 - "' e chave (Documento e TRT)'"
		::oDados:oLogs:log(STR0134 + StrTran(cList, chr(13), " ") + STR0135 + cChave + "'.", "R3")
	EndIf

	For nIndex := 1 to nTotal
		lError      := .F.
		aDados      := {}
		cComponente := aComponentes[nIndex]                  //cComponente + chr(13) + cValToChar(nPeriodo) + chr(13) + cTRT + chr(13) + cChvSubst
		aAuxComp    := Strtokarr2(cComponente, chr(13), .T.)
		cListAux    := cFilAux + aAuxComp[1] + chr(13) + aAuxComp[2]
		cChaveAux   := cChave + chr(13) + aAuxComp[3] + chr(13) + aAuxComp[4]
		aDados      := ::oDados_Rastreio:oDados:getItemAList(cListAux, cChaveAux, @lError)
		cDocAgl     := ""
		If lError //Verifica se existe documento aglutinado
			cDocAgl := ::oDados:oDominio:oAglutina:retornaDocAglutinado(cFilAux, nPeriodo, aAuxComp[1], {cTipoPai, cDocPai, cProdPai}, aAuxComp[3])
			If !Empty(cDocAgl)
				lError    := .F.
				cChaveAux := cDocAgl + chr(13) + aAuxComp[3] + chr(13) + aAuxComp[4]
				aDados    := ::oDados_Rastreio:oDados:getItemAList(cListAux, cChaveAux, @lError)
			EndIf
		EndIf
		If !lError
			cChvLock   := "dados_" + aDados[ADADOS_POS_DOCPAI];
					               + aDados[ADADOS_POS_COMPONENTE];
								   + aDados[ADADOS_POS_ID_OPCIONAL];
					               + aDados[ADADOS_POS_TRT]
			aSize(aDados, 0)
			::oDados_Rastreio:oDados:Lock(cChvLock)
			aDados     := ::oDados_Rastreio:oDados:getItemAList(cListAux, cChaveAux, @lError)
			If !lError
				cProduto   := aDados[ADADOS_POS_COMPONENTE]
				nPeriodo   := aDados[ADADOS_POS_PERIODO]
				cIDOpc     := aDados[ADADOS_POS_ID_OPCIONAL]
				cChaveMAT  := DtoS(::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + Iif(cProduto == Nil, "",cProduto + Iif(Empty(cIDOpc), "","|" + cIDOpc))
				nOldNec    := aDados[ADADOS_POS_NECESSIDADE]
				cRevAtuPai := aDados[ADADOS_POS_REVISAO]
				cChaveProd := cFilAux + aDados[ADADOS_POS_COMPONENTE] + Iif(cProduto == Nil, "",cProduto + Iif(Empty(cIDOpc), "","|" + cIDOpc))

				//Desfaz Substitui��es Matriz
				nSaldo     := ::oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_SALDO")

				If Self:oDados:oDominio:oMultiEmp:utilizaMultiEmpresa() .And.;
				   !Empty(cChvCheck) .And. cChvCheck == cFilAux + cProduto + chr(13) + cValToChar(nPeriodo)
					::oDados:oDominio:interrompeCalculo(STR0186 + CHR(10) + I18N(STR0189, {RTrim(cChvCheck), cPrdLoop + RTrim(cFilAux + cProduto) + "|"})) //"ESTRUTURA COM RECURSIVIDADE! Verifique o cadastro das estruturas." # "Desfazendo explos�es de estruturas. Chave: #1[CHAVE]#. Produtos: #2[PROD]#."
				EndIf

				If lEfetiva
					::oAlternativo:desfazSubstituicoes(cFilAux, cProduto, nSaldo, nPeriodo)
				EndIf

				If lEfetiva
					If Empty(cDocAgl)
						nQtdDel := nOldNec
					Else
						nQtdDel := ::oDados:oDominio:oAglutina:deletaAglutinado(cFilAux, "4", cProduto, nPeriodo, {cTipoPai, cDocPai, cProdPai}, aAuxComp[3])
						nQtdDel := IIf(nQtdDel <= 0, nOldNec, nQtdDel)
					EndIf
				EndIf

				//Calcula LeadTime
				nPerLead  := nPeriodo
				dLeadTime := ::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
				::oDados:oDominio:oLeadTime:aplicar(cFilAux, cFilAux + cProduto, @nPerLead, @dLeadTime)  //Aplica o Lead Time do produto

				//Desfaz Explos�o Matriz - Explosao negativa da estrutura: desfaz explos�es anteriores em caso de reprocessamento de alternativos ou fantasmas
				If !lRecursiva .And. lEfetiva
					::oDados:gravaSaidaEstrutura(cFilAux, ::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), cProduto, IIf(Empty(cDocAgl), -aDados[ADADOS_POS_NEC_ORIGINAL], -nQtdDel), nPeriodo, cIDOpc)
				EndIf
				If slLog7
					::oDados:oLogs:log(STR0036 + AllTrim(cChaveProd) + STR0026 + cValToChar(nPeriodo) + "/X" + STR0037 + cValToChar(IIf(Empty(cDocAgl), aDados[ADADOS_POS_NEC_ORIGINAL], nQtdDel)), "7") //"Explosao Estrutura (negativa):" + " - Periodos: " + " - Necessidade anterior: "
				EndIf

				//Recursividade para exclus�o de rastreios filhos
				If !Empty(aDados[ADADOS_POS_DOCFILHO])
					If lEfetiva
						::oDados:oDominio:explodirEstrutura(cFilAux, cProduto, -nQtdDel, nPerLead, nPeriodo, .F., cIDOpc, , cRevAtuPai)
					EndIf

					cListRec := cFilAux + aDados[ADADOS_POS_COMPONENTE] + chr(13) + cValToChar(aDados[ADADOS_POS_PERIODO])
					::deletaRastreios(cFilAux, cListRec, aDados[ADADOS_POS_DOCFILHO], nPeriodo, aDados[ADADOS_POS_COMP_EXPL_ESTRUT], aDados[ADADOS_POS_TIPOPAI], aDados[ADADOS_POS_COMPONENTE], aDados[ADADOS_POS_DOCPAI], .T., cChvCheck, lEfetiva, cPrdLoop + RTrim(cFilAux + cProduto) + "|")
				EndIf

				If Self:oDados:oParametros["lEventLog"] .And. lEfetiva
					Self:oDados:oDominio:oEventos:loga("004", cComponente, ::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), {AllTrim(Left(cList, snTamCod)), -nQtdDel, ::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), aDados[ADADOS_POS_DOCPAI], "", "", aDados[ADADOS_POS_TRT]}, cFilAux)
				EndIf

				If aDados[ADADOS_POS_TRANSFERENCIA_ENTRADA] > 0
					::oDados:oDominio:oMultiEmp:desfazEntradaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveMAT, aDados, cChvCheck, lEfetiva, cPrdLoop + RTrim(cFilAux + cProduto) + "|")
				EndIf

				If lEfetiva
					If Empty(cDocAgl)
						::oDados_Rastreio:oDados:delItemAList(cListAux, cChaveAux)
					Else
						aDados[ADADOS_POS_NEC_ORIGINAL] -= nQtdDel

						If aDados[ADADOS_POS_NEC_ORIGINAL] <= 0
							::oDados_Rastreio:oDados:delItemAList(cListAux, cChaveAux)
						Else
							aDados[ADADOS_POS_NECESSIDADE] -= nQtdDel
							aDados[ADADOS_POS_NECESSIDADE] := IIf(aDados[ADADOS_POS_NEC_ORIGINAL] < 0, 0, aDados[ADADOS_POS_NEC_ORIGINAL])
							::oDados_Rastreio:oDados:setItemAList(cListAux, cChaveAux, aDados)
						EndIf
					EndIf
				EndIf
			EndIf
			::oDados_Rastreio:oDados:unLock(cChvLock)

			aSize(aDados, 0)

		ElseIf lEfetiva
			cProduto := aAuxComp[1]
			::oDados:oDominio:oAglutina:deletaAglutinado(cFilAux, "4", cProduto, nPeriodo, {cTipoPai, cDocPai, cProdPai}, aAuxComp[3])
		EndIf
	Next

	aDados := Nil

	aSize(aComponentes, 0)
	aComponentes := Nil

Return

/*/{Protheus.doc} getPosicao
Retorna a posi��o do campo na tabela
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cCampo, caracter, string com o nome do campo relacionado aos dados de rastreabilidade
@Return nReturn, n�mero, posi��o padr�o do registro no array de dados
/*/
METHOD getPosicao(cCampo) CLASS MrpDominio_Rastreio
Return ::oDados_Rastreio:getPosicao(cCampo)

/*/{Protheus.doc} destruir
Destroi os objetos e variaveis desta classe
@author brunno.costa
@since 15/08/2019
@version 1.0
/*/
METHOD destruir() CLASS MrpDominio_Rastreio
Return ::oDados_Rastreio:oDados:destruir()

/*/{Protheus.doc} politicaDeEstoque
Realiza tratamentos de pol�tica de estoque
@author brunno.costa
@since 15/08/2019
@version 1.0
@param 01 - cFilAux , caracter, c�digo da filial para processamento
@param 02 - cProduto, caracter, c�digo do produto para tratamento
@param 03 - nPeriodo, n�mero  , per�odo para an�lise
@param 04 - nEstoque, n�mero  , saldo inicial do produto
@param 05 - nSaidas , n�mero  , quantidade de sa�das do per�odo
@param 06 - nSldIni , n�mero  , Saldo inicial do produto sem considerar as entradas.
@param 07 - cIdOpc  , caracter, ID de Opcionais do produto
@return nEstoque, n�mero, retorna o saldo inicial para an�lise com as tratativas de estoque
/*/
METHOD politicaDeEstoque(cFilAux, cProduto, nPeriodo, nEstoque, nSaidas, nSldIni, cIdOpc) CLASS MrpDominio_Rastreio
	Local aDados      := {}
	Local aAreaPRD    := {}
	Local cChave      := ""
	Local cChaveProd  := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	Local lAtual      := cChaveProd == ::oDados:oProdutos:cCurrentKey
	Local lCalcES     := .F.  //Define se o estoque de seguran�a j� foi calculado para o produto
	Local lPrdOpc     := .F.
	Local lOpcValido  := .T.
	Local nEstSeg     := 0
	Local nPontoPed   := 0
	Local nQtdEst     := nEstoque //Vari�vel de controle de estoque - estoque de seguran�a para c�lculo do ponto de pedido
	Local nPerUtil    := ::oDados:oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)

	Default nSldIni   := 0

	If ::oParametros['lEstoqueSeguranca'] .Or. ::oParametros['lPontoPedido']
		If !lAtual
			aAreaPRD := Self:oDados:retornaArea("PRD")
		EndIf

		aDados    := Self:oDados:retornaCampo("PRD", 1, cChaveProd, {"PRD_ESTSEG","PRD_PPED","PRD_CALCES"}, .F., lAtual, , , , , .T. /*lVarios*/)
		nEstSeg   := aDados[1]
		lCalcES   := aDados[3]
		If ::oParametros['lPontoPedido']
			nPontoPed := aDados[2]
		EndIf

		aSize(aDados, 0)

		If !lAtual
			Self:oDados:setaArea(aAreaPRD)
		EndIf

		If Empty(cIdOpc) .And. (nEstSeg > 0 .Or. nPontoPed > 0)
			lPrdOpc := Self:oDados:oOpcionais:getFlag("PRD_COM_OPC" + CHR(10) + cFilAux + cProduto)
			If lPrdOpc != Nil .And. lPrdOpc == .T.
				//Est� calculando o produto sem opcionais (Empty(cIdOpc)), e este produto possui opcionais em sua estrutura.
				//N�o ir� calcular o Ponto de Pedido e Estoque de seguran�a para este produto, pois n�o foi definido o opcional
				//default do produto. Caso tenha sido definido opcional default no produto, as quantidades de
				//estoque de seguran�a e ponto de pedido j� ser�o atribu�das para o produto + opcional (cIdOpc diferente de vazio).
				lOpcValido := .F.
			EndIf
		EndIf
	EndIf

	If nPerUtil == nPeriodo
		//Gera necessidade de saldo inicial negativo se necess�rio.
		If nEstoque+nEstSeg < 0
			cChave := "ESTNEG_" + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)

			::incluiNecessidade(cFilAux, "ESTNEG", cChave, cProduto, cIdOpc, "", Abs(nEstoque+nEstSeg), nPeriodo)
		EndIf

		If nEstSeg > 0
			nEstoque += nEstSeg
			If ::oParametros['lEstoqueSeguranca']
				nQtdEst -= nEstSeg
				//Gera registro de rastreabilidade referente Estoque de Seguran�a
				IF lCalcES == "F"
					If lOpcValido
						cChave := chaveESeg(cProduto, nPeriodo, .F.)
						::incluiNecessidade(cFilAux, Left(scTextESeg, 10), cChave, cProduto, cIdOpc, "", nEstSeg, nPeriodo,,,,,,,,,nEstoque + nEstSeg)//"Est.Seg."
					EndIf
					Self:oDados:gravaCampo("PRD", 1, , "PRD_CALCES", "T", .T., .T.)
				EndIf
			EndIf
			nQtdEst += nEstSeg
		EndIf

	EndIf

	//Gera registro de rastreabilidade referente Ponto de Pedido
	If ::oParametros['lPontoPedido'] .And. nPontoPed > 0 .And. lOpcValido
		If nPontoPed > (nQtdEst - nSaidas)
			cChave := chavePPed(cProduto, nPeriodo, .F.)
			::incluiNecessidade(cFilAux, Left(scTextPPed, 10), cChave, cProduto, cIdOpc, "", (nPontoPed - (nQtdEst - nSaidas)), nPeriodo)//"Ponto Ped."

			//Gera Evento 009 - Saldo em estoque menor ou igual ao ponto de pedido
			If ::oDados:oParametros["lEventLog"]
				::oDados:oDominio:oEventos:loga("009", cProduto, ::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), {nPontoPed, (nEstoque - nSaidas), ::oDados:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), "HWA"}, cFilAux)
			EndIf
		EndIf
	EndIf

	If nEstoque < 0
		nEstoque := 0
	EndIf

Return nEstoque

/*/{Protheus.doc} todosAltConsumidos
Identifica se todos os demais alternativos foram consumidos
@author brunno.costa
@since 15/08/2019
@version 1.0
@param 01 - cFilAux , caracter, c�digo da filial para processamento
@param 02 - cProdOri, caracter, c�digo do produto original
@param 03 - cExcecao, caracter, c�digo do produto alternativo atual, considerado como exce��o na regra
@param 04 - nPeriodo, n�mero  , per�odo relacionado
@return lReturn, l�gico, indica se todos os demais alternativos do produto original foram consumidos
/*/
METHOD todosAltConsumidos(cFilAux, cProdOri, cExcecao, nPeriodo) CLASS MrpDominio_Rastreio

	Local aChaves    := {}
	Local aAlteDeman := {} //C�digos dos Alternativos da Substitui��o
	Local aRastreio  := {}
	Local cAlternativo
	Local cList      := ""
	Local cOrigDeman := "KEY_" + cFilAux + AllTrim(cProdOri) + "_" + cValToChar(nPeriodo)//Original + Periodo
	Local cPrimeiro
	Local nInd
	Local nIndAlt
	Local lReturn    := .T.
	Local lError     := .F.

	//Atualiza controle de destinos de substituicao do produto origem
	aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)

	//Recupera registros das substituicoes
	For nInd := 1 to Len(aAlteDeman)
		cAlternativo := aAlteDeman[nInd][1]

		If nInd == 1
			cPrimeiro := cAlternativo
		EndIf

		//Desconsidera alternativo referente produto atual
		If AllTrim(cAlternativo) == AllTrim(cExcecao)
			Loop
		EndIf

		cList := cFilAux + cAlternativo + chr(13) + cValToChar(nPeriodo)
		aChaves := ::oDados_Rastreio:getDocsComponente(cList)
		For nIndAlt := 1 to Len(aChaves)
			aRastreio := {}
			aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, aChaves[nIndAlt], @lError)

			If !::oDados:foiCalculado(cFilAux + cAlternativo, nPeriodo)
				lReturn := .F.
				Exit

			ElseIf (aRastreio[ADADOS_POS_QTD_ESTOQUE] == (aRastreio[ADADOS_POS_CONSUMO_ESTOQUE] + aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]));
			   .and. aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] != aRastreio[ADADOS_POS_CONSUMO_SUBSTITU]
				lReturn := .F.
				Exit

			EndIf
		Next

		//Verifica se foi calculado
		If !lReturn
			Exit
		EndIf

	Next

	aSize(aChaves, 0)
	aChaves := Nil

	aSize(aAlteDeman, 0)
	aAlteDeman := Nil

	aSize(aRastreio, 0)
	aRastreio := Nil

Return lReturn

/*/{Protheus.doc} baixaPorOP
Percorre Rastreabilidade do Componente
Atribui baixas de estoque ao Rastreio
Prioridade de consumo de estoque: OP's (menor -> maior) e por �ltimo Ponto Pedido/Estoque de Seguran�a

@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cFilAux    , caracter, filial para processamento
@param 02 - cComponente, caracter, c�digo do componente para an�lise
@param 03 - cIDOpc     , caracter, c�digo do ID do Opcional
@param 04 - nEstoque   , n�mero  , quantidade em estoque
@param 05 - nPeriodo   , n�mero  , per�odo para an�lise
@param 06 - lAltReg1   , logico  , retorna por refer�ncia indicando se este produto � substituto (alternativo)
@param 07 - nSaidas    , n�mero  , quantidade de sa�das do per�odo
@param 08 - nSldIni    , n�mero  , Saldo inicial do produto
@return aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
                               {{1 - Id Rastreabilidade,;
                                 2 - Documento Pai,;
                                 3 - Quantidade Necessidade,;
                                 4 - Quantidade Estoque,;
                                 5 - Quantidade Baixa Estoque,;
                                 6 - Quantidade Substitui��o
                                 7 - Array com as quebras de pol�ticas de estoque},...}
/*/
METHOD baixaPorOP(cFilAux, cComponente, cIDOpc, nEstoque, nPeriodo, lAltReg1, nSaidas, nSldIni) CLASS MrpDominio_Rastreio

	Local aBaixaPorOP := {}
	Local aChaves     := {}
	Local aDados      := {}
	Local aDadosChvs  := {}
	Local nContador   := 0
	Local aRastreio   := {}
	Local aNames      := {}
	Local cChave      := ""
	Local cList       := cFilAux + cComponente + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + cValToChar(nPeriodo)
	Local cListOrig   := ""
	Local lError      := .F.
	Local lSubtrai    := .F.
	Local nIndex      := 0
	Local nSubstitui  := 0
	Local nTotal      := 0
	Local oSldSubst

	Default nSldIni    := 0

	//Aplica o rastreio relacionado a pol�ticas de estoque
	nEstoque := ::politicaDeEstoque(cFilAux, cComponente, nPeriodo, nEstoque, nSaidas, nSldIni, cIdOpc)

	//Verifica chaves do Componente
	aChaves  := ::oDados_Rastreio:getDocsComponente(cList)
	nTotal   := Len(aChaves)

	//Recupera registros de rastreabilidade dos chaves
	For nIndex := 1 to nTotal
		lError    := .F.
		aDados    := {}
		cChave    := aChaves[nIndex]
		aDados    := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
		If !lError
			nContador++
            aAdd(aDadosChvs, {cChave, aDados, StrZero(nContador, 5)})
			cListOrig := ""
		EndIf
	Next

	//N�o existe chaves deste componente
	nTotal := Len(aDadosChvs)
	If nTotal == 0
		Return aBaixaPorOP
	EndIf

	//Atualiza Total de Registros V�lidos e Ordena por OP
	aDadosChvs := ::ordenaRastreio(aDadosChvs, .T.)

	oSldSubst    := JsonObject():New()
	//Percorre Registros de Rastreabilidade
	For nIndex := 1 to nTotal
		cChave                            := aDadosChvs[nIndex][1]
		aRastreio                         := aDadosChvs[nIndex][2]
		aRastreio[ADADOS_POS_QTD_ESTOQUE] := nEstoque
		lSubtrai                          := .F.

		//N�o recalcula registro de necessidade para Ponto Pedido e Estoque de Seguran�a
		If (AllTrim(aRastreio[ADADOS_POS_TIPOPAI]) $ "|" + scTextPPed + "|1|") //"Ponto Ped." | "PMP"

			// Se for PMP, adiciona o saldo em estoque para ser consumido por outros rastreios.
			If aRastreio[ADADOS_POS_TIPOPAI] == "1"
				nEstoque += aRastreio[ADADOS_POS_NEC_ORIGINAL]
			EndIf

			//Monta array para retorno
			aAdd(aBaixaPorOP, ::montaBaixaPorOP(cChave                                     ,;
			                                    aRastreio[ADADOS_POS_DOCPAI]               ,;
			                                    aRastreio[ADADOS_POS_NECESSIDADE]          ,;
			                                    aRastreio[ADADOS_POS_QTD_ESTOQUE]          ,;
			                                    aRastreio[ADADOS_POS_CONSUMO_ESTOQUE]      ,;
			                                    0                                          ,;
			                                    aRastreio[ADADOS_POS_QUEBRAS_QUANTIDADE]   ,;
			                                    aRastreio[ADADOS_POS_TIPOPAI]              ,;
			                                    aRastreio[ADADOS_POS_NEC_ORIGINAL]         ,;
			                                    aRastreio[ADADOS_POS_REGRA_ALTERNATIVO]    ,;
			                                    aRastreio[ADADOS_POS_CHAVE_SUBSTITUICAO]   ,;
			                                    aRastreio[ADADOS_POS_TRANSFERENCIA_ENTRADA],;
			                                    aRastreio[ADADOS_POS_TRANSFERENCIA_SAIDA]  ,;
			                                    aRastreio[ADADOS_POS_DOCFILHO]             ,;
			                                    aRastreio[ADADOS_POS_RASTRO_AGLUTINACAO]   ))

		Else
			lError     := .F.
			If AllTrim(aRastreio[ADADOS_POS_TIPOPAI]) != scTextESeg //Est.Seg.
				nSubstitui := aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]

				//Acrescenta estoque referente estrutura negativa
				nEstoque   -= Iif(aRastreio[ADADOS_POS_NEC_ORIGINAL] < 0, aRastreio[ADADOS_POS_NEC_ORIGINAL], 0)

				//Recupera Quantidade da Substitui��o no Produto Original
				If !Empty(aRastreio[ADADOS_POS_CHAVE_SUBSTITUICAO])
					If (aRastreio[ADADOS_POS_REGRA_ALTERNATIVO] $ "|2|3|")
						::avaliaSubstOriginal(cFilAux, @aRastreio, @nEstoque, @nSubstitui, @oSldSubst)
					Else
						lAltReg1 := .T.
					EndIf
				Else
					nEstoque += nSubstitui
					lSubtrai := .T.
				EndIf
			EndIf

			//Atualiza Baixas de Estoque - Regras que avaliam estoque do produto original
			If aRastreio[ADADOS_POS_NEC_ORIGINAL] > 0;
			   .And. aRastreio[ADADOS_POS_REGRA_ALTERNATIVO] != "3";
			   .And. aRastreio[ADADOS_POS_TIPOPAI] != "AGL"

				If nEstoque >= aRastreio[ADADOS_POS_NEC_ORIGINAL] .And. nEstoque > 0
					lSubtrai := .F.
					nEstoque -= aRastreio[ADADOS_POS_NEC_ORIGINAL]
					aRastreio[ADADOS_POS_CONSUMO_ESTOQUE] := aRastreio[ADADOS_POS_NEC_ORIGINAL]

				ElseIf (aRastreio[ADADOS_POS_CONSUMO_ESTOQUE] + nEstoque) <= aRastreio[ADADOS_POS_QTD_ESTOQUE]
					aRastreio[ADADOS_POS_CONSUMO_ESTOQUE] += nEstoque
					aRastreio[ADADOS_POS_NECESSIDADE]     := aRastreio[ADADOS_POS_NEC_ORIGINAL] -nEstoque
					nEstoque := 0
					lSubtrai := .F.

				EndIf
			EndIf

			//Recalcula Necessidade
			aRastreio[ADADOS_POS_NECESSIDADE] := Iif(aRastreio[ADADOS_POS_NEC_ORIGINAL] < 0, 0, aRastreio[ADADOS_POS_NEC_ORIGINAL])
			aRastreio[ADADOS_POS_NECESSIDADE] -= aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]
			If aRastreio[ADADOS_POS_REGRA_ALTERNATIVO] != "3" .OR. nSubstitui < 0
				aRastreio[ADADOS_POS_NECESSIDADE] -= aRastreio[ADADOS_POS_QTD_ESTOQUE]

				//Desconta necessidade original negativa
				If aRastreio[ADADOS_POS_NECESSIDADE] > 0 .And. aRastreio[ADADOS_POS_NEC_ORIGINAL] < 0
					aRastreio[ADADOS_POS_NECESSIDADE] += aRastreio[ADADOS_POS_NEC_ORIGINAL]
				EndIf
			EndIf
			aRastreio[ADADOS_POS_NECESSIDADE] := Iif(aRastreio[ADADOS_POS_NECESSIDADE] < 0, 0, aRastreio[ADADOS_POS_NECESSIDADE])

			//Monta array para retorno
			aAdd(aBaixaPorOP, ::montaBaixaPorOP(cChave                                     ,;
			                                    aRastreio[ADADOS_POS_DOCPAI]               ,;
			                                    aRastreio[ADADOS_POS_NECESSIDADE]          ,;
			                                    aRastreio[ADADOS_POS_QTD_ESTOQUE]          ,;
			                                    aRastreio[ADADOS_POS_CONSUMO_ESTOQUE]      ,;
			                                    nSubstitui                                 ,;
			                                    aRastreio[ADADOS_POS_QUEBRAS_QUANTIDADE]   ,;
			                                    aRastreio[ADADOS_POS_TIPOPAI]              ,;
			                                    aRastreio[ADADOS_POS_NEC_ORIGINAL]         ,;
			                                    aRastreio[ADADOS_POS_REGRA_ALTERNATIVO]    ,;
			                                    aRastreio[ADADOS_POS_CHAVE_SUBSTITUICAO]   ,;
			                                    aRastreio[ADADOS_POS_TRANSFERENCIA_ENTRADA],;
			                                    aRastreio[ADADOS_POS_TRANSFERENCIA_SAIDA]  ,;
			                                    aRastreio[ADADOS_POS_DOCFILHO]             ,;
			                                    aRastreio[ADADOS_POS_RASTRO_AGLUTINACAO]   ))

			//Atualiza registro global
			::oDados_Rastreio:oDados:createAList(cList)
			::oDados_Rastreio:oDados:setItemAList(cList, cChave, aRastreio, @lError)

			//Verifica a necessidade de descontar a quantidade de subistitui��o do estoque
			If lSubtrai .And. aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] > 0 .And. Empty(aRastreio[ADADOS_POS_CHAVE_SUBSTITUICAO])
				nEstoque -= nSubstitui
			EndIf
		EndIf

	Next

	For nIndex := 1 to Len(aDadosChvs)
		aSize(aDadosChvs[nIndex][2], 0)
		aDadosChvs[nIndex][2] := Nil

		aSize(aDadosChvs[nIndex], 0)
		aDadosChvs[nIndex] := Nil
	Next
	aSize(aDadosChvs, 0)
	aDadosChvs := Nil

	aNames := oSldSubst:GetNames()
	nTotal := Len(aNames)
	For nIndex := 1 To nTotal
		oSldSubst[aNames[nIndex]] := Nil
	Next nIndex
	aSize(aNames, 0)
	aNames := Nil

	FreeObj(oSldSubst)
	oSldSubst := Nil

	aSize(aRastreio, 0)
	aRastreio := Nil

Return aBaixaPorOP

/*/{Protheus.doc} montaBaixaPorOP
Monta o array com os dados para registrar no aBaixaPorOP

@author lucas.franca
@since 09/12/2020
@version P12
@param 01 cChave    , Character, Chave do registro
@param 02 cDocPai   , Character, Documento pai do registro
@param 03 nNecess   , Numeric  , Quantidade de necessidade
@param 04 nQtdEst   , Numeric  , Quantidade de estoque
@param 05 nConsumo  , Numeric  , Quantidade de consumo de estoque
@param 06 nSubstitui, Numeric  , Quantidade de substitui��o
@param 07 aQuebras  , Array    , Array com as quebras por lote
@param 08 cTipoPai  , Character, Tipo do documento pai
@param 09 nNecOrigem, Numeric  , Necessidade original
@param 10 cRegraAlt , Character, Regra de consumo dos alternativos
@param 11 cChaveSub , Character, Chave de substitui��o
@param 12 nQtrEnt   , Numeric  , Quantidade de transfer�ncia de entrada
@param 13 nQtrSai   , Numeric  , Quantidade de transfer�ncia de sa�da
@param 14 cDocFilho , Character, Documento filho registro
@param 15 aRastroAgl, Array    , Array com as informa��es de rastreio da aglutina��o (TIPO_PAI=="AGL")
@return aBaixa, Array, Array com os dados do aBaixaPorOP
/*/
METHOD montaBaixaPorOP(cChave, cDocPai, nNecess, nQtdEst, nConsumo, nSubstitui, aQuebras, cTipoPai, nNecOrigem, cRegraAlt, cChaveSub, nQtrEnt, nQtrSai, cDocFilho, aRastroAgl, aGravaAgl) CLASS MrpDominio_Rastreio
	Local aBaixa := Array(ABAIXA_SIZE)

	Default aGravaAgl  := {.F., ""}
	Default aRastroAgl := {0,""}
	Default nQtrEnt    := 0
	Default nQtrSai    := 0
	Default cDocFilho  := ""

	aBaixa[ABAIXA_POS_CHAVE                ] := cChave
	aBaixa[ABAIXA_POS_DOCPAI               ] := cDocPai
	aBaixa[ABAIXA_POS_NECESSIDADE          ] := nNecess
	aBaixa[ABAIXA_POS_QTD_ESTOQUE          ] := nQtdEst
	aBaixa[ABAIXA_POS_CONSUMO_ESTOQUE      ] := nConsumo
	aBaixa[ABAIXA_POS_QTD_SUBSTITUICAO     ] := nSubstitui
	aBaixa[ABAIXA_POS_QUEBRAS_QUANTIDADE   ] := aQuebras
	aBaixa[ABAIXA_POS_TIPO_PAI             ] := cTipoPai
	aBaixa[ABAIXA_POS_NEC_ORIG             ] := nNecOrigem
	aBaixa[ABAIXA_POS_REGRA_ALT            ] := cRegraAlt
	aBaixa[ABAIXA_POS_CHAVE_SUBST          ] := cChaveSub
	aBaixa[ABAIXA_POS_TRANSFERENCIA_ENTRADA] := nQtrEnt
	aBaixa[ABAIXA_POS_TRANSFERENCIA_SAIDA  ] := nQtrSai
	aBaixa[ABAIXA_POS_DOCFILHO             ] := cDocFilho
	aBaixa[ABAIXA_POS_RASTRO_AGLUTINACAO   ] := aRastroAgl
	aBaixa[ABAIXA_POS_DOC_AGLUTINADOR      ] := aGravaAgl
Return aBaixa

/*/{Protheus.doc} ordenaRastreio
Faz a ordena��o do array de rastreabilidade

@author lucas.franca
@since 10/12/2020
@version P12
@param aRastreio , Array, Array com os dados de rastreabilidade
@param lContador , Logic, Indica se deve considerar o contador na ordena��o
@return aRastreio, Array, Array com os dados de rastreabilidade ordenado
/*/
METHOD ordenaRastreio(aRastreio, lContador) CLASS MrpDominio_Rastreio
	Local cDocs := "|0|2|3|4|5|9|OP|"
	aRastreio := aSort(aRastreio, , , {|x,y| Iif( x[2][ADADOS_POS_TIPOPAI     ] == "AGL", "0", "1");
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == "1", "0", "1");
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == scTextPPed, "2", "0"); //Ponto Ped.
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == "ESTNEG", "0", "1");
	                                       + Iif( x[2][ADADOS_POS_NEC_ORIGINAL] < 0, "0", "1");
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == scTextESeg, "0", "1"); //Est.Seg.
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == "Pr�-OP", "0", "1");
	                                       + Iif( "|"+AllTrim(x[2][ADADOS_POS_TIPOPAI])+"|" $ cDocs, "0", "1");
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == "TRANF_ES", "0", "1");
	                                       + Iif( x[2][ADADOS_POS_TIPOPAI     ] == "TRANF_PR", "1", "0");
	                                       + Iif( x[2][ADADOS_POS_TRANSFERENCIA_ENTRADA] <> 0, "1", "0");
	                                       + Iif( x[2][ADADOS_POS_TRANSFERENCIA_ENTRADA] <> 0 .And. x[2][ADADOS_POS_QTD_SUBSTITUICAO] <> 0, "0", "1");
	                                       + PadL(x[2][ADADOS_POS_CHAVE_SUBSTITUICAO], 130);
	                                       + Iif( x[2][ADADOS_POS_TRANSFERENCIA_ENTRADA] <> 0, "1", "0");
	                                       + PadL(x[2][ADADOS_POS_DOCPAI], 100);
	                                       + Iif(lContador, x[3], "0");
	                                       <;
	                                         Iif( y[2][ADADOS_POS_TIPOPAI     ] == "AGL", "0", "1");
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == "1", "0", "1");
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == scTextPPed, "2", "0"); //Ponto Ped.
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == "ESTNEG", "0", "1");
	                                       + Iif( y[2][ADADOS_POS_NEC_ORIGINAL] < 0, "0", "1");
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == scTextESeg, "0", "1"); //Est.Seg.
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == "Pr�-OP", "0", "1");
	                                       + Iif( "|"+AllTrim(y[2][ADADOS_POS_TIPOPAI])+"|" $ cDocs, "0", "1");
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == "TRANF_ES", "0", "1");
	                                       + Iif( y[2][ADADOS_POS_TIPOPAI     ] == "TRANF_PR", "1", "0");
	                                       + Iif( y[2][ADADOS_POS_TRANSFERENCIA_ENTRADA] <> 0, "1", "0");
	                                       + Iif( y[2][ADADOS_POS_TRANSFERENCIA_ENTRADA] <> 0 .And. y[2][ADADOS_POS_QTD_SUBSTITUICAO] <> 0, "0", "1");
	                                       + PadL(y[2][ADADOS_POS_CHAVE_SUBSTITUICAO], 130);
	                                       + Iif( y[2][ADADOS_POS_TRANSFERENCIA_ENTRADA] <> 0, "1", "0");
	                                       + PadL(y[2][ADADOS_POS_DOCPAI], 100);
	                                       + Iif(lContador, y[3], "0") } )
Return aRastreio

/*/{Protheus.doc} avaliaSubstOriginal
Avalia e recupera a quantidade de substitui��o deste alternativo no produto original
@author brunno.costa
@since 15/08/2019
@version 1.0
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - aAlternati , array   , retorna por refer�ncia array com o registro de rastreabilidade referente produto alternativo availiado
@param 03 - nEstoque   , n�mero  , retorna por refer�ncia quantidade de estoque inicial deste produto alternativo
@param 04 - nSubstAlt  , n�mero  , retorna por refer�ncia quantidade substitu�da do produto original para este alternativo
@param 05 - oSldSubst  , objeto  , objeto Json que controla os saldos de substitui��o por produto + per�odo + alternativo
@param 06 - lForcaOrig , l�gico  , indica se for�a rec�lculo do produto original
@param 07 - aBaixaPorOP, array   , array aBaixasPorOP relacionado a opera��o
@param 08 - lAltReg1   , l�gico  , indica se refere-se a registro de produto alternativo com regra do tipo 1
@return, nDesfezAlt, n�mero, retorna a quantidade do produto alternativo que foi desfeita.
/*/
METHOD avaliaSubstOriginal(cFilAux, aAlternati, nEstoque, nSubstAlt, oSldSubst, lForcaOrig, aBaixaPorOP, lAltReg1) CLASS MrpDominio_Rastreio

	Local aOriginal    := {}
	Local aDadosSubs   := {}
	Local aListOrig    := StrTokArr(aAlternati[ADADOS_POS_CHAVE_SUBSTITUICAO], chr(13) )
	Local cAlternativo := aAlternati[ADADOS_POS_COMPONENTE]
	Local cChave       := ""
	Local cChaveSubs   := ""
	Local cChvLock     := ""
	Local cChvOrigem   := ""
	Local cChaveOri    := ""
	Local cChaveAlt    := ""
	Local cChvAltOri   := ""
	Local cListOrig    := aListOrig[1] + chr(13) + aListOrig[2]
	Local lAllAltCons  := .F.
	Local lError       := .F.
	Local nDesfazer    := 0
	Local nDesfazSub   := 0
	Local nDesfezAlt   := 0
	Local nFalta       := 0
	Local nFaltaOrig   := 0
	Local nLimite      := 0
	Local nPeriodo     := aAlternati[ADADOS_POS_PERIODO]
	Local nSubstIni    := nSubstAlt
	Local nSubstOrig   := 0
	Local lNewKey      := .F.

	Default lForcaOrig  := .F.
	Default aBaixaPorOP := {}
	Default lAltReg1    := .F.

	cChave   := aAlternati[ADADOS_POS_DOCPAI] + chr(13) + aAlternati[ADADOS_POS_TRT] + chr(13) + ""
	cChvLock := cListOrig + cChave

	::oDados_Rastreio:oDados:lock(cChvLock)
	aOriginal := ::oDados_Rastreio:oDados:getItemAList(cListOrig, cChave, @lError)

	If slLogR4 == Nil
		slLogR4 := ::oDados:oLogs:logValido("R4")
	EndIf
	If slLogRS == Nil
		slLogRS := ::oDados:oLogs:logValido("RS")
	EndIf

	If !lError

		If slLogR4
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstIni: " + cValToChar(nSubstIni), "R4")
		EndIf

		If Empty(aOriginal[ADADOS_POS_ID_OPCIONAL])
			cChaveOri := aOriginal[ADADOS_POS_COMPONENTE]
		Else
			cChaveOri := aOriginal[ADADOS_POS_COMPONENTE] + "|" + aOriginal[ADADOS_POS_ID_OPCIONAL]
		EndIf

		If Empty(aAlternati[ADADOS_POS_ID_OPCIONAL])
			cChaveAlt := aAlternati[ADADOS_POS_COMPONENTE]
		Else
			cChaveAlt := aAlternati[ADADOS_POS_COMPONENTE] + "|" + aAlternati[ADADOS_POS_ID_OPCIONAL]
		EndIf
		
		cChaveSubs := "KEY_" + cFilAux + AllTrim(cChaveOri) + "_" + cValToChar(nPeriodo) + "_" + AllTrim(cChaveAlt)
		If oSldSubst[cChaveSubs] == Nil
			aDadosSubs := ::oDados:oAlternativos:getItemAList("substituicoes_dados", cChaveSubs, @lError) //{1-cProduto, 2-cAlternativo, 3-nPeriodo, 4-nConsAlt, 5-nConsOrig, 6-cOrdem, 7-nLimiteAlt, 8-nLimiteOrig, 9-Qtd Transfer�ncia (ME)}
			lNewKey    := .T.
			//Remove do saldo de substitui��o as quantidades que utilizam transfer�ncia de estoque entre filiais.
			oSldSubst[cChaveSubs] := Abs(aDadosSubs[5] - aDadosSubs[9])
			aSize(aDadosSubs, 0)
		EndIf

		//Recupera Consumo Anterior (Sem a Substitui��o Atual)
		If nSubstAlt != 0
			nSubstOrig := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nSubstAlt, .T.)
			If slLogRS
				::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstOrig: " + cValToChar(nSubstOrig), "RS")
			EndIf
			If !lNewKey
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "oSldSubst[cChaveSubs]: " + cValToChar(oSldSubst[cChaveSubs]), "RS")
				EndIf
				
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "oSldSubst[cChaveSubs]: " + cValToChar(oSldSubst[cChaveSubs]), "RS")
				EndIf
			EndIf
		EndIf

		If aOriginal[ADADOS_POS_QTD_SUBSTITUICAO] > 0
			If (aOriginal[ADADOS_POS_QTD_SUBSTITUICAO] - aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]) > 0
				nFaltaOrig := aOriginal[ADADOS_POS_QTD_SUBSTITUICAO] - aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]
				cChvAltOri := RTrim(cChaveAlt)
				If aOriginal[ADADOS_POS_ALTERNATIVOS] != Nil .And. aOriginal[ADADOS_POS_ALTERNATIVOS]:HasProperty(cChvAltOri)
					//Verifica qual � a quantidade deste alternativo para o documento do produto original
					If aOriginal[ADADOS_POS_ALTERNATIVOS][cChvAltOri] < nFaltaOrig
						nFaltaOrig := aOriginal[ADADOS_POS_ALTERNATIVOS][cChvAltOri]
					EndIf
				EndIf
			EndIf

			//Recompoe Consumo Substitui��o Sem este Alternativo
			If slLogRS
				::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nFaltaOrig: " + cValToChar(nFaltaOrig), "RS")
				::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstOrig: " + cValToChar(nSubstOrig), "RS")
				::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
			EndIf
			aOriginal[ADADOS_POS_CONSUMO_SUBSTITU] += nSubstOrig
			aOriginal[ADADOS_POS_CONSUMO_SUBSTITU] := Iif(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU] < 0, 0, aOriginal[ADADOS_POS_CONSUMO_SUBSTITU])
			If slLogRS
				::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
			EndIf
		EndIf

		If slLogR4
			::oDados:oLogs:log("Avaliando a substituicao do Alternativo: " + RTrim(aAlternati[ADADOS_POS_COMPONENTE]) +;
			                   " - Original " + RTrim(aOriginal[ADADOS_POS_COMPONENTE]) + "."                         +;
			                   " Documento: " + aOriginal[ADADOS_POS_DOCPAI]                                          +;
			                   " (TRT: " + RTrim(aOriginal[ADADOS_POS_TRT]) + " ) e periodo " + cValToChar(nPeriodo)  +;
			                   ". nFaltaOrig: " + cValToChar(nFaltaOrig) +;
			                   ", nSubstOrig: " + cValToChar(nSubstOrig) +;
			                   ", aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA]: " + cValToChar(aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA]), "R4")
		EndIf

		If aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA] > 0 .And. nFaltaOrig > 0
			If aOriginal[ADADOS_POS_ALTERNATIVOS] != Nil .And. aOriginal[ADADOS_POS_ALTERNATIVOS]:HasProperty(cChvAltOri)
				nLimite := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, aOriginal[ADADOS_POS_ALTERNATIVOS][cChvAltOri], .F.)
			Else
				nLimite := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, aOriginal[ADADOS_POS_QTD_SUBSTITUICAO], .F.)
			EndIf
			nFalta  := aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA] + aAlternati[ADADOS_POS_QTD_ESTOQUE]
			If nFalta > nLimite
				nFalta := Max(nLimite, aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA])
			EndIf
		ElseIf oSldSubst[cChaveSubs] < nFaltaOrig .And. oSldSubst[cChaveSubs] >= 0//Saldo substitui��o deste documento+periodo+ALTERNATIVO < nFalta
			nFalta := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, oSldSubst[cChaveSubs], .F.)
		Else
			nFalta := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nFaltaOrig, .F.)
		Endif
		If slLogR4
			::oDados:oLogs:log("Avaliando a substituicao do Alternativo " + RTrim(aAlternati[ADADOS_POS_COMPONENTE]) +;
			                   " - Original " + RTrim(aOriginal[ADADOS_POS_COMPONENTE]) + "."                        +;
			                   " Documento " + aOriginal[ADADOS_POS_DOCPAI]                                          +;
			                   " (TRT: " + AllTrim(aOriginal[ADADOS_POS_TRT]) + ") e periodo " + cValToChar(nPeriodo)+;
			                   ". oSldSubst[cChaveSubs]: " + cValToChar(oSldSubst[cChaveSubs])                       +;
			                   ", nFalta: " + cValToChar(nFalta)                                                     +;
			                   ", nEstoque: " + cValToChar(nEstoque)                                                 +;
			                   ", nSubstAlt: " + cValToChar(nSubstAlt)                                               +;
			                   ", aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA]: " + cValToChar(aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA]), "R4")
		EndIf

		//Saldo do alternativo n�o � suficiente para atender a substitui��o
		If aOriginal[ADADOS_POS_REGRA_ALTERNATIVO] == "1" .And. ;
		   ((nFalta > 0 .And. Abs(nSubstAlt) + Abs(nFalta) > nEstoque) .Or.;
		    (Abs(nSubstAlt) > nEstoque) )
			nSubstAlt := Iif(aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA] > 0, -nFalta, -(Abs(nSubstAlt) + Abs(nFalta)))
			
			If aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA] + nEstoque < Abs(nSubstAlt)
				//N�o permite substituir mais que a quantidade dispon�vel de estoque.
				nDesfazer := nSubstAlt
				nSubstAlt := - (aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA] + nEstoque)
			EndIf

		//Substitui toda necessidade faltante - Estoque Dispon�vel
		ElseIf nFalta > 0 .And. (nEstoque - nFalta) >= 0
			nSubstAlt := -nFalta
			If nSubstIni < 0 .And. (nEstoque - (nFalta + Abs(nSubstIni))) > 0
				//Mant�m substitui��o inicial + a quantidade faltante de substitui��o
				nSubstAlt := (-nFalta) + nSubstIni
				nLimite   := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, aOriginal[ADADOS_POS_QTD_SUBSTITUICAO] - aOriginal[ADADOS_POS_CONSUMO_SUBSTITU], .F.)
				If Abs(nSubstAlt) > nLimite
					nSubstAlt := -nLimite
				EndIf
			EndIf

		//Consome somente a quantidade em estoque
		ElseIf nFalta > 0 .And. nEstoque > 0 .And. !(aOriginal[ADADOS_POS_REGRA_ALTERNATIVO] $ "|2|3|")
			nSubstAlt := -nEstoque

		//Mant�m substitui��o original
		ElseIf nFalta == 0
			nSubstAlt := nSubstIni

		//Substitui toda necessidade faltante - Estoque Indispon�vel
		Else
			nSubstAlt := -nFalta

		EndIf

		//Identifica quantidade do produto original substitu�da
		nSubstOrig := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nSubstAlt, .T.)

		If slLogR4
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstOrig: " + cValToChar(nSubstOrig), "R4")
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstAlt: " + cValToChar(nSubstAlt), "R4")
		EndIf

		//For�a rec�lculo do produto Original - Ap�s Pol�tica de Estoque
		If lForcaOrig
			lAllAltCons := ::todosAltConsumidos(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nPeriodo)
			If lAllAltCons
				nDesfazSub := -nSubstOrig
				If nDesfazSub == 0
					nDesfazSub := - ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nDesfazer, .T.)
				EndIf
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nDesfazSub: " + cValToChar(nDesfazSub), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]: " + cValToChar(aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
				EndIf
				aOriginal[ADADOS_POS_QTD_SUBSTITUICAO] -= nDesfazSub
				aOriginal[ADADOS_POS_CONSUMO_SUBSTITU] += nSubstOrig
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]: " + cValToChar(aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
				EndIf

			Else
				lForcaOrig := .F.
				aOriginal[ADADOS_POS_CONSUMO_SUBSTITU] += nSubstOrig
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstOrig: " + cValToChar(nSubstOrig), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
				EndIf

			EndIf

		//Avalia necessidade de rec�lculo do produto Original - Regra do Tipo 1
		ElseIf lAltReg1 .And. ((nFaltaOrig + nSubstOrig > 0) .Or. (aOriginal[ADADOS_POS_REGRA_ALTERNATIVO] == "1" .And. nEstoque + nSubstAlt < 0))
			lAllAltCons := ::todosAltConsumidos(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nPeriodo)
			If lAllAltCons
				If nFaltaOrig + nSubstOrig > 0
					nDesfazSub := nFaltaOrig + nSubstOrig
				Else
					nDesfazSub := Abs(nEstoque + nSubstAlt)
					nSubstAlt  += nDesfazSub
					nSubstOrig := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nSubstAlt , .T.)
					nDesfazSub := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nDesfazSub, .T.)
				EndIf
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nDesfazSub: " + cValToChar(nDesfazSub), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]: " + cValToChar(aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
				EndIf
				aOriginal[ADADOS_POS_QTD_SUBSTITUICAO] -= nDesfazSub
				lForcaOrig := .T.
				If slLogRS
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]: " + cValToChar(aOriginal[ADADOS_POS_QTD_SUBSTITUICAO]), "RS")
					::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
				EndIf

			EndIf

		//For�a substitui��o do produto - Regras do Tipo 2 ou 3
		ElseIf aOriginal[ADADOS_POS_REGRA_ALTERNATIVO] $ "|2|3|" .And. (nFaltaOrig + nSubstOrig) < 0
			lAllAltCons := ::todosAltConsumidos(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nPeriodo)
			If lAllAltCons .And. nFalta > 0
				nSubstOrig := 0
				nSubstAlt  := 0
				nFaltaAlt  := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nFalta, .F.)
				::forcaSubstituicaoAlternativo(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], nPeriodo, nFalta, nFaltaAlt, aOriginal, cAlternativo, @nSubstOrig, @nSubstAlt, nSubstIni)
			EndIf

		EndIf
		If slLogR4
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nSubstOrig: " + cValToChar(nSubstOrig), "R4")
		EndIf

		//Atualiza estoque final do produto alternativo
		nEstoque += nSubstAlt
		If slLogR4
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "nEstoque: " + cValToChar(nEstoque), "R4")
		EndIf

		//Abate do controle de substitui��o Json Documento + Componente
		If slLogRS
			::oDados:oLogs:log("Avaliando a substituicao do Alternativo " + RTrim(aAlternati[ADADOS_POS_COMPONENTE])                        +;
			                   " - Original " + RTrim(aOriginal[ADADOS_POS_COMPONENTE]) + "."                                               +;
			                   " Documento " + aOriginal[ADADOS_POS_DOCPAI]                                                                 +;
			                   " (TRT: " + AllTrim(aOriginal[ADADOS_POS_TRT]) + ") e periodo " + cValToChar(nPeriodo)                       +;
			                   ". nSubstIni: " + cValToChar(nSubstIni)                                                                      +;
			                   ", aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA]: " + cValToChar(aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA])+;
			                   ", oSldSubst[cChaveSubs]: " + cValToChar(oSldSubst[cChaveSubs])                                              , "RS")
		EndIf
		
		oSldSubst[cChaveSubs] += nSubstOrig + aAlternati[ADADOS_POS_TRANSFERENCIA_ENTRADA]
		
		If slLogRS
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "oSldSubst[cChaveSubs]: " + cValToChar(oSldSubst[cChaveSubs]), "RS")
		EndIf

		//Atualiza Saldo de Substitui��o no Registro do Produto Original
		If slLogRS
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
		EndIf
		aOriginal[ADADOS_POS_CONSUMO_SUBSTITU] -= nSubstOrig
		If slLogRS
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + "aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]: " + cValToChar(aOriginal[ADADOS_POS_CONSUMO_SUBSTITU]), "RS")
		EndIf

		//Atualiza registro produto Original
		::oDados_Rastreio:oDados:setItemAList(cListOrig, cChave, aOriginal)

		//Forca recalculo do produto Original devido a necessidade de desfazer parte da substituicao
		If lForcaOrig
			If Self:oDados:oDominio:oMultiEmp:utilizaMultiEmpresa()
				cChvOrigem := PadR(aOriginal[ADADOS_POS_FILIAL], Self:oDados:oDominio:oMultiEmp:tamanhoFilial()) + aOriginal[ADADOS_POS_COMPONENTE]
			Else
				cChvOrigem := aOriginal[ADADOS_POS_COMPONENTE]
			EndIf
			If !Empty(aOriginal[ADADOS_POS_ID_OPCIONAL])
				cChvOrigem += "|" + aOriginal[ADADOS_POS_ID_OPCIONAL]
			EndIf

			::forcaRecalculoOriginal(cFilAux, cChvOrigem, nDesfazSub, nPeriodo, cAlternativo, @aBaixaPorOP)
		EndIf

		If slLogR4
			//STR0136 - "Avaliando a substitui��o do Alternativo: '"
			//STR0137 - "' - Original: '"
			//STR0138 - "'. Documento '"
			//STR0126 - "TRT: "
			::oDados:oLogs:log(STR0136 + AllTrim(aAlternati[ADADOS_POS_COMPONENTE]) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + " ) " + STR0132 + cValToChar(nPeriodo) + "': " + cValToChar(nSubstAlt), "R4")
		EndIf

		nDesfezAlt := ::oAlternativo:aplicaProdutoFator(cFilAux, aOriginal[ADADOS_POS_COMPONENTE], cAlternativo, nDesfazSub, .F.)

		//Atualiza substitui��o
		aAlternati[ADADOS_POS_QTD_SUBSTITUICAO]   := nSubstAlt
		aAlternati[ADADOS_POS_QTD_SUBST_ORIGINAL] := nSubstOrig

		aSize(aOriginal, 0)
		aOriginal := Nil


	EndIf
	::oDados_Rastreio:oDados:unlock(cChvLock)

Return nDesfezAlt

/*/{Protheus.doc} forcaSubstituicaoAlternativo
For�a Substitui��o para o Primeiro Alternativo
@author brunno.costa
@since 15/08/2019
@version 1.0
@param 01 - cFilAux     , caracter, c�digo da filial para processamento
@param 02 - cProdOri    , caracter, c�digo do produto original
@param 03 - nPeriodo    , n�mero  , per�odo relacionado
@param 04 - nQtdOrig    , n�mero  , quantidade para for�ar substitui��o - Fator referente Produto Original
@param 05 - nQtdAlt     , n�mero  , quantidade para for�ar substitui��o - Fator referente Produto Alternativo
@param 06 - aOriginal   , array   , array com os dados de rastreabilidade do registro original da substitui��o
@param 07 - cAlternativo, caracter, c�digo do produto alternativo em an�lise
@param 08 - nSubstOrig  , n�mero  , recebe e retorna por refer�ncia a quantidade de substitui��o atual - Fator referente Produto Original
@param 09 - nSubstAlt   , n�mero  , recebe e retorna por refer�ncia a quantidade de substitui��o atual - Fator referente Produto Alternativo
@param 10 - nSubstIni   , n�mero  , quantidade de substitui��o inicial - pr�via a avaliaSubstOriginal  - Fator referente Produto Alternativo
/*/
METHOD forcaSubstituicaoAlternativo(cFilAux, cProdOri, nPeriodo, nQtdOrig, nQtdAlt, aOriginal, cAlternativo, nSubstOrig, nSubstAlt, nSubstIni) CLASS MrpDominio_Rastreio

	Local aCampos    := {"ALT_ALTERN", "ALT_DATA"}
	Local aCposAlt   := {}
	Local aRastreio  := {}
	Local nSequencia := 1
	Local cChvAltern
	Local cChave     := aOriginal[ADADOS_POS_DOCPAI] + chr(13) + aOriginal[ADADOS_POS_TRT] + chr(13) + aOriginal[ADADOS_POS_COMPONENTE] + chr(13) + cValToChar(aOriginal[ADADOS_POS_PERIODO])
	Local cList
	Local lError
	Local cPriAltern

	//Identifica primeiro alternativo
	lError     := .T.
	While lError
		lError     := .F.
		cChvAltern := ::oAlternativo:chaveAlternativo(cFilAux, cProdOri, cValToChar(nSequencia))
		aCposAlt   := ::oDados:retornaCampo("ALT", 1, cChvAltern, aCampos, @lError,,,,,,.T.)
		nSequencia++

		If !lError .And. !::oAlternativo:validaVigencia(cFilAux, nPeriodo, aCposAlt[2])
			lError     := .T.
		EndIf

	EndDo

	If !lError
		cPriAltern := aCposAlt[1]
	EndIf

	//Chave da sess�o do primeiro alternativo
	cList      := cFilAux + cPriAltern + chr(13) + cValToChar(nPeriodo)
	lError     := .F.

	::incluiNecessidade(cFilAux                                 ,;
	                    aOriginal[ADADOS_POS_TIPOPAI]           ,;
						aOriginal[ADADOS_POS_DOCPAI]            ,;
						cPriAltern                              ,;
						""                                      ,;
						aOriginal[ADADOS_POS_TRT]               ,;
						0                                       ,;
						nPeriodo                                ,;
						aOriginal[ADADOS_POS_CHAVE_SUBSTITUICAO],;
						aOriginal[ADADOS_POS_REGRA_ALTERNATIVO] ,;
						aOriginal[ADADOS_POS_ROTEIRO]           ,;
						aOriginal[ADADOS_POS_OPERACAO]          )

	If slLogR9 == Nil
		slLogR9 := ::oDados:oLogs:logValido("R9")
	EndIf

	//Primeiro alternativo corresponde ao registro atual
	If cAlternativo == cPriAltern
		nSubstOrig -= nQtdOrig
		nSubstAlt  -= nQtdAlt

		If slLogR9
			//STR0139 - "For�a substitui��o deste Alternativo '"
			//STR0137 - "' - Original: '"
			//STR0138 - "'. Documento: '"
			//STR0126 - "TRT: "
			::oDados:oLogs:log(STR0139 + AllTrim(cAlternativo) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + ")': " + cValToChar(nQtdOrig) + " <- " + cValToChar(nQtdAlt), "R9")
		EndIf

	//Alternativo corresponde a outro registro
	Else

		aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)

		If !lError
			////Se conseguiu recuperar o registro, faz o lock e atualiza os dados de acordo com o aBaixaPorOP
			//cChvLock := "dados_" + aRastreio[ADADOS_POS_DOCPAI];
			//					 + aRastreio[ADADOS_POS_COMPONENTE];
			//					 + aRastreio[ADADOS_POS_ID_OPCIONAL];
			//					 + aRastreio[ADADOS_POS_TRT]
			//::oDados_Rastreio:oDados:lock(cChvLock)
			//aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
			//If !lError
				aRastreio[ADADOS_POS_QTD_SUBSTITUICAO] -= nQtdOrig
				If slLogR9
					//STR0140 - "For�a substitui��o DO Alternativo '"
					//STR0137 - "' - Original: '"
					//STR0138 - "'. Documento: '"
					//STR0126 - "TRT: "
					::oDados:oLogs:log(STR0140 + AllTrim(cPriAltern) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + ")': " + cValToChar(nQtdOrig) + " <- " + cValToChar(nQtdAlt), "R9")
					::oDados:oLogs:log(STR0140 + AllTrim(cPriAltern) + STR0137 + AllTrim(aOriginal[ADADOS_POS_COMPONENTE]) + STR0138 + aOriginal[ADADOS_POS_DOCPAI] + " (" + STR0126 + AllTrim(aOriginal[ADADOS_POS_TRT]) + ")': " + cValToChar(aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]) , "R9")
				EndIf


				//Recalcula Necessidade
				aRastreio[ADADOS_POS_NECESSIDADE] := Iif(aRastreio[ADADOS_POS_NEC_ORIGINAL] < 0, 0, aRastreio[ADADOS_POS_NEC_ORIGINAL])
				aRastreio[ADADOS_POS_NECESSIDADE] -= aRastreio[ADADOS_POS_QTD_SUBSTITUICAO]
				aRastreio[ADADOS_POS_NECESSIDADE] -= aRastreio[ADADOS_POS_QTD_ESTOQUE]
				aRastreio[ADADOS_POS_NECESSIDADE] := Iif(aRastreio[ADADOS_POS_NECESSIDADE] < 0, 0, aRastreio[ADADOS_POS_NECESSIDADE])

				//Desconta necessidade original negativa
				If aRastreio[ADADOS_POS_NECESSIDADE] > 0 .And. aRastreio[ADADOS_POS_NEC_ORIGINAL] < 0
					aRastreio[ADADOS_POS_NECESSIDADE] += aRastreio[ADADOS_POS_NEC_ORIGINAL]
				EndIf

				//Altera rastreio do alternativo
				::oDados_Rastreio:oDados:setItemAList(cList, cChave, aRastreio)
			//EndIf
			//::oDados_Rastreio:oDados:unlock(cChvLock)
		EndIf

		//For�a recalculo do produto alternativo para re-explodir a estrutura
		::oDados:gravaPeriodosProd(cFilAux + cPriAltern, nPeriodo)

		//Decrementa totalizador relacionado ao oDominio:loopNiveis
		If !::oDados:possuiPendencia(cFilAux + cPriAltern, .T.)
			::oDados:decrementaTotalizador(cFilAux + cPriAltern)
		EndIf

	EndIf

Return

/*/{Protheus.doc} forcaRecalculoOriginal
For�a Rec�lculo do Produto Original neste Per�odo
@author brunno.costa
@since 13/02/2020
@version 1.0
@param 01 - cFilAux     , caracter, c�digo da filial para processamento
@param 02 - cProduto    , caracter, c�digo do produto original
@param 03 - nSaldo      , n�mero  , recebe e retorna por refer�ncia o saldo do produto p�s desfazer substitui��o parcial
@param 04 - nPeriodo    , n�mero  , c�digo do per�odo relacionado
@param 05 - cAlternativo, caracter, c�digo do produto alternativo que deve desfazer a substitui��o
@param 06 - aBaixaPorOP , n�mero  , recebe e retorna por refer�ncia array aBaixaPorOP relacionado a opera��o
/*/
METHOD forcaRecalculoOriginal(cFilAux, cProduto, nSaldo, nPeriodo, cAlternativo, aBaixaPorOP) CLASS MrpDominio_Rastreio

	If nSaldo != 0
		//Desfaz substitui��o - Matriz e Rastreio
		::oAlternativo:desfazParcialSubstituicao(cFilAux, cProduto, cAlternativo, nSaldo, nPeriodo, @aBaixaPorOP)

		//Altera produto para rec�lculo
		::oDados:gravaPeriodosProd(cProduto, nPeriodo, , (nPeriodo - 1))

		//Decrementa totalizador relacionado ao oDominio:loopNiveis
		If !::oDados:possuiPendencia(cProduto, .T.)
			::oDados:decrementaTotalizador(cProduto)
		EndIf
	EndIf

Return

/*/{Protheus.doc} atualizaRastreio
Atualiza os dados do rastreio de acordo com os dados existentes no array aBaixaPorOP

@author lucas.franca
@since 23/10/2019
@version 1.0
@param 01 - cFilAux     , caracter, c�digo da filial para processamento
@param 02 - cChaveProd  , caracter, chave do produto
@param 03 - nPeriodo    , n�mero  , per�odo relacionado
@param 04 - aBaixaPorOP , array   , array com os dados de rastreabilidade origem (Documentos Pais)
							   {{1 - Id Rastreabilidade,;
							     2 - Documento Pai,;
							     3 - Quantidade Necessidade,;
							     4 - Quantidade Estoque,;
							     5 - Quantidade Baixa Estoque,;
							     6 - Quantidade Substitui��o
								 7 - Array com as quebras de pol�ticas de estoque},...}
@param 05 - aIndexAtu   , Array   , Array com as posi��es do aBaixaPorOP que precisam ser atualizadas. (Opcional)
@param 06 - cProduto    , caracter, c�digo do produto
@return Nil
/*/
METHOD atualizaRastreio(cFilAux, cChaveProd, nPeriodo, aBaixaPorOP, aIndexAtu, cProduto) CLASS MrpDominio_Rastreio
	Local aRastreio   := {}
	Local cChvLock    := ""
	Local cList       := cChaveProd + chr(13) + cValToChar(nPeriodo) //N�o adicionar cFilAux em cList. Informa��o vem concatenada em cChaveProd
	Local lError      := .F.
	Local lUsaIndex   := .F.
	Local nIndex      := 0
	Local nIndBaixa   := 0
	Local nTotal      := Len(aBaixaPorOP)

	If nTotal > 0
		//o array aIndexAtu cont�m os �ndices do array aBaixaPorOP que realmente precisam ser atualizados.
		//Se este array n�o existir, ser� feita a atualiza��o de todos os �ndices do aBaixaPorOP recebido.
		If aIndexAtu != Nil .And. Len(aIndexAtu) > 0
			lUsaIndex := .T.
			nTotal    := Len(aIndexAtu)
		EndIf
		For nIndex := 1 To nTotal
			If lUsaIndex
				nIndBaixa := aIndexAtu[nIndex]
			Else
				nIndBaixa := nIndex
			EndIf
			//Recupera o registro de rastreabilidade
			lError    := .F.
			aRastreio := ::oDados_Rastreio:oDados:getItemAList(cList, aBaixaPorOP[nIndBaixa][1], @lError)
			If !lError
				//Se conseguiu recuperar o registro, faz o lock e atualiza os dados de acordo com o aBaixaPorOP
				cChvLock := "dados_" + aRastreio[ADADOS_POS_DOCPAI];
									 + aRastreio[ADADOS_POS_COMPONENTE];
									 + aRastreio[ADADOS_POS_ID_OPCIONAL];
									 + aRastreio[ADADOS_POS_TRT]
				::oDados_Rastreio:oDados:lock(cChvLock)

				aRastreio[ADADOS_POS_NEC_ORIGINAL         ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_NEC_ORIG                 ]
				aRastreio[ADADOS_POS_NECESSIDADE          ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_NECESSIDADE              ]
				aRastreio[ADADOS_POS_QTD_ESTOQUE          ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_QTD_ESTOQUE              ]
				aRastreio[ADADOS_POS_CONSUMO_ESTOQUE      ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_CONSUMO_ESTOQUE          ]
				aRastreio[ADADOS_POS_TRANSFERENCIA_ENTRADA] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_TRANSFERENCIA_ENTRADA    ]
				aRastreio[ADADOS_POS_TRANSFERENCIA_SAIDA  ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_TRANSFERENCIA_SAIDA      ]
				aRastreio[ADADOS_POS_DOCFILHO             ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_DOCFILHO                 ]
				aRastreio[ADADOS_POS_QTD_SUBSTITUICAO     ] := aBaixaPorOP[nIndBaixa][ABAIXA_POS_QTD_SUBSTITUICAO         ]
				aRastreio[ADADOS_POS_QUEBRAS_QUANTIDADE   ] := aClone(aBaixaPorOP[nIndBaixa][ABAIXA_POS_QUEBRAS_QUANTIDADE])
				aRastreio[ADADOS_POS_RASTRO_AGLUTINACAO   ] := aClone(aBaixaPorOP[nIndBaixa][ABAIXA_POS_RASTRO_AGLUTINACAO])
				aRastreio[ADADOS_POS_DOC_AGLUTINADOR      ] := aClone(aBaixaPorOP[nIndBaixa][ABAIXA_POS_DOC_AGLUTINADOR   ])

				//Atualiza rastreabilidade do produto
				::oDados_Rastreio:oDados:setItemAList(cList, aBaixaPorOP[nIndBaixa][1], aRastreio)
				::oDados_Rastreio:oDados:unLock(cChvLock)

				aSize(aRastreio, 0)
			EndIf
		Next
	EndIf
Return

/*/{Protheus.doc} necPPed_ES
Retorna qual � a quantidade de necessidade por ponto de pedido + estoque de seguran�a para o produto no per�odo.

@author lucas.franca
@since 24/03/2020
@version 1.0
@param 01 - cFilAux , caracter, c�digo da filial para processamento
@param 02 - cProduto, caracter, c�digo do produto
@param 03 - nPeriodo, n�mero  , per�odo relacionado
@return nNecess   , n�mero  , Quantidade de necessidade por ponto de pedido
/*/
METHOD necPPed_ES(cFilAux, cProduto, nPeriodo) CLASS MrpDominio_Rastreio
	Local aDados  := {}
	Local cList   := ""
	Local cChave  := ""
	Local lError  := .F.
	Local nNecess := 0
	Local nQuant  := 0

	//Recupera ID do Registro (ou Insere Novo e Recupera)
	cList := cFilAux + cProduto + chr(13) + cValToChar(nPeriodo)

	cChave := chavePPed(cProduto, nPeriodo, .T.)
	aDados := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
	If !lError
		nQuant := aDados[ADADOS_POS_NEC_ORIGINAL] + aDados[ADADOS_POS_TRANSFERENCIA_ENTRADA] + aDados[ADADOS_POS_CONSUMO_ESTOQUE]
		
		If nQuant <> 0
			nNecess += nQuant
		ElseIf ::oDados:oDominio:oAglutina:avaliaAglutinacao(cFilAux, cProduto)
			nNecess += aDados[ADADOS_POS_NEC_ORIGINAL] + aDados[ADADOS_POS_CONSUMO_ESTOQUE]
		EndIf
		aSize(aDados, 0)
	EndIf
	lError := .F.
	If nPeriodo == 1
		cChave := chaveESeg(cProduto, nPeriodo, .T.)
		aDados := ::oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
		If !lError
			nNecess += aDados[ADADOS_POS_NECESSIDADE]
			aSize(aDados, 0)
		EndIf
	EndIf

Return nNecess

/*/{Protheus.doc} registraLoteVencido
Grava em mem�ria os dados do lote vencido para posterior registro na tabela HWC

@author lucas.franca
@since 22/07/2022
@version 1.0
@param 01 - cFilAux   , caracter, c�digo da filial para processamento
@param 02 - cProduto  , caracter, c�digo do produto
@param 03 - cIdOpc    , caracter, ID de opcionais
@param 04 - nPeriodo  , n�mero  , per�odo relacionado
@param 05 - nDescontou, n�mero  , quantidade de lote descontada
@param 06 - nSldIni   , n�mero  , quantidade do saldo inicial
@param 07 - aLotes    , array   , Array com os dados dos lotes vencidos.
                                  aLotes[nX][1] - Qtd do lote
                                  aLotes[nX][2] - Validade do lote
                                  aLotes[nX][3] - Armaz�m
                                  aLotes[nX][4] - Lote
                                  aLotes[nX][5] - Sub-lote
@return Nil
/*/
METHOD registraLoteVencido(cFilAux, cProduto, cIdOpc, nPeriodo, nDescontou, nSldIni, aLotes) CLASS MrpDominio_Rastreio
	Local aLogVenc := {}
	Local cChave   := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + cValToChar(nPeriodo)
	Local nIndex   := 0
	Local nPosLog  := 0
	Local nTotal   := Len(aLotes)
	
	If nTotal > 0
		aLogVenc := Array(2)
		aLogVenc[1] := {cFilAux, cProduto, cIdOpc, nPeriodo}
		aLogVenc[2] := {}
	EndIf

	For nIndex := nTotal To 1 Step -1
		aAdd(aLogVenc[2], {0, aLotes[nIndex][3], aLotes[nIndex][4], aLotes[nIndex][5], nSldIni, 0, aLotes[nIndex][2]})
		nPosLog++
		If aLotes[nIndex][1] < nDescontou
			//Qtd do lote � menor que a qtd descontada. Registra a qtd total do lote como vencimento do lote.
			nDescontou              -= aLotes[nIndex][1]
			aLogVenc[2][nPosLog][1] := aLotes[nIndex][1]
			aLogVenc[2][nPosLog][6] := aLogVenc[2][nPosLog][1]
		Else
			//Qtd do lote � maior ou igual a qtd descontada. Registra a qtd descontada como vencimento do lote.
			aLogVenc[2][nPosLog][1] := nDescontou
			aLogVenc[2][nPosLog][6] := aLogVenc[2][nPosLog][1]
			nDescontou              := 0
			Exit
		EndIf
		nSldIni -= aLogVenc[2][nPosLog][6]
	Next nIndex

	//Grava em mem�ria
	Self:oDados_Rastreio:oDados:setItemAList("LOTES_VENCIDOS", cChave, aLogVenc, .F., .F., .F.)

	FwFreeArray(aLogVenc)
Return

/*/{Protheus.doc} adicionaLoteVencido
Adiciona os dados dos lotes vencidos no array de documentos que ser� 
utilizado para processar a grava��o das informa��es na tabela HWC.

@author lucas.franca
@since 22/07/2022
@version 1.0
@param 01 - aDocumento, Array, Array com os documentos que ser�o gravados na HWC, j� ordenados.
@param 02 - aLotes    , Array, Array com as informa��es dos lotes que ser�o registrados.
                               aLotes[1][1] - Filial
                               aLotes[1][2] - Produto
                               aLotes[1][3] - ID Opcional
                               aLotes[1][4] - Periodo
                               aLotes[2][nX][1] - Quantidade descontada do lote
                               aLotes[2][nX][2] - Armaz�m
                               aLotes[2][nX][3] - Lote
                               aLotes[2][nX][4] - Sublote
                               aLotes[2][nX][5] - Saldo atual do produto
                               aLotes[2][nX][6] - Quantidade de baixa de estoque
							   aLotes[2][nX][7] - Validade do lote
@return aDocumento, Array, Array com as informa��es dos lotes adicionadas.
/*/
METHOD adicionaLoteVencido(aDocumento, aLotes) CLASS MrpDominio_Rastreio
	Local cDocPai := ""
	Local cList   := ""
	Local nIndex  := 0
	Local nTotal  := 0

	If aLotes != Nil .And. Len(aLotes) > 0
		nTotal := Len(aLotes[2])
		If nTotal > 0
			//Aumenta o tamanho do array aDocumento para adicionar os novos registros 
			//no in�cio do array, sem perder as informa��es j� existentes.
			aSize(aDocumento, Len(aDocumento) + nTotal)
		EndIf
	EndIf

	For nIndex := nTotal To 1 Step -1 
		//Adiciona um elemento na primeira posi��o do array, e move os elementos j� existentes
		//para baixo.
		aIns(aDocumento, 1)

		cDocPai := AllTrim(aLotes[2][nIndex][2]) + "; "
		cDocPai += STR0190 + RTrim(aLotes[2][nIndex][3]) // "Lote: "
		cDocPai += Iif(Empty(aLotes[2][nIndex][4]), "", STR0191 + RTrim(aLotes[2][nIndex][4])) // "; Sub-lote: "
		cDocPai += STR0192 + DToC(aLotes[2][nIndex][7]) // "; Validade: "

		cList := "LTVENC" + cDocPai

		//Adiciona os dados dos lotes vencidos na primeira posi��o.
		aDocumento[1] := {cList, Array(ADADOS_SIZE)}

		aDocumento[1][2][ADADOS_POS_FILIAL                 ] := aLotes[1][1]
		aDocumento[1][2][ADADOS_POS_COMPONENTE             ] := aLotes[1][2]
		aDocumento[1][2][ADADOS_POS_ID_OPCIONAL            ] := aLotes[1][3]
		aDocumento[1][2][ADADOS_POS_PERIODO                ] := aLotes[1][4]
		aDocumento[1][2][ADADOS_POS_TIPOPAI                ] := "LTVENC"
		aDocumento[1][2][ADADOS_POS_DOCPAI                 ] := cDocPai
		aDocumento[1][2][ADADOS_POS_LOCAL                  ] := aLotes[2][nIndex][2]
		aDocumento[1][2][ADADOS_POS_NEC_ORIGINAL           ] := aLotes[2][nIndex][1]
		aDocumento[1][2][ADADOS_POS_QTD_ESTOQUE            ] := aLotes[2][nIndex][5]
		aDocumento[1][2][ADADOS_POS_CONSUMO_ESTOQUE        ] := aLotes[2][nIndex][6]
		aDocumento[1][2][ADADOS_POS_DOCFILHO               ] := ""
		aDocumento[1][2][ADADOS_POS_COMP_EXPL_ESTRUT       ] := {}
		aDocumento[1][2][ADADOS_POS_TRT                    ] := ""
		aDocumento[1][2][ADADOS_POS_NECESSIDADE            ] := 0
		aDocumento[1][2][ADADOS_POS_QTD_SUBSTITUICAO       ] := 0
		aDocumento[1][2][ADADOS_POS_QTD_SUBST_ORIGINAL     ] := 0
		aDocumento[1][2][ADADOS_POS_CONSUMO_SUBSTITU       ] := 0
		aDocumento[1][2][ADADOS_POS_CHAVE_SUBSTITUICAO     ] := ""
		aDocumento[1][2][ADADOS_POS_SUBST_ORDEM            ] := ""
		aDocumento[1][2][ADADOS_POS_REGRA_ALTERNATIVO      ] := ""
		aDocumento[1][2][ADADOS_POS_QUEBRAS_QUANTIDADE     ] := {}
		aDocumento[1][2][ADADOS_POS_ROTEIRO                ] := ""
		aDocumento[1][2][ADADOS_POS_OPERACAO               ] := ""
		aDocumento[1][2][ADADOS_POS_ROTEIRO_DOCUMENTO_FILHO] := ""
		aDocumento[1][2][ADADOS_POS_TRANSFERENCIA_ENTRADA  ] := 0
		aDocumento[1][2][ADADOS_POS_TRANSFERENCIA_SAIDA    ] := 0
		aDocumento[1][2][ADADOS_POS_RASTRO_AGLUTINACAO     ] := {0, ""}
		aDocumento[1][2][ADADOS_POS_REVISAO                ] := ""
		aDocumento[1][2][ADADOS_POS_VERSAO_PRODUCAO        ] := ""
		aDocumento[1][2][ADADOS_POS_DOC_AGLUTINADOR        ] := {.F., ""}
		aDocumento[1][2][ADADOS_POS_ALTERNATIVOS           ] := Nil
	Next nIndex 

Return aDocumento

/*/{Protheus.doc} chavePPed
Monta a chave de registro para utilizar na rastreabilidade do ponto de pedido.

@type  Static Function
@author lucas.franca
@since 24/03/2020
@version P12.1.30
@param 01 - cProduto , caracter, c�digo do produto
@param 02 - nPeriodo , n�mero  , per�odo relacionado
@param 03 - lCompleta, logico  , indica que ir� montar a chave completa para utiliza��o no getItemAList
@return cChave, character, Chave de registro para utilizar no ponto de pedido.
/*/
Static Function chavePPed(cProduto, nPeriodo, lCompleta)
	Local cChave := ""
	cChave := scTextPPed + "_" + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)

	If lCompleta
		cChave += chr(13) + "" + chr(13) + ""
	EndIf
Return cChave

/*/{Protheus.doc} chaveESeg
Monta a chave de registro para utilizar na rastreabilidade do ponto de pedido.

@type  Static Function
@author lucas.franca
@since 24/03/2020
@version P12.1.30
@param 01 - cProduto , caracter, c�digo do produto
@param 02 - nPeriodo , n�mero  , per�odo relacionado
@param 03 - lCompleta, logico  , indica que ir� montar a chave completa para utiliza��o no getItemAList
@return cChave, character, Chave de registro para utilizar no ponto de pedido.
/*/
Static Function chaveESeg(cProduto, nPeriodo, lCompleta)
	Local cChave := ""

	cChave := scTextESeg + "_"+AllTrim(cProduto)+"_"+cValToChar(nPeriodo)

	If lCompleta
		cChave += chr(13) + "" + chr(13) + ""
	EndIf
Return cChave

/*/{Protheus.doc} getChaveEstSeg
Monta a chave de registro para utilizar na rastreabilidade do ponto de pedido.
@author Lucas Fagundes
@since 05/04/2022
@version P12
@param 01 - cProduto , caracter, c�digo do produto
@param 02 - nPeriodo , n�mero  , per�odo relacionado
@param 03 - lCompleta, logico  , indica que ir� montar a chave completa para utiliza��o no getItemAList
@return cChave, character, Chave de registro para utilizar no ponto de pedido.
/*/
METHOD getChaveEstSeg(cProduto, nPeriodo, lCompleta) CLASS MrpDominio_Rastreio
Return chaveESeg(cProduto, nPeriodo, lCompleta)
