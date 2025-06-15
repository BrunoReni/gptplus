#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#include 'eiccp400.ch'
#Include "TOPCONN.CH"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"
#define ALIAS_TEMP          1
#define ARQ_TAB             2
#define INDEX1              3
#define INDEX2              4

static _aAtriCond := {}
static _lPedOper  := .F. // Variável de controle, ao alterar o catalogo de produto, e está com status 5 ( EKD_STATUS = 5=Registrado(pendente: fabricante/ país) ), será questionado se deseja integrar essas pendencias
                         // .F. - Não irá questionar se deseja realizar a integração dessas pendencias
                         // .T. - Irá questionar se deseja realizar a integração dessas pendencias
                         // Devido a rotina automatica, será iniciado como .F.
static _aTabsTmp  := {}
static CP400_PROD := "CP400_SB1"

/*
Programa   : EICCP400   
Objetivo   : Rotina - Catalogo de Produtos
Retorno    : Nil
Autor      : Ramon Prado
Data/Hora  : Dez /2019
Obs.       :
*/
function EICCP400()
   Local aArea       := GetArea()
   Local aCores      := {}
   Local nX          := 1
   Local cModoAcEK9  := FWModeAccess("EK9",3)
   Local cModoAcEKA  := FWModeAccess("EKA",3)
   Local cModoAcEKB  := FWModeAccess("EKB",3)
   Local cModoAcEKD  := FWModeAccess("EKD",3)
   Local cModoAcEKE  := FWModeAccess("EKE",3)
   Local cModoAcEKF  := FWModeAccess("EKF",3)
   Local cModoAcSB1  := FWModeAccess("SB1",3)
   Local cModoAcSA2  := FWModeAccess("SA2",3)
   Local oBrowse

   Private aRotina      := {}
   Private aAtrib       := {}
   Private cValor       := ""
   Private cNCm         := "          "
   Private cModalEK9    := ""
   Private cPrdRefEK9   := ""
   Private cNcmAux      := ""
   Private lRetAux      :=.T.
   Private lMultiFil    := VerSenha(115) .And. cModoAcEK9 == "C" .And. cModoAcSB1 == "E" .And. cModoAcSA2 == "E"
      
      If !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF)
         EasyHelp(STR0025,STR0002) // "Modo de compatilhamento esta diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF "#Atenção
      Else

         aCores := {	{"EK9_STATUS == '1' ","ENABLE"      ,STR0004	},; //"Registrado"
                     {"EK9_STATUS == '5' ","BR_AZUL_CLARO",STR0156},; //Registrado Manualmente
                     {"EK9_STATUS == '2' ","BR_CINZA"	   ,STR0005	},; //"Pendente Registro"
                     {"EK9_STATUS == '3' ","BR_AMARELO"	,STR0006	},; //"Pendente Retificação"
                     {"EK9_STATUS == '4' .or. EK9_MSBLQL == '1' ","DISABLE"     ,STR0007	}}	//"Bloqueado"

         setPedOper(.T.)
         oBrowse := FWMBrowse():New() //Instanciando a Classe
         oBrowse:SetAlias("EK9") //Informando o Alias 
         oBrowse:SetMenuDef("EICCP400") //Nome do fonte do MenuDef
         oBrowse:SetDescription(STR0001) // "Catalogo de Produtos" //Descrição a ser apresentada no Browse   
      
         //Adiciona a legenda
         For nX := 1 To Len( aCores )   	    
            oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
         Next nX
         
         //Habilita a exibição de visões e gráficos
         oBrowse:SetAttach( .T. )
         //Configura as visões padrão
         oBrowse:SetViewsDefault(GetVisions())

         oBrowse:AddFilter(STR0117,"@EK9_MODALI = '1'", .F., .T.) // "Modalidade de Catálogo de Produtos"

         //Força a exibição do botão fechar o browse para fechar a tela
         oBrowse:ForceQuitButton()
         
         //Ativa o Browse
         oBrowse:Activate()
         setPedOper(.F.)
      EndIf

      RestArea(aArea)

Return Nil

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aClone(aRotina)
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function MenuDef()
   Local aRotina := {}

   aAdd( aRotina, { STR0008	, "AxPesqui"         , 0, 1, 0, NIL } )	//'Pesquisar'
   aAdd( aRotina, { STR0009	, 'VIEWDEF.EICCP400' , 0, 2, 0, NIL } )	//'Visualizar'
   aAdd( aRotina, { STR0010 , 'VIEWDEF.EICCP400' , 0, 3, 0, NIL } )	//'Incluir'
   aAdd( aRotina, { STR0011 , 'VIEWDEF.EICCP400' , 0, 4, 0, NIL } )	//'Alterar'
   aAdd( aRotina, { STR0012 , 'VIEWDEF.EICCP400' , 0, 5, 0, NIL } )	//'Excluir'
   aAdd( aRotina, { STR0013 , 'CP400Legen'	     , 0, 6, 0, NIL } )	//'Legenda'
   aAdd( aRotina, { STR0050 , 'CP400CadOE()'     , 0, 6, 0, NIL } )	//'"Cadastra Operador Estrangeiro" '
   aAdd( aRotina, { STR0045 , 'CP400IntCat()'    , 0, 6, 0, NIL } )	//'Integrar'
   aAdd( aRotina, { STR0140 , 'CP400GerCat()'    , 0, 7, 0, NIL } ) // "Geração em lote de catalogo de produtos"

Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ModelDef()
   Local oStruEK9       := FWFormStruct( 1, "EK9", , /*lViewUsado*/ )
   Local oStruEKA       := FWFormStruct( 1, "EKA", , /*lViewUsado*/ )
   Local oStruEKB       := FWFormStruct( 1, "EKB", , /*lViewUsado*/ )
   Local oStruEKC       := FWFormStruct( 1, "EKC", , /*lViewUsado*/ )
   Local bCommit        := {|oModel| CP400COMMIT(oModel)}
   Local bPosValidacao  := {|oModel| CP400POSVL(oModel)}
   Local bCancel        := {|oModel| CP400CANC(oModel)}
   Local oMdlEvent      := CP400EV():New()
   Local bPreVldEKC     := {|oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue| EKCLineValid(oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue)}
   Local bPreVldEKA     := {|oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue| EKAPreValid(oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue)}   
   Local bPosVldEKA     := {|oGridEKA| EKALineValid(oGridEKA)}
   Local bLnPosEKB      := {|oGridEKB| EKBLnVlPos(oGridEKB)}
   Local oModel         // Modelo de dados que será construído	
   Local lMultifil      := VerSenha(115) .And. FWModeAccess("EK9",3) == "C" .And. FWModeAccess("SB1",3) == "E" .And. FWModeAccess("SA2",3) == "E"   
   
      // Criação do Modelo
      oModel := MPFormModel():New( "EICCP400", /*bPreValidacao*/, bPosValidacao, bCommit, bCancel )
      //step 2
      //oModel:setOperation(4)
      If !lMultiFil
         oStruEK9:RemoveField("EK9_FILORI")
      EndIf

      //oStruEK9:RemoveField("EKD_NALADI")
      //oStruEK9:RemoveField("EKD_GPCBRK")
      //oStruEK9:RemoveField("EKD_GPCCOD")
      //oStruEK9:RemoveField("EKD_UNSPSC")
      oStruEK9:SetProperty('EK9_MSBLQL'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_MSBLQL")'    )) //Monta When diferente do dicionário

      // Adiciona ao modelo uma estrutura de formulário de edição por campo
      oModel:AddFields("EK9MASTER", /*cOwner*/ , oStruEK9, /*bPre*/, /*bPost*/, /*bLoad*/)
      oModel:SetPrimaryKey( { "EK9_FILIAL", "EK9_COD_I"} )	

      // Adiciona ao modelo uma estrutura de formulário de edição por grid - Relação de Produtos
      oModel:AddGrid("EKADETAIL","EK9MASTER", oStruEKA, bPreVldEKA , bPosVldEKA, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:GetModel("EKADETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Produto - OSSME-5771 - Critério 7
      oStruEKA:RemoveField("EKA_COD_I")

      // Adiciona ao modelo uma estrutura de formulário de edição por grid - Fabricantes
      oModel:AddGrid("EKBDETAIL","EK9MASTER", oStruEKB, /*bLinePre*/ ,bLnPosEKB, /*bPreVal*/ , /* bPosValEKB */, /*BLoad*/ )   
      oModel:GetModel("EKBDETAIL"):SetOptional( .T. ) //apesar de ser opcional, será validado no PosValid e obrigado a informar ao menos um fabricante ou país
      oStruEKB:RemoveField("EKB_COD_I")

      CpoModel(oStruEKC)
      // Adiciona ao modelo uma estrutura de formulário de edição por grid - Atributos
      oModel:AddGrid("EKCDETAIL","EK9MASTER", oStruEKC, bPreVldEKC ,/*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:GetModel("EKCDETAIL"):SetOptional( .T. ) 
      oModel:GetModel("EKCDETAIL"):SetNoInsertLine(.T.) 
      //oModel:GetModel("EKCDETAIL"):SetDelAllLine(.T.)
      oModel:GetModel("EKCDETAIL"):SetNoDeleteLine(.F.)
      //oModel:GetModel("EKCDETAIL"):SetNoUpdateLine(.T.)
   
      //oStruEKC:RemoveField("EKC_COD_I")
      //oStruEKC:RemoveField("EKC_VERSAO")

      If !lMultiFil
         oStruEKA:RemoveField("EKA_FILORI")
      EndIf

      If !lMultiFil
         oStruEKB:RemoveField("EKB_FILORI")
      EndIf

      //Modelo de relação entre Capa - Produto Referencia(EK9) e detalhe Relação de Produtos(EKA)
      oModel:SetRelation('EKADETAIL', {{ 'EKA_FILIAL' , 'xFilial("EKA")' },;
                                       { 'EKA_COD_I'  , 'EK9_COD_I'     }},;
                                       EKA->(IndexKey(1)) )
                                    
      oModel:SetRelation('EKBDETAIL', {{ 'EKB_FILIAL' , 'xFilial("EKB")' },;
                                       { 'EKB_COD_I'  , 'EK9_COD_I'     }},;
                                       EKB->(IndexKey(1)) )

      oModel:SetRelation('EKCDETAIL', {{ 'EKC_FILIAL'	, 'xFilial("EKC")' },;
                                       { 'EKC_COD_I'  , 'EK9_COD_I'     }},;
                                       "EKC_FILIAL+EKC_COD_I+EKC_CODATR" + if(Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS"),"+EKC_CONDTE",""))
                                    
      If lMultiFil
         oModel:GetModel("EKADETAIL"):SetUniqueLine({"EKA_PRDREF","EKA_FILORI"} )
      Else
         oModel:GetModel("EKADETAIL"):SetUniqueLine({"EKA_PRDREF"} )
      EndIf	
      
      If oStruEKB:hasField("EKB_PAIS")
         If lMultiFil
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA","EKB_PAIS","EKB_FILORI"} )
         Else
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA", "EKB_PAIS"} )
         EndIf	
      Else
         If lMultiFil
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA","EKB_FILORI"} )
         Else
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA"} )
         EndIf	
      EndIf   

      //Adiciona a descrição do Componente do Modelo de Dados
      oModel:GetModel("EK9MASTER"):SetDescription(STR0001) //"Catalogo de Produtos"
      oModel:SetDescription(STR0001) // "Catalogo de Produtos"
      oModel:GetModel("EKADETAIL"):SetDescription(STR0014) //'Relação do Catálogo de Produtos'
      oModel:GetModel("EKBDETAIL"):SetDescription(STR0024) //"Relação de Países de Origem e Fabricantes "
      oModel:GetModel("EKCDETAIL"):SetDescription(STR0040) //"Relação de Atributos"

      oModel:InstallEvent("CP400EV", , oMdlEvent)
      //step 2
      //oModel:setOperation(4)
      
      oStruEK9:SetProperty("EK9_CNPJ",MODEL_FIELD_TAMANHO, AVSX3("EKJ_CNPJ_R", 3))
      //oStruEKB:SetProperty('EKB_CODFAB',MODEL_FIELD_OBRIGAT, .F. )

      oStruEK9:SetProperty("EK9_MODALI",MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'CP400Init(b,a,c)' ))

      oModel:GetModel("EKCDETAIL"):SetOnlyQuery(.T.)

Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ViewDef()
   Local oStruEK9 := FWFormStruct(2, "EK9")
   Local oStruEKA := FWFormStruct(2, "EKA")
   Local oStruEKB := FWFormStruct(2, "EKB")
   Local oStruEKC := FWFormStruct(2, "EKC")
   Local oModel   := FWLoadModel("EICCP400")
   Local oView
   Local aCampos  := {}
   local lMultifil := VerSenha(115) .And. FWModeAccess("EK9",3) == "C" .And. FWModeAccess("SB1",3) == "E" .And. FWModeAccess("SA2",3) == "E"
   local lCatProdEx  := FwIsInCallStack("EECCP400")

   // Cria o objeto de View
   oView := FWFormView():New()

   // Define qual o Modelo de dados será utilizado na View
   oView:SetModel(oModel)

   // Remoção dos campos não utilizados
   oStruEK9:RemoveField("EK9_NALADI")
   oStruEK9:RemoveField("EK9_GPCBRK")
   oStruEK9:RemoveField("EK9_GPCCOD")
   oStruEK9:RemoveField("EK9_UNSPSC")

   if lCatProdEx .and. oStruEK9:HasField("EK9_STATUS")
      oStruEK9:RemoveField("EK9_STATUS")
      oStruEK9:RemoveField("EK9_RETINT")
   endif

   oStruEKA:RemoveField("EKA_COD_I")
   oStruEKB:RemoveField("EKB_COD_I")
   oStruEKC:RemoveField("EKC_COD_I")
   oStruEKC:RemoveField("EKC_VERSAO")
   oStruEKC:RemoveField("EKC_VALOR")
   if oStruEKC:hasField("EKC_CONDTE")
      oStruEKC:RemoveField("EKC_CONDTE")
   endif

   If !lMultiFil
      oStruEK9:RemoveField("EK9_FILORI")
      oStruEKA:RemoveField("EKA_FILORI")
      oStruEKB:RemoveField("EKB_FILORI")
   EndIf

   // Cria o grupo de folders principal (100% da tela)
   oView:CreateHorizontalBox('TELA', 100)
   oView:CreateFolder("MAIN", "TELA") 

   // Cria os folders
   oView:addSheet("MAIN", "F_CATALOGO_PRODUTOS", STR0001) // Catalogo de Produtos
   oView:addSheet("MAIN", "F_ATRIBUTOS", STR0040) // Relação de Atributos
   oView:addSheet("MAIN", "F_RELACAO_PROD", STR0108) // Relação de Produtos x Origens/Fabricantes

   // Cria as divisões nas telas
   oView:CreateHorizontalBox( 'CAT_PROD', 100,,,'MAIN', 'F_CATALOGO_PRODUTOS')
   oView:CreateHorizontalBox( 'REL_ATRI', 100,,,'MAIN', 'F_ATRIBUTOS')
   oView:CreateHorizontalBox( 'REL_PROD_SUP', 50,,,'MAIN', 'F_RELACAO_PROD')
   oView:CreateHorizontalBox( 'REL_PROD_INF', 50,,,'MAIN', 'F_RELACAO_PROD')

   // EK9 - Catálogo de Produtos (capa)
   if lCatProdEx
      // Cria os agrupadores
      oStruEK9:AddGroup("01", STR0109, "01", 2) // Cadastrais
      oStruEK9:AddGroup("02", STR0111, "01", 2) // Dados Complementares

      // Remove os Folders
      oStruEK9:aFolders := {}

      // Lista de campos e seus respectivos grupos
      aCampos := {{"EK9_COD_I", "01"}, {"EK9_IDPORT","01"}, {"EK9_VATUAL","01"}, {"EK9_IMPORT","01"}, {"EK9_CNPJ","01"},;
                  {"EK9_MODALI","01"}, {"EK9_PRDREF","01"}, {"EK9_DESC_I","01"}, {"EK9_NCM", "01"},;
                  {"EK9_DSCNCM","01"}, {"EK9_UNIEST","01"}, {"EK9_IDMANU","01"}, {"EK9_VSMANU","01"},;
                  {"EK9_DSCCOM","02"}, {"EK9_OBSINT","02"}, {"EK9_MSBLQL","02"}, {"EK9_ULTALT","02"}}

      // Adiciona os campos nos grupos
      aEval(aCampos, {|x| oStruEK9:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })
   else
      // Cria os agrupadores
      oStruEK9:AddGroup("01", STR0109, "01", 2) // Cadastrais
      oStruEK9:AddGroup("02", STR0110, "01", 2) // Integração
      oStruEK9:AddGroup("03", STR0111, "01", 2) // Dados Complementares

      // Remove os Folders
      oStruEK9:aFolders := {}

      // Lista de campos e seus respectivos grupos
      aCampos := {{"EK9_COD_I", "01"}, {"EK9_IDPORT","01"}, {"EK9_VATUAL","01"}, {"EK9_IMPORT","01"}, {"EK9_CNPJ","01"},;
                  {"EK9_MODALI","01"}, {"EK9_PRDREF","01"}, {"EK9_DESC_I","01"}, {"EK9_STATUS","01"}, {"EK9_NCM", "01"},;
                  {"EK9_DSCNCM","01"}, {"EK9_UNIEST","01"}, {"EK9_RETINT","02"}, {"EK9_IDMANU","02"}, {"EK9_VSMANU","02"},;
                  {"EK9_DSCCOM","03"}, {"EK9_OBSINT","03"}, {"EK9_MSBLQL","03"}, {"EK9_ULTALT","03"}}

      // Adiciona os campos nos grupos
      aEval(aCampos, {|x| oStruEK9:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })
   endif

   // Demais propriedades
   oView:AddField('CATALOGO_PRODUTOS', oStruEK9, 'EK9MASTER')
   oView:SetOwnerView('CATALOGO_PRODUTOS', 'CAT_PROD')
   oStruEK9:SetProperty("EK9_CNPJ", MVC_VIEW_PICT, AVSX3("EKJ_CNPJ_R", 6))

   // EKC - Atributos
   CpoView(oStruEKC)
   oView:AddGrid("VIEW_EKC", oStruEKC ,"EKCDETAIL")
   oView:SetViewProperty("EKCDETAIL", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)}})  
   oView:SetOwnerView("VIEW_EKC", 'REL_ATRI')

   // EKA - Catálogo de Produtos (detalhes) e EKB - Cadastro de Fabricantes
   oView:AddGrid("VIEW_EKA", oStruEKA, "EKADETAIL")
   oView:AddGrid("VIEW_EKB", oStruEKB, "EKBDETAIL")
   oView:SetOwnerView( "VIEW_EKA", 'REL_PROD_SUP')
   oView:SetOwnerView( "VIEW_EKB", 'REL_PROD_INF')
   oView:EnableTitleView('VIEW_EKA', STR0014 ) //'Relação de Produtos'
   oView:EnableTitleView('VIEW_EKB', STR0024) //"Relação de Países de Origem e Fabricantes"
   oView:AddIncrementField('VIEW_EKA', 'EKA_ITEM')

Return oView

/*
Programa   : CP400CANC
Objetivo   : Ação ao clicar no botao cancelar
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400CANC(oMdl)

   RollbackSx8()

Return .T.

/*
Programa   : CP400POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400POSVL(oMdl)
   Local aArea			:= GetArea()
   Local lRet			:= .T.
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   Local oModelEKB	:= oMdl:GetModel("EKBDETAIL")
   Local oModelEKC	:= oMdl:GetModel("EKCDETAIL")
   Local nI			   := 1
   Local cIdManu     := ""
   Local cVsManu     := ""
   Local cErro       := ""
   Local lPosicEKD   := .F.
   Local lEasyhelp   := .F. 
   Local lEmpPais    := .T. 
   local aAtributos  := {}
   local lAutoExec   := isExecAuto()

      EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão
      If EKD->(AvSeekLAst( xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I") ))
         lPosicEKD := .T.
      EndIf
   
      Begin Sequence
         If oMdl:GetOperation() == 5 //Exclusão
            if Alltrim(oModelEK9:GetValue("EK9_STATUS")) <> "2"
               lRet := .F.
               lEasyhelp := .T.
               EasyHelp(STR0003,STR0002) //"Apenas é possível excluir Catalogo de produto com Status 'Registro Pendente' "##"Atenção"
               break               
            EndIf
            
            If lPosicEKD .And. EKD->EKD_STATUS == '1' .Or. EKD->EKD_STATUS == '3' //Integrado ou Cancelado
               lRet := .F.
               lEasyhelp := .T.
               EasyHelp(STR0048,STR0002) //"Não é possível excluir Catalogo de Produtos que possua integração com status Integrado ou Cancelado" //"Apenas é possível excluir Catalogo de produto com Status 'Registro Pendente' "##"Atenção"
               break               
            EndiF   

            If lRet .And. lPosicEKD
               If !TemIntegEKD(oModelEK9:GetVAlue("EK9_COD_I")) .And. EKD->EKD_STATUS == '2' //nao achou registros Integrados ou Cancelados e a Ultima versao é "Nao Integrado"            
                  cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro Não Integrado     
               Else
                  lRet := .F.	
                  lEasyhelp := .T.
                  EasyHelp(STR0044,STR0002) // "Não é possível excluir Catalogo de Produtos que possua integração com status Integrado ou Cancelado""##"Atenção"
                  break                  
               EndIf
            EndIf

         ElseIf oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusão ou Alteração	

            //grid elação de Países de Origem e Fabricantes Em branco - a linha 1 fica vazia - Lenght igual a 1 - quando há deleção de linhas volta a ficar 0 o Lenght
            If oModelEKB:hasField("EKB_PAIS")
               lEmpPais := Empty(oModelEKB:GetValue("EKB_PAIS"))
            EndIf

            If oModelEKB:Length(.T.) == 0 .Or. ;
                     oModelEKB:Length(.T.) == 1 .And. ;
                     Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. Empty(oModelEKB:GetValue("EKB_LOJA")) .And. ;
                     lEmpPais //Empty(oModelEKB:GetValue("EKB_PAIS"))
               EasyHelp(STR0083,STR0002,STR0084)  //Problema: "Não foram informados fabricantes ou países de origem" Solução: "Informe ao menos um país de origem ou fabricante para prosseguir"
            
               lRet := .F.	
               lEasyhelp := .T.
               break
            EndIf

            cIdManu  := oModelEK9:GetValue("EK9_IDMANU") 
            cVsManu  := oModelEK9:GetValue("EK9_VSMANU") 
            If Empty(oModelEK9:GetValue("EK9_IDPORT")) .And. !Empty(cIdManu) .And. Empty(cVsManu)
               lRet := .F.	
               lEasyhelp := .T.
               EasyHelp(STR0037,STR0002) // "Ao preencher o campo ID Manual também será necessário preencher o campo Versão Manual"##"Atenção"
               break               
            EndIf

            If Empty(oModelEK9:GetValue("EK9_IDPORT")) .And. Empty(cIdManu) .And. !Empty(cVsManu)
               lRet := .F.	
               lEasyhelp := .T.
               EasyHelp(STR0041,STR0002) // "Ao preencher o campo ID Manual também será necessário preencher o campo Versão Manual"##"Atenção"
               break               
            EndIf

            If !empty(cIdManu) .and. !empty(cVsManu)
               cErro := ""
               lRet := ValIdVers( cIdManu , cVsManu , oMdl:GetOperation(), @cErro)
               if lRet .and. oModelEK9:GetValue("EK9_MODALI") == "2" .and. oMdl:GetOperation() == MODEL_OPERATION_UPDATE
                  lRet := ValProcExp( cIdManu , cVsManu, @cErro)
               endif
               If !lRet
                  break
               EndIf
            EndIf

            if lRet .and. ( !lAutoExec )
               aAtributos := getAtrVazio( oModelEKC )
               if len(aAtributos) > 0
                  MsgInfo(STR0120 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0121, STR0002)  // "Existem atributos obrigatórios e vigentes que não foram preenchidos." ### "Revise as informações do catalogo de produtos." ### "Atenção"
               endif
            endif

         EndIf
      End Sequence   
      //coloquei no commit não teve efeito, aqui já é o evento posvalid
      If lRet .And. (oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4) //MFR 11/02/2022 OSSME-6595 
         For nI := 1 to oModelEKC:Length()
            oModelEKC:GoLine( nI )
            If Empty(oModelEKC:GetValue("EKC_VALOR"))
               oModelEKC:DeleteLine()
            EndIf
         Next
      EndIf   

      If !Empty(cErro)
         lRet := .F.
         lEasyhelp := .T.
         EasyHelp(cErro,STR0002) //apresenta a mensagem de Erro da Rotima Automatica ExecAuto ## Atenção
      EndIf

      RestArea(aArea)

Return lRet
/*
Programa   : CP400COMMIT
Objetivo   : Funcao de Commit - utilizado para campos cujo formulario do mvc nao grava  
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Mar/2020
Obs.       :
*/
Static Function CP400COMMIT(oMdl)
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   Local oGridEKB    := oMdl:GetModel("EKBDETAIL")
   Local cIdManu     := ""
   Local cVsManu     := ""
   Local cErro       := ""
   Local cStatusEK9  := "" 
   Local lRet        := .T.
   Local lPosicEKD   := .F.
   Local lRetDif     := .F.
   Local aOEs        := {}
   Local lPendRetif  := .F.
   local lCatProdEx  := FwIsInCallStack("EECCP400")
   local lAutoExec   := .F.

      if !lCatProdEx
         EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão
         If EKD->(AvSeekLast(xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I")))
            lPosicEKD := .T.
         EndIf

         If oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusao ou Alteracao
            // Caso tenha operador estrangeiro relacionado ao produto não cadastrado cadastra via rotina automática
            if CP400OEValid(oGridEKB,oModelEK9,@aOEs)
               CP400ExecEKJ(aOEs,oModelEK9)
               oMdl:activate()
            endif
         endif
      endif

      Begin Transaction
         
         If oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusao ou Alteracao

            cIdManu  := oModelEK9:GetValue("EK9_IDMANU")
            cVsManu  := oModelEK9:GetValue("EK9_VSMANU")

            If !lCatProdEx .and. oMdl:GetOperation() <> 3 
               lRetDif := VerificDif(oMdl)
               If lRetDif .And. !Empty(cVsManu) .And. cVsManu == EK9->EK9_VATUAL
                  lAutoExec := isExecAuto()
                  //se foi encontrada diferença e se não for execauto exibe a pergunta. Senão segue como Sim(Existe Diferença)             
                  If lRetDif .And. !lAutoExec .And. !MsgNoYes(STR0043,STR0002) //"O catalogo alterado foi registrado manualmente no portal único, 
                                                   //deseja gerar uma nova versão para integração automática pelo sistema com os dados informados?" ## "Atenção"
                     lRetDif := .F. 
                  EndIf
               EndIf         
            EndIf
            If lRetDif .And. oMdl:GetOperation() == 4 .And. (!Empty(cVsManu) .And. EK9->EK9_VSMANU == oModelEK9:GetValue("EK9_VSMANU") .Or. oModelEK9:GetValue("EK9_STATUS") $ '1|6')//Se teve alteração e tem versão manual, limpa a informação para que seja possível integrar
               oModelEK9:LoadValue("EK9_VSMANU", " ")
               oModelEK9:LoadValue("EK9_VATUAL", " ")
               cIdManu  := " "
               cVsManu  := " "
               lPendRetif := .T.
            EndIf
            If !Empty(cVsManu) 
               oModelEK9:SetValue("EK9_ULTALT",cUserName)
               oModelEK9:SetValue("EK9_VATUAL", oModelEK9:GetValue("EK9_VSMANU") )
               If !Empty(cIdManu)
                  oModelEK9:SetValue("EK9_IDPORT", oModelEK9:GetValue("EK9_IDMANU") )
               EndIf
            EndIf

            if !lCatProdEx .and. (lRetDif .or. oMdl:GetOperation() == 3)
               if oMdl:GetOperation() == 3 .And. Empty(cVsManu)
                  cStatusEK9 := "2"
               elseif !Empty(oModelEK9:GetValue("EK9_IDPORT")) .And. !Empty(oModelEK9:GetValue("EK9_VATUAL")) .And. Empty(cVsManu)
                  cStatusEK9 := "1"
               elseif oModelEK9:GetValue("EK9_MSBLQL") == "1" 
                  cStatusEK9 := "4"
               elseif lPendRetif .or. (EK9->EK9_STATUS == "3" .And. Empty(cVsManu))
                  cStatusEK9 := "3"
               elseif !Empty(cVsManu)
                  cStatusEK9 := "5" //Registrado Manualmente
               else
                  cStatusEK9 := "2"
               endif
               oModelEK9:SetValue("EK9_STATUS", cStatusEK9)
            EndIf

            If Empty(cErro)
               CommitEKC(oMdl)
               FWFormCommit(oMdl)
               //havendo diferenças, versao manual igual a versao atual - resposta Sim para a pergunta de gerar Inclusao de Integracao Cat Prod.
               If !lCatProdEx .and. (oMdl:GetOperation() == 3 .Or. (lRetDif .and. oModelEK9:GetValue("EK9_MSBLQL") <> "1"))
                  cErro := IncluInteg(oModelEK9)
               EndIf

            Else
               DisarmTransaction()
            EndIf
         EndIf 

         If oMdl:GetOperation() == 5
            CommitEKC(oMdl)
            FWFormCommit(oMdl)
            If lPosicEKD
               cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro Não Integrado     
            EndIf
         EndIf

      End Transaction

      //primeiro commita o catalogo com a alteração do campo para depois incluir a integração e se houver erro a transação de inclusao
      //sera desarmada pela rotina EICCP401
      If !Empty(cErro)
         EECVIEW(cErro,STR0002) //apresenta a mensagem de Erro da Rotima Automatica ExecAuto ## Atenção 
         lRet := .F.
      EndIf

Return lRet

/*
Programa   : IncluInteg
Objetivo   : Funcao utilizada para Incluir integração do catálogo de produtos 
Retorno    : Caractere - Erro da Execução Automatica
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function IncluInteg( oModelEK9)
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

      aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")                    , Nil})
      aAdd(aCapaEKD,{"EKD_COD_I"	, oModelEK9:GetValue("EK9_COD_I")   , Nil})

      MSExecAuto({|a,b| EICCP401(a,b)}, aCapaEKD, 3)

      If lMsErroAuto
         aErros := GetAutoGRLog()
         For nJ:= 1 To Len(aErros)
            cLogErro += aErros[nJ]+ENTER
         Next nJ
      EndIf

Return cLogErro

/*
Programa   : VerificDif(oMdl)
Objetivo   : Funcao utilizada para Incluir integração do catálogo de produtos 
Retorno    : Caractere - Erro da Execução Automatica
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function VerificDif(oMdl)
   Local oModelEK9   := oMdl:GetModel("EK9MASTER")
   Local oModelEKA   := oMdl:GetModel("EKADETAIL")
   Local oModelEKB   := oMdl:GetModel("EKBDETAIL")
   Local oModelEKC   := oMdl:GetModel("EKCDETAIL")
   Local nI          := 0
   Local lAchouDif   := .F.
   Local cChaveEKA   := ""
   Local cChaveEKB   := ""
   Local cChaveEKC   := ""
   Local cVersaoEKD
   
      begin sequence

         //Verifica se foi excluido o registro da EKD. Se sim, gera um novo
         cVersaoEKD := CPGetVersion(xFilial("EKD"), oModelEK9:GetValue("EK9_COD_I"))
         If !EKD->(dbsetorder(1),DbSeek(xFilial("EKD") + oModelEK9:GetValue("EK9_COD_I") + cVersaoEKD))
            lAchouDif := .T.
            break            
         EndIf

         If EK9->EK9_IDPORT <> oModelEK9:GetValue("EK9_IDPORT") .Or. EK9->EK9_VATUAL <> oModelEK9:GetValue("EK9_VATUAL") .Or. ;
            EK9->EK9_IMPORT <> oModelEK9:GetValue("EK9_IMPORT") .Or. AvKey(EK9->EK9_CNPJ, "EKJ_CNPJ_R") <> AvKey(oModelEK9:GetValue("EK9_CNPJ"), "EKJ_CNPJ_R")   .Or. ;
            EK9->EK9_MODALI <> oModelEK9:GetValue("EK9_MODALI") .Or. EK9->EK9_NCM    <> oModelEK9:GetValue("EK9_NCM")    .Or. ;
            EK9->EK9_UNIEST <> oModelEK9:GetValue("EK9_UNIEST") .Or. EK9->EK9_STATUS <> oModelEK9:GetValue("EK9_STATUS") .Or. ;
            !(EK9->EK9_DSCCOM == oModelEK9:GetValue("EK9_DSCCOM")) .Or. !(EK9->EK9_RETINT == oModelEK9:GetValue("EK9_RETINT")) .Or. ;
            EK9->EK9_IDMANU <> oModelEK9:GetValue("EK9_IDMANU") .Or. EK9->EK9_VSMANU <> oModelEK9:GetValue("EK9_VSMANU") .Or. ;
            EK9->EK9_MSBLQL <> oModelEK9:GetValue("EK9_MSBLQL") .or. (getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V" .And. EK9->EK9_DESC_I <> oModelEK9:GetValue("EK9_DESC_I")) .Or. ;
            (lMultiFil .AND. EK9->EK9_FILORI <> oModelEK9:GetValue("EK9_FILORI")) 
               lAchouDif := .T.
               break
         EndIf

         For nI := 1 To oModelEKA:Length()
            oModelEKA:GoLine( nI )
            If oModelEKA:isInserted() .And. !Empty(oModelEKA:GetValue("EKA_PRDREF")) //Quando vazio, sempre da .t. no isInserted, pois adiciona uma linha em branco
               lAchouDif := .T.
               break   
            EndIf
            if ! oModelEKA:isdeleted()
               cChaveEKA := xFilial("EKA") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKA_COD_I",3)) + oModelEKA:GetValue("EKA_PRDREF")
               If !Empty(oModelEKA:GetValue("EKA_PRDREF")) .And. ! EKA->(DbSetOrder(1),MsSeek(cChaveEKA))
                  lAchouDif := .T.
                  break
               EndIf
            else
               lAchouDif := .T.
               break
            EndIf
         Next nI
         
         For nI := 1 To oModelEKB:Length()
            oModelEKB:GoLine( nI )
            If oModelEKB:isInserted()
               lAchouDif := .T.
               break   
            EndIf
            if ! oModelEKB:isdeleted()
               cChaveEKB := xFilial("EKB") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKB_COD_I",3)) + oModelEKB:GetValue("EKB_CODFAB") + oModelEKB:GetValue("EKB_LOJA")
               If ! EKB->(dbsetorder(1),MsSeek(cChaveEKB))
                  lAchouDif := .T.
                  break
               EndIf
            else
               lAchouDif := .T.
               break
            endif
         Next nI

         For nI := 1 To oModelEKC:Length()
            oModelEKC:GoLine( nI )
            if ! oModelEKB:isdeleted()
               cChaveEKC := xFilial("EKC") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKC_COD_I",3)) + oModelEKC:GetValue("EKC_CODATR")
               If EKC->(dbsetorder(1),MsSeek( cChaveEKC ))
                  If EKC->EKC_VERSAO <> oModelEKC:GetValue("EKC_VERSAO") .Or. ;
                     EKC->EKC_VALOR  <> oModelEKC:GetValue("EKC_VALOR")
                     lAchouDif := .T.
                     break
                  EndIf
               elseIf !Empty(oModelEKC:GetValue("EKC_VALOR"))
                  lAchouDif := .T.
                  break
               EndIf
            else
               lAchouDif := .T.
               break
            endif
         Next nI

      end sequence

Return lAchouDif
/*/{Protheus.doc} CP400Integrar
   Função para realizar a integração do operador estrangeiro com o siscomex
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   @param aCatalogos - array com o recno do catálogo de produtos a ser integrado, se vazio registra o posicionado no browse
   @return Nil
   /*/
Function CP400Integrar(aCatalogos)
   Local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
   Local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br 
   Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   Local cVersaoEKD  := ""
   Local cErros      := ""
   Local lRet        := .T.
   Local aRetIntCP   := {lRet,.T.}
   Local oProcess
   Local cLib

   Private cURLIACP    := "/catp/api/ext/produto"
   Private cURLAuth    := "/portal/api/autenticar"
   Private cURLIFbrPO  := "/catp/api/ext/fabricante"
   Private cCPPathAuth := ""
   Private cPathIACP   := ""
   Private cCabURLGov  := cURLTest

   Default aCatalogos  := {}

   GetRemoteType(@cLib)
   If 'HTML' $ cLib
      easyhelp(STR0099,STR0021,STR0100) // "Integração com Portal Único não disponível no smartclientHtml","Utilizar o smartclient aplicativo"
   Else

      begin sequence

            if EK9->EK9_STATUS == "4" .or. EK9->EK9_MSBLQL == "1"
               EasyHelp( StrTran(STR0116,"######",EK9->EK9_COD_I),STR0021) // "O catálogo de produto ###### está com status igual a 'Bloqueado'."
               lRet := .F.
               break
            endif

         // Caso não receba parâmetro faz a inclusão do registro posicionado 
            if len(aCatalogos) == 0
               cVersaoEKD := CPGetVersion(xFilial("EKD"),EK9->EK9_COD_I)
               if EKD->(dbsetorder(1),msseek(xFilial("EKD")+EK9->EK9_COD_I+cVersaoEKD))
                  If EKD->EKD_STATUS $ "2|4|5"
                     aadd(aCatalogos, EKD->(recno()) )
                  Else
                     EasyHelp( StrTran(STR0070,"######",EK9->EK9_COD_I),STR0021) //"Catálogo ###### com status igual a Integrado ou Cancelado não pode ser integrado" //Aviso
                     lRet := .F.
                     break
                  EndIf
               endif
            endif

         if len(aCatalogos) > 0
            if ! lIntgProd 
               // se não for execauto exibe a pergunta se não segue como sim
               if !msgnoyes( STR0051 + ENTER ; // "O sistema está configurado para integração com a Base de Testes do Portal Único."
                           + STR0052 + ENTER ; // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
                           + STR0053 + ENTER ; // "Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EEC0054' para 1."
                           + STR0054 , STR0002 ) // "Deseja Prosseguir?" // "Atenção"
                     lRet := .F.
                     break
               else
                  cCPPathAuth := cURLTest+cURLAuth
                  cPathIACP   := cURLTest+cURLIACP
               endif
            else
               cCPPathAuth := cURLProd+cURLAuth
               cPathIACP   := cURLProd+cURLIACP
               cCabURLGov  := cURLProd
            endif

            oProcess := MsNewProcess():New({|lEnd| aRetIntCP := CP400Sicomex(aCatalogos,cCPPathAuth,cPathIACP,oProcess,lEnd,@cErros) },;
                     STR0055 , STR0056 ,.T.) // "Integrar Catálogo de Produtos" , "Processando integração"
            oProcess:Activate()

            if !Empty(cErros) .and. !aRetIntCP[1]
               EECView(cErros,STR0049) // Falha de integração
               lRet := .F.
            ElseIf aRetIntCP[1]
               If aRetIntCP[2]
                  MsgInfo(STR0047,STR0021) //"Integrado com sucesso" //"Aviso"               
                  lRet := .T. 
               Else
                  MsgInfo(STR0089 + ENTER + STR0092 ,STR0021) //"Produto integrado com sucesso no catálogo, porém possui pendências entre fabricantes ou países de origem relacionados!"          //"Aviso"               
                  lRet := .T.   
               EndIf                                           //"Consulte na rotina de integração do catálogo de produtos o log de erro gerado para a última versão de integração do produto!"
            endif
         endif

      end sequence
   endif

Return lRet

/*/{Protheus.doc} CP400Sicomex
   Função que realiza a integração com o siscomex para cada item do array aCatalogos
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Function CP400Sicomex(aCatalogos,cCPPathAuth,cPathIACP,oProcess,lEnd,cErros)
   Local cRet           := ""
   Local cAux           := ""
   Local cPerg          := ""
   Local cCodigo        := ""
   Local cChaveEKE      := ""
   Local cSucesso       := ""
   Local ctxtJson       := ""
   Local cModalidade    := ""
   Local cCodinterno    := ""
   local cAtributos     := ""

   Local aJson          := {}
   Local aJsonErros     := {}
   Local aOperadores    := {}

   Local lRet           := .T.
   Local nj
   Local nCP
   Local nContCP        := 0
   Local nQtdInt        := len(aCatalogos)

   Local oJson
   Local oEasyJS

   Local xRetJson
   Local lIntFbrPsO     := .T.
   Local aRet           := {lRet,lIntFbrPsO}
   Local lEKI           :=.F.
   Local cDenomi        := ""

      begin sequence
         // se não for execauto alimenta reguas de processamento
         oProcess:SetRegua1(nQtdInt)

         // percorre o array de catálogos a serem entregados
         for nCP := 1 to nQtdInt
            lEKI := .F.
            //houve cancelamento do processo
            If lEnd
               lRet := .F.
               break
            EndIf
            
            // posiciona na capa do integrador
            EKD->(dbgoto(aCatalogos[nCP]))
            EK9->(dbsetorder(1),msseek(xFilial("EK9")+EKD->EKD_COD_I))
            // se for diferente de registrado e bloqueado
            If EKD->EKD_STATUS $ "2|4|5"

               // se não for execauto alimenta reguas de processamento
               oProcess:IncRegua1( STR0086 + alltrim(EKD->EKD_COD_I) + "/" + alltrim(EKD->EKD_VERSAO) ) // "Integrando:"
               oProcess:SetRegua2(1)

               // validação dos operadores estrangeiros se estão cadastrados e registrados
               if CP400VldOE(@cErros,@cPerg,@aOperadores)

                  // se houver operador estrangeiro no catálogo de produtos e não no integrador aborta a integração
                  if ! empty(cErros)
                     lRet := .F.
                     break
                  endif

                  // caso tenha operadores que ainda não estejam integrados com portal único 
                  if ! empty(cPerg) .and. len(aOperadores) > 0
                     // é perguntado se deseja o envio dos mesmos, caso não aborta integração do catálogo
                     if !MsgNoYes( STR0057 + ENTER ; //"Os operadores estrangeiros abaixo não estão integrados"  
                           + cPerg ;
                           + STR0058 , STR0002 ) // "Deseja integrar agora?" // "Atenção"
                              lRet := .F.
                              break
                     else
                        lOE400Auto := .F.
                        if !OE400Integrar(aOperadores,.T.)
                           lRet := .F.
                           break
                        endif
                     endif
                  endif
               endif

               if EKD->EKD_MODALI == "1" // =Importacao
                  cModalidade := "IMPORTACAO"
               elseif EKD->EKD_MODALI == "2" // =Exportacao
                  cModalidade := "EXPORTACAO"
               elseif empty(EKD->EKD_MODALI) .or. EKD->EKD_MODALI == "3" // =Ambos
                  cModalidade := "AMBOS"
               endif

               //NCF - 08/05/2021 - Alteração na forma de envio dos fabricantes.
               /*
               // posiciona no primeiro fabricante relacionado para validar montagem do json
               if EKB->(dbsetorder(1),msseek(xFilial("EKB") + EKD->EKD_COD_I))
                  // caso tenha fabricante o fabricante conhecido será enviado como true
                  cFabrConhecido := "true"

                  cChaveEKJ := xFilial("EKJ") + EKD->EKD_CNPJ + EKB->EKB_CODFAB + EKB->EKB_LOJA
                  if EKJ->(dbsetorder(1),msseek(cChaveEKJ))
                     // se o país origem do fabricante for brasil manda o cnpj do cadastro do fabricante 
                     cPaisOrigem := EKJ->EKJ_PAIS
                     if cPaisOrigem == "BR"
                        SA2->(dbsetorder(1),msseek(xFilial("SA2") + EKB->EKB_CODFAB + EKB->EKB_LOJA))
                        cCpfCnpjFabric := SA2->A2_CGC
                        cCodigoOE      := ""
                     else // se o pais origem for diferente de brasil manda o código do operador estrangeiro
                        cCodigoOE      := EKJ->EKJ_TIN
                        cCpfCnpjFabric := ""
                     endif
                  endif
               else // caso não tenha fabricante será enviado como false
                  cFabrConhecido := "false"
               endif
               */

               cAtributos := getJsonAtt(@lEKI)
               if !empty(cAtributos)
                  // Monta o texto do json para a integração
                  ctxtJson := '[{ "seq": '                 + "1"                    + ' ,'
                  // opcional, caso esteja em branco é inclusão e não deve ser enviado, depois de preenchido é alteração
                  if ! empty(EKD->EKD_IDPORT)
                     ctxtJson += ' "codigo": "'             + EKD->EKD_IDPORT        + '" ,'
                  endif
                  
                  cDenomi := Posicione("SB1", 1, xFilial("SB1") + EK9->EK9_PRDREF, "B1_DESC")
                  If getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V" .And. !Empty(EK9->EK9_DESC_I)
                     cDenomi := EK9->EK9_DESC_I
                  EndIf
                  ctxtJson += ' "descricao": "'                + alltrim(strtran(EK9->EK9_DSCCOM, chr(13)+chr(10), " ")) + '",' + ;
                              ' "denominacao": "'              + Alltrim(cDenomi)         + '",' +;
                              ' "cpfCnpjRaiz": "'              + EKD->EKD_CNPJ            + '",' + ;
                              ' "situacao": "'                 + "ATIVADO"                + '",' + ;
                              ' "modalidade": "'               + cModalidade              + '",' + ;
                              ' "ncm": "'                      + Alltrim(EKD->EKD_NCM)    + '",'

                  //NCF - 08/05/2021 - Alteração na forma de envio dos fabricantes.
                  /*
                              ' "paisOrigem": "'               + cPaisOrigem            + '",' + ;
                              ' "fabricanteConhecido": '       + cFabrConhecido         + ' ,'
                  
                  // define o fabricante caso exista 
                  if cFabrConhecido == "true"
                     if cPaisOrigem == "BR"
                        ctxtJson += ' "cpfCnpjFabricante": "'         + cCpfCnpjFabric   + '",' 
                     else
                        ctxtJson += ' "codigoOperadorEstrangeiro": "' + cCodigoOE        + '",' 
                     endif
                  endif
                  */

                  //++++ATRIBUTOS+++++ - EKI - percorre os atributos cadastrados para o catálogo de produto enviando atributo e valor
                  ctxtJson += cAtributos //Retorna os atributos montados no formato json para a integração do catálogo

                  // percorre a lista de código relacionados que são enviados em lista
                  cChaveEKE := xFilial("EKE") + EKD->EKD_COD_I + EKD->EKD_VERSAO
                  if EKE->(dbsetorder(1),msseek(cChaveEKE))
                     cCodinterno := if(lEKi,',','') +' "codigosInterno": [ '
                        while EKE->(! eof()) .and. EKE->(EKE_FILIAL+EKE_COD_I+EKE_VERSAO) == cChaveEKE

                           nContCP++
                           if nContCP > 1
                              cCodinterno += ','
                           endif

                           cCodinterno += '"' + EKE->EKE_PRDREF + '"'

                           EKE->(dbskip())
                        enddo
                     cCodinterno += ']'
                     ctxtJson += cCodinterno
                     nContCP := 0
                  endif
                  ctxtJson +=   '}' + ;
                           ']'

                  // consome o serviço através do easyjs
                  oEasyJS  := EasyJS():New()
                  oEasyJS:cUrl := cCPPathAuth
                  oEasyJS:Activate(.T.)
                  oEasyJS:runJSSync( CP400Auth( cCPPathAuth , cPathIACP , ctxtJson ) ,{|x| cRet := x } , {|x| cErros := x } )

                  // Pega o retorno e converte para json para extrair as informações
                  if ! empty(cRet) .and. empty(cErros)
                     cRet     := '{"items":'+cRet+'}'
                     oJson    := JsonObject():New()
                     xRetJson := oJson:FromJson(cRet)
                     if valtype(xRetJson) == "U" 
                        if valtype(oJson:GetJsonObject("items")) == "A"
                           aJson    := oJson:GetJsonObject("items")
                           if len(aJson) > 0
                              cSucesso := aJson[1]:GetJsonText("sucesso")
                              cCodigo  := aJson[1]:GetJsonText("codigo")
                              cVersaoJS:= StrZero(val(aJson[1]:GetJsonText("versao")), AvSX3("EK9_VATUAL",AV_TAMANHO))
                              if valtype(aJson[1]:GetJsonObject("erros")) == "A"
                                 aJsonErros := aJson[1]:GetJsonObject("erros")
                                 for nj := 1 to len(aJsonErros)
                                    cErros += aJsonErros[nj] + ENTER
                                 next
                                 if empty(cErros)
                                    cErros += STR0060
                                 endif
                              endif
                              If AvExisteInd({{"EKD","3"}}) .And. ExistCpo("EKD",EK9->EK9_COD_I + AvKey(cCodigo,"EK9_IDPORT") + AvKey(cVersaoJS,"EK9_VSMANU"), 3, , .F.)
                                 cErros += STR0162 +" (" +Alltrim(cCodigo)+"/"+Alltrim(cVersaoJS)+ ")" + ENTER //"O ID e Versão retornados pela integração já existem no histórico de Integrações do Catálogo de Produtos."
                                 cErros += STR0163 + ENTER //"Para utilizar este ID e Versão, recomendamos tornar obsoleto o registro atual e incluir um novo Catálogo de Produtos, informando os campos ID Manual e Versão Manual."
                                 cSucesso := "false"
                              EndIf 
                           endif
                        else
                           cErros += STR0059 + ENTER // "Arquivo de retorno sem itens!"
                        endif
                        FreeObj(oJson)
                     else
                        // cErros += STR0060 + ENTER // "Arquivo de retorno inválido!"
                        cErros += STR0071 + ENTER + alltrim(cRet) // "Não foi possível fazer o parse do JSON de retorno da integração."
                     endif
                  elseif ! empty(cErros)
                     if match(cErros,"*Failed to fetch*")
                        cErros := STR0072 + ENTER // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto."
                     endif
                  elseif empty(cErros)
                     cErros += STR0061 + ENTER // "Integração sem nenhum retorno!"
                  endif

                  // caso dê tudo certo grava as informações e finaliza o registro
                  if ! empty(cRet) .and. ! empty(cSucesso) .and. upper(cSucesso) == "TRUE"

                        //NCF - 08/05/2021 - Realiza a integração de Fabricantes/País de Origem
                        cPathIFbPO := cCabURLGov + cURLIFbrPO
                        oProcIntFb := MsNewProcess():New({|lEnd| lIntFbrPsO := CP400IFbPO(cCPPathAuth,cPathIFbPO,oProcIntFb,lEnd,@cErros,oEasyJS) }, STR0085 , STR0056 ,.T.) // "Integrar Fabricante" , "Processando integração"
                        oProcIntFb:Activate()
                        cStIntCP   := If( lIntFbrPsO , "1" , "5" )  // 5-Registrado (pendente: fabricante/ país)
                        If(!lIntFbrPsO , aRet[2] := lIntFbrPsO , )  // Indicar erro na integração de fabrincantes/país em uma das integrações de produto.

						      reclock("EKD",.F.)
                        EKD->EKD_STATUS   := cStIntCP
                        EKD->EKD_IDPORT   := cCodigo
                        If EKD->(ColumnPos("EKD_VATUAL")) > 0
                           EKD->EKD_VATUAL   := cVersaoJS
                        EndIf
                        EKD->EKD_DATA     := dDatabase
                        EKD->EKD_HORA     := strtran(time(),":","")
                        EKD->EKD_USERIN   := __cUserID
                        EKD->EKD_RETINT   := If( cStIntCP == "5", STR0091 + ENTER + Alltrim(cErros)  ,"") //"Erros de retorno da integração de Fabricantes/Países de Origem relacionados ao produto integrado:"
                        EKD->(msunlock())

						      // grava o status de registrado do catálogo de produtos
						      reclock("EK9",.F.)
                        EK9->EK9_STATUS   := "1"
                        EK9->EK9_IDPORT   := cCodigo
                        EK9->EK9_VATUAL   := cVersaoJS
                        EK9->EK9_RETINT   := ""
						      EK9->(msunlock())

                        oProcess:IncRegua2( STR0062 ) // "Integrado!"
                        oProcess:IncRegua2( STR0062 ) // "Integrado!"
                  else // caso não grava o log, se não tiver ret tem algum erro.
                     lRet := .F.
                     cErros := STR0164 + dtoc(dDatabase) + " as " + time() + ENTER + cErros + ENTER //"Erro ao integrar em "
                     cErros := STR0165 + alltrim(EKD->EKD_COD_I) + "/" + alltrim(EKD->EKD_VERSAO) + ENTER + cErros + ENTER //"Produto/Seq. Histórico: "
                     reclock("EKD",.F.)
                        EKD->EKD_STATUS   := "4"
                        // EKD->EKD_DATA     := dDatabase
                        // EKD->EKD_HORA     := strtran(time(),":","")
                        EKD->EKD_USERIN   := __cUserID
                        EKD->EKD_RETINT   := cErros
                        EKD->(msunlock())

                        // grava o status de falha do catálogo de produtos
                        reclock("EK9",.F.)
                        EK9->EK9_RETINT   := cErros
                        EK9->(msunlock())

                     oProcess:IncRegua2( STR0063 ) // "Falha!"
                     oProcess:IncRegua2( STR0063 ) // "Falha!"
                  endif
               endif
            endif
            
            cAux += cErros + ENTER
            cErros   := ""
            cRet     := ""
            cCodigo  := ""
            cSucesso := ""
         next
      end sequence

      aRet[1] := lRet

      if ! empty(cAux)
         cErros := cAux
      endif

Return aClone(aRet)

/*/{Protheus.doc} CP400Auth
   Gera o script para autenticar e consumir o serviço do portaul unico através do easyjs 
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Static Function CP400Auth(cUrl,cPathIACP,cOperador)
   Local cVar

   begincontent var cVar
      fetch( '%Exp:cUrl%', {
         method: 'POST',
         mode: 'cors',
         headers: { 
            'Content-Type': 'application/json',
            'Role-Type': 'IMPEXP',
         },
      })
      .then( response => {
         if (!(response.ok)) {
            throw new Error( response.statusText );
         }
         var XCSRFToken = response.headers.get('X-CSRF-Token');
         var SetToken = response.headers.get('Set-Token');
         return fetch( '%Exp:cPathIACP%', {
            method: 'POST',
            mode: 'cors',
            headers: { 
               'Content-Type': 'application/json',
               "Authorization": SetToken,
               "X-CSRF-Token":  XCSRFToken,
            },
            body: '%Exp:cOperador%'
         })
      })
      .then( (res) => res.text() )
      .then( (res) => { retAdvpl(res) } )
      .catch((e) => { retAdvplError(e) });
   endcontent

Return cVar

/*
Programa   : CP400VldOE
Objetivo   : validar se no cadastro de operador estrangeiro o mesmo está integrado ao portal único
           : e se o operador está registrado no integrador do catálogo de produtos
Retorno    : lRet
Autor      : Miguel Prado Gontijo
Data/Hora  : 21/07/2020
Obs.       :
*/
Function CP400VldOE(cErros,cPerg,aOperadores)
   Local aAreaEKB    := EKB->(getarea())
   Local aAreaEKJ    := EKJ->(getarea())
   Local cChaveEKB   := ""
   Local cChaveEKJ   := ""
   Local nContOE     := 0
   Local lRet        := .F.
   Local lEkbPAis    :=EKB->(FieldPos("EKB_PAIS")) > 0

   // posiciona nos fabricantes relacionados ao catálogo de produtos
   cChaveEKB := xFilial("EKB") + EKD->EKD_COD_I
   if EKB->(dbsetorder(1),msseek(cChaveEKB))
      // enquanto houverem fabricantes/pais de origem relacionados a esse catálogo de produtos 
      while EKB->( ! eof() ) .and. EKB->EKB_FILIAL+EKB->EKB_COD_I == cChaveEKB

         // verifica se o operador estrangeiro está cadastrado 
         cChaveEKJ := xFilial("EKJ") + EKD->EKD_CNPJ + EKB->EKB_CODFAB + EKB->EKB_LOJA
         if !empty(EKB->EKB_CODFAB) .And. EKJ->(dbsetorder(1),msseek(cChaveEKJ))  //NCF - 08/05/2021 - Fabricante deve estar informado para integraro o operador(se existir)
            
            // verifica se o mesmo está integrado ao portal único
            if EKJ->EKJ_STATUS <> "1" .And. !Empty(EKB->EKB_CODFAB)
               cPerg += strtran( STR0064 , "XXXX" , alltrim(EKJ->EKJ_FORN) + "/" + alltrim(EKJ->EKJ_FOLOJA)) + ENTER // STR0064 - "Fabricante XXXX não integrado!"
               // adciona o operador para realizar a integração com portal único
               aadd( aOperadores, EKJ->(recno()))
            endif
         else
            // NCF - 08/02/2021 - verifica se possui o país de origem cadastrado, pois se tiver não precisa ter o cadastro de operador estrangeiro.
            if !lEkbPAis /* EKB->(FieldPos("EKB_PAIS"))==0 */ .Or. Empty(EKB->EKB_PAIS)
               nContOE++
               // caso seja o primeiro registro insere informação do produto e versão a relatar o problema
               if nContOE == 1
                  cErros += strtran(  STR0065 , "XXXX" , alltrim(EKD->EKD_COD_I) + "/" + alltrim(EKD->EKD_VERSAO)) + ENTER // "Produto/Versão: XXXX "
               endif
               cErros += strtran(  STR0066 , "XXXX" , alltrim(EKB->EKB_CODFAB)  + "/" + alltrim(EKB->EKB_LOJA)) + ENTER // "Fabricante/Loja XXXX não registrado como operador estrangeiro!"
            endif
         endif
 
         EKB->(dbskip())
      enddo
   endif

   lRet := ! empty(cErros) .or. (! empty(cPerg) .and. len(aOperadores) > 0)

   restarea(aAreaEKB)
   restarea(aAreaEKJ)

Return lRet
/*{Protheus.doc} CPGetVersion
   Busca a última versão do integrador do catálogo de produtos
   @author Miguel Prado Gontijo
   @since 20/06/2020
   @version 1
   @param cFilial e cXCodI - Filial e código do item a ser buscado a última versão
   @return Nil
*/
function CPGetVersion( cXFil , cXCodI )
   Local cRet := ""

   if select("EKDVERSAO") > 0
      EKDVERSAO->(dbclosearea())
   endif

   BeginSql Alias "EKDVERSAO"
      select MAX(EKD_VERSAO) VERSAO 
      from %table:EKD% EKD 
      where EKD_FILIAL  = %Exp:cXFil%
         and EKD_COD_I  = %Exp:cXCodI%
         and EKD.%NotDel%
   EndSql

   if EKDVERSAO->(! eof())
      cRet := EKDVERSAO->VERSAO
   endif
   EKDVERSAO->(dbclosearea())

Return AvKey(cRet,"EKD_VERSAO")
/*
Programa   : CP400CadOE
Objetivo   : Inserir registros no cadastro de operador estrangeiro
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : 10/06/2020
Obs.       :
*/
Function CP400CadOE()
   Local oModel      := FWLoadModel("EICCP400")
   Local oModelEKB   := oModel:GetModel("EKBDETAIL")
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local aOEs        := {}
   Local lRet := .t.

   oModel:Activate()
   if CP400OEValid(oModelEKB,oModelEK9,@aOEs)
      lRet := CP400ExecEKJ(aOEs,oModelEK9)
      oModel:activate()
   Else 
         EasyHelp( StrTran(STR0069,"######",EK9->EK9_COD_I),STR0021) //Aviso Nenhum registro para processar. Todos os fabricantes do catálogo ###### já se encontram no cadastro de operador estrangeiro
   endif

Return
/*
Programa   : CP400OEValid
Objetivo   : Funcao que valida se deve gerar o cadastro de operador estrangeiro a partir do cadastro de fabricante relacionado ao produto do catálogo
Retorno    : Lógico
Autor      : Miguel Gontijo
Data/Hora  : 06/2020
Obs.       :
*/
static function CP400OEValid(oModelEKB,oModelEK9,aOEs)
   Local lRet        := .F.
   Local nLinEKB     := 1
   Local cChaveEKJ2  := ""
   Local aAux        := {}
   Local aAreaEKJ    := EKJ->(getarea())

   for nLinEKB := 1 to oModelEKB:length()
      if ! oModelEKB:isdeleted(nLinEKB)
         if ! empty( oModelEKB:getvalue("EKB_CODFAB", nLinEKB) ) .and. ! empty( oModelEKB:getvalue("EKB_LOJA", nLinEKB) )
            cChaveEKJ2 := xFilial("EKJ") + AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R") + oModelEKB:getvalue("EKB_CODFAB", nLinEKB)  + oModelEKB:getvalue("EKB_LOJA", nLinEKB)
            if ! EKJ->(dbsetorder(1),msseek(cChaveEKJ2))
               aAux := {}
               Aadd( aAux, { "EKJ_FILIAL"  , xFilial("EKJ")                            , Nil })
               Aadd( aAux, { "EKJ_IMPORT"  , oModelEK9:GetValue("EK9_IMPORT")          , Nil })
               Aadd( aAux, { "EKJ_CNPJ_R"  , AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R"), Nil })
               Aadd( aAux, { "EKJ_FORN"    , oModelEKB:getvalue("EKB_CODFAB" , nLinEKB) , Nil })
               Aadd( aAux, { "EKJ_FOLOJA"  , oModelEKB:getvalue("EKB_LOJA"   , nLinEKB) , Nil })
               aadd( aOEs, aclone(aAux))
            endif
         endif
      endif
   next

   lRet := len(aOEs) > 0

   restarea(aAreaEKJ)
return lRet


/*
Programa   : CP400ExecEKJ(aOEs)
Objetivo   : ExecAuto de Operador Estrangeiro - Grava o fabricante na tabela de operador estrangeiro
Parâmetro  : aOEs - array que contém uma lista de operadores a serem incluídos via rotina automática
Retorno    : Nil
Autor      : Miguel Gontijo
Data/Hora  : 06/2020
Obs.       :
*/
function CP400ExecEKJ(aOEs,oModelEK9)
   Local aArea       := getarea()
   Local aLog        := {}
   Local i           := 0
   Local nx          := 0
   Local nPosForn    := ""
   Local nPosFoLoja  := ""
   Local cMsg        := ""
   Local lRet        := .T.
   local lAutoExec   := isExecAuto()

   Private lMsErroAuto     := .F.
   Private lAutoErrNoFile  := .T.
   Private lMsHelpAuto     := .F. 

   For i := 1 to len(aOEs)
      lMsErroAuto := .F.
      MsExecAuto({|x,y| EICOE400(x,y) },aOEs[i], 3)
      if lMsErroAuto
         lRet := .F.
         aLog        := GetAutoGrLog()
         nPosForn    := ascan(aOEs[i], {|x| x[1] == "EKJ_FORN" })
         nPosFoLoja  := ascan(aOEs[i], {|x| x[1] == "EKJ_FOLOJA" })
         cMsg        += STR0074 + alltrim(oModelEK9:getvalue('EK9_COD_I')) + ENTER //"Erro na inclusão do registro de operador estrangeiro para o catálogo "
         cMsg        += STR0077 + Alltrim(aOEs[i][nPosForn][2]) + " Loja: " + Alltrim(aOEs[i][nPosFoLoja][2]) + ENTER //"Fornecedor: "
         cMsg        += STR0078 + ENTER //"Esse erro não intefere na gravação do catálogo de produtos(Veja mensagem abaixo)"
         for nx := 1 to len(aLog)
            cMsg += Alltrim(aLog[nx]) + ENTER
         Next
      EndIf
   Next

   if !empty(cMsg) .and. !lAutoExec
      EECVIEW(cMsg, STR0002,,,,, .T.)
   endif

   restarea(aArea)

return lRet
/*
Programa   : ExcIntegr
Objetivo   : Funcao utilizada para excluir integração do catálogo de produtos Não Integrada
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function ExcIntegr( cCat, cVersao )
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

   aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")  , Nil})
   aAdd(aCapaEKD,{"EKD_COD_I"	, cCat            , Nil})
   aAdd(aCapaEKD,{"EKD_VERSAO", cVersao         , Nil})

   MSExecAuto({|a,b| EICCP401 (a,b)}, aCapaEKD, 5)

   If lMsErroAuto
      aErros := GetAutoGRLog()
      For nJ:= 1 To Len(aErros)
         cLogErro += aErros[nJ]+ENTER
      Next nJ
   EndIf

Return cLogErro
/*
Programa   : CancInteg
Objetivo   : Funcao utilizada para Cancelar integração do catálogo de produtos
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function CancInteg( cCat, cVersao )
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

   aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")  , Nil})
   aAdd(aCapaEKD,{"EKD_COD_I"	, cCat            , Nil})
   aAdd(aCapaEKD,{"EKD_VERSAO", cVersao         , Nil})

   MSExecAuto({|a,b| EICCP401 (a,b)}, aCapaEKD, 4)

   If lMsErroAuto
      aErros := GetAutoGRLog()
      For nJ:= 1 To Len(aErros)
         cLogErro += aErros[nJ]+ENTER
      Next nJ
   EndIf

Return cLogErro
/*
Programa   : CP400Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Ramon Prado
Data/Hora  : 27/11/2019
Obs.       :
*/
Function CP400Legen()
   Local aCores := {}

   aCores := {	{"ENABLE"      , STR0004   },; // "Registrado"
               {"BR_AZUL_CLARO", STR0156},; //Registrado Manualmente
               {"BR_CINZA"    , STR0005   },; // "Pendente Registro"
               {"BR_AMARELO"  , STR0006   },; // "Pendente Retificação"
               {"DISABLE"     , STR0007   }}  // "Bloqueado"

   BrwLegenda(STR0001,STR0013,aCores)

Return .T.
/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
   Local aVisions    := {}
   Local aColunas    := AvGetCpBrw("EK9")
   Local aContextos  := {"REGISTRADO", "REGISTRADO_MANUALMENTE", "PENDENTE_REGISTRO", "PENDENTE_RETIFICACAO", "BLOQUEADO"} // {STR0004,STR0005,STR0006,STR0007}
   Local cFiltro     := ""
   Local oDSView
   Local i

   If aScan(aColunas, "EK9_FILIAL") == 0
      aAdd(aColunas, "EK9_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := RetFilter(aContextos[i])            
      oDSView    := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .F.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next

Return aVisions
/*
Função     : RetFilter(cTipo,lNome)
Objetivo   : Retorna a chave ou nome do filtro da tabela EK9 de acordo com o contexto desejado
Parâmetros : cTipo - Código do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
   Local cRet     := ""
   Default lNome  := .F.

      Do Case
         Case cTipo == "REGISTRADO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '1' "
         Case cTipo == "REGISTRADO" .And. lNome
            cRet := STR0004 //"Registrado" "

         Case cTipo == "REGISTRADO_MANUALMENTE" .And. !lNome
            cRet := "EK9->EK9_STATUS = '5' "
         Case cTipo == "REGISTRADO_MANUALMENTE" .And. lNome
            cRet := STR0156 //"Registrado Manualmente"

         Case cTipo == "PENDENTE_REGISTRO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '2' "
         Case cTipo == "PENDENTE_REGISTRO" .And. lNome
            cRet := STR0005 //"Pendente Registro" "

         Case cTipo == "PENDENTE_RETIFICACAO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '3' "
         Case cTipo == "PENDENTE_RETIFICACAO" .And. lNome
            cRet := STR0006 //"Pendente Retificação" "

         Case cTipo == "BLOQUEADO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '4' .OR. EK9->EK9_MSBLQL = '1' "
         Case cTipo == "BLOQUEADO" .And. lNome
            cRet := STR0007 //"Bloqueado"
      EndCase

Return cRet

/*
Função     : CP400SB1F3()
Objetivo   : Monta a consulta padrão da filial de origem do produto para seleção 
             
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Ramon Prado (adaptada da função NF400SD2F3, fonte: EICCP400)
Data       : Dez/2019
Revisão    :
*/
Function CP400SB1F3()
   Local aSeek    := {}
   Local bOk      := {|| lRet:= .T., oDlg:End()}
   Local bCancel  := {|| lRet:= .F.,  oDlg:End()}
   Local cCpo     := AllTrim(Upper(ReadVar()))
   Local aColunas	:= IF(cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF", AvGetCpBrw("SB1",,.T. /*desconsidera virtual*/), AvGetCpBrw("SA2",,.T. /*desconsidera virtual*/))
   Local lRet     := .F.
   Local nX       := 1
   Local oDlg
   Local oBrowse

   Private cTitulo   := ""
   Private aCampos   := {}
   Private aFilter   := {} 

   Begin Sequence
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         aAdd(aColunas,"B1_IMPORT")
      Elseif cCpo == "M->EKB_CODFAB" .And. aScan(aColunas, "A2_FILIAL") == 0      
         aAdd(aColunas,Nil)
         AIns(aColunas,1)
         aColunas[1] := "A2_FILIAL"    
      EndIf   
      
      /* Campos usados na pesquisa */
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         aSeek := AVIndSeek("SB1",3)
      Else
         aSeek := AVIndSeek("SA2",3)
      EndIf

      For nX := 1 to Len(aColunas)
         /* Campos usados no filtro */
         AAdd(aFilter, {aColunas[nX]  , AvSx3(aColunas[nX]    , AV_TITULO) , AvSx3(aColunas[nX]    , AV_TIPO) , AvSx3(aColunas[nX]    , AV_TAMANHO) , AvSx3(aColunas[nX]    , AV_DECIMAL), AvSx3(aColunas[nX]    , AV_PICTURE)})
      Next nX
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         AllCpoIndex("SB1",aColunas)
         cTitulo := STR0016
      Else
         AllCpoIndex("SA2",aColunas)
         cTitulo := STR0035
      EndIf
      
      Define MsDialog oDlg Title STR0001 + " - " + cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM * 0.9, DLG_COL_FIM * 0.9 Of oMainWnd Pixel

      oBrowse:= FWBrowse():New(oDlg)
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF" 
         oBrowse:SetDataTable("SB1")
         oBrowse:SetAlias("SB1")
         //cTitulo := STR0016
         oBrowse:SetColumns(AddColumns(aColunas, "SB1"))
      Else
         oBrowse:SetDataTable("SA2")
         oBrowse:SetAlias("SA2")
         //cTitulo := STR0035
         oBrowse:SetColumns(AddColumns(aColunas, "SA2"))
      EndIf

      oBrowse:bLDblClick:= {|| lRet:= .T.,  oDlg:End()}

      //oBrowse:SetDescription(cTitulo) 

      /* Pesquisa */
      oBrowse:SetSeek(, aSeek)
      
      /* Filtro */	
      oBrowse:SetUseFilter()
      oBrowse:SetFieldFilter(aFilter)
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF" 
         oBrowse:AddFilter('Default',"SB1->B1_IMPORT == 'S' .And. SB1->B1_MSBLQL <> '1' ",.F.,.T.)
      EndIf   

      If cCpo == "M->EKA_PRDREF" .And. !Empty(M->EK9_NCM)
         oBrowse:AddFilter('Ncm',"SB1->B1_POSIPI == '"+M->EK9_NCM+"' ",.F.,.T.)
      EndIF

      oBrowse:Activate()
      
      Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))	

   End Sequence

Return lRet

/*
Função     : CP400Relac(cCampo)
Objetivo   : Inicializar dados dos campos do grid(Relacao de Produtos - Catalogo de prds)
Parâmetros : cCampo - campo a ser inicializado
Retorno    : cRet - Conteudo a ser inicializado
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400Relac(cCampo)
   Local aArea       := getArea()
   Local cRet        := "" 
   Local oModel      := FWModelActive()
   Local oModelEKA   := oModel:GetModel("EKADETAIL")
   Local cChaveEKJ   := ""
   Local cChaveSA2   := ""
   local lCondic     := .F.
   local lMultifil := VerSenha(115) .And. FWModeAccess("EK9",3) == "C" .And. FWModeAccess("SB1",3) == "E" .And. FWModeAccess("SA2",3) == "E"

   If oModel:GetOperation() <> 3

      Do Case
         Case cCampo == "EKA_DESC_I" .And. ValType(oModelEKA) == "O"
            If lMultiFil
               cRet := Posicione("SB1",1,EKA->EKA_FILORI+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC")
            Else
               cRet := Posicione("SB1",1,XFILIAL("SB1")+AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC")
            EndIf
         Case cCampo == "EK9_DESC_I"
            If lMultiFil
               cRet := POSICIONE("SB1",1,FWFLDGET("EK9_FILORI")+FWFLDGET("EK9_PRDREF"),"B1_DESC")
            Else		
               cRet := POSICIONE("SB1",1,XFILIAL("SB1")+FWFLDGET("EK9_PRDREF"),"B1_DESC")
            EndIf
         Case cCampo == "EKB_NOME"
            If lMultiFil
               cRet := POSICIONE("SA2",1,EKB->EKB_FILORI+EKB->EKB_CODFAB+EKB->EKB_LOJA,"A2_NOME")
            Else
               cRet := POSICIONE("SA2",1,EKB->EKB_FILIAL+EKB->EKB_CODFAB+EKB->EKB_LOJA,"A2_NOME")
            EndIf
         Case cCampo $ "EKB_OENOME|EKB_OEEND|EKB_OESTAT|EKB_OPERFB"
            If lMultiFil
               cChaveSA2 := EKB->EKB_FILORI+EKB->EKB_CODFAB+EKB->EKB_LOJA
            Else
               cChaveSA2 := EKB->EKB_FILIAL+EKB->EKB_CODFAB+EKB->EKB_LOJA
            EndIf
            if SA2->(dbsetorder(1),msseek(cChaveSA2))
               cChaveEKJ := SA2->A2_FILIAL+EK9->EK9_CNPJ+SA2->A2_COD+SA2->A2_LOJA
               EKJ->(dbsetorder(1))
               if EKJ->(msseek(cChaveEKJ))
                  if cCampo == "EKB_OENOME"
                     cRet := EKJ->EKJ_NOME
                  elseif cCampo == "EKB_OEEND"
                     cRet := alltrim(EKJ->EKJ_LOGR) + "-" + alltrim(EKJ->EKJ_CIDA) + "-" + alltrim(EKJ->EKJ_SUBP) + "-" + alltrim(EKJ->EKJ_PAIS) + "-" + alltrim(EKJ->EKJ_POSTAL)
                  elseif cCampo == "EKB_OESTAT"
                     cRet := EKJ->EKJ_STATUS
                  elseif ccampo == "EKB_OPERFB"
                     cRet := EKJ->EKJ_TIN
                  endif
               else
                  if cCampo == "EKB_OENOME"
                     cRet := SA2->A2_NOME
                  elseif cCampo == "EKB_OEEND"
                     cRet := alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_MUN) + "-" + alltrim(SA2->A2_PAISSUB) + "-" + alltrim(SA2->A2_PAIS) + "-" + alltrim(SA2->A2_POSEX)
                  elseif cCampo == "EKB_OESTAT"
                     cRet := "2"
                  endif
               endif
            endif
         Case cCampo == "EKB_PAISDS"
            cRet := POSICIONE("SYA",1,xFilial("SYA")+EKB->EKB_PAIS,"YA_DESCR")
         Case cCampo == "EKC_STATUS"
            EKG->(dbSetOrder(1))
            lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"") ))
               cRet := CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG)
            EndIf
         Case cCampo == "EKC_NOME"
            EKG->(dbSetOrder(1))
            lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"") ))
               cRet := AllTrim(EKG->EKG_NOME)
            EndIf
         Case cCampo == "ATRIB_OBRIG"
            EKG->(dbSetOrder(1))
            lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"") ))
               cRet := if(empty(EKG->EKG_OBRIGA),"2", EKG->EKG_OBRIGA)
            EndIf

         Case cCampo == "EKC_VLEXIB"
            //cRet := IIF(!Empty(EKC->EKC_VALOR),SubSTR(EKC->EKC_VALOR,1,100),"")
                     
      EndCase	
   EndIf

   RestArea(aArea)

Return cRet

/*
Função     : CP400When(cCampo)
Objetivo   : Define se campo será habilitado para ediçao/alteração ou não na tela
Parâmetros : cCampo - campo a verificado o when(será habilitado pra edição/alteração ou nao na tela)
Retorno    : lWhen - lógico sim ou nao
Autor      : Ramon Prado
Data       : maio/2021
Revisão    :
*/
Function CP400When(cCampo)
   Local aArea       := getArea()
   Local lWhen       := .T.
   Local lCatProdEx  := FwIsInCallStack("EECCP400")

   Do Case
      Case cCampo == 'EKB_PAIS'
         If !Empty(Fwfldget("EKB_CODFAB")) .and. !EMPTY(Fwfldget("EKB_LOJA"))
            lWhen := .F.
         EndIf
      Case cCampo == 'EK9_MSBLQL'   //MFR 14/02/2022 OSSME-6604        
            lWhen := !Inclui
      Case cCampo == 'EK9_VSMANU'
            lWhen := Inclui .Or. lCatProdEx .Or. Empty(EK9->EK9_VATUAL)
      Case cCampo == 'EK9_IDMANU'
            lWhen := Inclui .Or. (Empty(EK9->EK9_IDPORT) .And. Empty(EK9->EK9_VATUAL))
   EndCase

   RestArea(aArea)
Return lWhen

/* 
Função     : CP400AtLn1()
Objetivo   : Gatilho para preencher produto de referência na linha 1 do detalhe(Relacao de produtos)
Parâmetros : 
Retorno    : cRet - Conteudo a ser gatilhado
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400AtLn1()	
   Local aArea       := getArea()	 
   Local oModel      := FWModelActive()
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local oModelEKA   := oModel:GetModel("EKADETAIL")
   Local cRet        := oModelEK9:GetValue("EK9_PRDREF")
   Local nI	         := 1
   Local nPos        := 0
   Local lExistPrd   := .F.
   Local mDesc       := ""

   If oModelEKA:Length() > 0 .And. !Empty(oModelEK9:GetValue("EK9_PRDREF"))	
      For nI := 1 to oModelEKA:Length()
         oModelEKA:GoLine( nI )
         If oModelEKA:GetValue("EKA_PRDREF") == oModelEK9:GetValue("EK9_PRDREF")			
            lExistPrd := .T.
            exit
         Endif
         If Empty(oModelEKA:GetValue("EKA_PRDREF"))
            nPos := nI
         EndIf
      Next nI
      
      If !lExistPrd     
         If nPos > 0
            oModelEKA:GoLine( nPos )
            oModelEKA:SetValue("EKA_PRDREF", oModelEK9:GetValue("EK9_PRDREF"))
         Else
            if oModelEKA:Length() < oModelEKA:AddLine()
               oModelEKA:SetValue("EKA_PRDREF", oModelEK9:GetValue("EK9_PRDREF"))
               CP400Ncm(oModelEK9,oModelEKA)
            Else
               cRet := oModelEK9:GetValue("EK9_PRDREF")
            EndIf   
         EndIf		
      ElseIf oModelEKA:IsDeleted()
         oModelEKA:UnDeleteLine()		
         oModelEKA:Goline(1) //posiciona na linha 1
      EndIf
      oModelEKA:GoLine(1)	//posiciona na linha 1
   Endif

   If !Empty(oModelEK9:GetValue("EK9_PRDREF"))
      mDesc := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
      If !Empty(mDesc)	
         FwFldPut("EK9_DSCCOM",AvKey(mDesc,"EK9_DSCCOM"))
      EndIf	
   EndIf

   RestArea(aArea)

Return cRet

/*
Função     : CP400Ncm(model)
Objetivo   : Excluir as linhas que tenham o produto com ncm diferente do ncm da capa(EK9)
Parâmetros : 
Retorno    : Retorno .t.
Autor      : Maurício Frison
Data       : Abr/2020
Revisão    :
*/
Function CP400Ncm(oModelEK9,oModelEKA)
   Local oView       := FWViewActive()
   Local nI          :=0
   Local cPRod       :=""
   Local cFil        :=""
   Local aArrayProd	:= {}
  // Local lFirstPrd   := .T. // MFR 02/03/2022 OSSME-6595

   if oModelEKA:GetOperation() == 3 //inclusao
      aArrayProd := CP400ArPrd(oModelEKA)
      if len(aArrayProd) > 0
         oModelEKA:ClearData(.T.,.F.) //oModelEKA:ClearData(.T.,.T.) MFR 11/02/2022 OSSME-6595
         FOR nI:=1 TO LEN(aArrayProd)
            cProd := aArrayProd[ni][1]
            cFil  := aArrayProd[ni][2] //if(!lMultiFil,aArrayProd[ni][2],oModelEK9:GetValue("EK9_FILORI")) MFR 02/03/2022 OSSME-6595
            CP400PsFil(cProd,cFil,"SB1")
            If Alltrim(oModelEK9:GetValue("EK9_NCM")) == AllTrim(SB1->B1_POSIPI) // Alltrim(cNCM) == AllTrim(SB1->B1_POSIPI) neste caso o cNCM ainda não está atualizado
               //If !lFirstPrd
                  oModelEKA:AddLine()
               //EndIf               
               oModelEKA:SetValue("EKA_PRDREF", cProd)
    //           lFirstPrd := .F. // MFR 02/03/2022 OSSME-6595
            EndIf
         Next
         IF oModelEKA:Length() == 0 // MFR 11/02/2022 OSSME-6595
            oModelEKA:AddLine()
         EndIf         
         oModelEKA:GoLine(1)
         if !isExecAuto(oView)
            oview:Refresh("EKADETAIL")
         endif
      EndIf  
   EndIf 

return .T.


/*
Função     : CP400Valid()
Objetivo   : Validar dados digitados nos campos EK9 e EKA
Parâmetros : cCampo - campo a ser validado
Retorno    : lRet - Retorno se foi validado ou nao
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400Valid(cCampo,lUndelete)
   Local oModel         := FWModelActive()
   Local oModelEK9      := oModel:GetModel("EK9MASTER")
   Local oModelEKA      := oModel:GetModel("EKADETAIL")
   Local oModelEKB      := oModel:GetModel("EKBDETAIL")
   Local oModelEKC      := oModel:GetModel("EKCDETAIL")
   Local cChaveEKJ      := ""
   Local lRet           := .T.
   //Local lPosicEKD      := .F.
   Local cCodFab        := ""
   local lAutoExec      := isExecAuto()
   local mDesc          := ""

   Default lUndelete    := .F.

   Do Case
      Case cCampo == "EK9_PRDREF" .OR. cCampo == "EK9_FILORI" .or. cCampo == "EKA_PRDREF" .OR. cCampo == "EKA_FILORI"
         Begin Sequence
            If cCampo == "EK9_PRDREF" .And. Empty(oModelEK9:GetValue("EK9_CNPJ"))  // MFR 11/02/2022 OSSME-6598
               lRet:=.F.
               EasyHelp(STR0104,STR0002,STR0103) //Campo CNPJ não informado. Informe primeiro o campo CNPJ Raiz
               break
            EndIf
            If lRet
               cProd := if(cCampo == "EK9_PRDREF", oModelEK9:GetValue("EK9_PRDREF") ,oModelEKA:GetValue("EKA_PRDREF"))         
               cFil  := if(cCampo == "EK9_PRDREF" .or. cCampo == "EKA_PRDREF", NIL, if(cCampo == "EK9_FILORI",M->EK9_FILORI , oModelEKA:GetValue("EKA_FILORI")))         
               If lMultiFil .And. !Empty(cProd)	
                  lRet := CP400PsFil(cProd,cFil,"SB1")
               ElseIf !Empty(cProd)
                  lRet := CP400PsFil(cProd,xFilial("SB1"),"SB1")
               EndIf
            EndIf   

            If lRet
               If SB1->B1_MSBLQL == '1'
                  EasyHelp(STR0019,STR0002) //"'Produto não encontrado no cadastro para esta filial'"##"Atenção"
                  lRet := .F.
               elseIf cCampo == "EK9_PRDREF"
                  mDesc := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
                  If !Empty(mDesc)	
                     FwFldPut("EK9_DSCCOM",AvKey(mDesc,"EK9_DSCCOM"))
                  EndIf
               endif
            Else
               Help(" ",1,"REGNOIS")
            EndIf
            
            If lRet .And. !Empty(oModelEK9:GetValue("EK9_NCM")) .and. (cCampo=="EKA_PRDREF" .or. cCampo =="EK9_PRDREF")
                  If Alltrim(oModelEK9:GetValue("EK9_NCM")) <> AllTrim(SB1->B1_POSIPI)                     // .T. pega só as linha válidas (não deletadas)
                        If oModel:GetOperation() == 4 .or. (oModel:GetOperation() == 3 .And. oModelEKA:Length(!lUndelete) > 1) // 4=alteração ou 3-Inclusão e já tem um ou mais produtos com o ncm igual ao da capa
                           lRet:=.F.
                           easyhelp(STR0042,STR0002,STR0107) //Alteração não permitida porque este produto possui NCM diferente da capa do processo. Informe um produtro com o mesmo NCM
                        Else
                           If cCampo =="EK9_PRDREF" .And. !lAutoExec .And. MsgNoYes(STR0020,STR0021) //'O Ncm do produto digitado é diferente do Ncm digitado no Cabeçalho. Deseja Prosseguir?'##'Aviso'
                              lRet := .T.
                              If oModelEKC:Length() > 0 .and. !Empty(oModelEKC:GetValue("EKC_CODATR"))
                                 lRet := MsgNoYes(STR0032,STR0002) // "Confirma alteração do NCM, se confirmar todas as informações sobre os atributos serão perdidas" ## "Atenção"
                              EndIf 
                           EndIf	
                           if lRet
                              oModelEK9:LoadValue("EK9_NCM", SB1->B1_POSIPI)
                              CP400ATRIB(.F.)
                           else
                              cNcmAux := oModelEK9:GetValue("EK9_NCM")
                           EndIf
                        EndIf
                  EndIf
            EndIf
         End Sequence   
      Case cCampo == "EKB_LOJA" .Or. cCampo == "EKB_FILORI"

         IF !Empty(oModelEKB:GetValue("EKB_CODFAB"))
            cCodFab := oModelEKB:GetValue("EKB_CODFAB")+oModelEKB:GetValue("EKB_LOJA")
         Else
            Help("",1,"CP400LOJA") //Problema: Código do Fabricante não está preenchido Solução: Preencha o Cód. do Fabricante
            lRet := .F.  
         EndIf 

         If lRet  
            If cCampo == "EKB_FILORI"
               cFil  := oModelEKB:GetValue("EKB_FILORI")
            EndIf

            If lMultiFil
               If !Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. !Empty(oModelEKB:GetValue("EKB_LOJA"))            
                  cFil := If(empty(oModelEKB:GetValue("EKB_FILORI")),xFilial('SA2'),oModelEKB:GetValue("EKB_FILORI"))
                  lRet := CP400PsFil(cCodFab,cFil,"SA2") //lRet := CP400PsFil(cCodFab,cFil,"SA2")  // MFR 11/02/2022 OSSME-6595                     
               EndIf   
            ElseIf !Empty(cCodFab)
               lRet := CP400PsFil(cCodFab,xFilial("SA2"),"SA2")             
            EndiF
            If !lRet
               Help(" ",1,"REGNOIS")
            EndIf  

            If lRet
               cChaveEKJ := xFilial("EKJ")+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA // MFR 11/02/2022 OSSME-6598
               if EKJ->(dbsetorder(1),msseek(cChaveEKJ))         
                  If EKJ->EKJ_MSBLQL == '1'
                     Help(" ",1,"CP400OPBLQ") //"Registro do operador estrangeiro encontra-se bloqueado. Para utilizá-lo efetue o desbloqueio do registro no Cadastro do Op. Estrangeiro"##"Atenção"
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
            If lRet
               If lMultiFil
                  //           oModelEKB:getvalue("EKB_FILORI",oModelEKB:getline())+oModelEKB:getvalue("EKB_CODFAB",oModelEKB:getline())+oModelEKB:getvalue("EKB_LOJA",oModelEKB:getline()) //MFR 11/02/2022 OSSME-6595               
                  //neste caso o cFil já foi preenchdo acima
                  cChaveSA2 := cFil+oModelEKB:getvalue("EKB_CODFAB",oModelEKB:getline())+oModelEKB:getvalue("EKB_LOJA",oModelEKB:getline()) 
               Else
                  cChaveSA2 := xFilial("SA2")+oModelEKB:getvalue("EKB_CODFAB",oModelEKB:getline())+oModelEKB:getvalue("EKB_LOJA",oModelEKB:getline())
               EndIf
               cRet:='' ////MFR 11/02/2022 OSSME-6595
               If SA2->(dbsetorder(1),msseek(cChaveSA2))
                  cRet := SA2->A2_PAIS
               EndIf 

               If Empty(cRet)
                  EasyHelp(STR0087,STR0002,STR0088)  //Problema: "O código do País de origem não foi preenchido no Cadastro de Fornecedores/Fabr." Solução: "Acesse o Cadastro do Fabricantes/Forn. e preencha o código do País de origem do Fabricante na aba 'Cadastrais' "
                  lRet := .F.	   
               EndIf
            EndIf
         EndIf                         
      Case cCampo == "EK9_UNIEST" 
         lRet := Vazio() .OR. ExistCpo("SAH",oModelEK9:GetValue("EK9_UNIEST"))
         If !lRet
            EasyHelp(StrTran(STR0022, "#####", oModelEK9:GetValue("EK9_UNIEST")),STR0002,STR0105) //"Unidade de Medida: ##### da NCM não encontrada no cadastro de unidade de medida"##"Atenção" Solução: "Revise o cadastro da NCM ou cadastre a unidade de medida"
         Endif
      Case cCampo == "EK9_NCM"
         lRet := (lRet .or. Vazio()) .and. ExistCpo("SYD",oModelEK9:GetValue("EK9_NCM")) 
         // mesmo retornando .F.(quando responde Nao) no controle do campo EKA_PRDREF, o sistema por falha do componente quando
         //entra aqui de novo está com o valor do campo M->EK9_NCM como se tivesse respondido Sim
         if !Empty(cNcmAux) 
            M->EK9_NCM := cNcmAux
            oModelEK9:LoadValue("EK9_NCM",cNcmAux)
            cNcmAux:=""
         EndIf
         If lREt .and. oModelEKC:Length() > 0 .and. oModelEK9:GetValue("EK9_NCM") <> cNcm
            If !Empty(oModelEKC:GetValue("EKC_CODATR"))
               If !lAutoExec  //se não for execauto exibe a pergunta se não segue como sim 
                  lRet := MsgNoYes(STR0032,STR0002) // "Confirma alteração do NCM, se confirmar todas as informações sobre os atributos serão perdidas" ### "Atenção"
               EndIf
               If lRet
                  CP400Ncm(oModelEK9,oModelEKA)
               EndIf
            EndIf
         EndIf
      Case cCampo == "EK9_IDMANU"
         If !FwIsInCallStack("EECCP400") .and. !Empty(oModelEK9:getvalue("EK9_IDPORT"))
            //EasyHelp(STR0079,STR0002) //"Não é possível digitar ID Manual já que o ID Portal já está preenchido"
            Help(" ",1,"CP400IDMAN")   //"Não é possível digitar ID Manual já que o ID Portal já está preenchido"         
            lRet := .F.
         EndIf
         If !Empty(oModelEK9:getvalue("EK9_VSMANU")) .And. AvExisteInd({{"EKD","3"}}) .And. ExistCpo("EKD",oModelEK9:getvalue("EK9_COD_I") + oModelEK9:getvalue("EK9_IDPORT") + oModelEK9:getvalue("EK9_VSMANU"),3,,.F.)
            EasyHelp(STR0157,STR0002,STR0158) // "Versão informada já existe no Histórico de Integração do Catálogo de Produtos." "###"Atenção"###"Informe uma versão que ainda não possua cadastro no Histórico de Integração."
            lRet := .F.
         EndIf 
      Case cCampo == "EK9_VSMANU"
         If !Empty(oModelEK9:getvalue("EK9_VSMANU")) .And. AvExisteInd({{"EKD","3"}}) .And. ExistCpo("EKD",oModelEK9:getvalue("EK9_COD_I") + oModelEK9:getvalue("EK9_IDPORT") + oModelEK9:getvalue("EK9_VSMANU"),3,,.F.)
            EasyHelp(STR0157,STR0002,STR0158) // "Versão informada já existe no Histórico de Integração do Catálogo de Produtos." "###"Atenção"###"Informe uma versão que ainda não possua cadastro no Histórico de Integração."
            lRet := .F.
         EndIf 

      Case cCampo == "EK9_DSCCOM"
         If len(oModelEK9:getvalue("EK9_DSCCOM")) > 3700
            EasyHelp(STR0096,STR0002) //"O campo de descrição complementar não pode ter mais de 3700 caracteres!"  "###"Atenção"
            lRet := .F.
         EndIf
      Case cCampo == "EKB_CODFAB"        
         Do Case
           Case Empty(oModelEK9:GetValue("EK9_CNPJ"))  // MFR 11/02/2022 OSSME-6598
                 lRet:=.F.
                 EasyHelp(STR0104,STR0002,STR0103) //Campo CNPJ não informado. Informe primeiro o campo CNPJ Raiz
            Case !Vazio() .And. !ExistCpo("SA2",oModelEKB:getvalue("EKB_CODFAB"))
                 lRet:=.F.
                 EasyHelp(STR0097,STR0002,STR0098) //Problema: "Fabricante informado não cadastrado!"  "###"Atenção"  Solução: "Consulte a lista de fabricantes cadastrados no sistema pressionando F3 sobre o campo ou acesse o cadastro de fabricantes e realize o cadastro do fabricante informado."  
         EndCase        
      Case cCampo == "EKB_PAIS"  
         lRet := Vazio() .or. ExistCpo("SYA",oModelEKB:getvalue("EKB_PAIS"))
         If !lRet
            Help(" ",1,"CP400PAIS") //Problema: Não existe o Cod. de Pais digitado Solução: Consulte a lista de código de países e digite um cod. de Pais válido.
         EndIf

      Case cCampo == "EK9_STATUS"
         cRet := Pertence("12345") //"1=Registrado;2=Pendente Registro;3=Pendente Retificação;4=Bloqueado;5=Registrado Manualmente"
      
      Case cCampo == "EKD_STATUS"
         cRet := Pertence("123456") //"1=Registrado;2=Pendente Registro;3=Obsoleto;4=Falha de integração;5=Registrado(pendente: fabricante/ país);6=Registrado Manualmente"

   EndCase	
   lRetAux := lRet

Return lRet

/*
Função     : CP400PsFil()
Objetivo   : Pesquisa filial para o produto digitado - quando nao via F3(consulta padrão/especifica)
Parâmetros : cCampo - Produto a ser pesquisado
			 cTable - Tabela EKA - uso escpecifico para posicionar no produto SB1 para a filial encontrada
Retorno    : lRet - retorna se achou filial para o produto digitado
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400PsFil(cPesq,cFil,cTable)
   Local aFil := {}
   Local lRet := .F.

   If(cFil == Nil, aFil := FWAllFilial(), aAdd(aFil,cFil))

   If cTable == "SB1"
      dbSelectArea("SB1")
      SB1->(DbSetOrder(1)) //Filial + Produto
      lRet := aScan(aFil,{|X| MsSeek(X+cPesq)}) > 0
   Else
      dbSelectArea("SA2")
      SA2->(DbSetOrder(1)) //Filial + Cod + Loja
      lRet := aScan(aFil,{|X| MsSeek(X+cPesq)}) > 0
   EndIf

Return lRet

/*
Função     : CP400IniBrw()
Objetivo   : Inicializa Browse - conteudo exibido no browse para campo passado por parametro
Parâmetros : cCampo - Campo a a ser inicializado no browse
Retorno    : cRet - Conteudo a ser inicializado no browse
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400IniBrw(cCampo)
   Local cRet	:= ""
   Local aArea	:= GetArea()

   If  cCampo == "EK9_DESC_I"
      If lMultiFil
         cRet := POSICIONE("SB1",1,EK9->EK9_FILORI+EK9->EK9_PRDREF,"B1_DESC")
      Else
         cRet := POSICIONE("SB1",1,xFILIAL("SB1")+EK9->EK9_PRDREF,"B1_DESC")
      EndIf
   EndIf

   RestArea(aArea)

Return cRet

/*
Função     : CP400Gatil(cCampo)
Objetivo   : Regras de gatilho para diversos campos
Parâmetros : cCampo - campo cujo conteudo deve ser gatilhado
Retorno    : .T.
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :  
*/
Function CP400Gatil(cCampo)
   Local aArea		   := GetArea()
   Local oModel	   := FWModelActive()
   Local oGridEKB    := oModel:GetModel("EKBDETAIL")
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local cRet        := ""
   Local cChaveEKJ   := ""
   Local cChaveEKJ2  := ""
   Local cChaveSA2   := ""
   Local lAchouSA2   := .F.

   Do Case
      Case cCampo == "EKB_NOME"
         If !Empty(SA2->A2_NOME)
            cConteu := SA2->A2_NOME             
            FwFldPut("EKB_NOME",AvKey(cConteu,"EKB_NOME"))
         EndIf   
      Case cCampo $ "EKB_OENOME|EKB_OEEND|EKB_OESTAT|EKB_OPERFB"
         If lMultiFil
            cChaveSA2 := oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline())+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         Else
            cChaveSA2 := oGridEKB:getvalue("EKB_FILIAL",oGridEKB:getline())+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         EndIf
         if SA2->(dbsetorder(1),msseek(cChaveSA2))
            cChaveEKJ := SA2->A2_FILIAL+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA
            cChaveEKJ2 := SA2->A2_FILIAL+AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R")+SA2->A2_COD+SA2->A2_LOJA
            EKJ->(dbsetorder(1))
            if EKJ->(msseek(cChaveEKJ)) .Or. EKJ->(msseek(cChaveEKJ2))
               if cCampo == "EKB_OENOME"
                  cRet := EKJ->EKJ_NOME
               elseif cCampo == "EKB_OEEND"
                  cRet := alltrim(EKJ->EKJ_LOGR) + "-" + alltrim(EKJ->EKJ_CIDA) + "-" + alltrim(EKJ->EKJ_SUBP) + "-" + alltrim(EKJ->EKJ_PAIS) + "-" + alltrim(EKJ->EKJ_POSTAL)
               elseif cCampo == "EKB_OESTAT"
                  cRet := EKJ->EKJ_STATUS
               elseif cCampo == "EKB_OPERFB"
                  cRet := EKJ->EKJ_TIN 
               endif
            elseif SA2->(dbsetorder(1),msseek(cChaveSA2)) //ta desposicionando na SA2 ao fazer o Seek da EKJ
               if cCampo == "EKB_OENOME"
                  cRet := SA2->A2_NOME
               elseif cCampo == "EKB_OEEND"
                  cRet := alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_MUN) + "-" + alltrim(SA2->A2_PAISSUB) + "-" + alltrim(SA2->A2_PAIS) + "-" + alltrim(SA2->A2_POSEX)
               elseif cCampo == "EKB_OESTAT"
                  cRet := "2"
               endif
            endif
         endif
      Case cCampo $ "EKB_LOJA"
         If lMultiFil
            cFil := Nil
            If !Empty(oGridEKB:GetValue("EKB_CODFAB"))           
               lAchouSA2 := IsInCallStack("F3GET") .Or. CP400PsFil(oGridEKB:GetValue("EKB_CODFAB"),cFil,"SA2")                      
            EndIf   
         ElseIf !Empty(oGridEKB:GetValue("EKB_CODFAB"))  
            lAchouSA2 := IsInCallStack("F3GET") .Or. CP400PsFil(oGridEKB:GetValue("EKB_CODFAB"),xFilial("SA2"),"SA2")             
         EndiF
         If lAchouSA2
            cRet := SA2->A2_LOJA
         EndIf         
      Case cCampo == "EKB_PAIS"   
         If lMultiFil
            cChaveSA2 := oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline())+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         Else
            cChaveSA2 := xFilial("SA2")+oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         EndIf
         If SA2->(dbsetorder(1),msseek(cChaveSA2))
            cRet := SA2->A2_PAIS
         EndIf 
      Case cCampo == "EKB_PAISDS"   
            If !Empty(oGridEKB:getvalue("EKB_PAIS",oGridEKB:getline()))
            cRet := POSICIONE("SYA",1,xFilial("SYA")+oGridEKB:getvalue("EKB_PAIS",oGridEKB:getline()),"YA_DESCR")
         EndIf       
   EndCase

   RestArea(aArea)

Return cRet

/*
Função     : CP400Condc(cCampo)
Objetivo   : Regras de condicao para gatilho ser executo para diversos campos
Parâmetros : cCampo - campo cujo condicao de execução do gatilho deve ser verificada
Retorno    : lRet
Autor      : Ramon Prado
Data       : Jan/2020
Revisão    :
*/
Function CP400Condc(cCampo)
   Local lRet := .F.

   Do Case
      Case cCampo == "EKA_PRDREF"   
         lRet := LMULTIFIL .And. !EMPTY(FWFLDGET("EKA_PRDREF"))
      Case cCampo == "EKB_LOJA"
         lRet := lMultiFil .And. !EMPTY(FWFLDGET("EKB_LOJA"))
   EndCase

Return lRet

/*
Função     : CP400ArPrd()
Objetivo   : Carrega Array de Produtos digitados no grid Relação de Produtos
Parâmetros : Nil
Retorno    : Array de Produtos
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400ArPrd(oModelPrd)
   Local aArea       := GetArea()
   Local aArrayProd  := {}
   Local nI          := 1

   If oModelPrd:Length() > 0
      For nI := 1 to oModelPrd:Length()		
         oModelPrd:GoLine(nI)
         if !Empty(oModelPrd:GetValue("EKA_PRDREF"))
               aAdd(aArrayProd, {oModelPrd:GetValue("EKA_PRDREF"),if(lMultiFil,oModelPrd:GetValue("EKA_FILORI"),xFilial("EKA"))})
         EndIf
      Next nI
   EndIf

   RestArea(aArea)

Return aArrayProd

/*
Função     : CP400VlSA5()
Objetivo   : Pesquisa Amarracao Produto XFornecedor Ou Produto X Fabricante
Parâmetros : Nil
Retorno    : lRet - Encontrou Amarracao de produto x Fornecedor Ou Produto X Fabricante
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400VlSA5(cFabricant, cLoja, cProd, cFilOri)
   Local aArea		   := GetArea()
   Local lRet		   := .F.
   Local cFilSA5     := ""

   Default cFilOri   := ""

   iif(!Empty(cFilOri), cFilSA5 := cFilOri, cFilSA5 := xFilial("SA5") )

   SA5->(DbSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
               
   If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(cProd, AVSX3("A5_PRODUTO",3)) + PADR(cFabricant, AVSX3("A5_FORNECE",3)) + PADR(cLoja, AVSX3("A5_LOJA",3)) ))
      lRet := .T.
   Else
      SA5->(DbSetOrder(4)) //A5_FILIAL+A5_FABR+A5_FALOJA+A5_PRODUTO
      If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(cFabricant, AVSX3("A5_FORNECE",3)) + PADR(cLoja, AVSX3("A5_LOJA",3)) + PADR(cProd, AVSX3("A5_PRODUTO",3)) ))
         lRet := .T.
      EndIf
   EndIF

   RestArea(aArea)

Return lRet

/*
Função     : CP400CarFb()
Objetivo   : Pesquisa Amarracao Produto XFornecedor Ou Produto X Fabricante e carrega a lista no grid de fabricantes conforme produto digitado
Parâmetros : Nil
Retorno    : Nil
Autor      : Ramon Prado
Data       : Abr/2021
Revisão    :
*/
Function CP400CarFb()
   Local aArea := getArea()
   Local oModel      := FWModelActive()
   Local oModelEK9	:= oModel:GetModel("EK9MASTER")
   Local oModelEKB	:= oModel:GetModel("EKBDETAIL")
   Local cFilSA5     := ""
   Local lMsgYesNo   := .T.
   Local cRet        := oModelEK9:GetValue("EK9_PRDREF")
   Local cPais,cBlq
   local lAutoExec   := .F.

   If !Empty(oModelEK9:GetValue("EK9_PRDREF")) .And. (cPrdRefEK9 <> oModelEK9:GetValue("EK9_PRDREF")) .And. oModel:GetOperation() != EXCLUIR 
      
      cPrdRefEK9 := oModelEK9:GetValue("EK9_PRDREF")
      /* //MFR 14/02/2022 OSSME-6592 Retirado para não apagar os fabricantes já existentes
      If oModel:GetOperation() == INCLUIR
         oModelEKB:DelAllline()     
         oModelEKB:ClearData(.T.,.T.)     
      EndIf 
      */
      
      //If(!Empty(oModelEKA:GetValue("EKA_FILORI",getLine())), cFilSA5 := oModelEKA:GetValue("EKA_FILORI",getLine()), cFilSA5 := xFilial("SA5") )
      cFilSA5 := xFilial("SA5")
      SA5->(DbSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
   
      //Cadastro de Produto x Fornecedor/Fabricante             
      If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(oModelEK9:GetValue("EK9_PRDREF"), AVSX3("A5_PRODUTO",3))))
         lAutoExec   := isExecAuto()
         If !lAutoExec //exibe a pergunta apenas para rotinas não automaticas, rotina automatica a variavel lMsgYesNo é "Sim"   
            lMsgYesNo := MsgYesNo(STR0073,STR0021) //"Deseja carregar a lista de Fabricantes/Fornecedores associados ao Produto? Serão considerados apenas os cadastros que possuirem o país informado" 
         EndIf
         If lMsgYesno 
            While SA5->(!EOF()) .And. SA5->(A5_FILIAL+A5_PRODUTO) == cFilSA5+oModelEK9:GetValue("EK9_PRDREF")            
               If !oModelEKB:SeekLine({{"EKB_CODFAB", SA5->A5_FORNECE},{"EKB_LOJA", SA5->A5_LOJA}})
                  cPais := Posicione("SA2",1,xFilial("SA2")+SA5->A5_FORNECE+SA5->A5_LOJA,"A2_PAIS") //MFR 14/02/2022 OSSME-6592
                  cBlq  :=  Posicione("EKJ",1,xFilial("EKJ")+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA,"EKJ_MSBLQL") // MFR 11/02/2022 OSSME-6598
                  If !Empty(cPais) .And. cBlq != "1"
                     if !(oModelEKB:length()==1 .AND. Empty(oModelEKB:GetValue("EKB_CODFAB"))) 
                        ForceAddLine(oModelEKB, .F./*Não permite bloquear grid para nova inserção de linhas*/) 
                     EndIf 
                     oModelEKB:SetValue("EKB_CODFAB", SA5->A5_FORNECE)
                     oModelEKB:SetValue("EKB_LOJA", SA5->A5_LOJA) 
                  EndIf                 
               Endif                                                 
               SA5->(DbSkip())      
            EndDo  
            oModelEKB:GoLine(1) //posiciona na linha 1
         EndIf   
      EndIf
            
   Endif

   RestArea(aArea)
Return cRet

/*
Função     : CP400ATRIB() Gatilho EK9_NCM
Objetivo   : Monta o grid com os atributos de acordo como ncm(gatilho no ncm da EK9)
             
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400ATRIB(lEvento)
   Local aDominio    := {}
   Local oModel      := FWModelActive()
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local oModelEKC   := oModel:GetModel("EKCDETAIL")
   local nTamCpoVlr  := 0
   local lFirst      := .T.
   local aCposGrd    := {}
   local nCpo        := 0
   local cCampos     := ""
   local cQuery      := ""
   local oQuery      := nil
   local cAliasQry   := ""
   local lCondic     := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local aOrderAtrb  := {}
   local cCodCatalog := ""
   local cModalid    := ""
   local cCodAtrib   := ""
   local dDataIni    := ctod("")
   local dDataFim    := ctod("")
   local cModEKG     := ""
   local cForm       := ""
   local cNcmEKG     := ""
   local cNomeEKG    := ""
   local cObrigEKG   := ""
   local nTamMAX     := 0
   local nDecAtrib   := 0
   local nRecEKG     := 0
   local cCodCondic  := ""
   local nPosOrdem   := 0
   local nOrdem      := 0
   local nOrdCond    := 0
   local cOrdem      := ""
   local cMultVal    := ""
   local aValores    := {}
   local nValores    := 0
   local aAttCompos  := {} //Array para armazenar os atributos que possuirem a forma de preenchimento COMPOSTO
 
   Default lEvento := .F.
   
   If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !FwIsInCallStack("incCatProd") .And. !Empty(oModelEK9:GetValue("EK9_PRDREF")) .And. Empty(oModelEK9:GetValue("EK9_DESC_I")) .And. getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V" //Como o campo EK9_DESC_I inicialmente era virtual, verifica se esta em branco e preenche
      oModelEK9:SetValue("EK9_DESC_I", Posicione("SB1", 1, xFilial("SB1") + oModelEK9:GetValue("EK9_PRDREF"), "B1_DESC"))
   EndIf

   if !FwIsInCallStack("incCatProd") .and. !Empty(oModelEK9:GetValue("EK9_NCM")) .and. (cNcm <> oModelEK9:GetValue("EK9_NCM") .or. cModalEK9 <> oModelEK9:GetValue("EK9_MODALI")) .and. oModel:GetOperation() != MODEL_OPERATION_DELETE

      cNcm := oModelEK9:GetValue("EK9_NCM") 
      cModalEK9 := oModelEK9:GetValue("EK9_MODALI")
      lFirst := IIF(lEvento,.F.,lFirst)
      If oModel:GetOperation() == MODEL_OPERATION_INSERT
         oModelEKC:DelAllline()     
         oModelEKC:ClearData(.T.,.T.)     
         lFirst := .T.
      EndIf

      nTamCpoVlr := getSx3Cache("EKC_VLEXIB", "X3_TAMANHO")

      DbSelectArea("EKG")
      if EKG->(dbSeek( xFilial("EKG") + cNcm ))
   
         aCposGrd := FWSX3Util():GetAllFields("EKG", .F.)
         for nCpo := 1 to len(aCposGrd)
            cCampos += " " + aCposGrd[nCpo] + " ,"
         next
         cCampos := substr(cCampos , 1, len(cCampos)-1)

         cQuery := " SELECT "
         cQuery += " R_E_C_N_O_ REC_EKG, "
         cQuery += cCampos 
         cQuery += " FROM " + RetSqlName('EKG') + " EKG "
         cQuery += " WHERE EKG.D_E_L_E_T_ = ' ' "
         cQuery += " AND EKG.EKG_FILIAL = ? "
         cQuery += " AND EKG.EKG_NCM = ? "
         If oModel:GetOperation() == MODEL_OPERATION_INSERT
            cQuery += " AND EKG.EKG_MSBLQL <> '1' "
         EndIf
         cQuery += " ORDER BY " + if( lCondic , "EKG_CONDTE, EKG_COD_I", "EKG_COD_I" )

         oQuery := FWPreparedStatement():New(cQuery)
         oQuery:SetString(1,xFilial('EKG'))
         oQuery:SetString(2,cNcm)
         cQuery := oQuery:GetFixQuery()

         cAliasQry := getNextAlias()
         MPSysOpenQuery(cQuery, cAliasQry)
         TcSetField(cAliasQry, "EKG_INIVIG", "D", 8, 0)
         TcSetField(cAliasQry, "EKG_FIMVIG", "D", 8, 0)

         _aAtriCond := {} // variavel static
         aAtrib := {} // variavel private

         aOrderAtrb := {}
         cCodCatalog := oModelEK9:GetValue("EK9_COD_I")
         cModalid := oModelEK9:GetValue("EK9_MODALI")

         EKC->(dbSetOrder(1))

         (cAliasQry)->(dbGoTop())
         while (cAliasQry)->(!eof())

            cCodAtrib := (cAliasQry)->EKG_COD_I
            dDataIni := (cAliasQry)->EKG_INIVIG
            dDataFim := (cAliasQry)->EKG_FIMVIG
            cModEKG := (cAliasQry)->EKG_MODALI
            cForm := alltrim((cAliasQry)->EKG_FORMA)
            cNcmEKG := (cAliasQry)->EKG_NCM
            cNomeEKG := (cAliasQry)->EKG_NOME
            cObrigEKG := (cAliasQry)->EKG_OBRIGA
            nTamMAX := (cAliasQry)->EKG_TAMAXI
            nDecAtrib := (cAliasQry)->EKG_DECATR
            nRecEKG := (cAliasQry)->REC_EKG
            cCodCondic := ""
            cMultVal := ""

            if lCondic
               cCodCondic := (cAliasQry)->EKG_CONDTE
               cMultVal := (cAliasQry)->EKG_MULTVA
               If cForm == ATT_COMPOSTO //Forma de Preenchimento do tipo COMPOSTO
                  If aScan(aAttCompos,{|X| X[1] == cNcmEKG .And. X[2] == cCodAtrib}) == 0
                     aAdd(aAttCompos,{cNcmEKG, cCodAtrib})
                  EndIf
               Else
                  if !empty(cCodCondic) .And. aScan(aAttCompos,{|X| X[1] == cNcmEKG .And. X[2] == cCodCondic}) == 0
                     nPosOrdem := aScan( aOrderAtrb, { |X| X[1] == cCodCondic .and. empty(X[2]) })
                     if nPosOrdem > 0
                        nOrdem := aOrderAtrb[nPosOrdem][3]
                        nOrdCond := aOrderAtrb[nPosOrdem][4]
                     endif
                     nPosOrdem := aScan( aOrderAtrb, { |X| X[2] == cCodCondic .and. !empty(X[1]) } )
                     if nPosOrdem > 0
                        while nPosOrdem > 0
                           nOrdCond := if( nOrdCond <= aOrderAtrb[nPosOrdem][4], aOrderAtrb[nPosOrdem][4], nOrdCond )
                           nPosOrdem := aScan( aOrderAtrb, { |X| X[2] == cCodCondic .and. !empty(X[1]) }, nPosOrdem+1 )
                        end
                     endif
                     nOrdCond += 1
                  else
                     nOrdem += 1
                     if aScan( aOrderAtrb, { |X| X[1] == cCodAtrib }) == 0
                        nOrdCond := 0
                     endif
                  endif
                  cOrdem := StrZero(nOrdem,3) + "_" + StrZero(nOrdCond,3)
                  aAdd( aOrderAtrb , { cCodAtrib, cCodCondic, nOrdem, nOrdCond} )
               EndIf
            endif

            if !oModelEKC:SeekLine( if( lCondic, {{"EKC_COD_I", cCodCatalog} , {"EKC_CODATR", cCodAtrib } , {"EKC_CONDTE", cCodCondic }} , {{"EKC_COD_I" , cCodCatalog} , {"EKC_CODATR", cCodAtrib }} ), .T. )
               if lCondic .and. !empty(cCodCondic) .And. aScan(aAttCompos,{|X| X[1] == cNcmEKG .And. X[2] == cCodCondic}) == 0
                  aAdd( _aAtriCond, { cCodCondic, nRecEKG })
               else
                  if CP400Status(dDataIni,dDataFim) != "EXPIRADO" .and. cForm != ATT_COMPOSTO .And. ( empty(cModEKG) .or. cModEKG == "3" .or. cModalid == cModEKG ) 
                     if lFirst .OR. (oModelEKC:length()==1 .AND. empty(oModelEKC:getVAlue("EKC_CODATR")) )
                        lFirst := .f.
                     Else
                        ForceAddLine(oModelEKC)
                     EndIf
                     loadInfAtr(oModelEKC, cAliasQry, lCondic, cCodCatalog, cOrdem )
                  EndIf  
               endif
            else

               if EKC->(dbSeek(xFilial("EKC") + cCodCatalog + cCodAtrib + cCodCondic))
                  cTela := EKC->EKC_VALOR
                  aValores := {cTela}
                  if lCondic .and. cMultVal == "1"
                     aValores := strTokArr( alltrim(cTela), ";" )
                  endif
                  
                  if cForm == "BOOLEANO"
                     cTela := if(cTela=="1","SIM",if(cTela=="2","NAO",""))
                  elseif cForm == "LISTA_ESTATICA"
                     cTela := ""
                     for nValores := 1 to len(aValores)
                        if EKH->(dbSeek( xFilial("EKH") + cNcm + EKC->EKC_CODATR + aValores[nValores]))
                           cTela += alltrim(EKH->EKH_CODDOM) + " - " + alltrim(EKH->EKH_DESCRE) + " ;"
                        endif
                     next nValores
                     cTela := substr( cTela, 1, len(cTela)-1)
                  endif
                  oModelEKC:LoadValue("EKC_VLEXIB",SubSTR(cTela,1,nTamCpoVlr))
               endif

               if lCondic
                  if( !empty(cCodCondic), aAdd( _aAtriCond, { cCodCondic, nRecEKG }) , )
                  if( empty(oModelEKC:GetValue("ATRIB_ORDEM")), oModelEKC:LoadValue("ATRIB_ORDEM", cOrdem ) , )
               endif
            endif

            aDominio := {}
            if EKH->(DBSEEK(xFilial("EKH") + cNcmEKG + cCodAtrib))
               while EKH->(!Eof()) .and. EKH->EKH_FILIAL == xFilial("EKH") .and. EKH->EKH_NCM == cNcmEKG .AND. EKH->EKH_COD_I == cCodAtrib
                  aAdd(aDominio,{EKH->EKH_COD_I,EKH->EKH_CODDOM,EKH->EKH_DESCRE,""})
                  EKH->(DbSkip())
               enddo
            endif

            aAdd(aAtrib,{cCodAtrib, cNomeEKG, cForm, cObrigEKG, nTamMAX, nDecAtrib, nRecEKG, aDominio, cCodCondic})

            (cAliasQry)->(dbSkip())
         end
         (cAliasQry)->(dbCloseArea())
         oQuery:Destroy()

         if lCondic .and. !( oModel:GetOperation() == MODEL_OPERATION_INSERT )
            OrdAtrib(oModelEKC)
         endif

         oModelEKC:GoLine(1) 

      endif

   endif

return .T.

/*
Função     : ForceAddLine()
Objetivo   : Força adição de linha na tela de grid
Parâmetros : oModelGrid
Retorno    : .T.
Autor      : Maurício Frison
Data       : Mar/2020
*/
Static Function ForceAddLine(oModelGrid, lControlLn)
   Local oModel   := FWModelActive()
   Local lDel     := .F.

   Default lControlLn := .T.

      nOperation := oModel:GetOperation()
      If lControlLn
         oModelGrid:SetNoInsertLine(.F.)
      EndIf
      if nOperation == 1
         oModel:nOperation := 3
      EndIf

      If oModelGrid:Length() >= oModelGrid:AddLine()
         oModelGrid:GoLine(1)
         If !oModelGrid:IsDeleted()
            oModelGrid:DeleteLine()
            lDel := .T.
         EndIf
         oModelGrid:AddLine()
         oModelGrid:GoLine(1)
         If lDel
            oModelGrid:UnDeleteLine()
         EndIf
         oModelGrid:GoLine(oModelGrid:Length())
      EndIf

      If lControlLn
         oModelGrid:SetNoInsertLine(.T.)
         //oModelGrid:SetNoDeleteLine(.T.)
      EndIf   
      oModel:nOperation := nOperation

Return .T.

/*
Função     : CP400Status()
Objetivo   : Gera o status conforme data da vigência e data base            
Parâmetros : dDataVigencia
Retorno    : Status
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400Status(dIniVig,dFimVig)
   Local cReturn := ""

   If !Empty(dIniVig) .And. dIniVig > dDataBase
      cReturn := "FUTURO"
   ElseIf !Empty(dFimVig) .And. dFimVig < dDataBase 
      cReturn := "EXPIRADO"
   Else
      cReturn := "VIGENTE"
   Endif

Return cReturn
/*
Função     : CP400TELA() Gatilho campo EKC_CODATR
Objetivo   : Abrir uma tela diferente para cada tipo de dado de acordo com as tabelas EKG e EKH
Parâmetros : cCodAtr código do atributo
Retorno    : cTela - Retorna a informação selecionada pelo usuário
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400TELA()
   Local oModel    := FWModelActive()
   Local oModelEKC := oModel:GetModel("EKCDETAIL")
   Local oView     := FWViewActive()
   Local cForma 
   Local lRetorno
   local lCondic := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local cCondte := ""

   Private cTela := ""

   if oModelEkc:getOperation() == 1
      lRetorno := .F.
   Else
      cAtr := oModelEKC:GetValue("EKC_CODATR")
      if lCondic
         cCondte := oModelEKC:GetValue("EKC_CONDTE")
      endif
      cForma := CP400Campo(cAtr,3, cCondte, lCondic)
      CP400CapaAtr(cForma,cAtr)
      if !isExecAuto(oView)
         oview:Refresh("EKCDETAIL")
      endif
      lRetorno := .T.
   EndIf

Return lREtorno

/*
Função     : CP400Campo()
Objetivo   : Pegar a forma de preenchimento do atributo
Parâmetros : cAtributo o código do atributo, nCampo posição qeu define qual campo será retornado
Retorno    : valor - Retorna o campo de preenchimento do atributo
Autor      : Maurício Frison
Data       : Mar/2020
nCampo             1              2             3              4               5               6          7               8
            : EKG->EKG_COD_I,EKG->EKG_NOME,EKG->EKG_FORMA,EKG->EKG_OBRIGA,EKG->EKG_TAMAXI,EKG->EKG_DECATR,EKG->(RECNO()),aDominio}
Revisão    :
*/
Function CP400Campo(cAtributo, nCampo, cCondte, lCondic)
   Local valor
   Local nPos := 0

   default nCampo  := 0
   default cCondte := ""
   default lCondic := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")

   nPos := if( !lCondic , ascan(aAtrib, {|x| AllTrim(x[1]) == AllTrim(cAtributo)}) ,  ascan(aAtrib, {|x| AllTrim(x[1]) == AllTrim(cAtributo) .and. AllTrim(x[9]) == AllTrim(cCondte)  }))

   if nPos > 0
      if nCampo == 0
         valor := aAtrib[nPos]
      else
         valor := if(valtype(aAtrib[nPos][nCampo]) == "C",AllTrim(aAtrib[nPos][nCampo]), aAtrib[nPos][nCampo])
      endif
   EndIf

Return valor

/*
Função     : CP400CapaAtr()
Objetivo   : Exibir a tela de capa do atributo
Parâmetros : cForma - é a forma de preenchimento que veio da tabela ekg
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400CapaAtr(cForma,cAtr)
   Local oModel      := FWModelActive()
   Local oModelEKC   := oModel:GetModel("EKCDETAIL")
   Local cPict       := ""
   Local cObrig      := ""
   Local cValor      := ""
   Local cTela       := ""
   Local nTam        := 0
   Local nDec        := 0
   Local nValor      := 0
   Local aLista      := {}
   //Local npos        := 1
   Local bOk		   := {|| lRet:= .T., CP400GravaAtr(oModelEKC,cTela,cValor,lCondic) , oDlg:End()}
   Local bCancel     := {|| lRet:= .F., CP400ViewAtr()  , oDlg:End()}
   Local aItems      := {'1-SIM','2-NAO'}
   Local lHtml       := .T.
   Local oPanelEnch
   Local oPanelAtr
   Local cTituloAtributos := STR0168 //"Edição de Atributos"
   Local cTextHtml   := ""
   Local cNotCampos  := ""
   Local aCposExib   := {}
   Local aSeek       := {}
   Local cCampo
   local lCondic     := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local cCondte     := ""
   local aDadosEKG   := {}
   local cConfigCSS  := ""
   local cTipoSmart  := ""
   local nTipo       := 0
   local lViaHtml    := .F. // .F. - Via SmartCliente .T. - Via Html
   local nPosAtrb    := 0
   local aValores    := {}

   Private oBrowse
   Private aRotina  := menudef()
   Private cLabelGrid := ""
   Private cTelaView  := "" 

   nTipo := GetRemoteType(@cTipoSmart)
   lViaHtml := if( (valtype(nTipo) == "N" .and. nTipo == 5) .or. 'HTML' $ alltrim(upper(cTipoSmart)), .T. , .F.)
  
   nLinIni := DLG_LIN_INI+100
   nColIni := DLG_COL_INI+100
   nLinFim := DLG_LIN_FIM
   nColFim := DLG_COL_FIM

   If !Empty(cAtr)
      if lCondic
         cCondte := oModelEKC:getValue("EKC_CONDTE")
      endif

      aDadosEKG := CP400Campo(cAtr, nil, cCondte , lCondic)
      EKG->(DBGOTO(aDadosEKG[7])) 
      If EKG->EKG_MSBLQL == "1" //Registro Bloqueado
         Help(" ",1,"REGBLOQ",,"EKG - " + Alltrim(FWX2Nome("EKG")),2,5)
      Else
         RegToMemory("EKG", .F.)
         
         cNotCampos += "EKG_CODOBJ/EKG_FORMA/EKG_TAMAXI/EKG_DECATR/EKG_BRIDAT" //Campos que não serão exibidos na tela da edição de atributos - OSSME-5342 - RNLP
         
         //Adicionando os campos a serem apresentados na Enchoice 
         SX3->(DbSetOrder(1))
         SX3->(DbSeek("EKG"))
         While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EKG"
            If !(AllTrim(SX3->X3_CAMPO) $ cNotCampos) .And. X3Uso(SX3->X3_USADO)
               Aadd(aCposExib,SX3->X3_CAMPO)
            EndIf 
         SX3->(DbSkip())
         EndDo

         DEFINE MSDIALOG oDlg TITLE cTituloAtributos FROM nLinIni,nColIni TO nLinFim,nColFim OF oMainWnd PIXEL

            // Panel para a enchoice
            nWidth            := PosDlg(oDlg)[4]
            nHeight           := round(PosDlg(oDlg)[3] * 0.6,0)
            oPanelEnch        := TPanel():New(0,0,'',oDlg,,.F.,.T.,,,nWidth,nHeight)
            oPanelEnch:Align  := CONTROL_ALIGN_TOP

            // enchoice
            oEnCh             := MsMGet():New("EKG", ,2, , , , aCposExib,PosDlg(oPanelEnch),{},,,,,oPanelEnch,.T.)
            oEnch:oBox:Align  := CONTROL_ALIGN_TOP //CONTROL_ALIGN_ALLCLIENT
            cObrig            := aDadosEKG[4]
            cTela             := oModelEKC:GetValue("EKC_VALOR")
            cValor            := oModelEKC:GetValue("EKC_VALOR")
            cTelaView         := oModelEKC:GetValue("EKC_VLEXIB")

            // Panel para a Say
            nLinIni           := round(PosDlg(oDlg)[3] * 0.6,0) - noround(PosDlg(oDlg)[3] * 0.05,0)
            nHeight           := round(PosDlg(oDlg)[3] * 0.06,0)
            oPanelSay         := TPanel():New(nLinIni,0,'',oDlg,,.F.,.T.,,/* CLR_BLUE */,nWidth,nHeight)
            // oPanelSay:Align   := CONTROL_ALIGN_ALLCLIENT

            // TSay permitindo texto no formato HMTL
            nCol              := 5
            oSay              := TSay():New(01,nCol,{|| '' },oPanelSay,,,,,,.T.,CLR_BLACK,/* CLR_YELLOW */,nWidth,nHeight,,,,,,lHtml)
            oSay:Align        := CONTROL_ALIGN_ALLCLIENT
            oSay:SetTextAlign( 2, 2 )

            // Panel para o atributo
            nLinIni           += nHeight + 1
            nHeight           := PosDlg(oDlg)[3] * 0.4
            oPanelAtr         := TPanel():New(nLinIni,0,'',oDlg,,.F.,.T.,,,nWidth,nHeight,.T.,.T.)
            oPanelAtr:Align   := CONTROL_ALIGN_BOTTOM
            nRow              := 30

            // Atributo a ser incluído
            DO CASE

               CASE cForma == "LISTA_ESTATICA"

                  cTextHtml := STR0169//'Selecione na lista o valor do atributo'
                  bOk := {|| If(Len(aLista) > 0, getPosAtrib(oBrowse, aLista, @cTela, @cValor), ), CP400GravaAtr(oModelEKC,cTela,cValor, lCondic) , oDlg:End() }
                  aLista := aDadosEKG[8]
                  //nPos := AScan(aLista, {|x| x[2] == cTela})
                  bDuploClick := {|oBrowse| duploClickAtributo(oBrowse, lCondic) }

                  if len(aLista) > 0 .and. !empty(cValor)
                     aValores := StrTokArr2(cValor,';')
                     for nValor := 1 to len(aValores)
                        nPosAtrb := aScan( aLista, { |X| alltrim(X[2]) == alltrim(aValores[nValor]) })
                        if nPosAtrb > 0
                           aLista[nPosAtrb][4] := "LBOK"
                        endif
                     next
                  endif

                  // Define o Browse
                  cCampo := aDadosEKG[2]
                  AAdd(aSeek, {cCampo, {{"", "C", LEN(aLista[1][2]), 0, cCampo,,cCampo}},1,.T.})

                  oBrowse := FWBrowse():New(oPanelAtr)
                  oBrowse:SetProfileID("CP400FwBrw")
                  oBrowse:SetClrAlterRow(15000804)
                  oBrowse:setDataArray()
                  oBrowse:setArray( aLista )
                  oBrowse:SetSeek(,aSeek)
                  //oBrowse:disableConfig() //se deixar esta linha não funciona a automação e teve que incluir o SetSeek também para funcionar
                  oBrowse:disableReport()

                  oBrowse:AddMarkColumns({|oBrowse| iif( marcaAtributo(oBrowse) ,'LBOK','LBNO') },;
                                                   bDuploClick,;
                                                   {|oBrowse| headerClickAtributo(oBrowse) })

                  // Adiciona as colunas do Browse 
                  oColumn := FWBrwColumn():New()
                  oColumn:SetData(&('{ || aLista[oBrowse:At()][2] }'))
                  oColumn:ReadVar('aLista[oBrowse:At()][2]')
                  oColumn:SetTitle(AvSX3('EKH_COD_I')[5])
                  oColumn:SetSize(AvSX3('EKH_COD_I')[3])
                  oColumn:SetDoubleClick(bDuploClick)

                  oBrowse:SetColumns({oColumn})

                  oColumn := FWBrwColumn():New()
                  oColumn:SetData(&('{ || aLista[oBrowse:At()][3] }'))
                  oColumn:ReadVar('aLista[oBrowse:At()][3]')
                  oColumn:SetTitle( aDadosEKG[2] )
                  oColumn:SetSize(100)
                  oColumn:SetDoubleClick(bDuploClick)

                  oBrowse:SetColumns({oColumn})

                  oBrowse:Activate()

               CASE cForma == "TEXTO"
                  cValor      := StrTran(cValor, ENTER, "<br>")
                  cTela       := StrTran(cTela, ENTER, "<br>")
                  cLabelGrid  := substr(aDadosEKG[2], 1 , 1 ) + substr( lower(aDadosEKG[2]), 2  ) // lower( aDadosEKG[2] )
                  cTextHtml   := cLabelGrid
                  nTam        := aDadosEKG[5] 
                  bValid      := { || .T. } // {|u| CP400VlTexto(u,@cValor,nTam,@cTela)  }
                  bOk         := {|| if( CP400VlTexto(oMulti,@cValor,nTam,@cTela, lViaHtml), (CP400GravaAtr(oModelEKC, cTela, cValor, lCondic, lViaHtml , oMulti, nTam) , oDlg:End()), nil )}
                  cLabelAux   := STR0170 + " (" + AllTrim(str(nTam)) + ")" //'Caracteres'
                  nRow        := 5
                  nWidth      := PosDlg(oPanelAtr)[4] - 6
                  nHeight     := PosDlg(oPanelAtr)[3]
                  bSetGet     := {|u| iif(Pcount()>0, (cTela:=u, cValor:=cTela) ,cTela)}
                  
                  oMulti      := TSimpleEditor():New(nRow,nCol,oPanelAtr,nWidth,nHeight,,.F.,bSetGet,,.T.,,bValid,cLabelAux,1)
                  oMulti:bGetKey  := {|self,cText,nkey,oDlg| CP400GetKey(self,cText,nkey,oPanelAtr,nTam, lViaHtml) }
                  oMulti:bChanged := {|self,oDlg| CP400Changed(self,@cTela,oPanelAtr,nTam) }
                  oMulti:load( if( lViaHtml, substr(cTela, 1, nTam), cTela))
                  oMulti:SetMaxTextLength( nTam )
                  oMulti:SetFocus()
                  // oMulti := TMultiget():New(nRow,nCol,{|u| iif(Pcount()>0, (cTela:=u, cValor:=cTela) ,cTela)}, ;
                  // oPanelAtr,nWidth,nHeight,,,,,,.T.,,,bValid,,,,bValid,,,.F.,.T. ,cLabelAux,1 )
                  // oMulti:bGetKey := {|self,cText,nkey,oDlg| CP400GetKey(self,cText,nkey,oPanelAtr,nTam) }
                  
               CASE cForma $ "NUMERO_REAL|NUMERO_INTEIRO"

                  //tela com número com picture correspondente
                  cTitle      := substr(aDadosEKG[2], 1 , 1 ) + substr( lower(aDadosEKG[2]), 2  ) // lower( aDadosEKG[2] )
                  cTextHtml   := cTitle
                  nTam        := aDadosEKG[5]
                  nDec        := aDadosEKG[6]
                  cPict       := CP400GeraPic(nTam,nDec)
                  cTela       := StrTran(cTela,".","")
                  cTela       := StrTran(cTela,",",".")
                  nValor      := val(cTela)
                  nWidth      := 80
                  nHeight     := 20

                  oGetNum := TGet():New(nRow,nCol, { | u | If( PCount() == 0, nValor, (nValor := u, cTela := alltrim(Transform(nValor,cPict)),cValor:=cTela) ) },oPanelAtr, ;
                  nWidth,nHeight, cPict ,, 0, ,,.F.,,.T., ,.F., ,.F.,.F., ,.F.,.F. ,,"nValor",,,,.T.,.F., ,"",1 )
                  oGetNum:SetFocus()
               CASE cForma == "BOOLEANO"
                  
                  // Tela combox sim ou nao
                  cTitle      := substr(aDadosEKG[2], 1 , 1 ) + substr( lower(aDadosEKG[2]), 2  ) // lower( aDadosEKG[2] )
                  cTextHtml   := cTitle
                  cCombo1     := if(cValor == "", aItems[2], if(cValor =="1", aItems[1], aItems[2]))
                  cTela       := right(cCombo1,3)
                  cValor      := left(cCombo1,1)
                  nWidth      := 80
                  nHeight     := 20

                  oCombo1  := TComboBox():New(nRow,nCol,{ |u| if(PCount()>0, cCombo1:=u , cCombo1) },;
                  aItems,nWidth,nHeight,oPanelAtr, , { || cTela:=right(cCombo1,3), cValor:=left(cCombo1,1) } ;
                  , , , ,.T., , , , , , , , , "cCombo1" , "",1)
                  oCombo1:SetFocus()
            EndCase
            oSay:SetText( alltrim(cTextHtml) )
            cConfigCSS := FWGetCSS( "TPANEL", 68) // "QLabel {color:white; border: 1px solid #CECECE; font-size:15px; background-color:#155c94}"
            oSay:setCSS(cConfigCSS)

         Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))	CENTERED
      EndIf
   EndIf
      
Return 

/*/{Protheus.doc} getPosAtrib
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
static function getPosAtrib(oBrowse, aLista, cTela, cValor)
   Local oData     := oBrowse:Data()
   Local aMarcados := {}
   Local nC        := 0

   default aLista := {}
   default cTela  := ""
   default cValor := ""

   cTela := ""
   cValor := ""
   aEval(oData:aArray, {|x| nC++, if( !empty(x[4]) .and. x[4] == 'LBOK' , ( aAdd( aMarcados, nC ), cValor += alltrim(aLista[nC][2]) + ";", cTela += allTrim(aLista[nC][2])+"-"+aLista[nC][3]+" ;" ), ) })

   if !empty(cValor)
      cValor := substr(cValor, 1, len(cValor)-1)
      cTela := substr(cTela, 1, len(cTela)-1)
   endif

Return aMarcados

/*/{Protheus.doc} marcaAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function marcaAtributo(oBrowse)
   Local lRet     := .F.
   Local oData    := oBrowse:Data()
   Local nPos     := oBrowse:At()
   
   if len(oData:aArray) > 0
      if ! empty(oData:aArray[nPos][4]) .and. oData:aArray[nPos][4] == 'LBOK'
         lRet := .T.
      endif
   endif

Return lRet
/*/{Protheus.doc} duploClickAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function duploClickAtributo(oBrowse, lCondic)
   Local oData    := oBrowse:Data()
   Local nPos     := oBrowse:At()
   Local nCount   := 0

   default lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")

   if( lCondic .and. M->EKG_MULTVA == "1", oData:aArray[nPos][4] := if(oData:aArray[nPos][4] == 'LBOK', 'LBNO', 'LBOK'), aEval(oData:aArray, {|x| nCount++, x[4] := iif( nCount == nPos, if( X[4] == 'LBOK', 'LBNO', 'LBOK' ), 'LBNO' ) }) )
   oBrowse:Refresh(.T.)

Return
/*/{Protheus.doc} headerClickAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function headerClickAtributo(oBrowse)
   Local oData    := oBrowse:Data()

   aEval(oData:aArray, {|x| x[4] := 'LBNO' })
   oBrowse:Refresh(.T.)

Return

/*
Função   : CP400GetKey(cValor,nTam)
Objetivo   : Exibir o número de caracters disponíveis
Parâmetros : cValor: o valor digitado, nTam: o tamanho máximo
Retorno    : .T. se o tamanho do campo digitado estiver dentro do tamanho máximo e .F. se passar deste tamanho
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP400Changed(objeto,cText,oDlg,nTam)
   
   if cText # nil
      objeto:cTitle := cLabelGrid + " (" + allTrim(str(nTam-len(cText))) + ")"
   endif

Return .T. 

/*
Função   : CP400GetKey(cValor,nTam)
Objetivo   : Exibir o número de caracters disponíveis
Parâmetros : cValor: o valor digitado, nTam: o tamanho máximo
Retorno    : .T. se o tamanho do campo digitado estiver dentro do tamanho máximo e .F. se passar deste tamanho
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP400GetKey(objeto,cText,nKey,oDlg,nTam, lViaHtml)
   default lViaHtml    := .F.
   objeto:cTitle := cLabelGrid + " (" + allTrim(str(nTam-len( if( lViaHtml, TrataInf(objeto) ,cText )))) + ")"
Return .T. 

/*
Função   : CP400VlTexto(oObjeto,nTam)
Objetivo   : trata o tamanho do campo e pergunta se quer truncar
Parâmetros : objeto a trucar o texto, nTam: o tamanho máximo
Retorno    : lRet se truncou ou não o tamanho do objeto
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP400VlTexto(oObjeto,cValor,nTam,cTela, lViaHtml)
   Local lRet := .T.

   default lViaHtml    := .F.
   
   cValor   := StrTran(cValor, "<br>", ENTER)
   cTela    := StrTran(cTela, "<br>", ENTER)
   
   if len( if( lViaHtml , TrataInf(oObjeto) , cValor) ) > nTam 
      lRet := MsgNoYes(STR0036) //Tamanho do campo excedido, as informações serão truncadas. Deseja prosseguir?
      if lRet
         cValor:=substring(cValor,1,nTam)
         cTela:=cValor
         oObjeto:load( cValor )
      EndIf
   EndIf

Return lRet 

/*
Função     : CP400GravaAtr()
Objetivo   : Grava a informação no banco
Parâmetros : cTela campo gerado na tela
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400GravaAtr(oModelEKC, cTela, cValor, lCondic,  lViaHtml , oMulti, nTam)
   local aValores   := {}
   local nTamCpoVlr := 0

   default lCondic     := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   default lViaHtml    := .F.
   default nTam        := 0

   cValor := if( lViaHtml .and. valtype(oMulti) == "O", TrataInf(oMulti, nTam) , cValor )
   cTela := if( lViaHtml .and. valtype(oMulti) == "O", cValor, cTela )

   oModelEKC:SetValue("EKC_VALOR",cValor)
   nTamCpoVlr := getSx3Cache("EKC_VLEXIB", "X3_TAMANHO")
   cTela := subString(cTela,1,nTamCpoVlr)
   oModelEKC:LoadValue("EKC_VLEXIB",cTela)

   if lCondic .and. len(_aAtriCond) > 0
      aValores := if( M->EKG_MULTVA == "1", StrTokArr2(cValor,';', .T.), {cValor} )
      LoadAtrCond(oModelEKC,alltrim(M->EKG_FORMA), aValores)
   endif

return .T.

static function TrataInf(oMulti, nTam)
   local cRet   := ""

   default nTam  := 0

   cRet := strTran( if( oMulti == nil, "" , oMulti:retText()) , "<!--?-->" + CHR(10), "")
   cRet := strTran( cRet ,  "<!--?-->", "")
   cRet := strTran( cRet , CHR(10) + CHR(9) , "")
   cRet := strTran( cRet , CHR(9) , "")
   cRet := if( at( "<!--?lit$",cRet) > 0 .and. at( "$-->",cRet) > 0 , strTran( cRet , substr( cRet, at( "<!--?lit$",cRet), at( "$-->",cRet)+len("$-->")-1), "" ), cRet)

   cRet := if( nTam > 0, substr( cRet, 1, nTam), cRet)

return cRet

/*
Função     : CP400ViewAtr()
Objetivo   : Retorna a informação pra tela principal quando sai da tela do F3 sem Confirmar 
Parâmetros : 
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400ViewAtr()
   cTela := cTelaView
return .T.

/*
Função     : CP400GeraPic()
Objetivo   : Gera a picture de acordo com os parÂmeros
Parâmetros : nTam tamanho total do campo inclusive com ponto decimal
             nDec número de casas decimais
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400GeraPic(nTam,nDec)
   Local cPict := ""
   Local nI

   //define decimal
   For nI := 1 to nDec
      cPict := cPict+"9"
   Next
   if nDec <> 0
      cPict :=  "."+cPict
      nTam := nTAm - ndec -1 //-1 referente ao ponto decimal
   EndIf
   //defini parte inteira
   For nI := nTam to 1 step -1
      if Mod(nTam-nI,3) == 0 .And. (nTam-nI) > 0
            cPict := "9," + cpict
      Else 
            cPict := "9" + cpict 
      EndIf     
   Next
   cPict :=  "@E " + cPict

Return cPict

/*
Função     : EKCLineValid()
Objetivo   : Funcao de Pre validacao do grid da EKC
Retorno    : T se quiser continuar e F se não quiser continuar
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Static Function EKCLineValid(oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.
 
   Do Case
      Case cAction == "DELETE" .And. !IsInCallStack("ForceAddLine") .And. !IsInCallStack("CP400POSVL") .And. !IsInCallStack("CP400ATRIB") .and. !IsInCallStack("CP400GravaAtr")
         If Alltrim(oGridEKC:GetValue("EKC_STATUS")) != "EXPIRADO"
            Help( ,, 'HELP',, STR0034, 1, 0) //"Não é possível excluir atributos com o status Vigente ou Futuro." 
            lRet := .F.
         EndIf
   
   EndCase

Return lRet


/*
Função     : EKAPreValid()
Objetivo   : Funcao de Pre validacao do grid da EKA
Retorno    : T se quiser continuar e F se não quiser continuar
Autor      : Maurício Frison
Data       : Junho/2022
Revisão    :
*/
Static Function EKAPreValid(oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.

   Do Case
      Case cAction == "UNDELETE" 
         lRet := CP400Valid('EKA_PRDREF',.T.)
   EndCase

Return lRet

/*
Função     : EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)
Objetivo   : Funcao para quando efetuado um duplo clik no item abrir em tela
Retorno    : Retorno lógico
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Static Function EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)
   Local lRet := .F.

   lRet := CP400TELA()

Return lRet
/*
Class      : CP400EV
Objetivo   : CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Class CP400EV FROM FWModelEvent
     
   Method New()
   Method Activate()
   Method VldActivate()

End Class
/*
Class      : Método New Class CP400EV 
Objetivo   : Método para criação do objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method New() Class CP400EV
Return
/*
Class      : Método New Class CP400EV 
Objetivo   : Método para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method Activate(oModel,lCopy) Class CP400EV
   cNCm  := "          "
   cModalEK9 := ""
   cPrdRefEK9 := ""   
   CP400ATRIB(.T.)
Return 

Method VldActivate(oModel) Class CP400EV
   local lRet := .F.
   lRet := !getPedOper() .or. CP400ValAct(oModel)
Return lRet

/*
Função     : EKALineValid()
Objetivo   : Funcao de Pre validacao do grid da EKA
Retorno    : T se quiser continuar e F se não quiser continuar
Autor      : Maurício Frison
Data       : Abr/2020
Revisão    :
*/
Static Function EKALineValid(oModelEKA)
   Local lRet := .T.

   if IsInCallStack("CP400AtLn1") 
      lRet := lRetAux
   EndIf

Return lRet

/*
Função     : EKBLnVlPos()
Objetivo   : Funcao de Pos validacao da linha do grid da EKB - Relação de Países de Origem e Fabricantes
Retorno    : T se validar  e F se não validar
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function EKBLnVlPos(oModelEKB)
   Local lRet := .T.
   Local lEmpPais := .T.
   if oModelEKB:HasField("EKB_PAIS")
      lEmpPais :=  Empty(oModelEKB:GetValue("EKB_PAIS"))
   EndIf
   If Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. lEmpPais //Empty(oModelEKB:GetValue("EKB_PAIS")) //informou o fabricante e o país está vazio
      Help(" ",1,"CP400FABRP") //"Veja que na linha: " ## "Problema: Não foram informados fabricantes ou países de origem. Solução: Informe ao menos um país de origem ou fabricante para prosseguir" 
      lRet := .F.
   EndIf

Return lRet


/*
Programa   : TemIntegEKD
Objetivo   : Verifica se para o Catalogo informado, existe registro Integrado ou Cancelado
Retorno    : .T. quando encontrar registro Integrado ou Cancelado; .F. não encontrar registro Integrado ou Cancelado
Autor      : Ramon Prado
Data/Hora  : Maio/2020
*/
Static Function TemIntegEKD(cCod_I)
   Local lRet := .F.
   Local cQuery

   cQuery := "SELECT EKD_COD_I FROM " + RetSQLName("EKD")
   cQuery += " WHERE EKD_FILIAL = '" + xFilial("EKD") + "' "
   cQuery += "   AND EKD_COD_I  = '" + cCod_I + "' "
   cQuery += "   AND (EKD_STATUS = '1' OR EKD_STATUS = '3') " //Registrado ou Cancelado
   cQuery += "   AND D_E_L_E_T_ = ' ' "

   If EasyQryCount(cQuery) != 0
      lRet := .T.
   EndIf

Return lRet


/*/{Protheus.doc} CP400IFbPO
   Função que realiza a integração com o siscomex para cada fabricante/país de origem 
   relacionado ao catálogo de produtos integrado.
   @author Nilson César
   @since 08/05/2021
   @version 1
/*/
Function CP400IFbPO(cPathAuth,cPathIAOE,oProcIntFb,lEnd,cErros,oEasyJS)
   Local nQtdInt     := 0
   Local cRet        := ""
   Local cAux        := ""
   Local cSucesso    := ""
   Local cCodigo     := ""
   Local ctxtJsonFB  := ""
   Local aFabrPaises := {}
   Local aJson       := {}
   Local aJsonErros  := {}
   Local lRet        := .T.
   //Local oEasyJS
   Local oJson
   Local cRetJson
   Local nFab
   Local nj,nInd
   Local cCpfCnpjR, cCodOEFB, cCpfCnpjFB, cConhFB, cCodProdF, cVincFB, cCodPaisF
   Local lEKFVincFB:=EKF->(FieldPos("EKF_VINCFB")) > 0 

   cChaveEKF := xFilial("EKF") + EKD->EKD_COD_I + EKD->EKD_VERSAO
   If EKF->(DbSeek( cChaveEKF ))      
      Do While EKF->(!Eof()) .And. EKF->( EKF_FILIAL + EKF_COD_I + EKF_VERSAO ) ==  cChaveEKF
         If lEKFVincFB .And. !Empty(EKF->EKF_VINCFB) .And. !(EKF->EKF_VINCFB $ "3|4|5")  // NCF - 11/05/2021 - Só serão setados para integração fabricantes a vincular ou desvincular
            nQtdInt++
            aAdd( aFabrPaises, EKF->(Recno()) )
         EndIf
         EKF->(DbSkip())
      EndDo
   EndIf

   oProcIntFb:SetRegua1(nQtdInt)

   for nFab := 1 to nQtdInt
      If lEnd	//houve cancelamento do processo
         lRet := .F.
         Exit
      EndIf
      EKF->(dbgoto(aFabrPaises[nFab]))

         oProcIntFb:IncRegua1( STR0086 + EKF->EKF_CODFAB + "/" + EKF->EKF_LOJA /*  + "/" + EKF->EKF_PAIS*/ ) // "Integrando:"
         oProcIntFb:SetRegua2(1)

         cConhFB   := If( !Empty(EKF->EKF_CODFAB) , "true" , "false"    )
         cVincFB   := If(lEKFVincFB,If( EKF->EKF_VINCFB == "1" , "true" , "false" ),"false")
         cCpfCnpjR := EKD->EKD_CNPJ
         cCodProdF := EKF->EKF_COD_I
         cCodPaisF := EKF->EKF_PAIS // EKF->EKF_PAIS

         If !Empty(EKF->EKF_CODFAB)
            EKJ->(dbsetorder(1),msseek(  xFilial("EKJ") + EKD->EKD_CNPJ + EKF->EKF_CODFAB + EKF->EKF_LOJA  ))  // Posiciona no registro de Operador Estrangeiro do Fabricante
            if EKJ->EKJ_PAIS == "BR"
               SA2->(dbsetorder(1),msseek(xFilial("SA2") + EKF->EKF_CODFAB + EKF->EKF_LOJA))
               cCpfCnpjFB := SA2->A2_CGC 
               cCodOEFB   := ""
            else // se o pais origem for diferente de brasil manda o código do operador estrangeiro
               cCodOEFB   := EKJ->EKJ_TIN
               cCpfCnpjFB := ""
            endif
            cCpfCnpjR := EKJ->EKJ_CNPJ_R
         Else
            cCodOEFB   := ""
            cCpfCnpjFB := ""
         EndIf

         ctxtJsonFB += If( nFab == 1,"[","")
         // Monta o texto do json para a integração
         ctxtJsonFB += '{' + ;
                        ' "seq": '                         + Alltrim(Str(nFab))  + ' ,' + ;
                        ' "cpfCnpjRaiz": "'                + cCpfCnpjR         + '",' + ;
                        ' "codigoOperadorEstrangeiro": "'  + cCodOEFB          + '",' + ;
                        ' "cpfCnpjFabricante": "'          + cCpfCnpjFB        + '",' + ;
                        ' "conhecido": "'                  + cConhFB           + '",' + ;
                        ' "codigoProduto": "'              + cCodProdF         + '",' + ;
                        ' "vincular": "'                   + cVincFB           + '",' + ;  //' "dataReferencia": "'             + 
                        ' "codigoPais": "'                 + cCodPaisF         + '"' + ;    //Campo Novo
                        '}'

         ctxtJsonFB += If( nFab < nQtdInt , "," , "]" )
         
      next nFab
      
      If nQtdInt > 0

         oEasyJS:runJSSync( CP400Auth( cPathAuth , cPathIFbPO , ctxtJsonFB ) ,{|x| cRet := x } , {|x| cErros := x } )

         // Pega o retorno e converte para json para extrair as informações
         if !Empty(cRet)
            cRet     := '{"items":'+cRet+'}'
            oJson    := JsonObject():New()
            cRetJson := oJson:FromJson(cRet)
            if valtype(cRetJson) == "U" 
               if valtype(oJson:GetJsonObject("items")) == "A"
                  aJson    := oJson:GetJsonObject("items")
                  For nInd := 1 To len(aJson)
                     cSucesso := aJson[nInd]:GetJsonText("sucesso")
                     cCodigo  := aJson[nInd]:GetJsonText("codigo")
                     cSequence:= aJson[nInd]:GetJsonText("seq")

                     if cSucesso == "false" .And. valtype(aJson[nInd]:GetJsonObject("erros")) == "A"
                        aJsonErros := aJson[1]:GetJsonObject("erros")
                        EKF->(dbgoto(aFabrPaises[ Val(cSequence)]))
                        cErros += "Fabricante: "+EKF->EKF_CODFAB+" | Loja: "+EKF->EKF_LOJA+" | País de Origem: "+EKF->EKF_PAIS+" | Erro: "   
                        for nj := 1 to len(aJsonErros)
                           cErros += aJsonErros[nj] + ENTER
                        next
                        if empty(cErros)
                           cErros += STR0060 //Arquivo de retorno inválido
                        endif                     
                     endif

                     //Atualiza a tabela de status da integração de fabricantes
                     if lEKFVincFB
                        EKF->(dbgoto(aFabrPaises[Val(cSequence)]))
                        cStatusInt := If(  Upper(cSucesso)=="TRUE" , If( EKF->EKF_VINCFB == "1" , "4"  , "5"    )    ,  EKF->EKF_VINCFB  )
                        If EKF->EKF_VINCFB <> cStatusInt
                           EKF->(RecLock("EKF",.F.))
                           EKF->EKF_VINCFB := cStatusInt
                           EKF->(MsUnlock())
                        EndIf
                     EndIf   

                     oProcIntFb:IncRegua2( If( Empty(cErros)  , STR0062 , STR0063 ) ) // "Integrado!"  // "Falha!"

                  Next nInd
               else
                  cErros += STR0059 + ENTER // "Arquivo de retorno sem itens!"
               endif
               FreeObj(oJson)
            else
               cErros += STR0071 + ENTER + alltrim(cRet) // "Não foi possível fazer o parse do JSON de retorno da integração."
            endif
         elseif empty(cErros)
            cErros += STR0061 + ENTER // "Integração sem nenhum retorno!"
         endif

         // caso dê tudo certo grava as informações e finaliza o registro
         if !( !empty(cRet) .and. !empty(cSucesso) .and. upper(cSucesso) == "TRUE" )
            lRet := .F.
            cAux += STR0090 + ENTER + cErros   // "Ocorreu um problema no retorno da integração de fabricantes: "
         endif

         cErros   := ""
         cRet     := ""
         cCodigo  := ""
         cSucesso := ""
      
         if !Empty(cAux)
            cErros := cAux
         endif
         
      EndIf

Return lRet

/*/{Protheus.doc} CP400ValAct
   Função que é chamado pra saber se o Model será ativado e a tela do catálogo será ou não aberta   
   @author Ramon Prado
   @since 18/05/2021
   @version 1
/*/
Function CP400ValAct(oModel)
   Local oModelEK9	:= oModel:GetModel("EK9MASTER")
   Local nOperation  := oModelEK9:GetOperation()
   Local lRet        := .T.
   Local cStatusEKD  := ""
   Local cCatEK9     := ""

   If nOperation == 4 //Alteração   
      cCatEK9    := EK9->EK9_COD_I
      cStatusEKD := CP400StEKD(cCatEK9) //função que retorna o Status da ultima integração/Historico do Catálogo
      If cStatusEKD == '5' /*Registrado (pendente: fabricante/ país)*/
         If MsgYesNo(STR0093) //"Existem pendências de integração do Catálogo de Produtos referente ao vínculo de Operadores Estrangeiros. Deseja processar a integração pendente?" 
            lRet := CP400Integrar()
            If lRet
               cStatusEKD := CP400StEKD(cCatEK9) //função que retorna o Status da ultima integração/Historico do Catálogo
               If cStatusEKD == '5' /*Registrado (pendente: fabricante/ país)*/ 
                  lRet := .F. //continua com Status Registrado (pendente: fabricante/ país) -- Pendência não resolvida de Integ. Fabricante
               EndIf
            EndIf
         Else
            lRet := .F.
         EndIf
      EndiF
   EndIf
   If !lRet   
      EasyHelp(STR0094,STR0002,STR0095) //Problema:"Não foi possível prosseguir com a alteração do catálogo de produtos!" ## Solução: "Para prosseguir com alteração resolva a(s) pendência(s) solicitando nova Integração do Catálogo de Produtos"
   EndIf
Return lRet

/*/{Protheus.doc} CP400StEKD
   Função que retorna o Status da ultima integração/Historico do Catálogo
   @author Ramon Prado
   @since 18/05/2021
   @version 1
/*/
Function CP400StEKD(cCatEK9)
   Local cStatusEKD  := ""
   Local aArea       := GetArea()

   EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão
   If EKD->(AvSeekLAst( xFilial("EKD") + cCatEK9 ))
      cStatusEKD := EKD->EKD_STATUS
   EndIf

   RestArea(aArea)
Return cStatusEKD

Static Function AddColumns(aColumns, cAlias)
Local nInc
Local aStruct := (cAlias)->(DbStruct())
Local aBrowse := {}
Local cColumn, bBlock, cType, nSize, nDec, cTitle, cPicture, nAlign

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
   For nInc := 1 To Len(aColumns)

      cColumn := Alltrim(aColumns[nInc])
      bBlock := &("{ ||" + cColumn + " }")
      cType := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][2]
      nSize := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][3]
      nDec := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][4]

      cTitle   := AvSX3(cColumn, AV_TITULO)
      cPicture := AvSX3(cColumn, AV_PICTURE)
      nAlign := If(cType<>"N", 1, 2)
      aAdd(aBrowse, {cTitle,bBlock,cType,cPicture,nAlign,nSize,nDec,.F.,{||.T.},.F.,{||.T.}, cColumn, {||.T.},.F.,.F.})
   Next

Return aBrowse


Static Function AllCpoIndex(cAlias,aColunas)
Local aInd
Local aAux
Local oAliasStru := FWFormStruct(1,cAlias)
Local nI
Local nY

Default aColunas := {}

aInd := oAliasStru:GetIndex()

For nI := 1 To Len(aInd)
   aAux := StrTokArr(aInd[nI][3],'+')
   For nY := 1 To Len(aAux)
      If aScan(aColunas,{|X| Alltrim(X) == Alltrim(aAux[nY])}) == 0
         aAdd(aColunas,Alltrim(aAux[nY]))
      EndIf
   Next
Next

Return aColunas

/*/{Protheus.doc} CpoModel
   inclusão de campo no modelo 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param  oStruct, Objeto, Objeto da classe FWFormStruct
   @return 
/*/
static function CpoModel( oStruct )
   oStruct:AddField( "Obrigatório"                  , ; // [01]  C   Titulo do campo
                     "Obrigatório"                  , ; // [02]  C   ToolTip do campo
                     "ATRIB_OBRIG"                  , ; // [03]  C   identificador (ID) do Field
                     "C"                            , ; // [04]  C   Tipo do campo
                     1                              , ; // [05]  N   Tamanho do campo
                     0                              , ; // [06]  N   Decimal do campo
                     {|| .T. }                      , ; // [07]  B   Code-block de validação do campo
                     {|| .F. }                      , ; // [08]  B   Code-block de validação When do campo
                     {"1=Sim", "2=Não"}             , ; // [09]  A   Lista de valores permitido do campo
                     .F.                            , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
                     {|| CP400Relac("ATRIB_OBRIG") }, ; // [11]  B   Code-block de inicializacao do campo
                     .F.                            , ; // [12]  L   Indica se trata de um campo chave
                     .T.                            , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                     .T.                            )   // [14]  L   Indica se o campo é virtual

   if Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
      oStruct:AddField( "Ordem"                        , ; // [01]  C   Titulo do campo
                        "Ordem"                        , ; // [02]  C   ToolTip do campo
                        "ATRIB_ORDEM"                  , ; // [03]  C   identificador (ID) do Field
                        "C"                            , ; // [04]  C   Tipo do campo
                        7                              , ; // [05]  N   Tamanho do campo
                        0                              , ; // [06]  N   Decimal do campo
                        {|| .T. }                      , ; // [07]  B   Code-block de validação do campo
                        {|| .F. }                      , ; // [08]  B   Code-block de validação When do campo
                        {}                             , ; // [09]  A   Lista de valores permitido do campo
                        .F.                            , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
                        nil                            , ; // [11]  B   Code-block de inicializacao do campo
                        .F.                            , ; // [12]  L   Indica se trata de um campo chave
                        .T.                            , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.                            )   // [14]  L   Indica se o campo é virtual
   endif

return

/*/{Protheus.doc} CpoView
   inclusão de campo no view 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param  oStruct, Objeto, Objeto da classe FWFormStruct
   @return 
/*/
static function CpoView( oStruct )
   local nOrdem := val(getSX3Cache("EKC_CODATR", "X3_ORDEM"))+1

   oStruct:AddField(	"ATRIB_OBRIG"      , ;  // [01]  C   Nome do Campo
                     StrZero(nOrdem,2)  , ;  // [02]  C   Ordem
                     "Obrigatório"      , ;  // [03]  C   Titulo do campo
                     "Obrigatório"      , ;  // [04]  C   Descrição do campo
                     nil                , ;  // [05]  A   Array com Help
                     "C"                , ;  // [06]  C   Tipo do campo
                     ""                 , ;  // [07]  C   Picture
                     nil                , ;  // [08]  B   Bloco de Picture Var
                     ''                 , ;  // [09]  C   Consulta F3
                     .F.                , ;  // [10]  L   Indica se o campo é editável
                     ""                 , ;  // [11]  C   Pasta do campo
                     ""                 , ;  // [12]  C   Agrupamento do campo
                     {"1=Sim", "2=Não"} , ;  // [13]  A   Lista de valores permitido do campo (Combo)
                     nil                , ;  // [14]  N   Tamanho Maximo da maior opção do combo
                     nil                , ;  // [15]  C   Inicializador de Browse
                     .T.                , ;  // [16]  L   Indica se o campo é virtual
                     nil                )    // [17]  C   Picture Variável

return

/*/{Protheus.doc} LoadAtrCond
   Carrega no modelo EKC os atributos condicionados

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, Objeto, Modelo EKC
          cValor, caracter, valor do atributo
   @return 
/*/
static function LoadAtrCond(oModelEKC, cFormaPai, aValores)
   local cCodAtrib  := ""
   local nPosCond   := 0
   local oModel     := nil
   local oModelEK9  := nil
   local cCodCat    := ""
   local cAtribCond := ""
   local cError     := ""
   local lError     := .F.
   local cOrdem     := ""
   local nOrdCond   := 0
   local cNewOrdem  := ""
   local aIncAtrib  := {}
   local aExcAtrib  := {}
   local aBackLines := {}
   local nPosCpoAtb := 0
   local nPosCpoCnd := 0
   local nPosOrdem  := 0
   local nAtrib     := 0
   local cMsgError  := STR0112 // "Verifique como está cadastrado a condição do atributo."
   local aNoExclui  := {}
   local nValor     := 0
   local cValor     := ""
   local nPosExc    := 0

   default cFormaPai := ""
   default aValores  := {}

   cCodAtrib := oModelEKC:GetValue("EKC_CODATR")
   nPosCond := aScan( _aAtriCond , { |X| X[1] == cCodAtrib })

   if nPosCond > 0

      oModel := oModelEKC:getModel()
      oModelEK9 := oModel:getModel("EK9MASTER")
      oModelEKC:SetNoInsertLine(.F.)
      cCodCat := oModelEK9:GetValue("EK9_COD_I")

      for nValor := 1 to len(aValores)
         cValor := aValores[nValor]
         nPosCond := aScan( _aAtriCond , { |X| X[1] == cCodAtrib })
         while nPosCond > 0

            EKG->(dbGoTo(_aAtriCond[nPosCond][2]))
            if EKG->(recno()) == _aAtriCond[nPosCond][2]
               cAtribCond := alltrim(EKG->EKG_COD_I) + " - " + alltrim(EKG->EKG_NOME)
               cError := ""
               lError := .F.
               cOrdem := substr(oModelEKC:getValue("ATRIB_ORDEM"), 1, 3 )
               if !empty(cValor) .and. VldAtrCond(alltrim(EKG->EKG_CONDIC), cFormaPai, alltrim(cValor), @cError, @lError) // Realiza a inclusão dos condicionados
                  if !oModelEKC:SeekLine({{"EKC_COD_I", cCodCat} ,{"EKC_CODATR", EKG->EKG_COD_I },{"EKC_CONDTE", cCodAtrib }}, .T.)
                     nOrdCond := 1
                     cNewOrdem := cOrdem + "_" + strZero(nOrdCond, 3)
                     while oModelEKC:SeekLine({{"ATRIB_ORDEM", cNewOrdem}}, .T.)
                        nOrdCond += 1
                        cNewOrdem := cOrdem + "_" + strZero(nOrdCond, 3)
                     end
                     aAdd( aIncAtrib, {cCodAtrib, EKG->EKG_COD_I, cNewOrdem, _aAtriCond[nPosCond][2]} )
                  endif
                  aAdd( aNoExclui, {cCodCat, EKG->EKG_COD_I, cCodAtrib} )
                  if len(aExcAtrib) > 0
                     nPosExc := aScan( aExcAtrib, { |X| X[1] == cCodAtrib .and. X[2] == EKG->EKG_COD_I } )
                     if nPosExc > 0
                        aDel(aExcAtrib, nPosExc)
                        aSize( aExcAtrib, len(aExcAtrib)-1)
                     endif
                  endif
               elseif !lError // Realiza a exclusão dos condicionados
                  if ( len(aNoExclui) == 0 .or. aScan(aNoExclui, { |X| X[1] == cCodCat .and. X[2] == EKG->EKG_COD_I .and. X[3] == cCodAtrib}) == 0) .and. oModelEKC:SeekLine({{"EKC_COD_I", cCodCat} ,{"EKC_CODATR", EKG->EKG_COD_I },{"EKC_CONDTE", cCodAtrib }}, .T.) .and. aScan( aExcAtrib, { |X| X[1] == cCodAtrib .and. X[2] == EKG->EKG_COD_I } ) == 0
                     aAdd( aExcAtrib, {cCodAtrib, EKG->EKG_COD_I, oModelEKC:getValue("ATRIB_ORDEM"), _aAtriCond[nPosCond][2]} )
                  endif
               endif
            endif

            nPosCond := if( !lError , aScan( _aAtriCond , { |X| X[1] == cCodAtrib }, nPosCond+1), 0)
         end
      next

      if( lError, EasyHelp(STR0113 + " [" + cAtribCond + "]" + CHR(10) + CHR(10) + STR0114 + ": " + cError, STR0067, cMsgError), nil) // "Não foi possível carregar os atributos condicionados" ### "Erro"

      if !lError .and. (len(aIncAtrib) > 0 .or. len(aExcAtrib) > 0)

         aBackLines := GetLines(oModelEKC, aExcAtrib)

         aSize(oModelEKC:aDataModel, 0)
         oModelEKC:aDataModel := {}
         oModelEKC:InitLine()

         if len(aBackLines) > 0
            nPosCpoAtb := aScan(aBackLines[1], { |X| X[1] == "EKC_CODATR" } )
            nPosCpoCnd := aScan(aBackLines[1], { |X| X[1] == "EKC_CONDTE" } )
            nPosOrdem := aScan(aBackLines[1], { |X| X[1] == "ATRIB_ORDEM" } )
         endif

         for nAtrib := 1 to len(aBackLines)
            if !oModelEKC:SeekLine({{"ATRIB_ORDEM", aBackLines[nAtrib][nPosOrdem][2]}}, .T.)
               //nPosCond := if( len(aExcAtrib) == 0 , 0, aScan( aExcAtrib , { |X| X[1] == aBackLines[nAtrib][nPosCpoAtb][2] }))
               //if nPosCond == 0
                  AddLine(oModelEKC, aBackLines[nAtrib], !(nAtrib == 1))
               //endif
               if len(aIncAtrib) > 0 .and. cCodAtrib == aBackLines[nAtrib][nPosCpoAtb][2] .and. empty(aBackLines[nAtrib][nPosCpoCnd][2])
                  nPosCond := aScan( aIncAtrib , { |X| X[1] == aBackLines[nAtrib][nPosCpoAtb][2] })
                  while nPosCond > 0
                     AddLine(oModelEKC)
                     getInfCond(oModelEKC, aIncAtrib[nPosCond][4] , cCodCat, aIncAtrib[nPosCond][3])
                     nPosCond := aScan( aIncAtrib , { |X| X[1] == aBackLines[nAtrib][nPosCpoAtb][2] }, nPosCond+1)
                  end
               endif
            endif
         next

      endif

      OrdAtrib(oModelEKC)

      oModelEKC:SetNoInsertLine(.T.)
      oModelEKC:SeekLine({{"EKC_COD_I", cCodCat} ,{"EKC_CODATR", cCodAtrib }})

   endif

return

/*/{Protheus.doc} VldAtrCond
   Valida todas as condições dos atributos condicionados com o valor do condicionante

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param cCondicao, caracter, condição para o condicionado
          cInfo, caracter, valor do atributo condicionante
          cError, caracter, mensagem de erro
          lError, logico, houve erro da verificação da condição
   @return 
/*/
static function VldAtrCond(cCondicao, cFormaPai, cInfo, cError, lError)
   local lRet       := .F.
   local oJson      := nil
   local aNames     := {}

   default cCondicao  := ""
   default cFormaPai  := ""
   default cInfo      := ""
   default cError     := ""
   default lError     := .F.

   if !empty(cCondicao)
      oJson := JsonObject():New()
      if oJson:FromJson(cCondicao) == nil
         while !( lRet := JsonCond( oJson, cFormaPai, cInfo, @cError, @lError )) .and. !lError
            aNames := oJson:GetNames()
            if aScan( aNames , { |X| X == "composicao" }) > 0 .and. aScan( aNames , { |X| X == "condicao" }) > 0 .and. valtype(oJson["condicao"]) == "J"
               oJson := oJson["condicao"]
            else
               exit
            endif
         end
      endif
      fwFreeObj(oJson)
   endif

return lRet

/*/{Protheus.doc} JsonCond
   Valida a condição dos atributos condicionados com o valor do condicionante

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param cCondicao, caracter, condição para o condicionado
          cInfo, caracter, valor do atributo condicionante
          cError, caracter, mensagem de erro
          lError, logico, houve erro da verificação da condição
   @return 
/*/
static function JsonCond( oJsonCond, cFormaPai, cInfo, cError, lError )
   local lRet       := .F.
   local aNames     := {}
   local cOperador  := ""
   local cValor     := ""
   local oErr       := nil
   local bLastError := {||}

   default cError := ""
   default lError := .F.

   aNames := oJsonCond:GetNames()

   if aScan( aNames , { |X| X == "operador" }) > 0
      cOperador := alltrim(oJsonCond["operador"])
   endif

   if aScan( aNames , { |X| X == "valor" }) > 0
      cValor := alltrim(oJsonCond["valor"])
      if lower( cValor ) == "true" .or. lower(cValor) == "false" .or. cFormaPai == "BOOLEANO"
         cValor := if(cValor == "true", "1", if(cValor == "false", "2", "true / false"))
      elseif !isnumeric(cInfo) .and. !isnumeric(cValor)
         cValor := "'" + lower(cValor) + "'"
         cInfo := "'" + lower(cInfo) + "'"
      endif
   endif

   bLastError := ErrorBlock( { |e| oErr := e, lError := .T., lRet := .F.})
   if !empty(cOperador) .and. !empty(cValor)
      lRet := &(cInfo + cOperador + cValor)
   endif
   ErrorBlock(bLastError)

   //if( valType(oErr) != "U", cError := oErr:ERRORSTACK, nil)
   if( valType(oErr) != "U", cError := STR0115 + ": " + cInfo + " " + cOperador + " " + cValor, nil) // "Falha ao verificar a condição"

return lRet

/*/{Protheus.doc} loadInfAtr
   Carrega o modelo EKC de acordo com os parametros  

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKC
          aInf, vetor, informações do atributo em vetor
          lCondic, logico, ambiente atualizado com o campo EKC_CONDTE
          cCodCat, caracter, código do catalogo de produto
   @return 
/*/
static function loadInfAtr(oModelEKC, cAliasTb, lCondic, cCodCat, cOrdem)

   default cAliasTb := "EKG"
   default lCondic  := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   default cCodCat  := ""
   default cOrdem   := ""

   oModelEKC:LoadValue("EKC_COD_I"  , cCodCat)
   oModelEKC:LoadValue("EKC_CODATR" , (cAliasTb)->EKG_COD_I)
   oModelEKC:LoadValue("EKC_STATUS" , CP400Status((cAliasTb)->EKG_INIVIG,(cAliasTb)->EKG_FIMVIG))
   oModelEKC:LoadValue("EKC_NOME"   , AllTrim((cAliasTb)->EKG_NOME))
   oModelEKC:LoadValue("ATRIB_OBRIG", if(empty((cAliasTb)->EKG_OBRIGA),"2", (cAliasTb)->EKG_OBRIGA))
   oModelEKC:LoadValue("EKC_VALOR"  , "" )
   if lCondic 
      oModelEKC:LoadValue("EKC_CONDTE" , (cAliasTb)->EKG_CONDTE)
      oModelEKC:LoadValue("ATRIB_ORDEM", cOrdem )
   endif

return

/*/{Protheus.doc} OrdAtrib
   Ordenar os atributos 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKC
   @return 
/*/
static function OrdAtrib(oModelEKC)
   local nPosOrdem  := 0
   local oStrGrd    := oModelEKC:getStruct()

   nPosOrdem  := oStrGrd:GetFieldPos("ATRIB_ORDEM")
   if nPosOrdem > 0
      aSort(oModelEKC:aDATAMODEL,,, {|x,y| x[1][1][nPosOrdem] < y[1][1][nPosOrdem] } )
   endif

return 

/*/{Protheus.doc} GetLines
   Realiza o backup dos dados do grid

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oMdlGrid, objeto, modelo da grid
   @return 
/*/
static function GetLines(oMdlGrid, aNoCopy)
   local oStrGrd    := nil
   local aCposGrd   := {}
   local aRet       := {}
   local nReg       := 0
   local aReg       := {}
   local nCpo       := 0

   default aNoCopy := {}

   oStrGrd  := oMdlGrid:getStruct()
   aCposGrd := oStrGrd:GetFields()

   for nReg := 1 To oMdlGrid:GetQtdLine()
      oMdlGrid:Goline(nReg)
      if len(aNoCopy) > 0 .and. aScan( aNoCopy , { |X| X[2] == oMdlGrid:getValue("EKC_CODATR") .and. X[1] == oMdlGrid:getValue("EKC_CONDTE") }) > 0  
         loop
      endif
      aReg := {}
      for nCpo := 1 to Len(aCposGrd)
         aAdd(aReg,{aCposGrd[nCpo][3], oMdlGrid:GetValue(aCposGrd[nCpo][3])})
      next nCpo
      aAdd(aRet,aClone(aReg))
      aSize(aReg,0)
   next nReg

return aRet

/*
Função     : AddLine
Objetivo   : Adiciona uma linha no grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function AddLine(oModelDet, aLoadCpos, lAddLine)
   local nLine     := 0
   local nCpo      := 0

   default aLoadCpos   := {}
   default lAddLine    := .T.

   nLine := oModelDet:GetLine()
   if lAddLine
      nLine := oModelDet:AddLine()
   endif

   for nCpo := 1 to Len(aLoadCpos)
      oModelDet:LoadValue( aLoadCpos[nCpo][1], aLoadCpos[nCpo][2] )
   next

return nLine

/*
Função     : getInfCond
Objetivo   : Realiza a atualização do modelo de dados EKC a partir da EKG
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function getInfCond(oModelEKC, nRecEKG, cCodCat, cOrdem)
   EKG->(dbGoTo(nRecEKG))
   loadInfAtr(oModelEKC, , .T., cCodCat, cOrdem)
return

/*
Função     : CommitEKC
Objetivo   : Commit do modelo de dados da EKC
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function CommitEKC( oModelo )
   local lCondic   := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local oModelEKC := nil
   local cQuery    := ""
   local oQuery    := nil
   local cAliasQry := ""
   local oStrGrd   := nil
   local aCposGrd  := {}
   local nRegEKC   := 0
   local lSeek     := .F.
   local nCpo      := 0
   local aCpos     := {}
   local nOperat   := oModelo:getOperation()

   if !nOperat == MODEL_OPERATION_VIEW

      oModelEKC := oModelo:getModel("EKCDETAIL")

      cQuery := " SELECT "
      cQuery += " R_E_C_N_O_ REC_EKC, EKC_FILIAL, EKC_COD_I, EKC_CODATR " 
      if lCondic
         cQuery += " , EKC_CONDTE "
      endif
      cQuery += " FROM " + RetSqlName('EKC') + " EKC "
      cQuery += " WHERE EKC.D_E_L_E_T_ = ' ' "
      cQuery += " AND EKC.EKC_FILIAL = ? "
      cQuery += " AND EKC.EKC_COD_I = ? "
      cQuery += " ORDER BY EKC_FILIAL, EKC_COD_I, EKC_CODATR "
      if lCondic
         cQuery += " , EKC_CONDTE "
      endif

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,xFilial('EKC'))
      oQuery:SetString(2,oModelEKC:GetValue("EKC_COD_I"))
      cQuery := oQuery:GetFixQuery()

      cAliasQry := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      while (cAliasQry)->(!eof())
         if !oModelEKC:SeekLine( if( lCondic, {{"EKC_COD_I", (cAliasQry)->EKC_COD_I} , {"EKC_CODATR", (cAliasQry)->EKC_CODATR } , {"EKC_CONDTE", (cAliasQry)->EKC_CONDTE }} , {{"EKC_COD_I" , (cAliasQry)->EKC_COD_I} , {"EKC_CODATR", (cAliasQry)->EKC_CODATR }} ), .T. )
            EKC->(dbGoTo((cAliasQry)->REC_EKC))
            if (cAliasQry)->REC_EKC == EKC->(recno())
               EKC->(reclock("EKC", .F.))
               EKC->(dbDelete())
               EKC->(MsUnlock())
            endif
         endif
         (cAliasQry)->(dbSkip())
      end
      (cAliasQry)->(dbCloseArea())
      oQuery:Destroy()

      EKC->(dbSetOrder(1)) // EKC_FILIAL+EKC_COD_I+EKC_CODATR
      oStrGrd  := oModelEKC:getStruct()
      aCposGrd := oStrGrd:GetFields()
      for nCpo := 1 to len(aCposGrd)
         if EKC->(ColumnPos(aCposGrd[nCpo][3])) > 0
            aAdd( aCpos, aCposGrd[nCpo][3])
         endif
      next

      for nRegEKC := 1 to oModelEKC:length()
         oModelEKC:goLine(nRegEKC)
         lSeek := EKC->(dbSeek( xFilial("EKC") + oModelEKC:getValue("EKC_COD_I") + oModelEKC:getValue("EKC_CODATR") + if( lCondic, oModelEKC:getValue("EKC_CONDTE"), "") ))

         if nOperat == MODEL_OPERATION_DELETE .or. oModelEKC:isDeleted()
            if lSeek
               EKC->(reclock("EKC", .F.))
               EKC->(dbDelete())
               EKC->(MsUnlock())
            endif
         else
            EKC->(reclock("EKC", !lSeek))
            for nCpo := 1 to len(aCpos)
                  EKC->&(aCpos[nCpo]) := oModelEKC:GetValue( aCpos[nCpo] )
            next
            if !lSeek
               EKC->EKC_FILIAL := xFilial("EKC")
               EKC->EKC_COD_I  := oModelEKC:getValue("EKC_COD_I")
               EKC->EKC_CODATR := oModelEKC:getValue("EKC_CODATR")
            endif
            EKC->(MsUnlock())
         endif
      next nRegEKC

   endif

return

/*
Função     : CP400Init
Objetivo   : Inicializador padrão para os campos
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
Obs.       :
*/
function CP400Init(cCampo) 
   local xValue

   do case
      case cCampo == 'EK9_MODALI'
         xValue := "1"
         if FwIsInCallStack("EECCP400")
            xValue := "2"
         endif
   end case

return xValue

/*
Função     : ValIdVers
Objetivo   : Valida se o catalogo de produto e a versão já existe.
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
Obs.       : 
*/
static function ValIdVers(cIdMan, cVerMan, nOpc, cMsgError)
   local lRet       := .T.
   local aArea      := getArea()
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""

   default cIdMan    := ""
   default cVerMan   := ""
   default nOpc      := 0
   default cMsgError := ""

   if !empty(cIdMan) .and. !empty(cVerMan)
      cAliasQry := getNextAlias()

      cQuery := " SELECT EK9.EK9_COD_I, EK9.EK9_IDPORT, EK9.EK9_VATUAL "
      cQuery += " FROM " + RetSqlName('EK9') + " EK9 "
      cQuery += " WHERE EK9.D_E_L_E_T_ = ' ' "
      cQuery += " AND EK9.EK9_FILIAL = ? "
      cQuery += " AND EK9.EK9_IDPORT = ? "
      cQuery += " AND EK9.EK9_VATUAL = ? "
      if nOpc == MODEL_OPERATION_UPDATE
         cQuery += " AND EK9.R_E_C_N_O_ <> " + alltrim(str(EK9->(Recno()))) + " "
      endif

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,xFilial('EK9'))
      oQuery:SetString(2,cIdMan)
      oQuery:SetString(3,cVerMan)

      cQuery := oQuery:GetFixQuery()

      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
         lRet := .F.
         cMsgError := STR0118 // "O catálogo de produto e a versão já está registrado no sistema."
      endif

      (cAliasQry)->(dbCloseArea())

      fwFreeObj(oQuery)

   endif

   restArea(aArea)

return lRet


/*
Função     : ValProcExp
Objetivo   : Valida se o catalogo de produto e a versão está sendo usada no item do processo de embarque
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
Obs.       : Como os campos de EK9_IDPORT e EK9_VATUAL são atualizados somente na confirmação, ou seja, não engatilhamos, podemos usar os campos para validação
*/
static function ValProcExp(cIdMan, cVerMan, cMsgError)
   local lRet       := .T.
   local aArea      := getArea()
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local cIdPort    := ""
   local cVersao    := ""

   default cIdMan    := ""
   default cVerMan   := ""
   default cMsgError := ""

   cIdPort := EK9->EK9_IDPORT
   cVersao := EK9->EK9_VATUAL

   if !empty(cIdPort) .and. !empty(cVersao) .and. (!(cIdPort == cIdMan) .or. !(cVersao == cVerMan))

      cAliasQry := getNextAlias()

      cQuery := " SELECT DISTINCT EE9.EE9_PREEMB "
      cQuery += " FROM " + RetSqlName('EE9') + " EE9 "
      cQuery += " WHERE EE9.D_E_L_E_T_ = ' ' "
      cQuery += " AND EE9.EE9_FILIAL = ? "
      cQuery += " AND EE9.EE9_IDPORT = ? "
      cQuery += " AND EE9.EE9_VATUAL = ? "
   
      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,xFilial('EE9'))
      oQuery:SetString(2,cIdPort)
      oQuery:SetString(3,cVersao)

      cQuery := oQuery:GetFixQuery()

      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
         lRet := .F.
         cMsgError := STR0119 // "Não é permitido a alteração dos campos ID Portal e Versão do catálogo de produto, pois está sendo utilizado no processo de Embarque."
      endif

      (cAliasQry)->(dbCloseArea())

      fwFreeObj(oQuery)

   endif

   restArea(aArea)

return lRet

/*
Função     : getJsonAtt
Objetivo   : Monta o json com todos os atributos do catálogo, tratados por Atributos, Atributos Multi Valorados e Atributos Compostos.
Parâmetro  : lEKI - Indica que existem atributos para o catálogo
Retorno    : Retorna json montado com os atributos.
Autor      : THTS - Tiago Tudisco
Data/Hora  : Fevereiro/2023
Obs.       :
*/
Static Function getJsonAtt(lEKI)
Local cAliasAtt   := GetNextAlias()
Local cJsonAtt    := "" //Montagem do Json a ser enviado com os atributos do catálogo (atributos)
Local cJsonAttMV  := "" //Montagem do Json a ser enviado com os atributos do catálogo "Multi Valorado" (atributosMultivalorados)
Local cJsonAttCP  := "" //Montagem do Json a ser enviado com os atributos do catálogo "Compostos" (atributosCompostos)
Local cJsonAttMC  := "" //Trata atributos Compostos e Multivalorados
Local lTemAtt     := .F. //Adiciona virgula para atributo
Local lTemMV      := .F. //Adiciona virgula para atributo MultiValorado
Local lTemCP      := .F. //Adiciona virgula para atributo composto
//Local lTemCPMV    := .F. //Adiciona virgula para atributo composto e Multivalorados
Local aAttCP      := {} //Controle de Atributos Compostos
Local aAuxMV      := {}
Local nAttCP
Local cAuxATT
Local nI

BeginSql Alias cAliasAtt
   SELECT 
      EKI_COD_I, 
      EKI_VERSAO, 
      EKI_CODATR, 
      EKG.EKG_MULTVA, 
      EKI_CONDTE, 
      EKG.EKG_FORMA,
      EKG_PAI.EKG_FORMA EKG_FORMA_PAI,
      EKI_VALOR
   FROM 
      %table:EKI% EKI 
      INNER JOIN %table:EK9% EK9 ON (
         EK9_FILIAL     = %xFilial:EK9%
         AND EK9_COD_I  = EKI_COD_I
      ) 
      INNER JOIN %table:EKG% EKG ON (
         EKG.EKG_FILIAL    = %xFilial:EKG%
         AND EKG.EKG_NCM   = EK9_NCM 
         AND EKG.EKG_COD_I = EKI_CODATR
      ) 
      LEFT OUTER JOIN %table:EKG% EKG_PAI ON (
         EKG_PAI.EKG_FILIAL      = %xFilial:EKG%
         AND EKG_PAI.EKG_NCM     = EK9_NCM 
         AND EKG_PAI.EKG_COD_I   = EKI_CONDTE 
         AND EKG_PAI.%NotDel%
      ) 
   WHERE 
      EKI_FILIAL     = %xFilial:EKI%
      AND EKI_COD_I  = %exp:EKD->EKD_COD_I%
      AND EKI_VERSAO = %exp:EKD->EKD_VERSAO%
      AND EKI.%NotDel%
      AND EK9.%NotDel%
      AND EKG.%NotDel%
   ORDER BY 
      EKI.EKI_FILIAL, 
      EKI.EKI_COD_I, 
      EKI.EKI_VERSAO, 
      EKI.EKI_CODATR, 
      EKI.EKI_CONDTE      
EndSql

if (cAliasAtt)->(!Eof())
   lEKI := .T.
   cJsonAtt    := ' "atributos": [ '
   cJsonAttMV  := ' "atributosMultivalorados": [ '
   cJsonAttCP  := ' "atributosCompostos": [ '
   cJsonAttMC  := ' "atributosCompostosMultivalorados": [ '
   while (cAliasAtt)->(!Eof())
      
      If !Empty((cAliasAtt)->EKI_CONDTE) .And. Alltrim((cAliasAtt)->EKG_FORMA_PAI) == ATT_COMPOSTO .And. (cAliasAtt)->EKG_MULTVA != "1" //Atributo Composto e não multivalorado

         lTemCP := .T.
         cAuxATT :=  '{' + ;
                        ' "atributo": "' + Alltrim((cAliasAtt)->EKI_CODATR)                           + '",' + ;
                        ' "valor": "'    + getFormVal((cAliasAtt)->EKG_FORMA, (cAliasAtt)->EKI_VALOR) + '" ' + ;
                     '}'
         If (nAttCP := aScan(aAttCP,{|X| X[1] == (cAliasAtt)->EKI_CONDTE})) > 0
            aAttCP[nAttCP][2] += "," + cAuxATT
         Else
            aAdd(aAttCP,{(cAliasAtt)->EKI_CONDTE, cAuxATT})
         EndIf

      ElseIf !Empty((cAliasAtt)->EKI_CONDTE) .And. Alltrim((cAliasAtt)->EKG_FORMA_PAI) == ATT_COMPOSTO .And. (cAliasAtt)->EKG_MULTVA == "1"  //Atributo Composto e multivalorado
         //lTemCPMV := .T.
         
      ElseIf (cAliasAtt)->EKG_MULTVA == "1"//Multivalorado = 1-Sim;
         if lTemMV
            cJsonAttMV += ','
         endif
         lTemMV := .T.
         
         cJsonAttMV +=  '{' + ;
                        ' "valores": [ '

         If Alltrim((cAliasAtt)->EKG_FORMA) == ATT_LISTA_ESTATICA
            aAuxMV := Strtokarr2((cAliasAtt)->EKI_VALOR, ';')
         ElseIf Alltrim((cAliasAtt)->EKG_FORMA) == ATT_TEXTO
            aAuxMV := Strtokarr2((cAliasAtt)->EKI_VALOR, chr(13)+chr(10))
         EndIf
         For nI := 1 To Len(aAuxMV)
            If nI > 1 
               cJsonAttMV += ","
            EndIf
            cJsonAttMV += '"' + aAuxMV[nI] + '"'
         Next
         cJsonAttMV += "],"
         cJsonAttMV +=  ' "atributo": "' + Alltrim((cAliasAtt)->EKI_CODATR) + '" '
         cJsonAttMV +=  '}'

      ElseIf ! empty((cAliasAtt)->EKI_VALOR)
         
         if lTemAtt
            cJsonAtt += ','
         endif
         lTemAtt := .T.

         cJsonAtt += '{' + ;
                        ' "atributo": "' + Alltrim((cAliasAtt)->EKI_CODATR)                           + '",' + ;
                        ' "valor": "'    + getFormVal((cAliasAtt)->EKG_FORMA, (cAliasAtt)->EKI_VALOR) + '" ' + ;
                     '}'
      endif
      (cAliasAtt)->(dbskip())
   enddo
   
   //Monta a lista de ATRIBUTOS
   cJsonAtt    += ']'

   //Monta a lista de atributos MULTI VALORADOS
   If lTemMV
      cJsonAttMV  += ']'
      cJsonAtt += ', ' + cJsonAttMV
   EndIf
   
   //Monta a lista de atributos COMPOSTOS
   If lTemCP
      For nI := 1 To Len(aAttCP)
         If nI > 1
            cJsonAttCP += ","
         EndIf
         cJsonAttCP += '{ "valores":[ '
         cJsonAttCP += aAttCP[nI][2]
         cJsonAttCP += ' ], "atributo": "' + Alltrim(aAttCP[nI][1]) + '" }'
      Next
      cJsonAttCP += ']'
      cJsonAtt += ', ' + cJsonAttCP
   EndIf
   
   //Monta atributos COMPOSTOS e MULTI VALORADOS
   //If lTemCPMV
      //cJsonAttMC  += ']'
   //EndIf

endif
(cAliasAtt)->(dbCloseArea())
Return cJsonAtt

Static Function getFormVal(cForma, cValor)
Local cRet

cForma := Alltrim(cForma)
cValor := Alltrim(strtran(cValor, chr(13)+chr(10), " "))
Do Case
   Case cForma == ATT_BOOLEANO
      If cValor == '1'
         cRet := "true"
      Else
         cRet := "false"
      EndIf
   Otherwise
      cRet := cValor
EndCase

Return cRet

/*
Função     : ValidAtr
Objetivo   : Valida os atributos vinculados a tabela de integração do catalogo de produto
Parâmetro  : cCodCatPrd- Código do catalogo de produto (EK9_COD_I)
             cVersao - Ultima versão do catalogo de produto (EKD_VERSAO)
Retorno    : Retorna .T. os atributos estão corretos, .F. os atributos obrigatórios estão vazio
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ValidAtr(cCodCatPrd, cVersao)
   local lRet       := .T.
   local aAreaEK9   := {}
   local oModelo    := nil
   local oModEKC    := nil
   local cAtributos := ""
   local aAtributos := {}
   local lBckAltera := ALTERA

   default cCodCatPrd := EKD->EKD_COD_I
   default cVersao    := EKD->EKD_VERSAO

   dbSelectArea("EK9")
   aAreaEK9 := EK9->(getArea())

   oModelo := FwLoadModel("EICCP400")
   oModelo:SetOperation(MODEL_OPERATION_UPDATE)
   lRet := oModelo:Activate()

   if lRet
      oModEKC := oModelo:getModel("EKCDETAIL")
      aAtributos := getAtrVazio( oModEKC, @cAtributos )

      if len(aAtributos) > 0
         lRet := .F.
         EasyHelp(STR0124,STR0002,STR0125 + ": " + cAtributos) // "Existem atributos que não foram preenchidos." ### "Favor preencher os atributos" ### "Atenção"
      endif
   endif

   ALTERA := lBckAltera
   oModelo:DeActivate()
   restArea(aAreaEK9)

return lRet

/*
Função     : getAtrVazio
Objetivo   : Retorna os atributos que estão vazio no modelo de dados, que são obrigatórios e vigentes
Parâmetro  : oModelEKC - Modelo de dados EKCDETAIL
             cAtributos - String com todos os atributos
Retorno    : aAtributos - Array com os atributos
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getAtrVazio( oModelEKC, cAtributos )
   local aAtributos := {}
   local nAtributos := 0

   default cAtributos := ""

   for nAtributos := 1 to oModelEKC:Length()
      oModelEKC:GoLine( nAtributos )
      if !oModelEKC:IsDeleted() .and. oModelEKC:GetValue("ATRIB_OBRIG") == "1" .and. empty(oModelEKC:GetValue("EKC_VALOR")) .and. alltrim(oModelEKC:GetValue("EKC_STATUS")) == "VIGENTE"
         aAdd( aAtributos , alltrim(oModelEKC:GetValue("EKC_CODATR")) )
      endif
   next

   if len(aAtributos) > 0
      aEval( aAtributos, { |X| cAtributos += X + ', '})
      cAtributos := substr( cAtributos, 1, len(cAtributos)-2)
   endif

return aAtributos

/*
Função     : setPedOper
Objetivo   : Seta o controle, onde será questionado se deseja integrar essas pendencias do catalogo de produto (fabricante)
             .F. - Não irá questionar se deseja realizar a integração dessas pendencias
             .T. - Irá questionar se deseja realizar a integração dessas pendencias
             Devido a rotina automatica, será iniciado como .F.
Parâmetro  : lPedOper
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function setPedOper(lPedOper)
   default lPedOper := .F.
   _lPedOper := lPedOper
return

/*
Função     : getPedOper
Objetivo   : Retorna o controle, onde será questionado se deseja integrar essas pendencias do catalogo de produto (fabricante)
             Devido a rotina automatica, será iniciado como .F.
Retorno    : Retorna .T. Irá questionar se deseja realizar a integração dessas pendencias, .F. Não irá questionar se deseja realizar a integração dessas pendencias
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getPedOper()
return _lPedOper

/*
Função     : CP400IntCat
Objetivo   : Função chamada no menu para Integrar o catalogo de produto
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function CP400IntCat()
   local cVersaoEKD := ""
   local aArea      := {}
   local aAreaEKD   := {}
   local cMsgStatus
   If EK9->EK9_STATUS == "5"  //Registrado Manualmente
      EasyHelp(STR0159,STR0002) //'Não é possível integrar um Catálogo de Produtos com o status "Registrado Manualmente".' ### "Atenção"
   Else
      aArea := if( !empty(alias()), getArea(), {})

      dbSelectArea("EKD")
      aAreaEKD := EKD->(getArea())
      cVersaoEKD := CPGetVersion(xFilial("EKD"),EK9->EK9_COD_I)
      EKD->(dbsetorder(1),DbSeek(xFilial("EKD")+EK9->EK9_COD_I + cVersaoEKD))
      if EKD->EKD_STATUS == "2" //Pendente Registro
         if ValidAtr(EKD->EKD_COD_I, EKD->EKD_VERSAO)
            CP400Integrar()
         endif
      else
         cMsgStatus := CP400CBSta("EKD_STATUS", EKD->EKD_STATUS)
         EasyHelp(STR0166, STR0002, STR0167 + IIF(!Empty(cMsgStatus),"( "+cMsgStatus+" )",""))//"Não foi possível efetuar a integração deste Catálogo de produtos."###"Atenção"####"""Verifique o status do último registro no Histórico de Integração do Catálogo de Produtos."
      endif
      restArea(aAreaEKD)

      if( len(aArea) > 0, restArea(aArea), nil)
   EndIf
return

/*
Função     : CP400GerCat
Objetivo   : Função chamada no menu para o facilitador de inclusão automaticamente de catálogo de produtos para os itens importados
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function CP400GerCat()
   local aArea      := {}
   local oFwSX1Util := nil
   local aPergunte  := {}
   local lProc      := .F.

   aArea := getArea()

   oFwSX1Util := FwSX1Util():New()
   oFwSX1Util:AddGroup("EICCP400")
   oFwSX1Util:SearchGroup()
   aPergunte := oFwSX1Util:GetGroup("EICCP400")

   lProc := if( len(aPergunte) > 0 .and. len(aPergunte[2]) > 0, .T., (EasyHelp(STR0127, STR0002, STR0128 ),.F.)) // "Funcionalidade não disponível para esta versão do sistema." #### "Atenção" #### "A funcionalidade estará disponível a partir do próximo release ou através do pacote de Expedição Contínua. Acompanhe a página de publicações em Documentos de Referência - Comércio Exterior (TDN)."

   if lProc
      ViewWizard()
   endif

   RestArea(aArea)

   FwFreeArray(aPergunte)
   FwFreeObj(oFwSX1Util)
   aPergunte := nil

return

/*
Função     : ViewWizard
Objetivo   : Função do wizard para inclusão automática do catalogo de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewWizard()
   local aCoords    := {}
   local oStepWiz   := nil
   local oStep1     := nil
   local oStep2     := nil
   local oStep3     := nil
   local aPergCP400 := {}
   local cAliasSB1  := CP400_PROD
   local cFieldMark := "REG_MARCA"
   local cMarcaSB1  := "X"

   aCoords := FWGetDialogSize()
   oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
   oStepWiz:ActiveUISteps()

   oStep1 := oStepWiz:AddStep("1", { |oPanel| ViewIntrod( oPanel )  })
   oStep1:SetStepDescription(STR0129) // "Introdução"
   oStep1:SetNextTitle(STR0130) // "Avançar"
   oStep1:SetNextAction( { || .T. } )
   oStep1:SetCancelAction({|| MsgYesNo(STR0131, STR0132) }) // "Deseja cancelar a geração de catálogo de produto?" ### "Geração de Catálogo de Produto"

   oStep2 := oStepWiz:AddStep("2", {|oPanel| getFiltro( oPanel, @aPergCP400 )})
   oStep2:SetStepDescription(STR0133) // "Opções de filtro"
   oStep2:SetPrevTitle(STR0134) // "Voltar"
   oStep2:SetNextTitle(STR0130) // "Avançar"
   oStep2:SetNextAction({|| VldNext(cAliasSB1, cFieldMark, cMarcaSB1, @aPergCP400) })
   oStep2:SetCancelAction({|| MsgYesNo(STR0131, STR0132) }) // "Deseja cancelar a geração de catálogo de produto?" ### "Geração de Catálogo de Produto"

   oStep3 := oStepWiz:AddStep("3", {|oPanel| ViewResul( oPanel, cAliasSB1, cFieldMark)})
   oStep3:SetStepDescription(STR0135) // "Resultado"
   oStep3:SetNextTitle(STR0136) // "Fechar"
   oStep3:SetNextAction({|| .T. })
   oStep3:SetCancelWhen({|| .F. })
   oStep3:SetPrevWhen({|| .F. })
   oStepWiz:Activate()
   oStepWiz:Destroy()

   // deleta os arquivos temporarios, tem que ser após devido para evitar errorlog ao destruir os objetos
   eraseTmp()

   FwFreeObj( oStepWiz )

return

/*
Função     : ViewIntrod
Objetivo   : Função apresentar a introdução do wizard
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewIntrod(oPanel)
   local aCoords    := {}
   local cIntrod    := "" 
   local oSay       := nil
   local oFont      := nil

   aCoords := FWGetDialogSize(oPanel)
   cIntrod := STR0137 // "Esta rotina tem como objetivo verificar os itens importados que não possuem Catálogo de Produtos e sugerir a sua criação, tendo como referência a existência de um Purchase Order ao qual o produto esteja vinculado."
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return

/*
Função     : getFiltro
Objetivo   : Função para apresentar o pergunte que é utilizado para o filtro de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getFiltro(oPanel, aPergCP400)
   default aPergCP400 := {}
   Pergunte('EICCP400',.T.,,,oPanel,,@aPergCP400)
return

/*
Função     : VldNext
Objetivo   : Função para validar os proximos passos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function VldNext(cAliasSB1, cFieldMark, cMarcaSB1, aPergCP400)
   local lRet       := .F.
   local cPOIni     := ""
   local cPOFim     := ""
   local dDtPOIni   := ctod("")
   local dDtPOFim   := ctod("")
   local cProdIni   := ""
   local cProdFim   := ""
   local cNCMIni    := ""
   local cNCMFim    := ""
   local cEXNCMIni  := ""
   local cEXNCMFim  := ""

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"
   default aPergCP400 := {}

   __SaveParam('EICCP400', aPergCP400)
   pergunte("EICCP400", .F.)
   cPOIni     := MV_PAR01
   cPOFim     := MV_PAR02
   dDtPOIni   := MV_PAR03
   dDtPOFim   := MV_PAR04
   cProdIni   := MV_PAR05
   cProdFim   := MV_PAR06
   cNCMIni    := MV_PAR07
   cNCMFim    := MV_PAR08
   cEXNCMIni  := MV_PAR09
   cEXNCMFim  := MV_PAR10

   begin sequence

   if empty(MV_PAR06)
      MsgInfo(STR0138, STR0002 ) // "Informe o intervalo de produtos para realizar o filtro." #### "Atenção"
      break
   endif

   lRet := getProds(cAliasSB1, cFieldMark, cMarcaSB1, cPOIni, cPOFim, dDtPOIni, dDtPOFim, cProdIni, cProdFim, cNCMIni, cNCMFim, cEXNCMIni, cEXNCMFim)
   if !lRet
      MsgInfo(STR0139, STR0002 ) // "Não foi encontrado nenhum produto." #### "Atenção"
   else
      lRet := ViewProds(cAliasSB1, cFieldMark, cMarcaSB1)
   endif

   end sequence

return lRet

/*
Função     : getProds
Objetivo   : Função para realizar a query, de acordo com os parametros (Pergunte - EICCP400)
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getProds(cAliasSB1, cFieldMark, cMarcaSB1, cPOIni, cPOFim, dDtPOIni, dDtPOFim, cProdIni, cProdFim, cNCMIni, cNCMFim, cEXNCMIni, cEXNCMFim)
   local lRet       := .F.
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil
   local aFilInfos  := {}
   local nFil       := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"
   default cPOIni     := ""
   default cPOFim     := ""
   default dDtPOIni   := ctod("")
   default dDtPOFim   := ctod("")
   default cProdIni   := ""
   default cProdFim   := ""
   default cNCMIni    := ""
   default cNCMFim    := ""
   default cEXNCMIni  := ""
   default cEXNCMFim  := ""

   cAliasQry := getNextAlias()

   // ao confirmar a parametrização, o sistema deverá verificar em todos os Purchases Orders emitidos no período (data do PO) os produtos que não possuem catálogo de produtos (relação de produtos) e que se enquadram na parametrização informada; 
   // os produtos que estão bloqueados no cadastro (SB1) devem ser desconsiderados;
   cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.R_E_C_N_O_ RECSB1, SW2.W2_IMPORT "
   cQuery += " FROM " + RetSqlName('SW3') + " SW3 "
   cQuery += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SW3.W3_COD_I AND SB1.B1_MSBLQL <> '1' "
   cQuery += " INNER JOIN " + RetSqlName('SW2') + " SW2 ON SW2.D_E_L_E_T_ = ' ' AND SW2.W2_FILIAL = '" + xFilial("SW2") + "' AND SW2.W2_PO_NUM = SW3.W3_PO_NUM "
   cQuery += " LEFT JOIN " + RetSqlName('EKA') + " EKA ON EKA.D_E_L_E_T_ = ' ' AND EKA.EKA_FILIAL = '" + xFilial("EKA") + "' AND EKA_PRDREF = SW3.W3_COD_I "
   cQuery += " WHERE SW3.D_E_L_E_T_ = ' ' AND EKA.EKA_COD_I IS NULL "

   aFilInfos := {} 
   aAdd( aFilInfos , xFilial('SW3'))
   cQuery += " AND SW3.W3_FILIAL = ? "

   if cProdIni == cProdFim
      aAdd( aFilInfos , cProdIni)
      cQuery += " AND SW3.W3_COD_I = ? "
   else
      aAdd( aFilInfos , cProdIni)
      aAdd( aFilInfos , cProdFim)
      cQuery += " AND SW3.W3_COD_I >= ? "
      cQuery += " AND SW3.W3_COD_I <= ? "
   endif

   if !empty(cPOIni) .or. !empty(cPOFim)
      if cPOIni == cPOFim
         aAdd( aFilInfos , cPOIni)
         cQuery += " AND SW3.W3_PO_NUM = ? "
      else
         aAdd( aFilInfos , cPOIni)
         aAdd( aFilInfos , cPOFim)
         cQuery += " AND SW3.W3_PO_NUM >= ? "
         cQuery += " AND SW3.W3_PO_NUM <= ? "
      endif
   endif

   if !empty(dDtPOIni) .or. !empty(dDtPOFim)
      if dDtPOIni == dDtPOFim
         aAdd( aFilInfos , dDtPOIni)
         cQuery += " AND SW2.W2_PO_DT   = ? "
      else
         aAdd( aFilInfos , dDtPOIni)
         aAdd( aFilInfos , dDtPOFim)
         cQuery += " AND SW2.W2_PO_DT >= ? "
         cQuery += " AND SW2.W2_PO_DT <= ? "
      endif
   endif

   if !empty(cNCMIni) .or. !empty(cNCMFim)
      if cNCMIni == cNCMFim
         aAdd( aFilInfos , cNCMIni)
         cQuery += " AND SW3.W3_TEC = ? "
      else
         aAdd( aFilInfos , cNCMIni)
         aAdd( aFilInfos , cNCMFim)
         cQuery += " AND SW3.W3_TEC >= ? "
         cQuery += " AND SW3.W3_TEC <= ? "
      endif
   endif

   if !empty(cEXNCMIni) .or. !empty(cEXNCMFim)
      if cEXNCMIni == cEXNCMFim
         aAdd( aFilInfos , cEXNCMIni)
         cQuery += " AND SW3.W3_EX_NCM = ? "
      else
         aAdd( aFilInfos , cEXNCMIni)
         aAdd( aFilInfos , cEXNCMFim)
         cQuery += " AND SW3.W3_EX_NCM >= ? "
         cQuery += " AND SW3.W3_EX_NCM <= ? "
      endif
   endif

   cQuery += " GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.R_E_C_N_O_, SW2.W2_IMPORT "
   cQuery += " ORDER BY SB1.B1_COD "

   oQuery := FWPreparedStatement():New(cQuery)
   for nFil := 1 to len(aFilInfos)
      if valtype(aFilInfos[nFil]) == "D"
         oQuery:SetDate( nFil , aFilInfos[nFil] )
      else
         oQuery:SetString( nFil , aFilInfos[nFil] )
      endif
   next
   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasQry)
 
   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof())
      lRet := .T.
      LoadProd(cAliasQry, cAliasSB1, cFieldMark, cMarcaSB1)
   endif

   if !empty(cAliasQry) .and. select(cAliasQry) > 0
      (cAliasQry)->(dbCloseArea())
   endif

   fwFreeObj(oQuery)

return lRet

/*
Função     : LoadProd
Objetivo   : Função para carregar os produtos do resultado da query no arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function LoadProd(cAliasQry, cAliasSB1, cFieldMark, cMarcaSB1)
   local aStruct    := {}
   local nCpo       := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"

   clearTmp(cAliasSB1)
   aStruct := (cAliasSB1)->(dbStruct())

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())

      reclock(cAliasSB1, .T.)
      for nCpo := 1 To Len(aStruct)
         if aStruct[nCpo][1] == cFieldMark
            (cAliasSB1)->&(cFieldMark) := cMarcaSB1
         elseif aStruct[nCpo][1] == "RESULTADO"
            (cAliasSB1)->&(aStruct[nCpo][1]) := "0"
         elseif !(aStruct[nCpo][1] $ "RECNO||RETORNO")
            (cAliasSB1)->&(aStruct[nCpo][1]) := (cAliasQry)->&(aStruct[nCpo][1])
         endif
      next nCpo
      (cAliasSB1)->(MsUnlock())

      (cAliasQry)->(dbSkip())
   end

   (cAliasSB1)->(dbGoTop())

return

/*
Função     : createTmp
Objetivo   : Função para criação do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function createTmp()
   local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
   local cAliasTmp  := ""
   local cFieldMark := ""
   local aSemSX3    := {}
   local cArqTab    := ""
   local cIndExt    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   // ---- Criação da tabela temporaria para a funcionalidade Gerar Catalogo de Produtos
   cAliasTmp := CP400_PROD
   if Select(cAliasTmp) == 0
      cFieldMark := "REG_MARCA"
      aCampos := {}
      aSemSX3 := {}

      aAdd(aSemSX3, {"B1_COD"    , getSX3Cache( "B1_COD"   , "X3_TIPO"), getSX3Cache( "B1_COD"   , "X3_TAMANHO"), getSX3Cache( "B1_COD"   , "X3_DECIMAL") })
      aAdd(aSemSX3, {"B1_DESC"   , getSX3Cache( "B1_DESC"  , "X3_TIPO"), getSX3Cache( "B1_DESC"  , "X3_TAMANHO"), getSX3Cache( "B1_DESC"  , "X3_DECIMAL") })
      aAdd(aSemSX3, {"B1_POSIPI" , getSX3Cache( "B1_POSIPI", "X3_TIPO"), getSX3Cache( "B1_POSIPI", "X3_TAMANHO"), getSX3Cache( "B1_POSIPI", "X3_DECIMAL") })
      aAdd(aSemSX3, {"B1_EX_NCM" , getSX3Cache( "B1_EX_NCM", "X3_TIPO"), getSX3Cache( "B1_EX_NCM", "X3_TAMANHO"), getSX3Cache( "B1_EX_NCM", "X3_DECIMAL") })
      aAdd(aSemSX3, {"W2_IMPORT" , getSX3Cache( "W2_IMPORT", "X3_TIPO"), getSX3Cache( "W2_IMPORT", "X3_TAMANHO"), getSX3Cache( "W2_IMPORT", "X3_DECIMAL") })
      aAdd(aSemSX3, {"RESULTADO" , "C"                                 , 01                                     , 0                                       })
      aAdd(aSemSX3, {"RETORNO"   , "M"                                 , 250                                    , 0                                       })
      aAdd(aSemSX3, {"RECNO"     , "N"                                 , 10                                     , 0                                       })
      aAdd(aSemSX3, {"RECSB1"    , "N"                                 , 10                                     , 0                                       })
      aAdd(aSemSX3, {cFieldMark  , "C"                                 , 01                                     , 0                                       })

      cArqTab := e_criatrab(, aSemSX3, cAliasTmp )

      cIndExt := TEOrdBagExt()
      E_IndRegua( cAliasTmp , cArqTab+cIndExt, "B1_COD")

      cIndex1 := e_create()
      E_IndRegua( cAliasTmp , cIndex1+cIndExt, cFieldMark)

      SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt)

      aAdd( _aTabsTmp, {cAliasTmp, cArqTab, cIndex1, cIndex2 })
   endif
   // ------------------------------------------------------------------------

   if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

return

/*
Função     : eraseTmp
Objetivo   : Função para exclusão do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function eraseTmp()
   local nTab       := 0
   local cAliasTmp  := ""
   local cTabArq    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   for nTab := 1 to len(_aTabsTmp)
      cAliasTmp := _aTabsTmp[nTab][ALIAS_TEMP]
      cTabArq := _aTabsTmp[nTab][ARQ_TAB]
      cIndex1 := if(empty(_aTabsTmp[nTab][INDEX1]),nil,_aTabsTmp[nTab][INDEX1])
      cIndex2 := if(empty(_aTabsTmp[nTab][INDEX2]),nil,_aTabsTmp[nTab][INDEX2])
      if select(cAliasTmp) > 0
         (cAliasTmp)->(E_EraseArq(cTabArq, cIndex1, cIndex2))
      endif
   next

   aSize(_aTabsTmp, 0)
   _aTabsTmp := {}

return

/*
Função     : clearTmp
Objetivo   : Função limpeza do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function clearTmp(cAliasTmp)
   default cAliasTmp := ""

   if( !empty(cAliasTmp), if( select(cAliasTmp)  > 0, AvZap(cAliasTmp), createTmp()), nil)

return

/*
Função     : ViewProds
Objetivo   : Função para apresentar o FwMarkBrowse com os produtos para geração do catálogo de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewProds(cAliasSB1, cFieldMark, cMarcaSB1)
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}
   local bMarcar    := { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1 ), oMrkBrSB1:oBrowse:Refresh() }
   local oMrkBrSB1  := nil
   local oDlgProd   := nil
   local nOpc       := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"

   aRotina := {} 

   aStruct := (cAliasSB1)->(dbStruct())
   for nCpo := 1 To Len(aStruct)
      if !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO||RECSB1||RESULTADO||RETORNO"))
         aAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
         aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
         aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
         aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
         aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
      endif
   next nCpo 

   fwFreeObj(oDlgProd)
   oDlgProd := FWDialogModal():New()
   oDlgProd:setEscClose(.F.)
   oDlgProd:enableAllClient()
   oDlgProd:setTitle( OemTOAnsi(STR0140) ) // "Geração em lote de catalogo de produtos"
   oDlgProd:enableFormBar(.F.)
   oDlgProd:SetCloseButton( .F. )
   oDlgProd:createDialog()

   fwFreeObj(oMrkBrSB1)
   oMrkBrSB1 := FWMarkBrowse():New()
   oMrkBrSB1:SetFieldMark( cFieldMark )
   oMrkBrSB1:SetOwner( oDlgProd:getPanelMain() )
   oMrkBrSB1:SetAlias( cAliasSB1 )
   oMrkBrSB1:SetAllMark( bMarcar )
   oMrkBrSB1:SetMark( cMarcaSB1, cAliasSB1, cFieldMark )
   oMrkBrSB1:SetColumns( aColumns )
   oMrkBrSB1:SetMenuDef("")
   oMrkBrSB1:SetTemporary(.T.)
   oMrkBrSB1:DisableFilter()
   oMrkBrSB1:DisableConfig()
   oMrkBrSB1:DisableReport()
   oMrkBrSB1:DisableDetails()
   oMrkBrSB1:AddButton( OemTOAnsi(STR0141), { || if( validPrds(cAliasSB1, cFieldMark, cMarcaSB1) , (nOpc := 1 , oDlgProd:DeActivate()), )},, 2 ) // "Confirmar"
   oMrkBrSB1:AddButton( OemTOAnsi(STR0142), { || if( MsgYesNo(STR0145,STR0132), oDlgProd:DeActivate(),)},, 2 ) // "Cancelar" #### "Deseja cancelar a operação?" ### "Geração de Catálogo de Produto"
   oMrkBrSB1:AddButton( OemTOAnsi(STR0143), { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1, "M" ), oMrkBrSB1:oBrowse:Refresh()},, 2 ) // "Marcar todos"
   oMrkBrSB1:AddButton( OemTOAnsi(STR0144), { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1, "D" ), oMrkBrSB1:oBrowse:Refresh()},, 2 ) // "Desmarcar todos"
   oMrkBrSB1:Activate()

   oDlgProd:Activate()

   lRet := nOpc == 1

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return lRet

/*
Função     : MarcarProd
Objetivo   : Função para marcar os produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function MarcarProd(cAliasSB1, cFieldMark, cMarcaSB1, cOpc )
   local cMarca     := ""
   local lMarcados  := .T.
   local nPosSB1    := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"
   default cOpc       := ""

   nPosSB1 := (cAliasSB1)->(recno())

   if empty(cOpc)
      (cAliasSB1)->(dbGoTop())
      while (cAliasSB1)->(!eof())
         lMarcados := !empty((cAliasSB1)->&(cFieldMark))
         if !lMarcados
            exit
         endif
         (cAliasSB1)->(dbSkip())
      end
   endif

   cMarca := if( empty(cOpc), if( lMarcados, " ", cMarcaSB1), if(cOpc=="M", cMarcaSB1, " "))

   (cAliasSB1)->(dbGoTop())
   while (cAliasSB1)->(!eof())
      reclock(cAliasSB1,.F.)
      (cAliasSB1)->&(cFieldMark) := cMarca
      (cAliasSB1)->(msUnLock())
      (cAliasSB1)->(dbSkip())
   end

   (cAliasSB1)->(dbGoTo(nPosSB1))

return .T.

/*
Função     : validPrds
Objetivo   : Função para validar ao confirmar a tela de marcação de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function validPrds(cAliasSB1, cFieldMark, cMarcaSB1)
   local lRet       := .F.
   local aArea      := {}

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"

   aArea := (cAliasSB1)->(getArea())
      (cAliasSB1)->(dbSetOrder(2))
      lRet := (cAliasSB1)->(dbSeek(cMarcaSB1))
   RestArea(aArea)

   if !lRet
      MsgInfo(STR0146, STR0002 ) // "Marque ao menos um produto para criação do catálogo de produto." #### "Atenção"
   else
      lRet := MsgYesNo(STR0147, STR0132) // "Deseja processar a inclusão dos catálogos de produtos?" #### "Geração de Catálogo de Produto"
   endif

return lRet

/*
Função     : ViewResul
Objetivo   : Função para o resultado final do processamento
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewResul(oPanel, cAliasSB1, cFieldMark)
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local oResult    := nil
   local oProc      := nil
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"

   (cAliasSB1)->(dbGoTop())

   aRotina := {}
   aStruct := (cAliasSB1)->(dbStruct())
   for nCpo := 1 To Len(aStruct)
      if !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO||RECSB1||RESULTADO"))
         aAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
         aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
         aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
         if aStruct[nCpo][1] == "RETORNO"
            aColumns[Len(aColumns)]:SetTitle("Mensagem")
         else            
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
         endif
      endif
   next nCpo 

   fwFreeObj(oResult)
   aRotina := {}
   oResult := FWmBrowse():New()
   oResult:SetProfileID( 'RESULTADO' )
   oResult:SetDataTable()
   oResult:SetOwner( oPanel )
   oResult:SetAlias( cAliasSB1 )
   oResult:AddLegend("RESULTADO == '0' ","BR_AMARELO",STR0148) // "Pendente de processamento"
   oResult:AddLegend("RESULTADO == '1' ","ENABLE",STR0149) // "Inclusão realizada com sucesso"
   oResult:AddLegend("RESULTADO == '2' ","DISABLE",STR0150) // "Falha na inclusão"
   oResult:SetColumns( aColumns )
   oResult:SetMenuDef( "" )
   oResult:SetFilterDefault(" " + cFieldMark + " <> ' ' ")
   oResult:DisableFilter()
   oResult:DisableConfig()
   oResult:DisableReport()
   oResult:DisableDetails()
   oResult:Activate()

   oProc := EasyProgress():New(.F.)
   oProc:SetProcess({|| PrcCatProd( cAliasSB1, cFieldMark, @oResult, @oProc )}, STR0151) // "Incluindo catálogo de produtos... "
   oProc:Init()  

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return

/*
Função     : PrcCatProd
Objetivo   : Função para realizar a chamada da função do execauto EICCP400
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function PrcCatProd(cAliasSB1, cFieldMark, oBrowse, oProc)
   local cCodChave  := ""
   local cMsgError  := ""
   local nQtdInt    := 0
   local nRecno     := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"

   nQtdInt := EasyQryCount("SELECT B1_COD FROM " + TETempName(cAliasSB1) + " WHERE D_E_L_E_T_= ' ' AND " + cFieldMark + " <> ' ' " )

   (cAliasSB1)->(dbGoTop())
   oProc:SetRegua(nQtdInt)
   while (cAliasSB1)->(!eof())
      nRecno := (cAliasSB1)->(recno())

      if !empty((cAliasSB1)->&(cFieldMark))
         cMsgError := ""

         cCodChave := incCatProd(@cMsgError, (cAliasSB1)->B1_COD, (cAliasSB1)->W2_IMPORT)
         reclock(cAliasSB1,.F.)
         if !empty(cCodChave)
            (cAliasSB1)->RESULTADO := "1"
            (cAliasSB1)->RETORNO := cCodChave
         else
            (cAliasSB1)->RESULTADO := "2"
            (cAliasSB1)->RETORNO := cMsgError
         endif
         (cAliasSB1)->(msUnLock())
         oProc:IncRegua()
         oBrowse:Refresh()
      endif

      (cAliasSB1)->(dbgoto(nRecno))
      (cAliasSB1)->(dbSkip())
   end

   oProc:Refresh()
   oBrowse:Refresh(.T.)
   (cAliasSB1)->(dbGoTop())

return .T.

/*
Função     : incCatProd
Objetivo   : Função que realiza a inclusão do catalogo de produto
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function incCatProd(cMsgError, cProduto, cImport)
   local cCodCat    := ""
   local oModelo    := nil
   local oModEK9    := nil
   local lOk        := .F.
   local xError     := nil

   default cMsgError := ""
   default cProduto  := ""
   default cImport   := ""

   cMsgError := STR0155 // "Falha ao carregar o modelo"
   oModelo := FwLoadModel("EICCP400")
   oModelo:SetOperation(MODEL_OPERATION_INSERT)
   if oModelo:Activate()

      cMsgError := ""
      oModEK9 := oModelo:getModel("EK9MASTER")
      lOk := oModEK9:setValue( "EK9_IMPORT", cImport)
      lOk := lOk .and. oModEK9:setValue( "EK9_PRDREF", cProduto)
      lOk := lOk .and. oModelo:VldData()
      lOk := lOk .and. oModelo:CommitData()
      cMsgError := if( !lOk ,;
         ( RollbackSx8(),;
            xError := oModelo:GetErrorMessage(), ;
            if( valtype(xError) == "C", alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 ,;
            STR0153 + ": " + alltrim(allToChar( xError[6])) + " - " + if( !empty(xError[7]) , STR0154 + ": " + alltrim(allToChar( xError[7] )), "") , "") );
         ),;
         "") // "Problema" ### "Solução"
      if lOk
         cCodCat := STR0152 + ": " + alltrim(oModEK9:getValue("EK9_COD_I")) // "Código chave gerado
      endif
      oModelo:deactivate()
   endif

   fwFreeObj(oModEK9)
   fwFreeObj(oModelo)

return cCodCat

/*
Função     : isExecAuto
Objetivo   : Função que indica se é execauto
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function isExecAuto(oView)
   local lRet := .F.
   default oView := FwViewActive()
   lRet := FwIsInCallStack("incCatProd") .or. oView == nil
return lRet

/*
Função     : CP400CBox
Objetivo   : Função chamada no X3_CBOX dos campos EK9_STATUS/ EKD_STATUS
Retorno    : Retorna a lista de Status.
Autor      : Tiago Tudisco
Data/Hora  : Março/2023
Obs.       :
*/
Function CP400CBox(cCampo)
Local cRet  := ""

Default cCampo:= Alltrim(ReadVar())
Do Case
   Case cCampo == "EK9_STATUS"
      cRet := STR0160//"1=Registrado;2=Pendente Registro;3=Pendente Retificação;4=Bloqueado;5=Registrado Manualmente"
   Case cCampo == "EKD_STATUS"
      cRet := STR0161//"1=Registrado;2=Pendente Registro;3=Obsoleto;4=Falha de integração;5=Registrado(pendente: fabricante/ país);6=Registrado Manualmente"
EndCase

Return cRet

/*/{Protheus.doc} CP400CBSta
   @type  Function
   @author Tiago Tudisco
   @since 19/04/2023
   @version v001
   @param cCampo - Campo a ser verificado; cStatus - Número do Status no combobox
   @return Retorna a descrição contida no combobox
   /*/
Function CP400CBSta(cCampo, cStatus)
Local cRet := ""
Local aStatus
Local nPos
Local cTexto

aStatus := StrTokarr(CP400CBox(cCampo),";")
If (nPos := aScan(aStatus,{|x| Substr(x, 1, at("=", x)-1) == cStatus})) > 0
   cTexto := aStatus[nPos]
   cRet := Substr(cTexto, at("=", cTexto) + 1)
EndIf

Return Alltrim(cRet)