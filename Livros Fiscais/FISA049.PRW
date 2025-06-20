#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA049.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA049  �Autor  � Erick G. Dias      � Data � 19/03/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cadastro de cr�dito referente a estoque de abertura.      ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA049()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""	

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "CF9" )
	oBrowse:SetDescription(STR0001)//"Estoque de abertura"
	oBrowse:Activate()

Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � MenuDef       �Autor  � Erick G. Dias      � Data � 19/03/2012  ���
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

	ADD OPTION aRotina TITLE STR0005 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA049' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA049' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA049' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FISA049' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.FISA049' OPERATION 8 ACCESS 0 //'Imprimir'
	
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ModelDef      �Autor  � Erick G. Dias      � Data � 19/03/2012  ���
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
	Local oStructCAB := FWFormStruct( 1 , "CF9" )

	oModel:= MPFormModel():New('FISA049MOD', ,{ |oModel| ValidForm(oModel) } )    
	oModel:AddFields( "CF9_CAB" ,, oStructCAB )
	oModel:SetPrimaryKey({"CF9_FILIAL"},{"CF9_CODBCC"},{"CF9_PERING"},{"CF9_CSTPIS"},{"CF9_ALQPIS"},{"CF9_CSTCOF"},{"CF9_ALQCOF"},{"CF9_CODCTA"})		
	oModel:SetDescription( STR0001)//"Estoque de abertura"
	
Return oModel 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Funcao    � ViewDef       �Autor  � Erick G. Dias      � Data � 19/03/2012  ���
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
	Local oModel     := FWLoadModel( "FISA049" )
	Local oStructCAB := FWFormStruct( 2 , "CF9" )

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , "CF9_CAB" )
	oView:CreateHorizontalBox( "CABEC" , 80 )
	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Erick G Dias       � Data � 19/03/2012  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.            	       ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�																   ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cCodBcc	:=	oModel:GetValue ('CF9_CAB','CF9_CODBCC'  )
	Local dPerIng	:=	oModel:GetValue ('CF9_CAB','CF9_PERING'  )
	Local cCstPis	:=	oModel:GetValue ('CF9_CAB','CF9_CSTPIS'  )
	Local nAlqPis	:=	oModel:GetValue ('CF9_CAB','CF9_ALQPIS'  )
	Local cCstCof	:=	oModel:GetValue ('CF9_CAB','CF9_CSTCOF'  )
	Local nAlqCof	:=	oModel:GetValue ('CF9_CAB','CF9_ALQCOF'  )
	Local cConta	:=	oModel:GetValue ('CF9_CAB','CF9_CODCTA'  )	  
	Local CDescPr	:=	oModel:GetValue ('CF9_CAB','CF9_DESCPR'  )
	Local nOperation:=	oModel:GetOperation()
    Local nRecno2	:= 0
	Local nRecno 	:= CF9->(Recno())

	If nOperation == 3 //.or. nOperation == 4  //Inclus�o de informa��es ou altera��es.		
		CF9->(DbSetOrder (1))
		If CF9->(DbSeek(xFilial("CF9")+cCodBcc+dTos(dPerIng)+cCstPis+Str(nAlqPis,8,4)+cCstCof+str(nAlqCof,8,4)+cConta))
				Help(" ",1,STR0004,,STR0003,1,0)//"J� existe um cadastro com mesmo c�digo da base de c�lculo, per�odo de ingresso no regime N�o Cumulativo, CST de PIS/COFINS, al�quota de PIS/COFINS e Conta cont�bil, verifique cadastro."
				lRet := .F. 
		EndIF
	End 
	If nOperation == 4 //.or. nOperation == 4  //Inclus�o de informa��es ou altera��es.		
		CF9->(DbSetOrder (1))
		If CF9->(DbSeek(xFilial("CF9")+cCodBcc+dTos(dPerIng)+cCstPis+Str(nAlqPis,8,4)+cCstCof+str(nAlqCof,8,4)+cConta))
			nRecno2:=CF9->(Recno())
			if nRecno2 <> nRecno
				Help(" ",1,STR0004,,STR0003,1,0)//"J� existe um cadastro com mesmo c�digo da base de c�lculo, per�odo de ingresso no regime N�o Cumulativo, CST de PIS/COFINS, al�quota de PIS/COFINS e Conta cont�bil, verifique cadastro."
				lRet := .F. 
			endif	
		EndIF
	End 

Return lRet 