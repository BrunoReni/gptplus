#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "EICUR100.CH"

/*
Programa   : EICUR100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
Obs.       : Criado com gerador autom�tico de fontes 
Revis�O    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08  
Revis�O    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/ 
Static Function MenuDef() 
Local aRotina := {}

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICUR100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICUR100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICUR100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICUR100" OPERATION 5 ACCESS 0

Return aRotina  
   


Function MVC_EICUR100()
Local oBrowse                                             

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJ0") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICUR100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//U R F's
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJ0 := FWFormStruct( 1, "SJ0") //Monta a estrutura da tabela SJ0
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SJ0")}                                                 


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP003', /*bPreValidacao*/, /*bPosValidacao*/,/* bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJ0
oModel:AddFields( 'EICP003_SJ0',/*nOwner*/,oStruSJ0, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//U R F's

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
             
  
  
  
  
Return oModel

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICUR100")

// Cria a estrutura a ser usada na View
Local oStruSJ0:=FWFormStruct(2,"SJ0")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP003_SJ0', oStruSJ0)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP003_SJ0') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
