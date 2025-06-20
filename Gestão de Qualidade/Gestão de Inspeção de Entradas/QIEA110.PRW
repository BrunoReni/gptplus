#INCLUDE "QIEA110.CH"
#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEA110  � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Classes de Situacao             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                    {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                    {OemToAnsi(STR0003),"A110ISit"  , 0 , 3},;  // "Incluir"   
                    {OemToAnsi(STR0004),"A110ISit"  , 0 , 4},;  // "Alterar"   
                    {OemToAnsi(STR0005),"A110DeSi"  , 0 , 5, 3} }  // "Excluir"
                    
Return aRotina

Function QIEA110
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Situa��o"

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
mBrowse( 6, 1,22,75,"QEG")

Set Key VK_F12 To	

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110DeSi � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Situacao - Delecao              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110DeSi(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110DeSi(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto � exclus�o?" 
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2

		cCod := QEG->QEG_SITU
		//���������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em Amarr. FornXProd �
		//�����������������������������������������������������������

  		dbSelectArea('SA5') 
		dbSetOrder(1)
		dbSeek(xFilial("SA5"))
		lAchou := .f.
		While A5_FILIAL == xFilial("SA5") .and. ! eof()
			if A5_SITU == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo

		if lAchou
  		  	HELP(" ",1,"A110DSITPF",,SA5->A5_PRODUTO+' - '+;
				SA5->A5_FORNECE,4,1)
			dbSelectArea(cAlias)
			Exit
		EndIf

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
	
			//  Recalcula os IQI Inferiores de todos os registros do QEG
			dbSelectArea(cAlias)
			dbGoto(nReg)
			If nOpcA==2 // Confirmou
				A110CIQI()			
			Endif

		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110ISit � Autor � Vera Lucia S. Simoes  � Data � 11/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Situacao - Inclusao/Alteracao   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110ISit(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110ISit(cAlias,nReg,nOpc)
LOCAL nOpcA:=0

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
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif

		//  Calcula os IQI Inferiores de todos os registros do QEG
		dbGoto(nReg)
		If nOpcA==1
			A110CIQI()			
		Endif

	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110CIQI � Autor � Vera Lucia S. Simoes  � Data � 11.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que calcula o IQI Inferior p/ Classe da Situacao    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110CIQI()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110CIQI()
Local nIqi_Inf

nIqi_Inf := 0.00
DbSelectArea("QEG")
nRec := QEG->(recno())
DbSetOrder(2)  // Chave: IQI Superior
DbSeek(xFilial("QEG"))
While QEG_FILIAL == xFilial("QEG") .and. ! Eof()
	RecLock("QEG",.F.)
	QEG->QEG_IQI_I := nIqi_Inf
	MsUnLock()
	nIqi_Inf := QEG->QEG_IQI_S + 0.01
	DbSkip()
Enddo
DbSetOrder(1)
QEG->(DbGoTo(nRec))
Return nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110VlIS � Autor � Vera Lucia S. Simoes  � Data � 09.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se IQI Superior ja' existe para outra Classe        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110VlIS()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110VlIS()
Local nRec := QEG->(Recno()), lRetu := .t.

DbSelectArea("QEG")
DbSetOrder(2)  // Chave: IQI Superior
DbSeek(xFilial("QEG") + str(M->QEG_IQI_S,6,2))
If Found() .and. QEG_SITU <> M->QEG_SITU
  	HELP(" ",1,"A110IQSEXI",,QEG_SITU,2,1)
   lRetu := .f.
EndIf
DbSetOrder(1)
QEG->(DbGoTo(nRec))
Return(lRetu)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110DSit � Autor � Vera Lucia S. Simoes  � Data � 21.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para preencher a descricao Situacao                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110DSit(ExpC1,ExpL1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Situacao                                 ���
���          � ExpL1 = Indica se e' gatilho                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (A5_SITU)    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

Apos o acerto da Axinclui e Axaltera, tirar o comentario e do MatxFunb

Function A110DSit(cSitu,lGatilho)
lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)

IF !Inclui .or. lGatilho	// Se Inic. Padrao ou gatilho a partir do cod. equipe
	QEG->(dbSeek(xFilial("QEG") + cSitu))
	Return(QEG->QEG_NIVEL)
Else
	Return(Space(Len(QEG->QEG_NIVEL)))
EndIf

/*/

