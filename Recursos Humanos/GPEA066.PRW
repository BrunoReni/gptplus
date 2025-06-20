#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA066.CH'

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA066   � Autor � Leandro Drumond                   � Data � 21/02/2014 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo de outros beneficios                                             ���
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
Function GPEA066() 

Local cFiltraRh
Local oBrwSRA
Local xRetFilRh

Private cPerRIR := ""
Private cBenRIR	:= ""

oBrwSRA := FWmBrowse():New()		
oBrwSRA:SetAlias( 'SRA' )
oBrwSRA:SetDescription(STR0001)	//"Outros Benef�cios"
	
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
���Fun��o    � MenuDef    � Autor � Leandro Drumond       � Data �21/02/2014���
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
ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION 'fViewRIR()'	 	OPERATION 2 ACCESS 0 //"Visualizar"

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
Local oStruRIR 		:= FWFormStruct(1, 'RIR', /*bAvalCampo*/,/*lViewUsado*/)

Local oModel

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA066', /*bPreValid*/ , /*bPosValid*/, /*bCommit*/, /*bCancel*/)

//Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

//Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'RIRDETAIL', 'SRAMASTER', oStruRIR, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

//Instancia vari�veis usada no relaciomaneto entre compomentes do model
If type("cPerRIR") == "U"
	cPerRIR := ""
EndIf
If type("cBenRIR") == "U"
	cBenRIR := ""
EndIf

//Faz relaciomaneto entre os compomentes do model
If Empty(cPerRIR) .and. Empty(cBenRIR)
	oModel:SetRelation('RIRDETAIL', {{'RIR_FILIAL', 'xFilial("RIR")'}, {'RIR_MAT', 'RA_MAT'}}, RIR->(IndexKey(1)))
ElseIf !Empty(cPerRIR) .and. Empty(cBenRIR)
	oModel:SetRelation('RIRDETAIL', {{'RIR_FILIAL', 'xFilial("RIR")'}, {'RIR_MAT', 'RA_MAT'}, {'RIR_PERIOD',"'" + cPerRIR + "'" } }, RIR->(IndexKey(1)))
ElseIf Empty(cPerRIR) .and. !Empty(cBenRIR)
	oModel:SetRelation('RIRDETAIL', {{'RIR_FILIAL', 'xFilial("RIR")'}, {'RIR_MAT', 'RA_MAT'}, {'RIR_TPBENE',"'" + cBenRIR + "'" } }, RIR->(IndexKey(1)))
Else
	oModel:SetRelation('RIRDETAIL', {{'RIR_FILIAL', 'xFilial("RIR")'}, {'RIR_MAT', 'RA_MAT'}, {'RIR_PERIOD',"'" + cPerRIR + "'" } , {'RIR_TPBENE',"'" + cBenRIR + "'" } }, RIR->(IndexKey(1)))
EndIf

//Permite grid sem dados
oModel:GetModel('RIRDETAIL'):SetOptional(.T.)

oModel:GetModel('SRAMASTER'):SetOnlyView(.T.)
oModel:GetModel('SRAMASTER'):SetOnlyQuery(.T.)

//Adiciona a descricao do Modelo de Dados
oModel:SetDescription(OemToAnsi(STR0001))  //"Outros Benef�cios"

//Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0004)) //"Funcion�rio"
oModel:GetModel('RIRDETAIL'):SetDescription(OemToAnsi(STR0006)) //"Hist�rico de C�lculo"

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
Local oModel   := FWLoadModel('GPEA066')

//Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRIR := FWFormStruct(2, 'RIR')

//Cria o objeto de View
oView := FWFormView():New()

//Remove campos da estrutura e ajusta ordem dos campos na view
oStruRIR:RemoveField('RIR_MAT')	
 
//Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RIR', oStruRIR, 'RIRDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('HISTORICO', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RIR', 'HISTORICO')

Return( oView )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �fViewRIR    � Autor � Leandro Drumond       � Data �25/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visualizador de dados 										���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � 				                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function fViewRIR()
	cRot := fGetCalcRot("I") //Outros Beneficios

	If Pergunte("GPA066",.T.)
	
		cBenRIR := MV_PAR01
		cPerRIR := MV_PAR02
	
		FWExecView(OemToAnsi(STR0001), "GPEA066" )

	EndIf

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Gp66VldPer  � Autor � Leandro Drumond       � Data �25/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Valida pergunte		 										���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � 				                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function Gp66VldPer()
Local aArea	:= GetArea()
Local lRet 	:= .T.
Local cVar	:= &(ReadVar())

If !Empty(cVar)
	DbSelectArea("RCH")
	DbSetOrder(RetOrder("RCH","RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG"))
	
	If !DbSeek(xFilial("RCH")+SRA->RA_PROCES+fGetCalcRot("I")+cVar)
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet
