#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA161.ch" 
#Include "FWEditPanel.CH"

STATIC cOperRedBas  := "PERC_REDUCAO_BASE"
STATIC lCIN         := AliasIndic("CIN") .And. FindFunction("xFisFormul")

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA161()

Esta rotina � o cadastro das regras de composi��o da base de c�lculo
dos tributos gen�ricos. Esta tela definir� como a base de c�lculo ser� 
composta.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Erick G. Dias
@since 20/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA161()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F27")
    dbSelectArea("F27")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F27")
    oBrowse:SetFilterDefault("F27_ALTERA == '2'")
    oBrowse:SetDescription(STR0001) // Cadastro da composi��o da base de c�lculo
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 20/062018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.FISA161' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.FISA161' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.FISA161' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.FISA161' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0014 ACTION 'VIEWDEF.FISA161' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0015 ACTION 'FSA161Hist'      OPERATION 4 ACCESS 0 //'Hist�rico de Altera��es'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela F27 com os campos da composi��o da base de c�lculo
Local oRegraBase := FWFormStruct(1, "F27" )
Local oFORMULBAS     := Iif(lCIN,FWFormStruct(1,"CIN"),nil) 

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA161',/*Pre-Validacao*/,{|oModel|ValidModel(oModel) },{|oModel|FSA161Grava(oModel)})

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA161",,oRegraBase)

//Verifico se tabela CIN existe
If lCIN  
    
    //Atribuindo estruturas para o modelo
    oModel:AddFields("FORMULBAS","FISA161",oFORMULBAS)
EndIF

//N�o permite alterar o conte�do do campo F27 na edi��o
oRegraBase:SetProperty('F27_CODIGO' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

//Somente permitir� informar tipo de redu��o quando o percentual de redu��o for maior que zero
oRegraBase:SetProperty('F27_TPRED' , MODEL_FIELD_WHEN, {|| oModel:GetValue ('FISA161',"F27_REDBAS") > 0 .And. oModel:GetValue('FISA161',"F27_VALORI")<>"11"  })

//Somente permitir� informar unidade de medida quando o valor de origem da base de c�lculo for igual 02-Quantidade
oRegraBase:SetProperty('F27_UM' , MODEL_FIELD_WHEN, {|| oModel:GetValue ('FISA161',"F27_VALORI") $ '02/11' })

//Valida��o para n�o permitir informar c�digo de perfil + tipo de perfil duplicado
oRegraBase:SetProperty('F27_CODIGO' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

If lCIN
    
    //O campo de f�rmula ficar� habilitado, somente ap�s o valor de origem for igual a 11
    //A fun��o Fsa161HFor() indica se deve ou n�o estar habilitado  

    
    oFORMULBAS:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {||  .T. })    
    oFORMULBAS:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") <> "ZZ" })

    oFORMULBAS:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa161HFor() })
    oFORMULBAS:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") == "ZZ" })
    oFORMULBAS:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") == "05" } )

   //Os campos abaixo ficar�o desabilitados quando o valor de origem for 11, f�rmula manual
   //a fun��o Fsa161HBtn() indica se os campos abaixo dever�o ou n�o ficar habilitados
    oRegraBase:SetProperty('F27_DESCON' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_FRETE' ,  MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_SEGURO' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_DESPE' ,  MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_ICMDES' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_ICMRET' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    
    //Adicionei no valid dos campos abaixo a chamada da fun��o Fsa161HBtn(), para atualizar a f�rmula 
    oRegraBase:SetProperty('F27_VALORI' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_DESCON' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_FRETE'  , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_SEGURO' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_DESPE'  , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_ICMDES' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_ICMRET' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_REDBAS' , MODEL_FIELD_VALID, {||(Fsa161Form() .And. MyPositivo())})
    oRegraBase:SetProperty('F27_TPRED' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    
    //Cria relacionamento entre a tabela F27 e CIN.
    oModel:SetRelation( 'FORMULBAS', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F27_ID'}, {'CIN_TREGRA', "'1 '"}}, CIN->( IndexKey(3)))

EndIF

oModel:SetPrimaryKey( {"F27_FILIAL","F27_CODIGO","F27_ALTERA","F27_ID"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) // Cadastro de Perfil Tribut�rio de Produto

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA161" ) 

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oRegraBase:= FWFormStruct(2, "F27")
Local oFormula  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) //Somente adiciona na view da f�rmula o campo CIN_FORMUL
Local oRegra    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB"}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL

Local oView := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oRegraBase  , 'FISA161'   )

//Cria os grupos
oRegraBase:AddGroup( 'GRUPO_CABECALHO', STR0003,'', 2 ) //'Base de C�lculo'
oRegraBase:AddGroup( 'GRUPO_ADICOES_DEDUCOES', STR0004, '' , 2 ) //'Adi��es e Dedu��es'
oRegraBase:AddGroup( 'GRUPO_REDUCAO' , STR0005 , '' , 2 ) //'Redu��o de Base de C�lculo'
oRegraBase:AddGroup( 'GRUPO_BASE_QUANTIDADE', STR0006 , '' , 2 ) //'Detalhamento - Base de C�lculo por Quantidade'

//Define os campos do grupo do cabe�alho
oRegraBase:SetProperty( 'F27_CODIGO'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABECALHO' )
oRegraBase:SetProperty( 'F27_DESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABECALHO' )
oRegraBase:SetProperty( 'F27_VALORI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABECALHO' )

//Define os campos do grupo das adi��es e subtra��es
oRegraBase:SetProperty( 'F27_DESCON' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_FRETE'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_SEGURO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_DESPE'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_ICMDES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_ICMRET' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )

//Define os campos do grupo da redu��o de base de c�lculo
oRegraBase:SetProperty( 'F27_REDBAS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REDUCAO' )
oRegraBase:SetProperty( 'F27_TPRED'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REDUCAO' )

//Define os campos do grupo do detalhamento da base de c�lculo por unidade de medida
oRegraBase:SetProperty( 'F27_UM'     , MVC_VIEW_GROUP_NUMBER, 'GRUPO_BASE_QUANTIDADE' )
oRegraBase:SetProperty( 'F27_UMDESC' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_BASE_QUANTIDADE' )

//Picture do campo c�digo
oRegraBase:SetProperty('F27_CODIGO' , MVC_VIEW_PICT, "@!")

// //Se a tabela CIN existir ent�o dividirei a tela em duas partes, uma para dados cadastrais da regr e outra com detalhamento da f�rmula
If lCIN
    oFormula:SetProperty("CIN_FORMUL"  , MVC_VIEW_CANCHANGE, .F.)

    //Remove o campo da View
    oRegraBase:RemoveField("F27_ID")

    //Cria as views do operando e da f�rmula    
    oView:AddField( 'VIEW_FORMULA' , oFormula, 'FORMULBAS')

    //Cria as view do campo regra
    oView:AddField( 'VIEW_REGRA' , oRegra, 'FORMULBAS')

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
     oView:AddSheet( 'PASTAS', 'ABA01', "Defini��o da Base de C�lculo"       )
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
    oView:AddOtherObject("BOTOES", {|oPanel| xFisFormul(oPanel, "FORMULBAS","VIEW_FORMULA", "1", "F27_CODIGO", "FISA161", "CIN_CONSUL", "VIEW_REGRA")}) 

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

EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161VORI
Fun��o que montar� as op��es dispon�veis para a origem da base de c�lculo.
o X3_CBOX chamar� esta fun��o 

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA161VORI(lCarga)

Local aOpcoes   := {}
Local cRet      := ''
Local nI        := 0

Default lCarga  := .F.

/*
Ao adicionar novas op��es � nescessario informar a segunda coluna com descri��o da formula e terceira valor da formula
Desta forma ao processar FISA170 sera dado carga da tabela CIN
Quando n�o informar segunda ou terceira coluna n�o sera dado carga na CIN
*/

//          F27 Combo                        |      CIN Descri��o         |  CIN Formula
AADD(aOpcoes,{"01=Valor da Mercadoria"       ,"Valor da Mercadoria"       ,"VAL_MERCADORIA" })
AADD(aOpcoes,{"02=Quantidade"                ,"Quantidade"                ,"QUANTIDADE"     })
AADD(aOpcoes,{"03=Valor Cont�bil"            ,"Valor Cont�bil"            ,"VAL_CONTABIL"   })
AADD(aOpcoes,{"04=Valor do Cr�dito Presumido","Valor do Cr�dito Presumido","VAL_CRED_PRESU" })
AADD(aOpcoes,{"05=Base de ICMS"              ,"Base de ICMS"              ,"BASE_ICMS"      })
AADD(aOpcoes,{"06=Base Original do ICMS"     ,"Base Original do ICMS"     ,"BASE_ORIG_ICMS" })
AADD(aOpcoes,{"07=Valor do ICMS"             ,"Valor do ICMS"             ,"VAL_ICMS"       })
AADD(aOpcoes,{"08=Valor do Frete"            ,"Valor do Frete"            ,"FRETE"          })
AADD(aOpcoes,{"09=Valor da Duplicata"        ,"Valor da Duplicata"        ,"VAL_DUPLICATA"  })
AADD(aOpcoes,{"10=Valor total do Item"       ,"Valor total do Item"       ,"TOTAL_ITEM"     })
If lCIN
    AADD(aOpcoes,{"11=F�rmula Manual"            ,""                          ,""               })
Endif

If lCarga
    Return aOpcoes
Endif

For nI:=1 To Len(aOpcoes)
    cRet += IIf(empty(cRet),'',';') + aOpcoes[nI][1]
Next

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Fun��o respons�vel por realizar as valida��es do model 
Ser� acionada ao salvar o modelo.

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local nRedBase 		:= oModel:GetValue ('FISA161',"F27_REDBAS")
Local cTpRed        := oModel:GetValue ('FISA161',"F27_TPRED")
Local cOrig         := oModel:GetValue ('FISA161',"F27_VALORI")
Local lRet          := .T.
Local cErrForml     := ""
Local oView 	    := nil

//VAlida��es para opera��es de inclus�o e altera��o.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If cOrig <> "11"
        //Valida��o de reducao base de c�lculo sem f�rmula manual
        
        //Se houver percentual de redu��o de base de c�lculo informado exigir� o tipo de redu��o
        If nRedBase > 0 .AND. Empty(cTpRed)
            lRet:= .F.
            Help( ,, 'Help',, STR0008, 1, 0 ) // 'Por favor, informe o Tipo de Redu��o.'
        EndIf   

    Else
        //Valida��o de reducao base de c�lculo utilizando f�rmula manual        
       If nRedBase > 0 .AND. lCIN .And. !cOperRedBas $ oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
            //Neste caso n�o temos operando de redu��o na f�rmula, por�m temos o percentual preenchido no campo espec�fico
            //Poderia alertar o usu�rio para limpar, mas acho melhor e sguro a pr�pria rotina limpar este campo automaticamente
            
            //Zerando percentual
            oModel:SetValue ('FISA161',"F27_REDBAS",0) 
            
            //Atualizando a View
            oView 	:= 	FWViewActive()
            oview:Refresh( 'VIEW_CABECALHO')
            
        ElseIf  nRedBase == 0 .AND. lCIN .And. cOperRedBas $ oModel:GetValue ('FORMULBAS',"CIN_FORMUL")  
            //Aqui precisa informar o percentual de redu��o
            lRet:= .F.
            Help( ,, 'Help',, "Por favor, informe percentual de redu��o", 1, 0 )
        EndIF
    EndIF    

    //Se a tabela CIN existe ent�o ser� verificada a sintaxe da f�rmula antes de gravar
    If lRet .AND. lCIN .AND. !xForCheck("FORMULBAS", @cErrForml, .F., "1", "F27_CODIGO", "FISA161")
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da F�rmula: -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na f�rmula, por favor verifique
    EndIF

EndIF

//Valida��o da exclus�o, para que n�o permita excluir caso este ID j� tenha sido utilizado na grava��o da F2D.
IF nOperation == MODEL_OPERATION_DELETE

    dbSelectArea("F2D")
    dbSetOrder(5)
    If F2D->(MsSeek(xFilial('F2D') + F27->F27_ID))
        lRet    := .F.
        Help( ,, 'Help',, STR0009, 1, 0 ) //"Esta regra j� foi utilizada na grava��o dos tributos gen�ricos e n�o poder� ser exclu�da!"
    EndIF

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Fun��o que valida se o c�digo de perfil cadastrado j� existe

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodBase 	:= oModel:GetValue ('FISA161',"F27_CODIGO")
Local lRet      := .T.

//Verifico se o perfil j� existe.
//Procura se j� existe regra de base de c�lculo com o mesmo c�digo e ativa
If F27->( MsSeek ( xFilial('F27') + cCodBase + '2' ) )
    Help( ,, 'Help',, "C�digo j� cadastrado!", 1, 0 ) 
    return .F.    
EndIF

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodBase .Or. ;
   "/" $ cCodBase .Or. ;
   "-" $ cCodBase .Or. ;
   "+" $ cCodBase .Or. ;
   "(" $ cCodBase .Or. ;
   ")" $ cCodBase
    Help( ,, 'Help',, "C�digo da regra n�o pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodBase)
    Help( ,, 'Help',, "C�digo n�o pode conter espa�o.", 1, 0 ) 
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161Grava
Fun��o respons�vel por realizar a grava��o da regra de base de al�quota
Aqui faremos o tratamento do hist�rico de altera��es

@author Erick Dias
@since 13/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA161Grava(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cCodigo 		:= oModel:GetValue ('FISA161',"F27_CODIGO")
Local cDescri 		:= oModel:GetValue ('FISA161',"F27_DESC")
Local cValOri 		:= oModel:GetValue ('FISA161',"F27_VALORI")
Local cDesc 		:= oModel:GetValue ('FISA161',"F27_DESCON")
Local cFrete 		:= oModel:GetValue ('FISA161',"F27_FRETE")
Local cSeguro  		:= oModel:GetValue ('FISA161',"F27_SEGURO")
Local cDesp  		:= oModel:GetValue ('FISA161',"F27_DESPE")
Local cIcmsDes 		:= oModel:GetValue ('FISA161',"F27_ICMDES")
Local cIcmsRet 		:= oModel:GetValue ('FISA161',"F27_ICMRET")
Local nReduzBase	:= oModel:GetValue ('FISA161',"F27_REDBAS")
Local cTpReduz  	:= oModel:GetValue ('FISA161',"F27_TPRED")
Local cUm 	    	:= oModel:GetValue ('FISA161',"F27_UM")
Local cFormula     	:= ""
Local cIdRegra      := ""

If nOperation == MODEL_OPERATION_INSERT 
    //Chama fun��o para gravar nova informa��o na tabela F27
    cIdRegra    := GravaF27(1, cCodigo, cDescri, cValOri, cDesc, cFrete, cSeguro, cDesp, cIcmsDes, cIcmsRet, nReduzBase, cTpReduz, cUm)
    
    //Grava as informa��es da f�rmula na tabela CIN
    If lCIN        
        cFormula    := oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
        GravaCIN("1","1", cCodigo, cIdRegra, cDescri, cFormula)        
    EndIF

ElseIF  nOperation == MODEL_OPERATION_UPDATE
    //Chama fun��o para alterar registro atual
    cIdRegra    := GravaF27(2)
    //Grava as informa��es da f�rmula na tabela CIN
    If lCIN
        //Chama fun��o para editar a regra CIN
        GravaCIN("2",,, cIdRegra)        
    EndIF
    
    //Agora chamo fun��o para inserir novo registro
    cIdRegra := GravaF27(1, cCodigo, cDescri, cValOri, cDesc, cFrete, cSeguro, cDesp, cIcmsDes, cIcmsRet, nReduzBase, cTpReduz, cUm)
    
    //Grava as informa��es da f�rmula na tabela CIN
    If lCIN
        //Chama fun��o para editar a regra CIN
        GravaCIN("2",,, cIdRegra)
        
        //Chama fun��o para gravar nova linha na CIN
        cFormula    := oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
        GravaCIN("1","1", cCodigo, cIdRegra	, cDescri, cFormula)
    EndIF
    
ElseIf nOperation == MODEL_OPERATION_DELETE
    
    If lCIN
        //Chama fun��o para excluir a regra CIN antes de excluir a F27
        GravaCIN("3",,, F27->F27_ID)
    EndIF

    //Faz exclus�o do registro
    RecLock("F27",.F.)
	F27->(dbDelete())
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
Static Function GravaF27(nOp, cCodigo, cDescri, cValOri, cDesc, cFrete, cSeguro, cDesp, cIcmsDes, cIcmsRet, nReduzBase, cTpReduz, cUm )
Local cId   := ""
If nOp == 1 //Incluiu
    RecLock("F27",.T.)
    F27->F27_FILIAL	    := xFilial("F27")
    F27->F27_ID		    := FWUUID("F27")
    F27->F27_CODIGO	    := cCodigo
    F27->F27_DESC  	    := cDescri
    F27->F27_VALORI	    := cValOri
    F27->F27_DESCON 	    := cDesc
    F27->F27_FRETE  	    := cFrete
    F27->F27_SEGURO	    := cSeguro
    F27->F27_DESPE 	    := cDesp
    F27->F27_ICMDES	    := cIcmsDes
    F27->F27_ICMRET	    := cIcmsRet
    F27->F27_REDBAS	    := nReduzBase
    F27->F27_TPRED 	    := cTpReduz
    F27->F27_UM    	    := cUm
    F27->F27_ALTERA		:= "2" //Indica que n�o foi alterado    
    MsUnLock()

ElseIf nOp ==2 //Altera��o    
    RecLock("F27",.F.)
    F27->F27_ALTERA 		:= "1"//Indica que sofreu altera��es
    F27->F27_DTALT  		:= Date()
    F27->F27_HRALT  		:= Time()
    MsUnLock()

EndIf

Return cId := F27->F27_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161Form
Fun��o que atualiza a f�rmula da regra de base de c�lculo.
Ao alterar algum operando do modo b�sico da regra, a f�rmula 
ser� atualizada.

@return - .T.

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161Form(cFormula)

Local oModel        := FWModelActive()
Local cValOri 		:= oModel:GetValue ('FISA161',"F27_VALORI")
Local cOpcaoOri     := ""
Local cRed          := ""
Local lRedAnt       := .F. //Reduz antes das adi��es e subtra��es
Local lRedDep       := .F. //Reduz depois das adi��es e subtra��es
Local cPrefixo      := ""

Default cFormula    := ""

//Inicia a f�rmula com operando de origem
cOpcaoOri   :=  RetOperOri(cValOri)

IF cValOri == "11" .And. !Empty(cFormula)
   
    //Primeiro limpa a f�rmula
    xForClear("FORMULBAS", .F., "VIEW_FORMULA")

    //Envia a Formula    
    xForBtnAct(cFormula, "FORMULBAS", .F., "VIEW_FORMULA")    

    lclicked    := .T.
Endif

//Se o valor original for 11, ent�o significa que � f�rmula, e logo n�o mais atualizarei as f�rmulas
If cValOri == "11"
    Return .T.
EndIF

//Primeiro limpa a f�rmula
xForClear("FORMULBAS", .F., "VIEW_FORMULA")

//Se operador estiver fazio ent�o a f�rmula n�o ser� montada!
If !Empty(cOpcaoOri)
    
    //Verifica se tem redu��o de base de c�lculo
    IF oModel:GetValue ('FISA161',"F27_REDBAS") > 0        
        
        //Obtenho o operando da redu��o de base de c�lculo
        cRed    := xFisTpForm('9') + cOperRedBas
        
        //Atualiza as variaveis de controle d eredu��o
        lRedAnt := oModel:GetValue ('FISA161',"F27_TPRED") == "1" //Reduz antes das adi��es e dedu��es        
        lRedDep := oModel:GetValue ('FISA161',"F27_TPRED") == "2" //Reduz depois das adi��es e dedu��es                

        //Se a redu��o acontecer antes ent�o j� devo abrir parentes aqui!
        IF lRedAnt .OR. lRedDep 
            xForBtnAct("(", "FORMULBAS", .F., "VIEW_FORMULA")
        EndIF

    EndIF

    //"0" = Operador prim�rio
    cPrefixo:= xFisTpForm("0")
    //Adiciona o operador de origem/in�cio na f�rmula
    xForBtnAct(cPrefixo+RetOperOri(cValOri), "FORMULBAS", .F., "VIEW_FORMULA")

    //Se a redu��o for antes, ent�o multiplico pelo percentual de redu��o e fecho os parenteses
    IF lRedAnt         
        //Adiciona o operador de multiplica��o
        xForBtnAct("*", "FORMULBAS", .F., "VIEW_FORMULA")
    
        //Adiciona o percentual
        xForBtnAct(cRed, "FORMULBAS", .F., "VIEW_FORMULA")
    
        //Fecha o parentes
        xForBtnAct(")", "FORMULBAS", .F., "VIEW_FORMULA")
    
    EndIF
    
    //Verifica se precisa adicionar o operando de desconto na f�rmula    
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_DESCON"),cPrefixo+"DESCONTO"        ) , "FORMULBAS", .F., "VIEW_FORMULA" )

    //Verifica se precisa adicionar o operando de frete na f�rmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_FRETE"),cPrefixo+"FRETE"            ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de SEGURO na f�rmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_SEGURO"),cPrefixo+"SEGURO"          ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de despesas na f�rmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_DESPE"), cPrefixo+"DESPESAS"        ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de ICMS Deson na f�rmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_ICMDES"),cPrefixo+"ICMS_DESONERADO" ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de ICMS Retido na f�rmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_ICMRET"),cPrefixo+"ICMS_RETIDO"     ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Se reduz depois das adic��es e subtra��es
    IF lRedDep
    
        //Fecha o parentes
        xForBtnAct(")", "FORMULBAS", .F., "VIEW_FORMULA")
        
        //Adiciona o operador de multiplica��o
        xForBtnAct("*", "FORMULBAS", .F., "VIEW_FORMULA")
        
        //Adiciona o percentual
        xForBtnAct( cRed , "FORMULBAS", .F., "VIEW_FORMULA")
    
    EndIF   
    //Indica que o bot�o de edi��o de f�rmula ficar� habilitado novamente
    lclicked := .T.
EndiF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetOperOri
Fun��o que retorna o operando para a op��o selecionada de origem de
base de c�lculo.

@param -  cValOri - Op��o selecionada no combo
@return - cOpcaoOri - Operando correspondente a origem selecionada

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function RetOperOri(cValOri)

Local cOpcaoOri := ""

IF cValOri == "01"
    cOpcaoOri := "VAL_MERCADORIA"
ElseIF cValOri == "02"
    cOpcaoOri := "QUANTIDADE"
ElseIF cValOri == "03"
    cOpcaoOri := "VAL_CONTABIL
ElseIF cValOri == "04"
    cOpcaoOri := "VAL_CRED_PRESU"
ElseIF cValOri == "05"
    cOpcaoOri := "BASE_ICMS"
ElseIF cValOri == "06"
    cOpcaoOri := "BASE_ORIG_ICMS"
ElseIF cValOri == "07"
    cOpcaoOri := "VAL_ICMS"
ElseIF cValOri == "08"
    cOpcaoOri := "FRETE"
ElseIF cValOri == "09"
    cOpcaoOri := "VAL_DUPLICATA"
ElseIF cValOri == "10"
    cOpcaoOri := "TOTAL_ITEM"
EndIF

Return cOpcaoOri

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperComb
Fun��o que adiciona operador e operando dos campos da onda 1 do
configurador, das op��es do combo.

@param -  cOpc - Indica se soma, subtrai ou sem a��o
@param -  cOperando - Operando a ser adicionado na f�rmula

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function AddOperComb(cOpc, cOperando)

Local cOperador := ""

IF cOpc == "2" //Subtra��o
    cOperador := "- "
ElseIF cOpc == "3" //Adi��o
    cOperador := "+ "
EndIF
//Se tem operador ent�o seguirei 
If Len(cOperador) > 0
    //Adiciona o operador
    xForBtnAct(cOperador , "FORMULBAS", .F., "VIEW_FORMULA" )

    //Adiciona operando
    xForBtnAct(cOperando , "FORMULBAS", .F., "VIEW_FORMULA" )
EndIF

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161HFor
Fun��o que indica se o campo de f�rmula dever� ou n�o estar habilitado,
e ter o seu conte�do alterado.

@return - bool - Retorna verdadeiro se a op��o de f�rmula manual estiver selecionada

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161HFor()
return !lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161AFor
Fun��o executada quando usu�rio acionou edi��o manual na f�rmula, 
fun��o chamada no action do bot�o habilitar f�rmulas.
Para isso preciso indicar no valor de origem a op��o 11, que 
significa f�rmula manual.
Al�m disso preciso tamb�m restaurar os demais campos para as op��es
iniciais, e deixar estes campos desabilitados, j� que a f�rmula ser� 
constru�da manualmente, e n�o mais por meio dos combos, at� mesmo
porq n�o seria poss�vel representar todas as f�rmulas nos combos, 
j� que a f�rmula � muito mais flexivel.

@author Erick Dias
@since 31/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161AFor()
Local oModel     := FWModelActive()
Local oFormul   := oModel:GetModel("FISA161")
Local oView 	:= 	FWViewActive()
    
//Adiciona o operador no final da f�rmula
oFormul:SetValue('F27_VALORI',  "11")

//Aqui retornarei todos os campos para estado inicial
oFormul:LoadValue('F27_DESCON', Criavar("F27_DESCON"))
oFormul:LoadValue('F27_FRETE',  Criavar("F27_FRETE"))
oFormul:LoadValue('F27_SEGURO', Criavar("F27_SEGURO"))
oFormul:LoadValue('F27_DESPE',  Criavar("F27_DESPE"))
oFormul:LoadValue('F27_ICMDES', Criavar("F27_ICMDES"))
oFormul:LoadValue('F27_ICMRET', Criavar("F27_ICMRET"))
oFormul:LoadValue('F27_TPRED' , Criavar("F27_TPRED"))    

//Atualizo a view
oview:Refresh( 'VIEW_CABECALHO')
oview:Refresh( 'VIEW_REGRA')
oview:Refresh( 'VIEW_FORMULA')
oview:Refresh( 'BOTOES')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161HBtn
Esta fun��o indica se o bot�o que habilita a edi��o da f�rmula dever� estar
ou n�o habilitado.

Por padr�o em um novo cadastro o bot�o estar� habilitado.

@return bool - Retorna verdadeiro quando a op��o de origem n�o � f�rmula manual(11)

@author Erick Dias
@since 31/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161HBtn()
Return lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161F27
Fun��o executada quando usu�rio entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA161F27()
Local oModel    := nil
Local cCodigo   := ""
Local cDescri   := ""
Local cFormula  := ""
Local cIdRegra  := ""
Local cAlias    := ""
Local cAltera   := ""

//Realiza pesquisa pela rela��o da F27 com CIN
cAlias := PesqCIN("F27")

DbSelectArea(cAlias)

//Caso n�o encontre diferen�as finaliza processo
If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA161
oModel    := FWLoadModel('FISA161')

DbSelectArea("F27")
F27->(DbSetOrder(3)) // F27_FILIAL+F27_ID

While (!(cAlias)->(Eof()))

    If F27->(MsSeek(xFilial("F27") + (cAlias)->F27_ID))

        oModel:Activate()

        cCodigo   := oModel:GetValue ('FISA161',"F27_CODIGO")   // C�digo Regra
        cDescri   := oModel:GetValue ('FISA161',"F27_DESC")    // Descri��o   
        cIdRegra  := oModel:GetValue ('FISA161','F27_ID')
        cAltera   := Iif(F27->F27_ALTERA == '2',"0","1")

        //Fun��o que atualiza a f�rmula da regra de base de c�lculo.
        Fsa161Form()

        cFormula    := oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
        GravaCIN("1","1", cCodigo, cIdRegra, cDescri, cFormula,cAltera)

        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F27->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MyPositivo
Fun��o auxiliar de valida��o do percentual de redu��o de base de c�lculo

@author Erick Dias
@since 14/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MyPositivo()
Local oModel        := FWModelActive()
Return oModel:GetValue ('FISA161',"F27_REDBAS") >= 0


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161Hist
Fun��o que exibir� Browse com o hist�rico de altea��es da rotina

@author Erick Dias
@since 25/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA161Hist()
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
AADD(aColunas,{ STR0019, &("{ || IIf(F27->F27_ALTERA == '1','" + STR0020 + "','" + STR0021 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - N�o alterado"
AADD(aColunas,{ STR0017, &("{ || F27->F27_DTALT }"), "D", "", 1, 8, 0, .f.}) //"Data de Altera��o"
AADD(aColunas,{ STR0018, &("{ || F27->F27_HRALT }"), "C", "", 1, 8, 0, .f.}) //"Hor�rio de Altera��o"

//Atribuo o Alias para variavel p�blica 
c170AlsHist := "F27"

//Monto o filtro abaixo somente com linhas que foram alteradas e n�o est�o mais vigentes
cFiltro :="F27_FILIAL == '" + xFilial("F27") + "'"
cFiltro	+= " .AND. F27_CODIGO == '" + F27->F27_CODIGO +  "'"

//Utilizo segundo �ndice para facilitar a visualiza��o
F27->(DbSetOrder(5))

//Chamo a fun��o auxiliar que montar� o Browse com as regras alteradas.
FSA16XHist("F27", cFiltro, STR0016 , aColunas) //"Hist�rico de altera��es da Regra de Base de C�lculo"

//Retorno o Alias e filtro padr�o
c170AlsHist := ""
F27->(DbSetOrder(1))

Return
