#INCLUDE "HSPAHA97.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHACJ  � Autor � Saude		         � Data �  01/12/10   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE DISPONIBILIDADE CLINICA                        ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������

/*/
Function HSPAHACJ()
Private aRotina   := {{OemtoAnsi(STR0001 ), "axPesqui", 0, 1}, ;  //"Pesquisar"
{OemtoAnsi(STR0002 ), "HS_ACJ",   0, 2}, ;  //"Visualizar"
{OemtoAnsi(STR0003 ), "HS_ACJ",   0, 3}, ;  //"Incluir"
{OemtoAnsi(STR0004 ), "HS_ACJ",   0, 4}, ;  //"Alterar"
{OemtoAnsi(STR0005 ), "HS_ACJ",   0, 5}}    //"Excluir"


mBrowse(06, 01, 22, 75, "GM6")
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | HS_ACJ   � Autor � PAULO JOSE         � Data � 16/11/04    ���
�������������������������������������������������������������������������͹��
���Descricao � Manutecao de Disponibilide Medica                          ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar  (Agenda Ambulatorial)                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HS_ACJ(cAlias, nReg, nOpc)

Local nCntFor := 0
Local nOpcA := 0, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local bFS_Facili	:= {||FS_FACILI()} // Facilitador para inclusao dos relacionamentos
Local aButtons := {}, bKeyF12, aJoin := {}

Private nGM5_DIASEM := 0, nGM5_IDEATI := 0, nLINGM5 := 0
Private nGMK_ITEDIA := 0, nGMK_DIASEM := 0, nGMK_HORINI := 0, nGMK_HORFIN := 0, nLINGMK := 0
Private nGM4_CODLOC := 0, nGM4_CODPLA := 0, nGM4_DESPLA := 0, nGM4_IDEATI := 0, nLINGM4 := 0
Private nGM3_CODLOC := 0, nGM3_CODPRO := 0, nGM3_DESPRO := 0, nGM3_IDEATI := 0, nLINGM3 := 0
Private oGM5, aHGM5 := {}, aCGM5 := {}, nUGM5 := 0
Private oGM4, aHGM4 := {}, aCGM4 := {}, nUGM4 := 0
Private oGMK, aHGMK := {}, aCGMK := {}, nUGMK := 0
Private oGM3, aHGM3 := {}, aCGM3 := {}, nUGM3 := 0, aCGM3W  := {}, nUGM3W := 0
Private oFolder, pForACols := 0
Private aTela := {}, aGets := {}
Private cGcsTipLoc := "J"  //Tipo de Local utilizado no filtro da consulta padrao GCS. Tem que ser com este nome de variavel.
Private cGcsCodLoc := ""   //Codigo do setor a ser selecionado no filtro dos procedimentos por setor (GM2) - HS_FilGm2()
Private __cCodSal  := ""   //Codigo da sala a ser selecionado no filtro dos recursos por sala (GO2) - HS_FilGO2()

//���������������������������������������Ŀ
//� Inclusao dos botoes dos facilitadores �
//�����������������������������������������
Aadd(aButtons, {'PARAMETROS', {||Eval(bFS_Facili)}, STR0028, STR0052}) //"Facilitador p/ inclus�o de itens no relacionamento"###"Itens"
bKeyF4 := SetKey(VK_F4, { || Eval(bFS_Facili)})

// Cria as Variaveis de Memoria do GM6
RegToMemory(cAlias, nOpc == 3)

// Inicializa os vetores do MsNewGetDados GM5
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GM5->GM5_CODDIS", Nil)
nLINGM5 := HS_BDados("GM5", @aHGM5, @aCGM5, @nUGM5, 1,, cCond )
nGM5_DIASEM := aScan(aHGM5, {| aVet | aVet[2] == "GM5_DIASEM"})
nLINGM5 := (IIf(Len(aCGM5) == 1 .And. Empty(aCGM5[1, nGM5_DIASEM]), 0, Len(aCGM5) ))

// Inicializa os vetores do MsNewGetDados GM4 - Disponibilidade / Planos Nao Atendidos
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GM4->GM4_CODDIS", Nil)
aJoin := {{" LEFT JOIN " + RetSqlName("GCM") + " GCM ", "GCM.GCM_DESPLA" , "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GM4.GM4_CODPLA ", "GM4_DESPLA"}}

nLINGM4 := HS_BDados("GM4", @aHGM4, @aCGM4, @nUGM4, 1,, cCond,,,,,,,,,,,, .T.,,,, aJoin)
nGM4_CODPLA := aScan(aHGM4, {| aVet | aVet[2] == "GM4_CODPLA"})
nGM4_DESPLA := aScan(aHGM4, {| aVet | aVet[2] == "GM4_DESPLA"})
nGM4_CODLOC := aScan(aHGM4, {| aVet | aVet[2] == "GM4_CODLOC"})
nLINGM4 := (IIf(Len(aCGM4) == 1 .And. Empty(aCGM4[1, nGM4_CODPLA]), 0, Len(aCGM4) ))

cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GM3->GM3_CODDIS", Nil)
aJoin := {{" LEFT JOIN " + RetSqlName("GA7") + " GA7 ", "GA7.GA7_DESC", "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GM3.GM3_CODPRO ", "GM3_DESPRO"}}

nLINGM3 := HS_BDados("GM3", @aHGM3, @aCGM3, @nUGM3, 1,, cCond,,,,,,,,,,,, .T.,,,, aJoin)
nGM3_CODLOC := aScan(aHGM3, {| aVet | aVet[2] == "GM3_CODLOC"})
nGM3_CODPRO := aScan(aHGM3, {| aVet | aVet[2] == "GM3_CODPRO"})
nGM3_DESPRO := aScan(aHGM3, {| aVet | aVet[2] == "GM3_DESPRO"})
nLINGM3 := (IIf(Len(aCGM3) == 1 .And. Empty(aCGM3[1, nGM3_CODPRO]), 0, Len(aCGM3)))

// Inicializa os vetores do MsNewGetDados GMK
cCond := IIf(nOpc # 3, "'" + M->GM6_CODDIS + "' == GMK->GMK_CODDIS", Nil)
nLINGMK := HS_BDados("GMK", @aHGMK, @aCGMK, @nUGMK, 1, M->GM6_CODDIS, cCond,,,,,"GMK_CODREC" )
nGMK_ITEDIA := aScan(aHGMK, {| aVet | aVet[2] == "GMK_ITEDIA"})
nGMK_DIASEM := aScan(aHGMK, {| aVet | aVet[2] == "GMK_DIASEM"})
nGMK_HORINI := aScan(aHGMK, {| aVet | aVet[2] == "GMK_HORINI"})
nGMK_HORFIN := aScan(aHGMK, {| aVet | aVet[2] == "GMK_HORFIN"})
If Empty(aCGMK[1, nGMK_ITEDIA])
	aCGMK[1, nGMK_ITEDIA]	:= StrZero(1, Len(aCGMK[1, nGMK_ITEDIA]))
Endif
nLINGMK := (IIf(Len(aCGMK) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(aCGMK)))

If Inclui
	aHGM3W := aClone(aHGM3)
	aCGM3W := aClone(aCGM3)
ElseIf Altera
	cGcsCodLoc := GM6->GM6_CODLOC
EndIf

 __cCodSal := GM6->GM6_CODSAL

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd(aObjects, {100, 050, .T., .T.})
AAdd(aObjects, {100, 050, .T., .T.})

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6]+25,aSize[5]	PIXEL of oMainWnd //"Disponibilidade M�dica"

oEnchoi:= MsMGet():New(cAlias, nReg, nOpc,,,,,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oEnchoi:oBox:Align := CONTROL_ALIGN_TOP

@ 120, 000 FOLDER oFolder SIZE 317, 117 OF oDlg PROMPTS STR0007, STR0008, STR0009, STR0059 PIXEL //"Dia da Semana"###"Planos n�o Atendidos"###"Procedimentos"###"Per�odos Indispon�veis"
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

oGM5 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , , , , , , , , , oFolder:aDialogs[1], aHGM5, aCGM5)
oGM5:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGM4 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , , , , , , , , , oFolder:aDialogs[2], aHGM4, aCGM4)
oGM4:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGM3 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , , , , , , , , , oFolder:aDialogs[3], aHGM3, aCGM3)
oGM3:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

oGMK := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, , ,"+GMK_ITEDIA", , , , , , , oFolder:aDialogs[4], aHGMK, aCGMK)
oGMK:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
nOpcA := 0
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And. HS_TUDOOK("GM5",	 oGM5, nGM5_DIASEM) ;
.And. HS_TUDOOK("GM4", oGM4, nGM4_CODPLA) 	.And. HS_TUDOOK("GM3", oGM3, nGM3_CODPRO) .And. ;
HS_TUDOOK("GMK", oGMK, nGMK_DIASEM) .And. ;
FS_VLCols(aCGM5, aCGM3, nOpc) .And. FS_VldDisp(), ;
oDlg:End(), 	nOpcA := 0)},  ;
{|| nOpcA := 0, oDlg:End()},, aButtons)

SetKey(VK_F4, bKeyF4)

If nOpca == 1
	FS_GrvACJ(nOpc)
Else
	While __lSx8
		RollBackSx8()
	End
EndIf

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldACJ � Autor � Paulo Jose         � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao �  Valida os campos                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar (Agenda Ambulatorial)                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_VldACJ()

Local lRet     := .T., nPos := 0, nForACols := 0, cAliasOld := Alias()
Local nLinTGM4 := 0
Local nLinTGM3 := 0
Local nLinTGMK := 0

//Valida dia da Semana
If ReadVar() == "M->GM5_DIASEM"

	If M->GM5_DIASEM $ "12345678"

		nPos := aScan(oGM5:aCols, {| aVet | aVet[nGm5_DIASEM] == M->GM5_DIASEM})
		If nPos > 0 .And. nPos # oGM5:oBrowse:nAt
			HS_MsgInf(STR0010, STR0011, STR0053) //"Dia da Semana j� cadastrado"###"Aten��o"###"Valida��o dos Campos"
			lRet := .F.
		EndIf

	Else

		HS_MsgInf(STR0012, STR0011, STR0053) //"Dia da Semana Inv�lido"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.

	EndIf
ElseIf ReadVar() == "M->GM6_CODSAL"
	If !(lRet := HS_SeekRet("GF3","M->GM6_CODSAL",1,.f.,"GM6_NOMSAL","GF3_DESCRI"))
		HS_MsgInf("Sala inv�lida", STR0011, STR0053) //Aten��o"###"Valida��o dos Campos"
	EndIf
ElseIf ReadVar() == "M->GMK_DIASEM"

	If !M->GMK_DIASEM $ "12345678"
		HS_MsgInf(STR0012, STR0011, STR0053) //"Dia da Semana Inv�lido"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	ElseIf 	(nPos := aScan(oGM5:aCols, {| aVet | aVet[nGM5_DIASEM] == M->GMK_DIASEM})) == 0
		HS_MsgInf(STR0060, STR0011, STR0053) //"Dia da Semana n�o cadastrado na aba Dia da Semana"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf

ElseIf ReadVar() == "M->GMK_HORINI"

	If M->GMK_HORINI < M->GM6_HORINI
		HS_MsgInf(STR0061, STR0011, STR0053) //"Hor�rio n�o pode ser menor que o hor�rio inicial da disponibilidade"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	ElseIf M->GMK_HORINI == M->GM6_HORINI .And. oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorFin] == M->GM6_HORFIM
		HS_MsgInf(STR0062, STR0011, STR0053) //"Hor�rios inicial/final iguais aos hor�rios da disponibilidade"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	ElseIf M->GMK_HORINI > M->GM6_HORFIM
		HS_MsgInf(STR0063, STR0011, STR0053) //"Hor�rios inicial n�o pode ser maior que o hor�rio final da disponibilidade"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf

	If lRet
		nLinTGMK := IIf ( Len(aCGMK) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(aCGMK) )
		For nForACols := 1 To nLinTGMK
			If nForACols # oGMK:oBrowse:nAt .And. oGMK:aCols[nForACols, nGMK_DiaSem] == oGMK:aCols[oGMK:oBrowse:nAt, nGMK_DiaSem] .And. !oGMK:aCols[nForACols, nUGMK + 1] .And. ;
				(M->GMK_HORINI >= oGMK:aCols[nForACols, nGMK_HorIni] .And. M->GMK_HORINI <= oGMK:aCols[nForACols, nGMK_HorFin] .Or. ;
				(M->GMK_HORINI < oGMK:aCols[nForACols, nGMK_HorIni] .And. oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorFin] >= oGMK:aCols[nForACols, nGMK_HorIni]))
				HS_MsgInf(STR0064, STR0011, STR0053) //"Per�odo coincidente com os per�odos j� cadastrados para esse dia"###"Aten��o"###"Valida��o dos Campos"
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf

ElseIf ReadVar() == "M->GMK_HORFIN"

	If M->GMK_HORFIN > M->GM6_HORFIM
		HS_MsgInf(STR0065, STR0011, STR0053) //"Hor�rio n�o pode ser maior que o hor�rio final da disponibilidade"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	ElseIf oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorIni] == M->GM6_HORINI .And.  M->GMK_HORFIN == M->GM6_HORFIM
		HS_MsgInf(STR0062, STR0011, STR0053) //"Hor�rios inicial/final iguais aos hor�rios da disponibilidade"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	ElseIf M->GMK_HORFIN < M->GM6_HORINI
		HS_MsgInf(STR0066, STR0011, STR0053) //"Hor�rios final n�o pode ser menor que o hor�rio inicial da disponibilidade"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf

	If lRet
		nLinTGMK := IIf(Len(aCGMK) == 1 .And. Empty(aCGMK[1, nGMK_DIASEM]), 0, Len(aCGMK))
		For nForACols := 1 To nLinTGMK
			If nForACols # oGMK:oBrowse:nAt .And. oGMK:aCols[nForACols, nGMK_DiaSem] == oGMK:aCols[oGMK:oBrowse:nAt, nGMK_DiaSem] .And. !oGMK:aCols[nForACols, nUGMK + 1] .And. ;
				(M->GMK_HORFIN <= oGMK:aCols[nForACols, nGMK_HorFin] .And. M->GMK_HORFIN >= oGMK:aCols[nForACols, nGMK_HorIni] .Or. ;
				(M->GMK_HORFIN > oGMK:aCols[nForACols, nGMK_HorFin] .And. oGMK:aCols[oGMK:oBrowse:nAt, nGMK_HorIni] <= oGMK:aCols[nForACols, nGMK_HorFin]))
				HS_MsgInf(STR0064, STR0011, STR0053) //"Per�odo coincidente com os per�odos j� cadastrados para esse dia"###"Aten��o"###"Valida��o dos Campos"
				lRet := .F.
				Exit
			EndIf
		Next
	EndIf

ElseIf ReadVar() == "M->GM6_IDEATI"
	If M->GM6_IDEATI == "1" .And. !Inclui
		DbSelectArea("GM2")
		DBSetOrder(1) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
		nLinTGM3 := IIf(Len(aCGM3) == 1 .And. Empty(aCGM3[1, nGM3_CODPRO]), 0, Len(aCGM3))
		For nForACols := 1 To nLinTGM3

			If !DbSeek(xFilial("GM2") + M->GM6_CODLOC + oGM3:aCols[nForACols, nGM3_CODPRO])
				HS_MsgInf(STR0013 + oGM3:aCols[nForACols, nGM3_CODPRO] + "/" + oGM3:aCols[nForACols, nGM3_DESPRO] + STR0014, STR0011, STR0009)  //"O Procedimento ("###") n�o est� cadastrado em Setor x Procedimento"###"Aten��o"###"Procedimentos"
				lRet := .F.
			EndIf
		Next

		DbSelectArea("GCM")
		DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
		nLinTGM4 := IIf(Len(aCGM4) == 1 .And. Empty(aCGM4[1, nGM4_CODPLA]), 0, Len(aCGM4) )
		For nForACols := 1 To nLinTGM4

			If !DbSeek(xFilial("GCM") + oGM4:aCols[nForACols, nGM4_CODPLA])
				HS_MsgInf(STR0015 + Trim(oGM4:aCols[nForACols, nGM4_CODPLA] + "/" + oGM4:aCols[nForACols, nGM4_DESPLA]) + STR0016, STR0011, STR0053) //"O plano ("###") n�o est� cadastrado em Plano"###"Aten��o"###"Valida��o dos Campos"
				lRet := .F.
			EndIf

		Next
	EndIf

	//Valida Disponibilidade Medica
ElseIf ReadVar() == "M->GM6_CODLOC"
	If !HS_SeekRet("GCS", "M->GM6_CODLOC", 1, .F., "GM6_NOMLOC", "GCS_NOMLOC",,, .T.)
		HS_MsgInf(STR0017, STR0011, STR0053) //"Setor inv�lido"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	Else
		If GCS->GCS_TIPLOC <> "1" .AND. GCS->GCS_TIPLOC <> "J"
			HS_MsgInf(STR0073, STR0011, STR0053)//"Setor inv�lido. Utilize um setor do tipo Atend. Clinica"###"Aten��o"###"Valida��o dos Campos"
			lRet := .F.
		Else
			cGcsCodLoc := GCS->GCS_CODLOC
			If Inclui
				aHGM3 := aClone(aHGM3W)
				aCGM3 := aClone(aCGM3W)
				oGM3:aCols := aClone(aCGM3)
				oGM3:Refresh()
			EndIf
		EndIf
	EndIf

	//VALIDA LIBERA��O DE DISPONIBILIDADE
ElseIf ReadVar() == "M->GM6_CODCRM"
	If !HS_SeekRet("SRA", "M->GM6_CODCRM", 11, .F., "GM6_NOMCRM", "RA_NOME",,, .T.)
		HS_MsgInf(STR0018, STR0011, STR0053) //"CRM do M�dico inv�lido"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	Else
		If !(HS_IniPadr("GBJ", 1, M->GM6_CODCRM, "GBJ_IDAGEN",, .F.) $ "0/2" )
			HS_MsgInf(STR0038, STR0011, STR0053)  //"CRM do M�dico Inv�lido! M�dico N�o Habilitado para Incluir uma Disponibilidade"###"Aten��o"###"Valida��o dos Campos"
			lRet := .F.
		EndIf
	EndIf
ElseIf ReadVar() == "M->GM6_HORINI"
	If !FS_VldHACJ(M->GM6_HORINI)
		HS_MsgInf(STR0019, STR0011, STR0053)  //"Hora inicial inv�lida"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf
ElseIf ReadVar() == "M->GM6_HORFIM"
	If !FS_VldHACJ(M->GM6_HORFIM)
		HS_MsgInf(STR0020, STR0011, STR0053)  //"Hora final inv�lida"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	ElseIf (M->GM6_HORFIM < M->GM6_HORINI)
		HS_MsgInf(STR0021, STR0011, STR0053)  //"Hora final menor que hora inicial."###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf
ElseIf ReadVar() == "M->GM6_HORENC"
	If M->GM6_HORENC <> "  :  " .And. (Empty(M->GM6_HORFIM) .Or. Empty(M->GM6_HORINI))
		HS_MsgInf(STR0067, STR0011, STR0053)  //"Digite as horas inicial e final"###"Atencao"###"valida��o dos Campos"
		lRet := .F.
	ElseIf M->GM6_HORENC <> "  :  " .And. !FS_VldHACJ(M->GM6_HORENC)
		HS_MsgInf(STR0068, STR0011, STR0053)  //"Hora limite para encaixe inv�lida"###"Atencao"###"valida��o dos Campos"
		lRet := .F.
	ElseIf M->GM6_HORENC <> "  :  " .And. (M->GM6_HORENC < M->GM6_HORINI .Or. M->GM6_HORENC > M->GM6_HORFIM)
		HS_MsgInf(STR0069, STR0011, STR0053)  //"O limite para encaixe deve ser um hor�rio entre o intervalo das horas inicial e final"###"Atencao"###"valida��o dos Campos"
		lRet := .F.
	EndIf
ElseIf ReadVar() == "M->GM6_INTMAR"
	If !FS_VldHACJ(M->GM6_INTMAR)
		HS_MsgInf(STR0022, STR0011, STR0053)  //"Intervalo de marca��o inv�lido"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf

	If !FS_VLHA97B(M->GM6_HORINI, M->GM6_HORFIM, M->GM6_INTMAR)
		HS_MsgInf(STR0022, STR0011, STR0053)  //"Intervalo de marca��o inv�lido"###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	EndIf

	// Foi definido nao fazer consistencia com o arquivo GM0-Setor X Plano nao atendido, permitindo que se
	// inclua planos para a disponibildade independente do setor. Esta verificacao sera feita pela rotina de
	// marcacao
Elseif ReadVar() == "M->GM4_CODPLA"																			// Valida Disp. x Planos Nao Atendidos
	If !HS_SeekRet("GCM", "M->GM4_CODPLA", 2, .F.,,,,, .T.)
		HS_MsgInf(STR0023, STR0024, STR0053) //"Plano inv�lido"###"Verifique"###"Valida��o dos Campos"
		lRet := .F.
	Else
		GDFieldPut("GM4_DESPLA", HS_IniPadr("GCM", 2, M->GM4_CODPLA, "GCM_DESPLA",, .F.))
		nPos := aScan(oGM4:aCols, {| aVet | aVet[nGM4_CodPla] == M->GM4_CODPLA})
		If nPos > 0 .And. nPos # oGM4:oBrowse:nAt  // Verifica se este Plano ja foi cadastrado para a disponibilidade
			HS_MsgInf(STR0025, STR0011, STR0053) //"Plano j� cadastrado para este setor"###"Aten��o"###"Valida��o dos Campos"
			lRet := .F.
		EndIf
	EndIf

ElseIf ReadVar() == "M->GM3_CODPRO"									//Valida Disp. / Procedimentos
	If !HS_SeekRet("GM2", "M->GM6_CODLOC + M->GM3_CODPRO", 1, .F.,,,,, .T.)
		HS_MsgInf(STR0026, STR0011, STR0053) //"Procedimento inv�lido ou n�o autorizado para o setor."###"Aten��o"###"Valida��o dos Campos"
		lRet := .F.
	Else
		GDFieldPut("GM3_DESPRO", HS_IniPadr("GA7", 1, M->GM3_CODPRO, "GA7_DESC",, .F.))
		nPos := aScan(oGM3:aCols, {| aVet | aVet[nGM3_CODPRO] == M->GM3_CODPRO})
		If nPos > 0 .And. nPos # oGM3:oBrowse:nAt  // Verifica se este Plano ja foi cadastrado
			HS_MsgInf(STR0027, STR0011, STR0053) //"Procedimento j� cadastrado para esta disponibilidade"###"Aten��o"###"Valida��o dos Campos"
			lRet := .F.
		EndIf

	EndIf
ElseIf ReadVar() == "M->GMK_CODREC"
	If !(lRet := HS_SeekRet("GO2","__cCodSal+M->GMK_CODREC",1,.F.,,,,, .T.))
		HS_MsgInf(STR0074, STR0011, STR0053) //"Recurso n�o cadastrado para sala" ### Aten��o"###"Valida��o dos Campos"
	EndIf
EndIf

DbSelectArea(cAliasOld)
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldHACJ� Autor � Paulo Jose         � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Validacao da hora                                ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FS_VldHACJ(cCampo)

Local lRet := .T., cHora := StrTran(cCampo, ":", "")

If Empty(cHora)
	lRet := .F.
Elseif !(SubStr(cHora, 3, 2) >= '00' .And. SubStr(cHora, 3, 2) <= '59')
	lRet := .F.
ElseIf !(SubStr(cHora, 1, 2) >= '00' .And. SubStr(cHora, 1, 2) <= '23')
	lRet := .F.
ElseIf SubStr(cHora, 1, 2) = '00' .And. SubStr(cHora, 3, 2) = '00'
	lRet := .F.
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldDisp �Autor �Daniel PEixoto      � Data �  07/20/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Verifica se j� existe alguma dispon. com os mesmos       ���
���          �  dias para o mesmo medico                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_VldDisp()

Local lRet       := .T.
Local nForACols  := 0
Local cHorIndisp := ""
Local nLinTGM5   := 0
Local cSqlGm6    := "", cSqlGm5 := ""
Local aArea      := GetArea()
If ExistBlock("HSACJVAL")
 	lRet:=ExecBlock("HSACJVAL", .F., .F.)
 	Return(lRet)
Endif

If INCLUI .OR. ALTERA
	cSqlGm6 := "SELECT GM6.GM6_CODCRM, GM6.GM6_CODDIS, GM6.GM6_HORINI, GM6.GM6_HORFIM, GM6.GM6_CODSAL "
	cSqlGm6 += "FROM " + RetSqlName("GM6") + " GM6 "
	cSqlGm6 += "WHERE GM6.D_E_L_E_T_ <> '*' AND GM6.GM6_FILIAL = '" + xFilial("GM6") + "' AND GM6_IDEATI='1' "
	cSqlGm6 += "AND GM6.GM6_CODCRM = '" + M->GM6_CODCRM + "' AND GM6.GM6_CODDIS <> '" + M->GM6_CODDIS + "'"
	cSqlGm6 := ChangeQuery(cSqlGm6)

	TCQuery cSqlGm6 New Alias "GM6CRM"
	DbSelectArea("GM6CRM")
	While !Eof() .And. lRet //dispnibilidade

		cSqlGm5 := "SELECT GM5.GM5_CODDIS, GM5.GM5_DIASEM "
		cSqlGm5 += "FROM " + RetSqlName("GM5") + " GM5 "
		cSqlGm5 += "WHERE GM5.D_E_L_E_T_ <> '*' AND GM5.GM5_FILIAL = '" + xFilial("GM5") + "' "
		cSqlGm5 += "AND GM5.GM5_CODDIS = '" + GM6CRM->GM6_CODDIS + "' AND GM5_IDEATI='1' "
		cSqlGm5 := ChangeQuery(cSqlGm5)

		TCQuery cSqlGm5 New Alias "GM5DIS"

		DbSelectArea("GM5DIS")
		While !Eof() .And. lRet //Disp X Dias semana
			nLinTGM5 := IIf(Len(oGM5:aCols) == 1 .And. Empty(oGM5:aCols[1, nGM5_DIASEM]), 0, Len(oGM5:aCols) )

			For nForACols := 1 To nLinTGM5
				If GM5DIS->GM5_CODDIS == GM6CRM->GM6_CODDIS .And. GM5DIS->GM5_DIASEM == oGM5:aCols[nForACols, nGM5_DIASEM] .And. !oGM5:aCols[nForACols, nUGM5 + 1]
					If M->GM6_HORINI >= GM6CRM->GM6_HORINI .And. M->GM6_HORINI <= GM6CRM->GM6_HORFIM .Or. M->GM6_HORFIM >= GM6CRM->GM6_HORINI .And. M->GM6_HORFIM <= GM6CRM->GM6_HORFIM
						HS_MsgInf(STR0039 + FS_DiaExt(oGM5:aCols[nForACols, nGM5_DIASEM]) + STR0040 + GM6CRM->GM6_HORINI + STR0041 + GM6CRM->GM6_HORFIM, STR0011, STR0054) //"J� Existe Disponibilidade Cadastrada no dia "###" para esse M�dico no per�odo das "###" a "###"Aten��o"###"Verifica��o de Disponibilidade"
						lRet:= .F.
					ElseIf M->GM6_HORINI < GM6CRM->GM6_HORINI .And. M->GM6_HORFIM >= GM6CRM->GM6_HORINI
						HS_MsgInf(STR0042 + FS_DiaExt(oGM5:aCols[nForACols, nGM5_DIASEM]) + STR0043, STR0011, STR0054) //"Hor�rio Final Incompat�vel, J� Existe Disponibilidade Cadastrada no dia "###" para esse M�dico"###"Aten��o"###"Verifica��o de Disponibilidade"
						lRet:= .F.
					ElseIf !Empty(M->GM6_CODSAL) .And. M->GM6_CODSAL == GM6CRM->GM6_CODSAL //valida a sala para o medico em questao
						cHorIndisp := HS_SomaHor(GM6CRM->GM6_HORFIM, HS_IniPadr("GF3", 1, M->GM6_CODSAL, "GF3_INTERV",, .F.)) //Hor de intervalo da sala GF3_Interv
						If M->GM6_HORINI > GM6CRM->GM6_HORFIM .And. M->GM6_HORINI <= cHorIndisp
							HS_MsgInf(STR0044 + cHorIndisp, STR0011, STR0054) //"Hor�rio Inicial Incompat�vel, Sala Indispon�vel at� "###"Aten��o"###"Verifica��o de Disponibilidade"
							lRet:= .F.
						EndIf
					EndIf
				EndIf
			Next

			DBSkip()
		EndDo

		DbSelectArea("GM5DIS")
		DbCloseArea()

		DbSelectArea("GM6CRM")
		DbSkip()
	EndDo

	DbSelectArea("GM6CRM")
	DbCloseArea()
EndIf

RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_DiaExt �Autor  �Daniel Peixoto      � Data �  07/21/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Retorna o dia por extenso correspondente ao Memo           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_DiaExt(cNroDia)

Local cDia := ""

If cNroDia == "1"
	cDia := STR0045 //"Domingo"
ElseIF  cNroDia == "2"
	cDia := STR0046 //"Segunda"
ElseIF  cNroDia == "3"
	cDia := STR0047 //"Ter�a"
ElseIF  cNroDia == "4"
	cDia := STR0048 //"Quarta"
ElseIF  cNroDia == "5"
	cDia := STR0049 //"Quinta"
ElseIF  cNroDia == "6"
	cDia := STR0050 //"Sexta"
ElseIF  cNroDia == "7"
	cDia := STR0051 //"S�bado"
EndIf

Return(cDia)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvACJ � Autor � Paulo Jose         � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Atualizacao das tabelas                          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvACJ(nOpc)

Local wProcura := .F.

aCGM5 := aClone(oGM5:aCols)
aCGM4 := aClone(oGM4:aCols)
aCGM3 := aClone(oGM3:aCols)
aCGMK := aClone(oGMK:aCols)

If nOpc # 2 // nao for consulta
	DbSelectArea("GM6")
	DbSetOrder(1) // GM6_FILIAL + GM6_CODDIS
	wProcura := DbSeek(xFilial("GM6") + M->GM6_CODDIS)
	If Inclui .Or. Altera

		//GRAVA CADASTRO LOCAL DE ATENDIMENTO - GCS
		RecLock("GM6", If(Altera, .F., .T.))
		HS_GRVCPO("GM6")
		MsUnlock()
		ConfirmSx8()

		FS_GrvGM("GM5", 1, "M->GM6_CODDIS + aCGM5[pForACols, nGM5_DIASEM]", aHGM5, aCGM5, nUGM5,nGM5_DIASEM,.F.)
		FS_GrvGM("GM4", 1, "M->GM6_CODDIS + aCGM4[pForACols, nGM4_CODPLA]", aHGM4, aCGM4, nUGM4,nGM4_CODPLA,.T.)
		FS_GrvGM("GM3", 1, "M->GM6_CODDIS + aCGM3[pForACols, nGM3_CODPRO]", aHGM3, aCGM3, nUGM3,nGM3_CODPRO,.T.)
		FS_GrvGM("GMK", 2, "M->GM6_CODDIS + aCGMK[pForACols, nGMK_ITEDIA]", aHGMK, aCGMK, nUGMK,nGMK_DIASEM,.F.)

	Else  // exclusao
		If wProcura
			If !FS_VldExcD()
				HS_MsgInf(STR0037, STR0011, STR0055) //"Existe agenda gerada para esta disponbiliddade. Exclus�o n�o permitida."###"Aten��o"###"Atualiza��o"
				lRet := .F.
			Else
				// DELETA relacionamentos GM5
				FS_DelGM("GM5", 1, "M->GM6_CODDIS + aCGM5[pForACols, nGM5_DIASEM]", aCGM5,nGM5_DIASEM)
				FS_DelGM("GM4", 1, "M->GM6_CODDIS + aCGM4[pForACols, nGM4_CODPLA]", aCGM4,nGM4_CODPLA)
				FS_DelGM("GM3", 1, "M->GM6_CODDIS + aCGM3[pForACols, nGM3_CODPRO]", aCGM3,nGM3_CODPRO)
				FS_DelGM("GMK", 2, "M->GM6_CODDIS + aCGMK[pForACols, nGMK_ITEDIA]", aCGMK,nGMK_DIASEM)

				DbSelectArea("GM6")
				RecLock("GM6", .F., .T.)
				DBDelete()
				MsUnlock()
				WriteSx2("GM6")
			EndIf
		EndIf
	EndIf
EndIf
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvGM  � Autor � Paulo Jose         � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Grava arquivos de relacionamento - GM0, GM1 e GM2          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvGM(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv, nPos, lLocal)

Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
Local cPref := cAlias + "->" + PrefixoCpo(cAlias)

If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]) )     // Se aCols nao vazio
	For nForACols := 1 To Len(aCGrv)
		pForACols := nForACols

		DbSelectArea(cAlias)
		DbSetOrder(nOrd)
		lAchou := DbSeek(xFilial(cAlias) + &(cChave))
		If aCGrv[nForACols, nUGrv + 1] .And. lAchou // exclusao
			RecLock(cAlias, .F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		Else
			If !aCGrv[nForACols, nUGrv + 1]
				RecLock(cAlias, !lAchou)
				HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
				&(cPref + "_FILIAL") := xFilial(cAlias)
				&(cPref + "_CODDIS") := M->GM6_CODDIS
				If lLocal     //lLocal refere-se a dizer se o arquivo tem o atributo CODLOC ou nao
					&(cPref + "_CODLOC") := M->GM6_CODLOC
				EndIf
				&(cPref + "_IDEATI") := M->GM6_IDEATI
				&(cPref + "_LOGARQ") := HS_LogArq()
				If cAlias == "GM4"
					&(cPref + "_CODCON") := HS_IniPadr("GCM", 2, aCGrv[nForACols, nGM4_CODPLA], "GCM_CODCON",, .F.)
				EndIf
				MsUnlock()
			EndIf
		EndIf
	Next
EndIf

DbSelectArea(cAliasOld)
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_DelGM  � Autor � Paulo Jose         � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de DELETE dos relacionamentos do Local              ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_DelGM(cAlias, nOrd, cChave, aCGrv,nPos)

Local nForDel := 0, cAliasOld := Alias()

If !(len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]) )     // Se aCols nao vazio
	For nForDel := 1 To Len(aCGrv)
		pForACols  := nForDel

		DbSelectArea(cAlias)
		DbSetOrder(nOrd)
		If DbSeek(xFilial(cAlias) + &(cChave))
			RecLock(cAlias, .F., .T.)
			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		EndIf
	Next
EndIf
DbSelectArea(cAliasOld)
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldExcD� Autor � Paulo Jose         � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina que Verifica se a disponibilidade esta em           ���
���          � uso na Agenda Ambulatorial (GM8)                           ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_VldExcD()

Local aArea := GetArea()
Local lRet  := .T.

DbSelectArea("GM8")
DbSetOrder(9) // GM8_FILIAL + GM8_CODDIS
lRet := !DbSeek(xFilial("GM8") + M->GM6_CODDIS)

RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_FACILI � Autor � Cibele Peria       � Data �  24/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Prepara Facilitadores                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_FACILI()

If oFolder:nOption == 1
	HS_MsgInf(STR0031, STR0011, STR0056) //"Facilitador n�o gerado para este relacionamento"###"Aten��o"###"Prepara Facilitadores"
Else
	If Empty(M->GM6_CODDIS)
		HS_MsgInf(STR0029, STR0011, STR0056) //"Por Favor,informe o c�digo da disponibilidade"###"Aten��o"###"Prepara Facilitadores"
	Else
		If oFolder:nOption == 2
			PROCESSA({||FS_FACPLA()})
		ElseIF oFolder:nOption == 3
			If Empty(M->GM6_CODLOC)
				HS_MsgInf(STR0032, STR0011, STR0056)//"Por favor, informe o c�digo do setor"###"Aten��o"###"Prepara Facilitadores"
			Else
				PROCESSA({||FS_FACPRO()})
			EndIf
		EndIf
	EndIf
EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_FACPLA � Autor � Cibele Peria       � Data �  24/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Facilitador para inclusao de planos no relacionamento      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_FACPLA()

Local aArea := GetArea(), lRet := .T., nForACols := 0

aCGM4 := aClone(oGM4:aCols)

For nForACols := 1 To Len(aCGM4)
	If aCGM4[nForACols, nUGM4 + 1] == .T.
		HS_MsgInf(STR0033, STR0011, STR0057) //"Atualize a disponibilidade (relacionamentos exclu�dos) antes de executar o facilitador"###"Aten��o"###"Facilitador para Inclus�o de Planos no Relacionamento"
		lRet := .F.
		Exit
	EndIf
Next

If lRet
	If Pergunte("HSA97A", .T.)
		DbSelectArea("GCM") //Cadastro de Planos X Convenios
		DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
		ProcRegua(RecCount())
		DbSeek(xFilial("GCM") + MV_PAR01, .T.)

		While !Eof() .And. GCM->GCM_FILIAL == xFilial("GCM") .And. GCM->GCM_CODPLA <= MV_PAR02
			IncProc(STR0030 + GCM->GCM_CODPLA) //"Processando... "

			If Empty(aCGM4[oGM4:nAt, nGM4_CODPLA])
				aCGM4[oGM4:nAt, nGM4_CODPLA] := GCM->GCM_CODPLA
				aCGM4[oGM4:nAt, nGM4_DESPLA] := GCM->GCM_DESPLA
				aCGM4[oGM4:nAt, nUGM4 + 1]   := .F.
			ElseIf aScan(oGM4:aCols, {| aVet | aVet[1] == GCM_CODPLA})	== 0
				aADD(aCGM4, oGM4:aCols[1])
				aCGM4[Len(aCGM4), nGM4_CODPLA] := GCM->GCM_CODPLA
				aCGM4[Len(aCGM4), nGM4_DESPLA] := GCM->GCM_DESPLA
			EndIf
			oGM4:SetArray(aCGM4)
			DbSkip()
		EndDo

		oGM4:Refresh()
	EndIf
EndIf

RestArea(aArea)
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_FACPLA � Autor � Cibele Peria       � Data �  27/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Facilitador P/incluisao de procedimentos no relacionamento ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_FACPRO()

Local aArea := GetArea(), lRet := .T., nForACols := 0

aCGM3 := aClone(oGM3:aCols)

For nForACols := 1 To Len(aCGM3)
	If aCGM3[nForACols, nUGM3 + 1] == .T.
		HS_MsgInf(STR0033, STR0011, STR0058) //"Atualize a disponibilidade (relacionamentos exclu�dos) antes de executar o facilitador"###"Aten��o"###"Facilitador para Inclus�o de Procedimentos no Relacionamento"
		lRet := .F.
		Exit
	EndIf
Next

If lRet
	If Pergunte("HSP99B", .T.)
		DbSelectArea("GM2") //Cadastro de Procedimentos
		DbSetOrder(1) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
		ProcRegua(RecCount())
		DbSeek(xFilial("GM2") + M->GM6_CODLOC + MV_PAR01, .T.)
		While !Eof() .And. GM2->GM2_FILIAL == xFilial("GM2") .And. GM2->GM2_CODLOC == M->GM6_CODLOC .And. GM2->GM2_CODPRO <= MV_PAR02
			IncProc(STR0030 + GM2->GM2_CODPRO) //"Processando... "

			DbSelectArea("GA7")
			DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
			If DbSeek(xFilial("GA7") + GM2->GM2_CODPRO)
				If GA7->GA7_CODGPP >= MV_PAR03 .And. GA7->GA7_CODGPP <= MV_PAR04 //Consiste Grupo de Procedimento
					If GA7->GA7_CODGDE >= MV_PAR05 .And. GA7->GA7_CODGDE <= MV_PAR06 //Consiste Grupo de Despesa
						If GA7->GA7_CODESP >= MV_PAR07 .And. GA7->GA7_CODESP <= MV_PAR08 //Consiste eSPECIALIDADE

							If Empty(aCGM3[oGM3:nAt, nGM3_CODPRO])
								aCGM3[oGM3:nAt, nGM3_CODPRO] := GA7->GA7_CODPRO
								aCGM3[oGM3:nAt, nGM3_DESPRO] := GA7->GA7_DESC
								aCGM3[oGM3:nAt, nUGM3 + 1] := .F.
							ElseIf aScan(aCGM3, {| aVet | aVet[1] == GA7_CODPRO})	== 0
								aADD(aCGM3, oGM3:aCols[1])
								aCGM3[Len(aCGM3), nGM3_CODPRO] := GA7->GA7_CODPRO
								aCGM3[Len(aCGM3), nGM3_DESPRO] := GA7->GA7_DESC
							EndIf
							oGM3:SetArray(aCGM3)

						EndIf
					EndIf
				EndIf
			EndIf
			DbSelectArea("GM2")
			DbSkip()
		End

		oGM3:Refresh()
	EndIf
EndIf

RestArea(aArea)
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VlHA97B�Autor  �Alessandro Freire   � Data �  23/02/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida o intervalo maximo entre uma hora e outra           ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_VlHA97B(cHoraI, cHoraF, cHoraM)

Local nHoraInter := 0, cHoraInter := StrTran(cHoraM, ":", "")

nHoraInter := Val(SubStr(cHoraInter, 1, 2)) + (Val(SubStr(cHoraInter, 3, 2)) / 60)

Return( nHoraInter <= SubtHoras(dDataBase, cHoraI, dDataBase, cHoraF))


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSVLCOLS  �Autor  �Alessandro Freire   � Data �  23/02/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � valida se o dia da semana e o procedimento estao           ���
���          � preenchidos                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VLCols(oCGM5, oCGM3, nOpc)

Local lRet1 := .F.
Local lRet2	:= .F.
Local nI				:= 0

If nOpc < 3 .Or. nOpc > 4
	Return(.T.)
EndIf

For nI := 1 To Len(oGM5:aCols)
	If ! Empty(ogm5:aCols[nI, nGM5_DIASEM]) .And. !oGM5:aCols[ni, Len(oGm5:aCols[ni])]
		lRet1 := .T.
		Exit
	EndIf
Next nI

If !lRet1
	HS_MsgInf(STR0035, STR0011, STR0053) //"Pelo menos um dia da semana deve ser inclu�do"###"Aten��o"###"Valida��o dos Campos"
EndIf

For nI := 1 To Len(oGm3:aCols)
	If !Empty(oGm3:aCols[nI, nGM3_CODPRO]) .And. !oGm3:aCols[ni, Len(oGm3:aCols[ni])]
		lRet2 := .T.
		Exit
	EndIf
Next nI

If !lRet2
	HS_MsgInf(STR0036, STR0011, STR0053) //"Pelo menos um procedimento deve ser inclu�do"###"Aten��o"###"Valida��o dos Campos"
EndIf

Return(lRet1 .And. lRet2)

