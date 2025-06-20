#INCLUDE "TOTVS.ch"
#Include "FINA716.ch"

Static __cDateFormat As Character
Static __cValFormat As Character
Static __oHashCache

/*/{Protheus.doc} FINA716
    Chamada do app de aplica��es e emprestimos pelo menu do protheus

    @author Vitor Duca
    @since 23/06/2022
/*/
Function FINA716()
    Local lOk As Logical
	Local cRelease := GetRpoRelease()
	
	If cRelease < "12.1.2210"
		APLEMP_HLP(STR0016, STR0017) //"Rotina dispon�vel a partir do release 12.1.2210" # "Atualize o release para conseguir utilizar a rotina"
		Return
	Endif

	lOk := .T.
	__cDateFormat := getDtFmt()
	__cValFormat  := getValFmt()
	__oHashCache := FwHashMap():New()

	// Verifica se a pota multiprotocola est� configurada no ambiente
	If FindFunction("AmIOnRestEnv")
		If !AmIOnRestEnv()
            APLEMP_HLP(STR0001, STR0009) //"Porta multiprotocolo n�o est� habilitada no ambiente!" # "Ajuste seu ambiente para conseguir utilizar a rotina"
			lOk := .F.
		EndIf
	EndIf

	If lOk
		FwCallApp("FINA710")
	EndIf

Return

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author Vitor Duca
    @since 23/06/2022
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)
	Local jsonCompany      as Json
	Local jsonBranch       as Json
	Local jsonUserBranches as Json
	Local jsonPaisLoc      as Json
	Local jsonDtFormat     as Json
	Local jsonValFormat    as Json
	Local jsonFunName      as Json
	Local aContent         as Array
	Local cFilBkp          as Character
	Local cFnc             as Character // macro executar fun��o tlpp pra n�o gerar erro de compila��o no release 17
	Local jStorage         as Json
	Local cDataBase := Dtos(dDataBase) As Character

	cType   := Upper(cType)

	Do Case
		Case cType == "PRELOAD"
			jsonCompany      := JsonObject():New()
			jsonBranch       := JsonObject():New()
			jsonUserBranches := JsonObject():New()
			jsonPaisLoc      := JsonObject():New()
			jsonDtFormat     := JsonObject():New()
			jsonValFormat    := JsonObject():New()
			jsonFunName      := JsonObject():New()
			jStorage         := JsonObject():New()

			jsonCompany["InternalId"]      := cEmpAnt
			jsonCompany["CorporateName"]   := FWGrpName(cEmpAnt)
			jsonCompany["Code"]            := cEmpAnt
			jsonBranch["CompanyCode"]      := cEmpAnt
			jsonBranch["EnterpriseGroup"]  := cEmpAnt
			jsonBranch["ParentCode"]       := cFilAnt
			jsonBranch["Code"]             := cFilAnt
			jsonBranch["Description"]      := FWFilialName()
			cFnc := 'gfin.util.branchesOfUser()'
			jsonUserBranches["items"]      := &cFnc
			jsonPaisLoc["PaisLoc"]         := cPaisLoc
			jsonDtFormat["DateFormat"]     := __cDateFormat
			jsonValFormat["ValueFormat"]   := __cValFormat
			jsonFunName["FunName"]         := "fina716"
			
			oWebChannel:AdvPLToJS('setCompany'       , jsonCompany:toJSON())
			oWebChannel:AdvPLToJS('setBranch'        , jsonBranch:toJSON())
			oWebChannel:AdvPLToJS('setUserBranches'  , jsonUserBranches:toJSON())
			oWebChannel:AdvPLToJS('setPaisLoc'       , jsonPaisLoc:toJSON())
			oWebChannel:AdvPLToJS('setDateFormat'    , jsonDtFormat:toJSON())
			oWebChannel:AdvPLToJS('setValueFormat'   , jsonValFormat:toJSON())
			oWebChannel:AdvPLToJS('setSessionStorage', "false" )
			oWebChannel:AdvPLToJS('setFunName'       , jsonFunName:toJson())

			// objeto para adicionar na sessionStorage de forma dinamica
			jStorage["AppVersion"]  := SubStr(DtoS(getapoinfo("fina710.app")[4]), 3)
			jStorage['DataBase'] 	:= SubString(cDataBase,1,4) + "-" + SubString(cDataBase,5,2) + "-" + SubString(cDataBase,7,2)
			jStorage['LayoutSM0'] 	:=  FWSM0Layout()

			oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())

			FreeObj(jsonCompany)
			FreeObj(jsonBranch)
			FreeObj(jsonUserBranches)
			FreeObj(jsonPaisLoc)
			FreeObj(jsonDtFormat)
			FreeObj(jStorage)
		/*
		Trecho mantido para metricas futuras

		Case cType == 'FWLsPutAsyncInfo'
			If !Empty(cContent) .And. !__oHashCache:containsKey(cContent) // controle para acionar apenas uma vez enquanto navega
				FWLsPutAsyncInfo("LS006", RetCodUsr(), '06', cContent)
				__oHashCache:put(cContent)
			EndIf
		*/
		Case cType == 'GETSXENUM'
			If !Empty(cContent)

				aContent := StrTokArr2(cContent, '|', .T.)

				If Len(aContent) == 4

					DbSelectArea("SEH")

					cFilBkp := cFilAnt

					If !Empty(aContent[1])
						cFilAnt := aContent[1]
					EndIF
					
					oWebChannel:AdvPLToJS('RETSXENUM', GetSxENum(Upper(aContent[2]), Upper(aContent[4]),,Val(aContent[3])))

					cFilAnt := cFilBkp

				Else
					oWebChannel:AdvPLToJS('RETSXENUM', ' ')
				EndIf
				
			EndIf
		Case cType == 'CONFIRMSX8'

			cFilBkp := cFilAnt
			cFilAnt := cContent

			ConfirmSX8()

			cFilAnt := cFilBkp
		Case cType == 'ROLLBACKSX8'

			cFilBkp := cFilAnt
			cFilAnt := cContent

			RollBackSx8()

			cFilAnt := cFilBkp
	End Case

Return

/*/{Protheus.doc} APLEMP_HLP
Montagem do HELP
@type  Static Function
@author Vitor Duca
@since 09/10/2021
@version 1.0
@return
/*/
static function APLEMP_HLP(cMessage As Character, cSolucao As Character)
	Local cMsg 		AS Character
	Local cTitulo 	AS Character
	Local aBtLinks 	AS Array

	cTitulo  := STR0005 //"Aplica��es e empr�stimos"
	aBtLinks := ARRAY(2,2)

	cMsg := "<font size='6' color='#0c9abe'><b>HELP - " + STR0006 + "</b></font><br/><br/>" //Ambiente incompat�vel

	cMsg += "<font size='4' color='#444'><b>" + STR0007 + "</b></font><br/>" //"Ocorr�ncia"
	cMsg += "<font size='4' color='#666'>" +  cMessage
	cMsg += "</font><br/><br/>"

	cMsg += "<font size='4' color='#444'><b>" + STR0008 + "</b></font><br/>" //"Solu��o"
	cMsg += "<font size='4' color='#666'>" + cSolucao + "</font><br/><br/>" 

	cMsg += "<font size='4' color='#444'><b>" + STR0010 + "</b></font>" //"Para maiores informa��es acesse:"

	aBtLinks[1,1] :=  STR0011 + " - FINA716" //"Documento de refer�ncia "
	aBtLinks[1,2] := "https://tdn.totvs.com/pages/releaseview.action?pageId=680254799"

	FinHelp(cTitulo, cMsg, aBtLinks, 250, 600)

Return

/*/{Protheus.doc} getDtFmt
    Pega o formato da data baseado
	na configura��o do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getDtFmt() As Character
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

Return cFormat

/*/{Protheus.doc} getValFmt
    Pega o formato do valor baseado
	na configura��o do Ini.

    @author Luiz.nai
    @since 16/02/2022
/*/
Static Function getValFmt() As Character
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

/*/{Protheus.doc} FAplEmpNew
	Verifica o release e exibe a mensagem de descontinua��o das rotinas de
	aplica��es e emprestimos
	@type  Function
	@author Vitor
	@since 14/06/2022
	@version 1.0
	@param cRotina, Character, Nome da rotina que sera descontinuada
	@return lRet, Logical, Define se ira abrir a nova rotina
/*/
Function FAplEmpNew(cRotina As Character) As Logical
	Local cRelease As Character
	Local lRet As Logical
	Local lExibeMsg As Logical
	Local cLinkTDN As Character
	Local cDataExp As Character
	Local cMsgAdic As Character

	DEFAULT cRotina := ""

	cRelease := GetRpoRelease()
	lRet := .F.
	lExibeMsg := .F.
	cLinkTDN := "https://tdn.totvs.com/pages/viewpage.action?pageId=680254799"
	cDataExp := "20221231"
	cMsgAdic := ""

	Do Case
		Case cRelease == "12.1.033" .and. Date() <= CTOD("31/12/2022")
			lRet := .F.
			lExibeMsg := .T.
		Case cRelease == "12.1.033" .and. Date() > CTOD("31/12/2022") .OR. cRelease > "12.1.033"
			lRet := .T.
	End Case

	// Verifica se a pota multiprotocola est� configurada no ambiente
	If FindFunction("AmIOnRestEnv")
		If !AmIOnRestEnv()
			cMsgAdic := STR0012 //"Por�m verificamos que a porta multiprotocolo n�o est� habilitada no ambiente."
		EndIf
	EndIf

	If lExibeMsg .and. !IsBlind()
		lRet := MsgYesNo(STR0013, STR0014) //"O processo de aplica��es e empr�stimo foi modernizado e j� existe uma nova vers�o dispon�vel para utiliza��o. Deseja abrir a nova vers�o ?" # "Aplica��es e empr�stimos"
	Endif

	If !lRet .and. cRelease == "12.1.033"
		IF FINDFUNCTION( "FinExpRot" )
			FinExpRot(cRotina, STR0015 + cMsgAdic, cLinkTDN, cDataExp) //"A rotina de aplica��es e empr�stimos foi modernizada e j� esta disponivel para uso. "
		Endif
	Endif

	If lRet
		FWLsPutAsyncInfo("LS006", RetCodUsr(), '06', 'FINA716')
	Endif

Return lRet
