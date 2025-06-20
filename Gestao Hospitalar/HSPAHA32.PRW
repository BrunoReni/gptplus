#INCLUDE "HSPAHA32.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA32  � Autor � Manoel Filho       � Data �  04/12/01   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE PRESTADORES                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA32()
Private cCadastro := OemToAnsi(STR0001) //"Cadastro de Prestador"
Private aRotina := {	{OemToAnsi(STR0002),	"AxPesqui", 		0, 1},; //"Pesquisar"
																					{OemToAnsi(STR0003),	"HS_A32ROTI",	0, 2},; 	//"Visualizar"
																					{OemToAnsi(STR0004),	"HS_A32ROTI",	0, 3},; //"Incluir"
																					{OemToAnsi(STR0005),	"HS_A32ROTI",	0, 4},; //"Alterar"
																					{OemToAnsi(STR0006),	"HS_A32ROTI",	0, 5},; //"Excluir"
																					{OemToAnsi(STR0007),	"HS_A32VLRP",	0, 4},; //"Vlr Plant�o"
																					{OemToAnsi(STR0008),	"HS_A32PGTM",	0,	4}} 	//"Pgto M�nimo/Teto"

Private __cTpPic := "J" //Variavel utilizada para setar a mascara do campo GAZ_CGCPRE

DbSelectArea("GAZ")
DbSetOrder(1)

mBrowse(6, 1, 22, 75, "GAZ")

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �HS_A32ROTI� Autor � Robson Ramiro A.Olivei� Data � 12.04.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de prestadores                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A32ROTI(cAlias, nReg, nOpc)
Local oDlg			:= NIL
Local lOk 			:= .F.
Local nCont		:= 0
Local bCampo	:= {|nCPO| Field(nCPO)}

Private aTela := {}
Private aGets := {}

DbSelectArea("GN4")
DbSelectArea("GAZ")
RegToMemory("GAZ", (nOpc == 3))

__cTpPic := IIF(!Empty(M->GAZ_TIPPRE),M->GAZ_TIPPRE,"J")

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd Pixel

 Enchoice("GAZ", nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,	{||lOk := Obrigatorio(aGets, aTela) .And. HS_VLDA32(2), IIf(lOk, oDlg:End(),)},;
																																																	{||oDlg:End()} )

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	
	Begin Transaction
	
 	RecLock("GAZ", Inclui)
	  For nCont := 1 To FCount()
	  	If "FILIAL"$Field(nCont)
	  		FieldPut(nCont, xFilial("GAZ"))
	  	Else
	  		FieldPut(nCont, M->&(EVAL(bCampo,nCont)))
	  	Endif
	  Next nCont
		 GAZ->GAZ_LOGARQ := HS_LOGARQ()
	 MsUnLock()
	
	End Transaction
	
Endif

If nOpc == 5 .and. lOk
	
	DbSelectArea("GAY")
	DbSetOrder(7)//GAY/7
	If !DbSeek(xFilial("GAY") + M->GAZ_CODPRE) //nao tem nos credenciamentos
		DbSelectArea("GA7")
		DbSetOrder(8)//GA7/8
		If !DbSeek(xFilial("GA7") + M->GAZ_CODPRE) //nao tem nos procedimentos
			//Deleta
			DbSelectArea("GEF")
			DbSetOrder(1)
			DbSeek(xFilial("GEF") + M->GAZ_CODPRE)
			
			Begin Transaction
			
 			Do While !Eof() .and.  GEF->(GEF_FILIAL + GEF_CODPRE) == xFilial("GEF") + M->GAZ_CODPRE
 				RecLock("GEF", .F.)
 			 	DbDelete()
 				MsUnLock()
				
	 			DbSkip()
	 		Enddo
			
		 	RecLock("GAZ", .F.)
		  	DbDelete()
			 MsUnLock()
			
			End Transaction
		Else
			HS_MsgInf(STR0013, STR0012, STR0006) //"Existe credenciamento cadastrado para este prestador. Exclus�o n�o permitida!"###"Aten��o"###"Excluir"
		Endif
	Else
		HS_MsgInf(STR0011, STR0012, STR0006) //"Existe esse prestador no Credenciamento. Impossivel Exclui-lo!"###"Aten��o"###"Excluir"
	EndIf
EndIf

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �HS_A32PGTM� Autor � Robson Ramiro A.Olivei� Data � 11.04.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastra o piso dos prestadores                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HS_A32PGTM(Void)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                   							          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � HSP                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A32PGTM(cAlias, nReg, nOpc)

Local nOpcA    := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
Local nCntFor  := 1 , aCpoEnc := {"GAZ_CODPRE",	"GAZ_FANPRE","GAZ_CTLOCM","GAZ_VALMIN","GAZ_VLMIND","GAZ_VALMAX","GAZ_VLMAXD"}
Local aSize    := {},  aObjects := {},  aInfo := {}, aPObjs := ()
Local aCposAlt := {"GAZ_CTLOCM","GAZ_VALMIN","GAZ_VLMIND","GAZ_VALMAX","GAZ_VLMAXD"}

Private aTela  := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGEF	 := {}, aHGEF   := {}, nUGEF := 0, nLGEF := 0, oGEF
Private nGEFSTAREG := 0, nGEF_NumSeq:= 0, nGEF_CodLoc := 0, nGEF_ValMin := 0, nGEF_VlMinD := 0, nGEF_ValMax := 0, nGEF_VlMaxD := 0, nGEF_Vigenc := 0

DbSelectArea("GEF")

RegToMemory("GAZ", .F.)

Inclui := .F.

HS_BDados("GEF", @aHGEF, @aCGEF, @nUGEF, 1, M->GAZ_CODPRE, "'" + M->GAZ_CODPRE + "' == GEF->GEF_CODPRE",.T. )
nGEFSTAREG  := aScan(aHGEF, {| aVet | aVet[2] == "HSP_STAREG"})
nGEF_CodLoc := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_CODLOC" })
nGEF_Vigenc := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_DATVIG" })
nGEF_ValMin := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VALMIN" })
nGEF_VlMinD := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VLMIND" })
nGEF_ValMax := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VALMAX" })
nGEF_VlMaxD := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VLMAXD" })
nGEF_NumSeq := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_NUMSEQ" })

//numeracao sequencial do primeiro detalhe - preencher com zeros a esquerda
If Empty(aCGEF[1, nGEF_NumSeq])
	aCGEF[1, nGEF_NumSeq] := StrZero(1, Len(GEF->GEF_NUMSEQ))
EndIf

Inclui := .T.
DbSelectArea("GAZ")
nOpcA := 0

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd

 EnChoice("GAZ", nReg, nOpc,,,,aCpoEnc, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] }, aCposAlt, 3,,,,,, .F.,,,.T.)

 oGEF := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,"HS_DuplAC(oGEF:oBrowse:nAt, oGEF:aCols, { nGEF_CodLoc,nGEF_Vigenc})",,"+GEF_NUMSEQ",,,,,,, oDlg, aHGEF, aCGEF)
 oGEF:cFieldOk        := "HS_GDAtrib(oGEF, {{nGEFStaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)"
 oGEF:oBrowse:bDelete := {|| HS_GDAtrib(oGEF, {{nGEFStaReg, "BR_CINZA", "BR_VERDE"}}, 5), oGEF:DelLine()}

 oGEF:oBrowse:align := CONTROL_ALIGN_BOTTOM                             
 IIf( M->GAZ_CTLOCM == '1',oGEF:oBrowse:Enable(),oGEF:oBrowse:Disable())

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, FS_Vlda() .AND. IIf(oGEF:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0) } , ;
																																																	{|| nOpcA := 0, oDlg:End()})
Begin Transaction
 RecLock("GAZ", .F.)
  HS_GrvCpo("GAZ")
  GAZ->GAZ_LOGARQ := HS_LOGARQ()
 MsUnLock()
End Transaction

// Salva Setores
If nOpcA == 1 .And. M->GAZ_CTLOCM == "1"
	Begin Transaction
 	FS_GrvA32a()
	End Transaction
EndIf

Return .T.


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    �FS_GrvA32a� Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava��o dos dados minimo/teto                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function FS_GrvA32a()
Local   cAlias    := "GEF"
Local   nOrd      := 2
Local   cChave    := "M->GAZ_CODPRE+oGEF:aCols[pForaCols, nGEF_NumSeq]"
Local   oGrv      := oGEF
Local   nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local   cAliasOld := Alias(), lAchou := .F.
Private pForaCols := 0

For nItem := 1 To Len(oGrv:aCols)
 If oGEF:aCols[nItem, nGEFStaReg] <> "BR_VERDE"
		pForaCols := nItem
		DbSelectArea(cAlias)
		DbSetOrder(nOrd)
		lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
		If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou /* exclusao */
			RecLock(cAlias, .F., .T.)
 			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		Else
			If Inclui .Or. Altera
				If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
					RecLock(cAlias, !lAchou)
	 				HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
	 				&(cPref + "_FILIAL") := xFilial(cAlias)
	 				&(cPref + "_CODPRE") := M->GAZ_CODPRE
	 				&(cPref + "_LOGARQ") := HS_LogArq()
					MsUnlock()
				Endif
			Endif
		EndIf
	Endif
Next

DbSelectArea(cAliasOld)
Return()


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � FS_Vlda  � Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida��o  dos dados minimo/teto                             ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function FS_Vlda()
Local nPosDel	:= Len(aHGEF) + 1
Local nItem 				:= 0
Local nSetores  := 0 // Guarda quantidade de setores

If M->GAZ_CTLOCM == "0" // Se n�o for controle por Setor
	// Se n�o tiver valor minimo ou maximo cadastrado
	If M->GAZ_VALMIN == 0 .and. M->GAZ_VLMIND == 0 .And. M->GAZ_VALMAX == 0 .and. M->GAZ_VLMAXD == 0
		HS_MsgInf(STR0010, STR0012, STR0008) //"O campo "Controle setor" est� informado como "N�o", informe a seguir os valores a serem considerados para no pagamento m�nimo/ teto"##"Aten��o"###"Pagto M�nimo/Teto"
		return (.F.)
		
		// Se o valor minimo for maior que o maximo
	ElseIf !Empty(M->GAZ_VALMAX) .And. M->GAZ_VALMIN > M->GAZ_VALMAX
		HS_MsgInf(STR0016, STR0012, STR0008) //"Valor m�ximo tem que ser maior ou igual ao valor m�nimo","Aten��o"###"Pagto M�nimo/Teto"
		return (.F.)
		
		// Se o valor minimo di�rio for maior que o m�ximo di�rio
	ElseIf !Empty(M->GAZ_VLMAXD) .And. M->GAZ_VLMIND > M->GAZ_VLMAXD
		HS_MsgInf(STR0017, STR0012, STR0008) //"Valor m�ximo di�rio tem que ser maior ou igual ao valor m�nimo di�rio"###"Aten��o"###"Pagto M�nimo/Teto"
		return (.F.)
 Endif
ElseIf M->GAZ_CTLOCM == "1"
	// verifica se setor e valores est�o preenchidos
	For nItem := 1 To Len(oGEF:aCols)
		
		If !oGEF:aCols[oGEF:nAt, nPosDel] // Linha nao deletada
				
			// Se n�o tiver valor minimo ou maximo cadastrado
			If !Empty(oGEF:aCols[oGEF:nAt, nGEF_CodLoc]) .and. oGEF:aCols[oGEF:nAt, nGEF_VALMIN] == 0 .and. oGEF:aCols[oGEF:nAt, nGEF_VLMIND] == 0 .And. oGEF:aCols[oGEF:nAt, nGEF_VALMAX] == 0 .and. oGEF:aCols[oGEF:nAt, nGEF_VLMAXD] == 0
				HS_MsgInf(STR0025, STR0012, STR0008) //"Por favor, informe os valores de pagamento m�nimo/ teto para os setores"##"Aten��o"###"Pagto M�nimo/Teto"
				return (.F.)
				
			// Se o valor minimo for maior que o maximo
			ElseIf !Empty(oGEF:aCols[oGEF:nAt, nGEF_VALMAX]) .And. oGEF:aCols[oGEF:nAt, nGEF_VALMIN] > oGEF:aCols[oGEF:nAt, nGEF_VALMAX]
				HS_MsgInf(STR0016, STR0012, STR0008) //"Valor m�ximo tem que ser maior ou igual ao valor m�nimo"###"Aten��o"###"Pagto M�nimo/Teto"
				return (.F.)
				
			// Se o valor minimo di�rio for maior que o m�ximo di�rio
			ElseIf !Empty(oGEF:aCols[oGEF:nAt, nGEF_VLMAXD]) .And. oGEF:aCols[oGEF:nAt, nGEF_VLMIND] > oGEF:aCols[oGEF:nAt, nGEF_VLMAXD]
				HS_MsgInf(STR0017, STR0012, STR0008) //"Valor m�ximo di�rio tem que ser maior ou igual ao valor m�nimo di�rio"###"Aten��o"###"Pagto M�nimo/Teto"
				return (.F.)
	
			// Se n�o tiver Setor
			ElseIf Empty(oGEF:aCols[oGEF:nAt, nGEF_CodLoc])
				HS_MsgInf(STR0018, STR0012, STR0008) //"Setor n�o pode estar em branco"###"Aten��o"###"Pagto M�nimo/Teto"
				return (.F.)
			Endif
	 Endif
		nSetores += IIF(!Empty(oGEF:aCols[nItem, nGEF_CodLoc]),1,0) // Se tiver setor incrementa
	Next
	If nSetores < 1
		HS_MsgInf(STR0019,STR0012, STR0008)//"Com controle por setor, � necess�rio informar um Setor com todos os valores preenchidos."###"Aten��o"###"Pagto M�nimo/Teto"
		return (.F.)
	Endif
ElseIf empty(M->GAZ_CTLOCM)
		HS_MsgInf(STR0027,STR0012,STR0001)//"Por favor, informe o tipo de controle: se SIM com controle por setor, se N�O sem controle por setor ou SEM CONTROLE para n�o gerar pagamento m�nimo."###"Aten��o"###"Cadastro de Prestador"
		return (.F.)
Endif

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A32VLRP�Autor  �MARCELO JOSE        � Data �  30/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �  RELACIONA PRESTADOR COM VALOR DO PLANTAO                  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A32VLRP(cAlias, nReg, nOpc)
Local nOpcA    := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
Local nCntFor  := 1 , aCpoEnc := {"GAZ_CODPRE",	"GAZ_FANPRE","GAZ_CTRLOC","GAZ_VLRDIU","GAZ_VLRNOT","GAZ_VLRFER","GAZ_FATORH"}
Local aSize    := {},  aObjects := {},  aInfo := {}, aPObjs := ()
Local aCposAlt := {"GAZ_CTRLOC","GAZ_VLRDIU","GAZ_VLRNOT","GAZ_VLRFER","GAZ_FATORH"}

Private aTela  := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGEU	 := {}, aHGEU   := {}, nUGEU := 0, nLGEU := 0, oGEU
Private nGEUSTAREG  := 0, nGEU_NumSeq := 0, nGEU_CodLoc := 0, nGEU_VlrDiu := 0, nGEU_VlrNot := 0, nGEU_VlrFer := 0, nGEU_FatorH := 0, nGEU_Vigenc := 0

DbSelectArea("GEU")

RegToMemory("GAZ", .F.)

Inclui := .F.

HS_BDados("GEU", @aHGEU, @aCGEU, @nUGEU, 1, M->GAZ_CODPRE, "'" + M->GAZ_CODPRE + "' == GEU->GEU_CODPRE",.T. )
nGEUSTAREG  := aScan(aHGEU, {| aVet | aVet[2] == "HSP_STAREG"})
nGEU_CodLoc := aScan(aHGEU, {| aVet | aVet[2] == "GEU_CODLOC"})
nGEU_VlrMat := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VLRMAT"})
nGEU_VlrNot := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VLRNOT"})
nGEU_VlrFer := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VLRFER"})
nGEU_FatorH := aScan(aHGEU, {| aVet | aVet[2] == "GEU_FATORH"})
nGEU_Vigenc := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VIGENC"})
nGEU_NumSeq := aScan(aHGEU, {| aVet | aVet[2] == "GEU_NUMSEQ"})

//numeracao sequencial do primeiro detalhe - preencher com zeros a esquerda
If Empty(aCGEU[1, nGEU_NumSeq])
	aCGEU[1, nGEU_NumSeq] := StrZero(1, Len(GEU->GEU_NUMSEQ))
EndIf

Inclui := .T.
DbSelectArea("GAZ")
nOpcA := 0

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd

 EnChoice("GAZ", nReg, nOpc,,,,aCpoEnc, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] }, aCposAlt, 3,,,,,, .F.,,,.T.)

 oGEU := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,"HS_DuplAC(oGEU:oBrowse:nAt, oGEU:aCols, { nGEU_CodLoc,nGEU_Vigenc})",,"+GEU_NUMSEQ",,,,,,, oDlg, aHGEU, aCGEU)
 oGEU:cFieldOk           := "HS_GDAtrib(oGEU, {{nGEUStaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)"
 oGEU:oBrowse:bDelete := {|| HS_GDAtrib(oGEU, {{nGEUStaReg, "BR_CINZA", "BR_VERDE"}}, 5), oGEU:DelLine()}
 oGEU:oBrowse:align := CONTROL_ALIGN_BOTTOM
 IIf( M->GAZ_CTRLOC == '1',oGEU:oBrowse:Enable(),oGEU:oBrowse:Disable())

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, FS_Vld() .AND. IIf(oGEU:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0) } , ;
																																																	{|| nOpcA := 0, oDlg:End()})

Begin Transaction
 RecLock("GAZ", .F.)
  HS_GrvCpo("GAZ")
  GAZ->GAZ_LOGARQ := HS_LOGARQ()
 MsUnLock()
End Transaction

// Salva Setores
If nOpcA == 1 .And. M->GAZ_CTRLOC == "1"
	Begin Transaction
 	FS_GrvA32()
	End Transaction
EndIf

Return(Nil)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � FS_GrvA32� Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava��o dos dados Plant�o                                   ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function FS_GrvA32()
Local   cAlias    := "GEU"
Local   nOrd      := 2
Local   cChave    := "M->GAZ_CODPRE+oGEU:aCols[pForaCols, nGEU_NumSeq]"
Local   oGrv      := oGEU
Local   nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local   cAliasOld := Alias(), lAchou := .F.
Private pForaCols := 0

For nItem := 1 To Len(oGrv:aCols)
 If oGEU:aCols[nItem, nGEUStaReg] <> "BR_VERDE"
		pForaCols := nItem
		DbSelectArea(cAlias)
		DbSetOrder(nOrd)//GEU_CODPRE+GEU_NUMSEQ
		lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
		If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou /* exclusao */
			RecLock(cAlias, .F., .T.)
		 	DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		Else
			If Inclui .Or. Altera
				If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
					RecLock(cAlias, !lAchou)
		 			HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
		 			&(cPref + "_FILIAL") := xFilial(cAlias)
		 			&(cPref + "_CODPRE") := M->GAZ_CODPRE
		 			&(cPref + "_LOGARQ") := HS_LogArq()
					MsUnlock()
				Endif
			Endif
		EndIf
	Endif
Next

DbSelectArea(cAliasOld)
Return()

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � FS_Vld   � Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida��o  dos dados Plant�o                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function FS_Vld()
Local   oGrv      := oGEU
Local   nItem 				:= 0
Local   nSetores  := 0 // Guarda quantidade de setores
If M->GAZ_CTRLOC == "0"
	If Empty(M->GAZ_VLRDIU) .OR. 	Empty(M->GAZ_VLRNOT) .OR. Empty(M->GAZ_VLRFER) .OR. Empty(M->GAZ_FATORH)
		HS_MsgInf(STR0020,STR0012,STR0001)//"Sem controle por setor, � necess�rio preencher todos campos de valores."###"Aten��o"###"Cadastro de Prestador"
		return (.F.)
	Endif
ElseIf M->GAZ_CTRLOC == "1"
	// verifica se setor e valores est�o preenchidos
	For nItem := 1 To Len(oGrv:aCols)
		
		// Se tiver Setor tem que ter todos os valores preenchidos
		if (!Empty(oGrv:aCols[nItem, nGEU_CodLoc])) .AND. (Empty(oGrv:aCols[nItem, nGEU_VlrMat]) .OR. Empty(oGrv:aCols[nItem, nGEU_VlrNot]) .OR. Empty(oGrv:aCols[nItem, nGEU_VlrFer]) .OR. Empty(oGrv:aCols[nItem, nGEU_FatorH]))
			HS_MsgInf(STR0021,STR0012,STR0001)//"Todos os valores de um Setor dever�o ser preenchidos."###"Aten��o"###"Cadastro de Prestador"
			return (.F.)
		Endif
		nSetores += IIF(!Empty(oGrv:aCols[nItem, nGEU_CodLoc]),1,0) // Se tiver setor incrementa
	Next
	If nSetores < 1
		HS_MsgInf(STR0022,STR0012,STR0001)//"Com controle por setor, � necess�rio informar um Setor com todos os valores preenchidos."###"Aten��o"###"Cadastro de Prestador"
		return (.F.)
	Endif
Else
		HS_MsgInf(STR0026,STR0012,STR0001)//"Por favor,informe o tipo de controle: se SIM com controle por setor ou N�O sem controle por setor."###"Aten��o"###"Cadastro de Prestador"
		return (.F.)
Endif

return (.T.)


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    �HS_VldHA32� Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function HS_VldHA32(cHora)
Local lRet := .T.

cHora := StrTran(cHora, ":", "")
If Empty(cHora)
	lRet := .F.
Elseif !(SubStr(cHora, 3, 2) >= '00' .and. SubStr(cHora, 3, 2) <= '59')
	lRet := .F.
ElseIf !(SubStr(cHora, 1, 2) >= '00' .and. SubStr(cHora, 1, 2) <= '23')
	lRet := .F.
EndIf

Return(lRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � HS_VLDA32� Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function HS_VLDA32(nVld)
Local lRet := .T.

If nVld == 1
	lRet := HS_SeekRet("SA2","M->GAZ_CODFOR",1,.F.,"GAZ_NREDUZ","A2_NREDUZ")
ElseIf nVld == 2
	If !Empty(M->GAZ_CGCPRE)
		If !( LEN(AllTrim(M->GAZ_CGCPRE)) == IIF(M->GAZ_TIPPRE == "J",14,11) )
			HS_MSGINF(STR0015,STR0012,STR0014)
			lRet := .F.
		ElseIf ( !CGC(M->GAZ_CGCPRE,"M->GAZ_CGCPRE") .AND. EXISTCHAV("GAZ",M->GAZ_CGCPRE,3,"GAZ_CGCPRE") )
			lRet := .F.
		EndIf
	EndIf
ElseIf nVld == 3
	If !Empty(M->GAZ_TIPPRE)
		__cTpPic := M->GAZ_TIPPRE
	EndIf
ElseIf nVld == 4
	If !(lRet :=HS_SeekRet("GCS","M->GEF_CODLOC",1,.F.,"GEF_NOMLOC","GCS_NOMLOC"))
		HS_MSGINF(STR0023,STR0012,STR0024)//"Setor n�o encontrado"###"Aten��o"###"Valida��o Setor"
	Endif
ElseIf nVld == 5
	If !(lRet :=HS_SeekRet("GCS","M->GEU_CODLOC",1,.F.,"GEU_NOMLOC","GCS_NOMLOC"))
		HS_MSGINF(STR0023,STR0012,STR0024)//"Setor n�o encontrado"###"Aten��o"###"Valida��o Setor"
	Endif
EndIf

Return(lRet)          

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � PicT     � Autor � MICROSIGA               � Data �   /  /   ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao para tratamento da Picture do Cadastro de Prestadores ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PicT(cTipPes)
Local cPict := ""  

if cTipPes == "F"
	cPict := "@R 999.999.999-99"
else
	cPict := "@R 99.999.999/9999-99"
endif
cPict := cPict + "%C"
Return cPict

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � HSHA32VLD� Autor � MICROSIGA                                 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao para tratamento do Valid dos campos da rotina HSPAHA32���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA32                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function HSHA32VLD (cCampo)
Local lRet := .T.

Do Case 
	Case cCampo == "GAZ_CTLOCM"
		If IsInCallStack("HS_A32PGTM")
			If M->GAZ_CTLOCM == '1'
				oGEF:oBrowse:Enable()
			Else
				oGEF:oBrowse:Disable()
			Endif
		Endif
	
	Case cCampo == "GAZ_CTRLOC"
		If IsInCallStack("HS_A32VLRP")
			If M->GAZ_CTRLOC == '1'
				oGEU:oBrowse:Enable()
			Else
				oGEU:oBrowse:Disable()
			Endif
		Endif
EndCase

Return lRet