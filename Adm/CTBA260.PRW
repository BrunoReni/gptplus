#Include "CTBA260.Ch"
#Include "PROTHEUS.Ch"

Static _oCtba260 

// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CtbaA260 � Autor � Pilar S. Albaladejo   � Data � 03.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Criacao de Contas Autom�ticas (Conta + C.Custo)            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctba260()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctba260()

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0004)  //"Cria��o de Contas C. Custo Contabil"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

SetKey(VK_F12,{|a,b|AcessaPerg("CTB260",.T.)})

Pergunte("CTB260",.F.)
//�����������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros			 	   			�
//� mv_par01	// Do C.Custo? 										�
//� mv_par02	// Ate o C.Custo?  									�
//� mv_par03	// Conta Modelo?                 				  	�
//�������������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"CT1")

dbSetOrder(1)   

SET KEY VK_F12 to
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ct260inc � Autor � Pilar S. Albaladejo   � Data � 03.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de contas com centro de Custos        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct260inc(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � nOpca                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ct260inc(cAlias,nReg,nOpcx,lAutomato)

Local aSaveArea := GetArea()
Local aAltera 	:= {"CTT_CUSTO","CTT_DESC01"}
Local aCampos	:= {}
Local cCustoIni := mv_par01
Local cCustoFim	:= mv_par02
Local cArq1 
Local nRec
Local nOpca
Local oGetDb
Local oDlg
Local oConta	
Local oDesc	

Private aTELA	:= {}
Private aGETS	:= {}
Private aHeader	:= {}

Default lAutomato := .F.

If Pergunte("CTB260",.T.)
	//��������������������������������������������������������������Ŀ
	//� Verifica se a Conta Modelo eh valida                         �
	//����������������������������������������������������������������
	dbSelectArea("CT1")       
	nRec	:= Recno()
	dbSeek(xFilial()+mv_par03)
	IF !Found() .Or. CT1->CT1_NCUSTO = 0 
		Help(" ",1,"NOGERACTB")
		dbGoto(nRec)
		RestArea(aSaveArea)
		Return
	EndIF
Else
	RestArea(aSaveARea)
	Return
EndIf	

aCampos := Ctb260Head(@aAltera)
Ctb260Cria(aCampos,@cArq1)

//������������������������������������������������������Ŀ
//� Carrega arquivo temporario para exibir na GetDB      �
//��������������������������������������������������������
Ctb260Carr(aCampos,cCustoIni,cCustoFim)

If TMP->(RecCount()) == 0
	RestArea(aSaveArea)
	Return
EndIf	

If !lAutomato
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0004) From 9,0 To 28,80 OF oMainWnd  //" Cria��o de Contas Autom�ticas "
		@ 1.4 , .8 SAY OemToAnsi(STR0005)		  		//"C�digo : "
		@ 1.4 , 4 	MSGET oConta VAR CT1->CT1_CONTA	SIZE 050,08 When .F. 
		oConta:cSx1Hlp:="CT1_CONTA"	                                     
		
		@ 1.4 , 14 	Say OemToAnsi(STR0006)  			//"Descri��o : "
		@ 1.4 , 18 	MSGET oDesc VAR CT1->CT1_DESC01 SIZE 160,08 When .F.
		oDesc:cSx1Hlp:="CT1_DESC01"
		                                     	
		oGetDB := MSGetDB():New( 034, 005, 126, 315, 2,;
				 "CT260LOK", "CT260TOk", ,.T.,aAltera,,.t.,,"TMP",,,,,,,)
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
		{||nOpca:=1,if(oGetDB:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()})
Else
	nOpca:=1
Endif

DbSelectArea(cAlias)
IF nOpcA == 1
	Begin Transaction
		Ct260Grava(	)
		//Processa Gatilhos
		EvalTrigger()
	End Transaction	
ENDIF

dbSelectArea("CT1")
TMP->(DbCloseArea())

If _oCtba260 <> Nil
	_oCtba260:Delete()
	_oCtba260 := Nil
Endif

RestArea(aSaveArea)

dbSelectArea(cAlias)
Return nOpca

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTB260Head� Autor � Pilar S. Albaladejo   � Data � 03.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta aHeader para MsGetDB                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctb260Head(aAltera)                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array aCampos                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Matriz com campos da MSGETDB                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb260Head(aAltera)

Local aSaveArea	:= GetArea()
Local aCampos	:= {}

PRIVATE nUsado := 0

// Montagem da matriz aHeader									
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("CTT")
While !EOF() .And. (x3_arquivo == "CTT")
	If	x3Uso(x3_usado) .and. cNivel >= x3_nivel
		If Ascan(aAltera,Trim(X3_CAMPO)) > 0
			nUsado++
			AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
								x3_tamanho, x3_decimal, x3_valid,;
								x3_usado, x3_tipo, "TMP", x3_context } )
		EndIF
	EndIF
	aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,;
						 SX3->X3_DECIMAL } )
	dbSkip()
EndDO

Aadd(aCampos,{"CTT_FLAG","L",1,0})

RestArea(aSaveArea)

Return aCampos

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTB260Cria� Autor � Pilar S. Albaladejo   � Data � 24.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria arquivo temporario e indices para MSGETDB             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctb260cria(aCampos,cArq1)                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Matriz com campos da MSGETDB                       ���
���          � ExpC1 = Nome do arquivo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctb260Cria(aCampos,cArq1)

Local aSaveArea := GetArea()

If Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf

If _oCtba260 <> Nil
	_oCtba260:Delete()
	_oCtba260 := Nil
Endif

_oCtba260 := FWTemporaryTable():New( "TMP" )  
_oCtba260:SetFields(aCampos) 
_oCtba260:AddIndex("1", {"CTT_FILIAL","CTT_CUSTO"})

//------------------
//Cria��o da tabela temporaria
//------------------
_oCtba260:Create()  

dbSelectArea( "TMP" )

RestArea(aSaveArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �CTB260Carr� Autor � Pilar S. Albaladejo   � Data � 24.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega arq. temporario com dados para MSGETDB             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctb260Carr(aCampos,ccustoIni,cCustoFim)                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Matriz com campos da MSGETDB                       ���
���          � ExpC1 = Centro de custo inicial                            ���
���          � ExpC2 = Centro de custo final                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTB260Carr(aCampos,cCustoIni,cCustoFim)

Local aSaveArea	:= GetArea()

DbSelectArea("CTT")
DbSetOrder(1)
DbSeek(xFilial()+cCustoIni,.T.)
While !Eof() .And. CTT->CTT_FILIAL == xFilial() .And. CTT->CTT_CUSTO <= cCustoFim
	dbSelectArea( "TMP" )
	RecLock("TMP",.T.)
	TMP->CTT_CUSTO 		:= CTT->CTT_CUSTO
	TMP->CTT_DESC01		:= CTT->CTT_DESC01
	dbSelectArea("CTT")
	dbSkip()
EndDo			
	
dbSelectArea("TMP")
dbGoTop()

RestArea(aSaveArea)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct260LOK  � Autor � Pilar S. Albaladejo   � Data � 07.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a linha           		                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct260lok()               		                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                      		                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Ct260LOK                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                   		                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ct260LOK()

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct260TOK  � Autor � Pilar S. Albaladejo   � Data � 07.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a GetDb           		                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ct260tok()                		                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                       		                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACTB                  		                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ct260TOK()

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct260Grava� Autor � Pilar S. Albaladejo   � Data � 07.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava as das novas contas		                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ct260Grava()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ct260Grava()

Local aConta	:= {}
Local cCodConta := Alltrim(CT1->CT1_CONTA)
Local cCodRes
Local nPos
Local nCont
Local nTamanho	:= Len(CT1->CT1_RES)

//���������������������������������������������������������Ŀ
//� Carrega definicoes da Conta Modelo                      �
//�����������������������������������������������������������
dbSelectArea("CT1")
dbSetOrder(1)
If dbSeek(xFilial()+mv_par03)
	For nPos := 1 To Fcount()
		Aadd(aConta,{FieldName(nPos),FieldGet(nPos)})
	Next nPos
EndIf		

//���������������������������������������������������������Ŀ
//� Posiciona no ultimo codigo reduzido da filial atual     �
//� para calcular o pr�ximo c�digo reduzido.                �
//�����������������������������������������������������������
dbSelectArea("CT1")
dbSetOrder(2)
dbSeek(StrZero(Int(Val(xFilial()))+1,2),.T.)
dbSkip(-1)
cCodRes := CT1->CT1_RES

dbSelectArea("TMP")
dbGotop()
While !Eof()
	If !TMP->CTT_FLAG
		//��������������������������������������������������������Ŀ
		//� Cria a nova conta no Plano de Contas                   �
		//����������������������������������������������������������
		dbSelectArea("CT1")
		DbSetOrder(1)
		If !dbSeek(xFilial() + cCodConta + TMP->CTT_CUSTO)
			RecLock("CT1",.T.)
			For nCont := 1	To Len(aConta)
				cCampo		:= aConta[nCont][1]
				&(cCampo)	:= aConta[nCont][2]
			Next nCont	
			CT1->CT1_CTASUP		:=	cCodConta
			CT1->CT1_CONTA		:=	cCodConta+Alltrim(TMP->CTT_CUSTO)
			CT1->CT1_CLASSE		:= "2"		// A conta incluida eh analitica
			cCodRes				:= StrZero(Val(cCodRes)+1,nTamanho)
			CT1->CT1_RES		:= cCodRes
		EndIf	
	EndIf	
	dbSelectArea("TMP")
	dbSkip()	 
EndDo

Return("")


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �01/12/06 ���
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
Local aRotina := {{ OemToAnsi(STR0001),"AxPesqui",0 , 1},;		//"Pesquisar"
					 { OemToAnsi(STR0002),"AxVisual",0 , 2},;		//"Visualizar"
					 { OemToAnsi(STR0003),"Ct260Inc",0 , 4} }		//"Criar"
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} Ct260Prep
Ajuste dos campos CT1_NCUSTO / CT1_CC
@author Totvs
@since 08/11/2018
@version 1.0
@see
/*/
//-------------------------------------------------------------------

Function Ct260Prep( cCtaModelo, lAutomato )  
//necessario popular campos CT1_NCUSTO // CT1_CC para automacao da rotina

If lAutomato
	CT1->(dbSetOrder(1))
	If CT1->( dbSeek( xFilial("CT1")+cCtaModelo) )
		If CT1->CT1_NCUSTO <> 4 
			CT1->( RecLock("CT1",.F.) )
			CT1->CT1_NCUSTO :=  4
			CT1->( MsUnLock() )
		EndIf
	EndIf
EndIf

Return