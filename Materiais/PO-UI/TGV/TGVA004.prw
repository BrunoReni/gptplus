#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TGVA004.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TGVA004
	Dummy Function - Defini��es de menus do Portal Gest�o de vendas
	@type		function
	@version	12.1.33
	@author		Danilo Salve / Squad CRM & Faturamento
	@since		28/12/2021
/*/
//-------------------------------------------------------------------
function TGVA004()
return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu de Cadastro do Portal Gest�o de Vendas
	@type       function
	@version    12.1.33
	@author     Danilo Salve / Squad CRM & Faturamento
	@since      21/12/2021
	@return     array, Lista de Rotinas do PGV.
/*/
//-------------------------------------------------------------------
static function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE OemToAnsi(STR0001)    ACTION 'TGVA004Mn'	OPERATION 1 ACCESS 0 // "Minhas Notifica��es"
	ADD OPTION aRotina TITLE OemToAnsi(STR0002)    ACTION 'TGVA004Mn'	OPERATION 2 ACCESS 0 // "Meus Clientes"
	ADD OPTION aRotina TITLE OemToAnsi(STR0003)    ACTION 'TGVA004Mn'	OPERATION 3 ACCESS 0 // "Minhas Vendas".
	ADD OPTION aRotina TITLE OemToAnsi(STR0004)    ACTION 'TGVA004Mn'	OPERATION 4 ACCESS 0 // "Meus Pedidos"
	ADD OPTION aRotina TITLE OemToAnsi(STR0005)    ACTION 'TGVA004Mn'	OPERATION 5 ACCESS 0 // "Meus Or�amentos"
return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} TGVA004Mn
	fun��o generica utilizada no MenuDEF
	@type		function
	@version	12.1.33
	@author		Danilo Salve / Squad CRM & Faturamento
	@since		22/12/2021
	/*/
//-------------------------------------------------------------------
static function TGVA004Mn()
	Alert(OemToAnsi(STR0006))
return nil
