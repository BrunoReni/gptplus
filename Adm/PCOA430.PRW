#INCLUDE "PCOA430.ch"
#INCLUDE "PROTHEUS.CH"

/*                        
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOA430  � AUTOR � Jo�o Gon�alves Oliveira � DATA � 06.11.2007 ���
�����������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa para cadastramento de regras de receitas relacionadas ���
�����������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                        ���
�����������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOA430                                                        ���
���_DESCRI_  � Programa para cadastramento de receitas relacionadas           ���
���_FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal      ���
���          � partir do Menu ou a partir de uma funcao pulando assim o       ���
���          � browse principal e executando a chamada direta da rotina       ���
���          � selecionada.                                                   ���
���          � Exemplo: PCOA430(2) - Executa a chamada da funcao de visua-    ���
���          �                        zacao da rotina.                        ���
�����������������������������������������������������������������������������Ĵ��
���_PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse                 ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function PCOA430(nCallOpcx,lAuto,aCposVs,aRecnos,lProc)
Local lRet      := .T.
Local xOldInt
Local lOldAuto
Local cFiltro

Default lAuto := .F.
Default lProc := .F.

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif
EndIf

Private aCposVisual	:= aCposVs
Private cCadastro	:= STR0001 //"Manuten��o de Regras de Receitas Relacionadas"
Private aRotina := MenuDef()

dbSelectArea("ALR")
dbSetOrder(1)
If nCallOpcx <> Nil
	lRet := A430DLG("ALR",ALR->(RecNo()),nCallOpcx,lAuto,aRecnos,lProc)

Else
	cFiltro	:= PcoFilConf("ALR")
	
	If !Empty(cFiltro)
		MBrowse(6,1,22,75,"ALR",,,,,,,,,,,,,,cFiltro)
	EndIf
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt
Return lRet

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �A430DLG   �Autor  �Jo�o Gon�alves Oliveira � Data � 07.11.2007  ���
�����������������������������������������������������������������������������͹��
���Desc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visualiza��o ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � Protheus10                                                     ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/

Function A430DLG(cAlias,nRecnoALR,nCallOpcx,lAuto,aRecnos,lProc)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}
Local aUsButtons := {}
Local oEnchALR

Local aHeadALN
Local aColsALN
Local nLenALR   := 0  // Numero de campos em uso no ALR
Local nLinALN   := 0  // Linha atual do acols
Local aRecALN   := {} // Recnos dos registros
Local nGetD
Local cRegra
Local aCposEnch,aCposNot
Local aCposAuto 
Local aUsField
Local aAreaALR := ALR->(GetArea()) // Salva Area do ALR 
Local aAreaALN := ALN->(GetArea()) // Salva Area do ALN
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local nPosRelac
Local nPosIDRef
Local nPosIdent
Local nPosUM
Local lOk := .F.
Local nX
Local aId_ALN, nPos_Id, nRegAux

If ValType(lAuto) != "L"
	lAuto := .F.
EndIf

Private INCLUI  := (nCallOpcx == 3 .or. nCallOpcx == 6)
Private oGdALN
PRIVATE aTELA[0][0],aGETS[0]

If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif
EndIf

If lAuto .And. !(nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .F.
EndIf

If nCallOpcx == 4
	If aRecnos != NIL .And. ! Empty(aRecnos)
		nRegAux := ALN->(Recno())
		aId_ALN := {}
		For nX := 1 TO Len(aRecnos)
			dbSelectArea("ALN")
			dbGoto(aRecnos[nX])
			If (nPos_Id	:=	ASCAN(aId_ALN, {|x| x[1] == ALN->ALN_ID}))==0
				aAdd(aId_ALN, {ALN->ALN_ID,{aRecnos[nX]}})
			Else
				AAdd(aId_ALN[nPos_Id][2],aRecnos[nX])
			EndIf
		Next
		dbGoto(nRegAux)
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 480,650 PIXEL //"Manuten��o das Regras de Rateio"
	oDlg:lMaximized := .T.
EndIf

aCposAuto := {} 

aCposEnch := {}
aCposNot	:= {}

// Carrega dados do ALR para memoria
RegToMemory("ALR",INCLUI)
//M->ALR_CODIGO := IIf(nCallOpcx == 6,GetSXENum("ALR","ALR_CODIGO"),M->ALR_CODIGO)

If nCallOpcx == 3 .or. nCallOpcx == 6

	If !Empty(MV_PAR02)
		M->ALR_TPCOD	:= MV_PAR02
	Endif
	
	If !Empty(MV_PAR03)
		M->ALR_VARCOD	:= MV_PAR03
	Endif

EndIf

If !lAuto
	//������������������������������������������������������������������������Ŀ
	//� Enchoice com os dados do cabe�alho                                     �
	//��������������������������������������������������������������������������
	
	If (nCallOpcx <> 3 .AND. nCallOpcx <> 6) .AND. ALR->(FieldPos("ALR_CFGPLN"))>0
		If Empty(ALR->ALR_CFGPLN)
			aCposNot	:= {"ALR_CFGPLN","ALR_TPCOD","ALR_VARCOD"}
		Endif
		aEval(GetAheader("ALR",,aCposNot), {|x| aAdd(aCposEnch , x[2] )})

   		oEnchALR := MSMGet():New('ALR',,nCallOpcx,,,,aCposEnch,{0,0,46,23},,,,,,oDlg,,,,,,,,,)
	Else
		oEnchALR := MSMGet():New('ALR',,nCallOpcx,,,,/*aCposEnch*/,{0,0,46,23},,,,,,oDlg,,,,,,,,,)
	EndIf
	oEnchALR:oBox:Align := CONTROL_ALIGN_TOP
EndIf

//������������������������������������������������������������������������Ŀ
//� Montagem do aHeader do ALN                                             �
//��������������������������������������������������������������������������
aHeadALN := GetaHeader("ALN",,{"ALN_CODIGO"},,aCposVisual, .T. /*lWalk_Thru*/)

aEnchAuto := GetaHeader("ALR")
nLenALN  := Len(aHeadALN) + 1


nPosRelac 	:= AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_PROIND"})
nPosIDRef 	:= AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_IDREF"})
nPosIdent 	:= AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_IDENT"})
nPosUM    	:= AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_UM"})

nPos_ALI_WT := AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_ALI_WT"})
nPos_REC_WT := AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_REC_WT"})

If nPosIDRef > 0
	aHeadALN[nPosIDRef][4] := 0
EndIf

If nPosRelac > 0

	DbSelectArea("AMC")
	DbSetOrder(1)
	DbSeek(xFilial("AMC") + AMB->AMB_CODIGO + AM1->AM1_CODIGO + "ZZ" ,.T.)
	DbSkip(-1)
	
	If xFilial("AMC") + AMB->AMB_CODIGO + AM1->AM1_CODIGO == AMC->(AMC_FILIAL+AMC_CFGPLN+AMC_TPCOD)

		aHeadALN[nPosRelac,9] := AMC->AMC_SXB

	Endif
EndIf

//������������������������������������������������������������������������Ŀ
//� Montagem do aCols do ALN                                               �
//��������������������������������������������������������������������������

aColsALN := {}
DbSelectArea("ALN")
DbSetOrder(1)
DbSeek(xFilial("ALN")+ALR->ALR_CODIGO)

cRegra := ALN->ALN_FILIAL + ALN->ALN_CODIGO
While nCallOpcx != 3 .And. !Eof() .And. ALN->ALN_FILIAL + ALN->ALN_CODIGO == cRegra
	If aRecnos == Nil .Or. AScan(aRecnos,ALN->(Recno())) > 0
		AAdd(aColsALN,Array( nLenALN ))
		nLinALN++
		// Varre o aHeader para preencher o acols
		AEval(aHeadALN, {|x,y| aColsALN[nLinALN][y] := If(Alltrim(x[2])$"ALN_ALI_WT|ALN_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })	
		
		If nPosIdent > 0 .And. !Empty(ALN->ALN_IDREF)
			aAuxArea := GetArea()
			AK6->(dbSetOrder(1))
			AK6->(dbSeek(xFilial()+ALN->ALN_CLASSE))
			If ! Empty(AK6->AK6_VISUAL)
				dbSelectArea(Substr(ALN->ALN_IDREF,1,3))
				dbSetOrder(Val(Substr(ALN->ALN_IDREF,4,2)))
				dbSeek(Substr(ALN->ALN_IDREF,6,Len(ALN->ALN_IDREF)))
				aColsALN[nLinALN][nPosIdent] := &(ALN->ALN_VISUAL)
			EndIf
			RestArea(aAuxArea)
		EndIf
		If nPosUM > 0
			AK6->(dbSetOrder(1))
			AK6->(dbSeek(xFilial()+ALN->ALN_CLASSE))
			aAuxArea := GetArea()
			If !Empty(AK6->AK6_UM)
				If !Empty(ALN->ALN_IDREF)
					dbSelectArea(Substr(ALN->ALN_IDREF,1,3))
					dbSetOrder(Val(Substr(ALN->ALN_IDREF,4,2)))
					dbSeek(Substr(ALN->ALN_IDREF,6,Len(ALN->ALN_IDREF)))
				EndIf
				aColsALN[nLinALN][nPosUM] := &(AK6->AK6_UM)
			EndIf
			RestArea(aAuxArea)
		EndIf
		
		If nPos_ALI_WT > 0
			aColsALN[nLinALN][nPos_ALI_WT] := "ALN"
		EndIf
		
		If nPos_REC_WT > 0
			aColsALN[nLinALN][nPos_REC_WT] := ALN->(Recno())
		EndIf
		
		// Deleted
		aColsALN[nLinALN][nLenALN] := .F.
		AAdd( aRecALN, ALN->( Recno() ) )		
	Endif
	// Adiciona o Recno no aRec	
	ALN->(DbSkip())
EndDo

// Verifica se n�o foi criada nenhuma linha para o aCols
If Len(aColsALN) = 0
	AAdd(aColsALN,Array( nLenALN ))
	nLinALN++
	// Varre o aHeader para preencher o acols
	AEval(aHeadALN, {|x,y| aColsALN[nLinALN][y] := IIf(Upper(AllTrim(x[2])) == "ALN_ID", StrZero(1,Len(ALN->ALN_ID)),  If(!(x[2]$"ALN_ALI_WT|ALN_REC_WT"), CriaVar(AllTrim(x[2])), NIL) ) })
	
	If nPos_ALI_WT > 0
		aColsALN[nLinALN][nPos_ALI_WT] := "ALN"
	EndIf
	
	If nPos_REC_WT > 0
		aColsALN[nLinALN][nPos_REC_WT] := 0
	EndIf
	
	// Deleted
	aColsALN[nLinALN][nLenALN] := .F.
EndIf

If !lAuto
	//�����������������������������������������������Ŀ
	//� GetDados com as Regras                        �
	//�������������������������������������������������
	If nCallOpcx = 3 .Or. nCallOpcx = 4
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	oGdALN:= MsNewGetDados():New(0,0,100,100,nGetd,"ALNLinOK",,"+ALN_ID",,,9999,,,,oDlg,aHeadALN,aColsALN)
	oGdALN:AddAction("ALN_IDENT",{||PCOIdentF3("ALN")})
	oGdALN:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdALN:CARGO := AClone(aRecALN)
	
	aButtons := aClone(AddToExcel(aButtons,{{"ENCHOICE",,oEnchALR:aGets,oEnchALR:aTela},{"GETDADOS",,oGdALN:aHeader,oGdALN:aCols} } ))	
	If nCallOpcx != 3
		ALR->(RestArea(aAreaALR)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchALR:Refresh()
	EndIf
	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT (oGdALN:oBrowse:Refresh(),EnchoiceBar(oDlg,{|| Processa({|| lOk := A430Ok(nCallOpcx,oGdALN:Cargo,aEnchAuto,oGdALN:aCols,oGdALN:aHeader,.T., aId_ALN,nRecnoALR)},STR0015), If(lOk, oDlg:End(),NIL) },{|| lCancel := .T., oDlg:End() },,aButtons))//"Gravando regras..."
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdALN:oBrowse:Refresh(),EnchoiceBar(oDlg, ;
		{|| Processa( {|| lOk := A430Ok(nCallOpcx,oGdALN:Cargo,aEnchAuto,oGdALN:aCols,oGdALN:aHeader,.T., aId_ALN,nRecnoALR)},STR0015), If(lOk,oDlg:End(),NIL)},;
		{|| lCancel := .T., oDlg:End() },,aButtons) )//"Gravando regras..."
	EndIf
Else
	lCancel := !A430Ok(nCallOpcx,aRecALN,aEnchAuto,aColsALN,aHeadALN,lProc, aId_ALN,nRecnoALR)
EndIf

If __lSX8 .And. lCancel
	RollBackSX8()
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaALR) 
RestArea(aAreaALN)
Return !lCancel

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Programa  � A430Ok   �Autor  � Jo�o Gon�alves de Oliveira � Data �  09/11/07   ���
���������������������������������������������������������������������������������͹��
���Desc.     � Funcao do botao OK da enchoice bar, valida e faz o tratamento      ���
���          � das informacoes.                                                   ���
���������������������������������������������������������������������������������͹��
���Uso       � AP8                                                                ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Static Function A430Ok(nCallOpcx,aRecALN,aEnchAuto,aColsALN,aHeadALN,lProc,aId_ALN,nRecnoALR)
Local nI
Local nX
Local aAreaALR	:= ALR->(GetArea())
Local aAreaALN	:= ALN->(GetArea())
Local nPosItem  := AScan(aHeadALN,{|x| Upper(AllTrim(x[2])) == "ALN_ID"})
DEFAULT lProc	:=	.F.
If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If ! ExistChav('ALR',M->ALR_CODIGO)
		Return .F.
	Endif
Endif

If ! A430Vld(nCallOpcx,aRecALN,aEnchAuto,aColsALN,aHeadALN)
	Return .F.
EndIf

ALR->(DbSetOrder(1))
If lProc
	ProcRegua(Len(aColsALN))
Endif

If nCallOpcx = 3 .Or. nCallOpcx == 6 // Inclusao ou C�pia
	Reclock("ALR",.T.)
	// Grava Campos do Cabecalho
	For nX := 1 To Len(aEnchAuto)
		FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
	Next nX

	// Grava campos que nao estao disponiveis na tela
	Replace ALR_CFGPLN With AMB->AMB_CODIGO
	
	Replace ALR_FILIAL With xFilial()
	MsUnlock()				
	
	// Grava Regras
	For nI := 1 To Len(aColsALN)
		If lProc
			If nI == 1
				IncProc(STR0013)	// 'Atualizando regras...'
			Else
				IncProc()
			Endif
		Endif
		If aColsALN[nI][Len(aColsALN[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("ALN",.T.)
		EndIf
		
		// Varre o aHeader e grava com base no acols
		AEval(aHeadALN,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALN[nI][y])), ) })	
		
		// Grava campos que nao estao disponiveis na tela	
		Replace ALN_FILIAL With xFilial("ALN")			
		Replace ALN_CODIGO With ALR->ALR_CODIGO 	
		MsUnlock()			
	Next nI	
ElseIf nCallOpcx = 4 // Alteracao	
	// Grava Regras
	ALR->(dbGoTo(nRecnoALR))
	Reclock("ALR",.F.)
	// Grava Campos do Cabecalho
	For nX := 1 To Len(aEnchAuto)
		FieldPut(FieldPos(aEnchAuto[nX][2]),&( "M->" + aEnchAuto[nX][2] ))
	Next nX
		
	// Grava campos que nao estao disponiveis na tela
	Replace ALR_FILIAL With xFilial()
	MsUnlock()				
	
	For nI := 1 To Len(aColsALN) 
		If lProc
			If nI == 1
				IncProc(STR0013)	// 'Atualizando regras...'
			Else
				IncProc()
			Endif
		Endif
		If nI <= Len(aRecALN) .And. aRecALN[nI] > 0
			ALN->(DbGoto(aRecALN[nI]))
			Reclock("ALN",.F.)
		Else
			If aColsALN[nI][Len(aColsALN[nI])] // Verifica se a linha esta deletada
				Loop                   
			Else
				Reclock("ALN",.T.)
			EndIf
		EndIf
		
		If aColsALN[nI][Len(aColsALN[nI])] // Verifica se a linha esta deletada
			ALN->(DbDelete())
		Else			
			If aId_ALN != NIL
				nPos_Id	:=	ASCAN(aId_ALN, {|x| x[1] == aColsALN[nI, nPosItem]})
				
				If nPos_Id == 0 .And. nPosItem > 0					
					cId_Ant := aColsALN[nI, nPosItem]   //salva o Id atual
					cId_ALN := A430Id_Next_ALN()  // Gerar novo Id
					aAdd(aId_ALR, {cId_ALN, { 0 }})  // agregar ao array para os proximos
					
					//substituir todos os itens pelo novo codigo do item(ALN_ID)
					aColsALN[nI, nPosItem] := cId_ALN  //joga no acols novo Id
				EndIf
			EndIf
						
			// Varre o aHeader e grava com base no acols
			AEval(aHeadALN,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsALN[nI][y])), ) })			
		
			// Grava campos que nao estao disponiveis na tela			
			Replace ALN_FILIAL With xFilial("ALN")			
			Replace ALN_CODIGO With ALR->alr_codigo
			MsUnlock()			
		EndIf		
	Next nI
ElseIf nCallOpcx = 5 // Exclusao
	// Exclui Regra	
	ALR->(DbGoto(nRecnoALR))		
	Reclock("ALR",.F.)
	ALR->(DbDelete())
	MsUnLock()	
	
	For nI := 1 To Len(aColsALN)
		If lProc
			If nI == 1
				IncProc(STR0013)	// 'Atualizando regras...'
			Else
				IncProc()
			Endif
		Endif
		If nI <= Len(aRecALN) .And. aRecALN[nI] > 0
			ALN->(DbGoto(aRecALN[nI]))		
			Reclock("ALN",.F.)
			ALN->(DbDelete())
			MsUnLock()
		EndIf
	Next nI	
EndIf

ALR->(RestArea(aAreaALR))
ALN->(RestArea(aAreaALN))
If __lSX8
	ConfirmSX8()
EndIf
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A430Vld  �Autor  �Guilherme C. Leal   � Data �  11/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de validacao dos campos.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A430Vld(nCallOpcx,aRecALN,aEnchAuto,aColsALN,aHeadALN)
Local nI
If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 6)
	Return .T.
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"ALN_ALI_WT|ALN_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsALN)
	If ! aColsALN[nI,Len(aHeadALN)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(aHeadALN,{|x,y| if(Alltrim(x[2])$"ALN_ALI_WT|ALN_REC_WT", .F. , x[17] .And. Empty(aColsALN[nI][y])) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("ALN"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0008+ AllTrim(aHeadALN[nPosField][1])+CHR(10)+CHR(13)+STR0009+Str(nI,3,0),3,1) //"Campo: "###"Linha: "
			Return .F.
		EndIf
	EndIf
Next nI
Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PcoxGD1LinOK� Autor � Edson Maricate      � Data � 17-12-2003 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da LinOK da Getdados                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PCOXFUN                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ALNLinOK()
Local lRet			:= .T.
Local nPosOper		:= aScan(aHeader,{|x|AllTrim(x[2])=="ALN_OPER"})
Local nPosClasse	:= aScan(aHeader,{|x|AllTrim(x[2])=="ALN_CLASSE"})
Local nPosIDRef		:= aScan(aHeader,{|x|AllTrim(x[2])=="ALN_IDREF"})
Local nPosField

If !aCols[n][Len(aCols[n])]
	dbSelectArea("AK6")
	dbSetOrder(1)
	dbSeek(xFilial()+aCols[n][nPosClasse])
	
	If AK6->AK6_OBRIGA=="1" .And. Empty(aCols[n][nPosIDRef])
		HELP("  ",1,"PCONOCHAVE")
		lRet	:= .F.
	EndIf
	
	If lRet .And. AK6->AK6_OPER=="1" .And. Empty(aCols[n][nPosOper])
		HELP("  ",1,"PCONOOPER")
		lRet	:= .F.
	EndIf
	
	//������������������������������������������������������Ŀ
	//� Verifica os campos obrigatorios do SX3.              �
	//��������������������������������������������������������
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n)
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A430Id_Next_ALN�Autor  �Paulo Carnelossi � Data � 31/03/06  ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna Proximo ALN_ID para o lote em edicao                ���
���          �Utilizado quando usuario resolve colocar + 1 item na altera-���
���          �cao da regra quando o parametro MV_PCOVISL esta com         ���
���          �conteudo "2" (somente edita regras alteradas/Pcodetlan()    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A430Id_Next_ALN()
Local aArea := GetArea()
Local aAreaALN := ALN->(GetArea()) 
Local nItALN := 0

dbSelectArea("ALN")
dbSetOrder(1)
If dbSeek(xFilial("ALN")+M->ALR_CODIGO)
	While ALN->(!Eof().And.ALN_FILIAL+ALN_CODIGO == ;
		xFilial("ALN")+M->ALN_CODIGO)
		nItALN := VAL(ALN->ALN_ID)
		ALN->(dbSkip())
	End
EndIf

nItALN++
cItALN := StrZero(nItALN, Len(ALN->ALN_ID))

RestArea(aAreaALN)
RestArea(aArea)
Return(cItALN)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �17/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {{STR0002,"AxPesqui",0,1,,.F.},;    //"Pesquisar"
{ STR0003, "A430DLG"   ,0,2},; //"Visualizar"
{ STR0004, "A430DLG"   ,0,3},; //"Incluir"
{ STR0005, "A430DLG"   ,0,4},; //"Alterar"
{ STR0006, "A430DLG"   ,0,5},; //"Excluir"
{ STR0014, "A430DLG"   ,0,3}}  //"Copiar"

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario no aRotina                                  �
//��������������������������������������������������������������������������
If ExistBlock( "PCOA4301" )
	//P_E������������������������������������������������������������������������Ŀ
	//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
	//P_E� browse da tela de lan�amentos                                          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�               Ex. :  User Function PCOA4301                            �
	//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
	//P_E��������������������������������������������������������������������������
	If ValType( aUsRotina := ExecBlock( "PCOA4301", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A430VldCO � Autor � Gustavo Henrique  � Data �  20/01/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida se a conta orcamentaria selecionada para a          ���
���          � regra eh sintetica                                         ���
�������������������������������������������������������������������������͹��
���Parametros� EXPC1 - Codigo da conta orcamentaria                       ���
�������������������������������������������������������������������������͹��
���Uso       � X3_VALID do campo ALR_CO                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A430VldCO( cCO )
Local lRet		:= .T.
Local aAreaAK5	:= AK5->( GetArea() )

AK5->( dbSetOrder( 1 ) )
AK5->( dbSeek( xFilial("AK5") + cCO ) )

lRet := (AK5->AK5_TIPO == "2")

If ! lRet
	Aviso( STR0011, STR0012, {"Ok"} )		// "Aten��o" ### "Informe uma conta orcament�ria anal�tica."
EndIf
                                          	
RestArea( aAreaAK5 )
Return lRet