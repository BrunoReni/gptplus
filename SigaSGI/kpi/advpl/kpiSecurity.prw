// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPISecurity - Contem os metodos para verificação de segurança do KPI
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 18.08.05 | 1776 Alexandre Alves da Silva Importado para uso no kpi.
// --------------------------------------------------------------------------------------

#include "KPIDefs.ch"
#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TKPISecurity
Classe do gerenciador de segurança do KPI.
--------------------------------------------------------------------------------------*/
#define SECUR_ID 163264
class TKPISecurity from TBIObject
	
	data fnUserCard		// Cartao do usuario
	data foUserTable	// Tabela de usuarios do sistema
	data foGroupTable	// Tabela de grupos do sistema
	data foSecurTable	// Tabela de seguranca do sistema
	
	method New(oKPICore) constructor
	method NewKPISecurity(oKPICore)
    
	method nLogin(cUser, cPassword, cSessao)
	method lSetupCard(nCard)
	method cCriptog(cKey)
	
	method oLoggedUser()

	// metodos para trabalhar com a seguranca
	method lHasAccess(cTipo, nID, cComando, nParentId)
	method lHasParentAccess(cTipo, nID, cComando)
	method lAccess(cTipo, nID, cComando)
	method lVerifUG(nIDUser,cEntidade,nEstID,nConstante)  
	method lVerifIP(cIdUser)   
	method lVerifAcessTime(cIdUser)  
	method cSecBscIte(cEntName) 	
	
	//Outros
	method lTimeBetween(cTimeFrom, cTimeTo)

endclass

/*--------------------------------------------------------------------------------------
@constructor New()
Constroe o objeto em memória.
--------------------------------------------------------------------------------------*/
method New(oKPICore) class TKPISecurity
	::NewKPISecurity(oKPICore)
return
method NewKPISecurity(oKPICore) class TKPISecurity
	::NewObject()
	::oOwner(oKPICore)
	// Abrir a tabela de usuarios
	::foUserTable := ::oOwner():oGetTable("USUARIO")
	// Abrir a tabela de Grupos
	::foGroupTable := ::oOwner():oGetTable("GRPUSUARIO")
	// Abrir as tabelas de seguranca
	::foSecurTable := ::oOwner():oGetTable("REGRA")
return

/*-------------------------------------------------------------------------------------
@method nLogin(cUser, cPassword, cSessao)
Posiciona o objeto security com base no usuário logado.
@param cUser - Nome de usuario para o qual sera gerado o security.
@param cPassword - Senha de usuario para o qual sera gerado o security.
@return - Um ID UserCard se o usuario existe. NIL usuario nao cadastrado.
--------------------------------------------------------------------------------------*/
method nLogin(cUser, cPassword, cSessao) class TKPISecurity
	local lUserAtivo := .f.
	local aGrupos,nI
	local oGrupo
	::fnUserCard := 0
	if(!empty(cUser))
		if(::foUserTable:lSeek(2, {cUser}))
            if(::foUserTable:lValue("USERKPI"))
				lUserAtivo := .t.
			else
				//Verificar se os grupos tem acesso.
				aGrupos := ::foGroupTable:aGroupsByUser(::foUserTable:cValue("ID"))
				oGrupo := 	::oOwner():oGetTable("GRUPO")			
				for nI := 1 to len(aGrupos)
					//Verifica na tabela de segurança, se o grupo tem acesso ao comando nesta entidade
					if(oGrupo:lSeek(1,{padr(aGrupos[nI],10)}))
						if(oGrupo:lValue("ATIVO"))
							lUserAtivo := .t.
							exit
						endif							
					endif
				next
			endif		   		

			if lUserAtivo
				if(::foUserTable:lValue("USERPROT"))
					psworder(2)
					pswseek(cUser)
					if(empty(cSessao) .and. pswname(cPassword)) .or. (!empty(cSessao) .and. RpcSetEnv('99', '01', cSessao, , "FAT", "", {}, .f., .f.,.f.,.f. ))
			   	 		::fnUserCard := ::foUserTable:nValue("ID")+SECUR_ID
					endif
				else
					if(	alltrim(::foUserTable:cValue("SENHA")) == cBIStr2Hex(pswencript(cPassword)) ;
						.or. cBIStr2Hex(alltrim(::foUserTable:cValue("SENHA"))) == cBIStr2Hex(pswencript(cPassword)) )
			   	 		::fnUserCard := ::foUserTable:nValue("ID")+SECUR_ID
		   		 	endif	
		   		endif
			endif		   		
		endif
	endif
return ::fnUserCard

/*-------------------------------------------------------------------------------------
@property lSetupCard(nCard)
Define o id cartao do usuario desta working thread.
@param nCard - Cartao a ser inserido.
@return - .t. se o cartão válido. .f. cartão inválido.
--------------------------------------------------------------------------------------*/
method lSetupCard(nCard) class TKPISecurity
	local lValid := ::foUserTable:lSeek(1, {padr(nCard-SECUR_ID,10)})
	::fnUserCard := iif(lValid, nCard, 0)
return lValid

/*-------------------------------------------------------------------------------------
@property oLoggedUser()
Retorna a tabela de usuarios posicionada no usuario atualmente logado.
@return - tabela posicionada.
--------------------------------------------------------------------------------------*/
method oLoggedUser() class TKPISecurity
	//Corrigido para procura o indice considerando o tamanho da chave.
	::foUserTable:lSeek(1,{padr(::fnUserCard-SECUR_ID,10)})
return ::foUserTable

/*-------------------------------------------------------------------------------------
@method lHasParentAccess(cTipo, nID, cComando)
Define se o usuario logado tem acesso a uma determinada entidade.
@param cTipo - Nome da entidade a ser pesquisada.
@param nID - ID da entidade a ser pesquisada.
@param cComando - Comando a ser executado.
@return - .t. usuario tem acesso a entidade. .f. acesso negado.
--------------------------------------------------------------------------------------*/
method lHasParentAccess(cTipo, nID, cComando) class TKPISecurity
	local lGranted := .f., oUsuarios, oTable
                               
	default cComando := "ARVORE"

	//Posiciona no usuario atualmente logado.
	oUsuarios := ::oLoggedUser()

	if(::lSetupCard(::fnUserCard))
		do case
			case ::foUserTable:lValue("ADMIN")
				lGranted := .t.
			case cComando=="CORES" .or. cComando=="NUMEROS"
				oTable := ::oOwner():oGetTable(cTipo)
				if(valtype(oTable)=="O")
					oTable:SavePos()
					if(oTable:cEntity()!="ORGANIZACAO")
						//Verifica se o Usuário é "Arquiteto" da Organização ou Estratégia
						if(oTable:lSeek(1,{nID}))
							if(!lGranted)
								oEstrategia := ::oOwner():oAncestor("ESTRATEGIA", oTable)
								nEstID 		:= oEstrategia:nValue("ID")
			    	            nOrgID 		:= oEstrategia:nValue("PARENTID")
								lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ORGANIZACAO",nOrgID,KPI_SEC_ARQUITETURA)
								if(!lGranted)
									lGranted := ::lVerifUG(oUsuarios:nValue("ID"),"ESTRATEGIA",nEstID,KPI_SEC_ARQUITETURA)
								endif	
			    			endif
						endif
						
						if(!lGranted)
							lGranted := ::lVerifUG(oUsuarios:nValue("ID"),cTipo,oTable:nValue("ID"),KPI_SEC_NUMEROS)
							if(!lGranted .and. cComando!="NUMEROS")
								lGranted := ::lVerifUG(oUsuarios:nValue("ID"),cTipo,oTable:nValue("ID"),KPI_SEC_CORES)
							endif
							if(!lGranted)                                       
								lGranted := ::lHasParentAccess(::oOwner():cGetParent(oTable), oTable:nValue("PARENTID"), cComando)
							endif
						endif
					endif
					oTable:RestPos()
				endif
		endcase
	endif
	
return lGranted                            

/*-------------------------------------------------------------------------------------
@method lHasAccess(cTipo, nID, cComando)
Define se o usuario logado tem acesso a uma determinada entidade.
@param cTipo - Nome da entidade a ser pesquisada.
@param nID - ID da entidade a ser pesquisada.
@param cComando - Comando a ser executado.
@return - .t. usuario tem acesso a entidade. .f. acesso negado.
--------------------------------------------------------------------------------------*/
method lHasAccess(cTipo, cID, cComando, nParentId) class TKPISecurity
	local lGranted := .f., oUsuarios, oTable//, oEstrategia
                               
	default cComando := "ARVORE"

	//Posiciona no usuario atualmente logado.
	oUsuarios := ::oLoggedUser()

	if(::lSetupCard(::fnUserCard))
		do case
			case ::foUserTable:lValue("ADMIN")
				lGranted := .t.
			case cTipo=="USUARIO" .or. cTipo=="GRUPO" .or. cTipo=="KPI"
				if(alltrim(oUsuarios:cValue("ID")) == alltrim(cID))
					lGranted := .t.
				else
					lGranted := .f.
				endif 
			case cComando=="AJUDA"
				lGranted := .t.
			case cComando=="ARVORE"
				lGranted := .t.
			case cTipo=="SYSTEMVAR"
				lGranted := .t.
			case cComando=="CARREGAR" .and. cTipo=="INDICADOR" //Mesmo que visualizar			
				lGranted := .t.			
			case cComando=="CARREGAR" //Mesmo que visualizar
				lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_VISUALIZACAO)
				if(! lGranted)
					lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_MANUTENCAO)
				endif
				if(! lGranted)
					lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_INCLUSAO)
				endif                                                                   
				if(! lGranted)
					lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_ALTERACAO)
				endif                                                                    
				if(! lGranted)
					lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_EXCLUSAO)
				endif
			case cComando=="MANUTENCAO" .or. cComando=="EXECUTAR"//mesmo que manutencao
				oTable := ::oOwner():oGetTable(cTipo)
				oTable:SavePos()
                //Verificacao por entidade, caso o usuario seja resposavel pelo item.
				lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_MANUTENCAO)
				oTable:RestPos()       
			case cComando=="INCLUIR"
				oTable := ::oOwner():oGetTable(cTipo)
				oTable:SavePos()
                //Verificacao por entidade, caso o usuario seja resposavel pelo item.
				lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_INCLUSAO)
				oTable:RestPos()     			
			case cComando=="ALTERAR"
				oTable := ::oOwner():oGetTable(cTipo)
				oTable:SavePos()
                //Verificacao por entidade, caso o usuario seja resposavel pelo item.
				lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_ALTERACAO)
				oTable:RestPos()
			case cComando=="EXCLUIR"
				oTable := ::oOwner():oGetTable(cTipo)
				oTable:SavePos()
                //Verificacao por entidade, caso o usuario seja resposavel pelo item.
				lGranted := ::lVerifUG(oUsuarios:cValue("ID"),cTipo,KPI_SEC_EXCLUSAO)
				oTable:RestPos()
		endcase
	endif
	
return lGranted

/*-------------------------------------------------------------------------------------
@method cCriptog(cKey)
Criptografa com função(1 way) própria do Protheus.
@param cKey - Chave a ser criptografada.
@return - Chave criptografada.
--------------------------------------------------------------------------------------*/
method cCriptog(cKey) class TKPISecurity
	cKey := pswencript(cKey)
return cKey

/*-------------------------------------------------------------------------------------
@method lVerifUG(nIDUser,cEntidade,nEntID,nConstante)
Verifica acesso de usuários e grupos (função de uso interno)
@param cIDUser - ID do Usuário
@param cEntidade - Nome da Entidade
@param nConstante - Constante a ser pesquisada
@return - Permissão (.t./.f.)
--------------------------------------------------------------------------------------*/
method lVerifUG(cIDUser,cEntidade,nConstante) class TKPISecurity
	local lGranted 	:= .f., nI
	local aAcesso	:=	{}
	local nRegra	:=	0
	local cEntidade := ::cSecBscIte(cEntidade)

	//Verifica permissão de arquitetura na estrategia
	if(::foSecurTable:lSeek(2,{"U", cIDUser, cEntidade,nConstante}))
		if(::foSecurTable:cValue("PERMITIDA") == "1")
			lGranted := .t.
		endif
	else
		aAcesso := 	::oLoggedUser():getFaRegra()
		nRegra	:=	ascan(aAcesso, {|regra|	regra[4] == cEntidade})
		if(nRegra == 0)
			lGranted := .t.
		endif			
	endif

	//Se o usuario não tiver acesso, verifica se o mesmo esta inserido em algum grupo 
	//que tenha a permissão
	if(!lGranted)
		aGrupos := ::foGroupTable:aGroupsByUser(cIDUser)
		for nI := 1 to len(aGrupos)
			//Verifica na tabela de segurança, se o grupo tem acesso ao comando nesta entidade
			if(::foSecurTable:lSeek(2,{"G", aGrupos[nI],  cEntidade, nConstante}))
				if(::foSecurTable:cValue("PERMITIDA") == "1")				
					lGranted := .t.
					exit
				endif
			endif
		next
	endif         

return lGranted             

method lVerifIP(nCard) class TKPISecurity
	local oParametro 	:= ::oOwner():oGetTable("PARAMETRO")
	local oEndIp 		:= ::oOwner():oGetTable("RESTACESSO")
	local lRet 			:= .f.     
	                 
	if( (! empty(nCard)) .and. ::foUserTable:lSeek(1, {padr(nCard-SECUR_ID,10)}) )
		if ::foUserTable:lValue("ADMIN") == .f.
			if(oParametro:lSeek(1,{"RESTRINGI_IP"}) )
				if oParametro:lValue("DADO")
					if( oEndIp:lSeek(2, {padr(HttpHeadIn->remote_addr,15)}) )
						lRet := .t.
					endif		
				else 
					lRet := .t. 
				endif
			else
				lRet := .t. //Opção default			
			endif 
		else 
			lRet := .t. //Administrador
		endif
	endif
	
return lRet

method lVerifAcessTime(nCard) class TKPISecurity
	local oParametro 	:= ::oOwner():oGetTable("PARAMETRO")
	local lRet 			:= .f.           
	local aData			:= {}
	                 
	if( (! empty(nCard)) .and. ::foUserTable:lSeek(1, {padr(nCard-SECUR_ID,10)}) )
		if ::foUserTable:lValue("ADMIN") == .f.
			if(oParametro:lSeek(1,{"RESTRINGI_HORARIO"}) )
				if oParametro:lValue("DADO")
					if(oParametro:lSeek(1,{"HORARIO_ACESSO"}))
						aData = aBIToken(oParametro:cValue("DADO"), "|") 
						if ::lTimeBetween(aData[1], aData[2])
							lRet := .t.
						endif
					endif
				else 
					lRet := .t.
				endif
			else
				lRet := .t. //Caso não encontre o registro utiliza a opção padrão
			endif 
		else 
			lRet := .t.
		endif
	endif
return lRet

method lTimeBetween(cTimeFrom, cTimeTo) class TKPISecurity
	local lRet 	:= .f.
	local nFrom	:= nHourToMinute(cTimeFrom)
	local nTo	:= nHourToMinute(cTimeTo)
	local nMy	:= nHourToMinute(time())
	
	if (nFrom <= nMy) .and. (nTo >= nMy)
		lRet := .t.
	else
		lRet := .f.
	endif

return lRet

//Devido a diferenca entre domenclatura entre as entidades do BSC e SGI aqui será retornada o 
//nome da entidade FORMMATRIX qdo as entidades forem ORGANIZACAO, ESTRATEGIA, PERSPECTIVA e OBJETIVOS
method cSecBscIte(cEntName) class TKPISecurity
	local cSecEntName := cEntName
	
return cSecEntName

function _KPISecurity()
return nil