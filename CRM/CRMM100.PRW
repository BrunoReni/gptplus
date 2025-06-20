#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMM100.CH"
#INCLUDE "FWLIBVERSION.CH"

//---------------------------------------------------------------
/*/{Protheus.doc} CRMMNOTES

Classe respons�vel por manipular as anota��es das entidades Protheus.

@author	Squad CRM/Faturamento
@since		11/06/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSRESTFUL CRMMNOTES DESCRIPTION STR0001 // "Anota��es para appCRM."

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL
	WSDATA sourceBranch AS STRING  OPTIONAL
	WSDATA resourceType AS STRING
	WSDATA resourceCode AS STRING
	WSDATA searchKey    AS STRING  OPTIONAL
	WSDATA code	 		AS STRING
	WSDATA searchOrder  AS STRING  OPTIONAL

	WSMETHOD GET Main    DESCRIPTION STR0002;  // "Retorno de anota��es"
	WSSYNTAX "/CRMMNOTES?{page, pageSize, sourceBranch, resourceType, resourceCode, searchKey}";
	PATH ""

	WSMETHOD GET Code    DESCRIPTION STR0002;  // "Retorno de anota��es"
	WSSYNTAX "/CRMMNOTES/{code}";
	PATH "{code}"

	WSMETHOD POST        DESCRIPTION STR0003;  // "Cria��o de anota��es"
	WSSYNTAX "/CRMMNOTES";
	PATH ""

	WSMETHOD PUT         DESCRIPTION STR0004;  // "Atualiza��o de anota��es"
	WSSYNTAX "/CRMMNOTES/{code}";
	PATH "{code}"

	WSMETHOD DELETE      DESCRIPTION STR0005;  // "Exclus�o de anota��es"
	WSSYNTAX "/CRMMNOTES/{code}";
	PATH "{code}"

END WSRESTFUL


//---------------------------------------------------------------
/*/{Protheus.doc} GET
M�todo respons�vel por listar as anota��es de uma entidade.

@author		Squad CRM/Faturamento
@since		16/07/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE page, pageSize, sourceBranch, resourceType, resourceCode, searchKey, searchOrder WSSERVICE CRMMNOTES

Local nError     := 0
Local cError     := ""
Local oResponse  := nil
Local oItem      := nil
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local nIndexJSon := 0
Local nSkip      := 0
Local lVerLib	 := CRMM100Stat()

Default Self:searchOrder := "DESC"

Self:SetContentType("application/json")

// Verifica se o par�metro obrigat�rio foi passado.
If empty(Self:resourceType) .or. empty(Self:resourceCode)
	nError := 400
	cError := STR0006  // "Entidade n�o informada."
Else
	Default Self:page := 1
	If Self:page < 0
		Self:page := 1
	Endif

	Default Self:pageSize := 20
	If Self:pageSize < 0 .or. Self:pageSize > 30
		Self:pageSize := 20
	Endif

	cQuery := "select AOB.R_E_C_N_O_ AOBRecNo " + CRLF
	cQuery += "from " + RetSqlName('AOB') + " AOB " + CRLF
	cQuery += "where AOB.D_E_L_E_T_ = '' " + CRLF
	If empty(Self:sourceBranch)
		cQuery += "and AOB.AOB_FILIAL in (?) " + CRLF
	Else
		cQuery += "and AOB.AOB_FILIAL = ? " + CRLF
	Endif
	cQuery += "and AOB.AOB_ENTIDA = ? " + CRLF
	cQuery += "and AOB.AOB_CHAVE  = ? " + CRLF
	If !empty(Self:searchKey)
		cQuery += "and (upper(AOB.AOB_TITULO) like '%' + ? + '%' or upper(AOB.AOB_CONTEU) like '%' + ? + '%')" + CRLF
	Endif
	cQuery += "order by AOB.AOB_FILIAL, AOB.AOB_ENTIDA, AOB.AOB_CHAVE, AOB.AOB_IDNOTA " + Self:searchOrder
	
	// Trata SQL para proteger de SQL injection.
	oStatement := IIf(lVerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery))

	nSQLParam++
	If empty(Self:sourceBranch)
		oStatement:SetString(nSQLParam, xFilial("AOB"))  // Filiais.
	Else
		oStatement:SetString(nSQLParam, xFilial("AOB", Self:sourceBranch))  // Filial.
	Endif

	nSQLParam++
	oStatement:SetString(nSQLParam, Self:resourceType)  // Entidade.

	nSQLParam++
	oStatement:SetString(nSQLParam, Self:resourceCode)  // Chave.

	If !empty(Self:searchKey)
		nSQLParam++
		oStatement:SetString(nSQLParam, upper(Self:searchKey))  // T�tulo.
		nSQLParam++
		oStatement:SetString(nSQLParam, upper(Self:searchKey))  // Conte�do.
	Endif

	If lVerLib
		cAliasSQL := oStatement:OpenAlias()
	Else
		cQuery := oStatement:GetFixQuery()
		cAliasSQL := MPSysOpenQuery(cQuery)
	EndIf 	

	oStatement:Destroy()
	oStatement := nil
	
	// Calcula quantos registros pular.
	DbSelectArea(cAliasSQL)
	If (cAliasSQL)->(!eof())
		nSkip := ((Self:page - 1) * Self:pageSize)
		If nSkip > 0
			(cAliasSQL)->(dbSkip(nSkip))
		Endif
	Endif

	oResponse := JsonObject():New()
	oResponse['items'] := {}
	Do While (cAliasSQL)->(!eof() .and. nIndexJSon < Self:pageSize)
		AOB->(dbGoTo((cAliasSQL)->AOBRecNo))

		oItem := JsonObject():New()
		oItem['code']         := RTrim(AOB->AOB_IDNOTA)
		oItem['resourceType'] := AOB->AOB_ENTIDA
		oItem['resourceCode'] := RTrim(AOB->AOB_CHAVE)
		oItem['title']        := EncodeUTF8(RTrim(AOB->AOB_TITULO))
		oItem['date']         := dtos(AOB->AOB_DTNOTA)
		oItem['content']      := EncodeUTF8(RTrim(AOB->AOB_CONTEU))
		If AOB->(FieldPos("AOB_MSFIL") > 0 .and. !empty(AOB_MSFIL))
			oItem['sourceBranch']     := AOB->AOB_MSFIL
			oItem['sourceBranchName'] := EncodeUTF8(RTrim(FWFilName(cEmpAnt, AOB->AOB_MSFIL)))
		Endif
		oItem['bloqued']      := (AOB->AOB_MSBLQL = "1")
		aAdd(oResponse['items'], oItem)

		nIndexJSon ++
		(cAliasSQL)->(dbSkip())
	EndDo
	oResponse['hasNext'] := (cAliasSQL)->(!eof())

	(cAliasSQL)->(dbCloseArea())
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} GET
M�todo respons�vel por retornar uma anota��o espec�fica.

@author		Squad CRM/Faturamento
@since		16/07/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSMETHOD GET Code WSSERVICE CRMMNOTES

Local nError     := 0
Local cError     := ""
Local oResponse  := nil
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local cCode      := Self:code
Local lVerLib	 := CRMM100Stat()

Self:SetContentType("application/json")

cQuery := "select AOB.R_E_C_N_O_ AOBRecNo " + CRLF
cQuery += "from " + RetSqlName('AOB') + " AOB " + CRLF
cQuery += "where AOB.D_E_L_E_T_ = '' " + CRLF
cQuery += "and AOB.AOB_FILIAL = '" + xFilial("AOB") + "' " + CRLF
cQuery += "and AOB.AOB_IDNOTA = ? " + CRLF
cQuery += "order by AOB.AOB_FILIAL, AOB.AOB_ENTIDA, AOB.AOB_CHAVE, AOB.AOB_IDNOTA "

// Trata SQL para proteger de SQL injection.
oStatement := IIf(lVerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery))

oStatement:SetString(1, cCode)

If lVerLib
	cAliasSQL := oStatement:OpenAlias()
Else
	cQuery := oStatement:GetFixQuery()
	cAliasSQL := MPSysOpenQuery(cQuery)
EndIf

oStatement:Destroy()
oStatement := nil

// Posiciona no registro a alterar.
DbSelectArea(cAliasSQL)
If (cAliasSQL)->(eof())
	nError := 404
	cError := STR0015  // "Registro n�o encontrado."
Else
	AOB->(dbGoTo((cAliasSQL)->AOBRecNo))
Endif
(cAliasSQL)->(dbCloseArea())

If nError = 0
	oResponse := JsonObject():New()
	oResponse['code']         := RTrim(AOB->AOB_IDNOTA)
	oResponse['resourceType'] := AOB->AOB_ENTIDA
	oResponse['resourceCode'] := RTrim(AOB->AOB_CHAVE)
	oResponse['title']        := EncodeUTF8(RTrim(AOB->AOB_TITULO))
	oResponse['date']         := dtos(AOB->AOB_DTNOTA)
	oResponse['content']      := EncodeUTF8(RTrim(AOB->AOB_CONTEU))
	If AOB->(FieldPos("AOB_MSFIL") > 0 .and. !empty(AOB_MSFIL))
		oResponse['sourceBranch']     := AOB->AOB_MSFIL
		oResponse['sourceBranchName'] := EncodeUTF8(RTrim(FWFilName(cEmpAnt, AOB->AOB_MSFIL)))
	Endif
	oResponse['bloqued']      := (AOB->AOB_MSBLQL = "1")
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} POST
M�todo respons�vel por incluir anota��es.

@author		Squad CRM/Faturamento
@since		17/07/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSMETHOD POST WSSERVICE CRMMNOTES

Local nError     := 0
Local cError     := ""
Local aError     := {}
Local oModel     := nil
Local oResponse  := nil
Local cCode      := ""
Local oContent   := nil

Self:SetContentType("application/json")

// Verifica se o body veio no formato JSon.
If lower(Self:GetHeader("Content-Type", .F.)) == "application/json"

	FWJsonDeserialize(Self:GetContent(), @oContent)
	If !AttIsMemberOf(oContent, "resourceType") .or. !AttIsMemberOf(oContent, "resourceCode") .or.;
		!AttIsMemberOf(oContent, "title") .or. !AttIsMemberOf(oContent, "content")

		nError := 400
		cError := STR0007  // "Par�metros obrigat�rios n�o informados."
	Else
		oModel := FwLoadModel('CRMA090')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oModel:SetValue('AOBMASTER', 'AOB_ENTIDA', oContent:resourceType)
			oModel:SetValue('AOBMASTER', 'AOB_CHAVE',  oContent:resourceCode)
			oModel:SetValue('AOBMASTER', 'AOB_TITULO', DecodeUTF8(RTrim(oContent:title)))
			oModel:SetValue('AOBMASTER', 'AOB_CONTEU', DecodeUTF8(RTrim(oContent:content)))
			If AttIsMemberOf(oContent, "bloqued")
				oModel:SetValue('AOBMASTER', 'AOB_MSBLQL', If(oContent:bloqued, '1', '2'))
			Endif
			If AttIsMemberOf(oContent, "ownerCode")
				oModel:SetValue('AOBMASTER', 'AOB_OWNER',  oContent:ownerCode)
			Endif
			cCode := oModel:GetValue('AOBMASTER', 'AOB_IDNOTA')

			If (oModel:VldData() .and. oModel:CommitData())
				oResponse := JsonObject():New()
				oResponse["sucessCode"] := 201
				oResponse["sucessMessage"] := EncodeUTF8(STR0018)  // "Anota��o inclu�da com sucesso."
				oResponse["code"] := cCode
			Else
				nError := 400
				cError := STR0008  // "A integra��o n�o foi bem sucedida."
				aError := oModel:GetErrorMessage()
				If !Empty(aError)
					cError += CRLF + STR0009 + Alltrim(aError[5]) + '-' + AllTrim(aError[6])  // "Foi retornado o seguinte problema: "
					If !Empty(Alltrim(aError[7]))
						cError += CRLF + STR0010 + AllTrim(aError[7])  // "Solu��o: "
					Endif
				Else
					cError += CRLF + STR0011  // "Verifique os dados enviados"
				Endif
			Endif
		Else
			nError := 400
			cError := STR0012  // "Erro ao ativar modelo CRMA090."
		Endif

		oModel:Deactivate()
		oModel:Destroy()
		oModel := nil
	Endif
Else
	nError := 400
	cError := STR0013  // "Body esperado no formato 'application/json'."
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} PUT
M�todo respons�vel por alterar anota��es.

@author		Squad CRM/Faturamento
@since		17/07/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSMETHOD PUT WSSERVICE CRMMNOTES

Local nError     := 0
Local cError     := ""
Local aError     := {}
Local oModel     := nil
Local oResponse  := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local oContent   := nil
Local cCode      := Self:code
Local lVerLib	 := CRMM100Stat()

Self:SetContentType("application/json")

// Verifica se o body veio no formato JSon.
If lower(Self:GetHeader("Content-Type", .F.)) == "application/json"

	If empty(cCode)
		nError := 400
		cError := STR0007  // "Par�metros obrigat�rios n�o informados."
	Else
		cQuery := "select AOB.R_E_C_N_O_ AOBRecNo " + CRLF
		cQuery += "from " + RetSqlName('AOB') + " AOB " + CRLF
		cQuery += "where AOB.D_E_L_E_T_ = '' " + CRLF
		cQuery += "and AOB.AOB_FILIAL = '" + xFilial("AOB") + "' " + CRLF
		cQuery += "and AOB.AOB_IDNOTA = ? " + CRLF

		// Trata SQL para proteger de SQL injection.
		oStatement := IIf(lVerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery))

		oStatement:SetString(1, cCode)

		If lVerLib
			cAliasSQL := oStatement:OpenAlias()
		Else
			cQuery := oStatement:GetFixQuery()
			cAliasSQL := MPSysOpenQuery(cQuery)
		EndIf
		
		oStatement:Destroy()
		oStatement := nil

		// Posiciona no registro a alterar.
		DbSelectArea(cAliasSQL)
		If (cAliasSQL)->(eof())
			nError := 404
			cError := STR0015  // "Registro n�o encontrado."
		Else
			AOB->(dbGoTo((cAliasSQL)->AOBRecNo))
		Endif
		(cAliasSQL)->(dbCloseArea())

		If nError = 0
			oModel := FwLoadModel('CRMA090')
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			If oModel:Activate()
				FWJsonDeserialize(Self:GetContent(), @oContent)
				If AttIsMemberOf(oContent, "title")
					oModel:SetValue('AOBMASTER', 'AOB_TITULO', DecodeUTF8(RTrim(oContent:title)))
				Endif
				If AttIsMemberOf(oContent, "user")
					oModel:SetValue('AOBMASTER', 'AOB_OWNER',  oContent:user)
				Endif
				If AttIsMemberOf(oContent, "content")
					oModel:SetValue('AOBMASTER', 'AOB_CONTEU', DecodeUTF8(RTrim(oContent:content)))
				Endif
				If AttIsMemberOf(oContent, "bloqued")
					oModel:SetValue('AOBMASTER', 'AOB_MSBLQL', If(oContent:bloqued, '1', '2'))
				Endif

				If (oModel:VldData() .and. oModel:CommitData())
					oResponse := JsonObject():New()
					oResponse["sucessCode"] := 200
					oResponse["sucessMessage"] := EncodeUTF8(STR0017)  // "Anota��o alterada com sucesso."
					oResponse["code"] := cCode
				Else
					nError := 400
					cError := STR0008  // "A integra��o n�o foi bem sucedida."
					aError := oModel:GetErrorMessage()
					If !Empty(aError)
						cError += CRLF + STR0009 + Alltrim(aError[5]) + '-' + AllTrim(aError[6])  // "Foi retornado o seguinte problema: "
						If !Empty(Alltrim(aError[7]))
							cError += CRLF + STR0010 + AllTrim(aError[7])  // "Solu��o: "
						Endif
					Else
						cError += CRLF + STR0011  // "Verifique os dados enviados"
					Endif
				Endif
			Else
				nError := 400
				cError := STR0012  // "Erro ao ativar modelo CRMA090."
			Endif

			oModel:Deactivate()
			oModel:Destroy()
			oModel := nil
		Endif
	Endif
Else
	nError := 400
	cError := STR0013  // "Body esperado no formato 'application/json'."
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} DELETE
M�todo respons�vel por excluir anota��es.

@author		Squad CRM/Faturamento
@since		18/07/2018
@version	12.1.21
/*/
//---------------------------------------------------------------
WSMETHOD DELETE WSSERVICE CRMMNOTES

Local nError     := 0
Local cError     := ""
Local aError     := {}
Local oModel     := nil
Local oResponse  := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local cCode      := Self:code
Local lVerLib	 := CRMM100Stat()

Self:SetContentType("application/json")

If empty(cCode)
	nError := 400
	cError := STR0007  // "Par�metros obrigat�rios n�o informados."
Else
	cQuery := "select AOB.R_E_C_N_O_ AOBRecNo " + CRLF
	cQuery += "from " + RetSqlName('AOB') + " AOB " + CRLF
	cQuery += "where AOB.D_E_L_E_T_ = '' " + CRLF
	cQuery += "and AOB.AOB_FILIAL = '" + xFilial("AOB") + "' " + CRLF
	cQuery += "and AOB.AOB_IDNOTA = ? " + CRLF

	// Trata SQL para proteger de SQL injection.
	oStatement := IIf(lVerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery))

	oStatement:SetString(1, cCode)

	If lVerLib
		cAliasSQL := oStatement:OpenAlias()
	Else
		cQuery := oStatement:GetFixQuery()
		cAliasSQL := MPSysOpenQuery(cQuery)
	EndIf

	oStatement:Destroy()
	oStatement := nil

	// Posiciona no registro a excluir.
	DbSelectArea(cAliasSQL)
	If (cAliasSQL)->(eof())
		nError := 404
		cError := STR0015  // "Registro n�o encontrado."
	Else
		AOB->(dbGoTo((cAliasSQL)->AOBRecNo))
	Endif
	(cAliasSQL)->(dbCloseArea())

	If nError = 0
		oModel := FwLoadModel('CRMA090')
		oModel:SetOperation(MODEL_OPERATION_DELETE)
		If oModel:Activate()
			If (oModel:VldData() .and. oModel:CommitData())
				oResponse := JsonObject():New()
				oResponse["sucessCode"] := 200
				oResponse["sucessMessage"] := EncodeUTF8(STR0016)  // "Anota��o exclu�da com sucesso."
				oResponse["code"] := cCode
			Else
				nError := 400
				cError := STR0008  // "A integra��o n�o foi bem sucedida."
				aError := oModel:GetErrorMessage()
				If !Empty(aError)
					cError += CRLF + STR0009 + Alltrim(aError[5]) + '-' + AllTrim(aError[6])  // "Foi retornado o seguinte problema: "
					If !Empty(Alltrim(aError[7]))
						cError += CRLF + STR0010 + AllTrim(aError[7])  // "Solu��o: "
					Endif
				Else
					cError += CRLF + STR0011  // "Verifique os dados enviados"
				Endif
			Endif
		Else
			nError := 400
			cError := STR0012  // "Erro ao ativar modelo CRMA090."
		Endif

		oModel:Deactivate()
		oModel:Destroy()
		oModel := nil
	Endif
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)

/*/{Protheus.doc} CRMM100Stat
Fun��o utilizada para validar a data da LIB para utiliza��o da classe FWExecStatement
@type       Function
@author     CRM/Faturamento
@since      Jan/2023
@version    12.1.33
@return     __Cr100VerLib retorna l�gico quando a data da lib for superior a 16/11/2021
/*/
Static Function CRMM100Stat()

Static __Cr100VerLib := Nil

If __Cr100VerLib == Nil
	__Cr100VerLib := FWLibVersion() >= "20211116"
EndIf

Return __Cr100VerLib
