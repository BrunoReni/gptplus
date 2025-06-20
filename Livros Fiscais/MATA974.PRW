#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA974.CH"

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA974   � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao cadastral da tabela CCD - Cadastro do reflexo dos    ���
���          � ajustes na Apura��o de ICMS                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA974
Local	lRet	:=	.T.

Private cCadastro   := STR0001	//"Cadastro do reflexo dos ajustes na Apura��o de ICMS"
Private aRotina  := MenuDef()

mBrowse( 6, 1,22,75,"CCD")

Return lRet                                                                                    


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { { oemtoansi("Pesquisar"),"AxPesqui", 0 , 1},; // "Pesquisar"
	{ oemtoansi("Visualizar"),"AxVisual", 0 , 2},; // "Visualizar"
	{ oemtoansi("Incluir"),"AxInclui", 0 , 3},;
	{ oemtoansi("Altera"),"AxAltera", 0 , 4},;
	{ oemtoansi("Exclui"),"AxDeleta", 0 , 5}}

If ExistBlock("MA974MNU")
	ExecBlock("MA974MNU",.F.,.F.)
EndIf

Return(aRotina)

Function M974SYP
	MSMM(M->CCD_DESCR2,,,M->CCD_DESCD,1,,,"CCD","CCD_DESCR2")
Return .T.

Function M974DSYP
	MSMM(CCD->CCD_DESCR2,,,,2,,,"CCD")
Return .T.
