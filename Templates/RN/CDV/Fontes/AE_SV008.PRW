#INCLUDE "AE_SV008.ch"
#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_SV008  � Autor � Itamar Oliveira    � Data �  15/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Prazos para solicitacao de viagens						  ���
�������������������������������������������������������������������������ͺ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function AE_SV008()
Private cString := "LJ8"

ChkTemplate("CDV")

dbSelectArea("LJ8")
LJ8->(dbSetOrder(1))

AxCadastro(cString, STR0001) //"Prazo de Antec. Solicita��o de Viagem"

Return
