#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXORCAM.CH"

REGISTER EXTRACTOR HLC

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOrcam
A tabela fato or�amento apresenta informa��es relativas aos lan�amentos
nas contas cont�beis relacionada a contabilidade or�ada. 

@author  BI TEAM
@since   03/11/2010
/*/
//-------------------------------------------------------------------
Class BIXOrcam from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   13/04/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXOrcam
	_Super:New( FACT, "HLC", STR0001, "CQ6", { CONTROLADORIA } ) //"Or�amento"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   13/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXOrcam
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o per�odo de extra��o para o primeio at� o 
	// �ltimo dia do m�s da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HLC_EMPRES",	"C", 32, 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HLC_ESTABL",	"C", 32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HLC_UNDNEG",	"C", 32, 00, .T., "HJ1" ) //"Unidade de Neg�cio"	
	oModel:AddField( "HLC_MOEDA" ,	"C", 32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HLC_CCUSTO",	"C", 32, 00, .T., "HJ5" ) //"Centro Custo"
	oModel:AddField( "HLC_CNTCTB",	"C", 32, 00, .T., "HJE" ) //"Conta Cont�bil"
	oModel:AddField( "HLC_PLCONT",	"C", 32, 00, .T., "HK5" ) //"Plano de Contas"
	oModel:AddField( "HLC_PLCCST",	"C", 32, 00, .T., "HKF" ) //"Plano Centro de Custo"	
	oModel:AddField( "HLC_CNARIO",	"C", 32, 00, .T., "HGZ" ) //"Cen�rio Or�ament�rio"
	oModel:AddField( "HLC_UNIORG",	"C", 32, 00, .T., "HQ8" ) //"Unidade Organizacional"
	oModel:AddField( "HLC_PROJET",	"C", 32, 00, .T., "HQ9" ) //"Projeto"
	oModel:AddField( "HLC_ITMCTB",	"C", 32, 00, .T., "HG9" ) //"Item Cont�bil"
	oModel:AddField( "HLC_CLVL",	"C", 32, 00, .T., "HG8" ) //"Classe Valor"	
	oModel:AddField( "HLC_CNORCA",	"C", 32, 00, .T., "HGY" ) //"Cen�rio Cont�bil"
	oModel:AddField( "HLC_UNORCA",	"C", 32, 00, .T., "HQ1" ) //"Unidade Or�ament�ria"
	oModel:AddField( "HLC_SQORCA",	"C", 32, 00, .T., "HQ6" ) //"Sequ�ncia Or�amento"
	oModel:AddField( "HLC_VSORCA",	"C", 32, 00, .T., "HQ7" ) //"Vers�o Or�amento"	
	oModel:AddField( "HLC_DATA"	 ,	"D", 08, 00, .F., "HK2" ) //"Per�odo"	

	oModel:AddField( "HLC_VORCAD",	"N", 16, 02 ) // "Valor Or�ado"
	oModel:AddField( "HLC_VEMPEN",	"N", 16, 02 ) // "Valor Empenhado"
	oModel:AddField( "HLC_VCTBRL",	"N", 16, 02 ) // "Valor Cont�bil Real"
	oModel:AddField( "HLC_VPREVI",	"N", 16, 02 ) // "Valor Saldo Previsto"

	oModel:FreeField()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 

@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oSeeker, objeto, Objeto para valida��o de integridade referencial.

@author  Helio Leal
@since   11/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXOrcam
	Local aMoeda  		 := {}
	Local aInterval  	 := {}
	Local aAccount		 := {}
	Local cMoeda		 := ""
	Local cFlow			 := ""
	Local nMoeda		 := 0
	Local nInterval 	 := 0

	//-------------------------------------------------------------------
	// Recupera os par�metros da fato.
	//-------------------------------------------------------------------
	aMoeda 	  	:= BIXGetMxF( ::cEntity )
	aInterval 	:= BIXInterval( cFrom, cTo )

	For nInterval := 1 To Len( aInterval ) 	
		//-------------------------------------------------------------------
		// Recupera os movimentos real, or�ado e empenhado das entidades cont�beis.
		//-------------------------------------------------------------------  	
		cFlow := BIXCtCntO( aInterval[nInterval][1], aInterval[nInterval][2] )
		
		//-------------------------------------------------------------------
		// Itera por todos os registros do fluxo principal. 
		//-------------------------------------------------------------------		     
		While ! (cFlow)->( Eof() )
			For nMoeda := 1 to Len(aMoeda)
				cMoeda := aMoeda[nMoeda][1]

				//-------------------------------------------------------------------
				// Inicializa o registro.
				//-------------------------------------------------------------------
				oRecord:Init()

				//-------------------------------------------------------------------
				// Customiza��o.
				//-------------------------------------------------------------------
				oRecord:SetValue( "CT1_CONTA"	, (cFlow)->CONTA )
				oRecord:SetValue( "CTT_CUSTO"	, (cFlow)->CUSTO )
				oRecord:SetValue( "CTH_CLVL"	, (cFlow)->CLVL )
				oRecord:SetValue( "CTD_ITEM"	, (cFlow)->ITEM )

				//-------------------------------------------------------------------
				// Lookups.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HLC_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
				oRecord:SetValue( "HLC_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HLC_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLC_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )          
				oRecord:SetValue( "HLC_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->CUSTO } ) )
				oRecord:SetValue( "HLC_CNTCTB"	, oSeeker:Seek( "HJE", { (cFlow)->CONTA } ) )
				oRecord:SetValue( "HLC_ITMCTB"	, oSeeker:Seek( "HG9", { (cFlow)->ITEM } ) )
				oRecord:SetValue( "HLC_CLVL"	, oSeeker:Seek( "HG8", { (cFlow)->CLVL } ) )
				oRecord:SetValue( "HLC_UNIORG"	, oSeeker:Seek( "HQ8", { FWGrpCompany( ) } ) )

				//-------------------------------------------------------------------
				// Entidades sem conceito.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HLC_PLCCST" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_PLCONT" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_CNARIO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_PROJET" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_CNORCA" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_UNORCA" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_SQORCA" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLC_VSORCA" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				
				//-------------------------------------------------------------------
				// Per�odo.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HLC_DATA"	, aInterval[nInterval][2]  )

				//-------------------------------------------------------------------
				// Indicadores.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HLC_VORCAD", BIXValue( (cFlow)->MOVORC	, "01", cMoeda, aInterval[nInterval][2] ) )
				oRecord:SetValue( "HLC_VEMPEN", BIXValue( (cFlow)->MOVEMP	, "01", cMoeda, aInterval[nInterval][2] ) )
				oRecord:SetValue( "HLC_VCTBRL", BIXValue( (cFlow)->MOVREAL	, "01", cMoeda, aInterval[nInterval][2] ) )		
				oRecord:SetValue( "HLC_VPREVI", BIXValue( (cFlow)->MOVPREV	, "01", cMoeda, aInterval[nInterval][2] ) )

				//-------------------------------------------------------------------
				// Envia o registro para o pool de grava��o. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nMoeda

			(cFlow)->( DBSkip() )   
		EndDo

		(cFlow)->( DBCloseArea() )

	 	//-------------------------------------------------------------------
		// Elimina os arquivos tempor�rios. 
		//-------------------------------------------------------------------
		BIXRunGC()
	Next nInterval

	//-------------------------------------------------------------------
	// Libera o pool de grava��o.
	//-------------------------------------------------------------------
	oOutput:Release()
Return