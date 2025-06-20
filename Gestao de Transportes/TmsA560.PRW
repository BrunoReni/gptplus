#INCLUDE "TmsA560.ch"
#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmsA560  � Autor � Alex Egydio           � Data �21.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Agravacao de Risco                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TmsA560()

Private cCadastro	:= STR0001 //'Agravacao de Risco'
Private aRotina	:= MenuDef()

mBrowse( 6,1,22,75,'DUW')

RetIndex('DUW')

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA560Mnt� Autor � Alex Egydio           � Data �21.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Agravacao de Risco                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA560Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA560Mnt( cTmsAlias, nTmsReg, nTmsOpcx )
//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local aTmsButtons	:= {}
Local nOpca			:= 0
Local oTmsEnch
//-- Dialog
Local oTmsDlgEsp
//-- GetDados
Local aNoFields	:= {}
Local aYesFields	:= {}
//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
//-- GetDados
Private aHeader	:= {}
Private aCols		:= {}
Private oTmsGetD
Private aTmsPosObj:= {}

//-- Configura variaveis da Enchoice
RegToMemory(cTmsAlias,nTmsOpcx==3)

Aadd( aTmsVisual, 'DUW_TABSEG' )
Aadd( aTmsVisual, 'DUW_TPTSEG' )
Aadd( aTmsVisual, 'DUW_DESTPT' )
Aadd( aTmsVisual, 'DUW_COMSEG' )
Aadd( aTmsVisual, 'DUW_DESSEG' )

Aadd( aNoFields, 'DUW_TABSEG' )
Aadd( aNoFields, 'DUW_TPTSEG' )
Aadd( aNoFields, 'DUW_DESTPT' )
Aadd( aNoFields, 'DUW_COMSEG' )
Aadd( aNoFields, 'DUW_DESSEG' )

aTmsAltera := AClone( aTmsVisual )

//-- Configura variaveis da GetDados
TMSFillGetDados(	nTmsOpcx, 'DUW', 1,xFilial( 'DUW' ) + M->DUW_TABSEG + M->DUW_TPTSEG + M->DUW_COMSEG, { ||	DUW->DUW_FILIAL + DUW->DUW_TABSEG + DUW->DUW_TPTSEG + DUW->DUW_COMSEG }, ;
{ || .T. }, aNoFields,	aYesFields )

//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. nTmsOpcx == 3
	GDFieldPut( 'DUW_ITEM', StrZero(1,Len(DUW->DUW_ITEM)), 1 )
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 80, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch		:= MsMGet():New( cTmsAlias, nTmsReg, nTmsOpcx,,,, aTmsVisual, aTmsPosObj[1], aTmsAltera, 3,,,,,,.T. )
	//          MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nTmsOpcx,'TmsA560LinOk','TmsA560TOk','+DUW_ITEM',.T.,       ,       ,      ,    ,       ,         ,       ,     ,    )
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{||Iif( oTmsGetD:TudoOk(), (nOpca := 1,oTmsDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oTmsDlgEsp:End()},, aTmsButtons )

If nTmsOpcx != 2 .And. nOpcA == 1

	TmsA560Grv( nTmsOpcx )
	
EndIf

Return(nOpca)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA560Lin� Autor � Alex Egydio           � Data �21.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsA560Lin()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA560LinOk()

Local lRet		  := .T.
LOCAL nPosValAte := Ascan( aHeader, { |aField| aField[2] = "DUW_VALATE" } )
LOCAL nValAte	  := aCols[n][nPosValAte]

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DUW_VALATE' }, 4 )
EndIf

If lRet
	DO CASE
		//������������������������������������������Ŀ
		//� Esta deletado                            �
		//��������������������������������������������
		CASE 	aCols[n][Len( aHeader ) + 1]
				lRet := .T.
		//������������������������������������Ŀ
		//� Na primeira linha Valida p/ baixo  �
		//��������������������������������������
		CASE  n = 1
				lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.AND. ;
										(nValAte >= aLine[nPosValAte]	)}, 2 ) = 0
		//��������������������������������Ŀ
		//� Na ultima linha Valida p/ cima �
		//����������������������������������
		CASE  n = Len( aCols )
				lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.AND. ;
											(nValAte <= aLine[nPosValAte]	)}, 1, Len( Acols ) - 1 ) = 0
		OTHER
				//�����������������������Ŀ
				//� Valida Acima e Abaixo �
				//�������������������������
				lRet := Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ]	.AND. ;
											(nValAte <= aLine[nPosValAte] ) } , 1, n - 1 ) = 0
		
				lRet := lRet .AND. Ascan( aCols, { |aLine| ! aLine[ Len( aLine ) ] .AND. ;
											(nValAte >= aLine[nPosValAte] )	}, n + 1 ) = 0
	ENDCASE
EndIf

IF !lRet
	HELP(" ",1,"TMSA56001") //"Valor ate deve estar em ordem crescente."
ENDIF

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA560TOk� Autor � Alex Egydio           � Data �21.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok da GetDados                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA560TOk()

Local lRet		:= .T.
//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )
//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oTmsGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TmsA560LinOk()
EndIf
//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	lRet := .F.
EndIf
Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TmsA560Grv� Autor � Alex Egydio          � Data �21.08.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function TmsA560Grv( nTmsOpcx )

Local nCntFor	:= 0
Local nCntFo1	:= 0

If	nTmsOpcx == 5				//-- Excluir
	Begin Transaction

		DUW->( DbSetOrder( 1 ) )
		While DUW->( MsSeek( xFilial('DUW') + M->DUW_TABSEG + M->DUW_TPTSEG + M->DUW_COMSEG, .F. ) )
			//-- Exclui Agravacoes de Risco
			RecLock('DUW',.F.,.T.)
			DUW->(DbDelete())
			MsUnLock()
		EndDo

		EvalTrigger()
	End Transaction
EndIf


If	nTmsOpcx == 3 .Or. nTmsOpcx == 4			//-- Incluir ou Alterar
	Begin Transaction

		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor )

				DUW->( DbSetOrder( 1 ) )
				If	DUW->( MsSeek( xFilial('DUW') + M->DUW_TABSEG + M->DUW_TPTSEG + M->DUW_COMSEG + GDFieldGet( 'DUW_ITEM', nCntFor ), .F. ) )
					RecLock('DUW',.F.)
				Else
					RecLock('DUW',.T.)
					DUW->DUW_FILIAL	:= xFilial('DUW')
					DUW->DUW_TABSEG	:= M->DUW_TABSEG
					DUW->DUW_TPTSEG	:= M->DUW_TPTSEG
					DUW->DUW_COMSEG	:= M->DUW_COMSEG
				EndIf

				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				MsUnLock()

			Else
				DUW->( DbSetOrder( 1 ) )
				If	DUW->( MsSeek( xFilial('DUW') + M->DUW_TABSEG + M->DUW_TPTSEG + M->DUW_COMSEG + GDFieldGet( 'DUW_ITEM', nCntFor ), .F. ) )
					RecLock('DUW',.F.,.T.)
					DUW->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next

		EvalTrigger()
	End Transaction
EndIf
	
Return NIL

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
     
Private aRotina	:= {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003,'TMSA560Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSA560Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSA560Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSA560Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TM560MNU")
	ExecBlock("TM560MNU",.F.,.F.)
EndIf

Return(aRotina)
