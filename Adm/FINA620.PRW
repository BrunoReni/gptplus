#INCLUDE "fina620.ch" 
#include "PROTHEUS.CH"

Static lFWCodFil := .T.
Static lRetMBrow := .F.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Fina620  � Autor � Claudio D. de Souza   � Data � 26/02/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Incluir solicitacoes de transferencia de debito            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fina620()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION Fina620(aAuto,nPosArotina)

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

//Local lPanelFin := IsPanelFin()
Local lRet		:= .T.
Private aRotina := MenuDef()
Private lGestao := lFWCodFil .and. Len(SE6->E6_FILIAL) > 2 //se campo filial > 2 posicoes considera Gestao
Private lCompSA1Emp 
Private lCompSA1Uni
Private lCompSA1Fil
Private aFilValido
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private aRotAuto := aAuto
PRIVATE cCadastro:= STR0004 //"Solicita��o de transfer�ncia"

DEFAULT nPosArotina := 0

lRetMBrow := .F.

If nPosArotina > 0
	dbSelectArea('SE1')
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	lRet := Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"SE1",,,,,,Fa620Leg())
Endif	
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa620Inc � Autor � Claudio D. de Souza   � Data � 06/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Incluir solicitacoes de transferencia de debito            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fa620Inc(cAlias,nReg,nOpc)                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa620Inc(cAlias,nReg,nOpc)
Local lPanelFin := IsPanelFin()
Local oDlg
Local nOpcA	 	:= 0
Local cNomCli	:= Space(40)
Local oMemo
Local cHistDeb	:= Spac(40) + Chr(13) + Chr(10) + Spac(40) + Chr(13) + Chr(10)
Local oOk    	:= LoadBitmap( GetResources(), "LBOK")
Local oNo    	:= LoadBitmap( GetResources(), "LBNO")
Local oCheck
Local cCheck
Local aCheck 	:= {}
Local aArea		:= GetArea()
Local lRet		:= .F.
Local cLstCart	:= FN022LSTCB(1)	//Lista das situacoes de cobranca (Carteira)
Local oNomCli	:= nil

Private lF620Auto := aRotAuto<>nil
							
If lRetMBrow
	lRetMBrow := .F.
	Return
EndIf

//���������������������������������������������������������������������Ŀ
//� PONTO DE ENTRADA - 12/01/12 - Shark
//�����������������������������������������������������������������������
If (ExistBlock( "FA620CHK" ) )
	If !(ExecBlock("FA620CHK",.F.,.F.))
		Return .F.
	EndIf
Endif

//O processo n�o � permitido pois o adiantamento.
If SE1->E1_TIPO $ MVRECANT
	Help(" ",1,"RAFINA620",,STR0051,1,0) //"Processo n�o permitido para adiantamento."
	Return(.F.)
EndIf

//-------------------------------------------------------------------
// Nao permite solicitacoes para recebimentos antecipados originados
// de faturas de adiantamentos. Req. Manejo de Anticipo
//-------------------------------------------------------------------
If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT")
	If Upper(Alltrim(SE1->E1_ORIGEM)) $ "FINA087A|MATA467N" .And.;
		GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+SE1->E1_NATUREZ,1,"") == "1"

		Help(" ",1,"VLDTITRA",,STR0042,1,0) //"Processo n�o permitido para titulo gerado de fatura de adiantamento."
		Return(.F.)

	EndIf
EndIf

If cPaisLoc == "ARG" .And. SE1->E1_TIPO $ MVCHEQUE
	Help("",1, "VLDTITCH",, STR0052,1,0)
	Return(.F.)
EndIf

Begin Sequence
  //****************************************
	// Restringe o uso do programa Financeiro
	// Quando a origem do titulo for de origem
	// Totvs Incorpora��o = FINTP01(.F.) == .t. 
	//****************************************
	If FINTP01(.T.)
		Break
	Endif

	// Se nao estiver em carteira , se ja houve baixa ou se ja foi solicitada uma transferencia,
	// nao permite nova transferencia
	If !(SE1->E1_SITUACA $ cLstCart)	.Or. ;		
		SE1->E1_SALDO != SE1->E1_VALOR	.Or.;
		!Empty(SE1->E1_NUMSOL)
		Help(" ",1,"FIN62001")
		Break// Vai para a primeira linha apos o end sequence
	Endif 
	

	//PCREQ-3782 - Bloqueio por situa��o de cobran�a
	If !(F023VerBlq("1","0010",SE1->E1_SITUACA,.T.))
		Break// Vai para a primeira linha apos o end sequence
	Endif

	If Upper(Trim(SE1->E1_ORIGEM)) $ "FINA677" 
		Help(" ",1,"FIN62005")
		Break // Vai para a primeira linha apos o end sequence
	Endif

	//Template GEM - nao podem ser liquidados/reliquidados os titulos do GEM pelo financeiro.
	If HasTemplate("LOT") .And. !Empty(SE1->E1_NCONTR)
		IW_MSGBOX(STR0019,STR0015,"STOP") //"N�o � permitida a inclus�o da solicita��o de transfer�ncia para titulos do template GEM. "   "Aten��o"
		Break// Vai para a primeira linha apos o end sequence
	EndIf

	// Se for uma fatura cancelada
	// nao permite a inclusao da solicitacao da transferencia
	If SE1->E1_STATUS == "C"
		IW_MSGBOX(STR0040, STR0015,"STOP")  //"Fatura cancelada. N�o � permitida a inclus�o da solicita��o de transfer�ncia"##"Aten��o"
		Break// Vai para a primeira linha apos o end sequence
	Endif
	// Se for um titulo de abatimento
	// nao permite a inclusao da solicitacao da transferencia
	If SE1->E1_TIPO $ MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
		IW_MSGBOX(STR0041, STR0015,"STOP")  //"N�o � permitida a inclus�o da solicita��o de transfer�ncia para titulos de abatimento. Por favor posicione sobre o titulo principal para efetuar a solicita��o."##"Aten��o"
		Break // Vai para a primeira linha apos o end sequence
	Endif
	dbSelectArea("SE6")
	DbSetOrder(4)
	If !Empty(SE1->E1_NUMSOL) .And.;
		MsSeek(xFilial("SE6")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_FILORIG))
		Help( " ", 1, "FIN62004",,STR0005+CHR(13)+STR0006 + SE6->E6_FILDEB, 4, 0) //"J� existe solicita��o de transfer�ncia do titulo"###"para a filial "
		Break // Vai para a primeira linha apos o end sequence
	Endif

	If !lF620Auto
		//�������������������������������������������������Ŀ
		//� Verifica tabela de check-list de transferencia  �
		//���������������������������������������������������
		dbSelectArea("SX5")
		dbSeek(xFilial("SX5")+"G2")
		While SX5->(X5_FILIAL+X5_TABELA) == xFilial("SX5")+"G2"
			AAdd( aCheck,{.F., X5Descri()})
			dbSkip()
		End
		
		dbSelectArea("SE6")
		DbSetOrder(1)
		RegToMemory("SE6",.F.)
		M->E6_FILDEB	:= CriaVar("E6_FILDEB")
		
		If !lPanelFin
			M->E6_FILDEB	:= cFilAnt
		EndIf
		
		M->E6_CLIENTE	:= CriaVar("E6_CLIENTE")
		M->E6_LOJA		:= CriaVar("E6_LOJA")

		If !lPanelFin .And. !F620VldCli( M->E6_FILDEB, M->E6_CLIENTE, M->E6_LOJA )
			M->E6_CLIENTE	:= Space(Len(SE6->E6_CLIENTE))
			M->E6_LOJA		:= Space(Len(SE6->E6_LOJA))
		EndIf
		
		dbSelectArea("SE1")
		RegToMemory("SE1",.F.)
	
		DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM 0,0 TO 500,708
	
		@  04, 03 TO 100, 352 OF oDlg  PIXEL LABEL STR0007 //"Dados do t�tulo a transferir"
		MsMGet():New("SE1",SE1->(RecNo()),2,,,,,{11,7,95,349},,3,,,,,,.T.)
		
		@ 101, 03 TO 160, 352 OF oDlg  PIXEL LABEL STR0008 //"Check-List para transfer�ncia"
		@ 108, 07 LISTBOX oCheck VAR cCheck Fields HEADER "",STR0009  SIZE 341,50 ON RIGHT CLICK ListBoxAll(108,7,@oCheck,oOk,oNo,@aCheck) NoScroll OF oDlg PIXEL //"Itens para checagem"
		oCheck:SetArray(aCheck)
		oCheck:bLine := { || {If(aCheck[oCheck:nAt,1],oOk,oNo),aCheck[oCheck:nAt,2]}}
		oCheck:bLDblClick := {|| aCheck[oCheck:nAt][1] := !aCheck[oCheck:nAt][1], oCheck:DrawSelect()}
		         
		@ 161, 03 TO 230, 352 OF oDlg  PIXEL LABEL STR0010 //"Dados da Transfer�ncia"
		
		@ 172, 07 SAY STR0011 OF oDlg  PIXEL  //"Filial de D�bito"
		@ 170, 43 MSGET M->E6_FILDEB OF oDlg  SIZE /*25*/50,8 PIXEL F3 "SM0" VALID CheckSx3("E6_FILDEB",M->E6_FILDEB) HASBUTTON
		@ 172, 93 SAY STR0012 OF oDlg  PIXEL //"Cliente a D�bito"
		@ 170,135 MSGET M->E6_CLIENTE OF oDlg  SIZE 50,8  PIXEL F3 "SA1" VALID (Vazio() .Or. ExistCpo("SA1",M->E6_CLIENTE+ALLTRIM(M->E6_LOJA))).And. CheckSx3("E6_CLIENTE",M->E6_CLIENTE) HASBUTTON
		@ 170,130+Len(M->E6_CLIENTE)+50 MSGET M->E6_LOJA OF oDlg  SIZE 20,8 PIXEL VALID (Vazio() .Or. ExistCpo("SA1",M->E6_CLIENTE+ALLTRIM(M->E6_LOJA))).And. CheckSx3("E6_LOJA",M->E6_LOJA) 
		@ 170,130+Len(M->E6_CLIENTE+M->E6_LOJA)+71	MSGET oNomCli Var cNomCli WHEN {||cNomCli := Posicione("SA1",1,xFilial("SA1")+M->E6_CLIENTE+M->E6_LOJA,"A1_NOME"),.F.} OF oDlg  PIXEL SIZE 135,8 OBFUSCATED RetGlbLGPD('A1_NOME')

		@ 185, 07 SAY STR0013 OF oDlg  PIXEL  //"Hist�rico"
		@ 185, 43 GET oMemo VAR cHistDeb OF oDlg MEMO SIZE 300,40 PIXEL FONT oDlg:oFont COLOR CLR_BLACK,CLR_HGRAY

		oMemo:bRClicked := {||AllwaysTrue()}
		
		If lPanelFin  //Chamado pelo Painel Financeiro					
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT FaMyBar(oDlg,;
			{||If(Fa620TOk(oDlg,aCheck,M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA),(nOpcA:=1,oDlg:End()),nOpcA:=0)},;
			{||nOpcA:=0,oDlg:End()},,,.F.,.F.)
	    Else	
			DEFINE SBUTTON FROM 233, 290 TYPE 1 ACTION (If(Fa620TOk(oDlg,aCheck,M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA),(nOpcA:=1,oDlg:End()),nOpcA:=0)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 233, 320 TYPE 2 ACTION (nOpcA:=0,oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
		Endif
	Else
		dbSelectArea("SE6")
		DbSetOrder(1)
		RegToMemory("SE6",.F.,.F.) 
		M->E6_FILDEB	:= CriaVar("E6_FILDEB")
		M->E6_CLIENTE	:= CriaVar("E6_CLIENTE")
		M->E6_LOJA		:= CriaVar("E6_LOJA")   
				
		dbSelectArea("SE1")
		RegToMemory("SE1",.F.)
		
		aValidGet := {}
		If lF620Auto
			If (nT := ascan(aRotAuto,{|x| x[1]='E6_FILDEB'}) ) > 0
				Aadd(aValidGet,{'E6_FILDEB' ,PAD(aRotAuto[nT,2],TamSx3("E6_FILDEB")[1]),"CheckSx3('E6_FILDEB',M->E6_FILDEB)",.t.})
			EndIf
			If (nT := ascan(aRotAuto,{|x| x[1]='E6_CLIENTE'}) ) > 0
				Aadd(aValidGet,{'E6_CLIENTE' ,PAD(aRotAuto[nT,2],TamSx3("E6_CLIENTE")[1]),"CheckSx3('E6_CLIENTE',M->E6_CLIENTE)",.t.})
			EndIf
			If (nT := ascan(aRotAuto,{|x| x[1]='E6_LOJA'}) ) > 0
				Aadd(aValidGet,{'E6_LOJA' ,PAD(aRotAuto[nT,2],TamSx3("E6_LOJA")[1]),"CheckSx3('E6_LOJA',M->E6_LOJA) ",.t.})
			EndIf
			If (nT := ascan(aRotAuto,{|x| x[1]='AUTHISTDEB'}) ) > 0
				cHistDeb := alltrim(aRotAuto[nT,2])
				Aadd(aValidGet,{'AUTHISTDEB' ,aRotAuto[nT,2],".T.",.t.})
				
			EndIf                      

			AAdd( aCheck,{.T., "Transfer�ncia Autom�tica" })

			If SE2->(MsVldGAuto(aValidGet)) .and. Fa620TOk(oDlg,aCheck,M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA)
				nOpcA:=1
			Else
				nOpcA:=0
			EndIf
		EndIf
	Endif
	If nOpcA == 1
		If ! Fa620Grava(M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA,cHistDeb)
			IW_MSGBOX(STR0014, STR0015, "STOP") //"Solicita��o n�o efetuada, tente novamente"###"Aten��o"
		Else
			lRet := .T.
		Endif
	EndIf
End Sequence
RestArea(aArea)

If nOpcA !=0
	lRetMBrow := .T.
EndIf
	                                   
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa620Grava� Autor � Claudio D. de Souza   � Data � 26/02/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava as solicitacoes de transferencia de debito           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fa620Grava(cFilDeb,cCliDeb,cLojaDeb,cHistDeb)			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC FUNCTION Fa620Grava(cFilDeb As Character, cCliDeb As Character,cLojaDeb As Character,cHistDeb As Character)  As Logical
Local lRet 		As Logical 
Local cFilOld   As Character
Local aAlt      As Array 
Local cFilOri   As Character 
Local cNumSol   As Character
Local cE6Ind7   As Character 
Local cE6Chave  As Character 
Local nOrder    As Numeric 

lRet :=.F.      
cFilOld := cFilAnt
aAlt      := {}
cFilOri   := ''
cE6Ind7   := SE6->(IndexKey(7))
cE6Chave  := ""
nOrder    := Iif(!Empty(cE6Ind7) .and. Alltrim(cE6Ind7) == "E6_NUMSOL" ,7,3)

cFilant := cFilDeb // A transferencia deve ser gravada na filial de Destino (Debito) 

BEGIN TRANSACTION   
	If RecLock("SE1",.F.)
	  cFilOri   := SE1->E1_FILIAL 
		While .t.
			cNumSol := GetSxENum("SE6", "E6_NUMSOL","E6_NUMSOL"+cEmpAnt,nOrder)
			ConfirmSx8()
			dbSelectArea("SE6")
			dbSetOrder(nOrder)
			// Prote��o para garantir a existencia do Indice.
			If nOrder == 7 
				cE6Chave := cNumSol
			else
				cE6Chave := cFilDeb+cNumSol
			Endif
 
			If !dbSeek(cE6Chave)
				Exit
			EndIf
		EndDo
		If RecLock("SE6",.T.)
			lRet := .T.
			SE6->E6_FILIAL		:= xFilial("SE6")
			SE6->E6_FILORIG		:= SE1->E1_FILORIG
			SE6->E6_TIPOSOL		:= "R"
			SE6->E6_NUMSOL		:= cNumSol
			SE6->E6_DATSOL		:= dDataBase
			SE6->E6_HORSOL		:= StrTran(Left(Time(),5),":","")
			SE6->E6_PREFIXO		:= SE1->E1_PREFIXO
			SE6->E6_NUM			:= SE1->E1_NUM
			SE6->E6_PARCELA		:= SE1->E1_PARCELA
			SE6->E6_TIPO   		:= SE1->E1_TIPO
			SE6->E6_VALOR  		:= SE1->E1_VALOR
			SE6->E6_SITSOL   	:= "1" // Em aberto
			SE6->E6_USRSOL   	:= RetCodUsr() 
			SE6->E6_CLIENTE		:= cCliDeb
			SE6->E6_LOJA		:= cLojaDeb
			SE6->E6_FILDEB		:= cFilDeb
			// Grava historico
			MSMM(SE6->E6_CDHSOL,,,cHistDeb,1,,,"SE6","E6_CDHSOL")
			SE1->E1_NUMSOL		:= SE6->E6_NUMSOL
			If SpbInUse() .AND. Trim(SE1->E1_MODSPB) == "" 
				SE1->E1_MODSPB := "1"
			EndIf
			If Trim(SE1->E1_SCORGP) == "" 
				SE1->E1_SCORGP := "2"
			EndIf
			If Trim(SE1->E1_FLUXO) == "" 
				SE1->E1_FLUXO := "S"
			EndIf
			If Trim(SE1->E1_MULTNAT) == "" 
				SE1->E1_MULTNAT := "2"
			EndIf
			MsUnlock()
			ConfirmSx8()
		Endif
		MsUnlock()
	Endif
	
END TRANSACTION

cFilAnt := cFilOri

///numbor			
aadd( aAlt,{ STR0046,'','','',STR0047 +  Alltrim(cFilDeb) })   
//chamada da Fun��o que cria o Hist�rico de Cobran�a
FinaCONC(aAlt)

cFilAnt := cFilOld

RETURN lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa620TOk  � Autor � Claudio D. de Souza   � Data � 26/02/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validar o botao Ok na inclusao das solic de transf de debito���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fa620TOk(oDlg,aCheck,cFilDeb,cCliDeb)					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMS                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION Fa620TOk(oDlg,aCheck,cFilDeb,cCliDeb,cLojaDeb,lF620Auto)
Local lRet := .T.
Local aArea := {}    

Default lF620Auto:= .F.

// Se todos os itens do check-list estiverem marcados, autoriza a transferencia.
aEval(aCheck, {|e| lRet := lRet .And. e[1] } )

If lRet
	If Empty(cCliDeb) .or. Empty(cLojaDeb)
		lRet := .F.
		cMsgErr := STR0043 //Os campos Fornecedor e Loja devem ser preenchidos
		Help( ,, 'HELP',, cMsgErr, 1, 0)
	Endif
	
	If SE1->E1_FILORIG == cFilDEb .And. SE1->E1_CLIENTE == cCliDeb .And. SE1->E1_LOJA == cLojaDeb
		lRet := .F.
		Help(" ",1,"FIN62002")
	Endif
	If lRet .And. !F620VldCli( cFilDeb, cCliDeb, cLojaDeb ) 
		lRet := .F.
		Help(" ",1,"FIN62002")
	Endif
	If lRet .And. cEmpAnt != SM0->M0_CODIGO
		lRet := .F.
		IW_MSGBOX(STR0017, STR0015, "STOP") // "A empresa destino deve ser igual a empresa origem"
	Endif

	//���������������������������������������������������������������Ŀ
	//� Tratamento para impedir a mudan�a de cliente na transfer�ncia �
	//� de t�tulos entre filiais mantendo o ISS na origem             �
	//�����������������������������������������������������������������
	If lRet .And. !GetNewPar( "MV_TRFISSF" , .T. ) .And. ( SE1->E1_CLIENTE <> cCliDeb .Or. SE1->E1_LOJA <> cLojaDeb ) 
		aArea    := GetArea()
		SE1->( dbSetOrder( 1 ) )//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->( dbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+;
			/*E1_TIPO*/Pad( MVISABT , Len( E1_TIPO ) ) ) ) )
			lRet := .F.
			IW_MSGBOX(STR0044, STR0015, "STOP") //"N�o � poss�vel transferir o t�tulo mantendo abatimento(s) na origem e alterando o cliente."###"Aten��o"			
		EndIf
		//ISS Bitributa��o - CEPOM
		If SE1->( dbSeek( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+;
			/*E1_TIPO*/Pad( MVI2ABT , Len( E1_TIPO ) ) ) ) )
			lRet := .F.
			IW_MSGBOX(STR0044, STR0015, "STOP") //"N�o � poss�vel transferir o t�tulo mantendo abatimento(s) na origem e alterando o cliente."###"Aten��o"			
		EndIf
		RestArea( aArea )
	EndIf

	IF SE1->E1_TIPO $ MVRECANT .And. SE1->E1_FILORIG <> cFilDEb
		lRet := .F.		
		cMsgErr := STR0049 //"N�o � permitida a inclus�o da solicita��o de transfer�ncia de t�tulos de recebimento antecipado para filiais diferentes."
		Help( ,, 'SOLICTRANSF',, cMsgErr, 1, 0)
	EndIf
	
Else
	IW_MSGBOX(STR0016, STR0015,"STOP") //"� necess�rio que todos os itens do check-list sejam verificados para efetuar a solicita��o"###"Aten��o"
Endif

Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa620Leg    � Autor � Claudio D. de Souza � Data � 27.03.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a ���
���          � para o BROWSE                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA620                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa620Leg(nReg)

Local aLegenda := {	{"BR_VERDE", STR0020 },;	 
					{"BR_VERMELHO", STR0021 },;		 
					{"BR_PRETO", STR0022} }
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { "E1_STATUS#'C' .And. E1_NUMSOL=' '", aLegenda[1][1] } )
	Aadd(uRetorno, { "E1_STATUS#'C' .And. E1_NUMSOL#' '", aLegenda[2][1] } )
	Aadd(uRetorno, { "E1_STATUS='C'", aLegenda[3][1] } )
Else
	BrwLegenda(cCadastro, "Legenda",aLegenda)
Endif

Return uRetorno


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �28/11/06 ���
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
Local aRotina	:=	{{STR0036	,"AxPesqui", 0 , 1,,.F.},; 	//"Pesquisar"    
                     {STR0037	,"AxVisual", 0 , 2},; 		//"Visualizar"   
                     {STR0038	,"Fa620Inc", 0 , 3},; 		//"Solicitar"    
					 {STR0018	,"Fa620Leg", 0 , 6, ,.F.}}  //"Legenda"     
Return(aRotina)



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FinA620T   � Autor � Marcelo Celi Marques � Data � 27.03.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada semi-automatica utilizado pelo gestor financeiro   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA620                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinA620T(aParam)

	ReCreateBrow("SE1",FinWindow)      	
	cRotinaExec := "FINA620"
	FinA620(,aParam[1])
	ReCreateBrow("SE1",FinWindow)      	

	dbSelectArea("SE1")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.	

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa620Auto  � Autor � Acacio Egas          � Data � 20.02.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada automatica para gera��o de transferencia e         ���
���Descri��o � aprovacao.                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA620                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa620Auto(nRecSe1,cfilDest,cHist, lAprov, lMsgErro)
Local aVetor 	:= {}
Local cFilbak	:= cFilAnt
Local lRet		:= .F.
Local IsAuto	:= Type("lMsErroAuto")<>"U"
//Local cQuery 		:= "" 

Default nRecSe1 := SE1->(RECNO())
Default cHist	 := "Estorno de Transferencia de titulo entre filiais."
Default lAprov	 := .F.
Default lMsgErro:= .F.

If	!IsAuto
	lMsErroAuto := .F.
EndIf

DbSelectArea("SE1")
DbGoto(nRecSe1)
                    
aVetor :={{"E6_FILDEB"	,cfilDest,Nil},;
		  {"E6_CLIENTE"	,SE1->E1_CLIENTE,Nil},;
		  {"E6_LOJA"	,SE1->E1_LOJA,Nil},;
		  {"AUTHISTDEB"	,cHist,Nil}}

If !IsAuto
	MSExecAuto({|x,y| Fina620(x,y)},aVetor,3) //Inclusao de Solicita��o de transferencia
Else
	lRet	:= Fina620(aVetor,3)
EndIf

If !lMsErroAuto
	If lAprov
		aVetor :={{"E6_NUMSOL"	,SE1->E1_NUMSOL,Nil}}
		cFilAnt	:= SE6->E6_FILDEB
		If	!IsAuto
			MSExecAuto({|x,y| Fina630(x,y)},aVetor,3) //Aprova��o Automatica da transferencia
		Else
			lRet	:= Fina630(aVetor,3)
		EndIf
		cFilAnt	:= cFilbak
		If !lMsErroAuto
			lRet	:= .T.
		EndIf
	Else
		lRet	:= .T.
	Endif
Endif

If lMsgErro .and. lMsErroAuto
	mostraerro()
Endif

Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa620Estor � Autor � Acacio Egas          � Data � 20.02.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada automatica para estorno de transferencia e         ���
���Descri��o � aprovacao.                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA620                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa620Estor(nRecSe1,lMsgErro)

Local aVetor 	:= {}
Local cFilbak	:= cFilAnt
Local lRet		:= .F.
Local IsAuto	:= Type("lMsErroAuto")<>"U"

Default nRecSe1 := SE1->(RECNO())
Default lMsgErro:= .F.

If	!IsAuto
	lMsErroAuto := .F.
EndIf

DbSelectArea("SE1")
DbGoto(nRecSe1)

If !Empty(SE1->E1_NUMSOL)

	aVetor :={{"E6_NUMSOL"	,SE1->E1_NUMSOL,Nil}}
	
	cFilAnt	:= SE6->E6_FILDEB
	
	If !IsAuto
		MSExecAuto({|x,y| Fina630(x,y)},aVetor,6) //Excluir
	Else
		Fina630(aVetor,6)
	EndIf
	
	cFilAnt	:= cFilbak

	If lMsgErro .and. lMsErroAuto
		If !IsBlind()
			mostraerro()
		EndIf
	Endif
	

Else

	Help(" ",1,"FIN63003",,STR0029,1,0) //"Este titulo n�o foi utilizado em tranferencia."
	lMsErroAuto := .T.

EndIf	


Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa620Stat  � Autor � Acacio Egas          � Data � 20.02.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Status do titulo na rotina de transferencia.     ���
���          � 0= Titulo Normal;                                          ���
���          � 1=Titulo transferido;                                      ���
���          � 2= Titulo de transferencia;                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA620                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa620Stat(nRecSe1,aAreaSE6)
Local cQuery
Local nRet	:= 0

Default nRecSe1	:= SE1->(Recno())

DbSelectArea("SE1")
DbGoto(nRecSe1)

If !Empty(SE1->E1_NUMSOL)
	
	DbSelectArea("SE6")
	DbSetOrder(3)
	If DbSeek(xFilial("SE6")+SE1->E1_NUMSOL) .and. SE6->E6_SITSOL=="2"
		nRet := 1
		aAreaSE6	:= SE6->(GetArea())
	EndIf

Else
	
	cQuery := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName( "SE6" ) + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND E6_FILDEB='" + SE1->E1_FILIAL + "' AND "
	cQuery += "E6_PREFIXO='" + SE1->E1_PREFIXO + "' AND E6_NUM='" + SE1->E1_NUM + "' AND "
	cQuery += "E6_PARCDES='" + SE1->E1_PARCELA + "' AND E6_TIPO='" + SE1->E1_TIPO + "' "
	cQuery := ChangeQuery( cQuery ) 

	dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "TMPSE6", .F., .T. )
	If TMPSE6->(!Eof()) 
		DbSelectArea("SE6")
		DbSetOrder(3)
		DbGoto(TMPSE6->(REC))
		SE6->(GetArea())
		nRet := 2
	EndIf
	TMPSE6->(DbCloseArea())

EndIf

Return nRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F620VldCli�Autor  �Microsiga           � Data �  11/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida Cliente/loja na Filial digitada para transferencia   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F620VldCli( cFilDeb, cCliDeb, cLojaDeb )
Local lRet := .F.
Local aArea := GetArea()
Local aAreaSA1 := SA1->( GetArea() )
Local cFilOld := cFilAnt

cFilAnt := cFilDeb
dbSelectArea( "SA1" )
dbSetOrder( 1 )
lRet := MsSeek( xFilial("SA1")+cCliDeb+cLojaDeb )
cFilAnt := cFilOld

RestArea(aAreaSA1)
RestArea(aArea)

Return( lRet ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F620VldFil�Autor  �Microsiga           � Data �  11/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida Filial digitada para transferencia                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F620VldFil(cFilAux)
Local lRet := .F.
//primeiro verificar se filial existe no Grupo Empresa
lRet := FWFilExist(cEmpAnt,cFilAux)

If lRet

	If !lGestao
		aFilValido := FWAllFilial(,,cEmpAnt)   //este array contera as filiais validas
		If Empty(aFilValido)
			lRet := .F.
		EndIf
	Else  //se gestao corporativa
		lCompSA1Emp := ( FWModeAccess("SA1",1) == "C" )
		lCompSA1Uni := ( FWModeAccess("SA1",2) == "C" )
		lCompSA1Fil := ( FWModeAccess("SA1",3) == "C" )
		aFilValido := F620FilArr( lCompSA1Emp, lCompSA1Uni, lCompSA1Fil )  ////este array contera as filiais validas
		If Empty(aFilValido)
			lRet := .F.
		EndIf
	EndIf
	
	lRet := lRet .And. ( aScan( aFilValido, cFilAux) > 0 )
	
EndIf

If !lRet
	Help(" ",1,"A000FI")
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F620FilArr�Autor  �Microsiga           � Data �  11/10/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna array com as filiais para transferencia de acordo   ���
���          �com compartilhamento da tabela SA1                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F620FilArr( lCompSA1Emp, lCompSA1Uni, lCompSA1Fil )
Local aAuxFil := {}
Local aFilSM0 := AdmAbreSM0()
Local nX := 0

If "E" $ FWSM0Layout() .And. lCompSA1Emp  //se a empresa eh compartilhada uni e fil tb sao

	For nX := 1 TO Len(aFilSM0)
		If aFilSM0[nX, 1] == cEmpAnt
			aAdd(aAuxFil, aFilSM0[nX, 2])
		EndIf
	Next

ElseIf "U" $ FWSM0Layout() .And. lCompSA1Uni  //se a unid neg eh compartilhada fil tb sao

	For nX := 1 TO Len(aFilSM0)
		If aFilSM0[nX, 1] == cEmpAnt
			If aFilSM0[nX, 3] == FwCompany()
				aAdd(aAuxFil, aFilSM0[nX, 2])
			EndIf
		EndIf
	Next

ElseIf "F" $ FWSM0Layout() .And. lCompSA1Fil  //se filial compartilhada

	If "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout()
		For nX := 1 TO Len(aFilSM0)
			If aFilSM0[nX, 1] == cEmpAnt
				If aFilSM0[nX, 3] == FwCompany()
					If aFilSM0[nX, 4] == FWUnitBusiness()
						aAdd(aAuxFil, aFilSM0[nX, 2])
					EndIf
				EndIf
			EndIf
		Next
	Else
		If "E" $ FWSM0Layout()
			For nX := 1 TO Len(aFilSM0)
				If aFilSM0[nX, 1] == cEmpAnt
					If aFilSM0[nX, 3] == FwCompany()
						aAdd(aAuxFil, aFilSM0[nX, 2])
					EndIf
				EndIf
			Next
		EndIf
    EndIf

Else //se for tudo exclusivo

	For nX := 1 TO Len(aFilSM0)
		If aFilSM0[nX, 1] == cEmpAnt
			aAdd(aAuxFil, aFilSM0[nX, 2])
		EndIf
	Next

EndIf

Return(aAuxFil)

