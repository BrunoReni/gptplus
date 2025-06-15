#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TAFRemoveCompany
API Reinf - Remove dados do contribuinte reinf da base de dados do RET 

@author Carlos Eduardo Boy / Renan Gomes / Wesley Matos
@since 19/05/2022
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL reinfContributor DESCRIPTION "API Reinf - Evento R-1000 - Informa��es do contribuinte."
    WSDATA companyId	AS STRING

    WSMETHOD POST removeCompany; 
        DESCRIPTION 'Remove dados do contribuinte Reinf da base de dados do RET';
        WSSYNTAX "/api/reinf/v1/reinfContributor/removeCompany?{companyId}";
        PATH '/api/reinf/v1/reinfContributor/removeCompany';
		TTALK "v1";
 
END WSRESTFUL 

//------------------------------------------------------------------------------
/*/{Protheus.doc} DELETE
M�todo DELETE para remover os dados do contribuinte Reinf da base de dados do RET

@param companyId - Empresa e Filial que far� a requisi��o no formato Empresa|Filial

@return lRet - Informa se a requisi��o foi realizada com sucesso

@author Carlos Eduardo Boy / Renan Gomes / Wesley Matos
@since 19/05/2022
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSMETHOD POST removeCompany QUERYPARAM companyId WSSERVICE ReinfContributor
Local lRet             := .T.
Local nCodeError       := 404
Local cMessage         := EncodeUTF8("Empresa|Filial n�o informado no par�metro 'companyId' ." )
Local cDetailedMessage := EncodeUTF8("Verifique o par�metro 'companyId' enviado na requisi��o.")
Local aCompany		   := {}
Local oResult 		   := JsonObject():New()
Local cEmpRequest	   := ""
Local cFilRequest	   := ""
Local aRetTrans		   := {}
Local nTryMonit		   := 0
Local cMsgRet		   := ""
Local cCode			   := "LS006"
Local cUser			   := RetCodUsr()
Local cModule		   := "84"
Local cRoutine 		   := "TAFReinfRemovContrib"

Private aRetMonit      := {} //Vari�vel precisa ser private para facilitar as valida��es com a fun��o Type()

::SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault(404,cMessage,.T.,,cDetailedMessage)
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

		If PrepEnv( cEmpRequest, cFilRequest )
		//Transmite a exclus�o do contribuinte para o RET
			
			If FindFunction( "FWLSPutAsyncInfo" )
        		FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
    		EndIf 

			TafLimpRei(.t.,@aRetTrans,.T.,@cMsgRet)
			//Se conseguiu transmitir vai ser verdadeiro, caso controrio vai ser falso e retorna o erro na API.
			if len(aRetTrans) > 0 .and. aRetTrans[1]
				//Ap�s esse passo se conseguiu transmitir ser� necess�rio monitorar e verificar se teve sucesso ou rejei��o, ambos devem retornar .t.
				//para o front o que vai mudar � somente a mensagem 

				aRegRec := {aRetTrans[4]}
				aEvents := TAFRotinas( "R-1000", 4, .F., 5 )
				
				aRetMonit := TAFProc10TSS( .F., aEvents, /*cStatus*/, /*aIDTrab*/, /*cRecnos*/, /*lEnd*/,/*@cMsgRet*/, /*aFiliais*/, /*dDataIni*/, /*dDataFim*/, /*lEvtInicial*/, /*lCommit*/, aRegRec, /*cIDEnt*/ )	
				for nTryMonit := 1 to 5
					if len(aRetMonit) > 0 
						if Type('aRetMonit[1][1]:CSTATUS') == "C" .and. aRetMonit[1][1]:CSTATUS == '2'
							Sleep(1000)
							aRetMonit := TAFProc10TSS( .F., aEvents, /*cStatus*/, /*aIDTrab*/, /*cRecnos*/, /*lEnd*/,/*@cMsgRet*/, /*aFiliais*/, /*dDataIni*/, /*dDataFim*/, /*lEvtInicial*/, /*lCommit*/, aRegRec, /*cIDEnt*/ )	
						else
							exit
						Endif
					Endif
				next
				
				//Se o TSS retornar algo no monitoramento, monto msg de retorno
				If len(aRetMonit) > 0
					MsgRetWS(@oResult,aRetMonit[1],cMsgRet)
				Endif
				
				::SetResponse(oResult:toJSON())
			else
				if !Empty(aRetTrans[2]) //Se n�o conseguir conex�o com TSS
					oResult := JSONObject():New()
					oResult["statusReturn"]   := .f.
					oResult["messageReturn"]  := EncodeUTF8(aRetTrans[2])
				elseIf aRetTrans[3][1][5] == "S" //Se for error de schema, apresento o retorno do TSS
					oResult := JSONObject():New()
					oResult["statusReturn"]   := .f.
					oResult["messageReturn"]  := EncodeUTF8(aRetTrans[3][1][4])
				Endif
				::SetResponse(oResult:toJSON())
			endif	
		Else
			lRet     := .F.
			cMessage := EncodeUTF8( "Falha na prepara��o do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage)
		EndIf
	EndIf
EndIf

FreeObj( oResult )
oResult := Nil

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MsgRetWS
Fun��o para tratamento de erros para retornar uma mensagem mais amig�vel para o cliente
@return nil
@author Carlos Eduardo Boy / Renan Gomes / Wesley Matos
@since 25/05/2022
@version 1.0 
/*/
Static Function MsgRetWS(oResult,aRetTSS,cMsgRet)
	Local cMessage := ''
	Local nPosIni  := 0
	Local nPosFim  := 0

	Private aMonitoring := {}
	
	Default oResult := JSONObject():New()
	Default aRetTSS := {}
	Default cMsgRet := ""

	aMonitoring := aClone(aRetTSS) //Clone para usar a fun��o Type e facilitar a verifica��o do objeto

	if len(aMonitoring) > 0 .and. Type('aMonitoring[1]:CSTATUS') == "C" .and. Type('aMonitoring[1]:CXMLRETEVEN') == "C"
		If aMonitoring[1]:CSTATUS == "5" .and. "<descRetorno>SUCESSO</descRetorno>" $ aMonitoring[1]:CXMLRETEVEN
			oResult := JSONObject():New()
			oResult["statusReturn"]   := .T.
			oResult["messageReturn"]  := EncodeUTF8('Contribuinte removido com sucesso do RET do ambiente de Pr� Produ��o')
		ElseIf aMonitoring[1]:CSTATUS == "5" .and. "<dscResp>N�o existem informa��es deste contribuinte" $ aMonitoring[1]:CXMLRETEVEN
			oResult := JSONObject():New()
			oResult["statusReturn"]     := .F.
			oResult["messageReturn"]  := EncodeUTF8('N�o existem informa��es deste contribuinte, na base de dados, para serem exclu�das.')
		//<ocorrencias><tipo>1</tipo><codigo>MS0092</codigo><descricao>Vers�o do lote inv�lida. Deve ser utilizada a vers�o 1.05.01. O lote enviado � do modelo , porem esse servi�o recebe somente lotes do modelo S�ncrono.</descricao></ocorrencias>
		ElseIf aMonitoring[1]:CSTATUS == "5" .and. ( "MS0092" $ Upper(aMonitoring[1]:CXMLRETEVEN) .Or. "LOTE INV" $ Upper(aMonitoring[1]:CXMLRETEVEN) )			
			cMessage := EncodeUTF8( Alltrim( aMonitoring[1]:CXMLRETEVEN ) )
			if "<descricao>" $ cMessage
				nPosIni := At( "<descricao>", cMessage ) + len( "<descricao>" )
				nPosFim := At( "</descricao>", cMessage ) - nPosIni
				if nPosIni > 0 .And. nPosFim > 0
					cMessage := SubStr(cMessage,nPosIni,nPosFim)
				endif
			endif
			oResult := JSONObject():New()
			oResult["statusReturn"]   := .F.
			oResult["messageReturn"]  := cMessage
		Elseif aMonitoring[1]:cSTATUS == "2"
			oResult := JSONObject():New()
			oResult["statusReturn"]   := .T.
			oResult["messageReturn"]  := EncodeUTF8("Contribuinte removido, por�m ainda aguardando retorno do GOV. Favor acompanhar o card de Monitoramento para mais detalhes.")
		Endif		
	else
		oResult := JSONObject():New()
		oResult["statusReturn"]   := .f.
		oResult["messageReturn"]  :=  EncodeUTF8(iif(Empty(cMsgRet),"N�o foi possivel remover o contribuiente corretamente. Favor acompanhar o card de Monitoramento para mais detalhes.", cMsgRet))
	endif
	
Return
