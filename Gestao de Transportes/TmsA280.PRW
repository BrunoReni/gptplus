#include 'TmsA280.ch'
#Include 'Protheus.ch'

Static lTMA280GRV:= ExistBlock('TMA280GRV')

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA280  � Autor � Alex Egydio           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rota x Rodovia                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA280(nOpcAuto,nRegAuto,cRota,cDesRot)

Private cCadastro	:= STR0001 //'Rota x Rodovia'
Private aRotina	:= MenuDef()

//-- A consulta F3( DU0 ) filtra as rodovias em questao, e necessita da variavel private ccodrod
Private cCodRod:= ''

DEFAULT nOpcAuto := 0
DEFAULT nRegAuto := 0
DEFAULT cRota    := ""
DEFAULT cDesRot  := ""
					
DA8->(DbSetOrder(1))								

DbSelectArea("DU2")
DbSetOrder( 3 )

If nOpcAuto == 0
	mBrowse( 6,1,22,75,'DU2')
Else
	TMSA280Mnt("DU2",nRegAuto,nOpcAuto,cRota,cDesRot)
EndIf
RetIndex('DU2')

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA280Mnt� Autor � Alex Egydio           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rota x Rodovia                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA280Mnt( cAlias, nReg, nOpcx , cRota, cDesRot )
//-- Genericas
Local aAreaAnt		:= GetArea()
Local aAreaDU0		:= DU0->( GetArea() )
Local nCntFor		:= 0
//-- EnchoiceBar
Local aVisual		:= {}
Local aAltera		:= {}
Local aButtons		:= {}
Local aButtUsr      := {}
Local nOpca			:= 0
Local oEnch
//-- Dialog
Local oDlgEsp
//-- GetDados
Local aNoFields	:= {}
//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]
//-- GetDados
Private aHeader	:= {}
Private aCols		:= {}
Private oGetD

Private aPosObj:= {}

If Type("cCadstro") == "U"
	Private cCadastro	:= STR0001 //'Rota x Rodovia'
	Private aRotina	:= MenuDef()
EndIf

DEFAULT cRota   := ""
DEFAULT cDesRot := ""

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, nOpcx==3 )

Aadd( aVisual, 'DU2_ROTA')
Aadd( aVisual, 'DU2_DESROT')

Aadd( aNoFields, 'DU2_ROTA')
Aadd( aNoFields, 'DU2_DESROT')

//-- Configura variaveis da GetDados
FillGetDados(	nOpcx, 'DU2', 3,xFilial( 'DU2' ) + M->DU2_ROTA, { ||	DU2->( DU2_FILIAL + DU2_ROTA ) }, ;
{ || .T. }, aNoFields,	/*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, /*bMontCols*/)

//-- Inicializa o item da getdados se a linha estiver em branco.
If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DU2_CODROD', 1 ) )
	GDFieldPut( 'DU2_ITEM', StrZero(1,Len(DU2->DU2_ITEM)), 1 )
Else

	DU0->( DbSetOrder( 1 ) )
	For nCntFor := 1 To Len( aCols )

		If	DU0->( MsSeek( xFilial('DU0') + GDFieldGet('DU2_CODROD',nCntFor) + GDFieldGet('DU2_SEQPDG',nCntFor),.F.) )
			GDFieldPut( 'DU2_KM', DU0->DU0_KM, nCntFor )
			GDFieldPut( 'DU2_MUNPDG', DU0->DU0_MUNPDG, nCntFor )
		EndIf

	Next

EndIf

If !Empty(cRota)
	M->DU2_ROTA   := cRota
	M->DU2_DESROT := cDesRot
EndIf

If IsInCallStack("OMSA100") .And. nModulo == 43
	M->DU2_ROTA   := DA8->DA8_COD
	M->DU2_DESROT := DA8->DA8_DESC
EndIf

//-- Inclui botoes do usuario
If ExistBlock("TM280BUT")
	If ValType(aButtUsr := ExecBlock("TM280BUT",.F.,.F.)) == "A"
		AEval(aButtUsr,{|x| Aadd(aButtons,x)})
	EndIf
EndIf

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 020, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oEnch		:= MsMGet():New( cAlias, nReg, nOpcx,,,, aVisual, aPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'TMSA280LinOk','TMSA280TudOk','+DU2_ITEM',.T.,       ,       ,      ,999,       ,         ,       ,     ,    )

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, If( oGetD:TudoOk(),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons ) 

If nOpcx != 2 .And. nOpcA == 1

	TMSA280Grv( nOpcx )	
	
EndIf

RestArea( aAreaDU0 )
RestArea( aAreaAnt )

Return(nOpca)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA280Vld� Autor � Alex Egydio           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes do sistema                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA280Vld()

Local aAreaAnt	:= GetArea()
Local aAreaDU0	:= DU0->( GetArea() )
Local bSeek		:= {|| .F. }
Local cCampo	:= ReadVar()
Local lRet		:= .T.

DU0->( DbSetOrder( 1 ) )

If	cCampo == 'M->DU2_CODROD'
	GDFieldPut('DU2_NOMROD',Posicione('DTZ',1,xFilial('DTZ')+M->DU2_CODROD,'DTZ_NOMROD'))
	If !Empty(GDFieldGet('DU2_CODROD',n)) .And. &cCampo <> GDFieldGet('DU2_CODROD',n)
		If !Empty(GDFieldGet('DU2_SEQPDG',n)) .Or. GDFieldGet('DU2_KM',n) > 0
			GDFieldPut('DU2_SEQPDG',"")
			GDFieldPut('DU2_KM',0)
		EndIf
	EndIf
ElseIf cCampo == 'M->DU2_SEQPDG'
	If	DU0->( ! MsSeek(xFilial('DU0') + GDFieldGet('DU2_CODROD',n) + Iif(Empty(M->DU2_SEQPDG),'',M->DU2_SEQPDG) ) )
		Help(' ', 1, 'TMSA28001')	//-- Rodovia nao encontrada (DU0)
		lRet := .F.
	Else
		GDFieldPut( 'DU2_SEQPDG', DU0->DU0_SEQPDG, n )
		GDFieldPut( 'DU2_KM', DU0->DU0_KM, n )
		GDFieldPut( 'DU2_MUNPDG', Iif( Empty( M->DU2_SEQPDG ), "", DU0->DU0_MUNPDG ), n )
	EndIf
EndIf


RestArea( aAreaDU0 )
RestArea( aAreaAnt )

Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA280Lin� Autor � Alex Egydio           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da linha da GetDados                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA280LinOk()

Local lRet       := .T.

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- A partir do release sera permitido incluir registros com a mesma sequencia.
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DU2_CODROD', 'DU2_SEQPDG', 'DU2_SENTID' }, 4 )
EndIf                

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA280Tud� Autor � Alex Egydio           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA280TudOk()

Local lRet		:= .T.
//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )
//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMSA280LinOk()
EndIf
//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	lRet := .F.
EndIf

Return( lRet )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA280Grv� Autor � Alex Egydio          � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar dados                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function TMSA280Grv( nOpcx )

Local aAreaAnt	:= GetArea()
Local aAreaDU2	:= DU2->( GetArea() )
Local bCampo	:= { |nCpo| Field(nCpo) }
Local nCntFor	:= 0
Local nCntFo1	:= 0

If	nOpcx == 5				//-- Excluir
	Begin Transaction

		DU2->( DbSetOrder( 1 ) )
		While DU2->( MsSeek( xFilial('DU2') + M->DU2_ROTA, .F. ) )
			RecLock('DU2',.F.,.T.)
			DU2->(DbDelete())
			MsUnLock()
		EndDo

		EvalTrigger()
	End Transaction
EndIf


If	nOpcx == 3 .Or. nOpcx == 4			//-- Incluir ou Alterar
	Begin Transaction

		DU2->( DbSetOrder( 3 ) )

		For nCntFor := 1 To Len( aCols )
			If	!GDDeleted( nCntFor )
				If	DU2->( MsSeek( xFilial('DU2') + M->DU2_ROTA + GDFieldGet( 'DU2_ITEM', nCntFor ), .F. ) )
					RecLock('DU2',.F.)
				Else
					RecLock('DU2',.T.)
					DU2->DU2_FILIAL	:= xFilial('DU2')
					DU2->DU2_ROTA		:= M->DU2_ROTA
				EndIf

				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
	         		FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
	    			EndIf
				Next
				MsUnLock()

			Else
				If	DU2->( MsSeek( xFilial('DU2') + M->DU2_ROTA + GDFieldGet( 'DU2_ITEM', nCntFor ), .F. ) )
					RecLock('DU2',.F.,.T.)
					DU2->(DbDelete())
					MsUnLock()
				EndIf	
			EndIf
		Next

		EvalTrigger()
	End Transaction
EndIf

If lTMA280GRV
	lRet := ExecBlock("TMA280GRV",.F.,.F.,{nOpcx})
EndIf
		
RestArea( aAreaDU2 )	
RestArea( aAreaAnt )	

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA280Vld� Autor �        Nava           � Data �25.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra no IniBrowse e na GetDados                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA280Show( cWhere, cField )

Local aAreaAnt	:= GetArea()
Local aAreaDU0	:= DU0->( GetArea() )
Local bSeek		:= {|| .F. }

DU0->( DbSetOrder( 1 ) )

IF cWhere == "GETDADOS"
		DU0->( MsSeek( xFilial('DU0') + M->DU2_CODROD + DU2->DU2_SEQPDG ) )
	IF cField == "DU2_KM"
      RETURN DU0->DU0_KM
   ELSEIF cField == 'DU2_MUNPDG'   
      RETURN DU0->DU0_MUNPDG
   ENDIF
ELSEIF cWhere == "MBROWSE"      
		DU0->( MsSeek( xFilial('DU0') + DU2->DU2_CODROD + DU2->DU2_SEQPDG	) )	
	IF cField == "DU2_KM"
      RETURN DU0->DU0_KM
   ELSEIF cField == 'DU2_MUNPDG'   
      RETURN DU0->DU0_MUNPDG
   ENDIF
ENDIF

RETURN .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmsA280Whe� Autor � Alex Egydio           � Data �03.07.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes antes de editar o campo                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TmsA280Whe()

Local aAreaAnt	:= GetArea()
Local cCampo	:= ReadVar()
Local lRet		:= .T.

If	cCampo == 'M->DU2_KM'
	lRet := Empty(GDFieldGet('DU2_SEQPDG',n))
EndIf		

RestArea(aAreaAnt)

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
     
Private aRotina	:= {	{ STR0002 ,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003 ,'TMSA280Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004 ,'TMSA280Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005 ,'TMSA280Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006 ,'TMSA280Mnt',0,5,0,NIL} } //'Excluir'


If ExistBlock("TMA280MNU")
	ExecBlock("TMA280MNU",.F.,.F.)
EndIf

Return(aRotina)

