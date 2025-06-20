#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA053.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA041  �Autor  � Vitor Felipe       � Data � 11/06/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cadastro de Aliquotas para o ISS.                         ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA053()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CE2")
	oBrowse:SetDescription(STR0001)//"Pedidos de Vendas x Entradas"
	oBrowse:Activate()
	
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Vitor Felipe       � Data � 11/06/2012  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    	   ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA053' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA053' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA053' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA053' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Vitor Felipe       � Data � 11/06/2012  ���
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
	Local oStructCAB := FWFormStruct( 1 , "CE2" )    

	oModel	:=	MPFormModel():New('FISA053MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA053MOD' ,, oStructCAB )
	
 	oModel:SetPrimaryKey({'CE2_FILIAL'},{'CE2_NUMPV'},{'CE2_DOCNF'},{'CE2_SERINF'},{'CE2_ITEMNF'},{'CE2_CODNF'},{'CE2_FORNNF'},{'CE2_LOJANF'})
	
	oModel:SetDescription(STR0001) //"Pedidos de Vendas x Entradas"
	
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Vitor Felipe       � Data � 11/06/2012  ���
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
	Local oModel     := FWLoadModel( "FISA053" )
	Local oStructCAB := FWFormStruct( 2 , "CE2" )	
		
	oView:SetModel(oModel)
	
	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA053MOD')	
	
	oView:CreateHorizontalBox( "CABEC" , 100 )
	
	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )	

	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Vitor Felipe       � Data � 11/06/2012  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.	        	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�															       ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cNumPV	:=	oModel:GetValue ('FISA053MOD','CE2_NUMPV')
	Local cDocNF	:=	oModel:GetValue ('FISA053MOD','CE2_DOCNF')
	Local cSeriNF	:=	oModel:GetValue ('FISA053MOD','CE2_SERINF')
	Local cItemNF	:=	oModel:GetValue ('FISA053MOD','CE2_ITEMNF')
	Local cCodNF	:=	oModel:GetValue ('FISA053MOD','CE2_CODNF')
	Local cFornNF	:=	oModel:GetValue ('FISA053MOD','CE2_FORNNF')
	Local cLojaNF	:=	oModel:GetValue ('FISA053MOD','CE2_LOJANF')                                                                            
	
	
	Local nOperation:=	oModel:GetOperation()
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CE2")  //Valores de exclus�o de PIS e Cofins para sociedade cooperativa.
		CE2->(DbSetOrder (1))
		If CE2->(msSeek(xFilial("CE2")+cNumPV+cDocNF+cSeriNF+cItemNF+cCodNF+cFornNF+cLojaNF))			
			lRet := .F.			
			Help("",1,STR0002,STR0002,STR0008,1,0)
		EndIF		
		
	EndIF
Return lRet

