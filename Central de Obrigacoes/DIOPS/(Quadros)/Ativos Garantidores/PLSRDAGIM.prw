#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt14C 		:= TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt14N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt14L 		:= TFont():New("MS LineDraw Regular",12,12,,.T., , , , .T., .F.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDAGIM

Relat�rio do Quadro Ativos Garantidores - Imobili�rio

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDAGIM(lTodosQuadros)
Local cCadastro		:= "DIOPS - Ativos Garantidores - Imobili�rio"
Local aResult		:= {}

DEFAULT lTodosQuadros	:= .F.

If !lTodosQuadros
	Private cPerg		:= "DIOPSINT"
	PRIVATE cTitulo 		:= cCadastro
	PRIVATE oReport     	:= nil
	PRIVATE cFileName		:= "DIOPS_Ativos_Garantidores_Imobiliario_"+CriaTrab(NIL,.F.)
	PRIVATE nPagina		:= 0		// J� declarada PRIVATE na chamada de todos os quadros

	Pergunte(cPerg,.F.)

	oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)
	oReport:setDevice(IMP_PDF)
	oReport:setResolution(72)
	oReport:SetLandscape()
	oReport:SetPaperSize(9)
	oReport:setMargin(10,10,10,10)
	oReport:Setup()  //Tela de configura��es

Else
	nPagina	:= 0	// J� declarada PRIVATE na chamada de todos os quadros, necess�rio resetar a cada quadro
		
EndIf


Processa( {|| aResult := PLSDAGIM() }, "DIOPS - Ativos Garantidores - Imobili�rio")

// Se n�o h� dados a apresentar
If !aResult[1]
	MsgAlert('N�o h� dados a apresentar referente a Ativos Garantidores - Imobili�rio')
	Return
EndIf 

lRet := PRINTAGIM(aResult[2]) //Recebe Resultado da Query e Monta Relat�rio 

If !lTodosQuadros .and. lRet
	oReport:EndPage()
	oReport:Print()
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTAGIM

@description Imprime Ativos Garantidores - Imobili�rio
@author Roger C
@since 17/01/18
@version P12
@return Logico - Imprimiu ou n�o.

/*/
//------------------------------------------------------------------
Static Function PRINTAGIM(aValores)

LOCAL lRet			:= .T.
Local nCtItemPg		:= 0 // Contador de Itens por P�gina
Local nItem			:= 0
Local nLin			:= 105
Local cTitulo 		:= "Ativos Garantidores (Imobili�rio)"
Local nTotal		:= 0
Local nCol          := 0

For nItem	:= 1 to Len(aValores)
	
	nCtItemPg ++
	If nCtItemPG > 23
		oReport:EndPage()
		nCtItemPG := 1
		nLin      := 0
	EndIf
	
	If nCtItemPg == 1 
		PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.
		nLin	:= 105
	EndIf
	If nItem = 1 .Or. nCtItemPG == 1
		oReport:Say(nLin, 220, "RGI", oFnt14N)
		oReport:Say(nLin, 460, "Rede Pr�pria", oFnt14N) 
		oReport:Say(nLin, 600, "Assistencial", oFnt14N) 
		oReport:Say(nLin, 720, "Valor Cont�bil", oFnt14N) 
		nLin += 20
	EndIf
	nCol :=20
	oReport:Say(nLin, nCol, aValores[nItem,1], oFnt14C)
	nCol :=485
	oReport:Say(nLin, nCol, IIf(aValores[nItem,2]=='0','N�o','Sim'), oFnt14C)
	nCol := 622
	oReport:Say(nLin, nCol, IIf(aValores[nItem,3]=='0','N�o','Sim'), oFnt14C)
	nCol := 670
	oReport:Say(nLin, nCol, Transform(aValores[nItem,4],Moeda), oFnt14L)
	  
	nTotal += aValores[nItem,4]
	nLin += 20
Next
oReport:Say(nLin+15, 023, "Total:", oFnt14N) 
oReport:Say(nLin+15, 695, PADL(Transform(nTotal,Moeda),20), oFnt14N)

Return lRet

Static Function PLSDAGIM()
Local nCount	:= 0
Local aRetAGIM	:= 	{ }	
Local cSql 		:= ""
Local lRet 		:= .T.

cSql := " SELECT B8C_CODRGI, B8C_REDPRO, B8C_ASSIST, B8C_VLRCON "
cSql += " FROM " + RetSqlName("B8C")
cSql += " WHERE B8C_FILIAL = '" + xFilial("B8C") + "' " 
cSql += " AND B8C_CODOPE = '" + B3D->B3D_CODOPE + "' "
cSql += " AND B8C_CODOBR = '" + B3D->B3D_CDOBRI + "' "
cSql += " AND B8C_ANOCMP = '" + B3D->B3D_ANO + "' "
cSql += " AND B8C_CDCOMP = '" + B3D->B3D_CODIGO + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY B8C_CODRGI, B8C_REDPRO " 	
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBAIM",.F.,.T.)
TcSetField("TRBAIM", "B8C_VLRCON",  "N", 16, 2 )

If !TRBAIM->(Eof())
	Do While !TRBAIM->(Eof())
		nCount++
		aAdd( aRetAGIM, { TRBAIM->B8C_CODRGI, TRBAIM->B8C_REDPRO, TRBAIM->B8C_ASSIST, TRBAIM->B8C_VLRCON } ) 			
		TRBAIM->(DbSkip())		

	EndDo

EndIf

TRBAIM->(DbCloseArea())
	
Return( { nCount>0 , aRetAGIM } )