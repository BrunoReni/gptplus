#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSA980.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA980  � Autor � Eduardo de Souza      � Data � 12/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Clientes Preservados                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA980                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA980()

Local aCores      := {}
Private cCadastro := STR0001 // 'Clientes Preservados'
Private aRotina   := MenuDef()

DbSelectArea('DWO')
DbSetOrder(1)

Aadd(aCores,{"DWO_STATUS=='1'",'BR_VERDE'		}) // Ativo
Aadd(aCores,{"DWO_STATUS=='2'",'BR_VERMELHO'	}) // Inativo

mBrowse(6,1,22,75,'DWO',,,,,,aCores)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA980Mnt � Autor � Eduardo de Souza      � Data � 12/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao - Clientes Preservados                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMA980Mnt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMA980Mnt(cAlias,nReg,nOpcx)

Local oDlg
Local oEnch
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local nOpca      := 0
Private aTELA[0][0]
Private aGETS[0]

If Type("aRotina") == "U"
	Private aRotina := MenuDef()
EndIf

nOpcx := aRotina[nOpcx][4]

RegToMemory("DWO",nOpcx==3)

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnch := MsMGet():New("DWO",nReg,nOpcx,,,,,aPosObj[1],iif(nOpcx == 4,{"DWO_MOTIVO","DWO_STATUS"},),3,,,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| If(Obrigatorio(aGets,aTela) .And. TMSA980VOk(),(nOpca := 1,oDlg:End()),) } , {|| oDlg:End() } ) CENTERED

If nOpcx <> 2 .And. nOpca == 1
	Begin Transaction
		TMA980Grv(nOpcx)
	End Transaction
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA980Vld � Autor � Eduardo de Souza      � Data � 12/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao dos campos                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMA980Vld                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMA980Vld()

Local cCampo   := ReadVar()
Local lRet     := .T.
Local aContrat := {}

If cCampo $ 'M->DWO_CODCLI/M->DWO_LOJCLI'
	If cCampo == 'M->DWO_CODCLI'
		lRet := ExistCpo("SA1",M->DWO_CODCLI,1)
	Else
		lRet := ( ExistCpo("SA1",M->DWO_CODCLI+M->DWO_LOJCLI,1) )
	EndIf	
	If lRet
		M->DWO_NOMCLI := Posicione('SA1',1,xFilial('SA1')+M->DWO_CODCLI+M->DWO_LOJCLI,'A1_NOME')
		If !Empty(M->DWO_CODCLI) .And. !Empty(M->DWO_LOJCLI) .And. !Empty(M->DWO_TIPFRE)
			aContrat := TMSContrat(M->DWO_CODCLI,M->DWO_LOJCLI,,,.T.,M->DWO_TIPFRE,.F.,,,,,,,,,,,,,,,M->DWO_CODNEG)
			lRet     := Len(aContrat) <> 0
		EndIf
	EndIf
ElseIf cCampo == 'M->DWO_TIPFRE'
	If !Empty(M->DWO_CODCLI) .And. !Empty(M->DWO_LOJCLI) .And. !Empty(M->DWO_TIPFRE)
		aContrat := TMSContrat(M->DWO_CODCLI,M->DWO_LOJCLI,,,.T.,M->DWO_TIPFRE,.F.,,,,,,,,,,,,,,,M->DWO_CODNEG)
		lRet     := Len(aContrat) <> 0
	EndIf
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA980VOk� Autor � Eduardo de Souza      � Data � 16/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da tecla OK                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA980VOk                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA980VOk()

Local lRet := .T.

//-- Verifica se o cliente ja foi informado
lRet := ExistChav( "DWO",M->DWO_CODCLI+M->DWO_LOJCLI+M->DWO_TIPFRE )

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA980Leg � Autor � Eduardo de Souza      � Data � 16/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe a Legenda                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMA980Leg()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMA980Leg()

Local aStatus := {}

Aadd( aStatus, {'BR_VERDE'   , STR0012 } ) // 'Ativo'
Aadd( aStatus, {'BR_VERMELHO', STR0013 } ) // 'Inativo'

BrwLegenda( STR0001, STR0014, aStatus ) //'Status'

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA980Grv � Autor � Eduardo de Souza      � Data � 16/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava clientes preservados                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMA980Grv()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMA980Grv(nOpcx)

Local nCnt   := 0
Local bCampo := { |nCpo| Field(nCpo) }
Local cMotivo:= ''

DbSelectArea("DWO")
DbSetOrder(1)

If nOpcx == 5 //-- Exclusao
	If DWO->(MsSeek(xFilial("DWO")+M->DWO_CODCLI+M->DWO_LOJCLI+M->DWO_TIPFRE))
		RecLock("DWO",.F.)
		DWO->(DbDelete())
		MsUnlock()
	EndIf
	MSMM(DWO->DWO_CODMOT,,,,2)

ElseIf nOpcx == 3 .Or. nOpcx == 4 //-- Alteracao
	If !DWO->(MsSeek(xFilial("DWO")+M->DWO_CODCLI+M->DWO_LOJCLI+M->DWO_TIPFRE))
		RecLock("DWO",.T.)
		cMotivo := M->DWO_MOTIVO
	Else
		RecLock("DWO",.F.)
		cMotivo := M->DWO_MOTIVO
	EndIf
	For nCnt := 1 TO FCount()
		If FieldName(nCnt) == "DWO_FILIAL"
			FieldPut(nCnt,xFilial("DWO"))
		Else
			If Type('M->'+FieldName(nCnt)) <> 'U'
				FieldPut(nCnt,M->&(Eval(bCampo,nCnt)))
			EndIf
		EndIf
	Next nCnt
	MSMM(DWO->DWO_CODMOT,,,cMotivo,1,,,"DWO","DWO_CODMOT")
	MsUnlock()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA980Prc � Autor � Eduardo de Souza      � Data � 16/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa clientes preservados                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMA980Prc()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMA980Prc()

Local aSays    := {}
Local aButtons := {}

Aadd( aSays, STR0011 ) //'Este programa tem como objetivo, atualizar para "Sim" o reajuste automatico de todos '
Aadd( aSays, STR0015 ) //'contratos vigentes com exe�� dos contratos referentes aos clientes preservados. '

// "Processando clientes preservados..." ### "Aguarde..."
Aadd( aButtons, { 1, .T., {|o| MsgRun( STR0009 , STR0010 ,{|| TMA980Prc1() } ), nOpca:= 1, o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )

FormBatch( cCadastro, aSays, aButtons )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA980Prc1� Autor � Eduardo de Souza      � Data � 16/01/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa clientes preservados                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMA980Prc1()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA980                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMA980Prc1()

Local cQuery    := ""
Local lInverte  := .F.
Local lTM980INV := ExistBlock("TM980INV")
Local iCont     := 0

//-- Ponto de Entrada utilizado para inverter a atualizacao do campo reajuste automatico.
If lTM980INV
	lInverte := ExecBlock("TM980INV",.F.,.F.)
	If ValType(lInverte) <> "L"
		lInverte  := .F.
	EndIf
EndIf

Begin Transaction
	cQuery := " UPDATE " + RetSQLName("AAM") + " SET AAM_REAAUT = '" + Iif(lInverte,"2","1") + "' "
	cQuery += "   WHERE AAM_FILIAL = '" + xFilial("AAM") + "' "
	cQuery += "     AND AAM_STATUS = '1' "
	cQuery += "     AND AAM_INIVIG <= '" + DToS(dDataBase) + "' "
	cQuery += "     AND ( AAM_FIMVIG = ' ' OR ( AAM_INIVIG <= '" + DToS(dDataBase) +"' AND AAM_FIMVIG >= '" + DToS(dDataBase) + "' ) ) "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	TCSqlExec( cQuery )
	
	DWO->(DbSetOrder(1))
	DWO->(MsSeek(xFilial("DWO")))
	While DWO->(!Eof())
		If DWO->DWO_STATUS == StrZero(1,Len(DWO->DWO_STATUS)) //-- Ativo
			cQuery := " UPDATE " + RetSQLName("AAM") + " SET AAM_REAAUT = '" + Iif(lInverte,"1","2") + "' "
			cQuery += "   WHERE AAM_FILIAL = '" + xFilial("AAM") + "' "
			cQuery += "     AND AAM_CODCLI = '" + DWO->DWO_CODCLI + "' "
			cQuery += "     AND AAM_LOJA   = '" + DWO->DWO_LOJCLI + "' "
			cQuery += "     AND ( AAM_TIPFRE = '3' OR AAM_TIPFRE = '" + DWO->DWO_TIPFRE + "' ) "
			cQuery += "     AND AAM_STATUS = '1' "
			cQuery += "     AND AAM_INIVIG <= '" + DToS(dDataBase) + "' "
			cQuery += "     AND ( AAM_FIMVIG = ' ' OR ( AAM_INIVIG <= '" + DToS(dDataBase) +"' AND AAM_FIMVIG >= '" + DToS(dDataBase) + "' ) ) "
			cQuery += "     AND D_E_L_E_T_ = ' ' "
			TCSqlExec( cQuery )
			iCont ++
		EndIf
		DWO->(DbSkip())
	EndDo
	Help("",1,"TMSA98001",,cValToChar(iCont),4,0)
End Transaction

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
     
Private aRotina   := {	{STR0002,'AxPesqui' , 	0, 1,0,.F.},;   // 'Pesquisar'
					  			{STR0003,'TMA980Mnt',	0, 2,0,NIL},; // 'Visualizar'
					  			{STR0004,'TMA980Mnt',	0, 3,0,NIL},; // 'Incluir'
					  			{STR0005,'TMA980Mnt',	0, 4,0,NIL},; // 'Alterar'
					  			{STR0006,'TMA980Mnt',	0, 5,0,NIL},; // 'Excluir'
					  			{STR0007,'TMA980Prc',	0, 6,0,NIL},; // 'Processar'
					  			{STR0008,'TMA980Leg',	0, 7,0,.F.}}  // 'Legenda'


If ExistBlock("TM980MNU")
	ExecBlock("TM980MNU",.F.,.F.)
EndIf

Return(aRotina)
