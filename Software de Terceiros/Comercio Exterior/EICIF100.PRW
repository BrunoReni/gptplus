#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICIF100.CH"
/*
Programa   : EICIF100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
Obs.       : Criado com gerador autom�tico de fontes 
Revis�o    : Clayton Fernandes - 05/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
Revis�o    : Clayton Fernandes - 05/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 


Static Function MenuDef() 
Local aRotina := {}                       

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICIF100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICIF100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICIF100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICIF100" OPERATION 5 ACCESS 0

Return aRotina  
                                      
                      
Function MVC_IF100EIC()                
Local oBrowse                                             
                                      
//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJ7") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICIF100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Inst.financiadoras
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJ7 := FWFormStruct( 1, "SJ7") //Monta a estrutura da tabela SJO
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SJ8")}                                                 


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP023', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP023_SJ7',/*nOwner*/,oStruSJ7, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Inst.financiadoras

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  
                                                               
//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICIF100")

// Cria a estrutura a ser usada na View
Local oStruSJ7:=FWFormStruct(2,"SJ7")                        

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP023_SJ7', oStruSJ7)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP023_SJ7') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 