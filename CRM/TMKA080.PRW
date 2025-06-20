#INCLUDE "Protheus.ch"
#INCLUDE "TMKA080.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA080   � Autor � Vendas CRM		    � Data � 26/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de cadastro de status dos operadores               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TmkA080(void)                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TmkA080()
Local oBrowse	:= Nil   

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AGE')
oBrowse:SetDescription(STR0001) //"Cadastro de Status dos Operadores"
oBrowse:Activate()

Return(.T.)   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruAGE := FWFormStruct(1,'AGE',/*bAvalCampo*/,/*lViewUsado*/)     

oModel := MPFormModel():New('TMKA080',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('AGEMASTER',/*cOwner*/,oStruAGE,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription(STR0001)

Return(oModel)                      
                                     

                                                                          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA080                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('TMKA080')
Local oStruAGE := FWFormStruct(2,'AGE')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AGE', oStruAGE,'AGEMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_AGE','TELA') 

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
���Uso       �TmkA080                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA080'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA080'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA080'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA080'	OPERATION 5	ACCESS 0


Return(aRotina) 