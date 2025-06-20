#Include 'TmsA470.ch'
#Include 'Protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA470  � Autor � Deny B. de Mendonca   � Data �03.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tipos de Faturamento                                       ���
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
Function TMSA470()

Private cCadastro	:= STR0001 //'Tipos de Faturamento'
Private aRotina	:= MenuDef()

mBrowse( 6,1,22,75,'DUN')

RetIndex('DUN')
Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA470Mnt� Autor � Deny B. de MEndonca   � Data �03.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tipos de Faturamento                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA470Mnt(ExpC1,ExpN1,ExpN2)                              ���
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

Function TMSA470Mnt( cTmsAlias, nTmsReg, nTmsOpcx, aEstrutura )

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local aTmsButtons	:= {}
Local aTelOld		:= Iif( Type('aTela') == 'A', aClone( aTela ), {} )
Local aGetOld		:= Iif( Type('aGets') == 'A', aClone( aGets ), {} )
Local nOpca			:= 0
Local oTmsEnch

//-- Dialog
Local cCadOld		:= Iif( Type('cCadastro') == 'C', cCadastro, '' )
Local oTmsDlgEsp
//-- GetDados
Local aHeaOld		:= Iif( Type('aHeader') == 'A', aClone( aHeader ), {} )
Local aColOld		:= Iif( Type('aCols') == 'A', aClone( aCols ), {} )
Local aNoFields	:= {}
Local aYesFields	:= {}
//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
//-- Checkbox
Local oAllMark

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
//-- GetDados
Private aHeader		:= {}
Private aCols		:= {}
Private oTmsGetD
Private aTmsPosObj	:= {}
//-- Checkbox
Private lAllMark	:= .T.   // Usado para o controle da repeticao do campo memo DUN_MOTIVO. NAO TROQUE PARA LOCAL!!!


DEFAULT cTmsAlias 	:= 'DUN'
DEFAULT nTmsReg		:= 1
DEFAULT nTmsOpcx	:= 2
DEFAULT aEstrutura	:= {}


//-- Configura variaveis da Enchoice
RegToMemory( cTmsAlias, INCLUI )

cCadastro:= STR0001 //'Tipos de Faturamento'

Aadd( aTmsVisual, 'DUN_TIPFAT' )
Aadd( aTmsVisual, 'DUN_DESCRI' )

If INCLUI
	Aadd( aTmsAltera, 'DUN_TIPFAT' )
endif	        

aNoFields := aClone( aTmsVisual )

//-- Configura variaveis da GetDados
TMSFillGetDados( nTmsOpcx, 'DUN', 1, xFilial( 'DUN' ) + M->DUN_TIPFAT, { ||  DUN->(DUN_FILIAL + DUN_TIPFAT) },;
																			 { || .T. }, aNoFields,	aYesFields )
																			 
//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DUN_ITEM', 1 ) )
	GDFieldPut( 'DUN_ITEM', StrZero(1,Len(DUN->DUN_ITEM)), 1 )
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 35, 35, .T., .T. } )
AAdd( aObjects, { 265, 265, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch		:= MsMGet():New( cTmsAlias, nTmsReg, nTmsOpcx,,,, aTmsVisual, aTmsPosObj[1],aTmsAltera, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)

	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nTmsOpcx,'TMSA470LinOk','TmsA470TOk',"+DUN_ITEM",.T.,  ,  ,  ,  ,  ,  ,  ,  ,  )

ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar(oTmsDlgEsp,{||Iif( oTmsGetD:TudoOk(), (nOpca := 1,oTmsDlgEsp:End()), (nOpca :=0, .F.))},{||nOpca:=0,oTmsDlgEsp:End()},, aTmsButtons )

If nTmsOpcx != 2 .And. nOpcA == 1

	TMSA470Grv( M->DUN_TIPFAT, nTmsOpcx )
	
EndIf

If !Empty( cCadOld )
	cCadastro := cCadOld
EndIf

If	!Empty( aTelOld )
	aTela		:= aClone( aTelOld )
	aGets		:= aClone( aGetOld )
EndIf

If	!Empty( aHeaOld )
	aHeader	:= aClone( aHeaOld )
	aCols	:= aClone( aColOld )
EndIf

Return nOpca

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA470Lin� Autor � Deny B. de Mendonca   � Data �03.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA470Lin()                                               ���
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
Function TMSA470LinOk()

Local lRet		:= .T.
Local nItenAnt	:= aCols[n,aScan(aHeader,{|x| Trim(x[2])=="DUN_ITEM"})]
Local nA

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	If	lRet
		lRet := GDCheckKey( {'DUN_VALATE'}, 4 )
	EndIf

	If lRet
		aSort(aCols,,, { |x, y| x[2] < y[2] })
		For nA := 1 To Len(aCols)
			aCols[nA,aScan(aHeader,{|x| Trim(x[2])=="DUN_ITEM"})] := Strzero(nA,TamSX3("DUN_ITEM")[1])
		Next nA
		oTmsGetD:oBrowse:Refresh()
	EndIf

EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA470TOk� Autor � Deny B. de Mendonca   � Data �03.07.2002���
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
Function TmsA470TOk()

Local lRet		:= .T.
Local aFaixas	:=	{}
Local nValate	:=	0
Local nValant	:=	0
Local nA
Local nPosVal	:= aScan(aHeader,{|x| Trim(x[2])=="DUN_VALATE"})

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )
//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oTmsGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMSA470LinOk()
EndIf
//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	lRet := .F.
EndIf

If lRet
	aSort(aCols,,, { |x, y| x[2] < y[2] })
	For nA := 1 To Len(aCols)
		aCols[nA,aScan(aHeader,{|x| Trim(x[2])=="DUN_ITEM"})] := Strzero(nA,TamSX3("DUN_ITEM")[1])
	Next nA
EndIf
aFaixas := aCols
//-- Analise de as Faixas complentam um periodo de 31 dias
If lRet
	If Len(aFaixas) > 0
		aSort(aFaixas,,, { |x, y| x[2] < y[2] })
		For nA := 1 To Len(aFaixas)
			If !GDDeleted( nA )
				nValate += aFaixas[nA,nPosVal] - nValant //Iif(nA>1,nValate ,nposvalate)
				nValant := aFaixas[nA,nPosVal]
			EndIf
		Next nA
	Endif
	If nValate < 31
		Help( ' ', 1, 'TMSA47001') //"As faixas de datas informadas devem completar 31 dias.Verifique as faixas digitadas (DUN)"
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA470Grv� Autor � Deny B. de Mendonca  � Data �03.07.2002���
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

Static Function TMSA470Grv( cTipo, nTmsOpcx )

Local nCntFor	:= 0
Local nCntFo1	:= 0


If	nTmsOpcx == 5
	Begin Transaction

		DUN->( DbSetOrder( 1 ) )
		While DUN->( MsSeek( xFilial('DUN') + cTipo, .F. ) )
			//-- Exclui Complemento de Regioes .
			RecLock('DUN', .F., .T.)
			DUN->(DbDelete())
			MsUnLock()
		EndDo

	End Transaction
EndIf


If	(nTmsOpcx == 3) /* Inclusao */ .or. (nTmsOpcx == 4) /* Alteracao */
	Begin Transaction

		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor )

				If	DUN->( MsSeek( xFilial('DUN') + cTipo + GDFieldGet( 'DUN_ITEM', nCntFor ), .F. ) )
					RecLock('DUN', .F.)
				Else
					RecLock('DUN', .T.)
					
					DUN->DUN_FILIAL	 	:= xFilial('DUN')
					DUN->DUN_TIPFAT		:= cTipo
				EndIf

				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		    FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				
				MsUnLock()

			Else
				If	DUN->( MsSeek( xFilial('DUN') + cTipo + GDFieldGet( 'DUN_ITEM', nCntFor ), .F. ) )
					RecLock('DUN', .F., .T.)
					DUN->(DbDelete())
					MsUnLock()
				EndIf
			EndIf
		Next

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
								{ STR0003,'TMSA470Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSA470Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSA470Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSA470Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TM470MNU")
	ExecBlock("TM470MNU",.F.,.F.)
EndIf

Return(aRotina)

