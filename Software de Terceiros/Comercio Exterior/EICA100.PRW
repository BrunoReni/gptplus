#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICA100.CH"
/*
Programa   : EICA100
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o 
             definidas em um programa com o mesmo nome da fun��o. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:06 
Obs.       : Criado com gerador autom�tico de fontes 
Revis�o    : Clayton Fernandes - 06/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:06                     
Revis�o    : Clayton Fernandes - 06/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC 
*/ 

Static Function MenuDef() 
Local aRotina := {}                       

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//"Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.EICA100" OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.EICA100" OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.EICA100" OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.EICA100" OPERATION 5 ACCESS 0	//"Excluir"

Return aRotina  
                                      
                      
Function MVC_100AEIC()                                      
Local oBrowse                                             
                                      
//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SYA") //Informando o Alias  //FSY - 17/10/2013 - Ajuste para de SJA para SYA - Paises
oBrowse:SetMenuDef("EICA100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Paises
oBrowse:Activate()

Return 
 
//CRF 
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel  
Local oStruSYA := FWFormStruct( 1, "SYA") //Monta a estrutura da tabela SJO//FSY - 17/10/2013 - Ajuste para de SJA para SYA - Paises


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP026', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP026_SYA',/*nOwner*/,oStruSYA, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)//FSY - 17/10/2013 - Ajuste para de SJA para SYA - Paises    

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Paises

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})
  
  
Return oModel
  
                                                               
//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICA100")

// Cria a estrutura a ser usada na View
Local oStruSYA:=FWFormStruct(2,"SYA")   //FSY - 17/10/2013   - Ajuste para de SJA para SYA - Paises                   

Local oView  
 
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel ) 

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP026_SYA', oStruSYA)//FSY - 17/10/2013 - Ajuste para de SJA para SYA - Paises

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP026_SYA') //FSY - 17/10/2013 - Ajuste para de SJA para SYA - Paises

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView 