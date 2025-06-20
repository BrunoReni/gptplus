#INCLUDE "fina426.ch"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FinA426  � Autor � Claudio D. de Souza   � Data � 12.11.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � sub-menu de cnab a pagar    								  	     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fina426()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	  �
//� ----------- Elementos contidos por dimensao ------------	  �
//� 1. Nome a aparecer no cabecalho 									  �
//� 2. Nome da Rotina associada											  �
//� 3. Usado pela rotina													  �
//� 4. Tipo de Transa��o a ser efetuada								  �
//�	 1 -Pesquisa e Posiciona em um Banco de Dados				  �
//�	 2 -Simplesmente Mostra os Campos								  �
//�	 3 -Inclui registros no Bancos de Dados						  �
//�	 4 -Altera o registro corrente									  �
//�	 5 -Exclui um registro cadastrado								  �
//����������������������������������������������������������������
Private aRotina := MenuDef()       					
PRIVATE cCadastro := STR0003 //"CNAB a pagar"

dbSelectArea("SE2")
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SE2",,,,,, Fa040Legenda("SE2"))

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �27/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Local lIntPFS := SuperGetMV("MV_JURXFIN",,.F.)    //Integra��o com SIGAPFS
Local aRotina := {	{STR0001,"Fina420()", 0, 1},; //"Gera arq envio"
							{STR0002,"Fina430()", 0, 3}} //"L� arq retorno"

	If lIntPFS .And. GetRemoteType() == 5 .And. FindFunction("JurUplCnab") // WebApp
		Aadd(aRotina, {STR0004, "JurUplCnab('SE2')", 0, 3}) // "Upload Arq. Retorno"
	EndIF
Return(aRotina)