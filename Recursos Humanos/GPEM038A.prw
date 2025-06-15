#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM038.CH"

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM038A
@Author   Silvia Taguti
@Since    04/11/2022
@Version  1.0
/*/
Function GPEM038A()
Return()

/*/{Protheus.doc} fNew2500
Função responsável por gerar o evento S-2500 - Processos Trabalhistas
@Author.....: Silvia Taguti
@Since......: 04/11/2022
@Version....: 1.0
/*/
Function fNew2500(dDataIni, dDataFim, aArrayFil, lRetific, aLogsOk, aCheck, aLogsErr,cVersEnvio,cCPFDe,cCPFAte,cProcDe,cProcAte)

	Local aArea			:= GetArea()
	Local nI            := 0
	Local cDtIni		:= ""
	Local cDtFim		:= ""
	Local cAliasRE0		:= "RE0"
	Local cQuery 		:= ""
	Local nx            := 0
	Local lRetXml		:= .F.
	Local lRet          := .F.
	Local aErros		:= {}
	Local cEvtLog		:= OemToAnsi(STR0050) //"Registro S-2500 do Processo:"
	Local lRetRE0		:= .F.
	Local cStatus 		:= "-1"
	Local cMsgErro      := " "
	Local cTafKey		:= ""
	Local cPerPred		:= ""
	Local cStatPred		:= "-1"
	Local aInfoC		:= {}
	Local aDadosRJE		:= {}
	Local cChaveMid		:= ""
	Local cRjeKey		:= ""
	Local lNovoRJE		:= .T.
	Local cOperEvt		:= ""
	Local cOperNew		:= "I"
	Local cRetfEvt		:= ""
	Local cRecibEvt		:= ""
	Local cRecibAnt		:= ""
	Local nRecEvt		:= 0
	Local lRetif		:= .F.

	Private cCompIn		:= ""
	Private cComFim		:= ""
	Private cRepPro		:= ""
	Private nVRemun		:= 0
	Private nVrApi 		:= 0
	Private nV13Api		:= 0
	Private nVInden		:= 0
	Private nBcfgts		:= 0
	Private cPgResc		:= ""
	Private cTpInPr 	:= ""
	Private cnInscPr	:= ""
	Private	cProJud 	:= ""
	Private	cObsProc	:= ""
	Private	cOrigem 	:= ""
	Private cNumProces	:= ""
	Private cReclam		:= ""
	Private aInfoE0A	:= {}
	Private aInfoE0B	:= {}
	Private aInfoE0D	:= {}
	Private aInfoE0G	:= {}
	Private aInfoRE1    := {}
	Private aInfoDep    := {}
	Private aInfoE0GDep	:= {}
	Private	cMatUnicid 	:= ""
	Private	cCategUnic 	:= ""
	Private	cdtIniUnic 	:= ""
	Private	cdtSent		:= ""
	Private	cdtCCP		:= ""
	Private	tpCCP		:= ""
	Private cnpjCCP		:= ""
	Private cCodUnic	:= ""
	Private cCPFTRAB	:= ""
	Private cNomeTrab	:= ""
	Private dDtNasc		:= ""
	Private cXml		:= ""
	Private	cTpResp 	:= ""
	Private cNInscResp	:= ""
	Private aUnicid		:= {}
	Private cFilIn 		:= ""
	Private cFilEnv     := ""
	Private cTpInsc		:= ""
	Private lAdmPubl	:= .F.
	Private cNrInsc		:= "0"
	Private cRetfNew	:= "1"
	Private cRecibXML	:= ""
	Private cIdXML		:= ""

	Default cCPFDe		:= ""
	Default cCPFAte 	:= "99999999999"
	Default cProcDe 	:= ""
	Default cProcAte	:= "ZZZZZZZZZZZZ"
	Default dDataIni	:= ctod("")
	Default dDataFim	:= CTOD("")
	Default aArrayFil	:= ""
	Default lRetific	:= .F.
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}
	Default cVersEnvio	:= "9.1.00"

	cDtIni := DtoS(dDataIni)
	cDtFim := DtoS(dDataFim)
	cPerPred := AnoMes(dDataIni)

	IIf(Select(cAliasRE0) > 0,(cAliasRE0)->(DbCloseArea()), .T.)

	For nI := 1 To Len(aArrayFil)
		cFilIn := Alltrim(xFilial("RE0", aArrayFil[nI][1]))
		cFilEnv := aArrayFil[nI][1]

		If lMiddleware
			fPosFil( cEmpAnt, cFilEnv )
			cStatPred := "-1"
			If fVld1000( cPerPred, @cStatPred, cFilEnv )
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
				aInfoC   := fXMLInfos(cPerPred)
				If Len(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				EndIf
			Else
				cMsgErro := cFilEnv + " - " + OemToAnsi(STR0045)//"### - Registro do evento S-1000"
				cMsgErro += If(cStatPred == "-1", OemToAnsi(STR0046), "")	// não localizado na base de dados"
				cMsgErro += If( cStatPred == "1", OemToAnsi(STR0047), "")	//" não transmitido para o governo"
				cMsgErro += If( cStatPred == "2", OemToAnsi(STR0048), "")	//" aguardando retorno do governo"
				cMsgErro += If( cStatPred == "3", OemToAnsi(STR0049), "")	//" retornado com erro do governo"
				aAdd( aLogsErr, cMsgErro)
				Loop
			EndIf
		EndIf

		cQuery := "SELECT RE0.RE0_FILIAL, RE0.RE0_NUM, RE0.RE0_RECLAM, RE0.RE0_TPPROC, RE0.RE0_PROJUD,RE0.RE0_COBS, RE0.RE0_DTDECI, RE0.RE0_DTCCP, RE0.RE0_ORIGEM, "
		cQuery += "RE0.RE0_TPCCP,RE0.RE0_COMAR,RE0.RE0_VARA, RE0.RE0_CNPJCC,RE0.RE0_TPINSC, RE0.RE0_NINSC, RD0.RD0_CIC, RD0.RD0_NOME, RD0.RD0_DTNASC "
		cQuery += "FROM " + RetSqlName('RE0') + " RE0 "
		cQuery += "INNER JOIN " + RetSqlName('RD0') + " RD0 "
		cQuery += "ON RE0.RE0_RECLAM = RD0.RD0_CODIGO "
		cQuery += "WHERE RE0.RE0_FILIAL IN ('" + cFilIn + "') "
		cQuery += " AND RE0.RE0_DTDECI BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "
		cQuery += " AND RE0.RE0_PROJUD  <> ' ' "
		cQuery += " AND RE0.RE0_PROJUD BETWEEN '" + cProcDe + "' AND '" + cProcAte + "' AND "
		cQuery += " RD0.RD0_CIC BETWEEN '" + cCPFDe + "' AND '" + cCPFAte + "' AND"
		cQuery += " RE0.D_E_L_E_T_ = ' ' AND "
		cQuery += " RD0.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY RE0.RE0_FILIAL, RE0.RE0_NUM, RE0.RE0_RECLAM "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),	cAliasRE0,.T.,.T.)

		While (cAliasRE0)->(!EOF())
			//ideResp
			cTpResp 	:= (cAliasRE0)->RE0_TPINSC
			cNInscResp	:= (cAliasRE0)->RE0_NINSC
			//InfoProcesso
			cProJud := (cAliasRE0)->RE0_PROJUD
			cObsProc := AllTrim(MSMM((cAliasRE0)->RE0_COBS,,,,3,,,"RE6",,"RDY"))
			cOrigem := (cAliasRE0)->RE0_ORIGEM

			cdtSent := (cAliasRE0)->RE0_DTDECI
			cdtCCP  := (cAliasRE0)->RE0_DTCCP
			tpCCP  	:= (cAliasRE0)->RE0_TPCCP
			cnpjCCP	:= (cAliasRE0)->RE0_CNPJCC
			lRetRE0	:= .T.

			If !Empty((cAliasRE0)->RE0_COMAR ) .And. !Empty((cAliasRE0)->RE0_VARA )
				lRet := fGetRE1(@aInfoRE1, (cAliasRE0)->RE0_COMAR,(cAliasRE0)->RE0_VARA ) // >> Busca Informarações da Vara
				If !lRet
					aAdd(aLogsErr,OemToAnsi(STR0037) ) //"Comarca/Vara não cadastrada "
					(cAliasRE0)->(DBSkip())
					Loop
				Endif
			else
				lRet := .F.
				aAdd(aLogsErr,OemToAnsi(STR0037) ) //"Comarca/Vara não cadastrada "
				(cAliasRE0)->(DBSkip())
				Loop
			Endif

			If lRet
				//<ideTrab>
				ccpfTrab  := (cAliasRE0)->RD0_CIC
				cNomeTrab := (cAliasRE0)->RD0_NOME
				dDtNasc   := (cAliasRE0)->RD0_DTNASC

				If !lMiddleware
					cStatus := TAFGetStat( "S-2500", cProJud,cEmpAnt,cFilEnv, 7)
				Else
					aDadosRJE	:= {}
					lNovoRJE	:= .T.
					cStatus		:= "-1"
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					nRecEvt		:= 0
					cRecibEvt	:= ""
					cRecibAnt	:= ""

					cRjeKey		:= Padr( cFilEnv + cProJud + ccpfTrab, fTamRJEKey(), " ")
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2500" + cRjeKey
					GetInfRJE( 2, cChaveMid, @cStatus, @cOperEvt, @cRetfEvt, @nRecEvt, @cRecibEvt, @cRecibAnt )

					If cStatus == "2"
						aAdd(aLogsErr, cEvtLog + cProJud + "-" + OemToAnsi(STR0056)) //"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
						(cAliasRE0)->(DBSkip())
						Loop
					ElseIf cStatus $ "1/3"
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
					cIdXml := If( Empty(cIdXml), aInfoC[3], fXMLInfos(cPerPred)[3] ) //gerar id por evento, demais infos são por filial
					aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2500", cPerPred, cRjeKey, cIdXml, cRetfNew, "12", "1", Date(), Time(), cOperNew, cRecibEvt, cRecibAnt } )
				EndIf

				If (cStatus == "4" .Or. cRetfNew == "2") .And. !lRetific
					aAdd(aLogsErr,cEvtLog+ cProJud+ "-" + OemToAnsi(STR0044) ) //"Registro S-2500 do Processo:"##"Ja foi integrado anteriormente, selecione a opção de retificação "
					(cAliasRE0)->(DBSkip())
					Loop
				Endif
				lRetif := If(cStatus == "4", lRetific, .F.)

				////E0B - Processo por Vinculo inFoContr
				If !Empty((cAliasRE0)->RE0_NUM ) .And. !Empty((cAliasRE0)->RE0_RECLAM ) .And. !Empty((cAliasRE0)->RE0_PROJUD)
					cNumProces := (cAliasRE0)->RE0_NUM
					cReclam	:= (cAliasRE0)->RE0_RECLAM
					lRet := fGetE0B(@aInfoE0B, cNumProces,cReclam )

					If !lRet .And. Len(aInfoE0B) == 0
						aAdd(aLogsErr, OemToAnsi(STR0036) + "-" + (cAliasRE0)->RE0_PROJUD)
						(cAliasRE0)->(DBSkip())
						Loop
					Endif

					If lRet .And. Len(aInfoE0B) > 0
						For nx:= 1 to Len(aInfoE0B)
							cIdVinculo := aInfoE0B[nx,3]
							cCodUnic   :=  aInfoE0B[nx,13]
							//dependentes
							If aInfoE0B[nx,4] <> "1"
								aInfoDep := fGetDep(cCodUnic)
							Endif
							//Informações Reclamante Externo <infoCompl>
							If aInfoE0B[nx,4] == "1"
								aInfoE0G := fGetE0G(cNumProces,cReclam, cIdVinculo )
								If Len(aInfoE0G) == 0
									aAdd(aLogsErr, OemToAnsi(STR0038) ) //"Informações do participante externo não encontrada"
									(cAliasRE0)->(DBSkip())
									Loop
								Endif
								aInfoE0GDep := fGetE0GDep(cNumProces,cReclam, cIdVinculo )
							Endif
							//<mudCategAtiv>
							aInfoE0A := fGetE0A( cNumProces, cReclam, cIdVinculo ) //	Filial, Processo, Reclamante, Id Vinculo

							//<unicContr>
							If aInfoE0B[nx,12] == "S"
								aUnicid :=	fGetUnic(cNumProces, cReclam, cIdVinculo)
							Endif

							//<ideEstab> <infoVlr>
							DbSelectArea("E0C")
							E0C->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM + E0B_RECLAM + E0B_VINC
							If E0C->( DbSeek(xFilial("E0C",cFilEnv) + cNumProces + cReclam + cIdVinculo) )
								cTpInPr := E0C_TPINSC
								cnInscPr:= E0C_NINSC
								cCompIn	:= E0C_COMPIN
								cComFim	:= E0C_COMFIM
								cRepPro := E0C_REPPRO
								nVRemun	:= E0C_VREMUN
								nVrApi 	:= E0C_VRAPI
								nV13Api	:= E0C_V13API
								nVInden	:= E0C_VINDEN
								nBcfgts	:= E0C_BCFGTS
								cPgResc	:= E0C_PGRESC
							else
								aAdd(aLogsErr, OemToAnsi(STR0039) ) //"Informações dos períodos e valores decorrentes de processo trabalhista não cadastradas"
								(cAliasRE0)->(DBSkip())
								Loop
							Endif
							//<idePeriodo>
							If !Empty(cTpInPr) .And. !Empty(cnInscPr)
								//E0D Valores Processo por Período
								aInfoE0D := fGetE0D(cNumProces, cReclam, cIdVinculo , cTpInPr, cnInscPr, cCompIn, cComFim )
								If Len(aInfoE0D) == 0
									aAdd(aLogsErr, OemToAnsi(STR0040) ) //Identificação do período ao qual se referem as bases de cálculo
									(cAliasRE0)->(DBSkip())
									Loop
								Endif
							Endif
						Next nx
					Endif
				Endif
			Endif
			If lRet
				////Realiza a integração
				Begin Transaction
					lRetXml := fXml2500( @cXml,cVersEnvio, lRetif )

					If !lMiddleware
						cTafKey := "S2500" + cdtSent + cProJud
						 //Integração TAF
						 aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml,cTafKey, "3", "S2500", , , , , , "GPE", ,  )
					ElseIf lRetXml //Integração MID
						If fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
							aAdd(aLogsOk, cEvtLog + cProJud + OemToAnsi(STR0043) + ccpfTrab + OemToAnsi(STR0055) ) //##"Registro S-2500 do Processo"## integrado com Mid
						EndIf
					EndIf
				End Transaction
				If Len( aErros ) > 0
					cMsgErro := ''
					FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
					FormText(@cMsgErro)
					aErros[1] := cMsgErro
					aAdd(aLogsErr, cEvtLog + cProJud + " - "+ OemToAnsi(STR0051) ) //##"Registro S-2500 "##" não foi integrado devido ao(s) erro(s) abaixo: "
					aAdd(aLogsErr, "" )
					aAdd(aLogsErr, aErros[1] )
				Endif

				If !lMiddleware .And. lRetXml .And. Len( aErros ) == 0
					aAdd(aLogsOk, cEvtLog + cProJud + OemToAnsi(STR0043) + ccpfTrab + OemToAnsi(STR0052)  ) //##"Registro S-2500 do Processo"## integrado com TAF
				Endif
			Endif
			aInfoE0A	:= {}
			aInfoE0B	:= {}
			aInfoRE1    := {}
			aInfoE0G	:= {}
			aInfoE0D	:= {}
			aInfoDep	:= {}
			cMatUnicid 	:= ""
			cCategUnic 	:= ""
			dtIniUnic  	:= ""
			cdtSent 	:= ""
			cdtCCP  	:= ""
			tpCCP  		:= ""
			cnpjCCP		:= ""
			cProJud 	:= ""
			cObsProc	:= ""
			cOrigem 	:= ""
			cNumProces	:= ""
			cReclam		:= ""
			cCodUnic	:= ""
			cNomeTrab 	:= ""
			dDtNasc	  	:= ""
			cTpResp 	:= ""
			cNInscResp	:= ""
			cCompIn 	:= ""
			cComFim 	:= ""
			cRepPro 	:= ""
			nVRemun 	:= 0
			nVrApi  	:= 0
			nV13Api 	:= 0
			nVInden 	:= 0
			nBcfgts 	:= 0
			cPgResc 	:= ""
			cTpInPr 	:= ""
			cnInscPr	:= ""
			aUnicid		:= {}

			(cAliasRE0)->(dbSkip() )
		ENDDO
		(cAliasRE0)->( dbCloseArea() )
	Next nI

	If !lRetRE0
		aAdd(aLogsErr,OemToAnsi(STR0041) ) //"Nenhum registro foi localizado, verifique os parametros selecionados"
	Endif

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetRE1
Busca  dados na tabela RE1
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetRE1(aInfoRE1, cComarca, cVara)
	Local lRet	:= .F.

	DEFAULT aInfoRE1	:= {}
	Default cComarca 	:= ""
	Default cVara       := ""

	DbSelectArea("RE1")
	RE1->(DbSetOrder(1)) //RE1_FILIAL+RE1_COMAR+RE1_VARA
	If RE1->( DbSeek(xFilial("RE1",cFilEnv) + cComarca + cVara) )
		AADD(aInfoRE1, {RE1->RE1_UF, RE1->RE1_CODMUN, RE1->RE1_IDVARA })
		lRet := .T.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0B
Busca  dados na tabela E0B
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetE0B(aInfoE0B, cPronum, cReclam)

Local lRet      := .F.
Default cPronum := ""
Default cReclam := ""
Default aInfoE0B := {}

	DbSelectArea("E0B")
	E0B->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM + E0B_RECLAM
	If E0B->( DbSeek(xFilial("E0B",cFilEnv) + cPronum + cReclam) )
		While E0B->( !Eof() .And. E0B->E0B_PRONUM == cPronum .And. E0B->E0B_RECLAM==cReclam )
			AADD(aInfoE0B, {E0B->E0B_PRONUM,;		//1Numero Processo
							E0B->E0B_RECLAM,;       //2Reclamante
							E0B->E0B_IDVINC,;		//3Id. Vinculo
							E0B->E0B_EXT,;			//4Externo
							E0B->E0B_TPCONT,;		//5Tp. Contrato
							E0B->E0B_INDCON,;		//6Ind. Contrat
							E0B->E0B_DTADMO,;		//7Dt. Adm. Ori
							E0B->E0B_INDREI,;		//8Ind. Reinteg
							E0B->E0B_INDCAT,;		//9Recon Categ
							E0B->E0B_INDNAT,;		//10Reconhecimento Atividade
							E0B->E0B_INDMDE,;		//11Reconhecimento Desligamen
							E0B->E0B_INDUNI,;		//12Reconhecimento Contrato
							E0B->E0B_CODUNI,;		//13Matrícula eSocial
							E0B->E0B_CATEFD,;		//14Categoria eSocial
							E0B->E0B_DTITSV,; 		//15Dt. Inicio TSV
							E0B->E0B_VININC	} )     //16Preenchido quando possui unicidade, vinculo superior
				lRet := .T.
			E0B->(DBSkip())
		EndDo
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0A
Busca  dados na tabela E0A
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0A(cPronum, cReclam, cIdVinculo )


Default aInfoE0A 	:= {}
Default cPronum 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""

	DbSelectArea("E0A")
	E0A->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM + E0B_RECLAM
	If E0A->( DbSeek(xFilial("E0A",cFilEnv) + cNumProces + cReclam + cIdVinculo) )

		AADD(aInfoE0A, {E0A->E0A_PRONUM,;		//1Numero Processo
						E0A->E0A_RECLAM,;       //2Reclamante
						E0A->E0A_IDVINC,;		//3Id. Vinculo
						E0A->E0A_IDMUD,;		//4
						E0A->E0A_CODUNI	,;		//5
						E0A->E0A_CATEFD,;		//6
						E0A->E0A_DTTSVE,;		//7
						E0A->E0A_DTALT,;		//8
						E0A->E0A_NCAT,;		    //9
						E0A->E0A_NATUR } )		//10
	Endif

Return aInfoE0A

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0D
Busca  dados na tabela E0D
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0D(cNumProces, cReclam, cIdVinculo , cTpInPr, cnInscPr, cCompIn, cComFim )

Default aInfoE0D 	:= {}
Default cNumProces 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""
Default cTpInPr		:= ""
Default cnInscPr    := ""
Default cCompIn		:= ""
Default cComFim		:= ""

	DbSelectArea("E0D")
	E0D->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM + E0B_RECLAM
	E0D->( DbSeek(xFilial("E0D",cFilEnv) + cNumProces + cReclam + cIdVinculo +cTpInPr+cnInscPr+cCompIn ) )
	While E0D->( !EoF() ) .And. E0D->E0D_FILIAL == xFilial("E0D",cFilEnv) .And. E0D->E0D_PRONUM == cNumProces .And. E0D->E0D_RECLAM == cReclam .And. E0D->E0D_IDVINC == cIdVinculo;
		.And. E0D->E0D_TPINSC == cTpInPr .And. E0D->E0D_NINSC == cnInscPr .And. E0D->E0D_COMPET >= cCompIn .And. E0D->E0D_COMPET <= cComFim
				Aadd(aInfoE0D,{;
					E0D->E0D_TPINSC,; 		//1
					E0D->E0D_NINSC,;   		//2
					E0D->E0D_COMPET,;  		//3
					E0D->E0D_GRAUEX,;  		//4
					E0D->E0D_BCINSS,;  		//5
					E0D->E0D_BCCP13,;  		//6
					E0D->E0D_BCFGTS,;  		//7
					E0D->E0D_FGTS13,;  		//8
					E0D->E0D_FGTSDE,;  		//9
					E0D->E0D_FG13AN,;  		//10
					E0D->E0D_FGTSPG,;  		//11
					E0D->E0D_CODCAT,;  		//12
					E0D->E0D_BCCPRE}) 		//13

		E0D->( dbSkip() )
	EndDo


Return aInfoE0D

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0G
Busca  dados na tabela E0G
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0G(cNumProces, cReclam, cIdVinculo)

Local oInfoCompl As OBJECT
Local cJMemoE0G  	:= ""
Local cCodCBO 		:= ""
Local nnatAtiv		:= 0
Local dtRemun		:= ""
Local vrSalFx		:= ""
Local undSalFixo	:= ""
Local dscSalVar		:= ""
Local tpRegTrab 	:= 0
Local tpRegPrev 	:= 0
Local dtAdm 		:= ""
Local tmpParc 		:= 0
Local tpContr 		:= 0
Local dtTermDur		:= ""
Local clauAssec 	:= ""
Local objDet 		:= ""
Local observacao 	:= ""
Local tpInsc 		:= 0
Local nrInsc 		:= ""
Local matricAnt 	:= ""
Local dtTransf 		:= ""
Local dtDeslig 		:= ""
Local mtvDeslig 	:= ""
Local dtProjFimAPI	:= ""
Local dtTerm 		:= ""
Local mtvDesligTSV	:= ""

Default cPronum 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""
Default aInfoE0G    := {}

	DbSelectArea("E0G")
	E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC
	If E0G->( DbSeek(xFilial("E0G",cFilEnv) + cNumProces + cReclam + cIdVinculo) )
		While !E0G->(Eof()) .And. (xFilial("E0G",cFilEnv) == E0G->E0G_FILIAL .And. cNumProces == E0G->E0G_PRONUM .And. cIdVinculo == E0G->E0G_IDVINC )
			If E0G->E0G_TPINF == "2"      //infoCompl
					oInfoCompl := JsonObject():new()
					cJMemoE0G := MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY")
					oInfoCompl:FromJSON(cJMemoE0G)
				
					cCodCBO 	:= If (Valtype(oInfoCompl['codCBO']) == "U",cCodCBO,oInfoCompl['codCBO'])
					nnatAtiv	:= If (Valtype(oInfoCompl['natAtividade']) == "U",nnatAtiv,oInfoCompl['natAtividade'])
					
					//infoTerm					
					If oInfoCompl['infoTerm']:hasProperty("dtTerm")
						dtTerm		:= If (Valtype(oInfoCompl['infoTerm']['dtTerm']) == "U",dtTerm,oInfoCompl['infoTerm']['dtTerm'])
						dtTerm		:= If(lMiddleware, dtTerm, Dtos(fJToD(dtTerm)) )						
						mtvDesligTSV:= If (Valtype(oInfoCompl['infoTerm']['mtvDesligTSV']) == "U",mtvDesligTSV,oInfoCompl['infoTerm']['mtvDesligTSV'])
					EndIf

					//Remuneracao
					If Len(oInfoCompl['remuneracao']) > 0
						dtRemun		:= If (Valtype(oInfoCompl['remuneracao'][1]['dtRemun']) == "U",dtRemun,oInfoCompl['remuneracao'][1]['dtRemun'])
						dtRemun		:= If(lMiddleware, dtRemun, Dtos(fJToD(dtRemun)) )
						vrSalFx		:= If (Valtype(oInfoCompl['remuneracao'][1]['vrSalFx']) == "U",vrSalFx,oInfoCompl['remuneracao'][1]['vrSalFx'])
						undSalFixo	:= If (Valtype(oInfoCompl['remuneracao'][1]['undSalFixo']) == "U",undSalFixo,oInfoCompl['remuneracao'][1]['undSalFixo'])
						dscSalVar	:= If (Valtype(oInfoCompl['remuneracao'][1]['dscSalVar']) == "U",dscSalVar,oInfoCompl['remuneracao'][1]['dscSalVar'])
					EndIf				

					//InfoVinc
					If oInfoCompl['infoVinc']:hasProperty("tpRegTrab")
						tpRegTrab 	:= If (Valtype(oInfoCompl['infoVinc']['tpRegTrab']) == "U",tpRegTrab,oInfoCompl['infoVinc']['tpRegTrab'])
						tpRegPrev 	:= If (Valtype(oInfoCompl['infoVinc']['tpRegPrev']) == "U",tpRegPrev,oInfoCompl['infoVinc']['tpRegPrev'])
						dtAdm		:= If (Valtype(oInfoCompl['infoVinc']['dtAdm']) == "U",dtAdm,oInfoCompl['infoVinc']['dtAdm'])
						dtAdm		:= If(lMiddleware, dtAdm, Dtos(fJToD(dtAdm)) )						
						tmpParc 	:= If (Valtype(oInfoCompl['infoVinc']['tmpParc']) == "U",tmpParc,oInfoCompl['infoVinc']['tmpParc'])

						//duracao
						If oInfoCompl['infoVinc']['duracao']:hasProperty("tpContr")
							tpContr 	:= If (Valtype(oInfoCompl['infoVinc']['duracao']['tpContr']) == "U",tpContr,oInfoCompl['infoVinc']['duracao']['tpContr'])
							dtTermdur	:= If (Valtype(oInfoCompl['infoVinc']['duracao']['dtTerm']) == "U",dtTermdur,oInfoCompl['infoVinc']['duracao']['dtTerm'])
							dtTermdur	:= If(lMiddleware, dtTermdur, Dtos(fJToD(dtTermdur)) )							
							clauAssec 	:= If (Valtype(oInfoCompl['infoVinc']['duracao']['clauAssec']) == "U",clauAssec,oInfoCompl['infoVinc']['duracao']['clauAssec'])
							objDet		:= If (Valtype(oInfoCompl['infoVinc']['duracao']['objDet']) == "U",objDet,oInfoCompl['infoVinc']['duracao']['objDet'])					
						EndIf

						//observação
						If Len(oInfoCompl['infoVinc']['observacoes']) > 0
							observacao 	:= oInfoCompl['infoVinc']['observacoes'][1]['observacao']
						EndIf

						//sucessaoVinc
						If oInfoCompl['infoVinc']['sucessaoVinc']:hasProperty("tpInsc")
							tpInsc 		:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['tpInsc']) == "U",tpInsc,oInfoCompl['infoVinc']['sucessaoVinc']['tpInsc'])
							nrInsc 		:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['nrInsc']) == "U",nrInsc,oInfoCompl['infoVinc']['sucessaoVinc']['nrInsc'])
							matricAnt 	:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['matricAnt']) == "U",matricAnt,oInfoCompl['infoVinc']['sucessaoVinc']['matricAnt'])
							dtTransf	:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['dtTransf']) == "U",dtTransf,oInfoCompl['infoVinc']['sucessaoVinc']['dtTransf'])
							dtTransf	:= If(lMiddleware, dtTransf, Dtos(fJToD(dtTransf)) )				
						EndIf

						//infoDeslig
						If oInfoCompl['infoVinc']['infoDeslig']:hasProperty("dtDeslig")
							dtDeslig	:= If (Valtype(oInfoCompl['infoVinc']['infoDeslig']['dtDeslig']) == "U",dtDeslig,oInfoCompl['infoVinc']['infoDeslig']['dtDeslig'])
							dtDeslig	:= If(lMiddleware, dtDeslig, Dtos(fJToD(dtDeslig)) )
							mtvDeslig 	:= oInfoCompl['infoVinc']['infoDeslig']['mtvDeslig']
							dtProjFimAPI	:= If (Valtype(oInfoCompl['infoVinc']['infoDeslig']['dtProjFimAPI']) == "U",dtProjFimAPI,oInfoCompl['infoVinc']['infoDeslig']['dtProjFimAPI'])
							dtProjFimAPI	:= If(lMiddleware, dtProjFimAPI, Dtos(fJToD(dtProjFimAPI)) )
						EndIf
					EndIf


				Aadd(aInfoE0G,{;
						cCodCBO,; 						//1
						nnatAtiv,;   					//2
						dtRemun,;  						//3
						vrSalFx,;  						//4
						undSalFixo,;  					//5
						dscSalVar,;  					//6
						tpRegTrab,;  					//7
						tpRegPrev,;  					//8
						dtAdm,;  						//9
						tmpParc,;  						//10
						tpContr,;  						//11
						dtTermDur,;  					//12
						clauAssec,;						//13
						objDet ,;						//14
						observacao,;					//15
						tpInsc,;						//16
						nrInsc,;						//17
						matricAnt,;						//18
						dtTransf,;						//19
						dtDeslig,;						//20
						mtvDeslig,;						//21
						dtProjFimAPI,;					//22
						dtTerm,;						//23
						mtvDesligTSV }) 				//24
				Return aInfoE0G								
			Endif
			E0G->(dbSkip())
		Enddo
	Endif

Return aInfoE0G


//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0G
Busca  dados na tabela E0G
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0GDep(cNumProces, cReclam, cIdVinculo)

Local cMemoDep  	:= ""
Local aDepMemo	:= {}
Local nI		:= 0

	If aScan(aInfoE0GDep, {|x| x[4] = cNumProces .And. x[5] = cReclam}) == 0     //Verifica se os dados do dependente externo, ja foram carregados no primeiro vinculos
		E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC
		If E0G->( DbSeek(xFilial("E0G",cFilEnv) + cNumProces + cReclam + cIdVinculo) )
			While !E0G->(Eof()) .And. (xFilial("E0G",cFilEnv) == E0G->E0G_FILIAL .And. cNumProces == E0G->E0G_PRONUM .And. cIdVinculo == E0G->E0G_IDVINC )
				If E0G->E0G_TPINF == "1"      //infoCompl
					cMemoDep := MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY")
					If !Empty(cMemoDep)
						aDepMemo := StrTokArr( cMemoDep , '###' )
						For nI := 1 to Len(aDepMemo)
							aDep	:= StrTokArr( aDepMemo[nI] , '|' )
							aAdd(aInfoE0GDep, {aDep[2], aDep[1], IIf(Len(aDep) >= 3,aDep[3],""), cNumProces, cReclam })   //tpDep,cpfDep,descDep,cNumProces,cReclam
						Next nI
					EndIf
					Return aInfoE0GDep
				Endif
				E0G->(dbSkip())
			Enddo
		Endif
	Endif

Return aInfoE0GDep

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   25/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet := sToD("")
	DEFAULT cDateJson := ""
	DEFAULT cDtType	  := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetDep
Busca  dados na tabela E0D
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetDep(cCodUnic)

Local aArea			:= GetArea()
Local aDep			:= {}
Local cFilTrab		:= ""
Local cMatTrab      := ""

Default cCodUnic		:= ""

	If !Empty(cCodUnic)
		dbSelectArea("SRA")
		SRA->(DbSetOrder(24))
		If SRA->(MsSeek(cCodUnic))
			If (SRA->RA_CODUNIC == cCodUnic)
				cFilTrab := SRA->RA_FILIAL
				cMatTrab := SRA->RA_MAT
				If !Empty(cFilTrab) .And. !Empty(cMatTrab)
					aDep := fGM23Dep(cFilTrab, cMatTrab)
				Endif
			ENDIF
		Endif
	Endif

RestArea(aArea)

Return aDep


//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetUnic
Busca  dados na tabela E0D
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetUnic(cNProc, cRecl, cIdVinPrinc)

Local aAreaE0B		:= E0B->(GetArea())

Default cNProc		:= ""
Default cRecl		:= ""
Default cIdVinPrinc	:= ""

	E0B->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC
	If E0B->( DbSeek(xFilial("E0B",cFilEnv) + cNProc + cRecl ) )
		While !E0B->(Eof()) .And. E0B->E0B_FILIAL == xFilial("E0B",cFilEnv) .And. E0B->E0B_PRONUM == cNProc
			If E0B->E0B_FILIAL == xFilial("E0B",cFilEnv) .And. E0B->E0B_PRONUM == cNProc .And. E0B->E0B_VININC == cIdVinPrinc
				AADD(aUnicid, { AllTrim(E0B->E0B_CODUNI), E0B->E0B_CATEFD, E0B->E0B_DTITSV })
			ENDIF
			E0B->(dbSkip())
		Enddo
	Endif

RestArea(aAreaE0B)

Return aUnicid

//-------------------------------------------------------------------
/*/{Protheus.doc} function fXml2500
Geração XML s2500
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fXml2500(cXml, cVersEnvio,lRetific)

Local nI		:= 0
Local nB		:= 0
Local nD		:= 0
Local nU		:= 0
Local lRet		:= .F.
Local cVersMw	:= ""
Local cTpAmb
Local nTpRegTrab := 0

Default lRetific := .F.

	//-------------------
	//| Inicio do XML
	//-------------------
	If lMiddleware
		fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, , @cTpAmb ) //lista do gpem017, adiciona ou
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtProcTrab/v" + cVersMw + "'>"
		cXML += 	"<evtProcTrab Id='" + cIdXml + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cTpAmb, 1, "12" } )
	Else
		cXml := "<eSocial>"
		cXml += '	<evtProcTrab>'
		If lRetific
			cXml += '		<ideEvento>'
			cXml += '			<indRetif>2</indRetif>
			cXml += '		</ideEvento>'
		Endif
	EndIf

	cXml += '		<ideEmpregador>'
	If lMiddleware
		cXml += '		<tpInsc>'+ cTpInsc +'</tpInsc>'
		cXml += '		<nrInsc>'+ Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) +'</nrInsc>'
	EndIf
	If !Empty(cTpResp) .And. !Empty(cNInscResp)
		cXml += '		<ideResp>'
		cXml += '			<tpInsc>'+cTpResp+'</tpInsc>'
		cXml += '			<nrInsc>'+cNInscResp+'</nrInsc>'
		cXml += '		</ideResp>'
	Endif
	cXml += '		</ideEmpregador>'

	cXml +=	'		<infoProcesso>'
	cXml +=	'			<origem>'+cOrigem+'</origem>'
	cXml +=	'			<nrProcTrab>'+Alltrim(cProJud)+'</nrProcTrab>'
	If !lMiddleware .Or. !Empty(cObsProc)
		cXml +=	'			<obsProcTrab>'+cObsProc+'</obsProcTrab>'
	EndIf

	cXml +=	'			<dadosCompl>'
	If cOrigem == "1"
		cXml +=	'				<infoProcJud>'
		cXml +=	'					<dtSent>'+ If(!lMiddleware, cdtSent, SubStr(cDtSent,1,4)+"-"+SubStr(cDtSent,5,2)+"-"+SubStr(cDtSent,7,2)) +'</dtSent>'

		If Len(aInfoRE1) > 0
			cXml +=	'				<ufVara>'+ aInfoRE1[1,1] +'</ufVara>'
			cXml +=	'				<codMunic>' + Iif(lMiddleware, fEstIBGE(aInfoRE1[1,1]), "") + aInfoRE1[1,2] + '</codMunic>'
			cXml +=	'				<idVara>'+ aInfoRE1[1,3] +'</idVara>'
		Endif
		cXml +=	'				</infoProcJud>'
	Else
		cXml +=	'				<infoCCP>'
		cXml +=	'					<dtCCP>'+ cdtCCP+ '</dtCCP>'
		cXml +=	'					<tpCCP>'+ tpCCP+'</tpCCP>'
		cXml +=	'					<cnpjCCP>'+cnpjCCP+'</cnpjCCP>'
		cXml +=	'				</infoCCP>'
	EndIf
	cXml +=	'			</dadosCompl>'

	cXml +=	'		</infoProcesso>'
	cXml +=	'		<ideTrab>'
	cXml +=	'			<cpfTrab>' +ccpfTrab+ '</cpfTrab>'
	cXml +=	'			<nmTrab>' +cNomeTrab+ '</nmTrab>'
	cXml +=	'			<dtNascto>' + If(!lMiddleware, dDtNasc, SubStr(dDtNasc,1,4)+"-"+SubStr(dDtNasc,5,2)+"-"+SubStr(dDtNasc,7,2)) + '</dtNascto>'
	If Len(aInfoDep) > 0
		For nI:= 1 To Len(aInfoDep)
			cXml +=	'			<dependente>'
			cXml +=	'				<cpfDep>'+ aInfoDep[nI,4]	+'</cpfDep>'
			cXml +=					fTpDep(aInfoDep[nI],cVersEnvio)
			If aInfoDep[nI,1] == '13'
				cXml +=	'				<descDep>'+ aInfoDep[nI,2]+ '</descDep>'
			Endif
			cXml +=	'			</dependente>'
		Next nI
	Endif

	If Len(aInfoE0G) > 0 .And. Len(aInfoE0GDep) > 0
		For nI:= 1 To Len(aInfoE0GDep)
			cXml +=	'			<dependente>'
			cXml +=	'				<cpfDep>'+ aInfoE0GDep[nI,2]+'</cpfDep>'
			cXml +=					fTpDep(aInfoE0GDep[nI],cVersEnvio)
			If aInfoE0GDep[nI,1]=='13'
				cXml +=	'				<descDep>'+ aInfoE0GDep[nI,3]+ '</descDep>'
			Endif
			cXml +=	'			</dependente>'
		Next nI
	Endif
	If Len(aInfoE0B) > 0
		For nB:= 1 To Len(aInfoE0B)
			cXml +=	'			<infoContr>'
			cXml +=	'				<tpContr>'+ aInfoE0B[nB,5]+ '</tpContr>'
			cXml +=	'				<indContr>'+ aInfoE0B[nB,6]+ '</indContr>'
			// Preencher quando tpContr = 2/4 e  indContr = N
			If aInfoE0B[nB,5] $ "2|4" .And. aInfoE0B[nB,6] $ "N|2"
				cXml +=	'				<dtAdmOrig>'+ If(!lMiddleware, aInfoE0B[nB,7], SubStr(aInfoE0B[nB,7],1,4)+"-"+SubStr(aInfoE0B[nB,7],5,2)+"-"+SubStr(aInfoE0B[nB,7],7,2)) + '</dtAdmOrig>'
			Endif
			// Preencher quando tpContr <> 6 e  indContr = S
			If aInfoE0B[nB,5] <> "6" .And. aInfoE0B[nB,6] $ "S|1"
				cXml +=	'				<indReint>'+ aInfoE0B[nB,8]+ '</indReint>
			Endif
			cXml +=	'				<indCateg>'+ aInfoE0B[nB,9]+ '</indCateg>'
			cXml +=	'				<indNatAtiv>'+ aInfoE0B[nB,10]+ '</indNatAtiv>'
			cXml +=	'				<indMotDeslig>'+ aInfoE0B[nB,11]+ '</indMotDeslig>'
			cXml +=	'				<indUnic>'+ aInfoE0B[nB,12]+ '</indUnic>'
			cXml +=	'				<matricula>'+ AllTrim(aInfoE0B[nB,13]) + '</matricula>'
			//tpcontr = N ou matricula nao preenchida
			If aInfoE0B[nB,6] $ "N|2" .Or. Empty(aInfoE0B[nB,13])
				cXml +=	'				<codCateg>'+ aInfoE0B[nB,14]+ '</codCateg>
			Endif
			//Preencher quando tpcontr == 6 e indcontr == N
			If (aInfoE0B[nB,5] == "6" .And.  aInfoE0B[nB,6] $ "N|2") .Or. Empty(aInfoE0B[nB,13])
				cXml +=	'				<dtInicio>'+ If(!lMiddleware, Dtos(aInfoE0B[nB,15]), SubStr(Dtos(aInfoE0B[nB,15]),1,4)+"-"+SubStr(Dtos(aInfoE0B[nB,15]),5,2)+"-"+SubStr(Dtos(aInfoE0B[nB,15]),7,2)) + '</dtInicio>'
			Endif
			If Len(aInfoE0G) > 0 .And. aInfoE0B[nB,6] $ "N|2"
				cXml +=	'				<infoCompl>'
				cXml +=	'					<codCBO>' + aInfoE0G[1,1]+ '</codCBO>'
				cXml +=	'					<natAtividade>'+ cValToChar(aInfoE0G[1,2])+ '</natAtividade>'
				nTpRegTrab	:= aInfoE0G[1,7]
				If !(aInfoE0B[nB,5] <> "6" .And. nTpRegTrab == 2) //Não gerar conforme tpContr+tpRegTrab
					cXml +=	'					<remuneracao>'
					cXml +=	'						<dtRemun>' + aInfoE0G[1,3]+ '</dtRemun>
					cXml +=	'						<vrSalFx>' + cValToChar(aInfoE0G[1,4])+ '</vrSalFx>
					cXml +=	'						<undSalFixo>' + cValToChar(aInfoE0G[1,5])+ '</undSalFixo>
					cXml +=	'						<dscSalVar>' + aInfoE0G[1,6]+ '</dscSalVar>
					cXml +=	'					</remuneracao>'
				EndIf
				If aInfoE0B[nB,5] <> "6"
					cXml +=	'					<infoVinc>'
					cXml +=	'						<tpRegTrab>' + cValToChar(nTpRegTrab) + '</tpRegTrab>
					cXml +=	'						<tpRegPrev>' + cValToChar(aInfoE0G[1,8])+ '</tpRegPrev>
					cXml +=	'						<dtAdm>'+ aInfoE0G[1,9]+ '</dtAdm>
					If nTpRegTrab == 1
						If aInfoE0G[1,10] >= 0
							cXml +=	'						<tmpParc>' + cValToChar(aInfoE0G[1,10])+ '</tmpParc>
						EndIf
						cXml +=	'						<duracao>
						cXml +=	'							<tpContr>' + cValToChar(aInfoE0G[1,11])+ '</tpContr>
						If 	aInfoE0G[1,11] == 2
							cXml +=	'							<dtTerm>' + aInfoE0G[1,12]+ '</dtTerm>
						Endif
						If 	cValToChar(aInfoE0G[1,11]) $ "2|3"
							cXml +=	'							<clauAssec>' + aInfoE0G[1,13]+ '</clauAssec>
						EndIf
						If 	aInfoE0G[1,11] == 3
						cXml +=	'							<objDet>' +aInfoE0G[1,14]+ '</objDet>
						EndIf
						cXml +=	'						</duracao>
					EndIf
					If !lMiddleware .Or. !Empty(aInfoE0G[1,15])
						cXml +=	'						<observacoes>
						cXml +=	'							<observacao>'+ aInfoE0G[1,15]+ '</observacao>
						cXml +=	'						</observacoes>
					EndIf
					If !lMiddleware .Or. !Empty(aInfoE0G[1,16])
						cXml +=	'						<sucessaoVinc>'
						cXml +=	'							<tpInsc>'+ cValToChar(aInfoE0G[1,16])+ '</tpInsc>
						cXml +=	'							<nrInsc>'+ aInfoE0G[1,17]+ '</nrInsc>
						cXml +=	'							<matricAnt>'+ aInfoE0G[1,18]+ '</matricAnt>
						cXml +=	'							<dtTransf>'+ aInfoE0G[1,19]+ '</dtTransf>
						cXml +=	'						</sucessaoVinc>
					EndIf
					cXml +=	'						<infoDeslig>
					cXml +=	'							<dtDeslig>'+ aInfoE0G[1,20]+ '</dtDeslig>
					cXml +=	'							<mtvDeslig>'+ aInfoE0G[1,21]+ '</mtvDeslig>
					If !lMiddleware .Or. !Empty(aInfoE0G[1,22])
						cXml +=	'							<dtProjFimAPI>'+ aInfoE0G[1,22]+ '</dtProjFimAPI>
					EndIf
					cXml +=	'						</infoDeslig>
					cXml +=	'					</infoVinc>
				EndIf
				If aInfoE0B[nB,5] == "6" .And. !Empty(aInfoE0G[1,23])
					cXml +=	'					<infoTerm>
					cXml +=	'						<dtTerm>'+ aInfoE0G[1,23]+ '</dtTerm>
					cXml +=	'						<mtvDesligTSV>'+ aInfoE0G[1,24]+ '</mtvDesligTSV>
					cXml +=	'					</infoTerm>
				EndIf
				cXml +=	'				</infoCompl>
			Endif
			If Len(aInfoE0A) > 0 .And. (aInfoE0B[nB,9]  == 'S' .Or. aInfoE0B[nB,10] == 'S') //Reconhecimento da atividade
				cXml +=	'				<mudCategAtiv>'
				cXml +=	'					<codCateg>'+ aInfoE0A[1,9]+ '</codCateg>'
				cXml +=	'					<natAtividade>'+ aInfoE0A[1,10]+ '</natAtividade>'
				cXml +=	'					<dtMudCategAtiv>'+ If(!lMiddleware, Dtos(aInfoE0A[1,8]), SubStr(Dtos(aInfoE0A[1,8]),1,4)+"-"+SubStr(Dtos(aInfoE0A[1,8]),5,2)+"-"+SubStr(Dtos(aInfoE0A[1,8]),7,2)) + '</dtMudCategAtiv>'
				cXml +=	'				</mudCategAtiv>'
			Endif
			If aInfoE0B[nB,12] == 'S' .And. Len(aUnicid) > 0  //Unicidade de contrato
				For nU := 1 to Len(aUnicid)
					cXml +=	'				<unicContr>'
					If !lmiddleware .Or. !Empty(aUnicid[nU,1])
						cXml +=	'					<matUnic>'+aUnicid[nU,1]+'</matUnic>
					EndIf
					If Empty(aUnicid[nU,1])
						cXml +=	'						<codCateg>'+aUnicid[nU,2]+'</codCateg>'
						cXml +=	'						<dtInicio>'+ If(!lMiddleware, Dtos(aUnicid[nU,3]), SubStr(Dtos(aUnicid[nU,3]),1,4)+"-"+SubStr(Dtos(aUnicid[nU,3]),5,2)+"-"+SubStr(Dtos(aUnicid[nU,3]),7,2)) +'</dtInicio>'
					Endif
					cXml +=	'				</unicContr>'
				Next nU
			Endif
			If !Empty(cTpInPr) .And. !Empty(cnInscPr)
				cXml +=	'				<ideEstab>'
				cXml +=	'					<tpInsc>'+ cTpInPr+ '</tpInsc>'
				cXml +=	'					<nrInsc>'+cnInscPr+ '</nrInsc>'
				cXml +=	'					<infoVlr>'
				cXml +=	'							<compIni>' + If( !lMiddleware, cCompIn, SubStr(cCompIn,1,4) + "-" + SubStr(cCompIn,5,2) ) + '</compIni>'
				cXml +=	'							<compFim>' + If( !lMiddleware, cComFim, SubStr(cComFim,1,4) + "-" + SubStr(cComFim,5,2) ) + '</compFim>'
				cXml +=	'							<repercProc>'+cRepPro+'</repercProc>'
				cXml +=	'							<vrRemun>' +AllTrim( Transform(nVRemun, "@R 999999999.99") )+ '</vrRemun>'
				cXml +=	'							<vrAPI>' +AllTrim( Transform(nVrApi, "@R 999999999.99") )+ '</vrAPI>'
				cXml +=	'							<vr13API>' +AllTrim( Transform(nV13Api, "@R 999999999.99") )+ '</vr13API>'
				cXml +=	'							<vrInden>' +AllTrim( Transform(nVInden, "@R 999999999.99") )+ '</vrInden>'
				If !Empty(cPgResc)
					cXml +=	'							<vrBaseIndenFGTS>' +AllTrim( Transform(nBcfgts, "@R 999999999.99") )+ '</vrBaseIndenFGTS>
					cXml +=	'							<pagDiretoResc>' +cPgResc+'</pagDiretoResc>
				EndIf
				If Len(aInfoE0D) > 0
					For nD := 1 to Len(aInfoE0D)
						cXml +=	'							<idePeriodo>'
						cXml +=	'								<perRef>' + If( !lMiddleware, aInfoE0D[nD,3], SubStr(aInfoE0D[nD,3],1,4) + "-" + SubStr(aInfoE0D[nD,3],5,2) ) + '</perRef>'
						cXml +=	'								<baseCalculo>
						cXml +=	'									<vrBcCpMensal>'+AllTrim(Transform(aInfoE0D[nD,5], "@R 999999999.99") )+ '</vrBcCpMensal>
						cXml +=	'									<vrBcCp13>'+AllTrim(Transform(aInfoE0D[nD,6], "@R 999999999.99") )+ '</vrBcCp13>
						cXml +=	'									<vrBcFgts>'+AllTrim(Transform(aInfoE0D[nD,7], "@R 999999999.99") )+ '</vrBcFgts>
						cXml +=	'									<vrBcFgts13>'+AllTrim(Transform(aInfoE0D[nD,8], "@R 999999999.99") )+ '</vrBcFgts13>
						cXml +=	'									<infoAgNocivo>
						cXml +=	'										<grauExp>'+aInfoE0D[nD,4]+'</grauExp>
						cXml +=	'									</infoAgNocivo>
						cXml +=	'								</baseCalculo>
						cXml +=	'								<infoFGTS>
						cXml +=	'									<vrBcFgtsGuia>'+ AllTrim(Transform(aInfoE0D[nD,9], "@R 999999999.99") )+ '</vrBcFgtsGuia>
						cXml +=	'									<vrBcFgts13Guia>'+AllTrim(Transform(aInfoE0D[nD,10], "@R 999999999.99") )+'</vrBcFgts13Guia>
						cXml +=	'									<pagDireto>'+aInfoE0D[nD,11]+'</pagDireto>
						cXml +=	'								</infoFGTS>
						cXml +=	'								<baseMudCateg>
						cXml +=	'									<codCateg>'+aInfoE0D[nD,12]+'</codCateg>
						cXml +=	'									<vrBcCPrev>'+AllTrim(Transform(aInfoE0D[nD,13], "@R 999999999.99") )+'</vrBcCPrev>
						cXml +=	'								</baseMudCateg>
						cXml +=	'							</idePeriodo>
					Next nD
				Endif
				cXml +=	'					</infoVlr>
				cXml +=	'				</ideEstab>
			Endif
			cXml +=	'			</infoContr>'
		Next nB
	Endif

	cXml +=	'		</ideTrab>'
	cXml +=	'	</evtProcTrab>'
	cXml += '</eSocial>'

	//-------------------
	//| Final do XML
	//-------------------
	If !Empty(cXml)
		GrvTxtArq(alltrim(cXml), "S2500",ccpfTrab)
		lRet := .T.
	Endif
Return lRet
