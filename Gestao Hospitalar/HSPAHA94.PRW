#INCLUDE "HSPAHA94.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA94  � Autor � Marcelo Prates     � Data �  14/10/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE MOTIVOS DE SOLICITA��ES                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA94()
 Private cAlias := "GSC"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0001,"HS_VEA94()","HS_VIA94()") //"Motivos de Solicitacoes"
Return(Nil)
/*---------------------------------------------------------------------------------------------------------------*/
Function HS_VIA94()
 Local lvai := .T.
 If Inclui
  If DBSeek(xFilial("GSC") + M->GSC_CODMOT )
   HS_MsgInf(STR0002, STR0004, STR0005)//"Codigo ja cadastrado. Tente outro..."###"Atencao"###"Inclus�o n�o Permitida"
   lvai := .F.
  EndIf
 EndIf 
Return( lvai )
/*---------------------------------------------------------------------------------------------------------------*/
Function HS_VEA94()
 Local lvai := .T.,cCodMot := "" 
 _alias := Alias()
 cCodMot := GSC->GSC_CODMOT
 DbSelectArea("GSA")
 DbSetOrder(5)
 If DBSeek(xFilial("GSA") + cCodMot )
  HS_MsgInf(STR0003, STR0004, STR0006)//"Motivo nao pode ser apagado pois esta sendo utilizado na movimentacao."###"Atencao"###"Exclus�o n�o Permitida"
  lvai := .F.
 EndIf
 DbSelectArea(_alias)
Return( lvai )