#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROFILE.CH"

Static __aTable
Static __aApp

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOpenProfile
Define a estrutura da tabela do perfil de extração e realiza a criação,
abertura e ajustes na estrutura do arquivo.

@author  Valdiney V GOMES
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXOpenProfile()
	Local oProfile 	:= nil
	Local oInterval := nil
	Local nTable	:= 1
	Local lMigrate	:= .F.

	If ( __aTable == nil )
		//-------------------------------------------------------------------
		// Lista de tabelas do perfil de extração. 
		//------------------------------------------------------------------- 
		__aTable	:= {}

		//-------------------------------------------------------------------
		// Cria a tabela de períodos. 
		//-------------------------------------------------------------------  
		oInterval	:= TBITable():New( "HRB", "HRB" ) 
	
		oInterval:addField( TBIField():New( "HRB_PROFIL" , "C", 06, 0 ))		
		oInterval:addField( TBIField():New( "HRB_FACT" 	 , "C", 03, 0 ))		
		oInterval:addField( TBIField():New( "HRB_INITIA" , "C", 50, 0 ))		
		oInterval:addField( TBIField():New( "HRB_FINAL"	 , "C", 50, 0))		
		oInterval:addIndex( TBIIndex():New( "HRB1", { "HRB_PROFIL", "HRB_FACT" }, .F.) )  
	
		aAdd( __aTable, oInterval )
	
		//-------------------------------------------------------------------
		// Cria a tabela do profile. 
		//------------------------------------------------------------------- 
		oProfile	:= TBITable():New( "HRC", "HRC" ) 
	
		oProfile:addField( TBIField():New( "HRC_ID" 	, "C", 06, 0 ))		
		oProfile:addField( TBIField():New( "HRC_TITLE" 	, "C", 50, 0 ))		
		oProfile:addField( TBIField():New( "HRC_AREA" 	, "M", 10, 0 ))		
		oProfile:addField( TBIField():New( "HRC_FACT"	, "M", 10, 0))	
		oProfile:addField( TBIField():New( "HRC_DIMEN"	, "M", 10, 0))
		oProfile:addIndex( TBIIndex():New( "HRC1", { "HRC_ID" }, .F.) )   
	    
		//-------------------------------------------------------------------
		// Identifica se deve realizar migração de dados. 
		//------------------------------------------------------------------- 
		lMigrate :=  ! ( oProfile:lExists() )			    
	    
		aAdd( __aTable, oProfile )
		
	EndIf 

	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( __aTable ) 
		If ! ( __aTable[nTable]:lIsOpen( ) )
			__aTable[nTable]:ChkStruct( .F., .F., .F., .T. )
			__aTable[nTable]:lOpen( )
		EndIf
	Next nTable  
Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProfile
Monta o browse para manutenção do perfil de extração.

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Function BIXProfile()
	Local oBrowse	:= nil
	Local oColumn	:= nil
	Local oTopology := nil
	
	BIXOpenProfile()

	//---------------------------------------------------------------
	// Se a tabela de histórico não tiver sido criada, a cria.
	//---------------------------------------------------------------
	BIXOpenHistory() 

	//-------------------------------------------------------------------
	// Recupera a lista de apps registradas. 
	//------------------------------------------------------------------- 
	If ( __aApp == nil )
		FWMsgRun(, {|| oTopology	:= BIXTopology():New( ), __aApp	:= oTopology:GetTopology( ), FreeObj( oTopology )}, "", STR0069) //"Efetuando a carga da Modelagem..."
	EndIf
	
	//-------------------------------------------------------------------
	// Monta a lista de perfis de extração. 
	//-------------------------------------------------------------------
  	DEFINE FWMBROWSE oBrowse ALIAS "HRC"
		oBrowse:SetDescription( STR0001 ) //"Cadastro de Perfis de Extracao"
		oBrowse:DisableDetails()
		
		ADD COLUMN oColumn DATA {|| HRC_ID } 		TITLE STR0002 OF oBrowse //"Perfil"
		ADD COLUMN oColumn DATA {|| HRC_TITLE } 	TITLE STR0003 OF oBrowse //"Descrição"
	ACTIVATE FWBROWSE oBrowse  

Return NIL
       

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProfile
Define as opções disponíveis no menu do perfil de extração.

@return aRotina, Rotinas que serão exibidas no menu. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.BIXProfile" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.BIXProfile" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.BIXProfile" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.BIXProfile" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0041 ACTION "BIXConfigExec"	 OPERATION 6 ACCESS 0 //"Executar Perfil"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProfile
Define o modelo de dados do perfil de extração.
  
@return oModel, Modelo de dados do perfil de extração. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel			:= nil
	Local oMainStruct 		:= nil
	Local oAppStruct		:= nil
	Local oFactStruct		:= nil
	Local oDimensionStruct	:= nil
       
	oModel	:= MPFormModel():New( "BIXPROFILE", /*bPreValidacao*/, /*bPosValidacao*/, { | oModel | BIXCommitProfile( oModel ) } /*bCommit*/, /*bCancel*/ )
       
	//-------------------------------------------------------------------
	// Estrutura principal. 
	//-------------------------------------------------------------------
	oMainStruct := FWFormModelStruct():New()
	oMainStruct:AddTable("HRC",{"HRC_ID"}, STR0002) //"Perfil"             
	oMainStruct:AddIndex(1,"01","HRC_ID", STR0008 , "" , "" , .T. ) //"Código"
	oMainStruct:AddField(STR0008, STR0008, "HRC_ID"    , "C" ,06 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ , .T./*lObrigat*/, /*bInit*/, /*lKey*/, .T./*lNoUpd*/,/*lVirtual*/) //"Código"
	oMainStruct:AddField(STR0003, STR0003, "HRC_TITLE" 	, "C" ,50 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ , .T./*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/, /*lVirtual*/) //"Descrição"
	oMainStruct:SetProperty( "HRC_ID", MODEL_FIELD_VALID, FwBuildFeature(1,"Eval( {|x,y,z| ExistChav('HRC', x:GetValue('HRC_ID') ) },a,b,c )") )
	oMainStruct:Activate()

	//-------------------------------------------------------------------
	// Estrutura do grid de áreas. 
	//-------------------------------------------------------------------
	oAppStruct := FWFormModelStruct():New()
	oAppStruct:AddTable("AREA",{"AREA_ID"},"Apps") 			//"App"             
	oAppStruct:AddIndex(1,"01","AREA_ID","ID" , "" , "" , .T. ) //"ID"
	oAppStruct:AddField("", STR0010, "AREA_MARK"    	, "L" ,01 , 0 , {||.T.}/*bValid*/, /*bWhen*/, /*aValues*/ , /*lObrigat*/, /*bInit*/, /*lKey*/, /*lNoUpd*/,/*lVirtual*/) //"Extrair"
	oAppStruct:AddField("ID"		,"ID", "AREA_ID" 		, "C" ,03 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) 
	oAppStruct:AddField(STR0003, STR0003, "AREA_TITLE" 	, "C" ,40 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"Descrição"
	oAppStruct:Activate()

	//-------------------------------------------------------------------
	// Estrutura do grid de fatos. 
	//-------------------------------------------------------------------
	oFactStruct := FWFormModelStruct():New()
	oFactStruct:AddTable("FACT",{"FACT_TABLE"},STR0016) //"Fatos"
	oFactStruct:AddIndex(1,"01","FACT_TABLE", STR0011, "" , "" , .T. ) //"Tabela"
	oFactStruct:AddField("", STR0010, "FACT_MARK"    	, "L" ,01 , 0 , {||.T.}/*bValid*/, /*bWhen*/, /*aValues*/ , /*lObrigat*/, /*bInit*/, /*lKey*/, /*lNoUpd*/,/*lVirtual*/) //"Extrair"
	oFactStruct:AddField(STR0011, STR0011, "FACT_TABLE"   	, "C" ,03 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"Tabela"
	oFactStruct:AddField(STR0012, STR0012, "FACT_TITLE" 	, "C" ,60 , 0 , /*bValid*/,/*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"Fato" 
	oFactStruct:AddField(STR0013, STR0013, "FACT_FROM" 		, "C" ,50 , 0 , {|oModel, cId, xValue| BIXValidDate( oModel, cId, xValue ) } /*bValid*/, {|oModel, cId, xValue| oModel:GetValue("FACT_MARK") }/*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"De"
	oFactStruct:AddField(STR0014, STR0014, "FACT_TO" 		, "C" ,50 , 0 , {|oModel, cId, xValue| BIXValidDate( oModel, cId, xValue ) } /*bValid*/, {|oModel, cId, xValue| oModel:GetValue("FACT_MARK") }/*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"Até"
	oFactStruct:Activate()

	//-------------------------------------------------------------------
	// Estrutura do grid de dimensões. 
	//-------------------------------------------------------------------
	oDimensionStruct := FWFormModelStruct():New()
	oDimensionStruct:AddTable("DIMENSION",{"DIMENSION_TABLE"},STR0017) //"Dimensões"
	oDimensionStruct:AddIndex(1,"01","DIMENSION_TABLE", STR0011, "" , "" , .T. ) //"Tabela"
	oDimensionStruct:AddField("", STR0010, "DIMENSION_MARK"    , "L" ,01 , 0 , {||.T.}/*bValid*/, /*bWhen*/, /*aValues*/ , /*lObrigat*/, /*bInit*/, /*lKey*/, /*lNoUpd*/,/*lVirtual*/) //"Extrair"
	oDimensionStruct:AddField(STR0011, STR0011, "DIMENSION_TABLE"   , "C" ,03 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"Tabela"
	oDimensionStruct:AddField(STR0015, STR0015, "DIMENSION_TITLE"   , "C" ,40 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/,   /*lVirtual*/) //"Dimensão"
	oDimensionStruct:AddField(STR0039, STR0039, "DIMENSION_PROTHEUS", "C" ,03 , 0 , /*bValid*/, /*bWhen*/, /*aValues*/ ,/*lObrigat*/, /*bInit*/,/*lKey*/, /*lNoUpd*/, /*lVirtual*/) //"Entidade"
	oDimensionStruct:Activate()
 
	//-------------------------------------------------------------------
	// Estrutura do modelos de dados. 
	//-------------------------------------------------------------------
	oModel:AddFields( "MODEL_MAIN", /*cOwner*/, oMainStruct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
	oModel:AddGrid( "MODEL_AREA"		, "MODEL_MAIN", oAppStruct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, {||{}}/*bLoad*/ )
	oModel:AddGrid( "MODEL_FACT"		, "MODEL_MAIN", oFactStruct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, { |oModel, nLine| BIXValidFactPeriod( oModel ) } /*bPosVal*/, {||{}}/*bLoad*/)
	oModel:AddGrid( "MODEL_DIMENSION"	, "MODEL_MAIN", oDimensionStruct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, {||{}}/*bLoad*/ )

    //-------------------------------------------------------------------
	// Chave primária da tabela principal do modelo. 
	//-------------------------------------------------------------------
	oModel:SetPrimaryKey( { "HRC_ID" } ) 
	
	//-------------------------------------------------------------------
	// Descrição dos modelos de dados. 
	//-------------------------------------------------------------------	
	oModel:SetDescription( STR0018 ) //"Perfil de Extração"
	oModel:GetModel( "MODEL_AREA" ):SetDescription( STR0019 ) //"Area"
	oModel:GetModel( "MODEL_FACT" ):SetDescription( STR0012 ) //"Fato"
	oModel:GetModel( "MODEL_DIMENSION" ):SetDescription( STR0015 ) //"Dimensão"   
     
	//-------------------------------------------------------------------
	// Bloqueio de inclusão nos grids. 
	//-------------------------------------------------------------------
	oModel:GetModel( "MODEL_AREA" ):SetNoInsertLine() 
	oModel:GetModel( "MODEL_FACT" ):SetNoInsertLine()
	oModel:GetModel( "MODEL_DIMENSION" ):SetNoInsertLine()

	//-------------------------------------------------------------------
	// Bloqueio de deleção nos grids. 
	//-------------------------------------------------------------------	
	oModel:GetModel( "MODEL_AREA" ):SetNoDeleteLine() 
	oModel:GetModel( "MODEL_FACT" ):SetNoDeleteLine()
	oModel:GetModel( "MODEL_DIMENSION" ):SetNoDeleteLine()

	//-------------------------------------------------------------------
	// Carga dos grids na ativação do modelo de dados. 
	//-------------------------------------------------------------------	
	oModel:SetActivate( { |oModel| BIXLoadApp( oModel ),  BIXLoadFact( oModel ), BIXLoadDimension( oModel ), oModel:lModify := .F. } )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProfile
Define a interface do perfil de extração.
  
@return oView, Interface do perfil de extração. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView 				:= nil
	Local oModel 				:= nil
	Local oMainStruct	   		:= nil
	Local oAppStruct 	   		:= nil
	Local oFactStruct	   		:= nil
	Local oDimensionStruct		:= nil
	Local oViewMainStruct		:= nil
	Local oViewAppStruct		:= nil
	Local oViewFactStruct		:= nil
	Local oViewDimensionStruct	:= nil
	Local oMark					:= nil

	oView 				:= FWFormView():New()
	oModel 				:= FWLoadModel( "BIXPROFILE" )
	oMainStruct	   		:= oModel:GetModel("MODEL_MAIN"):GetStruct()
	oAppStruct 	   		:= oModel:GetModel("MODEL_AREA"):GetStruct()
	oFactStruct	   		:= oModel:GetModel("MODEL_FACT"):GetStruct()
	oDimensionStruct	:= oModel:GetModel("MODEL_DIMENSION"):GetStruct()

	//-------------------------------------------------------------------
	// Estrutura principal. 
	//-------------------------------------------------------------------
	oViewMainStruct	:= FWFormViewStruct():New()
	oViewMainStruct:AddField("HRC_ID"  		,"01",oMainStruct:GetProperty("HRC_ID"  	,MODEL_FIELD_TITULO),oMainStruct:GetProperty("HRC_ID" 		,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
	oViewMainStruct:AddField("HRC_TITLE"    ,"02",oMainStruct:GetProperty("HRC_TITLE"   ,MODEL_FIELD_TITULO),oMainStruct:GetProperty("HRC_TITLE" 	,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
	oViewMainStruct:Activate()       
      
	//-------------------------------------------------------------------
	// Estrutura do grid de áreas. 
	//-------------------------------------------------------------------
	oViewAppStruct	:= FWFormViewStruct():New()
	oViewAppStruct:AddField("AREA_MARK"  	,"01",oAppStruct:GetProperty("AREA_MARK"  	,MODEL_FIELD_TITULO),oAppStruct:GetProperty("AREA_MARK" ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"L" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
	oViewAppStruct:AddField("AREA_ID"    	,"02",oAppStruct:GetProperty("AREA_ID"		,MODEL_FIELD_TITULO),oAppStruct:GetProperty("AREA_ID"     ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
	oViewAppStruct:AddField("AREA_TITLE"   ,"03",oAppStruct:GetProperty("AREA_TITLE"	,MODEL_FIELD_TITULO),oAppStruct:GetProperty("AREA_TITLE"   ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
	oViewAppStruct:Activate()    
	
	//-------------------------------------------------------------------
	// Estrutura do grid de fatos. 
	//-------------------------------------------------------------------	   
	oViewFactStruct	:= FWFormViewStruct():New()
	oViewFactStruct:AddField("FACT_MARK"   	,"01",oFactStruct:GetProperty("FACT_MARK"	,MODEL_FIELD_TITULO),oFactStruct:GetProperty("FACT_MARK"  ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"L" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
   	oViewFactStruct:AddField("FACT_TABLE"	,"02",oFactStruct:GetProperty("FACT_TABLE"	,MODEL_FIELD_TITULO),oFactStruct:GetProperty("FACT_TABLE"  ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
   	oViewFactStruct:AddField("FACT_TITLE"	,"03",oFactStruct:GetProperty("FACT_TITLE"	,MODEL_FIELD_TITULO),oFactStruct:GetProperty("FACT_TITLE"    ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
  	oViewFactStruct:AddField("FACT_FROM"   	,"04",oFactStruct:GetProperty("FACT_FROM"	,MODEL_FIELD_TITULO),oFactStruct:GetProperty("FACT_FROM"  ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/, /*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
  	oViewFactStruct:AddField("FACT_TO"      ,"05",oFactStruct:GetProperty("FACT_TO"		,MODEL_FIELD_TITULO),oFactStruct:GetProperty("FACT_TO"     ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/, /*cLookUp*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
	oViewFactStruct:Activate()
	             
	//-------------------------------------------------------------------
	// Estrutura do grid de dimensões. 
	//-------------------------------------------------------------------	      
	oViewDimensionStruct:= FWFormViewStruct():New()
	oViewDimensionStruct:AddField("DIMENSION_MARK"  	,"01",oDimensionStruct:GetProperty("DIMENSION_MARK"    ,MODEL_FIELD_TITULO),oDimensionStruct:GetProperty("DIMENSION_MARK"    ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"L" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
   	oViewDimensionStruct:AddField("DIMENSION_TABLE"		,"02",oDimensionStruct:GetProperty("DIMENSION_TABLE"    ,MODEL_FIELD_TITULO),oDimensionStruct:GetProperty("DIMENSION_TABLE"    ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
   	oViewDimensionStruct:AddField("DIMENSION_TITLE" 	,"03",oDimensionStruct:GetProperty("DIMENSION_TITLE"  ,MODEL_FIELD_TITULO),oDimensionStruct:GetProperty("DIMENSION_TITLE"  ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)
   	oViewDimensionStruct:AddField("DIMENSION_PROTHEUS"	,"04",oDimensionStruct:GetProperty("DIMENSION_PROTHEUS"  ,MODEL_FIELD_TITULO),oDimensionStruct:GetProperty("DIMENSION_TITLE"  ,MODEL_FIELD_TOOLTIP), /*aHelp*/ ,"C" ,/*cPicture*/,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/)

   	
	oViewDimensionStruct:Activate() 

	//-------------------------------------------------------------------
	// Modelo utilizado pela camada de visualização. 
	//-------------------------------------------------------------------		 	 
	oView:SetModel( oModel )

	//-------------------------------------------------------------------
	// Estrutura da camada de visualização. 
	//------------------------------------------------------------------
	oView:AddField( "VIEW_MAIN"		, oViewMainStruct	   	, "MODEL_MAIN" )
	oView:AddGrid( "VIEW_AREA"		, oViewAppStruct		, "MODEL_AREA" )  
	oView:AddGrid( "VIEW_FACT"		, oViewFactStruct		, "MODEL_FACT" )
	oView:AddGrid( "VIEW_DIMENSION"	, oViewDimensionStruct	, "MODEL_DIMENSION" )
	
	//-------------------------------------------------------------------
	// Definição de uma tela de Marcar Tudo
	//------------------------------------------------------------------
    oView:AddOtherObject("MARK", {|oMark| BIXAppMark( oMark, oView )})    

	//-------------------------------------------------------------------
	// Definição da tela para a disposição dos componentes. 
	//-------------------------------------------------------------------
	oView:CreateHorizontalBox( "SUPERIOR", 15 )
	oView:CreateHorizontalBox( "INFERIOR", 85 )
	oView:CreateVerticalBox( "INFERIOR_ESQUERDO",  25, "INFERIOR" )
	oView:CreateVerticalBox( "INFERIOR_CENTRAL" ,  50, "INFERIOR" )
	oView:CreateVerticalBox( "INFERIOR_DIREITO" ,  25, "INFERIOR" )
	oView:CreateHorizontalBox( "INF_DIREITO1", 96, "INFERIOR_DIREITO" )
	oView:CreateHorizontalBox( "INF_CENTRAL1", 96, "INFERIOR_CENTRAL" )
	oView:CreateHorizontalBox( "INF_CENTRAL2", 04, "INFERIOR_CENTRAL" )
	oView:CreateHorizontalBox( "INF_ESQUERDO1", 96, "INFERIOR_ESQUERDO" )
	oView:CreateHorizontalBox( "INF_ESQUERDO2", 04, "INFERIOR_ESQUERDO" )

	//-------------------------------------------------------------------
	// Posicionamento dos componentes em tela.
	//-------------------------------------------------------------------
	oView:SetOwnerView( "VIEW_MAIN"		, "SUPERIOR" )
	oView:SetOwnerView( "VIEW_AREA"		, "INF_ESQUERDO1" )
	oView:SetOwnerView( "VIEW_FACT"		, "INF_CENTRAL1" )
	oView:SetOwnerView( "VIEW_DIMENSION", "INF_DIREITO1" )
	oView:SetOwnerView( "MARK"			, "INF_ESQUERDO2" )

	//-------------------------------------------------------------------
	// Títulos das sessões. 
	//-------------------------------------------------------------------	
	oView:EnableTitleView("VIEW_AREA"		, STR0009 ) //"Áreas"
	oView:EnableTitleView("VIEW_FACT"		, STR0016 )	//"Fatos"
	oView:EnableTitleView("VIEW_DIMENSION"	, STR0017 ) //"Dimensões"

	//-------------------------------------------------------------------
	// Ação do combo extrair. 
	//-------------------------------------------------------------------   
    oView:SetFieldAction( "AREA_MARK"  , { |oView, cIDView, cField, xValue| BIXAppAction( oView, cIDView, cField, xValue ) } )
    oView:SetFieldAction( "FACT_MARK"  , { |oView, cIDView, cField, xValue| BIXFactAction( oView, cIDView, cField, xValue ) } )
  
	//-------------------------------------------------------------------
	// Habilita a exibição do novo componente de grid. 
	//-------------------------------------------------------------------       
    oView:SetViewProperty( "VIEW_AREA"		, "ENABLENEWGRID" )     
    oView:SetViewProperty( "VIEW_FACT"		, "ENABLENEWGRID" )
    oView:SetViewProperty( "VIEW_DIMENSION"	, "ENABLENEWGRID" )

	//-------------------------------------------------------------------
	// Habilita a pesquisa no grid. 
	//-------------------------------------------------------------------         
 	oView:SetViewProperty( "VIEW_AREA"		, "GRIDSEEK" )     
    oView:SetViewProperty( "VIEW_FACT"		, "GRIDSEEK" )
    oView:SetViewProperty( "VIEW_DIMENSION"	, "GRIDSEEK" ) 
    
 	//-------------------------------------------------------------------
	// Ação do botão confirmar. 
	//-------------------------------------------------------------------    
    oView:SetCloseOnOk( { || .T. } )  
Return oView                                                 
          
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadApp
Carrega o conteúdo da lista de áreas com base na relação definida 
no fonte BIXModelagem. 

@param oModel, object, Objeto do modelo de dados do perfil de extração. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXLoadApp( oModel )    
	Local oTopology		:= nil 
	Local oModelApp		:= nil
	Local aApp	 		:= {}
	Local aMarkedApp	:= {}
	Local nApp			:= 0  
	Local nOperation	:= 0
	Local lMarked		:= .T. 	

	Default oModel		:= nil

	oModelApp	:= oModel:GetModel("MODEL_AREA")
	nOperation	:= oModel:GetOperation() 

	//-------------------------------------------------------------------
	// Recupera a lista de apps registrados. 
	//------------------------------------------------------------------- 	
	oTopology 	:= BIXTopology():New( )
	aApp 		:= oTopology:ListEntity( APP )
	FreeObj( oTopology )

	//-------------------------------------------------------------------
	// Ordena por ID. 
	//-------------------------------------------------------------------       
	aSort( aApp,,, { |x,y| nBIVal( x[1] ) < nBIVal( y[1] ) } )  
       
    //-------------------------------------------------------------------
	// Recupera os dados da área do perfil. 
	//-------------------------------------------------------------------  
	If ! ( nOperation == MODEL_OPERATION_INSERT ) 
		aMarkedApp := aBIToken( HRC->HRC_AREA, "|", .F. )
	EndIf 

	//-------------------------------------------------------------------
	// Preenche o grid de áreas. 
	//-------------------------------------------------------------------
	For nApp := 1 To Len( aApp )  
		//--------------------------------------------------------------
		// Carrega a lista de áreas, desconsiderando PCO (descontinuado)
		//--------------------------------------------------------------
		If aApp[nApp][1] != PCO
			If ! ( nApp == 1 )
				oModelApp:AddLine(.T.)    
				oModelApp:GoLine( oModelApp:Length() ) 
			EndIf
				
			If !( nOperation == MODEL_OPERATION_INSERT ) 		
		 		lMarked := !( aScan( aMarkedApp, {|x| x == aApp[nApp][1] } ) == 0 )
		 	EndIf   	
	 		 
	 		If !( nOperation == MODEL_OPERATION_DELETE )  
	 			oModelApp:LoadValue( "AREA_MARK"  	, lMarked )  
				oModelApp:LoadValue( "AREA_ID"	   	, aApp[nApp][1] )
				oModelApp:LoadValue( "AREA_TITLE"	, aApp[nApp][2] )    
	 		Else
	 			oModelApp:ForceValue( "AREA_MARK"  , lMarked )  
				oModelApp:ForceValue( "AREA_ID"	, aApp[nApp][1] )
				oModelApp:ForceValue( "AREA_TITLE"	, aApp[nApp][2] )  			
	 		EndIf
	 	EndIf  				                                     		  
	Next nApp 
	
    //-------------------------------------------------------------------
	// Restaura propriedades do modelo. 
	//------------------------------------------------------------------- 	
	oModelApp:GoLine(1)
Return .T.  
        
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadFact
Carrega o conteúdo da lista de fatos com base na relação definida 
no fonte BIXModelagem. 

@param oModel, Objeto do modelo de dados do perfil de extração. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXLoadFact( oModel )  
	Local oModelFact	:= nil 
	Local aFact 		:= {}
	Local aMarkedFacts	:= {}  
	Local cFact			:= ""  
	Local cFrom			:= ""
	Local cTo	      	:= ""
	Local nFact			:= 0
	Local nOperation	:= 0
	Local nAt			:= 0
	Local lMarked		:= .T.  
	Local lInsert		:= .F. 

	Default oModel		:= nil	
	
	oModelFact	:= oModel:GetModel("MODEL_FACT")
	nOperation	:= oModel:GetOperation()
	
 	//-------------------------------------------------------------------
	// Recupera a lista de fatos registradas. 
	//------------------------------------------------------------------- 	
	oTopology 	:= BIXTopology():New( )
	aFact 		:= oTopology:ListEntity( FACT )
	FreeObj( oTopology )
 
 	//-------------------------------------------------------------------
	// Ordena por descrição. 
	//-------------------------------------------------------------------            
	aSort( aFact,,, {|x,y| AllTrim( Upper(x[2]) ) < AllTrim( Upper(y[2]) ) }) 
  
    //-------------------------------------------------------------------
	// Recupera os dados da fato do perfil. 
	//-------------------------------------------------------------------  
	If ! ( nOperation == MODEL_OPERATION_INSERT )  
		cFact	:= HRC->HRC_FACT  
	EndIf 
            
 	//-------------------------------------------------------------------
	// Recupera todos as fatos selecionados. 
	//-------------------------------------------------------------------    
	aMarkedFacts := aBIToken( cFact, "|" )
   
	//-------------------------------------------------------------------
	// Preenche o grid de fatos. 
	//-------------------------------------------------------------------
	For nFact := 1 To Len( aFact )  
		If ! ( nFact == 1 )
			oModelFact:AddLine(.T.) 
			oModelFact:GoLine( oModelFact:Length() )
		EndIf   
		
  		//-------------------------------------------------------------------
		// Verifica se a fato deve ser exibida selecionada.   
		//-------------------------------------------------------------------
		If !( nOperation == MODEL_OPERATION_INSERT ) 
	 		lMarked := ( AllTrim( aFact[nFact][1] ) $ cFact )
	 	EndIf  
	   	 
	  	cFrom 	:= ""
	 	cTo 	:= ""
	   			 	                                                	 	   
	 	If ( lMarked )      
	 		nAt := aScan( aMarkedFacts, {|x| aFact[nFact][1] $ x } )

	 		If ( nAt > 0 )
 				//-------------------------------------------------------------------
				// Recupera o intervalo da tabela adicional. 
				//------------------------------------------------------------------- 
 				If ( HRB->( DBSeek( oModel:GetValue( "MODEL_MAIN", "HRC_ID" ) + aFact[nFact][1] ) ) )   
 					cFrom	:= AllTrim( HRB->HRB_INITIA )
 					cTo  	:= AllTrim( HRB->HRB_FINAL )
 				EndIf 
	 		EndIf 
	 	EndIf	 	 	 	 	   
		
		If !( nOperation == MODEL_OPERATION_DELETE )   
	  		oModelFact:LoadValue( "FACT_MARK"   , lMarked )
			oModelFact:LoadValue( "FACT_TABLE"  , aFact[nFact][1] )
			oModelFact:LoadValue( "FACT_TITLE"	, aFact[nFact][2] )
			oModelFact:LoadValue( "FACT_FROM"	, cFrom ) 
			oModelFact:LoadValue( "FACT_TO"		, cTo )
		Else
			oModelFact:ForceValue( "FACT_MARK"  , lMarked )
			oModelFact:ForceValue( "FACT_TABLE" , aFact[nFact][1] )
			oModelFact:ForceValue( "FACT_TITLE"	, aFact[nFact][2] )
			oModelFact:ForceValue( "FACT_FROM"	, cFrom ) 
			oModelFact:ForceValue( "FACT_TO"	, cTo )	
		EndIf 		
	Next nFact 
	
    //-------------------------------------------------------------------
	// Restaura propriedades do modelo. 
	//------------------------------------------------------------------- 	    
	oModelFact:GoLine(1) 
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//------------------------------------------------------------------- 
	aSize(aFact, 0)
	aSize(aMarkedFacts, 0)
	aFact := Nil
	aMarkedFacts := Nil		
	
Return .T.
     
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadDimension
Carrega o conteúdo da lista de dimensões com base na relação definida 
no fonte BIXModelagem. 

@param oModel, objeto, Objeto do modelo de dados do perfil de extração. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXLoadDimension( oModel )
	Local oModelDimension	:= nil
	Local aDimension		:= {}
	Local cDimension		:= "" 
	Local nDimension		:= 0
	Local nOperation		:= 0  
	Local lMarked	   		:= .T.  
    
	Default oModel			:= nil	    
    
    oModelDimension	:= oModel:GetModel("MODEL_DIMENSION")
    nOperation		:= oModel:GetOperation()
    
 	//-------------------------------------------------------------------
	// Recupera a lista de dimensões registradas. 
	//------------------------------------------------------------------- 	
	oTopology 	:= BIXTopology():New( )
	aDimension 	:= oTopology:ListEntity( DIMENSION )
	FreeObj( oTopology )

    //-------------------------------------------------------------------
	// Ordena por descrição. 
	//-------------------------------------------------------------------       
	aSort( aDimension,,, {|x,y| AllTrim( Upper(x[2]) ) < AllTrim( Upper(y[2]) ) })
       
 	//-------------------------------------------------------------------
	// Recupera os dados da dimensão do perfil. 
	//-------------------------------------------------------------------  
	If ! ( nOperation == MODEL_OPERATION_INSERT )  
		cDimension	:= HRC->HRC_DIMEN  
	EndIf  
	
	//-------------------------------------------------------------------
	// Preenche o grid de dimensões. 
	//-------------------------------------------------------------------
	For nDimension := 1 To Len( aDimension )
		If ! ( nDimension == 1 )  
			oModelDimension:AddLine(.T.) 
			oModelDimension:GoLine( oModelDimension:Length() )
		EndIf

  		//-------------------------------------------------------------------
		// Verifica se a dimensão deve ser exibida selecionada.
		//-------------------------------------------------------------------
		If !( nOperation == MODEL_OPERATION_INSERT )
	 		lMarked := ( AllTrim( aDimension[nDimension][1] ) $ cDimension )
	 	EndIf

		If !( nOperation == MODEL_OPERATION_DELETE )
	 		oModelDimension:LoadValue( "DIMENSION_MARK"  	, lMarked )
			oModelDimension:LoadValue( "DIMENSION_TABLE" 	, aDimension[nDimension][1] )
	   		oModelDimension:LoadValue( "DIMENSION_TITLE"	, aDimension[nDimension][2] )
	   		oModelDimension:LoadValue( "DIMENSION_PROTHEUS"	, aDimension[nDimension][3] )
   		Else
		 	oModelDimension:ForceValue( "DIMENSION_MARK"  	, lMarked )
			oModelDimension:ForceValue( "DIMENSION_TABLE" 	, aDimension[nDimension][1] )
	   		oModelDimension:ForceValue( "DIMENSION_TITLE"	, aDimension[nDimension][2] )
	   		oModelDimension:ForceValue( "DIMENSION_PROTHEUS", aDimension[nDimension][3] )
   		EndIf
	Next nFact

    //-------------------------------------------------------------------
	// Restaura propriedades do modelo. 
	//------------------------------------------------------------------- 		
	oModelDimension:GoLine(1)
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//------------------------------------------------------------------- 
	aSize(aDimension, 0)
	aDimension := Nil
	
Return .T.  
     
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAppAction
Realiza a marcação ou desmarcação dos itens das listas de áreas e reflete
a opção para as listas de fatos e dimensões de acordo com o relacionamento
definido no fonte BIXModelagem. 

@param oView, objeto, Objeto visual. 
@param cIDView, caracter, Identificador do objeto visual. 
@param cField, caracter, Identificador do campo do objeto visual. 
@param xValue, indefinido, Valor do campo do objeto visual. 
@param xEntity, indefinido, Entidade ou lista de entidades a serem alteradas. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXAppAction( oView, cIDView, cField, xValue, xEntity )                           
	Local oModelApp		:= oView:oModel:GetModel( "MODEL_AREA" ) 
	Local oModelFact 	:= oView:oModel:GetModel( "MODEL_FACT" )  
    Local aFact			:= {}
    Local aSharedFacts	:= {}                                    
    Local aMarkedApp	:= {}
    Local nEntity		:= 0  
	Local nPosition		:= 0  
	Local cFact			:= ""
    
  	Default xEntity		:= oModelApp:GetValue("AREA_ID")        

  	//-------------------------------------------------------------------
	// Recupera todas as áreas selecionadas.
	//------------------------------------------------------------------- 
	nPosition	:= oModelApp:GetLine() 

	For nEntity := 1 To oModelApp:Length() 
   		oModelApp:GoLine(nEntity) 

   		If ( oModelApp:GetValue("AREA_MARK") )	  
            aAdd( aMarkedApp, oModelApp:GetValue("AREA_ID") ) 
        EndIf
	Next nEntity 

	oModelApp:GoLine( nPosition ) 

  	//-------------------------------------------------------------------
	// Recupera todos as fatos da área e as fatos compartilhadas.
	//-------------------------------------------------------------------     
 	aFact			:= BIXGetRelation( xEntity, APP, FACT )    
    aSharedFacts	:= BIXGetRelation( aMarkedApp, APP, FACT )

  	//-------------------------------------------------------------------
	// Marca ou desmarca as fatos filhas da área. 
	//-------------------------------------------------------------------  
	nPosition	:= oModelFact:GetLine()
	
	For nEntity := 1 To Len( aFact ) 
		If ( oModelFact:SeekLine( {{ "FACT_TABLE",aFact[nEntity] }} ) )  
			cFact 	:= oModelFact:GetValue("FACT_TABLE") 
   
   			If ! ( xValue )  
			  	//-------------------------------------------------------------------
				// Desmarca as fatos das áreas que não forem compatilhadas.
				//-------------------------------------------------------------------    
				If ( aScan( aSharedFacts, {|x| AllTrim( cFact ) == x }) == 0 ) 
					oModelFact:SetValue( "FACT_MARK", xValue ) 
					oModelFact:LoadValue( "FACT_FROM", "" ) 
			   		oModelFact:LoadValue( "FACT_TO", "" )    
				EndIf   
			Else
				oModelFact:SetValue( "FACT_MARK", xValue )  
			EndIf
	   	EndIf 
	Next nEntity
	
	oModelFact:GoLine( nPosition )  
	
  	//-------------------------------------------------------------------
	// Seleciona as dimensões filhas das fatos que são filhas da área. 
	//-------------------------------------------------------------------  
    BIXFactAction( oView, cIDView, cField, xValue, aFact )

	//-------------------------------------------------------------------
	// Atualiza a interface. 
	//-------------------------------------------------------------------  
	oView:Refresh("VIEW_FACT") 
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//------------------------------------------------------------------- 
	aSize(aFact, 0)
	aSize(aSharedFacts, 0)
	aSize(aMarkedApp, 0)
	aFact := Nil
	aSharedFacts := Nil
	aMarkedApp := Nil
	
Return .T.         
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFactAction
Realiza a marcação ou desmarcação dos itens da lista de fatos e a
validação da opção escolhida de acordo. Reflete a opção para a lista 
de dimensões de acordo com o relacionamento definido no fonte BIXModelagem. 

@param oView, object, Objeto visual. 
@param cIDView, caracter, Identificador do objeto visual. 
@param cField, caracter, Identificador do campo do objeto visual. 
@param xValue, indefinido, Valor do campo do objeto visual. 
@param xEntity, indefinido, Entidade ou lista de entidades a serem alteradas. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXFactAction( oView, cIDView, cField, xValue, xEntity )
	Local oModelApp			:= oView:oModel:GetModel( "MODEL_AREA" )                            
	Local oModelFact 		:= oView:oModel:GetModel( "MODEL_FACT" )   
	Local oModelDimension 	:= oView:oModel:GetModel( "MODEL_DIMENSION" )     
	Local aMarkedFacts		:= {} 
	Local aMarkedApp		:= {}
	Local aFact 			:= {}
	Local aSharedDimensions	:= {}
	Local cDimension		:= ""  
	Local cApp				:= ""
	Local nEntity			:= 0 
	Local nPosition			:= 0  
	Local nFact				:= 0
	Local nApp 				:= 0
	Local lHasFather		:= .F.
	Local lMark				:= .F.

	Default xEntity		:= oModelFact:GetValue("FACT_TABLE")  
 
	lHasFather := ( Valtype( xEntity ) == "A" )

  	//-------------------------------------------------------------------
	// Identifica se deve marcar ou desmarcar as dimensões. 
	//-------------------------------------------------------------------  
   	If ( xValue ) 
   		//-------------------------------------------------------------------
   		// Identifica se alguma área da qual a fato é filha está marcada. 
		//-------------------------------------------------------------------      
   		If ! ( lHasFather ) 
   			//-------------------------------------------------------------------
			// Lista as áreas relacionadas com a fato selecionada. 
			//------------------------------------------------------------------- 
	   		aApp		:= BIXGetRelation( xEntity, FACT, APP )  
	   		nPosition	:= oModelApp:GetLine()  
	   		              
			For nEntity := 1 To Len( aApp ) 
				If ( oModelApp:SeekLine( {{ "AREA_ID", aApp[nEntity] }} ) )
					//-------------------------------------------------------------------
					// Identifica se alguma área está selecionada. 
					//-------------------------------------------------------------------  
			   		If ( oModelApp:GetValue("AREA_MARK") ) 
						lHasFather := .T. 
						Exit   
				    EndIf 
			   	EndIf 	   		
			Next nEntity  
			     			
		   	If ! ( lHasFather ) 
		   		If ( MsgYesNo( STR0035 + CRLF + STR0036 ) ) //"A área da qual esta fato pertence não foi incluída no perfil de extração."###"Deseja selecionar a área da fato?"       
					lHasFather := ( Len( aApp ) == 1 ) 
					
					If ! ( lHasFather )  
						//-------------------------------------------------------------------
						// Exibe a lista de áreas para o usuário selecionar. 
						//-------------------------------------------------------------------  	
						cApp 		:= BIXChooseArea( oModelFact:GetValue("FACT_TABLE") )
				   		lHasFather 	:= ! ( Empty( cApp ) )  

				   		If ( lHasFather )          
					   		If ( oModelApp:SeekLine( {{ "AREA_ID", cApp }} ) )
	                        	oModelApp:LoadValue( "AREA_MARK", .T. ) 	
							EndIf  
						EndIf 
					Else								
						oModelApp:LoadValue( "AREA_MARK", .T. ) 
					EndIf 					
				EndIf
			EndIf 			

			oModelApp:GoLine( nPosition )
		EndIf
		
	  	//-------------------------------------------------------------------
		// Identifica se a dimensão é filha de alguma fato selecionada. 
		//------------------------------------------------------------------- 
		If ( lHasFather )    
    		aDimensions	:= BIXGetRelation( xEntity , FACT, DIMENSION )
			nPosition	:= oModelDimension:GetLine()  

			For nEntity := 1 To Len( aDimensions ) 
				If ( oModelDimension:SeekLine( {{ "DIMENSION_TABLE",aDimensions[nEntity] }} ) )
                	oModelDimension:SetValue( "DIMENSION_MARK", xValue )  
			   	EndIf 
			Next nEntity
             
			oModelDimension:GoLine( nPosition ) 
			  
			//-------------------------------------------------------------------
			// Atualiza a interface. 
			//-------------------------------------------------------------------   
			oView:Refresh("VIEW_AREA")
			oView:Refresh("VIEW_DIMENSION")
		Else	
			MsgInfo( STR0020 ) //"A fato não pode ser incluída no perfil de extração pois não está relacionada com nenhuma área selecionada."
			//-------------------------------------------------------------------
			// Inverte a marcação do campo. 
			//-------------------------------------------------------------------   
			oModelFact:SetValue( "FACT_MARK", ! xValue )  
			   
			//-------------------------------------------------------------------
			// Atualiza a interface. 
			//-------------------------------------------------------------------   
			oView:Refresh("VIEW_FACT") 
		EndIf    
	Else 
		//-------------------------------------------------------------------
		// Remove a configuração de períodos do fato.
		//-------------------------------------------------------------------   
		If !( lHasFather )
			oModelFact:LoadValue( "FACT_FROM", "" ) 
			oModelFact:LoadValue( "FACT_TO", "" )   
		EndIf          
	
	  	//-------------------------------------------------------------------
		// Recupera todos os fatos selecionados.
		//------------------------------------------------------------------- 
		nPosition	:= oModelFact:GetLine() 
		
		For nEntity := 1 To oModelFact:Length() 
	   		oModelFact:GoLine(nEntity) 
	   		
	   		If ( oModelFact:GetValue("FACT_MARK") )	  
	            aAdd( aMarkedFacts, oModelFact:GetValue("FACT_TABLE") ) 
            EndIf
		Next nEntity 
		
		oModelFact:GoLine( nPosition )          

	  	//-------------------------------------------------------------------
		// Desmarca as dimensões das fatos que não forem compatilhadas.
		//-------------------------------------------------------------------   
		aDimensions			:= BIXGetRelation( xEntity , FACT, DIMENSION )
		aSharedDimensions	:= BIXGetRelation( aMarkedFacts , FACT, DIMENSION )
		nPosition			:= oModelDimension:GetLine()

		For nEntity := 1 To Len( aDimensions ) 
			If ( oModelDimension:SeekLine( {{ "DIMENSION_TABLE",aDimensions[nEntity] }} ) )  
				cDimension 	:= oModelDimension:GetValue("DIMENSION_TABLE")   
				
				If ( aScan( aSharedDimensions, {|x| AllTrim( cDimension ) == x }) == 0 ) 
					oModelDimension:SetValue( "DIMENSION_MARK", xValue )  
				EndIf 
		   	EndIf 
		Next nEntity		

		oModelDimension:GoLine( nPosition )	

		//-------------------------------------------------------------------
		// Atualiza a interface. 
		//-------------------------------------------------------------------  
		oView:Refresh("VIEW_DIMENSION")

		//-------------------------------------------------------------------
		// Recupera todas as áreas selecionadas.
		//------------------------------------------------------------------- 
		nPosition	:= oModelApp:GetLine() 

		For nEntity := 1 To oModelApp:Length() 
	   		oModelApp:GoLine(nEntity) 
	
	   		If ( oModelApp:GetValue("AREA_MARK") )	  
	            aAdd( aMarkedApp, oModelApp:GetValue("AREA_ID") ) 
            EndIf
		Next nEntity 

		//-------------------------------------------------------------------
		// Desmarca as áreas cujas fatos não estão marcadas.
		//------------------------------------------------------------------- 
	    For nApp := 1 To Len(aMarkedApp)
	    	lMark := .F.
	    
	    	If ( oModelApp:SeekLine( {{ "AREA_ID", aMarkedApp[nApp] }} ) )
	    		aFact := BIXGetRelation( oModelApp:GetValue("AREA_ID"), APP, FACT )

	    		For nFact := 1 To Len(aFact)
	    			If ( oModelFact:SeekLine( {{ "FACT_TABLE", aFact[nFact] }} ) )
	    			 	If oModelFact:GetValue("FACT_MARK")
	    			 		lMark := .T.
	    			 	EndIf
	    			EndIF
	    		Next nFact
	    		
	    		If !(lMark)
	    			oModelApp:SetValue( "AREA_MARK", lMark )	    		
	    		EndIf
	    	EndIf
	    Next nApp

		oModelApp:GoLine( nPosition )	
		//-------------------------------------------------------------------
		// Atualiza a interface. 
		//-------------------------------------------------------------------   
		oView:Refresh("VIEW_AREA")
	EndIf
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//-------------------------------------------------------------------
	If !Empty( aMarkedFacts )
		aSize(aMarkedFacts, 0)
		aMarkedFacts := Nil
	EndIf

	If !Empty( aMarkedApp )
		aSize(aMarkedApp, 0)
		aMarkedApp := Nil
	EndIf

	If !Empty( aFact )
		aSize(aFact, 0)
		aFact := Nil
	EndIf

	If !Empty( aSharedDimensions )
		aSize(aSharedDimensions, 0)
		aSharedDimensions := Nil
	EndIf
	
Return .T.
          
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXChooseArea
Permite que o usuário selecione uma área relacionada com uma fato.

@param cFact, caracter, Fato da qual serão exibidas as área relacionadas.  
@return cApp, ID da área selecionada. 

@author  Valdiney V GOMES
@since   17/04/2017
/*/
//-------------------------------------------------------------------
Static Function BIXChooseArea( cFact )
	Local oTopology		:= nil	
	Local oDialog		:= nil
    Local oBrowse   	:= nil 
    Local aAllApp		:= {}
	Local aApp			:= {} 
    Local cApp			:= ""
	Local bOK  	   		:= nil 
	Local bCancel  		:= nil
	Local bTable		:= nil
	Local bDescription	:= nil
	
 	//-------------------------------------------------------------------
	// Recupera a lista de apps registradas. 
	//------------------------------------------------------------------- 	
	oTopology 	:= BIXTopology():New( )
	aAllApp 	:= oTopology:ListEntity( APP )
	FreeObj( oTopology )	
	
 	//-------------------------------------------------------------------
	// Define as ações de interface. 
	//------------------------------------------------------------------- 	
	bOK  	   		:= {|| cApp := aApp[oBrowse:nAt], oDialog:End() }
	bCancel  		:= {|| oDialog:End() } 
	bTable			:= {|| aApp[oBrowse:nAt] }
	bDescription	:= {|| aAllApp[aScan( aAllApp, {|x| x[1] == aApp[oBrowse:nAt] } ) ][2] }	

	//-------------------------------------------------------------------
	// Recupera a lista de áreas relacionada com a fato informada. 
	//-------------------------------------------------------------------
	aApp	:= BIXGetRelation( cFact, FACT, APP ) 
  
	//-------------------------------------------------------------------
	// Monta a lista de áreas. 
	//-------------------------------------------------------------------		 	  
    DEFINE DIALOG oDialog TITLE STR0009 FROM 050, 150 TO 400,600 PIXEL //"Áreas"   
		DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aApp NO REPORT NO LOCATE NO CONFIG DOUBLECLICK bOK OF oDialog
			ADD COLUMN oColumn DATA bTable 			TITLE "ID" OF oBrowse 
			ADD COLUMN oColumn DATA bDescription 	TITLE STR0040 OF oBrowse 
		ACTIVATE FWBROWSE oBrowse
     ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F.,{},,,.F.,.F.,.F.,.T., .F. )
Return cApp 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetRelation
Retorna a relação entre qualquer entidade com uma outra de com base no
relacionamento definido no fonte BIXModelagem. 

@param xValue, indefinido, Entidade conhecida. 
@param cType, caracter, Tipo da entidade conhecida	
@param cTypeSearched, caracter, Tipo das entidades pesquisadas. 
@return aEntity, Relação entre as entidades selecionadas. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Function BIXGetRelation( xValue, cType, cTypeSearched )	
	Local oTopology		:= nil
	Local aEntity		:= {}  
	Local aAuxiliary   	:= {}
	Local aIdentifyer	:= {}
	Local cIdentifyer 	:= "" 
	Local nApp			:= 1	 
	Local nFact      	:= 1
	Local nDimension    := 1
        
    Default xValue 			:= ""   
    Default cType    		:= "" 
    Default cTypeSearched   := ""  
        
	cIdentifyer := If( ValType( xValue ) == "A", cBIConcatWSep( "|", xValue ), xValue )
 	aIdentifyer	:= aBIToken( cIdentifyer, "|", .F. )

	//-------------------------------------------------------------------
	// Recupera a lista de apps registradas. 
	//------------------------------------------------------------------- 
	If ( __aApp == nil )
		oTopology 	:= BIXTopology():New( )
		__aApp 	:= oTopology:GetTopology( )
		FreeObj( oTopology )
	EndIf	

	Do Case    
		//-------------------------------------------------------------------
		// Lista entidades relacionadas com as áreas. 
		//------------------------------------------------------------------- 
		Case ( cType == APP )
			If ( cTypeSearched == FACT )		
				For nApp := 1 To Len( __aApp )
					If ! ( aScan( aIdentifyer, {|x| AllTrim( x ) == __aApp[nApp][1] } ) == 0 )
						For nFact := 1 To Len( __aApp[nApp][3] ) 
							If ! ( aScan( aEntity, {|x| x == __aApp[nApp][3][nFact][1] } ) > 0 ) 
								aAdd( aEntity, __aApp[nApp][3][nFact][1] )   
							EndIf
						Next  				
					Endif   
				Next  		
			ElseIf ( cTypeSearched == DIMENSION ) 
				aAuxiliary 	:= BIXGetRelation( xValue, APP, FACT )
				aEntity		:= BIXGetRelation( aAuxiliary, FACT, DIMENSION )
			EndIf
		//-------------------------------------------------------------------
		// Lista entidades relacionadas com os fatos. 
		//------------------------------------------------------------------- 
		Case ( cType == FACT ) 
			If ( cTypeSearched == APP ) 
				For nApp := 1 To Len( __aApp )
					For nFact := 1 To Len( __aApp[nApp][3] )  
						If ( __aApp[nApp][3][nFact][1] $ cIdentifyer )
							If ! ( aScan( aEntity, {|x| x == __aApp[nApp][1] } ) > 0 )
								aAdd( aEntity, __aApp[nApp][1] )
							EndIf 				
						EndIf
					Next 
				Next 
			ElseIf ( cTypeSearched == DIMENSION )	
				For nApp := 1 To Len( __aApp )
					For nFact := 1 To Len( __aApp[nApp][3] )  
						If ( __aApp[nApp][3][nFact][1] $ cIdentifyer )
							For nDimension := 1 To Len( __aApp[nApp][3][nFact][4] )   
								If ! ( aScan( aEntity, {|x| x == __aApp[nApp][3][nFact][4][nDimension][1] } ) > 0 )
									aAdd( aEntity, __aApp[nApp][3][nFact][4][nDimension][1] )
								EndIf 
							Next  					
						EndIf
					Next 
				Next 
			EndIf
	EndCase
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//------------------------------------------------------------------- 
	If !Empty(aAuxiliary)
		aSize(aAuxiliary, 0)
		aAuxiliary := Nil
	EndIf
	If !Empty(aIdentifyer)
		aSize(aIdentifyer, 0)
		aIdentifyer := Nil
	EndIf	
	
Return aEntity          

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCommitProfile
Realiza a gravação da tabela BIEXTRACTOR.PRF das informações disponíveis
no modelo de dados do perfil de extração. 

@param oModel, objeto, Objeto do modelo de dados do perfil de extração. 

@author  Valdiney V GOMES
@since   11/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXCommitProfile( oModel )      
	Local oModelApp			:= nil                            
	Local oModelFact 		:= nil 
	Local oModelDimension 	:= nil
	Local aEntity			:= {} 
	Local nOperation 		:= 0    
	Local nEntity			:= 0
	Local lInsert			:= .T.  
	
	Default oModel	:= nil 

	oModelApp		:= oModel:GetModel( "MODEL_AREA" )                            
	oModelFact 		:= oModel:GetModel( "MODEL_FACT" )   
	oModelDimension := oModel:GetModel( "MODEL_DIMENSION" )
	nOperation 		:= oModel:GetOperation() 

	BEGIN TRANSACTION
		If ( nOperation == MODEL_OPERATION_DELETE )
			//-------------------------------------------------------------------
			// Remove o perfil. 
			//------------------------------------------------------------------- 
			RecLock( "HRC", .F. )
				DBDelete()
			MsUnlock()      
			
			//-------------------------------------------------------------------
			// Remove os intervalos da tabela adicional. 
			//------------------------------------------------------------------- 			
			For nEntity := 1 To oModelFact:Length() 
		   		oModelFact:GoLine(nEntity) 
		   		
				If ( HRB->( DBSeek( oModel:GetValue( "MODEL_MAIN", "HRC_ID" ) + oModelFact:GetValue("FACT_TABLE") ) ) )
					RecLock( "HRB", .F. ) 
						DBDelete()
					MsUnlock() 
				EndIf				   
			Next nEntity
		Else  
			//-------------------------------------------------------------------
			// Grava a tabela principal do modelo. 
			//------------------------------------------------------------------- 			
			RecLock( "HRC", ( nOperation == MODEL_OPERATION_INSERT ) ) 	 
				HRC->HRC_ID  	:= oModel:GetValue( "MODEL_MAIN", "HRC_ID" )
				HRC->HRC_TITLE 	:= oModel:GetValue( "MODEL_MAIN", "HRC_TITLE" )  
	       
				//-------------------------------------------------------------------
				// Grava as áreas. 
				//-------------------------------------------------------------------             
	            aEntity := {} 
	            
				For nEntity := 1 To oModelApp:Length() 
			   		oModelApp:GoLine(nEntity) 
			   		
			   		If ( oModelApp:GetValue("AREA_MARK") )	 	  
						aAdd( aEntity, AllTrim( oModelApp:GetValue("AREA_ID") ) ) 
					EndIf    
				Next nEntity		
					
				HRC->HRC_AREA 	:= cBIConcatWSep( "|", aEntity )
				 
				//-------------------------------------------------------------------
				// Grava as fatos. 
				//------------------------------------------------------------------- 			 	 
				aEntity := {}
				 	 
				For nEntity := 1 To oModelFact:Length() 
			   		oModelFact:GoLine(nEntity) 
			   		
			   		If ( oModelFact:GetValue("FACT_MARK") )
			   			aAdd( aEntity, AllTrim( oModelFact:GetValue("FACT_TABLE") ) ) 	  
					EndIf 
					
					//-------------------------------------------------------------------
					// Identifica se insere ou atualiza um intervalo. 
					//------------------------------------------------------------------- 	
					lInsert := ! ( HRB->( DBSeek( oModel:GetValue( "MODEL_MAIN", "HRC_ID" ) + oModelFact:GetValue("FACT_TABLE") ) ) )
					
					//-------------------------------------------------------------------
					// Grava os intervalos das fatos. 
					//------------------------------------------------------------------- 	
					RecLock( "HRB", lInsert ) 
						HRB->HRB_PROFIL 	:= oModel:GetValue( "MODEL_MAIN", "HRC_ID" )
						HRB->HRB_FACT 	:= oModelFact:GetValue("FACT_TABLE")
						HRB->HRB_INITIA 	:= AllTrim( oModelFact:GetValue("FACT_FROM") )
						HRB->HRB_FINAL 	:= AllTrim( oModelFact:GetValue("FACT_TO") )
					MsUnlock()				   
				Next nEntity		
	
				HRC->HRC_FACT 	:= cBIConcatWSep( "|", aEntity )			
	
	           	//-------------------------------------------------------------------
				// Grava as dimensões.
				//-------------------------------------------------------------------   
	            aEntity := {}     
	
				For nEntity := 1 To oModelDimension:Length() 
			   		oModelDimension:GoLine(nEntity)  
			   		
			   		If ( oModelDimension:GetValue("DIMENSION_MARK") )		 	  
						aAdd( aEntity, AllTrim( oModelDimension:GetValue("DIMENSION_TABLE") ) )  
					EndIf   
				Next nEntity		
					
				HRC->HRC_DIMEN 	:= cBIConcatWSep( "|", aEntity )	
			MsUnlock()
			
		 	//-------------------------------------------------------------------
			// Mata as variáveis do tipo array para diminuir o consumo de memória 
			//------------------------------------------------------------------- 
			aSize(aEntity, 0)
			aEntity	:= Nil
			
		EndIf
	END TRANSACTION
Return .T.  
      
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEvalDate 
Evalia um valor informado para definir se o valor ou expressões definida 
retorna uma data. 

@param xValue, indefinido, Valor a ser avaliado. 
@param lString, lógico, Indica se deve retornar a data como string. 
@return xReturn, indefinido, Data retornada pela expressões em formato data ou string. 

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXEvalDate( xValue, lString )         
	Local cValue 		:= ""
	Local cParameter	:= ""
	Local nOpen			:= 0
	Local nClose		:= 0
	Local lValid		:= .T. 
	Local dValid    	:= nil   
	Local xReturn		:= nil
	Local bErro 		:= ErrorBlock( { || } )  

	Default xValue		:= "" 	
	Default lString		:= .F. 
	
	cValue 	:= Upper( StrTran( AllTrim( xValue ), " ", "" ) )
	
	BEGIN SEQUENCE
		//-------------------------------------------------------------------
		// Força a conversão valor informado em data. 
		//------------------------------------------------------------------- 
 		dValid 	:= xBIConvTo("D", cValue) 
        
        //-------------------------------------------------------------------
		// Verifica se retornou uma data válida. 
		//------------------------------------------------------------------- 
		lValid := ! Empty( DToS( dValid ) ) 
		
		If ! ( lValid ) 
			//-------------------------------------------------------------------
			// Verifica se foram utilizadas funções de manipulação de data. 
			//------------------------------------------------------------------- 
			If ( Left( cValue, 5 ) $ "DATE(|STOD(|CTOD(" ) .Or. ( Left( cValue, 7 ) $ "BIXFirstDay(|BILDAY(" )
				lValid := ( "DATE(" $ cValue )
				
				If !( lValid )
					nOpen 	:= At( "(", cValue )
					nClose	:= At( ")", cValue )
					
					If ( nOpen < nClose )
						//-------------------------------------------------------------------
						// Não valida o parâmetro das funções complexas BIXFDAY e BIXLDAY. 
						//------------------------------------------------------------------- 
						If ( Left( cValue, 7 ) $ "BIXFirstDay(|BILDAY(" )
							lValid := .T. 
						Else
							//-------------------------------------------------------------------
							// Encontra o parâmetro passado para as funções STOD ou CTOD. 
							//------------------------------------------------------------------- 
							cParameter := AllTrim( SubStr ( cValue, ( nOpen + 1 ), ( ( nClose - nOpen ) - 1 ) ) )
							
							//-------------------------------------------------------------------
							// Verifica o parâmetro da função é uma data válida.
							//------------------------------------------------------------------- 
							If ( ! Empty( cParameter ) )
								dValid 	:= xBIConvTo( "D", cParameter ) 
								
								If ( ValType( dValid ) == "D" )
									lValid := ! Empty( DToS( dValid ) ) 
								EndIf 
							EndIf
						EndIf
					EndIf 
				EndIf
			
				If ( lValid )
					//-------------------------------------------------------------------
					// Macroexecuta o conteúdo informado. 
					//------------------------------------------------------------------- 
					dValid := &( cValue )	
					
					//-------------------------------------------------------------------
					// Verifica se retornou uma data válida. 
					//------------------------------------------------------------------- 
					If ( ValType( dValid ) == "D" )
						lValid := ! Empty( DToS( dValid ) ) 
					EndIf 
				EndIf
		 	EndIf
		EndIf

		//-------------------------------------------------------------------
		// Identifica a formato do retorno. 
		//------------------------------------------------------------------- 
		If !( lValid ) 
			xReturn := If( !lString, nil, "" )
		Else
			xReturn := If( !lString, dValid, DToS( dValid ) )
		EndIf 
	END SEQUENCE
	ErrorBlock(bErro)
Return xReturn  
        
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXValidDate 
Evalia os possíveis valores para os campos De e Até da fato. 

@param oModel, objecto, Objeto do modelo de dados do perfil de extração. 
@param cId, caracter, ID do campo
@param xValue, indefinido, Valor informado.  
@return lValid, Indica se o valor informado é válido.  

@author  Valdiney V GOMES
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXValidDate( oModel, cId, xValue )        
	Local lValid 	:= .F.  
	Local dValid    := nil 
	Local bErro 	:= ErrorBlock( { || } )
	  
	//-------------------------------------------------------------------
	// Valida se uma expressão foi informada. 
	//-------------------------------------------------------------------     
	lValid  := Empty( xValue )
	
	If ! ( lValid )    
		//-------------------------------------------------------------------
		// Valida se a expressão informada retorna uma data. 
		//------------------------------------------------------------------- 
		lValid := ! (  BIXEvalDate( xValue ) == nil )  

		If ! ( lValid )
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0022, STR0023, "", "") //"A expressão não retorna uma data." ### "Por favor, informe uma expressão de data. As funções Date(), SToD() e CTod() podem ser utilizadas."
		EndIf  
	EndIf
Return lValid    

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXValidFactPeriod
Evalia os valores informados nos campos De e Até da lista de fatos
para avaliar se são exibidos em ordem cronológica. 

@param oModel, objetct, Objeto do modelo de dados do perfil de extração. 
@return lValid, Indica se o valor informado é válido.  

@author  Valdiney V GOMES
@since   13/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXValidFactPeriod( oModel )  
	Local cFrom 	:= nil
	Local cTo 		:= nil 
	Local lHasFrom  := .F. 
	Local lHasTo	:= .F. 
	Local lValid	:= .T. 
	
	Default oModel	:= nil 
   
  	cFrom 		:= oModel:GetValue("FACT_FROM")
	cTo 		:= oModel:GetValue("FACT_TO") 
	lHasFrom  	:= ! Empty( cFrom )
	lHasTo		:= ! Empty( cTo )  
   
   	//-------------------------------------------------------------------
	// Valida se não é utilizado período por excessão. 
	//-------------------------------------------------------------------      
	lValid  := ( ! ( lHasFrom ) .And. ! ( lHasTo ) )

    If ! ( lValid )   
    	//-------------------------------------------------------------------
		// Valida se a data inicial e final foi informada. 
		//-------------------------------------------------------------------   
  		lValid  := ( lHasFrom ) .And. ( lHasTo ) 
    
      	If ( lValid )
	      	//-------------------------------------------------------------------
			// Valida se a ordem cronológica foi respeitada. 
			//-------------------------------------------------------------------    
      	 	lValid := ( BIXEvalDate( cFrom ) <= BIXEvalDate( cTo ) )   
      	 	
      	 	If ! ( lValid ) 
      	 		oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0024, STR0025 + AllTrim( oModel:GetValue("FACT_TITLE") ) , "", "") //"A data inicial deve ser menor ou igual a data final de extração."###"Por favor, informe uma expressões que retorne valores válidos para a data inicial e final para a fato "
      	 	EndIf 
      	Else
   			 oModel:GetModel():SetErrorMessage( , , oModel:GetId() , "", "", STR0026, STR0027 + AllTrim( oModel:GetValue("FACT_TITLE") ) , "", "") //"As datas inicial e final para a extração da fato devem ser informadas."###"Por favor, informa a expressões para a data inicial e final de extração da fato "
      	EndIf
    EndIf     
Return lValid  
    
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXChooseProfile
Consulta específica para perfis de extração.

@param cVariable, caracter, Variável que será atualizada pela consulta. 

@author  Valdiney V GOMES
@since   11/11/2013
/*/
//-------------------------------------------------------------------
Function BIXChooseProfile( cVariable )
	Local oDialog	:= nil
    Local oBrowse   := nil 
    Local aButtons	:= {}
	Local bOK  		:= nil
	Local bCancel	:= nil
	
	Default cVariable := ""
	
	bOK  		:= {|| cVariable := HRC->HRC_ID, oDialog:End() }
	bCancel		:= {|| oDialog:End() }	
		
	BIXOpenProfile()

	//-------------------------------------------------------------------
	// Inclui botões de CRUD para facilitar o acesso as operações. 
	//-------------------------------------------------------------------  
	Aadd( aButtons, {""	, {|| BIXOperation( STR0004, MODEL_OPERATION_VIEW )	, oBrowse:Refresh()}, STR0004, STR0004 } ) 	//"Visualizar"
 	Aadd( aButtons, {"" , {|| BIXOperation( STR0005, MODEL_OPERATION_INSERT ), oBrowse:Refresh()}, STR0005, STR0005 } )	//"Incluir"	  
  	Aadd( aButtons, {""	, {|| BIXOperation( STR0006, MODEL_OPERATION_UPDATE ), oBrowse:Refresh()}, STR0006, STR0006 } ) //"Alterar"
  	Aadd( aButtons, {""	, {|| BIXOperation( STR0007, MODEL_OPERATION_DELETE ), oBrowse:Refresh()}, STR0007, STR0007 } ) //"Excluir"
 
	//-------------------------------------------------------------------
	// Monta a lista de perfis. 
	//-------------------------------------------------------------------	
    DEFINE DIALOG oDialog TITLE STR0018 FROM 050, 150 TO 450,600 PIXEL //"Perfil de Extração"     
		DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "HRC" DOUBLECLICK bOK NO SEEK NO CONFIG NO REPORT NO LOCATE  OF oDialog	
			oBrowse:SetDescription( STR0018 ) //"Perfil de Extração"
			
			ADD COLUMN oColumn DATA {||HRC->HRC_ID } 	TITLE STR0002	OF oBrowse 
			ADD COLUMN oColumn DATA {||HRC->HRC_TITLE} 	TITLE STR0003 OF oBrowse 
		ACTIVATE FWBROWSE oBrowse 
    ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, bOK, bCancel, .F., aButtons,,,.F.,.F.,.F.,.T., .F. )
Return .T.
            
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOperation
Exibe o formulário para realização de operações de CRUD do profile.

@param nOPeration, numérico, Operação que será realizada.  

@author  Valdiney V GOMES
@since   11/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXOperation( cTitle, nOPeration )  
	Local lContinue 	:= .T. 
	                	
	Default cTitle		:= ""
	Default nOPeration	:= ""	
	
	//-------------------------------------------------------------------
	// Verifica se há registros para ser modificado. 
	//-------------------------------------------------------------------	
	If ! ( nOperation == MODEL_OPERATION_INSERT )
		lContinue := ( HRC->( RecCount() ) > 0 )  		 			
	EndIf 

	//-------------------------------------------------------------------
	// Exibe de tela de edição. 
	//-------------------------------------------------------------------	          
  	If ( lContinue ) 
		FWExecView( cTitle, "BIXPROFILE", nOPeration ) 
	EndIf
Return 
      
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXValidProfile()
Avalia se o profile informado no campo perfil do agendamento no schedule
é válido.    

@return lProfile 	Indica se o profile informado é válido.  

@author  Valdiney V GOMES
@since   12/11/2013	
/*/
//-------------------------------------------------------------------
Function BIXValidProfile()  
	Local cProfile	:= MV_PAR05
	Local lValid 	:= .F. 
	                   
	BIXOpenProfile() 

   	//-------------------------------------------------------------------
	// Valida se não é utilizado profile. 
	//-------------------------------------------------------------------  	   
	lValid := Empty( cProfile ) 
	
	If ! ( lValid ) 
	   	//-------------------------------------------------------------------
		// Valida se o profile informado existe. 
		//------------------------------------------------------------------- 
	 	lValid := ( ExistCpo("HRC", cProfile, 1,,.F. ) ) 
	 	
	 	If ( lValid ) 
	 		//-------------------------------------------------------------------
			// Remove a configuração de extração por área. 
			//-------------------------------------------------------------------     
	 		MV_PAR04 	:= "" 
	 	Else
        	MsgAlert( STR0028 ) //"Perfil de extração inválido!"  
	 	EndIf
	EndIf
Return lValid 
   
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXHasProfile
Avalia se um agendamento do schedule contém o perfil de extração informado. 

@param aParameter, array, Array obtido pela função BIXGetParms
@return lProfile, lógico, Indica se há profile configurado.  

@author  Valdiney V GOMES
@since   13/11/2013
/*/
//-------------------------------------------------------------------
Function BIXHasProfile( aParameter ) 
  	Local lProfile		:= .F.  
  	
	Default aParameter	:= {}

 	//-------------------------------------------------------------------
	// Identifica a pergunta do profile existe. 
	//-------------------------------------------------------------------   
	lProfile := ( Len( aParameter ) >= 4 ) 
	
	If ( lProfile ) 		
		BIXOpenProfile() 
				
		//-------------------------------------------------------------------
		// Identifica se há profile configurado. 
		//-------------------------------------------------------------------  
		lProfile := HRC->( DBSeek( Padr( aParameter[4], 6 ) ) )  
	EndIf 		
Return lProfile   
   
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetPeriod
Retorna o período específico definido para uma fato em um perfil de extração. 

@param cFact 		Fato que terá as datas de extração verificadas no profile.
@param aParameter 	Array obtido pela função BIXGetParms
 
@return aPeriod 	Data inicial e final de extração da fato informado. 

@author  Valdiney V GOMES
@since   11/11/2013
/*/
//-------------------------------------------------------------------
Function BIXGetPeriod( cFact, aParameter ) 
	Local oTopology  := Nil
	Local aFact      := {} 
	Local aPeriod    := {} 
	Local cFrom      := ""   
	Local cTo        := ""  
	Local cTemp      := ""    
	Local cDateFrom  := aParameter[1]	 
	Local cDateTo    := aParameter[2]    
	Local nFact      := 1   
	Local lFact      := .F. 
	Local lHistory   := .F. 
 	Local lProfile   := .F. 

	Default	cFact := "" 

	//-------------------------------------------------------------------
	// Recupera a lista de fatos registradas. 
	//-------------------------------------------------------------------
	oTopology 	:= BIXTopology():New( )

	//-------------------------------------------------------------------
	// Verifica se a entidade é uma fato.
	//-------------------------------------------------------------------
	lFact 	:= Len( oTopology:ListEntity( FACT, AllTrim( cFact ) ) ) > 0 
	
	//-------------------------------------------------------------------
	// Libera objeto de topologia da memória.
	//-------------------------------------------------------------------
	FreeObj( oTopology )

	If ( lFact )
		If ! ( BIXLinkFSD() == 0 )
			//-------------------------------------------------------------------
			// Recupera um alias temporário. 
			//-------------------------------------------------------------------
			cTemp := GetNextAlias()     
		
			//-------------------------------------------------------------------
			// Executa a instrução SQL na tabela de períodos. 
			//-------------------------------------------------------------------
			DBUseArea(.T., "TOPCONN", TcGenQry(,, "SELECT HJJ_INFPER, HJJ_PERINI, HJJ_PERFIN FROM HJJ WHERE HJJ_CDFATO = '" + cFact + "'" ), cTemp, .T., .T.)
		 
			//-------------------------------------------------------------------
			// Recupera o período de extração da fato. 
			//-------------------------------------------------------------------			  
			If ! ( (cTemp)->( Eof() ) )
				If ( (cTemp)->HJJ_INFPER == "T" ) .And. !( Empty( (cTemp)->HJJ_PERINI ) ) .And. !( Empty( (cTemp)->HJJ_PERFIN ) )
					cDateFrom 	:= (cTemp)->HJJ_PERINI
					cDateTo		:= (cTemp)->HJJ_PERFIN
					lHistory 	:= .T. 
				Endif 	
			EndIf
			
			//-------------------------------------------------------------------
			// Fecha o alias temporário. 
			//-------------------------------------------------------------------				
			(cTemp)->( DBCloseArea() )			
			BIXUnLinkFSD()
		EndIf
		
		If ! ( lHistory )
			//-------------------------------------------------------------------
			// Identifica se tem perfil de extração. 
			//-------------------------------------------------------------------
			If ( BIXHasProfile( aParameter ) ) 
				If ( HRC->( DBSeek( Padr( AllTrim( aParameter[4] ), 6 ) ) ) ) 
			 		aFact 		:= aBIToken( HRC->HRC_FACT, "|" )
			 		nFact		:= aScan( aFact, {|x| x == AllTrim( cFact ) } )      
			 		
					//-------------------------------------------------------------------
					// Verifica se a fato foi incluída no profile. 
					//-------------------------------------------------------------------
					If ( nFact > 0 )   
						//-------------------------------------------------------------------
						// Recupera o intervalo da tabela adicional. 
						//------------------------------------------------------------------- 
		 				If ( HRB->( DBSeek( HRC->HRC_ID + aFact[nFact] ) ) )   
		 					cFrom	:= AllTrim( HRB->HRB_INITIA )
		 					cTo  	:= AllTrim( HRB->HRB_FINAL )
		 				EndIf 
			
						//-------------------------------------------------------------------
						// Verifica se o intervalo é definido por expressão. 
						//-------------------------------------------------------------------			
					 	If ( ( ! ( Empty( cFrom ) ) .And. ! ( Empty( cTo ) ) ) ) 
					   		cDateFrom 	:= BIXEvalDate( cFrom, .T. ) 					   						 	 
					 	   	cDateTo	 	:= BIXEvalDate( cTo, .T. )  
			
							//-------------------------------------------------------------------
							// Verifica a ordem cronológica do intervalo. 
							//-------------------------------------------------------------------		
							If ( Empty( cFrom ) ) .Or. ( Empty( cTo ) ) .Or. ( cFrom > cTo )
								cDateFrom	:= aParameter[1]
						 		cDateTo		:= aParameter[2]	
						 	Else 
						 		BIXSysOut("BIXPROFILE", STR0029 + AllTrim( HRC->HRC_TITLE ) + STR0030 + DToC( SToD( cDateFrom ) )  + STR0031 + DToC( SToD( cDateTo ) ) ) //"O intervalo do perfil ["###"] para extração da fato é de "###" até "
							EndIf 	
					 	EndIf			
					EndIf 	
			 	EndIf   
			EndIf  
			
			//-------------------------------------------------------------------
			// Fecha a área de trabalho temporária. 
			//-------------------------------------------------------------------			
			If ! ( Select( cTemp ) == 0 )
				(cTemp)->( DBCloseArea() )
			EndIf
		Endif 
	EndIf	
	
	aAdd( aPeriod, cDateFrom ) 
	aAdd( aPeriod, cDateTo ) 
Return aPeriod  

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetProfile
Retorna a relação de área X fato x dimensão de acordo com os valores
do perfil de extração.    
            
@param aParameter, array, Array obtido pela função BIXGetParms
@return aProfile, array, Relação de área X fato x dimensão. 

@author  Valdiney V GOMES
@since   11/11/2013
/*/
//-------------------------------------------------------------------
Function BIXGetProfile( aParameter ) 
	Local aProfile		:= {}
	Local aAreas		:= {} 
	Local aFact			:= {}
	Local aDimension	:= {}
	Local cApps     	:= ""
	Local cFacts      	:= ""
	Local cDimensions	:= ""  
	Local nArea			:= 1
	Local nFact			:= 1
	Local nDimension	:= 1  
	Local nProfile		:= 1
	
	If ( BIXHasProfile( aParameters ) )
		If ( HRC->( DBSeek( Padr( AllTrim( aParameters[4] ), 6 ) ) ) )  
	 		cApps			:= HRC->HRC_AREA
	 		cFacts	   		:= HRC->HRC_FACT 
	 		cDimensions		:= HRC->HRC_DIMEN  
	
	 		//-------------------------------------------------------------------
			// Lista as áreas. 
			//-------------------------------------------------------------------  
			aAreas := aBIToken( cApps, "|", .F.)		
	    	
	      	For nArea := 1 To Len( aAreas )  
	      		aAdd( aProfile, { aAreas[nArea], {} } )  
	      	Next nArea	
	
	 		//-------------------------------------------------------------------
			// Lista as fatos. 
			//-------------------------------------------------------------------   
	      	For nProfile := 1 To Len( aProfile )
	      	   	aFact := BIXGetRelation( aProfile[nProfile][1], AREA, FACT )	
	       	
		      	For nFact := 1 To Len( aFact ) 
		      		If (  aFact[nFact] $ cFacts )
		      	 		aAdd( aProfile[nProfile][2], { aFact[nFact], {} } )   
		      	 	EndIf
		      	Next nFact 	
	      	Next nProfile
	      	
	 		//-------------------------------------------------------------------
			// Lista as dimensões. 
			//-------------------------------------------------------------------        
	       	For nProfile := 1 To Len( aProfile )
		      	For nFact := 1 To Len( aProfile[nProfile][2] ) 
					aDimension := BIXGetRelation( aProfile[nProfile][2][nFact][1], FACT, DIMENSION )            
	         		
		    		For nDimension := 1 To Len( aDimension ) 
			      		If (  aDimension[nDimension] $ cDimensions )
			      	 		aAdd( aProfile[nProfile][2][nFact][2], aDimension[nDimension] )   
			      	 	EndIf
			      	Next nDimension 
		      	Next nFact 	
	   		Next nProfile 		
	   	EndIf     
	EndIf 
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//------------------------------------------------------------------- 
	aSize(aAreas, 0)
	aSize(aFact, 0)
	aSize(aDimension, 0)
	aAreas := Nil
	aFact := Nil
	aDimension := Nil
	
Return aProfile  

//---------------------------------------------------------------------------------
/*/{Protheus.doc} BIXMarkAll
Marca/Desmarca Todas as áreas. 

@param aApp, array, lista de apps. 

@author  Valdiney V GOMES
@since   17/10/2014       	
/*/
//---------------------------------------------------------------------------------
Static Function BIXMarkAll( aApp ) 
	Local nApp 		:= 0
	Local lMarked	:= .F.
	
	Default aApp	:= {}
	
	lMarked := ! ( aScan( aApp, {|x| x[1] == .T. } ) == 0 )
	
	For nApp := 1 To Len( aApp )
		aApp[nApp][1] := !lMarked
	Next nApp
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAppMark
Checkbox para desmarcar toda as opções da Dimensões.

@param oPanel, objeto, Carrega as informações da tela que ficará o botão. 
@param oView, objeto, Interface do perfil de extração.

@author  Daniele Lemos
@since   28/10/2015
/*/
//-------------------------------------------------------------------
Static Function  BIXAppMark( oPanel, oView )
	Local oModel		:= nil
	Local oModelApp		:= nil
	Local oFont			:= nil
	Local oMark			:= nil
	Local nOperation 	:= 0
	Local aApp 			:= {}
	Local nEntity		:= 0
	Local lCheck		:= .T.
	
	oModel		:= FWModelActive()
	oModelApp	:= oModel:GetModel("MODEL_AREA")
	nOperation 	:= oModel:GetOperation()

	If ( nOperation == MODEL_OPERATION_INSERT )
		lCheck := .T.
	Else
		//-------------------------------------------------------------------
		// Verifica se há alguma área selecionada.
		//-------------------------------------------------------------------
		For nEntity := 1 To oModelApp:Length()
			oModelApp:GoLine(nEntity)
			Aadd(aApp, oModelApp:GetValue("AREA_MARK"))
		Next nEntity
		
		If (Ascan(aApp,.F.)) != 0
			lCheck := .F.
		EndIf
	EndIf
	
	//-------------------------------------------------------------------
	// Cria botão para para desmarcar as Dimensões
	//-------------------------------------------------------------------
	DEFINE FONT oFont NAME "ARIAL" SIZE 0,-10 BOLD
	oPanel:Align := CONTROL_ALIGN_LEFT
	@02,03 CheckBox oMark Var lCheck Prompt STR0066 Size 60,9 On Change BIXMarkAction( lCheck, oView ) Pixel Of oPanel //Marcar / Desmarcar - STR0066
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMarkAction
Checkbox para marcar e desmarcar toda as opções das áreas.

@param lCheck, lógico, Identifica se o checkBox de Marcar/Desmarcar foi selecionado. 

@author  Daniele Lemos
@since   28/10/2015
/*/
//-------------------------------------------------------------------
Static Function BIXMarkAction( lCheck, oView )
	Local oModel			:= nil
	Local oModelArea		:= nil
	Local oModelFact		:= nil
	Local oModelDimension 	:= nil
	Local nArea				:= 0
	Local nFact				:= 0
	Local nDimension		:= 0
	Local lMark				:= .F.
	
	Default lCheck			:= .F. 
	Default oView			:= nil
	
	oModel			:= FWModelActive()
	oModelArea		:= oModel:GetModel("MODEL_AREA")	
	oModelFact		:= oModel:GetModel("MODEL_FACT")
	oModelDimension := oModel:GetModel( "MODEL_DIMENSION" )
			
	For nArea := 1 To oModelArea:Length()		
		oModelArea:GoLine(nArea)
			
		//-------------------------------------------------------------------
		// Validação do checkbox, se está selecionado
		//-------------------------------------------------------------------
		If  lCheck == .F. .And. ( oModelArea:GetValue("AREA_MARK") ) == .T.
			oModelArea:LoadValue( "AREA_MARK", lMark  )
		Else 
			If  lCheck == .T. .And. ( oModelArea:GetValue("AREA_MARK") ) == .F.
				lMark := .T.
				oModelArea:LoadValue( "AREA_MARK", lMark  )
			EndIf
		EndIf
	Next nArea
	
	For nFact := 1 To oModelFact:Length() 
		oModelFact:GoLine(nFact)
			
		//-------------------------------------------------------------------
		// Validação do checkbox, se está selecionado
		//-------------------------------------------------------------------
		If  lCheck == .T. .And. ( oModelArea:GetValue("AREA_MARK") ) == .F. .Or. ( lCheck == .F. .And. ( oModelArea:GetValue("AREA_MARK") ) == .F. )
			oModelFact:LoadValue( "FACT_MARK", lMark  )
		Else
			If  lCheck == .T. .And. ( oModelArea:GetValue("AREA_MARK") ) == .T.
				lMark := .T.	
				oModelFact:LoadValue( "FACT_MARK", lMark  )
			EndIf
		EndIf
	Next nFact
		
	For nDimension := 1 To oModelDimension:Length()		
		oModelDimension:GoLine( nDimension )
			
		//-------------------------------------------------------------------
		// Validação do checkbox, se está selecionado
		//-------------------------------------------------------------------
		If  lCheck == .T. .And. ( oModelArea:GetValue("AREA_MARK") ) == .F. .Or. ( lCheck == .F. .And. ( oModelArea:GetValue("AREA_MARK") ) == .F. )
			oModelDimension:LoadValue( "DIMENSION_MARK", lMark  )
		Else
			If  lCheck == .T. .And. ( oModelArea:GetValue("AREA_MARK") ) == .T.
				lMark := .T.	
				oModelDimension:LoadValue( "DIMENSION_MARK", lMark  )
			EndIf
		EndIf
	Next nDimension
			
	//-------------------------------------------------------------------
	// Posiciona na primeira linha.
	//-------------------------------------------------------------------
	oModelDimension:GoLine( 1 )
	oModelArea:GoLine( 1 )
	oModelFact:GoLine( 1 )
	
	//-------------------------------------------------------------------
	// Atualiza a interface. 
	//------------------------------------------------------------------- 	
	oView:Refresh("VIEW_AREA")
	oView:Refresh("VIEW_FACT")
	oView:Refresh("VIEW_DIMENSION") 
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXConfigExec
Monta um formulário para receber a DATA DE e DATA ATÉ.

@author  Helio Leal
@since   03/10/2014
/*/
//-------------------------------------------------------------------
Function BIXConfigExec()
	Local oDialog		:= nil
	Local oDateFrom		:= nil
	Local oDateTo		:= nil
	Local oTop			:= nil
	Local oLayer		:= nil
	Local aEmpFil		:= {} 
	Local lMark			:= .F. 
	Local dDateFrom		:= nil
	Local dDateTo		:= nil
	Local bDblClick		:= nil
	Local bData			:= nil
	Local bHeaderClick	:= nil

	oLayer			:= FWLayer():New()
	dDateFrom		:= Date( )
	dDateTo			:= Date( )
	bDblClick		:= { || aEmpFil[oBrowse:nAt][1] := ! aEmpFil[oBrowse:nAt][1] }
	bData			:= { || If( aEmpFil[oBrowse:nAt][1],'LBOK','LBNO') }
	bHeaderClick	:= { || BIXMarkAll( aEmpFil ), oBrowse:Refresh() }

	//-------------------------------------------------------------------
	// Lista todas as empresas e filiais.
	//-------------------------------------------------------------------      
    SM0->( DBGoTop( ) )
    
    While SM0->( ! Eof() )
    	lMark := Alltrim( SM0->M0_CODIGO ) == Alltrim( cEmpAnt ) .And. Alltrim( SM0->M0_CODFIL ) == Alltrim( cFilAnt ) 
    	AAdd( aEmpFil, { lMark, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_FILIAL } )

     	SM0->(DbSkip())
    EndDo
 
	//-------------------------------------------------------------------
	// Monta o formulário.
	//-------------------------------------------------------------------                    
	DEFINE DIALOG oDialog TITLE STR0018 FROM 050, 150 TO 500,700 PIXEL //"Perfil de Extração"  
		//-------------------------------------------------------------------
		// Monta as sessões da tela. 
		//-------------------------------------------------------------------  
		oLayer:Init( oDialog )
		oLayer:addLine( "TOP"	, 30, .F.)
		oLayer:addLine( "BOTTOM", 70, .F.)
		oLayer:addCollumn( "TOP_ALL"	,100, .T. , "TOP")
		oLayer:addCollumn( "BOTTOM_ALL"	,100, .T. , "BOTTOM")
		oLayer:addWindow( "TOP_ALL"		, "TOP_WINDOW"		, STR0067, 100	, .F., .T.,, "TOP") //Período
		oLayer:addWindow( "BOTTOM_ALL"	, "BOTTOM_WINDOW"	, STR0060, 80	, .F., .T.,, "BOTTOM") //"Empresa e Filial"
		
		oTop 	:= oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" ) 
		oBottom := oLayer:getWinPanel( "BOTTOM_ALL", "BOTTOM_WINDOW", "BOTTOM" ) 

		//-------------------------------------------------------------------
		// Monta a lista de empresas e filiais. 
		//-------------------------------------------------------------------  	
		DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aEmpFil NO REPORT NO LOCATE NO CONFIG OF oBottom 
			//-------------------------------------------------------------------
			// Campo De.
			//-------------------------------------------------------------------
			@ 02,05 SAY STR0048 OF oTop PIXEL //"De"
			@ 10,05 MSGET oDateFrom VAR dDateFrom SIZE 125,10 OF oTop PIXEL PICTURE "@E 99/99/9999"
			
			//-------------------------------------------------------------------
			// Campo Até.
			//-------------------------------------------------------------------
			@ 02,140 SAY STR0049 OF oTop PIXEL //"Até"
			@ 10,140 MSGET oDateTo VAR dDateTo SIZE 125,10 OF oTop PIXEL PICTURE "@E 99/99/9999"
				
	    	//------------------------------------------------------------------- 
	        // Adiciona as colunas do Browse 
			//------------------------------------------------------------------- 
			ADD MARKCOLUMN oColumn DATA bData DOUBLECLICK bDblClick HEADERCLICK bHeaderClick OF oBrowse
	      	ADD COLUMN oColumn DATA {|| aEmpFil[oBrowse:nAt, 2] } TITLE STR0061 SIZE 02 OF oBrowse // "Empresa" 
	      	ADD COLUMN oColumn DATA {|| aEmpFil[oBrowse:nAt, 3] } TITLE STR0062 SIZE 12 OF oBrowse // "Filial" 
	      	ADD COLUMN oColumn DATA {|| aEmpFil[oBrowse:nAt, 4] } TITLE STR0063 SIZE 20 OF oBrowse // "Descrição" 
	      	
      	//------------------------------------------------------------------- 
      	// Ativa do Browse 
      	//------------------------------------------------------------------- 
      	ACTIVATE FWBROWSE oBrowse
	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { || If( BIXExecute( dDateFrom, dDateTo, aEmpFil ), oDialog:End(), ) }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. )
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXExecute
Executa a extração para o perfil selecionado.

@param dataDe, date, string no formato yyyymmdd.
@param dataAte, date, string no formato yyyymmdd.
@param aEmpFil, array, Lista de empresas e filiais.
@return lOk, Identifica se o processo foi iniciado. 

@author  Helio Leal
@since   03/10/2014
/*/
//-------------------------------------------------------------------
Static Function BIXExecute( dDateFrom, dDateTo, aEmpFil )
	Local aParameter	:= {} 
	Local cTaskID		:= ""
	Local nEmpFil		:= 0
	Local lOk			:= .F. 
	
	Default dDateFrom 	:= Date()
	Default dDateTo 	:= Date()
	Default aEmpFil		:= {}
		
	lOk := ( ! Empty( dDateFrom ) .And. ! Empty( dDateTo ) .And. ! aScan( aEmpFil, {|x| x[1] == .T. } ) == 0 )
		
	If ( lOk )
		//-------------------------------------------------------------------
		// Informa os parâmetros para extração. 
		//-------------------------------------------------------------------	
		cTaskID := "DUMMY" + DToS( Date() ) + Substr( Time(), 1, 5 )  

		//-------------------------------------------------------------------
		// Define os atributos da tarefa. 
		//-------------------------------------------------------------------	
		aAdd( aParameter, DToS( dDateFrom ) )
		aAdd( aParameter, DToS( dDateTo ) )
		aAdd( aParameter, "" )
		aAdd( aParameter, HRC->HRC_ID )

		//-------------------------------------------------------------------
		// Executa a extração em JOB.
		//-------------------------------------------------------------------
		For nEmpFil := 1 to Len( aEmpFil )
			If ( aEmpFil[nEmpFil][1] == .T. )
				BIExtractor( aParameter, cTaskID, aEmpFil[nEmpFil][2], aEmpFil[nEmpFil][3] ) 
			EndIf
		Next nEmpFil

		//-------------------------------------------------------------------
		// Verifica se o usuário deseja ou não acompanhar a extração em tempo real.
		//-------------------------------------------------------------------
		If ( MsgYesNo( STR0058, STR0045 ) ) // "Deseja acompanhar a extração em tempo real ?"###"Atenção"
			BIXLog()
		EndIf
	Else
		MsgAlert( STR0068 ) //"É necessário informar o período, empresa e filial para extração!"
	EndIf 
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} BIFDay
Retorna o primeiro dia do mês e ano solicitado. 
            
@param nMonth, numérico, Mês utilizado para definir a data.
@param nType, numérico,Tipo de retorno. Ver função Lastday.
@return dDate, Primeiro dia do mês. 

@author  Valdiney V GOMES
@since   08/09/2014
/*/
//-------------------------------------------------------------------
Function BIFDay( nMonth, nType )
	Local dDate		:= nil
	Local nYear 	:= 0
	Local cDate		:= ""

	Default nMonth 	:= Month( Date() )
	Default nType 	:= 0
	
	nYear := Year( Date() )

	Do Case
		Case (nMonth > 12)
			While( nMonth > 12 )
				nMonth := ( nMonth - 12 )
				nYear	:= 	nYear + 1
			Enddo
		Case (nMonth <= 0)
			While( nMonth <= 0 )
				nMonth := ( 12 + nMonth )
				nYear	:= 	nYear - 1
			Enddo
	EndCase

	//-------------------------------------------------------------------
	// Calcula o primeiro dia do mês.
	//------------------------------------------------------------------- 		
	cDate := cBIStr( nYear ) + StrZero( nMonth, 2 ) + "01"
	dDate := FirstDay( SToD( cDate ), nType )
Return dDate

//-------------------------------------------------------------------
/*/{Protheus.doc} BILDay
Retorna o último dia do mês e ano solicitado.   
            
@param nMonth, numérico, Mês utilizado para definir a data.
@param nType, numérico, Tipo de retorno. Ver função Lastday 
@return dDate, Último dia do mês. 

@author  Valdiney V GOMES
@since   08/09/2014
/*/
//-------------------------------------------------------------------
Function BILDay( nMonth, nType ) 
	Local dDate		:= nil
	Local nYear 	:= 0
	Local cDate		:= ""

	Default nMonth 	:= Month( Date() )
	Default nType 	:= 0
	
	nYear 	:= Year( Date() )

	Do Case
		Case (nMonth > 12)
			While( nMonth > 12 )
				nMonth := ( nMonth - 12 )
				nYear	:= 	nYear + 1
			Enddo
		Case (nMonth <= 0)
			While( nMonth <= 0 )
				nMonth := ( 12 + nMonth )
				nYear	:= 	nYear - 1
			Enddo
	EndCase

	//-------------------------------------------------------------------
	// Calcula o último dia do mês.
	//------------------------------------------------------------------- 		
	cDate := cBIStr( nYear ) + StrZero( nMonth, 2 ) + "01"
	dDate := LastDay( SToD( cDate ), nType )
Return dDate