#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA330.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TmkA330   � Autor � Vendas CRM		    � Data � 08/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Metas                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TmkA330(void)                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                     ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TmkA330( cFilDef, aAddFil )

Local oBrowse		:= Nil
Local oTableAtt 	:= TableAttDef()
Local nX        := 0

Private aRotina := MenuDef()

Default cFilDef := ""
Default aAddFil := {}

//���������������Ŀ
//� Cria o Browse �
//�����������������
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AC6')
oBrowse:SetDescription(STR0001) //"Atualizacao de Metas"

//�����������������������������������������������������Ŀ
//� Filtro Default do Browse                           �
//������������������������������������������������������
If !Empty( cFilDef )
	oBrowse:SetFilterDefault( cFilDef )
EndIf
	
//���������������������������������������������������������Ŀ
//� Filtros adicionais do Browse                           �
//����������������������������������������������������������
For nX := 1 To Len( aAddFil )
	oBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
	oBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO], ;
					      aAddFil[nX][ADDFIL_EXPR], ;
					      aAddFil[nX][ADDFIL_NOCHECK], ;
					      aAddFil[nX][ADDFIL_SELECTED], ; 
					      aAddFil[nX][ADDFIL_ALIAS], ;
					      aAddFil[nX][ADDFIL_FILASK], ;
					      aAddFil[nX][ADDFIL_FILPARSER], ;
					      aAddFil[nX][ADDFIL_ID] )		 
	oBrowse:ExecuteFilter()	
Next nX		
	
oBrowse:SetAttach( .T. )
oBrowse:SetViewsDefault( oTableAtt:aViews )
oBrowse:SetTotalDefault('AC6_META','COUNT',STR0020) //'Total de Registros'

// se for diferente do modulo CRM, ent�o abre o browse com o grafico fechado
If nModulo <> 73
	oBrowse:SetOpenChart( .F. )
EndIf

oBrowse:Activate()

Return(.T.)


//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as vis�es e gr�ficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gr�ficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oAtivos		:= Nil // Metas de Campanha Ativas
Local oInativos	:= Nil // Metas de Campanha Inativas
Local oTableAtt 	:= FWTableAtt():New()

oTableAtt:SetAlias("AC6")

// Metas de Campanha Ativas 
oAtivos := FWDSView():New()
oAtivos:SetName(STR0018) //"Metas de Campanha Ativas"
oAtivos:SetID("Ativos") 
oAtivos:SetOrder(1) // AC6_FILIAL+AC6_META
oAtivos:SetCollumns({"AC6_META","AC6_TITULO","AC6_DTINI","AC6_DTFIM","AC6_TOTFAT"})
oAtivos:SetPublic( .T. )
oAtivos:AddFilter(STR0018, "AC6_MSBLQL == '2'") //"Metas de Campanha Ativas"

oTableAtt:AddView(oAtivos)

// Metas de Campanha Inativas
oInativos := FWDSView():New()
oInativos:SetName(STR0019) //"Metas de Campanha Inativas"
oInativos:SetID("Inativos") 
oInativos:SetOrder(1) // AO0_FILIAL+AO0_CODESPAC6_FILIAL+AC6_META
oInativos:SetCollumns({"AC6_META","AC6_TITULO","AC6_DTINI","AC6_DTFIM","AC6_TOTFAT"})
oInativos:SetPublic( .T. )
oInativos:AddFilter(STR0019, "AC6_MSBLQL == '1'") //"Metas de Campanha Inativas"

oTableAtt:AddView(oInativos)

Return (oTableAtt)	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  � Autor � Vendas CRM         � Data �  08/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados do grupo de atendimento (MVC)      ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA330                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oModel
Local oStruAC6 := FWFormStruct(1,'AC6', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruAC7 := FWFormStruct(1,'AC7', /*bAvalCampo*/, /*lViewUsado*/)

Local bCommit 		:= { |oMdl| Tk330Cmm( oMdl ) }		// Efetua a  validacao
Local bPosValidacao := {|oMdl|TmkA330Pos(oMdl)}		//Validacao da tela    
Local bLinePost 	:= {|oMdl|TmkA330LPos()} //Valida mudanca de linha                          

oModel := MPFormModel():New( 'TMKA330', /*bPreValidacao*/, bPosValidacao, bCommit, /*bCancel*/ )
oModel:AddFields('AC6MASTER',/*cOwner*/,oStruAC6, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'AC7DETAIL','AC6MASTER',oStruAC7,/*bLinePre*/,bLinePost,/*bPreVal*/,/*bPosVal*/)
oModel:SetRelation( 'AC7DETAIL',{{'AC7_FILIAL','xFilial("AC7")'},{'AC7_META','AC6_META'}} ,'AC7_FILIAL+AC7_META+AC7_CODCAM')
oModel:GetModel('AC7DETAIL'):SetUniqueLine({'AC7_CODCAM'})

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
AO4GdModel("AC6MASTER", oModel, "AC6" )

oModel:SetDescription(STR0001)

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   � Autor � Vendas CRM         � Data �  08/11/10   ���                                        
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de grupo de atendimento em ���
���          �MVC.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA330                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA330')
Local oStruAC6 := FWFormStruct(2,'AC6')
Local oStruAC7 := FWFormStruct(2,'AC7')


oStruAC7:RemoveField("AC7_META")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_AC6', oStruAC6, 'AC6MASTER' )
oView:AddGrid( 'VIEW_AC7', oStruAC7, 'AC7DETAIL' )
oView:CreateHorizontalBox('SUPERIOR', 50 )
oView:CreateHorizontalBox('INFERIOR', 50 )
oView:SetOwnerView( 'VIEW_AC6','SUPERIOR' )
oView:SetOwnerView( 'VIEW_AC7','INFERIOR' )

Return(oView)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor � Vendas CRM            � Data � 08/11/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRotina   retorna a array com lista de aRotina              ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TmkA330                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0	// "Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA330'	OPERATION 2	ACCESS 0	// "Visualizar"  
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA330'	OPERATION 3	ACCESS 0	// "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA330'	OPERATION 4	ACCESS 0	// "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMKA330'	OPERATION 5	ACCESS 0	// "Excluir"

If nModulo == 73
	ADD OPTION aRotina TITLE STR0017 ACTION "CRMA200('AC6')"	OPERATION 3	ACCESS 0	// "Privil�gios"
EndIf

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TmkA330Pos� Autor � Vendas CRM         � Data �  08/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pos validacao do browse MVC, executada antes da gravacao,   ���
���          �permitindo validar o formulario.                            ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA330                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TmkA330Pos(oMdl)
Local nOperation := oMdl:GetOperation()
Local lRet := .T.  

if  nOperation == 3 .OR. nOperation == 4
	If !Tk330ValGrid(oMdl)
		lRet:= .F.
		Return(lRet)
	EndIf

//������������������������������������������Ŀ
//� Calcula o valor total da meta.           �
//��������������������������������������������	
     Tk330CalCamp()

EndIf
Return lRet
     
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �TmkA330LPos� Autor � Vendas CRM         � Data �  08/11/10   ���
��������������������������������������������������������������������������͹��
���Desc.     �Bloco de codigo acionado na mudanca linha.                   ���
��������������������������������������������������������������������������͹��
���Uso       �TmkA330                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function TmkA330LPos()

//������������������������������������������Ŀ
//�Apos a mudanca da linha calcular o valor, �
//�total da meta.                            �
//��������������������������������������������
 	Tk330CalCamp()

Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Tk330CalCamp� Autor � Vendas CRM         � Data �  08/11/10   ���
���������������������������������������������������������������������������͹��
���Desc.     �Calcula o valor total da meta , baseado no faturamento de     ���
���          �cada campanha.                                                ���
���������������������������������������������������������������������������͹��
���Uso       �TmkA330                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function Tk330CalCamp()

Local oMdl := FWModelActive()
Local oMdlAC6 := oMdl:GetModel('AC6MASTER')
Local oMdlAC7 := oMdl:GetModel('AC7DETAIL')
Local nX := 0
Local nSoma := 0                        

For nX:= 1 to oMdlAC7:GetQtdLine()
	oMdlAC7:GoLine(nX)
	If !oMdlAC7:IsDeleted()
		nSoma += oMdlAC7:GetValue('AC7_FATCAM')
	EndIf                                                                     
Next nX
                                                                                                                            
oMdlAC6:SetValue('AC6_TOTFAT',nSoma,.T.)

Return(.T.)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Tk330ValGrid� Autor � Vendas CRM         � Data �  08/11/10   ���
���������������������������������������������������������������������������͹��
���Desc.     �Validacao do Grid                                             ���
���������������������������������������������������������������������������͹��
���Uso       �TmkA330                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function Tk330ValGrid(oMdl)
Local oMdlAC7 := oMdl:GetModel('AC7DETAIL')
Local lRet := .T.
Local nY := 0
Local nX := 0

//����������������������������������������������Ŀ
//�Verifica se foi atribuido um valor para Fat.  �
//�da Campanha.                                  �
//������������������������������������������������

For nY := 1 To oMdlAC7:GetQtdLine()
oMdlAC7:GoLine(nY)	
		If Empty(oMdlAC7:GetValue('AC7_FATCAM')) .AND. !oMdlAC7:IsDeleted()
			Help(" ",1,"SEMCAMPANH")
			lRet := .F.
			Return(lRet)
			Exit
		EndIf
Next nY


//��������������������������������������������Ŀ
//�Verifica se existem linhas em branco.       �
//����������������������������������������������
For nX:= 1 to oMdlAC7:GetQtdLine()
	oMdlAC7:GoLine(nX)                                                              
		If oMdlAC7:IsEmpty() .AND. !oMdlAC7:IsDeleted()	
			Help(" ",1,"SEMCAMPANH")
			lRet := .F.
			Exit
		EndIf
Next nX
Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Tk330Cmm

Faz o Commit dos Dados.   

@sample 	Tk330CMM( oModel )

@param		oModel -  Modelo de dados do sistema

@return   	lRet   -  Retorna verdadeiro ou falso

@author	Thiago Tavares
@since		11/04/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Tk330Cmm( oModel )

Local lRet		:= .T.

FWFormCommit(oModel,Nil,{|oModel,cId,cAlias| Tk330CmtAft(oModel,cId,cAlias) })

Return( lRet )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Tk330CmtAft

Bloco de transacao durante o commit do model. 

@sample	Tk330CmtAft(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		06/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function Tk330CmtAft(oModel,cId,cAlias)

Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""		
Local aAutoAO4  	:= {}
Local lRetorno 	:= .T.
		
//���������������������������������������������������Ŀ
//�Adiciona ou Remove o privilegios deste registro.  �
//����������������������������������������������������
If cId == "AC6MASTER" .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE ) 
	cChave 	:= PadR(xFilial("AC6")+oModel:GetValue("AC6_META"),TAMSX3("AO4_CHVREG")[1])
	aAutoAO4	:= CRMA200PAut(nOperation,"AC6",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
	lRetorno	:= CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
EndIf 

Return(lRetorno)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} AO4GdModel

Cria um GridModel associado ao modelo informado no par�metro, para evitar
a valida��o do SX9 da entidade principal do modelo informado com a AO4

@param, cIDModel, ID do modelo principal                              , String
@param, oModel  , Objeto do modelo a que o novo modelo serah associado, MPFormModel

@sample		AO4GdModel(cIDModel, oModel)

@return, Nil

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function AO4GdModel(cIDMasterM, oModel, cAliasMast )
Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
Default cIDMasterM := ""
Default cAliasMast := ""

oModel:AddGrid("AO4CHILD",cIDMasterM,oStructAO4,/*bPreValid*/,/*bPosValid*/, , ,{|oGridModel, lCopy|LoadGdAO4(oGridModel, lCopy)})
oModel:SetRelation( "AO4CHILD" ,{ { "AO4_FILIAL", "FWxFilial( 'AO4' )" }, { "AO4_ENTIDA", cAliasMast }, { "AO4_CHVREG", ( cAliasMast )->( IndexKey( 1 ) ) }  }, AO4->( IndexKey( 1 ) ) )
oModel:GetModel("AO4CHILD"):SetOnlyView()
oModel:GetModel("AO4CHILD"):SetOnlyQuery()
oModel:GetModel("AO4CHILD"):SetOptional(.T.)
oModel:GetModel("AO4CHILD"):SetNoInsertLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoUpdateLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoDeleteLine(.T.)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGdAO4 

Bloco de carga dos dados do submodelo.
Este bloco sera invocado durante a execu��o do metodo activate desta classe.
O bloco recebe por parametro o objeto de model do FormGrid(FWFormGridModel) e um 
valor l�gico indicando se eh uma opera��o de copia.

@param, oGridModel, objeto de model do FormGrid, FWFormGridModel
@param, lCopy     , indica se eh uma opera��o de copia, Boolean

@sample	LoadGdAO4(oGridModel, lCopy)

@return, aLoad, array com os dados que ser�o carregados no objeto, 
                o array deve ter a estrutura abaixo:
					[n]
					[n][1] ExpN: Id do registro (RecNo)
					[n][2] Array com os dados, os dados devem seguir exatamente 
					       a mesma ordem da estrutura de dados submodelo

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function LoadGdAO4(oGridModel, lCopy)
	
	Local aLoad      := {}
	Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStructAO4:GetFields()
	nQtFields := Len(aFields)

	AAdd(aLoad, {0,{}})

	For nField := 1 To nQtFields
		
		cField := aFields[nField][3]
		
		If Alltrim(cField) == "AO4_FILIAL"
			xValue := XFilial("AO4")
			cType  := ""
		Else
			cType  := aFields[nField][4]
			nLen   := aFields[nField][5]	
		EndIf

		Do Case
			Case cType == "C"
				xValue := Space(nLen)
			Case cType == "N"
				xValue := 0
			Case cType == "L"
				xValue := .T.
			Case cType == "D"
				xValue := CToD("  /  /    ")
		End Case

		AAdd(aLoad[1][2], xValue)
	Next nField

	FwFreeObj(oStructAO4)
	FwFreeObj(aFields)

Return aLoad
