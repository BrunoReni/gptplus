// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI004_Msg.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.11.04 | 1645 Leandro Marcelino Santos
// 05.01.06 | 1776 Adaptado para uso no KPI - Alexandre Silva
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI004_Msg.ch"

/*--------------------------------------------------------------------------------------
@entity Mensagens
Mensagens no KPI. Contém mensagens enviadas aos usuários do KPI.
@table KPI004
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "MENSAGEM"
#define TAG_GROUP  "MENSAGENS"
#define TEXT_ENTITY STR0001/*//"Mensagem"*/
#define TEXT_GROUP  STR0002/*//"Mensagens"*/

class TKPI004 from TBITable
	method New() constructor
	method NewKPI004()

	// diversos registros
	method oToXMLList(cParentID, nCommand)

	// registro atual
	method oToXMLNode(cDestID,cLoadCMD)
	method oToXMLRecList(cCommand)	
	method nInsFromXML(oXML, cPath)
	method nDelFromXML(cID) 
	method nExecute(cID, cExecCMD)  
	method nDelTodas(cPasta)
	Method cMakeMailName(oPessoa)
endclass
	
method New() class TKPI004
	::NewKPI004()
return
method NewKPI004() class TKPI004
	// Table
	::NewTable("SGI004")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C",015))
	::addField(TBIField():New("PARENTID"	,"C",010)) // ID da Pessoa Remetente
	::addField(TBIField():New("HORAENV"		,"C",008))
	::addField(TBIField():New("NOME"		,"C",255))
	::addField(TBIField():New("ANEXO"		,"C",255))
	::addField(TBIField():New("TEXTO"		,"M"))
	::addField(TBIField():New("DATAENV"		,"D"))
	::addField(TBIField():New("PRIORIDADE"	,"N")) // 5.Alta 6.Normal 7.Baixa
	::addField(TBIField():New("PASTA"		,"N")) // 1.Enviado 3.Excluido 4.Excluido Definitivamente
	
	// Indexes
	::addIndex(TBIIndex():New("SGI004I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI004I02",	{"NOME"},	.f.))
	::addIndex(TBIIndex():New("SGI004I03",	{"PARENTID", "ID"},	.t.))
	::addIndex(TBIIndex():New("SGI004I04",	{"DATAENV", "HORAENV"}, .f.))

return

method nExecute(cID, cExecCMD)  class TKPI004
	local nStatus := KPI_ST_OK  
    local aDatas    := {}
    
    aDatas := aBIToken(cExecCMD, "|", .f.)
       
    conout("Tipo de mensagem")
    conout(aDatas[2])
    
	do case
		case aDatas[2] == "MENSAGENS_ENVIADAS"    
	   		::nDelTodas(cBIStr(KPI_MSG_ENVIADA))    
	   	case aDatas[2] == "MENSAGENS_RECEBIDAS"    
	   	 	::nDelTodas(cBIStr(KPI_MSG_RECEBIDA))
	   	case aDatas[2] == "MENSAGENS_EXCLUIDAS"    
	   		::nDelTodas(cBIStr(KPI_MSG_EXCLUIDA))
	endcase      
    
return nStatus  

    
method nDelTodas(cPasta) class TKPI004  
	local nStatus 	:= KPI_ST_OK  
	local aArea		:= GetArea()
	local cQuery	:= ""
	local cAlias	:= GetNextAlias() 
    local oTable    := nil      

    oTable := ::oOwner():oGetTable("DESTINATARIO")    
    
	cQuery += "SELECT ID FROM " + oTable:fcTablename + " WHERE PESSID = '" + ::oOwner():foSecurity:oLoggedUser():cValue("ID") + "'"
	cQuery += " AND PASTA = '" + cPasta + "'"
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)
	DbSelectArea(cAlias)  
	
	While !((cAlias)->(Eof()))    
   		::nDelFromXML((cAlias)->ID)
		(cAlias)->(DbSkip())
   	Enddo    
   	      
   	DbSelectArea(cAlias)  
	dbCloseArea() 	
    restArea(aArea)
return nStatus    
                                

/*
*Este metodo esta sendo chamado na inicializacao do sistema para carregar,
*as mensagens recebidas para o usuario logado.
*/
method oToXMLRecList(cCommand) class TKPI004 
	local oXMLNodeLista := TBIXMLNode():New("LISTA")

	oXMLNodeLista:oAddChild(::oToXMLList("", KPI_MSG_RECEBIDA) )

	return oXMLNodeLista

// Lista XML para anexar ao pai
method oToXMLList(cParentID, nCommand) class TKPI004
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003) //"Assunto"
	oAttrib:lSet("CLA000", KPI_STRING)
	// Data
	oAttrib:lSet("TAG001", "DATAENV")
	oAttrib:lSet("CAB001", STR0004) //"Data Envio"
	oAttrib:lSet("CLA001", KPI_DATE)
	// Hora
	oAttrib:lSet("TAG002", "HORAENV")
	oAttrib:lSet("CAB002", STR0005) //"Hora Envio"
	oAttrib:lSet("CLA002", KPI_STRING)
	if(nCommand == 2) //Caixa de Entrada
		// Hora
		oAttrib:lSet("TAG003", "PRIORIDADE")
		oAttrib:lSet("CAB003", STR0006) //"Prioridade"
		oAttrib:lSet("CLA003", KPI_STRING)
	endif

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	// Gera recheio  
	oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
	if(nCommand == KPI_MSG_ENVIADA)
		::SetOrder(4)
		::cSQLFilter("PARENTID = '" + ::oOwner():foSecurity:oLoggedUser():cValue("ID") + "' AND PASTA = " + cBIStr(KPI_MSG_ENVIADA)) 
		::lFiltered(.t.)
		::_First()
		while(!::lEof())
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
			next
			oDestinatario:SetOrder(2)
			oDestinatario:lSeek(3, {::cValue("ID"), KPI_MSG_REMETENTE})
			oNode:oAddChild(TBIXMLNode():New("ID", oDestinatario:cValue("ID")))
			::_Next()
		end
		::cSQLFilter("")
	elseif(nCommand == KPI_MSG_RECEBIDA)
		oDestinatario:cSQLFilter("PESSID = '" + ::oOwner():foSecurity:oLoggedUser():cValue("ID") + "' AND PASTA = " + cBIStr(KPI_MSG_RECEBIDA) + " AND REMETENTE = " + cBIStr(KPI_MSG_DESTINATARIO)) 
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
		
			::lSeek(1,{oDestinatario:cValue("PARENTID")})

			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]=="PRIORIDADE")
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1],;
						if(aFields[nInd][2]==KPI_MSG_BAIXA, STR0007,; //Baixa
						if(aFields[nInd][2]==KPI_MSG_MEDIA, STR0008, STR0009)))) //Média / Alta
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif
			next
			oNode:oAddChild(TBIXMLNode():New("ID", oDestinatario:cValue("ID")))
	
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	elseif(nCommand == KPI_MSG_EXCLUIDA)
		oDestinatario:cSQLFilter("PESSID = '" + ::oOwner():foSecurity:oLoggedUser():cValue("ID") + "' AND PASTA = " + cBIStr(KPI_MSG_EXCLUIDA))
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
		
			::lSeek(1,{oDestinatario:cValue("PARENTID")})

			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"ID", "PARENTID"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]=="PRIORIDADE")
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1],;
						if(aFields[nInd][2]==KPI_MSG_BAIXA, STR0007,; //Baixa
						if(aFields[nInd][2]==KPI_MSG_MEDIA, STR0008, STR0009)))) //Média / Alta
				else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				endif
			next
			oNode:oAddChild(TBIXMLNode():New("ID", oDestinatario:cValue("ID")))
	
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif
return oXMLNode

// Carregar
method oToXMLNode(cDestID,cLoadCMD) class TKPI004
	local cID, aFields, nInd, oDestinatario
	local oXMLNode	:= TBIXMLNode():New(TAG_ENTITY)
	local cUserID	:=	""
	local oGrupo := ::oOwner():oGetTable("GRUPO")

	cID := "0"
	if(cBIStr(cLoadCMD) != "_BLANK")
		oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
		oDestinatario:lSeek(1,{cDestID})
		cID := oDestinatario:cValue("PARENTID")
		::lSeek(1, {cID})
    endif
    
	// Acrescenta os valores ao XML
	if(cBIStr(cLoadCMD) != "_BLANK")
		aFields := ::xRecord(RF_ARRAY,{"PASTA"})
	else
		aFields := ::xRecord(RF_ARRAY)
	endif

	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next   
	
	if(cBIStr(cLoadCMD) != "_BLANK")
		oXMLNode:oAddChild(TBIXMLNode():New("PASTA", oDestinatario:cValue("PASTA")))
	endif
                                        
	oPessoa := ::oOwner():oGetTable("USUARIO")    

	//Cria lista de remetentes
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")     
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM)
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0010) //Nome
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("RETORNA", .f.)
	
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("REMETENTES",,oAttrib))
	if(alltrim(cID)=="0")	
		//Se for envio de uma nova mensagem, o remetente e usuario logado.
		oPessoa :=	::oOwner():foSecurity:oLoggedUser()
	else
		//Se leitura de uma mensagem, e o usuario que enviou a mensagem.
		oPessoa:lSeek(1,{::cValue("PARENTID")})
	endif

	cUserID	:= oPessoa:cValue("ID")
		
	if(! oPessoa:lEof())
		oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
		oNode2:oAddChild(TBIXMLNode():New("ID", cUserID))
		oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))
		oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4))
		oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" ))
	endif

	//Cria lista de remetentes Auxiliar
	//Aqui retorna o usuario que esta logado.
	oPessoa :=	::oOwner():foSecurity:oLoggedUser()
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM)
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0010) //Nome
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("RETORNA", .f.)
	
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("REMS",,oAttrib))
	if(! oPessoa:lEof())
		oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
		oNode2:oAddChild(TBIXMLNode():New("ID", cUserID))
		oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))
		oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4))
		oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" ))
	endif

	//Cria lista de destinatarios Auxiliar
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM) 
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0010) //Nome
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("RETORNA", .f.)
	
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("DESTS",,oAttrib))

	oPessoa:cSQLFilter("ID != '" + cUserID + "' AND ID != '0'")

	oPessoa:lFiltered(.t.)
	oPessoa:_First()
	while(!oPessoa:lEof())                                                                                                          
        oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
		oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:cValue("ID")))
		oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))
		oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4))
		oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" ))
		oPessoa:_Next() 
	end
	oPessoa:cSQLFilter("")
	oGrupo:_First()
	while(!oGrupo:lEof())		
		if !(alltrim(oGrupo:cValue("ID")) == "0")
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("ID", oGrupo:cValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", oGrupo:cValue("NOME")))  
			oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 38))
			oNode2:oAddChild(TBIXMLNode():New("TIPO", "1" )) 
		endif	
		oGrupo:_Next()
	end			
	

	//Cria lista de pessoas não vinculadas ao usuário logado
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")  
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM)
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0010) //Nome
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("RETORNA", .f.)
	
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("PESSOAS",,oAttrib))
  	if(alltrim(cID)=="0")	
	   
		//Se for envio de uma nova mensagem, cria lista de destinatários com as pessoas não vinculadas ao usuário logado
		oPessoa:cSQLFilter("ID != '" + cUserID + "' AND ID != '0'")

		oPessoa:lFiltered(.t.)
		oPessoa:_First()
		while(!oPessoa:lEof()) 
				oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
				oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:cValue("ID")))
				oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))  
				oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4))
				oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" ))
			oPessoa:_Next()                                       			
		end
		oPessoa:cSQLFilter("")
		
		oGrupo:_First()
		while(!oGrupo:lEof())		
			if !(alltrim(oGrupo:cValue("ID")) == "0")
				oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
				oNode2:oAddChild(TBIXMLNode():New("ID", oGrupo:cValue("ID")))
				oNode2:oAddChild(TBIXMLNode():New("NOME", oGrupo:cValue("NOME")))  
				oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 38))
				oNode2:oAddChild(TBIXMLNode():New("TIPO", "1" )) 
			endif	
			oGrupo:_Next()
		end			
		
		
	else
		//Se leitura de uma mensagem, cria lista somente com as pessoas incluidas na pasta PARA e CC
		oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(cID) + "' AND (PARACC = '" + cBIStr(KPI_MSG_PARA) +;
								 "' OR PARACC = '" + cBIStr(KPI_MSG_CC) +;
								 "') AND REMETENTE = '" + cBIStr(KPI_MSG_DESTINATARIO)+"'")
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
			oPessoa:lSeek(1, {oDestinatario:cValue("PESSID")} )
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:cValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))   
			oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4)) 
			oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" )) 
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif

	//Cria lista de pessoas incluidas na lista de destinatários PARA
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")        
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM)
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0010) //Nome
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("RETORNA", .f.)   

	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("PARAS",,oAttrib))
	if(!(alltrim(cID)=="0"))
		//Se for envio de uma nova mensagem, cria lista de destinatários com as pessoas não vinculadas ao usuário logado
		oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(cID) + "' AND PARACC = '" + cBIStr(KPI_MSG_PARA) +;
								 "' AND REMETENTE = '" + cBIStr(KPI_MSG_DESTINATARIO)+"'")
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
			oPessoa:lSeek(1, {oDestinatario:cValue("PESSID")} )
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:cValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))    
			oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4))
			oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" )) 
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif
	
	//Cria lista de pessoas incluidas na lista de destinatários CC
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("TIPO", "PESSOA")     
	oAttrib:lSet("TAG000", "IMG_OWNER")
	oAttrib:lSet("CAB000", " ")
	oAttrib:lSet("CLA000", KPI_IMAGEM)
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0010) //"Nome"
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("RETORNA", .f.) 
	
	oNode1 := oXMLNode:oAddChild(TBIXMLNode():New("CCS",,oAttrib))
	if(!(alltrim(cID)=="0"))
		//Se for envio de uma nova mensagem, cria lista de destinatários com as pessoas não vinculadas ao usuário logado
		oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(cID) + "' AND PARACC = '" + cBIStr(KPI_MSG_CC) +;
								 "' AND REMETENTE = '" + cBIStr(KPI_MSG_DESTINATARIO)+"'")
		oDestinatario:lFiltered(.t.)
		oDestinatario:_First()
		while(!oDestinatario:lEof())
			oPessoa:lSeek(1,{oDestinatario:cValue("PESSID")})
			oNode2 := oNode1:oAddChild(TBIXMLNode():New("PESSOA"))
			oNode2:oAddChild(TBIXMLNode():New("ID", oPessoa:cValue("ID")))
			oNode2:oAddChild(TBIXMLNode():New("NOME", self:cMakeMailName(oPessoa)))
			oNode2:oAddChild(TBIXMLNode():New("IMG_OWNER", 4))
			oNode2:oAddChild(TBIXMLNode():New("TIPO", "0" )) 
			oDestinatario:_Next()
		end
		oDestinatario:cSQLFilter("")
	endif
	
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI004
	local oConexao 				:= ::oOwner():oGetTable("SMTPCONF")
	local oPessoas 				:= ::oOwner():oGetTable("USUARIO")
	local oGrupoUsu				:= ::oOwner():oGetTable("GRPUSUARIO")
	local lEnviarEmail 			:= .f.
	local i                  	:= 0
	local cServer           		:= ""
	local cPorta            		:= ""
	local cConta            		:= ""
	local cAutUsuario        	:= ""
	local cAutSenha           	:= ""
	local cTo 						:= ""
	local cAssunto				:= ""
	local cCorpo             	:= ""
	local cAnexos             	:= ""
	local cFrom               	:= ""
	local cCopia               	:= ""
	local aTo  					:= {}
	local aCopia 					:= {}
	local aFields               := {}
	local cUserID					:= ""    
	local cGrupoID				:= "" 
	Local cUsuarioSemEmail 		:= ""
	local nTotalDestinatarios 	:= 0  
	local nTotalEmails 			:= 0  // Receberá a quantidade de e-mails que serão destinatários e e-mails em cópia.    
	local nInd               	:= 0
	local nStatus 				:= KPI_ST_OK
	Local cProtocol				:= "0" // Por padrão não é utilizado nenhum protocolo.
		
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(aFields[nInd][1]=="DATAENV")
			aFields[nInd][2] := date()
		elseif(aFields[nInd][1]=="HORAENV")
			aFields[nInd][2] := time()
		elseif(aFields[nInd][1]=="PASTA")
			aFields[nInd][2] := KPI_MSG_ENVIADA
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		endif
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

	// Extrai e grava lista de destinatarios da lista PARA
	oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
	oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;	// ID
							{"PARENTID",  ::cValue("ID")},;	// ParentID 
							{"PESSID", ::cValue("PARENTID")},;	// ID do Remetente
							{"SITUACAO", 0},;					// Nula
							{"PASTA", KPI_MSG_ENVIADA},; 		// Enviada
							{"PARACC", 0},; 					// Nula
							{"REMETENTE", KPI_MSG_REMETENTE} })	// Remetent
							  					

	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PARAS"), "_PESSOA"))!="U")
		if(valtype(&("oXMLInput:"+cPath+":_PARAS:_PESSOA"))=="A")
			for nInd := 1 to len(&("oXMLInput:"+cPath+":_PARAS:_PESSOA"))
				//Verifica o tipo de registro 0.Usuario 1.Grupo
				if &("oXMLInput:"+cPath+":_PARAS:_PESSOA["+cBIStr(nInd)+"]:_TIPO:TEXT") == "1"
					cGrupoId := &("oXMLInput:"+cPath+":_PARAS:_PESSOA["+cBIStr(nInd)+"]:_ID:TEXT")

					oGrupoUsu:cSQLFilter("PARENTID = '" + cGrupoId + "' AND PARENTID != '0'")	
	
	   				oGrupoUsu:lFiltered(.t.)
					oGrupoUsu:_First()
					while(!oGrupoUsu:lEof())		
						cUserID := alltrim(oGrupoUsu:cValue("IDUSUARIO"))
						if !(cUserID == "0")                                          
							aadd(aTo, cUserID)
							oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
													{"PARENTID", ::cValue("ID")},;			// ParentID 
													{"PESSID", cUserID},;  					// ID do Destinatário
													{"SITUACAO", 2},; 				   		// Não Lida
													{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
													{"PARACC", KPI_MSG_PARA},;				// Para
													{"REMETENTE", KPI_MSG_DESTINATARIO} })	// 
						endif
					oGrupoUsu:_Next()	
					end	
					oGrupoUsu:cSQLFilter("")				
				else
					aPara := &("oXMLInput:"+cPath+":_PARAS:_PESSOA["+cBIStr(nInd)+"]")
					aadd(aTo, &("oXMLInput:"+cPath+":_PARAS:_PESSOA["+cBIStr(nInd)+"]:_ID:TEXT"))
					oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
											{"PARENTID", ::cValue("ID")},;			// ParentID 
											{"PESSID", cBIStr(aPara:_ID:TEXT)},;	// ID do Destinatário
											{"SITUACAO", 2},; 				   		// Não Lida
											{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
											{"PARACC", KPI_MSG_PARA},;				// Para
											{"REMETENTE", KPI_MSG_DESTINATARIO} })	// Destinatario
				endif
			next
		elseif(valtype(&("oXMLInput:"+cPath+":_PARAS:_PESSOA"))=="O")
			//Verifica o tipo de registro 0.Usuario 1.Grupo
			if &("oXMLInput:"+cPath+":_PARAS:_PESSOA:_TIPO:TEXT") == "1"
					cGrupoId := &("oXMLInput:"+cPath+":_PARAS:_PESSOA:_ID:TEXT")   
					
					oGrupoUsu:cSQLFilter("PARENTID = '" + cGrupoId + "' AND PARENTID != '0'")	

	   				oGrupoUsu:lFiltered(.t.)
					oGrupoUsu:_First()
					while(!oGrupoUsu:lEof())		
						cUserID := alltrim(oGrupoUsu:cValue("IDUSUARIO"))
						if !(cUserID == "0")  

							aadd(aTo, cUserID)
							oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
													{"PARENTID",  ::cValue("ID")},;		// ParentID 
													{"PESSID", cUserID},;					// ID do Destinatário
													{"SITUACAO", 2},; 						// Não Lida
													{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
													{"PARACC", KPI_MSG_PARA},;				// Para
													{"REMETENTE", KPI_MSG_DESTINATARIO} }) 	// Destinatario
						endif 
						oGrupoUsu:_Next()
					end
					oGrupoUsu:cSQLFilter("")
			else
				aPara := &("oXMLInput:"+cPath+":_PARAS:_PESSOA")
				aadd(aTo, &("oXMLInput:"+cPath+":_PARAS:_PESSOA:_ID:TEXT"))
				oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
										{"PARENTID",  ::cValue("ID")},;		// ParentID 
										{"PESSID", cBIStr(aPara:_ID:TEXT)},;	// ID do Destinatário
										{"SITUACAO", 2},; 						// Não Lida
										{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
										{"PARACC", KPI_MSG_PARA},;				// Para
										{"REMETENTE", KPI_MSG_DESTINATARIO} }) 	// Destinatario
			endif
		endif
	endif



	// Extrai e grava lista de destinatarios da lista CC
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_CCS"), "_PESSOA"))!="U")
		if(valtype(&("oXMLInput:"+cPath+":_CCS:_PESSOA"))=="A")
			for nInd := 1 to len(&("oXMLInput:"+cPath+":_CCS:_PESSOA"))
				//Verifica o tipo de registro 0.Usuario 1.Grupo
				if &("oXMLInput:"+cPath+":_CCS:_PESSOA["+cBIStr(nInd)+"]:_TIPO:TEXT") == "1"
					cGrupoId := &("oXMLInput:"+cPath+":_CCS:_PESSOA["+cBIStr(nInd)+"]:_ID:TEXT")

					oGrupoUsu:cSQLFilter("PARENTID = '" + cGrupoId + "' AND PARENTID != '0'")	
	   				
	   				oGrupoUsu:lFiltered(.t.)
					oGrupoUsu:_First()
					while(!oGrupoUsu:lEof())		
						cUserID := alltrim(oGrupoUsu:cValue("IDUSUARIO"))
						if !(cUserID == "0")                                          
							aadd(aTo, cUserID)
							oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
													{"PARENTID", ::cValue("ID")},;			// ParentID 
													{"PESSID", cUserID},;  					// ID do Destinatário
													{"SITUACAO", 2},; 				   		// Não Lida
													{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
													{"PARACC", KPI_MSG_CC},;				// CC
													{"REMETENTE", KPI_MSG_DESTINATARIO} })	// 
						endif
					oGrupoUsu:_Next()	
					end
					oGrupoUsu:cSQLFilter("")					
				
				else
					aCC := &("oXMLInput:"+cPath+":_CCS:_PESSOA["+cBIStr(nInd)+"]")
					aadd(aCopia, &("oXMLInput:"+cPath+":_CCS:_PESSOA["+cBIStr(nInd)+"]:_ID:TEXT"))
					oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
											{"PARENTID", ::cValue("ID")},;			// ParentID
											{"PESSID", cBIStr(aCC:_ID:TEXT)},;		// ID do Destinatário
											{"SITUACAO", 2},;						// Não Lida
											{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
											{"PARACC", KPI_MSG_CC},;				// CC
											{"REMETENTE", KPI_MSG_DESTINATARIO} }) 	// Destinatario
				endif
			next
		elseif(valtype(&("oXMLInput:"+cPath+":_CCS:_PESSOA"))=="O") 
			//Verifica o tipo de registro 0.Usuario 1.Grupo
			if &("oXMLInput:"+cPath+":_CCS:_PESSOA:_TIPO:TEXT") == "1"
					cGrupoId := &("oXMLInput:"+cPath+":_CCS:_PESSOA:_ID:TEXT")    

					oGrupoUsu:cSQLFilter("PARENTID = '" + cGrupoId + "' AND PARENTID != '0'")	
							
	   				oGrupoUsu:lFiltered(.t.)
					oGrupoUsu:_First()
					while(!oGrupoUsu:lEof())		
						cUserID := alltrim(oGrupoUsu:cValue("IDUSUARIO"))
						if !(cUserID == "0")  

							aadd(aTo, cUserID)
							oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
													{"PARENTID",  ::cValue("ID")},;		// ParentID 
													{"PESSID", cUserID},;					// ID do Destinatário
													{"SITUACAO", 2},; 						// Não Lida
													{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
													{"PARACC", KPI_MSG_CC},;				// CC
													{"REMETENTE", KPI_MSG_DESTINATARIO} }) 	// Destinatario
						endif 
						oGrupoUsu:_Next()
					end
					oGrupoUsu:cSQLFilter("")
			else
				aCC := &("oXMLInput:"+cPath+":_CCS:_PESSOA")
				aadd(aCopia, &("oXMLInput:"+cPath+":_CCS:_PESSOA:_ID:TEXT"))
				oDestinatario:lAppend({	{"ID", oDestinatario:cMakeID()},;		// ID
										{"PARENTID", ::cValue("ID")},;			// ParentID 
										{"PESSID", cBIStr(aCC:_ID:TEXT)},; 	// ID do Destinatário
										{"SITUACAO", 2},; 						// Não Lida
										{"PASTA", KPI_MSG_RECEBIDA},;			// Caixa de Entrada
										{"PARACC", KPI_MSG_CC},;				// CC
										{"REMETENTE", KPI_MSG_DESTINATARIO} }) 	// Destinatario
			endif
		endif
	endif

	if(nStatus==KPI_ST_OK)
		lEnviarEmail := if(xBIConvTo("L",oXMLInput:_REGISTROS:_MENSAGEM:_EMAIL:TEXT),.t.,.f.)
	endif
	if(lEnviarEmail .and. nStatus==KPI_ST_OK)
		//posiciona na configuração de email
		oConexao:cSQLFilter("ID = '"+cBIStr(1)+"'") // Filtra o ID 1 onde tem a configuracao SMTP
		oConexao:lFiltered(.t.)
		oConexao:_First()
		if(!::lEof() .and. !oConexao:lEof()) //posiciona cfg. da organização
			cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
			cPorta			:= alltrim(oConexao:cValue("PORTA"))
			cConta			:= alltrim(oConexao:cValue("NOME"))
			cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
			cAutSenha		:= alltrim(oConexao:cValue("SENHA"))
			cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))			

			// Inclusao do email dos Destinatarios.
			cTo := ""
			for i := 1 to len(aTo)
				if(oPessoas:lSeek(1, {aTo[i]}))  
				    If(!Empty(alltrim(oPessoas:cValue("EMAIL"))))
						cTo	+= if(empty(cTo),"",",")+alltrim(oPessoas:cValue("EMAIL"))    
						nTotalEmails++ 
					Else
						cUsuarioSemEmail += oPessoas:cValue("COMPNOME") + "<br>"
					EndIf	
				endif
			next

			// Inclusão dos e-mails em cópia.
			cCopia := ""
			for i := 1 to len(aCopia)
				if(oPessoas:lSeek(1, {aCopia[i]}))
				    If(!Empty(alltrim(oPessoas:cValue("EMAIL"))))
						cCopia	+= if(empty(cCopia),"",",")+alltrim(oPessoas:cValue("EMAIL"))    
						nTotalEmails++
					Else
						cUsuarioSemEmail += oPessoas:cValue("COMPNOME") + CRLF
					EndIf	
				endif
			next

			// Recebe a quantidade de destinatários + quantidade de e-mails em cópia.
        	nTotalDestinatarios := Len(aTo)+Len(aCopia)

			if(oPessoas:lSeek(1, {::cValue("PARENTID")}))
				cFrom:= alltrim(oPessoas:cValue("NOME"))+' <'+alltrim(oConexao:cValue("NOME"))+'>'
			endif
            
     
        	if(nTotalDestinatarios>=1)
				cCorpo 	:= alltrim(::cValue("TEXTO"))
				cAssunto	:= alltrim(::cValue("NOME"))
				cAnexos	:= ""
				oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, cCopia, "", cProtocol)
			EndIf	
		endif
		oConexao:cSQLFilter("") // Retira filtro.

	endif
	
	// Caso algum usuário destinatário não tenha e-mail vinculado entra nessa condição. 
	If ( nTotalDestinatarios > nTotalEmails )    
		// Alertar somente quando nenhum responsável puder ser notificado por e-mail.
		::fcMsg := "<html><body>"
	  	::fcMsg += STR0015 //"Os seguintes usuários não serão notificados via e-mail devido a falta de cadastro de endereço de e-mail:"
	  	::fcMsg += "<br>"  
	 	::fcMsg += "<br>"
	  	::fcMsg += cUsuarioSemEmail  
	  	::fcMsg += "</html></body>

	  	::flCanAlert := .T.
	EndIf              
return nStatus

// Delete mensagem da Caixa de Entrada / Itens Enviados / Itens excluidos
// O ID recebido sempre será do destinatário
method nDelFromXML(cID) class TKPI004
	local nStatus := KPI_ST_OK
	local oDestinatario, lRemetente, lExclui
	oDestinatario := ::oOwner():oGetTable("DESTINATARIO")
	//Posiciona ponteiro na tabela de Destinatarios KPI004A
	oDestinatario:lSeek(1,{cID})                
	//Posiciona ponteiro na tabela de Remetente KPI004
	::lSeek(1,{oDestinatario:cValue("PARENTID")})
	//Verifica se o cID solicitado é de remetente ou destinatário
	lRemetente := (oDestinatario:nValue("REMETENTE")==KPI_MSG_REMETENTE)

	if(lRemetente)
		if(::nValue("PASTA")==KPI_MSG_ENVIADA)
			::lUpdate({{"PASTA", KPI_MSG_EXCLUIDA}})
			oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(::cValue("ID")) + "' AND REMETENTE = '" + cBIStr(KPI_MSG_REMETENTE) + "'")
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof())
				oDestinatario:lUpdate({{"PASTA", KPI_MSG_EXCLUIDA}})
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")
		elseif(::nValue("PASTA")==KPI_MSG_EXCLUIDA)
			//Antes de verificar se a mensagem pode ser excluida definitivamente o registro corrente
			//deve ser enviado para a (Pasta = 4)
			::lUpdate({{"PASTA", KPI_MSG_DESCARTADA}})
			oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(::cValue("ID")) + "' AND REMETENTE = '" + cBIStr(KPI_MSG_REMETENTE) + "'")
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof())
				oDestinatario:lUpdate({{"PASTA", KPI_MSG_DESCARTADA}})
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")         

			//Verifica se todos os destinatarios excluiram a mensagem definitivamente (Pasta = 4),
			//caso todos tenham efetuado esta exclusão os registros referentes a esta mensagem
			//serão excluidos definitivamente da tabela KPI004 e KPI004A
			lExclui := .t.
			oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(::cValue("ID")) + "' AND REMETENTE = '" + cBIStr(KPI_MSG_DESTINATARIO) + "'")
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof() .and. lExclui)
			    lExclui := (oDestinatario:nValue("PASTA")==KPI_MSG_DESCARTADA)
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")
			
			if(lExclui)
				//Exclui da tabela de Destinatarios (KPI004A)
				oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(::cValue("ID")) + "'")
				oDestinatario:lFiltered(.t.)
				oDestinatario:_First()
				while(!oDestinatario:lEof())
					if(!oDestinatario:lDelete())
						nStatus := KPI_ST_INUSE
					endif
					oDestinatario:_Next()
				end
				oDestinatario:cSQLFilter("")
				//Exclui da tabela de Remetente (Mensagem original - KPI004)
				if(!::lDelete())
					nStatus := KPI_ST_INUSE
				endif
			endif
		endif
	else
		if(oDestinatario:nValue("PASTA")==KPI_MSG_RECEBIDA)
			oDestinatario:lUpdate({{"PASTA", KPI_MSG_EXCLUIDA}})
		elseif(oDestinatario:nValue("PASTA")==KPI_MSG_EXCLUIDA)
			//Antes de verificar se a mensagem pode ser excluida definitivamente o registro corrente
			//deve ser enviado para a (Pasta = 4)
			oDestinatario:lUpdate({{"PASTA", KPI_MSG_DESCARTADA}})

			//Verifica se todos os destinatarios e se o Remetente excluiram a mensagem definitivamente 
			//(Pasta = 4), caso todos tenham efetuado esta exclusão os registros referentes a esta mensagem
			//serão excluidos definitivamente da tabela KPI004 e KPI004A
			oDestinatario:SavePos()
			lExclui := .t.
			oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(oDestinatario:cValue("PARENTID")) + "' AND REMETENTE = '" + cBIStr(KPI_MSG_DESTINATARIO) + "'")
			oDestinatario:lFiltered(.t.)
			oDestinatario:_First()
			while(!oDestinatario:lEof() .and. lExclui)
			    lExclui := (oDestinatario:nValue("PASTA")==KPI_MSG_DESCARTADA)
				oDestinatario:_Next()
			end 
			oDestinatario:cSQLFilter("")
			oDestinatario:RestPos()              
			  
			//Verifica se o Remetente excluiu a mensagem definitivamente
			::lSeek(1,{oDestinatario:cValue("PARENTID")})
			lExclui := (::nValue("PASTA")==KPI_MSG_DESCARTADA)
			
			if(lExclui)
				//Exclui da tabela de Destinatarios (KPI004A)
				oDestinatario:cSQLFilter("PARENTID = '" + cBIStr(oDestinatario:cValue("PARENTID")) + "'")
				oDestinatario:lFiltered(.t.)
				oDestinatario:_First()
				while(!oDestinatario:lEof())
					if(!oDestinatario:lDelete())
						nStatus := KPI_ST_INUSE
					endif
					oDestinatario:_Next()
				end
				oDestinatario:cSQLFilter("")

				//Exclui da tabela de Remetente (Mensagem original - KPI004)
				if(!::lDelete())
					nStatus := KPI_ST_INUSE
				endif
			endif
		endif
	endif

return nStatus
       
/*
Monta o nome para mensagens da forma como deve ser exibido em tela.
@Param
	oPessoa (Objeto)
@Return
	cMailName (Caracter)
*/                    
Method cMakeMailName(oPessoa) class TKPI004
  	Local cMailName := '' 
    
    /*Compõe o nome de exibição da forma: Nome do Usuário (Login)*/ 	
  	cMailName := AllTrim(oPessoa:cValue('COMPNOME'))  + ' (' + AllTrim(oPessoa:cValue('NOME')) + ')'	
return cMailName

/*
*Classes para trabalhar com as Mensagens
*/
//Retorna um XML completo para Mensagens Enviadas
class TKPIMensagensEnviadas from TBIObject  
	method New() constructor
	method NewKPIMensagensEnviadas()

	// registro atual
	method oToXMLNode(cParentID, cLoadCmd) 
	


endclass

method New() class TKPIMensagensEnviadas
	::NewKPIMensagensEnviadas()
return

method NewKPIMensagensEnviadas() class TKPIMensagensEnviadas
	::NewObject()
return

method oToXMLNode(cParentID, cLoadCmd) class TKPIMensagensEnviadas
	local oXMLMsg
	
	oXMLMsg := TBIXMLNode():New("MENSAGENS_ENVIADAS")
	oXMLMsg:oAddChild(TBIXMLNode():New("ID", 1))
	oXMLMsg:oAddChild(TBIXMLNode():New("PARENTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("NOME", STR0011)) //"Itens Enviados"
	oXMLMsg:oAddChild(::oOwner():oGetTable("MENSAGEM"):oToXMLList(cParentID,1))
	
return oXMLMsg	        



//Retorna um XML completo para Mensagens Recebidas
class TKPIMensagensRecebidas from TBIObject  
	method New() constructor
	method NewKPIMensagensRecebidas()

	// registro atual
	method oToXMLNode(cParentID, cLoadCmd)

endclass

method New() class TKPIMensagensRecebidas
	::NewKPIMensagensRecebidas()
return

method NewKPIMensagensRecebidas() class TKPIMensagensRecebidas
	::NewObject()
return           

method oToXMLNode(cParentID, cLoadCmd) class TKPIMensagensRecebidas
	local oXMLMsg
	
	oXMLMsg := TBIXMLNode():New("MENSAGENS_RECEBIDAS")
	oXMLMsg:oAddChild(TBIXMLNode():New("ID", 1))
	oXMLMsg:oAddChild(TBIXMLNode():New("PARENTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("NOME", STR0012)) //"Caixa de Entrada"
	oXMLMsg:oAddChild(::oOwner():oGetTable("MENSAGEM"):oToXMLList(cParentID,2))
	
return oXMLMsg	

//Retorna um XML completo para Mensagens Excluidas
class TKPIMensagensExcluidas from TBIObject  
	method New() constructor
	method NewKPIMensagensExcluidas()

	// registro atual
	method oToXMLNode(cParentID, cLoadCmd)

endclass

method New() class TKPIMensagensExcluidas
	::NewKPIMensagensExcluidas()
return

method NewKPIMensagensExcluidas() class TKPIMensagensExcluidas
	::NewObject()
return

method oToXMLNode(cParentID, cLoadCmd) class TKPIMensagensExcluidas
	local oXMLMsg
	
	oXMLMsg := TBIXMLNode():New("MENSAGENS_EXCLUIDAS")
	oXMLMsg:oAddChild(TBIXMLNode():New("ID", 1))
	oXMLMsg:oAddChild(TBIXMLNode():New("PARENTID", 0))
	oXMLMsg:oAddChild(TBIXMLNode():New("NOME", STR0013)) //"Itens Excluidos"
	oXMLMsg:oAddChild(::oOwner():oGetTable("MENSAGEM"):oToXMLList(cParentID,3))
	
return oXMLMsg

function _KPI004_Msg()
return nil