#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF55.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSAF55  � Autor � Telso Carneiro        � Data � 31/10/07   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Despesas X Contas Contabeis por Veiculos                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF55()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � TMS - Gestao de Transportes                                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function TMSAF55() 

Private cCadastro  := STR0001 //'Despesas X Contas Contabeis por Veiculo'
Private aRotina	:=	{	{ STR0002 ,STR0003	, 0, 1 },;	 //"Pesquisar"###"AxPesqui"
						{ STR0004 ,"TMSAF55Mnt"	, 0, 2 },; //"Visualizar"
						{ STR0005 ,"TMSAF55Mnt"	, 0, 3 },;	 //"Incluir"
						{ STR0006 ,"TMSAF55Mnt"	, 0, 4 },;	 //"Alterar"
						{ STR0007 ,"TMSAF55Mnt"	, 0, 5 }} //"Excluir"

MBrowse(,,,,'DFY')

RetIndex('DFY')

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF55Mnt � Autor � Telso Carneiro     � Data �  31/10/07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Manutencao das Despesas X Contas Contabeis por Veiculo      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSAF55Mnt( ExpC1,ExpN1,ExpN2 )                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 - Alias                                               ���
���          �ExpC2 - Registro                                            ���
���          �ExpC3 - Opcao Selecionada                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TMSAF55                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF55Mnt(cAlias,nReg,nOpc)
Local oEnchoice    := Nil
Local lOk          := .F.
Local oDlg         := Nil
Local aSize        := {}
Local aObjects     := {}
Local aInfo        := {}
Local aNoFields    := {'DFZ_CODDES'}
Local nMaxLin      := 999
Local aButtons     := {}
Local aRateio      := {}
Local nPosCC

Private aTela[0][0]
Private aGets[0]
Private aHeader    := {}
Private aCols      := {}
Private aSetKey    := {}

Default cAlias     := 'DFY'
Default nReg       := 1
Default nOpc       := 1

If nOpc == 3 .Or. nOpc == 4
	Aadd(aSetKey, { VK_F6, {|| TMSSelField('SERTMS','M->DFY_SRTCUS') } } )
	aAdd(aButtons,{ "SDUREPL", {|| TMSSelField('SERTMS','M->DFY_SRTCUS')}, STR0010, STR0011 } )  //"Tipos de Servi�o - <F6>"###"Tp.Servi�o"
	Aadd(aSetKey, { VK_F7, {|| TMSSelField('TIPTRA','M->DFY_TPTCUS') } } )
	aAdd(aButtons,{ "CARGA", {|| TMSSelField('TIPTRA','M->DFY_TPTCUS')}, STR0012, STR0013 } )  //"Tipos de Transporte - <F7>"###"Tp.Transp"
	
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//��������������������������������������������������������Ŀ
//�Verifica se o registro n�o est� em uso por outra esta��o�
//����������������������������������������������������������
If nOpc == 4 .Or. nOpc == 5 //-- 4=Alteracao ; 5=Exclusao
	If !SoftLock("DFY")
		Return Nil
	EndIf	
EndIf

//�������������������������������Ŀ
//�Configura variaveis da Enchoice�
//���������������������������������
RegToMemory( cAlias, nOpc==3 )

//�����������������������������������������Ŀ
//�Configura variaveis da GetDados Principal�
//�������������������������������������������
TMSFillGetDados(nOpc, 'DFZ', 1, xFilial( 'DFZ' ) + M->DFY_CODDES ,; 
				{ ||  DFZ->(DFZ_FILIAL + DFZ_CODDES ) },;
				{ || .T. }, aNoFields )

//�������������������������Ŀ
//�Preenche o Numero do Item�
//���������������������������
If Empty(GDFieldGet("DFZ_ITEM",1))
	GDFieldPut("DFZ_ITEM",StrZero(1,Len(DFZ->DFZ_ITEM)),1)
EndIf

If nOpc == 2
	nPosCC := GdFieldPos("DFZ_CONTA")
	//-- Ordena o array
	Asort( aCols,,,{ |x,y| x[nPosCC] < y[nPosCC] } )
EndIf

//�����������������������Ŀ
//�Tratamento da Interface�
//�������������������������

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 135, .T., .T. } )
AAdd( aObjects, { 235, 200, .T., .T. } )
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnchoice	:= MsMGet():New( cAlias, nReg, nOpc,,,,, aPosObj[1],,3,,,,,,.T.)

oGetDados 	:= MSGetDados():New(	aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ],; 
									nOpc, 'TMSAF55LOk','AllWaysTrue()','+DFZ_ITEM',;
									IIf((nOpc==3 .Or. nOpc==4),.T.,Nil),,,,nMaxLin)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| If(Obrigatorio(aGets,aTela) .And. oGetDados:TudoOk(), ( lOk := .T., oDlg:End()), lOk := .F. )} ,;
													{|| lOk := .F., oDlg:End()},,aButtons) CENTERED

If nOpc != 2 .And. lOk
	TMSAF55Grv(nOpc)
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

DFY-> ( MsUnLock() )
Return
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF55LOk � Autor � Vitor Raspa          � Data � 10.Jan.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok na validacao da tela principal                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF55LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF55LOk( nOpc )
Local lRet      := .T.
Local aCpoCheck := {'DFZ_CONTA'}
Local aCpoNoEmp := {'DFZ_CC','DFZ_CC2'}
Local cConta    := GDFieldGet('DFZ_CONTA',n)
Local cItemCta  := GDFieldGet('DFZ_ITEMCT',n)
Local cClVl     := GDFieldGet('DFZ_CLVL',n)
Local cCCDe     := GDFieldGet('DFZ_CC',n)
Local cCCAte    := GDFieldGet('DFZ_CC2',n) 
Local lTipoCt1  := GdFieldGet('DFZ_TPITEM',n) == '1'
Local nCtn      := 0

If lTipoCt1
	Aadd(aCpoCheck,'DFZ_ITEMCT')
	Aadd(aCpoCheck,'DFZ_CLVL')
EndIf

//-- Analisa se ha itens duplicados na GetDados.
If !GDDeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	lRet := GDCheckKey(aCpoCheck,4)	
EndIf

//-- Analisa se ha itens vazios na GetDados.
If !GDDeleted(n) .And. lTipoCt1
	For nCtn := 1 To Len(aCpoNoEmp)
		lRet := !Empty(GdFieldGet(aCpoNoEmp[nCtn],n))
		If !lRet
			Help('',1,'OBRIGAT',,aHeader[GdFieldPos(aCpoNoEmp[nCtn]),1],4,0)
			Exit
		EndIf
	Next
EndIf

//-- Valida o intervalo de digitacao dos Centros de Custo
If lRet .And. !GDDeleted(n) .And. lTipoCt1
	If n == 1 
		lRet := Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe >= aLine[GDFieldPos('DFZ_CC')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC2')] }, n+1, Len(aCols) ) = 0
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte <= aLine[GDFieldPos('DFZ_CC2')] }, n+1, Len(aCols) ) = 0	
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC2')] }, n+1, Len(aCols) ) = 0		
	ElseIf n == Len(aCols)
		lRet := Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe >= aLine[GDFieldPos('DFZ_CC')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC2')] }, 1, Len(aCols)-1 ) = 0
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte <= aLine[GDFieldPos('DFZ_CC2')] }, 1, Len(aCols)-1 ) = 0	
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC2')] }, 1, Len(aCols)-1 ) = 0		
	Else
		lRet := Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe >= aLine[GDFieldPos('DFZ_CC')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC2')] }, n+1, Len(aCols) ) = 0
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte <= aLine[GDFieldPos('DFZ_CC2')] }, n+1, Len(aCols) ) = 0	
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC2')] }, n+1, Len(aCols) ) = 0		

		//-- Seta para Cima
		lRet := Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe >= aLine[GDFieldPos('DFZ_CC')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC2')] }, 1, n-1 ) = 0
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte <= aLine[GDFieldPos('DFZ_CC2')] }, 1, n-1 ) = 0	
		lRet := lRet .And. Ascan( aCols, {|aLine|	!aLine[Len(aLine)] .And. cConta+cItemCta+cClVl == aLine[GDFieldPos('DFZ_CONTA')]+aLine[GDFieldPos('DFZ_ITEMCT')]+aLine[GDFieldPos('DFZ_CLVL')] .And. cCCDe <= aLine[GDFieldPos('DFZ_CC')] .And. cCCAte >= aLine[GDFieldPos('DFZ_CC2')] }, 1, n-1 ) = 0		
	EndIf

	If !lRet
		Help('',1,'TMSAF5005') //-- "O Centro de Custo esta dentro de um intervalo ja lancado!"
	EndIf
EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF55Grv � Autor � Vitor Raspa          � Data � 10.Jan.07���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao dos Dados                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF55Grv()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF55Grv(nOpc)
Local nAux	     := 0
Local nAux2	     := 0

Begin Transaction
	//-- Exclusao
	If nOpc == 5	
		//-- Itens Desp. X Contas Contab.
		DFZ->(DbSetOrder(1))
		While DFZ->(MsSeek(xFilial('DFZ') + DFY->DFY_CODDES))
			RecLock('DFZ', .F.)
			DbDelete()
			MsUnLock()
		EndDo
		//-- Cabecalho Desp. X Contas Contab.
		RecLock('DFY',.F.)
		DbDelete()
		MsUnLock()
	Else		
		//-- Cabecalho
		RecLock('DFY', nOpc == 3 )
		DFY->( AEval( 	dbStruct(),; 
						{|aFieldName,nI| FieldPut( nI, If('FILIAL' $ aFieldName[1], xFilial( "DFY" ), M->&(aFieldName[1])))}))

		//-- Itens Desp. X Contas Contab.
		For nAux := 1 To Len( aCols )
			DFZ->(dbSetOrder(1))
			If	!GDDeleted( nAux ) 
				If	DFZ->( MsSeek( xFilial('DFZ') + M->DFY_CODDES + GDFieldGet('DFZ_ITEM',nAux)))
					RecLock('DFZ', .F.)
				Else
					RecLock('DFZ', .T.)
					DFZ->DFZ_FILIAL := xFilial('DFZ')
					DFZ->DFZ_CODDES := M->DFY_CODDES
				EndIf
			
				For nAux2 := 1 To Len(aHeader)
					If	aHeader[nAux2,10] != 'V'
						DFZ->(FieldPut(FieldPos(aHeader[nAux2,2]), aCols[nAux,nAux2]))
					EndIf
				Next				
			Else
				If DFZ->( MsSeek( xFilial('DFZ') + M->DFY_CODDES + GDFieldGet('DFZ_ITEM',nAux)))
					RecLock('DFZ',.F.)
					DbDelete()
				EndIf
			EndIf
			MsUnLock()
		Next
				
	EndIf
End Transaction

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF55Vld � Autor � Vitor Raspa          � Data � 10.Jan.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao de Campos                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF55Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF55Vld(cCampo)
Local lRet := .T.
Default cCampo := ReadVar()

If cCampo == 'M->DFY_CODDES'
	If !ExistChav("DFY",M->DFY_CODDES) .Or. !ExistCpo("DT7",M->DFY_CODDES)
		lRet := .F.
	EndIf
	
ElseIf cCampo == 'M->DFZ_CC'
	If !Empty(GDFieldGet('DFZ_CC2',n)) .And. M->DFZ_CC > GDFieldGet('DFZ_CC2',n)
		Help('',1,'TMSAF5503') //-- Centro de Custo DE deve ser menor que o Centro de Custo ATE
		lRet := .F.
	EndIf
	
ElseIf cCampo == 'M->DFZ_CC2'
	If !Empty(GDFieldGet('DFZ_CC',n)) .And. M->DFZ_CC2 < GDFieldGet('DFZ_CC',n)
		Help('',1,'TMSAF5504') //-- Centro de Custo ATE deve ser maior que o Centro de Custo DE
		lRet := .F.
	EndIf
	
ElseIf cCampo == 'M->DFZ_TPITEM'
	If M->DFZ_TPITEM == '2'
		GDFieldPut('DFZ_CLVL',Criavar('DFZ_CLVL'),n)
		GDFieldPut('DFZ_ITEMCT',Criavar('DFZ_ITEMCT'),n)
		GDFieldPut('DFZ_CC',Criavar('DFZ_CC'),n)
		GDFieldPut('DFZ_CC2',Criavar('DFZ_CC2'),n)
		lRet := .T.
	EndIf
	
ElseIf cCampo == 'M->DFZ_CONTA'
	If GDFieldGet("DFZ_TPITEM",n) == '2'
		lRet := ExistCpo("DFW",M->DFZ_CONTA,1)
	Else
		lRet := Ctb105Cta()
	EndIf
	
EndIf

Return(lRet)



/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �TMSAF55ConsCt�Autor  �Telso Carneiro      � Data �  31/10/07   ���
����������������������������������������������������������������������������͹��
���Desc.     �Consulta SXB que direciona o para o Conta contabel ou conta    ���
���          � especifica                                                    ���
����������������������������������������������������������������������������͹��
���Uso       � AP                                                            ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Function TMSAF55ConsCt()
Local lRet

If GdFieldGet("DFZ_TPITEM",N) == "1"
	lRet := ConPad1(,,,"CT1",,,.F.)
Else
	lRet := ConPad1(,,,"DFW",,,.F.)
EndIf

Return(lRet)
