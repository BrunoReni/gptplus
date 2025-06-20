#Include "cfgx037.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CFGX037  � Autor � Ary Medeiros          � Data � 31/08/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Configuracao de Gatilhos                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACFG                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CFGX037
Return APCFG10("#SX7")

Static Function __CFGX037
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina := {{ STR0007,"AxPesqui", 0 , 1},;
					{ STR0001,"AxVisual", 0 , 2},;  // "Visualizar"
                     { STR0002,"X037Inclui", 0 , 3},; // "Incluir"
                     { STR0003,"X037Altera", 0 , 4, 2},; // "Alterar"
                     { STR0004   ,"X037Deleta", 0 , 5, 1} }  // "Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi( STR0005 )  // "Configura��o de Gatilhos"


//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SX7")

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �X037Inclui� Autor � Ary Medeiros          � Data � 01/09/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao de Gatilhos                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � X037Inclui                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function X037Inclui(cAlias,nReg,nOpcx)

Local nOpca
Local cSavAlias := Alias()


nOpca := AxInclui(cAlias,nReg,nOpcx)

if nOpca == 1
	Reclock("SX7")
	Replace X7_PROPRI with "U"	
	MsUnlock()
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(SX7->X7_CAMPO)
	dbSetOrder(1)
	Reclock("SX3")
	Replace X3_TRIGGER with "S"
	dbUnlock( )
	dbSelectArea(cSavAlias)
endif
Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �X037Altera� Autor � Ary Medeiros          � Data � 01/09/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Altera��o de Gatilhos                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � X037Altera                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function X037Altera(cAlias,nReg,nOpcx)

Local cSavCpo
Local nOpca
Local cSavAlias := Alias()

cSavCpo := SX7->X7_CAMPO
cSavSeq := SX7->X7_SEQUENC
dbSelectArea("SX7")
dbSeek(cSavCpo+cSavSeq)
dbSkip()
if cSavCpo+cSavSeq <> X7_CAMPO+X7_SEQUENC
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(cSavCpo)
	RecLock("SX3",.f.)
	Replace X3_TRIGGER with " "
	dbSetOrder(1)
	UnLock
endif
dbSelectArea("SX7")
dbGoTo(nReg)

nOpca := AxAltera(cAlias,nReg,nOpcx)
if nOpca == 1
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(SX7->X7_CAMPO)
	dbSetOrder(1)
	RecLock("SX3",.f.)
	Replace X3_TRIGGER with "S"
	UnLock
	dbSelectArea(cSavAlias)
else
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(cSavCpo)
	RecLock("SX3",.f.)
	Replace X3_TRIGGER with "S"
	dbSetOrder(1)
	UnLock
	dbSelectArea(cSavAlias)
endif

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � X037Cpo  � Autor � Ary Medeiros          � Data � 31/08/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do nome do campo                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � X037Cpo(ExpC1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Nome do Campo                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX037                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function X037Cpo(cCpo)

Local cSavAlias := Alias()
Local cSavRec := RecNo()
Local lRet := .f.

if Empty(cCpo)
	lRet := .f.
	Help(" ",1,"NOMECPO")
else
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek(cCpo)
	if !Found()
		Help(" ",1,"NOMECPO")
		lRet := .f.
	else
		lRet := .t.
	endif
	dbSetOrder(1)
endif
dbSelectArea(cSavAlias)
dbGoTo(cSavRec)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � X037Alias� Autor � Ary Medeiros          � Data � 31/08/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Alias do Arquivo                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � X037Alias(ExpC1,ExpC2,ExpC3)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Contra Dominio                                     ���
���          � ExpC2 = Alias                                              ���
���          � ExpC3 = Tipo                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX037                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function X037Alias(cCpo,cAlias,cTipo)
Local cSavAlias := Alias()
Local lRet := .t.

dbSelectArea("SX2")
Set Filter to
dbSeek(cAlias)
if !Found()
	Help(" ",1,"X7_ALIAS")
	lRet := .f.
endif
Set Filter to x2_chave $ cFOPENed 
DbGotop()
dbSelectArea(cSavAlias)

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � X037Seq  � Autor � Ary Medeiros          � Data � 31/08/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna numero sequiencial para gatilho                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � X037Seq(ExpC1)                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Nome do Campo                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX037                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function X037Seq(cCpo)
Local cSavAlias := Alias()
Local nSavRec := Recno()
Local cRet

dbSelectArea("SX7")
dbSeek(cCpo)
if !Found()
	cRet := "001"
else
	While X7_CAMPO == cCpo
		dbSkip()
	end
	dbSkip(-1)
	cRet := StrZero(Val(X7_SEQUENC)+1,3)
endif
dbSelectArea(cSavAlias)
dbGoTo(nSavRec)
Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � X037Deleta � Autor � Ary Medeiros        � Data � 31/08/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de exclusao de Gatilhos                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � X037Delete()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX037                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function X037Deleta(cAlias,nReg,nOpc)
LOCAL cCampo,oDlg
*��������������������������������������������������������������Ŀ
*� Monta a entrada de dados do arquivo                          �
*����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]


While .T.
	*��������������������������������������������Ŀ
	*� Envia para processamento dos Gets          �
	*����������������������������������������������
	nOpcA:=0
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",STR0006 )  // "Quanto � exclus�o?"
	nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	DbSelectArea("SX7")
	IF nOpcA == 2
		cCampo := X7_CAMPO
		RecLock("SX7",.f.)
		dbDelete()
		UnLock
		dbSeek(cCampo)
		if !Found()
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek(cCampo)
			RecLock("SX3",.f.)
			Replace X3_TRIGGER with " "
			UnLock
			dbSetOrder(1)
		endif
	endif
	Exit
EndDo
DbSelectArea(cAlias)
Return NIL
