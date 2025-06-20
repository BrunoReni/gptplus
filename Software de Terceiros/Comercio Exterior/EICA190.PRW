#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICA190.CH"/*
/*
Programa   : EICA190
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em fun��es que n�o est�o
             definidas em um programa com o mesmo nome da fun��o.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:06
Obs.       : Criado com gerador autom�tico de fontes
Revis�o    : Clayton Fernandes - 04/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Chamada da fun��o MenuDef no programa onde a fun��o est� declarada.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:06
Revis�o    : Clayton Fernandes - 04/04/2011
Obs        : Adapta��o do Codigo para o padr�o MVC
*/
Static Function MenuDef()
Local aRotina := {}

//Adiciona os bot�es na MBROWSE
ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//"Pesquisar"
ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.EICA190" OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.EICA190" OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.EICA190" OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.EICA190" OPERATION 5 ACCESS 0	//"Excluir"

Return aRotina


Function MVC_EICA190()
Local oBrowse

//CRIA��O DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("SYJ") //Informando o Alias                                             `
oBrowse:SetMenuDef("EICA190") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001)//Incoterms
oBrowse:Activate()

Return

//CRF
*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruSYJ := FWFormStruct( 1, "SYJ") //Monta a estrutura da tabela SJO


/*Cria��o do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
  m�dulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( 'IMPP028', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

//Modelo para cria��o da antiga Enchoice com a estrutura da tabela SJO
oModel:AddFields( 'EICP028_SYJ',/*nOwner*/,oStruSYJ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)

//Adiciona a descri��o do Modelo de Dados
oModel:SetDescription(STR0001)//Incoterms

//Utiliza a chave primaria
oModel:SetPrimaryKey({''})


Return oModel


//CRF
*------------------------*
Static Function ViewDef()
*------------------------*

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel("EICA190")

// Cria a estrutura a ser usada na View
Local oStruSYJ:=FWFormStruct(2,"SYJ")

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('EICP028_SYJ', oStruSYJ)

//Relaciona a quebra com os objetos
oView:SetOwnerView( 'EICP028_SYJ')

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

