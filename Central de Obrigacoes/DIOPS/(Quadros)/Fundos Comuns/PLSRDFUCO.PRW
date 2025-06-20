#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"
#Define FMT_OPERA "@R 99999-9"

STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",12,12,,.F., , , , .T., .F.)
STATIC oFnt12T 		:= TFont():New("MS LineDraw Regular",12,12,,.T., , , , .T., .F.)
STATIC oFnt09C 		:= TFont():New("Arial",09,09,,.f., , , , .t., .f.)
STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",14,14,,.t., , , , .t., .f.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSRDFUCO� Autor �Roger C                � Data �22/01/2018���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera��o de arquivo PDF. DIOPS - Distribui��o Saldos Pagar  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TOTVS - SIGAPLS			                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSRDFUCO(lTodosQuadros,lAuto)
Local cCadastro		:= "Fundos Comuns"
Local aResult		:= {}
DEFAULT lTodosQuadros	:= .F.
Default lAuto := .F.

If !lTodosQuadros
	Private cPerg		:= "DIOPSINT"
	PRIVATE cTitulo 		:= cCadastro
	PRIVATE oReport     	:= nil
	PRIVATE cFileName		:= "DIOPS_Fundos_Comuns_"+CriaTrab(NIL,.F.)
	PRIVATE nPagina		:= 0		// J� declarada PRIVATE na chamada de todos os quadros

	If !lAuto
		Pergunte(cPerg,.F.)
	EndIf

	oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,lAuto,.f.,.f.,!lAuto)	
	oReport:setDevice(IMP_PDF)
	oReport:setResolution(72)
	oReport:SetLandscape()
	oReport:SetPaperSize(9)
	oReport:setMargin(10,10,10,10)

	If lAuto
		oReport:CFILENAME := cFileName
		oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
	Else
		oReport:Setup()  //Tela de configura��es
	EndIf

Else
	cTitulo := cCadastro
	nPagina	:= 0	// J� declarada PRIVATE na chamada de todos os quadros, necess�rio resetar a cada quadro
		
EndIf

Processa( {|| aResult := PLSDFUCO() }, "DIOPS - Fundos Comuns")

// Se n�o h� dados a apresentar
If !aResult[1]
	If !lAuto
		MsgAlert('N�o h� dados a apresentar referente a Fundos Comuns')
	EndIf		
	Return
EndIf 


PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.

lRet := PRINTFUCO(aResult[2]) //Recebe Resultado da Query e Monta Relat�rio 

If !lTodosQuadros .and. lRet
	oReport:EndPage()
	oReport:Print()
EndIf

Return

Static Function PRINTFUCO(aValores)

LOCAL lRet		:= .T.
Local nI		:= 0
Local nLinha	:= 095
Local nSubCrd	:= 0
Local nTotCrd	:= 0
Local nSubDeb	:= 0
Local nTotDeb	:= 0
Local lLastTit	:= .F.
Local cLastTit	:= ''
Local cCombo	:= ''		// Controle da combina��o para subtotal e altera��o de cabe�alho
Local lFill		:= .T.
Local cTab      :="B6R"
Local lCpos     := (cTab)->(FieldPos("B6R_OPEPAR")) .And. (cTab)->(FieldPos("B6R_OPEADM"))

// B6R_OPEINT, B6R_NOME, B6R_VENCTO, B6R_TIPCOB, B6R_SALDO, B6R_TIPO 
For nI := 1 to Len(aValores)

	If nLinha+15 >= 615
		oReport:EndPage()
		PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.
		lLastTit := .F.			// For�a reimpress�o do cabe�alho			
		nLinha := 095
	EndIf
	
	If !lLastTit .or. cCombo <> aValores[nI,1]

		If nSubCrd+nSubDeb > 0 
			oReport:box(nLinha, 020, nLinha+15, 805)	//Box SubTotal
			nLinha += 10
			oReport:Say(nLinha, 400, "SubTotal", oFnt12N)  
			oReport:Say(nLinha, 500, PADL(Transform(nSubCrd, Moeda),20), oFnt12T)
			oReport:Say(nLinha, 650, PADL(Transform(nSubDeb, Moeda),20), oFnt12T)
			nSubCrd := 0
			nSubDeb := 0
			nLinha += 15
		EndIf

		If nLinha+55 >= 615
			oReport:EndPage()
			PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.			
			nLinha := 095
		EndIf
	 
		cCombo	:= aValores[nI,1]
		lLastTit:= .T.
		cLastTit:= IIf(aValores[nI,1]<>'FCP', 'Participa��es em Programas ou Fundos Comuns de Despesas de Assist�ncia M�dico-Hospitalar','Programas ou Fundos Comuns de Despesas Assist.M�dico-Hospitalar Administrados pela Operadora' ) 

				
		oReport:box(nLinha, 020, nLinha+20, 805)	//Box Titulo
		nLinha += 15

		If aValores[nI,1]<>'FCP'
			oReport:Say(nLinha, 160, cLastTit, oFnt14N)  
		Else
			oReport:Say(nLinha, 145, cLastTit, oFnt14N)  
		EndIf
	
		nLinha += 10

		oReport:box(nLinha, 020, nLinha+15, 805)	//Box Titulo das Colunas 
		nLinha += 10
		oReport:Say(nLinha, 025, IIF(aValores[nI,1]<>'FCP',"Reg. ANS Adm.","Reg.ANS OPS Partic."), oFnt12N)
		oReport:Say(nLinha, 150, "Denomina��o do Programa/Fundo", oFnt12N)
		oReport:Say(nLinha, 560, "Saldo Credor", oFnt12N)
		oReport:Say(nLinha, 710, "Saldo Devedor", oFnt12N)
		nLinha += 20
	
	EndIf
	
	If nLinha+15 >= 615
		oReport:EndPage()
		PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.
		lLastTit := .F.			// For�a reimpress�o do cabe�alho			
		nLinha := 105
	EndIf
			
	cCNPJ := IIF(lCpos,PADL(Transform(aValores[nI,6],FMT_OPERA),7),PADL(Transform(aValores[nI,2],FMT_OPERA),7))

	oReport:Say(nLinha, 025, cCNPJ, oFnt12C)		// Operadora
	oReport:Say(nLinha, 150, aValores[nI,3], oFnt12C)		// Nome
	oReport:Say(nLinha, 500, PADL(Transform(aValores[nI,4],Moeda),20), oFnt12L)		// Saldo Credor
	oReport:Say(nLinha, 650, PADL(Transform(aValores[nI,5],Moeda),20), oFnt12L)		// Saldo Devedor
	nLinha += 15
	nTotCrd += aValores[nI,4]
	nSubCrd += aValores[nI,4]
	nTotDeb += aValores[nI,5]
	nSubDeb += aValores[nI,5]
	
Next

If nSubDeb+nSubCrd > 0 .and. lLastTit
	If nLinha+30 > 615
		oReport:EndPage()
		PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.			
		nLinha := 095
	EndIf


	oReport:box(nLinha, 020, nLinha+15, 805)	//Box SubTotal
	nLinha += 10
	oReport:Say(nLinha, 400, "SubTotal", oFnt12N)  
	oReport:Say(nLinha, 500, PADL(Transform(nSubCrd, Moeda),20), oFnt12T)
	oReport:Say(nLinha, 650, PADL(Transform(nSubDeb, Moeda),20), oFnt12T)
	nSubCrd := 0
	nSubDeb := 0
	nLinha += 15
EndIf

If nTotDeb+nTotCrd > 0 .and. lLastTit
	If nLinha+30 > 615
		oReport:EndPage()
		PlsRDCab(cTitulo)		// Chama fun��o gen�rica que imprime cabe�alho e numera p�ginas, est� no fonte PLSRDIOPS.PRW.			
		nLinha := 095
	EndIf

	oReport:box(nLinha, 020, nLinha+15, 805)	//Box Total
	nLinha += 10
	oReport:Say(nLinha, 400, "Total", oFnt12N)  
	oReport:Say(nLinha, 500, PADL(Transform(nTotCrd, Moeda),20), oFnt12T)
	oReport:Say(nLinha, 650, PADL(Transform(nTotDeb, Moeda),20), oFnt12T)
EndIf

Return lRet



Static Function PLSDFUCO()
Local nCount	:= 0		
Local cSql 		:= ""
Local lRet 		:= .T.
Local aRetFUCO	:= {}
Local cTab      := "B6R"
Local lCpos     := (cTab)->(FieldPos("B6R_OPEPAR")) .And. (cTab)->(FieldPos("B6R_OPEADM"))

If	lCpos 
	cSql := " SELECT B6R_TIPO, B6R_OPEPAR, B6R_OPEADM, B6R_NOME, B6R_SLDCRD, B6R_SLDDEB,B6R_OPEPAR "
Else
	cSql := " SELECT B6R_TIPO,B6R_CNPJ,B6R_NOME, B6R_SLDCRD, B6R_SLDDEB "
EndIf
cSql += " FROM " + RetSqlName("B6R")
cSql += " WHERE B6R_FILIAL = '" + xFilial("B6R") + "' " 
cSql += " AND B6R_CODOPE = '" + B3D->B3D_CODOPE + "' "
cSql += " AND B6R_CODOBR = '" + B3D->B3D_CDOBRI + "' "
cSql += " AND B6R_ANOCMP = '" + B3D->B3D_ANO + "' "
cSql += " AND B6R_CDCOMP = '" + B3D->B3D_CODIGO + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY B6R_TIPO " 	
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBIEV",.F.,.T.)
TcSetField("TRBIEV", "B6R_SLDCRD",  "N", 16, 2 )
TcSetField("TRBIEV", "B6R_SLDDEB" , "N", 16, 2 )

If !TRBIEV->(Eof())
	Do While !TRBIEV->(Eof())
		nCount++
		If lCpos
			aAdd( aRetFUCO, { TRBIEV->B6R_TIPO, AllTrim(TRBIEV->B6R_OPEADM), TRBIEV->B6R_NOME, TRBIEV->B6R_SLDCRD, TRBIEV->B6R_SLDDEB,TRBIEV->B6R_OPEPAR } )
		Else
			aAdd( aRetFUCO, { TRBIEV->B6R_TIPO, TRBIEV->B6R_CNPJ,TRBIEV->B6R_NOME, TRBIEV->B6R_SLDCRD, TRBIEV->B6R_SLDDEB } )
		EndIf

		TRBIEV->(DbSkip())		
	EndDo
EndIf
TRBIEV->(DbCloseArea())
	
Return( { nCount>0 , aRetFUCO } )


