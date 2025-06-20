#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA076.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA076  �Autor  � Caio Martins       � Data � 04/12/2017  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Informac�es Adic. Diferimento                             ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA076()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CFA")
	oBrowse:SetDescription(STR0001) //"Informac�es Adic. Diferimento"
	oBrowse:Activate()     

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Cecilia Carvalho   � Data � 04/12/2017  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()
	
	Local aRotina := {}	
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA076' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA076' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA076' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA076' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Cecilia Carvalho   � Data � 04/12/2017  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do ModelDef para o MVC.                               ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CFA" )    
	
	oModel	:=	MPFormModel():New('FISA076MOD', ,{ |oModel| ValidForm(oModel) } )	
	
	oModel:AddFields( 'FISA076MOD' ,, oStructCAB )		
	oModel:SetDescription(STR0001) // "Informac�es Adic. Diferimento"
    oModel:GetModel('FISA076MOD'):SetDescription(STR0001) // "Informac�es Adic. Diferimento"
	oModel:SetPrimaryKey({"CFA_PERAPU"},{"CFA_TPCON"},{"CFA_CODCON"},{"CFA_CNPJ"},{"CFA_ALIQ"},{"CFA_CODCRE"},{"CFA_CONSOL"})	
	
	//���������������������������������������������������������������������������������0�
	//�Define que os campos podem ser editados apenas em uma opera��o de inclus�o       �
	//���������������������������������������������������������������������������������0�
	oStructCAB:SetProperty( 'CFA_PERAPU' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CFA_TPCON' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CFA_CODCON' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CFA_CNPJ'     	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CFA_ALIQ'     	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CFA_CODCRE'    , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CFA_CONSOL'    , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Cecilia Carvalho   � Data � 04/12/2017  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao da Visualizacao para o MVC.                           ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA076" )
	Local oStructCAB := FWFormStruct( 2 , "CFA" )	

	oView:SetModel(oModel)
	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA076MOD')	
	oView:CreateHorizontalBox( "CABEC" , 100 )
	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Cecilia Carvalho   � Data � 04/12/2017  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.                    ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cPeriod	:=	oModel:GetValue ('FISA076MOD','CFA_PERAPU')
	Local cTpCon	:=	oModel:GetValue ('FISA076MOD','CFA_TPCON')
	Local cCodCon	:=	oModel:GetValue ('FISA076MOD','CFA_CODCON')
	Local cCNPJ		:=	oModel:GetValue ('FISA076MOD','CFA_CNPJ')
	Local aTamAliq	:= 	TamSx3("CFA_ALIQ")
	Local cAliq		:=	Str(oModel:GetValue ('FISA076MOD','CFA_ALIQ'),aTamAliq[1],aTamAliq[2])
	Local cCodCre	:=	oModel:GetValue ('FISA076MOD','CFA_CODCRE')
	Local cConsol	:=	oModel:GetValue ('FISA076MOD','CFA_CONSOL')
	Local nOperation :=	oModel:GetOperation()
	Local cChave	:= xFilial("CFA")+cPeriod+cTpCon+cCodCon+cCNPJ+cAliq+cCodCre+cConsol
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CFA")
		CFA->(DbSetOrder (1))
		If CFA->(DbSeek( cChave  ))			
			lRet := .F.			
			Help("",1,"Help","Help",STR0007,1,0) //"Registro j� cadastrado: Per�odo, Tipo da Contribui��o, C�digo da Contrib, CNPJ, Al�quota e C�digo do Cr�dito"
		EndIF		
		
	EndIF

Return lRet
