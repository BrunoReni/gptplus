#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA068.CH'

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA068   � Autor � Leandro Drumond                   � Data � 21/02/2014 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Dados do Calculo de outros beneficios                                    ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                          ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���            �          �                �                                            ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function GPEA068() 

Local cFiltraRh
Local oBrwSRA
Local xRetFilRh

Private cPerRIR := ""
Private cBenRIR	:= ""

oBrwSRA := FWmBrowse():New()		
oBrwSRA:SetAlias( 'SRA' )
oBrwSRA:SetDescription(STR0001)	//"Visualiza��o do C�lculo de Outros Benef�cios"
	
//Inicializa o filtro utilizando a funcao FilBrowse
xRetFilRh := CHKRH(FunName(),"SRA","1")
If ValType(xRetFilRh) == "L"
	cFiltraRh := if(xRetFilRh,".T.",".F.")
Else
	cFiltraRh := xRetFilRh
EndIf

GpLegMVC(@oBrwSRA)	// Adicionar a Legenda no Browse   

//Filtro padrao do Browse conforme tabela SRA (Funcion�rios)
oBrwSRA:SetFilterDefault(cFiltraRh)

oBrwSRA:DisableDetails()	
oBrwSRA:Activate()

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Leandro Drumond       � Data �25/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0002)  ACTION 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION 'VIEWDEF.GPEA068' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0006)  ACTION 'VIEWDEF.GPEA068' 	OPERATION 4 ACCESS 0 //"Manuten��o"

Return( aRotina )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Leandro Drumond       � Data �21/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para os dados de    ���
���          �Outros Beneficios calculados                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

Local aAux			:= {}
//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+ "|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRI1 		:= FWFormStruct(1, 'RI1', /*bAvalCampo*/,/*lViewUsado*/)
Local oStruRIQ 		:= FWFormStruct(1, 'RIQ', /*bAvalCampo*/,/*lViewUsado*/)

Local oModel

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA068', /*bPreValid*/ , /*bPosValid*/, {|oModel|Gp068Commit(oModel)}/*bCommit*/, /*bCancel*/)

//Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

//Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'RI1DETAIL', 'SRAMASTER', oStruRI1, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'RIQDETAIL', 'RI1DETAIL', oStruRIQ, {|oGrid| Gp068PreVld(oGrid)}/*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('RI1DETAIL', {{'RI1_FILIAL', 'xFilial("RI1")'}, {'RI1_MAT', 'RA_MAT'} }, RI1->(IndexKey(1)))
oModel:SetRelation('RIQDETAIL', {{'RIQ_FILIAL', 'xFilial("RIQ")'}, {'RIQ_MAT', 'RI1_MAT'}, {'RIQ_TPBENE','RI1_BENEF' } , {'RIQ_COD','RI1_TABELA' } }, RIQ->(IndexKey(1)))

//Permite grid sem dados
oModel:GetModel('RI1DETAIL'):SetOptional(.F.)
oModel:GetModel('RIQDETAIL'):SetOptional(.T.)
oModel:GetModel('RIQDETAIL'):SetNoInsertLine(.T.)

oModel:GetModel('SRAMASTER'):SetOnlyView(.T.)
oModel:GetModel('SRAMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('RI1DETAIL'):SetOnlyView(.T.)
oModel:GetModel('RI1DETAIL'):SetOnlyQuery(.T.)

//Adiciona a descricao do Modelo de Dados
oModel:SetDescription(OemToAnsi(STR0001))  //"Outros Benef�cios"

oModel:SetVldActivate( { |oModel| GPA068VldIni(oModel) } )

Return( oModel	)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Leandro Drumond       � Data �21/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visualizador de dados 										���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()	

Local oView

//Define os campos do SRA que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA068')

//Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRI1 := FWFormStruct(2, 'RI1')
Local oStruRIQ := FWFormStruct(2, 'RIQ')

//Cria o objeto de View
oView := FWFormView():New()

//Remove campos da estrutura e ajusta ordem dos campos na view
oStruRI1:RemoveField('RI1_MAT')	
oStruRIQ:RemoveField('RIQ_MAT')	
oStruRIQ:RemoveField('RIQ_TPBENE')	
oStruRIQ:RemoveField('RIQ_DESCBN')	
oStruRIQ:RemoveField('RIQ_COD')	
oStruRIQ:RemoveField('RIQ_DESCOD')	
oStruRIQ:RemoveField('RIQ_PD')
oStruRIQ:RemoveField('RIQ_PD1')
oStruRIQ:RemoveField('RIQ_PD2')
oStruRIQ:RemoveField('RIQ_DESC1')
oStruRIQ:RemoveField('RIQ_DESC2')
oStruRIQ:RemoveField('RIQ_DESC3')
 
//Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RI1', oStruRI1, 'RI1DETAIL')
oView:AddGrid('VIEW_RIQ', oStruRIQ, 'RIQDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 40)
oView:CreateHorizontalBox('DETALHE', 50)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RI1', 'INFERIOR')
oView:SetOwnerView('VIEW_RIQ', 'DETALHE')

Return( oView )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GPA068VldIni� Autor � Leandro Drumond       � Data �27/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida model													���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Static Function GPA068VldIni(oModel)
Local lRet	:= .T.

dbSelectArea( "RIQ" )
If !dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
	Help(,,STR0004,, STR0005,1,0 ) //"N�o existe beneficios calculados para o funcion�rio" # "Aten��o"
	lRet := .F.
EndIf

Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp068Fech   � Autor � Leandro Drumond       � Data �27/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada para o fechamento de outros beneficios				���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Function Gp068Fech()

GPEM120()

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp068Commit � Autor � Leandro Drumond       � Data �14/10/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Commit														���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������/*/
Function Gp068Commit(oModel)
Local oGrid := oModel:GetModel("RIQDETAIL")
Local nTam	:= oGrid:Length()
Local nX	:= 0

For nX := 1 to nTam
	oGrid:GoLine(nX)
	If oGrid:IsUpdated() .or. oGrid:IsInserted()
		oGrid:LoadValue("RIQ_TIPO","2")
	EndIf	
Next nX

FWFormCommit( oModel, {|| .T.} ) //Grava novo registro

Return .T.

/*/{Protheus.doc} Gp068PreVld()
- Fun��o respons�vel por validar a digita��o de dados na linha.
@author: Leandro.Drumond
@since:  01/02/2017
/*/

Static Function Gp068PreVld(oGrid)
Local lRet 	:= .T.

If Empty(oGrid:GetValue("RIQ_VALCAL")) .and. Empty(oGrid:GetValue("RIQ_PROCES")) 
	lRet := .F.
EndIf

Return lRet