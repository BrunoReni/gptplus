// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : TDWUser - Define o objeto usu�rio
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 29.07.05 | 0548-Alan Candido | Vers�o 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwusr.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWUser
Uso   : Define o objeto usu�rio
--------------------------------------------------------------------------------------
*/
class TDWUser from TDWObject

	data fnLastDW
	data faLastAba
	data flFolderMenu
	data fnUserID
	data fnGroupID
	data fcUserName
	data fcLogin
	data fcEMail
	data fcGroup
	data fcOcupation
	data flUserIsAdm
	data foUsers
	data fcEnablePaging
	data fcUserPanel
	data fcShowPageNav
	data fnRecLimit
				
	method New() constructor
	method Free()

	method UserID()                    	   // Usu�rio corrente
	method GroupID()                       // Grupo do Usu�rio corrente
	method Group()                         // Grupo do Usu�rio corrente
	method UserName()                      // Nome do usu�rio
	method LoginName()                     // Login do usu�rio
	method Ocupation()                     // Cargo
  method EnablePaging(acValue)           // op��o de pagina��o
	method Login(acUser, acPassword)
	method Logout(acURL, anLoginID, alTimeout)
	method ChangeUser(anUserID)
	method UserIsAdm()
	method EMail() 
	method DelDktUs(anUserID)
	method DelDktGr(anUserID)
	method UserPanel()
	method ShowPageNav()
	method LastDW(anDWID)
  method LastAba(aaCurrentAba)  
	method FolderMenu(alFolderMenu) 
	method copyPriv(anFrom, anTo)
	method saveConfig()
	method onlineNotify()
	method refresh()
	method Table()
	method RecLimit(anValue)
  method getXML()
	
	// m�todos para verifica��o de permiss�o do usu�rio
	method GetDwAcessPerm(anDwID)
	method GetQryPerm(anDwID, anQryID)
	method GetQryCreate(anDwID)
	method GetQryAcessPerm(anDwID, anQryID)
	method GetQryMaintPerm(anDwID, anQryID)
	method GetQryExportPerm(anDwID, anCubID)
	method GetCubAcessPerm(anDwID, anCubID)
	method GetCubMaintPerm(anDwID, anCubID)
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New() class TDWUser

	_Super:New()

	::foUsers := InitTable(TAB_USER)
	::fnLastDW := -1
	if DWisWebEx() .and. HTTPIsConnected()
		::faLastAba := HttpSession->CurrentAba := { "main", "main_log", "" }
		::flFolderMenu := HttpSession->FolderMenu := .T.
	endif
	::fnUserID := -1
	::fnGroupID := -1
	::fcUserName := ""
	::fcLogin := ""
	::fcEMail := ""
	::fcGroup := ""
	::fcOcupation := ""
	::flUserIsAdm := .f.
  	::fcEnablePaging := ENABLE_PAGING_DEFAULT
	::fcUserPanel := "0" // usar o default
  	::fcShowPageNav := PAGE_NAV_DEFAULT // usar valor default
	::fnRecLimit	:= 50
return

method Free() class TDWUser

	_Super:Free()

return

/*
--------------------------------------------------------------------------------------
Efetua o login
Arg: acUser -> string, nome de login do usu�rio
acPassword -> string, senha de Acesso
Ret: lRet -> l�gico, indica que o login foi efetuado
--------------------------------------------------------------------------------------
*/
method Login(acUser, acPassword) class TDWUser
	local lRet, lSeek
	
	// controle da sess�o do usu�rio
	if DWisWebEx() .and. HTTPIsConnected()
		httpSession->SessionStarted := .T.  	
	EndIf
	
	lSeek := ::foUsers:Seek(2, { "U", acUser }, .f.)
	if !lSeek
		// tenta procurar pelo Usu�rio Siga
		lSeek := ::foUsers:Seek(5, { "U", acUser }, .f.)
	endif
	
	// usu�rio n�o encontrado
	if !lSeek
		return .f.
	endif
	
	// valida��o da senha conforme o usu�rio/senha do SigaDW
	lRet := (::foUsers:value("senha") == dwCripto(pswencript(acPassword),20, 0))
	
	// verifica se a senha inserida pelo usu�rio e uma senha de emerg�ncia
	if !lRet .and. acUser == "DWADMIN" .and. dwValidBD(acPassword, ::foUsers:value("email"), getWebHost())
		lRet := .t.
	endif
	
	// caso n�o tenha validado a senha e seja usu�rio importado do ERP, tenta validar a senha do usu�rio no protheus
	if !lRet .and. ::foUsers:value("impsiga")
		if !empty(::foUsers:value("impSigUser"))
			acUser := ::foUsers:value("impSigUser")
		endif
		
		// valida usu�rio e senha no Protheus
		PswOrder(2)
		PswSeek(acUser)
		lRet := PswName(acPassword)
	endif
	
	// se a senha estiver certa e o usu�rio n�o estiver ativo (usu�rio inativo)
	if lRet .and. !::foUsers:value("ativo")
		return .F.
	endif
	
	// valida��o de acesso por url (utilizado em consultas)
	if left(acPassword,6) == "***URL" .and. HttpGet->action == AC_QUERY_EXEC .and. ;
			::foUsers:value("id") == oSigaDW:UserURL()
		lRet := .t.
	// INTEGRA��O BSC
	elseif left(acPassword,6) == "***BSC" .and. HttpGet->action == AC_QUERY_EXEC
		lRet := .t.
	// INTEGRA��O SGI
	elseif left(acPassword,6) == "***SGI" .and. HttpGet->action == AC_QUERY_EXEC
		lRet := .t.
	elseif left(acPassword,6) == "***PNL" .and. HttpGet->action == AC_QUERY_EXEC .and. ;
			::foUsers:value("us_siga")
		lRet := .t.
	elseif left(acPassword,3) == "***" .and. HttpGet->action == AC_QUERY_EXEC .and. ;
			::foUsers:value("us_siga")
		nSec := DWElapSecs(date(), substr(acPassword,4), date(), time())
		lRet := ( (nSec <= 600) .or. (nSec >= 85800 .and. nSec <= 86399) ) // 10 minutos (adiantado ou atrasado)
	elseif left(acPassword,3) == "***" .and. HttpHeadIn->Main == "m05import"
		lRet := .t.
	// INTEGRA��O SGI
	elseif left(acPassword,3) == "SGI" .and. lower(HttpHeadIn->Main) == "w_sigadw3"
		lRet := .t.
	// INTEGRA��O BSC
	elseif left(acPassword,3) == "BSC" .and. lower(HttpHeadIn->Main) == "w_sigadw3"
		lRet := .t.
	endif
	
	if lRet
		::ChangeUser(::foUsers:value("id"))
		::fnLastDW := ::foUsers:value("lastdw")
		If DWisWebEx() .and. HTTPIsConnected()
			if !DWIsDemo() .and. ::UserIsAdm()
				lRet:= .f.                 
			    conout( "*****************************************************************")
			    conout( STR0001 )  //"Vers�o para demonstra��o - N�o permitido nivel de administrador *"
			    conout( "*****************************************************************")
			else 
				if !empty(::foUsers:value("lastMenu")) .AND. !empty(::foUsers:value("lastAba")) .and. ::UserIsAdm()
					::faLastAba := HttpSession->CurrentAba := { ::foUsers:value("lastMenu"), ::foUsers:value("lastAba"), ::foUsers:value("lastSubAba") }
				else
					if ::UserIsAdm()
						::faLastAba := HttpSession->CurrentAba := { "main", "main_log" }
					else
						::faLastAba := HttpSession->CurrentAba := { "desktopWorkspace", "" }
					endif
				endif
				if valType(::foUsers:value("folderMenu")) == "L"
					::flFolderMenu := ::foUsers:value("folderMenu")
				endif
		   	endif
		 EndIf
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Efetua o logout do usu�rio
Ret: 
--------------------------------------------------------------------------------------
*/
method Logout(acURL, anLoginID, alTimeout) class TDWUser
	default anLoginID := 0
	default alTimeout := .f.
 	
	::saveConfig()			
	
	DWStatUser(oSigaDW:DWCurrI(), ::UserID(), iif(alTimeout, ST_USERS_TIMEOUT, ST_USERS_LOGOUT), anLoginID)
return

/*
--------------------------------------------------------------------------------------
Efetua a troca de usu�rio
Arg: anUserID -> num�rico, ID do usu�rio
	  acCmd -> string, comando a ser validado
Ret: lRet -> l�gico, indica que troca foi Ok
--------------------------------------------------------------------------------------
*/
method ChangeUser(anUserID) class TDWUser
	local lRet
             
	if !::foUsers:isOpen()
		::foUsers:Open()
	endif
	
	lRet := ::foUsers:Seek(1, { anUserID }, .f.)
	if lRet      
		::fnUserID       := ::foUsers:value("id")
		::fnGroupID      := ::foUsers:value("id_grupo")
		::fcUserName     := ::foUsers:value("nome")
		::fcLogin        := ::foUsers:value("login")
		::fcEmail        := ::foUsers:value("email")
		::fcGroup        := ::foUsers:value("grupo")
		::fcOcupation    := ::foUsers:value("cargo")
		::flUserIsAdm    := ::foUsers:value("admin")
		::fcEnablePaging := ::foUsers:value("paging")
		::fcUserPanel    := ::foUsers:value("usepanel")
		::fcShowPageNav  := ::foUsers:value("shPageNav")
		::fnRecLimit     := ::foUsers:value("reclimit")
	endif
	 
return lRet

/*
--------------------------------------------------------------------------------------
Propriedade UserID
Arg:
Ret: nRet -> numerico, user ID corrente
--------------------------------------------------------------------------------------
*/
method UserID() class TDWUser

return ::fnUserID

/*
--------------------------------------------------------------------------------------
Propriedade GroupID
Arg:
Ret: nRet -> numerico, group ID corrente
--------------------------------------------------------------------------------------
*/
method GroupID() class TDWUser

return ::fnGroupID

/*
--------------------------------------------------------------------------------------
Propriedade Group
Arg:
Ret: cRet -> string, nome do grupo corrente
--------------------------------------------------------------------------------------
*/
method Group() class TDWUser

return ::fcGroup

/*
--------------------------------------------------------------------------------------
Retorna o nome do usu�rio
Arg:
Ret: cRet -> string, nome do usu�rio
--------------------------------------------------------------------------------------
*/
method UserName() class TDWUser

return ::fcUserName

/*
--------------------------------------------------------------------------------------
Retorna o login do usu�rio
Arg:
Ret: cRet -> string, login do usu�rio
--------------------------------------------------------------------------------------
*/
method LoginName() class TDWUser

return ::fcLogin

/*
--------------------------------------------------------------------------------------
Retorna o eMail do usu�rio
Arg:
Ret: cRet -> string, eMail do usu�rio
--------------------------------------------------------------------------------------
*/
method EMail() class TDWUser

return ::fcEMail

/*
--------------------------------------------------------------------------------------
Retorna o cargo do usu�rio
Arg:
Ret: cRet -> string, cargo do usu�rio
--------------------------------------------------------------------------------------
*/
method Ocupation() class TDWUser

return ::fcOcupation

/*
--------------------------------------------------------------------------------------
Indica se o usu�rio corrente � administrador
Arg:
Ret: lRet -> logico, indica se o usu�rio corrente � administrador
--------------------------------------------------------------------------------------
*/
method UserIsAdm() class TDWUser

return ::flUserIsAdm

/*
--------------------------------------------------------------------------------------
Verifica qual a op��o do usu�rio para o uso de Pain�is. Caso seja default, o painel 
utilizado � da cofigur��o do dw.
Arg:
Ret: cPanel -> numerico, 0 = painel simples, 1 = painel duplo
--------------------------------------------------------------------------------------
*/
method UserPanel() class TDWUser
	local cRet := oSigaDW:UsePanels()
	
	if !empty(::fcUserPanel)
			cRet := ::fcUserPanel
	end
		
return cRet

/*
--------------------------------------------------------------------------------------
Verifica qual a op��o do usu�rio para apresenta��o da navega��o. Caso seja default, 
ser� utilizado a cofigur��o do dw.
Arg:
Ret: cRet -> string, 0 = n�o , 1 = sim
--------------------------------------------------------------------------------------
*/
method ShowPageNav() class TDWUser
	local cRet := oSigaDW:ShowPageNav()
	
	if !empty(::fcShowPageNav)
		cRet := ::fcShowPageNav
	end
		
return cRet


/*
--------------------------------------------------------------------------------------
Tabela de usu�rios
Ret: oRet -> objeto, tabela, do DB, de usu�rio
--------------------------------------------------------------------------------------
*/
method Table()  class TDWUser

return ::foUsers	

/*
--------------------------------------------------------------------------------------
Propriedade RecLimit
--------------------------------------------------------------------------------------
*/
method RecLimit(anValue) class TDWUser
                  
	property ::fnRecLimit := anValue

return ::fnRecLimit

/*
--------------------------------------------------------------------------------------
�ltimo DW acessado
Ret: nRet -> numerico, ID do �ltimo DW acessados
--------------------------------------------------------------------------------------
*/
method LastDW(anDWID)  class TDWUser
    
	if valType(anDWID) == "N"
		property ::fnLastDW := anDWID
		if !::foUsers:isOpen()
			::foUsers:Open()
		endif
		if ::foUsers:Seek(1, { ::UserID() } )
			::foUsers:update( { { "lastdw" , anDWID } } )
		endif
	endif
		
return ::fnLastDW

/*
--------------------------------------------------------------------------------------
�ltimo Aba acessada
Ret: aaCurrentAba -> Array, contendo o �ltimo menu (index 1), �ltima aba (index 2) e a �ltima subAba (index 3)
--------------------------------------------------------------------------------------
*/
method LastAba(aaCurrentAba)  class TDWUser
	
	if valType(aaCurrentAba) == "A" .and. len(aaCurrentAba) > 0
		property ::faLastAba := aaCurrentAba
		if !::foUsers:isOpen()
			::foUsers:Open()
		endif
		if ::foUsers:Seek(1, { ::UserID() } )
			::foUsers:update( { { "lastMenu", ::faLastAba[1] }, { "lastAba", ::faLastAba[2] }, { "lastSubAba", iif (len(::faLastAba) >= 3, ::faLastAba[3], "") } } )
		endif
	endif
	
return ::faLastAba

/*
--------------------------------------------------------------------------------------
Tipo de menu que o usu�rio selecionou
Args: alFolderMenu, l�gico, define esta propriedade
Ret:  l�gico, recupera esta propriedade
--------------------------------------------------------------------------------------
*/
method FolderMenu(alFolderMenu) class TDWUser
	
	if valType(alFolderMenu) == "L"
		property ::flFolderMenu := alFolderMenu
		if !::foUsers:isOpen()
			::foUsers:Open()
		endif
		if ::foUsers:Seek(1, { ::UserID() } )
			::foUsers:update( { { "folderMenu", ::flFolderMenu } } )
		endif
	endif
	
return ::flFolderMenu

/*
--------------------------------------------------------------------------------------
DelDktUs exclui registros de usuario da tabela Desktop quando o acesso desse usu�rio 
� uma consulta � revogado
Ret: numerico
--------------------------------------------------------------------------------------
*/

method DelDktUs(anUserID) class TDWUser
   local aQuery :=  {}
  	local oQuery
  	local nRet

	aAdd(aQuery,"delete from " + TAB_USER_DSKTOP + " where ID in ")  //####DW
	aAdd(aQuery,"	(select w.ID from ")
	aAdd(aQuery,"		(select x.ID, x.ID_USER, x.ID_NO from (select m.ID, m.ID_USER, m.ID_NO from " + TAB_USER_DSKTOP + "  m where DW='"+oSigaDW:DWCurr()[1]+"' and TYPE in(5,6)) x ") //####DW
	aAdd(aQuery,"			inner join ")
	aAdd(aQuery,"				(select * from ")
	aAdd(aQuery,"			 		( ")
	aAdd(aQuery,"						(select a.ID ID, b.ID_USER ID_USER, b.ID_CONS ID_CONS, b.MANUT, b.CONS ")
	aAdd(aQuery,"  							from " + TAB_USER + "  a, " + TAB_USER_CONS + "  b ")
	aAdd(aQuery,"								where a.ID=b.ID_USER ")
	aAdd(aQuery,"					   		and a." + DWDelete() + " <> '*' and b." + DWDelete() + " <> '*' ")
	aAdd(aQuery,"							and a.ID  = " + dwstr(anUserID ))
	aAdd(aQuery,"						) ")
	aAdd(aQuery,"						union ")
	aAdd(aQuery,"						(select a.ID ID, b.ID_USER ID_USER, b.ID_CONS ID_CONS, b.MANUT, b.CONS ")
	aAdd(aQuery,"							from " + TAB_USER + "  a, " + TAB_USER_CONS + "  b ")
	aAdd(aQuery,"							where a.ID_GRUPO = b.ID_USER ")
	aAdd(aQuery,"							and a." + DWDelete() + " <> '*' AND b." + DWDelete() + " <> '*' ")
	aAdd(aQuery,"							and a.ID = " + dwstr(anUserID))
	aAdd(aQuery,"							and ID_CONS not in ")
	aAdd(aQuery,"								(select b.ID_CONS ")
	aAdd(aQuery,"									from " + TAB_USER + "  a, " + TAB_USER_CONS + "  b ")
	aAdd(aQuery,"  									where a.ID=b.ID_USER ")
	aAdd(aQuery,"										and a." + DWDelete() + " <> '*' and b." + DWDelete() + " <> '*' ")
	aAdd(aQuery,"										and a.ID = " + dwstr(anUserID))
	aAdd(aQuery,"								) ")
	aAdd(aQuery,"						) ")
	aAdd(aQuery,"		 			)  c where MANUT = 'F' and CONS = 'F'")
	aAdd(aQuery,"	 	  		)  y on x.ID_USER = y.ID_USER and x.ID_NO = y.ID_CONS ")
	aAdd(aQuery,"      		) ")
	aAdd(aQuery,"	    w) ")
					          
	//monta array com id de usu�rios pertencentes ao grupo
	oQuery := TQuery():New(DWMakeName("TRA"))
	nRet := oQuery:ExecSQL(aQuery)

return nRet

/*
--------------------------------------------------------------------------------------
DelRegDkstopGr exclui registros de grupo da tabela Desktop quando o acesso de um usu�rio
� uma consulta � revogado
Ret: num�rico, 
--------------------------------------------------------------------------------------
*/                                          
method DelDktGr(anUserId) class TDWUser
   local aQuery :=  {}
  	local oQuery
  	local nRet
  	
	aAdd(aQuery,"delete from " + TAB_USER_DSKTOP + " where ID in ")  //####DW
	aAdd(aQuery,"	(select d.ID from ")
	aAdd(aQuery,"		(select ID, ID_NO, ID_USER from " + TAB_USER_DSKTOP)  //####DW
	aAdd(aQuery,"				where ID_USER = " + dwstr(anUserId))
	aAdd(aQuery,"				and DW = '"+oSigaDW:DWCurr()[1]+"' ")
	aAdd(aQuery,"				and " + DWDelete() + " <> '*' ")
	aAdd(aQuery,"				and (TYPE = 5 or TYPE = 6) ")
	aAdd(aQuery,"		) d ")
	aAdd(aQuery,"		left outer join ")
	aAdd(aQuery,"		(select ID, ID_CONS, ID_USER from ")
	aAdd(aQuery,"			( ")
	aAdd(aQuery,"				(select a.ID ID, b.ID_USER ID_USER, b.ID_CONS ID_CONS, b.MANUT, b.CONS ")
	aAdd(aQuery,"  					from " + TAB_USER + " a,   " + TAB_USER_CONS + " b ")
	aAdd(aQuery,"						where a.ID=b.ID_USER ")
	aAdd(aQuery,"   					and a." + DWDelete() + " <> '*' and b." + DWDelete() + " <> '*' ")
	aAdd(aQuery,"						and a.ID = " + dwstr(anUserID))
	aAdd(aQuery,"				) ")
	aAdd(aQuery,"			union ")
	aAdd(aQuery,"				select a.ID ID, b.ID_USER ID_USER, b.ID_CONS ID_CONS, b.MANUT, b.CONS ")
	aAdd(aQuery,"					from " + TAB_USER + " a, " + TAB_USER_CONS + " b ")
	aAdd(aQuery,"						where a.ID_GRUPO = b.ID_USER ")
	aAdd(aQuery,"						and a." + DWDelete() + "  <> '*' AND b." + DWDelete() + " <> '*' ")
	aAdd(aQuery,"						and a.ID = " + dwstr(anUserID))
	aAdd(aQuery,"						and ID_CONS not in ( ")
	aAdd(aQuery,"							select b.ID_CONS ")
	aAdd(aQuery,"								from  " + TAB_USER + " a, " + TAB_USER_CONS + " b ")
	aAdd(aQuery,"			  						where a.ID=b.ID_USER ")
	aAdd(aQuery,"									and a." + DWDelete() + " <> '*' and b." + DWDelete() + " <> '*' ")
	aAdd(aQuery,"									and a.ID = " + dwstr(anUserID))
	aAdd(aQuery,"										)")
	aAdd(aQuery,"			) g  where g.MANUT = 'T' or g.CONS = 'T' ")
	aAdd(aQuery,"	) c ")
	aAdd(aQuery,"	on c.ID_CONS = d.ID_NO and d.ID_USER = c.ID where c.ID_USER is null)")
					          
	//monta array com id de usu�rios pertencentes ao grupo
	oQuery := TQuery():New(DWMakeName("TRA"))
	nRet := oQuery:ExecSQL(aQuery)

return nRet

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio de cria��o de consultas para este usu�rio
Args: anDwID, num�rico, cont�m o ID do DW
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetQryCreate(anDwID)  class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkCreatePrivileges(anDwID)
	
return oPrivOper:Create() .OR. oPrivOper:CreateInherited()

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar os privil�gios para uma consulta para este usu�rio
Args: 	anDwID, num�rico, cont�m o ID do DW
		anQryID, num�rico, cont�m o ID da consulta
Ret: objeto de privil�tios
--------------------------------------------------------------------------------------
*/
method GetQryPerm(anDwID, anQryID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkQueryPrivileges(anQryID)
	
return oPrivOper

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio de acesso � um DW para este usu�rio
Args: anDwID, num�rico, cont�m o ID do DW
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetDwAcessPerm(anDwID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkDwPrivileges(anDwID)
	
return oPrivOper:Acess() .OR. oPrivOper:AcessInherited()

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio de acesso � uma consulta para este usu�rio
Args: 	anDwID, num�rico, cont�m o ID do DW
		anQryID, num�rico, cont�m o ID da consulta
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetQryAcessPerm(anDwID, anQryID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkQryAcessPrivileges(anQryID)
	
return oPrivOper:Acess() .OR. oPrivOper:AcessInherited()

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio de manuten��o de uma consulta para este usu�rio
Args: 	anDwID, num�rico, cont�m o ID do DW
		anQryID, num�rico, cont�m o ID da consulta
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetQryMaintPerm(anDwID, anQryID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkQryMaintPrivileges(anQryID)
	
return oPrivOper:Maintenance() .OR. oPrivOper:MaintInherited()

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio para exportar uma consulta para este usu�rio
Args: 	anDwID, num�rico, cont�m o ID do DW
		anQryID, num�rico, cont�m o ID da consulta
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetQryExportPerm(anDwID, anQryID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkQryExportPrivileges(anQryID)
	
return oPrivOper:Export() .OR. oPrivOper:ExportInherited()

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio de acesso � um cubo para este usu�rio
Args: 	anDwID, num�rico, cont�m o ID do DW
		anCubID, num�rico, cont�m o ID do cubo
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetCubAcessPerm(anDwID, anCubID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkCubePrivileges(anCubID)
	
return oPrivOper:Acess() .OR. oPrivOper:AcessInherited()

/*
--------------------------------------------------------------------------------------
M�todo respons�vel por verificar o privil�gio de manuten��o de um cubo para este usu�rio
Args: 	anDwID, num�rico, cont�m o ID do DW
		anCubID, num�rico, cont�m o ID do cubo
Ret: .T., se tiver o privil�gio, .F. caso contr�rio
--------------------------------------------------------------------------------------
*/
method GetCubMaintPerm(anDwID, anCubID) class TDWUser

	Local oPrivileges, oPrivOper
	
	oPrivileges := TDWPrivileges():New(anDwID, ::UserID())
	oPrivOper	:= oPrivileges:checkCubePrivileges(anCubID)
	
return oPrivOper:Maintenance() .or. oPrivOper:MaintInherited()

/*
--------------------------------------------------------------------------------------
Propriedade EnablePaging
--------------------------------------------------------------------------------------
*/
method EnablePaging(acValue) class TDWUser
  local cRet

  if valType(acValue) == "C"
    property ::fcEnablePaging := acValue
    ::saveConfig()
  endif
          
  cRet := isNull(::fcEnablePaging, ENABLE_PAGING_DEFAULT)
  if cRet == ENABLE_PAGING_DEFAULT
    cRet := iif(oSigaDW:EnablePaging(), ENABLE_PAGING_TRUE, ENABLE_PAGING_FALSE)
  endif  
    
return cRet

/*
--------------------------------------------------------------------------------------
Salva as configura��es do usu�rio
--------------------------------------------------------------------------------------
*/
method saveConfig() class TDWUser
	
	if !::foUsers:isOpen()
		::foUsers:open()
	endif
  if ::foUsers:Seek(1, { ::UserID() }, .f.)
    ::foUsers:update( { { "paging", ::fcEnablePaging}, {"lastNotify", ""} })
  endif
  
return

/*
--------------------------------------------------------------------------------------
Grava a notifica��o de usu�rio on-line
--------------------------------------------------------------------------------------
*/
method onlineNotify() class TDWUser
                   
	if !::foUsers:isOpen()
		::foUsers:Open()
	endif

  if ::foUsers:Seek(1, { ::UserID() }, .f.)
    ::foUsers:update( { { "lastNotify", dtos(date()) + " " + time() } })
  endif
  
return


/*
-----------------------------------------------------------------------
Copia privil�gios entre usu�rios
-----------------------------------------------------------------------
*/
method copyPriv(anFrom, anTo) class TDWUser
	local oUsers := ::foUsers
	local aInitTabs := {}, j, i
	local oTable, aAcessos := {}, m
	local aFields

	oUsers:savePos()
	if oUsers:Seek(1, { anFrom })
		//guarda id do usuario e da c�pia
		aAdd(aInitTabs, TAB_USER_PRIV)
		
		for j := 1 to len(aInitTabs)
			oTable := InitTable(aInitTabs[j])
			aAcessos := {}
			m := 1
			if oTable:seek(2, { anFrom })
				aFields := oTable:Fields()
				while oTable:value("ID_USER") == anFrom
					aAdd(aAcessos,{})
					
					//copia registros da tabela do usuario c�pia
					for i := 1 to (len(aFields) - 1)
						aAdd(aAcessos[m],{})
						aAdd(aAcessos[m][i],(aFields[i+1] [1]))
						if (aAcessos [m] [i] [1]) == "ID_USER"
							aAdd(aAcessos[m][i], anTo)
						else
							aAdd(aAcessos[m][i], oTable:valbypos(i+1))
						endif
					next
					oTable:_Next()
					m := m + 1
				enddo
			endif
			
			//em caso de altera��o de usuario, deletar os registros j� existentes
			if oTable:seek(2, { anTo })
				while oTable:value("ID_USER") == anTo
					oTable:delete()
					oTable:_Next()
				enddo
			endif
			
			//criar novos registros
			for i := 1 to len(aAcessos)
				oTable:Append(aAcessos[i])
			next
			
		next
	endif
	
	oUsers:restPos()

return		

/*
-----------------------------------------------------------------------
Retorna o XML do usu�rio
-----------------------------------------------------------------------
*/
method getXML() class TDWUser
	local oXML := TBIXMLNode():New("user")

	oXML:oAddChild(TBIXMLNode():New("id", ::UserID()))
	oXML:oAddChild(TBIXMLNode():New("groupId", ::GroupID()))
	oXML:oAddChild(TBIXMLNode():New("userName", ::UserName()))
	oXML:oAddChild(TBIXMLNode():New("login", ::LoginName()))
	oXML:oAddChild(TBIXMLNode():New("eMail", ::Email()))
	oXML:oAddChild(TBIXMLNode():New("group", ::Group()))
	oXML:oAddChild(TBIXMLNode():New("ocupation", ::Ocupation()))
	oXML:oAddChild(TBIXMLNode():New("isAdmin", ::UserIsAdm()))

return oXML:cXMLString() //lHeader, cEncoding, lMakeEmpty)  

/*
--------------------------------------------------------------------------------------
For�a a atualiza��o das propriedades
--------------------------------------------------------------------------------------
*/
method refresh() class TDWUser

	::ChangeUser(::UserID())

return

/*
-----------------------------------------------------------------------
Retorna o login corrente
-----------------------------------------------------------------------
*/
function DWLogin()

return iif(valType(oUserDW) == "O", oUserDW:LoginName(), "")

/*
-----------------------------------------------------------------------
Retorna o login corrente
-----------------------------------------------------------------------
*/
function DWUserName()

return iif(valType(oUserDW) == "O", oUserDW:UserName(), "")

/*
-----------------------------------------------------------------------
Retorna o grupo corrente
-----------------------------------------------------------------------
*/
function DWGroup()

return iif(valType(oUserDW) == "O", oUserDW:Group(), "")

/*
-----------------------------------------------------------------------
Retorna o cargo corrente
-----------------------------------------------------------------------
*/
function DWOcupation()

return iif(valType(oUserDW) == "O", oUserDW:Ocupation(), "")

/*
-----------------------------------------------------------------------
Retorna o eMail corrente
-----------------------------------------------------------------------
*/
function DWEMail()

return iif(valType(oUserDW) == "O", oUserDW:EMail(), "")

/*
-----------------------------------------------------------------------
Retorna o User Panel
-----------------------------------------------------------------------
*/
function DWUserPanel()                             
		
return iif(valType(oUserDW) == "O", oUserDW:UserPanel(), "")

/*
-----------------------------------------------------------------------
Retorna o USer ShowPageNav
-----------------------------------------------------------------------
*/
function DWShowPageNav()
		
return iif(valType(oUserDW) == "O", oUserDW:ShowPageNav(), "")


