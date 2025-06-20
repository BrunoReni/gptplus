#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJM.CH"
/*
Programa   : EICSJM
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
Obs.       : Criado com gerador autom�tico de fontes 
Revis�o    : Clayton Fernandes - 01/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09                     
Revis�o    : Clayton Fernandes - 01/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

Static Function MenuDef() 
Local aRotina := {}                       

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICSJM" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICSJM" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICSJM" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICSJM" OPERATION 5 ACCESS 0

Return aRotina  
                                           
                      
Function MVC_SJMEIC()
Local oBrowse                                             
                                      
//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJM") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICSJM") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Metodos Valoracao
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJM := FWFormStruct( 1, "SJM") //Monta a estrutura da tabela SJO
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SJM")}                                                 


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP013', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP013_SJM',/*nOwner*/,oStruSJM, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Metodos Valoracao

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  
                                                               
//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICSJM")

// Cria a estrutura a ser usada na View
Local oStruSJM:=FWFormStruct(2,"SJM")                        

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP013_SJM', oStruSJM)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP013_SJM') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 