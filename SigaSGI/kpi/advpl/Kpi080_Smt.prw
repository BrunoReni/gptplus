// ######################################################################################
// Projeto: KPI
// Modulo : Configuracao de Envio de Mensagens e Avisos SMTP
// Esta tabela soh contem um registro com o ID 1, obrigatoriamente.
// Fonte  : KPI080_SMT.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 24.09.04 | 0739 Aline Correa do Vale
// 06.01.06 | 1776 Alexandre Silva - Importado para uso no KPI.
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI080_SMT.ch"

/*--------------------------------------------------------------------------------------
@class TKPI080
@entity Mensagem
Envio de Mensagens e avisos do sistemas.
@table KPI080
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SMPTCONF"
#define TAG_GROUP  "SMPTCONFS"
#define TEXT_ENTITY STR0001/*//"Configuracao"*/
#define TEXT_GROUP  STR0002/*//"Configuracoes"*/

#Define PROT_NEN "0" // Protocolo 'Nenhum'.
#Define PROT_TLS "1" // Protocolo 'TLS'.
#Define PROT_SSL "2" // Protocolo 'SSL'.

class TKPI080 from TBITable
	method New() constructor
	method NewKPI080()

	// diversos registros
	method oArvore()
	method oToXMLList()

	// registro atual
	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)
	method SendMail(cServer, cPorta, cConta, cUsuario, cSenha, cTo, cAssunto, cCorpo, cAnexos)
endclass

method New() class TKPI080
	::NewKPI080()
return

method NewKPI080() class TKPI080
	// Table
	::NewTable("SGI080")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C",10))
	::addField(TBIField():New("FEEDBACK"	,"N"))
	::addField(TBIField():New("NOME"		,"C",120))	//Conta de email
	::addField(TBIField():New("SERVIDOR"	,"C",120))	//Servidor SMTP
	::addField(TBIField():New("PORTA"		,"C",4))	//Porta SMTP
	::addField(TBIField():New("USUARIO"	,"C",50))	//Nome do Usuario para autenticacao
	::addField(TBIField():New("SENHA"		,"C",15))	//Senha de autenticacao
	::addField(TBIField():New("PROTOCOLO"	,"N"))		//Protocolo de segurança (0 - Nenhum| 1 - TLS| 2 - SSL)
	// Indexes
	::addIndex(TBIIndex():New("SGI080I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI080I02",	{"NOME"}))
	

return

// Arvore
method oArvore() class TKPI080
	local oXMLArvore, oNode
	
	// Tag conjunto
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", TAG_GROUP)
	oAttrib:lSet("NOME", TEXT_GROUP)
	oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

 	::SetOrder(2) // Ordem de conta de email
	::cSQLFilter("ID = '"+cBIStr('1')+"'") // Filtra pelo ID 1
	::lFiltered(.t.)
	::_First()
	// Nodes
	while(!::lEof())
		// Nao lista o ID 0, de inclusao
		if(::nValue("ID")==0)
			::_Next()
			loop
		endif			

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", ::cValue("ID"))
		oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
		oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
		oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
		::_Next()
	enddo
	::cSQLFilter("") // Retira filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList() class TKPI080
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Conta de email para envio
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) /*Conta de email*/
	oAttrib:lSet("CLA000", KPI_STRING)
	// Servidor SMTP
	oAttrib:lSet("TAG001", "SERVIDOR")
	oAttrib:lSet("CAB001", STR0004)/*//"Servidor SMTP"*/
	oAttrib:lSet("CLA001", KPI_STRING)
	// Porta SMTP
	oAttrib:lSet("TAG002", "PORTA")
	oAttrib:lSet("CAB002", STR0005)/*//"Porta SMTP"*/
	oAttrib:lSet("CLA002", KPI_STRING)
	// Usuario para Autenticacao
	oAttrib:lSet("TAG003", "USUARIO")
	oAttrib:lSet("CAB003", STR0006)/*//"Usuario para Autenticacao"*/
	oAttrib:lSet("CLA003", KPI_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de conta
	::cSQLFilter("ID = '"+cBIStr('1')+"'") // Filtra pelo ID 1
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"SENHA"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TKPI080
	local cID,  aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
		  aFields  := {}
	//Se o registro 1 nao existir adiciona.
	if( ! ::lSeek(1,{"1"}))
		aAdd( aFields, {"ID", "1"} )
		
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif
	endif
	
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif
	next

	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI080
	local aFields, nInd, aREUCON, oTable, nStatus := KPI_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", ::cMakeID()} )
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI080
	local nStatus := KPI_ST_OK,	cID, nInd
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
		   aFields[nInd][2]	:=	"1"
			cID := "1" //o ID será sempre 1
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1,{"1"})) //o ID será sempre 1
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif
	endif
	
return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI080
	local nStatus := KPI_ST_OK

	// Deleta o elemento
	if(nStatus != KPI_ST_HASCHILD)
		if(::lSeek(1, {cID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif
    endif

return nStatus

// Método de envio de email
method SendMail(cServer, cPorta, cConta, cUsuario, cSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, cOculto, cProtocol) class TKPI080
	local oCarteiro
	
    Default cFrom 	:= ""
    Default cCopia 	:= ""
    Default cOculto 	:= ""
    Default cProtocol:= "0"
    
    If ValType( cProtocol ) == 'C'
    	cProtocol := iif( Empty( cProtocol ), "0", cProtocol )
    Else
    	cProtocol:= "0"
    EndIf

	oCarteiro := TBIMailSender():New() // Instancia a classe de e-mail.

	// Ajusta para o protocolo de segurança escolhido.
	If cProtocol == PROT_TLS
		oCarteiro:setTLS(.T.)
	ElseIf cProtocol == PROT_SSL
		oCarteiro:setSSL(.T.)
	EndIf

	oCarteiro:setServidor(cServer, cPorta)
	oCarteiro:setConta(cConta)
	oCarteiro:setUsuario(cUsuario, cSenha)

	oCarteiro:SendMessage( cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, cOculto)
	
return nil

function _KPI080_SMT()
return nil