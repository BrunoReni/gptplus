#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRECVENC.CH"

REGISTER EXTRACTOR HLE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRecVenc
Apresenta informações dos títulos à receber que foram emitidos.

@author  BI TEAM
@since   28/10/2010
/*/
//-------------------------------------------------------------------
Class BIXRecVenc from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Valdiney V GOMES
@since   21/02/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRecVenc
	_Super:New( FACT, "HLE", STR0001, "SE1", { FINANCEIRO } ) //"Contas a Receber - Vencimento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   04/11/2016
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRecVenc 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLE_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HLE_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HLE_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"		
	oModel:AddField( "HLE_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante"	
	oModel:AddField( "HLE_BANCO" ,	"C",	32, 00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HLE_ESPDOC",	"C",	32, 00, .T., "HJG" ) //"Espécie de Documento"	
	oModel:AddField( "HLE_CLIENT",	"C",	32, 00, .T., "HJ7" ) //"Cliente"	
	oModel:AddField( "HLE_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"	
	oModel:AddField( "HLE_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"	
	oModel:AddField( "HLE_MODALI",	"C",	32, 00, .T., "HJF" ) //"Modalidade"		
	oModel:AddField( "HLE_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"	
	oModel:AddField( "HLE_CCUSTO",	"C",	32, 00, .T., "HJ5" ) //"Centro Custo"	
	oModel:AddField( "HLE_NATFIN",	"C",	32, 00, .T., "HYE" ) //"Natureza Financeira"	
	oModel:AddField( "HLE_DATA"	 ,	"D",	08, 00,	.F., "HK2" ) //"Período"
	
	oModel:AddField( "HLE_DTEMIS",	"D",	08, 00 )	
	oModel:AddField( "HLE_NUMDOC",	"C",	40, 00 )
	oModel:AddField( "HLE_SERDOC",	"C",	08, 00 )		
	oModel:AddField( "HLE_PARCEL",	"C",	02, 00 )	
	oModel:AddField( "HLE_PRZVCT",	"N",	10, 00 )
	oModel:AddField( "HLE_VFATUR",	"N",	16,	02 )
	oModel:AddField( "HLE_VVECTO",	"N",	16,	02 )
	oModel:AddField( "HLE_VSUBVC",	"N",	16,	02 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXRecVenc
	Local oRegion	  := nil
	Local aMoeda 	  := {}
	Local aAbatim	  := {}
	Local aRecant	  := {}
	Local aCRNeg	  := {}
	Local cMoeda	  := ""
	Local cFlow		  := ""
	Local nMoeda	  := 0 
	Local nFee		  := 0
	Local lFee		  := .F.
	Local lUseFilOrig := SuperGetMV("MV_BIXFORI", .F., .F.)	
	Local aFilInfo    := Array(3)
		
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	:= BIXGetMxF( ::cEntity )
	lFee 	:= BIXParInfo( "BIX_TXMOED"	, "L", .F. )	
	aAbatim	:= aBIToken( mvabatim, "|", .F.) 
	aRecant	:= aBIToken( mvrecant, "|", .F.) 
	aCRNeg	:= aBIToken( mv_crneg, "|", .F.) 
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
			oRecord:SetValue( "E1_PREFIXO"	, (cFlow)->E1_PREFIXO ) 
			oRecord:SetValue( "E1_NUM"		, (cFlow)->E1_NUM ) 
			oRecord:SetValue( "E1_PARCELA"	, (cFlow)->E1_PARCELA ) 
			oRecord:SetValue( "E1_TIPO"		, (cFlow)->E1_TIPO ) 
			oRecord:SetValue( "A3_COD"		, (cFlow)->E1_VEND1 )			
			oRecord:SetValue( "A6_COD"     ,  (cFlow)->E1_PORTADO )
			oRecord:SetValue( "CTT_CUSTO"	, (cFlow)->E1_CCUSTO )
			oRecord:SetValue( "ED_CODIGO"	, (cFlow)->E1_NATUREZ )
			oRecord:SetValue( "A1_COD"		, (cFlow)->E1_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->E1_LOJA )
	
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLE_EMPRES"	, oSeeker:Seek( "HJ4", { aFilInfo[1] } ) ) 
			oRecord:SetValue( "HLE_ESTABL"	, oSeeker:Seek( "HKK", { aFilInfo[1], aFilInfo[2], aFilInfo[3] } ) ) 
			oRecord:SetValue( "HLE_UNDNEG"	, oSeeker:Seek( "HJ1", { aFilInfo[1], aFilInfo[2] } ) ) 
			oRecord:SetValue( "HLE_REPRES"	, oSeeker:Seek( "HJC", { (cFlow)->E1_VEND1 } ) ) 	
			oRecord:SetValue( "HLE_BANCO"	, oSeeker:Seek( "HG4", { (cFlow)->E1_PORTADO, "", "" } ) ) 
			oRecord:SetValue( "HLE_ESPDOC"	, oSeeker:Seek( "HJG", { (cFlow)->E1_TIPO } ) ) 
			oRecord:SetValue( "HLE_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->E1_CLIENTE, (cFlow)->E1_LOJA } ) ) 	
			oRecord:SetValue( "HLE_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HLE_MODALI" 	, oSeeker:Seek( "HJF", { (cFlow)->E1_SITUACA } ) ) 	
			oRecord:SetValue( "HLE_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E1_CCUSTO } ) ) 
			oRecord:SetValue( "HLE_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E1_NATUREZ } ) ) 		
			
			If SA1->( MsSeek( xFilial("SA1") + (cFlow)->E1_CLIENTE + (cFlow)->E1_LOJA ) )
				oRecord:SetValue( "HLE_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
				oRecord:SetValue( "HLE_GRPCLI"	, oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )		
			Else
				oRecord:SetValue( "HLE_REGIAO"	, oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
				oRecord:SetValue( "HLE_GRPCLI"	, oSeeker:Seek( "HJ0", { UNDEFINED } ) )		
			Endif
			
			oRecord:SetValue( "HLE_SERDOC"	, (cFlow)->E1_PREFIXO  )
			oRecord:SetValue( "HLE_NUMDOC"	, (cFlow)->E1_NUM  )
			oRecord:SetValue( "HLE_PARCEL"	, (cFlow)->E1_PARCELA  )		
			oRecord:SetValue( "HLE_DTEMIS"	, (cFlow)->E1_EMISSAO  )
			oRecord:SetValue( "HLE_DATA"	, (cFlow)->E1_VENCREA  )
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLE_PRZVCT" 	, ( BIXVldValor( (cFlow)->E1_VENCREA, (cFlow)->E1_EMISSAO, 3 ) ) )
			oRecord:SetValue( "HLE_VSUBVC"	, 0 )	
			
			If ( cPaisLoc == "MEX" )
				If ( AScan( aCRNeg, { | x | Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO ) } ) > 0 )
					oRecord:SetValue( "HLE_VFATUR"	, ( BIXValue( (cFlow)->E1_VALOR - (cFlow)->E1_VALIMP1, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) * ( -1 ) ) )
					oRecord:SetValue( "HLE_VVECTO"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLE_VFATUR"	, ( BIXValue( (cFlow)->E1_VALOR, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) ) )
					oRecord:SetValue( "HLE_VVECTO"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) ) )
				EndIf
			Else
				If ( ( AScan ( aAbatim	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO ) } ) > 0 ) .Or. ;
					 ( AScan ( aRecant	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO ) } ) > 0 ) .Or. ;
					 ( AScan ( aCRNeg	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E1_TIPO ) } ) > 0 ) ) 
					 
					oRecord:SetValue( "HLE_VFATUR"	, ( BIXValue( (cFlow)->E1_VALOR, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) * ( -1 ) ) )
					oRecord:SetValue( "HLE_VVECTO"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLE_VFATUR"	, ( BIXValue( (cFlow)->E1_VALOR, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) ) )
					oRecord:SetValue( "HLE_VVECTO"	, ( BIXValue( (cFlow)->E1_SALDO, (cFlow)->E1_MOEDA, cMoeda, (cFlow)->E1_VENCREA, nFee ) ) )
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
	
Return nil

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

@author  Valdiney V GOMES
@since   21/02/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXRecVenc
	Local cDML := ""

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
	cDML += " 		SE1.E1_VALOR,"
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
	cDML += "		AND ("
	cDML += "			SE1.E1_BAIXA = '" + Space( TamSX3( "E1_BAIXA" ) [1] ) + "'"
	cDML += "			OR" 
	cDML += "			SE1.E1_SALDO <> SE1.E1_VALOR)"
	cDML += "		AND SE1.E1_VENCREA BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cDML += "		AND SE1.D_E_L_E_T_ = ' '" 
	
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