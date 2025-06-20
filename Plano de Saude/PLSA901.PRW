
#INCLUDE "PLSMGER.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSA901 � Autor � Angelo Sperandio       � Data � 17/04/04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualiza BXH - Formas de Calculo de Comissao               ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSA901()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSA901()

//��������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                     �
//����������������������������������������������������������������������������
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := PLSRetTit("BXH")
PRIVATE cAlias    := "BXH"
//��������������������������������������������������������������������������Ŀ
//� Verifica codigos do sistema                                              �
//����������������������������������������������������������������������������
If  ! BXH->(dbseek(xFilial("BXH")+"101"))
    BXH->(RecLock("BXH",.T.))
    BXH->BXH_FILIAL := xFilial("BXH")
    BXH->BXH_PROPRI := "1"
    BXH->BXH_FORCAL := "01"
    BXH->BXH_TIPFOR := "1"
    BXH->BXH_DESCRI := "% OU VALOR SOBRE VALOR MENSALIDADE USUARIO"
    BXH->BXH_COMPL1 := "% OU VALOR SOBRE O VALOR DA MENSALIDADE DE CADA"
    BXH->BXH_COMPL2 := "USUARIO"
    BXH->BXH_COMPL3 := ""
    BXH->(msUnLock())
Endif    
If  ! BXH->(dbseek(xFilial("BXH")+"102"))
    BXH->(RecLock("BXH",.T.))
    BXH->BXH_FILIAL := xFilial("BXH")
    BXH->BXH_PROPRI := "1"
    BXH->BXH_FORCAL := "02"
    BXH->BXH_TIPFOR := "1"
    BXH->BXH_DESCRI := "VALOR FIXO POR USUARIO"
    BXH->BXH_COMPL1 := "VALOR FIXO POR CADA USUARIO VENDIDO"
    BXH->BXH_COMPL2 := ""
    BXH->BXH_COMPL3 := ""
    BXH->(msUnLock())
Endif    
If  ! BXH->(dbseek(xFilial("BXH")+"103"))
    BXH->(RecLock("BXH",.T.))
    BXH->BXH_FILIAL := xFilial("BXH")
    BXH->BXH_PROPRI := "1"
    BXH->BXH_FORCAL := "03"
    BXH->BXH_TIPFOR := "2"
    BXH->BXH_DESCRI := "VALOR FIXO POR CONTRATO"
    BXH->BXH_COMPL1 := "VALOR FIXO POR CONTRATO VENDIDO:"
    BXH->BXH_COMPL2 := "   PESSOA JURIDICA: POR SUBCONTRATO VENDIDO"
    BXH->BXH_COMPL3 := "   PESSOA FISICA: POR FAMILIA VENDIDA"
    BXH->(msUnLock())
Endif    
//��������������������������������������������������������������������������Ŀ
//� Browse padrao                                                            �
//����������������������������������������������������������������������������
DbSelectArea("BXH")
BXH->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BXH",,,,,,,,,,, .T. ))
//��������������������������������������������������������������������������Ŀ
//� Fim do programa                                                          �
//����������������������������������������������������������������������������
Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA901MOV   � Autor� Angelo Sperandio     �Data� 17/04/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rotina para atualizacao do cadastro                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Plsa901Mov(cAlias,nReg,nOpc)
Local I__f := 0

//��������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                     �
//����������������������������������������������������������������������������
Local oDlg
Local oEnc
Local nOpca := 0
LOCAL bOK      := {|| nOpca := 1,If(PLSA901OK(nOpc),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel  := {|| nOpca := 0,oDlg:End()}
//��������������������������������������������������������������������������Ŀ
//� Inicializa campos em memoria                                             �
//����������������������������������������������������������������������������
If  nOpc == K_Incluir
    Copy "BXH" TO Memory Blank
Else
    Copy "BXH" TO Memory
Endif
//��������������������������������������������������������������������������Ŀ
//� Dialogo                                                                  �
//����������������������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd
oEnc := MSMGet():New(cAlias,nReg,nOpc,,,,,{,,(oDlg:nClientHeight - 4)/2,},,,,,,oDlg,,,.F.)
ACTIVATE MSDIALOG oDlg       ON INIT EnchoiceBar(oDlg,bOK,bCancel)
//��������������������������������������������������������������������������Ŀ
//� Atualiza BXH - Formas de Calculo                                         �
//����������������������������������������������������������������������������
If  nOpca == 1 // confirmou
    PLUPTENC("BXH",nOpc)
EndIf
//��������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                            �
//����������������������������������������������������������������������������

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
Private aRotina := { 	{ STRPL01 	,'AxPesqui'    , 0, K_Pesquisar  , 0, .F.},;
						{ STRPL02	,'PLSA901MOV'  , 0, K_Visualizar , 0, Nil},;
						{ STRPL03		,'PLSA901MOV'  , 0, K_Incluir    , 0, Nil},;
						{ STRPL04		,'PLSA901MOV'  , 0, K_Alterar    , 0, Nil},;
						{ STRPL05		,'PLSA901MOV'  , 0, K_Excluir    , 0, Nil} }
Return(aRotina)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA901OK  � Autor � Angelo Sperandio      � Data � 19.03.07 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Validacao de confirmacao da tela (botao OK)                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function PLSA901OK(nOpc)

LOCAL lRet		:= .T.
LOCAL aChaves 	:= {}

If  nOpc == K_Excluir
    If  BXH->BXH_PROPRI <> "9"
		Help("",1,"PLSA901EXC")
        lRet := .F.
    Else
        If  ! empty(BXH->BXH_FILIAL) .and. ! empty(xFilial("BXJ"))
            aadd(aChaves,{"BXJ","BXJ_FILIAL",BXH->BXH_FILIAL,"BXJ_FORCAL",BXH->BXH_PROPRI+BXH->BXH_FORCAL})
        Else
            aadd(aChaves,{"BXJ","BXJ_FORCAL",BXH->BXH_PROPRI+BXH->BXH_FORCAL})
        Endif
        lRet := PLSCHKDEL(aChaves)
    Endif
Endif       

Return(lRet)