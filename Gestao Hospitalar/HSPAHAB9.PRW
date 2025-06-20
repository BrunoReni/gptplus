#INCLUDE "HSPAHAB9.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAB9  � Autor � Patricia Queiroz   � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Vias de Acesso                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAB9()

Private aRotina := MenuDef()
                    
	mBrowse(06, 01, 22, 75, "GE4")
	
Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_AB9    � Autor � Patricia Queiroz   � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_AB9(cAlias, nReg, nOpc) 


Local nOpcA := 0

Private nOpcE    := aRotina[nOpc, 4]
Private aTela 		 := {}
Private aGets    := {}
Private aHeader  := {}
Private aCols    := {}
Private nUsado   := 0
Private oGE4
Private lGDVazio := .F.

RegToMemory("GE4", (nOpcE == 3)) 

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd(aObjects, {100, 100, .T., .T.})

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Cadastro de Vias de Acesso"

oGE4 := MsMGet():New("GE4", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGE4:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)}, ;
																																																		{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	FS_GrvAB9(nOpcE)
EndIf

Return(Nil)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvAB9 �Autor  �Patricia Queiroz    � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvAB9(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
	RecLock("GE4", (nOpcE == 3))
	HS_GrvCpo("GE4")
	MsUnlock()	
ElseIf nOpcE == 5 //Excluir
	RecLock("GE4", .F.)
	DbDelete()
	MsUnlock()
EndIf

Return(nOpcE)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValExcl�Autor  �Patricia Queiroz    � Data �  13/09/06   ���
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
 If HS_CountTB("GD7", "GD7_CODVIA = '" + GE4->GE4_CODVIA + "'")  > 0
 	HS_MsgInf(STR0014 + ". " + STR0013, STR0008, STR0009)  //"O registro possui relacionamento com despesas de Procedimentos(GD7)"###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o de Exclus�o"
	 lRet := .F.	
 EndIf   

 If lRet .And. HS_CountTB("GE7", "GE7_CODVIA = '" + GE4->GE4_CODVIA + "'")  > 0
 	 HS_MsgInf(STR0015 + ". " + STR0013 , STR0008, STR0009) //"O registro possui relacionamento com despesas de Procedimentos(GE7)"###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o de Exclus�o"
	  lRet := .F.	 
	 EndIf 	 
	
 If lRet .And. HS_CountTB("GO7", "GO7_CODVIA = '" + GE4->GE4_CODVIA + "'")  > 0
 	 HS_MsgInf(STR0016 + ". " + STR0013, STR0008, STR0009) //"O registro possui relacionamento com despesas de Procedimentos(GO7)"###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o de Exclus�o"
    lRet := .F.
  EndIf

EndIf 

RestArea(aArea)

Return(lRet)


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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"	, 0, 1, 0, nil},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_AB9"  	, 0, 2, 0, nil},; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_AB9"		, 0, 3, 0, nil},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_AB9"		, 0, 4, 0, nil},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_AB9"		, 0, 5, 0, nil}}  //"Excluir"
Return(aRotina)
