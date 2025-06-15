// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI004a_Msg.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.11.04 | 1645 Leandro Marcelino Santos
// 05.01.06 | 1776 Adaptado para uso no KPI - Alexandre Silva
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI004a_Msg.ch"

/*--------------------------------------------------------------------------------------
@entity Mensagens
Mensagens no KPI. Contém mensagens recebidas dos usuários do KPI.
@table KPI004
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DESTINATARIO"
#define TAG_GROUP  "DESTINATARIOS"
#define TEXT_ENTITY STR0001/*//"Mensagem"*/
#define TEXT_GROUP  STR0002/*//"Mensagens"*/

class TKPI004A from TBITable
	method New() constructor
	method NewKPI004A()

	// diversos registros
	method oToXMLList(nParentID)

endclass
	
method New() class TKPI004A
	::NewKPI004A()
return
method NewKPI004A() class TKPI004A

	// Table
	::NewTable("SGI004A")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"C",15))
	::addField(TBIField():New("PARENTID",	"C",15))//Referencia a mensagem.
	::addField(TBIField():New("PESSID",	"C",10))
	::addField(TBIField():New("PARACC",	"N")) // 1.Para 2.CC
	::addField(TBIField():New("REMETENTE",	"N")) // 1.Remetente 2.Destinatário
	::addField(TBIField():New("SITUACAO",	"N")) // 1.Lida 2.Não Lida
	::addField(TBIField():New("PASTA",		"N")) // 2.Entrada 3.Excluido 4.Excluido Definitivamente
	
	// Indexes
	::addIndex(TBIIndex():New("SGI004AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI004AI02",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("SGI004AI03",	{"PARENTID", "REMETENTE"},	.f.))

return

function _KPI004a_Msg()
return nil