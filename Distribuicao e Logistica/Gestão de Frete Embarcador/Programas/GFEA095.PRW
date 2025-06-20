#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA095

Gera��o de Movimentos Cont�beis

@author Israel A. Possoli
@since 28/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA095()
	// Par�metros
	Private cTipoDoct
	Private cFilialIni
	Private cFilialFim
	Private cTranspIni
	Private cTranspFim
	Private cSerieIni
	Private cSerieFim
	Private cNrDocIni
	Private cNrDocFim
	Private dDtEntrIni
	Private dDtEntrFim	
	Private dDtFiscIni
	Private dDtFiscFim	
	Private cNrContrIni
	Private cNrContrFim
	Private dDtImprIni
	Private dDtImprFim
	Private cIntFatFin
	
	Private oProcess := nil
	
	Private GFEResult := GFEViewProc():New()
	
	If !Pergunte("GFEA095")
		Return Nil
	Endif
	GFEResult:EnableLog("gerar_contabilizacao", "Gera��o de Contabiliza��o")		
	GFEResult:GFELog:ShowParameters("GFEA095")
	
	cTipoDoct	:= MV_PAR01
	cFilialIni	:= MV_PAR02
	cFilialFim	:= MV_PAR03
	cTranspIni	:= MV_PAR04
	cTranspFim	:= MV_PAR05
	cSerieIni	:= MV_PAR06
	cSerieFim	:= MV_PAR07
	cNrDocIni	:= MV_PAR08 
	cNrDocFim	:= MV_PAR09
	dDtEntrIni	:= MV_PAR10
	dDtEntrFim	:= MV_PAR11
	dDtFiscIni	:= MV_PAR12
	dDtFiscFim	:= MV_PAR13
	cNrContrIni := MV_PAR14
	cNrContrFim := MV_PAR15
	dDtImprIni	:= MV_PAR16
	dDtImprFim	:= MV_PAR17
	cIntFatFin	:= MV_PAR18
	
	If cIntFatFin == 1 .AND. SuperGetMV('MV_GFEI16',,'1') == "3"
		Help( ,, 'Help',, "Sistema n�o parametrizado para integrar faturas no financeiro." + CHR(13) + CHR(10) + "Verificar o par�metro 'Fatura Financeiro' na aba 'Integra��es ERP' nos par�metros do m�dulo ou deixar o par�metro 'Atualizar Faturas Financeiro' como 'N�o'.", 1, 0 )
		Return .F.
	EndIf
	
	/* Documento de Frete */	
	If cTipoDoct == 1
		ResultAdd("Contabiliza��o por Documento de Frete")
		
		oProcess := MsNewProcess():New({|| ContabDoctoFrete()}, "Contabilizando...", "Buscando documentos...")
		oProcess:Activate()
	EndIf

	/* Fatura */	
	If cTipoDoct == 2
		ResultAdd("Contabiliza��o por Fatura")
		
		oProcess := MsNewProcess():New({|| ContabFatura()}, "Contabilizando...", "Buscando documentos...")
		oProcess:Activate()
	EndIf

	/* Contrato */	
	If cTipoDoct == 3
		ResultAdd("Contabiliza��o por Contrato")
		
		Processa({|| ContabContrato()},"Contabilizando...", "")
	EndIf
	
	GFEResult:Show("Gera��o de Movimentos Cont�beis", "Documentos contabilizados", "Erros", "Ocorreram erros durante o processo, clique no bot�o 'Erros' para mais detalhes.")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ContabDoctoFrete
Contabiliza��o do Documento de Frete

@author Israel A. Possoli
@since 03/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ContabDoctoFrete()
	Local cFilAntOri
	Local aRetRateio
	Local nI
	Local nNovaFatura	 // RecNo da Fatura que ser� adicionada para ser recontabilizada, caso o rateio do DF seja realizado com sucesso
	Local aFaturas  := {} // Armazena as faturas relacionadas ao documento de frete, para regerar o rateio da fatura
	Local nCountGW3 := 0
	Local cAliasGW3 := GetNextAlias()
	Local s_GFE09501	:= ExistBlock("GFE09501")
	
	oProcess:SetRegua1(0)
	oProcess:SetRegua2(0)
	oProcess:IncRegua2("Filtrando documentos de frete")
	
	cQuery := " SELECT GW3.* FROM "+RetSQLName("GW3")+" GW3 WHERE"
	cQuery += " 	GW3.GW3_FILIAL >= '" + cFilialIni       + "' AND GW3.GW3_FILIAL <= '" + cFilialFim       + "' AND "
	cQuery += " 	GW3.GW3_EMISDF >= '" + cTranspIni       + "' AND GW3.GW3_EMISDF <= '" + cTranspFim       + "' AND "
	cQuery += " 	GW3.GW3_SERDF  >= '" + cSerieIni        + "' AND GW3.GW3_SERDF  <= '" + cSerieFim        + "' AND "
	cQuery += " 	GW3.GW3_NRDF   >= '" + cNrDocIni        + "' AND GW3.GW3_NRDF   <= '" + cNrDocFim        + "' AND "
	cQuery += " 	GW3.GW3_DTENT  >= '" + DTOS(dDtEntrIni) + "' AND GW3.GW3_DTENT  <= '" + DTOS(dDtEntrFim) + "' AND "
	cQuery += " 	(GW3.GW3_DTFIS =  '' OR (GW3.GW3_DTFIS  >= '" + DTOS(dDtFiscIni) + "' AND GW3.GW3_DTFIS  <= '" + DTOS(dDtFiscFim) + "')) AND "
	cQuery += " 	(GW3.GW3_SIT   = '3' OR GW3.GW3_SIT   = '4')  AND "
	 If SuperGetMV('MV_DSCTB',,'1') == "2" 
		cQuery += "   GW3_SITFIS NOT IN('2','4','5') AND"
	EndIF
	cQuery += "     GW3.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW3, .F., .T.)
	
	dbSelectArea((cAliasGW3))
	(cAliasGW3)->( dbGoTop() )
	
	cFilAntOri := cFilAnt
	
	If (cAliasGW3)->( Eof() )
		ResultAdd("** Nenhum documento de frete aprovado encontrado para a faixa informada.")
		(cAliasGW3)->( dbCloseArea() )
		Return	
	EndIf
	
	While !(cAliasGW3)->( Eof() )
		nCountGW3++
		(cAliasGW3)->( dbSkip() )
	EndDo
	
	oProcess:IncRegua2("Contabilizando")
	oProcess:SetRegua2(nCountGW3)
	
	(cAliasGW3)->(dbGoTop())
	While !(cAliasGW3)->( Eof() )
		oProcess:IncRegua1("Filial: " + (cAliasGW3)->GW3_FILIAL + ", S�rie: " + AllTrim((cAliasGW3)->GW3_SERDF) + ", N�mero: " + AllTrim((cAliasGW3)->GW3_NRDF))
		// IncProc("Filial: " + (cAliasGW3)->GW3_FILIAL + ", S�rie: " + AllTrim((cAliasGW3)->GW3_SERDF) + ", N�mero: " + AllTrim((cAliasGW3)->GW3_NRDF))
		
		// Verifica se h� fatura vinculada no documento de frete para regerar a contabiliza��o 
		// A fatura deve estar aprovada e deve estar como "N�o enviada" ou "Rejeitada"
		nNovaFatura := 0
		dbSelectArea("GW6")
	    dbSetOrder(1)
		If GW6->( dbSeek((cAliasGW3)->GW3_FILFAT + (cAliasGW3)->GW3_EMIFAT + (cAliasGW3)->GW3_SERFAT + (cAliasGW3)->GW3_NRFAT + (cAliasGW3)->GW3_DTEMFA) )
			// Desconsidera as Faturas que n�o estejam como "N�o Enviada" ou "Rejeitada" no Financeiro
			If GW6->GW6_SITFIN != "1" .AND. GW6->GW6_SITFIN != "3"
				ResultDetail("** Fatura deve estar com a situa��o financeira como 'N�o Enviada' ou 'Rejeitada'")
				ResultDetail("> Filial: " + AllTrim((cAliasGW3)->GW3_FILFAT)  + ", Transp: " + AllTrim((cAliasGW3)->GW3_EMIFAT) + ", S�rie: " + AllTrim((cAliasGW3)->GW3_SERFAT)  + ", Nr Fatura: " + AllTrim((cAliasGW3)->GW3_NRFAT) + CRLF, 2)
				(cAliasGW3)->( dbSkip() )
			    Loop
			EndIF
			
			// Desconsidera as Faturas que n�o estejam aprovadas
			If GW6->GW6_SITAPR != "3" .AND. GW6->GW6_SITAPR != "4"
				(cAliasGW3)->( dbSkip() )
			    Loop
			EndIf
			nNovaFatura := GW6->( RecNo() )
		EndIF
		
		/* Realiza a o rateio do Documento de Frete */
		dbSelectArea("GW3")
		dbSetOrder(1)
		dbSeek((cAliasGW3)->GW3_FILIAL + (cAliasGW3)->GW3_CDESP + (cAliasGW3)->GW3_EMISDF + (cAliasGW3)->GW3_SERDF + (cAliasGW3)->GW3_NRDF + (cAliasGW3)->GW3_DTEMIS)
		cFilAnt := (cAliasGW3)->GW3_FILIAL
		aRetRateio := GFERatDF(.T.,(cAliasGW3)->GW3_CDESP, (cAliasGW3)->GW3_EMISDF, (cAliasGW3)->GW3_SERDF, (cAliasGW3)->GW3_NRDF, STOD((cAliasGW3)->GW3_DTEMIS), oProcess)
		
		If (aRetRateio[1] == .T.)
			If nNovaFatura  > 0
				// Verifica se a fatura j� foi adicionada no Array
				If AScan(aFaturas, nNovaFatura) == 0
					aADD( aFaturas, nNovaFatura )
				EndIf
			EndIf
			
			ResultAdd("> Filial: " + AllTrim((cAliasGW3)->GW3_FILIAL) + ", Transp: " + AllTrim((cAliasGW3)->GW3_EMISDF) + ", S�rie: " + AllTrim((cAliasGW3)->GW3_SERDF) + ", Nr Docto Frete: " + AllTrim((cAliasGW3)->GW3_NRDF))		
		Else
			ResultDetail("** Erro ao refazer o rateio do Documento de Frete:")
			ResultDetail("> Filial: " + AllTrim((cAliasGW3)->GW3_FILIAL) + ", Transp: " + AllTrim((cAliasGW3)->GW3_EMISDF) + ", S�rie: " + AllTrim((cAliasGW3)->GW3_SERDF) + ", Nr Docto Frete: " + AllTrim((cAliasGW3)->GW3_NRDF), 2)
			ResultDetail("> Motivo: " + aRetRateio[2], 2)
			ResultDetail()
		EndIf
		
		// Ponto de entrada que permite a inclus�o de funcionalidades
		// adicionais no processo de contabiliza��o do documento de frete
		If s_GFE09501
			ExecBlock("GFE09501",.F.,.F.)
		EndIf
		
		/*
		If cGFETrace == "1"
			conout("[" + Time() + "] [GFEA095] [DOC.FRETE] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Doc: " + AllTrim((cAliasGW3)->GW3_NRDF) + ", Serie: " + AllTrim((cAliasGW3)->GW3_SERDF) + ", Transportador: " + AllTrim((cAliasGW3)->GW3_EMISDF) +  "] " + cStatusLog)
		EndIf
		*/
		
		(cAliasGW3)->( dbSkip() )
	EndDo
	(cAliasGW3)->( dbCloseArea() )
	
	// Regera a grade de rateio para as faturas dos c�lculos que a grade cont�bil foi refeita
	If Len(aFaturas) > 0
			
		ResultAdd()
		ResultAdd("Faturas que necessitaram ser recontabilizadas:")
				
		oProcess:IncRegua1("Contabilizando faturas")
		oProcess:SetRegua1(Len(aFaturas))
					
		For nI := 1 To Len(aFaturas)
			oProcess:IncRegua1()
			
			dbSelectArea("GW6")
			dbGoTo(aFaturas[nI])
			// IncProc("Filial: " + AllTrim(GW6->GW6_FILIAL) + ", S�rie: " + AllTrim(GW6->GW6_SERFAT) + ", Fatura: " + AllTrim(GW6->GW6_NRFAT))
			ResultAdd("> Filial: " + AllTrim(GW6->GW6_FILIAL)  + ", Transp: " + AllTrim(GW6->GW6_EMIFAT) + ", S�rie: " + AllTrim(GW6->GW6_SERFAT)  + ", Nr Fatura: " + AllTrim(GW6->GW6_NRFAT))
				
			// Elimina os Movimentos Cont�beis
			GFECTBFATD(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
				
			// Cria��o dos movimentos cont�beis
			GFECTBFATC(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS)
			
			/*
			If cGFETrace == "1"
				conout("[" + Time() + "] [GFEA095] [FATURA] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Doc: " + AllTrim(GW6->GW6_NRFAT) + ", Serie: " + AllTrim(GW6->GW6_SERFAT) + ", Transportador: " + AllTrim(GW6->GW6_EMIFAT) +  "] [OK]")
			EndIf
			*/
			
		Next
	EndIf
	cFilAnt := cFilAntOri
		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ContabFatura
Contabiliza��o da Fatura

@author Israel A. Possoli
@since 11/12/12
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ContabFatura()
	Local cFilAntOri	:= cFilAnt
	Local lContDoctFrete
	Local aRetRateio	:= {}
	Local cAliasGW6 	:= GetNextAlias()
	Local lOk			:= .F.
	Local cMsg1 		:= ""
	Local dData			:= Nil
	Local cParData   	:= SuperGetMV('MV_DSDTAP',,'1') // Parametro Int Origem Data de Integra��o
	Local cMV_ERPGFE 	:= SuperGetMV("MV_ERPGFE",,"2")
	Local cMV_DTULFE	:= SuperGetMv("MV_DTULFE",,"20000101")
	Local aIntegr 		:= {}
	Local s_GFE09502	:= ExistBlock("GFE09502")
	
	If Empty(cParData)
		cParData := "1"
	EndIf
	
	oProcess:SetRegua1(0)
	oProcess:IncRegua1("Filtrando faturas")
	
	cQuery := " SELECT GW6.* FROM " + RetSQLName("GW6") + " GW6 WHERE"
	cQuery += " 	GW6.GW6_FILIAL >= '" + cFilialIni       + "' AND GW6.GW6_FILIAL <= '" + cFilialFim       + "' AND "
	cQuery += " 	GW6.GW6_EMIFAT >= '" + cTranspIni       + "' AND GW6.GW6_EMIFAT <= '" + cTranspFim       + "' AND "
	cQuery += " 	GW6.GW6_SERFAT >= '" + cSerieIni        + "' AND GW6.GW6_SERFAT <= '" + cSerieFim        + "' AND "
	cQuery += " 	GW6.GW6_NRFAT  >= '" + cNrDocIni        + "' AND GW6.GW6_NRFAT  <= '" + cNrDocFim        + "' AND "
	cQuery += " 	GW6.GW6_DTEMIS >= '" + DTOS(dDtEntrIni) + "' AND GW6.GW6_DTEMIS <= '" + DTOS(dDtEntrFim) + "' AND "
	cQuery += " 	(GW6.GW6_SITAPR  = '3' OR GW6.GW6_SITAPR  = '4')  AND "
	cQuery += " 	(GW6.GW6_SITFIN  = '1' OR GW6.GW6_SITFIN  = '3')  AND "
	cQuery += "     GW6.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW6, .F., .T.)
	
	dbSelectArea((cAliasGW6))
	(cAliasGW6)->( dbGoTop() )
	
	If (cAliasGW6)->( Eof() )
		ResultAdd("** Nenhuma fatura aprovada que esteja pendente ou rejeitada no financeiro, encontrada para a faixa informada.")
		(cAliasGW6)->( dbCloseArea() )
		Return	
	EndIf
	
	oProcess:SetRegua1(0)
	oProcess:SetRegua2(0)
	
	While !(cAliasGW6)->( Eof() )
		
		dbSelectArea("GW3")
		dbSetOrder(8)
		If dbSeek((cAliasGW6)->GW6_FILIAL + (cAliasGW6)->GW6_EMIFAT + (cAliasGW6)->GW6_SERFAT + (cAliasGW6)->GW6_NRFAT + (cAliasGW6)->GW6_DTEMIS)
			oProcess:IncRegua1("Fatura: " + (cAliasGW6)->GW6_NRFAT + " [Documento de Frete: " + AllTrim(GW3->GW3_NRDF) + "]")
			
			lContDoctFrete := .T.
			While !GW3->( EOF() ) .And. ;
				   GW3->GW3_FILFAT == (cAliasGW6)->GW6_FILIAL .AND. ;
				   GW3->GW3_EMIFAT == (cAliasGW6)->GW6_EMIFAT .AND. ;
				   GW3->GW3_SERFAT == (cAliasGW6)->GW6_SERFAT .AND. ;
				   GW3->GW3_NRFAT  == (cAliasGW6)->GW6_NRFAT  .AND. ;
				   GW3->GW3_DTEMFA == STOD((cAliasGW6)->GW6_DTEMIS) .AND. ;
				   lContDoctFrete
				   
				// Realiza a o rateio do Documento de Frete
				cFilAnt := GW3->GW3_FILIAL
				aRetRateio := GFERatDF(.T., GW3->GW3_CDESP, GW3->GW3_EMISDF, GW3->GW3_SERDF, GW3->GW3_NRDF, GW3->GW3_DTEMIS, oProcess)
				
				If (aRetRateio[1] == .F.)
					lContDoctFrete := .F.
					ResultDetail("** Erro ao contabilizar o Documento de Frete:")
					ResultDetail("> Filial: " + AllTrim(GW3->GW3_FILIAL) + ", Transp: " + AllTrim(GW3->GW3_EMISDF) + ", S�rie: " + AllTrim(GW3->GW3_SERDF) + ", Nr Docto Frete: " + AllTrim(GW3->GW3_NRDF), 2)
					ResultDetail("> Motivo: " + aRetRateio[2], 2)
				EndIf
				
				GW3->( dbSkip() )	   
			EndDo
			
			If lContDoctFrete
				ResultAdd("> Filial: " + (cAliasGW6)->GW6_FILIAL + ", S�rie: " + AllTrim((cAliasGW6)->GW6_SERFAT) + ", Nr Fatura: " + AllTrim((cAliasGW6)->GW6_NRFAT) + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)
				
				// Elimina os Movimentos Cont�beis
				GFECTBFATD((cAliasGW6)->GW6_FILIAL, (cAliasGW6)->GW6_EMIFAT, (cAliasGW6)->GW6_SERFAT, (cAliasGW6)->GW6_NRFAT, STOD((cAliasGW6)->GW6_DTEMIS))
					
				// Cria��o dos movimentos cont�beis
				GFECTBFATC((cAliasGW6)->GW6_FILIAL, (cAliasGW6)->GW6_EMIFAT, (cAliasGW6)->GW6_SERFAT, (cAliasGW6)->GW6_NRFAT, STOD((cAliasGW6)->GW6_DTEMIS))

				// Integra��o autom�tica no financeiro
				If cIntFatFin == 1
					dData 	:= Nil
					lOK 	:= .F.
					cMsg1	:= ""
					
					If s_GFE09502
						aIntegr 	:= ExecBlock("GFE09502",.f.,.f.,{(cAliasGW6)->GW6_FILIAL, (cAliasGW6)->GW6_EMIFAT, (cAliasGW6)->GW6_SERFAT, (cAliasGW6)->GW6_NRFAT, STOD((cAliasGW6)->GW6_DTEMIS)})
						s_GFE09502 	:= aIntegr[1]
						dData 		:= aIntegr[2]
						lOK   		:= aIntegr[3]
						cMsg1 		:= aIntegr[4]						
					EndIf
					If !s_GFE09502
						// Integrar fatura no financeiro
						If cMV_ERPGFE == '2' //quando o ERP for Protheus a data de integra��o/transa��o ser� atribu�da pelo sistema com a data corrente
							dData := DDATABASE
							lOK   := .T.
						Else
							If cParData == "1" .OR. cParData == "3" //Data Corrente ou Informada Usu�rio
								dData := DDATABASE
								lOK   := .T.
							ElseIf cParData == "2" 	// Data Cria��o
								dData := SToD((cAliasGW6)->GW6_DTCRIA)
								lOK   := .T.
							EndIf
						EndIf					
					EndIf
					
					If dData < SToD((cAliasGW6)->GW6_DTEMIS)
						cMsg1 := "** A data de transa��o deve ser maior que a data de emiss�o da fatura. "
						lOk   := .F.
					EndIf  
					
					If lOk .And. dData < cMV_DTULFE
						cMsg1 := "** Data de transa��o deve ser posterior a data do �ltimo fechamento: " + DTOC(cMV_DTULFE)
						lOk   := .F.
					EndIf
					
					If lOk
						// Protheus
						If cMV_ERPGFE == '2'
							aRet := GFEA070In("2", dData)
							
							// Verifica o retorno da integra��o com o Protheus
							If !aRet[1]
								ResultDetail("Fatura n�o foi enviada para atualiza��o no Financeiro por causa do seguinte erro: " + aRet[2][6])
							EndIf
						// Datasul
						Else
							RecLock("GW6", .F.)
								GW6->GW6_SITFIN := "2"
								GW6->GW6_DTFIN  := dData	
								GW6->GW6_HRFIN  := SubStr(Time(), 1, 5)									
							MsUnlock("GW6")
						EndIf 
					ELSE 
						If !Empty(cMsg1)
							ResultDetail("> Filial: " + (cAliasGW6)->GW6_FILIAL + ", S�rie: " + AllTrim((cAliasGW6)->GW6_SERFAT) + ", Nr Fatura: " + AllTrim((cAliasGW6)->GW6_NRFAT) + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)
							ResultDetail("Fatura contabilizada mas n�o integrada no financeiro. Motivo: " + cMsg1, 2)
							ResultDetail()
						EndIf
					Endif
				EndIf
			Else
				ResultDetail("> Filial: " + (cAliasGW6)->GW6_FILIAL + ", S�rie: " + AllTrim((cAliasGW6)->GW6_SERFAT) + ", Nr Fatura: " + AllTrim((cAliasGW6)->GW6_NRFAT) + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)
				ResultDetail("** Fatura n�o contabilizada. Verifique os erros dos documentos de frete acima.", 2)
				ResultDetail()
			EndIf

		Else
			ResultDetail("> Filial: " + (cAliasGW6)->GW6_FILIAL + ", S�rie: " + AllTrim((cAliasGW6)->GW6_SERFAT) + ", Nr Fatura: " + AllTrim((cAliasGW6)->GW6_NRFAT) + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)
			ResultDetail("** Nenhum documento de frete vinculado a fatura.", 2)
			ResultDetail()
		EndIf
				
		
		(cAliasGW6)->( dbSkip() )
	EndDo
	(cAliasGW6)->(dbCloseArea())
	cFilAnt := cFilAntOri
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ContabContrato
Contabiliza��o do Contrato

@author Israel A. Possoli
@since 03/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ContabContrato()
	Local cAliasGW2 := GetNextAlias()
	
	ProcRegua(0)
	
	cQuery := " SELECT GW2.* FROM " + RetSQLName("GW2") + " GW2 WHERE"
	cQuery += " 	GW2.GW2_FILIAL >= '" + cFilialIni       + "' AND GW2.GW2_FILIAL <= '" + cFilialFim       + "' AND "
	cQuery += " 	GW2.GW2_CDPROP >= '" + cTranspIni       + "' AND GW2.GW2_CDPROP <= '" + cTranspFim       + "' AND "
	cQuery += " 	GW2.GW2_NRCONT >= '" + cNrContrIni      + "' AND GW2.GW2_NRCONT <= '" + cNrContrFim      + "' AND "
	cQuery += " 	GW2.GW2_DTIMPR >= '" + DTOS(dDtImprIni) + "' AND GW2.GW2_DTIMPR <= '" + DTOS(dDtImprFim) + "' AND "
	cQuery += "     GW2.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW2, .F., .T.)
	
	dbSelectArea((cAliasGW2))
	(cAliasGW2)->( dbGoTop() )
	
	If (cAliasGW2)->( Eof() )
		ResultAdd("** Nenhum contrato impresso encontrado para a faixa informada.")
		(cAliasGW2)->( dbCloseArea() )
		Return	
	EndIf
	
	While !(cAliasGW2)->( Eof() )
		IncProc("Filial: " + (cAliasGW2)->GW2_FILIAL + ", Propriet�rio: " + AllTrim((cAliasGW2)->GW2_CDPROP) + ", N�mero: " + AllTrim((cAliasGW2)->GW2_NRCONT))
		ResultAdd("Filial: " + (cAliasGW2)->GW2_FILIAL + ", Propriet�rio: " + AllTrim((cAliasGW2)->GW2_CDPROP) + ", N�mero: " + AllTrim((cAliasGW2)->GW2_NRCONT))
		
		GFERatCon(.T.,(cAliasGW2)->GW2_NRCONT) // Executa a fun��o GFERatCon que Gera o Rateio por Contrato que esta localizada no fonte GFEXFUNC
		
		GFEACTBCON((cAliasGW2)->GW2_NRCONT,(cAliasGW2)->GW2_CDPROP)
		
		(cAliasGW2)->( dbSkip() )
	EndDo
	(cAliasGW2)->(dbCloseArea())
Return

Static Function ResultAdd(cMsg)
	Default cMsg := ""
	
	If IsBlind()
		Return(Nil)
	EndIf
	
	GFEResult:Add(cMsg)
Return(Nil)
 

Static Function ResultDetail(cMsg)
	Default cMsg := ""
	
	If IsBlind()
		Return(Nil)
	EndIf
	
	GFEResult:AddDetail(cMsg)
Return(Nil)
