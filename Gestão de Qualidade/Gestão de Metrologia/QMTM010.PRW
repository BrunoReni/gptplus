#include "qmtm010.ch"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTM010	� Autor � Wanderley Goncalves Jr� Data � 26.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Reprogramacao de Calibracao de Instrumentos                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTM010(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �	MOTIVO DA ALTERACAO		              ���
�������������������������������������������������������������������������Ĵ��
��� Aldo Marini  �09/09/02�------�Retirada da funcao Ajust aSx1()          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTM010()

//��������������������������������������������������������������Ŀ
//� Define Variaveis 							 			     �
//����������������������������������������������������������������
Local nOpca:=0
Local oGet			
Local lGravaOk := .T.
Local nRec
Local nIndice := 0
Local cIndice := ""
Local cChave := ""
Local dData
Local cInst := ""
Local aAlter := {"FREQAF","VALDAF"}
Local nCntFor
Local nLastKey := 0
Local laCols	:= .F.
Local nx		:= 1
Local lRet      := .T.
Local aNoFields := {}
Local aCpoAdic  := {}
Local lValParm  := SuperGetMv("MV_QMTJUST",.T.,.F.)
Local oDlg
Local oIcon
Local oSay
Local oMemo
Local oBtn1
Local oBtn2

private aHeader[0],Continua:=.F.,nUsado:=0
private aCols[0]
private aRotina := { { Nil, Nil, 0, 6} }
private aCRA := { OemToAnsi(STR0003), OemToAnsi(STR0004), OemToAnsi(STR0005) } // "Confirma" ### "Redigita" ### "Abandona"
private nPosTip, nPosIns, nPosRev, nPosUlt, nPosFre, nPosPre
private cPerg := "QMM010"
private lEnd := .F.

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 							 �
//����������������������������������������������������������������
If !Pergunte(cPerg,.T.)
	Return
EndIf

If lValParm
	If Empty(mv_par13)
		DEFINE MSDIALOG oDlg FROM 58,1 TO 290,300 TITLE STR0011 PIXEL OF oMainWnd  //"Justificativa"
		@ 003,003 TO 095,147 OF oDlg PIXEL
		@ 0.7,002 ICON oIcon RESOURCE "CLIPS" OF oDlg NOBORDER
		@ 011,045 SAY oSay PROMPT STR0013 SIZE 096,030 OF oDlg PIXEL //"Digite abaixo a justificativa dos instrumentos serem reprogamados"
		@ 035,017 GET oMemo VAR mv_par13 SIZE 116,50 OF oDlg MEMO NO VSCROLL PIXEL
		oMemo:bGotFocus := { || oMemo:nPos := 0,oMemo:Refresh()}

		@ 100, 050 BUTTON oBtn1 PROMPT STR0014 SIZE 44, 11 OF oDlg PIXEL ACTION (If(Empty(mv_par13),msgstop(STR0012,STR0009),(oDlg:End()))) //"Confirma" //"Justificativa n�o encontrada.","Aten��o"
		@ 100, 100 BUTTON oBtn2 PROMPT STR0015 SIZE 44, 11 OF oDlg PIXEL ACTION (lRet := .F., oDlg:End()) 	         //"Cancela"	

		ACTIVATE MSDIALOG oDlg CENTER 
	EndIf

	If !lRet
		return .F.
	Endif
Endif

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
private aTELA[0][0],aGETS[0]


//��������������������������������������������������������������Ŀ
//� aNoFields: Campos a serem desconsiderados na montagem padrao �
//� do aHeader pela funcao FillGetDados.                         �
//����������������������������������������������������������������
aNoFields := {"QM2_FILIAL", "QM2_DESCR" ,"QM2_DATREV","QM2_FILRES" ,;
			  "QM2_RESP"  ,"QM2_USOINI","QM2_FREQAF" ,"QM2_FREQAN" ,;
			  "QM2_VALDAF","QM2_VALDAN","QM2_FABR"   ,"QM2_NUMFAB" ,;
			  "QM2_NSEFAB","QM2_TALIM" ,"QM2_RESOL"  ,"QM2_LEIT"   ,;
			  "QM2_POT"   ,"QM2_DEPTO" ,"QM2_NDEPTO" ,"QM2_LOCAL"  ,;
			  "QM2_ESCMAL","QM2_CUSTO" ,"QM2_NHORDI" ,"QM2_ESPMAX" ,;
			  "QM2_ESPMIN","QM2_FREREP","QM2_VALREP" ,"QM2_LAUCO"  ,;
			  "QM2_SGUARD","QM2_DIAM"  ,"QM2_OVAL"   ,"QM2_DESG"   ,;
			  "QM2_STATUS","QM2_REVINV","QM2_OK"     ,"QM2_BITMAP" ,;
			  "QM2_CHAVE" ,"QM2_FLAG"  ,"QM2_ONLINE" ,"QM2_BAUDRA" ,;
			  "QM2_PARITY","QM2_PORTA" ,"QM2_BITDAD" ,"QM2_STOPS"  ,;
			  "QM2_CLIE"  ,"QM2_LOJA"  }

//��������������������������������������������������������������Ŀ
//� aCpoAdic: Campos a serem incluidos apos a montagem padrao do �
//� do aHeader pela funcao FillGetDados.                         �
//����������������������������������������������������������������
aCpoAdic := {"QM6_DATA" , "QM2_FREQAF" ,"QM2_VALDAF"}


  FillGetDados(4   ,"QM2" ,1     ,       ,           ,         ,aNoFields,          ,        ,      ,{|| QM010Acols()},  .F.  ,          ,        ,          ,           ,{|| QM10AfterH(aCpoAdic)},)
//FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols         ,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader              ,cAliasQry

//����������������������������������������������������������������������Ŀ
//� Verifica a posicao dos campos no aHeader p/ posterior consistencia   �
//������������������������������������������������������������������������
nPosTip  := Ascan(aHeader,{|x| x[2] = "QM2_TIPO  "})
nPosIns  := Ascan(aHeader,{|x| x[2] = "QM2_INSTR "})
nPosRev  := Ascan(aHeader,{|x| x[2] = "QM2_REVINS"})
nPosUlt  := Ascan(aHeader,{|x| x[2] = "QM6_DATA  "})
nPosFre  := Ascan(aHeader,{|x| x[2] = "QM2_FREQAF"})
nPosPre  := Ascan(aHeader,{|x| x[2] = "QM2_VALDAF"})



dbSelectArea("QM2")
RetIndex("QM2")	
Set Filter to
Ferase(cIndice + OrdBagExt())
QM2->(DbSetOrder(1))
QM2->(DbGoTop())
 
For nx := 1 To Len(aCols)        
   If nx <= Len(aCols)     
		If dbSeek(xFilial("QM2")+aCols[nx][1])
			If Inverte(QM2->QM2_REVINV) > aCols[nx][2]
				Adel( aCols, nx )
				ASize( aCols, Len(aCols) - 1)    
				nx--
			Endif
		Endif			         
	Endif
Next nx

If Len(aCols) > 0
   lAcols := .T. 
Endif

If laCols
	aHeader[nPosFre][2] := "FREQAF"
	aHeader[nPosPre][2] := "VALDAF"
			
	Continua 	:= .F.
	nOpca 		:= 0
		
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0002) From 9,0 To 28,81 OF oMainWnd	 // "Reprograma��es"
	
	oGet := MSGetDados():New(41,2,190,319,1,"AllwaysTrue","AllwaysTrue","",.F.,aAlter,3)
	oGet:obrowse:Align := CONTROL_ALIGN_ALLCLIENT
			
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(oGet:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()})
	
	If nOpcA == 1
   	
		DbSelectArea("QM2")
		Set Filter to

		Begin Transaction
		Processa ( { |lGravaOk| lGravaOk := Qmtm010Grv() } )
		
		If lGravaOK
			//Processa Gatilhos
			EvalTrigger()
		EndIf
		End Transaction
	Endif
Else
	msgstop(STR0010,STR0009)	// "Nenhuma calibra��o encontrada.","Aten��o"
Endif

Return nOpca


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � TR040Fil � Autor � Alessandro B.Freire   � Data � 20.08.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Filtro do plano de calibracao							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Tr040Fil													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTR040													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Tr010Fil()

//���������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros						    	�
//� mv_par01				// Instrumento Inicial				    	�
//� mv_par02				// Instrumento Final 				    	�
//� mv_par03				// Periodo Inicial		                	�
//� mv_par04				// Periodo Final                    		�
//� mv_par05				// Departamento Inicial 					�
//� mv_par06				// Departamento Final						�
//� mv_par07				// Orgao Calibrador Todos/Interno/Externo   �
//� mv_par08				// Orgao Calibrador interno					�
//� mv_par09				// Orgao Calibrador externo					�
//� mv_par10				// Fam�lia									�
//� mv_par11				// Fabricante								�
//� mv_par12				// Usu�rio									�
//� mv_par13				// Justificativa							�
//�����������������������������������������������������������������������

Local cExpr := ""

cExpr := 'QM2_FILIAL == "'+ xFilial("QM2") + '" .And. '
cExpr += 'QM2_INSTR >= "' + mv_par01 + '" .And. '
cExpr += 'QM2_INSTR <= "' + mv_par02 + '" .And. ' 
cExpr += 'DtoS(QM2_VALDAF) >= "'+ DtoS(mv_par03) + '" .And. '
cExpr += 'DtoS(QM2_VALDAF) <= "'+ DtoS(mv_par04) + '" .And. '
cExpr += 'QM2_DEPTO >= "' + mv_par05 + '" .And. '
cExpr += 'QM2_DEPTO <= "' + mv_par06 + '" .And. '
cExpr += 'QM2_STATUS <> "0" '

If ! Empty( mv_par10 )
	cExpr += ' .And. QM2_TIPO == "' + mv_par10 + '"'
EndIf

If ! Empty( mv_par11 )
	cExpr += ' .And. QM2_FABR == "' + mv_par11 + '"'
EndIf

If ! Empty( mv_par12 )
	cExpr += ' .And. QM2->QM2_RESP == "' + mv_par12 + '"'
EndIf

Return( cExpr )


/*
antigo a010Grava
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Qmtm010Grv� Autor � Wanderley Goncalves   � Data � 01/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava alteracoes de Reprogramacao                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTM010													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qmtm010Grv()

Local nCntFor
Local lAlter 
Local lData
Local dDataAnt
Local nTotal := len(aCols)
Local nRecAch := 0
Local nRecQMD := 0

DbSelectArea("QM2")

ProcRegua(nTotal)

For nCntFor := 1 to len(aCols)

	IncProc(STR0007) // "Processando..."

	DbSelectArea("QM2")
	lAlter := .f.
	lData := .f.    
	dbSetOrder(01)
	If QM2->(DbSeek(xFilial("QM2")+aCols[nCntFor,nPosIns]+;
						Inverte(aCols[nCntFor,nPosRev])))
		dDataAnt := QM2->QM2_VALDAF
		RecLock("QM2",.f.)
		If QM2->QM2_FREQAF <> aCols[nCntFor,nPosFre]
			Replace QM2->QM2_FREQAF with aCols[nCntFor,nPosFre]
			//����������������������������������������������������������������������Ŀ
			//�Altera tambem a frequencia anterior, para evitar erros no Schumacher  �
			//������������������������������������������������������������������������
			Replace QM2->QM2_FREQAN with aCols[nCntFor,nPosFre]
			lAlter := .t.
		EndIf
		If QM2->QM2_VALDAF <> aCols[nCntFor,nPosPre] 
			Replace QM2->QM2_VALDAF with aCols[nCntFor,nPosPre]
			//����������������������������������������������������������������������Ŀ
			//�Altera tambem a frequencia anterior, para evitar erros no Schumacher  �
			//������������������������������������������������������������������������
			Replace QM2->QM2_VALDAN with aCols[nCntFor,nPosPre]
			lData := .t.
			lAlter := .t.
		EndIf
	EndIf
	MsUnLock()

	//����������������������������������������������������������������������Ŀ
	//�Se alterou data, precisa tambem alterar a ultima medicao              �
	//������������������������������������������������������������������������
	If lData
		DbSelectArea("QM6")
		DbSetOrder(2)
		If QM6->(DbSeek(xFilial("QM6")+aCols[nCntFor,nPosIns]+;
												 aCols[nCntFor,nPosRev] ) )
			RecLock("QM6",.f.)
			Replace QM6->QM6_VALDAF with aCols[nCntFor,nPosPre]
			MsUnLock()
		EndIf

		//������������������������������������������������������������������������Ŀ
		//� Verifica se � instrumento malha e se for, altera a validade dos filhos �
		//��������������������������������������������������������������������������
		QMTM010IM(aCols[nCntFor,nPosIns],aCols[nCntFor,nPosPre])

	EndIf

	//����������������������������������������������������������������������Ŀ
	//� Grava registro de alteracao                                          �
	//������������������������������������������������������������������������
	nRecAch := 0
	If lAlter
		dbSelectArea("QMD")
		dbSetOrder(1)
		If !dbSeek(xFilial("QMD")+aCols[nCntFor][nPosIns]+aCols[nCntFor][nPosRev]+DtoS(dDataAnt))
			RecLock("QMD",.T.)
		Else
			If DtoS(QMD->QMD_DATA) == DtoS(dDataBase)
				RecLock("QMD",.F.)		
			Else
				nRecQMD := QMD->(RecNo())
				While !QMD->(Eof()) .And. QMD->QMD_FILIAL+QMD->QMD_INSTR+QMD->QMD_REVINS+DTOS(QMD->QMD_VALDAF) ==;
					xFilial("QMD")+aCols[nCntFor][nPosIns]+aCols[nCntFor][nPosRev]+DTOS(dDataAnt)
					If DtoS(QMD->QMD_DATA) == DtoS(dDataBase)				
						nRecAch := QMD->(Recno())
						RecLock("QMD",.F.)							
						Exit
					Endif
					QMD->(dbSkip())
				Enddo
				QMD->(DbGoTo(nRecQMD))
				If nRecAch == 0
					RecLock("QMD",.T.)											
				Endif
			Endif	
		Endif		            
		Replace QMD->QMD_FILIAL with xFilial("QMD")
		Replace QMD->QMD_INSTR	with aCols[nCntFor][nPosIns]
		Replace QMD->QMD_REVINS with aCols[nCntFor][nPosRev]
		Replace QMD->QMD_VALDAF with dDataAnt
		Replace QMD->QMD_VALREP with aCols[nCntFor][nPosPre]
		Replace QMD->QMD_DATA	with dDataBase
		Replace QMD->QMD_JUSTIF with mv_par13
		MsUnLock()
	EndIf

Next nCntFor

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTM010IM� Autora� Iuri Seto             � Data � 19/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se e instrumento malha e atualiza a validade dos  ���
���          � filhos.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTM010IM(ExpC1,ExpD1)                     				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Instrumento     						  ���
���			 � ExpD1 = Data de Validade  								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTM010  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTM010IM(cInstr,dDataFim)
Local cOldAlias := Select()
Local nRec		:= Recno()

DbSelectArea("QM2")    
DBSetOrder(7)
If QM2->(DbSeek(xFilial("QM2")+"0"+cInstr))
	Do While xFilial("QM2")+"0"+cInstr == QM2->QM2_FILIAL+"0"+QM2->QM2_Local .and. !QM2->(Eof())
		RecLock("QM2",.f.)
		QM2->QM2_VALDAF := dDataFim
		//����������������������������������������������������������������������Ŀ
		//�Altera tambem a frequencia anterior, para evitar erros no Schumacher  �
		//������������������������������������������������������������������������
		QM2->QM2_VALDAN := dDataFim
		QM2->(DbSkip())
		MsUnLock()
	EndDo
EndIf

DbSelectArea(cOldAlias)
DbGoto(nRec)

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QM010Acols�Autor  �Rafael S. Bernardi  � Data �  15/01/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para montagem do aCols                               ���
�������������������������������������������������������������������������͹��
���Uso       � QMTM010                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QM010Acols()
//����������������������������������������������������������������������Ŀ
//� Alimenta aCols                                                       �
//������������������������������������������������������������������������

Local nCntFor  := 0
Local nIndice  := 0
Local nLastKey := 0
Local nPosAli  := Ascan(aHeader,{|X| Upper(Alltrim(X[2])) == "QM2_ALI_WT"})
Local nPosRec  := Ascan(aHeader,{|X| Upper(Alltrim(X[2])) == "QM2_REC_WT"})

nUsado := Len(aHeader)

//��������������������������������������������������������������Ŀ
//� Crio �ndice tempor�rio para corresponder a ordem desejada.   �
//����������������������������������������������������������������
cIndice := CriaTrab(NIL,.F.)
cChave := "QM2_FILIAL+QM2_INSTR+QM2_REVINV"

//�����������������������������������������������������������������Ŀ
//� Seleciona instrumentos conforme condicao no TR010Fil            �
//�������������������������������������������������������������������
IndRegua("QM2",cIndice,cChave,,TR010Fil(),"Selecionando Registros")
nIndice := RetIndex("QM2")
dbSetOrder(nIndice+1)
dbGoTop()

//�������������������������������������Ŀ
//� Verifica se apertou o botao cancela �
//���������������������������������������
If nLastKey == 27 // .Or. LastKey() == 27
	dbSelectArea("QM2")
	RetIndex("QM2")                      
	Set Filter to
	Ferase(cIndice + OrdBagExt())
	QM2->(DbSetOrder(1))
	QM2->(DbGoTop())
	Return
EndIf

//��������������������������������������������������������������Ŀ
//� Salva a integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
dbSelectArea("SX2")	// Posiciona pq. rotinas internas utilizam inf. do SX2
dbSeek("QM2")

DbSelectArea("QM6")
QM6->(DbSetOrder(2))
DBSelectArea("QM2")
QM2->(DbSeek(xFilial("QM2")))
QM2->(DbSetOrder(nIndice+1))
Do while !QM2->(Eof())
	// Testa condicao de orgao calibrador
	If ! ( mv_par07 == 1 )	// Todos

		If ! QmCalib(mv_par07, mv_par08, mv_par09) .OR. QM2->QM2_STATUS == "0"
			QM2->(dbSkip())
			Loop
		EndIf
	EndIf

	If QM6->(DbSeek(xFilial("QM6") + QM2->QM2_INSTR )) 
		dData := QM6->QM6_DATA
	Else
		dData := QM2->QM2_USOINI 
	EndIf
	//����������������������������������������������������������������������Ŀ
	//�Colunas da aCols:                                                     �
	//�- 1o.) Instrumento                                                    �
	//�- 2o.) Revisao do Instrumento                                         �
	//�- 3o.) Familia                                                        �
	//�- 4o.) Ultima medicao (QM6)                                           �
	//�- 5o.) Frequencia                                                     �
	//�- 6o.) Validade da Calibracao                                         �
	//�- 7o.) Coluna de controle de delecao da getdados                      �
	//������������������������������������������������������������������������
	aadd(aCols,Array(nUsado+1))
	
	For nCntFor := 1 To Len(aHeader)
		If ( AllTrim(aHeader[nCntFor,2])!="QM6_DATA" )                                 
			aCols[Len(aCols),nCntFor] := QM2->(FieldGet(FieldPos(aHeader[nCntFor,2])))
		Else
			aCols[Len(aCols),nCntFor] := dData
		EndIf
		If nPosAli > 0 .and. nPosRec > 0
			Acols[Len(aCols),nPosAli] := QM2->(Alias())
			If IsHeadRec(aHeader[nPosRec,2])
				Acols[Len(aCols),nPosRec] := QM2->(RecNo())
			EndIf
		Endif
		aCols[Len(aCols),nUsado+1] := .F.
	Next
	cInst := QM2->QM2_INSTR
	Do while cInst = QM2->QM2_INSTR
		QM2->(DbSkip())
	EndDo
EndDo

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QM10AfterH�Autor  �Rafael S. Bernardi  � Data �  15/01/2007 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao a ser executada apos a montagem padrao do do aHeader ���
���          �pela funcao FillGetDados, para incluir outros campos        ���
�������������������������������������������������������������������������͹��
���Uso       � QMTM010                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QM10AfterH(aCpoAdic)

Local nX
Local aArea := GetArea()
Local nOrdem

dbSelectArea("SX3")
nOrdem := SX3->(IndexOrd())
dbSetOrder(2)

For nx := 1 To Len(aCpoAdic)
	If aCpoAdic[nX] $ "QM2_FREQAF�QM2_VALDAF"
		aadd(aHeader, Q010GetSX3(aCpoAdic[nX], "", "V") )
	Else
		aadd(aHeader, Q010GetSX3(aCpoAdic[nX], OemToAnsi(STR0001), "V") )
	Endif
	nUsado++
Next nX

RestArea(aArea)

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} Q010GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 16/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q010GetSX3(cCampo, cTitulo, cPropri)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              "",;
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              cPropri }
Return aHeaderTmp
