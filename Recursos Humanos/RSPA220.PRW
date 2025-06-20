#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'RSPA220.CH'
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPA220  � Autor � Emerson Campos                    � Data � 08/01/2014 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Config. Campos Portal (RS1)                                  ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSPA220()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�29/07/2014�TQENN4          �Incluido o fonte da 11 para a 12 e efetuada ���
���            �          �                �a limpeza.                                  ���
���Gustavo M.  �29/09/2014�TQRSKQ          �Inibi��o de bot�o Salvar e Criar Novo, alem ���
���            �          �                �de corre��o do erro ao validar a linha.     ���
���Flavio C.   �30/06/2016�TVN389          �Configura��o campo QG_TPCURRI               ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function RSPA220 ()
Local cFiltra	:= "RS0_TABELA $ 'SQG'"
Local oBrwRS0
Local lRet			:= .T.

PutRS0e1()

oBrwRS0 := FWmBrowse():New()		
oBrwRS0:SetAlias( 'RS0' )
oBrwRS0:SetDescription(STR0001)	//"Configura��o de campos no portal"

//Filtro padrao do Browse conforme tabela RS0 (Funcion�rios)
oBrwRS0:SetFilterDefault(cFiltra)

oBrwRS0:DisableDetails()	
oBrwRS0:Activate()


Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef     � Autor � Emerson Campos        � Data �08/01/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Menu Funcional                                                ���
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
	
	ADD OPTION aRotina Title STR0002  Action 'PesqBrw'        	OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.RSPA220'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.RSPA220'	OPERATION 4 ACCESS 0 //"Manuten��o"
	
Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Emerson Campos        � Data �08/01/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para o Cadastro de  ���
���          �Programa��o de Rateio (RS1)                                   ���
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

	//Define os campos do RS0 que ser�o apresentados na tela	
	Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RS0_TABELA|RS0_TITULO|RS0_ROTINA"}
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRS0 		:= FWFormStruct(1, 'RS0', bAvalCampo,/*lViewUsado*/)
	Local oStruRS1 		:= FWFormStruct(1, 'RS1', /*bAvalCampo*/,/*lViewUsado*/)
	Local oMdlRS1
	
	// Blocos de codigo do modelo
	Local bLinePos		:= {|| Rs220linOk()}
	Local bPosValid 	:= {|| Rs220TdOk()}

	//Atribui 
   	//oStruRS1:SetProperty( 'RS1_ORIGEM'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'S'" ) ) 
	
	// Cria o objeto do Modelo de Dados
	oMdlRS1 := MPFormModel():New('RSPA220', /*bPreValid*/ , bPosValid, /*bCommit*/, /*bCancel*/)
	
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
   	oMdlRS1:AddFields('RS0MASTER', /*cOwner*/, oStruRS0, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)
	
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
	oMdlRS1:AddGrid( 'RS1DETAIL', 'RS0MASTER', oStruRS1, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
		
	// Faz relaciomaneto entre os compomentes do model
	oMdlRS1:SetRelation('RS1DETAIL', {{'RS1_FILIAL', 'xFilial("RS1")'}, {'RS1_TABELA', 'RS0_TABELA'}}, RS1->(IndexKey(1)))
	
	//Define Chave �nica
	oMdlRS1:GetModel('RS1DETAIL'):SetUniqueLine({'RS1_TABELA', 'RS1_CAMPO'})
	
	//Permite grid sem dados
	oMdlRS1:GetModel('RS1DETAIL'):SetOptional(.T.)	
	oMdlRS1:GetModel('RS1DETAIL'):SetNoDeleteLine( .T. )
	oMdlRS1:GetModel('RS1DETAIL'):SetNoInsertLine( .T. )
	
	oMdlRS1:GetModel('RS0MASTER'):SetOnlyView(.T.)
	oMdlRS1:GetModel('RS0MASTER'):SetOnlyQuery(.T.)
	oMdlRS1:SetOnlyQuery('RS0MASTER')
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRS1:SetDescription(OemToAnsi(STR0001))  // "Cadastro Programa��o de Rateio"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRS1:GetModel('RS0MASTER'):SetDescription(OemToAnsi(STR0005)) // "Rotinas do Portal"
	oMdlRS1:GetModel('RS1DETAIL'):SetDescription(OemToAnsi(STR0006)) // "Configura��o dos Campos"

Return oMdlRS1
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Emerson Campos        � Data �08/01/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de de Programa��o de Rateio���
���          � (RS1)                                                        ���
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
//Define os campos do RS0 que ser�o apresentados na tela	
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RS0_TABELA|RS0_TITULO|RS0_ROTINA"}
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('RSPA220')
// Cria a estrutura a ser usada na View
Local oStruRS0 := FWFormStruct(2, 'RS0', bAvalCampo)
Local oStruRS1 := FWFormStruct(2, 'RS1')

// Cria o objeto de View
oView := FWFormView():New()
 
// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_RS0', oStruRS0, 'RS0MASTER')

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RS1', oStruRS1, 'RS1DETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_RS0', 'SUPERIOR')
oView:SetOwnerView('VIEW_RS1', 'INFERIOR') 

oView:SetCloseOnOk({ || .T. })
// Criar novo botao na barra de botoes
oView:AddUserButton( STR0040, 'CLIPS', { |cTab,lOk| PutRS0e1(RS0->RS0_TABELA, .T.) } )  //'Recupera Config. Padr�o'

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_RS1', OemToAnsi(STR0001)) // "Cadastro Programa��o de Rateio"
Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs220LinOk  � Autor � Emerson Campos        � Data � 11/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Linha OK da tela de configura��o campos do portal Candidato. ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs220LinOk( oMdlRS1 )                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRS1 = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Rs220linOk(lTdOk)	
Local lRet		:= .T.	
Local oModel    := FWModelActive()
Local oMdlRS1 	:= oModel:GetModel( 'RS1DETAIL' )
Local nI		:= 1
Local nInic		:= 1
Local nTam		:= oMdlRS1:Length()
Default lTdOk	:= .F.  

If !lTdOk
	nInic	:= oMdlRS1:nLine
	ntam	:= oMdlRS1:nLine	
EndIf
/*
*********************************************************************************
* Valida�oes relativas a tela de config Tabelas e campos o portal do candidato  *
*********************************************************************************
*/
For nI := nInic To nTam 
	If oMdlRS1:GetValue('RS1_CHAVE', nI) == 'S' .AND.;
		(oMdlRS1:GetValue('RS1_OBRIGA', nI) == 'N' .OR. oMdlRS1:GetValue('RS1_VISUAL', nI) == 'N') 
			Help( , , 'HELP', , OemToAnsi(STR0039), 1, 0 )   //'Se o campo for "chave" ele deve ser obrigat�rio e visual.'
			lRet := .F.
			Exit
	EndIf

	If lRet .AND.;
		(oMdlRS1:GetValue('RS1_OBRIGA', nI) == 'S' .AND. oMdlRS1:GetValue('RS1_VISUAL',nI) == 'N') 
			Help( , , 'HELP', , OemToAnsi(STR0038), 1, 0 ) //'Se o campo for "obrigat�rio" ele deve ser visual.'
			lRet := .F.
			Exit
	EndIf
Next nI 
		
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs220TdOk   � Autor � Emerson Campos        � Data � 11/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo OK da tela de configura��o de campos do portal Candidato���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs220TdOk( oMdlRS1 )                                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRS1 = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Rs220TdOk()	
Return Rs220LinOk(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PutRS0e1    � Autor � Emerson Campos        � Data � 11/01/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � imputa dados nas tabelas RS0 e RS1                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PutRS0e1(  )                                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cTab     = Tabela a retornar configura��o padr�o             ���
���          � lConfPad = .T. Volta configura��o padr�o, o default � .F.    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function PutRS0e1(cTab, lConfPad)
Local lRet		:= .T.
Local nI		:= 0
Local nTam		:= 0
Local aRS0		:= {}
Local aRS1		:= {}
Local lInc		:= .T.
Local lMunNasc 	:= SQG->(ColumnPos("QG_CODMUNN")) > 0 .and. SQG->(ColumnPos("QG_MUNNASC")) > 0  
Local oView 

Default cTab 		:= ''
Default lConfPad 	:= .F.
 
If lConfPad
	If !( xRet := ApMsgYesNo( STR0036+" "+cTab+ " "+STR0037 ) )
		lConfPad	:= .F.
	Else
		lInc	:= .F.
	EndIf
EndIf    
            
aAdd(aRS0, {xFilial("RS0"), "SQG", STR0034, STR0035 }) 

nTam	:= len(aRS0) 
DbSelectArea("RS0")
RS0->(DbSetOrder(1))
If RS0->(RecCount()) < nTam
	For nI := 1 To nTam
		If !RS0->(DbSeek(xfilial('RS0')+aRS0[nI,2]))
				RECLOCK('RS0', .T.)	
					RS0->RS0_FILIAL     := aRS0[nI,1]
					RS0->RS0_TABELA     := aRS0[nI,2]	
					RS0->RS0_TITULO     := aRS0[nI,3]	
					RS0->RS0_ROTINA     := aRS0[nI,4]
				RS0->(MsUnLock())
		EndIf 
	Next nI	
EndIf
 

aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_NOME   ", STR0007, "S", "S", "S" })
If cPaisloc == 'MEX'
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_PRINOME", STR0008, "S", "S", "N" })
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_SECNOME", STR0009, "S", "S", "N" })
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_PRISOBR", STR0010, "S", "S", "N" })
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_SECSOBR", STR0011, "S", "S", "N" })
EndIf 
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_RG     ", STR0012, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_CIC    ", STR0013, "S", "S", "S" })
If cPaisLoc == "BRA"
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_NUMCP", STR0014, "N", "S", "N" })
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_SERCP", STR0015, "N", "S", "N" })
EndIf 
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_DTNASC ", STR0016, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_ENDEREC", STR0017, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_COMPLEM", STR0018, "N", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_BAIRRO ", STR0019, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_MUNICIP", STR0020, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_ESTADO ", STR0021, "S", "S", "N" })
If cPaisLoc <> "BOL"
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_CEP", STR0022, "S", "S", "N" })
EndIf
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_FONE   ", STR0023, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_FONECEL", STR0024, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_EMAIL  ", STR0025, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_SEXO   ", STR0026, "S", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_ESTCIV ", STR0027, "N", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_QTDEFIL", STR0028, "N", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_NATURAL", STR0029, "N", "S", "N" })

If lMunNasc
	aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_MUNNASC ", GetSx3Cache("QG_MUNNASC","X3_TITULO"), "N", "S", "N" })
EndIf

aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_NACIONA", STR0030, "N", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_DFISICO", STR0031, "N", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_ULTSAL ", STR0032, "N", "S", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_SENHA  ", STR0033, "S", "S", "S" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_CODFUN ", GetSx3Cache("QG_CODFUN","X3_TITULO"), "N", "N", "N" })
aAdd(aRS1, {xFilial("RS1"), "SQG", "QG_TPCURRI ", GetSx3Cache("QG_TPCURRI","X3_TITULO"), "N", "N", "N" })

nTam	:= len(aRS1) 
DbSelectArea("RS1")
RS1->(DbSetOrder(1))
If RS1->(RecCount()) < nTam .OR. lConfPad
	For nI := 1 To nTam 
		If !lConfPad .OR. aRS1[nI,2] == cTab
			If !RS1->(DbSeek(xfilial('RS1')+aRS1[nI,2]+aRS1[nI,3])) .OR.;
				 (lConfPad .AND. RS1->(DbSeek(xfilial('RS1')+aRS1[nI,2]+aRS1[nI,3])))
				RECLOCK('RS1', lInc)	
					RS1->RS1_FILIAL     := aRS1[nI,1]
					RS1->RS1_TABELA     := aRS1[nI,2]
					RS1->RS1_CAMPO      := aRS1[nI,3]
					RS1->RS1_TITULO     := aRS1[nI,4]	
					RS1->RS1_OBRIGA     := aRS1[nI,5]	
					RS1->RS1_VISUAL     := aRS1[nI,6]
					RS1->RS1_CHAVE      := aRS1[nI,7]
				RS1->(MsUnLock())
			EndIf 
		EndIf
	Next nI	
EndIf   

If lConfPad
	oView := FWViewActive()
	oView:Refresh()
	RSPA220()
EndIf
Return lRet