#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA220.CH"

Function CRDA220()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Define o menu da gestao de acervos                                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Private aCols 	:= {}													// Campos da GetDados
Private aHeader	:= {}												 	// Array com Cabecalho dos campos
Private aRotina := MenuDef()
					
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Define o cabe놹lho da tela de atualiza뇇es                              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Private cCadastro	:= STR0008 //"Regras de Pontua豫o"

mBrowse( 6, 1,22,75,"MAS" )

Return Nil

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un豫o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Defini豫o do aRotina (Menu funcional)                      낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � MenuDef()                                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � CRDA220                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function MenuDef()
	Local aRotina := {	{STR0001	,"AxPesqui"		,0	,1	,0	,.F.	}	,;	 	//"Pesquisar"
					 	{STR0002	,"Crd220Man"	,0	,2	,0	,.T.	}	,;	 	//"Visualizar"
						{STR0003	,"Crd220Man"	,0	,3	,0	,.T.	}	,;	 	//"Incluir"
						{STR0004	,"Crd220Man"	,0	,4	,0	,.T.	}	,;	 	//"Alterar"
						{STR0005	,"Crd220Man"	,0	,5	,0	,.T.	}	} 	 	//"Excluir"
Return aRotina


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎RDA220Man튍utor  쿘arcos R. Andrade   � Data �  29/11/05   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿑uncao para manutencao no cadastro de campanha              볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞IGACRD                                                     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Crd220Man( cAlias, nReg, nOpc )

Local lProcessa		:= .T.						// Valida se exite o processamento ou nao
Local nSaveSx8		:= GetSx8Len()				// Controle de semaforo
Local aCamposEnc	:= {}						// Relacao dos campos que estao na enchoice para gravacao do
Local nX			:= 0                     	// Contador
Local aRecno		:= {}						// Array com a posicao do Registro
Local lRet			:= .F.						// Variavel de retorno	
Local cOperacao		:= ""						// Opercao clicada pelo usuario (Inclusao, Alteracao,...)

Do Case
	Case nOpc == 2
		cOperacao := STR0002 //"Visualizar"
	Case nOpc == 3
		cOperacao := STR0003 //"Incluir"
	Case nOpc == 4
		cOperacao := STR0004 //"Alterar"
	Case nOpc == 5
		cOperacao := STR0005 //"Excluir"
EndCase

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣alida se for exclusao e se pode excluir�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc == 5
	lProcessa := Crd220CanDel()
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Forca a abertura dos arquivos                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

If lProcessa
	
	DbSelectArea("MAS")
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Inicializacao das variaveis da Enchoice                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	RegToMemory( "MAS", (nOpc==3), (nOpc==3) )
	
	DbSelectArea( "SX3" )
	SX3->(DbSetOrder(1))	// X3_ARQUIVO+X3_ORDEM
	SX3->(DbSeek( "MAS" ))
	While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "MAS"
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			aAdd( aCamposEnc, SX3->X3_CAMPO )
		Endif
		SX3->(DbSkip())
	End
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cria aHeader e aCols da GetDados �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nUsado	:=0
	DbSelectArea("SX3")
	SX3->(DbSeek("MAT"))
	aHeader	:={}
	
	While !SX3->(Eof()) .AND. (X3_ARQUIVO == "MAT" )
		If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
			Aadd(aHeader,{ 	TRIM( SX3->X3_TITULO )	,;  //01 - Titulo
							SX3->X3_CAMPO			,;	//02 - campo
							SX3->X3_PICTURE			,;	//03 - Picture
							SX3->X3_TAMANHO			,;	//04 - Tamanho
							SX3->X3_DECIMAL			,;	//05 - Decimal
							SX3->X3_VALID			,;	//06 - Valid do campo (Sistema)
							SX3->X3_USADO			,;	//07 - Usado ou nao
							SX3->X3_TIPO			,;	//08 - Tipo
							SX3->X3_ARQUIVO			,;	//09 - Arquivo
							SX3->X3_CONTEXT } )			//10 - Contexto
		Endif
		SX3->(DbSkip())
	End
	
	aCols:={}
	DbSelectArea("MAT")
	MAT->(DbSetOrder(1))
	nUsado	:= Len( aHeader )
	
	If !INCLUI
		If MAT->(DbSeek( xFilial( "MAT" ) + M->MAS_CODCAM ))
			
			While 	!MAT->(EOF())							.AND.;
					MAT->MAT_FILIAL == xFilial( "MAT" ) 	.AND.;
					MAT->MAT_CODCAM == M->MAS_CODCAM
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Nao acrescenta recno caso for copia�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				AAdd( aCols, Array( nUsado + 1 ) )
				AAdd( aRecno, MAT->( Recno() ) )
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� Acrescenta acols de regras�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
				For nX := 1 To nUsado
					If ( aHeader[nX][10] <>  "V" )
						aCols[Len( aCols )][nX] := MAT->( FieldGet( FieldPos( aHeader[nX][2] ) ) )
					Else
						aCols[Len( aCols )][nX] := CriaVar( aHeader[nX][2], .T. )
					Endif
				Next nX
				
				aCols[Len( aCols )][ nUsado + 1 ] := .F.
				
				MAT->( DbSkip() )
			End
		Endif
		
	Else
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Se for uma inclusao inicializa o acols     �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		AAdd( aCols, Array( nUsado + 1 ) )
		For nX := 1 To nUsado
			If AllTrim( aHeader[ nX][2] ) == "MAT_ITEM"
				aCols[Len( aCols )][nX] := StrZero( 1, Len( MAT->MAT_ITEM ) )
			Else
				aCols[Len( aCols )][nX] := CriaVar( aHeader[nX][2], .T. )
			Endif
			aCols[Len( aCols )][ nUsado + 1 ] := .F.
			
		Next nX
		
	Endif
	
	If Len( aCols ) >= 0
		
		//旼컴컴컴컴컴컴컴컴컴커
		//� Executa a Modelo 3 �
		//읕컴컴컴컴컴컴컴컴컴켸
		cTitulo			:= STR0008 + " - " + cOperacao // Regras de pontuacao
		cLinOk			:= "CRD220LOK()"
		cTudOk			:= "CRD220TOK()"
		cFieldOk		:= "AllwaysTrue()"
		lRet 			:=CRD220Tela(	cTitulo,	"MAS",	"MAT",	aCamposEnc,;
										cLinOk,		cTudOk,	nOpc,	nOpc,;
										cFieldOk )
		
		//旼컴컴컴컴컴컴컴컴컴컴컴커
		//� Executar processamento �
		//읕컴컴컴컴컴컴컴컴컴컴컴켸
		If lRet
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Chama a funcao de gravacao - PONTOS DA CAMPANHA                         �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			lGravou := Crd220Grv(	nOpc,	aCamposEnc, aHeader, aCols,;
									aRecno )
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Controle do semaforo                                                    �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			If lGravou
				If nOpc == 3
					While ( GetSx8Len() > nSaveSx8 )
						ConfirmSx8()
					End
				Endif
			Else
				While ( GetSx8Len() > nSaveSx8 )
					RollBackSx8()
				End
			Endif
			
		Else
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Controle do semaforo                                                    �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			While (GetSx8Len() > nSaveSx8)
				RollBackSx8()
			End
		Endif
	Endif
Else
	Help(" ",1,"NODELETA")
Endif

Return Nil

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴컴엽�
굇쿑un뇚o    쿎rd220Grv � Autor � Henry Fila            � Data � 17/02/2005 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴컴눙�
굇쿏escri뇚o 쿝otina de Gravacao da campanha                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   쿎rd220Grv                                                     낢�
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
굇�              �        �      �                                          낢�
굇읕컴컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function Crd220Grv(	nOpc,		aCamposEnc, 	aHeader,	aCols,;
							aRecno )

Local aArea     := GetArea()						// Salva a area atual
Local bCampo 	:= {|nCPO| Field(nCPO) }    		// Nome do campo	
Local cItem     := Repl("0",Len( MAT->MAT_ITEM ))	// Numero do Item
Local nX        := 0								// Contador 
Local nField    := 0								// Contador
Local nLinha    := 0								// Contador de linhas do Acols
Local nPos		:= 0								// Posicao do campo MAT_VALOR
Local lTravou   := .F.								// Flag para garantir o lock de registro

DbSelectArea( "MAS" )
DbSelectArea( "MAT" )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e  for INCLUSAO ou ALTERACAO  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If ( nOpc == 3 ) .OR. ( nOpc == 4) 
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿒rava a pesquisa e as regras da pesquisa                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	BEGIN TRANSACTION
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿒rava os dados da Campanha�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
		MAS->(DbSetOrder(1))
		If MAS->(DbSeek( xFilial( "MAS" ) + M->MAS_CODCAM ))
			RecLock("MAS",.F.)
		Else
			RecLock("MAS",.T.)
		Endif       
		        
		For nField := 1 To MAS->( FCount() )	  				
  			FieldPut(nField, M->&(EVAL( bCampo, nField ) ) )
		Next nField       
		
		Replace MAS->MAS_FILIAL With xFilial("MAS")                         
		
		MAS->(MsUnLock())

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿒rava os dados  do MAT (Pontos da Campanha) - itens do cadastro �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

		bCampo := {|nCPO| Field(nCPO) }
		
		For nX := 1 To Len( aCols )
			
			// Flag para garantir o lock de registro
			lTravou := .F.
			
			// Se a linha atual for menor que o total de registros
			If nX <= Len( aRecNo )
				DbSelectArea( "MAT" )
				MAT->(DbGoTo( aRecNo[nX] ))
				RecLock("MAT",.F.)
				
				// Lock do regsitro que sera alterado
				lTravou := .T.
			Endif
			
			// Se a linha atual nao foi DELETADA
			If ( !aCols[nX][nUsado+1] )

				//Se nao fez o LOCK significa que e uma nova Linha
				If !lTravou
					RecLock("MAT",.T.)
				Endif

				cItem := Soma1(cItem,Len(MAT->MAT_ITEM))
				Replace MAT->MAT_FILIAL With xFilial("MAT")
				Replace MAT->MAT_CODCAM With MAS->MAS_CODCAM
				Replace MAT->MAT_ITEM   With cItem
				
				bCampo := {|nCPO| Field(nCPO) }
					
				For nLinha := 1 To MAT->(FCount())
				
					If !(EVAL(bCampo,nLinha) == "MAT_FILIAL") 
						nPos:= Ascan(aHeader,{|x| ALLTRIM(EVAL(bCampo,nLinha)) == ALLTRIM(x[2])})
						If (nPos > 0)
							If (aHeader[nPos][10] <> "V" .AND. aHeader[nPos][08] <> "M")
								Replace MAT->&(EVAL(bCampo,nLinha)) With aCols[nX][nPos]
							Endif
						Endif
					Endif
						
				Next nLinha
				
				lGravou := .T.
			Else
				If lTravou
					RecLock("MAT",.F.)
					MAT->(DbDelete())
				Endif
			Endif
			MAT->(MsUnLock())
			
		Next nX
		
	END TRANSACTION
	
ElseIf !nOpc == 2
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eleta MAT (Pontos da Campanha)            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	DbSelectArea("MAT")
	MAT->(DbSetOrder(1))
	If MAT->(DbSeek(xFilial("MAT")+M->MAS_CODCAM))
		RecLock("MAT",.F.)
		MAT->(DbDelete())
		MAT->(MsUnlock())
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿏eleta MAS (Campanha)                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	DbSelectArea("MAS")
	RecLock("MAS", .F.)
	MAS->(DbDelete())
	MAS->(MsUnlock())

Endif

RestArea(aArea)

Return .T.

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  쿎RD220CanDel� Autor 쿘arcos R. Andrade    � Data �30.11.2003낢�
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

Function Crd220CanDel()

Local lRet 		:= .T.						// Retorno da funcao
Local cAliasMAX	:= "MAX"					// Alias da relacao pontos x campanha x cliente
Local aArea		:= GetArea()				// Salva area

#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ENDIF

#IFDEF TOP
	
	lQuery := .T.
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿣erifica se tem algum registro na tabela MAX (Cliente X Total de pontos da campanha)�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	
	cAliasMAX := "QRYMAX"
	
	cQuery := "SELECT COUNT(*) QTDMAX "
	cQuery += " FROM "
	cQuery += RetSqlName("MAX")+ " MAX "
	cQuery += " WHERE "
	
	cQuery += "MAX_FILIAL = '" + xFilial( "MAX" ) +"' AND "
	cQuery += "MAX_CODCAM = '" + MAS->MAS_CODCAM +"' AND "
	cQuery += "MAX.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAX,.F.,.T.)
	
	If (cAliasMAX)->QTDMAX > 0
		lRet := .F.
	Endif
	
	DbCloseArea()
	
	DbSelectArea("MAS")
	
#ELSE
	cAliasMAX := "MAX"
	DbSelectArea( "MAX" )
	DbSetOrder( 2 )
	
	If MAX->( DbSeek(xFilial("MAX")+ MAS->MAS_CODCAM ) )
		lRet := .F.
	Endif
	
#ENDIF

RestArea( aArea )

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴敲굇
굇튡rograma  쿎RDProcCam 튍utor  쿘arcos Roberto Andrade� Data � 30/11/05 볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴묽�
굇튒esc.     � Verifica se existe alguma campanha ativa.                  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � CRDA220                                                    볍�
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
Function CRD220ProcCam()
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local cAliasMAS	:= "MAS"

#IFDEF TOP
	Local cQuery	:= ""
	Local lQuery	:= .F.
#ELSE
	Local cIndMAS	:= ""
	Local cKey		:= ""
	Local nIndMAS	:= 0
#ENDIF

#IFDEF TOP
	
	lQuery := .T.
	
	cAliasMAS := "QRYMAS"
	
	cQuery := "SELECT COUNT(*) QTDMAS "
	cQuery += " FROM "
	cQuery += RetSqlName("MAS")+ " MAS "
	cQuery += " WHERE "
	
	cQuery += "MAS_FILIAL = '" + xFilial( "MAS" ) +"' AND "
	cQuery += "MAS_CODCAM <> '" + M->MAS_CODCAM + "' AND "
	cQuery += "MAS_STATUS = '1'  AND "
	cQuery += "MAS.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasMAS,.F.,.T.)
	
	If (cAliasMAS)->QTDMAS > 0
		lRet := .F.
	Endif
	
	DbCloseArea()
	
	DbSelectArea("MAS")
	
#ELSE
	cAliasMAS := "MAS"
	DbSelectArea( "MAS" )
	DbSetOrder( 1 )
	cIndMAS := CriaTrab( NIL, .F.)
	
	cKey      := "MAS_FILIAL+MAS_STATUS"
	
	IndRegua( "MAS", cIndMAS, cKey)
	nIndMAS := RetIndex( "MAS" )
	DbSetIndex( cIndMAS + OrDbagExT() )
	DbSetOrder( nIndMAS + 1 )
	
	If MAS->( DbSeek(xFilial("MAS")+'1' ) )
		If MAS->MAS_CODCAM <> M->MAS_CODCAM
			lRet := .F.
		EndIf
	Endif
	
	DbSelectArea("MAS")
	DbClearFilter()
	RetIndex("MAS")
	Ferase(cIndMAS+OrDbagExt())
	
#ENDIF

If !lRet
	Aviso(STR0006, STR0007, {STR0009 } )  // Para ativar esta campanha ser� necess�rio inativar a campanha que esta ativa no momento, OK
EndIf


RestArea( aArea )

Return lRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎RD220LOK 튍utor  쿓anna C. Inglez     � Data �  27/02/06   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿑uncao para validacao do linkok. Valida se o valor foi      볍�
굇�          쿾reenchido.                                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function CRD220LOK()
Local lRet	:= .F.		// Retorno da funcao

If !aCols[n,Len(aHeader)+1]
	If 	(aScan(aHeader,{|x| Alltrim( x[2] ) == "MAT_VALOR"}) ) 	>  0 	.Or.;
		(aScan(aHeader,{|x| Alltrim( x[2] ) == "MAT_PRODUTO"}) ) 	<> "" 	.Or.;
		(aScan(aHeader,{|x| Alltrim( x[2] ) == "MAT_GRUPO"}) ) 	<> ""
		
		lRet	:= .T.
	Endif
Else
	lRet := .T.
EndIf

Return (lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎RD220TOK 튍utor  쿓anna C. Inglez     � Data �  27/02/06   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿑uncao para validacao do TudoOK. Valida se o valor foi      볍�
굇�          쿾reenchido.                                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function CRD220TOK()
Local lRet	:= .F.				// Retorno da funcao
If !Empty( M->MAS_PONTOS )
	lRet	:= .T.
Endif
Return (lRet)
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 쿘odelo3	  � Autor � Wilson				� Data � 17/03/97 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿐nchoice e GetDados									  	  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿹Ret:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  낢�
굇�			 � cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)낢�
굇�			 쿹Ret=Retorno .T. Confirma / .F. Abandona					  낢�
굇�			 쿬Titulo=Titulo da Janela 									  낢�
굇�			 쿬Alias1=Alias da Enchoice									  낢�
굇�			 쿬Alias2=Alias da GetDados									  낢�
굇�			 쿪MyEncho=Array com campos da Enchoice						  낢�
굇�			 쿬LinOk=LinOk 												  낢�
굇�			 쿬TudOk=TudOk 												  낢�
굇�			 쿻OpcE=nOpc da Enchoice									  낢�
굇�			 쿻OpcG=nOpc da GetDados									  낢�
굇�			 쿬FieldOk=validacao para todos os campos da GetDados 		  낢�
굇�			 쿹Virtual=Permite visualizar campos virtuais na enchoice	  낢�
굇�			 쿻Linhas=Numero Maximo de linhas na getdados				  낢�
굇�			 쿪AltEnchoice=Array com campos da Enchoice Alteraveis		  낢�
굇�			 쿻Freeze=Congelamento das colunas.                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 쿝dMake 													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function CRD220Tela(	cTitulo,	cAlias1,	cAlias2,	aMyEncho,;
							cLinOk,		cTudoOk,	nOpcE,		nOpcG,;
							cFieldOk,	lVirtual,	nLinhas,	aAltEnchoice,;
							nFreeze,	aButtons )

Local lRet
Local nOpca 	 := 0
Local nReg		 :=(cAlias1)->(Recno())
Local oDlg
Local oEnchoice
Local aSize      := MsAdvSize( .T., .F., 400 )		// Size da Dialog
Local aObjects   := {} 
Local aInfo      := {}
Local aPosObj    := {}

Private aTELA:=Array(0,0)
Private aGets:=Array(0)
Private bCampo:={|nCPO|Field(nCPO)}

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)
	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Divide a tela horizontalmente para os objetos enchoice e getdados   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )


DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd //"Configura뇙o"

oEnchoice := Msmget():New(cAlias1,nReg,nOpcE,,,,aMyEncho, aPosObj[1], aAltEnchoice,3,,,,,,lVirtual,,,,,,,,.T.)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"+MAT_ITEM",.T.,,nFreeze,,nLinhas,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons),;
AlignObject(oDlg,{oEnchoice:oBox,oGetDados:oBrowse},1,,{110}))

lRet:=(nOpca==1)
Return lRet
