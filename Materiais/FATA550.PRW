#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FATA550.CH" 
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA550   �Autor  �Vendas Clientes     � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Tipos de Tarefa                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fata550()

If !SX2->(DbSeek("ADS"))
	MsgStop(STR0001) //"Execute o update U_TKUPDADM antes de acessar esta rotina"
	Return Nil
EndIf

dbSelectArea("ADS")
dbSetOrder(1)

OBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADS')
oBrowse:SetDescription(STR0002) //"Cadastro de Tipo de Tarefa"
oBrowse:Activate()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados em MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruADS := FWFormStruct(1,'ADS', /*bAvalCampo*/,/*lViewUsado*/ )

Local bPosValidacao	:= {|oMdl|Ft550Pos(oMdl)}	

oModel := MPFormModel():New('FATA550', /*bPreValidacao*/,bPosValidacao,/*bCommit*/,/*bCancel*/ )
oModel:AddFields('ADSMASTER',/*cOwner*/,oStruADS, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0002)

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de Tipos de tarefas em     ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �FATA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('FATA550')
Local oStruADS := FWFormStruct( 2,'ADS')  
   

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ADS',oStruADS,'ADSMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ADS','TELA') 
  
Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Fernando Amorim       � Data �08/12/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � FATA550                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}


ADD OPTION aRotina TITLE STR0005 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA550'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FATA550'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FATA550'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FATA550'	OPERATION 5	ACCESS 0

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft550Pos  �Autor  �Vendas CRM          � Data �  21/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario, substi-���
���          �tuindo a gravacao padrao do MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft550Pos(oMdl)

Local nOperation	:= oMdl:GetOperation()
Local lRet          := .T.

If nOperation  == MODEL_OPERATION_DELETE
	lRet := Ft550Del()()
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft550Del  �Autor  �Microsiga           � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft550Del()

Local aArea	:= GetArea()
Local lRet	:= .T.

DbSelectArea("ADT")
DbSetOrder(1) //ADT_FILIAL+ADT_CODTAR+ADT_CODCMP

If DbSeek(xFilial("ADT")+ADS->ADS_CODIGO)
	Help( ,, 'HELP',, STR0003, 1, 0)   //"Este registro encontra-se vinculado ao cadastro de Componentes x Tp. Tarefa, favor verificar."
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet