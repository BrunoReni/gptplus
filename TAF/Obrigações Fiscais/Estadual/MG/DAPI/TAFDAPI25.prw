#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI25

Rotina de gera��o do Detalhamento Tipo 25 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informa��es da filial em processamento

@Author Rafael V�ltz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI25(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "25"
Local cStrTxt		:= ""
Local nPos			:= 0
Local cPeriodo   := StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0)
Local aDetalh20  := {}
Local lFound      := ""
Private cFilDapi := aFil[1]
Private cUFID    := aFil[7]

Begin Sequence

	cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 		  //Inscri��o Estadual		- M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Refer�ncia
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //M�s Refer�ncia
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final refer�ncia
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial refer�ncia

	/***** DETALHAMENTO TIPO 25 - Incentivo � Cultura ********/
	aDetalhe := GetIncent(aWizard[1][1], aWizard[1][2], cFilDapi, "MG000005")
	nPos := 0

	While nPos < Len(aDetalhe)
		nPos++
		nCont++

		cStrTxt := Left(cStrTxt,25) + PADL(Alltrim(aDetalhe[nPos,1]),13,"0")           	//N�mero do Termo
		cStrTxt := Left(cStrTxt,38) + FormatData(CTOD(aDetalhe[nPos,2]),.F.,5)          //Data Autoriza��o
		cStrTxt := Left(cStrTxt,46) + StrTran(StrZero(aDetalhe[nPos,3], 16, 2),".","")	//Valor Incentivado
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	EndDo

	GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIncent

Fun��o para buscar o n�mero do certificado e data de autoriza��o
dos incentivos fiscais a cultura e ao esporte

@Param dIni	->	Data inicial do per�odo
		dFim	->	Data final do per�odo
		cFil   -> Filial em processamento
		cIncentivo -> C�digo do incentivo a cultura ou ao esporte

@Return aResult -> Array com as informa��es dos incentivos

@Author Rafael V�ltz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GetIncent(dIni, dFim, cFil, cIncentivo)
 	Local cStrQuery 	:= ""
	Local cAliasQry 	:= GetNextAlias()
	Local aResult 	:= 	{}

	 cStrQuery := " SELECT C2X.R_E_C_N_O_ RECORD "
	  cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
	  cStrQuery +=              RetSqlName('C2X') + " C2X "
	  cStrQuery += "  WHERE C2S.C2S_FILIAL                = '" + cFil + "' "
	  cStrQuery +=   "  AND C2S.C2S_DTINI  BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	  cStrQuery +=   "  AND C2S.C2S_TIPAPU = '0'"
	  cStrQuery +=   "  AND C2S.C2S_INDAPU = ' '"
	  cStrQuery +=   "  AND C2S.C2S_FILIAL = C2X.C2X_FILIAL "
	  cStrQuery +=   "  AND C2S.C2S_ID     = C2X.C2X_ID "
	  cStrQuery +=   "  AND C2X.C2X_INFADC = '" + cIncentivo + "'"
	  cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2X.D_E_L_E_T_ = ' '"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasQry,.T.,.T.)

	DbSelectArea("C2X")
	DbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())


	While (cAliasQry)->(!Eof())
		C2X->(dbGoTo((cAliasQry)->RECORD))
		aInfCertif := StrTokArr(C2X->C2X_DSCCOM, " ")

		If Len(aInfCertif) == 2
			aAdd(aResult, {aInfCertif[1], aInfCertif[2], C2X->C2X_VLRINF})
		EndIf

		(cAliasQry)->(DbSkip())
  	EndDo

 	(cAliasQry)->(DbCloseArea())
 	C2X->(DbCloseArea())

Return aResult