#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA920.CH"

/*���������������������������������������������������������������������������
���Fun��o    � Loja920  � Autor � Vendas Clientes       � Data � 15/01/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � SAIDA de Notas Fiscais de Venda Manual                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
���������������������������������������������������������������������������*/ 
Function LOJA920

/******************************************************************************************
 STR0047 = Devido ao novo layout da NFE, que entrou em vigor em 01/04/2015, 
 alguns campos est�o sendo obrigat�rios na DANFE, por isso, � recomend�vel 
 a utiliza��o da rotina de Sa�da de Materiais MATA920, 
 que possui todos os tratamentos necess�rios.
*******************************************************************************************/
MsgAlert(STR0047)


MsgStop("Esta rotina n�o pode ser utilizada." + CHR(13) +;
	"Deve ser utilizada a rotina de Sa�da de Materiais (MATA920) do m�dulo Livros Fiscais (SIGAFIS)")

Return Nil
