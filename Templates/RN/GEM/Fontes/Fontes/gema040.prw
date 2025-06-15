#Include "Protheus.ch"
#INCLUDE "GEMA040.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GEMA040  � Autor � Reynaldo Miyashita    � Data � 01.02.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Manutencao das Condicoes de venda                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � GEMA040                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GEMA040()
Local aArea := GetArea()

//������������������������������������������������������������������������Ŀ
//�Verifica as cores da MBrowse                                            �
//��������������������������������������������������������������������������
Private aCores  := {{"LIR_ATIVO =='2'","DISABLE",STR0001};
                   ,{"LIR_ATIVO =='1'","ENABLE" ,STR0002}} //"Inativa"###"Ativa"
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0009) //"Manutencao da Condi��es de Venda"

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//������������������������������������������������������������������������Ŀ
//�Endereca para a funcao MBrowse                                          �
//��������������������������������������������������������������������������
dbSelectArea("LIR")
LIR->(dbSetOrder(1)) // LIR_FILIAL+LIR_CODCND
MsSeek(xFilial("LIR"))
mBrowse(06,01,22,75,"LIR",,,,,,aCores)

//������������������������������������������������������������������������Ŀ
//�Restaura a Integridade da Rotina                                        �
//��������������������������������������������������������������������������
dbSelectArea("LIR")
LIR->(dbSetOrder(1)) // LIR_FILIAL+LIR_CODCND
dbClearFilter()

RestArea(aArea)

Return( .T. )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040Dlg � Autor � Reynaldo Miyashita    � Data � 01.02.2005 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Manutencao das condicoes de venda                   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �GMA040Dlg()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do Arquivo                                       ���
���          �ExpN2: Numero do Registro                                     ���
���          �ExpN3: Opcao do aRotina                                       ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA040Dlg(cAlias,nReg,nOpc)

Local lA040Inclui := .F.
Local lA040Visual := .F.
Local lA040Altera := .F.
Local lA040Exclui := .F.
Local lContinua   := .T.
Local lOk         := .F.

Local nBrwCol     := 0
Local nX          := 0
Local nY          := 0
Local nRecLIR     := 0
Local aRecLIS     := {}
Local aSize       := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aUsrButtons := {}
Local aArea       := GetArea()

Local oDlg 

Private aGets[0]
Private aTela[0][0]
Private oEnch 
Private oGD
Private aHeader   := {}
Private aCols     := {}

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
Do Case
	Case (aRotina[nOpc][4] == 2)
		lA040Visual := .T.
	Case (aRotina[nOpc][4] == 3)
		Inclui		:= .T.
		lA040Inclui	:= .T.
	Case (aRotina[nOpc][4] == 4)
		Altera		:= .T.
		lA040Altera	:= .T.
	Case (aRotina[nOpc][4] == 5)
		lA040Exclui	:= .T.
		lA040Visual	:= .T.
EndCase

// caso exista a rotina, sera incluido os botoes especificos.
If ExistBlock("GMA040BTN")
	If ValType( aUsrButtons := ExecBlock( "GMA040BTN",.F., .F. ) ) == "A"
		aEval( aUsrButtons, { |x| aAdd( aButtons, x ) } )
	EndIf
EndIf
	
RegToMemory( "LIR" ,lA040Inclui )

If lA040Inclui
	M->LIR_FILIAL := xFilial("LIR")
EndIf

aCampos	:= {}
dbSelectArea("SX3")
SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
dbSeek("LIR")
While !Eof() .and. SX3->X3_ARQUIVO == "LIR"
	IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
		aAdd(aCampos,AllTrim(SX3->X3_CAMPO))
	EndIf
	dbSkip()
End

//�����������������������������������������������������������Ŀ
//� Faz a montagem do aHeader                                 �
//�������������������������������������������������������������
dbSelectArea("SX3")
SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
dbSeek("LIS")
While !EOF() .And. (SX3->x3_arquivo == "LIS")
	IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
		AADD(aHeader,{ TRIM(x3titulo()) ,SX3->x3_campo   ,SX3->x3_picture ;
                      ,SX3->x3_tamanho  ,SX3->x3_decimal ,SX3->x3_valid   ;
                      ,SX3->x3_usado    ,SX3->x3_tipo    ,SX3->x3_arquivo ;
                      ,SX3->x3_context  })
	Endif
	dbSkip()
End

If !lA040Inclui
	If lA040Altera.Or.lA040Exclui
		If !SoftLock("LIR")
			lContinua := .F.
		Else
			nRecLIR := LIR->(RecNo())
		Endif
	EndIf
	//�����������������������������������������������������������Ŀ
	//� Faz a montagem do aCols                                   �
	//�������������������������������������������������������������
	dbSelectArea("LIS")
	LIS->(dbSetOrder(1)) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
	dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
	While !Eof() .And. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND.And.lContinua
		If lA040Altera.Or.lA040Exclui
			If !SoftLock("LIS")
				lContinua := .F.
			Else
				aAdd(aRecLIS,RecNo())
			Endif
		EndIf
		aAdd(aCols,Array(Len(aHeader)+1))
		For nY := 1 to Len(aHeader)
			If ( aHeader[ny][10] != "V")
				aCols[Len(aCols)][ny] := FieldGet(FieldPos(aHeader[ny][2]))
			Else
				aCols[Len(aCols)][ny] := CriaVar(aHeader[ny][2])
			EndIf
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Next nY
		dbSelectArea("LIS")
		dbSkip()
	End
EndIf

If Empty(aCols)
	//�����������������������������������������������������������Ŀ
	//� Faz a montagem de uma linha em branco no aCols            �
	//�������������������������������������������������������������
	aadd(aCols,Array(Len(aHeader)+1))
	For nY := 1 to Len(aHeader)
		If Trim(aHeader[nY][2]) == "LIS_ITEM"
			aCols[1][nY] := StrZero(1, TamSX3("LIS_ITEM")[1])
		Else
			aCols[1][nY] := CriaVar(aHeader[nY][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next nY
EndIf	


If lContinua
	dbSelectArea("LIS")
    RegToMemory("LIS")
	//������������������������������������������������������Ŀ
	//� Faz o calculo automatico de dimensoes de objetos     �
	//��������������������������������������������������������
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 200, 200, .T., .T. } )
	aSize   := MsAdvSize()
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

	oEnch := MsMGet():New("LIR",LIR->(RecNo()),nOpc,,,,,aPosObj[1],aCampos,3,,,,oDlg)
	oGD   := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"T_GMA040LOk","T_GMA040TOk(oGD)","+LIS_ITEM",.T.,,1,,300,,,,/*delete*/,oDlg)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf( A040VldDlg( aGets ,aTela ,oGD ) ;
								                           ,(lOk:=.T.,nOpc:=1,oDlg:End()) ,lOk:=.F. ) ;
								                    },{||(oDlg:End(),lOk:=.F.)},,aButtons)

	If lOk .AND. (lA040Inclui .Or. lA040Altera .Or. lA040Exclui)
	
		Begin Transaction
			GMA040Grava(lA040Altera,lA040Exclui,nRecLIR,aRecLIS)
		End Transaction
	Else
		RollBackSX8()
	EndIf
	
EndIf

RestArea( aArea )
	
Return( .T. )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A040VldDlg� Autor � Reynaldo Miyashita    � Data �23.07.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Enchoice e GetDados da dialog de condicao de venda  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �A040VldDlg()                                                  ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function A040VldDlg( aGets ,aTela ,oGD )
Local lOk       := .F.
Local nFldAtivo := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_ATIVO"})
Local nAtivo    := 0
Local nCount    := 0

	// valida os Get da tela
	If Obrigatorio(aGets,aTela)
		// valida as linhas do browse
		If t_GMA040TOk( oGD )
			//
			// verifica se todos os itens da condicao de venda estao inativo, devendo assim cancelar a tabela
			//
			For nCount := 1 To Len(aCols)
				If aCols[nCount][nFldAtivo] == "1"
					nAtivo++
				Endif
			Next nCount
            
            Do Case    
				// todos os itens da condicao de venda estao desativados 
				Case nAtivo == 0
					// E a Condicao de venda esta ativa
					If M->LIR_ATIVO == "1"
						Help(" ",1,"ERRCONDVEND",,STR0012 + CRLF + STR0013 ,1) // "A condi��o de venda est� ativa, mas " ### "todos os itens est�o inativos"
					Else
						lOk := .T.
					EndIf
				// foi informado pelo menos 1 item da condicao de venda com ativo
				Case nAtivo > 0
					lOk := .T.
			EndCase
			
		EndIf
	EndIf
	
Return( lOk )
  
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040Leg � Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a   ���
���          � para o BROWSE                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMA040Legen()                                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA040Legen(nReg)
Local uRetorno := .T.
Local aLegenda := {}

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	aEval(aCores,{|aCor| Aadd(aLegenda,{aCor[2],aCor[3]}) })

	BrwLegenda( cCadastro,STR0008, aLegenda)  //"Legenda"

Return uRetorno


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040Gra � Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava as informacoes datela para a tabela                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �GMA040Grava()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GMA040Grava(lAltera,lDeleta,nRecLIR ,aRecLIS)

Local aArea       := GetArea()
Local bCampo      := {|n| FieldName(n) }
Local nPosParcela := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_NUMPAR"})
Local nCntFor     := 0
Local nCntFor2    := 0
Local nX          := 0

If !lDeleta
	//�����������������������������������������������������Ŀ
	//� Grava arquivo LIR - Condicoes de venda              �
	//�������������������������������������������������������
	dbSelectArea("LIR")
	If lAltera
		LIR->(dbGoto(nRecLIR))
		RecLock("LIR",.F.)
	Else
		RecLock("LIR",.T.)
	EndIf           
	
	For nX := 1 TO FCount()
		LIR->(FieldPut(nX,M->&(EVAL(bCampo,nX))))
	Next nX
	
	If !lAltera
		ConfirmSX8()
	EndIf
	MsUnlock()
	nRecLIR := LIR->(RecNo())
	
	//�����������������������������������������������������Ŀ
	//� Grava arquivo LIS - Itens de condicao de venda      �
	//�������������������������������������������������������
	dbSelectArea("LIS")
	For nCntFor := 1 to Len(aCols)
		// se o item nao foi deletado
		If !aCols[nCntFor][Len(aHeader)+1]
			If !Empty(aCols[nCntFor][nPosParcela])
				If nCntFor <= Len(aRecLIS)
					dbGoto(aRecLIS[nCntFor])
					RecLock("LIS",.F.)
				Else
					RecLock("LIS",.T.)
				EndIf
				For nCntFor2 := 1 To Len(aHeader)
					If ( aHeader[nCntFor2][10] != "V" )
						LIS->(FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				LIS->LIS_FILIAL	:= xFilial("LIS")
				LIS->LIS_CODCND := LIR->LIR_CODCND
				MsUnlock()
			EndIf
		Else
			If nCntFor <= Len(aRecLIS)
				dbGoto(aRecLIS[nCntFor])
				RecLock("LIS",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next nCntFor

Else
	LIR->(dbGoto(nRecLIR))
	//�����������������������������������������������������Ŀ
	//� Exclui do arquivo LIS - Itens de condicao de venda  �
	//�������������������������������������������������������
	dbSelectArea("LIS")
	LIS->(dbSetOrder(1)) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
	MsSeek(xFilial("LIS")+LIR->LIR_CODCND)
	While !Eof() .And. xFilial("LIR")+LIR->LIR_CODCND==;
		LIS->LIS_FILIAL+LIS->LIS_CODCND
		RecLock("LIS",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
	
	//�����������������������������������������������������Ŀ
	//� Exclui do arquivo LIR - Itens de condicao de venda  �
	//�������������������������������������������������������
	dbSelectArea("LIR")
	RecLock("LIR",.F.,.T.)
	dbDelete()
	MsUnlock()
	
EndIf

RestArea( aArea )

Return( .T. )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040LOk � Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida linha do browse                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMA040LOk()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA040LOk()
Local lRet        := MaCheckCols(aHeader,aCols,n)
Local nPosCampo   := 0
Local nField      := 0
Local nTotCols    := 0
Local nCntCols    := 0
Local cCampo      := ""

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	nTotCols := len(aHeader)
	nCntCols := 1
	While nCntCols <= nTotCols
		// obtem o nome do campo da tabela utilizado no browse	
		cCampo := AllTrim(aHeader[nCntCols][2])

		// Coluna Tipo de Juros Price
		If cCampo == "LIS_TPPRIC"
			// busca pela coluna Tipo de Sistema
			nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_TPSIST"})
			If nField >0
				// Se for o Tipo de Sistema diferente do Tipo de Sistema "1 - Price"
				If aCols[n][nField] == "1"
					// valida a celula do browse
					lRet := t_GMA040Valid( cCampo )
				Else                                                 
					nField := aScan(aHeader,{|x|AllTrim(x[2])==cCampo})
					aCols[n][nField] := CriaVar(aHeader[nField][2])
				Endif
			EndIf
		EndIf
		
		// Coluna quantidade de parcelas de residuo
		If lRet .AND. cCampo == "LIS_PARRES"
			nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_RESID"})
			If nField >0 
				// se tiver residuo
				IF aCols[n][nField] == "1"
					// valida a celula do browse
					lRet := t_GMA040Valid( cCampo )
				Else                               
					// limpa a celula
					nField := aScan(aHeader,{|x|AllTrim(x[2])==cCampo})
					aCols[n][nField] := CriaVar(aHeader[nField][2])
				EndIf
			EndIf
		EndIf	
		
		If lRet 
			// valida os outros campos
			lRet := t_GMA040Valid( cCampo )
		EndIf
		
		nCntCols++
		If !lRet
			Exit
		EndIf
	End	
Return( lRet )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040TOk � Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o browse                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMA040TudOk()                                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA040TOk( oGD )
Local nx    := 0
Local nSavN	:= n
Local lRet	:= .T.

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

For nx := 1 to Len(aCols)
	n	:= nx
	If !t_GMA040LOk()
		lRet := .F.
		Exit
	EndIf
Next
	
n := nSavN
oGD:oBrowse:Refresh()

Return lRet


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040When� Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Permite ou nao a edicao da coluna no browse                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMA040When()                                                ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA040When()

Local cCampo  := ReadVar()
Local nField  := 0 
Local lRet    := .T.   
Local nPos    := 0

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	If n <> NIL .AND. aHeader<>NIL .AND. aCols<>NIL  
		nPos    := n                                 
		// se a Linha de dados estiver ativa
		If !aCols[nPos][Len(aCols[nPos])] 
			// se o campo for tipo da price(begin/end) ou data de inicio da price
			If cCampo == "M->LIS_TPPRIC" 
				nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_TPSIST"})
				// o Tipo de sistema(LIS_TPSIST) nao for a Price ("1")
				If nField > 0 .AND. aCols[nPos][nField] != "1"
					lRet := .F.
				EndIf
			EndIf
			If lRet .AND. cCampo == "M->LIS_PARRES" 
				// se o campo for numero de parcelas de residuos
				If cCampo == "M->LIS_PARRES"
					nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_RESID"})
					// o Residuo(LIS_RESID) for NAO ("2")
					If nField > 0 .AND. aCols[nPos][nField] == "2"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return( lRet )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMA040Vali� Autor � Reynaldo Miyashita    � Data �02.05.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o das colunas do browse                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMA040Valid()                                               ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMA040Valid( cCampo )
Local nField := 0 
Local lRet   := .T.
Local nPos   := 0
Local uValor

DEFAULT cCampo  := ReadVar()

// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	If n <> NIL .AND. aHeader<>NIL .AND. aCols<>NIL

		nPos := n
		
		// se a Linha de dados estiver ativa
		If ! aCols[nPos][Len(aCols[nPos])] 
		
			// validacao na edicao do campo
			If left(cCampo,3)=="M->"
				uValor := &(cCampo) 
				
			// validacao na linha do browse
			Else
				nField := aScan(aHeader,{|x|AllTrim(x[2])==cCampo })
				If nField > 0 
					uValor := aCols[nPos][nField]
				EndIf
			EndIf
	
			// se o campo for tipo da price(begin/end) 
			If cCampo == "M->LIS_TPPRIC" .OR. cCampo == "LIS_TPPRIC"
				nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_TPSIST"})
				// o Tipo de sistema(LIS_TPSIST) nao for a Price ("1")
				If nField >0 .AND. aCols[nPos][nField] == "1"
					// se naum foi informado o tipo de price
					If Empty(uValor)
						Help(" ",1,"ERRCONDVEND",,STR0014,1) //"O Tipo de Price para o item nao foi informado."
						lRet := .F.
					EndIf
				EndIf
			// se o campo for quantidade de parcela de residuo
			ElseIf cCampo == "M->LIS_PARRES" .OR. cCampo == "LIS_PARRES"
				nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_RESID"})
				// Se tem parcela de res�duo
				If nField >0 .AND. aCols[nPos][nField] == "1"
					// se naum foi informado a quantidade de parcela residuo
					If uValor <= 0
						Help("",1,"GMA040003")
						lRet := .F.
					EndIf
				EndIf
			// se o campo for taxa anual 
			ElseIf cCampo == "M->LIS_TAXANO" .OR. cCampo == "LIS_TAXANO"
				nField := aScan(aHeader,{|x|AllTrim(x[2])=="LIS_TPSIST"})
				// o Tipo de sistema(LIS_TPSIST) nao for a Price ("1")
				If nField >0 .AND. aCols[nPos][nField] <> "4"
					// se naum foi informado o valor percentual da taxa anual de juros
					If uValor <= 0
						Help(" ",1,"ERRCONDVEND",,STR0015,1)  //"A Taxa de Juros Anual para o item nao foi informado."
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return( lRet )


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GMVldPerc | Autor � Reynaldo Miyashita    � Data �01.02.2005  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se os percentuais da montagem dos conjuntos nao       ���
���          � ultrapassa 100%                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �t_GMVldPerc()                                                 ���
���������������������������������������������������������������������������Ĵ��
���Uso       �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Template Function GMVldPerc()
Local lRet   := .T.
Local nX     := 0
Local nTotal := 0
Local nPos   := 0
                                   
// Valida se tem licen�as para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

nPos  := aScan(aHeader,{|x| Upper(Alltrim(x[2])) == "LIS_PERCLT"})

For nX := 1 to Len(aCols)                 
	If n == nX
		nTotal += M->LIS_PERCLT
	Else
		// se nao foi deletado.
		If ! aCols[nX][Len(aHeader)+1]
			nTotal += aCols[nX,nPos]
		EndIf
	Endif	   
Next nX

If nTotal > 100
	MsgAlert(STR0010) //"A soma dos percentuais das parcelas n�o pode ultrapassar de 100%"
	lRet := .F. 
Endif

Return( lRet )

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �05/12/06 ���
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
Private aRotina := {{ OemToAnsi(STR0003 ),"AxPesqui"      ,0,1,,.F.},; //"Pesquisar"
                    { OemToAnsi(STR0004) ,"T_GMA040Dlg"   ,0,2},; //"Visualizar"
                    { OemToAnsi(STR0005) ,"T_GMA040Dlg"   ,0,3},; //"Incluir"
                    { OemToAnsi(STR0006) ,"T_GMA040Dlg"   ,0,4},; //"Alterar"
                    { OemToAnsi(STR0007) ,"T_GMA040Dlg"   ,0,5},; //"Excluir"
                    { OemtoAnsi(STR0008) ,"T_GMA040Legen" ,0,6,,.F.} } //"Legenda"
Return(aRotina)                    
