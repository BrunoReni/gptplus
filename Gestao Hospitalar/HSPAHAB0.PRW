#INCLUDE "HSPAHAB0.CH"
#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAB0  � Autor � Paulo Jose         � Data �  10/01/05   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE EXAMENS MICROBIOLOGICOS 																					  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAB0()
 Private cAlias := "GDK"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0002, /* "Fs_ExcA9()" */)  //"Cadastro de Exames Microbiologicos"
Return
/*
// Funcao de Exclusao
Function Fs_ExcB0()
 Local lRet := .T.
 DbSelectArea("GCS")
 DbSetOrder(2)
 If DbSeek(xFilial("GCS") + GDK->GDK_CODEXA)
  HS_MsgInf(STR0003,STR0001,STR0002)  //"Este Codigo esta sendo usado. Impossivel Exclui-lo!"###"Atencao"###"Cadastro de Exames Microbiologicos"
  lRet := .F.
 Endif
 DbSelectArea(cAlias)
Return(lRet)
*/