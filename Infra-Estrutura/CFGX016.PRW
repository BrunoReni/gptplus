/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CFGX016  � Autor � Eveli Morasco         � Data � 12/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do arquivo de tabelas do sistema                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACFG                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CFGX016(xAutoCab,xAutoItens)

If xAutoCab <> NIL
	Return __CFGX016(xAutoCab,xAutoItens)
EndIf

Return APCFG10("#SX5")

Static Function __CFGX016(xAutoCab,xAutoItens)
#Include "FIVEWIN.CH"
#Include "CFGX016.CH"
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cArquivo,cIndex,cSixChave, nX

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
lCFG016Auto := (xAutoCab <> Nil .and. xAutoItens <> Nil)
aAutoCab    := {}
aAutoItens  := {}
PRIVATE aRotina := { { STR0001 ,  "AxPesqui"  , 0 , 1},;  // "Pesquisar"
							{ STR0002,   "C160Visual", 0 , 2},;  // "Visualizar"
							{ STR0003,   "C160Inclui", 0 , 3},;  // "Incluir"
							{ STR0004,   "C160Altera", 0 , 4},;  // "Alterar"
							{ STR0005,   "C160Deleta", 0 , 5} }  // "Excluir"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
cCadastro := OemToAnsi(STR0006)  // "Tabelas"

If !FwCanCfg( '__CFGX016', 'CFGX016' )
	Return NIL
EndIf
If !FWIsAdmin()
	_FWLogAccI( 'CFGX016' )
	FWHlpAcAdm()
	Return
Endif

If !lCFG016Auto
	mBrowse( 6, 1,22,75,"SX5" )
Else
	aAutoCab := SX5->(MSArrayXDB(xAutoCab))
	For nX := 1 To Len(xAutoItens)
		aadd(aAutoItens,SX5->(MSArrayXDB(xAutoItens[nX])))
	Next
	c160Inclui("SX5",Recno(),3)

EndIf
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160Visual� Autor � Eveli Morasco         � Data � 12/09/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de visualizacao de uma tabela                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C160Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION C160Visual(cAlias,nReg,nOpcx)
LOCAL nCnt,nUsado:=0,nSavRec:=RecNo()
LOCAL nRegistro,oDlg,nOpca:=0,oGet,cDescSx5
Private cTabela:=X5_TABELA
//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea( cAlias )
If RecCount() == 0
	Return .T.
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se esta' na filial correta                          �
//����������������������������������������������������������������
If cFilial != X5_FILIAL
	Help(" ",1,"A000FI")
	Return .T.
EndIf

//��������������������������������������������������������������Ŀ
//� Monta o cabecalho do GetDados                                �
//����������������������������������������������������������������
PRIVATE aHeader[0]
Select Sx2
Seek cAlias

Select Sx3
Seek cAlias
While !EOF() .And. X3_ARQUIVO == cAlias
	If X3USO(x3_usado) .And. cNivel >= X3_NIVEL
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	Skip
EndDo

//��������������������������������������������������������������Ŀ
//� Obtem o tamanho do aCols e monta-o logo em seguida           �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Seek cFilial+cTabela
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
	nCnt++
	Skip
EndDo
PRIVATE aCOLS[nCnt][nUsado]

dbSelectArea( cAlias )
Seek cFilial+cTabela
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
	nCnt++
	nUsado:=0
	Select SX3
	Seek cAlias
	While !EOF() .And. X3_ARQUIVO == cAlias
		If X3USO(x3_usado) .And. cNivel >= X3_NIVEL
			nUsado++
			aCOLS[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
		EndIf
		Skip
	EndDo
	dbSelectArea( cAlias )
	Skip
EndDo

//��������������������������������������������������������������Ŀ
//� Posiciona ponteiro do arquivo cabeca e inicializa variaveis  �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Seek cFilial+cTabela

//������������������������������������������������������Ŀ
//� Mostra o cabecalho                                   �
//��������������������������������������������������������
nRegistro := RecNo( )
dbSelectArea( "SX5" )
dbSeek( cFilial + "00" + cTabela )
cDescSx5 := cTabela + "  "+Iif(!Eof( ), X5Descri(), "" )
dbGoTo( nRegistro )

//������������������������������������������������������Ŀ
//� Mostra o corpo                                       �
//��������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80
@1.4, .8 Say OemToAnsi(STR0007 + cDescSx5) //"Tabela :"

oGet := MSGetDados():New(34,5,128,315,nOpcx,"","")
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()})
//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Go nSavRec

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160Inclui� Autor � Eveli Morasco         � Data � 14/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de tabelas                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C160Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION C160Inclui(cAlias,nReg,nOpcx)
LOCAL nUsado:=0,nOpca:=0
LOCAL GetList:={}
LOCAL oDlg,oGet

lCFG016Auto := If (Type("lCFG016Auto") == "U",.f.,lCFG016Auto)

//��������������������������������������������������������������Ŀ
//� Monta o cabecalho do GetDados                                �
//����������������������������������������������������������������
PRIVATE aHeader[0]
Private cTabela := "  "
Select Sx2
Seek cAlias

Select Sx3
Seek cAlias
While !EOF() .And. X3_ARQUIVO == cAlias
	If X3USO(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CAMPO != "X5_TABELA"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	Skip
EndDo

//��������������������������������������������������������������Ŀ
//� Inicializa o aCols com brancos                               �
//����������������������������������������������������������������
PRIVATE aCOLS[1][nUsado+1]
Select Sx3
Seek cAlias
nUsado:=0
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CAMPO != "X5_TABELA"
		nUsado++
		*���������������������������Ŀ
		*� Monta Array de 1 elemento �
		*� vazio. Se inclus�o.       �
		*�����������������������������
		IF x3_tipo == "C"
			aCOLS[1][nUsado] := SPACE(x3_tamanho)
		ELSEIF x3_tipo == "N"
			aCOLS[1][nUsado] := 0
		ELSEIF x3_tipo == "D"
			aCOLS[1][nUsado] := dDataBase
		ELSE
			aCOLS[1][nUsado] := .F.
		ENDIF
	ENDIF
	Skip
EndDo
aCols[1][nUsado+1] := .F.

//������������������������������������������������������Ŀ
//� Aceita o corpo                                       �
//��������������������������������������������������������
If !(lCFG016Auto)
	DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80
	@ 1.4, .8 Say   OemToAnsi(STR0008 )  // "&Tabela:"
	@ 1.4,  5 MSGET cTabela Picture "@!"  Valid C160Tabela(cTabela)

	oGet := MSGetDados():New(34,5,128,315,nOpcx,"C160LinOk","C160TudOk","",.T.,,,.F.,2000)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
Else
	MsAuto2aCols()
	aValidGet := {}
	Aadd(aValidGet,{"cTabela"    ,aAutoCab[SX5->(FieldPos("X5_TABELA")),2],"C160Tabela(cTabela)",.t.})
	If ! SX5->(MsVldGAuto(aValidGet)) // consiste os gets
		Return .f.
	EndIf
	If ! SX5->(MsVldAcAuto(aValidGet,"C160LinOk()","C160TudOk()"))   // consiste o campos do Acols
		Return .f.
	EndIf
	nOpcA := 1
EndIf
	
IF nOpcA ==1
	C160Grava(cAlias,cTabela)
ENDIF
dbSelectArea( cAlias )
Return nOpca
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160Altera� Autor � Eveli Morasco         � Data � 19/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de alteracao de tabelas                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C160Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada no menu                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION C160Altera(cAlias,nReg,nOpcx)
LOCAL nCnt,nUsado:=0
LOCAL nOpcA:=0,GetList:={}
LOCAL nRegistro,oDlg,oGet,cDescSx5

*����������������������������������������������������������������������Ŀ
*�Salva a integridade dos dados                                         �
*������������������������������������������������������������������������
LOCAL nSavRec  := RecNo()

Private cTabela := SX5->X5_TABELA
//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea( cAlias )
If RecCount() == 0
	Return .T.
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se esta' na filial correta                          �
//����������������������������������������������������������������
If cFilial != X5_FILIAL
	Help(" ",1,"A000FI")
	Return .T.
EndIf

//��������������������������������������������������������������Ŀ
//� Monta o cabecalho do GetDados                                �
//����������������������������������������������������������������
PRIVATE aHeader[0]
Select Sx2
Seek cAlias

Select Sx3
Seek cAlias
While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CAMPO != "X5_TABELA"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	Skip
EndDo

//��������������������������������������������������������������Ŀ
//� Obtem o tamanho do aCols e monta-o logo em seguida           �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Seek cFilial+cTabela
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
	nCnt++
	Skip
EndDo
PRIVATE aCOLS[nCnt][nUsado+1]

dbSelectArea( cAlias )
Seek cFilial+cTabela
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
	nCnt++
	nUsado:=0
	Select SX3
	Seek cAlias
	While !EOF() .And. X3_ARQUIVO == cAlias
		IF X3USO(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CAMPO != "X5_TABELA"
			nUsado++
			aCOLS[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
		EndIf
		Skip
	EndDo
	aCols[nCnt][nUsado+1] := .F.
	dbSelectArea( cAlias )
	Skip
EndDo


//��������������������������������������������������������������Ŀ
//� Posiciona ponteiro do arquivo cabeca e inicializa variaveis  �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Seek cFilial+cTabela

//������������������������������������������������������Ŀ
//� Mostra o cabecalho                                   �
//��������������������������������������������������������
nRegistro := RecNo( )
dbSelectArea( "SX5" )
dbSeek( cFilial + "00" + cTabela )
cDescSx5 :=  cTabela +"  "+Iif(!Eof( ), X5Descri(), "" )
dbGoTo( nRegistro )

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80
@ 1.4, .8 Say OemToAnsi(STR0008 +cDescSx5)   // "&Tabela:"

oGet := MSGetDados():New(34,5,128,315,nOpcx,"C160LinOk","C160TudOk","",.T.,,,.F.,2000)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
IF nOpcA == 1
	C160Grava(cAlias,cTabela)
ENDIF


//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Go nSavRec
Return nOpca

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160Deleta� Autor � Eveli Morasco         � Data � 19/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de tabelas                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C160Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION C160Deleta(cAlias,nReg,nOpcx)
LOCAL nCnt,nUsado:=0,nx
LOCAL nSavRec:=RecNo(),cSaveMenuh,nCntDel:=0
LOCAL nRegistro,oDlg,nOpca:=0,oGet,cDescSx5

Private cTabela:=X5_TABELA
//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea( cAlias )
If RecCount() == 0
	Return .T.
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica se esta' na filial correta                          �
//����������������������������������������������������������������
If cFilial != X5_FILIAL
	Help(" ",1,"A000FI")
	Return .T.
EndIf

//��������������������������������������������������������������Ŀ
//� Monta o cabecalho do GetDados                                �
//����������������������������������������������������������������
PRIVATE aHeader[0]
Select Sx2
Seek cAlias

Select Sx3
Seek cAlias
While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CAMPO != "X5_TABELA"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	Skip
EndDo

//��������������������������������������������������������������Ŀ
//� Obtem o tamanho do aCols e monta-o logo em seguida           �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Seek cFilial+cTabela
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
	nCnt++
	Skip
EndDo
PRIVATE aCOLS[nCnt][nUsado]

dbSelectArea( cAlias )
Seek cFilial+cTabela
nCnt := 0
While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
	nCnt++
	nUsado:=0
	Select SX3
	Seek cAlias
	While !EOF() .And. X3_ARQUIVO == cAlias
		IF X3USO(x3_usado) .And. cNivel >= X3_NIVEL .And. X3_CAMPO != "X5_TABELA"
			nUsado++
			aCOLS[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
		EndIf
		Skip
	EndDo
	dbSelectArea( cAlias )
	Skip
EndDo


//��������������������������������������������������������������Ŀ
//� Posiciona ponteiro do arquivo cabeca e inicializa variaveis  �
//����������������������������������������������������������������
dbSelectArea( cAlias )
Seek cFilial+cTabela

nRegistro := RecNo( )
dbSelectArea( "SX5" )
dbSeek( cFilial + "00" + cTabela )
cDescSx5 := cTabela + "  " + Iif(!Eof( ), X5Descri(), "" )
dbGoTo( nRegistro )

//������������������������������������������������������Ŀ
//� Mostra o corpo                                       �
//��������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80
	@ 1.4, .8 Say OemToAnsi(STR0008 + cDescSx5)  // "&Tabela:"
	oGet := MSGetDados():New(34,5,128,315,nOpcx,"","","")
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()})
IF nOpcA == 1
	nCntDel := 0

	For nX := 1 To Len(aCols)
		Seek cFilial+cTabela+aCols[nX][1]
		If Found()  //aCols[nX][Len(aCols[nX])]
			RecLock(cAlias,.F.)
			dbDelete()
			nCntDel++
		EndIf
	Next nx

	Unlock All
Else
	dbSelectArea( cAlias )
	Go nSavRec
ENDIF

//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
dbSelectArea( cAlias )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                                                                       ���
���                                                                       ���
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
���                                                                       ���
���                                                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160Tabela� Autor � Eveli Morasco         � Data � 14/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a digitacao do codigo da tabela                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C160Tabela(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Variavel com codigo da tabela a inserir            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION C160Tabela(cTabela)

If Empty(cTabela)
	Help(" ",1,"VAZIO")
	Return .F.
EndIf

Select SX5
Seek cFilial+cTabela
If Found()
	Help(" ",1,"C160TABELA")
	Return .F.
EndIf

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160LinOk � Autor � Eveli Morasco         � Data � 17/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se a linha digitada esta' Ok                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C160LinOk(o)
LOCAL nx,lRet := .T.,i
LOCAL nElemChave,nCont := 0,nK

If aCols[n][Len(aCols[n])]   && caso tenha sido deletado
	Return .T.
EndIf

For nX := 1 To Len(aHeader)
	If Trim(aHeader[nX][2]) == "X5_CHAVE"
		nElemChave := nX
		cChave := aCols[n][nx]
		Exit
	EndIf
Next nX

For nx = 1 To Len(aHeader)
	If Empty(aCols[n][nx])
		If cTabela != "01" .and. n != Len(aCols)
			Help(" ",1,"C16002")
			lRet := .F.
		Elseif cTabela== "01"
			If  !("X5_CHAVE" $ aHeader[nX][2]) // Nao permite inclusao de Varias linhas em branco
				 If Empty(aCols[n][nx])
			  		 Help(" ",1,"C16002")
					 lRet := .F.
				 Endif
			Endif
		Else
	  		Help(" ",1,"C16002")
			lRet := .F.
		Endif
		If !lRet
			Exit
		Endif
	Endif
Next nx

If lRet
	For nX := 1 To Len(aCols)
		If nX != n .And. aCols[n][nElemChave] == aCols[nX][nElemChave] .And. !aCols[nx][Len(aCols[nx])]
			If !Empty(aCols[n][nElemchave]) .and. !Empty(aCols[n][nElemChave])
				Help(" ",1,"C16003")
				lRet := .F.
				Exit
			Endif
		EndIf
	Next nX
EndIf

If lRet
	nCont := 0
	For i := 1 To Len(aCols)
		IF !aCols[i][Len(aCols[i])] // Se Nao Esta Deletado
			If cTabela != "01"
				If (Empty(aCols[i,1]) .and. !Empty(aCols[i,2])) .or. (!Empty(aCols[i,1]) .and. Empty(aCols[i,2]))
						Help(" ",1,"C16002")
						lRet := .F.
				Endif
			Else
				If (!Empty(aCols[i,1]) .and. Empty(aCols[i,2]))
						Help(" ",1,"C16002")
						lRet := .F.
				Elseif (Empty(aCols[i,1]) .and. !Empty(aCols[i,2]))
					nCont++
					if nCont > 1
						Help(" ",1,"C16003")
						lRet := .F.
					Endif
				Endif
			Endif
		Endif
	Next i
Endif


Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160TudOk � Autor � Eveli Morasco         � Data � 17/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica se todas as linhas estao Ok                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C160TudOk(o)
LOCAL nx ,ny ,nMaxArray ,lRetorna := .T., cJaTem
Local nElemChave := 0

For nX := 1 To Len(aHeader)
	If Trim(aHeader[nX][2]) == "X5_CHAVE"
		nElemChave := nX
		Exit
	EndIf
Next nX

//��������������������������������������������������������������Ŀ
//� verifica se o ultimo elemento do array esta em branco        �
//����������������������������������������������������������������
For nx := Len(aCols) to 1 Step -1
	IF Empty(aCols[Len(aCols),1]) .and. Empty(aCols[Len(aCols),2])
		ADEL(aCols,Len(acols))
		aSize(aCols,Len(aCols)-1)
	Endif
Next
nMaxArray := Len(aCols)
IF cTabela == "01"
	cJaTem :=""
	For ny := 1 to nMaxArray
		IF aCols[ny][nElemChave] $cJaTem .and. !aCols[ny,Len(aCols[ny])]
			Help(" ",1,"C16003")
			Return .f.
		Else
			cJatem+=aCols[ny][nElemChave]
		Endif
	Next
	Return .t.
Endif
For ny = 1 to Len(aHeader)
	If nMaxArray > 0
		If Empty(aCols[nMaxArray][ny]) .and. !aCols[nMaxArray][Len(aCols[nMaxArray])]
			Help(" ",1,"C16002")
			Exit
		EndIf
	Endif
Next ny

For ny = 1 to nMaxArray

	For nx = 1 to Len(aHeader)
		If Empty(aCols[ny][nx]) .and. !aCols[ny][Len(aCols[ny])]
			Help(" ",1,"C16002")
			lRetorna := .F.
			Exit
		EndIf
	Next nx

Next ny

Return lRetorna


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C160Grava � Autor � Eveli Morasco         � Data � 14/08/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os registros da tabela                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C160Grava(ExpC1,ExpC2)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpC2 = Codigo da tabela a gravar                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CFGX016                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C160Grava(cAlias,cTabela)
LOCAL nx ,ny ,nMaxArray ,aAnterior := {} ,nCntDel := 0
LOCAL cVar

// Begin Transaction
//��������������������������������������������������������������Ŀ
//� verifica se o ultimo elemento do array esta em branco        �
//����������������������������������������������������������������
nMaxArray := Len(aCols)
For ny = 1 to Len(aHeader)
	If Empty(aCols[nMaxArray][ny]) .and. cTabela != "01"
		nMaxArray--
		Exit
	EndIf
Next ny

dbSelectArea( cAlias )
Seek cFilial+cTabela
If Found()
	While !EOF() .And. X5_FILIAL+X5_TABELA == cFilial+cTabela
		AADD(aAnterior,RecN())
		Skip
	EndDo
EndIf

For nx = 1 to nMaxArray

	If Len(aAnterior) >= nx
		Go aAnterior[nx]
		RecLock(cAlias,.F.)
	Else
		RecLock(cAlias,.T.)
	EndIf

	If aCols[nx][Len(aCols[nx])]  && verifica se tem marcacao para apagar
		dbDelete()
		nCntDel++
	Else
		//����������������������������������������������������������Ŀ
		//� ataualiza dados padroes                                  �
		//������������������������������������������������������������
		Replace X5_FILIAL With cFilial,X5_TABELA With cTabela

		//��������������������������������������������������������������Ŀ
		//� ataualiza restante dos dados                                 �
		//����������������������������������������������������������������
		For ny = 1 to Len(aHeader)
			cVar := Trim(aHeader[ny][2])
			Replace &cVar. With aCols[nx][ny]
		Next ny
	EndIf

Next nx

MsUnlockAll()
Return .T.

