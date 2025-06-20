#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICSJK.CH"
/*
Programa   : EICSJK
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
Obs.       : Criado com gerador autom�tico de fontes 
*/ 

/*

Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:09 
*/ 
Static Function MenuDef()  
Local aRotina := {}

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"       OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.EICSJK" OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICSJK" OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICSJK" OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.EICSJK" OPERATION 5 ACCESS 0 //Excluir

Return aRotina

// CRF
Function EICSJK()
Local oBrowse                    

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SJK") //Informando o Alias
oBrowse:SetMenuDef("EICSJK") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) //Atributo Para N.v.e
oBrowse:Activate()

Return



//crf
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSJK := FWFormStruct( 1, "SJK") //Monta a estrutura da tabela SJK

//Adiciona a propriedade de valida��o no campo JK_ATRIB para que n�o haja inclus�o de valores j� existentes
oStruSJK:SetProperty('JK_ATRIB', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'ExistChav("SJK", M->JK_NCM+M->JK_ATRIB)' ) )

/*Cria��o do Modelo com o cID = "EXPP010", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'EICSJK', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJK
oModel:AddFields( 'SJKMASTER',/*nOwner*/,oStruSJK, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Atributo Para N.v.e

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})

Return oModel


//crf
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICSJK")

// Cria a estrutura a ser usada na View
Local oStruSJK:=FWFormStruct(2,"SJK")

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('SJKMASTER', oStruSJK)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'SJKMASTER') 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 