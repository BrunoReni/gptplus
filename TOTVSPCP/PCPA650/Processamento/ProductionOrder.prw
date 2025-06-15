#INCLUDE "TOTVS.CH"
#INCLUDE "PRODUCTIONORDER.CH"

#DEFINE POS_STRUCT_CAMPO   1
#DEFINE POS_STRUCT_TIPO    2
#DEFINE POS_STRUCT_TAMANHO 3
#DEFINE POS_STRUCT_DECIMAL 4

#DEFINE POS_X3_CAMPO    1
#DEFINE POS_X3_TIPO     2
#DEFINE POS_X3_TAMANHO  3
#DEFINE POS_X3_DECIMAL  4
#DEFINE POS_X3_OBRIGAT  5
#DEFINE POS_X3_RELACAO  6
#DEFINE POS_X3_VALID    7
#DEFINE POS_X3_PROPRI   8
#DEFINE AFIELDS_TAMANHO 8

#DEFINE RETURN_POS_STATUS     1
#DEFINE RETURN_POS_ERROR      2
#DEFINE RETURN_POS_ERROR_CODE 1
#DEFINE RETURN_POS_ERROR_MSG  2
#DEFINE RETURN_POS_JSON       3

/*/{Protheus.doc} ProductionOrder
Classe com as regras de neg�cio para manipula��o da ordem de produ��o (SC2)

@author lucas.franca
@since 12/11/2021
@version P12
/*/
Class ProductionOrder FROM LongNameClass
	
	DATA aFields        AS Array
	DATA aReturn        AS Array
	DATA cSacramenta    AS Character
	DATA lPossuiC2OP    AS Logic
	DATA lPCPRevAtu     AS Logic
	DATA nTamFil        AS Numeric
	DATA nTamNum        AS Numeric
	DATA nTamItem       AS Numeric
	DATA nTamSequen     AS Numeric
	DATA nTamItemGrd    AS Numeric
	DATA nTamProduto    AS Numeric
	DATA oFieldNoAlter  AS Object
	DATA oFieldPosition AS Object
	
	//M�todo construtor da classe
	Method New(lLoadFlds) Constructor
	Method Destroy()

	//M�todos
	Method ajustaInicializadoresPadrao()
	Method alteraOP(cJson)
	Method atribuiInicializadoresPadrao(oJson)
	Method atualizaSacramento(oJson)
	Method carregaFields()
	Method carregaNoAlter()
	Method chaveSC2(oJson, lRetFil)
	Method chaveValida(oJson)
	Method criaSB2(cProduto, cLocal)
	Method excluiOP(cJson)
	Method getJson(cJson)
	Method incluiOP(cJson)
	Method manipulaSC2(oJson, cOperacao)
	Method lastHelpMessage(cDefault)
	Method msgErrorBlock(oError)
	Method operacaoValida()
	Method preparaRetornoSucesso(oJson)
	Method SB1Posiciona(oJson)
	Method SC2Posiciona(oJson, lAddErr, lUsaRecno)
	Method setError(nCode, cMessage)
	Method validaAlteracaoCampos(oJson)
	Method validaCamposObrigatorios(oJson, lAltera)
	Method validaConteudoCampos(oJson, cOperacao)
	Method validaDados(oJson, cOperacao)
	Method validaDicionarioCamposSC2(oJson)
	Method validaEntrega(oJson, cOperacao)
	Method validaInicio(oJson, cOperacao)
	Method validaLocal(oJson, cOperacao)
	Method validaPedidoOp(cNumOp)
	Method validaProduto(oJson)
	Method validaQuant(oJson)
	Method validaQIP(oJson)
	Method validaStatus(oJson, cOperacao)
	Method validaUsuario(oJson, cOperacao)
	Method validaCCusto(oJson, cOperacao)
	Method validaItemContabil(oJson)
	Method validaClasseValor(oJson)

	Static Method getDataInicio(dEntrega, cProduto, cRoteiro)

EndClass

/*/{Protheus.doc} New
M�todo construtor da classe.

@author lucas.franca
@since 12/11/2021
@version P12
@param 01 lLoadFlds , Logical, Determina se inicializa o array aFields
@return Self, Object, Inst�ncia da classe ProductionOrder
/*/
Method New(lLoadFlds) Class ProductionOrder

	Default lLoadFlds := .T.
	
	Self:aReturn        := {.T., {0, ""}, ""}
	Self:cSacramenta    := ""
	Self:lPossuiC2OP    := .F.
	Self:lPCPRevAtu	    := SuperGetMv("MV_REVFIL",.F.,.F.)
	Self:nTamFil        := FwSizeFilial()                         
	Self:nTamNum        := GetSX3Cache("C2_NUM"    , "X3_TAMANHO")
	Self:nTamItem       := GetSX3Cache("C2_ITEM"   , "X3_TAMANHO")
	Self:nTamSequen     := GetSX3Cache("C2_SEQUEN" , "X3_TAMANHO")
	Self:nTamItemGrd    := GetSX3Cache("C2_ITEMGRD", "X3_TAMANHO")
	Self:nTamProduto    := GetSX3Cache("C2_PRODUTO", "X3_TAMANHO")
	Self:oFieldPosition := JsonObject():New()

	If lLoadFlds
		Self:carregaFields()
	EndIf

Return Self

/*/{Protheus.doc} Destroy
M�todo utilizado para limpar as informa��es do objeto.

@author lucas.franca
@since 12/11/2021
@version P12
@return Nil
/*/
Method Destroy() Class ProductionOrder
	
	FwFreeArray(Self:aFields)
	FwFreeArray(Self:aReturn)
	FreeObj(Self:oFieldPosition)
	
	If Self:oFieldNoAlter != Nil 
		FreeObj(Self:oFieldNoAlter)
	EndIf

Return Nil

/*/{Protheus.doc} ajustaInicializadoresPadrao
Ajusta Inicializadores Padr�o

@author brunno.costa
@since 25/10/2021
@version P12
@return Nil
/*/
Method ajustaInicializadoresPadrao() Class ProductionOrder
	Local aInicPad := {{"C2_BATROT" , "'ProductionOrderAPI'"               },;
					   {"C2_CC"     , "SB1->B1_CC"                         },;
					   {"C2_SEGUM"  , "SB1->B1_SEGUM"                      },;
					   {"C2_UM"     , "SB1->B1_UM"                         },;
					   {"C2_BLQAPON", "'2'"                                },;
					   {"C2_GRADE"  , "' '"                                },;
					   {"C2_ITEMPV" , "' '"                                },;
					   {"C2_PEDIDO" , "' '"                                },;
					   {"C2_BATORCA", "'N'"                                },;
					   {"C2_PRIOR"  , "'500'"                              },;
					   {"C2_DIASOCI", "SuperGetMV('MV_DIASOCI',.F.,99)"    },;
					   {"C2_AGLUT"  , "'N'"                                },;
					   {"C2_EMISSAO", "Date()"                             },;
					   {"C2_LOCAL"  , "RetFldProd(SB1->B1_COD,'B1_LOCPAD')"},;
					   {"C2_ROTEIRO", "Self:validaQIP(oJson)"              },;
					   {"C2_QTSEGUM", "Iif(oJson:HasProperty('C2_QUANT') .And. oJson['C2_QUANT'] != 0, ConvUm(SB1->B1_COD, oJson['C2_QUANT'], Iif(Empty(oJson['C2_QTSEGUM']),0,oJson['C2_QTSEGUM']), 2), 0)"},;
					   {"C2_REVISAO", "Iif(Self:lPCPRevAtu, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )"},;
					   {"C2_FILIAL" , "xFilial('SC2')"},;
					   {"C2_NUM"    , "GetNumSC2(.T.)"},;
					   {"C2_ITEM"   , "StrZero(1, Self:nTamItem)"},;
					   {"C2_SEQUEN" , "StrZero(1, Self:nTamSequen)"},;
					   {"C2_BATUSR" , "RetCodUsr()"} }
	Local cCampo   := ""
	Local nCampo   := 0
	Local nCampos  := Len(aInicPad)
	Local nPosicao := 0

	For nCampo := 1 to nCampos
		cCampo   := aInicPad[nCampo][1]
		nPosicao := Self:oFieldPosition[AllTrim(cCampo)]
		If nPosicao > 0 .And. Empty(Self:aFields[nPosicao][POS_X3_RELACAO])
			Self:aFields[nPosicao][POS_X3_RELACAO] := aInicPad[nCampo][2]
		EndIf
	Next nCampo
	
	aSize(aInicPad, 0)

Return

/*/{Protheus.doc} alteraOP
M�todo para altera��o de Ordem de Produ��o

@param 01, cJson, Character, String JSON recebida na requisi��o
@author douglas.heydt
@since 18/10/2021
@version P12
@return - aReturn, array:
          aReturn[1]    Retorno se a inser��o foi executada com sucesso
          aReturn[2][1] C�digo de erro HTTP
          aReturn[2][2] Mensagem de erro
          aReturn[3]    Retorno em JSON
/*/
Method alteraOP(cJson) Class ProductionOrder
	Local bErrorBlck := Nil
	Local cTpOpOri   := ""
	Local oJson      := Self:getJson(cJson)

	//Faz a carga dos campos que n�o podem ser modificados.
	Self:carregaNoAlter()

	If Self:operacaoValida()
		Self:validaDados(oJson, "A")
	EndIf

	If Self:operacaoValida()
		
		cTpOpOri := SC2->C2_TPOP

		bErrorBlck := ErrorBlock({|oError| ProdOrdErB(Self, 400, STR0006, oError) }) //"Erro durante a atualiza��o da ordem de produ��o."

		Begin Sequence

			//Processa a exclus�o
			Begin Transaction

				Self:manipulaSC2(oJson, "A")
				Self:atualizaSacramento(oJson)

				//Mudou o tipo de OP (Prevista/Firme). Atualiza a tabela de estoque.
				If cTpOpOri != SC2->C2_TPOP
					//Remove a quantidade de saldo do tipo de origem
					Self:criaSB2(SC2->C2_PRODUTO, SC2->C2_LOCAL)
					GravaB2Pre("-", SC2->C2_QUANT, cTpOpOri, SC2->C2_QTSEGUM)
					
					//Adiciona a quantidade de saldo do tipo de destino
					GravaB2Pre("+", SC2->C2_QUANT, SC2->C2_TPOP, SC2->C2_QTSEGUM)

				EndIf
				
			End Transaction

		End Sequence
		ErrorBlock(bErrorBlck)
	EndIf
	
	If Self:operacaoValida()
		Self:preparaRetornoSucesso(oJson)
	EndIf

	FwFreeArray(Self:aFields)
	FreeObj(oJson)

Return aClone(Self:aReturn)

/*/{Protheus.doc} atribuiInicializadoresPadrao
Atribui Inicializadores Padr�es aos Campos Respectivos N�o Preenchidos

@author brunno.costa
@since 18/10/2021
@version P12
@param 01, oJson, JsonObject, retorna por refer�ncia objeto JSON com os dados recebidos no oWsRestFul
@return Nil
/*/
Method atribuiInicializadoresPadrao(oJson) Class ProductionOrder
	
	Local bErrorBlck := Nil
	Local cCampo     := ""
	Local cIniPadrao := ""
	Local cTipo      := ""
	Local nCampos    := Len(Self:aFields)
	Local nInd       := 0

	Self:ajustaInicializadoresPadrao()
	Self:SB1Posiciona(oJson)

	bErrorBlck := ErrorBlock({|oError| Self:setError(400, I18N(STR0001, {RTrim(cCampo)}) + Self:msgErrorBlock(oError)) }) //"Erro na inicializa��o padr�o do campo '#1[CAMPO]#':"
	Begin Sequence

		For nInd := 1 to nCampos
			
			If !Self:operacaoValida()
				Exit
			EndIf

			cCampo     := Self:aFields[nInd][POS_X3_CAMPO]
			cIniPadrao := Self:aFields[nInd][POS_X3_RELACAO]

			If Empty(oJson[cCampo]);      //N�o est� Preenchido no oJson
				.And. !Empty(cIniPadrao)  //Possui Inicializador Padrao


				cTipo := AllTrim(Self:aFields[nInd][POS_X3_TIPO])
				If cTipo $ '|C|M|'
					oJson[cCampo] := &cIniPadrao

				ElseIf cTipo == 'N'
					If ValType(oJson[cCampo]) != "N"
						oJson[cCampo] := &cIniPadrao
					EndIf

				ElseIf cTipo == 'D'
					oJson[cCampo] := &cIniPadrao

				ElseIf cTipo == 'L'
					cTipo := ValType(oJson[cCampo])
					If cTipo != "L"
						If cTipo == "C" .And. AllTrim(oJson[cCampo]) == 'true'
							oJson[cCampo] := .T.
						ElseIf cTipo == "C" .And. AllTrim(oJson[cCampo]) == 'false'
							oJson[cCampo] := .F.
						Else
							oJson[cCampo] := &cIniPadrao
						EndIf
					EndIf

				EndIf
			EndIf
		Next nInd
	End Sequence
	ErrorBlock(bErrorBlck)

Return

/*/{Protheus.doc} atualizaSacramento
Faz as atualiza��es necess�rias para sacramentar/dessacramentar a ordem de produ��o.

@author lucas.franca
@since 18/02/2022
@version P12
@param oJson, JsonObject, JSON com os dados da ordem de produ��o.
@return Nil
/*/
Method atualizaSacramento(oJson) Class ProductionOrder

	Local aAreaC2    := {}
	Local cChave     := ""
	Local cEmp690    := Alltrim(STR(a690FilNum(FwCodFil())))
	Local cNameCarga := "CARGA"+If(Empty(cEmp690),cNumEmp,cEmp690)//Nome do arquivo de Carga
	Local cNum       := oJson["C2_NUM"   ]
	Local cItem      := oJson["C2_ITEM"  ]
	Local cSeq       := oJson["C2_SEQUEN"]

	If Self:cSacramenta $ "S|N" .And. OpenSemSh8()

		aAreaC2 := SC2->(GetArea())

		If !TCCanOpen(cNameCarga+"OPE")
			A690CheckSC2(.F.)
		Else
			dbUseArea(.T.,"TOPCONN",cNameCarga+"OPE","CARGA",.F.,.F.)
			dbSetIndex(cNameCarga+"OPE"+"1")
			dbSetIndex(cNameCarga+"OPE"+"2")
			dbSetIndex(cNameCarga+"OPE"+"3")
			dbSetIndex(cNameCarga+"OPE"+"4")
			dbSetIndex(cNameCarga+"OPE"+"5")
			dbSetIndex(cNameCarga+"OPE"+"6")
			dbGotop()
		EndIf

		If TCCanOpen(cNameCarga+"FER")
			dbUseArea(.T.,"TOPCONN",cNameCarga+"FER","FER",.F.,.F.)
			dbSetIndex(cNameCarga+"FER1")
			dbGotop()
		EndIf

		SHD->(dbSetOrder(1))
		SHD->(dbSeek(xFilial("SHD")+cNum+cItem+cSeq))
		While !SHD->(Eof()) .And. Substr(SHD->HD_OP,1,8) == cNum+cItem
			RecLock("SHD",.F.,.T.)
			SHD->(dbDelete())
			SHD->(MsUnLock())
			SHD->(dbSkip())
		End

		SHE->(dbSeek(xFilial("SHE")+cNum+cItem+cSeq))
		While SHE->(!Eof()) .And. Substr(SHE->HE_OP,1,8) == cNum+cItem

			If Select("FER") > 0
				RecLock("FER",.T.)
				FER->HE_FILIAL  := SHE->HE_FILIAL
				FER->HE_PRODUTO := SHE->HE_PRODUTO
				FER->HE_CODIGO  := SHE->HE_CODIGO
				FER->HE_OPERAC  := SHE->HE_OPERAC
				FER->HE_FERRAM  := SHE->HE_FERRAM
				FER->HE_DTINI   := SHE->HE_DTINI
				FER->HE_DTFIM   := SHE->HE_DTFIM
				FER->HE_HRINI   := SHE->HE_HRINI
				FER->HE_HRFIM   := SHE->HE_HRFIM
				FER->HE_OP      := SHE->HE_OP
				FER->(MsUnLock())
			EndIf

			RecLock("SHE",.F.,.T.)
			SHE->(dbDelete())
			SHE->(MsUnLock())
			SHE->(dbSkip())
		End

		If Self:cSacramenta == "S"

			SH8->(dbSetOrder(1))
			SH8->(dbSeek(xFilial("SH8")+cNum+cItem+cSeq))
			While SH8->(!Eof()) .And. Substr(SH8->H8_OP,1,8) == cNum+cItem
				If SH8->H8_OP != SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
					If !SC2->(dbSeek(oJson["C2_FILIAL"]+SH8->H8_OP))
						Exit
					EndIf
				EndIf

				RecLock("SHD",.T.)
				SHD->HD_FILIAL  := xFilial("SHD")
				SHD->HD_OP      := SH8->H8_OP
				SHD->HD_OPER    := SH8->H8_OPER
				SHD->HD_RECURSO := SH8->H8_RECURSO
				SHD->HD_FERRAM  := SH8->H8_FERRAM
				SHD->HD_HRINI   := SH8->H8_HRINI
				SHD->HD_DTINI   := SH8->H8_DTINI
				SHD->HD_HRFIM   := SH8->H8_HRFIM
				SHD->HD_DTFIM   := SH8->H8_DTFIM
				SHD->HD_DTIDEAL := SH8->H8_DTIDEAL
				SHD->HD_HRIDEAL := SH8->H8_HRIDEAL
				SHD->HD_BITINI  := SH8->H8_BITINI
				SHD->HD_BITFIM  := SH8->H8_BITFIM
				SHD->HD_SEQPAI  := SH8->H8_SEQPAI
				SHD->HD_CTRAB   := SH8->H8_CTRAB
				SHD->HD_USO     := SH8->H8_USO
				SHD->HD_QUANT   := SH8->H8_QUANT
				SHD->HD_DESDOBR := SH8->H8_DESDOBR
				SHD->HD_BITUSO  := SH8->H8_BITUSO
				SHD->HD_ROTEIRO := SH8->H8_ROTEIRO
				SHD->HD_DATRF   := SC2->C2_DATRF
				SHD->(MsUnLock())

				If Select("FER") > 0
					cChave := xFilial("SHE")+SH8->H8_OP
					FER->(dbSetOrder(1))
					FER->(dbSeek(cChave))
					While FER->(!Eof()) .And. cChave == FER->(HE_FILIAL+HE_OP)
						RecLock("SHE",.T.)
							SHE->HE_FILIAL  := xFilial("SHE")
							SHE->HE_PRODUTO := FER->HE_PRODUTO
							SHE->HE_CODIGO  := FER->HE_CODIGO
							SHE->HE_OPERAC  := FER->HE_OPERAC
							SHE->HE_FERRAM  := FER->HE_FERRAM
							SHE->HE_DTINI   := FER->HE_DTINI
							SHE->HE_DTFIM   := FER->HE_DTFIM
							SHE->HE_HRINI   := FER->HE_HRINI
							SHE->HE_HRFIM   := FER->HE_HRFIM
							SHE->HE_OP      := FER->HE_OP
						SHE->(MsUnLock())
						RecLock("FER",.F.)
						FER->(dbDelete())
						FER->(MsUnLock())
						FER->(dbSkip())
					End
				EndIf
				RecLock("SH8",.F.)
				SH8->H8_STATUS := "S"
				SH8->(MsUnLock())
				SH8->(dbSkip())
			End
			
			If Select("CARGA") > 0
				dbSelectArea("CARGA")
				If CARGA->(dbSeek(xFilial("SH8")))
					CARGA->(dbSetOrder(1))
					CARGA->(dbSeek(xFilial("SH8")+cNum+cItem+cSeq))
					While CARGA->(!Eof()) .And. Substr(CARGA->H8_OP,1,8) == cNum+cItem
						RecLock("CARGA",.F.)
							Replace CARGA->H8_STATUS With "S"
						MsUnLock()
						CARGA->(dbSkip())
					End
				EndIf
			EndIf
		Else
			SH8->(dbSetOrder(1))
			SH8->(dbSeek(xFilial("SH8")+cNum+cItem+cSeq))
			While SH8->(!Eof()) .And. Substr(SH8->H8_OP,1,8) == cNum+cItem
				RecLock("SH8",.F.)
				SH8->H8_STATUS := " "
				SH8->(MsUnLock())
				SH8->(dbSkip())
			End
			If Select("CARGA") > 0
				dbSelectArea("CARGA")
				CARGA->(dbSetOrder(1))
				CARGA->(dbSeek(xFilial("SH8")+cNum+cItem+cSeq))
				While CARGA->(!Eof()) .And. Substr(CARGA->H8_OP,1,8) == cNum+cItem
					RecLock("CARGA",.F.)
					CARGA->H8_STATUS := " "
					CARGA->(MsUnLock())
					CARGA->(dbSkip())
				End
			EndIf
		EndIf

		//-- Fecha/Libera Semafaro do SH8
		ClosSemSH8()
		
		If Select("CARGA") > 0
			dbSelectArea("CARGA")
			dbCloseArea()
		EndIf
		If Select("FER") > 0
			dbSelectArea("FER")
			dbCloseArea()
		EndIf

		SC2->(RestArea(aAreaC2))
		aSize(aAreaC2, 0)
	EndIf

Return

/*/{Protheus.doc} carregaFields
Carrega os campos da tabela SC2 que s�o necess�rios para o processamento.

@author lucas.franca
@since 12/11/2021
@version P12
@return Nil
/*/
Method carregaFields() Class ProductionOrder
	Local aAux       := Array(AFIELDS_TAMANHO)
	Local nIndex     := 0
	Local aStruct    := SC2->(DBStruct())

	Self:aFields       := {}
	aAux[POS_X3_VALID] := ""

	For nIndex := 1 To Len(aStruct)

		aAux[POS_X3_CAMPO  ] := aStruct[nIndex][POS_STRUCT_CAMPO]
		aAux[POS_X3_OBRIGAT] := X3OBRIGAT(aStruct[nIndex][POS_STRUCT_CAMPO])
		aAux[POS_X3_TIPO   ] := aStruct[nIndex][POS_STRUCT_TIPO]
		aAux[POS_X3_TAMANHO] := aStruct[nIndex][POS_STRUCT_TAMANHO]
		aAux[POS_X3_DECIMAL] := aStruct[nIndex][POS_STRUCT_DECIMAL]
		aAux[POS_X3_RELACAO] := GetSX3Cache(aStruct[nIndex][1],"X3_RELACAO")
		aAux[POS_X3_PROPRI]  := GetSX3Cache(aStruct[nIndex][1],"X3_PROPRI")
		
		If aAux[POS_X3_CAMPO] == "C2_OP"
			Self:lPossuiC2OP := .T.
		EndIf

		aAdd(Self:aFields, aClone(aAux))
		
		//Armazena posi��o do aFields para n�o precisar fazer aScan no aFields.
		Self:oFieldPosition[AllTrim(aAux[POS_X3_CAMPO])] := nIndex


	Next nIndex

	aSize(aAux, 0)
	aSize(aStruct, 0)
	
Return

/*/{Protheus.doc} carregaNoAlter
Carrega os campos da tabela SC2 que n�o podem ser modificados

@author lucas.franca
@since 24/11/2021
@version P12
@return Nil
/*/
Method carregaNoAlter() Class ProductionOrder

	If Self:oFieldNoAlter == Nil
		//Campos que n�o podem ser modificados
		Self:oFieldNoAlter := JsonObject():New()
		Self:oFieldNoAlter["C2_FILIAL" ] := .T.
		Self:oFieldNoAlter["C2_NUM"    ] := .T.
		Self:oFieldNoAlter["C2_ITEM"   ] := .T.
		Self:oFieldNoAlter["C2_SEQUEN" ] := .T.
		Self:oFieldNoAlter["C2_ITEMGRD"] := .T.
		Self:oFieldNoAlter["C2_PRODUTO"] := .T.
		Self:oFieldNoAlter["C2_QUANT"  ] := .T.
		Self:oFieldNoAlter["C2_QUJE"   ] := .T.
		Self:oFieldNoAlter["C2_PERDA"  ] := .T.
	EndIf

Return

/*/{Protheus.doc} chaveSC2
Retorna a chave da SC2 a partir do JSON

@author lucas.franca
@since 09/11/2021
@version P12
@param 01 oJson  , Object, Objeto Json com os dados da ordem de produ��o
@param 02 lRetFil, Logic , Define se o c�digo da filial deve ser retornada na chave da OP
@return cChave, Character, Chave da OP, composta por C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
/*/
Method chaveSC2(oJson, lRetFil) Class ProductionOrder
	Local cChave := ""

	Default lRetFil := .T.

	//Se n�o possuir alguma das informa��es da chave, inicializa com string em branco.
	If !oJson:HasProperty("C2_FILIAL")
		oJson["C2_FILIAL"] := ""
	EndIf
	If !oJson:HasProperty("C2_NUM")
		oJson["C2_NUM"] := ""
	EndIf
	If !oJson:HasProperty("C2_ITEM")
		oJson["C2_ITEM"] := ""
	EndIf
	If !oJson:HasProperty("C2_SEQUEN")
		oJson["C2_SEQUEN"] := ""
	EndIf
	If !oJson:HasProperty("C2_ITEMGRD")
		oJson["C2_ITEMGRD"] := ""
	EndIf

	//Ajusta o tamanho das informa��es
	oJson["C2_FILIAL" ] := PadR(oJson["C2_FILIAL" ], Self:nTamFil    )
	oJson["C2_NUM"    ] := PadR(oJson["C2_NUM"    ], Self:nTamNum    )
	oJson["C2_ITEM"   ] := PadR(oJson["C2_ITEM"   ], Self:nTamItem   )
	oJson["C2_SEQUEN" ] := PadR(oJson["C2_SEQUEN" ], Self:nTamSequen )
	oJson["C2_ITEMGRD"] := PadR(oJson["C2_ITEMGRD"], Self:nTamItemGrd)

	If lRetFil
		cChave := oJson["C2_FILIAL"]
	EndIf
	cChave += oJson["C2_NUM"] + oJson["C2_ITEM"] + oJson["C2_SEQUEN"] + oJson["C2_ITEMGRD"]

Return cChave

/*/{Protheus.doc} chaveValida
Verifica se os campos que definem a chave da SC2 foram recebidos no JSON.

@author lucas.franca
@since 24/11/2021
@version P12
@param oJson, Object, Objeto Json com os dados da ordem de produ��o
@return Nil
/*/
Method chaveValida(oJson) Class ProductionOrder

	If oJson["C2_NUM"   ] == Nil .Or.;
	   oJson["C2_ITEM"  ] == Nil .Or.;
	   oJson["C2_SEQUEN"] == Nil
		Self:setError(400, STR0023) //"Os campos 'C2_NUM', 'C2_ITEM' e 'C2_SEQUEN' pertencem a chave do registro de ordem de produ��o e n�o foram enviados. Envie todos os campos da chave da ordem de produ��o."
	Else
		oJson["C2_FILIAL"] := xFilial("SC2")
	EndIf

Return
/*/{Protheus.doc} criaSB2
Posiciona e Cria (quando for o caso) Registro na SB2

@type  Method
@author brunno.costa
@since 25/10/2021
@version P12
@param 01 cProduto  , Character, C�digo do produto ir� criar a SB2
@param 02 cLocal    , Character, C�digo do local
@return Nil
/*/
METHOD criaSB2(cProduto, cLocal) CLASS ProductionOrder

	Local cChavePrd := xFilial("SB2") + cProduto + cLocal

	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))

	If !SB2->(dbSeek(cChavePrd))
		CriaSB2(cProduto, cLocal)
		MsUnlock()
	EndIf

Return

/*/{Protheus.doc} excluiOP
M�todo de exclus�o da ordem de produ��o

@author lucas.franca
@since 09/11/2021
@version P12
@param cJson, Character, String JSON recebida na requisi��o
@return aReturn, array:
          aReturn[1]    Retorno se a inser��o foi executada com sucesso
          aReturn[2][1] C�digo de erro HTTP
          aReturn[2][2] Mensagem de erro
          aReturn[3]    Retorno em JSON
/*/
Method excluiOP(cJson) Class ProductionOrder
	Local bErrorBlck := Nil
	Local oJson      := Self:getJson(cJson)

	If Self:operacaoValida()
		Self:validaDados(oJson, "E")
	EndIf

	If Self:operacaoValida()
		
		bErrorBlck := ErrorBlock({|oError| ProdOrdErB(Self, 400, STR0014, oError) }) //"Erro durante a exclus�o da ordem de produ��o."

		Begin Sequence

			//Processa a exclus�o
			Begin Transaction

				//Faz a atualiza��o de estoque
				Self:criaSB2(SC2->C2_PRODUTO, SC2->C2_LOCAL)
				GravaB2Pre("-",SC2->C2_QUANT,SC2->C2_TPOP,SC2->C2_QTSEGUM)

				//Deleta o registro da SC2.
				Self:manipulaSC2(oJson, 'E')

			End Transaction

		End Sequence
		ErrorBlock(bErrorBlck)
	EndIf

Return aClone(Self:aReturn)

/*/{Protheus.doc} getDataInicio
Verifica a data inicial da OP com base no leadtime do produto.

@author lucas.franca
@since 21/02/2022
@version P12
@param 01 cEntrega, Caracter, Data de entrega da OP
@param 02 cProduto, Caracter, C�digo do produto
@param 03 nQuant  , Numeric , Quantidade da OP
@param 04 cRoteiro, Caracter, C�digo do roteiro
@return dInicio, Date, Data inicial da OP
/*/
Method getDataInicio(dEntrega, cProduto, nQuant, cRoteiro) Class ProductionOrder
	Local dInicio := dEntrega
	Local nPrazo  := 0

	cProduto := PadR(cProduto, GetSX3Cache("C2_PRODUTO", "X3_TAMANHO"))
	cRoteiro := Iif(!Empty(cRoteiro), PadR(cRoteiro, GetSX3Cache("C2_ROTEIRO", "X3_TAMANHO")), Nil)

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + cProduto))

	nPrazo := CalcPrazo(cProduto, nQuant,,, .F., dEntrega, cRoteiro)

	If !Empty(nPrazo)
		dInicio := SomaPrazo(dInicio, - nPrazo)		
	EndIf

Return dInicio

/*/{Protheus.doc} getJson
Retorna o objeto Json da requisi��o

@author lucas.franca
@since 09/11/2021
@version P12
@param 01, cJson , Character, String Json recebida na requisi��o
@return oJson, Object, JsonObject referente a string json recebida na requisi��o.
/*/
Method getJson(cJson) Class ProductionOrder
	Local cError := ""
	Local oJson  := JsonObject():New()
	
	cJson := EncodeUTF8(cJson)

	If !Empty(cJson)
		cError := oJson:fromJson(cJson)
		
		If !Empty(cError)
			Self:setError(400, STR0002 + " " + cError) //"Erro ao interpretar os par�metros recebidos."
		EndIf
	Else
		Self:setError(400, STR0003) //"Par�metros da requisi��o n�o foram enviados."
	EndIf

Return oJson 

/*/{Protheus.doc} incluiOP
M�todo para Inclus�o de Ordem de Produ��o

@author brunno.costa
@since 18/10/2021
@version P12
@param 01, cJson, Character, String JSON recebida na requisi��o
@return - aReturn, array:
          aReturn[1]    Retorno se a inser��o foi executada com sucesso
          aReturn[2][1] C�digo de erro HTTP
          aReturn[2][2] Mensagem de erro
          aReturn[3]    Retorno em JSON
/*/
Method incluiOP(cJson) Class ProductionOrder
	Local bErrorBlck := Nil
	Local oJson      := Self:getJson(cJson)
	Local oEmpenho   := Nil
	
	If Self:operacaoValida()
		Self:validaDados(oJson, "I")
	EndIf

	If Self:operacaoValida()
		
		bErrorBlck := ErrorBlock({|oError| ProdOrdErB(Self, 400, STR0005, oError) }) //"Erro durante a inclus�o da ordem de produ��o."

		Begin Sequence

			//Carrega os empenhos que devem ser inclu�dos.
			oEmpenho := Allocation():New()
			oEmpenho:cargaEstrutura(oJson["C2_PRODUTO"]       ,; //Produto
			                        oJson["C2_QUANT"  ]       ,; //Quantidade
			                        Self:chaveSC2(oJson, .F.) ,; //N�mero da OP
			                        oJson["C2_REVISAO"]       ,; //Revis�o do produto
			                        oJson["C2_DATPRI" ]       ,; //Data inicial da OP
			                        oJson["C2_ROTEIRO"]       )  //Roteiro da OP

			//Marca OP com os empenhos j� gerados.
			oJson["C2_BATCH"] := "S"
			
			//Processa a inclus�o
			Begin Transaction

				Self:manipulaSC2(oJson, "I")

				If Self:operacaoValida() //Atualiza Estoque SB2
					Self:criaSB2(SC2->C2_PRODUTO, SC2->C2_LOCAL)
					GravaB2Pre("+", SC2->C2_QUANT, SC2->C2_TPOP, SC2->C2_QTSEGUM)

					//Grava as informa��es dos empenhos
					oEmpenho:gravar(SC2->C2_TPOP)
				EndIf

			End Transaction

			PCPMETRIC("PCPA650", {{"manufatura-protheus_qtde-ops-manuais_total", 1 }}, .T.)
			
			oEmpenho:Destroy()
			FreeObj(oEmpenho)
			oEmpenho := Nil

		End Sequence
		ErrorBlock(bErrorBlck)
	EndIf

	If Self:operacaoValida()
		Self:preparaRetornoSucesso(oJson)
	EndIf

	FwFreeArray(Self:aFields)
	FreeObj(oJson)

Return aClone(Self:aReturn)

/*/{Protheus.doc} lastHelpMessage
Retorna a �ltima mensagem ativada pela fun��o Help.

@author lucas.franca
@since 09/11/2021
@version P12
@param cDefault, Character, Mensagem padr�o que ser� assumida se n�o conseguir identificar o HELP
@return cHelp, Character, Mensagem emitida pelo �ltimo HELP executado.
/*/
Method lastHelpMessage(cDefault) Class ProductionOrder

	Local aHelp := GetHelpPCP(cDefault)
	
	cHelp := aHelp[1] + Iif(Empty(aHelp[1]),"",": ") + aHelp[2] + Iif(Empty(aHelp[3]),"",CHR(10) + STR0015 + " " + aHelp[3]) //"Solu��o:"

Return cHelp

/*/{Protheus.doc} manipulaSC2
Insere ou atualiza um Registro na SC2

@author brunno.costa
@since 18/10/2021
@version P12
@param 01 oJson    , JsonObject, objeto JSON com os dados recebidos 
@param 02 cOperacao, Character , Operacao que ser� realizada:
                                 'I' - Inclus�o
                                 'A' - Altera��o
                                 'E' - Exclus�o
@return Nil
/*/
Method manipulaSC2(oJson, cOperacao) Class ProductionOrder

	Local cCampo  := ""
	Local lAddReg := cOperacao == "I"
	Local nCampos := Len(Self:aFields)
	Local nInd    := 0

	RecLock("SC2", lAddReg)

	If cOperacao == "E"
		SC2->(dbDelete())
	Else
		For nInd := 1 to nCampos	
			//Verifica se ocorreu algum erro e para o processo (ErrorBlock definido na fun��o chamadora)
			If !Self:operacaoValida()
				Exit
			EndIf
			
			cCampo := Self:aFields[nInd][POS_X3_CAMPO]

			//Verifica campos que n�o podem ser modificados
			If !lAddReg .And. Self:oFieldNoAlter:HasProperty(cCampo) .And. Self:oFieldNoAlter[cCampo]
				Loop
			EndIf

			If oJson[cCampo] != Nil
				SC2->&(cCampo) := oJson[cCampo]
			EndIf
		Next nInd

		If Self:lPossuiC2OP .And. Empty(SC2->C2_OP)
			SC2->C2_OP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
		EndIf
	EndIf
	SC2->(MsUnlock())
Return

/*/{Protheus.doc} msgErrorBlock
Fun��o para obter a mensagem de erro em exce��es (errorlog)
Retorna a mensagem de erro, e faz log completo do console.log

@author lucas.franca
@since 09/11/2021
@version P12
@param 01, oError, Object, Objeto com as propriedades do erro
@return cMessage, Character, Mensagem de erro contendo a descri��o do erro e pilha de chamada da execu��o
/*/
Method msgErrorBlock(oError) Class ProductionOrder
	Local cMessage := AllTrim(oError:Description) + CHR(10) + AllTrim(oError:ErrorStack)

	//Emite no log as informa��es do erro
	LogMsg('ProductionOrder', 14, 4, 1, '', '',;
	       oError:Description + CHR(10) + oError:ErrorStack + CHR(10) + oError:ErrorEnv)
Return cMessage 

/*/{Protheus.doc} operacaoValida()
Checa se a opera��o em execu��o continua v�lida

@author brunno.costa
@since 18/10/2021
@version P12
@return Self:aReturn[1], Logic, Identifica se a opera��o est� v�lida ou n�o
/*/
Method operacaoValida() Class ProductionOrder
Return Self:aReturn[1]

/*/{Protheus.doc} preparaRetornoSucesso
Prepara Retorno de Sucesso

@param 01, oJson, JsonObject, objeto JSON com os dados recebidos no oWsRestFul
@author brunno.costa
@since 18/10/2021
@version P12
@return Nil
/*/
Method preparaRetornoSucesso(oJson) Class ProductionOrder

	Local cCampo  := ""
	Local nCampos := Len(Self:aFields)
	Local nInd    := 0
	Local oResp   := JsonObject():New()

	For nInd := 1 to nCampos
		cCampo := Self:aFields[nInd][POS_X3_CAMPO]
		
		If AllTrim(Self:aFields[nInd][POS_X3_TIPO]) == "D"
			oResp[cCampo] := PCPConvDat(SC2->&(cCampo), 2)
		Else 
			oResp[cCampo] := SC2->&(cCampo)
		EndIf
	Next nInd
	oResp["RECNO"] := SC2->(Recno())
	
	Self:aReturn[3] := EncodeUTF8(oResp:ToJson())
	
	FreeObj(oResp)

Return

/*/{Protheus.doc} SB1Posiciona
Posiciona SB1 para o Produto Recebido no JSON

@author brunno.costa
@since 25/10/2021
@version P12
@param 01, oJson, JsonObject, retorna por refer�ncia objeto JSON com os dados recebidos no oWsRestFul
@return lRet, Logic, Indica se encontrou o produto na tabela SB1
/*/
Method SB1Posiciona(oJson) Class ProductionOrder
	Local cChave := ""
	Local lRet   := .F.

	If oJson["C2_PRODUTO"] == NIL
		oJson["C2_PRODUTO"] := Space(Self:nTamProduto)
	Else
		oJson["C2_PRODUTO"] := PadR(oJson["C2_PRODUTO"], Self:nTamProduto)
	EndIf

	cChave := xFilial("SB1") + oJson['C2_PRODUTO']

	SB1->(dbSetOrder(1))
	lRet := cChave == SB1->B1_FILIAL + SB1->B1_COD .Or. SB1->(dbSeek(xFilial("SB1") + oJson['C2_PRODUTO']))

Return lRet

/*/{Protheus.doc} SC2Posiciona
Faz o posicionamento da tabela SC2 conforme os par�metros recebidos na requisi��o

@author lucas.franca
@since 09/11/2021
@version P12
@param 01 oJson    , Object, Objeto JSON com os dados da OP
@param 02 lAddErr  , Logic , Indica se deve adicionar a mensagem de erro na classe.
@param 03 lUsaRecno, Logic , Indica se deve tentar posicionamento pelo RECNO.
@return lAchou, Logic, Identifica se encontrou o registro na tabela SC2.
/*/
Method SC2Posiciona(oJson, lAddErr, lUsaRecno) Class ProductionOrder
	Local lAchou := .F.

	//Tenta posicionar com o RECNO do registro.
	If lUsaRecno .And. oJson:HasProperty("RECNO") .And. !Empty(oJson["RECNO"])
		SC2->(dbGoTo(oJson["RECNO"]))
		
		If SC2->(Recno()) == oJson["RECNO"] .And. !SC2->(Deleted())
			If Self:chaveSC2(oJson) == SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
				lAchou := .T.
			ElseIf lAddErr
				Self:setError(400, I18N(STR0016, {RTrim(Self:chaveSC2(oJson)), oJson["RECNO"]}) ) //"RECNO da ordem de produ��o '#1[NUMOP]#' n�o coincide com o RECNO recebido na requisi��o '#2[RECNO]#'."
			EndIf
		ElseIf lAddErr
			Self:setError(400, I18N(STR0021, {oJson["RECNO"]}) ) //"RECNO '#1[RECNO]#' n�o existe na base de dados."
		EndIf
	EndIf

	//Se n�o encontrou, tenta posicionar pela chave da OP.
	If Self:operacaoValida()
		If !lAchou
			SC2->(dbSetOrder(1))
			lAchou := SC2->(dbSeek( Self:chaveSC2(oJson) ))
		EndIf

		If !lAchou .And. lAddErr
			Self:setError(400, I18N(STR0017, {RTrim(Self:chaveSC2(oJson))})) //"Ordem de produ��o '#1[NUMOP]#' n�o encontrada."
		EndIf
	EndIf
Return lAchou

/*/{Protheus.doc} setError
Define a mensagem de erro no processo da ordem de produ��o.

@author lucas.franca
@since 09/11/2021
@version P12
@param 01, nCode   , Numeric  , C�digo de erro
@param 02, cMessage, Character, Mensagem de erro
@return Nil
/*/
Method setError(nCode, cMessage) Class ProductionOrder
	Self:aReturn[RETURN_POS_STATUS]                       := .F.
	Self:aReturn[RETURN_POS_ERROR][RETURN_POS_ERROR_CODE] := nCode
	Self:aReturn[RETURN_POS_ERROR][RETURN_POS_ERROR_MSG ] := cMessage
Return

/*/{Protheus.doc} validaAlteracaoCampos
Verifica se est� sendo realizada tentativa de alterar campos que n�o podem ser alterados.
Este m�todo depende que o registro da SC2 que ser� modificado esteja posicionado.

@author lucas.franca
@since 24/11/2021
@version P12
@param 01, oJson  , JsonObject, objeto JSON com os dados recebidos no oWsRestFul
@return Nil
/*/
Method validaAlteracaoCampos(oJson) Class ProductionOrder

	Local aNames   := Self:oFieldNoAlter:GetNames()
	Local nIndex   := 0
	Local nPos     := 0
	Local nTotal   := Len(aNames)
	Local xValJson := ""
	Local xValSC2  := ""

	For nIndex := 1 To nTotal 
		If Self:oFieldNoAlter[aNames[nIndex]] .And. oJson:HasProperty(aNames[nIndex])
			
			nPos := Self:oFieldPosition[aNames[nIndex]]

			xValJson := oJson[aNames[nIndex]]
			xValSC2  := SC2->&(aNames[nIndex])

			//Se a informa��o � do tipo string, ajusta o tamanho
			If nPos > 0 .And. Self:aFields[nPos][POS_X3_TIPO] == "C"
				xValJson := PadR(xValJson, Self:aFields[nPos][POS_X3_TAMANHO])
			EndIf 

			If xValJson != xValSC2
				Self:setError(400, I18N(STR0024, {aNames[nIndex]})) //"Campo '#1[CAMPO]#' n�o pode ter seu conte�do modificado."
				Exit
			EndIf
		EndIf
	Next nIndex 

	aSize(aNames, 0)
Return

/*/{Protheus.doc} validaCamposObrigatorios
Valida Preenchimento dos Campos Obrigat�rios

@author brunno.costa
@since 18/10/2021
@version P12
@param 01, oJson  , JsonObject, objeto JSON com os dados recebidos no oWsRestFul
@param 02, lAltera, Logic     , Identifica que est� validando para a opera��o de Altera��o 
@return Nil
/*/
Method validaCamposObrigatorios(oJson, lAltera) Class ProductionOrder

	Local bErrorBlck := Nil
	Local cCampo     := ""
	Local cTipo      := ""
	Local dAux       := Nil
	Local nAux       := 0
	Local nCampos    := Len(Self:aFields)
	Local nInd       := 0

	bErrorBlck := ErrorBlock({|oError| Self:setError(400, I18N(STR0007, {RTrim(cCampo)}) + Self:msgErrorBlock(oError)) }) //"Erro no conte�do do campo obrigat�rio '#1[CAMPO]#'."
	Begin Sequence
		For nInd := 1 to nCampos
			
			If !Self:operacaoValida()
				Exit
			EndIf

			cCampo := Self:aFields[nInd][POS_X3_CAMPO]
			
			//Se est� modificando e o campo n�o foi informado, n�o precisa validar
			//pois a informa��o n�o ser� gravada na tabela.
			If lAltera .And. !oJson:HasProperty(cCampo)
				Loop
			EndIf

			cTipo := AllTrim(Self:aFields[nInd][POS_X3_TIPO])

			If Self:aFields[nInd][POS_X3_OBRIGAT] .Or. cTipo == "D"

				If cTipo $ '|C|M|'
					If Empty(oJson[cCampo])
						Self:setError(400, I18N(STR0008, {RTrim(cCampo)})) // "O campo obrigatorio '#1[CAMPO]# n�o foi preenchido."
					EndIf

				ElseIf cTipo == 'N'
					If ValType(oJson[cCampo]) != "N"
						If ValType(nAux) == "C"
							nAux := Val(oJson[cCampo])
							If ValType(nAux) == "N" .And. !Empty(oJson[cCampo])
								oJson[cCampo] := nAux
							Else
								Self:setError(400, I18N(STR0009, {RTrim(cCampo)})) //"Falha no preenchimento do campo num�rico obrigat�rio: '#1[CAMPO]#'."
							EndIf
						EndIf
					EndIf

				ElseIf cTipo == 'D'
					dAux := oJson[cCampo]
					If Empty(dAux)
						If Self:aFields[nInd][POS_X3_OBRIGAT]
							Self:setError(400, I18N(STR0010, {RTrim(cCampo)})) //"Falha no preenchimento do campo data obrigat�rio: '#1[CAMPO]#'."
						EndIf
					Else
						If ValType(dAux) != 'D'
							dAux := CTOD(dAux)
							If Empty(DtoS(dAux)) .And. Self:aFields[nInd][POS_X3_OBRIGAT]
								Self:setError(400, I18N(STR0010, {RTrim(cCampo)})) // "Falha no preenchimento do campo data obrigat�rio: '#1[CAMPO]#'." 
							Else
								oJson[cCampo] := dAux
							EndIf
						EndIf
					EndIf

				ElseIf cTipo == 'L'
					If ValType(oJson[cCampo]) != "L"
						If AllTrim(oJson[cCampo]) == 'true' .Or. AllTrim(oJson[cCampo]) == '.T.'
							oJson[cCampo] := .T.
						ElseIf AllTrim(oJson[cCampo]) == 'false' .Or. AllTrim(oJson[cCampo]) == '.F.'
							oJson[cCampo] := .F.
						Else
							Self:setError(400, I18N(STR0010, {RTrim(cCampo)})) //"Falha no preenchimento do campo l�gico obrigat�rio: '#1[CAMPO]#'." 
						EndIf
					EndIf

				EndIf
			EndIf
		Next nInd
	End Sequence
	ErrorBlock(bErrorBlck)

Return

/*/{Protheus.doc} validaConteudoCampos
Valida Conte�do dos Campos

@author brunno.costa
@since 25/10/2021
@version P12
@param 01, oJson    , JsonObject, objeto JSON com os dados recebidos no oWsRestFul
@param 02, cOperacao, Character, opera��o que est� sendo realizada
@return Nil
/*/
Method validaConteudoCampos(oJson, cOperacao) Class ProductionOrder
	Local aValid := {{"C2_QUANT"  , "Self:validaQuant(@oJson)"             },;
	                 {"C2_BATUSR" , "Self:validaUsuario(@oJson, cOperacao)"},;
	                 {"C2_PRODUTO", "Self:validaProduto(@oJson, cOperacao)"},;
	                 {"C2_STATUS" , "Self:validaStatus(@oJson, cOperacao)" },;
	                 {"C2_LOCAL"  , "Self:validaLocal(@oJson, cOperacao)"  },;
	                 {"C2_DATPRI" , "Self:validaInicio(@oJson, cOperacao)" },;
	                 {"C2_DATPRF" , "Self:validaEntrega(@oJson, cOperacao)"},;
					 {"C2_CC"     , "Self:validaCCusto(@oJson, cOperacao)"},;
					 {"C2_ITEMCTA", "Self:validaItemContabil(@oJson)"},;
					 {"C2_CLVL"   , "Self:validaClasseValor(@oJson)"}; 
					} 
	Local bErrorBlck := Nil
	Local cCampo     := ""
	Local cValidacao := ""
	Local nCampos    := Len(aValid)
	Local nIndex       := 0

	bErrorBlck := ErrorBlock({|oError| Self:setError(400, I18N(STR0046, {RTrim(cCampo)}) + Self:msgErrorBlock(oError)) }) //"Erro no conte�do do campo '#1[CAMPO]#'."
	Begin Sequence
		For nIndex := 1 to nCampos

			If !Self:operacaoValida()
				Exit
			EndIf

			cCampo     := aValid[nIndex][1]
			cValidacao := aValid[nIndex][2]

			If !Empty(cValidacao) .And. !(&cValidacao)
				//Se alguma valida��o n�o for realizada corretamente, para a execu��o.
				Exit
			EndIf
		Next nIndex
	End Sequence
	ErrorBlock(bErrorBlck)
	
	aSize(aValid, 0)

Return

/*/{Protheus.doc} validaDados
Faz valida��es dos dados da ordem de produ��o

@author lucas.franca
@since 14/02/2022
@version P12
@param 01, oJson    , JsonObject, objeto JSON com os dados recebidos no oWsRestFul
@param 02, cOperacao, Character , Opera��o realizada ('I' - Inclus�o;'A' - Altera��o;'E' - Exclus�o)
@return Nil
/*/
Method validaDados(oJson, cOperacao) Class ProductionOrder

	//Faz o posicionamento da SC2 para opera��es de altera��o e exclus�o.
	If cOperacao $ "|A|E|" .And. Self:operacaoValida()
		Self:SC2Posiciona(oJson, .T., .T.)
	EndIf

	//Valida��es que s�o realizadas somente para a opera��o de Inclus�o
	If cOperacao == "I"
		If Self:operacaoValida()
			Self:validaDicionarioCamposSC2(oJson)
		EndIf

		//Carrega inicializadores padr�o dos campos
		If Self:operacaoValida()
			Self:atribuiInicializadoresPadrao(@oJson)
		EndIf
			
		//Verifica se os campos de numera��o da ordem est�o completamente preenchidos.
		If Self:operacaoValida()                                 .And.;
			(Len(AllTrim(oJson["C2_NUM"   ])) != Self:nTamNum    .Or. ;
			Len(AllTrim(oJson["C2_ITEM"  ])) != Self:nTamItem    .Or. ;
			Len(AllTrim(oJson["C2_SEQUEN"])) != Self:nTamSequen  .Or. ;
			(!Empty(oJson["C2_ITEMGRD"]) .And. Len(AllTrim(oJson["C2_ITEMGRD"])) != Self:nTamItemGrd) )
			
			Self:setError(400, STR0025 ) //"Os campos chave da ordem de produ��o devem ser preenchidos com todos os caracteres. Verifique os campos C2_NUM, C2_ITEM, C2_SEQUEN e C2_ITEMGRD."
		EndIf

		//Valida��o de C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD j� existente.
		If Self:operacaoValida() .And. Self:SC2Posiciona(oJson, .F., .F.)
			Self:setError(400, I18N(STR0004, {RTrim(Self:chaveSC2(oJson))}) ) // "J� existe um registro com a chave �nica '#1[CHAVE]#'."  
		EndIf
	EndIf

	//Verifica se est�o sendo alterados campos que n�o podem ser modificados
	If cOperacao == "A" .And. Self:operacaoValida()
		Self:validaAlteracaoCampos(oJson)
	EndIf

	If cOperacao != "E"
		If Self:operacaoValida()
			Self:validaCamposObrigatorios(@oJson, cOperacao=="A")
		EndIf

		//Execu��o das valida��es do conte�do informado nos campos
		If Self:operacaoValida()
			Self:validaConteudoCampos(@oJson, cOperacao)
		EndIf
	EndIf

	//Se exclus�o, verifica se a OP pode ser exclu�da.
	If cOperacao == "E"
		If Self:operacaoValida()
			Self:validaPedidoOp(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		EndIf

		If Self:operacaoValida() .And. IsProdProt(SC2->C2_PRODUTO)
			Self:setError(400, STR0018) //"Produtos prot�tipos podem ser manipulados somente pelo m�dulo Desenvolvedor de Produtos (SIGADPR)."
		EndIf

		If Self:operacaoValida() .And. IntWms() .And. !WmsAvalSC2("3",,,,,SC2->(Recno()))
			Self:setError(400, Self:lastHelpMessage(STR0019)) //"Ordem de produ��o n�o pode ser exclu�da pois possui requisi��es do WMS."
		EndIf

		If Self:operacaoValida()            .And. ;
		   AllTrim(SC2->C2_ITEM  ) == 'OS'  .And. ;
		   AllTrim(SC2->C2_SEQUEN) == '001' .And. ;
		   SubStr( AllTrim( SC2->C2_BATROT ), 1, 3 ) $ 'MNT#RPC'
			Self:setError(400, STR0020) //"Ordem de produ��o n�o pode ser exclu�da pois a sua origem � do Manuten��o de Ativos (SIGAMNT). Esta ordem de produ��o somente poder� ser exclu�da pelo m�dulo Manuten��o de Ativos."
		EndIf
	EndIf

Return 

/*/{Protheus.doc} validaDicionarioCamposSC2
Valida Exist�ncia de Campos Enviados no Dicion�rio de Dados da SC2

@author brunno.costa
@since 18/10/2021
@version P12
@param 01, oJson, JsonObject, objeto JSON com os dados recebidos no oWsRestFul
@return Nil
/*/
Method validaDicionarioCamposSC2(oJson) Class ProductionOrder

	Local aNames  := oJson:GetNames()
	Local cCampo  := ""
	Local nCampos := 0
	Local nInd    := 0

	nCampos  := Len(aNames)
	For nInd := 1 to nCampos
		cCampo := AllTrim(Upper(aNames[nInd]))
		
		If Left(cCampo, 3) != "C2_";
			.Or. Empty(GetSX3Cache(cCampo, "X3_CAMPO"))

			If cCampo == "RECNO"
				Loop
			EndIf

			oJson:DelName(cCampo)
			//Self:setError(400, I18N(STR0013, {RTrim(cCampo)})) //"O campo '#1[CAMPO]#' n�o foi encontrado no dicion�rio de dados."
			Exit			
		EndIf
	Next nInd

	aSize(aNames, 0)
	
Return

/*/{Protheus.doc} validaEntrega
Valida��es referentes ao campo C2_DATPRF

@author lucas.franca
@since 07/03/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param 02, cOperacao, Character , Opera��o que est� sendo realizada.
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaEntrega(oJson, cOperacao) Class ProductionOrder
	Local lRet  := .T.

	//Verifica se a data de entrega � menor que a DATABASE. Em opera��o de Altera��o, somente valida se o campo foi modificado.
	If !Empty(oJson["C2_DATPRF"]) .And. oJson["C2_DATPRF"] < dDataBase  .And. (cOperacao == "I" .Or. (cOperacao == "A" .And. oJson["C2_DATPRF"] != SC2->C2_DATPRF))
		Self:setError(400, STR0027 ) //"Data de entrega da ordem de produ��o n�o pode ser anterior a Data Base."
		lRet := .F.
	EndIf
Return lRet 

/*/{Protheus.doc} validaInicio
Valida��es referentes ao campo C2_DATPRI

@author lucas.franca
@since 07/03/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param 02, cOperacao, Character , Opera��o que est� sendo realizada.
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaInicio(oJson, cOperacao) Class ProductionOrder
	Local dDataIni := Iif(oJson:HasProperty("C2_DATPRI"), oJson["C2_DATPRI"], Nil)
	Local dDataEnt := Iif(oJson:HasProperty("C2_DATPRF"), oJson["C2_DATPRF"], Nil)
	Local lRet     := .T.

	If cOperacao == "A" .And. (Empty(dDataIni) .Or. Empty(dDataEnt))
		dDataIni := Iif(Empty(dDataIni), SC2->C2_DATPRI, dDataIni)
		dDataEnt := Iif(Empty(dDataEnt), SC2->C2_DATPRF, dDataEnt)
	EndIf

	//Verifica se a data de in�cio da OP � maior que a data de entrega.
	If !Empty(dDataIni) .And. !Empty(dDataEnt) .And. dDataIni > dDataEnt
		Self:setError(400, STR0039 ) //"Data de in�cio da ordem de produ��o n�o pode ser maior que a data de entrega."
		lRet := .F.
	EndIf
Return lRet 

/*/{Protheus.doc} validaLocal
Valida��es referentes ao campo C2_LOCAL

@author lucas.franca
@since 07/03/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param 02, cOperacao, Character , Opera��o que est� sendo realizada.
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaLocal(oJson, cOperacao) Class ProductionOrder
	Local lRet := .T.

	//Padroniza o tamanho do local recebido
	oJson["C2_LOCAL"] := PadR(Upper(oJson["C2_LOCAL"]), Self:aFields[Self:oFieldPosition["C2_LOCAL"]][POS_X3_TAMANHO])

	//Verifica se existe na tabela NNR
	//Em opera��o de altera��o, somente valida se houve altera��o do local
	If cOperacao == "I" .Or. (cOperacao == "A" .And. oJson["C2_LOCAL"] != SC2->C2_LOCAL)
		NNR->(dbSetOrder(1))
		If !NNR->(dbSeek(xFilial("NNR") + oJson["C2_LOCAL"]))
			Self:setError(400, I18N(STR0026, {RTrim(oJson["C2_LOCAL"])}) ) // "C�digo do armaz�m '#1[ARMAZEM]#' n�o existe."
			lRet := .F.
		EndIf
	EndIf
Return lRet 

/*/{Protheus.doc} validaPedidoOp
Verifica se a ordem de produ��o est� vinculada com um pedido de venda

@author lucas.franca
@since 09/11/2021
@version P12
@param cNumOp, Character, Chave da ordem de produ��o
@return Nil
/*/
Method validaPedidoOp(cNumOp) Class ProductionOrder

	Local cAlias := GetNextAlias() 
	Local cQuery := ""

	cQuery := " SELECT 1 "
	cQuery +=   " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery +=  " WHERE SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "
	cQuery +=    " AND SC7.C7_OP      = '" + cNumOp + "' "
	cQuery +=    " AND SC7.D_E_L_E_T_ = ' '"

	If SuperGetMv("MV_DELEAE", .F., "S") == "S"
		cQuery += " AND SC7.C7_TIPO = '1' "
	Else
		cQuery += " AND SC7.C7_TIPO IN ('1','2') "
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	If ! (cAlias)->(Eof())
		Self:setError(400, I18N(STR0022, {RTrim(cNumOP)})) //"N�o � poss�vel excluir a ordem de produ��o '#1[NUMOP]#' pois existem pedidos de compra com situa��o 'Confirmado' vinculados � ordem de produ��o. Verifique a situa��o dos pedidos de compra antes de excluir a ordem de produ��o."
	EndIf
	(cAlias)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} validaProduto
Valida as informa��es referentes ao produto, e tamb�m carrega valores padr�es de acordo com o produto.

@author lucas.franca
@since 14/02/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param 02, cOperacao, Character, opera��o que est� sendo realizada
@return lRet, Logic, Indica se as valida��es do produto foram feitas com sucesso
/*/
Method validaProduto(oJson, cOperacao) Class ProductionOrder
	Local lRet := .T.

	If cOperacao == "I"
		If Self:operacaoValida() .And. !Self:SB1Posiciona(@oJson)
			Self:setError(400, I18N(STR0028, {RTrim(oJson["C2_PRODUTO"])})) //"C�digo do produto '#1[PRODUTO]#' n�o existe."
			lRet := .F.
		EndIf

		If Self:operacaoValida() .And. !MaAvalPerm(1,{oJson["C2_PRODUTO"],"MTA650",3})
			Self:setError(400, STR0029) //"Usu�rio sem permiss�o para utilizar esta rotina."
			lRet := .F.
		EndIf

		If Self:operacaoValida() .And. RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S"
			Self:setError(400, STR0030) //"N�o � permitida a inclus�o de ordens de produ��o para produtos fantasmas."
			lRet := .F.
		EndIf

		If Self:operacaoValida() .And. IsProdProt(SB1->B1_COD)
			Self:setError(400, STR0031) //"Produtos prot�tipos podem ser manipulados somente pelo m�dulo Desenvolvedor de Produtos (DPR)."
			lRet := .F.
		EndIf

		If Self:operacaoValida()
			Self:validaQIP(oJson)
			lRet := Self:operacaoValida()
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validaQuant
Valida��es referentes a quantidade da ordem de produ��o.

@author lucas.franca
@since 07/03/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaQuant(oJson) Class ProductionOrder
	Local lRet := oJson:HasProperty("C2_QUANT") .And. oJson['C2_QUANT'] > 0

	If !lRet 
		Self:setError(400, STR0040) //"Quantidade da ordem de produ��o deve ser maior que 0."
	EndIf
Return lRet 

/*/{Protheus.doc} validaQIP
Faz as valida��es do m�dulo QIP para o produto da ordem de produ��o
A tabela SB1 deve estar posicionada no produto da OP para utilizar esta fun��o.

@author lucas.franca
@since 15/02/2022
@version P12
@param oJson, JsonObject, Dados da OP recebidos na requisi��o
@return cRoteiro, Character, Retorna o roteiro padr�o do produto
/*/
Method validaQIP(oJson) Class ProductionOrder
	Local aHelp      := {}
	Local cRoteiro   := SB1->B1_OPERPAD
	Local cC2Revi    := Iif(oJson:HasProperty("C2_REVI"), oJson["C2_REVI"], "")
	Local cProdMnt   := SuperGetMV("MV_PRODMNT",.F.," ")
	Local lIntQIP    := IntQIP(SB1->B1_COD,,"T")
	Local lBLOESP    := If(SuperGetMV("MV_QBLOESP",.F.,"2") == "2",.F.,.T.)
	Local lIntQIPMAT := If(SuperGetMV("MV_QIPMAT",.F.,"N")=="N",.F.,.T.)
	Local lRet       := .T.

	If (AllTrim(cProdMnt) == AllTrim(SB1->B1_COD)) .And. (lIntQIP .or. lIntQIPMAT)
		lBLOESP := .F.
	EndIF

	If oJson:HasProperty("C2_ROTEIRO") .And. !Empty(oJson["C2_ROTEIRO"])
		cRoteiro := oJson["C2_ROTEIRO"]
		SG2->(dbSetOrder(1))
		If !SG2->(dbSeek(xFilial("SG2") + oJson["C2_PRODUTO"] + oJson["C2_ROTEIRO"]))
			Self:setError(400, I18N(STR0045, {RTrim(oJson["C2_ROTEIRO"])}) ) // "C�digo do roteiro '#1[ROTEIRO]#' n�o existe."
			lRet := .F.
		EndIf
	ElseIf lIntQIP .Or. lIntQIPMAT
		cRoteiro := A650VldRot(SB1->B1_COD, SB1->B1_OPERPAD)
	EndIf

	If lRet
		If lIntQIP
			//Verifica se o Produto possui ensaios
			If !QIPValEns(SB1->B1_COD, cC2Revi, cRoteiro) .And. lBLOESP
				aHelp := GetHelpPCP(STR0032) //"Especifica��o do produto n�o possui nenhum ensaio cadastrado."
				Self:setError(400, aHelp[1] + aHelp[2] + aHelp[3])
				aSize(aHelp, 0)
			Endif
		ElseIf lIntQIPMAT

			//Verifica se o Produto possui ensaios
			If Empty(cRoteiro) .Or. (!QIPValEns(SB1->B1_COD, cC2Revi, cRoteiro) .And. lBLOESP)
				Self:setError(400, STR0033) //"N�o existe especifica��o para este Produto/Roteiro. Necess�rio cadastrar a especifica��o do produto no m�dulo QIP."
			EndIf
		EndIf
	EndIf

Return cRoteiro

/*/{Protheus.doc} validaStatus
Faz as valida��es do status da ordem de produ��o (C2_STATUS)

@author lucas.franca
@since 17/02/2022
@version P12
@param oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param cOperacao, Character , Opera��o que est� sendo realizada.
@return lRet    , Logic     , Indica se o campo est� v�lido
/*/
Method validaStatus(oJson, cOperacao) Class ProductionOrder
	Local cStatus   := oJson["C2_STATUS"]
	Local lContinua := .T.
	Local lRet      := .T.

	Self:cSacramenta := ""

	If cOperacao == "I"
		If Self:operacaoValida() .And. cStatus == "S" .And. cOperacao == "I"
			Self:setError(400, STR0034) //"Situa��o da ordem de produ��o inv�lida. Somente ordens de produ��o processadas pelo carga m�quina podem ter sua situa��o alterada para 'Sacramentada'."
			lRet := .F.
		EndIf
		//Quando a opera��o � inclus�o, est� � a �nica valida��o necess�ria para o Status. As demais valida��es n�o precisam ser executadas.
		lContinua := .F.
	Else
		//Se n�o for uma inclus�o, posiciona da SC2.
		Self:SC2Posiciona(oJson, .F., .T.)
		If SC2->C2_STATUS == cStatus 
			//Se n�o houve mudan�a no status, n�o � necess�rio continuar as valida��es.
			lContinua := .F.
		EndIf
	EndIf

	If lContinua .And. Self:operacaoValida()
		If SC2->C2_STATUS <> "S" .And. cStatus == "S"
			If Self:operacaoValida()
				If !Empty(SC2->C2_DATRF)
					Self:setError(400, STR0035) //"N�o � poss�vel sacramentar uma ordem de produ��o j� finalizada."
					lRet := .F.

				ElseIf OpenSemSH8()

					SH8->(dbSetOrder(1))
					If SH8->(dbSeek(xFilial("SH8") + Self:chaveSC2(oJson, .F.) ))
						If Empty(SC2->C2_DATAJI) .Or. Empty(SC2->C2_DATAJF) .Or. Empty(SC2->C2_HORAJI) .Or. Empty(SC2->C2_HORAJF)
							lRet := .F.
							If A690CheckSC2()
								Self:setError(400, STR0036) //"N�o � poss�vel sacramentar esta ordem de produ��o, pois a Rotina de Atualiza��o dos Cadastros de SCs e Empenhos n�o foi executada. Para execut�-la tecle Visualizar na Rotina Carga M�quina e tecle ESC."
							Else
								Self:setError(400, STR0034) //"Situa��o da ordem de produ��o inv�lida. Somente ordens de produ��o processadas pelo carga m�quina podem ter sua situa��o alterada para 'Sacramentada'."
							EndIf
						Else
							If !A690CheckSC2()
								If A690ChkFlag(2) == 0
									Self:setError(400, STR0037) //"N�o � poss�vel sacramentar esta OP, pois a Rotina Carga M�quina foi executada (Alocar) com o par�metro 'Considera Sacramentadas?' desativado (N�o)."
									lRet := .F.
								Else
									Self:cSacramenta := "S"
								EndIf
							Else
								Self:setError(400, STR0036) //"N�o � poss�vel sacramentar esta ordem de produ��o, pois a Rotina de Atualiza��o dos Cadastros de SCs e Empenhos n�o foi executada. Para execut�-la tecle Visualizar na Rotina Carga M�quina e tecle ESC."
								lRet := .F.
							EndIf
						EndIf
					Else
						Self:setError(400, STR0034) //"Situa��o da ordem de produ��o inv�lida. Somente ordens de produ��o processadas pelo carga m�quina podem ter sua situa��o alterada para 'Sacramentada'."
						lRet := .F.
					EndIf
					
					//Libera semaforo da SH8
					ClosSemSH8()

				Else
					Self:setError(400, STR0038) //"N�o foi poss�vel obter acesso exclusivo nas informa��es do carga m�quina."
					lRet := .F.
				EndIf
			EndIf

		ElseIf SC2->C2_STATUS == "S" .And. cStatus != "S"
			Self:cSacramenta := "N"
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validaUsuario
Valida��es referentes ao campo C2_BATUSR

@author lucas.franca
@since 07/03/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param 02, cOperacao, Character , Opera��o que est� sendo realizada.
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaUsuario(oJson, cOperacao) Class ProductionOrder
	Local lRet := .T.

	If (cOperacao == "A" .And. oJson:HasProperty("C2_BATUSR") .And. Empty(oJson["C2_BATUSR"])) .Or. ;
	   (cOperacao == "I" .And. Empty(oJson["C2_BATUSR"]))
		lRet := .F.
		Self:setError(400, STR0041) //"Usu�rio para processamento batch n�o pode ser vazio."
	EndIf
Return lRet

/*/{Protheus.doc} validaCCusto
Valida��es referentes ao campo C2_CC

@author renan.roeder
@since 08/09/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@param 02, cOperacao, Character , Opera��o que est� sendo realizada.
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaCCusto(oJson, cOperacao) Class ProductionOrder
	Local lRet := .T.

	IF oJson:HasProperty("C2_CC") .And. !Empty(oJson["C2_CC"])

		//Padroniza o tamanho do centro de custo recebido
		oJson["C2_CC"] := PadR(Upper(oJson["C2_CC"]), Self:aFields[Self:oFieldPosition["C2_CC"]][POS_X3_TAMANHO])

		//Verifica se existe na tabela CTT
		//Em opera��o de altera��o, somente valida se houve altera��o do centro de custo
		If cOperacao == "I" .Or. (cOperacao == "A" .And. oJson["C2_CC"] != SC2->C2_CC)
			CTT->(dbSetOrder(1))
			If !CTT->(dbSeek(xFilial("CTT") + oJson["C2_CC"]))
				Self:setError(400, I18N(STR0042, {RTrim(oJson["C2_CC"])}) ) // "C�digo do centro de custo '#1[CCUSTO]#' n�o existe."
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validaItemContabil
Valida��es referentes ao campo C2_ITEMCTA

@author renan.roeder
@since 08/09/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaItemContabil(oJson) Class ProductionOrder
	Local lRet := .T.

	IF oJson:HasProperty("C2_ITEMCTA") .And. !Empty(oJson["C2_ITEMCTA"])
		//Padroniza o tamanho do item cont�bil recebido
		oJson["C2_ITEMCTA"] := PadR(Upper(oJson["C2_ITEMCTA"]), Self:aFields[Self:oFieldPosition["C2_ITEMCTA"]][POS_X3_TAMANHO])

		//Verifica se existe na tabela CTD
		CTD->(dbSetOrder(1))
		If !CTD->(dbSeek(xFilial("CTD") + oJson["C2_ITEMCTA"]))
			Self:setError(400, I18N(STR0043, {RTrim(oJson["C2_ITEMCTA"])}) ) // "C�digo do item cont�bil '#1[ITEMCTA]#' n�o existe."
			lRet := .F.
		EndIf

	EndIf
Return lRet

/*/{Protheus.doc} validaClasseValor
Valida��es referentes ao campo C2_CLVL

@author renan.roeder
@since 08/09/2022
@version P12
@param 01, oJson    , JsonObject, Dados da OP recebidos na requisi��o
@return lRet, Logic, Indica se as valida��es foram feitas com sucesso
/*/
Method validaClasseValor(oJson) Class ProductionOrder
	Local lRet := .T.

	IF oJson:HasProperty("C2_CLVL") .And. !Empty(oJson["C2_CLVL"])
		//Padroniza o tamanho da classe de valor recebido
		oJson["C2_CLVL"] := PadR(Upper(oJson["C2_CLVL"]), Self:aFields[Self:oFieldPosition["C2_CLVL"]][POS_X3_TAMANHO])

		//Verifica se existe na tabela CTH
		CTH->(dbSetOrder(1))
		If !CTH->(dbSeek(xFilial("CTH") + oJson["C2_CLVL"]))
			Self:setError(400, I18N(STR0044, {RTrim(oJson["C2_CLVL"])}) ) // "C�digo da classe de valor '#1[CLVL]#' n�o existe."
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} ProdOrdErB
Fun��o para avalia��o de ErrorBlock. Faz Rollback em caso de transa��o ativa, 
seta mensagem de erro na classe ProductionOrder e dispara o BREAK para finalizar a execu��o.

@type  Function
@author lucas.franca
@since 12/11/2021
@version P12
@param 01 oProdOrd, Object   , Inst�ncia da classe de ProductionOrder
@param 02 nCode   , Numeric  , C�digo de erro que ser� setado na classe
@param 03 cMessage, Character, Mensagem de erro que ser� setado na classe
@param 04 oError  , Object   , Objeto com as informa��es do erro ocorrido
@return Nil
/*/
Function ProdOrdErB(oProdOrd, nCode, cMessage, oError)

	oProdOrd:setError(nCode, cMessage + " " + oProdOrd:msgErrorBlock(oError))

	If InTransact()
		DisarmTransaction()
	EndIf

	BREAK

Return
