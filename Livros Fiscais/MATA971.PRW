#INCLUDE "MATA971.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA971   �Autor  �Mary C. Hergert     � Data �  11/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro das classes de consumo de energia eletrica, gas,   ���
���          �e agua.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA971()

Local oBrowse

ChkFile("CC5")

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CC5')
oBrowse:SetDescription(STR0001)
oBrowse:DisableDetails()
oBrowse:Activate()


Return .T.

//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
ADD OPTION aRotina Title "Pesquisar" Action 'PesqBrw'          OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.MATA971'  OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title "Incluir" Action 'VIEWDEF.MATA971'  OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title "Alterar" Action 'VIEWDEF.MATA971'  OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title "Excluir" Action 'VIEWDEF.MATA971'  OPERATION 5 ACCESS 0 //Excluir

Return aRotina

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef  � Autor �Erich Buttner   � Data � 18/06/18 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Modelod de dados                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIS                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local oStruCC5

oStruCC5 := FWFormStruct( 1, "CC5")

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('MATA971', /*bPreValidacao*/, {|oModel| MT971VlMd(oModel)},  /*bCommit*/, /*bCancel*/ )

oStruCC5:SetProperty('CC5_DTINIC', MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })
oStruCC5:SetProperty('CC5_DTFINA', MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })

// Adiciona ao modelo uma estrutura de formul?rio de edi??o por campo
oModel:AddFields( 'CC5MASTER', /* cOwner */, oStruCC5)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription(STR0001)
oModel:GetModel( 'CC5MASTER' ):SetDescription( STR0001 )

Return oModel

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef  � Autor �Autor �Erich Buttner   � Data � 18/06/18 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Modelod de Tela                                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAATF                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'MATA971' )
Local oStruCC5 := FWFormStruct( 2, 'CC5')

Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_CC5",oStruCC5,"CC5MASTER")

Return oView

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AF005VlMd  � Autor �Erich Buttner   � Data � 18/06/18 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida��o do Modelo de dados                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAATF                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MT971VlMd(oModel)

Local lRet   := .T.
Local cCod   := oModel:GetValue('CC5MASTER',"CC5_CODIGO")
Local cTp    := oModel:GetValue('CC5MASTER',"CC5_TIPO")
Local dDtIni := oModel:GetValue('CC5MASTER',"CC5_DTINIC")
Local dDtFim := oModel:GetValue('CC5MASTER',"CC5_DTFINA")
Local nOper  := oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT   

	If ((Empty(dDtIni) .and. !Empty(dDtFim)) .or. (Empty(dDtFim) .and. !Empty(dDtIni)))
		Help(" ", 1, "DTOBRIG")
		Return .F.
	EndIf

	If dDtIni > dDtFim
		Help(" ", 1, "DTVALID")
		Return .F. 
	EndIf

	If CC5->(dbSeek(xFilial("CC5")+cTp+cCod+DTOS(dDtIni)+DTOS(dDtFim)))	
		Help(" ", 1, "JAGRAVADO")
		Return .F.
	EndIf
	
EndIf

Return lRet
