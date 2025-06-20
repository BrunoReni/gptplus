#include "QIPA150.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA150  � Autor � Marcelo Pimentel      � Data � 01.10.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Plano de Amostragem                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Revis�o  �                                          � Data �          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {	{STR0002,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
                     	{STR0003,"AxVisual"  , 0 , 2}	,; //"Visualizar"
                     	{STR0004,"QP150Man"  , 0 , 3}	,; //"Incluir"
                     	{STR0005,"QP150Man"  , 0 , 4}	,; //"Alterar"
                     	{STR0006,"QP150Del"  , 0 , 5 , 3 }} //"Excluir"

Return aRotina

Function QIPA150()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0001)  //"Cadastro de Tipos de Planos"

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

QQB->(dbSetOrder(2))

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QQB")

Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QipA150Del� Autor � Marcelo Pimentel      � Data � 18/12/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de exclus�o dos planos de amostragem associados.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �QipA150Del()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP150Del(cAlias,nReg,nOpc)
Local lRet		:= .T.
LOCAL nOpcA		:= 0 
Local nCntDele	:= 0
Local cCod		:= ''
Local lMostraMens := 	.F.
Local cPlanoAmos    := ''
Local cPlano        := ''
Local cNivelNQA		:= ''
Local cTipoPl		:= ''
Local oDlg

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

//��������������������������������������������������������������Ŀ
//� Verifica se a Norma podera ser excluida						 �
//����������������������������������������������������������������
If !QPVerNorma(QQB->QQB_PLANO)
	Return(NIL)
EndIf	

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	cPlanoAmos  := QQB->QQB_PLANO
	cNivelNQA	:= "ESP"+QQB->QQB_CODIGO
	lMostraMens := QP150ChPl(cNivelNQA,cPlanoAmos)
	
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	If lMostraMens
		MsgAlert(STR0007,"Aten��o") //"Este plano de amostragem j� est� sendo utilizado na especifica��o de produtos, n�o poder� ser alterado."
		nOpcA:=AxVisual( cAlias, nReg, 2)
	Else 
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0008)) //"Quanto � exclus�o?"
		nOpca := 1
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
		dbSelectArea(cAlias)

		IF nOpcA == 2	// Confirma
			Begin Transaction
				//Exclui tipo de plano de amostragem
				cPlano  := QQB->QQB_PLANO
				cTipoPl := QQB->QQB_CODIGO	
				RecLock(cAlias)
				dbDelete()
				MsUnLock()
			
				dbSelectArea('QA6')
				dbSetOrder(2)
				If dbSeek(xFilial('QA6')+cPlano+cTipoPl)
					While	!Eof() .And. xFilial('QA6')+cPlano+cTipoPl == QA6_FILIAL+QA6_PLANO+QA6_NIVEL
						RecLock('QA6',.F.)
						dbDelete()
						MsUnlock()
						dbSkip()	
					EndDo	
				EndIf
				
				dbSelectArea('QA7')
				dbSetOrder(3)
				If dbSeek(xFilial('QA7')+cPlano+'ESP'+cTipoPl)
					While !Eof() .And. xFilial('QA7')+cPlano+"ESP"+cTipoPl == QA7_FILIAL+QA7_PLANO+QA7_NQA
						RecLock('QA7')
						dbDelete()
						MsUnlock()
						dbSkip()
					EndDo
				EndIf
			End Transaction
		Else
			MsUnLock()
	   EndIf
	EndIf
   Exit
EndDo
QQB->(dbSetOrder(2))
dbSelectArea(cAlias)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QP150Man � Autor � Vera Lucia S. Simoes  � Data � 28/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa atualizacao Tipo de Plano de Amostragem           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QP150Man(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QP150Man(cAlias,nReg,nOpc)
LOCAL nOpcA			:= 0
Local lMostraMens	:= .F.
Local cPlanoAmos    := ''
Local cNivelNQA		:= ''

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	If !INCLUI
		nOpcA:=0
		cPlanoAmos  := QQB->QQB_PLANO
		cNivelNQA	:= "ESP"+QQB->QQB_CODIGO
		               
		//��������������������������������������������������������������Ŀ
		//� Verifica se a Norma podera ser alterada						 �
		//����������������������������������������������������������������
		If !QPVerNorma(QQB->QQB_PLANO)
			Return(NIL)
		EndIf	
		
		//�����������������������������������������������������������������������������Ŀ
		//� Verifica se existe Plano de Amostragem ja cadastrado no Plano de Amostragem �
		//�������������������������������������������������������������������������������
		lMostraMens := 	QP150ChPl(cNivelNQA,cPlanoAmos)
	EndIf
	
	Begin Transaction
		If lMostraMens
			MsgAlert(STR0007,STR0009) //"Este plano de amostragem j� est� sendo utilizado na especifica��o de produtos, n�o poder� ser alterado."###"Aten��o"
			nOpcA:=AxVisual( cAlias, nReg, 2)
		Else	
			if nOpc == 3  // Inclusao
				nOpcA:=AxInclui( cAlias, nReg, nOpc,,,,"QP150TUDOK()")
			elseif nOpc == 4  // Alteracao
				nOpcA:=AxAltera( cAlias, nReg, nOpc)
			endif
			If __LANGUAGE <> "PORTUGUESE" .And. nOpcA == 1
				QQB->(RecLock("QQB",.F.))
				QQB->QQB_DESCSP := QQB->QQB_DESCRI
				QQB->QQB_DESCEN := QQB->QQB_DESCRI
				QQB->(MsUnLock())
			Endif
		EndIf
	End Transaction
   Exit
EndDo
QQB->(dbSetOrder(2))
dbSelectArea(cAlias)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP150ChPl � Autor � Vera Lucia S. Simoes  � Data � 28/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a verificacao no arquivo de plano de amostragem, se    ���
���          � existe plano cadastrado na especif. de produtos            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �QP150ChPl(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QP150ChPl(cNivelNQA,cPlanoAmos)
Local cNomArq		:= ''
Local cInd			:= ''
Local cFiltro		:= ''
Local lRet			:= .F.

dbSelectArea('QQH')
cNomArq := CriaTrab('',.F.)
cInd    := 'QQH_FILIAL+QQH_NQA'
cFiltro := 'QQH_FILIAL=="'+xFilial("QQH")+'".And.QQH_NQA=="'+cNivelNQA+'" .And. QQH_PLANO == "' + cPlanoAmos + '"'
IndRegua('QQH',cNomArq, cInd,, cFiltro, 'Selecionando Registros...')
cInd := RetIndex('QQH')

dbSetOrder(cInd + 1)
dbGotop()
While !Eof()
	If QQH_NQA == cNivelNQA
		lRet	:= .T.
		Exit
	EndIf
	dbSkip()
EndDo
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPA150   �Autor  �Microsiga           � Data �  11/21/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o Total da tela                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Valida��o Total da tela                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QP150TUDOK
Local lReturn:= .T. 

If EMPTY(M->QQB_PLANO)
	messageDlg(STR0010)//"Dever� ser informado um tipo de Plano de Amostragem"
	lReturn:=.F.
Endif


Return(lReturn)
