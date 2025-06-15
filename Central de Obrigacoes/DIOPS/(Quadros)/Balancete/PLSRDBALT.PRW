#Include "PROTHEUS.Ch"       
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 999,999,999,999.99"

STATIC oFnt09C 		:= TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt09L 		:= TFont():New("MS LineDraw Regular",09,09,,.F., , , , .t., .f.)
STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.F., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDBALT

Relatório do Balancete da DIOPS

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDBALT(lTodosQuadros,lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "Balancete"
	Local lResult   := .F.

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto         := .F.

	If !lTodosQuadros
		Private cPerg     := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cRelName := "DIOPS_Balancete_Trimestral_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		If !lAuto
			Pergunte(cPerg,.F.)			
		EndIf

		oReport := FWMSPrinter():New(cRelName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)
		If lAuto
			oReport:CFILENAME  := cRelName
			oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
		Else
			oReport:Setup()  //Tela de configurações
		EndIf
	
	Else
		nPagina	:= 0	// Já declarada PRIVATE na chamada de todos os quadros, necessário resetar a cada quadro
	EndIf

	Processa( {|| lResult := PLSDBALT() }, "DIOPS - Balancete Trimestral")

	// Se não há dados a apresentar
	If !lResult
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Balancete Trimestral')
		EndIf	
		Return
	EndIf 

	PlsRDCab(cCadastro)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTBALT() //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf	

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTBALT

@description Imprime Balancete Trimestral
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------

Static Function PRINTBALT(aValores)

	LOCAL lRet		:= .T.
	Local nLinha	:= 105
	Local nCol1		:= 020
	Local nCol2		:= 060
	Local nCol3		:= 440
	Local nCol4		:= 535
	Local nCol5		:= 625
	Local nCol6		:= 715
	Local cCadastro		:= "Balancete"

	oReport:Say(nLinha, nCol1, "Conta", oFnt11N)
	oReport:Say(nLinha, nCol2, "Descrição", oFnt11N)
	oReport:Say(nLinha, 460, "Saldo Anterior", oFnt11N)
	oReport:Say(nLinha, 570, "Débitos", oFnt11N)
	oReport:Say(nLinha, 655, "Créditos", oFnt11N)
	oReport:Say(nLinha, 750, "Saldo Final", oFnt11N)

	TRBBAL->(dbGoTop())
	Do While !TRBBAL->(Eof())

		nLinha += 15
		If nLinha >= 580
			oReport:EndPage()
			PlsRDCab(cCadastro)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105

			oReport:Say(nLinha, nCol1, "Conta", oFnt11N)
			oReport:Say(nLinha, nCol2, "Descrição", oFnt11N)
			oReport:Say(nLinha, 465, "Saldo Anterior", oFnt11N)
			oReport:Say(nLinha, 570, "Débitos", oFnt11N)
			oReport:Say(nLinha, 650, "Créditos", oFnt11N)
			oReport:Say(nLinha, 750, "Saldo Final", oFnt11N)
			nLinha += 15

		EndIf

		oReport:Say(nLinha, nCol1, TRBBAL->(B8A_CONTA), oFnt09C)			// Conta
		oReport:Say(nLinha, nCol2, SUBSTR(Posicione('B8B',1,xFilial('B8B')+TRBBAL->B8A_CODOPE+TRBBAL->B8A_CONTA,'B8B_DESCRI'),1,90), oFnt09C)			// Descrição

		oReport:Say(nLinha, nCol3, PadL(Transform(TRBBAL->B8A_SALANT, Moeda),20), oFnt09L)			// Saldo Anterior
		oReport:Say(nLinha, nCol4, PadL(Transform(TRBBAL->B8A_DEBITO, Moeda),20), oFnt09L)			// Débitos
		oReport:Say(nLinha, nCol5, PadL(Transform(TRBBAL->B8A_CREDIT, Moeda),20), oFnt09L)			// Créditos
		oReport:Say(nLinha, nCol6, PadL(Transform(TRBBAL->B8A_SALFIN, Moeda),20), oFnt09L)			// Saldo Final

		TRBBAL->(DbSkip())		

	EndDo

	TRBBAL->(DbCloseArea())

Return lRet

Static Function PLSDBALT()
	
	Local cSql 		:= ""
	Local lRet 		:= .F.

	cSql := " SELECT B8A_CODOPE, B8A_CONTA, B8A_SALANT, B8A_DEBITO, B8A_CREDIT, B8A_SALFIN "
	cSql += " FROM " + RetSqlName("B8A")
	cSql += " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
	cSql += " AND B8A_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8A_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8A_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8A_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8A_CONTA " 	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBAL",.F.,.T.)
	TcSetField("TRBBAL", "B8A_SALANT",  "N", 16, 2 )
	TcSetField("TRBBAL", "B8A_DEBITO",  "N", 16, 2 )
	TcSetField("TRBBAL", "B8A_CREDIT",  "N", 16, 2 )
	TcSetField("TRBBAL", "B8A_SALFIN",  "N", 16, 2 )

	If !TRBBAL->(Eof())
		lRet := .T.
	Else
		TRBBAL->(DbCloseArea())
	EndIf
	
Return( lRet )