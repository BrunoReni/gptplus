#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA540.CH"  
#INCLUDE 'FWMVCDEF.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA540   �Autor  �Vendas Clientes     � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Unidades de funcao (componentes)                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fata540()

Local oBrowse   := Nil  

PRIVATE cCadastro := STR0002   
Private aRotina := MenuDef()

SX2->(DbSetOrder(1))

If !SX2->(DbSeek("ADR"))
	MsgStop(STR0001) //"Execute o update U_TKUPDADM antes de acessar esta rotina"
	Return Nil
EndIf

dbSelectArea("ADR")
dbSetOrder(1)

OBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADR')
oBrowse:SetDescription(STR0002) //"Cadastro de Componentes" 
oBrowse:Activate()

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados EM MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruADR := FWFormStruct(1,'ADR', /*bAvalCampo*/,/*lViewUsado*/ )

Local bPosValidacao	:= {|oMdl| Ft540Pos(oMdl)}

oModel := MPFormModel():New('FATA540', /*bPreValidacao*/,bPosValidacao,/*bCommit*/,/*bCancel*/ )
oModel:AddFields('ADRMASTER',/*cOwner*/,oStruADR, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0002)

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de Componentes em MVC.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()   

Local oView  
Local oModel   := FWLoadModel('FATA540')
Local oStruADR := FWFormStruct( 2,'ADR')  
   

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ADR',oStruADR,'ADRMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ADR','TELA') 
  
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
���Uso       � FATA540                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 

Local aRotina := {}


ADD OPTION aRotina TITLE STR0005 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FATA540'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FATA540'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FATA540'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.FATA540'	OPERATION 5	ACCESS 0

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft540Pos  �Autor  �Vendas CRM          � Data �  10/08/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �No momento da gravacao, faz a validacao. 					  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ft540Pos(oMdl)

Local nOperation	:= oMdl:GetOperation()
Local lRet	:= .T.
  
If nOperation == MODEL_OPERATION_DELETE
     lRet := Ft540Del()        
EndIf

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft540Del  �Autor  �Microsiga           � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft540Del()

Local aArea	:= GetArea()
Local lRet	:= .T.

DbSelectArea("ADT")
DbSetOrder(2) //ADT_FILIAL+ADT_CODCMP+ADT_CODTAR

If DbSeek(xFilial("ADT")+ADR->ADR_CODIGO)
	Help( ,, 'HELP',, STR0003, 1, 0)   //"Este registro encontra-se vinculado ao cadastro de Componentes x Tp. Tarefa, favor verificar."
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet