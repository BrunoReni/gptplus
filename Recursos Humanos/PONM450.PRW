#INCLUDE "TOTVS.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "PONM450.CH"

/*/{Protheus.doc} PONM450
Gera o arquivo AEJ de acordo com a portaria 671/2021
@type  Function
@author C�cero Alves
@since 23/08/2022
/*/
Function PONM450()
	
	Local aArea			:= GetArea()
	Local cDescricao 	:= STR0001 // "Essa rotina realiza a Gera��o do Arquivo Eletr�nico de Jornada - AEJ, seguindo o leiaute e defini��es da portaria 671/2021"
	Local cBkpFil		:= cFilAnt
	
	Private lBlind 		:= IsBlind()
	Private aLogTitle	:= {}
	Private aLogAEJ 	:= {{}}
	Private nTipo01		:= 0
	Private nTipo03		:= 0
	Private nTipo05		:= 0
	Private nTipo06		:= 0
	Private nTipo07		:= 0
	Private oTmpAEJ
	
	If !fExistPerg("PONM450")
		//"Funcionalidade n�o dispon�vel para esta vers�o do sistema."
		Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0003}) // "Para utilizar a rotina de gera��o do arquivo AEJ � necess�rio atualizar o sistema."
		Return
	EndIf
	
	Pergunte("PONM450", .F.)
	
	If !lBlind
		tNewProcess():New( "PONM450", STR0004, {|oSelf| PNM450Proc(oSelf) }, cDescricao, "PONM450",,,,,,.T.) // "Gera��o do arquivo AEJ"
	Else
		PNM450Proc()
	EndIf
	
	MsAguarde({|| fMakeLog( aLogAEJ, aLogTitle, "PONM450", , "PONM450", STR0005 )}, STR0005) // "Ocorr�ncias na gera��o do arquivo AEJ"
	
	cFilAnt := cBkpFil
	
	RestArea(aArea)
	
	If oTmpAEJ <> Nil
		oTmpAEJ:Delete()
		Freeobj(oTmpAEJ)
    EndIf
	
Return

/*/{Protheus.doc} PNM450Proc
Busca as informa��es e gera o arquivo de texto
@type  Static Function
@author C�cero Alves
@since 23/08/2022
@param oProcess, Objeto, inst�ncia da classe tNewProcess
/*/
Static Function PNM450Proc(oProcess)
	
	Local cAcessaSRA	:= fSFiltrSQL(ChkRH("PONM450", "SRA", "2"))
	Local cQrySRA 		:= GetNextAlias()
	Local cLastFil		:= "*"
	Local cLastCPF		:= "*"
	Local cLastCod		:= ""
	Local cWhere		:= ""
	Local aInfo			:= {}
	Local LGeraFil		:= .F.
	Local l1Vinculo		:= .T.
	Local nRegua		:= 0
	
	Private dPerIni		:= cToD("//")
	Private dPerFim		:= cToD("//")
	Private dDataIni	:= MV_PAR08
	Private dDataFim	:= MV_PAR09
	Private aHorarios	:= {}
	Private aRelogios	:= {}
	Private aFiliais	:= {}
	
	dbSelectArea("SRA")
	
	MV_PAR06	:= fSqlIn(StrTran(MV_PAR06, '*'), 1)
	MV_PAR07	:= fSqlIn(StrTran(MV_PAR07, '*'), 1)
	
	MakeSqlExp("PONM450")
	
	cWhere := "RA_ADMISSA <= '" + dToS(dDataFim) + "' " 
	cWhere += "AND ( RA_DEMISSA = '        ' OR RA_DEMISSA > '" + dToS(dDataIni) + "' )"
	
	cWhere += If(!Empty(MV_PAR01), " AND " + MV_PAR01, "") 						// Filiais
	cWhere += If(!Empty(MV_PAR02), " AND " + MV_PAR02, "") 						// Centros de Custo
	cWhere += If(!Empty(MV_PAR03), " AND " + MV_PAR03, "")						// Turnos
	cWhere += If(!Empty(MV_PAR04), " AND " + MV_PAR04, "") 						// Matr�culas
	cWhere += If(!Empty(MV_PAR05), " AND " + MV_PAR05, "") 						// Regras de Apontamento
	cWhere += If(!Empty(MV_PAR06), " AND RA_SITFOLH IN (" + MV_PAR06 + ")", "") // Situa��es
	cWhere += If(!Empty(MV_PAR07), " AND RA_CATFUNC IN (" + MV_PAR07 + ")", "") // Categorias
	
	// Controle de Acesso
	cWhere += If(!Empty(cAcessaSRA) .And. cAcessaSRA != ".T.", " AND " + cAcessaSRA, "")
	cWhere := "%" + cWhere + "%"
	
	If !lBlind
		// Query para a r�gua de processamento
		BeginSQL ALIAS cQrySRA
			SELECT COUNT(RA_MAT) AS FUNCIONARIOS
			FROM %Table:SRA% SRA
			WHERE %Exp:cWhere%
			AND SRA.%NotDel%
		EndSQL
		
		nRegua := (cQrySRA)->FUNCIONARIOS
		(cQrySRA)->(dbCloseArea())
		oProcess:SetRegua1(nRegua)
	EndIf
	
	BeginSQL ALIAS cQrySRA
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_NOMECMP, RA_CIC, RA_CODUNIC, R_E_C_N_O_ AS RECNO
		FROM %Table:SRA% SRA
		WHERE %Exp:cWhere%
		AND SRA.%NotDel%
		ORDER BY SRA.RA_CIC
	EndSQL
	
	While (cQrySRA)->(!EoF())
		
		If !lBlind
			oProcess:IncRegua1("Processando funcion�rio " + (cQrySRA)->RA_MAT )
		EndIf
		
		// Adiciona no Log os funcion�rios com CPF em branco
		If (cQrySRA)->(Empty(RA_CIC))
			If(Empty(aLogTitle))
				Aadd(aLogTitle, STR0006) // "Funcion�rios n�o enviados"
			EndIf
			Aadd(aLogAEJ[1], (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT + ": " + STR0007) // "CPF inv�lido."
			(cQrySRA)->(dbSkip())
			LOOP
		EndIf
		
		// Verifica se Houve Troca de Filial
		If !((cQrySRA)->RA_FILIAL == cLastFil)
			
			cLastFil := (cQrySRA)->RA_FILIAL
			cFilAnt := cLastFil
			
			If (nPosFil := aScan(aFiliais, {|x| x == (cQrySRA)->RA_FILIAL})) > 0
				nTipo01 := nPosFil
			Else
				nTipo01 := Len(aFiliais) + 1
				LGeraFil := .T.
			EndIf
			
			// Obtem as datas do Periodo em Aberto
			GetPonMesDat( @dPerIni, @dPerFim, cLastFil )
			
		EndIf
		
		nTipo03++ // Controla a quantidade de funcion�rios enviados
		
		//Posiciona no Funcion�rio
		SRA->(dbGoTo((cQrySRA)->RECNO))
		
		// Gera as informa��es sobre hor�rios, REPs e marca��es. Tipos 02, 04, 05 e 07 (DSR)
		If !GeraMarc()
			If(Empty(aLogTitle))
				Aadd(aLogTitle, STR0006) //"Funcion�rios n�o enviados"
			EndIf
			Aadd(aLogAEJ[1], (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT + ": " + STR0008) // "Funcion�rio sem marca��es."
			(cQrySRA)->(dbSkip())
			nTipo03-- // Controle da quantidade de funcion�rios enviados
			LOOP
		EndIf
		
		//Gera o cabe�alho apenas quando o funcion�rio tem informa��es
		If LGeraFil
			// Busca as informa��es do cadastro de empresas
			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)
			
			// Grava as informa��es do cabe�alho na tabela tempor�ria
			Tipo01(aInfo)
			
			aAdd(aFiliais, (cQrySRA)->RA_FILIAL)
			LGeraFil := .F.
		EndIf
		
		// Grava as informa��es do V�nculo do funcion�rio
		(cQrySRA)->(Tipo03(RA_CIC, If(!Empty(RA_NOMECMP), RA_NOMECMP, RA_NOME)))
		
		// Tratamento para funcion�rios com m�ltiplos v�nculos
		If (cQrySRA)->RA_CIC == CLastCPF
			// Grava informa��es do v�nculo no eSocial (Funcion�rio anterior)
			If l1Vinculo
				Tipo06(CLastCod, .T.)
			EndIf
			// Grava informa��es do v�nculo no eSocial (Funcion�rio Atual)
			Tipo06((cQrySRA)->RA_CODUNIC, .F.)
			l1Vinculo := .F.
		Else
			l1Vinculo := .T.
		EndIf
		
		CLastCPF := (cQrySRA)->RA_CIC
		CLastCod := (cQrySRA)->RA_CODUNIC
		
		// Gera informa��es sobre os apontamentos. Tipo 07
		GeraApo()
		
		(cQrySRA)->(dbSkip())
		
	EndDo
	
	(cQrySRA)->(dbCloseArea())
	
	// Grava as informa��es do programa
	Tipo8()
	
	// Grava o Trailer do arquivo
	Tipo99()
	
	// Gera as informa��es da assinatura eletr�nica
	Assina()
	
	// Grera o arquivo de texto
	GeraArq()
	
Return 

/*/{Protheus.doc} GeraMarc
Gera as informa��es sobre hor�rios, REPs e marca��es. Tipos 02, 04, 05 e 07 (DSR)
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@return lRet, L�gico, Verdadeiro quando o funcion�rio possui marca��es no per�odo selecionado
/*/
Static Function GeraMarc()
	
	Local aPeriodos 	:= {}
	Local aTabCalend 	:= {} 
	Local aTurnos		:= {}
	Local aMarcacoes	:= {}
	Local aTabPadrao	:= {}
	Local lRet			:= .F.
	Local nMarcacoes	:= 0
	Local nI			:= 0
	
	aPeriodos := Monta_per( dDataIni, dDataFim, SRA->RA_FILIAL, SRA->RA_MAT, dPerIni, dPerFim )
	
	For nI := 1 To Len(aPeriodos)
		
		aTabCalend 	:= {}
		aTurnos		:= {}
		aMarcacoes	:= {}
		aTabPadrao	:= {}
		
		GetMarc(@aMarcacoes, SRA->RA_FILIAL, SRA->RA_MAT, aPeriodos[nI, 1], aPeriodos[nI, 2])
		
		If !CriaCalend(	aPeriodos[nI, 1] 	,;	//01 -> Data Inicial do Periodo
		   			   	aPeriodos[nI, 2]	,;	//02 -> Data Final do Periodo
				   		SRA->RA_TNOTRAB		,;	//03 -> Turno Para a Montagem do Calendario
				   		SRA->RA_SEQTURN		,;	//04 -> Sequencia Inicial para a Montagem Calendario
				   		@aTabPadrao			,;	//05 -> Array Tabela de Horario Padrao
				   		@aTabCalend			,;	//06 -> Array com o Calendario de Marcacoes
				   		SRA->RA_FILIAL     	,;	//07 -> Filial para a Montagem da Tabela de Horario
				   		SRA->RA_MAT   		,;	//08 -> Matricula para a Montagem da Tabela de Horario
				   		SRA->RA_CC   		,;	//09 -> Centro de Custo para a Montagem da Tabela
				   		@aTurnos			,;	//10 -> Array com as Trocas de Turno
						NIL					,;	//11 -> Array com Todas as Excecoes do Periodo
						NIL					,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
						.T.					,;	//13 -> Se executa a funcao se sincronismo do calendario
						NIL			 		;	//14 -> Se Forca a Criacao de Novo Calendario
					)
			
			If(Empty(aLogTitle))
				Aadd(aLogTitle, STR0006) // "Funcion�rios n�o enviados"
			EndIf
			Aadd(aLogAEJ[1], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + STR0009) // "N�o foi poss�vel criar o calend�rio para o funcion�rio."
			LOOP
		EndIf
		
		// Marca��es
		If !Tipo05(aMarcacoes, aTabCalend, @nMarcacoes)
			LOOP
		EndIf
		
		// Gera a movimenta��o de DSR. Tipo 07
		GeraDSR(aTabCalend, aMarcacoes)
		
	Next nI
	
	If nMarcacoes > 0
		nTipo05 += nMarcacoes
		lRet := .T.
	EndIf
	
Return lRet

/*/{Protheus.doc} GeraApo
Busca os apontamentos gravados nas tabelas de pr�-ACJEF e acumulado de ACJEF
@type  Static Function
@author C�cero Alves
@since 26/08/2022
/*/
Static Function GeraApo()
	
	Local cAliasRFF	:= GetNextAlias()
	Local cEvDSR	:= PosSP9("002A", SRA->RA_FILIAL, "P9_CODIGO", 2) // Desconsidera o evento de DRS se houver
	
	BeginSQL ALIAS cAliasRFF
		COLUMN RFF_DATA AS DATE
		SELECT RFF_DATA, RFF_PD, RFF_TIPO, RFF_QUANTC, RFF_SINAL
		FROM %Table:RFF% RFF
		WHERE RFF_FILIAL = %Exp:SRA->RA_FILIAL% AND 
		RFF_MAT = %Exp:SRA->RA_MAT% AND
		RFF_DATA >= %Exp:dToS(dDataIni)% AND
		RFF_DATA <= %Exp:dToS(dDataFim)% AND
		RFF_PD != %Exp:cEvDSR% AND
		( RFF_TIPO = '2' OR 
		RFF_PD IN (
			SELECT P9_CODIGO 
			FROM %Table:SP9% SP9 
			WHERE P9_FILIAL = %Exp:xFilial("SP9", SRA->RA_FILIAL)% AND 
			P9_CLASEV = '02' AND
			SP9.%NotDel% ) ) AND
		RFF.%NotDel%
		UNION ALL
		SELECT RFG_DATA, RFG_PD, RFG_TIPO, RFG_QUANTC, RFG_SINAL
		FROM %Table:RFG% RFG
		WHERE RFG_FILIAL = %Exp:SRA->RA_FILIAL% AND
		RFG_MAT = %Exp:SRA->RA_MAT% AND 
		RFG_DATA >= %Exp:dToS(dDataIni)% AND
		RFG_DATA <= %Exp:dToS(dDataFim)% AND
		RFG_PD != %Exp:cEvDSR% AND
		( RFG_TIPO = '2' OR 
		RFG_PD IN (
			SELECT P9_CODIGO 
			FROM %Table:SP9% SP9 
			WHERE P9_FILIAL = %Exp:xFilial("SP9", SRA->RA_FILIAL)% AND 
			P9_CLASEV = '02' AND
			SP9.%NotDel% ) ) AND
		RFG.%NotDel%
	EndSQL
	
	While (cAliasRFF)->(!EoF())
		
		If (cAliasRFF)->RFF_TIPO == 2 // Movimenta��o de banco de horas
			(cAliasRFF)->(Tipo07(RFF_DATA, RFF_QUANTC, RFF_SINAL, "3"))
		Else
			// Faltas
			(cAliasRFF)->(Tipo07(RFF_DATA, If(RFF_QUANTC > 1, RFF_QUANTC, NIL),, "2"))
		EndIf
		
		(cAliasRFF)->(dbSkip())
	EndDo
	
	(cAliasRFF)->(dbCloseArea())
	
Return

/*/{Protheus.doc} Tipo01
Grava as informa��es do cabe�alho na tabela tempor�ria
@type  Static Function
@author C�cero Alves
@since 24/08/2022
@param aInfo, Array, Informa��es do cadastro de empesas
/*/
Static Function Tipo01(aInfo)
	
	Local cTipoReg	:= "01"
	Local cVersao	:= "001"
	Local cRazaoS	:= ""
	Local cTipoInsc	:= ""
	Local cCPFCNPJ	:= ""
	Local cTexto	:= ""
	Local cDataIni	:= Transforma(dDataIni)
	Local cDataFim	:= Transforma(dDataFim)
	Local cDataGera	:= FWTimeStamp(5)
	Local cChave	:= StrZero(nTipo01, 6)
	
	// Remove os �ltimos : para ficar de acordo com o leiaute do governo
	cDataGera := Left(cDataGera, 22) + Right(cDataGera, 2)
	
	//TODO Ter� tratamento para CEI?
	
	// Tipo de inscri��o da empresa "1" = CNPJ, "2" = CPF, "3" = CEI
	cTipoInsc := If(aInfo[15] == 1, "3", If(aInfo[15] == 3, "2", "1"))
	
	cCPFCNPJ := AllTrim(aInfo[8])
	
	//TODO buscar CAEPF
	cCAEPF := ""
	
	//TODO buscar CNO
	cCNO := ""
	
	cRazaoS := FSubst(AllTrim(aInfo[3]))
	
	//Monta a linha do Registro do tipo 01 - Cabe�alho
	cTexto += cTipoReg 	+ "|" 	// Tipo de registro
	cTexto += cTipoInsc + "|" 	// Tipo de identificador do empregador
	cTexto += cCPFCNPJ 	+ "|" 	// CNPJ ou CPF do empregador
	cTexto += cCAEPF 	+ "|" 	// CAEPF
	cTexto += cCNO 		+ "|" 	// CNO
	cTexto += cRazaoS 	+ "|" 	// Raz�o Social ou nome do empregador
	cTexto += cDataIni 	+ "|" 	// Data Inicial
	cTexto += cDataFim 	+ "|" 	// Data Final
	cTexto += cDataGera	+ "|" 	// Data e Hora da Gera��o
	cTexto += cVersao	+ CRLF	// Vers�o do Leiaute
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
Return

/*/{Protheus.doc} Tipo02
Busca as informa��es do REP e grava na tabela tempor�ria
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param cFilSP0, Caractere, Filial do cadastro de rel�gios
@param cCodRel, Caractere, C�digo do rel�gio
@param cCCTREP, Caractere, C�digo do da CCT vinculada a marca��o
@return cIdREP, Caractere, Identificador do REP no AEJ
/*/
Static Function Tipo02(cFilSP0, cCodRel, cCCTREP)
	
	Local aArea		:= GetArea()
	Local cTipoReg	:= "02"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIdREP	:= ""
	Local cTipoREP	:= "1"
	Local cNumREP	:= ""
	Local cTexto	:= ""
	Local lTipoREP	:= SP0->(ColumnPos("P0_TPREP"))
	
	DEFAULT cCCTREP := ""
	
	DbSelectArea("SP0")
	DbSetOrder(1)
	
	If Empty(cCCTREP)
		
		If SP0->(dbSeek(cFilSP0 + cCodRel))
			
			If lTipoREP .And. SP0->P0_TPREP $ "2*4"
				cTipoREP := If(SP0->P0_TPREP == "4", "3", SP0->P0_TPREP)
			EndIf
			
			If cTipoREP == "1"
				cNumREP := AllTrim(SP0->P0_REP)
			ElseIf cTipoREP == "2"
				cNumREP := Replicate("9", 17)
			EndIf
			
		EndIf
	Else
		// Rel�gio do Clock in
		cNumREP := cCCTREP
		cTipoREP := "2"
	EndIf
	
	// Adiciona no array aRelogios para controle de duplicidade
	aAdd(aRelogios, {cNumREP, SP0->P0_FILIAL + cCodRel})
	
	cIdREP := cValToChar(Len(aRelogios))
	
	cTexto := cTipoReg	+ "|"
	cTexto += cIdREP	+ "|"
	cTexto += cTipoREP	+ "|"
	cTexto += cNumREP	+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
	RestArea(aArea)
	
Return cIdREP

/*/{Protheus.doc} Tipo03
Grava as informa��es do V�nculo do funcion�rio
@type  Static Function
@author C�cero Alves
@since 24/08/2022
@param cCPF, Caractere, CPF do funcion�rio
@param cNome, Caractere, Nome do Funcion�rio
/*/
Static Function Tipo03(cCPF, cNome)
	
	Local cTipoReg	:= "03"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIDVinc	:= CValToChar(nTipo03)
	Local cTexto	:= ""
	
	cCPF := AllTrim(cCPF)
	cNome := AllTrim(cNome)
	
	cTexto += cTipoReg	+ "|"
	cTexto += cIDVinc	+ "|"
	cTexto += cCPF		+ "|"
	cTexto += cNome		+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
Return

/*/{Protheus.doc} Tipo04
Grava o hor�rio contratual na tabela tempor�ria
@type  Static Function
@author user
@since 26/08/2022
@version version
@param aHDia, Array, Hor�rios de entrada e sa�da progrmados para o dia
@param nJornada, param_type, Dura��o da jornada de trabalho em horas
@return cIDJorn, Caractere, C�digo do hor�rio contratual no AEJ
/*/
Static Function Tipo04(aHDia, nJornada)
	
	Local cTipoReg	:= "04"
	Local cChave	:= StrZero(nTipo01, 6)
	Local nI		:= 0
	Local cIDJorn	:= ""
	Local cDuracao	:= CValToChar(__Hrs2Min(nJornada))
	Local cTexto	:= ""
	
	// Adiciona no array aHorarios para controle de duplicidade
	aAdd(aHorarios, aHDia)
	
	cIDJorn := CValToChar(Len(aHorarios))
	
	cTexto += cTipoReg	+ "|"
	cTexto += cIDJorn	+ "|"
	cTexto += cDuracao	+ "|"
	
	For nI := 1 To Len(aHDia)
		cTexto += aHDia[nI]	+ "|"
	Next nI
	
	cTexto := Left(cTexto, Len(cTexto) - 1) // Retira a �ltima /
	cTexto += CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
Return cIDJorn

/*/{Protheus.doc} Tipo05
Grava as marca��es realizadas pelo funcion�rio no per�odo na tabela tempor�ria
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param aMarcacoes, Array, Marca��es do funcion�rio, incluindo as marca��es desconsideradas
@param aTabCalend, Array, Calend�rio do ponto
@param nMarcacoes, Num�rico, Vari�vel para controle do total de registros do tipo 05 foram gerados no arquivo
@return lRet, L�gico, Indica se o funcion�rio tem alguma marca��o no per�odo selecionado
/*/
Static Function Tipo05(aMarcacoes, aTabCalend, nMarcacoes)
	
	Local cTipoReg		:= "05"
	Local cChave		:= StrZero(nTipo01, 6)
	Local cIDVinc		:= CValToChar(nTipo03) // C�digo do funcion�rio no arquivo
	Local cHorario		:= ""
	Local cSeqMarc		:= ""
	Local cDHMarc		:= ""
	Local cHoraMarc		:= ""
	Local cTipoMarc		:= ""
	Local cMotivo		:= ""
	Local cLastOrder	:= ""
	Local cOrigem		:= ""
	Local cIdREP		:= ""
	Local cTexto		:= ""
	Local lRet			:= .F.
	Local nMarcPer		:= 0
	Local nI 			:= 0
	
	For nI := 1 To Len(aMarcacoes)
		
		// Consiste as datas, pois s�o carregadas as marca��es do per�odo de apontamento inteiro
		If aMarcacoes[nI][AMARC_DATA] < dDataIni .Or. aMarcacoes[nI][AMARC_DATA] > dDataFim
			LOOP
		EndIf
		
		cHoraMarc := StrTran(StrZero(aMarcacoes[nI][AMARC_HORA], 5, 2), ".", ":") + ":00" // Adiciona os segundos como 00
		
		cDHMarc := FWTimeStamp(5, aMarcacoes[nI][AMARC_DATA], cHoraMarc) 
		
		// Remove os �ltimos : para ficar de acordo com o leiaute do governo
		cDHMarc := Left(cDHMarc, 22) + Right(cDHMarc, 2)
		
		If !Empty(aMarcacoes[nI][AMARC_RELOGIO])
			cIdREP := GetIdREP(aMarcacoes[nI][AMARC_FILORG], aMarcacoes[nI][AMARC_RELOGIO], If(!Empty(aMarcacoes[nI][AMARC_CCTREP]),  aMarcacoes[nI][AMARC_CCTREP],  aMarcacoes[nI][AMARC_NUMREP]))
		Else
			cIdREP := ""
		EndIf
		
		If aMarcacoes[nI][AMARC_TPMCREP] == "D" // Marca��o desconsiderada
			cTipoMarc := "D"
			cSeqMarc := ""
		Else
			cTipoMarc := Right(aMarcacoes[nI][AMARC_TIPOMARC], 1)
			cSeqMarc := StrZero(Val(Left(aMarcacoes[nI][AMARC_TIPOMARC], 1)), 3)
		EndIf
		
		cOrigem := aMarcacoes[nI][AMARC_TIPOREG]
		
		If cOrigem == "I" .Or. cTipoMarc == "D"
			cMotivo := AllTrim(aMarcacoes[nI][AMARC_MOTIVRG])
		Else 
			cMotivo := ""
		EndIf
		
		If !Empty(aMarcacoes[nI][AMARC_ORDEM]) .And. aMarcacoes[nI][AMARC_ORDEM] != cLastOrder
			cHorario := GetHorario(aTabCalend, aMarcacoes[nI][AMARC_ORDEM])
			cLastOrder := aMarcacoes[nI][AMARC_ORDEM]
		EndIf
		
		cTexto := cTipoReg	+ "|"
		cTexto += cIDVinc	+ "|"
		cTexto += cDHMarc	+ "|"
		cTexto += cIdREP	+ "|"
		cTexto += cTipoMarc	+ "|"
		cTexto += cSeqMarc	+ "|"
		cTexto += cOrigem	+ "|"
		cTexto += cHorario	+ "|"
		cTexto += cMotivo	+ CRLF
		
		GravaAEJ(cTipoReg, cChave, cTexto)
		nMarcPer++
		
	Next nI
	
	If nMarcPer > 0
		lRet := .T.
		nMarcacoes += nMarcPer
	EndIf
	
Return lRet

/*/{Protheus.doc} Tipo06
Identifica��o da matr�cula do v�nculo no eSocial, para empregados com m�ltiplos v�nculos
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param cCodUnico, Caractere, Matr�cula do funcion�rio no eSocial
@param lAnterior, L�gico, Indica se a gera��o � referente ao funcion�rio anterior
/*/
Static Function Tipo06(cCodUnico, lAnterior)
	
	Local cTipoReg	:= "06"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIDVinc	:= If(lAnterior, CValToChar(nTipo03 - 1), CValToChar(nTipo03))
	Local cTexto	:= ""
	
	cTexto += cTipoReg	+ "|"
	cTexto += cIDVinc	+ "|"
	cTexto += cCodUnico	+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	nTipo06++
	
Return

/*/{Protheus.doc} Tipo07
Aus�ncias e Banco de Horas
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param dData, Data, Data da ocorr�ncia
@param nHoras, Num�rico, Dura��o do evento em horas
@param cSinal, Caractere, Define se o evento � de provento ou desconto quando referente a movimenta��o do banco de horas
@param cTipo, cTipo, Tipo da movimenta��o. "1": DSR; "2": Falta; "3": movimento no banco de horas
/*/
Static Function Tipo07(dData, nHoras, cSinal, cTipo)
	
	Local cTipoReg	:= "07"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIDVinc	:= CValToChar(nTipo03)
	Local cTexto	:= ""
	Local cData		:= Transforma(dData)
	Local cMinutos	:= ""
	
	DEFAULT cSinal := ""
	DEFAULT nHoras := 0
	
	cMinutos := If(nHoras > 0, CValToChar(__Hrs2Min(nHoras)), "")
	
	cTexto := cTipoReg	+ "|"
	cTexto += cIDVinc	+ "|"
	cTexto += cTipo		+ "|"
	cTexto += cData		+ "|"
	cTexto += cMinutos	+ "|"
	cTexto += cSinal	+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	nTipo07++
	
Return

/*/{Protheus.doc} Tipo8
Identifica��o do Programa de Tratamento de Registro de Ponto
@type  Static Function
@author C�cero Alves
@since 26/08/2022
/*/
Static Function Tipo8()
	
	Local cTipoReg	:= "08"
	Local cVersao	:= GetRPORelease()
	Local cPrograma	:= "ERP TOTVS Protheus"
	Local cTipoInsc	:= "1" // CNPJ
	Local cCNPJ		:= "53113791000122"
	Local cRazaoS	:= "TOTVS S.A."
	Local cEmail	:= "MSIGA@MICROSIGA.COM.BR"
	Local cTexto	:= ""
	
	If Len(cVersao) > 8
		cVersao := StrTran(cVersao, ".1", "")
	EndIf
	
	cTexto += cTipoReg	+ "|"
	cTexto += cPrograma	+ "|"
	cTexto += cVersao	+ "|"
	cTexto += cTipoInsc	+ "|"
	cTexto += cCNPJ		+ "|"
	cTexto += cRazaoS	+ "|"
	cTexto += cEmail	+ CRLF
	
	GravaAEJ(cTipoReg, "999999", cTexto)
	
Return

/*/{Protheus.doc} Tipo99
Trailer com o resumo do arquivo
@type  Static Function
@author C�cero Alves
@since 26/08/2022
/*/
Static Function Tipo99()
	
	Local cTipoReg	:= "99"
	Local cTexto	:= ""
	Local cQnt01	:= cValToChar(nTipo01)
	Local cQnt02	:= cValToChar(Len(aRelogios))
	Local cQnt03	:= cValToChar(nTipo03)
	Local cQnt04	:= cValToChar(Len(aHorarios))
	Local cQnt05	:= cValToChar(nTipo05)
	Local cQnt06	:= cValToChar(nTipo06)
	Local cQnt07	:= cValToChar(nTipo07)
	Local cQnt08	:= "1" // Sempre 1
	
	cTexto := cTipoReg	+ "|"
	cTexto += cQnt01	+ "|"
	cTexto += cQnt02	+ "|"
	cTexto += cQnt03	+ "|"
	cTexto += cQnt04	+ "|"
	cTexto += cQnt05	+ "|"
	cTexto += cQnt06	+ "|"
	cTexto += cQnt07	+ "|"
	cTexto += cQnt08	+ CRLF
	
	GravaAEJ(cTipoReg, "999999", cTexto)
	
Return

/*/{Protheus.doc} Assina()
Grava a informa��o sobre a assinatura eletr�nica na tabela tempor�ria
@type  Static Function
@author C�cero Alves
@since 26/08/2022
/*/
Static Function Assina()
	Local cAssinatura := "ASSINATURA_DIGITAL_EM_ARQUIVO_P7S" // Texto leteral do leiaute
	
	cAssinatura := cAssinatura + Space(100 - Len(cAssinatura)) + CRLF
	
	GravaAEJ("ZZ", "999999", cAssinatura)
	
Return

/*/{Protheus.doc} Pn450Cria()
Cria a tabela tempor�ria que armazenar� os dados antes de gravar no arquivo de texto
@type  Static Function
@author C�cero Alves
@since 24/08/2022
/*/
Static Function Pn450Cria()
	
	Local aStruct	:= {}
	Local aIndices	:= {}
	
	Static cAliasAEJ := GetNextAlias()
	
	Aadd(aStruct, {"TIPO" , "C",   2, 0})
	Aadd(aStruct, {"CHAVE", "C",   6, 0})
	Aadd(aStruct, {"TEXTO", "C", 255, 0})
	
	Aadd(aIndices, {"CHAVE", "TIPO"})
	
	oTmpAEJ := RhCriaTrab(cAliasAEJ, aStruct, aIndices)
	
Return

/*/{Protheus.doc} GravaAEJ
Realiza a grava��o das informa��es na tabela tempor�ria
@type  Static Function
@author C�cero Alves
@since 24/08/2022
@param cTipoReg, Caractere, Tipo do registro de acordo com o leiaute. Usado para ordena��o
@param cChave, Caractere, Chave da filial atual. Usado para ordena��o
@param cTexto, Caractere, Texto da linha do arquivo
/*/
Static Function GravaAEJ(cTipoReg, cChave, cTexto)
	
	If oTmpAEJ == NIL
		Pn450Cria()
	EndIf
	
	(cAliasAEJ)->(RecLock(cAliasAEJ, .T. ))
		(cAliasAEJ)->TIPO := cTipoReg
		(cAliasAEJ)->CHAVE := cChave
		(cAliasAEJ)->TEXTO := cTexto
	(cAliasAEJ)->(MsUnlock())
	
Return

/*/{Protheus.doc} GeraArq
Gera o arquivo de texto com as informa��es gravadas na tabela tempor�ria
@type  Static Function
@author C�cero Alves
@since 24/08/2022
/*/
Static Function GeraArq()
	
	Local cLocFile 	:= Alltrim(MV_PAR10)
	Local cFile		:= ""
	Local cArqtmp	:= GetNextAlias()
	Local nHandle	:= 0
	
	cFile := Upper(GetPvProfString( GetEnvServer(), "StartPath", "", GetAdv97()))
	cFile := AllTrim(cFile + cArqtmp)
	
	nHandle := MsFCreate(cFile)
	
	(cAliasAEJ)->(dbGoTop())
	
	While (cAliasAEJ)->(!EoF())
		FWrite(nHandle, RTrim((cAliasAEJ)->TEXTO))
		(cAliasAEJ)->(!dbSkip())
	EndDo
	
	fClose(nHandle)
	__CopyFile(cFile, cLocFile)
	fErase(cFile)
	
Return

/*/{Protheus.doc} Transforma
Formata uma data para "AAAA-MM-dd"
@type Static Function
@author C�cero Alves
@since 26/08/2022
@param dData, Data, Data que ser� formatada
@return cRet, Caractere, Data com o formato "AAAA-MM-dd"
/*/
Static Function Transforma(dData)
Return (Right(Str(Year(dData)), 4) + "-" + StrZero(Month(dData), 2) + "-" + StrZero(Day(dData), 2))

/*/{Protheus.doc} Monta_Per
Monta os per�odos de apontamento de acordo com as datas passadas
@type Function
@author C�cero Alves
@since 26/08/2022
@param dDataIni, Data, Data inicial solicitada
@param dDataFim, Data, Data final solicitada
@param cFil, Caractere, Filial do funcion�rio
@param cMat, Caractere, Matr�cula do funcion�rio
@param dIniAtu, Data, Data inicial do per�odo de apontamento atual
@param dFimAtu, Data, Data final do per�odo de apontamento atual
@return aPeriodos, Array, Per�odos de apontamento compreendidos entre as datas solicitadas
/*/
Function Monta_Per( dDataIni, dDataFim, cFil, cMat, dIniAtu, dFimAtu )
	
	Local aPeriodos := {}
	Local cFilSPO	:= xFilial("SPO", cFil)
	Local dAdmissa	:= SRA->RA_ADMISSA
	Local dPerIni   := CToD("//")
	Local dPerFim   := CToD("//")
	Local dData		:= CToD("//")
	
	SPO->(dbSetOrder( 1 ))
	SPO->(dbSeek(cFilSPO, .F.))
	
	While SPO->( !Eof() .And. PO_FILIAL == cFilSPO )
		
		dPerIni := SPO->PO_DATAINI
		dPerFim := SPO->PO_DATAFIM  
		
		//-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
		If dPerFim < dDataIni .Or. dPerIni > dDataFim
			SPO->(dbSkip())
			LOOP
		EndIf
		
    	//-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
		If dPerFim >= dAdmissa
			aAdd(aPeriodos, {dPerIni, dPerFim, Max(dPerIni, dDataIni), Min(dPerFim, dDataFim)})
		Else
			SPO->(dbSkip())
			LOOP
		EndIF
		
		SPO->(dbSkip())
		
	EndDo
	
	If aScan( aPeriodos, {|x| x[1] == dIniAtu .And. x[2] == dFimAtu }) == 0
		dPerIni := dIniAtu
		dPerFim	:= dFimAtu 
		If !(dPerFim < dDataIni .Or. dPerIni > dDataFim)
			If dPerFim >= dAdmissa
				aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni, dDataIni), Min(dPerFim, dDataFim)})
			EndIf
		EndIf
	EndIF
	
	If !Empty(aPeriodos)
		dData	:= aPeriodos[ Len(aPeriodos), 2 ] + 1
		dPerIni	:= aPeriodos[ Len(aPeriodos), 1 ]
		dPerFim	:= aPeriodos[ Len(aPeriodos), 2 ]
	Else
		dData	:= dDataIni
		dPerIni	:= dIniAtu
		dPerFim	:= dFimAtu
	endif
	
	//Inclui periodos futuros se estiverem compreendidos pelo periodo solicitado
	If dData > dFimAtu 
		While .T.
			PerAponta(@dPerIni, @dPerFim, dData, Nil, Nil, .T., Nil, Nil, .T.)
			
			// Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
			If dPerFim >= dAdmissa .And. !(dPerFim < dDataIni .Or. dPerIni > dDataFim)
				Aadd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni, dDataIni), Min(dPerFim, dDataFim)})
			EndIf
			
			If dDataFim > dPerFim
				dData := dPerFim + 1
			Else
				EXIT
			EndIf
			
		EndDo
	EndIf
	
Return aPeriodos

/*/{Protheus.doc} GetIdREP
Retorna o Identificador do REP no AEJ
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param cFilOrigem, Caractere, Filial para busca no cadastro de rel�gios
@param cCodRel, Caractere, C�digo do rel�gio para busca no cadastro de rel�gios
@param cNumREP, Caractere, N�mero do REP ou CCT vinculada a marca��o
@return cIdREP, Caractere, dentificador do REP no AEJ
/*/
Static Function GetIdREP(cFilOrigem, cCodRel, cNumREP)
	
	Local cIdREP 	:= ""
	Local nPos		:= 0
	
	If !Empty(cNumREP)
		nPos := aScan(aRelogios, {|x| x[1] == cNumREP})
	Else
		nPos := aScan(aRelogios, {|x| x[2] == xFilial("SP0", cFilOrigem) + cCodRel})
	EndIf
	
	If nPos > 0
		cIdREP := cValToChar(nPos)
	Else
		cIdREP := Tipo02(cFilOrigem, cCodRel, cNumREP)
	EndIf
	
Return cIdREP

/*/{Protheus.doc} GetHorario
Retorna o Identificador do hor�rio no AEJ
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param aTabCalend, Array, Calend�rio do ponto
@param cOrdem, Caractere, Ordem do dia dentro do calend�rio
@return cHorario, Caractere, Identificador do hor�rio no AEJ
/*/
Static Function GetHorario(aTabCalend, cOrdem)
	
	Local cHorario	:= ""
	Local nI		:= AScan(aTabCalend, {|x| x[CALEND_POS_ORDEM] == cOrdem})
	Local nHrTrab	:= 0
	Local nPosH		:= 0
	Local aAux		:= {}
	
	While nI > 0 .And. nI <= Len(aTabCalend) .And. aTabCalend[nI][CALEND_POS_ORDEM] == cOrdem
		Aadd(aAux, StrTran(StrZero(aTabCalend[nI][CALEND_POS_HORA], 5, 2), "."))
		nHrTrab += aTabCalend[nI][CALEND_POS_HRS_TRABA]
		nI++
	EndDo
	
	If (nPosH := Ascan(aHorarios, {|x| ArrayCompare( aAux, x)})) > 0
		cHorario := CValToChar(nPosH)
	ElseIf nHrTrab > 0
		cHorario := Tipo04(aAux, nHrTrab)
	EndIf
	
Return cHorario

/*/{Protheus.doc} GeraDSR
Gera os dias de DSR com base no calend�rio e nas marca��es realizadas
@type  Static Function
@author C�cero Alves
@since 26/08/2022
@param aTabCalend, Array, Calend�rio do ponto
@param aMarcacoes, Array, Marca��es do funcion�rio no per�odo
/*/
Static Function GeraDSR(aTabCalend, aMarcacoes)
	
	Local nI
	Local cLastOrder := ""
	
	For nI := 1 To Len(aTabCalend)
		// O dia � um DSR e n�o houve marca��es
		If aTabCalend[nI][CALEND_POS_TIPO_DIA] == "D" .And. aTabCalend[nI][CALEND_POS_ORDEM] != cLastOrder
			// Consiste as datas, pois � carregado o per�odo inteiro
			If aTabCalend[nI][CALEND_POS_DATA] < dDataIni .Or. aTabCalend[nI][CALEND_POS_DATA] > dDataFim
				LOOP
			EndIf
			
			If AScan(aMarcacoes, {|x| x[AMARC_ORDEM] == aTabCalend[nI][CALEND_POS_ORDEM]}) == 0
				Tipo07(aTabCalend[nI][CALEND_POS_DATA],,, "1")
			EndIf
			cLastOrder := aTabCalend[nI][CALEND_POS_ORDEM]
		EndIf
	Next nI
	
Return 

/*/{Protheus.doc} fExistPerg
Verifica se o grupo de perguntas existe no ambiente
@type static function
@author C�cero Alves
@since 26/08/2022
@param cPergunte, Caractere, C�digo do grupo de perguntas
@return lRet, L�gico, Indica se o grupo de perguntas existe ou n�o
/*/
Function fExistPerg(cPergunte)
	
	Local lRet	:= .F.
	Local oSX1	:= FWSX1Util():New()
	
	oSX1:AddGroup(cPergunte)
	oSX1:SearchGroup()
	
	If !Empty(oSX1:aGrupo[1, 2])
		lRet:= .T.
	EndIf
	
	FreeObj(oSX1)
	
Return lRet

/*/{Protheus.doc} fGetAEJ
Abre a interface para a sele��o do diret�rio de gera��o doarquivo
@type  Function
@author C�cero Alves
@since 30/08/2022
@return lRet, L�gico, Retorna falso quando o caminho estiver em branco
/*/
Function fGetAEJ()
	
	Local mvRet := Alltrim(ReadVar())
	
	oWnd := GetWndDefault()
	
	cFile := MV_PAR10
	
	If Empty(cFile)
		cFile := cGetFile(, OemToAnsi(STR0010))  //"Selecione Arquivo"
	EndIf
	
	If Empty(cFile)
		Return .F.
	EndIf
	
	&mvRet := cFile
	
	If oWnd != Nil
		GetdRefresh()
	EndIf
	
Return .T.


/*/{Protheus.doc} GetMarc
Busca as marca��es do per�odo informado nas tabelas SP8 e SPG
@type  Static Function
@author C�cero Alves
@since 14/03/2023
@param aMarcacoes, Array, Array onde ser�o carregadas as marca��es - Deve ser passado por refer�ncia
@param cFilFunc, Caractere, Filial do funcion�rio
@param cMatFunc, Caractere, Matr�cula do funcion�rio
@param dDataIni, Data, Data inicial para busca das marca��es
@param dDataFim, Data, Data final para busca das marca��es
/*/
Static Function GetMarc(aMarcacoes, cFilFunc, cMatFunc, dDataIni, dDataFim)
	
	Local cAliasMarc	:= GetNextAlias()
	Local lFuso671		:= SP8->(ColumnPos("P8_FUSO")) > 0
	Local lCCTREP		:= SP8->(ColumnPos("P8_CCTREP")) > 0
	Local cCposP8		:= ""
	Local cCposPG		:= ""
	
	Default aMarcacoes := {} 
	Default cFilFunc := "" 
	Default cMatFunc := ""
	Default dDataIni := cToD("")
	Default dDataFim := cToD("")
	
	cCposP8 += If(lFuso671, ", P8_FUSO", "")
	cCposP8 += If(lCCTREP, ", P8_CCTREP", "")
	cCposP8 := "%" + cCposP8 + "%"
	
	cCposPG += If(lFuso671, ", PG_FUSO", "")
	cCposPG += If(lCCTREP, ", PG_CCTREP", "")
	cCposPG := "%" + cCposPG + "%"
	
	BeginSQL ALIAS cAliasMarc
		COLUMN P8_DATA AS DATE
		SELECT P8_FILIAL, P8_MAT, P8_DATA, P8_HORA, P8_ORDEM, P8_RELOGIO, P8_TPMARCA, P8_NUMREP, P8_TPMCREP, P8_TIPOREG, P8_MOTIVRG, P8_FILORG, R_E_C_N_O_ RECNO %Exp:cCposP8%
		FROM %Table:SP8% SP8 
		WHERE
		P8_FILIAL = %Exp:cFilFunc% AND 
		P8_MAT = %Exp:cMatFunc% AND 
		(P8_DATAAPO BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)% 
		OR (P8_DATAAPO = '        ' AND P8_DATA BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)%))AND 
		SP8.%NotDel%
		UNION 
		SELECT PG_FILIAL, PG_MAT, PG_DATA, PG_HORA, PG_ORDEM, PG_RELOGIO, PG_TPMARCA, PG_NUMREP, PG_TPMCREP, PG_TIPOREG, PG_MOTIVRG, PG_FILORG, R_E_C_N_O_ RECNO %Exp:cCposPG%
		FROM %Table:SPG% SPG 
		WHERE  PG_FILIAL = %Exp:cFilFunc% AND 
		PG_MAT = %Exp:cMatFunc% AND 
		(PG_DATAAPO BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)% 
		OR (PG_DATAAPO = '        ' AND PG_DATA BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)%))AND 
		SPG.%NotDel%
		ORDER BY P8_FILIAL, P8_MAT, P8_DATA, P8_HORA
	EndSQL
	
	While (cAliasMarc)->(!Eof())
		
		aAdd( aMarcacoes, Array(ELEMENTOS_AMARC))
		
		nLenMarc := Len(aMarcacoes)
		aMarcacoes[nLenMarc, AMARC_DATA   	] := (cAliasMarc)->P8_DATA			//01 - Data
		aMarcacoes[nLenMarc, AMARC_HORA   	] := (cAliasMarc)->P8_HORA			//02 - Hora
		aMarcacoes[nLenMarc, AMARC_ORDEM  	] := (cAliasMarc)->P8_ORDEM			//03 - Ordem
		aMarcacoes[nLenMarc, AMARC_RELOGIO	] := (cAliasMarc)->P8_RELOGIO		//11 - Relogio
		aMarcacoes[nLenMarc, AMARC_TIPOMARC	] := (cAliasMarc)->P8_TPMARCA		//12 - Tipo da Marcacao
		aMarcacoes[nLenMarc, AMARC_NUMREP	] := (cAliasMarc)->P8_NUMREP		//26 - Numero do REP
		aMarcacoes[nLenMarc, AMARC_TPMCREP	] := (cAliasMarc)->P8_TPMCREP		//27 - Tipo de Marcacao no REP
		aMarcacoes[nLenMarc, AMARC_TIPOREG	] := (cAliasMarc)->P8_TIPOREG		//28 - Tipo de Registro
		aMarcacoes[nLenMarc, AMARC_MOTIVRG	] := (cAliasMarc)->P8_MOTIVRG		//29 - Motivo da desconsideracao/inclusao
		aMarcacoes[nLenMarc, AMARC_FILORG	] := (cAliasMarc)->P8_FILORG		//32 - Filial Origem da marcacao
		
		If lFuso671
			aMarcacoes[nLenMarc, AMARC_FUSO	] := (cAliasMarc)->P8_FUSO			//41 - Fuso hor�rio da marca��o
		EndIf
		
		If lCCTREP
			aMarcacoes[nLenMarc, AMARC_CCTREP ] := (cAliasMarc)->P8_CCTREP		//42 - C�igo da conven��o coletiva da mar��o
		EndIf
		
		(cAliasMarc)->(dbSkip())
	EndDo
	
	(cAliasMarc)->(dbCloseArea())
	
Return
