#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 

Static _cQryC20
Static _cRetC20

//-------------------------------------------------------------------
/*/{Protheus.doc} GraVaC20

Função responsável por garavar a chave da nota fiscal (Protheus) na tabela C20 do TAF, para depois conseguirmos localizar esta nota no ERP

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
Parametros: Numero da Nota
Serie da Nota
Código Cliente / Fornecedor
Loja Cliente / Fornecedor
Data da Entrada da Nota
Hora de emissão da nota
Especie da Nota
cProC20 (Variavel de Controle )=1 Inclusão, 2 Cancelamento, cProC20 = 3 Exclusão, 4 = Complemento via MATA926
aProcC20 (Array para armazenar a tabela complemento via MATA926) esta parte ainda precisa ser revisitada
/*/
//-------------------------------------------------------------------

Function GraVaC20(cNumNF, cSerie, cTpOper, cCliFor, cLoja, dEntrada, cHorEmis, cEspecie, cProC20, aProcC20)

Local lExecC20      := VerCampos()
Local cIndOper      := ""
Local cFilProc      := xFilial("C20")
Local cAliasC20     := GetNextAlias()
Local aBind         := {}
Local cChvNf        := ""

DEFAULT cNumNF      := " "
DEFAULT cSerie      := " "
DEFAULT cTpOper     := " "
DEFAULT cCliFor     := " "
DEFAULT cLoja       := " "
DEFAULT cEspecie    := " "
DEFAULT cProC20     := " "
DEFAULT dEntrada    := " "
DEFAULT cHorEmis    := " "
DEFAULT aProcC20    := {}

If lExecC20 
    cIndOper := IIf(cTpOper = "S","1","0")
    If cProC20 == "1" // Se for uma inclusão de documento fiscal
        cChvNf := TAFGERAID("TAF")
        If RecLock("C20",.T.)
            C20->C20_FILIAL := cFilProc
            C20->C20_CHVNF	:= cChvNf  //TAFGERAID("TAF")  
            C20->C20_NUMDOC := cNumNF 
            C20->C20_SERIE	:= cSerie	
            C20->C20_INDOPE	:= cIndOper
            C20->C20_CLIFOR	:= cCliFor
            C20->C20_LOJA	:= cLoja
            C20->C20_DTDOC  := dEntrada
            C20->C20_HORMIS	:= cHorEmis
            C20->C20_ESPECI	:= cEspecie	
            C20->C20_ATUDOC	:= cProC20
			C20->C20_STATUS := '1'
            C20->(MsUnlock())

        Endif
    // cProC20 =1 Inclusão, 2 Cancelamento, cProC20 = 3 Exclusão, 4 = Complemento via MATA926   
    ElseIf cProC20 > "2"
        If _cQryC20 == nil 
	        _cQryC20 := "SELECT  C20.C20_CHVNF, C20.R_E_C_N_O_ AS RECNO"
	        _cQryC20 += " FROM " + RetSqlName('C20') + " C20"
	        _cQryC20 += " WHERE C20.C20_FILIAL    = ?"
	        _cQryC20 += " AND C20.C20_CLIFOR      = ?"
	        _cQryC20 += " AND C20.C20_LOJA        = ?"
	        _cQryC20 += " AND C20.C20_NUMDOC      = ?"
	        _cQryC20 += " AND C20.C20_SERIE       = ?"
            _cQryC20 += " AND C20.C20_INDOPE      = ?"  
            _cQryC20 += " AND C20.C20_ESPECI      = ?"
            _cQryC20 += " AND C20.C20_DTDOC       = ?"
            _cQryC20 += " AND C20.C20_HORMIS      = ?"
	        _cQryC20 += " AND C20.D_E_L_E_T_  	  = ?"
        EndIf     
        aBind := {}
        AADD(aBind,cFilProc)
        AADD(aBind,cCliFor)
        AADD(aBind,cLoja)
        AADD(aBind,cNumNF)
        AADD(aBind,cSerie)
        AADD(aBind,cIndOper)
        AADD(aBind,cEspecie)
        AADD(aBind,DtoS(dEntrada))
        AADD(aBind, cHorEmis )
        AADD(aBind,Space(1))
        If !Empty(_cQryC20) 
            dbUseArea(.T.,'TOPCONN',TcGenQry2(,,_cQryC20,aBind),cAliasC20,.T.,.F.)  
        Endif    

        DbSelectArea("C20")	
        DbGoto((cAliasC20)->RECNO)
        If RecLock("C20",.F.)
            C20->C20_ATUDOC	:= cProC20
			C20->C20_STATUS := '1' 
            C20->(MsUnlock())
        Endif
        (cAliasC20)->(DbCloseArea())  
    Endif
	//Executa Procedure
	AtuTabTaf(cFilProc)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VerCampos

Função para validar a exixtencia dos novos campos da C20

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function VerCampos()
If (C20->(FieldPos("C20_CLIFOR")))>0 .And. (C20->(FieldPos("C20_LOJA")))>0 .And. (C20->(FieldPos("C20_HORMIS")))>0 .And. (C20->(FieldPos("C20_ESPECI")))>0 .And. (C20->(FieldPos("C20_ATUDOC")))>0
    Return(.T.)
Else
    Return(.F.)
Endif

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTabTaf

Função que vefica todas as todas as filiais processadas pelo ERP e também responsável por iniciar o Job que irá fazer o controle das Threads de processamento

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function AtuTabTaf(cFilProc)
Local aNthread	 :=  CheckThread("THREADTAF")
Local nPos		 := 0
Local aFil		 := {}

//Variavel global que armazena todas as filiais para processamento
GetGlbVars("FILIALTAF", aFil)

//verifica se tem alguma thread já em execução para este job
If Len(aNthread) = 0
	ConOut(Repl("-",80))
	ConOut(PadC(OemToAnsi("Gravação C20 e C30"),80))
	ManualJob( "THREADTAF", GetEnvServer(), "", "", "THREADTAF", "", "" )
	PutGlbVars( "EMPRESA" , cEmpAnt ) //Carrega a empresa
	Aadd(aFil,{cFilProc,0})
	PutGlbVars( "FILIALTAF" , aFil )	
Else
	//veriffica se a filial do documento que esta sendo processado do ERP já se encontra no array para ser processado pelo JOB
	nPos := aScan( aFil , {|x| x[1] == cFilProc .And. x[2] < 3  } )
	If nPos == 0
		Aadd(aFil,{cFilProc,0})
		PutGlbVars( "FILIALTAF" , aFil )
	Endif	
Endif
GlbUnLock()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} THREADTAF

Função abaixo trata-se do Job controlador, ele será responsavel por iniciar e controlar as Threads de processamento

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
//Controla Thread
Function THREADTAF(cEmpAnt, cFilAnt)
Local lErro                  := .F.
Local oError
Local bError                 :={|e| oError := e, Break(e)}
Local bErrorBlock            := ErrorBlock( bError )
Local nCount    			 := 0
Local nNumThread			 := 1 // Criar parâmetro para controlar número de threads para processamento
Local nTempEsp				 := 5000
Local nLoop					 := 0
Local lProc 				 := .T.
Local nQtdeFil				 := 0
Local nFilProc				 := 1
Local aFilPrc				 := {}
Local nThreadPro			 := 0
Local nPosFil				 := 1
Local aNthread1	 			 :=  CheckThread("THREADTAF1")
Local nThrCai				 := 0
Local cWait					 := ""
//Abre o ambiente
RpcSetType(3)  //Nao consome licensas

Iif(nNumThread < 1, 1, nNumThread )

BEGIN SEQUENCE	
	While !KillApp()
		GetGlbVars("FILIALTAF",aFilPrc)
		aNthread1 :=  CheckThread("THREADTAF1")
		//Verifica se alguma thread caiu, caso tenha caido altera variaveis para iniciar outra
		If (Len(aNthread1) < nThreadPro) .And. (aScan( aFilPrc , {|x| x[2] < 2 } )) > 0
			nThrCai++
			nThreadPro--		
			lProc := .T.
		Endif	
		//caso alguma thread tenha caido mais ainda tenhamos mais filiais que ainda não iniciaram o processamento
		//deixamos a filial onde aconteceu a queda para ser processada por ultimo
		If nThrCai > 0 .And. ((aScan( aFilPrc , {|x| x[2] == 0  } )) == 0 )
			nPos := (aScan( aFilPrc , {|x| x[2] == 1 } )) > 0
			If nPos > 0
				lProc := .T.			
				nPosFil := nPos
				nThrCai--
			Endif	
		Endif	
		//Caso tenha passado mais de 1 hora sem ter processado nada o job é finalizado
		If nCount == 40
			FWFreeArray(aFilPrc)
			Exit
		Endif
		
		//Caso tenha alguma thead em wait verifica se tem mais alguma filial para processar, caso tenha inicia o processamento da nova filial
		GetGlbVars("THREADWAIT",cWait)
		If cWait == "1" 
			nQtdeFil := Len(aFilPrc)
			If nFilProc <= nQtdeFil
				lProc := .T.
				nPosFil += 1
				nFilProc++
			Else
				lProc := .F.
			Endif
			iF lProc
				PutGlbVars( "NPOSFIL" , nPosFil )
				PutGlbVars("THREADWAIT","2")
				IPCGo("THREADTAF1")
			Endif	
		//Caso não tenha nenhuma thread em wait, verifica se tem mais alguma filial para processar e se o número de threads que esta processando e inferior ao numero de threads disponiveis
		//caso seja menor inicia uma nova thread 
		ElseIf nNumThread > nThreadPro .And. lProc	
			ManualJob( "THREADTAF1", GetEnvServer(), "", "", "THREADTAF1", "", "")
			nThreadPro += 1 
			PutGlbVars( "NTHPRO" , nThreadPro )
			PutGlbVars( "NPOSFIL" , nPosFil )
			GlbUnLock()
			nLoop  := 0
			Sleep(10)
			nFilProc++
			nQtdeFil := Len(aFilPrc)
			If nFilProc <= nQtdeFil
				lProc := .T.
				nPosFil += 1
			Else
				lProc := .F.
			Endif
		Else
			Sleep(10)		
		Endif
		If (aScan( aFilPrc , {|x| x[2] < 2  } )) == 0
			nLoop  += nTempEsp
			Sleep(nLoop)
			nCount += 1	
		Endif
	ENDDO

RECOVER
	lErro	:= .T.

END SEQUENCE

ErrorBlock( bErrorBlock )

IF lErro
	conout(CHR(10)+CHR(13))
	conout('########## - FIM ERRO DE THREAD THREADTAF - ##########')	
	conout(CHR(10)+CHR(13))
EndIF
KillApp(.T.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} THREADTAF1

Função abaixo trata-se do(s) Job de processamento, os mesmos são responsáveis por receber a filial a ser processada e iniciar a função que irá processar
e gravar o restante das informações nas tabelas do TAF

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
//Chamada das threads
Function THREADTAF1()
Local lErro                  := .F.
Local oError
Local bError                 :={|e| oError := e, Break(e)}
Local bErrorBlock            := ErrorBlock( bError )
Local nCount				 := 0
Local nTimeOut				 := 3600000
Local nFim					 := 0
Local nTempExec 			 := 10000
Local nPosTrab				 := 0
Local aFiltrab				 := {}
Local aFilatu				 := {}
Local cFilTrab				 := ""
Local cEmpr					 := ""
Local cGo					 := ""

GetGlbVars("NPOSFIL", nPosTrab)
GetGlbVars("FILIALTAF", aFiltrab)
GetGlbVars("EMPRESA", cEmpr)
cFilTrab := aFiltrab[nPosTrab,1]
//Abre o ambiente
RpcSetType(3)  //Nao consome licensas
RpcSetEnv(cEmpr,cFilTrab) // //Abertura do ambiente em rotinas automáticas

BEGIN SEQUENCE	
	While !KillApp()
		GetGlbVars("THREADWAIT",cGo)
		//Caso a thread tenha entrado em wait no If abaixo verificamos se foi da Go nesta thread e carregamos as informações da nova filial a ser processada
		If cGo == "2"
			GetGlbVars("NPOSFIL", nPosTrab)
			PutGlbVars("THREADWAIT","")
			GetGlbVars("FILIALTAF", aFiltrab)
			cFilTrab := aFiltrab[nPosTrab,1]
			GlbUnLock()
		Endif			

		Sleep(nTempExec)
		//Verifica se tem registros a ser processados para esta filial
		nCount := BuscProcC20(cFilTrab)
		If nCount > 0
			AtuTabTafT(cFilTrab)
			//Atualiza array de filiais com '1' para indicar que iniciou o processamento para esta filial
			GetGlbVars("FILIALTAF", aFilatu)
			aFilatu[nPosTrab,2] := 1
			PutGlbVars( "FILIALTAF" , aFilatu )
			GlbUnLock()
			nFim := 0
		Else
			nFim += 1 
			If nFim == 3
				//Atualiza array de filiais com '2' para indicar que finalizou o processamento para esta filial
				GetGlbVars("FILIALTAF", aFilatu)
				aFilatu[nPosTrab,2] := 2 
				PutGlbVars( "FILIALTAF" , aFilatu )
				PutGlbVars("THREADWAIT","1")
				GlbUnLock()
				IPCWaitEx("THREADTAF1",nTimeOut)
			Endif
		Endif	
	ENDDO

RECOVER
	lErro	:= .T.

END SEQUENCE

ErrorBlock( bErrorBlock )

IF lErro
	conout(CHR(10)+CHR(13))
	conout('########## - FIM ERRO DE THREAD THREADTAF1 - ##########')	
	conout(CHR(10)+CHR(13))
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTabTafT

Função responsável por gravar as informações do ERP nas tabelas do TAF

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
function AtuTabTafT(cFilAnt)
Local cQuery    := ""
local lExeProc  := .F.
Local nStatus	:= 0
Local cFilExec	:= cFilAnt

Private lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .F.

lExeProc := TCSPExist("IntegraDocSped")

If !lExeProc
	cQuery   += "CREATE OR ALTER PROCEDURE IntegraDocSped " + CRLF
	cQuery   += "(	@FILIAL  char(08) )" + CRLF
	cQuery   += "AS" + CRLF
	cQuery   += "BEGIN" + CRLF
	cQuery   += "	declare @NUMDOC char(60);" + CRLF
	cQuery   += "	declare @SERIE  char(20);" + CRLF
	cQuery   += "	declare @OPER   char(01);" + CRLF
	cQuery   += "	declare @FORN   char(15);" + CRLF
	cQuery   += "	declare @LOJA   char(02);" + CRLF
	cQuery   += "	declare @CHVNF  char(36);" + CRLF
	cQuery   += "	declare @NUMITE INT"       + CRLF
	cQuery   += "	declare @CODMOD char(06)"  + CRLF
	cQuery   += "	declare @TIPO char(06)"    + CRLF
	cQuery   += "	declare @INDEMI CHAR(01)"  + CRLF
	cQuery   += "	declare @CODSIT char(06)"  + CRLF
	cQuery   += "	declare @EMISSAO char(08)" + CRLF
	cQuery   += "	declare @VLMERC float"     + CRLF
	cQuery   += "	declare @VLDOC float"      + CRLF
	cQuery   += "	declare @INDPAG char(01)"  + CRLF
	cQuery   += "	declare @INDFRT char(06)"  + CRLF
	cQuery   += "	declare @PRODUTO char(36);"+ CRLF
	cQuery   += "	declare @UM char(06);"     + CRLF
	cQuery   += "	declare @CLASFIS char(06);"+ CRLF
	cQuery   += "	declare @QUANT float;"     + CRLF
	cQuery   += "	declare @VLITEM float;"    + CRLF
	cQuery   += "	declare @TOTAL float;"     + CRLF
	cQuery   += "	declare @IDPROD char(36)"  + CRLF
	cQuery   += "	declare DADOS_C20 CURSOR FOR" + CRLF
	cQuery   += "		SELECT"                + CRLF
	cQuery   += "			C20.C20_FILIAL FILIAL,C20.C20_NUMDOC DOCUMENTO ,C20.C20_SERIE SERIE," + CRLF
	cQuery   += "			CASE WHEN C20.C20_INDOPE = '0' THEN 'E' ELSE 'S' END OPERACAO," + CRLF
	cQuery   += "			C20.C20_CLIFOR FORNECEDOR, " + CRLF
	cQuery   += "			C20.C20_LOJA LOJA, C20.C20_CHVNF " + CRLF
	cQuery   += "		FROM C20T10 C20" + CRLF
	cQuery   += "		WHERE C20.D_E_L_E_T_ = ' ' AND (C20.C20_STATUS = '1' OR C20.C20_STATUS = '2')" + CRLF
	cQuery   += "			AND C20.C20_FILIAL = @FILIAL" + CRLF
	cQuery   += "	open DADOS_C20;" + CRLF
	cQuery   += "	FETCH NEXT FROM DADOS_C20 INTO @FILIAL, @NUMDOC, @SERIE, @OPER, @FORN, @LOJA, @CHVNF ;" + CRLF
	cQuery   += "	SET @NUMITE = 0" + CRLF
	cQuery   += "	WHILE @@fetch_status = 0 BEGIN" + CRLF
	cQuery   += "		declare DADOS_SFT CURSOR FOR" + CRLF
	cQuery   += "			SELECT " + CRLF
	cQuery   += "				'000001' CODMOD," + CRLF
	cQuery   += "				CASE WHEN SFT.FT_TIPOMOV = 'E' THEN '0' ELSE '1' END FT_TIPOMOV," + CRLF
	cQuery   += "				CASE " + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO = 'D' THEN '000002' --'01'" + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO = 'I' THEN '000003' --'02'" + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO = 'P' THEN '000004' --'03'" + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO = 'C' THEN '000005' --'04'" + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO = 'B' THEN '000006' --'05'" + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO = 'S' THEN '000007' --'06'" + CRLF
	cQuery   += "					ELSE '000001' --00" + CRLF
	cQuery   += "				END FT_TIPODOC," + CRLF
	cQuery   += "				CASE WHEN SFT.FT_FORMUL = 'S' OR ( SFT.FT_FORMUL = ' ' AND SFT.FT_TIPOMOV = 'S' ) THEN '0' ELSE '1' END INDEMI," + CRLF
	cQuery   += "				SFT.FT_CLIEFOR,SFT.FT_LOJA,'000001' CODSIT,SFT.FT_EMISSAO," + CRLF
	cQuery   += "               CASE WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_VALMERC ELSE SF1.F1_VALMERC END VALMERC," + CRLF
	cQuery   += "               CASE WHEN SFT.FT_TIPOMOV = 'S' THEN SF2.F2_VALBRUT ELSE SF1.F1_VALBRUT END VALBRUT," + CRLF
	cQuery   += "               '9' INDPAG,'1' INDFRT,SFT.FT_PRODUTO,SB1.B1_UM," + CRLF
	cQuery   += "				CASE" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '0' THEN '000001'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '1' THEN '000002'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '2' THEN '000003'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '3' THEN '000004'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '4' THEN '000005'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '5' THEN '000006'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '6' THEN '000007'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '7' THEN '000008'" + CRLF
	cQuery   += "					WHEN LEFT(SFT.FT_CLASFIS,1) = '8' THEN '000009'" + CRLF
	cQuery   += "					ELSE '000001'" + CRLF
	cQuery   += "				END FT_CLASFIS,SFT.FT_QUANT," + CRLF
	cQuery   += "				CASE" + CRLF
	cQuery   += "					WHEN SFT.FT_TIPO IN ('I','P','C') THEN SFT.FT_TOTAL" + CRLF
	cQuery   += "					WHEN SFT.FT_PRCUNIT = ' ' THEN SFT.FT_TOTAL" + CRLF
	cQuery   += "					ELSE SFT.FT_PRCUNIT" + CRLF
	cQuery   += "				END VLRITEM," + CRLF
	cQuery   += "				SFT.FT_TOTAL, SFT.FT_PRODUTO" + CRLF
	cQuery   += "			FROM SFTT10 SFT" + CRLF
	cQuery   += "				INNER JOIN SB1T10 SB1 ON SB1.B1_FILIAL = @FILIAL AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery   += "				LEFT JOIN SF2T10 SF2 ON SFT.FT_TIPOMOV = 'S' AND SF2.F2_FILIAL = @FILIAL AND SF2.F2_DOC = SFT.FT_NFISCAL AND SF2.F2_SERIE = SFT.FT_SERIE AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND SF2.F2_LOJA = SFT.FT_LOJA AND SF2.D_E_L_E_T_ = ' '" + CRLF
	cQuery   +=	"				LEFT JOIN SF1T10 SF1 ON SFT.FT_TIPOMOV = 'E' AND SF1.F1_FILIAL = @FILIAL AND SF1.F1_DOC = SFT.FT_NFISCAL AND SF1.F1_SERIE = SFT.FT_SERIE AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND SF1.D_E_L_E_T_ = ' '" + CRLF					
	cQuery   += "			WHERE SFT.D_E_L_E_T_ = ' '" + CRLF
	cQuery   +=	"				AND SFT.FT_FILIAL = @FILIAL" + CRLF
	cQuery   += "				AND SFT.FT_NFISCAL = @NUMDOC"+ CRLF
	cQuery   += "				AND SFT.FT_SERIE = @SERIE"+ CRLF
	cQuery   += "				AND SFT.FT_TIPOMOV = @OPER"+ CRLF
	cQuery   += "				AND SFT.FT_CLIEFOR = @FORN"+ CRLF
	cQuery   += "				AND SFT.FT_LOJA = @LOJA;"+ CRLF
	cQuery   += "			OPEN DADOS_SFT;"+ CRLF
	cQuery   += "			FETCH NEXT FROM DADOS_SFT "+ CRLF
	cQuery   += "			INTO @CODMOD, @OPER, @TIPO, @INDEMI, @FORN, @LOJA, @CODSIT, @EMISSAO, @VLMERC, @VLDOC, @INDPAG, @INDFRT, @PRODUTO, @UM, @CLASFIS, @QUANT, @VLITEM, @TOTAL, @IDPROD"+ CRLF
	cQuery   += "			WHILE @@fetch_status = 0 BEGIN"+ CRLF
	cQuery   += "				SET @NUMITE = @NUMITE + 1"+ CRLF
	cQuery   += "				UPDATE C20T10 SET C20_CODMOD = @CODMOD, C20_TPDOC = @TIPO, C20_INDEMI = @INDEMI, C20_CODSIT = @CODSIT, C20_DTDOC = @EMISSAO,"+ CRLF
	cQuery   += "					C20_VLMERC = @VLMERC, C20_VLDOC = @VLDOC, C20_INDPAG = @INDPAG, C20_INDFRT = @INDFRT,  C20_STATUS = '3' "+ CRLF
	cQuery   += "				WHERE D_E_L_E_T_ = ' '"+ CRLF
	cQuery   += "					AND C20_FILIAL = @FILIAL"+ CRLF
	cQuery   += "					AND C20_CHVNF = @CHVNF"+ CRLF
	cQuery   += "				INSERT INTO C30T10 (C30_FILIAL, C30_CHVNF, C30_NUMITE, C30_CODITE, C30_UM, C30_ORIGEM, C30_QUANT, C30_VLRITE, C30_TOTAL ) "+ CRLF
	cQuery   += "					VALUES(@FILIAL, @CHVNF, @NUMITE, @IDPROD, @UM, @CLASFIS, @QUANT, @VLITEM, @TOTAL ) "+ CRLF
	cQuery   += "				FETCH NEXT FROM DADOS_SFT "+ CRLF
	cQuery   += "					INTO @CODMOD, @OPER, @TIPO, @INDEMI, @FORN, @LOJA, @CODSIT, @EMISSAO, @VLMERC, @VLDOC, @INDPAG, @INDFRT, @PRODUTO, @UM, @CLASFIS, @QUANT, @VLITEM, @TOTAL, @IDPROD	"+ CRLF
	cQuery   += "			END"+ CRLF
	cQuery   += "		CLOSE DADOS_SFT;"+ CRLF
	cQuery   += "		DEALLOCATE DADOS_SFT;"+ CRLF
	cQuery   += "		FETCH NEXT FROM DADOS_C20 INTO @FILIAL, @NUMDOC, @SERIE, @OPER, @FORN, @LOJA, @CHVNF ;		"+ CRLF
	cQuery   += "	END"+ CRLF
	cQuery   += "	CLOSE DADOS_C20;"+ CRLF
	cQuery   += "	DEALLOCATE DADOS_C20;"+ CRLF
	cQuery   += "END"
	nStatus := TcSqlExec(cQuery)
	If nStatus < 0
		conout("TCSQLError() " + TCSQLError())
	Else	
		lExeProc := .T.
	Endif	
Endif

If lExeProc
	TCSPEXEC("IntegraDocSped",cFilExec)
Endif	

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckThread

Função responsável retornar o número de Threads por Job

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function CheckThread(cAmb)
    Local aUserInfo 	:= {}
    Local aThreads  	:= {}
    Local nX        	:= 0

    // Retorna um array multidimensional com as informações de cada um do processos em execução
    aUserInfo := GetUserInfoArray()
    
    //Adiciona no Array quando for Thread do EFD Contribuições
	If cAmb == "THREADTAF"
		For nX := 1 to Len(aUserInfo)
			IF Upper(aUserInfo[nX][5]) == Upper(cAmb)
				Aadd(aThreads,aUserInfo[nX][3])
			Endif
		Next
	Else
		For nX := 1 to Len(aUserInfo)
			IF Upper(aUserInfo[nX][5]) == Upper(cAmb)
				Aadd(aThreads,aUserInfo[nX][3])
			Endif
		Next
	Endif	
aSize(aUserInfo,0) 
Return aThreads

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscProcC20

Função responsável retornar o número de registros a ser processados por filial

@author Adilson Roberto
@since 25/04/2023
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function BuscProcC20(cFilTrab)
Local cAliasChk     := GetNextAlias()
Local aCheck		:= {}
Local nRet			:= 0

If _cRetC20 == nil 
    _cRetC20 := "SELECT  COUNT(C20.C20_CHVNF) AS C20COUNT"
    _cRetC20 += " FROM " + RetSqlName('C20') + " C20"
    _cRetC20 += " WHERE C20.C20_FILIAL    = ?"
    _cRetC20 += " AND C20.C20_STATUS      = '1'"
	_cRetC20 += " AND C20.D_E_L_E_T_	  = ' '"
EndIf     
aCheck := {}
AADD(aCheck,cFilTrab)

If !Empty(_cRetC20) 
    dbUseArea(.T.,'TOPCONN',TcGenQry2(,,_cRetC20,aCheck),cAliasChk,.T.,.F.)  
	nRet := (cAliasChk)->C20COUNT 
Endif    
(cAliasChk)->(dbCloseArea())
Return(nRet)



