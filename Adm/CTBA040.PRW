#INCLUDE "CTBA040.CH"
#INCLUDE "PROTHEUS.CH"

#include "fwadaptereai.ch"
STATIC __lCTA040Item	:= .F.
STATIC lCTA040TOK := ExistBlock("CTA040TOK")
STATIC lCTB040AUT := .F.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA040  � Autor � Pilar S. Albaladejo   � Data � 04/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Itens Contabeis 			              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA040()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA040(aRotAuto,nOpcAuto)

Local aCores := {	{ "CTD_BLOQ == '1'" , "BR_VERMELHO"	},; // Conta Bloqueada
					{ "CTD_BLOQ == '2' .AND. ( ( Empty( CTD_DTEXIS ) .Or. CTD_DTEXIS <= dDatabase ) .AND. ( Empty( CTD_DTEXSF ) .Or. CTD_DTEXSF >= dDatabase ) )" , "BR_VERDE"   	},; // Sem Restri��o
					{ "CTD_BLOQ == '2' .AND. ( ! Empty( CTD_DTEXIS ) .AND. CTD_DTEXIS >= dDatabase )" , "BR_AMARELO"	},; // Exercicio N�o Iniciado
					{ "CTD_BLOQ == '2' .AND. ( ! Empty( CTD_DTEXSF ) .AND. CTD_DTEXSF <= dDatabase )" , "BR_CINZA"		} } // Exercicio Finalizado

PRIVATE aRotina := MenuDef()


PRIVATE cCadastro := OemToAnsi(STR0006)+CtbSayApro("CTD")  //"Cadastro Itens Contabeis"
__lCTA040Item	 := CtbMovSaldo("CTD")

DEFAULT aRotAuto := {}
DEFAULT nOpcAuto := 3

If !(__lCTA040Item)
	Help(" ",1,"NCONSALITE")
	Return
Endif

If Len(aRotAuto) > 0
	lCTB040AUT := .T.
Else
	SetKey(VK_F12,{|a,b|AcessaPerg("CTB040",.T.)})
EndIf

Pergunte("CTB040",.F.)

If lCTB040Aut
	PRIVATE aAutoCab   := Aclone(aRotAuto)
	MBrowseAuto(nOpcAuto,aAutoCab,"CTD")
Else
	//�������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros						�
	//� mv_par01		// Gera Item Sup? Autom/Formula/Digit	  	�
	//� mv_par02		// Formula Item Sup?						�
	//� mv_par03		// Cadastro em Arvore (Nao/Sim/Perguntar)	�
	//���������������������������������������������������������������

	If mv_par03 == 2
		CtbaTree("CTD")
		SET KEY VK_F12 to
		Return
	ElseIf mv_par03 == 3
		If MsgYesNo(STR0010)
			CtbaTree("CTD")
			SET KEY VK_F12 to
			Return
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"CTD",,,,,,aCores)

	SET KEY VK_F12 to
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA040Inc  � Autor � Lucimara Soares    � Data � 22/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclus�o de Itens Contabeis         			              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ctba040Inc(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA040Inc(cAlias,nReg,nOpc)

Local l040Grv    := ExistBlock('CTB040GR')
Local nOpcA      := 0
Local lIntegDef  := FWHasEAI("CTBA040",.T.,,.T.)
Local lEAI040A   := FWHasEAI("CTBA040A",.T.,,.T.)
Local aEaiRet    := {}
Local nY
PRIVATE aCposHistor := {}

Begin Transaction

If !lCTB040AUT		// SE FOR ROTINA AUTOMATICA
	nOpcA := AxInclui(cAlias,nReg,nOpc,,,,"Ct040TudOk(nOpc)")
Else
	nopcA := AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/   ,/*aCpos*/,"Ct040TudOk(nOpc)",/*lF3*/,  ,   ,/*aParam*/,aAutoCab  ,/*lVirtual*/,/*lMaximized*/)
EndIf

If nOpcA == 1
	//�����������������������������������������������������������������������Ŀ
	//� Grava Hist�rico de Altera��es na tabela CW4.                          �
	//�������������������������������������������������������������������������
	If nOpc == 3
		CTBGrvHist(xFilial("CTD"),"CTD"		,CTD->CTD_ITEM,       ,ValType(CTD->CTD_ITEM),"CTD_ITEM",""       ,CTD->CTD_ITEM,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := CTD->&(EVAL(bCampo,nY))
			If aCposHistor[nY][2] <> aCposHistor[nY][3]
				CTBGrvHist(xFilial("CTD"),"CTD"     ,CTD->CTD_ITEM,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
				//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
			EndIf
   		Next nY
	EndIf

	If lEAI040A
		aEaiRet := FwIntegDef('CTBA040A',,,,'CTBA040A')
		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
			DisarmTransaction()
			nOpcA := 0
		EndIf
	ElseIf lIntegDef // Caso o novo adapter n�o esteja configurado realizo a chamada do adapter antigo
	    // chamada da fun��o integdef
		aEaiRet := FwIntegDef('CTBA040',,,,'CTBA040')
		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
			DisarmTransaction()
			nOpcA := 0
		EndIf
	EndIf
EndIf

//*******************************
// P.E. apos a grava��o do Item *
//*******************************
If l040Grv .and. nOpcA == 1
	ExecBlock("CTB040GR",.F.,.F.,{nOpc})
EndIf

End Transaction

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA040Alt  � Autor � Marcos S. Lobo     � Data � 22/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alteracao de Itens Contabeis         			          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ctba040Alt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBA040Alt(cAlias,nReg,nOpc)

Local l040Grv    := ExistBlock('CTB040GR')
LOCAL bCampo     := {|nCPO| Field(nCPO)}
LOCAL nOpcA      := 0
Local lIntegDef  := FWHasEAI("CTBA040",.T.,,.T.)
Local lEAI040A   := FWHasEAI("CTBA040A",.T.,,.T.)
Local aEaiRet    := {}
LOCAL nY

PRIVATE aCposHistor := {}

DEFAULT nOpc := 4

Begin Transaction

If !lCTB040AUT		// SE FOR ROTINA AUTOMATICA
	nOpcA := AxAltera(cAlias,nReg,nOpc,,,,,"Ct040TudOk(4)")
Else
	nOpcA := AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"Ct040TudOk(4)"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,;
						/*aButtons*/,/*aParam*/,aAutoCab/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,/*lPanelFin*/,/*oFather*/,/*aDim*/,/*uArea*/,/*lFlat*/)
EndIf

If nOpcA == 1
	//�����������������������������������������������������������������������Ŀ
	//� Grava Hist�rico de Altera��es na tabela CW4.                          �
	//�������������������������������������������������������������������������
	If nOpc == 3
		CTBGrvHist(xFilial("CTD"),"CTD"		,CTD->CTD_ITEM,       ,ValType(CTD->CTD_ITEM),"CTD_ITEM",""       ,CTD->CTD_ITEM,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo,cValorAnt,cValorNovo   ,nOpc)
	Else
		For nY := 1 To Len(aCposHistor)
			aCposHistor[nY][3] := CTD->&(EVAL(bCampo,nY))
			If aCposHistor[nY][2] <> aCposHistor[nY][3]
				CTBGrvHist(xFilial("CTD"),"CTD"     ,CTD->CTD_ITEM,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],nOpc)
				//           cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
       		EndIf
   		Next nY
	EndIf

	If lEAI040A
		aEaiRet := FwIntegDef('CTBA040A',,,,'CTBA040A')
		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
			DisarmTransaction()
			nOpcA := 0
		EndIf
	ElseIf lIntegDef // Caso o novo adapter n�o esteja configurado realizo a chamada do adapter antigo
	    // chamada da fun��o integdef
		aEaiRet := FwIntegDef('CTBA040',,,,'CTBA040')
		If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
			aEaiRet := {.F., ""}
		Endif
		If !aEaiRet[1]
			Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
			DisarmTransaction()
			nOpcA := 0
		EndIf
	EndIf
EndIf

//*******************************
// P.E. apos a grava��o do Item *
//*******************************
If l040Grv .and. nOpcA == 1
	ExecBlock('CTB040GR',.F.,.F.,{4})
EndIf

End Transaction

Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctba040del� Autor � Pilar S. Albaladejo   � Data � 05/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Itens Contabeis                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ctba040Del(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctba040Del(cAlias,nReg,nOpc)

Local aSaveArea  := GetArea()
Local l040Grv    := ExistBlock('CTA40DEL')
LOCAL nOpcA      := 0
Local lRet       := .T.
Local oDlg
Local bCampo
Local i
Local aInfo      := {}
Local aPosObj    := {}
Local aObjects   := {}
Local lIntegDef  := FWHasEAI("CTBA040",.T.,,.T.)
Local lEAI040A   := FWHasEAI("CTBA040A",.T.,,.T.)
Local aEaiRet    := {}

PRIVATE aCposHistor := {}
DEFAULT nReg := (cAlias)->(Recno())

//��������������������������������������������������������������Ŀ
//� Carrega Variaveis de Memoria                                 �
//����������������������������������������������������������������
dbSelectArea(cAlias)
bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

Private aTELA[0][0],aGETS[0]

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
If !SoftLock(cAlias)
	Return
EndIf

If !lCTB040AUT		// SE FOR ROTINA AUTOMATICA
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	aPos := {aSize[7],000,aSize[6],aSize[5]}
	ENChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0004), ,aPosObj[1])  //"Quanto � exclus�o?"
	nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},;
											 {|| nOpca := 1,oDlg:End()})
Else
	nOpcA := 2
EndIf

If nOpcA == 2
	//��������������������������������������������Ŀ
	//� Verifica se o item x conta tem valores     �
	//����������������������������������������������
	IF ExiSalCQ("CTD",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,/*cConta*/,/*cCC*/,CTD->CTD_ITEM,/*cClasse*/)
		lRet:=.F.
		Help(" ",1,"ITEMOVIM")
	EndIF
	If !Ct040TudOk(nOpc)
		lRet := .F.
	Endif
	IF lRet
		dbSelectARea("CTD")
		dbSetOrder(2)
		IF CTD->CTD_CLASSE == "1"			// Sintetica
			dbSkip( )
			If !Eof() .And. CTD->CTD_FILIAL == xFilial("CTD") .and. Alltrim(M->CTD_ITEM) == alltrim(CTD->CTD_ITSUP)
				Help(" ",1,"ITEMSINT")
				lRet:=.F.
			EndIf
		EndIf
		dbSetOrder(1)
	EndIf

	If lRet
		lRet := VldEntPCO(cAlias,CTD->CTD_ITEM)
	Endif

	IF lRet
		BEGIN TRANSACTION

		//��������������������������������������������Ŀ
		//� Deleta o Item do Cadastro                  �
		//����������������������������������������������
		dbSelectArea(cAlias)
		MsGoto(nReg)
		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnlock()

		//�����������������������������������������������������Ŀ
		//� Grava Hist�rico de Altera��es na tabela CW4.         �
		//��������������������������������������������������������
		CTBGrvHist(xFilial("CTD"),"CTD"     ,CTD->CTD_ITEM,      ,ValType(CTD->CTD_ITEM),"CTD_ITEM",CTD->CTD_ITEM,""        ,nOpc)
		//		   cFilTabela	 ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo          ,cValorAnt   ,cValorNovo,nOpc)

		If lEAI040A
			aEaiRet := FwIntegDef('CTBA040A',,,,'CTBA040A')
			If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
				aEaiRet := {.F., ""}
			Endif
			If !aEaiRet[1]
				Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
				DisarmTransaction()
				nOpcA := 0
			EndIf
		ElseIf lIntegDef // Caso o novo adapter n�o esteja configurado realizo a chamada do adapter antigo
			// chamada da fun��o integdef
			aEaiRet := FwIntegDef('CTBA040',,,,'CTBA040')
			If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
				aEaiRet := {.F., ""}
			Endif
			If !aEaiRet[1]
				Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
				DisarmTransaction()
				nOpcA := 0
			EndIf
		EndIf

		// Ponto de entrada apos a exclusao do item contabil - BOPS:130433 - 01/11/2007
		If l040Grv .and. nOpcA == 2
			If ExecBlock("CTA40DEL",.F.,.F.,nOpc)
				lRet := .F.
			Endif
		Endif

		END TRANSACTION
	Endif
EndIf

MsUnlockAll()
MsGoTo(nReg)
RestArea(aSaveArea)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CtbITEMLP � Autor � Pilar S. Albaladejo   � Data � 21.02.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Itens Contabeis                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CtbitemLP(cCodigo)                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Item Contabil                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbItemLP(cCodigo)

M->CTD_ITLP := cCodigo

lRefresh := .T.

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctb040NoRe� Autor � Simone Mie Sato       � Data � 22/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se o cod. red.Item foi preenchido com Analiticas.  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTB040NoRe()                                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T./.F.		                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Valida��o no SX3 do campo CTD_RES (Cod. Reduzido)          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION CTB040NoRe()

Local lRet := .T.

If M->CTD_CLASSE == "1"	.And. !empty(M->CTD_RES)					// Analitica
	Help(" ",1,"CA040SINT")
	lRet:=.F.
Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �Ct040TudOk� Autor � Lucimara Soares       � Data � 22.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da pr�via exist�ncia do Item Cont�bil            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct040TudOk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ct040TudOk(nOpc)
LOCAL nY := 0
LOCAL bCampo := {|nCPO| Field(nCPO) }

DEFAULT nOpc := 3

If nOpc == 3
	IF FkInUse() // se a integridade estiver ligada
		If CTD->CTD_ITEM == CTD->CTD_ITLP
			// limpa o campo CTD_ITLP, afim de evitar erro de integridade
			CTD->CTD_ITLP := ''
		Endif
	Endif

	If ! ExistChav("CTD", M-> CTD_ITEM)
		Return .F.
	EndIf
ElseIf nOpc == 4
	IF   M-> CTD_CLASSE != CTD->CTD_CLASSE
		IF ExiSalCQ("CTD",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,/*cConta*/,/*cCC*/,M->CTD_ITEM,/*cClasse*/)
			Help( " " , 1 , "NALTCLASSE" ,, "da classe do item, pois existem movimenta��es para o mesmo." ,3,0)
			Return .F.
     	ENDIF
    ENDIF
Endif
For nY := 1 To FCount()
	AADD(aCposHistor,{CTD->(FieldName(nY)),CTD->&(EVAL(bCampo,nY)),""})
Next nY

If lCTA040TOK
	If ExecBlock("CTA040TOK",.F.,.F.,nOpc)
		Return .F.
	Endif
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Ctb040Sup � Autor � Simone Mie Sato       � Data � 03/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera o c�digo do item  superior a partir do item contab. atu���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb040Sup(cCodigo)                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Valida��o do SX3 do Campo CTD_ITEM                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Item Contabil           				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb040Sup(cCodigo)
Local nEndereco
Local nEnd1,nEnd2
Local cMemMvs := Sv020Mem()		// Funcao que salva os mv_par??

//������������������������������������������������������Ŀ
//� Chamada a funcao que gera o cta superior             �
//��������������������������������������������������������

Pergunte("CTB040",.F.)

If mv_par01 != 3					// Automatico / Formula
	If mv_par01 == 1				// Automatico -> Formula Siga
		M->CTD_ITSUP	:= CtbItemSup(cCodigo)
	ElseIf mv_par01 == 2			// Formula -> do usuario
		If !Empty(mv_par02)
			M->CTD_ITSUP:= &(mv_par02)
		EndIf
	EndIf
EndIf

lRefresh := .T.
Sv020Mem(cMemMvs)


Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBA040LEGEN � Autor � Renato F. Campos  � Data � 29/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a legenda referente ao status                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA040LEGEN()                                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CTBA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctba040leg()

BrwLegenda(STR0011,STR0012,{	{ "BR_VERDE"    , STR0013},;  //"Legenda"###"Item do Centro de Custo"###"Sem Restri��o"
								{ "BR_VERMELHO" , STR0014},;  //"Bloqueado"
								{ "BR_AMARELO"	, STR0015},;  //"Exercicio N�o Inciado"
								{ "BR_CINZA"	, STR0016}})  //"Exercicio Finalizado"


Return Nil

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Paulo Carnelossi      � Data �07/03/07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local lCT040MNU := ExistBlock("CT040MNU")

Local aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"  ,0 , 1},;  //"Pesquisar"
					{ OemToAnsi(STR0002),"AxVisual"  ,0 , 2},;  //"Visualizar"
					{ OemToAnsi(STR0003),"Ctba040Inc",0 , 3},;  //"Incluir"
					{ OemToAnsi(STR0004),"CTBA040Alt",0 , 4},;  //"Alterar"
					{ OemToAnsi(STR0005),"Ctba040Del",0 , 5},;  //"Excluir"
					{ OemToAnsi(STR0017),"Ctba040Imp",0 , 3},;	//"Importar"
					{ OemToAnsi(STR0018),"Ctba040Exp",0 , 4},;	//"Exportar"
					{ OemToAnsi(STR0011),"Ctba040leg",0 , 6},;	//"Legenda"
					{ OemToAnsi(STR0027),"MSDOCUMENT",0 , 4} }	//"Conhecimento"


If lCT040MNU
	aRotina := ExecBlock("CT040MNU",.F.,.F.,{aRotina})
Endif

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA040Exp�Autor  �Marcelo Akama       � Data �  13/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exporta itens contabeis para arquivo .CSV                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA040Exp()
Local aRet		:=	{}

SaveInter()

If ParamBox({	{6,STR0019,padr("",150),"",,"",90 ,.T.,STR0020,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrut. de itens contabeis"###"Arquivo .CSV |*.CSV"
		STR0021,@aRet)  //"Exportar para estrutura de itens contabeis"

	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"CTD",1} } )} )
	oProcess:Activate()

EndIf

RestInter()

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBA040Imp�Autor  �Marcelo Akama       � Data �  13/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Importa itens contabeis de arquivo .CSV                     ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBA040Imp()
Local aRet	:= {}
Local aArea	:= CTD->(GetArea())
Local aCfg
Local cCampos

CTD->(dbGoTop())
If !( CTD->(Eof()) .And. CTD->(Bof()) )
	Aviso(STR0017,STR0022+CRLF+STR0023,{STR0024}) //"Importar"###"A importacao de itens contabeis so pode ser"##"feita com o cadastro de itens contabeis vazio" //"Fechar"
	RestArea(aArea)
	Return .F.
EndIf

SaveInter()

cCampos:="CTD_ITEM,CTD_CLASSE,CTD_NORMAL,CTD_DESC01,CTD_DESC02,CTD_DESC03,CTD_DESC04,CTD_DESC05,CTD_BLOQ,CTD_DTBLIN,CTD_DTBLFI,CTD_DTEXIS,CTD_DTEXSF,CTD_ITLP,CTD_ITPON,CTD_BOOK,CTD_ITSUP,CTD_RES,CTD_CRGNV1,CTD_CRGNV2,CTD_RGNV3,CTD_CLOBRG,CTD_ACCLVL,CTD_ITVM,CTD_ITRED"

aCfg := { { "CTD", cCampos, {||MsExecAuto({|x,y| CTBA040(x,y)}, xAutoCab, 3)} } }

If ParamBox({	{6,STR0019,padr("",150),"",,"", 90 ,.T.,STR0020,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Estrut. de itens contabeis"###"Arquivo .CVE |*.CVE"
		STR0025,@aRet)  //"Importar estrutura de itens contabeis"

	oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfg )} )
	oProcess:Activate()
	lCTB040AUT := .F.

EndIf

RestInter()
RestArea(aArea)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ctb040Item� Autor � Microsiga             � Data � 26/09/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do Item Contabil Digitado -> SX3                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctb040Item()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb040Item()

Local aSaveArea := GetArea()
Local lRet 		:= .T.

lRet := ExistChav("CTD",,1) .And. Ctb040Sup(M->CTD_ITEM) .And. CtbItemLP(M->CTD_ITEM) .And. FreeForUse("CTD",m->ctd_item)

RestArea(aSaveArea)

// Verifica se o item que esta sendo incluido consta no cache como item invalido e atualiza o cache.
AtuVldEnt("CTD", M->CTD_ITEM)

Return lRet

/*/{Protheus.doc} CTBA040A
Fun��o de integra��o para envio e recebimento do item cont�bil
utilizando o conceito de mensagem �nica.

@author  Sidney de Oliveira
@since   26/09/2013
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI040(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
