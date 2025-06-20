#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA162.ch"
#Include "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA162()

Cadastro de Regra da aliquota
Esta rotina far� cadastro de Regra da Aliquota

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA162()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F28") 
    dbSelectArea("F28")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F28")
    oBrowse:SetFilterDefault("F28_ALTERA == '2'")
    oBrowse:SetDescription(STR0001) // Cadastro de Regra de Aliquota
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0018 ACTION 'VIEWDEF.FISA162' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0019 ACTION 'VIEWDEF.FISA162' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0020 ACTION 'VIEWDEF.FISA162' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0021 ACTION 'VIEWDEF.FISA162' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0022 ACTION 'VIEWDEF.FISA162' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0023 ACTION 'FSA162Hist'      OPERATION 4 ACCESS 0 //'Hist�rico de Altera��es'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil
Local lCIN := AliasIndic("CIN") .And. FindFunction("xFisFormul")

//Estrutura Pai correspondete a tabela de perfil F28
Local oCabecalho := FWFormStruct(1, "F28" )
Local oFORMULALQ := Iif(lCIN,FWFormStruct(1,"CIN"),nil) 

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA162',/*Pre-Validacao*/,{|oModel|ValidModel(oModel) },{|oModel|FSA162Grava(oModel)})

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA162",,oCabecalho)

//Verifico se tabela CIN existe
If lCIN
    //Atribuindo estruturas para o modelo
    oModel:AddFields("FORMULALQ","FISA162",oFORMULALQ)
EndIF

//Inicializa a variavel
oCabecalho:SetProperty('F28_UFRPER' , MODEL_FIELD_INIT ,{|| 100 } )


//N�o permite alterar o conte�do do campo F20_CODIGO na edi��o
oCabecalho:SetProperty('F28_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oCabecalho:SetProperty('F28_TPALIQ' , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")$"04#06#07") })
oCabecalho:SetProperty('F28_ALIQ'   , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="04") })
oCabecalho:SetProperty('F28_URF'    , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="05") })
oCabecalho:SetProperty('F28_DSURF'  , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="05") })
oCabecalho:SetProperty('F28_UFRPER' , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="05") })

//Valida��o para n�o permitir informar c�digo de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F28_CODIGO' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

If lCIN
    
    //O campo de f�rmula ficar� habilitado, somente ap�s o valor de origem for igual a 06
    //A fun��o Fsa162HFor() indica se deve ou n�o estar habilitado
    oFORMULALQ:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") <> "ZZ" })    
    oFORMULALQ:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })

    oFORMULALQ:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa162HFor() })
    oFORMULALQ:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") == "ZZ" })
    oFORMULALQ:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") == "05" } )

    //Adicionei no valid dos campos abaixo a chamada da fun��o Fsa161HBtn(), para atualizar a f�rmula
    oCabecalho:SetProperty('F28_VALORI' , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_TPALIQ' , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_ALIQ'   , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_URF'    , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_UFRPER' , MODEL_FIELD_VALID, {|| Fsa162Form() })

    //Cria relacionamento entre a tabela F28 e CIN.
    oModel:SetRelation( 'FORMULALQ', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F28_ID'}, {'CIN_TREGRA', "'2 '"}}, CIN->( IndexKey(3)))

EndIF

oModel:SetPrimaryKey( {"F28_FILIAL","F28_CODIGO","F28_ALTERA","F28_ID"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) // Cadastro de Perfil Tribut�rio de Produto

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA162" )
Local lCIN      := AliasIndic("CIN") .And. FindFunction("xFisFormul")

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho:= FWFormStruct(2, "F28")
Local oFormula  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) //Somente adiciona na view da f�rmula o campo CIN_FORMUL
Local oRegra    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB"}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL

Local oView := Nil

oCabecalho:AddGroup( 'GRUPO01', OemToAnsi(STR0003), '', 2 )
oCabecalho:AddGroup( 'GRUPO02', OemToAnsi(STR0004), '', 2 ) // "Tablas"
oCabecalho:AddGroup( 'GRUPO03', OemToAnsi(STR0005), '', 2 ) // "Campos"
oCabecalho:AddGroup( 'GRUPO04', OemToAnsi("Tabela Progressiva"), '', 2 ) // "Campos"

oCabecalho:SetProperty( 'F28_CODIGO'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oCabecalho:SetProperty( 'F28_DESC'      ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oCabecalho:SetProperty( 'F28_VALORI'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oCabecalho:SetProperty( 'F28_TPALIQ'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oCabecalho:SetProperty( 'F28_ALIQ'      ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oCabecalho:SetProperty( 'F28_URF'       ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
oCabecalho:SetProperty( 'F28_DSURF'     ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
oCabecalho:SetProperty( 'F28_UFRPER'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

//Picture do campo c�digo
oCabecalho:SetProperty('F28_CODIGO' , MVC_VIEW_PICT, "@!")

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho  , 'FISA162' )

//Se a tabela CIN existir ent�o dividirei a tela em duas partes, uma para dados cadastrais da regr e outra com detalhamento da f�rmula
If lCIN
    oFormula:SetProperty("CIN_FORMUL"  , MVC_VIEW_CANCHANGE, .F.)

    //Remove o campo da View
    oCabecalho:RemoveField("F28_ID")

    //Cria as views do operando e da f�rmula
    oView:AddField( 'VIEW_FORMULA' , oFormula, 'FORMULALQ')

    //Cria as view do campo regra
    oView:AddField( 'VIEW_REGRA' , oRegra, 'FORMULALQ')

    //Ajuste dos t�tulos dos campos de filtros de f�rmula
    oRegra:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegra:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegra:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na f�rmula")
    oRegra:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    //Ordem dos campos da CIN para realizarem filtros nas f�rmulas
    oRegra:SetProperty("CIN_FILTRO" , MVC_VIEW_ORDEM, "01")
    oRegra:SetProperty("CIN_TRIB"   , MVC_VIEW_ORDEM, "02")
    oRegra:SetProperty("CIN_CONSUL" , MVC_VIEW_ORDEM, "03")
    oRegra:SetProperty("CIN_VAL"    , MVC_VIEW_ORDEM, "04")    

     //Divide a tela em duas pastas
     oView:CreateFolder( 'PASTAS' )
     oView:AddSheet( 'PASTAS', 'ABA01', "Defini��o da Al�quota"       )
     oView:AddSheet( 'PASTAS', 'ABA02', "Detalhamento da F�rmula de C�lculo" )
    
    //Aba da esquerda cheia
     oView:CreateHorizontalBox( 'ESQUERDA', 100,,, 'PASTAS', 'ABA01' ) //Aqui ficar�o todos os componentes de tela que j� estavam na onda 1
    
    //Aba da direita dividida em duas partes horizontais
    oView:CreateHorizontalBox( 'TITULO'              , 30,,.T., 'PASTAS', 'ABA02') //Aqui crio um objeto vazio somente para colocar o t�tulo
    oView:CreateHorizontalBox( 'BOX_SUPERIOR'        , 140,,.T., 'PASTAS', 'ABA02') 
    oView:CreateVerticalBox( 'BOX_SUPERIOR_ESQUERDO' , 600,'BOX_SUPERIOR',.T., 'PASTAS', 'ABA02') //Aqui ficar�o os campos para sele��o das regras a serem adicionadas na f�rmula
    oView:CreateHorizontalBox( 'BOX_INTERMEDIARIO'   , 80,,.T., 'PASTAS', 'ABA02') //Aqui ficar�o os bot�es de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'BOX_INFERIOR'        , 230,,.T., 'PASTAS', 'ABA02') //Aqui ficar� o campo memo de f�rmula
     
    //Painel com os bot�es
    //Adiciono componente da f�rmula, que est� definido por meio da fun��o xFisFormul().
    oView:AddOtherObject("BOTOES", {|oPanel| xFisFormul(oPanel, "FORMULALQ","VIEW_FORMULA","2", "F28_CODIGO", "FISA162", "CIN_CONSUL", "VIEW_REGRA")})

    //Painel vazio para ter o t�tulo da tela
    oView:AddOtherObject("LABEL", {|oPanel| xFisLabel(oPanel)}) 
       
    //Aba da esquerda
    oView:SetOwnerView( 'VIEW_CABECALHO', 'ESQUERDA')   
    
    //T�tulo
    oView:SetOwnerView( 'LABEL'        , 'TITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA'    , 'BOX_SUPERIOR_ESQUERDO')              
    
    //Bot�es para manipular f�rmula
    oView:SetOwnerView( 'BOTOES'        , 'BOX_INTERMEDIARIO')       
    
    //F�rmula
    oView:SetOwnerView( 'VIEW_FORMULA'  , 'BOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um t�tulo para a segunda aba.
    oView:EnableTitleView('LABEL'  , "Composi��o da F�rmula")     

EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Fun��o que valida se o c�digo de perfil cadastrado j� existe

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodAliq 	:= oModel:GetValue ('FISA162',"F28_CODIGO")
Local lRet      := .T.

//Verifico se o perfil j� existe.
//Procura se j� existe regra de al�quota com o mesmo c�digo e ativa
If F28->( MsSeek ( xFilial('F28') + cCodAliq + '2' ) )
    Help( ,, 'Help',, "C�digo j� cadastrado!", 1, 0 ) 
    return .F.
EndIF

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodAliq .Or. ;
   "/" $ cCodAliq .Or. ;
   "-" $ cCodAliq .Or. ;
   "+" $ cCodAliq .Or. ;
   "(" $ cCodAliq .Or. ;
   ")" $ cCodAliq
    Help( ,, 'Help',, "C�digo da regra n�o pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodAliq)
    Help( ,, 'Help',, "C�digo n�o pode conter espa�o.", 1, 0 ) 
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C162CBOX
Fun��o que valida se o c�digo de perfil cadastrado j� existe

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function C162CBOX(lCarga)

Local nI	:= 0
Local cRet	:= ""
Local aOpc	:= {} 

Default lCarga := .F.

/*
Ao adicionar novas op��es � nescessario informar a segunda coluna com descri��o da formula e terceira valor da formula
Desta forma ao processar FISA170 sera dado carga da tabela CIN
Quando n�o informar segunda ou terceira coluna n�o sera dado carga na CIN
*/

//        F28 Combo     |       CIN Descri��o               |  CIN Formula
AADD(aOpc,{STR0011      ,"Al�quota do ICMS"                 ,"ALQ_ICMS"})       //"01=Al�quota do ICMS"
AADD(aOpc,{STR0012      ,"Al�quota do Cr�dito Presumido"    ,"ALQ_CREDPRESU"})  //"02=Al�quota do Cr�dito Presumido"
AADD(aOpc,{STR0013      ,"Al�quota do ICMS-ST"              ,"ALQ_ICMSST"})     //"03=Al�quota do ICMS-ST"
AADD(aOpc,{STR0014      ,""                                 ,""})               //"04=Al�quota Informada Manualmente"
AADD(aOpc,{STR0015      ,""                                 ,""})               //"05=Unidade de Referencia Fiscal (URF)"
AADD(aOpc,{STR0017      ,""                                 ,""})               //"06=F�rmula Manual"

//Esta op��o do combo n�o ser� adicionada como origem, e sim como indexde c�lculo
IF !lCarga
    AADD(aOpc,{"07=Tabela Progressiva"      ,""                                 ,""})               //"07 =Tabela Progressiva"
EndIF

If lCarga
    Return aOpc
Endif

For nI:=1 To Len(aOpc)
	cRet += IIf(empty(cRet),'',';') + aOpc[nI][1]
Next

Return (cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Fun��o respons�vel por realizar as valida��es do model 
Ser� acionada ao salvar o modelo.

@author Erich M. Buttner
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cValOri 		:= oModel:GetValue ('FISA162',"F28_VALORI")
Local nURFPerc 		:= oModel:GetValue ('FISA162',"F28_UFRPER")
Local cURF   		:= oModel:GetValue ('FISA162',"F28_URF")
Local cTpAliq       := oModel:GetValue ('FISA162',"F28_TPALIQ")
Local nAliq         := oModel:GetValue ('FISA162',"F28_ALIQ")
Local lRet          := .T.
Local lCIN          := AliasIndic("CIN") .And. FindFunction("xFisFormul")
Local cErrForml     := ""

//VAlida��es para opera��es de inclus�o e altera��o.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If cValOri == "05" .And. nURFPerc == 0
        lRet:= .F.
        Help( ,, 'Help',, STR0006, 1, 0 ) // "Por Favor, Preencher o percentual da URF"
    EndIF

    If lRet .And. Empty(AllTrim(cURF)) .And. cValOri == "05"
        lRet:= .F.
        Help( ,, 'Help',, STR0007, 1, 0 ) //"Por Favor, Informe o Codigo da URF"   
    EndIf

    If lRet .And. Empty(AllTrim(cTpAliq)) .And. cValOri $ "04#06#07"
        lRet:= .F.
        Help( ,, 'Help',, STR0008, 1, 0 ) //"Por Favor, Informe o Tipo da Aliquota"
    EndIf

    If lRet .And. nAliq == 0 .And. cValOri == "04"
        IF !(lCIN .and. AllTrim(cTpAliq) == '1') //Quando utilizado aliquota 0 com percentual permite cadastro
            lRet:= .F.
            Help( ,, 'Help',, STR0009, 1, 0 ) //"Por Favor, Informe o Valor da Aliquota"   
        Endif
    EndIf

    If lRet .And. nAliq < 0 .And. cValOri == "04"         
        lRet:= .F.
        Help( ,, 'Help',, STR0010, 1, 0 ) //"Por Favor, Informe o Valor da Aliquota Positivo"          
    EndIf    
    
    //Se a tabela CIN existe ent�o ser� verificada a sintaxe da f�rmula antes de gravar
    If lRet .AND. lCIN .AND. !xForCheck("FORMULALQ", @cErrForml, .F., "2", "F28_CODIGO", "FISA162")
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da F�rmula: -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na f�rmula, por favor verifique
    EndIF

EndIF

//Valida��o da exclus�o, para que n�o permita excluir caso este ID j� tenha sido utilizado na grava��o da F2D.
IF nOperation == MODEL_OPERATION_DELETE

    dbSelectArea("F2D")
    dbSetOrder(4)
    If F2D->(MsSeek(xFilial('F2D') + F28->F28_ID))
        lRet    := .F.
        Help( ,, 'Help',, STR0016, 1, 0 ) //"Esta regra j� foi utilizada na grava��o dos tributos gen�ricos e n�o poder� ser exclu�da!"
    EndIF

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162Grava
Fun��o respons�vel por realizar a grava��o da regra de al�quota.
Aqui faremos o tratamento do hist�rico de altera��es

@author Erick Dias
@since 13/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA162Grava(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cCodigo 		:= oModel:GetValue ('FISA162',"F28_CODIGO")
Local cDescri 		:= oModel:GetValue ('FISA162',"F28_DESC")
Local cValOri 		:= oModel:GetValue ('FISA162',"F28_VALORI")
Local cTpAliq 		:= oModel:GetValue ('FISA162',"F28_TPALIQ")
Local nAliq 		:= oModel:GetValue ('FISA162',"F28_ALIQ")
Local cUrf  		:= oModel:GetValue ('FISA162',"F28_URF")
Local nPerURF  		:= oModel:GetValue ('FISA162',"F28_UFRPER")
Local cFormula     	:= ""
Local cIdRegra      := ""
Local lCIN          := AliasIndic("CIN") .And. FindFunction("xFisFormul")

If nOperation == MODEL_OPERATION_INSERT 
    //Chama fun��o para gravar nova informa��o na tabela F28
    cIdRegra:= GravaF28(1, cCodigo, cDescri, cValOri, cTpAliq, nAliq, cUrf, nPerURF)

    //Grava as informa��es da f�rmula na tabela CIN
    If lCIN        
        cFormula    := oModel:GetValue ('FORMULALQ',"CIN_FORMUL")
        GravaCIN("1","2", cCodigo, cIdRegra, cDescri, cFormula)
    EndIF
ElseIF  nOperation == MODEL_OPERATION_UPDATE
    //Chama fun��o para alterar registro atual
    cIdRegra:= GravaF28(2)

    //Grava as informa��es da f�rmula na tabela CIN
    If lCIN
        //Chama fun��o para editar a regra CIN
        GravaCIN("2",,, cIdRegra)
    EndIF

    //Agora chamo fun��o para inserir novo registro
    cIdRegra := GravaF28(1, cCodigo, cDescri, cValOri, cTpAliq, nAliq, cUrf, nPerURF)

    //Grava as informa��es da f�rmula na tabela CIN
    If lCIN
        //Chama fun��o para editar a regra CIN
        GravaCIN("2",,, cIdRegra)
        
        //Chama fun��o para gravar nova linha na CIN
        cFormula    := oModel:GetValue ('FORMULALQ',"CIN_FORMUL")
        GravaCIN("1","2", cCodigo, cIdRegra	, cDescri, cFormula)
    EndIF
    
ElseIf nOperation == MODEL_OPERATION_DELETE

     If lCIN
        //Chama fun��o para excluir a regra CIN antes de excluir a F28
        GravaCIN("3",,, F28->F28_ID)
    EndIF
 
    //Faz exclus�o do registro
    RecLock("F28",.F.)
	F28->(dbDelete())
	MsUnLock()
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF28
Fun��o que faz grava��o e edi��o da tabela F28

@author Erick Dias
@since 13/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function GravaF28(nOp, cCodigo, cDescri, cValOri, cTpAliq, nAliq, cUrf, nPerURF)
Local cID := ""
If nOp == 1 //Incluiu

    RecLock("F28",.T.)
    F28->F28_FILIAL	    := xFilial("F28")
    F28->F28_ID		    := FWUUID("F28")    
    F28->F28_CODIGO		:= cCodigo
    F28->F28_DESC  		:= cDescri
    F28->F28_VALORI		:= cValOri
    F28->F28_TPALIQ		:= cTpAliq
    F28->F28_ALIQ  		:= nAliq
    F28->F28_URF   		:= cUrf
    F28->F28_UFRPER		:= nPerURF    
    F28->F28_ALTERA		:= "2" //Indica que n�o foi alterado
    F28->(MsUnLock())

ElseIf nOp ==2 //Altera��o    
    RecLock("F28",.F.)
    F28->F28_ALTERA 		:= "1"//Indica que sofreu altera��es
    F28->F28_DTALT  		:= Date()
    F28->F28_HRALT  		:= Time()
    F28->(MsUnLock())

EndIf

Return cId := F28->F28_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162HFor
Fun��o que indica se o campo de f�rmula dever� ou n�o estar habilitado,
e ter o seu conte�do alterado.

@return - bool - Retorna verdadeiro se a op��o de f�rmula manual estiver selecionada

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162HFor()
return !lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} RetOperOri
Fun��o que retorna o operando para a op��o selecionada de origem de
base de c�lculo.

@param -  cValOri - Op��o selecionada no combo
@return - cOpcaoOri - Operando correspondente a origem selecionada

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function RetOperOri(cValOri)

Local cOpcaoOri := ""

IF cValOri == "01"
    cOpcaoOri := "ALQ_ICMS"
ElseIF cValOri == "02"
    cOpcaoOri := "ALQ_CREDPRESU"
ElseIF cValOri == "03"
    cOpcaoOri := "ALQ_ICMSST"
ElseIF cValOri == "04"
    cOpcaoOri := "ALQ_MANUAL"
ElseIF cValOri == "05"
    cOpcaoOri := "UN_REFFISCAL"
ElseIF cValOri == "07"
    cOpcaoOri := "ALIQ_TAB_PROGRESSIVA"
EndIF

Return cOpcaoOri

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162Form
Fun��o que atualiza a f�rmula da regra de base de c�lculo.
Ao alterar algum operando do modo b�sico da regra, a f�rmula 
ser� atualizada.

@return - .T.

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162Form(cFormula)

Local oModel        := FWModelActive()
Local cValOri 		:= oModel:GetValue ('FISA162',"F28_VALORI")
Local cOpcaoOri     := ""
Local cTpAliq       := ""
Local cCodURF       := ""
Local cVlAlqM       := ""
Local cPerURF       := 0
Local nPerURF       := 0
Local nVlAlqM       := 0
Local cPrefixo      := ""

Default cFormula    := ""

//Inicia a f�rmula com operando de origem
cOpcaoOri   :=  RetOperOri(cValOri)

IF !Empty(cFormula) .And. cValOri == "06"

    //Primeiro limpa a f�rmula
    xForClear("FORMULALQ", .F., "VIEW_FORMULA", .F.)

    //Abrir parentes 
    xForBtnAct(cFormula, "FORMULALQ", .F., "VIEW_FORMULA")

    //Indica que o bot�o de edi��o de f�rmula ficar� habilitado
    lclicked := .T.

    Return .T.

Endif

//Se o valor original for 06, ent�o significa que � f�rmula, e logo n�o mais atualizarei as f�rmulas
If cValOri == "06"
    Return .T.
EndIF

//Primeiro limpa a f�rmula
xForClear("FORMULALQ", .F., "VIEW_FORMULA")

//Se operador estiver fazio ent�o a f�rmula n�o ser� montada!
If !Empty(cOpcaoOri)

    //Verifica se a al�quota � informada manualmente
    If cOpcaoOri == "ALQ_MANUAL"
        //Carrego as informa��es do campo de al�quota informado manualmente
        nVlAlqM := oModel:GetValue ('FISA162',"F28_ALIQ")
        //Carrego as informa��es do campo de tipo de al�quota
        cTpAliq := oModel:GetValue ('FISA162',"F28_TPALIQ")

        IF cTpAliq == '1' .and. nVlAlqM == 0
            cPrefixo:= xFisTpForm("0") //Operador prim�rio
            //Adiciona o operador de origem/in�cio na f�rmula
            xForBtnAct(cPrefixo+"ZERO", "FORMULALQ", .F., "VIEW_FORMULA")
        Else
            If !Empty(cTpAliq)
                
                //Converto o n�mero em caracter antes de ser adicionado na f�rmula
                cVlAlqM := Alltrim(StrTran( Str(nVlAlqM ), ".", "," ))

                //Adiciona o percentual
                xForBtnAct(cVlAlqM, "FORMULALQ", .F., "VIEW_FORMULA")
            EndIf        
        Endif
    //Al�quota por UFR
    ElseIf cOpcaoOri == "UN_REFFISCAL"

        //Carrego as informa��es do campo c�digo URF
        cCodURF:= oModel:GetValue ('FISA162',"F28_URF")
        //Carrego as informa��es do campo de Percentual da URF
        nPerURF:= oModel:GetValue ('FISA162',"F28_UFRPER")

        If !Empty(cCodURF)

            nPerURF:= nPerURF/100
            //Converto o n�mero em caracter antes de ser adicionado na f�rmula
            cPerURF := Alltrim(StrTran( Str(nPerURF ), ".", "," ))

            //Adiciona o percentual
            cPrefixo:= xFisTpForm("4") //URF
            xForBtnAct(cPrefixo+cCodURF, "FORMULALQ", .F., "VIEW_FORMULA")

            //Adiciona o operador de multiplica��o
            xForBtnAct("*", "FORMULALQ", .F., "VIEW_FORMULA")

            //Adiciona o operador de multiplica��o
            xForBtnAct(cPerURF, "FORMULALQ", .F., "VIEW_FORMULA")            

        EndIf         

    ElseIF cOpcaoOri == "ALIQ_TAB_PROGRESSIVA"                
            xForBtnAct(xFisTpForm("9") + cOpcaoOri, "FORMULALQ", .F., "VIEW_FORMULA")        

    Else
        cPrefixo:= xFisTpForm("0") //Operador prim�rio
        //Adiciona o operador de origem/in�cio na f�rmula
        xForBtnAct(cPrefixo+cOpcaoOri, "FORMULALQ", .F., "VIEW_FORMULA")
    EndIf
    
    lclicked := .T.
    
EndiF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162AFor
Fun��o executada quando usu�rio acionou edi��o manual na f�rmula, 
fun��o chamada no action do bot�o habilitar f�rmulas.
Para isso preciso indicar no valor de origem a op��o 06, que 
significa f�rmula manual.
Al�m disso preciso tamb�m restaurar os demais campos para as op��es
iniciais, e deixar estes campos desabilitados, j� que a f�rmula ser� 
constru�da manualmente, e n�o mais por meio dos combos, at� mesmo
porq n�o seria poss�vel representar todas as f�rmulas nos combos, 
j� que a f�rmula � muito mais flexivel.

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162AFor()
Local oModel    := FWModelActive()
Local oFormul   := oModel:GetModel("FISA162")
Local oView     := 	FWViewActive()

//Adiciona o operador no final da f�rmula
oFormul:SetValue('F28_VALORI',  "06")

//Atualizo a view
oview:Refresh( 'VIEW_CABECALHO')
oview:Refresh( 'VIEW_FORMULA')
oview:Refresh( 'VIEW_REGRA')
oview:Refresh( 'BOTOES')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162HBtn
Esta fun��o indica se o bot�o que habilita a edi��o da f�rmula dever� estar
ou n�o habilitado.

Por padr�o em um novo cadastro o bot�o estar� habilitado.

@return bool - Retorna verdadeiro quando a op��o de origem n�o � f�rmula manual(06)

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162HBtn()
Return lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162F28
Fun��o executada quando usu�rio entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA162F28()
Local oModel    := nil
Local cCodigo   := ""
Local cDescri   := ""
Local cFormula  := ""
Local cIdRegra  := ""
Local cAlias    := ""
Local cAltera   := ""

//Realiza pesquisa pela rela��o da F28 com CIN
cAlias := PesqCIN("F28")

DbSelectArea(cAlias)

//Caso n�o encontre diferen�as finaliza processo
If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA162
oModel    := FWLoadModel('FISA162')

DbSelectArea("F28")
F28->(DbSetOrder(4)) // F28_FILIAL+F28_ID

While (!(cAlias)->(Eof()))

    If F28->(MsSeek(xFilial("F28") + (cAlias)->F28_ID))

        oModel:Activate()

        cCodigo   := oModel:GetValue ('FISA162',"F28_CODIGO")   // C�digo Regra
        cDescri   := oModel:GetValue ('FISA162',"F28_DESC")    // Descri��o   
        cIdRegra  := oModel:GetValue ('FISA162','F28_ID')
        cAltera   := Iif(F28->F28_ALTERA =='2',"0","1")

        //Fun��o que atualiza a f�rmula da regra de Aliquota.
        Fsa162Form()

        cFormula    := oModel:GetValue ('FORMULALQ',"CIN_FORMUL")
        GravaCIN("1","2", cCodigo, cIdRegra, cDescri, cFormula,cAltera)

        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F28->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162Hist
Fun��o que exibir� Browse com o hist�rico de altea��es da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA162Hist()
Local cFiltro   := ""
Local aColunas  := {}

//Adicionando as colunas de Data e horario de altera��o, pois o UPDDISTR n�o altera o X3_BROWSE, por isso estou adicionado a coluna manualmente.
/* Posi��es dos arrays
1 - T�tulo
2 - Codeblock para carregra a ~informa��o
3 - Tipo
4 - Alinhamento (1 alinhado a esquera)
5 - Tamanho
6 - Decimal
7 - Indica se permite altera��o
*/
AADD(aColunas,{ STR0027, &("{ || IIf(F28->F28_ALTERA == '1','" + STR0028 + "','" + STR0029 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - N�o alterado"
AADD(aColunas,{ STR0025, &("{ || F28->F28_DTALT }"), "D", "", 1, 8, 0, .f.}) //"Data de Altera��o"
AADD(aColunas,{ STR0026, &("{ || F28->F28_HRALT }"), "C", "", 1, 8, 0, .f.}) //"Hor�rio de Altera��o"

//Atribuo o Alias para variavel p�blica 
c170AlsHist := "F28"

//Monto o filtro abaixo somente com linhas que foram alteradas e n�o est�o mais vigentes
cFiltro :="F28_FILIAL == '" + xFilial("F28") + "'"
cFiltro	+= " .AND. F28_CODIGO == '" + F28->F28_CODIGO +  "'"

//Utilizo segundo �ndice para facilitar a visualiza��o
F28->(DbSetOrder(6))

//Chamo a fun��o auxiliar que montar� o Browse com as regras alteradas.
FSA16XHist("F28", cFiltro, STR0024, aColunas) //"Hist�rico de altera��es da Regra de Al�quotas"

//Retorno o Alias e filtro padr�o
c170AlsHist := ""
F28->(DbSetOrder(1))

Return
