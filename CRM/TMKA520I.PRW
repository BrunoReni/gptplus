#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA520I.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE WFTYPE_INFORMATION 		1               
#DEFINE WFTYPE_AUTHORIZATION 	2

 
 
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA510I  � Autor � Vendas CRM		    � Data � 17/01/11  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Mantem o legado para funcoes e menus que chamam a rotina,    ���
���			 �TmkA510I.							          				   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �TmkA510I                                    				   ���
��������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                      ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/                         
Function TmkA510I()

//����������������������������Ŀ                                                      
//� Modelos de Workflow em MVC �                               
//������������������������������
	TmkA520I()
	
Return(.T.)                                       


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA520I  � Autor � Vendas CRM		    � Data � 26/10/10   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelos de Workflow em MVC. 									���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TmkA520I(void)                                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                       ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/                                
Function TmkA520I()
Local oBrowse	:= Nil
                                                                        
//���������������Ŀ                                                      
//� Cria o Browse �                               
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetMenuDef('TmkA520I')
oBrowse:SetAlias('SKY')
oBrowse:SetDescription(STR0001) //Modelos de Workflow
oBrowse:Activate()

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  � Autor � Vendas CRM         � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA520I                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruSKY 	:= FWFormStruct(1,'SKY',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruAGZ 	:= FWFormStruct(1,'AGZ') //detalhes do cadastro (usuarios associados)
Local aAux1 		:= {}
Local aAux2		:= {}

oModel := MPFormModel():New('TMKA520I',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('SKYMASTER',/*cOwner*/,oStruSKY,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid('AGZDETAIL','SKYMASTER',oStruAGZ) // cria o grid pro detalhe
oModel:SetRelation('AGZDETAIL',{  {'AGZ_FILIAL', 'xFilial("AGZ")'} , {'AGZ_TEMPWF', 'KY_CODIGO'}} , 'AGZ_FILIAL+AGZ_TEMPWF' ) //cria relacionamento entre mestre-detalhe atraves do campo Filial + Codigo do template

oModel:GetModel('AGZDETAIL'):SetUniqueLine({'AGZ_CODUSU'})

oModel:SetDescription(STR0001)

Return(oModel)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   � Autor � Vendas CRM         � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA520I                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA520I')
Local oStruSKY := FWFormStruct(2,'SKY')
Local oStruAGZ := FWFormStruct(2,'AGZ')  //detalhes do cadastro (usuarios associados)

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SKY', oStruSKY,'SKYMASTER')
oView:AddGrid('VIEW_AGZ',oStruAGZ, 'AGZDETAIL') // cria o grid pro detalhe

oView:CreateHorizontalBox('TELA',70)
oView:CreateHorizontalBox('GRID',30) // cria um container na tela

oView:SetOwnerView('VIEW_SKY','TELA')
oView:SetOwnerView('VIEW_AGZ','GRID')  // define que o grid fica dentro do container 'GRID'



Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 26/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TmkA520I                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA520I'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA520I'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA520I'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA520I'	OPERATION 5	ACCESS 0


Return(aRotina)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RunWFTemplate�Autor�Vendas Clientes    � Data �  18/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Executa o template selecionado.                         	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/        
Function RunWFTemplate(cCodTemplate)
Local oWFTemplate	:= Nil
Local aWFs			:= {}
Local lRet 			:= .F.                  
Local cCodUser 		:= RetCodUsr()
Local nCount		:= 0

oWFTemplate := WFTemplate():New()
lRet := oWFTemplate:load(cCodTemplate)
If lRet
	aWFs := oWFTemplate:buildWF(cCodUser)
	For nCount := 1 To Len( aWFs )
		aWFs[nCount]:start()
		aWFs[nCount]:save()
	Next
EndIf
Return lRet

/*/{Protheus.doc} TK520IVld()
Fun��o utilizada para valida��o do tipo de modelo WF, atrav�s do campo KY_TPWF.

@author 	SQUAD CRM & FAT
@since 		12/11/2018
@version 	1.0
/*/
Function TK520IVld()

Local lRet   := .T.
Local oModel := FWModelActive()

If FwFldGet("KY_TPWF") == "2" .And. FwFldGet("KY_AUTHSRV") $ "2 "
	oModel:LoadValue('SKYMASTER',"KY_AUTHSRV","1")
EndIf

Return lRet