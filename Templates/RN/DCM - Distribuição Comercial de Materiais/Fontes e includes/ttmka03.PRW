#INCLUDE "ttmka03.ch"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TTMKA03   � Autor � EWERTON C TOMAZ    � Data �  18/08/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Regras de Bloqueio de Pedidos                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function TTMKA03

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

CHKTEMPLATE("DCM")  

Private cString := "LH9"

DbSelectArea("LH9")
DbSetOrder(1)

AxCadastro(cString,STR0001,cVldAlt,cVldExc) //"Cadastro de Regras de Bloqueio de Pedido"

Return
