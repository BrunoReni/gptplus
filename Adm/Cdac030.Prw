#include "cdac030.ch"
#include "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CDAC030  � Autor � Wagner Mobile Costa   � Data �20.06.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Resultados da apuracao                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaCda                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CdaC030()

Private aRotina 	:= MenuDef()
						
//������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes           �
//��������������������������������������������������������
PRIVATE cCadastro 	:= STR0003 	//"Consulta calculo dos direitos autorais"
Private cAlias1		:= "AH5"	// Alias de detalhe
Private lSemItens	:= .T.		// Permite a nao existencia de itens
Private cChave			:= "AH4_PRODUT+AH4_FORNEC+AH4_LOJAFO+DTOS(AH4_DATCAL)"
Private cChave1		:= "AH5_PRODUT+AH5_FORNEC+AH5_LOJAFO+DTOS(AH5_DATCAL)"

//������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                          �
//��������������������������������������������������������

mBrowse(6,1,22,75,"AH4")

CdaPrivate()

Return(.T.)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     
Private aRotina 	:= { 	{ STR0001	,"AxPesqui"  	,0,1,0,.F.},;	//"Pesquisar"
								{ STR0002	,"CdaModelo"	,0,2,0,NIL} } //"Visualizar"

If ExistBlock("CD030MNU")
	ExecBlock("CD030MNU",.F.,.F.)
EndIf

Return(aRotina)


