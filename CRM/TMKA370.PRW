#Include "TMKA370.CH"
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA370   � Autor � Vendas CRM		    � Data � 26/10/10   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de atualizacao de Codigos DDI                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TmkA370(void)                                            ���
���������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                       ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function TmkA370()
Local oBrowse	:= Nil

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ACJ')
oBrowse:SetDescription(STR0008) //"Atualiza��o de Codigos DDI
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
���Uso       �TmkA370                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruACJ := FWFormStruct(1,'ACJ',/*bAvalCampo*/,/*lViewUsado*/)
Local bPosValidacao		:= {|oMdl|TMKA370Pos(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('TMKA370',/*bPreValidacao*/,bPosValidacao,/*bCommit*/,/*bCancel*/)
oModel:AddFields('ACJMASTER',/*cOwner*/,oStruACJ,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({'ACJ_FILIAL','ACJ_DDI'})
oModel:SetDescription(STR0008)

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
���Uso       �TmkA370                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA370')
Local oStruACJ := FWFormStruct(2,'ACJ')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ACJ', oStruACJ,'ACJMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_ACJ','TELA')

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
���Uso       �TmkA370                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA370'	OPERATION 2	ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA370'	OPERATION 3	ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA370'	OPERATION 4	ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.TMKA370'	OPERATION 5	ACCESS 0


Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TmkA370Pos�Autor  �Vendas CRM          � Data �  26/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pos validacao do browse MVC, executada antes da gravacao,   ���
���          �permitindo validar o formulario.                            ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA370                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function TmkA370Pos(oMdl)

Local lRet := .T.
Local nOperation := oMdl:GetOperation()

if nOperation == 5   

	//�������������������������������������Ŀ
	//�Valida se o codigo pode ser excluido.�
	//���������������������������������������
	If !TK370Valid(oMdl)
		lRet := .F.
		Return(lRet)
	Endif
	
EndIf

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TK370Valid� Autor � Vendas CRM			� Data � 26/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de validacao da exclusao de Codigos DDI.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TmkA370                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TK370Valid(oMdl)
Local oMdlACJ := oMdl:GetModel('ACJMASTER')
Local nIndex	:= 0
Local cIndex1   := ""
Local cKey		:= "U5_FILIAL+U5_CODPAIS"
Local cFiltro	:= ""
Local lRet      := .T.

//��������������������������������������������������������������������������Ŀ
//� Cria Indice Condicional para a sele��o dos contatos no arq. de TeleMkt.  �
//����������������������������������������������������������������������������
cIndex1 := CriaTrab(Nil,.F.)
DbSelectArea("SU5")
DbSetOrder(1)
IndRegua("SU5",cIndex1,cKey,,cFiltro,OemToAnsi(STR0010)) //"Analisando os contatos..."

DbSelectArea("SU5")
nIndex := RetIndex("SU5")


DbSetOrder(nIndex+1)
If DbSeek(xFilial("SU5") + oMdlACJ:GetValue("ACJ_DDI"))
	Help(" ",1,"GRAVADO")
	lRet := .F.
EndIf

//������������������������������������������������������������Ŀ
//� Deleta Arquivo Temporario e Restaura os Indices Ativos     �
//��������������������������������������������������������������
DbSelectArea("SU5")
DbSetOrder(1)
If File(cIndex1 + OrDbagExt())
	FErase(cIndex1 + OrDbagExt())
EndIf

Return(lRet)



