// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIStrCustom - Contem strings personalizadas pelo usuário
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 04.05.10 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "KPIDefs.ch"
#include "KPIStrCustom.ch"

#define TAG_ENTITY "KPISTRCUSTOM"

class TKPIStrCustom from TBITable
	data m_sco
	data m_real
	data m_meta
	data m_previa
	data m_tend

	method New() constructor

	method getStrSco()
	method getStrReal()
	method getStrMeta()
	method getStrPrevia() 
	method getStrTend() 
	method doRefresh()
	
endclass
 

method New() class TKPIStrCustom
	::NewObject()   
	::m_sco		:= ""
	::m_real	:= ""
	::m_meta	:= ""
	::m_previa	:= ""
	::m_tend	:= ""
return


method doRefresh() class TKPIStrCustom
	local oParametro := ::oOwner():oGetTable("PARAMETRO")

	::m_sco		:= oParametro:getValue("STR_SCO")
	::m_real	:= oParametro:getValue("STR_REAL")
	::m_meta	:= oParametro:getValue("STR_META")
	::m_previa	:= oParametro:getValue("STR_PREVIA")
	::m_tend	:= oParametro:getValue("STR_TEND")	
return


method getStrSco(cEntity) class TKPIStrCustom
	local oParametro := ::oOwner():oGetTable("PARAMETRO")
	local cRet := ""

	default cEntity := ""

	if empty(::m_sco)
		::doRefresh()
	endif

	if oParametro:getValue("MODO_ANALISE") == ANALISE_BSC
		do case
			case cEntity == CAD_SCORECARD
				cRet := ::m_sco

			case cEntity == CAD_ORGANIZACAO
				cRet := STR0001 //###"Organização"

			case cEntity == CAD_ESTRATEGIA
				cRet := STR0002 //###"Estratégia"

			case cEntity == CAD_PERSPECTIVA
				cRet := STR0003 //###"Perspectiva"

			case cEntity == CAD_OBJETIVO
				cRet := STR0004 //###"Objetivo"

		endcase
	else
		cRet := ::m_sco
	endif

return cRet
              

method getStrReal() class TKPIStrCustom
	if ::m_real == ""
		::doRefresh()		
	endif           
return ::m_real
   

method getStrMeta() class TKPIStrCustom
	if ::m_meta == ""
		::doRefresh()		
	endif
return ::m_meta
          

method getStrPrevia() class TKPIStrCustom
	if ::m_previa == ""
		::doRefresh()		
	endif
return ::m_previa

//Recupera o texto informado no parâmetro
method getStrTend() class TKPIStrCustom
	if ::m_tend == ""
		::doRefresh()		
	endif
return ::m_tend

