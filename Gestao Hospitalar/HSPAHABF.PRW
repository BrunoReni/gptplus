#INCLUDE "HSPAHABF.ch"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABF  � Autor � MARCELO JOSE       � Data �  20/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE PENDENCIAS DO FATURAMENTO                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ�� 
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHABF()

Private cString := "GEY"

dbSelectArea("GEY")
dbSetOrder(1)

AxCadastro(cString,STR0001,"HS_ExcABF()") //"Cadastro de Pendencias do Faturamento"

Return(Nil)
/******************************************************************************************************************/
Function HS_ExcABF()
 Local lRet := .T., cAliasOld := Alias()
 
 DbSelectArea("GEZ")
 DbSetOrder(2)				
 If DbSeek(xFilial("GEZ") + GEY->GEY_CODPEN) 
  HS_MsgInf(STR0002, STR0003, STR0001)  //"Pendencia cadastrada em relacionamento Auditoria de Contas. Exclusao nao permitida"###"Atencao!"###"Cadastro de Pendencias do Faturamento"
  lRet := .F.
 Endif                                                                                                         
 
 DbSelectArea(cAliasOld)
Return(lRet) 
