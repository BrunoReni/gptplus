#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA765.CH"

Static cTmpAlias := ""
Static oGSTmpTb

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA765
Monitor de Marcações de Atendentes
@sample TECA765()
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function TECA765()

	Local cPerg := "TECA765"
	Local aArea := GetArea()

	Private cCadastro := STR0001 //"Monitor de Marcações de Atendentes"

	If AliasInDic("T40")
		DbSelectArea("T40")
		T40->(DbSetOrder(1)) //T40_FILIAL+T40_VALCON

		DbselectArea("TE3")
		TE3->(DbSetOrder(1)) //TE3_FILIAL+TE3_CODIGO

		If Pergunte(cPerg,.T.)
			Processa( {|| (AT765Brow(cPerg)) }, STR0005, STR0006,.F.) //"Aguarde..."##"Processando a requisição solicitada..."
		Endif	

		RestArea(aArea)
	Else
		Help( " ", 1, "TECA765", Nil, STR0004, 1 ) //"Tabela T40 não existe no dicionário de Dados"
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765Brow
Definicao do Objeto Browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765Brow(cPerg)

	Local oBrowse  := Nil
	Local aStru    := AT765aStru()
	Local bTimer   := {||AT765AtBrw(@oBrowse)}
	Local aColumns := {}
	Local aSeek    := {}

	oBrowse:= FWmBrowse():New()
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)

	At765Cria(@oBrowse)

	oBrowse:SetMenuDef("")
	oBrowse:SetDescription(OEmToAnsi(cCadastro))

	oBrowse:AddButton(STR0007,{||Pergunte(cPerg,.T.),AT765AtBrw(@oBrowse)}) // Parametros
	oBrowse:AddButton(STR0017,{||At765Batida(),AT765AtBrw(@oBrowse)}) // Ajuste de Batida
	oBrowse:AddButton(STR0008,{||CloseBrowse()}) // Sair

	oBrowse:AddStatusColumns( { || Chkmarc() }, { || ConsLeg() } )

	If ExistBlock("TC765Bro")
		oBrowse := ExecBlock("TC765Bro", .F., .F., {oBrowse} )
	EndIf

	aColumns := AT765aCols(aStru)
	
	oBrowse:SetColumns(aColumns)

	aAdd(aSeek, {TxDadosCpo('ABB_FILIAL')[1],{{'','C',TamSX3('ABB_FILIAL')[1],TamSX3('ABB_FILIAL')[2],TxDadosCpo('ABB_FILIAL')[1],PesqPict('ABB','ABB_FILIAL'),NIL}},1,.T.})
	aAdd(aSeek, {TxDadosCpo('ABB_CODTEC')[1],{{'','C',TamSX3('ABB_CODTEC')[1],TamSX3('ABB_CODTEC')[2],TxDadosCpo('ABB_CODTEC')[1],PesqPict('ABB','ABB_CODTEC'),NIL}},2, .T.})

	oBrowse:SetSeek(.T., aSeek)

	oBrowse:SetTimer(bTimer, MV_PAR01 * 60000) // 60.000 aproximadamente 1 Minuto
	oBrowse:SetParam({||Pergunte(cPerg,.T.),AT765AtBrw(@oBrowse)})

	oBrowse:DisableConfig()

	oBrowse:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765AtBrw
Criacao do Objeto Browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function AT765AtBrw(oBrw)

	(At765Alias())->(DbCloseArea())
	At765Cria(@oBrw)
	oBrw:Refresh(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Alias
Retorna alias uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765Alias(cSetValue)

	If VALTYPE(cSetValue) == 'C'
		cTmpAlias := cSetValue
	EndIf

Return cTmpAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Alias
Retorna query uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765QryGen(aTmpStruct)

	Local cQuery   := ""
	Local cxFilTDV := " = '" + xFilial("TDV",cFilAnt) + "'"
	Local nX       := 0

	// Formatar parametro do tipo Range
	If !Empty(MV_PAR02)
		xFilTDV := At765Range(MV_PAR02)
	Endif

	cQuery += " SELECT  "
	For nX := 1 To Len(aTmpStruct)
		If !aTmpStruct[nX,1] $ "T40_TIPOMA|T40_HPREVI"
			cQuery += aTmpStruct[nX,1] + ", "
		EndIf
	Next nX
	// Campos Virtuais
	cQuery += "' ' T40_TIPOMA, ' ' T40_HPREVI"
	// Integração de marcações
	cQuery += " FROM "+ RetSqlName('T40') + " T40 "
	// Funcionários
	cQuery += " INNER JOIN "+RetSqlName('SRA')+" SRA ON  SRA.RA_FILIAL='"+xFilial("SRA")+"' AND SRA.RA_PIS = T40.T40_CODPIS  AND SRA.D_E_L_E_T_ = '' "
	// Atendentes
	cQuery += " INNER JOIN "+RetSqlName('AA1')+" AA1 ON  AA1.AA1_FILIAL='"+xFilial("AA1")+"' AND AA1.AA1_CDFUNC = SRA.RA_MAT AND AA1.AA1_FUNFIL = SRA.RA_FILIAL AND AA1.D_E_L_E_T_ = '' "
	// Agenda de Atendentes
	cQuery += " INNER JOIN ( "
	cQuery += " SELECT DISTINCT ABB_FILIAL, ABB_CODTEC, ABB_LOCAL, ABB_DTINI"
	cQuery += " FROM "+RetSqlName('ABB')+" ABB "
	cQuery += " WHERE ABB_FILIAL " + cxFilTDV + " AND ABB.D_E_L_E_T_ = ' ' "
	cQuery += " AND ABB.ABB_LOCAL >= '"+MV_PAR03+"' AND ABB.ABB_LOCAL <= '"+MV_PAR04+"' "
	cQuery += " AND ABB.ABB_DTINI BETWEEN '"+DtOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"') AGE "
	cQuery += " ON AGE.ABB_CODTEC = AA1.AA1_CODTEC AND AGE.ABB_DTINI = T40.T40_DATMAR "
	cQuery += " INNER JOIN "+RetSqlName('ABS')+" ABS ON ABS.ABS_FILIAL='"+xFilial("ABS")+"' AND ABS.ABS_LOCAL=AGE.ABB_LOCAL AND ABS.D_E_L_E_T_ = ' ' 
	cQuery += " WHERE "
	cQuery += " T40_FILIAL = '" + xFilial("T40",cFilAnt) + "' AND "
	cQuery += " T40_DATMAR BETWEEN '" + DTOS(MV_PAR05) + "' AND '"+ DTOS(MV_PAR06) + "' AND "
	cQuery += " T40_AGEINT <> 'S' AND "
	cQuery += " T40.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY T40_FILIAL, T40_DATMAR, T40_CODPIS, T40_NUMMAR"
	cQuery := ChangeQuery(cQuery)

Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Range
Formatar parametro do tipo Range
@since	07/11/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765Range(cConteudo)

	Local aRet := {}
	Local cRet := ""
	Local nX   := 0

	Default nTipo := 1
	Default cConteudo := ""

	aRet := StrTokArr(cConteudo,";")
	nTam := Len(aRet)-1
	cRet := "IN ("
	For nX := 1 to nTam
    	cRet += "'" + xFilial("ABB",aRet[nX]) +  "',"
	Next nX
	cRet := Substring(cRet,1,Len(cRet)-1)
	cRet += ")"
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Cria
Criacao tabela temporaria
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765Cria(oBrw)

Local cAliasTmp  := IIF( EMPTY(At765Alias()) , GetNextAlias() , At765Alias())
Local aTmpStruct := AT765aStru()
Local aInsert    := {}
Local aIdx       := {}
Local nX         := 0
Local cAliasAux  := GetNextAlias()
Local lRet       := .F.
Local xValue
Local nAtual     := 1
Local cOperado   := ""
Local lOK        := .F.
Local cCodTecABB   := ""
Local cFilialABB   := ""
Local cDatMarT40   := ""
Local nHoraIniABB  := 0
Local aBatidas     := {} //Array com batidas da ABB
Local nBatidas     := 0
Local nRegistro    := 0
Local nLimEAtraso  := 0 // Entrada com atraso
Local nLimEExtra   := 0 // Entrada hora extra - Antes do horario
Local nSaidaExtra  := 0 // Saida com Hora extra
Local nSaidaAtraso := 0 // Saida Antecipada
Local cContrato    := ""
Local cLimiteMar   := ""
Local nHoraLEExtra := 0
Local nHoraLIMEnt  := 0
Local cTipoMar     := ""
Local nHoraBatida  := 0
Local cTipo        := ""

	If VALTYPE(oGSTmpTb) == 'O'
		oGSTmpTb:Close()
		TecDestroy(oGSTmpTb)
	EndIf

	//Cria indices para a tabela temporária 
	Aadd(aIdx, {"I1",{ 'ABB_FILIAL' },{ 'ABB_DTINI' },{ 'ABB_CODTEC' }})
	Aadd(aIdx, {"I2",{ 'ABB_CODTEC' }})

	oGSTmpTb := GSTmpTable():New(cAliasTmp,aTmpStruct,aIdx)
	If !oGSTmpTb:CreateTMPTable()
		oGSTmpTb:ShowErro()
	Else
	    Count to nTotal
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,At765QryGen(aTmpStruct)),cAliasAux, .F., .T.)
    	ProcRegua(nTotal)

			While (cAliasAux)->(!EOF())

				aInsert := {}

				If Empty(nRegistro)

					nRegistro := 1
					cCodTecABB   := (cAliasAux)->ABB_CODTEC // Codigo do atendente
					cFilialABB   := (cAliasAux)->ABB_FILIAL // Filial da Agenda
					cDatMarT40   := (cAliasAux)->T40_DATMAR // Data da batida
					nBatidas  	 := ChkContd((cAliasAux)->T40_CODPIS,(cAliasAux)->T40_DATMAR ) //Quantidade de batidas
					aBatidas   	 := ChkQtdAtd(cCodTecABB,cDatMarT40) // Array com as batidas da ABB
					cContrato    := ChkContrt((cAliasAux)->ABB_CODTEC,(cAliasAux)->T40_DATMAR) // Numero do contrato
					cLimiteMar   := At765BLmar(cContrato) // Codigo da pesquisa de marcações

					If TE3->(DbSeek(Xfilial("TE3")+cLimiteMar ))
						nLimEAtraso  := TECMinSeg(TE3->TE3_ENTATE) // Entrada com atraso
						nLimEExtra   := TECMinSeg(TE3->TE3_ENTEXE) // Entrada hora extra - Antes do horario
						nSaidaExtra  := TECMinSeg(TE3->TE3_SAIEXE) // Saida com Hora extra
						nSaidaAtraso := TECMinSeg(TE3->TE3_SAIATE) // Saida Antecipada	
					Endif	

				Endif

				If nBatidas > 0
					If  nRegistro == 1
						nHoraIniABB  := TECXMinHor(Substring(ChkHrini(cCodTecABB,cDatMarT40,"EN"),4,5)) 
						nHoraLIMEnt  := nHoraIniABB+nLimEAtraso // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB-nLimEExtra  // Hora Prevista de entrada + Tolerancia de extra entrada
						nHoraBatida  := (cAliasAux)->T40_NUMMAR // Hora da batida
						If nHoraLIMEnt < nHoraBatida
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "A" //ATRASO
						Elseif nHoraBatida < nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "C" //ENTRADA ANTECIPADA
						Endif
						cTipoMar := STR0023 + AllTrim(Str((nRegistro+1)/2)) //"Entrada"
						nRegistro ++
						If nBatidas < nRegistro // Controle de quantidade de batidas
							nRegistro := 0
						Endif
					Elseif nRegistro == 2
						nHoraIniABB  := TECXMinHor(Substring(ChkHrini(cCodTecABB,cDatMarT40,"EA"),4,5)) 
						nHoraLIMEnt  := nHoraIniABB+nSaidaAtraso // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB-nSaidaExtra  // Hora Prevista de entrada + Tolerancia de extra entrada
						nHoraBatida  := (cAliasAux)->T40_NUMMAR  // Hora da batida
						If nHoraBatida < nHoraLIMEnt
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "D" //SAIDA ANTECIPADA
						Elseif nHoraBatida > nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "B" //HORA EXTRA
						Endif
						cTipoMar := STR0024 + AllTrim(Str(nRegistro/2)) //"Saida "
						nRegistro ++
						If nBatidas < nRegistro // Controle de quantidade de batidas
							nRegistro := 0
						Endif
					Elseif nRegistro == 3
						nHoraIniABB  := TECXMinHor(Substring(ChkHrini(cCodTecABB,cDatMarT40,"SA"),4,5)) 
						nHoraLIMEnt  := nHoraIniABB+nLimEAtraso // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB-nLimEExtra  // Hora Prevista de entrada + Tolerancia de extra entrada
						nHoraBatida  := (cAliasAux)->T40_NUMMAR // Hora da batida
						If nHoraLIMEnt < nHoraBatida
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "A" //ATRASO
						Elseif nHoraBatida < nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "C" //ENTRADA ANTECIPADA
						Endif
						cTipoMar := STR0023 + AllTrim(Str((nRegistro+1)/2)) //"Entrada "
						nRegistro ++
						If nBatidas < nRegistro // Controle de quantidade de batidas
							nRegistro := 0
						Endif
					Elseif nRegistro == 4
						nHoraIniABB  := TECXMinHor(Substring(ChkHrini(cCodTecABB,cDatMarT40,"SN"),4,5)) 
						nHoraLIMEnt  := nHoraIniABB+nSaidaAtraso // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB-nSaidaExtra  // Hora Prevista de entrada + Tolerancia de extra entrada
						nHoraBatida  := (cAliasAux)->T40_NUMMAR  // Hora da batida
						If nHoraBatida < nHoraLIMEnt
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "D" //SAIDA ANTECIPADA
						Elseif nHoraBatida > nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "B" //HORA EXTRA
						Endif
						cTipoMar := STR0024 + AllTrim(Str(nRegistro/2)) //"Saida "
						nRegistro ++
						If nBatidas < nRegistro // Controle de quantidade de batidas
							nRegistro := 0
						Endif
					ElseIf nRegistro >= 5
						nHoraIniABB := 0
						nHoraBatida := (cAliasAux)->T40_NUMMAR  // Hora da batida
						lOk := .T.
						cTipo := "E" //SEM AGENDA
						If (nRegistro % 2) == 1
							cTipoMar := STR0023 + AllTrim(Str((nRegistro+1)/2)) //"Entrada "
						Else
							cTipoMar := STR0024 + AllTrim(Str(nRegistro/2)) //"Saida "
						EndIf
						nRegistro ++
						If nBatidas < nRegistro // Controle de quantidade de batidas
							nRegistro := 0
						Endif
					Endif
				Endif	

				If lOK			
					For nX := 1 To LEN(aTmpStruct)
						xValue := (&("(cAliasAux)->" + aTmpStruct[nX][1]))
						If aTmpStruct[nX][1] == 'T40_NUMMAR'
							Aadd(aInsert, {aTmpStruct[nX][1],TECXHorMin(nHoraBatida)+cTipo})
						ElseIf aTmpStruct[nX][1] == 'T40_TIPOMA'
							Aadd(aInsert, {aTmpStruct[nX][1], cTipoMar })
						ElseIf aTmpStruct[nX][1] == 'AA1_NOMTEC'
							cOperado := xValue
							Aadd(aInsert, {aTmpStruct[nX][1], xValue })
						ElseIf aTmpStruct[nX][1] == "T40_HPREVI
							Aadd(aInsert, {aTmpStruct[nX][1], TECXHorMin(nHoraIniABB) })
						ElseIf aTmpStruct[nX][2] == 'D'
							Aadd(aInsert, {aTmpStruct[nX][1], STOD(xValue) })
						Else
							Aadd(aInsert, {aTmpStruct[nX][1], xValue })
						EndIf
						IncProc(STR0013 + cValToChar(nAtual) + STR0014 + cOperado  )
					Next nX
				Else
					(cAliasAux)->(DbSkip())
					lOK := .F.
				Endif

				If lOK
					If ( lRet := ( oGSTmpTb:Insert(aInsert) .AND. oGSTmpTb:Commit() ) )
						(cAliasAux)->(DbSkip())
						lOK := .F.
					Else
						oGSTmpTb:ShowErro()
						Exit
					EndIf
				Endif	
				nAtual++

			End	
		If ( Select( cAliasAux ) > 0 )
			DbSelectArea(cAliasAux)
			(cAliasAux)->(DbCloseArea())
			cAliasAux := ""
		EndIf
	EndIf
	At765Alias(oGSTmpTb:cAliasTmp)
	( At765Alias() )->(DbGoTop())
	oBrw:SetAlias((At765Alias()))

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765aStru
Definicao dos campos uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765aStru()

    Local aRet     := {}
	Local aUSRCpos := {}
	Local nX       := 0

	Aadd(aRet, At765Field("ABB_FILIAL"))
	Aadd(aRet, At765Field("ABB_CODTEC"))
	Aadd(aRet, At765Field("AA1_NOMTEC"))
	Aadd(aRet, At765Field("T40_DATMAR"))
	Aadd(aRet, At765Field("T40_TIPOMA"))
	Aadd(aRet, At765Field("T40_HPREVI"))
	Aadd(aRet, At765Field("T40_NUMMAR"))
	Aadd(aRet, At765Field("ABB_DTINI" ))
	Aadd(aRet, At765Field("ABB_LOCAL" ))
	Aadd(aRet, At765Field("ABS_DESCRI"))
	Aadd(aRet, At765Field("T40_CODREL"))
	Aadd(aRet, At765Field("T40_CODFUN"))
	Aadd(aRet, At765Field("T40_LOGIP" ))
	Aadd(aRet, At765Field("T40_CODNSR"))
	Aadd(aRet, At765Field("T40_CODPIS"))
	Aadd(aRet, At765Field("T40_CODREP"))
	Aadd(aRet, At765Field("T40_CODUNI"))
	Aadd(aRet, At765Field("T40_CODUSU"))
	Aadd(aRet, At765Field("T40_LONGIT"))
	Aadd(aRet, At765Field("T40_LATITU"))
	Aadd(aRet, At765Field("T40_GEOFEN"))
	Aadd(aRet, At765Field("T40_AGEINT"))

	If ExistBlock("TC765STR")
		aUSRCpos := aClone(ExecBlock("TC765STR", .F., .F., {aRet}))
		If Valtype(aUSRCpos) == "A" .And. Len(aUSRCpos) > 0
			For nX := 1 to Len(aUSRCpos)
				aAdd(aRet, {aUSRCpos[nX][1], aUSRCpos[nX][2], aUSRCpos[nX][3], aUSRCpos[nX][4]})
			Next nX
		EndIf
	EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Field
Definicao das colunas uso do browse
@since  23/08/2022
@author flavio.vicco
@return Array Campo, Tipo, Tamanho, Decimais
/*/
//------------------------------------------------------------------------------
Function At765Field(cField)

	Local aRet   := {}
	Local aField := {}

	aRet   := FwTamSx3(cField)
	aField := {cField, aRet[3], aRet[1], aRet[2]}

	// Altera tipo/tamanho do campo de Hora Marcada
	If cField == "T40_NUMMAR"
		aField[2] := "C"
		aField[3] :=  8
	Endif

Return aField

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765aCols
Definicao das colunas uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765aCols(aStru)

	Local nY       := 0
	Local nTam     := 0
	Local aColumns := {}
	Local cAlias   := At765Alias()
	Local cField   := ""
	Local cMasc    := ""
	Local cTitle   := ""

	For nY := 1 To Len(aStru)
		cField := aStru[nY][1]
		If !cField $ "T40_AGEINT"
			cMasc  := X3Picture(cField)
			cTitle := RetTitle(cField)
			If cField $ "T40_NUMMAR|T40_HPREVI"
				cMasc := "99:99"
			EndIf

			AAdd(aColumns,FWBrwColumn():New())
			nTam := Len(aColumns)
			If aStru[nY][2] == 'C'
				aColumns[nTam]:SetData(&("{||Rtrim("+(cAlias)+"->"+(cField)+")}"))
			Else
				aColumns[nTam]:SetData(&("{||"+cAlias+"->"+cField+"}"))
			EndIf
			aColumns[nTam]:SetTitle(cTitle)
			aColumns[nTam]:SetSize(aStru[nY][3])
			aColumns[nTam]:SetDecimal(aStru[nY][4])
			aColumns[nTam]:SetPicture(cMasc)
		EndIf

	Next nY

Return aColumns


//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkQtdAtd
Quantidades de batida no dia
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function ChkQtdAtd(cAtend,dDtini)

Local cQry    := ""
Local cAliasABB := GetnextAlias()
Local aABB := {}


	cQry := " SELECT ABB_HRINI, ABB_HRFIM  FROM "+RetSqlname("ABB")+" ABB "
	cQry += " WHERE ABB_CODTEC = '"+cAtend+"' "
	cQry += " AND ABB_DTINI = '"+dDtini+"' "
	cQry += " AND ABB.D_E_L_E_T_ = '' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasABB,.T.,.T.)

	While (cAliasABB)->(!Eof())
		AADD(aABB,(cAliasABB)->ABB_HRINI)
		AADD(aABB,(cAliasABB)->ABB_HRFIM)
		(cAliasABB)->(DbSkip())
	Enddo

	(cAliasABB)->(DbCloseArea())

Return aABB


//------------------------------------------------------------------------------
/*/{Protheus.doc} Chkmarc
Define cor da Legenda no grid
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Static Function Chkmarc()

Local cCor := ""

If Substring(T40_NUMMAR,6,1) == "A"
    cCor := "BR_AMARELO"  //ATRASO
ElseIf Substring(T40_NUMMAR,6,1) == "B"
	cCor := "BR_AZUL"     //HORA EXRA
ElseIf Substring(T40_NUMMAR,6,1) == "C"
	cCor := "BR_VERDE"    //ENTRADA ANTECIPADA
ElseIf Substring(T40_NUMMAR,6,1) == "D"
	cCor := "BR_VERMELHO"  //SAIDA ANTECIPADA
ElseIf Substring(T40_NUMMAR,6,1) == "E"
	cCor := "BR_PRETO"     //SEM AGENDA
Endif

Return cCor

//------------------------------------------------------------------------------
/*/{Protheus.doc} Chkmarc
Define cor da Legenda que sera apresentada ao usuario
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Static Function ConsLeg()

Local oLegend := FWLegend():New()

oLegend:Add("","BR_AZUL"    ,STR0015) //Hora Extra
oLegend:Add("","BR_AMARELO" ,STR0016) //Atraso
oLegend:Add("","BR_VERDE"   ,STR0020) //"Entrada Antecipada"
oLegend:Add("","BR_VERMELHO",STR0021) //"Saida Antecipada"
oLegend:Add("","BR_PRETO"   ,STR0022) //"Sem Agenda"
oLegend:Activate()
oLegend:View()
oLegend:DeActivate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkHrini
Hora de inicio do turno na ABB
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function ChkHrini(cAtend,dDtini,cTipo)

Local cQry   := ""
Local aABB   := {}
Local nRegs  := 0
Local cHrEnt := ""
Local cHrSai := ""
Local cHoraRet  := ""
Local cAliasABB := GetnextAlias()

    If cTipo $ "EN|SA" // Entrada periodo / Saida Almoço
		cQry := " SELECT ABB_HRINI HORAS "
	Elseif cTipo $	"EA|SN" // Entrada Almoço / Saida do periodo
		cQry := " SELECT ABB_HRFIM HORAS "
	Endif
	cQry += " FROM "+RetSqlname("ABB")+" ABB "
	cQry += " WHERE ABB_CODTEC = '"+cAtend+"' "
	cQry += " AND ABB_DTINI = '"+dDtini+"' "
	cQry += " AND ABB.D_E_L_E_T_ = '' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasABB,.T.,.T.)
	While (cAliasABB)->(!Eof())
		AADD(aABB,((cAliasABB)->HORAS))
		(cAliasABB)->(DbSkip())
	Enddo
	(cAliasABB)->(DbCloseArea())

	nRegs := Len(aABB)
	If nRegs >= 1
		cHrEnt := aABB[1]
		If nRegs >= 2
			cHrSai := aABB[2]
		EndIf
	Endif

	If cTipo $ "EN|SA"
		If cTipo == "EN"
			cHoraRet  := cTipo +"/"+cHrEnt
		Elseif  cTipo == "SA"
			cHoraRet  := cTipo +"/"+cHrSai
		Endif
	ElseIF cTipo $ "EA|SN"
		If cTipo == "EA"
			cHoraRet  := cTipo +"/"+cHrEnt
		Elseif  cTipo == "SN"
			cHoraRet  := cTipo +"/"+cHrSai
		Endif
	Endif

Return cHoraRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} TECXHorMin
Recebe o numero de segundos e transforma em hora
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function TECXHorMin(xValue)

local nHoraDec  := 0
Local nMinuDec  := 0
Local cTimeEnt := ""

nHoraDec := StrZero(Int(xValue/3600),2)
nMinuDec := cValtoChar( ( (xValue/3600) - Int(xValue/3600) ) * 60)
cTimeEnt := nHoraDec + ":" + StrZero(Val(Substring(nMinuDec,1,2)),2)

Return cTimeEnt

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECXMinHor
Recebe a hora e transforma em segundos
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function TECXMinHor(xValue)

local nHoraMarc := 0

nHoraMarc := (( Val(SubStr(xValue,4,2))/60) + (Val(SubStr(xValue,1,2)))) * 3600	

Return nHoraMarc


//------------------------------------------------------------------------------
/*/{Protheus.doc} TECMinSeg
Recebe minutos e transforma em segundos
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function TECMinSeg(xValue)

local nSegundos := 0

nSegundos := (xValue * 60)	

Return nSegundos

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkQtdAtd
Quantidades de batidas no dia
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function ChkContd(cCodPis,dDtini)

Local cQry      := ""
Local cAliasABB := GetnextAlias()
Local nBatidas  := 0

	cQry := " SELECT COUNT(*) BATIDAS FROM "+RetSqlname("T40")+" T40 "
	cQry += " WHERE T40_CODPIS = '"+cCodPis+"' "
	cQry += " AND T40_DATMAR = '"+dDtini+"' "
	cQry += " AND T40_FILIAL = '"+xFilial("T40")+"' "
	cQry += " AND T40.D_E_L_E_T_ = '' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasABB,.T.,.T.)

	nBatidas := (cAliasABB)->BATIDAS

	(cAliasABB)->(DbCloseArea())

Return nBatidas

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkContrt
Busca numero do contrato na ABB
@since		10/10/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function ChkContrt(cAtend,dDtini)

Local cQry    := ""
Local cCtrABB := ""
Local cAliasABB := GetNextAlias()


	cQry := " SELECT ABB_IDCFAL CONTRATO FROM "+RetSqlname("ABB")+" ABB "
	cQry += " WHERE ABB_CODTEC = '"+cAtend+"' "
	cQry += " AND ABB_DTINI = '"+dDtini+"' "
	cQry += " AND ABB_FILIAL = '"+xFilial("ABB")+"'"
	cQry += " AND ABB.D_E_L_E_T_ = '' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasABB,.T.,.T.)

	cCtrABB := Substring((cAliasABB)->CONTRATO,1,15)

	(cAliasABB)->(DbCloseArea())

Return cCtrABB


//------------------------------------------------------------------------------
/*/{Protheus.doc} At765BLmar
Retorna registro referente ao limite de marcações
@since		10/10/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function At765BLmar(cContrato)

Local cQry    := ""
Local cLMTFF := ""
Local cAliasTFF := GetNextAlias()

cQry := "  SELECT DISTINCT TFF_CODLIM LIMITE "
cQry += "  FROM  "+RetSqlName("TFF")+" TFF  "
cQry += "  INNER JOIN "+RetSqlName("TFL")+" TFL  ON TFF_CODPAI = TFL_CODIGO  AND TFL_FILIAL = '"+xFilial("TFL")+ "' "
cQry += "  INNER JOIN "+RetSqlName("TFJ")+" TFJ  ON TFL_CODPAI = TFJ_CODIGO  AND TFF_FILIAL = '"+xFilial("TFF")+ "' "
cQry += "  WHERE TFF_CONTRT = '"+cContrato+"'"
cQry += "  AND TFL.D_E_L_E_T_ = '' AND TFF.D_E_L_E_T_ = '' AND TFJ.D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFF,.T.,.T.)

cLMTFF := (cAliasTFF)->LIMITE

(cAliasTFF)->(DbCloseArea())

Return cLMTFF


//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Batida
Retorna Realiza o ajuste de batida
@since  18/01/2023
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function At765Batida()
Local lPerm := At680Perm(NIL, __cUserId, "070", .T.)
Local aArea := GetArea()

If lPerm
	cAliasABB := At765Alias()
	If (cAliasABB)->(!EOF())
		At203Batida((cAliasABB)->ABB_CODTEC,(cAliasABB)->T40_DATMAR)
	EndIf
Else
	Help( , , "At765Batida", , STR0018, 1, 0,,,,,,{STR0019}) //"Usuário sem permissão de realizar ajuste de batida manual" ## "Verifique a configuração de permissões do usuario na rotina TECA680, permissão 070."
EndIf

RestArea(aArea)
Return
