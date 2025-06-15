#INCLUDE "locr006.ch" 
#INCLUDE "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCR006.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATORIO DISPONIBILIDADE DE MAO DE OBRA-CAIXA DE PROCESSO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCR006()
	LOCAL CDESC1        := STR0001 //"ESTE PROGRAMA TEM COMO OBJETIVO IMPRIMIR RELATORIO "
	LOCAL CDESC2        := STR0002 //"DE ACORDO COM OS PARAMETROS INFORMADOS PELO USUARIO."
	LOCAL CDESC3        := STR0003 //"DISPONIBILIDADE DE MAO DE OBRA - CAIXA DE PROCESSO V1.2"
	LOCAL TITULO        := STR0004 //"DISPONIBILIDADE DE MAO DE OBRA - CAIXA DE PROCESSO"
	LOCAL NLIN          := 80
	LOCAL CPERG         := "LOCP011"
	LOCAL CABEC2        := ""
	LOCAL AORD          := {}       
	LOCAL IMPRIME 

	PRIVATE CVERLOCD    := "V1.2"
	PRIVATE CABEC1      := ""
	PRIVATE LEND        := .F.
	PRIVATE LABORTPRINT := .F.
	PRIVATE LIMITE      := 120
	PRIVATE TAMANHO     := "G"
	PRIVATE NOMEPROG    := "LOCR006" // COLOQUE AQUI O NOME DO PROGRAMA PARA IMPRESSAO NO CABECALHO
	PRIVATE NTIPO       := 18
	PRIVATE ARETURN     := { "ZEBRADO", 1, "ADMINISTRACAO", 2, 2, 1, "", 1}
	PRIVATE NLASTKEY    := 0
	PRIVATE CBTXT       := SPACE(10)
	PRIVATE CBCONT      := 00
	PRIVATE CONTFL      := 01
	PRIVATE M_PAG       := 01
	PRIVATE WNREL       := "LOCR006" 	// COLOQUE AQUI O NOME DO ARQUIVO USADO PARA IMPRESSAO EM DISCO
	PRIVATE CSTRING := ""

	IMPRIME := .T. 

	PERGUNTE(CPERG,.T.)

	WNREL := SETPRINT(CSTRING,NOMEPROG,CPERG,@TITULO,CDESC1,CDESC2,CDESC3,.T.,AORD,.T.,TAMANHO,,.T.)

	IF EMPTY(MV_PAR07)  .OR. EMPTY(MV_PAR08) 
		MSGALERT(STR0005 , STR0006)  //"PERIODO INICIAL OU FINAL ESTÁ(ÃO) EM BRANCO... PRENCHER !"###"GPO - LOCDISMO.PRW"
		RETURN 
	ENDIF 

	If MV_PAR07 > MV_PAR08
		Return
	EndIF

	IF NLASTKEY == 27
		RETURN
	ENDIF

	SETDEFAULT(ARETURN,CSTRING)

	IF NLASTKEY == 27
		RETURN
	ENDIF

	NTIPO := IF(ARETURN[4]==1,15,18)

	RPTSTATUS({|| RUNREPORT(CABEC1,CABEC2,TITULO,NLIN) },TITULO)
RETURN



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFUN‡„O    ³ RUNREPORT º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRI‡„O ³ FUNCAO AUXILIAR CHAMADA PELA RPTSTATUS. A FUNCAO RPTSTATUS º±±
±±º          ³ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ PROGRAMA PRINCIPAL                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
STATIC FUNCTION RUNREPORT(CABEC1,CABEC2,TITULO,NLIN)
Local cFuncao   := ""
Local dData1    := ctod("")
//Local cBranco   := ""
Local aFPQ      := {}
Local nX
Local nPonteiro := 0
Local lImpr     := .T.

	// --> MONTA CABECALHO COM TAMANHO DINAMICO PELO RESULTADO DA QUERY
	CABEC1 := PADR(STR0007, LEN(SRA->RA_FILIAL)+1) //"FL"
	CABEC1 += PADR(STR0008, LEN(SRA->RA_MAT)+1) //"MATRIC"
	CABEC1 += PADR(STR0009, LEN(SRA->RA_NOME)+1) //"NOME"
	CABEC1 += PADR(STR0010, LEN(SRJ->RJ_DESC)+1) //"FUNCAO"
	CABEC1 += PADR(STR0011, LEN(FPQ->FPQ_AS)+1) //"AS "
	CABEC1 += PADR(STR0012, 13 ) //"STATUS"
	CABEC1 += PADR(STR0038, LEN(DTOC(FPQ->FPQ_DATA))+1) //"DATA"
	//CABEC1 += PADR(STR0014, LEN(DTOC(FPQ->FPQ_DATA))+1) //"DT FIM"
	CABEC1 += PADR(STR0015, LEN(FP1->FP1_NOMORI)+1) //"LOCAL"
	CABEC1 += PADR(STR0016, LEN(FQ5->FQ5_DESTIN)+1) //"MUNICIPIO/OBRA"
	CABEC1 += PADR(STR0017, LEN(DTOC(SRF->RF_DATABAS))+3)  //"VCTO FER"


	SRA->(SETREGUA(RECCOUNT()))
	SRA->(dbGotop())

	WHILE SRA->(!EOF())
		INCREGUA()

		// Tratamento do cadastro de funcionarios
		If SRA->RA_FILIAL <> xFilial("SRA") .or. SRA->RA_MAT < MV_PAR01 .or. SRA->RA_MAT > MV_PAR02 
			SRA->(dbSkip())
			Loop
		EndIF
		If SRA->RA_CODFUNC < MV_PAR03 .or. SRA->RA_CODFUNC > MV_PAR04
			SRA->(dbSkip())
			Loop
		EndIF
		If !SRA->RA_SITFOLH $ MV_PAR10 .and. !empty(MV_PAR10)
			SRA->(dbSkip())
			Loop
		EndIF

		cFuncao := ""
		SRJ->(dbSetOrder(1))
		If SRJ->(dbSeek(xFilial("SRJ")+SRA->RA_CODFUNC))
			cFuncao := SRJ->RJ_DESC
		EndIF

		dData1 := ctod("01/01/2020") 
		SRF->(dbSetOrder(1))
		If SRF->(dbSeek(xFilial("SRF")+SRA->RA_MAT))
			dData1 := SRF->RF_DATABAS
		EndIF

		
		IF LABORTPRINT
			@ NLIN,00 PSAY STR0037 //"*** CANCELADO PELO OPERADOR ***"
			EXIT
		ENDIF
	
		IF NLIN > 55 
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			NLIN := 8
		ENDIF

		@ NLIN, 000      PSAY SRA->RA_FILIAL
		@ NLIN, PCOL()+1 PSAY SRA->RA_MAT
		@ NLIN, PCOL()+1 PSAY SRA->RA_NOME
		@ NLIN, PCOL()+1 PSAY cFuncao

		lImpr := .F.

		aFPQ := {}
		dTemp := MV_PAR07
		While dTemp <= MV_PAR08
			aadd(aFPQ, {0, dTemp,"Disponivel  "})
			dTemp ++
		EndDo

		FPQ->(dbSetOrder(1))
		FPQ->(dbSeek(xFilial("FPQ")+SRA->RA_MAT))
		While !FPQ->(Eof()) .and. FPQ->FPQ_MAT == SRA->RA_MAT .and. FPQ->FPQ_FILIAL == xFilial("FPQ")
			IF FPQ->FPQ_DATA >= MV_PAR07 .and. FPQ->FPQ_DATA <= MV_PAR08
				If FPQ->FPQ_AS >= MV_PAR05 .and. FPQ->FPQ_AS <= MV_PAR06

					nPonteiro := 0
					For nX := 1 to len(aFPQ)
						If aFPQ[nX][2] == FPQ->FPQ_DATA
							nPonteiro := nX
							Exit
						EndIF
					Next	

					If nPonteiro > 0
						aFPQ[nPonteiro][1] := FPQ->(Recno())
						If (FPQ->FPQ_STATUS <> "INTEGR" .and. FPQ->FPQ_STATUS <> "OBRA") .or. FPQ->FPQ_STATUS == "PATIO"
							aFPQ[nPonteiro][3] := "Disponivel  "
						EndIF
						If (FPQ->FPQ_STATUS == "INTEGR" .or. FPQ->FPQ_STATUS == "OBRA")
							aFPQ[nPonteiro][3] := "Alocado     "
						EndIF
						If FPQ->FPQ_STATUS <> "INTEGR" .and. FPQ->FPQ_STATUS <> "OBRA" .and. FPQ->FPQ_STATUS <> "PATIO"
							aFPQ[nPonteiro][3] := "Indisponivel"
						EndIF
					EndIF

				EndIF
			EndIF
			FPQ->(dbSkip())
		EndDo

		// Aplicação do filtro
		If MV_PAR09 == 1 // disponivel
			aTemp := {}
			For nX := 1 to len(aFPQ)
				If alltrim(aFPQ[nX][3]) == "Disponivel"
					aadd(aTemp,{aFPQ[nX][1],aFPQ[nX][2],aFPQ[nX][3]})
				EndIf
			Next
			aFPQ := aClone(aTemp)
		ElseIf MV_PAR09 == 2 // Alocado
			aTemp := {}
			For nX := 1 to len(aFPQ)
				If alltrim(aFPQ[nX][3]) == "Alocado"
					aadd(aTemp,{aFPQ[nX][1],aFPQ[nX][2],aFPQ[nX][3]})
				EndIf
			Next
			aFPQ := aClone(aTemp)
		ElseIf MV_PAR09 == 3 // Indisponivel
			aTemp := {}
			For nX := 1 to len(aFPQ)
				If alltrim(aFPQ[nX][3]) == "Indisponivel"
					aadd(aTemp,{aFPQ[nX][1],aFPQ[nX][2],aFPQ[nX][3]})
				EndIf
			Next
			aFPQ := aClone(aTemp)
		EndIF


		if len(aFPQ) == 0
			cBranco := space(TamSx3("FPQ_AS")    [1]) + " "
			cBranco += "Sem.Registro "
			cBranco += dtoc(MV_PAR07) + " "
			cBranco += space(TamSx3("FP1_NOMORI")[1]) + " "
			cBranco += space(TamSx3("FQ5_DESTIN")[1]) + " "
			@ NLIN, PCOL()+1 PSAY cBranco
			@ NLIN, PCOL()+1 PSAY dData1+365		
		Else

			cImp := ""
			For nX := 1 to len(aFPQ)
				If lImpr
					@ NLIN, 000      PSAY SRA->RA_FILIAL
					@ NLIN, PCOL()+1 PSAY SRA->RA_MAT
					@ NLIN, PCOL()+1 PSAY SRA->RA_NOME
					@ NLIN, PCOL()+1 PSAY cFuncao
				Else
					@ NLIN, 000      PSAY space(tamsx3("RA_FILIAL")[1])
					@ NLIN, PCOL()+1 PSAY space(tamsx3("RA_MAT")[1])
					@ NLIN, PCOL()+1 PSAY space(tamsx3("RA_NOME")[1])
					@ NLIN, PCOL()+1 PSAY space(len(cFuncao))
				EndIF

				FPQ->(dbGoto(aFPQ[nX][1]))
				cNOMORI := space(tamsx3("FP1_NOMORI")[1])
				cDESTIN := space(tamsx3("FQ5_DESTIN")[1])
				If !empty(FPQ->FPQ_AS)
					FPA->(dbSetOrder(3))
					If FPA->(dbSeek(xFilial("FPA")+FPQ->FPQ_AS))
						FP1->(dbSetOrder(1))
						If FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
							cNOMORI := FP1->FP1_NOMORI
						EndIf
					EndIF
					FQ5->(dbSetOrder(9))
					If FQ5->(dbSeek(xFilial("FQ5")+FPQ->FPQ_AS))
						cDESTIN := FQ5->FQ5_DESTIN
					EndIf
				EndIF
				cImp := FPQ->FPQ_AS + " "
				cImp += aFPQ[nX][3] + " "
				cImp += dtoc(aFPQ[nX][2]) + " "
				cImp += cNOMORI + " "
				cImp += cDESTIN + " "
				@ nLin, PCOL()+1 PSAY cImp
				@ NLIN, PCOL()+1 PSAY dData1+365 
				nLin ++
			Next
			
		EndIF
		


		//@ NLIN, PCOL()+1 PSAY SRA->FPL_AS
		//@ NLIN, PCOL()+1 PSAY SRA->STAT_MO    
		//CLODTI := IF(TRBMO->FPL_DTINI < MV_PAR07, MV_PAR07, TRBMO->FPL_DTINI )
		//CLODTF := IF(TRBMO->FPL_DTFIM > MV_PAR08, MV_PAR08, TRBMO->FPL_DTFIM)
		//@ NLIN, PCOL()+1 PSAY CLODTI    
		//@ NLIN, PCOL()+1 PSAY CLODTF 
		//@ NLIN, PCOL()+1 PSAY TRBMO->MUN_OBRA  
		//@ NLIN, PCOL()+1 PSAY TRBMO->FQ5_DESTIN  

		//@ NLIN, PCOL()+1 PSAY dData1+365 
	    NLIN := NLIN + 1 		// AVANCA A LINHA DE IMPRESSAO
		SRA->(DBSKIP()) 		// AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
	ENDDO

    //TRBMO->(DBCLOSEAREA())

	SET DEVICE TO SCREEN
	
	IF ARETURN[5]==1
	   DBCOMMITALL()
	   SET PRINTER TO
	   OURSPOOL(WNREL)
	ENDIF
	
	MS_FLUSH()

RETURN



// ======================================================================= \\
STATIC FUNCTION VALIDPERG(CPERG)
// ======================================================================= \\
/*
CPERG := PADR(CPERG,10)
PUTSX1(CPERG,"01","MATRIC DE?  ","","","MV_CH1","C",06,00,00,"G","","SRAZLD","","","MV_PAR01","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"02","MATRIC ATE? ","","","MV_CH2","C",06,00,00,"G","","SRAZLD","","","MV_PAR02","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"03","FUNCAO DE?  ","","","MV_CH3","C",05,00,00,"G","","SRJ   ","","","MV_PAR03","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"04","FUNCAO ATE? ","","","MV_CH4","C",05,00,00,"G","","SRJ   ","","","MV_PAR04","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"05","AS  DE?     ","","","MV_CH5","C",27,00,00,"G","","DTQA  ","","","MV_PAR05","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"06","AS  ATE?    ","","","MV_CH6","C",27,00,00,"G","","DTQA  ","","","MV_PAR06","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"07","PERIODO DE? ","","","MV_CH7","D",08,00,00,"G","NAOVAZIO()","      ","","","MV_PAR07","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"08","PERIODO ATE?","","","MV_CH8","D",08,00,00,"G","NAOVAZIO()","      ","","","MV_PAR08","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"09","STATUS MO?  ","","","MV_CH9","N",01,00,00,"C","","      ","","","MV_PAR09","DISPONIVEL","","","","ALOCADO","","","AMBOS","","","","","","","","",,,,"")
PUTSX1(CPERG,"10","SIT. FOLHA? ","","","MV_CHA","C",05,00,00,"G","FSITUACAO()","","","","MV_PAR10","","","","","","","","","","","","","","","","",,,,"")
PUTSX1(CPERG,"11","EXPORTA EXCEL?","","","MV_CHB","N",01,0,0,"C","","      ","","","MV_PAR11","SIM","","","","NÃO","","" ,"","","","","","","","","")
*/
RETURN



STATIC FUNCTION OLDRUNREPORT(CABEC1,CABEC2,TITULO,NLIN)
Local CJOIN
Local CJOIN1
Local CQRYWHER
Local CQRYINT
Local CARQDIAS
Local CQUERY
	
	// MONTA JOIN USADO VARIAS VEZES PARA NAO DUPLICAR CODIFICACAO
 	CJOIN  := " LEFT JOIN "+ RETSQLNAME("SRJ") + " RJ  ON RJ.D_E_L_E_T_='' AND RJ_FUNCAO = RA_CODFUNC   " + CRLF
 	CJOIN  += " LEFT JOIN "+ RETSQLNAME("SRF") + " RF  ON RF.D_E_L_E_T_='' AND RF_MAT=RA_MAT AND RA_FILIAL = '"+xFilial("SRA")+"'" + CRLF
	
   	CJOIN1 := " LEFT JOIN (SELECT 'ALOCADO   ' STAT_MO, ZLD.*, COALESCE(FP1_NOMORI,'SEM FP1') MUN_OBRA ,FQ5_DESTIN " + CRLF
	CJOIN1 += " FROM "+ RETSQLNAME("FPL") + " ZLD  " + CRLF
	CJOIN1 += " LEFT JOIN "+ RETSQLNAME("FQ5") + " DTQ ON FQ5_AS = FPL_AS AND DTQ.D_E_L_E_T_ = '' 
	CJOIN1 += " LEFT JOIN "+ RETSQLNAME("FP1") + " ZA1 ON FP1_PROJET = FPL_PROJET  AND FP1_OBRA = FPL_OBRA AND ZA1.D_E_L_E_T_ = '' " + CRLF
	CJOIN1 += " WHERE ZLD.D_E_L_E_T_='' " + CRLF
	CJOIN1 += " AND ((FPL_DTINI <= '"  + DTOS(MV_PAR07) + "' AND FPL_DTINI <= '" + DTOS(MV_PAR08)  + "' AND FPL_DTFIM >= '"  + DTOS(MV_PAR07) + "'  AND FPL_DTFIM >= '" + DTOS(MV_PAR08) + "') OR "	// PERÍODO TOTALMENTE DENTRO DO LANÇAMENTO
	CJOIN1 += " (FPL_DTINI >= '"  + DTOS(MV_PAR07) + "' AND FPL_DTINI <= '" + DTOS(MV_PAR08)  + "' AND FPL_DTFIM >= '"  + DTOS(MV_PAR07) + "'  AND FPL_DTFIM <= '" + DTOS(MV_PAR08) + "') OR "	// PERÍODO TOTALMENTE FORA DO LANÇAMENTO
	CJOIN1 += " (FPL_DTINI <= '"  + DTOS(MV_PAR07) + "' AND FPL_DTINI<= '" + DTOS(MV_PAR08)  + "' AND FPL_DTFIM >= '"  + DTOS(MV_PAR07) + "'  AND FPL_DTFIM <= '" + DTOS(MV_PAR08) + "') OR "	// LANÇAMENTO TERMINA NO PERÍODO
	CJOIN1 += " (FPL_DTINI >= '"  + DTOS(MV_PAR07) + "' AND FPL_DTINI<= '" + DTOS(MV_PAR08)  + "' AND FPL_DTFIM >= '"  + DTOS(MV_PAR07) + "'  AND FPL_DTFIM >= '" + DTOS(MV_PAR08) + "'))) MAO  "	// LANÇAMENTO INICIA NO PERÍODO
	CJOIN1 += " ON RA_MAT = FPL_MATRIC AND FPL_FILIAL = '"+xFilial("FPL")+"' " + CRLF
 
    // MONTA WHERE USADO VARIAS VEZES PARA NAO DUPLICAR CODIFICACAO
	// 18/11/2022 - Jose Eulalio - SIGALOC94-568 - Campo TSheet não é mais utilizado
	//CQRYWHER := " WHERE RA.D_E_L_E_T_ = '' AND RA_FILIAL = '"+ XFILIAL("SRA")+ "' AND RA_TSHEET = 'S' " + CRLF
	CQRYWHER := " WHERE RA.D_E_L_E_T_ = '' AND RA_FILIAL = '"+ XFILIAL("SRA")+ "' " + CRLF
	CQRYWHER += " AND RA_MAT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' -- MATRICULA DE ATE " + CRLF
	CQRYWHER += " AND '"+MV_PAR10+"' LIKE '%'"+MV_PAR10+ "'%' -- SITUACAO ESCOLHIDA"+ CRLF
	CQRYWHER += " AND RA_CODFUNC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' -- FUNCAO DE ATE " + CRLF
	CQRYWHER += " AND COALESCE(FPL_AS,'"+MV_PAR05+"') BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' -- AS  DE ATE " + CRLF
	IF MV_PAR09 == 1 						// DISPONIVEL 
		CQRYWHER += " AND FPL_AS IS NULL " + CRLF
	ELSEIF MV_PAR09 == 2					// ALOCADO 
 		CQRYWHER += " AND FPL_AS IS NOT NULL " + CRLF
	ElseIF MV_PAR09 == 3                    // Indisponível - Frank em 25/11/22
	ENDIF
	
	CQRYINT := "SELECT DISTINCT FPL_FILIAL, FPL_MATRIC, FPL_DTINI, FPL_DTFIM "+CRLF
	CQRYINT += "FROM "+ RETSQLNAME("SRA") + " RA "+CRLF
	CQRYINT += CJOIN + CJOIN1 +CQRYWHER		// APROVEITA MONTAGEM FEITA ANTERIORMENTE
	CQRYINT += " AND FPL_DTINI BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"' -- PERIODO DE ATE " + CRLF
	CQRYINT += " AND FPL_DTFIM BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'  --PERIODO DE ATE "+ CRLF
	CQRYINT += "ORDER BY 1,2,3   
	
	CARQDIAS := LOCXITU08(CQRYINT,"FPL_MATRIC", "FPL_DTINI","FPL_DTFIM",MV_PAR07, MV_PAR08, "FPL_FILIAL" )

	CQUERY := " SELECT RA_FILIAL, RA_MAT, RA_NOME, RJ_DESC, COALESCE(FPL_AS,'')  FPL_AS, COALESCE(STAT_MO, 'DISPONIVEL') STAT_MO,  " + CRLF
	CQUERY += " COALESCE(FPL_DTINI,'"+DTOS(MV_PAR07)+"')FPL_DTINI, COALESCE(FPL_DTFIM,'"+DTOS(MV_PAR08)+"')FPL_DTFIM, LEFT(COALESCE(MUN_OBRA, 'EMPRESA'),30) MUN_OBRA,  " + CRLF
	CQUERY += " LEFT(COALESCE(FQ5_DESTIN, ''),30) FQ5_DESTIN, COALESCE(RF_DATABAS, '20200101') VENCTO_FER,RA_SITFOLH " + CRLF
	CQUERY += " FROM "+ RETSQLNAME("SRA") + " RA " + CRLF
	CQUERY += CJOIN +CJOIN1					// APROVEITA MONTAGEM FEITA ANTERIORMENTE
	CQUERY += CQRYWHER 						// APROVEITA MONTAGEM FEITA ANTERIORMENTE

	// CONSIDERA DISPONIVEL TODOS OS BENS QUE NAO TIVEREM A DATA NO ZLD A PARTIR DO ARQUIVO DE APOIO
	CQUERY += " UNION ALL" + CRLF
    CQUERY += " SELECT RA_FILIAL, RA_MAT, RA_NOME, RJ_DESC, '' , 'DISPONIVEL', DTINI, DTFIM, '', '',COALESCE(RF_DATABAS, '20200101') VENCTO_FER,RA_SITFOLH  " + CRLF
	CQUERY += " FROM "+ RETSQLNAME("SRA") + " RA " + CRLF
	CQUERY += CJOIN 
	CQUERY += " JOIN "+CARQDIAS + " DIAS ON DIAS.FPL_MATRIC = RA_MAT  AND DIAS.FPL_FILIAL = '"+xFilial("FPL")+"' " + CRLF
	CQUERY += " WHERE RA.D_E_L_E_T_ = ''" + CRLF 
	CQUERY += " ORDER BY RA_NOME, 7,8 " + CRLF
	
	IF SELECT("TRBMO") > 0
	   TRBMO->(DBCLOSEAREA())
	ENDIF   
	CQUERY := CHANGEQUERY(CQUERY) 
	
	DBUSEAREA(.T., "TOPCONN", TCGENQRY(,,CQUERY), "TRBMO", .F., .T.)

	TCSETFIELD("TRBMO","FPL_DTINI" ,"D",8,0)
	TCSETFIELD("TRBMO","FPL_DTFIM" ,"D",8,0)
	TCSETFIELD("TRBMO","VENCTO_FER","D",8,0)
	                      
	// --> MONTA CABECALHO COM TAMANHO DINAMICO PELO RESULTADO DA QUERY
	CABEC1 := PADR(STR0007, LEN(TRBMO->RA_FILIAL)+1) //"FL"
	CABEC1 += PADR(STR0008, LEN(TRBMO->RA_MAT)+1) //"MATRIC"
	CABEC1 += PADR(STR0009, LEN(TRBMO->RA_NOME)+1) //"NOME"
	CABEC1 += PADR(STR0010, LEN(TRBMO->RJ_DESC)+1) //"FUNCAO"
	CABEC1 += PADR(STR0011, LEN(TRBMO->FPL_AS)+1) //"AS "
	CABEC1 += PADR(STR0012, LEN(TRBMO->STAT_MO)+1) //"STATUS"
	CABEC1 += PADR(STR0013, LEN(DTOC(TRBMO->FPL_DTINI))+1) //"DT INIC"
	CABEC1 += PADR(STR0014, LEN(DTOC(TRBMO->FPL_DTFIM))+1) //"DT FIM"
	CABEC1 += PADR(STR0015, LEN(TRBMO->MUN_OBRA)+1) //"LOCAL"
	CABEC1 += PADR(STR0016, LEN(TRBMO->FQ5_DESTIN)+1) //"MUNICIPIO/OBRA"
	CABEC1 += PADR(STR0017, LEN(DTOC(TRBMO->VENCTO_FER))+3)  //"VCTO FER"
	
	SETREGUA(RECCOUNT())
	
	WHILE TRBMO->(!EOF())

		IF LABORTPRINT
			@ NLIN,00 PSAY STR0037 //"*** CANCELADO PELO OPERADOR ***"
			EXIT
		ENDIF
	
		IF NLIN > 55 
			CABEC(TITULO,CABEC1,CABEC2,NOMEPROG,TAMANHO,NTIPO)
			NLIN := 8
		ENDIF

		@ NLIN, 000      PSAY TRBMO->RA_FILIAL                                        
		@ NLIN, PCOL()+1 PSAY TRBMO->RA_MAT    
		@ NLIN, PCOL()+1 PSAY TRBMO->RA_NOME    
		@ NLIN, PCOL()+1 PSAY TRBMO->RJ_DESC    
		@ NLIN, PCOL()+1 PSAY TRBMO->FPL_AS
		@ NLIN, PCOL()+1 PSAY TRBMO->STAT_MO    
		CLODTI := IF(TRBMO->FPL_DTINI < MV_PAR07, MV_PAR07, TRBMO->FPL_DTINI )
		CLODTF := IF(TRBMO->FPL_DTFIM > MV_PAR08, MV_PAR08, TRBMO->FPL_DTFIM)
		@ NLIN, PCOL()+1 PSAY CLODTI    
		@ NLIN, PCOL()+1 PSAY CLODTF 
		@ NLIN, PCOL()+1 PSAY TRBMO->MUN_OBRA  
		@ NLIN, PCOL()+1 PSAY TRBMO->FQ5_DESTIN  
		@ NLIN, PCOL()+1 PSAY TRBMO->VENCTO_FER+365 
	    NLIN := NLIN + 1 		// AVANCA A LINHA DE IMPRESSAO
		TRBMO->(DBSKIP()) 		// AVANCA O PONTEIRO DO REGISTRO NO ARQUIVO
	ENDDO

    TRBMO->(DBCLOSEAREA())

	SET DEVICE TO SCREEN
	
	IF ARETURN[5]==1
	   DBCOMMITALL()
	   SET PRINTER TO
	   OURSPOOL(WNREL)
	ENDIF
	
	MS_FLUSH()

RETURN
