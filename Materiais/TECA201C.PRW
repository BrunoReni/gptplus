#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "TECA201C.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TECA201C  �Autor  �Microsiga           � Data �  03/25/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atendentes X Equipes                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP     	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function TECA201C  

Local oBrowse	:= Nil     

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AA1')
oBrowse:SetDescription(STR0001) //'Atendentes X Equipes'
oBrowse:Activate()

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Microsiga           � Data �  03/25/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de Dados de Equipes X Atendentes                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201C                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()   
 
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel    := Nil														   		// Objeto que contem o modelo de dados.
Local oStruAA1 	:= FWFormStruct(1,'AA1',/*bAvalCampo*/,/*lViewUsado*/)				// Objeto que contem a estrutura do cabecalho de vistoria.
Local oStruAAY 	:= FWFormStruct(1,'AAY',/*bAvalCampo*/,/*lViewUsado*/)				// Objeto que contem a estrutura de produtos.
Local aEstrut	:= {} 												   				// Array que contem as estruturas.
Local aAux		:= {}
Local bCommit   := {|oModel| At201CCmt(oModel)}    									// Bloco de commit.
Local bLinePos  := {|oModel| At201VlLin() }

//������������������������������������������Ŀ
//� Adiciona as Estruturas no Array aEstrut. �
//��������������������������������������������
aAdd(aEstrut,oStruAA1)
aAdd(aEstrut,oStruAAY)

//�����������������������������������������������Ŀ
//� Instancia o modelo de dados Vistoria Tecnica. �
//�������������������������������������������������
oModel := MPFormModel():New('TECA201C',/*bPreValidacao*/,/*bPosValid*/,bCommit,/*bCancel*/)   

aAux := FwStruTrigger(;
'AAY_CODEQU'  ,;
'AAY_NOMEQU'  ,;
'AAX->AAX_NOME'  ,;
.T.,;
'AAX',;
1,;
'xFilial("AAX")+M->AAY_CODEQU')
oStruAAY:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oStruAA1:SetProperty('AA1_CODTEC',MODEL_FIELD_WHEN,.F.)  
oStruAA1:SetProperty('AA1_EMINFI',MODEL_FIELD_OBRIGAT,.F.)  
oStruAA1:SetProperty('AA1_FUNPRO',MODEL_FIELD_OBRIGAT,.F.) 
oStruAA1:SetProperty('AA1_LIBOSV',MODEL_FIELD_OBRIGAT,.F.)
oStruAA1:SetProperty('AA1_REQPEC',MODEL_FIELD_OBRIGAT,.F.) 
oStruAA1:SetProperty('AA1_CODVEN',MODEL_FIELD_OBRIGAT,.F.)  
oStruAA1:SetProperty('AA1_NOMUSU',MODEL_FIELD_OBRIGAT,.F.) 
//����������������������������������������Ŀ
//� Adiciona os campos no modelo de dados. �
//������������������������������������������
oModel:AddFields('AA1MASTER',/*cOwner*/,oStruAA1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/ )
oModel:AddGrid('AAYDETAIL','AA1MASTER',oStruAAY,/*bLinePre*/,bLinePos,/*bPreVal*/,/*bPosVal*/)

//�����������������������������Ŀ
//� Montagem do relacionamento. �
//�������������������������������
oModel:SetRelation('AAYDETAIL',{{'AAY_FILIAL','xFilial("AAY")'},{'AAY_CODTEC','AA1_CODTEC'}},AAY->( IndexKey(2)))

oModel:GetModel('AA1MASTER'):SetOnlyView(.T.)
oModel:GetModel('AA1MASTER'):SetOnlyQuery(.T.) 
oModel:GetModel('AAYDETAIL'):SetUniqueLine({'AAY_CODEQU'}) // N�o permite repetir o c�digo do atendente

//���������������������������������������Ŀ
// Adiciona a descricao do Modelo de Dados| 
//�����������������������������������������
oModel:SetDescription(STR0001)	//"Equipes X Atendentes"



Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Microsiga           � Data �  03/25/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface do cadastro de Equipes X Atendentes               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201C                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
            
Local oModel	:= FWLoadModel( 'TECA201C' ) // Objeto que contem o modelo de dados
Local oStruAA1 	:= FWFormStruct( 2, 'AA1' )  // Objeto que contem a estrutura de Equipes
Local oStruAAY 	:= FWFormStruct( 2, 'AAY' )  // Objeto que contem a estrutura de Equipes X Atendentes
Local aEstrut	:= {}     					 // Array que contem as estruturas.
Local oView		:= Nil 

aAdd(aEstrut,oStruAA1)
aAdd(aEstrut,oStruAAY)

oStruAAY:RemoveField("AAY_CODTEC") //Remove o campo para n�o ser visualizado pelo usuario.
oStruAAY:RemoveField("AAY_NOMTEC")
oStruAA1:RemoveField("AA1_EMINFI")
oStruAA1:RemoveField("AA1_FUNPRO") 

// Instancia a interface
oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField('VIEW_AA1',oStruAA1,'AA1MASTER')	//Adiciona os campos no cabecalho. 

oView:AddGrid('VIEW_AAY',oStruAAY,'AAYDETAIL')	//Adiciona os campos no grid. 

oView:CreateHorizontalBox( 'Atend' ,40 ) // Atendentes
oView:CreateHorizontalBox( 'Equip' ,60 ) // Atendentes X Equipes

oView:SetOwnerView( 'VIEW_AA1', 'Atend' )
oView:SetOwnerView( 'VIEW_AAY', 'Equip' )

Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Microsiga           � Data �  03/25/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria��o do MenuDef                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201C                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TECA201C' OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA201C' OPERATION 4 ACCESS 0  //'Alterar'

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �At201bCmt �Autor  �Microsiga           � Data �  03/25/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco de Commit                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �TECA201C                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function At201CCmt(oModel)

	FWModelActive(oModel)
	FWFormCommit(oModel,NIL,NIL,NIL)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �At201VlLin�Autor  �Microsiga           � Data �  05/22/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o da linha                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � TECA201C	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function At201VlLin()
Local aArea		:= GetArea()  
Local cTpGp		:= "" 
Local cTpGpVal	:= "" 
Local lRet		:= .T. 
Local nPoslin	:= 0  
Local oModel	:= FWModelActive()      
Local oMdlAAY	:= oModel:GetModel("AAYDETAIL")

//Pega a ultima linha
nPoslin := oMdlAAY:Length()

If nPoslin > 1
	
	DbSelectArea("AAX")
	DbSetOrder(1)
	
	//Pega o Valor da primeira linha
	If AAX->(DbSeek(xFilial("AAX")+oMdlAAY:GetValue("AAY_CODEQU",1)))
		cTpGp := AAX->AAX_TPGRUP
	EndIf               
		               
	If AAX->(DbSeek(xFilial("AAX")+oMdlAAY:GetValue("AAY_CODEQU",nPosLin)))
		cTpGpVal := AAX->AAX_TPGRUP
	EndIf
		
	If cTpGpVal <> cTpGp
		lRet := .F.	
	   	Help("",1,"At201VlLin",,STR0004+IIF(cTpGpVal=="1",STR0005,STR0006),2,0) //"Tipo de grupo da equipe � diferente de "#"reserva"#"apoio"
	EndIf 
EndIf         
	
RestArea(aArea)

Return lRet