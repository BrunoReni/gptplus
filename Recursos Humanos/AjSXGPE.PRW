#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXGPE.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWLIBVERSION.CH"

Main function GPELoad()

	Local cFunExec  := "GetSrvVersion"
    Local lRet		:= .T.

    If !IsBlind() .And. FwLibVersion() >= "20200727" .And. FindClass( "FWCustomMetrics" ) .And. FindFunction( cFunExec ) .And. &cFunExec.() >= "19.3.0.6"
        fGPEMetrics()
    EndIf

	lRet := fChkConv12()
	If !lRet
		Return
	Endif

Return .T.

/*/{Protheus.doc} fChkConv12
Checa preenchimento de campos P12 pelo GPECONV.
/*/
Function fChkConv12()
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local lTemSRA	:= .T.
	Local lTemSRD	:= .T.
	Local lRhConv := SuperGetMV("MV_RHCONV",,.F.)
	Local cOrder:= ''

	if(lRhConv)
		cOrder:= 'RA_FILIAL+RA_PROCES+RA_TNOTRAB+RA_SEQTURN+RA_REGRA+RA_MAT'		
		SRA->(dbSetOrder(RetOrder("SRA",cOrder)))	
		SRA->(dbGoTop())
		lTemSRA := (!SRA->(Eof()) .AND. Empty(SRA->RA_PROCES))	

		cOrder:= 'RD_FILIAL+RD_PROCES+RD_PERIODO+RD_SEMANA+RD_ROTEIR+RD_CC+RD_MAT'		
		SRD->(dbSetOrder(RetOrder("SRD",cOrder)))
		SRD->(dbGoTop())	
		lTemSRD := (!SRD->(Eof()) .AND. Empty(SRD->RD_PERIODO))

		if(lTemSRA .Or. lTemSRD)
			lRet := .F.
			Final("A base deve ser convertida para atender a P12. Verificar a documentação"," referente ao GPECONV disponivel no TDN no link: http://tdn.totvs.com/x/XMJhE")
		Endif
	endIf

	RestArea(aArea)
Return (lRet)

/*/{Protheus.doc} fGPEMetrics
Captura e envia métricas adicionais do módulo SIGAGPE
@author Allyson Luiz Mesashi
@since 24/01/2023
/*/
Static Function fGPEMetrics()

Local cAPIPEM1      := Iif( !Empty( SuperGetMV("MV_APIPEM1", Nil, "") ), "1", "0" )
Local cAPISWI1      := Iif( !Empty( SuperGetMV("MV_APISWI1", Nil, "") ), "1", "0" )
Local cMDTGPE       := Iif( SuperGetMV("MV_MDTGPE", Nil, "N") == "S" , "1", "0" )
Local cRHNG         := Iif( SuperGetMV("MV_RHNG", Nil, .F.), "1", "0" )
Local cRHTAEUS      := Iif( !Empty( SuperGetMV("MV_RHTAEUS", Nil, "") ), "1", "0" )
Local cSIGAPON      := Iif( SP9->( !Eof() ) .And. SPA->( !Eof() ) .And. SPJ->( !Eof() ), "1", "0" )
Local cTECXRH       := Iif( SuperGetMV("MV_TECXRH", Nil, .F.), "1", "0" )
Local cUSACPER      := Iif( SuperGetMV("MV_USACPER", Nil, .F.), "1", "0" )
Local cTmpAlias     := GetNextAlias()

Local nTotAfast     := 0
Local nTotAtiv      := 0
Local nTotDeslig    := 0
Local nTotFerias    := 0

BeginSql alias cTmpAlias
    SELECT RA_SITFOLH, COUNT(*) AS CONT
    FROM %table:SRA%
    WHERE D_E_L_E_T_= ' ' 
    GROUP BY RA_SITFOLH
EndSql

While (cTmpAlias)->( !EoF() )
    If (cTmpAlias)->RA_SITFOLH == "A"
        nTotAfast += (cTmpAlias)->CONT
    ElseIf (cTmpAlias)->RA_SITFOLH == "D"
        nTotDeslig += (cTmpAlias)->CONT
    ElseIf (cTmpAlias)->RA_SITFOLH == "F"
        nTotFerias += (cTmpAlias)->CONT
    Else
        nTotAtiv += (cTmpAlias)->CONT
    EndIf
    (cTmpAlias)->( dbSkip() )
End

(cTmpAlias)->( dbCloseArea() )

FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-apipem1_info", cAPIPEM1 )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-apiswi1_info", cAPISWI1 )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-mdtgpe_info", cMDTGPE )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-rhng_info", cRHNG )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-rhtaeus_info", cRHTAEUS )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-tecxrh_info", cTECXRH )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_configuracao-mv-usacper_info", cUSACPER )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_utilizacao-sigapon_info", cSIGAPON )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_quantidade-funcionarios-afastados_total", cValToChar(nTotAfast) )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_quantidade-funcionarios-ativos_total ", cValToChar(nTotAtiv) )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_quantidade-funcionarios-desligados_total", cValToChar(nTotDeslig) )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_quantidade-funcionarios-ferias_total", cValToChar(nTotFerias) )

Return
