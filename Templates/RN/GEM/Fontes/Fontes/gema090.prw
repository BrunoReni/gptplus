#INCLUDE "Protheus.ch"
#INCLUDE "gema090.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEMA090   �Autor  �Reynaldo Miyashita  � Data �  26.04.2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de tipos de parcelas - LFD                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function GEMA090()
Local aArea   := GetArea()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecTemplate.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecTemplate.

Local cAlias := "LFD"

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea(cAlias)
&(cAlias)->(dbSetOrder(1))

AxCadastro(cAlias,STR0001,cVldAlt,cVldExc) //"Cadastro de Tipos de Parcelas"
                 
restArea( aArea )

Return( .T. )