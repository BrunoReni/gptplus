#Include 'TMSA650.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA650  � Autor � Richard Anderson      � Data �09.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Averbacao de Seguro por Cliente                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA650()

Private cCadastro	:= STR0001 //'Averba��o de Seguro por Cliente'
Private aRotina	:= MenuDef()

mBrowse( 6,1,22,75,'DV6' )

RetIndex('DV6')

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA650Mnt� Autor � Richard Anderson      � Data �09.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Manutencao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA650Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/

Function TMSA650Mnt( cTmsAlias, nTmsReg, nTmsOpcx ) 

//-- EnchoiceBar
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
Private oTmsGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aTmsPosObj := {}

//-- Configura variaveis da Enchoice
RegToMemory( cTmsAlias, INCLUI )

cCadastro := STR0001 //'Averba��o de Seguro por Cliente'

//-- Configura variaveis da GetDados
TMSFillGetDados( nTmsOpcx, 'DV7', 1, xFilial( 'DV7' ) + M->DV6_NUMAVB , { ||  DV7->(DV7_FILIAL + DV7_NUMAVB) },;
																		 { || .T. }, aNoFields,	aYesFields )

If Inclui
	GdFieldPut("DV7_ITEM",StrZero(1,Len(DV7->DV7_ITEM)),1)
Endif		
																			 
//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cTmsAlias, nTmsReg, nTmsOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )

	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nTmsOpcx, 'TMSA650LOk','TMSA650TOk',"+DV7_ITEM",.T.,  ,  ,  ,  ,  ,  ,  ,  ,  )
	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| Iif( oTmsGetD:TudoOk(),(nOpca := 1,oTmsDlgEsp:End()),nOpca := 0)},{||nOpca:=0,oTmsDlgEsp:End()} ) 

If nTmsOpcx != 2 
	If nOpcA == 1
		TMSA650Grv( nTmsOpcx )
		If __lSX8
			ConfirmSX8()
		EndIf
	ElseIf __lSX8
		RollBackSX8()
	EndIf		
EndIf

Return nOpcA

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA650LOk� Autor � Richard Anderson      � Data �09.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA650LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA650LOk()

Local lRet 		:= .T.
Local cChave	:= ""
Local aAreaSA1 	:= SA1->(GetArea())

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	If	lRet
		lRet := GDCheckKey( {'DV7_CLIREM','DV7_LOJREM','DV7_CLIDES','DV7_LOJDES', 'DV7_ESTDES'}, 4 )
	EndIf               
	
	If lRet  
		If !Empty(GDFieldGet('DV7_CLIREM',n)) 
			cChave:= GDFieldGet('DV7_CLIREM',n) + GDFieldGet('DV7_LOJREM',n)
			SA1->( DbSetOrder( 1 ) )
			If SA1->(! MsSeek( xFilial( 'SA1' ) + cChave ) )
				lRet := .F.
			EndIf
		EndIf		
		If !Empty(GDFieldGet('DV7_CLIDES',n)) 
			cChave:= GDFieldGet('DV7_CLIDES',n) + GDFieldGet('DV7_LOJDES',n)
			SA1->( DbSetOrder( 1 ) )
			If SA1->(! MsSeek( xFilial( 'SA1' ) + cChave ) )
				lRet := .F.
			EndIf
		EndIf		
		If !lRet
			Help( '', 1, 'REGNOIS' ) //"Nao existe registro relacionado a este codigo"	
		EndIf
	EndIf
EndIf

RestArea(aAreaSA1)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA650TOk� Autor � Richard Anderson      � Data �09.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok da GetDados                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA650TOk()

Local lRet     := .T.
Local cSeek    := ''
Local aAreaDV6 := DV6->( GetArea() )

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analise averbacoes do devedor em vig�ncia
If lRet
	DV6->( DbSetOrder( 2 ) )
	DV6->( MsSeek( cSeek := xFilial( 'DV6' ) + M->DV6_CLIDEV + M->DV6_LOJDEV + M->DV6_COMSEG ) ) 
	While DV6->( !Eof() .And. DV6_FILIAL+DV6_CLIDEV+DV6_LOJDEV+DV6_COMSEG == cSeek )
	
     If DV6->DV6_NUMAVB <> M->DV6_NUMAVB .And. ;
        ( Empty(DV6->DV6_FIMVIG) .Or. M->DV6_INIVIG <= DV6->DV6_FIMVIG .Or. If(!Empty(M->DV6_FIMVIG),M->DV6_FIMVIG <= DV6->DV6_INIVIG,.F.) ) 
		  Help( '', 1, 'TMSA65004' ) //-- Ja existe averbacao de seguro em vig�ncia para este devedor
		  lRet := .F.
		  Exit
		EndIf			
		DV6->( DbSkip() )
	EndDo
EndIf			

//-- Analisa o linha ok.
If lRet
	lRet := TMSA650LOk()
EndIf

RestArea( aAreaDV6 )

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA650Grv� Autor � Richard Anderson     � Data �09.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function TMSA650Grv( nTmsOpcx )

Local nCntFor	:= 0
Local nCntFo1	:= 0    

DV7->( DbSetOrder( 1 ) )

If	nTmsOpcx == 5
                                           
	Begin Transaction
	RecLock('DV6', .F.)   // Exclui o Cabecalho
	DbDelete()
	MsUnLock()
	
	While DV7->( MsSeek( xFilial('DV7') + M->DV6_NUMAVB, .F. ) )
		//-- Exclui Averbacao de Seguro por Cliente
		RecLock('DV7', .F.)
		DbDelete()
		MsUnLock()
	EndDo
	End Transaction
Else
	Begin Transaction
	
	RecLock( "DV6", (nTmsOpcx==3) )
	
	Aeval( dbStruct(), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
													   xFilial( "DV6" ), M->&(aFieldName[1]) ) ) } )
	
	For nCntFor := 1 To Len( aCols )
		If	!GDDeleted( nCntFor ) 

			If	DV7->( MsSeek( xFilial('DV7') + M->DV6_NUMAVB + GDFieldGet( 'DV7_ITEM', nCntFor ), .F. ) )
				RecLock('DV7', .F.)
			Else
				RecLock('DV7', .T.)
				DV7->DV7_FILIAL := xFilial('DV7')
				DV7->DV7_NUMAVB := M->DV6_NUMAVB
			EndIf
			
			For nCntFo1 := 1 To Len(aHeader)
				If	aHeader[nCntFo1,10] != 'V'
					FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
				EndIf
			Next 
			MsUnLock()
		Else
			If	DV7->( MsSeek( xFilial('DV7') + M->DV6_NUMAVB + GDFieldGet( 'DV7_ITEM', nCntFor ), .F. ) )
				RecLock('DV7', .F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next
	End Transaction
EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA650Vld� Autor � Richard Anderson     � Data �09.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA650Vld()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA650Vld()

Local lRet    := .T.
Local cCampo  := ReadVar()
Local cChave  := ''
Local cNomCli := ''

If cCampo $ 'M->DV7_CLIREM|M->DV7_LOJREM'
	If cCampo == 'M->DV7_CLIREM'
		If !Empty( M->DV7_CLIREM ) .And. !Empty( GDFieldGet( 'DV7_LOJREM', n ) )
			cChave := M->DV7_CLIREM + GDFieldGet( 'DV7_LOJREM', n ) 
		EndIf			
	Else
		If !Empty( M->DV7_LOJREM )
			cChave := GDFieldGet( 'DV7_CLIREM', n ) + M->DV7_LOJREM
		EndIf			
	EndIf	
	If Empty( cChave )
		cNomCli := Space( Len( SA1->A1_NOME ) )
		GDFieldPut( 'DV7_CLIREM', Space( Len( DV7->DV7_CLIREM ) ), n )
		GDFieldPut( 'DV7_LOJREM', Space( Len( DV7->DV7_LOJREM ) ), n )
	Else		
		If cChave == GDFieldGet( 'DV7_CLIDES', n ) + GDFieldGet( 'DV7_LOJDES', n )
			GDFieldPut( 'DV7_LOJREM', Space( Len( DV7->DV7_LOJREM ) ), n )
			Help( '', 1, 'TMSA65003' ) //-- Remetente e destinat�rio n�o podem ser iguais
			lRet := .F.
		Else			
			SA1->( DbSetOrder( 1 ) )
			If SA1->(! MsSeek( xFilial( 'SA1' ) + cChave ) )
				Help( '', 1, 'REGNOIS' ) //"Nao existe registro relacionado a este codigo"
				lRet := .F.
			Else
				cNomCli := SA1->A1_NOME			
			EndIf		
		EndIf			
	EndIf		
	GDFieldPut( 'DV7_NOMREM', cNomCli, n )
ElseIf cCampo $ 'M->DV7_CLIDES|M->DV7_LOJDES'
	If cCampo == 'M->DV7_CLIDES'
		If !Empty( M->DV7_CLIDES ) .And. !Empty( GDFieldGet( 'DV7_LOJDES', n ) )
			cChave := M->DV7_CLIDES + GDFieldGet( 'DV7_LOJDES', n ) 
		EndIf			
	Else
		If !Empty( M->DV7_LOJDES )
			cChave := GDFieldGet( 'DV7_CLIDES', n ) + M->DV7_LOJDES
		EndIf			
	EndIf	
	If Empty( cChave )
		cNomCli := Space( Len( SA1->A1_NOME ) )
		GDFieldPut( 'DV7_CLIDES', Space( Len( DV7->DV7_CLIDES ) ), n )
		GDFieldPut( 'DV7_LOJDES', Space( Len( DV7->DV7_LOJDES ) ), n )
	Else		
		If cChave == GDFieldGet( 'DV7_CLIREM', n ) + GDFieldGet( 'DV7_LOJREM', n )
			GDFieldPut( 'DV7_LOJDES', Space( Len( DV7->DV7_LOJDES ) ), n )
			Help( '', 1, 'TMSA65003' ) //-- Remetente e destinat�rio n�o podem ser iguais
			lRet := .F.
		Else			
			SA1->( DbSetOrder( 1 ) )
			If SA1->(! MsSeek( xFilial( 'SA1' ) + cChave ) )
				Help( '', 1, 'REGNOIS' ) //"Nao existe registro relacionado a este codigo"
				lRet := .F.
			Else	
				cNomCli := SA1->A1_NOME						
			EndIf		
		EndIf			
	EndIf		
	GDFieldPut( 'DV7_NOMDES', cNomCli, n )
EndIf	

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA650When� Autor � Richard Anderson     � Data �11.04.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Condicoes de edicao                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA650Vhen()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA650When()

Local lRet    := .T.
Local cCampo  := ReadVar()

If cCampo == 'M->DV7_LOJREM'
	lRet := !Empty( GDFieldGet( 'DV7_CLIREM', n ) ) 
ElseIf cCampo $ 'M->DV7_CLIDES|M->DV7_LOJDES'
	If !Empty( GDFieldGet( 'DV7_ESTDES', n ) )
		Help('', 1, 'TMSA65002' ) //-- Este campo somente poder� ser preenchido caso a UF Destino n�o esteja preenchida
		lRet := .F.
	ElseIf cCampo == 'M->DV7_LOJDES'
		lRet := !Empty( GDFieldGet( 'DV7_CLIDES', n ) )
	EndIf
ElseIf cCampo $ 'M->DV7_ESTDES'      
	If !Empty( GDFieldGet( 'DV7_CLIDES', n ) )
		Help('', 1, 'TMSA65001' ) //-- Este campo somente poder� ser preenchido caso o destinat�rio n�o esteja preenchido
		lRet := .F.
	EndIf
EndIf

Return lRet			

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
								{ STR0003,'TMSA650Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSA650Mnt',0,3,0,NIL},; //'Incluir' 
								{ STR0005,'TMSA650Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSA650Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TM650MNU")
	ExecBlock("TM650MNU",.F.,.F.)
EndIf

Return(aRotina)

