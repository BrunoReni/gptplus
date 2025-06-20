#INCLUDE "OMSA170.ch"


/*/{Protheus.doc} MenuDef
** Funcao reescrita para nao chamar menu def do MATXATU
@author Equipe OMS
@since 03/03/2022
/*/
Static Function MenuDef()
	Local aRotina

	aRotina := { { oemtoansi(STR0002),"AxPesqui", 0 , 1,,.F.},; // "Pesquisar"
	{ oemtoansi(STR0003),"AxCadVis", 0 , 2},; // "Visualizar"
	{ oemtoansi(STR0004),"AxCadInc", 0 , 3},; //"Incluir"
	{ oemtoansi(STR0005),"AxCadAlt", 0 , 4},; //"Alterar"
	{ oemtoansi(STR0006),"AxCadDel", 0 , 5}}  //"Excluir"
Return aRotina

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Funcao   � OMSA170  � Autor � Waldemiro L. Lustosa  � Data � 01/09/1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA51  �                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Descricao� Cadastro de Grupos para Acerto Financeiro                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                  ���
���������������������������������������������������������������������������Ĵ��
��� Observ.  � Convers�o da antiga tabela D8                                ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
��� Conversao p/ Protheus (OMSA170)                � Cristiane   � 20/01/00 ���
���                                                � Moreto      �          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function OMSA170()

AxCadastro("DAX",STR0001) //"Grupos para Acerto Financeiro"

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � D170VCOD � Autor � Waldemiro L. Lustosa  � Data � 01.09.99 ���
�������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA511 �                                                 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacao do C�digo digitado - Grupos para Acerto Financ.  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
��� Revisao  �  Cristiane Moreto                        � Data � 20.01.00 ���
���          �  Conversao p/ Protheus (OMSA170)         �      �          ���
���          �  Funcao D170Vcod                         �      �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function D170Vcod()
Local rt := .T.

aArea := { Alias(), IndexOrd(), Recno() }

If !ExistChav("DAX")
   rt := .F.
ElseIf Len(Alltrim(M->DAX_COD)) > 3 .Or. Len(Alltrim(M->DAX_COD)) < 2
   Help(" ",1,"DS1705111")
   rt := .F.
ElseIf Len(Alltrim(M->DAX_COD)) == 3
   dbSelectArea("DAX")
   dbSetOrder(1)
   If !dbSeek(xFilial()+Left(M->DAX_COD,2)+" ")
      Help(" ",1,"DS1705112",,Left(M->DAX_COD,2),05,23)
      rt := .F.
   EndIf
EndIf

dbSelectArea(aArea[1])
dbSetOrder(aArea[2])
dbGoTo(aArea[3])

Return(rt)
