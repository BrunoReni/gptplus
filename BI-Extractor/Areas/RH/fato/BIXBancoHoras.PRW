#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXBANCOHORAS.CH"

REGISTER EXTRACTOR HLO

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBancoHoras
Apresenta informações de quantidade e valores do banco de horas dos 
colaboradores.

@author  BI TEAM
@since   31/08/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXBancoHoras from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   28/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXBancoHoras
	_Super:New( FACT, "HLO", STR0001, "SPI", { RH } ) //"Banco de Horas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXBancoHoras
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLO_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLO_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLO_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLO_SINDIC", "C", 32, 0, .T., "HJV" )
	oModel:AddField( "HLO_TURNO", "C", 32, 0, .T. , "HJU" )
	oModel:AddField( "HLO_TIPMOB", "C", 32, 0, .T., "HJQ" )
	oModel:AddField( "HLO_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLO_COLABR", "C", 32, 0, .T., "HJM" )
	oModel:AddField( "HLO_FXASAL", "C", 32, 0, .T., "HKG" )
	oModel:AddField( "HLO_MOEDA", "C", 32, 0, .T. , "HJ6" )
	oModel:AddField( "HLO_TIPHRS", "C", 32, 0, .T., "HJI" )
	oModel:AddField( "HLO_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLO_CATSAL", "C", 32, 0, .T., "HJT" )
	oModel:AddField( "HLO_CARGO", "C", 32, 0, .T. , "HJP" )
	oModel:AddField( "HLO_NIVHIE", "C", 32, 0, .T., "HG5" )
	oModel:AddField( "HLO_ESTCIV", "C", 32, 0, .T., "HKE" )
	oModel:AddField( "HLO_FXAETA", "C", 32, 0, .T., "HK8" )
	oModel:AddField( "HLO_GRAINS", "C", 32, 0, .T., "HK9" )
	oModel:AddField( "HLO_TPCASA", "C", 32, 0, .T., "HKH" )
	oModel:AddField( "HLO_TPCARG", "C", 32, 0, .T., "HKI" )
	oModel:AddField( "HLO_RELTRB", "C", 32, 0, .T., "HKD" )
	oModel:AddField( "HLO_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLO_SECAO", "C", 32, 0, .T. , "HQ0" )
	oModel:AddField( "HLO_LOCALI", "C", 32, 0, .T., "HQO" )
	oModel:AddField( "HLO_PRESRV", "C", 32, 0, .T., "HQQ" )
	oModel:AddField( "HLO_PLOTAC", "C", 32, 0, .T., "HQP" )
	oModel:AddField( "HLO_ULOTAC", "C", 32, 0, .T., "HQT" )
	oModel:AddField( "HLO_DATA", "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HLO_QBCOHR", "N", 16,	4 )
	oModel:AddField( "HLO_VBCOHR", "N", 16,	2 )

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

@author  Marcia Junko
@since   28/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXBancoHoras
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local aFXSal 	:= {}	
	Local aFXEta 	:= {}
	Local aTpCasa 	:= {}
	Local aTpCarg 	:= {}	 
	Local lFindSRJ	:= .F.
	Local cFilter	:= ""                    
	Local cMoeda	:= ""
	Local nInd      := 1
	Local nVlrHora	:= 0

	aMoedas := BIXGetMxF(::cEntity )
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SPI")    // Banco de horas	
	SPI->( dbSetOrder(2) ) // Filial + PI_MAT + Dtos(PI_DATA) + PI_PD
	
	cFilter := " PI_FILIAL = '" + xFilial("SPI") + "'"
	cFilter += " .AND. PI_DATA >= STOD('" + cFrom + "') "
	cFilter += " .AND. PI_DATA <= STOD('" + cTo + "') "

	SPI->( DBSetFilter ( &("{|| " + cFilter + "}"), cFilter) )
	SPI->( dbGoTop() )

	DbSelectArea("SRA")         // Funcionarios
	SRA->( dbSetOrder(1) ) // Filial + RA_MAT

	DbSelectArea("SP9")         // Eventos
	SP9->( dbSetOrder(1) ) // Filial + P9_CODIGO

	DbSelectArea("SRJ")         // Tranferencias	
	SRJ->( dbSetOrder(1) ) // Filial + RJ_FUNCAO

	aFXSal := aBIToken( BIXParInfo( "FXSALA", "C", "" ), ";", .F. )	
	aFXEta := aBIToken( BIXParInfo( "FXAETA", "C", "" ), ";", .F. )
	aTpCasa := aBIToken( BIXParInfo( "TPCASA", "C", "" ), ";", .F. )
	aTpCarg := aBIToken( BIXParInfo( "TPCARG", "C", "" ), ";", .F. )	
	
	While SPI->(! Eof() )
		nVlrHora := 0
		lFindSRJ := .F.
		
		If SRA->( MsSeek( xFilial("SRA") + SPI->PI_MAT ) ) .And. SP9->( MsSeek( xFilial("SP9") + SPI->PI_PD  ) ) .And. Empty(SPI->PI_DTBAIX)
			If SRA->RA_CATFUNC == "S"
				nVlrHora := (SRA->RA_SALARIO / SRA->RA_HRSEMAN)			
			Else
				nVlrHora := (SRA->RA_SALARIO / SRA->RA_HRSMES)
			EndIf

			// Dimensão Mão de Obra
			If SRJ->( MsSeek( xFilial("SRJ") + SPI->PI_CODFUNC) ) .And. !Empty(SRJ->RJ_MAOBRA)
				lFindSRJ := .T.
			Endif
			
			For nInd := 1 To Len(aMoedas)
				cMoeda := aMoedas[nInd][1]

				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 				
				oRecord:Init()
				
				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "PI_MAT"     , SPI->PI_MAT )
				oRecord:SetValue( "P1_PD"      , SPI->PI_PD )
				oRecord:SetValue( "PI_DATA"    , SPI->PI_DATA )
				oRecord:SetValue( "RCE_CODIGO" , SRA->RA_SINDICA )
				oRecord:SetValue( "R6_TURNO"   , SRA->RA_TNOTRAB )
				oRecord:SetValue( "CTT_CUSTO"  , SPI->PI_CC ) 
				oRecord:SetValue( "RJ_FUNCAO"  , SRA->RA_CODFUNC )
				oRecord:SetValue( "RA_MAT"     , SPI->PI_MAT )
				oRecord:SetValue( "QB_DEPTO"   , SRA->RA_DEPTO )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLO_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HLO_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLO_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HLO_SINDIC", oSeeker:Seek( "HJV", { SRA->RA_SINDICA } ) ) 
				oRecord:SetValue( "HLO_TURNO" , oSeeker:Seek( "HJU", { SRA->RA_TNOTRAB } ) ) 
				oRecord:SetValue( "HLO_CCUSTO", oSeeker:Seek( "HJ5", { SPI->PI_CC } ) ) 
				oRecord:SetValue( "HLO_COLABR", oSeeker:Seek( "HJM", { SPI->PI_MAT } ) ) 
				oRecord:SetValue( "HLO_FXASAL", oSeeker:Seek( "HKG", { BIXParGetFaixa( "FXSALA", SRA->RA_SALARIO, @aFxSal ) } ) ) 
				oRecord:SetValue( "HLO_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
				oRecord:SetValue( "HLO_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SRA->RA_NATURAL ) } ) ) 
				oRecord:SetValue( "HLO_CATSAL", oSeeker:Seek( "HJT", { SRA->RA_CATFUNC } ) ) 
				oRecord:SetValue( "HLO_CARGO" , oSeeker:Seek( "HJP", { SRA->RA_CODFUNC } ) ) 
				oRecord:SetValue( "HLO_ESTCIV", oSeeker:Seek( "HKE", { SRA->RA_ESTCIVI } ) ) 
				oRecord:SetValue( "HLO_FXAETA", oSeeker:Seek( "HK8", { BIXParGetFaixa( "FXAETA", DateDiffYMD(SRA->RA_NASC, SPI->PI_DATA)[1], @aFxEta ) } ) ) 
				oRecord:SetValue( "HLO_GRAINS", oSeeker:Seek( "HK9", { SRA->RA_GRINRAI } ) ) 
				oRecord:SetValue( "HLO_TPCASA", oSeeker:Seek( "HKH", { BIXParGetFaixa( "TPCASA", DateDiffYMD(SRA->RA_ADMISSA, SPI->PI_DATA)[1], @aTpCasa ) } ) ) 
				oRecord:SetValue( "HLO_TPCARG", oSeeker:Seek( "HKI", { BIXParGetFaixa( "TPCARG", BIXRetTPCARG(SRA->RA_MAT, SPI->PI_DATA), @aTpcarg )  } ) ) 
				oRecord:SetValue( "HLO_RELTRB", oSeeker:Seek( "HKD", { SRA->RA_TIPOADM } ) ) 
				oRecord:SetValue( "HLO_SECAO" , oSeeker:Seek( "HQ0", { SRA->RA_DEPTO } ) ) 
				oRecord:SetValue( "HLO_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLO_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLO_LOCALI", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLO_PRESRV", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLO_PLOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLO_ULOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				
				If lFindSRJ
					oRecord:SetValue( "HLO_TIPMOB", oSeeker:Seek( "HJQ", { SRJ->RJ_MAOBRA } ) )  
				Else
					oRecord:SetValue( "HLO_TIPMOB", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf

				// Dimensão Tipo Horas
				If !Empty(SP9->P9_CLASEV)
					oRecord:SetValue( "HLO_TIPHRS", oSeeker:Seek( "HJI", { SP9->P9_CLASEV } ) ) 
				Else
					oRecord:SetValue( "HLO_TIPHRS", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf
				
				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLO_DATA", IIf( !Empty(SPI->PI_DATA), SPI->PI_DATA, DATE_EMPTY ) ) // Data Movto do Banco de Horas
				If SP9->P9_TIPOCOD == '2'
					oRecord:SetValue( "HLO_QBCOHR", (SPI->PI_QUANTV * -1) )	// Qtde Horas Banco Horas				
					oRecord:SetValue( "HLO_VBCOHR", BIXValue((SPI->PI_QUANTV * nVlrHora * -1), 1, cMoeda, SPI->PI_DATA) )  // Vl Horas Banco Horas
				Else
					oRecord:SetValue( "HLO_QBCOHR", SPI->PI_QUANTV  )		// Qtde Horas Banco Horas								
					oRecord:SetValue( "HLO_VBCOHR", BIXValue(SPI->PI_QUANTV * nVlrHora, 1, cMoeda, SPI->PI_DATA) )		 // Vl Horas Banco Horas
				EndIf
				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
	        Next nInd
		EndIf	
		SPI->( dbSkip() )     
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()
	
	SPI->( DBClearFilter() ) // Remove filtro
Return NIL