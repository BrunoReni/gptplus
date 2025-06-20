#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA216.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA216  �Autor  � Thiago Y.M.N       � Data � 20/07/2020  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Controle de Retencoes SPED PIS                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA216()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SFV")
	oBrowse:SetDescription(STR0001) //"Controle de Retencoes PIS"
	oBrowse:Activate()     

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef      �Autor  � Thiago Y.M.N       � Data � 20/07/2020   ���
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
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA216' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA216' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA216' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA216' OPERATION 5 ACCESS 0 //'Excluir'
		
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
	Local oStructCAB := FWFormStruct( 1 , "SFV" )    
	
	oModel	:=	MPFormModel():New('FISA216MOD', ,{ |oModel| ValidForm(oModel) } )	
	
	oModel:AddFields( 'FISA216MOD' ,, oStructCAB )		
	oModel:SetDescription(STR0001) // "Controle de Retencoes PIS"
    oModel:GetModel('FISA216MOD'):SetDescription(STR0001) //"Controle de Cr�ditos Fiscais"
	oModel:SetPrimaryKey({"FV_NATRET"},{"FV_PER"}, {"FV_TPREG"}, {"FV_CONSOL"}, {"FV_MESANO"})
	
	//���������������������������������������������������������������������������������0�
	//�Define os campos que podem ser editados apenas em uma opera��o de inclus�o       �
	//���������������������������������������������������������������������������������0�
	oStructCAB:SetProperty( 'FV_NATRET' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'FV_PER' 		, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'FV_TPREG' 		, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'FV_CONSOL'    	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })//X3_MODAL == 1 para este campo
	oStructCAB:SetProperty( 'FV_MESANO'    	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
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
	Local oModel     := FWLoadModel( "FISA216" )
	Local oStructCAB := FWFormStruct( 2 , "SFV")	

	oView:SetModel(oModel)
	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA216MOD')	
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
	Local cNatRet	:=	oModel:GetValue ('FISA216MOD','FV_NATRET')
	Local cPer		:=	oModel:GetValue ('FISA216MOD','FV_PER')
	Local cTpReg	:=	oModel:GetValue ('FISA216MOD','FV_TPREG')
	Local cConsol	:=	oModel:GetValue ('FISA216MOD','FV_CONSOL')
	Local cMesAno	:=	oModel:GetValue ('FISA216MOD','FV_MESANO')
	Local nRessa	:=	oModel:GetValue ('FISA216MOD','FV_RESSA')
	Local nComp		:=	oModel:GetValue ('FISA216MOD','FV_COMP')
	Local nVlDisp	:=	oModel:GetValue ('FISA216MOD','FV_VLDISP')
	Local cBlql		:=	oModel:GetValue ('FISA216MOD','FV_RESRET')
	Local nOperation :=	oModel:GetOperation()
	Local cChave	:= xFilial("SFV")+cNatRet+cPer+cTpReg+cConsol+cMesAno
	
	If (nOperation == 3 .Or. nOperation == 4) .And. ((nRessa + nComp) > nVlDisp)
		lRet := .F.			
		Help("",1,"Help","Help",STR0002,1,0)
	ElseIf nOperation == 4 .And. cBlql == "2" .And. ((nRessa + nComp) >= nVlDisp) 
		lRet := .F.			
		Help("",1,"Help","Help",STR0007,1,0)
	EndIf

	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("SFV")
		SFV->(DbSetOrder (1))

		If SFV->(DbSeek( cChave  ))			
			lRet := .F.			
			Help("",1,"Help","Help",STR0008,1,0)
		EndIF				
	EndIF

Return lRet
