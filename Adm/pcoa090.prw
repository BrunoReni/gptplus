#INCLUDE "pcoa090.ch"
#INCLUDE "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PCOA090  � Autor � Edson Maricate        � Data �27-01-2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Tipos de Bloqueio do SIGAPCO              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function PCOA090()

//PcoChkAKJ()

AxCadastro("AKJ",STR0001, "PCOA090DEL()",,,,{|| If( Inclui .Or. Altera, PCO090VldF(), .T. )})  //"Cadastro de Tipos de Bloqueio"

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PCOA090DEL� Autor � Edson Maricate        � Data �27-01-2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de validacao de exclusao da Operacao                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Validacao OK                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � PCOA090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA090DEL()

Return .T.

Static Function PCO090VldF()
Private __aDadosBlq	:=	{1,0,0,"CHAVETESTE","PROCESSOTESTE","ITEMTESTE","PROGRAMATESTE"}

Return PcoTstForm(M->AKJ_BLOCK)

Static Function MenuDef()

Return StaticCall(MATXATU,MENUDEF)
