#INCLUDE "HSPAHAA6.ch"
#include "protheus.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAA6  � Autor � Jos� Orfeu         � Data �  07/12/2004 ���
�������������������������������������������������������������������������͹��
���Descricao � Carater do atendimento                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � HSPAHAA6 � Autor � Jos� Orfeu            � Data �07/12/2004���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carater de atendimento                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HSPAHAA6(void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Administracao Hospitalar 																																		���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Eduardo Alves�30/05/06� XXXX �  Inclusao do campos Codigo do SUS      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION HSPAHAA6()
 Private cCadastro := STR0001 //"Cadastro de carater do atendimento"
 Private aRotina := MenuDef()

 DbSelectArea("GD1")
 DbSetOrder(1)

 mBrowse( 6,1,22,75, "GD1")
Return(Nil)

Function HS_VEAA6()
 Local lRet := .T., cAliasOld := Alias()
 
 DbSelectArea("GCY")
 DbSetOrder(6)
 
 If !(lRet := !DBSeek(xFilial("GCY") + GD1->GD1_CARATE))
  Help(" ", 1, "HAA6RELGCY",, STR0007, 1) //"Registro encontrado no atendimento e n�o pode ser excluido"
 EndIf  
  
 DbSelectArea(cAliasOld)
Return( lRet )

Function HS_AA6(cAlias, nReg, nOpc)
 Local nOpcA := 0
 
 Private cDelFunc := "HS_VEAA6()"

 If nOpc == 3
  nOpcA := axInclui("GD1",, nOpc,,,, /*Fun��o para validar  a inclusao*/) 
 ElseIf nOpc == 5
  nOpcA := axDeleta("GD1", nReg, nOpc)
 EndIf                            
Return(nOpcA)

Function HS_VldAA6()
	Local lRet 	:= .T.
	Local aArea	:= GetArea()
	
	/* Codigo do SUS */
	If ReadVar() == "M->GD1_CATAIH"
		If !Empty(M->GD1_CATAIH)		
			DbSelectArea("GD1")
			DbSetOrder(3)
			If DbSeek(xFilial("GD1") + M->GD1_CATAIH)
				If (M->GD1_CARATE # GD1->GD1_CARATE)
					HS_MsgInf(STR0008, STR0009, STR0010) //"C�digo do SUS j� cadastrado!"###"Aten��o"###"Valida��o dos Campos"
					lRet := .F.
				EndIf
			EndIf
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

Local aRotina :=	{{STR0002, "AxPesqui", 0, 1, 0, nil},; //"Pesquisar"
                     {STR0003, "AxVisual", 0, 2, 0, nil},; //"Visualizar"
                     {STR0004, "HS_AA6"  , 0, 3, 0, nil},; //"Incluir"
                     {STR0005, "axAltera", 0, 4, 0, nil},; //"Alterar"
                     {STR0006, "HS_AA6"  , 0, 5, 0, nil}}  //"Excluir" 
                     
                   

                     

	
    	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GD1',GD1->GD1_CARATE, 1)})", 0 ,})
		aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GD1',GD1->GD1_CARATE, 0)})", 0 ,})                  

                   
                     
                     
Return(aRotina)