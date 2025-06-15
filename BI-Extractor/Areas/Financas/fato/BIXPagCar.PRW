#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPAGCAR.CH"

REGISTER EXTRACTOR HLK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPagCar
Apresenta informações históricas dos títulos à pagar que estão em 
aberto. 

@author  BI TEAM
@since   03/11/2010
/*/
//-------------------------------------------------------------------
Class BIXPagCar from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   03/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXPagCar
	_Super:New( FACT, "HLK", STR0001, "SE2", { FINANCEIRO } ) //"Contas a Pagar - Carteira"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   03/03/2016
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPagCar 
	Local oModel := BIXModel():Build( Self )
	
	oModel:IsSnapshot( .T. )

	oModel:AddField( "HLK_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HLK_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HLK_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"		
	oModel:AddField( "HLK_FORNEC",	"C",	32, 00, .T., "HKJ" ) //"Fornecedor"	
	oModel:AddField( "HLK_BANCO" ,	"C",	32, 00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HLK_ESPDOC",	"C",	32, 00, .T., "HJG" ) //"Espécie de Documento"	
	oModel:AddField( "HLK_GRPFOR",	"C",	32, 00, .T., "HGE" ) //"Grupo Fornecedor"	
	oModel:AddField( "HLK_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"	
	oModel:AddField( "HLK_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"	
	oModel:AddField( "HLK_MODALI",	"C",	32, 00, .T., "HJF" ) //"Modalidade"		
	oModel:AddField( "HLK_CCUSTO",	"C",	32, 00, .T., "HJ5" ) //"Centro Custo"	
	oModel:AddField( "HLK_NATFIN",	"C",	32, 00, .T., "HYE" ) //"Natureza Financeira"	
	oModel:AddField( "HLK_DTEXTR",	"D",	08, 00,	.F., "HK2" ) //"Período"
	
	oModel:AddField( "HLK_DTEMIS",	"D",	08, 00 )
	oModel:AddField( "HLK_DTVENC",	"D",	08, 00 )	
	oModel:AddField( "HLK_NUMDOC",	"C",	40, 00 )
	oModel:AddField( "HLK_SERDOC",	"C",	08, 00 )		
	oModel:AddField( "HLK_PARCEL",	"C",	02, 00 )	
	oModel:AddField( "HLK_PRZVCT",	"N",	10, 00 )
	oModel:AddField( "HLK_VPAGAR",	"N",	16,	02 )
	oModel:AddField( "HLK_VSUBCT",	"N",	16,	02 )

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
@since   03/11/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPagCar
	Local oRegion	  := nil
	Local aMoeda 	  := {}
	Local aAbatim	  := {}
	Local aPagant	  := {}
	Local aCPNeg	  := {}
	Local cMoeda	  := ""
	Local cFlow	      := ""
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
	aAbatim	:= aBIToken( MVABATIM, "|", .F.) 
	aPagant	:= aBIToken( MVPAGANT, "|", .F.) 
	aCPNeg	:= aBIToken( MV_CPNEG, "|", .F.) 
	oRegion := BIXRegiao():New()
	
	SA2->( dbSetOrder(1) )
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While ! (cFlow)->( Eof() ) 
		//-------------------------------------------------------------------
		// Identifica se utiliza a taxa negociada para moeda. 
		//------------------------------------------------------------------- 
		If ( ! cPaisLoc == "BRA" .Or. lFee )
			nFee := (cFlow)->E2_TXMOEDA
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
			If ! Empty( (cFlow)->E2_FILORIG )
				aFilInfo := BIXFOri( (cFlow)->E2_FILORIG )
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
			oRecord:SetFilOrig( (cFlow)->E2_FILORIG ) 

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "E2_PREFIXO" , (cFlow)->E2_PREFIXO ) 
			oRecord:SetValue( "E2_NUM"     , (cFlow)->E2_NUM ) 
			oRecord:SetValue( "E2_PARCELA" , (cFlow)->E2_PARCELA )
			oRecord:SetValue( "E2_TIPO"    , (cFlow)->E2_TIPO )
			oRecord:SetValue( "E2_FORNECE" , (cFlow)->E2_FORNECE )
			oRecord:SetValue( "E2_LOJA"    , (cFlow)->E2_LOJA )			
			oRecord:SetValue( "A2_COD"     , (cFlow)->E2_FORNECE )
			oRecord:SetValue( "A2_LOJA"    , (cFlow)->E2_LOJA )			
			oRecord:SetValue( "A6_COD"     , (cFlow)->E2_BCOPAG )
			oRecord:SetValue( "CTT_CUSTO"  , (cFlow)->E2_CCUSTO )
			oRecord:SetValue( "ED_CODIGO"  , (cFlow)->E2_NATUREZ )
	
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLK_EMPRES"	, oSeeker:Seek( "HJ4", { aFilInfo[1] } ) ) 
			oRecord:SetValue( "HLK_ESTABL"	, oSeeker:Seek( "HKK", { aFilInfo[1], aFilInfo[2], aFilInfo[3] } ) ) 
			oRecord:SetValue( "HLK_UNDNEG"	, oSeeker:Seek( "HJ1", { aFilInfo[1], aFilInfo[2] } ) ) 

			oRecord:SetValue( "HLK_BANCO"	, oSeeker:Seek( "HG4", { (cFlow)->E2_BCOPAG, "", "" } ) ) 
			oRecord:SetValue( "HLK_ESPDOC"	, oSeeker:Seek( "HJG", { (cFlow)->E2_TIPO } ) ) 
			oRecord:SetValue( "HLK_FORNEC"	, oSeeker:Seek( "HKJ", { (cFlow)->E2_FORNECE, (cFlow)->E2_LOJA } ) )
			oRecord:SetValue( "HLK_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HLK_MODALI" 	, oSeeker:Seek( "HJF", { UNDEFINED } ) ) 	
			oRecord:SetValue( "HLK_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E2_CCUSTO } ) ) 
			oRecord:SetValue( "HLK_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E2_NATUREZ } ) ) 		
			
			If SA2->( MsSeek( xFilial("SA2") + (cFlow)->E2_FORNECE + (cFlow)->E2_LOJA ) )
				oRecord:SetValue( "HLK_GRPFOR"	, oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) ) 			 	
				oRecord:SetValue( "HLK_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA2->A2_EST, SA2->A2_COD_MUN, SA2->A2_PAIS ) } ) ) 
			Else
				oRecord:SetValue( "HLK_GRPFOR"	, oSeeker:Seek( "HGE", { UNDEFINED } ) ) 			 	
				oRecord:SetValue( "HLK_REGIAO"	, oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
			Endif
			
			oRecord:SetValue( "HLK_SERDOC"	, (cFlow)->E2_PREFIXO  )
			oRecord:SetValue( "HLK_NUMDOC"	, (cFlow)->E2_NUM  )
			oRecord:SetValue( "HLK_PARCEL"	, (cFlow)->E2_PARCELA  )
			oRecord:SetValue( "HLK_DTEXTR"	, dToday  )					
			oRecord:SetValue( "HLK_DTEMIS"	, (cFlow)->E2_EMISSAO  )
			oRecord:SetValue( "HLK_DTVENC"	, (cFlow)->E2_VENCREA  )
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLK_PRZVCT" 	, ( BIXVldValor( (cFlow)->E2_VENCREA, (cFlow)->E2_EMISSAO, 3 ) ) )
			oRecord:SetValue( "HLK_VSUBVC"	, 0 )	
			
			If ( cPaisLoc == "MEX" )
				If ( Ascan( aCPNeg, { | x | Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 )
					oRecord:SetValue( "HLK_VPAGAR"	, ( BIXValue( (cFlow)->E2_SALDO - (cFlow)->E2_VALIMP1, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLK_VPAGAR"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) ) )
				EndIf
			Else
				If ( ( Ascan ( aAbatim	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 ) .Or. ;
					 ( Ascan ( aPagant	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 ) .Or. ;
					 ( Ascan ( aCPNeg	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 ) ) 
					 
					oRecord:SetValue( "HLK_VPAGAR"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLK_VPAGAR"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) ) )
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

@author  Tamara Clemente
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPagCar
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
	cDML += " SELECT "  
	cDML += " 		SE2.E2_TIPO,"
	cDML += " 		SE2.E2_BCOPAG,"
	cDML += " 		SE2.E2_CCUSTO,"
	cDML += " 		SE2.E2_NATUREZ,"
	cDML += " 		SE2.E2_FORNECE,"
	cDML += " 		SE2.E2_LOJA,"	
	cDML += " 		SE2.E2_TXMOEDA,"
	cDML += " 		SE2.E2_EMISSAO,"
	cDML += " 		SE2.E2_VENCREA,"
	cDML += " 		SE2.E2_PREFIXO,"
	cDML += " 		SE2.E2_NUM,"
	cDML += " 		SE2.E2_PARCELA,"
	cDML += " 		SE2.E2_SALDO,"	
	cDML += " 		SE2.E2_MOEDA,"
	If ( cPaisLoc == "MEX" )
		cDML += " 	SE2.E2_VALIMP1,"	
	EndIf
	cDML += " 		SE2.E2_FILORIG "	
	cDML += " FROM " + RetSQLName( "SE2" ) + " SE2 "
	//---------------------------------------------------------------------------------------
	// Junção com SA6 (Bancos) para receber o código do banco.
	//---------------------------------------------------------------------------------------
	cDML += " LEFT JOIN (SELECT DISTINCT SA6.A6_COD "
	cDML += " FROM " + RetSQLName( "SA6" ) + " SA6 "
	cDML += " WHERE SA6.A6_FILIAL = '" + xFilial( "SA6" ) + "'"
	cDML += " AND D_E_L_E_T_ = ' ') SA6 "
	cDML += " ON  SA6.A6_COD = SE2.E2_BCOPAG "
	cDML += " WHERE SE2.E2_FILIAL = '" + xFilial( "SE2" ) + "'"
	cDML += "		AND SE2.E2_SALDO > 0 "
	cDML += "		AND SE2.D_E_L_E_T_ = ' '" 
	
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
Return ::cFlow