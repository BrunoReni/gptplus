#Include "PROTHEUS.Ch"       
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10L 		:= TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
STATIC oFnt10T 		:= TFont():New("MS LineDraw Regular",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",12,12,,.t., , , , .t., .f.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDLCRP

Relat�rio de Lucros e Preju�zos

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDLCRP(lTodosQuadros,lAuto)

	Local aSays     := {}
	Local aButtons  := {}
	Local cCadastro := "DIOPS - LUCROS OU PREJU�ZOS"
	Local aResult   := {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.	

	If !lTodosQuadros
		
		Private cPerg		:= "DIOPSINT"
		PRIVATE cTitulo 	:= cCadastro
		PRIVATE oReport     := nil
		PRIVATE cRelName	:= "DIOPS_LCRP_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina		:= 0		// J� declarada PRIVATE na chamada de todos os quadros

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
			oReport:Setup()  //Tela de configura��es
		EndIf

	Else
		nPagina	:= 0	// J� declarada PRIVATE na chamada de todos os quadros, necess�rio resetar a cada quadro
	EndIf

	Processa( {|| aResult := PLSDLCRP() }, "DIOPS - LUCROS OU PREJU�ZOS")

	aResult:= PLSVERQRY(aResult[2])
	// Se n�o h� dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('N�o h� dados a apresentar referente a LUCROS OU PREJU�ZOS')			
		EndIf
		Return
	EndIf 

	cTitulo 	:= "Lucros ou Preju�zos"
	PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.

	lRet := PRINTLCRP(aResult[2]) //Recebe Resultado da Query e Monta Relat�rio 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTLCRP

@description Imprime LUCROS OU PREJU�ZOS
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou n�o.

/*/
//------------------------------------------------------------------

Static Function PRINTLCRP(aValores)

	LOCAL lRet		:= .T.
	Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro
	Local nLinha	:= 105
	Local nVez		:= 0
	Local nTotal	:= 0

	oReport:Fillrect( {nLinha, 020, nLinha+15, 805 }, oBrush1)	
	nLinha += 10	
	oReport:Say(nLinha, 030, "C�digo", oFnt11N)	
	oReport:Say(nLinha, 110, "Descri��o", oFnt11N)	
	oReport:Say(nLinha, 765, "Valor", oFnt11N)			

	For nVez := 1 to Len(aValores)
		nLinha += 15
		nTotal		+= aValores[nVez,2]
		oReport:Say(nLinha , 040, aValores[nVez,1], oFnt10L)			
		oReport:Say(nLinha , 700, PADL(Transform(aValores[nVez,2], Moeda),20), oFnt10L)
	Next	

	// Total
	nLinha += 5
	oReport:Fillrect( {nLinha, 020, nLinha+15, 805 }, oBrush1)		
	nLinha += 10
	oReport:Say(nLinha, 020, "TOTAL", oFnt11N)			
	oReport:Say(nLinha, 700, PADL(Transform(nTotal, Moeda),20), oFnt10T)

Return lRet

Static Function PLSDLCRP()

	Local cSql 		:= ""
	Local lRet 		:= .F.
	Local aResult	:= {}

	cSql := " SELECT B8E_DESCRI, B8E_VLRCON "
	cSql += " FROM " + RetSqlName("B8E")
	cSql += " WHERE B8E_FILIAL = '" + xFilial("B8E") + "' " 
	cSql += " AND B8E_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B8E_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B8E_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B8E_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8E_DESCRI "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBLCR",.F.,.T.)
	TcSetField("TRBLCR", "B8E_VLRCON", 	"N", 16, 2 )

	TRBLCR->(dbGoTop())
	If !TRBLCR->(Eof())
		lRet := .T.
		While !TRBLCR->(Eof())

			If Alltrim(TRBLCR->B8E_DESCRI) == "1"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Lucros distribuidos (-)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			ElseIf Alltrim(TRBLCR->B8E_DESCRI) == "2"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Constitui��o de reservas (-)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			ElseIf Alltrim(TRBLCR->B8E_DESCRI) == "3"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Revers�o de reservas (+)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			ElseIf Alltrim(TRBLCR->B8E_DESCRI) == "5"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Juros sobre capital pr�prio (-)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			ElseIf Alltrim(TRBLCR->B8E_DESCRI) == "6"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Ajustes de exerc�cios anteriores (com sinal)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			ElseIf Alltrim(TRBLCR->B8E_DESCRI) == "7"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Lucro incorporado ao capital (-)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			ElseIf Alltrim(TRBLCR->B8E_DESCRI) == "8"
				aAdd(aResult, { TRBLCR->B8E_DESCRI +"              Outros (com sinal)", TRBLCR->B8E_VLRCON  } )
				TRBLCR->(dbSkip())
			Else
				TRBLCR->(dbSkip())
			EndIf
		EndDo
	EndIf

	TRBLCR->(DbCloseArea())
	
Return( { lRet, aResult } )


//------------------------------------------------------------------
/*/{Protheus.doc} PLSVERQRY

@description Imprime as informa��es com zero caso n�o encontre o valor
@since 16/07/2019
/*/
//------------------------------------------------------------------
Static Function PLSVERQRY(aRes)

	Local aResult := {}  
	Local nI      := 0
	Local lRet    := .T.
	Local nJ      := 0
	Default aRes  := {}

	aAdd(aResult, {"1" +"              Lucros distribuidos (-)", 0 } )
	aAdd(aResult, {"2" +"              Constitui��o de reservas (-)", 0  } )
	aAdd(aResult, {"3" +"              Revers�o de reservas (+)", 0  } )
	aAdd(aResult, {"5" +"              Juros sobre capital pr�prio (-)", 0  } )
	aAdd(aResult, {"6" +"              Ajustes de exerc�cios anteriores (com sinal)", 0  } )
	aAdd(aResult, {"7" +"              Lucro incorporado ao capital (-)", 0 } )
	aAdd(aResult, {"8" +"              Outros (com sinal)", 0 } )

	For nI:=1 To Len(aResult)                  
		For nJ:=1 To Len(aRes) 
			If Substr(aResult[nI,1],1,1) == Substr(aRes[nJ,1],1,1) 
				aResult[nI,2]:=aRes[nJ,2]
			EndIf					   			
		Next
	Next

Return({lRet,aClone(aResult)})

