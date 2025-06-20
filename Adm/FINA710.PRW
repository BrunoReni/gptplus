#include 'PROTHEUS.CH'
#Include "FwSchedule.ch"
#Include "FINA710.ch"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'

Static __lMetric	:= .F.
Static __lAcces		:= .T.
Static __oHashCache

/*/{Protheus.doc} FINA710
    Chamada do app pelo menu do protheus

    @author renato.ito
    @since 10/09/2020
/*/
Function FINA710()

	Local cMvTfcjobT  As Character
	Local lOk         As Logical
	Local nRetMnu	  As Numeric

	Private aRotina     As Array
	Private nStartTime  As Character
	Private cDateFormat As Character
	Private cValFormat 	As Character

	cDateFormat := getDtFmt()
	cValFormat  := getValFmt()

	aRotina	:= MenuDef()
	nRetMnu	:= 0

	getMenu710(@nRetMnu)

	If nRetMnu == 0
		MsgStop( STR0012 + CRLF + STR0013, STR0014 ) // "Este usu�rio n�o possui acesso para executar essa opera��o." # "Menu: FINA710" # "Aten��o"
		Return
	Endif

	__lMetric    := FwLibVersion() >= "20210517"
	__oHashCache := FwHashMap():New()
	nStartTime   := Time()
	lOk          := .T.

	If !(GetRpoRelease() >= "12.1.033")
		If !(&("gfin.util.validRelease.getValidRelease()"))
			Help(, , STR0005, , STR0004, 1, 0) // #"Novo Gestor Financeiro" #"Para uso deese recurso o ambiente dever� ser atualizado para vers�o 12.1.33"
			Return
		Endif
	Endif

	// Verifica se o dicion�rio � compat�vel
	If !AliasIndic("F75") .Or. !AliasIndic("F76")
		Help(, , "FINA710DIC", , STR0001, 1, 0)    // "Dicion�rio incompat�vel com a aplica��o."
		lOk := .F.
	EndIf

	If lOk
		// Verifica se o ambiente est� com os campos necess�rio para a execu��o do Novo Gestor Financeiro
		If F710CfgOk()
			cMvTfcjobT := SuperGetMV("MV_TFCJOBT",,'')
			// Job ainda n�o foi executado, necess�rio aguardar para o uso do Novo Gestor Financeiro
			If Empty(cMvTfcjobT)
				FwCustomMetrics():setSumMetric("FINA711 - Carga inicial", "financeiro-protheus_qtd-por-acesso_total", 1)
				Help(' ', 1, 'FINA710JOB' , , STR0002 , 1 , 0)  // 'A carga de dados n�o foi conclu�da/realizada. Por favor, solicitar ao administrador do sistema verificar a execu��o do Job FINA711 no m�dulo configurador.'
				lOk := .F.
			Else
				FwCallApp("FINA710")
			Endif
		Else
			F712Wiz()
		EndIf
	EndIf
	FreeObj(__oHashCache)
Return


/*/{Protheus.doc} getDtFmt
    Pega o formato da data baseado
	na configura��o do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getDtFmt()
	Local cFormat As Character
	Local cLanguage As Character
	Local cIdiom As Character
	cIdiom := FwRetIdiom()
	cFormat := "dd/mm/yyyy"

	cLanguage := GetPvProfString(GetEnvServer(), "DateFormat", "NOEXISTS", GetSrvIniName())

	If(Upper(cIdiom) == 'EN')
		cFormat := "mm/dd/yyyy"
	EndIf

	If(cLanguage != "NOEXISTS")
		If(Upper(cLanguage) == "AMERICAN")
			cFormat := "mm/dd/yyyy"
		EndIf
	EndIf

	If(Upper(cIdiom) == 'RU')
		cFormat := "dd.mm.yyyy"
	EndIf
Return cFormat

/*/{Protheus.doc} getValFmt
    Pega o formato do valor baseado
	na configura��o do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getValFmt()
	Local cFormat As Character
	Local cLanguage As Character
	Local cIdiom As Character
	cIdiom := FwRetIdiom()
	cFormat := "DEFAULT"

	cLanguage := GetPvProfString(GetEnvServer(), "PictFormat", "NOEXISTS", GetSrvIniName())

	If(cLanguage != "NOEXISTS")
		If(Upper(cLanguage) == "AMERICAN")
			cFormat := "AMERICAN"
		EndIf
	Else
		If(Upper(cIdiom) == 'EN')
			cFormat := "AMERICAN"
		EndIf
	EndIf

Return cFormat

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author renato.ito
    @since 26/01/2021
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)

	Local jsonCompany                                               as Json
	Local jsonBranch                                                as Json
	Local jsonUserBranches                                          as Json
	Local jsonPaisLoc                                               as Json
	Local jsonDtFormat                                              as Json
	Local jsonValFormat                                             as Json
	Local jsonFunName                                               as Json
	Local cFnc                                                      as Character // macro executar fun��o tlpp pra n�o gerar erro de compila��o no release 17
	Local nSrvVersion := Val( StrTran( GetSrvVersion(), ".", "" ) ) as Numeric
	Local cSrvVersao  := Iif(nSrvVersion >= 20303, "true", "false") as Character
	Local nTimeSencs  := 0                                          as Numeric
	Local jStorage                                                  as Json

	Do Case
		Case cType == "preLoad"
			jsonCompany      := JsonObject():New()
			jsonBranch       := JsonObject():New()
			jsonUserBranches := JsonObject():New()
			jsonPaisLoc      := JsonObject():New()
			jsonDtFormat     := JsonObject():New()
			jsonValFormat    := JsonObject():New()
			jsonFunName      := JsonObject():New()
			jStorage         := JsonObject():New()
			jsonCompany["InternalId"]       := cEmpAnt
			jsonCompany["CorporateName"]    := FWGrpName(cEmpAnt)
			jsonCompany["Code"]             := cEmpAnt
			jsonBranch["CompanyCode"]       := cEmpAnt
			jsonBranch["EnterpriseGroup"]   := cEmpAnt
			jsonBranch["ParentCode"]        := cFilAnt
			jsonBranch["Code"]              := cFilAnt
			jsonBranch["Description"]       := FWFilialName()
			cFnc := 'gfin.util.branchesOfUser()'
			jsonUserBranches["items"]       := &cFnc
			jsonPaisLoc["PaisLoc"]          := cPaisLoc
			jsonDtFormat["DateFormat"]      := cDateFormat
			jsonValFormat["ValueFormat"]    := cValFormat
			jsonFunName["FunName"]          := 'fina710'
			oWebChannel:AdvPLToJS('setCompany'       , jsonCompany:toJSON())
			oWebChannel:AdvPLToJS('setBranch'        , jsonBranch:toJSON())
			oWebChannel:AdvPLToJS('setUserBranches'  , jsonUserBranches:toJSON())
			oWebChannel:AdvPLToJS('setPaisLoc'       , jsonPaisLoc:toJSON())
			oWebChannel:AdvPLToJS('setDateFormat'    , jsonDtFormat:toJSON())
			oWebChannel:AdvPLToJS('setValueFormat'   , jsonValFormat:toJSON())
			oWebChannel:AdvPLToJS('setFunName'       , jsonFunName:toJson() )
			oWebChannel:AdvPLToJS('setSessionStorage', cSrvVersao )
			// objeto para adicionar na sessionStorage de forma dinamica
			jStorage['SrvVersion']  := cSrvVersao
			jStorage['AppVersion']  := SubStr(DtoS(getapoinfo('fina710.app')[4]), 3)
			jStorage['UserName'] := cUserName
			oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())

			FreeObj(jsonCompany)
			FreeObj(jsonBranch)
			FreeObj(jsonUserBranches)
			FreeObj(jsonPaisLoc)
			FreeObj(jsonDtFormat)
			FreeObj(jStorage)
		Case cType == "metrics"
			If __lAcces .And. __lMetric
				nTimeSencs := Secs(ELAPTIME(nStartTime, TIME()))
				// Metrica de tempo m�dio para exibir a tela de Painel de Controle
				FwCustomMetrics():setAverageMetric("MediaCargaNGF", "financeiro-protheus_tempo-conclus�o-processo_seconds", nTimeSencs)
				__lAcces := .F.
			Endif
		Case cType == 'FWLsPutAsyncInfo'
			If __lMetric .And. !Empty(cContent) .And. !__oHashCache:containsKey(cContent) // controle para acionar apenas uma vez enquanto navega pelo NGF
				FWLsPutAsyncInfo("LS006", RetCodUsr(), '06', cContent)
				__oHashCache:put(cContent)
			EndIf
	EndCase

Return

/*/{Protheus.doc} F710CfgOk
    Verifica se o ambiente est� configurado

    @return lOk As Logical, true ou false
    @author renato.ito
    @since 02/03/2021
/*/
Static Function F710CfgOk()

	Local lOk       As Logical

	lOk := .T.

	// Verifica se a pota multiprotocola est� configurada no ambiente
	If lOk
		lOk := F710VMProt()
	EndIf
	// Verifica se exite o campo S_T_A_M_P_ nas tabelas
	If lOk
		lOk := F710VDic()
	EndIf

	// Verifica se j� existe o job configurado
	If lOk
		lOk := F710VJob()
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} IsMProt
Valida porta multiprotocolo

@return lRet
@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F710VMProt() As Logical

Local lRet As Logical

lRet := FindFunction("AmIOnRestEnv") .AND. AmIOnRestEnv()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F710VDic
Valida Dicion�rio

@return lRet
@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F710VDic() As Logical

Local lRet 		As Logical
Local aTables   As Array
Local nTable    As Numeric

lRet := .T.

aTables := STRTOKARR('SE1|SE2|FKD|SC5|SC6|SC7|SC9', '|' )
For nTable := 1 To len(aTables)
	If Ascan(TCStruct(RetSqlName(aTables[nTable])), {|x| x[1] == 'S_T_A_M_P_'}) == 0
		lRet := .F.
	EndIf
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F710VJob
Valida Job

@return lRet
@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F710VJob() As Logical

Local lRet 		As Logical
Local cJob      As Character

lRet := .T.

cJob := FwSchdByFunction("FINA711('" + cEmpAnt + "')")
If (Empty(cJob))
	lRet := .F.
EndIf

Return lRet


/*/{Protheus.doc} MenuDef
    Defini��o de menu de Acesso

    @return Array com o Menu
    @author francisco.oliveira
    @since 05/01/2022
/*/

Static Function MenuDef()
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION "a710Painel"  OPERATION 1 ACCESS 0  // "Painel de Controle"
	ADD OPTION aRotina TITLE STR0007 ACTION "a710MovFin"  OPERATION 2 ACCESS 0 	// "Movimenta��es Financeiras"

	If cPaisLoc == 'BRA'
		ADD OPTION aRotina TITLE STR0016 ACTION "a710ApiCR" OPERATION 3 ACCESS 0 	// "Contas a receber"
		ADD OPTION aRotina TITLE STR0017 ACTION "a710ApiCP" OPERATION 4 ACCESS 0 	// "Contas a pagar"
		ADD OPTION aRotina TITLE STR0009 ACTION "a710ConfCta" OPERATION 5 ACCESS 0 	// "Configura��o de Contas"
	Endif

Return(aRotina)

/*/{Protheus.doc} getMenu710
    Defini��o de privilegio de Acesso ao Menu

    @return Json
    @author francisco.oliveira
    @since 07/01/2022
/*/

Function getMenu710(nRetMnu As Numeric)

	Local jPrivUser	  As Json
	Local cUsersID	  As Character
	Local aRotina	  As Array
	Local nX		  As Numeric
	Local lBolRet  	  As Logical
	Local lAPICP 	  As Character

	Default nRetMnu := 0

	aRotina  	 := MenuDef()
	cUsersID 	 := RetCodUsr(cUserName)
	lBolRet		 := AliasInDic("F79") .and. AliasInDic("F7A") .and. F79->(FieldPos("F79_ESTCOB")) > 0 .and. F79->(FieldPos("F79_QTPROC")) > 0
	lAPICP		 := FindFunction("F717VldUso") .and. F717VldUso()

	jPrivUser	:= JsonObject():New()

	For nX := 1 To Len(aRotina)
		if aRotina[nX][2] == 'a710ApiCP'
			jPrivUser[aRotina[nX][2]] := MPUserHasAccess('FINA710', aRotina[nX][4], cUsersID) .and. lAPICP
		Else
			jPrivUser[aRotina[nX][2]] := MPUserHasAccess('FINA710', aRotina[nX][4], cUsersID)
		Endif

		If jPrivUser[aRotina[nX][2]]
			nRetMnu++
		Endif
	Next nX

	//Acessos que n�o s�o definidos com base nos privilegios
	jPrivUser["a710BolRet"] := lBolRet
Return jPrivUser
