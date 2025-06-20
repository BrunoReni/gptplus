#Include "PROTHEUS.CH"
#Include "TMSAF20.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSAF20  � Autor � Vitor Raspa           � Data � 10.Jan.07  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Despesas X Contas Contabeis                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Uso       � TMS - Gestao de Transportes                                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function TMSAF20() 

Private cCadastro :=     STR0001                           //-- Despesas X Contas Contabeis
Private aRotina   := { { STR0002 ,"AxPesqui"	 , 0, 1 } , ; //-- Pesquisar
					        { STR0003 ,"TMSAF20Mnt", 0, 2 } , ; //-- Visualizar
      				     { STR0004 ,"TMSAF20Mnt", 0, 3 } , ; //-- Incluir
		      		     { STR0005 ,"TMSAF20Mnt", 0, 4 } , ; //-- Alterar
				    	     { STR0006 ,"TMSAF20Mnt", 0, 5 }   } //-- Excluir


MBrowse( ,,,, 'DF9' )

RetIndex( 'DF9' )

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF20Mnt � Autor � Vitor Raspa        � Data �  10.Jan.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Manutencao das Despesas X Contas Contabeis                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSAF20Mnt( ExpC1,ExpN1,ExpN2 )                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 - Alias                                               ���
���          �ExpC2 - Registro                                            ���
���          �ExpC3 - Opcao Selecionada                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nil                                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �TMSAF20                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF20Mnt( cAlias, nReg, nOpc )

Local oEnchoice    := Nil
Local lOk          := .F.
Local oDlg         := Nil
Local aSize        := {}
Local aObjects     := {}
Local aInfo        := {}
Local aNoFields    := { 'DFA_CODDES' }
Local nMaxLin      := 999
Local aButtons     := {}
Local aRateio      := {}
Local nPosCC       := 0

Private aTela[0][0]
Private aGets[0]
Private aHeader    := {}
Private aCols      := {}
Private aHeaderDFB := {}
Private aColsDFB   := {}
Private aSetKey    := {}

Default cAlias     := 'DF9'
Default nReg       := 1
Default nOpc       := 1


Aadd( aSetKey,  { VK_F4      , { || TMSAF20Rat(nOpc) }                    } )
Aadd( aButtons, { "RELATORIO", { || TMSAF20Rat(nOpc) }, STR0007 , STR0008 } ) //"Definicao da Faixa -  <F4>" ### "Def. Faixa"

If nOpc == 3 .Or. nOpc == 4

	Aadd( aSetKey, { VK_F5    , {|| TMSSelField( 'DOCTMS', 'M->DF9_DOCCUS' ) }                                             } )
	Aadd( aButtons,{ "BMPPOST", {|| TMSSelField( 'DOCTMS', 'M->DF9_DOCCUS' ) }, STR0009 , STR0010                          } ) //"Tipos de Documentos - <F5>" ### "Tp.Docto."
	Aadd( aSetKey, { VK_F6    , {|| TMSSelField( 'SERTMS', 'M->DF9_SRTCUS' ) }                                             } )
	Aadd( aButtons,{ "SDUREPL", {|| TMSSelField( 'SERTMS', 'M->DF9_SRTCUS' ) }, "Tipos de Servi�o - <F6>"   , "Tp.Servi�o" } ) 
	Aadd( aSetKey, { VK_F7    , {|| TMSSelField( 'TIPTRA', 'M->DF9_TPTCUS' ) }                                             } )
	Aadd( aButtons,{ "CARGA"  , {|| TMSSelField( 'TIPTRA', 'M->DF9_TPTCUS' ) }, "Tipos de Transporte - <F7>", "Tp.Transp"  } ) 
	
EndIf

//-- Inicializa Teclas de Atalhos

TmsKeyOn( aSetKey )

//��������������������������������������������������������Ŀ
//�Verifica se o registro n�o est� em uso por outra esta��o�
//����������������������������������������������������������
If nOpc == 4 .Or. nOpc == 5 //-- 4=Alteracao ; 5=Exclusao

	If !SoftLock( "DF9" )

		Return Nil

	EndIf	

EndIf

//�������������������������������Ŀ
//�Configura variaveis da Enchoice�
//���������������������������������
RegToMemory( cAlias, nOpc == 3 )

//�����������������������������������������Ŀ
//�Configura variaveis da GetDados Principal�
//�������������������������������������������
TMSFillGetDados( nOpc, 'DFA', 1, xFilial( 'DFA' ) + M->( DF9_CODDES ) , ; 
				{ ||  DFA->(DFA_FILIAL + DFA_CODDES ) }               , ;
				{ || .T. }, aNoFields )

//�������������������������Ŀ
//�Preenche o Numero do Item�
//���������������������������

If Empty( GDFieldGet( "DFA_ITEM", 1 ) )

	GDFieldPut( "DFA_ITEM", StrZero( 1, Len( DFA->DFA_ITEM ) ), 1 )

EndIf

//������������������������Ŀ
//�aCols e aHeader - Rateio�
//��������������������������
TMSAF20Ini( nOpc, M->DF9_CODDES )

If nOpc == 2 .Or. nOpc == 4

	nPosCC := GdFieldPos( "DFA_CONTA" )

	//-- Ordena o array

	Asort( aCols,,,{ |x,y| x[ nPosCC ] < y[ nPosCC ] } )

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
									nOpc, 'TMSAF20LOk','AllWaysTrue()','+DFA_ITEM',;
									IIf((nOpc==3 .Or. nOpc==4),.T.,Nil),,,,nMaxLin)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| If(Obrigatorio(aGets,aTela) .And. oGetDados:TudoOk() .And. TMSAF20TOk(nOpc), ( lOk := .T., oDlg:End()), lOk := .F. )} ,;
													{|| lOk := .F., oDlg:End()},,aButtons) CENTERED

If nOpc != 2 .And. lOk

	TMSAF20Grv( nOpc )

EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff( aSetKey )

DF9->( MsUnLock() )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF20TOk � Autor � Vitor Raspa          � Data � 10.Jan.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Tela                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20TOk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF20TOk( nOpc )

Local lRet       := .T.
Local nAux       := 0
Local nDel       := 0
Local nPosValAte := AScan( aHeaderDFB, { | x | AllTrim( x[ 2 ] ) == 'DFB_VALATE' } )

If nOpc == 3 .Or. nOpc == 4

	If Len( aColsDFB ) == 0 .Or. ( Len(aColsDFB ) == 1 .And. Empty( aColsDFB[ 1, nPosValAte ] ) )

		Help( '', 1, 'TMSAF2002' ) //-- "Rateio nao informado para esta despesa"

		lRet := .F.

	Else

		For nAux := 1 To Len( aColsDFB )

			If aColsDFB[ nAux, Len( aHeaderDFB ) + 1 ]

				nDel++

			EndIf

		Next

		If nDel == Len( aColsDFB )

			Help( '', 1, 'TMSAF2002' ) //-- "Rateio nao informado para estaa despesa"

			lRet := .F.

		EndIf

	EndIf

EndIf

Return( lRet )	
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF20LOk � Autor � Vitor Raspa          � Data � 10.Jan.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok na validacao da tela principal                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF20LOk( nOpc )

Local lRet      := .T.
Local aCpoCheck := { 'DFA_CONTA', 'DFA_IDENCT' }
Local aCpoNoEmp := { 'DFA_CC'   , 'DFA_CC2'    }
Local cConta    := GDFieldGet( 'DFA_CONTA' , n )
Local cItemCta  := GDFieldGet( 'DFA_ITEMCT', n )
Local cClVl     := GDFieldGet( 'DFA_CLVL'  , n )
Local cCCDe     := GDFieldGet( 'DFA_CC'    , n )
Local cCCAte    := GDFieldGet( 'DFA_CC2'   , n ) 
Local lTipoCt1  := GdFieldGet( 'DFA_TPITEM', n ) == '1'
Local cIDConta  := GDFieldGet( 'DFA_IDENCT', n ) 
Local nCtn      := 0

If lTipoCt1

	Aadd( aCpoCheck, 'DFA_ITEMCT' )
	Aadd( aCpoCheck, 'DFA_CLVL'   )
	Aadd( aCpoCheck, 'DFA_CC'     )	  
	Aadd( aCpoCheck, 'DFA_CC2'    )	  

EndIf

//-- Analisa se ha itens duplicados na GetDados.
If !GDDeleted( n ) .And. ( lRet := MaCheckCols( aHeader, aCols, n ) )

	lRet := GDCheckKey( aCpoCheck, 4 )	

EndIf

//-- Analisa se ha itens vazios na GetDados.
If lRet .And. !GDDeleted( n ) .And. lTipoCt1

	For nCtn := 1 To Len( aCpoNoEmp )

		lRet := !Empty( GdFieldGet( aCpoNoEmp[ nCtn ], n ) )

		If !lRet

			Help( '', 1, 'OBRIGAT',, aHeader[ GdFieldPos( aCpoNoEmp[ nCtn ] ), 1 ], 4, 0 )

			Exit

		EndIf

	Next

EndIf

//-- Valida o intervalo de digitacao dos Centros de Custo
If lRet .And. !GDDeleted( n ) .And. lTipoCt1

	If n == 1 

		lRet :=            Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, n + 1, Len( aCols ) ) == 0
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, n + 1, Len( aCols ) ) == 0	
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, n + 1, Len( aCols ) ) == 0		

	ElseIf n == Len(aCols)

		lRet :=            Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, 1, Len( aCols ) - 1 ) == 0
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, 1, Len( aCols ) - 1 ) == 0	
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, 1, Len( aCols ) - 1 ) == 0		

	Else

		lRet :=            Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, n + 1, Len( aCols ) ) == 0
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, n + 1, Len( aCols ) ) == 0	
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, n + 1, Len( aCols ) ) == 0		

		//-- Seta para Cima
		lRet :=            Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, 1, n - 1 ) == 0
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte <= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, 1, n - 1 ) == 0	
		lRet := lRet .And. Ascan( aCols, { |aLine| !aLine[ Len( aLine ) ] .And. cConta + cItemCta + cClVl + cIDConta == aLine[ GDFieldPos( 'DFA_CONTA' ) ] + aLine[ GDFieldPos( 'DFA_ITEMCT' ) ] + aLine[ GDFieldPos( 'DFA_CLVL' ) ] + aLine[ GDFieldPos( 'DFA_IDENCT' ) ] .And. cCCDe  <= aLine[ GDFieldPos( 'DFA_CC' ) ] .And. cCCAte >= aLine[ GDFieldPos( 'DFA_CC2' ) ] }, 1, n - 1 ) == 0		

	EndIf

	If !lRet

		Help( '', 1, 'TMSAF2005' ) //-- "O Centro de Custo esta dentro de um intervalo ja lancado!"

	EndIf

EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF20Grv � Autor � Vitor Raspa          � Data � 10.Jan.07���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao dos Dados                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20Grv()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF20Grv(nOpc)

Local nAux	:= 0
Local nAux2	:= 0

Begin Transaction

	//-- Exclusao

	If nOpc == 5	

		//-- Itens do Rateio

		DFB->( DbSetOrder( 1 ) )

		While DFB->( MsSeek( xFilial( 'DFA' ) + DF9->DF9_CODDES ) )

			RecLock( 'DFB', .F. )
			DbDelete()
			MsUnLock()

		EndDo		

		//-- Itens Desp. X Contas Contab.

		DFA->( DbSetOrder( 1 ) )

		While DFA->( MsSeek( xFilial( 'DFA' ) + DF9->DF9_CODDES ) )

			RecLock( 'DFA', .F. )
			DbDelete()
			MsUnLock()

		EndDo

		//-- Cabecalho Desp. X Contas Contab.

		RecLock( 'DF9', .F. )
		DbDelete()
		MsUnLock()

	Else		

		//-- Cabecalho

		RecLock( 'DF9', nOpc == 3 )

		DF9->( AEval( 	dbStruct(), ; 
						{ | aFieldName, nI | FieldPut( nI, If( 'FILIAL' $ aFieldName[ 1 ], xFilial( "DF9" ), M->&( aFieldName[ 1 ] ) ) ) } ) )

		//-- Itens Desp. X Contas Contab.

		For nAux := 1 To Len( aCols )

			DFA->( dbSetOrder( 1 ) )

			If	!GDDeleted( nAux ) 

				If	DFA->( MsSeek( xFilial( 'DFA' ) + M->DF9_CODDES + GDFieldGet( 'DFA_ITEM', nAux ) ) )

					RecLock( 'DFA', .F. )

				Else

					RecLock( 'DFA', .T. )

					DFA->DFA_FILIAL := xFilial( 'DFA' )
					DFA->DFA_CODDES := M->DF9_CODDES

				EndIf
			
				For nAux2 := 1 To Len( aHeader )

					If	aHeader[ nAux2, 10 ] != 'V'

						DFA->( FieldPut( FieldPos( aHeader[ nAux2, 2 ] ), aCols[ nAux, nAux2 ] ) )

					EndIf

				Next				

			Else

				If DFA->( MsSeek( xFilial( 'DFA' ) + M->DF9_CODDES + GDFieldGet( 'DFA_ITEM', nAux ) ) )

					RecLock( 'DFA', .F. )
					DbDelete()

				EndIf

			EndIf

			MsUnLock()

		Next
		
		//-- Itens do Rateio		

		For nAux := 1 To Len( aColsDFB )

			DFB->(dbSetOrder( 1 ) )

			If	!aColsDFB[ nAux, Len( aHeaderDFB ) + 1 ]

				If	DFB->( MsSeek( xFilial( 'DFB' ) + M->DF9_CODDES + aColsDFB[ nAux, aScan( aHeaderDFB, { | x | AllTrim( x[ 2 ] ) == 'DFB_ITEM' } ) ] ) )

					RecLock( 'DFB', .F. )

				Else

					RecLock( 'DFB', .T. )

					DFB->DFB_FILIAL := xFilial( 'DFB' )
					DFB->DFB_CODDES := M->DF9_CODDES

				EndIf

				For nAux2 := 1 To Len( aHeaderDFB )

					If aHeaderDFB[ nAux2, 10 ] != 'V'

						DFB->( FieldPut( FieldPos( aHeaderDFB[ nAux2, 2 ] ), aColsDFB[ nAux, nAux2 ] ) )

					EndIf

				Next				

			Else

				If DFB->( MsSeek( xFilial( 'DFB' ) + M->DF9_CODDES + aColsDFB[ nAux, aScan( aHeaderDFB, { | x | AllTrim( x[ 2 ] ) == 'DFB_ITEM' } ) ] ) )

					RecLock( 'DFB', .F. )
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
���Fun��o    �TMSAF20Vld � Autor � Vitor Raspa          � Data � 10.Jan.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao de Campos                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20Vld()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSAF20Vld(cCampo)

Local lRet := .T.
Local nCnt

Default cCampo := ReadVar()

If cCampo == 'M->DF9_CODDES'

	If !ExistChav( "DF9", M->DF9_CODDES ) .Or. !ExistCpo( "DT7", M->DF9_CODDES )

		lRet := .F.

	EndIf

ElseIf cCampo == 'M->DF9_CARREP'

	If M->DF9_CARREP == '2' 

		M->DF9_PERREP := 0

		lRet := .T.

	EndIf

ElseIf cCampo == 'M->DF9_RATEIO'

	If M->DF9_RATEIO <> '7'

		For nCnt:= 1 To Len(aCols)

			GDFieldPut( 'DFA_IDENCT', '0', nCnt )

		Next       

		SysRefresh()

		lRet := .T.

	EndIf
	
ElseIf cCampo == 'M->DFA_CC'

	If !Empty( GDFieldGet( 'DFA_CC2', n ) ) .And. M->DFA_CC > GDFieldGet( 'DFA_CC2', n )

		Help( '', 1, 'TMSAF2003' ) //-- Centro de Custo DE deve ser menor que o Centro de Custo ATE

		lRet := .F.

	EndIf

ElseIf cCampo == 'M->DFA_CC2'

	If !Empty( GDFieldGet( 'DFA_CC', n ) ) .And. M->DFA_CC2 < GDFieldGet( 'DFA_CC', n )

		Help( '', 1, 'TMSAF2004' ) //-- Centro de Custo ATE deve ser maior que o Centro de Custo DE

		lRet := .F.

	EndIf

ElseIf cCampo == 'M->DFA_TPITEM'

	If M->DFA_TPITEM == '2'

		GDFieldPut( 'DFA_CLVL'  , Criavar( 'DFA_CLVL'  ), n )		
		GDFieldPut( 'DFA_ITEMCT', Criavar( 'DFA_ITEMCT'), n )		
		GDFieldPut( 'DFA_CC'    , Criavar( 'DFA_CC'    ), n )
		GDFieldPut( 'DFA_CC2'   , Criavar( 'DFA_CC2'   ), n )

		lRet := .T.

	EndIf	

ElseIf cCampo == 'M->DFA_CONTA'

	If GDFieldGet( "DFA_TPITEM", n ) == '2'

		lRet := ExistCpo( "DFW", M->DFA_CONTA, 1 )

	Else

		lRet := Ctb105Cta()		

	EndIf

ElseIf cCampo == 'M->DFA_CONTA2'

	If GDFieldGet( "DFA_TPITEM", n ) == '2'

		lRet := ExistCpo( "DFW", M->DFA_CONTA2, 1 )

	Else

		lRet := Ctb105Cta()		

	EndIf	
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF20Rat   � Autor � Vitor Raspa        � Data � 11.Jan.07���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rateio dos totais dos centros de custo                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20Rat( nExpN1 )                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSAF20Rat(nOpc)

Local lOk        := .F.
Local oDlgRat    := NIL
Local aRetBox    := RetSx3Box( Posicione( 'SX3', 2, 'DF9_RATEIO', 'X3CBox()' ),,, Len( DF9->DF9_RATEIO ) )
Local nPosValAte := 0
Local cCodDes    := ''
Local cDscDes    := ''
//Local cSerTMS    := ''
//Local cTipTra    := '' 
Local cRateio    := ''
Local nAux       := 0
Local oGetDadDFB := NIL

//-- Salva o aHeader e aCols principais
SaveInter()

aHeader := AClone( aHeaderDFB )
aCols   := AClone( aColsDFB   )

cCodDes := M->DF9_CODDES	
cDscDes := M->DF9_DSCDES
//cSerTMS := M->DF9_SERTMS
//cTipTra := M->DF9_TIPTRA
cRateio := M->DF9_RATEIO

//-- Complementa a descricao da coluna 'Ate'

nPosValAte := Ascan( aHeaderDFB, { | aField | aField[ 2 ] = "DFB_VALATE" } )

aHeader[ nPosValAte, 1 ] := AllTrim( RetTitle( 'DFB_VALATE' ) ) + ' - ' + AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == cRateio } ), 3 ] )

//��������������������Ŀ
//� TRATAMENTO DA TELA �
//����������������������

DEFINE MSDIALOG oDlgRat FROM 094, 104 TO 380,650 TITLE STR0013 Of oMainWnd PIXEL //"Rateio X Despesa"

@ 035, 005 Say RetTitle('DF9_CODDES') + ': ' Of oDlgRat PIXEL SIZE 150,009
@ 033, 050 MsGet cCodDes When .F. Of oDlgRat PIXEL SIZE 060,009

@ 045, 005 Say RetTitle('DF9_DSCDES') + ': ' Of oDlgRat PIXEL SIZE 150,009
@ 045, 050 MsGet cDscDes When .F. Of oDlgRat PIXEL SIZE 100,009

oGetDadDFB := MSGetDados():New( 060, 002, 125, 270, nOpc,'TMSF20RtLOk()', 'AllWaysTrue()', '+DFB_ITEM', IIf( nOpc == 3 .Or. nOpc == 4, .T., Nil ) )

ACTIVATE MSDIALOG oDlgRat ON INIT EnchoiceBar( oDlgRat, ;
											   { || If( oGetDadDFB:TudoOk(), ( lOk := .T., oDlgRat:End() ), ( lOk := .F. ) ) }, ;
											   { || lOk := .F., oDlgRat:End() } ) CENTERED
If lOk

	aColsDFB := {}
	aColsDFB := aClone( aCols )

EndIf

//-- Restaura o aHeader e aCols principais

RestInter()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSF20RtLOk  � Autor � Vitor Raspa        � Data � 11.Jan.07���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao das linhas de rateio                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSF20RtLOk()                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TMSF20RtLOk()

Local lRet       := .T.
Local nPosValAte := Ascan( aHeader, { | aField | aField[ 2 ] = "DFB_VALATE" } )
Local nValAte    := aCols[ n ][ nPosValAte ]

If aCols[ n ][ Len( aHeader ) + 1 ]

	lRet := .T.

Else

	If n == 1

		//������������������������������������Ŀ
		//� Na primeira linha Valida p/ baixo  �
		//��������������������������������������

		lRet := Ascan( aCols, { | aLine | !aLine[ Len( aLine ) ] .And. nValAte >= aLine[ nPosValAte ] }, 2 ) == 0

	ElseIf n == Len( aCols )

		//��������������������������������Ŀ
		//� Na ultima linha Valida p/ cima �
		//����������������������������������

		lRet := Ascan( aCols, { | aLine | !aLine[ Len( aLine ) ] .And. nValAte <= aLine[ nPosValAte ] }, 1, Len( aCols ) - 1 ) == 0
			
	Else

		//�����������������������Ŀ
		//� Valida Acima e Abaixo �
		//�������������������������

		lRet :=            Ascan( aCols, { | aLine | !aLine[ Len( aLine ) ] .And. nValAte <= aLine[ nPosValAte ] }, 1, n - 1 ) == 0
		lRet := lRet .And. Ascan( aCols, { | aLine | !aLine[ Len( aLine ) ] .And. nValAte >= aLine[ nPosValAte ] }, n + 1    ) == 0

	EndIf

EndIf

If !lRet

	Help( " ", 1, "TMSAF2001" ) //"Campo 'Valor Ate' Invalido ou ja existente"

EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAF20Ini   � Autor � Vitor Raspa        � Data � 11.Jan.07���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa as variaveis referente ao rateio                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAF20Ini()                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TMSAF20Ini( nOpc, cCodDes )

Local nAux     := 0
Local nPosItem := 0
Local aFldDFB  := {}
Local nI	   := 0

Default cCodDes := ''

//���������������������Ŀ
//� Montagem do aHeader �
//�����������������������

If Empty( aHeaderDFB )

	aFldDFB := ApBuildHeader("DFB")
	For nI := 1 To Len(aFldDFB)
		aAdd(aHeaderDFB, aFldDFB[nI])
	Next

EndIf

aSize(aFldDFB, 0)
aFldDFB := Nil

nPosItem := AScan( aHeaderDFB, { | x | AllTrim( x[ 2 ] ) == 'DFB_ITEM' } )

//�������������������Ŀ
//� Montagem do aCols �
//���������������������

If Empty( aColsDFB )

	If nOpc == 3

		AAdd( aColsDFB, Array( Len( aHeaderDFB ) + 1 ) )

		For nAux := 1 to Len( aHeaderDFB )

			aColsDFB[ 1 ][ nAux ] := CriaVar( aHeaderDFB[ nAux ][ 2 ] )			

		Next nAux

		aColsDFB[ Len( aColsDFB ) ][ nPosItem              ] := StrZero( 1, Len( DFB->DFB_ITEM ) )
		aColsDFB[ 1               ][ Len( aHeaderDFB ) + 1 ] := .F.

	Else		

		aColsDFB := {} 

		DFB->( DbSetOrder( 1 ) ) //-- DFB_FILIAL+DFB_CODDES+DFB_ITEM

		If DFB->( MsSeek( xFilial( 'DFB' ) + cCodDes ) )

			While !DFB->( Eof() ) .And. DFB->( DFB_FILIAL + DFB_CODDES ) == xFilial( 'DFB' ) + cCodDes 

				AAdd( aColsDFB, Array( Len( aHeaderDFB ) + 1 ) )

				For nAux := 1 To Len( aHeaderDFB )

					If	aHeaderDFB[ nAux, 10 ] != "V"

						aColsDFB[ Len( aColsDFB ), nAux ] := DFB->( FieldGet( FieldPos( aHeaderDFB[ nAux, 2 ] ) ) )

					Else				

						aColsDFB[ Len( aColsDFB ), nAux ] := CriaVar( aHeaderDFB[ nAux, 2 ] )

					EndIf		

				Next

				aColsDFB[ Len( aColsDFB ), Len( aHeaderDFB ) + 1 ] := .F.

				DFB->( dbSkip() )

			EndDo

		EndIf

	EndIf

EndIf

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �TMSAF20CCt�Autor     �Telso Carneiro      � Data �  30/10/07   ���
����������������������������������������������������������������������������͹��
���Desc.     �Consulta SXB que direciona o para o Conta contabel ou conta    ���
���          � especifica                                                    ���
����������������������������������������������������������������������������͹��
���Uso       � AP                                                            ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Function TMSAF20CCt()

Local lRet

If GdFieldGet( "DFA_TPITEM", N ) == "1"

	lRet := ConPad1( ,,, "CT1",,, .F. )

Else

	lRet := ConPad1( ,,, "DFW",,, .F. )

EndIf

Return( lRet)
