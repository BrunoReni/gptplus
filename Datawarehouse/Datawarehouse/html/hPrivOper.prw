// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : TDWPrivOper - Define o objeto de opera��es b�sicas que o usu�rio poder� executar
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.02.06 |2481-Paulo R Vieira| Vers�o 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWPrivileges
Uso   : Define o objeto de privil�gios do usu�rio
--------------------------------------------------------------------------------------
*/
class TDWPrivOper from TDWObject
	
	data flInhDWAcess
	data flDWAcess
	data flInhCreat
	data flCreate
	data flInhMaint
	data flMaintenance
	data flInhAcess
	data flAcess
	data flInhExport
	data flExport
	
	method New() constructor
	method Free()
	method Clean()

	// privil�gio de cria��o herdado
	method CreateInherited(alValue)
	
	// cria��o
	method Create(alValue)
	
	// privil�gio de manuten��o herdado
	method MaintInherited(alValue)
	
	// manuten��o
	method Maintenance(alValue)
	
	// privil�gio de acesso herdado
	method AcessInherited(alValue)
	
	// acesso
	method Acess(alValue)

	// privil�gio de exporta��o herdado
	method ExportInherited(alValue)
	
	// exporta��o
	method Export(alValue)
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args:
--------------------------------------------------------------------------------------
*/
method New() class TDWPrivOper

	_Super:New()
	::Clean()
	
return

method Free() class TDWPrivOper
	
	::Clean()
	_Super:Free()

return

method Clean() class TDWPrivOper
	::flInhDWAcess	:= .F.
	::flDWAcess		:= .F.
    ::flInhCreat	:= .F.
	::flCreate		:= .F.
	::flInhAcess	:= .F.
	::flAcess		:= .F.
	::flInhMaint	:= .F.
	::flMaintenance	:= .F.
	::flInhExport	:= .F.
	::flExport		:= .F.
return

/*
--------------------------------------------------------------------------------------
Propriedade Create/cria��o herdada
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method CreateInherited(alValue) class TDWPrivOper
	property ::flInhCreat := alValue
return ::flInhCreat

/*
--------------------------------------------------------------------------------------
Propriedade Create/cria��o
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Create(alValue) class TDWPrivOper
	property ::flCreate := alValue
return ::flCreate

/*
--------------------------------------------------------------------------------------
Propriedade Maintenance/manuten��o herdada
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method MaintInherited(alValue) class TDWPrivOper
	property ::flInhMaint := alValue
return ::flInhMaint

/*
--------------------------------------------------------------------------------------
Propriedade Maintenance/manuten��o
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Maintenance(alValue) class TDWPrivOper
	property ::flMaintenance := alValue
return ::flMaintenance

/*
--------------------------------------------------------------------------------------
Propriedade Acess/acesso herdada
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method AcessInherited(alValue) class TDWPrivOper
	property ::flInhAcess := alValue
return ::flInhAcess

/*
--------------------------------------------------------------------------------------
Propriedade Acess/acesso
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Acess(alValue) class TDWPrivOper
	property ::flAcess := alValue
return ::flAcess

/*
--------------------------------------------------------------------------------------
Propriedade Export/Exporta��o herdada
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method ExportInherited(alValue) class TDWPrivOper
	property ::flInhExport := alValue
return ::flInhExport

/*
--------------------------------------------------------------------------------------
Propriedade Export/Exporta��o
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method Export(alValue) class TDWPrivOper
	property ::flExport := alValue
return ::flExport