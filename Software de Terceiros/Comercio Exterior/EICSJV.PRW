#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJV.CH"

/*
Programa   : EICSJV
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08 
Obs.       : Criado com gerador autom�tico de fontes
Revis�o    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC  
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:08  
Revis�o    : Clayton Fernandes - 29/03/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/ 

Static Function MenuDef() 
Local aRotina := {}                       

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.EICSJV" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.EICSJV" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.EICSJV" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.EICSJV" OPERATION 5 ACCESS 0

Return aRotina  


Function MVC_EICSJV()
Local oBrowse                                             

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJV") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICSJV") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Natureza Operacao
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJV := FWFormStruct( 1, "SJV") //Monta a estrutura da tabela SJV
//Local bCommit  := {|oMdl| EasyMVCGrava(oMdl,"SJV")}                                                 


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP006', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJV
oModel:AddFields( 'EICP006_SJV',/*nOwner*/,oStruSJV, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Natureza Operacao

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  

//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICSJV")

// Cria a estrutura a ser usada na View
Local oStruSJV:=FWFormStruct(2,"SJV")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP006_SJV', oStruSJV)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP006_SJV') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 
