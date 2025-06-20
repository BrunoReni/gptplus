#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GPEA060.CH"

#DEFINE Confirma 1
#DEFINE Redigita 2
#DEFINE Abandona 3

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Gpea060  � Autor � Andreia dos Santos    � Data � 25/11/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Resultados de Exames                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Leandro Dr. �15/10/12�M12RH1�Requisito RHU210_03_03. Unificao da Folha ���
���Carlos E. O.�08/05/13�      �Conversao para MVC                        ���
���Jaqueline L.�23/02/18�      �Corre��o no filtro da Filial na Desc de Ex���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Gpea060

	PRIVATE aRotina := MenuDef()

	cCadastro := OemToAnsi(STR0006)  //"Cadastro de Resultado de Exames"

	//��������������������������������������������������������������Ŀ
	//� Verifica se o Arquivo Esta Vazio                             �
	//����������������������������������������������������������������
	If !ChkVazio("SRA")
		Return
	Endif

	oBrwSRA := FWmBrowse():New()
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(cCadastro)

	GpLegMVC(@oBrwSRA)	// Adicionar a Legenda no Browse

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"SRA","1")
	//Filtro padrao do Browse conforme tabela SQ3 (Cargo)
	oBrwSRA:SetFilterDefault(cFiltraRh)
	oBrwSRA:Activate()

Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Carlos Eduardo O.     � Data � 08/05/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0001  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.GPEA060'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0027  Action 'VIEWDEF.GPEA060'	OPERATION 4 ACCESS 0 //"Manutencao"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA060'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Carlos Eduardo O.     � Data � 08/05/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Credito Infonavit                                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

	// Cria o objeto do Modelo de Dados
	Local oModelRC8 := MPFormModel():New('GPEA060')	//ResExame = Resultado de Exame

	//Define os campos do SRA que ser�o apresentados na tela
	Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo) + "|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}

	// Cria a estrutura a ser usado no Model
	Local oStruSRA := FWFormStruct( 1, 'SRA', bAvalCampo)
	Local oStruRC8 := FWFormStruct( 1, 'RC8')
	Local bLinePos	:= {|oMdl| Gp060LinePos(oMdl)}

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModelRC8:AddFields('GPEA060_SRA', /*cOwner*/, oStruSRA)
	oModelRC8:AddGrid( 'GPEA060_RC8', 'GPEA060_SRA', oStruRC8, ,/*bLinePre,*/ bLinePos, /*bPreVal*/, /*bPosVal*/)
	oModelRC8:SetRelation( 'GPEA060_RC8', { { 'RC8_FILIAL', 'xFilial( "RC8" )' }, { 'RC8_MAT', 'RA_MAT' } }, RC8->( IndexKey( 1 ) ) )

	//Ativa verificacao de chave duplicada
	oModelRC8:GetModel('GPEA060_RC8'):SetUniqueLine( {'RC8_DATA', 'RC8_TIPOEX', 'RC8_EXTIPO', 'RC8_EXAME', 'RC8_INDRES'} )

	//Inicializa RC8->RC8_MAT com numero de matricula da tabela pai(funcionarios) SRA->RA_MAT
	oStruRC8:SetProperty("RC8_MAT", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'SRA->RA_MAT' ))

	oModelRC8:GetModel("GPEA060_SRA"):SetOnlyView( .T. )
	oModelRC8:GetModel("GPEA060_SRA"):SetOnlyQuery( .T. )

Return oModelRC8

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Carlos Eduardo O.     � Data � 08/05/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Credito Infonavit       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
	//Define os campos do SRA que ser�o apresentados na tela
	Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo) + "|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}

	// Cria a estrutura a ser usada na View
	Local oStruSRA := FWFormStruct(2, 'SRA' , bAvalCampo)
	Local oStruRC8 := FWFormStruct(2, 'RC8' )

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModelRC8 := FWLoadModel('GPEA060')

	// Cria o objeto de View
	Local oView := FWFormView():New()
	oView:SetDescription(STR0026)

	//Alterar propriedade folder do campo RA_ADMISSA na strutura da SRA
	//para aparecer na mesma tela dos outros campos

	oStruSRA:SetProperty('RA_ADMISSA', MVC_VIEW_FOLDER_NUMBER, '1')

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel(oModelRC8)

	//Adiciona no nosso View um controle do tipo FormField(antiga enchoice)
	oView:AddField('VIEW_SRA', oStruSRA, 'GPEA060_SRA')

	//Retira do Grid a coluna de matricula
	oStruRC8:RemoveField('RC8_MAT')

	//Adiciona no nosso View um controle do tipo Grid
	oView:AddGrid('VIEW_RC8', oStruRC8, 'GPEA060_RC8')

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('SUPERIOR' , 30 )
	oView:CreateHorizontalBox('INFERIOR' , 70 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SRA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RC8', 'INFERIOR' )

Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �A060DescExam�Autor�Andreia dos Santos  � Data �  26/11/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Traz o nome do exame                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA060                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function A060DescExam

	Local nBytes
	Local oModel := FWModelActive()
	Local TipoExame := oModel:GetValue('GPEA060_RC8', 'RC8_TIPOEX')

	nBytes := 20

	TM4->(dbSetOrder(1))
	If TM4->(dbSeek(xFilial( "TM4" , TM4_FILIAL) + TipoExame ))
		cRet := Left(TM4->TM4_NOMEXA+Space(nBytes),nBytes)
	Else
		cRet := Left(STR0016+Space(nBytes),nBytes)  //"** Nao Cadastrado **"
	Endif

	oModel:SetValue('GPEA060_RC8', 'RC8_NOMEEX', cRet)

Return  .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �a060Result�Autor  �Carlos E. Olivieri  � Data �  12/07/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta quadro com multipla escolha para preenchimento do    ���
���          � Resultado do Exame                                         ���
�������������������������������������������������������������������������͹��
���Uso       � GPEA060                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a060Result()

	Local cTitulo  		:= ""
	Local MvPar    		:= &(ReadVar())
	Local MvParDef 		:= "" 
	Local MvRet			:= ""
	Local lRet     		:= .T. 
	Local l1Elem   		:= .F.
	Local nGrupo			  
	Local aArea			:= GetArea()
	
	Private aResul	 := {}
	
	VAR_IXB := MvPar

	dbSelectArea("SX5")
	If dbSeek(cFilial+"00RM")
		cTitulo := Alltrim(Left(X5Descri(),20))
	Endif

	If dbSeek(cFilial+"RM")
		While !Eof() .And. SX5->X5_Tabela == "RM"
			If (Left(SX5->X5_Chave,1)$"1#2#3#4#5#6" )
			   	Aadd(aResul,	Alltrim(X5Descri()))
				MvParDef	+=	Left(SX5->X5_Chave,1)
			EndIf
			dbSkip()
		Enddo
	Else
		Help(" ",1,"GPEXATSDEF") // Estou usando situacao Default, nao achei tabela
		Return .F.
	Endif

	If len(aResul) > 0
		f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,1)		// Chama funcao f_Opcoes
		For nGrupo := 1 To Len(MvPar)
			If (SubStr(MvPar, nGrupo, 1) # "*")
				MvRet += SubStr(mvpar, nGrupo, 1)
			Else
				MvRet += Space(1)
			Endif
		Next nGrupo
	Else
		MvRet := space(1)						 					   	// Devolve Resultado
	Endif

	VAR_IXB := AllTrim(MvRet)
	RestArea(aArea)
	
Return(lRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp060LinePos� Autor � Carlos Eduardo O.     � Data � 09/05/13 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da linha do grid, se os campos foram preenchidos   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gp060LinePos(oMdl)                                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdl = objeto do modelo                                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Com bloco de codigo no ModelDef                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Static Function Gp060LinePos(p_oModl)

	Local lRet := .T.

	If Empty(p_oModl:GetValue('RC8_DATA'))

		Help(,, 'Help',, STR0013 , 1, 0) //Informe a data do Exame
		lRet := .F.

	Elseif Empty(p_oModl:GetValue('RC8_TIPOEX'))

		Help(,, 'Help',, STR0014, 1, 0) //Informe o tipo do Exame"
		lRet := .F.

	Elseif Empty(p_oModl:GetValue('RC8_EXTIPO'))

		Help(,, 'Help',, STR0022  , 1, 0) //Tipo de Exame(R/S) e/ou Resultado n�o Informado
		lRet := .F.

	Elseif Empty(p_oModl:GetValue('RC8_EXAME'))

		Help(,, 'Help',, STR0021 , 1, 0) //Tipo de Exame(R/S) n�o Informado
		lRet := .F.

	Elseif Empty(p_oModl:GetValue('RC8_INDRES'))

		Help(,, 'Help',, STR0020 , 1, 0) //Indique Um Valor V�lido(1 Ou 2) Para Este Tipo De Exame(ref.), No Campo Indicador De Resultado
		lRet := .F.

	Endif

Return lRet
