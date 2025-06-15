#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE AREGRAS_POS_ID_RASTREIO 1
#DEFINE AREGRAS_POS_REGRA       2
#DEFINE AREGRAS_POS_SALDO_OP    3

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
#DEFINE ABAIXA_SIZE                      15

/*/{Protheus.doc} MrpDominio_Alternativo
Regras de negocio MRP - Produtos alternativos
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio_Alternativo FROM LongClassName

	DATA aPeriodos_Alternativos AS ARRAY
	DATA aBaixaPorOP            AS ARRAY
	DATA aReservas              AS ARRAY
	DATA aSubsTranf             AS ARRAY
	DATA cOrdem                 AS STRING
	DATA cTipoFator             AS STRING
	DATA lConsome               AS LOGICAL
	DATA nFator                 AS INTEGER
	DATA oDados                 AS Object
	DATA oDominio               AS Object
	DATA oLeadTime              AS Object
	DATA oTranfDisp             AS Object

	METHOD new() CONSTRUCTOR
	METHOD aplicaFator(nQuantidade, cTipoFator, nFator, lDesfaz)
	METHOD aplicaProdutoFator(cFilAux, cChaveProd, cAlternativo, nQuantidade, lInversa)
	METHOD carregaTransferenciaDisponivel(cKey)
	METHOD gravaTransferenciaDisponivel(cKey, cAlternat, aTransf)
	METHOD consumirAlternativos(cFilAux, cProduto, nSaldo, nPeriodo, cProdOrig, lWait, cIDOpc, nSaiEstrut, aBaixaPorOP, aMinMaxAlt, lTranAlt)
	METHOD desfazSubstituicoes(cFilAux, cProduto, nSaldo, nPeriodo, cSomentAlt, aDesfezAlt, lWait)
	METHOD desfazParcialSubstituicao(cFilAux, cChaveSubs, cAlternativo, nQuantidade, nPeriodo, aBaixaPorOP, lSetRecalc)
	METHOD existeSubstituicao(cFilAux, cProduto, cAlternati, nPeriodo)
	METHOD loopSubstituicaoAnterior(cFilAux, cProduto, cAlternati, nPeriodo, cPath)
	METHOD consumirProduto(cFilAux, nPeriodo, cProduto, nSobraAnt, lCalculado, lEncontrou, cProdOrig, lForcaAlt, lCompraAlt, lTranAlt)
	METHOD consumirOpcionalProduto(cFilAux, nPeriodo, cProduto, nSobraAnt, lCalculado, lEncontrou, cProdOrig, cIDOpcOrig, lForcaAlt, lCompraAlt)
	METHOD percorreAlternativos(cFilAux, cProduto, nSldOrig, nPeriodo, cProdOrig, lWait, cIDOpc, nSaiEstrut, aQtdRegras, lCompraAlt, aMinMaxAlt, lTranAlt)
	METHOD registraMatrizes(cFilAux, cProduto, cAlternativo, nPeriodo, nConsOrig, nConsAlt)
	METHOD registraSubstituicao(cFilAux, cProduto, cAlternativo, nPeriodo, nConsOrig, nConsAlt, nSobra, nTransf, aTransf)
	METHOD saldoOPNecessidade(cFilAux, cProduto, cIDOpc, nPeriodo, cChave, cRegra)
	METHOD validaVigencia(cFilAux, nPeriodo, dVigencia)
	METHOD chaveAlternativo(cFilAux, cProduto, cSequencia)
	METHOD reservaAlternativo(cFilAux, cAlternat)
	METHOD liberaAlternativos()
	METHOD quantidadeSubstituicaoAlternativo(aBaixaPorOP)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oDominio, objeto, instancia da camada de dominio principal
/*/
METHOD new(oDominio) CLASS MrpDominio_Alternativo
	::oDominio               := oDominio
	::oDados                 := oDominio:oDados
	::oLeadTime              := MrpDominio_LeadTime():New(oDominio)
	::lConsome               := .T.
	::aPeriodos_Alternativos := {}
	::aReservas              := {}
	::aSubsTranf             := {}
	::oTranfDisp             := JsonObject():New()

	//Corrige Apontamento
	::oDominio:oRastreio:oAlternativo := Self
Return Self

/*/{Protheus.doc} consumirAlternativos
Consome alternativos do produto
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux    , caracter, codigo da filial para processamento
@param 02 - cProduto   , caracter, codigo do produto original para analise dos alternativos
@param 03 - nSaldo     , numero  , saldo do produto original para consumir alternativos
@param 04 - nPeriodo   , numero  , periodo para consumo
@param 05 - cProdOrig  , caracter, codigo do produto precessor ao original (caso este ja seja um alternativo)
@param 06 - lWait      , logico  , retorna por referencia indicando se existe na Matriz de Calculo, mas nao foi calculado. Interrompe o consumo.
@param 07 - cIDOpc     , caracter, Id do opcional relacionado
@param 08 - nSaiEstru  , n�mero  , quantidade sa�da estrutura do produto original
@param 09 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substitui��o},...}
@param 10 - aMinMaxAlt , array   , array com o nMin e nMax de sequ�ncia do alternativo
@param 11 - lTranAlt   , logic   , Identifica que deve tentar transferir o saldo do produto alternativo antes de executar a substitui��o
@return nSldPoster, numero, saldo posterior ao consumo dos alternativos
/*/
METHOD consumirAlternativos(cFilAux, cProduto, nSaldo, nPeriodo, cProdOrig, lWait, cIDOpc, nSaiEstrut, aBaixaPorOP, aMinMaxAlt, lTranAlt) CLASS MrpDominio_Alternativo

	/*cRegra   , caracter, regra de consumo dos alternativos:
	1- Valida Original; Valida Alternativo; Compra Original
	2- Valida Original; Valida Alternativo; Compra Alternativo
	3- Valida Alternativo; Compra Alternativo*/
	Local cRegra       := "1"

	Local nIndex       := 0
	Local nTotal       := Len(aBaixaPorOP)
	Local nSldOP       := 0
	Local nSldOPs      := 0
	Local aQtdRegras   := {}
	Local nSldPoster   := nSaldo
	Local lCompraAlt   := .F.
	Local nSubstitui   := 0

	Default cProdOrig  := ""
	Default lWait      := .F.
	Default nSaiEstrut := 0
	Default lTranAlt   := .F.

	If lTranAlt
		//An�lise de alternativos considerando a 
		//transfer�ncia de saldo do produto alternativo (multi-empresa)
		nSldOPs := -nSaiEstrut
		aAdd(aQtdRegras, {aBaixaPorOP[1], cRegra, nSldOPs})
	ElseIf nSaiEstrut > 0
		For nIndex := 1 to nTotal
			//Identifica o saldo da necessidade desta OP e a Regra de considera��o dos alternativos
			cRegra       := "1"
			nSldOP  := - ::saldoOPNecessidade(cFilAux, cProduto, cIDOpc, nPeriodo, aBaixaPorOP[nIndex][1], @cRegra)
			nSldOPs += nSldOP
			aAdd(aQtdRegras, {aBaixaPorOP[nIndex][1], cRegra, nSldOP})
			
			If cRegra $ "|2|3|"
				//::oDominio:oLogs:log("For�a consumo do alternativo, produto '" + AllTrim(cProduto) + "'", "33")
				lCompraAlt := .T.
			EndIf
		Next
	EndIf

	//Percorre os alternativos e consome o saldo conforme regra
	If nSldOPs < 0
		::lConsome := .F.
		nSldPoster := ::percorreAlternativos(cFilAux, cProduto, nSldOPs, nPeriodo, cProdOrig, @lWait, cIDOpc, @nSaiEstrut, aQtdRegras, lCompraAlt, aMinMaxAlt, lTranAlt)
		If !lWait
			::lConsome := .T.
			aSize(::aPeriodos_Alternativos, 0)
			If lTranAlt
				aSize(Self:aSubsTranf, 0)
			EndIf
			nSldPoster := ::percorreAlternativos(cFilAux, cProduto, nSldOPs, nPeriodo, cProdOrig, @lWait, cIDOpc, @nSaiEstrut, aQtdRegras, lCompraAlt, aMinMaxAlt, lTranAlt)
		EndIf
		nSubstitui := nSldPoster - nSldOPs
		nSaldo     += nSubstitui
	EndIf

Return nSaldo

/*/{Protheus.doc} percorreAlternativos
Consome alternativos do produto
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux   , caracter, codigo da filial para processamento
@param 02 - cProduto  , caracter, codigo do produto original para analise dos alternativos
@param 03 - nSldOrig  , numero  , saldo do produto original para consumir alternativos
@param 04 - nPeriodo  , numero  , periodo para consumo
@param 05 - cProdOrig , caracter, codigo do produto precessor ao original (caso este ja seja um alternativo)
@param 06 - lWait     , logico  , retorna por referencia indicando se existe na Matriz de Calculo, mas nao foi calculado. Interrompe o consumo.
@param 07 - cIDOpc    , caracter, Id do opcional relacionado
@param 08 - nSaiEstrut, n�mero  , quantidade de sa�da estrutura deste produto
@param 09 - aQtdRegras, array   , quantidade correspondente a cada uma das regras de OP em ordem de prioridade
								 {cID, cRegra, nQuantidade}
@param 10 - lCompraAlt, l�gico  , indica se existe alguma OP com regra 2 ou 3: compra alternativo
@param 11 - aMinMaxAlt, array   , array com o nMin e nMax de sequ�ncia do alternativo
@param 12 - lTranAlt  , logic   , Identifica que deve tentar transferir o saldo do produto alternativo antes de executar a substitui��o
@return nSldPoster, numero, saldo posterior ao consumo dos alternativos
/*/
METHOD percorreAlternativos(cFilAux, cProduto, nSldOrig, nPeriodo, cProdOrig, lWait, cIDOpc, nSaiEstrut, aQtdRegras, lCompraAlt, aMinMaxAlt, lTranAlt) CLASS MrpDominio_Alternativo

	Local aCampos      := {"ALT_ALTERN", "ALT_DATA", "ALT_TPFAT", "ALT_FATOR", "ALT_ORDEM"}
	Local aCposAlt     := {}
	Local cAlternati
	Local cMenorAlt    := ""
	Local cIndAlt      := aMinMaxAlt[1]
	Local cMaxAlt      := aMinMaxAlt[2]
	Local lCalculado   := .T.
	Local lEncontrou   := .F.
	Local lErrorALT    := .F.
	Local nIndex       := 0
	Local nSldInic     := nSldOrig
	Local nSldPoster   := nSldOrig
	Local nSldInic2    := 0
	Local nSldPoste2   := 0
	Local nSaiEstOri   := 0
	Local nQtdNecAlt   := 0
	Local nTotal       := 0
	Local nSldCnvAlt   := 0
	Local nSldAltPos   := 0
	Local nSubstitui   := 0
	Local nTotSubst    := 0
	Local nBkpSubsti   := 0

	Default cProdOrig  := ""
	Default lWait      := .F.
	Default nSaiEstrut := 0
	Default lCompraAlt := .F.
	Default lTranAlt   := .F.

	//Ajusta saldo para quantidade m�xima da sa�da estrutura
	nSaiEstOri := nSaiEstrut

	//Avalia Alternativos - Somente para quantidade Sa�da Estrutura
	While nSaiEstrut > 0 .And. nSldPoster < 0

		aSize(aCposAlt, 0)
		If cIndAlt > cMaxAlt
			Exit
		EndIf

		cChvAltern := Self:chaveAlternativo(cFilAux, cProduto, cIndAlt)
		aCposAlt   := ::oDados:retornaCampo("ALT", 1, cChvAltern, aCampos, @lErrorALT,,,,,,.T.)

		If lErrorALT
			aCposAlt  := {}
			lErrorALT := .F.
			cIndAlt := Soma1(cIndAlt)
			Loop
		EndIf

		//Valida vig�ncia do alternativo
		If !::validaVigencia(cFilAux, nPeriodo, aCposAlt[2])
			cIndAlt := Soma1(cIndAlt)
			Loop
		EndIf

		//Verifica cadastro incorreto de alternativo. (alternativo e original iguais)
		If RTrim(cProduto) == RTrim(aCposAlt[1])
			cIndAlt := Soma1(cIndAlt)
			Loop
		EndIf

		cAlternati   := aCposAlt[1]
		::cTipoFator := aCposAlt[3]
		::nFator     := aCposAlt[4]
		::cOrdem     := aCposAlt[5]

		//Nao avalia alternativo correspondente a produto original (protecao loop)
		If !Empty(cProdOrig) .And. AllTrim(cProdOrig) == AllTrim(cAlternati)
			cIndAlt := Soma1(cIndAlt)
			Loop
		EndIf

		//N�o avalia alternativo relacionado a substitui��o REVERSA
		If ::existeSubstituicao(cFilAux, cAlternati, cProduto, nPeriodo)
			cIndAlt := Soma1(cIndAlt)
			Loop
		EndIf

		//N�o avalia alternativo relacionado a substitui��o ANTERIOR
		If ::loopSubstituicaoAnterior(cFilAux, cProduto, cAlternati, nPeriodo)
			cIndAlt := Soma1(cIndAlt)
			Loop
		EndIf

		Self:oDominio:oSeletivos:setaProdutoValido(cAlternati)

		//Identifica primeira sequencia
		cMenorAlt := Iif(cMenorAlt == "", cIndAlt, cMenorAlt)

		//Identifica Saldo Convertido
		nSldCnvAlt  := Iif(nSldOrig == 0, 0, ::aplicaFator(nSldOrig, ::cTipoFator, ::nFator, .F.))

		//Consome saldo
		If Empty(cIDOpc)
			nSldAltPos := ::consumirProduto(cFilAux, nPeriodo, cAlternati, nSldCnvAlt, @lCalculado, @lEncontrou, cProduto, .F., lCompraAlt, lTranAlt)
		Else
			nSldAltPos := ::consumirOpcionalProduto(cFilAux, nPeriodo, cAlternati, nSldCnvAlt, @lCalculado, @lEncontrou, cProduto, cIDOpc, .F., lCompraAlt, lTranAlt)
		EndIf
		nSldPoster := Iif(nSldAltPos == 0, 0, ::aplicaFator(nSldAltPos, ::cTipoFator, ::nFator, .T.))
		nSubstitui := nSldPoster - nSldInic
		nSldInic   := nSldPoster
		nBkpSubsti := nSubstitui
		nSldOrig   += nSubstitui
		nTotSubst  += nSubstitui

		//Existe na MAT, mas nao foi calculado, interrompe
		If lEncontrou .And. !lCalculado
			//"Consumo alternativos interrompido: encontrou alternativo '" + "' do produto '" + "' na Matriz, mas este nao foi calculado."
			If Self:oDominio:oLogs:logValido("5")
				::oDominio:oLogs:log(STR0074 + AllTrim(cAlternati) + STR0075 + AllTrim(cProduto) + STR0076, "5")
			EndIf
			lWait := .T.
			Exit
		Else
			lWait := .F.
		EndIf

		cIndAlt := Soma1(cIndAlt)
	EndDo

	//Checar se h� necessidades diferente do tipo 1, se sim, gerar substitui��o para primeiro alternativo
	//Gera Necessidade do Alternativo - Regra "2" ou "3"
	If !lWait .And. cMenorAlt != ""
		nTotal   := Len(aQtdRegras)

		//Identifica a quantidade a gerar necessidade para o Alternativo
		For nIndex := 1 to nTotal
			If nTotSubst > 0
				If nTotSubst >= (-aQtdRegras[nIndex][AREGRAS_POS_SALDO_OP])
					nTotSubst += aQtdRegras[nIndex][AREGRAS_POS_SALDO_OP]
					aQtdRegras[nIndex][AREGRAS_POS_SALDO_OP] := 0
				Else
					aQtdRegras[nIndex][AREGRAS_POS_SALDO_OP] += nTotSubst
					nTotSubst := 0
				EndIf
			EndIf
			If aQtdRegras[nIndex][AREGRAS_POS_REGRA] $ "|2|3|"
				nQtdNecAlt += aQtdRegras[nIndex][AREGRAS_POS_SALDO_OP]
			EndIf
		Next

		//For�a Gera��o da Necessidade do Alternativo
		If nQtdNecAlt < 0
			lErrorALT  := .F.
			cChvAltern := cChvAltern := Self:chaveAlternativo(cFilAux, cProduto, cMenorAlt)
			aCposAlt     := ::oDados:retornaCampo("ALT", 1, cChvAltern, aCampos, @lErrorALT,,,,,,.T.)
			cAlternati   := aCposAlt[1]
			::cTipoFator := aCposAlt[3]
			::nFator     := aCposAlt[4]
			::cOrdem     := aCposAlt[5]

			nSldInic2  := nQtdNecAlt

			//Identifica Saldo Convertido
			nSldCnvAlt  := Iif(nQtdNecAlt == 0, 0, ::aplicaFator(nQtdNecAlt, ::cTipoFator, ::nFator, .F.))

			If Empty(cIDOpc)
				nSldAltPos := ::consumirProduto(cFilAux, nPeriodo, cAlternati, nSldCnvAlt, @lCalculado, @lEncontrou, cProduto, .T., lCompraAlt, lTranAlt)
			Else
				nSldAltPos := ::consumirOpcionalProduto(cFilAux, nPeriodo, cAlternati, nSldCnvAlt, @lCalculado, @lEncontrou, cProduto, cIDOpc, .T., lCompraAlt, lTranAlt)
			EndIf

			nSldPoste2     := Iif(nSldAltPos == 0, 0, ::aplicaFator(nSldAltPos, ::cTipoFator, ::nFator, .T.))
			nSubstitui     := nSldPoste2 - nSldInic2
			nSldOrig       += nSubstitui
		EndIf
	EndIf

Return nSldOrig

/*/{Protheus.doc} consumirProduto
Consome periodo e retorna o saldo posterior
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux   , caracter, c�digo da filial para processamento
@param 02 - nPeriodo  , numero  , periodo referencia para consumo
@param 03 - cProduto  , caracter, codigo do produto a ser consumido (alternativo) (ou codigo + ID Opcional)
@param 04 - nSobraAnt , numero  , saldo da necessidade antes de consumir este produto (alternativo)
@param 05 - lCalculado, logico  , retorna por referencia se o produto foi calculado no periodo
@param 06 - lEncontrou, logico  , retorna por referencia se encontrou o produto na matriz de calculo
@param 07 - cProdOrig , caracter, codigo do produto original
@param 08 - lForcaAlt , l�gico  , for�a o consumo do alternativo na quantidade total
@param 09 - lCompraAlt, l�gico  , indica se existe alguma OP com regra 2 ou 3: compra alternativo
@param 10 - lTranAlt  , logic   , Identifica que deve tentar transferir o saldo do produto alternativo antes de executar a substitui��o
@return nSobraPos, numero, retorna o saldo apos consumir o produto
/*/
METHOD consumirProduto(cFilAux, nPeriodo, cProduto, nSobraAnt, lCalculado, lEncontrou, cProdOrig, lForcaAlt, lCompraAlt, lTranAlt) CLASS MrpDominio_Alternativo

	Local aAreaMAT        := {}
	Local aRetAux         := {}
	Local aTransf         := {}
	Local cChaveMAT       := ""
	Local cChaveProd      := cFilAux + cProduto
	Local lErrorAlt       := .F.
	Local lInterrompe     := .F.
	Local lLog14          := Self:oDominio:oLogs:logValido("14")
	Local lLog15          := Self:oDominio:oLogs:logValido("15")
	Local lLog16          := Self:oDominio:oLogs:logValido("16")
	Local lLog17          := Self:oDominio:oLogs:logValido("17")
	Local lLog18          := Self:oDominio:oLogs:logValido("18")
	Local lLog6           := Self:oDominio:oLogs:logValido("6")
	Local lReservaMatriz  := .F.
	Local lReservaProduto := .F.
	Local lWait           := .F.
	Local nConsAlt        := 0
	Local nConsOrig       := 0
	Local nNecAltern      := 0
	Local nPerAux         := 0
	Local nQtTotTran      := 0
	Local nSldAltern      := 0
	Local nSobra          := 0
	Local nSobraPos       := nSobraAnt
	Local nThreads        := ::oDominio:oParametros["nThreads"]
	Local oLiveLock       := ::oDados:oLiveLock

	Default lForcaAlt     := .F.
	Default lCompraAlt    := .F.

	aAreaMAT    := ::oDados:retornaArea("MAT")

	If lTranAlt
		//Verifica se o produto alternativo possui saldo em outra
		//filial para transferir e fazer a substitui��o.
		Self:oDominio:oMultiEmp:consumirEstoqueME(cFilAux, cProduto, nPeriodo, "", nSobraAnt, @lWait, @nQtTotTran, Self:lConsome, Nil, .T., @aTransf)
		If lWait
			lCalculado := .F.
			lEncontrou := .T.
			Return nSobraPos
		ElseIf nQtTotTran == 0
			//N�o possui nenhum saldo para transferir.
			lCalculado := .T.
			lEncontrou := .T.
			Return nSobraPos
		EndIf
	EndIf

	//Busca para tras
	For nPerAux := nPeriodo to 1 step -1
		cChaveMAT  := DtoS(::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPerAux)) + cChaveProd
		lErrorAlt  := .F.
		::oDados:retornaCampo("MAT" , 1, cChaveMAT, "MAT_SALDO", @lErrorAlt)
		nSldAltern := ::oDominio:saldoInicial(cFilAux, cProduto, nPerAux)

		//Encontrou na Matriz de Calculo ou Possui Saldo
		If !lErrorAlt
			lEncontrou := .T.

			If !(lCalculado := ::oDados:foiCalculado(cChaveProd, nPerAux)) .And. !lForcaAlt .And. !(lTranAlt .And. nQtTotTran <> 0)
				If Self:oDominio:oLogs:logValido("11")
					::oDominio:oLogs:log(STR0053 + AllTrim(cProdOrig) + STR0054 + " -> " + AllTrim(cChaveProd) + STR0018 + cValToChar(nPerAux), "11") //"Alternativo ainda nao calculado, interrompe: " + "(Original)" + "(Alternativo)" + " - Periodo: "
				EndIf
				If nThreads > 1
					oLiveLock:setResult(cFilAux + cProduto , 1, .F., .T., .T.)
					oLiveLock:setResult(cFilAux + cProdOrig, 1, .F., .T., .T.)
				EndIf
				Exit
			EndIf

			//Se est� fazendo transfer�ncia para executar a substitui��o,
			//considera que o produto est� calculado, pois ser� substitu�do
			//a quantidade de transfer�ncia de estoque.
			If lTranAlt .And. nQtTotTran > 0
				lCalculado := .T.
			EndIf

			//Existe na Matriz calculado
			If lCalculado .Or. lForcaAlt
				lReservaMatriz := .F.
				nSobra         := 0
				If lReservaProduto := ::oDados:reservaProduto(cChaveProd)
					//Verifica o saldo no final do processo
					aRetAux    := ::oDados:retornaCampo("MAT", 1, cChaveMAT, {"MAT_NECESS","MAT_SALDO","MAT_QTRENT"}, @lErrorAlt, , , , , , .T. /*lVarios*/)
					If nPerAux == nPeriodo
						//Per�odo atual, considera o saldo final do per�odo.
						nSldAltern := aRetAux[2]
					Else
						//Per�odo anterior, considera o saldo que ser� gerado para o pr�ximo per�odo.
						nNecAltern := aRetAux[1]
						nSldAltern := aRetAux[2]
						nSldAltern += nNecAltern
					EndIf
					nSldAltern -= ::oDominio:oRastreio:necPPed_ES(cFilAux, cProduto, nPerAux)

					If lLog14
						::oDominio:oLogs:log("Reservou o produto alternativo " + RTrim(cProduto) +;
						                     " (Alternativo) - Periodo: " + cValToChar(nPerAux)  +;
						                     ", lTranAlt = " + Iif(lTranAlt, "true", "false")    +;
						                     ", nNecAltern = " + cValToChar(nNecAltern)          +;
						                     ", nSldAltern = " + cValToChar(nSldAltern)          +;
						                     ", aRetAux[1] = " + cValToChar(aRetAux[1])          +;
						                     ", aRetAux[2] = " + cValToChar(aRetAux[2])          +;
						                     ", aRetAux[3] = " + cValToChar(aRetAux[3])          ,"14")
					EndIf

					If !lTranAlt
						nSldAltern -= aRetAux[3]
					EndIf

					If nSldAltern > 0 .Or. lForcaAlt .Or. (!::lConsome .And. lTranAlt .And. nQtTotTran > 0)

						If ::lConsome

							//Registra o consumo do alternativo nas matrizes (Origem e Destino)
							If lLog14
								::oDominio:oLogs:log("Reservou o produto alternativo " + RTrim(cProduto) +;
								                     " (Alternativo) - Periodo: " + cValToChar(nPerAux)  +;
								                     ", lForcaAlt = " + Iif(lForcaAlt, "true", "false")  +;
								                     ", nSobraPos = " + cValToChar(nSobraPos)            +;
								                     ", nSldAltern = " + cValToChar(nSldAltern)          , "14")
							EndIf

							If lForcaAlt
								nConsAlt := -nSobraPos
								nSobra   := 0
							Else
								nSobra   := nSobraPos + nSldAltern
								nSobra   := If(nSobra > 0, 0, nSobra)
								nConsAlt := -(nSobraPos - nSobra)
							EndIf

							If lLog14
								::oDominio:oLogs:log("Reservou o produto alternativo " + RTrim(cProduto) +;
								                     " (Alternativo) - Periodo: " + cValToChar(nPerAux)  +;
								                     ", nSobra = " + cValToChar(nSobra)                  +;
								                     ", nConsAlt = " + cValToChar(nConsAlt)              , "14")
							EndIf

							//Identifica quantidade correspondente no produto original
							nConsOrig := Iif(nConsAlt == 0, 0, ::aplicaFator(nConsAlt, ::cTipoFator, ::nFator, .T.))

							//Registra a substituicao
							::registraSubstituicao(cFilAux, cProdOrig, cProduto, nPeriodo, @nConsOrig, @nConsAlt, @nSobra, nQtTotTran, aTransf)

							//Registra substituicao e registros nas matrizes (Origem e Destino)
							If nConsOrig <> 0 .And. nConsAlt <> 0
								::registraMatrizes(cFilAux, cProdOrig, cProduto, nPeriodo, nConsOrig, nConsAlt)
							EndIf
							::oDados:setaArea(aAreaMAT)

							If lTranAlt .And. nQtTotTran > 0
								/*
									Grava no array "Self:aSubsTranf" o produto alternativo e a quantidade
									de transfer�ncia que foi realizada para este produto alternativo.
									Esta informa��o ser� utilizada para gravar os dados de rastreabilidade
									do produto alternativo (HWC) com a quantidade correta de transfer�ncia para a substitui��o.
									Esta informa��o � lida no m�todo retornaAlternativos do fonte MrpDominio_Rastreio.
									O array � inicializado antes de iniciar o processo de substitui��o 
									(m�todo consumirAlternativos do fonte MrpDominio_Alternativo) e tamb�m no t�rmino 
									do processo de substitui��o (m�todo alternativosMultiEmpresa do fonte MrpDominio_MultiEmpresa)
								*/
								nPos := aScan(Self:aSubsTranf, {|x| x[1] == cProduto})
								If nPos == 0
									aAdd(Self:aSubsTranf, {cProduto, 0, 0})
									nPos := Len(Self:aSubsTranf)
								EndIf
								Self:aSubsTranf[nPos][2] += nQtTotTran
							EndIf

							nSobraPos   := nSobra
							nSobra      := 0
						EndIf

						//Interrompe While: apos consumir o saldo do alternativo
						If lLog15
							::oDominio:oLogs:log("Interrompe While: apos consumir o saldo do alternativo " +;
							                     RTrim(cProdOrig) + " (Original) -> " +;
							                     RTrim(cProduto) + " (Alternativo) - Periodo:" + cValToChar(nPeriodo), "15")
						EndIf

					Else
						If lLog17
							::oDominio:oLogs:log(STR0063 + AllTrim(cProdOrig) + STR0054 + " -> " + AllTrim(cProduto) + STR0055 + STR0018 + cValToChar(nPeriodo), "17") //"Interrompe While: Nao ha saldo do alternativo: " + " - Periodo: "
						EndIf

					EndIf
					::oDados:liberaProduto(cChaveProd)
					If lLog14
						::oDominio:oLogs:log("Liberou produto alternativo " + RTrim(cChaveProd) + " (Alternativo) - Periodo: " + cValToChar(nPeriodo), "14")
					EndIf
					lInterrompe := .T.
				Else

					If nThreads > 1
						oLiveLock:setResult(cFilAux + cProduto , 1, .F., .T., .T.)
						oLiveLock:setResult(cFilAux + cProdOrig, 1, .F., .T., .T.)
					EndIf

					lCalculado  := .F.
					lInterrompe := .T.
					If lLog16
						::oDominio:oLogs:log(STR0061 + AllTrim(cProdOrig) + STR0054 + " -> " + AllTrim(cProduto) + STR0055 + STR0018 + cValToChar(nPeriodo), "16") //"Interrompe While: ao tentar consumir saldo de alternativo bloqueado " + " - Periodo: "
					EndIf
					Exit
				EndIf

				Exit
			EndIf

		//N�o encontrou alternativo na matriz de calculo
		Else
			If nSldAltern > 0 .Or. lCompraAlt .Or. nQtTotTran > 0
				If !::oDados:existeMatriz(cFilAux, cProduto, nPerAux) .And. ::oDados:oMatriz:trava(cChaveMAT)

					//Decrementa totalizador relacionado ao oDominio:loopNiveis
					If !::oDados:existeMatriz(cFilAux, cProduto) .or. !::oDados:possuiPendencia(cChaveProd, .T.)
						::oDados:decrementaTotalizador(cChaveProd)
					EndIf

					//"Inclui novo registro na Matriz: " + " - Periodo: " + " - nNecessidade: "
					If lLog6
						::oDados:oLogs:log(STR0034 + AllTrim(cProduto) + STR0018 + cValToChar(nPerAux) + STR0035 + cValToChar(0), "6")
					EndIf
					::oDados:atualizaMatriz(cFilAux, ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPerAux), cProduto, Nil, {"MAT_SLDINI", "MAT_SALDO"}, {nSldAltern, nSldAltern}, /*cChave*/, /*lMantTrava*/, /*lFazLock*/, .F.)
					::oDados:gravaPeriodosProd(cChaveProd, nPerAux)
					::oDados:oMatriz:destrava(cChaveMAT)
					nPerAux++
					Loop

				ElseIf ::oDados:existeMatriz(cFilAux, cProduto, nPerAux)
				    nPerAux++
					Loop

				EndIf
			Else
				If lLog18
					::oDominio:oLogs:log(STR0064 + AllTrim(cProdOrig) + STR0054 + " -> " + AllTrim(cProduto) + STR0055 + STR0018 + cValToChar(nPerAux), "18") //"Nao encontrou alternativo na matriz de calculo no periodo: " + "(Original)" + "(Alternativo)" + " - Periodo: "
				EndIf
				Loop
			EndIf

		EndIf
		If lInterrompe
			Exit
		EndIf
	Next nPerAux

	::oDados:setaArea(aAreaMAT)

Return nSobraPos

/*/{Protheus.doc} registraMatrizes
Registra substituicao e alteracoes de entradas e saidas previstas nas matrizes
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux     , caracter, codigo da filial para processamento
@param 01 - cProduto    , caracter, codigo do produto original (substituido)
@param 02 - cAlternativo, caracter, codigo do produto alternativo (substituto)
@param 03 - nPeriodo    , numero  , periodo
@param 04 - nConsOrig   , numero  , quantidade substitu�da do produto original
@param 05 - nConsAlt    , numero  , quantidade consumida do produto alternativo
@return Nil
/*/
METHOD registraMatrizes(cFilAux, cProduto, cAlternativo, nPeriodo, nConsOrig, nConsAlt) CLASS MrpDominio_Alternativo

	Local aAreaMAT   := ::oDados:retornaArea("MAT")
	Local cChaveOri  := DtoS(::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + cProduto
	Local cChvAltern := DtoS(::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + cAlternativo
	Local lLog12     := ::oDominio:oLogs:logValido("12")
	Local lLog13     := ::oDominio:oLogs:logValido("13")

	//Atualiza Saida Prevista
	If lLog12
		::oDominio:oLogs:log("Periodo: " + cValToChar(nPeriodo) + " - Produto: " + RTrim(cAlternativo) + " - Saida Prevista (MAT_SAIPRE): (+)" + cValToChar(nConsAlt), "12")
	EndIf

	//Verifica se existe a matriz para o produto alternativo no per�odo onde ser� feita a substitui��o.
	//Verifica��o � necess�ria para quando o saldo do produto alternativo � proveniente de per�odos anteriores do MRP
	If !::oDados:existeMatriz(cFilAux, cAlternativo, nPeriodo) .And. ::oDados:oMatriz:trava(cChvAltern)
		::oDados:atualizaMatriz(cFilAux, ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), cAlternativo, Nil, {"MAT_SALDO"}, {nConsAlt}, /*cChave*/, /*lMantTrava*/, /*lFazLock*/, .F.)
		::oDados:gravaPeriodosProd(cFilAux + cAlternativo, nPeriodo)
		::oDados:oMatriz:destrava(cChvAltern)
	EndIf

	//Grava os dados de substitui��o na matriz do produto alternativo
	::oDados:gravaCampo("MAT", 1, cChvAltern, "MAT_SAIPRE", nConsAlt , .F., .T.)	//.T. = Acrescenta
	::oDados:gravaCampo("MAT", 1, cChvAltern, "MAT_SALDO" , -nConsAlt, .F., .T.)	//.T. = Acrescenta

	//Decrementa totalizador relacionado ao oDominio:loopNiveis
	If !::oDados:possuiPendencia(cFilAux + cProduto, .T.)
		::oDados:decrementaTotalizador(cFilAux + cProduto)
	EndIf

	//Ajusta periodo inicial produto alternativo consumido
	If lLog13
		::oDominio:oLogs:log("- Produto: " + cAlternativo + " (Alternativo) - Periodo Minimo:" + cValToChar(nPeriodo), "13")
	EndIf

	//Atualiza Entrada Prevista - Produto Original
	If lLog12
		::oDominio:oLogs:log("- Periodo: " + cValToChar(nPeriodo) + " - Produto: " + AllTrim(cProduto) + " - Entrada Prevista (MAT_ENTPRE): (+)" + cValToChar(nConsOrig), "12")
	EndIf
	::oDados:gravaCampo("MAT", 1, cChaveOri, "MAT_ENTPRE", nConsOrig, .F., .T.)   //.T. = Acrescenta

	//Adiciona produto e per�odo no controle de grava��o do campo "Per�odo DE" na l�gica de c�lculo
	aAdd(::aPeriodos_Alternativos, {cAlternativo, nPeriodo, nConsOrig})

	::oDados:setaArea(aAreaMAT)

Return

/*/{Protheus.doc} consumirOpcionalProduto
Consome periodo e retorna o saldo posterior - Produto com opcional
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux   , caracter, c�digo da filial para processamento
@param 02 - nPeriodo  , numero  , periodo referencia para consumo
@param 03 - cProduto  , caracter, codigo do produto a ser consumido (alternativo)
@param 04 - nSobraAnt , numero  , saldo da necessidade antes de consumir este produto (alternativo)
@param 05 - lCalculado, logico  , retorna por referencia se o produto foi calculado no periodo
@param 06 - lEncontrou, logico  , retorna por referencia se encontrou o produto na matriz de calculo
@param 07 - cProdOrig , caracter, codigo do produto original
@param 08 - cIDOpcOrig, caracter, ID do opcional original
@param 09 - lForcaAlt , l�gico  , for�a o consumo do alternativo na quantidade total
@param 10 - lCompraAlt, l�gico  , indica se existe alguma regra com regra 2 ou 3: compra alternativo
@param 11 - lTranAlt  , logic   , Identifica que deve tentar transferir o saldo do produto alternativo antes de executar a substitui��o
@return nSobraPos, numero, retorna o saldo apos consumir o produto
/*/
METHOD consumirOpcionalProduto(cFilAux, nPeriodo, cProduto, nSobraAnt, lCalculado, lEncontrou, cProdOrig, cIDOpcOrig, lForcaAlt, lCompraAlt, lTranAlt) CLASS MrpDominio_Alternativo

	Local aAreaMAT   := {}
	Local aAreaPRD   := ::oDados:retornaArea("PRD")
	Local aOpcional  := {}
	Local aOpcOrig   := {}
	Local aRetAux    := {}
	Local cIDOpc     := ""
	Local cOpcional  := ""
	Local cOpcOrig   := ""
	Local cProdAux   := ""
	Local cChaveOrig := cProdOrig + "|" + cIDOpcOrig
	Local lErrorPRD  := .F.
	Local nSobraPos  := nSobraAnt

	Default lForcaAlt := .F.

	aAreaMAT := ::oDados:retornaArea("MAT")

	//Consome saldo de alternativo sem estrutura
	If !::oDados:possuiEstrutura(cFilAux, cProduto)
		nSobraPos := ::consumirProduto(cFilAux, nPeriodo, cProduto, nSobraAnt, @lCalculado, @lEncontrou, cChaveOrig, lForcaAlt, lCompraAlt, lTranAlt)

	Else
		//Verifica existencia de alternativo com este opcional na tabela de Produtos
		aRetAux  := ::oDados:retornaCampo("PRD", 1, cFilAux + cProduto, {"PRD_COD", "PRD_IDOPC"}, @lErrorPRD, , , , , , .T. /*lVarios*/)
		While nSobraPos < 0
			If lErrorPRD
				Exit
			EndIf

			cProdAux := aRetAux[1]
			cIDOpc   := aRetAux[2]

			If (cProdAux == cProduto .Or. Empty(cProdAux))
				If !Empty(cIDOpc)
					cOpcional := ::oDados:retornaCampo("OPC", 2, cIDOpc    , "OPC_OPCION")
					aOpcional := StrTokArr(cOpcional, "|")
					aOpcional := aSort(aOpcional)
					cOpcional := AllTrim(Upper(Array2Str(aOpcional, .F.)))

					cOpcOrig  := Iif(Empty(cOpcOrig), ::oDados:retornaCampo("OPC", 2, cIDOpcOrig, "OPC_OPCION"), cOpcOrig)
					aOpcOrig  := Iif(Empty(aOpcOrig), StrTokArr(cOpcOrig, "|"), aOpcOrig)
					aOpcOrig  := aSort(aOpcOrig)
					cOpcOrig  := AllTrim(Upper(Array2Str(aOpcOrig, .F.)))

					//Consome alternativo com mesmo opcional selecionado
					If cOpcional == cOpcOrig
						cProduto  := cProduto + "|" + cIDOpc
						nSobraPos := ::consumirProduto(cFilAux, nPeriodo, cProduto, nSobraAnt, @lCalculado, @lEncontrou, cChaveOrig, lForcaAlt, /*lCompraAlt*/, lTranAlt)
					EndIf
				EndIf
			Else
				Exit
			EndIf

			aRetAux  := ::oDados:retornaCampo("PRD", 1, Nil, {"PRD_COD", "PRD_IDOPC"}, @lErrorPRD, , , .T./*lProximo*/, , , .T. /*lVarios*/)
		EndDo

	EndIf

	::oDados:setaArea(aAreaMAT)
	::oDados:setaArea(aAreaPRD)

Return nSobraPos

/*/{Protheus.doc} registraSubstituicao
Registra a substituicao do produto pelo alternativo
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux     , character, codigo da filial para processamento
@param 02 - cProduto    , character, codigo do produto avaliado (alternativo de outro produto)
@param 03 - cAlternativo, character, codigo do produto avaliado (alternativo de outro produto)
@param 04 - nPeriodo    , numeric  , n�mero do per�odo atual
@param 05 - nConsOrig   , numeric  , quantidade substitu�da do produto original
@param 06 - nConsAlt    , numeric  , quantidade consumida do produto alternativo
@param 07 - nSobra      , numeric  , saldo da necessidade
@param 08 - nTransf     , numeric  , quantidade de transfer�ncia gerada para esta substitui��o
@param 09 - aTransf     , array    , Array informando a quantidade transferida de cada filial
/*/
METHOD registraSubstituicao(cFilAux, cProduto, cAlternativo, nPeriodo, nConsOrig, nConsAlt, nSobra, nTransf, aTransf) CLASS MrpDominio_Alternativo
	Local aRegistro  := {}
	Local aAlteDeman := {} //Alternativos da Demanda
	Local cOrigDeman := "" //Origem da demanda - Produto Original + Per�odo
	Local cKeyOri    := ""
	Local cChave     := ""
	Local nPos       := 0
	Local lError     := .F.

	Default nTransf := 0
	Default aTransf := {}

	cOrigDeman := "KEY_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)//Original + Periodo
	cChave     := cOrigDeman + "_" + AllTrim(cAlternativo)               //Original + Periodo + Alternativo

	//Atualiza controle de destinos de substituicao do produto origem
	/*
		OBSERVA��O:
		O array "aAlteDeman" deve ter a estrutura igual ao array "Self:aSubsTranf".
		Caso seja alterada a estrutura deste array, deve tamb�m ser modificada a estrutura do 
		array "Self:aSubsTranf"
	*/
	aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)
	If Empty(aAlteDeman)
		aAlteDeman := {{cAlternativo, 0, 0}}
		nPos       := 1
	Else
		nPos := aScan(aAlteDeman, {|x| x[1] == cAlternativo})
		If nPos == 0
			aAdd(aAlteDeman, {cAlternativo, 0, 0})
			nPos := Len(aAlteDeman)
		EndIf
	EndIf

	aAlteDeman[nPos][3] += nConsOrig

	If nTransf <> 0
		//Armazena total de transfer�ncias
		aAlteDeman[nPos][2] += nTransf
		If !Empty(aTransf)
			::gravaTransferenciaDisponivel(cOrigDeman, cAlternativo, aTransf)
		EndIf
	EndIf
	//Salva na global
	::oDados:oAlternativos:setItemAList("substituicoes_produtos", cOrigDeman, aAlteDeman, .F., .T., .F.)

	aSize(aAlteDeman, 0)

	//Registra dados da substituicao
	aRegistro := ::oDados:oAlternativos:getItemAList("substituicoes_dados", cChave, @lError)
	If lError
		aRegistro := {cProduto, cAlternativo, nPeriodo, nConsAlt, nConsOrig, ::cOrdem, -1, -1, nTransf}
	Else
		//Limita Substitui��o na quantidade dispon�vel ap�s aplica��o das pol�ticas de estoque
		If nConsOrig > 0 .And. aRegistro[7] >= 0 .And. nTransf == 0 .And. (aRegistro[4]+nConsAlt) - (aRegistro[7]) > 0

			If nTransf == 0
				nSobra       -= (aRegistro[4]+nConsAlt) - aRegistro[7]
				nConsAlt     := aRegistro[7]
				nConsOrig    := aRegistro[8]
			EndIf

			//Atualiza Valor da Substitui��o
			aRegistro[4] := nConsAlt
			aRegistro[5] := nConsOrig

			//Reseta Limites
			aRegistro[7] := -1
			aRegistro[8] := -1
		Else
			aRegistro[4] += nConsAlt
			aRegistro[5] += nConsOrig

		EndIf
		aRegistro[9] += nTransf
	EndIf
	::oDados:oAlternativos:setItemAList("substituicoes_dados", cChave, aRegistro, .F., .T., .F.)

	//Atualiza Total Substitui��o
	cKeyOri      := "KEY_ORI_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)//Original + Periodo
	::oDados:oAlternativos:setflag(cKeyOri, nConsOrig, .F., .T., .T.)//Soma

	If ::oDominio:oLogs:logValido("33")
		::oDominio:oLogs:log("Registra substituicao do produto " + RTrim(cProduto) + " pelo alternativo " + AllTrim(cAlternativo) + " no periodo " + cValToChar(nPeriodo)+": + " + cValToChar(nConsAlt) + "(Total "+cValToChar(aRegistro[4])+").", "33")
	EndIf

	aSize(aRegistro, 0)

Return

/*/{Protheus.doc} desfazSubstituicoes
Desfaz substitucoes anteriores deste produto alternativo quando saldo atual gera necessidade
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux   , caracter, codigo da filial para processamento
@param 02 - cProduto  , caracter, codigo do produto avaliado (alternativo de outro produto)
@param 03 - nSaldo    , numero  , saldo atual do produto no periodo
@param 04 - nPeriodo  , numero  , indicador do periodo atual
@param 05 - cSomentAlt, caracter, C�digo do produto alternativo para desfazer as substitui��es, quando em branco, desfaz todas.
@param 06 - aDesfezAlt, caracter, retorna por refer�ncia os alternativos desfeitos.
@param 07 - lWait     , Logic   , retorna por refer�ncia se o processo deve ser pausado.
@return nSobraPos, numero, retorna o saldo apos consumir o produto
/*/
METHOD desfazSubstituicoes(cFilAux, cProduto, nSaldo, nPeriodo, cSomentAlt, aDesfezAlt, lWait) CLASS MrpDominio_Alternativo

	Local aAlteDeman   := {}//Alternativos da Demanda
	Local aRegistro    := {}
	Local aSubstit     := {}
	Local cAlternativo := ""
	Local cChave       := ""
	Local cOrigDeman   := "KEY_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo) //Original + Periodo
	Local cKeyOri      := ""
	Local lLog5        := .F.
	Local lLog34       := .F.
	Local nInd         := 0
	Local nConsAlt     := 0
	Local nConsOrig    := 0
	Local nPos         := 0
	Local nTotalSubs   := 0

	Default cSomentAlt := ""
	Default aDesfezAlt := {}
	Default lWait      := .F.

	//Carrega no objeto "Self:oTranfDisp" as quantidades de transfer�ncias
	//que j� foram realizadas anteriormente para reutiliza��o
	::carregaTransferenciaDisponivel(cOrigDeman)

	//Prote��o de execu��o duplicada via oRastreio:dezfazExplosoes ou PCOCalcNec- Lock
	::oDados:oAlternativos:trava(cOrigDeman)

	//Atualiza controle de destinos de substituicao do produto origem
	aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)

	//Possui substituicoes
	If aAlteDeman != Nil .AND. !Empty(aAlteDeman)
		lLog5  := ::oDominio:oLogs:logValido("5" )
		lLog34 := ::oDominio:oLogs:logValido("34")

		//Recupera registros das substituicoes
		For nInd := 1 to Len(aAlteDeman)
			cAlternativo := aAlteDeman[nInd][1]
			cChave       := cOrigDeman + "_" + AllTrim(cAlternativo) //Original + Periodo + Alternativo
			aRegistro    := ::oDados:oAlternativos:getItemAList("substituicoes_dados", cChave)
			If aRegistro != Nil
				nTotalSubs++
				aAdd(aSubstit, {cChave, aClone(aRegistro)})
				If !Self:reservaAlternativo(cFilAux, aRegistro[2])
					lWait := .T.

					If lLog5
						::oDominio:oLogs:log(STR0175 + AllTrim(aRegistro[2]), "5") //"N�o obteve reserva do produto alternativo: "
					EndIf

					Exit
				EndIf
			EndIf
		Next

		If !lWait
			//Ordena da maior a menor
			aSubstit   := aSort(aSubstit, , , {|x,y| x[2][4] > y[2][4] })
			For nInd := 1 To nTotalSubs
				cChave       := aSubstit[nInd][1]
				aRegistro    := aSubstit[nInd][2]
				cAlternativo := aRegistro[2]
				nConsAlt     := aRegistro[4]
				nConsOrig    := aRegistro[5]

				If nConsOrig != 0 .AND. nConsAlt != 0 .AND. (Empty(cSomentAlt) .or. AllTrim(cAlternativo) == AllTrim(cSomentAlt))
					If lLog34
						::oDominio:oLogs:log(STR0112 + AllTrim(aRegistro[1]) + STR0110 + AllTrim(aRegistro[2]) + STR0111 + cValToChar(nPeriodo)+"': "+cValToChar(nConsOrig)+" <- "+cValToChar(nConsAlt)+".", "34") //"Desfaz a substituicao do produto '" + "' pelo produto '" + "' no periodo '"
					EndIf

					nSaldo := nSaldo - nConsOrig

					aAdd(aDesfezAlt, aClone(aRegistro))
					aRegistro[4] := 0
					aRegistro[5] := 0
					aRegistro[9] := 0
					::oDados:oAlternativos:setItemAList("substituicoes_dados", cChave, aRegistro, .F., .T., .F.)

					//Atualiza Matrizes
					::registraMatrizes(cFilAux, aRegistro[1], aRegistro[2], aRegistro[3], -nConsOrig, -nConsAlt)

				EndIf

				//Limpa conteudo global
				nPos := aScan(aAlteDeman, {|x| x[1] == cAlternativo})
				If nPos > 0
					aDel(aAlteDeman, nPos)
					aSize(aAlteDeman, (Len(aAlteDeman) - 1))
					::oDados:oAlternativos:setItemAList("substituicoes_produtos", cOrigDeman, aAlteDeman, .F., .T., .F.)
				EndIf
			Next

			//Atualiza Total Substitui��o
			cKeyOri := "KEY_ORI_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)//Original + Periodo
			::oDados:oAlternativos:setflag(cKeyOri, 0, .F., .T., .F.)//Reseta

		EndIf

		Self:liberaAlternativos()

		aSize(aAlteDeman, 0)
	EndIf

	//Prote��o de execu��o duplicada via oRastreio:dezfazExplosoes ou PCOCalcNec- UnLock
	::oDados:oAlternativos:destrava(cOrigDeman)

Return nSaldo

/*/{Protheus.doc} desfazParcialSubstituicao
Desfaz substitucoes anteriores deste produto alternativo quando saldo atual gera necessidade
@author    brunno.costa
@since     13/02/2020
@version 1.0
@param 01 - cFilAux     , caracter, c�digo da filial para processamento
@param 02 - cChaveSubs  , caracter, string com a chave de substitui��o do registro
@param 03 - cAlternativo, caracter, c�digo do produto alternativo relacionado
@param 04 - nQuantidade , numero  , quantidade para desfazer a substitui��o
@param 05 - nPeriodo    , numero  , indicador do periodo atual
@param 06 - aBaixaPorOP , array   , recebe e retorna por refer�ncia array aBaixaPorOP relacionado ao processo
@param 07 - lSetRecalc  , l�gico  , indica se deve setar o produto para recalcular.
@return nTotOrig, numero, retorna a quantidade total desfeita do produto original.
/*/
METHOD desfazParcialSubstituicao(cFilAux, cChaveSubs, cAlternativo, nQuantidade, nPeriodo, aBaixaPorOP, lSetRecalc) CLASS MrpDominio_Alternativo

	Local aAlteDeman := {}//Alternativos da Demanda
	Local aRegistro  := {}
	Local aSubstit   := {}
	Local cChave     := ""
	Local cOrigDeman := ""
	Local cProduto   := ""
	Local lLog34     := ::oDominio:oLogs:logValido("34")
	Local nInd       := 0
	Local nConsAlt   := 0
	Local nConsOrig  := 0
	Local nQtdOrig   := 0
	Local nTotOrig   := 0

	Default cAlternativo := ""
	Default lSetRecalc   := .F.

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		cProduto := SubStr(cChaveSubs, Self:oDominio:oMultiEmp:tamanhoFilial()+1, 90)
	Else
		cProduto := Left(cChaveSubs, 90)
	EndIf

	cOrigDeman := "KEY_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo) //Original + Periodo

	//Prote��o de execu��o duplicada via oRastreio:dezfazExplosoes ou PCOCalcNec- Lock
	::oDados:oAlternativos:trava(cOrigDeman)

	//Atualiza controle de destinos de substituicao do produto origem
	aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)

	//Possui substituicoes
	If aAlteDeman != Nil .And. !Empty(aAlteDeman)

		//Recupera registros das substituicoes
		For nInd := 1 to Len(aAlteDeman)
			If aAlteDeman[nInd][1] == cAlternativo
				cChave       := cOrigDeman + "_" + AllTrim(cAlternativo) //Original + Periodo + Alternativo
				aRegistro    := ::oDados:oAlternativos:getItemAList("substituicoes_dados", cChave)
				If aRegistro != Nil
					aAdd(aSubstit, {cChave, aClone(aRegistro)})
					aSize(aRegistro, 0)
				EndIf
			EndIf
		Next

		aSize(aAlteDeman, 0)

		//Ordena da maior a menor
		aSubstit := aSort(aSubstit, , , {|x,y| x[2][4] > y[2][4] })
		For nInd := 1 to Len(aSubstit)
			cChave       := aSubstit[nInd][1]
			aRegistro    := aSubstit[nInd][2]
			cAlternativo := aRegistro[2]

			If nQuantidade == 0
				Exit

			Else
				//Limite de consumo de alternativos
				aRegistro[7] := aRegistro[4]
				aRegistro[8] := aRegistro[5]
				nConsAlt     := aRegistro[7] //Quantidade Limite Alternativo
				nConsOrig    := aRegistro[8] //Quantidade Limite Original
				
				If nConsOrig != 0 .AND. nConsAlt != 0
					
					If lLog34
						::oDominio:oLogs:log("1:" + STR0112 + AllTrim(aRegistro[1]) + STR0110 + AllTrim(aRegistro[2]) + STR0111 + cValToChar(nPeriodo)+"': "+cValToChar(nConsOrig)+" <- "+cValToChar(nConsAlt)+". nQuantidade=" + cValToChar(nQuantidade), "34") //"Desfaz a substituicao do produto '" + "' pelo produto '" + "' no periodo '"
					EndIf

					If nConsOrig > nQuantidade
						nConsAlt    -= nQuantidade * nConsAlt / nConsOrig
						nConsOrig   -= nQuantidade
						nQtdOrig    := nQuantidade
						nQuantidade := 0

						aRegistro[7] := nConsAlt
						aRegistro[8] := nConsOrig
					Else
						nQuantidade  -= nConsOrig
						nQtdOrig     := nConsOrig
						nConsAlt     := 0
						nConsOrig    := 0

						aRegistro[7] := 0
						aRegistro[8] := 0
					EndIf

					aRegistro[9] := 0

					//Atualiza totalizador da quantidade de substitui��o.
					cKeyOri := "KEY_ORI_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo)//Original + Periodo
					::oDados:oAlternativos:setflag(cKeyOri, -Abs(nQtdOrig), .F., .T., .T.)//Soma

					nTotOrig += Abs(nQtdOrig)

					::oDados:oAlternativos:setItemAList("substituicoes_dados", cChave, aRegistro, .F., .T., .F.)

					If lSetRecalc
						::oDados:gravaPeriodosProd(cFilAux + cProduto, nPeriodo, , (nPeriodo - 1))
					EndIf

					If lLog34
						::oDominio:oLogs:log("2:" + STR0112 + AllTrim(aRegistro[1]) + STR0110 + AllTrim(aRegistro[2]) + STR0111 + cValToChar(nPeriodo)+"': "+cValToChar(nConsOrig)+" <- "+cValToChar(nConsAlt)+". nQuantidade=" + cValToChar(nQuantidade), "34") //"Desfaz a substituicao do produto '" + "' pelo produto '" + "' no periodo '"
					EndIf
				Endif
			Endif
			aSize(aRegistro, 0)
		Next

	EndIf

	//Prote��o de execu��o duplicada via oRastreio:dezfazExplosoes ou PCOCalcNec- UnLock
	::oDados:oAlternativos:destrava(cOrigDeman)

Return nTotOrig

/*/{Protheus.doc} existeSubstituicao
Verifica se existe substitui��o do cProduto pelo cAlternativo no nPeriodo
@author    brunno.costa
@since     06/01/2020
@version 1.0
@param 01 - cFilAux     , caracter, codigo da filial para processamento
@param 02 - cProduto    , caracter, codigo do produto avaliado (alternativo de outro produto)
@param 03 - cAlternativo, caracter, c�digo do produto alternativo para an�lise
@param 04 - nPeriodo    , numero  , indicador do periodo atual
@return lExiste, l�gico, indica se existe substitui��o do cProduto pelo cAlternativo no nPeriodo
/*/
METHOD existeSubstituicao(cFilAux, cProduto, cAlternati, nPeriodo) CLASS MrpDominio_Alternativo

	Local lReturn    := .F.
	Local cOrigDeman := "KEY_" + cFilAux + AllTrim(cProduto) + "_" + cValToChar(nPeriodo) //Original + Periodo
	Local aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)
	Local nPos       := 0

	If aAlteDeman != Nil
		nPos := aScan(aAlteDeman, {|x| x[1] == cAlternati})
		If nPos > 0
			lReturn := .T.
		EndIf

		aSize(aAlteDeman, 0)
	EndIf

Return lReturn

/*/{Protheus.doc} loopSubstituicaoAnterior
Identifica a ocorr�ncia de loop em substitui��o anterior que impede a substitui��o atual
Produto A com B Alternativo e com substitui��o
Produto B com C Alternativo e com substitui��o
Produto C com A Alternativo e com substitui��o
@author    brunno.costa
@since     06/01/2020
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto avaliado (alternativo de outro produto)
@param 02 - cAlternati, caracter, c�digo do produto alternativo para an�lise
@param 03 - nPeriodo  , numero  , indicador do periodo atual
@param 04 - cPath     , caracter, concatena��o de alternativos: cPath + chr(13) + aAlteDeman[nIndAlt]
@return lReturn, l�gico, indica se existe substitui��o do cProduto pelo cAlternativo no nPeriodo
/*/
METHOD loopSubstituicaoAnterior(cFilAux, cProduto, cAlternati, nPeriodo, cPath) CLASS MrpDominio_Alternativo

	Local aAlteDeman    := {}
	Local cOrigDeman    := "KEY_" + cFilAux + AllTrim(cAlternati) + "_" + cValToChar(nPeriodo) //Original + Periodo
	Local lReturn       := .F.
	Local nPos          := 0
	Local nIndAlt       := 0
	Local nAlternativos := 0

	Default cPath := ""

	aAlteDeman := ::oDados:oAlternativos:getItemAList("substituicoes_produtos", cOrigDeman)

	If aAlteDeman != Nil
		nPos := aScan(aAlteDeman, {|x| x[1] == cProduto})

		If nPos > 0
			lReturn := .T.
		ElseIf cAlternati $ cPath
			lReturn := .T.
		EndIf

		If !lReturn
			nAlternativos := Len(aAlteDeman)
			For nIndAlt := 1 to nAlternativos
				lReturn := ::loopSubstituicaoAnterior(cFilAux, cProduto, aAlteDeman[nIndAlt][1], nPeriodo, cPath + chr(13) + aAlteDeman[nIndAlt][1])
				If lReturn
					Exit
				EndIf
			Next
		EndIf

		aSize(aAlteDeman, 0)
	EndIf

Return lReturn

/*/{Protheus.doc} saldoOPNecessidade
Identifica o saldo dispon�vel da necessidade desta OP
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux  , caracter, c�digo da filial para processamento
@param 02 - cProduto , caracter, c�digo do produto original
@param 03 - cIDOpc   , caracter, c�digo do ID de opcionais.
@param 04 - nPeriodo , n�mero  , n�mero do per�odo para an�lise
@param 05 - cChave   , caracter, chave do documento pai da rastreabilidade: documento pai + chr(13) + TRT
@param 06 - cRegra   , caracter, retorna por refer�ncia a regra para consumo de alternativos:
								1- Valida Original; Valida Alternativo; Compra Original
								2- Valida Original; Valida Alternativo; Compra Alternativo
								3- Valida Alternativo; Compra Alternativo
@return nSldOp       , numero, saldo dispon�vel da necessidade desta OP
/*/
METHOD saldoOPNecessidade(cFilAux, cProduto, cIDOpc, nPeriodo, cChave, cRegra) CLASS MrpDominio_Alternativo
	Local nSldOp := 0
	Local aDados := {}
	Local lError := .F.
	Local cList  := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + cValToChar(nPeriodo)

	aDados := ::oDominio:oRastreio:oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)

	If !lError
		If AllTrim(aDados[::oDominio:oRastreio:getPosicao("TIPOPAI")]) == "OP"
			cRegra := aDados[::oDominio:oRastreio:getPosicao("REGRA_ALTERNATIVO")]
			nSldOp := aDados[::oDominio:oRastreio:getPosicao("NECESSIDADE")]
		EndIf
	EndIf

Return nSldOp

/*/{Protheus.doc} validaVigencia
Identifica se o alternativo possui data de vig�ncia v�lida
@author    brunno.costa
@since     29/10/2019
@version 1.0
@param 01 - cFilAux  , caracter, filial em processamento pelo mrp
@param 01 - nPeriodo , n�mero  , identificador num�rico do per�odo
@param 02 - dVigencia, data    , data de vig�ncia do alternativo
@return lDTValida, l�gico, indica se a data de vig�ncia � v�lida
/*/
METHOD validaVigencia(cFilAux, nPeriodo, dVigencia) CLASS MrpDominio_Alternativo
	Local lDTValida := Empty(dVigencia) .OR. dVigencia <= ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
Return lDTValida

/*/{Protheus.doc} aplicaFator
Aplica o fator de convers�o do alternativo
@author    brunno.costa
@since     29/10/2019
@version 1.0
@param 01 - nQuantidade , n�mero  , quantidade para convers�o
@param 02 - cTipoFator  , caracter, tipo do fator de convers�o:
                                    1 - Multiplica��o
									2 - Divis�o
@param 03 - nFator      , n�mero  , fator de convers�o
@param 04 - lInversa    , l�gico  , indica e deve inverter a convers�o (Utilizada nos casos onde deve desfazer a substitui��o)
@return nNovaQtde       , numero, saldo dispon�vel da necessidade desta OP
/*/
METHOD aplicaFator(nQuantidade, cTipoFator, nFator, lInversa) CLASS MrpDominio_Alternativo

	Local nNovaQtde := nQuantidade
	Local cTipo     := cTipoFator

	Default lInversa := .F.

	//Inverte fatores de convers�o ao desfazer
	If lInversa
		If cTipoFator == "1"
			cTipo := "2"

		ElseIf cTipoFator == "2"
			cTipo := "1"

		EndIf
	EndIf

	If cTipo == "1"     //Multiplica��o
		nNovaQtde := nQuantidade * nFator

	ElseIf cTipo == "2" //Divis�o
		nNovaQtde := nQuantidade / nFator

	EndIf

Return nNovaQtde

/*/{Protheus.doc} aplicaProdutoFator
Aplica o fator de convers�o do alternativo por Produto
@author    brunno.costa
@since     29/10/2019
@version 1.0
@param 01 - cFilAux     , caracter, c�digo da filial para processamento
@param 02 - nQuantidade , n�mero  , quantidade para convers�o
@param 03 - cTipoFator  , caracter, tipo do fator de convers�o:
                                    1 - Multiplica��o
									2 - Divis�o
@param 04 - nFator      , n�mero  , fator de convers�o
@param 05 - lInversa    , l�gico  , indica e deve inverter a convers�o (Utilizada nos casos onde deve desfazer a substitui��o)
@return nNovaQtde       , numero, saldo dispon�vel da necessidade desta OP
/*/
METHOD aplicaProdutoFator(cFilAux, cChaveProd, cAlternativo, nQuantidade, lInversa) CLASS MrpDominio_Alternativo

	Local aCampos       := {"ALT_ALTERN", "ALT_TPFAT", "ALT_FATOR"}
	Local aCposAlt      := {}
	Local aMinMaxAlt
	Local cChvMinMax    := ""
	Local cCodAltern
	Local cIndAlt
	Local cMaxAlt
	Local lErrorAlt     := .F.
	Local lUsaME        := Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
	Local nReturn       := nQuantidade

	If lUsaME
		cChvMinMax := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilAux) + cChaveProd
	Else
		cChvMinMax := cFilAux + cChaveProd
	EndIf

	aMinMaxAlt    := ::oDados:oAlternativos:getItemAList("min_max", cChvMinMax, @lErrorAlt) //Identifica exist�ncia de Alternativos e sequ�ncias: Min-Max

	If !lErrorAlt
		cIndAlt := aMinMaxAlt[1]
		cMaxAlt := aMinMaxAlt[2]
		While .T.
			If cIndAlt > cMaxAlt
				Exit
			EndIf

			aSize(aCposAlt, 0)
			cChvAltern := Self:chaveAlternativo(cFilAux, cChaveProd, cIndAlt)
			aCposAlt   := ::oDados:retornaCampo("ALT", 1, cChvAltern, aCampos, @lErrorALT,,,,,,.T.)

			If lErrorALT
				aCposAlt  := {}
				lErrorALT := .F.
				cIndAlt := Soma1(cIndAlt)
				Loop
			EndIf

			cCodAltern   := aCposAlt[1]
			cTipoFator   := aCposAlt[2]
			nFator       := aCposAlt[3]

			If cAlternativo == cCodAltern
				nReturn := Iif(nQuantidade ==0 , 0, ::aplicaFator(nQuantidade, cTipoFator, nFator, lInversa))
			EndIf

			cIndAlt := Soma1(cIndAlt)
		EndDo
	Endif

Return nReturn

/*/{Protheus.doc} chaveAlternativo
Monta a chave para busca de alternativos

@author lucas.franca
@since 14/10/2020
@version P12
@param cFilAux   , character, c�digo da filial para processamento
@param cProduto  , character, c�digo do produto
@param cSequencia, character, sequ�ncia do alternativo
@return cChave, character, chave para utiliza��o no alternativo
/*/
METHOD chaveAlternativo(cFilAux, cProduto, cSequencia) CLASS MrpDominio_Alternativo
	Local cChave := ""
	Local lUsaME := Self:oDominio:oMultiEmp:utilizaMultiEmpresa()

	If lUsaME
		cChave := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilAux)
	EndIf
	cChave += cProduto + cSequencia
Return cChave

/*/{Protheus.doc} reservaAlternativo
Faz a reserva de um produto alternativo para processamento

@author lucas.franca
@since 16/04/2021
@version P12
@param cFilAux   , character, c�digo da filial para processamento
@param cAlternat , character, c�digo do produto alternativo
@return lReservou, logic    , Indica se conseguiu fazer a reserva do produto
/*/
METHOD reservaAlternativo(cFilAux, cAlternat) CLASS MrpDominio_Alternativo
	Local cChaveAlt := cFilAux + cAlternat
	Local lReservou := .F.

	lReservou := Self:oDados:reservaProduto(cChaveAlt)
	If lReservou
		aAdd(Self:aReservas, cChaveAlt)
	EndIf

Return lReservou

/*/{Protheus.doc} liberaAlternativos
Libera a reserva dos produtos que foram realizadas pelo m�todo reservaAlternativo

@author lucas.franca
@since 16/04/2021
@version P12
@return Nil
/*/
METHOD liberaAlternativos() CLASS MrpDominio_Alternativo
	Local nIndex := 0
	Local nTotal := Len(Self:aReservas)

	For nIndex := 1 To nTotal
		Self:oDados:liberaProduto(Self:aReservas[nIndex])
	Next nIndex

	aSize(Self:aReservas, 0)
Return

/*/{Protheus.doc} quantidadeSubstituicaoAlternativo
Retorna a quantidade de substitui��o existente deste produto alternativo

@author lucas.franca
@since 20/04/2021
@version P12
@param aBaixaPorOP, Array  , Array com as informa��es de rastreabilidade.
@return nQuant    , Numeric, Quantidade de substitui��o deste alternativo
/*/
METHOD quantidadeSubstituicaoAlternativo(aBaixaPorOP) CLASS MrpDominio_Alternativo
	Local nQuant := 0
	Local nIndex := 0
	Local nTotal := Len(aBaixaPorOP)

	For nIndex := 1 To nTotal
		If aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] < 0
			nQuant += aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]
		EndIf
	Next nIndex
Return Abs(nQuant)

/*/{Protheus.doc} carregaTransferenciaDisponivel
Carrega as transfer�ncias de alternativos j� realizadas

@author lucas.franca
@since 23/08/2022
@version P12
@param cKey, Character, Chave do produto original
@return Nil
/*/
METHOD carregaTransferenciaDisponivel(cKey) CLASS MrpDominio_Alternativo
	Local aTransf    := {}
	Local aNames     := {}
	Local cChaveTran := ""
	Local nIndTrf    := 0
	Local nTotTrf    := 0
	Local nIndex     := 0
	Local nTotal     := 0

	//Se n�o utiliza multi-empresa n�o haver� transfer�ncias
	If !Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		Return Nil
	EndIf
	
	//Limpa JSON com os dados de quantidades de transfer�ncias de alternativos
	FreeObj(Self:oTranfDisp)
	Self:oTranfDisp := JsonObject():New()

	//Cria a lista caso n�o exista
	criaList("transferencias_alternativos", ::oDados:oAlternativos)

	//Recupera os dados das transfer�ncias j� realizadas para o produto original + per�odo
	aTransf := ::oDados:oAlternativos:getItemAList("transferencias_alternativos", cKey)
	If aTransf == Nil .Or. Empty(aTransf)
		Return Nil
	EndIf

	//Percorre os produtos alternativos
	nTotal := Len(aTransf)
	For nIndex := 1 To nTotal 
		/*
			Para cada produto alternativo, percorre as transfer�ncias de cada filial e amazena em oTranfDisp
			aTransf[nIndex][1] = c�digo do produto alternativo
			aTransf[nIndex][2] = Json com as quantidades transferidas. A chave do JSON � o c�digo da filial
			e o valor do JSON � a quantidade transferida.
		*/
		aNames := aTransf[nIndex][2]:GetNames()
		nTotTrf := Len(aNames)
		For nIndTrf := 1 To nTotTrf 
			//Monta cChaveTran com o c�digo da filial + c�digo do produto alternativo
			cChaveTran := aNames[nIndTrf] + RTrim(aTransf[nIndex][1])
			Self:oTranfDisp[cChaveTran] := aTransf[nIndex][2][aNames[nIndTrf]]
		
		Next nIndTrf
		aSize(aNames, 0)

	Next nIndex 
	FwFreeArray(aTransf)

Return Nil

/*/{Protheus.doc} gravaTransferenciaDisponivel
Grava as transfer�ncias de alternativos j� realizadas

@author lucas.franca
@since 23/08/2022
@version P12
@param 01 cKey     , Caracter, Chave do produto original
@param 02 cAlternat, Caracter, C�digo do alternativo
@param 03 aTransf  , Array   , Array com os dados de transfer�ncias
                               aTransf[nPos][1] - C�digo da filial
                               aTransf[nPos][2] - Quantidade de transfer�ncia
@return Nil
/*/
METHOD gravaTransferenciaDisponivel(cKey, cAlternat, aTransf) CLASS MrpDominio_Alternativo
	Local aTrfAlter := {}
	Local nIndTrf   := 0
	Local nTotTrf   := 0
	Local nPos      := 0
	
	//Cria a lista caso n�o exista
	criaList("transferencias_alternativos", ::oDados:oAlternativos)
	
	//Busca os dados j� existentes na global
	aTrfAlter := ::oDados:oAlternativos:getItemAList("transferencias_alternativos", cKey)
	If aTrfAlter == Nil .Or. Empty(aTrfAlter)
		aTrfAlter := {}
	EndIf
	/*
		Verifica se esse alternativo j� possui dados. Se n�o existir cria.
		aTrfAlter[nIndex][1] = c�digo do produto alternativo
		aTrfAlter[nIndex][2] = Json com as quantidades transferidas. A chave do JSON � o c�digo da filial
		e o valor do JSON � a quantidade transferida.
	*/
	nPos := aScan(aTrfAlter, {|x| x[1] == cAlternat})
	If nPos == 0
		aAdd(aTrfAlter, {cAlternat, JsonObject():New()})
		nPos := Len(aTrfAlter)
	EndIf
	
	//Adiciona as qtds de transfer�ncia de cada filial
	nTotTrf := Len(aTransf)
	For nIndTrf := 1 To nTotTrf
		//Armazena no JSON da 2� posi��o de aTrfAlter a quantidade 
		//de transfer�ncia de cada filial origem
		If !aTrfAlter[nPos][2]:HasProperty( aTransf[nIndTrf][1] )
			aTrfAlter[nPos][2][ aTransf[nIndTrf][1] ] := 0
		EndIf
		aTrfAlter[nPos][2][ aTransf[nIndTrf][1] ] += aTransf[nIndTrf][2]
	Next nIndTrf

	//Grava os dados na global.
	::oDados:oAlternativos:setItemAList("transferencias_alternativos", cKey, aTrfAlter, .F., .T., .F.)
	FwFreeArray(aTrfAlter)

Return Nil

/*/{Protheus.doc} criaList
Cria uma lista nas vari�veis globais com o nome especificado.

@type  Static Function
@author lucas.franca
@since 23/08/2022
@version P12
@param 01 cList , Caracter, C�digo da lista
@param 02 oDados, Object  , Objeto de dados para cria��o da lista
@return Nil
/*/
Static Function criaList(cList, oDados)
	If !oDados:existList(cList)
		oDados:createList(cList)
	EndIf
Return Nil
