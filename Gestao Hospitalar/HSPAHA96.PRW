#INCLUDE "HSPAHA96.ch"
#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA96  � Autor � Gilson da Silva    � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE MOTIVOS DE CANCELAMENTO DE UM AGENDAMENTO.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA96()
 Private cAlias := "GM7"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0001, "Fs_Exc96()") //"Cadastro de Motivos de Cancelamento do Agendamento"
Return

// Funcao de Exclusao
Function Fs_Exc96()
 Local lRet := .T.
 DbSelectArea("GM9")
 DbSetOrder(2)
 If DbSeek(xFilial("GM9") + GM7->GM7_CODCAN)
  HS_MsgInf(STR0002, STR0004, STR0005)     //"Este Codigo esta sendo usado pela Tabela de Agendamentos Cancelados(GM9).Impossivel Exclui-lo!"###"Atencao"###"Exclus�o n�o Permitida"
  lRet := .F.
 Endif
	DbSelectArea("GMA")
 DbSetOrder(2)
 If DbSeek(xFilial("GMA") + GM7->GM7_CODCAN)
  HS_MsgInf(STR0003, STR0004, STR0005)     //"Este Codigo esta sendo usado pela Tabela de Agendamentos Transferidos(GMA).Impossivel Exclui-lo!"###"Atencao"###"Exclus�o n�o Permitida"
  lRet := .F.
 Endif
 DbSelectArea(cAlias)
Return(lRet)