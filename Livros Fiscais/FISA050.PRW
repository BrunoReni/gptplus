#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA050.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA050  �Autor  � Cecilia Carvalho   � Data � 26/12/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Controle de Credito SPED PIS                              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA050()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CG4")
	oBrowse:SetDescription(STR0001) //"Controle de Credito PIS"
	oBrowse:Activate()     

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Cecilia Carvalho   � Data � 26/12/2011  ���
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
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA050' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA050' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA050' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA050' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Cecilia Carvalho   � Data � 26/12/2011  ���
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
	Local oStructCAB := FWFormStruct( 1 , "CG4" )    
	
	oModel	:=	MPFormModel():New('FISA050MOD', ,{ |oModel| ValidForm(oModel) } )	
	
	oModel:AddFields( 'FISA050MOD' ,, oStructCAB )		
	oModel:SetDescription(STR0007) // "Controle de Creditos PIS"
    oModel:GetModel('FISA050MOD'):SetDescription(STR0001) //"Controle de Cr�ditos Fiscais"
	oModel:SetPrimaryKey({"CG4_RESCOM"},{"CG4_PISCOF"},{"CG4_PER"},{"CG4_COD"}) 

	//���������������������������������������������������������������������������������0�
	//�Define que os campos podem ser editados apenas em uma opera��o de inclus�o       �
	//���������������������������������������������������������������������������������0�
	oStructCAB:SetProperty( 'CG4_PISCOF'   	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CG4_PER'   	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CG4_PERORI'   	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CG4_COD'   	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })

Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Cecilia Carvalho   � Data � 26/12/2011  ���
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
	Local oModel     := FWLoadModel( "FISA050" )
	Local oStructCAB := FWFormStruct( 2 , "CG4" )	

	oView:SetModel(oModel)
	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA050MOD')	
	oView:CreateHorizontalBox( "CABEC" , 100 )
	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Cecilia Carvalho   � Data � 26/12/2011  ���
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
	Local cPISCOF	:=	oModel:GetValue ('FISA050MOD','CG4_PISCOF')
	Local cPer		:=	oModel:GetValue ('FISA050MOD','CG4_PER')
	Local cPerOri	:=	oModel:GetValue ('FISA050MOD','CG4_PERORI')
	Local cCod		:=	oModel:GetValue ('FISA050MOD','CG4_COD')
                                                                
	Local nOperation :=	oModel:GetOperation()
	Local cChave	:= xFilial("CG4")+cPISCOF+cPer+cPerOri+cCod
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CG4")
		CG4->(DbSetOrder (1))
		If CG4->(DbSeek( cChave  ))			
			lRet := .F.			
			Help("",1,"Help","Help",STR0008,1,0) //"Periodo e Codigo j� cadastrados!"
		EndIF		
		
	EndIF

Return lRet
