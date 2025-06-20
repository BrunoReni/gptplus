#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA039.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA039  �Autor  � Erick G Dias       � Data � 03/0102011  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cadastro da tabela de aliquotas por periodo.              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA039()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "CE9" )
	oBrowse:SetDescription(STR0001)//"Validade das aliquotas"
	oBrowse:Activate()
	
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    	   ���
������������������������������������������������������������������������������͹��
���Parametros�																		      	   ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA039' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA039' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA039' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA039' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do ModelDef para o MVC                         	   ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CE9" )    
	
	oModel	:=	MPFormModel():New('FISA039MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA039MOD' ,, oStructCAB )	
	
	oModel:SetPrimaryKey({"CE9_PER" },{ "CE9_CODIGO" },{ "CE9_ALQPIS" },{ "CE9_ALQCOF" })		

	oStructCAB:SetProperty( 'CE9_PER'    , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })		
	oStructCAB:SetProperty( 'CE9_CODIGO' , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CE9_ALQPIS' , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	oStructCAB:SetProperty( 'CE9_ALQCOF' , MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })
	
	oModel:SetDescription( "Exclus�es de PIS Cofins para Sociedade Cooperativa" )
	
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao da Visualizacao para o MVC                    	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                     	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA039" )
	Local oStructCAB := FWFormStruct( 2 , "CE9" )	

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA039MOD')	

	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.            	        ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�																  					  ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cPer		:=	oModel:GetValue ('FISA039MOD','CE9_PER'  )
	Local cCod		:=	oModel:GetValue ('FISA039MOD','CE9_CODIGO'  )
	Local nAlqPis		:=	oModel:GetValue ('FISA039MOD','CE9_ALQPIS'  )
	Local nAlqCof		:=	oModel:GetValue ('FISA039MOD','CE9_ALQCOF'  )
	Local lPIS		:= .F.
	Local lCOF		:= .F.
	Local nOperation:=	oModel:GetOperation()
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CE9")  //Valores de exclus�o de PIS e Cofins para sociedade cooperativa.
		CE9->(DbSetOrder (2))
		If CE9->(DbSeek(xFilial("CE9")+cPer+cCod+cvaltochar(nAlqPis)))			
			lPIS := .T.
		EndIF		
		
		CE9->(DbSetOrder (3))
		If CE9->(DbSeek(xFilial("CE9")+cPer+cCod+cvaltochar(nAlqCof)))			
			lCOF := .T.
		EndIF
		IF lPIS .AND. lCOF
			Help(" ",1,"Help",,STR0008,1,0)//"A data inicial tem que ser maior que a data final da linha superior."
			lRet := .F.
		EndIF
	EndIF


Return lRet

