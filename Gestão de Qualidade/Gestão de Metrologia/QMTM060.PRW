#INCLUDE "QMTM060.CH"
#Include "PROTHEUS.CH"
#Define PARETO "6"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTM060	� Autor � Wanderley Goncalves   � Data � 08.03.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de geracao do Diagrama de Pareto				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTM060(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Antonio     �19/07/99�22057 � Parametro de, ate para Status            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTM060()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 										  	 �
//����������������������������������������������������������������
Local cAlias := Alias()
Local cRevi := "  "
Local cTit := STR0003 //"Diagrama de Pareto"
Local lBrwEns := .f.

Private  cIndex1
Private  nIndex,nOpt1 := 1
Private  cMarca := GetMark()
Private  lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

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
//�    6 - Nao permite inclusao na getdados                      �
//����������������������������������������������������������������
// Definida aRotina somente por causa da MarkBrowse, pq. senao d� erro
Private  aRotina := { { "" ,"AxPesqui", 0 , 2} }
			

If pergunte("QMM060",.T.)
	//�����������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros									  �
	//� mv_par01				// Instrumento Inicial							  �
	//� mv_par02				// Instrumento Final 							  �
	//� mv_par03				// Periodo Inicial								  �
	//� mv_par04				// Periodo Final									  �
	//� mv_par05				// Departamento Inicial 						  �
	//� mv_par06				// Departamento Final							  �
	//� mv_par07				// Orgao Calibrador Todos/Interno/Externo   �
	//� mv_par08				// Org.Calib.Intr.Inicial  					  �
	//� mv_par09				// Org.Calib.Intr.Final    					  �
	//� mv_par10				// Org.Calib.Extr.Inicial  					  �
	//� mv_par11				// Org.Calib.Extr.Final    					  �
	//� mv_par12				// Familia Inicial                          �
	//� mv_par13				// Familia Final 									  �
	//� mv_par14				// Fabricante Inicial							  �
	//� mv_par15				// Fabricante Final								  �
	//� mv_par16				// Status de         	                    �
	//� mv_par17				// Status ate        	                    �
	//� mv_par18				// Usu�rio Inicial 								  �
	//� mv_par19				// Usu�rio Final 									  �
	//�������������������������������������������������������������������

	//���������������������������������������������������������������������Ŀ
	//� Chama MarkBrowse para escolha das Classes de NC						   �
	//�����������������������������������������������������������������������
	m060BrwCla(cRevi,cTit,lBrwEns)

EndIf

dbSelectArea(cAlias)

Return NIL


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � m060BrwCla � Autor � Wanderley Goncalves � Data � 08/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse para a escolha das Classes de NC - MarkBrowse ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � m060BrwCla(ExpC1,ExpC2,ExpL1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Revisao                                            ���
���          � ExpC2 = Titulo da Janela                                   ���
���          � ExpL1 = Indica se montou o Browse para escolha dos ensaios ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEm060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function m060BrwCla(cRevi,cTit,lBrwEns)

//Local aCAS := { OemToAnsi(STR0009), OemToAnsi(STR0010) }  //"Confirma" ### "Abandona"
Local aStru := {}
Local nOpcA := 0
Local lRetu := .f.
Local acpos := {}
Local cDir := ""
Local oMark, oDlg
Local oTmpTable := NIL
Private  lInverte := .F.

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                                     �
//����������������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_CLASSE"	,	"C",TamSX3("QEE_CLASSE")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QEE_DESCPO")[1],0} )

oTmpTable := FWTemporaryTable():New( "TRB" )
oTmpTable:SetFields( aStru )
oTmpTable:AddIndex("indice1", {"TB_CLASSE"} )
oTmpTable:Create()

//��������������������������������������������������������������Ŀ
//� Redefinicao do acpos para utilizar no MarkBrow               �
//����������������������������������������������������������������
acpos := {{"TB_OK"			,"",OemToAnsi("Ok")},;
			{"TB_CLASSE"	,"",OemToAnsi("Classe NC")},;
			{"TB_DESCRI"	,"",OemToAnsi("Descricao")}}

//��������������������������������������������������������������Ŀ
//� Alimenta arquivo temporario das Classes de Nao Conformidade  �
//����������������������������������������������������������������
QEE->(dbSeek(xFilial("QEE")))
While !QEE->(Eof()) .And. QEE->QEE_FILIAL == xFilial("QEE")
	RecLock("TRB",.T.)
	TRB->TB_CLASSE	:= QEE->QEE_CLASSE
	TRB->TB_DESCRI	:= QEE->QEE_DESCPO
	QEE->(dbSkip())
EndDo
dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else
	Do While .T.
		DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 26,62 OF oMainWnd
		oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{20,1,125,250})
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			:= {| | m060Esc1(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	:= {| | m060m1All(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(M060OK(),oDlg:End(),)},{||nOpcA:=0,oDlg:End()})
		If nOpcA == 1
			lRetu := .t.
		Endif
		Exit
	EndDo
EndIf

If lRetu
	//�����������������������������������������������������������������Ŀ
	//� Obtem o diretorio para a criacao dos arquivos de graficos (SPC) �
	//�������������������������������������������������������������������
	cDir := GetMv("MV_QDIRGRA")
	//�����������������������������������Ŀ
	//� Chama a rotina que gera o Grafico �
	//�������������������������������������
	M060GerDP(cRevi,lBrwEns,cDir)
EndIf

//��������������������������������������������������������������Ŀ
//� Deleta Arquivo Temporario Classes de NC                      �
//����������������������������������������������������������������
oTmpTable:Delete()

Return(lRetu)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � m060Esc1   � Autor � Wanderley Goncalves � Data � 08/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Escolhe as Classes de NC                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEm060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function m060Esc1(cMarca,lInverte,oDlg)
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
���Fun��o    � m060m1All  � Autor �Wanderley Goncalves  � Data � 08/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte as Classes NC Marcadas/Desmarcadas                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIEm060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function m060m1All(cMarca,oDlg)
Local nRecno:=Recno()
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � M060OK   � Autor � Wanderley Goncalves   � Data � 08.03.99 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Mensagem de OK antes de executar o processamento           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTM060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M060OK()
Return (MsgYesNo(OemToAnsi(STR0006),OemToAnsi(STR0007)))			//"Confirma Sele��o?"###"Aten��o"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �M060NoArq � Autor � Wanderley Goncalves   � Data � 08/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera nome do arquivo SPC									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTM060													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M060NoArq(cDir)

Local cArq	:= ""
Local nI 	:= 0

//������������������������������������������������Ŀ
//� Verifica o arquivo disponivel com extensao SPC �
//��������������������������������������������������
For nI := 1 to 99999
	cArq := "QMT" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI

Return cArq



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �M060GerDP � Autor � Wanderley Goncalves   � Data � 08/03/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera arquivo (SPC) para gerar o grafico                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M060GerDP(ExpC1,ExpL1,ExpC2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Revisao do Produto                                  ���
���          � ExpL1: Indica se montou o browse para escolha dos ensaios  ���
���          � ExpC2: Diretorio para a geracao do arquivo SPC             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTM060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M060GerDP(cRevi,lBrwEns,cDir)

Local cChave  := ""
Local aNC := {}
Local aDados := {}
Local aDad64 := {}
Local aNcGraf := {}
Local nPos := 0
Local cStrAnt := ""
Local cArqSPC	:= ""
Local nI		:= 1
Local cSenhas	:= "1"
Private  cSeql	:= ""

// Verifica se o diretorio do grafico e um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

dbSelectArea("QM2")
dbSetOrder(1)
dbSeek( xFilial("QM2") + mv_par01, .t. )

//�����������������������������������������������������������������Ŀ
//� Loop at� o �ltimo instrumento selecionado.							  �
//� Loop do instrumento.														  �
//�������������������������������������������������������������������
Do While xFilial( "QM2" ) == QM2->QM2_FILIAL .And. !Eof()

	If QM2->QM2_INSTR > mv_par02
		Exit
	EndIf

	dbSelectArea( "QM2" )

	//�����������������������������������������������������������������Ŀ
	//� Pula as revisoes anteriores do mesmo instrumento. 				  �
	//�������������������������������������������������������������������
	If cChave == QM2->QM2_FILIAL+QM2->QM2_INSTR
		dbSkip()
		Loop
	Else
		cChave := QM2->QM2_FILIAL+QM2->QM2_INSTR
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Se n�o est� entre as validades informadas n�o imprime.			  �
	//�������������������������������������������������������������������
/*	If ( QM2->QM2_VALDAF < mv_par03 ) .or. ;
		( QM2->QM2_VALDAF > mv_par04 )
		dbSkip()
		Loop
	EndIf */

	//�����������������������������������������������������������������Ŀ
	//� Se n�o est� entre os departamentos informados, n�o imprime.	  �
	//�������������������������������������������������������������������
	If ( QM2->QM2_DEPTO < mv_par05 ) .or. ( QM2->QM2_DEPTO > mv_par06 )
		dbSkip()
		Loop
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11)
			dbSkip()
			Loop			
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09)
			dbSkip()
			Loop
		EndIf
	EndIf
		
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11)
			dbSkip()
			Loop
		EndIf
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Se n�o � a familia selecionada n�o Imprime. 						  �
	//�������������������������������������������������������������������
	If (QM2->QM2_TIPO < mv_par12) .or. (QM2->QM2_TIPO > mv_par13)
		dbSkip()
		Loop
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� N�o � o fabricante selecionado. 										  �
	//�������������������������������������������������������������������
	If (QM2->QM2_FABR < mv_par14) .or. (QM2->QM2_FABR > mv_par15)
		dbSkip()
		Loop
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Verifica o status.                     								  �
	//�������������������������������������������������������������������	
	If QM2->QM2_STATUS < mv_par16 .Or. QM2->QM2_STATUS > mv_par17
		dbSkip()
		Loop
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� N�o � o usu�rio selecionado. 											  �
	//�������������������������������������������������������������������
	If (QM2->QM2_RESP < mv_par18) .or. (QM2->QM2_RESP > mv_par19)
		dbSkip()
		Loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Procura as escalas amarradas a Familia								  �
	//�������������������������������������������������������������������
	dbSelectArea("QMK")
	dbSetOrder(1)
	If ! dbSeek( xFilial() + QM2->QM2_TIPO )
		dbSelectArea( "QM2" )
		dbSkip()
		Loop
	EndIf

	dbSelectArea( "QM2" ) 


	QM6->(DbSetOrder(1))
	QMJ->(DbSetOrder(1))
	If QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS))
		While QM6->(!Eof()) .And. xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS ==;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS
			If QM6->QM6_DATA >= mv_par03 .and.;  // Data Inicial 
				QM6->QM6_DATA <= mv_par04			// Data Final
				cSeql := QM6->QM6_CSEQ
				If QMJ->(DbSeek(xFilial("QMJ")+QM6->QM6_INSTR+QM6->QM6_REVINS+DtoS(QM6->QM6_DATA)+cSeql))
					While QM6->(!Eof()) .And. xFilial("QMJ")+QM6->QM6_INSTR+QM6->QM6_REVINS+DtoS(QM6->QM6_DATA)+cSeql ==;
						QMJ->QMJ_FILIAL+QMJ->QMJ_INSTR+	QMJ->QMJ_REVINS+DtoS(QMJ->QMJ_DATA)+QMJ->QMJ_CSEQ
						//����������������������������������������������������������Ŀ
						//� Verifica se Classe de NC foi selecionada 		  		 �
						//������������������������������������������������������������
						If TRB->(DbSeek(QMJ->QMJ_CLASS))
							If !empty(TRB->TB_OK)
								nPos := Ascan(aNc, { |x| x[1] == QMJ->QMJ_NAOCON })
								If nPos == 0
									SAG->(DbSetOrder(1))
									SAG->(DbSeek(xFilial("SAG")+QMJ->QMJ_NAOCON))
									Aadd(aNC, { QMJ->QMJ_NAOCON, 1 })
								Else
									aNc[nPos][2]+= 1
								EndIf
							EndIf
						EndIf
						QMJ->(DbSkip())
					EndDo
				EndIf												
			EndIf
			QM6->(DbSkip())
		EndDo
	EndIf

	cStrAnt := QM2->QM2_INSTR

	//��������������������������������������������������������������Ŀ
	//� Revis�o anterior do instrumento deve ser desprezada   		 �
	//����������������������������������������������������������������
	Do while QM2->QM2_INSTR == cStrAnt 
		QM2->(DbSkip())
	EndDo

EndDo

If Len(aNc) <> 0

	// Ordena o vetor de NCs em ordem descendente de ocorrencia de NCs
	aNc := aSort(aNc,,, { | x,y | x[2] < y[2] })

	//��������������������������������������������������������������Ŀ
	//� Gera array com as 11 NCs de maior ocorrencia, acumulando as  �
	//� demais na 12a.                                               �
	//����������������������������������������������������������������
	For nI := 1 to Len(aNC)
		If nI < 12
			// NC, Ocorrencia
			Aadd(aNcGraf, { aNC[nI,1], aNC[nI,2] })
		Elseif nI == 12
			Aadd(aNcGraf, { OemToAnsi(STR0012), aNC[nI,2] })	// "Outras"
		Else
			aNcGraf[12,2]+= aNC[nI,2]
		EndIf
	Next nI

	//��������������������������������������Ŀ
	//� Monta vetor com os dados do grafico  �
	//����������������������������������������
	Aadd(aDados,"QACHART.DLL - PARETO")
	Aadd(aDados,"[DADOS PARETO]")

	For nI := 1 to Len(aNcGraf)
		Aadd(aDados,AllTrim(Str(aNcGraf[nI,2]))+";"+aNcGraf[nI,1])
		Aadd(aDad64,{AllTrim(Str( aNcGraf[nI,2])), aNcGraf[nI,1]})
	Next nI
	Aadd(aDados,"[FIM DADOS PARETO]")

	Aadd(aDados,"[LANGUAGE]")
	Aadd(aDados,Upper(__Language) )

	IF lExistChart 
		QIEMGRAFIC(aDad64, 2)
	Else
		// Gera o nome do arquivo SPC
		cArqSPC := M060NoArq(cDir)

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

				// Exclui o arquivo SPC gerado	
				Ferase(cDir+cArqSPC)
				PtInternal(9,"TRUE")
			EndIf
		EndIf
	EndIf

Else
	MessageDlg(OemToAnsi(STR0012),,3)	// "N�o foram encontradas N�o Conformidades, a partir dos dados solicitados."
EndIf

Ferase(cArqSPC+OrdBagExt())

Return .t.