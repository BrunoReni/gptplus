#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH' 
#INCLUDE "FATA580.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA580   �Autor  �Vendas CRM          � Data �  30/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Itens de complexidade                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA580                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FATA580()

Local oBrowse 
Private cCadastro := STR0001 // "Itens de complexidade"
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ADR') 
oBrowse:AddLegend( "ADU->(DbSeek(ADR->(ADR_FILIAL+ADR_CODIGO)))" , "BR_VERDE"		, STR0003  )
oBrowse:AddLegend( "!ADU->(DbSeek(ADR->(ADR_FILIAL+ADR_CODIGO)))" , "BR_PRETO"  	, STR0004 )
oBrowse:SetDescription(STR0001)

oBrowse:Activate()

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor �     Vendas CRM        � Data �08/12/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0005    ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.FATA580' OPERATION 2 ACCESS 0 // "Visualizar" 
ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.FATA580' OPERATION 4 ACCESS 0 // "Configurar"
ADD OPTION aRotina TITLE STR0008    ACTION 'VIEWDEF.FATA580' OPERATION 5 ACCESS 0 //"Exc.Config."
ADD OPTION aRotina TITLE STR0009    ACTION 'Ft580Leg' 	 	 OPERATION 9 ACCESS 0 //"Legenda"


Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �FATA580                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
Local oStruADR := FWFormStruct(1,'ADR',,)
Local oStruADU := FWFormStruct(1,'ADU', /*bAvalCampo*/, /*lViewUsado*/)
Local oModel 
Local bCommit		:= {|oMdl|FATA580Cmt(oMdl)}		//Gravacao dos dados

oModel := MPFormModel():New('FATA580', /*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/ )
oModel:AddFields( 'ADRPAI', /*cOwner*/, oStruADR, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)                                                  
oModel:AddGrid( 'ADUDETAIL','ADRPAI',oStruADU, /*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation( 'ADUDETAIL', { { 'ADU_FILIAL', 'xFilial( "ADU" ) ' } , { 'ADU_CODCMP', 'ADR_CODIGO' } } , 'ADU_FILIAL + ADU_CODCMP' )
oModel:SetDescription(STR0001)
oModel:GetModel('ADRPAI'):SetOnlyView() 

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  17/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �FATA580                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
Local oModel   := FWLoadModel( 'FATA580' )
Local oStruADR := FWFormStruct( 2, 'ADR' )
Local oStruADU := FWFormStruct( 2, 'ADU' )
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )


oView:AddField( 'VIEW_ADR', oStruADR, 'ADRPAI')
oView:AddGrid('VIEW_ADU', oStruADU, 'ADUDETAIL') 
oView:AddIncrementField('VIEW_ADU','ADU_ITEM')                                              
oView:CreateHorizontalBox('SUPERIOR', 50 )
oView:CreateHorizontalBox('INFERIOR', 50 )
oView:SetOwnerView( 'VIEW_ADR','SUPERIOR' )
oView:SetOwnerView( 'VIEW_ADU','INFERIOR' )

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATA580Cmt�Autor  �Vendas CRM          � Data �  21/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario, substi-���
���          �tuindo a gravacao padrao do MVC.                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA580                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FATA580Cmt(oMdl) 

Local aArea			:= Getarea()
Local nOperation	:= oMdl:GetOperation()
Local bAfter		:= {|oMdl,cId,cAlias,lNewRec|Fata580Memo(oMdl,cId,cAlias,lNewRec,nOperation)}
Local aRecnos		:= {}
Local cFilADU		:= xFilial("ADU")
Local nX			:= 0

If nOperation == 4 .Or. nOperation == 3

	FWModelActive(oMdl) 
	FWFormCommit(oMdl,,bAfter)

ElseIf nOperation == 5

	aRecnos := {}
	
	DbSelectArea("ADU")
	DbSetOrder(1)
	DbSeek(cFilADU + oMdl:GetValue('ADRPAI','ADR_CODIGO') )
	
	//������������������������������������Ŀ
	//�Armazena os recnos a serem deletados�
	//��������������������������������������
	While !ADU->(Eof()) .AND.;
		ADU->ADU_FILIAL == cFilADU .AND.;
		ADU->ADU_CODCMP == oMdl:GetValue('ADRPAI','ADR_CODIGO')
		
		AAdd(aRecnos,ADU->(Recno()))
		
		ADU->(DbSkip())			
	End
	
	//���������������������������Ŀ
	//�Deleta os registros na base�
	//�����������������������������
	For nX := 1 to Len(aRecnos)
		ADU->(DbGoTo(aRecnos[nX]))
		If !Empty(ADU->ADU_CODMEM)
			MSMM(ADU->ADU_CODMEM,,,,2)
		EndIf
		RecLock("ADU",.F.)
		DbDelete()
		MsUnLock()
	Next nX

EndIf
        
RestArea(aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ft580Leg  �Autor  �Vendas CRM          � Data �  22/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda da rotina                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �FATA580                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ft580Leg()

Local aLegenda := {	{"BR_VERDE"		, STR0003	},;	//"Configurado"
					{"BR_PRETO"  	, STR0004	}}	// "Nao configurado"

BrwLegenda(cCadastro,STR0002,aLegenda) // "Status do item"  

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Fata580Memo� Autor � Vendas CRM           � Data � 22/10/2010 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Tratamento do campo observacao(Memo) na SYP.                 ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FATA580                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Fata580Memo(oMdl,cId,cAlias,lNewRec,nOperation)  

Local nX   		:=  0
Local cMemo		:= "" 
  
If cId == "ADUDETAIL"
	
	nX 		:= oMdl:GetLine()	
	
	If nOperation == 4 .Or. nOperation == 3
			
		cMemo	:= oMdl:GetValue('ADU_MEMO'	,nX)    
	
		If !Empty(cMemo)
	   		MSMM(ADU->ADU_CODMEM,,,cMemo,1,,,"ADU","ADU_CODMEM")
		ElseIf Empty(cMemo) .AND. !Empty(ADU->ADU_CODMEM)
			MSMM(ADU->ADU_CODMEM,,,,2)
		EndIf

	ElseIf nOperation == 5
	
		If !Empty(ADU->ADU_CODMEM)
			MSMM(ADU->ADU_CODMEM,,,,2)
		EndIf
			
	EndIf	

EndIf   

Return(.T.)