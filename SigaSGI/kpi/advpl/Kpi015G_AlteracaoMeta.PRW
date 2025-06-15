// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI015G.PRW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 29.12.11 | Tiago Tudisco
// --------------------------------------------------------------------------------------
#Include "KPIDefs.ch"

#Include "KPI015G_AlteracaoMeta.ch"
#include "Fileio.ch"

#Define TAG_ENTITY "ALTERACAOMETA"
#Define TAG_GROUP  "ALTERACAOMETAS"
#Define TEXT_ENTITY STR0001		//###"Alteração de Meta"
#Define TEXT_GROUP  STR0002		//###"Alteração de Metas"

#Define INCLUSAO_META	"INSERTED"
#Define ALTERACAO_META	"CHANGED"
#Define EXCLUSAO_META	"DELETED"      

#Define ALVO			"1"
#Define PLANILHA		"2"

/*--------------------------------------------------------------------------------------
@class TKPI015G
@entity AlteracaoMeta
Alteracao Metas
@table KPI015G
--------------------------------------------------------------------------------------*/
Class TKPI015G From TBITable

	Data aIdJust	//ID das justificativas a serem enviadas por e-mail

	Method New() Constructor
	Method NewKPI015G()

	// Insere
	Method nInsFromXML(oXML, cPath)

	//montagem do e-mail
	Method lEMailJust(cIdJust)
	Method aIdRespInd(cUserID, cUserTipo)

	//Outros	
	Method clrIdJust() //Limpa o array com os ids das justificativas

EndClass


/*-------------------------------------------------------------------------------------------------------
*  CONSTRUTOR
*-------------------------------------------------------------------------------------------------------*/
Method New() Class TKPI015G
	::NewKPI015G()
Return
Method NewKPI015G() Class TKPI015G

	// Table
	::NewTable("SGI015G")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C", 010	))
	::addField(TBIField():New("INDIC_ID"	,"C", 010	))
	::addField(TBIField():New("DATADE"		,"C", 015	))
	::addField(TBIField():New("DATAATE"		,"C", 015	))
	::addField(TBIField():New("METAANT"		,"N", 019,06))
	::addField(TBIField():New("METAINF"		,"N", 019,06))
	::addField(TBIField():New("JUSTIFIC"	,"M"		))
	::addField(TBIField():New("TIPOJUST"	,"C", 001	)) //1 - ALVO; 2 - PLANILHA DE VALORES
	::addField(TBIField():New("TIPOALT"		,"C", 008	)) //DELETED; INSERTED; CHANGED
	::addField(TBIField():New("USUARIO"		,"C", 010	))
	::addField(TBIField():New("DATALANC"	,"D", 008	))
	::addField(TBIField():New("HORALANC"	,"C", 008	))

	// Indexes
	::addIndex(TBIIndex():New("SGI015GI01",{"ID"},.T.))
	::addIndex(TBIIndex():New("SGI015GI02",{"INDIC_ID"},.F.))
	::addIndex(TBIIndex():New("SGI015GI03",{"USUARIO"},.F.))

	::clrIdJust()

Return


/*-------------------------------------------------------------------------------------------------------
*  INSERE NOVA ENTIDADE
*-------------------------------------------------------------------------------------------------------*/
Method nInsFromXML(oXML) Class TKPI015G

	Local aFields		:=	{}
	Local aIndTend		:=	{}
	Local nInd			:=	0
	Local nStatus 		:=	KPI_ST_OK
	Local oUser			:= ::oOwner():foSecurity:oLoggedUser()
	Local cIdJust   

	Private oXMLInput	:= oXML

	aFields := ::xRecord(RF_ARRAY, {"ID","USUARIO","DATALANC","HORALANC"})

	// Extrai valores do XML
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
	Next

	If nStatus == KPI_ST_OK

		cIdJust := ::cMakeID()
		aAdd(aFields, {"ID"			, cIdJust})
		aAdd(aFields, {"USUARIO"	, oUser:cValue("ID")})
		aAdd(aFields, {"DATALANC"	, Date()})
		aAdd(aFields, {"HORALANC"	, Time()})

		// Grava
		If (!::lAppend(aFields))
			If (::nLastError() == DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			Else
				nStatus := KPI_ST_INUSE
			EndIf
		Else

			//adiciona na lista de envio de e-mail
			aAdd(::aIdJust,cIdJust)

		EndIf

	EndIf

Return nStatus            


Method lEmailJust() Class TKPI015G

	StartJob("eMailJust", GetEnvServer(), .F., {::aIdJust, ::oOwner():cKpiPath()})
    ::clrIdJust()

Return


/*-------------------------------------------------------------------------------------------------------
*	lEmailJust	- ENVIA E-MAIL AOS RESPONSAVEIS PELO INDICADOR ALTERADO
*	@param		- cIdJust: ID DA JUSTIFICATIVA A SER ENVIADA
*-------------------------------------------------------------------------------------------------------*/
Function eMailJust(aParms)

	Local lRet 			:= .T.
	Local nI
	Local oJust
	Local oConexao
	Local oIndicador
	Local oUsuarios
	Local cPathSite
	Local aUsuarios		:= {}
	Local cTipoMsg		
	Local cAssunto		:= ""
	Local cServer		:= ""
	Local cPorta		:= ""
	Local cConta		:= ""
	Local cAutUsuario	:= ""
	Local cAutSenha		:= ""
	Local cFrom			:= ""
	Local cTo			:= ""
	Local cCorpo		:= ""      
	Local cOculto		:= ""         
	Local aJustId		:= {}
	Local nJ                        
	Local aResponsaveisSemEmail := {}
	Local cProtocol	:= "0" // Por padrão não é utilizado nenhum protocolo.
    

	Private oKPICore    

	//Configuracoes do ambiente
	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	/*Instanciando KPICore*/
	oKPICore := TKPICore():New(aParms[2])
	ErrorBlock( {|oE| __KPIError(oE)})  

	/*Abre conexão*/
	If(oKPICore:nDBOpen() < 0)
		oKPICore:Log(STR0004, KPI_LOG_SCRFILE) //"Erro na abertura do banco de dados"

		Return .F.
	EndIf
                   
	oConexao	:= oKPICore:oGetTable("SMTPCONF")      
	oIndicador	:= oKPICore:oGetTable("INDICADOR")   
	oUsuarios	:= oKPICore:oGetTable("USUARIO")    
	oJust		:= oKPICore:oGetTable("ALTERACAOMETA")
	cPathSite	:= oKPICore:cKpiPath()+"imagens\"
             
             
	If (oConexao:lSeek(1,{cBIStr(1)})) //Filtra o ID 1 onde tem a configuracao SMTP

		cServer		:= Alltrim(oConexao:cValue("SERVIDOR"))
		cPorta			:= Alltrim(oConexao:cValue("PORTA"))
		cConta			:= Alltrim(oConexao:cValue("NOME"))
		cAutUsuario	:= Alltrim(oConexao:cValue("USUARIO"))
		cAutSenha		:= Alltrim(oConexao:cValue("SENHA"))
		cFrom			:= Alltrim(oConexao:cValue("NOME")) 
		cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))

		aJustId := aParms[1]
		For nJ := 1 To Len(aJustId)
	
			If !(oJust:lSeek(1,{aJustId[nJ]}))
				lRet := .F.
				Exit
		    EndIf   

			If nJ == 1
		   		
		   		If !(oIndicador:lSeek(1,{oJust:cValue("INDIC_ID")}))
					lRet := .F.
					Exit
				EndIf
				
				//Prepara quem vai receber o e-mail   
				If (oIndicador:cValue("TP_RESP") == TIPO_USUARIO)
					If oUsuarios:lSeek(1,{oIndicador:cValue("ID_RESP")}) .And. !Empty(oUsuarios:cValue("EMAIL"))
						cOculto += Alltrim(oUsuarios:cValue("EMAIL")) 
						lNotificaAdmin := .F.
					Else
					    aAdd(aResponsaveisSemEmail,oUsuarios:cValue("COMPNOME") )
				    EndIf 
				    
				Else
					aUsuarios := oJust:aIdRespInd(oIndicador:cValue("ID_RESP"), oIndicador:cValue("TP_RESP"))
					For nI := 1 To Len(aUsuarios)
					    If oUsuarios:lSeek(1,{aUsuarios[nI]}) .And. !Empty(oUsuarios:cValue("EMAIL"))
							cOculto += Alltrim(oUsuarios:cValue("EMAIL"))+';'     
						Else
					   	   aAdd(aResponsaveisSemEmail,oUsuarios:cValue("COMPNOME") ) 
					    EndIf
					Next                            
					cOculto := Substr(cOculto,1,Len(cOculto)-1)
				EndIf
			EndIf				
			
			oUsuarios:_First()
			While(!oUsuarios:lEof())
				If ( Upper(oUsuarios:cValue("ADMIN")) == 'T' .And. !Empty(oUsuarios:cValue("EMAIL")) )//verifica se o administrador tem email cadastrado
					cTo += Alltrim( oUsuarios:cValue( "EMAIL") ) + ','  
				EndIf        
				oUsuarios:_Next()
			EndDo

	       //notifica administradores caso os responsável(eis) não tenha(m) 
	       If( Len(aResponsaveisSemEmail) >= 1 )
			  
			  If( !Empty( alltrim(cTo)) )                                                                                                   
 			     cAssunto := "[SGI] - " + STR0022
				 cCorpo+="<table width='100%' border='0' cellpadding='0' cellspacing='0'><tr><td width='10%'>"
				 cCorpo+="<img src='art_logo_clie.sgi'>" 
				 cCorpo+="</td><td width='40%' style='color: #406496; font-weight: bold; font-size: 18px; font-family: Verdana, Arial, Helvetica, sans-serif;'>"
				 cCorpo+="<div align='center'>E-Mail de Notifica&ccedil;&atilde;o<br></br>"
				 cCorpo+="<span style='color: #666666; font-weight: bold; font-size: 14px; font-family: Verdana, Arial, Helvetica, sans-serif;'>"+STR0022+"</span>"
				 cCorpo+="</div></td><td width='10%'></td></tr></table>"
				 cCorpo+="<hr colspan='3' width='100%' size='3' noshade style='color: #000000;'/><tr><td colspan='4' align='left'>"
				 cCorpo+="<span style= 'font-size: 11px; font-family: Verdana, Arial, Helvetica, sans-serif;'>"
				 cCorpo+="<table width='100%' border='0' cellpadding='0' cellspacing='0'>"
				 cCorpo+="<tr><td width=5%></td><td width=90%><div>" + STR0023
				 cCorpo+="</div><ul>"
				 
				 for nI:=1 to Len(aResponsaveisSemEmail)
				 	if (!Empty( alltrim (aResponsaveisSemEmail[nI]) ))
				 	    cCorpo+="<li>" + aResponsaveisSemEmail[nI]                  
				 	EndIf    
				 Next
				 cCorpo+="</ul><div>"
				 cCorpo+=STR0024
				 cCorpo+="</div><br><div>"
				 cCorpo+=STR0025
				 cCorpo+="</div></td><td width=5%></td></tr></table></span>"
			     
			     cAnexos := cPathSite+"art_logo_clie.sgi"
			     
			     oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo,cAnexos, cFrom,/*cCopia*/"", cOculto, cProtocol)	   
			     
			     if( Empty ( alltrim(cOculto) ) )		     
				     Return .F.
				 EndIf    
			     
	          EndIf
	       EndIf

			Do	Case
	
				Case Alltrim(oJust:cValue("TIPOALT")) == INCLUSAO_META
	
					cAssunto := STR0003 /*//"Aviso de Inclusão de Meta no Indicador: "*/
					cTipoMsg := STR0007 /*//"Inclusao de Meta"*/
	
				Case Alltrim(oJust:cValue("TIPOALT")) == ALTERACAO_META
	
					cAssunto := STR0004 /*//"Aviso de Alteração de Meta no Indicador: "*/
				    cTipoMsg := STR0008/*//"Alteracao de Meta"*/
	
				Case Alltrim(oJust:cValue("TIPOALT")) == EXCLUSAO_META
	
					cAssunto := STR0005 /*//"Aviso de Exclusão de Meta no Indicador: "*/
					cTipoMsg := STR0009 /*//"Exclusao de Meta"*/
	
			EndCase    
	
			cAssunto += Alltrim(oIndicador:cValue("NOME"))
	
			cCorpo := "<table width='100%' border='0' cellpadding='0' cellspacing='0'>"
	
			cCorpo += "<tr>"
			cCorpo += "<td width='10%'><img src='art_logo_clie.sgi'></td>"
			cCorpo += "<td width='40%' style='color: #406496; font-weight: bold; font-size: 18px; font-family: Verdana, Arial, Helvetica, sans-serif;'><div align='center'>"+KPIEncode(STR0006)+"<br></br>" //E-Mail de Notificacao
			cCorpo += "<span style='color: #666666; font-weight: bold; font-size: 14px; font-family: Verdana, Arial, Helvetica, sans-serif;'>"+KPIEncode(cTipoMsg)+"</span></div></td>"
			cCorpo += "<td width='10%'></td>"
			cCorpo += "</tr>"
				
			cCorpo += "</table>"
			
			cCorpo += "<table width='100%' cellpadding='0' cellspacing='0'>"
				              
			cCorpo += "<hr colspan='3' width='100%' size='3' noshade style='color: #000000;'/>"
	
			cCorpo += "<tr>"
			cCorpo += "<td colspan='4' align='left'></td>"
			cCorpo += "</tr>"
					
			cCorpo += "<tr>"
			cCorpo += "<td width='05%' height='30'></td>"
			cCorpo += "<td width='15%' height='30'></br><strong>"+KPIEncode(STR0010)+"</strong></td>" //Indicador:
			cCorpo += "<td width='80%' height='30' colspan='2'></br>"+Alltrim(oIndicador:cValue("NOME"))+"</td>"
			cCorpo += "</tr>"
		
			cCorpo += "<tr>"
			cCorpo += "<td width='05%' height='30'></td>"
			cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0011)+"</strong></td>" //Meta Anterior:
			cCorpo += "<td width='80%' height='30'>"+Transform(val(oJust:cValue("METAANT")),('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9')))+"</td>"
			cCorpo += "</tr>"
	
			cCorpo += "<tr>"
			cCorpo += "<td width='05%' height='30'></td>"
			cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0012)+"</strong></td>" //Meta Informada:
			cCorpo += "<td width='80%' height='30'>"+Transform(val(oJust:cValue("METAINF")),('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9')))+"</td>"
			cCorpo += "</tr>"
		          
		    If !Empty(oJust:cValue("DATADE")) .And. Empty(oJust:cValue("DATAATE"))

				cCorpo += "<tr>"
				cCorpo += "<td width='05%' height='30'></td>"
				cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0021)+"</strong></td>" //Periodo:
				cCorpo += "<td width='80%' height='30'>"+oJust:cValue("DATADE")+"</td>"
				cCorpo += "</tr>"       
		                       
			ElseIf !Empty(oJust:dValue("DATADE")) .And. !Empty(oJust:dValue("DATAATE"))
				cCorpo += "<tr>"
				cCorpo += "<td width='05%' height='30'></td>"
				cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0013)+"</strong></td>" //Periodo De:
				cCorpo += "<td width='80%' height='30'>"+dToC(oJust:dValue("DATADE"))+"</td>"
				cCorpo += "</tr>"       
			
				cCorpo += "<tr>"
				cCorpo += "<td width='05%' height='30'></td>"
				cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0014)+"</strong></td>" //Periodo Ate:
				cCorpo += "<td width='80%' height='30'>"+dToC(oJust:dValue("DATAATE"))+"</td>"
				cCorpo += "</tr>"
	        EndIf
						
			cCorpo += "<tr>"
			cCorpo += "<td height='10' colspan='4'>"
			cCorpo += "</tr>"
			
			cCorpo += "<tr>"
			cCorpo += "<td width='05%' height='30'></td>"
			cCorpo += "<td width='15%' valign='top'><strong>"+KPIEncode(STR0015)+"</strong></td>" //Justificativa da Alteracao:
			cCorpo += "<td width='70%' colspan='2' valign='top'>"+oJust:cValue("JUSTIFIC")+"</td>"
			cCorpo += "<td width='10'/>"
			cCorpo += "</tr>"
	
			cCorpo += "<tr>"
			cCorpo += "<td height='30' colspan='4'>"
			cCorpo += "</tr>"
			                    
			If (oJust:cValue("TIPOJUST") == ALVO .And. oJust:cValue("METAINF") == "0")			                  
				cCorpo += "<tr>"
				cCorpo += "<td height='10' colspan='3'>"
				cCorpo += "</tr>"
				
				cCorpo += "<tr>"
				cCorpo += "<td width='05%' height='30'></td>"
				cCorpo += "<td width='15%' height='30'><strong>"+KPIEncode(STR0019)+"</strong></td>" //Observacao:
				cCorpo += "<td width='80%' height='30' colspan='2'>"+KPIEncode(STR0018)+"</td>" //O valor do Alvo foi alterado para zero, desta forma a Planilha de Valores passa a ser considerada.
				cCorpo += "</tr>"
			EndIf		                    
			                                     
			cCorpo += "</table>"
			              
			cCorpo += "<table width='100%' cellpadding='0' cellspacing='0'>"
	
			cCorpo += "<hr width='100%' size='1' noshade style='color: #000000;'/>"
	
			cCorpo += "<tr>"
			cCorpo += "<td width='20%' colspan='3' align='center' style='color: #666666; font-weight: bold; font-size: 14px; font-family: Verdana, Arial, Helvetica, sans-serif;'>"+KPIEncode(STR0020)+"</td>"//Responsável pela Modificação
			cCorpo += "</tr>"
		
			cCorpo += "<tr>"
			cCorpo += "<td height='10' colspan='3'/>"
			cCorpo += "</tr>"
	                     
			cCorpo += "<tr>"
			cCorpo += "<td colspan='3' align='left'></td>"
			cCorpo += "</tr>"
	
			cCorpo += "<tr>"
			cCorpo += "<td width='05%' height='30'></td>"
			cCorpo += "<td width='15%'><strong>"+KPIEncode(STR0016)+"</strong></td>" //Usuario:
	
			If (oUsuarios:lSeek(1,{oJust:cValue("USUARIO")}))
				cCorpo += "<td width='80%'>"+Alltrim(oUsuarios:cValue("COMPNOME"))+"</td>"
	        Else
				cCorpo += "<td width='80%'> </td>"
	        EndIf                       
	        
	        cCorpo += "</tr>"
	        
	        cCorpo += "<tr>"
	   		cCorpo += "<td width='05%' height='30'></td>"
			cCorpo += "<td width='15%'><strong>"+KPIEncode(STR0017)+"</strong></td>" //Data/Hora
			cCorpo += "<td width='80%'>"+dToC(oJust:dValue("DATALANC"))+" - "+oJust:cValue("HORALANC")+"</td>"
			cCorpo += "</tr>"
						
			cCorpo += "</table>"
                                                                                
			cAnexos := cPathSite+"art_logo_clie.sgi"
			oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cCorpo, cAnexos, cFrom, /*cCopia*/ "", cOculto, cProtocol)	
	
		Next
	Else
		lRet := .F.
	EndIf		
		
Return lRet


/*-------------------------------------------------------------------------------------------------------
*	respInd	- Retorno o(s) usuario(s) responsavel(is) pelo indicador
*	@Param	- cUserID:	ID do usuario ou do grupo responsavel pelo indicador
*	@Param	- cUserTipo:Tipo de responsavel pelo indicador (Usuario ou Grupo de Usuarios)
*-------------------------------------------------------------------------------------------------------*/
Method aIdRespInd(cUserID, cUserTipo) Class TKPI015G
	
	Local aRet	:= {}
	Local oGrupoUser:= ::oOwner():oGetTable("GRPUSUARIO")
	
	If cUserTipo == TIPO_USUARIO
		aRet := aAdd(aRet,cUserId) //ID do Usuario
	ElseIf cUserTipo == TIPO_GRUPO
		aRet := oGrupoUser:aUsersByGroup(cUserID) //ID do Grupo
	EndIf
	
Return aRet


/*-------------------------------------------------------------------------------------------------------
*	Limpa o array com os ids das justificativas
*-------------------------------------------------------------------------------------------------------*/
Method clrIdJust() Class TKPI015G

	::aIdJust := {}

Return