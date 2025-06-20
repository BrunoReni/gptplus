#INCLUDE "QMTA170.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTA170  � Autor � Wanderley Goncalves Jr� Data � 05/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Registros de Manutencao                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTA170

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
Private  aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1},;  		// "Pesquisar"
{OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  		// "Visualizar"
{OemToAnsi(STR0003),"A170Incl"  , 0 , 3},;  		// "Incluir"
{OemToAnsi(STR0004),"AxAltera"  , 0 , 4},;  		// "Alterar"
{OemToAnsi(STR0005),"A170Dele"  , 0 , 5,3},;  	// "Excluir"
{OemToAnsi(STR0012),"A170Text"  , 0 , 6} } 		// "Texto"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private  cCadastro := OemtoAnsi(STR0006)  //"Registros de Manuten��o"

Private  cDelFunc // Utilizado pelo AxDeleta

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QME")

Set Key VK_F12 To

Return .T.


/*
A170Incl
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A170Incl  � Autor � Wanderley Goncalves   � Data � 05/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclusao para Registros de Manutencao                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A170Incl(cAlias, nReg, nOpc)

Local nOpca

nOpca := AxInclui( cAlias, nReg, nOpc,,,,'qmt170Chv()')

If nOpca == 1
	RecLock(cAlias,.F.)
	QME->QME_FILRES	:= cFilAnt
	MsUnlock()
	MSGINFO(OemToAnsi(STR0010),;   // "Sugerimos que seja efetuado um registro de calibra��o correspondente a esta manuten��o"
	OemToAnsi(STR0011))    // "ATEN��O"
EndIf

Return(.T.)


/*
antigo a170Chav
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �qmt170Chv � Autor � Wanderley Goncalves   � Data � 05/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o dos campos chave                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA170 - E' chamada no X3_VALID.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function qmt170Chv()
Local lRet := .T.

If ! Empty( M->QME_INSTR ) .and. ! Empty( M->QME_REVINS ) .and.;
	! Empty( M->QME_DATA  )
	
	dbSelectArea("QME")
	If dbSeek( xFilial("QME") + M->QME_INSTR + M->QME_REVINS + DtoS(M->QME_DATA))
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	Endif
	
EndIf

Return( lRet )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A170Del  � Autor � Wanderley Goncalves Jr� Data � 12.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclusao de Registros de Manutencao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � A170Dele(ExpC1,ExpN1,ExpN2)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo											  ���
���			 � ExpN1 = Numero do registro 										  ���
���			 � ExpN2 = Opcao selecionada											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTA170																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A170Dele(cAlias, nReg, nOpc)

Local nOpca

Begin Transaction
//�����������������������������������������������Ŀ
//� Apaga tambem no QA2 -> Textos dos Instrumentos�
//�������������������������������������������������
QA_DelTxt(QME->QME_CHAVE,"QMTA170 ") // QAXFUN

nOpca := AxDeleta(cAlias,nReg,nOpc)
End Transaction

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A170Text � Autor � Wanderley Goncalves Jr� Data � 12.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Textos para Registro de Manutencao                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � A170Text(ExpC1,ExpN1,ExpN2)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo											  ���
���			 � ExpN1 = Numero do registro 										  ���
���			 � ExpN2 = Opcao selecionada											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTA170																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A170Text(cAlias, nReg, nOpc)

Local cChave
Local cCabec  := OemtoAnsi(STR0006)  // "Registros de Manuten��o"
Local cTitulo := OemToAnsi(STR0013)  // "Instrumento"
Local nTamLin := TamSX3("QA2_TEXTO")[1]
Local lTxtQa := .T.

axtextos := {} // Vetor que contem os textos

If !empty(QME->QME_CHAVE)
	cChave := QME->QME_CHAVE
Else
	cChave := QA_CvKey(QME_FILIAL + QME_INSTR + QME_REVINS + DTOS(QME_DATA),"QME",2)
	RecLock("QME",.F.)
	QME->QME_CHAVE := cChave
	MsUnlock()
EndIf

cEspecie := 'QMTA170 '

lTxtQa := QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,;
alltrim(QME_INSTR)+' - '+QME_REVINS,@axtextos,1,;
cCABEC,.T.)

//����������������������������������������������������������Ŀ
//� Grava Texto de Manutencao no QA2                  		 �
//������������������������������������������������������������
If lTxtQa  
	QA_GrvTxt(cChave,cEspecie,1,@axtextos)   // QAXFUN
Endif
dbselectArea("QME")

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMT170VlIns� Autora� Iuri Seto           � Data � 11/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � N�o permite incluir manuten��o para instrumentos que       ���
���          � pertencem a uma malha QM2_STATUS = "0"                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMT170VlIns(ExpC1)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = C�digo do Instrumento							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTA170																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QMT170VlIns(cInstr)
Local cAlias := Select()
Local nReg	 := Recno()
Local lRet

lRet := .T. 
dbSelectArea("QM2")
dbSetOrder(1)
If QM2->(dbSeek(xFilial("QM2")+cInstr))
	If QM2->QM2_STATUS == "0"
		msgstop(OemToAnsi(StrTran(STR0014,"%@@",ALLTRIM(QM2->QM2_LOCAL))),OemtoAnsi(STR0015))	// "Instrumento pertence a Malha %@@. O registro da manuten��o dever� ser feito para a Malha." ### "Aten��o"
		lRet := .F.
	EndIf
EndIf
dbSelectArea(cAlias)
dbGoto(nReg)
Return lRet
