#Include "Protheus.ch"
#Include "TmsA210.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmsA210F � Autor � Vitor Raspa           � Data � 22.Dez.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carregamento de Entrega / Fluvial                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA210F()

Private cCadastro  := STR0037 //"Carregamento Entrega Fluvial"
Private aRotina := MenuDef()

TmsA210('3','3')

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MENUDEF  � Autor � Jefferson Tomaz       � Data �29.12.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Menu                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := MenuD210()

Return(aRotina)