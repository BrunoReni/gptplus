#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA217.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA217  �Autor  � Thiago Y.M.N       � Data � 20/07/2020  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Controle de Retencoes SPED COFINS                         ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA217()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SFW")
	oBrowse:SetDescription(STR0001) //"Controle de Saldo de Retencoes COFINS"
	oBrowse:Activate()     

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Thiago Y.M.N       � Data � 20/07/2020  ���
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
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA217' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA217' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA217' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA217' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Thiago Y.M.N       � Data � 20/07/2020  ���
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
	Local oStructCAB := FWFormStruct( 1 , "SFW" )    
	
	oModel	:=	MPFormModel():New('FISA217MOD', ,{ |oModel| ValidForm(oModel) } )	
	
	oModel:AddFields( 'FISA217MOD' ,, oStructCAB )		
	oModel:SetDescription(STR0001) // "Controle de Retencoes COFINS"
    oModel:GetModel('FISA217MOD'):SetDescription(STR0001) //"Controle de Cr�ditos Fiscais"
	oModel:SetPrimaryKey({"FW_NATRET"},{"FW_PER"}, {"FW_TPREG"}, {"FW_CONSOL"}, {"FW_MESANO"})
	
	//���������������������������������������������������������������������������������0�
	//�Define que os campos podem ser editados apenas em uma opera��o de inclus�o       �
	//���������������������������������������������������������������������������������0�
	oStructCAB:SetProperty( 'FW_NATRET' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'FW_PER' 		, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'FW_TPREG' 		, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'FW_CONSOL'    	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })//X3_MODAL == 1 para este campo
	oStructCAB:SetProperty( 'FW_MESANO'    	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Thiago Y.M.N       � Data � 20/07/2020  ���
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
	Local oModel     := FWLoadModel( "FISA217" )
	Local oStructCAB := FWFormStruct( 2 , "SFW")	

	oView:SetModel(oModel)
	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA217MOD')	
	oView:CreateHorizontalBox( "CABEC" , 100 )
	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Thiago Y.M.N       � Data � 20/07/2020  ���
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
	Local cNatRet	:=	oModel:GetValue ('FISA217MOD','FW_NATRET')
	Local cPer		:=	oModel:GetValue ('FISA217MOD','FW_PER')
	Local cTpReg	:=	oModel:GetValue ('FISA217MOD','FW_TPREG')
	Local cConsol	:=	oModel:GetValue ('FISA217MOD','FW_CONSOL')
	Local cMesAno	:=	oModel:GetValue ('FISA217MOD','FW_MESANO')
	Local nRessa	:=	oModel:GetValue ('FISA217MOD','FW_RESSA')
	Local nComp		:=	oModel:GetValue ('FISA217MOD','FW_COMP')
	Local nVlDisp	:=	oModel:GetValue ('FISA217MOD','FW_VLDISP')
	Local cBlql		:=	oModel:GetValue ('FISA217MOD','FW_RESRET')
	Local nOperation :=	oModel:GetOperation()
	Local cChave	:= xFilial("SFW")+cNatRet+cPer+cTpReg+cConsol+cMesAno

	If (nOperation == 3 .Or. nOperation == 4) .And. ((nRessa + nComp) > nVlDisp)
		lRet := .F.			
		Help("",1,"Help","Help",STR0002,1,0)
	ElseIf nOperation == 4 .And. cBlql == "2" .And. ((nRessa + nComp) >= nVlDisp) 
		lRet := .F.			
		Help("",1,"Help","Help",STR0007,1,0)
	EndIf
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("SFW")
		SFW->(DbSetOrder (1))

		If SFW->(DbSeek( cChave  ))			
			lRet := .F.			
			Help("",1,"Help","Help",STR0008,1,0)
		EndIF			
	EndIF

Return lRet
