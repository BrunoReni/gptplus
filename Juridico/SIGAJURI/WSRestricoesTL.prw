#INCLUDE "WSRESTRICOESTL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRESTRICOES
M�todos WS REST do Jur�dico para restri��es do TOTVS Legal

@author SIGAJURI
@since 12/03/2021

/*/
//-------------------------------------------------------------------
WSRESTFUL JURRESTRICOES DESCRIPTION STR0001 // "WS Jur�dico Restri��es"

	WSDATA filial       AS STRING
	WSDATA cajuri       AS STRING
	WSDATA rotina       AS STRING
	WSDATA codPesq      AS STRING
	WSDATA grupoUsuario AS STRING

	WSMETHOD GET restricRot             DESCRIPTION STR0002 PATH 'restricRot'                               PRODUCES APPLICATION_JSON // 'Restri��es de Rotinas do TOTVS Legal'
	WSMETHOD GET assJurxPesq            DESCRIPTION STR0003 PATH 'assJurxPesq'                              PRODUCES APPLICATION_JSON // 'Busca o assunto jur�dico correspondente ao c�digo da pesquisa'
	WSMETHOD GET getAcessoUsu           DESCRIPTION STR0004 PATH "grpusu/accessRestriction"                 PRODUCES APPLICATION_JSON // "Retornar as Restri��o de acessos do Grupo do usu�rio logado" 
	WSMETHOD GET RoutineRestrictionTJD  DESCRIPTION STR0006 PATH "grpusu/accessRestriction/options"         PRODUCES APPLICATION_JSON // "Retorna as Rotinas de restri��es do Grupo do usu�rio"
	WSMETHOD GET groupRestrictionTJD    DESCRIPTION STR0007 PATH "grpusu/{grupoUsuario}/routineRestricted"  PRODUCES APPLICATION_JSON // "Retorna as rotinas que est�o restritas ao grupo" 
	
	WSMETHOD PUT updRestrictionTJD      DESCRIPTION STR0005 PATH "grpusu/{grupoUsuario}/accessRestriction"  PRODUCES APPLICATION_JSON // "Atualiza as restri��es do Grupo do usu�rio" 

	WSMETHOD DELETE delRestrictionTJD   DESCRIPTION STR0009 PATH "grpusu/{grupoUsuario}/accessRestriction"  PRODUCES APPLICATION_JSON // "Excluir as restri��es do grupo de usu�rio"
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} restricRot
Busca as restri��es do usu�rio para as rotinas do TOTVS Legal

@param filial: Filial do assunto jur�dico
@param cajuri: C�digo do assunto jur�dico
@param rotina: Rotina

@since 12/03/2021

@example GET -> http://localhost:12173/rest/JURRESTRICOES/restricRot?filial=D MG 01 &cajuri=0000000247
/*/
//-------------------------------------------------------------------
WSMETHOD GET restricRot WSRECEIVE filial, cajuri, rotina WSREST JURRESTRICOES

Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cFilPro    := self:filial
Local cCajuri    := self:cajuri
Local cRotina    := IIF( VALTYPE(self:rotina) <> "U", self:rotina, "")
Local cAssJur    := ""
Local cResult    := ""
Local aRestric   := {}
Local nX         := 0

	Self:SetContentType("application/json")
	oResponse['restricoes'] := {}

	If !Empty(cCajuri)
		cAssJur  := JurGetDados("NSZ", 1, cFilPro + cCajuri, "NSZ_TIPOAS")
		cResult  := JPermissTL(cAssJur, cRotina)
		aRestric := JURSQL(cResult,"*")

		For nX := 1 To Len(aRestric)
			Aadd(oResponse['restricoes'], JsonObject():New())
			oResponse['restricoes'][nX]['visualizar'] := aRestric[nX][1] == '1'
			oResponse['restricoes'][nX]['incluir']    := aRestric[nX][2] == '1'
			oResponse['restricoes'][nX]['alterar']    := aRestric[nX][3] == '1'
			oResponse['restricoes'][nX]['excluir']    := aRestric[nX][4] == '1'
			oResponse['restricoes'][nX]['rotina']     := aRestric[nX][5]
		Next nX
	EndIf

	aSize(aRestric, 0)
	RestArea( aArea )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldRestri
Valida a restri��o de acessos do usu�rio

@param cTpAssJur, string, C�digo do tipo de assunto jur�dico
@param cRotina,   string, C�digo da rotina
@param nOpc,      string, Opera��oexecutada

@return lRet,     boolean, Retorna .F. caso o usu�rio n�o possua acesso

@since 12/03/2021
/*/
//-------------------------------------------------------------------
Function JVldRestri(cTpAssJur, cRotina, nOpc)

Local cAlias      := ""
Local cQuery      := ""
Local lRet        := .F.

Default cTpAssJur := '001'
Default cRotina   := '14'
Default nOpc      := 2
	
	// Se o usu�rio � do grupo de subs�dio,for da rotina de anexo ou solicita��o de subs�dio, permite a manipula��o.
	If cRotina $ "'03'/'19'"
		aEval(J218RetGru( __cUserId ), {|cGrupo| lRet := lRet .or. Posicione('NZX',1,xFilial('NZX')+cGrupo,'NZX_TIPOA') == '4' })
	Endif

	If !lRet
		cAlias      := GetNextAlias()
		cQuery := JPermissTL(cTpAssJur, cRotina)
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

		lRet := (cAlias)->(! Eof())

		While lRet .And. (cAlias)->(! Eof()) 
			Do case 
				Case nOpc == 2
					If (cAlias)->NWP_CVISU == '2'
						lRet := .F.
					EndIf
				Case nOpc == 3
					If (cAlias)->NWP_CINCLU == '2'
						lRet := .F.
					EndIf
				Case nOpc == 4
					If (cAlias)->NWP_CALTER == '2'
						lRet := .F.
					EndIf
				Case nOpc == 5
					If (cAlias)->NWP_CEXCLU == '2'
						lRet := .F.
					EndIf
			End Case

			(cAlias)->(dbSkip())
		End

		(cAlias)->(DbCloseArea())
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPermissTL
Busca as permissoes de acessos do usu�rio para o TOTVS Legal

@param cTpAssJur, string, C�digo do tipo de assunto jur�dico
@param cRotina,   string, C�digo da rotina

@return cQuery,   string, retorno da query com acessos do usu�rio
@since 12/03/2021
/*/
//-------------------------------------------------------------------
Function JPermissTL(cTpAssJur, cRotina)

Local cQuery      := ""
Local cUser       :=  __CUSERID 
Local cGrupos     := ArrTokStr(J218RetGru(cUser),"','")
Local lNVKCasJur  := .F.

Default cRotina := ""

	// Verifica se o campo NVK_CASJUR existe no dicion�rio
	If Select("NVK") > 0
		lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	cQuery := " SELECT NWP_CVISU, "
	cQuery +=        " NWP_CINCLU, "
	cQuery +=        " NWP_CALTER, "
	cQuery +=        " NWP_CEXCLU, "
	cQuery +=        " NWP_CROT, "
	cQuery +=        " NVK_CGRUP "
	cQuery += " FROM   " + RetSqlname("NVK") + " NVK "
	cQuery +=        " LEFT JOIN " + RetSqlname("NWP") + " NWP "
	cQuery +=                " ON ( NWP_CCONF = NVK_COD "
	cQuery +=                     " AND NWP_FILIAL = '" + xFilial("NWP") + "'"
	If !Empty(cRotina)
		cQuery +=                 " AND NWP_CROT IN ( " + cRotina + " ) "
	EndIf
	cQuery +=                     " AND NWP.D_E_L_E_T_ = ' ' ) "
	cQuery +=        " LEFT JOIN " + RetSqlname("NVJ") + " NVJ "
	cQuery +=               " ON ( NVJ_FILIAL = '" + xFilial("NVJ") + "'"
	cQuery +=                    " AND NVK_CPESQ = NVJ_CPESQ "
	cQuery +=                    " AND NVJ.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE ( NVK_CUSER = '" + cUser + "' "
	cQuery +=               " OR NVK_CGRUP IN ( '" + cGrupos + "' ) ) "

	If lNVKCasJur
		cQuery +=       " AND ( NVK_CASJUR = '" + cTpAssJur + "' "
		cQuery +=               " OR NVJ_CASJUR = '" + cTpAssJur + "' ) "
	Else
		cQuery +=               " AND NVJ_CASJUR = '" + cTpAssJur + "' "
	EndIf

	cQuery +=       " AND NVK.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET assJurxPesq
Busca o assunto jur�dico correspondente ao c�digo da pesquisa

@param codPesq: C�digo da pesquisa

@since 29/04/2021

@example GET -> http://localhost:12173/rest/JURRESTRICOES/assJurxPesq?codPesq=002
/*/
//-------------------------------------------------------------------
WSMETHOD GET assJurxPesq WSRECEIVE codPesq WSREST JURRESTRICOES

Local aArea      := GetArea()
Local oResponse  := Nil
Local cCodPesq   := self:codPesq
Local cQuery     := ""
Local aListAss   := {}
Local nX         := 0

Default codPesq := ""

	Self:SetContentType("application/json")

	If !Empty(cCodPesq)
		oResponse := JsonObject():New()
		oResponse['assuntos'] := {}

		cQuery := " SELECT NVJ_CASJUR ASSUNTO "
		cQuery += " FROM " + RetSqlname("NVJ") + " NVJ "
		cQuery += " WHERE NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "' "
		cQuery +=   " AND NVJ.NVJ_CPESQ = '" + cCodPesq + "' "
		cQuery +=   " AND NVJ.D_E_L_E_T_ = ' ' "

		aListAss := JURSQL(cQuery,"*")

		For nX := 1 To Len(aListAss)
			Aadd(oResponse['assuntos'], JsonObject():New())
			oResponse['assuntos'][nX]['codAssJur'] := aListAss[nX][1]
		Next nX
	EndIf

	aSize(aListAss, 0)
	RestArea( aArea )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} StrToOpt(cOptions)
Transforma o Options do CBOX em Array

@param cOptions - CBOX = 1=Sim;2=N�o

@return [n][1] - Valor
        [n][2] - Descri��o

@since 28/12/2022
/*/
//-------------------------------------------------------------------
Static Function StrToOpt(cOptions)
Local aRet     := {}
Local aOptions := StrTokArr(cOptions, ";")
Local nI       := 0
Local nAtDiv   := 0

	For nI := 1 To Len(aOptions)
		nAtDiv := At("=", aOptions[nI])
		aAdd(aRet, { SubStr(aOptions[nI], 0, nAtDiv-1),  SubStr(aOptions[nI], nAtDiv+1) })
	Next nI
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RoutineRestrictionTJD
Retorna as op��es de Rotinas a serem restringidas no TJD 

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/accessRestriction/options
/*/
//-------------------------------------------------------------------
WSMETHOD GET RoutineRestrictionTJD WSREST JURRESTRICOES
Local lRet  := .T.
Local aOpts := {}
Local nI    := 0
Local oResponse := {}

	aOpts := StrToOpt(J309Rotina())

	For nI := 1 To Len(aOpts)
		aAdd(oResponse, JSonObject():New())
		oResponse[nI]["value"] := aOpts[nI][1]
		oResponse[nI]["label"] := JurConvUTF8(aOpts[nI][2])
	Next nI
	
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	aSize(oResponse, 0)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET groupRestrictionTJD
Retorna o c�digo das rotinas que est�o Bloqueadas para o Grupo de usu�rio

@param grupoUsuario - Path - Grupo de acesso a ser verificado
@return - {}

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/{grupoUsuario}/routineRestricted
/*/
//-------------------------------------------------------------------
WSMETHOD GET groupRestrictionTJD PATHPARAM grupoUsuario WSREST JURRESTRICOES
Local lRet      := .T.
Local nI        := 0
Local cQuery    := ""
Local cGrpUsu   := Self:grupoUsuario
Local aRotinas  := {}
Local oResponse := JSonObject():New()

Default cGrpUsu := ""

	oResponse['rotinas'] := {}
	
	If (FWAliasInDic("O1G"))
		cQuery := " SELECT O1G_ROTINA "
		cQuery +=   " FROM " + RetSqlName("O1G") + " O1G "
		cQuery +=  " WHERE O1G.O1G_BLOQUE = '1' "
		cQuery +=    " AND O1G.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND O1G.O1G_GRPUSU = '"+cGrpUsu+"' "

		aRotinas := JurSQL(cQuery, {"O1G_ROTINA"})
		
		For nI := 1 To Len(aRotinas)
			aAdd(oResponse['rotinas'], aRotinas[nI][1])
		Next nI
	Else
		oResponse['status']  = '204'
		oResponse['message'] = JurEncUTF8(STR0010) // "A tabela O1G n�o existe no dicion�rio de dados."
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RoutineRestrictionTJD
Retorna as op��es de Rotinas a serem restringidas no TJD 

@param grupoUsuario - C�digo do Grupo de usu�rio

@Body ["rotinas"] = Array com as rotinas a serem BLOQUEADAS

@notes Os c�digos das rotinas que n�o forem recebidas ser�o desbloqueadas

@example [Sem Opcional] PUT -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/accessRestriction
/*/
//-------------------------------------------------------------------
WSMETHOD PUT updRestrictionTJD  PATHPARAM grupoUsuario WSREST JURRESTRICOES
Local oBody        := JSonObject():New()
Local oResponse    := JSonObject():New()
Local cBody        := Self:GetContent()
Local cGrpUsu      := Self:grupoUsuario
Local lRet         := .T.
Local cQuery       := ""
Local aRotinas     := {}
Local aRstGrpUsu   := {}
Local nI           := 0
Local nIndRestr    := 0

	oBody:FromJson(cBody)
	aRotinas := oBody['rotinas']

	If (FWAliasInDic("O1G"))
		cQuery := " SELECT O1G.O1G_ROTINA, O1G.O1G_BLOQUE, R_E_C_N_O_ Recno "
		cQuery +=   " FROM " + RetSqlName("O1G") + " O1G "
		cQuery +=  " WHERE O1G_GRPUSU = '" + cGrpUsu + "'"
		cQuery +=    " AND O1G.D_E_L_E_T_ = ' ' "

		aRstGrpUsu := JurSQL(cQuery, {"O1G_ROTINA", "O1G_BLOQUE", "Recno"})

		// Processa as rotinas que foram recebidas via Body, bloqueando as rotinas
		For nI := 1 to Len(aRotinas) //Body
			nIndRestr := aScan(aRstGrpUsu,{|x| x[1] == aRotinas[nI]})
			If (nIndRestr == 0) 
				lRet := JUpdBlqO1G(/* N�o tem Recno */, cGrpUsu, aRotinas[nI], '1')
			Else 
				lRet := JUpdBlqO1G(aRstGrpUsu[nIndRestr][3], cGrpUsu, aRotinas[nI], '1')
			EndIf
		Next nI

		// Ir� processar as rotinas restantes para habilitar o acesso
		For nI := 1 To Len(aRstGrpUsu)
			nIndRestr := aScan(aRotinas, aRstGrpUsu[nI][1])
			If nIndRestr == 0 // N | S | X
				lRet := JUpdBlqO1G(aRstGrpUsu[nI][3], cGrpUsu, aRstGrpUsu[nI][1], '2')
			EndIf
		Next nI
		
		If (lRet)
			oResponse['status']  = '200'
			oResponse['message'] = JurEncUTF8(STR0008)//"As restri��es das rotinas do grupo foram atualizadas com sucesso!"
		EndIf
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdBlqO1G(nRecno, cGrpUsu, cRotina, cBloque)
Fun��o que inicia a atualiza��o/cria��o da Restri��o de Rotina do Grupo

@param nRecno - Recno do Grupo na O1G
@param cGrpUsu - C�digo do Grupo de Usu�rio
@param cRotina - C�digo da Rotina a ser alterada
@param cBloque - Indica se a rotina ser� bloqueada ou n�o

@return lRet - Retorna se a opera��o foi bem sucedida ou n�o

@author Willian Kazahaya
@since 28/12/2022
/*/
//-------------------------------------------------------------------
Static Function JUpdBlqO1G(nRecno, cGrpUsu, cRotina, cBloque)
Local lRet := .T.
Default nRecno  := -1
Default cGrpUsu := ""
Default cRotina := ""

	If nRecno == -1 // Se o Recno for negativo � uma Inclus�o
		lRet := JOpera309(3, cGrpUsu, cRotina)
	Else
		DbSelectArea("O1G")
		DbGoTo(nRecno)
		lRet := JOpera309(4, cGrpUsu, cRotina, cBloque)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdBlqO1G(nRecno, cGrpUsu, cRotina, cBloque)
Fun��o que inicia a atualiza��o/cria��o da Restri��o de Rotina do Grupo

@param nRecno - Recno do Grupo na O1G
@param cGrpUsu - C�digo do Grupo de Usu�rio
@param cRotina - C�digo da Rotina a ser alterada
@param cBloque - Indica se a rotina ser� bloqueada ou n�o

@author Willian Kazahaya
@since 28/12/2022
/*/
//-------------------------------------------------------------------
Static Function JOpera309(nOper, cGrpUsu, cRotina, cBloque)
Local oModel    := Nil
Default nOper   := 4
Default cGrpUsu := "" //O1G->O1G_GRPUSU
Default cRotina := "" //O1G->O1G_ROTINA
Default cBloque := "" //O1G->O1G_BLOQUE

	oModel := FwLoadModel("JURA309")
	oModel:SetOperation(nOper)
	oModel:Activate()

	If nOper == MODEL_OPERATION_INSERT 
		oModel:SetValue("O1GMASTER", "O1G_GRPUSU", cGrpUsu)
		oModel:SetValue("O1GMASTER", "O1G_ROTINA", cRotina)
	ElseIf nOper == MODEL_OPERATION_UPDATE
		oModel:SetValue("O1GMASTER", "O1G_BLOQUE", cBloque)
	EndIf

	If ( lRet := oModel:VldData() )
		lRet := oModel:CommitData()
	EndIf
	
	If (!lRet)
		lRet := JurMsgErro(oModel:aErrorMessage[6]) 
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getAcessoUsu

Retornar as Restri��o de acessos do Grupo do usu�rio logado
@since 28/12/2022
@version 1.0
@example [Sem Opcional] PUT -> localhost:12173/rest/JURRESTRICOES/grpusu/accessRestriction
/*/
//-------------------------------------------------------------------

WSMETHOD GET getAcessoUsu WSREST JURRESTRICOES
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local cAliasO1G  := ""

	oResponse["restringe"] := JsonObject():New()
	oResponse["restringe"]["publicacoes"] := .F.
	oResponse["restringe"]["distribuicoes"] := .F.
	oResponse["restringe"]["config"] := .F.
	oResponse["restringe"]["cadBasico"] := .F.
	oResponse["restringe"]["usuarios"] := .F.

	If (FWAliasInDic("O1G"))
		cQuery:= " SELECT O1G.O1G_ROTINA"
		cQuery+=  " FROM " + RetSqlName("NZY") + " NZY "
		cQuery+=  " INNER JOIN " + RetSqlName("NZX") + " NZX ON (NZX.NZX_COD = NZY.NZY_CGRUP"
		cQuery+=                                           " AND NZX.D_E_L_E_T_ = ' ')"
		cQuery+=  " INNER JOIN " + RetSqlName("O1G") + " O1G ON (O1G.O1G_GRPUSU = NZX.NZX_COD" 
		cQuery+=                                           " AND O1G.D_E_L_E_T_ = ' ')"
		cQuery+= " WHERE NZY.NZY_CUSER = '"+__cUserID+"'"
		cQuery+= " AND O1G.O1G_BLOQUE = '1'"
		cQuery+= " AND NZY.D_E_L_E_T_ = ' '"
		cQuery+= " GROUP BY O1G.O1G_ROTINA"

		cAliasO1G := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasO1G, .F., .T.)

		While (cAliasO1G)->(!Eof())
			Do Case
				Case ((cAliasO1G)->(O1G_ROTINA))=='1'
					oResponse["restringe"]["publicacoes"] := .T.

				Case ((cAliasO1G)->(O1G_ROTINA))=='2'
					oResponse["restringe"]["distribuicoes"] := .T.

				Case ((cAliasO1G)->(O1G_ROTINA))=='3'
					oResponse["restringe"]["config"] := .T.

				Case ((cAliasO1G)->(O1G_ROTINA))=='4'
					oResponse["restringe"]["cadBasico"] := .T.

				Case ((cAliasO1G)->(O1G_ROTINA))=='5'
					oResponse["restringe"]["usuarios"] := .T.

			End Case
			(cAliasO1G)->( dbSkip() )
		End

		(cAliasO1G)->(DbCloseArea())
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE delRestrictionTJD
Exclui as Restri��es de Rotina do TJD do Grupo de usu�rio

@since 09/01/2023
@version 1.0
@example [Sem Opcional] DELETE -> http://127.0.0.1:12173/rest/JURRESTRICOES/grpusu/{grupoUsuario}/routineRestricted
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE delRestrictionTJD PATHPARAM grupoUsuario WSREST JURRESTRICOES
Local oResponse  := JsonObject():New()
Local aRstGrpUsu := {}
Local cQuery     := ""
Local nI         := 0
Local lRet       := .T.

	If (FWAliasInDic("O1G"))
		cQuery := " SELECT R_E_C_N_O_ Recno "
		cQuery +=   " FROM " + RetSqlName("O1G") + " O1G "
		cQuery +=  " WHERE O1G_GRPUSU = '" + self:grupoUsuario + "'"
		cQuery +=    " AND O1G.D_E_L_E_T_ = ' ' "

		aRstGrpUsu := JurSQL(cQuery, { "Recno" })

		If (Len(aRstGrpUsu) > 0)
			For nI := 1 To Len(aRstGrpUsu)
				DbSelectArea("O1G")
				DbGoTo(aRstGrpUsu[nI][1])
				lRet := JOpera309(5)
			Next nI
		EndIf
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	aSize(aRstGrpUsu, 0)
Return lRet
