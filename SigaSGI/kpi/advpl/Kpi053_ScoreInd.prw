// ######################################################################################
// Projeto: KPI
// Modulo : Relatório de Scorecards e Indicadores
// Fonte  : KPI053_ScoreInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 11.01.06 | 2487 Eduardo Konigami Miyoshi
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI053_ScoreInd.ch"

/*--------------------------------------------------------------------------------------
@class TKPI053
@entity RelScoreInd
Relatório Scorecards e Indicadores
@table KPI053
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELSCOREIND"
#define TAG_GROUP  "RELSCOREINDS"
#define TEXT_ENTITY STR0001/*//"Relatório de Scorecard e Indicador"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Scorecards e Indicadores"*/

class TKPI053 from TBITable
	method New() constructor
	method NewKPI053()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLStatus()
	method oXMLTipoImprimir()

	// registro atual
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	
	// executar 
	method nExecute(cID, cExecCMD)
endclass

method New() class TKPI053
	::NewKPI053()
return
method NewKPI053() class TKPI053
	
	// Table
	::NewTable("SGI053")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"C", 10))
	::addField(TBIField():New("PARENTID",	"C", 10))
	::addField(TBIField():New("NOME",		"C", 60))
	::addField(TBIField():New("DESCRICAO",	"C", 255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	::addField(TBIField():New("SCORE_DE",	"C", 10))
	::addField(TBIField():New("SCORE_ATE",	"C", 10))
    ::addField(TBIField():New("LISTAIND",	"L"))
    

	// Indexes
	::addIndex(TBIIndex():New("SGI053I01",	{"ID"},		.t.))
	
return

// Arvore
method oArvore(nParentID) class TKPI053
	local oXMLArvore, oNode
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
	::SetOrder(1) // Por ordem de ID
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "1")
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", STR0051 + cTextScor + STR0052) //"Relatórios de "###" e Indicadores"
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TKPI053
	local aFields, oNode, oAttrib, oXMLNode, nInd
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0049 + cTextScor + STR0050)	//"Relatório de "###" e Indicador"*/
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de Nome
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","DESCRICAO","IMPDESC","SCORE_DE","SCORE_ATE","LISTAIND"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TKPI053
	local aFields, nInd, nStatus := KPI_ST_OK
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	::SetOrder(1) // Por ordem de ID
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::cMakeID()}}))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif

	if nStatus == KPI_ST_OK
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY,{})
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			if(aFields[nInd][1] == "ID")
				nID := aFields[nInd][2]
			endif	
		next
	endif
	
	//Indica se o usuario logado e administrador.
	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN", ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")))

	// Acrescenta children
	//TIPOACAO: 1-Indicador, 2-Projeto
	oXMLNode:oAddChild(::oOwner():oGetTable("USUARIO"):oToXMLList(.T.))
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.t.))
	
return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI053
	local nStatus := KPI_ST_OK,	nID, nInd, oTable, cNome
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif
	next

	// Verifica condições de gravação (append ou update)
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("ID = '"+cBIStr(nID)+"'") // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::cMakeID()}, {"PARENTID", nParentID} }))
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
	::cSQLFilter("")
return nStatus

// Execute
method nExecute(cID, cExecCMD) class TKPI053
	local aParms := {} 
	local cPathSite	:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	private nStatus := KPI_ST_OK
	if(::lSeek(1, {cID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))
		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))
		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))
		// 4 - Scorecard de
		aAdd(aParms, ::cValue("SCORE_DE"))
		// 5 - Scorecard ate
		aAdd(aParms, ::cValue("SCORE_ATE"))
		// 6 - Listar Indicadores?
		aAdd(aParms, ::lValue("LISTAIND"))
		// 7 - ID do Relatório
		aAdd(aParms, ::cValue("ID"))
		// 8 - KPIPATH da Working THREAD
		aAdd(aParms, ::oOwner():cKpiPath())
		// 9 - Nome do arquivo que sera salvo
		aAdd(aParms,cExecCMD )
		// 10 - Diretorio do site.
		aAdd(aParms, strtran(cPathSite,"\","/"))

		// Executando JOB
		//StartJob("KPIScoreIndJob", GetEnvServer(), .f., aParms)
		nStatus := KPIScoreIndJob(aParms)
		if(nStatus == KPI_ST_OK)
			::fcMsg := STR0041
		elseif(nStatus == KPI_ST_GENERALERROR)
			::fcMsg := STR0042
		endif
	else

		nStatus := 	KPI_ST_BADID

	endif

return nStatus

// Funcao executa o job
function KPIScoreIndJob(aParms)
	local nRegistros := 0, aUsuarios := {}, nUsu:=0
	local cNome, cDescricao, lImpDesc, cScoreDe, cScoreAte
	local lListInd, cKpiPath, cReportName, cId, cSitePath 
	local cIdGrupo := ""
	local	cIdDe		:= ''
	local 	cIdAte 		:= ''
	local   aIdParam	:= Array(2)
	local 	cFilter		:= ""
	local	oIndicador  := oKPICore:oGetTable("INDICADOR") 	
	local 	oUnidade 	:= oKPICore:oGetTable("UNIDADE") 	
	local 	oUsuario 	:= oKPICore:oGetTable("USUARIO")	
	local 	oGrupo 		:= oKPICore:oGetTable("GRUPO_IND")	
	local 	oScorxUser	:= oKPICore:oGetTable("SCOR_X_USER") 
	local	cHierarq
	local cTipoAtu	:= STR0045 // "Vazio"
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
	private	oScorecard 	:= oKPICore:oGetTable("SCORECARD")

	oParametro 	:= oKPICore:oGetTable("PARAMETRO")
     
    // Coleta os parametros
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao 	:= aParms[2]
	// 3 - Imprime Descrição?
	lImpDesc	:= aParms[3]
	// 4 - Scorecard de
	cScoreDe	:= alltrim(aParms[4])
	// 5 - Scorecard ate
	cScoreAte	:= alltrim(aParms[5])
	// 6 - Listar Indicadores?
	lListInd	:= aParms[6]
	// 7 - ID do Relatório
	cId			:= alltrim(aParms[7])
	// 8 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[8]
	// 9 - Nome do arquivo que sera salvo, nome do userDe e nome do userAte
	cReportName := aParms[9]
	// 10 - Diretório do site
    cSitePath	:= aParms[10]
    
	oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL053_" + alltrim(cID) + ".html")

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0004 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL053_"*/
		oKPICore:Log(STR0005, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return KPI_ST_GENERALERROR
	endif
		

	cCorScoreInd 	:= "#C6E2FF" //cor da tabela de scorecards
	cCorCabecalho	:= "#aca6d2" //cor dos cabeçalhos
	cCorResp		:= "#d3d1e9" //cor dos resultados
	
	//Coleta os ID's
	if(oScorecard:lSeek(1, {cScoreDe}))
		aIdParam[1] := alltrim(oScorecard:cValue("ID"))
	endif 	
	if(oScorecard:lSeek(1, {cScoreAte}))
		aIdParam[2] := alltrim(oScorecard:cValue("ID"))
	endif
	 
	 //Verifica qual dos ID's eh o menor
	 cIdDe  := iif(aIdParam[1]<aIdParam[2],aIdParam[1],aIdParam[2])
	 cIdAte := iif(aIdParam[2]>aIdParam[1],aIdParam[2],aIdParam[1])

    //Monta o Filtro
	if (!empty(cIdDe) .and. !empty(cIdAte) .and. alltrim(cIdDe) == alltrim(cIdAte))
		cFilter := "ID = '"+cIdDe+"' "
	elseif(!empty(cIdDe) .and. !empty(cIdAte))
		cFilter := "ID>='"+cIdDe+"' AND ID<='"+cIdAte+"'"
	elseif(empty(cIdDe) .and. !empty(cIdAte))
		cFilter := "ID<='"+cIdAte+"'"
	elseif(!empty(cIdDe) .and. empty(cIdAte))
		cFilter := "ID>='"+cIdDe+"'"
	endif                        


	oScorecard:setOrder(4)
	if(! empty(cFilter))
		oScorecard:cSQLFilter(cFilter)
		oScorecard:lFiltered(.t.)
	endif		

	oScorecard:_First()
	
	// Montagem do cabeçalho do relatório
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('	<title>' + KPIEncode( STR0049 + cTextScor + STR0052 ) + '</title>') //"Relatório de "###" e Indicadores"
	oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')     
	
	oHtmFile:nWriteLN('<meta http-equiv="Pragma" content="no-cache">')
	oHtmFile:nWriteLN('<meta http-equiv="expires" content="0">')

    oHtmFile:nWriteLN('<link href="'+cSitePath+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	oHtmFile:nWriteLN('</head>')
	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	
	while(!oScorecard:lEof())   
	
		if(oScorecard:nValue("ID") != 0)
		
			nRegistros++  
			
			//Cabeçalho do relatório
			if(nRegistros==1)
	
				oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0">')
				
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td>')
				oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela">')
				                     
				
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td class="tdlogo"><img class="imglogo" src="'+cSitePath+'imagens/art_logo_clie.sgi"></td>')
				oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0049 + cTextScor + STR0052) + '<br><br>') //"Relatório de "###" e Indicadores"
				if(lImpDesc)
					oHtmFile:nWriteLN('<span class="texto">'+ KPIEncode(cDescricao) +'</span> </div></td>')
				endif	 							
				oHtmFile:nWriteLN('	<td width="150" align="right" class="texto">'+KPIEncode(STR0043)+ dtoc(date()) + '</td>')
				oHtmFile:nWriteLN('</tr>') 

				oHtmFile:nWriteLN('</table>')								           
								
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')							
				oHtmFile:nWriteLN('<tr>') 				
				oHtmFile:nWriteLN('<td>&nbsp;</td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('</table>')
			    
			    lCabecalho := .T.  
			    
			endif

			oHtmFile:nWriteLN('<table width="70%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
	      	oHtmFile:nWriteLN('<tr>')

			//PEGA A HIERARQUIA A SER EXIBIDA - CASO SEJA VAZIA, FICA A PADRAO
			cHierarq := oScorecard:cGetScoreName(oScoreCard:cValue("ID"))
            
			If oParametro:getValue("MODO_ANALISE") == ANALISE_BSC           
		        oHtmFile:nWriteLN('<td ColSpan="2" class="cabecalho_1">'+cHierarq+'</td>')
	   		Else
		        oHtmFile:nWriteLN('<td width="23%" class="cabecalho_1">'+KPIEncode(cTextScor)+'</td>')
		        oHtmFile:nWriteLN('<td width="77%" class="cabecalho_1">	'+cHierarq+'</td>')
			EndIf

	      	oHtmFile:nWriteLN('</tr>')
	      	oHtmFile:nWriteLN('<tr>')
	        oHtmFile:nWriteLN('<td width="23%" class="cabecalho_2"><strong>'+KPIEncode(STR0009)+'</strong></td>')
	        oHtmFile:nWriteLN('<td width="77%" class="texto">'+KPIEncode(alltrim(oScorecard:cValue("DESCRICAO")))+'</td>')
	      	oHtmFile:nWriteLN('</tr>')
	      	oHtmFile:nWriteLN('<tr>')
	        oHtmFile:nWriteLN('<td class="cabecalho_2"><strong>'+KPIEncode(STR0010)+'</strong></td>')
			if(oUsuario:lSeek(1, {alltrim(oScorecard:cValue("RESPID"))}))
			       oHtmFile:nWriteLN('<td class="texto">'+KPIEncode(alltrim(oUsuario:cValue("NOME")))+'</td>')
			endif
			aUsuarios := oScorxUser:aUsuxScor(oScorecard:cValue("ID"))
			if(len(aUsuarios)>0)
		      	oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td class="cabecalho_2"><strong>'+KPIEncode(STR0044)+'</strong></td>') //"Usuários autorizados"
				oHtmFile:nWriteLN('<td class="texto">')
				for nUsu:=1 to len(aUsuarios)
					oHtmFile:nWriteLN(if(nUsu>1,", ","")+alltrim(aUsuarios[nUsu][2]))
				next
				oHtmFile:nWriteLN('</td>')
		      	oHtmFile:nWriteLN('</tr>')
			endif
	
		    oHtmFile:nWriteLN('</tr>')

		    oHtmFile:nWriteLN('</table>')
	
			if(lListInd)
				oIndicador:setOrder(5)
				oIndicador:cSQLFilter("ID_SCOREC='" + oScorecard:cValue("ID") + "'")
				oIndicador:lFiltered(.t.)
				oIndicador:_First() 
				
				if(!oIndicador:lEof())	
				    oHtmFile:nWriteLN('<table width="70%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
				    oHtmFile:nWriteLN('<tr align="center">')
			        oHtmFile:nWriteLN('<td width="105%" class="cabecalho_3"><br>')    
			        
					while(!oIndicador:lEof())   
					
						oHtmFile:nWriteLN('<br>')
				        oHtmFile:nWriteLN('<br>')
				        
				        oHtmFile:nWriteLN('<table width="90%" border="0" cellpadding="0" cellspacing="0" class="tabela">')
				        
				        oHtmFile:nWriteLN('<tr>')
	            		oHtmFile:nWriteLN('	<td width="15%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0012)+'</strong> </td>')
			            oHtmFile:nWriteLN('	<td width="85%" colspan="3" align="left" class="texto">'+KPIEncode(alltrim(oIndicador:cValue("NOME")))+'</td>')
	        			oHtmFile:nWriteLN('</tr>') 
	        			
			            oHtmFile:nWriteLN('<tr>')
	        		    oHtmFile:nWriteLN('	<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0013)+'</strong> </td>')
			            oHtmFile:nWriteLN('	<td width="80%" colspan="3" align="left" class="texto">'+KPIEncode(alltrim(oIndicador:cValue("DESCRICAO"))) +'</td>')
	        		    oHtmFile:nWriteLN('</tr>') 
	        		      
	        		    //TODO - Internacionalizar.	        		    
	        		    oHtmFile:nWriteLN('<tr>')
	        		    oHtmFile:nWriteLN('	<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode("Método de Verificação:")+'</strong> </td>')
			            oHtmFile:nWriteLN('	<td width="80%" colspan="3" align="left" class="texto">'+KPIEncode(alltrim(oIndicador:cValue("VERIFICA"))) +'</td>')
	        		    oHtmFile:nWriteLN('</tr>') 
	        		                  
	        		    
			            oHtmFile:nWriteLN('<tr> ')
	        		    oHtmFile:nWriteLN('	<td width="20%" align="left" nowrap class="cabecalho_4"><strong>'+KPIEncode(STR0014)+'</strong> </td> ')
				  		oIndicador:savePos()  
					  	if (! alltrim(oIndicador:cValue("ID_INDICA")) == "") .and. (oIndicador:lSeek(1, {oIndicador:cValue("ID_INDICA")}))
			              	oHtmFile:nWriteLN('	<td width="80%" colspan="3" align="left" class="texto">'+ KPIEncode(alltrim(oIndicador:cValue("NOME")))+'</td> ')
					  	else
			              	oHtmFile:nWriteLN('	<td width="80%" colspan="3" align="left" class="texto">&nbsp;</td> ')				  	
					  	endif   
						oIndicador:restPos()   
			            oHtmFile:nWriteLN('</tr> ')
			                             
			            
			            oHtmFile:nWriteLN('<tr>')			            
			            oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0015)+'</strong> </td>')
						if(oIndicador:lValue("ASCEND"))
				            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(STR0026)+'&nbsp; </td>')
						else
				            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(STR0027)+'&nbsp; </td>')	
						endif      						
			            oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0016)+'</strong> </td>')
			            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(alltrim(oIndicador:cValue("DECIMAIS")))+'&nbsp; &nbsp; </td>')
						oHtmFile:nWriteLN('</tr>')
						 
						 // Tipo de atualização do indicador.
						If oIndicador:cValue("TIPO_ATU") == "1"
							cTipoAtu := STR0046 // "Manual"
						ElseIf oIndicador:cValue("TIPO_ATU") == "2"
							cTipoAtu := STR0047 // "Via planilha"
						ElseIf oIndicador:cValue("TIPO_ATU") == "3"
							cTipoAtu := STR0048 // "Via fonte de dados"
						EndIf						 

						 oHtmFile:nWriteLN('<tr>')
	        		    oHtmFile:nWriteLN('	<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode("Tipo de Atualização: ")+'</strong> </td>')
			            oHtmFile:nWriteLN('	<td width="80%" colspan="3" align="left" class="texto">'+KPIEncode(cTipoAtu) +'</td>')
	        		    oHtmFile:nWriteLN('</tr>') 
						               
						
			            oHtmFile:nWriteLN('<tr> ') 			            
			            oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0017)+'</strong> </td> ')
						if(oUnidade:lSeek(1, {alltrim(oIndicador:cValue("UNIDADE"))}))
						    oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(oUnidade:cValue("NOME"))+'&nbsp; </td> ')
						else
						    oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">&nbsp; </td> ')			 
						endif       
		                oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0018)+'</strong> </td> ')
		                oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(oIndicador:cGetFreqName(oIndicador:nValue("FREQ")))+'&nbsp; </td> ')
		                oHtmFile:nWriteLN('</tr> ')  


		            	oHtmFile:nWriteLN('<tr>') 
			            oHtmFile:nWriteLN('	<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0019)+'</strong> </td>')
						cIdGrupo := alltrim(oIndicador:cValue("ID_GRUPO"))						
						if ! empty(cIdGrupo) .and. (oGrupo:lSeek(1, {cIdGrupo}))
				            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode( alltrim( oGrupo:cValue("NOME") ) )+'&nbsp; </td>')
						else
				            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">&nbsp;  </td>')	
						endif    						  
						//TODO - Internacionalizar.
			            oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode("Peso:")+'</strong> </td>')
			            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(alltrim(oIndicador:cValue("PESO")))+'&nbsp; &nbsp; </td>')
						oHtmFile:nWriteLN('</tr>') 
						
	
		            	oHtmFile:nWriteLN('<tr>')
		              	oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0020)+'</strong> </td>')
			            oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(oIndicador:cGetAcumName(oIndicador:nValue("ACUM_TIPO")))+'&nbsp; </td>')
			            oHtmFile:nWriteLN('<td width="20%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0021)+'</strong> </td>')
					   	if(oIndicador:lValue("VISIVEL"))
				          oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(STR0039)+'&nbsp; </td>')
						else
				          oHtmFile:nWriteLN('<td width="30%" align="left" class="texto">'+KPIEncode(STR0040)+'&nbsp; </td>')
						endif							  
		     	        oHtmFile:nWriteLN('</tr>')  
		     	                                  
		     	        
		            	oHtmFile:nWriteLN('<tr>')
		                oHtmFile:nWriteLN('<td width="15%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0022)+'</strong> </td>')
		                oHtmFile:nWriteLN('<td width="85%" colspan="3" align="left" class="texto">'+KPIEncode(alltrim(oIndicador:cValue("ID_CODCLI")))+'&nbsp;  </td>')
		                oHtmFile:nWriteLN('</tr>')
		                                          
		                
		                oHtmFile:nWriteLN('<tr>')
		                oHtmFile:nWriteLN('<td width="15%" align="left" class="cabecalho_4"><strong>'+KPIEncode(STR0023)+'</strong> </td>')
		                /*Identifica se o indicador é proprietário*/
		                If(oIndicador:lValue("ISPRIVATE"))        
		                	/*Exibe a descrição do fórmula do indicador.*/
		                	oHtmFile:nWriteLN('<td width="85%" colspan="3" align="left" class="texto">'+KPIEncode( AllTrim(oIndicador:cValue("DESCFORMU")) )+'&nbsp;  </td>')
						Else  
							/*Exibe a expressão da fórmula do indicador.*/
							oHtmFile:nWriteLN('<td width="85%" colspan="3" align="left" class="texto">'+KPIEncode(oIndicador:cRetFormula(oIndicador:cValue("FORMULA")))+'&nbsp;  </td>')
						EndIf						
						oHtmFile:nWriteLN()
		                oHtmFile:nWriteLN('</tr>') 
		                
			          		oHtmFile:nWriteLN('</table>')	
						oIndicador:_next()
					enddo
					oHtmFile:nWriteLN('	<br>')
					oHtmFile:nWriteLN('	<br>')
					oHtmFile:nWriteLN('	<p>&nbsp;</p></td>')
					oHtmFile:nWriteLN('	</tr>')
					oHtmFile:nWriteLN('	</table>')
					oHtmFile:nWriteLN('	<br>')
					oHtmFile:nWriteLN('	<br>')
				endif
			endif
			oHtmFile:nWriteLN('	<tr>')
			oHtmFile:nWriteLN('		<td>&nbsp;')
			oHtmFile:nWriteLN('		</td>')
			oHtmFile:nWriteLN('	</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<br><br>')
		endif			
		
		oScorecard:_next()		
	enddo
	
	//retira o filtro
	oScorecard:cSQLFilter("")
	// Fim table 1
	
	if(nRegistros == 0)
		// Montagem do rodap&eacute; do relat&oacute;rio 
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode(STR0024))
		oHtmFile:nWriteLN('	</font>')
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode(STR0025))
		oHtmFile:nWriteLN('	</font>')
	endif
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
               
	//Faz a copia do relatorio para o diretorio de Spool
	oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + cReportName, oKPICore:cKpiPath())
	oHtmFile:lClose()
	oKPICore:Log(STR0006+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
return nStatus

function cScorePais(cScoreId)
	local cIdPai := "", cAcumNomePai := "", cNome := ""
	oScorecard:savePos()

	if(oScorecard:lSeek(1, {cScoreId}))
		cIdPai := alltrim(oScorecard:cValue("PARENTID"))
		if( !empty(cIdPai) )
			if(oScorecard:lSeek(1, {cIdPai}))
				cNome := alltrim(oScorecard:cValue("NOME"))
				cAcumNomePai := cScorePais(cIdPai) + " -> " + cNome
			endif
		endif
	endif

	oScorecard:restPos()
	
return cAcumNomePai
