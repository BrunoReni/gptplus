#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA225.CH"
#DEFINE MAXGETDAD 	4096                  
Function CRDA225()
                                   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Define o menu da gestao de acervos                                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Private aCols
Private aHeader
Private aRotina := MenuDef()
                                                                  
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Define o cabe놹lho da tela de atualiza뇇es                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Private cCadastro	:= STR0006 //"Regras de Pontua豫o"

mBrowse( 6, 1,22,75,"MA0" )

Return Nil 

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un豫o    � MenuDef  � Autor � Vendas Clientes       � Data � 13.12.06 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Defini豫o do aRotina (Menu funcional)                      낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � MenuDef()                                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � CRDA225                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"AxPesqui"		,0	,1	,0	,.F.}	,;	//"Pesquisar"
						{STR0002	,"Crd225Man"	,0	,2	,0	,.T.}	,;	//"Visualizar"
						{STR0003	,"Crd225Man"	,0	,3	,0	,.T.}	,;	//"Incluir"
						{STR0004	,"Crd225Man"	,0	,4	,0	,.T.}	,;	//"Alterar"
						{STR0005	,"Crd225Man"	,0	,5	,0	,.T.}	}	//"Excluir"
Return(aRotina)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎RDA225Man튍utor  쿣endas Clientes     � Data �  29/11/05   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿑uncao para manutencao no cadastro de campanha              볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞IGACRD                                                     볍�
굇쳐컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Data   	 쿛rogramador |BOPS    �  Motivo da Alteracao                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴탠컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�05/02/09  쿑ernando    �115958  � Altera豫o feita  para utilizar       낢�
굇�          �            �        쿥alk Trhu                             낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴좔컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Crd225Man( cAlias, nReg, nOpc )
Local aPosObj		:= {}            
Local aObjects		:= {}             
Local aSize			:= MsAdvSize()
Local aInfo1		:= {}						// Variavel para montagem da tela (Folders)
Local aHeader1		:= {}						// aHeader do folder do vale compras
Local aHeader2		:= {}						// aHeader do folder do Brinde
Local aHeader3		:= {}						// aHeader do folder do Self Liquidate
Local aAuxHeader1	:= {}						// Auxiliar do aHeader do folder do vale compras
Local aAuxHeader2	:= {}						// Auxiliar do aHeader do folder do Brinde
Local aAuxHeader3	:= {}						// Auxiliar do aHeader do folder do Self Liquidate
Local aCols1		:= {}						// aCols do folder do vale compras
Local aCols2		:= {}						// aCols do folder do brinde
Local aCols3		:= {}						// aCols do folder do Self Liquidate
Local aPosObj1		:= {}						// Variavel para montagem da tela (Folders)
Local oDlgCamp									// Objeto da janela de cadastro
Local oEnc										// Objeto da enchoice
Local lConfirma		:= .F.						// Variavel da escolha do usuario (confirma ou cancela) a manutencao
Local lProcessa		:= .T.						// Verifica se pode continuar o processamento
Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local nOpcX			:= 0						// Opcao escolhida
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local aRecno1		:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local aRecno2		:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local aRecno3		:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0 						// Variavel para utilizacao do FOR
Local nUsado1	 	:= 0						// Controle da qtde de colunas da aColsMAU
Local nUsado2 		:= 0						// Controle da qtde de colunas da aColsMAU
Local nUsado3 		:= 0						// Controle da qtde de colunas da aColsMAU
Local cRot			:= ""
                                          
Private aTELA[0][0]
Private aGETS[0]

Do Case
	Case nOpc == 1 
		cRot       := STR0001      //"Pesquisar"
	Case nOpc == 2
		cRot       := STR0002      // Visualizar
	Case nOpc == 3
		cRot       := STR0003      //"Incluir"
	Case nOpc == 4
		cRot       := STR0004      //"Alterar"
	Case nOpc == 5
		cRot       := STR0005      // Excluir				
EndCase

If nOpc == 5 //exclusao 

	lProcessa := Crd225CanDel()

EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Forca a abertura dos arquivos                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

If lProcessa
	dbSelectArea("MA0")   
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Inicializacao das variaveis da Enchoice                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	RegToMemory( "MA0", (nOpc==3), (nOpc==3) )
	
	dbSelectArea("SX3")
	dbSetOrder(1)	// X3_ARQUIVO+X3_ORDEM
	dbSeek( "MA0" )
	While !Eof() .AND. SX3->X3_ARQUIVO == "MA0"
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			aAdd( aCamposEnc, SX3->X3_CAMPO )
		EndIf			
		dbSkip()
	End

	aAuxHeader1:= aClone( APBuildHeader( "MAU" ) )
	For nx := 1 to Len( aAuxHeader1 )
		If	Alltrim( aAuxHeader1[nx][2] ) == "MAU_ITEM"	.OR.;
			Alltrim( aAuxHeader1[nx][2] ) == "MAU_PONTOS"	.OR.;
			Alltrim( aAuxHeader1[nx][2] ) == "MAU_VALOR"
			aAdd( aHeader1, aAuxHeader1[nx] )
		EndIf
	Next
	ADHeadRec("MAU",aHeader1)
	nUsado1	:= Len( aHeader1 )
	
	aAuxHeader2:= aClone( APBuildHeader( "MAU" ) )
	For nx := 1 to Len( aAuxHeader2 )
		If	Alltrim( aAuxHeader2[nx][2] ) == "MAU_ITEM"	.OR.;
			Alltrim( aAuxHeader2[nx][2] ) == "MAU_PONTOS"	.OR.;
			Alltrim( aAuxHeader2[nx][2] ) == "MAU_PROD"
			aAdd( aHeader2, aAuxHeader2[nx] )
		EndIf
	Next
	ADHeadRec("MAU",aHeader2,)
	nUsado2	:= Len( aHeader2 )
	
	aAuxHeader3:= aClone( APBuildHeader( "MAU" ) )
	For nx := 1 to Len( aAuxHeader3 )
		If	Alltrim( aAuxHeader3[nx][2] ) == "MAU_ITEM"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_PONTOS"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_PROD"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_PERDES"	.OR.;
			Alltrim( aAuxHeader3[nx][2] ) == "MAU_SEQUEN"
			aAdd( aHeader3, aAuxHeader3[nx] )
		EndIf
	Next
	ADHeadRec("MAU",aHeader3,)
	nUsado3	:= Len( aHeader3 )
	
	dbSelectArea( "MAU" )
	dbSetOrder( 1 )
	
	If !INCLUI
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Monta aHeader e aCols de alteracao dos Pontos da Campanha�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		dbSelectArea( "MAU" )
		dbSetOrder( 1 )
	
		dbSeek( xFilial( "MAU" ) + MA0->MA0_CODCAM )
		
			While MAU->MAU_FILIAL == xFilial( "MAU" ) .AND.;
				MAU->MAU_CODCAM == MA0->MA0_CODCAM 

			If MAU->MAU_TIPO == "1"
				AAdd( aCols1, Array( nUsado1 + 1 ) )
				AAdd( aRecno1, MAU->( Recno() ) )
			ElseIf MAU->MAU_TIPO == "2"
				AAdd( aCols2, Array( nUsado2 + 1 ) )
				AAdd( aRecno2, MAU->( Recno() ) )
			Else
				AAdd( aCols3, Array( nUsado3 + 1 ) )
				AAdd( aRecno3, MAU->( Recno() ) )
			EndIf

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Acrescenta acols de regras�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
			For nX := 1 To nUsado1
				If MAU->MAU_TIPO == "1"
					If IsHeadRec(aHeader1[nX][2])
						aCols1[Len( aCols1 )][nX]:= MAU->(Recno()) 
		   			Elseif IsHeadAlias(aHeader1[nX][2])
			   			aCols1[Len( aCols1 )][nX]:= "MAU"
					ElseIf ( aHeader1[nX][10] <>  "V" ) .OR. Alltrim( aHeader1[nX][2] ) == "MAU_ITEM"
						aCols1[Len( aCols1 )][nX] := MAU->( FieldGet( FieldPos( aHeader1[nX][2] ) ) )
					Else
						aCols1[Len( aCols1 )][nX] := CriaVar( aHeader1[nX][2], .T. )
					EndIf
					aCols1[Len( aCols1 )][ nUsado1 + 1 ] := .F.
				EndIf
			Next nX

			For nX := 1 To nUsado2
				If MAU->MAU_TIPO == "2"
					If IsHeadRec(aHeader2[nX][2])
						aCols2[Len( aCols2 )][nX]:= MAU->(Recno()) 
		   			Elseif IsHeadAlias(aHeader2[nX][2])
			   			aCols2[Len( aCols2 )][nX]:= "MAU"
					ElseIf ( aHeader2[nX][10] <>  "V" ) .OR. Alltrim( aHeader1[nX][2] ) == "MAU_ITEM"
						aCols2[Len( aCols2 )][nX] := MAU->( FieldGet( FieldPos( aHeader2[nX][2] ) ) )
					Else
						aCols2[Len( aCols2 )][nX] := CriaVar( aHeader2[nX][2], .T. )
					EndIf
					aCols2[Len( aCols2 )][ nUsado2 + 1 ] := .F.
				EndIf
			Next nX

			For nX := 1 To nUsado3
				If MAU->MAU_TIPO == "3"
					If IsHeadRec(aHeader3[nX][2])
						aCols3[Len( aCols3 )][nX]:= MAU->(Recno()) 
		   			Elseif IsHeadAlias(aHeader3[nX][2])
			   			aCols3[Len( aCols3 )][nX]:= "MAU"
					ElseIf ( aHeader3[nX][10] <>  "V" ) .OR. Alltrim( aHeader1[nX][2] ) == "MAU_ITEM"
						aCols3[Len( aCols3 )][nX] := MAU->( FieldGet( FieldPos( aHeader3[nX][2] ) ) )
					Else
						aCols3[Len( aCols3 )][nX] := CriaVar( aHeader3[nX][2], .T. )
					EndIf
					aCols3[Len( aCols3 )][ nUsado3 + 1 ] := .F.
				EndIf
			Next nX

			DbSelectArea( "MAU" )
			DbSkip()
		End
	EndIf		
		
	If Empty( aCols1 )
		AAdd( aCols1, Array( nUsado1 + 1 ) )
	
		For nX := 1 To nUsado1
			If IsHeadRec(aHeader1[nX][2])
				aCols1[Len( aCols1 )][nX]:= 0 
			Elseif IsHeadAlias(aHeader1[nX][2])
				aCols1[Len( aCols1 )][nX]:= "MAU"
			ElseIf AllTrim( aHeader1[nX][2] ) == "MAU_ITEM"
				aCols1[Len( aCols1 )][nX] := StrZero( 1, Len( MAU->MAU_ITEM ) )
			Else
				aCols1[Len( aCols1 )][nX] := CriaVar( aHeader1[nX][2], .T. )
			EndIf
		Next nX
		aCols1[Len( aCols1 )][ nUsado1 + 1 ] := .F.
	EndIf

	If Empty( aCols2 )
		AAdd( aCols2, Array( nUsado2 + 1 ) )
	
		For nX := 1 To nUsado2
			If IsHeadRec(aHeader2[nX][2])
				aCols2[Len( aCols2 )][nX]:= 0  
			Elseif IsHeadAlias(aHeader2[nX][2])
				aCols2[Len( aCols2 )][nX]:= "MAU"

			ElseIf AllTrim( aHeader2[ nX][2] ) == "MAU_ITEM"
				aCols2[Len( aCols2 )][nX] := StrZero( 1, Len( MAU->MAU_ITEM ) )
			Else
				aCols2[Len( aCols2 )][nX] := CriaVar( aHeader2[nX][2], .T. )
			EndIf
		Next nX
		aCols2[Len( aCols2 )][ nUsado2 + 1 ] := .F.
	EndIf

	If Empty( aCols3 )
		AAdd( aCols3, Array( nUsado3 + 1 ) )
	
		For nX := 1 To nUsado3
			If IsHeadRec(aHeader3[nX][2])
				aCols3[Len( aCols3 )][nX]:= 0  
			Elseif IsHeadAlias(aHeader3[nX][2])
				aCols3[Len( aCols3 )][nX]:= "MAU"
			ElseIf AllTrim( aHeader3[ nX][2] ) == "MAU_ITEM"
				aCols3[Len( aCols3 )][nX] := StrZero( 1, Len( MAU->MAU_ITEM ) )
			Else
				aCols3[Len( aCols3 )][nX] := CriaVar( aHeader3[nX][2], .T. )
			EndIf
		Next nX
	
		aCols3[Len( aCols3 )][ nUsado3 + 1 ] := .F.
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Monta aHeader e aCols das Regras da Pesquisa�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	DbSelectArea( "MAU" )
	DbSetOrder( 1 )
			
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Calcula as posicoes dos objetos na tela                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	aSize := MsAdvSize()
	
	AAdd( aObjects, { 100,065,.T.,.T. } )
	AAdd( aObjects, { 100,100,.T.,.T. } )
	
	aInfo 	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Define a interface com o usuario                                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	DEFINE MSDIALOG oDlgCamp TITLE STR0006 + " - " + cRot FROM aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL //"Cadastro de assuntos"
			//旼컴컴컴컴컴컴컴컴컴�
			//� Definindo Enchoice�
			//읕컴컴컴컴컴컴컴컴컴�
			EnChoice( 	cAlias	, nReg	, nOpc	, NIL			,;
						NIL		, NIL	, NIL	, aPosObj[1]	,;
						NIL		, NIL	, NIL	, NIL			,;
						NIL		, NIL	, NIL	, .T. )
	
			//旼컴컴컴컴컴컴컴컴컴컴컴커
			//� Getdados - Alternativas�
			//읕컴컴컴컴컴컴컴컴컴컴컴켸
			
			aTitles := {STR0008,STR0009,STR0010}  //"Vale Compras","Brinde","Self Liquidate"
	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Definindo as Folders                                 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{"","",""},oDlgCamp,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
			oFolder:bSetOption:={|nAtu| .T.}

			oGetd1 := MsNewGetDados():New( 	2,;
											2,;
											aPosObj[2,3]-aPosObj[2,1]-15,;
											aPosObj[2,4]-aPosObj[2,2]-5,;
											IF( Altera .OR. Inclui, GD_INSERT + GD_DELETE + GD_UPDATE, 0 ),;
											"AllwaysTrue()"	,;
											"AllwaysTrue()"	,;
											"+MAU_ITEM"		,;
											NIL				,;
											NIL				,;
											MAXGETDAD		,;
											NIL				,;
											NIL				,;
											NIL				,;
											oFolder:aDialogs[1],;
											aHeader1		,;
											aCols1 )
	
			oGetd2 := MsNewGetDados():New( 	2,;
											2,;
											aPosObj[2,3]-aPosObj[2,1]-15,;
											aPosObj[2,4]-aPosObj[2,2]-5,;
											IF( Altera .OR. Inclui, GD_INSERT + GD_DELETE + GD_UPDATE, 0 ),;
											"AllwaysTrue()"	,;
											"AllwaysTrue()"	,;
											"+MAU_ITEM"		,;
											NIL				,;
											NIL				,;
											MAXGETDAD		,;
											NIL				,;
											NIL				,;
											NIL				,;
											oFolder:aDialogs[2],;
											aHeader2		,;
											aCols2 )	

			oGetd3 := MsNewGetDados():New( 	2,;
											2,;
											aPosObj[2,3]-aPosObj[2,1]-15,;
											aPosObj[2,4]-aPosObj[2,2]-5,;
											IF( Altera .OR. Inclui, GD_INSERT + GD_DELETE + GD_UPDATE, 0 ),;
											"AllwaysTrue()"	,;
											"AllwaysTrue()"	,;
											"+MAU_ITEM"		,;
											NIL				,;
											NIL				,;
											MAXGETDAD		,;
											NIL				,;
											NIL				,;
											NIL				,;
											oFolder:aDialogs[3],;
											aHeader3		,;
											aCols3 )	
	
	
	ACTIVATE MSDIALOG oDlgCamp ON INIT (EnchoiceBar(oDlgCamp,{ ||nOpcX := 1, aCols1 := oGetd1:aCols,aCols2 := oGetd2:aCols, aCols3 := oGetd3:aCols,IF( oGetd1:TudoOk() .AND. oGetd2:TudoOk().AND. oGetd3:TudoOk(), IF( !Obrigatorio( aGets, aTela ), nOpcX := 0, oDlgCamp:End() ), nOpcX := 0 ) }, { ||oDlgCamp:End() }  ) )
	
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Se confirmou, faz a gravacao na base de dados                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If ( nOpcX == 1 )
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Chama a funcao de gravacao - PONTOS DA CAMPANHA                         �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		lGravou := Crd225Grv(	nOpc - 2,	aCamposEnc,	aRecno1, aHeader1, aCols1,;
														aRecno2, aHeader2, aCols2,;
														aRecno3, aHeader3, aCols3 )
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Controle do semaforo                                                    �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If lGravou 
			If nOpc == 3
				While (GetSx8Len() > nSaveSx8)
					ConfirmSx8()
				End
			EndIf
		Else
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			End
		EndIf
		
	Else
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Controle do semaforo                                                    �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		While (GetSx8Len() > nSaveSx8)
			RollBackSx8()
		End
	EndIf
Else
	Help(" ",1,"NODELETA")
EndIf

Return Nil
          
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴컴엽�
굇쿑un뇚o    쿎rd225Grv � Autor � Vendas Clientes       � Data � 17/02/2005 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴컴눙�
굇쿏escri뇚o 쿝otina de Gravacao da campanha                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿎rd225Grv                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿐xpN1: Opcao da Gravacao sendo:                               낢�
굇�          �       [1] Inclusao                                           낢�
굇�          �       [2] Alteracao                                          낢�
굇�          �       [3] Exclusao                                           낢�
굇�          쿐xpA2: Array de registros                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Pesquisa e Resultado                                         낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Atualizacoes sofridas desde a Construcao Inicial.                       낢�
굇쳐컴컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Programador  � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘auro S.      �26/06/07�127549쿟ratamento do datatype do MAU_PONTOS      낢�
굇읕컴컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function Crd225Grv(		nOpc,		aCamposEnc,	aRecno1,	aHeader1,;
								aCols1,		aRecno2,	aHeader2, 	aCols2,;
								aRecno3,	aHeader3,	aCols3 )

Local aArea			:= GetArea()						// Faz o backup da area                     
	
Local bCampo 		:= {|nCPO| Field(nCPO) }			// Captura a posicaodo campo
	
Local cAliasMemo	:= ""								// Alias dos memos virtuais
Local cItem     	:= Repl("0",Len(MAU->MAU_ITEM))	// Reserva espaco para o item da campanha

Local nX        	:= 0								// Variavel de looping
Local nCntFor   	:= 0								// Variavel de looping								
Local nY        	:= 0								// Varicale de looping
Local nUsado1		:= Len( aHeader1 )					// Armazena o tamanho do aHeader
Local nUsado2 		:= Len( aHeader2 )					// Armazena o tamanho do aHeader
Local nUsado3		:= Len( aHeader3 )					// Armazena o tamanho do aHeader
Local nFolder		:= 0								// 
Local nPosPonto		:= 0								// Armazena os pontos da campanha

Local lTravou   	:= .F.  							// Variavel de controle

Local cTipo			:= "C"								// Armazena o tipo do campo MAU_PONTOS
Local aAreaMAU		:= {}								// Backup da area antes de procurar o type do MAU_PONTOS
Local lEntra		:= .F.								// Variavel de controle paraq o MAU_PONTOS do aCols1

aAreaMAU := GetArea()
dbSelectArea("SX3") 
dbSetOrder( 2 )
If dbSeek( "MAU_PONTOS" )
	cTipo := X3_TIPO
EndIf
RestArea( aAreaMAU )

If nOpc <> 3

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿒rava a pesquisa e as regras da pesquisa                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	Begin Transaction

		//旼컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿒rava os dados da Campanha�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
		dbSelectArea("MA0")
		dbSetOrder(1)
		If dbSeek( xFilial( "MA0" ) + M->MA0_CODCAM )
			RecLock( "MA0", .F. )
		Else
			RecLock( "MA0", .T. )
		EndIf
		For nCntFor := 1 To FCount()
			FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
		Next nCntFor
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿒rava os campos Memos Virtuais					 				  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If Type("aMemos") == "A"
			For nCntFor := 1 To Len(aMemos)
				cVar := aMemos[nCntFor][2]
				cAliasMemo := If(len(aMemos[nCntFor]) == 3,aMemos[nCntFor][3],Nil)
				MSMM(,TamSx3(aMemos[nCntFor][2])[1],,&cVar,1,,,"SKC",aMemos[nCntFor][1],cAliasMemo)
			Next nCntFor
		EndIf
                        
		MA0->MA0_FILIAL := xFilial( "MA0" )
		MsUnLock()                                    
		    
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿒rava os dados  do MAU (Pontos da Campanha)�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		For nX := 1 To Len( aCols1 )
			nPosPonto	:=	aScan(aHeader1,{|x| Alltrim( x[2] ) == "MAU_PONTOS"})

			lTravou := .F.
			If nX <= Len( aRecNo1 )
				DbSelectArea("MAU")
				DbGoTo(aRecNo1[nX])
				RecLock("MAU")
				lTravou := .T.
			EndIf
			
			If ( !aCols1[nX][nUsado1+1] )
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿣erifica o tipo do MAU_PONTOS e atribui se pode entrar�
				//쿽u nao.                                               �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				If  cTipo =="C"
					If Val( aCols1[nX][nPosPonto] ) > 0 
						lEntra := .T.
					EndIf	
				Else	 
					If aCols1[nX][nPosPonto] > 0
						lEntra :=.T.
					EndIf
				EndIf   
				
				If lEntra		 
					If !lTravou 
						RecLock("MAU",.T.)
					EndIf
					For nY := 1 To Len(aHeader1)
						If aHeader1[nY][10] <> "V"
							MAU->(FieldPut(FieldPos(aHeader1[nY][2]),aCols1[nX][nY]))
						EndIf
					Next nY
					cItem := Soma1( cItem, Len( MAU->MAU_ITEM ) )
					MAU->MAU_FILIAL	:= xFilial( "MAU" )
					MAU->MAU_CODCAM	:= MA0->MA0_CODCAM
					MAU->MAU_ITEM	:= cItem
					MAU->MAU_TIPO	:= "1"
					MsUnLock()                   
						
					lGravou := .T.
				EndIf
			Else	
				If lTravou        
					RecLock("MAU")
						MAU->( DbDelete() )
					MsUnlock()
				EndIf				
			EndIf
			MsUnLock()		
		Next nX

		For nX := 1 To Len( aCols2 )
			nPosPonto	:=	aScan(aHeader2,{|x| Alltrim( x[2] ) == "MAU_PONTOS"})

			lTravou := .F.
			If nX <= Len( aRecNo2 )
				DbSelectArea("MAU")
				DbGoTo(aRecNo2[nX])
				RecLock("MAU")
				lTravou := .T.
			EndIf
			
			If ( !aCols2[nX][nUsado2 + 1] )   
			
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿣erifica o tipo do MAU_PONTOS e atribui se pode entrar�
				//쿽u nao.                                               �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			    lEntra := .F.
				If  cTipo =="C"
					If Val(aCols2[nX][nPosPonto]) > 0
						lEntra := .T.
					EndIf	
				Else	 
					If aCols2[nX][nPosPonto] > 0
						lEntra :=.T.
					EndIf
				EndIf   
				
				If lEntra		 
					If !lTravou 
						RecLock("MAU",.T.)
					EndIf
					For nY := 1 To Len(aHeader2)
						If aHeader2[nY][10] <> "V"
							MAU->(FieldPut(FieldPos(aHeader2[nY][2]),aCols2[nX][nY]))
						EndIf
					Next nY
					cItem := Soma1( cItem, Len( MAU->MAU_ITEM ) )
					MAU->MAU_FILIAL	:= xFilial( "MAU" )
					MAU->MAU_CODCAM	:= MA0->MA0_CODCAM
					MAU->MAU_ITEM	:= cItem
					MAU->MAU_TIPO	:= "2"
					MsUnLock()                   
						
					lGravou := .T.
				EndIf
			Else	
				If lTravou        
					RecLock("MAU")
						MAU->( DbDelete() )
					MsUnlock()
				EndIf				
			EndIf
			MsUnLock()
		Next nX

		For nX := 1 To Len( aCols3 )
			
			nPosPonto	:=	aScan(aHeader3,{|x| Alltrim( x[2] ) == "MAU_PONTOS"})			
			lTravou := .F.
			If nX <= Len( aRecNo3 )
				DbSelectArea( "MAU" )
				DbGoTo(aRecNo3[nX])
				RecLock( "MAU" )
				lTravou := .T.
			EndIf
			
			If ( !aCols3[nX][nUsado3 + 1] ) 
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿣erifica o tipo do MAU_PONTOS e atribui se pode entrar�
				//쿽u nao.                                               �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			    lEntra := .F.
				If  cTipo =="C"
					If Val(aCols3[nX][nPosPonto]) > 0
						lEntra := .T.
					EndIf	
				Else	 
					If aCols3[nX][nPosPonto] > 0
						lEntra :=.T.
					EndIf
				EndIf   
				
				If lEntra		 
					If !lTravou 
						RecLock("MAU",.T.)
					EndIf
					For nY := 1 To Len( aHeader3 )
						If aHeader3[nY][10] <> "V"
							MAU->(FieldPut(FieldPos(aHeader3[nY][2]),aCols3[nX][nY]))
						EndIf
					Next nY
					cItem := Soma1( cItem, Len( MAU->MAU_ITEM ) )
					MAU->MAU_FILIAL	:= xFilial( "MAU" )
					MAU->MAU_CODCAM	:= MA0->MA0_CODCAM
					MAU->MAU_ITEM	:= cItem
					MAU->MAU_TIPO	:= "3"
					MsUnLock()                   
						
					lGravou := .T.
				EndIf
			Else	
				If lTravou        
					RecLock("MAU")
						MAU->( DbDelete() )
					MsUnlock()
				EndIf				
			EndIf
			MsUnLock()
		Next nX
	End Transaction	
Else
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eleta MAT (Pontos da Campanha)            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	dbSelectArea("MAU")
	dbSetOrder(1)
	If dbSeek(xFilial("MAU")+M->MA0_CODCAM)
		RecLock("MAU")
			dbDelete()
		MsUnlock()
	EndIf	

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eleta MAS (Campanha)                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	dbSelectArea("MA0")
	RecLock("MA0")
		dbDelete()
	MsUnlock()    
EndIf

RestArea(aArea)    

Return .T.
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  쿎RD225CanDel� Autor 쿣endas Clientes      � Data �30.11.2003낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿣alidacao da exclusao da Campanha                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       쿎ampanha de Fidelizacao             					      낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�                Alteracoes desde sua criacao                           낢�
굇쳐컴컴컴컴컫컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                          

Function Crd225CanDel()

Local lRet 		:= .T.
Local cAliasMAY	:= "MAY" 
Local aArea		:= GetArea()


#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ENDIF	

#IFDEF TOP

    lQuery := .T.

	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿣erifica se tem algum registro na tabela MAY (Cliente X Resgate de Vale Compra)     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	cAliasMAY := "QRYMAY"
    
    cQuery := "SELECT COUNT(*) QTDMAY "
    cQuery += " FROM "
    cQuery += RetSqlName("MAY")+ " MAY "
    cQuery += " WHERE "
	    
    cQuery += "MAY_FILIAL = '" + xFilial( "MAY" ) +"' AND "
    cQuery += "MAY_CODCAM = '" + MA0->MA0_CODCAM +"' AND "    
    cQuery += "MAY.D_E_L_E_T_ = ' ' "
	    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAY,.F.,.T.)
		
	If (cAliasMAY)->QTDMAY > 0
		lRet := .F.                	
	EndIf
	
	dbCloseArea()
	
	dbSelectArea("MA0")
	
#ELSE
                                 
	dbSelectArea( "MAY" )
	dbSetOrder( 2 )
		
	If MAY->( dbSeek(xFilial("MAY")+ MA0->MA0_CODCAM ) )
		lRet := .F.
	EndIf              
	
	dbSelectArea("MA0")

                          
#ENDIF

	RestArea( aArea ) 

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴敲굇
굇튡rograma  쿎RDProcCam 튍utor  쿣endas Clientes       � Data � 30/11/05 볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴묽�
굇튒esc.     � Verifica se existe alguma campanha ativa.                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � CRDA225                                                    볍�
굇勁袴袴袴錮賈袴袴佶袴袴袴錮袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇�  DATA  � BOPS 쿛rogram.� ALTERACAO                                    볍�
굇쳐컴컴컴컵컴컴컴탠컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�        �      �        �                                              볍�
굇�        �      �        �                                              볍�
굇�        �      �        �                                              볍�
굇훤袴袴袴賈袴袴袴鳩袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function CRD225ProcCam()
Local lRet 	:= .T.
Local aArea	:= GetArea()
Local cAliasMA0	:= "MA0"

#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ELSE
	Local cIndMA0	:= ""		
	Local cKey		:= ""	
	Local nIndMA0	:= 0
#ENDIF	

#IFDEF TOP

    lQuery := .T.
    
    cAliasMA0 := "QRYMA0"
    
    cQuery := "SELECT COUNT(*) QTDMA0 "
    cQuery += " FROM "
    cQuery += RetSqlName("MA0")+ " MA0 "
    cQuery += " WHERE "
    
    cQuery += "MA0_FILIAL = '" + xFilial( "MA0" ) +"' AND "
    cQuery += "MA0_CODCAM <> '" + M->MA0_CODCAM + "' AND "     
    cQuery += "MA0_STATUS = '1'  AND "    
    cQuery += "MA0.D_E_L_E_T_ = ' ' "
    
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMA0,.F.,.T.)

	If (cAliasMA0)->QTDMA0 > 0
		lRet := .F.
	EndIf	

	dbCloseArea()
	
	dbSelectArea("MA0")
	
#ELSE
                                 
	dbSelectArea( "MA0" )
	dbSetOrder( 1 )
	cIndMA0 := CriaTrab( NIL, .F.)

	cKey      := "MA0_FILIAL+MA0_STATUS"

	IndRegua( "MA0", cIndMA0, cKey)
	nIndMA0 := RetIndex( "MA0" )
	dbSetIndex( cIndMA0 + OrdBagExT() )
	dbSetOrder( nIndMA0 + 1 )	

    If MA0->( dbSeek(xFilial("MA0")+'1' ) )
    	If MA0->MA0_CODCAM <> M->MA0_CODCAM
    		lRet := .F.		
		EndIf
	EndIf	
 
	dbSelectArea("MA0")
	dbClearFilter()
	RetIndex("MA0")
	Ferase(cIndMA0+OrdBagExt())
	
#ENDIF	
          
If !lRet
	Aviso(STR0006, STR0007, {"Ok"} )  // Para ativar esta campanha ser� necess�rio inativar a campanha que esta ativa no momento.
EndIf
RestArea( aArea )

Return lRet
