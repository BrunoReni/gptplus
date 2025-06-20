#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "GPEA920.CH"
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cVersEnvio	:= ""
Static cVersGPE		:= ""

/*
�������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������������Ŀ��
���Funcao    	� GPEA920    � Autor � Glaucia M./Mauricio M.  	                � Data � 13/06/2013 ���
���������������������������������������������������������������������������������������������������Ĵ��
���Descricao 	� Informacoes Exclusivas Estagio                                                    ���
���������������������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEA920()                                                    	  		            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Uso       	� GPEA010 - Ac Relacionadas - Info Estagiario - Aca Relacionada Ag. Int. Est.       ���
���������������������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			            ���
���������������������������������������������������������������������������������������������������Ĵ��
���Analista     � Data     � FNC/Requisito  � Chamado �  Motivo da Alteracao                        ���
���������������������������������������������������������������������������������������������������Ĵ��
���Raquel Hager �08/07/2014�00000020445/2014�TPZTHB	  �Inclusao de fonte na versao 12(datat fonte   ���
���             �          �         		�		  �versao 11 - 01/06/2014)					    ���
���Christiane V �02/07/2015�00000015644/2015�TSMUY2   �Adapta��es para vers�o 2.0 do eSocial        ���
���Raquel Hager �24/08/2016�00000029392/2016�TVTOQD   �Remo��o do uso do par�metro MV_INTTAF para   ���
���             �          �                �         �release 12.1.7.							    ���
���Marcos Cout  �11/05/2017�DRHESOCP-237    �         �Realizar ajustes para gera��o do evento S2300���
���             �          �                �         �para o layout do eSocial 2.2.01       	    ���
���Marcos Cout  �20/07/2017�DRHESOCP-403    �         �Realizado ajustes necess�rios para que o     ���
���             �          �                �         �evento S-2205 seja gerado corretamente p/    ���
���             �          �                �         �para registros de Trabalhador S Vinculos     ���
���             �          �                �         �Realizadas varias corre��es de processos     ���
��|Marcos Cout  |27/10/2017|DRHESOCP-1728   |         |Realizado ajustes necess�rios para q seja    |��
��|             |          |                |         |gerado o XML contendo os dados do estagiario |��
��|             |          |                |         |corretamente.                                |��
��|Marcos Cout  |06/12/2017|DRHESOCP-2227   |         |Realizado ajustes necess�rios para q a rotina|��
��|             |          |                |         |de consistencia valide corretamente os dados |��
��|Cec�lia Carv |08/01/2018|DRHESOCP-2682   |         |Ajuste para gera��o de contrato intermitente |��
��|             |          |                |         | - evento S-2200.                            |��
���Marcos Cout. |16/02/2017|DRHESOCP-3618   |         |Realizando ajuste na chave de pesquisa trab  |��
���             |          |                |         |sem vinculo (TSV)                            |��
����������������������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������������*/
Function GPEA920()

	Local oMBrowse
	Local cFiltraRh

	If lMiddleware .And. !ChkFile("RJE")
		Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0041), 1, 0 )//"Tabela RJE n�o encontrada. Execute o UPDDISTR - atualizador de dicion�rio e base de dados."
		Return
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Informacoes Exclusivas Estagio"

	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	cFiltraRh := CHKRH("GPEA920","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:SetLocate()
	GpLegMVC(@oMBrowse)

	oMBrowse:SetFilterDefault("RA_CATFUNC $ 'E*G'")
	oMBrowse:ExecuteFilter(.T.)

	oMBrowse:Activate()

Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Glaucia M.       � Data �04/06/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Criacao do Menu do Browse.                                  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { OemToAnsi(STR0009)	, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { OemToAnsi(STR0010)	, "VIEWDEF.GPEA920", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { OemToAnsi(STR0011)	, "VIEWDEF.GPEA920", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { OemToAnsi(STR0012)	, "VIEWDEF.GPEA920", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef		�Autor�  Glaucia M.       � Data �05/06/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �Model em uso.												�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()

	Local oModel		:= Nil
	Local oStruSRA 		:= FWFormStruct( 1, 'SRA')
	Local oStruRFS 		:= FWFormStruct( 1, 'RFS')
	Local bMdPreVal		:= {|oModel| fG920PrVAL(oStruRFS)}
	Local bRFSposVal	:= {|oModel| fG920RFSpo()}
	Local bCommit		:= {|oModel| fG920Com(oModel)}

	oModel     	:= MPFormModel():New('GPEA920', bMdPreVal, ,bCommit )
	oStruSRA	:= FWFormStruct(1,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oModel:AddFields( 'SRATITLE',				, oStruSRA )
	oModel:AddFields( 'RFSMASTER', 'SRATITLE'	, oStruRFS,,bRFSposVal )

	oModel:GetModel( 'RFSMASTER' ):SetDescription(OemToAnsi(STR0001)) //Informacoes Exclusivas Estagio
	oModel:SetRelation( "RFSMASTER", { { "'RFS_FILIAL", "xFilial( 'RFS' )" },  { 'RFS_MAT', 'RA_MAT' }} , RFS->(IndexKey(1)) )

	oModel:GetModel( "SRATITLE" ):SetOnlyQuery(.T.)

	oModel:SetActivate( { |oModel| fGP920RFS( oModel ) } )

Return( oModel )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef		�Autor�  Glaucia M.       � Data �05/06/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �View em uso.    											�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function ViewDef()
	Static cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas
	Local oView		:= NIL
	Local oModel	:= FWLoadModel( 'GPEA920' )
	Local oStruSRA	:= FWFormStruct(2, 'SRA')
	Local oStruRFR	:= FWFormStruct(2, 'RFS')

	oStruSRA	:= FWFormStruct(2,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SRA",oStruSRA,"SRATITLE")
	oView:AddField("VIEW_RFS",oStruRFR,"RFSMASTER")

	oStruRFR:RemoveField("RFS_FILIAL")
	oStruRFR:RemoveField("RFS_MAT")
	oStruSRA:RemoveField("RA_FILIAL")

	oStruSRA:SetNoFolder()

	oView:SetOnlyView('VIEW_SRA')

	oView:CreateHorizontalBox( 'SUPERIOR', 12 )
	oView:CreateHorizontalBox( 'INFERIOR', 88 )

	oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RFS', 'INFERIOR' )

	oView:EnableTitleView('VIEW_SRA')
	oView:EnableTitleView('VIEW_RFS')

Return oView


/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fGP920RFS()	�Autor�  Glaucia M.       � Data �17/06/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Inicializa campos RFS na alteracao.                         �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �Nenhum														�
�����������������������������������������������������������������������Ĵ
�Parametros�oModel = ModelDef em uso na rotina.	     					�
�������������������������������������������������������������������������*/
Static Function fGP920RFS( oModel )

	Local aArea      := GetArea()
	Local aAreaRFS   := RFS->( GetArea() )
	Local aCampos    := {}
	Local nI         := 0
	Local nOperation := oModel:GetOperation()
	Local oModelRFS
	Local xInit      := ""

	If nOperation == MODEL_OPERATION_UPDATE
		oModelRFS := oModel:GetModel( 'RFSMASTER')

		RFS->( dbSetOrder( 1 ) )
		If !RFS->( dbSeek( xFilial( 'RFS' ) + oModel:GetValue( 'SRATITLE', 'RA_MAT' )  ) )
			aCampos := oModelRFS:GetStruct():GetFields()

			For nI :=  1 to Len( aCampos )
				If aCampos[nI][MODEL_FIELD_INIT] <> NIL
					xInit := oModelRFS:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
					If !Empty( xInit )
						oModelRFS:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	RestArea( aAreaRFS )
	RestArea( aArea )

Return NIL

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fGP920Ent()	�Autor�  Glaucia M.       � Data �01/07/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Complemento da valida��o do campo RFS_ENTIDA                �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fGP920Ent()                 								�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Campo RFS_ENTIDA                                  �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�Nenhum 								    					�
�������������������������������������������������������������������������*/
Function fGP920Ent()

	Local lRet:=	.T.
	Local cMsg	:= ""

	//Posiciono na tabela para garantir abertura quando MVC e ExecAuto
	dbSelectArea("RA0")
	dbSetOrder(1) // RA0_FILIAL+RA0_ENTIDA
	If RA0->(dbSeek(xFilial("RA0")+&(ReadVar())))
		Iif( cPaisLoc == "BRA" .And. FindFunction("fVersEsoc"), fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE ), .T.)

		cMsg:= OemtoAnsi(STR0014)+" "+ OemtoAnsi(STR0008)+", "  //"A Entidade escolhida"  ## n�o possui todos os campos necess�rios preenchidos
		cMsg:= cMsg+OemtoAnsi(STR0016)+" "+ OemtoAnsi(STR0001)+"."+CRLF // para contemplar o cadastro ## Informa��es Excluvisas Est�gio

		If (cVersEnvio < "9.0")
			cMsg:= cMsg+OemtoAnsi(STR0036)+", "		//"CNPJ V�lido e diferente de '00000000000000'"
			cMsg:= cMsg+OemtoAnsi(STR0019)+", "		//"Descri��o"
			cMsg:= cMsg+OemtoAnsi(STR0020)+", "		//"Endere�o"
			cMsg:= cMsg+OemtoAnsi(STR0021)+", "		//"Estado"
			cMsg:= cMsg+OemtoAnsi(STR0023)+"."			//"CEP"
		Else
			cMsg:= cMsg+OemtoAnsi(STR0036)+" "+OemtoAnsi(STR0042)+" "		//"CNPJ V�lido e diferente de '00000000000000' ou "
			cMsg:= cMsg+OemtoAnsi(STR0020)+", "		//"Endere�o"
			cMsg:= cMsg+OemtoAnsi(STR0021)+", "		//"Estado"
			cMsg:= cMsg+OemtoAnsi(STR0023)+"."			//"CEP"
		Endif

		If ((cVersEnvio < "9.0") .Or. (cVersEnvio >= "9.0" .And. !Empty(RA0->RA0_CGC)))
			If (RA0->RA0_CGC=='00000000000000')
				Help( ,, 'HELP',, cMsg, 1, 0 )
				Return .F.
			EndIf
		Endif

		If cEFDAviso <> "2"

			If (  (cVersEnvio < "9.0" .And. (empty(RA0->RA0_CGC) .OR. empty(RA0->RA0_ENDERE) .OR. empty(RA0->RA0_CEP) .OR. empty(RA0->RA0_ESTADO) .OR. empty(RA0->RA0_DESC))) .Or. ;
				(cVersEnvio >= "9.0" .And. (empty(RA0->RA0_CGC) .And. (empty(RA0->RA0_ENDERE) .OR. empty(RA0->RA0_CEP) .OR. empty(RA0->RA0_ESTADO)) )) )

				If cEFDAviso == "1"
					Help( ,, 'HELP',, cMsg, 1, 0 )
					lRet:= .F.
				Else
					Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## Como a categoria do Funcionario eh estagiario, apresentaremos o cadastro ## Informacoes Exclusivas do Estagio ## "OK" ##
				EndIf

			EndIf
		EndIf
	EndIf

Return lRet

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fGP920Coor()	�Autor�  Glaucia M.       � Data �01/07/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Complemento da valida��o do campo RFS_COORD                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fGP920Coor()             									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Campo RFS_COORD                                   �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�Nenhum                            	     					�
�������������������������������������������������������������������������*/
Function fGP920Coor( )

	Local lRet	:=	.T.
	Local cMsg

	//Posiciono na tabela para garantir abertura quando MVC e ExecAuto
	dbSelectArea("RD0")
	dbSetOrder(1) //RD0_FILIAL+RD0_CODIGO
	If RD0->(dbSeek(xFilial("RD0",SRA->RA_FILIAL)+&(ReadVar())))
		Iif( cPaisLoc == "BRA" .And. FindFunction("fVersEsoc"), fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE ), .T.)

		If (cVersEnvio < "9.0")
			If cEFDAviso <> "2"
				cMsg:= OemtoAnsi(STR0026)+" "+ OemtoAnsi(STR0008)+", "  //"O Coordenador de Estagio escolhido"   ## n�o possui todos os campos necess�rios preenchidos
				cMsg:= cMsg+OemtoAnsi(STR0016)+" "+ OemtoAnsi(STR0001)+"."+CRLF // para contemplar o cadastro ## Informa��es Excluvisas Est�gio

				cMsg:= cMsg+OemtoAnsi(STR0025)+CRLF	//"Os campos necessarios para Entidade, s�o:"
				cMsg:= cMsg+OemtoAnsi(STR0027)+" e "			//"Nome"
				cMsg:= cMsg+OemtoAnsi(STR0024)+"."			//"CPF"

				If empty(RD0->RD0_NOME) .OR. empty(RD0->RD0_CIC)
					If cEFDAviso == "1"
						lRet:= .F.
						Help( ,, 'Help',, cMsg, 1, 0 )
					Else
						Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## Como a categoria do Funcionario eh estagiario, apresentaremos o cadastro ## Informacoes Exclusivas do Estagio ## "OK" ##
					EndIF

				EndIf
			EndIf
		Endif
	EndIf

Return lRet

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fGP920DtFm()	�Autor�  Glaucia M.       � Data �03/07/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Complemento da valida��o do campo RFS_DTFIM                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fGP920DtFm()             									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Campo RFS_DTFIM                                   �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�Nenhum                            	     					�
�������������������������������������������������������������������������*/
Function fGP920DtFm()

	Local lRet	:=	.T.

	If (SRA->RA_ADMISSA >= FwfldGet("RFS_DTFIM")  )
		lRet:= .F.
		Help( ,, 'Help',, OemtoAnsi(STR0029), 1, 0 ) //"A data prevista para o termino do estagio devera ser maior que a Data de Admissao."
	EndIf

Return lRet

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fG920PrVAL()	�Autor�  Glaucia M.       � Data �11/07/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Pre valida��o RFS                                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fG920PrVAL(Struct)           								�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Verifica o parametro MV_EFDAVIS, e se necessario  �
�          �tornara os campos do cadastro RFS-Estagio obrigatorio       �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�Nenhum                            	     					�
�������������������������������������������������������������������������*/
Static Function fG920PrVAL(oStruRFS)
If ((SRA->RA_CATFUNC $ 'E*G') .OR. fGP010FoiE())
	If SRA->RA_CATEFD == "906"
		oStruRFS:SetProperty('RFS_NIVEL',	MODEL_FIELD_OBRIGAT, .F. )
		oStruRFS:SetProperty('RFS_COORD',	MODEL_FIELD_OBRIGAT, .F. )
		oStruRFS:SetProperty('RFS_COORD',	MODEL_FIELD_WHEN, {||.F.})
		oStruRFS:SetProperty('RFS_AGENTE',	MODEL_FIELD_WHEN, {||.F.})
	ElseIf SRA->RA_CATEFD == "901"
		oStruRFS:SetProperty('RFS_NIVEL',	MODEL_FIELD_OBRIGAT, .T. )
	EndIf
Endif
Return .T.

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fG920RFSpo()	�Autor�  Glaucia M.       � Data �11/07/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Pos validacao                                               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fG920RFSpo()           							         	�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Verifica o parametro MV_EFDAVIS, e se necessario  �
�          �emitira apenas um alerta que os campos necessarios nao      �
�          �foram preenchidos.                                          �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�Nenhum                            	     					�
�������������������������������������������������������������������������*/
Function fG920RFSpo()
	Local	oModel		:=	FWModelActive()
	Local	oModelRFS	:=	oModel:GetModel('RFSMASTER')
	Local 	cMsg		:=""
	Local	lRet		:= .T.

	cMsg	:=OemToAnsi(STR0034)		//"Um ou mais dos campos da Pasta ESTAGIO: Natureza, Nivel, Entidade, Agente,"
	cMsg	:= cMsg+OemToAnsi(STR0035)	//" Coordenador ou Data Prevista Final Est�gio, est�(o) vazio(s), mas a grava��o da informa��o ser� realizada normalmente."

	If SRA->RA_CATEFD == "906"
		If oModelRFS:GetValue('RFS_NATUR') <> "2"
			Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0046), 1, 0 )	//ATENCAO"###"O campo Natureza do Est�gio deve ser preenchido com: 2-N�o obrigat�rio."
			lRet := .F.
		ElseIf oModelRFS:GetValue('RFS_NIVEL') == "9"
			Help( " ", 1, OemToAnsi(STR0015),, OemToAnsi(STR0047), 1, 0 )	//ATENCAO"###"O campo N�vel de est�gio n�o pode ser preenchido com 9 para a categoria 906."
			lRet := .F.
		EndIf
	ElseIf cEFDAviso == '0' .AND. ((SRA->RA_CATFUNC $ 'E*G') .OR. fGP010FoiE())
		If (empty(oModelRFS:GetValue('RFS_NATUR')) .OR. empty(oModelRFS:GetValue('RFS_NIVEL'))) .OR. (empty(oModelRFS:GetValue('RFS_ENTIDA')) .OR. empty(oModelRFS:GetValue('RFS_AGENTE')) .OR. empty(oModelRFS:GetValue('RFS_COORD')) .OR. empty(oModelRFS:GetValue('RFS_DTFIM')))
			Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## "OK" ##
		EndIf
	EndIf
Return lRet

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � f927Comm   	�Autor�  Glaucia M.       � Data �23/07/2014�
�����������������������������������������������������������������������Ĵ
�Descri��o �Commit do Model para integracao com o TAF                   �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �f927Comm(oModel)           						         	�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Verifica o parametro MV_INTTAF, e se necessario   �
�          �integrara com o modulo TAF.                                 �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�O Model para "commit" dos dados    	     					�
�������������������������������������������������������������������������*/
Static Function fG920Com(oModel)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local cCPF			:= ""
Local cCateg 		:= ""
Local cMatTemp 		:= ""
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309"
Local cTrabSemVincu	:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
Local aTpAlt		:= {.F., .F., .F., .F.}
Local lTpEst		:= .F.
Local oMdlRFS		:= oModel:GetModel("RFSMASTER")
Local cVersEnvio	:= ""
Local cChave 		:= ""
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

cCPF	   := SRA->RA_CIC
cCateg	:= Iif(SRA->RA_CATEFD $ "901|906",SRA->RA_CATEFD,"")

cMatTemp:= SRA->RA_MAT

//--------------------------------
//| Verifica se existe integra��o
//--------------------------------
If (lIntTAF .Or. lMiddleware) .AND. FunName() != "GPEM035"

	If FindFunction("fVersEsoc")
		fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
	Else
		cVersEnvio := '2.2'
	EndIf

	//Montando chave do trabalhador

	If !lMiddleware
		If cVersEnvio >= "9.0"
			cChave := AllTrim( SRA->RA_CIC ) + ";" + Iif(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
		Else
			cChave := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
		EndIf
	Else
		If cVersEnvio >= "9.0" .And. lGeraMat
			cChave := AllTrim( SRA->RA_CODUNIC)
		Else
			cChave := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
		EndIf
	Endif

	If !(EMPTY(cCPF)) .and. cCateg $ "103*901*906"
		If !lMiddleware
			cStatus := TAFGetStat( "S-2300", cChave )
		Else
			cStatus := "-1"
			fPosFil( cEmpAnt, SRA->RA_FILIAL )
			aInfoC   := fXMLInfos()
			If LEN(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cChave,fTamRJEKey(), " ")
			cStatus 	:= "-1"
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus )
		EndIf
		cStat1 := "-1"

		//Verifica��o de qual o tipo de altera��o foi realizada - RFS
		fVerAltEst(@lTpEst, oMdlRFS)

		//Verifica��o de qual o tipo de altera��o foi realizada - SRA
		lRet := fVerTpAlt(@aTpAlt,lRet,lTpEst, cVersEnvio)

		If cCateg $ cTrabSemVincu .AND. lRet
			//---------------------------------------
			//| Verifica existencia ou Status <> "4"
			//| Se status <> "4" ou n�o existir, cria reg
			//--------------------------------------------
			If ( aTpAlt[1] .OR. aTpAlt[2] )
				lRet := fInt2300New("SRA", /*lAltCad*/, 3,"S2300",/*cTFilial*/,/*aDadosXml*/,cVersEnvio,.T., oMdlRFS)
			Else
				//-----------------------------------------
				//| Registro Status == "4" e tem altera��o
				//| Verifica se foi altera��o cadastral ou contratual
				//| Faz uma analise dentro da SRA (Cad/Con) e RFS (Con)
				//------------------------------------------------------
				If aTpAlt[3] .And. M->RA_SITFOLH <> "D"
					lRet := fIntAdmiss("SRA",,4,"S2205",,,)
				EndIf

				If aTpAlt[4]
					lRet := fInt2306New("SRA",/*lAltCad*/, 4,"S2306",/*cTFilial*/,/*dtEf*/,cVersEnvio ,.T.,oMdlRFS)

				EndIf
			Endif

			If lRet
				If FindFunction("fEFDMsg")
					fEFDMsg()
				EndIf

				FWFormCommit(oModel)
			EndIf
		Endif
	EndIf

Else
	FWFormCommit(oModel)
EndIf

If (lIntTaf .Or. lMiddleware) .AND. (Findfunction("fGP26SRA")) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg) )
	fGP26SRA(cCPF,cCateg,cMatTemp,3,"GPEA920")
EndIf

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������Ŀ
�Funcao    � fVerAltEst   	�Autor�  Marcos Coutinho   � Data �20/07/2017�
�����������������������������������������������������������������������ĳ
�Descricao �Realizar a verificacao das alteracoes do estagiario         �
�����������������������������������������������������������������������ĳ
�Sintaxe   �fVerAltEst( lTpEst )          						         	�
�����������������������������������������������������������������������ĳ
� Uso      �GPEA920 - Verifica se houve alguma altera��o no registro    �
�          �corrente do estagi�rio                                      �
�����������������������������������������������������������������������ĳ
� Retorno  �Boolean													            	�
�����������������������������������������������������������������������ĳ
�Parametros� Uma variavel l�gica base para retorno             			�
�����������������������������������������������������������������������*/
Function fVerAltEst( lTpEst, oMdl )
Local aCpos := {}
Local nI := 0
Local cTrabSemVinc:= fCatTrabEFD("TSV") //"201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903" //Trabalhador sem vinculo
Default lTpEst := .F.
aCpos := {"RFS_NATUR", "RFS_NIVEL", "RFS_ATUA", "RFS_APOLIC", "RFS_DTFIM", "RFS_ENTIDA", "RFS_AGENTE", "RFS_COORD"}

If cPaisLoc == "BRA"
	If SRA->RA_CATEFD $ cTrabSemVinc
		For nI := 1 To Len(aCpos)
			if &('RFS->' + aCpos[nI]) <> oMdl:GetValue(aCpos[nI])
				lTpEst := .T.
			Endif
		neXT nI
	EndIf
EndIf
Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fGP920Coor()	�Autor�  Glaucia M.       � Data �01/07/2013�
�����������������������������������������������������������������������Ĵ
�Descri��o �Complemento da valida��o do campo RFS_COORD                 �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fGP920Coor()             									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA920 - Campo RFS_COORD                                   �
�����������������������������������������������������������������������Ĵ
� Retorno  �Boolean														�
�����������������������������������������������������������������������Ĵ
�Parametros�Nenhum                            	     					�
�������������������������������������������������������������������������*/
Function fGP920Age( )

	Local lRet	:=	.T.
	Local cMsg

	//Posiciono na tabela para garantir abertura quando MVC e ExecAuto
	dbSelectArea("RFR")
	dbSetOrder(1) //RFR_FILIAL+RFR_AGENTE
	If RFR->(dbSeek(xFilial("RFR")+&(ReadVar())))
		If (ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2300", .F.,,,@cVersEnvio, @cVersGPE),)

		If Empty(cVersGPE)
			cVersGPE := cVersEnvio
		EndIf

		If (cVersEnvio <= "2.5")
			If cEFDAviso <> "2"
				cMsg:= OemtoAnsi(STR0043)+" "+ OemtoAnsi(STR0008)+", "  //"O Agente de Est�gio escolhido"   ## n�o possui todos os campos necess�rios preenchidos
				cMsg:= cMsg+OemtoAnsi(STR0016)+" "+ OemtoAnsi(STR0001)+"."+CRLF // para contemplar o cadastro ## Informa��es Excluvisas Est�gio

				cMsg:= cMsg+OemtoAnsi(STR0044)+CRLF	//"Os campos necess�rios para Agente de Est�gio s�o:"
				cMsg:= cMsg+OemtoAnsi(STR0027)+", "								//"Nome"
				cMsg:= cMsg+OemtoAnsi(STR0020)+", "								//"Endere�o"
				cMsg:= cMsg+OemtoAnsi(STR0028)+", "								//"Bairro"
				cMsg:= cMsg+OemtoAnsi(STR0023)+", "								//"CEP"
				cMsg:= cMsg+OemtoAnsi(STR0022)+" " + OemToAnsi(STR0045) + " "	//"C�digo Munic�pio" ## "e"
				cMsg:= cMsg+OemtoAnsi(STR0021)+"."								//"Estado"

				If empty(RFR->RFR_NOME) .OR. empty(RFR->RFR_END) .OR. empty(RFR->RFR_BAIRRO) .OR. empty(RFR->RFR_CEP) .OR. empty(RFR->RFR_CODMUN) .OR. empty(RFR->RFR_UF)
					If cEFDAviso == "1"
						lRet:= .F.
						Help( ,, 'Help',, cMsg, 1, 0 )
					Else
						Aviso(OemtoAnsi(STR0015),OemtoAnsi(cMsg),{OemtoAnsi(STR0017)}) //"Atencao" ## Como a categoria do Funcionario eh estagiario, apresentaremos o cadastro ## Informacoes Exclusivas do Estagio ## "OK" ##
					EndIF

				EndIf
			EndIf
		Endif
	EndIf

Return lRet
