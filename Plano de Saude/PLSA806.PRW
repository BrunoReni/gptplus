#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA806.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA806
Funcao para abrir Agendamento de Capta��o
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA806()

Local oBrowse
LOCAL nFor := 0
LOCAL aAlias := {"B9Y", "B9V", "B9L", "B9P", "B9R", "B9Q", "BC9", "BID", "B18"}
LOCAL cAlias := ""

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B9P')
oBrowse:SetDescription(FunDesc())

//Cria Legenda do Browse
obrowse:AddLegend( "!(Vazio(B9P_DATCAN))", "RED", "Visita Cancelada") //"Visita Cancelada"
obrowse:AddLegend( "!(Vazio(B9P_DATAVI))", "BLUE", STR0001) //"Visita Realizada"
obrowse:AddLegend( "(Vazio(B9P_DATAVI))", "GRAY", STR0002) //"Visita Pendente"


oBrowse:Activate()

//	Fecha as tabelas utilizadas na rotina
FOR nFor := 1 TO LEN(aAlias)
	IF SELECT(aAlias[nFor]) > 0
		cAlias := aAlias[nFor]
		( cAlias )->( DbCloseArea() )
	ENDIF
NEXT

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title STR0033 /*'Visualizar'*/ Action 'VIEWDEF.PLSA806' Operation 2 Access 0
Add Option aRotina Title STR0034 /*'Incluir'   */ Action 'VIEWDEF.PLSA806' Operation 3 Access 0
Add Option aRotina Title STR0035 /*'Alterar'   */ Action 'VIEWDEF.PLSA806' Operation 4 Access 0
Add Option aRotina Title STR0036 /*'Excluir'   */ Action 'VIEWDEF.PLSA806' Operation 5 Access 0
Add Option aRotina Title STR0037 /*'Imprimir'  */ Action 'VIEWDEF.PLSA806' Operation 8 Access 0
Add Option aRotina Title STR0038 /*'Copiar'    */ Action 'VIEWDEF.PLSA806' Operation 9 Access 0

AaDd( aRotina,{ STR0003 /*"Conhecimento"*/	,"PLS806BAN()"	, 0 , 0 } ) //Cria o bot�o de conhecimento no Browse

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados constru�do
Local oStrB9P:= FWFormStruct(1,'B9P')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que ir�considerar
Local oStrB9Q:= FWFormStruct(1,'B9Q'/*, { |cCampo| PLSAB9Q806(cCampo) } */)// Cria as estruturas a serem usadas no Modelo de Dados
Local oStrB9R:= FWFormStruct(1,'B9R') // Cria as estruturas a serem usadas no Modelo de Dados
Local oStrB9V:= FWFormStruct(1,'B9V'/*, { |cCampo| PLSAB9V806(cCampo) } */) // Cria as estruturas a serem usadas no Modelo de Dados

oModel := MPFormModel():New( 'PLSA806' , , {|| PLSA806OK(oModel) }, , {|| PLSA806SXE(oModel) } ) // Cria o objeto do Modelo de Dados e insere a fun�ao de p�s-valida��o

oModel:addFields('MasterB9P',/*cOwner*/,oStrB9P)  // Adiciona ao modelo um componente de formul�rio

oModel:AddGrid('B9VDetail', 'MasterB9P', oStrB9V) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B9QDetail', 'B9VDetail', oStrB9Q) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B9RDetail', 'B9VDetail', oStrB9R) // Adiciona ao modelo uma componente de grid

oModel:SetRelation( 'B9VDetail', { ;
	{ 'B9V_FILIAL'	, 'xFilial("B9V")' },;
	{ 'B9V_CODINT'	, 'B9P_CODINT' 		},;
	{ 'B9V_SEQB9V'	, 'B9P_SEQVIS' 		},;
	{ 'B9V_CODPRO'	, 'B9P_CODPRO'		} },;
	B9V->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

oModel:SetRelation( 'B9QDetail', {	;
	{ 'B9Q_FILIAL'	, 'xFilial("B9Q")'	},;
	{ 'B9Q_CODPRO'	, 'B9V_CODPRO' 		},;
	{ 'B9Q_CODINT'	, 'B9V_CODINT' 		},;
	{ 'B9Q_SEQVIS'	, 'B9V_SEQB9V'		},;
	{ 'B9Q_CODLOC'	, 'B9V_CODSEQ'		} },;
	B9Q->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

oModel:SetRelation( 'B9RDetail', { ;
	{ 'B9R_FILIAL' 	, 'xFilial("B9R")' },;
	{ 'B9R_CODPRO'	, 'B9V_CODPRO'		},;
	{ 'B9R_CODINT'	, 'B9V_CODINT' 		},;
	{ 'B9R_SEQVIS'	, 'B9V_SEQB9V'		},;
	{ 'B9R_CODLOC'	, 'B9V_CODSEQ'		} },;
B9R->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

oModel:GetModel( 'B9QDetail' ):SetUniqueLine( { 'B9Q_CODESP' } ) //Nao deixa cadastrar dois registros iguais
oModel:GetModel( 'B9RDetail' ):SetUniqueLine( { 'B9R_CODPRO', 'B9R_CODSER' } ) //Nao deixa cadastrar dois registros iguais
oModel:GetModel( 'B9VDetail' ):SetUniqueLine( { 'B9V_CODPRO', 'B9V_CEP', 'B9V_COMEND'} ) //Nao deixa cadastrar dois registros iguais

oModel:GetModel('MasterB9P'):SetDescription(FunDesc()) // Adiciona a descri��o do Modelo de Dados

//N�o permite adi��o de linhas, caso j� tenha ocorrido a cria��o da solicita��o de Credenciamento.
oModel:GetModel('B9VDetail'):SetNoInsertLine( IIF(oModel:getOperation() == MODEL_OPERATION_INSERT, .F., PLS806WHEN() ) )
oModel:GetModel('B9QDetail'):SetNoInsertLine( IIF(oModel:getOperation() == MODEL_OPERATION_INSERT, .F., PLS806WHEN() ) )
oModel:GetModel('B9RDetail'):SetNoInsertLine( IIF(oModel:getOperation() == MODEL_OPERATION_INSERT, .F., PLS806WHEN() ) )

//Ajusta, temporariamente, o inicializador padr�o do campo para a rotina.
oStrB9V:SetProperty( 'B9V_CODPRO' , MODEL_FIELD_INIT, { || "0" } )
oStrB9V:SetProperty( 'B9V_SEQB9V' , MODEL_FIELD_INIT, { || oModel:GetModel('MasterB9P'):getValue("B9P_SEQVIS")} )

//Ajusta os WHEN do cadastro, em fun��o de ter sido gerado, ou n�o, a solicita��o de Credenciamento
oStrB9V:SetProperty( '*' , MODEL_FIELD_WHEN , { || PLS806WHEN() } )
oStrB9P:SetProperty( '*' , MODEL_FIELD_WHEN , { || PLS806WHEN() } )
oStrB9P:SetProperty( 'B9P_OBSERV' , MODEL_FIELD_WHEN , { || .T. } )
oStrB9Q:SetProperty( '*' , MODEL_FIELD_WHEN , { || PLS806WHEN() } )
oStrB9R:SetProperty( '*' , MODEL_FIELD_WHEN , { || PLS806WHEN() } )

//Ajustes secund�rios do WHEN, necess�rios para que o cadastro funcione como esperado.
oStrB9P:SetProperty( 'B9P_AGENTE' , MODEL_FIELD_WHEN , { || IIF(Vazio(M->B9P_DATAVI) .AND. Vazio(M->B9P_HORAVI), PLS806WHEN(), .F. ) } )
oStrB9P:SetProperty( 'B9P_DATAVI' , MODEL_FIELD_WHEN , { || IIF(oModel:getOperation() == MODEL_OPERATION_INSERT, .F., PLS806WHEN() ) } )
oStrB9P:SetProperty( 'B9P_HORAVI' , MODEL_FIELD_WHEN , { || IIF(oModel:getOperation() == MODEL_OPERATION_INSERT, .F., PLS806WHEN() ) } )
oStrB9P:SetProperty( 'B9P_INTCON' , MODEL_FIELD_WHEN , { || IIF(oModel:getOperation() == MODEL_OPERATION_INSERT, .F., PLS806WHEN() ) .AND. !(Vazio(M->B9P_DATAVI)) } )
oStrB9P:SetProperty( 'B9P_PROVCT' , MODEL_FIELD_WHEN , { || IIF(M->B9P_INTCON == "1", PLS806WHEN(), .F.) } )

//Hora da visita obrigat�ria somente quando for informada a data da visita
oStrB9P:SetProperty( 'B9P_HORAVI' , MODEL_FIELD_OBRIGAT, IIF(Vazio(M->B9P_DATAVI), .F., .T.) )

//Define Chave prim�ria do Model
oModel:SetPrimaryKey( {"B9P_FILIAL", "B9P_CODINT", "B9P_CRMNUM", "B9P_CRMEST", "B9P_SEQVIS"} )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualiza��o constru�da
Local oModel := FWLoadModel( 'PLSA806' ) // Cria as estruturas a serem usadas na View
Local oStrB9P:= FWFormStruct(2, 'B9P', { |cCampo| PLSAB9P806(cCampo) } )
Local oStrB9Q:= FWFormStruct(2, 'B9Q', { |cCampo| PLSAB9Q806(cCampo) } )
Local oStrB9R:= FWFormStruct(2, 'B9R', { |cCampo| PLSAB9R806(cCampo) } )
Local oStrB9V:= FWFormStruct(2, 'B9V', { |cCampo| PLSAB9V806(cCampo) } )
Local oStrObs:= FWFormStruct(2, 'B9P', { |cCampo| !PLSAOBS806(cCampo) } )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados ser� utilizado

oView:AddField('ViewB9P' , oStrB9P,'MasterB9P' ) // Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)

oView:AddGrid( 'ViewB9Q' , oStrB9Q,'B9QDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB9R' , oStrB9R,'B9RDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB9V' , oStrB9V,'B9VDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddField( 'ViewOBS' , oStrObs,'MasterB9P' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)

oView:AddIncrementField( 'ViewB9Q' , 'B9Q_CODSEQ') //Adiciona Campo incremental na View
oView:AddIncrementField( 'ViewB9R' , 'B9R_CODSEQ') //Adiciona Campo incremental na View
oView:AddIncrementField( 'ViewB9V' , 'B9V_CODSEQ') //Adiciona Campo incremental da View

oView:CreateHorizontalBox( 'SUPERIOR' , 100,,, 'ABA', 'T1' ) // Cria um "box" horizontal para receber cada elemento da view e Associa � Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR1', 025,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa � Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR2', 025,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa � Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR3', 025,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa � Aba Correspondente
oView:CreateHorizontalBox( 'INFERIOR4', 025,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa � Aba Correspondente

oView:EnableTitleView( 'ViewB9Q', STR0004 /*'Especialidades'*/				) //Atribui t�tulo para a View
oView:EnableTitleView( 'ViewB9R', STR0005 /*'Servi�os'		*/				) //Atribui t�tulo para a View
oView:EnableTitleView( 'ViewB9V', STR0006 /*'Endere�os de Atendimento'*/	) //Atribui t�tulo para a View
oView:EnableTitleView( 'ViewOBS', STR0007 /*'Observa��es'		*/			) //Atribui t�tulo para a View

oView:SetOwnerView('ViewB9P','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView('ViewB9V','INFERIOR1') // Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView('ViewB9Q','INFERIOR2') // Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView('ViewB9R','INFERIOR3') // Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView('ViewOBS','INFERIOR4') // Relaciona o identificador (ID) da View com o "box" para exibi��o

oView:AddUserButton(STR0003/*'Conhecimento'*/,"", { |oView| PLS806BAN() }) //Cria o bot�o de ocnhecimento na View

oView:SetFieldAction('B9P_PROVCT', { |oView| PLS806CCRE(oView)}) //Gera alerta ao informar "Providenciar Contrato = Sim"
oView:SetFieldAction('B9P_DATAAG', { |oView| PLS806DTAG(oView)}) //Gera alerta ao cadastrar mais d euma visita para o agente na mesma data
oView:SetFieldAction('B9V_CEP'   , { |oModel| PLS806CEP(oModel)})  //Preenche os campos correspondentes ao digitar o CEP
oView:SetFieldAction('B9V_TIPEST', { |oModel| PLS806Mem1(oModel)}) //Passa o valor preenchido na Grid para a vari�vel de mem�ria

oStrB9P:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '1')
oStrB9Q:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
oStrB9V:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
oStrB9R:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')
oStrObs:SetProperty( '*', MVC_VIEW_FOLDER_NUMBER, '2')

//Ajusta T�tulos dos campos para melhor uso do sistema
oStrB9P:SetProperty( 'B9P_CEMIGS', MVC_VIEW_TITULO, STR0039 /*'Conhece a '*/ + AllTrim(POSICIONE("BA0",1,XFILIAL("BA0")+PLSINTPAD(),"BA0_NOMINT")) + STR0040 /*"?"*/)
oStrB9P:SetProperty( 'B9P_AGENTE', MVC_VIEW_TITULO, STR0041 /*'C�digo do Agente'*/)
oStrB9P:SetProperty( 'B9P_CRMNUM', MVC_VIEW_TITULO, STR0042 /*'N�mero do CRM'*/)
oStrB9P:SetProperty( 'B9P_DATAAG', MVC_VIEW_TITULO, STR0043 /*'Data do Agendada'*/)
oStrB9P:SetProperty( 'B9P_HORAAG', MVC_VIEW_TITULO, STR0044 /*'Hor�rio Agendado'*/)
oStrB9P:SetProperty( 'B9P_DATAVI', MVC_VIEW_TITULO, STR0045 /*'Data da Visita'*/)
oStrB9P:SetProperty( 'B9P_HORAVI', MVC_VIEW_TITULO, STR0046 /*'Hor�rio da Visita'*/)
oStrB9P:SetProperty( 'B9P_NOMCON', MVC_VIEW_TITULO, STR0047 /*'Nome do Contato'*/)
oStrB9P:SetProperty( 'B9P_DESVIS', MVC_VIEW_TITULO, STR0048 /*'Descri��o do Motivo da Visita'*/)
oStrB9P:SetProperty( 'B9P_DESOBS', MVC_VIEW_TITULO, STR0049 /*'Observa��o Padr�o'*/)
oStrB9P:SetProperty( 'B9P_CODSOL', MVC_VIEW_TITULO, STR0050 /*'C�digo do solicitante'*/)
oStrB9P:SetProperty( 'B9P_REVNEG', MVC_VIEW_TITULO, STR0051 /*'Revisita de Negocia��o'*/)
oStrB9P:SetProperty( 'B9P_INTCON', MVC_VIEW_TITULO, STR0052 /*'Interesse no conv�nio?'*/)
oStrB9P:SetProperty( 'B9P_PROVCT', MVC_VIEW_TITULO, STR0053 /*'Providenciar Contrato?'*/)
oStrB9P:SetProperty( 'B9P_FCAPTA', MVC_VIEW_TITULO, STR0054 /*'Forma de Capta��o'*/)

//Impede a edi��o do campo (ser� preenchido por consulta F3, nesta rotina)
oStrB9V:SetProperty( 'B9V_CODLOG', MVC_VIEW_CANCHANGE, .F.)
oStrB9V:SetProperty( 'B9V_CODCID', MVC_VIEW_CANCHANGE, .F.)
oStrB9V:SetProperty( 'B9V_ENDER' , MVC_VIEW_CANCHANGE, .F.)
oStrB9V:SetProperty( 'B9V_CODSEQ', MVC_VIEW_CANCHANGE, .F.)
oStrB9V:SetProperty( 'B9V_BAIRRO', MVC_VIEW_CANCHANGE, .F.)

//Passa o CEP para o in�cio da Grid
oStrB9V:SetProperty( 'B9V_CEP', MVC_VIEW_ORDEM, '02')

oView:CreateFolder( 'ABA' ) //Cria estrutura de abas

oView:AddSheet( 'ABA', 'T1', STR0008 /*'Formul�rio Visita'*/) //Cria Primeira aba (Tabela B9P)
oView:AddSheet( 'ABA', 'T2', STR0009 /*'Dados Prestador'*/  ) //Cria Segunda aba (Tabelas B9V, B9R, B9Q e Campo B9P_OBSERV)

//Adiciona a Consulta padr�o ao campo
oStrB9V:SetProperty( 'B9V_CEP', MVC_VIEW_LOOKUP, 'B9VCEP')

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAOBS806
Tratamento para separar o campo de Observa��o da estrutura Mestre e coloc�-lo no detalhe correto.
@author Oscar Zanin
@since 13/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAOBS806 (cCampo)

Local lRet	:= .T.

If cCampo == "B9P_OBSERV"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA806OK
Validar Inclus�o da Visita
@author Oscar Zanin
@since 14/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA806OK(oModel)

LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9P' )
LOCAL cCrmNum  		:= oModelDetail:GetValue('B9P_CRMNUM')
LOCAL cCrmEst			:= oModelDetail:GetValue('B9P_CRMEST')
LOCAL cCodInt			:= PLSINTPAD()
LOCAL nOpc				:= oModel:GetOperation()
Local cIntCon			:= oModelDetail:GetValue('B9P_INTCON')
Local cProvCt			:= oModelDetail:GetValue('B9P_PROVCT')
Local cGerouS			:= oModelDetail:GetValue('B9P_GEROUS')

//Verifica se h� linhas de endere�o deletadas e deleta as especialidades e servi�os relacionados
PLS806VDEL(oModel)

lRet := PLS806OBR1(oModel)

If (nOpc == 3) //Inclus�o

	PLSCPRO806(oModel, cCrmNum, cCrmEst, cCodInt) //Atribui o c�digo do Prospect

EndIf

If (nOpc <> 5) .AND. (nOpc <> 4) //N�o Exclus�o e N�o Altera��o

	B9P->(DbSetOrder(3)) // B9P_FILIAL + B9P_CODINT + B9P_CRMNUM + B9P_CRMEST

	If ((B9P->(MsSeek(XFilial("B9P") + cCodInt + cCrmNum + cCrmEst))) .AND. (M->(B9P_PRICON) == "1"))
		cMsg := STR0010 //"N�o � o Primeiro Contato, J� foi cadastrado contato anterior com o Prospect!"
		Help( ,, 'HELP',, cMsg, 1, 0)
		lRet := .F.
	EndIf

	If (!(B9P->(MsSeek(XFilial("B9P") + cCodInt + cCrmNum + cCrmEst))) .AND. (M->(B9P_REVNEG) == "1"))
		cMsg := STR0011 //"� o primeiro contato cadastrado!"
		Help( ,, 'HELP',, cMsg, 1, 0)
		lRet := .F.
	EndIf

EndIf

If (nOpc <> 5) //N�o Exclus�o

	If ( cIntCon == "0" ) .AND. (M->B9P_PROVCT) == "1"

		cMsg := STR0012 //"Verificar os campos Interesse Conv�nio e Providenciar Contrato!"
		Help( ,, 'HELP',, cMsg, 1, 0)
		lRet := .F.

	EndIf

	If ((cProvCt == "1") .AND. (lRet == .T.) .AND. !(cGerouS == "1"))

		PLS806CRED(oModel, cCodInt)
	EndIf 
	// retirados os elseifs que tinham aqui pois os campos ja bloqueados pelo MVC_WHEN j� barram altera��o quando gerou asolicita��o de credenciamento
EndIf

If (nOpc == 5) //Exclus�o

	If ( cGerous == "1")

		cMsg := STR0058 //"Foi gerada uma solicita��o de Credenciamento para este Registro, imposs�vel apag�-lo"
		MsgInfo(cMsg, STR0030 /*"Aten��o"*/)
		lRet := .F.

	EndIf
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCPRO806
Prenche o Campo B9P_CODPRO. Caso seja a primeira visita, Gera o c�digo do Prospect.
@author Oscar Zanin
@since 15/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCPRO806 (oModel, cCrmNum, cCrmEst, cCodInt)

LOCAL oModelSubDet	:= oModel:GetModel('B9VDetail')
LOCAL oModelDetail	:= oModel:GetModel('MasterB9P')
LOCAL cCodPro		:= ""
Local cCodB9P		:= ""
local nFor 			:= 0

B9P->(DbSetOrder(3)) //B9P_FILIAL + B9P_CODINT + B9P_CRMNUM + B9P_CRMEST

//Verifica Se o Prospect j� foi cadastrado. Caso Sim, atribui o n�mero correspondente, caso N�o, gera o novo n�mero
If B9P->(MsSeek(xFilial("B9P") + cCodInt + cCRMNum + Space(TamSX3("B9P_CRMNUM")[1] - Len(cCRMNUM)) + cCRMEst))

	cCodPro := B9P->(B9P_CODPRO)
	cCodB9P := B9P->(B9P_CODB9P)

	If	cCodPro == Space(TamSX3("B9P_CODPRO")[1])

		cCodPro := 'P' + StrZero(1, (Len(Space(TamSX3("B9P_CODPRO")[1])) - 1))

	ElseIf !( AllTrim(cCodB9P) == "" )

		cCodPro := cCodB9P

	EndIf

Else

	B9P->(DbSetOrder(2)) //B9P_FILIAL + B9P_CODINT + B9P_CODPRO
	B9P->(MsSeek(xFilial("B9P") + cCodInt))
	//Busca o �ltimo CODPRO cadastrado
	While(!B9P->(EOF()) .AND. B9P->(B9P_FILIAL) == xFilial("B9P") .AND. B9P->(B9P_CODINT) == cCodInt)
		cCodPro	:=	B9P->(B9P_CODPRO)
		B9P->(DbSkip())
	End

	B9P->(DbSetOrder(6)) //B9P_FILIAL + B9P_CODINT + B9P_CODB9P
	B9P->(MsSeek(xFilial("B9P") + cCodInt))
	//Busca o �ltimo CODB9P cadastrado
	While(!B9P->(EOF()) .AND. B9P->(B9P_FILIAL) == xFilial("B9P") .AND. B9P->(B9P_CODINT) == cCodInt)
		cCodB9P	:=	B9P->(B9P_CODB9P)
		B9P->(DbSkip())
	End

	If ( Right(cCodPro, 5) < Right(cCodB9P, 5) )//Se o �ltimo CodB9P for maior, atribui ele pra cCodPro,
													   //Para n�o utilizar CodPro repetido.

		cCodPro := cCodB9P

	EndIf

	//Incrementa e formata o resultado
	cCodPro := 'P' + StrZero(Val(Right(cCodPro, Len(Space(TamSX3("B9P_CODPRO")[1])) - 1)) + 1, Len(Space(TamSX3("B9P_CODPRO")[1])) - 1)

EndIf

oModelDetail:SetValue('B9P_CODPRO', cCodPro) //Atribui Valor ao Model da B9P
//S�o grids e posso ter v�rios itens, devo percorrer e preencher todos, para a "integridade" ......
for nFor := 1 to oModelSubDet:Length()
	oModelSubDet:GoLine(nFor)
	oModelSubDet:SetValue('B9V_CODPRO', cCodPro)
	oModelSubDet:SetValue('B9V_SEQB9V', oModelDetail:getValue('B9P_SEQVIS'))
next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806BAN
Banco de Conhecimento
@author Oscar Zanin
@since 20/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806BAN()

LOCAL aAreaB9W		:= B9P->(GetArea())
LOCAL cQuery			:= ""
LOCAL cIndex			:= ""
LOCAL cChaveInt  		:= B9P->(B9P_CODINT) + B9P->(B9P_CODPRO)

Private aRotina 	:= {}

aRotina := {{STR0009 /*"Conhecimento"*/,'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{STR0019 /*"Inclus�o R�pida"*/,'PLSDOcs',0,3}}

B9P->( DbSetOrder(2) ) //B9P_FILIAL + B9P_CODPRO
B9P->( MsSeek( xFilial("B9P") + cChaveInt ) )

cIndex := CriaTrab(NIL,.F.)
cQuery := "B9P_FILIAL == '" + xFilial("B9P") + "' "
cQuery += " .AND. B9P_CODPRO == '" + B9P->B9P_CODPRO + "' "

IndRegua("B9P",cIndex,"B9P_FILIAL+B9P_CODINT+B9P_CODPRO",,cQuery)

If B9P->(!Eof())
	MsDocument( "B9P", B9P->( RecNo() ), 2 )
EndIf

RetIndex( "B9P" )
dbClearFilter()
FErase( cIndex+OrdBagExt() )
RestArea(aAreaB9W)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806CRED
Gera solicita��o de credenciamento
@author Oscar Zanin
@since 20/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806CRED(oModel, cCodInt)

Local oModelDetail := oModel:GetModel( 'MasterB9P' )
Local oModelB9V    := oModel:GetModel( 'B9VDetail' )
Local oModelB9Q    := oModel:GetModel( 'B9QDetail' )
Local oModelB9R    := oModel:GetModel( 'B9RDetail' )
Local cPrestador	 := oModelDetail:GetValue('B9P_PRESTA')
Local cCRMNum		 := oModelDetail:GetValue('B9P_CRMNUM')
Local cCRMEst		 := oModelDetail:GetValue('B9P_CRMEST')
Local cCPFCNPJ	 := oModelDetail:GetValue('B9P_CPFCGC')
Local cTelcon		 := oModelDetail:GetValue('B9P_DESCON')
Local cEmail		 := oModelDetail:GetValue('B9P_EMAIL')
Local cFCapta		 := oModelDetail:GetValue('B9P_FCAPTA')
Local cGera	 	 := "1"
Local cProt		 := ""
Local cMes			 := ""
Local cAno			 := ""
Local cCodB9Y		 := ""
Local lCadastra	 := .T.
Local cMsg			 := ""
Local cCodProAnt 	 := oModelDetail:GetValue('B9P_CODPRO')

B9Y->(DbSetOrder(2))		//Operadora + CRM + Status do Credenciamento

If (B9Y->(MsSeek(xFilial("B9P") + cCodInt + cCRMNum))) 	//Verifica se o CRM j� foi cadastrado
	If B9Y->(B9Y_STCRED) <> "4"			//Caso haja registro, verifica se foi indeferido
		lCadastra := .F.
	EndIf
EndIf

If lCadastra					//Se Ok at� aqui, faz a pr�xima verifica��o
	B9Y->(DbSetOrder(3))		//Operadora + CPF/CNPJ + Status do Credenciamento
	If !(Empty(cCPFCNPJ))	//Verifica se foi informado o CPF/CNPJ
		If (B9Y->(MsSeek(xFilial("B9P") + cCodInt + cCPFCNPJ)))		//Verifica se o CNPJ/CPF j� foi cadastrado
			If B9Y->(B9Y_STCRED) <> "4"				//Caso haja registro, verifica se foi indeferido
				lCadastra := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lCadastra

	lCadastra := .F.

	BEGIN TRANSACTION

	cCodB9Y     := GetSXENum("B9Y", "B9Y_CODIGO")
	cMes        := ALLTRIM(STRZERO(Month(Date()), 2))
	cAno        := SUBSTR(ALLTRIM(STR(Year(Date()))), -2)
	cProt       := cMes + cAno + AllTrim(cCodB9Y)

	//Grava a solicita��o de credenciamento
	B9Y->(RecLock("B9Y",.T.))

	B9Y->B9Y_FILIAL := xFilial("B9P")
	B9Y->B9Y_CODIGO := cCodB9Y
	B9Y->B9Y_NOME   := cPrestador
	B9Y->B9Y_CRMNUM := cCRMNum
	B9Y->B9Y_CRMEST := cCRMEst
	B9Y->B9Y_CPFCGC := cCPFCNPJ
	B9Y->B9Y_TEL    := cTelcon
	B9Y->B9Y_EMAIL  := cEmail
	B9Y->B9Y_FCAPTA := cFCapta
	B9Y->B9Y_STCRED := "1"
	B9Y->B9Y_CODINT := cCodInt
	B9Y->B9Y_NROPRO := cProt
	B9Y->B9Y_DATAIN := dDataBase
	B9Y->B9Y_ROTINA := "1" //"1" = Registro Proveniente da rotina de visita de Capta��o

	B9Y->(MsUnLock())

	ConfirmSX8()

	lCadastra := .T.

	END TRANSACTION

EndIf

If lCadastra

	cMsg := STR0013 //"Solicita��o de Credenciamento Criada!"
	MsgInfo(cMsg, STR0014 /*"Aviso"*/)

	//Se deu tudo certo a grava��o, ent�o foi gerada uma solicita��o de credenciamento..
	//Por�m.. somente os Dados da B9P foram gravados na B9Y e eles tem registros correspondentes
	//na B9V, B9Q e B9R, abaixo n�s resolvemos esse problema do relacionamento, sem perder informa��es
	//ou ter que cadastrar em duplicidade a informa��o.
	oModelDetail:SetValue('B9P_CODB9P', cCodProAnt) 	//grava o c�digo antigo da B9P
	oModelDetail:SetValue('B9P_CODPRO', cCodB9Y)		//passa o c�digo da B9Y para o CODPRO na B9P

	oModelB9V:SetValue('B9V_CODPRO', cCodB9Y)			//	altera os c�digos relacionados na B9V
	oModelB9Q:SetValue('B9Q_CODPRO', cCodB9Y)			//	B9Q
	oModelB9R:SetValue('B9R_CODPRO', cCodB9Y)			// 	e B9R

	//Altera o cadastro para constar que foi gerado o credenciamento e ativar as travas correlatas � isso
	oModelDetail:SetValue('B9P_GEROUS', cGera)

else

	cMsg := STR0055 //"N�o foi gerada a solicita��o de credenciamento!"
	MsgInfo(cMsg, STR0014 /*"Aviso"*/)

EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806TEMP
Calcula o tempo de forma��o. Esta fun��o � utilizada no gatilho de campos
para mostrar o tempo decorrido entre a data informada e a data atual.
@author Oscar Zanin
@since 20/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806TEMP(dCampo)
Local dDataForm	:=	dCampo
Local dDataAtu	:=	Date()
Local nDifTime	:= 0
Local nAnos		:= 0
Local nMeses		:= 0
Local nDias		:= 0
Local cAnos		:= ""
Local cMeses		:= ""
Local cDias		:= ""
Local cTempo		:= ""

nDifTime := dDataAtu - dDataForm //Calcula a diferen�a de tempo entre as datas (em dias)

nAnos  := INT(  nDifTime / 365)	//Calcula a quantidade de anos inteiros
nMeses := INT( (nDifTime - (nAnos * 365)) / 365 * 12 ) //Subtrae os dias que formaram o ano da quantidade total e calcula os meses inteiros
nDias  := INT(  nDifTime - (nMeses / 12 * 365) - (nAnos * 365)) //Subtrae os dias dos anos e meses inteiros e calcula a quantidade de dias

//Formata os Resultados
cAnos  := STRZERO(nAnos, 2)
cMeses := STRZERO(nMeses, 2)
cDias	:= STRZERO(nDias, 2)

//Verifica se Existe data digitada e formata o resultado que ser� apresentado ao usu�rio
If !(Empty(M->dCampo))

	If nAnos == 1
		cTempo := cAnos + STR0021 /*" Ano"*/ + STR0023 /*","*/
	Else
		cTempo := cAnos + STR0022 /*" Anos"*/ + STR0023 /*","*/
	EndIf

	If nMeses == 1
		cTempo := cTempo + cMeses + STR0024 /*" M�s"*/ + STR0025 /*" e "*/
	Else
		cTempo := cTempo + cMeses + STR0026 /*" Meses"*/ + STR0025 /*" e "*/
	EndIf

	If nDias == 1
		cTempo := cTempo + cDias + STR0027 /*" Dia."*/
	Else
		cTempo := cTempo + cDias + STR0028 /*" Dias."*/
	EndIf

Else

	cTempo := ""

EndIf

Return (cTempo)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806CCRE
Verifica se foi informado para providenciar contrato (Credenciamento) do Prestador
@author Oscar Zanin
@since 22/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806CCRE(oView)

Local oViewDetail	:= oView:GetModel( 'MasterB9P' )
Local lRet			:= .T.
Local cContrato 	:= oViewDetail:GetValue('B9P_PROVCT')

If cContrato == "1"

	lRet := .F.
	cMsg := STR0029 	//"Aten��o! Ao informar 'Sim' para este campo, ser� gerada uma solicita��o de Credenciamento!"
						//" Ao gerar a Solicita��o, n�o ser� poss�vel realizar altera��es!"
	MsgInfo( cMsg, STR0030 /*'Aten��o!'*/)

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806DTAG
Verifica se foi informado mais de uma visita para o Agente, na mesma data
@author Oscar Zanin
@since 23/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806DTAG(oView)

Local oViewDetail	:= oView:GetModel( 'MasterB9P' )
Local cDataAg 	:= DToS(oViewDetail:GetValue('B9P_DATAAG'))
Local cAgente		:= oViewDetail:GetValue('B9P_AGENTE')
Local cCodInt		:= PLSINTPAD()

B9P->(DbSetOrder(5)) //B9P_FILIAL + B9P_CODINT + B9P_AGENTE + B9P_DATAAG

If (B9P->(MsSeek(XFilial("B9P") + cCodInt + cAgente + cDataAg)))
	cMsg := STR0031 //"O Agente Informado j� possui outra Visita cadastrada para a mesma data!"
	MsgInfo( cMsg, STR0030 /*'Aten��o!'*/)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9V806
Tratamento para ajustar os campos a ser utilizados da tabela B9V.
@author Oscar Zanin
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9V806(cCampo)

Local lRet	:= .T.

If cCampo == "B9V_EMAIL " //N�o para o e-mail
	lRet := .F.
EndIf

If cCampo == "B9V_CONTAT" //N�o para o contato
	lRet := .F.
EndIf

If cCampo == "B9V_CODPRO" //N�o para o C�digo do Prospect
	lRet := .F.
EndIf

If cCampo == "B9V_CODPRE" //N�o para o C�digo do Prestador
	lRet := .F.
EndIf

If cCampo == "B9V_CODINT" //N�o para o C�digo da Operadora
	lRet := .F.
EndIf

If cCampo == "B9V_DESINT" //N�o para a Descri��o da operadora
	lRet := .F.
EndIf

If cCampo == "B9V_SEQB9V" //N�o para o Sequencial da tabela
	lRet := .F.
EndIf

If cCampo == "B9V_TEL   " //N�o para o Telefone
	lRet := .F.
EndIf

If cCampo == "B9V_DEFERE" //Campo da Rotina de Credenciamento
	lRet := .F.
EndIf

If cCampo == "B9V_TIPLOC" //Campo da Rotina de Credenciamento
	lRet := .F.
EndIf

If cCampo == "B9V_DESLOC" //Campo da Rotina de Credenciamento
	lRet := .F.
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9Q806
Tratamento para ajustar os campos a ser utilizados da tabela B9Q.
@author Oscar Zanin
@since 29/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9Q806(cCampo)

Local lRet	:= .F.

If cCampo == "B9Q_CODESP" //Sim para C�digo da Especialidade
	lRet := .T.
EndIf

If cCampo == "B9Q_DESESP" //Sim para Descri��o da Especialidade
	lRet := .T.
EndIf

If cCampo == "B9Q_CODSEQ" //Sim para sequencial da especialidade
	lRet := .T.
EndIf

If cCampo == "B9Q_TEMFOR" //Sim para sequencial da especialidade
	lRet := .T.
EndIf

If cCampo == "B9Q_DESTEM" //Sim para sequencial da especialidade
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806Zero
Tratamento para ajustar os campos com os Zeros � esquerda, sem precisar digit�-los
@author Oscar Zanin
@since 02/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806Zero(cCampo)
Local nTStr	:= 0		//Tamanho do campo
Local cCStr	:= ""		//String digitada
Local cRetorna:= ""		//Retorno da fun��o

If !(Empty(cCampo))

	cCStr	:= cCampo					//Passa o par�metro para uma vari�vel
	nTStr	:= Len(cCampo)			//Verifica o tamanho total
	cCstr	:= AllTrim(cCstr)  		//Elimina espa�os extras

	If ValType(cCStr) == "N"			//Trata o tipo da vari�vel recebida e Formata retorno
		cCampo := StrZero(cCampo, nTStr)
	Else
		cRetorna := StrZero(Val(cCStr), nTStr)
	EndIf

EndIf

Return (cRetorna)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806VDEL
Tratamento para deletar registros de especialiade e servi�os, caso seja
deletado o registro do endere�o correspondente
@author Oscar Zanin
@since 05/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806VDEL(oModel)

Local oB9V		:= oModel:GetModel( 'B9VDetail' ) //Endere�o
Local oB9Q		:= oModel:GetModel( 'B9QDetail' ) //Especialidade
Local oB9R		:= oModel:GetModel( 'B9RDetail' ) //Servi�o
Local nI		:= 0
Local nJ		:= 0
Local nK		:= 0

For nI := 1 To oB9V:Length() //Verifica quantas linhas tem o Model de Endere�os
	oB9V:GoLine( nI ) //Vai para a primeira linha

	If oB9V:IsDeleted() //Se o endere�o foi deletado, excl�i as especialidades e servi�os vinculados

		For nJ := 1 To oB9Q:Length() //Exclus�o das Especialidades sem endere�o correspondente
			oB9Q:GoLine( nJ )
			If oB9Q:GetValue( 'B9Q_CODLOC' ) == oB9V:GetValue('B9V_CODSEQ')
				oB9Q:DeleteLine()
			EndIf
		Next

		For nK	:= 1 To oB9R:Length() //Exclus�o dos Servi�os sem endere�o correspondente
			oB9R:GoLine( nK )
			If oB9R:GetValue( 'B9R_CODLOC' ) == oB9V:GetValue( 'B9V_CODSEQ' )
				oB9R:DeleteLine()
			EndIf
		Next

	EndIf
Next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806VTPV
Valida se o Motivo de visita informado n�o � referente a Relacionamento
@author Oscar Zanin
@since 10/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806VTPV(cCampo)
Local lRet 	:= .F.
Local cCodInt	:= PLSINTPAD()
Local cMotivo := PLS806Zero(cCampo)

B9L->(DbSetOrder(7))

If B9L->(MsSeek(xFilial("B9P") + cCodInt + cMotivo + "0"))

	lRet := .T.

EndIf

If B9L->(MsSeek(xFilial("B9P") + cCodInt + cMotivo + "2"))

	lRet := .T.

EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806WHEN
Impede a edi��o do cadastro, ap�s a gera��o da solicita��o de credenciamento
@author Oscar Zanin
@since 02/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806WHEN()

Local cGerouCred		:= M->B9P_GEROUS
Local lRet 			:= .F.

If cGerouCred == '0'

	lRet := .T.

EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806CEP
Preenche os campos correspondentes ao CEP na B9V
@author Oscar Zanin
@since 06/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806CEP(oView)

Local cTipLog := ""
Local cEnd		:= ""
Local cCodMun := ""
Local cBairro	:= ""

Local cMunici	:= ""
Local cLogra	:= ""

BC9->(DbSetOrder(1))

//Limpa os valores, caso o valor esteja Vazio
If Vazio(oView:GetModel("B9VDetail"):GetValue("B9V_CEP"))

	oView:GetModel("B9VDetail"):LoadValue("B9V_CODLOG" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_ENDER"  , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CODCID" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_BAIRRO" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CIDADE" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_DESLOG" , "")
	oView:getmodel("B9VDetail"):LoadValue("B0V_EST"    , "")

//Carrega os valores, caso exista o c�digo
ElseIf BC9->(MsSeek(xFilial("BC9") + oView:GetModel("B9VDetail"):GetValue("B9V_CEP")))

	cTipLog := PLS806Zero(BC9->BC9_TIPLOG)
	cEnd	 := AllTrim(BC9->BC9_END)
	cCodMun := PLS806Zero(BC9->BC9_CODMUN)
	cBairro := AllTrim(BC9->BC9_BAIRRO)
	cEst	 := AllTrim(BC9->BC9_EST)

	cMunici := POSICIONE("BID",1,XFILIAL("BID")+cCodMun,"BID_DESCRI")
	cLogra	 := ALLTRIM(POSICIONE("B18",1,XFILIAL("B18")+cTipLog,'B18_DESCRI'))

	oView:GetModel("B9VDetail"):SetValue("B9V_CODLOG" , cTipLog)
	oView:GetModel("B9VDetail"):SetValue("B9V_ENDER"  , cEnd)
	oView:GetModel("B9VDetail"):SetValue("B9V_CODCID" , cCodMun)
	oView:GetModel("B9VDetail"):SetValue("B9V_BAIRRO" , cBairro)
	oView:GetModel("B9VDetail"):SetValue("B9V_DESLOG" , cLogra)
	oView:GetModel("B9VDetail"):SetValue("B9V_CIDADE" , cMunici)
	oView:getModel("B9VDetail"):setValue("B9V_EST"	 , cEst)

//Limpa os demais campos, caso n�o atenda os anteriores
Else

	oView:GetModel("B9VDetail"):LoadValue("B9V_CODLOG" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_ENDER"  , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CODCID" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_BAIRRO" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_CIDADE" , "")
	oView:GetModel("B9VDetail"):LoadValue("B9V_DESLOG" , "")
	oView:getModel("B9VDetail"):LoadValue("B9V_EST",   , "")

EndIF
oView:Refresh()

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806OBR1
Valida se, caso foi preenchida a data da visita, tamb�m foi preenchida a hora e vice-versa.
@author Oscar Zanin
@since 10/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806OBR1(oModel)
Local oModelB9P 	:= oModel:getModel("MasterB9P")
Local cDataVi   	:= Alltrim( DToS( oModelB9P:GetValue("B9P_DATAVI") ) )
Local cHoraVi		:= AllTrim( oModelB9P:Getvalue("B9P_HORAVI") )
Local lRet			:= .T.

//Se a Data ou a Hora estiverem preenchidas
If !(cDataVi == "") .OR. !(cHoraVi == "")

	If ( cHoraVi == "" ) //Se a Hora est� em branco

		MsgInfo(STR0056 /*"Foi informada a data da realiza��o da visita, mas n�o o hor�rio, por favor, verifique o preenchimento!"*/, STR0030 /*"Aten��o!"*/)
		lRet := .F.

	EndIf

	If ( cDataVi == "" ) //Se a Data est� em branco

		MsgInfo(STR0057 /*"Foi informado o hor�rio da realiza��o da visita, mas n�o a data, por favor, verifique o preenchimento!"*/, STR0030 /*"Aten��o!"*/)
		lRet := .F.

	EndIf
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9P806
Tratamento para separar os campos que n�o ir�o para a View
@author Oscar Zanin
@since 20/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9P806 (cCampo)

Local lRet	:= .T.

If cCampo == "B9P_OBSERV"
	lRet := .F.
EndIf

If cCampo == "B9P_SEQVIS"
	lRet := .F.
EndIf

If cCampo == "B9P_CODPRO"
	lRet := .F.
EndIf

If cCampo == "B9P_GEROUS"
	lRet := .F.
EndIf

If cCampo == "B9P_CODINT"
	lRet := .F.
EndIf

If cCampo == "B9P_DESINT"
	lRet := .F.
EndIf

If cCampo == "B9P_CODB9P"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA806SXE
Fun��o d� rollback no sxe reservado
@author Oscar Zanin
@since 25/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA806SXE(oModel)

//Somente para a opera��o de Inclus�o
if oModel:getOperation() == MODEL_OPERATION_INSERT
	ROLLBACKSXE()
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9R806
Separar os campos a Exibir na View
@author Oscar Zanin
@since 20/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9R806(cCampo)

Local lRet := .F.

If cCampo == "B9R_CODSER" //Sim para C�digo do Servi�o
	lRet := .T.
EndIf
If cCampo == "B9R_DESSER" //Sim para Descri��o do Servi�o
	lRet := .T.
EndIf
If cCampo == "B9R_CODSEQ" //Sim para sequencial do servi�o
	lRet := .T.
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS806Mem1
Passar o tipo de estabelecimento para a vari�vel de mem�ria
@author Oscar Zanin
@since 20/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS806Mem1(oModel)

Local oB9V		:= oModel:GetModel('B9VDetail')
local cTipEst	:= oB9V:GetValue('B9V_TIPEST')

M->B9V_TIPEST	:= cTipEst

Return
