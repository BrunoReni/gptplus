#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "INTEGRAGIQ.CH"

#DEFINE ENTER CHR(13) + CHR(10)

/*/{Protheus.doc} IntegraGIQ
Regras de Negocio - Integracao de Mensagens Protheus x GIQ
@author    brunno.costa / renan.roeder
@since     30/08/2021
/*/
CLASS IntegraGIQ FROM LongClassName

	METHOD new() CONSTRUCTOR

	//CONTROLE DE PENDENCIAS DE INTEGRACAO
    METHOD incluiMensagemPendente(cAPI, cChaveRegistro, oDados, cMsgError)
    METHOD encerraPendencia(cAPI, cChaveRegistro)
	METHOD limpaRegistrosExcluidos()
    METHOD enviaTodasPendenciasParaGIQ(lManual)
	METHOD enviaPendenciaParaGIQ(lManual)
    
	//METODOS DE CONSUMO DAS API'S GIQ
    METHOD enviaProdutoParaGIQ(oProduto)
    METHOD enviaFornecedorParaGIQ(oFornecedor)
    METHOD enviaSolicitacaoInspecaoNFEParaGIQ(oSolicitacao)
    METHOD retornaLaudosGeraisPendentesDoGIQ()

	//CONTROLE PROCESSAMENTO EXECAUTO MATA175
	METHOD processaTodasBaixasEstoqueCQ()
	METHOD processaBaixasEstoqueCQ(oLaudoGeral)

	//PREPARAÇÃO ED CABEÇALHO DE INTEGRAÇÃO TOTVS RAC
	METHOD geraCabecalhoTOTVSRAC(cError)
	METHOD tokenRACExpirado()
	
ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author    brunno.costa / renan.roeder
@since     30/08/2021
/*/
METHOD new() CLASS IntegraGIQ
Return Self

/*/{Protheus.doc} incluiMensagemPendente
Inclui Mensagem para Tratamento de Pendências
@author    brunno.costa / renan.roeder
@since     30/08/2021
@param 01 - cAPI          , caracter, nome da API
@param 02 - cChaveRegistro, caracter, código único do registro
@param 03 - oDados        , JsonObject, objeto de dados para envio
@param 04 - cMsgError     , caracter  , mensagem de erro de integração
/*/
METHOD incluiMensagemPendente(cAPI, cChaveRegistro, oDados, cMsgError) CLASS IntegraGIQ
    
    Local nMaxTentativas := 3 //CRIAR MV_PAR
	Local lExiste        := .F.
    Local cTipo          := '1' //Insert/UPDATE

    cAPI := PadR(AllTriM(cAPI), 60, ' ')

    DbSelectArea("QF0")
    QF0->(DbSetOrder(2)) //QF0_FILIAL+QF0_API+QF0_IDREG
    If QF0->(DbSeek(xFilial("QF0") + cAPI + cChaveRegistro))
        lExiste = .T.
    EndIf

    If oDados:toJson() == '{}' .OR. oDados["delete"]
        cTipo := '2'
    EndIf

    RecLock('QF0', !lExiste)
	If lExiste
		QF0->QF0_TENT   += 1
		QF0->QF0_DTREP  := Date()
		QF0->QF0_HRREP  := Time()
		QF0->QF0_MSGRER := AllTrim(Left(PadR(cMsgError, 200), 200))
	Else
		QF0->QF0_FILIAL := xFilial("QF0")
		QF0->QF0_PROG   := FunName()
		QF0->QF0_API    := cAPI
		QF0->QF0_IDREG  := cChaveRegistro
		QF0->QF0_TIPO   := cTipo
		QF0->QF0_DADOS  := oDados:toJson()
		QF0->QF0_IDPRC  := ''
		QF0->QF0_USER   := RetCodUsr()
		QF0->QF0_DTENV  := Date()
		QF0->QF0_HRENV  := Time()
		QF0->QF0_MSGREI := AllTrim(Left(PadR(cMsgError, 200), 200))
	EndIf

	If QF0->QF0_TENT >= nMaxTentativas
		QF0->QF0_STATUS := '2' //2.Limite Tentativas Atingido
	Else
		QF0->QF0_STATUS := '1' //1.Pendente Reprocessamento
	EndIf

    QF0->(MsUnLock())
    QF0->(DbCLoseArea())

Return

/*/{Protheus.doc} encerraPendencia
Altera Status da Mensagem Pendente para Encerrado (3)
@author    brunno.costa / renan.roeder
@since     30/08/2021
@param 01 - cAPI          , caracter, nome da API
@param 02 - cChaveRegistro, caracter, código único do registro
/*/
METHOD encerraPendencia(cAPI, cChaveRegistro) CLASS IntegraGIQ
    
    Local cDelete := ""
	
	cAPI    := PadR(AllTriM(cAPI), 60, ' ')
    cDelete := " UPDATE " + RetSqlName("QF0") + " SET QF0_STATUS = '3' WHERE QF0_API = '" + cAPI + "' AND QF0_IDREG = '" + cChaveRegistro + "' AND D_E_L_E_T_= ' ' "
    If TcSqlExec(cDelete) < 0
		Help(' ', 1, 'Help' ,, STR0004 + cAPI + STR0005 + "'" + cChaveRegistro + "' : " + ENTER + ENTER + AllTrim(tcSQLError()), 1, 1, , , , , ,{STR0006}) //"Falha no encerramento pendência da " " e registro " "Contate o administrdor do sistema."
    EndIf
Return 

/*/{Protheus.doc} limpaRegistrosExcluidos
Exclui Registros Físicos na QF0 com Status 3
@author    brunno.costa / renan.roeder
@since     30/08/2021
/*/
METHOD limpaRegistrosExcluidos() CLASS IntegraGIQ
    
    Local cDelete := ""
	
    cDelete := " DELETE FROM " + RetSqlName("QF0") + " WHERE QF0_STATUS = '3'"
    If TcSqlExec(cDelete) < 0
		Help(' ', 1, 'Help' ,, STR0007 + ENTER + ENTER + AllTrim(tcSQLError()), 1, 1, , , , , ,;
			{STR0006}) //"Falha na limpeza das pendências encerradas: " "Contate o administrador do sistema."
    EndIf

Return 

/*/{Protheus.doc} enviaProdutoParaGIQ
Envia Produto para GIQ
@author    brunno.costa / renan.roeder
@since     30/08/2021
@param 01 - oProduto, JsonObject, objeto json do produto para envio
/*/
METHOD enviaProdutoParaGIQ(oProduto) CLASS IntegraGIQ

    Local aHeadOut       := {}
	Local cChaveRegistro := xFilial("SB1") + '-' + oProduto["codigo"]
	Local cError         := ""
    Local cResource      := ":443/giq/core/api/v1/produtos/integracao"
    Local cURL 		     := SuperGetMV("MV_URLGIQ",.F. )
    Local oRest          := FwRest():New(cURL)                              
	Local oJsonError     := JsonObject():New()
	Local bErrorBlock    := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('MATA010GIQ', cChaveRegistro, oProduto, e:Description) })

	Begin Sequence
		aHeadOut := self:geraCabecalhoTOTVSRAC(@cError) // Traz o token para realizar a integração

		oRest:SetPath(cResource)
		oRest:SetPostParams(oProduto:toJson())
		If !Empty(cError)
			self:incluiMensagemPendente('MATA010GIQ', cChaveRegistro, oProduto, cError)
			Help(' ', 1, 'Help' ,, STR0008 + "'" + AllTrim(oProduto["codigo"]) + "'" + STR0009 + ENTER + cError, 1, 1, , , , , ,;
									{STR0010}) //"A integração do produto " " não foi finalizada: " "Acesse a rotina de Pendências de Integração GIQ e reprocesse o envio."
		ElseIf (oRest:Post(aHeadOut))
			self:encerraPendencia('MATA010GIQ', cChaveRegistro)

		Else
			cError := oRest:GetLastError()
			oJsonError:fromJson(oRest:cResult)
			If !Empty(oJsonError['detailedMessage'])
				cError += + ENTER + ENTER + oJsonError['detailedMessage']
			EndIf
			self:incluiMensagemPendente('MATA010GIQ', cChaveRegistro, oProduto, DecodeUTF8(cError))
			Help(' ', 1, 'Help' ,, STR0008 + "'" + AllTrim(oProduto["codigo"]) + "'" + STR0009 + ENTER + ENTER + AllTrim(DecodeUTF8(cError)), 1, 1, , , , , ,;
									{STR0010}) //"A integração do produto "  não foi finalizada: " "Acesse a rotina de Pendências de Integração GIQ e reprocesse o envio."

		EndIf
	End Sequence

	ErrorBlock(bErrorBlock)

    FreeObj(oRest)
    oRest := Nil

	FreeObj(oJsonError)
    oJsonError := Nil

Return 

/*/{Protheus.doc} enviaFornecedorParaGIQ
Envia Fornecedor para GIQ
@author    brunno.costa / renan.roeder
@since     30/08/2021
@param 01 - oFornecedor, JsonObject, objeto json do fornecedor para envio
/*/
METHOD enviaFornecedorParaGIQ(oFornecedor) CLASS IntegraGIQ

	Local aHeadOut       := {}
	Local cChaveRegistro := xFilial("SA2") + '-' + oFornecedor["codigo"]
	Local cError         := ""
    Local cResource      := ":443/giq/core/api/v1/fornecedores/integracao"
    Local cURL 		     := SuperGetMV("MV_URLGIQ",.F. )
    Local oRest          := FwRest():New(cURL)                              
	Local oJsonError     := JsonObject():New()
	Local bErrorBlock    := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('MATA020GIQ', cChaveRegistro, oFornecedor, e:Description) })

	Begin Sequence
		aHeadOut := self:geraCabecalhoTOTVSRAC(@cError) // Traz o token para realizar a integração

		oRest:SetPath(cResource)
		oRest:SetPostParams(oFornecedor:toJson())
		If !Empty(cError)
			self:incluiMensagemPendente('MATA020GIQ', cChaveRegistro, oFornecedor, cError)
			Help(' ', 1, 'Help' ,, STR0011 + "'" + AllTrim(oFornecedor["codigo"]) + "'" + STR0009 + ENTER + cError, 1, 1, , , , , ,;
									{STR0010}) //"A integração do fornecedor " "  não foi finalizada: " "Acesse a rotina de Pendências de Integração GIQ e reprocesse o envio."

		ElseIf (oRest:Post(aHeadOut))
			self:encerraPendencia('MATA020GIQ', cChaveRegistro)

		Else
			cError := oRest:GetLastError()
			oJsonError:fromJson(oRest:cResult)
			If !Empty(oJsonError['detailedMessage'])
				cError += + ENTER + ENTER + oJsonError['detailedMessage']
			EndIf
			self:incluiMensagemPendente('MATA020GIQ', cChaveRegistro, oFornecedor, DecodeUTF8(cError))
			Help(' ', 1, 'Help' ,, STR0011 + "'" + AllTrim(oFornecedor["codigo"]) + "'" + STR0009 + ENTER + ENTER + AllTrim(DecodeUTF8(cError)), 1, 1, , , , , ,;
									{STR0010}) //"A integração do fornecedor " " não foi finalizada: " "Acesse a rotina de Pendências de Integração GIQ e reprocesse o envio."

		EndIf
	End Sequence

	ErrorBlock(bErrorBlock)

    FreeObj(oRest)
    oRest := Nil

	FreeObj(oJsonError)
    oJsonError := Nil

Return 

/*/{Protheus.doc} enviaSolicitacaoInspecaoNFEParaGIQ
Envia Solicitação de Inspeção da Nota Fiscal de Entrada para o GIQ
@author    brunno.costa / renan.roeder
@since     30/08/2021
@param 01 - oSolicitacao, JsonObject, objeto json da Solicitação de Inspeção da Nota Fiscal para envio
@return aRetQie = {EXPC1,EXPC2,EXPL1}
					Onde:  	EXPC1 = "C" Entrada certificada
									"D" Entrada Excluida
									"E" Erro na Integracao
					Onde:  	EXPC2 =  "C" Mensagem a ser enviada na acao
							EXPL1 = .T. Realizou a Integracao
									.F. Nao realizou a Integracao
/*/
METHOD enviaSolicitacaoInspecaoNFEParaGIQ(oSolicitacao) CLASS IntegraGIQ

    Local aRetQie        := {}
	Local aHeadOut       := {}
	Local cChaveRegistro := xFilial("SD7") + '-' + oSolicitacao["codigo"]
	Local cError         := ""
	Local cResource      := ":443/giq/core/api/v1/solicitacao/integracao"
    Local cURL 		     := SuperGetMV("MV_URLGIQ",.F. )
    Local oRest          := FwRest():New(cURL)	
	Local oJsonErro      := JsonObject():new()
	Local bErrorBlock    := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('SolicitacaoInspecaoNFE', cChaveRegistro, oSolicitacao, e:Description) })

	Begin Sequence
		aHeadOut := self:geraCabecalhoTOTVSRAC(@cError) // Traz o token para realizar a integração

		oRest:SetPath(cResource)
		oRest:SetPostParams(oSolicitacao:toJson())
		If !Empty(cError)
			oJsonErro:fromJson(oRest:GetResult())
			aRetQie := {"E", cError, .F.}
			self:incluiMensagemPendente('SolicitacaoInspecaoNFE', cChaveRegistro, oSolicitacao, cError)
			Help(' ', 1, 'Help' ,, STR0012 + "'" + AllTrim(oSolicitacao["codigo"]) + "'" + STR0009 + ENTER + cError, 1, 1, , , , , ,;
									{STR0010}) //"A integração da solicitação de inspeção " " não foi finalizada: " "Acesse a rotina de Pendências de Integração GIQ e reprocesse o envio."

		ElseIf (oRest:Post(aHeadOut))
			self:encerraPendencia('SolicitacaoInspecaoNFE', cChaveRegistro)
			aRetQie := {" ", OemToAnsi(STR0001), .T.} //"Material enviado para Inspecao no GIQ"

		Else
			cError := oRest:GetLastError()
			oJsonError:fromJson(oRest:cResult)
			If !Empty(oJsonError['detailedMessage'])
				cError += + ENTER + ENTER + oJsonError['detailedMessage']
			EndIf
			aRetQie := {"E", DecodeUTF8(cError), .F.}
			self:incluiMensagemPendente('SolicitacaoInspecaoNFE', cChaveRegistro, oSolicitacao, DecodeUTF8(cError))
			Help(' ', 1, 'Help' ,, STR0012 + "'" + AllTrim(oSolicitacao["codigo"]) + "'" + STR0009 + ENTER + ENTER + AllTrim(DecodeUTF8(cError)), 1, 1, , , , , ,;
									{STR0010}) //"A integração da solicitação de inspeção " " não foi finalizada: " "Acesse a rotina de Pendências de Integração GIQ e reprocesse o envio."


		EndIf
	End Sequence

	ErrorBlock(bErrorBlock)

    FreeObj(oRest)
    oRest := Nil

	FreeObj(oJsonErro)
    oJsonErro := Nil

Return aRetQie

/*/{Protheus.doc} retornaLaudosGeraisPendentesDoGIQ
Retorna Laudo Geral do GIQ Pendente de Integração
@author brunno.costa / renan.roeder
@since 01/09/2021
@version 1.0
@return cResult, caracter, string com dados Json retornados pela API

GIQ0001 - Programa que recebe o resultado das solicitações do GIQ para movimentar o estoque
@author  Michelle Ramos Henriques
@version P12
@since   30/03/2021
/*/
METHOD retornaLaudosGeraisPendentesDoGIQ() CLASS IntegraGIQ
	Local aHeadOut     := {}
	Local cError       := ""
    Local cResource    := ":443/giq/query/api/v1/solicitacoes/integracao/"    
	Local cResult      := ''
   	Local cURL 		   := SuperGetMV("MV_URLGIQ",.F. )
    Local oRest        := FwRest():New(cURL)                              
	Local oJsonError   := JsonObject():New()
	Local bErrorBlock  := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('retornaLaudosGeraisPendentes', 'retornaLaudosGeraisPendentes', JsonObject():new(), e:Description) })

	Begin Sequence
		aHeadOut := self:geraCabecalhoTOTVSRAC(@cError) // Traz o token para realizar a integração

		oRest:SetPath(cResource)

		If !Empty(cError)
			self:incluiMensagemPendente('retornaLaudosGeraisPendentes', 'retornaLaudosGeraisPendentes', JsonObject():new(), cError)
		ElseIf (oRest:get(aHeadOut))
			self:encerraPendencia('retornaLaudosGeraisPendentes', 'retornaLaudosGeraisPendentes')
			cResult := DecodeUTF8(oRest:GetResult())
		Else
			cError := oRest:GetLastError()
			oJsonError:fromJson(oRest:cResult)
			If !Empty(oJsonError['detailedMessage'])
				cError += + ENTER + ENTER + oJsonError['detailedMessage']
			EndIf
			self:incluiMensagemPendente('retornaLaudosGeraisPendentes', 'retornaLaudosGeraisPendentes', JsonObject():new(), DecodeUTF8(cError))
		EndIf
	End Sequence

	ErrorBlock(bErrorBlock)

	FreeObj(oRest)
	oRest := Nil

	FreeObj(oJsonError)
	oJsonError := Nil

Return cResult

/*/{Protheus.doc} processaTodasBaixasEstoqueCQ
Processa Baixas de CQ - Todos os Laudos Pendente
@author brunno.costa / renan.roeder
@since 01/09/2021
@version 1.0

GIQ0001 - Programa que recebe o resultado das solicitações do GIQ para movimentar o estoque
@author  Michelle Ramos Henriques
@version P12
@since   30/03/2021
/*/
METHOD processaTodasBaixasEstoqueCQ() CLASS IntegraGIQ

	Local nIndice	    := 0
	Local oLaudosGerais := JsonObject():New()
	Local cLaudosGerais := self:retornaLaudosGeraisPendentesDoGIQ()

	Local bErrorBlock  := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('retornaLaudosGeraisPendentes',;
																			  'retornaLaudosGeraisPendentes', JsonObject():New(), e:Description) })

	Begin Sequence
		If !Empty(cLaudosGerais)
			oLaudosGerais:FromJson(cLaudosGerais)
		
			DbSelectArea("SD7")
			For nIndice := 1 to Len(oLaudosGerais)
				self:processaBaixasEstoqueCQ(oLaudosGerais[nIndice])
			Next nIndice
			SD7->(dbCloseArea())
		EndIf
	End Sequence

	ErrorBlock(bErrorBlock)

	FreeObj(oLaudosGerais)
	oLaudosGerais := Nil

RETURN

/*/{Protheus.doc} processaBaixasEstoqueCQ
Processa Baixas de CQ - Laudo Específico
@author brunno.costa / renan.roeder
@since 01/09/2021
@version 1.0
@param 01 - oLaudoGeral, JsonObject, objeto Json com os dados de 1 (um) Laudo Geral retornado pela API (oLaudosGerais[nIndice])

GIQ0001 - Programa que recebe o resultado das solicitações do GIQ para movimentar o estoque
@author  Michelle Ramos Henriques
@version P12
@since   30/03/2021
/*/
METHOD processaBaixasEstoqueCQ(oLaudoGeral) CLASS IntegraGIQ

	Local aLibera	     := {}
	Local cAliasTop      := ''
	Local cDocSerie      := ''
	Local cDoctoNF	     := ''
	Local cDocCQ	     := ''
	Local cError         := ''
	Local cFilDocCQ	     := ''
	Local cFilMovto	     := ''
	Local cFornec	     := ''
	Local cFornLoja	     := ''
	Local cLoja		     := ''
	Local cProduto	     := ''
	Local cQuery         := ''
	Local cSerie	     := ''
	Local dData		     := ''
	Local nSD7Num	     := GetSx3Cache("D7_NUMERO" ,"X3_TAMANHO")
	Local nSD7Filial     := GetSx3Cache("D7_FILIAL" ,"X3_TAMANHO")
	Local nSD7Fornec     := GetSx3Cache("D7_FORNECE","X3_TAMANHO")
	Local nD7Loja        := GetSx3Cache("D7_LOJA"   ,"X3_TAMANHO")
	Local nD7Doc 	     := GetSx3Cache("D7_DOC"    ,"X3_TAMANHO")
	Local nD7Prod 	     := GetSx3Cache("D7_PRODUTO","X3_TAMANHO")
	Local nD7Serie	     := GetSx3Cache("D7_SERIE"  ,"X3_TAMANHO")
	Local cChaveRegistro := xFilial("SD7") + '-' + PadR(SubStr( oLaudoGeral['id'], (RAt( "-", oLaudoGeral['id'] ) + 1), nSD7Num ), nSD7Num) + '-001'
	Local nPosicao       := 0
	Local nQtdLibera     := 0
	Local nQtdRejei      := 0

	Local bErrorBlock    := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('ProcessaBaixaCQxMATA175', cChaveRegistro, oLaudoGeral, e:Description) })

	Begin Sequence
		cFilDocCQ	:= oLaudoGeral['id'] //Filial-Documento Qualidade
		nPosicao    := RAt( "-", cFilDocCQ )
		cDocCQ	    := PadR(SubStr( cFilDocCQ, (nPosicao + 1), nSD7Num ), nSD7Num) //Documento da qualidade
		cFilMovto   := PadR(SubStr( cFilDocCQ, 1, (nPosicao - 1) ), nSD7Filial) //Filial

		If cFilMovto <> xFilial("SD7")
			Return
		EndIf 

		cFornLoja   := oLaudoGeral['fornecedor']
		nPosicao    := RAt( "-", cFornLoja )
		cFornec	    := PadR(SubStr( cFornLoja, (nPosicao+1), nSD7Fornec ),nSD7Fornec) 
		cLoja	    := PadR(SubStr( cFornLoja, 1, (nPosicao-1) ), nD7Loja) // Fornecedor 

		nQtdLibera	:= oLaudoGeral['liberado']
		nQtdRejei	:= oLaudoGeral['rejeitado']
		dData		:= CtoD(SubStr(oLaudoGeral['data'],09,2)+'/'+SubStr(oLaudoGeral['data'],6,2)+'/'+SubStr(oLaudoGeral['data'],1,4))
		cProduto	:= PadR(oLaudoGeral['produto'], nD7Prod) //codigo do produto no protheus 

		cDocSerie	:= oLaudoGeral['documento']
		nPosicao	:= RAt( "-", cDocSerie )
		cSerie	    := PadR(SubStr( cDocSerie, (nPosicao + 1), nD7Serie ), nD7Serie) // Serie
		cDoctoNF    := PadR(SubStr( cDocSerie, 1, (nPosicao - 1) ),nD7Doc ) // Nota Fiscal

		cQuery := " SELECT SD7.R_E_C_N_O_ D7REC "
		cQuery +=   " FROM " + RetSqlName("SD7") + " SD7 "
		cQuery +=  " WHERE SD7.D7_FILIAL  = '" + xFilial("SD7") + "' "
		cQuery +=    " AND SD7.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SD7.D7_PRODUTO  = '" + cProduto + "' "
		cQuery +=    " AND SD7.D7_NUMERO   = '" + cDocCQ + "' "
		cQuery +=    " AND SD7.D7_TIPO     = 0  "

		cQuery    := ChangeQuery(cQuery)
		cAliasTop := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
		If !(cAliasTop)->(Eof())
			
			SD7->(dbGoTo((cAliasTop)->(D7REC)))
			If nQtdLibera > 0
				aAdd(aLibera,{	{"D7_TIPO"    , 1  	 	       , Nil},;  // 1=Libera o item do CQ / 2=Rejeita o item do CQ    			
								{"D7_DATA"    , dData  	       , Nil},;  // Data			
								{"D7_QTDE"    , nQtdLibera     , Nil},;  // Quantidade			
								{"D7_SALDO"   , Nil            , Nil},;  // Saldo - Mata175 efetua o calculo do saldo, mas é necessário passar o parâmetro
								{"D7_PRODUTO" , cProduto       , Nil},;  //	Produto			
								{"D7_NUMERO"  , cDocCQ         , Nil},;  //	Documento da qualidade			
								{"D7_DOC" 	  , cDoctoNF       , Nil},;  //	Nota Fiscal			
								{"D7_SERIE"	  , cSerie         , Nil},;  //	Serie da Nota Fiscal			
								{"D7_FORNECE" , cFornec        , Nil},;	 // Fornecedor
								{"D7_LOJA"    , cLoja          , Nil},;	 // loja
								{"D7_TIPCQ"   , "Q"            , Nil},;  // Tipo de movimento do qualidade 
								{"D7_LOCDEST" , SD7->D7_LOCDEST, Nil } }) // Local Destino
			EndIf

			If nQtdRejei > 0
				aAdd(aLibera,{	{"D7_TIPO"    , 2  	 	      , Nil},;  // 1=Libera o item do CQ / 2=Rejeita o item do CQ    			
								{"D7_DATA"    , dData  	      , Nil},;  // Data			
								{"D7_QTDE"    , nQtdRejei     , Nil},;  // Quantidade			
								{"D7_SALDO"   , Nil           , Nil},;  // Saldo - Mata175 efetua o calculo do saldo, mas é necessário passar o parâmetro
								{"D7_PRODUTO" , cProduto      , Nil},;  // Produto			
								{"D7_NUMERO"  , cDocCQ        , Nil},;  // Documento da qualidade			
								{"D7_DOC" 	  , cDoctoNF      , Nil},;  // Nota Fiscal	
								{"D7_SERIE"	  , cSerie 	      , Nil},;  // Serie da Nota Fiscal					
								{"D7_FORNECE" , cFornec       , Nil},;  // Fornecedor
								{"D7_LOJA"    , cLoja         , Nil},;  // loja
								{"D7_TIPCQ"   , "Q"		      , Nil},;  // Tipo de movimento do qualidade 
								{"D7_LOCDEST" , SD7->D7_LOCAL , Nil} }) // Local Destino - Quando é rejeitado, não se pode alterar o local 
			EndIf
			lMsErroAuto    := .F.
			lAutoErrNoFile := .T.
			MSExecAuto({|x,y,z| MATA175(x,y)}, aLibera, 4) 	

			If lMsErroAuto
				aEval(GetAutoGrLog(), {|x| cError += x + ENTER })
				self:incluiMensagemPendente('ProcessaBaixaCQxMATA175', cChaveRegistro, oLaudoGeral, cError)
			Else
				self:encerraPendencia('ProcessaBaixaCQxMATA175', cChaveRegistro)
			EndIf

		EndIf
	End Sequence

	ErrorBlock(bErrorBlock)

	aSize(aLibera, 0)
	(cAliasTop)->(dbCloseArea())
Return

/*/


{Protheus.doc} processaBaixasEstoqueCQ
Processa Baixas de CQ - Laudo Específico
@author brunno.costa / renan.roeder
@since 01/09/2021
@version 1.0
@param 01 - oLaudoGeral, JsonObject, objeto Json com os dados de 1 (um) Laudo Geral retornado pela API (oLaudosGerais[nIndice])

Função responsável por gerar o token de autorização do TOTVS RAC no cabeçalho da mensagem
@author  Michelle Ramos Henriques
@version P12
@since   30/03/2021

@param 01 - cError, caracter, retorna por referência erro ocorrido na operação
@return   aHeadOut - Array contendo o cabeçalho com o token do RAC para efetuar a integração com o GIQ
/*/

METHOD geraCabecalhoTOTVSRAC(cError) CLASS IntegraGIQ

    Local aHeadOut     := {}
	Local cURL         := SuperGetMV("MV_RACGIQ",.F. )
	Local cParams	   := ""
	Local cBeare	   := ""
	Local cClientId    := SuperGetMV( "MV_CLIENTI", .F.)
	Local cSecretId    := SuperGetMV( "MV_SECRETI", .F.)
	Local cResource    := "/totvs.rac/connect/token"
	Local oJson        := JsonObject():new()
	Local oJsonError   := JsonObject():New()
    Local oRest        := FwRest():New(cURL)
	Local cSeconds     := ''

	If !VarIsUID( 'IntegraGIQ' )
		VarSetUID( 'IntegraGIQ', .T.)
	EndIf

	GetGlbVars("IntegraGIQ_aHeadOut", @aHeadOut, @cSeconds)
	If Empty(aHeadOut) .OR. self:tokenRACExpirado(cSeconds)
		VarBeginT('IntegraGIQ', 'geraCabecalhoTOTVSRAC')
		GetGlbVars("IntegraGIQ_aHeadOut", @aHeadOut, @cSeconds)
		If (Empty(aHeadOut) .OR. self:tokenRACExpirado(cSeconds))
			oRest:SetPath(cResource)
			If Empty(cClientId) .Or. Empty(cSecretId)
				Help(' ', 1, 'Help' ,, STR0013, 1, 1, , , , , ,;
										{STR0014}) //"Falha na configuração dos parâmetros 'MV_CLIENTI' e 'MV_SECRETI'." "Corrija-os ou desative a integração com o GIQ (Parâmetro 'MV_INTGIQE')."
				cError := STR0013 //"Falha na configuração dos parâmetros 'MV_CLIENTI' e 'MV_SECRETI'."
			Else
				aAdd( aHeadOut, "Content-Type: application/x-www-form-urlencoded" )
				
				cParams := "grant_type=client_credentials&"
				cParams += "client_id=" + trim(cClientId) + "&"
				cParams += "client_secret=" + trim(cSecretId) + "&"
				cParams += "scope=authorization_api"

				oRest:SetPostParams(cParams)
				If oRest:Post(aHeadOut)
					If oJson:FromJson(oRest:GetResult()) = nil
						cBeare := oJson:GetJSonObject('access_token')
						aHeadOut := {}
						aAdd( aHeadOut, "Accept: application/json" )
						aAdd( aHeadOut, "Content-Type: application/json;odata=verbose" )
						aAdd( aHeadOut, "Cache-Control: no-cache" )
						aAdd( aHeadOut, 'User-Agent: Chrome/65.0 (compatible; Protheus '+GetBuild()+')' )
						aAdd( aHeadOut, "Content-Type: application/json; charset=UTF-8")
						aAdd( aHeadOut, "Authorization: Bearer " + cBeare)
						PutGlbVars("IntegraGIQ_aHeadOut", aHeadOut, MicroSeconds())
					Else
						aHeadOut := {}
						Help(' ', 1, 'Help' ,, STR0015 + ENTER + ENTER + AllTrim(DecodeUTF8(oRest:GetLastError())), 1, 1, , , , , ,;
												{STR0016}) //"Falha na geração de autorização para Integração com o GIQ.: " "Revise os parâmetros 'MV_CLIENTI' e 'MV_SECRETI' ou desative a integração com o GIQ, parâmetro 'MV_INTGIQE'."
						cError := STR0015 + ENTER + ENTER + AllTrim(DecodeUTF8(oRest:GetLastError())) //"Falha na geração de autorização para Integração com o GIQ.: "
					EndIf
				Else
					Help(' ', 1, 'Help' ,, STR0015 + ENTER + ENTER + AllTrim(DecodeUTF8(oRest:GetLastError())), 1, 1, , , , , ,;
											{STR0016}) //"Falha na geração de autorização para Integração com o GIQ.: " "Revise os parâmetros 'MV_CLIENTI' e 'MV_SECRETI' ou desative a integração com o GIQ, parâmetro 'MV_INTGIQE'."

					cError := "Falha na geração de autorização para Integração com o GIQ.: " + ENTER + ENTER + AllTrim(DecodeUTF8(oRest:GetLastError()))
					oJsonError:fromJson(oRest:cResult)
					If !Empty(oJsonError['detailedMessage'])
						cError += + ENTER + ENTER + oJsonError['detailedMessage']
					EndIf
				EndIf
			EndIf
		EndIf
		VarEndT('IntegraGIQ', 'geraCabecalhoTOTVSRAC')
	EndIf

	FreeObj(oRest)
	oRest := Nil

	FreeObj(oJson)
	oJson := Nil

	FreeObj(oJsonError)
	oJsonError := Nil

	//aSize(aHeadOut, 0) Descomentar para Testar Erros
Return aHeadOut


/*/{Protheus.doc} enviaTodasPendenciasParaGIQ
Função Responsável Por Realizar o Reprocessamento De Todas as Pendências de Envio para o GIQ
@author brunno.costa / renan.roeder
@since 01/09/2021
@version 1.0
@param 01 - lManual, lógico, define se força re-execução manual (.T.) ou se é chamado a partir do agendamento de schedule (.F.)
/*/

METHOD enviaTodasPendenciasParaGIQ(lManual) CLASS IntegraGIQ

	Default lManual := .F.

	DbSelectArea("QF0")
	QF0->(DbGoTop())
	While !QF0->(EOF())
		self:enviaPendenciaParaGIQ(lManual)
		QF0->(DbSkip())
	EndDo

	self:limpaRegistrosExcluidos()
	QF0->(DbCloseArea())

	If VarIsUID( 'IntegraGIQ' )
		VarClean( 'IntegraGIQ' )
	EndIf

Return

/*/{Protheus.doc} enviaPendenciaParaGIQ
Função Responsável Por Realizar o Reprocessamento de Pendência do Registro Posicionado da QF0
@author brunno.costa / renan.roeder
@since 01/09/2021
@version 1.0
@param 01 - lManual, lógico, define se força re-execução manual (.T.) ou se é chamado a partir do agendamento de schedule (.F.)
/*/
METHOD enviaPendenciaParaGIQ(lManual) CLASS IntegraGIQ

	Local cAPI        := ''
	Local oJsonObject := JsonObject():New()
	Local cIDProcesso := UUIDRandomSeq()
	Local nRecnoBkp   := 0

	cAPI := AllTrim(QF0->QF0_API)
	nRecnoBkp := QF0->(Recno())
	
	If QF0->QF0_STATUS == '1' .OR. lManual //1.Pendente Reprocessamento
		If Empty(QF0->QF0_IDPRC) .AND. RecLock("QF0", .F.)
			QF0->QF0_IDPRC := cIDProcesso
			MsUnlock("QF0")
		EndIf
		
		QF0->(DbGoTo(nRecnoBkp))
		If AllTrim(QF0->QF0_IDPRC) == AllTrim(cIDProcesso)
			oJsonObject:fromJson(QF0->QF0_DADOS)
			Do Case
				Case AllTrim(QF0->QF0_API) == 'MATA010GIQ'
					self:enviaProdutoParaGIQ(oJsonObject)

				Case AllTrim(QF0->QF0_API) == 'MATA020GIQ'
					self:enviaFornecedorParaGIQ(oJsonObject)

				Case AllTrim(QF0->QF0_API) == 'SolicitacaoInspecaoNFE'
					self:enviaSolicitacaoInspecaoNFEParaGIQ(oJsonObject)

				Case AllTrim(QF0->QF0_API) == 'retornaLaudosGeraisPendentes'
					self:processaTodasBaixasEstoqueCQ()

				Case AllTrim(QF0->QF0_API) == 'ProcessaBaixaCQxMATA175'
					self:processaBaixasEstoqueCQ(oJsonObject)

			End Sequence
		EndIf

		QF0->(DbGoTo(nRecnoBkp))
		If AllTrim(QF0->QF0_IDPRC) == AllTrim(cIDProcesso)
			RecLock("QF0", .F.)
			QF0->QF0_IDPRC := ''
			MsUnlock("QF0")
		EndIf
	EndIf
Return

/*/{Protheus.doc} tokenRACExpirado
Verifica se Já Expirou o token do TOTVS RAC
@author brunno.costa / renan.roeder
@since 24/09/2021
@version 1.0
@param 01 - nMicroSeconds, numero, define se força re-execução manual (.T.) ou se é chamado a partir do agendamento de schedule (.F.)
/*/
METHOD tokenRACExpirado(nMicroSeconds) CLASS IntegraGIQ
	Local lExpirado   := .F.
	Local nMinutos    := 15
	Local bErrorBlock := ErrorBlock({|e| .T. })
	Default nMicroSeconds := -1
	If nMicroSeconds > 0
		Begin Sequence
			lExpirado := ((MicroSeconds() - nMicroSeconds) > nMinutos*60)//*1000
		End Sequence
	EndIf
	ErrorBlock(bErrorBlock)
Return lExpirado

/*/{Protheus.doc} IntGiqESol
Função chamada nos diversos pontos de integração de nota fiscal para solicitar inspeção ao GIQ
@since 19/11/2020
@param 01 - aDados, Array de Integracao dos dados - (LayOut para Importacao)              
							Descricao               ³   Origem Materiais   ³ TIPO ³ TAM ³ DEC ³ 
			[01] - Numero da Nota Fiscal 	 		³ D1_DOC               ³  C   ³	06	³  0  ³  
			[02] - Serie da Nota Fiscal           	³ D1_SERIE   	       ³  C	  ³	03	³  0  ³ 
			[03] - Tipo da Nota Fiscal   		 	³ D1_TIPO              ³  C   ³	01	³  0  ³  
			[04] - Data de Emissao da Nota Fiscal   ³ D1_EMISSAO           ³  D	  ³	08	³  0  ³
			[05] - Data de Entrada da Nota Fiscal   ³ D1_DTDIGIT           ³  D	  ³	08	³  0  ³
			[06] - Tipo de Documento -> default "NF"³ "NF" ou "REMITO"     ³  C	  ³	06	³  0  ³ 
			[07] - Item da Nota Fiscal				³ D1_ITEM              ³  C	  ³	02	³  0  ³ 
			[08] - Numero do Remito (Localizacoes)  ³ D1_REMITO            ³  C	  ³	12	³  0  ³ 
			[09] - Numero do Pedido de Compra       ³ D1_PEDIDO            ³  C	  ³	06	³  0  ³
			[10] - Item do Pedido de Compra         ³ D1_ITEMPC            ³  C	  ³	02	³  0  ³
			[11] - Codigo Fornecedor/Cliente        ³ D1_FORNECE           ³  C	  ³	06	³  0  ³
			[12] - Loja Fornecedor/Cliente          ³ D1_LOJA     	       ³  C	  ³	02	³  0  ³
			[13] - Numero do Lote do Fornecedor     ³ D1_LOTEFOR     	   ³  C	  ³	18	³  0  ³
			[14] - Codigo do Solicitante            ³ SPACE(6)     		   ³  C   ³	06	³  0  ³
			[15] - Codigo do Produto                ³ D1_COD     	       ³  C	  ³	06	³  0  ³
			[16] - Local Origem    				    ³ D1_LOCAL   	   	   ³  C	  ³	02	³  0  ³
			[17] - Numero do Lote             		³ D5_LOTECTL 	       ³  C	  ³	10	³  0  ³
			[18] - Sequencia do Sub-Lote         	³ D5_NUMLOTE     	   ³  C	  ³	06	³  0  ³
			[19] - Numero Sequencial                ³ D1_NUMSEQ            ³  C	  ³	06	³  0  ³ 
			[20] - Numero do CQ					    ³ D1_NUMCQ		       ³  C	  ³	06	³  0  ³
			[21] - Quantidade             			³ D1_QUANT		       ³  N	  ³ 11	³  2  ³
			[22] - Preco             				³ D1_TOTAL 		       ³  N	  ³	14	³  2  ³
			[23] - Dias em atraso				    ³ D1_DTDIGIT-C7_DATPRF ³  N	  ³	04	³  0  ³
			[24] - TES (somente Materiais)			³ D1_TES		       ³  C	  ³	03	³  0  ³
			[25] - Origem							³ FunName()		       ³  C	  ³	08	³  0  ³
			[26] - Origem Importacao TXT			³ 				       ³  C	  ³	12	³  0  ³
			[27] - Quantidade do Lote Original      ³ 					   ³  N	  ³ 11	³  2  ³
			[28] - Hora da Entrada				    ³ 					   ³  C	  ³ 05	³  0  ³

@param 02 - nOpc: 1) Inclusao, 2) Exclusao

@return aRetQie = {EXPC1,EXPC2,EXPL1}
					Onde:  	EXPC1 = "C" Entrada certificada
									"D" Entrada Excluida
									"E" Erro na Integracao
					Onde:  	EXPC2 =  "C" Mensagem a ser enviada na acao
							EXPL1 = .T. Realizou a Integracao
									.F. Nao realizou a Integracao
/*/
Function IntGiqESol(aDados, nOpc)

	Local aRetQie     := {}
	Local oIntegraGIQ := IntegraGIQ():New()
	Local oJson 	  := JsonObject():New()

	oJson["produto"] 			:= trim(aDados[15]) //Codigo do Produto 
	oJson["fornecedor"] 		:= trim(aDados[11]) + "-" + trim(aDados[12]) //Codigo Fornecedor/Cliente  + Loja Fornecedor/Cliente 
	oJson["codigo"]             := xFilial("SD7") + "-" + trim(aDados[20]) //Numero do CQ	
	oJson["delete"]				:= iF(nOpc == 2,.T.,.F.)
	
	oJson['documento'] := JsonObject():New()
	oJson['documento']["tipo"] 	:= trim(aDados[03]) //Tipo da Nota Fiscal 				 	
	oJson['documento']["numero"]:= trim(aDados[01]) + "-" + trim(aDados[02]) //Numero da Nota Fiscal + Serie da Nota Fiscal 
	oJson['documento']["data"]  := FWTimeStamp(3,aDados[05])
	
	oJson["lote"] := JsonObject():New()
	oJson["lote"]["quantidade"]	:= aDados[21] //Quantidade 

	If Empty(aDados[13]) //Lote do Fornecedor
		oJson["lote"]["numero"]	:= aDados[17] //Numero do Lote  
	else
		oJson["lote"]["numero"]	:= aDados[13] //Lote do Fornecedor
	EndIf

	iF SD7->(MsSeek(xFilial("SD7")+aDados[20]+aDados[15]+aDados[16]+aDados[19]))
		oJson["lote"]["dataValidadeLote"] 	:= SD7->D7_DTVALID
	EndIf

	aRetQie := oIntegraGIQ:enviaSolicitacaoInspecaoNFEParaGIQ(oJson)
	FreeObj(oJson)
	oJson := Nil

	FreeObj(oIntegraGIQ)
	oIntegraGIQ := Nil
	
Return aRetQie


/*/{Protheus.doc} GIQIPCStart
Inicializa uma fila de JOBS
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo, caracter, nome do semaforo que sera utilizado para a fila de Threads
@param 02 - nThreads , numero  , numero de Threads que serao abertas pela funcao
@param 03 - nAbertas , numero  , utilizacao interna em recursao, indica quantidade de threads ja abertas
@param 04 - xEmpAnt  , caracter, indica o codigo da empresa para abertura de ambiente
@param 05 - xFilAnt  , caracter, indica o codigo da filial para abertura de ambiente
@param 06 - cErrorUID, caracter, codigo identificador da secao global de controle de erros
/*/

Function GIQIPCStart(cSemaforo, nThreads, nAbertas, xEmpAnt, xFilAnt, cErrorUID)

	Local nInd      := 1
	Local nResto    := nThreads
	Local oPCPError

	Default cSemaforo := "GIQIPC"
	Default nAbertas  := 0
	Default cErrorUID := "MULTITHREAD_GIQIPC"

	VarSetUID( "SEMAFORO_" + cSemaforo  , .T.)
	VarSetX  ( "SEMAFORO_" + cSemaforo, "lActivated" , .T. )
	If nAbertas < 1
		VarSetX("SEMAFORO_" + cSemaforo, "nIniciando", nThreads)
	EndIf

	oPCPError := PCPMultiThreadError():New(cErrorUID, .F.)

	If nAbertas < 1
		nResto   := nThreads - 1
		nThreads := 1
	EndIf

	For nInd := 1 to nThreads
		oPCPError:startJob("GIQIPCJOB", GetEnvServer(), .F., xEmpAnt, xFilAnt, cSemaforo, cErrorUID)
		Sleep(200)
	Next

	If nAbertas == 0 .and. nResto > 0
		oPCPError:startJob("GIQIPCStart", GetEnvServer(), .T., , , cSemaforo, nResto, nAbertas + 1, xEmpAnt, xFilAnt, cErrorUID)
	EndIf

Return

/*/{Protheus.doc} GIQIPCFinish
Encerra as threads de determinada fila
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo, caracter, nome do semaforo que sera utilizado para a fila de Threads
@param 02 - nMinCanc , numero  , número mínimo de tentativa consecutivas de fechamento da Thread
@param 03 - nQtdThr  , numero  , quantidade de threads a ser encerrada. Se não passar, será assumido o mesmo valor das tentativas
/*/
Function GIQIPCFinish(cSemaforo, nMinCanc, nQtdThr)
	Local nTentativas := 0

	Default cSemaforo := "GIQIPCJOB"
	Default nMinCanc  := 1
	Default nQtdThr   := nMinCanc

	//Verifica se as threads ainda estão sendo iniciadas, e aguarda o término da inicialização
	GIQIPCWIni(cSemaforo)

	While IPCCount(cSemaforo) > 0 .OR. nTentativas < nMinCanc
		Sleep(50)

		If IPCCount(cSemaforo) > 0
			GIQIPCGO(cSemaforo, .T.)

			//Decrementa a quantidade de threads a serem encerradas
			nQtdThr--

			//Se ja fechou todas as threads, sai do loop
			If nQtdThr == 0
				Exit
			EndIf
		EndIf
		nTentativas++
	EndDo

	VarSetX( "SEMAFORO_" + cSemaforo, "lActivated" , .F. )
	If !VarClean("SEMAFORO_" + cSemaforo)
		LogMsg("GIQIPCJOB", 0, 0, 1, '', '', "************************************* Falha GIQIPCFinish VarClean(SEMAFORO_ + cSemaforo): " + AllTrim(cSemaforo) + " *************************************") // falha
	EndIf
Return

/*/{Protheus.doc} GIQIPCGO
Encerra as threads de determinada fila
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo, caracter    , nome do semaforo da fila
@param 02 - lClose   , logico      , indica se deve fechar a Thread apos a execucao
@param 03 - cFunName , caracter    , indica o nome da funcao que sera executada pela Thread
@param 04 - oVar1    , nao definido, 1a variavel que sera repassada para a funcao
@param 05 - oVar2    , nao definido, 2a variavel que sera repassada para a funcao
@param 06 - oVar3    , nao definido, 3a variavel que sera repassada para a funcao
@param 07 - oVar4    , nao definido, 4a variavel que sera repassada para a funcao
@param 08 - oVar5    , nao definido, 5a variavel que sera repassada para a funcao
@param 09 - oVar6    , nao definido, 6a variavel que sera repassada para a funcao
@param 10 - oVar7    , nao definido, 7a variavel que sera repassada para a funcao
@param 11 - oVar8    , nao definido, 8a variavel que sera repassada para a funcao
@param 12 - oVar9    , nao definido, 9a variavel que sera repassada para a funcao
@param 13 - oVar10   , nao definido, 10a variavel que sera repassada para a funcao
@param 14 - lWait    , logico      , indica se a funcao deve aguardar uma Thread disponivel
									 ou nao executar a a funcao em caso de indisponibilidade
/*/
Function GIQIPCGO(cSemaforo, lClose, cFunName, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar9, oVar10, lWait)

	Local lReturn := .T.

	Default cSemaforo := "GIQIPCJOB"
	Default lClose    := .F.
	Default cFunName  := ""
	Default lWait     := .T.

	If lWait
		While !IPCGo( cSemaforo, cFunName, lClose, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar9, oVar10 )
		EndDo
	Else
		lReturn := IPCGo( cSemaforo, cFunName, lClose, oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar9, oVar10 )
	EndIf

Return lReturn

/*/{Protheus.doc} GIQIPCJOB
Job de execucao das Threads da Fila
@author    brunno.costa
@since     14/02/2019
@version   1
@param 01 - cSemaforo , caracter, nome do semaforo que sera utilizado para a fila de Threads
@param 02 - cErrorUID, caracter, codigo identificador da secao global de controle de erros
/*/
Function GIQIPCJOB(cSemaforo, cErrorUID)
	Local cFunName
	Local lRet
	Local lClose
	Local oVar1
	Local oVar2
	Local oVar3
	Local oVar4
	Local oVar5
	Local oVar6
	Local oVar7
	Local oVar8
	Local oVar9
	Local oVar10
	Local lAux
	Local lPrimeiro  := .T.
	Local nTotal     := 0

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	While !KillApp()
		cFunName := ""
		lClose   := .F.
		oVar1    := NIL
		oVar2    := NIL
		oVar3    := NIL
		oVar4    := NIL
		oVar5    := NIL
		oVar6    := NIL
		oVar7    := NIL
		oVar8    := NIL
		oVar9    := NIL
		oVar10   := NIL

		//Decrementa totalizador de threads preparadas
		If lPrimeiro
			lPrimeiro := .F.
			VarSetX("SEMAFORO_" + cSemaforo, "nIniciando", @nTotal, 1, -1)
		EndIf

		lRet := IpcWaitEx( cSemaforo, 10000, @cFunName, @lClose, @oVar1, @oVar2, @oVar3, @oVar4, @oVar5, @oVar6, @oVar7, @oVar9, @oVar10 )
		If lRet
			If !Empty(cFunName)
				&cFunName.(oVar1, oVar2, oVar3, oVar4, oVar5, oVar6, oVar7, oVar9, oVar10)
			EndIf
		Endif
		If !lClose
			If VarIsUID("SEMAFORO_" + cSemaforo)
				lRet := VarGetX( "SEMAFORO_" + cSemaforo, "lActivated" , @lAux )
				If !lRet
					lAux := .F.
				EndIf
				lClose := !lAux
			Else
				lClose := .T.
			EndIf
		EndIf
		If lClose
			Exit
		EndIf
	EndDo

Return

/*/{Protheus.doc} GIQIPCWIni
Aguarda a abertura e inicialização das threads

@author    lucas.franca
@since     12/03/2020
@version   1
@param 01 - cSemaforo, Character, Nome do semáforo de threads
/*/
Function GIQIPCWIni(cSemaforo)
	Local lRet   := .T.
	Local nTotal := 0

	While lRet
		lRet := VarGetX("SEMAFORO_" + cSemaforo, "nIniciando", @nTotal)

		If lRet
			Sleep(100)
			If nTotal < 1
				lRet := .F.
			EndIf
		EndIf
	End

Return
