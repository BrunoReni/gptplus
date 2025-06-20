#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA420.CH"

/*/
旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇚o	   쿒PEA420   � Autor 쿝OMAN DIAZ                       � Data �21/06/2004�
쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿎ADASTRO DE PROCESSOS.                     					          �
쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� 		   ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			          �
쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛rogramador � Data	  � BOPS/FNC       �  Motivo da Alteracao			  		  �
쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿘ohanad Odeh�19/02/13쿘12RH01   RQ0309쿢nificacao dos fontes V12                 �
쿟iago Malta �13/11/13쿝Q2550          쿎ONVERS홒 DE DADOS                        �
쿞idney O.   �31/03/14쿘_RH007   TPCCTW쿌lteracao da descricao dos processos      �
�            �        �                쿾re-definidos                             �
쿎arlos E. O.�10/06/14쿣ER12_TEST      �                                          �
�            �        �          TPVIYP쿣alidacao pra nao deixar excluir processo �
�            �        �                쿿uando vinculado a algum periodo.         �
읕컴컴컴컴컴컨컴컴컴컴좔컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
/*/
Function GPEA420
Local aIndexRCJ	:= {}		//Variavel Para Filtro
Private bFiltraBrw  := {|| Nil}		//Variavel para Filtro
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Processos"

//Inicializa o filtro utilizando a funcao FilBrowse
cFiltraRh := ChkRh("GPEA420","RCJ","1")
bFiltraBrw := { || FilBrowse("RCJ",@aIndexRCJ,@cFiltraRH) }
Eval(bFiltraBrw)

//Inicializa codigos de Processo caso arquivo esteja vazio
If cPaisLoc $ "BRA/RUS"
	GpIniProc()
Endif

dbSelectArea("RCJ")
dbSetOrder(1)

mBrowse( 6,1,22,75, "RCJ", NIL , NIL , NIL , NIL , NIL , if(!(MV_MODFOL == "2"),Gpe420CriaCor(), NIL),,,,,,,,,,,MV_MODFOL )

EndFilBrw( "RCJ" , aIndexRCJ )

Return

/*
旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇚o    쿲pea420Mnt� Autor 쿘auricio T. Takakura   � Data �30/12/2004�
쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇚o 쿎adastro de Processos                                       �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   쿲pea420Mnt( cAlias , nReg , nOpc )						    |
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros쿬Alias = Alias do arquivo                                   �
�          쿻Reg   = Numero do registro                                 �
�          쿻Opc   = Numero da opcao selecionada                        �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      �    	                                                    �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Function Gpea420Mnt(cAlias, nReg, nOpc)
Local aSvKeys				:= GetKeys()	// grava as teclas de atalhos
Local aArea				:= GetArea()	// grava a area da janela
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjSize			:= {}  			// tamanho do objeto
Local aObjCoords			:= {}			// coordenadas do objeto
Local aRCJNotFields		:= {} 			// campos que nao irao aparecer na enchoice
Local aRCJCols			:= {}			// colunas da enchoice
Local aRCJHeader			:= {}			// cabecalho da enchoice
Local aRCJVirtEn			:= {}  			// array com os campos virtuais que irao aparecer na enchoice
Local aRCJVisuEn			:= {}			// array com os campos apenas visuais
Local aRCJRecnos			:= {} 			// array que contem os recnos dos registros
Local aRCJFields			:= {}  			// campos
Local aRCJNaoAlt			:= {}			// campo apenas de consulta - nao editavel
Local aRCJAltera			:= {}			// campos editaveis
Local bSet15				:= { || NIL }		// botao OK
Local bSet24				:= { || NIL }		// botao Cancel
Local cFilRCJ				:= ""			// armazena a filial corrente
Local nLoop				:= 0			// variavel utilizado para for / next
Local nLoops				:= 0.00			// variavel auxiliar - auxiliar para o loop, passando um valor variavel
Local nOpcAlt    		:= 0.00 		// variavel que controla se todos os dados estao OK para serem gravados
Local nRCJUsado			:= 0.00	        // retorna pelo gdmontacols() o numero de campos em uso
Local oDlg				:= NIL			// objeto da Dialog
Local oEnchoice			:= NIL			// objeto da Enchoice

Begin Sequence

	If nOpc = 3 // SE INCLUSAO POSICIONA O REGISTRO NO FINAL DO ARQUIVO
		PutFileInEof( "RCJ" , @nReg )  		 // FUNCAO EM PONXFUN.PRX
	EndIf

	//Elaboracao dos parametros da Enchoice
	aAdd( aRCJNotFields, "RCJ_FILIAL" )
	aAdd( aRCJNotFields, "RCJ_ORIGEM" )
	If cPaisLoc == "PTG"
		aAdd( aRCJNotFields, "RCJ_TIVCV" )
	EndIf

    aRCJCols := RCJ->(GdMontaCols(	@aRCJHeader		,;
    								@nRCJUsado		,;
    								@aRCJVirtEn		,;
    								@aRCJVisuEn		,;
    								NIL				,;
    								aRCJNotFields	,;
    								@aRCJRecnos		,;
    								NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,;
    								.F.				 ;
    							)) // FUNCAO EM PONXFUN.PRX

	cFilRCJ	 := xFilial( "RCJ" )

	//CRIA AS VARIAVEIS DE MEMORIA E CARREGA OS DADOS CONFORME O ARQUIVO	PARA EDICAO NA ENCHOICE
	For nLoop := 1 To nRCJUsado // No. de campos
		aAdd(aRCJFields , aRCJHeader[nLoop, 02])
		Private &("M->"+aRCJHeader[nLoop, 02]) := aRCJCols[01, nLoop]
	Next nLoop

	//DEFINE OS CAMPOS EDITAVEIS NA ENCHOICE
	If (( nOpc == 3 ) .or. ( nOpc == 4 )) // OPCAO 3-INCLUIR E 4-ALTERAR
	   // CAMPOS DE CONSULTA
 		nLoops := Len( aRCJVisuEn ) // CAMPOS VISUAIS
		For nLoop := 1 To nLoops
			aAdd(aRCJNaoAlt, aRCJVisuEn[nLoop])
		Next nLoop

		If nOpc == 4
			aAdd(aRCJNaoAlt, "RCJ_CODIGO")
			If (RCJ->RCJ_ORIGEM == "1") .AND. MV_MODFOL == "1"
				aAdd(aRCJNaoAlt, "RCJ_DESCRI")
			EndIf
		EndIf

		// CAMPOS EDITAVEIS
		nLoops := Len(aRCJFields)
		For nLoop := 1 To nLoops
			If (aScan(aRCJNaoAlt, {|cNaoA| cNaoA == aRCJFields[nLoop]}) == 0.00)
				aAdd(aRCJAltera, aRCJFields[nLoop])
			EndIf
		Next nLoop
	EndIf

	//MONTA AS DIMENSOES DOS OBJETOS
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	//DEFINE O BLOCO PARA A TECLA <CTRL-O> (BOTAO OK)
	bSet15		:= { || If (fValForm(),;// VERIFICA SE RCJ_DIACAL FOR IGUAL A 1 SE O CAMPO RCJ_DIAPRO EST� VAZIO. PARA COLOMBIA E PERU
    						IF(;
								( ( nOpc == 3 ) .or. ( nOpc == 4 )) .and. ;   				// inclusao e alteracao
								Obrigatorio( oEnchoice:aGets , oEnchoice:aTela ) 	.and.;	//Verifica os Campos Obrigatoris na Enchoice
								EnchoTudOk( oEnchoice )				 				     ;	//Valida Todos os Campos da Enchoice
							    ,;
								(;															// situacao verdadeira
									nOpcAlt := 1.00 ,;										// OK para gravacao
									oDlg:End();
							 	),;
							 	IF(; 														// situacao falsa
							 		( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) ,;					//Inclusao ou alteracao
							 			(;
							 				nOpcAlt := 0.00 ,; 								// nao serao permitido a gravacao
							 				.F.;											// permanecera na janela
							 			 ),;
									(;
										nOpcAlt := IF( nOpc == 2 , 0 , 1.00 ) ,;			//Visualizacao ou Exclusao
										oDlg:End();
							 		);
							 	  );
						   );
						,Help(" ",1,"GPEA420DIACAL"); //Se Dias do Calend�rio for selecionado como "Sim", o n�mero de dias por per�odo dever� ser igual a "0"
						);
					 }

	//DEFINE O BLOCO PARA A TECLAS <CTRL-X> (BOTAO CANCELAR)
	bSet24		:= { || ( nOpcAlt := 0.00 , oDlg:End() ) }

	// Monta o Dialogo Principal para a Manutencao
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0006 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // 'Cadastro de Processos'


	//MONTA O OBJETO ENCHOICE PARA O RCJ
	oEnchoice	:= MsmGet():New(	"RCJ"		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRCJFields	,;
									aObjSize[1] ,;
									aRCJAltera	,;
									NIL			,;
									NIL			,;
									NIL         ,;  // opcao para inserir funcao que valida a linha que esta sendo incluida
									oDlg		,;
									NIL			,;
									.T.			,;
									,,,,,,,,,Alltrim(MV_MODFOL))

	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

	//QUANDO CONFIRMADA A OPCAO E NAO FOR VISUALIZACAO GRAVA OU EXCLUI AS INFORMACOES DO RCJ
	If( nOpcAlt == 1 )
 		If ( nOpc == 3 ) .OR. ( nOpc == 4 )

			//GRAVANDO/INCLUINDO
			MsAguarde(;
						{ ||;
					             gpea420Grava(	nOpc		,;	//Opcao de Acordo com aRotina
											 	nReg		,;	//Numero do Registro do Arquivo Pai ( RCJ )
												aRCJHeader	,;	//Campos do Arquivo Pai ( RCJ )
												aRCJVirtEn	;	//Campos Virtuais do Arquivo Pai ( RCJ )
										   );
						};
					 )
		EndIf
	EndIf
End Sequence

RestKeys(aSvKeys)
RestArea(aArea)

Return(Nil)

/*
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇚o    쿲pea420Grava 쿌utor쿘auricio T. Takakura  � Data �30/12/2004�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇚o � Gravacao das informacoes do arquivo RCJ                    �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �<Vide Parametros Formais>									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�<Vide Parametros Formais>									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿢so       쿒pea420                                                     �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Static Function gpea420Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RCJ )
							 	aRCJHeader	,;	//Campos do Arquivo Pai ( RCJ )
							 	aRCJVirtEn	;	//Campos Virtuais do Arquivo Pai ( RCJ )
							  )
Local lLock		:= .F.						// variavel para controle de travar registros
Local nChoice		:= 0						// variavel utilizada para loop
Local nChoices	:= 0.00					// numero de columas
nChoices			:= Len(aRCJHeader)

//Se for Inclusao/Alteracao (nOpc == 3 .or. nOpc == 4)
If (nOpc == 3 .or. nOpc == 4)
	Begin Transaction
		If !Empty(nReg)
			RCJ->(MsGoto(nReg))
			lLock := RecLock("RCJ", .F., .F.)   // bloquear o registro  .F. - alterar; .F. nao forcar gravacao
		Else
			lLock := RecLock("RCJ", .T., .F.)	// .T. incluir um novo registro; .F. nao forcar gravacao
		EndIf

		If !(lLock)
			Break
		EndIf
        RCJ->RCJ_FILIAL := xFilial('RCJ')

        If nOpc == 3 .and. MV_MODFOL == "1"
        	RCJ->RCJ_ORIGEM := "2"
        EndIf

		// GRAVACAO DOS CAMPOS DE FORMA DINAMICA
		For nChoice := 1 To nChoices
			If (aScan(aRCJVirtEn , { |cCpo| (cCpo == aRCJHeader[nChoice, 02])}) == 0.00)
				RCJ->(&(aRCJHeader[nChoice, 02])) :=&("M->"+aRCJHeader[nChoice, 02])
            EndIf
		Next nChoice

		RCJ->(MsUnLock())

	End Transaction
EndIf

Return (Nil)

/*
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇚o    쿒pea420Dele  쿌utor쿝oman Diaz            � Data �23/06/2004�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇚o | Excluir, o usuario nao podera excluir registros do sistema �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �<Vide Parametros Formais>									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�<Vide Parametros Formais>									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿢so       쿒pea420()	                                                �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Function Gpea420Dele( cAlias, nReg, nOpc)

Local aArea		:= GetArea()
Local aAreaRCJ	:= RCJ->(GetArea())
Local aAC    	:= {STR0007 , STR0008}  //'Abandona'###'Confirma'

Local cFil  	:= ""
Local cCodigo  	:= ""
Local cCve     	:= ""
Local cNivant

Local lRet   	:= .T.
Local lAchou 	:= .F.

Local nOpcA

// VARIAVEIS PARA DIMENSIONAR TELA
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

//MONTA A ENTRADA DE DADOS DO ARQUIVO
Private aTELA[0][0], aGETS[0]

Begin Sequence

	nOpcA := 0
	dbSelectArea(cAlias)
	dbSetOrder(1)

	//MONTA AS DIMENSOES DOS OBJETOS
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T.  } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

		nOpcA := EnChoice( cAlias, nReg, nOpc, aAC, 'AC', OemToAnsi(STR0009),,aObjSize[1],,,,,,,,,,,,,,,,,MV_MODFOL )  //'Quanto � exclus꼘?'
        nOpcA := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()}) CENTERED

	If nOpcA == 2

		IF (RCJ->RCJ_ORIGEM) == "1"
			Aviso(cCadastro, OemToAnsi(STR0012), {'OK'})	//"Nao e possivel Excluir um Processo de Sistema"
			Break
		EndIF

		If lAchou == .F.
       		cFil := xFilial('RCJ')
			cCodigo := RCJ->RCJ_CODIGO

			// VERIFICA A INTEGRIDADE COM OUTRAS TABELAS
			lAchou := !Gpea420ChkDel( cAlias , nReg , nOpc , cCodigo)

			// VERIFICA SE O PROCESSO ESTA ASSOCIADO COM: SRA,SRC,RCF,SFG
			If lAchou
				Break
			Else

				RCH->(dbSetOrder(1)) //Ordena por Processo
				If RCH->(dbSeek(cFil + cCodigo)) //Verifica se o Processo existe no cadastro de Periodos
					Aviso(cCadastro, OemToAnsi(STR0025), {'OK'})	//"Nao e possivel Excluir um Processo de Sistema"
					Break
				Endif

				Begin Transaction
					dbSelectArea(cAlias)
					RecLock(cAlias, .F., .T.)
					dbDelete()
					MsUnlock()
					WRITESX2(cAlias,1)
					DbSkip ()
				End Transaction
			EndIf
		Else
			Aviso(OemToAnsi(STR0009), OemToAnsi(STR0010), {'OK'})//"Registro em Uso por outro Usuario"##"Este processo esta em uso e nao pode ser excluido"
		EndIf
	EndIf
End Sequence

RestArea(aAreaRCJ)
RestArea(aArea)

Return Nil

/*
旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇚o    쿒pea420ChkDel쿌utor쿝oman Diaz            � Data �23/06/2004�
쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇚o 쿣erifica se os Registros podem ser Deletados                �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �<Vide Parametros Formais>									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�<Vide Parametros Formais>									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿢so       쿒pea420()	                                                �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Static Function Gpea420ChkDel(	cAlias		,;	//Alias do Arquivo Principal
								nReg		,;	//Recno do Arquivo Principal
								nOpc		,;	//Opcao do Arquivo Principal
								cCodigo		 ;	//Chave para Exclusao (Sem a Filial)
							   )

Local cKeyDel		:= ""
Local lChkDelOk 	:= .T.

DEFAULT cAlias		:= Alias()
DEFAULT nReg		:= (cAlias)->(Recno())
DEFAULT nOpc		:= 5
DEFAULT cCodigo		:= ""

(cAlias)->(MsGoto(nReg))
cKeyDel	:= cCodigo

lChkDelOk  := ChkDelRegs(	cAlias			,;	//Alias do Arquivo Principal
							nReg				,;	//Registro do Arquivo Principal
							nOpc				,;	//Opcao para a AxDeleta
							xFilial(cAlias)	,;	//Filial do Arquivo principal para Delecao
							cKeyDel			,;	//Chave do Arquivo Principal para Delecao
							NIL				   ,;	//Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	//Mensagem para MsgYesNo
							NIL					,;	//Titulo do Log de Delecao
							NIL					,;	//Mensagem para o corpo do Log
							.F.				 	,;	//Se executa AxDeleta
							.T.     			,;	//Se deve Mostrar o Log
							NIL					,;	//Array com o Log de Exclusao
							NIL				 	 ;	//Array com o Titulo do Log
						)

Return(lChkDelOk)

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    쿒pProLeg		쿌utor쿙atie     		  � Data �21/09/2000�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿎ria uma janela contendo a legenda da mBrowse               �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �< Vide Parametros Firmais >									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      쿒pProLeg	                                                �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Retorno  쿙IL															�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�< Vide Parametros Firmais >									�
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Function GpProLeg()

BrwLegenda(	OemToAnsi(cCadastro)						,;	// "Titulo do Cadastro"
			OemToAnsi( STR0013 )						,;	// "Legenda"
			{;
				{"BR_AZUL"		,OemToAnsi(STR0014)	}	,;	// "Processo Exclusivo do Sistema"
				{"BR_VERDE"		,OemToAnsi(STR0015)	}	 ;	// "Processo de Cliente"
			};
		 )

Return( .T. )

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    쿒pe420CriaCor	쿌utor쿝OMAN DIAZ		  � Data �30/12/2004�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿗egenda                                                     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �< Vide Parametros Firmais >									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      쿒pe420CriaCor                                               �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Retorno  쿙IL															�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�< Vide Parametros Firmais >									�
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Function Gpe420CriaCor()
Local aCores := {}

aCores	:=	{;
				{ "RCJ->RCJ_ORIGEM=='2'" , 'BR_VERDE'		},;
				{ "RCJ->RCJ_ORIGEM=='1'" , 'BR_AZUL'		} ;
			 }

//PONTO DE ENTRADA PARA ALTERAR CORES DO BROWSE DO CADASTRO
If ExistBlock("GP420BWCORES")
	IF ValType( uRet := ExecBlock("GP420BWCORES",.F.,.F.,aCores) ) == "A"
		aCores := aClone(uRet)
		uRet	 := NIL
	Endif
EndIf

Return(aCores)

/*/
旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇚o	   쿯ListProc � Autor 쿘auricio Takakura 	  � Data � 06/10/05 �
쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇚o 쿞elecionar Cod. de Processos da Tabela RCJ           	  	�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   � fListProc()												�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿢so	   � Generico 													�
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�/*/
Function fListProc( l1Elem , cPreSelect )
Local aNewSelect		:= {}
Local aPreSelect		:= {}
Local aProcesssos       := {}
Local cFilRCJ			:= xFilial("RCJ")
Local cTitulo			:= ""
Local cReadVar			:= ""
Local MvParDef			:= ""
Local MvRetor			:= ""
Local MvParam			:= ""
Local lRet				:= .T.
Local nFor				:= 0
Local nAuxFor			:= 1
Local MvPar     		:= NIL

DEFAULT cPreSelect		:= ""
DEFAULT l1Elem			:= .F.

Begin Sequence

	cAlias 	:= Alias()
	MvPar	:= &(Alltrim(ReadVar()))
	mvRet	:= Alltrim(ReadVar())

	If AllTrim( MvPar ) == "*"
		Break
	EndIf

	CursorWait()
		For nFor := 1 To Len( cPreSelect ) Step 5
			aAdd( aPreSelect , SubStr( cPreSelect , nFor , 5 ) )
		Next nFor

		If !( l1Elem )
			For nFor := 1 TO Len(alltrim(MvPar))
				Mvparam += PADR( (Subs(MvPar,nAuxFor,5)), 5 )
				MvParam += Replicate("*",5)
				nAuxFor := (nFor * 5) + 1
			Next
		Endif
		mvPar 	:= MvParam

		afProcessos	:= BldafProcesso( cFilRCJ )

	CursorArrow()

	IF !( lRet := !Empty( afProcessos ) )
		Help(" ",1,"GPENFILIAL")	//Cadastro de verbas nao existe para a filial
		Break
	EndIF

	CursorWait()
		For nFor := 1 To Len( afProcessos )
			IF ( aScan( aPreSelect , SubStr( afProcessos[ nFor ] , 1 , 5 ) ) == 0.00 )
				MvParDef+=Left(afProcessos[ nFor ],5)
				aAdd( aNewSelect , afProcessos[ nFor ] )
			EndIF
		Next nFor
	CursorArrow()

	IF f_Opcoes(@MvPar,cTitulo,aNewSelect,MvParDef,12,49,l1Elem,5,10)
		CursorWait()
			For nFor := 1 To Len( mVpar ) Step 5
				IF ( SubStr( mVpar , nFor , 5 ) # "*****" )
					mvRetor += SubStr( mVpar , nFor , 5 )
				Endif
			Next nFor
			&MvRet := Alltrim(Mvretor)
			If &MvRet == ""
				&MvRet := Space(30)
			EndIf
		CursorArrow()
	EndIF

End Sequence

dbSelectArea(cAlias)

Return( lRet )

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    쿍ldProcesso   � Autor 쿘auricio Takakura      � Data �06/10/2005�
쳐컴컴컴컴컵컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿎arregar os Processos do RCJ conforme Filial                 	�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros쿬FilRCJ - Filial do RCJ											�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿝etorno   쿪Processos - Array com Stringo-Codigo + Descricao da Ausencia   �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Static Function BldafProcesso( cFilRCJ )
Local aArea		:= GetArea()
Local aQuery		:= {}
Local aProcessos	:= {}
Local bSkip		:= { || aAdd( aProcessos , ( RCJ_CODIGO + " - " + RCJ_DESCRI ) ) , .F. }

#IFDEF TOP
	aQuery		:= Array( 03 )
	aQuery[01]	:= "RCJ_FILIAL='"+cFilRCJ+"'"
	aQuery[02]	:= " AND "
	aQuery[03]	:= "D_E_L_E_T_=' ' "
#ENDIF

RCJ->( GdMontaCols(	NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					NIL				,;
					{				 ;
						"RCJ_FILIAL",;
						"RCJ_CODIGO",;
						"RCJ_DESCRI" ;
					}				,;
					NIL				,;
					"RCJ"			,;
					cFilRCJ			,;
					NIL				,;
					bSkip			,;
					.F.				,;
					.F.				,;
					.F.				,;
					NIL				,;
					.F.				,;
					.F.				,;
					aQuery			,;
					.F.				,;
					.T.				,;
					.F.				,;
					.T.				,;
					.F.				,;
					.F.				,;
					.F.				 ;
				   );
	  )

RestArea(aArea)
Return(aClone(aProcessos))

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿒PIniProc 튍utor  쿘icrosiga           � Data �  04/06/06   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     �                                                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function GpIniProc()

Local aArea   	:= GetArea()
Local lUsaGFP	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.F.) //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
Local lcria     := .F.
Local lRcjModulo:= .F.

	DBSELECTAREA("RCJ")

	//Verifica existencia do campo RCJ_MODULO
	lRcjModulo := RCJ->( ColumnPos( "RCJ_MODULO")) > 0

	RCJ->(DBSETORDER(1))
	RCJ->(DBGOTOP())

    If RCJ->(EOF()) .OR. !DbSeek(RCJ->(xFilial("RCJ")))
        lcria := .T.
    Endif

    If lCria
		If cPaisLoc $ "RUS"
			If !DBSEEK(xFilial("RCJ")+"00001")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00001"
					RCJ->RCJ_DESCRI 	:= OemToAnsi(STR0026)
		      		RCJ->RCJ_ORIGEM   	:= "1"
			 		RCJ->(MsUnlock())
				Endif
			EndIf
		Else
			If !DBSEEK(xFilial("RCJ")+"00001")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00001"
					RCJ->RCJ_DESCRI 	:= "CELETISTA/ESTAGIARIO MENSAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			EndIf

			If !DBSEEK(xFilial("RCJ")+"00002")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00002"
					RCJ->RCJ_DESCRI 	:= "CELETISTA/ESTAGIARIO SEMANAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			EndIf

			If !DBSEEK(xFilial("RCJ")+"00003")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00003"
					RCJ->RCJ_DESCRI 	:= "CONTRIBUINTE INDIVIDUAL MENSAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			Endif

			If !DBSEEK(xFilial("RCJ")+"00004")
				If Reclock("RCJ",.T.)
					RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
					RCJ->RCJ_CODIGO		:= "00004"
					RCJ->RCJ_DESCRI 	:= "CONTRIBUINTE INDIVIDUAL SEMANAL"
					RCJ->RCJ_ORIGEM		:= "1"
					If lRcjModulo
						RCJ->RCJ_MODULO		:= "GPE"
					EndIf
					RCJ->(MsUnlock())
				Endif
			Endif

			If lUsaGFP
				If !DBSEEK(xFilial("RCJ")+"50000")
					If Reclock("RCJ",.T.)
						RCJ->RCJ_FILIAL 	:= xFilial("RCJ")
						RCJ->RCJ_CODIGO		:= "50000"
						RCJ->RCJ_DESCRI 	:= "MEMBROS/SERVIDORES"
						RCJ->RCJ_ORIGEM		:= "1"
						RCJ->RCJ_MODULO		:= "GFP"
						RCJ->(MsUnlock())
					ENDIF
				Endif
			ENDIF
		EndIf
	Endif

	Dbclosearea()

	RestArea(aArea)

Return

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    � fKeyAsimOpc	쿌utor�  Igor Franzoi     � Data �11/01/2010�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿝etorna as opcoes para o campo RCJ_CLASIM					�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �< Vide Parametros Formais >									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      쿒PEA420                                                     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Retorno  쿪Rotina														�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�< Vide Parametros Formais >									�
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Function fKeyAsimOpc()
Local cOpc := ""

cOpc += ( "A=" + OemToAnsi(STR0016)+ ";" ) //Membros Soc.coop.prod. - Miembros Soc.coop.prod.
cOpc += ( "B=" + OemToAnsi(STR0017)+ ";" )  //Int.Soc.e Assoc.Civ. - Int.Soc.y Asoc.Civ.
cOpc += ( "C=" + OemToAnsi(STR0018)+ ";" )  //Membros Cons.Dir.Vig.Con.Com. - Miembros Cons.Dir.Vig.Con.Com.
cOpc += ( "D=" + OemToAnsi(STR0019)+ ";" )  //Ativ.Emp. - Activ.Emp.
cOpc += ( "E=" + OemToAnsi(STR0020)+ ";" )  //Hon.Assim.Sal. - Hon.Asim.Suel.
cOpc += ( "F=" + OemToAnsi(STR0021) )       //Outros - Otros

Return cOpc

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    � MenuDef		쿌utor�  Luiz Gustavo     � Data �05/01/2007�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o 쿔sola opcoes de menu para que as opcoes da rotina possam    �
�          퀂er lidas pelas bibliotecas Framework da Versao 9.12 .      �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   �< Vide Parametros Formais >									�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      쿒PEA420                                                     �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Retorno  쿪Rotina														�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros�< Vide Parametros Formais >									�
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Static Function MenuDef()
Local aRotina :=	{}

		aAdd( aRotina , {STR0001, "PesqBrw"	    , 0, 1, ,.F.} )	// "Pesquisar"
		aAdd( aRotina , {STR0002, "Gpea420Mnt"  , 0, 2} 	  )	// "Visualizar"
		aAdd( aRotina , {STR0003, "Gpea420Mnt"  , 0, 3} 	  )	// "Incluir"
		aAdd( aRotina , {STR0004, "Gpea420Mnt"  , 0, 4} 	  )	// "Alterar"
		aAdd( aRotina , {STR0005, "Gpea420dele" , 0, 5} 	  )	// "Excluir"

 		If (MV_MODFOL == "1") .and. cPaisLoc <> "PTG"
			aAdd( aRotina , {STR0013, "GpProLeg"    , 0, 5, 7,.F.})  // "Legenda"
		EndIf

Return aRotina

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴�
쿑un뇙o    � fValForm 		쿌utor� Emerson Campos    � Data �03/01/2012�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴�
쿏escri뇙o � Validacao dos campos RCJ_DIACAL e RCJ_DIAPRO               �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿞intaxe   � < Vide Parametros Formais >							    �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      � GPEA420                                                    �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Retorno  � lRet														�
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿛arametros� < Vide Parametros Formais >								�
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
Static Function fValForm()
Local lRet := .T.
	If cPaisLoc == "COL" .OR. cPaisLoc == "PER"
		If M->RCJ_DIACAL == "1" .AND. M->RCJ_DIAPRO <> 0
			M->RCJ_DIAPRO := 0
			lRet := .F.
		EndIf
	EndIf
Return  lRet