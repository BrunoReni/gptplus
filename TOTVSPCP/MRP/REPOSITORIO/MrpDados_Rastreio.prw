#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDados.ch'

#DEFINE ABAIXA_POS_QTD_PAI                 3
#DEFINE ABAIXA_POS_QTD_SUBSTITUICAO        6
#DEFINE ABAIXA_POS_QUEBRAS_QUANTIDADE      7

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
#DEFINE ADADOS_POS_DOC_AGL                 30
#DEFINE ADADOS_POS_ALTERNATIVOS            31
#DEFINE ADADOS_SIZE                        31

/*/{Protheus.doc} MrpDados_Rastreio
Classe de controle do rastreio de OP's
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDados_Rastreio FROM LongClassName

	DATA oDados          AS Object

	METHOD destruir()
	METHOD getPosicao(cCampo)
	METHOD getCmpDocPai(cList, cChave)
	METHOD getDocsComponente(cList)
	METHOD new() CONSTRUCTOR

	//M�todos auxiliares para identifica��o de ID e OP
	METHOD proximoID()
	METHOD proximaOP()
	METHOD proximaOPItem(cOP)
	METHOD proximaOPSequencia(cOP)

ENDCLASS

/*/{Protheus.doc} MrpDados_Rastreio
M�todo construtor da classe MrpDados_Rastreio
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - lCreate, l�gico, indica se deve criar a sess�o global de dados
@param 02 - oDados , objeto, instancia da camada de dados do MRP
@return, Self, objeto, instancia desta classe
/*/
METHOD new(lCreate, oDados) CLASS MrpDados_Rastreio

	Local cChaveExec
	Local oStatus    := MrpDados_Status():New(oDados:oParametros["ticket"])

	cChaveExec := oDados:oParametros["cChaveExec"]
	::oDados   := MrpData_Global():New( cChaveExec, "RASTREIO"    , lCreate, oDados:oLogs, oStatus)

Return Self

/*/{Protheus.doc} proximoID
Identifica o pr�ximo ID de Rastreabilidade
@author    brunno.costa
@since     15/08/2019
@version   1
@return cProxID, caracter, ID de rastreabilidade
/*/
METHOD proximoID() CLASS MrpDados_Rastreio

	Local cProxID := ""
	Local cChave  := "ultimoID"
	Local nProxID := 1
	Local lError  := .F.

	::oDados:setFlag(cChave, @nProxID, @lError, , ,.T.)
	cProxID := StrZero(nProxID, 10)

Return cProxID

/*/{Protheus.doc} proximaOP
Identifica o pr�ximo c�digo de OP
@author    brunno.costa
@since     15/08/2019
@version   1
@return cProxOP, caracter, pr�ximo n�mero de ordem de produ��o
/*/
METHOD proximaOP() CLASS MrpDados_Rastreio

	Local cProxOP := ""
	Local lError  := .F.
	Local nVal    := 0
	
	::oDados:setFlag("ProximaOP", @nVal, @lError, , .T., .T.)

	If lError .Or. nVal < 1
		lError  := .F.
		cProxOP := "000001"
	Else
		cProxOP := StrZero(nVal, 6)
	EndIf

	cProxOP := cProxOP + "01001"

Return cProxOP

/*/{Protheus.doc} proximaOPItem
Identifica o pr�ximo c�digo de Item para esta OP
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cOP, caracter, c�digo da OP referencia
@return cProxOP, caracter, c�digo de OP com o pr�ximo item para OP recebida
/*/
METHOD proximaOPItem(cOP) CLASS MrpDados_Rastreio

	Local cProxOP  := ""
	Local cItem    := "01"
	Local cChaveOP := Left(cOP, 6)
	Local cChave   := "ultimoItem_" + cChaveOP
	Local lError   := .F.

	::oDados:lock(cChave)
	cItem := ::oDados:getFlag(cChave, @lError)
	
	If lError
		lError  := .F.
		cItem := "02"
	Else
		cItem := Soma1(cItem)
	EndIf
	::oDados:setFlag(cChave, cItem, @lError)
	::oDados:unLock(cChave)
	cProxOP := cChaveOP + cItem + "001"

Return cProxOP

/*/{Protheus.doc} proximaOPSequencia
Identifica o pr�ximo ID de Sequencia para esta OP
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cOP, caracter, c�digo da OP referencia
@return cProxOP, caracter, c�digo de OP com a pr�xima sequ�ncia para OP recebida
/*/
METHOD proximaOPSequencia(cOP) CLASS MrpDados_Rastreio

	Local cProxOP  := ""
	Local cSequen  := "001"
	Local cChaveOP := Left(cOP, 8)
	Local cChave   := "ultimaSequencia_" + cChaveOP
	Local lError   := .F.

	::oDados:lock(cChave)
	cSequen := ::oDados:getFlag(cChave, @lError)
	If lError
		lError  := .F.
		cSequen := "002"
	Else
		cSequen := Soma1(cSequen)
	EndIf
	::oDados:setFlag(cChave, cSequen, @lError)
	::oDados:unLock(cChave)
	cProxOP := cChaveOP + cSequen

Return cProxOP

/*/{Protheus.doc} getCmpDocPai
Retorna os Componentes do documento Pai
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cChave, caracter, chave do registro: documento pai + chr(13) + TRT
@return aCmp, array, array com os componentes do documento pai: aCmp[x] := cComponente + chr(13) + cValToChar(nPeriodo) + chr(13) + cTRT + chr(13) + cChvSubst
/*/
METHOD getCmpDocPai(cList, cChave) CLASS MrpDados_Rastreio

	Local lError       := .F.
	Local aCmp := {}
	Local aAux

	aAux := ::oDados:getItemAList(cList, cChave, @lError)
	IF lError
		aCmp := {}
	Else
		aCmp := aClone(aAux[ADADOS_POS_COMP_EXPL_ESTRUT])
	EndIf
	aSize(aAux, 0)
	aAux := Nil

Return aCmp

/*/{Protheus.doc} getDocsComponente
Retorna os Documentos Pai do componente + TRT
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cList, caracter, chave da sess�o de rastreio: Produto + chr(13) + Per�odo
@return aChaves, array, array com as chaves dos componentes (Componente + chr(13) + TRT)
/*/
METHOD getDocsComponente(cList) CLASS MrpDados_Rastreio

	Local lError     := .F.
	Local aChvsBruto := {}
	Local aChaves    := {}
	Local nInd

	If ::oDados:existAList(cList)
		::oDados:getAllAList(cList, @aChvsBruto, lError)

		IF lError
			aChaves := {}
		Else
			For nInd := 1 to Len(aChvsBruto)
				aAdd(aChaves, aChvsBruto[nInd][1])
			Next
		EndIf

		aSize(aChvsBruto, 0)
		aChvsBruto := Nil
	EndIf

Return aChaves

/*/{Protheus.doc} getPosicao
Retorna a posi��o do campo na tabela
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cCampo, caracter, string com o nome do campo relacionado aos dados de rastreabilidade
@Return nReturn, n�mero, posi��o padr�o do registro no array de dados
/*/
METHOD getPosicao(cCampo) CLASS MrpDados_Rastreio

	Local nReturn := 0

	Do Case
		Case cCampo == "TIPOPAI"
			nReturn := ADADOS_POS_TIPOPAI
		Case cCampo == "DOCPAI"
			nReturn := ADADOS_POS_DOCPAI
		Case cCampo == "DOCFILHO"
			nReturn := ADADOS_POS_DOCFILHO
		Case cCampo == "COMPONENTE"
			nReturn := ADADOS_POS_COMPONENTE
		Case cCampo == "ID_OPCIONAL"
			nReturn := ADADOS_POS_ID_OPCIONAL
		Case cCampo == "PERIODO"
			nReturn := ADADOS_POS_PERIODO
		Case cCampo == "TRT"
			nReturn := ADADOS_POS_TRT
		Case cCampo == "NEC_ORIGINAL"
			nReturn := ADADOS_POS_NEC_ORIGINAL
		Case cCampo == "CONSUMO_ESTOQUE"
			nReturn := ADADOS_POS_CONSUMO_ESTOQUE
		Case cCampo == "NECESSIDADE"
			nReturn := ADADOS_POS_NECESSIDADE
		Case cCampo == "QTD_ESTOQUE"
			nReturn := ADADOS_POS_QTD_ESTOQUE
		Case cCampo == "SUBSTITUICAO"
			nReturn := ADADOS_POS_QTD_SUBSTITUICAO
		Case cCampo == "CONSUMO_SUBSTITU"
			nReturn := ADADOS_POS_CONSUMO_SUBSTITU
		Case cCampo == "CHAVE_SUBSTITUICAO"
			nReturn := ADADOS_POS_CHAVE_SUBSTITUICAO
		Case cCampo == "REGRA_ALTERNATIVO"
			nReturn := ADADOS_POS_REGRA_ALTERNATIVO
		Case cCampo == "SUBST_ORDEM"
			nReturn := ADADOS_POS_SUBST_ORDEM
		Case cCampo == "REVISAO"
			nReturn := ADADOS_POS_REVISAO
		Case cCampo == "ROTEIRO"
			nReturn := ADADOS_POS_ROTEIRO
		Case cCampo == "OPERACAO"
			nReturn := ADADOS_POS_OPERACAO
		Case cCampo == "ROTEIRO_DOCUMENTO_FILHO"
			nReturn := ADADOS_POS_ROTEIRO_DOCUMENTO_FILHO
		Case cCampo == "LOCAL"
			nReturn := ADADOS_POS_LOCAL
		Case cCampo == "QUEBRAS_QUANTIDADE"
			nReturn := ADADOS_POS_QUEBRAS_QUANTIDADE
		Case cCampo == "SIZE"
			nReturn := ADADOS_SIZE
		Case cCampo == "ABAIXA_POS_QTD_PAI"
			nReturn := ABAIXA_POS_QTD_PAI
		Case cCampo == "ABAIXA_POS_QTD_SUBSTITUICAO"
			nReturn := ABAIXA_POS_QTD_SUBSTITUICAO
		Case cCampo == "ABAIXA_POS_QUEBRAS_QUANTIDADE"
			nReturn := ABAIXA_POS_QUEBRAS_QUANTIDADE
		Case cCampo == "QTD_SUBST_ORIGINAL"
			nReturn := ADADOS_POS_QTD_SUBST_ORIGINAL
		Case cCampo == "VERSAO_PRODUCAO"
			nReturn := ADADOS_POS_VERSAO_PRODUCAO
		Case cCampo == "FILIAL"
			nReturn := ADADOS_POS_FILIAL
		Case cCampo == "TRANSFERENCIA_ENTRADA"
			nReturn := ADADOS_POS_TRANSFERENCIA_ENTRADA
		Case cCampo == "TRANSFERENCIA_SAIDA"
			nReturn := ADADOS_POS_TRANSFERENCIA_SAIDA
		Case cCampo == "RASTRO_AGLUTINACAO"
			nReturn := ADADOS_POS_RASTRO_AGLUTINACAO
		Case cCampo == "DOCUMENTO_AGLUTINADOR"
			nReturn := ADADOS_POS_DOC_AGL
		Case cCampo == "ALTERNATIVOS"
			nReturn := ADADOS_POS_ALTERNATIVOS
		OtherWise
			nReturn := ADADOS_SIZE
	EndCase

Return nReturn

/*/{Protheus.doc} destruir
Destroi os objetos e variaveis desta classe
@author brunno.costa
@since 15/08/2019
@version 1.0
/*/
METHOD destruir() CLASS MrpDados_Rastreio

	FreeObj(::oDados)

	::oDados := Nil
	ClearGlbValue("aRastreio")

Return