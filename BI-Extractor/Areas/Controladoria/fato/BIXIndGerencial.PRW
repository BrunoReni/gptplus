#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXINDGERENCIAL.CH"

REGISTER EXTRACTOR HLA

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXIndGerencial
A tabela fato Indicadores Gerenciais apresenta informa��es de diversos 
indicadores econ�micos e financeiros relaciondos a gest�o da empresa.
 
@author  Helio Leal
@since   12/04/2017
/*/
//-------------------------------------------------------------------
Class BIXIndGerencial from BIXEntity
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
@since   06/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXIndGerencial
	_Super:New( FACT, "HLA", STR0001, "CQ6", { CONTROLADORIA } ) //"Indicadores Gerenciais"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   06/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXIndGerencial 
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o per�odo de extra��o para o primeio at� o 
	// �ltimo dia do m�s da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HLA_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HLA_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"	
	oModel:AddField( "HLA_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Neg�cio"	
	oModel:AddField( "HLA_MOEDA" ,	"C", 	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HLA_PLCONT",	"C", 	32, 00, .T., "HK5" ) //"Plano de Contas"
	oModel:AddField( "HLA_CNARIO",	"C", 	32, 00, .T., "HGY" ) //"Cen�rio Cont�bil"
	oModel:AddField( "HLA_UNIORG",	"C", 	32, 00, .T., "HQ8" ) //"Unidade Organizacional"
	oModel:AddField( "HLA_PROJET",	"C", 	32, 00, .T., "HQ9" ) //"Projeto"
	oModel:AddField( "HLA_DATA"	 ,	"D", 	08, 00, .F., "HK2" ) //"Per�odo"

	oModel:AddField( "HLA_INDICA",	"C", 08, 00 ) // "Indicador"
	oModel:AddField( "HLA_VRLMES",	"N", 16, 02 ) // "Valor Realizado Mensal"
	oModel:AddField( "HLA_VRLMSA",	"N", 16, 02 ) // "Valor Acumulado"
	oModel:AddField( "HLA_MESREF",	"N", 04, 00 ) // "M�s Refer�ncia"
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
@since   12/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXIndGerencial
	Local aMoeda 	:= {}
	Local aInterval := {}
	Local aAccount	:= {} 
	Local nInterval := 0
	Local nAccount	:= 0
	Local nMoeda	:= 0
	Local cFlow		:= ""
	Local cBook		:= ""
	Local cMoeda	:= ""
	Local lMoeda	:= .T.

	//-------------------------------------------------------------------
	// Recupera os par�metros da fato.
	//-------------------------------------------------------------------
	aMoeda 		:= BIXGetMxF( ::cEntity )
	aInterval 	:= BIXInterval( cFrom, cTo )
	lMoeda		:= BIXExistMoedaCtb()
	cBook 		:= BIXBookLoad() // Recupera o livro informado no wizard.
	aAccount 	:= BIXLoadCtaGer() // Recupera as contas gerenciais informadas no wizard.

	//-------------------------------------------------------------------
	// Verifica se existe moeda cont�bil cadastrada para que n�o ocorra
	// erro durante o processo da fato, caso a moeda cont�bil n�o seja 
	// encontrada, n�o executa o processamento dos dados. 
	//-------------------------------------------------------------------
	If ( lMoeda )
		If ! ( Empty( cBook ) .Or. Len( aAccount ) == 0 )
			For nInterval := 1 To Len( aInterval ) 
				//-------------------------------------------------------------------
				// Recupera os saldos e movimentos das contas gerenciais do m�s. 
				//-------------------------------------------------------------------  			
				cFlow := BIXCtGerInd( cBook, aInterval[nInterval][1], aInterval[nInterval][2] )
	
				//-------------------------------------------------------------------
				// Itera por todos os registros do fluxo principal.
				//-------------------------------------------------------------------
				While ! (cFlow)->( Eof() )
					//-------------------------------------------------------------------
					// Verifica se a conta foi selecionada.
					//-------------------------------------------------------------------
					nAccount := aScan( aAccount, { |x| x[3] == (cFlow)->CONTA } )

					If ! ( nAccount == 0 )
						For nMoeda := 1 To Len(aMoeda)
							cMoeda := aMoeda[nMoeda][1]

							//-------------------------------------------------------------------
							// Inicializa o registro.
							//-------------------------------------------------------------------
							oRecord:Init()

							//-------------------------------------------------------------------
							// Lookups.
							//-------------------------------------------------------------------
							oRecord:SetValue( "HLA_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
							oRecord:SetValue( "HLA_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
							oRecord:SetValue( "HLA_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
							oRecord:SetValue( "HLA_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
							oRecord:SetValue( "HLA_UNIORG"	, oSeeker:Seek( "HQ8", { FWGrpCompany() } ) )
							oRecord:SetValue( "HLA_PLCONT" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
							oRecord:SetValue( "HLA_CNARIO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
							oRecord:SetValue( "HLA_PROJET" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) // Para entidades sem conceito.
							oRecord:SetValue( "HLA_DATA"	, aInterval[nInterval][2]  )
							oRecord:SetValue( "HLA_INDICA"	, aAccount[nAccount][1] )

							//-------------------------------------------------------------------
							// Indicadores.
							//-------------------------------------------------------------------
							oRecord:SetValue( "HLA_VRLMES", BIXValue( (cFlow)->MOVIMENTO, "1", cMoeda, aInterval[nInterval][2] ) )
							oRecord:SetValue( "HLA_VRLMSA", BIXValue( (cFlow)->SALDOATU	, "1", cMoeda, aInterval[nInterval][2] ) )
							oRecord:SetValue( "HLA_MESREF", Month( aInterval[nInterval][2] ) )

							//-------------------------------------------------------------------
							// Envia o registro para o pool de grava��o.
							//-------------------------------------------------------------------
							oOutput:Send( oRecord )
						Next nMoeda
					EndIf
		
					(cFlow)->( DBSkip() )
				EndDo

				(cFlow)->( DBCloseArea() )
			Next nInterval
		Else
			BIXSysOut( "BIXINDGERENCIAL", STR0002, ERROR ) //"Aten��o: algum dos par�metros necess�rios para extra��o do Indicador Gerencial n�o foi informado corretamente. V� at� o ambiente Configurador (SIGACFG) e acesse o menu Ambiente / Extrator B.I. / Config. Par�metros para informar estes par�metros."
		EndIf
	EndIf

	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return