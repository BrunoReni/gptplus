#INCLUDE "HSPAHA34.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA34  � Autor � Manoel             � Data �  11/12/01   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE Armazens 	                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA34()

 Private cTab      := "AL"
 Private cAlias    := "SX5"
 Private cCadastro := STR0001 //"Armazens"
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
���Fun��o    � HSPAHA341 � Autor �  Manoel            � Data � 11/12/2001 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA341(nOpc)

 cSayCpo1 := STR0007 //"Codigo"
 cSayCpo2 := STR0008 //"Armazem"

 HS_TelSx5('HS_Exc34()',,nOpc)

Return

/******************************************************************************************************************/

// Funcao de Exclusao
Function HS_Exc34()
 DbSelectArea("GAI")
 DbSetOrder(5)
 If DbSeek(xFilial("GAI") + PADR(M->X5_CHAVE,2) )
  HS_MsgInf(STR0010, STR0009, STR0012) //"Existe este Codigo de Armazem no Arquivo de Solicitacoes (GAI). Impossivel Exclui-lo!"###"Aten��o"###"Inclusao/Alteracao/Visualizacao"
  Return(.F.)
 Endif   
 DbSelectArea("GCS")
 DbSetOrder(1)
 DBGotop()
 Do While !Eof()
  If GCS->GCS_ARMSET == Padr(M->X5_CHAVE,2)
   HS_MsgInf(STR0011+AllTrim(GCS->GCS_NOMLOC)+STR0013, STR0009, STR0012) //"Este Codigo Esta relacionado no Cadastro de Setor: "###" ...Impossivel exclui-lo."###"Aten��o"###"Inclusao/Alteracao/Visualizacao"
   Return(.F.)
  Endif
  DbSkip()
 End         
 nOpca := 1
 oDlg:End()          

Return(.T.)


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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"   , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0003), 'HSAHA341(2)', 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), 'HSAHA341(3)', 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), 'HSAHA341(4)', 0, 4, 2, nil},; //"Alterar"
                     {OemToAnsi(STR0006), 'HSAHA341(5)', 0, 5, 1, nil}}  //"Excluir" 
Return(aRotina)