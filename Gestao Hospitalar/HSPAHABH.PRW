#INCLUDE "HSPAHABH.ch"
#INCLUDE "protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABH  � Autor � MARCELO JOSE       � Data �  09/06/05   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE DESTINO DE PACIENTES                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��  
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHABH()

Private cCadastro := STR0001 //"Cadastro de Destino do Paciente"
Private aRotina   := MenuDef()

Private cDelFunc := "HS_VALEXC()" 

Private cString := "GEV"

dbSelectArea("GEV")
dbSetOrder(1)



dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VALEXC � Autor � MARIO ARIZONO      � Data �  16/12/05   ���
�������������������������������������������������������������������������͹��
���Descricao � FUNCAO PARA VALIDACAO DA EXCLUSAO                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

FUNCTION HS_VALEXC()
 
 Local lRet := .T.
 
 DbselectArea("GCY")
 Dbsetorder(12)
 
 If DBSeek(xFilial("GCY")+GEV->GEV_CODIGO)   //GCY_FILIAL+GCY_CATENDI
  HS_MsgInf(STR0007, STR0008, STR0009) //"Destino nao pode ser excluido, pois esta sendo usado no atendimento"###"Atencao"###"Valida��o de Exclus�o"
  lRet:= .F.
 Endif  
 
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
Local aRotina :=	{{STR0006, "AxPesqui", 0, 1, 0, nil},; //"Pesquisar"
                     {STR0002, "AxVisual", 0, 2, 0, nil},; //"Visualizar"
                     {STR0003, "AxInclui", 0, 3, 0, nil},; //"Incluir"
                     {STR0004, "AxAltera", 0, 4, 0, nil},; //"Alterar"
                     {STR0005, "AxDeleta", 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)