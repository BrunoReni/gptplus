#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONTAB.CH"

REGISTER EXTRACTOR HL9

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXContab
A tabela fato Contabilidade apresenta informações informações das contas
contábeis relacionadas à contabilidade realizada. 
 
@author  BI TEAM
@since   03/11/2010
/*/
//-------------------------------------------------------------------
Class BIXContab from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Helio Leal
@since   11/04/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXContab
	_Super:New( FACT, "HL9", STR0001, "CQ6", { CONTROLADORIA } ) //"Contabilidade"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   11/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXContab
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o período de extração para o primeio até o 
	// último dia do mês da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HL9_EMPRES",	"C", 32, 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HL9_ESTABL",	"C", 32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL9_UNDNEG",	"C", 32, 00, .T., "HJ1" ) //"Unidade de Negócio"	
	oModel:AddField( "HL9_MOEDA" ,	"C", 32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL9_CCUSTO",	"C", 32, 00, .T., "HJ5" ) //"Centro Custo"
	oModel:AddField( "HL9_CNTCTB",	"C", 32, 00, .T., "HJE" ) //"Conta Contábil"
	oModel:AddField( "HL9_PLCONT",	"C", 32, 00, .T., "HK5" ) //"Plano de Contas"
	oModel:AddField( "HL9_PLCCST",	"C", 32, 00, .T., "HKF" ) //"Plano Centro de Custo"	
	oModel:AddField( "HL9_CNARIO",	"C", 32, 00, .T., "HGY" ) //"Cenário Contábil"
	oModel:AddField( "HL9_UNIORG",	"C", 32, 00, .T., "HQ8" ) //"Unidade Organizacional"
	oModel:AddField( "HL9_PROJET",	"C", 32, 00, .T., "HQ9" ) //"Projeto"
	oModel:AddField( "HL9_ITMCTB",	"C", 32, 00, .T., "HG9" ) //"Item Contábil"
	oModel:AddField( "HL9_CLVL",	"C", 32, 00, .T., "HG8" ) //"Classe Valor"
	oModel:AddField( "HL9_DATA"	 ,	"D", 08, 00, .F., "HK2" ) //"Período"	

	oModel:AddField( "HL9_VCTBRL",	"N", 16, 02 ) // "Valor Movimento Contábil Real"
	oModel:AddField( "HL9_VSDINI",	"N", 16, 02 ) // "Valor Saldo Inicial"
	oModel:AddField( "HL9_VDREAL",	"N", 16, 02 ) // "Valor Débito Real"
	oModel:AddField( "HL9_VCREAL",	"N", 16, 02 ) // "Valor Crédito Real"
	oModel:AddField( "HL9_VSDFIN",	"N", 16, 02 ) // "Valor Saldo"
	oModel:AddField( "HL9_VAPURA",	"N", 16, 02 ) // "Valor Apuração"

	oModel:FreeField()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para validação de integridade referencial.

@author  Helio Leal
@since   11/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXContab
	Local aMoeda 	:= {}
	Local aInterval := {}
	Local aAccount	:= {}	
	Local cMoeda	:= ""
	Local cAccount	:= ""
	Local cNormal 	:= ""
	Local cFlow		:= ""
	Local lBloqued	:= .F.
	Local nMoeda	:= 0
	Local nInterval := 0

   	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	  	:= BIXGetMxF( ::cEntity )
	aInterval 	:= BIXInterval( cFrom, cTo )
	lBloqued 	:= BIXParInfo( "BIX_CONTBL"	, "L", .F. )
   	cAccount	:= BIXParInfo( "CNTRESULT"	, "C", "", ::cEntity )

	//-------------------------------------------------------------------
	// Recupera as contas de apuração de resultado do wizard.  
	//-------------------------------------------------------------------
	aAccount 	:= aBIToken( cAccount, ";", .F.)
	
	For nInterval := 1 To Len( aInterval ) 	
		//-------------------------------------------------------------------
		// Recupera os saldos e movimentos das entidades contábeis.
		//-------------------------------------------------------------------  
		cFlow := BIXCtCnt( aInterval[nInterval][1], aInterval[nInterval][2] )	
		
		//-------------------------------------------------------------------
		// Itera por todos os registros do fluxo principal. 
		//------------------------------------------------------------------- 
		While ! (cFlow)->( EoF() )
			cNormal	  := ""

			If ( CT1->( MsSeek( xFilial("CT1") + (cFlow)->CONTA ) ) )
				//----------------------------------------------------------
				// Verifica se não é para considerar contas bloqueadas.
				//----------------------------------------------------------			
				If !( lBloqued )
					//----------------------------------------------------------
					// Verifica se a conta está bloqueada. 
					//----------------------------------------------------------
					If ( CT1->CT1_BLOQ == "1" )
						(cFlow)->( DBSkip() )
						Loop
					EndIf
				EndIf
				cNormal := CT1->CT1_NORMAL
			EndIf

			For nMoeda := 1 To Len(aMoeda)
				cMoeda := aMoeda[nMoeda][1]

				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 				
				oRecord:Init()
				
				//-------------------------------------------------------------------
				// Customização.
				//-------------------------------------------------------------------
				oRecord:SetValue( "CT1_CONTA"	, (cFlow)->CONTA )
				oRecord:SetValue( "CTT_CUSTO"	, (cFlow)->CUSTO )
				oRecord:SetValue( "CTH_CLVL"	, (cFlow)->CLVL )
				oRecord:SetValue( "CTD_ITEM"	, (cFlow)->ITEM )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HL9_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HL9_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
				oRecord:SetValue( "HL9_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HL9_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )          
				oRecord:SetValue( "HL9_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->CUSTO } ) )
				oRecord:SetValue( "HL9_CNTCTB"	, oSeeker:Seek( "HJE", { (cFlow)->CONTA } ) )
				oRecord:SetValue( "HL9_ITMCTB"	, oSeeker:Seek( "HG9", { (cFlow)->ITEM } ) )
				oRecord:SetValue( "HL9_CLVL"	, oSeeker:Seek( "HG8", { (cFlow)->CLVL } ) )
				oRecord:SetValue( "HL9_UNIORG"	, oSeeker:Seek( "HQ8", { FWGrpCompany() } ) )
				oRecord:SetValue( "HL9_PLCCST" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
				oRecord:SetValue( "HL9_PLCONT" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
				oRecord:SetValue( "HL9_CNARIO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
				oRecord:SetValue( "HL9_PROJET" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
				oRecord:SetValue( "HL9_DATA"	, aInterval[nInterval][2]  )
				
				//-------------------------------------------------------------------
				// Indicadores.
				//-------------------------------------------------------------------
				If cPaisLoc == "BRA"
					oRecord:SetValue( "HL9_VCTBRL"	, BIXValue( (cFlow)->MOV		, "01" , cMoeda , aInterval[nInterval][2] ) )
					oRecord:SetValue( "HL9_VSDINI"	, BIXValue( (cFlow)->ANTSLD 	, "01" , cMoeda , aInterval[nInterval][2] ) )
					oRecord:SetValue( "HL9_VSDFIN"	, BIXValue( (cFlow)->ATUSLD 	, "01" , cMoeda , aInterval[nInterval][2] ) )
				Else
					oRecord:SetValue( "HL9_VCTBRL"	, BIXGetCTBValue( ValorCTB( BIXValue( (cFlow)->MOV		, "01" , cMoeda , aInterval[nInterval][2] ), 0, 0, 20, , .T., "", cNormal,,, , "N",, .T., .F. ) ) )
					oRecord:SetValue( "HL9_VSDINI"	, BIXGetCTBValue( ValorCTB( BIXValue( (cFlow)->ANTSLD 	, "01" , cMoeda , aInterval[nInterval][2] ), 0, 0, 20, , .T., "", cNormal,,, , "N",, .T., .F. ) ) )
					oRecord:SetValue( "HL9_VSDFIN"	, BIXGetCTBValue( ValorCTB( BIXValue( (cFlow)->ATUSLD 	, "01" , cMoeda , aInterval[nInterval][2] ), 0, 0, 20, , .T., "", cNormal,,, , "N",, .T., .F. ) ) )
				
				EndIf
				
				oRecord:SetValue( "HL9_VDREAL"	, BIXValue( (cFlow)->DEB	, "01", cMoeda, aInterval[nInterval][2] ) )
				oRecord:SetValue( "HL9_VCREAL"	, BIXValue( (cFlow)->CRD	, "01", cMoeda, aInterval[nInterval][2] ) )

				//-------------------------------------------------------------------
				// Grava o Vl Apuração Resultado. 
				//-------------------------------------------------------------------  
				If ! ( Ascan( aAccount, AllTrim( (cFlow)->CONTA ) ) == 0 )
					oRecord:SetValue( "HL9_VAPURA"	, (cFlow)->MOV )
				Else
					oRecord:SetValue( "HL9_VAPURA"	, 0 )
				EndIf
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nMoeda
	
			(cFlow)->( DBSkip() )    
		EndDo
		
		(cFlow)->( DBCloseArea() )
		
		//-------------------------------------------------------------------
		// Elimina os arquivos temporários. 
		//-------------------------------------------------------------------   
	   	BIXRunGC() 
	Next nInterval

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return nil