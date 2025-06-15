#INCLUDE "TOTVS.CH"
#INCLUDE "QIPLaudosEnsaios.CH"

CLASS QIPLaudosEnsaios FROM LongNameClass
	
	DATA cNivelLaudo as STRING
	DATA oAPIManager as OBJECT
    DATA oWSRestFul  as OBJECT

	Method New(oWSRestFul)

	//M�todos P�blicos
	Method AvaliaAcessoATodaOperacao(nRecnoInspecao, cUsuario, cOperacao)
	Method BuscaDataDeValidadeDoLaudo(nRecnoInspecao, cUsuario, cError)
	Method ChecaTodasAsOperacoesComLaudos(cUsuario, nRecnoQPK)
	Method ChecaTodosOsLaboratoriosComLaudos(cUsuario, nRecnoQPK)
	Method DirecionaParaTelaDeLaudoPorInspecaoEUsuario(nRecnoInspecao, cUsuario, cError)
	Method ExcluiLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, cOperacao)
	Method ExcluiLaudoGeralEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao)
	Method ExcluiLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, lMedicao)
	Method ExcluiLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao)
	Method GravaLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, cParecer, cJustifica, nRejeicao, cValidade, lBaixaCQ)
	Method GravaLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cParecer, cJustifica, nRejeicao, cValidade)
	Method GravaLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cParecer, cJustifica, nRejeicao, cValidade)
	Method LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cNivelLaudo)
	Method ReabreInspecao(cUsuario, nRecnoQPK, cRoteiro, lMedicao)
	Method ReabreOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao)
	Method RetornaLaudoGeral(nRecnoQPK, cRoteiro)
	Method RetornaLaudoLaboratorio(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio)
	Method RetornaLaudoOperacao(nRecnoQPK, cRoteiro, cOperacao)
	Method RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos()
	Method SugereParecerLaudo(cNivelLaudo, nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, cError)
	Method UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, cError)
	Method ValidaDataDeValidadeDoLaudo(dShelfLife, cReportSelected, cError)

	//M�todos Internos
	Method ApagaAssinatura( cNumOP, cOperacao, cLabor)
	Method AtualizaCertificadoDaQualidade(lDesvincular)
	Method AtualizaFlagLegendaInspecao(cParecer)
	Method AvaliaLaudosOperacoes(cAlias, cParecer)
	Method AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina)
	Method AvaliaParecerLaboratorio(cAlias, cParecer)
	Method DirecionaParaTelaDeLaudo(nLabsInspecao, nOperInspecao, nLabsUInsp, cUsuario, lLaudGeral)
	Method GravaAssinaturaGeral(cUsuario, cLaudoGer, cNumOp)
	Method GravaAssinaturaLaboratorio(cUsuario, cLaudoLab, cNumOP, cLabor, cOperacao)
	Method GravaAssinaturaOperacao(cUsuario, cLaudoOpe, cNumOP, cOperacao)
	METHOD MovimentaEstoqueCQ(nRecnoQPK)
	Method QuantidadeLaboratoriosInspecao(nRecnoInspecao)
	Method QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario)
	Method QuantidadeOperacoesInspecao(nRecnoInspecao)
	Method ReabreInspecaoEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao, nOpc)
	Method RetornaListaOperacoes(nRecnoInspecao)
	Method SugereParecerLaudoGeral(nRecnoInspecao, cUsuario)
	Method SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario)
	Method SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario)
	Method ValidaRecnoValidoQPK(nRecnoQPK)

EndClass

METHOD New(oWSRestFul) CLASS QIPLaudosEnsaios
     Self:oWSRestFul  := oWSRestFul
	 Self:oAPIManager := QualityAPIManager():New(Nil, oWSRestFul)
Return Self

/*/{Protheus.doc} DirecionaParaTelaDeLaudo
M�todo Respons�vel por Realiza��o do Direcionamento para a P�gina de Laudo
@author brunno.costa
@since  17/10/2022
@param 01 - nLabsInspecao, n�mero, quantidade de laborat�rios relacionados a inspe��o atual
@param 02 - nOperInspecao, n�mero, quantidade de opera��es relacionadas a inspe��o atual
@param 03 - nLabsUInsp   , n�mero, quantidade de laborat�rios da inspe��o que o usu�rio tem acesso
@param 04 - cUsuario     , caracter, login do usu�rio para checagem
@param 05 - cError       , caracter, retorna por refer�ncia erro na compara��o
@return cPagina, caracter, caracter que indica o modelo de p�gina de Laudo que o usu�rio ser� direcionado, sendo:
                          L  - Laudo via Laborat�rio
						  O  - Laudo via Opera��o
						  G  - Laudo Geral
						  OA - Laudo de Opera��o Agrupado (Similar ao Geral, visualiza v�rias opera��es, mas n�o grava Laudo Geral)
						  LA - Laudo de Laborat�rio Agrupado (Similar ao via Opera��o, visualiza v�rios laborat�rios, mas n�o grava Laudo Geral nem de Opera��o)
/*/
Method DirecionaParaTelaDeLaudo(nLabsInspecao, nOperInspecao, nLabsUInsp, cUsuario, cError) CLASS QIPLaudosEnsaios
	Local cPagina      := ""
	Local cNivelLaudo  := ""
	Local cError       := ""

	Default nLabsInspecao := 1
	Default nOperInspecao := 1
	Default nLabsUInsp    := 1
	Default lLaudGeral    := .T.

	If nLabsInspecao == nLabsUInsp //Cen�rios SEM Restri��es de Acesso a Laborat�rios
		If     nLabsInspecao == 1 .AND. nOperInspecao == 1
			cPagina     := "L"
			cNivelLaudo := "L"
		ElseIf nLabsInspecao == 1 .AND. nOperInspecao >  1
			cPagina     := "G"
			cNivelLaudo := "G"
		ElseIf nLabsInspecao >  1 .AND. nOperInspecao == 1
			cPagina     := "O"
			cNivelLaudo := "O"
		ElseIf nLabsInspecao >  1 .AND. nOperInspecao >  1
			cPagina     := "G"
			cNivelLaudo := "G"
		EndIf
	Else                           //Cen�rios COM Restri��es de Acesso a Laborat�rios
		If nLabsInspecao >  1 .AND. nOperInspecao == 1
			cPagina     := "LA"
			cNivelLaudo := "L"
		ElseIf nLabsInspecao >  1 .AND. nOperInspecao >  1
			cPagina     := "OA"
			cNivelLaudo := "O"
		EndIf
	EndIf

	If !Self:UsuarioPodeGerarLaudo(cUsuario, "T")
		If cNivelLaudo == "G" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, @cError)
			cPagina         := "OA"
			cNivelLaudo     := "O"
		EndIf

		If cNivelLaudo == "O" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, @cError)
			cPagina         := "LA"
			cNivelLaudo     := "L"
		EndIf

		If cNivelLaudo == "L" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, @cError)
			cPagina         := ""
		EndIf

		If cNivelLaudo == "O" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
			cPagina         := "OA"
		EndIf

		If cNivelLaudo == "L" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
			cPagina         := "LA"
		EndIf
	EndIf


Return cPagina

/*/{Protheus.doc} DirecionaParaTelaDeLaudoPorInspecaoEUsuario
M�todo Respons�vel por Realiza��o do Direcionamento para a P�gina de Laudo - Por Inspe��o e Usu�rio
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, n�mero  , indica o Recno da Inspe��o
@param 02 - cUsuario      , caracter, login do usu�rio para checagem
@param 03 - cError        , caracter, retorna por refer�ncia erro na compara��o
@return cPagina, caracter, caracter que indica o modelo de p�gina de Laudo que o usu�rio ser� direcionado, sendo:
                          L  - Laudo via Laborat�rio
						  O  - Laudo via Opera��o
						  G  - Laudo Geral
						  OA - Laudo de Opera��o Agrupado (Similar ao Geral, visualiza v�rias opera��es, mas n�o grava Laudo Geral)
						  LA - Laudo de Laborat�rio Agrupado (Similar ao via Opera��o, visualiza v�rios laborat�rios, mas n�o grava Laudo Geral nem de Opera��o)
						  X  - Usu�rio sem acesso a gera��o de Laudos
/*/
Method DirecionaParaTelaDeLaudoPorInspecaoEUsuario(nRecnoInspecao, cUsuario, cError) CLASS QIPLaudosEnsaios
	
	Local cPagina       := "X"
	Local nLabsInspecao := Nil
	Local nLabsUInsp    := Nil
	Local nOperInspecao := Nil

	If Self:UsuarioPodeGerarLaudo(cUsuario, "X", @cError)
		nLabsInspecao := Self:QuantidadeLaboratoriosInspecao(nRecnoInspecao) 
		nLabsUInsp    := Self:QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario) 
		nOperInspecao := Self:QuantidadeOperacoesInspecao(nRecnoInspecao)
		cPagina       := Self:DirecionaParaTelaDeLaudo(nLabsInspecao, nOperInspecao, nLabsUInsp, cUsuario, @cError)
		cPagina       := Self:AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina)
	EndIf

Return cPagina

/*/{Protheus.doc} AvaliaNecessidadeDeDirecionarParaGeralERedireciona
Avalia Necessidade de Direcionar Para Tela Laudo de Inspe��o Geral, devido exist�ncia de laudo de Opera��o ou Laborat�rio
@author brunno.costa
@since  16/11/2022
@param 01 - nRecnoInspecao, n�mero  , indica o Recno da Inspe��o
@param 02 - cPagina       , caracter, p�gina de direcionamento atual
@return cPagina, caracter, p�gina correta para direcionamento
/*/
Method AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina) CLASS QIPLaudosEnsaios
	
	Local cFilQPM := xFilial("QPM")
	Local cFilQPL := xFilial("QPL")

	If cPagina == "L"
		QPK->(DbGoTo(nRecnoInspecao))
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(cFilQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
			While cFilQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER) == QPM->(QPM_FILIAL+QPM_OP+QPM_LOTE+QPM_NUMSER)
				If !Empty(QPM->QPM_LAUDO)
					cPagina := "G"
					Exit
				EndIf
				QPM->(DbSkip())
			EndDo
		EndIf

		If cPagina != "G"
			QPL->(dbSetOrder(3))
			If QPL->(dbSeek(cFilQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
				While cFilQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER) == QPL->(QPL_FILIAL+QPL_OP+QPL_LOTE+QPL_NUMSER)
					If !Empty(QPL->QPL_LAUDO) .AND. !Empty(QPL->QPL_LABOR)
						cPagina := "G"
						Exit
					EndIf
					QPL->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	
Return cPagina

/*/{Protheus.doc} AvaliaAcessoATodaOperacao
Avalia acesso a inclus�o de Laudo para toda a Opera��o
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, n�mero  , indica o Recno da Inspe��o
@param 02 - cUsuario      , caracter, login do usu�rio para checagem
@param 03 - cOperacao     , caracter, opera��o relacionada
@return lPermite, l�gico, indica se permite acesso a inclus�o de laudo em toda a opera��o
/*/
Method AvaliaAcessoATodaOperacao(nRecnoInspecao, cUsuario, cOperacao) CLASS QIPLaudosEnsaios
	
	Local lPermite      := Nil
	Local nLabsInspecao := Nil
	Local nLabsUInsp    := Nil

	nLabsInspecao := Self:QuantidadeLaboratoriosInspecao(nRecnoInspecao, cOperacao) 
	nLabsUInsp    := Self:QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario, cOperacao) 

	lPermite := nLabsUInsp >= nLabsInspecao
	
Return lPermite

/*/{Protheus.doc} QuantidadeLaboratoriosInspecao
Retorna a quantidade de laborat�rios relacionados a inspe��o
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, n�mero  , indica o Recno da Inspe��o
@param 02 - cOperacao     , caracter, indica o filtro de opera��o para an�lise
@return nLabsInspecao, n�mero, indica o n�mero de laborat�rios vinculados a inspe��o
/*/
Method QuantidadeLaboratoriosInspecao(nRecnoInspecao, cOperacao) CLASS QIPLaudosEnsaios
	
	Local cAlias        := ""
	Local cQuery        := ""
	Local nLabsInspecao := 0

	Default nRecnoInspecao := -1
	Default cOperacao      := ""

	If nRecnoInspecao > 0
		cQuery += " SELECT COUNT(QP7_LABOR) COUNTLAB
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "

		If !Empty(cOperacao)
			cQuery +=    " AND (QP7_OPERAC = '"+cOperacao+"')  "
		EndIf

		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  
		
		If !Empty(cOperacao)
			cQuery +=    " AND (QP8_OPERAC = '"+cOperacao+"')  "
		EndIf

		cQuery += " ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "


		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nLabsInspecao := (cAlias)->COUNTLAB
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nLabsInspecao

/*/{Protheus.doc} QuantidadeLaboratoriosUsuarioInspecao
Retorna a quantidade de laborat�rios relacionados a inspe��o que o usu�rio possui acesso
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, n�mero  , indica o Recno da Inspe��o
@param 02 - cUsuario      , caracter, login do usu�rio para checagem
@param 03 - cOperacao     , caracter, opera��o relacionada
@return nLabsUInsp, n�mero, indica o n�mero de laborat�rios vinculados a inspe��o que o usu�rio possui acesso
/*/
Method QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario, cOperacao) CLASS QIPLaudosEnsaios
	
	Local cAlias     := ""
	Local cQuery     := ""
	Local nLabsUInsp := 0

	Default nRecnoInspecao := -1
	Default cOperacao      := ""

	If nRecnoInspecao > 0
		
		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()

		cQuery += " SELECT COUNT(QP7_LABOR) COUNTLAB
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		If !Empty(cOperacao)
			cQuery +=    " AND (QP7_OPERAC = '"+cOperacao+"')  "
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cUsuario)
		EndIf

		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "

		If !Empty(cOperacao)
			cQuery +=    " AND (QP8_OPERAC = '"+cOperacao+"')  "
		EndIf
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cUsuario)
		EndIf

		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nLabsUInsp := (cAlias)->COUNTLAB
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nLabsUInsp

/*/{Protheus.doc} QuantidadeOperacoesInspecao
Retorna a quantidade de opera��es relacionadas a inspe��o
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, n�mero  , indica o Recno da Inspe��o
@return nOperInspecao, n�mero, indica o n�mero de opera��es vinculados a inspe��o
/*/
Method QuantidadeOperacoesInspecao(nRecnoInspecao) CLASS QIPLaudosEnsaios
	
	Local cAlias        := ""
	Local cQuery        := ""
	Local nOperInspecao := 0

	Default nRecnoInspecao := -1

	If nRecnoInspecao > 0
		cQuery += " SELECT COUNT(QP7_OPERAC) COUNTOPER
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nOperInspecao := (cAlias)->COUNTOPER
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nOperInspecao

/*/{Protheus.doc} UsuarioPodeGerarLaudo
Indica se o usu�rio pode gerar laudo
@author brunno.costa
@since  17/10/2022
@param 01 - cUsuario    , caracter, login do usu�rio para checagem
@param 02 - cNivelLaudo, caracter, indica o n�vel para an�lise:
								L - Laborat�rio
								O - Opera��o
								G - Geral
								X - Qualquer
								T - Todos
@param 03 - cError      , caracter, retorna por refer�ncia erro na compara��o
@return lLaudGeral, l�gico, indica se o usu�rio pode gerar laudo geral
/*/
Method UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, cError) CLASS QIPLaudosEnsaios
	
	Local cNivDefGer := Nil
	Local cNivDefLab := Nil
	Local cNivDefOpe := Nil
	Local cNivelDef  := SuperGetMV("MV_QPLDNIV", .F., "000")
	Local cNivelUser := Posicione("QAA", 6, Upper(cUsuario), "QAA_NIVEL")
	Local lLaudGeral := .F.
	Local lLaudLabor := .F.
	Local lLaudOpera := .F.
	Local lReturn    := .F.
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default cNivelLaudo := 'X'

	cNivelUser := Iif(Empty(cNivelUser), "0", cNivelUser)

	If Len(cNivelDef) < 3
		cError                            := STR0001 //"Falha na configura��o do par�metro MV_QPLDNIV."
		Self:oApiManager:cErrorMessage    := cError
	Else
		cNivDefLab := Substring(cNivelDef, 1, 1)
		cNivDefOpe := Substring(cNivelDef, 2, 1)
		cNivDefGer := Substring(cNivelDef, 3, 1)

		lLaudLabor := Val(cNivDefLab) <= Val(cNivelUser)
		lLaudOpera := Val(cNivDefOpe) <= Val(cNivelUser)
		lLaudGeral := Val(cNivDefGer) <= Val(cNivelUser)

		lReturn := Iif(cNivelLaudo == 'L', lLaudLabor                                  , lReturn)
		lReturn := Iif(cNivelLaudo == 'O', lLaudOpera                                  , lReturn)
		lReturn := Iif(cNivelLaudo == 'G', lLaudGeral                                  , lReturn)
		lReturn := Iif(cNivelLaudo == 'X', lLaudLabor .OR. lLaudOpera .OR. lLaudGeral  , lReturn)
		lReturn := Iif(cNivelLaudo == 'T', lLaudLabor .AND. lLaudOpera .AND. lLaudGeral, lReturn)
	EndIf

	ErrorBlock(oLastError)

Return lReturn

/*/{Protheus.doc} SugereParecerLaudo
Sugere Parecer para Laudo
@author brunno.costa
@since 25/10/2022
@param 01 - cNivelLaudo  , caracter, indica o n�vel de laudo que deseja ser gerado:
									L - Laborat�rio
									O - Opera��o
									G - Geral
									LA - Laborat�rios Agrupados
									OA - Opera��es Agrupadas
@param 02 - nRecnoInspecao, n�mero  , recno do registro da QPK relacionado a inspe��o 
@param 03 - aOperacoes    , array   , rela��o de opera��es para an�lise - em branco para todas
@param 04 - aLaboratorios , array   , rela��o de laborat�rios para an�lise - em branco para todos
@param 05 - cUsuario      , caracter, usu�rio processando a sugest�o de parecer
@param 06 - cError        , caracter, retorna por refer�ncia erro ocorrido
@return cParecer, l�gico, indica se o usu�rio pode gerar laudo geral
/*/
Method SugereParecerLaudo(cNivelLaudo, nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, cError) CLASS QIPLaudosEnsaios
	
	Local cOperacao  := ""
	Local cParecer   := "" //Default Ensaio N�o Obrigat�rio Vazio
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default nRecnoInspecao := -1
	Default aOperacoes     := {}
	Default aLaboratorios  := {}
	Default cError         := ""

	Begin Sequence
		If nRecnoInspecao > 0
			Self:cNivelLaudo := cNivelLaudo
			If cNivelLaudo == "L" .OR. cNivelLaudo == "LA"
				cOperacao := Iif(VALTYPE(aOperacoes) == "A",Iif(Len(aOperacoes) > 0, aOperacoes[1], ""),  aOperacoes) 
				cParecer  := Self:SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario)
			ElseIf cNivelLaudo == "O"
				cParecer := Self:SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario)
			ElseIf cNivelLaudo == "OA"
				cParecer := Self:SugereParecerLaudoGeral(nRecnoInspecao, cUsuario)
			Else
				cParecer := Self:SugereParecerLaudoGeral(nRecnoInspecao, cUsuario)
			EndIf
		EndIf
	Recover
		cParecer := "E"
		cError   := Iif(Empty(cError), STR0002, cError) //"Erro no processo de sugest�o de laudo."
	End Sequence 

	ErrorBlock(oLastError)

Return cParecer

/*/{Protheus.doc} SugereParecerLaudosLaboratorios
Sugere Parecer para Laudo(s) Laborat�rio(s)
@author brunno.costa
@since 25/10/2022
@param 01 - nRecnoInspecao, n�mero  , recno do registro da QPK relacionado a inspe��o 
@param 02 - cOperacao     , caracter, opera��o da inspe��o para checagem
@param 03 - cParecer      , caracter, parecer precedente a an�lise
@param 04 - aLaboratorios , array   , rela��o de laborat�rios para an�lise - em branco para todos
@param 05 - cUsuario      , caracter, usu�rio processando a sugest�o de parecer
@return cParecer, l�gico, sugest�o de paracer para o(s) Laborat�rio(s)
/*/
Method SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario) CLASS QIPLaudosEnsaios
	
	Local cAlias        := ""
	Local cCampos       := "*"
	Local cIDEnsaio     := ""
	Local cOrdem        := ""
	Local cTipoOrdem    := "ASC"
	Local nIndiceLabor  := 0
	Local nLaboratorios := 0
	Local nPagina       := 1
	Local nTamPag       := 999999
	Local oEnsaiosAPI   := EnsaiosInspecaoDeProcessosAPI():New(Nil)
	
	Default cParecer      := ""                  //Default Ensaio N�o Obrigat�rio Vazio
	Default aLaboratorios := {}

	nLaboratorios := Len(aLaboratorios)
	If nLaboratorios > 0
		For nIndiceLabor := 1 to nLaboratorios
			cAlias   := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, cOperacao, aLaboratorios[nIndiceLabor], cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
			cParecer := Self:AvaliaParecerLaboratorio(cAlias, cParecer)
			(cAlias)->(DbCloseArea())
			If cParecer == "E"                   //Se REPROVADO, encerra a An�lise
				Exit
			EndIf
		Next nIndiceLab
	Else
		cAlias   := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, cOperacao, "", cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
		cParecer := Self:AvaliaParecerLaboratorio(cAlias, cParecer)
		(cAlias)->(DbCloseArea())
	EndIf

Return cParecer

/*/{Protheus.doc} AvaliaParecerLaboratorio
Avalia Parecer do Laborat�rio
@author brunno.costa
@since 25/10/2022
@param 01 - cAlias  , caracter, alias com os registros dos Ensaios do laborat�rio
@param 02 - cParecer, caracter, parecer precedente a an�lise
@return cParecer, l�gico, sugest�o de paracer para o Laborat�rio
/*/
Method AvaliaParecerLaboratorio(cAlias, cParecer) CLASS QIPLaudosEnsaios

	Local cLaudo      := ""
	Local cParecerLab := ""
	Local cParecerMed := ""
	Local cStatus     := ""

	While !(cAlias)->(Eof()) .AND. cParecer != "E"
		cLaudo        := Iif((cAlias)->QPL_LAUDO == Nil, Nil, AllTrim((cAlias)->QPL_LAUDO))
		cStatus       := Iif((cAlias)->STATUS    == Nil, Nil, Alltrim((cAlias)->STATUS   ))
		
		If Self:cNivelLaudo <> "L"
			If cLaudo == "E"                        //Se houver LAUDO de reprova��o, considera REPROVADO e encerra a An�lise
				cParecerLab := "E"
				Exit

			ElseIf cLaudo == "A"                    //Se houver LAUDO de aprova��o, considera APROVADO e segue na an�lise
				cParecerLab := "A"

			EndIf
		EndIf

		If (cAlias)->ENSOBRI == "S" .AND. ((Self:cNivelLaudo == "L" .AND. Empty(cLaudo)) .OR. Empty(cLaudo))
			If !(cStatus $ "|A|R|")
				cParecerLab := "E"                  //Se o ENSAIO � OBRIGAT�RIO e est� PENDENTE, considera REPROVADO e encerra a An�lise
				Exit
			EndIf
		EndIf

		If cStatus == "A" .AND. cParecerMed != "E"  //Se houver MEDI��O aprovada, considera medi��o APROVADO
			cParecerMed := cStatus
		ElseIf cStatus == "R"
			cParecerMed := "E"                      //Se houver MEDI��O reprovada, considera medi��o REPROVADO
			Exit
		EndIf
		
		(cAlias)->(DbSkip())
	EndDo 
	cParecerLab := Iif(Empty(cParecerLab), cParecerMed, cParecerLab) //Se ainda n�o identificou parecer, considera parecer medi��es
	cParecer    := Iif(Empty(cParecer) .OR. (cParecer == "A" .AND. cParecerLab == "E");
	                                     , cParecerLab, cParecer)    //Laborat�rio atual for REPROVADO OU se n�o houver resultado anterior
Return cParecer

/*/{Protheus.doc} SugereParecerLaudosOperacoes
Sugere Parecer para Laudo(s) Opera��o(�es)
@author brunno.costa
@since 25/10/2022
@param 01 - nRecnoInspecao, n�mero  , recno do registro da QPK relacionado a inspe��o 
@param 02 - aOperacoes    , array   , opera��es relacionadas a inspe��o
@param 03 - aLaboratorios , array   , rela��o de laborat�rios para an�lise - em branco para todos
@param 04 - cUsuario      , caracter, usu�rio processando a sugest�o de parecer
@return cParecer, l�gico, sugest�o de paracer para a(s) opera��o(�es)
/*/
Method SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario) CLASS QIPLaudosEnsaios
	
	Local cOperacao  := ""
	Local cParecer   := ""                   //Default Ensaio N�o Obrigat�rio Vazio
	Local nIndiceOpe := 0
	Local nOperacoes := Len(aOperacoes)

	For nIndiceOpe := 1 to nOperacoes
		cOperacao := aOperacoes[nIndiceOpe]
		cParecer  := Self:SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario)
		If cParecer == "E"                   //Se REPROVADO, encerra a An�lise
			Exit
		EndIf
	Next nIndiceOpe

Return cParecer

/*/{Protheus.doc} SugereParecerLaudoGeral
Sugere Parecer para Laudo Geral
@author brunno.costa
@since 25/10/2022
@param 01 - nRecnoInspecao, n�mero  , recno do registro da QPK relacionado a inspe��o 
@param 02 - cUsuario      , caracter, usu�rio processando a sugest�o de parecer
@return cParecer, l�gico, sugest�o de paracer para a inspe��o
/*/
Method SugereParecerLaudoGeral(nRecnoInspecao, cUsuario) CLASS QIPLaudosEnsaios
	
	Local aOperacoes    := {}
	Local cAlias        := ""
	Local cParecer      := ""
	Local oInspecoesAPI := InspecoesDeProcessosAPI():New(Nil)

	cAlias   := oInspecoesAPI:CriaAliasPesquisa(cUsuario, "", "", "", "ASC", 1, 9999, "*", cValToChar(nRecnoInspecao), "") 
	cParecer := Self:AvaliaLaudosOperacoes(cAlias, cParecer)
	(cAlias)->(DbCloseArea())

	If cParecer <> "E" .AND. cParecer <> "A"
		aOperacoes := Self:RetornaListaOperacoes(nRecnoInspecao)
		cParecer   := Self:SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, Nil, cUsuario)
	EndIf

Return cParecer

/*/{Protheus.doc} AvaliaLaudosOperacoes
Avalia Parecer das Opera��es
@author brunno.costa
@since 25/10/2022
@param 01 - cAlias  , caracter, alias com os registros dos Ensaios do laborat�rio
@param 02 - cParecer, caracter, parecer precedente a an�lise
@return cParecer, l�gico, sugest�o de paracer para o Laborat�rio
/*/
Method AvaliaLaudosOperacoes(cAlias, cParecer) CLASS QIPLaudosEnsaios

	Local cLaudo        := ""
	Local cParecerOpe   := ""

	While !(cAlias)->(Eof()) .AND. cParecer != "E"
		cLaudo          := Iif((cAlias)->QPM_LAUDO == Nil, Nil, AllTriM((cAlias)->QPM_LAUDO))
		
		If cLaudo == "E" .OR. cLaudo == "R"                             //Se houver LAUDO de reprova��o, considera REPROVADO e encerra a An�lise
			cParecerOpe := "E"
			Exit

		ElseIf   cLaudo == Nil;
			.OR. cLaudo == "P" ;
			.OR. Empty(cLaudo)                                          //Se N�O HOUVER LAUDO, considera PENDENTE e segue na an�lise
			cParecerOpe := "P"

		ElseIf cLaudo == "A"                                            //Se houver LAUDO de aprova��o, considera APROVADO e segue na an�lise
			cParecerOpe := "A"

		EndIf
		
		cParecer    := Iif(Empty(cParecer) .OR. (cParecer == "A" .AND. cParecerOpe == "E");
											, cParecerOpe, cParecer)    //Opera��o atual for REPROVADO OU se n�o houver resultado anterior

		(cAlias)->(DbSkip())
	EndDo 
	cParecer    := Iif(Empty(cParecer) .OR. (cParecer == "A" .AND. cParecerOpe == "E");
											, cParecerOpe, cParecer)    //Opera��o atual for REPROVADO OU se n�o houver resultado anterior
Return cParecer

/*/{Protheus.doc} RetornaListaOperacoes
Retorna Lista de Opera��es Relacionadas a Inspe��o
@author brunno.costa
@since  25/10/2022
@param 01 - nRecnoInspecao, n�mero  , recno do registro da QPK relacionado a inspe��o 
@return aOperacoes, array, rela��o de opera��es relacionadas a inspe��o
/*/
Method RetornaListaOperacoes(nRecnoInspecao) CLASS QIPLaudosEnsaios
	
	Local aOperacoes := {}
	Local cAlias     := ""
	Local cQuery     := ""

	Default nRecnoInspecao := -1

	If nRecnoInspecao > 0
		cQuery += " SELECT DISTINCT QP7_OPERAC
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		While (cAlias)->(!Eof())
			aAdd(aOperacoes, (cAlias)->QP7_OPERAC)
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
	EndIf

Return aOperacoes


/*/{Protheus.doc} BuscaDataDeValidadeDoLaudo
Busca uma data de validade para sugerir na tela do laudo
@author rafael.hesse
@since  25/10/2022
@param 01 - cProductID, numerico, produto da inspe��o
@param 02 - cSpecificationVersion, caracter, Revis�o do produto
@return dDataVal, date, indica a data de validade que ser� sugerido
/*/
Method BuscaDataDeValidadeDoLaudo(cProductID, cSpecificationVersion) CLASS QIPLaudosEnsaios
	Local dDataVal := ""
	Local nDias    := 0
	Local oQltAPIManager := QualityAPIManager():New(nil, Self:oWSRestFul)

	If !(cProductID == Nil .And. cSpecificationVersion == Nil)
		DbSelectArea("QP6")
		QP6->(DbSetOrder(2))
		If QP6->(dbSeek(xFilial("QP6")+PADR( cProductID, oQltAPIManager:GetSx3Cache('QP6_PRODUT', 'X3_TAMANHO'))+cSpecificationVersion))
			If QP6->QP6_SHLF > 0
				DO Case
					Case QP6->QP6_TPSLIF == "1"
						nDias := QP6->QP6_SHLF
					Case QP6->QP6_TPSLIF == "2"
						nDias := QP6->QP6_SHLF * 30
					Case QP6->QP6_TPSLIF == "3"
						nDias := Int(QP6->QP6_SHLF / 24)
					Case QP6->QP6_TPSLIF == "4"
						nDias := QP6->QP6_SHLF * 365
				EndCase
				dDataVal := dDataBase + nDias
			EndIf
		EndIf
	EndIf

Return dDataVal

/*/{Protheus.doc} ValidaDataDeValidadeDoLaudo
Verifica se a data de validade do Laudo � valida
@author rafael.hesse
@since  25/10/2022
@param 01 - dDateShelfLife, date, data a ser validada.
@param 02 - cReportSelected, String, descri��o do laudo.
@param 03 - cError, String, mensagem de erro que ser� passada por referencia.
@return lReturn, l�gico, indica se a data � v�lida ou n�o.
/*/
Method ValidaDataDeValidadeDoLaudo(dShelfLife, cReportSelected, cError) CLASS QIPLaudosEnsaios
	Local lReturn        := .T.

	If !Empty(Alltrim(StrTran(cReportSelected,"'","")))
		If !Empty(dShelfLife) .And. dShelfLife < dDataBase
			lReturn := .F.
			cError  := STR0003 //"A data de validade do laudo n�o pode ser menor que a data atual"
		EndIf
	Else
		lReturn := .F.
		cError  := STR0004 //"Informe primeiro o parecer do Laudo para depois digitar a data de validade"
	EndIf

Return lReturn

/*/{Protheus.doc} GravaLaudoGeral
Grava Laudo Geral
@author brunno.costa
@since  01/11/2022
@param 01 - cUsuario  , caracter, Login do usu�rio
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro relacionado
@param 04 - cParecer  , caracter, parecer do laudo.
@param 05 - cJustifica, caracter, justificativa de altera��o da sugest�o de parecer do laudo
@param 06 - nRejeicao , n�mero  , quantidade rejeitada
@param 07 - cValidade , caracter, data de validade do laudo no formato JSON
@param 08 - lBaixaCQ , Logico, indica se o usu�rio deseja realizar a movimenta��o do estoque CQ.
@return lSucesso, l�gico, indica se conseguiu realizar a grava��o
/*/
Method GravaLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, cParecer, cJustifica, nRejeicao, cValidade, lBaixaCQ) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local lInclui    := Nil
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0005), Break(e)}) //"Falha na grava��o do Laudo Geral"

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default cParecer   := "E"
	Default cValidade  := ""
	Default nRejeicao  := 0
	Default cJustifica := ""

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)

			If lSucesso .AND. !QPK->(Eof())
				
				Self:AtualizaCertificadoDaQualidade(.F.)

				dbSelectArea("QPL")
				QPL->(dbSetOrder(3))
				lInclui := !QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+Space(GetSX3Cache("QPL_OPERAC", "X3_TAMANHO"))+Space(GetSX3Cache("QPL_LABOR", "X3_TAMANHO"))))

				RecLock("QPL", lInclui)
				QPL->QPL_FILIAL	:= cFiLQPL
				QPL->QPL_PRODUT	:= QPK->QPK_PRODUT
				QPL->QPL_DTENTR	:= QPK->QPK_EMISSA
				QPL->QPL_LOTE	:= QPK->QPK_LOTE
				QPL->QPL_OP 	:= QPK->QPK_OP
				QPL->QPL_OPERAC	:= Space(02)
				QPL->QPL_ROTEIR := cRoteiro
				QPL->QPL_NUMSER := QPK->QPK_NUMSER
				
				QPL->QPL_TAMLOT := cValToChar(QPK->QPK_TAMLOT)
				QPL->QPL_QTREJ  := cValToChar(nRejeicao)

				QPL->QPL_LAUDO  := cParecer
				QPL->QPL_JUSTLA := cJustifica
				QPL->QPL_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)

				If Empty(QPL->QPL_DTENLA)
					QPL->QPL_DTENLA := dDataBase
					QPL->QPL_HRENLA := Time()
				EndIf

				QPL->QPL_DTLAUD := dDataBase
				QPL->QPL_HRLAUD := Time()
				MsUnLock()
				If lBaixaCq
					Self:MovimentaEstoqueCQ(nRecnoQPK)
				EndIf
				Self:AtualizaFlagLegendaInspecao(cParecer,.F.,lBaixaCQ)
				Self:GravaAssinaturaGeral(cUsuario, cParecer, QPK->QPK_OP)

			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} GravaLaudoLaboratorio
Grava Laudo de Laborat�rio
@author brunno.costa
@since  02/11/2022
@param 01 - cUsuario    , caracter, Login de usu�rio
@param 02 - nRecnoQPK   , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro    , caracter, roteiro relacionado
@param 04 - cOperacao   , caracter, opera��o relacionada
@param 05 - cLaboratorio, caracter, recno da inspe��o relacionada na QPK
@param 06 - cParecer    , caracter, parecer do laudo.
@param 07 - cJustifica  , caracter, justificativa de altera��o da sugest�o de parecer do laudo
@param 08 - nRejeicao   , n�mero  , quantidade rejeitada
@param 09 - cValidade   , caracter, data de validade do laudo no formato JSON
@return lSucesso, l�gico, indica se conseguiu realizar a grava��o
/*/
Method GravaLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cParecer, cJustifica, nRejeicao, cValidade) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0008), Break(e)}) //"Falha na grava��o do Laudo de Laborat�rio"

	Default nRecnoQPK    := -1
	Default cLaboratorio := "LABFIS"
	Default cRoteiro     := "01"
	Default cParecer     := "E"
	Default cValidade    := ""
	Default nRejeicao    := 0
	Default cJustifica   := ""

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
			If lSucesso .AND. !QPK->(Eof())
				dbSelectArea("QPL")
				QPL->(dbSetOrder(3))
				lInclui := !QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao+cLaboratorio))
				
				RecLock("QPL", lInclui)
				QPL->QPL_FILIAL	:= cFiLQPL
				QPL->QPL_PRODUT	:= QPK->QPK_PRODUT
				QPL->QPL_DTENTR	:= QPK->QPK_EMISSA
				QPL->QPL_LOTE	:= QPK->QPK_LOTE
				QPL->QPL_OP 	:= QPK->QPK_OP
				QPL->QPL_NUMSER := QPK->QPK_NUMSER

				QPL->QPL_ROTEIR := cRoteiro
				QPL->QPL_OPERAC	:= cOperacao
				QPL->QPL_LABOR	:= cLaboratorio
				
				QPL->QPL_TAMLOT := cValToChar(QPK->QPK_TAMLOT)
				QPL->QPL_QTREJ  := cValToChar(nRejeicao)

				QPL->QPL_LAUDO  := cParecer
				QPL->QPL_JUSTLA := cJustifica
				QPL->QPL_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)


				If Empty(QPL->QPL_DTENLA)
					QPL->QPL_DTENLA := dDataBase
					QPL->QPL_HRENLA := Time()
				EndIf

				QPL->QPL_DTLAUD := dDataBase
				QPL->QPL_HRLAUD := Time()
				MsUnLock()
				Self:GravaAssinaturaLaboratorio(cUsuario, cParecer, QPK->QPK_OP, cLaboratorio, cOperacao)
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} GravaLaudoOperacao
Grava Laudo de Opera��o
@author brunno.costa
@since  02/11/2022
@param 01 - cUsuario    , caracter, Login de usu�rio
@param 02 - nRecnoQPK   , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro    , caracter, roteiro relacionado
@param 04 - cOperacao   , caracter, opera��o relacionada
@param 05 - cParecer    , caracter, parecer do laudo.
@param 06 - cJustifica  , caracter, justificativa de altera��o da sugest�o de parecer do laudo
@param 07 - nRejeicao   , n�mero  , quantidade rejeitada
@param 08 - cValidade   , caracter, data de validade do laudo no formato JSON
@return lSucesso, l�gico, indica se conseguiu realizar a grava��o
/*/
Method GravaLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cParecer, cJustifica, nRejeicao, cValidade) CLASS QIPLaudosEnsaios
	
	Local cFiLQPM    := xFilial("QPM")
	Local lInclui    := Nil
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0009), Break(e)}) //"Falha na grava��o do Laudo de Opera��o"

	Default nRecnoQPK    := -1
	Default cRoteiro     := "01"
	Default cParecer     := "E"
	Default cValidade    := ""
	Default nRejeicao    := 0
	Default cJustifica   := ""

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
			If lSucesso .AND. !QPK->(Eof())

				dbSelectArea("QPM")
				QPM->(dbSetOrder(3))
				lInclui := !QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao))
				
				RecLock("QPM", lInclui)
				QPM->QPM_FILIAL	:= cFiLQPM
				QPM->QPM_PRODUT	:= QPK->QPK_PRODUT
				QPM->QPM_DTPROD	:= QPK->QPK_EMISSA
				QPM->QPM_LOTE	:= QPK->QPK_LOTE
				QPM->QPM_OP 	:= QPK->QPK_OP
				QPM->QPM_NUMSER := QPK->QPK_NUMSER

				QPM->QPM_ROTEIR := cRoteiro
				QPM->QPM_OPERAC	:= cOperacao
				
				QPM->QPM_TAMLOT := cValToChar(QPK->QPK_TAMLOT)
				QPM->QPM_QTREJ  := cValToChar(nRejeicao)

				QPM->QPM_LAUDO  := cParecer
				QPM->QPM_JUSTLA := cJustifica
				QPM->QPM_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)


				If Empty(QPM->QPM_DTENLA)
					QPM->QPM_DTENLA := dDataBase
					QPM->QPM_HRENLA := Time()
				EndIf

				QPM->QPM_DTLAUD := dDataBase
				QPM->QPM_HRLAUD := Time()
				MsUnLock()
				Self:GravaAssinaturaOperacao(cUsuario, cParecer, QPK->QPK_OP, cOperacao)
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} AtualizaFlagLegendaInspecao
Atualiza FLAG de legenda da inspe��o - QPK_SITOP
@author brunno.costa
@since  01/11/2022
@param 01 - cParecer  , caracter, parecer do laudo.
@param 02 - lMedicao  , logico  , indica se a inspe��o possui medi��o
/*/
Method AtualizaFlagLegendaInspecao(cParecer, lMedicao, lMovimentouEstoque) CLASS QIPLaudosEnsaios
		Local aAreaSC2        := SC2->(GetArea())
		Local cQPKSITOP       := ""
		Local lLaudoParcial   := .F.
		Local oQIPA215Estoque := Nil
		Local oQIPA215Aux := Nil

		Default lMedicao 		   := .F.
		Default lMovimentouEstoque := .T.

		If !lMovimentouEstoque
			If FindClass("QIPA215Estoque")
				oQIPA215Estoque := QIPA215Estoque():New(-1)
				If oQIPA215Estoque:lIntegracaoEstoqueHabilitada
					cQPKSITOP := "6" //Movimentacao de estoque pendente
				EndIf
			EndIf
		EndIf

		dbSelectArea("SC2")
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+QPK->QPK_OP))
		If FindClass("QIPA215AuxClass")
			oQIPA215Aux := QIPA215AuxClass():New()
			lLaudoParcial := oQIPA215Aux:possuiLaudoParcialSemLaudoGeral(SC2->C2_ROTEIRO)
		EndIf

		RestArea(aAreaSC2)

		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 lLaudoParcial  , "7", cQPKSITOP) //Tem laudo parcial (opera��o ou laborat�rio sem geral)
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 lMedicao	    , "1", cQPKSITOP) //Tem medi��o e n�o tem laudo
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer == "A", "2", cQPKSITOP) //Aprovado
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer == "E", "3", cQPKSITOP) //Reprovado
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer == "U", "4", cQPKSITOP) //Urgente
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer == "B", "5", cQPKSITOP) //Condicional - Desvio Simples
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer == "C", "5", cQPKSITOP) //Condicional - Desvio Grave
		

		RecLock("QPK", .F.)
			QPK->QPK_SITOP := cQPKSITOP
		QPK->(MSUnLock())
Return

/*/{Protheus.doc} AtualizaCertificadoDaQualidade
Atualiza C�digo do Certificado da Qualidade
@author brunno.costa
@since  01/11/2022
@param 01 - lDesvincular, l�gico, indica se deve vincular (.F.) ou desvincular (.T.)
/*/
Method AtualizaCertificadoDaQualidade(lDesvincular) CLASS QIPLaudosEnsaios
	Default lDesvincular := .F.
	RecLock("QPK", .F.)
		If lDesvincular
			QPK->QPK_CERQUA := ""
		Else
		If Empty(QPK->QPK_CERQUA) .AND. !Empty(QPK->QPK_SITOP)
			QPK->QPK_CERQUA := QA_SEQUSX6("QIP_CEQU",TamSX3("C2_CERQUA")[1],"S", STR0007) //"Certificado Qualidade"
		EndIf
	EndIf
	QPK->(MSUnLock())
Return

/*/{Protheus.doc} RetornaLaudoGeral
Retorna Laudo Geral
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@param 02 - cRoteiro  , caracter, roteiro selecionado
@return oLaudo, json, objeto json com:
					  hasReport       , l�gico  , indica se possui laudo geral
					  reportLevel     , caracter, indica o n�vel do laudo geral:
												G - Geral
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de altera��o da sugest�o de parecer do laudo
					  rejectedQuantity, n�mero  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
/*/ 
Method RetornaLaudoGeral(nRecnoQPK, cRoteiro) CLASS QIPLaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0010)}) //"Falha na consulta do Laudo Geral"

	Default nRecnoQPK  := -1
	Default cRoteiro   := ""

	oLaudo['hasReport'] := .F.

	DbSelectArea("QPK")
	Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If !QPK->(Eof())
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If QPL->(dbSeek(xFilial("QPL")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+Space(GetSX3Cache("QPL_OPERAC", "X3_TAMANHO"))+Space(GetSX3Cache("QPL_LABOR", "X3_TAMANHO"))))
			If !Empty(QPL->QPL_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "G"
				oLaudo['rejectedQuantity'] := QPL->QPL_QTREJ
				oLaudo['reportSelected']   := QPL->QPL_LAUDO
				oLaudo['justification']    := QPL->QPL_JUSTLA
				oLaudo['shelfLife']        := QPL->QPL_DTVAL
			EndIf
		EndIf
	EndIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} RetornaLaudoLaboratorio
Retorna Laudo do Laborat�rio
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , n�mero  , recno da inspe��o relacionada na QPK
@param 02 - cRoteiro    , caracter, roteiro relacionado
@param 03 - cOperacao   , caracter, opera��o relacionada
@param 04 - cLaboratorio, caracter, recno da inspe��o relacionada na QPK
@return oLaudo, json, objeto json com:
					  hasReport       , l�gico  , indica se possui laudo de laborat�rio ou laudo geral
					  reportLevel     , caracter, indica o n�vel do laudo de laborat�rio:
												L - Laborat�rio
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de altera��o da sugest�o de parecer do laudo
					  rejectedQuantity, n�mero  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
/*/
Method RetornaLaudoLaboratorio(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio) CLASS QIPLaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0011)}) //"Falha na consulta do Laudo de Laborat�rio"

	Default nRecnoQPK    := -1
	Default cRoteiro     := "01"
	Default cOperacao    := "01"
	Default cLaboratorio := "LABFIS"

	oLaudo['hasReport'] := .F.

	DbSelectArea("QPK")
	Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If !QPK->(Eof())
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If QPL->(dbSeek(xFilial("QPL")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao+cLaboratorio))
			If !Empty(QPL->QPL_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "L"
				oLaudo['rejectedQuantity'] := QPL->QPL_QTREJ
				oLaudo['reportSelected']   := QPL->QPL_LAUDO
				oLaudo['justification']    := QPL->QPL_JUSTLA
				oLaudo['shelfLife']        := QPL->QPL_DTVAL
			EndIf
		EndIf
	EndIf

	If !oLaudo['hasReport']
		oLaudo := Self:RetornaLaudoOperacao(nRecnoQPK, cRoteiro, cOperacao)
	ENdIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} RetornaLaudoOperacao
Retorna Laudo da Opera��o
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , n�mero  , recno da inspe��o relacionada na QPK
@param 02 - cRoteiro    , caracter, roteiro relacionado
@param 03 - cOperacao   , caracter, opera��o relacionada
@return oLaudo, json, objeto json com:
					  hasReport       , l�gico  , indica se possui laudo de opera��o ou laudo geral
					  reportLevel     , caracter, indica o n�vel do laudo de opera��o:
												O - Opera��o
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de altera��o da sugest�o de parecer do laudo
					  rejectedQuantity, n�mero  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
@return lSucesso, l�gico, indica se conseguiu realizar a grava��o
/*/
Method RetornaLaudoOperacao(nRecnoQPK, cRoteiro, cOperacao) CLASS QIPLaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0012), Break(e)}) //"Falha na consulta do Laudo de Opera��o"

	Default nRecnoQPK := -1
	Default cRoteiro  := "01"
	Default cOperacao := "01"

	oLaudo['hasReport'] := .F.

	DbSelectArea("QPK")
	Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If !QPK->(Eof())
		dbSelectArea("QPM")
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(xFilial("QPM")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao))
			If !Empty(QPM->QPM_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "O"
				oLaudo['rejectedQuantity'] := QPM->QPM_QTREJ
				oLaudo['reportSelected']   := QPM->QPM_LAUDO
				oLaudo['justification']    := QPM->QPM_JUSTLA
				oLaudo['shelfLife']        := QPM->QPM_DTVAL
			EndIf
		EndIf
	EndIf

	If !oLaudo['hasReport']
		oLaudo := Self:RetornaLaudoGeral(nRecnoQPK, cRoteiro)
	ENdIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} ReabreInspecao
Reabertura da Inspe��o - Exclui todos os Laudos de Laborat�rio, Opera��o e Geral
@author brunno.costa
@since  05/11/2022
@param 01 - cUsuario  , n�mero  , caracter, login do usu�rio
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o ou se ela j� aberta
/*/ 
Method ReabreInspecao(cUsuario, nRecnoQPK, cRoteiro, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local cFiLQPM    := xFilial("QPM")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0013), Break(e)}) //"Falha na reabertura da Inspe��o"

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "X")
				DbSelectArea("QPK")
				lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
				If lSucesso .AND. !QPK->(Eof())
					Self:AtualizaFlagLegendaInspecao("", lMedicao)
					Self:AtualizaCertificadoDaQualidade(.T.)

					dbSelectArea("QPL")
					QPL->(dbSetOrder(3))
					If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
						While !QPL->(Eof())                    .AND.;
							QPL->QPL_FILIAL == cFiLQPL         .AND.;
							QPL->QPL_OP     == QPK->QPK_OP     .AND.;
							QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
							QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
							QPL->QPL_ROTEIR == cRoteiro

							Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)

							RecLock("QPL", .F.)
							QPL->(DbDelete())
							MsUnLock()

							QPL->(DbSkip())
						EndDo
					EndIf

					dbSelectArea("QPM")
					QPM->(dbSetOrder(3))
					If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
						While !QPM->(Eof())                    .AND.;
							QPM->QPM_FILIAL == cFiLQPM         .AND.;
							QPM->QPM_OP     == QPK->QPK_OP     .AND.;
							QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
							QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
							QPM->QPM_ROTEIR == cRoteiro

							Self:ApagaAssinatura(QPM->QPM_OP, QPM->QPM_OPERAC, QPM->QPM_LABOR)

							RecLock("QPM", .F.)
							QPM->(DbDelete())
							MsUnLock()

							QPM->(DbSkip())
						EndDo
					EndIf

				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := STR0015 //"Usu�rio acesso a todos os n�veis de laudos da inspe��o."
				Self:oApiManager:lWarningError := .T.
			EndIf
			
		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} ReabreOperacao
Reabertura da Inspe��o - Exclui todos os Laudos de Laborat�rio e Opera��o relacionados
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario  , n�mero  , caracter, login do usu�rio
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - cOperacao , caracter, operacao relacionada
@param 05 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o ou se ela j� aberta
/*/ 
Method ReabreOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local cFiLQPM    := xFilial("QPM")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0016 + cOperacao), Break(e)}) //"Falha na reabertura da Opera��o " + cOperacao

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default cOperacao  := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
			If lSucesso .AND. !QPK->(Eof())
				Self:AtualizaFlagLegendaInspecao("", lMedicao)
				Self:AtualizaCertificadoDaQualidade(.T.)

				dbSelectArea("QPL")
				QPL->(dbSetOrder(3))
				If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
					While !QPL->(Eof())                    .AND.;
						QPL->QPL_FILIAL == cFiLQPL         .AND.;
						QPL->QPL_OP     == QPK->QPK_OP     .AND.;
						QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
						QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
						QPL->QPL_ROTEIR == cRoteiro

						If QPL->QPL_OPERAC == cOperacao
							Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)

							RecLock("QPL", .F.)
							QPL->(DbDelete())
							MsUnLock()

						EndIf

						QPL->(DbSkip())
					EndDo
				EndIf

				dbSelectArea("QPM")
				QPM->(dbSetOrder(3))
				If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
					While !QPM->(Eof())                    .AND.;
						QPM->QPM_FILIAL == cFiLQPM         .AND.;
						QPM->QPM_OP     == QPK->QPK_OP     .AND.;
						QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
						QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
						QPM->QPM_ROTEIR == cRoteiro

						If QPM->QPM_OPERAC == cOperacao
							Self:ApagaAssinatura(QPM->QPM_OP, QPM->QPM_OPERAC, QPM->QPM_LABOR)

							RecLock("QPM", .F.)
							QPM->(DbDelete())
							MsUnLock()

						EndIf

						QPM->(DbSkip())
					EndDo
				EndIf

			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} LaudoPodeSerEditado
Indica se o Laudo Pode ser Editado
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , n�mero  , recno da inspe��o relacionada na QPK
@param 02 - cRoteiro    , caracter, roteiro relacionado
@param 03 - cOperacao   , caracter, opera��o relacionada
@param 04 - cLaboratorio, caracter, laborat�rio relacionado
@param 05 - cNivelLaudo, caracter, caracter que indica o modelo de p�gina de Laudo:
                          L  - Laudo via Laborat�rio
						  O  - Laudo via Opera��o
						  G  - Laudo Geral
						  OA - Laudo de Opera��o Agrupado (Similar ao Geral, visualiza v�rias opera��es, mas n�o grava Laudo Geral)
						  LA - Laudo de Laborat�rio Agrupado (Similar ao via Opera��o, visualiza v�rios laborat�rios, mas n�o grava Laudo Geral nem de Opera��o)
@return lPermite, l�gico, indica se conseguiu reabrir a inspe��o ou se ela j� aberta
/*/ 
Method LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cNivelLaudo) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local cFiLQPM    := xFilial("QPM")
	Local lPermite   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0014)}) //"Falha na consulta de permiss�o para edi��o de laudo"
	Local lLaudoLab  := .F.
	Local lLaudoOpe  := .F.
	Local lLaudoGer  := .F.

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	
	lPermite := Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If lPermite .AND. !QPK->(Eof())
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
			While !QPL->(Eof())                    .AND.;
				QPL->QPL_FILIAL == cFiLQPL         .AND.;
				QPL->QPL_OP     == QPK->QPK_OP     .AND.;
				QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
				QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
				QPL->QPL_ROTEIR == cRoteiro

				If (Empty(cOperacao) .OR. QPL->QPL_OPERAC == cOperacao .OR. Empty(QPL->QPL_OPERAC)) .AND. !Empty(QPL->QPL_LAUDO)
					If Empty(QPL->QPL_LABOR)
						lLaudoGer := .T.
					ElseIf Empty(cLaboratorio) .OR. QPL->QPL_LABOR == cLaboratorio
						lLaudoLab := .T.
					EndIf
				EndIf

				QPL->(DbSkip())
			EndDo
		EndIf

		dbSelectArea("QPM")
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
			While !QPM->(Eof())                    .AND.;
				QPM->QPM_FILIAL == cFiLQPM         .AND.;
				QPM->QPM_OP     == QPK->QPK_OP     .AND.;
				QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
				QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
				QPM->QPM_ROTEIR == cRoteiro

				If (Empty(cOperacao) .OR. QPM->QPM_OPERAC == cOperacao) .AND. !Empty(QPM->QPM_LAUDO)
					lLaudoOpe  := .T.
				EndIf

				QPM->(DbSkip())
			EndDo
		EndIf

	EndIf

	lPermite := Iif("L" $ cNivelLaudo, !lLaudoOpe .AND. !lLaudoGer, lPermite)
	lPermite := Iif("O" $ cNivelLaudo, !lLaudoGer                 , lPermite)
	lPermite := Iif("G" $ cNivelLaudo, .T.                        , lPermite)

	ErrorBlock(oLastError)
	
Return lPermite

/*/{Protheus.doc} ValidaRecnoValidoQPK
Indica se o Laudo Pode ser Editado
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , n�mero  , recno da inspe��o relacionada na QPK
@return lValido, l�gico, indica se o RECNO � v�lido na QPK
/*/ 
Method ValidaRecnoValidoQPK(nRecnoQPK) CLASS QIPLaudosEnsaios
	Local lValido := .T.
	QPK->(DbGoTo(nRecnoQPK))
	If QPK->(Eof())
		lValido := .F.
		Self:oAPIManager:cDetailedMessage := STR0006 + cValToChar(nRecnoQPK) + "." //"Informe um recno de inspe��o v�lido da tabela QPK: "
		Self:oAPIManager:cErrorMessage    := STR0006 + cValToChar(nRecnoQPK) + "." //"Informe um recno de inspe��o v�lido da tabela QPK: "
	EndIf
Return lValido

/*/{Protheus.doc} GravaAssinaturaLaboratorio
Realiza a grava��o da assinatura do laborat�rio
@author rafael.hesse
@since  06/11/2022
@param 01 - cUsuario    , caracter, Login do usu�rio
@param 02 - cLaudoLab   , caracter, Laudo do Laborat�rio
@param 03 - cNumOP      , caracter, c�digo da Ordem de Produ��o
@param 04 - cLabor      , caracter, laborat�rio relacionado
@param 05 - cOperacao   , caracter, opera��o relacionada
/*/ 
Method GravaAssinaturaLaboratorio(cUsuario, cLaudoLab, cNumOP, cLabor, cOperacao) CLASS QIPLaudosEnsaios
Local aArea     := {}
Local lLauNivel := GetNewpar("MV_QPLDNIV","000") <> "000"

	If lLauNivel 
		aArea := GetArea()
		DbSelectArea("QQL")
		QQL->(DbSetOrder(2))
		If QQL->(DbSeek(xFilial("QQL") + cNumOp + cOperacao + cLabor)) .And. !Empty(cLaudoLab)
			If cLaudoLab <> QQL->QQL_LAUDO
				RecLock("QQL",.F.)
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoLab
				QQL->(MsUnLock())
			EndIf	
		Else
			RecLock("QQL",.T.)
				QQL->QQL_FILIAL  := xFilial("QQL")
				QQL->QQL_OP      := cNumOp
				QQL->QQL_OPERAC  := cOperacao
				QQL->QQL_LAB     := cLabor
				QQL->QQL_RESP    := cUsuario
				QQL->QQL_DATA    := dDataBase
				QQL->QQL_HORA    := Left(Time(),5)
				QQL->QQL_LAUDO   := cLaudoLab
			QQL->(MsUnLock())
		EndIf
		RestArea(aArea)
	EndIf

Return

/*/{Protheus.doc} GravaAssinaturaOperacao
Realiza a grava��o da assinatura da Opera��o
@author rafael.hesse
@since  06/11/2022
@param 01 - cUsuario    , caracter, Login do usu�rio
@param 02 - cLaudoOpe   , caracter, Laudo da Opera��o
@param 03 - cNumOP      , caracter, c�digo da Ordem de Produ��o
@param 04 - cOperacao   , caracter, opera��o relacionada
/*/ 
Method GravaAssinaturaOperacao(cUsuario, cLaudoOpe, cNumOP, cOperacao) CLASS QIPLaudosEnsaios
Local aArea     := {}
Local cLabor    := Space(TamSx3("QQL_LAB")[1])
Local lLauNivel := GetNewpar("MV_QPLDNIV","000") <> "000"

	If lLauNivel 
		aArea := GetArea()
		DbSelectArea("QQL")
		QQL->(DbSetOrder(2))
		If QQL->(DbSeek(xFilial("QQL") + cNumOp + cOperacao + cLabor)) .And. !Empty(cLaudoOpe)
			If cLaudoOpe <> QQL->QQL_LAUDO
				RecLock("QQL",.F.)
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoOpe
				QQL->(MsUnLock())
			EndIf	
		Else
			RecLock("QQL",.T.)
				QQL->QQL_FILIAL  := xFilial("QQL")
				QQL->QQL_OP      := cNumOp
				QQL->QQL_OPERAC  := cOperacao
				QQL->QQL_LAB     := cLabor
				QQL->QQL_RESP    := cUsuario
				QQL->QQL_DATA    := dDataBase
				QQL->QQL_HORA    := Left(Time(),5)
				QQL->QQL_LAUDO   := cLaudoOpe
			QQL->(MsUnLock())
		EndIf
		RestArea(aArea)
	EndIf

Return

/*/{Protheus.doc} GravaAssinaturaGeral
Realiza a grava��o da assinatura do laudo Geral
@author rafael.hesse
@since  06/11/2022
@param 01 - cUsuario    , caracter, Login do usu�rio
@param 02 - cLaudoGer   , caracter, Laudo Geral
@param 03 - cNumOP      , caracter, c�digo da Ordem de Produ��o
/*/ 
Method GravaAssinaturaGeral(cUsuario, cLaudoGer, cNumOp) CLASS QIPLaudosEnsaios
Local aArea     := {}
Local cLabor    := Space(TamSx3("QQL_LAB")[1])
Local cOperacao := Space(TamSx3("QQL_OPERAC")[1])
Local lLauNivel := GetNewpar("MV_QPLDNIV","000") <> "000"

	If lLauNivel
		aArea := GetArea()
		DbSelectArea("QQL")
		QQL->(DbSetOrder(2))
		If !Empty(cLaudoGer)
			If QQL->(!DbSeek(xFilial("QQL")+cNumOp+cOperacao+cLabor))
				RecLock("QQL",.T.)
					QQL->QQL_FILIAL  := xFilial("QQL")
					QQL->QQL_OP      := cNumOp
					QQL->QQL_OPERAC  := cOperacao
					QQL->QQL_LAB     := cLabor
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoGer
				QQL->(MsUnLock())
			ElseIf QQL->QQL_LAUDO <> cLaudoGer
				RecLock("QQL",.F.)
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoGer
				QQL->(MsUnLock())
			EndIf
		EndIf
		RestArea(aArea)
	EndIf

Return


/*/{Protheus.doc} ExcluiLaudoLaboratorio
Exclui Laudo do Laborat�rio
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario     , caracter, login de usu�rio relacionado
@param 02 - nRecnoQPK    , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro     , caracter, roteiro selecionado
@param 04 - cOperacao    , caracter, operacao relacionada
@param 05 - cLaboratorio , caracter, laborat�rio relacionado
@param 06 - lMedicao     , logico  , indica se tem medicao
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o ou se ela j� aberta
/*/ 
Method ExcluiLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0017 + cLaboratorio + STR0018 + cOperacao), Break(e)}) //"Falha Exclus�o Laudo do Laborat�rio " + cLaboratorio + " da Opera��o " + cOperacao

	Default nRecnoQPK    := -1
	Default cRoteiro     := "01"
	Default cOperacao    := "01"
	Default cLaboratorio := "LABFIS"
	Default lMedicao     := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "L")
				If Self:LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, "", "L")
					DbSelectArea("QPK")
					lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
					If lSucesso .AND. !QPK->(Eof())

						dbSelectArea("QPL")
						QPL->(dbSetOrder(3))
						If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
							While !QPL->(Eof())                    .AND.;
								QPL->QPL_FILIAL == cFiLQPL         .AND.;
								QPL->QPL_OP     == QPK->QPK_OP     .AND.;
								QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
								QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
								QPL->QPL_ROTEIR == cRoteiro

								If QPL->QPL_OPERAC == cOperacao .AND. cLaboratorio == QPL->QPL_LABOR .AND. !Empty(QPL->QPL_LABOR)
									Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)
									
									RecLock("QPL", .F.)
									QPL->(DbDelete())
									MsUnLock()

								EndIf

								QPL->(DbSkip())
							EndDo
						EndIf
						Self:AtualizaFlagLegendaInspecao("", lMedicao)
						Self:AtualizaCertificadoDaQualidade(.T.)

					EndIf
				Else
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := STR0019 //"Este laudo n�o pode ser exclu�do, reabra a Inspe��o ou exclua os laudos superiores."
					Self:oApiManager:lWarningError := .T.
				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := STR0020 //"Usu�rio sem acesso a gera��o de laudo de laborat�rio."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso


/*/{Protheus.doc} ExcluiLaudoOperacao
Exclui Laudo de Opera��o
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario  , caracter, login de usu�rio relacionado
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - cOperacao , caracter, operacao relacionada
@param 05 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o ou se ela j� aberta
/*/ 
Method ExcluiLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cFiLQPM    := xFilial("QPM")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0021 + cOperacao), Break(e)}) //"Falha Exclus�o Laudo da Opera��o "

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default cOperacao  := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "O")
				If Self:LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, "", "O")
					DbSelectArea("QPK")
					lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
					If lSucesso .AND. !QPK->(Eof())

						dbSelectArea("QPM")
						QPM->(dbSetOrder(3))
						If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
							While !QPM->(Eof())                    .AND.;
								QPM->QPM_FILIAL == cFiLQPM         .AND.;
								QPM->QPM_OP     == QPK->QPK_OP     .AND.;
								QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
								QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
								QPM->QPM_ROTEIR == cRoteiro

								If QPM->QPM_OPERAC == cOperacao
									Self:ApagaAssinatura(QPM->QPM_OP, QPM->QPM_OPERAC, QPM->QPM_LABOR)

									RecLock("QPM", .F.)
									QPM->(DbDelete())
									MsUnLock()

								EndIf

								QPM->(DbSkip())
							EndDo
						EndIf
						Self:AtualizaFlagLegendaInspecao("", lMedicao)
						Self:AtualizaCertificadoDaQualidade(.T.)

					EndIf
				Else
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := STR0022 //"Este laudo n�o pode ser exclu�do, reabra a Inspe��o ou exclua o Laudo Geral."
					Self:oApiManager:lWarningError := .T.
				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := STR0023 //"Usu�rio sem acesso a gera��o de laudo de opera��o."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso


/*/{Protheus.doc} ExcluiLaudoGeral
Exclui Laudo Geral
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario  , caracter, login de usu�rio relacionado
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o ou se ela j� aberta
/*/ 
Method ExcluiLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0025), Break(e)}) //"Falha na Exclus�o do Laudo Geral"

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "G")
				DbSelectArea("QPK")
				lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
				If lSucesso .AND. !QPK->(Eof())

					dbSelectArea("QPL")
					QPL->(dbSetOrder(3))
					If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
						While !QPL->(Eof())                    .AND.;
							QPL->QPL_FILIAL == cFiLQPL         .AND.;
							QPL->QPL_OP     == QPK->QPK_OP     .AND.;
							QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
							QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
							QPL->QPL_ROTEIR == cRoteiro

							If Empty(QPL->QPL_OPERAC) .AND. Empty(QPL->QPL_LABOR)
								Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)								
								
								RecLock("QPL", .F.)
								QPL->(DbDelete())
								MsUnLock()

							EndIf

							QPL->(DbSkip())
						EndDo
					EndIf
					Self:AtualizaFlagLegendaInspecao("", lMedicao)
					Self:AtualizaCertificadoDaQualidade(.T.)

				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := STR0024 //"Usu�rio sem acesso a gera��o de laudo geral."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} ApagaAssinatura
Realiza a Exclus�o da Assinatura do Laudo
@author rafael.hesse
@since  16/11/2022
@param 01 - cNumOP      , caracter, c�digo da Ordem de Produ��o
@param 02 - cOperacao   , caracter, opera��o relacionada
@param 03 - cLabor      , caracter, laborat�rio relacionado
/*/ 
Method ApagaAssinatura( cNumOP, cOperacao, cLabor) CLASS QIPLaudosEnsaios
Local aArea     :=  GetArea()

	DbSelectArea("QQL")
	QQL->(DbSetOrder(2))
	If QQL->(DbSeek(xFilial("QQL") + cNumOp + cOperacao + cLabor))
		RecLock("QQL",.F.)
			QQL->(DbDelete())
		QQL->(MsUnLock())
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} ChecaTodosOsLaboratoriosComLaudos
Checa se Todos os Laborat�rios Possuem Laudos
@author brunno.costa
@since  20/11/2022
@param 01 - cUsuario  , caracter, login de usu�rio relacionado
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@return lTodosLaudos, l�gico, indica que todos os laborat�rios possuem laudos
/*/ 
Method ChecaTodosOsLaboratoriosComLaudos(cUsuario, nRecnoQPK) CLASS QIPLaudosEnsaios
	Local cAlias                         := Nil
	Local lTodosLaudos                   := .T.
	Local oEnsaiosInspecaoDeProcessosAPI := EnsaiosInspecaoDeProcessosAPI():New(Nil)

	cAlias := oEnsaiosInspecaoDeProcessosAPI:CriaAliasEnsaiosPesquisa(nRecnoQPK, "", "", "", "", 1, 999999, "*", "", cUsuario)
	While (cAlias)->(!Eof())
		If Empty((cAlias)->QPL_LAUDO)
			lTodosLaudos := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo

Return lTodosLaudos


/*/{Protheus.doc} ChecaTodasAsOperacoesComLaudos
Checa se Todas as Opera��es Possuem Laudos
@author brunno.costa
@since  20/11/2022
@param 01 - cUsuario  , caracter, login de usu�rio relacionado
@param 02 - nRecnoQPK , n�mero  , recno da inspe��o relacionada na QPK
@return lTodosLaudos, l�gico, indica que todas as opera��es possuem laudos
/*/ 
Method ChecaTodasAsOperacoesComLaudos(cUsuario, nRecnoQPK) CLASS QIPLaudosEnsaios

    Local cAlias                   := Nil
	Local lTodosLaudos             := .T.
	Local oInspecoesDeProcessosAPI := InspecoesDeProcessosAPI():New(Nil)

	cAlias := oInspecoesDeProcessosAPI:CriaAliasPesquisa(cUsuario, "", "", "", "", 1, 999999, "*", cValToChar(nRecnoQPK))
	While (cAlias)->(!Eof())
		If Empty((cAlias)->QPM_LAUDO)
			lTodosLaudos := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo

Return lTodosLaudos

/*/{Protheus.doc} RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos
Verifica se h� integra��o com outros m�dulos e retorna as mensagens de falha
@author rafael.hesse
@since  17/11/2022
@return aMensagens, Array, Informa as mensagems de integra��o que ser�o exibidas. Caso vazio n�o ser� apresentado.
/*/ 
Method RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos() CLASS QIPLaudosEnsaios
	
	Local aMensagens := {}

	If GetMv("MV_QINTQMT") == 'S'
		 aAdd(aMensagens, STR0026) //"Integra��o com Metrologia ativa. Utilize o Protheus para informar os instrumentos utilizados e preencher ou editar o Laudo"
	EndIf

	If GetMv("MV_QIPQNC") == '1'
		aAdd(aMensagens, STR0027) //"Integra��o com Controle de N�o Conformidades ativa. Utilize o Protheus para informar NCs e preencher ou editar o Laudo"
	EndIf

Return aMensagens

/*/{Protheus.doc} MovimentaEstoqueCQ
Movimenta Estoque da QPK Automaticamente
@author rafael.hesse
@since  21/03/2022
@param 01 - nRecnoQPK, num�rico, recno do registro na QPK
@Return - lSucesso, L�gico, indica se conseguiu realizar a movimenta��o
/*/
METHOD MovimentaEstoqueCQ(nRecnoQPK) CLASS QIPLaudosEnsaios
Local bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0031 + e:Description), Break(e)}) // STR0031 - "Falha na movimenta��o de Estoque do CQ. "
Local lSucesso        := .F.
Local oQIPA215Estoque := Nil

	If FindClass("QIPA215Estoque")
		oQIPA215Estoque := QIPA215Estoque():New(-1)
		QPL->(DbGoTop())//For�a desposicionamento na QPL para tratar bug de posicionamento em registro de mem�ria desatualizado
		oQIPA215Estoque:movimentaPendenciasEstoqueCQAutomaticamente(nRecnoQPK)

		QPK->(DbGoto(nRecnoQPK))
		QPL->(DbSetOrder(1))
		QPL->(DbSeek(xFilial("QPL")+QPK->QPK_OP ))
		Self:AtualizaFlagLegendaInspecao(QPL->QPL_LAUDO, .F., .T.)
		lSucesso := .T.

	EndIf
	ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} ReabreInspecaoEEstornaMovimentosCQ
Fun��o respons�vel pela reabertura da inspe��o e estorno das movimenta��es de Estoque do CQ
@type  Function
@author brunno.costa / thiago.rover
@since 07/03/2023 / 22/03/2023
@param 01 - cLogin, caracter, indica o Login do usu�rio da QAA
@param 02 - nRecnoQPK, num�rico, indica o RECNO do registro da QPK relacionado
@param 03 - cRoteiro, caracter, indicar o c�digo do roteiro do registro da QPK relacionado
@param 04 - lMedicao, l�gico, indicar se a inspe��o cont�m medi��es
@param 05 - nOpc, num�rico, indica quando a chamada foi realizada via APP
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o
/*/
METHOD ReabreInspecaoEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao, nOpc) CLASS QIPLaudosEnsaios 
		
	Local lSucesso        := .F.
	Local lTemMovi        := .F.
	Local oQIPA215Estoque := Nil

	Default nOpc := 3

	BEGIN TRANSACTION
		oQIPA215Estoque := QIPA215Estoque():New(nOpc)
		
		lSucesso := oQIPA215Estoque:estornaTodosMovimentosDeCQ(nRecnoQPK, @lTemMovi) 
			
		If lTemMovi .And. !lSucesso .And. nOpc == -1
		  // STR0028 - Verifique se h� saldo de estoque suficente para realiza��o dos estornos e repita o processo.
			Self:oApiManager:cErrorMessage := STR0028
			Self:oApiManager:lWarningError := .T.
		else
			lSucesso := .T.
		Endif

		IF !(lSucesso := Iif(lSucesso, Self:ReabreInspecao(cLogin, nRecnoQPK, cRoteiro, lMedicao), lSucesso)) .And. nOpc == -1
		 // STR0029 - N�o foi possivel realizar a reabertura da inspe��o. Verifique se a inspe��o est� sendo editada por outro usu�rio."
			Self:oApiManager:cErrorMessage := STR0029
			Self:oApiManager:lWarningError := .T.
		Endif

		If !lSucesso
			DisarmTransaction()
		EndIf
	END TRANSACTION

Return lSucesso

/*/{Protheus.doc} ExcluiLaudoGeralEEstornaMovimentosCQ
Fun��o respons�vel pela exclus�o do laudo geral e estorno das movimenta��es de Estoque do CQ no APP
@type  Function
@author thiago.rover
@since 22/03/2023
@param 01 - cLogin, caracter, indica o Login do usu�rio da QAA
@param 02 - nRecnoQPK, num�rico, indica o RECNO do registro da QPK relacionado
@param 03 - cRoteiro, caracter, indicar o c�digo do roteiro do registro da QPK relacionado
@param 04 - lMedicao, l�gico, indicar se a inspe��o cont�m medi��es
@return lSucesso, l�gico, indica se conseguiu reabrir a inspe��o
/*/
METHOD ExcluiLaudoGeralEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao) CLASS QIPLaudosEnsaios 

	Local lSucesso        := .F.
	Local lTemMovi        := .F.
	Local oQIPA215Estoque := QIPA215Estoque():New(-1)

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	BEGIN TRANSACTION
		lSucesso := oQIPA215Estoque:estornaTodosMovimentosDeCQ(nRecnoQPK, @lTemMovi)
			
		If lTemMovi .And. !lSucesso
		 // STR0028 - Verifique se h� saldo de estoque suficente para realiza��o dos estornos e repita o processo.
			Self:oApiManager:cErrorMessage := STR0028
			Self:oApiManager:lWarningError := .T.
		else
			lSucesso := .T.
		Endif

		IF !(lSucesso := Iif(lSucesso, Self:ExcluiLaudoGeral(cLogin, nRecnoQPK, cRoteiro, lMedicao), lSucesso))
		 // STR0030 - N�o foi possivel realizar a exclus�o do laudo geral. Verifique se a inspe��o est� sendo editada por outro usu�rio."
			Self:oApiManager:cErrorMessage := STR0030
			Self:oApiManager:lWarningError := .T.
		Endif

		If !lSucesso
			DisarmTransaction()
		EndIf
	END TRANSACTION

Return lSucesso
