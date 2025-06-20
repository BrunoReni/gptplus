#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTYPECHARTS.CH"

#DEFINE FORMSERVICE "form"
#DEFINE DATASERVICE "data"
#DEFINE ITEMSERVICE "itemService"

Static lA1PCustom := A1P->(ColumnPos("A1P_CUSTOM"))
Static lFATA902   := !Empty(GetAPOInfo("FATA902.PRW"))

/*/{Protheus.doc} TypeChart

API Cadastro de Tipos de Gr�ficos

@author		Squad CRM/Faturamento
@since		07/04/2020
/*/
WSRESTFUL TypeChart DESCRIPTION STR0001 // #"DashBoard Protheus"
  WSDATA IDTypeChart AS STRING	OPTIONAL
	WSDATA Page				   AS INTEGER	OPTIONAL
	WSDATA PageSize		   AS INTEGER	OPTIONAL

  WSMETHOD GET tgs ;
  DESCRIPTION STR0002 ; //#"Retorna os Tipos de Gr�ficos Cadastrados"
  WSSYNTAX "/TypeChart/TypeChart/" ;
  PATH "/TypeChart/TypeChart/";
  PRODUCES APPLICATION_JSON

  WSMETHOD GET tg ;
  DESCRIPTION STR0003 ; //#"Retorna um Tipo de Gr�fico Espec�fico"
  WSSYNTAX "/TypeChart/TypeChart/{IDTypeChart}" ;
  PATH "/TypeChart/TypeChart/{IDTypeChart}";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST tg ;
  DESCRIPTION STR0004 ; //"Insere um novo Tipo de Gr�fico"
  WSSYNTAX "/TypeChart/TypeChart/" ;
  PATH "/TypeChart/TypeChart/" ;
  TTALK "v1"

  WSMETHOD POST vtg ;
  DESCRIPTION STR0025 ; //#"Valida os endpoints a serem inclu�dos/alterados"
  WSSYNTAX "/TypeChart/TypeChart/valid" ;
  PATH "/TypeChart/TypeChart/valid" ;
  TTALK "v1"

  WSMETHOD PUT tg ;
  DESCRIPTION STR0005 ; //"Altera um Tipo de Gr�fico"
  WSSYNTAX "/TypeChart/TypeChart/{IDTypeChart}" ;
  PATH "/TypeChart/TypeChart/{IDTypeChart}" ;
  TTALK "v1"

  WSMETHOD DELETE tg ;
  DESCRIPTION STR0006 ; //"Exclui um Tipo de Gr�fico"
  WSSYNTAX "/TypeChart/TypeChart/{IDTypeChart}" ;
  PATH "/TypeChart/TypeChart/{IDTypeChart}" ;
  TTALK "v1"

ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET tgs
Retorna os dados do Gr�fico

@author Nairan Alves/D�bora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tgs WSRECEIVE JsonFilter WSSERVICE TypeChart

  Local aRet        := {}
  Local cError		  := STR0007  //#"Erro na Requisi��o"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

  Self:SetContentType("application/json")

  aRet := MntQuery()

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])

  oCoreDash:SetFields(DePara(Self:aQueryString))
  oCoreDash:SetApiQstring(Self:aQueryString)
  lRet := oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToObjectJson())
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 404,  FWhttpEncode(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tg
Retornar apenas um tipo de Painel

@author Nairan Alves/D�bora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tg WSRECEIVE IDTypeChart WSSERVICE TypeChart

  Local aRet        := {}
  Local aFilter     := {}
  Local cError		  := STR0007  //#"Erro na Requisi��o"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

  Self:SetContentType("application/json")

  aRet := MntQuery()

  aAdd(aFilter, {" A1P.A1P_ID = '" + self:IDTypeChart + "' " })

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  oCoreDash:SetApiFilter(aFilter)

  oCoreDash:SetFields(DePara(Self:aQueryString))
  oCoreDash:SetApiQstring(Self:aQueryString)
  lRet := oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToSingleObject())
	Else
		SetRestFault( 404,  FwHttpEncode(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Post tg
Realiza a inclus�o de um Tipo de Gr�fico

@param oCoreDash, objeto, Objeto respons�vel pela montagem do json
@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST tg WSSERVICE TypeChart
  Local lRet := .T.
  lRet := PostFunc(Self, .F.)
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} Post vtg
Realiza a valida��o dos endpoints de um Tipo de Gr�fico a ser inclu�do/alterado

@param oCoreDash, objeto, Objeto respons�vel pela montagem do json
@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//----------------------------------------------------------------------------------
WSMETHOD POST vtg WSSERVICE TypeChart
  Local lRet := .T.
  lRet := PostFunc(Self, .T.)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT tg
Alterar um Tipo de Gr�fico

@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD PUT tg WSRECEIVE IDTypeChart WSSERVICE TypeChart

	Local cBody 	   := Self:GetContent()
	Local lRet       := .F.
  Local oCoreDash  := CoreDash():New()
  Local cURL       := Self:GetURL()
  Local cAuth      := Self:GetHeader('Authorization')
  Local aDetailErr := {}
  Local lIsCustom  := Nil

  Default self:IDTypeChart := ""

  If !lFATA902 .Or. !lA1PCustom
    lRet := .F.
    SetRestFault(501, FwHttpEncode("Not Implemented"), .T., , FwHttpEncode(STR0008 + "put" + STR0009)) //#"O m�todo " #" n�o est� completamente implementado nesta API neste ambiente, pois o fonte FATA902 n�o est� contido no RPO. Ou o campo A1P_CUSTOM n�o foi criado no banco de dados. Atualize o seu RPO e execute o UPDDISTR com o patch da expedi��o cont�nua mais recente."
    oCoreDash:Destroy()
    FwFreeObj(aDetailErr)
    Return lRet
  EndIf  

  // Validar se a altera��o eh de um tipo de card n�o customizado j� existente na base de dados
  If (!Empty(self:IDTypeChart))
    lIsCustom := isCstmInDB(xFilial("A1P") + self:IDTypeChart)
  EndIf

  // Validar se a altera��o eh de um tipo de card customizado j� existente na base de dados para um n�o customizado
  // Ou se � um tipo de card que nem existe na base de dados (ValType(lIsCustom) == "U")
  If ValType(lIsCustom) == "U" .Or. lIsCustom
    lIsCustom := isCstmInJs(cBody)
    If ValType(lIsCustom) == "U"
      lRet := .F.
      SetRestFault(400,  FwHttpEncode(STR0014) )  //#"Falha ao realizar a leitura do json enviado no body da requisi��o."
      oCoreDash:Destroy()
      FwFreeObj(aDetailErr)
      Return lRet
    EndIf
  EndIf

  // Validar se o tipo de gr�fico e � padr�o
  If !lIsCustom
    lRet := .F.
    SetRestFault(400, FwHttpEncode(STR0015))  //#"Tipo de gr�fico padr�o n�o pode ser inclu�do/alterado por este servi�o."
    oCoreDash:Destroy()
    FwFreeObj(aDetailErr)
    Return lRet
  EndIf

  // Validacao dos EndPoints informados no body
  lRet := vEndPoints(cBody, cURL, @aDetailErr, cAuth)
  If !lRet
    SetRestFault(400, FwHttpEncode("Bad Request"), .T., , FwHttpEncode(STR0011), , aDetailErr)  //#"Erro na valida��o dos endpoints enviados na requisi��o"
    oCoreDash:Destroy()
    FwFreeObj(aDetailErr)
    Return lRet
  EndIf

  If !Empty(self:IDTypeChart)
    oCoreDash:SetFields(DePara(Self:aQueryString))
    lRet := oCoreDash:SetUpsertData("A1P", xFilial("A1P") + self:IDTypeChart, cBody)
  EndIf

  If lRet
    self:IDTypeChart := A1P->A1P_ID
    self:GET_TG(self:IDTypeChart)
  Else
    SetRestFault(403, FwHttpEncode(oCoreDash:GetJsonError()))
  Endif

  oCoreDash:Destroy()
  FwFreeObj(aDetailErr)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE tp
Deleta um Tipo de Gr�fico

@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE tg WSRECEIVE IDTypeChart WSSERVICE TypeChart

	Local lRet           := .F.
  Local oJsonPositions := JsonObject():New()
  Local cKey           := ""

  Default self:IDTypeChart := ""

  If !lA1PCustom
    lRet := .F.
    SetRestFault(501, FwHttpEncode("Not Implemented"), .T., , FwHttpEncode(STR0008 + "delete" + STR0016))  //#"O m�todo " #" n�o est� completamente implementado nesta API deste ambiente, pois o campo A1N_CUSTOM n�o foi criado no banco de dados. Atualize o seu RPO e execute o UPDDISTR com o patch da expedi��o cont�nua mais recente."
    FWFreeObj(oJsonPositions)
    Return lRet
  EndIf

  If !Empty(self:IDTypeChart)
    A1P->(DbSetOrder(1))
    cKey := xFilial("A1P") + self:IDTypeChart
    If A1P->(DbSeek(cKey))
      If !isCstmInDB(cKey)
        lRet := .F.
        SetRestFault(400, FwHttpEncode(STR0017))  //#"Tipo de gr�fico padr�o n�o pode ser exclu�do por este servi�o."
        FWFreeObj(oJsonPositions)
        Return lRet
      ElseIf hasChart(self:IDTypeChart)
        lRet := .F.
        SetRestFault(400, FwHttpEncode(STR0026))  //#"Tipo de Gr�fico n�o pode ser exclu�do, pois est� relacionado � um Gr�fico."
        FWFreeObj(oJsonPositions)
        Return lRet
      EndIf
      lRet := .T.
      A1P->(RecLock("A1P", .F.))
      A1P->(DbDelete())
      A1P->(MsUnLock())
    Else
      lRet := .F.
      SetRestFault( 404, FwHttpEncode(STR0018) )  //#"Tipo de gr�fico n�o pode ser deletado, pois n�o foi encontrado."
      FWFreeObj(oJsonPositions)
      Return lRet
    EndIf
  EndIf

	oJsonPositions['response'] := STR0024 + self:IDTypeChart + STR0019 //#"Id " #" exclu�do com sucesso."
	Self:SetResponse( EncodeUtf8(oJsonPositions:ToJson()) )

  FWFreeObj(oJsonPositions)
Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} DePara
Realiza o De/Para entre os objetos do Json e os campos do Protheus
@param aQueryStr, array, array com os querystrings enviados na requisicao
@author Nairan Alves/D�bora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//--------------------------------------------------------------------------
Static Function DePara(aQueryStr)
  Local aCampos    := {}
  Local nPosFields := 0
  Local cFields    := ""
  Local cTitle     := "titletype"
  
  // Tratamento para manter compatibilidade do atributo do titulo com versoes anteriores do frontend
  nPosFields := AScan(aQueryStr, {|qryStr| UPPER(qryStr[1]) == "FIELDS"})
  If !Empty(nPosFields)
    cFields := StrTran(UPPER(aQueryStr[nPosFields][2]), " ", "")
  EndIf
  If At("TITLE", cFields) > 0 .And. At("TITLETYPE", cFields) == 0
    cTitle := "title"
  EndIf

  aCampos := {;
    {"branch"         , "A1P_FILIAL"  },;
    {"id"             , "A1P_ID"      },;
    {"form"           , "A1P_SRVFOR"  },;
    {"data"           , "A1P_SRVDAT"  },;
    {"filter"         , "A1P_SRVFIL"  },;
    {cTitle           , "A1P_TITULO"  },;
    {"level"          , "A1P_MAXNIV"  },;
    {"headerService"  , "A1P_CABSER"  },;
    {"itemService"    , "A1P_ITSERV"  };  
  }

  If lA1PCustom
    AAdd(aCampos, {"custom" , "A1P_CUSTOM"})
  EndIf
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQuery
Monta a query respons�vel por trazer os itens utilizados no Painel

@param oCoreDash, objeto, Objeto respons�vel pela montagem do json
@author Nairan Alves/D�bora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery(cSelect)
  Local cQuery  := ""
  Local cWhere  := ""

  Default cSelect := " A1P_FILIAL, A1P_ID, A1P_SRVFOR, A1P_SRVDAT, A1P_SRVFIL, A1P_TITULO, A1P_MAXNIV, A1P_ITSERV"

  If lA1PCustom
    cSelect += ", A1P_CUSTOM"
  EndIf

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("A1P") + " A1P "

  cWhere := " A1P.D_E_L_E_T_ = ' ' AND A1P.A1P_FILIAL = '" + xFilial("A1P") + "'

Return {cQuery, cWhere}

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vEndPoints
Funcao que verifica e trata o retorno das funcoes de validacao dos EndPoints enviados no body da requisicao
@param cBody      , character, Body enviado na requisicao
@param cURL       , character, URL para testar os endpoints enviados no body
@param aDetailErr , array    , Array com o detalhe das valida��es n�o atendidas pelos endPoints
@param cAuth      , character, Conteudo do usu�rio e senha para HTTP Basic Authentication
@author Rafael Mota Previdi
@since 13/01/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function vEndPoints(cBody, cURL, aDetailErr, cAuth)
  Local lValid     := .T.
  Local aEndPoints := {}
  // Preparar os dados a serem enviados sobre cada endPoint a ser validado
  // 1 - form
  AAdd(aEndPoints, {FORMSERVICE /*Tag do EndPoint no body*/, "GET" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "items"   /*Atributo*/,"A" /*Tipo*/} ;
                                    }
  // 2 - data
  AAdd(aEndPoints, {DATASERVICE /*Tag do EndPoint no body*/, "POST" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "items"   /*Atributo*/,"A" /*Tipo*/} ;
                                    }
  // 3 - itemService
  AAdd(aEndPoints, {ITEMSERVICE /*Tag do EndPoint no body*/, "POST" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "header"  /*Atributo*/,"A" /*Tipo*/}, ;
                                      { "items"   /*Atributo*/,"A" /*Tipo*/}, ;
                                      { "hasNext" /*Atributo*/,"L" /*Tipo*/} ;
                                    }
  // Validacao dos EndPoints informados no body
  aDetailErr := vEndPntsDB(cBody, cURL, aEndPoints, cAuth)
  If Len(aDetailErr) > 0
    lValid := .F.
  EndIf

  FwFreeObj(aEndPoints)
Return lValid

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isCstmInJs
Funcao que verifica o tipo de gr�fico � customizado ou n�o olhando para o json do body da requisicao
@param cBody      , character , Body enviado na requisicao
@author Rafael Mota Previdi
@since 13/01/2021
@version Protheus 12
@return lIsCustom, boolean, indica se o tipo de gr�fico em quest�o � customizado ou n�o
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function isCstmInJs(cBody)
  Local lIsCustom := .F.
  Local jBody    := JsonObject():new()

  jBody:fromJson(cBody)
  lIsCustom := IIf(ValType(jBody["custom"]) == "L", jBody["custom"], Nil)
  FWFreeObj(jBody)
Return lIsCustom

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isCstmInDB
Funcao que verifica o tipo de gr�fico � customizado ou n�o olhando para o registro na base dados
@param cKey , character, Chave de pesquisa do tipo de card na base de dados
@author Rafael Mota Previdi
@since 13/01/2021
@version Protheus 12
@return lIsCustom, boolean, indica se o tipo de card em quest�o � customizado ou n�o
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function isCstmInDB(cKey)
  Local lIsCustom := Nil
  If (A1P->(A1P_FILIAL + A1P_ID) == cKey .Or. A1P->(DBSeek(cKey)))
    lIsCustom := A1P->A1P_CUSTOM
  EndIf
Return lIsCustom

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PostFunc
Funcao que � executada para os m�todos POST da API.
@param oRestFul , object , Objeto respons�vel pelos dados e controles da requisi��o
@param lValid   , boolean, Indica se � somente uma valida��o dos endpoints ou se � para persistir os dados
@author Rafael Mota Previdi
@since 18/01/2021
@version Protheus 12
@return lRet, boolean, indica o resultado do processamento da fun��o onde .T.=Sucesso e .F.=Falha
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function PostFunc(oRestFul, lValid)
  Local cBody 	  	:= oRestFul:GetContent()
	Local lRet        := .T.
  Local oCoreDash  := Nil
  Local cURL       := oRestFul:GetURL()
  Local cAuth      := oRestFul:GetHeader('Authorization')
  Local aDetailErr := {}
  Local lIsCustom   := Nil

  If !lFATA902 .Or. !lA1PCustom
    lRet := .F.
    SetRestFault(501, FwHttpEncode("Not Implemented"), .T., , FwHttpEncode(STR0008 + "post" + STR0009))  //#"O m�todo " #" n�o est� completamente implementado nesta API neste ambiente, pois o fonte FATA902 n�o est� contido no RPO. Ou o campo A1P_CUSTOM n�o foi criado no banco de dados. Atualize o seu RPO e execute o UPDDISTR com o patch da expedi��o cont�nua mais recente."
    FwFreeObj(aDetailErr)
    Return lRet
  EndIf  

  // Validar se a inclusao eh de um tipo de gr�fico n�o customizado
  lIsCustom := isCstmInJs(cBody)
  If ValType(lIsCustom) == "L" .And. !lIsCustom
    lRet := .F.
    SetRestFault(400, FwHttpEncode(STR0010))  //#"Tipo de gr�fico padr�o n�o pode ser inclu�do por este servi�o."
    FwFreeObj(aDetailErr)
    Return lRet
  EndIf

  // Validacao dos EndPoints informados no body
  lRet := vEndPoints(cBody, cURL, @aDetailErr, cAuth)
  If !lRet
    SetRestFault(400, FwHttpEncode("Bad Request"), .T., , FwHttpEncode(STR0011), , aDetailErr)  //#"Erro na valida��o dos endpoints enviados na requisi��o."
    FwFreeObj(aDetailErr)
    Return lRet
  EndIf

  If lValid
    oRestFul:SetResponse(cBody)
  Else
    oCoreDash := CoreDash():New()
    oCoreDash:SetFields(DePara(oRestFul:aQueryString))
    lRet := oCoreDash:SetUpsertData("A1P", Nil, cBody)

    If lRet
      oRestFul:IDTypeChart := A1P->A1P_ID
      oRestFul:GET_TG(oRestFul:IDTypeChart)
    Endif
    oCoreDash:Destroy()
  EndIf
  FwFreeObj(aDetailErr)
Return lRet

/*/{Protheus.doc} hasChart
  Fun��o que verifica se existe um gr�fico (A1Q) vinculado ao tipo de gr�fico enviado (A1P)
  @type  Static Function
  @author D�bora Constantino / Squad CRM/FAT
  @since 18/02/2022
  @version 1.0
  @param idTypeChart, Character, Id do tipo de gr�fico a ser pesquisado na A1Q
  @return .T., Boolean, Retorna se o tipo de gr�fico foi encontrado ou n�o na A1Q
  @example
  hasChart("000031")
/*/
Static Function hasChart(idTypeChart as Character)
  Local lRet := .F.
  Local cKey := xFilial("A1Q") + idTypeChart

  
  If FWSIXUtil():ExistIndex("A1Q", "2")
    A1Q->(DbSelectArea("A1Q"))
    A1Q->(DbSetOrder(2))
    lRet := A1Q->(DbSeek(cKey))
  Else
    lRet := .T.
  EndIf

Return lRet
