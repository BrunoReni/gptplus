// 浜様様様曜様様様様�
// � Versao � 03     �
// 藩様様様擁様様様様�
#Include "OFIOA350.ch"
#Include "Protheus.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIOA350 � Autor �  Andre Luis Almeida   � Data � 25/08/04 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Consulta Liberacoes de Verbas                              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOA350
Local aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
Private cFilSM0 := ( aSM0[2] +" - "+ Alltrim(aSM0[6]) +" "+ Alltrim(aSM0[5]) )
Private cChkVbs := "" // Checa Verba
Private lChkVbR := lChkVbA := lChkVbI := lChkVbL := lChkVbF := .f.  // Checa Verba
Private lAltera := .f. // Deixa Alterar campos somente os Usuarios nivel 3
cChkVbs := GetNewPar("MV_CHKVER","")
If "R" $ cChkVbs
	lChkVbR := .t.
EndIf
If "A" $ cChkVbs
	lChkVbA := .t.
EndIf
If "I" $ cChkVbs
	lChkVbI := .t.
EndIf
If "L" $ cChkVbs
	lChkVbL := .t.
EndIf
If "F" $ cChkVbs
	lChkVbF := .t.
EndIf
DbSelectArea("VAI")
DbSetOrder(4)
If DbSeek( xFilial("VAI") + __CUSERID )
	If left(VAI->VAI_NVERBA,1)=="*" .or. "3" $ VAI->VAI_NVERBA
		lAltera := .t.
	EndIf
EndIf
DEFINE MSDIALOG oVerb FROM 000,000 TO 012,050 TITLE STR0001 OF oMainWnd

// Checar Verba //
@ 030,005 TO 083,193 LABEL STR0002 OF oVerb PIXEL // Caixa Empresa / Sair
@ 039,014 CHECKBOX oChkVbR VAR lChkVbR PROMPT STR0003 OF oVerb ON CLICK FS_TIK() SIZE 125,08 PIXEL COLOR CLR_BLUE WHEN lAltera
@ 047,014 CHECKBOX oChkVbA VAR lChkVbA PROMPT STR0004 OF oVerb ON CLICK FS_TIK() SIZE 125,08 PIXEL COLOR CLR_BLUE WHEN lAltera
@ 055,014 CHECKBOX oChkVbI VAR lChkVbI PROMPT STR0005 OF oVerb ON CLICK FS_TIK() SIZE 125,08 PIXEL COLOR CLR_BLUE WHEN lAltera
@ 063,014 CHECKBOX oChkVbL VAR lChkVbL PROMPT STR0006 OF oVerb ON CLICK FS_TIK() SIZE 125,08 PIXEL COLOR CLR_BLUE WHEN lAltera
@ 071,014 CHECKBOX oChkVbF VAR lChkVbF PROMPT STR0007 OF oVerb ON CLICK FS_TIK() SIZE 125,08 PIXEL COLOR CLR_BLUE WHEN lAltera

// Empresa / Sair //
@ 013,010 SAY (STR0008+cFilSM0) SIZE 180,08 OF oVerb PIXEL COLOR CLR_BLUE
@ 012,138 BUTTON oSair PROMPT OemToAnsi(STR0009) OF oVerb SIZE 48,10 PIXEL ACTION (oVerb:End())
@ 005,005 TO 027,193 LABEL "" OF oVerb PIXEL // Caixa Empresa / Sair

ACTIVATE MSDIALOG oVerb CENTER

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � FS_TIK   � Autor �  Andre Luis Almeida   � Data � 25/08/04 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Verbas.						                              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_TIK()
cChkVbs := ""
cChkVbs += If(lChkVbR,"R/"," /")
cChkVbs += If(lChkVbA,"A/"," /")
cChkVbs += If(lChkVbI,"I/"," /")
cChkVbs += If(lChkVbL,"L/"," /")
cChkVbs += If(lChkVbF,"F/"," /")
If SX6->(DbSeek(xFilial("SX6")+"MV_CHKVER"))
	RecLock("SX6",.f.)
	SX6->X6_CONTEUD := cChkVbs
	SX6->X6_CONTSPA := cChkVbs
	SX6->X6_CONTENG := cChkVbs
	MsUnlock()
EndIf
Return()
