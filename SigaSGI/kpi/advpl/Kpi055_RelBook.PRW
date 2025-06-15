// ###################################################################################### 
// Projeto: KPI
// Modulo : Book de Planejamento Estratégico
// Fonte  : KPI055_RelBook.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------  
// 25.10.11 | Tiago Tudisco
// --------------------------------------------------------------------------------------

#Include "BIDefs.ch"
#Include "KPIDefs.ch"
#Include "KPI055_RelBook.ch"

/*--------------------------------------------------------------------------------------
@class TKPI055
@entity RelBook
Book de Planejamento Estratégico
@table KPI055
--------------------------------------------------------------------------------------*/
#Define TAG_ENTITY "RELBOOK"
#Define TAG_GROUP  "RELBOOK"                            
#Define TEXT_ENTITY STR0001/*//"Book de Planejamento estratégico"*/
#Define TEXT_GROUP  STR0002/*//"Book de Planejamento estratégico"*/

#Define BOOK_ORG	1
#Define BOOK_EST	2
#Define BOOK_PER	3
#Define BOOK_OBJ	4
#Define BOOK_IND	5     

//Tipo Atualizacao Indicador
#Define MANUAL		"0"
#Define VIA_PLAN	"1"
#Define VIA_FDAD	"2"           

#Define TAG			1
#Define CAB			2

Class TKPI055 From TBITable
	//CONSTRUTUOR
	Method New() constructor
	Method NewKPI055()

	// REGISTRO ATUAL
	Method oToXMLNode(cId)
	Method nUpdFromXML(oXML, cPath)

	// EXECUTAR 
	Method nExecute(cID, cExecCMD)   

	//Relatorios
	Method KPIRelBookJob(aParms)   
	Method RelBookDes(cNome,cKpiPath,cPathSite,cReportName)
	Method RelBookOrg(aOrg,cNome,cKpiPath,cPathSite,cReportName)
	Method RelBookEst(aEst,cNome,cKpiPath,cPathSite,cReportName)
	Method RelBookPer(aPer,cNome,cKpiPath,cPathSite,cReportName)
	Method RelBookObj(aObj,cNome,cKpiPath,cPathSite,cReportName)
	Method RelBookInd(aInd,cNome,cKpiPath,cPathSite,cReportName)

	Method aMntScore()

EndClass           


/*-------------------------------------------------------------------------------------------------------
*  CONSTRUTOR
*-------------------------------------------------------------------------------------------------------*/
Method New() Class TKPI055
	::NewKPI055()
Return
Method NewKPI055() Class TKPI055

	// Table
	::NewTable("SGI055")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C", 010))
	::addField(TBIField():New("NOME"		,"C", 060))
	::addField(TBIField():New("DESCRICAO"	,"C", 255))
	::addField(TBIField():New("IMPDESC"		,"L"	 )) // Imprime Descrição 
	::addField(TBIField():New("IMPIND"		,"L",	 )) // Imprime Indicadores
	::addField(TBIField():New("IMPEXP"		,"L",	 )) // Imprime os itens expandidos

	// Indexes
	::addIndex(TBIIndex():New("SGI055I01",{"ID"},.T.))
Return     

/*-------------------------------------------------------------------------------------------------------
*  CARREGAR
*-------------------------------------------------------------------------------------------------------*/
Method oToXMLNode(cId) Class TKPI055
	Local aFields
	Local nInd
	Local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	Local aSelNode		:= {}                 

	::_First()

	// ACRESCENTA OS VALORES AO XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

	// ACRESCENTA CHILDREN
	aSelNode := ::oOwner():oGetTable("RELBOOKXSCOR"):aNodeSelect(cId)
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oArvore(.T.,"0",.T.,aSelNode))

Return oXMLNode             
 
                      
/*-------------------------------------------------------------------------------------------------------
*  ATUALIZA AS ENTIDADES
*-------------------------------------------------------------------------------------------------------*/
Method nUpdFromXML(oXML, cPath) Class TKPI055

	Local nStatus := KPI_ST_OK,	cID, nInd, oTable, cNome, nQtdReg, aObj := {}
	Local oRelBookxScor := ::oOwner():oGetTable("RELBOOKXSCOR")
	Local cScorAlt	:= xBIConvTo("C", oXML:_REGISTROS:_RELBOOK:_SCORECARDS:TEXT)
	Local nFoundScor:= 0
	Local nFoundProj:= 0
	Local aScorAlt	:= {}
	Local aProjAlt	:= {}
						
	Private oXMLInput := oXML
	
	//CONTROLA OS REGISTROS QUE O USUARIO SOLICITOU ALTERACAO.
	cScorAlt	:= strTran(cScorAlt, "[", "")
  	cScorAlt	:= strTran(cScorAlt, "]", "")
	aScorAlt	:= aBIToken(alltrim(cScorAlt),",",.f.)

	aFields := ::xRecord(RF_ARRAY) 

	// EXTRAI VALORES DO XML
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		If(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		EndIf
	Next
            
	// VERIFICA CONDICOES DE GRAVACAO (APPEND OU UPDATE)     
	::oOwner():oOltpController():lBeginTransaction()
	
	::SetOrder(1) // POR ORDEM DE ID
	::cSQLFilter("ID = '"+cBIStr(cID)+"'") // FILTRA PELO PAI
	::lFiltered(.t.)
	::_First()

	if(::lEof())
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

    If nStatus == KPI_ST_OK

		//ATUALIZANDO OS VALORES DA SCORECARD
		If(Valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD")) != "U")
	
			aRegNode := &("oXMLInput:"+cPath+":_SCORECARDS")//PEGANDO OS VALORES DA SCORECARDS
	
			If(Valtype(aRegNode:_SCORECARD) != "A")
				aObj := { aRegNode:_SCORECARD }
			Else
				aObj := aRegNode:_SCORECARD
			EndIf	
		    oRelBookxScor:setOrder(2)
		    oRelBookxScor:lSoftSeek(2,{cID})
			While(!oRelBookxScor:lEof() .And. Alltrim(oRelBookxScor:cValue("ID_RELBOOK")) == Alltrim(cID))
				nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == Alltrim(oRelBookxScor:cValue("ID_SCOREC"))})
				If(nFoundItem == 0)
						//NAO ENCONTROU NO XML APAGA.
					If(!oRelBookxScor:lDelete())
						nStatus := KPI_ST_INUSE
						Exit							
					EndIf
				EndIf    
	
				oRelBookxScor:_Next()
			End
	
			If(Valtype(aRegNode:_SCORECARD) == "A")
				For nQtdReg := 1 To Len(aRegNode:_SCORECARD)
					nStatus	:= oRelBookxScor:nInsFromXML(cId, aRegNode:_SCORECARD[nQtdReg])
					If(nStatus != KPI_ST_OK)
						Exit
					EndIf
				Next nQtdReg
			ElseIf(Valtype(aRegNode:_SCORECARD) == "O")
				nStatus	:= oRelBookxScor:nInsFromXML(cId, aRegNode:_SCORECARD)
			EndIf
		Else
			//CASO NAO ENCONTROU EXCLUI TUDO.
		    oRelBookxScor:setOrder(2)
		    oRelBookxScor:lSoftSeek(2,{cID})
			While(!oRelBookxScor:lEof() .And. Alltrim(oRelBookxScor:cValue("ID_RELBOOK")) == Alltrim(cID))
				//NAO ENCONTROU NO XML APAGA.
				If(!oRelBookxScor:lDelete())
					nStatus := KPI_ST_INUSE
					Exit							
				EndIf
				oRelBookxScor:_Next()
			End
		EndIf                                           
	EndIf   		

	If nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	EndIf

	::oOwner():oOltpController():lEndTransaction()

Return nStatus 

/*-------------------------------------------------------------------------------------------------------
*  EXECUTE
*-------------------------------------------------------------------------------------------------------*/
Method nExecute(cID, cExecCMD) Class TKPI055
	
	Local 	aParms 		:= {} 
	Local 	cPathSite	:= Left(httpHeadIn->REFERER, Rat("/", httpHeadIn->REFERER))
	Private nStatus 	:= KPI_ST_OK
	if(::lSeek(1, {cID})) // POSICIONA NO ID INFORMADO

		// 1 - Nome
		aAdd(aParms, Alltrim(::cValue("NOME")))
		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))
		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))
		// 4 - Imprime Indicadores?
		aAdd(aParms, ::lValue("IMPIND"))
		// 5 - ID do Relatório
		aAdd(aParms, ::cValue("ID"))
		// 6 - KPIPATH da Working THREAD
		aAdd(aParms, ::oOwner():cKpiPath())
		// 7 - Nome do arquivo que sera salvo
		aAdd(aParms,cExecCMD )
		// 8 - Diretorio do site.
		aAdd(aParms, strtran(cPathSite,"\","/"))     
		// 9 - Imprime expandido
		aAdd(aParms, ::lValue("IMPEXP"))

		// Executando JOB
		nStatus := ::KPIRelBookJob(aParms)
		If(nStatus == KPI_ST_OK)
			::fcMsg := STR0003 //Geração do Relatório Finalizada!
		ElseIf(nStatus == KPI_ST_GENERALERROR)
			::fcMsg := STR0004 //Erro na Geração do Relatório!
		EndIf
	Else

		nStatus := 	KPI_ST_BADID

	EndIf

Return nStatus

                  
/*-------------------------------------------------------------------------------------------------------
*  FUNCTION PARA EXECUTAR O JOB
*-------------------------------------------------------------------------------------------------------*/
Method KPIRelBookJob(aParms) Class TKPI055

	Local cNome
	Local cDescricao
	Local lImpDesc
	Local lImpInd     
	Local lImpExp
	Local cID
	Local cKpiPath
	Local cReportName
	Local cPathSite       
	Local lImpRel	:= .F.  
	Local oHtmFile
	
	Local aRelBook	:= {}
	Local cExt    
	
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao	:= aParms[2]	
	// 3 - Imprime Descrição?
	lImpDesc	:= aParms[3]	
	// 4 - Imprime Indicador?
	lImpInd		:= aParms[4]
	// 5 - ID do Relatório
	cID			:= aParms[5]	
	// 6 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[6]	
	// 7 - Nome do arquivo que sera salvo
	cReportName	:= aParms[7]
	// 8 - Diretorio do site.
	cPathSite	:= aParms[8]	
	// 9 - Imprime expandido
	lImpExp	    := aParms[9]	
	            
	lImpRel := ::aMntScore(aRelBook)   
	                     
	cExt := Right(cReportName, Len(cReportName) - Rat(".",cReportName) + 1)
	If Empty(cExt)
		cReportName += ".html"
	EndIf
	
    //CRIA O ARQUIVO HTML
    oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_" + alltrim(cID) + ".html")
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0005 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_"*/
		oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return KPI_ST_GENERALERROR
	endif

	// MONTAGEM DO CABECALHO DA PAGINA
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
	oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')   
	oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
    oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')
   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	If lImpDesc   	
		oHtmFile:nWriteLN(' <script language="javascript">')    
			
		oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
		oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
		oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')     	                         
		
		oHtmFile:nWriteLN(' 	function dinMenu( x )')
		oHtmFile:nWriteLN(' 	{')
		oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
		oHtmFile:nWriteLN(' 			x.style.display = "";')
		oHtmFile:nWriteLN(' 		else')
		oHtmFile:nWriteLN(' 			x.style.display = "none";')
		oHtmFile:nWriteLN(' 	}')
		oHtmFile:nWriteLN('	</script>')      
	EndIf
	oHtmFile:nWriteLN('</head>')         

	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
       
	If lImpRel .Or. lImpDesc

	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150"  align="center"><img src="'+cPathSite+'imagens/art_logo_clie.sgi"></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)+'</div></td>') //Book de Planejamento estratégico  		
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
	
		oHtmFile:nWriteLN('<table width="100%" height="300" bgcolor="#F5F5F3" border="0" align="left" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="8%"></td>')
		oHtmFile:nWriteLN('<td width="92%"></td>')
		oHtmFile:nWriteLN('</tr>')
        //Imprime "Resumo"
		If lImpDesc                
			oHtmFile:nWriteLN('<tr>')
			If lImpExp  
				impEspaco(oHtmFile, "20")
				oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_resumo.gif" width="20" height="20"></div></td>')
				oHtmFile:nWriteLN('<td height="20" class="links"><a href="REL055_Res_'+cReportName+' " target="_top">'+KPIEncode(STR0011)+'</a></td>')//Resumo
			Else
				oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_resumo.gif" width="20" height="20"></div></td>')
				oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="REL055_Res_'+cReportName+' " target="_top">'+KPIEncode(STR0011)+'</a></td>')//Resumo
			EndIf
			oHtmFile:nWriteLN('</tr>')
			::RelBookDes(cNome,cKpiPath,cPathSite,cReportName,Nil,"1")    
			If lImpExp   
				impEspaco(oHtmFile, "15")
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2">') 
							
				::RelBookDes(cNome,cKpiPath,cPathSite,cReportName,oHtmFile, "2")  
				
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
				impDivisao(oHtmFile, cPathSite) 			           
			EndIf   			
		EndIf      
        //Imprime "Organizações"
		If Len(aRelBook[BOOK_ORG]) > 0    
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_20_organizacao.gif" width="20" height="20"></div></td>')
			If lImpExp
				oHtmFile:nWriteLN('<td height="20" class="links"><a href="REL055_Org_'+cReportName+' " target="_top">'+KPIEncode(STR0012)+'</a></td>')//Organizacao
			Else
				oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="REL055_Org_'+cReportName+' " target="_top">'+KPIEncode(STR0012)+'</a></td>')//Organizacao
			EndIf
			oHtmFile:nWriteLN('</tr>')
			::RelBookOrg(aRelBook[BOOK_ORG],cNome,cKpiPath,cPathSite,cReportName, Nil, "1") 
			If lImpExp 
				impEspaco(oHtmFile, "15")      			
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2" height="5">')	
				               
				::RelBookOrg(aRelBook[BOOK_ORG],cNome,cKpiPath,cPathSite,cReportName,oHtmFile,"2")
						
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')	
				impDivisao(oHtmFile, cPathSite) 	
			EndIf
		EndIf   
        //Imprime "Estrategias"
		If Len(aRelBook[BOOK_EST]) > 0   
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_20_estrategia.gif" width="20" height="20"></div></td>')
			If lImpExp
				oHtmFile:nWriteLN('<td height="20" class="links"><a href="REL055_Est_'+cReportName+' " target="_top">'+KPIEncode(STR0013)+'</a></td>')//Estrategia
			Else                                                                                                                                                       
				oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="REL055_Est_'+cReportName+' " target="_top">'+KPIEncode(STR0013)+'</a></td>')//Estrategia			
			EndIf
			oHtmFile:nWriteLN('</tr>')
			::RelBookEst(aRelBook[BOOK_EST],cNome,cKpiPath,cPathSite,cReportName,Nil,"1")
			If lImpExp             
				impEspaco(oHtmFile, "15")
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2">')		
			
				::RelBookEst(aRelBook[BOOK_EST],cNome,cKpiPath,cPathSite,cReportName,oHtmFile,"2")
	
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
				impDivisao(oHtmFile, cPathSite) 			
			EndIf
		EndIf        
        //Imprime "Perspectivas"
		If Len(aRelBook[BOOK_PER]) > 0    
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_20_perspectiva.gif" width="20" height="20"></div></td>')
			If lImpExp
				oHtmFile:nWriteLN('<td height="20" class="links"><a href="REL055_Per_'+cReportName+' " target="_top">'+KPIEncode(STR0014)+'</a></td>')//Perspectiva
			Else
				oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="REL055_Per_'+cReportName+' " target="_top">'+KPIEncode(STR0014)+'</a></td>')//Perspectiva
			EndIf
			oHtmFile:nWriteLN('</tr>')
			::RelBookPer(aRelBook[BOOK_PER],cNome,cKpiPath,cPathSite,cReportName,Nil,"1")
			If lImpExp             
				impEspaco(oHtmFile, "15")
	        	oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2">')
	                         
	   			::RelBookPer(aRelBook[BOOK_PER],cNome,cKpiPath,cPathSite,cReportName,oHtmFile,"2")
				
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
				impDivisao(oHtmFile, cPathSite) 			
			EndIf
		EndIf 
        //Imprime "Objetivos"
		If Len(aRelBook[BOOK_OBJ]) > 0   
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_objetivo_green.gif" width="20" height="20"></div></td>')
			If lImpExp
				oHtmFile:nWriteLN('<td height="20" class="links"><a href="REL055_Obj_'+cReportName+' " target="_top">'+KPIEncode(STR0015)+'</a></td>')//Objetivo
		    Else
				oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="REL055_Obj_'+cReportName+' " target="_top">'+KPIEncode(STR0015)+'</a></td>')//Objetivo
			EndIf
			oHtmFile:nWriteLN('</tr>')
			::RelBookObj(aRelBook[BOOK_OBJ],cNome,cKpiPath,cPathSite,cReportName, Nil, "1")
			If lImpExp               
				impEspaco(oHtmFile, "15")
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2">')
			
				::RelBookObj(aRelBook[BOOK_OBJ],cNome,cKpiPath,cPathSite,cReportName, oHtmFile, "2")
				
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
				impDivisao(oHtmFile, cPathSite) 					
			EndIf
		EndIf 
        //Imprime "Indicadores"
		If (Len(aRelBook[BOOK_IND]) > 0 ) .And. lImpInd  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td height="20"><div align="center"><img src="'+cPathSite+'imagens/ic_indicador.gif" width="20" height="20"></div></td>')
			If lImpExp 
				oHtmFile:nWriteLN('<td height="20" class="links"><a href="REL055_Ind_'+cReportName+' " target="_top">'+KPIEncode(STR0016)+'</a></td>')//Indicador
			Else
				oHtmFile:nWriteLN('<td height="20" class="form_input"><a href="REL055_Ind_'+cReportName+' " target="_top">'+KPIEncode(STR0016)+'</a></td>')//Indicador
    		EndIf
			oHtmFile:nWriteLN('</tr>')
			::RelBookInd(aRelBook[BOOK_IND],cNome,cKpiPath,cPathSite,cReportName,Nil,"1") 
			If lImpExp          
				impEspaco(oHtmFile, "15")
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td colspan="2">')
				
				::RelBookInd(aRelBook[BOOK_IND],cNome,cKpiPath,cPathSite,cReportName,oHtmFile,"2")
							
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
			EndIf
		EndIf      

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="90"></td>')
		oHtmFile:nWriteLN('<td height="90"></td>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="2" ><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10" /></td>')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')

	Else

		// Montagem do rodape do relatorio
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(	KPIEncode(STR0008))//Não foram encontradas informações dentro das especificações passadas
		oHtmFile:nWriteLN('	</font>')
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode(STR0009))//ou não existem Indicadores para os Objetivos selecionados.
		oHtmFile:nWriteLN('	</font>')

	EndIf

	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')

	//Faz a copia do relatorio para o diretorio de Spool
	oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + cReportName, oKPICore:cKpiPath())
	oHtmFile:lClose()
	oKPICore:Log(STR0003+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/

Return nStatus

                 
/*-------------------------------------------------------------------------------------------------------
* MONTA RELATORIO DE RESUMO (DESCRICAO)
*-------------------------------------------------------------------------------------------------------*/
Method RelBookDes(cNome,cKpiPath,cPathSite,cReportName,oHtmOrig,cTipo) Class TKPI055

Local oHtmFile 

Default oHtmOrig := nil
Default cTipo    := "1"   

	If oHtmOrig != nil
		oHtmFile := oHtmOrig
	EndIf 
    
	If cTipo == "1"
	    oHtmFile := TBIFileIO():New(cKpiPath+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_Res_"+cReportName)
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oKPICore:Log(STR0017 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_Res"*/
			oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
			return KPI_ST_GENERALERROR
		endif
	
		// MONTAGEM DO CABECALHO DA PAGINA
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
		oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">') 
		oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')
	   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
		oHtmFile:nWriteLN('</head>')         
	
		oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150"  align="center"><img src="'+cPathSite+'imagens/art_logo_clie.sgi"></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Book de Planejamento estratégico  		
		oHtmFile:nWriteLN('<br><br><span class="titulo2">'+KPIEncode(STR0011)+'</span>')//Resumo
		oHtmFile:nWriteLN('</div></td>')
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
	EndIf      
	
	oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F5F5F3" >')
                                
	oHtmFile:nWriteLN('<tr>')   
	
	If cTipo == "1"
		oHtmFile:nWriteLN('<td width="10%" height="40" ><img src="'+cPathSite+'imagens/icone_resumo.jpg" height="40" /></td>') 
		If Len(cReportName) > 5
			oHtmFile:nWriteLN('<td width="90%" height="40" colspan="3" align="right"><a href="'+cReportName+'"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
		Else
			oHtmFile:nWriteLN('<td width="90%" height="40" colspan="3" align="right"><a href="REL055.html"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"   border="0"/></a></td>')
		EndIf          
	EndIf
	
	oHtmFile:nWriteLN('</tr>')
	
	oHtmFile:nWriteLN('<tr>')     
	oHtmFile:nWriteLN('<td width="5%" height="20" />')
	oHtmFile:nWriteLN('<td width="95%" colspan="2" ><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10" /></td>')
	oHtmFile:nWriteLN('</tr>')  
	
	oHtmFile:nWriteLN('<tr>')       
	If cTipo == "2"
		oHtmFile:nWriteLN('<td width="10%" height="40" align="center"><img src="'+cPathSite+'imagens/icone_resumo.jpg" height="40" /></td>')
	Else
		oHtmFile:nWriteLN('<td width="5%" height="25"/></td>')
	EndIf
	oHtmFile:nWriteLN('<td width="10%" ><strong>'+KPIEncode(STR0018)+'</strong></td>')//Relatorio:
	oHtmFile:nWriteLN('<td width="70%" style = "border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="#FFFFFF" >'+cBookEncode(::cValue("NOME"))+'</td>')
	oHtmFile:nWriteLN('<td width="10%" /></td>')
	oHtmFile:nWriteLN('</tr>')
	
	oHtmFile:nWriteLN('<tr>')
	oHtmFile:nWriteLN('<td height="5" colspan="4">')
	oHtmFile:nWriteLN('</tr>')
	
	oHtmFile:nWriteLN('<tr>')                         
	If cTipo == "2"
		oHtmFile:nWriteLN('<td width="5%" height="40"/>')
	Else
		oHtmFile:nWriteLN('<td width="5%" height="25"/>')
	EndIf
	oHtmFile:nWriteLN('<td width="10%" ><strong>'+KPIEncode(STR0019)+'</strong></td>')//Descricao:
	oHtmFile:nWriteLN('<td width="75%" style = "border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="#FFFFFF" >'+cBookEncode(::cValue("DESCRICAO"))+'</td>')
	oHtmFile:nWriteLN('<td width="10%" />')
	oHtmFile:nWriteLN('</tr>')
	
	oHtmFile:nWriteLN('<tr>')
	oHtmFile:nWriteLN('<td height="20" colspan="4">')
	oHtmFile:nWriteLN('</tr>')
	
	oHtmFile:nWriteLN('</table>')   
	
	If cTipo == "1"
		oHtmFile:nWriteLN('<div width="100%"><img src="'+cPathSite+'imagens/linha_fundo.jpg" width="100%" height="5"></div>')
	
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
	
		//Faz a copia do relatorio para o diretorio de Spool
		oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + 'REL055_Res_'+cReportName, cKpiPath)
		oHtmFile:lClose()
		oKPICore:Log(STR0003+cNome+"KPI055_Res]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
	EndIf

Return 
        

/*-------------------------------------------------------------------------------------------------------
* MONTA RELATORIO DE ORGANIZACAO
*-------------------------------------------------------------------------------------------------------*/
Method RelBookOrg(aOrg,cNome,cKpiPath,cPathSite,cReportName, oHtmOrig, cTipo) Class TKPI055      
                   
	Local oScore	:= ::oOwner():oGetTable("SCORECARD")       
	Local oOrg		:= ::oOwner():oGetTable("ORGANIZACAO")
	Local oEst		:= ::oOwner():oGetTable("ESTRATEGIA")
	Local oHtmFile
	Local nI     
	Local lPrimeiro	:= .T.      
	Local cEstTab  
	
	Default oHtmOrig := Nil
	Default cTipo    := "1"     
	
	If oHtmOrig != Nil
		oHtmFile := oHtmOrig
	EndIf
	
	If cTipo == "1"
	    oHtmFile := TBIFileIO():New(cKpiPath+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_Org_"+cReportName)
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oKPICore:Log(STR0020 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_Org"*/
			oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
			Return KPI_ST_GENERALERROR
		EndIf
	
		// MONTAGEM DO CABECALHO DA PAGINA
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
		oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')        
 		oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')
	   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	   	
		oHtmFile:nWriteLN(' <script language="javascript">')    
		
		oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
		oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
		oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')                                                                    
		                         
		oHtmFile:nWriteLN(' 	function dinMenu( x )')
		oHtmFile:nWriteLN(' 	{')
		oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
		oHtmFile:nWriteLN(' 			x.style.display = "";')
		oHtmFile:nWriteLN(' 		else')
		oHtmFile:nWriteLN(' 			x.style.display = "none";')
		oHtmFile:nWriteLN(' 	}')
		oHtmFile:nWriteLN('	</script>')
	   	
		oHtmFile:nWriteLN('</head>')         
	
		oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150"  align="center"><img src="'+cPathSite+'imagens/art_logo_clie.sgi"></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Book de Planejamento estratégico  		
		oHtmFile:nWriteLN('<br><br><span class="titulo2">'+KPIEncode(STR0012)+'</span>')//Organizacao
		oHtmFile:nWriteLN('</div></td>')
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')   
	EndIf   
	         
	For nI := 1 To Len(aOrg)
		
		oScore:lSeek(1,{aOrg[nI]}) 
		oOrg:lSeek(1,{aOrg[nI]})     
   		cEstTab := "estTab"+alltrim(aOrg[nI])
		
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F5F5F3" >')
		oHtmFile:nWriteLN('<tr>')       
		oHtmFile:nWriteLN('<td width="10%" height="40" align="center" ><img src="'+cPathSite+'imagens/icone_organizacao.gif" height="40" /></td>')  
		If cTipo == "1"	
			oHtmFile:nWriteLN('<td width="85%" height="10" colspan="2"><strong><font size="4">'+cBookEncode(oScore:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
		Else
			oHtmFile:nWriteLN('<td width="90%" height="40" colspan="2"><strong><font size="4">'+cBookEncode(oScore:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
		EndIf	 
	    
	    If cTipo == "1"                        
			If lPrimeiro			     
				If Len(cReportName) > 5
					oHtmFile:nWriteLN('<td width="10%" height="40" align="right"><a href="'+cReportName+'"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif" border="0"/></a></td>')
				Else
					oHtmFile:nWriteLN('<td width="10%" height="40" align="right"><a href="REL055.html"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif" border="0"/></a></td>')
				EndIf
				lPrimeiro := .F.					
			Else	
				oHtmFile:nWriteLN('<td width="10%" height="40" />')							
			EndIf                                                  
		Else
//			oHtmFile:nWriteLN('<td width="10%" height="40" />')
		EndIf
		
		oHtmFile:nWriteLN('</tr>')
			
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="12%"><strong>'+KPIEncode(STR0019)+'</strong></td>')//Descricao:
		oHtmFile:nWriteLN('<td width="73%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oScore:cValue("DESCRICAO"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		                          
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="12%"><strong>'+KPIEncode(STR0021)+'</strong></td>')//Missao:
		oHtmFile:nWriteLN('<td width="73%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oOrg:cValue("MISSAO"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="12%"><strong>'+KPIEncode(STR0022)+'</strong></td>')//Visao
		oHtmFile:nWriteLN('<td width="73%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oOrg:cValue("VISAO"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')   
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="12%"><strong>'+KPIEncode(STR0023)+'</strong></td>')//Notas
		oHtmFile:nWriteLN('<td width="73%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oOrg:cValue("NOTAS"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="12%"><strong>'+KPIEncode(STR0024)+'</strong></td>')//Politica de Qualidade
		oHtmFile:nWriteLN('<td width="73%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oOrg:cValue("QUALIDADE"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="12%"><strong>'+KPIEncode(STR0025)+'</strong></td>')//Valores
		oHtmFile:nWriteLN('<td width="73%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oOrg:cValue("VALORES"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		                            
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="4"/>')
		oHtmFile:nWriteLN('</tr>')		
 
	    If oScore:lSeek(2,{aOrg[nI]})//PARENTID
			   
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')     
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink"><a href="javascript:dinMenu('+cEstTab+');">'+KPIEncode(STR0026)+'</a></a></td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('<td width="85%" colspan="2"><table id="'+cEstTab+'" style="display:none;" width="100%" border="0"   cellpadding="2" cellspacing="2">')
		  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="35%" colspan="2" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0013)+'</td>')//Estrategia
			oHtmFile:nWriteLN('<td width="20%" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0053)+'</td>')//Data Inicial
			oHtmFile:nWriteLN('<td width="20%" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0054)+'</td>')//Data Final
			oHtmFile:nWriteLN('</tr>')
		   
			While oScore:cValue("PARENTID") == aOrg[nI]

				oEst:lSeek(1,{oScore:cValue("ID")})
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="35%" colspan="2" height="20" class="texto3">'+cBookEncode(oScore:cValue("NOME"))+'</td>')
				oHtmFile:nWriteLN('<td width="20%" height="20" align="right" class="texto3">'+dToC(oEst:dValue("DATAINI"))+'</td>')
				oHtmFile:nWriteLN('<td width="20%" height="20" align="right" class="texto3">'+dToC(oEst:dValue("DATAFIN"))+'</td>')
				oHtmFile:nWriteLN('</tr>')
    
				oScore:_Next()
			
			End				
						
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')    
			
		Else
		
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink">'+KPIEncode(STR0059)+'</td>')//Sem Estrategias
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')
		
		EndIf			   
									
		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="20" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>') 
		
		If cTipo == "1"
			oHtmFile:nWriteLN('<div width="100%" ><img src="'+cPathSite+'imagens/linha_fundo.jpg" width="100%" height="5" /></div>')
		EndIf
	
	Next
	
	If cTipo == "1"
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')
		
		//Faz a copia do relatorio para o diretorio de Spool
		oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + 'REL055_Org_'+cReportName, cKpiPath)
		oHtmFile:lClose()
		oKPICore:Log(STR0003+cNome+"KPI055_Org]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
	EndIf

Return
       

/*-------------------------------------------------------------------------------------------------------
* MONTA RELATORIO DE ESTRATEGIA
*-------------------------------------------------------------------------------------------------------*/
Method RelBookEst(aEst,cNome,cKpiPath,cPathSite,cReportName,oHtmOrig,cTipo) Class TKPI055

	Local oScore	:= ::oOwner():oGetTable("SCORECARD")       
	Local oEst		:= ::oOwner():oGetTable("ESTRATEGIA")

	Local oHtmFile
	Local nI         
	Local nRec    
	Local lPrimeiro	:= .T.
	Local cPerTab         
	
    Local cHierarq 	:= ""     
    Local lQuebra	:= .T.   
    
	Default oHtmOrig := Nil
	Default cTipo    := "1" 
    
    If oHtmOrig != Nil
    	oHtmFile := oHtmOrig
    EndIf
	     
	If cTipo == "1"
	    oHtmFile := TBIFileIO():New(cKpiPath+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_Est_"+cReportName)
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oKPICore:Log(STR0029 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_Est"*/
			oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
			return KPI_ST_GENERALERROR
		endif
	
		// MONTAGEM DO CABECALHO DA PAGINA
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
		oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
    	oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')		
	   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	   	
		oHtmFile:nWriteLN(' <script language="javascript">')    
		
		oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
		oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
		oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')                                                                    
		                         
		oHtmFile:nWriteLN(' 	function dinMenu( x )')
		oHtmFile:nWriteLN(' 	{')
		oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
		oHtmFile:nWriteLN(' 			x.style.display = "";')
		oHtmFile:nWriteLN(' 		else')
		oHtmFile:nWriteLN(' 			x.style.display = "none";')
		oHtmFile:nWriteLN(' 	}')
		oHtmFile:nWriteLN('	</script>')
	   	
		oHtmFile:nWriteLN('</head>')         
	
		oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150"  align="center"><img src="'+cPathSite+'imagens/art_logo_clie.sgi"></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Book de Planejamento estratégico  		
		oHtmFile:nWriteLN('<br><br><span class="titulo2">'+KPIEncode(STR0013)+'</span>')//Estrategia
		oHtmFile:nWriteLN('</div></td>')
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')  
	EndIf    
    
    cHierarq := "" 
	For nI := 1 To Len(aEst)
	      
		oScore:lSeek(1,{aEst[nI]})//ID
		oEst:lSeek(1,{aEst[nI]})//ID
		nRec := oScore:nRecno() 
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
   		cPerTab := "perTab"+alltrim(aEst[nI])
	    
		lQuebra := !(cHierarq == cBookEncode(oScore:cValue("NOME")))	
	
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F5F5F3" >')
		                          
		If !lPrimeiro
		
			oHtmFile:nWriteLN('<tr>')     
			oHtmFile:nWriteLN('<td width="100%" height="25" colspan="4">')  
			
			If lQuebra
				oHtmFile:nWriteLN('<img src="'+cPathSite+'imagens/linha_fundo.jpg" width="100%" height="5"/>')				
			EndIf   
			
			oHtmFile:nWriteLN('</td></tr>')
		EndIf      
		
		If lQuebra
			cHierarq := cBookEncode(oScore:cValue("NOME"))	
		      
			oHtmFile:nWriteLN('<tr>')     
			If cTipo == "2"
				oHtmFile:nWriteLN('<td width="10%" height="25" align="center"><img src="'+cPathSite+'imagens/icone_estrategia.gif" height="40"></td>')      
			Else
				oHtmFile:nWriteLN('<td width="5%" height="25"><img src="'+cPathSite+'imagens/icone_estrategia.gif" height="40"></td>')      
			EndIf
			oHtmFile:nWriteLN('<td width="90%" height="10" colspan="2"><strong><font size="4">'+cHierarq+'</font></strong></td>')
		
			If cTipo == "1"
		   		If lPrimeiro
			   		If Len(cReportName) > 5
				   		oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="'+cReportName+'"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
			  		Else
			   			oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="REL055.html"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
			 		EndIf
			 		lPrimeiro := .F.
		 		Else
			   		oHtmFile:nWriteLN('<td width="5%" height="40" />')
		   		EndIf
		   	EndIf
     
	   		
	 	EndIf
		oHtmFile:nWriteLN('</tr>')

		oScore:lGoTo(nRec)		
		
		oHtmFile:nWriteLN('<tr>') 
		     
		If lQuebra
			oHtmFile:nWriteLN('<td width="5%" height="25"></td>')		
		Else
			oHtmFile:nWriteLN('<td width="5%" height="25">&nbsp;</td>')				
		EndIf   
		
		oHtmFile:nWriteLN('<td width="85%" colspan="2"><strong><font size="3" color="#000080">'+cBookEncode(oScore:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
		oHtmFile:nWriteLN('<td width="10%" ></td>')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0019)+'</strong></td>')//Descricao:
		oHtmFile:nWriteLN('<td width="75%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oScore:cValue("DESCRICAO"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
				
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0027)+'</strong></td>')//Data Inicial:
		oHtmFile:nWriteLN('<td width="75%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+dToC(oEst:dValue("DATAINI"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
						
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0028)+'</strong></td>')//Data Final
		oHtmFile:nWriteLN('<td width="75%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+dToC(oEst:dValue("DATAFIN"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('	</tr>')     
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="4"/>')
		oHtmFile:nWriteLN('</tr>')		

		If oScore:lSeek(2,{aEst[nI]})//PARENTID       

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink"><a href="javascript:dinMenu('+cPerTab+');">'+KPIEncode(STR0030)+'</a></a></td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('<td width="85%" colspan="2"><table id="'+cPerTab+'" style="display:none;" width="100%" border="0" cellpadding="2" cellspacing="2">')
		  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="30%" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0014)+'</td>')//Perspectiva
			oHtmFile:nWriteLN('<td width="70%" align="center" height="20" colspan="2" bgcolor="#7BA0CA">'+KPIEncode(STR0052)+'</td>')//Descricao
			oHtmFile:nWriteLN('</tr>')
		     
			While oScore:cValue("PARENTID") == aEst[nI]
			   
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="30%" height="20" class="texto3">'+cBookEncode(oScore:cValue("NOME"))+'</td>')
				oHtmFile:nWriteLN('<td width="70%" height="20" colspan="2" class="texto3">'+cBookEncode(oScore:cValue("DESCRICAO"))+'</td>')
				oHtmFile:nWriteLN('</tr>')    
				
				oScore:_Next()
				
			End    

			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
		   
		Else
		
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink">'+KPIEncode(STR0060)+'</td>')//Sem Perspectivas
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')		
		
		EndIf			   
									
		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="20" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
	
	Next 
	
	If cTipo == "1"   
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')	
		
		//Faz a copia do relatorio para o diretorio de Spool
		oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + 'REL055_Est_'+cReportName, cKpiPath)
		oHtmFile:lClose()
		oKPICore:Log(STR0003+cNome+"KPI055_Est]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
	EndIf

Return
          

/*-------------------------------------------------------------------------------------------------------
* MONTA RELATORIO DE PERSPECTIVA
*-------------------------------------------------------------------------------------------------------*/
Method RelBookPer(aPer,cNome,cKpiPath,cPathSite,cReportName,oHtmOrig,cTipo) Class TKPI055
        
	Local oScore	:= ::oOwner():oGetTable("SCORECARD")       

	Local oHtmFile
	Local nI         
	Local nRec    
	Local cEstrat   
	Local lPrimeiro	:= .T.     
	Local cObjTab       
	
	Local cHierarq 	:= ""     
    Local lQuebra	:= .T.  
    
    Default oHtmOrig := Nil
    Default cTipo    := "1"
    
    If oHtmOrig != Nil
    	oHtmFile := oHtmOrig
    EndIf
	
	If cTipo == "1"
	    oHtmFile := TBIFileIO():New(cKpiPath+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_Per_"+cReportName)
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oKPICore:Log(STR0031 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_Per"*/
			oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
			return KPI_ST_GENERALERROR
		endif
	
		// MONTAGEM DO CABECALHO DA PAGINA
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
		oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')  
		oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')
	   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')    
	   	
		oHtmFile:nWriteLN(' <script language="javascript">')    
		
		oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
		oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
		oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')                                                                    
		                         
		oHtmFile:nWriteLN(' 	function dinMenu( x )')
		oHtmFile:nWriteLN(' 	{')
		oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
		oHtmFile:nWriteLN(' 			x.style.display = "";')
		oHtmFile:nWriteLN(' 		else')
		oHtmFile:nWriteLN(' 			x.style.display = "none";')
		oHtmFile:nWriteLN(' 	}')
		oHtmFile:nWriteLN('	</script>')
	   	
		oHtmFile:nWriteLN('</head>')         
	
		oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150"  align="center"><img src="'+cPathSite+'imagens/art_logo_clie.sgi"></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Book de Planejamento estratégico  		
		oHtmFile:nWriteLN('<br><br><span class="titulo2">'+KPIEncode(STR0014)+'</span>')//Perspectiva
		oHtmFile:nWriteLN('</div></td>')
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')  
	EndIf    
	
	cHierarq := ""     
	For nI := 1 To Len(aPer)
                             
		oScore:lSeek(1,{aPer[nI]})//ID
		nRec := oScore:nRecno() 
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cEstrat := oScore:cValue("NOME")
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
   		cObjTab := "objTab"+alltrim(aPer[nI])
                          
		lQuebra := !(cHierarq == cBookEncode(oScore:cValue("NOME"))+' > '+cBookEncode(cEstrat))
                               
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F5F5F3">')
        
		If !lPrimeiro
			oHtmFile:nWriteLN('<tr>')	
			oHtmFile:nWriteLN('<td width="100%" height="25" colspan="4">')  

	   		If lQuebra
				oHtmFile:nWriteLN('<img src="'+cPathSite+'imagens/linha_fundo.jpg" width="100%" height="5"/>')
    		EndIf
    		
			oHtmFile:nWriteLN('</td></tr>')    		
  		EndIf

		If lQuebra
			cHierarq := cBookEncode(oScore:cValue("NOME"))+' > '+cBookEncode(cEstrat)		
		                     
			oHtmFile:nWriteLN('<tr>')     
			If cTipo == "2"
				oHtmFile:nWriteLN('<td width="10%" height="25" align="center"><img src="'+cPathSite+'imagens/icone_perspectiva.gif" height="40"></td>')   
			Else                                                                                                                          
				oHtmFile:nWriteLN('<td width="5%" height="25"><img src="'+cPathSite+'imagens/icone_perspectiva.gif" height="40"></td>')   
			EndIf				
			oHtmFile:nWriteLN('<td width="90%" height="10" colspan="2"><strong><font size="4">'+cHierarq+'</font></strong></td>')
		        
			If cTipo == "1"
				If lPrimeiro
					If Len(cReportName) > 5
						oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="'+cReportName+'"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif" border="0"/></a></td>')
					Else
						oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="REL055.html"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif" border="0"/></a></td>')
					EndIf
					lPrimeiro := .F.
				Else
					oHtmFile:nWriteLN('<td width="5%" height="40"/>')
				EndIf	   
			EndIf
				
			oHtmFile:nWriteLN('</tr>')
		EndIf
		
		oScore:lGoTo(nRec)          
		oHtmFile:nWriteLN('<tr>')                          
		If lQuebra
			If cTipo == "2"
				oHtmFile:nWriteLN('<td width="10%" height="25"></td>')		
			Else
				oHtmFile:nWriteLN('<td width="5%" height="25"></td>')
			EndIf
		Else
			If cTipo == "2"
				oHtmFile:nWriteLN('<td width="10%" height="25">&nbsp;</td>')				
			Else
				oHtmFile:nWriteLN('<td width="5%" height="25">&nbsp;</td>')
			EndIf
		EndIf
		If cTipo == "2"
			oHtmFile:nWriteLN('<td width="90%" colspan="2"><strong><font size="3" color="#000080">'+cBookEncode(oScore:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
		Else
			oHtmFile:nWriteLN('<td width="85%" colspan="2"><strong><font size="3" color="#000080">'+cBookEncode(oScore:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
			oHtmFile:nWriteLN('<td width="10%" ></td>')		
		EndIf
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0019)+'</strong></td>')//Descricao:
		oHtmFile:nWriteLN('<td width="75%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oScore:cValue("DESCRICAO"))+'</td>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td height="20" colspan="4"/>')
		oHtmFile:nWriteLN('</tr>')		
		        
		If oScore:lSeek(2,{aPer[nI]})//PARENTID
			  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink"><a href="javascript:dinMenu('+cObjTab+');">'+KPIEncode(STR0032)+'</a></a></td>')//Lista de Objetivos
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('<td width="85%" colspan="2"><table id="'+cObjTab+'" style="display:none;" width="100%" border="0" cellpadding="2" cellspacing="2">')
		  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="30%" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0033)+'</td>')//Objetivos
			oHtmFile:nWriteLN('<td width="70%" align="center" height="20" colspan="2" bgcolor="#7BA0CA">'+KPIEncode(STR0052)+'</td>')//Descricao
			oHtmFile:nWriteLN('</tr>')
		     
			While oScore:cValue("PARENTID") == aPer[nI]
			   
				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="30%" height="20" class="texto3">'+cBookEncode(oScore:cValue("NOME"))+'</td>')
				oHtmFile:nWriteLN('<td width="70%" height="20" colspan="2" class="texto3">'+cBookEncode(oScore:cValue("DESCRICAO"))+'</td>')
				oHtmFile:nWriteLN('</tr>')
				
				oScore:_Next()
				
			End    
		
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
		           
		Else
		
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink">'+KPIEncode(STR0061)+'</td>')//Sem Objetivos
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')						
		
		EndIf			   
									
		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="20" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
	
	Next

	If cTipo == "1"   
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')	
		
		//Faz a copia do relatorio para o diretorio de Spool
		oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + 'REL055_Per_'+cReportName, cKpiPath)
		oHtmFile:lClose()
		oKPICore:Log(STR0003+cNome+"KPI055_Per]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/ 
	EndIf

Return
                                

/*-------------------------------------------------------------------------------------------------------
* MONTA RELATORIO DE OBJETIVOS
*-------------------------------------------------------------------------------------------------------*/
Method RelBookObj(aObj,cNome,cKpiPath,cPathSite,cReportName, oHtmOrig, cTipo) Class TKPI055     
       
	Local oScore	:= ::oOwner():oGetTable("SCORECARD")
	Local oUser		:= ::oOwner():oGetTable("USUARIO")     
	Local oInd		:= ::oOwner():oGetTable("INDICADOR")

	Local oHtmFile
	Local nI         
	Local nRec        
	Local cEstrat
	Local cPerspe    
	Local lPrimeiro	:= .T.     
	Local cIndTab

    Local cHierarq 	:= ""     
    Local lQuebra	:= .T.           
    
    Default oHtmOrig := Nil
    Default cTipo    := "1"
    
    If oHtmOrig != nil
    	oHtmFile := oHtmOrig
    EndIf
	         
	If cTipo == "1"
	    oHtmFile := TBIFileIO():New(cKpiPath+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_Obj_"+cReportName)
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oKPICore:Log(STR0034 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_Obj"*/
			oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
			return KPI_ST_GENERALERROR
		endif
	
		// MONTAGEM DO CABECALHO DA PAGINA
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
		oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
		oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')
	   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
		oHtmFile:nWriteLN(' <script language="javascript">')    
		
		oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
		oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
		oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')                                                                    
		                         
		oHtmFile:nWriteLN(' 	function dinMenu( x )')
		oHtmFile:nWriteLN(' 	{')
		oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
		oHtmFile:nWriteLN(' 			x.style.display = "";')
		oHtmFile:nWriteLN(' 		else')
		oHtmFile:nWriteLN(' 			x.style.display = "none";')
		oHtmFile:nWriteLN(' 	}')
		oHtmFile:nWriteLN('	</script>')
	
		oHtmFile:nWriteLN('</head>')         
	
		oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150"  align="center"><img src="'+cPathSite+'imagens/art_logo_clie.sgi"></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Book de Planejamento Estratégico  		
		oHtmFile:nWriteLN('<br><br><span class="titulo2">'+KPIEncode(STR0015)+'</span>')//Objetivo
		oHtmFile:nWriteLN('</div></td>')
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')    
	EndIf
        
    cHierarq := ""
	For nI := 1 To Len(aObj)
                             
		oScore:lSeek(1,{aObj[nI]})//ID
		nRec := oScore:nRecno()
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cPerspe := oScore:cValue("NOME")
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cEstrat := oScore:cValue("NOME")
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cIndTab := "indTab"+alltrim(aObj[nI])          

		lQuebra := !(cHierarq == cBookEncode(oScore:cValue("NOME"))+' > '+cBookEncode(cEstrat)+' > '+cBookEncode(cPerspe))
		        
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F5F5F3">')
             
		If !lPrimeiro
			oHtmFile:nWriteLN('<tr>')	
			oHtmFile:nWriteLN('<td width="100%" height="25" colspan="4">')  

	   		If lQuebra
				oHtmFile:nWriteLN('<img src="'+cPathSite+'imagens/linha_fundo.jpg" width="100%" height="5"/>')
    		EndIf
    		
			oHtmFile:nWriteLN('</td></tr>')    		
  		EndIf

		If lQuebra
			cHierarq := cBookEncode(oScore:cValue("NOME"))+' > '+cBookEncode(cEstrat)+' > '+cBookEncode(cPerspe)
		      
			oHtmFile:nWriteLN('<tr>')  
			If cTipo == "2"      
				oHtmFile:nWriteLN('<td width="10%" height="25" align="center"><img src="'+cPathSite+'imagens/icone_objetivo.gif" height="40"></td>')
			Else                                                                                                                    
				oHtmFile:nWriteLN('<td width="5%" height="25"><img src="'+cPathSite+'imagens/icone_objetivo.gif" height="40"></td>')
			EndIf
			oHtmFile:nWriteLN('<td width="90%" height="10" colspan="2"><strong><font size="4">'+cHierarq+'</font></strong></td>')
	                     
			If cTipo == "1"
				If lPrimeiro
					If Len(cReportName) > 5
						oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="'+cReportName+'"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
					Else
						oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="REL055.html"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
					EndIf
					lPrimeiro := .F.
				Else
					oHtmFile:nWriteLN('<td width="5%" height="40" />')
				EndIf      
			EndIf				

			oHtmFile:nWriteLN('</tr>')								
		EndIf		

		oScore:lGoTo(nRec)
		oHtmFile:nWriteLN('<tr>')                          
		If lQuebra
			oHtmFile:nWriteLN('<td width="5%" height="25"></td>')		
		Else
			oHtmFile:nWriteLN('<td width="5%" height="25">&nbsp;</td>')				
		EndIf
		
		oHtmFile:nWriteLN('<td width="85%" colspan="2"><strong><font size="3" color="#000080">'+cBookEncode(oScore:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
		oHtmFile:nWriteLN('<td width="10%"></td>')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%" height="25" />')		
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0019)+'</strong></td>')//Descricao:
		oHtmFile:nWriteLN('<td width="75%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oScore:cValue("DESCRICAO"))+'</td>')
      	oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="5" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
			                                 
		oUser:lSeek(1,{oScore:cValue("RESPID")})//ID   
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="5%" height="10">')
		oHtmFile:nWriteLN('<td width="10%" height="10"><strong>'+KPIEncode(STR0035)+'</strong></td>')//Responsavel:
		oHtmFile:nWriteLN('<td width="75%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oUser:cValue("COMPNOME"))+'</td>')
        oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('</tr>')    
		
		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="20" colspan="4">')
		oHtmFile:nWriteLN('</tr>')

		If oInd:lSeek(3,{aObj[nI]})//ID_SCOREC
                        
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink"><a href="javascript:dinMenu('+cIndTab+');">'+KPIEncode(STR0036)+'</a></a></td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('<td width="85%" colspan="2"><table id="'+cIndTab+'" style="display:none;" width="100%" border="0"   cellpadding="2" cellspacing="2">')
		  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="35%" colspan="2" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0037)+'</td>')//Indicadores
			oHtmFile:nWriteLN('<td width="20%" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0057)+'</td>')//Frequencia
			oHtmFile:nWriteLN('<td width="20%" align="center" height="20" bgcolor="#7BA0CA">'+KPIEncode(STR0058)+'</td>')//Orientacao
			oHtmFile:nWriteLN('</tr>')
	    
	    	While oInd:cValue("ID_SCOREC") == aObj[nI]  

				oHtmFile:nWriteLN('<tr>')
				oHtmFile:nWriteLN('<td width="35%" colspan="2" height="20" class="texto3">'+cBookEncode(oInd:cValue("NOME"))+'</td>')
				oHtmFile:nWriteLN('<td width="20%" height="20" class="texto3">'+cBookEncode(oInd:cGetFreqName(oInd:nValue("FREQ")))+'</td>')
				If oInd:lValue("ASCEND")
					oHtmFile:nWriteLN('<td width="20%" height="20" class="texto3">'+KPIEncode(STR0044)+'</td>')//Quanto Maior Melhor
				Else
					oHtmFile:nWriteLN('<td width="20%" height="20" class="texto3">'+KPIEncode(STR0045)+'</td>')//Quanto Menor Melhor
				EndIf		
				oHtmFile:nWriteLN('</tr>')
				
				oInd:_Next()
			End

			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
				  
		Else
		
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="2" style="background-color: #EEE9E9;" class="textolink">'+KPIEncode(STR0062)+'</td>')//Sem Indicadores
			oHtmFile:nWriteLN('<td width="10%">')
			oHtmFile:nWriteLN('</tr>')						
								
		EndIf                     
		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="20" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')       
    	
	Next    

	If cTipo == "1"
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')	
		
		//Faz a copia do relatorio para o diretorio de Spool
		oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + 'REL055_Obj_'+cReportName, cKpiPath)
		oHtmFile:lClose()
		oKPICore:Log(STR0003+cNome+"KPI055_Obj]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/  
	EndIf

Return
                              

/*-------------------------------------------------------------------------------------------------------
* MONTA RELATORIO DE INDICADORES
*-------------------------------------------------------------------------------------------------------*/
Method RelBookInd(aInd,cNome,cKpiPath,cPathSite,cReportName,oHtmOrig, cTipo) Class TKPI055
        
	Local oScore	:= ::oOwner():oGetTable("SCORECARD")
	Local oUser		:= ::oOwner():oGetTable("USUARIO")   
	Local oGrupo    := ::oOwner():oGetTable("GRUPO")
	Local oInd		:= ::oOwner():oGetTable("INDICADOR")       
	Local oUnidade	:= ::oOwner():oGetTable("UNIDADE")
	Local oPlanilha	:= ::oOwner():oGetTable("PLANILHA")
	Local oXMLLista	:= TBIXMLAttrib():New()                         

	Local oHtmFile
	Local nI, nX         
	Local nRec        
	Local cObjet
	Local cEstrat
	Local cPerspe    
	Local cFreq    
	Local cCol
	Local cWidth       
	Local lPrimeiro	:= .T.
	Local cPlanTab            
	
    Local cHierarq 	:= ""     
    Local lQuebra	:= .T.	  
    Local cUser    
    
    Default oHtmOrig := Nil
    Default cTipo    := "1"
    
    If oHtmOrig != Nil
    	oHtmFile := oHtmOrig
    EndIf
	     
	If cTipo == "1"
	    oHtmFile := TBIFileIO():New(cKpiPath+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL055_Ind_"+cReportName)
		If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			oKPICore:Log(STR0038 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL055_Ind"*/
			oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
			return KPI_ST_GENERALERROR
		endif
	
		// MONTAGEM DO CABECALHO DA PAGINA
		oHtmFile:nWriteLN('<html>')
		oHtmFile:nWriteLN('<head>')
		oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
		oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')  
		oHtmFile:nWriteLN('<META HTTP-EQUIV="Pragma" CONTENT="no-cache"> ')
        oHtmFile:nWriteLN('<META HTTP-EQUIV="Expires" CONTENT="-0"> ')
	   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	
		oHtmFile:nWriteLN(' <script language="javascript">')    
		
		oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
		oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
		oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')                                                                    
		                         
		oHtmFile:nWriteLN(' 	function dinMenu( x )')
		oHtmFile:nWriteLN(' 	{')
		oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
		oHtmFile:nWriteLN(' 			x.style.display = "";')
		oHtmFile:nWriteLN(' 		else')
		oHtmFile:nWriteLN(' 			x.style.display = "none";')
		oHtmFile:nWriteLN(' 	}')
		oHtmFile:nWriteLN('	</script>')
	   	
		oHtmFile:nWriteLN('</head>')         
	
		oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="150" align="center" ><img src="'+cPathSite+'imagens/art_logo_clie.sgi" ></td>')   
	
		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Book de Planejamento Estratégico  		
		oHtmFile:nWriteLN('<br><br><span class="titulo2">'+KPIEncode(STR0016)+'</span>')//Indicador
		oHtmFile:nWriteLN('</div></td>')
	   	   		
		oHtmFile:nWriteLN('<td width="150" class="titulo2"><div align="center">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>') 
	EndIf
                             
    cHierarq := ""     
	For nI := 1 To Len(aInd)
		
		oInd:lSeek(1,{aInd[nI]})//ID_SCOREC
		oScore:lSeek(1,{oInd:cValue("ID_SCOREC")})//ID
		nRec := oScore:nRecno()
 	   	cObjet	:= oScore:cValue("NOME")
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cPerspe := oScore:cValue("NOME")
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cEstrat := oScore:cValue("NOME")
		oScore:lSeek(1,{oScore:cValue("PARENTID")})//PARENTID
		cPlanTab := "planTab"+alltrim(aInd[nI])                    
		          
		lQuebra := !(cHierarq == cBookEncode(oScore:cValue("NOME"))+' > '+cBookEncode(cEstrat)+' > '+cBookEncode(cPerspe)+' > '+cBookEncode(cObjet))
		
		oHtmFile:nWriteLN('<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#F5F5F3">')
             
		If !lPrimeiro
			oHtmFile:nWriteLN('<tr>')	
			oHtmFile:nWriteLN('<td width="100%" height="25" colspan="7">')  

	   		If lQuebra
				oHtmFile:nWriteLN('<img src="'+cPathSite+'imagens/linha_fundo.jpg" width="100%" height="5"/>')
    		EndIf
    		
			oHtmFile:nWriteLN('</td></tr>')    		
  		EndIf

		If lQuebra
			cHierarq := cBookEncode(oScore:cValue("NOME"))+' > '+cBookEncode(cEstrat)+' > '+cBookEncode(cPerspe)+' > '+cBookEncode(cObjet)

			oHtmFile:nWriteLN('<tr>')     
			If cTipo == "2"
				oHtmFile:nWriteLN('<td width="10%" height="25" align="center"><img src="'+cPathSite+'imagens/icone_indicador.gif" height="40"></td>')
			Else
				oHtmFile:nWriteLN('<td width="5%" height="25"><img src="'+cPathSite+'imagens/icone_indicador.gif" height="40"></td>')
			EndIf
			oHtmFile:nWriteLN('<td width="90%" height="10" colspan="5"><strong><font size="4">'+cHierarq+'</font></strong></td>')
                            
			If cTipo == "1"
				If lPrimeiro
					If Len(cReportName) > 5
						oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="'+cReportName+'"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
					Else
						oHtmFile:nWriteLN('<td width="5%" height="40" align="right"><a href="REL055.html"><br><img src="'+cPathSite+'imagens/ic_20_voltar.gif"  border="0"/></a></td>')
					EndIf
					lPrimeiro := .F.       
				Else
					oHtmFile:nWriteLN('<td width="5%" height="40"/>')
				EndIf		        
			EndIf
			
			oHtmFile:nWriteLN('</tr>')		
		EndIf                  

		oHtmFile:nWriteLN('<tr>')                          
		If lQuebra
			oHtmFile:nWriteLN('<td width="5%" height="25"></td>')		
		Else
			oHtmFile:nWriteLN('<td width="5%" height="25">&nbsp;</td>')				
		EndIf
		
		oHtmFile:nWriteLN('<td width="90%" colspan="5"><strong><font size="3" color="#000080">'+cBookEncode(oInd:cValue("NOME"))+'</font></strong><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10"></td>')
		oHtmFile:nWriteLN('<td width="5%"></td>')
		oHtmFile:nWriteLN('</tr>')
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="10">')
		oHtmFile:nWriteLN('<td width="10%" ><strong>'+KPIEncode(STR0019)+'</strong></td>')//Descricao:
		oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oInd:cValue("DESCRICAO"))+'</td>')
		oHtmFile:nWriteLN('<td width="5%"/>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="7">')
		oHtmFile:nWriteLN('</tr>')
		                       
		oUnidade:lSeek(1,{oInd:cValue("UNIDADE")})
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%"/>')

		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0040)+'</strong></td>')//Unidade:
		oHtmFile:nWriteLN('<td width="25%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oUnidade:cValue("NOME"))+'</td>')
		oHtmFile:nWriteLN('<td width="15%"/>')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0041)+'</strong></td>')//Nº Decimais:
		oHtmFile:nWriteLN('<td width="25%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oInd:cValue("DECIMAIS"))+'</td>')
		oHtmFile:nWriteLN('<td width="5%"/>')
		oHtmFile:nWriteLN('</tr>')
				                       
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="7">')
		oHtmFile:nWriteLN('</tr>')

		cFreq := oInd:cGetFreqName(oInd:nValue("FREQ"))
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0042)+'</strong></td>')//Frequencia:
		oHtmFile:nWriteLN('<td width="25%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(cFreq)+'</td>')
		oHtmFile:nWriteLN('<td width="15%" />')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0043)+'</strong></td>')//Orientacao:
		If oInd:lValue("ASCEND")		
			oHtmFile:nWriteLN('<td width="25%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+KPIEncode(STR0044)+'</td>')//Quanto Maior Melhor
		Else
			oHtmFile:nWriteLN('<td width="25%" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+KPIEncode(STR0045)+'</td>')//Quanto Menor Melhor
		EndIf
		oHtmFile:nWriteLN('<td width="5%"/>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="7">')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="10">')
		oHtmFile:nWriteLN('<td width="10%" ><strong>'+KPIEncode(STR0046)+'</strong></td>')//Desc. Metrica:
		oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(oInd:cValue("VERIFICA"))+'</td>')
		oHtmFile:nWriteLN('<td width="5%"/>')
		oHtmFile:nWriteLN('</tr>')

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="7">')
		oHtmFile:nWriteLN('</tr>')
	
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" />')
		oHtmFile:nWriteLN('<td width="10%" ><strong>'+KPIEncode(STR0047)+'</strong></td>')//Forma de Coleta
                                         
		If oInd:cValue("TIPO_ATU") == MANUAL             
			oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+KPIEncode(STR0048)+'</td>')//Manual
		ElseIf oInd:cValue("TIPO_ATU") == VIA_PLAN //via planilha                                                                                                                  
			oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+KPIEncode(STR0049)+'</td>')//Via Planilha
		Else//via fonte de dados                                                                                                                                               
			oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+KPIEncode(STR0050)+'</td>')//Via Fonte de Dados
		EndIf             
		oHtmFile:nWriteLN('<td width="5%"/>')
		oHtmFile:nWriteLN('</tr>')
                 
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="7">')
		oHtmFile:nWriteLN('</tr>')
	
		If (oInd:cValue("TP_RESP") == TIPO_USUARIO)
        	oUser:lSeek(1,{oInd:cValue("ID_RESP")})//ID
        	cUser := oUser:cValue("COMPNOME")
		Else//TIPO_GRUPO
			oGrupo:lSeek(1,{oInd:cValue("ID_RESP")})//ID
			cUser := oGrupo:cValue("NOME")
		EndIf
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="10">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0055)+'</strong></td>')//Resp. Indicador:
		oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(cUser)+'</td>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('</tr>')
		        
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="5" colspan="7">')
		oHtmFile:nWriteLN('</tr>')            
                  
		If (oInd:cValue("TP_RESPCOL") == TIPO_USUARIO)
			oUser:lSeek(1,{oInd:cValue("ID_RESPCOL")})//ID
        	cUser := oUser:cValue("COMPNOME")
		Else//TIPO_GRUPO
			oGrupo:lSeek(1,{oInd:cValue("ID_RESPCOL")})//ID
			cUser := oGrupo:cValue("NOME")
		EndIf

		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="10%" height="10">')
		oHtmFile:nWriteLN('<td width="10%"><strong>'+KPIEncode(STR0056)+'</strong></td>')//Resp. Coleta:
		oHtmFile:nWriteLN('<td width="75%" colspan="4" style="border-style: solid; border-width: 3" bordercolor="#E4EAEF" bgcolor="white">'+cBookEncode(cUser)+'</td>')
		oHtmFile:nWriteLN('<td width="5%">')
		oHtmFile:nWriteLN('</tr>')		
		
		oHtmFile:nWriteLN('<tr>')
		oHtmFile:nWriteLN('<td width="100%" height="20" colspan="7"/>')
		oHtmFile:nWriteLN('</tr>')		
		
		If oPlanilha:lSoftSeek(2,{oInd:cValue("ID")})//PARENTID, ANO, MES, DIA

			oXMLLista := oPlanilha:montaCabPeriodo(oInd:nValue("FREQ"))
			aTagCab   := aBookPlan(oXMLLista)        
			
			cWidth 	:= cValToChar(100/Len(aTagCab))
	
			cCol	:= cValToChar(Len(aTagCab))   
			  
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="10%">')
	        oHtmFile:nWriteLN('<td width="85%" colspan="5" style="background-color: #EEE9E9;" class="textolink"><a href="javascript:dinMenu('+cPlanTab+');">'+KPIEncode(STR0051)+'</a></a></td>')//Planilha de Valores
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('</tr>')

			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('<td width="95%" colspan="5"><table id="'+cPlanTab+'" style="display:none;" width="100%"  border="0" cellpadding="2" cellspacing="2">')
		  
			oHtmFile:nWriteLN('<tr>')				
			For nX := 1 To Len(aTagCab)
	
				oHtmFile:nWriteLN('<td width="'+cWidth+'%" align="center" height="20" bgcolor="#7BA0CA">'+aTagCab[nX][CAB]+'</td>')
			
			Next
			oHtmFile:nWriteLN('</tr>')
		
			While oPlanilha:cValue("PARENTID") == oInd:cValue("ID")
				
				oHtmFile:nWriteLN('<tr>')							 
			                     
				For nX := 1 To Len(aTagCab)
		                                      
					If (aTagCab[nX][TAG]) $ "DIA/MES/ANO"
						oHtmFile:nWriteLN('<td width="'+cWidth+'%" align="right" height="20" class="texto3">'+cBookEncode(oPlanilha:cValue(aTagCab[nX][TAG]))+'</td>')
					Else
						oHtmFile:nWriteLN('<td width="'+cWidth+'%" align="right" height="20" class="texto3">'+Transform(val(cBookEncode(oPlanilha:cValue(aTagCab[nX][TAG]))),('@E 999,999,999,999.'+Pad('',oInd:nValue("DECIMAIS"),'9')))+'</td>')
					EndIf
				
				Next
				
				oHtmFile:nWriteLN('</tr>')
				oPlanilha:_Next()   
			
			End     

			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
		
		Else	
			
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="5%">')
	        oHtmFile:nWriteLN('<td width="95%" colspan="5" style="background-color: #EEE9E9;" class="textolink">'+KPIEncode(STR0063)+'</td>')//Sem Planilha de Valores
			oHtmFile:nWriteLN('<td width="5%">')
			oHtmFile:nWriteLN('</tr>')
									
		EndIf                     
		oHtmFile:nWriteLN('<tr>')
        oHtmFile:nWriteLN('<td height="20" colspan="4">')
		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')

	Next   
	
	If cTipo == "1" 
		oHtmFile:nWriteLN('</body>')
		oHtmFile:nWriteLN('</html>')	
		
		//Faz a copia do relatorio para o diretorio de Spool
		oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + 'REL055_Ind_'+cReportName, cKpiPath)
		oHtmFile:lClose()
		oKPICore:Log(STR0003+cNome+"KPI055_Ind]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/      
	EndIf

Return
 
                 
/*-------------------------------------------------------------------------------------------------------
*  SEPARA OS SCORECARDS SELECIONADOS
*-------------------------------------------------------------------------------------------------------*/
Method aMntScore(aRelBook) Class TKPI055
	Local lRet 		:= .F.
	Local oSelect	:= ::oOwner():oGetTable("RELBOOKXSCOR")
	Local oScore	:= ::oOwner():oGetTable("SCORECARD")
	Local oIndic	:= ::oOwner():oGetTable("INDICADOR")
	
	Local aOrganiza	:= {}
	Local aEstrat	:= {}
	Local aPerspec	:= {}
	Local aObjetivo	:= {}
	Local aIndic	:= {}
	
    oSelect:setOrder(1)//ID_RELIND,ID_SCOREC
	oSelect:_First()  
	oScore:setOrder(1)//ID
		                 
	//SELECIONA TODOS OS OBJETIVOS MARCADOS NA ARVORE
	While (!oSelect:lEof())
	    lRet := .T.
		If oScore:lSeek(1,{oSelect:cValue("ID_SCOREC")})
			If ( oScore:lChkAccess() )  
				Do Case
					Case oScore:cValue("TIPOSCORE") == CAD_ORGANIZACAO
						aAdd(aOrganiza,oSelect:cValue("ID_SCOREC"))
					
					Case oScore:cValue("TIPOSCORE") == CAD_ESTRATEGIA
						aAdd(aEstrat,oSelect:cValue("ID_SCOREC"))
					
					Case oScore:cValue("TIPOSCORE") == CAD_PERSPECTIVA      
						aAdd(aPerspec,oSelect:cValue("ID_SCOREC"))
					
					Case oScore:cValue("TIPOSCORE") == CAD_OBJETIVO
						aAdd(aObjetivo,oSelect:cValue("ID_SCOREC"))
						
						oIndic:setOrder(3)//ID_SCOREC - ID DO SCORECARD
						If oIndic:lSeek(3,{oSelect:cValue("ID_SCOREC")})				
							While (!oIndic:lEof()) .And. (oIndic:cValue("ID_SCOREC") == oSelect:cValue("ID_SCOREC"))
								aAdd(aIndic,oIndic:cValue("ID"))		
								oIndic:_Next()							   
							End					
						EndIf					
				EndCase		
		    EndIf
		EndIf				
		oSelect:_Next()	
	End

	aAdd(aRelBook,aOrganiza) 
	aAdd(aRelBook,aEstrat)
	aAdd(aRelBook,aPerspec)
	aAdd(aRelBook,aObjetivo)
	aAdd(aRelBook,aIndic)
Return lRet
                    

/*-------------------------------------------------------------------------------------------------------
*  VERIFICA SE O TEXTO E VAZIO
*-------------------------------------------------------------------------------------------------------*/
Static Function cBookEncode(cTexto)               

	cTexto := KPIEncode(Alltrim(cTexto))
	
	If Empty(cTexto)
	
		cTexto := "&nbsp;"

	EndIf

Return cTexto
                                

/*-------------------------------------------------------------------------------------------------------
*  MONTA ARRAY COM TAG E CAB DA TABELA DE PLANILHA
*-------------------------------------------------------------------------------------------------------*/
Static Function aBookPlan(oBIXMLLista)

	Local aRet	:= {}
	Local nI	:= 0
	Local cNum
    Local cTAG
    Local cCAB
	
	cNum 	:= PADL(nI,3,'0')
	cTAG	:= oBIXMLLista:cValue("TAG"+cNUM)
	cCAB	:= oBIXMLLista:cValue("CAB"+cNUM)
	
	While (cTAG != nil) .And. (cCAB != nil)
	            
	    aAdd(aRet,{cTAG,cCAB})
		
		nI 		+= 1	
		cNum 	:= PADL(nI,3,'0')
		cTAG	:= oBIXMLLista:cValue("TAG"+cNUM)
		cCAB	:= oBIXMLLista:cValue("CAB"+cNUM)
	
	End
	

Return aRet  
              
/*-------------------------------------------------------------------------------------------------------
*  CRIA LINHA DIVISORIA A SER UTILIZADA NO MODELO EXPANDIDO
*-------------------------------------------------------------------------------------------------------*/
Static Function impDivisao(oHtmFile, cPathSite)  

oHtmFile:nWriteLN('<tr>')     
	oHtmFile:nWriteLN('<td colspan="2">') 
		oHtmFile:nWriteLN('<table width="100%" height="20" bgcolor="#F5F5F3" border="0" align="left" cellpadding="0" cellspacing="0">')
		oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td width="100%" colspan="2" ><img src="'+cPathSite+'imagens/linhadivisoriatitulo.jpg" width="100%" height="10" /></td>')
		oHtmFile:nWriteLN('</tr>') 
		oHtmFile:nWriteLN('</table>')
	oHtmFile:nWriteLN('</td>')
oHtmFile:nWriteLN('</tr>') 

Return  

/*-------------------------------------------------------------------------------------------------------
*  CRIA ESPAÇAMENTO NO MODELO, DEFINIDO PELO PARÂMETRO RECEBIDO
*-------------------------------------------------------------------------------------------------------*/
Static Function impEspaco(oHtmFile, cTam)  

	oHtmFile:nWriteLN('<tr>')
	oHtmFile:nWriteLN('<td height="'+cTam+'"></td>')
	oHtmFile:nWriteLN('</tr>') 

Return
 
 
/*-------------------------------------------------------------------------------------------------------
*  FUNCTION
*-------------------------------------------------------------------------------------------------------*/
Function _KPI055_RelBook()
Return Nil