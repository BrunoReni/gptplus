#INCLUDE "ofiia210.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIIA210 � Autor �  Renata               � Data � 12/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de arquivos que terao duplicidades eliminadas     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIIA210

PRIVATE cCadastro := OemToAnsi(STR0001)

axCadastro("VH7", cCadastro)

Return
             
Function FS_VALNOMARQ()
Local lRet := .t.
//
DbSelectArea("SX2")
DbSetOrder(1) 
DbSeek(M->VH7_NOMARQ)
//
If Found() .and. Left(M->VH7_NOMARQ,2)=="VI"
  M->VH7_DESARQ := X2Nome()
Else
  lRet := .f.
EndIf
//
If !FG_EK("VH7")
   lRet := .f.
EndIf
//
Return lRet

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)