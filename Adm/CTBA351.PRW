#Include "PROTHEUS.CH"
#Include "CTBA351.CH"

#DEFINE D_PRELAN	"9"

STATIC __lBlind  := IsBlind()
STATIC __nThread := Nil

STATIC cSayCusto := Nil
STATIC cSayItem	 := Nil
STATIC cSayClVL	 := Nil
STATIC lAtSldBase
STATIC lCusto
STATIC lItem
STATIC lClVl
STATIC lCtb350Ef
STATIC lEfeLanc
STATIC lCT350TSL
Static lPE351Qry 	:= ExistBlock("CT351QRY")
Static _cQry351EFT	:= NIL
Static _cTmpShared  := NIL

/*-------------------------------------------------------------------------
Funcao		  : CTB351PROC
Autor         : Renato Campos / Alexandre TOSTA
Data          : 12/09/2016
Uso           : Efetua a validação dos dados do lançamento
-------------------------------------------------------------------------*/

Function CTB351PROC(lEnd, aMv_Par, cTbTmpShar, lImprRel)

Local cAliasTrb1
Local lSimula := .F. //(mv_par12==2)
Local cCTB240	:= IIF(FindFunction("GetSPName"), GetSPName("CTB240","07"), "CTB240")
Local nX
Local nProcess	:= 0
Local nD
Local cQueryInc := ""
Local cAliasInc := GetNextAlias()

Private aProcFilDt := {}

Default lEnd	:= .F.
Default aMv_Par	:= {}
Default cTbTmpShar := ""
Default lImprRel := .T.
Default lErro := .F.

_cTmpShared := cTbTmpShar

If Empty(aMv_Par)
	Pergunte( "CTB350" , .F. )
Else
	For nX := 1 TO Len(aMv_Par)
		&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
	Next
EndIf

lSimula := (mv_par12==2)

ProcRegua(1000)

//-- Verifica a quantidade de threads para o processamento.
__nThread   := GetNewPar( "MV_CT350TH", 1 )

lAtSldBase	:= ( GetMv("MV_ATUSAL") == "S" )
lCusto		:= CtbMovSaldo("CTT")
lItem 		:= CtbMovSaldo("CTD")
lClVl		:= CtbMovSaldo("CTH")
lCtb350Ef	:= ExistBlock("CTB350EF")
lEfeLanc 	:= ExistBlock("EFELANC")
lCT350TSL	:= GetNewPar( "MV_CT350SL", .T.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)

If !LockByName("CTB350ATHR1"+cEmpAnt+Alltrim(StrTran(cFilAnt," ", "_")),.F.,.F.)
	Help(" ",1,"CTB350ATHR1",,STR0001,1,0) //"Outro usuario está usando a rotina." 
	Return(.F.)
EndIf

//----------------------------------------------------------------------------------------------
// Nao processsa caso o parametro MV_CT350SL seja .T. e a procedure CTB240 nao esteja instalada
//----------------------------------------------------------------------------------------------
If lCT350TSL .And. !ExistProc(cCTB240,VerIDProc())
	Help(" ",1,"CTB351PROC",,STR0013,1,0) //"Para o processo de efetivação multithread (MV_CT350TH) com atualização de saldo (MV_CT350L), é necessária a instalação da Stored Procedure CTB240.SQL, presente no pacote p12_07.sps."
	Return(.F.)
EndIf

cAliasTrb1 := Ctb351Qry( "cTrb2", aMv_Par ) // envia agrupado por lote

If !Empty(cAliasTrb1) //Verificar
	// chama o processo de validação
	IncProc(STR0002) //"Iniciando validação dos dados via multi-thread."

	//Separa o processamento por filial e dias
	DbSelectArea(cAliasTrb1)
	DbGoTop()

	While (cAliasTrb1)->(!Eof())

		If Len(aProcFilDt) == 0
			Aadd( aProcFilDt , { (cAliasTrb1)->CT2_FILIAL, (cAliasTrb1)->CT2_DATA, (cAliasTrb1)->CT2_LOTE } )
			nProcess++
		ElseIf aProcFilDt[nProcess][1] <> (cAliasTrb1)->CT2_FILIAL .Or.  aProcFilDt[nProcess][2] <> (cAliasTrb1)->CT2_DATA .Or. aProcFilDt[nProcess][3] <> (cAliasTrb1)->CT2_LOTE
			Aadd( aProcFilDt , { (cAliasTrb1)->CT2_FILIAL, (cAliasTrb1)->CT2_DATA, (cAliasTrb1)->CT2_LOTE } )
			nProcess++
		EndIf
				
		(cAliasTrb1)->(DbSkip()) 
	EndDo	
	
	For nD := 1 To Len(aProcFilDt)
		If CTBA351VLD( cAliasTrb1, aMv_Par, lImprRel, aProcFilDt[nD]) .And. !lSimula

			// chama o processo de efetivação
			IncProc(STR0003) //"Iniciando efetivação dos dados via multi-thread."
		EndIf
	Next nD

	If _cTmpShared <> NIL .And. !Empty(_cTmpShared)

		If Select("TRB350REL") <= 0
			dbUseArea( .T., "TOPCONN", _cTmpShared, "TRB350REL", .F., .F. )
			TcRefresh("TRB350REL")
		Endif
					
		DbSelectArea("TRB350REL")
		DbGoTop()

		//query para ver se ocorreu alguma inconsistencia na xFilial("CT2") que foi processada
		cQueryInc := " SELECT CXFILCT2, DOC FROM "+_cTmpShared
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryInc),cAliasInc,.T.,.F.)

		If (cAliasInc)->( !Eof() )
			//------------------------------------
			// Imprime relatorio de consistencias
			//------------------------------------
			lErro := .T.
		ElseIf lSimula 
			lErro := .F.
			CT350GrInc(,,,,,,STR0004) //"Não foram encontrados erros."
		Endif
		//fecha alias da query e retorna para TRB350REL
		(cAliasInc)->( dbCloseArea() )
		DbSelectArea("TRB350REL")
		
		If lImprRel  
			If lSimula .OR. lErro
				If lSimula
					titulo+=" - " +STR0005 //"Modo Simulação."
				EndIf
					
				C350ImpRel()
		
			EndIf
		EndIf
	EndIf

Endif

If Select(cAliasTrb1) > 0
	DbSelectArea(cAliasTrb1)
	DbCloseArea()
Endif

//Destrava rotina após finalizar a execução das Threads
UnLockByName( "CTB350ATHR1"+cEmpAnt+Alltrim(StrTran(cFilAnt," ", "_")), .F. , .F. )

Return

/*-------------------------------------------------------------------------
Funcao		  : CTBA351VLD
Autor         : Renato Campos / Alexandre TOSTA
Data          : 12/09/2016
Uso           : Efetua a validação dos dados do lançamento
-------------------------------------------------------------------------*/
Static Function CTBA351VLD(cAliasTrb1, aMv_Par, lImprRel, aProcXFilD)
Local oGrid		:= Nil
Local lSimula	:= .F. //(mv_par12==2)
Local nX
Local nDocsTH
Local nRecMin
Local nRecMax

Private lErro		:= .F.
Private aRecGrid := {}
Private aRegMin
Private aRegMax

If Empty(aMv_Par)
	Pergunte( "CTB350" , .F. )
Else
	For nX := 1 TO Len(aMv_Par)
		&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
	Next
EndIf

lSimula	:= (mv_par12==2)

//Objeto do Controlador de Threads (Instancia para Execução das Threads)
oGrid := FWIPCWait():New("CTBA350"+cEmpAnt,2000)

//Inicia as Threads
oGrid:SetThreads(__nThread)

//Informa o Ambiente Para Execução da Thread
oGrid:SetEnvironment( cEmpAnt , cFilAnt )

//Função para ser executada na Thread
oGrid:Start("CT351VALID")
//Sleep(1000)

//Se der erro em alguma Thread sai imediatamente.	
oGrid:SetNoErrorStop(.T.)

DbSelectArea(cAliasTrb1)
DbGoTop()

aRecGrid := {}

While (cAliasTrb1)->(!Eof())

	If aProcXFilD[1] == (cAliasTrb1)->CT2_FILIAL .And. aProcXFilD[2] == (cAliasTrb1)->CT2_DATA .And. aProcXFilD[3] == (cAliasTrb1)->CT2_LOTE   		
		Aadd( aRecGrid , { (cAliasTrb1)->CT2_FILIAL, (cAliasTrb1)->CT2_DATA, (cAliasTrb1)->CT2_LOTE, (cAliasTrb1)->CT2_SBLOTE, (cAliasTrb1)->CT2_DOC } )
	EndIf
		
	(cAliasTrb1)->(DbSkip()) 
EndDo	

//Variavel para controle de Threads e Registros para processamento
nDocsTH := Round( Len(aRecGrid) / __nThread ,0)

nRecMin := 1
nRecMax := nDocsTH

If Len( aRecGrid ) > 0
	If Len( aRecGrid ) > __nThread .And. nDocsTH > __nThread

		For nX := 1 To __nThread
				
			aRegMin := aRecGrid[nRecMin]
			
			If nX == __nThread
				aRegMax := aRecGrid[Len(aRecGrid)]
			Else
				aRegMax := IIf(nDocsTH == 0, 1, aRecGrid[nRecMax])
			EndIf

			If nX != __nThread
				nRecMin := nRecMax + 1
				nRecMax += nDocsTH
			EndIf

			oGrid:Go( aRegMin, aRegMax , aMv_Par,aRegMin[1] )

		Next nX	
	Else
		aRegMin := aRecGrid[1]
		aRegMax := aRecGrid[Len(aRecGrid)]

		oGrid:Go( aRegMin, aRegMax, aMv_Par, aRegMin[1] )
	EndIf
EndIf

//Fechamento das Threads Iniciadas (O método aguarda o encerramentos de todas as Threads antes de retornar ao controle.
oGrid:Stop()

cError := oGrid:GetError()
FreeObj(oGrid)
oGrid := Nil

If !Empty(cError)
	Help(,,"Error",,cError,1,0)
	lErro := .T.
Endif
		
Return !lErro

/*-------------------------------------------------------------------------
Funcao		  : Ctb351Qry
Data          : 12/09/2016
Uso           : Monta e executa a criação do temporario de processamento.
-------------------------------------------------------------------------*/
Static Function Ctb351Qry( cTrb, aMv_Par )
Local cAliasQry := Criatrab(,.F.)
Local cQuery 	:= ""
Local cQryUser := ""
Local nX

If Empty(aMv_Par)
	Pergunte( "CTB350" , .F. )
Else
	For nX := 1 TO Len(aMv_Par)
		&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
	Next
EndIf

cQuery := " SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "
cQuery += "      , SUM( CT2_VALOR * CASE WHEN CT2_DC = '1' OR CT2_DC = '3' THEN 1 ELSE 0 END) VALORDEB"
cQuery += "      , SUM( CT2_VALOR * CASE WHEN CT2_DC = '2' OR CT2_DC = '3' THEN 1 ELSE 0 END) VALORCRD"
cQuery += "   FROM " + RetSqlName("CT2") + " CT2"
cQuery += "  WHERE  "

// Filial
If Empty(mv_par15) .And. Empty(mv_par16)
	cQuery += " CT2_FILIAL = '" + FWxFilial('CT2') + "' "
ElseIf Empty(mv_par15) .And. ! Empty(mv_par16)
	cQuery += " CT2_FILIAL >= '" + FWxFilial('CT2') + "' AND CT2_FILIAL <= '" + mv_par16 + "' "	
ElseIf !Empty(mv_par15) .And. Empty(mv_par16)
	cQuery += " CT2_FILIAL >= '" + mv_par15 + "' AND CT2_FILIAL <= '" + FWxFilial('CT2') + "' "	
Else
	cQuery += " CT2_FILIAL >= '" + mv_par15 + "' AND CT2_FILIAL <= '" + mv_par16 + "' "
EndIf
	
// Data
If mv_par03 == mv_par04
	cQuery += " AND CT2_DATA = '" + DTOS(mv_par03) + "' "
Else
	cQuery += " AND CT2_DATA >= '" + DTOS(mv_par03) + "' "
	cQuery += " AND CT2_DATA <= '" + DTOS(mv_par04) + "' "
Endif
	
// Lote
If ! Empty( mv_par01 ) .Or. ! Empty( mv_par02 )
	If ( mv_par01 == mv_par02 )
		cQuery += " AND CT2_LOTE = '" + mv_par01 + "' "
	Else
		If ! Empty( mv_par01 )
			cQuery += " AND CT2_LOTE >= '" + mv_par01 + "' "
		Endif
		
		If ! Empty( mv_par02 )
			cQuery += " AND CT2_LOTE <= '" + mv_par02 + "' "
		Endif
	Endif
Endif

// Sublote
If ! Empty( mv_par09 ) .Or. ! Empty( mv_par10 )
	If ( mv_par09 == mv_par10 )
		cQuery += " AND CT2_SBLOTE = '" + mv_par09 + "' "
	Else
		If ! Empty( mv_par09 )
			cQuery += " AND CT2_SBLOTE >= '" + mv_par09 + "' "
		Endif
		
		If ! Empty( mv_par10 )
			cQuery += " AND CT2_SBLOTE <= '" + mv_par10 + "' "
		Endif
	Endif
Endif
	
// Documento
If ! Empty( mv_par13 ) .Or. ! Empty( mv_par14 )
	If ( mv_par13 == mv_par14 )
		cQuery += " AND CT2_DOC = '" + mv_par13 + "' "
	Else
		If ! Empty( mv_par13 )
			cQuery += " AND CT2_DOC >= '" + mv_par13 + "' "
		Endif
		
		If ! Empty( mv_par14 )
			cQuery += " AND CT2_DOC <= '" + mv_par14 + "' "
		Endif
	Endif
Endif

cQuery += " AND CT2_TPSALD = '" + D_PRELAN + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC"
cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC"

If lPE351Qry
	cQryUser := ExecBlock("CT351QRY",.F.,.F.,{cQuery})
	If !Empty(cQryUser) //se ponto de entrada retornou string query preenchida
		cQuery := cQryUser	
	EndIf 	
EndIf

cQuery := ChangeQuery(cQuery)
	
If Select(cAliasQry) > 0
	dbSelectArea(cAliasQry)
	dbCloseArea()
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

If Select(cAliasQry) <= 0
	cAliasQry := ""
Else
	TcSetField(cAliasQry,"CT2_DATA","D",8,0)
	TcSetField(cAliasQry,"VALORDEB","N",17,2)
	TcSetField(cAliasQry,"VALORCRD","N",17,2)
Endif

Return cAliasQry

/*-------------------------------------------------------------------------
Funcao		  : Ct351Valid
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Efetua a validação das linhas dos lançamentos via multithread
-------------------------------------------------------------------------*/
Function CT351VALID( aRegMin, aRegMax, aMv_Par, cXFilial )

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local lEnd := .F.
Local aErroTexto 	:= {}
Local aErro:= {}
Local cTpSldAtu 	:= ""
Local lEfLote		:= .F.
Local lEfDoc		:= .F.
Local lMostraLct	:= .F.
Local lSimula		:= .F.
Local nX
Local lCTBA351

//variaveis utilizada no CTBA350
Private cFilCT2 := xFilial("CT2")
Private OPCAO	:= 3

Default aRegMin = {}
Default aRegMax = {}

cFilAnt := cXFilial

If Empty(aMv_Par)
	Pergunte( "CTB350" , .F. )
Else
	For nX := 1 TO Len(aMv_Par)
		&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
	Next
EndIf

cTpSldAtu 	:= mv_par07
lEfLote		:= Iif(mv_par05 == 1,.T.,.F.)//.T. ->Efetiva sem bater Lote / .F. ->Nao efetiva sem bater Lote
lEfDoc		:= Iif(mv_par06 == 1,.T.,.F.)//.T. ->Efetiva sem bater Doc / .F. ->Nao efetiva sem bater Doc
lMostraLct	:= ( mv_par11 == 1 )
lSimula		:= ( mv_par12 == 2 )

If cSayCusto == Nil 
	cSayCusto := CtbSayApro("CTT")
Endif

If cSayItem == Nil
	cSayItem	:= CtbSayApro("CTD")
Endif

IF cSayClVL == Nil
	cSayClVL	:= CtbSayApro("CTH")
Endif

aErroTexto := ct350aerro()

If Len(aRegMin) > 0 .And. Len(aRegMax) > 0

	lCTBA351 := .T.
	ct350roda( cXFilial, @lEnd,aErro,aErroTexto,cTpSldAtu,lEfLote,lEfDoc,lMostraLct,lSimula, .T., aRegMin, aRegMax)

	lRet := lEnd

EndIF

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea:= nil

Return lRet

/*-------------------------------------------------------------------------
Funcao		  : CtbSqlExec
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( STR0011 + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement ) //"Erro na instrução de execução do SQL"
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno

//--------------------------------------------------
/*/{Protheus.doc} VerIDProc
Controle de versao da procedure CTB240.

@author Totvs
@since 27/12/2017
@version P12.1.17

@return caracter, versao da procedure CTB240
/*/
//--------------------------------------------------
Static Function VerIDProc()
Return "010"
