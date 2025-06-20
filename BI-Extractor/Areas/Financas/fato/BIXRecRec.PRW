#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRECREC.CH"

REGISTER EXTRACTOR HLJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRecRec
Apresenta informa��es dos t�tulos � receber que foram parcialmente ou 
totalmente recebidos.

@author  BI TEAM
@since   03/11/2010
/*/
//-------------------------------------------------------------------
Class BIXRecRec from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Valdiney V GOMES
@since   03/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRecRec
	_Super:New( FACT, "HLJ", STR0001, "SE5", { FINANCEIRO } ) //"Contas a Receber - Recebimento"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   03/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRecRec 
	Local oModel := BIXModel():Build( Self )
	
	oModel:AddField( "HLJ_EMPRES",	"C", 32, 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HLJ_ESTABL",	"C", 32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HLJ_UNDNEG",	"C", 32, 00, .T., "HJ1" ) //"Unidade de Neg�cio"	
	oModel:AddField( "HLJ_REPRES",	"C", 32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HLJ_BANCO" ,	"C", 32, 00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HLJ_ESPDOC",	"C", 32, 00, .T., "HJG" ) //"Esp�cie de Documento"
	oModel:AddField( "HLJ_CLIENT",	"C", 32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HLJ_REGIAO",	"C", 32, 00, .T., "HJB" ) //"Regi�o"	
	oModel:AddField( "HLJ_MOEDA" ,	"C", 32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HLJ_MODALI",	"C", 32, 00, .T., "HJF" ) //"Modalidade"	
	oModel:AddField( "HLJ_GRPCLI",	"C", 32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HLJ_CCUSTO",	"C", 32, 00, .T., "HJ5" ) //"Centro Custo"
	oModel:AddField( "HLJ_NATFIN",	"C", 32, 00, .T., "HYE" ) //"Natureza Financeira"
	oModel:AddField( "HLJ_DATA"	 ,	"D", 08, 00, .F., "HK2" ) //"Per�odo"
	
	oModel:AddField( "HLJ_DTEMIS",	"D", 08, 00 )
	oModel:AddField( "HLJ_DTVENC",	"D", 08, 00 )
	oModel:AddField( "HLJ_SERDOC",	"C", 08, 00 )
	oModel:AddField( "HLJ_NUMDOC",	"C", 40, 00 )
	oModel:AddField( "HLJ_PARCEL",	"C", 02, 00 )	
	oModel:AddField( "HLJ_SEQREC",	"C", 10, 00 )	
	oModel:AddField( "HLJ_PRZREC",	"N", 10, 00 )
	oModel:AddField( "HLJ_VDESCC",	"N", 16, 02 )
	oModel:AddField( "HLJ_VJUREC",	"N", 16, 02 )
	oModel:AddField( "HLJ_VRCBDO",	"N", 16, 02 )
	oModel:AddField( "HLJ_VSUBRC",	"N", 16, 02 )	
	
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
@param oKey, objeto, Objeto para valida��o de integridade referencial.

@author  BI TEAM
@since   10/11/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXRecRec
	Local oRegion	  := nil 
	Local aReason	  := {}
	Local aMoeda	  := {}
	Local cMoeda	  := ""
	Local nMoeda	  := 0 
	Local nFee		  := 0
	Local lFee 	      := .F.
	Local lIgnore	  := .F. 
	Local lUseFilOrig := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aFilInfo    := Array(3)	
	//-------------------------------------------------------------------
	// Recupera os par�metros da fato. 
	//------------------------------------------------------------------- 		
	aMoeda 	:= BIXGetMxF( ::cEntity )
	lFee 	:= BIXParInfo( "BIX_TXMOED"	, "L", .F. )	
	oRegion := BIXRegiao():New()	
	
	//-------------------------------------------------------------------
	// Identifica os motivo de baixa. 
	//------------------------------------------------------------------- 
	AAdd( aReason, "DSD" )
	AAdd( aReason, "FAT" )
	AAdd( aReason, "LIQ" )
	AAdd( aReason, "AGL" )
	
	SA1->( dbSetOrder(1) )

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While ! (cFlow)->( Eof() ) 
		//-------------------------------------------------------------------
		// Identifica se � um pagamento. 
		//------------------------------------------------------------------- 		
		lIgnore := ( AllTrim( (cFlow)->E5_RECPAG ) == "P" )
		
		If ! ( lIgnore )
			//-------------------------------------------------------------------
			// Identifica se a baixa foi cancelada. 
			//------------------------------------------------------------------- 
			lIgnore := TemBxCanc( (cFlow)->E5_PREFIXO + (cFlow)->E5_NUMERO + (cFlow)->E5_PARCELA + (cFlow)->E5_TIPO + (cFlow)->E5_CLIFOR + (cFlow)->E5_LOJA + (cFlow)->E5_SEQ )
			
			If ! ( lIgnore )
				//-------------------------------------------------------------------
				// Identifica se o documento � do tipo Baixas ou Movimenta��o banc�ria. 
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
				If ! Empty( (cFlow)->E5_FILORIG )
					aFilInfo := BIXFOri( (cFlow)->E5_FILORIG )
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
				oRecord:SetFilOrig( (cFlow)->E5_FILORIG ) 
					
				//-------------------------------------------------------------------
				// Customiza��o.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "E5_DATA"		, (cFlow)->E5_DATA ) 
				oRecord:SetValue( "E5_BANCO"	, (cFlow)->E5_BANCO )
				oRecord:SetValue( "E5_AGENCIA"	, (cFlow)->E5_AGENCIA )
				oRecord:SetValue( "E5_CONTA"	, (cFlow)->E5_CONTA )
				oRecord:SetValue( "A3_COD"		, (cFlow)->E1_VEND1 ) 
				oRecord:SetValue( "A6_COD"		, (cFlow)->E5_BANCO )
				oRecord:SetValue( "A6_AGENCIA"	, (cFlow)->E5_AGENCIA )
				oRecord:SetValue( "A6_NUMCON"	, (cFlow)->E5_CONTA )
				oRecord:SetValue( "CTT_CUSTO"	, (cFlow)->E5_CCUSTO )
				oRecord:SetValue( "ED_CODIGO"	, (cFlow)->E5_NATUREZ )
				oRecord:SetValue( "A1_COD"		, (cFlow)->E1_CLIENTE )
				oRecord:SetValue( "A1_LOJA"		, (cFlow)->E1_LOJA )
				
				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLJ_EMPRES"	, oSeeker:Seek( "HJ4", { aFilInfo[1] } ) ) 
				oRecord:SetValue( "HLJ_ESTABL"	, oSeeker:Seek( "HKK", { aFilInfo[1], aFilInfo[2], aFilInfo[3] } ) ) 
				oRecord:SetValue( "HLJ_UNDNEG"	, oSeeker:Seek( "HJ1", { aFilInfo[1], aFilInfo[2] } ) ) 
				oRecord:SetValue( "HLJ_REPRES"	, oSeeker:Seek( "HJC", { (cFlow)->E1_VEND1 } ) ) 	
				oRecord:SetValue( "HLJ_BANCO"	, oSeeker:Seek( "HG4", { (cFlow)->E5_BANCO, (cFlow)->E5_AGENCIA, (cFlow)->E5_CONTA } ) ) 
				oRecord:SetValue( "HLJ_ESPDOC"	, oSeeker:Seek( "HJG", { (cFlow)->E5_TIPO } ) ) 
				oRecord:SetValue( "HLJ_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->E1_CLIENTE, (cFlow)->E1_LOJA } ) ) 	
				oRecord:SetValue( "HLJ_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
				oRecord:SetValue( "HLJ_MODALI" 	, oSeeker:Seek( "HJF", { (cFlow)->E1_SITUACA } ) ) 	
				oRecord:SetValue( "HLJ_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E5_CCUSTO } ) ) 
				oRecord:SetValue( "HLJ_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E5_NATUREZ } ) ) 	
				
				If SA1->( MsSeek( xFilial("SA1") + (cFlow)->E1_CLIENTE + (cFlow)->E1_LOJA ) )
					oRecord:SetValue( "HLJ_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
					oRecord:SetValue( "HLJ_GRPCLI"	, oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )		
				Else
					oRecord:SetValue( "HLJ_REGIAO"	, oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
					oRecord:SetValue( "HLJ_GRPCLI"	, oSeeker:Seek( "HJ0", { UNDEFINED } ) )
				EndIf
				
				oRecord:SetValue( "HLJ_DTVENC"	, (cFlow)->E1_VENCREA  )
				oRecord:SetValue( "HLJ_DTEMIS"	, (cFlow)->E1_EMISSAO  )
				oRecord:SetValue( "HLJ_DATA"	, (cFlow)->E5_DATA  )		
				oRecord:SetValue( "HLJ_SERDOC"	, (cFlow)->E1_PREFIXO  )
				oRecord:SetValue( "HLJ_NUMDOC"	, (cFlow)->E1_NUM  )
				oRecord:SetValue( "HLJ_PARCEL"	, (cFlow)->E1_PARCELA  )
				oRecord:SetValue( "HLJ_SEQREC"	, (cFlow)->E5_SEQ )	
	
				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 	
				oRecord:SetValue( "HLJ_VDESCC"	, BIXValue( (cFlow)->E5_VLDESCO, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee ) )	
				oRecord:SetValue( "HLJ_VJUREC"	, BIXValue( (cFlow)->E5_VLJUROS, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee ) )	
				oRecord:SetValue( "HLJ_PRZREC"	, BIXVldValor( (cFlow)->E1_BAIXA, (cFlow)->E1_EMISSAO, 3 ) )	
	
				If ! ( AScan( aReason, AllTrim( (cFlow)->E5_MOTBX ) ) ) == 0
					oRecord:SetValue( "HLJ_VSUBRC"	, BIXValue( (cFlow)->E5_VALOR, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee ) )
					oRecord:SetValue( "HLJ_VRCBDO"	, 0 )
				Else
					oRecord:SetValue( "HLJ_VSUBRC"	, 0 )
					oRecord:SetValue( "HLJ_VRCBDO"	, BIXValue( (cFlow)->E5_VALOR, (cFlow)->E5_MOEDA, cMoeda, (cFlow)->E5_DATA, nFee)  )
				EndIf
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de grava��o. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nMoeda	
		EndIf 

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
	
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma �nica tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restri��o na recupera��o de dados no formato {{campo, opera��o, valor}}. 
@return cFlow, Alias tempor�rio. 

@author  Valdiney V GOMES
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXRecRec
	Local cDML 		:= ""
	Local cReason	:= SuperGetMv ("MV_PLMOTBC", , "")

	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
	cDML += " SELECT "  
	cDML += " 		SE1.E1_BAIXA,"
	cDML += " 		SE1.E1_CLIENTE,"
	cDML += " 		SE1.E1_EMISSAO,"
	cDML += " 		SE1.E1_LOJA,"
	cDML += " 		SE1.E1_NUM,"
	cDML += " 		SE1.E1_PARCELA,"
	cDML += " 		SE1.E1_PREFIXO,"
	cDML += " 		SE1.E1_SITUACA,"
	cDML += " 		SE1.E1_VENCREA,"
	cDML += " 		SE1.E1_VEND1,"
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
	cDML += " INNER JOIN " + RetSQLName( "SE1" ) + " SE1 "	
	cDML += " 		ON SE1.E1_FILIAL = '" + xFilial( "SE1" ) + "'" 	
	cDML += " 		AND SE1.E1_PREFIXO = SE5.E5_PREFIXO"
	cDML += " 		AND SE1.E1_NUM = SE5.E5_NUMERO"
	cDML += " 		AND SE1.E1_PARCELA = SE5.E5_PARCELA"
	cDML += " 		AND SE1.E1_TIPO = SE5.E5_TIPO"
	cDML += " 		AND SE1.D_E_L_E_T_ = ' '" 
	cDML += " WHERE SE5.E5_FILIAL = '" + xFilial( "SE5" ) + "'" 
	cDML +=  "		AND SE5.E5_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cDML += "		AND SE5.E5_MOTBX <> '" + cReason + "'" 
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
	TCSetField( ::cFlow, "E1_EMISSAO", "D", 08, 0 )
	TCSetField( ::cFlow, "E1_VENCREA", "D", 08, 0 )
	TCSetField( ::cFlow, "E1_BAIXA"	 , "D", 08, 0 )
	TCSetField( ::cFlow, "E5_DATA"	 , "D", 08, 0 )
Return ::cFlow