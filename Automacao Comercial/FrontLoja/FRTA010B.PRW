#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FRTA010B.CH"
Static __lFirst := .T.
Static aItems	:= {}

/*���������������������������������������������������������������������������
���Fun��o	 �FRTGeraSL � Autor � Cesar Eduardo Valadao � Data �07/08/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos campos dos arquivos.                ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
���������������������������������������������������������������������������*/
Function FRTGeraSL(cAlias, aArray, lAppend, lUnLock)
Local cOldAlias	:=Alias()
Local lRet		:=.T.
Local nPosCpo	:= 0
Local nX		:= 0

Default lAppend := .F.
Default lUnLock := .T.

DbSelectArea(cAlias)
If !lAppend .And. !lUnLock
	lRet := MsRLock()
Else
	lRet := RecLock(cAlias, lAppend)
EndIf
If lRet
	For nX := 1 to Len(aArray)
		nPosCpo := ColumnPos(aArray[nX][1])
		
		If nPosCpo > 0
			FieldPut(nPosCpo,aArray[nX][2])
		EndIf
	Next nX
Else
	ConOut("Impossible lock on file "+cAlias+" Record:"+AllTrim(Str(Recno()))+".")
EndIf
If lRet .And. lUnLock
	dbCommit()
	MsUnLock()
EndIf
If !Empty(cOldAlias)
	dbSelectArea(cOldAlias)
EndIf
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTGeraSLI� Autor � Cesar Eduardo Valadao � Data �07/08/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos campos do SLI.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data   � Bops �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Conrado Q.�05/04/07�122711�Alterada a utiliza��o da chamada            ���
���          �        �      �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTGeraSLI(cEstacao, cTipo, cMsg, cDecisao, lUnLock, _cUsuario, _dData, _cHora)
Local aSLI
Local lRet
Local lLI_SEQ	:= SLI->(ColumnPos("LI_SEQ")) > 0	//Existe campo sequencia?
Local cLI_SEQ	:= ""
Local cChaveSLI	:= "" 								//Chave de Busca SLI
Local nTamLiSeq := TamSx3("LI_SEQ")[1]

DEFAULT cDecisao := "ABANDONA"
DEFAULT lUnLock  := .T.
DEFAULT _cUsuario:= cUserName
DEFAULT _dData   := dDataBase
DEFAULT _cHora   := Time()

lAppend := !SLI->(dbSeek(xFilial("SLI")+PadR(cEstacao,4)+cTipo))

If !lAppend
	If Empty(SLI->LI_MSG)
		lAppend := .F.
	Else
		If cDecisao == "ABANDONA"
			Return(NIL)
		ElseIf cDecisao == "SOBREPOE"
			lAppend := .F.
		ElseIf cDecisao == "NOVO"
			lAppend := .T.
		EndIf
	EndIf
EndIf	

If lAppend .AND. lLI_SEQ

	cLI_SEQ := Replicate("0", nTamLiSeq) 
	cLI_SEQ := Soma1(cLI_SEQ, nTamLiSeq)

	cChaveSLI := xFilial("SLI") + PadR(cEstacao,TamSx3("LI_ESTACAO")[1]) + PadR(cTipo, TamSx3("LI_TIPO")[1])
	
	SLI->(DbSetOrder(1)) // LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ
	SLI->(DbGoBottom())
	cLI_SEQ := SLI->LI_SEQ

	Do While SLI->(DbSeek(cChaveSLI + cLI_SEQ))
		cLI_SEQ := Soma1(cLI_SEQ, nTamLiSeq)
	EndDo

EndIf	

aSLI := {{"LI_FILIAL"	, xFilial("SLI")	},;
		 {"LI_ESTACAO"	, cEstacao			},;
		 {"LI_TIPO"		, cTipo				},;
		 {"LI_USUARIO"	, _cUsuario			},;
		 {"LI_DATA"		, _dData			},;
		 {"LI_HORA"		, _cHora			},;
		 {"LI_MSG"		, cMsg				},;
		 {"LI_SEQ"		, cLI_SEQ			}}

lRet := FRTGeraSL("SLI", aSLI, lAppend, lUnLock)
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTGeraSLH� Autor � Cesar Eduardo Valadao � Data �15/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao dos campos do SLH.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data   � Bops �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Conrado Q.�05/04/07�122711�Alterada a utiliza��o da chamada            ���
���          �        �      �SubStr(cUsuario,7,15) por cUserName         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTGeraSLH(cAlias, cSituacao)
Static lUsaSLH, lGravaFi, aFiliais:={}
Local i, aSLH, cChave, cOldAlias:=Alias()
Local nRecnoSM0
Local lOk:=.F.
Local cAux
Local nPosFil	:= 0
Local nPosAlis  := 0
Local nPosChav	:= 0
Local nPosDtAl  := 0
Local nPosHrAl  := 0
Local nTamLHCh	:= TamSx3("LH_CHAVE")[1]

If ValType(lGravaFi) == "U"						// Controla se deve replicar o SLH para todas as filiais
	nRecnoSM0 := SM0->(Recno())
	cAux := FWModeAccess("SBI",3)
	lGravaFi := cAux != FWModeAccess("SB0",3)
	SM0->(DBEval({|| AAdd(aFiliais,FWGETCODFILIAL)}, {|| SM0->M0_CODIGO==cEmpAnt}))
	SM0->(dbGoTo(nRecnoSM0))
EndIf

lUsaSLH := FRTUsaSLH()

If lUsaSLH
	dbSelectArea(cAlias)
	cChave := &(IndexKey(1))
	If cAlias $ "SB1/SB0"
		cAlias := "SB1"										// O alias de todos os registros serah SB1.
		cChave := xFilial("SB0")+Substr(cChave,FWGETTAMFILIAL+1,999)		// A filial de todos os registros serah do SB0.
	EndIf
	aSLH := {{"LH_FILIAL",  xFilial("SLH")},;
			 {"LH_ALIAS",   cAlias},;
			 {"LH_SITUA",   cSituacao},;
			 {"LH_CHAVE",   cChave},;
			 {"LH_DTALT",   dDataBase},;
			 {"LH_HRALT",   Time()},;
			 {"LH_USUARIO", cUserName}}
	If ! (lOk := ChkFile("SLH"))
		// "Aguarde... Atualizando o Log das Modifica��es!!!" ### "Aten��o"
		LJMsgRun(STR0003, STR0002, {|| lOk:=FRTChkFile()})
	EndIf
	
	nPosFil	 := AScan( aSLH, { |x| x[1] == "LH_FILIAL"	} )
	nPosAlis := AScan( aSLH, { |x| x[1] == "LH_ALIAS" 	} )
	nPosChav := AScan( aSLH, { |x| x[1] == "LH_CHAVE" 	} )
	nPosDtAl := AScan( aSLH, { |x| x[1] == "LH_DTALT" 	} )
	nPosHrAl := AScan( aSLH, { |x| x[1] == "LH_HRALT" 	} )

	If lOk
		If lGravaFi
			For i := 1 To Len(aFiliais)
				aSLH[1][2] := aFiliais[i]
				aSLH[4][2] := aFiliais[i]+Substr(aSLH[4][2],3)
				DbSelectArea("SLH")
				DbSetOrder(1)
				If !DbSeek(aSLH[nPosFil][2]+aSLH[nPosAlis][2]+PadR(aSLH[nPosChav][2],nTamLHCh)+DTOS(aSLH[nPosDtAl][2])+aSLH[nPosHrAl][2])
					FRTGeraSL("SLH", aSLH, .T.)
				EndIf
			Next
		Else
			DbSelectArea("SLH")
			DbSetOrder(1)
			If !DbSeek(aSLH[nPosFil][2]+aSLH[nPosAlis][2]+PadR(aSLH[nPosChav][2],nTamLHCh)+DTOS(aSLH[nPosDtAl][2])+aSLH[nPosHrAl][2])
				FRTGeraSL("SLH", aSLH, .T.)
			EndIf	
		EndIf
	Else
		// "O Arquivo de Log das Modifica��es (SLH) n�o pode ser atualizado. "
		// "As informa��es alteradas N�O estar�o dispon�veis na pr�xima Carga nas Esta��es." ### "Aten��o"
		MsgStop(STR0004+STR0005, STR0002)
	EndIf
	dbSelectArea(cOldAlias)
EndIf
Return(NIL)
    
Static Function FRTChkFile
Local i, lOk
For i := 1 To 10
	If (lOk := ChkFile("SLH"))
		Return(.T.)
	EndIf
	Sleep(1000)
Next
Return(lOk)

Static Function FRTUsaSLH
Local nHandle, lRet:=.F., cMV_DIRCFRT
cMV_DIRCFRT := GetMV("MV_DIRCFRT")
nHandle := FCreate(cMV_DIRCFRT+"TEMP.TMP")
If nHandle != -1
	lRet := .T.
	FClose(nHandle)
	FErase(cMV_DIRCFRT+"TEMP.TMP")
EndIf
Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTPegaIT � Autor � Cesar Eduardo Valadao � Data �07/08/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Transforma o Numero Item Para 2 Bytes.                     ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
�������������������������������������������������������������������������Ĵ��
���  DATA  � BOPS �Program.� MOTIVO DA ALTERACAO                          ���
�������������������������������������������������������������������������Ĵ��
���02/09/03�S/BOPS�Solange �Transd. do caracter recebido em maiusculo.    ���
�������������������������������������������������������������������������Ĵ��
���18/07/07�128428�Danilo  �Tratamento para considerar a condicao do para-���
���        �      �Calil   �metro MV_SOMAOLD.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTPegaIT(uItem)

Local nX		:= 0					// Contador de For
Local nY		:= 0					// Contador de For
Local aTemp 	:= {}					// Array temporario
Local nTamSd2It	:= TamSX3("D2_ITEM")[1]	//Tamanho do campo D2_ITEM
 
//��������������������������������������������������������������Ŀ
//�Se o campo for caracter transformar em maiusculo por seguran�a�
//����������������������������������������������������������������
If ValType(uItem) == "C"
   uItem := Upper( Right(uItem, nTamSd2It) )
EndIf

//�����������������������������Ŀ
//�Monta o Array Somente uma Vez�
//�������������������������������
If Len(aItems) == 0			
	aTemp := {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	For nX := Asc("A") To Asc("Z")
		AAdd(aTemp, Chr(nX))
	Next
	For nX := 1 To 99
		AAdd(aItems, StrZero(nX,2,0))
	Next

	//����������������������������Ŀ
	//�Tratamento para o MV_SOMAOLD�
	//������������������������������
	If SuperGetMV("MV_SOMAOLD",NIL,.F.)
		For nX := Asc("A") To Asc("Z")
			For nY := 1 To Len(aTemp)
				AAdd(aItems, Chr(nX)+aTemp[nY])
			Next
		Next
    Else
		//���������������������������������������������Ŀ
		//�Tratamento para quando o MV_SOMAOLD for falso�
		//�����������������������������������������������
		For nX := Asc("A") To Asc("Z")
			AAdd(aItems, "9" + chr(nX))
		Next

		For nX := Asc("A") To Asc("Z")
			For nY := 1 To Len(aTemp)
				AAdd(aItems, Chr(nX)+aTemp[nY])
			Next
		Next
    
    EndIf
EndIf
If ValType(uItem) == "N"
	uRet := aItems[uItem]
ElseIf ValType(uItem) == "C"
	uRet := AScan(aItems, uItem)
EndIf

Return(uRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTCancela� Autor � Cesar Eduardo Valadao � Data �14/11/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza o cancelamento do SL, SL2 e SL4                    ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTCancela(lDeletaSL1, lDeletaSL2, lDeletaSL4)

Local lOk := .T.

Default lDeletaSL1 := .T.
Default lDeletaSL2 := .T.
Default lDeletaSL4 := .T.

//�������������������������������������������������������������������������Ŀ
//� Foi adicionado esta trava devido a um problema no cancelamento do cupom	�
//� quando � enviado o pacote de gravacao.									�
//� Quando esta sendo incluido uma venda, e assim que o pacote foi enviado,	�
//� nao tiver dado tempo para a gravacao na retaguarda, o cancelamento		�
//� nao e feito na retaguarda, causando problemas de sincronizacao de base.	�
//���������������������������������������������������������������������������
If lDeletaSL1 .AND. lDeletaSL2 .AND. lDeletaSL4
	DbSelectArea( "SL1" )

	If !RecLock( "SL1", .F. )
		lOk := .F.
		MsgStop( STR0009 ) //"N�o foi poss�vel cancelar o cupom pois est� sendo utilizado no momento. Tente novamente."

	EndIf
EndIf

If lOk
	//�������������������������������Ŀ
	//�Cancela as formas de pagamento �
	//���������������������������������
	If lDeletaSL4
		dbSelectArea("SL4")
		dbSetOrder(1)
		dbSeek(xFilial()+SL1->L1_NUM)
		While (L4_FILIAL+L4_NUM == xFilial()+SL1->L1_NUM) .And. !EOF()
			RecLock("SL4",.F.)
			dbDelete()
			MsUnlock()
			dbSkip()
		End
	EndIf
	//�������������������Ŀ
	//� Cancelar os Itens �
	//���������������������
	If lDeletaSL2
		dbSelectArea("SL2")
		dbSetOrder(1)
		dbSeek(xFilial()+SL1->L1_NUM)
		While (L2_FILIAL+L2_NUM == xFilial()+SL1->L1_NUM) .And. !EOF()
			RecLock("SL2", .F.)
			dbDelete()
			MsUnLock()
			dbSkip()
		End
	EndIf
	If HasTemplate("DRO") 
		T_DROCancANVISA()
	Endif
	//������������������Ŀ
	//� Cancelar o Cupom �
	//��������������������
	If lDeletaSL1
		//Eh necessario excluir os registros de troco criados no PDV...
		If cPaisLoc <> "BRA" .And. SuperGetMV("MV_LJTRLOC",,.F.)
			dbSelectArea("SE5")
			dbSetOrder(2)
			If dbSeek(xFilial("SE5")+"VL"+SL1->L1_SERIE+SL1->L1_DOC)	    	
				While !Eof() .And. xFilial("SE5")+"VL"+E5_PREFIXO+E5_NUMERO == xFilial("SE5")+"VL"+SL1->L1_SERIE+SL1->L1_DOC
					If Empty(E5_TIPO) .And. E5_MOEDA == "TC" .And. E5_RECPAG == "P" .And.;
					   E5_CLIFOR == SL1->L1_CLIENTE .And. E5_LOJA == SL1->L1_LOJA
					   
						RecLock("SE5",.F.)
						dbDelete()
						MsUnLock()					
					EndIf
				    dbSkip()
				End
			EndIf
		EndIf
		dbSelectArea("SL1")
		RecLock("SL1", .F.)
		dbDelete()
		MsUnLock()
	EndIf
EndIf

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTChkModo� Autor � Cesar Eduardo Valadao � Data �17/11/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a checagem das filiais do SB1 e SBI. Devido ao SBI ���
���          � uma compilacao dos campos necessarios ao FrontLoja, eh     ���
���          � preciso que os dois arquivos tenham a mesma filial.        ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTChkModo
Local cModoSB1, cModoSBI, cModoSB0, cModoSLH

cModoSB1 := FWModeAccess("SB1",3)
cModoSBI := FWModeAccess("SBI",3)
cModoSB0 := FWModeAccess("SB0",3)
cModoSLH := FWModeAccess("SLH",3)
//����������������������������������������������������Ŀ
//� Modos de abertura compativeis:                     �
//� - SB0, SB1, SBI e SLH COMPARTILHADOS,              �
//� - SB0, SB1, SBI e SLH EXCLUSIVOS,                  �
//� - SB1 e SBI COMPARTILHADOS e SB0 e SLH EXCLUSIVOS. �
//������������������������������������������������������
If cModoSB1 != cModoSBI
	// "Modo de abertura incompat�vel" ### "� necess�rio que as tabelas SB1 e SBI tenham o mesmo modo de abertura."
	Aviso(STR0006, STR0001, {"Ok"})
EndIf
If cModoSB0 != cModoSLH
	// "Modo de abertura incompat�vel" ### "� necess�rio que as tabelas SB0 e SLH tenham o mesmo modo de abertura."
	Aviso(STR0006, STR0007, {"Ok"})
EndIf
If cModoSB1=="E" .And. cModoSB0=="C"
	// "Modo de abertura incompat�vel" ### "N�o � poss�vel utilizar o modo de abertura EXCLUSIVO para a tabela SB1/SBI e COMPARTILHADO para a tabela SB0."
	Aviso(STR0006, STR0008, {"Ok"})
EndIf
Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTSemafor� Autor � Cesar Eduardo Valadao � Data �28/06/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria um Semaforo em Arquivo.                               ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data   � Bops �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������͹��
���Mauro Sano�01/08/07|129740�Feita melhoria para matar a thread caso     ���
���          �        |      �fique presa ao ocorrer a queda do Server.	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTSemaforo(cTipo, cEstacao, nHandle)
Local lMVLjKillT	:= SuperGetMv( "MV_LjKillT", .F., .F. )			// Verifica conteudo do parametro para determinar o tratamento das threads
Local nId			:= ThreadId()									// Id da Thread atual
Local aThreads		:= {}											// Captura dados de todas as Threads
Local nX			:= 0											// Variavel de looping

If __lFirst
	MakeDir("\SEMAFORO\SIGAFRT\")
	__lFirst := .T.
EndIf                                                                                                  
  
If lMVLjKillT
	aThreads		:= GetUserInfoArray()
EndIf

nHandle := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cTipo+cFilAnt+cEstacao," ","")+".L"+StrTran(cEmpAnt," ",""))
PtInternal( 1, cTipo+cFilAnt+AllTrim(cEstacao)+".L"+cEmpAnt ) 

If nHandle < 0
	If lMVLjKillT
		For nX := 1 To Len( aThreads )                                                                     
			//��������������������������������������������������������Ŀ
			//�Verifico pelo nome da thread e pela observacao da thread�
			//�antes de finaliza-la.                                   �
			//����������������������������������������������������������
			If aThreads[nX,3] <> nId .AND. aThreads[nX,11] == cTipo+cFilAnt+AllTrim(cEstacao)+".L"+cEmpAnt
				KillUser( aThreads[nX,1], aThreads[nX,2], aThreads[nX,3] )  
				Sleep( 5000 )
			EndIf    
		Next nX
	Else
		Return(.F.)
	EndIf		
EndIf

FrtGeraSLI( cEstacao, "CON", "|||||", "SOBREPOE" )
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FRTSemaSta� Autor � Cesar Eduardo Valadao � Data �28/06/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica o Status de um Semaforo em Arquivo.               ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAFRT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FRTSemaStat(cTipo, cEstacao)
Local nHandle
If __lFirst
	MakeDir("\SEMAFORO\SIGAFRT\")
	__lFirst := .F.
EndIf
nHandle := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cTipo+cFilAnt+cEstacao," ","")+".L"+StrTran(cEmpAnt," ",""))
IF nHandle < 0
	Return(.T.)
Endif        
FClose(nHandle)
Return(.F.)
