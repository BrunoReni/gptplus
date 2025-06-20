#INCLUDE "HSPAHABR.ch"
#include "protheus.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABR  � Autor � Marcelo Jose       � Data �  14/03/06   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE NACIONALIDADES VIA SX5(34) PADRAO              ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HSPAHABR()
Private cIndex
Private cKey
Private cCondicao
Private cTab      := "34"
Private cAlias    := "SX5"
Private cCadastro := STR0001 //"Nacionalidades"
Private nOpc      := 0
Private aRotina   := MenuDef()

DbSelectArea(cAlias)
DbSetOrder(1)
cFiltro := "X5_TABELA = '" +cTab+ "'"
mBrowse(06, 01, 22, 75, "SX5",,,,,,,,,,,,,, cFiltro)
Return( Nil )


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_GerABR � Autor �  Marcelo Jose         � Data �14/03/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_GerABR(nOpc)
cSayCpo1 := STR0007 //"Codigo"
cSayCpo2 := STR0008 //"Descricao"
HS_TelSx5('HS_ExcABR()',,nOpc)
Return( Nil )
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HS_ExcABR� Autor �  Marcelo Jose         � Data �14/03/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao de Exclusao                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_ExcABR()
Local lRet := .T., cSql := "", cAliasQry := "GBHABR"

If GBH->(FieldPos("GBH_CODNAC")) > 0
	cSql := "SELECT COUNT(GBH.GBH_CODNAC) AS SOMA FROM " + RetSQLName("GBH") + " GBH "
	cSql += " WHERE GBH.GBH_CODNAC = '" + M->X5_CHAVE + "' AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasQry,.T.,.T.)
	DbSelectArea(cAliasQry)
	If (cAliasQry)->SOMA > 0
		HS_MsgInf(STR0009, STR0010, STR0011)  //"Esta Nacionalidade esta sendo usada no cadastro de Pacientes. Operacao cancelada."###"Atencao..."###"Valida��o de exclusao"
		lRet := .F.
	End
	dbCloseArea()
	dbSelectArea(cAlias)
	dbSetOrder(1)
EndIf

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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"    , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0003), "HS_GerABR(2)", 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), "HS_GerABR(3)", 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), "HS_GerABR(4)", 0, 4, 2, nil},; //"Alterar"
                     {OemToAnsi(STR0006), "HS_GerABR(5)", 0, 5, 1, nil}}  //"Excluir" 
Return(aRotina)