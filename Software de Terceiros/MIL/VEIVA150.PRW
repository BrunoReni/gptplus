#INCLUDE "veiva150.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VEIVA150 � Autor �  Andre                � Data � 22/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Cores de Veiculos                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIVA150
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0001) //"Cores de Veiculos"
//��������������������������������������������������������������Ŀ
//� Endereca a funcao axCadastro                                 �
//����������������������������������������������������������������
axCadastro("VVC", cCadastro, "Veiva150Ex()")

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Veiva150Ex� Autor � Eduardo Motta         � Data � 03/10/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode ser feito a exclusao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Veiva150Ex()
Local aArquivos := {}
aadd(aArquivos,{"VC4","VC4_CODMAR+VC4_CORVEI", VVC->VVC_CODMAR+VVC->VVC_CORVEI,})
aadd(aArquivos,{"VV1","VV1_CODMAR+VV1_CORVEI", VVC->VVC_CODMAR+VVC->VVC_CORVEI,})
aadd(aArquivos,{"VV1","VV1_CODMAR+VV1_CORFXA", VVC->VVC_CODMAR+VVC->VVC_CORVEI,})
Return FG_DELETA(aArquivos)

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)