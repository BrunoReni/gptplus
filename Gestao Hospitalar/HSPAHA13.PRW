#INCLUDE "HSPAHA13.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA13  � Autor � Manoel             � Data �  23/11/01   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE DIETAS                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA13()
 Private cTab      := "TE"
 Private cAlias    := "SX5"
 Private cCadastro := STR0001 //"Dietas"
 Private nOpc      := 0
 Private aRotina   := MenuDef()

 dbSelectArea(cAlias)
 dbSetOrder(1)
 mBrowse(06, 01, 22, 75, "SX5",,,,,,,,,,,,,, "X5_TABELA = '"+cTab+"'") 

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HSPAHA131� Autor �  Manoel               � Data � 23/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA131(nOpc)

 cSayCpo1 := STR0007 //"Codigo"
 cSayCpo2 := STR0008 //"Descricao"

 HS_TelSx5('HS_VExcA13()',,nOpc)
Return

Function HS_VExcA13()
 Local aArea := GetArea()
 Local lRet  := .T.
 
 DbSelectArea("GDY")
 DbSetOrder(2) //GDY_FILIAL + GDY_CODDIE + GDY_ATIVO
 If DbSeek(xFilial("GDY") + M->X5_CHAVE)
  HS_MsgInf(STR0010, STR0011, STR0001) //"Dieta ja utilizada em atendimento. Exclusao nao permitida!"###"Atencao"###"Dietas"
  lRet := .F.
 Endif
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"   , 0, 1, 0, nil},;	//"Pesquisar"
 				     {OemToAnsi(STR0003), 'HSAHA131(2)', 0, 2, 0, nil},;	//"Visualizar"
		             {OemToAnsi(STR0004), 'HSAHA131(3)', 0, 3, 0, nil},;	//"Incluir"
		             {OemToAnsi(STR0005), 'HSAHA131(4)', 0, 4, 2, nil},;	//"Alterar"
		             {OemToAnsi(STR0006), 'HSAHA131(5)', 0, 5, 1, nil}}	//"Excluir"
                     
Return(aRotina)