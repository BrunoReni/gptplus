#INCLUDE "OMSA160.ch"


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
��� Funca    � OMSA160  � Autor � Karla Leite Fonseca   � Data � 20.07.1999 ���
���������������������������������������������������������������������������Ĵ��
���Nome Orig.� DFATA40  �                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Descricao�  AxCadastro para Manut. dos Codigos Cidade e Estado (IBGE)   ���                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Distribuidor                                      ���
���������������������������������������������������������������������������Ĵ��
��� Solicit. � Nerimar Mendes                                               ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Objetivos� Padronizacao dos Codigos de Estados e Cidades - Padrao IBGE  ���
���������������������������������������������������������������������������Ĵ��
��� Observ.  �                                                              ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Descricao da Revisao                           � Responsavel �   Data   ���
���������������������������������������������������������������������������Ĵ��
��� Conversao p/ Protheus (OMSA160)                � Cristiane   �20.01.99  ���
���                                                � Moreto      �          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function OMSA160()

dbSelectArea("DAS")
dbSetOrder(1)
dbGoTop()

AxCadastro("DAS",STR0001,".T.",".T.") //"Codigos Cidades/Estados-Padrao IBGE "

Return
