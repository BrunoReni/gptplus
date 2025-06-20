
#INCLUDE "PLSMGER.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA909 � Autor � Angelo Sperandio       � Data � 27/05/04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualiza BXQ - Comissoes                                   ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA909()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSA909()
PRIVATE aRotina   := MenuDef()
/*/
                        { 'Incluir'   ,'PLSA909MOV'  , 0 , K_Incluir    },;
                        { 'Alterar'   ,'PLSA909MOV'  , 0 , K_Alterar    },;
                        { 'Excluir'   ,'PLSA909MOV'  , 0 , K_Excluir    } }
/*/
PRIVATE aCdCores  := { { 'BR_VERDE'   ,'Em Aberto no Comercial'     },;
                        { 'BR_AMARELO' ,'Em Aberto no Contas a Pagar'},;
                        { 'BR_VERMELHO','Baixado no Contas a Pagar'  },;
                        { 'BR_AZUL'    ,'Enviado para a Folha'       } }

PRIVATE aCores    := { { 'empty(BXQ_MAT) .and. empty(BXQ_E2NUM)',aCdCores[1,1] },;
                       { '! empty(BXQ_E2NUM) .and. posicione("SE2",1,xFilial("SE2")+BXQ_E2PREF+BXQ_E2NUM+BXQ_E2PARC+BXQ_E2TIPO+BXQ_E2FORN+BXQ_E2LOJA,"E2_SALDO") <> 0',aCdCores[2,1] },;
                       { '! empty(BXQ_E2NUM) .and. posicione("SE2",1,xFilial("SE2")+BXQ_E2PREF+BXQ_E2NUM+BXQ_E2PARC+BXQ_E2TIPO+BXQ_E2FORN+BXQ_E2LOJA,"E2_SALDO") == 0',aCdCores[3,1] },;
                       { '! empty(BXQ_MAT)',aCdCores[4,1] } }
PRIVATE cCadastro := Fundesc()
PRIVATE cAlias    := "BXQ"

DbSelectArea("BXQ")

BXQ->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BXQ",,,,,   ,aCores,,,,, .T. ))

Return 


Function Plsa909Mov(cAlias,nReg,nOpc)
Local I__f := 0
Local oDlg
Local oEnc
Local nOpca := 0

If nOpc == K_Incluir
   Copy "BXQ" TO Memory Blank
Else
   Copy "BXQ" TO Memory
Endif

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd

oEnc := MSMGet():New(cAlias,nReg,nOpc,,,,,{,,(oDlg:nClientHeight - 4)/2,},,,,,,oDlg,,,.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()})

If nOpca == 1 // confirmou
   PLUPTENC("BXQ",nOpc)
EndIf

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA800LEG � Autor � Tulio Cesar         � Data � 08.01.02 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Exibe a legenda...                                         ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSA909Leg()

Local aLegenda := { { aCdCores[1,1],aCdCores[1,2] },;
                     { aCdCores[2,1],aCdCores[2,2] },;
                     { aCdCores[3,1],aCdCores[3,2] },;
                     { aCdCores[4,1],aCdCores[4,2] } }

BrwLegenda(cCadastro,"Status" ,aLegenda)

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
Private aRotina := {	{ STRPL01 ,'AxPesqui'    , 0, K_Pesquisar  , 0, .F.},;
						{ STRPL02,'PLSA909MOV'  , 0, K_Visualizar , 0, Nil},;
           				{ "Legenda"   ,"PLSA909LEG"  , 0, 0            , 0, .F.} }
Return(aRotina)