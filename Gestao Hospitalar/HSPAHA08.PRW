#INCLUDE "HSPAHA08.ch"
#INCLUDE "Protheus.ch"
#include "colors.CH"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA08  � Autor � Eduardo AlveS      � Data �  13/04/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Especialidade                                  ���                                            ���
�������������������������������������������������������������������������͹��    
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA08
 Local aRotReord := {{OemtoAnsi(STR0007), "HSA08REsp()", 0, 4, 0, Nil}, ; 
					{OemtoAnsi(STR0028), 'HSA08RPrc()', 0, 4, 0, Nil}} //"Especialidade" ### "Procedimentos"

 Private cCadastro := STR0001 //"Cadastro de Especialidade"
 Private aRotina := MenuDef()
 Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
 Private cTab := "EM"
 Private cIndex
 Private cKey
 Private cCondicao
 
// Private lGFR := HS_LocTab("GFR", .F.)
// Private cAlias := IIf(lGFR, "GFR", "SX5")
 Private cAlias := "GFR"
 
 If Hs_ExisDic({{"C", "GFR_PRIORI"}}, .F.)
	aAdd(aRotina, {STR0027,	aRotReord, 8, 2}) //"Prioridade"
EndIf

 DbSelectArea(cAlias)
 DbSetOrder(1) //GFR_FILIAL + GFR_CDESPE ou X5_FILIAL + X5_TABELA + X5_CHAVE 
/*
 If lGFR
 	mBrowse( 6, 1, 22, 75, cAlias)
 Else
	 mBrowse( 6, 1, 22, 75, cAlias,,,,,,,,,,,,,, "X5_TABELA = 'EM'")
 EndIf
*/
 mBrowse( 6, 1, 22, 75, cAlias)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A08    �Autor  �Eduardo Alves       � Data �  13/04/06   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao de Tratamento do Cadastro de Especialidade          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A08(cAlias, nReg, nOpc)
Local nOpcA      := 0
Local nGDOpc  := IIF(nOpc == 3 .OR. nOpc == 4,GD_INSERT + GD_UPDATE + GD_DELETE,0)
Local oEnchoi
Private lExbCrit	:= SuperGetMV("MV_CRITCLI", NIL, .F.) //Verifica se Exibe o Folder Para Cadastro de Critica
Private aTela 		:= {}, aGets := {}
Private nOpcE := aRotina[nOpc, 4]
Private oGTM,oFolGTM
Private aCGTM := {}, aHGTM := {}, nUGTM := 0, nLGTM := 0
Private nGTMCODIGO:=0
Private lRet:=.f.
Private  cnome:=""
Private cCodigo :=""  
	
	// Funcao utilizada para alocar o conteudo da tabela memoria
RegToMemory("GFR", (nOpcE == 3))
nOpcA := 0
	
aSize := MsAdvSize(.T.)
aObjects := {} 

If lExbCrit
	AAdd( aObjects, { 100, 030, .T., .T. } )
	AAdd( aObjects, { 100, 070, .T., .T. } )
Else
	AAdd( aObjects, { 100, 100, .T., .T. } )
Endif  

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlgA08 TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
	
	oEnchoi := MsMGet():New("GFR",nReg,nOpcE, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlgA08)
	oEnchoi :oBox:align:= CONTROL_ALIGN_TOP
	
	If lExbCrit	

		nLGTM := HS_BDados("GTM", @aHGTM, @aCGTM, @nUGTM, 1,M->GFR_CDESPE ,IIF(aRotina[nOpcE, 4] # 3,"GTM->GTM_CODESP == '" + M->GFR_CDESPE + "'", Nil))
		nGTMCODIGO := aScan(aHGTM, {| aVet | aVet[2] == "GTM_CODCRI"})
		
		@ aPObjs[2, 1], aPObjs[2, 1] FOLDER oFolGTM SIZE aPObjs[2, 1], aPObjs[2, 1] OF oDlgA08 PROMPTS STR0029 PIXEL // "Criticas"
	    oFolGTM:Align:= CONTROL_ALIGN_ALLCLIENT
	    
	    oGTM := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_DuplAC(oGTM:oBrowse:nAt, oGTM:aCols, {nGTMCODIGO})",,,,,,,,, oFolGTM:aDialogs[1], aHGTM, aCGTM)
	    oGTM:bLinhaOK      := {|| !empty(oGTM:aCols[oGTM:oBrowse:nAt, nGTMCODIGO]) }  
	    oGTM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    Endif
	
	ACTIVATE MSDIALOG oDlgA08 ON INIT EnchoiceBar (oDlgA08, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlgA08:End(), nOpcA := 0)},;
	{|| nOpcA := 0, oDlgA08:End()})
	
	If (nOpcA == 1) .And. (nOpcE <> 2) // Em caso de Inclusao, Alteracao ou Exclusao e o botao OK pressionado.
		Begin Transaction
		FS_GrvA08(nOpcE)
		End Transaction
	EndIf
	
/*Else
	cSayCpo1 := STR0007 //"Especialidade"
	cSayCpo2 := STR0008 //"Descri��o"
	
	HS_TelSx5('HS_VldExc(M->X5_CHAVE)',,nOpc)
	
EndIf */

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA08 �Autor  �Eduardo Alves       � Data �  13/04/06   ���
�������������������������������������������������������������������������͹��
���Descri��o �Funcao de Gravacao ou Exclusao de Especialidade             ���                                                           ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA08(nOpc)
Local aArea := GetArea()
Local lEspelhar := GetNewPar("MV_INTESPE",.F.)
Local lNovBAQ 	:= .T.

//������������������������������������������������������Ŀ
//� Espelhamento GFR X BAQ...                            �
//��������������������������������������������������������
If nOpcE == 3   //Inclusao
	//������������������������������������������������������Ŀ
	//� Verifica se aEspecialidade ja existe Tabela PLS                  �
	//��������������������������������������������������������
	
	If lEspelhar
		
		If  ! Empty(M->GFR_CDESPE)
			DbSelectArea("BAQ")
			BAQ->(DbSetOrder(6))
			lNovBAQ := (BAQ->(MsSeek(xFilial("BAQ")+M->GFR_CDESPE)))
		Endif
	Else
		lNovBAQ := .T.
	Endif
	
	//������������������������������������������������������Ŀ
	//� Verifica se deve criar Especialidade no Plano de Saude�
	//��������������������������������������������������������
	If  ! LNovBAQ
		DbSelectArea("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHA08  "+"GFR"+"BAQ"))
			BAQ->(RecLock("BAQ",.T.))
			BAQ->BAQ_FILIAL := xFilial("BAQ")
			IF GFR->(FieldPos("GFR_CODINT"))>0 
				BAQ->BAQ_CODINT := M->GFR_CODINT
			Endif			
			PlsSinc("HSPAHA08","GFR","BAQ")
			BAQ->(MsUnLock())
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0018)) //"Arquivo de sincronismo entre BAQ x GFR nao esta integro. Verifique!"
			Endif
		Endif
		
	Endif
	
	RecLock("GFR",.T.)
	HS_GrvCpo("GFR")
	GFR->GFR_FILIAL:=xFilial("GFR")
	GFR->GFR_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
	
ElseIf nOpcE == 4
	If lEspelhar
		DbSelectArea("BAQ")
		BAQ->(DbSetOrder(6))
		If BAQ->(MsSeek(xFilial("BAQ")+M->GFR_CDESPE))
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If BBL->(MsSeek(xFilial("BBL")+"HSPAHA08  "+"GFR"+"BAQ"))
				BAQ->(RecLock("BAQ",.F.))
				BAQ->BAQ_FILIAL := xFilial("BAQ") 
				IF GFR->(FieldPos("GFR_CODINT"))>0
					If !Empty(M->GFR_CODINT) 
						BAQ->BAQ_CODINT := M->GFR_CODINT
					Endif
				Endif			
				PlsSinc("HSPAHA08","GFR","BAQ")
				BAQ->(MsUnLock())
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0018)) //"Arquivo de sincronismo entre BAQ x GFR nao esta integro. Verifique!"
				Endif
			Endif
		Endif
	Endif
	
	RecLock("GFR", .F.)
	HS_GrvCpo("GFR")
	GFR->GFR_FILIAL:=xFilial("GFR")
	GFR->GFR_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
ElseIf nOpcE == 5
	
	If HS_VldExc(M->GFR_CDESPE)
		If lEspelhar
			DbSelectArea("BAQ")
			BAQ->(DbSetOrder(6))
			If BAQ->(MsSeek(xFilial("BAQ")+M->GFR_CDESPE)) .and. PLSA370EXC(FunName())
				DbSelectArea("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"HSPAHA08  "+"GFR"+"BAQ"))
					RecLock("BAQ", .F.)
					DbDelete()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0018)) //"Arquivo de sincronismo entre BAQ x GFR nao esta integro. Verifique!"
					Endif
				Endif
			Endif
		Endif
		
		RecLock("GFR", .F., .T.)
		DbDelete()
		MsUnLock()
		

	EndIf
	
Endif
If lExbCrit
	Fs_GrvItm("GTM",oGTM, nGTMCODIGO,nOpc)
Endif

RestArea(aArea)

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldExc �Autor  �Eduardo Alves       � Data �  20/04/06   ���
�������������������������������������������������������������������������͹��
���Descri��o �Funcao de Valida��o da Exclusao/Sincronismo de Especialidade���
���          �Verifica se o Registro poder� realizar Sincronismo entre 	  ���
��� os modulos PLS e GH													  ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_VldExc(cCodEsp)

Local lRet      := .T.



// Validacoes para Exclusao da Especialidade

// Profissional: Verifica nos 3 campos de especialidades existentes;

DbSelectArea("GBJ")
DbSetOrder(2) //GBJ_FILIAL + GBJ_ESPEC1
If DbSeek(xFilial("GBJ") + cCodEsp)
	If FunName() # "PLSA370"
		HS_MsgInf( STR0010, STR0013, STR0009) //"Este registro est� sendo utilizado no Cadastro de Profissionais. Exclus�o n�o permitida!"##"Aten��o"##"Valida��o de Exclus�o"
	Else
		HS_MsgInf(STR0019, STR0020, STR0021) //"Este registro est� sendo utilizado no Cadastro de Profissionais .", "Sincronismo  n�o Efetuado na Tabela do SIGAHSP", "Valida��o de Sincronismo da Especialidade no Modulo SIGAHSP"
	Endif
	
	lRet := .F.
End

If lRet
	DbSetOrder(3) //GBJ_FILIAL + GBJ_ESPEC2
	If DbSeek(xFilial("GBJ") + cCodEsp)
		If	FunName() # "PLSA370"
			HS_MsgInf(STR0010, STR0013, STR0009) //"Este registro est� sendo utilizado no Cadastro de Profissionais. Exclus�o n�o permitida!"##"Aten��o"##"Valida��o de Exclus�o"
		Else
			HS_MsgInf(STR0019, STR0020, STR0021) //"Este registro est� sendo utilizado no Cadastro de Profissionais .", "Sincronismo  n�o Efetuado na Tabela do SIGAHSP", "Valida��o de Sincronismo da Especialidade no Modulo SIGAHSP"
		Endif
		
		lRet := .F.
	EndIf
EndIf

If lRet
	DbSetOrder(4) //GBJ_FILIAL + GBJ_ESPEC3
	If DbSeek(xFilial("GBJ") + cCodEsp)
		IF FunName() # "PLSA370"
			HS_MsgInf(STR0010, STR0013, STR0009) //"Este registro est� sendo utilizado no Cadastro de Profissionais. Exclus�o n�o permitida!"##"Aten��o"##"Valida��o de Exclus�o"
		Else
			HS_MsgInf(STR0019, STR0020, STR0021) //"Este registro est� sendo utilizado no Cadastro de Profissionais .", "Sincronismo  n�o Efetuado na Tabela do SIGAHSP", "Valida��o de Sincronismo da Especialidade no Modulo SIGAHSP"
		Endif
		
		lRet := .F.
	EndIf
EndIf

//GFP - Relacionamento Especialidade x Profissional
If lRet .And. HS_LocTab("GFP", .F.)
	If HS_CountTB("GFP", "GFP_CODESP  = '" + cCodEsp + "'")  > 0
		If	FunName() # "PLSA370"
			HS_MsgInf(	STR0012, STR0013, STR0009) //"Este registro est� sendo utilizado no relacionamento EspecialidadexProfissional. Exclus�o n�o permitida!"##"Aten��o"##"Valida��o de Exclus�o"
		Else
			HS_MsgInf(STR0022, STR0020, STR0021)	//"Este registro est�  sendo utilizado no relacionamento EspecialidadexProfissional .", "Sincronismo  n�o Efetuado na Tabela do SIGAHSP", "Valida��o de Sincronismo da Especialidade no Modulo SIGAHSP"
		Endif
		
		lRet := .F.
	EndIf
EndIf

// GA7 - Cadastro de Procedimento
If lRet
	DbSelectArea("GA7")
	DbSetOrder(7) //GA7_FILIAL + GA7_CODESP
	If DbSeek(xFilial("GA7") + cCodEsp)
		If	FunName() # "PLSA370"
			HS_MsgInf(  STR0011, STR0013, STR0009) //"Este registro est� sendo utilizado no Cadastro de Procedimentos. Exclus�o n�o permitida!"##"Aten��o"##"Valida��o de Exclus�o"
		Else
			HS_MsgInf(STR0023, STR0020, STR0021)	//"Este registro est�  sendo utilizado no relacionamento EspecialidadexProfissional .", "Sincronismo  n�o Efetuado na Tabela do SIGAHSP", "Valida��o de Sincronismo da Especialidade no Modulo SIGAHSP"
		Endif
		
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldA08 � Autor � Patricia Queiroz   � Data �  30/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para validacao dos campos.                          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_VldA08()
Local lRet := .T.
Local aArea := GetArea()

If ReadVar() == "M->GFR_CDESPE"
	DbSetOrder(1) //GFR_FILIAL + GFR_CDESPE
	If DbSeek(xFilial("GFR") + M->GFR_CDESPE)
		HS_MsgInf(STR0014, STR0013, STR0016) //"Este c�digo j� existe!"##"Aten��o"##"Valida��o de Inclus�o"
		lRet := .F.
	EndIf
	
ElseIf !Empty(M->GFR_CBOSUS) .And. ReadVar() == "M->GFR_CBOSUS"
	If !HS_SeekRet("GH1","M->GFR_CBOSUS",1,.f.,"GFR_DCBSUS","GH1_DESCBO")
		HS_MsgInf("C�digo de CBO n�o encontrado no cadastro de CBO SUS.", STR0013, "Valida��o SUS")  //"Codigo do Grupo AMB invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
		lRet := .F.
	EndIf
ElseIf !Empty(M->GFR_TPASUS) .And. ReadVar() == "M->GFR_TPASUS"
	If !HS_SeekRet("GJ3","M->GFR_TPASUS",1,.f.,"GFR_DTPSUS","GJ3_DESCRI")
		HS_MsgInf("Tipo de Acomoda��o invalido!", STR0013, "Valida��o SUS")  //"Codigo do Grupo AMB invalido"###"Atencao"###"Credenciamento de Medicos por Convenio"
		lRet := .F.
	EndIf	
ElseIf ReadVar() == "M->GTM_CODCRI"
	If !(lRet := HS_SeekRet("GTK", "M->GTM_CODCRI", 1, .F., "GTM_DESCRI", "GTK_DESCR") )
		HS_MsgInf(STR0024, STR0013, STR0025)  //"Critica N�o Cadastrada"###"Aten��o"###"Valida��o de Cr�ticas
	EndIf		
EndIf

RestArea(aArea)

Return(lRet) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldA08 � Autor � Patricia Queiroz   � Data �  05/05/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para Gravar os Itens de Critica                     ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fs_GrvItm(cAliasRel,oGdObj, nPosChv,nOpc)
Local aArea  := GetArea()
Local nI    := 0
Local lFound := .F.

For nI := 1 to Len(oGdObj:aCols)
	DbSelectArea(cAliasRel)
	DBSetOrder(1)
	
	lFound := DbSeek(xFilial(cAliasRel) + M->GFR_CDESPE + oGdObj:aCols[nI, nPosChv])
	
	If Inclui .Or. Altera .And. !(oGdObj:aCols[nI, len(oGdObj:aHeader) + 1])
		if !empty(oGdObj:aCols[nI, nPosChv])
			RecLock(cAliasRel, !lFound)
			HS_GrvCpo(cAliasRel, oGdObj:aCols, oGdObj:aHeader, nI)
			&(cAliasRel+"->"+cAliasRel+"_FILIAL") := xFilial(cAliasRel)
			&(cAliasRel+"->"+cAliasRel+"_CODESP") := M->GFR_CDESPE
			MsUnlock()
		endif
	ElseIf lFound
		RecLock(cAliasRel, .F.)
		DbDelete()
		MsUnlock()
		WriteSx2(cAliasRel)
	EndIf
	
next nI

RestArea(aArea)
Return()




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 06/06/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
 Local aRotina :=	{ {STR0002,	"AxPesqui", 0, 1, 0, nil} ,; //"Pesquisar"
                    {STR0003,	"HS_A08"		, 0, 2, 0, nil} ,; //"Visualizar"
                    {STR0004,	"HS_A08"		, 0, 3, 0, nil} ,; //"Incluir"
                    {STR0005,	"HS_A08"		, 0, 4, 0, nil} ,; //"Alterar"
                    {STR0006,	"HS_A08"		, 0, 5, 0, nil} }  //"Excluir"
                    
 Local aA08Rot := Nil       
 
/* 
 Local aRotReord := {{OemtoAnsi(STR0007), "HSA08REsp()", 0, 4, 0, Nil}, ; 
					{OemtoAnsi(STR0028), 'HSA08RPrc()', 0, 4, 0, Nil}} //"Especialidade" ### "Procedimentos"


If Hs_ExisDic({{"C", "GFR_PRIORI"}}, .F.)
	aAdd(aRotina, {STR0027,	aRotReord, 8, 2}) //"Prioridade"
EndIf
*/
                       
 If ExistBlock("HSA08ROT")
 	aA08Rot := ExecBlock("HSA08ROT", .F., .F., {aRotina})
 	If ValType(aA08Rot) == "A"
 	 aRotina := aClone(aA08Rot[1])
 	EndIf
 EndIf

Return(aRotina)
