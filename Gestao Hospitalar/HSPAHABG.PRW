#INCLUDE "HSPAHABG.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABG  � Autor � Gilson da Silva    � Data �  23/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE MOTIVO DE CANCELAMENTO DO ATENDIMENTO          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHABG()

Private cString := "GES"

dbSelectArea("GES")
dbSetOrder(1)

AxCadastro(cString,STR0001,"HS_ExcABG()") //"Cadastro de Motivo de Cancelamento do Atendimento"

Return(Nil)
/******************************************************************************************************************/
Function HS_ExcABG()
 Local lRet := .T.
 Local aArea:= GetArea()
 
 DbSelectArea("GCY")
 DbSetOrder(9)				
 If DbSeek(xFilial("GES") + GES->GES_CODIGO) 
  HS_MsgInf(STR0002, STR0003, STR0004)  //"Motivo de Cancelamento do Atendimento cadastrado no Atendimento. Exclusao nao permitida"###"Atencao"###"Valida��o de exclus�o"
  lRet := .F.
 Endif                                                                                                         
 
 RestArea(aArea)
Return(lRet)
