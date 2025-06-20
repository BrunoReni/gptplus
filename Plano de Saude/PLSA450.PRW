#INCLUDE "plsa450.ch"

#include "PLSMGER.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PLSA450    � Autor � Tulio Cesar       � Data � 08.10.2002 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Situacoes Adversas                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PLSA450                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Padrao do mBrowse                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSA450(cAlias,nReg,nOpc)
PRIVATE bDelLine := { || PLSA450Exc() }

AxCadastro("BGX",STR0001) //"Situacoes Adversas"

Return


Function PLSA450Cd(cCodInt)
LOCAL nRet    := 0
LOCAL nOrdBGX := BGX->(IndexOrd())

BGX->(DbSetOrder(1))

BGX->(DbSeek(xFilial("BGX")+cCodInt+Replicate("9",Len(BGX->BGX_CODSAD)),.T.))
BGX->(DbSkip(-1))
                                                           
If BGX->(BGX_FILIAL+BGX_CODINT) <> xFilial("BGX")+cCodInt
   nRet := StrZero(1,3)
Else
   nRet := StrZero(Val(BGX->BGX_CODSAD)+1,3)
Endif

BGX->(DbSetOrder(nOrdBGX))

Return(nRet)


Function PLSA450Exc
LOCAL lRet := .T.

If lRet
   BHN->(DbSetOrder(2))
   If BHN->(DbSeek(xFilial("BHN")+BGX->(BGX_CODINT+BGX_CODSAD)))
      lRet := .F.
   Endif
   
   If lRet   
      BGZ->(DbSetOrder(2))                                              
      If BGZ->(DbSeek(xFilial("BGZ")+BGX->(BGX_CODINT+BGX_CODSAD)))
         lRet := .F.
      Endif   
   Endif
Endif      

If ! lRet
   Help("",1,"PLSA450EXC")
Endif   


Return(lRet)
