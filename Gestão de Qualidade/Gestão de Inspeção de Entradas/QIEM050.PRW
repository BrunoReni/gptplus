#INCLUDE "QIEM050.CH"
#include "PROTHEUS.CH"
#Define PARETO "6"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEM050  � Autor � Vera Lucia S. Simoes  � Data � 06/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de geracao do Diagrama de Pareto                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaQIE                                                    ���
���          � Obs.: Se nao especificar a revisao do produto, considera a ���
���          � revisao vigente na data de Entrada limite (ate), para exi- ���
���          � bir os ensaios para escolha e para identificar os Limites  ���
���          � Engenharia. Neste caso (revisao em branco) serao conside-  ���
���          � radas as medicoes de todas as revisoes que existirem no    ���
���          � periodo, mesmo que haja diferenca de especificacao do en-  ���
���          � saio, de uma revisao para outra.                           ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �20/04/99�------� Inclusao da Loja do Fornecedor           ���
���Paulo Emidio�28/08/00�004790� Alterado programa para fechar o TMP apos ���
���            �        �      � a edicao dos browses.                    ���
���Paulo Emidio�21/05/01�META  � Alterado programa para que possa ser sele���
���       	   �		�	   � cionado o Tipo da Nota Fiscal de Entrada ���
���       	   �		�	   � sendo a mesma 1)Normal 2)Beneficiamento  ���
���       	   �		�	   � 3)Devolucao.							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIEM050
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cAlias := Alias()
Local cRevi  := "  "
Local cTit   := OemToAnsi(STR0001)	// "Diagrama de Pareto"
Local lCont  := .T.
Local lBrwEns:= .f.
Local oTempTable	:= NIL    

Private cIndex1
Private nIndex
Private nOpt1  := 1
Private cMarca := GetMark()
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

//��������������������������������������������������������������Ŀ
//� Selecao da geracao do Diagrama de Pareto                     �
//� mv_par01: Produto                ? (Um ou Todos)             �
//� mv_par02: Revisao                ? (Uma ou Todas)            �
//� mv_par03: Fornecedor      De     ?                           �
//� mv_par04: Fornecedor      Ate'   ?                           �
//� mv_par05: Data de Entrada De     ?                           �
//� mv_par06: Data de Entrada Ate'   ?                           �
//� mv_par07: Lote            De     ?                           �
//� mv_par08: Lote            Ate'   ?                           �
//� mv_par09: Ensaiador       De     ?                           �
//� mv_par10: Ensaiador       Ate'   ?                           �
//� mv_par11: Laboratorio     De     ?                           �
//� mv_par12: Laboratorio     Ate'   ?                           �
//� mv_par13: Mostra a Coluna Outros ?                           �
//� mv_par14: Considera Entradas     ? 1)Normal 				 �
//�								       2)Beneficiamento 		 �
//� 							       3)Devolucao				 �
//� mv_par15 = Filial de?                                        �
//� mv_par16 = Filial ate?                                       �
//� mv_par17 = Loja Forn. de                                     �
//� mv_par18 = Loja Forn. ate                                    �  
//� mv_par19 = Nota Fiscal                                       �
//� mv_par20 = Serie NF                                          �
//����������������������������������������������������������������

If Pergunte("QEM050",.T.)

	//������������������������������������������������������������������Ŀ
	//� Valida o Produto / Revisao                                       �
	//��������������������������������������������������������������������
	If !Empty(mv_par01)
		mv_par01 := Upper(mv_par01)

		If Empty(mv_par02)	// Nao especificou a revisao
			QE6->(dbSetOrder(1))
			If !QE6->(dbSeek(xFilial("QE6")+mv_par01))
				Help(" ",1,"QIEPRODNAO")	// "Produto nao cadastrado."
				lCont := .F.
			EndIf
		Else
			If !QE6->(dbSeek(xFilial("QE6")+mv_par01+Inverte(mv_par02)))
				Help(" ",1,"QIEPRRVNAO")	// "Produto/Revisao nao cadastrados."
				lCont := .F.
			EndIf
		EndIf
	EndIf

	If lCont
		//������������������������������������������������������������������Ŀ
		//� Identifica a revisao a ser adotada                               �
		//��������������������������������������������������������������������

		//��������������������������������������������������������������Ŀ
		//� Utiliza a Revisao atual, caso nao tenha sido esepcificada	 �
		//����������������������������������������������������������������
		If !Empty(mv_par01)
			lBrwEns := .t.
			If !Empty(mv_par02)
				cRevi := mv_par02
			Else
				cRevi := QA_UltRevEsp(mv_par01,mv_par06,,,"QIE")
			EndIf
		EndIf

		//������������������������������������������������������������������Ŀ
		//� Chamada da Funcao para montar o Browse para escolha dos ensaios  �
		//��������������������������������������������������������������������
		If lBrwEns
			lCont := M050BrwEns(cRevi,cTit,@oTempTable)
		EndIf

		//���������������������������������������������������������������������Ŀ
		//� Chamada da Funcao para montar o Browse para escolha das Classes NC  �
		//�����������������������������������������������������������������������
		If lCont
			M050BrwCla(cRevi,cTit,lBrwEns)
		EndIf
		
		//�����������������������������������Ŀ
		//� Deleta Arquivo Temporario Ensaios �
		//�������������������������������������
		If lBrwEns				
			Set Filter to
			oTempTable:Delete()
		EndIf
		
	EndIf
EndIf
dbSelectArea(cAlias)
Return NIL

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050BrwEns � Autor � Vera Lucia S. Simoes� Data � 06/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse para a escolha dos ensaios - MarkBrowse       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M050BrwEns(ExpC1,ExpC2,ExpC3)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Revisao                                            ���
���          � ExpC2 = Titulo da Janela                                   ���
���          � ExpC3 = Arquivo temporario ensaios (a ser criado - @)      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M050BrwEns(cRevi,cTit,oTempTable)
Local aStru := {}
Local nOpcA := 0
Local lRetu := .t.
Local aCpos := {}
Local oMark
Local  oDlg

Private lInverte := .F.

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                                     �
//����������������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QE7_ENSAIO")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QE1_DESCPO")[1],0} )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_ENSAIO"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Redefinicao do acpos para utilizar no MarkBrow               �
//����������������������������������������������������������������
acpos := {{"TB_OK"		,"",OemToAnsi(STR0005)},;	//"Ok"
	  	   {"TB_ENSAIO"	,"",OemToAnsi(STR0006)},;	// "Ensaio"
		   {"TB_DESCRI"	,"",OemToAnsi(STR0007)}}	// "Descri��o"

//��������������������������������������������������������������Ŀ
//� Alimenta arquivo temporario dos Ensaios                      �
//����������������������������������������������������������������
// Ensaios mensuraveis
QE7->(dbSetOrder(1))
QE7->(dbSeek(xFilial("QE7")+mv_par01+cRevi))
While !QE7->(Eof()) .And. QE7->QE7_FILIAL == xFilial("QE7");
		.And. QE7->QE7_PRODUT == mv_par01 .And. QE7->QE7_REVI == cRevi
	
	If QE7->QE7_LABOR < mv_par11  .Or. QE7->QE7_LABOR > mv_par12
       QE7->(dbSkip())
       Loop
    EndIF
    
	RecLock("TRB",.T.)
	TRB->TB_ENSAIO	:= QE7->QE7_ENSAIO
	TRB->TB_DESCRI	:= QIEXDeEn(QE7->QE7_ENSAIO)
	QE7->(dbSkip())
EndDo

// Ensaios Texto
QE8->(dbSetOrder(1))
QE8->(dbSeek(xFilial("QE8")+mv_par01+cRevi))
While !QE8->(Eof()) .And. QE8->QE8_FILIAL == xFilial("QE8");
		.And. QE8->QE8_PRODUT == mv_par01 .And. QE8->QE8_REVI == cRevi
		
	If QE8->QE8_LABOR < mv_par11  .Or. QE8->QE8_LABOR > mv_par12
       QE8->(dbSkip())
       Loop
    EndIF

	RecLock("TRB",.T.)
	TRB->TB_ENSAIO	:= QE8->QE8_ENSAIO
	TRB->TB_DESCRI	:= QIEXDeEn(QE8->QE8_ENSAIO)
	QE8->(dbSkip())
EndDo

dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else

	DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 26,62 OF oMainWnd
	oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{30,1,125,250})
	oMark:oBrowse:lCanAllMark:=.T.
	oMark:oBrowse:lHasMark	 :=.T.
	oMark:bMark 			:= {| | M050Escol(cMarca,lInverte,oDlg)}
	oMark:oBrowse:bAllMark	:= {| | M050MarkAll(cMarca,oDlg)}
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()})
	If nOpcA <> 1
		lRetu := .f.
	Endif
	
EndIf
Return(lRetu)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050BrwCla � Autor � Vera Lucia S. Simoes� Data � 06/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse para a escolha das Classes de NC - MarkBrowse ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M050BrwCla(ExpC1,ExpC2,ExpL1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Revisao                                            ���
���          � ExpC2 = Titulo da Janela                                   ���
���          � ExpL1 = Indica se montou o Browse para escolha dos ensaios ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M050BrwCla(cRevi,cTit,lBrwEns)
Local oTempTable	:= NIL
Local aStru := {}
Local nOpcA := 0
Local lRetu := .f.
Local acpos := {}
Local cDir	:= ""
Local oMark
Local oDlg

Private lInverte := .F.

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                                     �
//����������������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_CLASSE"	,	"C",TamSX3("QEE_CLASSE")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QEE_DESCPO")[1],0} )

oTempTable := FWTemporaryTable():New( "TRB1" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_CLASSE"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Redefinicao do acpos para utilizar no MarkBrow               �
//����������������������������������������������������������������
acpos := {{"TB_OK"		,"",OemToAnsi(STR0005)},;	// "Ok"
		   {"TB_CLASSE"	,"",OemToAnsi(STR0008)},;	// "Classe NC"
		   {"TB_DESCRI"	,"",OemToAnsi(STR0007)}}	// "Descri��o"

//��������������������������������������������������������������Ŀ
//� Alimenta arquivo temporario das Classes de Nao Conformidade  �
//����������������������������������������������������������������
QEE->(dbSetOrder(1))
QEE->(dbSeek(xFilial("QEE")))
While !QEE->(Eof()) .And. QEE->QEE_FILIAL == xFilial("QEE")
	RecLock("TRB1",.T.)
	TRB1->TB_CLASSE	:= QEE->QEE_CLASSE
	TRB1->TB_DESCRI	:= QEE->QEE_DESCPO
	QEE->(dbSkip())
EndDo

dbSelectArea("TRB1")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else
	DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 23,60 OF oMainWnd
	oMark := MsSelect():New("TRB1","TB_OK",,acpos,lInverte,cMarca,{30,1,100,240})
	oMark:oBrowse:lCanAllMark:=.T.
	oMark:oBrowse:lHasMark	 :=.T.
	oMark:bMark 			:= {| | M050Esc1(cMarca,lInverte,oDlg)}
	oMark:oBrowse:bAllMark	:= {| | M050M1All(cMarca,oDlg)}
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()})
	If nOpcA == 1
		lRetu := .t.
	Endif
EndIf

If lRetu
	//�����������������������������������������������������������������Ŀ
	//� Obtem o diretorio para a criacao dos arquivos de graficos (SPC) �
	//�������������������������������������������������������������������
	cDir := GetMv("MV_QDIRGRA")      

	//���������������������������������������������������������Ŀ
	//�Verifica se o diretorio do grafico e um  diretorio Local �
	//�����������������������������������������������������������
	If !QA_VerQDir(cDir) 
		Return
	EndIf 
	
	//�����������������������������������Ŀ
	//� Chama a rotina que gera o Grafico �
	//�������������������������������������
	M050GerDP(cRevi,lBrwEns,cDir)

EndIf
		
//�����������������������������������������Ŀ
//� Deleta Arquivo Temporario Classes de NC �
//�������������������������������������������
Set Filter to
oTempTable:Delete()

Return(lRetu)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050Marca  � Autor � Vera Lucia S. Simoes� Data � 06/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Avalia Marca.                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M050Marca()

dbSelectArea("TRB")
If LastKey() == K_ENTER
	RecLock(cTrb,.F.)
	TRB->TB_OK := Iif(Empty(TRB->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050Escol  � Autor � Vera Lucia S. Simoes� Data � 08/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Escolhe os Ensaios                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M050Escol(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= "  "
	Else
		TRB->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050Esc1   � Autor � Vera Lucia S. Simoes� Data � 08/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Escolhe as Classes de NC                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M050Esc1(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB1",.F.)
	If !lInverte
		TRB1->TB_OK	:= cMarca
	Else
		TRB1->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB1",.F.)
	If !lInverte
		TRB1->TB_OK	:= "  "
	Else
		TRB1->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050MarkAll� Autor �Vera Lucia S. Simoes � Data � 08/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte os Ensaios Marcados/Desmarcados                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M050MarkAll(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050M1All  � Autor �Vera Lucia S. Simoes � Data � 08/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte as Classes NC Marcadas/Desmarcadas                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M050M1All(cMarca,oDlg)
LOCAL nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB1",.F.)
	If Empty(TRB1->TB_OK)
		TRB1->TB_OK	:= cMarca
	Else
		TRB1->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M050M1     � Autor � Vera Lucia S. Simoes� Data � 06/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Avalia Marca.                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M050M1()

dbSelectArea("TRB1")
If LastKey() == K_ENTER
	RecLock("TRB1",.F.)
	TRB1->TB_OK := Iif(Empty(TRB1->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbGotop()
	While !Eof()
		RecLock("TRB1",.F.)
		TRB1->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbGotop()
	While !Eof()
		RecLock("TRB1",.F.)
		TRB1->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbGotop()
EndIf
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �M050GerDP � Autor � Vera Lucia S. Simoes  � Data � 06/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera arquivo (SPC) para gerar o grafico                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M050GerDP(ExpC1,ExpL1,ExpC2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Revisao do Produto                                  ���
���          � ExpL1: Indica se montou o browse para escolha dos ensaios  ���
���          � ExpC2: Diretorio para a geracao do arquivo SPC             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEM050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M050GerDP(cRevi,lBrwEns,cDir)
Local cCond 
Local cKey
Local nIndex
Local cNomArq := ""
Local aNC     := {}
Local aNcGraf := {}
Local aDados  := {}
Local aDad64 := {}
Local nPos
Local nI
Local cArqSPC := ""
Local cSenhas := "1"
// Monta condicao do Filtro de acordo com os parametros
If !Empty(mv_par16)
	cCond := 'QEK_FILIAL >="'+mv_par15+'" .And. QEK_LOJFOR<="'+mv_par16+'" .And. '       
Else
	cCond := 'QEK_FILIAL=="'+xFilial("QEK")+'" .And. '
EndIf

//verifica o Tipo de Entrada selecionado
If mv_par14 == 1
	cCond += '(QEK->QEK_TIPONF == "N" .Or. QEK->QEK_TIPONF == " ") .And.'
ElseIf mv_par14 == 2
	cCond += 'QEK->QEK_TIPONF == "B".And.'
ElseIf mv_par14 == 3
	cCOnd += 'QEK->QEK_TIPONF == "D".And.'
EndIf

If !Empty(mv_par01)
	cCond := 'QEK_PRODUT=="'+mv_par01+'" .And. '
	If !Empty(mv_par02)
		cCond+= 'QEK_REVI=="'+cRevi+'" .And. '
	EndIf
EndIf
cCond+= 'QEK_FORNEC>="'+mv_par03+'" .And. QEK_FORNEC<="'+mv_par04+'" .And. '       
//�������������������������������������������������������������������Ŀ
//� Verifica a Loja Forenecedor  							       	  �
//���������������������������������������������������������������������
If !Empty(mv_par18)
	cCond+= 'QEK_LOJFOR>="'+mv_par17+'" .And. QEK_LOJFOR<="'+mv_par18+'" .And. '       
EndIf
cCond+= 'Dtos(QEK_DTENTR)>="'+Dtos(mv_par05)+'" .And. Dtos(QEK_DTENTR)<="'+Dtos(mv_par06)+'" .And. '
cCond+= 'QEK_LOTE>="'+mv_par07+'" .And. QEK_LOTE<="'+mv_par08+'"'
		
//����������������������������������������������������������Ŀ
//� Pega o nome do arquivo de indice de trabalho             �
//������������������������������������������������������������
dbSelectArea("QEK")
cKey:= IndexKey()
//����������������������������������������������������������Ŀ
//� Cria o indice de trabalho                                �
//������������������������������������������������������������
cNomArq:=CriaTrab(NIL,.F.)
IndRegua("QEK",cNomArq,cKey,,cCond,OemToAnsi(STR0011))		//"Selecionando Registros..."
nIndex := RetIndex("QEK")
dbSetOrder(nIndex+1)
dbGoTop()

QER->(dbSetOrder(1))
// Seleciona as Entradas de acordo com os parametros
dbSelectArea("QEK")
dbGoTop()
While !QEK->(Eof())

	// Seleciona as medicoes da Entrada
	cChvQER := xFilial("QER")+QEK->QEK_PRODUT+QEK->QEK_REVI+QEK->QEK_FORNEC+;
		QEK->QEK_LOJFOR+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
	QER->(dbSeek(cChvQER))
	While !QER->(Eof()) .And. QER->QER_FILIAL+QER->QER_PRODUT+QER->QER_REVI+;
		QER->QER_FORNEC+QER->QER_LOJFOR+Dtos(QER->QER_DTENTR)+QER->QER_LOTE == cChvQER

		// Se montou browse ensaios, verifica se escolheu este ensaio
		If lBrwEns	
			TRB->(dbSeek(QER->QER_ENSAIO))
			If TRB->(Eof()) .Or. Empty(TRB->TB_OK)
				QER->(dbSkip())
				Loop
			EndIf
		EndIf


		// Verifica o Ensaiador
		If (!Empty(mv_par09) .And. QER->QER_ENSR < mv_par09) .Or. ;
			(!Empty(mv_par10) .And. QER->QER_ENSR > mv_par10)
			QER->(dbSkip())
			Loop
		EndIf

		// Obtem chave de ligacao da medicao com os outros arquivos
		cChvMed := QER->QER_CHAVE

		// Verifica se a medicao apresenta NC
		QEU->(dbSetOrder(1))
		If QEU->(dbSeek(xFilial("QEU")+cChvMed))
			While QEU->QEU_FILIAL+QEU->QEU_CODMED == xFilial("QEU")+cChvMed .And. !QEU->(Eof())
				// Verifica se a Classe da NC foi escolhida
				TRB1->(dbSeek(QEU->QEU_CLASSE))
				If TRB1->(Eof()) .Or. Empty(TRB1->TB_OK)
					QEU->(dbSkip())
					Loop
				EndIf

				nPos := ascan(aNC, { |x| x[1] == QEU->QEU_NAOCON })
				If nPos == 0
					// NC, Ocorrencia
					Aadd(aNC, { QEU->QEU_NAOCON, QEU->QEU_NUMNC })
				Else
					aNC[nPos][2]+= QEU->QEU_NUMNC
				EndIf
				QEU->(dbSkip())
			EndDo
		EndIf
		QER->(dbSkip())
	EndDo
	QEK->(dbSkip())
EndDo

If Len(aNc) <> 0

	// Ordena o vetor de NCs em ordem descendente de ocorrencia de NCs
	aNC := aSort(aNC,,, { | x,y | x[2] > y[2] })

	//��������������������������������������������������������������Ŀ
	//� Gera array com as 11 NCs de maior ocorrencia, acumulando as  �
	//� demais na 12a.                                               �
	//����������������������������������������������������������������
	For nI := 1 to Len(aNC)
		If nI < 12
			// NC, Ocorrencia
			Aadd(aNcGraf, { aNC[nI,1], aNC[nI,2] })
		Else  
			If MV_PAR13 == 1
				If nI == 12
					Aadd(aNcGraf, { OemToAnsi(STR0012), aNC[nI,2] })	// "Outras"
				Else
					aNcGraf[12,2]+= aNC[nI,2]
				EndIf
			EndIf
		EndIf
	Next nI

	//��������������������������������������Ŀ
	//� Monta vetor com os dados do grafico  �
	//����������������������������������������
	Aadd(aDados,"QACHART.DLL - PARETO")
	Aadd(aDados,"[DADOS PARETO]")

	For nI := 1 to Len(aNcGraf)
		Aadd(aDados,AllTrim(Str(aNcGraf[nI,2]))+";"+aNcGraf[nI,1])
		Aadd(aDad64,{ AllTrim(Str( aNcGraf[nI,2])), aNcGraf[nI,1]})
	Next nI
	Aadd(aDados,"[FIM DADOS PARETO]")

	//��������������������������������������������������������������Ŀ
	//� Ponto Entrada para impressao do titulo no grafico.           �
	//����������������������������������������������������������������
	If ExistBlock("QIEM050T")
		//�����������������Ŀ
		//� Grava o Titulo �
		//�������������������
		Aadd(aDados,"[TITLE]")
		Aadd(aDados,ExecBlock("QIEM050T",.F.,.F.))
	EndIf  

	Aadd(aDados,"[LANGUAGE]")
	Aadd(aDados,Upper(__Language) )

	//��������������������������������������������������������������Ŀ
	//� Ponto Entrada para impressao do titulo no grafico.           �
	//����������������������������������������������������������������
	If ExistBlock("QIEM050F")
	//�����������������Ŀ
		//� Grava o Rodape �
		//�������������������
		Aadd(aDados,"[FOOT]")
		Aadd(aDados,ExecBlock("QIEM050F",.F.,.F.))
	EndIF

	IF lExistChart 
		QIEMGRAFIC(aDad64, 2)
	Else

		// Gera o nome do arquivo SPC
		cArqSPC := M050NoArq(cDir)

		If !Empty(cArqSPC)
			//���������������������Ŀ
			//� Grava o arquivo SPC �
			//�����������������������
			lGera := GeraTxt32(aDados, cArqSPC, cDir)
			If lGera
				//��������������������������������������������������������������������������������������Ŀ
				//� Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos �
				//� nao perca a conexao.																 �
				//����������������������������������������������������������������������������������������
				PtInternal(9,"FALSE")

				Calldll32("ShowChart",cArqSPC,"6",cDir,PARETO,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))

				//Exclui o arquivo SPC gerado	
				Ferase(cDir+cArqSPC)
				PtInternal(9,"TRUE")
			EndIf
		EndIf
	Endif

Else
	MessageDlg(OemToAnsi(STR0013),,3)	// "N�o foram encontradas N�o Conformidades, a partir dos dados solicitados."
EndIf
//��������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                             �
//����������������������������������������������������������������
dbSelectArea("QEK")
Set Filter to
RetIndex("QEK")
Ferase(cNomArq+OrdBagExt())
dbSetOrder(1)

Return .T.                                 


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �M050NoArq � Autor � Vera Lucia S. Simoes  � Data � 28/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera nome do arquivo SPC									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM050													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M050NoArq(cDir)
Local cArq	:= ""
Local nI 	:= 0

//������������������������������������������������Ŀ
//� Verifica o arquivo disponivel com extensao SPC �
//��������������������������������������������������
For nI := 1 to 99999
	cArq := "QIE" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI

Return cArq
