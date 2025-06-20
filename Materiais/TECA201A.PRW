#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"  
#Include "TECA201A.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADEQU	�Autor  �			         � Data �  03/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro da tabela AAX - Equipes.			                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TECA201A()

Local oBrowse     

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AAX')
oBrowse:SetDescription(STR0001) //'Cadastro de Equipes'
oBrowse:Activate()

Return Nil  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �			         � Data �  03/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Criacao do MenuDef.	  	                        		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Opcoes de menu    		                                  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201A                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TECA201A' OPERATION 1 ACCESS 0  //'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA201A' OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TECA201A' OPERATION 3 ACCESS 0  //'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TECA201A' OPERATION 4 ACCESS 0  //'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TECA201A' OPERATION 5 ACCESS 0  //'Excluir'

Return aRotina
              
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �			         � Data �  03/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de Dados da equipe.		  						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Modelo de Dados		                                      ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201A	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruAAX := FWFormStruct( 1, 'AAX', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
 
// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CADEQU', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'AAXMASTER', /*cOwner*/, oStruAAX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0007) //'Modelo de Dados de Equipes'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'AAXMASTER' ):SetDescription(STR0008) //'Dados da Equipe'   

// Valida��o de exclusao da ativa��o do modelo
oModel:SetVldActivate({|oModel| AT201AEX(oModel)})

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �			         � Data �  03/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface Tipo de visita.        							  ���
�������������������������������������������������������������������������͹��
���Retorno   �Interface                            			              ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum					                      			  ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201A                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef() 

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'TECA201A' )
// Cria a estrutura a ser usada na View
Local oStruAAX := FWFormStruct( 2, 'AAX' )
Local oView  

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_AAX', oStruAAX, 'AAXMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_AAX', 'TELA' )

Return oView                 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AT201AEX  �Autor  �Microsiga           � Data �  03/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impedir de excluir equipes dependentes                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201A                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AT201AEX(oModel)
                
Local aAreaAAX 	:= AAX->(GetArea())
Local lRet		:= .T.
Local cAtend	:= AAX->AAX_CODEQU
                      
If oModel:GetOperation() == MODEL_OPERATION_DELETE

	DbSelectArea("AAY") // Tabela de Equipes X Atendentes                                
	AAY->(DbSetOrder(1))		//AAY_FILIAL+AAY_CODEQU

	If AAY->(DbSeek(xFilial("AAY")+cAtend))
		lRet	:= .F. 
		Help("",1,"AT201AEX",,STR0009,2,0) //"N�o � possivel excluir esta equipe"
	EndIf                         
EndIf
       
RestArea(aAreaAAX)

Return lRet