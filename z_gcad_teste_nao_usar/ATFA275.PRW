#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'ATFA275.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Atfa275  � Autor � Claudio Donizete      � Data �21.06.2010��� 
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Configurador do grupo de campos                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Atfa275()                                                  ���
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
Function Atfa275
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro 	:= STR0001		//"Configurador do grupo de campos "

mBrowse( 6, 1,22,75,"SNK")

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Atfa275Man� Autor � Claudio Donizete      � Data � 21/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Manutencao Config. grupo de campo                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias da tabela de configuracao do grupo de campos	  ���
���          �ExpN2: Recno da tabela de configuracao do grupo de campos   ���
���          �ExpN3: Opcao do arotina                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Atfa275Man()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atfa275                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Atfa275Man(cAlias,nReg,nOpc)

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize() 

Local cSeek     := ""
Local cWhile    := ""

Local oDlg

Local lContinua := .T.

Local nX        := 0
Local nOpca     := 0
Local nSaveSx8  := GetSx8Len()
Local aCpoGDa   := {'NK_GRUPO','NK_DGRUPO','NK_CBASE','NK_UCBASE'} // Vetor responsavel pela montagem da aHeader
Local aCampos	 := {}
Local oGetD

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aCols     := {}
Private aHeader   := {}
Private n		   := 1
Private aTELA[0][0],aGETS[0]
Private Inclui   := (nOpc == 3)
Private Altera   := (nOpc == 4)

If nOpc > Len(aRotina)
	nOpc := 1
Endif

//��������������������������������������������������������Ŀ
//� Verifica se o arquivo est� realmente vazio ou se       �
//� est� posicionado em outra filial.                      �
//����������������������������������������������������������
If !INCLUI .And. (SNK->(EOF()) .or. SNK->NK_FILIAL # xFilial("SNK"))
   HELP(" " , 1 , "ARQVAZIO")
   lContinua := .F.
Endif

If lContinua

	If Inclui
		RegToMemory( cAlias, .T., .F. )
	Else
		If SoftLock(cAlias)
			RegToMemory( cAlias, .F., .F. )
		Else
			lContinua := .F.
		EndIf
	EndIf

	dbSelectArea(cAlias)
	dbSetOrder(1)
	
	If lContinua

		aObjects := {} 
		AAdd( aObjects, { 30,  70, .t., .t. } )
		AAdd( aObjects, { 20, 180, .t., .t. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
		aPosObj := MsObjSize( aInfo, aObjects ) 
		
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek(cAlias)            
		
		While ( !Eof() .And. SX3->X3_ARQUIVO == cAlias)
			If (ALLTRIM(SX3->X3_CAMPO) $ "NK_GRUPO/NK_DGRUPO/NK_CBASE/NK_UCBASE")
   	   	aAdd(aCampos,AllTrim(SX3->X3_CAMPO))
   	   Else
   	   	If !Alltrim(SX3->X3_CAMPO) $ "NK_FILIAL"
					Aadd(aHeader,{ AllTrim(X3Titulo()),;
								SX3->X3_CAMPO	,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID	,;
								SX3->X3_USADO	,;
								SX3->X3_TIPO	,;
								SX3->X3_F3 		,;
								SX3->X3_CONTEXT,;
								SX3->X3_CBOX	,;
								SX3->X3_RELACAO})
				Endif
			Endif
			dbSelectArea("SX3")
			dbSkip()
		EndDo

   	// Carrega aHeader                                                                                                                
		If !Inclui
			cSeek  := xFilial(cAlias)+M->NK_GRUPO
			cWhile := "SNK->NK_FILIAL+SNK->NK_GRUPO"
         nRecno := (cAlias)->(Recno())                                                                                                                       
			// Carregue aqui a Montagem da sua aCol                                                                                         
			aAux := {}                          
			dbSelectArea(cAlias)
			dbSetOrder(1)	
			MsSeek(cSeek)
			While (cAlias)->(!eof()) .and. cSeek == &cWhile
				aAux := {}
				For nX := 1 To Len(aHeader)
					If aHeader[nX,10] == "V"
						Aadd(aAux,CriaVar(Alltrim(aHeader[nX,2])))
					Else
						Aadd(aAux,(cAlias)->&(Alltrim(aHeader[nX,2])))
					EndIf
				Next	
				Aadd(aAux,.F.)                      
				Aadd(aCols,aAux)
				dbSelectArea(cAlias)
		   	dbSkip()
			Enddo                             
			aColsCpy := aClone(aCols)
         dbGoTo(nRecno)
		Endif
		If Empty(aCols)
			Aadd(aCols, Array(Len(aHeader)))
			For nX := 1 to Len(aHeader)
				//���������������������������Ŀ
				//� Monta Array de 1 elemento �
				//� vazio. Se inclus�o.       �
				//�����������������������������
				If nOpc == 3
					aCols[1,nX]:= CriaVar(allTrim(aHeader[nX][2]))
				End
			Next	
			Aadd(aCols[Len(aCols)],.F.)
		Endif
		
	 	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
		
		oTela     := FWFormContainer():New( oDlg )
		cIdBrowse := oTela:CreateHorizontalBox( 18 )
		cIdRodape := oTela:CreateHorizontalBox( 75 )
		oTela:Activate( oDlg, .F. )
		
		oPanel1  := oTela:GeTPanel( cIdBrowse )
		oPanel2  := oTela:GeTPanel( cIdRodape )
		
		oEnc01 := MsmGet():New( cAlias , nReg , nOpc , NIL , NIL    , NIL  , aCampos , {,,,} ,    ,   NIL ,    NIL ,     NIL ,        , oPanel1)
		oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
		
		oGetD := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],If(!Inclui.And. !Altera,0,GD_INSERT+GD_UPDATE+GD_DELETE),{ ||Atfa275LOk(aCols, aHeader, oGetD:nAt ) },,,/*alteraveis*/,/*freeze*/,4096,/*fieldok*/,/*superdel*/,/*delok*/,oPanel2,aHeader,aCols)	
		oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetD:oBrowse:bChange := { || Atfa275ChLin(oGetD) }
			
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,aCols:=oGetD:aCols,If(Obrigatorio(aGets,aTela) .And. oGetD:TudoOk(),oDlg:End(), nOpca :=  0 )},{|| nOpca := 2,oDlg:End()})
		
		If nOpca == 1 .And. nOpc <> 2
		
			Begin Transaction
				lGravou := Atfa275Grv(nOpc,aCols,aHeader, aCampos,If(nOpc==3,aCols,aColsCpy))
				
				If ( lGravou )
					EvalTrigger()
					While (GetSx8Len() > nSaveSx8)
						ConfirmSx8()
					EndDo
				EndIf
				
			End Transaction
		
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo
		Else
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			EndDo			
		Endif	
	Endif	

Endif
DbSelectArea(cAlias)
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ATFF3SX3
Fun��o gen�rica para montagem de tela de consulta padrao para campos do sistema
Uso Geral.

@param 	cFiltro 	    Filtro para a consulta
@sample ATFF3SX3( "X3_ARQUIVO =='SA1'" )
@author Ernani Forastieri e Claudio Donizete
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function AtfF3SX3( cFiltro )
Local aArea    := GetArea()
Local lRet     := .F.
Local oDlg, oBrowse, oMainPanel, oPanelBtn, oBtnOK, oBtnCan
Local oColumn1, oColumn2, oColumn3, oColumn4

ParamType 0 Var cFiltro    As Character Optional Default ''

If Type("oWizard")=='O' .And. Type("oGetDados")=='O' .And. Type("cFltWizEnt")='C'
	cFiltro := cFltWizEnt
EndIf

If Select( 'ATFSX3' ) == 0
	OpenSxs(,,,,cEmpAnt,"ATFSX3","SX3",,.F.)
EndIf

Define MsDialog oDlg From 0, 0 To 390, 515 Title STR0002 Pixel Of oMainWnd		//"Consulta Padr�o - Campos do Sistema"

@00, 00 MsPanel oMainPanel Size 250, 80
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00, 00 MsPanel oPanelBtn Size 250, 15
oPanelBtn:Align := CONTROL_ALIGN_BOTTOM

Define FWBrowse oBrowse DATA TABLE ALIAS 'ATFSX3'  NO CONFIG  NO REPORT ;
DOUBLECLICK { || lRet := .T.,  oDlg:End() } Of oMainPanel
ADD COLUMN oColumn1  DATA { || ATFSX3->X3_CAMPO   }  Title STR0003  Size Len( ATFSX3->X3_CAMPO   ) Of oBrowse // "Campo"
ADD COLUMN oColumn2  DATA { || If(__LANGUAGE=="SPANISH",ATFSX3->X3_TITSPA, If(__LANGUAGE=="ENGLISH",ATFSX3->X3_TITENG, ATFSX3->X3_TITULO)) }  Title STR0004 Size Len( ATFSX3->X3_TITULO ) Of oBrowse			//"Titulo"
ADD COLUMN oColumn3  DATA { || If(__LANGUAGE=="SPANISH",ATFSX3->X3_DESCSPA, If(__LANGUAGE=="ENGLISH",ATFSX3->X3_DESCENG, ATFSX3->X3_DESCRIC)) }  Title STR0005 Size Len( ATFSX3->X3_DESCRIC ) Of oBrowse		//"Descri��o"
If !Empty( cFiltro )
	oBrowse:SetFilterDefault( cFiltro )
EndIf
oBrowse:Activate()

Define SButton oBtnOK  From 02, 02 Type 1 Enable Of oPanelBtn ONSTOP STR0006 ;				//"Ok <Ctrl-O>"
Action ( lRet := .T., oDlg:End() )

Define SButton oBtnCan From 02, 32 Type 2 Enable Of oPanelBtn ONSTOP STR0007 ;				//"Cancelar <Ctrl-X>"
Action ( lRet := .F., oDlg:End() )

Activate MsDialog oDlg Centered

ATFSX3->( dbClearFilter() )

RestArea( aArea )

Return lRet

/*/
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o	 �Atfa275Grv  � Autor � Claudio D. de Souza   � Data � 25/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os dados do aCols a da Enchoice na tabela SNK            ���
����������������������������������������������������������������������������Ĵ��
���Parametros� nOpc,aCols, aHeader, aCampos, aColsCpy                        ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Atfa275LOk(aCols, aHeader, nLinAtu)    				   		  ���
����������������������������������������������������������������������������Ĵ��
��� Uso		 � ATFA275 										   							  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Atfa275Grv(nOpc,aCols,aHeader,aCampos,aColsCpy)
Local lRet := .T.
Local nX, nY
Local nLen := Len(aCols)
Local lDeleted
Local lAchou := .F.
Local nLenAcolsCpy := Len(aColsCpy)

		For nX := 1 To nLen
			lDeleted := GdDeleted(nX,aHeader,aCols)
			If nOpc == 3
				If !lDeleted
					RecLock("SNK",.T.)
					SNK->NK_FILIAL := xFilial("SNK")
				Endif	
			Else
				lAchou := .F.
				If nOpc == 4 .And. nX <= nLenAcolsCpy
					lAchou := SNK->(MsSeek(xFilial("SNK") + M->NK_GRUPO + GdFieldGet("NK_CAMPO",nX,,aHeader,aColsCpy)))
				Else
					lAchou := SNK->(MsSeek(xFilial("SNK") + M->NK_GRUPO + GdFieldGet("NK_CAMPO",nX,,aHeader,aCols)))
				Endif
				If lAchou
					RecLock("SNK",.F.)
				ElseIf nOpc == 4 .And. !lDeleted
					RecLock("SNK",.T.)
					SNK->NK_FILIAL := xFilial("SNK")	
				Endif
			Endif	
			If nOpc == 5 .Or. (nOpc==4 .And. lDeleted .And. lAchou)
				DbDelete()
			Else
				If !lDeleted
					For nY := 1 To Len(aCampos)
						If SNK->(FieldPos(aCampos[nY])) > 0
							SNK->&(aCampos[nY]) := M->&(aCampos[nY])
						Endif	
					Next
					For nY := 1 To Len(aHeader)
						If aHeader[nY,10] <> "V"
							SNK->&(aHeader[nY,2]) := aCols[nX,nY]
						Endif	
					Next
				Endif	
			Endif	
			MsUnlock()
		Next
	
Return lRet

/*/
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o	 �Atfa275LOk  � Autor � Claudio D. de Souza   � Data � 25/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Valida a linha da GetDados                                     ���
����������������������������������������������������������������������������Ĵ��
���Parametros� aCols, aHeader, nLinAtu 								   			  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Atfa275LOk(aCols, aHeader, nLinAtu)    				   		  ���
����������������������������������������������������������������������������Ĵ��
��� Uso		 � ATFA275 										   							  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Atfa275LOk(aCols, aHeader, nLinAtu)
Local lRet := .T.
Local nX
Local nLen := Len(aCols)
Local nPosCpo := GdFieldPos("NK_CAMPO", aHeader)
Local nAscan
Local cCampo

nAscan := Ascan(aCols, {|e| e[nPosCpo] == aCols[nLinAtu,nPosCpo]} )

If nAscan # nLinAtu .And. nAscan > 0
	lRet := .F.
	Help("",1, "JAGRAVADO")
Endif
If lRet
	cCampo := GdFieldGet("NK_CAMPO",nLinAtu,,aHeader,aCols)
	If X3Obrigat(cCampo)
		lRet := .F.
		Help("",1, "ATFINVCPO")
	ElseIf !X3Usado(cCampo)
		lRet := .F.
		Help("",1, "ATFINVCPO")
	Endif
Endif

Return lRet

/*/
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o	 �Atfa275ChLin� Autor � Claudio D. de Souza   � Data � 26/07/10  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Posiciona no registro da tabela SNK, conforme a linha atual    ���
����������������������������������������������������������������������������Ĵ��
���Parametros� oGetD = Objeto GetDados									   			  ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Atfa275ChLin(oGetD}        			    				   		  ���
����������������������������������������������������������������������������Ĵ��
��� Uso		 � ATFA275 										   							  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function Atfa275ChLin(oGetd)

If ALTERA .And. Len(aCols) > 1 .And. oGetD:nAt <= Len(oGetD:aCols)

	// Posiciona no SNK na mudanca de linha, para que a funcao existChav da validacao no campo NK_CAMPO funcione
	// conforme o esperado
	SNK->(DbSetOrder(1))
	SNK->(MsSeek(xFilial("SNK")+M->NK_GRUPO + GdFieldGet("NK_CAMPO",oGetD:nAt,,oGetD:aHeader,oGetD:aCols)))
	
EndIf	

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Claudio Donizete      � Data �21/07/2010���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     		  ���
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
Local aRotina	:= {} 
	Aadd( aRotina, {"Pesquisar"		,"AxPesqui"   , 0 , 1, 0, .F.	} )
	Aadd( aRotina, {"Visualizar"	,"Atfa275Man" , 0 , 2, 0, nil	} )	
	Aadd( aRotina, {"Incluir"		,"Atfa275Man" , 0 , 3, 0, nil	} )	
	Aadd( aRotina, {"Alterar"		,"Atfa275Man" , 0 , 4, 0, nil	} )	
	Aadd( aRotina, {"Excluir"		,"Atfa275Man" , 0 , 5, 3, nil	} )
Return aRotina




