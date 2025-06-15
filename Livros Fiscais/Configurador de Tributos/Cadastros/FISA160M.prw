#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA160M.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160M()

Esta rotina tem objetivo de realizar o cadastro das
Regras para gera��o do C�digo de receita

@author Rafael oliveira
@since 23/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FISA160M()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ5")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ5")
    oBrowse:SetDescription(STR0001) //Regra para gera��o do C�digo da receita
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Rafael oliveira
@since 23/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160M" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro da regra de c�digo de receita

@author Rafael oliveira
@since 23/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    //Cria��o do objeto do modelo de dados
    Local oModel := Nil

    //Estrutura Pai do cabe�alho da rotina
    Local oCabecalho := FWFormStruct(1, "CJ5")

    //Estrutura Do modelo de Documento
    Local oModDoc := FWFormStruct(1, "CJ7")    

    //Estrutura das UFs
    Local oItens := FWFormStruct(1, "CJ6")
   
    //Valida��o dos Itens    
    Local bValdGrid   := {||PosVldCJ6()}//Valida��o da linha do grid

    //=====================Defini��o de Modelo com formulario e Grid ========================================

    //Instanciando o modelo
    oModel	:=	MPFormModel():New('FISA160M',,{|oModel|ValidForm(oModel) })

    //Atribuindo cabe�alho para o modelo
    oModel:AddFields("FISA160M" ,,oCabecalho)    

    oModel:addGrid("MODELO_DOC", "FISA160M", oModDoc, /*bLinePre*/, bValdGrid, /*bPre*/, /*bPos*/, /*bLoad*/)

    //Atribuindo as Ufs para Grid do modelo
    oModel:addGrid("ITENS","FISA160M",oItens,/*bLinePre*/, /*bLinPosCIR*/, /*bPre*/, /*bPos*/, /*bLoad*/)



    //===================================Propriedades dos campos=============================================

    //Indica que o campo � chave
    oCabecalho:SetProperty('CJ5_CODIGO' , MODEL_FIELD_KEY   , .T. )

    //Valida��o para n�o permitir informar um c�digo da regra que j� exista no sistema (legado)
    oCabecalho:SetProperty('CJ5_CODIGO' , MODEL_FIELD_VALID , {|| ( VldCod(oModel) )})

    //N�o permite alterar codigo quando altera��o
    oCabecalho:SetProperty('CJ5_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation() == MODEL_OPERATION_INSERT) })
    
    //Campos Obrigatorios no Grid
    oItens:SetProperty("CJ6_ESTADO",MODEL_FIELD_OBRIGAT, .T.)    
    oItens:SetProperty("CJ6_CODREC",MODEL_FIELD_OBRIGAT, .T.)

    
    //==================================Defini��es adicionais do modelo ================================================

    //Grid n�o pode ser vazio
    oModel:GetModel('ITENS'):SetOptional(.F.)

    //Grid N�o pode ser vazio
    oModel:GetModel('MODELO_DOC'):SetOptional(.F.)


    //Define para n�o repetir o estado
	oModel:GetModel( "ITENS" ):SetUniqueLine( { "CJ6_ESTADO" } )	

    //Define para n�o repetir a Especie
    oModel:GetModel( "MODELO_DOC" ):SetUniqueLine( { "CJ7_ESPECI" } )	


    //Define o valor maximo de linhas do grid
    oModel:GetModel('ITENS'):SetMaxLine(9999)

    //Define o valor maximo de linhas do grid
    oModel:GetModel('MODELO_DOC'):SetMaxLine(9999)

    //Relacionamento das tabelas.	
	oModel:SetRelation("ITENS"	, {{ "CJ6_FILIAL", "xFilial('CJ6')"} ,{ "CJ6_CODIGO" ,"CJ5_CODIGO" }} , CJ6->( IndexKey(1) ))

    oModel:SetRelation("MODELO_DOC"	, {{ "CJ7_FILIAL", "xFilial('CJ7')"} ,{ "CJ7_CODIGO" ,"CJ5_CODIGO" }} , CJ7->( IndexKey(1) ))

    //Adicionando descri��o ao modelo
    oModel:SetDescription(STR0001) //"Regra para gera��o do C�digo da receita"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Rafael oliveira    
@since 23/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    //Cria��o do objeto do modelo de dados da Interface do Cadastro
    Local oModel     := FWLoadModel( "FISA160M" )

    //Cria��o da estrutura de dados utilizada na interface do cadastro
    Local oCabecalho := FWFormStruct(2, "CJ5")
    Local oItens     := FWFormStruct(2, "CJ6")
    Local oModDoc    := FWFormStruct(2, "CJ7")    
    Local oView      := Nil

    oView := FWFormView():New()
    oView:SetModel( oModel )

    
    //Adiciona na grid um controle de FormFields
    oView:AddField("VIEW_CABECALHO" , oCabecalho, "FISA160M")
    oView:AddGrid( "VIEW_MODELO_DOC", oModDoc   , "MODELO_DOC" ) 
    oView:AddGrid( "VIEW_ITENS"     , oItens    , "ITENS" ) 

    //Retira da view os campos de ID
    oItens:RemoveField('CJ6_ID')
    oItens:RemoveField('CJ6_CODIGO')    
    oModDoc:RemoveField('CJ7_CODIGO')

    // Cria box visual para separa��o dos elementos em tela.
	oView:createHorizontalBox( "SUPERIOR", 15, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
    oView:createHorizontalBox( "MEIO"    , 30, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:createHorizontalBox( "INFERIOR", 55, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

    //Faz v�nculo do box com a view
    oView:SetOwnerView( 'VIEW_CABECALHO' , 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_MODELO_DOC', 'MEIO'     )
    oView:SetOwnerView( 'VIEW_ITENS'     , 'INFERIOR' )

    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_CABECALHO', STR0003 ) //"Defini��o da Regra"
    oView:EnableTitleView('VIEW_MODELO_DOC', STR0004 ) //"Defini��o da Regra"
    oView:EnableTitleView('VIEW_ITENS', STR0008 ) //"Defini��o de modelos de documento"

    //Altera��o de Titulo dos campos
    oCabecalho:SetProperty("CJ5_CODIGO", MVC_VIEW_TITULO, STR0009) //"C�digo do Tributo"
    oModDoc:SetProperty("CJ7_ESPECI", MVC_VIEW_TITULO, STR0010) //"Modelo do Documento"
    
    oItens:SetProperty('CJ6_REF',MVC_VIEW_COMBOBOX,{'1=Mensal','2=1� Quinzena','3=2� Quinzena','4=1� Dec�ndio','5=2� Dec�ndio','6=3� Dec�ndio'})	

    //Aqui � a defini��o de exibir dois campos por linha
    //oView:SetViewProperty( "VIEW_CABECALHO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )
   
    

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Fun��o que valida se o c�digo da regra

@author Rafael oliveira
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160M',"CJ5_CODIGO")
Local lRet      := .T.

//Procura se j� existe regra com o mesmo c�digo
CJ5->(DbSetOrder(1))
If CJ5->( MsSeek ( xFilial('CJ5') + cCodigo ) )
    Help( ,, 'Help',, STR0005, 1, 0 ) //"C�digo j� cadastrado!"
    return .F.    
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0007, 1, 0 ) // "C�digo n�o pode conter espa�o."
    Return .F.
EndIf

//Permite c�digo v�lido
If Empty(cCodigo)
    Return .T.
EndIF

//Procura se j� existe regra com o mesmo c�digo
F2E->(DbSetOrder(2))
If !F2E->( MsSeek ( xFilial('F2E') + cCodigo ) )
    Help( ,, 'Help',, STR0016, 1, 0 ) //"C�digo j� cadastrado!"
    return .F.    
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CodRec
Fun��o que retorna c�digo da Receita

Parametros:
Tributo
Estado
Modelo de nota

Retorno:
C�digo da receita
Detalhamento
Refer�ncia

@author Rafael oliveira
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------

Function CodRec(cTributo, cEstado, cModelo)

    Local aRet      := ""
    Local cSelect	:= ""
    Local cFrom	    := ""
    Local cjoin	    := ""
    Local cWhere	:= ""
    Local cAliasQry	:= ""

    Default cModelo := ""

    //Query para c�digo da Receita
    cSelect := "DISTINCT CJ6.CJ6_CODREC, CJ6.CJ6_DETALH, CJ6.CJ6_REF, (CASE WHEN CJ6.CJ6_ESTADO = "+ ValToSQL(cEstado) +" THEN 'S' ELSE 'N' END ) ESTADO "

    cFrom   := RetSQLName("CJ5") + " CJ5 "
    cjoin   += "INNER JOIN " + RetSQLName("F2B") + " F2B ON (F2B.F2B_FILIAL = '"+xFilial("F2B")+"' AND CJ5.CJ5_CODIGO = F2B.F2B_TRIB AND F2B_REGRA = " + ValToSQL(cTributo) + "AND F2B.F2B_ALTERA = '2' AND F2B.D_E_L_E_T_ = ' '  ) "
    cjoin   += "INNER JOIN " + RetSQLName("CJ6") + " CJ6 ON (CJ6.CJ6_FILIAL = '"+xFilial("CJ6")+"' AND CJ5.CJ5_CODIGO = CJ6.CJ6_CODIGO AND (CJ6.CJ6_ESTADO = "+ ValToSQL(cEstado) +" OR  CJ6.CJ6_ESTADO = '**') AND CJ6.D_E_L_E_T_ = ' ' ) "  
    cjoin   += "INNER JOIN " + RetSQLName("CJ7") + " CJ7 ON (CJ7.CJ7_FILIAL = '"+xFilial("CJ7")+"' AND CJ5.CJ5_CODIGO = CJ7.CJ7_CODIGO AND (CJ7.CJ7_ESPECI = "+ ValToSQL(cModelo) +" OR  CJ7.CJ7_ESPECI = 'TODOS') AND CJ7.D_E_L_E_T_ = ' ' ) "
    

    cWhere  := "CJ5.CJ5_FILIAL = " + ValToSQL( xFilial("CJ5") ) + " "
    //cWhere  += "AND CJ5.CJ5_CODIGO = " + ValToSQL(cTributo) + " "
    cWhere  += "AND CJ5.D_E_L_E_T_ = ' ' " 


    //prepara as variaveis para BeginSQL
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + cjoin  + "%"
	cWhere  := "%" + cWhere  + "%"    

    //Executa Query
    cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
        ORDER BY
            ESTADO DESC
	EndSQL 

    If !(cAliasQry)->(Eof())        
        aRet := {(cAliasQry)->CJ6_CODREC ,(cAliasQry)->CJ6_DETALH, (cAliasQry)->CJ6_REF}
    Else
        aRet := {" "," "," "}
    Endif 

    //Fecha o Alias antes de sair da fun��o
    dbSelectArea(cAliasQry)
    dbCloseArea()

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160MPOS
Fun��o auxiliar para tratar o inicializador padr�o da descri��o do 
do Produto, pois o campo X3_RELACAO � limitado e n�o cabia 
toda a instru��o necess�ria.

@author Rafael Oliveira
@since 24/09/2020
@version 12.1.31

/*/
//-------------------------------------------------------------------

Function FSA160MPOS()

Local cDescr    := ""
Default cEspeci := Upper(Alltrim(CJ7->CJ7_ESPECI)) 

If !INCLUI 
    If AllTrim(cEspeci) == "TODOS"
        cDescr  := "TODOS OS MODELOS"
    Else
        cDescr  := Posicione("SX5",1,xFilial("SX5")+"42"+CJ7->CJ7_ESPECI,"X5_DESCRI")
    EndIF
EndIF

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Fun��o que valida se o c�digo de regra j� existe

@author Rafael Oliveira
@since 25/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel) 

Local lRet        := .T.
Local cCodigo     := oModel:GetValue('FISA160M','CJ5_CODIGO')
Local nOperation  := oModel:GetOperation()
Local nRecno      := CJ5->(Recno())
Local nRecnoVld   := 0

If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)
	CJ5->(DbSetOrder(1))
	//CJ5_FILIAL, CJ5_CODAJU, CJ5_DTINI
	If CJ5->(DbSeek(xFilial("CJ5")+cCodigo))
		If nOperation == MODEL_OPERATION_UPDATE //Altera��o
			nRecnoVld :=  CJ5->(Recno())
			If nRecnoVld <> nRecno
				Help(" ",1,"Help",,STR0011,1,0)//Registro j� cadastrado
				lRet := .F.
			EndIf
		Else
			Help(" ",1,"Help",,STR0011,1,0)//Registro j� cadastrado
			lRet := .F.
		EndIf
		//Volta Recno posicionado na tela
		CJ5->(DbGoTo(nRecno))
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldCJ6
Fun��o que realiza a valida��o de p�s edi��o da linha do grid dos valores

@Return     lRet    - Booleano  - REtorno com valida��o, .T. pode prosseguir, .F. n�o poder� prosseguir

@author Rafael Oliveira
@since 28/09/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function PosVldCJ6()
Local oModel		:= FWModelActive()
Local oGrid         := oModel:GetModel("MODELO_DOC")
Local nTamGrid	    := oGrid:Length()
Local nLnAtual      := oGrid:Getline()
Local cEsp          := oGrid:GetValue("CJ7_ESPECI")
Local nX            := 0
Local cMsgErro      := ""

For nX := 1 to nTamGrid
    
    //Muda linha do grid
    oGrid:GoLine(nX)    
    
    //Verifico se n�o estou validando a pr�pria linha
    If nLnAtual <> nX .And. !oGrid:IsDeleted() 

        //Verifica se existe duplicidade ou esta usandoestado especifico ou op��o: TODOS
        If (cEsp  == oGrid:GetValue("CJ7_ESPECI")  .OR. AllTrim(cEsp)  == "TODOS" .Or. AllTrim(oGrid:GetValue("CJ7_ESPECI"))  == "TODOS")

            //Mensagem para identificar a linha que est� divergente com a linha atual do grid            
            cMsgErro := STR0012 + AllTrim(cEsp) + STR0013  + AllTrim(oGrid:GetValue("CJ7_ESPECI")) + " )" + CRLF //"O Modelo Atual (" -- ") est� em conflito  com modelo j� cadastrada(: "")"
            
            //Restauro a linha inicial do grid antes de sa�r da fun��o
            oGrid:GoLine(nLnAtual)
            HELP(' ',1, STR0014 ,, cMsgErro ,2,0,,,,,, {STR0015} ) //"Inconsist�ncia de valores" -- "Verifique os Modelos Digitados"
            Return .F.
            

        EndIF

    EndIF

Next nX

Return .T.

