#INCLUDE "HSPAHA25.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA25  � Autor � L.Gustavo Caloi    � Data �  12/04/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Porte Anestesico de Cirurgia                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA25()
 Private aRotina := MenuDef()
                          
 DbSelectArea("GA3")
 mBrowse(06, 01, 22, 75, "GA3")
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A25    � Autor � L.Gustavo Caloi    � Data �  12/04/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A25(cAlias, nReg, nOpc)
 Local nOpcA      := 0
 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela 	  := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGA3
 Private lGDVazio := .F.

 RegToMemory("GA3",(nOpcE == 3)) //Gera variavies de memoria para o GA3

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Porte Anest�sico de Cirurgia"

  oGA3 := MsMGet():New("GA3", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
  oGA3:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ExclA25(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  Begin Transaction
 	 FS_GrvA25(nReg)
 	End Transaction
 EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA25 �Autor  �L.Gustavo Caloi     � Data �  12/04/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA25(nReg)
 Local aArea := GetArea()

 DbSelectArea("GA3")
 If nOpcE <> 3
  DbGoTo(nReg)
 Endif
  
 If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	 RecLock("GA3", (nOpcE == 3))
	  HS_GrvCpo("GA3")
 	  GA3->GA3_LOGARQ := HS_LOGARQ()
	 MsUnlock()

 ElseIf nOpcE == 5 //Exclusao
	 RecLock("GA3", .F.)
	  DbDelete()
	 MsUnlock()
 Endif

 RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ExclA25� Autor �L.Gustavo Caloi        � Data � 12/04/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ExclA25()
 Local aArea := GetArea()
 Local lRet	 := .T.
 
 If nOpcE == 5
  If HS_CountTB("GA8", "GA8_CODPAN  = '" + M->GA3_CODPAN + "'")  > 0
  	HS_MsgInf(STR0009, STR0007, STR0008) //"Existe(m) procedimento(s) cadastrado(s) com este porte anest�sico. Exclus�o n�o permitida"###"Aten��o"###"Valida��o da Exclus�o"
  	lRet := .F.
  Endif	
 Endif 
           
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
Local aRotina :=	{{OemtoAnsi(STR0001) , "axPesqui" , 0, 1, 0, nil}, ; //"Pesquisar"
                     {OemtoAnsi(STR0002) , "HS_A25"   , 0, 2, 0, nil}, ; //"Visualizar"
                     {OemtoAnsi(STR0003) , "HS_A25"   , 0, 3, 0, nil}, ; //"Incluir"
                     {OemtoAnsi(STR0004) , "HS_A25"   , 0, 4, 0, nil}, ; //"Alterar"
                     {OemtoAnsi(STR0005) , "HS_A25"   , 0, 5, 0, nil} }  //"Excluir"
Return(aRotina)