#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXLOG.CH"
	
Static __aTable
Static __cLogID 
Static __cScheduleID
Static __lDebug

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOpenLog
Define a estrutura das tabelas de log de extração e realiza a criação, 
abertura e ajustes na estrutura do arquivo. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXOpenLog()   
	Local oLog	 		:= nil
	Local oEntity 		:= nil
	Local oConfig		:= nil
	Local oIntegrity	:= nil
	Local nTable		:= 1

	If ( __aTable == nil )
		//-------------------------------------------------------------------
		// Lista de tabelas do log de extração. 
		//------------------------------------------------------------------- 
		__aTable := {}
		
		//-------------------------------------------------------------------
		// Cria a tabela de processos. 
		//-------------------------------------------------------------------  
		oLog := TBITable():New( "HVY", "HVY" ) 
	
		oLog:AddField( TBIField():New( "HVY_ID" 		,"C" ,06 ,0))
		oLog:AddField( TBIField():New( "HVY_EMPFIL" 	,"C" ,15 ,0))	
		oLog:AddField( TBIField():New( "HVY_PROFIL" 	,"C" ,50 ,0))	
		oLog:AddField( TBIField():New( "HVY_APP" 		,"C" ,200 ,0))	
		oLog:AddField( TBIField():New( "HVY_STARTD"  	,"D" ,08 ,0))	    
		oLog:AddField( TBIField():New( "HVY_FINISD"  	,"D" ,08 ,0))
		oLog:AddField( TBIField():New( "HVY_STARTH"  	,"C" ,08 ,0))	    
		oLog:AddField( TBIField():New( "HVY_FINISH"  	,"C" ,08 ,0))	
		oLog:AddField( TBIField():New( "HVY_STATUS"  	,"N" ,01 ,0))
		oLog:AddField( TBIField():New( "HVY_MEMO"		,"M" ,10 ,0))	
		oLog:AddField( TBIField():New( "HVY_EXEC"		,"C" ,13 ,0))		
		oLog:addIndex( TBIIndex():New( "HVY1", {"HVY_ID"}, .T.) )  
		oLog:addIndex( TBIIndex():New( "HVY2", {"HVY_EXEC"}, .F.) ) 
			
		aAdd( __aTable, oLog )
	
		//-------------------------------------------------------------------
		// Cria a tabela de entidades. 
		//-------------------------------------------------------------------  
		oEntity := TBITable():New( "HVZ", "HVZ" ) 
	
		oEntity:AddField( TBIField():New( "HVZ_ID" 		,"C" ,06 ,0))
		oEntity:AddField( TBIField():New( "HVZ_ENTITY" 	,"C" ,03 ,0))
		oEntity:AddField( TBIField():New( "HVZ_PERIOF"  	,"D" ,08 ,0))	
		oEntity:AddField( TBIField():New( "HVZ_PERIOT"  	,"D" ,08 ,0))	
		oEntity:AddField( TBIField():New( "HVZ_STARTD"  	,"D" ,08 ,0))	    
		oEntity:AddField( TBIField():New( "HVZ_FINISD"  	,"D" ,08 ,0))
		oEntity:AddField( TBIField():New( "HVZ_STARTH"  	,"C" ,08 ,0))	    
		oEntity:AddField( TBIField():New( "HVZ_FINISH"  	,"C" ,08 ,0))
		oEntity:AddField( TBIField():New( "HVZ_RECORD"  	,"N" ,10 ,0))	
		oEntity:AddField( TBIField():New( "HVZ_STATUS"  	,"N" ,01 ,0))
		oEntity:AddField( TBIField():New( "HVZ_MEMO"		,"M" ,10 ,0))
		oEntity:addIndex( TBIIndex():New( "HVZ1", {"HVZ_ID", "HVZ_ENTITY"}, .T.) ) 

		aAdd( __aTable, oEntity )

		//-------------------------------------------------------------------
		// Cria a tabela de configuração.
		//-------------------------------------------------------------------
		oConfig := TBITable():New( "HY4", "HY4" ) 

		oConfig:AddField( TBIField():New( "HY4_CONFIG" 	,"C" ,15 	,0))	
		oConfig:AddField( TBIField():New( "HY4_MEMO" 	,"C" ,255	,0))	
		oConfig:addIndex( TBIIndex():New( "HY41", {"HY4_CONFIG"}, .T.) )  
			
		aAdd( __aTable, oConfig )
	
		//-------------------------------------------------------------------
		// Cria a tabela de validação de integridade. 
		//-------------------------------------------------------------------  
		oIntegrity := TBITable():New( "HY5", "HY5" ) 
	
		oIntegrity:AddField( TBIField():New( "HY5_ID" 		,"C" ,06 ,0))
		oIntegrity:AddField( TBIField():New( "HY5_FACT" 	,"C" ,03 ,0))			
		oIntegrity:AddField( TBIField():New( "HY5_LOOKUP"	,"C" ,03 ,0))	
		oIntegrity:AddField( TBIField():New( "HY5_BK"		,"C" ,40 ,0))	
		oIntegrity:AddField( TBIField():New( "HY5_FILIAL"	,"C" ,12 ,0))	
		oIntegrity:AddField( TBIField():New( "HY5_VALUE"	,"C" ,30 ,0))	
		oIntegrity:addIndex( TBIIndex():New( "HY51", { "HY5_ID", "HY5_FACT", "HY5_LOOKUP", "HY5_BK", "HY5_FILIAL", "HY5_VALUE" }, .T.) )  
			
		aAdd( __aTable, oIntegrity )
	EndIf 

	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( __aTable ) 
		If !( __aTable[nTable]:lIsOpen( ) )
			__aTable[nTable]:bLogger( {|x| BIXSysOut("BIXLOG", __aTable[nTable]:cTablename() + " " + x )} )
			__aTable[nTable]:ChkStruct( .F., .F., .F., .T. )
			__aTable[nTable]:lOpen( )
		EndIf
	Next nTable 
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLog
Monta a tela de visualização do log. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Function BIXLog() 
	Local oDialog   := nil 
	Local oRelation := nil 
	Local oProcess  := nil	
	Local oEntity   := nil
	Local oLeft     := nil
	Local oRight    := nil
	Local oLayer    := FWLayer():New()
	Local aPosition := FWGetDialogSize( oMainWnd )
  	Local aButtons  := {}
	Local bOK       := {|| oDialog:End() }
	Local bCancel   := {|| oDialog:End() }
	
	//-------------------------------------------------------------------
	// Abre as tabelas utilizadas no Log. 
	//------------------------------------------------------------------- 	
	BIXOpenLog() 
	
	//-------------------------------------------------------------------
	// Inclui botões de acesso as operações. 
	//-------------------------------------------------------------------  
   	Aadd( aButtons, {"", {|| BIXLogDetails( HVZ->HVZ_ENTITY  ) }						, STR0001, STR0001 } ) //"Log de Extração"	  
   	Aadd( aButtons, {"", {|| BIXLogPerformance( HVZ->HVZ_ENTITY , HVY->HVY_EMPFIL ) }	, STR0017, STR0017 } ) //"Análise de Performance"	
 	Aadd( aButtons, {"", {|| BIXLogData( HVZ->HVZ_ENTITY  ) }							, STR0025, STR0025 } ) //"Tabela de Dados"	
	Aadd( aButtons, {"", {|| BIXLogConfig( ) }											, STR0027, STR0027 } ) //"Configurar"	
	Aadd( aButtons, {"", {|| BIXLogReport( .T. ) }										, STR0066, STR0066 } ) //"Gerar Relatório"

	//-------------------------------------------------------------------
	// Monta a tela de visualização do log. 
	//------------------------------------------------------------------- 
	DEFINE MSDIALOG oDialog TITLE STR0001 FROM aPosition[1], aPosition[2] TO aPosition[3], aPosition[4] PIXEL //"Log de Extração"
		//-------------------------------------------------------------------
		// Define as sessões do log. 
		//-------------------------------------------------------------------  
		oLayer:Init(oDialog,.F.,.T.)
		oLayer:addLine( "TOP", 92, .F. )
		oLayer:AddCollumn( "TOP_LEFT", 40, .T., "TOP" )
		oLayer:setColSplit( "TOP_LEFT", CONTROL_ALIGN_RIGHT, "TOP", ) 
		oLayer:AddCollumn( "TOP_RIGHT", 60, .F., "TOP" )
		oLayer:AddWindow( "TOP_LEFT"	,"LEFT"	 ,STR0002, 100,.F.,.T.,, "TOP", { || } ) //"Extrações"
		oLayer:AddWindow( "TOP_RIGHT"	,"RIGHT" ,STR0003, 100,.F.,.T.,, "TOP", { || } ) //"Dimensões e Fatos"
		oLeft  := oLayer:GetWinPanel( "TOP_LEFT", "LEFT", "TOP" )
		oRight := oLayer:GetWinPanel( "TOP_RIGHT"	, "RIGHT", "TOP" )	

		//-------------------------------------------------------------------
		// Monta o browse de processos. 
		//-------------------------------------------------------------------  	
  		DEFINE FWBROWSE oProcess DATA TABLE ALIAS "HVY" NO SEEK NO CONFIG NO REPORT NO LOCATE FILTER OF oLeft
  			//-------------------------------------------------------------------
			// Monta a legenda. 
			//-------------------------------------------------------------------  
  			ADD LEGEND DATA {|| HVY->HVY_STATUS == 1} COLOR "YELLOW" 	TITLE STR0004 OF oProcess //"Executando"
			ADD LEGEND DATA {|| HVY->HVY_STATUS == 3} COLOR "GREEN"  	TITLE STR0006 OF oProcess //"Finalizado"
			ADD LEGEND DATA {|| HVY->HVY_STATUS == 2} COLOR "RED"  		TITLE STR0005 OF oProcess //"Finalizado com erro"
			ADD LEGEND DATA {|| HVY->HVY_STATUS == 4} COLOR "GRAY"  	TITLE STR0040 OF oProcess //"Cancelado"
			ADD LEGEND DATA {|| HVY->HVY_STATUS == 5} COLOR "WHITE"  	TITLE STR0050 OF oProcess //"Sem Licença disponível"
			ADD LEGEND DATA {|| HVY->HVY_STATUS == 7} COLOR "BLACK"  	TITLE STR0083 OF oProcess //"Sem conexão com a Fluig Smart Data"

			//-------------------------------------------------------------------
			// Monta o browse de processos. 
			//-------------------------------------------------------------------  
			ADD COLUMN oColumn SIZE 05  DATA {|| HVY->HVY_EMPFIL }																		TITLE STR0007	OF oProcess //"Empresa" 
			ADD COLUMN oColumn SIZE 05  DATA {|| BIXTimeDiff( HVY->HVY_STARTD, HVY->HVY_STARTH, HVY->HVY_FINISD,  HVY->HVY_FINISH ) }	TITLE STR0011	OF oProcess //"Tempo" 
			ADD COLUMN oColumn SIZE 10  DATA {|| DToC( HVY->HVY_STARTD ) + " " + HVY->HVY_STARTH } 										TITLE STR0009 	OF oProcess //"Início da Extração" 
			ADD COLUMN oColumn SIZE 10  DATA {|| DToC( HVY->HVY_FINISD ) + " " + HVY->HVY_FINISH }										TITLE STR0010	OF oProcess //"Fim da Extração"  
			ADD COLUMN oColumn SIZE 20  DATA {|| HVY->HVY_PROFIL }																		TITLE STR0008	OF oProcess //"Perfil"
			ADD COLUMN oColumn SIZE 250 DATA {|| HVY->HVY_APP }																			TITLE "App"		OF oProcess //"App"		
		ACTIVATE FWBROWSE oProcess 		
		
		//-------------------------------------------------------------------
		// Monta o browse de entidades. 
		//-------------------------------------------------------------------  
		DEFINE FWBROWSE oEntity DATA TABLE ALIAS "HVZ" DOUBLECLICK {|| BIXLogDetails( HVZ->HVZ_ENTITY ) } NO SEEK NO CONFIG NO REPORT NO LOCATE FILTER OF oRight
  			//-------------------------------------------------------------------
			// Monta a legenda. 
			//-------------------------------------------------------------------  
  			ADD LEGEND DATA {|| HVZ->HVZ_STATUS == 1} COLOR "YELLOW" TITLE STR0004 OF oEntity //"Executando"
			ADD LEGEND DATA {|| HVZ->HVZ_STATUS == 3} COLOR "GREEN"  TITLE STR0006 OF oEntity //"Finalizado"
			ADD LEGEND DATA {|| HVZ->HVZ_STATUS == 5} COLOR "BLUE"   TITLE STR0042 OF oEntity //"Atualizado anteriormente"	
			ADD LEGEND DATA {|| HVZ->HVZ_STATUS == 2} COLOR "RED"    TITLE STR0005 OF oEntity //"Finalizado com erro"
			ADD LEGEND DATA {|| HVZ->HVZ_STATUS == 4} COLOR "GRAY"   TITLE STR0040 OF oEntity //"Cancelado"

			//-------------------------------------------------------------------
			// Monta o browse de entidades. 
			//-------------------------------------------------------------------  
			ADD COLUMN oColumn SIZE 20 DATA {|| AllTrim( HVZ->HVZ_ENTITY ) + If( Empty( BIXGetTitle( HVZ->HVZ_ENTITY ) ), "", " - " + BIXGetTitle( HVZ->HVZ_ENTITY ) ) } TITLE STR0013 OF oEntity //"Entidade"
			ADD COLUMN oColumn SIZE 05 DATA {|| BIXTimeDiff( HVZ->HVZ_STARTD, HVZ->HVZ_STARTH, HVZ->HVZ_FINISD,  HVZ->HVZ_FINISH ) }								TITLE STR0011 OF oEntity //"Tempo" 				
			ADD COLUMN oColumn SIZE 05 DATA {|| HVZ->HVZ_RECORD }																									TITLE STR0015 OF oEntity //"Registros"  
			ADD COLUMN oColumn SIZE 15 DATA {|| cBIStr( HVZ->HVZ_PERIOF ) + " - " + cBIStr( HVZ->HVZ_PERIOT ) }														TITLE STR0014 OF oEntity //"Período" 
			ADD COLUMN oColumn SIZE 15 DATA {|| DToC( HVZ->HVZ_STARTD ) + " " + HVZ->HVZ_STARTH }																	TITLE STR0009 OF oEntity //"Início da Extração" 
			ADD COLUMN oColumn SIZE 15 DATA {|| DToC( HVZ->HVZ_FINISD ) + " " + HVZ->HVZ_FINISH }																	TITLE STR0010 OF oEntity //"Fim da Extração" 
		ACTIVATE FWBROWSE oEntity  

		//-------------------------------------------------------------------
		// Define o relacionamento entre processos e entidades. 
		//------------------------------------------------------------------- 
		oRelation := FWBrwRelation():New() 
		oRelation:AddRelation( oProcess,oEntity, { { "HVZ_ID", "HVY_ID" } } )
		oRelation:Activate()
	ACTIVATE MSDIALOG oDialog ON INIT ( EnchoiceBar( oDialog, bOK, bCancel, .F., aButtons,,,.F.,.F.,.F.,.F., .F. ), SetKey( VK_F5, {|| oProcess:Refresh() } ) )
Return nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogDetails
Monta a tela de visualização dos detalhes da extração de uma entidade. 

@param cEntity, caracter, Entidade que será analiada. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXLogDetails( cEntity )
	Local oDialog		:= nil 
	Local oDetails		:= nil 
	Local oLayer		:= nil 
	Local oLog 			:= nil
	Local oIntegrity	:= nil 
	Local aPosition 	:= FWGetDialogSize( oMainWnd )
	Local aAreaProcess	:= HVY->( GetArea() )
	Local aAreaEntity	:= HVZ->( GetArea() )
	Local cContent		:= HVZ->HVZ_MEMO
	Local cFilter		:= ""
	Local bOK  			:= {|| oDialog:End() }
	Local bCancel		:= {|| oDialog:End() }
	
	//-------------------------------------------------------------------
	// Monta o detalhe. 
	//------------------------------------------------------------------- 
	DEFINE MSDIALOG oDialog TITLE STR0016 FROM aPosition[1], aPosition[2] TO aPosition[3], aPosition[4] PIXEL //"Detalhes da Extração"
		//-------------------------------------------------------------------
		// Define as sessões dos detalhes. 
		//-------------------------------------------------------------------  
		oLayer := FWLayer():New()
		oLayer:init( oDialog )
		oLayer:addLine( "LINE_TOP", 45, .F. )
		oLayer:addLine( "LINE_BOTTOM", 50, .F. )
		oLayer:addCollumn( "COL_TOP", 100,, "LINE_TOP" )	
		oLayer:addCollumn( "COL_BOTTOM", 100,, "LINE_BOTTOM" )	
		oLayer:addWindow( "COL_TOP", "WIN_TOP", STR0001, 100, .F., .F.,, "LINE_TOP") //"Log de Extração"
		oLayer:addWindow( "COL_BOTTOM", "WIN_BOTTOM", STR0049, 100, .F., .F.,, "LINE_BOTTOM") //"Log de Integridade"
		
		oLog 		:= oLayer:GetWinPanel("COL_TOP", "WIN_TOP", "LINE_TOP")
		oIntegrity  := oLayer:GetWinPanel("COL_BOTTOM", "WIN_BOTTOM", "LINE_BOTTOM")	
		
		//-------------------------------------------------------------------
		// Monta o campo para exibição dos erros e mensagens diversas. 
		//-------------------------------------------------------- -----------  		
		oDetails := TMultiget():New(15,10,{|| cContent },oLog,180,45,,,,,,.T.)
		oDetails:SetCss("TMultiGet{border:none;}")
		oDetails:lFocusOnFirst 	:= .T.
		oDetails:lReadOnly 		:= .T.
		oDetails:Align 			:= CONTROL_ALIGN_ALLCLIENT

		//-------------------------------------------------------------------
		// Monta o filtro para o log de integridade.
		//-------------------------------------------------------------------	
		cFilter += "HY5_ID == '" + HVZ->HVZ_ID  + "' .And. HY5_FACT == '" + HVZ->HVZ_ENTITY + "'"

		//-------------------------------------------------------------------
		// Monta o browse de validação de integridade. 
		//-------------------------------------------------------------------  
		DEFINE FWBROWSE oEntity DATA TABLE ALIAS "HY5" NO SEEK NO CONFIG NO REPORT NO LOCATE FILTER OF oIntegrity
			//-------------------------------------------------------------------
			// Monta as colunas do browse de validação de integridade. 
			//-------------------------------------------------------------------  
			ADD COLUMN oColumn SIZE 30 DATA {|| HY5->HY5_LOOKUP + " - " + BIXGetTitle( HY5->HY5_LOOKUP ) }	TITLE STR0084 OF oEntity 	//"Dimensão"
			ADD COLUMN oColumn SIZE 40 DATA {|| HY5->HY5_BK }												TITLE STR0085 OF oEntity 	//"Campo chave"   
			ADD COLUMN oColumn SIZE 40 DATA {|| HY5->HY5_FILIAL }											TITLE STR0086 OF oEntity 	//"Filial"
			ADD COLUMN oColumn SIZE 40 DATA {|| HY5->HY5_VALUE }											TITLE STR0087 OF oEntity 	//Conteúdo  
			
			oEntity:SetFilterDefault( cFilter )
		ACTIVATE FWBROWSE oEntity 		
	ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., {},,,.F.,.F.,.F.,.F., .F. )
	
	RestArea( aAreaProcess ) 
	RestArea( aAreaEntity ) 
Return nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogOverview
Monta a tela de visualização dos detalhes da extração de um processo. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXLogOverview()
	Local oDialog		:= nil 
	Local oWindow		:= nil 
	Local oRow			:= nil 
	Local oLayer		:= nil 
	Local oEntityRecord	:= FWChartPie():New()
	Local oEntityTime	:= FWChartPie():New()	
	Local aPosition 	:= FWGetDialogSize( oMainWnd )
	Local aAreaEntity	:= HVZ->( GetArea() )
	Local aRecords		:= {}
	Local aTime			:= {} 	
	Local nSerie		:= 0
	Local bOK  			:= {|| oDialog:End() }
	Local bCancel		:= {|| oDialog:End() }
		
	//-------------------------------------------------------------------
	// Monta o detalhe. 
	//------------------------------------------------------------------- 
	DEFINE MSDIALOG oDialog TITLE STR0016 FROM aPosition[1], aPosition[2] TO aPosition[3], aPosition[4] PIXEL //"Detalhes da Extração"
		//-------------------------------------------------------------------
		// Define as camadas da interface. 
		//-------------------------------------------------------------------  
		oLayer := FWLayer():New()
		oLayer:init( oDialog )
		oLayer:addCollumn( "COL_ALL", 100, .F. )
		oLayer:addWindow( "COL_ALL", "WIN_ALL"		, STR0038, 92, .F., .T., {||} ) //"Visão Geral"  
		oWindow := oLayer:GetWinPanel("COL_ALL","WIN_ALL")	
		
		//-------------------------------------------------------------------
		// Define linhas e colunas. 
		//------------------------------------------------------------------- 	
		oRow := FWLayer():New()
		oRow:init( oWindow )
		oRow:addLine("LINE", 80)
		oRow:addCollumn( "LEFT", 50,, "LINE" )	
		oRow:addCollumn( "RIGHT", 50,, "LINE" )			
	
		//-------------------------------------------------------------------
		// Recupera as informações para montagem do gráfico. 
		//------------------------------------------------------------------- 	
		If ( HVZ->( MSSeek( HVY->HVY_ID ) ) )
			While ( ! HVZ->( Eof() ) .And. HVZ->HVZ_ID == HVY->HVY_ID )  
				//-------------------------------------------------------------------
				// Tempo por entidade. 
				//-------------------------------------------------------------------
				aAdd( aTime, { HVZ->HVZ_ENTITY, If( Empty( HVZ->HVZ_FINISD ) , 0, BIXTimeDiff( HVZ->HVZ_STARTD, HVZ->HVZ_STARTH, HVZ->HVZ_FINISD, HVZ->HVZ_FINISH, .F. ) ) } )  
				
				//-------------------------------------------------------------------
				// Registros por entidade. 
				//-------------------------------------------------------------------
				aAdd( aRecords, { HVZ->HVZ_ENTITY, HVZ->HVZ_RECORD } )

				HVZ->( DBSkip() )
			EndDo 
		EndIf 

		//-------------------------------------------------------------------
		// Monta o gráfico de tempo de extração por entidade.  
		//------------------------------------------------------------------- 	
		oEntityTime:init( oRow:getColPanel( "LEFT", "LINE" ), .T. )
		oEntityTime:setTitle( STR0036, CONTROL_ALIGN_CENTER ) //"Tempo em minutos por entidade"
		oEntityTime:SetColor( "RANDOM" )
		
		For nSerie := 1 To Len( aTime )
			oEntityTime:addSerie( aTime[nSerie][1] + " - " + BIXGetTitle( aTime[nSerie][1] ) , aTime[nSerie][2] ) 
		Next nSerie 

		oEntityTime:Build()	
		
		//-------------------------------------------------------------------
		// Monta o gráfico de registros extraídos por entidade. 
		//------------------------------------------------------------------- 	
		oEntityRecord:init( oRow:getColPanel( "RIGHT", "LINE" ), .T. )
		oEntityRecord:setTitle( STR0037, CONTROL_ALIGN_CENTER ) //"Registros por entidade"
		oEntityRecord:SetColor( "RANDOM" )
				
		For nSerie := 1 To Len( aRecords )
			oEntityRecord:addSerie( aRecords[nSerie][1] + " - " + BIXGetTitle( aRecords[nSerie][1] ), aRecords[nSerie][2] ) 
		Next nSerie 

		oEntityRecord:Build()
	ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., {},,,.F.,.F.,.F.,.F., .F. )

	RestArea( aAreaEntity ) 
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogPerformance
Monta a tela de visualização dos detalhes da extração de uma entidade. 

@param cEntity, caracter, Entidade que será analiada. 
@param cEmpFil, caracter, Filial. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXLogPerformance( cEntity, cEmpFil )
	Local oDialog		:= nil 
	Local oWindow		:= nil 
	Local oRow			:= nil 
	Local oLayer		:= nil 
	Local oEntityRecord	:= FWChartLine():New()
	Local oEntityTime	:= FWChartLine():New()
	Local aPosition 	:= FWGetDialogSize( oMainWnd )
	Local aRecords		:= {}
	Local aTime			:= {}
	Local cQuery		:= ""
	Local cTemp 		:= GetNextAlias()	
	Local nLimit		:= 30 
	Local bOK  			:= {|| oDialog:End() }
	Local bCancel		:= {|| oDialog:End() }
	
	Default cEntity		:= ""
	Default cEmpFil		:= ""
	
	//-------------------------------------------------------------------
	// Monta o detalhe. 
	//------------------------------------------------------------------- 
	DEFINE MSDIALOG oDialog TITLE STR0016 FROM aPosition[1], aPosition[2] TO aPosition[3], aPosition[4] PIXEL //"Detalhes da Extração"
		//-------------------------------------------------------------------
		// Define as camadas da interface. 
		//-------------------------------------------------------------------  
		oLayer := FWLayer():New()
		oLayer:init( oDialog )
		oLayer:addCollumn( "COL_ALL", 100, .F. )
		oLayer:addWindow( "COL_ALL", "WIN_ALL", STR0017 + " - " + AllTrim( cEntity ) + " - " + AllTrim( cEmpFil ), 92, .F., .T., {||} ) //"Análise de Performance"  
		oWindow := oLayer:GetWinPanel("COL_ALL","WIN_ALL")	
		
		//-------------------------------------------------------------------
		// Define linhas e colunas. 
		//------------------------------------------------------------------- 
		oRow := FWLayer():New()
		oRow:init( oWindow )
		oRow:addLine("LIN_TOP", 45)
		oRow:addCollumn( "COL_TOP", 100,, "LIN_TOP" )			
		oRow:addLine("LIN_BOTTOM", 45)
		oRow:addCollumn( "COL_BOTTOM", 100,, "LIN_BOTTOM" )			
		
		//-------------------------------------------------------------------
		// Recupera as informações para montagem do gráfico. 
		//------------------------------------------------------------------- 
		cQuery += " SELECT * FROM HVZ" 
		cQuery += " INNER JOIN HVY"
		cQuery += " ON" 
		cQuery += " 	HVY_ID = HVZ_ID"
		cQuery += " WHERE " 
		cQuery += " 	HVZ_ENTITY = '" + AllTrim( cEntity ) + "'"
		cQuery += " AND"
		cQuery += " 	HVY_EMPFIL = '" + AllTrim( cEmpFil ) + "'"
		cQuery += " AND"
		cQuery += " 	HVZ.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY" 
		cQuery += " 	HVY_ID DESC"
		
		//-------------------------------------------------------------------
		// Abre a área de trabalho temporária. 
		//-------------------------------------------------------------------  
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery ), cTemp, .T., .F.)	
		
		//-------------------------------------------------------------------
		// Converte os campos do tipo data. 
		//------------------------------------------------------------------- 
		TcSetField( cTemp, "HVZ_STARTD", "D", 8, 0 ) 
		TcSetField( cTemp, "HVZ_FINISD", "D", 8, 0 ) 

		While ( ! (cTemp)->( Eof() ) ) 
			//-------------------------------------------------------------------
			// Registros extraídos. 
			//-------------------------------------------------------------------
			aAdd( aRecords, { cBIStr( (cTemp)->HVZ_STARTD ) + " " + (cTemp)->HVZ_STARTH, (cTemp)->HVZ_RECORD } )

			//-------------------------------------------------------------------
			// Tempo em minutos. 
			//-------------------------------------------------------------------
			aAdd( aTime	, { cBIStr( (cTemp)->HVZ_STARTD ) + " " + (cTemp)->HVZ_STARTH, If( Empty( (cTemp)->HVZ_FINISD ) , 0, BIXTimeDiff( (cTemp)->HVZ_STARTD, (cTemp)->HVZ_STARTH, (cTemp)->HVZ_FINISD, (cTemp)->HVZ_FINISH, .F. ) ) } )
			
			//-------------------------------------------------------------------
			// Limite os registros no gráfico. 
			//-------------------------------------------------------------------
			If ( Len( aRecords ) >= nLimit )
				Exit
			EndIf 
			
			(cTemp)->( DBSkip() )
		EndDo	

		//-------------------------------------------------------------------
		// Ordena as informações do gráfico por data e hora. 
		//------------------------------------------------------------------- 
		ASort(aRecords, , , {|x,y| y[1] > x[1] })
		ASort(aTime	, , , {|x,y| y[1] > x[1] })
		
		//-------------------------------------------------------------------
		// Monta o gráfico de registros extraídos. 
		//------------------------------------------------------------------- 	
		oEntityRecord:init( oRow:getColPanel( "COL_TOP", "LIN_TOP" ), .T. ) 
		oEntityRecord:addSerie( STR0023, If ( Len( aRecords ) == 0, {{"",0}}, aRecords ) ) //"Registros extraídos"
		oEntityRecord:setTitle( STR0023 )
		oEntityRecord:Build()

		//-------------------------------------------------------------------
		// Monta o gráfico de tempo em minutos. 
		//------------------------------------------------------------------- 	
		oEntityTime:init( oRow:getColPanel( "COL_BOTTOM", "LIN_BOTTOM" ), .T. ) 
		oEntityTime:addSerie( STR0018, If ( Len( aTime ) == 0, {{"",0}}	, aTime ) ) //"Tempo em minutos"
		oEntityTime:setTitle( STR0018 )
		oEntityTime:Build()
	ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., {},,,.F.,.F.,.F.,.F., .F. )
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogData
Monta a tela de visualização dos dados da entidade. 

@param cEntity, caracter, Entidade que será analiada. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXLogData( cEntity )
	Local oDialog   := nil 
	Local oData     := nil 
	Local aPosition := FWGetDialogSize( oMainWnd )
	Local aFields   := {}
	Local nField    := 0
	Local bOK       := {|| oDialog:End() }
	Local bCancel   := {|| oDialog:End() }
	
	Default cEntity := ""

	If ! Empty( cEntity ) .And. ! ( BIXLinkFSD() < 0 )
		//-------------------------------------------------------------------
		// Limpa todos os espaços para correto funcionamento da query.
		//-------------------------------------------------------------------  	
		cEntity := AllTrim( cEntity )

		//-------------------------------------------------------------------
		// Abre a tabela da entidade. 
		//-------------------------------------------------------------------  			
		DBUseArea( .T., "TOPCONN", cEntity, cEntity, .T., .F. )

		//-------------------------------------------------------------------
		// Valida a abertura da tabela. 
		//-------------------------------------------------------------------
		If ! ( Select( cEntity ) == 0 )
			//-------------------------------------------------------------------
			// Monta o detalhe. 
			//------------------------------------------------------------------- 
			DEFINE MSDIALOG oDialog TITLE STR0025 FROM aPosition[1], aPosition[2] TO aPosition[3], aPosition[4] PIXEL //"Tabela"
				//-------------------------------------------------------------------
				// Define as camadas da interface. 
				//-------------------------------------------------------------------  
				oLayer := FWLayer():New()
				oLayer:init( oDialog )
				oLayer:addCollumn( "COL_ALL", 100, .F. )
				oLayer:addWindow( "COL_ALL", "WIN_ALL", STR0025 + " - " + cEntity, 92, .F., .T., {||} ) //"Tabela"
				oWindow := oLayer:GetWinPanel("COL_ALL","WIN_ALL")

				//-------------------------------------------------------------------
				// Monta o browse de dados. 
				//-------------------------------------------------------------------  
				DEFINE FWBROWSE oData DATA TABLE ALIAS cEntity NO SEEK NO CONFIG NO REPORT NO LOCATE FILTER OF oWindow
					//-------------------------------------------------------------------
					// Recupera a estrutura da tabela. 
					//-------------------------------------------------------------------  
					aFields := ( cEntity )->( DBStruct() )
	  			
					//-------------------------------------------------------------------
					// Monta as colunas do browse. 
					//------------------------------------------------------------------- 
					For nField := 1 To Len( aFields )
						ADD COLUMN oColumn DATA &("{||" + aFields[nField][1] + " }")  Title aFields[nField][1] SIZE ( aFields[nField][3] + aFields[nField][4] ) / 3 Of oData
					Next
					
					//--------------------------------------------------------------------
					// Fecha conexão com a Stage.
					//--------------------------------------------------------------------
					BIXUnlinkFSD()
					
				ACTIVATE FWBROWSE oData   		
			ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., { },,,.F.,.F.,.F.,.F., .F. )
	
			( cEntity )->( DBCloseArea() )
		Else
			ApMsgAlert(STR0082 , cEntity) //"Funcionalidade não disiponível para a entidade selecionada"
		EndIf
	EndIf

	BIXUnlinkFSD()
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogConfig
Monta a tela de configuração do log. 

@author  Valdiney V GOMES
@since   11/11/2014
/*/
//-------------------------------------------------------------------
Static Function BIXLogConfig()
	Local oDialog      := Nil 
	Local oMail        := Nil 
	Local oPeriod      := Nil
	Local oRecord      := Nil
	Local bOK          := {|| lSave := .T., oDialog:End() }
	Local bCancel      := {|| oDialog:End() }
	Local aConfig      := {}
	Local aPosition    := FWGetDialogSize( oMainWnd )
	Local lAlert       := BIXGetConfig( "CONFIG_ALERT"  , "L" 		)
	Local lEndAlert    := BIXGetConfig( "CONFIG_FINISH" , "L" 		)
	Local lCancelAlert := BIXGetConfig( "CONFIG_CANCEL" , "L" 		)
	Local lDebug       := BIXGetConfig( "CONFIG_DEBUG"  , "L" 		)
	Local cMail        := BIXGetConfig( "CONFIG_EMAIL"  , "C"		)
	Local nPeriodo     := BIXGetConfig( "CONFIG_PERIOD" , "N", 30	)
	Local nRecord      := BIXGetConfig( "CONFIG_RECORD" , "N", 200	)
	Local lSave        := .F. 

	cMail := Padr( cMail, 255 )

	//-------------------------------------------------------------------
	// Monta a tela de configuração. 
	//------------------------------------------------------------------- 
	DEFINE MSDIALOG oDialog TITLE STR0027 FROM aPosition[1], aPosition[2] TO aPosition[3], aPosition[4] PIXEL //Configurar
    	@ 000, 000 MSPANEL oPanel OF oDialog SIZE 000,000 
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
		
		//-------------------------------------------------------------------
		// Campo alertar quando ouver erro na extração.
		//-------------------------------------------------------------------	
		@ 15,20 CHECKBOX lDebug PROMPT STR0081 PIXEL SIZE 400,10 OF oPanel	// "Habilitar o modo de debug ?"	
		
		//-------------------------------------------------------------------
		// Campo alertar quando ouver erro na extração.
		//-------------------------------------------------------------------	
		@ 35,20 CHECKBOX lAlert PROMPT STR0029 PIXEL SIZE 400,10 OF oPanel	// "Alertar sobre ocorrência de erro na extração de fatos e dimensões ?"

		//-------------------------------------------------------------------
		// Campo alertar quando uma extração for finalizada.
		//-------------------------------------------------------------------	
		@ 55,20 CHECKBOX lEndAlert PROMPT STR0074 PIXEL SIZE 400,10 OF oPanel // "Alertar no momento em que uma extração for finalizada ? "
		
		//-------------------------------------------------------------------
		// Campo alertar quando uma extração ficar obsoleta / Cancelada.
		//-------------------------------------------------------------------	
		@ 75,20 CHECKBOX lCancelAlert PROMPT STR0075 PIXEL SIZE 400,10 OF oPanel // "Alertar no momento em que uma extração for cancelada ?"
		
		//-------------------------------------------------------------------
		// Descrição do campo email.
		//-------------------------------------------------------------------
		@ 95,20 SAY STR0030 OF oPanel PIXEL //"Quem deve ser comunicado quando alguma das opções acima for contemplada ? Os emails devem ser separador por ponto e vírgula."
		
		//-------------------------------------------------------------------
		// Campo email.
		//-------------------------------------------------------------------
		@ 105,20 MSGET oMail VAR cMail SIZE 400,10 OF oPanel PIXEL PICTURE "@" 
		
		//-------------------------------------------------------------------
		// Descrição do campo de cancelamento de processo de extração.
		//-------------------------------------------------------------------
		@ 125,20 SAY STR0039 OF oPanel PIXEL // "Marcar como canceladas extrações não finalizadas em quantos dias?"
		
		//-------------------------------------------------------------------
		// Campo período.
		//-------------------------------------------------------------------
		oPeriod := tSpinBox():new(135, 20, oPanel, {|x| nPeriodo := x } , 35, 13)
		oPeriod:setRange(1, 30)
	   	oPeriod:setStep(1)
	   	oPeriod:setValue( nPeriodo )
	   	
	   	//-------------------------------------------------------------------
		// Descrição do campo de quantidade de registros que serão guardados na sessão de extrações.
		//-------------------------------------------------------------------
		@ 155,20 SAY STR0041 OF oPanel PIXEL // "Qual a quantidade de registros que deseja manter na sessão de extrações?"
		
		//-------------------------------------------------------------------
		// Campo Informar quantidade de registros que serão mantidos na sessão de extrações.
		//-------------------------------------------------------------------
		oRecord := tSpinBox():new(165, 20, oPanel, {|x| nRecord := x } , 35, 13)
		oRecord:setRange(1, 500)
	   	oRecord:setStep(1)
	   	oRecord:setValue( nRecord )
	ACTIVATE MSDIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., { },,,.F.,.F.,.F.,.T., .F. )

	//-------------------------------------------------------------------
	// Identifica se deve gravar a configuração.
	//-------------------------------------------------------------------	
	If ( lSave )
		aAdd( aConfig, {"CONFIG_ALERT"	, lAlert 		} )
		aAdd( aConfig, {"CONFIG_FINISH"	, lEndAlert		} )
		aAdd( aConfig, {"CONFIG_CANCEL"	, lCancelAlert	} )	
		aAdd( aConfig, {"CONFIG_DEBUG"	, lDebug 		} )			
		aAdd( aConfig, {"CONFIG_EMAIL"	, cMail 		} )
		aAdd( aConfig, {"CONFIG_PERIOD"	, nPeriodo 		} )
		aAdd( aConfig, {"CONFIG_RECORD"	, nRecord 		} )	
			
		//-------------------------------------------------------------------
		// Grava as configurações.
		//-------------------------------------------------------------------		
		BIXSetConfig( aConfig )
		
		//-------------------------------------------------------------------
		// Realiza a limpeza do log de extração.
		//------------------------------------------------------------------- 
		BIXClearLog()
	EndIf 
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSetConfig
Grava uma ou mais configurações. 

@param aConfig, array, Lista no formato {CONFIG, CONTENT}. 

@author  Valdiney V GOMES
@since   11/11/2014
/*/
//-------------------------------------------------------------------
Static Function BIXSetConfig( aConfig )
	Local nConfig 	:= 0
	Local lConfig	:= .F. 
	
	Default aConfig := {}
	
	For nConfig := 1 To Len( aConfig )
		//-------------------------------------------------------------------
		// Identifica se é para incluir ou atualizar a configuração.
		//-------------------------------------------------------------------	
		lConfig := HY4->( MSSeek( aConfig[nConfig][1] ) )		
		
		//-------------------------------------------------------------------
		// Incluir ou atualizar a configuração.
		//-------------------------------------------------------------------	
		If( RecLock( "HY4", ! lConfig  ) )
			HY4->HY4_CONFIG	:= aConfig[nConfig][1]
			HY4->HY4_MEMO 	:= cBIStr( aConfig[nConfig][2] )
			HY4->( MsUnlock() )
		EndIf 
	Next aConfig
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetConfig
Retorna o conteúdo de uma configuração do log. 

@param cConfig, caracter, Identificador da configuração. 
@param cType, caracter, Tipo de retorno. 
@return xValue, Configuração convertida para o tipo informado. 

@author  Valdiney V GOMES
@since   11/11/2014
/*/
//-------------------------------------------------------------------
Static Function BIXGetConfig( cConfig, cType, xDefault )
	Local xValue 		:= nil 
	
	Default cConfig 	:= ""	
	Default cType 		:= ""
	Default xDefault	:= nil 

	//-------------------------------------------------------------------
	// Retorna a configuração convertida para o tipo correto.
	//-------------------------------------------------------------------
	If ( HY4->( MSSeek( cConfig ) ) )	
		xValue := xBIConvTo( cType, HY4->HY4_MEMO )
	EndIf 
	
	//-------------------------------------------------------------------
	// Verifica se deve assumir o valor padrão.
	//-------------------------------------------------------------------	
	If ( xValue == nil .And. ! ( xDefault == nil ) )
		xValue := xBIConvTo( cType, xDefault )
	EndIf	
Return xValue

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogID
Retorna um identificador único para cada processo de extração. 

@return __cLogID, ID único. 

@author  Valdiney V GOMES
@since   07/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXLogID()  
	Local aArea		:= {}
	Local cTemp		:= ""
	Local cDML		:= ""
	Local cLock 	:= ""
	Local cTaskID	:= ""
	Local nHandle	:= 0
	Local cIDNumber	:= ""

	aArea		:= GetArea() 
	cLock 		:= BIXLock( "BIXLOG", "", .F. ) 
	cTaskID		:= BIXTaskID()

	If ( __cLogID == nil .Or. ! ( __cScheduleID == cTaskID  ) ) 
		//-------------------------------------------------------------------
		// Insere um lock para evitar duplicidade de ID. 
		//-------------------------------------------------------------------	
		While ( ( nHandle := FCreate( cLock, 1 ) ) == -1 )
			Sleep( 100 ) 
		EndDo 
		
		//-------------------------------------------------------------------
		// Monta o DML. 
		//-------------------------------------------------------------------			
		cDML := "SELECT MAX( HVY_ID ) ID FROM HVY"

		//-------------------------------------------------------------------
		// Executa o DML. 
		//-------------------------------------------------------------------		
		DBUseArea(.T., "TOPCONN", TCGenQry(,, cDML ), cTemp	:= GetNextAlias(), .T., .F.)

	 	//-------------------------------------------------------------------
		// Recupera o ID. 
		//-------------------------------------------------------------------		
	 	If ! (cTemp)->( Eof() )
	 		cIDNumber := (cTemp)->ID
	 		If TcGetDB() == "POSTGRES"
	 			cIDNumber := Alltrim((cTemp)->ID)
	 			If !Empty(cIDNumber)
	 				cIdNumber := Right( cIdNumber, 6)
	 			Else
	 				cIDNumber := "000000"
	 			EndIf
	 		EndIf
	 		__cLogID := Soma1( cIdNumber ) 
	 	Else
	 		__cLogID := "000000"
	 	EndIf 
		 	
		(cTemp)->( DBCloseArea() )

		//-------------------------------------------------------------------
		// Cria o cabeçalho do Log 
		//-------------------------------------------------------------------
		RecLock( "HVY", .T.  ) 
			HVY->HVY_ID			:= __cLogID
			HVY->HVY_EMPFIL 	:= cEmpAnt + "/" + cFilAnt
			HVY->HVY_EXEC		:= BIXGetRun()
		HVY->( MsUnlock() )
	
		//-------------------------------------------------------------------
		// Recupera o ID da tarefa do schedule. 
		//-------------------------------------------------------------------		
		__cScheduleID	:= cTaskID

		//-------------------------------------------------------------------
		// Remove o lock do processo. 
		//-------------------------------------------------------------------
		FClose( nHandle )  
		FErase( cLock ) 
	EndIf 
	RestArea( aArea )
Return __cLogID

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMail
Envia uma email considerando as configurações de Email/Proxy. 

@param cTo, caracter, Lista de destinatários separados por ;. 
@param cSubject, caracter, Assunto do email. 
@param cMensagem, caracter, Corpo de mensagem.
@return lOK, lógico, Identifica se o email foi enviado. 

@author  Valdiney V GOMES
@since   11/11/2014
/*/
//-------------------------------------------------------------------
Static Function BIXMail( cTo, cSubject, cMensagem, cAnexo )
	Local cSMTPServer := AllTrim( GetMV("MV_RELSERV"))
	Local cLogin      := AllTrim( GetMV("MV_RELACNT"))
	Local cPassword   := AllTrim( GetMV("MV_RELPSW" ))
	Local cMail       := AllTrim( GetMV("MV_RELACNT"))
	Local cFrom       := AllTrim( GetMV("MV_RELFROM"))
	Local lAuth       := GetMV("MV_RELAUTH" )
	Local lOK         := .F. 
	
	Default cTo       := ""
	Default cSubject  := ""
	Default cMensagem := ""
	Default cAnexo    := ""
		
	// ------------------------------------------------------
	// Verifica se o Email/Proxy foi configurado. 
	// ------------------------------------------------------		
	If ( ! Empty( cSMTPServer ) .And. ! Empty( cMail ) .And. ! Empty( cLogin )  )
		// ------------------------------------------------------
		// Conecta no servidor SMTP
		// ------------------------------------------------------
		CONNECT SMTP SERVER cSMTPServer ACCOUNT cLogin PASSWORD cPassword RESULT lOk
		
		// ------------------------------------------------------
		// Verifica se o servidor requer autenticação. 
		// ------------------------------------------------------
		If ( lOk )
			If ( lAuth )
				lOk := MailAuth(cLogin,cPassword)
			EndIf
		EndIf

		//-------------------------------------------------------------------
		// Identifica a conta do remetente.
		//-------------------------------------------------------------------
		If ( Empty( cFrom ) ) 
			cFrom := cMail
		EndIf

		// ------------------------------------------------------
		// Envia o e-mail.
		// ------------------------------------------------------
		If ( lOk )
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cMensagem ATTACHMENT cAnexo RESULT lOk
		EndIf

		// ------------------------------------------------------
		// Verifica se ocorreu erro no envio.
		// ------------------------------------------------------	
		If ! ( lOk )
			BIXSysOut("BIXLOG", STR0032 ) //"O email não pode ser enviado"
		EndIf
		
		// ------------------------------------------------------
		// Disconecta do servidor SMTP.
		// ------------------------------------------------------	
		DISCONNECT SMTP SERVER
	Else
		BIXSysOut("BIXLOG", STR0033 + cEmpAnt ) //"Email/Proxy não configurado para empresa "
	EndIf
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogReport
Rotina que cria um relatório do log de extração.

@Param lDialog, lógico, Identifica se deve abrir a tela de configuração de envio de e-mail.
@Return String, Retorna uma cadeia de caracteres que contem o caminho do relatório gerado.

@author  Helio Leal
@since   20/03/2015
/*/
//-------------------------------------------------------------------
Static Function BIXLogReport( lDialog )
	Local aAreaProcess	:= HVY->( GetArea() )
	Local cPath			:= "\BIEXTRACTOR\REPORTS\"
	Local cReport 		:= CriaTrab(NIL, .F.) + ".HTML"
	Local oHtmFile		:= nil
	Local cClass			:= ""

	Default lDialog		:= .F.

	//-------------------------------------------------------------------
	// Inicia o Objeto de manipulação de arquivos.
	//-------------------------------------------------------------------
	oHtmFile := TBIFileIO():New( cPath + cReport )

	//-------------------------------------------------------------------
	// Cria o arquivo HTML.
	//-------------------------------------------------------------------
	If ( oHtmFile:lCreate( FO_READWRITE + FO_EXCLUSIVE, .T. ) )
		//-------------------------------------------------------------------
		// Montagem do cabeçalho e do corpo do relatório.
		//-------------------------------------------------------------------
		oHtmFile:nWriteLN("<html>")
		oHtmFile:nWriteLN("	<head>")
		oHtmFile:nWriteLN("		<title>"+ STR0052 +"</title>") // "Relatório do Log de Extração"
		oHtmFile:nWriteLN("		<meta content='text/html; charset=iso-8859-1' http-equiv='Content-Type'>")
		oHtmFile:nWriteLN("		<style type='text/css'>")
		oHtmFile:nWriteLN("		.tabela {")
		oHtmFile:nWriteLN("			color: #000000;")
		oHtmFile:nWriteLN("			padding: 0px;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.tabela tr td {")
		oHtmFile:nWriteLN("			border:1px solid #6B6B6B;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.cabecalho_2 {")
		oHtmFile:nWriteLN("			color: #000000;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #7BA0CA;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("			margin: 3px;")
		oHtmFile:nWriteLN("			padding: 3px;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.texto3 {")
		oHtmFile:nWriteLN("			color: #333333;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #FFFFFF;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("			margin: 3px;")
		oHtmFile:nWriteLN("			padding: 3px;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.textoExec {")
		oHtmFile:nWriteLN("			color: #333333;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #FFFF6F;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("			margin: 3px;")
		oHtmFile:nWriteLN("			padding: 3px;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.titulo{")
		oHtmFile:nWriteLN("			font-family: Verdana, Arial, Helvetica, sans-serif;")
		oHtmFile:nWriteLN("			font-size: 16px;")
		oHtmFile:nWriteLN("			font-weight: bold;")
		oHtmFile:nWriteLN("			color: #406496;")
		oHtmFile:nWriteLN("			margin: 0px;")
		oHtmFile:nWriteLN("			padding: 0px;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.texto {")
		oHtmFile:nWriteLN("			color: #666666;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #FFFFFF;")
		oHtmFile:nWriteLN("			margin: 0px;")
		oHtmFile:nWriteLN("			padding: 0px;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.textoAviso {")
		oHtmFile:nWriteLN("			color: #333333;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #B5F9B7;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("			margin: 3px;")
		oHtmFile:nWriteLN("			padding: 3px;")
		oHtmFile:nWriteLN("		}")	
		oHtmFile:nWriteLN("		.textoErro { ")
		oHtmFile:nWriteLN("			color: #333333; ")
		oHtmFile:nWriteLN("			font-family: Verdana; ")
		oHtmFile:nWriteLN("			font-size: 10px; ")
		oHtmFile:nWriteLN("			background-color: #FF8282; ")
		oHtmFile:nWriteLN("			border-collapse: collapse; ")
		oHtmFile:nWriteLN("			margin: 3px; ")
		oHtmFile:nWriteLN("			padding: 3px; ")
		oHtmFile:nWriteLN("		} ")
		oHtmFile:nWriteLN("		.textoAtu {")
		oHtmFile:nWriteLN("			color: #333333;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #A7F3F8;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("			margin: 3px;")
		oHtmFile:nWriteLN("			padding: 3px;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		.textoCancel {")
		oHtmFile:nWriteLN("			color: #333333;")
		oHtmFile:nWriteLN("			font-family: Verdana;")
		oHtmFile:nWriteLN("			font-size: 10px;")
		oHtmFile:nWriteLN("			background-color: #CFCFCF;")
		oHtmFile:nWriteLN("			border-collapse: collapse;")
		oHtmFile:nWriteLN("			margin: 3px;")
		oHtmFile:nWriteLN("			padding: 3px;")
		oHtmFile:nWriteLN("		}")
		oHtmFile:nWriteLN("		</style>")
		oHtmFile:nWriteLN("	</head>")
		oHtmFile:nWriteLN("	<body leftmargin='0' topmargin='0' marginwidth='0' marginheight='0'>")
		oHtmFile:nWriteLN("		<table style='margin-left:1%' width='99%' border='0' cellpadding='0' cellspacing='0' class='tabela'>")
		oHtmFile:nWriteLN("			<tr>")
		oHtmFile:nWriteLN("				<td width='80%' class='titulo'>")
		oHtmFile:nWriteLN("					<div align='center'>")
		oHtmFile:nWriteLN("						"+ STR0052 ) // Relatório do Log de Extração
		oHtmFile:nWriteLN("					</div>")
		oHtmFile:nWriteLN("				</td>")
		oHtmFile:nWriteLN("				<td width='20%' class='texto'>")
		oHtmFile:nWriteLN("					<div align='right'>")
		oHtmFile:nWriteLN("						"+ STR0007 + ": " + HVY->HVY_EMPFIL + "<br />")
		oHtmFile:nWriteLN("						"+ STR0011 + ": " + BIXTimeDiff( HVY->HVY_STARTD, HVY->HVY_STARTH, HVY->HVY_FINISD,  HVY->HVY_FINISH ) + "<br />")
		oHtmFile:nWriteLN("						"+ STR0009 + ": " + DToC( HVY->HVY_STARTD ) + " " + HVY->HVY_STARTH + "<br />")
		oHtmFile:nWriteLN("						"+ STR0010 + ": " + DToC( HVY->HVY_FINISD ) + " " + HVY->HVY_FINISH +" <br />")
		
		If !Empty( HVY->HVY_PROFIL )
			oHtmFile:nWriteLN("					"+ STR0008 + ": " + HVY->HVY_PROFIL +" <br />")
		EndIf
		
		oHtmFile:nWriteLN("					</div>")
		oHtmFile:nWriteLN("				</td>")
		oHtmFile:nWriteLN("			</tr>")
		oHtmFile:nWriteLN("		</table>")
		oHtmFile:nWriteLN("		<br />")
		oHtmFile:nWriteLN("		<table style='margin-left:1%' width='99%' border='0' cellpadding='0' cellspacing='0' class='tabela'>")
		oHtmFile:nWriteLN("			<tr class='cabecalho_2'>") 
		oHtmFile:nWriteLN("				<td width='14.5%' align='center'><Strong> " + STR0054 + " 	</Strong></td>") // "Status"
		oHtmFile:nWriteLN("				<td width='23.5%' align='center'><strong> " + STR0013 + " </Strong></td>") // "Entidade"
		oHtmFile:nWriteLN("				<td width='06.0%' align='center'><strong> " + STR0011 + " </Strong></td>") // "Tempo"
		oHtmFile:nWriteLN("				<td width='06.0%' align='center'><strong> " + STR0015 + " </Strong></td>") // "Registros"
		oHtmFile:nWriteLN("				<td width='15.0%' align='center'><strong> " + STR0014 + " </Strong></td>") // "Período"
		oHtmFile:nWriteLN("				<td width='12.0%' align='center'><strong> Início </Strong></td>")
		oHtmFile:nWriteLN("				<td width='12.0%' align='center'><strong> Final </Strong></td>")
		oHtmFile:nWriteLN("			</tr>")
		
		//-------------------------------------------------------------------
		// Recebe a tabela com as entidades que são ligadas ao processo.
		//-------------------------------------------------------------------
		If ( HVZ->( MSSeek( HVY->HVY_ID ) ) )
			While ( ! HVZ->( Eof() ) .And. HVZ->HVZ_ID == HVY->HVY_ID )
				//-------------------------------------------------------------------
				// Verifica o Status da entidade.
				//-------------------------------------------------------------------
				Do Case
					Case HVZ->HVZ_STATUS == 1
						cClass := " class='textoExec' "
						cDescr := STR0004 //"Executando"
					Case HVZ->HVZ_STATUS == 3				
						cClass := " class='texto3' "
						cDescr := STR0006 //"Finalizado"
					Case HVZ->HVZ_STATUS == 5
						cClass := " class='textoAtu' "
						cDescr := STR0042 //"Atualizado anteriormente"
					Case HVZ->HVZ_STATUS == 2
						cClass := " class='textoErro' "
						cDescr := STR0005 //"Finalizado com erro"
					Case HVZ->HVZ_STATUS == 4
						cClass := " class='textoCancel' "
						cDescr := STR0040 //"Cancelado"
				EndCase
	
				oHtmFile:nWriteLN("			<tr>")
				oHtmFile:nWriteLN("				<td " + cClass + " align='center'>"	+ cDescr +"</td>")		
				oHtmFile:nWriteLN("				<td " + cClass + " align='left'>")
				oHtmFile:nWriteLN(					HVZ->HVZ_ENTITY + " - " + BIXGetTitle( HVZ->HVZ_ENTITY ) ) 
				oHtmFile:nWriteLN("				</td>")
				oHtmFile:nWriteLN("				<td " + cClass + " align='center'>" + BIXTimeDiff( HVZ->HVZ_STARTD, HVZ->HVZ_STARTH, HVZ->HVZ_FINISD,  HVZ->HVZ_FINISH ) + "</td>")
				oHtmFile:nWriteLN("				<td " + cClass + " align='center'>"	+ cBIStr( HVZ->HVZ_RECORD ) + "</td>")
				oHtmFile:nWriteLN("				<td " + cClass + " align='center'>" + cBIStr( HVZ->HVZ_PERIOF ) + " - " + cBIStr( HVZ->HVZ_PERIOT ) + "</td>")
				oHtmFile:nWriteLN("				<td " + cClass + " align='center'>" + DToC( HVZ->HVZ_STARTD ) 	+ " " + HVZ->HVZ_STARTH + "</td>")
				oHtmFile:nWriteLN("				<td " + cClass + " align='center'>" + DToC( HVZ->HVZ_FINISD )	 + " " + HVZ->HVZ_FINISH + "</td>")
				oHtmFile:nWriteLN("			</tr>")
				
				//------------------------------------------------------------------------------
				// Caso exista algum conteúdo para a entidade, o conteúdo é colocado na tela.
				//------------------------------------------------------------------------------
				If ( HVZ->HVZ_STATUS == 2 )
					oHtmFile:nWriteLN("			<tr>")				
					oHtmFile:nWriteLN("				<td " + cClass + " colspan='8' align='justify'>" + StrTran(HVZ->HVZ_MEMO, chr(10), "<br/>") + "</td>")
					oHtmFile:nWriteLN("			</tr>")
				ElseIf ( !Empty(HVZ->HVZ_MEMO) )
					oHtmFile:nWriteLN("			<tr>")	 			
					oHtmFile:nWriteLN("				<td colspan='8' align='justify' class='texto'>" + StrTran(HVZ->HVZ_MEMO, chr(10), "<br/>") + "</td>")
					oHtmFile:nWriteLN("			</tr>")
				EndIf		
				
				HVZ->( DBSkip() )
			EndDo
		EndIf
	
		oHtmFile:nWriteLN("		</table>")
		oHtmFile:nWriteLN("	</body>	")
		oHtmFile:nWriteLN("</html>")
		
		//-------------------------------------------------------------------
		// Fecha o arquivo e restaura a área.
		//-------------------------------------------------------------------
		oHtmFile:lClose()
	
		//-------------------------------------------------------------------
		// Chama a 'tela' de envio de e-mail e se deve mostrar o relatório no browser.
		//-------------------------------------------------------------------
		If ( lDialog )
			BIXSendReport( cPath, cReport )
			//-------------------------------------------------------------------
			// Remove o arquivo de relatório do LOG.
			//-------------------------------------------------------------------
			FErase(cPath + cReport)
		EndIf
	Else
		BIXSysOut( "BIXLOG", STR0051 ) // "Erro na criação do arquivo HTML"
	EndIf
	
	RestArea( aAreaProcess )
Return cPath + cReport

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSendReport
Rotina que envia o relatório criado por e-mail e pergunta se o usuário 
deseja abrir o relatório pelo browser de internet.

@Param cPath, caracter, Recebe o caminho + nome do arquivo para ser enviado por e-mail.

@author  Helio Leal
@since   20/03/2015
/*/
//-------------------------------------------------------------------
Static Function BIXSendReport( cPath, cReport )
	Local oDialog 	:= nil
	Local oMail		:= nil
	Local aPosition	:= FWGetDialogSize( oMainWnd )
	Local cMail		:= Space( 255 )
	Local cSubject	:= ""
	Local cBody		:= ""
	Local lMail		:= .F.
	Local lSave		:= .F.
	Local lBrowser	:= .F.
	Local bOK  		:= {|| lSave := .T., oDialog:End() }
	Local bCancel	:= {|| oDialog:End() }

	Default cReport	:= ""
	Default cPath	:= ""

	//-------------------------------------------------------------------
	// Monta a tela de configuração. 
	//------------------------------------------------------------------- 
	DEFINE MSDIALOG oDialog TITLE STR0056 FROM 050, 150 TO 300,1000 PIXEL // "Relatório Gerado com sucesso"
    	@ 000, 000 MSPANEL oPanel OF oDialog SIZE 000,000 
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 15,20 CHECKBOX lMail PROMPT STR0057 PIXEL SIZE 400,10 OF oPanel // "Enviar arquivo HTML gerado por e-mail ? "	
		@ 35,20 SAY STR0058 OF oPanel PIXEL // "Quem deve receber e-mail com o relatório gerado em anexo ?"
		@ 45,20 MSGET oMail VAR cMail SIZE 400,10 OF oPanel PIXEL PICTURE "@"	
		@ 65,20 CHECKBOX lBrowser PROMPT STR0059 PIXEL SIZE 400,10 OF oPanel // "Abrir arquivo HTML gerado no browser após confirmação? " 
	ACTIVATE MSDIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., { },,,.F.,.F.,.F.,.T., .F. )
	
	If ( lSave )
		//-------------------------------------------------------------------
		// Verifica se deve ser enviado por e-mail.
		//-------------------------------------------------------------------
		If ( lMail )
			BIXManageMail( 0, cMail, cPath + cReport )
		EndIf
		
		//-------------------------------------------------------------------
		// Verifica se deve ser aberto o browser.
		//-------------------------------------------------------------------
	  	If ( lBrowser )
		  	If ( CpyS2T ( cPath + cReport, GetTempPath(.T.), .T. ) )
		  		If ! ( GetRemoteType() == 5 )
			  		ShellExecute("OPEN", cBIFixPath( GetTempPath(.T.), "\") + cReport ,"" ,"" ,SW_SHOWMAXIMIZED )
		  		Else		
		  			MsgInfo(STR0067, STR0053) // "Relatório não disponível para visualização no SmartCliente HTML." ### "Aviso" 
		  		EndIf
		  	EndIf
	  	EndIf 
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXManageEmails
Esta função é responsável por gerenciar os e-mails que serão enviados. ela
será responsável por direcionar a opção de envio ( se é de origem erro, cancelada,
finalizada etc.)

@Param nTipo Numérico Recebe o tipo de origem: (0: Gerar relatório; 2: Erro; 3: Finalizada 4: Cancelada)

@author  Helio Leal
@since   31/03/2015
/*/
//-------------------------------------------------------------------
Static Function BIXManageMail( nTipo, cMail, cReport )
	Local cBody 		:= ""
	Local cSubject	:= ""
	Local cTo			:= ""
	Local cAttachment	:= ""

	Default nTipo 	:= 0
	Default cMail		:= ""
	Default cReport	:= ""

	Do Case
		Case nTipo == 0
			//-------------------------------------------------------------------
			// Verifica se algum email foi informado.
			//-------------------------------------------------------------------
			If ( ! Empty( cMail ) )
				//-------------------------------------------------------------------
				// Monta o assunto. 
				//-------------------------------------------------------------------
				cSubject 	:= STR0052 // "Relatório do Log de Extração"
				
				//-------------------------------------------------------------------
				// Monta o corpo. 
				//-------------------------------------------------------------------
				cBody	 	+= STR0060 + ",<br><br>" // "Prezado(s)"
				cBody		+= STR0061 + "<br><br>" // "Segue em anexo Relatório do LOG DE EXTRAÇÃO." 			 
				cBody		+= "<b>" + STR0062 + "</b>" + cBIStr( Date() ) + "<br>" // "Data da geração:" 
				cBody		+= "<b>" + STR0063 + "</b>" + cBIStr( Time() ) // "Hora da geração:"
				
				//-------------------------------------------------------------------
				// Envia o email. 
				//-------------------------------------------------------------------
				If( BIXMail( cMail, cSubject, cBody, cReport ) )
					MsgInfo(STR0064, STR0065) // "E-mail Enviado com sucesso." ### "Sucesso"
				Else
					MsgInfo(STR0032) //"O email não pode ser enviado" 
				EndIf
				//-------------------------------------------------------------------
				// Remove o arquivo de relatório do LOG.
				//-------------------------------------------------------------------
				FErase( cReport )
			EndIf
		Case nTipo == LOG_ERROR
			If ( BIXGetConfig( "CONFIG_ALERT", "L" ) )
				cTo := BIXGetConfig( "CONFIG_EMAIL", "C" )

				//-------------------------------------------------------------------
				// Verifica se algum email foi informado.
				//-------------------------------------------------------------------
				If ! ( Empty( cTo ) )
					//-------------------------------------------------------------------
					// Monta o assunto.
					//-------------------------------------------------------------------
					cSubject 	:= STR0028 + HVZ->HVZ_ENTITY  //"TOTVS Protheus - Erro de extração: "

					//-------------------------------------------------------------------
					// Monta o corpo.
					//-------------------------------------------------------------------
					cBody		:= StrTran( HVZ->HVZ_MEMO, Chr(10), "<br>" )
					
					//-------------------------------------------------------------------
					// Monta o anexo. 
					//-------------------------------------------------------------------
					cAttachment := BIXLogReport( )

					//-------------------------------------------------------------------
					// Envia o email. 
					//-------------------------------------------------------------------	
					If ( BIXMail( cTo, cSubject, cBody, cAttachment ) )
						BIXSysOut("BIXLOG", STR0064 ) // "E-mail Enviado com sucesso." ### "Sucesso"
					Else
						BIXSysOut("BIXLOG", STR0032 ) //"O email não pode ser enviado"
					EndIf
					
					//-------------------------------------------------------------------
					// Remove o arquivo de relatório do LOG.
					//-------------------------------------------------------------------
					FErase( cAttachment )
				EndIf 
			EndIf
		Case nTipo == LOG_FINISH
			//-------------------------------------------------------------------
			// Enviar e-mail quando finalizar a extração ?
			//-------------------------------------------------------------------
			If ( BIXGetConfig( "CONFIG_FINISH"	, "L" ) )					
				cTo := BIXGetConfig( "CONFIG_EMAIL", "C" )
	
				If ! ( Empty( cTo ) )
					//-------------------------------------------------------------------
					// Monta o assunto. 
					//-------------------------------------------------------------------
					cSubject 	:= STR0071 + " (" + cEmpAnt + "/" + cFilAnt + ")" // "Processo de Extração Finalizado"
					
					//-------------------------------------------------------------------
					// Monta o corpo. 
					//-------------------------------------------------------------------
					cBody		+= STR0072 + " <br><br>" // "O Processo de extração foi finalizado com sucesso."
					cBody		+= "<b>" + STR0007 + ": </b>" + HVY->HVY_EMPFIL + "<br />
					cBody		+= "<b>" + STR0011 + ": </b>" + BIXTimeDiff( HVY->HVY_STARTD, HVY->HVY_STARTH, HVY->HVY_FINISD,  HVY->HVY_FINISH ) + "<br />
					cBody		+= "<b>" + STR0009 + ": </b>" + DToC( HVY->HVY_STARTD ) + " " + HVY->HVY_STARTH + "<br />
					cBody		+= "<b>" + STR0010 + ": </b>" + DToC( HVY->HVY_FINISD ) + " " + HVY->HVY_FINISH +" <br />
					cBody		+= "<b>" + STR0008 + ": </b>" + HVY->HVY_PROFIL +" <br />
	
					//-------------------------------------------------------------------
					// Monta o anexo. 
					//-------------------------------------------------------------------
					cAttachment := BIXLogReport( )
	
					//-------------------------------------------------------------------
					// Envia o email. 
					//-------------------------------------------------------------------	
					If ( BIXMail( cTo, cSubject, cBody, cAttachment ) )
						BIXSysOut("BIXLOG", STR0064 ) // "E-mail Enviado com sucesso." ### "Sucesso"
					Else
						BIXSysOut("BIXLOG", STR0032 ) //"O email não pode ser enviado"
					EndIf
					
					//-------------------------------------------------------------------
					// Remove o arquivo de relatório do LOG.
					//-------------------------------------------------------------------
					FErase( cAttachment )
				Else
					BIXSysOut("BIXLOG", STR0073 ) // "Destinatários não informados nas configurações do LOG"
				EndIf 
			EndIf
		Case nTipo == LOG_CANCEL
			//-------------------------------------------------------------------
			// Enviar e-mail quando cancelar a extração?
			//-------------------------------------------------------------------
			If ( BIXGetConfig( "CONFIG_CANCEL"	, "L" ) )
				cTo := BIXGetConfig( "CONFIG_EMAIL", "C" )
	
				If ! ( Empty( cTo ) )
					//-------------------------------------------------------------------
					// Monta o assunto. 
					//-------------------------------------------------------------------
					cSubject 	:= STR0076 // "Processo de Extração Cancelado"
					
					//-------------------------------------------------------------------
					// Monta o corpo. 
					//-------------------------------------------------------------------
					cBody		+= STR0077 + " <br><br>" // "O Processo de extração foi marcado como cancelado."
					cBody		+= "<b>" + STR0007 + ": </b>" + HVY->HVY_EMPFIL + "<br />"
					cBody		+= "<b>" + STR0009 + ": </b>" + DToC( HVY->HVY_STARTD ) + " " + HVY->HVY_STARTH + " <br />" 
					cBody		+= "<b>" + STR0078 + ": </b>" + DToC( HVY->HVY_FINISD ) + " " + HVY->HVY_FINISH + " <br />" //  Cancelada no dia
					cBody		+= "<b>" + STR0008 + ": </b>" + HVY->HVY_PROFIL +" <br />"
					
					//-------------------------------------------------------------------
					// Monta o anexo. 
					//-------------------------------------------------------------------
					cAttachment := BIXLogReport( )

					//-------------------------------------------------------------------
					// Envia o email. 
					//-------------------------------------------------------------------	
					If ( BIXMail( cTo, cSubject, cBody, cAttachment ) )
						BIXSysOut("BIXLOG", STR0064 ) // "E-mail Enviado com sucesso." ### "Sucesso"
					Else
						BIXSysOut("BIXLOG", STR0032 ) //"O email não pode ser enviado"
					EndIf
					
					//-------------------------------------------------------------------
					// Remove o arquivo de relatório do LOG.
					//-------------------------------------------------------------------
					FErase( cAttachment )
				Else
					BIXSysOut("BIXLOG", STR0073 ) //"Destinatários não informados nas configurações do LOG"
				EndIf
			EndIf
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetTitle
Retorna uma das propriedades do objeto.
 
@param cEntity, caracter, Entidade.  
@return cTitle, valor da propriedade. 

@author  Valdiney V GOMES
@version P12
@since   08/02/2017
/*/
//-------------------------------------------------------------------
Static Function BIXGetTitle( cEntity )
	Local oEntity 	:= nil
	Local cTitle 	:= "" 
	
	Default cEntity		:= ""
 	
 	//---------------------------------------------------------------------------------------
	// Limpa todos os espaços para o correto funcionamento para todos os bancos de dados.
	//---------------------------------------------------------------------------------------
 	cEntity := AllTrim( cEntity )

	If ! ( Empty( cEntity ) )
		oEntity := BIXObject( cEntity )
		
		If ! ( Empty( oEntity ) )
			If oEntity:GetType() == FACT
				cTitle := STR0019 //"Fato "
			EndIf
			
			cTitle += oEntity:GetTitle()	
			FreeObj( oEntity )
		EndIf 
	EndIf	
Return cTitle

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTimeDiff
Calcula a diferença entre duas datas informadas. 

@param dFromDate, data, Data Inicial 
@param cFromTime, caracter, Hora Inicial 
@param dToDate, data, Data Final 
@param cToTime, data, Hora Final
@param lTitle, lógico, Identifica se retorna a descrição do intervalo ou o número de minutos transcorridos.
@return xTimeDiff, Número de minutos ou descrição do período transcorrido. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXTimeDiff( dFromDate, cFromTime, dToDate, cToTime, lTitle ) 
	Local xTimeDiff 		:= ""
	Local nMinute			:= 0
	Local nSecond			:= 0
	Local nDayToMinute		:= 0
	Local nHourToMinute		:= 0
	Local nTimeInMinute		:= 0
	Local nMinuteToHour		:= 0
	Local nSecondToInt		:= 0
	
	Default dFromDate	:= Date()
	Default dToDate		:= Date()
	Default cToTime		:= Time()
	Default cFromTime	:= Time()
	Default lTitle		:= .T. 

 	//-------------------------------------------------------------------
	// Considera o dia e hora atual para cálculo de período em aberto.  
	//------------------------------------------------------------------- 
	dToDate	:= If( Empty( dToDate ), Date(), dToDate )
	cToTime	:= If( Empty( cToTime ), Time(), cToTime )

 	//-------------------------------------------------------------------
	// Converte dias e horas para minutos e segundos.  
	//------------------------------------------------------------------- 
	nDayToMinute  	:= ( nBIVal( dToDate - dFromDate ) ) * 1440 
	nHourToMinute 	:= ( nBIVal( Substr( cToTime, 1, 2 ) ) - nBIVal( Substr( cFromTime, 1, 2 ) ) ) * 60
	nMinute       	:= ( nBIVal( Substr( cToTime, 4, 2 ) ) - nBIVal( Substr( cFromTime, 4, 2 ) ) )  
	nSecond			:= ( nBIVal( Substr( cToTime, 7, 2 ) ) - nBIVal( Substr( cFromTime, 7, 2 ) ) )
	nTimeInMinute	:= ( nDayToMinute + nHourToMinute + nMinute ) 

	If ! ( lTitle ) 
		//-------------------------------------------------------------------
		// Transforma o segundo em fração de minuto. 
		//------------------------------------------------------------------- 
		If ! ( nSecond == 0 )
			nSecondToInt := ( nSecond / 60 )
		EndIf 
		
		//-------------------------------------------------------------------
		// Calcula o tempo total. 
		//------------------------------------------------------------------- 	
		xTimeDiff := Round( nTimeInMinute + nSecondToInt, 2 )
	Else
		//-------------------------------------------------------------------
		// Calcula a quantidade minutos quando segundos são negativos. 
		//------------------------------------------------------------------- 
		If ( nSecond < 0 ) 
			nTimeInMinute := nTimeInMinute - 1
			nSecond		:= 60 + nSecond
		EndIf 

		//-------------------------------------------------------------------
		// Expressa a diferença em horas, minutos e segundos. 
		//------------------------------------------------------------------- 	
		If ( nTimeInMinute == 0 )
			xTimeDiff := cBIStr( nSecond ) + "s"
		Else	
			If ( nTimeInMinute < 60 ) 
				xTimeDiff := cBIStr( nTimeInMinute ) + "m" + cBIStr( nSecond ) + "s"
			Else
				nMinuteToHour := Int( nTimeInMinute / 60 )
				xTimeDiff 		:= cBIStr( nMinuteToHour ) + "h" + cBIStr( Mod( nTimeInMinute, 60 ) ) + "m" + cBIStr( nSecond ) + "s"	
			EndIf 
		EndIf
	EndIf 	
Return xTimeDiff

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSetLog
Permite realizar a inserção de um registro no log. 

@param nStatus, numérico, Status de extração. 
@param cEntity, caracter, Entidade que está sendo extraída. 	
@param dFrom, data, Data inicial da extração de uma entidade.  
@param dTo, data, Data final da extração de uma entidade.  
@param cProfile, caracter, Perfil de extração em uso em um processo. 
@param nRecord, numérico, Número de registros extraídos em uma entidade. 
@param cContent, caracter,Log adicional relacionado com uma entidade. 
@param cApp, caracter, Apps. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Function BIXSetLog( nStatus, cEntity, dFrom, dTo, cProfile, nRecord, cContent, cApp )
	Local aEntity     := {} 
	Local cProcess    := ""
	Local cTo         := ""
	Local cSubject    := ""
	Local cBody       := ""
	Local cAttachment := ""
	Local cWhen       := ""
	Local bErro       := ErrorBlock( { || } )  
	Local lLog        := .F.

	Default cEntity  := "" 
	Default cContent := "" 
	Default cProfile := ""
	Default cApp     := ""
	Default nRecord  := 0
	Default nStatus  := LOG_RUNNING 
	Default dFrom    := nil 
	Default dTo      := nil 

	BIXOpenLog() 
	
	BEGIN SEQUENCE
		//-------------------------------------------------------------------
		// Define o momento da ocorrência. 
		//-------------------------------------------------------------------  
		cWhen := + "[" + cBIStr( Date() ) + "][" + Time() + "]" 	
		
		//-------------------------------------------------------------------
		// Define o ID do processo. 
		//-------------------------------------------------------------------  	
		cProcess	:= BIXLogID()
	
		//-------------------------------------------------------------------
		// Identifica o tipo de log. 
		//------------------------------------------------------------------- 
		If ( Empty( cEntity ) .Or. ( cEntity == "___" ) )
			lLog := HVY->( MSSeek( cProcess ) )
		
			//-------------------------------------------------------------------
			// Atualiza o log com informações de extração. 
			//------------------------------------------------------------------- 	
			If( RecLock( "HVY", ! lLog  ) )
				HVY->HVY_ID			:= cProcess
				HVY->HVY_EMPFIL 	:= cEmpAnt + "/" + cFilAnt
				HVY->HVY_STATUS 	:= nStatus
	
				//-------------------------------------------------------------------
				// Grava os campos que precisam de validação. 
				//-------------------------------------------------------------------
				If ! ( Empty( cProfile ) ) 			
					HVY->HVY_PROFIL	:= Upper( cProfile )
				EndIf 

				If ! ( Empty( cApp ) ) 			
					HVY->HVY_APP := Upper( cApp )
				EndIf 

				//-------------------------------------------------------------------
				// Grava o início e fim da extração. 
				//-------------------------------------------------------------------
				If ( nStatus == LOG_RUNNING  .Or. nStatus == LOG_DEBUG )
					//-------------------------------------------------------------------
					// Impede que a data e hora de início da extração seja atualizada. 
					//-------------------------------------------------------------------
					If ( Empty( HVY->HVY_STARTD ) .And. Empty( HVY->HVY_STARTH ) )
						HVY->HVY_STARTD	:= Date()
						HVY->HVY_STARTH	:= Time()
						HVY->HVY_EXEC	:= BIXGetRun()
					EndIf 
				Else
					//-------------------------------------------------------------------
					// Caso seja Status de licença loga as datas de início da extração.
					//-------------------------------------------------------------------
					If ( nStatus == LOG_LICENSE .Or. nStatus == LOG_LINK )
						HVY->HVY_STARTD	:= Date()
						HVY->HVY_STARTH	:= Time()
					EndIf
					
					HVY->HVY_FINISD	:= Date()
					HVY->HVY_FINISH	:= Time()

					//-------------------------------------------------------------------
					// Realiza a notificação por e-mail. 
					//-------------------------------------------------------------------
					If ( nStatus == LOG_FINISH )
						BIXManageMail( LOG_FINISH )	
					EndIf
					
					//-------------------------------------------------------------------
					// Encerra o log e limpa o identificador. 
					//-------------------------------------------------------------------
					__cLogID := nil
				EndIf 
				
				HVY->( MsUnlock() )
			EndIf 		
		Else
			lEntity 	:= HVZ->( MSSeek( cProcess + cEntity ) )
			
			//-------------------------------------------------------------------
			// Atualiza o log com informações da entidade. 
			//------------------------------------------------------------------- 
		 	If( RecLock( "HVZ", ! lEntity ) ) 		
				HVZ->HVZ_ID		:= cProcess
				HVZ->HVZ_ENTITY	:= cEntity
					
				//-------------------------------------------------------------------
				// Grava os campos que precisam de validação. 
				//-------------------------------------------------------------------
				If HVZ->HVZ_STATUS == 0 .Or. (HVZ->HVZ_STATUS == LOG_RUNNING .Or. HVZ->HVZ_STATUS == LOG_DEBUG)
					HVZ->HVZ_STATUS	:= nStatus
				EndIf
				
				If !( dFrom == nil ) 
					HVZ->HVZ_PERIOF	:= dFrom
				EndIf 
				
				If !( dTo == nil ) 
					HVZ->HVZ_PERIOT	:= dTo
				EndIf 			
				
				If !( nRecord == 0 )
					HVZ->HVZ_RECORD := nRecord
				EndIf
	  	
				//-------------------------------------------------------------------
				// Grava as mensagens de log. 
				//-------------------------------------------------------------------				
				If ! ( Empty( cContent ) )				
					If( nStatus == LOG_DEBUG )
						If ( BIXIsDebug() )
							HVZ->HVZ_MEMO := HVZ->HVZ_MEMO + "[DEBUG] " + cWhen + cContent + CRLF + CRLF
						EndIf				
					Else
						HVZ->HVZ_MEMO := HVZ->HVZ_MEMO + If( nStatus == LOG_ERROR, "[ERROR] ", "[INFO] " ) + cWhen + cContent + CRLF + CRLF
					EndIf
				Else
					If ( BIXIsDebug() )
						If ( Empty( HVZ->HVZ_MEMO ) )
							//-------------------------------------------------------------------
							// Recupera fonte do extrator. 
							//-------------------------------------------------------------------
							cSource := BIXSource( cEntity )

							If ! ( Empty( cSource ) )
								//-------------------------------------------------------------------
								// Recupera as informações do fonte. 
								//-------------------------------------------------------------------				
								aEntity := GetAPOInfo( AllTrim( cSource ) )

								If ! ( Empty( aEntity ) )
									//-------------------------------------------------------------------
									// Formata as informações do fonte. 
									//-------------------------------------------------------------------
									cContent += "[DEBUG] " + cWhen +  Upper( aEntity[1] ) + " " + cBIStr( aEntity[4] )	+ " " + cBIStr( aEntity[5] ) + CRLF + CRLF									
									
									//-------------------------------------------------------------------
									// Grava as informações dos fontes. 
									//-------------------------------------------------------------------		
									HVZ->HVZ_MEMO := HVZ->HVZ_MEMO + cContent									
								EndIf
							EndIf 
						EndIf 
					Endif 			
				EndIf	  	
			
				//-------------------------------------------------------------------
				// Grava o início e fim da extração. 
				//-------------------------------------------------------------------
				If ( nStatus == LOG_RUNNING  .Or. nStatus == LOG_DEBUG )
					//-------------------------------------------------------------------
					// Impede que a data e hora de início da extração seja atualizada.
					//-------------------------------------------------------------------
					If ( Empty( HVZ->HVZ_STARTD ) .And. Empty( HVZ->HVZ_STARTH ) )
						HVZ->HVZ_STARTD	:= Date()
						HVZ->HVZ_STARTH	:= Time()
					EndIf 
				Else
					If ( nStatus == LOG_UPDATED ) 
						HVZ->HVZ_STARTD	:= Date()
						HVZ->HVZ_STARTH	:= Time()				
					EndIf 				
				
					HVZ->HVZ_FINISD	:= Date()
					HVZ->HVZ_FINISH	:= Time()
					
					//-------------------------------------------------------------------
					// Realiza a notificação por e-mail. 
					//-------------------------------------------------------------------			
					If ( nStatus == LOG_ERROR ) 
						BIXManageMail( LOG_ERROR )				
					EndIf 
				EndIf 
				
				HVZ->( MsUnlock() )
			EndIf 
		EndIf 
	END SEQUENCE
	ErrorBlock(bErro)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogIntegrity
Permite realizar a inserção de um registro no log. 

@param cFact, caracter, Fato em processamento. 			
@param cLookup, caracter, Entidade na qual os dados estão sendo procurados. 	
@param aBK, caracter, Chave estrangeira do lookup.  		
@param cBranch, caracter, Filial do lookup	
@param aKey, caracter, Valor que está sendo procurado. 				

@author  Valdiney V GOMES
@since   19/01/2011
/*/
//-------------------------------------------------------------------
Function BIXLogIntegrity( cFact, cLookup, aBK, cBranch, aKey )
	Local lIntegrity := .F. 
	Local cProcess   := ""
	Local cBK        := ""
	Local cKey       := ""
	Local bErro      := ErrorBlock( { || } )  

	Default aKey    := {} 
	Default aValue  := {} 
	Default cFact   := "" 
	Default cLookup := "" 
	Default cBranch := "" 

	BIXOpenLog() 
	
	BEGIN SEQUENCE
		//-------------------------------------------------------------------
		// Define os tamanho e formato dos campos chave. 
		//-------------------------------------------------------------------  	
		cProcess := BIXLogID()
		cBranch  := Padr( cBranch, 12 )
		cBK      := Padr( BIXConcatWSep( "+", aBK ), 40 )
		cKey     := Padr( BIXConcatWSep( "", aKey ), 30 )

		//-------------------------------------------------------------------
		// Identifica a operação a ser realizada. 
		//------------------------------------------------------------------- 
		lIntegrity := HY5->( MSSeek( cProcess + cFact + cLookup + cBK  + cBranch + cKey ) )

		//-------------------------------------------------------------------
		// Atualiza o log com informações da validação de integride. 
		//------------------------------------------------------------------- 	
		If( RecLock( "HY5", ! lIntegrity  ) )
			If ( ! lIntegrity )
				HY5->HY5_ID 	:= cProcess
				HY5->HY5_FACT 	:= cFact
				HY5->HY5_LOOKUP := cLookup
				HY5->HY5_BK 	:= cBK
				HY5->HY5_FILIAL	:= cBranch			
				HY5->HY5_VALUE 	:= cKey
			EndIf
			
			HY5->( MsUnlock() )
		EndIf 
	END SEQUENCE
	ErrorBlock(bErro)
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogStatus
Retorna o status de uma entidade dentro de uma execução do schedule. 
O status da extração de uma entidade é definido pelo menor status en
contrado para entidades igual em qualquer processo dentro de uma ext
ração.

@param cEntity, caracter, Entidade em extração. 
@return nStatus, numérico, Status da extração. 

@author  Valdiney V GOMES
@since   25/03/2015
/*/
//-------------------------------------------------------------------
Function BIXLogStatus( cEntity )
	Local aAreaProcess	:= HVY->( GetArea() )
	Local aAreaEntity	:= HVZ->( GetArea() )
	Local cRun			:= ""
	Local nStatus 		:= LOG_FINISH
	Local cTaskID		:= BIXTaskID()

	Default cEntity 	:= ""
 	
 	BIXOpenLog() 
 	
 	//-------------------------------------------------------------------
	// Recupera o processo em execução. 
	//-------------------------------------------------------------------	
 	cRun := BIXGetRun( cTaskID )
 	
	//-------------------------------------------------------------------
	// Identifica se é um processo ou entidade. 
	//------------------------------------------------------------------- 
	If ( Empty( cEntity ) )
		//-------------------------------------------------------------------
		// Identifica se um processo está em execução na extração corrente. 
		//------------------------------------------------------------------- 
		HVY->( DBSetOrder(2) )

		If( HVY->( MSSeek( cRun ) ) )
			While ( ! HVY->( Eof() ) .And. HVY->HVY_EXEC == cRun ) 
				If ( HVY->HVY_STATUS == LOG_ERROR .Or. HVY->HVY_STATUS == LOG_RUNNING )
					nStatus := HVY->HVY_STATUS
					Exit 
				EndIf 
			
				HVY->( DBSkip() )
			EndDo 
		EndIf 
	Else
		//-------------------------------------------------------------------
		// Indentifica se alguma entidade está em execução na extração corrente. 
		//------------------------------------------------------------------- 
		HVY->( DBSetOrder(2) )
		
		If( HVY->( MSSeek( cRun ) ) )
			While ( ! HVY->( Eof() ) .And. HVY->HVY_EXEC == cRun ) 	
				If( HVZ->( MSSeek( HVY->HVY_ID + cEntity ) ) )
					While ( ! HVZ->( Eof() ) .And. HVZ->HVZ_ID == HVY->HVY_ID .And. HVZ->HVZ_ENTITY == cEntity ) 	
						If ( HVZ->HVZ_STATUS == LOG_ERROR .Or. HVZ->HVZ_STATUS == LOG_RUNNING )
							nStatus := HVZ->HVZ_STATUS
							Exit 
						EndIf 
					
						HVZ->( DBSkip() )
					EndDo 	
				EndIf 	
				
				HVY->( DBSkip() )
			EndDo 
		EndIf 	
	EndIf 	
	
	RestArea( aAreaProcess )
	RestArea( aAreaEntity )	
Return nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXClearLog
Remove registros antigos do arquivo de log. 

@author  Valdiney V GOMES
@since   01/10/2014
/*/
//-------------------------------------------------------------------
Function BIXClearLog() 
	Local nProcess  := HVY->( LastRec() ) 
	Local nLimit    := BIXGetConfig( "CONFIG_RECORD", "N", 200 )
	Local nPeriodo  := BIXGetConfig( "CONFIG_PERIOD", "N", 30 )
	Local nRecord   := 0	
	Local nRemove   := 0
	Local nActive   := 0
	Local nTimeDiff := 0

	BIXOpenLog() 

	If !( HVY->( Eof() ) )
		HVY->( DBSetOrder( 1 ) )
		HVY->( DBGoTop() )
		
		//-------------------------------------------------------------------
		// Identifica o range que precisa se removido. 
		//-------------------------------------------------------------------	
		nActive := ( nProcess - HVY->( Recno() ) )
		nRemove := ( nActive - nLimit )
		
		//-------------------------------------------------------------------
		// Varredura em todos os processos. Rotina criada para cancelar extrações obsoletas.
		//-------------------------------------------------------------------
		For nRecord := 0 To ( nActive )
			//-------------------------------------------------------------------
			// Verifica se o processo está marcado como em andamento.
			//-------------------------------------------------------------------
			If ( HVY->HVY_STATUS == LOG_RUNNING )
				//-------------------------------------------------------------------
				// Verifica se o tempo que o processo está em andamento é maior igual do que período marcado nas configurações.
				//-------------------------------------------------------------------
				nTimeDiff := ( BIXTimeDiff( HVY->HVY_STARTD, HVY->HVY_STARTH, , , .F. ) ) / 1440
				
				If ( nTimeDiff >= nPeriodo )
					//-------------------------------------------------------------------
					// Efetua o controle do envio por e-mail.
					//-------------------------------------------------------------------	
					If ( TCCanOpen( "HVY") )
						If ! ( TCSQLExec( "UPDATE HVY SET HVY_STATUS =" + cBIStr( LOG_CANCEL ) + " , HVY_FINISD = '" + DToS( Date() ) + "' , HVY_FINISH = '" + Time() + "' WHERE HVY_ID = '" + HVY->HVY_ID + "'" ) < 0 )
							TCSQLExec( "UPDATE HVZ SET HVZ_STATUS =" + cBIStr( LOG_CANCEL ) + " , HVZ_FINISD = '" + DToS( Date() ) + "' , HVZ_FINISH = '" + Time() + "' WHERE HVZ_ID = '" + HVY->HVY_ID + "'" )
						Endif 
					EndIf
					
					//-------------------------------------------------------------------
					// Envia o alerta por e-mail.
					//-------------------------------------------------------------------
					BIXManageMail( LOG_CANCEL )						
				EndIf				
			EndIf	
						
			HVY->( DBSkip() )
		Next nRecord

		nRecord := 0
		HVY->( DBGoTop() )
				
		//-------------------------------------------------------------------
		// Verifica se é necessário realizar a limpeza. 
		//-------------------------------------------------------------------	
		If ( nRemove > 0 )  
			For nRecord := 0 To ( nRemove )		
				If ( TCCanOpen( "HVY") )
					If ! ( TCSQLExec( "DELETE FROM HVY WHERE HVY_ID ='" + HVY->HVY_ID + "'" ) < 0 ) 
						If ! ( TCSQLExec( "DELETE FROM HVZ WHERE HVZ_ID ='" + HVY->HVY_ID + "'" ) < 0 )
							TCSQLExec( "DELETE FROM HY5 WHERE HY5_ID ='" + HVY->HVY_ID + "'AND HY5_FACT ='" + HVZ->HVZ_ENTITY + "'" )	
						EndIf
					Endif 
				EndIf
					
				HVY->( DBSkip() )
			Next nRecord
		EndIf		
	EndIf  
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXIsDebug
Verifica se o modo Debug está Configurado (Modo debug de Log de Extração). 

@return lDebug, boolean, retorna se modo debug está ativo.

@author  Helio Leal
@since   01/08/2017
/*/
//-------------------------------------------------------------------
Function BIXIsDebug()
 	//-------------------------------------------------------------------
 	// Verifica se o modo debug já foi verificado no Cache.
 	//-------------------------------------------------------------------
	If ( __lDebug == Nil )
		__lDebug := BIXGetConfig( "CONFIG_DEBUG"  , "L" )
	EndIf
return __lDebug