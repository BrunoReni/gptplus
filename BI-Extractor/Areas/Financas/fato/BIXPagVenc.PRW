#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPAGVENC.CH"

REGISTER EXTRACTOR HLD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPagVenc
Apresenta informa��es dos t�tulos � pagar que foram emitidos.

@author  Helio Leal
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Class BIXPagVenc from BIXEntity
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
Method New() Class BIXPagVenc
	_Super:New( FACT, "HLD", STR0001, "SE2", { FINANCEIRO } ) //"Contas a Pagar - Vencimento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   06/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPagVenc 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLD_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HLD_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"	
	oModel:AddField( "HLD_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Neg�cio"	
	oModel:AddField( "HLD_BANCO" ,	"C",	32, 00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HLD_ESPDOC",	"C",	32, 00, .T., "HJG" ) //"Esp�cie de Documento"
	oModel:AddField( "HLD_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Regi�o"
	oModel:AddField( "HLD_MODALI",	"C",	32, 00, .T., "HJF" ) //"Modalidade"
	oModel:AddField( "HLD_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HLD_FORNEC",	"C",	32, 00, .T., "HKJ" ) //"Fornecedor"		
	oModel:AddField( "HLD_GRPFOR",	"C",	32, 00, .T., "HGE" ) //"Grupo de Fornecedor"
	oModel:AddField( "HLD_CCUSTO",	"C",	32, 00, .T., "HJ5" ) //"Centro de Custo"
	oModel:AddField( "HLD_NATFIN",	"C",	32, 00, .T., "HYE" ) //"Natureza Financeira"

	oModel:AddField( "HLD_DATA"	 ,	"D",	08, 00,	.F., "HK2" ) //"Per�odo"	
	oModel:AddField( "HLD_DTEMIS",	"D",	08, 00 ) // "Data Emiss�o"
	oModel:AddField( "HLD_NUMDOC",	"C",	40, 00 ) // "N�mero do Documento"
	oModel:AddField( "HLD_SERDOC",	"C",	08, 00 ) // "S�rie do Documento"		
	oModel:AddField( "HLD_PARCEL",	"C",	02, 00 ) // "N�mero da Parcela"
	oModel:AddField( "HLD_PRZVCT",	"N",	10, 00 ) // "Prazo Vencimento"
	oModel:AddField( "HLD_VCOMPR",	"N",	16,	02 ) // "Valor Comprado"
	oModel:AddField( "HLD_VVECTO",	"N",	16,	02 ) // "Valor Vencimento"
	oModel:AddField( "HLD_VSUBVC",	"N",	16,	02 ) // "Valor Substitui��o Vencimento"

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
@since   06/03/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPagVenc
	Local oRegion		 := Nil
	Local aMoeda		 := {}
	Local aAbatim		 := {}
	Local aPagant		 := {}
	Local aCPNeg		 := {}
	Local cMoeda		 := ""
	Local cFlow		 := ""
	Local nMoeda	  	 := 0
	Local nFee		  	 := 0
	Local lFee			 := .F.
	Local lUseFilOrig	 := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aFilInfo	 := Array(3)	
	
	//-------------------------------------------------------------------
	// Recupera os par�metros da fato.
	//-------------------------------------------------------------------
	aMoeda  := BIXGetMxF( ::cEntity )
	lFee    := BIXParInfo( "BIX_TXMOED"	, "L", .F. )

	aAbatim	:= aBIToken( MVABATIM, "|", .F.) 
	aPagant	:= aBIToken( MVPAGANT, "|", .F.) 
	aCPNeg		:= aBIToken( MV_CPNEG, "|", .F.) 
	oRegion 	:= BIXRegiao():New()

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
		// Inicializa as vari�veis de gest�o de empresas
		//------------------------------------------------------------------- 
		aFilInfo[1]	:= UNDEFINED
		aFilInfo[2]	:= UNDEFINED
		aFilInfo[3]	:= UNDEFINED
		
		//-------------------------------------------------------------------
		// Tratamento para utiliza��o dos dados da _FILORIG
		//------------------------------------------------------------------- 
		If !lUseFilOrig
			//-------------------------------------------------------------------
			// Atrribui as informa��es padr�es 
			//------------------------------------------------------------------- 
			aFilInfo[1] := ::GetCompany( )
			aFilInfo[2] := ::GetUnitBusiness( )
			aFilInfo[3] := ::GetFilial( )
		Else
			If ! Empty( (cFlow)->E2_FILORIG )
				aFilInfo := BIXFOri( (cFlow)->E2_FILORIG )
			EndIf				
		EndIf

		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()

			//-------------------------------------------------------------------
			// Armazena o conte�do da Filial Origem 
			//------------------------------------------------------------------- 				
			oRecord:SetFilOrig( (cFlow)->E2_FILORIG ) 

			//-------------------------------------------------------------------
			// Customiza��o.
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
			oRecord:SetValue( "HLD_EMPRES"	, oSeeker:Seek( "HJ4", { aFilInfo[1] } ) ) 
			oRecord:SetValue( "HLD_ESTABL"	, oSeeker:Seek( "HKK", { aFilInfo[1], aFilInfo[2], aFilInfo[3] } ) ) 
			oRecord:SetValue( "HLD_UNDNEG"	, oSeeker:Seek( "HJ1", { aFilInfo[1], aFilInfo[2] } ) )

			oRecord:SetValue( "HLD_BANCO"	, oSeeker:Seek( "HG4", { (cFlow)->E2_BCOPAG, "", "" } ) )
			oRecord:SetValue( "HLD_ESPDOC"	, oSeeker:Seek( "HJG", { (cFlow)->E2_TIPO } ) )
			oRecord:SetValue( "HLD_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HLD_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E2_CCUSTO } ) )
			oRecord:SetValue( "HLD_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E2_NATUREZ } ) )
			oRecord:SetValue( "HLD_FORNEC"	, oSeeker:Seek( "HKJ", { (cFlow)->E2_FORNECE, (cFlow)->E2_LOJA } ) )
			
			If SA2->( MsSeek( xFilial("SA2") + (cFlow)->E2_FORNECE + (cFlow)->E2_LOJA ) )
				oRecord:SetValue( "HLD_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA2->A2_EST, SA2->A2_COD_MUN, SA2->A2_PAIS ) } ) )
				oRecord:SetValue( "HLD_GRPFOR"	, oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) )
			Else
				oRecord:SetValue( "HLD_REGIAO"	, oSeeker:Seek( "HJB", { UNDEFINED } ) )
				oRecord:SetValue( "HLD_GRPFOR"	, oSeeker:Seek( "HGE", { UNDEFINED } ) )
			Endif
			
			oRecord:SetValue( "HLD_MODALI" 	, oSeeker:Seek( "HJF", { UNDEFINED } ) )
			
			oRecord:SetValue( "HLD_SERDOC"	, (cFlow)->E2_PREFIXO  )
			oRecord:SetValue( "HLD_NUMDOC"	, (cFlow)->E2_NUM  )
			oRecord:SetValue( "HLD_PARCEL"	, (cFlow)->E2_PARCELA  )
			oRecord:SetValue( "HLD_DTEMIS"	, (cFlow)->E2_EMISSAO  )
			oRecord:SetValue( "HLD_DATA"	, (cFlow)->E2_VENCREA  )

			//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HLD_PRZVCT" 	, ( BIXVldValor( (cFlow)->E2_VENCREA, (cFlow)->E2_EMISSAO, 3 ) ) )
			oRecord:SetValue( "HLD_VSUBVC"	, 0 )

			If ( cPaisLoc == "MEX" )
				If ( Ascan( aCPNeg, { | x | Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 )
					oRecord:SetValue( "HLD_VCOMPR"	, ( BIXValue( (cFlow)->E2_VALOR - (cFlow)->E2_VALIMP1, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) * ( -1 ) ) )
					oRecord:SetValue( "HLD_VVECTO"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLD_VCOMPR"	, ( BIXValue( (cFlow)->E2_VALOR, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) ) )
					oRecord:SetValue( "HLD_VVECTO"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) ) )
				EndIf
			Else
				If ( ( Ascan ( aAbatim	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 ) .Or. ;
					 ( Ascan ( aPagant	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 ) .Or. ;
					 ( Ascan ( aCPNeg	, {|x| Alltrim( x ) == Alltrim( (cFlow)->E2_TIPO ) } ) > 0 ) )

					oRecord:SetValue( "HLD_VCOMPR"	, ( BIXValue( (cFlow)->E2_VALOR, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) * ( -1 ) ) )
					oRecord:SetValue( "HLD_VVECTO"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) * ( -1 ) ) )
				Else
					oRecord:SetValue( "HLD_VCOMPR"	, ( BIXValue( (cFlow)->E2_VALOR, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) ) )
					oRecord:SetValue( "HLD_VVECTO"	, ( BIXValue( (cFlow)->E2_SALDO, (cFlow)->E2_MOEDA, cMoeda, (cFlow)->E2_VENCREA, nFee ) ) )
				EndIf
			EndIf
			
			oOutput:Send( oRecord ) 
		Next nMoeda

		(cFlow)->( DBSkip() )
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------
	oOutput:Release()
	
 	//-------------------------------------------------------------------
	// Mata as vari�veis do tipo array para diminuir o consumo de mem�ria 
	//-------------------------------------------------------------------  		  
	aSize(aFilInfo, 0)
	aFilInfo := Nil
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma �nica tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restri��o na recupera��o de dados no formato {{campo, opera��o, valor}}. 
@return cFlow, String, Alias tempor�rio. 

@author  Helio Leal
@since   06/03/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPagVenc
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cDML += " SELECT "  
	cDML += " 		SE2.E2_TXMOEDA,"
	cDML += " 		SE2.E2_EMISSAO,"
	cDML += " 		SE2.E2_VENCREA,"
	cDML += " 		SE2.E2_PREFIXO,"
	cDML += " 		SE2.E2_NUM,"
	cDML += " 		SE2.E2_PARCELA,"
	cDML += " 		SE2.E2_TIPO,"
	cDML += " 		SE2.E2_VALOR,"
	cDML += " 		SE2.E2_MOEDA,"
	cDML += " 		SE2.E2_SALDO,"
	cDML += " 		SE2.E2_BCOPAG,"
	cDML += " 		SE2.E2_CCUSTO,"
	cDML += " 		SE2.E2_NATUREZ,"
	cDML += " 		SE2.E2_FORNECE,"
	cDML += " 		SE2.E2_LOJA,"
	If ( cPaisLoc == "MEX" )
		cDML += " 	SE2.E2_VALIMP1,"	
	EndIf
	cDML += " 		SE2.E2_FILORIG"
	cDML += " FROM " + RetSQLName( "SE2" ) + " SE2 "
	//---------------------------------------------------------------------------------------
	// Jun��o com SA6 (Bancos) para receber o c�digo do banco.
	//---------------------------------------------------------------------------------------
	cDML += " LEFT JOIN (SELECT DISTINCT SA6.A6_COD "
	cDML += " FROM " + RetSQLName( "SA6" ) + " SA6 "
	cDML += " WHERE SA6.A6_FILIAL = '" + xFilial( "SA6" ) + "'"
	cDML += " AND D_E_L_E_T_ = ' ') SA6 "
	cDML += " ON  SA6.A6_COD = SE2.E2_BCOPAG "
	cDML += " WHERE SE2.E2_FILIAL = '" + xFilial( "SE2" ) + "'"
	cDML += "		AND SE2.E2_SALDO > 0"
	cDML += "		AND ("
	cDML += "			SE2.E2_BAIXA = '" + Space( TamSX3( "E2_BAIXA" ) [1] ) + "'"
	cDML += "			OR" 
	cDML += "			SE2.E2_SALDO <> SE2.E2_VALOR)"
	cDML += "		AND SE2.E2_VENCREA BETWEEN '" + cFrom + "' AND '" + cTo + "'"
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