#INCLUDE "ttmka05.ch"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TTMKA05   � Autor � EWERTON C TOMAZ    � Data �  18/08/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Grupos e Sub-Grupos de Produtos                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function TTMKA05

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

CHKTEMPLATE("DCM")  

Private cString := "SZ3"

DbSelectArea("SZ3")
DbSetOrder(1)

AxCadastro(cString,STR0001,cVldAlt,cVldExc) //"Cadastro de Grupos de Produtos"

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TTMKA05b  � Autor � EWERTON C TOMAZ    � Data �  18/08/04   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function TTMKA05b

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

CHKTEMPLATE("DCM")  

Private cString := "SZ4"

DbSelectArea("SZ4")
DbSetOrder(1)

AxCadastro(cString,STR0002,cVldAlt,cVldExc) //"Cadastro de Sub-Grupos de Produtos"

Return(Nil)
