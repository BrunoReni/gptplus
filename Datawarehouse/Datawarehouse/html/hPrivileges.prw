// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : TDWPrivileges - Define o objeto de privil�gios do usu�rio
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
class TDWPrivileges from TDWObject

	data fnDwID
	data fnUserID
	data fnUserGroup
	data flUserIsAdm
	
	method New(anDwID, anUserID) constructor
	method Free()
	method Clean()

	// DW
	method DwID()

	// Usu�rio
	method UserID()
	
	// Grupo do usu�rio
	method UserGroup()

	// usu�rio � administrador
	method UserIsAdm()
	
	// carrega informa��es sobre o usu�rio
	method DoLoad()
	
	// verifica se o usu�rio t�m um grupo
	method UserHaveGroup()
	
	// checa um privil�gio gen�rico para este usu�rio
	method checkPrivilege(anObjID, acPriv, acOper)
	
	// checa o privil�gio de acesso ao DW
	method checkDwPrivileges(anDwID)
	
	// checa os privil�gios de um determinado cubo
	method checkCubePrivileges(anCubID)
	
	// checa o privil�gio de cria��o de consultas
	method checkCreateQuery()
	
	// checa os privil�gios de acesso de determinada consulta
	method checkQryAcessPrivileges(anQryID)
	
	// checa os privil�gios de manuten��o de determinada consulta
	method checkQryMaintPrivileges(anQryID)
	
	// checa os privil�gios de exportar uma determinada consulta
	method checkQryExportPrivileges(anQryID)
	
	// checa os privil�gios de uma determinada consulta
	method checkQueryPrivileges(anQryID, acOperType)
	
	// salva um privil�gio gen�rico para este usu�rio
	method SavePrivilege(anObjID, acPriv, acOper, acAuthoriz) 
	
	// salva privil�gios de DW para este usu�rio
	method SaveDwPrivileges(anDwID, aoNewPrivOper)
	
	// salva privil�gios de cria��o para este usu�rio
	method SaveCreatePrivileges(aoNewPrivOper)
	
	// salva os privil�gios de uma consulta para este usu�rio
	method SaveQueryPrivileges(anQueryID, aoNewPrivOper)
	
	// salva os privil�gios de um cubo para este usu�rio
	method SaveCubePrivileges(anCubeID, aoNewPrivOper)

	// redefine todos os privil�gios deste usu�rio
	method ResetAllPrivileges()
	
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
Args: 	anDwID, num�rico, contendo o id do dw aonde ser�o gerenciados os privil�gios do usu�rio
		anUserID, num�rico, contendo o id do usu�rio dos privil�gios
--------------------------------------------------------------------------------------
*/
method New(anDwID, anUserID) class TDWPrivileges

	_Super:New()
	::Clean()
	::DwID(anDwID)
	::UserID(anUserID)
	::DoLoad()
	
return

method Free() class TDWPrivileges

	::Clean()
	_Super:Free()

return


method Clean() class TDWPrivileges
	
	::DwID(0)
	::UserID(0)
	::UserGroup(0)
    ::UserIsAdm(.F.)

return

/*
--------------------------------------------------------------------------------------
Propriedade DwID
Arg: anValue, num�rico, define esta propriedade
Ret: num�rico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method DwID(anValue) class TDWPrivileges
	property ::fnDwID := anValue
return ::fnDwID

/*
--------------------------------------------------------------------------------------
Propriedade UserID
Arg: anValue, num�rico, define esta propriedade
Ret: num�rico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method UserID(anValue) class TDWPrivileges
	property ::fnUserID := anValue
return ::fnUserID

/*
--------------------------------------------------------------------------------------
Propriedade UserGroup
Arg: anValue, num�rico, define esta propriedade
Ret: num�rico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method UserGroup(anValue) class TDWPrivileges
	property ::fnUserGroup := anValue
return ::fnUserGroup

/*
--------------------------------------------------------------------------------------
Propriedade UserIsAdm
Arg: alValue, l�gico, define esta propriedade
Ret: l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method UserIsAdm(alValue) class TDWPrivileges
	property ::flUserIsAdm := alValue
return ::flUserIsAdm

/*
--------------------------------------------------------------------------------------
M�todo que realiza o carregamento de informa��es do usu�rio
Arg: anValue, num�rico, define esta propriedade
Ret: num�rico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method DoLoad() class TDWPrivileges
	Local oUser := InitTable(TAB_USER)
	
	oUser:SavePos()
	oUser:Seek(1, { ::UserID() })
	if !oUser:EoF() .AND. oUser:value("id") == ::UserID()
		::UserGroup(oUser:value("id_grupo"))
		::UserIsAdm(oUser:value("admin"))
	endif
	oUser:RestPos()
return

/*
--------------------------------------------------------------------------------------
M�todo que verifica se o usu�rio t�m um grupo
Arg:
Ret: L�gico, .T. se tiver ou .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method UserHaveGroup() class TDWPrivileges
return iif (::UserGroup() > 0, .T., .F.)

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar um privil�gio gen�rico para este usu�rio
Arg: 	anObjID, n�merico, cont�m o id do objeto
		acPriv, caracter, cont�m o tipo de objeto (ver defines PRIV_OBJ_XXXX)
		acOper, caracter, cont�m a opera��o (ver defines PRIV_OPER_XXXX)
Ret: L�gico, se possue (.T.) ou n�o (.F.) o privl�gio
--------------------------------------------------------------------------------------
*/
method checkPrivilege(anObjID, acPriv, acOper, anUserID) class TDWPrivileges
    
    Local cRet := PRIV_AUTH_NDEFINED
	Local oTablePriv := InitTable(TAB_USER_PRIV)
	
	default anUserID := ::UserID()
	
	// verifica os privil�gios do usu�rio (caso este n�o seja admin)
	if !::UserIsAdm()
		__DWIDTemp := ::DwID()
		if anObjID > 0
			oTablePriv:SavePos()
			oTablePriv:Seek(2, { anUserID, anObjID, acPriv, acOper })
			if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == anUserID .AND. oTablePriv:value("id_dw") == ::DwID() ;
					.AND. oTablePriv:value("id_obj") == anObjID .AND. oTablePriv:value("type_obj") == acPriv .AND. ;
						oTablePriv:value("type_oper") == acOper
				cRet := oTablePriv:value("type_auth")
			endif
			oTablePriv:RestPos()
		else
			oTablePriv:SavePos()
			oTablePriv:Seek(3, { anUserID, acPriv, acOper })
			if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == anUserID .AND. oTablePriv:value("id_dw") == ::DwID() ;
					.AND. oTablePriv:value("type_obj") == acPriv .AND. oTablePriv:value("type_oper") == acOper
				cRet := oTablePriv:value("type_auth")
			endif
			oTablePriv:RestPos()
		endif
		__DWIDTemp := -1
	else
		cRet := PRIV_AUTH_AUTHOR
	endif
	
return cRet

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar os privil�gios de um determinado cubo
Arg: anDwID, n�merico, cont�m o id do DW
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privil�gios deste usu�rio para cada opera��o poss�vel
--------------------------------------------------------------------------------------
*/
method checkDwPrivileges(anDwID) class TDWPrivileges
	
	Local cUserPriv
	Local oRet := TDWPrivOper():New()
	
	// privil�gio de acesso a DW
	cUserPriv := ::checkPrivilege(anDwID, PRIV_OBJ_DW, PRIV_OPER_ACESS)
	oRet:Acess(checkAuthorization(cUserPriv))
	// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(anDwID, PRIV_OBJ_DW, PRIV_OPER_ACESS, ::UserGroup())
		oRet:AcessInherited(checkAuthorization(cUserPriv))
	endif
	
return oRet

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar os privil�gios de um determinado cubo
Arg: anCubID, n�merico, cont�m o id do cubo
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privil�gios deste usu�rio para cada opera��o poss�vel
--------------------------------------------------------------------------------------
*/
method checkCubePrivileges(anCubID) class TDWPrivileges
	
	Local oRet := TDWPrivOper():New()
	Local cUserPriv
	
	// cubo s� poder� ser criado pelo administrador
	oRet:Create(::UserIsAdm())
	oRet:CreateInherited(.F.)
	
	// privil�gio de manuten��o do cubo
	cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_MANUT)
	oRet:Maintenance(checkAuthorization(cUserPriv))
	// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_MANUT, ::UserGroup())
		oRet:MaintInherited(checkAuthorization(cUserPriv))
	endif

	// privil�gio de acesso ao cubo
	cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_ACESS)
	oRet:Acess(checkAuthorization(cUserPriv))
	// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(anCubID, PRIV_OBJ_CUBE, PRIV_OPER_ACESS, ::UserGroup())
		oRet:AcessInherited(checkAuthorization(cUserPriv))
	endif	
	
return oRet

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar o privil�gio de cria��o de consultas
Arg:
Ret: L�gico, se possue (.T.) ou n�o (.F.) o privl�gio
--------------------------------------------------------------------------------------
*/
method checkCreateQuery() class TDWPrivileges
	
	Local cUserPriv
	Local oRet := TDWPrivOper():New()
	
	// privil�gio de cria��o de consulta
	cUserPriv := ::checkPrivilege(0, PRIV_OBJ_QUERY, PRIV_OPER_CREATE)
	oRet:Create(checkAuthorization(cUserPriv))
	// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
	if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
		cUserPriv := ::checkPrivilege(0, PRIV_OBJ_QUERY, PRIV_OPER_CREATE, ::UserGroup())
		oRet:CreateInherited(checkAuthorization(cUserPriv))
	endif
	
return oRet

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar o privil�gio de acesso deste usu�rio � uma determinada consulta
Arg: anQryID, n�merico, cont�m o id da consulta
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privil�gios deste usu�rio para cada opera��o poss�vel
--------------------------------------------------------------------------------------
*/
method checkQryAcessPrivileges(anQryID) class TDWPrivileges
return ::checkQueryPrivileges(anQryID, PRIV_OPER_ACESS)

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar o privil�gio de manuten��o deste usu�rio � uma determinada consulta
Arg: anQryID, n�merico, cont�m o id da consulta
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privil�gios deste usu�rio para cada opera��o poss�vel
--------------------------------------------------------------------------------------
*/
method checkQryMaintPrivileges(anQryID) class TDWPrivileges
return ::checkQueryPrivileges(anQryID, PRIV_OPER_MANUT)

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar o privil�gio de exportar deste usu�rio � uma determinada consulta
Arg: anQryID, n�merico, cont�m o id da consulta
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privil�gios deste usu�rio para cada opera��o poss�vel
--------------------------------------------------------------------------------------
*/
method checkQryExportPrivileges(anQryID) class TDWPrivileges
return ::checkQueryPrivileges(anQryID, PRIV_OPER_EXPORT)

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por checar os privil�gios de uma determinada consulta
Arg: anQryID, n�merico, cont�m o id da consulta
	 acOperType, string, cont�m o tipo de opera��o a ser verificada a permiss�o. DEFAULT verifica todos os direitos
Ret: Objeto, retorna objeto do tipo TDWPrivOper() com os privil�gios deste usu�rio para cada opera��o poss�vel
--------------------------------------------------------------------------------------
*/
method checkQueryPrivileges(anQryID, acOperType) class TDWPrivileges
	
	Local oRet
	Local cUserPriv, oUser
	Local oConsulta			:= InitTable(TAB_CONSULTAS)
	
	// verifica o privil�gio de cria��o de consultas
	oRet := ::checkCreateQuery()
	
	oConsulta:SavePos()
	oConsulta:Seek(1, { anQryID })
	// verifica se a consulta � de usu�rio
	if !oConsulta:EoF() .AND. oConsulta:value("id") == anQryID .AND. oConsulta:value("tipo") == QUERY_USER

		/*Verifica se o CRIADOR da consulta foi este usu�rio | Se a Consulta � foi definida como sendo PUBLICA
			| Se o usu�rio corrente � ADMINISTRADOR do SigaDW.*/ 		
		if ( oConsulta:value("id_user") == ::UserID() .or. oConsulta:value("publica") .or. oUserDW:UserIsAdm() )
			oRet:MaintInherited(.F.)	// privil�gio de manuten��o herdado
			oRet:Maintenance(.T.)		// privil�gio de manuten��o
			oRet:AcessInherited(.F.)	// privil�gio de acesso herdado
			oRet:Acess(.T.) 			// privil�gio de acesso
			oRet:ExportInherited(.F.) 	// privil�gio de exporta��o herdado
			oRet:Export(.T.) 			// privil�gio de exporta��o
		else			
			oUser := InitTable(TAB_USER)
			oUser:SavePos()
			oUser:Seek(1, { oConsulta:value("id_user") })
			// verifica se a consulta � p�blica OU se est� dispon�vel para o grupo deste usu�rio
			if oConsulta:value("publica") .OR. (!oUser:EoF() .and. oUser:value("id") == oConsulta:value("id_user") .and. ;
					oConsulta:value("sogrupo") .and. ::UserGroup() == oUser:value("id_grupo"))
				oRet:MaintInherited(.F.)	// privil�gio de manuten��o herdado
				oRet:Maintenance(.F.)		// privil�gio de manuten��o
				oRet:AcessInherited(.T.)	// privil�gio de acesso herdado
				oRet:Acess(.F.) 			// privil�gio de acesso
				oRet:ExportInherited(.F.) 	// privil�gio de exporta��o herdado
				oRet:Export(.F.) 			// privil�gio de exporta��o			
			endif
			oUser:RestPos()
		endif
	
	// consulta � pr�-definida
	else
		
		// privil�gio de manuten��o da consulta
		if (isNull(acOperType) .OR. acOperType == PRIV_OPER_MANUT)
			cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_MANUT)
			oRet:Maintenance(checkAuthorization(cUserPriv))
			// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
			if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
				cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_MANUT, ::UserGroup())
				oRet:MaintInherited(checkAuthorization(cUserPriv)) 
			endif
		endif
		
		// privil�gio de acesso � consulta
		if (isNull(acOperType) .OR. acOperType == PRIV_OPER_ACESS)
			cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_ACESS)
			oRet:Acess(checkAuthorization(cUserPriv))
			// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
			if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
				cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_ACESS, ::UserGroup())
				oRet:AcessInherited(checkAuthorization(cUserPriv))
			endif
		endif
		
		// privil�gio de exportar a consulta
		if (isNull(acOperType) .OR. acOperType == PRIV_OPER_EXPORT)
			cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_EXPORT)
			oRet:Export(checkAuthorization(cUserPriv))
			// se o usu�rio n�o tiver privil�gio estabelecido, procuro pelo privil�gio no grupo do usu�rio
			if cUserPriv == PRIV_AUTH_NDEFINED .AND. ::UserHaveGroup()
				cUserPriv := ::checkPrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_EXPORT, ::UserGroup())
				oRet:ExportInherited(checkAuthorization(cUserPriv))
			endif
		endif
	endif
	oConsulta:RestPos()
	
return oRet

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por salvar um privil�gio gen�rico para um usu�rio
Arg: 	anObjID, n�merico, cont�m o id do objeto
		acPriv, caracter, cont�m o tipo de objeto (ver defines PRIV_OBJ_XXXX)
		acOper, caracter, cont�m a opera��o (ver defines PRIV_OPER_XXXX)
		acAuthoriz, caracter, cont�m o tipo de autoriza��o (ver defines PRIV_AUTH_XXXX)
--------------------------------------------------------------------------------------
*/
method SavePrivilege(anObjID, acPriv, acOper, acAuthoriz) class TDWPrivileges
	
	Local oTablePriv 	:= InitTable(TAB_USER_PRIV)
	Local aValues 		:= 	{	{ "ID_DW", ::DwID() }, ;
								{ "ID_USER", ::UserID() }, ;
								{ "ID_OBJ", anObjID }, ;
								{ "type_obj", acPriv }, ;
								{ "type_oper", acOper }, ;
								{ "type_auth", acAuthoriz } ;
							}
	
	// VERIFIA O PRIVIL�GIO ATUAL DO USU�RIO
	__DWIDTemp := ::DwID()
	if !empty(anObjID) .AND. !(anObjID == 0)
		oTablePriv:SavePos()
		oTablePriv:Seek(2, { ::UserID(), anObjID, acPriv, acOper })
		if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == ::UserID() .AND. oTablePriv:value("id_dw") == ::DwID() ;
				.AND. oTablePriv:value("id_obj") == anObjID .AND. oTablePriv:value("type_obj") == acPriv .AND. ;
					oTablePriv:value("type_oper") == acOper
			oTablePriv:Update( { { "type_auth", acAuthoriz } } )
		else
			oTablePriv:Append(aValues)
		endif
		oTablePriv:RestPos()
	else
		oTablePriv:SavePos()
		oTablePriv:Seek(3, { ::UserID(), acPriv, acOper })
		if !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == ::UserID() .AND. oTablePriv:value("id_dw") == ::DwID() ;
				.AND. oTablePriv:value("type_obj") == acPriv .AND. oTablePriv:value("type_oper") == acOper
			oTablePriv:Update( { { "type_auth", acAuthoriz } } )
		else
			oTablePriv:Append(aValues)
		endif
		oTablePriv:RestPos()
	endif
	__DWIDTemp := -1
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por salvar privil�gios de DW para este usu�rio. Atualmente s� acesso ao DW
Arg: aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privil�gios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveDwPrivileges(anDwID, aoNewPrivOper) class TDWPrivileges
	
	// recupera os privil�gios atuais do usu�rio para acessar o DW espec�fico
	Local oPrivOper := ::checkDwPrivileges(anDwID)
	
	// salva o privil�gio de acesso do DW CASO o usu�rio j� possuia
	// autoriz de acesso DW  OU herdou do grupo               E estou negando essa autoriz
	if ((oPrivOper:Acess() .OR. oPrivOper:AcessInherited()) .AND. !aoNewPrivOper:Acess()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Acess() .AND. !oPrivOper:AcessInherited()) .AND. aoNewPrivOper:Acess())
		::SavePrivilege(anDwID, PRIV_OBJ_DW, PRIV_OPER_ACESS, getAuthorization(aoNewPrivOper:Acess()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por salvar privil�gios de cria��o para um usu�rio. Atualmente s� cria��o de consultas
Arg: aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privil�gios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveCreatePrivileges(aoNewPrivOper) class TDWPrivileges
	
	// recupera os privil�gios atuais do usu�rio para esta consulta
	Local oPrivOper := ::checkCreateQuery()
	
	// salva o privil�gio de cria��o de consultas CASO o usu�rio j� possuia
	// autoriz de cria��o  OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Create() .OR. oPrivOper:CreateInherited()) .AND. !aoNewPrivOper:Create()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Create() .AND. !oPrivOper:CreateInherited()) .AND. aoNewPrivOper:Create())
		::SavePrivilege(0, PRIV_OBJ_QUERY, PRIV_OPER_CREATE, getAuthorization(aoNewPrivOper:Create()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por salvar um privil�gio para um usu�rio em um determinada consulta
Arg: 	anQryID, n�merico, cont�m o id da consulta
		aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privil�gios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveQueryPrivileges(anQryID, aoNewPrivOper) class TDWPrivileges
	
	// recupera os privil�gios atuais do usu�rio para esta consulta
	Local oPrivOper := ::checkQueryPrivileges(anQryID)
	
	// salva o privil�gio de acesso CASO o usu�rio j� possuia
	// autoriz de acesso  OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Acess() .OR. oPrivOper:AcessInherited()) .AND. !aoNewPrivOper:Acess()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Acess() .AND. !oPrivOper:AcessInherited()) .AND. aoNewPrivOper:Acess())
		::SavePrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_ACESS, getAuthorization(aoNewPrivOper:Acess()))
	endif
	
	// salva o privil�gio de manuten��o CASO o usu�rio j� possuia
	// autoriz de manuten��o      OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Maintenance() .OR. oPrivOper:MaintInherited()) .AND. !aoNewPrivOper:Maintenance()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Maintenance() .AND. !oPrivOper:MaintInherited()) .AND. aoNewPrivOper:Maintenance())
		::SavePrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_MANUT, getAuthorization(aoNewPrivOper:Maintenance()))
	endif
	
	// salva o privil�gio de exportar CASO o usu�rio j� possuia
	// autoriz de exportar   OU herdou do grupo                 E estou negando essa autoriz
	if ((oPrivOper:Export() .OR. oPrivOper:ExportInherited()) .AND. !aoNewPrivOper:Export()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Export() .AND. !oPrivOper:ExportInherited()) .AND. aoNewPrivOper:Export())
		::SavePrivilege(anQryID, PRIV_OBJ_QUERY, PRIV_OPER_EXPORT, getAuthorization(aoNewPrivOper:Export()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por salvas os privil�gios de um cubo para este usu�rio
Arg: 	anQryID, n�merico, cont�m o id da consulta
		aoNewPrivOper, objeto, objeto do tipo TDWPrivOper() com os privil�gios a serem salvos
--------------------------------------------------------------------------------------
*/
method SaveCubePrivileges(anCubeID, aoNewPrivOper) class TDWPrivileges
	
	// recupera os privil�gios atuais do usu�rio para esta consulta
	Local oPrivOper := ::checkCubePrivileges(anCubeID)
	
	// salva o privil�gio de acesso CASO o usu�rio j� possuia
	// autoriz de acesso  OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Acess() .OR. oPrivOper:AcessInherited()) .AND. !aoNewPrivOper:Acess()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Acess() .AND. !oPrivOper:AcessInherited()) .AND. aoNewPrivOper:Acess())
		::SavePrivilege(anCubeID, PRIV_OBJ_CUBE, PRIV_OPER_ACESS, getAuthorization(aoNewPrivOper:Acess()))
	endif
	
	// salva o privil�gio de manuten��o CASO o usu�rio j� possuia
	// autoriz de manuten��o      OU herdou do grupo                   E estou negando essa autoriz
	if ((oPrivOper:Maintenance() .OR. oPrivOper:MaintInherited()) .AND. !aoNewPrivOper:Maintenance()) .OR. ; //OU n�o tinha autoriz e estou concedendo
						((!oPrivOper:Maintenance() .AND. !oPrivOper:MaintInherited()) .AND. aoNewPrivOper:Maintenance())
		::SavePrivilege(anCubeID, PRIV_OBJ_CUBE, PRIV_OPER_MANUT, getAuthorization(aoNewPrivOper:Maintenance()))
	endif
	
return

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por redefinir todos os privil�gios deste usu�rio com os privil�gios do grupo do usu�rio
Arg:
--------------------------------------------------------------------------------------
*/
method ResetAllPrivileges() class TDWPrivileges
	
	Local oTablePriv := InitTable(TAB_USER_PRIV)
	
	__DWIDTemp := ::DwID()
	if ::UserHaveGroup()
		oTablePriv:SavePos()
		oTablePriv:Seek(2, { ::UserID() })
		while !oTablePriv:EoF() .AND. oTablePriv:value("id_user") == ::UserID()
			oTablePriv:Delete()
			oTablePriv:_Next()
		enddo
		oTablePriv:RestPos()
	endif
	__DWIDTemp := -1
	
return

/*
--------------------------------------------------------------------------------------
Fun��o respons�vel por verificar se o usu�rio tem ou n�o autoriza��o
Arg: acPrivilege, caracter, cont�m o tipo de autoriza��o do usu�rio
Ret: .T. se n�o tiver autoriza��o, .F. em outra situa��o
--------------------------------------------------------------------------------------
*/
static function checkAuthorization(acPrivilege)
return iif (acPrivilege == PRIV_AUTH_AUTHOR, .T., .F.)

/*
--------------------------------------------------------------------------------------
Fun��o respons�vel por recuperar o tipo de autoriza��o
Arg: alPrivilege, l�gico, cont�m o tipo de autoriza��o do usu�rio
Ret: PRIV_AUTH_AUTHOR caso seja .T., PRIV_AUTH_DENIED em outra situa��o
--------------------------------------------------------------------------------------
*/
static function getAuthorization(alPrivilege)
return iif (alPrivilege, PRIV_AUTH_AUTHOR, PRIV_AUTH_DENIED)