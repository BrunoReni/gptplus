#INCLUDE "HSPAHA77.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA77  � Autor � Patricia Queiroz   � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Oficios                                        ��� 
�������������������������������������������������������������������������͹��
���Alteracoes� 14/06/06                                                   ���
���          �        Criacao do indice na tabela GCZ para melhorar a     ���
���          �        performance da validacao da exclusao.               ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA77()
Private aRotina := MenuDef()

If HS_LocTab("GH2")
	DbSelectArea("GH2")
	mBrowse(06, 01, 22, 75, "GH2")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A77    � Autor � Patricia Queiroz   � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A77(cAlias, nReg, nOpc)
Local nOpcA := 0

Private nOpcE    := aRotina[nOpc, 4]
Private aTela 			:= {}
Private aGets    := {}
Private aHeader 	:= {}
Private aCols    := {}
Private nUsado   := 0
Private oGH2
Private lGDVazio := .F.

RegToMemory("GH2",(nOpcE == 3)) //Gera variavies de memoria para o GH2

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de Of�cio"

oGH2 := MsMGet():New("GH2", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGH2:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	FS_GrvA77(nOpcE)
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA77 �Autor  �Patricia Queiroz    � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA77(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GH2", (nOpcE == 3))
	HS_GrvCpo("GH2")
	MsUnlock()
	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GH2", .F.)
	DbDelete()
	MsUnlock()
Endif

Return(nOpcE)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValExcl�Autor  �Patricia Queiroz    � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validacao da exclusao.                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ValExcl()

Local aArea := GetArea()
Local lRet	 := .T.

If nOpcE == 5
DbSelectArea("GCZ")
DbSetOrder(20) //GCZ_FILIAL + GCZ_CDCBOR
	If DbSeek(xFilial("GCZ") + M->GH2_CODCBO)
		HS_MsgInf(STR0011, STR0008, STR0010)//"Cadastro de Of�cio possui relacionamento com Guia."##"Aten��o"##"Valida��o de Exclus�o"
		lRet := .F.
	Endif
Endif

	RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldA77 �Autor  �Patricia Queiroz    � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validacao dos campos.                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
 
Function HS_VldA77()
 
Local lRet := .T.
Local aArea := GetArea()

If ReadVar() == "M->GH2_CODCBO"
  DbSetOrder(1) // GH2_FILIAL + GH2_CDCBOR
  If DbSeek(xFilial("GH2") + M->GH2_CODCBO)
    HS_MsgInf(STR0007, STR0008, STR0009) //"Este c�digo j� existe!"###"Aten��o"###"Valida��o de Inclus�o"
    lRet := .F.
  EndIf
EndIf 

RestArea(aArea)

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 11/07/07 ���
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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"	, 0, 1, 0, nil},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A77"		, 0, 2, 0, nil},; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A77"		, 0, 3, 0, nil},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A77"		, 0, 4, 0, nil},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A77"		, 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)
