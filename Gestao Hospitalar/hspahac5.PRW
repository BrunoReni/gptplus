#INCLUDE "HSPAHAC5.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC5  � Autor � Heimdall Castro    � Data �  27/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Regras de Credenciamento de Medico por Mat/Med ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAC5()
 Private aRotina, cCadastrO
 cCadastro := STR0001 //"Cadastro de Regras de Medico por Mat/Med"
 aRotina := {{OemtoAnsi(STR0002)	, "axPesqui"    , 0, 1}, ; // "Pesquisar" //"Pesquisar"
             {OemToAnsi(STR0003), "axVisual"    , 0, 2}, ; // "Visualizar" //"Visualizar"
             {OemToAnsi(STR0004)			, "axAltera"    , 0, 4}}   // "Alterar" //"Alterar"

 dbSelectArea("GN8")
 dbSetOrder(1)
 mBrowse(06, 01, 22, 75, "GN8")
 
Return(Nil)