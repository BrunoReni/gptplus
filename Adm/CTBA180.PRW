#INCLUDE "CTBA180.CH"
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTBA180   � Autor � Pilar S. Albaladejo   � Data � 11.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao dos Cadastros de Custo                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctba180()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CTBA180()

Local oDlg
Local oRadio
Local nRadio
Local nOpca := 1
Local lCtb	:= CtbInUse()
Local cFNameAtual:= ''

//Fonte descontinuado na vers�o 12.1.17

Help(NIL, NIL, "CTBA180DES", NIL, STR0003/*"Custos(CTBA180) descontinuado a partir da vers�o 12.1.17."*/, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0004/*"Substituir o fonte CTBA180 do menu por: "*/, STR0005/*"Centro de Custo(CTBA030 - CTT), "*/, STR0006/*"Item Cont�bil(CTBA040 - CTD), "*/,STR0007/*"Classe Valor(CTBA060 - CTH)."*/ })

Return