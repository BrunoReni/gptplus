#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPI.CH"

WSRESTFUL WSPfsApi DESCRIPTION STR0001 // "WebService para teste API"
	WSDATA pathArq     AS STRING
	WSDATA codDoc      AS STRING
	WSDATA codEntidade AS STRING
	WSDATA nomeEnt     AS STRING
    WSDATA key         AS STRING
	WSDATA campoChave  AS STRING
	WSDATA mvcModel    AS STRING
	WSDATA xbAlias     AS STRING
	WSDATA searchKey   AS STRING
	WSDATA filtF3      AS STRING
	WSDATA filter      AS STRING

	// Métodos GET
    WSMETHOD GET DownloadFile  DESCRIPTION STR0002 PATH "legaldesk/anexo/download/{key}"       PRODUCES APPLICATION_JSON // "Download anexo via LegalDesk"

	WSMETHOD GET StructMVC     DESCRIPTION STR0021 PATH "mvc/struct/{MvcModel}"                PRODUCES APPLICATION_JSON // "Busca a Estrutura do MVC"
	WSMETHOD GET existTab      DESCRIPTION STR0032 PATH "sx2/{key}"                            PRODUCES APPLICATION_JSON // "Verifica se existe a tabela no ambiente"

	WSMETHOD GET gtSx3Data     DESCRIPTION STR0022 PATH "congen/sx3/{MvcModel}/{campoChave}"   PRODUCES APPLICATION_JSON // "Busca dados do campo"

	WSMETHOD GET gtModelData   DESCRIPTION STR0023 PATH "congen/mvc/{mvcModel}"                PRODUCES APPLICATION_JSON // "Busca os dados do modelo" 
	WSMETHOD GET getF3List     DESCRIPTION STR0024 PATH "getF3/{filtF3}/{xbAlias}"             PRODUCES APPLICATION_JSON // 'Busca a lista de opções de um campo tipo F3'
	WSMETHOD GET getF3         DESCRIPTION STR0025 PATH "getF3/{filtF3}/{xbAlias}/{searchKey}" PRODUCES APPLICATION_JSON // 'Busca o registro específico de um campo tipo F3'

	// Métodos PUT
	WSMETHOD PUT cnvPfsTxt     DESCRIPTION STR0003 PATH "convert/txt"                          PRODUCES APPLICATION_JSON // "Conversão de PDF para Texto"

	// Métodos POST
	WSMETHOD POST cpAnalise    DESCRIPTION STR0004 PATH "leitura/pagar"                        PRODUCES APPLICATION_JSON // "Analise de PDF do Contas a pagar" 
	WSMETHOD POST anxCreate    DESCRIPTION STR0005 PATH "anexo"                                PRODUCES APPLICATION_JSON // "Cria anexo"
	WSMETHOD POST anxLdCreate  DESCRIPTION STR0005 PATH "legaldesk/anexo/upload"               PRODUCES APPLICATION_JSON // "Cria anexo via LegalDesk"
	WSMETHOD POST fileImport   DESCRIPTION STR0005 PATH "arqretorno"                           PRODUCES APPLICATION_JSON // "Importa arquivo de retorno do CNAB para o diretório da SEE do banco"

	
	// Métodos DELETE
	WSMETHOD DELETE DeleteDoc  DESCRIPTION STR0006 PATH "anexos/{codDoc}"                      PRODUCES APPLICATION_JSON // "Exclusão do anexo"
END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET existTab 
Verifica se a tabela existe no Ambiente

@param key - Tabela a ser pesquisada

@author Willian.Kazahaya
@since 02/07/2021
@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/sx2/{key}

/*/
//-------------------------------------------------------------------
WSMETHOD GET existTab PATHPARAM key WSREST WsPfsApi
Local lTabInDic := .F.
Local oResponse := JsonObject():New()

	lTabInDic := FWAliasInDic(Self:key)
	oResponse['table'] := Self:key
	oResponse['exist'] := lTabInDic

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DownloadFile
Efetua o download do anexo selecionado

@param key - Chave da NUM a fazer download (NUM_FILIAL + NUM_COD) em base 64

@author Willian.Kazahaya
@since 00/00/2020
@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/legaldesk/anexo/donwload/{key}

/*/
//-------------------------------------------------------------------
WSMETHOD GET DownloadFile PATHPARAM key WSREST WSPfsApi
Local oAnexo      := Nil
Local lRet        := .T.
Local cTpAnexo    := ""
Local cEntidade   := ""
Local cCodEnt     := ""
Local cPathDown   := "\temp\"
Local cNomArq     := ""
Local nCodError   := 404 //Not Found
Local cMsgError   := STR0018 //"Chave primária inválida [#1]"
Local aDados	  := {}
Local cKey		  := Self:Key

	// Caso não tenha enviado o caminho do arquivo por queryParam
	If !Empty(cKey)
		cKey   := PadR(DeCode64(cKey), TamSx3("NUM_FILIAL")[1]+TamSx3("NUM_COD")[1])
		aDados := JurGetDados("NUM", 1, cKey, {"NUM_ENTIDA", "NUM_CENTID", "NUM_NUMERO","NUM_DESC", "NUM_DOC", "NUM_EXTEN"})
		
		If Len(aDados) > 0
			cTpAnexo  := AllTrim(SuperGetMv('MV_JDOCUME',, '2'))
			cEntidade := aDados[01]
			cCodEnt   := aDados[02]
			cNumero   := aDados[03]

			If !Empty(aDados[04])
				cNomArq := AllTrim(aDados[04])
			Else
				cNomArq := AllTrim(aDados[05]) + AllTrim(aDados[06])
			EndIf 
			oAnexo   := JPFSGetAnx(cEntidade, cCodEnt)

			If cTpAnexo == '2' //Base de Conhecimento
				
				cPathDown += AllTrim(cNumero)+"\"
				cPathArq := cPathDown + cNomArq

				// Verifica se a pasta temporária está criada, caso não, cria a pasta
				If CreatePathDown(@cPathDown) .And. !Empty(cPathArq)
					oAnexo:lSalvaTemp := .F.

					If lRet := oAnexo:Exportar("", cPathDown, cNumero, cNomArq)
						//Manda o arquivo
						lRet := JRespDown(Self, cPathArq)

						If lRet
							//Apaga o arquivo e o diretório criados temporariamente
							fErase(cPathArq)
							DirRemove(cPathDown)
						EndIf
					Else
						nCodError := 500
						cMsgError := STR0019 //"Não foi possível localizar o arquivo" '
						SetRestFault(nCodError, JConvUTF8(cMsgError))
					EndIf
				Else
					lRet := .F.
					nCodError := 500
					cMsgError := I18N(STR0020, {cPathDown,cValToChar(FError())}) //"Não foi possível criar a pasta #1 Erro: #2"
				EndIf
			Else
				lRet := .F.
				nCodError := 500
			    cMsgError := STR0019 //"Não foi possível localizar o arquivo"
				SetRestFault(nCodError, JConvUTF8(cMsgError))
			EndIf
		Else
			lRet := .F.
			cMsgError := I18N(cMsgError , {cKey}) //"Chave primária inválida [#1]"
			SetRestFault(nCodError, JConvUTF8(cMsgError))
		EndIf
	Else
		lRet := .F.
		cMsgError := I18N(cMsgError , {cValToChar(cKey)}) //"Chave primária inválida [#1]"
		SetRestFault(nCodError, JConvUTF8(cMsgError))
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET StructMVC
Endpoint de busca da estrutura do MVC

@param mvcModel - Path - Fonte MVC a ser chamado

@author Willian.Kazahaya
@since 21/05/2021
@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/mvc/struct/{MvcModel}
/*/
//-------------------------------------------------------------------
WSMETHOD GET StructMVC PATHPARAM mvcModel WSREST WsPfsApi
Local lRet       := .T.
Local oResponse  := nil
Local mvcModel   := Self:mvcModel

	If !Empty(mvcModel)
		oResponse := JW77StrMdl(mvcModel, '')
		If ValType(oResponse) == "J"
			Self:SetContentType("application/json")
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		Else
			lRet := .F.
		EndIf
	Else
		lRet := setRespError(404, STR0027) // "É necessário passar o modelo a ser consultado."
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET getF3
Busca a lista de dados da consulta do F3

@param  filtF3    Filtro adicional a ser aplicado, 
					'0' para não aplicar filtro
					'O0A_CCAUSA='001'condição sql para aplicar filtro
@param  xbAlias   Alias do campo procurado na SXB
@param  searchKey Código do registro a ser buscado
@return .T.       Lógico

@author Willian.Kazahaya
@since 21/05/2021

@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/0/NRBJUR
@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/O0A_CCAUSA=%27005%27/O0A
/*/
//-------------------------------------------------------------------
WSMETHOD GET getF3 PATHPARAM xbAlias, searchKey, filtF3  WSREST WsPfsApi
Local oResponse := JsonObject():New()
Local cXBAlias  := Self:xbAlias
Local cIdReg    := Self:searchKey
Local aOptions  := {}
Local nPos      := 0

	If Empty(cXBAlias)
		cXBAlias := ''
	EndIf

	aOptions := WPfsBscF3( cXBAlias ,,self:filtF3)

	Self:SetContentType("application/json")

	// Busca por código
	If !Empty(cIdReg)
		nPos := aScan(aOptions,{|x|  Lower(JurLmpCpo(cIdReg)) == Lower(JurLmpCpo(x[1])) })

		If(nPos > 0 ) 
			oResponse['value'] := aOptions[nPos][1]
			oResponse['label'] := jConvUTF8(aOptions[nPos][2])
		EndIf
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getF3List
Busca um determinado registro da lista do F3.
@param  filtF3    Filtro adicional a ser aplicado, 
					'0' para não aplicar filtro
					'O0A_CCAUSA='001'condição sql para aplicar filtro
@param  xbAlias    Alias do campo procurado na SXB
@param  filter     Filtro da busca de dados da lista F3.
@return .T.        Lógico

@author Willian.Kazahaya
@since 21/05/2021

@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/NRBJUR
@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/O0A_CCAUSA=%27005%27/O0A
/*/
//-------------------------------------------------------------------
WSMETHOD GET getF3List PATHPARAM xbAlias, filtF3 WSRECEIVE filter  WSREST WsPfsApi
Local oResponse := JsonObject():New()
Local cXBAlias  := Self:xbAlias
Local cFilter   := Self:filter
Local aOptions  := {}
Local nI        := 0

	If Empty(cXBAlias)
		cXBAlias := ''
	EndIf

	aOptions := WPfsBscF3( cXBAlias, cFilter, self:filtF3 )

	Self:SetContentType("application/json")
	oResponse['items'] := {} 

	For nI := 1 To Len(aOptions)
		Aadd(oResponse['items'], JsonObject():New())
		aTail(oResponse['items'])['value'] := aOptions[nI][1]
		aTail(oResponse['items'])['label'] := jConvUTF8(aOptions[nI][2])
		
		If(nI = 10)
			Exit
		EndIf

	Next nI

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET gtSx3Data
Busca os dados do SX3 do campo informado
@param campoChave - Path - Campo a ser buscado no SX3

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/congen/sx3/{campoChave}

@author Willian Kazahaya
@since 07/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtSx3Data PATHPARAM campoChave, MvcModel WSREST WSPfsApi
Local aFieldsMdl := {}
Local oResponse  := JsonObject():New()
Local oFieldMdl  := ""
Local cCampo     := Self:campoChave
Local cModelo    := Self:MvcModel
Local tamSx3Res  := Tamsx3(cCampo)
Local lRet       := .T.

	If (Len(tamSx3Res) < 3 .Or. Empty(cCampo))
		lRet := setRespError(400, STR0028) //"O campo informado não existe na tabela!"
	Else
		oFieldMdl := JW77StrMdl(cModelo, cCampo)

		If (Len(oFieldMdl['struct'][1]['fields']) > 0)
			aFieldsMdl := oFieldMdl['struct'][1]['fields'][1]:GetNames()


			oResponse['SX3'] := JsonObject():New()
			oResponse['SX3']['titulo'] := JConvUTF8(GetSx3Cache(UPPER(oFieldMdl['struct'][1]['fields'][1]['field']),'X3_TITULO'))
			oResponse['SX3']['tamanho'] := oFieldMdl['struct'][1]['fields'][1]['size']
			oResponse['SX3']['decimal'] := oFieldMdl['struct'][1]['fields'][1]['decimal']
			oResponse['SX3']['tipo'] := oFieldMdl['struct'][1]['fields'][1]['type']

			If (oResponse['SX3']['tipo'] == "L")
				lRet := setRespError(400, STR0033) //"Campos lógicos não podem ser utilizados como filtro!"
			ElseIf (!Empty(GetSx3Cache(cCampo, 'X3_CBOX')))
				lRet := setRespError(400, STR0034) // "Campos combo não podem ser utilizados como filtro!"
			ElseIf (!Empty(GetSx3Cache(cCampo, 'X3_F3')))
				lRet := setRespError(400, STR0035) //"Campos de consulta a outras tabelas não podem ser utilizados como filtro!"
			Else 
				Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
			EndIf
		Else
			lRet := setRespError(400,  I18N(STR0036 , {cCampo})) //"O campo #1 não existe no modelo selecionado!"
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET gtSx3Data
Busca os dados do SX3 do campo informado
@param campoChave - Path - Campo a ser buscado no SX3

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/congen/mvc/{nomeModelo}

@author Willian Kazahaya
@since 07/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtModelData PATHPARAM mvcModel WSREST WSPfsApi
Local oResponse := JsonObject():New()
Local cModelo   := Self:mvcModel
Local oModel    := Nil
Local lRet      := .T.

	If (Empty(cModelo))
		lRet := setRespError(400, STR0029) //"Informe um modelo!"
	Else
		cModelo := UPPER(cModelo)
		oResponse['MVC'] := JsonObject():New()
		
		oResponse['MVC']['codigo'] := cModelo

		oModel := FwLoadModel(cModelo)
		If (ValType(oModel) != "O")
			lRet := setRespError(400, STR0030) //"O modelo informado não é MVC!"
		Else
			oResponse['MVC']['descricao'] := JConvUTF8(oModel:GetDescription())
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST anxLdCreate
Cria o anexo na pasta do Spool para o LegalDesk

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/legaldesk/anexo/upload
/*/
//-------------------------------------------------------------------
WSMETHOD POST anxLdCreate WSREST WSPfsApi
Local oResponse  := JsonObject():New() 
Local oData      := Nil
Local nMsgCode   := 400
Local cMsgErro   := ""
Local cBody      := ""
Local cEntidade  := ""
Local cCodEnt    := ""
Local aInfoBody  := {}
Local lCadAnxNUM := .F.
Local lRet       := .T.

	cBody := Self:GetContent()
	aInfoBody := bdAnexos(cBody,  HTTPHeader("content-type"))
	lRet := crtAnexo(aInfoBody[1], aInfoBody[2])

	// Cria o anexo na Protheus_data
	If lRet
		oData := JSonObject():New()
		oData:FromJSon(aInfoBody[3])
		
		If Empty(cMsgErro)
			// Verifica se irá cadastrar na NUM
			lCadAnxNUM := !Empty(aInfoBody[3]) 
		
			If lCadAnxNUM .And. oData:ToJson() != "{}"
				If (!JJSonHasKey( oData, "entidade" ) .OR. !JJSonHasKey( oData, "codEntidade" ))
					cMsgErro := STR0038 // "A entidade e/ou código da entidade não foram informados"
					lRet := .F.
				EndIf

				If Empty(cMsgErro)
					cEntidade := oData['entidade']
					cCodEnt := oData['codEntidade']
					aResp := J026Anexar(cEntidade, xFilial(cEntidade), cCodEnt, "", aInfoBody[1], .T.)

					If (aResp[1]) 
						oResponse['result'] := STR0016 //"Anexo copiado com sucesso." 
						oResponse['entityNUM'] := JSonObject():New() 
						oResponse['entityNUM']['id']     := aResp[3] 
						oResponse['entityNUM']['status'] := "CREATED" 
					Else 
						oResponse['result'] := JConvUTF8(aResp[2]) // Erro da criação da NUM
						oResponse['entityNUM'] := JSonObject():New() 	
						oResponse['entityNUM']['status'] := "ERROR" 
						oResponse['entityNUM']['id']     := ""							
					EndIf
				EndIf
			Else 
				oResponse['result'] := STR0016 //"Anexo copiado com sucesso." 
				oResponse['entityNUM'] := JSonObject():New() 					
				oResponse['entityNUM']['id']     := ""
				oResponse['entityNUM']['status'] := "NOT_CREATED" 
			EndIf 
		EndIf
			
		oData:FromJSon("{}") 
		oData := NIL 
	EndIf

	If lRet
		Self:SetResponse(oResponse:toJson()) 
	Else 
		If !Empty(cMsgErro)
			SetRestFault(nMsgCode, JConvUTF8(cMsgErro)) 
		EndIf
	EndIf	

	oResponse:FromJSon("{}") 
	oResponse := NIL 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST anxCreate
Cria o anexo

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/anexo

@author Willian Kazahaya
@since  05/03/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST anxCreate WSREST WSPfsApi
Local lRet         := .T.
Local oRequest     := JsonObject():New()
Local cBody        := ""
Local cEntidade    := ""
Local cCodEnt      := ""
Local aInfoBod     := {}

	cBody := Self:GetContent()
	aInfoBod := bdAnexos(cBody,  HTTPHeader("content-type"))

	If (!Empty(aInfoBod[3]))
		oRequest:FromJson(aInfoBod[3])
		cCodEnt := oRequest['codEntidade']
		cEntidade := oRequest['entidade']

		lRet := crtAnexo(aInfoBod[1], aInfoBod[2])
		
		If (lRet)
			aResp := J026Anexar(cEntidade, xFilial(cEntidade), cCodEnt, "", aInfoBod[1], .T.)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE DeleteDoc
Deleta documentos anexados.

@param codDoc      - String com os NUM_COD concatenados por virgula

@example [Sem Opcional] DELETE -> http://127.0.0.1:9090/rest/WSPfsApi/anexo

@author Willian.Kazahaya
@since 06/01/2021
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE DeleteDoc PATHPARAM codDoc WSREST WSPfsApi
Local cCodDoc    := Self:codDoc
Local oResponse  := JsonObject():New()
Local lRet       := {}
Local aCodNUM    := StrToArray( cCodDoc, ',' )
Local nI         := 0
Local nIndexJSon := 0
Local cEntidade  := ""
Local cCodEnt    := ""
Local cNameDoc   := ""

	oResponse['operation'] := "DeleteDocs"
	Self:SetContentType("application/json")
	oResponse['attachments'] := {}

	for nI := 1 to Len(aCodNUM)
		cNameDoc  := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_DESC"))
		cEntidade := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_ENTIDA"))
		cCodEnt   := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_CENTID"))

		lRet := deleteDocs(aCodNUM[nI], cEntidade, cCodEnt)

		nIndexJSon++
		Aadd(oResponse['attachments'], JsonObject():New())

		If lRet
			oResponse['attachments'][nIndexJSon]['isDelete']    := .T.
			oResponse['attachments'][nIndexJSon]['codDocument'] := aCodNUM[nI]
			oResponse['attachments'][nIndexJSon]['nameDocument'] := JConvUTF8(cNameDoc)
		EndIf
	Next nI

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST cpAnalise
Realiza a analise do Arquivo PDF para extrair dados para o Titulo CP

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/leitura/pagar

/*/
//-------------------------------------------------------------------
WSMETHOD POST cpAnalise WSREST WSPfsApi
Local oResponse := JsonObject():New()
Local lRet      := .T.

	Self:SetContentType("application/json")

	If len(cFilant) < 8
		cFilant := PadR(cFilAnt,8)
	EndIf

	cArquivo := recebeFile(Self:GetContent(), HTTPHeader("content-type"))

	oResponse['texto'] := reqAPIPy(getText(cArquivo))

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT cnvPfsTxt
Converte o PDF para TXT

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/convert/txt

/*/
//-------------------------------------------------------------------
WSMETHOD PUT cnvPfsTxt WSREST WSPfsApi
Local oResponse := JsonObject():New()
Local oJSonBody := JsonObject():New()
Local cBody     := ""
Local itens     
Local lRet      := .T.

	cBody  := StrTran(Self:GetContent(),CHR(10),"")
	oJSonBody:fromJson(cBody)
	itens := oJSonBody:getNames()

	oResponse['texto'] := getText(oJsonBody:getJsonObject("file"))
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} bdAnexos
Extrai dados do Body

@param cBody - Corpo da requisição

@return [1] - Nome do Arquivo no Spool
        [2] - Dados para montagem do arquivo
        [3] - Dados adicionais 

@author Willian Kazahaya
@since  05/03/2021
/*/
//-------------------------------------------------------------------
Static Function bdAnexos(cBody, cContent)
Local cFileName := ""
Local cArquivo  := ""
Local cFile     := ""
Local cData     := ""
Local cSpool    := "\spool\"
Local cLimite   := SubStr(cContent,At("boundary=",cContent)+9)

	cFileName := SubStr(cBody,At('filename="',cBody)+10, At('"',SubStr(cBody,At('filename="',cBody)+10,200))-1)
	cFileName := decodeUTF8(AllTrim(cFileName))

	cArquivo  := cSpool + cFileName

	cFile := SubStr(SubStr(SubStr(cBody,;
	         At("Content-Type:",;
	         cBody)+12),;
	         At(Chr(10),;
	         SubStr(cBody,At("Content-Type:",cBody)+12))+3),;
	         1,;
	         At(cLimite,SubStr(SubStr(cBody,At("Content-Type:",cBody)+12),;
	         At(Chr(10),;
	         SubStr(cBody,At("Content-Type:",cBody)+12))+3))-5)

	cData := SubStr(cBody,At('Content-Disposition: form-data; name="data"',cBody)+46)
	cData := REPLACE(SubStr(cData,1,At(cLimite,cData)-5),CHR(10),'')

Return {cArquivo, cFile, cData}

//-------------------------------------------------------------------
/*/{Protheus.doc} crtAnexo
Cria o anexos na pasta da Spool

@param cArquivo - Nome do arquivo
@param cFile    - Conteúdo do arquivo

@return lRet    - Indica se o arquivo foi criado corretamente

@author Willian Kazahaya
@since  05/03/2021
/*/
//-------------------------------------------------------------------
Static Function crtAnexo(cArquivo, cFile)
Local nTamArquivo
Local nHDestino
Local nBytesSalvo

Default cArquivo := ""
Default cFile    := ""

	If (!Empty(cArquivo) .And. !Empty(cFile))
		nTamArquivo := Len(cFile)
		nHDestino   := FCREATE(cArquivo)

		If nHDestino >= 0
			nBytesSalvo := FWRITE(nHDestino, cFile, nTamArquivo)
			lRet := (nBytesSalvo == nTamArquivo) .And. FCLOSE(nHDestino)
		Else
			lRet := .F.
		EndIf
	Else
		If (Empty(cFile))
			SetRestFault(415, JConvUTF8(STR0031) ) // "O arquivo informado está vazio! Não foi possivel criar o arquivo no spool."
		Else
			SetRestFault(500, JConvUTF8(STR0017) ) // "Erro ao criar o arquivo no spool."
		EndIf
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} deleteDocs
Função responsável por chamar a função da classe de anexo para deletar os documentos

@param cCodDoc     - Codigo do documento para pesquisa de Doc especifica
@param entidade    - Alias da entidade
@param codEntidade - Codigo da entidade

@since 06/01/2021
/*/
//-------------------------------------------------------------------
Static Function deleteDocs(cCodDoc, cEntidade, cCodEnt)
	Local lRet    := .F.
	Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
	Local oAnexo  := JPFSGetAnx(cEntidade, cCodEnt)

	Do Case
		Case cParam == '2' //Base de Conhecimento
			lRet :=  oAnexo:DeleteNUM(cCodDoc)
		Case cParam == '3' //Fluig
			lRet :=  oAnexo:Excluir(cCodDoc)
	EndCase

	FwFreeObj(oAnexo)
	oAnexo := Nil
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getText(filePath)
Executa o pdfToText no arquivo pdf

@param filePath - Caminho do PDF a ser convertido

@since 06/01/2021
/*/
//-------------------------------------------------------------------
Static function getText(filePath)
	Local cMarca    := GetMark()
	Local cParams    := "-raw -nopgbrk -enc UTF-8"
	Local cNomeTxt  := "inicial_" + Lower(cMarca) + ".txt"
	Local cSpool    := "/spool/"
	Local cFile     := ""
	Local aLinhas   := {}
	Local nI        := 0
	Local cRootPath := GetSrvProfString("RootPath","") //Pega o conteúdo da chave RootPath do arquivo appserver.ini
	Local cCmd      := ""
	Local cInicTxt  := ""
	Local cMsgErro  := ""
	Local oTxt      := Nil
	Local cArquivo  := ""
	
	//Pega o nome do arquivo
	If rAt('\',cDirPdf) == 0
		cArquivo := SubStr(cDirPdf,rAt('/',cDirPdf)+1)
	Else
		cArquivo := SubStr(cDirPdf,rAt('\',cDirPdf)+1)
	Endif

	If At(':\',cDirPdf) > 0//valida se a inicial ja esta no root do servidor
		If CpyT2S(cDirPdf,cSpool) //Faz a cópia do arquivo para o servidor
			cDirPdf   := cRootPath + cSpool + cArquivo
		Endif
	Else
		cDirPdf := cRootPath + Replace(cDirPdf,'/','\') //substitui / por \ pois o \spool pode ser escrito das duas formas
	Endif
	
	//Monta o comando para ser executado via terminal
	DO CASE
		CASE "Windows" $ GetSrvInfo()[2]
			cDirPdf := cRootPath + cSpool + cArquivo
			cCmd    := 'pdftotext.exe ' + cParams + ' "'+cDirPdf+'" ' + cNomeTxt
			cFile   := cSpool + cNomeTxt

		CASE "Linux" $ GetSrvInfo()[2]
			cSpool  := "/spool/"
			cDirPdf := cRootPath + cSpool + cArquivo
			cCmd    := 'pdftotext ' + cParams + ' "'+cDirPdf+'" ' + cNomeTxt
			cFile   := cSpool + cNomeTxt
	END CASE
	//Monta o comando para ser executado via terminal

	cCmd    := 'pdftotext.exe ' + cParams + ' "'+filePath+'" ' + cNomeTxt
	cFile   := cSpool + cNomeTxt

	If  WaitRunSrv(cCmd, .T., cRootPath + cSpool) //Executa o comando para converter o PDF em TXT
		If File(cFile)
			oTxt := FWFileReader():New(cFile) //Cria um objeto file para realizar a leitura do arquivo TXT convertido
			If (oTxt:Open())
				If oTxt:hasLine()
					aLinhas := oTxt:getAllLines() //Transforma todas as linhas do arquivo em um array
					For nI := 1 To Len(aLinhas)
						cInicTxt += aLinhas[nI] + CRLF
					Next
					oTxt:Close()
				Else
					cMsgErro := JurMsgErro(STR0009,STR0010,STR0011)//("Não foi possível carregar o arquivo" ,"WSPfsApi","Verifique se o documento selecionado está correto") 
				Endif
			Endif
		Else 
			VarInfo("File não encontrado", cFile)
		Endif
	Else
		cMsgErro := JurMsgErro(STR0009,STR0010,STR0012) //("Não foi possível carregar o arquivo","WSPfsApi","Verifique se o executável pdftotext.exe se encontra na pasta do AppServer") 
	Endif

Return cInicTxt

//-------------------------------------------------------------------
/*/{Protheus.doc} recebeFile(cBody,cContent, oData)
Executa o pdfToText no arquivo pdf

@param filePath - Caminho do PDF a ser convertido

@since 06/01/2021
/*/
//-------------------------------------------------------------------
Static Function recebeFile(cBody,cContent, oData)
	Local nTamArquivo
	Local cFileName := ""
	Local nHDestino
	Local cLimite   := SubStr(cContent,At("boundary=",cContent)+9)
	Local cFile     := "" //conteúdo do arquivo
	Local cData     := "" //conteúdo extra
	Local cArquivo  := ""

	Default oData  := JSonObject():New()

	cFileName := SubStr(cBody,At('filename="',cBody)+10, At('"',SubStr(cBody,At('filename="',cBody)+10,200))-1)
	cFileName := decodeUTF8(AllTrim(cFileName))
	cArquivo  := "\spool\" + cFileName

	cFile := SubStr(SubStr(SubStr(cBody,;
		At("Content-Type:",;
		cBody)+12),;
		At(Chr(10),;
		SubStr(cBody,At("Content-Type:",cBody)+12))+3),;
		1,;
		At(cLimite,SubStr(SubStr(cBody,At("Content-Type:",cBody)+12),;
		At(Chr(10),;
		SubStr(cBody,At("Content-Type:",cBody)+12))+3))-5)

	cData := SubStr(cBody,At('Content-Disposition: form-data; name="data"',cBody)+46)
	if !Empty(cData)
		cData := REPLACE(SubStr(cData,1,At(cLimite,cData)-5),CHR(10),'')

		oData:fromJson(cData)
	Endif
	nTamArquivo := Len(cFile)

	nHDestino := FCREATE(cArquivo)
	nBytesSalvo := FWRITE(nHDestino, cFile,nTamArquivo)
	FCLOSE(nHDestino)

Return cArquivo

//-------------------------------------------------------------------
/*/{Protheus.doc} reqAPIPy(cBody)
Envia o texto gerado pelo pfsToText para a API Python 
Recebe a analise da API Python como resposta

@param cBody - Texto a ser analisado

@since 06/01/2021

/*/
//-------------------------------------------------------------------
Static function reqAPIPy(cBody)
Local cEndpoint := "http://localhost:5000/" // API por hora no localhost
Local oRest     := Nil
Local oJson     := Nil
Local aHeadOut  := {}
Local cResult   := ""
Local lRet      := .T.

	If !JurAuto()
		ProcRegua(0)
	Endif

	//Monta o cabeçalho da requisição
	aAdd(aHeadOut,'Content-Type: text/plain; Charset=UTF-8')
	aAdd(aHeadOut,'Cache-Control: no-cache')
	aAdd(aHeadOut,'Accept: */*')
	aAdd(aHeadOut,'User-Agent: Mozilla/5.0 (Compatible)')

	oRest := FWRest():New(cEndpoint)
	oRest:SetPath("/tituloCp")
	oRest:SetPostParams(cBody) //Adiciona o TXT convertido no body da requisição

	If oRest:Post(aHeadOut) //Faz a requisição para o endpoint
		cResult := DecodeUTF8(oRest:GetResult())
		oJson   := JsonObject():new()
		oJson:fromJson(cResult) //Transforma o retorno em objeto JSON
	Else
		//ConOut("Retorno da requisição" + oRest:GetLastError()) //"Retorno da requisição"
		lRet := .F.
	Endif
	
Return oJson

//-------------------------------------------------------------------
/*/{Protheus.doc} JRespDown
Realiza a transmissão do documento

@param oWs       - Objeto do WS
@param cPathDown - caminho do arquivo a ser transferido
@since 07/10/2020

/*/
//-------------------------------------------------------------------
Function JRespDown(oWs, cPathArq)
Local lRet      := .T.
Local cNomeArq  := ""
Local cBuffer   := ""
Local nHandle   := 0
Local nBytes    := 0

Default cPathArq := "''"

	If File(cPathArq)
		cNomeArq := SubStr(cPathArq, Rat("/",cPathArq)+1)
		cNomeArq := SubStr(cNomeArq, Rat("\",cNomeArq)+1)
		oWs:SetContentType("Application/octet-stream")
		oWs:SetHeader("Content-Disposition",'attachment; filename="'+cNomeArq+'"')
		nHandle := FOPEN(cPathArq)  // Grava o ID do arquivo

		If nHandle > -1
			While (nBytes := FREAD(nHandle, @cBuffer, 524288)) > 0      // Lê os bytes
				oWs:SetResponse(cBuffer)
			EndDo

			FCLOSE(nHandle)
			lRet := .T.
		Else
			SetRestFault(500, JConvUTF8(STR0013)) //"Erro ao ler o arquivo"
		EndIf
	Else
		lRet := .F.
		SetRestFault(404, JConvUTF8(STR0007)) //"Arquivo não existe."
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFSGetAnx(cEntidade, cCodEnt,cCodProc)
Função responsável por identificar qual anexo está sendo utilizado para instanciar a classe

@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade
@param cCodProc     - Codigo do processo

@since 06/01/2020

/*/
//-------------------------------------------------------------------
Function JPFSGetAnx(cEntidade, cCodEnt, cCodProc)
Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
Local oAnexo  := Nil
Local nIndice := 1
Local lEntPFS := .T. // Indica se é entidade do SIGAPFS

Default cEntidade := ""
Default cCodEnt   := ""
Default cCodProc  := ""

	Do Case
	Case cParam == '1'
		oAnexo := TJurAnxWork():New(STR0014, cEntidade, xFilial(cEntidade), cCodEnt, nIndice /* nIndice */ , .F., lEntPFS) // "WorkSite"
	Case cParam == '2'
		oAnexo := TJurAnxBase():NewTHFInterface(cEntidade, cCodEnt, cCodProc, lEntPFS) // "Base de Conhecimento"
	Case cParam == '3'
		oAnexo := TJurAnxFluig():New(STR0015, cEntidade, xFilial(cEntidade), cCodEnt, nIndice, .F.) // "Documentos em Destaque - Fluig"
	EndCase
return oAnexo

//-----------------------------------------------------------------
/*/{Protheus.doc} CreatePathDown
Função responsavel pela criação do caminho da pasta /thf/download/

@param cPathDown - Caminho para criar a pasta de download
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Static Function CreatePathDown(cPathDown)
	Local lRet     := .T.
	Local aAuxPath := nil
	Local cPathAux := ""
	Local cSlash   := If("Linux" $ GetSrvInfo()[2],'/','\')
	Local n1       := 0

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cPathDown := StrTran(cPathDown,"\","/")
	Endif

	If !ExistDir(cPathDown)
		aAuxPath := Separa(cPathDown,cSlash)
		For n1 := 1 To Len(aAuxPath)
			If Empty(aAuxPath[n1])
				loop
			Endif

			cPathAux += cSlash+aAuxPath[n1]

			If !ExistDir(cPathAux)
				If MakeDir(cPathAux) <> 0
					lRet := .F.
					exit
				Endif
			Endif
		Next

		//Redundancia para garantir que a pasta foi criada depois de realizar a criação
		lRet := lRet .and. ExistDir(cPathDown)

		aSize(aAuxPath,0)
		aAuxPath := nil
	EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Converte o Texto para UTF8, removendo os CRLF por || e removendo os espaços laterais

@param cValue - Valor a ser formatado
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function JConvUTF8(cValue)
	Local cReturn := ""
	cReturn := StrTran(EncodeUTF8(Alltrim(cValue)), CRLF, "||")
Return cReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} JW77StrMdl
Busca da estrutura de uma determinada rotina. 

@param  cRotina: Nome da rotina em mvc para buscar a estrutura
@return oResponse - Objeto json com a estrutura da rotina

@author Willian Kazahaya
@since 12/05/2021
/*/
//-------------------------------------------------------------------
Function JW77StrMdl(cRotina, cNomeCampo)
Local oResponse  := nil
Local oView      := nil
Local oModel     := nil
Local aModels    := nil
Local aMdlFields := nil
Local aViewField := nil
Local aAuxFlds   := nil
Local aAuxCbox   := nil
Local aOptions   := nil
Local cF3        := ''
Local lCanChange := .T.
Local lHasXENum  := .F.
Local nPos       := 1
local nI         := 1
local nX         := 1
local nZ         := 1

Default cRotina    := ''
Default cNomeCampo := ''

	If !Empty(cRotina)
		oView  := FwLoadView(cRotina)
		If ValType(oView) == "O"
			oModel := oView:GetModel()

			oResponse := JsonObject():New()
			oResponse['title']   := JConvUTF8(oView:GetDescription())
			oResponse['struct']  := {}
			oResponse['modelId'] := oModel:GetId()

			aModels := oModel:GetAllSubModels()

			For nI := 1 To Len(aModels)
				aViewField := {}

				aAdd(oResponse['struct'],JsonObject():New())
				aTail(oResponse['struct'])['id']   := aModels[nI]:GetId() //nome modelo
				aTail(oResponse['struct'])['type'] := aModels[nI]:ClassName() //Field/Grid
				aTail(oResponse['struct'])['fields'] := {}

				aAuxFlds   := aTail(oResponse['struct'])['fields']

				aMdlFields := aModels[nI]:GetStruct():GetFields()

				If aScan(oView:GetModelsId(),aModels[nI]:GetId()) > 0
					aViewField := aClone(oView:GetViewStruct(aModels[nI]:GetId()):GetFields())
				Endif
				
				If (!Empty(cNomeCampo) .And. aScan(aMdlFields, {|x| x[3] == cNomeCampo }) == 0)
					Loop
				EndIf

				For nX := 1 To Len(aMdlFields)
					If (Empty(cNomeCampo) .Or. (!Empty(cNomeCampo) .And. aMdlFields[nX][3] == cNomeCampo))
						cF3         := ''
						aOptions    := Nil
						lCanChange  := .T.
						nPos        := 0

						If !Empty(aMdlFields[nX][11])
							lHasXENum := AT('GETSXENUM',UPPER(GetCbSource(aMdlFields[nX][11]))) > 0
						Else
							lHasXENum := .F.
						Endif

						If Len(aViewField) > 0
							nPos      := aScan(aViewField,{|x| x[1] == aMdlFields[nX][3] })
						Endif
						
						If nPos > 0
							cF3        := aViewField[nPos][9]
							lCanChange := aViewField[nPos][10]

							If Len(aViewField[nPos][13]) > 0
								aOptions := {}

								For nZ := 1 to Len(aViewField[nPos][13])

									If Empty(aViewField[nPos][13][nZ]) .Or. At('=',aViewField[nPos][13][nZ]) == 0
										loop
									Endif

									aAdd(aOptions,JsonObject():New())
									aAuxCbox := Separa(aViewField[nPos][13][nZ],'=')
									aTail(aOptions)['value'] := aAuxCbox[1]
									aTail(aOptions)['label'] := JConvUTF8(aAuxCbox[2])
								Next
							EndIf
						EndIf

						aAdd(aAuxFlds,JsonObject():New())

						aTail(aAuxFlds)['field']         := aMdlFields[nX][3]
						aTail(aAuxFlds)['description']   := JConvUTF8(aMdlFields[nX][1])
						aTail(aAuxFlds)['type']          := aMdlFields[nX][4]
						aTail(aAuxFlds)['size']          := aMdlFields[nX][5]
						aTail(aAuxFlds)['decimal']       := aMdlFields[nX][6]
						aTail(aAuxFlds)['filter']        := AllTrim(cF3)
						aTail(aAuxFlds)['options']       := aOptions
						aTail(aAuxFlds)['isBrowse']      := getSx3Cache(aMdlFields[nX][3],'X3_BROWSE') == 'S'
						aTail(aAuxFlds)['isRequired']    := aMdlFields[nX][10]
						aTail(aAuxFlds)['isView']        := nPos > 0
						aTail(aAuxFlds)['isVirtual']     := getSx3Cache(aMdlFields[nX][3],'X3_CONTEXT') == 'V'
						aTail(aAuxFlds)['hasSequencial'] := lHasXENum
						aTail(aAuxFlds)['canChange']     := lCanChange
					EndIf
				Next
			Next

			oView:Destroy()
			FwFreeObj(oView)
		Else
			setRespError(404, STR0037 )//'O modelo informado não contem view configurada! Favor verificar.'
		Endif

		oView := nil
	Endif
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} WPfsBscF3
Retorna a lista de dados do F3 de campos customizados.

@param cF3:        Nome do XB_ALIAS que foi cadastrado para o campo customizado
@param cSearchKey: Conteúdo de busca
@param cFiltro:    Adiciona uma condição na busca dos dados
@return aRet - Lista com os dados de retorno do F3
@since 02/09/2020
/*/
//-------------------------------------------------------------------
Static Function WPfsBscF3( cF3, cSearchKey, cfiltro )
Local aArea      := GetArea()
Local cAlias     := ''
Local cQuery     := ''
Local cTabela    := ''
Local cChave     := ''
Local cLabel     := ''
Local cChvAuxSX5 := ''
Local cChaveSX5  := ''
Local nIndex     := 0
Local nPosCp     := 0
Local lContinua  := .F.
Local lSX5       := .F.
Local aRet       := {}
Local aStructF3  := {}

Default cFiltro = ""

	//-- Busca as informações da consulta no SXB
	If !Empty(cF3)

		DbSelectArea("SXB")
		DbSetOrder(1) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA

		cF3:= PadR( cF3, 6 )

		If DbSeek( cF3  + '1' + '01' )
			cTabela := ALLTRIM(SXB->XB_CONTEM)
		EndIf

		lSX5 := cTabela == 'SX5' .Or. Len(AllTrim(cF3)) == 2

		While (SXB->XB_ALIAS == cF3)

			If SXB->XB_TIPO == '5'
				If Empty(cChave)
					cChave := ALLTRIM(SXB->XB_CONTEM)
				else
					cChave += " + " + ALLTRIM(SXB->XB_CONTEM)
				EndIf

			ElseIf lSX5 .And. SXB->XB_TIPO == '2'
				nIndex := At('jursxb(', Lower(SXB->XB_CONTEM))

				If nIndex > 0
					cChvAuxSX5 := SubStr(SXB->XB_CONTEM, nIndex + 8) 
					cChaveSX5 += SubStr(cChvAuxSX5 , 0, At(',', Lower(cChvAuxSX5)) - 2)
				EndIf
			EndIf
			SXB->(DbSkip())
		End

		SXB->(DbCloseArea())

		If (!Empty(cTabela) .And. !Empty(cChave)) .Or. Len(AllTrim(cF3)) == 2
			If !lSX5
				aStructF3 := FWSX3Util():GetAllFields(cTabela, .F.)

				//-- Busca campos que possuem _NOME ou _DESC, senão usa terceira coluna da tabela
				nPosCp := aScan( aStructF3, { |x| '_NOME' $ x } )

				If nPosCp <= 0
					nPosCp := aScan( aStructF3, { |x| '_DESC' $ x } )
				EndIf

				If nPosCp > 0
					cLabel := aStructF3[nPosCp]
				Else
					cLabel := aStructF3[3]
				EndIf
			Else
				If Empty(cTabela) .And. Len(AllTrim(cF3)) == 2
					cTabela = 'SX5'
					cChave := 'X5_CHAVE'
					lContinua := .T.
				EndIf

				Do Case
					Case FwRetIdiom() == "pt-br"
						cLabel := 'X5_DESCRI'

					Case FwRetIdiom() == "en"
						cLabel := 'X5_DESCENG'

					Case FwRetIdiom() == "es"
						cLabel := 'X5_DESCSPA'
				EndCase
			EndIf

			//-- Tratamento para retorno da consulta
			cChave := STRTRAN(cChave, cTabela + "->")

			If Substr(cTabela, 1, 1) == "S"
				cFilS := Substr(cTabela, 2) + "_FILIAL"
				If Substr(cTabela, 2) == SubStr(cChave, 1, 2)
					lContinua := .T.
				EndIf

			Else
				cFilS := cTabela + "_FILIAL"
				If Substr(cTabela, 1, 3) == SubStr(cChave, 1, 3)
					lContinua := .T.
				EndIf
			EndIf

			cChave := STRTRAN(cChave, " + ", " || ")

			//-- Busca os dados
			If lContinua

				cQuery := " SELECT " + cChave + " CHAVE, "
				cQuery +=        " " + cLabel + " LABEL  "
				cQuery += " FROM " + RetSqlName(cTabela) + " "
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery +=     " AND " + cFilS + " = '" + xFilial(cTabela) + "' "

				If !Empty(cSearchKey)
					cSearchKey := StrTran(cSearchKey,'-',' ')
					cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey, .F.), '#', ''))
					cQuery +=     " AND " +  JurFormat(cLabel, .T., .T.) + " LIKE '%" + cSearchKey + "%' "
				EndIf

				If cFiltro != '0'
					cQuery += " AND " + cFiltro
				EndIf

				If lSX5
					cQuery += " AND X5_TABELA = '" + IIF(!Empty(cChaveSX5), cChaveSX5, cF3) + "'"
				EndIf

				cQuery := ChangeQuery(cQuery)

				cAlias := GetNextAlias()
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

				While !(cAlias)->(Eof())
					aAdd( aRet, { (cAlias)->(CHAVE), (cAlias)->(LABEL) } )
					(cAlias)->(DbSkip())
				End

				(cAlias)->(DbCloseArea())
			EndIf

		EndIf

	EndIf
	restArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} setRespError(nCodHttp, cErrMessage)
Padroniza a resposta sempre convertendo o texto para UTF-8

@param nCodHttp - Código HTTP
@param cErrMessage - Mensagem de erro a ser convertido

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function setRespError(nCodHttp, cErrMessage)
	SetRestFault(nCodHttp, JConvUTF8(cErrMessage), .T.)
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST fileImport
Importar aquivo de retorno do CNAB para o diretório do Banco na SEE

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/arqretorno

@author reginaldo.borges
@since  03/05/2023
/*/
//-------------------------------------------------------------------
WSMETHOD POST fileImport WSREST WSPfsApi
Local lRet        := .T.
Local oRequest    := JsonObject():New()
Local cBody       := ""
Local aCodEnt     := {}
Local aInfoBod    := {}
Local cChvBanco   := ""
Local cDirPag     := ""
Local cFilBanco   := ""
Local nTamCodBco  := TamSX3("EE_CODIGO")[1]
Local nTamAgeBco  := TamSX3("EE_AGENCIA")[1]
Local nTamContBco := TamSX3("EE_CONTA")[1]
Local nTamSubBco  := TamSX3("EE_SUBCTA")[1]

	cBody := Self:GetContent()
	aInfoBod := bdAnexos(cBody,  HTTPHeader("content-type"))

	If (!Empty(aInfoBod[3]))
		oRequest:FromJson(aInfoBod[3])
		cFilBanco   := oRequest["filialBanco"]
		aCodEnt     := oRequest['codBanco']
		cChvBanco   := PADR(aCodEnt[2], nTamCodBco) +;
						PADR(Substr(aCodEnt[4], 1, At('-', aCodEnt[4]) - 1 ), nTamAgeBco) +;
						PADR(Substr(aCodEnt[6], 1, At('-', aCodEnt[6]) - 1 ), nTamContBco) +;
						PADR(aCodEnt[8], nTamSubBco)
		cDirPag     := AllTrim(JurGetDados("SEE", 1, cFilBanco + cChvBanco, "EE_DIRPAG"))
		aInfoBod[1] := cDirPag + Substr(aInfoBod[1], Rat('\', aInfoBod[1]) + 1, Len(aInfoBod[1]))

		lRet := crtAnexo(aInfoBod[1], aInfoBod[2])
	EndIf

Return lRet
