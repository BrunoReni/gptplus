#Include "PROTHEUS.CH"
#INCLUDE "QIER350.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QIER350  � Autor � Leandro S. Sabino     � Data � 19.04.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Relatorio de Amarracao Produto x Fornecedor			      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIER350(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIE                                                        ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���			  	 �		  �		 � 									      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIER350()
Local cPerg		 := "QIE350    "
Local lRet 		 := .F.

Private cFimSA5  := ""
Private cFimPara := ""
Private aNiv	 := {}
Private aSituac  := {}
Private aSitSel	 := {}

//��������������������������������Ŀ
//� Parametros utilizados          �
//� mv_par01 - Fornecedor de       �
//� mv_par02 - Fornecedor ate      �
//| mv_par03 - Produto de          |
//| mv_par04 - Produto ate         |
//� mv_par05 - Loja de             �
//� mv_par06 - Loja ate            �
//� mv_par07 - Listar              �
//| mv_par08 - Situacao 	       |
//| mv_par09 - Idioma              |
//����������������������������������

If Pergunte(cPerg, .T. )
	
	dbSelectArea("QA3")
	dbSetOrder(1)
	

	IF MV_PAR07 = 1 // FORNECEDOR
		dbSelectArea("SA5")
		SA5->(dbSetOrder(1))  //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO     
//		If dbSeek(xFilial("SA5")+mv_par01+mv_par05+mv_par03,.T.)
		dbSeek(xFilial("SA5")+mv_par01+mv_par05,.T.) 
		while !SA5->(EOF())
			If SA5->A5_FORNECE+SA5->A5_LOJA >= mv_par01+mv_par05 .and. SA5->A5_FORNECE+SA5->A5_LOJA <= mv_par02+mv_par06
				lRet := .T.
				Exit
			Endif
			SA5->(DbSkip())
		EndDo
		cFimSA5 := "SA5->A5_FILIAL+SA5->A5_FORNECE+SA5->A5_LOJA"
		cFimPara := xFilial("SA5")+mv_par02+mv_par06
	Else
		dbSelectArea("SA5")
		SA5->(dbSetOrder(2))
//		If dbSeek(xFilial("SA5")+mv_par03+mv_par01+MV_PAR05,.T.)
		dbSeek(xFilial("SA5")+mv_par03,.T.)		   
		while !SA5->(EOF())
			If SA5->A5_PRODUTO >= mv_par03 .and. SA5->A5_PRODUTO <= mv_par04
				lRet := .T.
				Exit
			Endif
			SA5->(DbSkip())
		EndDo
		cFimSA5 := "SA5->A5_FILIAL+SA5->A5_PRODUTO"
		cFimPara := xFilial("SA5")+mv_par04
	Endif
	
	If lRet
		MsgRun(STR0014,"",{|| CursorWait(), FQER350MontaRel() ,CursorArrow()}) //"Gerando Visualizacao, Aguarde..."
	Else
		Help(" ",1,"QA_NAOIMP") //Nao existem dados para essa pesquisa.
	Endif
	
Else
	Return (.F.)
Endif

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FQER350MontaRel� Autor � Leandro Sabino   � Data � 27.02.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Exibe os campos do relatorio                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FQER350MontaRel(ExpO1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER350                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FQER350MontaRel()
Local lin, x
Local aTxtJust 	:= ""
Local nAnt
Private oPrint
Private i := 1
Private oFontCou08
oFontCou08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)

oPrint := TMSPrinter():New(STR0013)// 'Situacao do Fornecedor - Produto x Fornecedores'
oPrint:SetLandscape(.T.)

FQER350Cab(oPrint,i)

lin := 300

While SA5->(!Eof()) .And. &(cFimSA5) <= cFimPara
	
	//Filtrando por FORNECEDOR ou Produto
	IF mv_par07 = 1 .And. (SA5->A5_FORNECE+SA5->A5_LOJA < mv_par01+mv_par05) .Or. (SA5->A5_FORNECE > mv_par02)
		SA5->(DbSkip())
		Loop
	ElseIF mv_par07 = 2 .And. (SA5->A5_PRODUTO < mv_par03 .Or. SA5->A5_PRODUTO > mv_par04)
		SA5->(DbSkip())
		Loop
	Endif
	
	//Filtrando as Situacoes
	IF aScan(aSitSel,{|x| AllTrim(x[1]) = AllTrim(SA5->A5_SITU)}) == 0
		SA5->(DbSkip())
		Loop
	Endif
	
	If QA3->(dbSeek(xFilial("SA5")+"MATA060T"+SA5->A5_CHAVE,.T.))
		
		FQER350PulPag(@lin)
		
		oPrint:Say(lin,0040,SA5->A5_FORNECE,oFontCou08)
		oPrint:Say(lin,0170,SA5->A5_NOMEFOR,oFontCou08)
		oPrint:Say(lin,0900,SA5->A5_PRODUTO +" "+SA5->A5_NOMPROD,oFontCou08)//"Produto"
		
		If aScan(aNiv,{|x| AllTrim(x[3]) == AllTrim(QA3->QA3_ANT)}) > 0
			nAnt:=aSituac[aScan(aNiv,{|x| AllTrim(x[3]) == AllTrim(QA3->QA3_ANT)}),2]
			oPrint:Say(lin,1700,nAnt,oFontCou08)
		Endif

		If aScan(aNiv,{|x| AllTrim(x[3]) == AllTrim(SA5->A5_SITU)}) > 0		
			oPrint:Say(lin,2000,aSituac[aScan(aNiv,{|x| AllTrim(x[3]) == AllTrim(SA5->A5_SITU)}),2],oFontCou08)
			oPrint:Say(lin,2300,Dtoc(QA3->QA3_DATA),oFontCou08)
		Endif
		
		aTxtJust := JustificaTXT(QA3->QA3_TEXTO,035,.T.)
		
		For x := 1 to Len(aTxtJust)
			oPrint:Say(lin,2500,aTxtJust[x],oFontCou08)
			FQER350PulPag(@lin)
		Next
		
		FQER350PulPag(@lin)
	Endif
	
	SA5->(DbSkip())
Enddo

oPrint:Preview()

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FQER350Cab� Autor � Leandro de S. Sabino  � Data � 27.01.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta o cabecalho do relatorio    						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FQER350Cab(ExpO1,ExpN1)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER350                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FQER350Cab(oPrint,i)
Local oFont16, oFont08, oFont10

oFont16		:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)

oPrint:StartPage()
oPrint:Say(050,0900,OemToAnsi(STR0013),oFont16)//'Situacao do Fornecedor - Produto x Fornecedores'

oPrint:Line( 0300, 0030, 0300, 3050 )

oPrint:Say(240,0040,STR0006,oFont08)//"Fornecedor"

oPrint:Say(240,0900,STR0018,oFont08)//"Produto"

oPrint:Say(200,1840,STR0007,oFont08)//"Situacao"
oPrint:Say(240,1700,STR0008,oFont08)//"Anterior"
oPrint:Say(240,2000,STR0009,oFont08)//"Atual"

oPrint:Say(200,2315,STR0010,oFont08)//"Data"
oPrint:Say(240,2300,STR0011,oFont08)//"Alteracao"

oPrint:Say(240,2500,STR0012,oFont08)//"Justificativa para alteracao"

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FQER350PulPag� Autor � Leandro de S. S.   � Data � 27.02.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicia uma nova pagina                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FQER350PulPag(lin,oPrint,i)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lin = linha atual do relatorio                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER350                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FQER350PulPag(lin)
lin += 20
If lin > 2200
	oPrint:EndPage()
	FQER350Cab(oPrint,i)
	lin := 300
Endif
Return nil


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FQER350Sel� Autor � Leandro S. Sabino     � Data � 15/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Selecionar os parametros do relatorio                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FQER350Sel                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �QIER350                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function FQER350Sel()
Local oDlg
Local oListbox
Local oOk    := LoaDbitmap( GetResources(), "LBOK" )
Local oNo    := LoaDbitmap( GetResources(), "LBNO" )
Local cMvpar := &(ReadVar()) // Carrega Nome da Variavel do Get em Questao
Local cMvret := ReadVar() // Igual a Nome da Variavel ao Nome variavel de Retorno
Local nOpcao := 0
Local cAlias := Alias()
Local nFor
Local cSel   := ""
Local aSi
Local nX
Local lNiv
Local lEntrou := .F.

If len (aNiv)==0
	Aadd(aNiv,{If("O  " $ cMvpar,.T.,.F.),OemToAnsi(STR0016),"O  "}) //"Todos"
	
	dbSelectArea("QEG")
	dbSetOrder(1)
	dbSeek(xFilial("QEG"))
	AADD(aSituac,{STR0016,"O"})//"Todos"
	While QEG->(!EOF()) .and. QEG->QEG_FILIAL == xFilial("QEG")
		If mv_par09 = 1 // Portugues
			AADD(aSituac,{QEG_SITU,QEG_NIVEL})
		ElseIf mv_par09 = 2 // Ingles
			AADD(aSituac,{QEG_SITU,QEG_NIVING})
		Else			// Espanhol
			AADD(aSituac,{QEG_SITU,QEG_NIVESP})
		Endif
		QEG->(dbSkip())
	EndDo
	
	aSi := FWGetSX5("SI")
	If !Empty(aSi)
		//Busca da tabela SX5
		For nX := 1 to Len(aSi)
			If aSi[nX][1] == xFilial("SX5") .And. !Empty(aSi[nX][3])
				If Substr(aSi[nX][3],1,3) $ cMvpar
					lNiv := .T.
				Else
					lNiv := .F.
				Endif
				Aadd(aNiv,{lNiv,Alltrim(aSi[nX][4]),Substr(aSi[nX][3],1,3)})
				lEntrou := .T.
			Endif
		Next nX
	EndIf
	FreeObj(aSi)
	
	If !lEntrou
		//Caso a tabela SI nao exista ele carrega manualmente
		AADD(aNiv,{If("A  "$cMvpar,.T.,.F.),OemToAnsi(STR0002),"A  "}) //"Assegurado"
		AADD(aNiv,{If("B  "$cMvpar,.T.,.F.),OemToAnsi(STR0003),"B  "}) //"Qualificado"
		AADD(aNiv,{If("C  "$cMvpar,.T.,.F.),OemToAnsi(STR0004),"C  "}) //"Pre-Qualificado"
		AADD(aNiv,{If("D  "$cMvpar,.T.,.F.),OemToAnsi(STR0005),"D  "}) //"N/Habilitado"
	EndIf
Endif

nLin1 := 0.5
nCol1 := 002

DEFINE MSDIALOG oDlg FROM 005,005 TO 016,050 TITLE OemToAnsi(STR0017)//"Escolha Padr�o"

@ nLin1,nCol1 LISTBOX oListBox NOSCROLL ;
FIELDS HEADER " ",OemToAnsi(STR0015) ; //"Situacao do Fornecedor"
SIZE 150,057;
ON DbLCLICK FQER350Sit(@oListBox,@aNiv)

oListBox:SetArray(aNiv)
oListBox:bLine := { || {If(aNiv[oListBox:nAt,1],oOk,oNo),aNiv[oListBox:nAt,2]}}

DEFINE SBUTTON FROM 065,112   TYPE 1 ACTION (nOpcao:= 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 065,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

If nOpcao == 1
	cMvpar:= ""
	For nFor := 1 TO Len(aNiv)
		cSel:= If(aNiv[nFor,1],aNiv[nFor,3],"*")
		cMvpar += cSel
		AADD(aSitSel,{cSel})
	Next nFor
EndIf

&cMvRet := cMvpar // Devolve Resultado

DbSelectArea(cAlias) // Retorna Alias

Return .T.


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FQER350Sit    � Autor �Leandro S. Sabino  � Data � 15/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tratar o click da pergunte                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �FQER350Sit                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQIE                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function FQER350Sit(oListBox,aNiv)
Local nI:= 0

aNiv[oListBox:nat,1]:= !aNiv[oListBox:nat,1]

If oListBox:nAt == 1	 // Todos
	For nI:= 2 To Len(aNiv)
		aNiv[nI,1] := aNiv[1,1]
	Next nI
Else
	If !aNiv[oListBox:nat,1]
		aNiv[1,1]:= .F.
	EndIf
EndIf
oListBox:Refresh()

Return