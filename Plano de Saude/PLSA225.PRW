
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA225 � Autor � Angelo Sperandio       � Data � 03.11.04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualizacao do cadastro de Equipamento x RDA x Local       ����
���          � Indica quais RDA's poderao utilizar determinado            ����
���          � equipamento (pos/cpu) em determinado local                 ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA225()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSA225
//��������������������������������������������������������������������������Ŀ
//� Define variaveis PRIVATE...                                              �
//����������������������������������������������������������������������������
private cCodInt
Private cCodRda := Space(06)
axCadastro("BSV","Equipamento x RDA x Local")
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return

Function Plsa225Rda()
cCodRda := BSV->BSV_CODRDA
Return .t.

Function PL225DesLoc()
Return(Posicione("BB8",1,xFilial("BB8")+BSV->(BSV_CODRDA+BSV_CODINT+BSV_CODLOC),"BB8_DESLOC"))

Function PL225VldLoc()

Return(ExistCpo("BB8",M->BSV_CODRDA+M->BSV_CODINT+M->BSV_CODLOC,1) .and. ExistChav("BSV",M->BSV_CODINT+M->BSV_CODEQU+M->BSV_CODRDA+M->BSV_CODLOC,1))
