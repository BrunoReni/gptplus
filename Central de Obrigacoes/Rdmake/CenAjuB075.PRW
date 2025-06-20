#Include 'Protheus.ch'

#DEFINE ARQ_LOG		    "correcao_recnos.log"
#DEFINE ARQ_MOV_CSV		"recnos_movimentos.csv"
#DEFINE ARQ_CRI_CSV		"recnos_criticas.csv"


User Function CnAjB075()

    Local aSay    := {}
    Local aButton := {}
    Local nOpc    := 0
    Local Titulo  := 'Central de Obriga��es'
    Local cDesc1  := 'Esta rotina far� a exclus�o de criticas B075 para movimenta��es de '
    Local cDesc2  := 'retifica��o da Central de Obriga��es.'
    Local cDesc3  := 'Tabela: B3F'

    aAdd( aSay, cDesc1 )
    aAdd( aSay, cDesc2 )
    aAdd( aSay, cDesc3 )

    aAdd( aButton, { 1, .T., { || nOpc := 2, FechaBatch() } } )
    aAdd( aButton, { 2, .T., { || FechaBatch() } } )

    FormBatch( Titulo, aSay, aButton, , 200, 450 )

    If nOpc == 2
        BEGIN TRANSACTION    
            PlsLogFil(CENDTHRL("I") + "[CenAjuB075] Inicio da dele��o das criticas B075. ",ARQ_LOG)
            Processa( { || lOk := delCriB075() },"Esclus�o Criticas B075 para retifica��es","Processando...",.T.)
            PlsLogFil(CENDTHRL("I") + "[CenAjuB075] Fim  da dele��o das criticas B075. ",ARQ_LOG)
        END TRANSACTION
        MsgInfo("Processamento conclu�do!")
    EndIf

Return 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} delCriB075()

Corrige a chave �nica das movimenta��es do SIB

@author everton.mateus
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function delCriB075()
	
	Local nQtd  := 0
	Local nProc := 0

    PlsLogFil(CENDTHRL("I") + "[delCriB075] Inicio da corre��o dos recnos das movimenta��es B3X. ",ARQ_LOG)
    PlsLogFil("recno_b3k;recno_b3x;valo_antigo;valor_novo",ARQ_MOV_CSV)
    nQtd := carMovtoSIB(.T.)
    
    If nQtd > 0
        ProcRegua( int(nQtd / 1000) + 1)
        carMovtoSIB(.F.)
        Do While !TRBCOR->(Eof())
            If nProc % 200 == 0
                cMsg := "Movimenta��es Excluidas: " +AllTrim(Str(nQtd))+"."
                PlsLogFil(CENDTHRL("I") + "[delCriB075] " + cMsg,ARQ_LOG)
                IncProc(cMsg)
            EndIf
            B3F->( DbGoto(TRBCOR->RECB3F) )
            RecLock("B3F",.F.)
                B3F->(DbDelete())
            B3F->(msUnLock())
            PlsLogFil(Alltrim(Str(TRBCOR->RECB3F)),ARQ_MOV_CSV)
            nProc++
            TRBCOR->(DbSkip())
        EndDo
    Else
        PlsLogFil(CENDTHRL("W") + "[delCriB075] N�o encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TRBCOR->(DbCloseArea())	
    PlsLogFil(CENDTHRL("I") + "[delCriB075] Fim da corre��o dos recnos das movimenta��es B3X. ",ARQ_LOG)

Return

Static Function carMovtoSIB(lTotal)
	
    Local nQtd := 0
    Local cSql := ""
	
	Default lTotal := .F.
	
	If Select('TRBCOR') > 0
		TRBCOR->(dbCloseArea())
	EndIf

	cSql := " SELECT  "
	If lTotal
		cSql += " count(1) TOTAL "
	Else 
		cSql += " B3F.R_E_C_N_O_ RECB3F "
	EndIf
	
	cSql += " FROM " + RetSqlName("B3F") + " B3F "
	cSql += "   INNER JOIN " + RetSqlName("B3X") + " B3X ON (B3F_CHVORI =  B3X.R_E_C_N_O_) "
	cSql += " WHERE 1 = 1  "
	cSql += "   AND B3F_CODCRI LIKE '%B075%' "  //Critica
	cSql += "   AND B3X_OPERA = '2'          "  //Opera��o Retifica��o   
	cSql += "   AND B3F.D_E_L_E_T_ = ' '     "
	cSql += "   AND B3X.D_E_L_E_T_ = ' '     "
		
	cSql := ChangeQuery(cSql)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Query de movimenta��es: " + cSql,ARQ_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOR",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Fim da query.",ARQ_LOG)

	If lTotal .AND. !TRBCOR->(Eof())
		nQtd := TRBCOR->TOTAL
	EndIf

Return nQtd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENDTHRL

Funcao criada para retornar date e hora para log 

@author timoteo.bega
@since 
/*/
//--------------------------------------------------------------------------------------------------
Static Function CENDTHRL(cTp)

	Local cMsg := "[" + DTOS(Date()) + " " + Time() + "]"
	Default cTp	:= "I"

	If cTp == "E"
		cMsg += "[ERRO]"
	ElseIf cTp == "W"
		cMsg += "[WARN]"
	Else
		cMsg += "[INFO]"
	EndIf

Return cMsg