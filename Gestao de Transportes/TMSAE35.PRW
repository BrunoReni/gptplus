#INCLUDE 'TMSAE35.CH'
#INCLUDE 'PROTHEUS.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE35  � Autor � Ana Cristina          � Data �02.03.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Ocorrencias x Embarcadora                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE35()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSAE35()

Private cCadastro	:= STR0001 //"Ocorrencias x Embarcadora"
Private aRotina	:= MenuDef()

DE6->( DbSetOrder( 1 ) )

mBrowse( 6,1,22,75,'DE6',, )

RetIndex('DE6')

Return( Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE35Mnt� Autor �Ana Cristina           � Data �02.03.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcoes de Atualizacao do Cadastro                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE35Mnt(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA35                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE35Mnt( cAlias, nReg, nOpcx )

Local aAreaAnt		:= GetArea()
Local aAreaDE6		:= DE6->( GetArea() )
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

Aadd( aVisual,   'DE6_CODCLI') 
Aadd( aVisual,   'DE6_LOJCLI') 
Aadd( aVisual,   'DE6_NOMCLI')

Aadd( aNoFields, 'DE6_CODCLI') 
Aadd( aNoFields, 'DE6_LOJCLI') 
Aadd( aNoFields, 'DE6_NOMCLI')

//-- Configura variaveis da GetDados
TMSFillGetDados(	nOpcx, 'DE6', 1,xFilial('DE6')+M->DE6_CODCLI+M->DE6_LOJCLI, { ||	DE6->DE6_FILIAL + DE6->DE6_CODCLI + DE6->DE6_LOJCLI },{ || .T. }, aNoFields,	aYesFields )

//-- Se for copia, zera o codigo para obrigar a alteracao.
If lCopy
    cCodAnt := M->DE6_CODCLI
	M->DE6_CODCLI 	:= Space(Len(DE6->DE6_CODCLI))
	M->DE6_LOJCLI 	:= Space(Len(DE6->DE6_LOJCLI))
	M->DE6_NOME	  	:= Space(Len(SA1->A1_NOME))
Endif	

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 80, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)    

Inclui := ((nOpcX==3).Or.(nOpcX==4)) //-- Impede que a Descricao apareca na inclusao de itens durante a alteracao

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,aVisual,aPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'TMSAE35LOk','TMSAE35TOk',,nOpcx==3 .Or. nOpcx==4,       ,       ,      ,999999,       ,         ,       ,     ,    )

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, If( oGetD:TudoOk(),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons ) 

If nOpcx != 2 .And. nOpcA == 1
	TMSAE35Grv( nOpcx )  //Gravacao dos registros
EndIf

DeleteObject( oDlgEsp )
DeleteObject( oEnch )
DeleteObject( oGetD )

RestArea( aAreaDE6 )
RestArea( aAreaAnt )

Return(nOpca)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE35LOk� Autor � Eduardo de Souza      � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE35LOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA35                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE35LOk()

Local lRet := .T.

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DE6_CODOCO' }, 4 )
EndIf

Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE35TOk � Autor � Eduardo de Souza     � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE35TOk()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA35                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE35TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analisa o linha ok.
If lRet
	lRet := TMSAE35LOk()
EndIf

Return( lRet )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSAE35Grv � Autor � Eduardo de Souza     � Data � 14/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE35Grv(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Opcao Selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSEA35                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMSAE35Grv( nOpcx )

Local aAreaAnt	:= GetArea()
Local aAreaDE6	:= DE6->( GetArea() )
Local bCampo	:= { |nCpo| Field(nCpo) }
Local nCntFor	:= 0
Local nCntFo1	:= 0
Local nPosoCor  := Ascan(aHeader,{|x| TRIM(x[2]) == "DE6_CODOCO" })

If	nOpcx == 5				//-- Excluir
	Begin Transaction
      // Exclui todos os itens do DE6
      	DE6->( DbSetOrder( 1 ) )
    	MsSeek(xFilial('DE6') + M->DE6_CODCLI + M->DE6_LOJCLI)
		While !EOF() .And. DE6->( MsSeek( xFilial('DE6') + M->DE6_CODCLI + M->DE6_LOJCLI, .F. ) )
			RecLock('DE6',.F.,.T.)
			DE6->(DbDelete())
			dbSkip()
			MsUnLock()
		EndDo
		EvalTrigger()
	End Transaction
EndIf

If	nOpcx == 3 .Or. nOpcx == 4			//-- Incluir ou Alterar

	Begin Transaction
		
		// Se ja existir o registro apaga pra incluir novamente
		DE6->( DbSetOrder( 1 ))
		If	DE6->( MsSeek( xFilial('DE6') + M->DE6_CODCLI + M->DE6_LOJCLI, .F. ))
			While !Eof() .And. (DE6->DE6_FILIAL + DE6->DE6_CODCLI + DE6->DE6_LOJCLI == xFilial('DE6') + M->DE6_CODCLI + M->DE6_LOJCLI)
				RecLock('DE6',.F.,.T.)
				DE6->(DbDelete())
				MsUnLock()
				dbSkip()
			EndDo
		EndIf
		
		//����������������Ŀ
		//� Grava GetDados �
		//������������������
		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor ) .And. !Empty(aCols[nCntFor,nPosOcor]) 
				RecLock('DE6',.T.)
				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				DE6->DE6_FILIAL := xFilial('DE6')
				DE6->DE6_CODCLI := M->DE6_CODCLI 
				DE6->DE6_LOJCLI := M->DE6_LOJCLI
				MsUnLock()
			EndIf
		Next

		EvalTrigger()

	End Transaction

EndIf

RestArea( aAreaDE6 )	
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
     
Private aRotina	:= {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003,'TMSAE35Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSAE35Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSAE35Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSAE35Mnt',0,5,0,NIL},; //'Excluir' 
								{ STR0007,'TMSAE35Mnt',0,6,0,NIL} } //'Copiar'


If ExistBlock("TME35MNU")
	ExecBlock("TME35MNU",.F.,.F.)
EndIf


Return(aRotina)

