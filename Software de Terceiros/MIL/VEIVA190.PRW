#INCLUDE "veiva190.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VEIVA190 � Autor �  Fabio                � Data � 21/02/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Segmento do Modelo                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIVA190
PRIVATE cCadastro := OemToAnsi(STR0001) //"Segmento do Modelo"
//��������������������������������������������������������������Ŀ
//� Endereca a funcao axCadastro                                 �
//����������������������������������������������������������������
axCadastro("VVX", cCadastro , "VA190E()")

Return .T.                                

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA190E    �Autor  �Fabio               � Data �  08/23/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Excluir   Segmento do Modelo                               ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VA190E()
Local aVetValid := {}
SBM->( DbSetOrder(1) )
Aadd(aVetValid, {"VE3", "VE3_SEGMOD" , VVX->VVX_CODMAR+VVX->VVX_SEGMOD , "SBM->( DbSeek( xFilial('SBM') + VE3->VE3_GRUITE ) ) .And. SBM->BM_CODMAR == VVX->VVX_CODMAR" } )
Aadd(aVetValid, {"VV1", "VV1_CODMAR+VV1_SEGMOD" , VVX->VVX_CODMAR+VVX->VVX_SEGMOD , NIL } )
Aadd(aVetValid, {"VV2", "VV2_CODMAR+VV2_SEGMOD" , VVX->VVX_CODMAR+VVX->VVX_SEGMOD , NIL } )
Aadd(aVetValid, {"VO6", "VO6_CODMAR+VO6_SEGMOD" , VVX->VVX_CODMAR+VVX->VVX_SEGMOD , NIL } )
Aadd(aVetValid, {"VO7", "VO7_CODMAR+VO7_SEGMOD" , VVX->VVX_CODMAR+VVX->VVX_SEGMOD , NIL } )
Aadd(aVetValid, {"VO8", "VO8_CODMAR+VO8_SEGMOD" , VVX->VVX_CODMAR+VVX->VVX_SEGMOD , NIL } )
Return FG_DELETA( aVetValid )

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)