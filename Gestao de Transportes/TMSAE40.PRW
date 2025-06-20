#INCLUDE 'TMSAE40.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE40  � Autor � Ana Cristina          � Data �04.03.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de "Produtos x Embarcadora"                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE40()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE40(nOpcx)

Local   aRotAux   := If(Type("aRotina") == "A",AClone(aRotina),{})

Private cCadastro := STR0001 //"Produtos x Embarcadora"
Private aRotina	:= MenuDef()

Default nOpcx     := 0

DE7->(dbSetOrder(1))

If nOpcx == 0
	mBrowse(6,1,22,75,'DE7')
Else
	TMSAE40Mnt('DE7',DE7->(Recno()),nOpcx)
EndIf		

RetIndex('DE7')

If Len(aRotAux) > 0
	aRotina := AClone(aRotAux)
EndIf

Return( Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE40Mnt� Autor �Ana Cristina           � Data �04.03.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcoes de Atualizacao do Cadastro                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE40Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA40                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE40Mnt( cAlias, nReg, nOpcx )

Local aAreaAnt		:= GetArea()
Local aAreaDE7		:= DE7->( GetArea() )
Local nCntFor		:= 0
Local aVisual		:= {}
Local aAltera		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local oEnch
Local oDlgEsp
Local aNoFields		:= {}
Local aYesFields	:= {}
Local aObjects		:= {}
Local aInfo			:= {}

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols	:= {}
Private oGetD
Private aPosObj:= {}    
Private lCopy := .F.
Private cCodAnt

If nOpcx == 6
	nOpcx := 4  
	lCopy :=.T.
Endif	

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, nOpcx==3 )

Aadd( aVisual,   'DE7_CODCLI') 
Aadd( aVisual,   'DE7_LOJCLI')
Aadd( aVisual,   'DE7_NOMCLI')

Aadd( aNoFields, 'DE7_CODCLI')
Aadd( aNoFields, 'DE7_LOJCLI') 
Aadd( aNoFields, 'DE7_NOMCLI')

//-- Configura variaveis da GetDados
TMSFillGetDados(nOpcx,'DE7', 1,xFilial('DE7')+M->DE7_CODCLI+M->DE7_LOJCLI, { || DE7->DE7_FILIAL + DE7->DE7_CODCLI + DE7->DE7_LOJCLI},{ || .T. }, aNoFields,	aYesFields )
//-- Se for copia, zera o codigo para obrigar a alteracao.
If lCopy
    cCodAnt :=M->DE7_CODCLI+M->DE7_LOJCLI
	M->DE7_CODCLI 	:= Space(Len(DE7->DE7_CODCLI))
	M->DE7_LOJCLI 	:= Space(Len(DE7->DE7_LOJCLI))
	M->DE7_NOME	  	:= Space(Len(SA1->A1_NOME))
Endif	

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 80, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,aVisual,aPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'TMSAE40LOk','TMSAE40TOk',,.T.,       ,       ,      , 999    ,       ,         ,       ,     ,    )

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, If( oGetD:TudoOk(),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons ) 

If nOpcx != 2 .And. nOpcA == 1
	TMSAE40Grv( nOpcx )  //Gravacao dos registros
EndIf

DeleteObject( oDlgEsp )
DeleteObject( oEnch )
DeleteObject( oGetD )

RestArea( aAreaDE7 )
RestArea( aAreaAnt )

Return(nOpca)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE40LOk� Autor � Eduardo de Souza      � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE40LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA40                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE40LOk()

Local lRet := .T.

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DE7_CODPRO', 'DE7_PRDEMB' }, 4 )
EndIf

Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE40TOk  � Autor � Eduardo de Souza    � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE40TOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA40                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE40TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analisa o linha ok.
If lRet
	lRet := TMSAE40LOk()
EndIf

Return( lRet )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE40Grv � Autor � Eduardo de Souza     � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE40GrV(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao Selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA40                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMSAE40Grv( nOpcx )

Local aAreaAnt	:= GetArea()
Local aAreaDE7	:= DE7->( GetArea() )
Local bCampo	:= { |nCpo| Field(nCpo) }
Local nCntFor	:= 0
Local nCntFo1	:= 0         
Local nPosPro    := Ascan(aHeader,{|x| TRIM(x[2]) == "DE7_CODPRO" })

If	nOpcx == 5				//-- Excluir
	Begin Transaction
      // Exclui todos os itens do DE7
      	DE7->( DbSetOrder( 1 ) )
    	MsSeek(xFilial('DE7') + M->DE7_CODCLI + M->DE7_LOJCLI)
		While !EOF() .And. DE7->( MsSeek( xFilial('DE7') + M->DE7_CODCLI + M->DE7_LOJCLI, .F. ) )
			RecLock('DE7',.F.,.T.)
			DE7->(DbDelete())
			dbSkip()
			MsUnLock()
		EndDo
		EvalTrigger()
	End Transaction
EndIf

If	nOpcx == 3 .Or. nOpcx == 4			//-- Incluir ou Alterar

	Begin Transaction
		
		// Se ja existir o registro apaga pra incluir novamente
		DE7->( DbSetOrder( 1 ))
		If	DE7->( MsSeek( xFilial('DE7') + M->DE7_CODCLI + M->DE7_LOJCLI, .F. ))
			While !Eof() .And. (DE7->DE7_FILIAL + DE7->DE7_CODCLI + DE7->DE7_LOJCLI == xFilial('DE7') + M->DE7_CODCLI + M->DE7_LOJCLI)
				RecLock('DE7',.F.,.T.)
				DE7->(DbDelete())
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
		
		//����������������Ŀ
		//� Grava GetDados �
		//������������������
		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor ) .And. !Empty(aCols[nCntFor,nPosPro]) 
				RecLock('DE7',.T.)
				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				DE7->DE7_FILIAL := xFilial('DE7')
				DE7->DE7_CODCLI := M->DE7_CODCLI 
				DE7->DE7_LOJCLI := M->DE7_LOJCLI
				MsUnLock()
			EndIf
		Next

		EvalTrigger()

	End Transaction

EndIf

RestArea( aAreaDE7 )	
RestArea( aAreaAnt )	

Return( Nil) 

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
     
Private aRotina := {	{	STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar
							{	STR0003,'TMSAE40Mnt',0,2,0,NIL},; //'Visualizar'
							{	STR0004,'TMSAE40Mnt',0,3,0,NIL},; //'Incluir'
							{	STR0005,'TMSAE40Mnt',0,4,0,NIL},; //'Alterar'
							{	STR0006,'TMSAE40Mnt',0,5,0,NIL},; //'Excluir' 
							{	STR0007,'TMSAE40Mnt',0,6,0,NIL}} //'Copiar'

If ExistBlock("TME40MNU")
	ExecBlock("TME40MNU",.F.,.F.)
EndIf


Return(aRotina)
