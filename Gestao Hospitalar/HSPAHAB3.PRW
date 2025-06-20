#INCLUDE "HSPAHAB3.ch"
#INCLUDE "Protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAB3  � Autor � MARCELO JOSE       � Data �  11/01/05   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE CAUCAO                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP7 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
 Function HSPAHAB3()

 Private cCadastro := STR0001 //"Cadastro de Caucao"

 Private aRotina := MenuDef()

 Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

 Private cString := "GDL"

 dbSelectArea("GDL")
 dbSetOrder(1)

 dbSelectArea(cString)
 mBrowse( 6,1,22,75,cString)

Return


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
Local aRotina :=	{{STR0002, "AxPesqui", 0, 1, 0, nil},; //"Pesquisar"
                     {STR0003, "AxVisual", 0, 2, 0, nil},; //"Visualizar"
                     {STR0004, "AxInclui", 0, 3, 0, nil},; //"Incluir"
                     {STR0005, "AxAltera", 0, 4, 0, nil},; //"Alterar"
                     {STR0006, "AxDeleta", 0, 5, 0, nil}}  //"Excluir"
Return(aRotina)