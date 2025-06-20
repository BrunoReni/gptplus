#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA340.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o     � GPEA340A   � Autor � Mauricio Takakura            � Data � 17/11/10     ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o  � Cadastro de Sindicatos em MVC                                           ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe    � GPEA340()                                                               ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso       � Generico ( DOS e Windows )                                              ���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                           ���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC                    �  Motivo da Alteracao              ���
���������������������������������������������������������������������������������������Ĵ��
*/
Function GPEA340A()

	Local oMBrowse
	Local cFiltraRh

	//--Altera o Set Epch para 1920
	nEpoca := SET( 5,1920)

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias("RCE")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Cadastro de Sindicatos"

	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	cFiltraRh := CHKRH("GPEA340","RCE","1")
	oMBrowse:SetFilterDefault( cFiltraRh )

	oMBrowse:Activate()

	//--Retornar Set Epoch Padrao
	SET(5,nEpoca)

Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Mauricio Takakura� Data �17/11/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Criacao do Menu do Browse                                   �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA340                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA340A" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA340A" 		OPERATION 4 ACCESS 0				//'Alterar'

Return aRotina

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef 		�Autor�  Mauricio Takakura� Data �17/11/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA340                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()
Local oModel := FWLoadModel( "GPEA340" )
Return( oModel )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Mauricio Takakura� Data �17/11/2010�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA340                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ViewDef()
Local oView 	:= FWFormView():New()
Local oModel	:= FWLoadModel("GPEA340")
Local oStructRCE:= FWFormStruct(2, "RCE",{|cCampo|  AllTrim(cCampo) $ "|RCE_MED01|RCE_MED02|RCE_MED03|RCE_MED04|"})
Local oStruct	:= FWFormStruct(2, "RCE",{|cCampo|  AllTrim(cCampo) $ "|RCE_CODIGO|RCE_DESCRI|"})
Local nI 		:= 1

oView:SetModel(oModel)

oStruct:SetProperty('RCE_CODIGO', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetProperty('RCE_DESCRI', MVC_VIEW_CANCHANGE ,.F.)
oStruct:SetNofolder()
oView:AddField("GPEA340_RCE", oStruct,"GPEA340_RCE")
oView:AddField("GPEA340_1", oStructRCE,"GPEA340_RCE")
oView:CreateHorizontalBox("FIELDS", 10)
oView:CreateHorizontalBox("FIELDS1", 90)
oView:SetOwnerView("GPEA340_RCE", "FIELDS")
oView:SetOwnerView('GPEA340_1', 'FIELDS1')
Return oView
