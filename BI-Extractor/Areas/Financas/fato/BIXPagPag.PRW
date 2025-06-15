#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPAGPAG.CH"

REGISTER EXTRACTOR HLI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPagPag
Apresenta informações dos títulos à pagar que foram parcialmente ou 
totalmente pagos.

@author  BI TEAM
@since   03/11/2010
/*/
//-------------------------------------------------------------------
Class BIXPagPag from BIXEntity
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
@since   03/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXPagPag
	_Super:New( FACT, "HLI", STR0001, "SE5", { FINANCEIRO } ) //"Contas a Pagar - Pagamento"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   03/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPagPag 
	Local oModel := BIXModel():Build( Self )
	
	oModel:AddField( "HLI_EMPRES",	"C",	32,	00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HLI_ESTABL",	"C",	32,	00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HLI_UNDNEG",	"C",	32,	00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HLI_BANCO" ,	"C",	32,	00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HLI_ESPDOC",	"C",	32,	00, .T., "HJG" ) //"Espécie de Documento"
	oModel:AddField( "HLI_FORNEC",	"C",	32,	00, .T., "HKJ" ) //"Fornecedor"
	oModel:AddField( "HLI_REGIAO",	"C",	32,	00, .T., "HJB" ) //"Região"
	oModel:AddField( "HLI_MOEDA" ,	"C",	32,	00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HLI_MODALI",	"C",	32,	00, .T., "HJF" ) //"Modalidade"
	oModel:AddField( "HLI_GRPFOR",	"C",	32,	00, .T., "HGE" ) //"Grupo de Fornecedor"
	oModel:AddField( "HLI_CCUSTO",	"C",	32,	00, .T., "HJ5" ) //"Centro Custo"
	oModel:AddField( "HLI_NATFIN",	"C",	32, 00, .T., "HYE" ) //"Natureza Financeira"
	oModel:AddField( "HLI_DATA"	 ,	"D",	08,	00, .F., "HK2" ) //"Período"
	
	oModel:AddField( "HLI_DTEMIS",	"D",	08,	00 )
	oModel:AddField( "HLI_DTVENC",	"D",	08, 00 )
	oModel:AddField( "HLI_SERDOC",	"C",	08,	00 )
	oModel:AddField( "HLI_NUMDOC",	"C",	40,	00 )
	oModel:AddField( "HLI_PARCEL",	"C",	02,	00 )
	oModel:AddField( "HLI_SEQPAG",	"C",	10,	00 )
	oModel:AddField( "HLI_PRZPAG",	"N",	10,	00 )
	oModel:AddField( "HLI_VDESCR",	"N",	16,	02 )
	oModel:AddField( "HLI_VJUPAG",	"N",	16,	02 )
	oModel:AddField( "HLI_VPAGO" ,	"N",	16,	02 )
	oModel:AddField( "HLI_VSUBPG",	"N",	16,	02 )	

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
@since   10/11/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPagPag
	Local oRegion     := nil 
	Local aReason     := {}
	Local aMoeda      := {}
	Local cMoeda      := ""
	Local nMoeda      := 0 
	Local nFee        := 0
	Local lFee        := .F.
	Local lIgnore     := .F. 
	Local lUseFilOrig := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aFilInfo    := Array(3)
	
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 		
	aMoeda  := BIXGetMxF( ::cEntity )
	lFee    := BIXParInfo( "BIX_TXMOED"	, "L", .F. )	
	oRegion := BIXRegiao():New()		
	
	//-------------------------------------------------------------------
	// Identifica os motivos de baixa. 
	//------------------------------------------------------------------- 
	AAdd( aReason, "DSD" )
	AAdd( aReason, "FAT" )
	AAdd( aReason, "LIQ" )
	AAdd( aReason, "AGL" )	
	
	SA2->( dbSetOrder(1) )

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While ! (cFlow)->( Eof() ) 
		//-------------------------------------------------------------------
		// Identifica se é um recebimento. 
		//------------------------------------------------------------------- 		
		lIgnore := ( AllTrim( (cFlow)->E5_RECPAG ) == "R" )
		
		If ! ( lIgnore )
			//-------------------------------------------------------------------
			// Identifica se a baixa foi cancelada. 
			//------------------------------------------------------------------- 
			lIgnore := TemBxCanc( (cFlow)->E5_PREFIXO + (cFlow)->E5_NUMERO + (cFlow)->E5_PARCELA + (cFlow)->E5_TIPO + (cFlow)->E5_CLIFOR + (cFlow)->E5_LOJA + (cFlow)->E5_SEQ )
			
			If ! ( lIgnore )
				//-------------------------------------------------------------------
				// Identifica se o documento é do tipo Baixas ou Movimentação bancária. 
				//------------------------------------------------------------------- 
				lIgnore := ! ( AllTrim( (cFlow)->E5_TIPODOC ) $ "VL/BA" )
			EndIf 
		EndIf 
	
		If ! ( lIgnore )

			//-------------------------------------------------------------------
			// Identifica se utiliza a taxa negociada para moeda. 
			//------------------------------------------------------------------- 
			If ( ! cPaisLoc == "BRA" .Or. lFee )
				nFee := (cFlow)->E5_TXMOEDA
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
				If ! Empty( (cFlow)->E5_FILORIG )
					aFilInfo := BIXFOri( (cFlow)->E5_FILORIG )
				End If	
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
				oRecord:SetFilOrig( (cFlow)->E5_FILORIG ) 
					
				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "E5_DATA"		, (cFlow)->E5_DATA ) 
				oRecord:SetValue( "E5_BANCO"	, (cFlow)->E5_BANCO )
				oRecord:SetValue( "E5_AGENCIA"	, (cFlow)->E5_AGENCIA )
				oRecord:SetValue( "E5_CONTA"	, (cFlow)->E5_CONTA )
				oRecord:SetValue( "A6_COD"		, (cFlow)->E5_BANCO )
				oRecord:SetValue( "A6_AGENCIA"	, (cFlow)->E5_AGENCIA )
				oRecord:SetValue( "A6_NUMCON"	, (cFlow)->E5_CONTA )
				oRecord:SetValue( "CTT_CUSTO"	, (cFlow)->E5_CCUSTO )
				oRecord:SetValue( "ED_CODIGO"	, (cFlow)->E5_NATUREZ )
				oRecord:SetValue( "A2_COD"		, (cFlow)->E2_FORNECE )
				oRecord:SetValue( "A2_LOJA"		, (cFlow)->E2_LOJA )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLI_EMPRES"	, oSeeker:Seek( "HJ4", { aFilInfo[1] } ) ) 
				oRecord:SetValue( "HLI_ESTABL"	, oSeeker:Seek( "HKK", { aFilInfo[1], aFilInfo[2], aFilInfo[3]} ) ) 
				oRecord:SetValue( "HLI_UNDNEG"	, oSeeker:Seek( "HJ1", { aFilInfo[1], aFilInfo[2] } ) ) 

				oRecord:SetValue( "HLI_BANCO"	, oSeeker:Seek( "HG4", { (cFlow)->E5_BANCO, (cFlow)->E5_AGENCIA, (cFlow)->E5_CONTA } ) ) 
				oRecord:SetValue( "HLI_ESPDOC"	, oSeeker:Seek( "HJG", { (cFlow)->E5_TIPO } ) ) 
				oRecord:SetValue( "HLI_FORNEC"	, oSeeker:Seek( "HKJ", { (cFlow)->E2_FORNECE, (cFlow)->E2_LOJA } ) ) 
				 
				oRecord:SetValue( "HLI_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
				oRecord:SetValue( "HLI_MODALI" 	, oSeeker:Seek( "HJF", { UNDEFINED } ) ) 	
				oRecord:SetValue( "HLI_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E5_CCUSTO } ) ) 
				oRecord:SetValue( "HLI_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E5_NATUREZ } ) ) 	
				
				If SA2->( MsSeek( xFilial("SA2") + (cFlow)->E2_FORNECE + (cFlow)->E2_LOJA ) )
					oRecord:SetValue( "CC2_EST"		, SA2->A2_EST )
					oRecord:SetValue( "CC2_CODMUN"	, SA2->A2_COD_MUN )
					
					oRecord:SetValue( "HLI_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA2->A2_EST, SA2->A2_COD_MUN, SA2->A2_PAIS ) } ) )
					oRecord:SetValue( "HLI_GRPFOR"	, oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) )
				Else
					oRecord:SetValue( "CC2_EST"		, " " )
					oRecord:SetValue( "CC2_CODMUN"	, " " )
					
					oRecord:SetValue( "HLI_REGIAO"	, oSeeker:Seek( "HJB", { UNDEFINED } ) )
					oRecord:SetValue( "HLI_GRPFOR"	, oSeeker:Seek( "HGE", { UNDEFINED } ) )
				EndIf
				
				
				oRecord:SetValue( "HLI_DTVENC"	, (cFlow)->E2_VENCREA  )
				oRecord:SetValue( "HLI_DTEMIS"	, (cFlow)->E2_EMISSAO  )
				oRecord:SetValue( "HLI_DATA"	, (cFlow)->E5_DATA  )		
				oRecord:SetValue( "HLI_SERDOC"	, (cFlow)->E2_PREFIXO  )
				oRecord:SetValue( "HLI_NUMDOC"	, (cFlow)->E2_NUM  )
				oRecord:SetValue( "HLI_PARCEL"	, (cFlow)->E2_PARCELA  )
				oRecord:SetValue( "HLI_SEQPAG"	, (cFlow)->E5_SEQ )	

				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 	
				oRecord:SetValue( "HLI_VDESCR"	, BIXValue( (cFlow)->E5_VLDESCO	, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee ) )	
				oRecord:SetValue( "HLI_VJUPAG"	, BIXValue( (cFlow)->E5_VLJUROS	, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee ) )	
				oRecord:SetValue( "HLI_PRZPAG"	, BIXVldValor( (cFlow)->E2_BAIXA, (cFlow)->E2_EMISSAO, 3 ) )
	
				If ! ( AScan( aReason, AllTrim( (cFlow)->E5_MOTBX ) ) ) == 0
					oRecord:SetValue( "HLI_VSUBPG"	, BIXValue( (cFlow)->E5_VALOR, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee ) )
					oRecord:SetValue( "HLI_VPAGO"	, 0 )
				Else
					oRecord:SetValue( "HLI_VSUBPG"	, 0 )
					oRecord:SetValue( "HLI_VPAGO"	, BIXValue( (cFlow)->E5_VALOR, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee)  )
				EndIf

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nMoeda			
		EndIf

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
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPagPag
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
	cDML += " SELECT "  
	cDML += " 		SE2.E2_FORNECE,"
	cDML += " 		SE2.E2_LOJA,"
	cDML += " 		SE2.E2_VENCREA,"
	cDML += " 		SE2.E2_EMISSAO,"
	cDML += " 		SE2.E2_PREFIXO,"
	cDML += " 		SE2.E2_NUM,"
	cDML += " 		SE2.E2_PARCELA,"
	cDML += " 		SE2.E2_BAIXA,"
	cDML += " 		SE5.E5_BANCO,"
	cDML += " 		SE5.E5_AGENCIA,"
	cDML += " 		SE5.E5_CONTA,"
	cDML += " 		SE5.E5_CCUSTO,"
	cDML += " 		SE5.E5_CLIFOR,"
	cDML += " 		SE5.E5_DATA,"
	cDML += " 		SE5.E5_LOJA,"
	cDML += " 		SE5.E5_MOEDA,"
	cDML += " 		SE5.E5_NATUREZ,"
	cDML += " 		SE5.E5_NUMERO,"
	cDML += " 		SE5.E5_PARCELA,"
	cDML += " 		SE5.E5_PREFIXO,"
	cDML += " 		SE5.E5_RECPAG,"
	cDML += " 		SE5.E5_SEQ,"
	cDML += " 		SE5.E5_TIPO,"
	cDML += " 		SE5.E5_TIPODOC,"
	cDML += " 		SE5.E5_TXMOEDA,"
	cDML += " 		SE5.E5_VALOR,"
	cDML += " 		SE5.E5_VLDESCO,"
	cDML += " 		SE5.E5_VLJUROS,"
	cDML += " 		SE5.E5_NUMCHEQ,"
	cDML += " 		SE5.E5_MOTBX,"
	cDML += " 		SE5.E5_FILORIG"
	cDML += " FROM " + RetSQLName( "SE5" ) + " SE5 "
	cDML += " INNER JOIN " + RetSQLName( "SE2" ) + " SE2 "	
	cDML += " 		ON SE2.E2_FILIAL = '" + xFilial( "SE2" ) + "'" 	
	cDML += " 		AND SE2.E2_PREFIXO = SE5.E5_PREFIXO"
	cDML += " 		AND SE2.E2_NUM = SE5.E5_NUMERO"
	cDML += " 		AND SE2.E2_PARCELA = SE5.E5_PARCELA"
	cDML += " 		AND SE2.E2_TIPO = SE5.E5_TIPO"
	cDML += " 		AND SE2.E2_FORNECE = SE5.E5_CLIFOR"
	cDML += " 		AND SE2.E2_LOJA = SE5.E5_LOJA"
	cDML += " 		AND SE2.D_E_L_E_T_ = ' '" 
	cDML += " WHERE SE5.E5_FILIAL = '" + xFilial( "SE5" ) + "'" 
	cDML +=  "		AND SE5.E5_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cDML += "		AND SE5.D_E_L_E_T_ = ' '" 	

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
	TCSetField( ::cFlow, "E2_EMISSAO", "D", 08, 0 )
	TCSetField( ::cFlow, "E2_VENCREA", "D", 08, 0 )
	TCSetField( ::cFlow, "E2_BAIXA"	 , "D", 08, 0 )
	TCSetField( ::cFlow, "E5_DATA"	 , "D", 08, 0 )
Return ::cFlow