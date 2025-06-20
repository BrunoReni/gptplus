
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA256 � Autor � Wagner Mobile Costa    � Data � 10.08.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Tipos de Lancamento Debito/Credito [Cobranca]              ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA256()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSA256

AxCadastro("BSP","Cadastro Tipos Lancamentos Debitos/Creditos [COBRANCA]","PLSA256Del()")

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA256Del � Autor � Angelo Sperandio      � Data � 19.03.07 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Validacao de exclusao                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function PLSA256Del()

LOCAL lRet		:= .T.
LOCAL aChaves 	:= {}

If  ! empty(BSP->BSP_FILIAL) .and. ! empty(xFilial("BSQ"))
    aadd(aChaves,{"BSQ","BSQ_FILIAL",BSP->BSP_FILIAL,"BSQ_CODLAN",BSP->BSP_CODSER})
Else
    aadd(aChaves,{"BSQ","BSQ_CODLAN",BSP->BSP_CODSER})
Endif    

lRet := PLSCHKDEL(aChaves)

Return(lRet)