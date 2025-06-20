#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA520O.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMKA520O  � Autor � Vendas CRM		    � Data � 26/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para atualizacao do cadastro de Processos,         ���
���			 |CRM x Acao.            							          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TMKA520O (void)                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKA520O()
Local oBrowse	:= Nil

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADW')
oBrowse:SetDescription(STR0001) //Cadastro de Processos CRM x Acao
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
���Uso       �TMKA520O                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruADW := FWFormStruct(1,'ADW',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('TMKA520O',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields('ADWMASTER',/*cOwner*/,oStruADW,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
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
���Uso       �TMKA520O                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA520O')
Local oStruADW := FWFormStruct(2,'ADW')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ADW', oStruADW,'ADWMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ADW','TELA')

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
���Uso       �TMKA520O                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA520O'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA520O'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA520O'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA520O'	OPERATION 5	ACCESS 0


Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExecCRMPro�Autor  �Vendas Clientes     � Data �  18/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Executa um processo de CRM.                             	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
Function ExecCRMPro(cCodProcesso)
Local aArea := GetArea()
Local lRet := .F.

DbSelectArea("ADW")
DbSetOrder(2)
If DbSeek(xFilial("ADW")+cCodProcesso)
	lRet := .T.
	Eval(&("{||" + ADW->ADW_FORMUL + "}"), "")
EndIf

RestArea(aArea)
Return lRet    