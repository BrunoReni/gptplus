#Include "Mata026.ch"
#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Mata026   �Autor  �Juliana Taveira     � Data �  29/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro Amarracao Ficha X Cod Lancamento Cat83             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Mata026()
Local lRet := .T.

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0001)

mBrowse( 6, 1,22,75,"CCU")

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA026   �Autor  �Juliana Taveira     � Data �  29/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Menu funcional da rotina                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Private aRotina := {	{STR0002,"AxPesqui"	,0,1,0,.F.},;		// "Pesquisar"
{STR0003,"A026Visual",0,2,0,NIL},;		// "Visualizar"
{STR0004,"A026Inclui",0,3,0,NIL},;		// "Incluir"
{STR0005,"A026Altera",0,4,0,NIL},;		// "Alterar"
{STR0006,"A026Deleta",0,5,0,NIL} }		// "Excluir"                                         
Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A026Visual� Autor � Juliana Taveira	    � Data � 29/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizacao Amarracao Ficha X Cod Lancamento Cat83        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AP		                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A026Visual(cAlias,nReg,nOpcx)
Local nSavRec
Local nOpca     := 0, oDlg, oGet, cVarTmp
Local cSeek     := ""
Local cWhile    := ""
Local aNoFields := {"CCU_FICHA","CCU_DESCFC"}

Private cFicha1 := CriaVar("CCU_FICHA"), cFilialEnt:= CCU_FILIAL
Private cfilial := xfilial("CCU")
Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols := {}

//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea(cAlias)
If LastRec() == 0
	Return .T.
Endif

//�������������������������������������������������������Ŀ
//� Montagem do aHeader e aCols                           �
//���������������������������������������������������������
cFicha1 := CCU_FICHA
nSavRec := RecNo()
cSeek	:= cFilial+cFicha1
cWhile	:= "CCU_FILIAL+CCU_FICHA"
FillGetDados(nOPcx,cAlias,1,cSeek,{|| &cWhile },{|| .T. },aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)

DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To 44,128 OF oMainWnd

@ 2.4,.8  SAY OemToAnsi(STR0007) 		//"Ficha: "
@ 2.4,3   SAY OemToAnsi(cFicha1)
SX5->(dbSeek(cFilial+"SS"+cFicha1))
@ 2.4,5   SAY OemToAnsi(Substr(X5Descri(),1,47))
oGet := MSGetDados():New(42,5,275,502,nOpcx,,,,.F.,/**/,/**/,/**/,999)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})

dbSelectArea(cAlias)
dbGoTo( nSavRec )
Return nOpca

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A026Inclui� Autor � Juliana Taveira	    � Data � 29/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inclusao Amarracao Ficha X Cod Lancamento Cat83             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AP		                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A026Inclui(cAlias,nReg,nOpcx)
Local nSavReg, oDlg, oGet, nOpca:=0
Local aNoFields := {"CCU_FICHA","CCU_DESCFC"}

Private aTELA[0][0],aGETS[0],aHeader[0],cFicha1:=CriaVar("CCU_FICHA")

//��������������������������������������������������������������Ŀ
//� Tabelas a serem utilizadas                                   �
//����������������������������������������������������������������
dbSelectArea("CCU")
dbSetOrder(1)            

dbSelectArea("CDZ")
dbSetOrder(1)            

dbSelectArea("SX2")
dbSeek(cAlias)
//�������������������������������������������������������Ŀ
//� Montagem do aHeader e aCols                           �
//���������������������������������������������������������
FillGetDados(nOPcx,cAlias,1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.)

nOpca := 0
DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To 44,128 OF oMainWnd
//������������������������������������������������������Ŀ
//� Aceita o cabecalho.                                  �
//��������������������������������������������������������
@ 2.4 ,.8  SAY OemToAnsi(STR0007) 		//"Ficha: "
@ 2.4,3 MSGET cFicha1 F3 "SS" Valid A026Ficha(cFicha1)
SX5->(dbSeek(cFilial+"SS"+cFicha1))
@ 2.4,7   SAY OemToAnsi(Substr(X5Descri(),1,47))
oGet := MSGetDados():New(42,5,275,502,nOpcx,"a026LinOk","a026TudOk",,.T.,/**/,/**/,/**/,999)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

IF nOpcA == 1
	Begin Transaction
	A026Grava(cAlias)
	//Processa Gatilhos
	EvalTrigger()
	End Transaction
Endif

//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
dbSelectArea(cAlias)
Return nOpca

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A026Altera� Autor � Juliana Taveira	    � Data � 29/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Alteracao Amarracao Ficha X Cod Lancamento Cat83            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AP		                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A026Altera(cAlias,nReg,nOpcx)
Local nSavRec,nRegCCU
Local nOpca 	:= 0, oDlg, oGet, cVarTmp
Local cSeek 	:= ""
Local cWhile   	:= ""
Local aNoFields := {"CCU_FICHA","CCU_DESCFC"}

Private cFicha1 := CriaVar("CCU_FICHA"), cFilialEnt:= CCU_FILIAL
Private cfilial := xfilial('CCU')
Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols := {}

//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea(cAlias)
If LastRec() == 0
	Return .T.
Endif

cFicha1 := CCU_FICHA
nSavRec := RecNo()

dbSetOrder(1)
dbSeek(cFilial+cFicha1 )
nRegCCU := Recno()

//�������������������������������������������������������Ŀ
//� Montagem do aHeader e aCols                           �
//���������������������������������������������������������
cSeek		:= cFilial+cFicha1
cWhile		:= "CCU_FILIAL+CCU_FICHA"
FillGetDados(nOPcx,cAlias,1,cSeek,{|| &cWhile },{|| .T. },aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)

DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To 44,128 OF oMainWnd
//������������������������������������������������������Ŀ
//� Aceita o cabecalho.                                  �
//��������������������������������������������������������
@ 2.4,.8  SAY OemToAnsi(STR0007) 		//"Ficha: "
@ 2.4,3   Say OemToAnsi(cFicha1)
SX5->(dbSeek(cFilial+"SS"+cFicha1))
oGet := MSGetDados():New(42,5,275,502,nOpcx,"a026LinOk","a026TudOk",,.T.,/**/,/**/,/**/,999)
dbSelectArea(cAlias)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
If nOpcA == 1
	Begin Transaction
	A026Grava(cAlias)
	//Processa Gatilhos
	EvalTrigger()
	End Transaction
Else
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbGoTo(nRegCCU)
	While !EOF() .And. CCU_FILIAL+CCU_FICHA == cFilial+cFicha1
		If CCU_FILIAL != cFilialEnt
			dbSkip()
			Loop
		EndIf
		MsUnLock()
		dbSkip()
	End
Endif

dbSelectArea(cAlias)
dbGoTo(nSavRec)
Return nOpca

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A026Deleta� Autor � Juliana Taveira	    � Data � 29/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclusao Amarracao Ficha X Cod Lancamento Cat83            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AP		                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Function A026Deleta(cAlias,nReg,nOpcx)
Local nCnt		:= 1
Local nSavRec	:= 1
Local nCntItem  := 1
Local nOpca 	:= 0 
Local nX 		:= 0            
Local cFicha1	:= CriaVar("CCU_FICHA"),cFilialEnt:= CCU_FILIAL,cfilial:=xfilial('CCU')
Local cSeek 	:= ""
Local cWhile 	:= ""
Local cCodLan 	:= ""  
Local cVarTmp
Local aAC 		:= { "Abandona","Confirma" }
Local aNoFields := {"CCU_FICHA","CCU_DESCFC"}
Local oDlg, oGet 


Private aCols   := {}
Private aTELA[0][0],aGETS[0],aHeader[0],nOpc:=3

//��������������������������������������������������������������Ŀ
//� Verifica se existe algum dado no arquivo                     �
//����������������������������������������������������������������
dbSelectArea(cAlias)
If LastRec() == 0
	Return .T.
Endif

//�������������������������������������������������������Ŀ
//� Montagem do aHeader e aCols                           �
//���������������������������������������������������������
cFicha1 := CCU_FICHA
nSavRec := RecNo()
cSeek		:= cFilial+cFicha1
cWhile	:= "CCU_FILIAL+CCU_FICHA"
FillGetDados(nOPcx,cAlias,1,cSeek,{|| &cWhile },{|| .T. },aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)

dbSelectArea("SX5")
dbSeek(cFilial+"SS"+cFicha1)
DEFINE MSDIALOG oDlg TITLE cCadastro From 7,0 To 44,128 OF oMainWnd
//������������������������������������������������������Ŀ
//� Aceita o cabecalho.                                  �
//��������������������������������������������������������
@ 2.4,.8  SAY OemToAnsi(STR0007) 		//"Ficha: "
@ 2.4,3   Say OemToAnsi(cFicha1)
SX5->(dbSeek(cFilial+"SS"+cFicha1))
@ 2.4,5   SAY OemToAnsi(SUBSTR(X5Descri(),1,40))
oGet := MSGetDados():New(42,5,275,502,nOpcx,"a026LinOk","a026TudOk","",.F.,/**/,/**/,/**/,999)
dbSelectArea(cAlias)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=2,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})

If nOpcA == 2
	dbSelectArea(cAlias)
	nCnt := 0
	For nx = 1 to Len(aCols)
		cCodLan:= aCols[nx,Ascan(aHeader,{|x|Alltrim(x[2])=="CCU_CODLAN"})] 
		dbSeek(xFilial()+cFicha1+cCodLan)
		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnLock()
		nCnt++
	Next nx
Else
	dbSelectArea(cAlias)
	dbGoTo( nSavRec )
Endif

//��������������������������������������������������������������Ŀ
//� Restaura a integridade da janela                             �
//����������������������������������������������������������������
dbSelectArea(cAlias)
Return nOpca                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A026Grava �Autor  �Juliana Taveira     � Data �  01/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Grava os movimentos digitados                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A026Grava(cAlias)
Local nx ,ny ,nMaxArray , n, aAnterior := {},nCntDel := 0
LOCAL cfilial := xfilial("CCU")
Local cVar := ""

dbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� verifica se o ultimo elemento do array esta em branco        �
//����������������������������������������������������������������
nMaxArray := Len(aCols)
For nx = 1 to Len(aHeader)
	If Empty(aCols[nMaxArray][nx]) .And. Trim(aHeader[nx][2]) == "CCU_CODLAN"
		nMaxArray--
		Exit
	Endif
Next nx

dbSeek(cFilial+cFicha1 )
If Found()
	While !EOF() .And. CCU_FILIAL+CCU_FICHA == cFilial+cFicha1
		AADD(aAnterior,{RecNo()})
		dbSkip()
	EndDo
Endif

For nx = 1 to nMaxArray
	If Len(aAnterior) >= nx
		If !Inclui
			Go aAnterior[nx,1]
		EndIf
		RecLock(cAlias,.F.)
	Else
		RecLock(cAlias,.T.)
	Endif
	
	//����������������������������������������������������������������Ŀ
	//� verifica se tem marcacao para apagar.                          �
	//������������������������������������������������������������������
	If aCols[nx][Len(aCols[nx])]
		RecLock("CCU",.F.,.T.)
		dbDelete()
		nCntDel++
	Else
		For n = 1 to len(acols)
			acols[n][1] := cfilial
		next n
		replace CCU_FICHA WITH cFicha1
		//����������������������������������������������������������Ŀ
		//� atualiza dados selecionados pelo cliente                 �
		//������������������������������������������������������������
		For ny = 1 to Len(aHeader)
			cVar := Trim(aHeader[ny][2])
			If aHeader[ny][10] # "V"
				Replace &cVar. With aCols[nx][ny]
			Endif
		Next ny
	Endif
Next nx
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A026LinOk �Autor  �Juliana Taveira     � Data �  01/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se a linha esta Ok                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A026LinOk(o)
Local lRet		:= .T.
Local nX		:= 0
Local nUsado    := Len(aHeader)
Local nPCodLan  := aScan(aHeader, {|x|AllTrim(x[2])=='CCU_CODLAN'})
Local cCodLan   := ""

If nPCodLan > 0
	cCodLan := aCols[n][nPCodLan]
EndIf

If Empty(cCodLan).And. !aCols[n][nUsado+1]
	Help(' ', 1, 'OBRIGAT')
	lRet := .F.
Else
	If lRet .And. !aCols[n][nUsado + 1]
		For nX := 1 To Len(aCols)
			If(nX != n .And. !aCols[nX][nUsado + 1])
				If !Empty(cCodLan)
					If aCols[nX][nPCodLan] == cCodLan
						Help(' ', 1, 'JAGRAVADO')
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �a026TudOk �Autor  �Juliana Taveira     � Data �  01/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se tudo ok                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a026TudOk(o)
Local lRet := .T.
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �a026Desc  �Autor  �Juliana Taveira     � Data �  01/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilha descricao do codigo de lancamento Cat83            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a026Desc()
Local lRet 		:= .T.
Local nPDscLan  := aScan(aHeader, {|x|AllTrim(x[2])=='CCU_DESCCL'})
Local cCdLan    := ""

If nPDscLan > 0
	cCdLan := M->CCU_CODLAN
	If !Empty(cCdLan)
		If CDZ->(DbSeek(xFilial("CDZ")+avKey(cCdLan,"CDZ_CODLAN")))
			aCols[n][nPDscLan] := CDZ->CDZ_DESCR
		EndIf
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A026Ficha �Autor  �Juliana Taveira     � Data �  01/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida codigo da ficha digitada no cabecalho da rotina     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A026Ficha(cFicha1)

dbSelectArea("CCU")
CCU->(dbSeek(xFilial("CCU")+cFicha1))
If !Eof()
	Help(" ",1,"JAGRAVADO")
	Return .F.
Endif

dbSelectArea("SX5")
SX5->(dbSeek(xFilial("SX5")+"SS"+cFicha1))
If Eof()
	Help(" ",1,"A026FICHA")
	Return .F.
Endif
Return()
