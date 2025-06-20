#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA045.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA045  �Autor  � Cecilia Carvalho   � Data � 26/12/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Controle de Credito SPED COFINS                           ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA045()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CCW")
	oBrowse:SetDescription(STR0001) //"Controle de Credito COFINS"
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
		
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA045' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA045' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA045' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA045' OPERATION 5 ACCESS 0 //'Excluir'
		
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
	Local oStructCAB := FWFormStruct( 1 , "CCW" )    
	
	oModel	:=	MPFormModel():New('FISA045MOD', ,{ |oModel| ValidForm(oModel) }  )

	oModel:AddFields( 'FISA045MOD' ,, oStructCAB )		
	oModel:SetDescription(STR0007) // "Controle de Creditos PIS"	
    oModel:GetModel('FISA045MOD'):SetDescription(STR0001) //"Controle de Cr�ditos Fiscais"
	oModel:SetPrimaryKey({'CCW_FILIAL', 'CCW_PERIOD', 'CCW_ANO', 'CCW_MES', 'CCW_COD','CCW_ORICRE', 'CCW_CNPJ'})	
	
	//���������������������������������������������������������������������������������0�
	//�Define que os campos podem ser editados apenas em uma opera��o de inclus�o       �
	//���������������������������������������������������������������������������������0�
	oStructCAB:SetProperty( 'CCW_PERIOD' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CCW_ANO' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CCW_MES' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CCW_COD'     	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CCW_ORICRE'   , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CCW_CNPJ'     , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
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
	Local oModel     := FWLoadModel( "FISA045" )
	Local oStructCAB := FWFormStruct( 2 , "CCW" )	

	oView:SetModel(oModel)
	oView:AddField( "VIEW_CCW" , oStructCAB , 'FISA045MOD')	
	oView:CreateHorizontalBox( "CABEC" , 100 )
	oView:SetOwnerView( "VIEW_CCW" , "CABEC" )

Return oView	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Cecilia Carvalho    � Data � 26/12/2011 ���
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
	Local cPeriod	:=	oModel:GetValue ('FISA045MOD','CCW_PERIOD')
	Local cCod		:=	oModel:GetValue ('FISA045MOD','CCW_COD')
	Local cAno		:=	oModel:GetValue ('FISA045MOD','CCW_ANO')
	Local cMes		:=	oModel:GetValue ('FISA045MOD','CCW_MES')
	Local cOriCre	:=	oModel:GetValue ('FISA045MOD','CCW_ORICRE')
	Local cCodCnpj	:=	oModel:GetValue ('FISA045MOD','CCW_CNPJ')
	Local nOperation :=	oModel:GetOperation()
	Local cChave	:= xFilial("CCW")+cPeriod+cAno+cMes+cCod+cOriCre+cCodCnpj //CCW_FILIAL, CCW_PERIOD, CCW_ANO, CCW_MES, CCW_COD, CCW_ORICRE, CCW_CNPJ, R_E_C_D_E_L_
	Local nIndice	:= 1		
		
	If nOperation == 3  //Inclus�o de informa��es
		DbSelectArea ("CCW")
		DbSetOrder (5)
		nIndice := 5
		cChave	:= xFilial("CCW")+cPeriod+oModel:GetValue ('FISA045MOD','CCW_ANO')+oModel:GetValue ('FISA045MOD','CCW_MES')+oModel:GetValue ('FISA045MOD','CCW_ORICRE')+oModel:GetValue ('FISA045MOD','CCW_CNPJ')+cCod                                                                                        

		DbSetOrder (nIndice)
		If DbSeek( cChave )	.and.  nOperation == 3					
			lRet := .F.			
			Help("",1,"Help","Help",STR0008,1,0) //"periodo e Codigo j� cadastrados!"
		EndIF			
	EndIF 
	
Return lRet