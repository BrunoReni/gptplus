#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA203I.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203I
Rotina para calcular o numero da fatura na geracao
e geral

@param cTpNum,    Tipo de fatura:
                   - FT - Fatura
                   - MF - Minuta de Fatura
                   - MP - Minuta de Pre-Fatura
                   - MS - Minuta de S�cio
@param cCodEscr,  C�digo do Escritorio
@param cCodMoeda, C�digo da Moeda da Fatura
@param lHonor,    Possui honorarios?
@param lDesp,     Possui despesas?
@param cMsgProc,  Mensagem para barra de progresso
@param dDtEmiss,  Data de emiss�o da Fatura

@return aNumFat,  aNumFat[1]: .T. ou .F. para o numero da fatura;
                  aNumFat[2]: Fun��o JURA203I ou chave do tipo de numera��o em caso de falha

@author Luciano Pereira dos Santos
@since 14/09/15
/*/
//-------------------------------------------------------------------
Function JURA203I( cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, cMsgProc, dDtEmiss)
Local lMV_JDFTINT := GetMv( "MV_JDFTINT", Nil, .F.                    ) // Diferenciar Numera��o de Faturas Internacionais? - Padr�o .F.
Local lMV_JDFTHON := GetMv( "MV_JDFTHON", Nil, .F.                    ) // Diferenciar Numera��o de Faturas de Honor�rios? - Padr�o .F.
Local lMV_JDFTDES := GetMv( "MV_JDFTDES", Nil, .F.                    ) // Diferenciar Numera��o de Faturas de Despesas? - Padr�o .F.
Local cMV_JMOENAC := GetMv( "MV_JMOENAC", Nil, "01"                   ) // Moeda Nacional
Local cMV_JNFTINT := GetMv( "MV_JNFTINT", Nil, CriaVar("NXA_COD",.F.) ) // Numera��o Diferenciada para Faturas Internacionais
Local cMV_JNFTHON := GetMv( "MV_JNFTHON", Nil, CriaVar("NXA_COD",.F.) ) // Numera��o Diferenciada para Faturas de Honor�rios
Local cMV_JNTDES  := GetMv( "MV_JNTDES" , Nil, CriaVar("NXA_COD",.F.) ) // Numera��o Diferenciada para Faturas de Despesas

Local lFatIntl   := (cCodMoeda <> cMV_JMOENAC)
Local nTamCod    := TamSX3("NXA_COD")[1]
Local cNumFat    := ''
Local cFilFat    := xFilial("NXA")

Local lRegraInt  := .F. //Usa Regra de Fat Internacional
Local lRegraHon  := .F. //Usa Regra de Fat Honorarios
Local lRegraDsp  := .F. //Usa Regra de Fat Despesas

Local lGetNext   := .T.
Local cFlagSXE   := ""
Local aNumFat    := {.T., "JURA203I"}

Local lCode      := .F.

Local cMaxRange  := Replicate("9", nTamCod) // N�mero m�ximo do range da emiss�o de fatura.
Local lLog       := File('numfat.pfs') //Ativa o log atraves da cria��o do arquivo numfat.pfs na pasta system

//Privates utilizadas na rotina J203CriaSXE para inicializacao do controle de numeracao
Private cCodMin  := ""
Private cCodMax  := ""
Private aRegra   := {}

ProcRegua( 0 )
IncProc()
IncProc()
IncProc()
IncProc()
IncProc()

While !(lCode := MayIUseCode("JURA203I"))
	Sleep(1000)
EndDo

cCodMin := ""
cCodMax := ""

If cTpNum == "FT"

	cMV_JNFTINT := IIf(Empty(cMV_JNFTINT), cMV_JNFTINT, StrZero(Val(cMV_JNFTINT), nTamCod))
	cMV_JNFTHON := IIf(Empty(cMV_JNFTHON), cMV_JNFTHON, StrZero(Val(cMV_JNFTHON), nTamCod))
	cMV_JNTDES  := IIf(Empty(cMV_JNTDES) , cMV_JNTDES , StrZero(Val(cMV_JNTDES) , nTamCod))

	lRegraInt := (lMV_JDFTINT .And. !Empty(cMV_JNFTINT))
	lRegraHon := (lMV_JDFTHON .And. !Empty(cMV_JNFTHON))
	lRegraDsp := (lMV_JDFTDES .And. !Empty(cMV_JNTDES ))

	If !lRegraInt .And. !lRegraHon .And. !lRegraDsp // N�o existe numera��o diferenciada

		aRegra    := {.F., .F., .F., .F., cMV_JMOENAC}

		cFlagSXE  := "JURNFT"
		cCodMin   := StrZero(1, nTamCod)
		cCodMax   := Replicate("9", nTamCod)

	ElseIf lRegraInt .And. !lRegraHon .And. !lRegraDsp // Numera��o de faturas internacionais diferente

		aRegra := {.F., .F., lRegraInt, lFatIntl, cMV_JMOENAC}

		If lFatIntl // Internacional
			cFlagSXE  := "JURNFTINT"
			cCodMin   := cMV_JNFTINT
			cCodMax   := Replicate("9", nTamCod)
		Else // Nacional
			cFlagSXE  := "JURNFT"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(cMV_JNFTINT) - 1, nTamCod) 
		EndIf

	ElseIf !lRegraInt .And. !lRegraHon .And. lRegraDsp // Diferen�a na numera��o de faturas de despesas

		aRegra := {lHonor, lDesp, .F., .F., cMV_JMOENAC}

		If lHonor // Honor�rios ou Honor�rios + Despesas
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(cMV_JNTDES) - 1, nTamCod) 
		Else // Despesas
			cFlagSXE  := "JURNFTDES"
			cCodMin   := cMV_JNTDES
			cCodMax   := Replicate("9", nTamCod)
		EndIf

	ElseIf !lRegraInt .And. lRegraHon .And. !lRegraDsp // Diferen�a na numera��o de faturas de honor�rios ou honor�rios e despesas juntos

		aRegra := {lHonor, lDesp, .F., .F., cMV_JMOENAC}

		If lHonor // Honor�rios ou Honor�rios + Despesas
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := cMV_JNFTHON
			cCodMax   := Replicate("9", nTamCod)
		Else // Despesas
			cFlagSXE  := "JURNFTDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(cMV_JNFTHON) - 1, nTamCod) 
		EndIf

	ElseIf !lRegraInt .And. lRegraHon .And. lRegraDsp // Diferen�a na numera��o de faturas de (honor�rios ou honor�rios e despesas juntos) e somente de despesas

		aRegra := {lHonor, lDesp, .F., .F., cMV_JMOENAC}

		If lHonor // Honor�rios ou Honor�rios + Despesas
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := cMV_JNFTHON
			cCodMax   := IIf(cMV_JNTDES > cMV_JNFTHON, StrZero(Val(cMV_JNTDES) - 1, nTamCod), Replicate("9", nTamCod))
		Else // Despesas
			cFlagSXE  := "JURNFTDES"
			cCodMin   := cMV_JNTDES
			cCodMax   := IIf(cMV_JNTDES < cMV_JNFTHON, StrZero(Val(cMV_JNFTHON) - 1, nTamCod), Replicate("9", nTamCod))
		EndIf

	ElseIf  lRegraInt .And. !lRegraHon .And. lRegraDsp // Diferen�a na numera��o de faturas internacionais e de despesas

		aRegra := {lHonor, lDesp, lRegraInt, lFatIntl, cMV_JMOENAC}

		If (!lFatIntl .And. lHonor) // Nacional de Honor�rios ou Honor�rios + Despesas (1�)
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(IIf(cMV_JNTDES < cMV_JNFTINT, cMV_JNTDES, cMV_JNFTINT)) - 1, nTamCod) // Max do menor dos parametros
		EndIf

		If (!lFatIntl .And. !lHonor) // Nacional de Despesas (2�)
			cFlagSXE  := "JURNFTDES"
			cCodMin   := cMV_JNTDES
			cCodMax   := StrZero(Val(IIf(cMV_JNTDES < cMV_JNFTINT, cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNTDES), nTamCod))) - 1, nTamCod) 
		EndIf

		If (lFatIntl .And. lHonor)
			cFlagSXE  := "JURNFTINTHON" // Internacional de Honor�rios ou Honor�rios + Despesas (3�)
			cCodMin   := cMV_JNFTINT
			cCodMax   := StrZero(Val(IIf(cMV_JNTDES < cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNTDES), nTamCod), cMV_JNTDES)) - 1, nTamCod) 
		EndIf

		If (lFatIntl .And. !lHonor) // Internacional de Despesas (4�)
			cFlagSXE  := "JURNFTINTDES"
			cCodMin   := StrZero(Val(cMV_JNFTINT) + Val(cMV_JNTDES), nTamCod)
			cCodMax   := Replicate("9", nTamCod)
		EndIf

	ElseIf lRegraInt .And. lRegraHon .And. !lRegraDsp // Diferen�a na numera��o de faturas internacionais e de honor�rios ou honor�rios e despesas juntos

		aRegra := {lHonor, lDesp, lRegraInt, lFatIntl, cMV_JMOENAC}

		If (!lFatIntl .And. !lHonor) // Nacional de Despesas (1�)
			cFlagSXE  := "JURNFTDES"
			cCodMin   := StrZero(1, nTamCod)
			cCodMax   := StrZero(Val(IIf(cMV_JNFTHON < cMV_JNFTINT, cMV_JNFTHON, cMV_JNFTINT)) - 1, nTamCod) // Max do menor dos parametros
		EndIf

		If (!lFatIntl .And. lHonor) // Nacional de Honor�rios ou Honor�rios + Despesas (2�)
			cFlagSXE  := "JURNFTHONDES"
			cCodMin   := cMV_JNFTHON
			cCodMax   := StrZero(Val(IIf(cMV_JNFTHON < cMV_JNFTINT, cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNFTHON), nTamCod))) - 1, nTamCod)
		EndIf

		If (lFatIntl .And. !lHonor)
			cFlagSXE  := "JURNFTINTDES" // Internacional de Despesas (3�)
			cCodMin   := cMV_JNFTINT
			cCodMax   := StrZero(Val(IIf(cMV_JNFTHON < cMV_JNFTINT, StrZero(Val(cMV_JNFTINT) + Val(cMV_JNFTHON), nTamCod), cMV_JNFTHON)) - 1, nTamCod)
		EndIf

		If (lFatIntl .and. lHonor) // Internacional de Honor�rios ou Honor�rios + Despesas (4�)
		
			cFlagSXE  := "JURNFTINTHON"
			cCodMin   := StrZero(Val(cMV_JNFTINT) + Val(cMV_JNFTHON), nTamCod)
			cCodMax   := Replicate("9", nTamCod)
		EndIf

	ElseIf lRegraInt .And. lRegraHon .And. lRegraDsp // Erro na configura��o dos parametros de numera��o de fatura.

		aNumFat  := {.F., STR0001} // "Erro na configura��o dos parametros de numera��o de fatura. Somente dois parametros de numera��o pode ser habilitados ao mesmo tempo."
		Return aNumFat

	EndIf

	If lLog
		J203ILog('', cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, lFatIntl, cCodMin, cCodMax, cFlagSXE, dDtEmiss)
	EndIf

	While lGetNext

		cNumFat := GetSXENum("NXA", "NXA_COD", cFilFat + cCodEscr + cFlagSXE)

		If (cNumFat > cMaxRange) // Se o n�mero da fatura � maior que o range m�ximo num�rico, ent�o cont�m letras (pode ser uma minuta ou extrapolou a numera��o)
			aNumFat := {.F., I18N(STR0002, {cCodMax, cCodEscr + cFlagSXE})} // "Erro no controle de numera��o da fatura. Verifique o controle de numera��o para chave '#2'."
			Exit
		EndIf

		lGetNext := J203TemNXA(cCodEscr, cNumFat, cTpNum, dDtEmiss, aRegra, cCodMin, cCodMax)

		If lGetNext
			If cNumFat > cCodMax // Valida��o para o limite do intervalo da numera��o de fatura
				aNumFat := {.F., I18N(STR0003, {cCodMax, cCodEscr + cFlagSXE})} // "A numera��o m�xima de #1 foi atingida. Verifique os parametros e o controle de numera��o para chave '#2'."
				Exit
			Else
				ConfirmSX8() //Confirma para n�o deixar no controle de numera��o, n�meros pendentes
			EndIf
		EndIf

	EndDo

	If aNumFat[1]
		aNumFat := {.T., cNumFat}
	EndIf

ElseIf (cTpNum $ "MF|MP|MS") // Numeracao de Minuta de (Pre) Fatura

	// "JURNMF" - "JURNMP" - "JURNMS"

	aRegra   := {.F., .F., .F., .F., cMV_JMOENAC}
	cCodMin  := cTpNum + StrZero(1, nTamCod-Len(cTpNum) )
	cCodMax  := cTpNum + Replicate("9",nTamCod-Len(cTpNum))
	cFlagSXE := "JURN" + cTpNum

	If lLog
		J203ILog('', cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, lFatIntl, cCodMin, cCodMax, cFlagSXE, dDtEmiss)
	EndIf

	While lGetNext

		cNumFat := GetSXENum("NXA", "NXA_COD", cFilFat + cCodEscr + cFlagSXE)

		// Adiciona o prefixo de minuta
		If !(substr(cNumFat,1,2) $ cTpNum)
			cNumFat := cTpNum + StrZero(val(cNumFat), nTamCod-Len(cTpNum) )
		EndIf

		lGetNext := J203TemNXA(cCodEscr, cNumFat, cTpNum, dDtEmiss, aRegra, cCodMin, cCodMax)

		If lGetNext
			ConfirmSX8()
		EndIf
	EndDo

	aNumFat := {.T., cNumFat}

EndIf

If lLog
	J203ILog(cNumFat)
EndIf

Leave1Code("JURA203I")

Return aNumFat

//-------------------------------------------------------------------
/*/{Protheus.doc} J203TemNXA()
Fun��o para verificar se o n�mero de fatura j� esta sendo utilizado no banco,
e se respeita as regras de exce��o de numera��o.

@param     cCodEscr,   C�digo do escrit�rio da Fatura
@param     cNumFat,    C�digo de fatura a ser testado
@param     cTpNum,     Tipo de fatura: Ex: FT -fatura; MF -Minuta de fatura; etc...
@param     dDtEmiss,   Data e emiss�o da fatura
@param     aRegra,     Array com as regras de numera��o de fatura
           - aRegra[1] - .T. se tem honor�rios ou honorarios mais despesas
           - aRegra[2] - .T. se tem somente despesas
           - aRegra[3] - .T. se � fatura internacional
           - aRegra[4] - Moeda Nacional (paramentro MV_JMOENAC)
@param     cCodMin,    Numera��o minima da fatura
@param     cCodMax,    Numera��o maxima da fatura

@return    lRet,   .T. O n�mero de fatura n�o contemplou alguma das regras de numera��o;
                   .F. O numero pode ser utilizado

@author Luciano Pereira dos Santos
@since  11/09/2015
/*/
//-------------------------------------------------------------------
Function J203TemNXA(cCodEscr, cNumFat, cTpNum, dDtEmiss, aRegra, cCodMin, cCodMax)
Local lRet      := .F.
Local cPrefixo  := PadR(SuperGetMV('MV_JPREFAT',,'PFS'), TamSX3('E1_PREFIXO')[1] )
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local cFilSE1   := ""
Local cMoeNac   := ""
Local lFathon   := .F.
Local lFatDes   := .F.
Local lDifInt   := .F.
Local lFatInt   := .F.

Default aRegra  := {}

// Verifica o intervalo de numera��o
lRet := (cNumFat < cCodMin .Or. cNumFat >= cCodMax)

If lRet // O n�mero de fatura sendo menor que o do parametro, a rotina pai testa se maior
	IncProc(STR0010 + cNumFat + " / " + cCodMin ) // "Validando numera��o inicial da fatura: "
EndIf

If !lRet // Verifica se existe fatura emitida com a nuemra��o
	NXA->(dbSetOrder(1))
	lRet := NXA->(dbSeek(xFilial('NXA') + cCodEscr + cNumFat))

	If lRet
		IncProc(I18N(STR0004, {Iif(cTpNum == "FT", STR0008, STR0009), cCodEscr + cNumFat})) // "Localizando um n�mero de #1 v�lido: '#2'" ##fatura ###minuta
	EndIf
EndIf

If cTpNum == "FT"
	If !lRet // Verifica se exite titulo gerados para esse numero de fatura
		cFilSE1 := JurGetDados('NS7', 1, xFilial('NS7') + cCodEscr, 'NS7_CFILIA')
		SE1->(dbSetOrder(1))
		lRet := SE1->(dbSeek(cFilSE1 + cPrefixo + cNumFat))

		If lRet
			IncProc(STR0006 + "'" + cFilSE1 + cPrefixo + cNumFat + "'") // "Localizando um n�mero de t�tulo v�lido: "
		EndIf
	EndIf
EndIf

If !lRet
	cQuery :=      " SELECT A.EXISTE "
	cQuery +=        " FROM ( "
	cQuery +=               " SELECT NXA.NXA_COD EXISTE"
	cQuery +=                 " FROM " + RetSqlName("NXA") + " NXA"
	cQuery +=                " WHERE NXA.NXA_FILIAL = '" + xFilial('NXA') + "'"
	cQuery +=                  " AND NXA.NXA_CESCR = '" + cCodEscr + "'"
	cQuery +=                  " AND NXA.NXA_TIPO = '" + PadR(cTpNum , TamSX3("NXA_TIPO")[1]) + "'"
	cQuery +=                  " AND NXA.NXA_DTEMI < '" + DtoS(dDtEmiss) + "'"
	cQuery +=                  " AND NXA.NXA_COD = '" + cNumFat + "'"
	cQuery +=                  " AND NXA.D_E_L_E_T_ = ' '"

	If cTpNum == "FT"
		// Regra de numera��o
		If !Empty(aRegra)
			lFathon := aRegra[1]
			lFatDes := aRegra[2]
			lDifInt := aRegra[3]
			lFatInt := aRegra[4]
			cMoeNac := aRegra[5]
		EndIf

		// Regra de diferencia��o de numera��o de honorarios e despesas
		If lFathon
			cQuery +=          " AND NXA.NXA_VLFATH > 0" // Honor�rios ou Honor�rios + Despesas
		ElseIf lFatDes
			cQuery +=          " AND NXA.NXA_VLFATD > 0 AND NXA.NXA_VLFATH = 0" // S� Despesas
		EndIf

		// Regra da diferencia��o de Internacional / Nacional
		If lDifInt
			cQuery +=          " AND NXA.NXA_CMOEDA " + Iif(lFatInt,'<>', '=') + " '" + cMoeNac + "'" // Internacional / Nacional
		EndIf

		// Desconsidera as faturas da exce��o de numera��o
		cQuery +=              " AND NOT EXISTS (SELECT 1 "
		cQuery +=                                " FROM " + RetSqlName("NSE") + " NSE "
		cQuery +=                               " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "'"
		cQuery +=                                 " AND NSE.NSE_CESC = NXA.NXA_CESCR "
		cQuery +=                                 " AND NXA.NXA_COD BETWEEN NSE.NSE_NUMINI AND NSE.NSE_NUMFIN "
		cQuery +=                                 " AND NSE.D_E_L_E_T_ = ' ' "
		cQuery +=                             " ) "
		cQuery +=            " UNION ALL "
		cQuery +=           " SELECT NSE_NUMFIN EXISTE "
		cQuery +=             " FROM " + RetSqlName("NSE") + " NSE "
		cQuery +=            " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "'"
		cQuery +=              " AND NSE.NSE_CESC = '" + cCodEscr + "' "
		cQuery +=              " AND '" + cNumFat + "' BETWEEN NSE.NSE_NUMINI AND NSE.NSE_NUMFIN "
		cQuery +=              " AND NSE.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery +=             " ) A "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	lRet := !(cAliasQry)->(Eof())

	(cAliasQry)->(DbCloseArea())

	If lRet
		IncProc(I18N(STR0007, {Iif(cTpNum == "FT", STR0008, STR0009), cCodEscr + cNumFat})) //#"Localizando n�mero de #1 dipon�vel: '#2'"  ##fatura ###minuta
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CriaSXE
Funcao para calculo da numeracao das faturas quando o SXE estiver
zerado

@Param  PARAMIXB      Array com as informa��es da rotina CriaSXE, fonte MATXATU.PRX
         PARAMIXB[1]  Alias da tabela
         PARAMIXB[2]  Campo da tabela para numera��o
         PARAMIXB[3]  Chave do controle de numera��o

@Return cNextNum Proximo Numero de Fatura

@author Daniel Magalhaes
@since 01/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203CriaSXE(ParamIXB)
Local cAlias   := ""
Local cCampo   := ""
Local cChave   := ""

Local cNextNum := Nil

Local cIniNum  := ""
Local cFimNum  := ""

Local cQuery   := ""
Local cFilNXA  := ""
Local cEscrit  := ""

Local lFathon  := .F.
Local lFatDes  := .F.
Local lDifInt  := .F.
Local lFatInt  := .F.

Local cMoeNac  := ""
Local cAliasQr := GetNextAlias()

Default ParamIXB := {}

If Len(ParamIXB) == 0
	Return nil
EndIf

cAlias := ParamIXB[1]
cCampo := ParamIXB[2]
cChave := ParamIXB[3]

SetPrvt("cCodMin")
SetPrvt("cCodMax")
SetPrvt("aRegra" )

If cAlias == "NXA" .And. cCampo == "NXA_COD"

	cFilNXA := xFilial('NXA')
	cEscrit := SubStr(cChave,Len(cFilNXA)+1,TamSX3("NXA_CESCR")[1])

	If "JURNFT" $ cChave //Faturas

		//Variaveis Private da JURA203I
		If ValType(cCodMin) == "C"
			cIniNum := cCodMin
		EndIf

		If ValType(cCodMax) == "C"
			cFimNum := cCodMax
		EndIf
		
		If ValType(aRegra)  == "A"
			lFathon := aRegra[1]
			lFatDes := aRegra[2]
			lDifInt := aRegra[3]
			lFatInt := aRegra[4]
			cMoeNac := aRegra[5]
		EndIf
		
		cQuery := " SELECT MAX(NXA_COD) MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "FT", TamSX3("NXA_TIPO")[1] ) + "' "
		//Intervalo de faturamento
		If !Empty(cIniNum) .And. !Empty(cFimNum)
			cQuery +=   " AND NXA.NXA_COD between '" + cIniNum + "' AND '" + cFimNum + "'"
		EndIf

		//Testa se o m�ximo n�o esta dentro da exce��o de numera��o de fatura
		cQuery +=    " AND NOT EXISTS (SELECT 1 "
		cQuery +=                      " FROM " + RetSqlName("NSE") + " NSE "
		cQuery +=                     " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "'"
		cQuery +=                       " AND NSE.NSE_CESC = NXA.NXA_CESCR "
		cQuery +=                       " AND NXA.NXA_COD BETWEEN NSE.NSE_NUMINI AND NSE.NSE_NUMFIN "
		cQuery +=                       " AND NSE.D_E_L_E_T_ = ' ' "
		cQuery +=                   " ) "

		//Regra de diferencia��o de numera��o de honorarios e despesas
		If lFathon
			cQuery +=   " AND NXA.NXA_VLFATH > 0" //Hon ou Hon+Desp
		ElseIf lFatDes
			cQuery +=   " AND NXA.NXA_VLFATD > 0 AND NXA.NXA_VLFATH = 0" // s� Desp
		EndIf

		// Regra da diferencia��o de Internacional / Nacional
		If lDifInt
			cQuery +=   " AND NXA.NXA_CMOEDA " + Iif(lFatInt,'<>', '=') + " '" + cMoeNac + "'"
		EndIf
		cQuery +=       " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea(.T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T.)

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := Soma1((cAliasQr)->MAX_COD)
		ElseIf !Empty(cIniNum)
			cNextNum := cIniNum
		EndIf

		(cAliasQr)->(DbCloseArea())

	ElseIf "JURNMF" $ cChave //Minuta Fatura

		cQuery := " SELECT MAX(NXA_COD) MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA "
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "MF", TamSX3("NXA_TIPO")[1] ) + "'"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T. )

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := (cAliasQr)->MAX_COD
			cNextNum := '00'+Substr(cNextNum,3) //Retira o prefixo
			cNextNum := Soma1(cNextNum) //Incrementa o numero
		Else
			cNextNum := StrZero( 1, TamSX3("NXA_COD")[1] )
		EndIf

		(cAliasQr)->(DbCloseArea())

	ElseIf "JURNMP" $ cChave //Minuta Pre-Fatura

		cQuery := " SELECT MAX(NXA_COD) as MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "MP", TamSX3("NXA_TIPO")[1] ) + "'"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T. )

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := (cAliasQr)->MAX_COD
			cNextNum := '00'+Substr(cNextNum,3) //Retira o prefixo
			cNextNum := Soma1(cNextNum) //Incrementa o numero
		Else
			cNextNum := StrZero( 1, TamSX3("NXA_COD")[1] )
		EndIf

		(cAliasQr)->(DbCloseArea())

	ElseIf "JURNMS" $ cChave //Minuta S�cio

		cQuery := " SELECT MAX(NXA_COD) as MAX_COD"
		cQuery +=   " FROM " + RetSqlName("NXA") + " NXA"
		cQuery +=  " WHERE NXA.NXA_FILIAL = '" + cFilNXA + "'"
		cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "'"
		cQuery +=    " AND NXA_TIPO = '" + PadR( "MS", TamSX3("NXA_TIPO")[1] ) + "'"
		cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQr, .T., .T. )

		If !Empty((cAliasQr)->MAX_COD)
			cNextNum := (cAliasQr)->MAX_COD
			cNextNum := '00'+Substr(cNextNum,3) //Retira o prefixo
			cNextNum := Soma1(cNextNum) //Incrementa o numero
		Else
			cNextNum := StrZero( 1, TamSX3("NXA_COD")[1] )
		EndIf

		(cAliasQr)->(DbCloseArea())

	EndIf

EndIf

Return cNextNum

//-------------------------------------------------------------------
/*/{Protheus.doc} J203IExcFt
Retorna em um array as exce��es de numera��o cadastradas para o 
escrit�rio

@Param  cCodEscr C�digo de escrit�rio com para numera��o.

@Return aRet  aRet[1] n�mero inicial da exce��o;
              aRet[2] n�mero final da exce��o;

@author  Luciano Pereira dos Santos
@since   10/09/2015
/*/
//-------------------------------------------------------------------
Static Function J203IExcFt(cCodEscr)
Local cQuery := ""
Local aRet   := {}

Default cCodEscr := ""

	cQuery := " SELECT NSE.NSE_NUMINI, NSE.NSE_NUMFIN "
	cQuery +=   " FROM " + RetSqlName("NSE") + " NSE "
	cQuery +=  " WHERE NSE.NSE_FILIAL = '" + xFilial("NSE") + "' "
	cQuery +=    " AND NSE.NSE_CESC = '" + cCodEscr + "' "
	cQuery +=    " AND NSE.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY NSE.NSE_NUMINI "

	aRet := JurSql(cQuery, "*")

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ILog
Rotina para exibir o log de diagn�stico de teste da rotina da J203I

@param cNumFat,   C�digo da Fatura
@param cTpNum,    Tipo de fatura:
                   - FT - Fatura
                   - MF - Minuta de Fatura
                   - MP - Minuta de Pre-Fatura
                   - MS - Minuta de S�cio
@param cCodEscr,  C�digo do Escritorio
@param cCodMoeda, C�digo da Moeda da Fatura
@param lHonor,    Possui honorarios?
@param lDesp,     Possui despesas?
@param lFatIntl,  Indica se � fatura internacional
@param cCodMin,   C�digo m�nimo permitido para emiss�o
@param cCodMax,   C�digo m�ximo permitido para emiss�o
@param cFlagSXE,  Flag usada no controle de numera��o
@param dDtEmiss,  Data de emiss�o da Fatura

@return Nil

@author Luciano Pereira dos Santos
@since  17/09/2015
/*/
//-------------------------------------------------------------------
Static Function J203ILog(cNumFat, cTpNum, cCodEscr, cCodMoeda, lHonor, lDesp, lFatIntl, cCodMin, cCodMax, cFlagSXE, dDtEmiss)
Local cMsgLog := ""
Local lMV_JDFTINT := .F.// Diferenciar Numera��o de Faturas Internacionais? - Padr�o .F.
Local lMV_JDFTHON := .F.// Diferenciar Numera��o de Faturas de Honor�rios? - Padr�o .F.
Local lMV_JDFTDES := .F.// Diferenciar Numera��o de Faturas de Despesas? - Padr�o .F.
Local cMV_JMOENAC := '' // Moeda Nacional
Local cMV_JNFTINT := '' // Numera��o Diferenciada para Faturas Internacionais
Local cMV_JNFTHON := '' // Numera��o Diferenciada para Faturas de Honor�rios
Local cMV_JNTDES  := '' // Numera��o Diferenciada para Faturas de Despesas
Local nTamCod     := 0
Local aRet        := {}
Local nHandle     := 0
Local nExec       := 0

If Empty(cNumFat)
	lMV_JDFTINT := GetMv( "MV_JDFTINT", Nil, .F.                )
	lMV_JDFTHON := GetMv( "MV_JDFTHON", Nil, .F.                )
	lMV_JDFTDES := GetMv( "MV_JDFTDES", Nil, .F.                )
	cMV_JMOENAC := GetMv( "MV_JMOENAC", Nil, "01"               )
	cMV_JNFTINT := GetMv( "MV_JNFTINT", Nil, CriaVar("NXA_COD",.F.) )
	cMV_JNFTHON := GetMv( "MV_JNFTHON", Nil, CriaVar("NXA_COD",.F.) )
	cMV_JNTDES  := GetMv( "MV_JNTDES" , Nil, CriaVar("NXA_COD",.F.) )

	nTamCod :=  TamSX3("NXA_COD")[1]
	If !Empty(cMV_JNFTINT)
		cMV_JNFTINT := StrZero(Val(cMV_JNFTINT),nTamCod)
	EndIf
	If !Empty(cMV_JNFTHON)
		cMV_JNFTHON := StrZero(Val(cMV_JNFTHON),nTamCod)
	EndIf
	If !Empty(cMV_JNTDES)
		cMV_JNTDES  := StrZero(Val(cMV_JNTDES), nTamCod)
	EndIf
	If Empty(cCodMin)
		cCodMin     := StrZero(0, nTamCod)
	EndIf
	aRet    := J203IExcFt(cCodEscr)

	cMsgLog += "========================================"          + CRLF
	cMsgLog += OemToAnsi(STR0011)                                  + CRLF //"Rotina numera��o de fatura JURA203I"
	cMsgLog += OemToAnsi(I18N(STR0012,{AllToChar(Date()),AllToChar(Time())})) + CRLF //"Data: #1  hor�rio: #2"
	cMsgLog += "========================================"          + CRLF
	cMsgLog += OemToAnsi(STR0013)                                  + CRLF //"Parametros de entrada da rotina: "
	cMsgLog += OemToAnsi(STR0031) + AllToChar(dDtEmiss)            + CRLF //"Data de emiss�o      := "
	cMsgLog += OemToAnsi(STR0014) + "'" + cTpNum + "'"             + CRLF //"Tipo de fatura       := "
	cMsgLog += OemToAnsi(STR0015) + "'" + cCodEscr + "'"           + CRLF //"C�digo do Escrit�rio := "
	cMsgLog += OemToAnsi(STR0016) + cCodMoeda                      + CRLF //"Moeda da Fatura      := "
	cMsgLog += OemToAnsi(STR0017) + Iif(lHonor,STR0018,STR0019)    + CRLF //"Tem honor�rios?      := "
	cMsgLog += OemToAnsi(STR0020) + Iif(lDesp,STR0018,STR0019)     + CRLF //"Tem despesas?        := "
	cMsgLog += OemToAnsi(STR0021) + Iif(lFatIntl,STR0018,STR0019)  + CRLF //"� internacional?     := "
	For nExec := 1 To Len(aRet)
		cMsgLog += "----------------------------------------"      + CRLF
		cMsgLog += OemToAnsi(STR0022)                              + CRLF //"Controle de Exce��o de Fatura: "
		cMsgLog += OemToAnsi(STR0023) + aRet[nExec][1]             + CRLF //"Inicio da exce��o    := "
		cMsgLog += OemToAnsi(STR0024) + aRet[nExec][2]             + CRLF //"Final da exce��o     := "
	Next nExec
	cMsgLog += "----------------------------------------"          + CRLF
	cMsgLog += OemToAnsi(STR0025)                                  + CRLF //"Configura��o dos parametros do sistema: "
	cMsgLog += "MV_JDFTINT := " + alltochar(lMV_JDFTINT) + CRLF
	cMsgLog += "MV_JNFTINT := " + cMV_JNFTINT            + CRLF
	cMsgLog += "MV_JDFTHON := " + alltochar(lMV_JDFTHON) + CRLF
	cMsgLog += "MV_JNFTHON := " + cMV_JNFTHON            + CRLF
	cMsgLog += "MV_JDFTDES := " + alltochar(lMV_JDFTDES) + CRLF
	cMsgLog += "MV_JNTDES  := " + cMV_JNTDES             + CRLF
	cMsgLog += "MV_JMOENAC := " + cMV_JMOENAC            + CRLF

	cMsgLog += "----------------------------------------"          + CRLF
	cMsgLog += OemToAnsi(STR0026)                                  + CRLF //"Condi��es para gerar o n�mero: "
	cMsgLog += OemToAnsi(STR0027) + cCodMin                        + CRLF //"Inicio do intervalo := "
	cMsgLog += OemToAnsi(STR0028) + cCodMax                        + CRLF //"Fim do intervalo    := "
	cMsgLog += OemToAnsi(STR0029) + cFlagSXE                       + CRLF //"Chave de controle   := "
Else
	cMsgLog := OemToAnsi(STR0030) + cNumFat                        + CRLF //"N�mero gerado       := "
	cMsgLog += CRLF
EndIf

If (nHandle := FOpen('numfat.pfs', 2 )) > 0
	FSeek(nHandle, 0, 2)
	FWrite(nHandle, cMsgLog)
	Fclose(nHandle)
EndIf

JurLogMsg(cMsgLog)

Return
