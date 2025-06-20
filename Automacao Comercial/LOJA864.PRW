#INCLUDE "PROTHEUS.ch"
#INCLUDE "LOJA864.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA864   � Autor � Antonio C Ferreira � Data �  08/04/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Range de CEP do e-Commerce, define a Filial e Amrazem para ���
���          � a reserva de estoque.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - eCommerce                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function LOJA864()

Private cCadastro := STR0001   //"Cadastro de Range de CEP do e-Commerce"
//���������������������������������������������������������������������Ŀ
//� aRotina padrao. Utilizando a declaracao a seguir, a execucao da     �
//� MBROWSE sera identica a da AXCADASTRO:                              �
//�                                                                     �
//� cDelFunc  := ".T."                                                  �
//� aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               �
//�                { "Visualizar"   ,"AxVisual" , 0, 2},;               �
//�                { "Incluir"      ,"AxInclui" , 0, 3},;               �
//�                { "Alterar"      ,"AxAltera" , 0, 4},;               �
//�                { "Excluir"      ,"AxDeleta" , 0, 5} }               �
//�                                                                     �
//�����������������������������������������������������������������������

Private aRotina := { {STR0002,"AxPesqui",0,1} ,;    //"Pesquisar"
             {STR0003,"AxVisual",0,2} ,;       //"Visualizar"
             {STR0004,"AxInclui",0,3} ,;       //"Incluir"
             {STR0005,"AxAltera",0,4} ,;       //"Alterar"
             {STR0006,"AxDeleta",0,5} }        //"Excluir"

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

dbSelectArea("MF6")
dbSetOrder(1)   //MF6_FILIAL+MF6_CEPDE+MF6_CEPATE

mBrowse( 6,1,22,75,"MF6")

Return