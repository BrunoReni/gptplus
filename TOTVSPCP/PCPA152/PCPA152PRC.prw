#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH" 

#DEFINE FACTORY_OPC_BASE 1

#DEFINE QUANTIDADE_ETAPAS 5

/*/{Protheus.doc} PCPA152PRC
"Processamento Programação da Produção"

@type  WSCLASS
@author Lucas Fagundes
@since 01/02/2023
@version P12
/*/
WSRESTFUL PCPA152PRC DESCRIPTION STR0001 FORMAT APPLICATION_JSON // "Processamento Programação da Produção"
	WSDATA atual       AS BOOLEAN OPTIONAL
	WSDATA programacao AS STRING  OPTIONAL

	WSMETHOD POST START;
		DESCRIPTION STR0002; // "Inicia processamento da programação da produção";
		WSSYNTAX "/api/pcp/v1/pcpa152prc/start" ;
		PATH "/api/pcp/v1/pcpa152prc/start" ;
		TTALK "v1"

	WSMETHOD GET STATUS;
		DESCRIPTION STR0003; // "Retorna o status de uma programação";
		WSSYNTAX "/api/pcp/v1/pcpa152prc/status/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/status/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST CANCEL;
		DESCRIPTION STR0085; //"Cancela o processamento da programação"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/cancel/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/cancel/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST CONTINUAR;
		DESCRIPTION STR0137; // "Continua o processamento de uma programação"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/continuar/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/continuar/{programacao}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} POST START /api/pcp/v1/pcpa152prc/start
"Inicia processamento da programação da produção"

@type  WSMETHOD
@author Lucas Fagundes
@since 01/02/2023
@version P12
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD POST START WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local cBody     := ""
	Local lReturn   := .T.
	Local oBody     := Nil

	Self:SetContentType("application/json")

	cBody := Self:getContent()

	oBody := JsonObject():New()
	oBody:FromJson(cBody)

	BEGIN SEQUENCE
		aReturn := processa(oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} processa
Função responsavel por iniciar o processamento

@type  Static Function
@author Lucas Fagundes
@since 01/02/2023
@version P12
@param oStart, Object, Json com o parâmetros para execução do programa.
@return aReturn, Array, Array com as informações para o retorno do rest.
/*/
Static Function processa(oStart)
	Local aError    := {}
	Local aReturn   := Array(3)
	Local oProcesso := Nil
	Local oRetorno  := JsonObject():New()

	oProcesso := PCPA152Process():executaProgramacao(Nil, oStart)

	If oProcesso:oProcError:possuiErro()
		aError := oProcesso:oProcError:getaError()

		oRetorno["message"        ] := aError[1][2]
		oRetorno["detailedMessage"] := aError[1][3]

		aReturn[1] := .F.
		aReturn[2] := 500
		aReturn[3] := oRetorno:toJson()

		FwFreeArray(aError)
		oProcesso:oProcError:destroy()
	Else
		oRetorno["items"  ] := P152GetSta(oProcesso:retornaProgramacao())
		oRetorno["hasNext"] := .F.

		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oRetorno:toJson()
	EndIf
	oProcesso:destroy()

	FreeObj(oStart)
	FreeObj(oProcesso)
Return aReturn

/*/{Protheus.doc} GET STATUS /api/pcp/v1/pcpa152prc/status/{programacao}
"Retorna o status de uma programação"

@type  WSMETHOD
@author Lucas Fagundes
@since 01/02/2023
@version P12
@param 01 programacao, Caracter, Número da programação
@param 02 atual      , Lógico  , Indica se deve retornar o status somente da etapa atual
@return lReturn      , Lógico  , Indica se teve sucesso na requisição.
/*/
WSMETHOD GET STATUS PATHPARAM programacao QUERYPARAM atual WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getStatus(Self:programacao, Self:atual)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getStatus
Função responsavel por obter o progresso de uma programação.
@type  Function
@author Lucas Fagundes
@since 07/02/2023
@version P12
@param 01 cProg , Caracter, Código da programação que irá buscar.
@param 02 lAtual, Lógico  , Indica se deve retornar o status somente da etapa atual.
@return aReturn, Array, Array com as informações para o retorno do rest.
/*/
Static Function getStatus(cProg, lAtual)
	Local aReturn    := Array(3)
	Local oProgresso := P152GetSta(cProg, lAtual)
	Local oReturn    := JsonObject():New()

	If oProgresso == Nil
		oReturn["message"        ] := STR0005 // "Programação não encontrada"
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["items"  ] := oProgresso
		oReturn["hasNext"] := .F.

		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	EndIf

	FreeObj(oProgresso)
Return aReturn

/*/{Protheus.doc} P152GetSta
Retorna o status do processamento de uma programação.

@author Lucas Fagundes
@since 06/02/2023
@version P12
@param 01 cProg , Caracter, Código da programação que irá consultar
@param 02 lAtual, Logico  , Indica se deve retornar o status somente da etapa atual.
@return oJsRet, Object, Json com o progresso das etapas
/*/
Function P152GetSta(cProg, lAtual)
	Local cAlias     := GetNextAlias()
	Local cBanco     := TCGetDB()
	Local cQryCondic := ""
	Local cQryFields := ""
	Local cQryOrder  := ""
	Local oJsAux     := Nil
	Local oJsRet     := Nil
	Default lAtual   := .F.

	cQryFields := " T4X.T4X_PROG,"   + ;
		          " T4X.T4X_STATUS," + ;
		          " T4X.T4X_DTINI,"  + ;
		          " T4X.T4X_HRINI,"  + ;
		          " T4X.T4X_DTFIM,"  + ;
		          " T4X.T4X_HRFIM,"  + ;
		          " T4X.T4X_USER,"   + ;
		          " T4Z.T4Z_ETAPA,"  + ;
		          " T4Z.T4Z_SEQ,"    + ;
		          " T4Z.T4Z_STATUS," + ;
		          " T4Z.T4Z_PERCT,"  + ;
		          " T4Z.T4Z_MSG,"    + ;
		          " T4Z.T4Z_DTINI,"  + ;
		          " T4Z.T4Z_HRINI,"  + ;
		          " T4Z.T4Z_DTFIM,"  + ;
		          " T4Z.T4Z_HRFIM,"  + ;
		          " T4Z.T4Z_MSGDET"

	cQryCondic := RetSqlName("T4X") + " T4X"                 + ;
	       " LEFT OUTER JOIN " + RetSqlName("T4Z") + " T4Z"  + ;
	         " ON T4Z.T4Z_PROG   = T4X.T4X_PROG"             + ;
	        " AND T4Z.T4Z_FILIAL = '" + xFilial("T4Z") + "'" + ;
	        " AND T4Z.D_E_L_E_T_ = ' '"
	
	If lAtual
		cQryCondic += " AND T4Z.T4Z_STATUS <> '2'"
	EndIf
	
	cQryCondic += " WHERE T4X.T4X_PROG   = '" + cProg          + "'" + ;
	                " AND T4X.T4X_FILIAL = '" + xFilial("T4X") + "'" + ;
	                " AND T4X.D_E_L_E_T_ = ' '"

	cQryOrder := " T4Z.T4Z_SEQ "

	If lAtual
		If Upper(cBanco) $ 'ORACLE'
			cQryCondic += " AND ROWNUM <= 1"
		ElseIf Upper(cBanco) $ 'POSTGRES'
			cQryOrder += " LIMIT 1"
		Else
			cQryFields := " TOP 1 " + cQryFields
		EndIf
	EndIf

	cQryFields := "%" + cQryFields + "%"
	cQryCondic := "%" + cQryCondic + "%"
	cQryOrder  := "%" + cQryOrder  + "%"

	BeginSql Alias cAlias
		%noparser%
		SELECT %Exp:cQryFields%
		  FROM %Exp:cQryCondic%
		 ORDER BY %Exp:cQryOrder%
	EndSql

	If (cAlias)->(!EoF())
		oJsRet := JsonObject():New()
		oJsRet["programacao"] := RTrim((cAlias)->T4X_PROG)
		oJsRet["idStatus"   ] := RTrim((cAlias)->T4X_STATUS)
		oJsRet["status"     ] := PCPA152Process():getDescricaoStatus(oJsRet["idStatus"])
		oJsRet["dataInicial"] := RTrim((cAlias)->T4X_DTINI)
		oJsRet["horaInicial"] := RTrim((cAlias)->T4X_HRINI)
		oJsRet["dataFinal"  ] := RTrim((cAlias)->T4X_DTFIM)
		oJsRet["horaFinal"  ] := RTrim((cAlias)->T4X_HRFIM)
		oJsRet["userId"     ] := RTrim((cAlias)->T4X_USER)
		oJsRet["percentual" ] := Round((((cAlias)->T4Z_SEQ - 1) * (100 / QUANTIDADE_ETAPAS)) + ((cAlias)->T4Z_PERCT / QUANTIDADE_ETAPAS), 2)
		oJsRet["etapas"     ] := {}
	EndIf

	While (cAlias)->(!EoF())
		oJsAux := JsonObject():New()
		oJsAux["etapa"      ] := RTrim((cAlias)->T4Z_ETAPA)
		oJsAux["descEtapa"  ] := PCPA152Process():getDescricaoEtapa(oJsAux["etapa"])
		oJsAux["sequencia"  ] := (cAlias)->T4Z_SEQ
		oJsAux["idStatus"   ] := RTrim((cAlias)->T4Z_STATUS)
		oJsAux["status"     ] := PCPA152Process():getDescricaoStatus(oJsAux["idStatus"], oJsAux["etapa"])
		oJsAux["percentual" ] := Round((cAlias)->T4Z_PERCT, 2)
		oJsAux["mensagem"   ] := RTrim((cAlias)->T4Z_MSG)
		oJsAux["mensagemDet"] := RTrim((cAlias)->T4Z_MSGDET)
		oJsAux["dataInicio" ] := SToD((cAlias)->T4Z_DTINI)
		oJsAux["horaInicio" ] := RTrim((cAlias)->T4Z_HRINI)
		oJsAux["dataFim"    ] := SToD((cAlias)->T4Z_DTFIM)
		oJsAux["horaFim"    ] := RTrim((cAlias)->T4Z_HRFIM)

		aAdd(oJsRet["etapas"], oJsAux)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oJsRet

/*/{Protheus.doc} POST CANCEL /api/pcp/v1/pcpa152prc/cancel/{programacao}
Cancela o processamento da programação

@type WSMETHOD
@author Marcelo Neumann
@since 07/03/2023
@version P12
@param programacao, Caracter, Número da programação
@return lReturn   , Lógico  , Indica se teve sucesso na requisição.
/*/
WSMETHOD POST CANCEL PATHPARAM programacao WSSERVICE PCPA152PRC
	Local aReturn   := Array(3)
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local lReturn   := .T.
	Local oProcesso := Nil
	Local oReturn   := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If PCPA152Process():processamentoFactory(Self:programacao, FACTORY_OPC_BASE, @oProcesso)
			oProcesso:cancelaExecucao()
			oReturn["message"        ] := STR0040 //"Processamento cancelado."
			oReturn["detailedMessage"] := ""

			aReturn[1] := .T.
			aReturn[2] := 200
			aReturn[3] := oReturn:toJson()
		EndIf
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	P152ClnStc()
Return lReturn

/*/{Protheus.doc} POST CONTINUAR /api/pcp/v1/pcpa152prc/continuar
Continua o processamento de uma programação.

@type  WSMETHOD
@author Lucas Fagundes
@since 01/02/2023
@version P12
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD POST CONTINUAR PATHPARAM programacao WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local cBody     := ""
	Local lReturn   := .T.
	Local oBody     := Nil

	Self:SetContentType("application/json")

	cBody := Self:getContent()

	oBody := JsonObject():New()
	oBody:FromJson(cBody)

	BEGIN SEQUENCE
		aReturn := continuar(Self:programacao, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} continuar
Retoma o processamento de uma programação e inicia o cálculo do tempo das operações.
@type  Static Function
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param oBody, Object, Json com os parâmetros para iniciar o calculo do tempo das operações.
@return aReturn, Array, Array com as informações da requisição
/*/
Static Function continuar(cProg, oBody)
	Local aError    := {}
	Local aReturn   := Array(3)
	Local cMsg      := ""
	Local cMsgDet   := ""
	Local lSucesso  := .T.
	Local nCode     := 0
	Local oProcesso := Nil
	Local oRetorno  := JsonObject():New()

	oProcesso := PCPA152Process():executaProgramacao(cProg, oBody)

	If oProcesso:oProcError:possuiErro()
		aError := oProcesso:oProcError:getaError()

		cMsg    := aError[1][2]
		cMsgDet := aError[1][3]

		lSucesso := .F.
		nCode    := 500

		FwFreeArray(aError)
		oProcesso:oProcError:destroy()
	Else
		cMsg    := STR0138 // "Cálculo do tempo das operações iniciado com sucesso."
		cMsgDet := ""

		lSucesso := .T.
		nCode    := 200
	EndIf
	
	oRetorno["message"        ] := cMsg
	oRetorno["detailedMessage"] := cMsgDet
	
	aReturn[1] := lSucesso
	aReturn[2] := nCode
	aReturn[3] := oRetorno:toJson()
	
	oProcesso:destroy()

	FreeObj(oProcesso)
	FreeObj(oRetorno)
Return aReturn
