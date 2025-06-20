#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201A.CH"

#DEFINE PREFATURA 1
#DEFINE FATURA    2

//TIPO EXEC = 1 (EMISS�O DE PR�)
//-------------------------------------------------------------------
/*/{Protheus.doc} JA201AEmi()
Rotina para filtrar os Time-Sheets que atendam aos par�metros na
emiss�o da pr�-fatura.

@param aParams  , Par�metros da fila de processamento
@param lAutomato, Indica se a chamada foi feita via automa��o

@return aRet    , Retorno da Emiss�o
                  aRet[1] - .T. - Executado com sucesso - .F. - Houve erro
                  aRet[2] - Mensagem de Erro


@author David G. Fernandes
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201AEmi(aParams, lAutomato, lThread)
	Local aRet         := {.T., "", 0}
	Local cQuery       := ""
	Local cQueryCont   := ""
	Local aArea        := GetArea()
	Local cQryRes      := ""
	Local cCodPre      := ""
	Local cNVVCOD      := ""
	Local cNW2COD      := ""
	Local cNT0COD      := ""
	Local cNT0CRELAT   := ""
	Local cNVECCLIEN   := ""
	Local cNVELCLIEN   := ""
	Local cNVENUMCAS   := ""
	Local cTEMTS       := ""
	Local cTEMLT       := ""
	Local cTEMDP       := ""
	Local cTEMFX       := ""
	Local cTEMFA       := ""
	Local cTEMLM       := ""
	Local nCount       := 0
	Local oParams      := Nil
	Local cEvent       := ""
	Local cXMLParam    := ""
	Local cPresFat     := ""
	Local oFilaExe     := Nil
	Local nI           := 1
	Local nRecOH1      := 0
	Local aErros       := {}
	Local lOk          := .T.
	Local cMsgErros    := ""
	Local aEmite       := {}
	Local lExit        := .F.

	Default aParams    := {}
	Default lAutomato  := .F.
	Default lThread    := .T.

	If Len(aParams) >= 2 .And. aParams[2] > 0
		cXMLParam   := aParams[1][4][2]
		cRecno      := aParams[2]

		oParams := TJPREFATPARAM():New()
		oParams:Deserializer(Decode64(cXMLParam))
		lOk    := oParams:LockContratos()[1]

		If !lOk
			aAdd(aErros, {STR0001 + " (" + AToC(oParams:aContratos, ", ") + ")", ""}) // "Algum contrato do filtro selecionado j� esta sendo emitido por outro usu�rio!"
		EndIf
	Else
		lOk := .F.
		aAdd(aErros, {"JA201AEmi: Empty Parameter", ""})
	EndIf

	If lOk
		__cUserID  := oParams:GetCodUser()
		oFilaExe   := JurFilaExe():New("JURA201", "2") // 2 = Impress�o
		cQueryCont := oParams:GetQueryPre()

		cQuery := " SELECT A.NVV_COD,"
		cQuery +=        " A.NW2_COD,"
		cQuery +=        " A.NT0_COD,"
		cQuery +=        " A.NT0_CRELAT,"
		cQuery +=        " A.NVE_CCLIEN,"
		cQuery +=        " A.NVE_LCLIEN,"
		cQuery +=        " A.NVE_NUMCAS,"
		cQuery +=        " MIN(A.TEMTS) TEMTS,"
		cQuery +=        " MIN(A.TEMLT) TEMLT,"
		cQuery +=        " MIN(A.TEMDP) TEMDP,"
		cQuery +=        " MIN(A.TEMFX) TEMFX,"
		cQuery +=        " MIN(A.TEMFA) TEMFA,"
		cQuery +=        " MIN(A.TEMLM) TEMLM,"
		cQuery +=        " A.SEPARA "
		cQuery +=  " FROM ( " + cQueryCont + " ) A"
		cQuery +=  " GROUP BY A.NVV_COD,"
		cQuery +=           " A.NW2_COD,"
		cQuery +=           " A.NT0_COD,"
		cQuery +=           " A.NT0_CRELAT,"
		cQuery +=           " A.NVE_CCLIEN,"
		cQuery +=           " A.NVE_LCLIEN,"
		cQuery +=           " A.NVE_NUMCAS,"
		cQuery +=           " A.SEPARA "
		cQuery += " ORDER BY A.NVV_COD,"
		cQuery +=           " A.NW2_COD,"
		cQuery +=           " A.NT0_COD,"
		cQuery +=           " A.SEPARA DESC,"
		cQuery +=           " A.NT0_CRELAT,"
		cQuery +=           " A.NVE_CCLIEN,"
		cQuery +=           " A.NVE_LCLIEN,"
		cQuery +=           " A.NVE_NUMCAS"

		cQuery  := ChangeQuery(cQuery, .F.)
		cQryRes := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

		oParams:EventInsert(PREFATURA, STR0011 + JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(oParams:GetCodUser()), "RD0_NOME")) // "Iniciando emiss�o de pr�fatura do uru�rio: "

	EndIf

	While !(cQryRes)->(EOF())

		While !(cQryRes)->(EOF())
			If !lExit .And. (;
							!(;
								(Empty(cNVVCOD) .And. Empty(cNW2COD) .And. ;
								(cNVVCOD == (cQryRes)->NVV_COD) .And. ;
								(cNW2COD == (cQryRes)->NW2_COD) .And. ;
								(cNT0COD == (cQryRes)->NT0_COD) .And. ;
								(cNT0CRELAT == (cQryRes)->NT0_CRELAT) .And. ;
								(cNVECCLIEN == (cQryRes)->NVE_CCLIEN) .And. ;
								(cNVELCLIEN == (cQryRes)->NVE_LCLIEN) ) ;
								.Or.;
								(Empty(cNVVCOD) .And. !Empty(cNW2COD) .And.;
								(cNW2COD == (cQryRes)->NW2_COD ) ) ;
								.Or.;
								( (cNT0COD == (cQryRes)->NT0_COD) .And. ;
								(Empty(cNVVCOD) .Or. (cNVVCOD == (cQryRes)->NVV_COD)) ) ;
							) ;
							.Or.;
							((cQryRes)->SEPARA == '1'))

				cNVVCOD     := (cQryRes)->NVV_COD
				cNW2COD     := (cQryRes)->NW2_COD
				cNT0COD     := (cQryRes)->NT0_COD
				cNT0CRELAT  := (cQryRes)->NT0_CRELAT
				cNVECCLIEN  := (cQryRes)->NVE_CCLIEN
				cNVELCLIEN  := (cQryRes)->NVE_LCLIEN
				cNVENUMCAS  := (cQryRes)->NVE_NUMCAS
				cTEMTS      := Alltrim((cQryRes)->TEMTS)
				cTEMLT      := Alltrim((cQryRes)->TEMLT)
				cTEMDP      := Alltrim((cQryRes)->TEMDP)
				cTEMFX      := Alltrim((cQryRes)->TEMFX)
				cTEMFA      := Alltrim((cQryRes)->TEMFA)
				cTEMLM      := Alltrim((cQryRes)->TEMLM)

				lExit := .T.
				Exit

			Else

				aAdd(aEmite, {(cQryRes)->NVV_COD     , (cQryRes)->NW2_COD       , (cQryRes)->NT0_COD       ,;
							(cQryRes)->NT0_CRELAT    , (cQryRes)->NVE_CCLIEN    , (cQryRes)->NVE_LCLIEN    , (cQryRes)->NVE_NUMCAS,;
							Alltrim((cQryRes)->TEMTS), Alltrim((cQryRes)->TEMLT), Alltrim((cQryRes)->TEMDP),;
							Alltrim((cQryRes)->TEMFX), Alltrim((cQryRes)->TEMFA), Alltrim((cQryRes)->TEMLM)})

				lExit := .F.
				(cQryRes)->(DbSkip())

			EndIf
		EndDo

		If !Empty(aEmite)
			nCount++
			cCodPre := JA201AProc(oParams, aEmite, nCount, @aErros, @cEvent, lAutomato)

			If !Empty(cCodPre)
				cPresFat += Iif(Empty(cPresFat), cCodPre, "," + cCodPre)
				JurConout(J201AGetInfo(cCodPre, 1))
			EndIf
		EndIf

		JurFreeArr(@aEmite)

	EndDo

	If (!Empty(cQryRes))
		(cQryRes)->(DbCloseArea())
	EndIf

	oFilaExe:SetConcl(cRecno)

	If !Empty(cPresFat)
		oFilaExe:AddParams("Lista de Pre Fatura", cPresFat)

		For nI := 1 To Len(aParams[1])
			If( aParams[1][nI][1] !=  "oParams" )
				oFilaExe:AddParams(aParams[1][nI][1],; // Nome do Campo
				                   aParams[1][nI][2],; // Valor do Campo
				                   aParams[1][nI][3])  // Visivel
			EndIf
		Next nI

		nRecOH1 := oFilaExe:Insert(lThread) //Salvar registro para imprss�o
		oParams:EventInsert(PREFATURA, cEvent + STR0007) // "Fim do processamento."
	EndIf

	If Empty(cPresFat) .And. Empty(aErros)
		// Tratamento para as situa��es onde � emitido apenas um contrato cujo limite est� excedido e o par�metro n�o permite emitir pr�
		aRet[1] := .F.
		aRet[2] := ""
		oParams:EventInsert(PREFATURA, STR0008, 2) // "N�o foram encontrados dados para emiss�o da Pr�-Fatura."

	ElseIf !Empty(aErros)
		For nI := 1 To Len(aErros)
			cMsgErros += aErros[nI][2] + CRLF
			cMsgErros += Space(20) + STR0010 + aErros[nI][1] + CRLF // "Erro: "
		Next nI

		oParams:EventInsert(PREFATURA, cMsgErros, 3)
		aRet := {.F., cMsgErros}
	EndIf

	If nRecOH1 > 0
		aRet[3] := nRecOH1
	EndIf
	MsUnlockAll()

	Iif(oParams:IsThread() .And. lAutomato, IPCGo("JTESTCASE"),) //Avisa que a emiss�o foi concluida para continuar os casos de testes.
	oParams:Destroy()

	RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201AProc()
Rotina para processar a emiss�o de uma pr�-fatura

@param oParams   , Objeto com os par�metros para emiss�o da pr�-fatura
@param aEmite    , Dados da pr�-fatura que ser� emitida
                       aEmite[nI][1]  - C�digo da Fatura Adicional
                       aEmite[nI][2]  - C�digo da Jun��o de Contratos
                       aEmite[nI][3]  - C�digo do Contrato
                       aEmite[nI][4]  - C�digo do Relat�rio
                       aEmite[nI][5]  - Cliente do Caso
                       aEmite[nI][6]  - Loja do Cliente do Caso
                       aEmite[nI][7]  - Caso
                       aEmite[nI][8]  - Indica se tem Time Sheet (1=Sim;2=N�o)
                       aEmite[nI][9]  - Indica se tem Lanc Tabelado (1=Sim;2=N�o)
                       aEmite[nI][10] - Indica se tem Despesa (1=Sim;2=N�o)
                       aEmite[nI][11] - Indica se tem Parcela Fixa (1=Sim;2=N�o)
                       aEmite[nI][12] - Indica se tem Fatura Adicional (1=Sim;2=N�o)
                       aEmite[nI][13] - Indica se tem Limite (1=Sim;2=N�o)
@param nCount    , Quantidade de pr�-faturas emitidas
@param aErros    , Armazena poss�veis erros durante a emiss�o da pr�-fatura
@param cEvent    , Indica o tipo de evento, ou seja, se � emiss�o de pr�-fatura de
                   Jun��o de Contratos, Contrato ou Fatura Adicional
@param lAutomato , Indica se a chamada foi feita via automa��o

@return cCodPre  , C�digo da Pr�-Fatura

@author Bruno Ritter / Jorge Martins
@since 22/02/2019
/*/
//-------------------------------------------------------------------
Static Function JA201AProc(oParams, aEmite, nCount, aErros, cEvent, lAutomato)
	Local lAguarda     := .T.
	Local nVezes       := 0
	Local lLimExc      := SuperGetMv( "MV_JLIMEXC", .F., "2" ) == "1" //Indica se emite pr�-fatura para Contratos com o limite geral excedido? (1-Sim; 2-N�o)
	Local aLimite      := {}
	Local cNVVCOD      := ""
	Local cNW2COD      := ""
	Local cNT0COD      := ""
	Local cNT0CRELAT   := ""
	Local cNVECCLIEN   := ""
	Local cNVELCLIEN   := ""
	Local cNVENUMCAS   := ""
	Local cTEMTS       := ""
	Local cTEMLT       := ""
	Local cTEMDP       := ""
	Local cTEMFX       := ""
	Local cTEMFA       := ""
	Local cTEMLM       := ""
	Local nI           := 0
	Local lLimContr    := .F.
	Local aLimiteCas   := {}
	Local lLimCaso     := .F.
	Local nSaldoNT0    := 0
	Local aSaldo       := {}
	Local nSaldoNVE    := 0
	Local nSaldo       := 0
	Local lTemLT       := .F.
	Local lTemFX       := .F.
	Local lTemFA       := .F.
	Local lTemDP       := .F.
	Local lTemLM       := .F.
	Local lPodeEmit    := .F.
	Local lOkEmite     := .F.
	Local lLoop        := .F.
	Local aNVV         := {}
	Local lFirstApag   := .T.
	Local cCodPre      := ""
	Local aRet         := {}
	Local nTotEmite    := Len(aEmite)
	Local lVinc        := .F.

	Default lAutomato := .F.

	BEGIN TRANSACTION
		cCodPre := JurGetNum("NX0", "NX0_COD")

		For nI := 1 To Len(aEmite)
			lLoop    := .F.
			lAguarda := .T. 

			If Len(aEmite[nI]) >= 13
				cNVVCOD     := aEmite[nI][1]
				cNW2COD     := aEmite[nI][2]
				cNT0COD     := aEmite[nI][3]
				cNT0CRELAT  := aEmite[nI][4]
				cNVECCLIEN  := aEmite[nI][5]
				cNVELCLIEN  := aEmite[nI][6]
				cNVENUMCAS  := aEmite[nI][7]
				cTEMTS      := aEmite[nI][8]
				cTEMLT      := aEmite[nI][9]
				cTEMDP      := aEmite[nI][10]
				cTEMFX      := aEmite[nI][11]
				cTEMFA      := aEmite[nI][12]
				cTEMLM      := aEmite[nI][13]

				// Bloco para impedir a emiss�o de pr�-faturas para contratos com Limite Geral excedido, conforme par�metro MV_JLIMEXC
				If !lLimExc
					aLimite   := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, {"NT0_CMOELI", "NT0_VLRLI", "NT0_CFXCVL", "NT0_CTBCVL", "NT0_CFACVL"})
					lLimContr := (!Empty(aLimite[1]) .And. !Empty(aLimite[2]))

					If !Empty(cNVENUMCAS) .And. NVE->(ColumnPos("NVE_CMOELI")) > 0 //Regra + Prote��o
						aLimiteCas := JurGetDados("NVE", 1, xFilial("NVE") + cNVECCLIEN + cNVELCLIEN + cNVENUMCAS, {"NVE_CMOELI", "NVE_VLRLI", "NVE_CTBCVL", "NVE_CFACVL"})
					Else
						aLimiteCas := {"", 0, "", ""}
					EndIf

					lLimCaso := (!Empty(aLimiteCas[1]) .And. !Empty(aLimiteCas[2]))

					If lLimContr .Or. lLimCaso

						nSaldoNT0 := J201ASaldo(cNT0COD, @aSaldo) //retorna o Valor Dispon�vel do contrato
						nSaldoNVE := J201ASaldC(cNVECCLIEN, cNVELCLIEN, cNVENUMCAS, @aSaldo) //retorna o Valor Dispon�vel do Caso

						If lLimContr .And. lLimCaso
							nSaldo := Iif(nSaldoNT0 < nSaldoNVE, nSaldoNT0, nSaldoNVE) //Se tanto o caso quanto o contrato tiverem limite, usa o menor saldo.
						ElseIf lLimContr
							nSaldo := nSaldoNT0
						Else
							nSaldo := nSaldoNVE
						EndIf

						If nSaldo <= 0
							lTemDP := cTEMDP == "1" //Tem Despesas
							lTemFX := cTEMFX == "1" .And. aLimite[3] == "2" //Tem Fixo e n�o faz parte do limite do contrato excedido
							lTemLT := cTEMLT == "1" .And. (aLimite[4] == "2" .Or. aLimiteCas[3] == "2") //Tem Tabelado e n�o faz parte do limite do contrato ou caso excedido
							lTemFA := cTEMFA == "1" .And. (aLimite[5] == "2" .Or. aLimiteCas[4] == "2") //Tem Fatura Adicional e n�o faz parte do limite do contrato ou caso excedido
							lTemLM := cTEMLM == "1" //Tem saldo de limite execedido de faturas anteriores

							lPodeEmit := (nI == nTotEmite .And. lOkEmite) //Controle para permitir o EOF() da query e liberar a emiss�o caso tenha algo para emitir

							If !(lTemDP .Or. lTemLT .Or. lTemFX .Or. lTemFA .Or. lTemLM) .And. !lPodeEmit
								lLoop := .T.
							Else
								lOkEmite := .T. //Tem algo que a regra de Limite Geral excedido permite emitir
							EndIf
						EndIf
					EndIf
				EndIf

				If !lLoop
					If cTEMFA == "1"
						//Verifica as flags de transferencia para vincular os lan�amentos na Fatura Adicional
						aNVV := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD,;
										{"NVV_TRATS", "NVV_TRALT", "NVV_TRADSP", "NVV_DSPCAS", "NVV_DTINIH", ;   //5
										"NVV_DTFIMH", "NVV_DTINID", "NVV_DTFIMD", "NVV_DTINIT", "NVV_DTFIMT" } ) //10

						oParams:SetDIniH( aNVV[5] )
						oParams:SetDFinH( aNVV[6] )
						oParams:SetDIniD( aNVV[7] )
						oParams:SetDFinD( aNVV[8] )
						oParams:SetDIniT( aNVV[9] )
						oParams:SetDFinT( aNVV[10])
					EndIf

					While lAguarda .And. nVezes <= 2000
						lAguarda := J201AWaitDel("JA201AEmi: Erasing")

						If !lAguarda
							aRet := JA201JApag( oParams, cNVVCOD, cNW2COD, cNT0COD,;
							                    cNVECCLIEN, cNVELCLIEN, cNVENUMCAS,;
							                    cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA, cTEMLM,;
							                    cCodPre, STR0012) // #Cancelamento por emiss�o de pr�-fatura

						Else
							If nVezes == 0 .And. lFirstApag
								oParams:EventInsert(PREFATURA, STR0002) // "Aguardando outras emiss�es de pr�-faturas terminarem de substituir pr�s antigas."
								lFirstApag := .F.
							EndIf
							Sleep(10)
							nVezes++
						EndIf
					EndDo

					If nVezes == 2000
						aRet := {.F., STR0003} // "Tempo de espera por outras emiss�es de pr�-faturas foi esgotado! Favor Gerar novamente"
					EndIf

					If aRet[1]
						// Vincula os lan�amentos
						aRet := JA201BVinc(oParams, "", cCodPre, cNVVCOD, cNW2COD, cNT0COD, cNVECCLIEN, cNVELCLIEN, cNVENUMCAS, cTEMTS, cTEMLT, cTEMDP, cTEMFX, cTEMFA)

						If aRet[1]
							// Foram vinculados lan�amentos
							lVinc := .T.
						Else
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI

		If lVinc
			If aRet[1]
				aRet := JA201CEmi(oParams, cCodPre, cNVVCOD, cNW2COD, cNT0COD, lAutomato)
			EndIf

			If aRet[1]
				While __lSX8
					ConfirmSX8()
				EndDo

				cEvent += J201AGetInfo(cCodPre, nCount, {cNVVCOD, cNW2COD, cNT0COD})
			Else
				aAdd(aErros, {aRet[2], J201AGetInfo("", nCount, {cNVVCOD, cNW2COD, cNT0COD})} )
			EndIf
		EndIf

		If !lVinc .Or. !aRet[1]
			cCodPre := ""
			DisarmTransaction()
			While __lSX8 // Libera os registros usados na transa��o
				RollBackSX8()
			EndDo
		EndIf

	END TRANSACTION

Return cCodPre

//-------------------------------------------------------------------
/*/{Protheus.doc} J201AWaitDel()
Rotina para verificar se a rotina de apagar pre-fatura esta sendo executada
por algum usu�rio.

@author Felipe Bonvicini Conti
@since 20/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201AWaitDel(cObs)
Local lRet  := .F.
Local aInfo := GetUserInfoArray()

aEVal( aInfo, { |x| IIf( Upper(x[11]) $ Upper(cObs), lRet := .T., ) } )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201AGetInfo()
Rotina para gerar as informa��es para o EventViewer.

@param cCodPre, C�digo de pr�-fatura
@param nCount , Quantidade de pr�-faturas emitidas
@param aInfos , {C�d Fat Adicional, C�d Jun��o, C�d. Contrato}

@author Felipe Bonvicini Conti
@since 20/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201AGetInfo(cCodPre, nCount, aInfos)
	Local cRet     := ""

	Default aInfos := {}

	cRet += STR0005 + " " + AllTrim(Str(nCount)) + " - "// "Emiss�o"

	If !Empty(aInfos) .And. Len(aInfos) >= 3
		If !Empty(aInfos[1])
			cRet += AllTrim(RetTitle("NX0_CFTADC")) + ": " + aInfos[1] // "Fatura Adicional: "
		ElseIf !Empty(aInfos[2])
			cRet += AllTrim(RetTitle("NX0_CJCONT")) + ": " + aInfos[2] // "Jun��o: "
		Else
			cRet += AllTrim(RetTitle("NX0_CCONTR")) + ": " + aInfos[3] // "Contrato: "
		EndIf
	EndIf

	FWMonitorMsg(cRet)

	If !Empty(cCodPre)
		cRet += " - " + STR0004 + cCodPre + CRLF // "Pr�-fatura: "
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ASaldo()
Rotina para pesquizar e memorizar o saldo do contrato

@Param cContr  Codigo do contrato
@Param aSaldo  Array pesquizas j� realizadas, passado por referencia

@author Luciano Pereira dos Santos
@since 07/06/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201ASaldo(cContr, aSaldo)
Local nRet       := 0
Local nPos       := 0

Default cContr   := ""
Default aSaldo   := {}

If Len(aSaldo) > 0 .And. (nPos := aScan(aSaldo, {|aX| aX[1] == cContr})) > 0
	nRet := aSaldo[nPos][2]
Else
	nRet := J201GSldLm(cContr, '2')
	aAdd(aSaldo, {cContr, nRet})
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ASaldC()
Rotina para pesquizar e memorizar o saldo do Caso

@Param cCliente  Codigo do cliente
@Param aSaldo  Array pesquizas j� realizadas, passado por referencia

@author Anderson Carvalho \ Queizy
@since 03/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201ASaldC(cCliente, cLoja, cCaso, aSaldo)
Local nRet        := 0
Local nPos        := 0

Default cCliente  := ""
Default cLoja     := ""
Default cCaso     := ""
Default aSaldo    := {}

If Len(aSaldo) > 0 .And. (nPos := aScan(aSaldo, {|aX| aX[1] == cCliente + cLoja + cCaso})) > 0
	nRet := aSaldo[nPos][2]
Else
	nRet := J201GSldCs(cCliente, cLoja, cCaso, '2')
	aAdd(aSaldo, {cCliente, cLoja, cCaso, nRet})
EndIf

Return nRet
