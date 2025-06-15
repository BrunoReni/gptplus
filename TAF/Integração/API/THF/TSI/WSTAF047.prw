#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TSIServiceStatus
API TAF Fiscal TSI - Consulta o status do servi�o do schedule, se est� configurado e/ou ativo.
@author Karen Honda
@since 25/04/2022
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL TSIServiceStatus DESCRIPTION "API TSIServiceStatus - Consulta o status do servi�o, se est� configurado e/ou ativo."
	WSDATA companyId	AS STRING

	WSMETHOD GET TSIServiceStatus;
		DESCRIPTION "Consulta o status do servi�o, se est� configurado e/ou ativo";
		WSSYNTAX "/api/tsi/v1/TSIServiceStatus/?{companyId}";
		PATH "/api/tsi/v1/TSIServiceStatus/";
		TTALK "v1";

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	M�todo para obter o status do servi�o, se est� configurado e/ou ativo.
@author			Karen Honda
@since			25/04/2022
@return			lRet - Indica se o m�todo aceitou a execu��o do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET TSIServiceStatus QUERYPARAM companyId WSRESTFUL TSIServiceStatus
Local lRet             as logical
Local aRet             as array
Local nCodeError       as numeric
Local cMessage         as character
Local cDetailedMessage as character
Local cHelpUrl         as character
Local aCompany		   as array
Local oResponse        as object
Local oStatusSched	   as object
Local cEmpRequest	   as character
Local cFilRequest	   as character

aRet             := {.F., .F.}
nCodeError       := 404
cMessage         := EncodeUTF8("Empresa|Filial n�o informado no par�metro 'companyId' ." )
cDetailedMessage := EncodeUTF8("Verifique o par�metro 'companyId' enviado na requisi��o.")
cHelpUrl         := EncodeUTF8("https://api.totvs.com.br/apidetails/TSIServiceStatus_v1_000.json")
aCompany		 := {}
oResponse        := nil
oStatusSched	 := nil
cEmpRequest	     := ""
cFilRequest	     := ""
lRet             := .T.
//-----------------------------------------------
// Inicializa��o vari�veis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault(404,cMessage,.T.,,cDetailedMessage,cHelpUrl)
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage,cHelpUrl)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

		If PrepEnv( cEmpRequest, cFilRequest )
            aRet := TafStSched("TSI", cEmpRequest) 

			oResponse     := JSONObject():New()
            oStatusSched  := JSONObject():New()
            oStatusSched["configuredService"]   := aRet[1]
            oStatusSched["activeService"]       := aRet[2]

            oResponse["status"] := oStatusSched
			self:SetResponse(oResponse:toJSON())

		Else
			lRet     := .F.
			cMessage := EncodeUTF8( "Falha na prepara��o do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage,cHelpUrl)
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafStSched
@type			function
@description	fun��o que verifica se o servi�o TSI est� configurado no schedule e se schedule est� ativo
@author			Karen Honda
@since			25/04/2022
@return			aRet[1] - Indica se o servi�o TSI est� configurado no schedule
                aRet[2] - Indica se o schedule est� ativo
/*/
//---------------------------------------------------------------------
Static Function TafStSched(cService, cEmpSchd)
Local lServCfg      as logical
Local lServAtivo    as logical
Local cSchedID      as character
Local cEmpFil       as character
Local aFilsSchd     as array 
Local aRet          as array
Local nTamGrp		as numeric

Default cService := "TSI"
Default cEmpSchd := cEmpAnt

lServCfg := .F.
lServAtivo := .F.
aFilsSchd := {}
aRet := {}
nTamGrp := Len(cEmpSchd)

cSchedID := FWSchdByFunction(cService)

If !Empty(cSchedID)

    cEmpFil := FWSchdEmpFil(cSchedID)
    aFilsSchd := StrToArray(cEmpFil,";")
    //verifica se posusi o agendamento para o grupo de empresa passado como par�metro
    If AScan(aFilsSchd,{|x| left(x,nTamGrp) == cEmpSchd}) > 0
		lServCfg := ExistStamp(,,)
    EndIf
EndIf    

//verifica se schedule est� ativo
lServAtivo := FWSchdAvaiable()

aRet := {lServCfg, lServAtivo} // [1]- Servi�o configurado [2] - Servi�o Ativo 
Return aRet
