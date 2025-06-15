// ######################################################################################
// Projeto: KPI
// Modulo : Relatório de Indicadores
// Fonte  : KPI056_RelInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.10.11 | Tiago Tudisco
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI056_RelInd.ch"

/*--------------------------------------------------------------------------------------
@class TKPI056
@entity RelInd
Relatório de Indicadores
@table KPI056
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELIND"
#define TAG_GROUP  "RELINDS"
#define TEXT_ENTITY STR0001/*//"Relatório de Indicador"*/
#define TEXT_GROUP  STR0002/*//"Relatório de Indicadores"*/
                              
//aValores
#define VAL_REAL			1
#define VAL_META			2
#define VAL_REAL_ACU		3
#define VAL_META_ACU		4
#define VAL_REAL_STATUS		5
#define VAL_ACUM_STATUS		6
#define VAL_PREVIA			7     

class TKPI056 from TBITable
	//CONSTRUTUOR
	Method New() constructor
	Method NewKPI056()

	// REGISTRO ATUAL
	Method oToXMLNode(cId)
	Method nUpdFromXML(oXML, cPath)
	
	// EXECUTAR 
	Method nExecute(cID, cExecCMD)   
	
	Method KPIRelIndJob(aParms)
	Method KPIBuscaObj()
	Method KPIBuscaGrp()
	Method KPIRelGrpJob(aParms)
endclass           


/*-------------------------------------------------------------------------------------------------------
*  CONSTRUTOR
*-------------------------------------------------------------------------------------------------------*/
method New() class TKPI056
	::NewKPI056()
return
method NewKPI056() class TKPI056
	
	// Table
	::NewTable("SGI056")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C", 010))
	::addField(TBIField():New("NOME"		,"C", 060))
	::addField(TBIField():New("DESCRICAO"	,"C", 255))
	::addField(TBIField():New("IMPDESC"	,"L"	 )) //	Imprime descrição.
	::addField(TBIField():New("DTALVO"		,"D"	 ))	// 	Data Alvo.
	::addField(TBIField():New("DTDE"		,"D"	 ))	// 	Acumulado de.
	::addField(TBIField():New("DTATE"		,"D"	 ))	// 	Até.
//	::addField(TBIField():New("ATEDATA"	,"D"	 ))
	::addField(TBIField():New("SITUACAO"	,"N"	 ))	// 	0-Atingido, 1-Nao Atingido, 2-Dentro da Tolerância, 3-Todos
	::addField(TBIField():New("TIPOREL"	,"N"	 ))	//	Tipo de relatório ( 0 - Entidades(objetivos) ou 1 - Grupo de indicadores )

	// Indexes
	::addIndex(TBIIndex():New("SGI056I01",{"ID"},.T.))

return      
    
/*-------------------------------------------------------------------------------------------------------
*  CARREGAR
*-------------------------------------------------------------------------------------------------------*/
method oToXMLNode(cId) class TKPI056
	Local aFields
	Local nInd
	Local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)
	Local aSelNode	:= {}  
	Local aSelNodeGrp	:= {}

	::_First()

	// Acrescenta os valores ao XML.
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

	// Acrescenta Children.
	aSelNode := ::oOwner():oGetTable("RELINDXSCOR"):aNodeSelect(cId)
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oArvore(.T.,"0",.T.,aSelNode))
	
	// Acrescenta o grupo de indicadores.
	aSelNodeGrp := ::oOwner():oGetTable("RELINDXGRPIND"):aNodeSelect(cId)
	oXMLNode:oAddChild(::oOwner():oGetTable("GRUPO_IND"):oArvore(aSelNodeGrp))
	
return oXMLNode             
             
/*-------------------------------------------------------------------------------------------------------
*  ATUALIZA AS ENTIDADES
*-------------------------------------------------------------------------------------------------------*/
Method nUpdFromXML(oXML, cPath) Class TKPI056

	Local nStatus := KPI_ST_OK,	cID, nInd, oTable, cNome, nQtdReg, aObj := {}
	Local oRelIndxScor := ::oOwner():oGetTable("RELINDXSCOR")
	Local oRelIndxGrp := ::oOwner():oGetTable("RELINDXGRPIND")
	Local cScorAlt	:= xBIConvTo("C", oXML:_REGISTROS:_RELIND:_SCORECARDS:TEXT)
	Local nFoundScor:= 0
	Local nFoundProj:= 0
	Local aScorAlt	:= {}
	Local aProjAlt	:= {}
						
	Private oXMLInput := oXML
	
	// Controla os registros que o usuário solicitou alteração.
	cScorAlt	:= strTran(cScorAlt, "[", "")
  	cScorAlt	:= strTran(cScorAlt, "]", "")
	aScorAlt	:= aBIToken(alltrim(cScorAlt),",",.f.)

	aFields := ::xRecord(RF_ARRAY) 

	// Extrai Valores do XML.
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		If(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		EndIf
	Next
            
	// Verifica condições de gravação (APPEND ou UPDATE).
	::oOwner():oOltpController():lBeginTransaction()
	
	::SetOrder(1) // POR ORDEM DE ID
	::cSQLFilter("ID = '"+cBIStr(cID)+"'") // Filtra pelo pai.
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
		
		// Caso a opção selecionada seja por ENTIDADES.
		If ::nValue("TIPOREL") == 0
		
			// Exclui os registros de Grupo de indicadores.
		    oRelIndxGrp:setOrder(2)
		    oRelIndxGrp:lSoftSeek(2,{cID})
			While(!oRelIndxGrp:lEof() .And. Alltrim(oRelIndxGrp:cValue("ID_RELIND")) == Alltrim(cID))
				//Não encontrou no Xml Apagar.
				If(!oRelIndxGrp:lDelete())
					nStatus := KPI_ST_INUSE
					Exit							
				EndIf
				oRelIndxGrp:_Next()
			End	

			//Atualizando os valores do ScoreCard.
			If(Valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD")) != "U")
		
				aRegNode := &("oXMLInput:"+cPath+":_SCORECARDS")// Pegando os valores do scorecards.
		
				If(Valtype(aRegNode:_SCORECARD) != "A")
					aObj := { aRegNode:_SCORECARD }
				Else
					aObj := aRegNode:_SCORECARD
				EndIf	
			    oRelIndxScor:setOrder(2)
			    oRelIndxScor:lSoftSeek(2,{cID})
				While(!oRelIndxScor:lEof() .And. Alltrim(oRelIndxScor:cValue("ID_RELIND")) == Alltrim(cID))
					nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == Alltrim(oRelIndxScor:cValue("ID_SCOREC"))})
					If(nFoundItem == 0)
						//Não encontrou no XML, apaga.
						If(!oRelIndxScor:lDelete())
							nStatus := KPI_ST_INUSE
							Exit							
						EndIf
					EndIf    
		
					oRelIndxScor:_Next()
				End
		
				If(Valtype(aRegNode:_SCORECARD) == "A")
					For nQtdReg := 1 To Len(aRegNode:_SCORECARD)
						nStatus	:= oRelIndxScor:nInsFromXML(cId, aRegNode:_SCORECARD[nQtdReg])
						If(nStatus != KPI_ST_OK)
							Exit
						EndIf
					Next nQtdReg
				ElseIf(Valtype(aRegNode:_SCORECARD) == "O")
					nStatus	:= oRelIndxScor:nInsFromXML(cId, aRegNode:_SCORECARD)
				EndIf
			Else
				//Caso não encontrou exclui tudo.
			    oRelIndxScor:setOrder(2)
			    oRelIndxScor:lSoftSeek(2,{cID})
				While(!oRelIndxScor:lEof() .And. Alltrim(oRelIndxScor:cValue("ID_RELIND")) == Alltrim(cID))
					//Não encontrou no Xml Apagar.
					If(!oRelIndxScor:lDelete())
						nStatus := KPI_ST_INUSE
						Exit							
					EndIf
					oRelIndxScor:_Next()
				End
			EndIf
		// Caso a opção selecionada seja por GRUPO DE INDICADORES.
		Else
			// Exclui os registro de ScoreCards.
			oRelIndxScor:setOrder(2)
			oRelIndxScor:lSoftSeek(2,{cID})
			While(!oRelIndxScor:lEof() .And. Alltrim(oRelIndxScor:cValue("ID_RELIND")) == Alltrim(cID))
				//Não encontrou no Xml Apagar.
				If(!oRelIndxScor:lDelete())
					nStatus := KPI_ST_INUSE
					Exit							
				EndIf
				oRelIndxScor:_Next()
			End
		
			// Atualizando os valores do Grupo de indicadores.
			If(Valtype(XmlChildEx(&("oXMLInput:"+cPath+":_GRUPO_INDS"), "_GRUPO_IND")) != "U")
											
				aRegNode := &("oXMLInput:"+cPath+":_GRUPO_INDS") // Pegando os valores dos grupos de indicadores.
		
				If(Valtype(aRegNode:_GRUPO_IND) != "A")
					aObj := { aRegNode:_GRUPO_IND }
				Else
					aObj := aRegNode:_GRUPO_IND
				EndIf

				oRelIndxGrp:setOrder(2)
			   	oRelIndxGrp:lSoftSeek(2,{cID})
				While(!oRelIndxGrp:lEof() .And. Alltrim(oRelIndxGrp:cValue("ID_RELIND")) == Alltrim(cID))
					nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == Alltrim(oRelIndxGrp:cValue("ID_GRPIND"))})
					If(nFoundItem == 0)
						//Não encontrou no XML, apaga.
						If(!oRelIndxGrp:lDelete())
							nStatus := KPI_ST_INUSE
							Exit							
						EndIf
					EndIf    
		
					oRelIndxGrp:_Next()
				End
		
				If(Valtype(aRegNode:_GRUPO_IND) == "A")
					For nQtdReg := 1 To Len(aRegNode:_GRUPO_IND)
						nStatus	:= oRelIndxGrp:nInsFromXML(cId, aRegNode:_GRUPO_IND[nQtdReg])
						If(nStatus != KPI_ST_OK)
							Exit
						EndIf
					Next nQtdReg
				ElseIf(Valtype(aRegNode:_GRUPO_IND) == "O")
					nStatus	:= oRelIndxGrp:nInsFromXML(cId, aRegNode:_GRUPO_IND)
				EndIf			
			Else
				//Caso não encontrou exclui tudo.
			    oRelIndxGrp:setOrder(2)
			    oRelIndxGrp:lSoftSeek(2,{cID})
				While(!oRelIndxGrp:lEof() .And. Alltrim(oRelIndxGrp:cValue("ID_RELIND")) == Alltrim(cID))
					//Não encontrou no Xml Apagar.
					If(!oRelIndxGrp:lDelete())
						nStatus := KPI_ST_INUSE
						Exit							
					EndIf
					oRelIndxGrp:_Next()
				End			
			EndIf
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
Method nExecute(cID, cExecCMD) Class TKPI056
	
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
		// 4 - Scorecard de
		aAdd(aParms, ::dValue("DTALVO"))
		// 5 - Scorecard ate
//		aAdd(aParms, ::dValue("ATEDATA"))
		// 6 - Listar Indicadores?
		aAdd(aParms, ::nValue("SITUACAO"))
		// 7 - ID do Relatório
		aAdd(aParms, ::cValue("ID"))
		// 8 - KPIPATH da Working THREAD
		aAdd(aParms, ::oOwner():cKpiPath())
		// 9 - Nome do arquivo que sera salvo
		aAdd(aParms,cExecCMD )
		// 10 - Diretorio do site.
		aAdd(aParms, strtran(cPathSite,"\","/"))
		// 11 - Acumulado de.
		aAdd(aParms, ::dValue("DTDE"))
		// 12 - Até
		aAdd(aParms, ::dValue("DTATE"))


		// Tipo de relatório ( 0 - Entidades | 1 - Grupo de indicadores )		
		If ::nValue("TIPOREL") == 0
			// Executando JOB	
			nStatus := ::KPIRelIndJob(aParms)
		Else
			// Executando JOB	
			nStatus := ::KPIRelGrpJob(aParms)
		EndIf

		
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
Method KPIRelIndJob(aParms) Class TKPI056

	Local cNome
	Local cDescricao
	Local lImpDesc
	Local dDataAlvo
	Local dDataDe
	Local dDataAte
//	Local dDataAte
	Local nSituacao
	Local cID
	Local cKpiPath
	Local cReportName
	Local cPathSite   
	Local nI,nY,nX,nJ  
	Local nTipoRel	:= 0
	
	Local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	Local oPlanilha	:= ::oOwner():oGetTable("PLANILHA") 
	Local oScorecard	:= ::oOwner():oGetTable("SCORECARD")
	Local oObj			:= ::oOwner():oGetTable("OBJETIVO")
		                     
	Local aRelInd		:= {}   
	Local aEstrat		:= {}
	Local aPerspec	:= {}
	Local aObjetivo	:= {}
	Local oHtmFile            

	Local cNomeOrg
	Local cNomeEstrat
	Local cNomePers
	      
	Local nTotPeso	:= 0
	Local nTotPesoV	:= 0     
	Local nPercent	:= 0   
	Local nCor			:= 1 	// ALTERNA COR DA LINHA NA TABELA DE INDICADORES
	Local nCntObj		:= 0 	// Contador para objetivos.
	Local aObjs		:= {}	// Receberá um array com (ID e NOME) do objetivo.
	Local cHtml		:= ""
	Local aHtml		:= {}
	Local nCntInd		:= 0
	
	Local cTipoAtu	:= STR0030 // "Vazio"
	
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao	:= aParms[2]	
	// 3 - Imprime Descrição?
	lImpDesc	:= aParms[3]	
	// 4 - Scorecard de
	dDataAlvo	:= aParms[4]
	// 5 - Scorecard ate
//	dDataAte	:= aParms[5]	
	// 6 - Listar Indicadores?
	nSituacao	:= aParms[5]	
	// 7 - ID do Relatório
	cID			:= aParms[6]	
	// 8 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[7]	
	// 9 - Nome do arquivo que sera salvo
	cReportName	:= aParms[8]
	// 10 - Diretorio do site.
	cPathSite	:= aParms[9]
	// 11 - Acumulado De.
	dDataDe	:= aParms[10]
	// 12 - Até
	dDataAte	:= aParms[11]

    //FILTRA TODOS OS OBJETIVOS SELECIONADOS
    aRelInd := ::KPIBuscaObj(nSituacao,dDataAlvo)

	
    //Cria o arquivo HTML.
    oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL056_" + alltrim(cID) + ".html")
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0005 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL056_"*/
		oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return KPI_ST_GENERALERROR
	endif

	// MONTAGEM DO CABECALHO DA PAGINA
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>')//SGI - Sistema de Gestão de Indicadores
	oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	oHtmFile:nWriteLN('</head>')         

	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	                                            	
	If (Len(aRelInd) > 0 )      

	    //MONTA CABECADO DE EXIBICAO DO RELATORIO
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
  		oHtmFile:nWriteLN('<tr>')
   		oHtmFile:nWriteLN('<td width="150" align="center"><img src="'+cPathSite+'/imagens/art_logo_clie.sgi"></td>')   

   		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Relatório de Indicadores   		

   		//IMPRIME A DESCRICAO
   		If lImpDesc
			
			oHtmFile:nWriteLN('<br><br><span class="texto">'+ KPIEncode(Alltrim(::cValue("DESCRICAO"))) +'</span>')
   		
		EndIf
   		                                             
   		oHtmFile:nWriteLN('</div></td>')
   	   		
   		oHtmFile:nWriteLN('<td width="150" class="texto"><div align="right">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
   		oHtmFile:nWriteLN('<br>'+KPIEncode(STR0021)+ dToC(dDataAlvo))
		
		oHtmFile:nWriteLN('<br>' + STR0035 + ' ' + dToC(dDataDe ) ) // "Acumulado de:"  
		oHtmFile:nWriteLN('<br>' + STR0036 + ' ' + dToC(dDataAte) ) // "Até"
		
	   		
	   	// Se for filtrado por objetivos mostra qual é o tipo.	
	   	If nTipoRel == 0
	   		If nSituacao == 0
		   		oHtmFile:nWriteLN('<br>'+KPIEncode(STR0023)+ KPIEncode(STR0024))//SITUACAO: ATINGIDO
		   	ElseIf nSituacao == 1
		   		oHtmFile:nWriteLN('<br>'+KPIEncode(STR0023)+ KPIEncode(STR0025))//SITUACAO: NAO ATINGIDO
		   	ElseIf nSituacao == 2
				oHtmFile:nWriteLN('<br>'+KPIEncode(STR0023)+ KPIEncode(STR0027))//SITUACAO: DENTRO DA TOLERANCIA	   	
		   	ElseIf nSituacao == 3
				oHtmFile:nWriteLN('<br>'+KPIEncode(STR0023)+ KPIEncode(STR0029))//SITUACAO: SUPEROU
		   	Else
		   		oHtmFile:nWriteLN('<br>'+KPIEncode(STR0023)+ KPIEncode(STR0026))//SITUACAO: TODOS
		   	EndIf 
	   	EndIf
	   	
	   	oHtmFile:nWriteLN('</div></td>')		
  		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<br>')

		// Ordena as organizações por ordem alfabética.
		aSort(aRelInd, , , { | x,y | y[2] > x[2] } )

		For nI := 1 To Len(aRelInd)
			
			cNomeOrg := Alltrim(aRelInd[nI][2])//PEGA O NOME DA ORGANIZACAO
			aEstrat  := aRelInd[nI][3]//ARRAY COM AS ESTRATEGIAS Q TENHAM OBJETIVOS SELECIONADOS		

			// Ordena as estratégias por ordem alfabética.
			aSort(aEstrat, , , { | x,y | y[2] > x[2] } )

			For nJ := 1 To Len(aEstrat)
			                          
				cNomeEstrat := Alltrim(aEstrat[nJ][2])//PEGA O NOME DA ESTRATEGIA
				aPerspec	:= aEstrat[nJ][3]//ARRAY COM AS PERSPECTIVAS Q TENHAM OBJETIVOS SELECIONADOS
			
				// Ordena as perspectivas por ordem alfabética.
				aSort(aPerspec, , , { | x,y | y[2] > x[2] } )
			
				For nY := 1 To Len(aPerspec)
				
				    cNomePers := Alltrim(aPerspec[nY][2])//PEGA O NOME DA PERSPECTIVA 
				    aObjetivo := aPerspec[nY][3]//ARRAY COM OS OBJETIVOS SELECIONADOS

					aObjs := {} // Zera array.
					
					// Rotina para receber ID e NOME dos objetivos.
					// Criada para organizar objetivos por ordem alfabética.
					For nCntObj := 1 To Len(aObjetivo)
						If oScorecard:lSeek(1,{aObjetivo[nCntObj]})							
							aAdd(aObjs, { aObjetivo[nCntObj], oScorecard:cValue("NOME") })
						EndIf
					Next
					
					// Ordena os objetivos por ordem alfabética.
					aSort(aObjs, , , { | x,y | y[2] > x[2] } )
				    
					For nX := 1 To Len(aObjs)

						oScorecard:lSeek(1,{aObjs[nX][1]})

						//HIERARQUIA 
						oHtmFile:nWriteLN('<table width="100%" bgcolor="#C6E2FF" border="0" cellpadding="0" cellspacing="0" >')
						oHtmFile:nWriteLN('<tr>')
//						oHtmFile:nWriteLN('<td class="cabecalho_1_branco">')
						oHtmFile:nWriteLN('<table width="95%" border="0" cellpadding="0" cellspacing="0">')
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td class="texto1">')
						oHtmFile:nWriteLN('<strong>'+KPIEncode(STR0018)+'</strong> '+KPIEncode(cNomeOrg))//Organizacao:
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td class="texto1">')
						oHtmFile:nWriteLN('<p style="margin-left:2%"><strong>'+KPIEncode(STR0019)+'</strong>'+KPIEncode(cNomeEstrat))//Estrategia:
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td class="texto1">')
						oHtmFile:nWriteLN('<p style="margin-left:4%"><strong>'+KPIEncode(STR0011)+'</strong>'+KPIEncode(cNomePers))//Perspectiva:
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')						
						oHtmFile:nWriteLN('<td class="texto1">')
						oHtmFile:nWriteLN('<p style="margin-left:6%"><strong>'+KPIEncode(STR0020)+'</strong>'+KPIEncode(Alltrim(oScorecard:cValue("NOME"))))//Objetivo:
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
						
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td align="left" class="texto">')
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
						oHtmFile:nWriteLN('</table>')					
		
						//TABELA DO OBJETIVO E SEUS INDICADORES
						oHtmFile:nWriteLN('<table style="margin-left:6%" width="94%" border="0" cellpadding="0" cellspacing="0" class="tabela">')
						oHtmFile:nWriteLN('<tr class="cabecalho_2">')
						oHtmFile:nWriteLN('<td width="30%" align="center"><strong>'+KPIEncode(STR0013)+'</strong></td>')//INDICADOR 
						oHtmFile:nWriteLN('<td width="10%" align="center"><strong>'+KPIEncode(STR0022)+'</strong></td>')//PESO
						oHtmFile:nWriteLN('<td width="10%" align="center"><strong>'+KPIEncode(STR0014)+'</strong></td>')//META
						oHtmFile:nWriteLN('<td width="10%" align="center"><strong>'+KPIEncode(STR0015)+'</strong></td>')//REALIZADO
						oHtmFile:nWriteLN('<td width="20%" align="center"><strong>'+KPIEncode("Real Acumuluado")+'</strong></td>') //Real Acumuluado.
						oHtmFile:nWriteLN('<td width="20%" align="center"><strong>'+KPIEncode("Meta Acumulada")+'</strong></td>') //Meta Acumulada.
						oHtmFile:nWriteLN('</tr>')
						
						//POSICIONA OS INDICADORES DO OBJETIVO SELECIONADO
						oIndicador:cSQLFilter("ID_SCOREC = '"+aObjs[nX][1]+"'")
						oIndicador:lFiltered(.T.)
						oIndicador:SetOrder(3)//ID_SCOREC - ID DO SCORECARD
						oIndicador:_First()
						
						While (!oIndicador:lEof())
							//POSICIONA A PLANILHA PARA BUSCAR OS VALORES DO INDICADOR										
							if(oPlanilha:lDateSeek(oIndicador:cValue("ID"),dDataAlvo,oIndicador:nValue("FREQ")))
								aValores 	:= oIndicador:aGetIndValores(dDataAlvo, dDataDe, dDataAte)
							else
								aValores	:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}
							endif

							cHtml := "" // Zera a variável.
							
							// Tipo de atualização do indicador.
							If oIndicador:cValue("TIPO_ATU") == "1"
								cTipoAtu := STR0031 // "Manual"
							ElseIf oIndicador:cValue("TIPO_ATU") == "2"
								cTipoAtu := STR0032 // "Via planilha"
							ElseIf oIndicador:cValue("TIPO_ATU") == "3"
								cTipoAtu := STR0033 // "Via fonte de dados"
							EndIf
							
							// Dados do indicador.
							If nCor == 1
								cHtml += '<tr title="' + STR0034 + '' + cTipoAtu + '">'	// Tipo de Atualização: 							
								cHtml += '<td width="30%" valign="top" class="texto3">'+KPIEncode(Alltrim(oIndicador:cValue("NOME")))+'</td>'
								cHtml += '<td width="10%" align="right" valign="top" class="texto3">'+KPIEncode(Alltrim(oIndicador:cValue("PESO")))+'</td>'
								cHtml += '<td width="10%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_META],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '<td width="10%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_REAL],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '<td width="20%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_REAL_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '<td width="20%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_META_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '</tr>'								
								nCor := 2
							Else
								cHtml += '<tr title="' + STR0034 + '' + cTipoAtu + '">'	// Tipo de Atualização:
								cHtml += '<td width="30%" valign="top" class="texto2">'+KPIEncode(Alltrim(oIndicador:cValue("NOME")))+'</td>'
								cHtml += '<td width="10%" align="right" valign="top" class="texto2">'+KPIEncode(Alltrim(oIndicador:cValue("PESO")))+'</td>'
								cHtml += '<td width="10%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_META],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '<td width="10%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_REAL],('@E 9999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '<td width="20%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_REAL_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
								cHtml += '<td width="20%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_META_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'								
								cHtml += '</tr>'
								nCor := 1							
							EndIf
							
							// Adiciona o nome do indicador e o HTML dele no array.
							// Manipulaçao desenvolvida para ordenar os indicadores em ordem alfabética.
							aAdd(aHtml, { Alltrim(oIndicador:cValue("NOME")), cHtml } )
														    
							nTotPeso 	+= oIndicador:nValue("PESO")

							If aValores[VAL_REAL_STATUS] == STATUS_GREEN
								nTotPesoV	+= oIndicador:nValue("PESO")
							EndIf
													
							oIndicador:_Next()
						
						End
						
						// Ordena os indicadores por ordem alfabética.
						aSort(aHtml, , , { | x,y | y[1] > x[1] } )
						
						// Escreve o HTML dos indicadores.
						For nCntInd := 1 To Len(aHtml)
							oHtmFile:nWriteLN(aHtml[nCntInd][2])
						Next
						
						aHtml := {} // Zera variável.
						
						nPercent := (nTotPesoV/nTotPeso)*100
						oHtmFile:nWriteLN('<p class="texto1" style="margin-left:6%">'+KPIEncode(STR0028)+' <strong>('+Transform(nPercent,'@E 999,999.99')+'%)</strong>')
						
					    //FINALIZA INDICADORES PARA O OBJETIVO  
						oHtmFile:nWriteLN('</table>')
						oHtmFile:nWriteLN('<br>')
											
						nTotPeso 	:= 0 
						nTotPesoV  	:= 0                        
					
					Next
					    
			    Next   
			
			Next
            
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<br>')

		Next

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

	oIndicador:lFiltered(.F.)
	oIndicador:cSQLFilter("")

Return nStatus

/*-------------------------------------------------------------------------------------------------------
*  	SEPARA TODOS OS OBJETIVOS SELECIONADOS NA ARVORE       
*  	@Param nSituacao - Situacao do objetivo (0-Atingido, 1-Nao Atingido, 2-Dentro da Tolerância, 3-Todos).
*	@Param dDataAlvo - Data alvo.
*-------------------------------------------------------------------------------------------------------*/
Method KPIBuscaObj(nSituacao, dDataAlvo) Class TKPI056
                           
	Local oObj			:= ::oOwner():oGetTable("OBJETIVO")
	Local oSelect		:= ::oOwner():oGetTable("RELINDXSCOR")  
	Local oScore		:= ::oOwner():oGetTable("SCORECARD")   
	Local oScoring	:= ::oOwner():oGetTable("SCORECARDING")  
	Local oInd			:= ::oOwner():oGetTable("INDICADOR")
	Local nI,nX
	
	Local cObj                
	Local aObj			:= {}
	Local aPerspec	:= {}
	Local aEstrat		:= {}
	Local aOrg			:= {}    
	
	Local nPosOrg
	Local nPosEst
	Local nPosPer
	
	Local cPerspec  
	Local cIdPerspec
	
	Local cEstrat
	Local cIdEstrat
	
	Local cOrg
	Local cIdOrg                    
	Local oSituacao        
	Local oNode  
	Local nStatus
	
    oSelect:setOrder(2)//ID_RELIND,ID_SCOREC
	oSelect:_First()     
	oObj:setOrder(1)//ID    
		                 
	//SELECIONA TODOS OS OBJETIVOS MARCADOS NA ARVORE
	While (!oSelect:lEof())
	   
		If (oObj:lSeek(1,{oSelect:cValue("ID_SCOREC")})) .And. (oInd:lSeek(3,{oSelect:cValue("ID_SCOREC")}))//E OBJETIVO E POSSUI INDICADOR
		     
			aAdd(aObj,oSelect:cValue("ID_SCOREC"))
		
		EndIf
				  
		oSelect:_Next()
		  	  	       
	End
	
	//VERIFICA O STATUS DOS OBJETIVOS
	If nSituacao != 4 //TODOS
	
		oSituacao 	:= oScoring:oToXMLScoStatus({}, aObj, dDataAlvo)
		aObj 		:= {}
		For nX := 1 To oSituacao:nChildCount()
		
	   		oNode 	:= oSituacao:oChildByPos(nX) 
	   		nStatus	:= oNode:oChildByName("STATUS_DATAALVO"):nGetValue()

	   	   Do Case
	   		
		   		Case nSituacao == 0 .And. (nStatus == STATUS_GREEN .Or. nStatus == STATUS_BLUE) //ATINGIDOS

           			aAdd(aObj,oNode:oChildByName("ID"):cGetValue())
	   		
		   		Case nSituacao == 1 .And. nStatus == STATUS_RED //NAO ATINGIDOS
	   		       
	   				aAdd(aObj,oNode:oChildByName("ID"):cGetValue())
	   		
	   			Case nSituacao == 2 .And. (nStatus == STATUS_GREEN .Or. nStatus == STATUS_YELLOW) //DENTRO DA TOLERANCIA
	   			
	   				aAdd(aObj,oNode:oChildByName("ID"):cGetValue())                
	   			
	   			Case nSituacao == 3 .And. nStatus == STATUS_BLUE //SUPEROU

					aAdd(aObj,oNode:oChildByName("ID"):cGetValue())                	   				
	   		
	   		EndCase
		
		Next	
	
	EndIf	
			
	For nX := 1 To Len(aObj)
		  
    	cObj := aObj[nX]
		If (oScore:lSeek(1,{ cObj }))//BUSCAR A PERPECTIVA DO OBJETIVO                 
		    //PEGA A PERSPECTIVA
			oScore:lSeek(1,{ oScore:cValue("PARENTID") })	
			cPerspec	:= oScore:cValue("NOME") 
			cIdPerspec	:= oScore:cValue("ID") 
		                        
		    //PEGA A ESTRATEGIA			                   
			oScore:lSeek(1,{ oScore:cValue("PARENTID") })
			cEstrat		:= oScore:cValue("NOME")
			cIdEstrat	:= oScore:cValue("ID") 
			
			//PEGA A ORGANIZACAO
			oScore:lSeek(1,{ oScore:cValue("PARENTID") })
			cOrg 	:= oScore:cValue("NOME")
			cIdOrg	:= oScore:cValue("ID")
			
		EndIf	     
				           
		If Len(aOrg) > 0
		
			For nI := 1 To Len(aOrg)
			
				nPosOrg := aScan(aOrg[nI],cIdOrg)
			    If nPosOrg != 0 
			    	nPosOrg := nI
			    	Exit
			    EndIf
			    
			Next
		
			If nPosOrg != 0//ACHOU A ORGANIZACAO

				For nI := 1 To Len(aOrg[nPosOrg][3])					
				                                    
					nPosEst := aScan(aOrg[nPosOrg][3][nI],cIdEstrat)
				    If nPosEst != 0
				    	Exit
				    EndIf
				
				Next
								
				If nPosEst != 0//ACHOU A ESTRATEGIA	
				
					For nI := 1 To Len(aOrg[nPosOrg][3][nPosEst][3])
					
						nPosPer := aScan(aOrg[nPosOrg][3][nPosEst][3][nI],cIdPerspec)
					    If nPosPer != 0
					    	Exit
					    EndIf	  
					    				
					Next    
					
					If nPosPer != 0//ACHOU A PERSPECTIVA
						
						aAdd(aOrg[nPosOrg][3][nPosEst][3][nPosPer][3],cObj)
						
					Else//NOVA PERSPECTIVA
						     
						aAdd(aOrg[nPosOrg][3][nPosEst][3],{cIdPerspec,cPerspec,{cObj}})	
						
					EndIf						
					
				Else//NOVA ESTRATEGIA
					
					aAdd(aPerspec,{cIdPerspec,cPerspec,{cObj}})					
					aAdd(aOrg[nPosOrg][3],{cIdEstrat,cEstrat,aPerspec})
				
				EndIf						 
				
			Else//NOVA ORGANIZACAO
			
				aAdd(aPerspec,{cIdPerspec,cPerspec,{cObj}})
				aAdd(aEstrat,{cIdEstrat,cEstrat,aPerspec})
   				aAdd(aOrg,{cIdOrg,cOrg,aEstrat})			    
			
			EndIf
		
		Else					     

			aAdd(aPerspec,{cIdPerspec,cPerspec,{cObj}})
			aAdd(aEstrat,{cIdEstrat,cEstrat,aPerspec})
			aAdd(aOrg,{cIdOrg,cOrg,aEstrat})
			
		EndIf
	
		aPerspec:= {} 
		aEstrat	:= {}
	
	Next

Return aOrg

//-------------------------------------------------------------------
/*/{Protheus.doc} KPIBuscaGrp
Separa todos os grupos de indicadores com ID e NOME     
@Param nSituacao - Situacao do objetivo (0-Atingido, 1-Nao Atingido, 2-Dentro da Tolerância, 3-Todos).
@Param dDataAlvo - Data alvo. 	
@Return Array com ID e NOME do grupo de indicadores.
@Since 23/04/2014
@Author  Helio Leal
/*/
//-------------------------------------------------------------------
Method KPIBuscaGrp(nSituacao, dDataAlvo) Class TKPI056

	Local oSelect		:= ::oOwner():oGetTable("RELINDXGRPIND")	   
	Local oInd			:= ::oOwner():oGetTable("INDICADOR")
	Local oGrp			:= ::oOwner():oGetTable("GRUPO_IND")
	Local aGrpInd		:= {}   
	Local aGrp			:= {}
	
	Local nY			:= 0

	oSelect:setOrder(2) // ID_RELIND + ID_GRPIND
	oSelect:_First()

	//Seleciona todos os grupos que tem pelo menos um indicador associado.
	While (!oSelect:lEof())
		If oInd:lSeek(2,{oSelect:cValue("ID_GRPIND")}) // Pergunta se o grupo tem algum indicador.
			aAdd(aGrpInd, oSelect:cValue("ID_GRPIND"))
		EndIf				  
		oSelect:_Next()
	End	
	
	For nY := 1 To Len( aGrpInd )
		If oGrp:lSeek(1,{AllTrim(aGrpInd[nY])})
			//aAdd(aGrpInd[nY], oGrp:cValue("NOME") )
			aAdd(aGrp, { AllTrim(aGrpInd[nY]), oGrp:cValue("NOME") } )
		EndIf
	Next nY

	// Ordena os grupos de indicadores por ordem alfabética.
	aSort(aGrp, , , { | x,y | y[2] > x[2] } )
	
Return aGrp

//-------------------------------------------------------------------
/*/{Protheus.doc} KPIRelGrpJob
FUNCTION PARA EXECUTAR O JOB    
@Param 		aParms - Parâmetros da base de dados.
@Return 	Status da operação.
@Since 		23/04/2014
@Author  	Helio Leal
/*/
//------------------------------------------------------------------- 
Method KPIRelGrpJob(aParms) Class TKPI056
	Local cNome
	Local cDescricao
	Local lImpDesc
	Local dDataAlvo
	Local dDataDe
	Local dDataAte
	Local nSituacao
	Local cID
	Local cKpiPath
	Local cReportName
	Local cPathSite   
	Local nI

	Local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	Local oPlanilha	:= ::oOwner():oGetTable("PLANILHA") 

	Local aRelInd		:= {}
	Local oHtmFile

	Local nTotPeso	:= 0
	Local nTotPesoV	:= 0     
	Local nPercent	:= 0   
	Local nCor			:= 1 // Alterna cor da linha na tabela de indicadores.
	
	Local cNomeGrupo	:= ""
	
	Local cHtml		:= ""
	Local aHtml		:= {}
	Local nCntInd		:= 0
	
	Local cTipoAtu	:= STR0030 //  "Vazio"
	
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao	:= aParms[2]	
	// 3 - Imprime Descrição?
	lImpDesc	:= aParms[3]	
	// 4 - Scorecard de
	dDataAlvo	:= aParms[4]
	// 5 - Scorecard ate
//	dDataAte	:= aParms[5]	
	// 6 - Listar Indicadores?
	nSituacao	:= aParms[5]	
	// 7 - ID do Relatório
	cID			:= aParms[6]	
	// 8 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[7]	
	// 9 - Nome do arquivo que sera salvo
	cReportName	:= aParms[8]
	// 10 - Diretorio do site.
	cPathSite	:= aParms[9]
	// 11 - Acumulado De.
	dDataDe	:= aParms[10]
	// 12 - Até
	dDataAte	:= aParms[11]

    // Filtra todos os grupos de indicadores selecionados.
    aRelInd := ::KPIBuscaGrp(nSituacao,dDataAlvo)

    // Cria arquivo HTML.
    oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL056_" + alltrim(cID) + ".html")
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0005 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL056_"*/
		oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		Return KPI_ST_GENERALERROR
	EndIf

	// Montagem do cabeçalho da página.
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('<title>'+KPIEncode(STR0007)+'</title>') //SGI - Sistema de Gestão de Indicadores
	oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	oHtmFile:nWriteLN('</head>')         

	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	                                            	
	If (Len(aRelInd) > 0 )      

	    //Monta o cabeçalho de exibição do relatório.
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
  		oHtmFile:nWriteLN('<tr>')
   		oHtmFile:nWriteLN('<td width="150" align="center"><img src="'+cPathSite+'/imagens/art_logo_clie.sgi"></td>')   

   		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0002)) //Relatório de Indicadores   		

   		//Imprime a Descrição.
   		If lImpDesc			
			oHtmFile:nWriteLN('<br><br><span class="texto">'+ KPIEncode(Alltrim(::cValue("DESCRICAO"))) +'</span>')   		
		EndIf
   		                                             
   		oHtmFile:nWriteLN('</div></td>')
   	   		
   		oHtmFile:nWriteLN('<td width="150" class="texto"><div align="right">'+KPIEncode(STR0010)+ dtoc(date()) ) //Emissão:
   		oHtmFile:nWriteLN('<br>'+KPIEncode(STR0021)+ dToC(dDataAlvo))

		oHtmFile:nWriteLN('<br>' + STR0035 + ' ' + dToC(dDataDe ) ) // "Acumulado de:"  
		oHtmFile:nWriteLN('<br>' + STR0036 + ' ' + dToC(dDataAte) ) // "Até"

	   	oHtmFile:nWriteLN('</div></td>')		
  		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<br>')

		For nI := 1 To Len(aRelInd)
			
			cNomeGrupo := aRelInd[nI][2]

			oHtmFile:nWriteLN('<table width="100%" bgcolor="#C6E2FF" border="0" cellpadding="0" cellspacing="0" >')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<table width="95%" border="0" cellpadding="0" cellspacing="0">')
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td class="texto1">')
			oHtmFile:nWriteLN('<strong>'+KPIEncode("Nome do Grupo: ")+'</strong> '+KPIEncode(cNomeGrupo))//Nome do grupo:
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('</tr>')
			
			oHtmFile:nWriteLN('<tr>')
			oHtmFile:nWriteLN('<td align="left" class="texto">')
			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')					

			// Tabela do grupo de indicadores e os indicadores.
			oHtmFile:nWriteLN('<table style="margin-left:12%" width="88%" border="0" cellpadding="0" cellspacing="0" class="tabela">')
			oHtmFile:nWriteLN('<tr class="cabecalho_2">')
			oHtmFile:nWriteLN('<td width="30%" align="center"><strong>'+KPIEncode(STR0013)+'</strong></td>') //Indicador. 
			oHtmFile:nWriteLN('<td width="10%" align="center"><strong>'+KPIEncode(STR0022)+'</strong></td>') //Peso.
			oHtmFile:nWriteLN('<td width="10%" align="center"><strong>'+KPIEncode(STR0014)+'</strong></td>') //Meta
			oHtmFile:nWriteLN('<td width="10%" align="center"><strong>'+KPIEncode(STR0015)+'</strong></td>') //Realizado.
			oHtmFile:nWriteLN('<td width="20%" align="center"><strong>'+KPIEncode("Real Acumuluado")+'</strong></td>') //Real Acumuluado.
			oHtmFile:nWriteLN('<td width="20%" align="center"><strong>'+KPIEncode("Meta Acumulada")+'</strong></td>') //Meta Acumulada.
			oHtmFile:nWriteLN('</tr>')
			
			//POSICIONA OS INDICADORES DO OBJETIVO SELECIONADO
			oIndicador:cSQLFilter("ID_GRUPO = '"+aRelInd[nI][1]+"'")
			oIndicador:lFiltered(.T.)
			oIndicador:SetOrder(2) //ID_GRUPO - ID DO GRUPO.
			oIndicador:_First()	  

			While (!oIndicador:lEof())
				// Posiciona a planilha para buscar os valores do indicador.										
				if(oPlanilha:lDateSeek(oIndicador:cValue("ID"),dDataAlvo,oIndicador:nValue("FREQ")))
					aValores 	:= oIndicador:aGetIndValores(dDataAlvo, dDataDe, dDataAte)
				else
					aValores	:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}
				endif

				cHtml := "" // Zera a variável.
				
				// Tipo de atualização do indicador.
				If oIndicador:cValue("TIPO_ATU") == "1"
					cTipoAtu := STR0031 // "Manual"
				ElseIf oIndicador:cValue("TIPO_ATU") == "2"
					cTipoAtu := STR0032 // "Via planilha"
				ElseIf oIndicador:cValue("TIPO_ATU") == "3"
					cTipoAtu := STR0033 // "Via fonte de dados"
				EndIf

				// Dados do indicador.
				If nCor == 1
					cHtml += '<tr title="'+ STR0034 + ''+ cTipoAtu +'">' // "Tipo de Atualização: " 
					cHtml += '<td width="30%" valign="top" class="texto3">'+KPIEncode(Alltrim(oIndicador:cValue("NOME")))+'</td>'
					cHtml += '<td width="10%" align="right" valign="top" class="texto3">'+KPIEncode(Alltrim(oIndicador:cValue("PESO")))+'</td>'
					cHtml += '<td width="10%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_META],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '<td width="10%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_REAL],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '<td width="20%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_REAL_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '<td width="20%" align="right" valign="top" class="texto3">'+AllTrim(Transform(aValores[VAL_META_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '</tr>'								
					nCor := 2
				Else
					cHtml += '<tr title="'+ STR0034 + ''+ cTipoAtu +'">' // "Tipo de Atualização: "
					cHtml += '<td width="30%" valign="top" class="texto2">'+KPIEncode(Alltrim(oIndicador:cValue("NOME")))+'</td>'
					cHtml += '<td width="10%" align="right" valign="top" class="texto2">'+KPIEncode(Alltrim(oIndicador:cValue("PESO")))+'</td>'					
					cHtml += '<td width="10%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_META],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '<td width="10%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_REAL],('@E 9999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '<td width="20%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_REAL_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'
					cHtml += '<td width="20%" align="right" valign="top" class="texto2">'+AllTrim(Transform(aValores[VAL_META_ACU],('@E 999,999,999,999.'+Pad('',oIndicador:nValue("DECIMAIS"),'9'))))+'</td>'	
					cHtml += '</tr>'
					nCor := 1							
				EndIf
				
				// Adiciona o nome do indicador e o HTML dele no array.
				// Manipulaçao desenvolvida para ordenar os indicadores em ordem alfabética.
				aAdd(aHtml, { Alltrim(oIndicador:cValue("NOME")), cHtml } )
											    
				nTotPeso 	+= oIndicador:nValue("PESO")

				If aValores[VAL_REAL_STATUS] == STATUS_GREEN
					nTotPesoV	+= oIndicador:nValue("PESO")
				EndIf
										
				oIndicador:_Next()
			
			End
			
			// Ordena os indicadores por ordem alfabética.
			aSort(aHtml, , , { | x,y | y[1] > x[1] } )
			
			// Escreve o HTML dos indicadores.
			For nCntInd := 1 To Len(aHtml)
				oHtmFile:nWriteLN(aHtml[nCntInd][2])
			Next
			
			aHtml := {} // Zera variável.
			
			nPercent := (nTotPesoV/nTotPeso)*100
			oHtmFile:nWriteLN('<p class="texto1" style="margin-left:12%">'+KPIEncode(STR0028)+' <strong>('+Transform(nPercent,'@E 999,999.99')+'%)</strong>')
			
		    //FINALIZA INDICADORES PARA O OBJETIVO  
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<br>')
								
			nTotPeso 	:= 0 
			nTotPesoV  	:= 0              

			oHtmFile:nWriteLN('</td>')
			oHtmFile:nWriteLN('</tr>')
			oHtmFile:nWriteLN('</table>')
			oHtmFile:nWriteLN('<br>')

		Next

	Else 

		// Montagem do rodape do relatorio
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(	KPIEncode(STR0008))//Não foram encontradas informações dentro das especificações passadas
		oHtmFile:nWriteLN('	</font>')
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode("ou não existem Indicadores para os Grupos de indicadores selecionados."))
		oHtmFile:nWriteLN('	</font>')

	EndIf  

	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')

	//Faz a copia do relatorio para o diretorio de Spool
	oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + cReportName, oKPICore:cKpiPath())
	oHtmFile:lClose()
	oKPICore:Log(STR0003+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/

	oIndicador:lFiltered(.F.)
	oIndicador:cSQLFilter("")

Return nStatus

/*-------------------------------------------------------------------------------------------------------
*  FUNCTION
*-------------------------------------------------------------------------------------------------------*/
function _KPI056_RelInd()
return nil