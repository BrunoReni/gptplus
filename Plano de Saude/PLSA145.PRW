#INCLUDE "plsa145.ch"

#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA145 � Autor � Tulio Cesar            � Data � 27.06.02 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Cadastro dos valores de coeficiente de honorarios mensais  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA145()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA145()
      
PRIVATE bDelLine := { || PLSA145Edt() }

PRIVATE bEdit := { || PLSA145Edt() }

AxCadastro("BFM",STR0001) //"Cadastro de U.S. Mensais"
                                               
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLsa145Edt� Autor � Tulio Cesar           � Data � 27.06.02 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Validacao do registro                                      ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � Plsa145Edt()                                               ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA145Edt()
LOCAL lRet := .T.

BIP->(DbSetOrder(1))
If BIP->(DbSeek(xFilial("BIP")+BFM->(BFM_CODINT+BFM_ANO+BFM_MES)))
   If BIP->BIP_FECHAD == "1"
      lRet := .F.
   Endif
Endif      

If ! lRet   
   MsgInfo(STR0002) //"Nao e possivel Editar/Excluir pois este mes ja se encontra fechado"
Endif


Return(lRet)


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � MenuDef � Autor � Henry Fila             � Data � 02/04/07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualizacao do menu funcional                              ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � MenuDef()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Static Function MenuDef()

Return StaticCall(MATXATU,MENUDEF)
