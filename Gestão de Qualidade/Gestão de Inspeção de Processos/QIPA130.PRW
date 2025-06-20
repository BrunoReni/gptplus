#INCLUDE "QIPA130.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA130  � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Lote (Opcoes de Skip-Lote) ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A130ISkL"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A130ISkL"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A130DSkL"  , 0 , 5, 3} }  // "Excluir"

Return aRotina

Function QIPA130
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Skip-Lote"

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
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
QPF->(dbSetOrder(2))
mBrowse( 6, 1,22,75,"QPF")
QPF->(dbSetOrder(1))
Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130DSkL � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Lote - Delecao             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130DSkL(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function A130DSkL(cAlias,nReg,nOpc)

Local oDlg
Local nOpcA    := 0
Local cCod     := ""
Local nOrd01   := 0
Local cIndex   := ""
Local cKey     := ""
Local cFiltro  := ""
Local lApaga   := .T.

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA:=0
dbSelectArea(cAlias)
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto � exclus�o?" 
	nOpca := 1
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
dbSelectArea(cAlias)

IF nOpcA == 2
	cCod := QPF->QPF_SKPLOT

	//�������������������������������������������������Ŀ
	//� Verifica se existem produtos utilizando skiplote�
	//���������������������������������������������������
	nOrd01:= QP6->(IndexOrd())
	DbSelectarea("QP6")
	cIndex  := CriaTrab(Nil,.F.)
	cKey    := "QP6_SKPLOT"
	cFiltro := "QP6_SKPLOT == '" + cCod + "'"
	IndRegua("QP6",cIndex,cKey,,cFiltro,OemToAnsi(STR0014)) // "Validando a Exclusao..."
	If QP6->(!Eof())
		lApaga:= .F.
	EndIf
	RetIndex("QP6")
	Set Filter to
	cIndex += OrDbagExt()
	Delete File &(cIndex)
	QP6->(DbSetOrder(nOrd01))

	If lApaga
		Begin Transaction
			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
		End Transaction
	Else
		Help("",1,"Q130ExistR") // "Existe relacionamento para o Skip-Lote," ### "a exclusao nao sera permitida."
	EndIf

EndIf

dbSelectArea(cAlias)

Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130ISkL � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Skip-Lote - Inclusao/Alteracao  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130ISkL(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130ISkL(cAlias,nReg,nOpc)
Local nOpcA:=0
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]
While .T.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc,,,,"A130ENOK()")

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc,,,,,"A130ENOK()")
		endif

		If nOpcA == 1	// Confirma
			RecLock("QPF", .F.)
			QPF->QPF_QTDINV := Inverte(StrZero(QPF->QPF_QTDE,4))
			MsUnlock()
		EndIf

	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
Return(.T.)
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130DUSL � Autor � Vera Lucia S. Simoes  � Data � 12/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Descricao da Unidade de Skip-Lote                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130DUSL(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Unidade de Skip-Lote                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA130 - Inic. do browse - X3_INIBRW                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130DUSL(cUnSkLt)
Local cRet	:= ''
If cUnSkLt == "1"
	cRet	:= STR0013			//"Producao"
ElseIf cUnSkLt == "2"
	cRet	:= STR0011		//"Dias
EndIf
Return(cRet)
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130WhSk � Autor � Vera Lucia S. Simoes  � Data � 29/05/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Sugere o proximo codigo do Skip-Lote                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A130WhSk()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130WhSk()
Local lRetu := .t.
Local nOrd 	:= QPF->(IndexOrd())
Local nRec	:= QPF->(Recno())
Local cSkLt	:= "  "

If INCLUI
	QPF->(dbSetOrder(1))
	QPF->(dbSeek(xFilial("QPF")))
	While QPF->QPF_FILIAL == xFilial("QPF") .And. !QPF->(Eof())
		cSkLt := QPF->QPF_SKPLOT
		QPF->(dbSkip())
	EndDo

	cSkLt := StrZero(Val(cSkLt)+1,2)

	// Atualiza variavel da tela
	M->QPF_SKPLOT := cSkLt

	QPF->(dbSetOrder(nOrd))
	QPF->(dbGoTo(nRec))
EndIf
Return(lRetu)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130DSLt � Autor � Vera Lucia S. Simoes  � Data � 12.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher a descricao do Skip-Lote            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A060DSLt(ExpC1,ExpL1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Skip-Lote                                ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (A5_SKPLOT)  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130DSLt(cSkLt,lGatilho)
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

IF !Inclui .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. Skip-Lote
	QPF->(dbSeek(xFilial("QPF") + cSkLt))
	Return(QPF->QPF_DESCRI)
Else
	Return(Space(Len(QPF->QPF_DESCRI)))
EndIf
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A130EnOK � Autor � Vera Lucia S. Simoes  � Data � 01/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o dos campos da Enchoice                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA130 - E' chamada no AxInclui/AxAltera                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A130EnOK()
Local lRetu := .T.,;
		nOrd := QPF->(IndexOrd())

//����������������������������������������������������������������������Ŀ
//� Verifica se j� existe a Unidade/Frequencia                           �
//������������������������������������������������������������������������
QPF->(dbSetOrder(2))
If QPF->(dbSeek(xFilial("QPF")+M->QPF_UNSKLT+Str(M->QPF_QTDE,4)))
	If QPF->QPF_SKPLOT <> M->QPF_SKPLOT
		Help(" ",1,"A120SKPEXI")	// "J� existe Skip-Lote com esta Unidade / Frequencia"
		lRetu := .f.
	EndIf
EndIf

//�������������������������������������������������������������������������������Ŀ
//� Verifica se existe a Unidade "1"(Producao) e Frequencia 1: Controla Todas     �
//���������������������������������������������������������������������������������
QPF->(dbSetOrder(2))
If !QPF->(dbSeek(xFilial("QPF")+"1"+Str(1,4))) .And.;
		(M->QPF_UNSKLT <> "1" .Or. M->QPF_UNSKLT == "1" .And. M->QPF_QTDE <> 1)
	Help(" ",1,"qp130SKOB")	// "O Skip-Lote para Controlar todas as producoes � obrigatorio."
	lRetu := .f.
EndIf

QPF->(dbSetOrder(nOrd))
Return(lRetu)
