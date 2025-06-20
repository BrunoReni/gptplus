
#INCLUDE "PLSMGER.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA907 � Autor � Angelo Sperandio       � Data � 18/04/04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualiza BXO - Metas de Vendas por Vendedor                ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA907()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSA907()

Private cCodInt := ""

PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := PLSRetTit("BXN")
PRIVATE cAlias    := "BXN"

DbSelectArea("BXN")

BXN->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BXN",,,,,,,,,,, .T. ))

Return 


Function Plsa907Mov(cAlias,nReg,nOpc)
Local I__f := 0
Local oDlg
Local oEnc
Local nOpca := 0

If nOpc == K_Incluir
   Copy "BXN" TO Memory Blank
Else
   Copy "BXN" TO Memory
Endif

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd

oEnc := MSMGet():New(cAlias,nReg,nOpc,,,,,{,,(oDlg:nClientHeight-30)/2,},,,,,,oDlg,,,.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Iif(Obrigatorio(oEnc:aGets,oEnc:aTela),(nOpca := 1,oDlg:End()),NIL)},{|| nOpca := 0,oDlg:End()})

If nOpca == 1 // confirmou 
   PLUPTENC("BXN",nOpc)
Else
	RollBackSxe() 
EndIf


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �08/01/2007���
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
Private aRotina := {	{ STRPL01 	,'AxPesqui'    , 0, K_Pesquisar  , 0, .F.},;
						{ STRPL02	,'PLSA907MOV'  , 0, K_Visualizar , 0, Nil},;
						{ STRPL03		,'PLSA907MOV'  , 0, K_Incluir    , 0, Nil},;
						{ STRPL04		,'PLSA907MOV'  , 0, K_Alterar    , 0, Nil},;
						{ STRPL05		,'PLSA907MOV'  , 0, K_Excluir    , 0, Nil} }
Return(aRotina)