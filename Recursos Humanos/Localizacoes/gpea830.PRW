#Include "PROTHEUS.CH"
#Include "GPEA1830.CH"

#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA830  � Autor  � Luis Trombini          		   � Data �04/08/2010���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Gastos Pessoais - Equador                          		���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA830()                                                   			���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     			���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC            �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���Alex        �06/10/10�00000021052/2010� Incluido o fPosTab para posicionamento   ���
���            �        �                � do codigo conforme a tabela S019.        ���
���Emerson Camp�28/02/12�00000004383/2012� Alterado a validacao do RH5_ANO do linOK ���
���            �        �                � p/ uma funcao a partir de do X3_VALID e  ���
���            �        �                � inserido uma funcao de ajustaSX3 para    ���
���            �        �                � inserir esse nova funcao para o valid    ���
�����������������������������������������������������������������������������������Ĵ��
���Jonathan Glz�30/04/15�      PCREQ-4256�Se elimina la funcion AjustaSX3() que     ���
���            �        �                �ajusta el valid del campo RH5_ANO con     ���
���            �        �                �motivo de las nuevas estructuras de las   ���
���            �        �                �SXs para version 12                       ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
/*/
Function GPEA830(nOpcAuto, xAutoCab, xAutoItens, nOpc)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cFiltraSRA			//Variavel para filtro
LOCAL aIndexSRA	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//��������������������������������������������������������������Ŀ
//� Define array contendo as Rotinas a executar do programa      �
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
Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private lGp830Auto := (xAutoCab <> Nil)
Private aAutoCab   := Nil
Private aAutoItens := Nil

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0008)  //"Controle de Periodos por Empregado"

If nOpcAuto <> Nil
	Do Case
		Case nOpcAuto == 3
			INCLUI := .T.
			ALTERA := .F.
		Case nOpcAuto == 4
			INCLUI := .F.
			ALTERA := .T.
		OtherWise
			INCLUI := .F.
			ALTERA := .F.
	EndCase

	dbSelectArea('SRA')
	nPos := Ascan(aRotina,{|x| x[4]== nOpcAuto})
	If ( nPos <> 0 )
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPos)
	EndIf
Else
	If lGp830Auto
		aAutoCab	  := xAutoCab
		aAutoItens := xAutoItens
		If nOpc==3
			nOpc:=6//aRotina -> op�ao Incluir
		EndIf
		mBrowseAuto(nOpc,aAutoCab,"SRA")
	Else
		//��������������������������������������������������������������Ŀ
		//� Verifica se o Arquivo Esta Vazio                             �
		//����������������������������������������������������������������
		If !ChkVazio("SRA")
				Return
		Endif

		//������������������������������������������������������������������������Ŀ
		//� Inicializa o filtro utilizando a funcao FilBrowse                      �
		//��������������������������������������������������������������������������
		cFiltraRh := CHKRH("GPEA830","SRA","1")
		bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
		Eval(bFiltraBrw)

		//��������������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE                                  �
		//����������������������������������������������������������������
		dbSelectArea("SRA")
		dbGoTop()
		mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

		//������������������������������������������������������������������������Ŀ
		//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
		//��������������������������������������������������������������������������
		EndFilBrw("SRA",aIndexSra)
	EndIf
EndIf
Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � gp830atu � Autor � Mauro                 � Data � 13/10/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Atualizacao da Provisao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � gp830atu(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � gp830atu                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function gp830Mnt(cAlias,nReg,nOpc)
//��������������������������������������������������������������Ŀ
//� Salva a integridade dos dados                                �
//����������������������������������������������������������������
Local aArea			:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}
Local oFont
Local oDlg
Local nCnt								//Armazena a quantidade de registros de um determinado funcionario. Utilizada para verificar se usuario podera "Incluir" ou "Alterar".
Local cKey			:= ''				// variavel com os valores das chaves. (variavel para getdados da tabela RH5)
Local aNotFields	:= {}				// vetor com os campos que nao seria visualizados. (variavel para getdados da tabela RH5)
Local aRH5Cols		:= {}				// vetor com as colunas da GetDados SRF. (variavel para getdados da tabela RH5)
Local aRH5VisualGD	:= {} 				// vetor com os campos visuais. (variavel para getdados da tabela RH5)
Local oGroup							// Variavel do tipo objetos
Local bSet15		:= { || NIL }		// Bloco com as validacoes do botao OK. (variavel da janela)
Local bSet24		:= { || NIL }		// Bloco com as validacoes do botao Cancelar. (variavel da janela)
Local cQuery		:= ""
Local nT := 0

Private aHeader		:= {}				// vetor com o cabecalho da GetDados RH5. (variavel para getdados da tabela RH5)
Private nRH5Usado	:= 0.00 			// variavel que retorna a quantidade de campos da tabela. (variavel para getdados da tabela RH5)
Private aRH5ColsRec	:= {}				// vetor que contem os Recnos da tabela. (variavel para getdados da tabela RH5)
Private oGet							// Variavel do tipo objetos
Private aRH5VirtGd	:= {}				// vetor com os campos virtuais. (variavel para getdados da tabela RH5)
Private cMat     	:= ""
Private cFilFunc  	:= ""

Private aMemos := {}
Private aCols	:= {}

M->RH5_Codigo := ""

_SetOwnerPrvt( "nOpcNewGd", IF( nOpc == 2 .or. nOpc == 5 , 0 , GD_INSERT + GD_UPDATE + GD_DELETE))

//nSavRec        := RecNo()

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
   cFilFunc :=	xFilial("SRA")
  	If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RH5_MAT'})) > 0
		cMat :=	aAutoCab[nT,2]
 	EndIf

	dbSelectArea("SRA")
	dbSetOrder(1)
	If !dbSeek(xFilial("SRA")+cMat)
		Help( " ", 1, "REGNOIS" )
		Return
	EndIf
Else
	cMat     	:= SRA->RA_MAT
	cFilFunc  	:= SRA->RA_FILIAL
EndIf

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
If !lGp830Auto
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 015 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )
EndIf

cAlias := "RH5"
Begin Sequence

	While .T.
		//��������������������������������������������������������������Ŀ
		//� Envia para processamento dos Gets                            �
		//����������������������������������������������������������������
		nOpcA:=0

		dbSelectArea(cAlias)
		dbSeek( cFilFunc + cMat )
	    nCnt := 0
	    While !EOF() .And. RH5_FILIAL + RH5_MAT == cFilFunc + cMat
			nCnt++
			dbSkip()
	    EndDo

	    If nCnt > 0  .And. nOpc = 3    //--Quando Inclusao e existir Registro
	        Help(" ",1,"A830EXIST")
			Exit
	    Elseif nCnt = 0 .And. nOpc # 3  //--Quando Nao for Inclusao e nao existir Registro
	        Help(" ",1,"A830NEXIST")
			Exit
		Endif

		//�������������������������������������������������������������Ŀ
		//� Verifica se o Funcionario Esta Demitido                     �
		//���������������������������������������������������������������
		If SRA->RA_SITFOLH == "D"
			Help(" ",1,"A090DEMITI")
		Endif

		If !lGp830Auto
			DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
			DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Monta os Dados para a GetDados do SRF						 �
		//����������������������������������������������������������������
		// campos que nao serao visualizados na getdados
		aAdd( aNotFields , "RH5_FILIAL" )
		aAdd( aNotFields , "RH5_MAT"    )
//		aAdd( aNotFields , "RH5_ANO"   )
//		aAdd( aNotFields , "RF_ADMISSA")

		#IFDEF TOP
			If TcSrvType() != "AS/400"
				cQuery := "  RH5_FILIAL = '" + cFilFunc + "'"
				cQuery += " AND "
				cQuery += "  RH5_MAT = '" + cMat + "'"
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ <> '*' "
			Else
				cQuery := NIL
			EndIf
		#ENDIF


		cKey  	 := ( cFilFunc + cMat )
		aRH5Cols := RH5->( GdMontaCols(	@aHeader		,;  //01 -> Array com os Campos do Cabecalho da GetDados
										@nRH5Usado		,;	//02 -> Numero de Campos em Uso
									 	@aRH5VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
									  	@aRH5VisualGd	,;	//04 -> [@]Array com os Campos Visuais
			                          	"RH5"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
									  	aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
									  	@aRH5ColsRec	,;	//07 -> [@]Array unidimensional contendo os Recnos
									  	"SRA"			,;	//08 -> Alias do Arquivo Pai
									  	cKey		 	,;	//09 -> Chave para o Posicionamento no Alias Filho
									    NIL				,;	//10 -> Bloco para condicao de Loop While
									    NIL				,;	//11 -> Bloco para Skip no Loop While
		  							    NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols
					  				    NIL				,;	//13 -> Se cria variaveis Publicas
							  		    NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
		  							    NIL				,;	//15 -> Lado para o inicializador padrao
				  					    NIL				,;	//16 -> Opcional, Carregar Todos os Campos
						  			    NIL 			,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
			  						    cQuery			,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
			  						    .F.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
			  						    .F.				 ;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
			 						  ))

		If !lGp830Auto
			@ aObjSize[1,1] , aObjSize[1,2] GROUP oGroup TO ( aObjSize[1,3] - 3 ),( ( aObjSize[1,4]/100*10 - 2 ) )				LABEL OemToAnsi(STR0012) OF oDlg PIXEL	// "Matricula:"
			oGroup:oFont:= oFont
			@ aObjSize[1,1] , ( ( aObjSize[1,4]/100*10 ) ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),( aObjSize[1,4]/100*80 - 2 )	LABEL OemToAnsi(STR0013) OF oDlg PIXEL	// "Nome:"
			oGroup:oFont:= oFont
			@ aObjSize[1,1] , ( aObjSize[1,4]/100*80 ) GROUP oGroup TO ( aObjSize[1,3] - 3 ),aObjSize[1,4]						LABEL OemToAnsi(STR0014) OF oDlg PIXEL	// "Admiss�o:"
			oGroup:oFont:= oFont
			@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( aObjSize[1,2] + 5 )				SAY SRA->RA_MAT		SIZE 050,10 OF oDlg PIXEL FONT oFont
			@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( ( aObjSize[1,4]/100*10 ) + 5 )	SAY OemToAnsi(SRA->RA_NOME) 					SIZE 146,10 OF oDlg PIXEL FONT oFont
			@ ( ( aObjSize[1,3] ) - ( ( ( aObjSize[1,3] - 3 ) - aObjSize[1,2] ) / 2 ) ) , ( ( aObjSize[1,4]/100*80 ) + 5 )	SAY Dtoc(SRA->RA_ADMISSA)						SIZE 050,10 OF oDlg PIXEL FONT oFont

			oGet := MsNewGetDados():New(aObjSize[2,1]	,;	// nTop
										 aObjSize[2,2]	,;  // nLelft
										 aObjSize[2,3]	,;	// nBottom
			                             aObjSize[2,4]	,;	// nRright
										 nOpcNewGd		,;	// controle do que podera ser realizado na GetDado - nstyle
										 "gp830LinOk"	,;	// funcao para validar a edicao da linha - ulinhaOK
										 "Gp830TudOk"	,;	// funcao para validar todas os registros da GetDados - uTudoOK
		  								 NIL			,;	// cIniCPOS
										 NIL			,;	// aAlter
										 0				,; 	// nfreeze
										 99999			,;  // nMax
										 NIL			,;	// cFieldOK
										 NIL			,;	// usuperdel
										 If(nOpc=2.Or.nOpc=5,Nil,.T.),;		// udelOK
										 @oDlg			,; 	// objeto de dialogo - oWnd
										 @aHeader		,;	// Vetor com Colunas - AparHeader
										 @aRH5Cols		;	// Vetor com Header - AparCols
										)

			oGet:bDelOk:= {|| gp830ChkDel()}

			bSet15	:= {|| nOpca:= (IF(nOpc=5,2,1)), IF(oGet:TudoOk(),oDlg:End(),nOpca:=0)}
			bSet24	:= {|| oDlg:End()}
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

		Else
		   	If MsGetDAuto(aAutoItens,"gp830LinOk","Gp830TudOk",,nOpcNewGd)
			   	nOpcA:=If(nOpc=5,2,1)
		   	EndIf
		EndIf

        If nOpcA == Redigita
            LOOP
        ElseIf nOpcA == Confirma .And. nOpc # 2
            Begin Transaction
                //--Gravacao
                gp830Grava(cAlias, nOpc)
                //--Processa Gatilhos
  				( cAlias )->( EvalTrigger() )
            End Transaction
        Endif
		Exit
	EndDo

End Sequence

RestArea( aArea )
If ( nOpc == 3 )
	MBrChgLoop(.F.)
EndIf

Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���                   ROTINAS DE CRITICA DE CAMPOS                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp830Grava� Autor � Tatiane Matias        � Data � 27.04.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava no arquivo de Periodos                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � gp830Grava                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� */
Function gp830Grava(cAlias, nOpc)

//��������������������������������������������������������������Ŀ
//� Declaracao de variaveis locais         					     �
//����������������������������������������������������������������
Local aRH5Cols  	:= {}
Local nX 			:= 0
Local ny			:= 0.00					// Contador de colunas.
Local nLenCols		:= 0		// Quantidade de linhas da SRF.
Local nLenRegAlt 	:= Len(aRH5ColsRec)
Local nLenHeader	:= Len( aHeader  )		// Quantidade de colunas da SRF.
Local cPrefixo		:= ( PrefixoCpo( cAlias ) + "_" )
Local cCampo		:= ""
Local nPosDeleted	:= GdFieldPos( "GDDELETED" )

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
	aRH5Cols  	:= aCols
Else
	aRH5Cols  	:= (oGet:aCols)
EndIf

nLenCols		:= Len(aRH5Cols)

Begin Transaction

	If ( nLenRegAlt > 0 )
		For nX := 1 To nLenRegAlt
			( cAlias )->( dbGoto( aRH5ColsRec[nX] ) )
			( cAlias )->( RecLock( cAlias , .F. , .T. ) )
			IF ( aRH5Cols[nX,nPosDeleted] )
				(cAlias)->( dbDelete() )
			Else
				(cAlias)->(&(cPrefixo+"FILIAL"))	:= cFilFunc
				(cAlias)->(&(cPrefixo+"MAT"))		:= cMat
				For nY := 1 To nLenHeader
					/*
					��������������������������������������������������������������Ŀ
					�Obtem o Campo para Gravacao  							       �
					����������������������������������������������������������������*/
					cCampo := aHeader[nY,2]

					/*
					��������������������������������������������������������������Ŀ
					�Nao Grava Campo Virtual									   �
					����������������������������������������������������������������*/
//					IF ( aScan(aSRFVirtGd,cCampo) # 0 )
//						Loop
//					EndIF

					xConteudo := aRH5Cols[nX,nY]
					(cAlias)->( &cCampo ) := xConteudo

				Next nY
			EndIf

			/*
			��������������������������������������������������������������Ŀ
			�Efetua a gravacao dos campos memos na tabela RE6.			   �
			����������������������������������������������������������������*/
			fGravaMemos(aMemos,cAlias)

			/*
			��������������������������������������������������������������Ŀ
			�Destrava o Registro										   �
			����������������������������������������������������������������*/
			( cAlias )->( MsUnLock() )
		Next nX
		IF ( nLenCols > nLenRegAlt ) // Se Trata de Inclusao de Itens
			Gp830GrInc( cAlias , cPrefixo , ( nLenRegAlt + 1 ) )
		EndIF
	Else
		Gp830GrInc( cAlias , cPrefixo , 1 )
	EndIF

End Transaction

Return( .T. )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp830GrInc  � Autor �Tatiane Matias       � Data � 27.04.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros Incluidos na GetDados	                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Gp830GrInc                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function Gp830GrInc( cAlias , cPrefixo , nIniciar )

Local aRH5Cols		:= {}
Local cCampo		:= ""
Local nLenHeader	:= Len( aHeader )
Local nLenCols		:= 0
Local nPosDeleted	:= GdFieldPos( "GDDELETED" )
Local nX			:= 0
Local nY 			:= 0

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
	aRH5Cols  	:= aCols
Else
	aRH5Cols  	:= (oGet:aCols)
EndIf

nLenCols		:= Len( aRH5Cols )

For nX := nIniciar To nLenCols
	IF !( aRH5Cols[nX,nPosDeleted] )
		(cAlias)->( RecLock(cAlias,.T.) )
		(cAlias)->(&(cPrefixo+"FILIAL"))	:= cFilFunc
		(cAlias)->(&(cPrefixo+"MAT"))		:= cMat
		For nY := 1 To nLenHeader
			/*
			��������������������������������������������������������������Ŀ
			�Obtem o Campo para Gravacao  							       �
			����������������������������������������������������������������*/
			cCampo := aHeader[nY,2]

			/*
			��������������������������������������������������������������Ŀ
			�Nao Grava Campo Virtual									   �
			����������������������������������������������������������������*/
//			IF ( aScan(aSRFVirtGd,cCampo) # 0 )
//				Loop
//			EndIF

			xConteudo := aRH5Cols[nX,nY]
			(cAlias)->( &cCampo ) := xConteudo
		Next nY

		/*
		��������������������������������������������������������������Ŀ
		�Efetua a gravacao dos campos memos na tabela RE6.			   �
		����������������������������������������������������������������*/
		fGravaMemos(aMemos,cAlias)

		/*
		��������������������������������������������������������������Ŀ
		�Destrava o Registro										   �
		����������������������������������������������������������������*/
		( cAlias )->( MsUnLock() )
	EndIF
Next nX

Return( NIL )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �gp830LinOk� Autor � Tatiane Matias        � Data � 27.04.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Critica linha digitada                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function gp830LinOk()
//��������������������������������������������������������������Ŀ
//� Declaracao de variaveis locais         					     �
//����������������������������������������������������������������
Local aRH5Cols		:= {}
Local aCposKey		:= {}
Local lRet		  	:= .T.
Local cHelp		  	:= ""
Local nPoscodigo	:= GdFieldPos( "RH5_CODIGO", aHeader )
Local nPosvalor 	:= GdFieldPos( "RH5_VALOR", aHeader )
Local cCodGast		:= ""
//Local nPosDiasDir	:= GdFieldPos( "RF_DIASDIR", aHeader )
//Local nPosDiasVenc	:= GdFieldPos( "RF_DFERVAT", aHeader )
//Local nPosDiasProp	:= GdFieldPos( "RF_DFERAAT", aHeader )

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If lGp830Auto
	aRH5Cols		:= aCols
Else
	aRH5Cols		:= (oGet:aCols)
EndIf

		If !aRH5Cols[n,nRH5Usado+1]
			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Campos Estao Devidamente Preenchidos		   �
			����������������������������������������������������������������/*/
			aCposKey := GdObrigat( aHeader )
			lRet := GdNoEmpty( aCposKey )

//		    Em alguns casos, o inicio da contagem do periodo devera ser anterior a admissao do funcionario
//			If lRet .and. aSRFCols[n,nPosDtIni] < SRA->RA_ADMISSA
//				cHelp := OemToAnsi( STR0017 ) // A Data de Inicio do Periodo deve ser maior que a data de admissao
//				MsgInfo( cHelp , STR0015 )
//				lRet := .F.
//			EndIf

			nPosTab 	:= fPosTab("S019",aRH5Cols[n,nPosCodigo],"=",4)
			cCodGast	:= fTabela("S019",nPosTab,04)

			If lRet .and. !(aRH5Cols[n,nPosCodigo] $ cCodGast) // strzero(year(ddata_pgto),4)
				cHelp := OemToAnsi( STR0017 ) // "O codigo nao � Valido para a Deducao de Gastos Pessoais"
				If lGp830Auto
					AutoGrLog( cHelp )
				Else
					MsgInfo( cHelp , STR0015 )
				EndIf
				lRet := .F.
			EndIf
			If lRet .and. aRH5Cols[n,nPosValor] < 0.00
				cHelp := OemToAnsi( STR0018 ) // "O Valor tem que ser Maior que Zeros"
				If lGp830Auto
					AutoGrLog( cHelp )
				Else
					MsgInfo( cHelp , STR0015 )
				EndIf
				lRet := .F.
			EndIf

			/*
			��������������������������������������������������������������Ŀ
			� Verifica Itens Duplicados na GetDados						   �
			����������������������������������������������������������������*/
			If lRet
				aCposKey := { "RH5_ANO" , "RH5_CODIGO"}
				lRet := GdCheckKey( aCposKey , 4 )
			EndIf


		EndIf

Return( lRet )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gp830TudOk� Autor �Tatiane Matias         � Data �27/04/2005�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gp830TudOk( ) 								      	        �
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso      �Gp050Mnt()                                                  �
�������������������������������������������������������������������������/*/
Function Gp830TudOk( )
	Local lRetorna  := .T.
	Continua := .F.
Return lRetorna

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    �gp830VerEdit	  � Autor � Tatiane Matias        � Data �27.04.2005���
�������������������������������������������������������������������������������Ĵ��
���Descri��o �Verificar se o registro poder� ser editado. So permitira efetuar  ���
���          �manutencao nos periodos que nao foram utilizados em calculo,      ���
���          �ou seja, quando o campo Dias Pagos for maior que zero.            ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � gp830VerEdit()                                                   ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � When de todos os campos da tabela SRF SX3                        ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
����������������������������������������������������������������������������������� */
Function gp830VerEdit()

Local lEdit 		:= .T.
Local aRH5Cols  	:= (oGet:aCols)
Local nPosDiasPg  	:= GdFieldPos( "RH5_VALOR", aHeader )

	If aRH5Cols[n, nPosDiasPg] > 0
		lEdit := .F.
	EndIf

Return (lEdit)

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �gp830ChkDel   �Autor�Tatiane Matias       � Data �27/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o registro pode ser excluido.                   �
�          �O registro so podera ser excluido se o Dias Pagos for zero. �
�����������������������������������������������������������������������Ĵ
�Uso       �No bDelOk da oGet     .				                        �
�������������������������������������������������������������������������/*/
Static Function gp830ChkDel()

Local nPosDiasPg := GdFieldPos( "RH5_VALOR", aHeader )

lRet :=	!( aCols[n, nPosDiasPg] > 0 )

Return ( lRet )


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �gp830DescPD   �Autor�Reginaldo            � Data �28/11/2005�
�����������������������������������������������������������������������Ĵ
�Descri��o �Preenche o Campo Descricao da Verba                         �
�������������������������������������������������������������������������/*/
Function GP830DescPd(cPd)

Local cDescPd
/*
��������������������������������������������������������������Ŀ
�Carrega a Descricao da Verba                                  �
����������������������������������������������������������������*/
cDescPd := fDesc( "SRV" , cPd , "RV_DESC" )
GdFieldPut( "RF_DESCPD" , cDescPd )

Return ( .t. )


/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �03/01/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA830                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function MenuDef()

 Local aRotina := { 	{ STR0004 , "PesqBrw"  , 0 , 1},;  //"Pesquisar"
						{ STR0005 , "gp830Mnt" , 0 , 2},;  //"Visualizar"
						{ STR0011 , "gp830Mnt" , 0 , 6}	,;  //"Incluir"
						{ STR0006 , "gp830Mnt" , 0 , 4},;  //"Atualizar"
						{ STR0010 , "GPER600"  , 0 , 6}}   //"Imprimir"

Return aRotina

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �valDtFimPer�Autor  �Emerson Campos      � Data � 28/02/2012  ���
��������������������������������������������������������������������������͹��
���Desc.     � Valida se a data final do periodo deve ser maior que a data ���
���          � de inicio do periodo.                                       ���
��������������������������������������������������������������������������͹��
���Uso       � GPEA830                                                     ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function valDtFimPer()
Local lRet	:= .T.
Local cHelp := OemToAnsi( STR0016 ) // "A Data Final do Periodo deve ser maior que a Data de Inicio do Periodo"

lGp830Auto := If (Type("lGp830Auto") == "U",.F.,lGp830Auto)

If M->RH5_ANO < strzero(year(date()),4)
	If lGp830Auto
		AutoGrLog( cHelp )
	Else
		MsgInfo( cHelp , STR0015 )
	EndIf
	lRet := .F.
EndIf
Return lRet
