#INCLUDE "HSPAHP43.ch"
#INCLUDE "rwmake.ch"        

/*       
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO4     � Autor � MARCELO JOSE       � Data �  19/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE TIPOS DE NAO CONFORMIDADES                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Function HSPAHP43()
 dbSelectArea("GSF")
 dbSetOrder(1)
 AxCadastro("GSF",STR0001,"HS_VEP43()") //"Cadastro de Tipos de Nao Conformidades"
Return(Nil)

Function HS_VEP43()
 Local lRet := .T.
 Local aAreaOld := GetArea()
 
 dbSelectArea("GSE")
 dbSetOrder(3)  
 
 If DBSeek( xFilial("GSE") + GSF->GSF_CODIGO )
  HS_MsgInf(STR0002,STR0003,STR0001) //"Este Codigo esta sendo usado pelo rotina de Nao Conformidade .Impossivel Exclui-lo!" //"Aten��o"###"Cadastro de Tipos de Nao Conformidades"
  lRet := .F.
 Else
  RestArea(aAreaold)
  RecLock("GSF", .F.,.T.)
   DBDelete()
  MsUnLock()
 EndIf   
 
 
Return( lRet )
