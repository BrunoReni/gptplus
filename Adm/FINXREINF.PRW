#include 'PROTHEUS.CH'

Static __oQryFKW      As Object
Static __oQryPerN     As Object
Static __oQryBase     As Object
/*
	Fonte generico para funções do REINF 2.1.1
*/


//--------------------------------------------------------------------------------------
/*/{Protheus.doc}GetPropImp
Retorna o valor dos impostos retidos e não retidos da baixa a pagar proporcionalizados 
por Natureza de Rendimento (REINF - Bloco 40).

@param cChave    - Chave do titulo
@param cTpImp    - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdFk4    - Id da FK4 (FK4_IDFK4)
@param nBasImp   - Valor da base de calculo a ser proporcionalizada
@param nValImp   - Valor do imposto a ser proporcionalizado (informado quando houver retencao)
@param nValBx  	 - Valor da baixa
@param nTotImpBx - Valor total de todos os impostos com fato gerador na baixa do titulo
@param dDtBx     - Data da baixa
@param cMotBaix  - Motivo da baixa
@param cTabOri  - tabela de origem calculo (FK3), tabela de origem de retenção (FK4), sem impostos ou isenção/suspensão (FKW)
@param aRatIRPF - array dados para registro do rateio CPF
	aRatIRPF[x][1] - CPF
	aRatIRPF[x][2] - % DE RATEIO
	aRatIRPF[x][3] - Valor de imposto calculado
	aRatIRPF[x][4] - cIdorig
	aRatIRPF[x][5] - cTabOri
@Retorno - Array com as posições abaixo:
[1] Filial
[2] ID da baixa (FK2_IDFK2)
[3] Codigo do Imposto
[4] Natureza de Rendimento
[5] Percentual de proporcionalização
[6] Valor da Base de calculo
[7] Valor do imposto retido
[8] Valor da base com exigibilidade suspensa
[9] Valor do imposto que deixou de ser efetuado
[10] Numero do processo judicial/administrativo
[11] Tipo do processo
[12] Cod. indicacao de suspencao judicial

@author Fabio Casagrande Lima
@since  25/07/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Function GetPropImp(cChave, cTpImp, cIdOrig, nBasImp, nValImp, nValBx, nTotImpBx, dDtBx, cMotBaix,cTabOri, aRatIRPF) 

	Local cIdDoc    As Character
	Local cNatRen   As Character
	Local cFilFKY   As Character
	Local cCodProc  As Character
	Local cTpProc   As Character
	Local cIndSusp  As Character 
	Local aDadosFKY As Array
	Local aArea		As Array
	Local nBasNRet  As Numeric
	Local nImpNRet  As Numeric
	Local nBasFKW   As Numeric
	Local nImpFKW   As Numeric
	Local nTotTit   As Numeric
	Local nBasCoef  As Numeric
	Local lTabProg  As Logical
	Local lJurMul   As Logical
	Local nCoef  	As Numeric
	Local nCalc     As Numeric
	Local lRatIRPF  As Logical
	Local nX     	As Numeric
	Local lVlBxAlt	As Logical
	Local lBordero	As Logical

	Default cChave   	:= ""
	Default cTpImp   	:= ""
	Default cIdOrig  	:= ""	
	Default nBasImp  	:= 0
	Default nValImp  	:= 0
	Default nValBx   	:= 0
	Default nTotImpBx 	:= 0
	Default dDtBx    	:= dDataBase
	Default cMotBaix 	:=""
	Default cTabOri   	:= "FK4"
	Default aRatIRPF   	:= {}

	aArea	  := GetArea()
	aDadosFKY := {}	
	lTabProg  := SA2->A2_TIPO == 'F' .or. SA2->A2_IRPROG == '1'
	cNatRen   := ""
	cFilFKY   := xFilial("FKY")
	cIdDoc    := FINGRVFK7( 'SE2', cChave ) 
	cCodProc  := ""
	cTpProc   := ""
	cIndSusp  := ""
	nBasNRet  := 0
	nImpNRet  := 0
	lJurMul   := SuperGetMv("MV_IMPBAIX",.t.,"2") == "1"
	nTotTit   := salRefPag(SE2->E2_FORNECE + SE2->E2_LOJA,,,,,,, .T.)
	nBasCoef  := nBasImp
	nCalc 	  := 0
	nCoef	  := 1
	lRatIRPF  := Len(aRatIRPF)>0
	nX		  := 0
	lVlBxAlt  := .F.
	lBordero  := FwIsInCallStack("FINA241") .or. FwIsInCallStack("FINA590")

	If lJurMul
		nTotTit+= SE2->(E2_SDACRES - E2_SDDECRE)
	EndIf

	If "IRF" $ cTpImp .And. lTabProg .And. !lBordero

		If FindFunction("F080RAltBx")
			If FwIsInCallStack("FINA080")
				lVlBxAlt := F080RAltBx()
			EndIf
		EndIf
		If lVlBxAlt
			nCalc  := nValBx
		Else 
			nCalc  := (nValBx+nValImp)
		EndIf 
		nCalc  := (nCalc/xMoeda(nTotTit, SE2->E2_MOEDA, 1, dDataBase,, SE2->E2_TXMOEDA)) //Trata IRPF a parte devido o 'nBasImp' chegar com a base reduzida na FK4

	Elseif Alltrim(cTpImp) $ "SEMIMP" 
		nCalc  := (nBasCoef / xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, 1, dDataBase,, SE2->E2_TXMOEDA))	
		
	Else	
		//Grava a base de calculo quando o imposto esta totalmente isentos ou suspenso para achar o coeficiente corretamente
		If (nBasImp == 0 .and. nValImp == 0) 
			nBasCoef := GetBasNR(cIdDoc,cTpImp,nValBx,nTotImpBx,nTotTit)
		Endif

		nCalc  := (nBasCoef / xMoeda(nTotTit, SE2->E2_MOEDA, 1, dDataBase,, SE2->E2_TXMOEDA))
	    	
	Endif

	If nCalc != 0
		nCoef  := nCalc
	Endif

			
	DbSelectArea("FKW")
	FKW->(DBSetOrder(3)) //FKW_FILIAL+FKW_IDDOC+FKW_TPIMP+FKW_CGC
	FKW->(dbGoTop())

	//Identifica o coeficiente da baixa para calcular a proporcionalidade do imposto nao retido de acordo com o valor baixado.
	If !lRatIRPF
		If FKW->(DBSeek(xFilial("FKW") + cIdDoc + cTpImp)) //Caso existir registro na FKW deve respeitar a proporcionalizacao de la (Origem Doc. Entrada)
			While !FKW->(Eof()) .And. FKW->FKW_IDDOC+Alltrim(FKW->FKW_TPIMP) == cIdDoc+AllTrim(cTpImp) 
				
				cNatRen   := FKW->FKW_NATREN

				If Empty(cIdOrig)
					cTabOri := "FKW"
					cIdOrig := FKW->FKW_IDFKW
				Endif

				//Tratamento na base do imposto para considerar a proporcionalidade
				nBasFKW  := GetBaseFKW(cTpImp, cIdDoc)     //Verifica base real do imposto quando origem de nota fiscal
				nBasFKW  := nBasFKW * nCoef				//Aplica coeficiente da baixa
				nBasFKW  := (nBasFKW * FKW->FKW_PERC)/100	//Aplica proporcionalidade da natureza de rendimento na base de calculo
				nImpFKW  := (nValImp* FKW->FKW_PERC)/100   //Aplica proporcionalidade da natureza de rendimento no valor do imposto

				//Tratamento de base não retida (suspensa) para a baixa
				nBasNRet := nCoef * FKW->FKW_BASENR
				nImpNRet := nCoef * FKW->FKW_VLIMPN
				cCodProc := FKW->FKW_NUMPRO
				cTpProc  := FKW->FKW_TPPROC
				cIndSusp := FKW->FKW_CODSUS

				//Grava dados no array que ira alimentar a tabela FKY
				aAdd(aDadosFKY,{cFilFKY, cIdDoc, cTabOri, cIdOrig, cTpImp, cNatRen, nBasFKW, nImpFKW, nBasNRet, nImpNRet, cCodProc, cTpProc, cIndSusp })					
				
				FKW->(dbSkip())
			EndDo
		Endif
	Else
		For nX := 1 to Len(aRatIRPF)
			If FKW->(DBSeek(xFilial("FKW") + cIdDoc + cTpImp+aRatIRPF[nX][1]))
				While !FKW->(Eof()) .And. FKW->FKW_IDDOC+Alltrim(FKW->FKW_TPIMP)+Alltrim(FKW->FKW_CGC) == cIdDoc+AllTrim(cTpImp)+Alltrim(aRatIRPF[nX][1])
					cNatRen   := FKW->FKW_NATREN

					If Empty(aRatIRPF[nX][4])
						cTabOri := "FKW"
						cIdOrig := FKW->FKW_IDFKW
					Else
						cTabOri := aRatIRPF[nX][5]
						cIdOrig := aRatIRPF[nX][4]
					Endif
				
					//Tratamento na base do imposto para considerar a proporcionalidade
					nBasFKW  := GetBaseNat(cTpImp, cIdDoc, cNatRen) //Aplica coeficiente da baixa
					nBasFKW  := nBasFKW*(aRatIRPF[nX][2]/100) * nCoef //Aplica proporcionalidade da natureza de rendimento na base de calculo
					nTotNat  := GetPercNat(cTpImp, cIdDoc,cNatRen) //Verifica base real do imposto quando origem de nota fiscal
					nImpFKW  := aRatIRPF[nX][3]*(nTotNat/100) //Aplica proporcionalidade da natureza de rendimento no valor do imposto

					//Grava dados no array que ira alimentar a tabela FKY
					aAdd(aDadosFKY,{cFilFKY, cIdDoc, cTabOri, cIdOrig, cTpImp, cNatRen, nBasFKW, nImpFKW, nBasNRet, nImpNRet, cCodProc, cTpProc, cIndSusp })					
					
					FKW->(dbSkip())
				EndDo
			EndIf
		Next nX
	EndIf


	RestArea(aArea)
	FwFreeArray(aArea)

Return aDadosFKY

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}FinGrvFKY
Grava os impostos retidos na baixa a pagar proporcionalizados por
Natureza de Rendimento na tabela FKY (REINF - Bloco 40).

@param cId       - ID da FK2 (FK2_IDFK2)
@param oSubFKY   - Submodelo da FKY
@param aDadosFKY - Dados a serem gravados na tabela FKY

@author Fabio Casagrande Lima
@since  25/07/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Function FinGrvFKY(cIdFk2, oSubFKY, aDadosFKY)

	Local nX As Numeric
	Local nY As Numeric

	Default cIdFk2    	  := ""
	Default oSubFKY   := nil
	Default aDadosFKY := {}

	For nX := 1 To Len(aDadosFKY)
		If Len(aDadosFKY[nX]) > 0
			If nX > 1
				oSubFKY:AddLine()
			Endif
			For nY := 1 To Len(aDadosFKY[nX]) //Localizar se encontra casos que a proporcionalizacao esteja menos de 100%, pois possuira mais de uma posicao no array.
				If nY > 1
					oSubFKY:AddLine()
				Endif	
				oSubFKY:SetValue( "FKY_FILIAL",	aDadosFKY[nX][nY][1] )
				oSubFKY:SetValue( "FKY_IDFKY" ,	FWUUIDV4()		     )				
				oSubFKY:SetValue( "FKY_IDDOC" ,	aDadosFKY[nX][nY][2] )
				oSubFKY:SetValue( "FKY_IDFK2" ,	cIdFk2 				 )
				oSubFKY:SetValue( "FKY_TABORI",	aDadosFKY[nX][nY][3] )				
				oSubFKY:SetValue( "FKY_IDORIG",	aDadosFKY[nX][nY][4] )
				oSubFKY:SetValue( "FKY_TPIMP" ,	aDadosFKY[nX][nY][5] )
				oSubFKY:SetValue( "FKY_NATREN",	aDadosFKY[nX][nY][6] )
				oSubFKY:SetValue( "FKY_BASETR",	aDadosFKY[nX][nY][7] )
				oSubFKY:SetValue( "FKY_VLIMP" ,	aDadosFKY[nX][nY][8] )
				oSubFKY:SetValue( "FKY_BASENR",	aDadosFKY[nX][nY][9] )
				oSubFKY:SetValue( "FKY_VLIMPN",	aDadosFKY[nX][nY][10] )
				oSubFKY:SetValue( "FKY_NUMPRO",	aDadosFKY[nX][nY][11] )
				oSubFKY:SetValue( "FKY_TPPROC",	aDadosFKY[nX][nY][12] )
				oSubFKY:SetValue( "FKY_CODSUS",	aDadosFKY[nX][nY][13] )

			Next nY
		Endif
	Next nX

	//Limpa valores da memoria.
	aSize(aDadosFKY, 0)

Return

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}FinDelFKY
Exclui dados na tabela FKY - Proporcionalização dos impostos retidos na baixa a pagar por 
Natureza de Rendimento (REINF - Bloco 40)

@param cIdFK2 - ID da FK2 (FK2_IDFK2)

@author Fabio Casagrande Lima
@since  26/07/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Function FinDelFKY(cIdFk2) 

	Local aArea		As Array
	Local cAliasQry As Character

	Default cIdFk2 := ""

	aArea := GetArea()

	If !Empty(cIdFk2)

		cAliasQry := GetNextAlias()

		cQuery 	:= " SELECT R_E_C_N_O_ RECNOFKY FROM "+RetSqlName("FKY")+" WHERE "
		cQuery 	+= " FKY_FILIAL = '"+xFilial("FKY")+"' AND FKY_IDFK2 = '" + cIdFK2 + "' AND "
		cQuery 	+= " D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		(cAliasQry)->(dbGoTop())
		While !( cAliasQRY )->( Eof())
			dbSelectArea("FKY")
			FKY->(dbGoTo(( cAliasQRY )->RECNOFKY ) )
			Reclock("FKY",.F.)
			FKY->(DbDelete())
			FKY->(MsUnlock())
			(cAliasQry)->(dbSkip())
		Enddo
		(cAliasQry)->(dbCloseArea())

	Endif

	RestArea(aArea)

Return

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}GetFkyNr
Verifica o total de base não retida de um titulo na tabela FKY (REINF - Bloco 40).

@param cIdDoc - ID da FK7
@param cTpImp - Tipo do Imposto (IR/PIS/COF/CSL)

@author Fabio Casagrande Lima
@since  15/08/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Static Function GetFkyNr(cIdDoc, cTpImp)

	Local cAliasQry As Character
	Local nTotal    As Numeric

	Default cIdDoc := ""
	Default cTpImp := ""

	cAliasQry := GetNextAlias()
	nTotal    := 0

	cQuery 	:= "SELECT FKY_BASENR VALOR"
	cQuery  += "FROM "+RetSqlName("FKY")+" WHERE "
	cQuery 	+= "FKY_FILIAL = '"+xFilial("FKY")+"' AND FKY_IDDOC = '"+cIdDoc+"' AND FKY_TPIMP = '"+cTpImp+"' AND "
	cQuery 	+= "D_E_L_E_T_ = '  ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	(cAliasQry)->(dbGoTop())
	While !( cAliasQRY )->( Eof())
		nTotal += ( cAliasQRY )->VALOR
		(cAliasQry)->(dbSkip())
	Enddo
	(cAliasQry)->(dbCloseArea())

Return nTotal
//--------------------------------------------------------------------
/*/{Protheus.doc}GetBaseFKW
Retorna o valor da base de calculo do titulo presente na tabela FKW
(REINF - Bloco 40).

@param cTpImp - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdDoc - Id do titulo (ID FK7)


@author Fabio Casagrande Lima
@since  25/09/2019
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetBaseFKW(cTpImp, cIdDoc)
		
	Local cTblTmp As Character 
	Local nRet    As Numeric
	Local cQuery  As Character 

	Default cTpImp := ""
	Default cIdDoc := ""

	cTblTmp := ""
	nRet    := 0
	cQuery  := ""

	If __oQryFKW == Nil
		cQuery := "SELECT SUM(FKW_BASETR) BASETR FROM "+RetSqlName("FKW")
		cQuery += "WHERE FKW_FILIAL = ? AND "
		cQuery += "FKW_IDDOC = ? AND FKW_TPIMP = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		__oQryFKW := FWPreparedStatement():New(cQuery)
	EndIf
	
	__oQryFKW:SetString(1, xFilial("FKW"))
	__oQryFKW:SetString(2, cIdDoc)
	__oQryFKW:SetString(3, cTpImp)
	
	cQuery  := __oQryFKW:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)
	If (cTblTmp)->(!Eof())
		nRet := (cTblTmp)->BASETR
	Endif
	(cTblTmp)->(dbCloseArea())
	
Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc}GetBasNR
Retorna o valor da base quando o imposto esta totalmente nao retido
devido a uma suspencao judicial (REINF - Bloco 40).

@param cIdDoc    - Id do titulo (ID FK7)
@param cTpImp    - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param nValBx    - Valor da baixa
@param nTotImpBx - Valor total de todos os impostos com fato gerador na baixa do titulo
@param nTotTit   - Valor total do titulo

@author Fabio Casagrande Lima
@since  03/10/2019
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetBasNR(cIdDoc As Character, cTpImp As Character, nValBx As Numeric, nTotImpBx As Numeric, nTotTit As Numeric)
		
	Local lVlBxLiq   As Logical
	Local lVlBxAlt   As Logical
	Local nRet       As Numeric
	Local nTotBasFKY As Numeric

	Default cIdDoc    := ""
	Default cTpImp	  := ""
	Default nValBx    := 0
	Default nTotImpBx := 0
	Default nTotTit   := 0

	lVlBxAlt := .F.
	nRet	 := 0

	If FindFunction("F080RAltBx") .and. FindFunction("F450RAltBx") 
		If FwIsInCallStack("FINA080")
			lVlBxAlt := F080RAltBx()
		EndIf
		If FwIsInCallStack("FINA450")
			lVlBxAlt := F450RAltBx()
		EndIf
	EndIf
	
	If lVlBxAlt //Trata valor da baixa alterado manualmente no FINA080/FINA450
		lVlBxLiq   := SuperGetMv("MV_BP10925",.F., "1") == "2" // 1-Bruto / 2- Liquido
		If lVlBxLiq
			nRet := nValBx + nTotImpBx
		Endif
	Elseif FwIsInCallStack("FINA340") .and. FindFunction("F340VlComp")
		nRet       := F340VlComp() //base do imposto do valor compensado
	Else
		//Tratamento para pegar o valor correto da base da ultima baixa, quando MV_BP10925 = '1' e ha retencao de impostos 
		nTotBasFKY := GetFkyNr(cIdDoc, cTpImp) //Verifica total de base nao retida já gravada na FKY
		nRet       := nTotTit - nTotBasFKY
	Endif

Return nRet


//--------------------------------------------------------------------
/*/{Protheus.doc}GetPercNat
Retorna percentual total da natureza de rendimento, independente do CPF

@param cTpImp - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdDoc - Id do titulo (ID FK7)
@param cNatRen - Natureza de rendimento

@author Pâmela Bernardo de Souza
@since  13/01/2023
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetPercNat(cTpImp, cIdDoc, cNatRen)
		
	Local cTblTmp As Character 
	Local nRet    As Numeric
	Local cQuery  As Character 

	Default cTpImp := ""
	Default cIdDoc := ""
	Default cNatRen := ""

	cTblTmp := ""
	nRet    := 0
	cQuery  := ""

	If __oQryPerN == Nil
		cQuery := "SELECT SUM(FKW_PERC) PERC FROM "+RetSqlName("FKW")
		cQuery += "WHERE FKW_FILIAL = ? AND "
		cQuery += "FKW_IDDOC = ? AND FKW_TPIMP = ? AND "
		cQuery += "FKW_NATREN = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		__oQryPerN := FWPreparedStatement():New(cQuery)
	EndIf
	
	__oQryPerN:SetString(1, xFilial("FKW"))
	__oQryPerN:SetString(2, cIdDoc)
	__oQryPerN:SetString(3, cTpImp)
	__oQryPerN:SetString(4, cNatRen)
	
	cQuery  := __oQryPerN:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)
	If (cTblTmp)->(!Eof())
		nRet := (cTblTmp)->PERC
	Endif
	(cTblTmp)->(dbCloseArea())
	
Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc}GetBaseNat
Retorna base total da natureza de rendimento, independente do CPF

@param cTpImp - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdDoc - Id do titulo (ID FK7)
@param cNatRen - Natureza de rendimento

@author Pâmela Bernardo de Souza
@since  13/01/2023
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetBaseNat(cTpImp, cIdDoc, cNatRen)
		
	Local cTblTmp As Character 
	Local nRet    As Numeric
	Local cQuery  As Character 

	Default cTpImp := ""
	Default cIdDoc := ""
	Default cNatRen := ""

	cTblTmp := ""
	nRet    := 0
	cQuery  := ""

	If __oQryBase == Nil
		cQuery := "SELECT SUM(FKW_BASETR) BASETR FROM "+RetSqlName("FKW")
		cQuery += "WHERE FKW_FILIAL = ? AND "
		cQuery += "FKW_IDDOC = ? AND FKW_TPIMP = ? AND "
		cQuery += "FKW_NATREN = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		__oQryBase := FWPreparedStatement():New(cQuery)
	EndIf
	
	__oQryBase:SetString(1, xFilial("FKW"))
	__oQryBase:SetString(2, cIdDoc)
	__oQryBase:SetString(3, cTpImp)
	__oQryBase:SetString(4, cNatRen)
	
	cQuery  := __oQryBase:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)
	If (cTblTmp)->(!Eof())
		nRet := (cTblTmp)->BASETR
	Endif
	(cTblTmp)->(dbCloseArea())
	
Return nRet

