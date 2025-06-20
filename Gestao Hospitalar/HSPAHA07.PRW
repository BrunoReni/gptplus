#INCLUDE "HSPAHA07.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA07  � Autor � Manoel             � Data �  23/11/01   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE CATEGORIAS DE TAXAS E DIARIAS                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA07()                   
                                                                             
 Private cTab := "CT"
 Private cIndex 
 Private cKey
 Private cCondicao
 Private cAlias := "SX5"
 Private cCadastro := STR0001 //"Categorias de Taxas e Diarias"
 Private nOpc    := 0
 Private aRotina := MenuDef()

 dbSelectArea(cAlias)
 dbSetOrder(1)
 mBrowse(06, 01, 22, 75, "SX5",,,,,,,,,,,,,, "X5_TABELA = '"+cTab+"'")  

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HSPAHA071� Autor �  Manoel            � Data � 23/11/2001 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA071(nOpc)

 cSayCpo1 := STR0007 //"Codigo da Categoria"
 cSayCpo2 := STR0008 //"Descricao"

 HS_TelSx5('HS_Exc07()',,nOpc)

Return

// Funcao de Exclusao
Function Hs_Exc07() 
 Local lRet := .T.
 DbSelectArea("GAA")
 DbSetOrder(4)
 if DbSeek(xFilial("GAA")+M->X5_CHAVE)
  HS_MsgInf(STR0009, STR0011, STR0001)//"Existe esta Categoria de Taxa / Diaria no Cadastro de Taxas / Diarias (GAA). Impossivel Exclui-la!" //"Atencao"//"Categorias de Taxas e Diarias"
  Return(.T.)
 EndIf
 DbSelectArea(cAlias)
 If lRet 
  nOpca := 1
  oDlg:End()          
 EndIf 
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"   , 0, 1, 0, nil}, ; //"Pesquisar"
		             {OemToAnsi(STR0003), 'HSAHA071(2)', 0, 2, 0, nil}, ; //"Visualizar"
        		     {OemToAnsi(STR0004), 'HSAHA071(3)', 0, 3, 0, nil}, ; //"Incluir"
		             {OemToAnsi(STR0005), 'HSAHA071(4)', 0, 4, 2, nil}, ; //"Alterar"
		             {OemToAnsi(STR0006), 'HSAHA071(5)', 0, 5, 1, nil}}   //"Excluir"
Return(aRotina)