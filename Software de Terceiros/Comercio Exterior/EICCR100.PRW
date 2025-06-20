#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICCR100.CH"
/*
Programa   : EICCR100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Clayton Fernandes
Data/Hora  : 04/04/2011 11:46:08 
Obs.       : Criado com gerador autom�tico de fontes 
Revis�o    : Clayton Fernandes - 04/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Clayton Fernandes
Data/Hora  : 04/04/2011 11:46:08 
Revis�o    : Clayton Fernandes - 04/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 


Static Function MenuDef() 
Local aRotina := {}                       

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICCR100" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICCR100" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICCR100" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICCR100" OPERATION 5 ACCESS 0

Return aRotina  
                                      
                      
Function MVC_RC100EIC()                
Local oBrowse                                             
                                      
//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SYW") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICCR100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Corretoras
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSYW := FWFormStruct( 1, "SYW") //Monta a estrutura da tabela SJO


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP024', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP024_SYW',/*nOwner*/,oStruSYW, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Corretoras

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  
                                                               
//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICCR100")

// Cria a estrutura a ser usada na View
Local oStruSYW:=FWFormStruct(2,"SYW")                        

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP024_SYW', oStruSYW)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP024_SYW') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 