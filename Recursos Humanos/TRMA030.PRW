#Include "Protheus.ch"
#INCLUDE "Trma030.CH"     

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Program   � TRMA030  � Autor � Cristina Ogura          � Data � 27.11.98 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Grupos e Competencias                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Cecilia Car.�21.07.2014�TPZSOX�Incluido o fonte da 11 para a 12 e efetua-���
���            �          �      �da a limpeza.                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function Trma030()                        
Local cFiltra	:= ""	//Variavel para filtro
Local aIndFil	:= {}	//Variavel Para Filtro 

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro := OemToAnsi(STR0001)	//"Grupo"
    
//������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE 						 �
//��������������������������������������������������������
dbSelectArea("SQ0") 
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"SQ0","1")
bFiltraBrw 	:= {|| FilBrowse("SQ0",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE						      	     �
//����������������������������������������������������������������
dbSelectArea("SQ0") 
dbGoTop()

mBrowse(6, 1, 22, 75,"SQ0") 

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SQ0",aIndFil) 

// Volta para 1a ordem dos Arquivos
dbSelectArea("SQ0") 
dbSetOrder(1)

dbSelectArea("RBM") 
dbSetOrder(1)

Return Nil
                   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TR030Mnt  � Autor � Cristina Ogura       � Data � 12.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Opcao de exclusao dos grupos                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
���          � ExpN1 : Registro                                           ���
���          � ExpN2 : Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Trma030       �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tr030Mnt(cAlias,nReg,nOpcx)

Local nI 		:= 0 
Local nUsado 	:= 0
Local nOpca 	:= 0
Local oDlg  
Local aNoFields	:= {"RBM_FILIAL","RBM_GRUPO"}
Local lOp		:= If(nOpcx==2 .Or. nOpcx==5 ,.F.,.T.) 
Local bSet15
Local bSet24

// Variaveis de Coordenadas de Tela
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords 	:= {}
Local aObjSize		:= {}

//Variaveis para WalkThru
Local nRbmOrd		:= RetOrdem("RBM","RBM->RBM_FILIAL+RBM->RBM_GRUPO")
Local bSeekWhile	:= {|| RBM->RBM_FILIAL + RBM->RBM_GRUPO }
Private nPosRec		:= 0

Private aHeader	:= {}
Private aCols	:= {}
Private aTELA	:= Array(0,0)
Private aGets	:= Array(0)
Private bCampo	:= {||}       

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("SQ0",(nOpcx == 3))
                 
If cModulo != "RSP" .And. cModulo != "TMK"	//Recutamento e CRM
	//��������������������������������������������������������������Ŀ
	//� Cria aHeader e aCols da GetDados                             �
	//����������������������������������������������������������������
	
	FillGetDados(nOpcx						,; //1-nOpcx - n�mero correspondente � opera��o a ser executada, exemplo: 3 - inclus�o, 4 altera��o e etc;
				 "RBM"						,; //2-cAlias - area a ser utilizada;
				 nRbmOrd		 			,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 xFilial("SQ0")+M->Q0_GRUPO	,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
				 bSeekWhile					,; //5-bSeekWhile - bloco contendo a express�o a ser comparada com cSeekKey na condi��o  do While.
				 NIL						,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-c�digo, condi��o a ser utilizado para executar o Loop no While;2� - array bi-dimensional contendo N.. condi��es, em que o 1� elemento � o bloco condicional, o 2� � bloco a ser executado se verdadeiro e o 3� � bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields					,; //7-aNoFields - array contendo os campos que n�o estar�o no aHeader;
				 NIL						,; //8-aYesFields - array contendo somente os campos que estar�o no aHeader;
				 NIL						,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usu�rio;
				 NIL						,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL						)  //11-bMontCols - bloco contendo fun��o especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
	
	nPosRec:=GdfieldPos("RBM_REC_WT")
	If nOpcx == 3
		aCols[1][nPosRec]:=0
	EndIf
	
EndIf
	
//��������������������������������������������������������������Ŀ
//� Aciona Enchoice / GetDados                                   �
//����������������������������������������������������������������
cAliasEnchoice	:= "SQ0"
cAliasGetD		:= "RBM"
cLinOk			:= "GdRBMLinOk"
cTudOk			:= "GdRBMTudOk"
cFieldOk		:= "AllwaysTrue()"
aCpoEnchoice	:= Nil

bCampo	:= {|nCPO|Field(nCPO)}

//��������������������������������������������������������������Ŀ
//� Monta as Dimensoes dos Objetos         					   	 �
//����������������������������������������������������������������
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 035 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
    
//��������������������������������������������������������������Ŀ
//� Ativa Enchoice e GetDados  			        			     �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aAdvSize[7],0 to aAdvSize[6],aAdvSize[5]	of oMainWnd PIXEL

	EnChoice(cAliasEnchoice,nReg,nOpcx,,,,aCpoEnchoice,aObjSize[1],,3)
                   
	If cModulo != "RSP" .And. cModulo != "TMK"	//Recutamento e CRM
		oGetDados := MsGetDados():New(	aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcx,cLinOk,cTudOk,,lOp,	,,,500,cFieldOk)
		bSet15 := {||nOpca:=1, If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)}
	Else
		bSet15 := {||nOpca:=1, If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End())}	
	EndIf 

	bSet24 := {||nOpca:=0, oDlg:End()}  

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24)

//��������������������������������������������������������������Ŀ
//� Gravacao			                                         �
//����������������������������������������������������������������	
If nOpca == 1  
	Tr030Grava(nOpcx)
Else
	If __lSX8                     
		RollBackSX8()
	EndIf	
EndIf

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr030Grava� Autor � Emerson Grassi Rocha  � Data �  18/12/03  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Executa a gravaco de GRUPO. 					                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Trma030	                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function Tr030Grava(nOpcx)
Local bCampo 	:= {|n| FieldName(n) }
Local nX		:= 0
Local nY		:= 0
Local lTravou	:= .F.

Do Case 
	Case nOpcx == 3  // INCLUSAO
		If __lSX8
			ConfirmSX8()
		EndIf	
	Case nOpcx == 5 // Exclusao
		Tr030Dele()
EndCase

If nOpcx == 3 .or. nOpcx == 4
	//�����������������������������������������������������Ŀ
	//� Grava Cabecalho de GRUPO - SQ0   				    �
	//�������������������������������������������������������
	RecLock("SQ0",IIf(nOpcx == 3,.T.,.F.))
	
	For nX := 1 To FCount()
		If ( FieldName(nX) == "Q0_FILIAL" )
			FieldPut(nX, xFilial("SQ0"))
		Else
			FieldPut(nX, M->&(FieldName(nX)))
		EndIf
	Next nI
    MsUnlock()
    
	If cModulo != "RSP"	.And. cModulo != "TMK"	//Recutamento e CRM
		
		//�����������������������������������������������������Ŀ
		//� Grava Competencias de GRUPO - RBM					�
		//�������������������������������������������������������
		dbSelectArea("RBM") 
		For nX :=1 to Len(aCols)
		    Begin Transaction 
				If aCols[nx][nPosRec]>0
					MsGoto(aCols[nX][nPosRec])
					RecLock("RBM",.F.)
					lTravou:=.T.
				Else
				    If !(aCols[nX][Len(aCols[nX])])
						RecLock("RBM",.T.)
						lTravou:=.T.
					EndIf
				EndIf
				If lTravou
					//--Verifica se esta deletado
					If aCols[nX][Len(aCols[nX])] 
						dbDelete()
			        Else
						Replace RBM->RBM_FILIAL 	WITH xFilial("RBM")
						Replace RBM->RBM_GRUPO	 	WITH M->Q0_GRUPO			
					EndIf
					For nY := 1 To Len(aHeader)
						If aHeader[nY][10] <> "V"
							RBM->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
						EndIf	
					Next nY
					MsUnlock()
					lTravou:=.F.
				EndIf	
			End Transaction	
		Next nx
	EndIf
EndIf

Return                      

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr030Dele � Autor � Cristina Ogura        � Data � 20.11.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Deleta todos os registros referentes as funcionarios        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Tr030Dele                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr030Dele()

Local lAchou	:= .F.
     
// Verificar no SQ1 - Fatores da Avaliacao
dbSelectArea("SQ1")
dbSetOrder(1)
If dbSeek(xFilial("SQ1")+SQ0->Q0_GRUPO)
	Help(" ",1,"EXISTEGRUP")
	lAchou := .T.
EndIf

// Verificar no SQ3 - Especificacao dos Cargos
dbSelectArea("SQ3")
dbSetOrder(2)
If dbSeek(xFilial("SQ3")+SQ0->Q0_GRUPO)
	Help(" ",1,"EXISTECARG")
	lAchou := .T.
EndIf

If cModulo == "TMK"
	If Tr030VldTmk(SQ0->Q0_GRUPO)
		Help(" ",1,"NODELETA",,STR0017,2,0)	//"Este grupo esta sendo utilizado pela rotina de Cadastro de Contatos."
		lAchou := .T.
	EndIf
EndIf

If !lAchou
	Begin Transaction
	
	//�����������������������������������������������������Ŀ
	//� Deleta arquivo RBM (Itens)                          �
	//�������������������������������������������������������
	DbSelectArea("RBM")
	DbSetOrder(1)
	DbSeek(xFilial("RBM")+SQ0->Q0_GRUPO)
	While (!Eof()) .AND. (SQ0->Q0_FILIAL == xFilial("RBM")) .AND. (RBM->RBM_GRUPO == SQ0->Q0_GRUPO)
		Reclock( "RBM" ,.F.)
			DbDelete()
		MsUnlock()
		DbSkip()
	End
	
	//�����������������������������������������������������Ŀ
	//� Deleta arquivo SQ0 (Cabecalho)                      �
	//�������������������������������������������������������
	DbSelectArea("SQ0")
	Reclock( "SQ0" ,.F.)
		DbDelete()
	MsUnlock()
	
	End Transaction
EndIf

Return Nil


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GdRBMLinOk   � Autor �Emerson Grassi Rocha� Data � 19/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Linha Ok da GetDados.                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GdRBMLinOk(oBrowse)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�								                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trma030                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GdRBMLinOk(oBrowse)

Local aSaveArea	:= GetArea()
Local aCposKey	:= {}
Local lLinOk	:= .T.

//����������������������������������������������������������������������Ŀ
//� Evitar que os Inicializadores padroes sejam carregados indevidamente �
//������������������������������������������������������������������������
PutFileInEof( "RBM" )

Begin Sequence

	//��������������������������������������������������������������Ŀ
	//� Se a Linha da GetDados Nao Estiver Deletada				   	 �
	//����������������������������������������������������������������
	If !( GdDeleted() )
	
		//��������������������������������������������������������������Ŀ
		//� Verifica Itens Duplicados na GetDados						 �
		//����������������������������������������������������������������
		aCposKey := { "RBM_CODCOM" }
		If !( lLinOk := GdCheckKey( aCposKey , 4 ) )
			Break
		EndIf
	
		//��������������������������������������������������������������Ŀ
		//� Verifica Se o Campos Estao Devidamente Preenchidos		   	 �
		//����������������������������������������������������������������
		If !( lLinOk := GdNoEmpty( aCposKey ) )
	    	Break
		EndIf

	ElseIf aCols[n][len(aCols[n])]	// Se linha tiver deletada   

		dbSelectArea("RBH")
		dbSetOrder(3)
		If dbSeek(xFilial("RBH")+GdFieldGet("RBM_CODCOM") )
			While !Eof() .And. ( RBH->RBH_CODCOM == GdFieldGet("RBM_CODCOM") )
				If M->Q0_GRUPO == RBH->RBH_GRUPO
					Aviso(STR0014, STR0015, {"Ok"},,STR0016+RBH->RBH_CARGO)	//"Atencao"###"Competencia esta sendo utilizada por Este Cargo."###"Cargo: "
					lLinOk := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
		dbSetOrder(1)
		Break
	EndIf
	
End Sequence

//��������������������������������������������������������������Ŀ
//�Se Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  �
//����������������������������������������������������������������
If !( lLinOk )
	oBrowse:SetFocus()
EndIf

RestArea(aSaveArea)

Return( lLinOk )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GdRBMTudOk   � Autor �Emerson Grassi Rocha� Data � 19/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tudo Ok da GetDados.                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GdRBMLinOk( oBrowse )										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�								                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Trma030                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GdRBMTudOk( oBrowse )

Local lTudoOk	:= .T.
Local nSvn		:= oBrowse:nAt
Local nx		:= 0

	Begin Sequence
	
		//��������������������������������������������������������������Ŀ
		//� Percorre Todas as Linhas para verificar se Esta Tudo OK      �
		//����������������������������������������������������������������
		For nx := 1 To Len( aCols )
			n := nx
			IF !( lTudoOk := GdRBMLinOk( oBrowse ) )
				oBrowse:Refresh()
				Break
			EndIF
		Next nx
	
		n := nSvn
	
		//Valida se pontuacao maximo esta preenchido e se e' maior que pontuacao minimo
		If ( !Empty( M->Q0_PMIN ) .Or. !Empty( M->Q0_PMAX ) ) .And. M->Q0_PMAX <= M->Q0_PMIN
			Aviso(STR0014, STR0018, {"Ok"})	//"Atencao"###"A pontua��o m�xima deve ser maior do que a pontua��o m�nima"
			lTudoOk := .F.
		EndIf

	End Sequence

Return( lTudoOk  )
                  

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RbmCodWhen   � Autor �Emerson Grassi Rocha� Data � 19/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida campo RBM_CODCOM.                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �RbmCodWhen()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�								                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �X3_WHEN                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RbmCodWhen()
Local lRet	:= .F.
If Inclui .Or. Empty(M->RBM_CODCOM)
	lRet := .T.
EndIf
Return lRet    

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �21/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TRMA030                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada 								 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada 						 �
//�    1 - Pesquisa e Posiciona em um Banco de Dados			 �
//�    2 - Simplesmente Mostra os Campos						 �
//�    3 - Inclui registros no Bancos de Dados					 �
//�    4 - Altera o registro corrente							 �
//�    5 - Remove o registro corrente do Banco de Dados 		 �
//����������������������������������������������������������������

Local aRotina :=   {	{ STR0002	,"PesqBrw", 0 , 1,,.F.},; 	//"Pesquisar"
						{ STR0003	,"Tr030Mnt", 0 , 2},;	//"Visualizar"
						{ STR0004	,"Tr030Mnt", 0 , 3},;	//"Incluir"
						{ STR0005	,"Tr030Mnt", 0 , 4},;	//"Alterar"    	  							      		
		    			{ STR0006	,"Tr030Mnt", 0 , 5}}	//"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tr030VldTmk � Autor � Vendas/CRM	        � Data � 28/03/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o Grupo n�o esta sendo utilizado pela rotina   ���
��� 		 � de Cadastro de Contatos.								      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TRMA030 	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Tr030VldTmk(cGrupo)

Local cQuery := ""
Local cAlias := ""
Local lRet	 := .F.

cAlias := GetNextAlias()
cQuery += " SELECT COUNT(*) TOTAL FROM " + RetSqlName("SU5")
cQuery += " WHERE "
cQuery += " U5_FILIAL = '" + xFilial("SU5") + "' AND "
cQuery += " U5_GRUPO  = '" + cGrupo + "' AND "
cQuery += " D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

If (cAlias)->TOTAL > 0
	lRet := .T.
EndIf

(cAlias)->(dbCloseArea())

Return lRet