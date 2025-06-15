#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRECCAR.CH"

REGISTER EXTRACTOR HLL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRecCar
Apresenta informações históricas dos títulos à receber que estão em 
aberto.

@author  Helio Leal
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Class BIXRecCar From BIXEntity
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
@since   03/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRecCar
	_Super:New( FACT, "HLL", STR0001, "SE1", { FINANCEIRO } ) // "Contas a Receber - Carteira"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   03/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRecCar
	Local oModel := BIXModel():Build( Self )

	oModel:IsSnapshot( .T. )

	oModel:AddField( "HLL_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HLL_BANCO" ,	"C",	32, 00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HLL_CLIENT",	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HLL_ESPDOC",	"C",	32, 00, .T., "HJG" ) //"Espécie de Documento"
	oModel:AddField( "HLL_MODALI",	"C",	32, 00, .T., "HJF" ) //"Modalidade"
	oModel:AddField( "HLL_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HLL_CCUSTO",	"C",	32, 00, .T., "HJ5" ) //"Centro Custo"
	oModel:AddField( "HLL_NATFIN",	"C",	32, 00, .T., "HYE" ) //"Natureza Financeira"
	oModel:AddField( "HLL_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HLL_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"			
	oModel:AddField( "HLL_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"			
	oModel:AddField( "HLL_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HLL_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HLL_DTEXTR",	"D",	08, 00,	.F., "HK2" ) //"Período"

	oModel:AddField( "HLL_DTEMIS",	"D",	08, 00 ) // "Data Emissão"
	oModel:AddField( "HLL_DTVENC",	"D",	08, 00 ) // "Data de Vencimento"	
	oModel:AddField( "HLL_NUMDOC",	"C",	40, 00 ) // Número do Documento.
	oModel:AddField( "HLL_SERDOC",	"C",	08, 00 ) // Série do Documento.
	oModel:AddField( "HLL_PARCEL",	"C",	02, 00 ) // Número da Parcela.
	oModel:AddField( "HLL_PRZREC",	"N",	10, 00 ) // Prazo vencimento.
	oModel:AddField( "HLL_VRECEB",	"N",	16,	02 ) // Valor a Receber.
	oModel:AddField( "HLL_VSUBCT",	"N",	16,	02 ) // Valor Subt Carteira.

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

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) Class BIXRecCar
	Local oRegion     := Nil
	Local aMoeda      := {}
	Local aAbatim     := {}
	Local aRecant     := {}
	Local aCRNeg      := {}
	Local cMoeda      := ""
	Local cFlow       := ""
	Local nMoeda      := 0 
	Local nFee        := 0
	Local lFee        := .F.
	Local lUseFilOrig := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aFilInfo    := Array(3)
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda  := BIXGetMxF( ::cEntity )
	lFee    := BIXParInfo( "BIX_TXMOED"	, "L", .F. )
	aAbatim := aBIToken( mvabatim, "|", .F.) 
	aRecant := aBIToken( mvrecant, "|", .F.) 
	aCRNeg  := aBIToken( mv_crneg, "|", .F.) 
	oRegion := BIXRegiao():New()

	SA1->( dbSetOrder(1) )
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	While ! (cFlow)->( Eof() )

		//-------------------------------------------------------------------
		// Identifica se utiliza a taxa negociada para moeda.
		//------------------------------------------------------------------- 
		If ( ! cPaisLoc == "BRA" .Or. lFee )
			nFee := (cFlow)->E1_TXMOEDA
		Endif

		//-------------------------------------------------------------------
		// Inicializa as variáveis de gestão de empresas
		//------------------------------------------------------------------- 
		aFilInfo[1]	:= UNDEFINED
		aFilInfo[2]	:= UNDEFINED
		aFilInfo[3]	:= UNDEFINED

		//-------------------------------------------------------------------
		// Tratamento para utilização dos dados da _FILORIG
		//------------------------------------------------------------------- 
		If !lUseFilOrig
			//-------------------------------------------------------------------
			// Atrribui as informações padrões 
			//------------------------------------------------------------------- 
			aFilInfo[1] := ::GetCompany( )
			aFilInfo[2] := ::GetUnitBusiness( )
			aFilInfo[3] := ::GetFilial( )
		Else		
			If ! Empty( (cFlow)->E1_FILORIG )
				aFilInfo := BIXFOri( (cFlow)->E1_FILORIG )
			EndIf	
		EndIf

		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()

			//-------------------------------------------------------------------
			// Armazena o conteúdo da Filial Origem 
			//------------------------------------------------------------------- 				
			oRecord:SetFilOrig( (cFlow)->E1_FILORIG ) 

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "E1_PREFIXO" , (cFlow)->E1_PREFIXO ) 
			oRecord:SetValue( "E1_NUM"     , (cFlow)->E1_NUM ) 
			oRecord:SetValue( "E1_PARCELA" , (cFlow)->E1_PARCELA ) 
			oRecord:SetValue( "E1_TIPO"    , (cFlow)->E1_TIPO ) 			
			oRecord:SetValue( "A3_COD"     , (cFlow)->E1_VEND1 )			
			oRecord:SetValue( "A6_COD"     , (cFlow)->E1_PORTADO )
			oRecord:SetValue( "CTT_CUSTO"  , (cFlow)->E1_CCUSTO )
			oRecord:SetValue( "ED_CODIGO"  , (cFlow)->E1_NATUREZ )
			oRecord:SetValue( "A1_COD"     , (cFlow)->E1_CLIENTE )
			oRecord:SetValue( "A1_LOJA"    , (cFlow)->E1_LOJA )
			
			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HLL_EMPRES"	, oSeeker:Seek( "HJ4", { aFilInfo[1] } ) ) 
			oRecord:SetValue( "HLL_ESTABL"	, oSeeker:Seek( "HKK", { aFilInfo[1], aFilInfo[2], aFilInfo[3] } ) ) 
			oRecord:SetValue( "HLL_UNDNEG"	, oSeeker:Seek( "HJ1", { aFilInfo[1], aFilInfo[2] } ) ) 
			oRecord:SetValue( "HLL_REPRES"	, oSeeker:Seek( "HJC", { (cFlow)->E1_VEND1 } ) ) 	
			oRecord:SetValue( "HLL_BANCO"	, oSeeker:Seek( "HG4", { (cFlow)->E1_PORTADO, "", "" } ) ) 
			oRecord:SetValue( "HLL_ESPDOC"	, oSeeker:Seek( "HJG", { (cFlow)->E1_TIPO } ) ) 
			oRecord:SetValue( "HLL_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->E1_CLIENTE, (cFlow)->E1_LOJA } ) ) 	
			oRecord:SetValue( "HLL_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HLL_MODALI" 	, oSeeker:Seek( "HJF", { (cFlow)->E1_SITUACA } ) ) 	
			oRecord:SetValue( "HLL_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E1_CCUSTO } ) ) 
			oRecord:SetValue( "HLL_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E1_NATUREZ } ) ) 		
			
			If SA1->( MsSeek( xFilial("SA1") + (cFlow)->E1_CLIENTE + (cFlow)->E1_LOJA ) )
				oRecord:SetValue( "HLL_GRPCLI"	, oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )		
				oRecord:SetValue( "HLL_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
			Else
				oRecord:SetValue( "HLL_GRPCLI"	, oSeeker:Seek( "HJ0", { UNDEFINED } ) )		
				oRecord:SetValue( "HLL_REGIAO"	, oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
			EndIf
			
			oRecord:SetValue( "HLL_SERDOC"	, (cFlow)->E1_PREFIXO  )
			oRecord:SetValue( "HLL_NUMDOC"	, (cFlow)->E1_NUM  )
			oRecord:SetValue( "HLL_PARCEL"	, (cFlow)->E1_PARCELA  )		
			oRecord:SetValue( "HLL_DTEMIS"	, (cFlow)->E1_EMISSAO  )
			oRecord:SetValue( "HLL_DTVENC"	, (cFlow)->E1_VENCREA  )
			oRecord:SetValue( "HLL_DTEXTR"	, dToday )

			//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HLL_PRZREC" 	, ( BIXVldValor( (cFlow)->E1_VENCREA, (cFlow)->E1_EMISSAO, 3 ) ) ) 
			oRecord:SetValue( "HLL_VSUBCT"	, 0 )

			If ( cPaisLoc == "MEX" )
				If ( Ascan( aCRNeg, { | x | Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO ) } ) > 0 )
					oRecord:SetValue( "HLL_VRECEB"	, ( BIXValue( (cFlow)->E1_SALDO - (cFlow)->E1_VALIMP1, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLL_VRECEB"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) ) )
				EndIf
			Else
				If ( ( Ascan ( aAbatim	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO)} ) > 0 ) .Or. ;
					 ( Ascan ( aRecant	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO)} ) > 0 ) .Or. ;
					 ( Ascan ( aCRNeg	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO)} ) > 0 ) )

					oRecord:SetValue( "HLL_VRECEB"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLL_VRECEB"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) ) )
				EndIf
			EndIf
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------
			oOutput:Send( oRecord )
		Next nMoeda

		(cFlow)->( DBSkip() )
	EndDo
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
	oOutput:Release()
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//-------------------------------------------------------------------  		  
	aSize(aFilInfo, 0)
	aFilInfo := Nil
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma única tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Período inicial de extração.
@param cTo, caracter, Período final de extração.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restrição na recuperação de dados no formato {{campo, operação, valor}}. 
@return cFlow, Alias temporário. 

@author  Helio Leal
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXRecCar
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
	cDML += " SELECT "  
	cDML += " 		SE1.E1_TXMOEDA,"
	cDML += " 		SE1.E1_EMISSAO,"
	cDML += " 		SE1.E1_VENCREA,"
	cDML += " 		SE1.E1_PREFIXO,"
	cDML += " 		SE1.E1_NUM,"
	cDML += " 		SE1.E1_PARCELA,"
	cDML += " 		SE1.E1_TIPO,"
	cDML += " 		SE1.E1_MOEDA,"
	cDML += " 		SE1.E1_SALDO,"
	cDML += " 		SE1.E1_VEND1,"
	cDML += " 		SE1.E1_PORTADO,"
	cDML += " 		SE1.E1_CLIENTE,"
	cDML += " 		SE1.E1_LOJA,"
	cDML += " 		SE1.E1_SITUACA,"
	cDML += " 		SE1.E1_CCUSTO,"
	cDML += " 		SE1.E1_NATUREZ,"	
	
	If ( cPaisLoc == "MEX" )
		cDML += " 	SE1.E1_VALIMP1,"	
	EndIf

	cDML += " 		SE1.E1_FILORIG "
	cDML += " FROM " + RetSQLName( "SE1" ) + " SE1 "
	cDML += " WHERE SE1.E1_FILIAL = '" + xFilial( "SE1" ) + "'" 
	cDML +=  "		AND SE1.E1_SALDO > 0"
	cDML += "		AND SE1.D_E_L_E_T_ = ''" 

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  


	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias() , .T., .F. )

	//-------------------------------------------------------------------
	// Converte os campos para o tipo correto.
	//-------------------------------------------------------------------  	
	TCSetField( ::cFlow, "E1_EMISSAO", "D", 08, 0 )
	TCSetField( ::cFlow, "E1_VENCREA", "D", 08, 0 )
Return ::cFlow
