#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE TRANF_POS_FILIAL_DESTINO   1
#DEFINE TRANF_POS_FILIAL_ORIGEM    2
#DEFINE TRANF_POS_PRODUTO          3
#DEFINE TRANF_POS_DATA             4
#DEFINE TRANF_POS_QUANTIDADE       5
#DEFINE TRANF_POS_DOCUMENTO        6
#DEFINE TRANF_POS_DATA_RECEBIMENTO 7
#DEFINE TRANF_TAMANHO              7

#DEFINE QTD_LINHAS_INCLUI 500

Static sCRLF         := chr(13)+chr(10) //Quebra de linha
Static soDados       := Nil             //Instancia da camada de dominio
Static soDominio     := Nil             //Instancia da camada de dominio
Static snTamCod      := 90

Static sOPC_KEY      := 1
Static sOPC_KEY2     := 2
Static sOPC_OPCION   := 3
Static sOPC_ID       := 4
Static sOPC_IDPAI    := 5
Static sOPC_IDMASTER := 6
Static sOPC_TABRECNO := 7
Static sOPC_RECNO    := 8
Static sOPC_FILIAIS  := 9
Static sOPC_DEFAULT  := 10

Static snIFilial
Static snIPeriodo
Static snITipoPai
Static snIDocPai
Static snIDocFilh
Static snICompone
Static snIID_OPC
Static snITRT
Static snINecOrig
Static snIQtdEstq
Static snIConEstq
Static snISubstit
Static snISubsOri
Static snINecessi
Static snIChvSubs
Static snIIDRevis
Static snIRoteiro
Static snIOperacao
Static snIRotFilho
Static snILocal
Static snIQtrEnt
Static snIQtrSai
Static snIQuebras
Static snIVersao
Static snGravaAgl

Static snMatPFil
Static snMatPQTE
Static snMatPQTS

Static snXFilial
Static snXProd
Static snXDocAgl
Static snXDocs
Static snXTpDocOr
Static snXDocOri
Static snXProdOri
Static snXNeces
Static snXEmpen
Static snXSubst
Static snXQtrEnt
Static snXQtrSai
Static snXDocFil
Static snXTrt

Static _lRotFil  := Nil
Static _lTransfs := Nil
Static _lDocAgl  := Nil
Static _lLoteSME := Nil
Static _lOpcDflt := Nil
Static _lGravaTrt := Nil

/*/{Protheus.doc} MrpDominio_Saida
Regras de negocio MRP - Saida de Dados
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio_Saida FROM LongNameClass

	DATA oDominio AS OBJECT

	METHOD new(oDominio) CONSTRUCTOR

	METHOD aguardaAglutinacao(oDominio)
	METHOD aguardaEntradas(oDominio)
	METHOD aguardaRastreio(oDominio)
	METHOD aguardaSMV(oDominio)
	METHOD aguardaTermino(oDominio)

	METHOD exportarAglutinacaoRastreio(oDominio)
	METHOD exportarComplementoHWB(oDominio)
	METHOD exportarDocumentos(oDominio)
	METHOD exportarEntradas(oDominio, nTotProc)
	METHOD exportarEventos(oDominio, aArrEvt)
	METHOD exportarOpcionais(oDominio)
	METHOD exportarResultados(nResultados, oDominio)
	METHOD exportarRastreio(oDominio)
	METHOD exportarTransferencia(oDominio)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
METHOD new(oDominio) CLASS MrpDominio_Saida

	::oDominio := oDominio

Return Self

/*/{Protheus.doc} exportarOpcionais
Exporta resultados
@author brunno.costa
@since 25/04/2019
@version 1.0
@param oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD exportarOpcionais(oDominio) CLASS MrpDominio_Saida

	Local aLenFields     := {}
	Local aOpcionais     := {}
	Local aResultados    := {}
	Local nInd           := 0
	Local nOpcionais     := 0
	Local nCount         := 0
	Local nTam           := 0
	Local oDados         := oDominio:oDados
	Local oOpcionais     := oDados:oOpcionais
	Local oStatus        := oDominio:oLogs:oStatus
	Local oMultiEmp      := oDominio:oMultiEmp

	//Retorna todos os dados de opcionais da Matriz de Opcionais
	oOpcionais:getAllRow(aOpcionais, .F.)

	//Retorna caso não possua opcional
	If Empty(aOpcionais)
		Return
	EndIf

	oStatus:preparaAmbiente(oDominio:oDados)

	oDominio:oLogs:log("[HWD] Inicio de exportacao de resultados. " + Time(), "32")

	oOpcionais:setflag("cFilial", xFilial("HWD"))

	//Busca o tamanho dos campos CHAR para o PadR
	aAdd(aLenFields, FWSizeFilial())
	aAdd(aLenFields, GetSx3Cache("HWD_TICKET","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWD_IDMAST","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWD_IDPAI" ,"X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWD_ID"    ,"X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWD_ERPOPC","X3_TAMANHO"))

	nTam := GetSx3Cache("HWD_DEFAUL","X3_TAMANHO")
	If nTam > 0
		aAdd(aLenFields, nTam)
		_lOpcDflt := .T.
	EndIf

	DbSelectArea("T4J")
	DbSelectArea("T4Q")

	cCols := "HWD_FILIAL,HWD_TICKET,HWD_IDMAST,HWD_IDPAI,HWD_ID,HWD_KEY,HWD_KEYMAT,HWD_OPCION,HWD_ERPMOP,HWD_ERPOPC"

	If _lOpcDflt
		cCols += ",HWD_DEFAUL"
	EndIf

	//Carrega o array com os registros a serem inseridos
	nOpcionais := Len(aOpcionais)
	For nInd := 1 To nOpcionais
		LinOPCBD(aOpcionais[nInd], @aResultados, oOpcionais, oDominio:oParametros["ticket"], aLenFields, oMultiEmp)

		nCount++
		If nCount >= QTD_LINHAS_INCLUI
			nCount := 0
			gravaDados(RetSqlName("HWD"), cCols, aResultados)
		EndIf
	Next nInd

	If !Empty(aResultados)
		gravaDados(RetSqlName("HWD"), cCols, aResultados)
	EndIf

	aSize(aResultados, 0)
	aSize(aLenFields , 0)
	oDominio:oLogs:log("[HWD] Termino de exportacao de resultados. " + Time(), "32")

Return

/*/{Protheus.doc} LinOPCBD
Gera Linha de Exportação da Tabela de Opcionais - BD
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - aOpcional  , array   , linha do opcional
@param 02 - aResultados, array   , retorna por referência array dos opcionais
@param 03 - oOpcionais , objeto  , objeto Data_Global referente Opcionais
@param 04 - cTicket    , caracter, ticket referente execução do MRP
@param 05 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
/*/
Static Function LinOPCBD(aOpcional, aResultados, oOpcionais, cTicket, aLenFields, oMultiEmp)

	Local aLinAux   := {}
	Local cERPMOP   := ""
	Local cERPOPC   := ""
	Local cTabela   := aOpcional[2][sOPC_TABRECNO]
	Local nIndex    := 0
	Local nTotalFil := 0

	//Adiciona campos na ordem de cCols
	aAdd(aLinAux, PadR(oOpcionais:getflag("cFilial"), aLenFields[1])) //HWD_FILIAL
	aAdd(aLinAux, PadR(cTicket                      , aLenFields[2])) //HWD_TICKET
	aAdd(aLinAux, PadR(aOpcional[2][sOPC_IDMASTER]  , aLenFields[3])) //HWD_IDMAST
	aAdd(aLinAux, PadR(aOpcional[2][sOPC_IDPAI]     , aLenFields[4])) //HWD_IDPAI
	aAdd(aLinAux, PadR(aOpcional[2][sOPC_ID]        , aLenFields[5])) //HWD_ID
	aAdd(aLinAux, aOpcional[1]                                      ) //HWD_KEY
	aAdd(aLinAux, aOpcional[2][sOPC_KEY2]                           ) //HWD_KEYMAT
	aAdd(aLinAux, StrTran(aOpcional[2][sOPC_OPCION] , ";", ","))      //HWD_OPCION

	If !Empty(cTabela) .And. !Empty(aOpcional[2][sOPC_RECNO])
		//Posiciona no RECNO que possui os dados dos opcionais
		(cTabela)->(dbGoTo(aOpcional[2][sOPC_RECNO]))
		//Recupera o valor do opcional da tabela.
		//A macro execução a seguir irá montar o comando "T4Q->T4Q_ERPMOP", mudando a tabela conforme cTabela.
		cERPMOP := &(cTabela + '->' + cTabela + '_ERPMOP')
		cERPOPC := &(cTabela + '->' + cTabela + '_ERPOPC')
	EndIf

	aAdd(aLinAux, cERPMOP)                      //HWD_ERPMOP
	aAdd(aLinAux, PadR(cERPOPC, aLenFields[6])) //HWD_ERPOPC

	If _lOpcDflt
		If aOpcional[2][sOPC_DEFAULT]
			aAdd(aLinAux, PadR("S", aLenFields[7])) // HWD_DEFAUL
		Else
			aAdd(aLinAux, PadR("N", aLenFields[7])) // HWD_DEFAUL
		EndIf
	EndIf

	If oMultiEmp:utilizaMultiEmpresa()
		nTotalFil := Len(aOpcional[2][sOPC_FILIAIS])

		For nIndex := 1 To nTotalFil
			aLinAux[1] := PadR(aOpcional[2][sOPC_FILIAIS][nIndex], oMultiEmp:tamanhoFilial())

			aAdd(aResultados, aClone(aLinAux))
		Next nIndex

	Else
		aAdd(aResultados, aLinAux)
	EndIf
Return

/*/{Protheus.doc} exportarResultados
Exporta resultados
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - nResultados, numero, retorna por referencia a quantidade de resultados - Single Thread
@param 02 - oDominio   , objeto, objeto da camada de dominio
@return Nil
/*/
METHOD exportarResultados(nResultados, oDominio) CLASS MrpDominio_Saida
	Local cErrorUID := Nil
	Local oPCPError := Nil

	nResultados := oDominio:oDados:tamanhoLista("MAT")

	If nResultados > 0
		If oDominio:oParametros["nThreads_MAT"] <= 1
			MrpExpResM(nResultados, oDominio, oDominio:oParametros["ticket"])
		Else
			cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(), "PCPA712_MRP_" + oDominio:oParametros["ticket"])
			oPCPError := PCPMultiThreadError():New(cErrorUID)
			oPCPError:startJob("MrpExpResM", GetEnvServer(), .F., Nil, Nil, nResultados, Nil, oDominio:oParametros["ticket"])
		EndIf
	Else
		oDominio:oDados:oMatriz:setflag("nUsdThread" , 0, .F., .F.)
		oDominio:oDados:oMatriz:setflag("nResultados", 0, .F., .F.)
	EndIf

Return

/*/{Protheus.doc} MrpExpResM
Exporta Resultados Matriz - Master
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - nResultados, numero  , quantidade de resultados
@param 02 - oDominio   , objeto  , objeto da camada de dominio - Single Thread
@param 03 - cTicket    , caracter, Número do ticket de processamento do MRP
@return Nil
/*/
Function MrpExpResM(nResultados, oDominio, cTicket)

	Local aLenFields  := {}
	Local nIndAux     := 0
	Local nInicio     := 0
	Local nFim        := 0
	Local nMedia      := 0
	Local nThreads    := 0
	Local nUsdThread  := 0
	Local oDados
	Local oMatriz
	Local oStatus

	If oDominio == Nil
		PrepStatics(cTicket)
		oDominio := soDominio
	EndIf

	oDados   := oDominio:oDados
	oLogs    := oDominio:oLogs
	oMatriz  := oDados:oMatriz
	oStatus  := oDominio:oLogs:oStatus

	oStatus:preparaAmbiente(oDominio:oDados)

	oLogs:log("[HWB] Inicio de exportacao de resultados. Total: " + cValToChar(nResultados) + " " + Time(), "32")

	oMatriz:setflag("cFilial", xFilial("HWB"))

	//Busca o tamanho dos campos CHAR para o PadR
	aAdd(aLenFields, FWSizeFilial())
	aAdd(aLenFields, GetSx3Cache("HWB_TICKET","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWB_PRODUT","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWB_IDOPC" ,"X3_TAMANHO"))

	nThreads := oDominio:oParametros["nThreads_MAT"]

	If nThreads <= 1
		MrpExpResS(0, 1, nResultados, aLenFields, oDominio:oParametros["ticket"])
	Else
	    //Processamento por Thread
		nMedia := Round(nResultados / nThreads, 0)
		If nMedia < 3000
			nMedia := 3000
		EndIf

		For nIndAux := 1 to nThreads
			nInicio := nMedia * (nIndAux - 1) + 1
			If (nMedia * nIndAux) < nResultados
				nFim := nMedia*nIndAux
			ElseIf nInicio <= nResultados
				nFim := nResultados
			Else
				nFim := 0
			EndIf
			If nFim > 0 .And. nIndAux == nThreads .And. nFim < nResultados
				nFim := nResultados
			EndIf
			If nFim > 0
				nUsdThread++
				oMatriz:setflag("lResultT" + PadL(nIndAux, 2, "0"), .F., .F., .F.)

				//Delega carga para Thread
				PCPIPCGO(oDominio:oParametros["cSemaforoThreads"] + "MAT", .F., "MrpExpResS", nIndAux, nInicio, nFim, aLenFields, oDominio:oParametros["ticket"])
			EndIf
		Next nIndAux
	EndIf

	oMatriz:setflag("nUsdThread" , nUsdThread, .F., .F.)
	oMatriz:setflag("nResultados", nResultados, .F., .F.)

	oLogs:log("[HWB] Termino da exportacao de resultados. " + Time(), "32")

	aSize(aLenFields, 0)

Return

/*/{Protheus.doc} MrpExpResS
Exporta Resultados Matriz - Slave
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - nThreadsSeq, numerico, identificador sequencial de Thread delegada
@param 02 - nPrimeiro  , numerico, primeiro resultado a ser exportado por esta Thread
@param 03 - nUltimo    , numerico, ultimo resultado a ser exportado por esta Thread
@param 04 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 05 - cTicket    , caracter, Número do ticket de processamento do MRP
@return Nil
/*/
Function MrpExpResS(nThreadsSeq, nPrimeiro, nUltimo, aLenFields, cTicket)

	Local aCpsMat     := {}
	Local aResultados := {}
	Local aRetAux     := {}
	Local cCols       := "HWB_FILIAL,HWB_TICKET,HWB_DATA,HWB_PRODUT,HWB_IDOPC,HWB_QTSLES,HWB_QTENTR,HWB_QTSAID,HWB_QTSEST,HWB_QTSALD,HWB_QTNECE,HWB_DTINIC"
	Local cFilAux     := ""
	Local cName       := ""
	Local lAgluPrd    := .F.
	Local lErrorMAT   := .F.
	Local lNivelHWB   := .F.
	Local lUsaME      := .F.
	Local nIndAux     := 0
	Local nTentativas := 0
	Local oCachePrd   := Nil
	Local oDados      := Nil
	Local oLogs       := Nil
	Local oMatriz     := Nil
	Local oStatus     := Nil

	PrepStatics(cTicket)

	oDados    := soDominio:oDados
	oLogs     := soDominio:oLogs
	oMatriz   := oDados:oMatriz
	oStatus   := soDominio:oLogs:oStatus
	lUsaME    := soDominio:oMultiEmp:utilizaMultiEmpresa()

	dbSelectArea("HWB")
	If FieldPos("HWB_NIVEL") > 0
		lNivelHWB := .T.
		cCols += ",HWB_NIVEL"
		oCachePrd := JsonObject():New()
	EndIf

	If lUsaME
		cCols += ",HWB_QTRENT"
		cCols += ",HWB_QTRSAI"
	EndIf

	If FieldPos("HWB_AGLPRD") > 0
		cCols += ",HWB_AGLPRD"
		lAgluPrd := .T.
	EndIf

	aCpsMat := {"MAT_DATA"  , "MAT_PRODUT","MAT_SLDINI", "MAT_ENTPRE",;
	            "MAT_SAIPRE", "MAT_SAIEST","MAT_SALDO" , "MAT_NECESS",;
	            "MAT_IDOPC" , "MAT_DTINI"}

	If lUsaME
		aAdd(aCpsMat, "MAT_FILIAL")
		snMatPFil := Len(aCpsMat)   //Static para guardar o valor da posição do campo MAT_FILIAL dentro do array

		aAdd(aCpsMat, "MAT_QTRENT")
		snMatPQTE := snMatPFil + 1  //Static para guardar o valor da posição do campo MAT_QTRENT dentro do array

		aAdd(aCpsMat, "MAT_QTRSAI")
		snMatPQTS := snMatPQTE + 1   //Static para guardar o valor da posição do campo MAT_QTRSAI dentro do array
	EndIf

	cName := "cResultT" + PadL(nThreadsSeq, 2, "0")
	oMatriz:setResult(cName, "", .F., .F.)

	For nIndAux := nPrimeiro To nUltimo

		If (nIndAux == 1 .Or. Mod(nIndAux, oDados:oParametros["nX_Para_Cancel"]) == 0) .And. oStatus:getStatus("status") == "4"
			Exit
		EndIF

		oMatriz:position(nIndAux, @lErrorMAT)
		If lErrorMAT
			Exit
		EndIf

		aRetAux := oDados:retornaCampo("MAT", 1, , aCpsMat, @lErrorMAT  , .T. /*lAtual*/, , , , .T. /*lSort*/, .T. /*lVarios*/)

		If !lErrorMAT .And. lUsaME
			cFilAux := aRetAux[snMatPFil]
		Else
			cFilAux := ""
		EndIf

		If (Empty(aRetAux[2]);
		   .Or. (aRetAux[4] == 0 .And. aRetAux[5] == 0 .And. aRetAux[6] == 0 .And. aRetAux[8] == 0)) ;
		   .And. !soDominio:descontouLoteVencido(cFilAux, aRetAux[2], aRetAux[9], aRetAux[1])
			If lUsaME
				If aRetAux[snMatPQTE] == 0 .And. aRetAux[snMatPQTS] == 0
					Loop
				EndIf
			Else
				Loop
			EndIf
		EndIf

		LinMatBD(aRetAux, @aResultados, oLogs, oMatriz, soDominio:oParametros["ticket"], aLenFields, @oCachePrd, oDados, lAgluPrd)

		//Transferencias parciais de string para variavel global / Banco
		If nThreadsSeq > 0 .And. Mod(nIndAux, 500) == 0
			If !(AllTrim(soDominio:oParametros["cAutomacao"]) $ "|1|2|")
				//Grava resultados no banco de dados
				oStatus:preparaAmbiente(oDados)

				While nTentativas < 10
					If TCDBInsert(RetSqlName("HWB"), cCols, aResultados) < 0
						LogMsg('MRPDOMINIO_SAIDA', 14, 4, 1, '', '', tcSQLError())
						Sleep(500)
						nTentativas++
					Else
						Exit
					EndIf
				EndDo

				If nTentativas == 10
					varInfo("HWB aResultados - ", aResultados)
					UserException(tcSQLError())
					nTentativas := 0
				EndIf
			EndIf
			aSize(aResultados, 0)
		EndIf
	Next nIndAux

	If !Empty(aResultados)
		If AllTrim(soDominio:oParametros["cAutomacao"]) != "1"
			//Grava resultados no banco de dados
			oStatus:preparaAmbiente(oDados)

			While nTentativas < 10

				//Corrige ordenação para comparação em automação
				If AllTrim(soDominio:oParametros["cAutomacao"]) == "2"
					aResultados := aSort(aResultados, , , { | x,y | x[1] + x[2] + DtoS(x[3]) + x[4] + x[5];
					                                               <;
																    y[1] + y[2] + DtoS(y[3]) + y[4] + y[5];
					                                  } )
				EndIf
				If TCDBInsert(RetSqlName("HWB"), cCols, aResultados) < 0
					LogMsg('MRPDOMINIO_SAIDA', 14, 4, 1, '', '', tcSQLError())
					Sleep(500)
					nTentativas++
				Else
					Exit
				EndIf
			EndDo
			If nTentativas == 10
				varInfo("HWB aResultados - ", aResultados)
				UserException(tcSQLError())
			EndIf
		EndIf
		aSize(aResultados, 0)

	EndIf

	oMatriz:setflag("lResultT" + PadL(nThreadsSeq, 2, "0"), .T., .F., .F.)

	FreeObj(oCachePrd)

Return

/*/{Protheus.doc} LinMatBD
Gera Linha de Exportação da Tabela da Matriz - BD
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - aRetAux    , array   , linha do opcional
@param 02 - aResultados, array   , retorna por referência array dos resultados da Matriz
@param 03 - oLogs      , objeto  , objeto para registros de logs do mrp
@param 04 - oMatriz    , objeto  , objeto Data_Global referente Matriz de Resultados
@param 05 - cTicket    , caracter, ticket referente execução do MRP
@param 06 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 07 - oCachePrd  , objeto  , JsonObject utilizado como cache das informações de nível do produto
@param 08 - oDados     , objeto  , Instância de dados do MRP
@param 09 - lAgluPrd   , logico  , Indica se existe a coluna de aglutinação do produto na HWB
/*/
Static Function LinMatBD(aRetAux, aResultados, oLogs, oMatriz, cTicket, aLenFields, oCachePrd, oDados, lAgluPrd)

	Local aLinAux    := {}
	Local cChave     := ""
	Local cChaveProd := ""
	Local nFlag      := ""

	//Adiciona campos na ordem de cCols
	If soDominio:oMultiEmp:utilizaMultiEmpresa()
		aAdd(aLinAux, PadR(aRetAux[snMatPFil], soDominio:oMultiEmp:tamanhoFilial())) //HWB_FILIAL
		cChaveProd := aRetAux[snMatPFil] + aRetAux[2]
	Else
		aAdd(aLinAux, PadR(oMatriz:getflag("cFilial"), aLenFields[1])) //HWB_FILIAL
		cChaveProd := aRetAux[2]
	EndIf
	aAdd(aLinAux, PadR(cTicket                   , aLenFields[2])) //HWB_TICKET
	aAdd(aLinAux, aRetAux[1])                                      //HWB_DATA
	aAdd(aLinAux, PadR(aRetAux[2]                , aLenFields[3])) //HWB_PRODUT
	aAdd(aLinAux, PadR(aRetAux[9]                , aLenFields[4])) //HWB_IDOPC
	aAdd(aLinAux, aRetAux[3])                                      //HWB_QTSLES
	aAdd(aLinAux, aRetAux[4])                                      //HWB_QTENTR
	aAdd(aLinAux, aRetAux[5])                                      //HWB_QTSAID
	aAdd(aLinAux, aRetAux[6])                                      //HWB_QTSEST
	aAdd(aLinAux, aRetAux[7])                                      //HWB_QTSALD
	aAdd(aLinAux, aRetAux[8])                                      //HWB_QTNECE
	aAdd(aLinAux, aRetAux[10])                                     //HWB_DTINIC

	If oCachePrd != Nil
		aAdd(aLinAux, getNivel(cChaveProd, @oCachePrd, oDados, aRetAux[1], aRetAux[9]))
	EndIf

	If soDominio:oMultiEmp:utilizaMultiEmpresa()
		aAdd(aLinAux, aRetAux[snMatPQTE])                          //HWB_QTRENT
		aAdd(aLinAux, aRetAux[snMatPQTS])                          //HWB_QTRSAI
	EndIf

	If lAgluPrd //Valor para o campo HWB_AGLPRD
		cChave := "|AGLUPRD|" + DtoS(aRetAux[1]) + cChaveProd + Iif(!Empty(aRetAux[9]), "|" + aRetAux[9], "")
		nFlag  := soDominio:oDados:oMatriz:getFlag(cChave)
		If !Empty(nFlag)
			aAdd(aLinAux, cValToChar(nFlag))
		Else
			aAdd(aLinAux, "0")
		EndIf
	EndIf

	aAdd(aResultados, aLinAux)

Return

/*/{Protheus.doc} exportarRastreio
Exporta Rastreio
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - oDominio, objeto, objeto da camada de dominio
/*/
METHOD exportarRastreio(oDominio) CLASS MrpDominio_Saida
	Local cErrorUID := Nil
	Local oPCPError := Nil

	If oDominio:oParametros["nThreads"] <= 1
		MrpExpRasM(oDominio, oDominio:oParametros["ticket"])
	Else
		cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(), "PCPA712_MRP_" + oDominio:oParametros["ticket"])
		oPCPError := PCPMultiThreadError():New(cErrorUID)
		oPCPError:startJob("MrpExpRasM", GetEnvServer(), .F., Nil, Nil, Nil, oDominio:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpExpRasM
Exporta rastreabilidade - Master
@author    brunno.costa
@since     23/10/2019
@version 1.0
@param 01 - oDominio, objeto  , objeto da classe MrpDominio passado somente sem threads adicionais - Single thread
@param 02 - cTicket , caracter, Número do ticket de processamento do MRP
/*/
Function MrpExpRasM(oDominio, cTicket)

	Local aLotes      := {}
	Local aLenFields  := {}
	Local aPeriodos   := {}
	Local aPerProds   := {}
	Local aSessoes    := {}
	Local cChaveExec  := ""
	Local cList       := ""
	Local cChaveProd  := ""
	Local lError      := .F.
	Local lExistLt    := .F.
	Local lExistRas   := .F.
	Local nDelegacoes := 0
	Local nIPer       := 0
	Local nInd        := 0
	Local nProdutos   := 0
	Local nThreads    := 0
	Local oRastreio
	Local oStatus

	If oDominio == Nil
		PrepStatics(cTicket)
		oDominio := soDominio
	EndIf

	oStatus    := oDominio:oLogs:oStatus
	oRastreio  := oDominio:oRastreio
	nThreads   := oDominio:oParametros["nThreads"]
	cChaveExec := oDominio:oParametros["cChaveExec"]

	oDominio:oLogs:log("[HWC] Inicio de exportacao de resultados. " + Time(), "32")

	VarIsUID( cChaveExec + "UIDs_PCPMRP")
	VarGetXA( cChaveExec + "UIDs_PCPMRP", @aSessoes)
	nTotal := Len(aSessoes)

	For nInd := 1 to nTotal
		If "Periodos_Produto_" $ aSessoes[nInd][1]
			aAdd(aPerProds, Substr(aSessoes[nInd][1], 17 + At("Periodos_Produto_", aSessoes[nInd][1])))
		EndIf
	Next

	aSize(aSessoes, 0)
	aSessoes := Nil

	If oDominio:oEventos:lHabilitado
		oDominio:oEventos:analisaDocumentos(aPerProds)
	EndIf

	//Retorna todos os dados de rastreio
	nProdutos := Len(aPerProds)
	If nProdutos > 0
		oStatus:preparaAmbiente(oDominio:oDados)

		oRastreio:oDados_Rastreio:oDados:setflag("cFilial", xFilial("HWC"))

		//Busca o tamanho dos campos CHAR para o PadR
		aAdd(aLenFields, FWSizeFilial())
		aAdd(aLenFields, GetSx3Cache("HWC_TICKET","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_TPDCPA","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_DOCPAI","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_DOCFIL","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_PRODUT","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_IDOPC" ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_TRT"   ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_CHVSUB","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_CHAVE" ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_REV"   ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_ROTEIR","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_OPERAC","X3_TAMANHO"))

		dbSelectArea("HWC")
		If FieldPos("HWC_ROTFIL") > 0
			aAdd(aLenFields, GetSx3Cache("HWC_ROTFIL","X3_TAMANHO"))
		Else
			aAdd(aLenFields, 0)
		EndIf

		aAdd(aLenFields, GetSx3Cache("HWC_LOCAL" ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_DOCERP","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_TDCERP","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_STATUS","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWC_VERSAO","X3_TAMANHO"))

		dbSelectArea("HWC")
		If FieldPos("HWC_AGLUT") > 0
			aAdd(aLenFields, GetSx3Cache("HWC_AGLUT","X3_TAMANHO"))
		Else
			aAdd(aLenFields, 0)
		EndIf

		If AllTrim(oDominio:oParametros["cAutomacao"]) == "2"
			aPerProds := aSort(aPerProds)
		EndIf

		//Percorre os dados do rastreio
		For nInd := 1 To nProdutos
			lError := .F.

			cChaveProd := aPerProds[nInd]
			oDominio:oDados:oMatriz:getAllList("Periodos_Produto_"+cChaveProd, @aPeriodos, @lError)

			If !lError
				nPeriodos := Len(aPeriodos)
				For nIPer := 1 To nPeriodos

					cList     := cChaveProd + chr(13) + aPeriodos[nIPer][1]
					aLotes    := oRastreio:oDados_Rastreio:oDados:getItemAList("LOTES_VENCIDOS", cList, @lError, .F.)
					lExistLt  := !lError .And. Len(aLotes) > 0
					lExistRas := oRastreio:oDados_Rastreio:oDados:existAList(cList)
					If lExistRas .Or. lExistLt
						//Executa função de exportação os resultados com todos os registros
						If nThreads <= 1
							MrpExpRasS(0, cList, aLenFields, cTicket, lExistRas, aLotes)

						//Delega carga para Thread
						Else
							nDelegacoes++
							PCPIPCGO(oDominio:oParametros["cSemaforoThreads"], .F., "MrpExpRasS", nDelegacoes, cList, aLenFields, cTicket, lExistRas, aLotes)
						EndIf
					EndIf
					If lExistLt
						FwFreeArray(aLotes)
					EndIf
				Next nIPer
			EndIf
			aSize(aPeriodos, 0)
		Next nInd

		oRastreio:oDados_Rastreio:oDados:setflag("nDelegacoes_Rastreio", nDelegacoes, .F., .F.)

		//Limpa Array Local aPerProds
		aSize(aPerProds, 0)
		aPerProds := Nil

		aSize(aLenFields, 0)
	Else
		oRastreio:oDados_Rastreio:oDados:setflag("nDelegacoes_Rastreio", 0, .F., .F.)
	EndIf
	oDominio:oLogs:log("[HWC] Termino de exportacao de resultados. " + Time(), "32")

Return

/*/{Protheus.doc} MrpExpRasS
Exporta rastreabilidade - Slave
@author    brunno.costa
@since     23/10/2019
@version 1.0
@param 01 - nThreadsSeq, numerico, identificador sequencial de Thread delegada
@param 02 - cList      , caracter, identificador da sessão de variáveis globais - Produto + chr(13) + Período
@param 03 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 04 - cTicket    , caracter, número do ticket de processamento do MRP
@param 05 - lExistRas  , logico  , indica que existem dados de rastreabilidade para exportar. Pode ser .F. quando somente existirem dados de lotes vencidos.
@param 06 - aLotes     , array   , array com as informações de lotes vencidos
/*/
Function MrpExpRasS(nThreadsSeq, cList, aLenFields, cTicket, lExistRas, aLotes)

	Local aDocumentos := {}
	Local aLinha      := {}
	Local aResultados := {}
	Local cCols       := "HWC_FILIAL,HWC_TICKET,HWC_DATA,HWC_TPDCPA,HWC_DOCPAI,HWC_DOCFIL,HWC_PRODUT,HWC_IDOPC,HWC_TRT,HWC_QTNEOR,HWC_QTSLES,HWC_QTBXES,HWC_QTSUBS,HWC_QTSBVL,HWC_QTEMPE,HWC_QTNECE,HWC_CHVSUB,HWC_CHAVE,HWC_REV,HWC_ROTEIR,HWC_OPERAC,HWC_SEQUEN,HWC_LOCAL,HWC_VERSAO"
	Local nUltimo     := 0
	Local nIndAux     := 0
	Local nIDoc       := 0
	Local nTotLote    := 0
	Local nPosRecno   := 25
	Local oCachePrd   := JsonObject():New()
	Local oDados      := Nil
	Local oLogs       := Nil
	Local oMOD        := MrpDominio_MOD():New()
	Local oRastreio   := Nil
	Local oStatus     := Nil

	PrepStatics(cTicket)

	oDados    := soDominio:oDados
	oLogs     := soDominio:oLogs
	oRastreio := soDominio:oRastreio
	oStatus   := soDominio:oLogs:oStatus

	oStatus:preparaAmbiente(oDados)

	If !Empty(aLotes)
		nTotLote := Len(aLotes[2])
	EndIf

	If _lRotFil == Nil
		dbSelectArea("HWC")
		_lRotFil  := FieldPos("HWC_ROTFIL") > 0
		_lTransfs := FieldPos("HWC_QTRENT") > 0
		_lDocAgl  := FieldPos("HWC_AGLUT") > 0
	EndIf

	If _lRotFil
		cCols += ",HWC_ROTFIL"
		nPosRecno := nPosRecno + 1
	EndIf

	If _lTransfs
		cCols += ",HWC_QTRENT,HWC_QTRSAI"
		nPosRecno := nPosRecno + 2
	EndIf

	If _lDocAgl
		cCols += ",HWC_AGLUT"
		nPosRecno := nPosRecno + 1
	EndIf

	oRastreio:oDados_Rastreio:oDados:setflag("lResultT" + cValToChar(nThreadsSeq), .F., .F., .F.)

	If snIPeriodo == Nil
		snIFilial   := oRastreio:getPosicao("FILIAL")
		snIPeriodo  := oRastreio:getPosicao("PERIODO")
		snITipoPai  := oRastreio:getPosicao("TIPOPAI")
		snIDocPai   := oRastreio:getPosicao("DOCPAI")
		snIDocFilh  := oRastreio:getPosicao("DOCFILHO")
		snICompone  := oRastreio:getPosicao("COMPONENTE")
		snIID_OPC   := oRastreio:getPosicao("ID_OPCIONAL")
		snITRT      := oRastreio:getPosicao("TRT")
		snINecOrig  := oRastreio:getPosicao("NEC_ORIGINAL")
		snIQtdEstq  := oRastreio:getPosicao("QTD_ESTOQUE")
		snIConEstq  := oRastreio:getPosicao("CONSUMO_ESTOQUE")
		snISubstit  := oRastreio:getPosicao("SUBSTITUICAO")
		snISubsOri  := oRastreio:getPosicao("QTD_SUBST_ORIGINAL")
		snINecessi  := oRastreio:getPosicao("NECESSIDADE")
		snIChvSubs  := oRastreio:getPosicao("CHAVE_SUBSTITUICAO")
		snIIDRevis  := oRastreio:getPosicao("REVISAO")
		snIRoteiro  := oRastreio:getPosicao("ROTEIRO")
		snIOperacao := oRastreio:getPosicao("OPERACAO")
		snIRotFilho := oRastreio:getPosicao("ROTEIRO_DOCUMENTO_FILHO")
		snILocal    := oRastreio:getPosicao("LOCAL")
		snIQuebras  := oRastreio:getPosicao("QUEBRAS_QUANTIDADE")
		snIVersao   := oRastreio:getPosicao("VERSAO_PRODUCAO")
		snIQtrEnt   := oRastreio:getPosicao("TRANSFERENCIA_ENTRADA")
		snIQtrSai   := oRastreio:getPosicao("TRANSFERENCIA_SAIDA")
		snGravaAgl  := oRastreio:getPosicao("DOCUMENTO_AGLUTINADOR")
	EndIf

	If lExistRas
		oRastreio:oDados_Rastreio:oDados:getAllAList(cList, @aDocumentos)
		aDocumentos := oRastreio:ordenaRastreio(aDocumentos, .F.)
	EndIf
	aDocumentos := oRastreio:adicionaLoteVencido(aDocumentos, aLotes)
	nDocumentos := Len(aDocumentos)

	For nIDoc := 1 To nDocumentos
		aLinha := aDocumentos[nIDoc][2]

		If !soDominio:oSeletivos:consideraProduto(aLinha[snIFilial], aLinha[snICompone]);
		   .OR. oMOD:produtoMOD(aLinha[snIFilial], aLinha[snICompone], soDominio:oDados)
			aLinha[snINecessi] := 0
		EndIf

		//Não imprime registros zerados
		If (aLinha[snINecOrig] == 0;
			.AND. aLinha[snIConEstq] == 0;
			.AND. aLinha[snINecessi] == 0;
			.AND. aLinha[snISubstit] == 0;
			.AND. !(("|"+AllTrim(aLinha[snITipoPai]+"|")) $ "|Pré-OP|");
		  .OR.;
			("|"+AllTrim(aLinha[snITipoPai]+"|") $ "|Pré-OP|";
			.AND. aLinha[snIQtdEstq] == 0;
			.AND. aLinha[snINecessi] == 0))
			If soDominio:oMultiEmp:utilizaMultiEmpresa()
				If aLinha[snIQtrEnt] == 0 .And. aLinha[snIQtrSai] == 0
					Loop
				EndIf
			Else
				Loop
			EndIf
		EndIf

		//Prepara linha de resultados para exportação em banco de dados
		LinRastBD(aLinha, @aResultados, oLogs, oRastreio, soDominio:oParametros["ticket"], aLenFields, @oCachePrd, cList, nIDoc-nTotLote)
		aSize(aLinha, 0)

		//Transferencias parciais de string para variavel global / Banco
		If Len(aResultados) >= QTD_LINHAS_INCLUI
			If oStatus:getStatus("status") == "4"
				Exit
			EndIF
			If !(AllTrim(soDominio:oParametros["cAutomacao"]) $ "|1|2|")
				//Grava resultados no banco de dados
				gravaDados(RetSqlName("HWC"), cCols, aResultados)
			EndIf
			aSize(aResultados, 0)
		EndIf
	Next
	aSize(aDocumentos, 0)

	If !Empty(aResultados) .AND. oStatus:getStatus("status") != "4"//Não Cancelado
		If AllTrim(soDominio:oParametros["cAutomacao"]) != "1"
			//Corrige ordenação para comparação em automação
			If AllTrim(soDominio:oParametros["cAutomacao"]) == "2"
				aResultados := aSort(aResultados, , , { | x,y | Iif(x[4] == STR0144, "1", "0") + x[19] + x[7] + DtoS(x[3]) + x[4] + x[5] + StrZero(x[nPosRecno], 5);
																<;
																Iif(y[4] == STR0144, "1", "0") + y[19] + y[7] + DtoS(y[3]) + y[4] + y[5] + StrZero(y[nPosRecno], 5);
													} )
				//Corrige ordenação de RECNO
				nUltimo := Len(aResultados)
				For nIndAux := 1 To nUltimo
					aSize(aResultados[nIndAux], Len(aResultados[nIndAux])-1)
				Next
			EndIf

			//Grava resultados no banco de dados
			gravaDados(RetSqlName("HWC"), cCols, aResultados)

		EndIf
		aSize(aResultados, 0)
	EndIf

	If soDominio:oDados:oParametros["lRastreiaEntradas"]
		soDominio:oRastreioEntradas:efetivaDocHWC()
	EndIf

	oRastreio:oDados_Rastreio:oDados:setflag("lResultT" + cValToChar(nThreadsSeq), .T., .F., .F.)

	FreeObj(oCachePrd)
	FwFreeArray(aLotes)
Return

/*/{Protheus.doc} LinRastBD
Adiciona linha do registro no controle de inserção no banco
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - aLinha     , array   , linha do rastreio
@param 02 - aResultados, array   , retorna por referência array dos resultados de rastreabilidade
@param 03 - oLogs      , objeto  , objeto Data_Global referente aos logs
@param 04 - oRastreio  , objeto  , objeto Data_Global referente rastreabilidade
@param 05 - cTicket    , caracter, ticket referente execução do MRP
@param 06 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 07 - oCachePrd  , Object  , JsonObject utilizado como cache das informações do local do produto
@param 08 - cList      , caracter, Identificador dos dados da HWC em memória
@param 09 - nPosDoc    , numero  , Índice do array de dados (ordenados) subtraído das posições de lote vencido.
/*/
Static Function LinRastBD(aLinha, aResultados, oLogs, oRastreio, cTicket, aLenFields, oCachePrd, cList, nPosDoc)

	Local aLinAux    := {}
	Local cFilAux    := ""
	Local lAutomacao := AllTrim(soDominio:oParametros["cAutomacao"]) == "2"
	Local nRecno     := 0
	Local nIndQuebra := 0
	Local nTotEmp    := 0
	Local nTotNecOri := 0
	Local nTotSubst  := 0
	Local nTotSubOr  := 0
	Local nTotQuebra := 0
	Local nEmpGrv    := 0
	Local nNecOriGrv := 0
	Local nSubsGrv   := 0
	Local nSubOriGrv := 0
	Local nQtdEstGrv := 0
	Local nConEstGrv := 0
	Local nQtdBaixa  := 0
	Local nQtdNeg    := 0
	Local nSequen    := 1
	Local oDados     := soDominio:oRastreio:oDados_Rastreio:oDados

	//Proteção para caso não tenha sido gerado o array de controle das quebras
	//de produção/compra. Irá gerar uma quebra com a qtd. total
	If aLinha[snIQuebras] == Nil .Or. Len(aLinha[snIQuebras]) < 1
		aLinha[snIQuebras] := {}
		aAdd(aLinha[snIQuebras], {aLinha[snINecessi], aLinha[snIDocFilh]})
	EndIf

	//TODO - Proteção contra BUG identificado após merge da issue DMANNEWPCP-2760 apresentando aLinha[snISubstit] positivo quando deveria ser negativo - Apenas base codificação - Não identificado ponto onde o valor perde o sinal
	If aLinha[snISubsOri] != Nil .And. aLinha[snISubstit] != Nil .And. aLinha[snISubsOri] < 0 .And. aLinha[snISubstit] > 0
		aLinha[snISubstit] := -aLinha[snISubstit]
	EndIf

	//Armazena o total de empenhos, necessidades e substituições deste rastreio
	//Utiliza os totalizadores para controlar as quebras que serão feitas para exportação
	//das quebras de produção/compras.
	nTotNecOri := aLinha[snINecOrig]
	nTotSubst  := Iif(aLinha[snISubstit] == Nil, 0        , aLinha[snISubstit])
	nTotSubOr  := Iif(aLinha[snISubsOri] == Nil, nTotSubst, aLinha[snISubsOri])
	nTotEmp    := nTotNecOri - nTotSubst

	//Para cada elemento do array de quebras, irá gerar um registro de rastreabilidade.
	//O primeiro elemento do array de quebras sempre é referente ao registro principal da rastreabilidade.
	//Os demais elementos sempre são elementos de produção ou compra. Por isso nunca possuem estoque ou consumo.
	nTotQuebra := Len(aLinha[snIQuebras])
	For nIndQuebra := 1 To nTotQuebra

		//Limpa variáveis auxiliares
		nEmpGrv    := 0
		nNecOriGrv := 0
		nSubsGrv   := 0
		nSubOriGrv := 0
		nQtdEstGrv := 0
		nConEstGrv := 0

		//Adiciona campos na ordem de cCols
		If soDominio:oMultiEmp:utilizaMultiEmpresa()
			cFilAux := aLinha[snIFilial]
			aAdd(aLinAux, PadR(aLinha[snIFilial], soDominio:oMultiEmp:tamanhoFilial()))          //HWC_FILIAL
		Else
			cFilAux := ""
			aAdd(aLinAux, PadR(oDados:getflag("cFilial")                       , aLenFields[1])) //HWC_FILIAL
		EndIf

		aAdd(aLinAux, PadR(cTicket                                             , aLenFields[2])) //HWC_TICKET
		aAdd(aLinAux, soDominio:oPeriodos:retornaDataPeriodo(cFilAux, aLinha[snIPeriodo]))       //HWC_DATA
		aAdd(aLinAux, PadR(aLinha[snITipoPai]                                  , aLenFields[3])) //HWC_TPDCPA
		aAdd(aLinAux, PadR(aLinha[snIDocPai]                                   , aLenFields[4])) //HWC_DOCPAI

		If Empty(aLinha[snIQuebras][nIndQuebra][2]) .And. nTotQuebra == 1 .And. aLinha[snIQuebras][nIndQuebra][1] > 0
			aAdd(aLinAux, PadR(aLinha[snIDocFilh]                              , aLenFields[5])) //HWC_DOCFIL
		ElseIf Empty(aLinha[snIQuebras][nIndQuebra][2])
			aAdd(aLinAux, PadR(aLinha[snIDocFilh]                              , aLenFields[5])) //HWC_DOCFIL
		Else
			aAdd(aLinAux, PadR(aLinha[snIQuebras][nIndQuebra][2]               , aLenFields[5])) //HWC_DOCFIL
		EndIf

		aAdd(aLinAux, PadR(aLinha[snICompone]                                  , aLenFields[6])) //HWC_PRODUT
		aAdd(aLinAux, PadR(Iif(Empty(aLinha[snIID_OPC]), "",aLinha[snIID_OPC]) , aLenFields[7])) //HWC_IDOPC
		aAdd(aLinAux, PadR(aLinha[snITRT]                                      , aLenFields[8])) //HWC_TRT

		If nIndQuebra == 1
			If nTotQuebra == 1
				//Se a produção não foi quebrada, irá imprimir os totalizadores
				nEmpGrv    := nTotEmp
				nNecOriGrv := nTotNecOri
				nSubsGrv   := nTotSubst
				nSubOriGrv := nTotSubOr
			Else
				//Se houve quebras na produção, irá calcular quais os valores devem ser impressos
				//neste registro de rastreabilidade, de acordo com as quantidades que foram quebradas para a produção/compra.
				nEmpGrv := aLinha[snIConEstq] + aLinha[snIQuebras][nIndQuebra][1]
				If _lTransfs
					nEmpGrv += aLinha[snIQtrEnt]
				EndIf
				If nTotSubst >= 0
					nNecOriGrv := aLinha[snIConEstq] + aLinha[snISubstit] + aLinha[snIQuebras][nIndQuebra][1]
					nSubsGrv   := nTotSubst
					nSubOriGrv := nTotSubOr
					If _lTransfs
						nNecOriGrv += aLinha[snIQtrEnt]
					EndIf
				Else
					If aLinha[snIQuebras][nIndQuebra][1] > 0
						//Deve entrar aqui quando é um produto alternativo,
						//Que possui estoque, e que foi produzido.
						//Soma na qtd. do empenho o saldo de estoque.
						nEmpGrv += aLinha[snIQtdEstq]
						If _lTransfs
							nEmpGrv += aLinha[snIQtrEnt]
						EndIf
					EndIf
					nNecOriGrv := 0
					nSubsGrv   := -nEmpGrv
				EndIf
			EndIf

			nQtdEstGrv := aLinha[snIQtdEstq]
			nConEstGrv := aLinha[snIConEstq]
		Else
			//Não é o primeiro elemento da quebra, então não vai gravar quantidades de estoque e de consumo.
			//Somente calcula a qtd. necessidade original e empenho de acordo com o valor de necessidade deste registro para gravação.
			nEmpGrv    := Iif(nTotEmp    < aLinha[snIQuebras][nIndQuebra][1], nTotEmp   , aLinha[snIQuebras][nIndQuebra][1])
			nNecOriGrv := Iif(nTotNecOri < aLinha[snIQuebras][nIndQuebra][1], nTotNecOri, aLinha[snIQuebras][nIndQuebra][1])

			nQtdEstGrv := 0
			nConEstGrv := 0
		EndIf

		aAdd(aLinAux, nNecOriGrv) //HWC_QTNEOR - Necessidade original
		aAdd(aLinAux, nQtdEstGrv) //HWC_QTSLES - Qtd. estoque
		aAdd(aLinAux, nConEstGrv) //HWC_QTBXES - Qtd. Baixa
		aAdd(aLinAux, nSubsGrv  ) //HWC_QTSUBS - Qtd. Substituição
		aAdd(aLinAux, nSubOriGrv) //HWC_QTSBVL - Qtd. Substituição Validação

		If aLinha[snITipoPai] == "OP"
			aAdd(aLinAux, nEmpGrv) //HWC_QTEMPE
		Else
			aAdd(aLinAux, 0)       //HWC_QTEMPE
		EndIf

		aAdd(aLinAux, aLinha[snIQuebras][nIndQuebra][1])                                       //HWC_QTNECE - Necessidade
		aAdd(aLinAux, PadR(StrTran(aLinha[snIChvSubs], CHR(13), "")         , aLenFields[ 9])) //HWC_CHVSUB
		aAdd(aLinAux, PadR(aLinha[snICompone]+cValToChar(aLinha[snIPeriodo]), aLenFields[10])) //HWC_CHAVE
		aAdd(aLinAux, PadR(cValToChar(aLinha[snIIDRevis])                   , aLenFields[11])) //HWC_REV
		aAdd(aLinAux, PadR(cValToChar(aLinha[snIRoteiro])                   , aLenFields[12])) //HWC_ROTEIR
		aAdd(aLinAux, PadR(cValToChar(aLinha[snIOperacao])                  , aLenFields[13])) //HWC_OPERAC

		//Desconta os valores já impressos das variáveis totalizadoras.
		nTotEmp    -= nEmpGrv
		nTotNecOri -= nNecOriGrv
		nTotSubst  -= nSubsGrv

		//Adiciona o campo HWC_SEQUEN. Este campo diferencia os registros quando existe alguma quebra
		//referente às políticas de estoque.
		aAdd(aLinAux, nSequen) //HWC_SEQUEN

		//Aplica Regra HWC_LOCAL
		aLinha[snILocal] := getLocalPrd(cFilAux + aLinha[snICompone], @oCachePrd, soDominio:oDados)
		aAdd(aLinAux, PadR(cValToChar(aLinha[snILocal]), aLenFields[15])) //HWC_LOCAL

		If _lRotFil
			aAdd(aLinAux, PadR(aLinha[snIVersao]              , aLenFields[19]))
			aAdd(aLinAux, PadR(cValToChar(aLinha[snIRotFilho]), aLenFields[14])) //HWC_ROTFIL
		Else
			aAdd(aLinAux, PadR(aLinha[snIVersao]              , aLenFields[18]))
		EndIf

		If _lTransfs
			//Registra as quantidades de transferência somente no primeiro registro da quebra de lotes.
			If nIndQuebra == 1
				aAdd(aLinAux, aLinha[snIQtrEnt])
				aAdd(aLinAux, aLinha[snIQtrSai])
			Else
				aAdd(aLinAux, 0)
				aAdd(aLinAux, 0)
			EndIf
		EndIf

		If _lDocAgl
			If !Empty(aLinha[snGravaAgl]) .And. aLinha[snGravaAgl][1]
				aAdd(aLinAux, aLinha[snGravaAgl][2])
			Else
				aAdd(aLinAux, "")
			EndIf
		EndIf

		//Incrementa a sequência para o próximo registro (se houver).
		nSequen++

		If lAutomacao
			//Adiciona campo RECNO somente para ordenação dos dados para gravação na HWC, quando é utilizada automação.
			oDados:setFlag("RECNOHWC", @nRecno, .F., .F., .F., .T.)
			aAdd(aLinAux, nRecno)
		EndIf

		If soDominio:oDados:oParametros["lRastreiaEntradas"] .And. AllTrim(aLinAux[4]) != "LTVENC"
			nQtdBaixa := aLinAux[12]

			If AllTrim(aLinAux[4]) == "Pré-OP"
				nQtdNeg := soDominio:oAglutina:retornaEmpNegativo(aLinha[snIFilial], aLinha[snIPeriodo], aLinAux[7])
				If nQtdNeg < 0
					nQtdBaixa += Abs(nQtdNeg)
				EndIf
			EndIf

			soDominio:oRastreioEntradas:addDocHWC(aLinAux[1]  ,; //Filial
			                                      "OP"        ,; //Tipo Documento Entrada
			                                      aLinAux[6]  ,; //Número Documento Entrada
			                                      nIndQuebra  ,; //Sequência
			                                      aLinAux[3]  ,; //Data
			                                      aLinAux[7]  ,; //Produto
			                                      aLinAux[9]  ,; //TRT
			                                      nQtdBaixa   ,; //Baixa Estoque
			                                      aLinAux[13] ,; //Substituição
			                                      aLinAux[15] ,; //Empenho
			                                      aLinAux[16] ,; //Necessidade
			                                      aLinAux[4]  ,; //Tipo Documento Saída
			                                      aLinAux[5]  ,; //Número Documento Saída
			                                      aLinAux[8]  ,; //ID Opcional
			                                      cList       ,; //Identificador dos dados da HWC em memória
			                                      nPosDoc      ) //Índice do array de dados (ordenados) subtraído das posições de lote vencido
		EndIf

		aAdd(aResultados, aClone(aLinAux))
		aSize(aLinAux   , 0)
	Next nIndQuebra

Return

/*/{Protheus.doc} exportarAglutinacaoRastreio
Exporta Aglutinacao do Rastreio
@author    brunno.costa
@since     25/11/2019
@version 1.0
@param 01 - oDominio   , objeto, objeto da camada de dominio
/*/
METHOD exportarAglutinacaoRastreio(oDominio) CLASS MrpDominio_Saida
	Local cErrorUID := Nil
	Local oPCPError := Nil

	If oDominio:oParametros["nThreads_AGL"] <= 1
		MrpExpAglM(oDominio, oDominio:oParametros["ticket"])
	Else
		cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(), "PCPA712_MRP_" + oDominio:oParametros["ticket"])
		oPCPError := PCPMultiThreadError():New(cErrorUID)
		oPCPError:startJob("MrpExpAglM", GetEnvServer(), .F., Nil, Nil, Nil, oDominio:oParametros["ticket"])
	EndIf

Return

/*/{Protheus.doc} MrpExpAglM
Exporta aglutinação de rastreabilidade - Master
@author    brunno.costa
@since     23/10/2019
@version 1.0
@param 01 - oDominio, objeto  , objeto da classe MrpDominio passado somente sem threads adicionais - Single thread
@param 02 - cTicket , caracter, Número do ticket de processamento do MRP
/*/
Function MrpExpAglM(oDominio, cTicket)

	Local aAglutinacao := {}
	Local aLenFields   := {}
	Local aListas      := {"1", "2", "3", "4", "5", "6"}
	Local nDelegacoes  := 0
	Local nIlAglutina  := 0
	Local nInd         := 0
	Local nIndLis      := 0
	Local nThreads     := 0
	Local nTotal       := 0
	Local oAglutinacao
	Local oStatus

	If oDominio == Nil
		PrepStatics(cTicket)
		oDominio := soDominio
	EndIf

	oStatus      := oDominio:oLogs:oStatus
	oAglutinacao := oDominio:oAglutina:oAglutinacao
	nThreads     := oDominio:oParametros["nThreads_AGL"]

	oStatus:preparaAmbiente(oDominio:oDados)

	oDominio:oLogs:log("[HWG] Inicio de exportacao de resultados. " + Time(), "32")

	oAglutinacao:setflag("cFilial", xFilial("HWG"))

	//Busca o tamanho dos campos CHAR para o PadR
	aAdd(aLenFields, FWSizeFilial())
	aAdd(aLenFields, GetSx3Cache("HWG_TICKET","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWG_PROD"  ,"X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWG_DOCAGL","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWG_TPDCOR","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("HWG_DOCORI","X3_TAMANHO"))

	nIlAglutina := oDominio:oAglutina:getPosicao("AGLUTINA")

	For nIndLis := 1 To Len(aListas)
		lError := .F.
		oAglutinacao:getAllAList(aListas[nIndLis], @aAglutinacao, @lError)

		If !lError
			//Retorna todos os dados de rastreio da aglutinação - Lista 1
			nTotal := Len(aAglutinacao)
			If nTotal > 0
				//Processamento por Thread
				For nInd := 1 to nTotal
					//Desconsidera registros não aglutinados
					IF !aAglutinacao[nInd][2][nIlAglutina]
						Loop
					EndIf
					cChave := aAglutinacao[nInd][1]
					nDelegacoes++
					If oDominio:oParametros["nThreads_AGL"] <= 1
						MrpExpAglS(nDelegacoes, aListas[nIndLis], cChave, aLenFields, cTicket)
					Else
						PCPIPCGO(oDominio:oParametros["cSemaforoThreads"] + "AGL", .F., "MrpExpAglS", nDelegacoes, aListas[nIndLis], cChave, aLenFields, cTicket)
					EndIf
				Next nInd
			EndIf

			//Limpa Array Local aAglutinacao
			aSize(aAglutinacao, 0)
		EndIf
	Next nIndLis

	oAglutinacao:setflag("nDelegacoes_Rastreio", nDelegacoes, .F., .F.)
	oDominio:oLogs:log("[HWG] Termino de exportacao de resultados. " + Time(), "32")

Return

/*/{Protheus.doc} MrpExpAglS
Exporta aglutinação de rastreabilidade - Slave
@author    brunno.costa
@since     23/10/2019
@version 1.0
@param 01 - nThreadsSeq, numerico, identificador sequencial de Thread delegada
@param 02 - cLista     , caracter, código da lista identificadora da tabela utilizada:
                              1 = Carga de Demandas (PCPCargDem)
							  2 = Carga de Empenhos
							  3 = Carga de outras Saídas Previstas
							  4 = Explosão da Estrutura
@param 03 - cChave     , caracter, chave do registro aglutinado
									If lAglutina
										cChave := cFilAux + cValToChar(nPeriodo) + cProduto + chr(13)
									Else
										cChave := cFilAux + cOrigem + cDocumento + chr(13) + cValToChar(nPeriodo) + cProduto
									EndIf
@param 04 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 05 - cTicket    , caracter, número do ticket de processamento do MRP

/*/
Function MrpExpAglS(nThreadsSeq, cLista, cChave, aLenFields, cTicket)

	Local aLinha      := {}
	Local aNovasLin   := {}
	Local lError      := .F.
	Local oAglutinacao
	Local nIndAlt
	Local nAlternativos

	PrepStatics(cTicket)

	oAglutinacao := soDominio:oAglutina:oAglutinacao

	If snXProd == Nil
		snXFilial  := soDominio:oAglutina:getPosicao("FILIAL")
		snXProd    := soDominio:oAglutina:getPosicao("PRODUTO")
		snXDocAgl  := soDominio:oAglutina:getPosicao("DOCUMENTO")
		snXDocs    := soDominio:oAglutina:getPosicao("ADOC_PAI")
		snXTpDocOr := soDominio:oAglutina:getPosicao("ADOC_PAI_ORI")
		snXDocOri  := soDominio:oAglutina:getPosicao("ADOC_PAI_DOC")
		snXProdOri := soDominio:oAglutina:getPosicao("ADOC_PAI_PRODUTO")
		snXNeces   := soDominio:oAglutina:getPosicao("ADOC_PAI_QTD")
		snXEmpen   := soDominio:oAglutina:getPosicao("ADOC_PAI_QTD_EMPE")
		snXSubst   := soDominio:oAglutina:getPosicao("ADOC_PAI_QTD_SUBS")
		snXDocFil  := soDominio:oAglutina:getPosicao("ADOC_PAI_HWC_DOCFIL")
		snXQtrEnt  := soDominio:oAglutina:getPosicao("TRANSF_ENTRADA")
		snXQtrSai  := soDominio:oAglutina:getPosicao("TRANSF_SAIDA")
		snXTrt     := soDominio:oAglutina:getPosicao("ADOC_PAI_TRT")
	EndIf

	aLinha := oAglutinacao:getItemAList(cLista, cChave, @lError)
	soDominio:oAglutina:ajustesExportacao(@aLinha, @aNovasLin)

	If !lError
		MrpExpAglR(aLinha, aLenFields, oAglutinacao)

		If aNovasLin != Nil .AND. !Empty(aNovasLin)
			nAlternativos := Len(aNovasLin)
			For nIndAlt := 1 to nAlternativos
				MrpExpAglR(aNovasLin[nIndAlt], aLenFields, oAglutinacao)
			Next
		EndIf
	EndIf

	oAglutinacao:setflag("lResultT" + cValToChar(nThreadsSeq), .T., .F., .F.)

Return

/*/{Protheus.doc} MrpExpAglR
Exporta aglutinação de rastreabilidade - Insersão de Resultados
@author    brunno.costa
@since     23/10/2019
@version 1.0
@param 01 - aLinha       , array   , array com os dados do registro da aglutinação (HWG)
@param 02 - aLenFields   , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 03 - oAglutinacao , objeto  , objeto MrpData_Global de aglutinação
/*/
Static Function MrpExpAglR(aLinha, aLenFields, oAglutinacao)
	Local aDocOrig    := {}
	Local aLinAux     := {}
	Local aResultados := {}
	Local cCols       := "HWG_FILIAL,HWG_TICKET,HWG_PROD,HWG_DOCAGL,HWG_TPDCOR,HWG_DOCORI,HWG_SEQORI,HWG_PRODOR,HWG_NECESS,HWG_QTEMPE,HWG_QTSUBS"
	Local cFilGrava   := ""
	Local nDocumentos := Len(aLinha[snXDocs])
	Local lUsaME      := .F.
	Local lDocFilHWG  := .F.
	Local nIDoc       := 0
	Local nLen        := 0
	Local nTentativas := 0
	Local oStatus     := soDominio:oLogs:oStatus
	Local oDados      := soDominio:oDados
	Local oMultiEmp   := soDominio:oMultiEmp

	lUsaME := oMultiEmp:utilizaMultiEmpresa()

	If !lUsaME
		cFilGrava := PadR(oAglutinacao:getflag("cFilial")   , aLenFields[1])
	Else
		cCols += ",HWG_QTRENT,HWG_QTRSAI"
	EndIf

	If soDominio:oAglutina:usaDocFilho()
		lDocFilHWG := .T.
		cCols      += ",HWG_DOCFIL"
	EndIf

	If _lGravaTrt == Nil
		dbSelectArea("HWG")
		_lGravaTrt := FieldPos("HWG_TRT") > 0
	EndIf

	If _lGravaTrt
		cCols += ",HWG_TRT"
	EndIf

	For nIDoc := 1 to nDocumentos

		//Tratamento de erro VM - Base IES - Relação com aDel da MrpDominio_Aglutina:prepara()
		If Len(aLinha)          >= snXDocs .AND. aLinha[snXDocs]        != Nil .AND.;
			Len(aLinha[snXDocs]) >= nIDoc   .AND. aLinha[snXDocs][nIDoc] != Nil
			nLen := Len(aLinha[snXDocs][nIDoc])
		Else
			nLen := 0
		EndIf

		If nLen < snXEmpen
   			Loop
		EndIf

		If aLinha[snXDocs][nIDoc][snXNeces] + aLinha[snXDocs][nIDoc][snXEmpen] != 0 .Or.;
   		  (lUsaME .And. (aLinha[snXDocs][nIDoc][snXQtrEnt] > 0 .Or. aLinha[snXDocs][nIDoc][snXQtrSai] > 0))
			If chr(13) $ aLinha[snXDocs][nIDoc][snXDocOri]
				aDocOrig := Strtokarr2( aLinha[snXDocs][nIDoc][snXDocOri], chr(13), .T.)
			Else
				aSize(aDocOrig, 0)
				aAdd(aDocOrig, aLinha[snXDocs][nIDoc][snXDocOri])
				aAdd(aDocOrig, 1)
			EndIf
			If lUsaME
				cFilGrava := aLinha[snXFilial]
			EndIf

			cDocAgl  := aLinha[snXDocAgl]
			cTipoOri := aLinha[snXDocs][nIDoc][snXTpDocOr]
			cDocOri  := aDocOrig[1]
			nSeqOri  := aDocOrig[2]
			nNecess  := aLinha[snXDocs][nIDoc][snXNeces]
			nSubsti  := aLinha[snXDocs][nIDoc][snXSubst]

			aAdd(aLinAux, PadR(cFilGrava                         , aLenFields[1])) //HWG_FILIAL
			aAdd(aLinAux, PadR(soDominio:oParametros["ticket"]   , aLenFields[2])) //HWG_TICKET
			aAdd(aLinAux, PadR(aLinha[snXProd]                   , aLenFields[3])) //HWG_PROD
			aAdd(aLinAux, PadR(cDocAgl                           , aLenFields[4])) //HWG_DOCAGL
			aAdd(aLinAux, PadR(cTipoOri                          , aLenFields[5])) //HWG_TPDCOR
			aAdd(aLinAux, PadR(cDocOri                           , aLenFields[6])) //HWG_DOCORI
			aAdd(aLinAux, nSeqOri                                                ) //HWG_SEQORI
			aAdd(aLinAux, PadR(aLinha[snXDocs][nIDoc][snXProdOri], aLenFields[3])) //HWG_PRODOR
			aAdd(aLinAux, nNecess                                                ) //HWG_NECESS
			aAdd(aLinAux, aLinha[snXDocs][nIDoc][snXEmpen]                       ) //HWG_QTEMPE
			aAdd(aLinAux, nSubsti                                                ) //HWG_QTSUBS

			If lUsaME
				aAdd(aLinAux, aLinha[snXDocs][nIDoc][snXQtrEnt]) //HWG_QTRENT
				aAdd(aLinAux, aLinha[snXDocs][nIDoc][snXQtrSai]) //HWG_QTRSAI
			EndIf

			If lDocFilHWG
				aAdd(aLinAux, aLinha[snXDocs][nIDoc][snXDocFil]) //HWG_DOCFIL
			EndIf

			If _lGravaTrt
				aAdd(aLinAux, aLinha[snXDocs][nIDoc][snXTrt]) // HWG_TRT
			EndIf

			aAdd(aResultados, aClone(aLinAux))

			aSize(aLinAux,0)

			If soDominio:oParametros["lRastreiaEntradas"]
				soDominio:oRastreioEntradas:addAglutinado(cFilGrava, cDocAgl, cTipoOri, cDocOri, nSeqOri, "", nNecess, nSubsti)
			EndIf

			aSize(aLinha[snXDocs][nIDoc], 0)
		EndIf
	Next
	aSize(aLinha, 0)

	If !Empty(aResultados) .AND. oStatus:getStatus("status") != "4" //Não Cancelado

		If AllTrim(soDominio:oParametros["cAutomacao"]) != "1"
			//Grava resultados no banco de dados
			oStatus:preparaAmbiente(oDados)
			While nTentativas < 10
				If TCDBInsert(RetSqlName("HWG"), cCols, aResultados) < 0
					LogMsg('MRPDOMINIO_SAIDA', 14, 4, 1, '', '', tcSQLError())
					Sleep(500)
					nTentativas++
				Else
					Exit
				EndIf
			EndDo
			If nTentativas == 10
				varInfo("HWG aResultados - ", aResultados)
				UserException(tcSQLError())
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} exportarEventos
Exportar Log de Eventos do MRP
@author brunno.costa
@since 04/05/2020
@version 1.0
@param 01 - oDominio, objeto, objeto da camada de dominio
@param 02 - aArrEvt , array , array com os eventos para exportação
@return Nil
/*/
METHOD exportarEventos(oDominio, aArrEvt) CLASS MrpDominio_Saida

	Local aLenFields     := {}
	Local aEventos       := {}
	Local aResultados    := {}
	Local cCols          := "HWM_FILIAL,HWM_TICKET,HWM_PRODUT,HWM_EVENTO,HWM_LOGMRP,HWM_DOC,HWM_ITEM,HWM_ALIAS,HWM_PRDORI"
	Local cSQLName       := ""
	Local cEvento        := ""
	Local nInd           := 0
	Local nTentativas    := 0
	Local oDados         := oDominio:oDados
	Local oEventos       := oDados:oEventos
	Local oStatus        := oDominio:oLogs:oStatus
	Local nArrInd        := 0
	Local nArrTot
	Local nEventos       := 0
	Local lExpDocs       := aArrEvt == Nil

	Default aArrEvt      := {"001","004","005","006","008","009"}

	oEventos:setFlag("lExportacaoConcluida", .F.)

	If lExpDocs
		oDominio:oLogs:log("[HWM] Inicio de exportacao de resultados. " + Time(), "32")
	EndIf

	If Empty(aLenFields)
		oStatus:preparaAmbiente(oDominio:oDados)
		cSQLName := RetSqlName("HWM")

		oEventos:setflag("cFilial", xFilial("HWM"))

		//Busca o tamanho dos campos CHAR para o PadR
		aAdd(aLenFields, FWSizeFilial())
		aAdd(aLenFields, GetSx3Cache("HWM_TICKET","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_PRODUT","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_EVENTO","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_LOGMRP","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_DOC"   ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_ITEM"  ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_ALIAS" ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("HWM_PRDORI","X3_TAMANHO"))
	EndIf

	nArrTot := Len(aArrEvt)
	For nArrInd := 1 to nArrTot
		cEvento := aArrEvt[nArrInd]

		//Retorna todos os dados de opcionais da Matriz de Opcionais
		oEventos:getAllAList(cEvento, @aEventos, .F.)

		//Retorna caso não possua opcional
		If Empty(aEventos)
			Loop
		EndIf

		DbSelectArea("HWM")

		//Carrega o array com os registros a serem inseridos
		nEventos := Len(aEventos)
		For nInd := 1 To nEventos
			oDominio:oEventos:montaDadosImpressao(cEvento, aEventos[nInd], @aResultados, aLenFields)
			If Mod(nInd, 100) == 0
				If Len(aResultados) > 0
					//Insere os registros
					While nTentativas < 10
						If TCDBInsert(cSQLName, cCols, aResultados) < 0
							Sleep(500)
							nTentativas++
						Else
							Exit
						EndIf
					EndDo
					If nTentativas == 10
						nTentativas := 0
						UserException(tcSQLError())
						Exit
					EndIf
					aSize(aResultados, 0)
				EndIf
			EndIf
		Next nInd

		If Len(aResultados) > 0
			//Insere os registros
			While nTentativas < 10
				If TCDBInsert(cSQLName, cCols, aResultados) < 0
					Sleep(500)
					nTentativas++
				Else
					Exit
				EndIf
			EndDo
			If nTentativas == 10
				UserException(tcSQLError())
			EndIf
		EndIf

		aSize(aResultados, 0)
		aSize(aEventos, 0)
	Next
	aSize(aLenFields, 0)

	If lExpDocs
		While oEventos:getFlag("lProcessamentoConcluido") == Nil .OR. !oEventos:getFlag("lProcessamentoConcluido")
			Sleep(50)
		EndDo
		Self:exportarEventos(oDominio, {"002","003","007"})
	Else
		oEventos:setFlag("lExportacaoConcluida", .T.)
		oDominio:oLogs:log("[HWM] Termino de exportacao de resultados. " + Time(), "32")
	EndIf

Return

/*/{Protheus.doc} exportarTransferencia
Exportar as transferências geradas pelo MultiEmpresa
@author ricardo.prandi
@since 15/12/2020
@version 1.0
@param 01 - oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD exportarTransferencia(oDominio) CLASS MrpDominio_Saida

	Local aLenFields     := {}
	Local aResultados    := {}
	Local aTransf        := {}
	Local cCols          := "MA_FILIAL,MA_FILORIG,MA_FILDEST,MA_PROD,MA_DTTRANS,MA_QTDTRAN,MA_STATUS,MA_TICKET,MA_DOCUM,MA_ARMORIG,MA_ARMDEST,MA_DTRECEB"
	Local cFilAux        := xFilial("SMA")
	Local nInd           := 0
	Local nTamArray      := 0
	Local nTentativas    := 0
	Local oCachePrd      := JsonObject():New()
	Local oStatus        := oDominio:oLogs:oStatus
	Local oTransf        := oDominio:oDados:oTransferencia

	//Retorna todos os dados de transferência da tabela
	oTransf:getAllRow(aTransf, .F.)

	//Retorna caso não possua registros
	If Empty(aTransf)
		Return
	EndIf

	oStatus:preparaAmbiente(oDominio:oDados)

	oDominio:oLogs:log("[SMA] Inicio de exportacao de resultados. " + Time(), "32")

	//Busca o tamanho dos campos CHAR para o PadR
	aAdd(aLenFields, FWSizeFilial())
	aAdd(aLenFields, GetSx3Cache("MA_FILORIG","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("MA_FILDEST","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("MA_PROD"   ,"X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("MA_TICKET" ,"X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("MA_ARMORIG","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("MA_ARMDEST","X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("MA_DOCUM"  ,"X3_TAMANHO"))

	//Carrega o array com os registros a serem inseridos
	nTamArray := Len(aTransf)
	For nInd := 1 To nTamArray
		LinTRANFBD(cFilAux, aTransf[nInd], @aResultados, oTransf, oDominio:oParametros["ticket"], aLenFields, @oCachePrd, oDominio:oDados)
	Next nInd

	//Insere os registros
	While nTentativas < 10
		If TCDBInsert(RetSqlName("SMA"), cCols, aResultados) < 0
			Sleep(500)
			nTentativas++
		Else
			Exit
		EndIf
	EndDo
	If nTentativas == 10
		UserException(tcSQLError())
	EndIf

	oDominio:oLogs:log("[SMA] Termino de exportacao de resultados. " + Time(), "32")

	aSize(aResultados, 0)
	aSize(aLenFields , 0)
	aSize(aTransf, 0)
Return

/*/{Protheus.doc} LinTRANFBD
Gera Linha de Exportação da Tabela de Transferências
@author    ricardo.prandi
@since     08/02/2021
@version 1.0
@param 01 - cFilAux    , caracter, filial de inclusão da tabela
@param 01 - aTransf    , array   , linha de transferência
@param 02 - aResultados, array   , retorna por referência array dos opcionais
@param 03 - oTransf    , objeto  , objeto de transferência
@param 04 - cTicket    , caracter, ticket referente execução do MRP
@param 05 - aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
@param 06 - oCachePrd  , Object  , jsonObject utilizado como cache das informações do Local do produto
@param 07 - oDados     , Object  , Instância de Dados do MRP
/*/
Static Function LinTRANFBD(cFilAux, aTransf, aResultados, oTransf, cTicket, aLenFields, oCachePrd, oDados)

	Local aLinAux    := {}
	Local cChaveProd := ""
	Local cLocal     := ""

	//Adiciona campos na ordem de cCols
	aAdd(aLinAux, PadR(cFilAux                             , aLenFields[1])) //MA_FILIAL
	aAdd(aLinAux, PadR(aTransf[2][TRANF_POS_FILIAL_ORIGEM ], aLenFields[2])) //MA_FILORIG
	aAdd(aLinAux, PadR(aTransf[2][TRANF_POS_FILIAL_DESTINO], aLenFields[3])) //MA_FILDEST
	aAdd(aLinAux, PadR(aTransf[2][TRANF_POS_PRODUTO       ], aLenFields[4])) //MA_PROD
	aAdd(aLinAux, aTransf[2][TRANF_POS_DATA               ]                ) //MA_DTTRANS
	aAdd(aLinAux, aTransf[2][TRANF_POS_QUANTIDADE         ]                ) //MA_QTDTRAN
	aAdd(aLinAux, "0"                                                      ) //MA_STATUS
	aAdd(aLinAux, PadR(cTicket                             , aLenFields[5])) //MA_TICKET
	aAdd(aLinAux, PadR(aTransf[2][TRANF_POS_DOCUMENTO     ], aLenFields[8])) //MA_DOCUM

	//Busca local padrão filial origem
	cChaveProd := aTransf[2][TRANF_POS_FILIAL_ORIGEM] + aTransf[2][TRANF_POS_PRODUTO]
	cLocal := getLocalPrd(cChaveProd, @oCachePrd, oDados)
	aAdd(aLinAux, PadR(cLocal, aLenFields[6])) //MA_ARMORIG

	//Busca local padrão filial destino
	cChaveProd := aTransf[2][TRANF_POS_FILIAL_DESTINO] + aTransf[2][TRANF_POS_PRODUTO]
	cLocal := getLocalPrd(cChaveProd, @oCachePrd, oDados)
	aAdd(aLinAux, PadR(cLocal, aLenFields[7])) //MA_ARMDEST

	aAdd(aLinAux, aTransf[2][TRANF_POS_DATA_RECEBIMENTO   ]) //MA_DTRECEB

	aAdd(aResultados, aLinAux)
Return

/*/{Protheus.doc} exportarComplementoHWB
Gera dados das filiais que estão "incompletas" na tabela HWB quando utilizado Multi-Empresa.
Para o MRP Multi-empresa, os registros na HWB devem existir em todas as filiais para cada data quando existe algum saldo.

@author lucas.franca
@since 02/07/2021
@version 1.0
@param 01 - oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD exportarComplementoHWB(oDominio) CLASS MrpDominio_Saida
	Local aResultado := {}
	Local cAlias     := ""
	Local cChavePrd  := ""
	Local cCols      := "HWB_FILIAL,HWB_TICKET,HWB_DATA,HWB_PRODUT,HWB_IDOPC,HWB_QTSLES,HWB_QTENTR,HWB_QTSAID,HWB_QTSEST,HWB_QTSALD,HWB_QTNECE,HWB_DTINIC,HWB_NIVEL,HWB_QTRENT,HWB_QTRSAI"
	Local cFilAux    := ""
	Local cProduto   := ""
	Local cQuery     := ""
	Local cNivel     := ""
	Local cTabHWB    := RetSqlName("HWB")
	Local nIndBuff   := 0
	Local nTotBuff   := 0
	Local nIndex     := 0
	Local nIndIni    := 0
	Local nTotal     := 0
	Local nSldIni    := 0
	Local nTentativa := 0
	Local oMultiEmp  := oDominio:oMultiEmp
	Local oCachePrd  := JsonObject():New()

	If ! oMultiEmp:utilizaMultiEmpresa()
		Return
	EndIf

	oDominio:oLogs:log("[HWB + ME] Inicio de exportacao de complemento de resultados. " + Time(), "32")

	nTotBuff := Ceiling(oMultiEmp:totalDeFiliais()/5)

	For nIndBuff := 1 To nTotBuff
		//Busca produtos que existam na HWB mas não possuem o registro para todas as filiais.
		//Replica o registro nas filiais necessárias considerando o registro com data menor na HWB. Se não encontrar
		//com data menor, utiliza o de data maior para replicar os dados.
		cQuery  := " SELECT HWB_FILIAL, HWB_TICKET, HWB_DATA, HWB_PRODUT, HWB_IDOPC, HWB_QTSLES, HWB_QTSALD, HWB_DTINIC, HWB_NIVEL "
		cQuery  +=   " FROM ("

		nIndIni := nTotal + 1

		If nIndBuff == nTotBuff
			nTotal := oMultiEmp:totalDeFiliais()
		Else
			nTotal := nIndBuff * 5
		EndIf

		For nIndex := nIndIni To nTotal
			If nIndex > nIndIni
				cQuery += " UNION "
			EndIf

			cQuery += " SELECT DISTINCT '" + oMultiEmp:filialPorIndice(nIndex) + "' AS HWB_FILIAL, "
			cQuery +=                 " HWB.HWB_TICKET,"
			cQuery +=                 " HWB.HWB_DATA,"
			cQuery +=                 " HWB.HWB_PRODUT,"
			cQuery +=                 " HWB.HWB_IDOPC,"
			cQuery +=                 " CASE"
			cQuery +=                    " WHEN HWBREPL.HWB_DATA < HWB.HWB_DATA THEN HWBREPL.HWB_QTSALD + HWBREPL.HWB_QTNECE"
			cQuery +=                    " ELSE HWBREPL.HWB_QTSLES"
			cQuery +=                 " END AS HWB_QTSLES,"
			cQuery +=                 " CASE"
			cQuery +=                    " WHEN HWBREPL.HWB_DATA < HWB.HWB_DATA THEN HWBREPL.HWB_QTSALD + HWBREPL.HWB_QTNECE"
			cQuery +=                    " ELSE HWBREPL.HWB_QTSLES"
			cQuery +=                 " END AS HWB_QTSALD,"
			cQuery +=                 " HWB.HWB_DATA AS HWB_DTINIC,"
			cQuery +=                 " HWBREPL.HWB_NIVEL"
			cQuery +=            " FROM " + cTabHWB + " HWB "
			cQuery +=            " LEFT OUTER JOIN " + cTabHWB + " HWBREPL"
			cQuery +=              " ON HWBREPL.HWB_FILIAL = '" + oMultiEmp:filialPorIndice(nIndex) + "'"
			cQuery +=             " AND HWBREPL.HWB_TICKET = HWB.HWB_TICKET"
			cQuery +=             " AND HWBREPL.HWB_PRODUT = HWB.HWB_PRODUT"
			cQuery +=             " AND HWBREPL.HWB_IDOPC  = HWB.HWB_IDOPC"
			cQuery +=             " AND HWBREPL.D_E_L_E_T_ = ' '"
			cQuery +=             " AND HWBREPL.HWB_DATA   = ( COALESCE( (SELECT MAX(HWBDATA.HWB_DATA)
			cQuery +=                                                     " FROM " + cTabHWB + " HWBDATA"
			cQuery +=                                                    " WHERE HWBDATA.HWB_FILIAL = HWBREPL.HWB_FILIAL"
			cQuery +=                                                      " AND HWBDATA.HWB_TICKET = HWBREPL.HWB_TICKET"
			cQuery +=                                                      " AND HWBDATA.HWB_PRODUT = HWBREPL.HWB_PRODUT"
			cQuery +=                                                      " AND HWBDATA.HWB_IDOPC  = HWBREPL.HWB_IDOPC"
			cQuery +=                                                      " AND HWBDATA.D_E_L_E_T_ = ' '"
			cQuery +=                                                      " AND HWBDATA.HWB_DATA   < HWB.HWB_DATA ),"
			cQuery +=                                                    " (SELECT MIN(HWBDATA.HWB_DATA)"
			cQuery +=                                                     " FROM " + cTabHWB + " HWBDATA"
			cQuery +=                                                    " WHERE HWBDATA.HWB_FILIAL = HWBREPL.HWB_FILIAL"
			cQuery +=                                                      " AND HWBDATA.HWB_TICKET = HWBREPL.HWB_TICKET"
			cQuery +=                                                      " AND HWBDATA.HWB_PRODUT = HWBREPL.HWB_PRODUT"
			cQuery +=                                                      " AND HWBDATA.HWB_IDOPC  = HWBREPL.HWB_IDOPC"
			cQuery +=                                                      " AND HWBDATA.D_E_L_E_T_ = ' '"
			cQuery +=                                                      " AND HWBDATA.HWB_DATA   > HWB.HWB_DATA )) )"
			cQuery +=           " WHERE HWB.HWB_FILIAL <> '" + oMultiEmp:filialPorIndice(nIndex) + "'"
			cQuery +=             " AND HWB.HWB_TICKET = '" + oDominio:oParametros["ticket"] + "'"
			cQuery +=             " AND HWB.D_E_L_E_T_ = ' '"
			cQuery +=             " AND HWB.HWB_DATA NOT IN (SELECT HWBAUX.HWB_DATA"
			cQuery +=                                        " FROM " + cTabHWB + " HWBAUX"
			cQuery +=                                       " WHERE HWBAUX.HWB_FILIAL = '" + oMultiEmp:filialPorIndice(nIndex) + "'"
			cQuery +=                                         " AND HWBAUX.HWB_TICKET = HWB.HWB_TICKET"
			cQuery +=                                         " AND HWBAUX.HWB_PRODUT = HWB.HWB_PRODUT"
			cQuery +=                                         " AND HWBAUX.HWB_IDOPC  = HWB.HWB_IDOPC"
			cQuery +=                                         " AND HWBAUX.D_E_L_E_T_ = ' ')"
			cQuery +=             " AND EXISTS(SELECT 1"
			cQuery +=                          " FROM " + cTabHWB + " HWBAUX"
			cQuery +=                         " WHERE HWBAUX.HWB_FILIAL = '" + oMultiEmp:filialPorIndice(nIndex) + "'"
			cQuery +=                           " AND HWBAUX.HWB_TICKET = HWB.HWB_TICKET"
			cQuery +=                           " AND HWBAUX.HWB_PRODUT = HWB.HWB_PRODUT"
			cQuery +=                           " AND HWBAUX.HWB_IDOPC  = HWB.HWB_IDOPC"
			cQuery +=                           " AND HWBAUX.HWB_DATA  <> HWB.HWB_DATA"
			cQuery +=                           " AND HWBAUX.D_E_L_E_T_ = ' ')"
		Next nIndex

		cQuery +=        " ) HWB "
		cQuery +=  " WHERE HWB.HWB_QTSLES <> 0 "
		cQuery +=     " OR HWB.HWB_QTSALD <> 0 "

		nIndex := 0
		cAlias := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

		While (cAlias)->(!Eof())

			nIndex++

			aAdd(aResultado, {(cAlias)->HWB_FILIAL,;
							(cAlias)->HWB_TICKET,;
							(cAlias)->HWB_DATA  ,;
							(cAlias)->HWB_PRODUT,;
							(cAlias)->HWB_IDOPC ,;
							(cAlias)->HWB_QTSLES,;
							0                   ,;//HWB_QTENTR
							0                   ,;//HWB_QTSAID
							0                   ,;//HWB_QTSEST
							(cAlias)->HWB_QTSALD,;
							0                   ,;//HWB_QTNECE
							(cAlias)->HWB_DTINIC,;
							(cAlias)->HWB_NIVEL ,;
							0                   ,;//HWB_QTRENT
							0                   })//HWB_QTRSAI

			(cAlias)->(dbSkip())

			//Transferencias parciais de string para variavel global / Banco
			If (cAlias)->(Eof()) .Or. Mod(nIndex, 500) == 0
				While nTentativa < 10
					If TCDBInsert(cTabHWB, cCols, aResultado) < 0
						Sleep(500)
						nTentativa++
					Else
						Exit
					EndIf
				EndDo

				aSize(aResultado, 0)

				If nTentativa == 10
					UserException(tcSQLError())
				EndIf

				nTentativa := 0
				nIndex     := 0
			EndIf
		End
		(cAlias)->(dbCloseArea())

		//Após a primeira varredura, faz novamente a busca dos registros, para identificar os registros que
		//devem ser replicados, mas que não possuem nenhum registro na HWB para efetuar a réplica dos dados.
		//Vincula com a T4V para pegar somente produtos que possuem saldo, mas não possuem nenhum tipo de necessidade ou entrada.
		cQuery := " SELECT HWB_FILIAL, HWB_TICKET, HWB_DATA, HWB_PRODUT, HWB_IDOPC "
		cQuery +=   " FROM ("

		For nIndex := nIndIni To nTotal
			If nIndex > nIndIni
				cQuery += " UNION "
			EndIf

			cQuery += " SELECT DISTINCT '" + oMultiEmp:filialPorIndice(nIndex) + "' AS HWB_FILIAL, "
			cQuery +=                 " HWB.HWB_TICKET, HWB.HWB_DATA, HWB.HWB_PRODUT, HWB.HWB_IDOPC  "
			cQuery +=   " FROM " + cTabHWB + " HWB"
			cQuery +=  " WHERE HWB.HWB_FILIAL <> '" + oMultiEmp:filialPorIndice(nIndex) + "'"
			cQuery +=    " AND HWB.HWB_TICKET = '" + oDominio:oParametros["ticket"] + "'"
			cQuery +=    " AND HWB.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NOT EXISTS (SELECT 1 "
			cQuery +=                      " FROM " + cTabHWB + " HWBAUX "
			cQuery +=                     " WHERE HWBAUX.HWB_TICKET = HWB.HWB_TICKET"
			cQuery +=                       " AND HWBAUX.HWB_FILIAL = '" + oMultiEmp:filialPorIndice(nIndex) + "'"
			cQuery +=                       " AND HWBAUX.D_E_L_E_T_ = ' ' "
			cQuery +=                       " AND HWBAUX.HWB_PRODUT = HWB.HWB_PRODUT "
			cQuery +=                       " AND HWBAUX.HWB_IDOPC  = HWB.HWB_IDOPC) "
			cQuery +=    " AND EXISTS( SELECT 1 "
			cQuery +=                  " FROM " + RetSqlName("T4V") + " T4V "
			cQuery +=                 " WHERE T4V.T4V_FILIAL = '" + xFilial("T4V", oMultiEmp:filialPorIndice(nIndex)) + "'"
			cQuery +=                   " AND T4V.T4V_PROD   = HWB.HWB_PRODUT"
			cQuery +=                   " AND T4V.T4V_QTD    <> 0 "
			cQuery +=                   " AND T4V.D_E_L_E_T_ = ' ' ) "
		Next nIndex
		cQuery +=        " ) HWB "

		nIndex := 0
		cAlias := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

		While (cAlias)->(!Eof())
			cFilAux   := PadR((cAlias)->(HWB_FILIAL), oMultiEmp:tamanhoFilial())
			cProduto  := PadR((cAlias)->(HWB_PRODUT), snTamCod)
			cChavePrd := cFilAux + cProduto

			If !Empty((cAlias)->(HWB_IDOPC))
				cChavePrd += "|" + (cAlias)->(HWB_IDOPC)
			EndIf

			nSldIni := oDominio:saldoInicial(cFilAux, cProduto, 1, cChavePrd, (cAlias)->(HWB_IDOPC))
			If nSldIni <> 0
				nIndex++
				cNivel := getNivel(cChavePrd, @oCachePrd, oDominio:oDados, StoD((cAlias)->HWB_DATA), (cAlias)->HWB_IDOPC)
				aAdd(aResultado, {(cAlias)->HWB_FILIAL,;
								(cAlias)->HWB_TICKET,;
								(cAlias)->HWB_DATA  ,;
								(cAlias)->HWB_PRODUT,;
								(cAlias)->HWB_IDOPC ,;
								nSldIni             ,;
								0                   ,;//HWB_QTENTR
								0                   ,;//HWB_QTSAID
								0                   ,;//HWB_QTSEST
								nSldIni             ,;
								0                   ,;//HWB_QTNECE
								(cAlias)->HWB_DATA  ,;
								cNivel              ,;
								0                   ,;//HWB_QTRENT
								0                   })//HWB_QTRSAI
			EndIf

			(cAlias)->(dbSkip())

			//Transferencias parciais de string para variavel global / Banco
			If nIndex > 0 .And. ((cAlias)->(Eof()) .Or. Mod(nIndex, 500) == 0)
				While nTentativa < 10
					If TCDBInsert(cTabHWB, cCols, aResultado) < 0
						Sleep(500)
						nTentativa++
					Else
						Exit
					EndIf
				EndDo

				aSize(aResultado, 0)

				If nTentativa == 10
					UserException(tcSQLError())
				EndIf

				nTentativa := 0
				nIndex     := 0
			EndIf
		End
		(cAlias)->(dbCloseArea())
	Next nIndBuff

	FreeObj(oCachePrd)
	oCachePrd := Nil

	oDominio:oLogs:log("[HWB + ME] Termino de exportacao de complemento de resultados. " + Time(), "32")

Return

/*/{Protheus.doc} aguardaSMV
Verificar o término do processamento da SMV, aguardando a finalização.

@author lucas.franca
@since 08/12/2021
@version P12
@param oDominio, Object, Objeto da camada de domínio
@return Nil
/*/
Method aguardaSMV(oDominio) Class MrpDominio_Saida
	Local cStatus    := oDominio:oDados:oMatriz:getFlag("TERMINO_GRAVACAO_SMV")
	Local lCancelado := oDominio:oLogs:oStatus:getStatus("status") == "4"

	While cStatus != Nil .And. cStatus == "N" .And. !lCancelado
		Sleep(100)
		cStatus    := oDominio:oDados:oMatriz:getFlag("TERMINO_GRAVACAO_SMV")
		lCancelado := oDominio:oLogs:oStatus:getStatus("status") == "4"
	End
Return Nil

/*/{Protheus.doc} aguardaTermino
Aguarda Término da Exportação dos Resultados
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD aguardaTermino(oDominio) CLASS MrpDominio_Saida
	Local aResultados := {}
	Local lCancelado  := .F.
	Local lConcluiu   := .F.
	Local lError      := .F.
	Local lRetAux     := .F.
	Local nIndAux     := 0
	Local nMaximo     := 0
	Local oDados      := oDominio:oDados
	Local oEventos    := oDados:oEventos
	Local oMatriz     := oDados:oMatriz
	Local oStatus     := oDominio:oLogs:oStatus

	//Aguarda Término Exportação da Matriz
	While !lCancelado .AND. oMatriz:getflag("nUsdThread") == Nil
		Sleep(50)
		If oStatus:getStatus("status") == "4"//Cancelado
			lCancelado := .T.
		EndIF
	EndDo
	nMaximo := oMatriz:getflag("nUsdThread")
	While !lCancelado .AND. !lConcluiu
		lConcluiu := .T.
		For nIndAux := 1 to nMaximo
			lRetAux := oMatriz:getflag("lResultT" + PadL(nIndAux, 2, "0"))
			If lRetAux == Nil .Or. !lRetAux
				lConcluiu := .F.
				Exit
			EndIf
		Next nIndAux
		Sleep(50)
		If oStatus:getStatus("status") == "4"//Cancelado
			lCancelado := .T.
		EndIF
	EndDo
	If !lCancelado
		oMatriz:getAllRes(@aResultados, @lError)
		aEval(aResultados, {|x| oMatriz:setResult(x[1], "", .F., .F.) })
		aSize(aResultados, 0)
	EndIf

	//Aguarda Término Exportação de Rastreio
	::aguardaRastreio(oDominio)

	::aguardaAglutinacao(oDominio)

	If oDados:oParametros['lEventLog']
		//Aguarda Término Exportação do Log de Eventos
		While !lCancelado .AND. oEventos:getflag("lExportacaoConcluida") == Nil
			Sleep(50)
			If oStatus:getStatus("status") == "4"//Cancelado
				lCancelado := .T.
			EndIF
		EndDo
		lConcluiu := .F.
		While !lCancelado .AND. !lConcluiu
			lConcluiu := oEventos:getflag("lExportacaoConcluida")
			Sleep(50)
			If oStatus:getStatus("status") == "4"//Cancelado
				lCancelado := .T.
			EndIF
		EndDo
	EndIf

	If oDominio:oDados:oParametros['lAnalisaMemoriaPosExpRastreio']
		oDominio:oDados:oProdutos:analiseMemoria(oDominio:oDados:oParametros['lAnalisaMemoriaSplit'], STR0119) //Análise de Memória Após Exportação do Rastreio
	EndIf

Return

/*/{Protheus.doc} exportarDocumentos
Exporta os documentos utilizados no cálculo do MRP - tabela SMV (entradas/saídas)

@author lucas.franca
@since 07/12/2021
@version 1.0
@param oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD exportarDocumentos(oDominio) CLASS MrpDominio_Saida
	If oDominio:oParametros["nThreads_MAT"] <= 1
		MrpExpDocs(oDominio:oParametros["ticket"])
	Else
		PCPIPCGO(oDominio:oParametros["cSemaforoThreads"] + "MAT", .F., "MrpExpDocs", oDominio:oParametros["ticket"])
	EndIf
Return

/*/{Protheus.doc} exportarEntradas
Exporta o rastreio das entradas
@author marcelo.neumann
@since 08/10/2020
@version 1.0
@param oDominio, objeto, objeto da camada de dominio
@param nTotProc, numero, total de registros processados para manter atualização de barra de progresso
@return Nil
/*/
METHOD exportarEntradas(oDominio, nTotProc) CLASS MrpDominio_Saida
	Local aProds       := {}
	Local aLenFields   := {}
	Local cNivelAtu    := ""
	Local nIndex       := 0
	Local nTotal       := 0
	Local nProcOk      := 0
	Local oRastreioEnt := oDominio:oDados:oRastreioEntradas
	Local oStatus      := oDominio:oLogs:oStatus

	dbSelectArea("SME")
	_lLoteSME := Fieldpos("ME_LOTE") > 0 .And. Fieldpos("ME_SLOTE") > 0

	oRastreioEnt:setFlag("lExportacaoConcluida", .F.)
	oRastreioEnt:setFlag("RASTRO_DEM_FINALIZADOS", 0)
	oStatus:preparaAmbiente(oDominio:oDados)

	//Busca o tamanho dos campos CHAR para o PadR
	aAdd(aLenFields, GetSx3Cache("ME_TICKET" , "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_NMDCENT", "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_PRODUTO", "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_TIPO"   , "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_TPDCSAI", "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_NMDCSAI", "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_IDREG"  , "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_TRT"    , "X3_TAMANHO"))
	aAdd(aLenFields, GetSx3Cache("ME_IDPAI"  , "X3_TAMANHO"))

	If _lLoteSME
		aAdd(aLenFields, GetSx3Cache("ME_LOTE" , "X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("ME_SLOTE", "X3_TAMANHO"))
	EndIf

	//Recupera a lista de produtos para exportação da rastreabilidade
	oRastreioEnt:getAllList("PRODUTOS_SME", @aProds)

	//Carrega o nível correto para produtos que não registraram o nível corretamente na carga dos dados.
	aEval(aProds, {|aProd| Iif(aProd[2]=='--', aProd[2] := oDominio:oRastreioEntradas:getNivel(aProd[1]), Nil) })

	//Ordena os produtos para processamento por nível
	aSort(aProds, , , {|x,y| x[2] < y[2] })

	//Percorre os produtos delegando o processamento para as threads
	nTotal := Len(aProds)
	nIndex := 0
	While nIndex < nTotal .And. oStatus:getStatus("status") <> "4"
		nIndex++

		If cNivelAtu <> aProds[nIndex][2] .And. !Empty(cNivelAtu)
			//Aguarda finalizar o nível anterior
			While oRastreioEnt:getFlag("RASTRO_DEM_FINALIZADOS") < nIndex-1 .And. oStatus:getStatus("status") <> "4"
				Sleep(500)
				Loop
			End
		EndIf
		cNivelAtu := aProds[nIndex][2]

		If oDominio:oParametros["nThreads"] <= 1
			MrpExpRDem(oDominio:oParametros["ticket"], aProds[nIndex][1], aLenFields)
		Else
			PCPIPCGO(oDominio:oParametros["cSemaforoThreads"], .F., "MrpExpRDem", oDominio:oParametros["ticket"], aProds[nIndex][1], aLenFields)
		EndIf

		//Atualiza percentual de gravação
		nProcOk := oRastreioEnt:getFlag("RASTRO_DEM_FINALIZADOS")
		oDominio:oRastreioEntradas:atualizaPercentual(oDominio, nTotProc, nTotal, nProcOk)
	End

	//Aguarda finalizar os processamentos delegados
	While nProcOk < nIndex .And. oStatus:getStatus("status") <> "4"
		nProcOk := oRastreioEnt:getFlag("RASTRO_DEM_FINALIZADOS")
		oDominio:oRastreioEntradas:atualizaPercentual(oDominio, nTotProc, nTotal, nProcOk)
		Sleep(500)
		Loop
	End

	oRastreioEnt:setFlag("lExportacaoConcluida", .T.)

	aSize(aProds, 0)
	aSize(aLenFields, 0)

Return

/*/{Protheus.doc} MrpExpRDem
Função para processar e gravar dados de rastreabilidade de determinado produto

@author lucas.franca
@since 30/11/2022
@version P12
@param 01 cTicket    , caracter, número do ticket do MRP
@param 02 cChave     , caracter, Chave para identificar o produto que será processado
@param 03 aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
/*/
Function MrpExpRDem(cTicket, cChave, aLenFields)
	Local aEntradas    := {}
	Local aResultados  := {}
	Local cFilSME      := ""
	Local cCols        := "ME_FILIAL,ME_TICKET,ME_TPDCENT,ME_NMDCENT,ME_DATA,ME_PRODUTO,ME_QUANT,ME_TIPO,ME_TPDCSAI,ME_NMDCSAI,ME_IDREG,ME_TRT,ME_IDPAI"
	Local nEntradas    := 0
	Local nInd         := 0
	Local oRastreioEnt := Nil

	dbSelectArea("SME")
	_lLoteSME := Fieldpos("ME_LOTE") > 0 .And. Fieldpos("ME_SLOTE") > 0

	If _lLoteSME
		cCols += ",ME_LOTE,ME_SLOTE"
	EndIf

	PrepStatics(cTicket)
	soDominio:oLogs:oStatus:preparaAmbiente(soDominio:oDados)

	oRastreioEnt := soDominio:oDados:oRastreioEntradas
	cFilSME      := xFilial("SME")

	//Carrega o array com os registros a serem inseridos
	aEntradas := soDominio:oRastreioEntradas:getEntradas(cChave)
	nEntradas := Len(aEntradas)
	soDominio:oRastreioEntradas:ordena(@aEntradas)

	For nInd := 1 To nEntradas
		LinEntBD(soDominio, cFilSME, cTicket, aEntradas[nInd], @aResultados, aLenFields)

		If Len(aResultados) >= QTD_LINHAS_INCLUI .Or. nInd == nEntradas
			//Grava resultados no banco de dados
			gravaDados(RetSqlName("SME"), cCols, aResultados)
			aSize(aResultados, 0)
		EndIf
	Next nInd

	aSize(aEntradas  , 0)

	//Incrementa finalizados
	oRastreioEnt:setFlag("RASTRO_DEM_FINALIZADOS", 1,,,, .T.)
Return

/*/{Protheus.doc} LinEntBD
Gera Linha de Exportação da Tabela de Rastreio das Entradas - BD
@author marcelo.neumann
@since 08/10/2020
@version 1.0
@param 01 oDominio   , objeto  , instância da classe do dominio
@param 02 cFilAux    , caracter, código da filial
@param 03 cTicket    , caracter, número do ticket do MRP
@param 04 aRetAux    , array   , array com as entradas que estavam na global
@param 05 aResultados, array   , retorna por referência array com os resultados
@param 06 aLenFields , array   , array com o tamanho dos campos CHAR para gravar com PadR
/*/
Static Function LinEntBD(oDominio, cFilAux, cTicket, aRetAux, aResultados, aLenFields)
	Local aLinAux   := {}
	Local aRegistro := {}
	Local nIndex    := 0
	Local nLenReg   := 0
	Local nQuantFld := 13

	If _lLoteSME
		nQuantFld += 2
	EndIf
	aLinAux := Array(nQuantFld)

	aLinAux[1] := aRetAux[1]                      //01-ME_FILIAL
	aLinAux[2] := PadR(cTicket   , aLenFields[1]) //02-ME_TICKET
	aLinAux[5] := aRetAux[4]                      //05-ME_DATA
	aLinAux[6] := PadR(aRetAux[5], aLenFields[3]) //06-ME_PRODUTO

	//Tratamento do registro de rastreio (se estiver aglutinado, faz a explosão do registro)
	aRegistro := oDominio:oRastreioEntradas:trataRegistroSME(aLinAux[1] , ; //Filial
	                                                         aRetAux[2] , ; //Tipo Documento Entrada
	                                                         aRetAux[3] , ; //Número Documento Entrada
	                                                         aLinAux[5] , ; //Data
	                                                         aLinAux[6] , ; //Produto
	                                                         aRetAux[6] , ; //TRT
	                                                         aRetAux[7] , ; //Quantidade
	                                                         aRetAux[8] , ; //Tipo do registro
	                                                         aRetAux[9] , ; //Tipo Documento Saída
	                                                         aRetAux[10], ; //Número Documento Saída
	                                                         aRetAux[12], ; //Documento pai HWC
	                                                         aRetAux[13], ; //Sequência do registro da HWC
	                                                         aRetAux[14], ; //Id Opcional
	                                                         aRetAux[15], ; //Lote
	                                                         aRetAux[16]  ) //Sub-lote

	nLenReg := Len(aRegistro)
	For nIndex := 1 To nLenReg
		If aRegistro[nIndex][6] == 0
			Loop
		EndIf

		aLinAux[3]  := aRegistro[nIndex][2]                        //Tipo Documento Entrada
		aLinAux[4]  := PadR(aRegistro[nIndex][3] , aLenFields[2])  //Número Documento Entrada
		aLinAux[7]  := aRegistro[nIndex][6]                        //Quantidade
		aLinAux[8]  := PadR(aRegistro[nIndex][7] , aLenFields[4])  //Tipo do registro
		aLinAux[9]  := PadR(aRegistro[nIndex][8] , aLenFields[5])  //Tipo Documento Saída
		aLinAux[10] := PadR(aRegistro[nIndex][9] , aLenFields[6])  //Número Documento Saída
		aLinAux[11] := PadR(aRegistro[nIndex][12], aLenFields[7])  //Identificador único do registro
		aLinAux[12] := PadR(aRegistro[nIndex][10], aLenFields[8])  //TRT
		aLinAux[13] := PadR(aRegistro[nIndex][11], aLenFields[9])  //Identificador do registro pai

		If _lLoteSME
			aLinAux[14] := PadR(aRegistro[nIndex][15], aLenFields[10])  //Lote
			aLinAux[15] := PadR(aRegistro[nIndex][16], aLenFields[11])  //Sub-lote
		EndIf

		aAdd(aResultados, aClone(aLinAux))

		aSize(aRegistro[nIndex], 0)
	Next nIndex

	aSize(aLinAux  , 0)
	aSize(aRegistro, 0)
Return

/*/{Protheus.doc} PrepStatics
Exporta resultados por Thread
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cTicket, caracter, Número do ticket de processamento do MRP
/*/
Static Function PrepStatics(cTicket)

	If soDominio == Nil
		SET DATE FRENCH; Set(_SET_EPOCH, 1980)

		soDominio := MRPPrepDom(cTicket)
		soDados   := soDominio:oDados
	EndIf

Return

/*/{Protheus.doc} aguardaRastreio
Aguarda o término da exportação da HWC
@author marcelo.neumann
@since 30/11/2020
@version 1.0
@param oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD aguardaRastreio(oDominio) CLASS MrpDominio_Saida
	Local lCancelado   := .F.
	Local lConcluiu    := .F.
	Local lRetAux      := .F.
	Local nIndAux      := 1
	Local nMaximo      := 0
	Local oDadosRas    := oDominio:oRastreio:oDados_Rastreio:oDados
	Local oStatus      := oDominio:oLogs:oStatus

	//Aguarda Término Exportação de Rastreio
	While !lCancelado .AND. oDadosRas:getflag("nDelegacoes_Rastreio") == Nil
		Sleep(50)
		If oStatus:getStatus("status") == "4"//Cancelado
			lCancelado := .T.
		EndIF
	EndDo

	If !lCancelado
		nMaximo := oDadosRas:getflag("nDelegacoes_Rastreio")
	EndIf
	lConcluiu := .F.

	While !lCancelado .AND. !lConcluiu
		lConcluiu := .T.

		For nIndAux := 1 To nMaximo
			lRetAux := oDadosRas:getflag("lResultT" + cValToChar(nIndAux))
			If lRetAux == Nil .Or. !lRetAux
				lConcluiu := .F.
				Exit
			EndIf
		Next nIndAux

		Sleep(50)

		If oStatus:getStatus("status") == "4"//Cancelado
			lCancelado := .T.
		EndIF
	EndDo

Return

/*/{Protheus.doc} aguardaAglutinacao
Aguarda o término da exportação da HWG
@author marcelo.neumann
@since 30/11/2020
@version 1.0
@param oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD aguardaAglutinacao(oDominio) CLASS MrpDominio_Saida
	Local lCancelado   := .F.
	Local lConcluiu    := .F.
	Local lRetAux      := .F.
	Local nIndAux      := 1
	Local nMaximo      := 0
	Local oAglutinacao := oDominio:oAglutina:oAglutinacao
	Local oStatus      := oDominio:oLogs:oStatus

	//Aguarda Término Exportação do Rastreio da Aglutinação
	While !lCancelado .AND. oAglutinacao:getflag("nDelegacoes_Rastreio") == Nil
		Sleep(50)
		If oStatus:getStatus("status") == "4"//Cancelado
			lCancelado := .T.
		EndIF
	EndDo

	nMaximo   := oAglutinacao:getflag("nDelegacoes_Rastreio")
	lConcluiu := .F.

	While !lCancelado .AND. !lConcluiu
		lConcluiu := .T.

		For nIndAux := 1 to nMaximo
			lRetAux := oAglutinacao:getflag("lResultT" + cValToChar(nIndAux))
			If lRetAux == Nil .Or. !lRetAux
				lConcluiu := .F.
				Exit
			EndIf
		Next nIndAux

		Sleep(50)

		If oStatus:getStatus("status") == "4"//Cancelado
			lCancelado := .T.
		EndIF
	EndDo

Return

/*/{Protheus.doc} aguardaEntradas
Aguarda término da exportação da SME
@author marcelo.neumann
@since 30/11/2020
@param oDominio, objeto, objeto da camada de dominio
@return Nil
/*/
METHOD aguardaEntradas(oDominio) CLASS MrpDominio_Saida
	Local lCancelado   := .F.
	Local lConcluiu    := .F.
	Local oRastreioEnt := oDominio:oDados:oRastreioEntradas
	Local oStatus      := oDominio:oLogs:oStatus

	If oDominio:oDados:oParametros['lRastreiaEntradas']
		//Aguarda Término da Exportação do Rastreio das Demandas
		While !lCancelado .AND. oRastreioEnt:getflag("lExportacaoConcluida") == Nil
			Sleep(50)
			If oStatus:getStatus("status") == "4"//Cancelado
				lCancelado := .T.
			EndIF
		EndDo

		lConcluiu := .F.

		While !lCancelado .AND. !lConcluiu
			lConcluiu := oRastreioEnt:getflag("lExportacaoConcluida")
			Sleep(50)
			If oStatus:getStatus("status") == "4"//Cancelado
				lCancelado := .T.
			EndIF
		EndDo
	EndIf

Return

/*/{Protheus.doc} getNivel
Recupera o nível do produto

@type  Static Function
@author lucas.franca
@since 16/11/2020
@version P12
@param 01 cChaveProd, Character, Chave do produto
@param 02 oCachePrd , Object   , JsonObject utilizado como cache das informações de nível do produto
@param 03 oDados    , Object   , Instância de dados do MRP
@param 04 dData     , Date     , Data da matriz para considerar o nível
@param 05 cIdOpc    , Character, ID de opcionais do produto
@return cNivel, Character, Nível do produto
/*/
Static Function getNivel(cChaveProd, oCachePrd, oDados, dData, cIdOpc)
	Local aAreaPrd := {}
	Local cChave   := ""
	Local cNivel   := oCachePrd[cChaveProd]
	Local lNiv99   := .F.
	Local lAtual   := .F.
	Local lError   := .F.

	If cNivel == Nil
		lAtual := oDados:oProdutos:cCurrentKey != Nil .And. oDados:oProdutos:cCurrentKey == cChaveProd
		If !lAtual
			aAreaPrd := oDados:retornaArea("PRD")
		EndIf

		cNivel := oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_NIVEST", @lError, lAtual)
		If lError .Or. Empty(cNivel)
			cNivel := "99"
		EndIf
		oCachePrd[cChaveProd] := cNivel

		If !lAtual
			oDados:setaArea(aAreaPRD)
			aSize(aAreaPRD, 0)
		EndIf
	EndIf

	If cNivel <> "99"
		cChave := "PRD_NIV_99_"
		cChave += DtoS(dData) + cChaveProd + Iif(!Empty(cIdOpc),"|"+cIdOpc,"")
		lError := .F.
		lNiv99 := oDados:oMatriz:getFlag(cChave, @lError, .F.)
		If !lError .And. lNiv99
			//Produto que possui estrutura, mas na data da matriz não possui nenhum componente válido.
			//Considera que o nível do produto é 99.
			cNivel := "99"
		EndIf
	EndIf
Return cNivel

/*/{Protheus.doc} getLocalPrd
Recupera o local padrão do produto

@type  Static Function
@author ricardo.prandi
@since 09/02/2021
@version P12
@param 01 cChaveProd, Character, Chave do produto
@param 02 oCachePrd , Object   , JsonObject utilizado como cache das informações do local do produto
@param 03 oDados    , Object   , Instância de dados do MRP
@return cLocal, Character, Local do produto
/*/
Static Function getLocalPrd(cChaveProd, oCachePrd, oDados)
	Local aAreaPrd := {}
	Local cLocal   := oCachePrd[cChaveProd]
	Local lAtual   := .F.
	Local lError   := .F.

	If cLocal == Nil
		lAtual := oDados:oProdutos:cCurrentKey != Nil .And. oDados:oProdutos:cCurrentKey == cChaveProd
		If !lAtual
			aAreaPrd := oDados:retornaArea("PRD")
		EndIf

		cLocal := oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_LOCPAD", @lError, lAtual)
		If lError .Or. Empty(cLocal)
			cLocal := "01"
		EndIf
		oCachePrd[cChaveProd] := cLocal

		If !lAtual
			oDados:setaArea(aAreaPRD)
			aSize(aAreaPRD, 0)
		EndIf
	EndIf
Return cLocal

/*/{Protheus.doc} MrpExpDocs
Exporta os documentos utilizados no cálculo do MRP - tabela SMV (entradas/saídas)

@type  Function
@author lucas.franca
@since 07/12/2021
@version P12
@param 01 cTicket, Character, Número do ticket do MRP
@return Nil
/*/
Function MrpExpDocs(cTicket)

	Local aTabelas   := {}
	Local aDadosTab  := {}
	Local aSMV       := {}
	Local aLenFields := {}
	Local cChave     := "DOCMRP_TABELAS"
	Local cCodFil    := ""
	Local cCols      := ""
	Local lError     := .F.
	Local lUsaME     := .F.
	Local nIndTab    := 0
	Local nTotTab    := 0
	Local nIndReg    := 0
	Local nTotReg    := 0
	Local nTentativa := 0
	Local nTempoIni  := MicroSeconds()
	Local nTotal     := 0
	Local oDados     := Nil
	Local oLogs      := Nil
	Local oStatus    := Nil

	PrepStatics(cTicket)

	oDados    := soDominio:oDados
	oLogs     := soDominio:oLogs
	oStatus   := soDominio:oLogs:oStatus

	oStatus:preparaAmbiente(oDados)

	oLogs:log("[SMV] Inicio de exportacao de resultados. " + Time(), "32")

	If FWAliasInDic("SMV", .F.)

		lUsaME  := soDominio:oMultiEmp:utilizaMultiEmpresa()
		cCodFil := xFilial("SMV")
		cCols   := "MV_FILIAL,MV_TICKET,MV_PRODUT,MV_IDOPC,MV_DATAMRP,MV_DOCUM,MV_TIPDOC,MV_TIPREG,MV_TABELA,MV_QUANT"

		//Busca o tamanho dos campos CHAR para o PadR
		aAdd(aLenFields, FWSizeFilial())
		aAdd(aLenFields, GetSx3Cache("MV_TICKET","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("MV_PRODUT","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("MV_IDOPC" ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("MV_DOCUM" ,"X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("MV_TIPDOC","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("MV_TIPREG","X3_TAMANHO"))
		aAdd(aLenFields, GetSx3Cache("MV_TABELA","X3_TAMANHO"))

		//A lista de "TABELAS" e seus dados são gravados no método MrpDados_CargaMemoria:registraDocumentos().
		//Recupera as tabelas disponíveis para geração.
		aTabelas := oDados:oMatriz:getItemAList(cChave, "TABELAS", @lError, .F.)
		If lError
			aTabelas := {}
		Else
			//Limpa a global de listas, pois não será mais utilizada.
			oDados:oMatriz:cleanAList(cChave)
		EndIf

	EndIf

	//Para cada tabela, busca os dados e grava na tabela SMV.
	nTotTab := Len(aTabelas)
	For nIndTab := 1 To nTotTab

		cChave    := "DOCMRP_" + aTabelas[nIndTab]
		lError    := .F.
		aDadosTab := oDados:oMatriz:getItemAList(cChave, aTabelas[nIndTab], @lError, .F.)
		If lError
			aDadosTab := {}
		Else
			//Limpa a global de tabelas, pois não será mais utilizada.
			oDados:oMatriz:cleanAList(cChave)
		EndIf

		nTotReg := Len(aDadosTab)
		nTotal  += nTotReg
		//Trata os dados para gravar na SMV
		For nIndReg := 1 To nTotReg
			If lUsaME
				cCodFil := aDadosTab[nIndReg][1]
			EndIf
			aAdd(aSMV, {PadR(cCodFil              , aLenFields[1]),; //MV_FILIAL
			            PadR(cTicket              , aLenFields[2]),; //MV_TICKET
			            PadR(aDadosTab[nIndReg][2], aLenFields[3]),; //MV_PRODUT
			            PadR(aDadosTab[nIndReg][3], aLenFields[4]),; //MV_IDOPC
			            aDadosTab[nIndReg][4]                     ,; //MV_DATAMRP
			            PadR(aDadosTab[nIndReg][5], aLenFields[5]),; //MV_DOCUM
			            PadR(aDadosTab[nIndReg][6], aLenFields[6]),; //MV_TIPDOC
			            PadR(aDadosTab[nIndReg][7], aLenFields[7]),; //MV_TIPREG
			            PadR(aDadosTab[nIndReg][8], aLenFields[8]),; //MV_TABELA
			            aDadosTab[nIndReg][9]                     }) //MV_QUANT

			//Executa a inclusão a cada 1000 registros ou no fim de cada tabela.
			If nIndReg == nTotReg .Or. Mod(nIndReg, 1000) == 0
				nTentativa := 0
				//Grava resultados no banco de dados
				While nTentativa < 10
					If ( TCDBInsert(RetSqlName("SMV"), cCols, aSMV ) ) < 0
						LogMsg('MRPDOMINIO_SAIDA', 14, 4, 1, '', '', tcSQLError())
						Sleep(500)
						nTentativa++
					Else
						Exit
					EndIf
				EndDo
				If nTentativa == 10
					varInfo("SMV aSMV - ", aSMV)
					UserException(tcSQLError())
				EndIf
				aSize(aSMV, 0)
			EndIf

		Next nIndReg
		aSize(aDadosTab, 0)

	Next nIndTab

	//Grava flag de conclusão global da gravação da SMV
	oDados:oMatriz:setFlag("TERMINO_GRAVACAO_SMV", "S")

	oLogs:log(STR0178 + cValToChar(MicroSeconds() - nTempoIni), "CM") //"Tempo de gravação SMV: "
	oLogs:log(STR0179 + cValToChar(nTotal)                    , "CM") //"Total de registros gravados na SMV: "
	oLogs:log("[SMV] Termino de exportacao de resultados. " + Time(), "32")

	aSize(aTabelas  , 0)
	aSize(aLenFields, 0)

Return

/*/{Protheus.doc} gravaDados
Grava os dados com a função TcDbInsert, separando os dados em blocos de 1000 registros

@type  Static Function
@author lucas.franca
@since 24/02/2022
@version P12
@param 01 cTabela, Character, Nome da tabela (RetSqlName()) para inclusão dos dados
@param 02 cCols  , Character, Colunas para inclusão dos dados
@param 03 aDados , Array    , Array com os dados para inclusão
@return Nil
/*/
Static Function gravaDados(cTabela, cCols, aDados)
	Local aDadoInc   := {}
	Local nInicio    := 0
	Local nFim       := 0
	Local nIndex     := 1
	Local nTotInc    := 0
	Local nTotal     := Len(aDados)
	Local nTentativa := 1

	//Enquanto existirem dados para incluir, repete o processo limitando cada insersão ao número de registros definido em QTD_LINHAS_INCLUI
	While nTotInc < nTotal .And. nTentativa < 10
		nTentativa := 1

		If nTotal <= QTD_LINHAS_INCLUI
			//Se o total de registros é menor ou igual que QTD_LINHAS_INCLUI, insere todos os dados de uma única vez
			aDadoInc := aDados
			nTotInc  := nTotal
		Else
			//Se o total de registros é maior que QTD_LINHAS_INCLUI, irá separar os dados e incluir em blocos com a qtd de registros definido em QTD_LINHAS_INCLUI
			nInicio := nTotInc + 1
			nFim    += QTD_LINHAS_INCLUI
			//Caso a soma de QTD_LINHAS_INCLUI ultrapasse o tamanho total de dados, vai percorrer até o nTotal.
			nFim    := Min(nFim, nTotal)

			For nIndex := nInicio To nFim
				aAdd(aDadoInc, aDados[nIndex])
				aDados[nIndex] := {}
				//Incrementa o nTotInc para interromper o WHILE quando finalizar a inclusão de todos os dados
				nTotInc++
			Next nIndex
		EndIf

		//Insere os dados
		While nTentativa < 10
			If ( TCDBInsert(cTabela, cCols, aDadoInc ) ) < 0
				LogMsg('MRPDOMINIO_SAIDA', 14, 4, 1, '', '', tcSQLError())
				Sleep(500)
				nTentativa++
			Else
				Exit
			EndIf
		EndDo
		If nTentativa == 10
			varInfo( cTabela + "_DADOS:", aDadoInc)
			UserException(tcSQLError())
		EndIf
		aSize(aDadoInc, 0)
	End
	aSize(aDados, 0)

Return Nil
