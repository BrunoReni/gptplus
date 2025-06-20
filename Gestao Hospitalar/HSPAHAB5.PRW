#INCLUDE "HSPAHAB5.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAB5  � Autor � Cibele Peria       � Data �  27/01/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Regras de Credenciamento Medico por Prioridade ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAB5()
 Private aRotina, cCadastrO
 cCadastro := STR0001 //"Cadastro de Regras de Credenciamento Medico"
 aRotina := MenuDef()
 

 dbSelectArea("GDV")
 dbSetOrder(1)
 mBrowse(06, 01, 22, 75, "GDV")
 
Return(Nil)


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
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui"    , 0, 1, 0, nil},; //"Pesquisar"
             		 {OemToAnsi(STR0003), "axVisual"    , 0, 2, 0, nil},; //"Visualizar"
             		 {OemToAnsi(STR0004), "axAltera"    , 0, 4, 0, nil}}   //"Alterar"
Return(aRotina)