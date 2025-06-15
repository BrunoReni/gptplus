#Include 'Protheus.ch'
#Include 'GPEM038.ch'

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM038B
@Author   isabel.noguti
@Since    21/11/2022
@Version  1.0
/*/
Function GPEM038B()
Return()

/*/{Protheus.doc} fNew2501
Função responsável por gerar o evento S-2501 - Informações de Tributos Decorrentes de Processo Trabalhista
@Author.....: isabel.noguti
@Since......: 18/11/2022
@Version....: 1.0
/*/
Function fNew2501( dDataIni, aArrayFil, lRetific, aLogsOk, aLogsErr )
	Local aErrTaf		:= {}
	Local cAliasQry		:= GetNextAlias()
	Local cChaveE0F		:= ""
	Local cFilEnv		:= ""
	Local cIdLog		:= ""
	Local cOldProc		:= ""
	Local cProJud		:= ""
	Local cPerAp		:= ""
	Local cQuery		:= ""
	Local cStatus		:= "-1"
	Local cXml			:= ""
	Local lRet			:= .F.
	Local lRetXml		:= .F.
	Local nFil		 	:= 0
	Local nCont			:= 0
	Local lProcessa		:= .F.
	Local lRetif		:= .F.
	Local cMsgErr		:= ""
	Local aDadosE0E		:= {}
	Local aIdeTrab		:= {}
	Local aInfoIR		:= {}
	Local aInfoBs		:= {}
	Local cObs			:= ""
	Local aInfoC		:= {}
	Local cStatPred		:= "-1"
	Local cRjeKey		:= ""
	Local cChaveMid		:= ""
	Local lNovoRJE		:= .T.
	Local cOperEvt		:= "I"
	Local cOperNew		:= "I"
	Local cRetfEvt		:= "1"
	Local cRecibEvt		:= ""
	Local cRecibAnt		:= ""
	Local nRecEvt		:= 0
	Local aDadosRJE		:= {}
	Local cTafKey		:= ""

	Private cTpInsc		:= ""
	Private cNrInsc		:= ""
	Private lAdmPubl	:= .F.
	Private cIdXml		:= ""
	Private cRetfNew	:= "1"
	Private cRecibXML	:= ""

	Default dDataIni	:= CtoD("")
	Default aArrayFil	:= {}
	Default lRetific	:= .F.
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}

	cCpfDe	:= If( Empty(cCpfDe), '0', cCpfDe )
	cProcDe := If( Empty(cProcDe), '0', cProcDe )
	cPerAp	:= AnoMes(dDataIni)

	For nFil := 1 To Len(aArrayFil)
		cFilIn	:= xFilial("RE0", aArrayFil[nFil][1])
		cFilEnv	:= aArrayFil[nFil][1]

		If lMiddleware
			fPosFil( cEmpAnt, cFilEnv )
			cStatPred := "-1"
			If fVld1000( cPerAp, @cStatPred, cFilEnv )
				cTpInsc	 := ""
				cNrInsc	 := "0"
				lAdmPubl := .F.
				cIdXml	 := ""
				aInfoC	 := fXMLInfos(cPerAp)
				If Len(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					cNrInsc  := aInfoC[2]
					lAdmPubl := aInfoC[4]
				EndIf
			Else
				cMsgErr := cFilEnv + " - " + OemToAnsi(STR0045)//"### - Registro do evento S-1000"
				cMsgErr += If(cStatPred == "-1", OemToAnsi(STR0046), "")	//" não localizado na base de dados"
				cMsgErr += If( cStatPred == "1", OemToAnsi(STR0047), "")	//" não transmitido para o governo"
				cMsgErr += If( cStatPred == "2", OemToAnsi(STR0048), "")	//" aguardando retorno do governo"
				cMsgErr += If( cStatPred == "3", OemToAnsi(STR0049), "")	//" retornado com erro do governo"
				aAdd( aLogsErr, cMsgErr)
				Loop
			EndIf
		EndIf

		cQuery := "SELECT E0E.E0E_PRONUM, E0E.E0E_RECLAM, E0E.E0E_CMEM, E0E.E0E_COMPET, E0E.E0E_BSINSS, E0E.E0E_BS13, E0E.E0E_RDIRRF, E0E.E0E_RDIR13, RE0.RE0_PROJUD, RD0.RD0_CIC "
		cQuery += "FROM " + RetSqlName('E0E') + " E0E "
		cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0E","RE0") + " AND E0E.E0E_PRONUM=RE0.RE0_NUM "
		cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0E","RD0") + " AND E0E.E0E_RECLAM=RD0.RD0_CODIGO " //observ
		cQuery += "WHERE E0E.E0E_FILIAL IN ('" + cFilIn + "') "
		cQuery +=	"AND E0E.E0E_PERAP = '" + cPerAp + "' "
		cQuery += 	"AND E0E.E0E_PRONUM IN (SELECT RE0.RE0_NUM "
		cQuery +=							"FROM " + RetSqlName('RE0') + " RE0 "
		cQuery +=						 	"WHERE RE0.RE0_FILIAL IN ('" + cFilIn + "') "
		cQuery +=							"AND RE0.RE0_PROJUD BETWEEN '" + cProcDe + "' AND '" + cProcAte + "' "
		cQuery +=							"AND RE0.RE0_PROJUD IN (SELECT RE0_PROJUD "
		cQuery +=													"FROM " + RetSqlName('RE0') + " RE0 "
		cQuery += 													"INNER JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("RE0","RD0") + " AND RE0.RE0_RECLAM = RD0.RD0_CODIGO "
		cQuery +=													"WHERE RD0.RD0_CIC BETWEEN '" + cCpfDe + "' AND '" + cCpfAte + "' "
		cQuery +=													"AND RD0.D_E_L_E_T_ = ' ') "
		cQuery +=							"AND RE0.D_E_L_E_T_ = ' ') "
		cQuery += 	"AND E0E.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY RE0.RE0_PROJUD, E0E.E0E_RECLAM, E0E.E0E_COMPET "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		While (cAliasQry)->(!EoF())

			If !(cAliasQry)->RE0_PROJUD == cOldProc
				lRet := .T.
				cObs		:= ""
				lProcessa	:= .T.
				cOldProc	:= (cAliasQry)->RE0_PROJUD
				cIdLog		:= " - " + STR0042 + cOldProc //" - Processo: ###"

				If lMiddleware

					lNovoRJE	:= .T.
					cStatus		:= "-1"
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					nRecEvt		:= 0
					cRecibEvt	:= ""
					cRecibAnt	:= ""

					cRjeKey		:= Padr( cFilEnv + cOldProc + cPerAp, fTamRJEKey(), " ")
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2501" + cRjeKey + cPerAp
					GetInfRJE( 2, cChaveMid, @cStatus, @cOperEvt, @cRetfEvt, @nRecEvt, @cRecibEvt, @cRecibAnt )

					If cStatus $ "1/3"
						cOperNew 	:= cOperEvt
						cRetfNew	:= cRetfEvt
						lNovoRJE	:= .F.
						If cRetfNew == "2"
							cRecibXML := cRecibAnt
						EndIf
					ElseIf cStatus == "4"
						cOperNew 	:= "A"
						cRetfNew	:= "2"
						cRecibXML	:= cRecibEvt
						cRecibAnt	:= cRecibEvt
						cRecibEvt	:= ""
					EndIf
				Else
					cStatus := TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 5 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO já que padrão da rotina manda indice 2
				EndIf

				cMsgErr	:= If(!lRetific .And. (cStatus == "4" .Or. cRetfNew == "2"), OemToAnsi(STR0044), "")	//"Evento ja foi integrado anteriormente, selecione a opção de retificação "
				cMsgErr	:= If(cStatus == "2", OemToAnsi(STR0048), cMsgErr )				//"aguardando retorno do governo
				If !Empty(cMsgErr)
					lProcessa := .F.
					aAdd(aLogsErr, cIdLog + " - " + cMsgErr)
					(cAliasQry)->(DbSkip())
					Loop
				EndIf

				lRetif := If(cStatus == "4", lRetific, .F.)
				cProJud := AllTrim((cAliasQry)->RE0_PROJUD)
			EndIf
			If lProcessa

				If (cAliasQry)->E0E_RECLAM == "OBSERV"
					cObs := AllTrim(MSMM((cAliasQry)->E0E_CMEM,,,,3,,,"E0E",,"RDY"))
				else
					If aScan(aIdeTrab, {|x| x == (cAliasQry)->RD0_CIC }) == 0
						Aadd(aIdeTrab, (cAliasQry)->RD0_CIC	)

						cChaveE0F := cFilIn + (cAliasQry)->E0E_PRONUM + (cAliasQry)->E0E_RECLAM + cPerAp + "999999" + "1"
						DbSelectArea("E0F")
						If E0F->( dbSeek(cChaveE0F)) //E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_IDTRIB
							While E0F->( E0F_FILIAL + E0F_PRONUM + E0F_RECLAM + E0F_PERAP + E0F_COMPET + E0F_TIPO) == cChaveE0F
								aAdd(aInfoIR, {	(cAliasQry)->RD0_CIC		,;//1- cpfTrab
												E0F->E0F_TPCR				,;//2- tpCR
												AllTrim(Str(E0F->E0F_VRCR))	})//3- vrCR
								E0F->( dbSkip())
							End
						EndIf
					EndIf

					If aScan(aDadosE0E, {|x| x[1]+x[2] == (cAliasQry)->RD0_CIC + (cAliasQry)->E0E_COMPET }) == 0
						Aadd(aDadosE0E, {	(cAliasQry)->RD0_CIC					,;//1- cpfTrab
											(cAliasQry)->E0E_COMPET					,;//2- perRef
											AllTrim(Str((cAliasQry)->E0E_BSINSS))	,;//3- bsMensal
											AllTrim(Str((cAliasQry)->E0E_BS13))		,;//4- bs13
											AllTrim(Str((cAliasQry)->E0E_RDIRRF))	,;//5- rendIR
											AllTrim(Str((cAliasQry)->E0E_RDIR13))	})//6- rendIR13

						cChaveE0F := cFilIn + (cAliasQry)->E0E_PRONUM + (cAliasQry)->E0E_RECLAM + cPerAp + (cAliasQry)->E0E_COMPET + "2"
						DbSelectArea("E0F")
						If E0F->( dbSeek(cChaveE0F))
							While E0F->( E0F_FILIAL + E0F_PRONUM + E0F_RECLAM + E0F_PERAP + E0F_COMPET + E0F_TIPO ) == cChaveE0F
								aAdd(aInfoBs, {	(cAliasQry)->RD0_CIC		,;//1- cpf
												(cAliasQry)->E0E_COMPET		,;//2- perRef
												E0F->E0F_TPCR				,;//3- tpCR
												AllTrim(Str(E0F->E0F_VRCR))	})//4- vrCR
								E0F->( dbSkip())
							End
						EndIf
					EndIf
				EndIf

			EndIf

			(cAliasQry)->(DbSkip())

			If cProJud == AllTrim((cAliasQry)->RE0_PROJUD)
				Loop
			ElseIf Len(aDadosE0E) > 0

				If lMiddleware
					aDadosRJE := {}
					cIdXml := If( Empty(cIdXml), aInfoC[3], fXMLInfos(cPerAp)[3] ) //gerar id por evento, demais infos são por filial
					aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2501", cPerAp, cRjeKey, cIdXml, cRetfNew, "12", "1", Date(), Time(), cOperNew, cRecibEvt, cRecibAnt } )
				EndIf
				Begin Transaction
					lRetXml := fXML2501(@cXml, lRetif, cProJud, cPerAp, aIdeTrab, aDadosE0E, aInfoBs, aInfoIR, cObs )
					If lRetXml
						If lMiddleware
							If fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
								aAdd(aLogsOk, cIdLog )
							EndIf
						Else
							cTafKey := "S2501" + cOldProc + cPerAp
							aErrTaf := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey, "3", "S-2501", , , , , , "GPE" )

							If Len(aErrTaf) == 0
								aAdd( aLogsOk, cIdLog )
							else
								aAdd( aLogsErr, cIdLog )
								For nCont := 1 to Len(aErrTaf)
									aAdd( aLogsErr, aErrTaf[nCont])
								Next
							EndIf
						EndIf
					EndIf
				End Transaction
			EndIf
			cXml		:= ""
			aIdeTrab	:= {}
			aInfoIR		:= {}
			aDadosE0E	:= {}
			aInfoBs		:= {}
			cObs		:= ""
			cProJud		:= ""
			cLogId		:= ""
		EndDo
		(cAliasQry)->(dbCloseArea())

	Next nFil
	If !lRet
		aAdd( aLogsErr, OemToAnsi(STR0041) ) //"Nenhum registro foi localizado, verifique os parametros selecionados"
	Endif


Return lRet

/*/{Protheus.doc} fXML2501
Geração XML do evento S-2501
@Author.....: isabel.noguti
@Since......: 17/11/2022
@Version....: 1.0
/*/
Static Function fXML2501( cXml, lRetif, cProJud, cPerAp, aIdeTrab, aDadosE0E, aInfoBs, aInfoIR, cObs )
	Local lRet		:= .F.
	Local nTrab		:= 0
	Local nE		:= 0
	Local nF		:= 0
	Local cVersMw	:= ""
	Local cTpAmb

	Default lRetif		:= .F.
	Default cProJud		:= ""
	Default cPerAp		:= ""
	Default aIdeTrab	:= {}
	Default aDadosE0E	:= {}
	Default aInfoBs		:= {}
	Default aInfoIR		:= {}
	Default cObs		:= ""

	If lMiddleware
		fVersEsoc( "S2200", , , , , , @cVersMw, , @cTpAmb ) //lista do gpem017
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtContProc/v" + cVersMw + "'>"
		cXML += 	"<evtContProc Id='" + cIdXml + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cTpAmb, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )//<ideEmpregador>
	Else
		cXml := '<eSocial>'
		cXml += 	'<evtContProc>'
		If lRetif
			cXml += 		'<ideEvento>'
			cXml +=				'<indRetif>2</indRetif>'
			cXml +=			'</ideEvento>'
		EndIf
	EndIf

	cXml += 			'<ideProc>'
	cXml += 				'<nrProcTrab>' + cProJud + '</nrProcTrab>' //RE0_PROJUD
	cXml += 				'<perApurPgto>' + If( !lMiddleware, cPerAp, SubStr(cPerAp,1,4) + "-" + SubStr(cPerAp,5,2) ) + '</perApurPgto>' //AAAA-MM E0E_PERAP
	If !Empty(cObs)
		cXml +=				'<obs>' + cObs + '</obs>' //E0E_CMEM
	EndIf
	cXml += 			'</ideProc>'
//For cpf
	For nTrab := 1 to Len(aideTrab)
		cXml += 		"<ideTrab cpfTrab='" + aideTrab[nTrab] + "'>"
		For nE := 1 to Len(aDadosE0E)
			If aDadosE0E[nE][1] == aideTrab[nTrab]
				cXml +=		"<calcTrib perRef='" +  If( !lMiddleware, aDadosE0E[nE][2], SubStr(aDadosE0E[nE][2],1,4) + "-" + SubStr(aDadosE0E[nE][2],5,2) ) + "' "
				cXml +=		"vrBcCpMensal='" + aDadosE0E[nE][3] + "' vrBcCp13='" + aDadosE0E[nE][4] + "' vrRendIRRF='" + aDadosE0E[nE][5] + "' vrRendIRRF13='" + aDadosE0E[nE][6] + "'>"

				For nF := 1 to Len(aInfoBs)
					If aInfoBs[nF][1] == aideTrab[nTrab] .And. aInfoBs[nF][2] == aDadosE0E[nE][2] //cpf/perRef
						cXml += "<infoCRContrib tpCR='" + aInfoBs[nF][3] + "' vrCR='" + aInfoBs[nF][4] + "'>"
						cXml += '</infoCRContrib>'
					EndIf
				Next nF
				cXml += 	'</calcTrib>'
			EndIf
		Next nE

		For nF := 1 to Len(aInfoIR)//tipo1
			If aInfoIR[nF][1] == aideTrab[nTrab]
				cXml += 	"<infoCRIRRF tpCR='" + aInfoIR[nF][2] + "' vrCR='" + aInfoIR[nF][3] + "'>"
				cXml += 	'</infoCRIRRF>'
			EndIf
		Next nF
		cXml += 		'</ideTrab>'

	Next nTrab
	cXml += 	'</evtContProc>'
	cXml += '</eSocial>'

	If !Empty(cXml)
		GrvTxtArq(AllTrim(cXml), "S2501", cPerAp + cProJud )
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} fNew3500
Função responsável por gerar o evento S-2501 - Informações de Tributos Decorrentes de Processo Trabalhista
@Author.....: isabel.noguti
@Since......: 18/11/2022
@Version....: 1.0
/*/
Function fNew3500(dDataIni, dDataFim, aArrayFil,aLogsOk, aCheck, aLogsErr )
	Local cAliasQry		:= GetNextAlias()
	Local cFilEnv		:= ""
	Local cIdLog		:= ""
	Local cOldProc		:= ""
	Local cProJud		:= ""
	Local cPerAp		:= ""
	Local cQuery		:= ""
	Local cStatus		:= "-1"
	Local cXml			:= ""
	Local lRet			:= .F.
	Local lProcessa		:= .F.
	Local cMsgErr		:= ""
	Local cEvtLog		:="Registro S-3500 do Processo: "
	Local cChaveE0F		:= ""
	Local nFil 			:= 0
	Local lRetXML		:= .T. 
	Local cChaveObs		:= ""

	Default dDataIni	:= CtoD("")
	Default aArrayFil	:= {}
	Default lRetific	:= .F.
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}


	cCpfDe	:= If( Empty(cCpfDe), '0', cCpfDe )
	cProcDe := If( Empty(cProcDe), '0', cProcDe )
	cPerAp	:= AnoMes(dDataIni)

	For nFil := 1 To Len(aArrayFil)
		cFilIn := xFilial("RE0", aArrayFil[nFil][1])
		cFilEnv := aArrayFil[nFil][1]

		cQuery := "SELECT E0E.E0E_PRONUM, E0E.E0E_RECLAM,E0E.E0E_COMPET,RE0.RE0_PROJUD, RD0.RD0_CIC "
		cQuery += "FROM " + RetSqlName('E0E') + " E0E "
		cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON E0E.E0E_FILIAL=RE0.RE0_FILIAL AND E0E.E0E_PRONUM=RE0.RE0_NUM "
		cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON E0E.E0E_RECLAM=RD0.RD0_CODIGO " //observ
		cQuery += "WHERE E0E.E0E_FILIAL IN ('" + cFilIn + "') "
		cQuery +=	"AND E0E.E0E_PERAP = '" + cPerAp + "' "
		cQuery += 	"AND E0E.E0E_PRONUM IN (SELECT RE0.RE0_NUM "
		cQuery +=							"FROM " + RetSqlName('RE0') + " RE0 "
		cQuery +=						 	"WHERE RE0.RE0_FILIAL IN ('" + cFilIn + "') "
		cQuery +=							"AND RE0.RE0_PROJUD BETWEEN '" + cProcDe + "' AND '" + cProcAte + "' "
		cQuery +=							"AND EXISTS (SELECT RD0.RD0_CODIGO "
		cQuery +=										"FROM " + RetSqlName('RD0') + " RD0 "
		cQuery +=										"WHERE RE0.RE0_RECLAM = RD0.RD0_CODIGO "
		cQuery +=										"AND RD0.RD0_CIC BETWEEN '" + cCpfDe + "' AND '" + cCpfAte + "' "
		cQuery +=										"AND RD0.D_E_L_E_T_ = ' ') "
		cQuery +=							"AND RE0.D_E_L_E_T_ = ' ') "
		cQuery += 	"AND E0E.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY RE0.RE0_PROJUD, E0E.E0E_RECLAM, E0E.E0E_COMPET "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
		While (cAliasQry)->(!EoF())
			If !(cAliasQry)->RE0_PROJUD == cOldProc
				lRet := .T.
				lRetXML := .T.
				lProcessa	:= .T.
				cOldProc	:= (cAliasQry)->RE0_PROJUD
				cIdLog		:= " - " + STR0042 + cOldProc //" - Processo: ###"

				cStatus := TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp, , , 5 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO já que padrão da rotina manda indice 2
				cProJud := AllTrim((cAliasQry)->RE0_PROJUD) 

				If cStatus == '4'
					cRecib := fRecExTrib(cFilEnv, cOldProc, cPerAp)
					aErros := {}

					BEGIN Transaction

						InExc3500(@cXml,'S-2501',cRecib, cProJud, ,Substr(cPerAp,1,4)+ "-"+Substr(cPerAp,5,2))
						GrvTxtArq(alltrim(cXml), "S3500", cProJud )

						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3500",,,,,,"GPE")
					End Transaction	
					If Len( aErros ) > 0
						cMsgErro := ''
						FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
						FormText(@cMsgErro)
						aErros[1] := cMsgErro
						aAdd(aLogsErr, cEvtLog + cProJud + " - "+ OemToAnsi(STR0051) ) //##"Registro S-3500 "##" não foi integrado devido ao(s) erro(s) abaixo: "
						aAdd(aLogsErr, "" )
						aAdd(aLogsErr, aErros[1] )
					Endif
					lRetXML := IIF(Len(aErros) > 0,.F.,.T.)
				ElseIf cStatus == "2"
					cMsgErr	:= OemToAnsi(STR0058) //"Registro de exclusao S-3500 desprezado pois está aguardando retorno do governo "
					aAdd(aLogsErr, cIdLog + " - " + cMsgErr)
					lRetXML := .F.
				ElseIf cStatus == "3"
					cMsgErr	:= OemToAnsi(STR0059 ) //"Registro de exclusao S-3500 desprezado pois o evento S-2501 foi transmitido com inconsistencias."
					aAdd(aLogsErr, cIdLog + " - " + cMsgErr)
					lRetXML := .F.
				ElseIf cStatus <> "-1"
					cMsgErr	:= OemToAnsi(STR0060 ) //"Registro de exclusao S-3500 desprezado pois o evento S-2501 não transmitido"
					aAdd(aLogsErr, cIdLog + " - " + cMsgErr)
					lRetXML := .F.
				Endif
				If (cStatus == '4' .Or. cStatus = '-1') .And. lRetXML

					cChaveE0F := xFilial("E0E",cFilEnv) + (cAliasQry)->E0E_PRONUM + (cAliasQry)->E0E_RECLAM + cPerAp 
					cChaveObs := xFilial("E0E",cFilEnv) + (cAliasQry)->E0E_PRONUM + "OBSERV" + cPerAp 
					DbSelectArea("E0E")
					E0E->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM 

					If E0E->( dbSeek(cChaveE0F)) //E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_IDTRIB
						While E0E->( E0E_FILIAL + E0E_PRONUM + E0E_RECLAM + E0E_PERAP ) == cChaveE0F .Or.;
							  E0E->( E0E_FILIAL + E0E_PRONUM + E0E_RECLAM + E0E_PERAP ) == cChaveObs 
							RecLock("E0E",.F.)
								E0E->(dbDelete())
								E0E->(MsUnlock())
								E0E->(dbSkip())
						End
					EndIf

					DbSelectArea("E0F")
					E0F->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM 
					If E0F->( dbSeek(cChaveE0F)) //E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_IDTRIB
						While E0F->( E0F_FILIAL + E0F_PRONUM + E0F_RECLAM + E0F_PERAP ) == cChaveE0F .Or.;
							  E0F->( E0F_FILIAL + E0F_PRONUM + E0F_RECLAM + E0F_PERAP ) == cChaveObs 
							RecLock("E0F",.F.)
								E0F->(dbDelete())
								E0F->(MsUnlock())
								E0F->(dbSkip())
						End
					EndIf
					aAdd( aLogsOk, cIdLog )
				Endif
			EndIf
			(cAliasQry)->(DbSkip())
		Enddo

		(cAliasQry)->(dbCloseArea())
	Next nFil	
	If !lRet
		aAdd( aLogsErr, OemToAnsi(STR0041) ) //"Nenhum registro foi localizado, verifique os parametros selecionados"
	Endif

Return lRet


Static Function fRecExTrib(cFilEx, cProcRecb, cPerAp)

Local aArea			:= GetArea()
Local cRecib		:= ""
Default cFilEx 	:= ""
Default cProcRecb 	:= ""
Default cPerAp		:= ""	

DbSelectArea("V7C")
V7C->( dbSetOrder(5) )

If V7C->( dbSeek( xFilial("V7C",cFilEx) + PADR(cProcRecb,20) + cPerAp + "1" ) )
	cRecib := Alltrim(V7C->V7C_PROTUL)
EndIf 

RestArea(aArea)

Return cRecib





