#include 'totvs.ch'
#INCLUDE "RESTFUL.CH"
#INCLUDE "TMSCARDS.CH"

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSRESTFUL tmschart008 DESCRIPTION STR0085  //-- "Documentos a Vencer x Praz de Entrega"

	WSDATA JsonFilter       AS STRING	OPTIONAL
	WSDATA drillDownFilter  AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL

	WSMETHOD GET form ;
		DESCRIPTION "Carrega os campos que ser�o apresentados no formul�rio" ; // #"Carrega os campos que ser�o apresentados no formul�rio"
	WSSYNTAX "/charts/form/" ;
		PATH "/charts/form";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST retdados ;
		DESCRIPTION "Carrega os itens" ; // # "Carrega os itens"
	WSSYNTAX "/charts/retdados/{JsonFilter}" ;
		PATH "/charts/retdados";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST itemsDetails ;
		DESCRIPTION "Carrega os Itens Utilizados para Montagem do itens" ; // # "Carrega os Itens Utilizados para Montagem do itens"
	WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
		PATH "/charts/itemsDetails";
		PRODUCES APPLICATION_JSON

ENDWSRESTFUL

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD GET form WSSERVICE tmschart008

	Local oResponse  := JsonObject():New()
	Local oCoreDash  := CoreDash():New()

	oCoreDash:SetPOForm(STR0025 , "charttype"       , 6   , STR0025 , .T., "string" , oCoreDash:SetPOCombo({{"bar",STR0026}}))
	oCoreDash:SetPOForm(STR0027 , "datainicio"      , 6   , STR0028 , .T., "date")
	oCoreDash:SetPOForm(""      , "datafim"         , 6   , STR0029 , .T., "date")
	
	oResponse  := oCoreDash:GetPOForm()

	Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL tmschart008

	Local aHeader     := {}
	Local aItems      := {}
	Local aRet        := {}
	Local aFilter     := {}
	Local lRet	      := .T.
	Local cSelect     := ""
	Local cFilter     := ""
	Local cError	  := STR0062 //-- Erro na requisi��o
	Local cBody       := DecodeUtf8(Self:GetContent())
	Local oCoreDash   := CoreDash():New()
	Local oBody       := JsonObject():New()
	Local oJsonFilter := JsonObject():New()
	Local oJsonDD     := JsonObject():New()
	Local nLenFilter  := 0
	Local nX          := 0

	If !Empty(cBody)
		oBody:FromJson(cBody)

		If ValType(oBody["chartFilter"]) == "J"
			oJsonFilter := oBody["chartFilter"]
		EndIf

		If ValType(oBody["detailFilter"]) == "A"
			oJsonDD := oBody["detailFilter"]
		EndIf
	EndIf

	Self:SetContentType("application/json")

	If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
		If Len(oJsonDD) == 0
			
			aHeader := {;
				{"filori"	    ,  FWX3Titulo('DTQ_FILORI') ,"link"     ,,.T.,.T.     },;    // #"Data de Emiss�o"
				{"viagem"	    ,  FWX3Titulo('DTQ_VIAGEM') ,     		,,.T.,.T.     },;        // #"Produto"
				{"fildoc"	    ,  FWX3Titulo('DT6_FILDOC') ,           ,,.T.,.T.     },;      // #"Grupo de Produto"
				{"doc"	        ,  FWX3Titulo('DT6_DOC') 	,           ,,.T.,.T.     },;    // #"Cliente"
				{"serie"        ,  FWX3Titulo('DT6_SERIE') 	,           ,,.T.,.T.     },;
                {"clirem"       ,  FWX3Titulo('DT6_CLIREM') ,           ,,.T.,.T.     },;    // #"Loja"
				{"lojrem"       ,  FWX3Titulo('DT6_LOJREM') ,           ,,.T.,.T.     },;
				{"nomrem"       ,  FWX3Titulo('DT6_NOMREM') ,           ,,.T.,.T.     },;    // #"CFOP"
				{"clides"       ,  FWX3Titulo('DT6_CLIDES') ,           ,,.T.,.T.     },; 
                {"lojdes"       ,  FWX3Titulo('DT6_LOJDES') ,           ,,.T.,.T.     },; 
                {"nomdes"       ,  FWX3Titulo('DT6_NOMDES') ,           ,,.T.,.T.     }; 
                }

            aItems := {;
                {"filori"   , "DTQ_FILORI"          },;
                {"viagem"   , "DTQ_VIAGEM"          },;
                {"fildoc"   , "DT6_FILDOC"          },;
                {"doc"      , "DT6_DOC"             },;
                {"serie"    , "DT6_SERIE"           },;
                {"przent"   , "DT6_PRZENT"          },;
                {"clirem"   , "DT6_CLIREM"          },;
                {"lojrem"   , "DT6_LOJREM"          },;
                {"nomrem"   , "DT6_NOMREM"          },;
                {"clides"   , "DT6_CLIDES"          },;
                {"lojdes"   , "DT6_LOJDES"          },;
                {"nomdes"   , "DT6_NOMDES"          };
                }

			cSelect := " DTQ_FILORI, DTQ_VIAGEM, DT6_FILDOC, DT6_DOC , DT6_SERIE ,  DT6_PRZENT, DT6_CLIREM , DT6_LOJREM , SA1REM.A1_NREDUZ AS DT6_NOMREM , DT6_CLIDES, DT6_LOJDES , SA1DES.A1_NREDUZ AS DT6_NOMDES  "

			cFilter += FilterForm(oJsonFilter) 
			oCoreDash:SetFields(aItems) 
			oCoreDash:SetApiQstring(Self:aQueryString) 
			aFilter := oCoreDash:GetApiFilter() 
			nLenFilter := Len(aFilter)
			If nLenFilter > 0
				For nX := 1 to nLenFilter
					cFilter += " AND " + aFilter[nX][1]
				Next
			EndIf

			aRet := QueryDTQ(cSelect,cFilter)
			oCoreDash:SetQuery(aRet[1])
			oCoreDash:SetWhere(aRet[2])
			oCoreDash:SetGroupBy(aRet[3])

		Endif
	EndIf

	oCoreDash:BuildJson()

	If lRet
		oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
	FreeObj(oJsonDD)
	FreeObj(oJsonFilter)
	FreeObj(oBody)

	aSize(aRet, 0)
	aSize(aItems, 0)
	aSize(aHeader, 0)

Return lRet

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE tmschart008

	Local oResponse := JsonObject():New()
	Local oCoreDash := CoreDash():New()
	Local oJson     := JsonObject():New()

	oJson:FromJson(DecodeUtf8(Self:GetContent()))

	retDados(@oResponse, oCoreDash, oJson)

	Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

	oResponse := Nil
	FreeObj( oResponse )

	oCoreDash:Destroy()
	FreeObj( oCoreDash )

Return .T.

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function retDados(oResponse, oCoreDash, oJson)

	Local aData     := {}
	Local aDataFim  := {}
	Local aCab      := {}
	Local aClrChart := oCoreDash:GetColorChart() //cor do gr�fico
	Local cFilter   := ""
	Local nX        := 0
	Local nAuxClr	:= 0

	cFilter := FilterForm(oJson) 

	If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0

		aAdd(aCab,STR0082 + " 2 " + STR0077) // A VENCER 2 DIAS
		aAdd(aCab,STR0082 + " 5 " + STR0077)
		aAdd(aCab,STR0082 + " 7 " + STR0077)
		aAdd(aCab,STR0082 + " 7 " + STR0077 + " " +STR0101 ) //-- A VENCER 7 DIAS OU MAIS

		//-- A vencer
		aAdd(aData, RetDocsVenc( dDataBase 		, dDataBase + 2  ) )
		aAdd(aData, RetDocsVenc( dDataBase + 3 	, dDataBase + 5 ) )
		aAdd(aData, RetDocsVenc( dDataBase + 6 , dDataBase + 7 ) )
		aAdd(aData, RetDocsVenc( dDataBase + 7 , dDataBase + 365 ) )
		
		For nX := 1 To Len(aData)
			nAuxClr++
			oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nX + nAuxClr][3] /*"cColorBackground"*/ )
		Next  

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({STR0085},,/*lCurrency*/.F.,, STR0085  )) //-- "Documentos X Prazos de Entrega"
	EndIf

	oResponse["items"] := aDataFim

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function QueryDTQ(cSelect as Char, cFilter as Char)

	Local cQuery  := ""
	Local cWhere  := ""
	Local cGroup  := ""

	Default cSelect := " DTQ_FILORI, DTQ_VIAGEM, DT6_FILDOC, DT6_DOC , DT6_SERIE ,  DT6_PRZENT, DT6_CLIREM , DT6_LOJREM , SA1REM.A1_NREDUZ AS DT6_NOMREM , DT6_CLIDES, DT6_LOJDES , SA1DES.A1_NREDUZ AS DT6_NOMDES"
	Default cFilter := ""

	cQuery  := " SELECT " + cSelect + " FROM " + RetSqlName("DTQ") + " DTQ "
    cQuery  += " INNER JOIN " + RetSqlName("DUD") + " DUD "
    cQuery  += " ON DUD_FILIAL  = '" + xFilial("DUD") + "' "
    cQuery  += " AND DUD_FILORI     = DTQ_FILORI "
    cQuery  += " AND DUD_VIAGEM     = DTQ_VIAGEM "
    cQuery  += " AND DUD.D_E_L_E_T_ = '' "
    cQuery  += " INNER JOIN " + RetSqlName("DT6") + " DT6 "
    cQuery  += " ON DT6_FILIAL      = '" + xFilial("DT6") + "' "
    cQuery  += " AND DT6_FILDOC     = DUD_FILDOC "
    cQuery  += " AND DT6_DOC        = DUD_DOC "
    cQuery  += " AND DT6_SERIE      = DUD_SERIE "
    cQuery  += " AND DT6_STATUS     <> '7' "
    cQuery  += " AND DT6_PRZENT     >= '" + DToS(dDataBase) + "' "
    cQuery  += " AND DT6.D_E_L_E_T_ = '' "
    cQuery  += " LEFT JOIN " + RetSqlName("SA1") + " SA1REM "
    cQuery  += " ON SA1REM.A1_FILIAL       = '" + xFilial("SA1") + "' "
    cQuery  += " AND SA1REM.A1_COD         = DT6_CLIREM "
    cQuery  += " AND SA1REM.A1_LOJA        = DT6_LOJREM "
    cQuery  += " AND SA1REM.D_E_L_E_T_ = '' "
    cQuery  += " LEFT JOIN " + RetSqlName("SA1") + " SA1DES "
    cQuery  += " ON SA1DES.A1_FILIAL       = '" + xFilial("SA1") + "' "
    cQuery  += " AND SA1DES.A1_COD         = DT6_CLIDES "
    cQuery  += " AND SA1DES.A1_LOJA        = DT6_LOJDES "
    cQuery  += " AND SA1DES.D_E_L_E_T_ = '' "

	cWhere := " DTQ_FILIAL = '" + xFilial("DTQ") + "' "
	cWhere	+= " AND DTQ_FILORI	= '" + cFilAnt + "' "
	If !Empty(cFilter)
		cWhere += cFilter
	Endif

	cWhere += " AND DTQ.D_E_L_E_T_ = ' ' "
	
Return { cQuery, cWhere, cGroup }

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FilterForm(oJson)
Local cFilter 	:= ""

Return cFilter


/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetDocsVenc( dDataDe , dDataAte , cSerie ) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default dDataDe	    := dDataBase 
Default dDataAte    := dDataBase
Default cSerie		:= "" 

cQuery  := " SELECT COUNT(*)  CONT FROM " + RetSqlName("DT6") + " DT6 "
cQuery  += " WHERE DT6_FILIAL   = '" + xFilial("DT6") + "' "
cQuery  += " AND DT6_STATUS     <> '7' "
cQuery	+= " AND DT6_FILDOC		= '" + cFilAnt + "' "
If Empty(cSerie )
	cQuery	+= " AND DT6_SERIE		<> 'COL' "
Else 
	cQuery	+= " AND DT6_SERIE		= '" + cSerie + "' "
EndIf 
cQuery  += " AND DT6_PRZENT     BETWEEN '" + DToS(dDataDe) + "'  AND '" + DToS(dDataAte) + "' "
cQuery  += " AND DT6.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 16/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetNFsVenc( dDataDe , dDataAte ) 
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 
Local nQtde      := 0 

Default dDataDe	    := dDataBase 
Default dDataAte    := dDataBase

cQuery  := " SELECT COUNT(DTC_NUMNFC) CONT FROM " + RetSqlName("DT6") + " DT6 "
cQuery  += " INNER JOIN " + RetSqlName("DTC") + " DTC "
cQuery  += " ON DTC_FILIAL      = '" + xFilial("DTC") + "' "
cQuery  += " AND DTC_FILDOC     = DT6_FILDOC "
cQuery  += " AND DTC_DOC        = DT6_DOC "
cQuery  += " AND DTC_SERIE      = DT6_SERIE "
cQuery  += " AND DTC.D_E_L_E_T_   = '' "
cQuery  += " WHERE DT6_FILIAL   = '" + xFilial("DT6") + "' "
cQuery  += " AND DT6_STATUS     <> '7' "
cQuery  += " AND DT6_PRZENT     BETWEEN '" + DToS(dDataDe) + "'  AND '" + DToS(dDataAte) + "' "
cQuery  += " AND DT6.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
    nQtde   := (cAliasQry)->CONT
EndIf 

(cAliasQry)->(dbCloseArea())

Return nQtde