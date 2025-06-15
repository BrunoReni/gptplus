#Include "DLGA270.CH"
#Include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DLGA270  � Autor � Rodrigo de A. Sartorio� Data � 03/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento do codigo do cliente no operador logistico   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DLGA270
LOCAL lIntegraDL :=	GetMV("MV_INTDL") == "S"
LOCAL lOperadorL := GetMV("MV_APDLOPER")
LOCAL cFilialAdm := GetMV("MV_APDLFOP")
LOCAL lFilialOper := cFilialAdm == cFilAnt

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 -Pesquisa e Posiciona em um Banco de Dados              �
//�    2 -Simplesmente Mostra os Campos                          �
//�    3 -Inclui registros no Bancos de Dados                    �
//�    4 -Altera o registro corrente                             �
//�    5 -Estorna registro selecionado gerando uma contra-partida�
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de alteracoes                     �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0004)	//"Associacao ao Codigo do OL"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
If lIntegraDL .And. lOperadorL .And. lFilialOper
	mBrowse(6,1,22,75,"DCK")
Else
	HELP(" ",1,"APDLCAOPL")
EndIf
RETURN

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Dl270Alter� Autor �Rodrigo de A. Sartorio � Data � 03/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de alteracao de Codigos no Operador Logistico     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � DLGA270                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function Dl270Alter(cAlias,nReg,nOpcx)
Local nOpca:=0,aAlter:={}
AADD(aAlter,"DCK_CODOPL")
AADD(aAlter,"DCK_LOJOPL")
//��������������������������������������������������������������Ŀ
//� Envia para rotina de Alteracao de Codigos                    �
//����������������������������������������������������������������
nOpca := AxAltera(cAlias,nReg,nOpcx,,aAlter)
RETURN NIL

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �23/10/2006���
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
PRIVATE aRotina	:= {		{STR0001,"AxPesqui", 0 , 1 , 0 , .F.},;	//"Pesquisar"
							{STR0002,"AxVisual", 0 , 2 , 0 , nil},;	//"Visualizar"
							{STR0003,"Dl270Alter", 0 , 4 , 0 , nil}}	//"Alterar Codigo"	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("DLG270MNU")
	ExecBlock("DLG270MNU",.F.,.F.)
EndIf
Return(aRotina)  
