#INCLUDE "Mt680Est.ch" 
#include "Protheus.ch"


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Funcao   � CBMT680EST � Autor � Anderson Rodrigues � Data �Wed  10/07/02���
���������������������������������������������������������������������������͹��
���Descri��o � Faz validacao da exclusao PCP MOD 1 e MOD 2                  ���
���������������������������������������������������������������������������͹��
���Uso       � SIGAACD                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CBMT680EST()

If !SuperGetMV("MV_CBPE014",.F.,.F.)
	Return .t.
EndIf

If Type("l680AUTO") =="L" .and. l680AUTO
	Return .t.
Endif

If ! Empty(SH6->H6_CBFLAG)
	MsgAlert(STR0001) //"Registro deve ser excluido pela rotina de monitoramento da Producao do ACDSTD"
	Return .f.
EndIf

Return .t.
